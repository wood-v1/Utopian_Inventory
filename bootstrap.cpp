#include "bootstrap.h"

#include "console_bridge.h"
#include "diagnostics.h"
#include "input_bridge.h"
#include "runtime_config.h"
#include "runtime_state.h"
#include "ui_bridge.h"
#include "ui_layout.h"

#include "OynonToolsApi.h"

#include <cstdio>

namespace inventory_overhaul
{
namespace
{
constexpr const char* NATIVE_VERSION =
    "INV_OVERHAUL_INVENTORY_NATIVE_VERSION 2026.08.16-quickslot-weapon-select-1";

bool InitializeEngineHooks(Diagnostics& diagnostics)
{
    if (!OynonSetPlayerBootstrapEffect("inv_overhaul_inventory_bootstrap.bin")) {
        diagnostics.Log(
            "InventoryOverhaul failed to configure inventory bootstrap effect");
    }
    if (!OynonSetPlayerInventoryCategoryCapacity(64)) {
        diagnostics.Log(
            "InventoryOverhaul failed to configure player category capacity");
    }
    if (!OynonSetWorldContainerCapacity(128)) {
        diagnostics.Log(
            "InventoryOverhaul failed to configure world container capacity");
    }

    const DWORD hookFlags =
        OYNON_HOOK_PLAYER_EFFECT_CALLBACK |
        OYNON_HOOK_CONSOLE_READ |
        OYNON_HOOK_CONSOLE_EXECUTE |
        OYNON_HOOK_PLAYER_INVENTORY_CAPACITY |
        OYNON_HOOK_UI_INVENTORY_STATE |
        OYNON_HOOK_UI_INVENTORY_REDIRECT |
        OYNON_HOOK_UI_WINDOW_PREPARE |
        OYNON_HOOK_PLAYER_USE_CALLBACK;

    if (!OynonInitializeHooksWhenReady(hookFlags)) {
        diagnostics.Log("InventoryOverhaul failed to initialize OynonTools hooks");
        return false;
    }
    return true;
}

void RegisterCallbacks(
    ConsoleBridge& console,
    Diagnostics& diagnostics,
    InputBridge& input)
{
    if (!console.RegisterMessageCallback()) {
        diagnostics.Log(
            "InventoryOverhaul failed to register console message callback");
    }
    if (!diagnostics.RegisterConsoleMessageFilter()) {
        diagnostics.Log(
            "InventoryOverhaul failed to register console message filter");
    }
    if (!input.RegisterConsoleCommandFilter()) {
        diagnostics.Log(
            "InventoryOverhaul failed to register console command filter");
    }
}

void RegisterUiAndInputCallbacks(
    Diagnostics& diagnostics,
    InputBridge& input,
    UiBridge& ui)
{
    ui.RegisterInventoryStateCallback();
    if (!input.RegisterKeyboardCallback()) {
        diagnostics.Log("InventoryOverhaul failed to register keyboard callback");
    }
    if (!ui.RegisterWindowPrepareCallback()) {
        diagnostics.Log("InventoryOverhaul failed to register pre-window callback");
    }
    if (!ui.RegisterWindowCreatedCallback()) {
        diagnostics.Log("InventoryOverhaul failed to register post-window callback");
    }
}

void LogInitialization(
    Diagnostics& diagnostics,
    const RuntimeConfiguration& configuration,
    const UiRedirects& redirects)
{
    diagnostics.Log("InventoryOverhaul debug logging enabled");

    char opacityLine[96] = {};
    std::snprintf(
        opacityLine,
        sizeof(opacityLine),
        "empty slot opacity=%.3f",
        configuration.emptySlotOpacity);
    diagnostics.Log(opacityLine);

    diagnostics.Log(IsCenteredInventoryXml(redirects.inventoryXml)
        ? "InventoryOverhaul initialized (centered 1920x1080 layout)"
        : "InventoryOverhaul initialized (standard layout)");
    diagnostics.Log(IsCenteredLootXml(redirects.lootXml)
        ? "InventoryOverhaul loot redirect initialized (centered 1920x1080 layout)"
        : "InventoryOverhaul loot redirect initialized (standard layout)");
    diagnostics.Log(
        "InventoryOverhaul vanilla special inventory physical priority initialized");
}

void RunPollingLoop(InputBridge& input, UiBridge& ui)
{
    DWORD lastBootstrapConfirmation = 0;
    input.BeginPolling();
    while (true) {
        OynonUIPoll();
        OynonUIInventoryPoll();
        OynonKeyboardPoll();
        ui.PollPageHover();
        const DWORD now = ::GetTickCount();
        input.RefreshBindingIfDue(now);
        if (now - lastBootstrapConfirmation >= 250) {
            // The module can be injected after playerstat.xml was created, so
            // a window callback alone cannot initialize the character branch
            // before the first inventory. The Oynon side still requires a
            // complete five-category inventory and makes repeated confirms a
            // no-op for an already bootstrapped player.
            OynonConfirmPlayerBootstrapReady();
            lastBootstrapConfirmation = now;
        }
        input.RetryPendingQuickslot();
        ::Sleep(16);
    }
}
}
}

DWORD WINAPI MainThread(LPVOID parameter)
{
    using namespace inventory_overhaul;

    const HMODULE module = static_cast<HMODULE>(parameter);
    const RuntimeConfiguration configuration = LoadRuntimeConfiguration(module);
    RuntimeState state;
    Diagnostics diagnostics(configuration.debugEnabled, configuration.debugLogPath);
    InputBridge input(state, diagnostics, configuration.inputConfigPath);
    ConsoleBridge console(state, diagnostics);
    UiBridge ui(state, diagnostics);

    input.RefreshHandCombatKey(true);
    diagnostics.Log(NATIVE_VERSION);
    if (!WriteEmptySlotTexture(module, configuration.emptySlotOpacity)) {
        diagnostics.Log("failed to create empty slot opacity texture");
    }

    if (!InitializeEngineHooks(diagnostics)) {
        return 0;
    }
    RegisterCallbacks(console, diagnostics, input);

    const UiRedirects redirects = ui.ConfigureRedirects();
    if (!ui.InitializeRuntimeTextureEpoch()) {
        diagnostics.Log("InventoryOverhaul failed to publish runtime texture epoch");
    }
    diagnostics.Log("InventoryOverhaul persistent UI texture cache disabled");
    RegisterUiAndInputCallbacks(diagnostics, input, ui);
    LogInitialization(diagnostics, configuration, redirects);

    RunPollingLoop(input, ui);
    return 0;
}
