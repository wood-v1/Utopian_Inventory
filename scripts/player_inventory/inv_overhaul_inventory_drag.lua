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

  function PlayerDragInitializeState() -> void
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

  function BeginItem(
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

  function ClearItem() -> void
    itemID = -1
    itemCategory = -1
    itemIndex = -1
    itemGroup = -1
    itemIsWeapon = false
  end

  function BeginTransaction(newSourceSlot: int, newSourceCell: int) -> void
    sourceSlot = newSourceSlot
    sourceCell = newSourceCell
    hoverTarget = newSourceSlot
    moved = false
    latchedTarget = -1
    invalidTargetFrames = 0
  end

  function ClearTransaction() -> void
    sourceSlot = -1
    sourceCell = -1
    hoverTarget = -1
    moved = false
    latchedTarget = -1
    invalidTargetFrames = 0
  end

  function PlayerDragIsActive() -> bool return sourceSlot >= 0 end
  function GetSourceSlot() -> int return sourceSlot end
  function GetSourceCell() -> int return sourceCell end
  function GetHoverTarget() -> int return hoverTarget end
  function SetHoverTarget(target: int) -> void hoverTarget = target end
  function PlayerDragGetHighlightedTarget() -> int return highlightedTarget end
  function PlayerDragSetHighlightedTarget(target: int) -> void highlightedTarget = target end
  function HasMoved() -> bool return moved end
  function PlayerDragGetItemID() -> int return itemID end
  function GetItemCategory() -> int return itemCategory end
  function GetItemIndex() -> int return itemIndex end
  function GetItemGroup() -> int return itemGroup end
  function GetItemIsWeapon() -> bool return itemIsWeapon end

  function PlayerDragApplyPointerTarget(target: int, sameSource: bool) -> int
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

  function PlayerDragResolveReleaseTarget(target: int) -> int
    if target < 0 && latchedTarget >= 0 && invalidTargetFrames <= 3 then
      return latchedTarget
    end
    return target
  end

  function PlayerDragBeginPageHover(action: int) -> bool
    if action == 0 || pageHoverAction == action then return false end
    pageHoverAction = action
    pageHoverElapsed = 0
    pageHoverConsumed = false
    return true
  end

  function PlayerDragCanCancelPageHover(action: int) -> bool
    return action == 0 || pageHoverAction == action
  end

  function PlayerDragClearPageHover() -> void
    pageHoverAction = 0
    pageHoverElapsed = 0
    pageHoverConsumed = false
  end

  function PlayerDragGetPageHoverAction() -> int return pageHoverAction end
  function PlayerDragGetPageHoverElapsed() -> float return pageHoverElapsed end

  function PlayerDragAdvancePageHover(delta: float) -> int
    if sourceSlot < 0 || pageHoverAction == 0 || pageHoverConsumed then return 0 end
    pageHoverElapsed = pageHoverElapsed + delta
    if pageHoverElapsed < InventoryDragPageHoverDelay then return 0 end
    pageHoverConsumed = true
    latchedTarget = -1
    invalidTargetFrames = 0
    return pageHoverAction
  end
end
