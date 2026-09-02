#pragma once

#include "framework.h"

namespace inventory_overhaul
{
class Diagnostics;
struct RuntimeState;

class ConsoleBridge
{
public:
    ConsoleBridge(RuntimeState& state, Diagnostics& diagnostics);

    bool RegisterMessageCallback();

private:
    static void __stdcall ConsoleMessage(const char* message, void* userData);
    void OnConsoleMessage(const char* message);

    RuntimeState& state_;
    Diagnostics& diagnostics_;
};
}
