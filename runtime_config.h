#pragma once

#include "framework.h"

#include <string>

namespace inventory_overhaul
{
struct RuntimeConfiguration
{
    std::string inputConfigPath;
    std::string debugLogPath;
    float emptySlotOpacity = 1.0f;
    bool debugEnabled = false;
};

RuntimeConfiguration LoadRuntimeConfiguration(HMODULE module);
DWORD ReadHandCombatKey(const std::string& inputConfigPath);
bool WriteEmptySlotTexture(HMODULE module, float opacity);
}
