#include "console_bridge.h"

#include "diagnostics.h"
#include "runtime_state.h"
#include "ui_layout.h"

#include "OynonToolsApi.h"

#include <cstdio>
#include <cstdlib>
#include <cstring>

namespace inventory_overhaul
{
ConsoleBridge::ConsoleBridge(RuntimeState& state, Diagnostics& diagnostics)
    : state_(state), diagnostics_(diagnostics)
{
}

bool ConsoleBridge::RegisterMessageCallback()
{
    return OynonRegisterConsoleMessageCallback(&ConsoleMessage, this) != FALSE;
}

void __stdcall ConsoleBridge::ConsoleMessage(const char* message, void* userData)
{
    static_cast<ConsoleBridge*>(userData)->OnConsoleMessage(message);
}

void ConsoleBridge::OnConsoleMessage(const char* message)
{
    if (!message) {
        return;
    }

    if (diagnostics_.HandleCacheConsoleMessage(message)) {
        return;
    }

    constexpr const char* effectLifecyclePrefix = "INV_OVERHAUL_EFFECT_LIFECYCLE ";
    const char* effectLifecycleMessage = std::strstr(message, effectLifecyclePrefix);
    if (effectLifecycleMessage) {
        int effectGeneration = 0;
        const char* generationText = std::strstr(effectLifecycleMessage, "generation=");
        if (generationText) {
            effectGeneration = static_cast<int>(std::strtol(
                generationText + std::strlen("generation="),
                nullptr,
                10));
        }
        if (std::strstr(effectLifecycleMessage, "quickslots start") ||
            std::strstr(effectLifecycleMessage, "quickslots resume")) {
            state_.quickslotsGeneration.store(
                effectGeneration,
                std::memory_order_release);
            state_.quickslotsReady.store(true, std::memory_order_release);
        }
        else if (std::strstr(effectLifecycleMessage, "quickslots stop")) {
            const int activeGeneration =
                state_.quickslotsGeneration.load(std::memory_order_acquire);
            if (effectGeneration <= 0 || effectGeneration == activeGeneration) {
                state_.quickslotsReady.store(false, std::memory_order_release);
            }
            else {
                char staleLine[144] = {};
                std::snprintf(
                    staleLine,
                    sizeof(staleLine),
                    "quickslots stale stop ignored generation=%d active=%d",
                    effectGeneration,
                    activeGeneration);
                diagnostics_.Log(staleLine);
            }
        }
        diagnostics_.Log(effectLifecycleMessage);
        return;
    }

    constexpr const char* handsDropPrefix = "inv_overhaul_drop_hands ";
    const char* handsDropMessage = std::strstr(message, handsDropPrefix);
    if (handsDropMessage) {
        diagnostics_.Log(handsDropMessage);
        return;
    }

    constexpr const char* quickslotTracePrefix = "inv_overhaul_quickslot ";
    const char* quickslotTraceMessage = std::strstr(message, quickslotTracePrefix);
    if (quickslotTraceMessage) {
        diagnostics_.Log(quickslotTraceMessage);
        return;
    }

    if (diagnostics_.HandlePerformanceConsoleMessage(
            message,
            state_.playerBranch.load(std::memory_order_acquire))) {
        return;
    }

    constexpr const char* branchPrefix = "INV_OVERHAUL_PLAYER_BRANCH ";
    const char* branchRequest = std::strstr(message, branchPrefix);
    if (branchRequest) {
        // The branch marker belongs to the freshly constructed bootstrap task.
        // Its quickslot effect is applied immediately afterwards; invalidate
        // readiness only for this narrow, real player-transition interval.
        state_.quickslotsReady.store(false, std::memory_order_release);
        char* end = nullptr;
        const long branch = std::strtol(
            branchRequest + std::strlen(branchPrefix),
            &end,
            10);
        if (end == branchRequest + std::strlen(branchPrefix) || branch < 0 || branch > 2) {
            diagnostics_.Log("player branch request parse failed");
            return;
        }

        state_.playerBranch.store(static_cast<int>(branch), std::memory_order_release);
        const char* inventoryXml = ResolveInventoryXml(static_cast<int>(branch));
        OynonUIInventorySetRedirect(inventoryXml);

        char line[160] = {};
        std::snprintf(
            line,
            sizeof(line),
            "player branch=%ld inventory redirect=%s",
            branch,
            inventoryXml);
        diagnostics_.Log(line);
        return;
    }

    constexpr const char* prefix = "INV_OVERHAUL_QUICKSLOT_NATIVE_HANDS ";
    const char* request = std::strstr(message, prefix);
    if (!request) {
        return;
    }

    char* end = nullptr;
    const long itemId = std::strtol(request + std::strlen(prefix), &end, 10);
    if (end == request + std::strlen(prefix)) {
        diagnostics_.Log("quickslot native hands request parse failed");
        return;
    }

    const bool applied = OynonSetPlayerHandsItem(static_cast<int>(itemId)) != FALSE;
    char line[128] = {};
    std::snprintf(
        line,
        sizeof(line),
        "quickslot native hands item=%ld applied=%s",
        itemId,
        applied ? "true" : "false");
    diagnostics_.Log(line);
}
}
