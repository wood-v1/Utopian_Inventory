#include "framework.h"

#include "OynonToolsApi.h"

#include <array>
#include <atomic>
#include <cstdio>
#include <cstdlib>
#include <cstring>
#include <algorithm>
#include <cctype>
#include <fstream>
#include <sstream>
#include <string>
#include <vector>

namespace
{
constexpr const char* DEBUG_CHANNEL = "UtopianInventory";
constexpr const char* CUSTOM_INVENTORY_XML = "utopian_inventory.xml";
constexpr const char* CUSTOM_INVENTORY_XML_1920 = "utopian_inventory_1920x1080.xml";
constexpr const char* CUSTOM_CLARA_INVENTORY_XML = "utopian_inventory_clara.xml";
constexpr const char* CUSTOM_CLARA_INVENTORY_XML_1920 = "utopian_inventory_clara_1920x1080.xml";
constexpr const char* CUSTOM_LOOT_XML = "utopian_container.xml";
constexpr const char* CUSTOM_LOOT_XML_1920 = "utopian_container_1920x1080.xml";
constexpr const char* CUSTOM_CORPSE_XML = "utopian_corpse.xml";
constexpr const char* CUSTOM_CORPSE_XML_1920 = "utopian_corpse_1920x1080.xml";
constexpr int PAGE_BUTTON_WIDTH = 40;
constexpr int PAGE_BUTTON_HEIGHT = 36;
constexpr int PAGE_NEXT_OFFSET = 92;
constexpr DWORD PLAYER_CATEGORY_COUNT = 5;
constexpr DWORD PLAYER_CATEGORY_MAPPING_STRIDE = 64;
constexpr DWORD PLAYER_INVENTORY_MAPPING_CAPACITY =
    PLAYER_CATEGORY_COUNT * PLAYER_CATEGORY_MAPPING_STRIDE;
constexpr std::array<DWORD, 5> APPARATUS_PRIORITY_IDS = {
    50, 51, 52, 53, 54
};
constexpr std::array<DWORD, 26> MICROSCOPE_PRIORITY_IDS = {
    59, 60, 61, 62, 63, 64, 65, 66, 67, 68, 69, 70,
    1113, 1117, 1118, 1119, 1120, 1121, 1122, 1126,
    1128, 1129, 1130, 1131, 1132, 1133
};
constexpr std::array<DWORD, 27> DOCTOR_APPARATUS_PRIORITY_IDS = {
    55,
    59, 60, 61, 62, 63, 64, 65, 66, 67, 68, 69, 70,
    1113, 1117, 1118, 1119, 1120, 1121, 1122, 1126,
    1128, 1129, 1130, 1131, 1132, 1133
};

std::atomic<bool> g_inventoryOpen{ false };
std::atomic<DWORD> g_handCombatKey{ 'X' };
std::atomic<int> g_playerBranch{ -1 };
int g_publishedPageHover = -1;
float g_emptySlotOpacity = 1.0f;
std::string g_inputConfigPath;

void Log(const char* line);
const char* ResolveInventoryXml();

void __stdcall OnConsoleMessage(const char* message, void*)
{
    if (!message) {
        return;
    }

    constexpr const char* branchPrefix = "UTOPIAN_PLAYER_BRANCH ";
    const char* branchRequest = std::strstr(message, branchPrefix);
    if (branchRequest) {
        char* end = nullptr;
        const long branch = std::strtol(
            branchRequest + std::strlen(branchPrefix),
            &end,
            10);
        if (end == branchRequest + std::strlen(branchPrefix) || branch < 0 || branch > 2) {
            Log("player branch request parse failed");
            return;
        }

        g_playerBranch.store(static_cast<int>(branch), std::memory_order_release);
        const char* inventoryXml = ResolveInventoryXml();
        OynonUIInventorySetRedirect(inventoryXml);

        char line[160] = {};
        std::snprintf(
            line,
            sizeof(line),
            "player branch=%ld inventory redirect=%s",
            branch,
            inventoryXml);
        Log(line);
        return;
    }

    constexpr const char* prefix = "UTOPIAN_QUICKSLOT_NATIVE_HANDS ";
    const char* request = std::strstr(message, prefix);
    if (!request) {
        return;
    }

    char* end = nullptr;
    const long itemId = std::strtol(request + std::strlen(prefix), &end, 10);
    if (end == request + std::strlen(prefix)) {
        Log("quickslot native hands request parse failed");
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
    Log(line);
}

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

bool IsInventoryWindowName(const char* xml)
{
    if (!xml) {
        return false;
    }
    return std::strcmp(xml, "inventory.xml") == 0 ||
        std::strcmp(xml, "container.xml") == 0 ||
        std::strcmp(xml, "corpse.xml") == 0 ||
        std::strcmp(xml, CUSTOM_INVENTORY_XML) == 0 ||
        std::strcmp(xml, CUSTOM_INVENTORY_XML_1920) == 0 ||
        std::strcmp(xml, CUSTOM_CLARA_INVENTORY_XML) == 0 ||
        std::strcmp(xml, CUSTOM_CLARA_INVENTORY_XML_1920) == 0 ||
        std::strcmp(xml, CUSTOM_LOOT_XML) == 0 ||
        std::strcmp(xml, CUSTOM_LOOT_XML_1920) == 0 ||
        std::strcmp(xml, CUSTOM_CORPSE_XML) == 0 ||
        std::strcmp(xml, CUSTOM_CORPSE_XML_1920) == 0;
}

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

std::string GetInputConfigPath(HMODULE module)
{
    char path[MAX_PATH] = {};
    const DWORD length = ::GetModuleFileNameA(module, path, MAX_PATH);
    if (length == 0 || length >= MAX_PATH) {
        return "data\\init.cfg";
    }

    std::string result(path, length);
    const std::string::size_type separator = result.find_last_of("\\/");
    if (separator == std::string::npos) {
        return "data\\init.cfg";
    }
    result.resize(separator + 1);
    result += "..\\..\\..\\data\\init.cfg";

    char normalized[MAX_PATH] = {};
    const DWORD normalizedLength = ::GetFullPathNameA(
        result.c_str(), MAX_PATH, normalized, nullptr);
    if (normalizedLength > 0 && normalizedLength < MAX_PATH) {
        return std::string(normalized, normalizedLength);
    }
    return result;
}

std::string LowerAscii(std::string value)
{
    std::transform(
        value.begin(),
        value.end(),
        value.begin(),
        [](unsigned char character) {
            return static_cast<char>(std::tolower(character));
        });
    return value;
}

DWORD ResolveVirtualKeyName(const std::string& rawName)
{
    const std::string name = LowerAscii(rawName);
    if (name.size() == 1) {
        const SHORT mapped = ::VkKeyScanA(name[0]);
        if (mapped != -1) {
            return static_cast<DWORD>(mapped & 0xff);
        }
    }

    if (name.size() >= 2 && name[0] == 'f') {
        const int number = std::atoi(name.c_str() + 1);
        if (number >= 1 && number <= 24) {
            return VK_F1 + static_cast<DWORD>(number - 1);
        }
    }

    struct NamedKey {
        const char* name;
        DWORD virtualKey;
    };
    static constexpr NamedKey namedKeys[] = {
        { "tab", VK_TAB }, { "space", VK_SPACE },
        { "escape", VK_ESCAPE }, { "esc", VK_ESCAPE },
        { "enter", VK_RETURN }, { "return", VK_RETURN },
        { "backspace", VK_BACK }, { "delete", VK_DELETE },
        { "insert", VK_INSERT }, { "home", VK_HOME },
        { "end", VK_END }, { "pageup", VK_PRIOR },
        { "pagedown", VK_NEXT }, { "up", VK_UP },
        { "down", VK_DOWN }, { "left", VK_LEFT },
        { "right", VK_RIGHT }, { "lctrl", VK_LCONTROL },
        { "rctrl", VK_RCONTROL }, { "lshift", VK_LSHIFT },
        { "rshift", VK_RSHIFT }, { "lalt", VK_LMENU },
        { "ralt", VK_RMENU }, { "lbutton", VK_LBUTTON },
        { "rbutton", VK_RBUTTON }, { "mbutton", VK_MBUTTON },
        { "xbutton1", VK_XBUTTON1 }, { "xbutton2", VK_XBUTTON2 }
    };
    for (const NamedKey& key : namedKeys) {
        if (name == key.name) {
            return key.virtualKey;
        }
    }
    return 0;
}

DWORD ReadHandCombatKey()
{
    std::ifstream input(g_inputConfigPath);
    if (!input) {
        return 'X';
    }

    DWORD result = 'X';
    std::string line;
    while (std::getline(input, line)) {
        std::istringstream tokens(line);
        std::string command;
        std::string key;
        std::string action;
        tokens >> command >> key >> action;
        if (LowerAscii(command) != "bind" ||
            LowerAscii(action) != "handcombat") {
            continue;
        }
        const DWORD resolved = ResolveVirtualKeyName(key);
        if (resolved != 0) {
            result = resolved;
        }
    }
    return result;
}

void RefreshHandCombatKey(bool forceLog)
{
    const DWORD resolved = ReadHandCombatKey();
    const DWORD previous = g_handCombatKey.exchange(resolved);
    if (!forceLog && previous == resolved) {
        return;
    }
    char line[160] = {};
    std::snprintf(
        line,
        sizeof(line),
        "handcombat binding key=%lu config=%s",
        static_cast<unsigned long>(resolved),
        g_inputConfigPath.c_str());
    Log(line);
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

void LogEmptySlotOpacity()
{
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
    const bool clara = g_playerBranch.load(std::memory_order_acquire) == 2;
    if (width == 1920 && height == 1080) {
        return clara ? CUSTOM_CLARA_INVENTORY_XML_1920 : CUSTOM_INVENTORY_XML_1920;
    }
    return clara ? CUSTOM_CLARA_INVENTORY_XML : CUSTOM_INVENTORY_XML;
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
        // Do not publish console variables while the game is loading a world.
        // OynonExecCommand invokes the engine directly and is only safe here
        // while the inventory UI is active.
        g_publishedPageHover = 0;
    }
    Log(opened ? "inventory overlay opened" : "inventory overlay closed");
}

void __stdcall OnUIWindowPrepare(const char* xml, void*)
{
    if (IsInventoryWindowName(xml)) {
        // Close the small interval between CreateWnd and the inventory-state
        // callback so a digit used to assign a slot cannot also activate it.
        g_inventoryOpen.store(true);
    }

    const DWORD* priorityIds = nullptr;
    DWORD priorityIdCount = 0;
    if (xml && std::strcmp(xml, "apparatus.xml") == 0) {
        priorityIds = APPARATUS_PRIORITY_IDS.data();
        priorityIdCount = static_cast<DWORD>(APPARATUS_PRIORITY_IDS.size());
    }
    else if (xml && std::strcmp(xml, "dapparatus.xml") == 0) {
        priorityIds = DOCTOR_APPARATUS_PRIORITY_IDS.data();
        priorityIdCount = static_cast<DWORD>(DOCTOR_APPARATUS_PRIORITY_IDS.size());
    }
    else if (xml && std::strcmp(xml, "microscope.xml") == 0) {
        priorityIds = MICROSCOPE_PRIORITY_IDS.data();
        priorityIdCount = static_cast<DWORD>(MICROSCOPE_PRIORITY_IDS.size());
    }
    if (!priorityIds) {
        return;
    }

    std::array<DWORD, PLAYER_INVENTORY_MAPPING_CAPACITY> oldToNew = {};
    std::array<DWORD, PLAYER_CATEGORY_COUNT> categoryCounts = {};
    BOOL changed = FALSE;
    if (!OynonStablePrioritizePlayerInventory(
            priorityIds,
            priorityIdCount,
            oldToNew.data(),
            static_cast<DWORD>(oldToNew.size()),
            categoryCounts.data(),
            static_cast<DWORD>(categoryCounts.size()),
            &changed)) {
        Log("special inventory synchronous priority unavailable; opening vanilla window unchanged");
        return;
    }

    if (!changed) {
        char line[112] = {};
        std::snprintf(
            line,
            sizeof(line),
            "special inventory synchronous priority unchanged xml=%s",
            xml);
        Log(line);
        return;
    }

    DWORD changedCategoryMask = 0;
    bool published = true;
    for (DWORD category = 0; category < PLAYER_CATEGORY_COUNT; ++category) {
        bool categoryChanged = false;
        const DWORD mappingBase = category * PLAYER_CATEGORY_MAPPING_STRIDE;
        for (DWORD oldIndex = 0; oldIndex < categoryCounts[category]; ++oldIndex) {
            if (oldToNew[mappingBase + oldIndex] != oldIndex) {
                categoryChanged = true;
                break;
            }
        }
        char command[128] = {};
        if (!categoryChanged) {
            std::snprintf(
                command,
                sizeof(command),
                "setvar utopian_special_inventory_count_%lu 0",
                static_cast<unsigned long>(category));
            published = OynonExecCommand(command) && published;
            continue;
        }

        changedCategoryMask |= 1u << category;
        std::snprintf(
            command,
            sizeof(command),
            "setvar utopian_special_inventory_count_%lu %lu",
            static_cast<unsigned long>(category),
            static_cast<unsigned long>(categoryCounts[category]));
        published = OynonExecCommand(command) && published;

        for (DWORD oldIndex = 0; oldIndex < categoryCounts[category]; ++oldIndex) {
            std::snprintf(
                command,
                sizeof(command),
                "setvar utopian_special_inventory_map_%lu_%lu %lu",
                static_cast<unsigned long>(category),
                static_cast<unsigned long>(oldIndex),
                static_cast<unsigned long>(oldToNew[mappingBase + oldIndex]));
            published = OynonExecCommand(command) && published;
        }
    }

    if (published) {
        char command[96] = {};
        std::snprintf(
            command,
            sizeof(command),
            "setvar utopian_special_inventory_remap_mask %lu",
            static_cast<unsigned long>(changedCategoryMask));
        published = OynonExecCommand(command) &&
            OynonExecCommand("setvar utopian_special_inventory_remap_request 1");
    }
    if (!published) {
        Log("special inventory physical priority succeeded but layout remap publish failed");
    }

    char line[128] = {};
    std::snprintf(
        line,
        sizeof(line),
        "special inventory synchronous priority complete xml=%s mask=%lu",
        xml,
        static_cast<unsigned long>(changedCategoryMask));
    Log(line);
}

void __stdcall OnKeyboardInput(DWORD virtualKey, BOOL pressed, void*)
{
    if (!pressed) {
        return;
    }

    const int quickslot = GetQuickslotNumber(virtualKey);
    const bool inventoryOpen = g_inventoryOpen.load();
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
        Log(ignoredLine);
        return;
    }

    if (virtualKey == g_handCombatKey.load()) {
        if (!OynonExecCommand("setvar utopian_handcombat_request 1")) {
            Log("handcombat input command failed");
        }
        else {
            Log("handcombat request published");
        }
    }

    if (quickslot == 0) {
        return;
    }

    const bool daychangeBusy =
        OynonUIDaychangeIsVanillaActive(::GetTickCount()) != FALSE;
    char command[64] = {};
    std::snprintf(
        command,
        sizeof(command),
        "setvar utopian_quickslot_request %d",
        quickslot);
    if (!OynonExecCommand(command)) {
        Log("quick-slot input command failed");
        return;
    }

    char publishedLine[128] = {};
    std::snprintf(
        publishedLine,
        sizeof(publishedLine),
        "quick-slot request published slot=%d daychangeBusy=%d",
        quickslot,
        daychangeBusy ? 1 : 0);
    Log(publishedLine);
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
            return HitPagePair(cursor, 1082, 780, 1, 2);
        }
        if (width == 1024 && height == 768) {
            return HitPagePair(cursor, 626, 616, 1, 2);
        }
        if (width < 1000) {
            return HitPagePair(cursor, 467, 465, 1, 2);
        }
        return 0;
    }

    if (kind == OYNON_INVENTORY_OVERLAY_CONTAINER ||
        kind == OYNON_INVENTORY_OVERLAY_CORPSE) {
        int target = 0;
        if (width == 1920 && height == 1080) {
            target = HitPagePair(cursor, 1082, 780, 1, 2);
            if (target == 0) {
                target = HitPagePair(cursor, 528, 625, 5, 6);
            }
            return target;
        }
        if (width == 1280 && height == 1024) {
            return HitPagePair(cursor, 198, 434, 5, 6);
        }
        if (width == 1024 && height == 768) {
            target = HitPagePair(cursor, 626, 616, 1, 2);
            if (target == 0) {
                target = HitPagePair(cursor, 149, 506, 5, 6);
            }
            return target;
        }
        target = HitPagePair(cursor, 467, 465, 1, 2);
        if (target == 0) {
            target = HitPagePair(cursor, 107, 453, 5, 6);
        }
        return target;
    }

    return 0;
}

