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
constexpr const char* DEBUG_CHANNEL = "InventoryOverhaul";
constexpr const char* CUSTOM_INVENTORY_XML = "inv_overhaul_inventory.xml";
constexpr const char* CUSTOM_INVENTORY_XML_1920 = "inv_overhaul_inventory_1920x1080.xml";
constexpr const char* CUSTOM_CLARA_INVENTORY_XML = "inv_overhaul_inventory_clara.xml";
constexpr const char* CUSTOM_CLARA_INVENTORY_XML_1920 = "inv_overhaul_inventory_clara_1920x1080.xml";
constexpr const char* CUSTOM_LOOT_XML = "inv_overhaul_container.xml";
constexpr const char* CUSTOM_LOOT_XML_1920 = "inv_overhaul_container_1920x1080.xml";
constexpr const char* CUSTOM_CORPSE_XML = "inv_overhaul_corpse.xml";
constexpr const char* CUSTOM_CORPSE_XML_1920 = "inv_overhaul_corpse_1920x1080.xml";
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
std::atomic<int> g_playerBranch{ -1 };
std::atomic<int> g_pendingQuickslot{ 0 };
std::atomic<DWORD> g_lastQuickslotRequestTick{ 0 };
std::atomic<DWORD> g_handCombatKey{ 'X' };
std::atomic<bool> g_quickslotsReady{ false };
std::atomic<int> g_quickslotsGeneration{ 0 };
std::atomic<DWORD> g_runtimeTextureEpoch{ 1 };
int g_publishedPageHover = -1;
float g_emptySlotOpacity = 1.0f;
bool g_performanceDiagnostics = true;
std::string g_inputConfigPath;

struct InventoryOpenPerformance
{
    bool active = false;
    ULONGLONG startedMicroseconds = 0;
    DWORD createWndMicroseconds = 0;
    DWORD childReadyMicroseconds = 0;
    DWORD layoutReadyMicroseconds = 0;
    DWORD firstItemMicroseconds = 0;
    DWORD lastStepMicroseconds = 0;
    std::string originalXml;
    std::string resolvedXml;
};

InventoryOpenPerformance g_inventoryPerformance;

void Log(const char* line);
const char* ResolveInventoryXml();

ULONGLONG PerformanceNowMicroseconds()
{
    static LARGE_INTEGER frequency = []() {
        LARGE_INTEGER value = {};
        ::QueryPerformanceFrequency(&value);
        return value;
    }();
    LARGE_INTEGER counter = {};
    ::QueryPerformanceCounter(&counter);
    if (frequency.QuadPart <= 0) {
        return static_cast<ULONGLONG>(::GetTickCount64()) * 1000ull;
    }
    const ULONGLONG ticks = static_cast<ULONGLONG>(counter.QuadPart);
    const ULONGLONG ticksPerSecond =
        static_cast<ULONGLONG>(frequency.QuadPart);
    return (ticks / ticksPerSecond) * 1000000ull +
        ((ticks % ticksPerSecond) * 1000000ull) / ticksPerSecond;
}

DWORD InventoryPerformanceElapsed()
{
    if (!g_inventoryPerformance.active) {
        return 0;
    }
    const ULONGLONG now = PerformanceNowMicroseconds();
    const ULONGLONG elapsed = now > g_inventoryPerformance.startedMicroseconds
        ? now - g_inventoryPerformance.startedMicroseconds
        : 0;
    return elapsed > MAXDWORD ? MAXDWORD : static_cast<DWORD>(elapsed);
}

