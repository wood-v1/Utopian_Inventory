import "inv_overhaul_inventory_layout"
import "inv_overhaul_inventory_layout_runtime"
import "inv_overhaul_inventory_geometry"
import "inv_overhaul_inventory_protocol"
import "inv_overhaul_inventory_items"
import "inv_overhaul_inventory_quickslot_bindings"
import "inv_overhaul_inventory_equipment"
import "inv_overhaul_inventory_snapshot"
import "inv_overhaul_inventory_drag"
import "inv_overhaul_inventory_view"
import "inv_overhaul_inventory_paging"
import "inv_overhaul_inventory_tooltip"
import "inv_overhaul_inventory_drop"
import "inv_overhaul_inventory_presenter"
import "inv_overhaul_inventory_input_controller"
import "inv_overhaul_inventory_sounds"

module inv_overhaul_inventory_controller do
  local const c_sScriptVersion: string = "2026.08.17-fast-open-generation-poll-1"
  local const c_iCWeapon: int = 0
  local const c_iCClothes: int = 1
  local const c_iCategoryCount: int = 5
  local const c_iInventoryCapacity: int = 56
  local const c_iLayoutVersion: int = 4
  local const c_iVKShift: int = 16
  local const c_iVKControl: int = 17
  local const c_iQuickslotCount: int = 10
  local const c_iQuickslotVersion: int = 1
  local const c_iWMHelpMessage: int = 200
  local const c_iInventoryFullTextID: int = 1400
  local const c_iSlotSelected: int = 16384
  local const c_iSlotEmpty: int = 32768
  local const c_iSlotNumber: int = 65536
  local const c_iHoverMessageBase: int = 100000
  local const c_iReleaseMessageBase: int = 200000
  local const c_iDragEndMessageBase: int = 300000
  local const c_iSlotHotZone: int = 52
  local const c_iSlotDropInset: int = 1
  local const c_iInitialSlotLoadBatch: int = 1

  local windowWidth: int
  local windowHeight: int
  local visibleSlots: int
  local lastLayoutWidth: int
  local lastLayoutHeight: int
  local lastLayoutSlots: int
  local deferredInventoryRefresh: float
  local inventoryFullMessageCooldown: float
  local shiftHeld: bool
  local controlHeld: bool
  local inventoryPollCooldown: float
  local observedContentGeneration: int
  local layoutLoadStartCell: int
  local closingWindow: bool

  function PlayerControllerInitialize() -> void
    inv_overhaul_inventory_view.PlayerViewInitializeState()
    if inv_overhaul_inventory_view.DebugLoggingEnabled() then
      native.Trace("INV_OVERHAUL_PERF_STEP root_init_begin")
    end
    native.Trace("INV_OVERHAUL_INVENTORY_VERSION " + c_sScriptVersion + " screen=inventory")
    inv_overhaul_inventory_paging.PlayerPagingInitialize()
    inv_overhaul_inventory_drag.PlayerDragInitializeState()
    lastLayoutWidth = -1
    lastLayoutHeight = -1
    lastLayoutSlots = -1
    inv_overhaul_inventory_tooltip.InterfaceTooltipInitializeState()
    deferredInventoryRefresh = 0
    inventoryFullMessageCooldown = 0
    shiftHeld = false
    controlHeld = false
    inventoryPollCooldown = 0.25
    observedContentGeneration = 0
    local currentContentGeneration: int = observedContentGeneration
    native.GetVariable("inv_overhaul_inventory_content_generation", currentContentGeneration)
    observedContentGeneration = currentContentGeneration
    layoutLoadStartCell = -1
    closingWindow = false
    if inv_overhaul_inventory_view.DebugLoggingEnabled() then
      local warmed: int = 0
      native.GetVariable("inv_overhaul_ui_cache_loaded", warmed)
      native.Trace("INV_OVERHAUL_PERF_PHASE cache_snapshot warmed=" + warmed)
    end
    inv_overhaul_inventory_quickslot_bindings.QuickslotBindingsInitializeState()
    InitializeQuickslotBindings()
    RefreshQuickslotCache()
    if inv_overhaul_inventory_view.DebugLoggingEnabled() then native.Trace("INV_OVERHAUL_PERF_STEP root_quickslots_ready") end
    inv_overhaul_inventory_tooltip.InitializeMoneyItem()
    inv_overhaul_inventory_snapshot.SnapshotInitializeState()
    inv_overhaul_inventory_items.InitializeProjection()
    inv_overhaul_inventory_equipment.InitializeCache()
    InitSlotOrder()
    if inv_overhaul_inventory_view.DebugLoggingEnabled() then native.Trace("INV_OVERHAUL_PERF_STEP root_vectors_ready") end
    PlayerControllerUpdateLayout()
    native.SetVariable("inv_overhaul_inventory_drag_item", -1)
    native.SetVariable("inv_overhaul_inventory_page_hover", 0)
    native.SetCursor("inv_overhaul_inventory")
    native.ShowCursor()
    native.CaptureKeyboard()
    native.SetOwnerDraw(false)
    native.SetNeedUpdate(true)
    if inv_overhaul_inventory_view.DebugLoggingEnabled() then native.Trace("INV_OVERHAUL_PERF_STEP root_before_process_events") end
    inv_overhaul_inventory_sounds.InventorySoundsPlayOpen()
    native.ProcessEvents()
    if inv_overhaul_inventory_view.DebugLoggingEnabled() then native.Trace("INV_OVERHAUL_PERF_STEP root_init_end") end
  end

  -- The compiler cannot safely lower a module global used directly as an
  -- argument of another Lua/DSL function.  These accessors keep controller
  -- state module-owned while ensuring call arguments are ordinary values.
  function ReadWindowWidth() -> int return windowWidth end
  function ReadVisibleSlots() -> int return visibleSlots end
  function ReadPage() -> int
    return inv_overhaul_inventory_paging.GetPage()
  end
  function ReadDragSourceSlot() -> int
    return inv_overhaul_inventory_drag.GetSourceSlot()
  end
  function ReadDragSourceCell() -> int
    return inv_overhaul_inventory_drag.GetSourceCell()
  end
  function ReadHighlightedSlot() -> int
    return inv_overhaul_inventory_drag.PlayerDragGetHighlightedTarget()
  end
  function ReadDragItemCategory() -> int
    return inv_overhaul_inventory_drag.GetItemCategory()
  end
  function ReadDragItemIndex() -> int
    return inv_overhaul_inventory_drag.GetItemIndex()
  end
  function ReadDragItemGroup() -> int
    return inv_overhaul_inventory_drag.GetItemGroup()
  end
  function ReadDragItemIsWeapon() -> bool
    return inv_overhaul_inventory_drag.GetItemIsWeapon()
  end
  function ReadLastBackpackItemCount() -> int
    return inv_overhaul_inventory_snapshot.GetLastBackpackItemCount()
  end
  function ReadLayoutLoadStartCell() -> int return layoutLoadStartCell end
  function ReadPerfCacheEpoch() -> int
    return inv_overhaul_inventory_view.GetCacheEpoch()
  end

  function InitSlotOrder() -> void
    inv_overhaul_inventory_layout_runtime.LayoutRuntimeInitialize()
  end

  function GetBranch() -> int
    local branch: int = -1
    native.GetVariable("branch", branch)
    return branch
  end

  function PlayerControllerGetOrderValue(slot: int) -> int
    return inv_overhaul_inventory_layout_runtime.LayoutRuntimeGetOrderValue(slot)
  end

  function LoadLayoutVariables() -> void
    inv_overhaul_inventory_layout_runtime.Load()
  end

  function ContinueIncrementalLayoutLoad() -> bool
    local complete: bool = inv_overhaul_inventory_layout_runtime.ContinueIncrementalLoad(ReadLayoutLoadStartCell() + 0)
    if complete then layoutLoadStartCell = 0 end
    return complete
  end

  function SaveLayoutVariables() -> void
    inv_overhaul_inventory_layout_runtime.SaveAll()
  end

  function QueueLayoutSave() -> void
    inv_overhaul_inventory_layout_runtime.QueueSave()
  end

  function ContinueLayoutSave() -> void
    inv_overhaul_inventory_layout_runtime.ContinueQueuedSave()
  end

  function OrderFreeCellsByDisplayForCount(itemCount: int) -> void
    if inv_overhaul_inventory_layout_runtime.LayoutRuntimeOrderFreeCellsByDisplay(itemCount, ReadVisibleSlots() + 0) then QueueLayoutSave() end
  end

  function PlayerControllerGetPlayerContainer() -> object
    return inv_overhaul_inventory_items.ItemsGetPlayerContainer()
  end

  function BeginDragCursor(slot: int) -> void
    native.SetVariable("inv_overhaul_inventory_drag_item", -1)
    inv_overhaul_inventory_drag.ClearItem()
    local reference: int = ResolveDragSource(slot)
    if reference < 0 then return end
    local itemCategory: int =
      inv_overhaul_inventory_items.DecodeReferenceCategory(reference)
    local itemIndex: int =
      inv_overhaul_inventory_items.DecodeReferenceIndex(reference)

    local container: object = PlayerControllerGetPlayerContainer()
    local item: object
    container->GetItem(item, itemIndex, itemCategory)
    if !item then
      return
    end

    local itemID: int
    item->GetItemID(itemID)
    local itemGroup: int = -1
    local itemIsWeapon: bool = false
    if itemCategory == c_iCWeapon then
      native.HasInvItemProperty(itemIsWeapon, itemID, "Weapon")
    end
    if itemCategory == c_iCClothes then
      local hasGroup: bool
      native.HasInvItemProperty(hasGroup, itemID, "Group")
      if hasGroup then
        native.GetInvItemProperty(itemGroup, itemID, "Group")
      end
    end
    inv_overhaul_inventory_drag.BeginItem(
      itemID, itemCategory, itemIndex, itemGroup, itemIsWeapon)
    native.SetVariable("inv_overhaul_inventory_drag_item", itemID)
  end

  function EndDragCursor() -> void
    native.SetVariable("inv_overhaul_inventory_drag_item", -1)
    native.SetVariable("inv_overhaul_inventory_page_hover", 0)
    inv_overhaul_inventory_drag.ClearItem()
  end

  function PlayerControllerConfigureSlotRenderSize() -> void
    inv_overhaul_inventory_presenter.PlayerPresenterConfigureSlotRenderSize(
      ReadWindowWidth())
  end

  function PlayerControllerUpdateLayout() -> void
    local currentWidth: int
    local currentHeight: int

    native.GetWindowSize(currentWidth, currentHeight)
    if currentWidth <= 0 || currentHeight <= 0 then
      native.GetScreenSize(currentWidth, currentHeight)
    end

    windowWidth = currentWidth
    windowHeight = currentHeight
    visibleSlots = inv_overhaul_inventory_geometry.InterfaceGeometryGetVisibleSlots(ReadWindowWidth() + 0)
    if windowWidth != lastLayoutWidth || windowHeight != lastLayoutHeight || visibleSlots != lastLayoutSlots then
      native.Trace("inv_overhaul_inventory layout window=" + windowWidth + "x" + windowHeight + " slots=" + visibleSlots)
      if inv_overhaul_inventory_view.ChildWindowsReady() then
        native.SendMessage(currentWidth, "character_doll")
        native.SendMessage(5000 + currentHeight, "character_doll")
        native.SendMessage(currentWidth, "panel_background")
        native.SendMessage(5000 + currentHeight, "panel_background")
        PlayerControllerConfigureSlotRenderSize()
      end
      lastLayoutWidth = windowWidth
      lastLayoutHeight = windowHeight
      lastLayoutSlots = visibleSlots
    end
  end

  function PlayerControllerSendGridRendererState(slot: int, operation: int, value: int, data: object) -> void
    inv_overhaul_inventory_presenter.PlayerPresenterSendGridRendererState(
      slot, c_iInventoryCapacity, operation, value, data)
  end

  function PlayerControllerSetGridRendererHighlight(slot: int, enabled: bool) -> void
    inv_overhaul_inventory_presenter.PlayerPresenterSetGridRendererHighlight(
      slot, enabled)
  end

  function PlayerControllerGetVisibleCell(slot: int) -> int
    return inv_overhaul_inventory_paging.PlayerPagingGetVisibleCell(
      slot, ReadVisibleSlots(), c_iInventoryCapacity)
  end

  function PlayerControllerGetCellForLinearSlot(linear: int) -> int
    return inv_overhaul_inventory_paging.PlayerPagingGetCellForLinearSlot(
      linear, ReadVisibleSlots(), c_iInventoryCapacity)
  end

  function PlayerControllerGetTargetWndName(target: int) -> string
    return inv_overhaul_inventory_view.GetTargetWindowName(
      target, ReadVisibleSlots())
  end

  function PlayerControllerIsInsideSpecialTarget(target: int, x: int, y: int) -> bool
    return inv_overhaul_inventory_geometry.InterfaceGeometryIsInsideSpecialTarget(
      ReadWindowWidth(), GetBranch(), target, x, y)
  end

  function PlayerControllerIsInsideMoney(x: int, y: int) -> bool
    return inv_overhaul_inventory_geometry.InterfaceGeometryIsInsideMoney(
      ReadWindowWidth(), GetBranch(), x, y)
  end

  function FindSpecialTargetAt(x: int, y: int) -> int
    if inv_overhaul_inventory_drag.GetItemCategory() == c_iCWeapon &&
      inv_overhaul_inventory_drag.GetItemIsWeapon() then
      if PlayerControllerIsInsideSpecialTarget(inv_overhaul_inventory_protocol.TargetWeapon, x, y) then
        return inv_overhaul_inventory_protocol.TargetWeapon
      end
    end

    local itemGroup: int = inv_overhaul_inventory_drag.GetItemGroup()
    if inv_overhaul_inventory_drag.GetItemCategory() == c_iCClothes &&
      itemGroup >= 1 && itemGroup <= 4 then
      local clothesTarget: int = inv_overhaul_inventory_protocol.TargetClothesBase + itemGroup
      if PlayerControllerIsInsideSpecialTarget(clothesTarget, x, y) then
        return clothesTarget
      end
    end

    if PlayerControllerIsInsideSpecialTarget(inv_overhaul_inventory_protocol.TargetDrop, x, y) then
      return inv_overhaul_inventory_protocol.TargetDrop
    end
    return -1
  end

  function FindEquipmentTargetAt(x: int, y: int) -> int
    if PlayerControllerIsInsideSpecialTarget(inv_overhaul_inventory_protocol.TargetWeapon, x, y) then return inv_overhaul_inventory_protocol.TargetWeapon end
    for group = 1, 4 do
      local target: int = inv_overhaul_inventory_protocol.TargetClothesBase + group
      if PlayerControllerIsInsideSpecialTarget(target, x, y) then return target end
    end
    return -1
  end

  function PlayerControllerGetBackpackItemCount() -> int
    return inv_overhaul_inventory_items.GetBackpackCount()
  end

  function LoadPersistentBackpackSnapshot() -> bool
    return inv_overhaul_inventory_snapshot.LoadPersistent()
  end

  function CanReusePersistentBackpackSnapshot() -> bool
    return inv_overhaul_inventory_snapshot.CanReusePersistent()
  end

  function SavePersistentBackpackSnapshot() -> void
    inv_overhaul_inventory_snapshot.SavePersistent()
  end

  function CopyCurrentBackpackSnapshot(newCount: int) -> void
    inv_overhaul_inventory_snapshot.CopyCurrent(newCount)
  end

  function BackpackSnapshotDiffers(newCount: int) -> bool
    return inv_overhaul_inventory_snapshot.Differs(newCount)
  end

  function PersistCurrentBackpackSnapshot() -> void
    inv_overhaul_inventory_snapshot.PersistCurrent()
  end

  function ReconcileInventoryContentGeneration(currentGeneration: int) -> bool
    if currentGeneration == observedContentGeneration then return false end

    -- A category/index captured by BeginDragCursor is no longer trustworthy
    -- after any externally published inventory mutation.  Cancel before the
    -- snapshot and index caches are rebuilt, then acknowledge the generation
    -- only after the persistent snapshot reflects the reconciled contents.
    if inv_overhaul_inventory_drag.PlayerDragIsActive() then CancelDragAction() end
    local currentBackpackCount: int =
      inv_overhaul_inventory_snapshot.CaptureCurrentCount()
    if BackpackSnapshotDiffers(currentBackpackCount) then
      ReconcileBackpackSnapshot(currentBackpackCount)
      UpdateSlots()
    end
    SavePersistentBackpackSnapshot()
    observedContentGeneration = currentGeneration
    return true
  end

  function InitializePersistentBackpackSnapshot() -> void
    if CanReusePersistentBackpackSnapshot() then
      inv_overhaul_inventory_snapshot.BuildIndexCacheAndPrevious()
      inv_overhaul_inventory_snapshot.ClampLastBackpackItemCount()
      return
    end
    local currentCount: int =
      inv_overhaul_inventory_snapshot.CaptureCurrentCount()
    if currentCount > c_iInventoryCapacity then currentCount = c_iInventoryCapacity end
    local loaded: bool = LoadPersistentBackpackSnapshot()
    local changed: bool = loaded && BackpackSnapshotDiffers(currentCount)
    if changed then
      ReconcileBackpackSnapshot(currentCount)
      native.Trace("inv_overhaul_inventory persistent snapshot reconciled old=" +
        ReadLastBackpackItemCount() +
        " current=" + currentCount)
    end
    CopyCurrentBackpackSnapshot(currentCount)
    -- Persist after every fallback comparison so an older save that lacks the
    -- content-generation stamp is migrated after its stored IDs are checked.
    SavePersistentBackpackSnapshot()
    if !loaded then native.Trace("inv_overhaul_inventory persistent snapshot initialized count=" + currentCount) end
    BuildBackpackIndexCache()
  end

  function ReconcileBackpackSnapshot(newCount: int) -> void
    inv_overhaul_inventory_snapshot.Reconcile(
      newCount,
      ReadVisibleSlots() + 0)
    QueueLayoutSave()
  end

  function RestoreOrderAfterEquipmentReplacement(replacedOrder: int, itemCount: int) -> bool
    local restored: bool =
      inv_overhaul_inventory_snapshot.RestoreAfterEquipmentReplacement(
        replacedOrder,
        itemCount,
        ReadVisibleSlots() + 0)
    if restored then QueueLayoutSave() end
    return restored
  end

  function RestoreOrderAfterEquipmentSelection(removedOrder: int, beforeCount: int) -> bool
    local restored: bool =
      inv_overhaul_inventory_snapshot.RestoreAfterEquipmentSelection(
        removedOrder,
        beforeCount,
        ReadVisibleSlots() + 0)
    if restored then QueueLayoutSave() end
    return restored
  end

  function PlayerControllerShowInventoryFull() -> void
    if inventoryFullMessageCooldown > 0 then return end
    local text: object
    native.CreateIntVector(text)
    text->add(c_iInventoryFullTextID)
    native.SendWorldWndMessage(c_iWMHelpMessage, text)
    inventoryFullMessageCooldown = 1.0
  end

  function PlayerControllerGetMaxPage() -> int
    return inv_overhaul_inventory_paging.PlayerPagingGetMaxPage(
      c_iInventoryCapacity, ReadVisibleSlots() + 0)
  end

  function ClampPage() -> void
    inv_overhaul_inventory_paging.Clamp(
      c_iInventoryCapacity, ReadVisibleSlots() + 0)
  end

  function PlayerControllerUpdatePageControls() -> void
    local maxPage: int = PlayerControllerGetMaxPage()
    local currentPage: int = ReadPage()
    inv_overhaul_inventory_presenter.PlayerPresenterUpdatePageControls(
      ReadVisibleSlots(), c_iInventoryCapacity, maxPage, currentPage)
  end

  function PlayerControllerResolveVisibleSlot(slot: int) -> int
    local target: int = PlayerControllerGetOrderValue(PlayerControllerGetVisibleCell(slot))
    return inv_overhaul_inventory_items.ResolveCachedOrdinal(target)
  end

  function BuildBackpackIndexCache() -> void
    inv_overhaul_inventory_items.ItemsBuildIndexCache()
  end

  function BuildBackpackIndexCacheAndSnapshot() -> int
    return inv_overhaul_inventory_snapshot.BuildIndexCacheAndPrevious()
  end

  function PlayerControllerUpdateMoney() -> void
    inv_overhaul_inventory_presenter.PlayerPresenterUpdateMoney(
      PlayerControllerGetPlayerContainer())
  end

  function InitializeQuickslotBindings() -> void
    inv_overhaul_inventory_quickslot_bindings.InitializeBindings()
  end

  function RefreshQuickslotCache() -> void
    inv_overhaul_inventory_quickslot_bindings.RefreshCache()
  end

  function GetDisplayedQuickslot(category: int, index: int, itemID: int) -> int
    return inv_overhaul_inventory_quickslot_bindings.GetDisplayedBinding(
      category, index, itemID)
  end

  function AssignQuickslot(slot: int, category: int, index: int) -> void
    if inv_overhaul_inventory_quickslot_bindings.Assign(
      slot, category, index, true) then
      inv_overhaul_inventory_sounds.InventorySoundsPlayAction()
      UpdateSlots()
    end
  end

  function GetQuickslotByKey(key: int) -> int
    return inv_overhaul_inventory_quickslot_bindings.GetSlotByKey(key)
  end

  function PlayerControllerAssignHoveredQuickslot(slot: int) -> void
    if inv_overhaul_inventory_drag.PlayerDragIsActive() then return end
    local target: int = inv_overhaul_inventory_drag.PlayerDragGetHighlightedTarget()
    if target < 0 then
      target = inv_overhaul_inventory_tooltip.GetTarget()
    end
    local reference: int = ResolveDragSource(target)
    if reference >= 0 then
      AssignQuickslot(
        slot,
        inv_overhaul_inventory_items.DecodeReferenceCategory(reference),
        inv_overhaul_inventory_items.DecodeReferenceIndex(reference))
    end
  end

  function PlayerControllerUpdateSlot(slot: int) -> void
    local container: object = PlayerControllerGetPlayerContainer()
    local visibleCell: int = PlayerControllerGetVisibleCell(slot)
    local reference: int = -1
    if visibleCell >= 0 then reference = PlayerControllerResolveVisibleSlot(slot) end
    inv_overhaul_inventory_presenter.PlayerPresenterUpdateSlot(
      slot, c_iInventoryCapacity, visibleCell, reference, container)
  end

  function PlayerControllerIsItemTexturePreloaded(itemID: int, cacheEpoch: int) -> bool
    return inv_overhaul_inventory_presenter.PlayerPresenterIsItemTexturePreloaded(
      itemID, cacheEpoch)
  end

  function PlayerControllerMarkItemTextureLoaded(category: int, index: int) -> void
    inv_overhaul_inventory_presenter.PlayerPresenterMarkItemTextureLoaded(
      PlayerControllerGetPlayerContainer(), category, index)
  end

  function MeasureInitialTextureCacheCoverage() -> void
    inv_overhaul_inventory_view.ResetCacheCoverage()
    local container: object = PlayerControllerGetPlayerContainer()

    for ordinal = 0, c_iInventoryCapacity - 1 do
      local category: int
      local index: int
      category = inv_overhaul_inventory_items.ItemsGetCachedCategory(ordinal)
      index = inv_overhaul_inventory_items.ItemsGetCachedIndex(ordinal)
      if category >= 0 && index >= 0 then
        local item: object
        local itemID: int = -1
        container->GetItem(item, index, category)
        if item then item->GetItemID(itemID) end
        local hit: bool = PlayerControllerIsItemTexturePreloaded(
          itemID, ReadPerfCacheEpoch() + 0)
        inv_overhaul_inventory_view.RecordStackCacheResult(hit)
      end
    end

    for equipment = 0, 4 do
      local category: int
      local index: int
      category = inv_overhaul_inventory_equipment.PlayerEquipmentGetCachedCategory(equipment)
      index = inv_overhaul_inventory_equipment.PlayerEquipmentGetCachedIndex(equipment)
      if category >= 0 && index >= 0 then
        local item: object
        local itemID: int = -1
        container->GetItem(item, index, category)
        if item then item->GetItemID(itemID) end
        local hit: bool = PlayerControllerIsItemTexturePreloaded(
          itemID, ReadPerfCacheEpoch() + 0)
        inv_overhaul_inventory_view.RecordEquipmentCacheResult(hit)
      end
    end
  end

  function PlayerControllerReportFirstInitialItem() -> void
    inv_overhaul_inventory_view.PlayerViewReportFirstInitialItem()
  end

  function PlayerControllerReportInitialLoadComplete() -> void
    inv_overhaul_inventory_view.PlayerViewReportInitialLoadComplete()
  end

  function TryWarmStartGrid() -> void
    if !inv_overhaul_inventory_view.BeginWarmStartAttempt() then return end

    local characterReady: int = 0
    local fullyWarmed: int = 0
    local completedGeneration: int = -1
    local currentGeneration: int = 0
    native.GetVariable("inv_overhaul_ui_cache_character_ready", characterReady)
    native.GetVariable("inv_overhaul_ui_cache_fully_warmed", fullyWarmed)
    native.GetVariable("inv_overhaul_ui_cache_completed_generation", completedGeneration)
    native.GetVariable("inv_overhaul_inventory_content_generation", currentGeneration)
    if characterReady != 1 || fullyWarmed != 1 || completedGeneration != currentGeneration then
      if inv_overhaul_inventory_view.DebugLoggingEnabled() then
        native.Trace("INV_OVERHAUL_PERF_PHASE warm_start ready=0 generation=" +
          completedGeneration + " current=" + currentGeneration)
      end
      return
    end

    LoadLayoutVariables()
    InitializePersistentBackpackSnapshot()
    OrderFreeCellsByDisplayForCount(ReadLastBackpackItemCount() + 0)
    BuildEquipmentIndexCache()
    MeasureInitialTextureCacheCoverage()
    local cacheHits: int = inv_overhaul_inventory_view.GetCacheHits()
    local cacheMisses: int = inv_overhaul_inventory_view.GetCacheMisses()
    if cacheMisses > 0 then
      if inv_overhaul_inventory_view.DebugLoggingEnabled() then
        native.Trace("INV_OVERHAUL_PERF_PHASE warm_start ready=0 hits=" +
          cacheHits + " misses=" + cacheMisses)
      end
      return
    end

    ClampPage()
    for slot = 0, visibleSlots - 1 do PlayerControllerUpdateSlot(slot) end
    inv_overhaul_inventory_view.MarkWarmGridLoaded()
    if inv_overhaul_inventory_view.DebugLoggingEnabled() then
      native.Trace("INV_OVERHAUL_PERF_PHASE warm_start ready=1 hits=" +
        cacheHits + " misses=" + cacheMisses)
    end
  end

  function PlayerControllerBeginInitialSlotLoad() -> void
    PlayerControllerUpdateLayout()
    ClampPage()
    BuildEquipmentIndexCache()
    MeasureInitialTextureCacheCoverage()
    PlayerControllerUpdatePageControls()
    inv_overhaul_inventory_view.BeginInitialLoad(
      ReadVisibleSlots())
    -- Every inventory window is created with empty slot backgrounds already
    -- assigned by the child scripts.  Initialise the five equipment labels in
    -- one cheap pass; PlayerControllerContinueInitialSlotLoad then spends frames only on
    -- occupied slots whose sprites actually have to be decoded.
    for cache = 0, 4 do
      local wndName: string = PlayerControllerGetTargetWndName(inv_overhaul_inventory_protocol.TargetWeapon + cache)
      native.SendMessage(c_iSlotEmpty, wndName)
      native.SendMessage(-140, wndName)
      native.SendMessage(-30 - cache, wndName)
    end
    native.Trace("inv_overhaul_inventory deferred initial slots count=" + visibleSlots)
  end

  function PlayerControllerContinueInitialSlotLoad() -> void
    if !inv_overhaul_inventory_view.IsInitialLoadActive() then return end
    if inv_overhaul_inventory_view.DebugLoggingEnabled() then native.Trace("INV_OVERHAUL_PERF_STEP slot_pass_begin") end
    for batch = 0, c_iInitialSlotLoadBatch - 1 do
      local loadedSprite: bool = false

      -- Empty equipment slots have already been initialised in
      -- PlayerControllerBeginInitialSlotLoad.  Skip them without consuming a whole frame.
      local equipmentDone: bool = false
      while !loadedSprite && !equipmentDone do
        local equipmentSlot: int =
          inv_overhaul_inventory_view.TakeNextEquipment()
        if equipmentSlot < 0 then equipmentDone = true else
        local category: int
        local index: int
        category = inv_overhaul_inventory_equipment.PlayerEquipmentGetCachedCategory(equipmentSlot)
        index = inv_overhaul_inventory_equipment.PlayerEquipmentGetCachedIndex(equipmentSlot)
        if category >= 0 && index >= 0 then
          UpdateCachedEquipmentSlot(equipmentSlot)
          PlayerControllerMarkItemTextureLoaded(category, index)
          PlayerControllerReportFirstInitialItem()
          loadedSprite = true
        end
        end
      end

      -- A freshly-created empty grid slot already has the correct background.
      -- Only occupied cells need an item message and native.LoadImage. Invalid
      -- cells on a short final page are still explicitly hidden.
      while !loadedSprite do
        local slot: int = inv_overhaul_inventory_view.TakeNextSlot(
          ReadVisibleSlots())
        if slot < 0 then loadedSprite = true else
        if PlayerControllerGetVisibleCell(slot) < 0 then
          PlayerControllerUpdateSlot(slot)
        else
          local reference: int = PlayerControllerResolveVisibleSlot(slot)
          if reference >= 0 then
            PlayerControllerUpdateSlot(slot)
            PlayerControllerMarkItemTextureLoaded(
              inv_overhaul_inventory_items.DecodeReferenceCategory(reference),
              inv_overhaul_inventory_items.DecodeReferenceIndex(reference))
            PlayerControllerReportFirstInitialItem()
            loadedSprite = true
          end
        end
        end
      end
    end
    if inv_overhaul_inventory_view.InitialLoadComplete(
      ReadVisibleSlots()) then
      inv_overhaul_inventory_view.FinishInitialLoad()
      PlayerControllerReportInitialLoadComplete()
      native.Trace("inv_overhaul_inventory sequential initial slots complete batch=" +
        c_iInitialSlotLoadBatch)
    end
    if inv_overhaul_inventory_view.DebugLoggingEnabled() then native.Trace("INV_OVERHAUL_PERF_STEP slot_pass_end") end
  end

  function UpdateSlots() -> void
    inv_overhaul_inventory_view.FinishInitialLoad()
    PlayerControllerUpdateLayout()
    ClampPage()
    BuildBackpackIndexCacheAndSnapshot()
    for slot = 0, visibleSlots - 1 do PlayerControllerUpdateSlot(slot) end
    UpdateEquipmentSlots()
    PlayerControllerUpdatePageControls()
  end

  function BuildEquipmentIndexCache() -> void
    inv_overhaul_inventory_equipment.BuildCache()
  end

  function UpdateCachedEquipmentSlot(cache: int) -> void
    local category: int
    local index: int
    local wndName: string = PlayerControllerGetTargetWndName(inv_overhaul_inventory_protocol.TargetWeapon + cache)
    category = inv_overhaul_inventory_equipment.PlayerEquipmentGetCachedCategory(cache)
    index = inv_overhaul_inventory_equipment.PlayerEquipmentGetCachedIndex(cache)
    inv_overhaul_inventory_presenter.UpdateEquipmentSlot(
      cache, wndName, category, index, PlayerControllerGetPlayerContainer(),
      c_iSlotEmpty)
  end

  function UpdateEquipmentSlots() -> void
    BuildEquipmentIndexCache()
    for cache = 0, 4 do
      UpdateCachedEquipmentSlot(cache)
    end
  end

  function UpdateVisibleCell(cell: int) -> void
    if cell < 0 then return end
    for slot = 0, visibleSlots - 1 do
      if PlayerControllerGetVisibleCell(slot) == cell then
        PlayerControllerUpdateSlot(slot)
        return
      end
    end
  end

  function RefreshEquipmentMutation(changedCell: int, equipmentTarget: int) -> void
    inv_overhaul_inventory_view.FinishInitialLoad()
    BuildBackpackIndexCacheAndSnapshot()
    inv_overhaul_inventory_snapshot.ClampLastBackpackItemCount()
    UpdateVisibleCell(changedCell)
    BuildEquipmentIndexCache()
    local cache: int = equipmentTarget - inv_overhaul_inventory_protocol.TargetWeapon
    if cache >= 0 && cache < 5 then UpdateCachedEquipmentSlot(cache) end
    PlayerControllerUpdatePageControls()
  end

  function ResolveEquipmentTarget(target: int) -> int
    return inv_overhaul_inventory_equipment.ResolveTarget(target)
  end

  function ResolveDragSource(source: int) -> int
    if source >= 0 && source < visibleSlots then
      return PlayerControllerResolveVisibleSlot(source)
    end
    return ResolveEquipmentTarget(source)
  end

  function UnequipItem(category: int, index: int) -> bool
    return inv_overhaul_inventory_equipment.Unequip(category, index)
  end

  function EquipDraggedItem(target: int, category: int, index: int) -> bool
    return inv_overhaul_inventory_equipment.Equip(target, category, index)
  end

  function ToggleSlot(category: int, index: int) -> void
    local result: int = inv_overhaul_inventory_equipment.PlayerEquipmentToggle(category, index)
    if result == 1 then
      inv_overhaul_inventory_sounds.InventorySoundsPlayItemEquip()
    end
    if result == 2 then deferredInventoryRefresh = 0.25 end
  end

  function PlayerControllerHandleModifiedDrop(sourceSlot: int) -> bool
    if !shiftHeld && !controlHeld then return false end
    if sourceSlot < 0 || sourceSlot >= visibleSlots then return false end
    local reference: int = PlayerControllerResolveVisibleSlot(sourceSlot)
    if reference < 0 then return true end

    if controlHeld && !shiftHeld then
      PlayerControllerMoveSlotToOtherPage(sourceSlot)
      return true
    end

    local category: int =
      inv_overhaul_inventory_items.DecodeReferenceCategory(reference)
    local index: int =
      inv_overhaul_inventory_items.DecodeReferenceIndex(reference)
    local amount: int
    local player: object = PlayerControllerGetPlayerContainer()
    player->GetItemAmount(amount, index, category)

    local beforeCount: int = PlayerControllerGetBackpackItemCount()
    local usedOrder: int = PlayerControllerGetOrderValue(PlayerControllerGetVisibleCell(sourceSlot))
    if inv_overhaul_inventory_drop.Slot(category, index, amount) then
      local afterCount: int = PlayerControllerGetBackpackItemCount()
      if afterCount < beforeCount then RemoveOrderOrdinal(usedOrder, beforeCount) end
      UpdateSlots()
    end
    return true
  end

  function PlayerControllerMoveSlotToOtherPage(sourceSlot: int) -> void
    local maxPage: int = PlayerControllerGetMaxPage()
    if maxPage <= 0 then return end

    local targetPage: int =
      inv_overhaul_inventory_paging.GetNextPage(maxPage)
    local backpackCount: int = PlayerControllerGetBackpackItemCount()
    local targetCell: int = -1
    for targetSlot = 0, visibleSlots - 1 do
      local linear: int = targetPage * visibleSlots + targetSlot
      local cell: int = PlayerControllerGetCellForLinearSlot(linear)
      if cell >= 0 && PlayerControllerGetOrderValue(cell) >= backpackCount then
        targetCell = cell
        targetSlot = visibleSlots
      end
    end
    if targetCell < 0 then
      PlayerControllerShowInventoryFull()
      return
    end

    local sourceCell: int = PlayerControllerGetVisibleCell(sourceSlot)
    SwapSlotOrderCells(sourceCell, targetCell)
    native.Trace("inv_overhaul_inventory ctrl-page-move sourcePage=" +
      ReadPage() + " targetPage=" + targetPage)
  end

  function HandleSlotMessage(message: int, sender: string) -> bool
    for slot = 0, visibleSlots - 1 do
      if sender == inv_overhaul_inventory_protocol.GetSlotWindowName(slot) then
        local reference: int = PlayerControllerResolveVisibleSlot(slot)
        if reference >= 0 then
          if message == 1 then
            local beforeCount: int = PlayerControllerGetBackpackItemCount()
            local usedOrder: int = PlayerControllerGetOrderValue(PlayerControllerGetVisibleCell(slot))
            local category: int =
              inv_overhaul_inventory_items.DecodeReferenceCategory(reference)
            local index: int =
              inv_overhaul_inventory_items.DecodeReferenceIndex(reference)
            ToggleSlot(category, index)
            local afterCount: int = PlayerControllerGetBackpackItemCount()
            native.Trace("inv_overhaul_inventory slot toggle category=" + category + " order=" + usedOrder +
              " before=" + beforeCount + " after=" + afterCount)
            if afterCount < beforeCount then
              if category == c_iCWeapon || category == c_iCClothes then
                if !RestoreOrderAfterEquipmentSelection(usedOrder, beforeCount) then
                  RemoveOrderOrdinal(usedOrder, beforeCount)
                end
              else
                RemoveOrderOrdinal(usedOrder, beforeCount)
              end
            else
              if afterCount == beforeCount && (category == c_iCWeapon || category == c_iCClothes) then
                RestoreOrderAfterEquipmentReplacement(usedOrder, beforeCount)
              end
            end
          else
            native.Trace("inv_overhaul_inventory left click ignored " + sender)
          end
        end
        UpdateSlots()
        return true
      end
    end
    return false
  end

  function GetDragSourceBySender(sender: string) -> int
    local backpackSource: int = inv_overhaul_inventory_protocol.GetSlotBySender(sender, ReadVisibleSlots() + 0)
    if backpackSource >= 0 then return backpackSource end
    return inv_overhaul_inventory_protocol.GetSpecialTargetBySender(sender)
  end

  function IsSpecialTargetCompatible(target: int) -> bool
    return inv_overhaul_inventory_equipment.PlayerEquipmentIsTargetCompatible(
      target, ReadDragItemCategory(), ReadDragItemIsWeapon(), ReadDragItemGroup() + 0)
  end

  function StartDragAction(source: int, sender: string) -> void
    local currentGeneration: int = observedContentGeneration
    native.GetVariable("inv_overhaul_inventory_content_generation", currentGeneration)
    ReconcileInventoryContentGeneration(currentGeneration)
    CancelDragPageHover(0)
    inv_overhaul_inventory_tooltip.InterfaceTooltipClear()
    local sourceCell: int = -1
    if source >= 0 && source < visibleSlots then sourceCell = PlayerControllerGetVisibleCell(source) end
    inv_overhaul_inventory_drag.BeginTransaction(source, sourceCell)
    SetHighlightedSlot(-1)
    BeginDragCursor(ReadDragSourceSlot() + 0)
    native.Trace("inv_overhaul_inventory press " + sender + " " + source)
  end

  function UnequipTarget(target: int, reason: string) -> void
    local reference: int = ResolveEquipmentTarget(target)
    if reference >= 0 then
      local beforeCount: int = PlayerControllerGetBackpackItemCount()
      if beforeCount >= c_iInventoryCapacity then
        native.Trace("inv_overhaul_inventory unequip refused: backpack full target=" + target)
        PlayerControllerShowInventoryFull()
        return
      end
      local category: int =
        inv_overhaul_inventory_items.DecodeReferenceCategory(reference)
      local index: int =
        inv_overhaul_inventory_items.DecodeReferenceIndex(reference)
      if UnequipItem(category, index) then
        InsertOrderOrdinal(PlayerControllerGetBackpackOrdinal(category, index), beforeCount)
        inv_overhaul_inventory_sounds.InventorySoundsPlayItemEquip()
        native.Trace("inv_overhaul_inventory unequipped by " + reason + " target=" + target)
      end
      UpdateSlots()
    end
  end

  function SwapSlotOrderCells(sourceCell: int, targetCell: int) -> void
    if !inv_overhaul_inventory_layout_runtime.LayoutRuntimeSwapCells(sourceCell, targetCell) then return end
    inv_overhaul_inventory_sounds.InventorySoundsPlayItemEquip()
    QueueLayoutSave()
    for visibleSlot = 0, visibleSlots - 1 do
      local visibleCell: int = PlayerControllerGetVisibleCell(visibleSlot)
      if visibleCell == sourceCell || visibleCell == targetCell then PlayerControllerUpdateSlot(visibleSlot) end
    end
  end

  function RemoveOrderOrdinal(removedOrder: int, beforeCount: int) -> void
    inv_overhaul_inventory_layout_runtime.RemoveOrdinal(removedOrder, beforeCount, PlayerControllerGetBackpackItemCount(), ReadVisibleSlots() + 0)
    QueueLayoutSave()
  end

  function FindFirstFreeVisualSlot(itemCount: int) -> int
    return inv_overhaul_inventory_layout_runtime.FindFirstFreeCell(itemCount, ReadVisibleSlots() + 0)
  end

  function PlayerControllerGetBackpackOrdinal(category: int, index: int) -> int
    return inv_overhaul_inventory_items.ItemsGetBackpackOrdinal(category, index)
  end

  function InsertOrderOrdinal(insertedOrder: int, beforeCount: int) -> bool
    return InsertOrderOrdinalAtCell(insertedOrder, beforeCount, FindFirstFreeVisualSlot(beforeCount))
  end

  function InsertOrderOrdinalAtCell(insertedOrder: int, beforeCount: int, targetCell: int) -> bool
    local inserted: bool = inv_overhaul_inventory_layout_runtime.InsertOrdinal(insertedOrder, beforeCount, targetCell, PlayerControllerGetBackpackItemCount(), ReadVisibleSlots() + 0)
    if inserted then QueueLayoutSave() end
    return inserted
  end

  function SetHighlightedSlot(slot: int) -> void
    local previous: int = inv_overhaul_inventory_drag.PlayerDragGetHighlightedTarget()
    if previous == slot then
      return
    end

    if previous >= 0 then
      if previous < visibleSlots then
        PlayerControllerSetGridRendererHighlight(previous, false)
      else
        native.SendMessage(-21, PlayerControllerGetTargetWndName(previous))
      end
    end

    inv_overhaul_inventory_drag.PlayerDragSetHighlightedTarget(slot)
    if slot >= 0 then
      if slot < visibleSlots then
        PlayerControllerSetGridRendererHighlight(slot, true)
      else
        native.SendMessage(-20, PlayerControllerGetTargetWndName(slot))
      end
    end
  end

  function CancelDragAction() -> void
    if !inv_overhaul_inventory_drag.PlayerDragIsActive() then return end

    local sourceSlot: int = inv_overhaul_inventory_drag.GetSourceSlot()
    inv_overhaul_inventory_tooltip.Suspend(0.2)
    inv_overhaul_inventory_tooltip.InterfaceTooltipClear()
    if sourceSlot >= visibleSlots && sourceSlot <= inv_overhaul_inventory_protocol.TargetClothesBase + 4 then
      native.SendMessage(-130, PlayerControllerGetTargetWndName(sourceSlot))
    end

    inv_overhaul_inventory_drag.ClearTransaction()
    SetHighlightedSlot(-1)
    EndDragCursor()
    CancelDragPageHover(0)
  end

  function FinishLeftAction(targetSlot: int) -> void
    if !inv_overhaul_inventory_drag.PlayerDragIsActive() then
      return
    end

    local currentGeneration: int = observedContentGeneration
    native.GetVariable("inv_overhaul_inventory_content_generation", currentGeneration)
    if ReconcileInventoryContentGeneration(currentGeneration) then return end

    local sourceSlot: int = inv_overhaul_inventory_drag.GetSourceSlot()
    local resolvedTarget: int =
      inv_overhaul_inventory_drag.PlayerDragResolveReleaseTarget(targetSlot)
    if resolvedTarget != targetSlot then
      targetSlot = resolvedTarget
      native.Trace("inv_overhaul_inventory release latched target=" + targetSlot)
    end

    inv_overhaul_inventory_tooltip.Suspend(0.2)
    inv_overhaul_inventory_tooltip.InterfaceTooltipClear()
    if sourceSlot >= visibleSlots && sourceSlot <= inv_overhaul_inventory_protocol.TargetClothesBase + 4 then
      native.SendMessage(-130, PlayerControllerGetTargetWndName(sourceSlot))
    end
    if targetSlot >= visibleSlots && targetSlot <= inv_overhaul_inventory_protocol.TargetClothesBase + 4 then
      native.SendMessage(-130, PlayerControllerGetTargetWndName(targetSlot))
    end

    if sourceSlot >= inv_overhaul_inventory_protocol.TargetWeapon && sourceSlot <= inv_overhaul_inventory_protocol.TargetClothesBase + 4 then
      if targetSlot >= 0 && targetSlot < visibleSlots then
        local beforeCount: int = PlayerControllerGetBackpackItemCount()
        if beforeCount < c_iInventoryCapacity then
          if UnequipItem(ReadDragItemCategory(), ReadDragItemIndex()) then
            InsertOrderOrdinalAtCell(
              PlayerControllerGetBackpackOrdinal(ReadDragItemCategory(), ReadDragItemIndex()),
              beforeCount,
              PlayerControllerGetVisibleCell(targetSlot))
            inv_overhaul_inventory_sounds.InventorySoundsPlayItemEquip()
            native.Trace("inv_overhaul_inventory unequipped by drag source=" + sourceSlot + " target=" + targetSlot)
          end
        else
          native.Trace("inv_overhaul_inventory unequip drag refused: backpack full source=" + sourceSlot)
          PlayerControllerShowInventoryFull()
        end
        RefreshEquipmentMutation(PlayerControllerGetVisibleCell(targetSlot), sourceSlot)
      else
        if targetSlot == inv_overhaul_inventory_protocol.TargetDrop then
          inv_overhaul_inventory_drop.Slot(
            ReadDragItemCategory(),
            ReadDragItemIndex(),
            1)
          UpdateSlots()
        else
          native.Trace("inv_overhaul_inventory equipped source release ignored source=" + sourceSlot + " target=" + targetSlot)
        end
      end
    else
      if targetSlot >= 0 && targetSlot < visibleSlots &&
        PlayerControllerGetVisibleCell(targetSlot) !=
          inv_overhaul_inventory_drag.GetSourceCell() then
        native.Trace("inv_overhaul_inventory swap " + sourceSlot + " " + targetSlot)
        SwapSlotOrderCells(ReadDragSourceCell(), PlayerControllerGetVisibleCell(targetSlot))
      else
        if targetSlot >= inv_overhaul_inventory_protocol.TargetWeapon && targetSlot <= inv_overhaul_inventory_protocol.TargetClothesBase + 4 then
          if inv_overhaul_inventory_drag.GetItemCategory() >= 0 &&
            inv_overhaul_inventory_drag.GetItemIndex() >= 0 then
            local beforeCount: int = PlayerControllerGetBackpackItemCount()
            local usedOrder: int = PlayerControllerGetOrderValue(ReadDragSourceCell() + 0)
            local equipped: bool = EquipDraggedItem(targetSlot, ReadDragItemCategory(), ReadDragItemIndex())
            if equipped then
              inv_overhaul_inventory_sounds.InventorySoundsPlayItemEquip()
              local afterCount: int = PlayerControllerGetBackpackItemCount()
              if afterCount < beforeCount then
                if !RestoreOrderAfterEquipmentSelection(usedOrder, beforeCount) then
                  RemoveOrderOrdinal(usedOrder, beforeCount)
                end
              else
                if afterCount == beforeCount then
                  RestoreOrderAfterEquipmentReplacement(usedOrder, beforeCount)
                end
              end
              native.Trace("inv_overhaul_inventory equipped target=" + targetSlot)
            else
              native.Trace("inv_overhaul_inventory incompatible target=" + targetSlot)
            end
            if equipped then RefreshEquipmentMutation(ReadDragSourceCell(), targetSlot) end
          end
        else
          if targetSlot == inv_overhaul_inventory_protocol.TargetDrop then
            if inv_overhaul_inventory_drag.GetItemCategory() >= 0 &&
              inv_overhaul_inventory_drag.GetItemIndex() >= 0 then
              local beforeCount: int = PlayerControllerGetBackpackItemCount()
              local usedOrder: int = PlayerControllerGetOrderValue(ReadDragSourceCell() + 0)
              inv_overhaul_inventory_drop.Slot(
                ReadDragItemCategory(),
                ReadDragItemIndex(),
                1)
              local afterCount: int = PlayerControllerGetBackpackItemCount()
              if afterCount < beforeCount then RemoveOrderOrdinal(usedOrder, beforeCount) end
              UpdateSlots()
            end
          else
            native.Trace("inv_overhaul_inventory left release " + sourceSlot)
          end
        end
      end
    end

    inv_overhaul_inventory_drag.ClearTransaction()
    SetHighlightedSlot(-1)
    EndDragCursor()
    CancelDragPageHover(0)
  end

  function FindBackpackSlotAt(x: int, y: int) -> int
    return inv_overhaul_inventory_geometry.FindBackpackSlot(
      ReadWindowWidth(), ReadVisibleSlots(), c_iSlotDropInset, x, y)
  end

  function FindSlotAt(x: int, y: int) -> int
    local backpackSlot: int = FindBackpackSlotAt(x, y)
    if backpackSlot >= 0 then return backpackSlot end
    return FindSpecialTargetAt(x, y)
  end

  function PlayerControllerIsInsideSlotDropArea(localX: int, localY: int) -> bool
    return inv_overhaul_inventory_geometry.InterfaceGeometryIsInsideSlotDropArea(
      ReadWindowWidth(), c_iSlotDropInset, localX, localY)
  end

  function FindSlotAtPointer(x: int, y: int) -> int
    return FindSlotAt(x, y)
  end

  function UpdatePointerSlot(x: int, y: int) -> int
    return FindSlotAtPointer(x, y)
  end

  function ApplyPointerSlot(slot: int) -> void
    if !inv_overhaul_inventory_drag.PlayerDragIsActive() then
      return
    end

    local sameSource: bool = false
    local sourceSlot: int = inv_overhaul_inventory_drag.GetSourceSlot()
    local sourceCell: int = inv_overhaul_inventory_drag.GetSourceCell()
    if slot == sourceSlot then sameSource = true end
    if sourceCell >= 0 && slot >= 0 && slot < visibleSlots then
      if PlayerControllerGetVisibleCell(slot) == sourceCell then sameSource = true else sameSource = false end
    end
    local highlight: int =
      inv_overhaul_inventory_drag.PlayerDragApplyPointerTarget(slot, sameSource)
    SetHighlightedSlot(highlight)
  end

  function GetCurrentDropSlot(message: int, base: int, sender: string) -> int
    return PlayerControllerGetSlotTargetFromPointerMessage(message, base, sender)
  end

  function PlayerControllerGetSlotTargetFromPointerMessage(message: int, base: int, sender: string) -> int
    return inv_overhaul_inventory_input_controller.PlayerInputGetSlotTargetFromPointerMessage(
      message, base, sender, ReadVisibleSlots(),
      ReadWindowWidth(), c_iSlotDropInset)
  end

  function ChangePage(delta: int) -> void
    inv_overhaul_inventory_paging.Change(
      delta, c_iInventoryCapacity, ReadVisibleSlots() + 0)
    inv_overhaul_inventory_sounds.InventorySoundsPlayAction()
    UpdateSlots()
  end

  function PlayerControllerGetDragPageHoverAction(sender: string) -> int
    return inv_overhaul_inventory_input_controller.PlayerInputGetDragPageHoverAction(
      sender, PlayerControllerGetMaxPage())
  end

  function BeginDragPageHover(sender: string) -> void
    if !inv_overhaul_inventory_drag.PlayerDragIsActive() then return end
    local action: int = PlayerControllerGetDragPageHoverAction(sender)
    if action == 0 then return end
    if !inv_overhaul_inventory_drag.PlayerDragBeginPageHover(action) then return end
    native.Trace("inv_overhaul_inventory page-hover begin sender=" + sender + " action=" + action +
      " source=" + inv_overhaul_inventory_drag.GetSourceSlot())
  end

  function CancelDragPageHover(action: int) -> void
    if !inv_overhaul_inventory_drag.PlayerDragCanCancelPageHover(action) then return end
    local currentAction: int = inv_overhaul_inventory_drag.PlayerDragGetPageHoverAction()
    if currentAction != 0 then
      native.Trace("inv_overhaul_inventory page-hover cancel action=" + currentAction + " elapsed=" +
        inv_overhaul_inventory_drag.PlayerDragGetPageHoverElapsed())
    end
    inv_overhaul_inventory_drag.PlayerDragClearPageHover()
  end

  function UpdateDragPageHover(delta: float) -> void
    local action: int = inv_overhaul_inventory_drag.PlayerDragGetPageHoverAction()
    if !inv_overhaul_inventory_drag.PlayerDragIsActive() || action == 0 then return end
    if !inv_overhaul_inventory_paging.CanMove(
      action, PlayerControllerGetMaxPage()) then
      CancelDragPageHover(action)
      return
    end
    action = inv_overhaul_inventory_drag.PlayerDragAdvancePageHover(delta)
    if action == 0 then return end
    SetHighlightedSlot(-1)
    native.Trace("inv_overhaul_inventory page-hover switch action=" + action +
      " page=" + ReadPage())
    ChangePage(action)
  end

  function SyncDragPageHoverFromCursor() -> void
    if !inv_overhaul_inventory_drag.PlayerDragIsActive() then
      CancelDragPageHover(0)
      return
    end
    local hoverTarget: int = 0
    native.GetVariable("inv_overhaul_inventory_page_hover", hoverTarget)
    local action: int = inv_overhaul_inventory_paging.GetCursorHoverAction(
      hoverTarget, PlayerControllerGetMaxPage())
    if action == 0 then
      CancelDragPageHover(0)
      return
    end
    if !inv_overhaul_inventory_drag.PlayerDragBeginPageHover(action) then return end
    native.Trace("inv_overhaul_inventory page-hover cursor target=" + hoverTarget +
      " action=" + action + " page=" + ReadPage())
  end

  function RunFramePreparationStage(delta: float) -> void
    if inv_overhaul_inventory_view.ClaimChildWindowsReady() then
      if inv_overhaul_inventory_view.DebugLoggingEnabled() then native.Trace("INV_OVERHAUL_PERF_STEP first_update_begin") end
      if inv_overhaul_inventory_view.DebugLoggingEnabled() then native.Trace("INV_OVERHAUL_PERF_PHASE child_ready") end
      lastLayoutWidth = -1
      lastLayoutHeight = -1
      lastLayoutSlots = -1
      PlayerControllerUpdateLayout()
      PlayerControllerUpdatePageControls()
      PlayerControllerUpdateMoney()
      if inv_overhaul_inventory_view.DebugLoggingEnabled() then native.Trace("INV_OVERHAUL_PERF_STEP first_update_children_ready") end
    end
    inv_overhaul_inventory_tooltip.AdvanceSuspension(delta)
    if inventoryFullMessageCooldown > 0 then
      inventoryFullMessageCooldown = inventoryFullMessageCooldown - delta
      if inventoryFullMessageCooldown < 0 then inventoryFullMessageCooldown = 0 end
    end
    PlayerControllerUpdateLayout()
  end

  function RunMetadataAndLoadingStage(delta: float) -> void
    if inv_overhaul_inventory_view.AdvanceMetadataDelay(delta) then
        if inv_overhaul_inventory_view.GetMetadataStage() == 0 then
          if inv_overhaul_inventory_view.DebugLoggingEnabled() then native.Trace("INV_OVERHAUL_PERF_STEP layout_batch_begin") end
          if ContinueIncrementalLayoutLoad() then
            inv_overhaul_inventory_view.AdvanceMetadataStage()
          end
          if inv_overhaul_inventory_view.DebugLoggingEnabled() then native.Trace("INV_OVERHAUL_PERF_STEP layout_batch_end") end
        end
        if inv_overhaul_inventory_view.GetMetadataStage() == 1 then
          if inv_overhaul_inventory_view.DebugLoggingEnabled() then native.Trace("INV_OVERHAUL_PERF_STEP snapshot_begin") end
          InitializePersistentBackpackSnapshot()
          inv_overhaul_inventory_view.AdvanceMetadataStage()
          if inv_overhaul_inventory_view.DebugLoggingEnabled() then native.Trace("INV_OVERHAUL_PERF_STEP snapshot_end") end
        end
        if inv_overhaul_inventory_view.GetMetadataStage() == 2 then
          if inv_overhaul_inventory_view.DebugLoggingEnabled() then native.Trace("INV_OVERHAUL_PERF_STEP free_order_begin") end
          OrderFreeCellsByDisplayForCount(ReadLastBackpackItemCount() + 0)
          if inv_overhaul_inventory_view.DebugLoggingEnabled() then native.Trace("INV_OVERHAUL_PERF_STEP free_order_end") end
          if inv_overhaul_inventory_view.DebugLoggingEnabled() then native.Trace("INV_OVERHAUL_PERF_PHASE layout_ready") end
          inv_overhaul_inventory_view.CompleteMetadata()
          if inv_overhaul_inventory_view.DebugLoggingEnabled() then native.Trace("INV_OVERHAUL_PERF_STEP initial_load_begin") end
          PlayerControllerBeginInitialSlotLoad()
          if inv_overhaul_inventory_view.DebugLoggingEnabled() then native.Trace("INV_OVERHAUL_PERF_STEP initial_load_end") end
        end
    end
    if inv_overhaul_inventory_view.IsInitialLoadActive() then
      if inv_overhaul_inventory_view.AdvanceSpriteCooldown(delta) then
        PlayerControllerContinueInitialSlotLoad()
        if inv_overhaul_inventory_view.IsInitialLoadActive() then
          inv_overhaul_inventory_view.ResetSpriteCooldown()
        end
      end
    end
  end

  function RunPersistenceAndRefreshStage(delta: float) -> void
    ContinueLayoutSave()
    inventoryPollCooldown = inventoryPollCooldown - delta
    if inventoryPollCooldown <= 0 then
      inventoryPollCooldown = 0.25
      PlayerControllerUpdateMoney()
      local currentGeneration: int = 0
      native.GetVariable("inv_overhaul_inventory_content_generation", currentGeneration)
      ReconcileInventoryContentGeneration(currentGeneration)
    end
    if deferredInventoryRefresh > 0 then
      deferredInventoryRefresh = deferredInventoryRefresh - delta
      if deferredInventoryRefresh <= 0 then
        UpdateSlots()
        native.Trace("inv_overhaul_inventory deferred item-use refresh")
      end
    end
  end

  function RunDragHoverStage(delta: float) -> void
    SyncDragPageHoverFromCursor()
    UpdateDragPageHover(delta)
  end

  function PlayerControllerStartPanelPointerDrag(x: int, y: int) -> void
    if inv_overhaul_inventory_drag.PlayerDragIsActive() then return end

    local equipmentTarget: int = FindEquipmentTargetAt(x, y)
    if equipmentTarget >= 0 && ResolveEquipmentTarget(equipmentTarget) >= 0 then
      StartDragAction(equipmentTarget, "panel_background")
      return
    end

    local backpackSlot: int = FindBackpackSlotAt(x, y)
    if backpackSlot >= 0 && PlayerControllerHandleModifiedDrop(backpackSlot) then return end
    if backpackSlot >= 0 && PlayerControllerResolveVisibleSlot(backpackSlot) >= 0 then
      StartDragAction(backpackSlot, "panel_background")
    end
  end

  function PlayerControllerGetPageControlX() -> int
    return inv_overhaul_inventory_input_controller.PlayerInputGetPageControlX(
      ReadWindowWidth())
  end

  function PlayerControllerGetPageControlY() -> int
    return inv_overhaul_inventory_input_controller.PlayerInputGetPageControlY(
      ReadWindowWidth(), GetBranch())
  end

  function PlayerControllerIsInsideQuickslotHelp(x: int, y: int) -> bool
    return inv_overhaul_inventory_input_controller.PlayerInputIsInsideQuickslotHelp(
      ReadWindowWidth(), x, y)
  end

  function PlayerControllerIsInsidePlayerPaging(x: int, y: int) -> bool
    return inv_overhaul_inventory_input_controller.PlayerInputIsInsidePlayerPaging(
      ReadWindowWidth(), GetBranch(),
      PlayerControllerGetMaxPage(), x, y)
  end

  function UpdatePanelTooltip(x: int, y: int) -> void
    if inv_overhaul_inventory_tooltip.IsSuspended() then
      inv_overhaul_inventory_tooltip.InterfaceTooltipClear()
      return
    end
    if inv_overhaul_inventory_drag.PlayerDragIsActive() then
      inv_overhaul_inventory_tooltip.InterfaceTooltipClear()
      return
    end
    if PlayerControllerIsInsideQuickslotHelp(x, y) then
      inv_overhaul_inventory_tooltip.ShowText(
        inv_overhaul_inventory_protocol.TargetQuickslotHelp, 1407)
      return
    end
    if PlayerControllerIsInsidePlayerPaging(x, y) then
      inv_overhaul_inventory_tooltip.ShowText(
        inv_overhaul_inventory_protocol.TargetPaging, 1404)
      return
    end
    if PlayerControllerIsInsideSpecialTarget(
      inv_overhaul_inventory_protocol.TargetDrop, x, y) then
      inv_overhaul_inventory_tooltip.ShowText(
        inv_overhaul_inventory_protocol.TargetDrop, 1401)
      return
    end
    if PlayerControllerIsInsideMoney(x, y) then
      inv_overhaul_inventory_tooltip.ShowMoney()
      return
    end

    local target: int = FindBackpackSlotAt(x, y)
    local reference: int = -1
    if target >= 0 then
      reference = PlayerControllerResolveVisibleSlot(target)
    else
      target = FindEquipmentTargetAt(x, y)
      if target >= 0 then reference = ResolveEquipmentTarget(target) end
    end

    if reference < 0 then
      inv_overhaul_inventory_tooltip.InterfaceTooltipClear()
      return
    end
    if inv_overhaul_inventory_tooltip.GetTarget() == target then return end

    local container: object = PlayerControllerGetPlayerContainer()
    local item: object
    local category: int =
      inv_overhaul_inventory_items.DecodeReferenceCategory(reference)
    local index: int =
      inv_overhaul_inventory_items.DecodeReferenceIndex(reference)
    container->GetItem(item, index, category)
    inv_overhaul_inventory_tooltip.ShowItem(target, item)
  end

  function PlayerControllerHandlePanelPointer(message: int) -> void
    if message >= inv_overhaul_inventory_protocol.PointerLeaveBase then
      inv_overhaul_inventory_tooltip.InterfaceTooltipClear()
      native.SendMessage(-95, "page_prev")
      native.SendMessage(-95, "page_next")
      return
    end

    local base: int =
      inv_overhaul_inventory_input_controller.DecodePanelPointerBase(message)
    local action: int =
      inv_overhaul_inventory_input_controller.DecodePanelPointerAction(message)

    local x: int = inv_overhaul_inventory_protocol.InterfaceProtocolDecodePanelPointerX(message, base)
    local y: int = inv_overhaul_inventory_protocol.InterfaceProtocolDecodePanelPointerY(message, base)

    if action == 0 then
      UpdatePageControlHover(x, y)
      UpdatePanelTooltip(x, y)
    end

    if action == 1 then
      inv_overhaul_inventory_tooltip.InterfaceTooltipClear()
      if HandlePageControlAt(x, y) then return end
      PlayerControllerStartPanelPointerDrag(x, y)
      return
    end

    if action == 2 then
      local equipmentTarget: int = FindEquipmentTargetAt(x, y)
      if equipmentTarget >= 0 then
        UnequipTarget(equipmentTarget, "panel right click")
        return
      end
      local backpackSlot: int = FindBackpackSlotAt(x, y)
      if backpackSlot >= 0 then
        HandleSlotMessage(1, inv_overhaul_inventory_protocol.GetSlotWindowName(backpackSlot))
      end
      return
    end

    local targetSlot: int = FindSlotAt(x, y)
    if action == 3 then
      if inv_overhaul_inventory_drag.PlayerDragIsActive() then
        ApplyPointerSlot(targetSlot)
        FinishLeftAction(targetSlot)
      end
      return
    end

    if inv_overhaul_inventory_drag.PlayerDragIsActive() then ApplyPointerSlot(targetSlot) end
  end

  function HandlePageControlAt(x: int, y: int) -> bool
    if visibleSlots >= c_iInventoryCapacity then return false end

    local controlX: int = PlayerControllerGetPageControlX()
    local controlY: int = PlayerControllerGetPageControlY()
    local action: int = inv_overhaul_inventory_paging.GetControlAction(
      x, y, controlX, controlY)
    if action == 0 then return false end
    if inv_overhaul_inventory_paging.CanMove(
      action, PlayerControllerGetMaxPage()) then ChangePage(action) end
    return true
  end

  function UpdatePageControlHover(x: int, y: int) -> void
    if PlayerControllerGetMaxPage() <= 0 then return end
    local controlX: int = PlayerControllerGetPageControlX()
    local controlY: int = PlayerControllerGetPageControlY()
    local maxPage: int = PlayerControllerGetMaxPage()
    if inv_overhaul_inventory_paging.IsControlHovered(
      -1, x, y, controlX, controlY, maxPage) then
      native.SendMessage(-94, "page_prev")
    else
      native.SendMessage(-95, "page_prev")
    end
    if inv_overhaul_inventory_paging.IsControlHovered(
      1, x, y, controlX, controlY, maxPage) then
      native.SendMessage(-94, "page_next")
    else
      native.SendMessage(-95, "page_next")
    end
  end

  function HandleGlobalProtocolMessage(message: int, sender: string) -> bool
    if message == inv_overhaul_inventory_protocol.QuickslotHelpHover && sender == "panel_background" then
      inv_overhaul_inventory_tooltip.ShowText(
        inv_overhaul_inventory_protocol.TargetQuickslotHelp, 1407)
      return true
    end
    if message == inv_overhaul_inventory_protocol.GridRendererReady then
      inv_overhaul_inventory_view.MarkRendererReady()
      TryWarmStartGrid()
      return true
    end
    if message == inv_overhaul_inventory_protocol.PageHoverEnter then
      BeginDragPageHover(sender)
      return true
    end
    if message == inv_overhaul_inventory_protocol.PageHoverLeave then
      CancelDragPageHover(PlayerControllerGetDragPageHoverAction(sender))
      return true
    end
    if sender == "panel_background" && message >= inv_overhaul_inventory_protocol.PointerMoveBase then
      PlayerControllerHandlePanelPointer(message)
      return true
    end
    return false
  end

  function HandleEquipmentProtocolMessage(message: int, sender: string) -> bool
    if message == -43 then
      local unequipTarget: int = inv_overhaul_inventory_protocol.GetSpecialTargetBySender(sender)
      UnequipTarget(unequipTarget, "right click")
      return true
    end

    if message <= -60 && message >= -64 then
      local dollSource: int =
        inv_overhaul_inventory_protocol.GetDollTargetBySourceMessage(message, -60)
      if ResolveEquipmentTarget(dollSource) >= 0 then
        StartDragAction(dollSource, "character_doll")
      end
      return true
    end

    if message <= -70 && message >= -74 then
      local dollTarget: int =
        inv_overhaul_inventory_protocol.GetDollTargetBySourceMessage(message, -70)
      UnequipTarget(dollTarget, "doll right click")
      return true
    end

    if message == -40 then
      if inv_overhaul_inventory_drag.PlayerDragIsActive() then
        local specialTarget: int = inv_overhaul_inventory_protocol.GetSpecialTargetBySender(sender)
        if specialTarget >= 0 && IsSpecialTargetCompatible(specialTarget) then
          inv_overhaul_inventory_drag.SetHoverTarget(specialTarget)
          ApplyPointerSlot(specialTarget)
        else
          inv_overhaul_inventory_drag.SetHoverTarget(-1)
          ApplyPointerSlot(-1)
        end
      else
        SetHighlightedSlot(inv_overhaul_inventory_protocol.GetSpecialTargetBySender(sender))
      end
      return true
    end

    if message <= -50 && message >= -54 then
      if inv_overhaul_inventory_drag.PlayerDragIsActive() then
        local dollTarget: int = inv_overhaul_inventory_protocol.GetDollTargetByHoverMessage(message)
        if dollTarget >= 0 && IsSpecialTargetCompatible(dollTarget) then
          inv_overhaul_inventory_drag.SetHoverTarget(dollTarget)
          ApplyPointerSlot(dollTarget)
        else
          inv_overhaul_inventory_drag.SetHoverTarget(-1)
          ApplyPointerSlot(-1)
        end
      end
      return true
    end

    if message == -42 then
      if inv_overhaul_inventory_drag.PlayerDragIsActive() then
        local releaseTarget: int = inv_overhaul_inventory_protocol.GetSpecialTargetBySender(sender)
        if releaseTarget >= 0 && IsSpecialTargetCompatible(releaseTarget) then
          ApplyPointerSlot(releaseTarget)
          FinishLeftAction(releaseTarget)
        else
          CancelDragAction()
        end
      end
      return true
    end

    if message == -41 then
      if inv_overhaul_inventory_drag.PlayerDragIsActive() then
        inv_overhaul_inventory_drag.SetHoverTarget(-1)
        ApplyPointerSlot(-1)
      else
        SetHighlightedSlot(-1)
      end
      return true
    end
    return false
  end

  function HandlePagingProtocolMessage(message: int, sender: string) -> bool
    if sender == "page_prev" && message == 0 then
      if inv_overhaul_inventory_paging.CanMove(
        -1, PlayerControllerGetMaxPage()) then ChangePage(-1) end
      return true
    end
    if sender == "page_next" && message == 0 then
      if inv_overhaul_inventory_paging.CanMove(
        1, PlayerControllerGetMaxPage()) then ChangePage(1) end
      return true
    end
    return false
  end

  function HandleSlotPointerProtocolMessage(message: int, sender: string) -> bool
    if message >= c_iDragEndMessageBase then
      local targetSlot: int = GetCurrentDropSlot(message, c_iDragEndMessageBase, sender)
      ApplyPointerSlot(targetSlot)
      FinishLeftAction(targetSlot)
      return true
    end

    if message >= c_iReleaseMessageBase then
      local targetSlot: int = GetCurrentDropSlot(message, c_iReleaseMessageBase, sender)
      ApplyPointerSlot(targetSlot)
      FinishLeftAction(targetSlot)
      return true
    end

    if message >= c_iHoverMessageBase then
      if inv_overhaul_inventory_drag.PlayerDragIsActive() then
        local hoverTarget: int =
          PlayerControllerGetSlotTargetFromPointerMessage(message, c_iHoverMessageBase, sender)
        inv_overhaul_inventory_drag.SetHoverTarget(hoverTarget)
        ApplyPointerSlot(hoverTarget)
      else
        SetHighlightedSlot(PlayerControllerGetSlotTargetFromPointerMessage(message, c_iHoverMessageBase, sender))
      end
      return true
    end
    return false
  end

  function PlayerControllerHandleDragLifecycleMessage(message: int, sender: string) -> bool
    if message == 2 || message == 3 then
      local source: int = GetDragSourceBySender(sender)
      if PlayerControllerHandleModifiedDrop(source) then return true end
      StartDragAction(source, sender)
      return true
    end

    if message == 4 then
      native.Trace("inv_overhaul_inventory system drag message 4 ignored")
      return true
    end

    if message == 5 then
      native.Trace("inv_overhaul_inventory system drag message 5 ignored")
      return true
    end

    if message == 6 then return true end

    if message == 7 then
      if inv_overhaul_inventory_drag.PlayerDragIsActive() then
        inv_overhaul_inventory_drag.SetHoverTarget(-1)
      end
      SetHighlightedSlot(-1)
      return true
    end

    if message == 8 then
      FinishLeftAction(ReadHighlightedSlot() + 0)
      return true
    end
    return false
  end

  function PlayerControllerHandleRegularSlotMessage(
    message: int,
    sender: string,
    data: object) -> bool
    if message != 0 && message != 1 then return false end
    if data then return true end
    HandleSlotMessage(message, sender)
    return true
  end

  function OnUIMessage(message: int, sender: string, data: object) -> void
    if HandleGlobalProtocolMessage(message, sender) then return end
    if HandleEquipmentProtocolMessage(message, sender) then return end
    if HandlePagingProtocolMessage(message, sender) then return end
    if HandleSlotPointerProtocolMessage(message, sender) then return end
    if PlayerControllerHandleDragLifecycleMessage(message, sender) then return end
    PlayerControllerHandleRegularSlotMessage(message, sender, data)
  end
  function OnLButtonDown(x: int, y: int) -> void
    if HandlePageControlAt(x, y) then return end
    local equipmentTarget: int = FindEquipmentTargetAt(x, y)
    if equipmentTarget >= 0 && ResolveEquipmentTarget(equipmentTarget) >= 0 then
      StartDragAction(equipmentTarget, "root")
      return
    end
  end


  function OnRButtonDown(x: int, y: int) -> void
    local equipmentTarget: int = FindEquipmentTargetAt(x, y)
    if equipmentTarget >= 0 then
      UnequipTarget(equipmentTarget, "root right click")
    end
  end

  function OnMouseMove(x: int, y: int) -> void
    if inv_overhaul_inventory_drag.PlayerDragIsActive() then
      local slot: int = UpdatePointerSlot(x, y)
      ApplyPointerSlot(slot)
    end
  end

  function OnMouseLeave() -> void
    if inv_overhaul_inventory_drag.PlayerDragIsActive() then
      SetHighlightedSlot(-1)
    end
  end

  function OnLButtonUp(x: int, y: int) -> void
    if inv_overhaul_inventory_drag.PlayerDragIsActive() then
      local targetSlot: int = UpdatePointerSlot(x, y)
      ApplyPointerSlot(targetSlot)
      FinishLeftAction(targetSlot)
    end
  end

  function CloseInventoryWindow() -> void
    if closingWindow then return end
    closingWindow = true
    native.SetNeedUpdate(false)
    native.SetVariable("inv_overhaul_inventory_drag_item", -1)
    native.SetVariable("inv_overhaul_inventory_page_hover", 0)
    native.SendMessage(-200, "panel_background")
    native.SendMessage(-200, "character_doll")
    native.DestroyWindow()
  end

  function OnChar(char: int) -> void
    if char >= 48 && char <= 57 then return end
    native.Trace("inv_overhaul_inventory OnChar close")
    if inv_overhaul_inventory_layout_runtime.HasQueuedSave() then
      SaveLayoutVariables()
    end
    PersistCurrentBackpackSnapshot()
    CloseInventoryWindow()
  end

  function OnKeyDown(key: int) -> void
    native.Trace("inv_overhaul_inventory OnKeyDown " + key)
    if key == c_iVKShift then shiftHeld = true end
    if key == c_iVKControl then controlHeld = true end
    local quickslot: int = GetQuickslotByKey(key)
    if quickslot > 0 then
      PlayerControllerAssignHoveredQuickslot(quickslot)
      return
    end
    if key == 27 || key == 73 || key == 105 then
      if inv_overhaul_inventory_layout_runtime.HasQueuedSave() then
        SaveLayoutVariables()
      end
      PersistCurrentBackpackSnapshot()
      CloseInventoryWindow()
    end
  end

  function OnKeyUp(key: int) -> void
    if key == c_iVKShift then shiftHeld = false end
    if key == c_iVKControl then controlHeld = false end
  end
end
