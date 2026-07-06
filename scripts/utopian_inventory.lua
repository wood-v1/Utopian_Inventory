maintask UtopianInventoryUI do
  local const c_iCWeapon: int = 0
  local const c_iCClothes: int = 1
  local const c_iCategoryCount: int = 5
  local const c_iSlotSelected: int = 16384
  local const c_iSlotEmpty: int = 32768
  local const c_iSlotNumber: int = 65536
  local const c_iHoverMessageBase: int = 100000
  local const c_iReleaseMessageBase: int = 200000
  local const c_iDragEndMessageBase: int = 300000
  local const c_iSlotHotZone: int = 52
  local const c_iSlotDropInset: int = 1

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
  local lastLayoutWidth: int
  local lastLayoutHeight: int
  local lastLayoutSlots: int

  function init() -> void
    native.Trace("utopian_inventory script init")
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
    lastLayoutWidth = -1
    lastLayoutHeight = -1
    lastLayoutSlots = -1
    InitSlotOrder()
    UpdateLayout()
    LoadLayoutVariables()
    UpdateSlots()
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
    for i = 0, 39 do
      slotOrder->add(i)
    end
  end

  function GetBranch() -> int
    local branch: int = -1
    native.GetVariable("branch", branch)
    return branch
  end

  function GetOrderValue(slot: int) -> int
    local order: int = slot
    if slot >= 0 && slot < 40 then
      slotOrder->get(order, slot)
    end
    return order
  end

  function SetOrderValue(slot: int, value: int) -> void
    if slot >= 0 && slot < 40 then
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
    if initialized != 1 || layoutVersion != 3 then
      SaveLayoutVariables()
      return
    end

    for i = 0, 39 do
      local order: int = i
      native.GetVariable(GetCellVariableName(i), order)
      if order < 0 || order >= 40 then
        order = i
      end
      SetOrderValue(i, order)
    end
    NormalizeSlotOrder()
    SaveLayoutVariables()
    native.Trace("utopian_inventory layout loaded from variables")
  end

  function SaveLayoutVariables() -> void
    for i = 0, 39 do
      native.SetVariable(GetCellVariableName(i), GetOrderValue(i))
    end
    native.SetVariable("utopian_inventory_layout_initialized", 1)
    native.SetVariable("utopian_inventory_layout_version", 3)
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
    for candidate = 0, 39 do
      if !IsOrderUsedAtOrBefore(slot, candidate) then
        return candidate
      end
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

  function GetPlayerContainer() -> object
    local container: object
    native.GetPlayerContainer(container)
    return container
  end

  function BeginDragCursor(slot: int) -> void
    native.SetVariable("utopian_inventory_drag_item", -1)
    if slot < 0 || slot >= visibleSlots then
      return
    end
    if !ResolveVisibleSlot(slot) then
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
    native.SetVariable("utopian_inventory_drag_item", itemID)
    native.SetCursor("drag_item")
  end

  function EndDragCursor() -> void
    native.SetVariable("utopian_inventory_drag_item", -1)
    native.SetCursor("default")
  end

  function UpdateLayout() -> void
    native.GetWindowSize(windowWidth, windowHeight)
    if windowWidth <= 0 || windowHeight <= 0 then
      native.GetScreenSize(windowWidth, windowHeight)
    end
    if windowWidth >= 1200 then
      visibleSlots = 40
    else
      if windowWidth >= 1000 then
        visibleSlots = 35
      else
        visibleSlots = 24
      end
    end
    if windowWidth != lastLayoutWidth || windowHeight != lastLayoutHeight || visibleSlots != lastLayoutSlots then
      native.Trace("utopian_inventory layout window=" + windowWidth + "x" + windowHeight + " slots=" + visibleSlots)
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

  function GetGridStartX() -> int
    if windowWidth >= 1200 then
      return 288
    end
    if windowWidth >= 1000 then
      return 200
    end
    return 128
  end

  function GetRootLeft() -> int
    return 0
  end

  function GetRootTop() -> int
    return 0
  end

  function GetGridStartY() -> int
    if windowWidth >= 1200 then
      return 324
    end
    if windowWidth >= 1000 then
      return 226
    end
    return 177
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
      total = total + count
    end

    return total
  end

  function ClampPage() -> void
    local total: int = GetBackpackItemCount()
    local maxPage: int = 0
    if total > 0 then
      maxPage = (total - 1) / visibleSlots
    end

    if page < 0 then
      page = 0
    end
    if page > maxPage then
      page = maxPage
    end
  end

  function ResolveVisibleSlot(slot: int) -> bool
    resolvedCategory = -1
    resolvedIndex = -1

    local target: int = page * visibleSlots + GetOrderValue(slot)
    local current: int = 0
    local container: object = GetPlayerContainer()

    for category = 0, c_iCategoryCount - 1 do
      local count: int
      container->GetItemCount(count, category)
      for index = 0, count - 1 do
        if current == target then
          resolvedCategory = category
          resolvedIndex = index
          return true
        end
        current = current + 1
      end
    end

    return false
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

    local container: object = GetPlayerContainer()
    for slot = 0, visibleSlots - 1 do
      local wndName: string = GetSlotWndName(slot)
      if ResolveVisibleSlot(slot) then
        local item: object
        local amount: int
        local selected: bool
        container->GetItem(item, resolvedIndex, resolvedCategory)
        container->GetItemAmount(amount, resolvedIndex, resolvedCategory)
        container->IsItemSelected(selected, resolvedIndex, resolvedCategory)

        if selected then
          native.SendMessage(c_iSlotSelected, wndName, item)
        else
          native.SendMessage(0, wndName, item)
        end
        native.SendMessage(amount + c_iSlotNumber, wndName)
      else
        native.SendMessage(c_iSlotEmpty, wndName)
      end
    end
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
      amount = amount - 1
      if amount == 0 then
        container->RemoveItem(index, 1, category)
      else
        container->SetItemAmount(amount, index, category)
      end
    end
  end

  function DropSlot(category: int, index: int) -> void
    local container: object
    native.GetContainer(container)
    if !container then
      return
    end

    local playerContainer: object = GetPlayerContainer()
    local item: object
    playerContainer->GetItem(item, index, category)

    local success: bool
    container->AddItem(success, item, 0, 1)
    if !success then
      return
    end

    if category == c_iCWeapon then
      local selected: bool
      playerContainer->IsItemSelected(selected, index, category)
      if selected then
        native.SetPlayerHandsItem(-1)
      end
    end

    playerContainer->RemoveItem(index, 1, category)
  end

  function HandleSlotMessage(message: int, sender: string) -> bool
    for slot = 0, visibleSlots - 1 do
      if sender == GetSlotWndName(slot) then
        if ResolveVisibleSlot(slot) then
          if message == 1 then
            local beforeCount: int = GetBackpackItemCount()
            local usedOrder: int = page * visibleSlots + GetOrderValue(slot)
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

  function SwapSlotOrder(sourceSlot: int, targetSlot: int) -> void
    if sourceSlot < 0 || targetSlot < 0 || sourceSlot == targetSlot then
      return
    end
    if sourceSlot >= visibleSlots || targetSlot >= visibleSlots then
      return
    end

    local sourceOrder: int = GetOrderValue(sourceSlot)
    local targetOrder: int = GetOrderValue(targetSlot)
    SetOrderValue(sourceSlot, targetOrder)
    SetOrderValue(targetSlot, sourceOrder)
    SaveLayoutVariables()
    UpdateSlots()
  end

  function RemoveOrderOrdinal(removedOrder: int, beforeCount: int) -> void
    if removedOrder < 0 then
      return
    end

    local emptyOrder: int = beforeCount - 1
    for slot = 0, 39 do
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
    SaveLayoutVariables()
  end

  function SetHighlightedSlot(slot: int) -> void
    if highlightedSlot == slot then
      return
    end

    if highlightedSlot >= 0 then
      native.SendMessage(-21, GetSlotWndName(highlightedSlot))
    end

    highlightedSlot = slot
    if highlightedSlot >= 0 then
      native.SendMessage(-20, GetSlotWndName(highlightedSlot))
    end
  end

  function FinishLeftAction(targetSlot: int) -> void
    if dragSourceSlot < 0 then
      return
    end

    local sourceSlot: int = dragSourceSlot

    native.Trace("utopian_inventory finish source=" + sourceSlot + " target=" + targetSlot + " moved=" + dragMoved)

    if targetSlot >= 0 && targetSlot != sourceSlot then
      native.Trace("utopian_inventory swap " + sourceSlot + " " + targetSlot)
      SwapSlotOrder(sourceSlot, targetSlot)
    else
      native.Trace("utopian_inventory left release " + sourceSlot)
    end

    dragSourceSlot = -1
    hoverSlot = -1
    lastPointerSlot = -1
    SetHighlightedSlot(-1)
    dragMoved = false
    EndDragCursor()
  end

  function FindSlotAt(x: int, y: int) -> int
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
    local ready: int = 0
    native.GetVariable("utopian_inventory_cursor_ready", ready)
    return ready == 1
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

    if slot >= 0 && slot != dragSourceSlot then
      dragMoved = true
      SetHighlightedSlot(slot)
    else
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
    UpdateSlots()
    UpdateMoney()
    if dragSourceSlot >= 0 && IsCursorPollingReady() then
      ApplyPointerSlot(UpdatePointerSlotFromCursorVariables())
    end
  end

  function OnUIMessage(message: int, sender: string, data: object) -> void
    if sender == "page_prev" then
      ChangePage(-1)
      return
    end
    if sender == "page_next" then
      ChangePage(1)
      return
    end

    if message >= c_iDragEndMessageBase then
      local targetSlot: int = GetCurrentDropSlot(message, c_iDragEndMessageBase, sender)
      ApplyPointerSlot(targetSlot)
      FinishLeftAction(targetSlot)
      return
    end

    if message >= c_iReleaseMessageBase then
      local targetSlot: int = GetCurrentDropSlot(message, c_iReleaseMessageBase, sender)
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
      end
      return
    end

    if message == 2 || message == 3 then
      dragSourceSlot = GetSlotBySender(sender)
      hoverSlot = dragSourceSlot
      lastPointerSlot = dragSourceSlot
      dragDebugLastPointerSlot = -999
      dragMoved = false
      SetHighlightedSlot(-1)
      BeginDragCursor(dragSourceSlot)
      native.Trace("utopian_inventory press " + sender + " " + dragSourceSlot)
      return
    end

    if message == 4 then
      SetHighlightedSlot(-1)
      FinishLeftAction(-1)
      return
    end

    if message == 5 then
      SetHighlightedSlot(-1)
      FinishLeftAction(-1)
      return
    end

    if message == 6 then
      return
    end

    if message == 7 then
      if dragSourceSlot >= 0 then
        hoverSlot = -1
        lastPointerSlot = -1
        SetHighlightedSlot(-1)
      end
      return
    end

    if message == 8 then
      if dragSourceSlot >= 0 && IsCursorPollingReady() then
        local targetSlot: int = UpdatePointerSlotFromCursorVariables()
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
    if y > windowHeight - 48 then
      if x < 96 then
        ChangePage(-1)
      else
        if x > windowWidth - 96 then
          ChangePage(1)
        end
      end
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

  function OnMouseWheel(x: int, y: int, delta: float) -> void
    native.Trace("utopian_inventory OnMouseWheel")
    if delta > 0 then
      ChangePage(-1)
    else
      ChangePage(1)
    end
  end

  function OnChar(char: int) -> void
    native.Trace("utopian_inventory OnChar close")
    native.DestroyWindow()
  end

  function OnKeyDown(key: int) -> void
    native.Trace("utopian_inventory OnKeyDown " + key)
    if key == 27 || key == 73 || key == 105 then
      native.DestroyWindow()
    end
  end
end
