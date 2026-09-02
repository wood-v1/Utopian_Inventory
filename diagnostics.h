#pragma once

#include "framework.h"

#include <string>

namespace inventory_overhaul
{
class Diagnostics
{
public:
    Diagnostics(bool debugEnabled, const std::string& debugLogPath);

    bool DebugEnabled() const;
    void Log(const char* line) const;
    bool RegisterConsoleMessageFilter();

    bool HandleCacheConsoleMessage(const char* message) const;
    bool HandlePerformanceConsoleMessage(const char* message, int playerBranch);
    void BeginInventoryOpen(const char* originalXml);
    void RecordInventoryWindowCreated(
        const char* originalXml,
        const char* resolvedXml,
        BOOL succeeded,
        DWORD elapsedMicroseconds);

private:
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

    static BOOL __stdcall ConsoleMessageFilter(const char* message, void* userData);

    DWORD InventoryPerformanceElapsed() const;

    bool debugEnabled_ = false;
    InventoryOpenPerformance inventoryPerformance_;
};
}
