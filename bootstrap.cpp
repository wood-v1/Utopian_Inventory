#include "framework.h"

#include "OynonToolsApi.h"

#include <atomic>
#include <cstdio>

namespace
{
constexpr const char* DEBUG_CHANNEL = "UtopianInventory";
constexpr const char* CUSTOM_INVENTORY_XML = "utopian_inventory.xml";

std::atomic<int> g_pendingInventoryState{ -1 };
std::atomic<int> g_inventoryOpen{ 0 };
int g_lastCursorX = -99999;
int g_lastCursorY = -99999;
int g_lastCursorReady = -1;
HWND g_gameWindow = nullptr;

void Log(const char* line)
{
    OynonDebugLog(DEBUG_CHANNEL, line);
}

void SetIntVar(const char* name, int value)
{
    char command[128] = {};
    std::snprintf(command, sizeof(command), "setvar %s %d", name, value);
    OynonExecCommand(command);
}

BOOL CALLBACK FindProcessWindowProc(HWND window, LPARAM param)
{
    DWORD processId = 0;
    ::GetWindowThreadProcessId(window, &processId);
    if (processId != ::GetCurrentProcessId() || !::IsWindowVisible(window)) {
        return TRUE;
    }

    *reinterpret_cast<HWND*>(param) = window;
    return FALSE;
}

HWND GetGameWindow()
{
    if (g_gameWindow && ::IsWindow(g_gameWindow)) {
        return g_gameWindow;
    }

    HWND foreground = ::GetForegroundWindow();
    DWORD foregroundProcessId = 0;
    if (foreground) {
        ::GetWindowThreadProcessId(foreground, &foregroundProcessId);
        if (foregroundProcessId == ::GetCurrentProcessId()) {
            g_gameWindow = foreground;
            return g_gameWindow;
        }
    }

    HWND found = nullptr;
    ::EnumWindows(&FindProcessWindowProc, reinterpret_cast<LPARAM>(&found));
    g_gameWindow = found;
    return g_gameWindow;
}

void PublishCursorState(int ready, int x, int y)
{
    if (ready != g_lastCursorReady) {
        SetIntVar("utopian_inventory_cursor_ready", ready);
        g_lastCursorReady = ready;
    }
    if (x != g_lastCursorX) {
        SetIntVar("utopian_inventory_cursor_x", x);
        g_lastCursorX = x;
    }
    if (y != g_lastCursorY) {
        SetIntVar("utopian_inventory_cursor_y", y);
        g_lastCursorY = y;
    }
}

void PollCursorState()
{
    if (g_inventoryOpen.load() != 1) {
        PublishCursorState(1, -1, -1);
        return;
    }

    HWND window = GetGameWindow();
    POINT point = {};
    if (!window || !::GetCursorPos(&point) || !::ScreenToClient(window, &point)) {
        PublishCursorState(1, -1, -1);
        return;
    }

    PublishCursorState(1, static_cast<int>(point.x), static_cast<int>(point.y));
}

void __stdcall OnInventoryStateChanged(BOOL opened, void*)
{
    g_pendingInventoryState.store(opened ? 1 : 0);
    g_inventoryOpen.store(opened ? 1 : 0);
    Log(opened ? "inventory overlay opened" : "inventory overlay closed");
}
}

DWORD WINAPI MainThread(LPVOID)
{
    OynonDebugConfigureLauncherChannel(DEBUG_CHANNEL, FALSE);

    const DWORD hookFlags =
        OYNON_HOOK_CONSOLE_EXECUTE |
        OYNON_HOOK_UI_INVENTORY_STATE |
        OYNON_HOOK_UI_INVENTORY_REDIRECT;

    if (!OynonInitializeHooksWhenReady(hookFlags)) {
        Log("UtopianInventory failed to initialize OynonTools hooks");
        return 0;
    }

    OynonUIInventorySetRedirect(CUSTOM_INVENTORY_XML);
    OynonRegisterInventoryStateCallback(&OnInventoryStateChanged, nullptr);
    OynonExecCommand("setvar utopian_inventory_open 0");
    PublishCursorState(1, -1, -1);
    Log("UtopianInventory initialized");

    while (true) {
        OynonUIInventoryPoll();

        const int inventoryState = g_pendingInventoryState.exchange(-1);
        if (inventoryState != -1) {
            OynonExecCommand(inventoryState == 1
                ? "setvar utopian_inventory_open 1"
                : "setvar utopian_inventory_open 0");
        }

        PollCursorState();

        ::Sleep(16);
    }
}
