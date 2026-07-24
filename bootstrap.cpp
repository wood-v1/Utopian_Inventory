#include "framework.h"

#include "OynonToolsApi.h"

#include <atomic>
#include <cstdio>
#include <cstdlib>
#include <string>
#include <vector>

namespace
{
constexpr const char* DEBUG_CHANNEL = "UtopianInventory";
constexpr const char* CUSTOM_INVENTORY_XML = "utopian_inventory.xml";
constexpr const char* CUSTOM_INVENTORY_XML_1920 = "utopian_inventory_1920x1080.xml";
constexpr const char* CUSTOM_LOOT_XML = "utopian_container.xml";
constexpr const char* CUSTOM_LOOT_XML_1920 = "utopian_container_1920x1080.xml";
constexpr const char* CUSTOM_CORPSE_XML = "utopian_corpse.xml";
constexpr const char* CUSTOM_CORPSE_XML_1920 = "utopian_corpse_1920x1080.xml";
constexpr int PAGE_BUTTON_WIDTH = 32;
constexpr int PAGE_BUTTON_HEIGHT = 28;
constexpr int PAGE_NEXT_OFFSET = 100;

std::atomic<bool> g_inventoryOpen{ false };
int g_publishedPageHover = -1;
float g_emptySlotOpacity = 1.0f;

std::string GetIniPath(HMODULE module)
{
    char path[MAX_PATH] = {};
    const DWORD length = ::GetModuleFileNameA(module, path, MAX_PATH);
    if (length == 0 || length >= MAX_PATH) {
        return "UtopianInventory.ini";
    }

    std::string result(path, length);
    const std::string::size_type separator = result.find_last_of("\\/");
    if (separator == std::string::npos) {
        return "UtopianInventory.ini";
    }
    result.resize(separator + 1);
    result += "UtopianInventory.ini";
    return result;
}

float ReadEmptySlotOpacity(HMODULE module)
{
    char buffer[32] = {};
    const std::string iniPath = GetIniPath(module);
    ::GetPrivateProfileStringA(
        "General",
        "EmptySlotOpacity",
        "1.0",
        buffer,
        static_cast<DWORD>(sizeof(buffer)),
        iniPath.c_str());

    char* end = nullptr;
    float value = std::strtof(buffer, &end);
    if (end == buffer) {
        value = 1.0f;
    }
    if (value < 0.0f) {
        value = 0.0f;
    }
    if (value > 1.0f) {
        value = 1.0f;
    }
    return value;
}

bool WriteEmptySlotTexture(HMODULE module)
{
    wchar_t modulePath[MAX_PATH] = {};
    const DWORD length = ::GetModuleFileNameW(module, modulePath, MAX_PATH);
    if (length == 0 || length >= MAX_PATH) {
        return false;
    }

    std::wstring texturePath(modulePath, length);
    const std::wstring::size_type separator = texturePath.find_last_of(L"\\/");
    if (separator == std::wstring::npos) {
        return false;
    }
    texturePath.resize(separator + 1);
    texturePath += L"..\\..\\..\\data\\Textures\\UI\\utopian_slot_empty.tga";

    wchar_t normalizedPath[MAX_PATH] = {};
    const DWORD normalizedLength =
        ::GetFullPathNameW(texturePath.c_str(), MAX_PATH, normalizedPath, nullptr);
    if (normalizedLength == 0 || normalizedLength >= MAX_PATH) {
        return false;
    }

    constexpr int textureWidth = 64;
    constexpr int textureHeight = 64;
    constexpr int bytesPerPixel = 4;
    constexpr int headerSize = 18;
    std::vector<unsigned char> tga(
        headerSize + textureWidth * textureHeight * bytesPerPixel,
        0);
    tga[2] = 2;
    tga[12] = static_cast<unsigned char>(textureWidth);
    tga[14] = static_cast<unsigned char>(textureHeight);
    tga[16] = 32;
    tga[17] = 40;
    const unsigned char alpha = static_cast<unsigned char>(
        g_emptySlotOpacity * 255.0f + 0.5f);
    for (int pixel = 0; pixel < textureWidth * textureHeight; ++pixel) {
        tga[headerSize + pixel * bytesPerPixel + 3] = alpha;
    }

    const HANDLE file = ::CreateFileW(
        normalizedPath,
        GENERIC_WRITE,
        FILE_SHARE_READ,
        nullptr,
        CREATE_ALWAYS,
        FILE_ATTRIBUTE_NORMAL,
        nullptr);
    if (file == INVALID_HANDLE_VALUE) {
        return false;
    }

    DWORD written = 0;
    const BOOL writeSucceeded = ::WriteFile(
        file,
        tga.data(),
        static_cast<DWORD>(tga.size()),
        &written,
        nullptr);
    ::CloseHandle(file);
    return writeSucceeded && written == tga.size();
}

void PublishEmptySlotOpacity()
{
    const int scaledOpacity = static_cast<int>(g_emptySlotOpacity * 1000.0f + 0.5f);
    char command[96] = {};
    std::snprintf(
        command,
        sizeof(command),
        "setvar utopian_inventory_empty_slot_opacity %d",
        scaledOpacity);
    OynonExecCommand(command);

    char line[96] = {};
    std::snprintf(line, sizeof(line), "empty slot opacity=%.3f", g_emptySlotOpacity);
    OynonDebugLog(DEBUG_CHANNEL, line);
}

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

const char* ResolveLootXml()
{
    int width = 0;
    int height = 0;
    GetGameClientSize(width, height);
    if (width == 1920 && height == 1080) {
        return CUSTOM_LOOT_XML_1920;
    }
    return CUSTOM_LOOT_XML;
}

const char* ResolveCorpseXml()
{
    int width = 0;
    int height = 0;
    GetGameClientSize(width, height);
    if (width == 1920 && height == 1080) {
        return CUSTOM_CORPSE_XML_1920;
    }
    return CUSTOM_CORPSE_XML;
}

void Log(const char* line)
{
    OynonDebugLog(DEBUG_CHANNEL, line);
}

void __stdcall OnInventoryStateChanged(BOOL opened, void*)
{
    g_inventoryOpen.store(opened != FALSE);
    if (!opened) {
        g_publishedPageHover = -1;
    }
    Log(opened ? "inventory overlay opened" : "inventory overlay closed");
}

bool IsPointInside(const POINT& point, int x, int y)
{
    return point.x >= x && point.x < x + PAGE_BUTTON_WIDTH &&
        point.y >= y && point.y < y + PAGE_BUTTON_HEIGHT;
}

int HitPagePair(const POINT& point, int x, int y, int previousTarget, int nextTarget)
{
    if (IsPointInside(point, x, y)) {
        return previousTarget;
    }
    if (IsPointInside(point, x + PAGE_NEXT_OFFSET, y)) {
        return nextTarget;
    }
    return 0;
}

int ResolvePageHoverTarget()
{
    if (!g_inventoryOpen.load()) {
        return 0;
    }

    HWND window = ::GetForegroundWindow();
    DWORD processId = 0;
    if (!window) {
        return 0;
    }
    ::GetWindowThreadProcessId(window, &processId);
    if (processId != ::GetCurrentProcessId()) {
        return 0;
    }

    RECT client = {};
    POINT cursor = {};
    if (!::GetClientRect(window, &client) ||
        !::GetCursorPos(&cursor) ||
        !::ScreenToClient(window, &cursor)) {
        return 0;
    }

    const int width = client.right - client.left;
    const int height = client.bottom - client.top;
    const DWORD kind = OynonUIInventoryGetOverlayKind();

    if (kind == OYNON_INVENTORY_OVERLAY_PLAYER) {
        if (width == 1920 && height == 1080) {
            return HitPagePair(cursor, 1161, 780, 1, 2);
        }
        if (width == 1024 && height == 768) {
            return HitPagePair(cursor, 710, 580, 1, 2);
        }
        if (width < 1000) {
            return HitPagePair(cursor, 359, 465, 1, 2);
        }
        return 0;
    }

    if (kind == OYNON_INVENTORY_OVERLAY_CONTAINER ||
        kind == OYNON_INVENTORY_OVERLAY_CORPSE) {
        int target = 0;
        if (width == 1920 && height == 1080) {
            target = HitPagePair(cursor, 1161, 780, 1, 2);
            if (target == 0) {
                target = HitPagePair(cursor, 528, 625, 5, 6);
            }
            return target;
        }
        if (width == 1280 && height == 1024) {
            return HitPagePair(cursor, 198, 434, 5, 6);
        }
        if (width == 1024 && height == 768) {
            target = HitPagePair(cursor, 650, 580, 1, 2);
            if (target == 0) {
                target = HitPagePair(cursor, 149, 506, 5, 6);
            }
            return target;
        }
        target = HitPagePair(cursor, 501, 465, 1, 2);
        if (target == 0) {
            target = HitPagePair(cursor, 107, 453, 5, 6);
        }
        return target;
    }

    return 0;
}

void PollPageHover()
{
    const int hoverTarget = ResolvePageHoverTarget();
    if (hoverTarget == g_publishedPageHover) {
        return;
    }

    char command[96] = {};
    std::snprintf(
        command,
        sizeof(command),
        "setvar utopian_inventory_page_hover %d",
        hoverTarget);
    if (!OynonExecCommand(command)) {
        return;
    }

    g_publishedPageHover = hoverTarget;
    char line[64] = {};
    std::snprintf(line, sizeof(line), "native page-hover target=%d", hoverTarget);
    Log(line);
}
}

