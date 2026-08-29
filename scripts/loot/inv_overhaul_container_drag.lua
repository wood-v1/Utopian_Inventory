module inv_overhaul_container_drag do
  local const c_fPageHoverDelay: float = 1.00

  local source: int
  local kind: int
  local itemID: int
  local playerCategory: int
  local playerIndex: int
  local playerCell: int
  local containerIndex: int
  local containerOrdinal: int
  local containerVisual: int
  local highlightedTarget: int
  local lastValidTarget: int
  local invalidTargetFrames: int
  local pageHoverAction: int
  local pageHoverElapsed: float
  local pageHoverConsumed: bool

  function ContainerDragInitializeState() -> void
    source = -1
    kind = -1
    itemID = -1
    playerCategory = -1
    playerIndex = -1
    playerCell = -1
    containerIndex = -1
    containerOrdinal = -1
    containerVisual = -1
    highlightedTarget = -1
    lastValidTarget = -1
    invalidTargetFrames = 0
    pageHoverAction = 0
    pageHoverElapsed = 0
    pageHoverConsumed = false
  end

  function ContainerDragBeginPlayerSource(
    newSource: int,
    newItemID: int,
    newCategory: int,
    newIndex: int,
    newCell: int) -> void
    source = newSource
    kind = 0
    itemID = newItemID
    playerCategory = newCategory
    playerIndex = newIndex
    playerCell = newCell
    containerIndex = -1
    containerOrdinal = -1
    containerVisual = -1
    lastValidTarget = -1
    invalidTargetFrames = 0
  end

  function ContainerDragBeginExternalSource(
    newSource: int,
    newKind: int,
    newItemID: int,
    newIndex: int,
    newOrdinal: int,
    newVisual: int) -> void
    source = newSource
    kind = newKind
    itemID = newItemID
    playerCategory = -1
    playerIndex = -1
    playerCell = -1
    containerIndex = newIndex
    containerOrdinal = newOrdinal
    containerVisual = newVisual
    lastValidTarget = -1
    invalidTargetFrames = 0
  end

  function ContainerDragClearSource() -> void
    source = -1
    kind = -1
    itemID = -1
    playerCategory = -1
    playerIndex = -1
    playerCell = -1
    containerIndex = -1
    containerOrdinal = -1
    containerVisual = -1
    lastValidTarget = -1
    invalidTargetFrames = 0
  end

  function ContainerDragIsActive() -> bool return source >= 0 end
  function ContainerDragGetSource() -> int return source end
  function ContainerDragGetKind() -> int return kind end
  function ContainerDragGetItemID() -> int return itemID end
  function ContainerDragGetPlayerCategory() -> int return playerCategory end
  function ContainerDragGetPlayerIndex() -> int return playerIndex end
  function ContainerDragGetPlayerCell() -> int return playerCell end
  function ContainerDragGetContainerIndex() -> int return containerIndex end
  function ContainerDragGetContainerOrdinal() -> int return containerOrdinal end
  function ContainerDragGetContainerVisual() -> int return containerVisual end
  function ContainerDragGetHighlightedTarget() -> int return highlightedTarget end
  function ContainerDragSetHighlightedTarget(target: int) -> void highlightedTarget = target end

  function ContainerDragRecordPointerTarget(
    target: int,
    sameSource: bool,
    compatible: bool) -> int
    if target >= 0 && !sameSource && compatible then
      lastValidTarget = target
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

  function ContainerDragResolveReleaseTarget(target: int) -> int
    if target < 0 && lastValidTarget >= 0 && invalidTargetFrames <= 3 then
      return lastValidTarget
    end
    return target
  end

  function ContainerDragBeginPageHover(action: int) -> bool
    if action == 0 || action == pageHoverAction then return false end
    pageHoverAction = action
    pageHoverElapsed = 0
    pageHoverConsumed = false
    return true
  end

  function ContainerDragCanCancelPageHover(action: int) -> bool
    return action == 0 || pageHoverAction == action
  end

  function ContainerDragClearPageHover() -> void
    pageHoverAction = 0
    pageHoverElapsed = 0
    pageHoverConsumed = false
  end

  function ContainerDragGetPageHoverAction() -> int return pageHoverAction end
  function ContainerDragGetPageHoverElapsed() -> float return pageHoverElapsed end

  function ContainerDragAdvancePageHover(delta: float) -> int
    if source < 0 || pageHoverAction == 0 || pageHoverConsumed then return 0 end
    pageHoverElapsed = pageHoverElapsed + delta
    if pageHoverElapsed < c_fPageHoverDelay then return 0 end
    pageHoverConsumed = true
    lastValidTarget = -1
    invalidTargetFrames = 0
    return pageHoverAction
  end
end
