maintask UtopianInventoryUI do
  local const c_iCWeapon: int = 0
  local const c_iCClothes: int = 1
  local const c_iCategoryCount: int = 5
  local const c_iInventoryCapacity: int = 56
  local const c_iLayoutVersion: int = 4
  local const c_iVKShift: int = 16
  local const c_iVKControl: int = 17
  local const c_iWMHelpMessage: int = 200
  local const c_iInventoryFullTextID: int = 1400
  local const c_iSlotSelected: int = 16384
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
  local const c_iTargetWeapon: int = 100
  local const c_iTargetClothesBase: int = 100
  local const c_iTargetDrop: int = 200
  local const c_iTargetMoney: int = 300

  local windowWidth: int
  local windowHeight: int
  local visibleSlots: int
  local page: int
  local resolvedCategory: int
  local resolvedIndex: int
  local slotOrder: object
  local dragSourceSlot: int
  local hoverSlot: int
  local highlightedSlot: int
  local dragMoved: bool
  local dragDebugLastTargetSlot: int
  local lastPointerSlot: int
  local dragDebugLastPointerSlot: int
  local lastValidDropTarget: int
  local invalidDropTargetFrames: int
  local dragDebugLastAppliedTarget: int
  local dragItemID: int
  local dragItemCategory: int
  local dragItemIndex: int
  local dragItemGroup: int
  local dragItemIsWeapon: bool
  local lastLayoutWidth: int
  local lastLayoutHeight: int
  local lastLayoutSlots: int
  local panelTooltipTarget: int
  local moneyTooltipItem: object
  local backpackSnapshot: object
  local currentBackpackSnapshot: object
  local backpackCategoryCache: object
  local backpackIndexCache: object
  local oldToNewOrder: object
  local claimedNewOrder: object
  local usedLayoutCell: object
  local lastBackpackItemCount: int
  local deferredInventoryRefresh: float
  local inventoryFullMessageCooldown: float
  local shiftHeld: bool
  local controlHeld: bool
  local inventoryPollCooldown: float

  function init() -> void
    native.Trace("utopian_inventory script init diagnostics=18 clara-money-tooltip")
    page = 0
    resolvedCategory = -1
    resolvedIndex = -1
    dragSourceSlot = -1
    hoverSlot = -1
    highlightedSlot = -1
    dragMoved = false
    dragDebugLastTargetSlot = -999
    lastPointerSlot = -1
    dragDebugLastPointerSlot = -999
    lastValidDropTarget = -1
    invalidDropTargetFrames = 0
    dragDebugLastAppliedTarget = -999
    dragItemID = -1
    dragItemCategory = -1
    dragItemIndex = -1
    dragItemGroup = -1
    dragItemIsWeapon = false
    lastLayoutWidth = -1
    lastLayoutHeight = -1
    lastLayoutSlots = -1
    panelTooltipTarget = -999
    deferredInventoryRefresh = 0
    inventoryFullMessageCooldown = 0
    shiftHeld = false
    controlHeld = false
    inventoryPollCooldown = 0.1
    native.CreateInvItem(moneyTooltipItem)
    moneyTooltipItem->SetItemName("Money")
    native.CreateIntVector(backpackSnapshot)
    native.CreateIntVector(currentBackpackSnapshot)
    native.CreateIntVector(backpackCategoryCache)
    native.CreateIntVector(backpackIndexCache)
    native.CreateIntVector(oldToNewOrder)
    native.CreateIntVector(claimedNewOrder)
    native.CreateIntVector(usedLayoutCell)
    for i = 0, c_iInventoryCapacity - 1 do
      backpackSnapshot->add(-1)
      currentBackpackSnapshot->add(-1)
      backpackCategoryCache->add(-1)
      backpackIndexCache->add(-1)
      oldToNewOrder->add(-1)
      claimedNewOrder->add(0)
      usedLayoutCell->add(0)
    end
    lastBackpackItemCount = 0
    InitSlotOrder()
    UpdateLayout()
    LoadLayoutVariables()
    OrderFreeCellsByDisplay()
    UpdateSlots()
    SnapshotBackpackItems()
    UpdateMoney()
    native.SetCursor("default")
    native.ShowCursor()
    native.CaptureKeyboard()
    native.SetOwnerDraw(false)
    native.SetNeedUpdate(true)
    native.Trace("utopian_inventory before ProcessEvents")
    native.ProcessEvents()
  end

  function InitSlotOrder() -> void
    native.CreateIntVector(slotOrder)
    for i = 0, c_iInventoryCapacity - 1 do
      slotOrder->add(GetDefaultOrderForCell(i))
    end
  end

  function GetDefaultOrderForCell(cell: int) -> int
    if cell < 16 then return cell + 40 end
    return cell - 16
  end

  function GetBranch() -> int
    local branch: int = -1
    native.GetVariable("branch", branch)
    return branch
  end

  function GetOrderValue(slot: int) -> int
    local order: int = slot
    if slot >= 0 && slot < c_iInventoryCapacity then
      slotOrder->get(order, slot)
    end
    return order
  end

  function SetOrderValue(slot: int, value: int) -> void
    if slot >= 0 && slot < c_iInventoryCapacity then
      slotOrder->set(slot, value)
    end
  end

  function GetCellVariableName(slot: int) -> string
    return "utopian_inventory_cell_" + slot
  end

  function LoadLayoutVariables() -> void
    local initialized: int = 0
    local layoutVersion: int = 0
    native.GetVariable("utopian_inventory_layout_initialized", initialized)
    native.GetVariable("utopian_inventory_layout_version", layoutVersion)
    if initialized != 1 then
      SaveLayoutVariables()
      return
    end

    local storedSlots: int = c_iInventoryCapacity
    if layoutVersion == 3 then storedSlots = 40 end
    if layoutVersion != 3 && layoutVersion != c_iLayoutVersion then
      SaveLayoutVariables()
      return
    end

    if layoutVersion == 3 then
      for i = 0, 15 do SetOrderValue(i, i + 40) end
      for i = 0, 39 do
        local order: int = i
        native.GetVariable(GetCellVariableName(i), order)
        if order < 0 || order >= 40 then order = i end
        SetOrderValue(i + 16, order)
      end
    else
      for i = 0, storedSlots - 1 do
        local order: int = GetDefaultOrderForCell(i)
        native.GetVariable(GetCellVariableName(i), order)
        if order < 0 || order >= storedSlots then order = GetDefaultOrderForCell(i) end
        SetOrderValue(i, order)
      end
    end
    NormalizeSlotOrder()
    SaveLayoutVariables()
    native.Trace("utopian_inventory layout loaded from variables")
  end

  function SaveLayoutVariables() -> void
    for i = 0, c_iInventoryCapacity - 1 do
      native.SetVariable(GetCellVariableName(i), GetOrderValue(i))
    end
    native.SetVariable("utopian_inventory_layout_initialized", 1)
    native.SetVariable("utopian_inventory_layout_version", c_iLayoutVersion)
    native.Trace("utopian_inventory layout stored in variables")
  end

  function IsOrderUsedBefore(slot: int, order: int) -> bool
    for i = 0, slot - 1 do
      if GetOrderValue(i) == order then
        return true
      end
    end
    return false
  end

  function IsOrderUsedAtOrBefore(slot: int, order: int) -> bool
    for i = 0, slot do
      if GetOrderValue(i) == order then
        return true
      end
    end
    return false
  end

  function FindFirstUnusedOrder(slot: int) -> int
    for candidate = 0, c_iInventoryCapacity - 1 do
      if !IsOrderUsedAtOrBefore(slot, candidate) then
        return candidate
      end
    end
    return slot
  end

  function NormalizeSlotOrder() -> void
    for slot = 0, c_iInventoryCapacity - 1 do
      local order: int = GetOrderValue(slot)
      if order < 0 || order >= c_iInventoryCapacity || IsOrderUsedBefore(slot, order) then
        SetOrderValue(slot, FindFirstUnusedOrder(slot))
      end
    end
  end

  function OrderFreeCellsByDisplay() -> void
    local itemCount: int = GetBackpackItemCount()
    if itemCount > c_iInventoryCapacity then return end
    local nextFreeOrder: int = itemCount
    for linear = 0, c_iInventoryCapacity - 1 do
      local cell: int = GetCellForLinearSlot(linear)
      if cell >= 0 && GetOrderValue(cell) >= itemCount then
        SetOrderValue(cell, nextFreeOrder)
        nextFreeOrder = nextFreeOrder + 1
      end
    end
    SaveLayoutVariables()
  end

  function GetPlayerContainer() -> object
    local container: object
    native.GetPlayerContainer(container)
    return container
  end

  function BeginDragCursor(slot: int) -> void
    native.SetVariable("utopian_inventory_drag_item", -1)
    dragItemID = -1
    dragItemCategory = -1
    dragItemIndex = -1
    dragItemGroup = -1
    dragItemIsWeapon = false
    if !ResolveDragSource(slot) then
      return
    end

    local container: object = GetPlayerContainer()
    local item: object
    container->GetItem(item, resolvedIndex, resolvedCategory)
    if !item then
      return
    end

    local itemID: int
    item->GetItemID(itemID)
    dragItemID = itemID
    dragItemCategory = resolvedCategory
    dragItemIndex = resolvedIndex
    if dragItemCategory == c_iCWeapon then
      native.HasInvItemProperty(dragItemIsWeapon, dragItemID, "Weapon")
    end
    if dragItemCategory == c_iCClothes then
      local hasGroup: bool
      native.HasInvItemProperty(hasGroup, dragItemID, "Group")
      if hasGroup then
        native.GetInvItemProperty(dragItemGroup, dragItemID, "Group")
      end
    end
    native.SetVariable("utopian_inventory_drag_item", itemID)
    native.SetCursor("drag_item")
    native.Trace("utopian_inventory diagnostic drag-start slot=" + slot + " item=" + dragItemID +
      " category=" + dragItemCategory + " index=" + dragItemIndex + " group=" + dragItemGroup +
      " weapon=" + dragItemIsWeapon)
  end

  function EndDragCursor() -> void
    native.SetVariable("utopian_inventory_drag_item", -1)
    native.SetCursor("default")
    dragItemID = -1
    dragItemCategory = -1
    dragItemIndex = -1
    dragItemGroup = -1
    dragItemIsWeapon = false
  end

  function UpdateLayout() -> void
    native.GetWindowSize(windowWidth, windowHeight)
    if windowWidth <= 0 || windowHeight <= 0 then
      native.GetScreenSize(windowWidth, windowHeight)
    end
    if windowWidth >= 1200 then
      visibleSlots = c_iInventoryCapacity
    else
      if windowWidth >= 1000 then
        visibleSlots = 35
      else
        visibleSlots = 24
      end
    end
    if windowWidth != lastLayoutWidth || windowHeight != lastLayoutHeight || visibleSlots != lastLayoutSlots then
      native.Trace("utopian_inventory layout window=" + windowWidth + "x" + windowHeight + " slots=" + visibleSlots)
      native.SendMessage(windowWidth, "character_doll")
      native.SendMessage(5000 + windowHeight, "character_doll")
      native.SendMessage(windowWidth, "panel_background")
      native.SendMessage(5000 + windowHeight, "panel_background")
      lastLayoutWidth = windowWidth
      lastLayoutHeight = windowHeight
      lastLayoutSlots = visibleSlots
    end
  end

  function GetSlotWndName(slot: int) -> string
    local number: int = slot + 1
    if number < 10 then
      return "slot0" + number
    end
    return "slot" + number
  end

  function GetVisibleCell(slot: int) -> int
    local linear: int = page * visibleSlots + slot
    return GetCellForLinearSlot(linear)
  end

  function GetCellForLinearSlot(linear: int) -> int
    if linear < 0 || linear >= c_iInventoryCapacity then return -1 end
    if visibleSlots < c_iInventoryCapacity then return (linear + 16) - ((linear + 16) / c_iInventoryCapacity) * c_iInventoryCapacity end
    return linear
  end

  function GetGridStartX() -> int
    if windowWidth >= 1900 then
      return 920
    end
    if windowWidth >= 1200 then
      return 600
    end
    if windowWidth >= 1000 then
      return 468
    end
    return 359
  end

  function GetRootLeft() -> int
    return 0
  end

  function GetRootTop() -> int
    return 0
  end

  function GetGridStartY() -> int
    if windowWidth >= 1900 then
      return 242
    end
    if windowWidth >= 1200 then
      return 182
    end
    if windowWidth >= 1000 then
      return 266
    end
    return 225
  end

  function GetGridStep() -> int
    if windowWidth >= 1200 then
      return 64
    end
    if windowWidth >= 1000 then
      return 61
    end
    return 58
  end

  function GetGridColumns() -> int
    if windowWidth >= 1200 then
      return 8
    end
    if windowWidth >= 1000 then
      return 7
    end
    return 6
  end

  function GetSlotLeft(slot: int) -> int
    local columns: int = GetGridColumns()
    local column: int = slot - (slot / columns) * columns
    return GetGridStartX() + column * GetGridStep()
  end

  function GetSlotTop(slot: int) -> int
    local columns: int = GetGridColumns()
    return GetGridStartY() + (slot / columns) * GetGridStep()
  end

  function GetTargetWndName(target: int) -> string
    if target >= 0 && target < visibleSlots then
      return GetSlotWndName(target)
    end
    if target == c_iTargetWeapon then
      return "equip_weapon"
    end
    if target == c_iTargetClothesBase + 1 then
      return "equip_feet"
    end
    if target == c_iTargetClothesBase + 2 then
      return "equip_head"
    end
    if target == c_iTargetClothesBase + 3 then
      return "equip_body"
    end
    if target == c_iTargetClothesBase + 4 then
      return "equip_hands"
    end
    if target == c_iTargetDrop then
      return "drop_slot"
    end
    return ""
  end

  function GetTargetDebugName(target: int) -> string
    if target >= 0 && target < visibleSlots then
      return "BACKPACK_" + target
    end
    if target == c_iTargetWeapon then return "WEAPON" end
    if target == c_iTargetClothesBase + 1 then return "FEET" end
    if target == c_iTargetClothesBase + 2 then return "HEAD" end
    if target == c_iTargetClothesBase + 3 then return "BODY" end
    if target == c_iTargetClothesBase + 4 then return "HANDS" end
    if target == c_iTargetDrop then return "DROP" end
    return "OUTSIDE"
  end

  function TraceDragTarget(target: int) -> void
    if target == dragDebugLastAppliedTarget then
      return
    end
    dragDebugLastAppliedTarget = target

    if dragSourceSlot < 0 || dragItemID < 0 then
      native.Trace("utopian_inventory diagnostic target=" + GetTargetDebugName(target) + " cache=empty")
      return
    end
    local compatible: bool = false

    if target >= 0 && target < visibleSlots then
      compatible = true
    else
      if target == c_iTargetDrop then
        compatible = true
      else
        if target == c_iTargetWeapon && dragItemCategory == c_iCWeapon then
          compatible = dragItemIsWeapon
        else
          if target > c_iTargetClothesBase && target <= c_iTargetClothesBase + 4 && dragItemCategory == c_iCClothes then
            compatible = target == c_iTargetClothesBase + dragItemGroup
          end
        end
      end
    end

    native.Trace("utopian_inventory diagnostic target=" + GetTargetDebugName(target) +
      " item=" + dragItemID + " category=" + dragItemCategory + " group=" + dragItemGroup +
      " compatible=" + compatible)
  end

  function GetSpecialTargetLeft(target: int) -> int
    if windowWidth >= 1900 then
      if target == c_iTargetWeapon then return 715 end
      if target == c_iTargetClothesBase + 1 then return 590 end
      if target == c_iTargetClothesBase + 2 then return 590 end
      if target == c_iTargetClothesBase + 3 then return 590 end
      if target == c_iTargetClothesBase + 4 then return 445 end
      if target == c_iTargetDrop then return 1126 end
    else
    if windowWidth >= 1200 then
      if target == c_iTargetWeapon then return 395 end
      if target == c_iTargetClothesBase + 1 then return 270 end
      if target == c_iTargetClothesBase + 2 then return 270 end
      if target == c_iTargetClothesBase + 3 then return 270 end
      if target == c_iTargetClothesBase + 4 then return 125 end
      if target == c_iTargetDrop then return 806 end
    else
      if windowWidth >= 1000 then
        if target == c_iTargetWeapon then return 315 end
        if target == c_iTargetClothesBase + 1 then return 207 end
        if target == c_iTargetClothesBase + 2 then return 207 end
        if target == c_iTargetClothesBase + 3 then return 207 end
        if target == c_iTargetClothesBase + 4 then return 86 end
        if target == c_iTargetDrop then return 650 end
      else
        if target == c_iTargetWeapon then return 234 end
        if target == c_iTargetClothesBase + 1 then return 156 end
        if target == c_iTargetClothesBase + 2 then return 156 end
        if target == c_iTargetClothesBase + 3 then return 156 end
        if target == c_iTargetClothesBase + 4 then return 68 end
        if target == c_iTargetDrop then return 501 end
      end
    end
    end
    return -1000
  end

  function GetSpecialTargetTop(target: int) -> int
    if windowWidth >= 1900 then
      if target == c_iTargetWeapon then return 610 end
      if target == c_iTargetClothesBase + 1 then return 800 end
      if target == c_iTargetClothesBase + 2 then return 300 end
      if target == c_iTargetClothesBase + 3 then return 488 end
      if target == c_iTargetClothesBase + 4 then return 560 end
      if target == c_iTargetDrop then return 745 end
    else
    if windowWidth >= 1200 then
      if target == c_iTargetWeapon then return 550 end
      if target == c_iTargetClothesBase + 1 then return 740 end
      if target == c_iTargetClothesBase + 2 then return 240 end
      if target == c_iTargetClothesBase + 3 then return 428 end
      if target == c_iTargetClothesBase + 4 then return 500 end
      if target == c_iTargetDrop then return 685 end
    else
      if windowWidth >= 1000 then
        if target == c_iTargetWeapon then return 438 end
        if target == c_iTargetClothesBase + 1 then return 569 end
        if target == c_iTargetClothesBase + 2 then return 188 end
        if target == c_iTargetClothesBase + 3 then return 346 end
        if target == c_iTargetClothesBase + 4 then return 399 end
        if target == c_iTargetDrop then return 580 end
      else
        if target == c_iTargetWeapon then return 337 end
        if target == c_iTargetClothesBase + 1 then return 429 end
        if target == c_iTargetClothesBase + 2 then return 159 end
        if target == c_iTargetClothesBase + 3 then return 271 end
        if target == c_iTargetClothesBase + 4 then return 311 end
        if target == c_iTargetDrop then return 455 end
      end
    end
    end
    return -1000
  end

  function IsInsideSpecialTarget(target: int, x: int, y: int) -> bool
    local left: int = GetSpecialTargetLeft(target)
    local top: int = GetSpecialTargetTop(target)
    return x >= left && y >= top && x < left + c_iSlotHotZone && y < top + c_iSlotHotZone
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

  function IsInsideMoney(x: int, y: int) -> bool
    local left: int = GetMoneyLeft()
    local top: int = GetMoneyTop()
    return x >= left && y >= top && x < left + c_iSlotHotZone && y < top + c_iSlotHotZone
  end

  function FindSpecialTargetAt(x: int, y: int) -> int
    if dragItemCategory == c_iCWeapon && dragItemIsWeapon then
      if IsInsideSpecialTarget(c_iTargetWeapon, x, y) then
        return c_iTargetWeapon
      end
    end

    if dragItemCategory == c_iCClothes && dragItemGroup >= 1 && dragItemGroup <= 4 then
      local clothesTarget: int = c_iTargetClothesBase + dragItemGroup
      if IsInsideSpecialTarget(clothesTarget, x, y) then
        return clothesTarget
      end
    end

    if IsInsideSpecialTarget(c_iTargetDrop, x, y) then
      return c_iTargetDrop
    end
    return -1
  end

  function FindEquipmentTargetAt(x: int, y: int) -> int
    if IsInsideSpecialTarget(c_iTargetWeapon, x, y) then return c_iTargetWeapon end
    for group = 1, 4 do
      local target: int = c_iTargetClothesBase + group
      if IsInsideSpecialTarget(target, x, y) then return target end
    end
    return -1
  end

  function IsEquippedItem(category: int, index: int) -> bool
    if category != c_iCWeapon && category != c_iCClothes then
      return false
    end

    local container: object = GetPlayerContainer()
    local selected: bool
    container->IsItemSelected(selected, index, category)
    if !selected then
      return false
    end

    local item: object
    container->GetItem(item, index, category)
    local itemID: int
    item->GetItemID(itemID)

    if category == c_iCWeapon then
      local hasWeapon: bool
      native.HasInvItemProperty(hasWeapon, itemID, "Weapon")
      return hasWeapon
    end

    local hasGroup: bool
    native.HasInvItemProperty(hasGroup, itemID, "Group")
    return hasGroup
  end

  function GetBackpackItemCount() -> int
    local container: object = GetPlayerContainer()
    local total: int = 0

    for category = 0, c_iCategoryCount - 1 do
      local count: int
      container->GetItemCount(count, category)
      for index = 0, count - 1 do
        if !IsEquippedItem(category, index) then
          total = total + 1
        end
      end
    end

    return total
  end

  function CaptureBackpackItems(snapshot: object) -> int
    local container: object = GetPlayerContainer()
    local ordinal: int = 0
    for i = 0, c_iInventoryCapacity - 1 do snapshot->set(i, -1) end
    for category = 0, c_iCategoryCount - 1 do
      local count: int
      container->GetItemCount(count, category)
      for index = 0, count - 1 do
        if !IsEquippedItem(category, index) then
          if ordinal < c_iInventoryCapacity then
            local item: object
            local itemID: int
            container->GetItem(item, index, category)
            if item then
              item->GetItemID(itemID)
              snapshot->set(ordinal, itemID)
            end
          end
          ordinal = ordinal + 1
        end
      end
    end
    return ordinal
  end

  function SnapshotBackpackItems() -> void
    lastBackpackItemCount = CaptureBackpackItems(backpackSnapshot)
  end

  function FindFirstUnusedDisplayCell() -> int
    for linear = 0, c_iInventoryCapacity - 1 do
      local cell: int = GetCellForLinearSlot(linear)
      local used: int = 0
      usedLayoutCell->get(used, cell)
      if used == 0 then return cell end
    end
    return -1
  end

  function ReconcileExternalAdditions(newCount: int) -> void
    local oldCount: int = lastBackpackItemCount
    if newCount <= oldCount || newCount > c_iInventoryCapacity then return end

    for i = 0, c_iInventoryCapacity - 1 do
      oldToNewOrder->set(i, -1)
      claimedNewOrder->set(i, 0)
      usedLayoutCell->set(i, 0)
    end

    local oldOrdinal: int = 0
    local newOrdinal: int = 0
    while newOrdinal < newCount do
      local currentID: int
      currentBackpackSnapshot->get(currentID, newOrdinal)
      local previousID: int = -1
      if oldOrdinal < oldCount then backpackSnapshot->get(previousID, oldOrdinal) end
      if oldOrdinal < oldCount && currentID == previousID then
        oldToNewOrder->set(oldOrdinal, newOrdinal)
        claimedNewOrder->set(newOrdinal, 1)
        oldOrdinal = oldOrdinal + 1
      end
      newOrdinal = newOrdinal + 1
    end

    for old = 0, oldCount - 1 do
      local mapped: int = -1
      oldToNewOrder->get(mapped, old)
      if mapped < 0 then
        local wantedID: int
        backpackSnapshot->get(wantedID, old)
        for current = 0, newCount - 1 do
          local claimed: int
          local currentID: int
          claimedNewOrder->get(claimed, current)
          currentBackpackSnapshot->get(currentID, current)
          if claimed == 0 && currentID == wantedID then
            oldToNewOrder->set(old, current)
            claimedNewOrder->set(current, 1)
            current = newCount
          end
        end
      end
    end

    for cell = 0, c_iInventoryCapacity - 1 do
      local oldOrder: int = GetOrderValue(cell)
      if oldOrder >= 0 && oldOrder < oldCount then
        local mappedOrder: int
        oldToNewOrder->get(mappedOrder, oldOrder)
        if mappedOrder >= 0 then
          SetOrderValue(cell, mappedOrder)
          usedLayoutCell->set(cell, 1)
        end
      end
    end

    for insertedOrder = 0, newCount - 1 do
      local claimed: int
      claimedNewOrder->get(claimed, insertedOrder)
      if claimed == 0 then
        local freeCell: int = FindFirstUnusedDisplayCell()
        if freeCell >= 0 then
          SetOrderValue(freeCell, insertedOrder)
          usedLayoutCell->set(freeCell, 1)
        end
      end
    end

    local freeOrder: int = newCount
    for linear = 0, c_iInventoryCapacity - 1 do
      local freeCell: int = GetCellForLinearSlot(linear)
      local used: int
      usedLayoutCell->get(used, freeCell)
      if used == 0 then
        SetOrderValue(freeCell, freeOrder)
        freeOrder = freeOrder + 1
      end
    end
    NormalizeSlotOrder()
    SaveLayoutVariables()
    native.Trace("utopian_inventory reconciled external add old=" + oldCount + " new=" + newCount)
  end

  function ShowInventoryFull() -> void
    if inventoryFullMessageCooldown > 0 then return end
    local text: object
    native.CreateIntVector(text)
    text->add(c_iInventoryFullTextID)
    native.SendWorldWndMessage(c_iWMHelpMessage, text)
    inventoryFullMessageCooldown = 1.0
  end

  function GetMaxPage() -> int
    if visibleSlots <= 0 then return 0 end
    return (c_iInventoryCapacity - 1) / visibleSlots
  end

  function ClampPage() -> void
    local maxPage: int = GetMaxPage()

    if page < 0 then
      page = 0
    end
    if page > maxPage then
      page = maxPage
    end
  end

  function UpdatePageControls() -> void
    if visibleSlots >= c_iInventoryCapacity then return end
    local maxPage: int = GetMaxPage()
    local visibilityMessage: int = -93
    if maxPage > 0 then visibilityMessage = -92 end
    native.SendMessage(visibilityMessage, "page_prev")
    native.SendMessage(visibilityMessage, "page_counter")
    native.SendMessage(visibilityMessage, "page_next")
    if maxPage <= 0 then return end
    native.SendMessage(-90, "page_prev")
    native.SendMessage(-91, "page_next")
    if page > 0 then native.SendMessage(-97, "page_prev") else native.SendMessage(-96, "page_prev") end
    if page < maxPage then native.SendMessage(-97, "page_next") else native.SendMessage(-96, "page_next") end
    native.SendMessage((page + 1) * 100 + maxPage + 1, "page_counter")
  end

  function ResolveVisibleSlot(slot: int) -> bool
    resolvedCategory = -1
    resolvedIndex = -1

    local target: int = GetOrderValue(GetVisibleCell(slot))
    if target < 0 || target >= c_iInventoryCapacity then return false end
    backpackCategoryCache->get(resolvedCategory, target)
    backpackIndexCache->get(resolvedIndex, target)
    return resolvedCategory >= 0 && resolvedIndex >= 0
  end

  function BuildBackpackIndexCache() -> void
    for ordinal = 0, c_iInventoryCapacity - 1 do
      backpackCategoryCache->set(ordinal, -1)
      backpackIndexCache->set(ordinal, -1)
    end
    local container: object = GetPlayerContainer()
    local ordinal: int = 0
    for category = 0, c_iCategoryCount - 1 do
      local count: int
      container->GetItemCount(count, category)
      for index = 0, count - 1 do
        if !IsEquippedItem(category, index) then
          if ordinal < c_iInventoryCapacity then
            backpackCategoryCache->set(ordinal, category)
            backpackIndexCache->set(ordinal, index)
          end
          ordinal = ordinal + 1
        end
      end
    end
  end

  function UpdateMoney() -> void
    local container: object = GetPlayerContainer()
    local money: int
    container->GetProperty("money", money)
    native.SendMessage(money, "money")
  end
  function UpdateSlots() -> void
    UpdateLayout()
    ClampPage()
    BuildBackpackIndexCache()

    local container: object = GetPlayerContainer()
    for slot = 0, visibleSlots - 1 do
      local wndName: string = GetSlotWndName(slot)
      if GetVisibleCell(slot) < 0 then
        native.SendMessage(c_iSlotEmpty, wndName)
        native.SendMessage(-22, wndName)
      else
        native.SendMessage(-23, wndName)
        if ResolveVisibleSlot(slot) then
          local item: object
          local amount: int
          container->GetItem(item, resolvedIndex, resolvedCategory)
          container->GetItemAmount(amount, resolvedIndex, resolvedCategory)
          native.SendMessage(0, wndName, item)
          native.SendMessage(amount + c_iSlotNumber, wndName)
        else
          native.SendMessage(c_iSlotEmpty, wndName)
        end
      end
    end
    UpdateEquipmentSlots()
    UpdatePageControls()
    SnapshotBackpackItems()
  end

  function UpdateEquipmentSlot(target: int) -> void
    local wndName: string = GetTargetWndName(target)
    if ResolveEquipmentTarget(target) then
      local container: object = GetPlayerContainer()
      local item: object
      container->GetItem(item, resolvedIndex, resolvedCategory)
      native.SendMessage(0, wndName, item)
    else
      native.SendMessage(c_iSlotEmpty, wndName)
    end
    native.SendMessage(-30 - (target - c_iTargetWeapon), wndName)
  end

  function UpdateEquipmentSlots() -> void
    for target = c_iTargetWeapon, c_iTargetClothesBase + 4 do
      UpdateEquipmentSlot(target)
    end
  end

  function ResolveEquipmentTarget(target: int) -> bool
    resolvedCategory = -1
    resolvedIndex = -1
    local container: object = GetPlayerContainer()

    if target == c_iTargetWeapon then
      local weaponCount: int
      container->GetItemCount(weaponCount, c_iCWeapon)
      for index = 0, weaponCount - 1 do
        local selected: bool
        container->IsItemSelected(selected, index, c_iCWeapon)
        if selected then
          local item: object
          container->GetItem(item, index, c_iCWeapon)
          local itemID: int
          item->GetItemID(itemID)
          local hasWeapon: bool
          native.HasInvItemProperty(hasWeapon, itemID, "Weapon")
          if hasWeapon then
            resolvedCategory = c_iCWeapon
            resolvedIndex = index
            return true
          end
        end
      end
      return false
    end

    if target <= c_iTargetClothesBase || target > c_iTargetClothesBase + 4 then
      return false
    end

    local requiredGroup: int = target - c_iTargetClothesBase
    local clothesCount: int
    container->GetItemCount(clothesCount, c_iCClothes)
    for index = 0, clothesCount - 1 do
      local selected: bool
      container->IsItemSelected(selected, index, c_iCClothes)
      if selected then
        local item: object
        container->GetItem(item, index, c_iCClothes)
        local itemID: int
        item->GetItemID(itemID)
        local hasGroup: bool
        native.HasInvItemProperty(hasGroup, itemID, "Group")
        if hasGroup then
          local group: int
          native.GetInvItemProperty(group, itemID, "Group")
          if group == requiredGroup then
            resolvedCategory = c_iCClothes
            resolvedIndex = index
            return true
          end
        end
      end
    end
    return false
  end

  function ResolveDragSource(source: int) -> bool
    if source >= 0 && source < visibleSlots then
      return ResolveVisibleSlot(source)
    end
    return ResolveEquipmentTarget(source)
  end

  function UnequipItem(category: int, index: int) -> bool
    if category != c_iCWeapon && category != c_iCClothes then return false end
    local container: object = GetPlayerContainer()
    local selected: bool
    container->IsItemSelected(selected, index, category)
    if !selected then return false end
    container->SelectItem(index, false, category)
    if category == c_iCWeapon then
      native.SetPlayerHandsItem(-1)
    end
    return true
  end

  function EquipDraggedItem(target: int, category: int, index: int) -> bool
    local container: object = GetPlayerContainer()
    local item: object
    container->GetItem(item, index, category)
    if !item then return false end

    local itemID: int
    item->GetItemID(itemID)
    if target == c_iTargetWeapon then
      if category != c_iCWeapon then return false end
      local hasWeapon: bool
      native.HasInvItemProperty(hasWeapon, itemID, "Weapon")
      if !hasWeapon then return false end

      native.SetPlayerHandsItem(itemID)
      local count: int
      container->GetItemCount(count, c_iCWeapon)
      for i = 0, count - 1 do container->SelectItem(i, false, c_iCWeapon) end
      container->SelectItem(index, true, c_iCWeapon)
      return true
    end

    if target <= c_iTargetClothesBase || target > c_iTargetClothesBase + 4 then return false end
    if category != c_iCClothes then return false end
    local hasGroup: bool
    native.HasInvItemProperty(hasGroup, itemID, "Group")
    if !hasGroup then return false end
    local group: int
    native.GetInvItemProperty(group, itemID, "Group")
    if target != c_iTargetClothesBase + group then return false end

    local count: int
    container->GetItemCount(count, c_iCClothes)
    for i = 0, count - 1 do
      local other: object
      container->GetItem(other, i, c_iCClothes)
      local otherID: int
      other->GetItemID(otherID)
      local otherHasGroup: bool
      native.HasInvItemProperty(otherHasGroup, otherID, "Group")
      if otherHasGroup then
        local otherGroup: int
        native.GetInvItemProperty(otherGroup, otherID, "Group")
        if otherGroup == group then container->SelectItem(i, false, c_iCClothes) end
      end
    end
    container->SelectItem(index, true, c_iCClothes)
    return true
  end

  function ToggleSlot(category: int, index: int) -> void
    local container: object = GetPlayerContainer()
    local item: object
    container->GetItem(item, index, category)

    local itemID: int
    item->GetItemID(itemID)

    local amount: int
    container->GetItemAmount(amount, index, category)

    local selected: bool
    container->IsItemSelected(selected, index, category)

    if category == c_iCWeapon then
      local hasWeapon: bool
      native.HasInvItemProperty(hasWeapon, itemID, "Weapon")
      if !hasWeapon then
        return
      end

      if selected then
        container->SelectItem(index, false, category)
        native.SetPlayerHandsItem(-1)
      else
        native.SetPlayerHandsItem(itemID)
        local count: int
        container->GetItemCount(count, category)
        for i = 0, count - 1 do
          container->SelectItem(i, false, category)
        end
        container->SelectItem(index, true, category)
      end
      return
    end

    if category == c_iCClothes then
      local hasGroup: bool
      native.HasInvItemProperty(hasGroup, itemID, "Group")
      if !hasGroup then
        return
      end

      local group: int
      native.GetInvItemProperty(group, itemID, "Group")
      if selected then
        container->SelectItem(index, false, category)
      else
        local count: int
        container->GetItemCount(count, category)
        for i = 0, count - 1 do
          local otherSelected: bool
          container->IsItemSelected(otherSelected, i, category)
          if otherSelected then
            local other: object
            container->GetItem(other, i, category)
            local otherID: int
            other->GetItemID(otherID)
            local otherHasGroup: bool
            native.HasInvItemProperty(otherHasGroup, otherID, "Group")
            if otherHasGroup then
              local otherGroup: int
              native.GetInvItemProperty(otherGroup, otherID, "Group")
              if otherGroup == group then
                container->SelectItem(i, false, category)
              end
            end
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
      if amount == 0 then
        container->RemoveItem(index, 1, category)
      else
        container->SetItemAmount(amount, index, category)
      end
    end
  end

  function DropSlot(category: int, index: int, requestedAmount: int) -> bool
    local container: object
    native.GetContainer(container)
    if !container then
      native.Trace("utopian_inventory drop failed: world container unavailable")
      return false
    end

    local playerContainer: object = GetPlayerContainer()
    local item: object
    playerContainer->GetItem(item, index, category)
    if !item then return false end
    local availableAmount: int
    playerContainer->GetItemAmount(availableAmount, index, category)
    local amount: int = requestedAmount
    if amount <= 0 || amount > availableAmount then amount = availableAmount end
    if amount <= 0 then return false end

    local success: bool
    container->AddItem(success, item, 0, amount)
    if !success then
      native.Trace("utopian_inventory drop failed: AddItem rejected category=" + category + " index=" + index)
      return false
    end

    if category == c_iCWeapon then
      local selected: bool
      playerContainer->IsItemSelected(selected, index, category)
      if selected then
        native.SetPlayerHandsItem(-1)
      end
    end

    playerContainer->RemoveItem(index, amount, category)
    native.Trace("utopian_inventory drop success category=" + category + " index=" + index + " amount=" + amount)
    return true
  end

  function HandleModifiedDrop(sourceSlot: int) -> bool
    if !shiftHeld && !controlHeld then return false end
    if sourceSlot < 0 || sourceSlot >= visibleSlots then return false end
    if !ResolveVisibleSlot(sourceSlot) then return true end

    local category: int = resolvedCategory
    local index: int = resolvedIndex
    local amount: int = 1
    if shiftHeld then
      local player: object = GetPlayerContainer()
      player->GetItemAmount(amount, index, category)
    end

    local beforeCount: int = GetBackpackItemCount()
    local usedOrder: int = GetOrderValue(GetVisibleCell(sourceSlot))
    if DropSlot(category, index, amount) then
      local afterCount: int = GetBackpackItemCount()
      if afterCount < beforeCount then RemoveOrderOrdinal(usedOrder, beforeCount) end
      UpdateSlots()
    end
    return true
  end

  function HandleSlotMessage(message: int, sender: string) -> bool
    for slot = 0, visibleSlots - 1 do
      if sender == GetSlotWndName(slot) then
        if ResolveVisibleSlot(slot) then
          if message == 1 then
            local beforeCount: int = GetBackpackItemCount()
            local usedOrder: int = GetOrderValue(GetVisibleCell(slot))
            ToggleSlot(resolvedCategory, resolvedIndex)
            local afterCount: int = GetBackpackItemCount()
            if afterCount < beforeCount then
              RemoveOrderOrdinal(usedOrder, beforeCount)
            end
          else
            native.Trace("utopian_inventory left click ignored " + sender)
          end
        end
        UpdateSlots()
        return true
      end
    end
    return false
  end

  function GetSlotBySender(sender: string) -> int
    for slot = 0, visibleSlots - 1 do
      if sender == GetSlotWndName(slot) then
        return slot
      end
    end
    return -1
  end

  function GetDragSourceBySender(sender: string) -> int
    local backpackSource: int = GetSlotBySender(sender)
    if backpackSource >= 0 then return backpackSource end
    return GetSpecialTargetBySender(sender)
  end

  function GetSpecialTargetBySender(sender: string) -> int
    if sender == "equip_weapon" then return c_iTargetWeapon end
    if sender == "equip_feet" then return c_iTargetClothesBase + 1 end
    if sender == "equip_head" then return c_iTargetClothesBase + 2 end
    if sender == "equip_body" then return c_iTargetClothesBase + 3 end
    if sender == "equip_hands" then return c_iTargetClothesBase + 4 end
    if sender == "drop_slot" then return c_iTargetDrop end
    return -1
  end

  function GetSpecialTargetByDollMessage(message: int) -> int
    if message == -50 then return c_iTargetWeapon end
    if message == -51 then return c_iTargetClothesBase + 1 end
    if message == -52 then return c_iTargetClothesBase + 2 end
    if message == -53 then return c_iTargetClothesBase + 3 end
    if message == -54 then return c_iTargetClothesBase + 4 end
    return -1
  end

  function GetSpecialTargetByDollSourceMessage(message: int, base: int) -> int
    local offset: int = base - message
    if offset == 0 then return c_iTargetWeapon end
    if offset >= 1 && offset <= 4 then return c_iTargetClothesBase + offset end
    return -1
  end

  function IsSpecialTargetCompatible(target: int) -> bool
    if target == c_iTargetDrop then return true end
    if target == c_iTargetWeapon then
      return dragItemCategory == c_iCWeapon && dragItemIsWeapon
    end
    if target > c_iTargetClothesBase && target <= c_iTargetClothesBase + 4 then
      return dragItemCategory == c_iCClothes && target == c_iTargetClothesBase + dragItemGroup
    end
    return false
  end

  function StartDragAction(source: int, sender: string) -> void
    dragSourceSlot = source
    hoverSlot = dragSourceSlot
    lastPointerSlot = dragSourceSlot
    dragDebugLastPointerSlot = -999
    dragDebugLastAppliedTarget = -999
    dragMoved = false
    lastValidDropTarget = -1
    invalidDropTargetFrames = 0
    SetHighlightedSlot(-1)
    BeginDragCursor(dragSourceSlot)
    native.Trace("utopian_inventory press " + sender + " " + dragSourceSlot)
  end

  function UnequipTarget(target: int, reason: string) -> void
    if ResolveEquipmentTarget(target) then
      local beforeCount: int = GetBackpackItemCount()
      if beforeCount >= c_iInventoryCapacity then
        native.Trace("utopian_inventory unequip refused: backpack full target=" + target)
        ShowInventoryFull()
        return
      end
      local category: int = resolvedCategory
      local index: int = resolvedIndex
      if UnequipItem(category, index) then
        InsertOrderOrdinal(GetBackpackOrdinal(category, index), beforeCount)
        native.Trace("utopian_inventory unequipped by " + reason + " target=" + target)
      end
      UpdateSlots()
    end
  end

  function SwapSlotOrder(sourceSlot: int, targetSlot: int) -> void
    if sourceSlot < 0 || targetSlot < 0 || sourceSlot == targetSlot then
      return
    end
    if sourceSlot >= visibleSlots || targetSlot >= visibleSlots then
      return
    end

    local sourceCell: int = GetVisibleCell(sourceSlot)
    local targetCell: int = GetVisibleCell(targetSlot)
    if sourceCell < 0 || targetCell < 0 then return end
    local sourceOrder: int = GetOrderValue(sourceCell)
    local targetOrder: int = GetOrderValue(targetCell)
    SetOrderValue(sourceCell, targetOrder)
    SetOrderValue(targetCell, sourceOrder)
    SaveLayoutVariables()
    UpdateSlots()
  end

  function RemoveOrderOrdinal(removedOrder: int, beforeCount: int) -> void
    if removedOrder < 0 then
      return
    end

    local emptyOrder: int = beforeCount - 1
    for slot = 0, c_iInventoryCapacity - 1 do
      local order: int = GetOrderValue(slot)
      if order == removedOrder then
        SetOrderValue(slot, emptyOrder)
      else
        if order > removedOrder && order < beforeCount then
          SetOrderValue(slot, order - 1)
        end
      end
    end
    NormalizeSlotOrder()
    OrderFreeCellsByDisplay()
    SaveLayoutVariables()
  end

  function FindFirstFreeVisualSlot(itemCount: int) -> int
    for linear = 0, c_iInventoryCapacity - 1 do
      local cell: int = GetCellForLinearSlot(linear)
      if cell >= 0 && GetOrderValue(cell) >= itemCount then
        return cell
      end
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
          if currentCategory == category && currentIndex == index then
            return ordinal
          end
          ordinal = ordinal + 1
        end
      end
    end
    return -1
  end

  function InsertOrderOrdinal(insertedOrder: int, beforeCount: int) -> bool
    if insertedOrder < 0 then return false end
    local freeSlot: int = FindFirstFreeVisualSlot(beforeCount)
    if freeSlot < 0 then return false end

    for slot = 0, c_iInventoryCapacity - 1 do
      if slot != freeSlot then
        local order: int = GetOrderValue(slot)
        if order >= insertedOrder && order < beforeCount then
          SetOrderValue(slot, order + 1)
        end
      end
    end
    SetOrderValue(freeSlot, insertedOrder)
    NormalizeSlotOrder()
    OrderFreeCellsByDisplay()
    SaveLayoutVariables()
    native.Trace("utopian_inventory inserted ordinal=" + insertedOrder + " visualSlot=" + freeSlot)
    return true
  end

  function SetHighlightedSlot(slot: int) -> void
    if highlightedSlot == slot then
      return
    end

    if highlightedSlot >= 0 then
      native.SendMessage(-21, GetTargetWndName(highlightedSlot))
    end

    highlightedSlot = slot
    if highlightedSlot >= 0 then
      native.SendMessage(-20, GetTargetWndName(highlightedSlot))
    end
  end

  function FinishLeftAction(targetSlot: int) -> void
    if dragSourceSlot < 0 then
      return
    end

    local sourceSlot: int = dragSourceSlot

    if targetSlot < 0 && lastValidDropTarget >= 0 && invalidDropTargetFrames <= 3 then
      targetSlot = lastValidDropTarget
      native.Trace("utopian_inventory release latched target=" + targetSlot)
    end

    native.Trace("utopian_inventory finish source=" + sourceSlot + " target=" + targetSlot + " moved=" + dragMoved)

    if sourceSlot >= c_iTargetWeapon && sourceSlot <= c_iTargetClothesBase + 4 then
      if targetSlot >= 0 && targetSlot < visibleSlots then
        local beforeCount: int = GetBackpackItemCount()
        if beforeCount < c_iInventoryCapacity then
          if UnequipItem(dragItemCategory, dragItemIndex) then
            InsertOrderOrdinal(GetBackpackOrdinal(dragItemCategory, dragItemIndex), beforeCount)
            native.Trace("utopian_inventory unequipped by drag source=" + sourceSlot + " target=" + targetSlot)
          end
        else
          native.Trace("utopian_inventory unequip drag refused: backpack full source=" + sourceSlot)
          ShowInventoryFull()
        end
        UpdateSlots()
      else
        if targetSlot == c_iTargetDrop then
          DropSlot(dragItemCategory, dragItemIndex, 1)
          UpdateSlots()
        else
          native.Trace("utopian_inventory equipped source release ignored source=" + sourceSlot + " target=" + targetSlot)
        end
      end
    else
      if targetSlot >= 0 && targetSlot < visibleSlots && targetSlot != sourceSlot then
        native.Trace("utopian_inventory swap " + sourceSlot + " " + targetSlot)
        SwapSlotOrder(sourceSlot, targetSlot)
      else
        if targetSlot >= c_iTargetWeapon && targetSlot <= c_iTargetClothesBase + 4 then
          if ResolveVisibleSlot(sourceSlot) then
            local beforeCount: int = GetBackpackItemCount()
            local usedOrder: int = GetOrderValue(GetVisibleCell(sourceSlot))
            local equipped: bool = EquipDraggedItem(targetSlot, resolvedCategory, resolvedIndex)
            if equipped then
              local afterCount: int = GetBackpackItemCount()
              if afterCount < beforeCount then RemoveOrderOrdinal(usedOrder, beforeCount) end
              native.Trace("utopian_inventory equipped target=" + targetSlot)
            else
              native.Trace("utopian_inventory incompatible target=" + targetSlot)
            end
            UpdateSlots()
          end
        else
          if targetSlot == c_iTargetDrop then
            if ResolveVisibleSlot(sourceSlot) then
              local beforeCount: int = GetBackpackItemCount()
              local usedOrder: int = GetOrderValue(GetVisibleCell(sourceSlot))
              DropSlot(resolvedCategory, resolvedIndex, 1)
              local afterCount: int = GetBackpackItemCount()
              if afterCount < beforeCount then RemoveOrderOrdinal(usedOrder, beforeCount) end
              UpdateSlots()
            end
          else
            native.Trace("utopian_inventory left release " + sourceSlot)
          end
        end
      end
    end

    dragSourceSlot = -1
    hoverSlot = -1
    lastPointerSlot = -1
    SetHighlightedSlot(-1)
    dragMoved = false
    lastValidDropTarget = -1
    invalidDropTargetFrames = 0
    dragDebugLastAppliedTarget = -999
    EndDragCursor()
  end

  function FindBackpackSlotAt(x: int, y: int) -> int
    local startX: int = GetGridStartX()
    local startY: int = GetGridStartY()
    local step: int = GetGridStep()
    local columns: int = GetGridColumns()

    if x < startX || y < startY then
      return -1
    end

    local rows: int = (visibleSlots + columns - 1) / columns
    if x >= startX + columns * step || y >= startY + rows * step then
      return -1
    end

    local column: int = (x - startX) / step
    local row: int = (y - startY) / step
    if column < 0 || column >= columns || row < 0 || row >= rows then
      return -1
    end

    local localX: int = x - startX - column * step
    local localY: int = y - startY - row * step
    if !IsInsideSlotDropArea(localX, localY) then
      return -1
    end

    local slot: int = row * columns + column
    if slot < 0 || slot >= visibleSlots then
      return -1
    end
    return slot
  end

  function FindSlotAt(x: int, y: int) -> int
    local backpackSlot: int = FindBackpackSlotAt(x, y)
    if backpackSlot >= 0 then return backpackSlot end
    return FindSpecialTargetAt(x, y)
  end

  function IsInsideSlotDropArea(localX: int, localY: int) -> bool
    return localX >= c_iSlotDropInset &&
      localY >= c_iSlotDropInset &&
      localX < c_iSlotHotZone - c_iSlotDropInset &&
      localY < c_iSlotHotZone - c_iSlotDropInset
  end

  function FindSlotAtPointer(x: int, y: int) -> int
    return FindSlotAt(x, y)
  end

  function UpdatePointerSlot(x: int, y: int) -> int
    lastPointerSlot = FindSlotAtPointer(x, y)
    if lastPointerSlot != dragDebugLastPointerSlot then
      native.Trace("utopian_inventory root pointer x=" + x + " y=" + y + " slot=" + lastPointerSlot)
      dragDebugLastPointerSlot = lastPointerSlot
    end
    return lastPointerSlot
  end

  function IsCursorPollingReady() -> bool
    return false
  end

  function UpdatePointerSlotFromCursorVariables() -> int
    local cursorX: int = -1
    local cursorY: int = -1
    native.GetVariable("utopian_inventory_cursor_x", cursorX)
    native.GetVariable("utopian_inventory_cursor_y", cursorY)
    if cursorX < 0 || cursorY < 0 then
      lastPointerSlot = -1
      if lastPointerSlot != dragDebugLastPointerSlot then
        native.Trace("utopian_inventory dll pointer x=" + cursorX + " y=" + cursorY + " slot=-1")
        dragDebugLastPointerSlot = lastPointerSlot
      end
      return -1
    end

    lastPointerSlot = FindSlotAtPointer(cursorX, cursorY)
    if lastPointerSlot != dragDebugLastPointerSlot then
      native.Trace("utopian_inventory dll pointer x=" + cursorX + " y=" + cursorY + " slot=" + lastPointerSlot)
      dragDebugLastPointerSlot = lastPointerSlot
    end
    return lastPointerSlot
  end

  function ApplyPointerSlot(slot: int) -> void
    if dragSourceSlot < 0 then
      return
    end

    TraceDragTarget(slot)

    if slot >= 0 && slot != dragSourceSlot then
      dragMoved = true
      lastValidDropTarget = slot
      invalidDropTargetFrames = 0
      SetHighlightedSlot(slot)
    else
      if slot < 0 then
        invalidDropTargetFrames = invalidDropTargetFrames + 1
      else
        invalidDropTargetFrames = 0
      end
      SetHighlightedSlot(-1)
    end
  end

  function GetCurrentDropSlot(message: int, base: int, sender: string) -> int
    if IsCursorPollingReady() then
      return UpdatePointerSlotFromCursorVariables()
    end
    return GetSlotTargetFromPointerMessage(message, base, sender)
  end

  function GetSlotTargetFromPointerMessage(message: int, base: int, sender: string) -> int
    local senderSlot: int = GetSlotBySender(sender)
    if senderSlot < 0 then
      return -1
    end

    local encoded: int = message - base
    local localX: int = encoded / 100
    local localY: int = encoded - localX * 100
    local targetSlot: int = -1
    if IsInsideSlotDropArea(localX, localY) then
      targetSlot = senderSlot
    end
    if targetSlot != dragDebugLastTargetSlot then
      native.Trace("utopian_inventory slot target sender=" + senderSlot + " local=" + localX + "," + localY + " target=" + targetSlot)
      dragDebugLastTargetSlot = targetSlot
    end
    return targetSlot
  end

  function ChangePage(delta: int) -> void
    page = page + delta
    ClampPage()
    UpdateSlots()
  end

  function OnUpdate(delta: float) -> void
    if inventoryFullMessageCooldown > 0 then
      inventoryFullMessageCooldown = inventoryFullMessageCooldown - delta
      if inventoryFullMessageCooldown < 0 then inventoryFullMessageCooldown = 0 end
    end
    UpdateLayout()
    inventoryPollCooldown = inventoryPollCooldown - delta
    if inventoryPollCooldown <= 0 then
      inventoryPollCooldown = 0.1
      UpdateMoney()
      local currentBackpackCount: int = CaptureBackpackItems(currentBackpackSnapshot)
      if dragSourceSlot < 0 && currentBackpackCount != lastBackpackItemCount then
        if currentBackpackCount > lastBackpackItemCount then ReconcileExternalAdditions(currentBackpackCount) end
        UpdateSlots()
      end
    end
    if deferredInventoryRefresh > 0 then
      deferredInventoryRefresh = deferredInventoryRefresh - delta
      if deferredInventoryRefresh <= 0 then
        UpdateSlots()
        native.Trace("utopian_inventory deferred item-use refresh")
      end
    end
    if dragSourceSlot >= 0 && IsCursorPollingReady() then
      ApplyPointerSlot(UpdatePointerSlotFromCursorVariables())
    end
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

  function StartPanelPointerDrag(x: int, y: int) -> void
    if dragSourceSlot >= 0 then return end

    local equipmentTarget: int = FindEquipmentTargetAt(x, y)
    if equipmentTarget >= 0 && ResolveEquipmentTarget(equipmentTarget) then
      StartDragAction(equipmentTarget, "panel_background")
      return
    end

    local backpackSlot: int = FindBackpackSlotAt(x, y)
    if backpackSlot >= 0 && HandleModifiedDrop(backpackSlot) then return end
    if backpackSlot >= 0 && ResolveVisibleSlot(backpackSlot) then
      StartDragAction(backpackSlot, "panel_background")
    end
  end

  function ClearPanelTooltip() -> void
    if panelTooltipTarget != -1 then
      panelTooltipTarget = -1
      native.SendMessage(-1, "panel_background")
    end
  end

  function UpdatePanelTooltip(x: int, y: int) -> void
    if dragSourceSlot >= 0 then
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

    local target: int = FindBackpackSlotAt(x, y)
    local found: bool = false
    if target >= 0 then
      found = ResolveVisibleSlot(target)
    else
      target = FindEquipmentTargetAt(x, y)
      if target >= 0 then found = ResolveEquipmentTarget(target) end
    end

    if !found then
      ClearPanelTooltip()
      return
    end
    if panelTooltipTarget == target then return end

    local container: object = GetPlayerContainer()
    local item: object
    container->GetItem(item, resolvedIndex, resolvedCategory)
    if item then
      panelTooltipTarget = target
      native.SendMessage(1, "panel_background", item)
    else
      ClearPanelTooltip()
    end
  end

  function HandlePanelPointer(message: int) -> void
    local base: int = c_iPanelPointerMoveBase
    local action: int = 0

    if message >= c_iPanelPointerLeaveBase then
      ClearPanelTooltip()
      native.SendMessage(-95, "page_prev")
      native.SendMessage(-95, "page_next")
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
      local equipmentTarget: int = FindEquipmentTargetAt(x, y)
      if equipmentTarget >= 0 then
        UnequipTarget(equipmentTarget, "panel right click")
        return
      end
      local backpackSlot: int = FindBackpackSlotAt(x, y)
      if backpackSlot >= 0 then HandleSlotMessage(1, GetSlotWndName(backpackSlot)) end
      return
    end

    local targetSlot: int = FindSlotAt(x, y)
    if action == 3 then
      if dragSourceSlot >= 0 then
        ApplyPointerSlot(targetSlot)
        FinishLeftAction(targetSlot)
      end
      return
    end

    if dragSourceSlot >= 0 then ApplyPointerSlot(targetSlot) end
  end

  function HandlePageControlAt(x: int, y: int) -> bool
    if visibleSlots >= c_iInventoryCapacity then return false end

    local controlX: int = 359
    local controlY: int = 465
    if windowWidth >= 1000 then
      controlX = 710
      controlY = 580
    end

    if y < controlY || y >= controlY + 28 then return false end
    if x >= controlX && x < controlX + 32 then
      if page > 0 then ChangePage(-1) end
      return true
    end
    if x >= controlX + 100 && x < controlX + 132 then
      if page < GetMaxPage() then ChangePage(1) end
      return true
    end
    return false
  end

  function UpdatePageControlHover(x: int, y: int) -> void
    if GetMaxPage() <= 0 then return end
    local controlX: int = 359
    local controlY: int = 465
    if windowWidth >= 1000 then
      controlX = 710
      controlY = 580
    end
    if page > 0 && x >= controlX && x < controlX + 32 && y >= controlY && y < controlY + 28 then
      native.SendMessage(-94, "page_prev")
    else
      native.SendMessage(-95, "page_prev")
    end
    if page < GetMaxPage() && x >= controlX + 100 && x < controlX + 132 && y >= controlY && y < controlY + 28 then
      native.SendMessage(-94, "page_next")
    else
      native.SendMessage(-95, "page_next")
    end
  end

  function OnUIMessage(message: int, sender: string, data: object) -> void
    if sender == "panel_background" && message >= c_iPanelPointerMoveBase then
      HandlePanelPointer(message)
      return
    end

    if message == -43 then
      local unequipTarget: int = GetSpecialTargetBySender(sender)
      UnequipTarget(unequipTarget, "right click")
      return
    end

    if message <= -60 && message >= -64 then
      local dollSource: int = GetSpecialTargetByDollSourceMessage(message, -60)
      if ResolveEquipmentTarget(dollSource) then
        StartDragAction(dollSource, "character_doll")
      end
      return
    end

    if message <= -70 && message >= -74 then
      local dollTarget: int = GetSpecialTargetByDollSourceMessage(message, -70)
      UnequipTarget(dollTarget, "doll right click")
      return
    end

    if message == -40 then
      if dragSourceSlot >= 0 then
        local specialTarget: int = GetSpecialTargetBySender(sender)
        if specialTarget >= 0 && IsSpecialTargetCompatible(specialTarget) then
          hoverSlot = specialTarget
          ApplyPointerSlot(specialTarget)
        else
          hoverSlot = -1
          ApplyPointerSlot(-1)
        end
      end
      return
    end

    if message <= -50 && message >= -54 then
      if dragSourceSlot >= 0 then
        local dollTarget: int = GetSpecialTargetByDollMessage(message)
        if dollTarget >= 0 && IsSpecialTargetCompatible(dollTarget) then
          hoverSlot = dollTarget
          ApplyPointerSlot(dollTarget)
        else
          hoverSlot = -1
          ApplyPointerSlot(-1)
        end
      end
      return
    end

    if message == -42 then
      if dragSourceSlot >= 0 then
        local releaseTarget: int = GetSpecialTargetBySender(sender)
        if releaseTarget >= 0 && IsSpecialTargetCompatible(releaseTarget) then
          ApplyPointerSlot(releaseTarget)
          FinishLeftAction(releaseTarget)
        end
      end
      return
    end

    if message == -41 then
      if dragSourceSlot >= 0 then
        hoverSlot = -1
        ApplyPointerSlot(-1)
      end
      return
    end

    if sender == "page_prev" then
      if page > 0 then ChangePage(-1) end
      return
    end
    if sender == "page_next" then
      if page < GetMaxPage() then ChangePage(1) end
      return
    end

    if message >= c_iDragEndMessageBase then
      local targetSlot: int = GetCurrentDropSlot(message, c_iDragEndMessageBase, sender)
      native.Trace("utopian_inventory diagnostic drag-end sender=" + sender +
        " target=" + GetTargetDebugName(targetSlot) + " highlighted=" + GetTargetDebugName(highlightedSlot) +
        " latched=" + GetTargetDebugName(lastValidDropTarget) + " invalidFrames=" + invalidDropTargetFrames)
      ApplyPointerSlot(targetSlot)
      FinishLeftAction(targetSlot)
      return
    end

    if message >= c_iReleaseMessageBase then
      local targetSlot: int = GetCurrentDropSlot(message, c_iReleaseMessageBase, sender)
      native.Trace("utopian_inventory diagnostic release sender=" + sender +
        " target=" + GetTargetDebugName(targetSlot) + " highlighted=" + GetTargetDebugName(highlightedSlot) +
        " latched=" + GetTargetDebugName(lastValidDropTarget) + " invalidFrames=" + invalidDropTargetFrames)
      ApplyPointerSlot(targetSlot)
      FinishLeftAction(targetSlot)
      return
    end

    if message >= c_iHoverMessageBase then
      if dragSourceSlot >= 0 then
        if IsCursorPollingReady() then
          hoverSlot = UpdatePointerSlotFromCursorVariables()
        else
          hoverSlot = GetSlotTargetFromPointerMessage(message, c_iHoverMessageBase, sender)
        end
        ApplyPointerSlot(hoverSlot)
      else
        SetHighlightedSlot(GetSlotTargetFromPointerMessage(message, c_iHoverMessageBase, sender))
      end
      return
    end

    if message == 2 || message == 3 then
      local source: int = GetDragSourceBySender(sender)
      if HandleModifiedDrop(source) then return end
      StartDragAction(source, sender)
      return
    end

    if message == 4 then
      native.Trace("utopian_inventory system drag message 4 ignored")
      return
    end

    if message == 5 then
      native.Trace("utopian_inventory system drag message 5 ignored")
      return
    end

    if message == 6 then
      return
    end

    if message == 7 then
      if dragSourceSlot >= 0 then
        hoverSlot = -1
        lastPointerSlot = -1
      end
      SetHighlightedSlot(-1)
      return
    end

    if message == 8 then
      if dragSourceSlot >= 0 && IsCursorPollingReady() then
        local targetSlot: int = UpdatePointerSlotFromCursorVariables()
        native.Trace("utopian_inventory diagnostic message8 current=" + GetTargetDebugName(targetSlot) +
          " highlighted=" + GetTargetDebugName(highlightedSlot) +
          " latched=" + GetTargetDebugName(lastValidDropTarget) + " invalidFrames=" + invalidDropTargetFrames)
        if targetSlot < 0 then
          targetSlot = highlightedSlot
        end
        ApplyPointerSlot(targetSlot)
        FinishLeftAction(targetSlot)
      else
        FinishLeftAction(highlightedSlot)
      end
      return
    end

    if message != 0 && message != 1 then
      return
    end
    if data then
      return
    end
    native.Trace("utopian_inventory slot click " + message + " " + sender)
    HandleSlotMessage(message, sender)
  end
  function OnLButtonDown(x: int, y: int) -> void
    native.Trace("utopian_inventory OnLButtonDown")
    if HandlePageControlAt(x, y) then return end
    local equipmentTarget: int = FindEquipmentTargetAt(x, y)
    if equipmentTarget >= 0 && ResolveEquipmentTarget(equipmentTarget) then
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
    if dragSourceSlot >= 0 then
      local slot: int
      if IsCursorPollingReady() then
        slot = UpdatePointerSlotFromCursorVariables()
      else
        slot = UpdatePointerSlot(x, y)
      end
      ApplyPointerSlot(slot)
    end
  end

  function OnMouseLeave() -> void
    if dragSourceSlot >= 0 then
      lastPointerSlot = -1
      SetHighlightedSlot(-1)
    end
  end

  function OnLButtonUp(x: int, y: int) -> void
    if dragSourceSlot >= 0 then
      local targetSlot: int
      if IsCursorPollingReady() then
        targetSlot = UpdatePointerSlotFromCursorVariables()
      else
        targetSlot = UpdatePointerSlot(x, y)
      end
      ApplyPointerSlot(targetSlot)
      FinishLeftAction(targetSlot)
    end
  end

  function OnChar(char: int) -> void
    native.Trace("utopian_inventory OnChar close")
    native.DestroyWindow()
  end

  function OnKeyDown(key: int) -> void
    native.Trace("utopian_inventory OnKeyDown " + key)
    if key == c_iVKShift then shiftHeld = true end
    if key == c_iVKControl then controlHeld = true end
    if key == 27 || key == 73 || key == 105 then
      native.DestroyWindow()
    end
  end

  function OnKeyUp(key: int) -> void
    if key == c_iVKShift then shiftHeld = false end
    if key == c_iVKControl then controlHeld = false end
  end
end
