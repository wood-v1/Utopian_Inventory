#pragma once

#include "framework.h"

#include <atomic>

namespace inventory_overhaul
{
class Diagnostics;
struct RuntimeState;

struct UiRedirects
{
    const char* inventoryXml = nullptr;
    const char* lootXml = nullptr;
    const char* corpseXml = nullptr;
};

class UiBridge
{
public:
    UiBridge(RuntimeState& state, Diagnostics& diagnostics);

    UiRedirects ConfigureRedirects();
    bool InitializeRuntimeTextureEpoch();
    void RegisterInventoryStateCallback();
    bool RegisterWindowPrepareCallback();
    bool RegisterWindowCreatedCallback();
    void PollPageHover();

private:
    static void __stdcall InventoryStateChanged(BOOL opened, void* userData);
    static void __stdcall UIWindowPrepare(const char* xml, void* userData);
    static void __stdcall UIWindowCreated(
        const char* originalXml,
        const char* resolvedXml,
        BOOL succeeded,
        DWORD elapsedMicroseconds,
        void* userData);

    void OnInventoryStateChanged(BOOL opened);
    void OnUIWindowPrepare(const char* xml);
    void OnUIWindowCreated(
        const char* originalXml,
        const char* resolvedXml,
        BOOL succeeded,
        DWORD elapsedMicroseconds);
    bool PrepareLootWindow(const char* xml);
    void PreparePlayerWindow(const char* xml);
    void PrepareSpecialInventory(const char* xml);
    bool PublishRuntimeTextureEpoch() const;
    int ResolvePageHoverTarget() const;

    RuntimeState& state_;
    Diagnostics& diagnostics_;
    std::atomic<DWORD> runtimeTextureEpoch_{ 1 };
    int publishedPageHover_ = -1;
};
}
