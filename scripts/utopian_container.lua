maintask UtopianContainerUI do
  local const c_iCWeapon: int = 0
  local const c_iCClothes: int = 1
  local const c_iCategoryCount: int = 5
  local const c_iBranchBurah: int = 1
  local const c_iSlotEmpty: int = 32768
  local const c_iSlotNumber: int = 65536
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
  local const c_iPanelPointerStride: int = 2000
  local const c_iSlotHotZone: int = 52
  local const c_iSlotDropInset: int = 1
  local const c_iTargetDrop: int = 200
  local const c_iTargetContainerBase: int = 300
  local const c_iTargetOrganBase: int = 400
  local const c_iTargetMoney: int = 500
  local const c_iContainerSlots: int = 12
  local const c_iOrganSlots: int = 4
  local const c_iMaxContainerVisuals: int = 128
  local const c_iTransferMarker: int = 791337

  local windowWidth: int
  local windowHeight: int
  local visibleSlots: int
  local playerPage: int
  local containerPage: int
  local resolvedCategory: int
  local resolvedIndex: int
  local resolvedContainerIndex: int
  local resolvedContainerOrdinal: int
  local slotOrder: object
  local playerOrderSnapshot: object
  local containerOrder: object
  local organOrder: object
  local dragSource: int
  local dragKind: int
  local dragItemID: int
  local dragPlayerCategory: int
  local dragPlayerIndex: int
  local dragContainerIndex: int
  local dragContainerOrdinal: int
  local dragPlayerIsOrgan: bool
  local highlightedTarget: int
  local lastValidDropTarget: int
  local invalidDropTargetFrames: int
  local panelTooltipTarget: int
  local moneyTooltipItem: object
  local moneyItemID: int
  local isCorpse: bool
  local showOrgans: bool
  local corpseVisualPending: bool
  local organVisibilityRefresh: float
  local lastLayoutWidth: int
  local lastLayoutHeight: int
  local deferredInventoryRefresh: float

  function init() -> void
    native.Trace("utopian_container script init diagnostics=1 bidirectional-loot")
    playerPage = 0
    containerPage = 0
    resolvedCategory = -1
    resolvedIndex = -1
    resolvedContainerIndex = -1
    resolvedContainerOrdinal = -1
    dragSource = -1
    dragKind = -1
    dragItemID = -1
    dragPlayerCategory = -1
    dragPlayerIndex = -1
    dragContainerIndex = -1
    dragContainerOrdinal = -1
    dragPlayerIsOrgan = false
    highlightedTarget = -1
    lastValidDropTarget = -1
    invalidDropTargetFrames = 0
    panelTooltipTarget = -999
    lastLayoutWidth = -1
    lastLayoutHeight = -1
    deferredInventoryRefresh = 0
    corpseVisualPending = false
    organVisibilityRefresh = 0.5
    native.SetCursor("default")
    native.ShowCursor()
    native.CaptureKeyboard()
    native.SetOwnerDraw(false)
    native.SetNeedUpdate(true)
    native.CreateInvItem(moneyTooltipItem)
    moneyTooltipItem->SetItemName("Money")
    moneyTooltipItem->GetItemID(moneyItemID)
    InitSlotOrder()
    InitContainerOrders()
    UpdateLayout()
    native.Trace("utopian_container init layout ready")
    DetectContainerKind()
    native.Trace("utopian_container init kind ready corpse=" + isCorpse)
    LoadLayoutVariables()
    native.Trace("utopian_container init variables ready")
    UpdateAllSlots()
    native.Trace("utopian_container init slots ready")
    native.ProcessEvents()
  end

  function GetPlayerContainer() -> object
    local container: object
    native.GetPlayerContainer(container)
    return container
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
    if external then
      local count: int
      external->GetItemCount(count)
      native.Trace("utopian_container external item count=" + count)
      for index = 0, count - 1 do
        local item: object
        local organ: bool = false
        external->GetItem(item, index)
        item->HasProperty(organ, "Organ")
        if organ then
          native.Trace("utopian_container corpse detected by organ item")
          ActivateCorpseMode()
          return
        end
      end
    end
    native.Trace("utopian_container kind awaiting corpse marker")
  end

  function ActivateCorpseMode() -> void
    isCorpse = true
    corpseVisualPending = true
    organVisibilityRefresh = 0.5
    local branch: int = 0
    native.GetVariable("branch", branch)
    showOrgans = branch == c_iBranchBurah
    native.Trace("utopian_container corpse marker branch=" + branch + " organs=" + showOrgans)
    native.SendMessage(-100, "loot_doll")
    UpdateContainerSlots()
    UpdateOrganSlots()
  end

  function InitSlotOrder() -> void
    native.CreateIntVector(slotOrder)
    for i = 0, 39 do slotOrder->add(i) end
    native.CreateIntVector(playerOrderSnapshot)
    for i = 0, 39 do playerOrderSnapshot->add(-1) end
  end

  function InitContainerOrders() -> void
    native.CreateIntVector(containerOrder)
    for i = 0, c_iMaxContainerVisuals - 1 do containerOrder->add(i) end
    native.CreateIntVector(organOrder)
    for i = 0, c_iOrganSlots - 1 do organOrder->add(i) end
  end

  function GetOrderValue(slot: int) -> int
    local order: int = slot
    if slot >= 0 && slot < 40 then slotOrder->get(order, slot) end
    return order
  end

  function SetOrderValue(slot: int, value: int) -> void
    if slot >= 0 && slot < 40 then slotOrder->set(slot, value) end
  end

  function GetContainerOrderValue(visual: int) -> int
    local order: int = visual
    if visual >= 0 && visual < c_iMaxContainerVisuals then containerOrder->get(order, visual) end
    return order
  end

  function SetContainerOrderValue(visual: int, value: int) -> void
    if visual >= 0 && visual < c_iMaxContainerVisuals then containerOrder->set(visual, value) end
  end

  function GetOrganOrderValue(visual: int) -> int
    local order: int = visual
    if visual >= 0 && visual < c_iOrganSlots then organOrder->get(order, visual) end
    return order
  end

  function SetOrganOrderValue(visual: int, value: int) -> void
    if visual >= 0 && visual < c_iOrganSlots then organOrder->set(visual, value) end
  end

  function GetCellVariableName(slot: int) -> string
    return "utopian_inventory_cell_" + slot
  end

  function LoadLayoutVariables() -> void
    local initialized: int = 0
    local version: int = 0
    native.GetVariable("utopian_inventory_layout_initialized", initialized)
    native.GetVariable("utopian_inventory_layout_version", version)
    if initialized != 1 || version != 3 then
      SaveLayoutVariables()
      return
    end
    for i = 0, 39 do
      local order: int = i
      native.GetVariable(GetCellVariableName(i), order)
      if order < 0 || order >= 40 then order = i end
      SetOrderValue(i, order)
    end
    NormalizeSlotOrder()
  end

  function SaveLayoutVariables() -> void
    for i = 0, 39 do native.SetVariable(GetCellVariableName(i), GetOrderValue(i)) end
    native.SetVariable("utopian_inventory_layout_initialized", 1)
    native.SetVariable("utopian_inventory_layout_version", 3)
  end

  function IsOrderUsedBefore(slot: int, order: int) -> bool
    for i = 0, slot - 1 do
      if GetOrderValue(i) == order then return true end
    end
    return false
  end

  function IsOrderUsedAtOrBefore(slot: int, order: int) -> bool
    for i = 0, slot do
      if GetOrderValue(i) == order then return true end
    end
    return false
  end

  function FindFirstUnusedOrder(slot: int) -> int
    for candidate = 0, 39 do
      if !IsOrderUsedAtOrBefore(slot, candidate) then return candidate end
    end
    return slot
  end

  function NormalizeSlotOrder() -> void
    for slot = 0, 39 do
      local order: int = GetOrderValue(slot)
      if order < 0 || order >= 40 || IsOrderUsedBefore(slot, order) then
        SetOrderValue(slot, FindFirstUnusedOrder(slot))
      end
    end
  end

  function UpdateLayout() -> void
    native.GetWindowSize(windowWidth, windowHeight)
    if windowWidth <= 0 || windowHeight <= 0 then native.GetScreenSize(windowWidth, windowHeight) end
    if windowWidth >= 1200 then
      visibleSlots = 40
    else
      if windowWidth >= 1000 then visibleSlots = 35 else visibleSlots = 24 end
    end
    if windowWidth != lastLayoutWidth || windowHeight != lastLayoutHeight then
      native.SendMessage(windowWidth, "panel_background")
      native.SendMessage(5000 + windowHeight, "panel_background")
      lastLayoutWidth = windowWidth
      lastLayoutHeight = windowHeight
    end
  end

  function GetSlotWndName(slot: int) -> string
    local number: int = slot + 1
    if number < 10 then return "slot0" + number end
    return "slot" + number
  end

  function GetContainerSlotWndName(slot: int) -> string
    local number: int = slot + 1
    if number < 10 then return "cslot0" + number end
    return "cslot" + number
  end

  function GetOrganSlotWndName(slot: int) -> string
    local number: int = slot + 1
    if number < 10 then return "oslot0" + number end
    return "oslot" + number
  end

  function GetTargetWndName(target: int) -> string
    if target >= 0 && target < visibleSlots then return GetSlotWndName(target) end
    if target >= c_iTargetContainerBase && target < c_iTargetContainerBase + c_iContainerSlots then
      return GetContainerSlotWndName(target - c_iTargetContainerBase)
    end
    if target >= c_iTargetOrganBase && target < c_iTargetOrganBase + c_iOrganSlots then
      return GetOrganSlotWndName(target - c_iTargetOrganBase)
    end
    if target == c_iTargetDrop then return "drop_slot" end
    return ""
  end

  function GetGridStartX() -> int
    if windowWidth >= 1900 then return 920 end
    if windowWidth >= 1200 then return 600 end
    if windowWidth >= 1000 then return 468 end
    return 359
  end

  function GetGridStartY() -> int
    if windowWidth >= 1900 then return 370 end
    if windowWidth >= 1200 then return 310 end
    if windowWidth >= 1000 then return 266 end
    return 225
  end

  function GetGridStep() -> int
    if windowWidth >= 1200 then return 64 end
    if windowWidth >= 1000 then return 61 end
    return 58
  end

  function GetGridColumns() -> int
    if windowWidth >= 1200 then return 8 end
    if windowWidth >= 1000 then return 7 end
    return 6
  end

  function GetContainerStartX() -> int
    if windowWidth >= 1900 then return 490 end
    if windowWidth >= 1200 then return 170 end
    if windowWidth >= 1000 then return 121 end
    return 79
  end

  function GetContainerStartY() -> int
    if windowWidth >= 1900 then return 410 end
    if windowWidth >= 1200 then return 350 end
    if windowWidth >= 1000 then return 300 end
    return 250
  end

  function GetOrganStartX() -> int
    if windowWidth >= 1900 then return 458 end
    if windowWidth >= 1200 then return 138 end
    if windowWidth >= 1000 then return 90 end
    return 49
  end

  function GetOrganStartY() -> int
    if windowWidth >= 1900 then return 710 end
    if windowWidth >= 1200 then return 650 end
    if windowWidth >= 1000 then return 570 end
    return 482
  end

  function GetDropLeft() -> int
    if windowWidth >= 1900 then return 1126 end
    if windowWidth >= 1200 then return 806 end
    if windowWidth >= 1000 then return 650 end
    return 501
  end

  function GetDropTop() -> int
    if windowWidth >= 1900 then return 745 end
    if windowWidth >= 1200 then return 685 end
    if windowWidth >= 1000 then return 596 end
    return 455
  end

  function GetMoneyLeft() -> int
    if windowWidth >= 1900 then return 1420 end
    if windowWidth >= 1200 then return 1100 end
    if windowWidth >= 1000 then return 864 end
    return 655
  end

  function GetMoneyTop() -> int
    if windowWidth >= 1900 then return 830 end
    if windowWidth >= 1200 then return 770 end
    if windowWidth >= 1000 then return 616 end
    return 465
  end

  function IsEquippedItem(category: int, index: int) -> bool
    if category != c_iCWeapon && category != c_iCClothes then return false end
    local container: object = GetPlayerContainer()
    local selected: bool
    container->IsItemSelected(selected, index, category)
    if !selected then return false end
    local item: object
    container->GetItem(item, index, category)
    local itemID: int
    item->GetItemID(itemID)
    if category == c_iCWeapon then
      local weapon: bool
      native.HasInvItemProperty(weapon, itemID, "Weapon")
      return weapon
    end
    local group: bool
    native.HasInvItemProperty(group, itemID, "Group")
    return group
  end

  function GetBackpackItemCount() -> int
    local container: object = GetPlayerContainer()
    local total: int = 0
    for category = 0, c_iCategoryCount - 1 do
      local count: int
      container->GetItemCount(count, category)
      for index = 0, count - 1 do
        if !IsEquippedItem(category, index) then total = total + 1 end
      end
    end
    return total
  end

  function ClampPlayerPage() -> void
    local total: int = GetBackpackItemCount()
    local maxPage: int = 0
    if total > 0 then maxPage = (total - 1) / visibleSlots end
    if playerPage < 0 then playerPage = 0 end
    if playerPage > maxPage then playerPage = maxPage end
  end

  function ResolveVisibleSlot(slot: int) -> bool
    resolvedCategory = -1
    resolvedIndex = -1
    local target: int = playerPage * visibleSlots + GetOrderValue(slot)
    local current: int = 0
    local container: object = GetPlayerContainer()
    for category = 0, c_iCategoryCount - 1 do
      local count: int
      container->GetItemCount(count, category)
      for index = 0, count - 1 do
        if !IsEquippedItem(category, index) then
          if current == target then
            resolvedCategory = category
            resolvedIndex = index
            return true
          end
          current = current + 1
        end
      end
    end
    return false
  end

  function IsOrganItem(item: object) -> bool
    if !item then return false end
    local organ: bool = false
    item->HasProperty(organ, "Organ")
    return organ
  end

  function IsKnownOrganItemID(itemID: int) -> bool
    local knownID: int
    native.GetInvItemByName(knownID, "liver")
    if itemID == knownID then return true end
    native.GetInvItemByName(knownID, "kidney")
    if itemID == knownID then return true end
    native.GetInvItemByName(knownID, "heart")
    if itemID == knownID then return true end
    native.GetInvItemByName(knownID, "blood")
    if itemID == knownID then return true end
    native.GetInvItemByName(knownID, "diseased_liver")
    if itemID == knownID then return true end
    native.GetInvItemByName(knownID, "diseased_kidney")
    if itemID == knownID then return true end
    native.GetInvItemByName(knownID, "diseased_heart")
    if itemID == knownID then return true end
    native.GetInvItemByName(knownID, "diseased_blood")
    return itemID == knownID
  end

  function IsPlayerOrganItem(category: int, index: int) -> bool
    local player: object = GetPlayerContainer()
    local item: object
    player->GetItem(item, index, category)
    if !item then return false end
    local storedOrgan: bool = false
    item->HasProperty(storedOrgan, "UtopianOrgan")
    if storedOrgan then return true end
    local itemID: int
    item->GetItemID(itemID)
    return IsKnownOrganItemID(itemID)
  end

  function GetNormalContainerItemCount() -> int
    local container: object = GetExternalContainer()
    if !container then return 0 end
    local count: int
    container->GetItemCount(count)
    local normalCount: int = 0
    for index = 0, count - 1 do
      local item: object
      container->GetItem(item, index)
      if !IsOrganItem(item) then normalCount = normalCount + 1 end
    end
    return normalCount
  end

  function GetOrganItemCount() -> int
    local container: object = GetExternalContainer()
    if !container then return 0 end
    local count: int
    container->GetItemCount(count)
    local organCount: int = 0
    for index = 0, count - 1 do
      local item: object
      container->GetItem(item, index)
      if IsOrganItem(item) then organCount = organCount + 1 end
    end
    return organCount
  end

  function ResolveNormalContainerOrdinal(ordinal: int) -> bool
    resolvedContainerIndex = -1
    resolvedContainerOrdinal = -1
    if ordinal < 0 then return false end
    local container: object = GetExternalContainer()
    if !container then return false end
    local count: int
    container->GetItemCount(count)
    local current: int = 0
    for index = 0, count - 1 do
      local item: object
      container->GetItem(item, index)
      if !IsOrganItem(item) then
        if current == ordinal then
          resolvedContainerIndex = index
          resolvedContainerOrdinal = ordinal
          return true
        end
        current = current + 1
      end
    end
    return false
  end

  function ResolveOrganOrdinal(ordinal: int) -> bool
    resolvedContainerIndex = -1
    resolvedContainerOrdinal = -1
    if ordinal < 0 then return false end
    local container: object = GetExternalContainer()
    if !container then return false end
    local count: int
    container->GetItemCount(count)
    local current: int = 0
    for index = 0, count - 1 do
      local item: object
      container->GetItem(item, index)
      if IsOrganItem(item) then
        if current == ordinal then
          resolvedContainerIndex = index
          resolvedContainerOrdinal = ordinal
          return true
        end
        current = current + 1
      end
    end
    return false
  end

  function ResolveContainerVisualSlot(slot: int) -> bool
    local visual: int = containerPage * c_iContainerSlots + slot
    return ResolveNormalContainerOrdinal(GetContainerOrderValue(visual))
  end

  function ResolveOrganVisualSlot(slot: int) -> bool
    if !showOrgans then return false end
    resolvedContainerIndex = -1
    resolvedContainerOrdinal = slot
    local container: object = GetExternalContainer()
    if !container then return false end
    local count: int
    container->GetItemCount(count)
    for index = 0, count - 1 do
      local item: object
      container->GetItem(item, index)
      if IsOrganItem(item) then
        local itemID: int
        item->GetItemID(itemID)
        local organSlot: int = GetOrganSlotByItemID(itemID)
        if organSlot == slot then
          resolvedContainerIndex = index
          return true
        end
      end
    end
    return false
  end

  function GetOrganSlotByItemID(itemID: int) -> int
    local knownID: int
    native.GetInvItemByName(knownID, "liver")
    if itemID == knownID then return 0 end
    native.GetInvItemByName(knownID, "diseased_liver")
    if itemID == knownID then return 0 end
    native.GetInvItemByName(knownID, "kidney")
    if itemID == knownID then return 1 end
    native.GetInvItemByName(knownID, "diseased_kidney")
    if itemID == knownID then return 1 end
    native.GetInvItemByName(knownID, "heart")
    if itemID == knownID then return 2 end
    native.GetInvItemByName(knownID, "diseased_heart")
    if itemID == knownID then return 2 end
    native.GetInvItemByName(knownID, "blood")
    if itemID == knownID then return 3 end
    native.GetInvItemByName(knownID, "diseased_blood")
    if itemID == knownID then return 3 end
    return -1
  end

  function GetLastOccupiedContainerVisual() -> int
    local count: int = GetNormalContainerItemCount()
    if count <= 0 then return -1 end
    local last: int = -1
    for visual = 0, c_iMaxContainerVisuals - 1 do
      if GetContainerOrderValue(visual) < count then last = visual end
    end
    return last
  end

  function ClampContainerPage() -> void
    local last: int = GetLastOccupiedContainerVisual()
    local maxPage: int = 0
    if last >= 0 then maxPage = last / c_iContainerSlots end
    if containerPage < 0 then containerPage = 0 end
    if containerPage > maxPage then containerPage = maxPage end
  end

  function UpdateMoney() -> void
    local container: object = GetPlayerContainer()
    local money: int
    container->GetProperty("money", money)
    native.SendMessage(money, "money")
  end

  function UpdatePlayerSlots() -> void
    ClampPlayerPage()
    local container: object = GetPlayerContainer()
    for slot = 0, visibleSlots - 1 do
      local wnd: string = GetSlotWndName(slot)
      if ResolveVisibleSlot(slot) then
        local item: object
        local amount: int
        container->GetItem(item, resolvedIndex, resolvedCategory)
        container->GetItemAmount(amount, resolvedIndex, resolvedCategory)
        native.SendMessage(0, wnd, item)
        native.SendMessage(amount + c_iSlotNumber, wnd)
      else
        native.SendMessage(c_iSlotEmpty, wnd)
      end
    end
  end

  function UpdateContainerSlots() -> void
    ClampContainerPage()
    local container: object = GetExternalContainer()
    for slot = 0, c_iContainerSlots - 1 do
      local wnd: string = GetContainerSlotWndName(slot)
      if ResolveContainerVisualSlot(slot) then
        local item: object
        local amount: int
        container->GetItem(item, resolvedContainerIndex)
        container->GetItemAmount(amount, resolvedContainerIndex)
        native.SendMessage(0, wnd, item)
        native.SendMessage(amount + c_iSlotNumber, wnd)
      else
        native.SendMessage(c_iSlotEmpty, wnd)
      end
    end
  end

  function UpdateOrganSlots() -> void
    local container: object = GetExternalContainer()
    for slot = 0, c_iOrganSlots - 1 do
      local wnd: string = GetOrganSlotWndName(slot)
      if !isCorpse || !showOrgans then
        native.SendMessage(c_iSlotEmpty, wnd)
        native.SendMessage(-22, wnd)
      else
        native.SendMessage(-23, wnd)
        if ResolveOrganVisualSlot(slot) then
          native.SendMessage(-25, wnd)
          local item: object
          local amount: int
          container->GetItem(item, resolvedContainerIndex)
          container->GetItemAmount(amount, resolvedContainerIndex)
          native.SendMessage(0, wnd, item)
          native.SendMessage(amount + c_iSlotNumber, wnd)
        else
          native.SendMessage(c_iSlotEmpty, wnd)
          native.SendMessage(-24, wnd)
        end
      end
    end
  end

  function UpdateAllSlots() -> void
    UpdateLayout()
    UpdatePlayerSlots()
    UpdateContainerSlots()
    UpdateOrganSlots()
    UpdateMoney()
  end

  function SwapSlotOrder(sourceSlot: int, targetSlot: int) -> void
    if sourceSlot < 0 || targetSlot < 0 || sourceSlot == targetSlot then return end
    if sourceSlot >= visibleSlots || targetSlot >= visibleSlots then return end
    local sourceOrder: int = GetOrderValue(sourceSlot)
    local targetOrder: int = GetOrderValue(targetSlot)
    SetOrderValue(sourceSlot, targetOrder)
    SetOrderValue(targetSlot, sourceOrder)
    SaveLayoutVariables()
  end

  function SwapContainerSlotOrder(sourceSlot: int, targetSlot: int) -> void
    if sourceSlot < 0 || sourceSlot >= c_iContainerSlots then return end
    if targetSlot < 0 || targetSlot >= c_iContainerSlots || sourceSlot == targetSlot then return end
    local sourceVisual: int = containerPage * c_iContainerSlots + sourceSlot
    local targetVisual: int = containerPage * c_iContainerSlots + targetSlot
    local sourceOrder: int = GetContainerOrderValue(sourceVisual)
    local targetOrder: int = GetContainerOrderValue(targetVisual)
    SetContainerOrderValue(sourceVisual, targetOrder)
    SetContainerOrderValue(targetVisual, sourceOrder)
    UpdateContainerSlots()
  end

  function RemoveOrderOrdinal(removedOrder: int, beforeCount: int) -> void
    if removedOrder < 0 then return end
    local emptyOrder: int = beforeCount - 1
    for slot = 0, 39 do
      local order: int = GetOrderValue(slot)
      if order == removedOrder then
        SetOrderValue(slot, emptyOrder)
      else
        if order > removedOrder && order < beforeCount then SetOrderValue(slot, order - 1) end
      end
    end
    NormalizeSlotOrder()
    SaveLayoutVariables()
  end

  function FindFirstFreePlayerVisual(itemCount: int) -> int
    for slot = 0, visibleSlots - 1 do
      if GetOrderValue(slot) >= itemCount then return slot end
    end
    return -1
  end

  function GetBackpackOrdinal(category: int, index: int) -> int
    local container: object = GetPlayerContainer()
    local ordinal: int = 0
    for currentCategory = 0, c_iCategoryCount - 1 do
      local count: int
      container->GetItemCount(count, currentCategory)
      for currentIndex = 0, count - 1 do
        if !IsEquippedItem(currentCategory, currentIndex) then
          if currentCategory == category && currentIndex == index then return ordinal end
          ordinal = ordinal + 1
        end
      end
    end
    return -1
  end

  function SnapshotExistingPlayerOrder() -> void
    local player: object = GetPlayerContainer()
    local ordinal: int = 0
    for category = 0, c_iCategoryCount - 1 do
      local count: int
      player->GetItemCount(count, category)
      for index = 0, count - 1 do
        if !IsEquippedItem(category, index) then
          local item: object
          local itemID: int
          player->GetItem(item, index, category)
          item->GetItemID(itemID)
          playerOrderSnapshot->set(ordinal, itemID)
          ordinal = ordinal + 1
        end
      end
    end
    for emptyOrdinal = ordinal, 39 do playerOrderSnapshot->set(emptyOrdinal, -1) end
  end

  function FindSnapshotPlayerOrdinal(oldOrder: int, insertedCategory: int, insertedIndex: int) -> int
    local player: object = GetPlayerContainer()
    local wantedItemID: int
    playerOrderSnapshot->get(wantedItemID, oldOrder)
    local wantedOccurrence: int = 0
    for previousOrder = 0, oldOrder - 1 do
      local previousItemID: int
      playerOrderSnapshot->get(previousItemID, previousOrder)
      if previousItemID == wantedItemID then wantedOccurrence = wantedOccurrence + 1 end
    end
    local ordinal: int = 0
    local occurrence: int = 0
    for category = 0, c_iCategoryCount - 1 do
      local count: int
      player->GetItemCount(count, category)
      for index = 0, count - 1 do
        if !IsEquippedItem(category, index) then
          if category != insertedCategory || index != insertedIndex then
            local item: object
            local itemID: int
            player->GetItem(item, index, category)
            item->GetItemID(itemID)
            if itemID == wantedItemID then
              if occurrence == wantedOccurrence then return ordinal end
              occurrence = occurrence + 1
            end
          end
          ordinal = ordinal + 1
        end
      end
    end
    return -1
  end

  function RestorePlayerOrderAfterInsert(insertedOrder: int, insertedCategory: int, insertedIndex: int, beforeCount: int, preferredSlot: int) -> bool
    if insertedOrder < 0 || beforeCount >= 40 then return false end
    local insertedSlot: int = -1
    for slot = 0, 39 do
      local oldOrder: int = GetOrderValue(slot)
      if oldOrder < beforeCount then
        local mappedOrder: int = FindSnapshotPlayerOrdinal(oldOrder, insertedCategory, insertedIndex)
        if mappedOrder >= 0 then SetOrderValue(slot, mappedOrder) end
      else
        if oldOrder == beforeCount then
          SetOrderValue(slot, insertedOrder)
          insertedSlot = slot
        end
      end
    end
    if insertedSlot < 0 then return false end
    if preferredSlot >= 0 && preferredSlot < visibleSlots && preferredSlot != insertedSlot then
      local preferredOrder: int = GetOrderValue(preferredSlot)
      SetOrderValue(preferredSlot, insertedOrder)
      SetOrderValue(insertedSlot, preferredOrder)
    end
    NormalizeSlotOrder()
    SaveLayoutVariables()
    return true
  end

  function FindRemainingPlayerOrdinal(oldOrder: int, removedOrder: int) -> int
    local wantedItemID: int
    local removedItemID: int
    playerOrderSnapshot->get(wantedItemID, oldOrder)
    playerOrderSnapshot->get(removedItemID, removedOrder)
    local wantedOccurrence: int = 0
    for previousOrder = 0, oldOrder - 1 do
      local previousItemID: int
      playerOrderSnapshot->get(previousItemID, previousOrder)
      if previousItemID == wantedItemID then wantedOccurrence = wantedOccurrence + 1 end
    end
    if removedOrder < oldOrder && removedItemID == wantedItemID then
      wantedOccurrence = wantedOccurrence - 1
    end

    local player: object = GetPlayerContainer()
    local ordinal: int = 0
    local occurrence: int = 0
    for category = 0, c_iCategoryCount - 1 do
      local count: int
      player->GetItemCount(count, category)
      for index = 0, count - 1 do
        if !IsEquippedItem(category, index) then
          local item: object
          local itemID: int
          player->GetItem(item, index, category)
          item->GetItemID(itemID)
          if itemID == wantedItemID then
            if occurrence == wantedOccurrence then return ordinal end
            occurrence = occurrence + 1
          end
          ordinal = ordinal + 1
        end
      end
    end
    return -1
  end

  function RestorePlayerOrderAfterRemove(removedOrder: int, beforeCount: int) -> bool
    if removedOrder < 0 || removedOrder >= beforeCount then return false end
    for slot = 0, 39 do
      local oldOrder: int = GetOrderValue(slot)
      if oldOrder == removedOrder then
        SetOrderValue(slot, beforeCount - 1)
      else
        if oldOrder < beforeCount then
          local mappedOrder: int = FindRemainingPlayerOrdinal(oldOrder, removedOrder)
          if mappedOrder >= 0 then SetOrderValue(slot, mappedOrder) end
        end
      end
    end
    NormalizeSlotOrder()
    SaveLayoutVariables()
    return true
  end

  function InsertOrderOrdinalAt(insertedOrder: int, beforeCount: int, preferredSlot: int) -> bool
    if insertedOrder < 0 then return false end
    if beforeCount >= 40 then return false end
    local insertedSlot: int = -1
    for slot = 0, 39 do
      local order: int = GetOrderValue(slot)
      if order == beforeCount then
        SetOrderValue(slot, insertedOrder)
        insertedSlot = slot
      else
        if order >= insertedOrder && order < beforeCount then SetOrderValue(slot, order + 1) end
      end
    end
    if insertedSlot < 0 then return false end
    if preferredSlot >= 0 && preferredSlot < visibleSlots && preferredSlot != insertedSlot then
      local preferredOrder: int = GetOrderValue(preferredSlot)
      SetOrderValue(preferredSlot, insertedOrder)
      SetOrderValue(insertedSlot, preferredOrder)
    end
    NormalizeSlotOrder()
    SaveLayoutVariables()
    return true
  end

  function FindFirstFreeContainerVisual(itemCount: int) -> int
    for visual = 0, c_iMaxContainerVisuals - 1 do
      if GetContainerOrderValue(visual) >= itemCount then return visual end
    end
    return -1
  end

  function InsertContainerOrdinalAt(insertedOrder: int, beforeCount: int, preferredSlot: int) -> bool
    if insertedOrder < 0 then return false end
    if beforeCount >= c_iMaxContainerVisuals then return false end
    local preferredVisual: int = containerPage * c_iContainerSlots + preferredSlot
    local insertedVisual: int = -1
    for visual = 0, c_iMaxContainerVisuals - 1 do
      local order: int = GetContainerOrderValue(visual)
      if order == beforeCount then
        SetContainerOrderValue(visual, insertedOrder)
        insertedVisual = visual
      else
        if order >= insertedOrder && order < beforeCount then SetContainerOrderValue(visual, order + 1) end
      end
    end
    if insertedVisual < 0 then return false end
    if preferredSlot >= 0 && preferredSlot < c_iContainerSlots && preferredVisual != insertedVisual then
      local preferredOrder: int = GetContainerOrderValue(preferredVisual)
      SetContainerOrderValue(preferredVisual, insertedOrder)
      SetContainerOrderValue(insertedVisual, preferredOrder)
    end
    return true
  end

  function FindFirstFreeOrganVisual(itemCount: int) -> int
    for visual = 0, c_iOrganSlots - 1 do
      if GetOrganOrderValue(visual) >= itemCount then return visual end
    end
    return -1
  end

  function InsertOrganOrdinalAt(insertedOrder: int, beforeCount: int, preferredSlot: int) -> bool
    if insertedOrder < 0 then return false end
    local freeSlot: int = -1
    if preferredSlot >= 0 && preferredSlot < c_iOrganSlots then
      if GetOrganOrderValue(preferredSlot) >= beforeCount then freeSlot = preferredSlot end
    end
    if freeSlot < 0 then freeSlot = FindFirstFreeOrganVisual(beforeCount) end
    if freeSlot < 0 then return false end
    local preferredOccupied: bool = preferredSlot >= 0 && preferredSlot < c_iOrganSlots && GetOrganOrderValue(preferredSlot) < beforeCount
    for visual = 0, c_iOrganSlots - 1 do
      if visual != freeSlot then
        local order: int = GetOrganOrderValue(visual)
        if order >= insertedOrder && order < beforeCount then SetOrganOrderValue(visual, order + 1) end
      end
    end
    if preferredOccupied then
      SetOrganOrderValue(freeSlot, GetOrganOrderValue(preferredSlot))
      SetOrganOrderValue(preferredSlot, insertedOrder)
    else
      SetOrganOrderValue(freeSlot, insertedOrder)
    end
    return true
  end

  function RemoveContainerOrdinal(removedOrder: int, beforeCount: int) -> void
    if removedOrder < 0 then return end
    local emptyOrder: int = beforeCount - 1
    for visual = 0, c_iMaxContainerVisuals - 1 do
      local order: int = GetContainerOrderValue(visual)
      if order == removedOrder then
        SetContainerOrderValue(visual, emptyOrder)
      else
        if order > removedOrder && order < beforeCount then SetContainerOrderValue(visual, order - 1) end
      end
    end
  end

  function RemoveOrganOrdinal(removedOrder: int, beforeCount: int) -> void
    if removedOrder < 0 then return end
    local emptyOrder: int = beforeCount - 1
    for visual = 0, c_iOrganSlots - 1 do
      local order: int = GetOrganOrderValue(visual)
      if order == removedOrder then
        SetOrganOrderValue(visual, emptyOrder)
      else
        if order > removedOrder && order < beforeCount then SetOrganOrderValue(visual, order - 1) end
      end
    end
  end

  function TogglePlayerSlot(category: int, index: int) -> void
    local container: object = GetPlayerContainer()
    local item: object
    container->GetItem(item, index, category)
    if !item then return end
    local itemID: int
    item->GetItemID(itemID)
    local amount: int
    container->GetItemAmount(amount, index, category)
    local selected: bool
    container->IsItemSelected(selected, index, category)

    if category == c_iCWeapon then
      local weapon: bool
      native.HasInvItemProperty(weapon, itemID, "Weapon")
      if !weapon then return end
      if selected then
        container->SelectItem(index, false, category)
        native.SetPlayerHandsItem(-1)
      else
        native.SetPlayerHandsItem(itemID)
        local count: int
        container->GetItemCount(count, category)
        for i = 0, count - 1 do container->SelectItem(i, false, category) end
        container->SelectItem(index, true, category)
      end
      return
    end

    if category == c_iCClothes then
      local hasGroup: bool
      native.HasInvItemProperty(hasGroup, itemID, "Group")
      if !hasGroup then return end
      local group: int
      native.GetInvItemProperty(group, itemID, "Group")
      if selected then
        container->SelectItem(index, false, category)
      else
        local count: int
        container->GetItemCount(count, category)
        for i = 0, count - 1 do
          local other: object
          container->GetItem(other, i, category)
          local otherID: int
          other->GetItemID(otherID)
          local otherHasGroup: bool
          native.HasInvItemProperty(otherHasGroup, otherID, "Group")
          if otherHasGroup then
            local otherGroup: int
            native.GetInvItemProperty(otherGroup, otherID, "Group")
            if otherGroup == group then container->SelectItem(i, false, category) end
          end
        end
        container->SelectItem(index, true, category)
      end
      return
    end

    local used: bool
    native.UseItem(index, category, used)
    if used then
      deferredInventoryRefresh = 0.25
      amount = amount - 1
      if amount == 0 then container->RemoveItem(index, 1, category) else container->SetItemAmount(amount, index, category) end
    end
  end

  function FindPlayerTransferMarkerIndex(category: int) -> int
    local player: object = GetPlayerContainer()
    local count: int
    player->GetItemCount(count, category)
    for index = 0, count - 1 do
      local item: object
      player->GetItem(item, index, category)
      local hasMarker: bool = false
      item->HasProperty(hasMarker, "UtopianTransferMarker")
      if hasMarker then return index end
    end
    return -1
  end

  function FindPlayerItemIndexByID(category: int, wantedItemID: int) -> int
    local player: object = GetPlayerContainer()
    local count: int
    player->GetItemCount(count, category)
    for index = 0, count - 1 do
      local candidate: object
      player->GetItem(candidate, index, category)
      local candidateID: int
      candidate->GetItemID(candidateID)
      if candidateID == wantedItemID then return index end
    end
    return -1
  end

  function FindExternalTransferMarkerOrdinal(organItem: bool) -> int
    local external: object = GetExternalContainer()
    local count: int
    external->GetItemCount(count)
    local ordinal: int = 0
    for index = 0, count - 1 do
      local item: object
      external->GetItem(item, index)
      if IsOrganItem(item) == organItem then
        local hasMarker: bool = false
        item->HasProperty(hasMarker, "UtopianTransferMarker")
        if hasMarker then
          item->RemoveProperty("UtopianTransferMarker")
          return ordinal
        end
        ordinal = ordinal + 1
      end
    end
    return -1
  end

  function FindExternalItemOrdinalByID(organItem: bool, wantedItemID: int) -> int
    local external: object = GetExternalContainer()
    local count: int
    external->GetItemCount(count)
    local ordinal: int = 0
    for index = 0, count - 1 do
      local candidate: object
      external->GetItem(candidate, index)
      if IsOrganItem(candidate) == organItem then
        local candidateID: int
        candidate->GetItemID(candidateID)
        if candidateID == wantedItemID then return ordinal end
        ordinal = ordinal + 1
      end
    end
    return -1
  end

  function MovePlayerToContainer(sourceSlot: int, targetSlot: int, asOrgan: bool) -> void
    if !ResolveVisibleSlot(sourceSlot) then return end
    local player: object = GetPlayerContainer()
    local external: object = GetExternalContainer()
    if !external then return end

    local category: int = resolvedCategory
    local index: int = resolvedIndex
    local beforeBackpack: int = GetBackpackItemCount()
    local usedOrder: int = GetBackpackOrdinal(category, index)
    local beforeExternal: int
    if asOrgan then beforeExternal = GetOrganItemCount() else beforeExternal = GetNormalContainerItemCount() end
    local item: object
    player->GetItem(item, index, category)
    if !item then return end
    SnapshotExistingPlayerOrder()
    local itemID: int
    item->GetItemID(itemID)

    if asOrgan then
      item->RemoveProperty("UtopianOrgan")
      item->SetProperty("Organ", 1)
    end
    local success: bool
    external->AddItem(success, item, 0, 1)
    if !success then
      if asOrgan then
        item->RemoveProperty("Organ")
        item->SetProperty("UtopianOrgan", 1)
      end
      native.Trace("utopian_container player-to-container rejected slot=" + sourceSlot)
      return
    end
    local insertedExternalOrdinal: int = FindExternalItemOrdinalByID(asOrgan, itemID)

    if category == c_iCWeapon then
      local selected: bool
      player->IsItemSelected(selected, index, category)
      if selected then native.SetPlayerHandsItem(-1) end
    end
    player->RemoveItem(index, 1, category)

    local afterBackpack: int = GetBackpackItemCount()
    if afterBackpack < beforeBackpack then
      RestorePlayerOrderAfterRemove(usedOrder, beforeBackpack)
      native.Trace("utopian_container restored player order after remove=" + usedOrder)
    end
    local afterExternal: int
    if asOrgan then afterExternal = GetOrganItemCount() else afterExternal = GetNormalContainerItemCount() end
    if afterExternal > beforeExternal then
      if asOrgan then InsertOrganOrdinalAt(insertedExternalOrdinal, beforeExternal, targetSlot) else InsertContainerOrdinalAt(insertedExternalOrdinal, beforeExternal, targetSlot) end
    end
    native.Trace("utopian_container moved player-to-container source=" + sourceSlot + " target=" + targetSlot + " organ=" + asOrgan + " inserted=" + insertedExternalOrdinal + " before=" + beforeExternal + " after=" + afterExternal)
    UpdateAllSlots()
  end

  function MoveExternalToPlayer(organSource: bool, sourceSlot: int, targetSlot: int) -> void
    local found: bool
    if organSource then found = ResolveOrganVisualSlot(sourceSlot) else found = ResolveContainerVisualSlot(sourceSlot) end
    if !found then return end

    local external: object = GetExternalContainer()
    local player: object = GetPlayerContainer()
    local sourceIndex: int = resolvedContainerIndex
    local sourceOrdinal: int = resolvedContainerOrdinal
    local beforeNormal: int = GetNormalContainerItemCount()
    local beforeOrgans: int = GetOrganItemCount()
    local beforeBackpack: int = GetBackpackItemCount()
    local item: object
    local amount: int
    external->GetItem(item, sourceIndex)
    external->GetItemAmount(amount, sourceIndex)
    if !item || amount <= 0 then return end

    local itemID: int
    item->GetItemID(itemID)
    if itemID == moneyItemID then
      local money: int
      player->GetProperty("money", money)
      player->SetProperty("money", money + amount)
      external->RemoveItem(sourceIndex, amount)
      if organSource then RemoveOrganOrdinal(sourceOrdinal, beforeOrgans) else RemoveContainerOrdinal(sourceOrdinal, beforeNormal) end
      native.Trace("utopian_container took money amount=" + amount)
      UpdateAllSlots()
      return
    end

    local category: int
    native.GetInvItemProperty(category, itemID, "Category")
    SnapshotExistingPlayerOrder()
    if organSource then
      item->SetProperty("UtopianOrgan", 1)
      item->RemoveProperty("Organ")
    end
    local success: bool
    player->AddItem(success, item, category, 1)
    if !success then
      if organSource then
        item->RemoveProperty("UtopianOrgan")
        item->SetProperty("Organ", 1)
      end
      native.Trace("utopian_container container-to-player rejected source=" + sourceSlot)
      return
    end

    local insertedPlayerIndex: int = FindPlayerItemIndexByID(category, itemID)

    external->RemoveItem(sourceIndex, 1)
    if amount == 1 then
      if !organSource then RemoveContainerOrdinal(sourceOrdinal, beforeNormal) end
    end

    local afterBackpack: int = GetBackpackItemCount()
    if afterBackpack > beforeBackpack then
      local insertedOrder: int = GetBackpackOrdinal(category, insertedPlayerIndex)
      RestorePlayerOrderAfterInsert(insertedOrder, category, insertedPlayerIndex, beforeBackpack, targetSlot)
      native.Trace("utopian_container restored player order inserted=" + insertedOrder + " target=" + targetSlot)
    end
    if organSource then native.PlaySound("take_organ") end
    native.Trace("utopian_container moved container-to-player source=" + sourceSlot + " target=" + targetSlot + " organ=" + organSource + " index=" + insertedPlayerIndex + " before=" + beforeBackpack + " after=" + afterBackpack)
    UpdateAllSlots()
  end

  function DropPlayerToWorld(sourceSlot: int) -> void
    if !ResolveVisibleSlot(sourceSlot) then return end
    local player: object = GetPlayerContainer()
    local category: int = resolvedCategory
    local index: int = resolvedIndex
    local beforeBackpack: int = GetBackpackItemCount()
    local usedOrder: int = GetBackpackOrdinal(category, index)
    local item: object
    player->GetItem(item, index, category)
    if !item then return end
    SnapshotExistingPlayerOrder()

    if category == c_iCWeapon then
      local selected: bool
      player->IsItemSelected(selected, index, category)
      if selected then native.SetPlayerHandsItem(-1) end
    end
    player->DropItems(item, 1)
    player->RemoveItem(index, 1, category)
    if GetBackpackItemCount() < beforeBackpack then RestorePlayerOrderAfterRemove(usedOrder, beforeBackpack) end
    native.Trace("utopian_container dropped player item source=" + sourceSlot)
    UpdateAllSlots()
  end

  function ResolveDragSource(source: int) -> bool
    dragKind = -1
    dragPlayerCategory = -1
    dragPlayerIndex = -1
    dragContainerIndex = -1
    dragContainerOrdinal = -1
    dragPlayerIsOrgan = false
    local item: object

    if source >= 0 && source < visibleSlots then
      if !ResolveVisibleSlot(source) then return false end
      dragKind = 0
      dragPlayerCategory = resolvedCategory
      dragPlayerIndex = resolvedIndex
      dragPlayerIsOrgan = IsPlayerOrganItem(dragPlayerCategory, dragPlayerIndex)
      local player: object = GetPlayerContainer()
      player->GetItem(item, dragPlayerIndex, dragPlayerCategory)
    else
      if source >= c_iTargetContainerBase && source < c_iTargetContainerBase + c_iContainerSlots then
        if !ResolveContainerVisualSlot(source - c_iTargetContainerBase) then return false end
        dragKind = 1
      else
        if source >= c_iTargetOrganBase && source < c_iTargetOrganBase + c_iOrganSlots then
          if !ResolveOrganVisualSlot(source - c_iTargetOrganBase) then return false end
          dragKind = 2
        else
          return false
        end
      end
      dragContainerIndex = resolvedContainerIndex
      dragContainerOrdinal = resolvedContainerOrdinal
      local external: object = GetExternalContainer()
      external->GetItem(item, dragContainerIndex)
    end

    if !item then return false end
    item->GetItemID(dragItemID)
    return true
  end

  function BeginDragCursor(source: int) -> bool
    native.SetVariable("utopian_inventory_drag_item", -1)
    dragItemID = -1
    if !ResolveDragSource(source) then return false end
    native.SetVariable("utopian_inventory_drag_item", dragItemID)
    native.SetCursor("drag_item")
    return true
  end

  function EndDragCursor() -> void
    native.SetVariable("utopian_inventory_drag_item", -1)
    native.SetCursor("default")
    dragItemID = -1
    dragKind = -1
    dragPlayerCategory = -1
    dragPlayerIndex = -1
    dragContainerIndex = -1
    dragContainerOrdinal = -1
    dragPlayerIsOrgan = false
  end

  function GetPlayerSlotBySender(sender: string) -> int
    for slot = 0, visibleSlots - 1 do
      if sender == GetSlotWndName(slot) then return slot end
    end
    return -1
  end

  function GetContainerSlotBySender(sender: string) -> int
    for slot = 0, c_iContainerSlots - 1 do
      if sender == GetContainerSlotWndName(slot) then return slot end
    end
    return -1
  end

  function GetOrganSlotBySender(sender: string) -> int
    for slot = 0, c_iOrganSlots - 1 do
      if sender == GetOrganSlotWndName(slot) then return slot end
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

  function IsInsideSlotDropArea(localX: int, localY: int) -> bool
    return localX >= c_iSlotDropInset && localY >= c_iSlotDropInset &&
      localX < c_iSlotHotZone - c_iSlotDropInset && localY < c_iSlotHotZone - c_iSlotDropInset
  end

  function FindGridSlotAt(x: int, y: int, startX: int, startY: int, columns: int, rows: int, count: int) -> int
    local step: int = GetGridStep()
    if x < startX || y < startY || x >= startX + columns * step || y >= startY + rows * step then return -1 end
    local column: int = (x - startX) / step
    local row: int = (y - startY) / step
    local localX: int = x - startX - column * step
    local localY: int = y - startY - row * step
    if !IsInsideSlotDropArea(localX, localY) then return -1 end
    local slot: int = row * columns + column
    if slot < 0 || slot >= count then return -1 end
    return slot
  end

  function FindPlayerSlotAt(x: int, y: int) -> int
    local columns: int = GetGridColumns()
    local rows: int = (visibleSlots + columns - 1) / columns
    return FindGridSlotAt(x, y, GetGridStartX(), GetGridStartY(), columns, rows, visibleSlots)
  end

  function FindContainerSlotAt(x: int, y: int) -> int
    return FindGridSlotAt(x, y, GetContainerStartX(), GetContainerStartY(), 3, 4, c_iContainerSlots)
  end

  function FindOrganSlotAt(x: int, y: int) -> int
    if !showOrgans then return -1 end
    return FindGridSlotAt(x, y, GetOrganStartX(), GetOrganStartY(), 4, 1, c_iOrganSlots)
  end

  function IsInsideMoney(x: int, y: int) -> bool
    local left: int = GetMoneyLeft()
    local top: int = GetMoneyTop()
    return x >= left && y >= top && x < left + c_iSlotHotZone && y < top + c_iSlotHotZone
  end

  function FindTargetAt(x: int, y: int) -> int
    local slot: int = FindPlayerSlotAt(x, y)
    if slot >= 0 then return slot end
    slot = FindContainerSlotAt(x, y)
    if slot >= 0 then return c_iTargetContainerBase + slot end
    slot = FindOrganSlotAt(x, y)
    if slot >= 0 then return c_iTargetOrganBase + slot end
    return -1
  end

  function IsTargetCompatible(target: int) -> bool
    if dragKind == 0 then
      if target >= 0 && target < visibleSlots then return true end
      if target >= c_iTargetContainerBase && target < c_iTargetContainerBase + c_iContainerSlots then return true end
      return false
    end
    if dragKind == 1 then
      if target >= 0 && target < visibleSlots then return true end
      return target >= c_iTargetContainerBase && target < c_iTargetContainerBase + c_iContainerSlots
    end
    if dragKind == 2 then return target >= 0 && target < visibleSlots end
    return false
  end

  function SetHighlightedTarget(target: int) -> void
    if target >= 0 && !IsTargetCompatible(target) then target = -1 end
    if highlightedTarget == target then return end
    if highlightedTarget >= 0 then native.SendMessage(-21, GetTargetWndName(highlightedTarget)) end
    highlightedTarget = target
    if highlightedTarget >= 0 then native.SendMessage(-20, GetTargetWndName(highlightedTarget)) end
  end

  function ApplyPointerTarget(target: int) -> void
    if dragSource < 0 then return end
    if target >= 0 && target != dragSource && IsTargetCompatible(target) then
      lastValidDropTarget = target
      invalidDropTargetFrames = 0
      SetHighlightedTarget(target)
    else
      if target < 0 then invalidDropTargetFrames = invalidDropTargetFrames + 1 else invalidDropTargetFrames = 0 end
      SetHighlightedTarget(-1)
    end
  end

  function StartDragAction(source: int, sender: string) -> void
    if dragSource >= 0 then return end
    if !BeginDragCursor(source) then return end
    dragSource = source
    lastValidDropTarget = -1
    invalidDropTargetFrames = 0
    SetHighlightedTarget(-1)
    native.Trace("utopian_container drag-start sender=" + sender + " source=" + source + " kind=" + dragKind)
  end

  function FinishDrag(target: int) -> void
    if dragSource < 0 then return end
    if target < 0 && lastValidDropTarget >= 0 && invalidDropTargetFrames <= 3 then target = lastValidDropTarget end
    local source: int = dragSource
    local sourceKind: int = dragKind
    native.Trace("utopian_container drag-finish source=" + source + " target=" + target + " kind=" + sourceKind)

    if IsTargetCompatible(target) then
      if sourceKind == 0 then
        if target >= 0 && target < visibleSlots then
          if target != source then
            SwapSlotOrder(source, target)
            UpdatePlayerSlots()
          end
        else
          if target >= c_iTargetContainerBase && target < c_iTargetContainerBase + c_iContainerSlots then
            MovePlayerToContainer(source, target - c_iTargetContainerBase, false)
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
            SwapContainerSlotOrder(source - c_iTargetContainerBase, target - c_iTargetContainerBase)
          end
        end
      end
    end

    dragSource = -1
    SetHighlightedTarget(-1)
    lastValidDropTarget = -1
    invalidDropTargetFrames = 0
    EndDragCursor()
  end

  function QuickTransfer(source: int) -> void
    if source >= 0 && source < visibleSlots then
      if !ResolveVisibleSlot(source) then return end
      local visual: int = FindFirstFreeContainerVisual(GetNormalContainerItemCount())
      if visual < 0 then
        native.Trace("utopian_container quick player-to-container refused: no visual slot")
        return
      end
      containerPage = visual / c_iContainerSlots
      MovePlayerToContainer(source, visual - containerPage * c_iContainerSlots, false)
      return
    end

    local playerTarget: int = FindFirstFreePlayerVisual(GetBackpackItemCount())
    if playerTarget < 0 then playerTarget = 0 end
    if source >= c_iTargetContainerBase && source < c_iTargetContainerBase + c_iContainerSlots then
      MoveExternalToPlayer(false, source - c_iTargetContainerBase, playerTarget)
      return
    end
    if source >= c_iTargetOrganBase && source < c_iTargetOrganBase + c_iOrganSlots then
      MoveExternalToPlayer(true, source - c_iTargetOrganBase, playerTarget)
    end
  end

  function GetSlotTargetFromPointerMessage(message: int, base: int, sender: string) -> int
    local target: int = GetTargetBySender(sender)
    if target < 0 then return -1 end
    local encoded: int = message - base
    local localX: int = encoded / 100
    local localY: int = encoded - localX * 100
    if IsInsideSlotDropArea(localX, localY) then return target end
    return -1
  end

  function ClearPanelTooltip() -> void
    if panelTooltipTarget != -1 then
      panelTooltipTarget = -1
      native.SendMessage(-1, "panel_background")
    end
  end

  function UpdatePanelTooltip(x: int, y: int) -> void
    if dragSource >= 0 then
      ClearPanelTooltip()
      return
    end
    if IsInsideMoney(x, y) then
      if panelTooltipTarget != c_iTargetMoney then
        panelTooltipTarget = c_iTargetMoney
        native.SendMessage(1, "panel_background", moneyTooltipItem)
      end
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
    if panelTooltipTarget != target then
      panelTooltipTarget = target
      native.SendMessage(1, "panel_background", item)
    end
  end

  function StartPanelPointerDrag(x: int, y: int) -> void
    local source: int = FindTargetAt(x, y)
    if source < 0 then return end
    StartDragAction(source, "panel_background")
  end

  function GetPanelPointerX(message: int, base: int) -> int
    local encoded: int = message - base
    return encoded / c_iPanelPointerStride
  end

  function GetPanelPointerY(message: int, base: int) -> int
    local encoded: int = message - base
    local x: int = encoded / c_iPanelPointerStride
    return encoded - x * c_iPanelPointerStride
  end

  function HandlePanelPointer(message: int) -> void
    local base: int = c_iPanelPointerMoveBase
    local action: int = 0
    if message >= c_iPanelPointerLeaveBase then
      ClearPanelTooltip()
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

    local x: int = GetPanelPointerX(message, base)
    local y: int = GetPanelPointerY(message, base)
    if action == 0 then UpdatePanelTooltip(x, y) end
    if action == 1 then
      ClearPanelTooltip()
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
    if dragSource >= 0 then ApplyPointerTarget(target) end
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

  function OnUIMessage(message: int, sender: string, data: object) -> void
    if message == -100 && sender == "corpse_marker" then
      ActivateCorpseMode()
      return
    end
    if sender == "panel_background" && message >= c_iPanelPointerMoveBase then
      HandlePanelPointer(message)
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
      if dragSource >= 0 then ApplyPointerTarget(GetSlotTargetFromPointerMessage(message, c_iHoverMessageBase, sender)) end
      return
    end
    if message == 2 || message == 3 then
      StartDragAction(GetTargetBySender(sender), sender)
      return
    end
    if message == 7 then
      if dragSource >= 0 then ApplyPointerTarget(-1) end
      return
    end
    if message == 8 then
      FinishDrag(highlightedTarget)
      return
    end
    if message == 1 && !data then
      QuickTransfer(GetTargetBySender(sender))
    end
  end

  function OnUpdate(delta: float) -> void
    UpdateLayout()
    UpdateMoney()
    if organVisibilityRefresh > 0 then
      organVisibilityRefresh = organVisibilityRefresh - delta
      UpdateOrganSlots()
    end
    if corpseVisualPending then
      native.SendMessage(-100, "loot_doll")
      corpseVisualPending = false
    end
    if deferredInventoryRefresh > 0 then
      deferredInventoryRefresh = deferredInventoryRefresh - delta
      if deferredInventoryRefresh <= 0 then
        UpdatePlayerSlots()
        native.Trace("utopian_container deferred inventory refresh")
      end
    end
  end

  function OnMouseMove(x: int, y: int) -> void
    if dragSource >= 0 then ApplyPointerTarget(FindTargetAt(x, y)) end
  end

  function OnMouseLeave() -> void
    if dragSource >= 0 then SetHighlightedTarget(-1) end
  end

  function OnLButtonUp(x: int, y: int) -> void
    if dragSource >= 0 then
      local target: int = FindTargetAt(x, y)
      ApplyPointerTarget(target)
      FinishDrag(target)
    end
  end

  function OnMouseWheel(x: int, y: int, delta: float) -> void
    if x < GetGridStartX() then
      if delta > 0 then ChangeContainerPage(-1) else ChangeContainerPage(1) end
    else
      if delta > 0 then ChangePlayerPage(-1) else ChangePlayerPage(1) end
    end
  end

  function OnChar(char: int) -> void
    native.DestroyWindow()
  end

  function OnKeyDown(key: int) -> void
    if key == 27 || key == 73 || key == 105 then native.DestroyWindow() end
  end
end
