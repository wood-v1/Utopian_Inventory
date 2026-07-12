#include "framework.h"

#include "OynonToolsApi.h"

namespace
{
constexpr const char* DEBUG_CHANNEL = "UtopianInventory";
constexpr const char* CUSTOM_INVENTORY_XML = "utopian_inventory.xml";

void Log(const char* line)
{
    OynonDebugLog(DEBUG_CHANNEL, line);
}

void __stdcall OnInventoryStateChanged(BOOL opened, void*)
{
    Log(opened ? "inventory overlay opened" : "inventory overlay closed");
}
}

DWORD WINAPI MainThread(LPVOID)
{
    OynonDebugConfigureLauncherChannel(DEBUG_CHANNEL, FALSE);

    const DWORD hookFlags =
        OYNON_HOOK_UI_INVENTORY_STATE |
        OYNON_HOOK_UI_INVENTORY_REDIRECT;

    if (!OynonInitializeHooksWhenReady(hookFlags)) {
        Log("UtopianInventory failed to initialize OynonTools hooks");
        return 0;
    }

    OynonUIInventorySetRedirect(CUSTOM_INVENTORY_XML);
    OynonRegisterInventoryStateCallback(&OnInventoryStateChanged, nullptr);
    Log("UtopianInventory initialized (safe UI events, cursor polling disabled)");

    while (true) {
        OynonUIInventoryPoll();
        ::Sleep(16);
    }
}
