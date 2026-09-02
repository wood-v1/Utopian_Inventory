#include "runtime_config.h"

#include <algorithm>
#include <cctype>
#include <cstdlib>
#include <fstream>
#include <sstream>
#include <vector>

namespace inventory_overhaul
{
namespace
{
std::string GetModuleSiblingPath(
    HMODULE module,
    const char* fileName,
    const char* fallback)
{
    char path[MAX_PATH] = {};
    const DWORD length = ::GetModuleFileNameA(module, path, MAX_PATH);
    if (length == 0 || length >= MAX_PATH) {
        return fallback;
    }

    std::string result(path, length);
    const std::string::size_type separator = result.find_last_of("\\/");
    if (separator == std::string::npos) {
        return fallback;
    }
    result.resize(separator + 1);
    result += fileName;
    return result;
}

std::string GetIniPath(HMODULE module)
{
    return GetModuleSiblingPath(
        module,
        "InventoryOverhaul.ini",
        "InventoryOverhaul.ini");
}

std::string GetDebugLogPath(HMODULE module)
{
    return GetModuleSiblingPath(module, "Debug.log", "Debug.log");
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

bool ReadDebugEnabled(HMODULE module)
{
    const std::string iniPath = GetIniPath(module);
    return ::GetPrivateProfileIntA(
        "Debug",
        "Enabled",
        0,
        iniPath.c_str()) != 0;
}
}

RuntimeConfiguration LoadRuntimeConfiguration(HMODULE module)
{
    RuntimeConfiguration configuration;
    configuration.inputConfigPath = GetInputConfigPath(module);
    configuration.emptySlotOpacity = ReadEmptySlotOpacity(module);
    configuration.debugEnabled = ReadDebugEnabled(module);
    configuration.debugLogPath = GetDebugLogPath(module);
    return configuration;
}

DWORD ReadHandCombatKey(const std::string& inputConfigPath)
{
    std::ifstream input(inputConfigPath);
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

bool WriteEmptySlotTexture(HMODULE module, float opacity)
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
    const unsigned char alpha = static_cast<unsigned char>(opacity * 255.0f + 0.5f);
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
}
