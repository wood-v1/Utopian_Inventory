#include "framework.h"

#include "OynonToolsApi.h"

namespace
{
constexpr const char* DEBUG_CHANNEL = "UtopianInventory";
constexpr const char* CUSTOM_INVENTORY_XML = "utopian_inventory.xml";
constexpr const char* CUSTOM_INVENTORY_XML_1920 = "utopian_inventory_1920x1080.xml";

bool GetGameClientSize(int& width, int& height)
{
    HWND window = ::GetForegroundWindow();
    DWORD processId = 0;
    if (window) {
        ::GetWindowThreadProcessId(window, &processId);
    }

    RECT client = {};
    if (window && processId == ::GetCurrentProcessId() && ::GetClientRect(window, &client)) {
        width = client.right - client.left;
        height = client.bottom - client.top;
        if (width > 0 && height > 0) {
            return true;
        }
    }

    width = ::GetSystemMetrics(SM_CXSCREEN);
    height = ::GetSystemMetrics(SM_CYSCREEN);
    return width > 0 && height > 0;
}

const char* ResolveInventoryXml()
{
    int width = 0;
    int height = 0;
    GetGameClientSize(width, height);
    if (width == 1920 && height == 1080) {
        return CUSTOM_INVENTORY_XML_1920;
    }
    return CUSTOM_INVENTORY_XML;
}

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

    const char* inventoryXml = ResolveInventoryXml();
    OynonUIInventorySetRedirect(inventoryXml);
    OynonRegisterInventoryStateCallback(&OnInventoryStateChanged, nullptr);
    Log(inventoryXml == CUSTOM_INVENTORY_XML_1920
        ? "UtopianInventory initialized (centered 1920x1080 layout)"
        : "UtopianInventory initialized (standard layout)");

    while (true) {
        OynonUIInventoryPoll();
        ::Sleep(16);
    }
}
