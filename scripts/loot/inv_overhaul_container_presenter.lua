import "inv_overhaul_inventory_layout"
import "inv_overhaul_inventory_layout_runtime"
import "inv_overhaul_container_geometry"
import "inv_overhaul_container_projection"
import "inv_overhaul_container_view"
import "inv_overhaul_inventory_items"
import "inv_overhaul_inventory_quickslot_bindings"

module inv_overhaul_container_presenter do
  local const InventoryCapacity: int = 56
  local const ContainerSlots: int = 12
  local const OrganSlots: int = 4
  local const InitialSlotLoadBatch: int = 1

  local windowWidth: int
  local windowHeight: int
  local visibleSlots: int
  local playerPage: int
  local containerPage: int
  local renderedPlayerPage: int
  local renderedContainerPage: int
  local lastLayoutWidth: int
  local lastLayoutHeight: int
  local lastContainerMaxPage: int
  local initialSlotLoadActive: bool
  local initialPlayerSlotLoadNext: int
  local initialContainerSlotLoadNext: int
  local moneyPollCooldown: float
  local pendingPlayerEntryCategory: int
  local pendingPlayerEntryIndex: int
  local pendingPlayerEntryScanSlot: int
  local isCorpse: bool
  local showOrgans: bool

  function ContainerPresenterInitializeState() -> void
    windowWidth = 0
    windowHeight = 0
    visibleSlots = 0
    playerPage = 0
    containerPage = 0
    renderedPlayerPage = -1
    renderedContainerPage = -1
    lastLayoutWidth = -1
    lastLayoutHeight = -1
    lastContainerMaxPage = -1
    initialSlotLoadActive = false
    initialPlayerSlotLoadNext = 0
    initialContainerSlotLoadNext = 0
    moneyPollCooldown = 0.25
    pendingPlayerEntryCategory = -1
    pendingPlayerEntryIndex = -1
    pendingPlayerEntryScanSlot = 0
    isCorpse = false
    showOrgans = false
  end

  function ContainerPresenterGetWindowWidth() -> int
    local value: int = windowWidth
    return value
  end

  function ContainerPresenterGetWindowHeight() -> int
    local value: int = windowHeight
    return value
  end

  function ContainerPresenterGetVisibleSlots() -> int
    local value: int = visibleSlots
    return value
  end

  function ContainerPresenterGetPlayerPage() -> int
    local value: int = playerPage
    return value
  end

  function ContainerPresenterGetContainerPage() -> int
    local value: int = containerPage
    return value
  end

  function ContainerPresenterGetRenderedPlayerPage() -> int
    local value: int = renderedPlayerPage
    return value
  end

  function ContainerPresenterGetRenderedContainerPage() -> int
    local value: int = renderedContainerPage
    return value
  end

  function ContainerPresenterIsCorpse() -> bool
    local value: bool = isCorpse
    return value
  end

  function ContainerPresenterShowsOrgans() -> bool
    local value: bool = showOrgans
    return value
  end

  function ContainerPresenterSetPlayerPage(page: int) -> void
    playerPage = page
    ContainerPresenterClampPlayerPage()
  end

  function ContainerPresenterSetContainerPage(page: int) -> void
    containerPage = page
    ContainerPresenterClampContainerPage()
  end

  function ContainerPresenterSetCorpseMode(
    newIsCorpse: bool,
    newShowOrgans: bool) -> void
    isCorpse = newIsCorpse
    showOrgans = newShowOrgans
  end

  function ContainerPresenterUpdateLayout() -> void
    local newWidth: int
    local newHeight: int
    native.GetWindowSize(newWidth, newHeight)
    if newWidth <= 0 || newHeight <= 0 then
      native.GetScreenSize(newWidth, newHeight)
    end
    local newVisibleSlots: int =
      inv_overhaul_container_geometry.ContainerGeometryGetVisibleSlots(newWidth)
    if newWidth != lastLayoutWidth || newHeight != lastLayoutHeight then
      native.SendMessage(newWidth, "panel_background")
      native.SendMessage(5000 + newHeight, "panel_background")
      inv_overhaul_container_view.ContainerViewConfigureSlotRenderSize(
        newWidth, newVisibleSlots)
      lastLayoutWidth = newWidth
      lastLayoutHeight = newHeight
    end
    windowWidth = newWidth
    windowHeight = newHeight
    visibleSlots = newVisibleSlots
  end

  function ContainerPresenterGetCellForLinearSlot(linear: int) -> int
    local slots: int = visibleSlots
    return inv_overhaul_inventory_layout.InventoryLayoutGetCellForLinearSlot(
      linear, slots, InventoryCapacity)
  end

  function ContainerPresenterGetVisibleCell(slot: int) -> int
    local page: int = playerPage
    local slots: int = visibleSlots
    local linear: int = page * slots + slot
    return ContainerPresenterGetCellForLinearSlot(linear)
  end

  function ContainerPresenterGetMaxPlayerPage() -> int
    local slots: int = visibleSlots
    return inv_overhaul_inventory_layout.InventoryLayoutGetMaxPage(
      InventoryCapacity, slots)
  end

  function ContainerPresenterClampPlayerPage() -> void
    local maxPage: int = ContainerPresenterGetMaxPlayerPage()
    if playerPage < 0 then playerPage = 0 end
    if playerPage > maxPage then playerPage = maxPage end
  end

  function ContainerPresenterResolveVisibleSlot(slot: int) -> int
    local target: int =
      inv_overhaul_inventory_layout_runtime.InventoryLayoutRuntimeGetOrderValue(
        ContainerPresenterGetVisibleCell(slot))
    return inv_overhaul_inventory_items.InventoryItemsResolveCachedOrdinal(target)
  end

  function ContainerPresenterQueueCachedPlayerEntryRefresh(
    category: int,
    index: int) -> void
    pendingPlayerEntryCategory = category
    pendingPlayerEntryIndex = index
    pendingPlayerEntryScanSlot = 0
  end

  function ContainerPresenterContinueCachedPlayerEntryRefresh() -> void
    if pendingPlayerEntryCategory < 0 || pendingPlayerEntryIndex < 0 then return end
    if pendingPlayerEntryScanSlot >= visibleSlots then
      pendingPlayerEntryCategory = -1
      pendingPlayerEntryIndex = -1
      pendingPlayerEntryScanSlot = 0
      ContainerPresenterUpdatePlayerPageControls()
      return
    end
    local slot: int = pendingPlayerEntryScanSlot
    pendingPlayerEntryScanSlot = pendingPlayerEntryScanSlot + 1
    local ordinal: int =
      inv_overhaul_inventory_layout_runtime.InventoryLayoutRuntimeGetOrderValue(
        ContainerPresenterGetVisibleCell(slot))
    local cachedCount: int =
      inv_overhaul_inventory_items.InventoryItemsGetCachedBackpackCount()
    if ordinal >= 0 && ordinal < cachedCount && ordinal < InventoryCapacity then
      local cachedCategory: int =
        inv_overhaul_inventory_items.InventoryItemsGetCachedCategory(ordinal)
      local cachedIndex: int =
        inv_overhaul_inventory_items.InventoryItemsGetCachedIndex(ordinal)
      if cachedCategory == pendingPlayerEntryCategory &&
        cachedIndex == pendingPlayerEntryIndex then
        ContainerPresenterUpdatePlayerSlot(slot)
        pendingPlayerEntryCategory = -1
        pendingPlayerEntryIndex = -1
        pendingPlayerEntryScanSlot = 0
        ContainerPresenterUpdatePlayerPageControls()
      end
    end
  end

  function ContainerPresenterGetVisibleSlotForCell(cell: int) -> int
    if cell < 0 then return -1 end
    for slot = 0, visibleSlots - 1 do
      if ContainerPresenterGetVisibleCell(slot) == cell then return slot end
    end
    return -1
  end

  function ContainerPresenterGetNormalContainerItemCount() -> int
    local container: object
    native.GetContainer(container)
    return inv_overhaul_container_projection.ContainerProjectionGetNormalItemCount(
      container)
  end

  function ContainerPresenterBuildContainerIndexCache() -> void
    local container: object
    native.GetContainer(container)
    inv_overhaul_container_projection.ContainerProjectionBuildIndexCache(container)
  end

  function ContainerPresenterResolveContainerVisualSlot(slot: int) -> int
    local page: int = containerPage
    local visual: int = page * ContainerSlots + slot
    local ordinal: int =
      inv_overhaul_container_projection.ContainerProjectionGetContainerOrder(visual)
    return inv_overhaul_container_projection.ContainerProjectionResolveNormalOrdinal(
      ordinal)
  end

  function ContainerPresenterResolveOrganVisualSlot(slot: int) -> int
    if !showOrgans then return -1 end
    local container: object
    native.GetContainer(container)
    return inv_overhaul_container_projection.ContainerProjectionResolveOrganVisual(
      container, slot)
  end

  function ContainerPresenterClampContainerPage() -> void
    local maxPage: int =
      inv_overhaul_container_projection.ContainerProjectionGetMaxPage()
    if containerPage < 0 then containerPage = 0 end
    if containerPage > maxPage then containerPage = maxPage end
  end

  function ContainerPresenterUpdatePlayerPageControls() -> void
    local maxPage: int = ContainerPresenterGetMaxPlayerPage()
    local page: int = playerPage
    inv_overhaul_container_view.ContainerViewResetPageControls(
      "player_", -114, -115)
    inv_overhaul_container_view.ContainerViewUpdatePageControls(
      "player_", page, maxPage)
  end

  function ContainerPresenterUpdateContainerPageControls() -> void
    local maxPage: int =
      inv_overhaul_container_projection.ContainerProjectionGetMaxPage()
    local page: int = containerPage
    local corpse: bool = isCorpse
    inv_overhaul_container_view.ContainerViewResetPageControls(
      "container_", -116, -117)
    if maxPage != lastContainerMaxPage then
      native.Trace("inv_overhaul_container pages count=" +
        inv_overhaul_container_projection.ContainerProjectionGetCachedNormalCount() +
        " max=" + maxPage + " current=" + page + " corpse=" + corpse)
      lastContainerMaxPage = maxPage
    end
    inv_overhaul_container_view.ContainerViewUpdatePageControls(
      "container_", page, maxPage)
  end

  function ContainerPresenterUpdateMoney() -> void
    local player: object =
      inv_overhaul_inventory_items.InventoryItemsGetPlayerContainer()
    local money: int
    player->GetProperty("money", money)
    native.SendMessage(money, "money")
  end

  function ContainerPresenterUpdatePlayerSlot(slot: int) -> void
    local player: object =
      inv_overhaul_inventory_items.InventoryItemsGetPlayerContainer()
    local wnd: string =
      inv_overhaul_container_view.ContainerViewGetPlayerSlotWndName(slot)
    if ContainerPresenterGetVisibleCell(slot) < 0 then
      inv_overhaul_container_view.ContainerViewRenderPlayerSlotUnavailable(wnd)
      return
    end
    inv_overhaul_container_view.ContainerViewBeginPlayerSlot(wnd)
    local reference: int = ContainerPresenterResolveVisibleSlot(slot)
    if reference < 0 then
      inv_overhaul_container_view.ContainerViewRenderPlayerSlotEmpty(wnd)
      return
    end
    local category: int =
      inv_overhaul_inventory_items.InventoryItemsDecodeReferenceCategory(reference)
    local index: int =
      inv_overhaul_inventory_items.InventoryItemsDecodeReferenceIndex(reference)
    local item: object
    local amount: int
    player->GetItem(item, index, category)
    player->GetItemAmount(amount, index, category)
    inv_overhaul_container_view.ContainerViewRenderPlayerSlotItem(wnd, item, amount)
    local itemID: int
    item->GetItemID(itemID)
    local quickslot: int =
      inv_overhaul_inventory_quickslot_bindings.InventoryQuickslotGetDisplayedBinding(
        category, index, itemID)
    inv_overhaul_container_view.ContainerViewRenderPlayerQuickslot(wnd, quickslot)
  end

  function ContainerPresenterUpdatePlayerSlots() -> void
    ContainerPresenterClampPlayerPage()
    inv_overhaul_inventory_items.InventoryItemsBuildIndexCache()
    for slot = 0, visibleSlots - 1 do
      ContainerPresenterUpdatePlayerSlot(slot)
    end
    renderedPlayerPage = playerPage
    ContainerPresenterUpdatePlayerPageControls()
  end

  function ContainerPresenterUpdateContainerSlot(slot: int) -> void
    local container: object
    native.GetContainer(container)
    local wnd: string =
      inv_overhaul_container_view.ContainerViewGetContainerSlotWndName(slot)
    local reference: int = ContainerPresenterResolveContainerVisualSlot(slot)
    if reference < 0 then
      inv_overhaul_container_view.ContainerViewRenderContainerSlotEmpty(wnd)
      return
    end
    local index: int =
      inv_overhaul_container_projection.ContainerProjectionGetReferenceIndex(reference)
    local item: object
    local amount: int
    container->GetItem(item, index)
    container->GetItemAmount(amount, index)
    inv_overhaul_container_view.ContainerViewRenderContainerSlotItem(
      wnd, item, amount)
  end

  function ContainerPresenterUpdateContainerSlots() -> void
    ContainerPresenterBuildContainerIndexCache()
    ContainerPresenterClampContainerPage()
    for slot = 0, ContainerSlots - 1 do
      ContainerPresenterUpdateContainerSlot(slot)
    end
    renderedContainerPage = containerPage
    ContainerPresenterUpdateContainerPageControls()
  end

  function ContainerPresenterUpdateOrganSlots() -> void
    local container: object
    native.GetContainer(container)
    for slot = 0, OrganSlots - 1 do
      local wnd: string =
        inv_overhaul_container_view.ContainerViewGetOrganSlotWndName(slot)
      if !isCorpse || !showOrgans then
        inv_overhaul_container_view.ContainerViewRenderOrganSlotHidden(wnd)
      else
        inv_overhaul_container_view.ContainerViewBeginOrganSlot(wnd)
        local reference: int = ContainerPresenterResolveOrganVisualSlot(slot)
        if reference < 0 then
          inv_overhaul_container_view.ContainerViewRenderOrganSlotEmpty(wnd)
        else
          local index: int =
            inv_overhaul_container_projection.ContainerProjectionGetReferenceIndex(
              reference)
          inv_overhaul_container_view.ContainerViewBeginOrganSlotItem(wnd)
          local item: object
          local amount: int
          container->GetItem(item, index)
          container->GetItemAmount(amount, index)
          inv_overhaul_container_view.ContainerViewRenderOrganSlotItem(
            wnd, item, amount)
        end
      end
    end
  end

  function ContainerPresenterUpdateAllSlots() -> void
    initialSlotLoadActive = false
    ContainerPresenterUpdateLayout()
    ContainerPresenterUpdatePlayerSlots()
    ContainerPresenterUpdateContainerSlots()
    ContainerPresenterUpdateOrganSlots()
    ContainerPresenterUpdateMoney()
  end

  function ContainerPresenterRefreshVisibleContainerItem(
    itemID: int,
    fallbackSlot: int) -> void
    initialSlotLoadActive = false
    if renderedContainerPage != containerPage then
      ContainerPresenterUpdateContainerSlots()
      return
    end
    ContainerPresenterBuildContainerIndexCache()
    local fallbackUpdated: bool = false
    for slot = 0, ContainerSlots - 1 do
      local update: bool = false
      if slot == fallbackSlot then update = true end
      local reference: int = ContainerPresenterResolveContainerVisualSlot(slot)
      if reference >= 0 then
        local index: int =
          inv_overhaul_container_projection.ContainerProjectionGetReferenceIndex(
            reference)
        local external: object
        native.GetContainer(external)
        local item: object
        local visibleItemID: int = -1
        external->GetItem(item, index)
        if item then item->GetItemID(visibleItemID) end
        if visibleItemID == itemID then update = true end
      end
      if update then
        ContainerPresenterUpdateContainerSlot(slot)
        if slot == fallbackSlot then fallbackUpdated = true end
      end
    end
    if !fallbackUpdated && fallbackSlot >= 0 && fallbackSlot < ContainerSlots then
      ContainerPresenterUpdateContainerSlot(fallbackSlot)
    end
    ContainerPresenterUpdateContainerPageControls()
  end

  function ContainerPresenterBeginInitialSlotLoad() -> void
    ContainerPresenterUpdateLayout()
    ContainerPresenterClampPlayerPage()
    inv_overhaul_inventory_items.InventoryItemsBuildIndexCache()
    ContainerPresenterBuildContainerIndexCache()
    ContainerPresenterClampContainerPage()
    ContainerPresenterUpdatePlayerPageControls()
    ContainerPresenterUpdateContainerPageControls()
    ContainerPresenterUpdateOrganSlots()
    ContainerPresenterUpdateMoney()
    initialPlayerSlotLoadNext = 0
    initialContainerSlotLoadNext = 0
    initialSlotLoadActive = true
    native.Trace("inv_overhaul_container deferred initial slots player=" +
      visibleSlots + " container=" + ContainerSlots)
  end

  function ContainerPresenterContinueInitialSlotLoad() -> void
    if !initialSlotLoadActive then return end
    for batch = 0, InitialSlotLoadBatch - 1 do
      if initialContainerSlotLoadNext < ContainerSlots then
        local containerSlot: int = initialContainerSlotLoadNext
        ContainerPresenterUpdateContainerSlot(containerSlot)
        initialContainerSlotLoadNext = initialContainerSlotLoadNext + 1
      else
        if initialPlayerSlotLoadNext < visibleSlots then
          local playerSlot: int = initialPlayerSlotLoadNext
          ContainerPresenterUpdatePlayerSlot(playerSlot)
          initialPlayerSlotLoadNext = initialPlayerSlotLoadNext + 1
        end
      end
    end
    if initialContainerSlotLoadNext >= ContainerSlots &&
      initialPlayerSlotLoadNext >= visibleSlots then
      initialSlotLoadActive = false
      native.Trace("inv_overhaul_container sequential initial slots complete batch=" +
        InitialSlotLoadBatch)
    end
  end

  function ContainerPresenterAdvanceMoneyPolling(delta: float) -> void
    moneyPollCooldown = moneyPollCooldown - delta
    if moneyPollCooldown <= 0 then
      moneyPollCooldown = 0.25
      ContainerPresenterUpdateMoney()
    end
  end

  function ContainerPresenterChangePlayerPage(delta: int) -> void
    playerPage = playerPage + delta
    ContainerPresenterClampPlayerPage()
    ContainerPresenterUpdatePlayerSlots()
  end

  function ContainerPresenterChangeContainerPage(delta: int) -> void
    containerPage = containerPage + delta
    ContainerPresenterClampContainerPage()
    ContainerPresenterUpdateContainerSlots()
  end
end
