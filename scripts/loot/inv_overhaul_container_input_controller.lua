import "inv_overhaul_inventory_layout_runtime"
import "inv_overhaul_inventory_snapshot"
import "inv_overhaul_container_drag"
import "inv_overhaul_container_drag_controller"
import "inv_overhaul_container_geometry"
import "inv_overhaul_container_paging_controller"
import "inv_overhaul_container_player_actions"
import "inv_overhaul_container_presenter"
import "inv_overhaul_container_projection"
import "inv_overhaul_container_protocol"
import "inv_overhaul_container_quick_transfer"
import "inv_overhaul_container_session"
import "inv_overhaul_container_tooltip_controller"
import "inv_overhaul_container_view"
import "inv_overhaul_inventory_tooltip"
import "inv_overhaul_inventory_items"
import "inv_overhaul_inventory_quickslot_bindings"

module inv_overhaul_container_input_controller do
  local const VKShift: int = 16
  local const VKControl: int = 17

  local shiftHeld: bool
  local controlHeld: bool

  function LootInputInitializeState() -> void
    shiftHeld = false
    controlHeld = false
  end

  function LootInputAssignHoveredQuickslot(slot: int) -> void
    if inv_overhaul_container_drag.LootDragIsActive() then return end
    local target: int =
      inv_overhaul_container_drag.LootDragGetHighlightedTarget()
    if target < 0 then
      target = inv_overhaul_inventory_tooltip.GetTarget()
    end
    local visibleSlots: int =
      inv_overhaul_container_presenter.LootPresenterGetVisibleSlots()
    if target < 0 || target >= visibleSlots then return end
    local reference: int =
      inv_overhaul_container_presenter.LootPresenterResolveVisibleSlot(target)
    if reference < 0 then return end
    local category: int =
      inv_overhaul_inventory_items.DecodeReferenceCategory(reference)
    local index: int =
      inv_overhaul_inventory_items.DecodeReferenceIndex(reference)
    if inv_overhaul_inventory_quickslot_bindings.Assign(
      slot, category, index, false) then
      inv_overhaul_container_presenter.UpdatePlayerSlots()
    end
  end

  function LootInputHandleModifiedDrop(source: int) -> bool
    if !shiftHeld && !controlHeld then return false end
    local visibleSlots: int =
      inv_overhaul_container_presenter.LootPresenterGetVisibleSlots()
    if source < 0 || source >= visibleSlots then return false end
    local reference: int =
      inv_overhaul_container_presenter.LootPresenterResolveVisibleSlot(source)
    if reference < 0 then return true end
    if controlHeld && !shiftHeld then
      inv_overhaul_container_player_actions.LootPlayerActionsMoveSlotToOtherPage(
        source)
      return true
    end
    local amount: int
    local player: object =
      inv_overhaul_inventory_items.ItemsGetPlayerContainer()
    local category: int =
      inv_overhaul_inventory_items.DecodeReferenceCategory(reference)
    local index: int =
      inv_overhaul_inventory_items.DecodeReferenceIndex(reference)
    player->GetItemAmount(amount, index, category)
    inv_overhaul_container_player_actions.DropToWorld(
      source, amount)
    return true
  end

  function LootInputStartPanelPointerDrag(x: int, y: int) -> void
    local source: int =
      inv_overhaul_container_drag_controller.LootDragControllerFindTargetAt(
        x, y)
    if source < 0 then return end
    if LootInputHandleModifiedDrop(source) then return end
    inv_overhaul_container_drag_controller.Start(source)
  end

  function LootInputHandlePanelPointer(message: int) -> void
    local action: int =
      inv_overhaul_container_protocol.GetPanelPointerAction(message)
    if action < 0 then
      inv_overhaul_container_tooltip_controller.LootTooltipClear()
      inv_overhaul_container_view.ClearPageControlHover()
      return
    end
    local base: int =
      inv_overhaul_container_protocol.GetPanelPointerBase(message)
    local x: int =
      inv_overhaul_container_geometry.LootGeometryDecodePanelPointerX(
        message, base)
    local y: int =
      inv_overhaul_container_geometry.LootGeometryDecodePanelPointerY(
        message, base)
    if action == 0 then
      inv_overhaul_container_paging_controller.UpdateControlHover(
        x, y)
      local windowWidth: int =
        inv_overhaul_container_presenter.GetWindowWidth()
      local visibleSlots: int =
        inv_overhaul_container_presenter.LootPresenterGetVisibleSlots()
      local playerPage: int =
        inv_overhaul_container_presenter.GetPlayerPage()
      local containerPage: int =
        inv_overhaul_container_presenter.GetContainerPage()
      local showOrgans: bool =
        inv_overhaul_container_presenter.LootPresenterShowsOrgans()
      local maxPlayerPage: int =
        inv_overhaul_container_presenter.GetMaxPlayerPage()
      inv_overhaul_container_tooltip_controller.Update(
        windowWidth, visibleSlots, playerPage, containerPage, showOrgans,
        maxPlayerPage, x, y)
    end
    if action == 1 then
      inv_overhaul_container_tooltip_controller.LootTooltipClear()
      if inv_overhaul_container_paging_controller.HandleControlAt(
        x, y) then return end
      LootInputStartPanelPointerDrag(x, y)
      return
    end
    if action == 2 then
      local source: int =
        inv_overhaul_container_drag_controller.LootDragControllerFindTargetAt(
          x, y)
      local wholeStack: bool = shiftHeld
      inv_overhaul_container_quick_transfer.Execute(
        source, wholeStack)
      return
    end
    local target: int =
      inv_overhaul_container_drag_controller.LootDragControllerFindTargetAt(
        x, y)
    if action == 3 then
      inv_overhaul_container_drag_controller.LootDragControllerApplyPointerTarget(
        target)
      inv_overhaul_container_drag_controller.Finish(target)
      return
    end
    if inv_overhaul_container_drag.LootDragIsActive() then
      inv_overhaul_container_drag_controller.LootDragControllerApplyPointerTarget(
        target)
    end
  end

  function HandleLifecycleMessage(
    message: int,
    sender: string) -> bool
    if message == inv_overhaul_container_protocol.ContainerQuickslotHelpHover &&
      sender == "panel_background" then
      inv_overhaul_container_tooltip_controller.ShowQuickslotHelp()
      return true
    end
    if message == inv_overhaul_container_protocol.ContainerGridRendererReady then
      native.SendMessage(-201, "panel_background")
      return true
    end
    if message == inv_overhaul_container_protocol.ContainerPageHoverEnter then
      inv_overhaul_container_paging_controller.BeginDragHover(sender)
      return true
    end
    if message == inv_overhaul_container_protocol.ContainerPageHoverLeave then
      local action: int =
        inv_overhaul_container_paging_controller.GetDragHoverAction(
          sender)
      inv_overhaul_container_drag_controller.CancelPageHover(
        action)
      return true
    end
    if message == -100 && sender == "corpse_marker" then
      inv_overhaul_container_session.ActivateCorpseMode()
      native.SendMessage(-120, "corpse_marker")
      return true
    end
    return false
  end

  function HandlePagingMessage(
    message: int,
    sender: string) -> bool
    if sender == "player_page_prev" && message == 0 then
      local page: int =
        inv_overhaul_container_presenter.GetPlayerPage()
      if page > 0 then
        inv_overhaul_container_presenter.ChangePlayerPage(-1)
      end
      return true
    end
    if sender == "player_page_next" && message == 0 then
      local page: int =
        inv_overhaul_container_presenter.GetPlayerPage()
      local maxPage: int =
        inv_overhaul_container_presenter.GetMaxPlayerPage()
      if page < maxPage then
        inv_overhaul_container_presenter.ChangePlayerPage(1)
      end
      return true
    end
    if sender == "container_page_prev" && message == 0 then
      local page: int =
        inv_overhaul_container_presenter.GetContainerPage()
      if page > 0 then
        inv_overhaul_container_presenter.ChangeContainerPage(-1)
      end
      return true
    end
    if sender == "container_page_next" && message == 0 then
      local page: int =
        inv_overhaul_container_presenter.GetContainerPage()
      local maxPage: int =
        inv_overhaul_container_projection.LootProjectionGetMaxPage()
      if page < maxPage then
        inv_overhaul_container_presenter.ChangeContainerPage(1)
      end
      return true
    end
    return false
  end

  function GetSlotPointerTarget(
    message: int,
    base: int,
    sender: string) -> int
    local visibleSlots: int =
      inv_overhaul_container_presenter.LootPresenterGetVisibleSlots()
    local windowWidth: int =
      inv_overhaul_container_presenter.GetWindowWidth()
    return inv_overhaul_container_protocol.LootProtocolGetSlotTargetFromPointerMessage(
      message, base, sender, visibleSlots, windowWidth)
  end

  function HandleSlotPointerMessage(
    message: int,
    sender: string) -> bool
    local action: int =
      inv_overhaul_container_protocol.GetSlotPointerAction(message)
    local base: int =
      inv_overhaul_container_protocol.GetSlotPointerBase(message)
    if action == 3 || action == 2 then
      local target: int = GetSlotPointerTarget(message, base, sender)
      inv_overhaul_container_drag_controller.LootDragControllerApplyPointerTarget(
        target)
      inv_overhaul_container_drag_controller.Finish(target)
      return true
    end
    if action == 1 then
      local target: int = GetSlotPointerTarget(message, base, sender)
      if inv_overhaul_container_drag.LootDragIsActive() then
        inv_overhaul_container_drag_controller.LootDragControllerApplyPointerTarget(
          target)
      else
        inv_overhaul_container_drag_controller.LootDragControllerSetHighlightedTarget(
          target)
      end
      return true
    end
    return false
  end

  function LootInputHandleDragLifecycleMessage(
    message: int,
    sender: string) -> bool
    if message == 2 || message == 3 then
      local source: int =
        inv_overhaul_container_drag_controller.LootDragControllerGetTargetBySender(
          sender)
      if LootInputHandleModifiedDrop(source) then return true end
      inv_overhaul_container_drag_controller.Start(source)
      return true
    end
    if message == 7 then
      if inv_overhaul_container_drag.LootDragIsActive() then
        inv_overhaul_container_drag_controller.LootDragControllerApplyPointerTarget(
          -1)
      else
        inv_overhaul_container_drag_controller.LootDragControllerSetHighlightedTarget(
          -1)
      end
      return true
    end
    if message == 8 then
      local target: int =
        inv_overhaul_container_drag.LootDragGetHighlightedTarget()
      inv_overhaul_container_drag_controller.Finish(target)
      return true
    end
    return false
  end

  function LootInputHandleRegularSlotMessage(
    message: int,
    sender: string,
    data: object) -> bool
    if message == 1 && !data then
      local source: int =
        inv_overhaul_container_drag_controller.LootDragControllerGetTargetBySender(
          sender)
      local wholeStack: bool = shiftHeld
      inv_overhaul_container_quick_transfer.Execute(
        source, wholeStack)
      return true
    end
    return false
  end

  function HandleUIMessage(
    message: int,
    sender: string,
    data: object) -> void
    if HandleLifecycleMessage(message, sender) then return end
    if sender == "panel_background" &&
      inv_overhaul_container_protocol.IsPanelPointerMessage(
        message) then
      LootInputHandlePanelPointer(message)
      return
    end
    if HandlePagingMessage(message, sender) then return end
    if HandleSlotPointerMessage(message, sender) then return end
    if LootInputHandleDragLifecycleMessage(message, sender) then return end
    LootInputHandleRegularSlotMessage(message, sender, data)
  end

  function PersistAndClose() -> void
    if inv_overhaul_inventory_layout_runtime.HasQueuedSave() then
      inv_overhaul_inventory_layout_runtime.SaveAll()
    end
    inv_overhaul_inventory_snapshot.PersistCurrent()
    inv_overhaul_container_session.CloseWindow()
  end

  function HandleChar(char: int) -> void
    if char >= 48 && char <= 57 then return end
    PersistAndClose()
  end

  function HandleKeyDown(key: int) -> void
    if key == VKShift then shiftHeld = true end
    if key == VKControl then controlHeld = true end
    local quickslot: int =
      inv_overhaul_inventory_quickslot_bindings.GetSlotByKey(key)
    if quickslot > 0 then
      LootInputAssignHoveredQuickslot(quickslot)
      return
    end
    if key == 27 || key == 73 || key == 105 then
      PersistAndClose()
    end
  end

  function HandleKeyUp(key: int) -> void
    if key == VKShift then shiftHeld = false end
    if key == VKControl then controlHeld = false end
  end
end
