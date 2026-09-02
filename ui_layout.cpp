#include "ui_layout.h"

#include "framework.h"

#include <cctype>
#include <cstring>

namespace inventory_overhaul
{
namespace
{
constexpr const char* CUSTOM_INVENTORY_XML = "inv_overhaul_inventory.xml";
constexpr const char* CUSTOM_INVENTORY_XML_1920 = "inv_overhaul_inventory_1920x1080.xml";
constexpr const char* CUSTOM_CLARA_INVENTORY_XML = "inv_overhaul_inventory_clara.xml";
constexpr const char* CUSTOM_CLARA_INVENTORY_XML_1920 = "inv_overhaul_inventory_clara_1920x1080.xml";
constexpr const char* CUSTOM_LOOT_XML = "inv_overhaul_container.xml";
constexpr const char* CUSTOM_LOOT_XML_1920 = "inv_overhaul_container_1920x1080.xml";
constexpr const char* CUSTOM_CORPSE_XML = "inv_overhaul_corpse.xml";
constexpr const char* CUSTOM_CORPSE_XML_1920 = "inv_overhaul_corpse_1920x1080.xml";

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

bool Is1920x1080()
{
    int width = 0;
    int height = 0;
    GetGameClientSize(width, height);
    return width == 1920 && height == 1080;
}
}

const char* ResolveInventoryXml(int playerBranch)
{
    const bool clara = playerBranch == 2;
    if (Is1920x1080()) {
        return clara ? CUSTOM_CLARA_INVENTORY_XML_1920 : CUSTOM_INVENTORY_XML_1920;
    }
    return clara ? CUSTOM_CLARA_INVENTORY_XML : CUSTOM_INVENTORY_XML;
}

const char* ResolveLootXml()
{
    return Is1920x1080() ? CUSTOM_LOOT_XML_1920 : CUSTOM_LOOT_XML;
}

const char* ResolveCorpseXml()
{
    return Is1920x1080() ? CUSTOM_CORPSE_XML_1920 : CUSTOM_CORPSE_XML;
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

bool IsCenteredInventoryXml(const char* xml)
{
    return xml && std::strcmp(xml, CUSTOM_INVENTORY_XML_1920) == 0;
}

bool IsCenteredLootXml(const char* xml)
{
    return xml && std::strcmp(xml, CUSTOM_LOOT_XML_1920) == 0;
}
}
