import "inv_overhaul_container_drag"
import "inv_overhaul_container_player_actions"
import "inv_overhaul_container_presenter"
import "inv_overhaul_container_projection"
import "inv_overhaul_container_protocol"
import "inv_overhaul_container_tooltip_controller"
import "inv_overhaul_container_transfer_external"
import "inv_overhaul_container_transfer_player"
import "inv_overhaul_container_view"
import "inv_overhaul_inventory_tooltip"
import "inv_overhaul_inventory_items"

module inv_overhaul_container_drag_controller do
  local const ContainerSlots: int = 12

  function ContainerDragControllerGetTargetBySender(sender: string) -> int
    local visibleSlots: int =
      inv_overhaul_container_presenter.ContainerPresenterGetVisibleSlots()
    return inv_overhaul_container_protocol.ContainerProtocolGetTargetBySender(
      sender, visibleSlots)
  end

  function ContainerDragControllerFindTargetAt(x: int, y: int) -> int
    local windowWidth: int =
      inv_overhaul_container_presenter.ContainerPresenterGetWindowWidth()
    local visibleSlots: int =
      inv_overhaul_container_presenter.ContainerPresenterGetVisibleSlots()
    local showOrgans: bool =
      inv_overhaul_container_presenter.ContainerPresenterShowsOrgans()
    return inv_overhaul_container_protocol.ContainerProtocolFindTargetAt(
      windowWidth, visibleSlots, showOrgans, x, y)
  end

  function ContainerDragControllerIsTargetCompatible(target: int) -> bool
    local kind: int = inv_overhaul_container_drag.ContainerDragGetKind()
    local visibleSlots: int =
      inv_overhaul_container_presenter.ContainerPresenterGetVisibleSlots()
    return inv_overhaul_container_protocol.ContainerProtocolIsTargetCompatible(
      kind, target, visibleSlots)
  end

  function ContainerDragControllerResolveSource(source: int) -> bool
    local item: object
    local kind: int = -1
    local playerCategory: int = -1
    local playerIndex: int = -1
    local playerCell: int = -1
    local containerIndex: int = -1
    local containerOrdinal: int = -1
    local containerVisual: int = -1
    local visibleSlots: int =
      inv_overhaul_container_presenter.ContainerPresenterGetVisibleSlots()

    if inv_overhaul_container_protocol.ContainerProtocolIsPlayerTarget(
      source, visibleSlots) then
      local playerReference: int =
        inv_overhaul_container_presenter.ContainerPresenterResolveVisibleSlot(source)
      if playerReference < 0 then return false end
      kind = 0
      playerCategory =
        inv_overhaul_inventory_items.InventoryItemsDecodeReferenceCategory(
          playerReference)
      playerIndex =
        inv_overhaul_inventory_items.InventoryItemsDecodeReferenceIndex(
          playerReference)
      playerCell =
        inv_overhaul_container_presenter.ContainerPresenterGetVisibleCell(source)
      local player: object =
        inv_overhaul_inventory_items.InventoryItemsGetPlayerContainer()
      player->GetItem(item, playerIndex, playerCategory)
    else
      local containerReference: int = -1
      if inv_overhaul_container_protocol.ContainerProtocolIsContainerTarget(source) then
        local containerSlot: int =
          inv_overhaul_container_protocol.ContainerProtocolGetContainerSlot(source)
        containerReference =
          inv_overhaul_container_presenter.ContainerPresenterResolveContainerVisualSlot(
            containerSlot)
        if containerReference < 0 then return false end
        kind = 1
        local containerPage: int =
          inv_overhaul_container_presenter.ContainerPresenterGetContainerPage()
        containerVisual = containerPage * ContainerSlots + containerSlot
      else
        if inv_overhaul_container_protocol.ContainerProtocolIsOrganTarget(source) then
          local organSlot: int =
            inv_overhaul_container_protocol.ContainerProtocolGetOrganSlot(source)
          containerReference =
            inv_overhaul_container_presenter.ContainerPresenterResolveOrganVisualSlot(
              organSlot)
          if containerReference < 0 then return false end
          kind = 2
        else
          return false
        end
      end
      containerIndex =
        inv_overhaul_container_projection.ContainerProjectionGetReferenceIndex(
          containerReference)
      containerOrdinal =
        inv_overhaul_container_projection.ContainerProjectionGetReferenceOrdinal(
          containerReference)
      local external: object
      native.GetContainer(external)
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

  function ContainerDragControllerBeginCursor(source: int) -> bool
    native.SetVariable("inv_overhaul_inventory_drag_item", -1)
    if !ContainerDragControllerResolveSource(source) then return false end
    local itemID: int = inv_overhaul_container_drag.ContainerDragGetItemID()
    native.SetVariable("inv_overhaul_inventory_drag_item", itemID)
    return true
  end

  function ContainerDragControllerEndCursor() -> void
    native.SetVariable("inv_overhaul_inventory_drag_item", -1)
    native.SetVariable("inv_overhaul_inventory_page_hover", 0)
    inv_overhaul_container_drag.ContainerDragClearSource()
  end

  function ContainerDragControllerSetHighlightedTarget(target: int) -> void
    if inv_overhaul_container_drag.ContainerDragIsActive() && target >= 0 &&
      !ContainerDragControllerIsTargetCompatible(target) then target = -1 end
    local previousTarget: int =
      inv_overhaul_container_drag.ContainerDragGetHighlightedTarget()
    if previousTarget == target then return end
    local visibleSlots: int =
      inv_overhaul_container_presenter.ContainerPresenterGetVisibleSlots()
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

  function ContainerDragControllerApplyPointerTarget(target: int) -> void
    if !inv_overhaul_container_drag.ContainerDragIsActive() then return end
    local source: int = inv_overhaul_container_drag.ContainerDragGetSource()
    local kind: int = inv_overhaul_container_drag.ContainerDragGetKind()
    local sameSource: bool = false
    if target == source then sameSource = true end
    local visibleSlots: int =
      inv_overhaul_container_presenter.ContainerPresenterGetVisibleSlots()
    if kind == 0 &&
      inv_overhaul_container_protocol.ContainerProtocolIsPlayerTarget(
        target, visibleSlots) then
      local targetCell: int =
        inv_overhaul_container_presenter.ContainerPresenterGetVisibleCell(target)
      if targetCell == inv_overhaul_container_drag.ContainerDragGetPlayerCell() then
        sameSource = true
      else
        sameSource = false
      end
    end
    if kind == 1 &&
      inv_overhaul_container_protocol.ContainerProtocolIsContainerTarget(target) then
      local page: int =
        inv_overhaul_container_presenter.ContainerPresenterGetContainerPage()
      if page * ContainerSlots +
        inv_overhaul_container_protocol.ContainerProtocolGetContainerSlot(target) ==
        inv_overhaul_container_drag.ContainerDragGetContainerVisual() then
        sameSource = true
      else
        sameSource = false
      end
    end
    local compatible: bool = ContainerDragControllerIsTargetCompatible(target)
    local recordedTarget: int =
      inv_overhaul_container_drag.ContainerDragRecordPointerTarget(
        target, sameSource, compatible)
    ContainerDragControllerSetHighlightedTarget(recordedTarget)
  end

  function ContainerDragControllerCancelPageHover(action: int) -> void
    if !inv_overhaul_container_drag.ContainerDragCanCancelPageHover(action) then return end
    local currentAction: int =
      inv_overhaul_container_drag.ContainerDragGetPageHoverAction()
    if currentAction != 0 then
      native.Trace("inv_overhaul_container page-hover cancel action=" +
        currentAction + " elapsed=" +
        inv_overhaul_container_drag.ContainerDragGetPageHoverElapsed())
    end
    inv_overhaul_container_drag.ContainerDragClearPageHover()
  end

  function ContainerDragControllerStart(source: int) -> void
    if inv_overhaul_container_drag.ContainerDragIsActive() then return end
    ContainerDragControllerCancelPageHover(0)
    inv_overhaul_container_tooltip_controller.ContainerTooltipClear()
    if !ContainerDragControllerBeginCursor(source) then return end
    ContainerDragControllerSetHighlightedTarget(-1)
  end

  function ContainerDragControllerFinish(target: int) -> void
    if !inv_overhaul_container_drag.ContainerDragIsActive() then return end
    target = inv_overhaul_container_drag.ContainerDragResolveReleaseTarget(target)
    local source: int = inv_overhaul_container_drag.ContainerDragGetSource()
    local sourceKind: int = inv_overhaul_container_drag.ContainerDragGetKind()
    local playerCell: int =
      inv_overhaul_container_drag.ContainerDragGetPlayerCell()
    local containerVisual: int =
      inv_overhaul_container_drag.ContainerDragGetContainerVisual()
    local visibleSlots: int =
      inv_overhaul_container_presenter.ContainerPresenterGetVisibleSlots()
    inv_overhaul_inventory_tooltip.InventoryTooltipSuspend(0.2)
    inv_overhaul_container_tooltip_controller.ContainerTooltipClear()
    if source >= 0 then
      native.SendMessage(
        -130,
        inv_overhaul_container_view.ContainerViewGetTargetWndName(
          source, visibleSlots))
    end
    if target >= 0 then
      native.SendMessage(
        -130,
        inv_overhaul_container_view.ContainerViewGetTargetWndName(
          target, visibleSlots))
    end

    if ContainerDragControllerIsTargetCompatible(target) then
      if sourceKind == 0 then
        if inv_overhaul_container_protocol.ContainerProtocolIsPlayerTarget(
          target, visibleSlots) then
          local targetCell: int =
            inv_overhaul_container_presenter.ContainerPresenterGetVisibleCell(target)
          if targetCell != playerCell then
            inv_overhaul_container_player_actions.ContainerPlayerActionsSwapCells(
              playerCell, targetCell)
          end
        else
          if inv_overhaul_container_protocol.ContainerProtocolIsContainerTarget(
            target) then
            inv_overhaul_container_transfer_player.ContainerPlayerTransferExchangeWithContainer(
              source,
              inv_overhaul_container_protocol.ContainerProtocolGetContainerSlot(
                target))
          end
        end
      else
        if inv_overhaul_container_protocol.ContainerProtocolIsPlayerTarget(
          target, visibleSlots) then
          if sourceKind == 1 then
            inv_overhaul_container_transfer_external.ContainerExternalTransferMoveToPlayer(
              false,
              inv_overhaul_container_protocol.ContainerProtocolGetContainerSlot(source),
              target, -1)
          else
            inv_overhaul_container_transfer_external.ContainerExternalTransferMoveToPlayer(
              true,
              inv_overhaul_container_protocol.ContainerProtocolGetOrganSlot(source),
              target, -1)
          end
        else
          if sourceKind == 1 &&
            inv_overhaul_container_protocol.ContainerProtocolIsContainerTarget(
              target) then
            local page: int =
              inv_overhaul_container_presenter.ContainerPresenterGetContainerPage()
            local targetVisual: int = page * ContainerSlots +
              inv_overhaul_container_protocol.ContainerProtocolGetContainerSlot(
                target)
            if inv_overhaul_container_projection.ContainerProjectionSwapVisuals(
              containerVisual, targetVisual) then
              inv_overhaul_container_presenter.ContainerPresenterUpdateContainerSlots()
            end
          end
        end
      end
    end
    ContainerDragControllerSetHighlightedTarget(-1)
    ContainerDragControllerEndCursor()
    ContainerDragControllerCancelPageHover(0)
  end
end
