#include "diagnostics.h"

#include "OynonToolsApi.h"

#include <algorithm>
#include <cctype>
#include <cstdio>
#include <cstring>

namespace inventory_overhaul
{
namespace
{
constexpr const char* DEBUG_CHANNEL = "InventoryOverhaul";

std::string LowerAscii(std::string value)
{
    std::transform(
        value.begin(), value.end(), value.begin(),
        [](unsigned char character) {
            return static_cast<char>(std::tolower(character));
        });
    return value;
}

bool ContainsCaseInsensitive(const char* text, const char* needle)
{
    if (!text || !needle) {
        return false;
    }
    const std::string haystack = LowerAscii(text);
    const std::string lowercaseNeedle = LowerAscii(needle);
    return haystack.find(lowercaseNeedle) != std::string::npos;
}

bool IsImportantLogMessage(const char* message)
{
    // The script API has no severity-aware logging primitive. Keep messages
    // that clearly report failures or unsafe degraded states visible even when
    // verbose logging is disabled.
    static constexpr const char* importantTerms[] = {
        "error",
        "fatal",
        "warning",
        "failed",
        "failure",
        "unavailable",
        "rejected",
        "queue full",
        "not found",
        "could not",
        "unable",
        "corrupt",
        "before player observation"
    };
    for (const char* term : importantTerms) {
        if (ContainsCaseInsensitive(message, term)) {
            return true;
        }
    }
    return false;
}

bool IsInventoryOverhaulConsoleMessage(const char* message)
{
    return ContainsCaseInsensitive(message, "inv_overhaul");
}

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
}

Diagnostics::Diagnostics(bool debugEnabled, const std::string& debugLogPath)
    : debugEnabled_(debugEnabled)
{
    OynonDebugConfigureChannel(
        DEBUG_CHANNEL,
        TRUE,
        debugLogPath.c_str(),
        nullptr);
}

bool Diagnostics::DebugEnabled() const
{
    return debugEnabled_;
}

void Diagnostics::Log(const char* line) const
{
    if (!debugEnabled_ && !IsImportantLogMessage(line)) {
        return;
    }
    OynonDebugLog(DEBUG_CHANNEL, line);
}

bool Diagnostics::RegisterConsoleMessageFilter()
{
    return OynonRegisterConsoleMessageFilter(&ConsoleMessageFilter, this) != FALSE;
}

BOOL __stdcall Diagnostics::ConsoleMessageFilter(const char* message, void* userData)
{
    const auto& diagnostics = *static_cast<Diagnostics*>(userData);
    if (diagnostics.debugEnabled_ || !IsInventoryOverhaulConsoleMessage(message)) {
        return FALSE;
    }
    return IsImportantLogMessage(message) ? FALSE : TRUE;
}

DWORD Diagnostics::InventoryPerformanceElapsed() const
{
    if (!inventoryPerformance_.active) {
        return 0;
    }
    const ULONGLONG now = PerformanceNowMicroseconds();
    const ULONGLONG elapsed = now > inventoryPerformance_.startedMicroseconds
        ? now - inventoryPerformance_.startedMicroseconds
        : 0;
    return elapsed > MAXDWORD ? MAXDWORD : static_cast<DWORD>(elapsed);
}

bool Diagnostics::HandleCacheConsoleMessage(const char* message) const
{
    constexpr const char* cachePrefix = "INV_OVERHAUL_UI_CACHE_";
    const char* cacheMessage = message ? std::strstr(message, cachePrefix) : nullptr;
    if (!cacheMessage) {
        return false;
    }
    if (debugEnabled_) {
        Log(cacheMessage);
    }
    return true;
}

bool Diagnostics::HandlePerformanceConsoleMessage(const char* message, int playerBranch)
{
    constexpr const char* performanceStepPrefix = "INV_OVERHAUL_PERF_STEP ";
    const char* performanceStepMessage = std::strstr(message, performanceStepPrefix);
    if (performanceStepMessage) {
        RecordInventoryPerformanceStep(
            performanceStepMessage + std::strlen(performanceStepPrefix));
        return true;
    }

    constexpr const char* performanceIconPrefix = "INV_OVERHAUL_PERF_ICON ";
    const char* performanceIconMessage = std::strstr(message, performanceIconPrefix);
    if (performanceIconMessage) {
        if (debugEnabled_ && inventoryPerformance_.active) {
            char line[768] = {};
            std::snprintf(
                line,
                sizeof(line),
                "inventory perf icon elapsed_us=%lu %s",
                static_cast<unsigned long>(InventoryPerformanceElapsed()),
                performanceIconMessage + std::strlen(performanceIconPrefix));
            Log(line);
        }
        return true;
    }

    constexpr const char* performancePrefix = "INV_OVERHAUL_PERF_PHASE ";
    const char* performanceMessage = std::strstr(message, performancePrefix);
    if (!performanceMessage) {
        return false;
    }
    if (!debugEnabled_ || !inventoryPerformance_.active) {
        return true;
    }

    const char* phase = performanceMessage + std::strlen(performancePrefix);
    const DWORD elapsed = InventoryPerformanceElapsed();
    if (std::strncmp(phase, "child_ready", 11) == 0) {
        inventoryPerformance_.childReadyMicroseconds = elapsed;
    }
    else if (std::strncmp(phase, "layout_ready", 12) == 0) {
        inventoryPerformance_.layoutReadyMicroseconds = elapsed;
    }
    else if (std::strncmp(phase, "first_item", 10) == 0) {
        inventoryPerformance_.firstItemMicroseconds = elapsed;
    }
    else if (std::strncmp(phase, "complete", 8) == 0) {
        int stacks = 0;
        int equipment = 0;
        std::sscanf(
            phase,
            "complete stacks=%d equipment=%d",
            &stacks,
            &equipment);
        char line[512] = {};
        std::snprintf(
            line,
            sizeof(line),
            "inventory perf open=%lu mode=%s branch=%d original=%s resolved=%s stacks=%d equipment=%d prepare_us=%lu create_us=%lu child_us=%lu layout_us=%lu first_item_us=%lu complete_us=%lu",
            inventoryPerformance_.sequence,
            inventoryPerformance_.sequence == 1 ? "cold" : "warm",
            playerBranch,
            inventoryPerformance_.originalXml.c_str(),
            inventoryPerformance_.resolvedXml.c_str(),
            stacks,
            equipment,
            static_cast<unsigned long>(inventoryPerformance_.prepareMicroseconds),
            static_cast<unsigned long>(inventoryPerformance_.createWndMicroseconds),
            static_cast<unsigned long>(inventoryPerformance_.childReadyMicroseconds),
            static_cast<unsigned long>(inventoryPerformance_.layoutReadyMicroseconds),
            static_cast<unsigned long>(inventoryPerformance_.firstItemMicroseconds),
            static_cast<unsigned long>(elapsed));
        FlushInventoryPerformanceSteps();
        Log(line);
        inventoryPerformance_.active = false;
    }
    return true;
}

void Diagnostics::BeginInventoryOpen(const char* originalXml)
{
    if (!debugEnabled_) {
        return;
    }
    inventoryPerformance_ = {};
    inventoryPerformance_.active = true;
    inventoryOpenSequence_ += 1;
    inventoryPerformance_.sequence = inventoryOpenSequence_;
    inventoryPerformance_.startedMicroseconds = PerformanceNowMicroseconds();
    inventoryPerformance_.originalXml = originalXml ? originalXml : "";
}

void Diagnostics::RecordInventoryPerformanceStep(const char* step)
{
    if (!debugEnabled_ || !inventoryPerformance_.active || !step) {
        return;
    }
    const DWORD elapsed = InventoryPerformanceElapsed();
    const DWORD delta = elapsed >= inventoryPerformance_.lastStepMicroseconds
        ? elapsed - inventoryPerformance_.lastStepMicroseconds
        : 0;
    char sample[256] = {};
    std::snprintf(
        sample,
        sizeof(sample),
        "%s@%lu(+%lu)",
        step,
        static_cast<unsigned long>(elapsed),
        static_cast<unsigned long>(delta));
    if (!inventoryPerformance_.steps.empty()) {
        inventoryPerformance_.steps += " | ";
    }
    inventoryPerformance_.steps += sample;
    inventoryPerformance_.lastStepMicroseconds = elapsed;
}

void Diagnostics::FlushInventoryPerformanceSteps() const
{
    if (inventoryPerformance_.steps.empty()) {
        return;
    }
    char prefix[64] = {};
    std::snprintf(
        prefix,
        sizeof(prefix),
        "inventory perf steps open=%lu ",
        inventoryPerformance_.sequence);
    // OynonDebugLog has a 4096-byte buffer (including its own prefix). Keep
    // complete samples below that limit so late slot timings are not lost.
    constexpr std::size_t maxChunkSize = 3000;
    const std::string& steps = inventoryPerformance_.steps;
    std::size_t begin = 0;
    while (begin < steps.size()) {
        std::size_t end = (std::min)(begin + maxChunkSize, steps.size());
        if (end < steps.size()) {
            const std::size_t separator = steps.rfind(" | ", end);
            if (separator != std::string::npos && separator > begin) {
                end = separator;
            }
        }
        const std::string line = std::string(prefix) + steps.substr(begin, end - begin);
        Log(line.c_str());
        begin = end;
        if (steps.compare(begin, 3, " | ") == 0) {
            begin += 3;
        }
    }
}

void Diagnostics::RecordInventoryWindowCreated(
    const char* originalXml,
    const char* resolvedXml,
    BOOL succeeded,
    DWORD elapsedMicroseconds)
{
    if (!debugEnabled_ || !inventoryPerformance_.active) {
        return;
    }

    inventoryPerformance_.createWndMicroseconds = elapsedMicroseconds;
    const DWORD totalElapsed = InventoryPerformanceElapsed();
    inventoryPerformance_.prepareMicroseconds =
        totalElapsed >= elapsedMicroseconds
        ? totalElapsed - elapsedMicroseconds
        : 0;
    inventoryPerformance_.originalXml = originalXml ? originalXml : "";
    inventoryPerformance_.resolvedXml = resolvedXml ? resolvedXml : "";
    RecordInventoryPerformanceStep("create_window_end");
    if (!succeeded) {
        char line[256] = {};
        std::snprintf(
            line,
            sizeof(line),
            "inventory perf create failed original=%s resolved=%s create_us=%lu",
            inventoryPerformance_.originalXml.c_str(),
            inventoryPerformance_.resolvedXml.c_str(),
            static_cast<unsigned long>(elapsedMicroseconds));
        FlushInventoryPerformanceSteps();
        Log(line);
        inventoryPerformance_.active = false;
    }
}
}
