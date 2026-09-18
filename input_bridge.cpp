#include "input_bridge.h"

#include "diagnostics.h"
#include "runtime_config.h"
#include "runtime_state.h"

#include "OynonToolsApi.h"

#include <cctype>
#include <cstdio>

namespace inventory_overhaul
{
namespace
{
int GetQuickslotNumber(DWORD virtualKey)
{
    if (virtualKey >= '1' && virtualKey <= '9') {
        return static_cast<int>(virtualKey - '0');
    }
    if (virtualKey == '0') {
        return 10;
    }
    if (virtualKey >= VK_NUMPAD1 && virtualKey <= VK_NUMPAD9) {
        return static_cast<int>(virtualKey - VK_NUMPAD0);
    }
    if (virtualKey == VK_NUMPAD0) {
        return 10;
    }
    return 0;
}
}

InputBridge::InputBridge(
    RuntimeState& state,
    Diagnostics& diagnostics,
    std::string inputConfigPath)
    : state_(state),
      diagnostics_(diagnostics),
      inputConfigPath_(std::move(inputConfigPath))
{
}

void InputBridge::RefreshHandCombatKey(bool forceLog)
{
    const DWORD resolved = ReadHandCombatKey(inputConfigPath_);
    const DWORD previous = handCombatKey_.exchange(resolved);
    if (!forceLog && previous == resolved) {
        return;
    }
    char line[192] = {};
    std::snprintf(
        line, sizeof(line), "handcombat binding key=%lu config=%s",
        static_cast<unsigned long>(resolved), inputConfigPath_.c_str());
    diagnostics_.Log(line);
}

bool InputBridge::RegisterConsoleCommandFilter()
{
    return OynonRegisterConsoleCommandFilter(&ConsoleCommand, this) != FALSE;
}

bool InputBridge::RegisterKeyboardCallback()
{
    return OynonRegisterKeyboardCallback(&KeyboardInput, this) != FALSE;
}

void InputBridge::BeginPolling()
{
    lastBindingRefresh_ = ::GetTickCount();
}

void InputBridge::RefreshBindingIfDue(DWORD now)
{
    if (now - lastBindingRefresh_ >= 1000) {
        RefreshHandCombatKey(false);
        lastBindingRefresh_ = now;
    }
}

bool InputBridge::ItemHotkeysBlocked()
{
    const DWORD generation = OynonUIDialogInputGeneration();
    const bool changed = dialogInputGeneration_.exchange(generation) != generation;
    const bool blocked = OynonUIDialogBlocksItemHotkeys() != FALSE;
    if (changed || blocked) state_.pendingQuickslot.store(0, std::memory_order_release);
    return blocked;
}

void InputBridge::RetryPendingQuickslot()
{
    if (ItemHotkeysBlocked()) {
        state_.pendingQuickslot.store(0, std::memory_order_release);
        return;
    }
    const int pendingQuickslot =
        state_.pendingQuickslot.load(std::memory_order_acquire);
    if (pendingQuickslot <= 0 ||
        state_.inventoryOpen.load(std::memory_order_acquire) ||
        OynonUIInventoryGetOverlayKind() != OYNON_INVENTORY_OVERLAY_NONE) {
        return;
    }
    if (PublishQuickslotRequest(pendingQuickslot, "deferred")) {
        int expected = pendingQuickslot;
        state_.pendingQuickslot.compare_exchange_strong(
            expected,
            0,
            std::memory_order_acq_rel);
    }
}

void __stdcall InputBridge::KeyboardInput(
    DWORD virtualKey,
    BOOL pressed,
    void* userData)
{
    static_cast<InputBridge*>(userData)->OnKeyboardInput(virtualKey, pressed);
}

BOOL __stdcall InputBridge::ConsoleCommand(const char* command, void* userData)
{
    return static_cast<InputBridge*>(userData)->OnConsoleCommand(command);
}

void InputBridge::OnKeyboardInput(DWORD virtualKey, BOOL pressed)
{
    if (!pressed) {
        return;
    }

    // Shared UI state: suppress all item bindings (also numpad/handcombat),
    // without consuming Escape, dialogue input or changing user bindings.
    if (ItemHotkeysBlocked()) {
        state_.pendingQuickslot.store(0, std::memory_order_release);
        return;
    }
    const int quickslot = GetQuickslotNumber(virtualKey);
    const bool inventoryOpen = state_.inventoryOpen.load();
    const DWORD overlayKind = OynonUIInventoryGetOverlayKind();
    if (inventoryOpen || overlayKind != OYNON_INVENTORY_OVERLAY_NONE) {
        if (quickslot == 0) {
            return;
        }
        char ignoredLine[128] = {};
        std::snprintf(
            ignoredLine,
            sizeof(ignoredLine),
            "quick-slot key ignored slot=%d inventoryOpen=%d overlay=%lu",
            quickslot,
            inventoryOpen ? 1 : 0,
            static_cast<unsigned long>(overlayKind));
        diagnostics_.Log(ignoredLine);
        return;
    }

    if (virtualKey == handCombatKey_.load(std::memory_order_acquire)) {
        if (!OynonExecCommand("setvar inv_overhaul_handcombat_request 1")) {
            diagnostics_.Log("handcombat input command failed");
        }
        else {
            diagnostics_.Log("handcombat request published");
        }
    }

    if (quickslot == 0) {
        return;
    }

    if (!PublishQuickslotRequest(quickslot, "keyboard")) {
        state_.pendingQuickslot.store(quickslot, std::memory_order_release);
        char queuedLine[112] = {};
        std::snprintf(
            queuedLine,
            sizeof(queuedLine),
            "quick-slot request deferred slot=%d until native player context is ready",
            quickslot);
        diagnostics_.Log(queuedLine);
    }
}

BOOL InputBridge::OnConsoleCommand(const char* command)
{
    if (ItemHotkeysBlocked()) {
        state_.pendingQuickslot.store(0, std::memory_order_release);
        return FALSE;
    }
    if (!command || state_.inventoryOpen.load(std::memory_order_acquire) ||
        OynonUIInventoryGetOverlayKind() != OYNON_INVENTORY_OVERLAY_NONE ||
        state_.playerBranch.load(std::memory_order_acquire) < 0) {
        return FALSE;
    }

    while (*command && std::isspace(static_cast<unsigned char>(*command))) {
        ++command;
    }
    std::string action;
    while (*command && !std::isspace(static_cast<unsigned char>(*command))) {
        action.push_back(static_cast<char>(
            std::tolower(static_cast<unsigned char>(*command))));
        ++command;
    }
    if (action != "handcombat") {
        return FALSE;
    }

    OynonExecCommand("setvar inv_overhaul_handcombat_request 1");
    diagnostics_.Log("handcombat command observed; drop scheduled after vanilla holster");
    return FALSE;
}

bool InputBridge::PublishQuickslotRequest(int quickslot, const char* source)
{
    constexpr DWORD QUICK_SLOT_COOLDOWN_MS = 500;
    const DWORD now = ::GetTickCount();
    DWORD last = lastQuickslotRequestTick_.load(std::memory_order_acquire);
    while (last != 0 && now - last < QUICK_SLOT_COOLDOWN_MS) {
        return false;
    }
    while (!lastQuickslotRequestTick_.compare_exchange_weak(
        last,
        now,
        std::memory_order_acq_rel,
        std::memory_order_acquire)) {
        if (last != 0 && now - last < QUICK_SLOT_COOLDOWN_MS) {
            return false;
        }
    }

    char effectName[64] = {};
    std::snprintf(
        effectName,
        sizeof(effectName),
        "inv_overhaul_quickslot_request_%d.bin",
        quickslot);
    const bool nativeApplied = OynonApplyObservedPlayerEffect(effectName) != FALSE;
    if (!nativeApplied) {
        // Save loading replaces the player before OynonTools can observe a new
        // direct ApplyEffect call. The engine's own `effect` command resolves
        // the current player by name, so it is a safe one-shot transport that
        // does not retain or dereference a player pointer across worlds.
        char command[96] = {};
        std::snprintf(command, sizeof(command), "effect player %s", effectName);
        if (!OynonExecCommand(command)) {
            lastQuickslotRequestTick_.store(last, std::memory_order_release);
            diagnostics_.Log("quick-slot input transports unavailable");
            return false;
        }
    }

    char line[128] = {};
    std::snprintf(
        line,
        sizeof(line),
        "quick-slot request published slot=%d source=%s transport=%s",
        quickslot,
        source ? source : "unknown",
        nativeApplied ? "native" : "engine-command");
    diagnostics_.Log(line);
    return true;
}
}
