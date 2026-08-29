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

  function ContainerInputInitializeState() -> void
    shiftHeld = false
    controlHeld = false
  end

  function ContainerInputAssignHoveredQuickslot(slot: int) -> void
    if inv_overhaul_container_drag.ContainerDragIsActive() then return end
    local target: int =
      inv_overhaul_container_drag.ContainerDragGetHighlightedTarget()
    if target < 0 then
      target = inv_overhaul_inventory_tooltip.InventoryTooltipGetTarget()
    end
    local visibleSlots: int =
      inv_overhaul_container_presenter.ContainerPresenterGetVisibleSlots()
    if target < 0 || target >= visibleSlots then return end
    local reference: int =
      inv_overhaul_container_presenter.ContainerPresenterResolveVisibleSlot(target)
    if reference < 0 then return end
    local category: int =
      inv_overhaul_inventory_items.InventoryItemsDecodeReferenceCategory(reference)
    local index: int =
      inv_overhaul_inventory_items.InventoryItemsDecodeReferenceIndex(reference)
    if inv_overhaul_inventory_quickslot_bindings.InventoryQuickslotAssign(
      slot, category, index, false) then
      inv_overhaul_container_presenter.ContainerPresenterUpdatePlayerSlots()
    end
  end

  function ContainerInputHandleModifiedDrop(source: int) -> bool
    if !shiftHeld && !controlHeld then return false end
    local visibleSlots: int =
      inv_overhaul_container_presenter.ContainerPresenterGetVisibleSlots()
    if source < 0 || source >= visibleSlots then return false end
    local reference: int =
      inv_overhaul_container_presenter.ContainerPresenterResolveVisibleSlot(source)
    if reference < 0 then return true end
    if controlHeld && !shiftHeld then
      inv_overhaul_container_player_actions.ContainerPlayerActionsMoveSlotToOtherPage(
        source)
      return true
    end
    local amount: int
    local player: object =
      inv_overhaul_inventory_items.InventoryItemsGetPlayerContainer()
    local category: int =
      inv_overhaul_inventory_items.InventoryItemsDecodeReferenceCategory(reference)
    local index: int =
      inv_overhaul_inventory_items.InventoryItemsDecodeReferenceIndex(reference)
    player->GetItemAmount(amount, index, category)
    inv_overhaul_container_player_actions.ContainerPlayerActionsDropToWorld(
      source, amount)
    return true
  end

  function ContainerInputStartPanelPointerDrag(x: int, y: int) -> void
    local source: int =
      inv_overhaul_container_drag_controller.ContainerDragControllerFindTargetAt(
        x, y)
    if source < 0 then return end
    if ContainerInputHandleModifiedDrop(source) then return end
    inv_overhaul_container_drag_controller.ContainerDragControllerStart(source)
  end

  function ContainerInputHandlePanelPointer(message: int) -> void
    local action: int =
      inv_overhaul_container_protocol.ContainerProtocolGetPanelPointerAction(message)
    if action < 0 then
      inv_overhaul_container_tooltip_controller.ContainerTooltipClear()
      inv_overhaul_container_view.ContainerViewClearPageControlHover()
      return
    end
    local base: int =
      inv_overhaul_container_protocol.ContainerProtocolGetPanelPointerBase(message)
    local x: int =
      inv_overhaul_container_geometry.ContainerGeometryDecodePanelPointerX(
        message, base)
    local y: int =
      inv_overhaul_container_geometry.ContainerGeometryDecodePanelPointerY(
        message, base)
    if action == 0 then
      inv_overhaul_container_paging_controller.ContainerPagingUpdateControlHover(
        x, y)
      local windowWidth: int =
        inv_overhaul_container_presenter.ContainerPresenterGetWindowWidth()
      local visibleSlots: int =
        inv_overhaul_container_presenter.ContainerPresenterGetVisibleSlots()
      local playerPage: int =
        inv_overhaul_container_presenter.ContainerPresenterGetPlayerPage()
      local containerPage: int =
        inv_overhaul_container_presenter.ContainerPresenterGetContainerPage()
      local showOrgans: bool =
        inv_overhaul_container_presenter.ContainerPresenterShowsOrgans()
      local maxPlayerPage: int =
        inv_overhaul_container_presenter.ContainerPresenterGetMaxPlayerPage()
      inv_overhaul_container_tooltip_controller.ContainerTooltipUpdate(
        windowWidth, visibleSlots, playerPage, containerPage, showOrgans,
        maxPlayerPage, x, y)
    end
    if action == 1 then
      inv_overhaul_container_tooltip_controller.ContainerTooltipClear()
      if inv_overhaul_container_paging_controller.ContainerPagingHandleControlAt(
        x, y) then return end
      ContainerInputStartPanelPointerDrag(x, y)
      return
    end
    if action == 2 then
      local source: int =
        inv_overhaul_container_drag_controller.ContainerDragControllerFindTargetAt(
          x, y)
      local wholeStack: bool = shiftHeld
      inv_overhaul_container_quick_transfer.ContainerQuickTransferExecute(
        source, wholeStack)
      return
    end
    local target: int =
      inv_overhaul_container_drag_controller.ContainerDragControllerFindTargetAt(
        x, y)
    if action == 3 then
      inv_overhaul_container_drag_controller.ContainerDragControllerApplyPointerTarget(
        target)
      inv_overhaul_container_drag_controller.ContainerDragControllerFinish(target)
      return
    end
    if inv_overhaul_container_drag.ContainerDragIsActive() then
      inv_overhaul_container_drag_controller.ContainerDragControllerApplyPointerTarget(
        target)
    end
  end

  function ContainerInputHandleLifecycleMessage(
    message: int,
    sender: string) -> bool
    if message == inv_overhaul_container_protocol.ContainerQuickslotHelpHover &&
      sender == "panel_background" then
      inv_overhaul_container_tooltip_controller.ContainerTooltipShowQuickslotHelp()
      return true
    end
    if message == inv_overhaul_container_protocol.ContainerGridRendererReady then
      native.SendMessage(-201, "panel_background")
      return true
    end
    if message == inv_overhaul_container_protocol.ContainerPageHoverEnter then
      inv_overhaul_container_paging_controller.ContainerPagingBeginDragHover(sender)
      return true
    end
    if message == inv_overhaul_container_protocol.ContainerPageHoverLeave then
      local action: int =
        inv_overhaul_container_paging_controller.ContainerPagingGetDragHoverAction(
          sender)
      inv_overhaul_container_drag_controller.ContainerDragControllerCancelPageHover(
        action)
      return true
    end
    if message == -100 && sender == "corpse_marker" then
      inv_overhaul_container_session.ContainerSessionActivateCorpseMode()
      native.SendMessage(-120, "corpse_marker")
      return true
    end
    return false
  end

  function ContainerInputHandlePagingMessage(
    message: int,
    sender: string) -> bool
    if sender == "player_page_prev" && message == 0 then
      local page: int =
        inv_overhaul_container_presenter.ContainerPresenterGetPlayerPage()
      if page > 0 then
        inv_overhaul_container_presenter.ContainerPresenterChangePlayerPage(-1)
      end
      return true
    end
    if sender == "player_page_next" && message == 0 then
      local page: int =
        inv_overhaul_container_presenter.ContainerPresenterGetPlayerPage()
      local maxPage: int =
        inv_overhaul_container_presenter.ContainerPresenterGetMaxPlayerPage()
      if page < maxPage then
        inv_overhaul_container_presenter.ContainerPresenterChangePlayerPage(1)
      end
      return true
    end
    if sender == "container_page_prev" && message == 0 then
      local page: int =
        inv_overhaul_container_presenter.ContainerPresenterGetContainerPage()
      if page > 0 then
        inv_overhaul_container_presenter.ContainerPresenterChangeContainerPage(-1)
      end
      return true
    end
    if sender == "container_page_next" && message == 0 then
      local page: int =
        inv_overhaul_container_presenter.ContainerPresenterGetContainerPage()
      local maxPage: int =
        inv_overhaul_container_projection.ContainerProjectionGetMaxPage()
      if page < maxPage then
        inv_overhaul_container_presenter.ContainerPresenterChangeContainerPage(1)
      end
      return true
    end
    return false
  end

  function ContainerInputGetSlotPointerTarget(
    message: int,
    base: int,
    sender: string) -> int
    local visibleSlots: int =
      inv_overhaul_container_presenter.ContainerPresenterGetVisibleSlots()
    local windowWidth: int =
      inv_overhaul_container_presenter.ContainerPresenterGetWindowWidth()
    return inv_overhaul_container_protocol.ContainerProtocolGetSlotTargetFromPointerMessage(
      message, base, sender, visibleSlots, windowWidth)
  end

  function ContainerInputHandleSlotPointerMessage(
    message: int,
    sender: string) -> bool
    local action: int =
      inv_overhaul_container_protocol.ContainerProtocolGetSlotPointerAction(message)
    local base: int =
      inv_overhaul_container_protocol.ContainerProtocolGetSlotPointerBase(message)
    if action == 3 || action == 2 then
      local target: int = ContainerInputGetSlotPointerTarget(message, base, sender)
      inv_overhaul_container_drag_controller.ContainerDragControllerApplyPointerTarget(
        target)
      inv_overhaul_container_drag_controller.ContainerDragControllerFinish(target)
      return true
    end
    if action == 1 then
      local target: int = ContainerInputGetSlotPointerTarget(message, base, sender)
      if inv_overhaul_container_drag.ContainerDragIsActive() then
        inv_overhaul_container_drag_controller.ContainerDragControllerApplyPointerTarget(
          target)
      else
        inv_overhaul_container_drag_controller.ContainerDragControllerSetHighlightedTarget(
          target)
      end
      return true
    end
    return false
  end

  function ContainerInputHandleDragLifecycleMessage(
    message: int,
    sender: string) -> bool
    if message == 2 || message == 3 then
      local source: int =
        inv_overhaul_container_drag_controller.ContainerDragControllerGetTargetBySender(
          sender)
      if ContainerInputHandleModifiedDrop(source) then return true end
      inv_overhaul_container_drag_controller.ContainerDragControllerStart(source)
      return true
    end
    if message == 7 then
      if inv_overhaul_container_drag.ContainerDragIsActive() then
        inv_overhaul_container_drag_controller.ContainerDragControllerApplyPointerTarget(
          -1)
      else
        inv_overhaul_container_drag_controller.ContainerDragControllerSetHighlightedTarget(
          -1)
      end
      return true
    end
    if message == 8 then
      local target: int =
        inv_overhaul_container_drag.ContainerDragGetHighlightedTarget()
      inv_overhaul_container_drag_controller.ContainerDragControllerFinish(target)
      return true
    end
    return false
  end

  function ContainerInputHandleRegularSlotMessage(
    message: int,
    sender: string,
    data: object) -> bool
    if message == 1 && !data then
      local source: int =
        inv_overhaul_container_drag_controller.ContainerDragControllerGetTargetBySender(
          sender)
      local wholeStack: bool = shiftHeld
      inv_overhaul_container_quick_transfer.ContainerQuickTransferExecute(
        source, wholeStack)
      return true
    end
    return false
  end

  function ContainerInputHandleUIMessage(
    message: int,
    sender: string,
    data: object) -> void
    if ContainerInputHandleLifecycleMessage(message, sender) then return end
    if sender == "panel_background" &&
      inv_overhaul_container_protocol.ContainerProtocolIsPanelPointerMessage(
        message) then
      ContainerInputHandlePanelPointer(message)
      return
    end
    if ContainerInputHandlePagingMessage(message, sender) then return end
    if ContainerInputHandleSlotPointerMessage(message, sender) then return end
    if ContainerInputHandleDragLifecycleMessage(message, sender) then return end
    ContainerInputHandleRegularSlotMessage(message, sender, data)
  end

  function ContainerInputPersistAndClose() -> void
    if inv_overhaul_inventory_layout_runtime.InventoryLayoutRuntimeHasQueuedSave() then
      inv_overhaul_inventory_layout_runtime.InventoryLayoutRuntimeSaveAll()
    end
    inv_overhaul_inventory_snapshot.InventorySnapshotPersistCurrent()
    inv_overhaul_container_session.ContainerSessionCloseWindow()
  end

  function ContainerInputHandleChar(char: int) -> void
    if char >= 48 && char <= 57 then return end
    ContainerInputPersistAndClose()
  end

  function ContainerInputHandleKeyDown(key: int) -> void
    if key == VKShift then shiftHeld = true end
    if key == VKControl then controlHeld = true end
    local quickslot: int =
      inv_overhaul_inventory_quickslot_bindings.InventoryQuickslotGetSlotByKey(key)
    if quickslot > 0 then
      ContainerInputAssignHoveredQuickslot(quickslot)
      return
    end
    if key == 27 || key == 73 || key == 105 then
      ContainerInputPersistAndClose()
    end
  end

  function ContainerInputHandleKeyUp(key: int) -> void
    if key == VKShift then shiftHeld = false end
    if key == VKControl then controlHeld = false end
  end
end
