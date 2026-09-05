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
import "inv_overhaul_inventory_sounds"

module inv_overhaul_container_drag_controller do
  local const ContainerSlots: int = 12

  function LootDragControllerGetTargetBySender(sender: string) -> int
    local visibleSlots: int =
      inv_overhaul_container_presenter.LootPresenterGetVisibleSlots()
    return inv_overhaul_container_protocol.LootProtocolGetTargetBySender(
      sender, visibleSlots)
  end

  function LootDragControllerFindTargetAt(x: int, y: int) -> int
    local windowWidth: int =
      inv_overhaul_container_presenter.GetWindowWidth()
    local visibleSlots: int =
      inv_overhaul_container_presenter.LootPresenterGetVisibleSlots()
    local showOrgans: bool =
      inv_overhaul_container_presenter.LootPresenterShowsOrgans()
    return inv_overhaul_container_protocol.LootProtocolFindTargetAt(
      windowWidth, visibleSlots, showOrgans, x, y)
  end

  function LootDragControllerIsTargetCompatible(target: int) -> bool
    local kind: int = inv_overhaul_container_drag.GetKind()
    local visibleSlots: int =
      inv_overhaul_container_presenter.LootPresenterGetVisibleSlots()
    return inv_overhaul_container_protocol.LootProtocolIsTargetCompatible(
      kind, target, visibleSlots)
  end

  function ResolveSource(source: int) -> bool
    local item: object
    local kind: int = -1
    local playerCategory: int = -1
    local playerIndex: int = -1
    local playerCell: int = -1
    local containerIndex: int = -1
    local containerOrdinal: int = -1
    local containerVisual: int = -1
    local visibleSlots: int =
      inv_overhaul_container_presenter.LootPresenterGetVisibleSlots()

    if inv_overhaul_container_protocol.IsPlayerTarget(
      source, visibleSlots) then
      local playerReference: int =
        inv_overhaul_container_presenter.LootPresenterResolveVisibleSlot(source)
      if playerReference < 0 then return false end
      kind = 0
      playerCategory =
        inv_overhaul_inventory_items.DecodeReferenceCategory(
          playerReference)
      playerIndex =
        inv_overhaul_inventory_items.DecodeReferenceIndex(
          playerReference)
      playerCell =
        inv_overhaul_container_presenter.LootPresenterGetVisibleCell(source)
      local player: object =
        inv_overhaul_inventory_items.ItemsGetPlayerContainer()
      player->GetItem(item, playerIndex, playerCategory)
    else
      local containerReference: int = -1
      if inv_overhaul_container_protocol.IsContainerTarget(source) then
        local containerSlot: int =
          inv_overhaul_container_protocol.GetContainerSlot(source)
        containerReference =
          inv_overhaul_container_presenter.ResolveContainerVisualSlot(
            containerSlot)
        if containerReference < 0 then return false end
        kind = 1
        local containerPage: int =
          inv_overhaul_container_presenter.GetContainerPage()
        containerVisual = containerPage * ContainerSlots + containerSlot
      else
        if inv_overhaul_container_protocol.IsOrganTarget(source) then
          local organSlot: int =
            inv_overhaul_container_protocol.GetOrganSlot(source)
          containerReference =
            inv_overhaul_container_presenter.ResolveOrganVisualSlot(
              organSlot)
          if containerReference < 0 then return false end
          kind = 2
        else
          return false
        end
      end
      containerIndex =
        inv_overhaul_container_projection.GetReferenceIndex(
          containerReference)
      containerOrdinal =
        inv_overhaul_container_projection.GetReferenceOrdinal(
          containerReference)
      local external: object
      native.GetContainer(external)
      external->GetItem(item, containerIndex)
    end
    if !item then return false end
    local itemID: int
    item->GetItemID(itemID)
    if kind == 0 then
      inv_overhaul_container_drag.BeginPlayerSource(
        source, itemID, playerCategory, playerIndex, playerCell)
    else
      inv_overhaul_container_drag.BeginExternalSource(
        source, kind, itemID, containerIndex, containerOrdinal, containerVisual)
    end
    return true
  end

  function BeginCursor(source: int) -> bool
    native.SetVariable("inv_overhaul_inventory_drag_item", -1)
    if !ResolveSource(source) then return false end
    local itemID: int = inv_overhaul_container_drag.LootDragGetItemID()
    native.SetVariable("inv_overhaul_inventory_drag_item", itemID)
    return true
  end

  function EndCursor() -> void
    native.SetVariable("inv_overhaul_inventory_drag_item", -1)
    native.SetVariable("inv_overhaul_inventory_page_hover", 0)
    inv_overhaul_container_drag.ClearSource()
  end

  function LootDragControllerSetHighlightedTarget(target: int) -> void
    if inv_overhaul_container_drag.LootDragIsActive() && target >= 0 &&
      !LootDragControllerIsTargetCompatible(target) then target = -1 end
    local previousTarget: int =
      inv_overhaul_container_drag.LootDragGetHighlightedTarget()
    if previousTarget == target then return end
    local visibleSlots: int =
      inv_overhaul_container_presenter.LootPresenterGetVisibleSlots()
    if previousTarget >= 0 then
      inv_overhaul_container_view.SetTargetHighlighted(
        previousTarget, visibleSlots, false)
    end
    inv_overhaul_container_drag.LootDragSetHighlightedTarget(target)
    if target >= 0 then
      inv_overhaul_container_view.SetTargetHighlighted(
        target, visibleSlots, true)
    end
  end

  function LootDragControllerApplyPointerTarget(target: int) -> void
    if !inv_overhaul_container_drag.LootDragIsActive() then return end
    local source: int = inv_overhaul_container_drag.GetSource()
    local kind: int = inv_overhaul_container_drag.GetKind()
    local sameSource: bool = false
    if target == source then sameSource = true end
    local visibleSlots: int =
      inv_overhaul_container_presenter.LootPresenterGetVisibleSlots()
    if kind == 0 &&
      inv_overhaul_container_protocol.IsPlayerTarget(
        target, visibleSlots) then
      local targetCell: int =
        inv_overhaul_container_presenter.LootPresenterGetVisibleCell(target)
      if targetCell == inv_overhaul_container_drag.GetPlayerCell() then
        sameSource = true
      else
        sameSource = false
      end
    end
    if kind == 1 &&
      inv_overhaul_container_protocol.IsContainerTarget(target) then
      local page: int =
        inv_overhaul_container_presenter.GetContainerPage()
      if page * ContainerSlots +
        inv_overhaul_container_protocol.GetContainerSlot(target) ==
        inv_overhaul_container_drag.GetContainerVisual() then
        sameSource = true
      else
        sameSource = false
      end
    end
    local compatible: bool = LootDragControllerIsTargetCompatible(target)
    local recordedTarget: int =
      inv_overhaul_container_drag.RecordPointerTarget(
        target, sameSource, compatible)
    LootDragControllerSetHighlightedTarget(recordedTarget)
  end

  function CancelPageHover(action: int) -> void
    if !inv_overhaul_container_drag.LootDragCanCancelPageHover(action) then return end
    local currentAction: int =
      inv_overhaul_container_drag.LootDragGetPageHoverAction()
    if currentAction != 0 then
      native.Trace("inv_overhaul_container page-hover cancel action=" +
        currentAction + " elapsed=" +
        inv_overhaul_container_drag.LootDragGetPageHoverElapsed())
    end
    inv_overhaul_container_drag.LootDragClearPageHover()
  end

  function Start(source: int) -> void
    if inv_overhaul_container_drag.LootDragIsActive() then return end
    CancelPageHover(0)
    inv_overhaul_container_tooltip_controller.LootTooltipClear()
    if !BeginCursor(source) then return end
    LootDragControllerSetHighlightedTarget(-1)
  end

  function Finish(target: int) -> void
    if !inv_overhaul_container_drag.LootDragIsActive() then return end
    target = inv_overhaul_container_drag.LootDragResolveReleaseTarget(target)
    local source: int = inv_overhaul_container_drag.GetSource()
    local sourceKind: int = inv_overhaul_container_drag.GetKind()
    local playerCell: int =
      inv_overhaul_container_drag.GetPlayerCell()
    local containerVisual: int =
      inv_overhaul_container_drag.GetContainerVisual()
    local visibleSlots: int =
      inv_overhaul_container_presenter.LootPresenterGetVisibleSlots()
    inv_overhaul_inventory_tooltip.Suspend(0.2)
    inv_overhaul_container_tooltip_controller.LootTooltipClear()
    if source >= 0 then
      native.SendMessage(
        -130,
        inv_overhaul_container_view.LootViewGetTargetWndName(
          source, visibleSlots))
    end
    if target >= 0 then
      native.SendMessage(
        -130,
        inv_overhaul_container_view.LootViewGetTargetWndName(
          target, visibleSlots))
    end

    if LootDragControllerIsTargetCompatible(target) then
      if sourceKind == 0 then
        if inv_overhaul_container_protocol.IsPlayerTarget(
          target, visibleSlots) then
          local targetCell: int =
            inv_overhaul_container_presenter.LootPresenterGetVisibleCell(target)
          if targetCell != playerCell then
            inv_overhaul_container_player_actions.LootPlayerActionsSwapCells(
              playerCell, targetCell)
          end
        else
          if inv_overhaul_container_protocol.IsContainerTarget(
            target) then
            inv_overhaul_container_transfer_player.ExchangeWithContainer(
              source,
              inv_overhaul_container_protocol.GetContainerSlot(
                target))
          end
        end
      else
        if inv_overhaul_container_protocol.IsPlayerTarget(
          target, visibleSlots) then
          if sourceKind == 1 then
            inv_overhaul_container_transfer_external.MoveToPlayer(
              false,
              inv_overhaul_container_protocol.GetContainerSlot(source),
              target, -1)
          else
            inv_overhaul_container_transfer_external.MoveToPlayer(
              true,
              inv_overhaul_container_protocol.GetOrganSlot(source),
              target, -1)
          end
        else
          if sourceKind == 1 &&
            inv_overhaul_container_protocol.IsContainerTarget(
              target) then
            local page: int =
              inv_overhaul_container_presenter.GetContainerPage()
            local targetVisual: int = page * ContainerSlots +
              inv_overhaul_container_protocol.GetContainerSlot(
                target)
            if inv_overhaul_container_projection.SwapVisuals(
              containerVisual, targetVisual) then
              inv_overhaul_inventory_sounds.InventorySoundsPlayItemEquip()
              inv_overhaul_container_presenter.UpdateContainerSlots()
            end
          end
        end
      end
    end
    LootDragControllerSetHighlightedTarget(-1)
    EndCursor()
    CancelPageHover(0)
  end
end
