#include "ui_bridge.h"

#include "diagnostics.h"
#include "runtime_state.h"
#include "ui_layout.h"

#include "OynonToolsApi.h"

#include <array>
#include <cstdio>
#include <cstring>

namespace inventory_overhaul
{
namespace
{
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
}

UiBridge::UiBridge(RuntimeState& state, Diagnostics& diagnostics)
    : state_(state), diagnostics_(diagnostics)
{
}

UiRedirects UiBridge::ConfigureRedirects()
{
    UiRedirects redirects;
    redirects.inventoryXml = ResolveInventoryXml(
        state_.playerBranch.load(std::memory_order_acquire));
    redirects.lootXml = ResolveLootXml();
    redirects.corpseXml = ResolveCorpseXml();
    OynonUIInventorySetRedirect(redirects.inventoryXml);
    OynonUILootSetRedirects(redirects.lootXml, redirects.corpseXml);
    return redirects;
}

void UiBridge::RegisterInventoryStateCallback()
{
    OynonRegisterInventoryStateCallback(&InventoryStateChanged, this);
}

bool UiBridge::RegisterWindowPrepareCallback()
{
    return OynonRegisterUIWindowPrepareCallback(&UIWindowPrepare, this) != FALSE;
}

bool UiBridge::RegisterWindowCreatedCallback()
{
    return OynonRegisterUIWindowCreatedCallback(&UIWindowCreated, this) != FALSE;
}

void __stdcall UiBridge::InventoryStateChanged(BOOL opened, void* userData)
{
    static_cast<UiBridge*>(userData)->OnInventoryStateChanged(opened);
}

void __stdcall UiBridge::UIWindowPrepare(const char* xml, void* userData)
{
    static_cast<UiBridge*>(userData)->OnUIWindowPrepare(xml);
}

void __stdcall UiBridge::UIWindowCreated(
    const char* originalXml,
    const char* resolvedXml,
    BOOL succeeded,
    DWORD elapsedMicroseconds,
    void* userData)
{
    static_cast<UiBridge*>(userData)->OnUIWindowCreated(
        originalXml,
        resolvedXml,
        succeeded,
        elapsedMicroseconds);
}

void UiBridge::OnInventoryStateChanged(BOOL opened)
{
    state_.inventoryOpen.store(opened != FALSE);
    if (opened) {
        // A deferred gameplay activation must never fire after the player has
        // entered the assignment UI.
        state_.pendingQuickslot.store(0, std::memory_order_release);
    }
    if (!opened) {
        // Do not publish console variables while the game is loading a world.
        // OynonExecCommand invokes the engine directly and is only safe here
        // while the inventory UI is active.
        publishedPageHover_ = 0;
    }
    diagnostics_.Log(opened ? "inventory overlay opened" : "inventory overlay closed");
}

void UiBridge::OnUIWindowPrepare(const char* xml)
{
    const bool playerInventoryWindow = IsPlayerInventoryWindowName(xml);
    if (playerInventoryWindow) {
        diagnostics_.BeginInventoryOpen(xml);
        diagnostics_.RecordInventoryPerformanceStep("prepare_begin");
    }
    if (PrepareLootWindow(xml)) {
        return;
    }
    PreparePlayerWindow(xml);

    if (IsInventoryWindowName(xml)) {
        // Close the small interval between CreateWnd and the inventory-state
        // callback so a digit used to assign a slot cannot also activate it.
        state_.inventoryOpen.store(true);
    }

    if (IsPlayerInventoryWindowName(xml)) {
        // Some branches expose their first playable inventory after the
        // day-change callback ran against a still-transitional player. The
        // inventory itself is a stronger gameplay-ready signal, so repeat the
        // confirmation here and let OynonTools attach the persistent guard and
        // quickslot effects to the current player object.
        if (OynonConfirmPlayerBootstrapReady()) {
            diagnostics_.Log("player bootstrap gameplay readiness confirmed by inventory window");
        }
        // Reassert at every open: loading a save can restore engine variables
        // after playerstat preparation. A native cached-success flag cannot
        // prove that the script-visible value survived that transition.
        if (!EnsureDebugStatePublished()) {
            diagnostics_.Log("InventoryOverhaul failed to publish debug logging state");
        }
    }

    PrepareSpecialInventory(xml);
    if (playerInventoryWindow) {
        diagnostics_.RecordInventoryPerformanceStep("prepare_end");
    }
}

bool UiBridge::PrepareLootWindow(const char* xml)
{
    // Do not execute console commands while the engine is constructing an
    // external-inventory override. Re-entering the loop-transition machinery
    // here can leave a static station active without its first UI update.
    // Corpse layouts carry an explicit child marker, while ordinary container
    // layouts intentionally do not, so no global kind variable is required.
    if (IsCorpseWindowName(xml)) {
        diagnostics_.Log("loot window kind selected corpse layout");
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
                    diagnostics_.Log(line);
                }
                else {
                    diagnostics_.Log("loot window corpse one-shot redirect failed");
                }
                return true;
            }