void PollPageHover()
{
    if (!g_inventoryOpen.load()) {
        g_publishedPageHover = 0;
        return;
    }

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
    g_inputConfigPath = GetInputConfigPath(module);
    RefreshHandCombatKey(true);
    g_emptySlotOpacity = ReadEmptySlotOpacity(module);
    OynonDebugConfigureLauncherChannel(DEBUG_CHANNEL, FALSE);
    Log("UTOPIAN_INVENTORY_NATIVE_VERSION 2026.08.01-early-load-safe-clara-3");
    if (!WriteEmptySlotTexture(module)) {
        Log("failed to create empty slot opacity texture");
    }

    if (!OynonSetPlayerBootstrapEffect("utopian_inventory_bootstrap.bin")) {
        Log("UtopianInventory failed to configure inventory bootstrap effect");
    }
    if (!OynonSetPlayerInventoryCategoryCapacity(64)) {
        Log("UtopianInventory failed to configure player category capacity");
    }
    if (!OynonSetWorldContainerCapacity(128)) {
        Log("UtopianInventory failed to configure world container capacity");
    }
    const DWORD hookFlags =
        OYNON_HOOK_PLAYER_EFFECT_CALLBACK |
        OYNON_HOOK_CONSOLE_READ |
        OYNON_HOOK_CONSOLE_EXECUTE |
        OYNON_HOOK_PLAYER_INVENTORY_CAPACITY |
        OYNON_HOOK_UI_INVENTORY_STATE |
        OYNON_HOOK_UI_INVENTORY_REDIRECT |
        OYNON_HOOK_UI_WINDOW_PREPARE;

    if (!OynonInitializeHooksWhenReady(hookFlags)) {
        Log("UtopianInventory failed to initialize OynonTools hooks");
        return 0;
    }
    if (!OynonRegisterConsoleMessageCallback(&OnConsoleMessage, nullptr)) {
        Log("UtopianInventory failed to register console message callback");
    }

    const char* inventoryXml = ResolveInventoryXml();
    const char* lootXml = ResolveLootXml();
    const char* corpseXml = ResolveCorpseXml();
    OynonUIInventorySetRedirect(inventoryXml);
    OynonUILootSetRedirects(lootXml, corpseXml);
    OynonRegisterInventoryStateCallback(&OnInventoryStateChanged, nullptr);
    if (!OynonRegisterKeyboardCallback(&OnKeyboardInput, nullptr)) {
        Log("UtopianInventory failed to register keyboard callback");
    }
    if (!OynonRegisterUIWindowPrepareCallback(&OnUIWindowPrepare, nullptr)) {
        Log("UtopianInventory failed to register pre-window callback");
    }
    LogEmptySlotOpacity();
    Log(inventoryXml == CUSTOM_INVENTORY_XML_1920
        ? "UtopianInventory initialized (centered 1920x1080 layout)"
        : "UtopianInventory initialized (standard layout)");
    Log(lootXml == CUSTOM_LOOT_XML_1920
        ? "UtopianInventory loot redirect initialized (centered 1920x1080 layout)"
        : "UtopianInventory loot redirect initialized (standard layout)");
    Log("UtopianInventory vanilla special inventory physical priority initialized");

    DWORD lastBindingRefresh = ::GetTickCount();
    while (true) {
        OynonUIPoll();
        OynonUIInventoryPoll();
        OynonKeyboardPoll();
        PollPageHover();
        const DWORD now = ::GetTickCount();
        if (now - lastBindingRefresh >= 1000) {
            RefreshHandCombatKey(false);
            lastBindingRefresh = now;
        }
        ::Sleep(16);
    }
}
