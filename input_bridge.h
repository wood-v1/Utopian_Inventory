#pragma once

#include "framework.h"

#include <atomic>
#include <string>

namespace inventory_overhaul
{
class Diagnostics;
struct RuntimeState;

class InputBridge
{
public:
    InputBridge(
        RuntimeState& state,
        Diagnostics& diagnostics,
        std::string inputConfigPath);

    void RefreshHandCombatKey(bool forceLog);
    bool RegisterConsoleCommandFilter();
    bool RegisterKeyboardCallback();
    void BeginPolling();
    void RefreshBindingIfDue(DWORD now);
    void RetryPendingQuickslot();

private:
    static void __stdcall KeyboardInput(DWORD virtualKey, BOOL pressed, void* userData);
    static BOOL __stdcall ConsoleCommand(const char* command, void* userData);

    void OnKeyboardInput(DWORD virtualKey, BOOL pressed);
    BOOL OnConsoleCommand(const char* command);
    bool PublishQuickslotRequest(int quickslot, const char* source);
    bool ItemHotkeysBlocked();

    RuntimeState& state_;
    Diagnostics& diagnostics_;
    std::string inputConfigPath_;
    std::atomic<DWORD> lastQuickslotRequestTick_{ 0 };
    std::atomic<DWORD> handCombatKey_{ 'X' };
    DWORD lastBindingRefresh_ = 0;
    std::atomic<DWORD> dialogInputGeneration_{ 0 };
};
}
