import "inv_overhaul_inventory_layout"
import "inv_overhaul_inventory_layout_runtime"
import "inv_overhaul_container_geometry"
import "inv_overhaul_container_projection"
import "inv_overhaul_container_view"
import "inv_overhaul_inventory_items"
import "inv_overhaul_inventory_sounds"
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

  function LootPresenterInitializeState() -> void
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

  function GetWindowWidth() -> int
    local value: int = windowWidth
    return value
  end

  function GetWindowHeight() -> int
    local value: int = windowHeight
    return value
  end

  function LootPresenterGetVisibleSlots() -> int
    local value: int = visibleSlots
    return value
  end

  function GetPlayerPage() -> int
    local value: int = playerPage
    return value
  end

  function GetContainerPage() -> int
    local value: int = containerPage
    return value
  end

  function GetRenderedPlayerPage() -> int
    local value: int = renderedPlayerPage
    return value
  end

  function GetRenderedContainerPage() -> int
    local value: int = renderedContainerPage
    return value
  end

  function LootPresenterIsCorpse() -> bool
    local value: bool = isCorpse
    return value
  end

  function LootPresenterShowsOrgans() -> bool
    local value: bool = showOrgans
    return value
  end

  function SetPlayerPage(page: int) -> void
    playerPage = page
    ClampPlayerPage()
  end

  function SetContainerPage(page: int) -> void
    containerPage = page
    ClampContainerPage()
  end

  function SetCorpseMode(
    newIsCorpse: bool,
    newShowOrgans: bool) -> void
    isCorpse = newIsCorpse
    showOrgans = newShowOrgans
  end

  function LootPresenterUpdateLayout() -> void
    local newWidth: int
    local newHeight: int
    native.GetWindowSize(newWidth, newHeight)
    if newWidth <= 0 || newHeight <= 0 then
      native.GetScreenSize(newWidth, newHeight)
    end
    local newVisibleSlots: int =
      inv_overhaul_container_geometry.LootGeometryGetVisibleSlots(newWidth)
    if newWidth != lastLayoutWidth || newHeight != lastLayoutHeight then
      native.SendMessage(newWidth, "panel_background")
      native.SendMessage(5000 + newHeight, "panel_background")
      inv_overhaul_container_view.LootViewConfigureSlotRenderSize(
        newWidth, newVisibleSlots)
      lastLayoutWidth = newWidth
      lastLayoutHeight = newHeight
    end
    windowWidth = newWidth
    windowHeight = newHeight
    visibleSlots = newVisibleSlots
  end

  function LootPresenterGetCellForLinearSlot(linear: int) -> int
    local slots: int = visibleSlots
    return inv_overhaul_inventory_layout.LayoutGetCellForLinearSlot(
      linear, slots, InventoryCapacity)
  end

  function LootPresenterGetVisibleCell(slot: int) -> int
    local page: int = playerPage
    local slots: int = visibleSlots
    local linear: int = page * slots + slot
    return LootPresenterGetCellForLinearSlot(linear)
  end

  function GetMaxPlayerPage() -> int
    local slots: int = visibleSlots
    return inv_overhaul_inventory_layout.LayoutGetMaxPage(
      InventoryCapacity, slots)
  end

  function ClampPlayerPage() -> void
    local maxPage: int = GetMaxPlayerPage()
    if playerPage < 0 then playerPage = 0 end
    if playerPage > maxPage then playerPage = maxPage end
  end

  function LootPresenterResolveVisibleSlot(slot: int) -> int
    local target: int =
      inv_overhaul_inventory_layout_runtime.LayoutRuntimeGetOrderValue(
        LootPresenterGetVisibleCell(slot))
    return inv_overhaul_inventory_items.ResolveCachedOrdinal(target)
  end

  function QueueCachedPlayerEntryRefresh(
    category: int,
    index: int) -> void
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
    local ordinal: int =
      inv_overhaul_inventory_layout_runtime.LayoutRuntimeGetOrderValue(
        LootPresenterGetVisibleCell(slot))
    local cachedCount: int =
      inv_overhaul_inventory_items.GetCachedBackpackCount()
    if ordinal >= 0 && ordinal < cachedCount && ordinal < InventoryCapacity then
      local cachedCategory: int =
        inv_overhaul_inventory_items.ItemsGetCachedCategory(ordinal)
      local cachedIndex: int =
        inv_overhaul_inventory_items.ItemsGetCachedIndex(ordinal)
      if cachedCategory == pendingPlayerEntryCategory &&
        cachedIndex == pendingPlayerEntryIndex then
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
      if LootPresenterGetVisibleCell(slot) == cell then return slot end
    end
    return -1
  end

  function GetNormalContainerItemCount() -> int
    local container: object
    native.GetContainer(container)
    return inv_overhaul_container_projection.GetNormalItemCount(
      container)
  end

  function BuildContainerIndexCache() -> void
    local container: object
    native.GetContainer(container)
    inv_overhaul_container_projection.LootProjectionBuildIndexCache(container)
  end

  function ResolveContainerVisualSlot(slot: int) -> int
    local page: int = containerPage
    local visual: int = page * ContainerSlots + slot
    local ordinal: int =
      inv_overhaul_container_projection.GetContainerOrder(visual)
    return inv_overhaul_container_projection.ResolveNormalOrdinal(
      ordinal)
  end

  function ResolveOrganVisualSlot(slot: int) -> int
    if !showOrgans then return -1 end
    local container: object
    native.GetContainer(container)
    return inv_overhaul_container_projection.ResolveOrganVisual(
      container, slot)
  end

  function ClampContainerPage() -> void
    local maxPage: int =
      inv_overhaul_container_projection.LootProjectionGetMaxPage()
    if containerPage < 0 then containerPage = 0 end
    if containerPage > maxPage then containerPage = maxPage end
  end

  function UpdatePlayerPageControls() -> void
    local maxPage: int = GetMaxPlayerPage()
    local page: int = playerPage
    inv_overhaul_container_view.ResetPageControls(
      "player_", -114, -115)
    inv_overhaul_container_view.LootViewUpdatePageControls(
      "player_", page, maxPage)
  end

  function UpdateContainerPageControls() -> void
    local maxPage: int =
      inv_overhaul_container_projection.LootProjectionGetMaxPage()
    local page: int = containerPage
    local corpse: bool = isCorpse
    inv_overhaul_container_view.ResetPageControls(
      "container_", -116, -117)
    if maxPage != lastContainerMaxPage then
      native.Trace("inv_overhaul_container pages count=" +
        inv_overhaul_container_projection.GetCachedNormalCount() +
        " max=" + maxPage + " current=" + page + " corpse=" + corpse)
      lastContainerMaxPage = maxPage
    end
    inv_overhaul_container_view.LootViewUpdatePageControls(
      "container_", page, maxPage)
  end

  function LootPresenterUpdateMoney() -> void
    local player: object =
      inv_overhaul_inventory_items.ItemsGetPlayerContainer()
    local money: int
    player->GetProperty("money", money)
    native.SendMessage(money, "money")
  end

  function UpdatePlayerSlot(slot: int) -> void
    local player: object =
      inv_overhaul_inventory_items.ItemsGetPlayerContainer()
    local wnd: string =
      inv_overhaul_container_view.GetPlayerSlotWndName(slot)
    if LootPresenterGetVisibleCell(slot) < 0 then
      inv_overhaul_container_view.RenderPlayerSlotUnavailable(wnd)
      return
    end
    inv_overhaul_container_view.BeginPlayerSlot(wnd)
    local reference: int = LootPresenterResolveVisibleSlot(slot)
    if reference < 0 then
      inv_overhaul_container_view.RenderPlayerSlotEmpty(wnd)
      return
    end
    local category: int =
      inv_overhaul_inventory_items.DecodeReferenceCategory(reference)
    local index: int =
      inv_overhaul_inventory_items.DecodeReferenceIndex(reference)
    local item: object
    local amount: int
    player->GetItem(item, index, category)
    player->GetItemAmount(amount, index, category)
    inv_overhaul_container_view.RenderPlayerSlotItem(wnd, item, amount)
    local itemID: int
    item->GetItemID(itemID)
    local quickslot: int =
      inv_overhaul_inventory_quickslot_bindings.GetDisplayedBinding(
        category, index, itemID)
    inv_overhaul_container_view.RenderPlayerQuickslot(wnd, quickslot)
  end

  function UpdatePlayerSlots() -> void
    ClampPlayerPage()
    inv_overhaul_inventory_items.ItemsBuildIndexCache()
    for slot = 0, visibleSlots - 1 do
      UpdatePlayerSlot(slot)
    end
    renderedPlayerPage = playerPage
    UpdatePlayerPageControls()
  end

  function UpdateContainerSlot(slot: int) -> void
    local container: object
    native.GetContainer(container)
    local wnd: string =
      inv_overhaul_container_view.GetContainerSlotWndName(slot)
    local reference: int = ResolveContainerVisualSlot(slot)
    if reference < 0 then
      inv_overhaul_container_view.RenderContainerSlotEmpty(wnd)
      return
    end
    local index: int =
      inv_overhaul_container_projection.GetReferenceIndex(reference)
    local item: object
    local amount: int
    container->GetItem(item, index)
    container->GetItemAmount(amount, index)
    inv_overhaul_container_view.RenderContainerSlotItem(
      wnd, item, amount)
  end

  function UpdateContainerSlots() -> void
    BuildContainerIndexCache()
    ClampContainerPage()
    for slot = 0, ContainerSlots - 1 do
      UpdateContainerSlot(slot)
    end
    renderedContainerPage = containerPage
    UpdateContainerPageControls()
  end

  function UpdateOrganSlots() -> void
    local container: object
    native.GetContainer(container)
    for slot = 0, OrganSlots - 1 do
      local wnd: string =
        inv_overhaul_container_view.GetOrganSlotWndName(slot)
      if !isCorpse || !showOrgans then
        inv_overhaul_container_view.RenderOrganSlotHidden(wnd)
      else
        inv_overhaul_container_view.BeginOrganSlot(wnd)
        local reference: int = ResolveOrganVisualSlot(slot)
        if reference < 0 then
          inv_overhaul_container_view.RenderOrganSlotEmpty(wnd)
        else
          local index: int =
            inv_overhaul_container_projection.GetReferenceIndex(
              reference)
          inv_overhaul_container_view.BeginOrganSlotItem(wnd)
          local item: object
          local amount: int
          container->GetItem(item, index)
          container->GetItemAmount(amount, index)
          inv_overhaul_container_view.RenderOrganSlotItem(
            wnd, item, amount)
        end
      end
    end
  end

  function UpdateAllSlots() -> void
    initialSlotLoadActive = false
    LootPresenterUpdateLayout()
    UpdatePlayerSlots()
    UpdateContainerSlots()
    UpdateOrganSlots()
    LootPresenterUpdateMoney()
  end

  function RefreshVisibleContainerItem(
    itemID: int,
    fallbackSlot: int) -> void
    initialSlotLoadActive = false
    if renderedContainerPage != containerPage then
      UpdateContainerSlots()
      return
    end
    BuildContainerIndexCache()
    local fallbackUpdated: bool = false
    for slot = 0, ContainerSlots - 1 do
      local update: bool = false
      if slot == fallbackSlot then update = true end
      local reference: int = ResolveContainerVisualSlot(slot)
      if reference >= 0 then
        local index: int =
          inv_overhaul_container_projection.GetReferenceIndex(
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
        UpdateContainerSlot(slot)
        if slot == fallbackSlot then fallbackUpdated = true end
      end
    end
    if !fallbackUpdated && fallbackSlot >= 0 && fallbackSlot < ContainerSlots then
      UpdateContainerSlot(fallbackSlot)
    end
    UpdateContainerPageControls()
  end

  function LootPresenterBeginInitialSlotLoad() -> void
    LootPresenterUpdateLayout()
    ClampPlayerPage()
    inv_overhaul_inventory_items.ItemsBuildIndexCache()
    BuildContainerIndexCache()
    ClampContainerPage()
    UpdatePlayerPageControls()
    UpdateContainerPageControls()
    UpdateOrganSlots()
    LootPresenterUpdateMoney()
    initialPlayerSlotLoadNext = 0
    initialContainerSlotLoadNext = 0
    initialSlotLoadActive = true
    native.Trace("inv_overhaul_container deferred initial slots player=" +
      visibleSlots + " container=" + ContainerSlots)
  end

  function LootPresenterContinueInitialSlotLoad() -> void
    if !initialSlotLoadActive then return end
    for batch = 0, InitialSlotLoadBatch - 1 do
      if initialContainerSlotLoadNext < ContainerSlots then
        local containerSlot: int = initialContainerSlotLoadNext
        UpdateContainerSlot(containerSlot)
        initialContainerSlotLoadNext = initialContainerSlotLoadNext + 1
      else
        if initialPlayerSlotLoadNext < visibleSlots then
          local playerSlot: int = initialPlayerSlotLoadNext
          UpdatePlayerSlot(playerSlot)
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

  function AdvanceMoneyPolling(delta: float) -> void
    moneyPollCooldown = moneyPollCooldown - delta
    if moneyPollCooldown <= 0 then
      moneyPollCooldown = 0.25
      LootPresenterUpdateMoney()
    end
  end

  function ChangePlayerPage(delta: int) -> void
    playerPage = playerPage + delta
    ClampPlayerPage()
    inv_overhaul_inventory_sounds.InventorySoundsPlayAction()
    UpdatePlayerSlots()
  end

  function ChangeContainerPage(delta: int) -> void
    containerPage = containerPage + delta
    ClampContainerPage()
    inv_overhaul_inventory_sounds.InventorySoundsPlayAction()
    UpdateContainerSlots()
  end
end
