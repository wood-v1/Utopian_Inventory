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

  function InventoryControllerInitialize() -> void
    inv_overhaul_inventory_view.InventoryViewInitializeState()
    if inv_overhaul_inventory_view.InventoryViewDiagnosticsEnabled() then
      native.Trace("INV_OVERHAUL_PERF_STEP root_init_begin")
    end
    native.Trace("INV_OVERHAUL_INVENTORY_VERSION " + c_sScriptVersion + " screen=inventory")
    inv_overhaul_inventory_paging.InventoryPagingInitialize()
    inv_overhaul_inventory_drag.InventoryDragInitializeState()
    lastLayoutWidth = -1
    lastLayoutHeight = -1
    lastLayoutSlots = -1
    inv_overhaul_inventory_tooltip.InventoryTooltipInitializeState()
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
    if inv_overhaul_inventory_view.InventoryViewDiagnosticsEnabled() then
      local warmed: int = 0
      native.GetVariable("inv_overhaul_ui_cache_loaded", warmed)
      native.Trace("INV_OVERHAUL_PERF_PHASE cache_snapshot warmed=" + warmed)
    end
    inv_overhaul_inventory_quickslot_bindings.InventoryQuickslotInitializeState()
    InventoryControllerInitializeQuickslotBindings()
    InventoryControllerRefreshQuickslotCache()
    if inv_overhaul_inventory_view.InventoryViewDiagnosticsEnabled() then native.Trace("INV_OVERHAUL_PERF_STEP root_quickslots_ready") end
    inv_overhaul_inventory_tooltip.InventoryTooltipInitializeMoneyItem()
    inv_overhaul_inventory_snapshot.InventorySnapshotInitializeState()
    inv_overhaul_inventory_items.InventoryItemsInitializeProjection()
    inv_overhaul_inventory_equipment.InventoryEquipmentInitializeCache()
    InventoryControllerInitSlotOrder()
    if inv_overhaul_inventory_view.InventoryViewDiagnosticsEnabled() then native.Trace("INV_OVERHAUL_PERF_STEP root_vectors_ready") end
    InventoryControllerUpdateLayout()
    native.SetVariable("inv_overhaul_inventory_drag_item", -1)
    native.SetVariable("inv_overhaul_inventory_page_hover", 0)
    native.SetCursor("inv_overhaul_inventory")
    native.ShowCursor()
    native.CaptureKeyboard()
    native.SetOwnerDraw(false)
    native.SetNeedUpdate(true)
    if inv_overhaul_inventory_view.InventoryViewDiagnosticsEnabled() then native.Trace("INV_OVERHAUL_PERF_STEP root_before_process_events") end
    native.ProcessEvents()
    if inv_overhaul_inventory_view.InventoryViewDiagnosticsEnabled() then native.Trace("INV_OVERHAUL_PERF_STEP root_init_end") end
  end

  -- The compiler cannot safely lower a module global used directly as an
  -- argument of another Lua/DSL function.  These accessors keep controller
  -- state module-owned while ensuring call arguments are ordinary values.
  function InventoryControllerReadWindowWidth() -> int return windowWidth end
  function InventoryControllerReadVisibleSlots() -> int return visibleSlots end
  function InventoryControllerReadPage() -> int
    return inv_overhaul_inventory_paging.InventoryPagingGetPage()
  end
  function InventoryControllerReadDragSourceSlot() -> int
    return inv_overhaul_inventory_drag.InventoryDragGetSourceSlot()
  end
  function InventoryControllerReadDragSourceCell() -> int
    return inv_overhaul_inventory_drag.InventoryDragGetSourceCell()
  end
  function InventoryControllerReadHighlightedSlot() -> int
    return inv_overhaul_inventory_drag.InventoryDragGetHighlightedTarget()
  end
  function InventoryControllerReadDragItemCategory() -> int
    return inv_overhaul_inventory_drag.InventoryDragGetItemCategory()
  end
  function InventoryControllerReadDragItemIndex() -> int
    return inv_overhaul_inventory_drag.InventoryDragGetItemIndex()
  end
  function InventoryControllerReadDragItemGroup() -> int
    return inv_overhaul_inventory_drag.InventoryDragGetItemGroup()
  end
  function InventoryControllerReadDragItemIsWeapon() -> bool
    return inv_overhaul_inventory_drag.InventoryDragGetItemIsWeapon()
  end
  function InventoryControllerReadLastBackpackItemCount() -> int
    return inv_overhaul_inventory_snapshot.InventorySnapshotGetLastBackpackItemCount()
  end
  function InventoryControllerReadLayoutLoadStartCell() -> int return layoutLoadStartCell end
  function InventoryControllerReadPerfCacheEpoch() -> int
    return inv_overhaul_inventory_view.InventoryViewGetCacheEpoch()
  end

  function InventoryControllerInitSlotOrder() -> void
    inv_overhaul_inventory_layout_runtime.InventoryLayoutRuntimeInitialize()
  end

  function InventoryControllerGetBranch() -> int
    local branch: int = -1
    native.GetVariable("branch", branch)
    return branch
  end

  function InventoryControllerGetOrderValue(slot: int) -> int
    return inv_overhaul_inventory_layout_runtime.InventoryLayoutRuntimeGetOrderValue(slot)
  end

  function InventoryControllerLoadLayoutVariables() -> void
    inv_overhaul_inventory_layout_runtime.InventoryLayoutRuntimeLoad()
  end

  function InventoryControllerContinueIncrementalLayoutLoad() -> bool
    local complete: bool = inv_overhaul_inventory_layout_runtime.InventoryLayoutRuntimeContinueIncrementalLoad(InventoryControllerReadLayoutLoadStartCell() + 0)
    if complete then layoutLoadStartCell = 0 end
    return complete
  end

  function InventoryControllerSaveLayoutVariables() -> void
    inv_overhaul_inventory_layout_runtime.InventoryLayoutRuntimeSaveAll()
  end

  function InventoryControllerQueueLayoutSave() -> void
    inv_overhaul_inventory_layout_runtime.InventoryLayoutRuntimeQueueSave()
  end

  function InventoryControllerContinueLayoutSave() -> void
    inv_overhaul_inventory_layout_runtime.InventoryLayoutRuntimeContinueQueuedSave()
  end

  function InventoryControllerOrderFreeCellsByDisplayForCount(itemCount: int) -> void
    if inv_overhaul_inventory_layout_runtime.InventoryLayoutRuntimeOrderFreeCellsByDisplay(itemCount, InventoryControllerReadVisibleSlots() + 0) then InventoryControllerQueueLayoutSave() end
  end

  function InventoryControllerGetPlayerContainer() -> object
    return inv_overhaul_inventory_items.InventoryItemsGetPlayerContainer()
  end

  function InventoryControllerBeginDragCursor(slot: int) -> void
    native.SetVariable("inv_overhaul_inventory_drag_item", -1)
    inv_overhaul_inventory_drag.InventoryDragClearItem()
    local reference: int = InventoryControllerResolveDragSource(slot)
    if reference < 0 then return end
    local itemCategory: int =
      inv_overhaul_inventory_items.InventoryItemsDecodeReferenceCategory(reference)
    local itemIndex: int =
      inv_overhaul_inventory_items.InventoryItemsDecodeReferenceIndex(reference)

    local container: object = InventoryControllerGetPlayerContainer()
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
    inv_overhaul_inventory_drag.InventoryDragBeginItem(
      itemID, itemCategory, itemIndex, itemGroup, itemIsWeapon)
    native.SetVariable("inv_overhaul_inventory_drag_item", itemID)
  end

  function InventoryControllerEndDragCursor() -> void
    native.SetVariable("inv_overhaul_inventory_drag_item", -1)
    native.SetVariable("inv_overhaul_inventory_page_hover", 0)
    inv_overhaul_inventory_drag.InventoryDragClearItem()
  end

  function InventoryControllerConfigureSlotRenderSize() -> void
    local sizeMessage: int = -27
    local equipSizeMessage: int = -27
    if windowWidth >= 1200 then sizeMessage = -26 end
    if windowWidth >= 1900 then equipSizeMessage = -28 end
    native.SendMessage(equipSizeMessage, "equip_head")
    native.SendMessage(equipSizeMessage, "equip_body")
    native.SendMessage(equipSizeMessage, "equip_hands")
    native.SendMessage(equipSizeMessage, "equip_feet")
    native.SendMessage(equipSizeMessage, "equip_weapon")
    native.SendMessage(sizeMessage, "drop_slot")
    native.SendMessage(sizeMessage, "money")
  end

  function InventoryControllerUpdateLayout() -> void
    local currentWidth: int
    local currentHeight: int

    native.GetWindowSize(currentWidth, currentHeight)
    if currentWidth <= 0 || currentHeight <= 0 then
      native.GetScreenSize(currentWidth, currentHeight)
    end

    windowWidth = currentWidth
    windowHeight = currentHeight
    visibleSlots = inv_overhaul_inventory_geometry.InventoryGeometryGetVisibleSlots(InventoryControllerReadWindowWidth() + 0)
    if windowWidth != lastLayoutWidth || windowHeight != lastLayoutHeight || visibleSlots != lastLayoutSlots then
      native.Trace("inv_overhaul_inventory layout window=" + windowWidth + "x" + windowHeight + " slots=" + visibleSlots)
      if inv_overhaul_inventory_view.InventoryViewChildWindowsReady() then
        native.SendMessage(currentWidth, "character_doll")
        native.SendMessage(5000 + currentHeight, "character_doll")
        native.SendMessage(currentWidth, "panel_background")
        native.SendMessage(5000 + currentHeight, "panel_background")
        InventoryControllerConfigureSlotRenderSize()
      end
      lastLayoutWidth = windowWidth
      lastLayoutHeight = windowHeight
      lastLayoutSlots = visibleSlots
    end
  end

  function InventoryControllerSendGridRendererState(slot: int, operation: int, value: int, data: object) -> void
    if slot < 0 || slot >= c_iInventoryCapacity then return end
    if value < 0 then value = 0 end
    if value > 19999 then value = 19999 end
    inv_overhaul_inventory_view.InventoryViewSendGridRendererState(slot, operation, value, data)
  end

  function InventoryControllerSetGridRendererHighlight(slot: int, enabled: bool) -> void
    inv_overhaul_inventory_view.InventoryViewSetGridRendererHighlight(slot, enabled)
  end

  function InventoryControllerGetVisibleCell(slot: int) -> int
    return inv_overhaul_inventory_paging.InventoryPagingGetVisibleCell(
      slot, InventoryControllerReadVisibleSlots(), c_iInventoryCapacity)
  end

  function InventoryControllerGetCellForLinearSlot(linear: int) -> int
    return inv_overhaul_inventory_paging.InventoryPagingGetCellForLinearSlot(
      linear, InventoryControllerReadVisibleSlots(), c_iInventoryCapacity)
  end

  function InventoryControllerGetTargetWndName(target: int) -> string
    return inv_overhaul_inventory_view.InventoryViewGetTargetWindowName(
      target, InventoryControllerReadVisibleSlots())
  end

  function InventoryControllerIsInsideSpecialTarget(target: int, x: int, y: int) -> bool
    return inv_overhaul_inventory_geometry.InventoryGeometryIsInsideSpecialTarget(
      InventoryControllerReadWindowWidth(), InventoryControllerGetBranch(), target, x, y)
  end

  function InventoryControllerIsInsideMoney(x: int, y: int) -> bool
    return inv_overhaul_inventory_geometry.InventoryGeometryIsInsideMoney(
      InventoryControllerReadWindowWidth(), InventoryControllerGetBranch(), x, y)
  end

  function InventoryControllerFindSpecialTargetAt(x: int, y: int) -> int
    if inv_overhaul_inventory_drag.InventoryDragGetItemCategory() == c_iCWeapon &&
      inv_overhaul_inventory_drag.InventoryDragGetItemIsWeapon() then
      if InventoryControllerIsInsideSpecialTarget(inv_overhaul_inventory_protocol.TargetWeapon, x, y) then
        return inv_overhaul_inventory_protocol.TargetWeapon
      end
    end

    local itemGroup: int = inv_overhaul_inventory_drag.InventoryDragGetItemGroup()
    if inv_overhaul_inventory_drag.InventoryDragGetItemCategory() == c_iCClothes &&
      itemGroup >= 1 && itemGroup <= 4 then
      local clothesTarget: int = inv_overhaul_inventory_protocol.TargetClothesBase + itemGroup
      if InventoryControllerIsInsideSpecialTarget(clothesTarget, x, y) then
        return clothesTarget
      end
    end

    if InventoryControllerIsInsideSpecialTarget(inv_overhaul_inventory_protocol.TargetDrop, x, y) then
      return inv_overhaul_inventory_protocol.TargetDrop
    end
    return -1
  end

  function InventoryControllerFindEquipmentTargetAt(x: int, y: int) -> int
    if InventoryControllerIsInsideSpecialTarget(inv_overhaul_inventory_protocol.TargetWeapon, x, y) then return inv_overhaul_inventory_protocol.TargetWeapon end
    for group = 1, 4 do
      local target: int = inv_overhaul_inventory_protocol.TargetClothesBase + group
      if InventoryControllerIsInsideSpecialTarget(target, x, y) then return target end
    end
    return -1
  end

  function InventoryControllerGetBackpackItemCount() -> int
    return inv_overhaul_inventory_items.InventoryItemsGetBackpackCount()
  end

  function InventoryControllerLoadPersistentBackpackSnapshot() -> bool
    return inv_overhaul_inventory_snapshot.InventorySnapshotLoadPersistent()
  end

  function InventoryControllerCanReusePersistentBackpackSnapshot() -> bool
    return inv_overhaul_inventory_snapshot.InventorySnapshotCanReusePersistent()
  end

  function InventoryControllerSavePersistentBackpackSnapshot() -> void
    inv_overhaul_inventory_snapshot.InventorySnapshotSavePersistent()
  end

  function InventoryControllerCopyCurrentBackpackSnapshot(newCount: int) -> void
    inv_overhaul_inventory_snapshot.InventorySnapshotCopyCurrent(newCount)
  end

  function InventoryControllerBackpackSnapshotDiffers(newCount: int) -> bool
    return inv_overhaul_inventory_snapshot.InventorySnapshotDiffers(newCount)
  end

  function InventoryControllerPersistCurrentBackpackSnapshot() -> void
    inv_overhaul_inventory_snapshot.InventorySnapshotPersistCurrent()
  end

  function InventoryControllerReconcileInventoryContentGeneration(currentGeneration: int) -> bool
    if currentGeneration == observedContentGeneration then return false end

    -- A category/index captured by BeginDragCursor is no longer trustworthy
    -- after any externally published inventory mutation.  Cancel before the
    -- snapshot and index caches are rebuilt, then acknowledge the generation
    -- only after the persistent snapshot reflects the reconciled contents.
    if inv_overhaul_inventory_drag.InventoryDragIsActive() then InventoryControllerCancelDragAction() end
    local currentBackpackCount: int =
      inv_overhaul_inventory_snapshot.InventorySnapshotCaptureCurrentCount()
    if InventoryControllerBackpackSnapshotDiffers(currentBackpackCount) then
      InventoryControllerReconcileBackpackSnapshot(currentBackpackCount)
      InventoryControllerUpdateSlots()
    end
    InventoryControllerSavePersistentBackpackSnapshot()
    observedContentGeneration = currentGeneration
    return true
  end

  function InventoryControllerInitializePersistentBackpackSnapshot() -> void
    if InventoryControllerCanReusePersistentBackpackSnapshot() then
      inv_overhaul_inventory_snapshot.InventorySnapshotBuildIndexCacheAndPrevious()
      inv_overhaul_inventory_snapshot.InventorySnapshotClampLastBackpackItemCount()
      return
    end
    local currentCount: int =
      inv_overhaul_inventory_snapshot.InventorySnapshotCaptureCurrentCount()
    if currentCount > c_iInventoryCapacity then currentCount = c_iInventoryCapacity end
    local loaded: bool = InventoryControllerLoadPersistentBackpackSnapshot()
    local changed: bool = loaded && InventoryControllerBackpackSnapshotDiffers(currentCount)
    if changed then
      InventoryControllerReconcileBackpackSnapshot(currentCount)
      native.Trace("inv_overhaul_inventory persistent snapshot reconciled old=" +
        InventoryControllerReadLastBackpackItemCount() +
        " current=" + currentCount)
    end
    InventoryControllerCopyCurrentBackpackSnapshot(currentCount)
    -- Persist after every fallback comparison so an older save that lacks the
    -- content-generation stamp is migrated after its stored IDs are checked.
    InventoryControllerSavePersistentBackpackSnapshot()
    if !loaded then native.Trace("inv_overhaul_inventory persistent snapshot initialized count=" + currentCount) end
    InventoryControllerBuildBackpackIndexCache()
  end

  function InventoryControllerReconcileBackpackSnapshot(newCount: int) -> void
    inv_overhaul_inventory_snapshot.InventorySnapshotReconcile(
      newCount,
      InventoryControllerReadVisibleSlots() + 0)
    InventoryControllerQueueLayoutSave()
  end

  function InventoryControllerRestoreOrderAfterEquipmentReplacement(replacedOrder: int, itemCount: int) -> bool
    local restored: bool =
      inv_overhaul_inventory_snapshot.InventorySnapshotRestoreAfterEquipmentReplacement(
        replacedOrder,
        itemCount,
        InventoryControllerReadVisibleSlots() + 0)
    if restored then InventoryControllerQueueLayoutSave() end
    return restored
  end

  function InventoryControllerRestoreOrderAfterEquipmentSelection(removedOrder: int, beforeCount: int) -> bool
    local restored: bool =
      inv_overhaul_inventory_snapshot.InventorySnapshotRestoreAfterEquipmentSelection(
        removedOrder,
        beforeCount,
        InventoryControllerReadVisibleSlots() + 0)
    if restored then InventoryControllerQueueLayoutSave() end
    return restored
  end

  function InventoryControllerShowInventoryFull() -> void
    if inventoryFullMessageCooldown > 0 then return end
    local text: object
    native.CreateIntVector(text)
    text->add(c_iInventoryFullTextID)
    native.SendWorldWndMessage(c_iWMHelpMessage, text)
    inventoryFullMessageCooldown = 1.0
  end

  function InventoryControllerGetMaxPage() -> int
    return inv_overhaul_inventory_paging.InventoryPagingGetMaxPage(
      c_iInventoryCapacity, InventoryControllerReadVisibleSlots() + 0)
  end

  function InventoryControllerClampPage() -> void
    inv_overhaul_inventory_paging.InventoryPagingClamp(
      c_iInventoryCapacity, InventoryControllerReadVisibleSlots() + 0)
  end

  function InventoryControllerUpdatePageControls() -> void
    if visibleSlots >= c_iInventoryCapacity then return end
    local maxPage: int = InventoryControllerGetMaxPage()
    local visibilityMessage: int = -93
    native.SendMessage(-112, "page_prev")
    native.SendMessage(-113, "page_next")
    if maxPage > 0 then visibilityMessage = -92 end
    native.SendMessage(visibilityMessage, "page_prev")
    native.SendMessage(visibilityMessage, "page_counter")
    native.SendMessage(visibilityMessage, "page_next")
    if maxPage <= 0 then return end
    native.SendMessage(-90, "page_prev")
    native.SendMessage(-91, "page_next")
    local currentPage: int = InventoryControllerReadPage()
    if currentPage > 0 then native.SendMessage(-97, "page_prev") else native.SendMessage(-96, "page_prev") end
    if currentPage < maxPage then native.SendMessage(-97, "page_next") else native.SendMessage(-96, "page_next") end
    native.SendMessage((currentPage + 1) * 100 + maxPage + 1, "page_counter")
  end

  function InventoryControllerResolveVisibleSlot(slot: int) -> int
    local target: int = InventoryControllerGetOrderValue(InventoryControllerGetVisibleCell(slot))
    return inv_overhaul_inventory_items.InventoryItemsResolveCachedOrdinal(target)
  end

  function InventoryControllerBuildBackpackIndexCache() -> void
    inv_overhaul_inventory_items.InventoryItemsBuildIndexCache()
  end

  function InventoryControllerBuildBackpackIndexCacheAndSnapshot() -> int
    return inv_overhaul_inventory_snapshot.InventorySnapshotBuildIndexCacheAndPrevious()
  end

  function InventoryControllerUpdateMoney() -> void
    local container: object = InventoryControllerGetPlayerContainer()
    local money: int
    container->GetProperty("money", money)
    native.SendMessage(money, "money")
  end

  function InventoryControllerInitializeQuickslotBindings() -> void
    inv_overhaul_inventory_quickslot_bindings.InventoryQuickslotInitializeBindings()
  end

  function InventoryControllerRefreshQuickslotCache() -> void
    inv_overhaul_inventory_quickslot_bindings.InventoryQuickslotRefreshCache()
  end

  function InventoryControllerGetDisplayedQuickslot(category: int, index: int, itemID: int) -> int
    return inv_overhaul_inventory_quickslot_bindings.InventoryQuickslotGetDisplayedBinding(
      category, index, itemID)
  end

  function InventoryControllerAssignQuickslot(slot: int, category: int, index: int) -> void
    if inv_overhaul_inventory_quickslot_bindings.InventoryQuickslotAssign(
      slot, category, index, true) then
      InventoryControllerUpdateSlots()
    end
  end

  function InventoryControllerGetQuickslotByKey(key: int) -> int
    return inv_overhaul_inventory_quickslot_bindings.InventoryQuickslotGetSlotByKey(key)
  end

  function InventoryControllerAssignHoveredQuickslot(slot: int) -> void
    if inv_overhaul_inventory_drag.InventoryDragIsActive() then return end
    local target: int = inv_overhaul_inventory_drag.InventoryDragGetHighlightedTarget()
    if target < 0 then
      target = inv_overhaul_inventory_tooltip.InventoryTooltipGetTarget()
    end
    local reference: int = InventoryControllerResolveDragSource(target)
    if reference >= 0 then
      InventoryControllerAssignQuickslot(
        slot,
        inv_overhaul_inventory_items.InventoryItemsDecodeReferenceCategory(reference),
        inv_overhaul_inventory_items.InventoryItemsDecodeReferenceIndex(reference))
    end
  end

  function InventoryControllerUpdateSlot(slot: int) -> void
    local container: object = InventoryControllerGetPlayerContainer()
    if InventoryControllerGetVisibleCell(slot) < 0 then
      InventoryControllerSendGridRendererState(slot, inv_overhaul_inventory_protocol.GridRendererHidden, 0, null)
    else
      local reference: int = InventoryControllerResolveVisibleSlot(slot)
      if reference >= 0 then
        local category: int =
          inv_overhaul_inventory_items.InventoryItemsDecodeReferenceCategory(reference)
        local index: int =
          inv_overhaul_inventory_items.InventoryItemsDecodeReferenceIndex(reference)
        local item: object
        local amount: int
        container->GetItem(item, index, category)
        container->GetItemAmount(amount, index, category)
        local itemID: int
        item->GetItemID(itemID)
        local quickslot: int = InventoryControllerGetDisplayedQuickslot(category, index, itemID)
        if amount > 1800 then amount = 1800 end
        InventoryControllerSendGridRendererState(slot, inv_overhaul_inventory_protocol.GridRendererItem, amount * 11 + quickslot, item)
      else
        InventoryControllerSendGridRendererState(slot, inv_overhaul_inventory_protocol.GridRendererEmpty, 0, null)
      end
    end
  end

  function InventoryControllerIsItemTexturePreloaded(itemID: int, cacheEpoch: int) -> bool
    if itemID < 0 then return false end
    if cacheEpoch > 0 then
      local itemEpoch: int = 0
      native.GetVariable("inv_overhaul_ui_cache_item_" + itemID, itemEpoch)
      if itemEpoch == cacheEpoch then return true end
    end
    local runtimeEpoch: int = 0
    local loadedEpoch: int = -1
    native.GetVariable("inv_overhaul_runtime_texture_epoch", runtimeEpoch)
    if runtimeEpoch <= 0 then return false end
    native.GetVariable("inv_overhaul_runtime_texture_item_" + itemID, loadedEpoch)
    return loadedEpoch == runtimeEpoch
  end

  function InventoryControllerMarkItemTextureLoaded(category: int, index: int) -> void
    if category < 0 || index < 0 then return end
    local runtimeEpoch: int = 0
    native.GetVariable("inv_overhaul_runtime_texture_epoch", runtimeEpoch)
    if runtimeEpoch <= 0 then return end
    local container: object = InventoryControllerGetPlayerContainer()
    local item: object
    local itemID: int = -1
    container->GetItem(item, index, category)
    if item then item->GetItemID(itemID) end
    if itemID >= 0 then
      native.SetVariable("inv_overhaul_runtime_texture_item_" + itemID, runtimeEpoch)
    end
  end

  function InventoryControllerMeasureInitialTextureCacheCoverage() -> void
    inv_overhaul_inventory_view.InventoryViewResetCacheCoverage()
    local container: object = InventoryControllerGetPlayerContainer()

    for ordinal = 0, c_iInventoryCapacity - 1 do
      local category: int
      local index: int
      category = inv_overhaul_inventory_items.InventoryItemsGetCachedCategory(ordinal)
      index = inv_overhaul_inventory_items.InventoryItemsGetCachedIndex(ordinal)
      if category >= 0 && index >= 0 then
        local item: object
        local itemID: int = -1
        container->GetItem(item, index, category)
        if item then item->GetItemID(itemID) end
        local hit: bool = InventoryControllerIsItemTexturePreloaded(
          itemID, InventoryControllerReadPerfCacheEpoch() + 0)
        inv_overhaul_inventory_view.InventoryViewRecordStackCacheResult(hit)
      end
    end

    for equipment = 0, 4 do
      local category: int
      local index: int
      category = inv_overhaul_inventory_equipment.InventoryEquipmentGetCachedCategory(equipment)
      index = inv_overhaul_inventory_equipment.InventoryEquipmentGetCachedIndex(equipment)
      if category >= 0 && index >= 0 then
        local item: object
        local itemID: int = -1
        container->GetItem(item, index, category)
        if item then item->GetItemID(itemID) end
        local hit: bool = InventoryControllerIsItemTexturePreloaded(
          itemID, InventoryControllerReadPerfCacheEpoch() + 0)
        inv_overhaul_inventory_view.InventoryViewRecordEquipmentCacheResult(hit)
      end
    end
  end

  function InventoryControllerReportFirstInitialItem() -> void
    inv_overhaul_inventory_view.InventoryViewReportFirstInitialItem()
  end

  function InventoryControllerReportInitialLoadComplete() -> void
    inv_overhaul_inventory_view.InventoryViewReportInitialLoadComplete()
  end

  function InventoryControllerTryWarmStartGrid() -> void
    if !inv_overhaul_inventory_view.InventoryViewBeginWarmStartAttempt() then return end

    local characterReady: int = 0
    local fullyWarmed: int = 0
    local completedGeneration: int = -1
    local currentGeneration: int = 0
    native.GetVariable("inv_overhaul_ui_cache_character_ready", characterReady)
    native.GetVariable("inv_overhaul_ui_cache_fully_warmed", fullyWarmed)
    native.GetVariable("inv_overhaul_ui_cache_completed_generation", completedGeneration)
    native.GetVariable("inv_overhaul_inventory_content_generation", currentGeneration)
    if characterReady != 1 || fullyWarmed != 1 || completedGeneration != currentGeneration then
      if inv_overhaul_inventory_view.InventoryViewDiagnosticsEnabled() then
        native.Trace("INV_OVERHAUL_PERF_PHASE warm_start ready=0 generation=" +
          completedGeneration + " current=" + currentGeneration)
      end
      return
    end

    InventoryControllerLoadLayoutVariables()
    InventoryControllerInitializePersistentBackpackSnapshot()
    InventoryControllerOrderFreeCellsByDisplayForCount(InventoryControllerReadLastBackpackItemCount() + 0)
    InventoryControllerBuildEquipmentIndexCache()
    InventoryControllerMeasureInitialTextureCacheCoverage()
    local cacheHits: int = inv_overhaul_inventory_view.InventoryViewGetCacheHits()
    local cacheMisses: int = inv_overhaul_inventory_view.InventoryViewGetCacheMisses()
    if cacheMisses > 0 then
      if inv_overhaul_inventory_view.InventoryViewDiagnosticsEnabled() then
        native.Trace("INV_OVERHAUL_PERF_PHASE warm_start ready=0 hits=" +
          cacheHits + " misses=" + cacheMisses)
      end
      return
    end

    InventoryControllerClampPage()
    for slot = 0, visibleSlots - 1 do InventoryControllerUpdateSlot(slot) end
    inv_overhaul_inventory_view.InventoryViewMarkWarmGridLoaded()
    if inv_overhaul_inventory_view.InventoryViewDiagnosticsEnabled() then
      native.Trace("INV_OVERHAUL_PERF_PHASE warm_start ready=1 hits=" +
        cacheHits + " misses=" + cacheMisses)
    end
  end

  function InventoryControllerBeginInitialSlotLoad() -> void
    InventoryControllerUpdateLayout()
    InventoryControllerClampPage()
    InventoryControllerBuildEquipmentIndexCache()
    InventoryControllerMeasureInitialTextureCacheCoverage()
    InventoryControllerUpdatePageControls()
    inv_overhaul_inventory_view.InventoryViewBeginInitialLoad(
      InventoryControllerReadVisibleSlots())
    -- Every inventory window is created with empty slot backgrounds already
    -- assigned by the child scripts.  Initialise the five equipment labels in
    -- one cheap pass; InventoryControllerContinueInitialSlotLoad then spends frames only on
    -- occupied slots whose sprites actually have to be decoded.
    for cache = 0, 4 do
      local wndName: string = InventoryControllerGetTargetWndName(inv_overhaul_inventory_protocol.TargetWeapon + cache)
      native.SendMessage(c_iSlotEmpty, wndName)
      native.SendMessage(-140, wndName)
      native.SendMessage(-30 - cache, wndName)
    end
    native.Trace("inv_overhaul_inventory deferred initial slots count=" + visibleSlots)
  end

  function InventoryControllerContinueInitialSlotLoad() -> void
    if !inv_overhaul_inventory_view.InventoryViewIsInitialLoadActive() then return end
    if inv_overhaul_inventory_view.InventoryViewDiagnosticsEnabled() then native.Trace("INV_OVERHAUL_PERF_STEP slot_pass_begin") end
    for batch = 0, c_iInitialSlotLoadBatch - 1 do
      local loadedSprite: bool = false

      -- Empty equipment slots have already been initialised in
      -- InventoryControllerBeginInitialSlotLoad.  Skip them without consuming a whole frame.
      local equipmentDone: bool = false
      while !loadedSprite && !equipmentDone do
        local equipmentSlot: int =
          inv_overhaul_inventory_view.InventoryViewTakeNextEquipment()
        if equipmentSlot < 0 then equipmentDone = true else
        local category: int
        local index: int
        category = inv_overhaul_inventory_equipment.InventoryEquipmentGetCachedCategory(equipmentSlot)
        index = inv_overhaul_inventory_equipment.InventoryEquipmentGetCachedIndex(equipmentSlot)
        if category >= 0 && index >= 0 then
          InventoryControllerUpdateCachedEquipmentSlot(equipmentSlot)
          InventoryControllerMarkItemTextureLoaded(category, index)
          InventoryControllerReportFirstInitialItem()
          loadedSprite = true
        end
        end
      end

      -- A freshly-created empty grid slot already has the correct background.
      -- Only occupied cells need an item message and native.LoadImage. Invalid
      -- cells on a short final page are still explicitly hidden.
      while !loadedSprite do
        local slot: int = inv_overhaul_inventory_view.InventoryViewTakeNextSlot(
          InventoryControllerReadVisibleSlots())
        if slot < 0 then loadedSprite = true else
        if InventoryControllerGetVisibleCell(slot) < 0 then
          InventoryControllerUpdateSlot(slot)
        else
          local reference: int = InventoryControllerResolveVisibleSlot(slot)
          if reference >= 0 then
            InventoryControllerUpdateSlot(slot)
            InventoryControllerMarkItemTextureLoaded(
              inv_overhaul_inventory_items.InventoryItemsDecodeReferenceCategory(reference),
              inv_overhaul_inventory_items.InventoryItemsDecodeReferenceIndex(reference))
            InventoryControllerReportFirstInitialItem()
            loadedSprite = true
          end
        end
        end
      end
    end
    if inv_overhaul_inventory_view.InventoryViewInitialLoadComplete(
      InventoryControllerReadVisibleSlots()) then
      inv_overhaul_inventory_view.InventoryViewFinishInitialLoad()
      InventoryControllerReportInitialLoadComplete()
      native.Trace("inv_overhaul_inventory sequential initial slots complete batch=" +
        c_iInitialSlotLoadBatch)
    end
    if inv_overhaul_inventory_view.InventoryViewDiagnosticsEnabled() then native.Trace("INV_OVERHAUL_PERF_STEP slot_pass_end") end
  end

  function InventoryControllerUpdateSlots() -> void
    inv_overhaul_inventory_view.InventoryViewFinishInitialLoad()
    InventoryControllerUpdateLayout()
    InventoryControllerClampPage()
    InventoryControllerBuildBackpackIndexCacheAndSnapshot()
    for slot = 0, visibleSlots - 1 do InventoryControllerUpdateSlot(slot) end
    InventoryControllerUpdateEquipmentSlots()
    InventoryControllerUpdatePageControls()
  end

  function InventoryControllerBuildEquipmentIndexCache() -> void
    inv_overhaul_inventory_equipment.InventoryEquipmentBuildCache()
  end

  function InventoryControllerUpdateCachedEquipmentSlot(cache: int) -> void
    local category: int
    local index: int
    local wndName: string = InventoryControllerGetTargetWndName(inv_overhaul_inventory_protocol.TargetWeapon + cache)
    category = inv_overhaul_inventory_equipment.InventoryEquipmentGetCachedCategory(cache)
    index = inv_overhaul_inventory_equipment.InventoryEquipmentGetCachedIndex(cache)
    if category >= 0 && index >= 0 then
      local container: object = InventoryControllerGetPlayerContainer()
      local item: object
      container->GetItem(item, index, category)
      native.SendMessage(0, wndName, item)
      local itemID: int
      item->GetItemID(itemID)
      local quickslot: int = InventoryControllerGetDisplayedQuickslot(category, index, itemID)
      native.SendMessage(-140, wndName)
      if quickslot > 0 then native.SendMessage(-140 - quickslot, wndName) end
    else
      native.SendMessage(c_iSlotEmpty, wndName)
      native.SendMessage(-140, wndName)
    end
    native.SendMessage(-30 - cache, wndName)
  end

  function InventoryControllerUpdateEquipmentSlots() -> void
    InventoryControllerBuildEquipmentIndexCache()
    for cache = 0, 4 do
      InventoryControllerUpdateCachedEquipmentSlot(cache)
    end
  end

  function InventoryControllerUpdateVisibleCell(cell: int) -> void
    if cell < 0 then return end
    for slot = 0, visibleSlots - 1 do
      if InventoryControllerGetVisibleCell(slot) == cell then
        InventoryControllerUpdateSlot(slot)
        return
      end
    end
  end

  function InventoryControllerRefreshEquipmentMutation(changedCell: int, equipmentTarget: int) -> void
    inv_overhaul_inventory_view.InventoryViewFinishInitialLoad()
    InventoryControllerBuildBackpackIndexCacheAndSnapshot()
    inv_overhaul_inventory_snapshot.InventorySnapshotClampLastBackpackItemCount()
    InventoryControllerUpdateVisibleCell(changedCell)
    InventoryControllerBuildEquipmentIndexCache()
    local cache: int = equipmentTarget - inv_overhaul_inventory_protocol.TargetWeapon
    if cache >= 0 && cache < 5 then InventoryControllerUpdateCachedEquipmentSlot(cache) end
    InventoryControllerUpdatePageControls()
  end

  function InventoryControllerResolveEquipmentTarget(target: int) -> int
    return inv_overhaul_inventory_equipment.InventoryEquipmentResolveTarget(target)
  end

  function InventoryControllerResolveDragSource(source: int) -> int
    if source >= 0 && source < visibleSlots then
      return InventoryControllerResolveVisibleSlot(source)
    end
    return InventoryControllerResolveEquipmentTarget(source)
  end

  function InventoryControllerUnequipItem(category: int, index: int) -> bool
    return inv_overhaul_inventory_equipment.InventoryEquipmentUnequip(category, index)
  end

  function InventoryControllerEquipDraggedItem(target: int, category: int, index: int) -> bool
    return inv_overhaul_inventory_equipment.InventoryEquipmentEquip(target, category, index)
  end

  function InventoryControllerToggleSlot(category: int, index: int) -> void
    local result: int = inv_overhaul_inventory_equipment.InventoryEquipmentToggle(category, index)
    if result == 2 then deferredInventoryRefresh = 0.25 end
  end

  function InventoryControllerHandleModifiedDrop(sourceSlot: int) -> bool
    if !shiftHeld && !controlHeld then return false end
    if sourceSlot < 0 || sourceSlot >= visibleSlots then return false end
    local reference: int = InventoryControllerResolveVisibleSlot(sourceSlot)
    if reference < 0 then return true end

    if controlHeld && !shiftHeld then
      InventoryControllerMoveSlotToOtherPage(sourceSlot)
      return true
    end

    local category: int =
      inv_overhaul_inventory_items.InventoryItemsDecodeReferenceCategory(reference)
    local index: int =
      inv_overhaul_inventory_items.InventoryItemsDecodeReferenceIndex(reference)
    local amount: int
    local player: object = InventoryControllerGetPlayerContainer()
    player->GetItemAmount(amount, index, category)

    local beforeCount: int = InventoryControllerGetBackpackItemCount()
    local usedOrder: int = InventoryControllerGetOrderValue(InventoryControllerGetVisibleCell(sourceSlot))
    if inv_overhaul_inventory_drop.InventoryDropSlot(category, index, amount) then
      local afterCount: int = InventoryControllerGetBackpackItemCount()
      if afterCount < beforeCount then InventoryControllerRemoveOrderOrdinal(usedOrder, beforeCount) end
      InventoryControllerUpdateSlots()
    end
    return true
  end

  function InventoryControllerMoveSlotToOtherPage(sourceSlot: int) -> void
    local maxPage: int = InventoryControllerGetMaxPage()
    if maxPage <= 0 then return end

    local targetPage: int =
      inv_overhaul_inventory_paging.InventoryPagingGetNextPage(maxPage)
    local backpackCount: int = InventoryControllerGetBackpackItemCount()
    local targetCell: int = -1
    for targetSlot = 0, visibleSlots - 1 do
      local linear: int = targetPage * visibleSlots + targetSlot
      local cell: int = InventoryControllerGetCellForLinearSlot(linear)
      if cell >= 0 && InventoryControllerGetOrderValue(cell) >= backpackCount then
        targetCell = cell
        targetSlot = visibleSlots
      end
    end
    if targetCell < 0 then
      InventoryControllerShowInventoryFull()
      return
    end

    local sourceCell: int = InventoryControllerGetVisibleCell(sourceSlot)
    InventoryControllerSwapSlotOrderCells(sourceCell, targetCell)
    native.Trace("inv_overhaul_inventory ctrl-page-move sourcePage=" +
      InventoryControllerReadPage() + " targetPage=" + targetPage)
  end

  function InventoryControllerHandleSlotMessage(message: int, sender: string) -> bool
    for slot = 0, visibleSlots - 1 do
      if sender == inv_overhaul_inventory_protocol.InventoryProtocolGetSlotWindowName(slot) then
        local reference: int = InventoryControllerResolveVisibleSlot(slot)
        if reference >= 0 then
          if message == 1 then
            local beforeCount: int = InventoryControllerGetBackpackItemCount()
            local usedOrder: int = InventoryControllerGetOrderValue(InventoryControllerGetVisibleCell(slot))
            local category: int =
              inv_overhaul_inventory_items.InventoryItemsDecodeReferenceCategory(reference)
            local index: int =
              inv_overhaul_inventory_items.InventoryItemsDecodeReferenceIndex(reference)
            InventoryControllerToggleSlot(category, index)
            local afterCount: int = InventoryControllerGetBackpackItemCount()
            native.Trace("inv_overhaul_inventory slot toggle category=" + category + " order=" + usedOrder +
              " before=" + beforeCount + " after=" + afterCount)
            if afterCount < beforeCount then
              if category == c_iCWeapon || category == c_iCClothes then
                if !InventoryControllerRestoreOrderAfterEquipmentSelection(usedOrder, beforeCount) then
                  InventoryControllerRemoveOrderOrdinal(usedOrder, beforeCount)
                end
              else
                InventoryControllerRemoveOrderOrdinal(usedOrder, beforeCount)
              end
            else
              if afterCount == beforeCount && (category == c_iCWeapon || category == c_iCClothes) then
                InventoryControllerRestoreOrderAfterEquipmentReplacement(usedOrder, beforeCount)
              end
            end
          else
            native.Trace("inv_overhaul_inventory left click ignored " + sender)
          end
        end
        InventoryControllerUpdateSlots()
        return true
      end
    end
    return false
  end

  function InventoryControllerGetDragSourceBySender(sender: string) -> int
    local backpackSource: int = inv_overhaul_inventory_protocol.InventoryProtocolGetSlotBySender(sender, InventoryControllerReadVisibleSlots() + 0)
    if backpackSource >= 0 then return backpackSource end
    return inv_overhaul_inventory_protocol.InventoryProtocolGetSpecialTargetBySender(sender)
  end

  function InventoryControllerIsSpecialTargetCompatible(target: int) -> bool
    return inv_overhaul_inventory_equipment.InventoryEquipmentIsTargetCompatible(
      target, InventoryControllerReadDragItemCategory(), InventoryControllerReadDragItemIsWeapon(), InventoryControllerReadDragItemGroup() + 0)
  end

  function InventoryControllerStartDragAction(source: int, sender: string) -> void
    local currentGeneration: int = observedContentGeneration
    native.GetVariable("inv_overhaul_inventory_content_generation", currentGeneration)
    InventoryControllerReconcileInventoryContentGeneration(currentGeneration)
    InventoryControllerCancelDragPageHover(0)
    inv_overhaul_inventory_tooltip.InventoryTooltipClear()
    local sourceCell: int = -1
    if source >= 0 && source < visibleSlots then sourceCell = InventoryControllerGetVisibleCell(source) end
    inv_overhaul_inventory_drag.InventoryDragBeginTransaction(source, sourceCell)
    InventoryControllerSetHighlightedSlot(-1)
    InventoryControllerBeginDragCursor(InventoryControllerReadDragSourceSlot() + 0)
    native.Trace("inv_overhaul_inventory press " + sender + " " + source)
  end

  function InventoryControllerUnequipTarget(target: int, reason: string) -> void
    local reference: int = InventoryControllerResolveEquipmentTarget(target)
    if reference >= 0 then
      local beforeCount: int = InventoryControllerGetBackpackItemCount()
      if beforeCount >= c_iInventoryCapacity then
        native.Trace("inv_overhaul_inventory unequip refused: backpack full target=" + target)
        InventoryControllerShowInventoryFull()
        return
      end
      local category: int =
        inv_overhaul_inventory_items.InventoryItemsDecodeReferenceCategory(reference)
      local index: int =
        inv_overhaul_inventory_items.InventoryItemsDecodeReferenceIndex(reference)
      if InventoryControllerUnequipItem(category, index) then
        InventoryControllerInsertOrderOrdinal(InventoryControllerGetBackpackOrdinal(category, index), beforeCount)
        native.Trace("inv_overhaul_inventory unequipped by " + reason + " target=" + target)
      end
      InventoryControllerUpdateSlots()
    end
  end

  function InventoryControllerSwapSlotOrderCells(sourceCell: int, targetCell: int) -> void
    if !inv_overhaul_inventory_layout_runtime.InventoryLayoutRuntimeSwapCells(sourceCell, targetCell) then return end
    InventoryControllerQueueLayoutSave()
    for visibleSlot = 0, visibleSlots - 1 do
      local visibleCell: int = InventoryControllerGetVisibleCell(visibleSlot)
      if visibleCell == sourceCell || visibleCell == targetCell then InventoryControllerUpdateSlot(visibleSlot) end
    end
  end

  function InventoryControllerRemoveOrderOrdinal(removedOrder: int, beforeCount: int) -> void
    inv_overhaul_inventory_layout_runtime.InventoryLayoutRuntimeRemoveOrdinal(removedOrder, beforeCount, InventoryControllerGetBackpackItemCount(), InventoryControllerReadVisibleSlots() + 0)
    InventoryControllerQueueLayoutSave()
  end

  function InventoryControllerFindFirstFreeVisualSlot(itemCount: int) -> int
    return inv_overhaul_inventory_layout_runtime.InventoryLayoutRuntimeFindFirstFreeCell(itemCount, InventoryControllerReadVisibleSlots() + 0)
  end

  function InventoryControllerGetBackpackOrdinal(category: int, index: int) -> int
    return inv_overhaul_inventory_items.InventoryItemsGetBackpackOrdinal(category, index)
  end

  function InventoryControllerInsertOrderOrdinal(insertedOrder: int, beforeCount: int) -> bool
    return InventoryControllerInsertOrderOrdinalAtCell(insertedOrder, beforeCount, InventoryControllerFindFirstFreeVisualSlot(beforeCount))
  end

  function InventoryControllerInsertOrderOrdinalAtCell(insertedOrder: int, beforeCount: int, targetCell: int) -> bool
    local inserted: bool = inv_overhaul_inventory_layout_runtime.InventoryLayoutRuntimeInsertOrdinal(insertedOrder, beforeCount, targetCell, InventoryControllerGetBackpackItemCount(), InventoryControllerReadVisibleSlots() + 0)
    if inserted then InventoryControllerQueueLayoutSave() end
    return inserted
  end

  function InventoryControllerSetHighlightedSlot(slot: int) -> void
    local previous: int = inv_overhaul_inventory_drag.InventoryDragGetHighlightedTarget()
    if previous == slot then
      return
    end

    if previous >= 0 then
      if previous < visibleSlots then
        InventoryControllerSetGridRendererHighlight(previous, false)
      else
        native.SendMessage(-21, InventoryControllerGetTargetWndName(previous))
      end
    end

    inv_overhaul_inventory_drag.InventoryDragSetHighlightedTarget(slot)
    if slot >= 0 then
      if slot < visibleSlots then
        InventoryControllerSetGridRendererHighlight(slot, true)
      else
        native.SendMessage(-20, InventoryControllerGetTargetWndName(slot))
      end
    end
  end

  function InventoryControllerCancelDragAction() -> void
    if !inv_overhaul_inventory_drag.InventoryDragIsActive() then return end

    local sourceSlot: int = inv_overhaul_inventory_drag.InventoryDragGetSourceSlot()
    inv_overhaul_inventory_tooltip.InventoryTooltipSuspend(0.2)
    inv_overhaul_inventory_tooltip.InventoryTooltipClear()
    if sourceSlot >= visibleSlots && sourceSlot <= inv_overhaul_inventory_protocol.TargetClothesBase + 4 then
      native.SendMessage(-130, InventoryControllerGetTargetWndName(sourceSlot))
    end

    inv_overhaul_inventory_drag.InventoryDragClearTransaction()
    InventoryControllerSetHighlightedSlot(-1)
    InventoryControllerEndDragCursor()
    InventoryControllerCancelDragPageHover(0)
  end

  function InventoryControllerFinishLeftAction(targetSlot: int) -> void
    if !inv_overhaul_inventory_drag.InventoryDragIsActive() then
      return
    end

    local currentGeneration: int = observedContentGeneration
    native.GetVariable("inv_overhaul_inventory_content_generation", currentGeneration)
    if InventoryControllerReconcileInventoryContentGeneration(currentGeneration) then return end

    local sourceSlot: int = inv_overhaul_inventory_drag.InventoryDragGetSourceSlot()
    local resolvedTarget: int =
      inv_overhaul_inventory_drag.InventoryDragResolveReleaseTarget(targetSlot)
    if resolvedTarget != targetSlot then
      targetSlot = resolvedTarget
      native.Trace("inv_overhaul_inventory release latched target=" + targetSlot)
    end

    inv_overhaul_inventory_tooltip.InventoryTooltipSuspend(0.2)
    inv_overhaul_inventory_tooltip.InventoryTooltipClear()
    if sourceSlot >= visibleSlots && sourceSlot <= inv_overhaul_inventory_protocol.TargetClothesBase + 4 then
      native.SendMessage(-130, InventoryControllerGetTargetWndName(sourceSlot))
    end
    if targetSlot >= visibleSlots && targetSlot <= inv_overhaul_inventory_protocol.TargetClothesBase + 4 then
      native.SendMessage(-130, InventoryControllerGetTargetWndName(targetSlot))
    end

    if sourceSlot >= inv_overhaul_inventory_protocol.TargetWeapon && sourceSlot <= inv_overhaul_inventory_protocol.TargetClothesBase + 4 then
      if targetSlot >= 0 && targetSlot < visibleSlots then
        local beforeCount: int = InventoryControllerGetBackpackItemCount()
        if beforeCount < c_iInventoryCapacity then
          if InventoryControllerUnequipItem(InventoryControllerReadDragItemCategory(), InventoryControllerReadDragItemIndex()) then
            InventoryControllerInsertOrderOrdinalAtCell(
              InventoryControllerGetBackpackOrdinal(InventoryControllerReadDragItemCategory(), InventoryControllerReadDragItemIndex()),
              beforeCount,
              InventoryControllerGetVisibleCell(targetSlot))
            native.Trace("inv_overhaul_inventory unequipped by drag source=" + sourceSlot + " target=" + targetSlot)
          end
        else
          native.Trace("inv_overhaul_inventory unequip drag refused: backpack full source=" + sourceSlot)
          InventoryControllerShowInventoryFull()
        end
        InventoryControllerRefreshEquipmentMutation(InventoryControllerGetVisibleCell(targetSlot), sourceSlot)
      else
        if targetSlot == inv_overhaul_inventory_protocol.TargetDrop then
          inv_overhaul_inventory_drop.InventoryDropSlot(
            InventoryControllerReadDragItemCategory(),
            InventoryControllerReadDragItemIndex(),
            1)
          InventoryControllerUpdateSlots()
        else
          native.Trace("inv_overhaul_inventory equipped source release ignored source=" + sourceSlot + " target=" + targetSlot)
        end
      end
    else
      if targetSlot >= 0 && targetSlot < visibleSlots &&
        InventoryControllerGetVisibleCell(targetSlot) !=
          inv_overhaul_inventory_drag.InventoryDragGetSourceCell() then
        native.Trace("inv_overhaul_inventory swap " + sourceSlot + " " + targetSlot)
        InventoryControllerSwapSlotOrderCells(InventoryControllerReadDragSourceCell(), InventoryControllerGetVisibleCell(targetSlot))
      else
        if targetSlot >= inv_overhaul_inventory_protocol.TargetWeapon && targetSlot <= inv_overhaul_inventory_protocol.TargetClothesBase + 4 then
          if inv_overhaul_inventory_drag.InventoryDragGetItemCategory() >= 0 &&
            inv_overhaul_inventory_drag.InventoryDragGetItemIndex() >= 0 then
            local beforeCount: int = InventoryControllerGetBackpackItemCount()
            local usedOrder: int = InventoryControllerGetOrderValue(InventoryControllerReadDragSourceCell() + 0)
            local equipped: bool = InventoryControllerEquipDraggedItem(targetSlot, InventoryControllerReadDragItemCategory(), InventoryControllerReadDragItemIndex())
            if equipped then
              local afterCount: int = InventoryControllerGetBackpackItemCount()
              if afterCount < beforeCount then
                if !InventoryControllerRestoreOrderAfterEquipmentSelection(usedOrder, beforeCount) then
                  InventoryControllerRemoveOrderOrdinal(usedOrder, beforeCount)
                end
              else
                if afterCount == beforeCount then
                  InventoryControllerRestoreOrderAfterEquipmentReplacement(usedOrder, beforeCount)
                end
              end
              native.Trace("inv_overhaul_inventory equipped target=" + targetSlot)
            else
              native.Trace("inv_overhaul_inventory incompatible target=" + targetSlot)
            end
            if equipped then InventoryControllerRefreshEquipmentMutation(InventoryControllerReadDragSourceCell(), targetSlot) end
          end
        else
          if targetSlot == inv_overhaul_inventory_protocol.TargetDrop then
            if inv_overhaul_inventory_drag.InventoryDragGetItemCategory() >= 0 &&
              inv_overhaul_inventory_drag.InventoryDragGetItemIndex() >= 0 then
              local beforeCount: int = InventoryControllerGetBackpackItemCount()
              local usedOrder: int = InventoryControllerGetOrderValue(InventoryControllerReadDragSourceCell() + 0)
              inv_overhaul_inventory_drop.InventoryDropSlot(
                InventoryControllerReadDragItemCategory(),
                InventoryControllerReadDragItemIndex(),
                1)
              local afterCount: int = InventoryControllerGetBackpackItemCount()
              if afterCount < beforeCount then InventoryControllerRemoveOrderOrdinal(usedOrder, beforeCount) end
              InventoryControllerUpdateSlots()
            end
          else
            native.Trace("inv_overhaul_inventory left release " + sourceSlot)
          end
        end
      end
    end

    inv_overhaul_inventory_drag.InventoryDragClearTransaction()
    InventoryControllerSetHighlightedSlot(-1)
    InventoryControllerEndDragCursor()
    InventoryControllerCancelDragPageHover(0)
  end

  function InventoryControllerFindBackpackSlotAt(x: int, y: int) -> int
    return inv_overhaul_inventory_geometry.InventoryGeometryFindBackpackSlot(
      InventoryControllerReadWindowWidth(), InventoryControllerReadVisibleSlots(), c_iSlotDropInset, x, y)
  end

  function InventoryControllerFindSlotAt(x: int, y: int) -> int
    local backpackSlot: int = InventoryControllerFindBackpackSlotAt(x, y)
    if backpackSlot >= 0 then return backpackSlot end
    return InventoryControllerFindSpecialTargetAt(x, y)
  end

  function InventoryControllerIsInsideSlotDropArea(localX: int, localY: int) -> bool
    return inv_overhaul_inventory_geometry.InventoryGeometryIsInsideSlotDropArea(
      InventoryControllerReadWindowWidth(), c_iSlotDropInset, localX, localY)
  end

  function InventoryControllerFindSlotAtPointer(x: int, y: int) -> int
    return InventoryControllerFindSlotAt(x, y)
  end

  function InventoryControllerUpdatePointerSlot(x: int, y: int) -> int
    return InventoryControllerFindSlotAtPointer(x, y)
  end

  function InventoryControllerApplyPointerSlot(slot: int) -> void
    if !inv_overhaul_inventory_drag.InventoryDragIsActive() then
      return
    end

    local sameSource: bool = false
    local sourceSlot: int = inv_overhaul_inventory_drag.InventoryDragGetSourceSlot()
    local sourceCell: int = inv_overhaul_inventory_drag.InventoryDragGetSourceCell()
    if slot == sourceSlot then sameSource = true end
    if sourceCell >= 0 && slot >= 0 && slot < visibleSlots then
      if InventoryControllerGetVisibleCell(slot) == sourceCell then sameSource = true else sameSource = false end
    end
    local highlight: int =
      inv_overhaul_inventory_drag.InventoryDragApplyPointerTarget(slot, sameSource)
    InventoryControllerSetHighlightedSlot(highlight)
  end

  function InventoryControllerGetCurrentDropSlot(message: int, base: int, sender: string) -> int
    return InventoryControllerGetSlotTargetFromPointerMessage(message, base, sender)
  end

  function InventoryControllerGetSlotTargetFromPointerMessage(message: int, base: int, sender: string) -> int
    local senderSlot: int = inv_overhaul_inventory_protocol.InventoryProtocolGetSlotBySender(sender, InventoryControllerReadVisibleSlots() + 0)
    if senderSlot < 0 then
      return -1
    end

    local encoded: int = message - base
    local localX: int = encoded / 100
    local localY: int = encoded - localX * 100
    local targetSlot: int = -1
    if InventoryControllerIsInsideSlotDropArea(localX, localY) then
      targetSlot = senderSlot
    end
    return targetSlot
  end

  function InventoryControllerChangePage(delta: int) -> void
    inv_overhaul_inventory_paging.InventoryPagingChange(
      delta, c_iInventoryCapacity, InventoryControllerReadVisibleSlots() + 0)
    InventoryControllerUpdateSlots()
  end

  function InventoryControllerGetDragPageHoverAction(sender: string) -> int
    local action: int = 0
    if sender == "page_prev" then action = -1 end
    if sender == "page_next" then action = 1 end
    if inv_overhaul_inventory_paging.InventoryPagingCanMove(
      action, InventoryControllerGetMaxPage()) then return action end
    return 0
  end

  function InventoryControllerBeginDragPageHover(sender: string) -> void
    if !inv_overhaul_inventory_drag.InventoryDragIsActive() then return end
    local action: int = InventoryControllerGetDragPageHoverAction(sender)
    if action == 0 then return end
    if !inv_overhaul_inventory_drag.InventoryDragBeginPageHover(action) then return end
    native.Trace("inv_overhaul_inventory page-hover begin sender=" + sender + " action=" + action +
      " source=" + inv_overhaul_inventory_drag.InventoryDragGetSourceSlot())
  end

  function InventoryControllerCancelDragPageHover(action: int) -> void
    if !inv_overhaul_inventory_drag.InventoryDragCanCancelPageHover(action) then return end
    local currentAction: int = inv_overhaul_inventory_drag.InventoryDragGetPageHoverAction()
    if currentAction != 0 then
      native.Trace("inv_overhaul_inventory page-hover cancel action=" + currentAction + " elapsed=" +
        inv_overhaul_inventory_drag.InventoryDragGetPageHoverElapsed())
    end
    inv_overhaul_inventory_drag.InventoryDragClearPageHover()
  end

  function InventoryControllerUpdateDragPageHover(delta: float) -> void
    local action: int = inv_overhaul_inventory_drag.InventoryDragGetPageHoverAction()
    if !inv_overhaul_inventory_drag.InventoryDragIsActive() || action == 0 then return end
    if !inv_overhaul_inventory_paging.InventoryPagingCanMove(
      action, InventoryControllerGetMaxPage()) then
      InventoryControllerCancelDragPageHover(action)
      return
    end
    action = inv_overhaul_inventory_drag.InventoryDragAdvancePageHover(delta)
    if action == 0 then return end
    InventoryControllerSetHighlightedSlot(-1)
    native.Trace("inv_overhaul_inventory page-hover switch action=" + action +
      " page=" + InventoryControllerReadPage())
    InventoryControllerChangePage(action)
  end

  function InventoryControllerSyncDragPageHoverFromCursor() -> void
    if !inv_overhaul_inventory_drag.InventoryDragIsActive() then
      InventoryControllerCancelDragPageHover(0)
      return
    end
    local hoverTarget: int = 0
    native.GetVariable("inv_overhaul_inventory_page_hover", hoverTarget)
    local action: int = inv_overhaul_inventory_paging.InventoryPagingGetCursorHoverAction(
      hoverTarget, InventoryControllerGetMaxPage())
    if action == 0 then
      InventoryControllerCancelDragPageHover(0)
      return
    end
    if !inv_overhaul_inventory_drag.InventoryDragBeginPageHover(action) then return end
    native.Trace("inv_overhaul_inventory page-hover cursor target=" + hoverTarget +
      " action=" + action + " page=" + InventoryControllerReadPage())
  end

  function InventoryControllerRunFramePreparationStage(delta: float) -> void
    if inv_overhaul_inventory_view.InventoryViewClaimChildWindowsReady() then
      if inv_overhaul_inventory_view.InventoryViewDiagnosticsEnabled() then native.Trace("INV_OVERHAUL_PERF_STEP first_update_begin") end
      if inv_overhaul_inventory_view.InventoryViewDiagnosticsEnabled() then native.Trace("INV_OVERHAUL_PERF_PHASE child_ready") end
      lastLayoutWidth = -1
      lastLayoutHeight = -1
      lastLayoutSlots = -1
      InventoryControllerUpdateLayout()
      InventoryControllerUpdatePageControls()
      InventoryControllerUpdateMoney()
      if inv_overhaul_inventory_view.InventoryViewDiagnosticsEnabled() then native.Trace("INV_OVERHAUL_PERF_STEP first_update_children_ready") end
    end
    inv_overhaul_inventory_tooltip.InventoryTooltipAdvanceSuspension(delta)
    if inventoryFullMessageCooldown > 0 then
      inventoryFullMessageCooldown = inventoryFullMessageCooldown - delta
      if inventoryFullMessageCooldown < 0 then inventoryFullMessageCooldown = 0 end
    end
    InventoryControllerUpdateLayout()
  end

  function InventoryControllerRunMetadataAndLoadingStage(delta: float) -> void
    if inv_overhaul_inventory_view.InventoryViewAdvanceMetadataDelay(delta) then
        if inv_overhaul_inventory_view.InventoryViewGetMetadataStage() == 0 then
          if inv_overhaul_inventory_view.InventoryViewDiagnosticsEnabled() then native.Trace("INV_OVERHAUL_PERF_STEP layout_batch_begin") end
          if InventoryControllerContinueIncrementalLayoutLoad() then
            inv_overhaul_inventory_view.InventoryViewAdvanceMetadataStage()
          end
          if inv_overhaul_inventory_view.InventoryViewDiagnosticsEnabled() then native.Trace("INV_OVERHAUL_PERF_STEP layout_batch_end") end
        end
        if inv_overhaul_inventory_view.InventoryViewGetMetadataStage() == 1 then
          if inv_overhaul_inventory_view.InventoryViewDiagnosticsEnabled() then native.Trace("INV_OVERHAUL_PERF_STEP snapshot_begin") end
          InventoryControllerInitializePersistentBackpackSnapshot()
          inv_overhaul_inventory_view.InventoryViewAdvanceMetadataStage()
          if inv_overhaul_inventory_view.InventoryViewDiagnosticsEnabled() then native.Trace("INV_OVERHAUL_PERF_STEP snapshot_end") end
        end
        if inv_overhaul_inventory_view.InventoryViewGetMetadataStage() == 2 then
          if inv_overhaul_inventory_view.InventoryViewDiagnosticsEnabled() then native.Trace("INV_OVERHAUL_PERF_STEP free_order_begin") end
          InventoryControllerOrderFreeCellsByDisplayForCount(InventoryControllerReadLastBackpackItemCount() + 0)
          if inv_overhaul_inventory_view.InventoryViewDiagnosticsEnabled() then native.Trace("INV_OVERHAUL_PERF_STEP free_order_end") end
          if inv_overhaul_inventory_view.InventoryViewDiagnosticsEnabled() then native.Trace("INV_OVERHAUL_PERF_PHASE layout_ready") end
          inv_overhaul_inventory_view.InventoryViewCompleteMetadata()
          if inv_overhaul_inventory_view.InventoryViewDiagnosticsEnabled() then native.Trace("INV_OVERHAUL_PERF_STEP initial_load_begin") end
          InventoryControllerBeginInitialSlotLoad()
          if inv_overhaul_inventory_view.InventoryViewDiagnosticsEnabled() then native.Trace("INV_OVERHAUL_PERF_STEP initial_load_end") end
        end
    end
    if inv_overhaul_inventory_view.InventoryViewIsInitialLoadActive() then
      if inv_overhaul_inventory_view.InventoryViewAdvanceSpriteCooldown(delta) then
        InventoryControllerContinueInitialSlotLoad()
        if inv_overhaul_inventory_view.InventoryViewIsInitialLoadActive() then
          inv_overhaul_inventory_view.InventoryViewResetSpriteCooldown()
        end
      end
    end
  end

  function InventoryControllerRunPersistenceAndRefreshStage(delta: float) -> void
    InventoryControllerContinueLayoutSave()
    inventoryPollCooldown = inventoryPollCooldown - delta
    if inventoryPollCooldown <= 0 then
      inventoryPollCooldown = 0.25
      InventoryControllerUpdateMoney()
      local currentGeneration: int = 0
      native.GetVariable("inv_overhaul_inventory_content_generation", currentGeneration)
      InventoryControllerReconcileInventoryContentGeneration(currentGeneration)
    end
    if deferredInventoryRefresh > 0 then
      deferredInventoryRefresh = deferredInventoryRefresh - delta
      if deferredInventoryRefresh <= 0 then
        InventoryControllerUpdateSlots()
        native.Trace("inv_overhaul_inventory deferred item-use refresh")
      end
    end
  end

  function InventoryControllerRunDragHoverStage(delta: float) -> void
    InventoryControllerSyncDragPageHoverFromCursor()
    InventoryControllerUpdateDragPageHover(delta)
  end

  function InventoryControllerStartPanelPointerDrag(x: int, y: int) -> void
    if inv_overhaul_inventory_drag.InventoryDragIsActive() then return end

    local equipmentTarget: int = InventoryControllerFindEquipmentTargetAt(x, y)
    if equipmentTarget >= 0 && InventoryControllerResolveEquipmentTarget(equipmentTarget) >= 0 then
      InventoryControllerStartDragAction(equipmentTarget, "panel_background")
      return
    end

    local backpackSlot: int = InventoryControllerFindBackpackSlotAt(x, y)
    if backpackSlot >= 0 && InventoryControllerHandleModifiedDrop(backpackSlot) then return end
    if backpackSlot >= 0 && InventoryControllerResolveVisibleSlot(backpackSlot) >= 0 then
      InventoryControllerStartDragAction(backpackSlot, "panel_background")
    end
  end

  function InventoryControllerGetPageControlX() -> int
    return inv_overhaul_inventory_geometry.InventoryGeometryGetPageControlX(InventoryControllerReadWindowWidth() + 0)
  end

  function InventoryControllerGetPageControlY() -> int
    return inv_overhaul_inventory_geometry.InventoryGeometryGetPageControlY(InventoryControllerReadWindowWidth(), InventoryControllerGetBranch())
  end

  function InventoryControllerIsInsideQuickslotHelp(x: int, y: int) -> bool
    return inv_overhaul_inventory_geometry.InventoryGeometryIsInsideQuickslotHelp(
      InventoryControllerReadWindowWidth(), x, y)
  end

  function InventoryControllerIsInsidePlayerPaging(x: int, y: int) -> bool
    return inv_overhaul_inventory_geometry.InventoryGeometryIsInsidePlayerPaging(
      InventoryControllerReadWindowWidth(), InventoryControllerGetBranch(),
      InventoryControllerGetMaxPage(), x, y)
  end

  function InventoryControllerUpdatePanelTooltip(x: int, y: int) -> void
    if inv_overhaul_inventory_tooltip.InventoryTooltipIsSuspended() then
      inv_overhaul_inventory_tooltip.InventoryTooltipClear()
      return
    end
    if inv_overhaul_inventory_drag.InventoryDragIsActive() then
      inv_overhaul_inventory_tooltip.InventoryTooltipClear()
      return
    end
    if InventoryControllerIsInsideQuickslotHelp(x, y) then
      inv_overhaul_inventory_tooltip.InventoryTooltipShowText(
        inv_overhaul_inventory_protocol.TargetQuickslotHelp, 1407)
      return
    end
    if InventoryControllerIsInsidePlayerPaging(x, y) then
      inv_overhaul_inventory_tooltip.InventoryTooltipShowText(
        inv_overhaul_inventory_protocol.TargetPaging, 1404)
      return
    end
    if InventoryControllerIsInsideSpecialTarget(
      inv_overhaul_inventory_protocol.TargetDrop, x, y) then
      inv_overhaul_inventory_tooltip.InventoryTooltipShowText(
        inv_overhaul_inventory_protocol.TargetDrop, 1401)
      return
    end
    if InventoryControllerIsInsideMoney(x, y) then
      inv_overhaul_inventory_tooltip.InventoryTooltipShowMoney()
      return
    end

    local target: int = InventoryControllerFindBackpackSlotAt(x, y)
    local reference: int = -1
    if target >= 0 then
      reference = InventoryControllerResolveVisibleSlot(target)
    else
      target = InventoryControllerFindEquipmentTargetAt(x, y)
      if target >= 0 then reference = InventoryControllerResolveEquipmentTarget(target) end
    end

    if reference < 0 then
      inv_overhaul_inventory_tooltip.InventoryTooltipClear()
      return
    end
    if inv_overhaul_inventory_tooltip.InventoryTooltipGetTarget() == target then return end

    local container: object = InventoryControllerGetPlayerContainer()
    local item: object
    local category: int =
      inv_overhaul_inventory_items.InventoryItemsDecodeReferenceCategory(reference)
    local index: int =
      inv_overhaul_inventory_items.InventoryItemsDecodeReferenceIndex(reference)
    container->GetItem(item, index, category)
    inv_overhaul_inventory_tooltip.InventoryTooltipShowItem(target, item)
  end

  function InventoryControllerHandlePanelPointer(message: int) -> void
    local base: int = inv_overhaul_inventory_protocol.PointerMoveBase
    local action: int = 0

    if message >= inv_overhaul_inventory_protocol.PointerLeaveBase then
      inv_overhaul_inventory_tooltip.InventoryTooltipClear()
      native.SendMessage(-95, "page_prev")
      native.SendMessage(-95, "page_next")
      return
    end

    if message >= inv_overhaul_inventory_protocol.PointerDragEndBase then
      base = inv_overhaul_inventory_protocol.PointerDragEndBase
      action = 3
    else
      if message >= inv_overhaul_inventory_protocol.PointerDragBeginBase then
        base = inv_overhaul_inventory_protocol.PointerDragBeginBase
        action = 1
      else
        if message >= inv_overhaul_inventory_protocol.PointerRightBase then
          base = inv_overhaul_inventory_protocol.PointerRightBase
          action = 2
        else
          if message >= inv_overhaul_inventory_protocol.PointerUpBase then
            base = inv_overhaul_inventory_protocol.PointerUpBase
            action = 3
          else
            if message >= inv_overhaul_inventory_protocol.PointerDownBase then
              base = inv_overhaul_inventory_protocol.PointerDownBase
              action = 1
            end
          end
        end
      end
    end

    local x: int = inv_overhaul_inventory_protocol.InventoryProtocolDecodePanelPointerX(message, base)
    local y: int = inv_overhaul_inventory_protocol.InventoryProtocolDecodePanelPointerY(message, base)

    if action == 0 then
      InventoryControllerUpdatePageControlHover(x, y)
      InventoryControllerUpdatePanelTooltip(x, y)
    end

    if action == 1 then
      inv_overhaul_inventory_tooltip.InventoryTooltipClear()
      if InventoryControllerHandlePageControlAt(x, y) then return end
      InventoryControllerStartPanelPointerDrag(x, y)
      return
    end

    if action == 2 then
      local equipmentTarget: int = InventoryControllerFindEquipmentTargetAt(x, y)
      if equipmentTarget >= 0 then
        InventoryControllerUnequipTarget(equipmentTarget, "panel right click")
        return
      end
      local backpackSlot: int = InventoryControllerFindBackpackSlotAt(x, y)
      if backpackSlot >= 0 then
        InventoryControllerHandleSlotMessage(1, inv_overhaul_inventory_protocol.InventoryProtocolGetSlotWindowName(backpackSlot))
      end
      return
    end

    local targetSlot: int = InventoryControllerFindSlotAt(x, y)
    if action == 3 then
      if inv_overhaul_inventory_drag.InventoryDragIsActive() then
        InventoryControllerApplyPointerSlot(targetSlot)
        InventoryControllerFinishLeftAction(targetSlot)
      end
      return
    end

    if inv_overhaul_inventory_drag.InventoryDragIsActive() then InventoryControllerApplyPointerSlot(targetSlot) end
  end

  function InventoryControllerHandlePageControlAt(x: int, y: int) -> bool
    if visibleSlots >= c_iInventoryCapacity then return false end

    local controlX: int = InventoryControllerGetPageControlX()
    local controlY: int = InventoryControllerGetPageControlY()
    local action: int = inv_overhaul_inventory_paging.InventoryPagingGetControlAction(
      x, y, controlX, controlY)
    if action == 0 then return false end
    if inv_overhaul_inventory_paging.InventoryPagingCanMove(
      action, InventoryControllerGetMaxPage()) then InventoryControllerChangePage(action) end
    return true
  end

  function InventoryControllerUpdatePageControlHover(x: int, y: int) -> void
    if InventoryControllerGetMaxPage() <= 0 then return end
    local controlX: int = InventoryControllerGetPageControlX()
    local controlY: int = InventoryControllerGetPageControlY()
    local maxPage: int = InventoryControllerGetMaxPage()
    if inv_overhaul_inventory_paging.InventoryPagingIsControlHovered(
      -1, x, y, controlX, controlY, maxPage) then
      native.SendMessage(-94, "page_prev")
    else
      native.SendMessage(-95, "page_prev")
    end
    if inv_overhaul_inventory_paging.InventoryPagingIsControlHovered(
      1, x, y, controlX, controlY, maxPage) then
      native.SendMessage(-94, "page_next")
    else
      native.SendMessage(-95, "page_next")
    end
  end

  function InventoryControllerHandleGlobalProtocolMessage(message: int, sender: string) -> bool
    if message == inv_overhaul_inventory_protocol.QuickslotHelpHover && sender == "panel_background" then
      inv_overhaul_inventory_tooltip.InventoryTooltipShowText(
        inv_overhaul_inventory_protocol.TargetQuickslotHelp, 1407)
      return true
    end
    if message == inv_overhaul_inventory_protocol.GridRendererReady then
      inv_overhaul_inventory_view.InventoryViewMarkRendererReady()
      InventoryControllerTryWarmStartGrid()
      return true
    end
    if message == inv_overhaul_inventory_protocol.PageHoverEnter then
      InventoryControllerBeginDragPageHover(sender)
      return true
    end
    if message == inv_overhaul_inventory_protocol.PageHoverLeave then
      InventoryControllerCancelDragPageHover(InventoryControllerGetDragPageHoverAction(sender))
      return true
    end
    if sender == "panel_background" && message >= inv_overhaul_inventory_protocol.PointerMoveBase then
      InventoryControllerHandlePanelPointer(message)
      return true
    end
    return false
  end

  function InventoryControllerHandleEquipmentProtocolMessage(message: int, sender: string) -> bool
    if message == -43 then
      local unequipTarget: int = inv_overhaul_inventory_protocol.InventoryProtocolGetSpecialTargetBySender(sender)
      InventoryControllerUnequipTarget(unequipTarget, "right click")
      return true
    end

    if message <= -60 && message >= -64 then
      local dollSource: int =
        inv_overhaul_inventory_protocol.InventoryProtocolGetDollTargetBySourceMessage(message, -60)
      if InventoryControllerResolveEquipmentTarget(dollSource) >= 0 then
        InventoryControllerStartDragAction(dollSource, "character_doll")
      end
      return true
    end

    if message <= -70 && message >= -74 then
      local dollTarget: int =
        inv_overhaul_inventory_protocol.InventoryProtocolGetDollTargetBySourceMessage(message, -70)
      InventoryControllerUnequipTarget(dollTarget, "doll right click")
      return true
    end

    if message == -40 then
      if inv_overhaul_inventory_drag.InventoryDragIsActive() then
        local specialTarget: int = inv_overhaul_inventory_protocol.InventoryProtocolGetSpecialTargetBySender(sender)
        if specialTarget >= 0 && InventoryControllerIsSpecialTargetCompatible(specialTarget) then
          inv_overhaul_inventory_drag.InventoryDragSetHoverTarget(specialTarget)
          InventoryControllerApplyPointerSlot(specialTarget)
        else
          inv_overhaul_inventory_drag.InventoryDragSetHoverTarget(-1)
          InventoryControllerApplyPointerSlot(-1)
        end
      else
        InventoryControllerSetHighlightedSlot(inv_overhaul_inventory_protocol.InventoryProtocolGetSpecialTargetBySender(sender))
      end
      return true
    end

    if message <= -50 && message >= -54 then
      if inv_overhaul_inventory_drag.InventoryDragIsActive() then
        local dollTarget: int = inv_overhaul_inventory_protocol.InventoryProtocolGetDollTargetByHoverMessage(message)
        if dollTarget >= 0 && InventoryControllerIsSpecialTargetCompatible(dollTarget) then
          inv_overhaul_inventory_drag.InventoryDragSetHoverTarget(dollTarget)
          InventoryControllerApplyPointerSlot(dollTarget)
        else
          inv_overhaul_inventory_drag.InventoryDragSetHoverTarget(-1)
          InventoryControllerApplyPointerSlot(-1)
        end
      end
      return true
    end

    if message == -42 then
      if inv_overhaul_inventory_drag.InventoryDragIsActive() then
        local releaseTarget: int = inv_overhaul_inventory_protocol.InventoryProtocolGetSpecialTargetBySender(sender)
        if releaseTarget >= 0 && InventoryControllerIsSpecialTargetCompatible(releaseTarget) then
          InventoryControllerApplyPointerSlot(releaseTarget)
          InventoryControllerFinishLeftAction(releaseTarget)
        else
          InventoryControllerCancelDragAction()
        end
      end
      return true
    end

    if message == -41 then
      if inv_overhaul_inventory_drag.InventoryDragIsActive() then
        inv_overhaul_inventory_drag.InventoryDragSetHoverTarget(-1)
        InventoryControllerApplyPointerSlot(-1)
      else
        InventoryControllerSetHighlightedSlot(-1)
      end
      return true
    end
    return false
  end

  function InventoryControllerHandlePagingProtocolMessage(message: int, sender: string) -> bool
    if sender == "page_prev" && message == 0 then
      if inv_overhaul_inventory_paging.InventoryPagingCanMove(
        -1, InventoryControllerGetMaxPage()) then InventoryControllerChangePage(-1) end
      return true
    end
    if sender == "page_next" && message == 0 then
      if inv_overhaul_inventory_paging.InventoryPagingCanMove(
        1, InventoryControllerGetMaxPage()) then InventoryControllerChangePage(1) end
      return true
    end
    return false
  end

  function InventoryControllerHandleSlotPointerProtocolMessage(message: int, sender: string) -> bool
    if message >= c_iDragEndMessageBase then
      local targetSlot: int = InventoryControllerGetCurrentDropSlot(message, c_iDragEndMessageBase, sender)
      InventoryControllerApplyPointerSlot(targetSlot)
      InventoryControllerFinishLeftAction(targetSlot)
      return true
    end

    if message >= c_iReleaseMessageBase then
      local targetSlot: int = InventoryControllerGetCurrentDropSlot(message, c_iReleaseMessageBase, sender)
      InventoryControllerApplyPointerSlot(targetSlot)
      InventoryControllerFinishLeftAction(targetSlot)
      return true
    end

    if message >= c_iHoverMessageBase then
      if inv_overhaul_inventory_drag.InventoryDragIsActive() then
        local hoverTarget: int =
          InventoryControllerGetSlotTargetFromPointerMessage(message, c_iHoverMessageBase, sender)
        inv_overhaul_inventory_drag.InventoryDragSetHoverTarget(hoverTarget)
        InventoryControllerApplyPointerSlot(hoverTarget)
      else
        InventoryControllerSetHighlightedSlot(InventoryControllerGetSlotTargetFromPointerMessage(message, c_iHoverMessageBase, sender))
      end
      return true
    end
    return false
  end

  function InventoryControllerHandleDragLifecycleMessage(message: int, sender: string) -> bool
    if message == 2 || message == 3 then
      local source: int = InventoryControllerGetDragSourceBySender(sender)
      if InventoryControllerHandleModifiedDrop(source) then return true end
      InventoryControllerStartDragAction(source, sender)
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
      if inv_overhaul_inventory_drag.InventoryDragIsActive() then
        inv_overhaul_inventory_drag.InventoryDragSetHoverTarget(-1)
      end
      InventoryControllerSetHighlightedSlot(-1)
      return true
    end

    if message == 8 then
      InventoryControllerFinishLeftAction(InventoryControllerReadHighlightedSlot() + 0)
      return true
    end
    return false
  end

  function InventoryControllerHandleRegularSlotMessage(
    message: int,
    sender: string,
    data: object) -> bool
    if message != 0 && message != 1 then return false end
    if data then return true end
    InventoryControllerHandleSlotMessage(message, sender)
    return true
  end

  function InventoryControllerOnUIMessage(message: int, sender: string, data: object) -> void
    if InventoryControllerHandleGlobalProtocolMessage(message, sender) then return end
    if InventoryControllerHandleEquipmentProtocolMessage(message, sender) then return end
    if InventoryControllerHandlePagingProtocolMessage(message, sender) then return end
    if InventoryControllerHandleSlotPointerProtocolMessage(message, sender) then return end
    if InventoryControllerHandleDragLifecycleMessage(message, sender) then return end
    InventoryControllerHandleRegularSlotMessage(message, sender, data)
  end
  function InventoryControllerOnLButtonDown(x: int, y: int) -> void
    if InventoryControllerHandlePageControlAt(x, y) then return end
    local equipmentTarget: int = InventoryControllerFindEquipmentTargetAt(x, y)
    if equipmentTarget >= 0 && InventoryControllerResolveEquipmentTarget(equipmentTarget) >= 0 then
      InventoryControllerStartDragAction(equipmentTarget, "root")
      return
    end
  end


  function InventoryControllerOnRButtonDown(x: int, y: int) -> void
    local equipmentTarget: int = InventoryControllerFindEquipmentTargetAt(x, y)
    if equipmentTarget >= 0 then
      InventoryControllerUnequipTarget(equipmentTarget, "root right click")
    end
  end

  function InventoryControllerOnMouseMove(x: int, y: int) -> void
    if inv_overhaul_inventory_drag.InventoryDragIsActive() then
      local slot: int = InventoryControllerUpdatePointerSlot(x, y)
      InventoryControllerApplyPointerSlot(slot)
    end
  end

  function InventoryControllerOnMouseLeave() -> void
    if inv_overhaul_inventory_drag.InventoryDragIsActive() then
      InventoryControllerSetHighlightedSlot(-1)
    end
  end

  function InventoryControllerOnLButtonUp(x: int, y: int) -> void
    if inv_overhaul_inventory_drag.InventoryDragIsActive() then
      local targetSlot: int = InventoryControllerUpdatePointerSlot(x, y)
      InventoryControllerApplyPointerSlot(targetSlot)
      InventoryControllerFinishLeftAction(targetSlot)
    end
  end

  function InventoryControllerCloseInventoryWindow() -> void
    if closingWindow then return end
    closingWindow = true
    native.SetNeedUpdate(false)
    native.SetVariable("inv_overhaul_inventory_drag_item", -1)
    native.SetVariable("inv_overhaul_inventory_page_hover", 0)
    native.SendMessage(-200, "panel_background")
    native.SendMessage(-200, "character_doll")
    native.DestroyWindow()
  end

  function InventoryControllerOnChar(char: int) -> void
    if char >= 48 && char <= 57 then return end
    native.Trace("inv_overhaul_inventory OnChar close")
    if inv_overhaul_inventory_layout_runtime.InventoryLayoutRuntimeHasQueuedSave() then
      InventoryControllerSaveLayoutVariables()
    end
    InventoryControllerPersistCurrentBackpackSnapshot()
    InventoryControllerCloseInventoryWindow()
  end

  function InventoryControllerOnKeyDown(key: int) -> void
    native.Trace("inv_overhaul_inventory OnKeyDown " + key)
    if key == c_iVKShift then shiftHeld = true end
    if key == c_iVKControl then controlHeld = true end
    local quickslot: int = InventoryControllerGetQuickslotByKey(key)
    if quickslot > 0 then
      InventoryControllerAssignHoveredQuickslot(quickslot)
      return
    end
    if key == 27 || key == 73 || key == 105 then
      if inv_overhaul_inventory_layout_runtime.InventoryLayoutRuntimeHasQueuedSave() then
        InventoryControllerSaveLayoutVariables()
      end
      InventoryControllerPersistCurrentBackpackSnapshot()
      InventoryControllerCloseInventoryWindow()
    end
  end

  function InventoryControllerOnKeyUp(key: int) -> void
    if key == c_iVKShift then shiftHeld = false end
    if key == c_iVKControl then controlHeld = false end
  end
end