            char line[384] = {};
            std::snprintf(
                line,
                sizeof(line),
                "loot window kind selected container layout active_use=%s",
                activeUseScript);
            diagnostics_.Log(line);
        }
        else {
            diagnostics_.Log("loot window kind selected container layout active_use=<none>");
        }
    }
    return false;
}

void UiBridge::PreparePlayerWindow(const char* xml)
{
    if (xml && std::strcmp(xml, "playerstat.xml") == 0) {
        // playerstat is created before the first controllable inventory. By
        // confirming the already validated five-category player here, the
        // bootstrap script can publish the character branch before the first
        // inventory redirect is resolved.
        state_.quickslotsReady.store(false, std::memory_order_release);
        // A DLL survives save-to-save transitions, while the character branch
        // belongs to the newly loaded player. Never let Clara's specialized
        // layout leak into a Bachelor/Haruspex save while the fresh bootstrap
        // effect is still publishing its branch marker.
        state_.playerBranch.store(-1, std::memory_order_release);
        OynonUIInventorySetRedirect(ResolveInventoryXml(-1));
        OynonRearmPlayerBootstrapEffect();
        if (OynonConfirmPlayerBootstrapReady()) {
            diagnostics_.Log("player bootstrap gameplay readiness confirmed by playerstat window");
        }
        if (!EnsureDebugStatePublished()) {
            diagnostics_.Log("InventoryOverhaul failed to publish debug logging state");
        }
    }

    if (xml && std::strcmp(xml, "daychange.xml") == 0) {
        if (OynonConfirmPlayerBootstrapReady()) {
            diagnostics_.Log("player bootstrap gameplay readiness confirmed by daychange window");
        }
        else {
            diagnostics_.Log("player bootstrap daychange confirmation arrived before player observation");
        }
    }
}

bool UiBridge::EnsureDebugStatePublished()
{
    char debugCommand[64] = {};
    std::snprintf(
        debugCommand,
        sizeof(debugCommand),
        "setvar inv_overhaul_debug_enabled %d",
        diagnostics_.DebugEnabled() ? 1 : 0);
    return OynonExecCommandInUIWindowPrepare(debugCommand) != FALSE;
}

void UiBridge::PrepareSpecialInventory(const char* xml)
{
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
        diagnostics_.Log(
            "special inventory synchronous priority unavailable; opening vanilla window unchanged");
        return;
    }

    if (!changed) {
        char line[112] = {};
        std::snprintf(
            line,
            sizeof(line),
            "special inventory synchronous priority unchanged xml=%s",
            xml);
        diagnostics_.Log(line);
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
        diagnostics_.Log(
            "special inventory physical priority succeeded but layout remap publish failed");
    }

    char line[128] = {};
    std::snprintf(
        line,
        sizeof(line),
        "special inventory synchronous priority complete xml=%s mask=%lu",
        xml,
        static_cast<unsigned long>(changedCategoryMask));
    diagnostics_.Log(line);
}

void UiBridge::OnUIWindowCreated(
    const char* originalXml,
    const char* resolvedXml,
    BOOL succeeded,
    DWORD elapsedMicroseconds)
{
    if (!IsPlayerInventoryWindowName(originalXml)) {
        return;
    }
    diagnostics_.RecordInventoryWindowCreated(
        originalXml,
        resolvedXml,
        succeeded,
        elapsedMicroseconds);
}

int UiBridge::ResolvePageHoverTarget() const
{
    if (!state_.inventoryOpen.load()) {
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

void UiBridge::PollPageHover()
{
    if (!state_.inventoryOpen.load()) {
        publishedPageHover_ = 0;
        return;
    }

    const int hoverTarget = ResolvePageHoverTarget();
    if (hoverTarget == publishedPageHover_) {
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

    publishedPageHover_ = hoverTarget;
    char line[64] = {};
    std::snprintf(line, sizeof(line), "native page-hover target=%d", hoverTarget);
    diagnostics_.Log(line);
}
}