bool PublishQuickslotRequest(int quickslot, const char* source)
{
    constexpr DWORD QUICK_SLOT_COOLDOWN_MS = 200;
    const DWORD now = ::GetTickCount();
    DWORD last = g_lastQuickslotRequestTick.load(std::memory_order_acquire);
    while (last != 0 && now - last < QUICK_SLOT_COOLDOWN_MS) {
        return false;
    }
    while (!g_lastQuickslotRequestTick.compare_exchange_weak(
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
        // direct ApplyEffect call.  The engine's own `effect` command resolves
        // the current player by name, so it is a safe one-shot transport that
        // does not retain or dereference a player pointer across worlds.
        char command[96] = {};
        std::snprintf(
            command,
            sizeof(command),
            "effect player %s",
            effectName);
        if (!OynonExecCommand(command)) {
            g_lastQuickslotRequestTick.store(last, std::memory_order_release);
            Log("quick-slot input transports unavailable");
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
    Log(line);
    return true;
}

bool PublishRuntimeTextureEpoch()
{
    char command[96] = {};
    std::snprintf(
        command,
        sizeof(command),
        "setvar inv_overhaul_runtime_texture_epoch %lu",
        static_cast<unsigned long>(
            g_runtimeTextureEpoch.load(std::memory_order_acquire)));
    return OynonExecCommand(command) != FALSE;
}

void __stdcall OnConsoleMessage(const char* message, void*)
{
    if (!message) {
        return;
    }

    constexpr const char* cachePrefix = "INV_OVERHAUL_UI_CACHE_";
    const char* cacheMessage = std::strstr(message, cachePrefix);
    if (cacheMessage) {
        if (g_performanceDiagnostics) {
            Log(cacheMessage);
        }
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
            g_quickslotsGeneration.store(effectGeneration, std::memory_order_release);
            g_quickslotsReady.store(true, std::memory_order_release);
        }
        else if (std::strstr(effectLifecycleMessage, "quickslots stop")) {
            const int activeGeneration =
                g_quickslotsGeneration.load(std::memory_order_acquire);
            if (effectGeneration <= 0 || effectGeneration == activeGeneration) {
                g_quickslotsReady.store(false, std::memory_order_release);
            }
            else {
                char staleLine[144] = {};
                std::snprintf(
                    staleLine,
                    sizeof(staleLine),
                    "quickslots stale stop ignored generation=%d active=%d",
                    effectGeneration,
                    activeGeneration);
                Log(staleLine);
            }
        }
        Log(effectLifecycleMessage);
        return;
    }

    constexpr const char* handsDropPrefix = "inv_overhaul_drop_hands ";
    const char* handsDropMessage = std::strstr(message, handsDropPrefix);
    if (handsDropMessage) {
        Log(handsDropMessage);
        return;
    }

    constexpr const char* quickslotTracePrefix = "inv_overhaul_quickslot ";
    const char* quickslotTraceMessage = std::strstr(message, quickslotTracePrefix);
    if (quickslotTraceMessage) {
        Log(quickslotTraceMessage);
        return;
    }

    constexpr const char* performanceStepPrefix = "INV_OVERHAUL_PERF_STEP ";
    const char* performanceStepMessage = std::strstr(message, performanceStepPrefix);
    if (performanceStepMessage) {
        if (g_performanceDiagnostics && g_inventoryPerformance.active) {
            const DWORD elapsed = InventoryPerformanceElapsed();
            const DWORD delta = elapsed >= g_inventoryPerformance.lastStepMicroseconds
                ? elapsed - g_inventoryPerformance.lastStepMicroseconds
                : 0;
            char line[384] = {};
            std::snprintf(
                line,
                sizeof(line),
                "inventory perf step elapsed_us=%lu delta_us=%lu %s",
                static_cast<unsigned long>(elapsed),
                static_cast<unsigned long>(delta),
                performanceStepMessage + std::strlen(performanceStepPrefix));
            Log(line);
            g_inventoryPerformance.lastStepMicroseconds = elapsed;
        }
        return;
    }

    constexpr const char* performancePrefix = "INV_OVERHAUL_PERF_PHASE ";
    constexpr const char* performanceIconPrefix = "INV_OVERHAUL_PERF_ICON ";
    const char* performanceIconMessage = std::strstr(message, performanceIconPrefix);
    if (performanceIconMessage) {
        if (g_performanceDiagnostics && g_inventoryPerformance.active) {
            char line[768] = {};
            std::snprintf(
                line,
                sizeof(line),
                "inventory perf icon elapsed_us=%lu %s",
                static_cast<unsigned long>(InventoryPerformanceElapsed()),
                performanceIconMessage + std::strlen(performanceIconPrefix));
            Log(line);
        }
        return;
    }

    const char* performanceMessage = std::strstr(message, performancePrefix);
    if (performanceMessage) {
        if (!g_performanceDiagnostics || !g_inventoryPerformance.active) {
            return;
        }
        const char* phase = performanceMessage + std::strlen(performancePrefix);
        const DWORD elapsed = InventoryPerformanceElapsed();
        if (std::strncmp(phase, "child_ready", 11) == 0) {
            g_inventoryPerformance.childReadyMicroseconds = elapsed;
        }
        else if (std::strncmp(phase, "layout_ready", 12) == 0) {
            g_inventoryPerformance.layoutReadyMicroseconds = elapsed;
        }
        else if (std::strncmp(phase, "first_item", 10) == 0) {
            g_inventoryPerformance.firstItemMicroseconds = elapsed;
        }
        else if (std::strncmp(phase, "complete", 8) == 0) {
            int stacks = 0;
            int equipment = 0;
            int hits = 0;
            int misses = 0;
            int warmed = 0;
            int warmStart = 0;
            std::sscanf(
                phase,
                "complete stacks=%d equipment=%d hits=%d misses=%d warmed=%d warm_start=%d",
                &stacks,
                &equipment,
                &hits,
                &misses,
                &warmed,
                &warmStart);
            char line[512] = {};
            std::snprintf(
                line,
                sizeof(line),
                "inventory perf branch=%d original=%s resolved=%s stacks=%d equipment=%d cache_hits=%d cache_misses=%d warmed=%d warm_start=%d create_us=%lu child_us=%lu layout_us=%lu first_item_us=%lu complete_us=%lu",
                g_playerBranch.load(std::memory_order_acquire),
                g_inventoryPerformance.originalXml.c_str(),
                g_inventoryPerformance.resolvedXml.c_str(),
                stacks,
                equipment,
                hits,
                misses,
                warmed,
                warmStart,
                static_cast<unsigned long>(g_inventoryPerformance.createWndMicroseconds),
                static_cast<unsigned long>(g_inventoryPerformance.childReadyMicroseconds),
                static_cast<unsigned long>(g_inventoryPerformance.layoutReadyMicroseconds),
                static_cast<unsigned long>(g_inventoryPerformance.firstItemMicroseconds),
                static_cast<unsigned long>(elapsed));
            Log(line);
            g_inventoryPerformance.active = false;
        }
        return;
    }

    constexpr const char* branchPrefix = "INV_OVERHAUL_PLAYER_BRANCH ";
    const char* branchRequest = std::strstr(message, branchPrefix);
    if (branchRequest) {
        // The branch marker belongs to the freshly constructed bootstrap task.
        // Its quickslot effect is applied immediately afterwards; invalidate
        // readiness only for this narrow, real player-transition interval.
        g_quickslotsReady.store(false, std::memory_order_release);
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

    constexpr const char* prefix = "INV_OVERHAUL_QUICKSLOT_NATIVE_HANDS ";
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

bool IsPlayerInventoryWindowName(const char* xml)
{
    if (!xml) {
        return false;
    }
    return std::strcmp(xml, "inventory.xml") == 0 ||
        std::strcmp(xml, CUSTOM_INVENTORY_XML) == 0 ||
        std::strcmp(xml, CUSTOM_INVENTORY_XML_1920) == 0 ||
        std::strcmp(xml, CUSTOM_CLARA_INVENTORY_XML) == 0 ||
        std::strcmp(xml, CUSTOM_CLARA_INVENTORY_XML_1920) == 0;
}

bool IsCorpseWindowName(const char* xml)
{
    if (!xml) {
        return false;
    }
    return std::strcmp(xml, "corpse.xml") == 0 ||
        std::strcmp(xml, CUSTOM_CORPSE_XML) == 0 ||
        std::strcmp(xml, CUSTOM_CORPSE_XML_1920) == 0;
}

bool IsContainerWindowName(const char* xml)
{
    if (!xml) {
        return false;
    }
    return std::strcmp(xml, "container.xml") == 0 ||
        std::strcmp(xml, CUSTOM_LOOT_XML) == 0 ||
        std::strcmp(xml, CUSTOM_LOOT_XML_1920) == 0;
}

bool IsStorageContainerUseScript(const char* scriptName)
{
    if (!scriptName || scriptName[0] == '\0') {
        return false;
    }

    const char* baseName = scriptName;
    for (const char* cursor = scriptName; *cursor != '\0'; ++cursor) {
        if (*cursor == '/' || *cursor == '\\') {
            baseName = cursor + 1;
        }
    }

    // Vanilla world containers, including the dropped-item bag, use the
    // container*.bin family. Bachelor/Clara corpses open the same
    // container.xml from their NPC script (citizen_*.bin, etc.). Classifying
    // at this already validated player-use boundary avoids calling actor-only
    // methods on generic container actors, which caused the rubbish softlock.
    constexpr char prefix[] = "container";
    for (std::size_t index = 0; index + 1 < sizeof(prefix); ++index) {
        if (baseName[index] == '\0' ||
            std::tolower(static_cast<unsigned char>(baseName[index])) != prefix[index]) {
            return false;
        }
    }
    return true;
}

std::string GetIniPath(HMODULE module)
{
    char path[MAX_PATH] = {};
    const DWORD length = ::GetModuleFileNameA(module, path, MAX_PATH);
    if (length == 0 || length >= MAX_PATH) {
        return "InventoryOverhaul.ini";
    }

    std::string result(path, length);
    const std::string::size_type separator = result.find_last_of("\\/");
    if (separator == std::string::npos) {
        return "InventoryOverhaul.ini";
    }
    result.resize(separator + 1);
    result += "InventoryOverhaul.ini";
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
        value.begin(), value.end(), value.begin(),
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

    struct NamedKey { const char* name; DWORD virtualKey; };
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
    char line[192] = {};
    std::snprintf(
        line, sizeof(line), "handcombat binding key=%lu config=%s",
        static_cast<unsigned long>(resolved), g_inputConfigPath.c_str());
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

bool ReadPerformanceDiagnostics(HMODULE module)
{
    const std::string iniPath = GetIniPath(module);
    return ::GetPrivateProfileIntA(
        "Performance",
        "Diagnostics",
        1,
        iniPath.c_str()) != 0;
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
    // The opacity texture is generated as an uncompressed TGA at runtime.
    // Never write these bytes over the packaged DDS/TEX resource: doing so
    // makes UI.dll parse a TGA payload as a DDS texture and eventually corrupts
    // its texture cache when slot states are changed repeatedly.
    texturePath += L"..\\..\\..\\data\\Textures\\UI\\inv_overhaul_slot_empty_runtime.tga";

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
    if (opened) {
        // A deferred gameplay activation must never fire after the player has
        // entered the assignment UI.
        g_pendingQuickslot.store(0, std::memory_order_release);
    }
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
    // Do not execute console commands while the engine is constructing an
    // external-inventory override. Re-entering the loop-transition machinery
    // here can leave a static station active without its first UI update.
    // Corpse layouts carry an explicit child marker, while ordinary container
    // layouts intentionally do not, so no global kind variable is required.
    if (IsCorpseWindowName(xml)) {
        Log("loot window kind selected corpse layout");
    }
    else if (IsContainerWindowName(xml)) {
        char activeUseScript[260] = {};
        if (OynonGetActivePlayerUseScript(activeUseScript, sizeof(activeUseScript))) {
            const bool originalContainerWindow = std::strcmp(xml, "container.xml") == 0;
            const bool corpseOpenedAsContainer =
                originalContainerWindow && !IsStorageContainerUseScript(activeUseScript);
            if (corpseOpenedAsContainer) {
                if (OynonUISetOneShotWindowRedirect("container.xml", ResolveCorpseXml())) {
                    char line[384] = {};
                    std::snprintf(
                        line,
                        sizeof(line),
                        "loot window kind promoted to corpse layout active_use=%s",
                        activeUseScript);
                    Log(line);
                }
                else {
                    Log("loot window corpse one-shot redirect failed");
                }
                return;
            }

            char line[384] = {};
            std::snprintf(
                line,
                sizeof(line),
                "loot window kind selected container layout active_use=%s",
                activeUseScript);
            Log(line);
        }
        else {
            Log("loot window kind selected container layout active_use=<none>");
        }
    }

    if (xml && std::strcmp(xml, "playerstat.xml") == 0) {
        // playerstat is created before the first controllable inventory. By
        // confirming the already validated five-category player here, the
        // bootstrap script can publish the character branch before the first
        // inventory redirect is resolved.
        g_quickslotsReady.store(false, std::memory_order_release);
        OynonRearmPlayerBootstrapEffect();
        if (OynonConfirmPlayerBootstrapReady()) {
            Log("player bootstrap gameplay readiness confirmed by playerstat window");
        }
    }

    if (xml && std::strcmp(xml, "daychange.xml") == 0) {
        if (OynonConfirmPlayerBootstrapReady()) {
            Log("player bootstrap gameplay readiness confirmed by daychange window");
        }
        else {
            Log("player bootstrap daychange confirmation arrived before player observation");
        }
    }

    if (IsInventoryWindowName(xml)) {
        // Close the small interval between CreateWnd and the inventory-state
        // callback so a digit used to assign a slot cannot also activate it.
        g_inventoryOpen.store(true);
    }

    if (IsPlayerInventoryWindowName(xml)) {
        // Some branches expose their first playable inventory after the
        // day-change callback ran against a still-transitional player. The
        // inventory itself is a stronger gameplay-ready signal, so repeat the
        // confirmation here and let OynonTools attach the persistent guard and
        // quickslot effects to the current player object.
        if (OynonConfirmPlayerBootstrapReady()) {
            Log("player bootstrap gameplay readiness confirmed by inventory window");
        }
        // World loading resets console variables. Republish the process-local
        // epoch immediately before the root inventory script is created so
        // per-item warm markers survive window close/open but never leak into
        // a later game process through a save.
        if (!PublishRuntimeTextureEpoch()) {
            Log("InventoryOverhaul failed to republish runtime texture epoch");
        }
        char diagnosticsCommand[64] = {};
        std::snprintf(
            diagnosticsCommand,
            sizeof(diagnosticsCommand),
            "setvar inv_overhaul_perf_diagnostics %d",
            g_performanceDiagnostics ? 1 : 0);
        OynonExecCommand(diagnosticsCommand);
        if (g_performanceDiagnostics) {
            g_inventoryPerformance = {};
            g_inventoryPerformance.active = true;
            g_inventoryPerformance.startedMicroseconds = PerformanceNowMicroseconds();
            g_inventoryPerformance.originalXml = xml ? xml : "";
        }
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
                "setvar inv_overhaul_special_inventory_count_%lu 0",
                static_cast<unsigned long>(category));
            published = OynonExecCommand(command) && published;
            continue;
        }

        changedCategoryMask |= 1u << category;
        std::snprintf(
            command,
            sizeof(command),
            "setvar inv_overhaul_special_inventory_count_%lu %lu",
            static_cast<unsigned long>(category),
            static_cast<unsigned long>(categoryCounts[category]));
        published = OynonExecCommand(command) && published;

        for (DWORD oldIndex = 0; oldIndex < categoryCounts[category]; ++oldIndex) {
            std::snprintf(
                command,
                sizeof(command),
                "setvar inv_overhaul_special_inventory_map_%lu_%lu %lu",
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
            "setvar inv_overhaul_special_inventory_remap_mask %lu",
            static_cast<unsigned long>(changedCategoryMask));
        published = OynonExecCommand(command) &&
            OynonExecCommand("setvar inv_overhaul_special_inventory_remap_request 1");
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

void __stdcall OnUIWindowCreated(
    const char* originalXml,
    const char* resolvedXml,
    BOOL succeeded,
    DWORD elapsedMicroseconds,
    void*)
{
    if (!g_performanceDiagnostics ||
        !g_inventoryPerformance.active ||
        !IsPlayerInventoryWindowName(originalXml)) {
        return;
    }

    g_inventoryPerformance.createWndMicroseconds = elapsedMicroseconds;
    g_inventoryPerformance.originalXml = originalXml ? originalXml : "";
    g_inventoryPerformance.resolvedXml = resolvedXml ? resolvedXml : "";
    if (!succeeded) {
        char line[256] = {};
        std::snprintf(
            line,
            sizeof(line),
            "inventory perf create failed original=%s resolved=%s create_us=%lu",
            g_inventoryPerformance.originalXml.c_str(),
            g_inventoryPerformance.resolvedXml.c_str(),
            static_cast<unsigned long>(elapsedMicroseconds));
        Log(line);
        g_inventoryPerformance.active = false;
    }
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

    if (virtualKey == g_handCombatKey.load(std::memory_order_acquire)) {
        if (!OynonExecCommand("setvar inv_overhaul_handcombat_request 1")) {
            Log("handcombat input command failed");
        }
        else {
            Log("handcombat request published");
        }
    }

    if (quickslot == 0) {
        return;
    }

    if (!PublishQuickslotRequest(quickslot, "keyboard")) {
        g_pendingQuickslot.store(quickslot, std::memory_order_release);
        char queuedLine[112] = {};
        std::snprintf(
            queuedLine,
            sizeof(queuedLine),
            "quick-slot request deferred slot=%d until native player context is ready",
            quickslot);
        Log(queuedLine);
    }
}

BOOL __stdcall OnConsoleCommand(const char* command, void*)
{
    if (!command || g_inventoryOpen.load(std::memory_order_acquire) ||
        OynonUIInventoryGetOverlayKind() != OYNON_INVENTORY_OVERLAY_NONE ||
        g_playerBranch.load(std::memory_order_acquire) < 0) {
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
    Log("handcombat command observed; drop scheduled after vanilla holster");
    return FALSE;
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
            return HitPagePair(cursor, 1082, 826, 1, 2);
        }
        if (width == 1024 && height == 768) {
            return HitPagePair(cursor, 626, 632, 1, 2);
        }
        if (width < 1000) {
            return HitPagePair(cursor, 467, 481, 1, 2);
        }
        return 0;
    }

    if (kind == OYNON_INVENTORY_OVERLAY_CONTAINER ||
        kind == OYNON_INVENTORY_OVERLAY_CORPSE) {
        int target = 0;
        if (width == 1920 && height == 1080) {
            target = HitPagePair(cursor, 1082, 826, 1, 2);
            if (target == 0) {
                target = HitPagePair(cursor, 528, 625, 5, 6);
            }
            return target;
        }
        if (width == 1280 && height == 1024) {
            return HitPagePair(cursor, 198, 434, 5, 6);
        }
        if (width == 1024 && height == 768) {
            target = HitPagePair(cursor, 626, 632, 1, 2);
            if (target == 0) {
                target = HitPagePair(cursor, 149, 506, 5, 6);
            }
            return target;
        }
        target = HitPagePair(cursor, 467, 481, 1, 2);
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
        "setvar inv_overhaul_inventory_page_hover %d",
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
    g_emptySlotOpacity = ReadEmptySlotOpacity(module);
    g_performanceDiagnostics = ReadPerformanceDiagnostics(module);
    OynonDebugConfigureLauncherChannel(DEBUG_CHANNEL, FALSE);
    RefreshHandCombatKey(true);
    Log("INV_OVERHAUL_INVENTORY_NATIVE_VERSION 2026.08.16-quickslot-weapon-select-1");
    if (!WriteEmptySlotTexture(module)) {
        Log("failed to create empty slot opacity texture");
    }

    if (!OynonSetPlayerBootstrapEffect("inv_overhaul_inventory_bootstrap.bin")) {
        Log("InventoryOverhaul failed to configure inventory bootstrap effect");
    }
    if (!OynonSetPlayerInventoryCategoryCapacity(64)) {
        Log("InventoryOverhaul failed to configure player category capacity");
    }
    if (!OynonSetWorldContainerCapacity(128)) {
        Log("InventoryOverhaul failed to configure world container capacity");
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
        Log("InventoryOverhaul failed to initialize OynonTools hooks");
        return 0;
    }
    if (!OynonRegisterConsoleMessageCallback(&OnConsoleMessage, nullptr)) {
        Log("InventoryOverhaul failed to register console message callback");
    }
    if (!OynonRegisterConsoleCommandFilter(&OnConsoleCommand, nullptr)) {
        Log("InventoryOverhaul failed to register console command filter");
    }

    const char* inventoryXml = ResolveInventoryXml();
    const char* lootXml = ResolveLootXml();
    const char* corpseXml = ResolveCorpseXml();
    OynonUIInventorySetRedirect(inventoryXml);
    OynonUILootSetRedirects(lootXml, corpseXml);
    g_runtimeTextureEpoch.store(
        (::GetTickCount() & 0x3fffffffu) + 1u,
        std::memory_order_release);
    if (!PublishRuntimeTextureEpoch()) {
        Log("InventoryOverhaul failed to publish runtime texture epoch");
    }
    Log("InventoryOverhaul persistent UI texture cache disabled");
    OynonRegisterInventoryStateCallback(&OnInventoryStateChanged, nullptr);
    if (!OynonRegisterKeyboardCallback(&OnKeyboardInput, nullptr)) {
        Log("InventoryOverhaul failed to register keyboard callback");
    }
    if (!OynonRegisterUIWindowPrepareCallback(&OnUIWindowPrepare, nullptr)) {
        Log("InventoryOverhaul failed to register pre-window callback");
    }
    if (!OynonRegisterUIWindowCreatedCallback(&OnUIWindowCreated, nullptr)) {
        Log("InventoryOverhaul failed to register post-window callback");
    }
    Log(g_performanceDiagnostics
        ? "InventoryOverhaul performance diagnostics enabled"
        : "InventoryOverhaul performance diagnostics disabled");
    LogEmptySlotOpacity();
    Log(inventoryXml == CUSTOM_INVENTORY_XML_1920
        ? "InventoryOverhaul initialized (centered 1920x1080 layout)"
        : "InventoryOverhaul initialized (standard layout)");
    Log(lootXml == CUSTOM_LOOT_XML_1920
        ? "InventoryOverhaul loot redirect initialized (centered 1920x1080 layout)"
        : "InventoryOverhaul loot redirect initialized (standard layout)");
    Log("InventoryOverhaul vanilla special inventory physical priority initialized");

    DWORD lastBootstrapConfirmation = 0;
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
        if (now - lastBootstrapConfirmation >= 250) {
            // The module can be injected after playerstat.xml was created, so
            // a window callback alone cannot initialize the character branch
            // before the first inventory. The Oynon side still requires a
            // complete five-category inventory and makes repeated confirms a
            // no-op for an already bootstrapped player.
            OynonConfirmPlayerBootstrapReady();
            lastBootstrapConfirmation = now;
        }
        const int pendingQuickslot = g_pendingQuickslot.load(std::memory_order_acquire);
        if (pendingQuickslot > 0 &&
            !g_inventoryOpen.load(std::memory_order_acquire) &&
            OynonUIInventoryGetOverlayKind() == OYNON_INVENTORY_OVERLAY_NONE) {
            if (PublishQuickslotRequest(pendingQuickslot, "deferred")) {
                int expected = pendingQuickslot;
                g_pendingQuickslot.compare_exchange_strong(
                    expected,
                    0,
                    std::memory_order_acq_rel);
            }
        }
        ::Sleep(16);
    }
}
