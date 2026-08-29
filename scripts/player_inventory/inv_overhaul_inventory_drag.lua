module inv_overhaul_inventory_drag do
  local const InventoryDragPageHoverDelay: float = 1.00

  local sourceSlot: int
  local sourceCell: int
  local hoverTarget: int
  local highlightedTarget: int
  local moved: bool
  local latchedTarget: int
  local invalidTargetFrames: int
  local itemID: int
  local itemCategory: int
  local itemIndex: int
  local itemGroup: int
  local itemIsWeapon: bool
  local pageHoverAction: int
  local pageHoverElapsed: float
  local pageHoverConsumed: bool

  function InventoryDragInitializeState() -> void
    sourceSlot = -1
    sourceCell = -1
    hoverTarget = -1
    highlightedTarget = -1
    moved = false
    latchedTarget = -1
    invalidTargetFrames = 0
    itemID = -1
    itemCategory = -1
    itemIndex = -1
    itemGroup = -1
    itemIsWeapon = false
    pageHoverAction = 0
    pageHoverElapsed = 0
    pageHoverConsumed = false
  end

  function InventoryDragBeginItem(
    newItemID: int,
    newCategory: int,
    newIndex: int,
    newGroup: int,
    newIsWeapon: bool) -> void
    itemID = newItemID
    itemCategory = newCategory
    itemIndex = newIndex
    itemGroup = newGroup
    itemIsWeapon = newIsWeapon
  end

  function InventoryDragClearItem() -> void
    itemID = -1
    itemCategory = -1
    itemIndex = -1
    itemGroup = -1
    itemIsWeapon = false
  end

  function InventoryDragBeginTransaction(newSourceSlot: int, newSourceCell: int) -> void
    sourceSlot = newSourceSlot
    sourceCell = newSourceCell
    hoverTarget = newSourceSlot
    moved = false
    latchedTarget = -1
    invalidTargetFrames = 0
  end

  function InventoryDragClearTransaction() -> void
    sourceSlot = -1
    sourceCell = -1
    hoverTarget = -1
    moved = false
    latchedTarget = -1
    invalidTargetFrames = 0
  end

  function InventoryDragIsActive() -> bool return sourceSlot >= 0 end
  function InventoryDragGetSourceSlot() -> int return sourceSlot end
  function InventoryDragGetSourceCell() -> int return sourceCell end
  function InventoryDragGetHoverTarget() -> int return hoverTarget end
  function InventoryDragSetHoverTarget(target: int) -> void hoverTarget = target end
  function InventoryDragGetHighlightedTarget() -> int return highlightedTarget end
  function InventoryDragSetHighlightedTarget(target: int) -> void highlightedTarget = target end
  function InventoryDragHasMoved() -> bool return moved end
  function InventoryDragGetItemID() -> int return itemID end
  function InventoryDragGetItemCategory() -> int return itemCategory end
  function InventoryDragGetItemIndex() -> int return itemIndex end
  function InventoryDragGetItemGroup() -> int return itemGroup end
  function InventoryDragGetItemIsWeapon() -> bool return itemIsWeapon end

  function InventoryDragApplyPointerTarget(target: int, sameSource: bool) -> int
    if target >= 0 && !sameSource then
      moved = true
      latchedTarget = target
      invalidTargetFrames = 0
      return target
    end
    if target < 0 then
      invalidTargetFrames = invalidTargetFrames + 1
    else
      invalidTargetFrames = 0
    end
    return -1
  end

  function InventoryDragResolveReleaseTarget(target: int) -> int
    if target < 0 && latchedTarget >= 0 && invalidTargetFrames <= 3 then
      return latchedTarget
    end
    return target
  end

  function InventoryDragBeginPageHover(action: int) -> bool
    if action == 0 || pageHoverAction == action then return false end
    pageHoverAction = action
    pageHoverElapsed = 0
    pageHoverConsumed = false
    return true
  end

  function InventoryDragCanCancelPageHover(action: int) -> bool
    return action == 0 || pageHoverAction == action
  end

  function InventoryDragClearPageHover() -> void
    pageHoverAction = 0
    pageHoverElapsed = 0
    pageHoverConsumed = false
  end

  function InventoryDragGetPageHoverAction() -> int return pageHoverAction end
  function InventoryDragGetPageHoverElapsed() -> float return pageHoverElapsed end

  function InventoryDragAdvancePageHover(delta: float) -> int
    if sourceSlot < 0 || pageHoverAction == 0 || pageHoverConsumed then return 0 end
    pageHoverElapsed = pageHoverElapsed + delta
    if pageHoverElapsed < InventoryDragPageHoverDelay then return 0 end
    pageHoverConsumed = true
    latchedTarget = -1
    invalidTargetFrames = 0
    return pageHoverAction
  end
end
