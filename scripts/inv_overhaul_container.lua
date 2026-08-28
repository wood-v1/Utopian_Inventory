import "inv_overhaul_inventory_layout"
import "inv_overhaul_inventory_layout_runtime"
import "inv_overhaul_inventory_snapshot"
import "inv_overhaul_container_geometry"
import "inv_overhaul_container_drag"
import "inv_overhaul_container_projection"
import "inv_overhaul_container_transfer"
import "inv_overhaul_container_view"
import "inv_overhaul_inventory_tooltip"
import "inv_overhaul_inventory_items"
import "inv_overhaul_inventory_quickslot_bindings"

maintask InvOverhaulContainerUI do
  local const c_sScriptVersion: string = "2026.08.17-native-occupied-slot-exchange-1"
  local const c_iCWeapon: int = 0
  local const c_iCategoryCount: int = 5
  local const c_iInventoryCapacity: int = 56
  local const c_iVKShift: int = 16
  local const c_iVKControl: int = 17
  local const c_iBranchBurah: int = 1
  local const c_iHoverMessageBase: int = 100000
  local const c_iReleaseMessageBase: int = 200000
  local const c_iDragEndMessageBase: int = 300000
  local const c_iPanelPointerMoveBase: int = 1000000
  local const c_iPanelPointerDownBase: int = 4000000
  local const c_iPanelPointerUpBase: int = 7000000
  local const c_iPanelPointerRightBase: int = 10000000
  local const c_iPanelPointerDragBeginBase: int = 13000000
  local const c_iPanelPointerDragEndBase: int = 16000000
  local const c_iPanelPointerLeaveBase: int = 19000000
  local const c_iTargetDrop: int = 200
  local const c_iTargetContainerBase: int = 300
  local const c_iTargetOrganBase: int = 400
  local const c_iTargetMoney: int = 500
  local const c_iTargetPaging: int = 600
  local const c_iTargetQuickslotHelp: int = 601
  local const c_iQuickslotHelpHover: int = 29800001
  local const c_iContainerSlots: int = 12
  local const c_iOrganSlots: int = 4
  local const c_iMaxContainerVisuals: int = 128
  local const c_iWMHelpMessage: int = 200
  local const c_iInventoryFullTextID: int = 1400
  local const c_iContainerFullTextID: int = 1402
  local const c_iCorpseFullTextID: int = 1403
  local const c_iPageHoverEnter: int = -110
  local const c_iPageHoverLeave: int = -111
  local const c_iGridRendererReady: int = 29900000
  local const c_iInitialSlotLoadBatch: int = 1

  local windowWidth: int
  local windowHeight: int
  local visibleSlots: int
  local playerPage: int
  local containerPage: int
  local renderedPlayerPage: int
  local renderedContainerPage: int
  local quickTransferPreviousPlayerPage: int
  local quickTransferPreviousContainerPage: int
  local resolvedCategory: int
  local resolvedIndex: int
  local resolvedContainerIndex: int
  local resolvedContainerOrdinal: int
  local moneyItemID: int
  local isCorpse: bool
  local windowClosing: bool
  local showOrgans: bool
  local corpseVisualPending: bool
  local organVisibilityRefresh: float
  local lastLayoutWidth: int
  local lastLayoutHeight: int
  local deferredInventoryRefresh: float
  local deferredContainerRefresh: float
  local inventoryFullMessageCooldown: float
  local lastContainerMaxPage: int
  local shiftHeld: bool
  local controlHeld: bool
  local initialSlotLoadActive: bool
  local initialPlayerSlotLoadNext: int
  local initialContainerSlotLoadNext: int
  local moneyPollCooldown: float
  local initialSlotLoadPending: bool
  local initialSlotLoadDelay: float
  local initialMetadataStage: int
  local pendingPlayerEntryCategory: int
  local pendingPlayerEntryIndex: int
  local pendingPlayerEntryScanSlot: int

  function init() -> void
    native.Trace("INV_OVERHAUL_INVENTORY_VERSION " + c_sScriptVersion + " screen=container")
    playerPage = 0
    containerPage = 0
    renderedPlayerPage = -1
    renderedContainerPage = -1
    quickTransferPreviousPlayerPage = -1
    quickTransferPreviousContainerPage = -1
    resolvedCategory = -1
    resolvedIndex = -1
    resolvedContainerIndex = -1
    resolvedContainerOrdinal = -1
    inv_overhaul_container_drag.ContainerDragInitializeState()
    inv_overhaul_inventory_tooltip.InventoryTooltipInitializeState()
    initialSlotLoadActive = false
    initialPlayerSlotLoadNext = 0
    initialContainerSlotLoadNext = 0
    moneyPollCooldown = 0.25
    initialSlotLoadPending = true
    initialSlotLoadDelay = 0.05
    lastLayoutWidth = -1
    lastLayoutHeight = -1
    deferredInventoryRefresh = 0
    deferredContainerRefresh = 0
    inventoryFullMessageCooldown = 0
    lastContainerMaxPage = -1
    shiftHeld = false
    controlHeld = false
    corpseVisualPending = false
    windowClosing = false
    organVisibilityRefresh = 0.5
    initialMetadataStage = 0
    pendingPlayerEntryCategory = -1
    pendingPlayerEntryIndex = -1
    pendingPlayerEntryScanSlot = 0
    inv_overhaul_inventory_quickslot_bindings.InventoryQuickslotInitializeState()
    inv_overhaul_inventory_quickslot_bindings.InventoryQuickslotInitializeBindings()
    inv_overhaul_inventory_quickslot_bindings.InventoryQuickslotRefreshCache()
    native.SetVariable("inv_overhaul_inventory_drag_item", -1)
    native.SetVariable("inv_overhaul_inventory_page_hover", 0)
    native.SetCursor("inv_overhaul_inventory")
    native.ShowCursor()
    native.CaptureKeyboard()
    native.SetOwnerDraw(false)
    native.SetNeedUpdate(true)
    inv_overhaul_inventory_tooltip.InventoryTooltipInitializeMoneyItem()
    moneyItemID = inv_overhaul_inventory_tooltip.InventoryTooltipGetMoneyItemID()
    inv_overhaul_inventory_snapshot.InventorySnapshotInitializeState()
    InitSlotOrder()
    inv_overhaul_inventory_items.InventoryItemsInitializeProjection()
    inv_overhaul_container_projection.ContainerProjectionInitialize()
    -- Organ forms are created with the same black default background as the
    -- other loot slots. Hide them before the first ProcessEvents call so a
    -- normal container never renders four corpse slots for one frame.
    for organSlot = 0, c_iOrganSlots - 1 do
      native.SendMessage(
        -22,
        inv_overhaul_container_view.ContainerViewGetOrganSlotWndName(organSlot))
    end
    UpdateLayout()
    native.SendMessage(-201, "panel_background")
    DetectContainerKind()
    if windowClosing then return end
    UpdatePlayerPageControls()
    UpdateContainerPageControls()
    native.ProcessEvents()
  end

  function GetPlayerContainer() -> object
    return inv_overhaul_inventory_items.InventoryItemsGetPlayerContainer()
  end

  function GetExternalContainer() -> object
    local container: object
    native.GetContainer(container)
    return container
  end

  function DetectContainerKind() -> void
    isCorpse = false
    showOrgans = false
    local external: object = GetExternalContainer()
    -- The selected world object may be a generic Container actor (dropped
    -- rubbish heaps use this type). It does not expose the Actor property
    -- interface, and calling HasProperty on it aborts UI init before
    -- ProcessEvents, leaving the player trapped in a static overlay. Corpse
    -- layouts are identified by the engine flag below and by corpse_marker.
    local nativeCorpse: bool = false
    native.IsCorpseContainer(nativeCorpse)
    if nativeCorpse then
      native.Trace("inv_overhaul_container corpse detected by engine container kind")
      ActivateCorpseMode()
      return
    end
    if external then
      local count: int
      external->GetItemCount(count)
      native.Trace("inv_overhaul_container external item count=" + count)
      for index = 0, count - 1 do
        local item: object
        local organ: bool = false
        external->GetItem(item, index)
        item->HasProperty(organ, "Organ")
        if organ then
          native.Trace("inv_overhaul_container corpse detected by organ item")
          ActivateCorpseMode()
          return
        end
      end
    end
    native.Trace("inv_overhaul_container kind awaiting corpse marker")
  end

  function ActivateCorpseMode() -> void
    isCorpse = true
    corpseVisualPending = true
    organVisibilityRefresh = 0.5
    local branch: int = 0
    native.GetVariable("branch", branch)
    showOrgans = branch == c_iBranchBurah
    native.Trace("inv_overhaul_container corpse marker branch=" + branch + " organs=" + showOrgans)
    native.SendMessage(-100, "loot_doll")
    UpdateContainerSlots()
    UpdateOrganSlots()
    deferredContainerRefresh = 0.05
  end

  function InitSlotOrder() -> void
    inv_overhaul_inventory_layout_runtime.InventoryLayoutRuntimeInitialize()
  end

  function GetOrderValue(slot: int) -> int
    return inv_overhaul_inventory_layout_runtime.InventoryLayoutRuntimeGetOrderValue(slot)
  end

  function SetOrderValue(slot: int, value: int) -> void
    inv_overhaul_inventory_layout_runtime.InventoryLayoutRuntimeSetOrderValue(slot, value)
  end

  function ContinueIncrementalLayoutLoad() -> bool
    return inv_overhaul_inventory_layout_runtime.InventoryLayoutRuntimeContinueIncrementalLoad(-1)
  end

  function SaveLayoutVariables() -> void
    inv_overhaul_inventory_layout_runtime.InventoryLayoutRuntimeSaveAll()
  end

  function QueueLayoutSave() -> void
    inv_overhaul_inventory_layout_runtime.InventoryLayoutRuntimeQueueSave()
  end

  function ContinueLayoutSave() -> void
    inv_overhaul_inventory_layout_runtime.InventoryLayoutRuntimeContinueQueuedSave()
  end

  function OrderFreeCellsByDisplay() -> void
    local itemCount: int = GetBackpackItemCount()
    if inv_overhaul_inventory_layout_runtime.InventoryLayoutRuntimeOrderFreeCellsByDisplay(
      itemCount, visibleSlots) then QueueLayoutSave() end
  end

  function UpdateLayout() -> void
    native.GetWindowSize(windowWidth, windowHeight)
    if windowWidth <= 0 || windowHeight <= 0 then native.GetScreenSize(windowWidth, windowHeight) end
    if windowWidth >= 1900 then
      visibleSlots = 35
    else
    if windowWidth >= 1200 then
      visibleSlots = 35
    else
      if windowWidth >= 1000 then visibleSlots = 35 else visibleSlots = 24 end
    end
    end
    if windowWidth != lastLayoutWidth || windowHeight != lastLayoutHeight then
      native.SendMessage(windowWidth, "panel_background")
      native.SendMessage(5000 + windowHeight, "panel_background")
      inv_overhaul_container_view.ContainerViewConfigureSlotRenderSize(
        windowWidth, visibleSlots)
      lastLayoutWidth = windowWidth
      lastLayoutHeight = windowHeight
    end
  end

  function GetVisibleCell(slot: int) -> int
    local linear: int = playerPage * visibleSlots + slot
    return GetCellForLinearSlot(linear)
  end

  function GetCellForLinearSlot(linear: int) -> int
    return inv_overhaul_inventory_layout.InventoryLayoutGetCellForLinearSlot(
      linear, visibleSlots, c_iInventoryCapacity)
  end

  function GetBackpackItemCount() -> int
    return inv_overhaul_inventory_items.InventoryItemsGetBackpackCount()
  end

  function GetCachedBackpackItemCount() -> int
    return inv_overhaul_inventory_items.InventoryItemsGetCachedBackpackCount()
  end

  function ShowInventoryFull() -> void
    if inventoryFullMessageCooldown > 0 then return end
    local text: object
    native.CreateIntVector(text)
    text->add(c_iInventoryFullTextID)
    native.SendWorldWndMessage(c_iWMHelpMessage, text)
    inventoryFullMessageCooldown = 1.0
  end

  function ShowContainerFull() -> void
    if inventoryFullMessageCooldown > 0 then return end
    local text: object
    native.CreateIntVector(text)
    if isCorpse then text->add(c_iCorpseFullTextID) else text->add(c_iContainerFullTextID) end
    native.SendWorldWndMessage(c_iWMHelpMessage, text)
    inventoryFullMessageCooldown = 1.0
  end

  function GetMaxPlayerPage() -> int
    return inv_overhaul_inventory_layout.InventoryLayoutGetMaxPage(
      c_iInventoryCapacity, visibleSlots)
  end

  function ClampPlayerPage() -> void
    local maxPage: int = GetMaxPlayerPage()
    if playerPage < 0 then playerPage = 0 end
    if playerPage > maxPage then playerPage = maxPage end
  end

  function ResolveVisibleSlot(slot: int) -> bool
    resolvedCategory = -1
    resolvedIndex = -1
    local target: int = GetOrderValue(GetVisibleCell(slot))
    if target < 0 || target >= c_iInventoryCapacity then return false end
    resolvedCategory = inv_overhaul_inventory_items.InventoryItemsGetCachedCategory(target)
    resolvedIndex = inv_overhaul_inventory_items.InventoryItemsGetCachedIndex(target)
    return resolvedCategory >= 0 && resolvedIndex >= 0
  end

  function BuildPlayerIndexCache() -> void
    inv_overhaul_inventory_items.InventoryItemsBuildIndexCache()
  end

  function GetAppendedCategoryBackpackOrdinal(category: int, beforeCount: int) -> int
    -- The vectors contain exactly the 56 visible backpack entries. Saves
    -- with overflow are intentionally preserved, but must never be used as
    -- vector bounds by the incremental transfer path.
    if beforeCount < 0 || beforeCount > c_iInventoryCapacity then return -1 end
    return inv_overhaul_inventory_items.InventoryItemsGetAppendedCategoryOrdinal(
      category, beforeCount)
  end

  function InsertPlayerIndexCacheAt(
    insertedOrdinal: int,
    beforeCount: int,
    category: int,
    index: int
  ) -> bool
    if beforeCount < 0 || beforeCount >= c_iInventoryCapacity ||
      insertedOrdinal < 0 || insertedOrdinal > beforeCount ||
      category < 0 || category >= c_iCategoryCount || index < 0 then
      native.Trace("inv_overhaul_container cache insert rejected ordinal=" +
        insertedOrdinal + " before=" + beforeCount + " category=" + category +
        " index=" + index)
      BuildPlayerIndexCache()
      return false
    end
    inv_overhaul_inventory_items.InventoryItemsInsertCachedEntry(
      insertedOrdinal, beforeCount, category, index)
    return true
  end

  function RemovePlayerIndexCacheAt(
    removedOrdinal: int,
    beforeCount: int,
    removedCategory: int,
    removedIndex: int
  ) -> bool
    if beforeCount <= 0 || beforeCount > c_iInventoryCapacity ||
      removedOrdinal < 0 || removedOrdinal >= beforeCount ||
      removedCategory < 0 || removedCategory >= c_iCategoryCount || removedIndex < 0 then
      native.Trace("inv_overhaul_container cache remove rejected ordinal=" +
        removedOrdinal + " before=" + beforeCount + " category=" + removedCategory +
        " index=" + removedIndex)
      BuildPlayerIndexCache()
      return false
    end
    inv_overhaul_inventory_items.InventoryItemsRemoveCachedEntry(
      removedOrdinal, beforeCount, removedCategory, removedIndex)
    return true
  end

  function QueueCachedPlayerEntryRefresh(category: int, index: int) -> void
    pendingPlayerEntryCategory = category
    pendingPlayerEntryIndex = index
    pendingPlayerEntryScanSlot = 0
  end

  function ContinueCachedPlayerEntryRefresh() -> void
    if pendingPlayerEntryCategory < 0 || pendingPlayerEntryIndex < 0 then return end
    if pendingPlayerEntryScanSlot >= visibleSlots then
      pendingPlayerEntryCategory = -1
      pendingPlayerEntryIndex = -1
      pendingPlayerEntryScanSlot = 0
      UpdatePlayerPageControls()
      return
    end
    local slot: int = pendingPlayerEntryScanSlot
    pendingPlayerEntryScanSlot = pendingPlayerEntryScanSlot + 1
    local ordinal: int = GetOrderValue(GetVisibleCell(slot))
    local cachedCount: int = GetCachedBackpackItemCount()
    if ordinal >= 0 && ordinal < cachedCount && ordinal < c_iInventoryCapacity then
      local cachedCategory: int =
        inv_overhaul_inventory_items.InventoryItemsGetCachedCategory(ordinal)
      local cachedIndex: int =
        inv_overhaul_inventory_items.InventoryItemsGetCachedIndex(ordinal)
      if cachedCategory == pendingPlayerEntryCategory && cachedIndex == pendingPlayerEntryIndex then
        UpdatePlayerSlot(slot)
        pendingPlayerEntryCategory = -1
        pendingPlayerEntryIndex = -1
        pendingPlayerEntryScanSlot = 0
        UpdatePlayerPageControls()
      end
    end
  end

  function GetVisibleSlotForCell(cell: int) -> int
    if cell < 0 then return -1 end
    for slot = 0, visibleSlots - 1 do
      if GetVisibleCell(slot) == cell then return slot end
    end
    return -1
  end

  function GetNormalContainerItemCount() -> int
    local container: object = GetExternalContainer()
    return inv_overhaul_container_projection.ContainerProjectionGetNormalItemCount(container)
  end

  function ApplyResolvedContainerReference(reference: int) -> bool
    resolvedContainerIndex = -1
    resolvedContainerOrdinal = -1
    if reference < 0 then return false end
    resolvedContainerIndex = inv_overhaul_container_projection.ContainerProjectionGetReferenceIndex(reference)
    resolvedContainerOrdinal = inv_overhaul_container_projection.ContainerProjectionGetReferenceOrdinal(reference)
    return resolvedContainerIndex >= 0 && resolvedContainerOrdinal >= 0
  end

  function ResolveNormalContainerOrdinal(ordinal: int) -> bool
    local reference: int = inv_overhaul_container_projection.ContainerProjectionResolveNormalOrdinal(ordinal)
    return ApplyResolvedContainerReference(reference)
  end

  function BuildContainerIndexCache() -> void
    local container: object = GetExternalContainer()
    inv_overhaul_container_projection.ContainerProjectionBuildIndexCache(container)
  end

  function ResolveContainerVisualSlot(slot: int) -> bool
    local visual: int = containerPage * c_iContainerSlots + slot
    return ResolveNormalContainerOrdinal(
      inv_overhaul_container_projection.ContainerProjectionGetContainerOrder(visual))
  end

  function ResolveOrganVisualSlot(slot: int) -> bool
    if !showOrgans then return false end
    resolvedContainerIndex = -1
    resolvedContainerOrdinal = slot
    local container: object = GetExternalContainer()
    local reference: int = inv_overhaul_container_projection.ContainerProjectionResolveOrganVisual(container, slot)
    if reference < 0 then return false end
    resolvedContainerIndex = inv_overhaul_container_projection.ContainerProjectionGetReferenceIndex(reference)
    resolvedContainerOrdinal = inv_overhaul_container_projection.ContainerProjectionGetReferenceOrdinal(reference)
    return resolvedContainerIndex >= 0
  end

  function ClampContainerPage() -> void
    local maxPage: int =
      inv_overhaul_container_projection.ContainerProjectionGetMaxPage()
    if containerPage < 0 then containerPage = 0 end
    if containerPage > maxPage then containerPage = maxPage end
  end

  function UpdatePlayerPageControls() -> void
    local maxPage: int = GetMaxPlayerPage()
    inv_overhaul_container_view.ContainerViewResetPageControls(
      "player_", -114, -115)
    inv_overhaul_container_view.ContainerViewUpdatePageControls(
      "player_", playerPage, maxPage)
  end

  function UpdateContainerPageControls() -> void
    local maxPage: int =
      inv_overhaul_container_projection.ContainerProjectionGetMaxPage()
    inv_overhaul_container_view.ContainerViewResetPageControls(
      "container_", -116, -117)
    if maxPage != lastContainerMaxPage then
      native.Trace("inv_overhaul_container pages count=" + inv_overhaul_container_projection.ContainerProjectionGetCachedNormalCount() + " max=" + maxPage + " current=" + containerPage + " corpse=" + isCorpse)
      lastContainerMaxPage = maxPage
    end
    inv_overhaul_container_view.ContainerViewUpdatePageControls(
      "container_", containerPage, maxPage)
  end

  function UpdateMoney() -> void
    local container: object = GetPlayerContainer()
    local money: int
    container->GetProperty("money", money)
    native.SendMessage(money, "money")
  end

  function GetDisplayedQuickslot(category: int, index: int, itemID: int) -> int
    return inv_overhaul_inventory_quickslot_bindings.InventoryQuickslotGetDisplayedBinding(
      category, index, itemID)
  end

  function AssignQuickslot(slot: int, category: int, index: int) -> void
    if inv_overhaul_inventory_quickslot_bindings.InventoryQuickslotAssign(
      slot, category, index, false) then UpdatePlayerSlots() end
  end

  function GetQuickslotByKey(key: int) -> int
    return inv_overhaul_inventory_quickslot_bindings.InventoryQuickslotGetSlotByKey(key)
  end

  function AssignHoveredQuickslot(slot: int) -> void
    if inv_overhaul_container_drag.ContainerDragIsActive() then return end
    local target: int =
      inv_overhaul_container_drag.ContainerDragGetHighlightedTarget()
    if target < 0 then
      target = inv_overhaul_inventory_tooltip.InventoryTooltipGetTarget()
    end
    if target < 0 || target >= visibleSlots then return end
    if ResolveVisibleSlot(target) then
      AssignQuickslot(slot, resolvedCategory, resolvedIndex)
    end
  end

  function UpdatePlayerSlot(slot: int) -> void
    local container: object = GetPlayerContainer()
    local wnd: string =
      inv_overhaul_container_view.ContainerViewGetPlayerSlotWndName(slot)
    if GetVisibleCell(slot) < 0 then
      inv_overhaul_container_view.ContainerViewRenderPlayerSlotUnavailable(wnd)
    else
      inv_overhaul_container_view.ContainerViewBeginPlayerSlot(wnd)
      if ResolveVisibleSlot(slot) then
        local item: object
        local amount: int
        container->GetItem(item, resolvedIndex, resolvedCategory)
        container->GetItemAmount(amount, resolvedIndex, resolvedCategory)
        inv_overhaul_container_view.ContainerViewRenderPlayerSlotItem(
          wnd, item, amount)
        local itemID: int
        item->GetItemID(itemID)
        local quickslot: int = GetDisplayedQuickslot(resolvedCategory, resolvedIndex, itemID)
        inv_overhaul_container_view.ContainerViewRenderPlayerQuickslot(
          wnd, quickslot)
      else
        inv_overhaul_container_view.ContainerViewRenderPlayerSlotEmpty(wnd)
      end
    end
  end

  function UpdatePlayerSlots() -> void
    ClampPlayerPage()
    BuildPlayerIndexCache()
    for slot = 0, visibleSlots - 1 do UpdatePlayerSlot(slot) end
    renderedPlayerPage = playerPage
    UpdatePlayerPageControls()
  end

  function UpdateContainerSlot(slot: int) -> void
    local container: object = GetExternalContainer()
    local wnd: string =
      inv_overhaul_container_view.ContainerViewGetContainerSlotWndName(slot)
    if ResolveContainerVisualSlot(slot) then
      local item: object
      local amount: int
      container->GetItem(item, resolvedContainerIndex)
      container->GetItemAmount(amount, resolvedContainerIndex)
      inv_overhaul_container_view.ContainerViewRenderContainerSlotItem(
        wnd, item, amount)
    else
      inv_overhaul_container_view.ContainerViewRenderContainerSlotEmpty(wnd)
    end
  end

  function UpdateContainerSlots() -> void
    BuildContainerIndexCache()
    ClampContainerPage()
    for slot = 0, c_iContainerSlots - 1 do UpdateContainerSlot(slot) end
    renderedContainerPage = containerPage
    UpdateContainerPageControls()
  end

  function UpdateOrganSlots() -> void
    local container: object = GetExternalContainer()
    for slot = 0, c_iOrganSlots - 1 do
      local wnd: string =
        inv_overhaul_container_view.ContainerViewGetOrganSlotWndName(slot)
      if !isCorpse || !showOrgans then
        inv_overhaul_container_view.ContainerViewRenderOrganSlotHidden(wnd)
      else
        inv_overhaul_container_view.ContainerViewBeginOrganSlot(wnd)
        if ResolveOrganVisualSlot(slot) then
          inv_overhaul_container_view.ContainerViewBeginOrganSlotItem(wnd)
          local item: object
          local amount: int
          container->GetItem(item, resolvedContainerIndex)
          container->GetItemAmount(amount, resolvedContainerIndex)
          inv_overhaul_container_view.ContainerViewRenderOrganSlotItem(
            wnd, item, amount)
        else
          inv_overhaul_container_view.ContainerViewRenderOrganSlotEmpty(wnd)
        end
      end
    end
  end

  function UpdateAllSlots() -> void
    initialSlotLoadActive = false
    UpdateLayout()
    UpdatePlayerSlots()
    UpdateContainerSlots()
    UpdateOrganSlots()
    UpdateMoney()
  end

  function RefreshVisibleContainerItem(itemID: int, fallbackSlot: int) -> void
    initialSlotLoadActive = false
    if renderedContainerPage != containerPage then
      UpdateContainerSlots()
      return
    end
    BuildContainerIndexCache()
    local fallbackUpdated: bool = false
    for slot = 0, c_iContainerSlots - 1 do
      local update: bool = false
      if slot == fallbackSlot then update = true end
      if ResolveContainerVisualSlot(slot) then
        local external: object = GetExternalContainer()
        local item: object
        local visibleItemID: int = -1
        external->GetItem(item, resolvedContainerIndex)
        if item then item->GetItemID(visibleItemID) end
        if visibleItemID == itemID then update = true end
      end
      if update then
        UpdateContainerSlot(slot)
        if slot == fallbackSlot then fallbackUpdated = true end
      end
    end
    if !fallbackUpdated && fallbackSlot >= 0 && fallbackSlot < c_iContainerSlots then UpdateContainerSlot(fallbackSlot) end
    UpdateContainerPageControls()
  end

  function BeginInitialSlotLoad() -> void
    UpdateLayout()
    ClampPlayerPage()
    BuildPlayerIndexCache()
    BuildContainerIndexCache()
    ClampContainerPage()
    UpdatePlayerPageControls()
    UpdateContainerPageControls()
    UpdateOrganSlots()
    UpdateMoney()
    initialPlayerSlotLoadNext = 0
    initialContainerSlotLoadNext = 0
    initialSlotLoadActive = true
    native.Trace("inv_overhaul_container deferred initial slots player=" + visibleSlots + " container=" + c_iContainerSlots)
  end

  function ContinueInitialSlotLoad() -> void
    if !initialSlotLoadActive then return end
    for batch = 0, c_iInitialSlotLoadBatch - 1 do
      if initialContainerSlotLoadNext < c_iContainerSlots then
        UpdateContainerSlot(initialContainerSlotLoadNext)
        initialContainerSlotLoadNext = initialContainerSlotLoadNext + 1
      else
        if initialPlayerSlotLoadNext < visibleSlots then
        UpdatePlayerSlot(initialPlayerSlotLoadNext)
        initialPlayerSlotLoadNext = initialPlayerSlotLoadNext + 1
        end
      end
    end
    if initialContainerSlotLoadNext >= c_iContainerSlots && initialPlayerSlotLoadNext >= visibleSlots then
      initialSlotLoadActive = false
      native.Trace("inv_overhaul_container sequential initial slots complete batch=" +
        c_iInitialSlotLoadBatch)
    end
  end

  function SwapSlotOrderCells(sourceCell: int, targetCell: int) -> void
    if sourceCell == targetCell then return end
    if sourceCell < 0 || targetCell < 0 then return end
    local sourceOrder: int = GetOrderValue(sourceCell)
    local targetOrder: int = GetOrderValue(targetCell)
    SetOrderValue(sourceCell, targetOrder)
    SetOrderValue(targetCell, sourceOrder)
    QueueLayoutSave()
    for visibleSlot = 0, visibleSlots - 1 do
      local visibleCell: int = GetVisibleCell(visibleSlot)
      if visibleCell == sourceCell || visibleCell == targetCell then UpdatePlayerSlot(visibleSlot) end
    end
  end

  function SwapContainerSlotOrderVisuals(sourceVisual: int, targetVisual: int) -> void
    if sourceVisual < 0 || sourceVisual >= c_iMaxContainerVisuals then return end
    if targetVisual < 0 || targetVisual >= c_iMaxContainerVisuals || sourceVisual == targetVisual then return end
    local sourceOrder: int =
      inv_overhaul_container_projection.ContainerProjectionGetContainerOrder(sourceVisual)
    local targetOrder: int =
      inv_overhaul_container_projection.ContainerProjectionGetContainerOrder(targetVisual)
    inv_overhaul_container_projection.ContainerProjectionSetContainerOrder(
      sourceVisual, targetOrder)
    inv_overhaul_container_projection.ContainerProjectionSetContainerOrder(
      targetVisual, sourceOrder)
    UpdateContainerSlots()
  end

  function RemoveOrderOrdinal(removedOrder: int, beforeCount: int) -> void
    if removedOrder < 0 then return end
    local emptyOrder: int = beforeCount - 1
    for slot = 0, c_iInventoryCapacity - 1 do
      local order: int = GetOrderValue(slot)
      if order == removedOrder then
        SetOrderValue(slot, emptyOrder)
      else
        if order > removedOrder && order < beforeCount then SetOrderValue(slot, order - 1) end
      end
    end
    QueueLayoutSave()
  end

  function FindFirstFreePlayerVisual(itemCount: int) -> int
    for linear = 0, c_iInventoryCapacity - 1 do
      local cell: int = GetCellForLinearSlot(linear)
      if cell >= 0 && GetOrderValue(cell) >= itemCount then return cell end
    end
    return -1
  end

  function GetBackpackOrdinal(category: int, index: int) -> int
    return inv_overhaul_inventory_items.InventoryItemsGetBackpackOrdinal(category, index)
  end

  function PersistCurrentPlayerSnapshot() -> void
    inv_overhaul_inventory_snapshot.InventorySnapshotPersistCurrent()
  end

  function InitializePersistentPlayerSnapshot() -> void
    if inv_overhaul_inventory_snapshot.InventorySnapshotCanReusePersistent() then
      inv_overhaul_inventory_snapshot.InventorySnapshotCapturePrevious()
      return
    end

    local currentCount: int =
      inv_overhaul_inventory_snapshot.InventorySnapshotCaptureCurrentCount()
    if currentCount > c_iInventoryCapacity then currentCount = c_iInventoryCapacity end
    local loaded: bool =
      inv_overhaul_inventory_snapshot.InventorySnapshotLoadPersistent()
    local changed: bool =
      loaded && inv_overhaul_inventory_snapshot.InventorySnapshotDiffers(currentCount)
    if changed then
      local oldCount: int =
        inv_overhaul_inventory_snapshot.InventorySnapshotGetLastBackpackItemCount()
      inv_overhaul_inventory_snapshot.InventorySnapshotReconcile(
        currentCount, visibleSlots)
      QueueLayoutSave()
      native.Trace("inv_overhaul_container persistent snapshot reconciled old=" +
        oldCount + " current=" + currentCount)
    end

    inv_overhaul_inventory_snapshot.InventorySnapshotCopyCurrent(currentCount)
    -- Persist after every fallback comparison so an older save that lacks the
    -- content-generation stamp is migrated after its stored IDs are checked.
    inv_overhaul_inventory_snapshot.InventorySnapshotSavePersistent()
    if !loaded then
      native.Trace("inv_overhaul_container persistent snapshot initialized count=" +
      currentCount)
    end
  end

  function InsertOrderOrdinalAt(insertedOrder: int, beforeCount: int, preferredSlot: int) -> bool
    if insertedOrder < 0 then return false end
    if beforeCount >= c_iInventoryCapacity then return false end
    -- The cell carrying exactly beforeCount is the first free ordinal. Using
    -- that exact cell keeps the shared layout a permutation after the ordinal
    -- shift; a full normalize/order-free-cells pass is unnecessary.
    local insertedSlot: int = -1
    for slot = 0, c_iInventoryCapacity - 1 do
      if GetOrderValue(slot) == beforeCount then insertedSlot = slot end
    end
    if insertedSlot < 0 then return false end
    for slot = 0, c_iInventoryCapacity - 1 do
      local order: int = GetOrderValue(slot)
      if slot != insertedSlot && order >= insertedOrder && order < beforeCount then SetOrderValue(slot, order + 1) end
    end
    SetOrderValue(insertedSlot, insertedOrder)
    local preferredCell: int = GetVisibleCell(preferredSlot)
    if preferredSlot >= 0 && preferredSlot < visibleSlots && preferredCell != insertedSlot then
      local preferredOrder: int = GetOrderValue(preferredCell)
      SetOrderValue(preferredCell, insertedOrder)
      SetOrderValue(insertedSlot, preferredOrder)
    end
    QueueLayoutSave()
    return true
  end

  function InsertContainerOrdinalAt(insertedOrder: int, beforeCount: int, preferredSlot: int) -> bool
    return inv_overhaul_container_projection.ContainerProjectionInsertContainerOrdinalAt(
      containerPage, insertedOrder, beforeCount, preferredSlot)
  end

  function MovePlayerAmountToContainer(sourceSlot: int, targetSlot: int, requestedAmount: int) -> void
    local category: int = -1
    local index: int = -1
    if inv_overhaul_container_drag.ContainerDragGetKind() == 0 &&
      inv_overhaul_container_drag.ContainerDragGetPlayerCategory() >= 0 &&
      inv_overhaul_container_drag.ContainerDragGetPlayerIndex() >= 0 then
      category = inv_overhaul_container_drag.ContainerDragGetPlayerCategory()
      index = inv_overhaul_container_drag.ContainerDragGetPlayerIndex()
    else
      if !ResolveVisibleSlot(sourceSlot) then return end
      category = resolvedCategory
      index = resolvedIndex
    end
    local player: object = GetPlayerContainer()
    local external: object = GetExternalContainer()
    if !external then return end

    local beforeBackpack: int = GetCachedBackpackItemCount()
    if beforeBackpack < 0 then
      BuildPlayerIndexCache()
      beforeBackpack = GetCachedBackpackItemCount()
    end
    local sourceCell: int = GetVisibleCell(sourceSlot)
    if inv_overhaul_container_drag.ContainerDragGetKind() == 0 &&
      inv_overhaul_container_drag.ContainerDragGetPlayerCell() >= 0 then
      sourceCell = inv_overhaul_container_drag.ContainerDragGetPlayerCell()
    end
    local usedOrder: int = GetOrderValue(sourceCell)
    if usedOrder < 0 || usedOrder >= beforeBackpack then usedOrder = GetBackpackOrdinal(category, index) end
    local beforeCategoryCount: int
    player->GetItemCount(beforeCategoryCount, category)
    local beforeExternal: int = GetNormalContainerItemCount()
    if beforeExternal >= c_iMaxContainerVisuals then
      ShowContainerFull()
      return
    end
    local item: object
    player->GetItem(item, index, category)
    if !item then return end
    local availableAmount: int
    player->GetItemAmount(availableAmount, index, category)
    local transferAmount: int =
      inv_overhaul_container_transfer.ContainerTransferNormalizeAmount(
        requestedAmount, availableAmount)
    if transferAmount <= 0 then return end
    local itemID: int
    item->GetItemID(itemID)
    local beforeExternalAmount: int =
      inv_overhaul_container_transfer.ContainerTransferGetExternalItemTotalAmount(
        external, itemID)

    local success: bool
    external->AddItem(success, item, 0, transferAmount)
    local afterExternalAmount: int =
      inv_overhaul_container_transfer.ContainerTransferGetExternalItemTotalAmount(
        external, itemID)
    local addedAmount: int = afterExternalAmount - beforeExternalAmount
    if !success || addedAmount <= 0 then
      ShowContainerFull()
      native.Trace("inv_overhaul_container player-to-container rejected slot=" + sourceSlot + " success=" + success + " before_amount=" + beforeExternalAmount + " after_amount=" + afterExternalAmount)
      RefreshVisibleContainerItem(itemID, targetSlot)
      return
    end

    if category == c_iCWeapon then
      local selected: bool
      player->IsItemSelected(selected, index, category)
      if selected then native.SetPlayerHandsItem(-1) end
    end
    if addedAmount > transferAmount then addedAmount = transferAmount end
    player->RemoveItem(index, addedAmount, category)

    local afterCategoryCount: int
    player->GetItemCount(afterCategoryCount, category)
    local afterBackpack: int = GetBackpackItemCount()
    if afterBackpack < beforeBackpack then
      if RemovePlayerIndexCacheAt(usedOrder, beforeBackpack, category, index) then
        RemoveOrderOrdinal(usedOrder, beforeBackpack)
      end
    end
    local afterExternal: int = GetNormalContainerItemCount()
    if quickTransferPreviousContainerPage >= 0 && afterExternal == beforeExternal then
      containerPage = quickTransferPreviousContainerPage
    end
    if afterExternal > beforeExternal then
      InsertContainerOrdinalAt(beforeExternal, beforeExternal, targetSlot)
    end
    if beforeExternal <= c_iContainerSlots && afterExternal > c_iContainerSlots then
      native.Trace("inv_overhaul_container corpse/container page 2 activated count=" + afterExternal)
    end
    local visibleSourceSlot: int = GetVisibleSlotForCell(sourceCell)
    if visibleSourceSlot >= 0 then
      UpdatePlayerSlot(visibleSourceSlot)
      UpdatePlayerPageControls()
    end
    RefreshVisibleContainerItem(itemID, targetSlot)
    UpdateMoney()
  end

  function MovePlayerToContainer(sourceSlot: int, targetSlot: int) -> void
    MovePlayerAmountToContainer(sourceSlot, targetSlot, 1)
  end

  function ExchangePlayerWithContainer(sourceSlot: int, targetSlot: int) -> void
    if !ResolveContainerVisualSlot(targetSlot) then
      MovePlayerToContainer(sourceSlot, targetSlot)
      return
    end

    -- Preserve the real entry under the occupied visual cell. Adding the
    -- player's item may append another native entry and changes only the
    -- visual order; the original entry itself keeps this index/ordinal.
    local exchangedContainerIndex: int = resolvedContainerIndex
    local exchangedContainerOrdinal: int = resolvedContainerOrdinal
    local external: object = GetExternalContainer()
    local exchangedItem: object
    local exchangedAmount: int
    local externalCountBefore: int
    external->GetItem(exchangedItem, exchangedContainerIndex)
    external->GetItemAmount(exchangedAmount, exchangedContainerIndex)
    external->GetItemCount(externalCountBefore)
    if !exchangedItem then return end

    local sourceCategory: int = -1
    local sourceIndex: int = -1
    if inv_overhaul_container_drag.ContainerDragGetPlayerCategory() >= 0 &&
      inv_overhaul_container_drag.ContainerDragGetPlayerIndex() >= 0 then
      sourceCategory = inv_overhaul_container_drag.ContainerDragGetPlayerCategory()
      sourceIndex = inv_overhaul_container_drag.ContainerDragGetPlayerIndex()
    else
      if !ResolveVisibleSlot(sourceSlot) then return end
      sourceCategory = resolvedCategory
      sourceIndex = resolvedIndex
    end
    local player: object = GetPlayerContainer()
    local sourceItem: object
    local sourceAmount: int
    player->GetItem(sourceItem, sourceIndex, sourceCategory)
    player->GetItemAmount(sourceAmount, sourceIndex, sourceCategory)
    if !sourceItem || sourceAmount <= 0 then return end
    local sourceItemID: int
    sourceItem->GetItemID(sourceItemID)
    local beforeSourceAmount: int =
      inv_overhaul_container_transfer.ContainerTransferGetPlayerItemTotalAmount(
        player, sourceCategory, sourceItemID)

    -- If moving one unit does not free a backpack cell, the incoming stack
    -- still has to fit normally. Never remove the container item first.
    local cachedCount: int = GetCachedBackpackItemCount()
    if cachedCount < 0 then
      BuildPlayerIndexCache()
      cachedCount = GetCachedBackpackItemCount()
    end
    if cachedCount >= c_iInventoryCapacity && sourceAmount > 1 then
      local exchangedItemID: int
      local exchangedCategory: int
      exchangedItem->GetItemID(exchangedItemID)
      native.GetInvItemProperty(exchangedCategory, exchangedItemID, "Category")
      local exchangedMergeIndex: int =
        inv_overhaul_container_transfer.ContainerTransferFindPlayerMergeIndex(
          player, exchangedCategory, exchangedItemID)
      if exchangedMergeIndex < 0 then
        ShowInventoryFull()
        return
      end
    end

    MovePlayerToContainer(sourceSlot, targetSlot)
    local afterSourceAmount: int =
      inv_overhaul_container_transfer.ContainerTransferGetPlayerItemTotalAmount(
        player, sourceCategory, sourceItemID)
    if afterSourceAmount >= beforeSourceAmount then return end

    -- AddItem appends a new non-stackable entry. Exchange that native entry
    -- with the occupied target before removing the displaced item. The
    -- physical container order then matches the visible order and survives
    -- closing/reopening the loot window without a sidecar layout cache.
    local exchangedMovedToIndex: int = exchangedContainerIndex
    local exchangedMovedToOrdinal: int = exchangedContainerOrdinal
    local appendedIndex: int =
      inv_overhaul_container_transfer.ContainerTransferSwapAppendedEntry(
        external, exchangedItem, exchangedAmount, exchangedContainerIndex,
        sourceItemID, externalCountBefore)
    if appendedIndex >= 0 then
      BuildContainerIndexCache()
      for visual = 0, c_iMaxContainerVisuals - 1 do
        inv_overhaul_container_projection.ContainerProjectionSetContainerOrder(
          visual, visual)
      end
      exchangedMovedToIndex = appendedIndex
      exchangedMovedToOrdinal =
        inv_overhaul_container_projection.ContainerProjectionGetCachedNormalCount() - 1
    end

    -- Route the displaced native entry back into the player's vacated visual
    -- cell. The direct indices prevent a page/order lookup from selecting one
    -- of the many identical masks in this reproduction case.
    MoveResolvedExternalAmountToPlayer(
      false, exchangedMovedToIndex, exchangedMovedToOrdinal,
      targetSlot, sourceSlot, -1)
    UpdateContainerSlots()
    native.Trace("inv_overhaul_container exchanged occupied container slot=" + targetSlot)
  end

  function MoveExternalAmountToPlayer(organSource: bool, sourceSlot: int, targetSlot: int, requestedAmount: int) -> void
    local sourceIndex: int = -1
    local sourceOrdinal: int = -1
    if inv_overhaul_container_drag.ContainerDragGetKind() >= 1 &&
      inv_overhaul_container_drag.ContainerDragGetContainerIndex() >= 0 then
      sourceIndex = inv_overhaul_container_drag.ContainerDragGetContainerIndex()
      sourceOrdinal = inv_overhaul_container_drag.ContainerDragGetContainerOrdinal()
    else
      local found: bool
      if organSource then found = ResolveOrganVisualSlot(sourceSlot) else found = ResolveContainerVisualSlot(sourceSlot) end
      if !found then return end
      sourceIndex = resolvedContainerIndex
      sourceOrdinal = resolvedContainerOrdinal
    end
    MoveResolvedExternalAmountToPlayer(
      organSource, sourceIndex, sourceOrdinal, sourceSlot, targetSlot, requestedAmount)
  end

  function MoveResolvedExternalAmountToPlayer(
    organSource: bool,
    sourceIndex: int,
    sourceOrdinal: int,
    sourceSlot: int,
    targetSlot: int,
    requestedAmount: int) -> void
    local external: object = GetExternalContainer()
    local player: object = GetPlayerContainer()
    local beforeNormal: int = GetNormalContainerItemCount()
    local beforeBackpack: int = GetCachedBackpackItemCount()
    if beforeBackpack < 0 then
      BuildPlayerIndexCache()
      beforeBackpack = GetCachedBackpackItemCount()
    end
    local item: object
    local amount: int
    external->GetItem(item, sourceIndex)
    external->GetItemAmount(amount, sourceIndex)
    if !item || amount <= 0 then return end
    local transferAmount: int =
      inv_overhaul_container_transfer.ContainerTransferNormalizeAmount(
        requestedAmount, amount)
    if transferAmount <= 0 then return end

    local itemID: int
    item->GetItemID(itemID)
    if itemID == moneyItemID then
      local money: int
      player->GetProperty("money", money)
      player->SetProperty("money", money + amount)
      external->RemoveItem(sourceIndex, amount)
      if !organSource then
        inv_overhaul_container_projection.ContainerProjectionRemoveContainerOrdinal(
          sourceOrdinal, beforeNormal)
      end
      native.Trace("inv_overhaul_container took money amount=" + amount)
      if organSource then UpdateOrganSlots() else RefreshVisibleContainerItem(itemID, sourceSlot) end
      UpdateMoney()
      return
    end

    local category: int
    native.GetInvItemProperty(category, itemID, "Category")
    local mergeIndex: int =
      inv_overhaul_container_transfer.ContainerTransferFindPlayerMergeIndex(
        player, category, itemID)
    if beforeBackpack >= c_iInventoryCapacity && mergeIndex < 0 then
      ShowInventoryFull()
      native.Trace("inv_overhaul_container container-to-player refused: inventory full")
      return
    end
    local beforePlayerAmount: int =
      inv_overhaul_container_transfer.ContainerTransferGetPlayerItemTotalAmount(
        player, category, itemID)
    local beforeCategoryCount: int
    player->GetItemCount(beforeCategoryCount, category)
    if organSource then
      item->SetProperty("InvOverhaulOrgan", 1)
      item->RemoveProperty("Organ")
    end
    local success: bool
    player->AddItem(success, item, category, transferAmount)
    local afterPlayerAmount: int =
      inv_overhaul_container_transfer.ContainerTransferGetPlayerItemTotalAmount(
        player, category, itemID)
    local addedAmount: int = afterPlayerAmount - beforePlayerAmount
    if !success || addedAmount <= 0 then
      if organSource then
        item->RemoveProperty("InvOverhaulOrgan")
        item->SetProperty("Organ", 1)
      end
      ShowInventoryFull()
      native.Trace("inv_overhaul_container container-to-player rejected source=" + sourceSlot + " success=" + success + " before_amount=" + beforePlayerAmount + " after_amount=" + afterPlayerAmount)
      if organSource then UpdateOrganSlots() else RefreshVisibleContainerItem(itemID, sourceSlot) end
      return
    end

    if addedAmount > transferAmount then addedAmount = transferAmount end
    external->RemoveItem(sourceIndex, addedAmount)
    if addedAmount >= amount then
      if !organSource then
        inv_overhaul_container_projection.ContainerProjectionRemoveContainerOrdinal(
          sourceOrdinal, beforeNormal)
      end
    end

    local afterCategoryCount: int
    player->GetItemCount(afterCategoryCount, category)
    local afterBackpack: int = GetBackpackItemCount()
    if quickTransferPreviousPlayerPage >= 0 && afterBackpack == beforeBackpack then
      playerPage = quickTransferPreviousPlayerPage
    end
    local insertedIntoPlayerCache: bool = false
    if afterBackpack > beforeBackpack then
      local insertedIndex: int = afterCategoryCount - 1
      local insertedOrder: int = GetAppendedCategoryBackpackOrdinal(category, beforeBackpack)
      insertedIntoPlayerCache = InsertPlayerIndexCacheAt(insertedOrder, beforeBackpack, category, insertedIndex)
      if insertedIntoPlayerCache then InsertOrderOrdinalAt(insertedOrder, beforeBackpack, targetSlot) end
      mergeIndex = insertedIndex
    end
    if organSource then native.PlaySound("take_organ") end
    if afterBackpack > beforeBackpack && insertedIntoPlayerCache && renderedPlayerPage != playerPage then
      -- Quick-transfer may choose the first free cell on another page. The
      -- page counter already follows playerPage, so keeping the old page's
      -- other slot forms here produces a mixed page until the user changes
      -- pages manually. Repaint the whole destination page in that case.
      UpdatePlayerSlots()
    else
    if afterBackpack > beforeBackpack && insertedIntoPlayerCache then
      -- InsertOrderOrdinalAt has already placed the new ordinal in the exact
      -- requested visual cell. Do not rescan every visible cell to rediscover
      -- information we already have.
      UpdatePlayerSlot(targetSlot)
      UpdatePlayerPageControls()
    else
      if afterBackpack > beforeBackpack then UpdatePlayerSlots() end
      -- Finding the visual cell of an existing stack requires reading the
      -- layout map. Spread that lookup across UI updates instead of blocking
      -- the transfer frame with a full visible-grid scan.
      QueueCachedPlayerEntryRefresh(category, mergeIndex)
    end
    end
    if organSource then UpdateOrganSlots() else RefreshVisibleContainerItem(itemID, sourceSlot) end
    UpdateMoney()
  end

  function MoveExternalToPlayer(organSource: bool, sourceSlot: int, targetSlot: int) -> void
    MoveExternalAmountToPlayer(organSource, sourceSlot, targetSlot, 1)
  end

  function DropPlayerToWorld(sourceSlot: int, requestedAmount: int) -> void
    if !ResolveVisibleSlot(sourceSlot) then return end
    local player: object = GetPlayerContainer()
    local category: int = resolvedCategory
    local index: int = resolvedIndex
    local beforeBackpack: int = GetBackpackItemCount()
    local usedOrder: int = GetBackpackOrdinal(category, index)
    local item: object
    player->GetItem(item, index, category)
    if !item then return end
    local availableAmount: int
    player->GetItemAmount(availableAmount, index, category)
    local amount: int =
      inv_overhaul_container_transfer.ContainerTransferNormalizeAmount(
        requestedAmount, availableAmount)
    if amount <= 0 then return end
    if category == c_iCWeapon then
      local selected: bool
      player->IsItemSelected(selected, index, category)
      if selected then native.SetPlayerHandsItem(-1) end
    end
    player->DropItems(item, amount)
    player->RemoveItem(index, amount, category)
    if GetBackpackItemCount() < beforeBackpack then RemoveOrderOrdinal(usedOrder, beforeBackpack) end
    UpdateAllSlots()
  end

  function HandleModifiedDrop(source: int) -> bool
    if !shiftHeld && !controlHeld then return false end
    if source < 0 || source >= visibleSlots then return false end
    if !ResolveVisibleSlot(source) then return true end

    if controlHeld && !shiftHeld then
      MovePlayerSlotToOtherPage(source)
      return true
    end

    local amount: int
    local player: object = GetPlayerContainer()
    player->GetItemAmount(amount, resolvedIndex, resolvedCategory)
    DropPlayerToWorld(source, amount)
    return true
  end

  function MovePlayerSlotToOtherPage(sourceSlot: int) -> void
    local maxPage: int = GetMaxPlayerPage()
    if maxPage <= 0 then return end

    local targetPage: int = playerPage + 1
    if targetPage > maxPage then targetPage = 0 end
    local backpackCount: int = GetBackpackItemCount()
    local targetCell: int = -1
    for targetSlot = 0, visibleSlots - 1 do
      local linear: int = targetPage * visibleSlots + targetSlot
      local cell: int = GetCellForLinearSlot(linear)
      if cell >= 0 && GetOrderValue(cell) >= backpackCount then
        targetCell = cell
        targetSlot = visibleSlots
      end
    end
    if targetCell < 0 then
      ShowInventoryFull()
      return
    end

    SwapSlotOrderCells(GetVisibleCell(sourceSlot), targetCell)
    native.Trace("inv_overhaul_container ctrl-page-move sourcePage=" + playerPage + " targetPage=" + targetPage)
  end

  function ResolveDragSource(source: int) -> bool
    local item: object
    local kind: int = -1
    local playerCategory: int = -1
    local playerIndex: int = -1
    local playerCell: int = -1
    local containerIndex: int = -1
    local containerOrdinal: int = -1
    local containerVisual: int = -1

    if source >= 0 && source < visibleSlots then
      if !ResolveVisibleSlot(source) then return false end
      kind = 0
      playerCategory = resolvedCategory
      playerIndex = resolvedIndex
      playerCell = GetVisibleCell(source)
      local player: object = GetPlayerContainer()
      player->GetItem(item, playerIndex, playerCategory)
    else
      if source >= c_iTargetContainerBase && source < c_iTargetContainerBase + c_iContainerSlots then
        if !ResolveContainerVisualSlot(source - c_iTargetContainerBase) then return false end
        kind = 1
        containerVisual = containerPage * c_iContainerSlots + source - c_iTargetContainerBase
      else
        if source >= c_iTargetOrganBase && source < c_iTargetOrganBase + c_iOrganSlots then
          if !ResolveOrganVisualSlot(source - c_iTargetOrganBase) then return false end
          kind = 2
        else
          return false
        end
      end
      containerIndex = resolvedContainerIndex
      containerOrdinal = resolvedContainerOrdinal
      local external: object = GetExternalContainer()
      external->GetItem(item, containerIndex)
    end

    if !item then return false end
    local itemID: int
    item->GetItemID(itemID)
    if kind == 0 then
      inv_overhaul_container_drag.ContainerDragBeginPlayerSource(
        source, itemID, playerCategory, playerIndex, playerCell)
    else
      inv_overhaul_container_drag.ContainerDragBeginExternalSource(
        source, kind, itemID, containerIndex, containerOrdinal, containerVisual)
    end
    return true
  end

  function BeginDragCursor(source: int) -> bool
    native.SetVariable("inv_overhaul_inventory_drag_item", -1)
    if !ResolveDragSource(source) then return false end
    native.SetVariable(
      "inv_overhaul_inventory_drag_item",
      inv_overhaul_container_drag.ContainerDragGetItemID())
    return true
  end

  function EndDragCursor() -> void
    native.SetVariable("inv_overhaul_inventory_drag_item", -1)
    native.SetVariable("inv_overhaul_inventory_page_hover", 0)
    inv_overhaul_container_drag.ContainerDragClearSource()
  end

  function GetPlayerSlotBySender(sender: string) -> int
    for slot = 0, visibleSlots - 1 do
      if sender == inv_overhaul_container_view.ContainerViewGetPlayerSlotWndName(slot) then
        return slot
      end
    end
    return -1
  end

  function GetContainerSlotBySender(sender: string) -> int
    for slot = 0, c_iContainerSlots - 1 do
      if sender == inv_overhaul_container_view.ContainerViewGetContainerSlotWndName(slot) then
        return slot
      end
    end
    return -1
  end

  function GetOrganSlotBySender(sender: string) -> int
    for slot = 0, c_iOrganSlots - 1 do
      if sender == inv_overhaul_container_view.ContainerViewGetOrganSlotWndName(slot) then
        return slot
      end
    end
    return -1
  end

  function GetTargetBySender(sender: string) -> int
    local slot: int = GetPlayerSlotBySender(sender)
    if slot >= 0 then return slot end
    slot = GetContainerSlotBySender(sender)
    if slot >= 0 then return c_iTargetContainerBase + slot end
    slot = GetOrganSlotBySender(sender)
    if slot >= 0 then return c_iTargetOrganBase + slot end
    if sender == "drop_slot" then return c_iTargetDrop end
    return -1
  end

  function FindOrganSlotAt(x: int, y: int) -> int
    if !showOrgans then return -1 end
    return inv_overhaul_container_geometry.ContainerGeometryFindOrganSlotAt(
      windowWidth, c_iOrganSlots, x, y)
  end

  function FindTargetAt(x: int, y: int) -> int
    local slot: int =
      inv_overhaul_container_geometry.ContainerGeometryFindPlayerSlotAt(
        windowWidth, visibleSlots, x, y)
    if slot >= 0 then return slot end
    slot = inv_overhaul_container_geometry.ContainerGeometryFindContainerSlotAt(
      windowWidth, c_iContainerSlots, x, y)
    if slot >= 0 then return c_iTargetContainerBase + slot end
    slot = FindOrganSlotAt(x, y)
    if slot >= 0 then return c_iTargetOrganBase + slot end
    return -1
  end

  function IsTargetCompatible(target: int) -> bool
    local kind: int = inv_overhaul_container_drag.ContainerDragGetKind()
    if kind == 0 then
      if target >= 0 && target < visibleSlots then return true end
      if target >= c_iTargetContainerBase && target < c_iTargetContainerBase + c_iContainerSlots then return true end
      return false
    end
    if kind == 1 then
      if target >= 0 && target < visibleSlots then return true end
      return target >= c_iTargetContainerBase && target < c_iTargetContainerBase + c_iContainerSlots
    end
    if kind == 2 then return target >= 0 && target < visibleSlots end
    return false
  end

  function SetHighlightedTarget(target: int) -> void
    if inv_overhaul_container_drag.ContainerDragIsActive() &&
      target >= 0 && !IsTargetCompatible(target) then target = -1 end
    local previousTarget: int =
      inv_overhaul_container_drag.ContainerDragGetHighlightedTarget()
    if previousTarget == target then return end
    if previousTarget >= 0 then
      inv_overhaul_container_view.ContainerViewSetTargetHighlighted(
        previousTarget, visibleSlots, false)
    end
    inv_overhaul_container_drag.ContainerDragSetHighlightedTarget(target)
    if target >= 0 then
      inv_overhaul_container_view.ContainerViewSetTargetHighlighted(
        target, visibleSlots, true)
    end
  end

  function ApplyPointerTarget(target: int) -> void
    if !inv_overhaul_container_drag.ContainerDragIsActive() then return end
    local source: int = inv_overhaul_container_drag.ContainerDragGetSource()
    local kind: int = inv_overhaul_container_drag.ContainerDragGetKind()
    local sameSource: bool = false
    if target == source then sameSource = true end
    if kind == 0 && target >= 0 && target < visibleSlots then
      if GetVisibleCell(target) ==
        inv_overhaul_container_drag.ContainerDragGetPlayerCell() then
        sameSource = true
      else
        sameSource = false
      end
    end
    if kind == 1 && target >= c_iTargetContainerBase &&
      target < c_iTargetContainerBase + c_iContainerSlots then
      if containerPage * c_iContainerSlots + target - c_iTargetContainerBase ==
        inv_overhaul_container_drag.ContainerDragGetContainerVisual() then
        sameSource = true
      else
        sameSource = false
      end
    end
    SetHighlightedTarget(
      inv_overhaul_container_drag.ContainerDragRecordPointerTarget(
        target, sameSource, IsTargetCompatible(target)))
  end

  function StartDragAction(source: int, sender: string) -> void
    if inv_overhaul_container_drag.ContainerDragIsActive() then return end
    CancelDragPageHover(0)
    ClearPanelTooltip()
    if !BeginDragCursor(source) then return end
    SetHighlightedTarget(-1)
  end

  function FinishDrag(target: int) -> void
    if !inv_overhaul_container_drag.ContainerDragIsActive() then return end
    target = inv_overhaul_container_drag.ContainerDragResolveReleaseTarget(target)
    local source: int = inv_overhaul_container_drag.ContainerDragGetSource()
    local sourceKind: int = inv_overhaul_container_drag.ContainerDragGetKind()
    local playerCell: int = inv_overhaul_container_drag.ContainerDragGetPlayerCell()
    local containerVisual: int =
      inv_overhaul_container_drag.ContainerDragGetContainerVisual()
    inv_overhaul_inventory_tooltip.InventoryTooltipSuspend(0.2)
    ClearPanelTooltip()
    if source >= 0 then
      native.SendMessage(
        -130,
        inv_overhaul_container_view.ContainerViewGetTargetWndName(source, visibleSlots))
    end
    if target >= 0 then
      native.SendMessage(
        -130,
        inv_overhaul_container_view.ContainerViewGetTargetWndName(target, visibleSlots))
    end

    if IsTargetCompatible(target) then
      if sourceKind == 0 then
        if target >= 0 && target < visibleSlots then
          if GetVisibleCell(target) != playerCell then
            SwapSlotOrderCells(playerCell, GetVisibleCell(target))
          end
        else
          if target >= c_iTargetContainerBase && target < c_iTargetContainerBase + c_iContainerSlots then
            ExchangePlayerWithContainer(source, target - c_iTargetContainerBase)
          end
        end
      else
        if target >= 0 && target < visibleSlots then
          if sourceKind == 1 then
            MoveExternalToPlayer(false, source - c_iTargetContainerBase, target)
          else
            MoveExternalToPlayer(true, source - c_iTargetOrganBase, target)
          end
        else
          if sourceKind == 1 && target >= c_iTargetContainerBase && target < c_iTargetContainerBase + c_iContainerSlots then
            SwapContainerSlotOrderVisuals(
              containerVisual,
              containerPage * c_iContainerSlots + target - c_iTargetContainerBase)
          end
        end
      end
    end

    SetHighlightedTarget(-1)
    EndDragCursor()
    CancelDragPageHover(0)
  end

  function QuickTransfer(source: int) -> void
    if source >= 0 && source < visibleSlots then
      if !ResolveVisibleSlot(source) then return end
      local visual: int =
        inv_overhaul_container_projection.ContainerProjectionFindFirstFreeContainerVisual(
          GetNormalContainerItemCount())
      if visual < 0 then
        ShowContainerFull()
        native.Trace("inv_overhaul_container quick player-to-container refused: no visual slot")
        return
      end
      quickTransferPreviousContainerPage = containerPage
      containerPage = visual / c_iContainerSlots
      if shiftHeld then
        MovePlayerAmountToContainer(source, visual - containerPage * c_iContainerSlots, -1)
      else
        MovePlayerToContainer(source, visual - containerPage * c_iContainerSlots)
      end
      quickTransferPreviousContainerPage = -1
      return
    end

    local playerVisual: int = FindFirstFreePlayerVisual(GetBackpackItemCount())
    if playerVisual < 0 then playerVisual = 0 end
    local playerLinear: int = playerVisual
    if visibleSlots < c_iInventoryCapacity then
      playerLinear = playerVisual - 16
      if playerLinear < 0 then playerLinear = playerLinear + c_iInventoryCapacity end
    end
    quickTransferPreviousPlayerPage = playerPage
    playerPage = playerLinear / visibleSlots
    local playerTarget: int = playerLinear - playerPage * visibleSlots
    if source >= c_iTargetContainerBase && source < c_iTargetContainerBase + c_iContainerSlots then
      if shiftHeld then
        MoveExternalAmountToPlayer(false, source - c_iTargetContainerBase, playerTarget, -1)
      else
        MoveExternalToPlayer(false, source - c_iTargetContainerBase, playerTarget)
      end
      quickTransferPreviousPlayerPage = -1
      return
    end
    if source >= c_iTargetOrganBase && source < c_iTargetOrganBase + c_iOrganSlots then
      if shiftHeld then
        MoveExternalAmountToPlayer(true, source - c_iTargetOrganBase, playerTarget, -1)
      else
        MoveExternalToPlayer(true, source - c_iTargetOrganBase, playerTarget)
      end
      quickTransferPreviousPlayerPage = -1
    end
  end

  function GetSlotTargetFromPointerMessage(message: int, base: int, sender: string) -> int
    local target: int = GetTargetBySender(sender)
    if target < 0 then return -1 end
    local encoded: int = message - base
    local localX: int = encoded / 100
    local localY: int = encoded - localX * 100
    local hotZone: int =
      inv_overhaul_container_geometry.ContainerGeometryGetSlotHotZone(windowWidth)
    if target >= c_iTargetOrganBase && target < c_iTargetOrganBase + c_iOrganSlots then
      hotZone =
        inv_overhaul_container_geometry.ContainerGeometryGetOrganSlotHotZone(windowWidth)
    end
    if inv_overhaul_container_geometry.ContainerGeometryIsInsideSlotDropArea(
      localX, localY, hotZone) then return target end
    return -1
  end

  function ClearPanelTooltip() -> void
    inv_overhaul_inventory_tooltip.InventoryTooltipClear()
  end

  function ShowPlayerPagingTooltip() -> void
    inv_overhaul_inventory_tooltip.InventoryTooltipShowText(c_iTargetPaging, 1404)
  end

  function ShowQuickslotHelpPanelTooltip() -> void
    inv_overhaul_inventory_tooltip.InventoryTooltipShowText(c_iTargetQuickslotHelp, 1407)
  end

  function IsInsidePlayerPaging(x: int, y: int) -> bool
    return inv_overhaul_container_geometry.ContainerGeometryIsInsidePageControl(
      GetMaxPlayerPage(), x, y,
      inv_overhaul_container_geometry.ContainerGeometryGetPlayerPageControlX(windowWidth),
      inv_overhaul_container_geometry.ContainerGeometryGetPlayerPageControlY(windowWidth))
  end

  function UpdatePanelTooltip(x: int, y: int) -> void
    if inv_overhaul_inventory_tooltip.InventoryTooltipIsSuspended() then
      ClearPanelTooltip()
      return
    end
    if inv_overhaul_container_drag.ContainerDragIsActive() then
      ClearPanelTooltip()
      return
    end
    if inv_overhaul_container_geometry.ContainerGeometryIsInsideQuickslotHelp(
      windowWidth, x, y) then
      ShowQuickslotHelpPanelTooltip()
      return
    end
    if IsInsidePlayerPaging(x, y) then
      ShowPlayerPagingTooltip()
      return
    end
    if inv_overhaul_container_geometry.ContainerGeometryIsInsideMoney(
      windowWidth, x, y) then
      inv_overhaul_inventory_tooltip.InventoryTooltipShowMoneyForTarget(c_iTargetMoney)
      return
    end

    local target: int = FindTargetAt(x, y)
    local item: object = null
    if target >= 0 && target < visibleSlots then
      if ResolveVisibleSlot(target) then
        local player: object = GetPlayerContainer()
        player->GetItem(item, resolvedIndex, resolvedCategory)
      end
    else
      if target >= c_iTargetContainerBase && target < c_iTargetContainerBase + c_iContainerSlots then
        if ResolveContainerVisualSlot(target - c_iTargetContainerBase) then
          local external: object = GetExternalContainer()
          external->GetItem(item, resolvedContainerIndex)
        end
      else
        if target >= c_iTargetOrganBase && target < c_iTargetOrganBase + c_iOrganSlots then
          if ResolveOrganVisualSlot(target - c_iTargetOrganBase) then
            local external: object = GetExternalContainer()
            external->GetItem(item, resolvedContainerIndex)
          end
        end
      end
    end

    if !item then
      ClearPanelTooltip()
      return
    end
    inv_overhaul_inventory_tooltip.InventoryTooltipShowItem(target, item)
  end

  function StartPanelPointerDrag(x: int, y: int) -> void
    local source: int = FindTargetAt(x, y)
    if source < 0 then return end
    if HandleModifiedDrop(source) then return end
    StartDragAction(source, "panel_background")
  end

  function HandlePanelPointer(message: int) -> void
    local base: int = c_iPanelPointerMoveBase
    local action: int = 0
    if message >= c_iPanelPointerLeaveBase then
      ClearPanelTooltip()
      inv_overhaul_container_view.ContainerViewClearPageControlHover()
      return
    end
    if message >= c_iPanelPointerDragEndBase then
      base = c_iPanelPointerDragEndBase
      action = 3
    else
      if message >= c_iPanelPointerDragBeginBase then
        base = c_iPanelPointerDragBeginBase
        action = 1
      else
        if message >= c_iPanelPointerRightBase then
          base = c_iPanelPointerRightBase
          action = 2
        else
          if message >= c_iPanelPointerUpBase then
            base = c_iPanelPointerUpBase
            action = 3
          else
            if message >= c_iPanelPointerDownBase then
              base = c_iPanelPointerDownBase
              action = 1
            end
          end
        end
      end
    end

    local x: int =
      inv_overhaul_container_geometry.ContainerGeometryDecodePanelPointerX(
        message, base)
    local y: int =
      inv_overhaul_container_geometry.ContainerGeometryDecodePanelPointerY(
        message, base)
    if action == 0 then
      UpdatePageControlHover(x, y)
      UpdatePanelTooltip(x, y)
    end
    if action == 1 then
      ClearPanelTooltip()
      if HandlePageControlAt(x, y) then return end
      StartPanelPointerDrag(x, y)
      return
    end
    if action == 2 then
      QuickTransfer(FindTargetAt(x, y))
      return
    end
    local target: int = FindTargetAt(x, y)
    if action == 3 then
      ApplyPointerTarget(target)
      FinishDrag(target)
      return
    end
    if inv_overhaul_container_drag.ContainerDragIsActive() then ApplyPointerTarget(target) end
  end

  function HandlePageControlAt(x: int, y: int) -> bool
    local playerMaxPage: int = GetMaxPlayerPage()
    if playerMaxPage > 0 then
      local playerAction: int =
        inv_overhaul_container_geometry.ContainerGeometryGetPageControlAction(
          x, y,
          inv_overhaul_container_geometry.ContainerGeometryGetPlayerPageControlX(windowWidth),
          inv_overhaul_container_geometry.ContainerGeometryGetPlayerPageControlY(windowWidth))
      if playerAction != 0 then
        if playerAction < 0 && playerPage > 0 then ChangePlayerPage(-1) end
        if playerAction > 0 && playerPage < playerMaxPage then ChangePlayerPage(1) end
        return true
      end
    end

    local containerMaxPage: int =
      inv_overhaul_container_projection.ContainerProjectionGetMaxPage()
    if containerMaxPage > 0 then
      local containerAction: int =
        inv_overhaul_container_geometry.ContainerGeometryGetPageControlAction(
          x, y,
          inv_overhaul_container_geometry.ContainerGeometryGetContainerPageControlX(windowWidth),
          inv_overhaul_container_geometry.ContainerGeometryGetContainerPageControlY(
            windowWidth, c_iContainerSlots))
      if containerAction != 0 then
        if containerAction < 0 && containerPage > 0 then ChangeContainerPage(-1) end
        if containerAction > 0 && containerPage < containerMaxPage then ChangeContainerPage(1) end
        return true
      end
    end
    return false
  end

  function UpdatePageControlHover(x: int, y: int) -> void
    local playerX: int =
      inv_overhaul_container_geometry.ContainerGeometryGetPlayerPageControlX(windowWidth)
    local playerY: int =
      inv_overhaul_container_geometry.ContainerGeometryGetPlayerPageControlY(windowWidth)
    local playerMaxPage: int = GetMaxPlayerPage()
    inv_overhaul_container_view.ContainerViewSetPageButtonHover(
      "player_page_prev",
      inv_overhaul_container_geometry.ContainerGeometryIsPageButtonHovered(
        -1, playerPage, playerMaxPage, x, y, playerX, playerY))
    inv_overhaul_container_view.ContainerViewSetPageButtonHover(
      "player_page_next",
      inv_overhaul_container_geometry.ContainerGeometryIsPageButtonHovered(
        1, playerPage, playerMaxPage, x, y, playerX, playerY))

    local containerX: int =
      inv_overhaul_container_geometry.ContainerGeometryGetContainerPageControlX(windowWidth)
    local containerY: int =
      inv_overhaul_container_geometry.ContainerGeometryGetContainerPageControlY(
        windowWidth, c_iContainerSlots)
    local containerMaxPage: int =
      inv_overhaul_container_projection.ContainerProjectionGetMaxPage()
    inv_overhaul_container_view.ContainerViewSetPageButtonHover(
      "container_page_prev",
      inv_overhaul_container_geometry.ContainerGeometryIsPageButtonHovered(
        -1, containerPage, containerMaxPage, x, y, containerX, containerY))
    inv_overhaul_container_view.ContainerViewSetPageButtonHover(
      "container_page_next",
      inv_overhaul_container_geometry.ContainerGeometryIsPageButtonHovered(
        1, containerPage, containerMaxPage, x, y, containerX, containerY))
  end

  function ChangePlayerPage(delta: int) -> void
    playerPage = playerPage + delta
    ClampPlayerPage()
    UpdatePlayerSlots()
  end

  function ChangeContainerPage(delta: int) -> void
    containerPage = containerPage + delta
    ClampContainerPage()
    UpdateContainerSlots()
  end

  function GetDragPageHoverAction(sender: string) -> int
    if sender == "player_page_prev" && playerPage > 0 then return -1 end
    if sender == "player_page_next" && playerPage < GetMaxPlayerPage() then return 1 end
    if sender == "container_page_prev" && containerPage > 0 then return -2 end
    if sender == "container_page_next" && containerPage <
      inv_overhaul_container_projection.ContainerProjectionGetMaxPage() then return 2 end
    return 0
  end

  function BeginDragPageHover(sender: string) -> void
    if !inv_overhaul_container_drag.ContainerDragIsActive() then return end
    local action: int = GetDragPageHoverAction(sender)
    if !inv_overhaul_container_drag.ContainerDragBeginPageHover(action) then return end
    native.Trace("inv_overhaul_container page-hover begin sender=" + sender + " action=" + action + " source=" + inv_overhaul_container_drag.ContainerDragGetSource())
  end

  function CancelDragPageHover(action: int) -> void
    if !inv_overhaul_container_drag.ContainerDragCanCancelPageHover(action) then return end
    local currentAction: int =
      inv_overhaul_container_drag.ContainerDragGetPageHoverAction()
    if currentAction != 0 then
      native.Trace("inv_overhaul_container page-hover cancel action=" + currentAction + " elapsed=" + inv_overhaul_container_drag.ContainerDragGetPageHoverElapsed())
    end
    inv_overhaul_container_drag.ContainerDragClearPageHover()
  end

  function UpdateDragPageHover(delta: float) -> void
    if !inv_overhaul_container_drag.ContainerDragIsActive() then return end
    local action: int =
      inv_overhaul_container_drag.ContainerDragGetPageHoverAction()
    if action == 0 then return end
    if action == -1 && playerPage <= 0 then
      CancelDragPageHover(action)
      return
    end
    if action == 1 && playerPage >= GetMaxPlayerPage() then
      CancelDragPageHover(action)
      return
    end
    if action == -2 && containerPage <= 0 then
      CancelDragPageHover(action)
      return
    end
    if action == 2 && containerPage >=
      inv_overhaul_container_projection.ContainerProjectionGetMaxPage() then
      CancelDragPageHover(action)
      return
    end
    action = inv_overhaul_container_drag.ContainerDragAdvancePageHover(delta)
    if action == 0 then return end
    SetHighlightedTarget(-1)
    native.Trace("inv_overhaul_container page-hover switch action=" + action + " player_page=" + playerPage + " container_page=" + containerPage)
    if action == -1 then ChangePlayerPage(-1) end
    if action == 1 then ChangePlayerPage(1) end
    if action == -2 then ChangeContainerPage(-1) end
    if action == 2 then ChangeContainerPage(1) end
  end

  function SyncDragPageHoverFromCursor() -> void
    if !inv_overhaul_container_drag.ContainerDragIsActive() then
      CancelDragPageHover(0)
      return
    end
    local hoverTarget: int = 0
    local action: int = 0
    native.GetVariable("inv_overhaul_inventory_page_hover", hoverTarget)
    if (hoverTarget == 1 || hoverTarget == 3) && playerPage > 0 then action = -1 end
    if (hoverTarget == 2 || hoverTarget == 4) && playerPage < GetMaxPlayerPage() then action = 1 end
    if hoverTarget == 5 && containerPage > 0 then action = -2 end
    if hoverTarget == 6 && containerPage <
      inv_overhaul_container_projection.ContainerProjectionGetMaxPage() then action = 2 end
    if action == 0 then
      CancelDragPageHover(0)
      return
    end
    if !inv_overhaul_container_drag.ContainerDragBeginPageHover(action) then return end
    native.Trace("inv_overhaul_container page-hover cursor target=" + hoverTarget + " action=" + action + " player_page=" + playerPage + " container_page=" + containerPage)
  end

  function OnUIMessage(message: int, sender: string, data: object) -> void
    if message == c_iQuickslotHelpHover && sender == "panel_background" then
      ShowQuickslotHelpPanelTooltip()
      return
    end
    if message == c_iGridRendererReady then
      native.SendMessage(-201, "panel_background")
      return
    end
    if message == c_iPageHoverEnter then
      BeginDragPageHover(sender)
      return
    end
    if message == c_iPageHoverLeave then
      CancelDragPageHover(GetDragPageHoverAction(sender))
      return
    end
    if message == -100 && sender == "corpse_marker" then
      ActivateCorpseMode()
      native.SendMessage(-120, "corpse_marker")
      return
    end
    if sender == "panel_background" && message >= c_iPanelPointerMoveBase then
      HandlePanelPointer(message)
      return
    end

    if sender == "player_page_prev" && message == 0 then
      if playerPage > 0 then ChangePlayerPage(-1) end
      return
    end
    if sender == "player_page_next" && message == 0 then
      if playerPage < GetMaxPlayerPage() then ChangePlayerPage(1) end
      return
    end
    if sender == "container_page_prev" && message == 0 then
      if containerPage > 0 then ChangeContainerPage(-1) end
      return
    end
    if sender == "container_page_next" && message == 0 then
      if containerPage <
        inv_overhaul_container_projection.ContainerProjectionGetMaxPage() then
        ChangeContainerPage(1)
      end
      return
    end

    if message >= c_iDragEndMessageBase then
      local target: int = GetSlotTargetFromPointerMessage(message, c_iDragEndMessageBase, sender)
      ApplyPointerTarget(target)
      FinishDrag(target)
      return
    end
    if message >= c_iReleaseMessageBase then
      local target: int = GetSlotTargetFromPointerMessage(message, c_iReleaseMessageBase, sender)
      ApplyPointerTarget(target)
      FinishDrag(target)
      return
    end
    if message >= c_iHoverMessageBase then
      local target: int = GetSlotTargetFromPointerMessage(message, c_iHoverMessageBase, sender)
      if inv_overhaul_container_drag.ContainerDragIsActive() then
        ApplyPointerTarget(target)
      else
        SetHighlightedTarget(target)
      end
      return
    end
    if message == 2 || message == 3 then
      local source: int = GetTargetBySender(sender)
      if HandleModifiedDrop(source) then return end
      StartDragAction(source, sender)
      return
    end
    if message == 7 then
      if inv_overhaul_container_drag.ContainerDragIsActive() then
        ApplyPointerTarget(-1)
      else
        SetHighlightedTarget(-1)
      end
      return
    end
    if message == 8 then
      FinishDrag(inv_overhaul_container_drag.ContainerDragGetHighlightedTarget())
      return
    end
    if message == 1 && !data then
      QuickTransfer(GetTargetBySender(sender))
    end
  end

  function OnUpdate(delta: float) -> void
    if windowClosing then return end
    inv_overhaul_inventory_tooltip.InventoryTooltipAdvanceSuspension(delta)
    if inventoryFullMessageCooldown > 0 then
      inventoryFullMessageCooldown = inventoryFullMessageCooldown - delta
      if inventoryFullMessageCooldown < 0 then inventoryFullMessageCooldown = 0 end
    end
    UpdateLayout()
    if initialSlotLoadPending then
      initialSlotLoadDelay = initialSlotLoadDelay - delta
      if initialSlotLoadDelay <= 0 then
        if initialMetadataStage == 0 then
          if ContinueIncrementalLayoutLoad() then
            initialMetadataStage = 1
            initialSlotLoadDelay = 0.01
          else
            initialSlotLoadDelay = 0
          end
        else
          if initialMetadataStage == 1 then
            InitializePersistentPlayerSnapshot()
            initialMetadataStage = 2
            initialSlotLoadDelay = 0.01
          else
            OrderFreeCellsByDisplay()
            initialSlotLoadPending = false
            BeginInitialSlotLoad()
          end
        end
      end
    end
    ContinueInitialSlotLoad()
    ContinueCachedPlayerEntryRefresh()
    ContinueLayoutSave()
    moneyPollCooldown = moneyPollCooldown - delta
    if moneyPollCooldown <= 0 then
      moneyPollCooldown = 0.25
      UpdateMoney()
    end
    if organVisibilityRefresh > 0 then
      organVisibilityRefresh = organVisibilityRefresh - delta
      if organVisibilityRefresh <= 0 then UpdateOrganSlots() end
    end
    if corpseVisualPending then
      native.SendMessage(-100, "loot_doll")
      corpseVisualPending = false
    end
    if deferredInventoryRefresh > 0 then
      deferredInventoryRefresh = deferredInventoryRefresh - delta
      if deferredInventoryRefresh <= 0 then
        UpdatePlayerSlots()
        native.Trace("inv_overhaul_container deferred inventory refresh")
      end
    end
    if deferredContainerRefresh > 0 then
      deferredContainerRefresh = deferredContainerRefresh - delta
      if deferredContainerRefresh <= 0 then UpdateContainerSlots() end
    end
    SyncDragPageHoverFromCursor()
    UpdateDragPageHover(delta)
  end

  function OnMouseMove(x: int, y: int) -> void
    if inv_overhaul_container_drag.ContainerDragIsActive() then
      ApplyPointerTarget(FindTargetAt(x, y))
    end
  end

  function OnMouseLeave() -> void
    if inv_overhaul_container_drag.ContainerDragIsActive() then SetHighlightedTarget(-1) end
  end

  function OnLButtonUp(x: int, y: int) -> void
    if inv_overhaul_container_drag.ContainerDragIsActive() then
      local target: int = FindTargetAt(x, y)
      ApplyPointerTarget(target)
      FinishDrag(target)
    end
  end

  function CloseContainerWindow() -> void
    native.SetCursor("default")
    native.DestroyWindow()
  end

  function OnChar(char: int) -> void
    if char >= 48 && char <= 57 then return end
    if inv_overhaul_inventory_layout_runtime.InventoryLayoutRuntimeHasQueuedSave() then SaveLayoutVariables() end
    PersistCurrentPlayerSnapshot()
    CloseContainerWindow()
  end

  function OnKeyDown(key: int) -> void
    if key == c_iVKShift then shiftHeld = true end
    if key == c_iVKControl then controlHeld = true end
    local quickslot: int = GetQuickslotByKey(key)
    if quickslot > 0 then
      AssignHoveredQuickslot(quickslot)
      return
    end
    if key == 27 || key == 73 || key == 105 then
      if inv_overhaul_inventory_layout_runtime.InventoryLayoutRuntimeHasQueuedSave() then SaveLayoutVariables() end
      PersistCurrentPlayerSnapshot()
      CloseContainerWindow()
    end
  end

  function OnKeyUp(key: int) -> void
    if key == c_iVKShift then shiftHeld = false end
    if key == c_iVKControl then controlHeld = false end
  end
end