DWORD WINAPI MainThread(LPVOID parameter)
{
    const HMODULE module = static_cast<HMODULE>(parameter);
    g_emptySlotOpacity = ReadEmptySlotOpacity(module);
    OynonDebugConfigureLauncherChannel(DEBUG_CHANNEL, FALSE);
    if (!WriteEmptySlotTexture(module)) {
        Log("failed to create empty slot opacity texture");
    }

    if (!OynonSetPlayerBootstrapEffect("utopian_inventory_guard.bin")) {
        Log("UtopianInventory failed to configure inventory guard effect");
    }
    if (!OynonSetPlayerInventoryCategoryCapacity(64)) {
        Log("UtopianInventory failed to configure player category capacity");
    }
    if (!OynonSetWorldContainerCapacity(128)) {
        Log("UtopianInventory failed to configure world container capacity");
    }

    const DWORD hookFlags =
        OYNON_HOOK_PLAYER_EFFECT_CALLBACK |
        OYNON_HOOK_CONSOLE_EXECUTE |
        OYNON_HOOK_PLAYER_INVENTORY_CAPACITY |
        OYNON_HOOK_UI_INVENTORY_STATE |
        OYNON_HOOK_UI_INVENTORY_REDIRECT;

    if (!OynonInitializeHooksWhenReady(hookFlags)) {
        Log("UtopianInventory failed to initialize OynonTools hooks");
        return 0;
    }

    const char* inventoryXml = ResolveInventoryXml();
    const char* lootXml = ResolveLootXml();
    const char* corpseXml = ResolveCorpseXml();
    OynonUIInventorySetRedirect(inventoryXml);
    OynonUILootSetRedirects(lootXml, corpseXml);
    OynonRegisterInventoryStateCallback(&OnInventoryStateChanged, nullptr);
    PublishEmptySlotOpacity();
    Log(inventoryXml == CUSTOM_INVENTORY_XML_1920
        ? "UtopianInventory initialized (centered 1920x1080 layout)"
        : "UtopianInventory initialized (standard layout)");
    Log(lootXml == CUSTOM_LOOT_XML_1920
        ? "UtopianInventory loot redirect initialized (centered 1920x1080 layout)"
        : "UtopianInventory loot redirect initialized (standard layout)");

    while (true) {
        OynonUIInventoryPoll();
        PollPageHover();
        ::Sleep(16);
    }
}
