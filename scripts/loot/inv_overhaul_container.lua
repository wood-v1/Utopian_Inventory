import "inv_overhaul_inventory_layout_runtime"
import "inv_overhaul_inventory_snapshot"
import "inv_overhaul_container_bootstrap"
import "inv_overhaul_container_drag"
import "inv_overhaul_container_drag_controller"
import "inv_overhaul_container_feedback"
import "inv_overhaul_container_input_controller"
import "inv_overhaul_container_paging_controller"
import "inv_overhaul_container_presenter"
import "inv_overhaul_container_projection"
import "inv_overhaul_container_session"
import "inv_overhaul_container_transfer_external"
import "inv_overhaul_container_view"
import "inv_overhaul_inventory_tooltip"
import "inv_overhaul_inventory_items"
import "inv_overhaul_inventory_quickslot_bindings"

maintask InvOverhaulContainerUI do
  local const ScriptVersion: string = "2026.08.17-native-occupied-slot-exchange-1"
  local const OrganSlots: int = 4

  function init() -> void
    native.Trace("INV_OVERHAUL_INVENTORY_VERSION " + ScriptVersion +
      " screen=container")

    inv_overhaul_container_presenter.ContainerPresenterInitializeState()
    inv_overhaul_container_session.ContainerSessionInitializeState()
    inv_overhaul_container_feedback.ContainerFeedbackInitializeState()
    inv_overhaul_container_bootstrap.ContainerBootstrapInitializeState()
    inv_overhaul_container_input_controller.ContainerInputInitializeState()
    inv_overhaul_container_drag.ContainerDragInitializeState()
    inv_overhaul_inventory_tooltip.InventoryTooltipInitializeState()
    inv_overhaul_inventory_quickslot_bindings.InventoryQuickslotInitializeState()
    inv_overhaul_inventory_quickslot_bindings.InventoryQuickslotInitializeBindings()
    inv_overhaul_inventory_quickslot_bindings.InventoryQuickslotRefreshCache()

    native.SetVariable("inv_overhaul_inventory_drag_item", -1)
    native.SetVariable("inv_overhaul_inventory_page_hover", 0)
    native.SetCursor("inv_overhaul_inventory")
    native.ShowCursor()
    native.CaptureKeyboard()
    native.SetOwnerDraw(false)
    native.SetNeedUpdate(true)

    inv_overhaul_inventory_tooltip.InventoryTooltipInitializeMoneyItem()
    inv_overhaul_container_transfer_external.ContainerExternalTransferInitializeState()
    inv_overhaul_inventory_snapshot.InventorySnapshotInitializeState()
    inv_overhaul_inventory_layout_runtime.InventoryLayoutRuntimeInitialize()
    inv_overhaul_inventory_items.InventoryItemsInitializeProjection()
    inv_overhaul_container_projection.ContainerProjectionInitialize()

    -- Hide organ forms before the first event pass so ordinary containers do
    -- not render the corpse-only slots for one frame.
    for organSlot = 0, OrganSlots - 1 do
      native.SendMessage(
        -22,
        inv_overhaul_container_view.ContainerViewGetOrganSlotWndName(organSlot))
    end
    inv_overhaul_container_presenter.ContainerPresenterUpdateLayout()
    native.SendMessage(-201, "panel_background")
    inv_overhaul_container_session.ContainerSessionDetectContainerKind()
    inv_overhaul_container_presenter.ContainerPresenterUpdatePlayerPageControls()
    inv_overhaul_container_presenter.ContainerPresenterUpdateContainerPageControls()
    native.ProcessEvents()
  end

  function OnUIMessage(message: int, sender: string, data: object) -> void
    inv_overhaul_container_input_controller.ContainerInputHandleUIMessage(
      message, sender, data)
  end

  function OnUpdate(delta: float) -> void
    inv_overhaul_inventory_tooltip.InventoryTooltipAdvanceSuspension(delta)
    inv_overhaul_container_feedback.ContainerFeedbackAdvance(delta)
    inv_overhaul_container_presenter.ContainerPresenterUpdateLayout()
    inv_overhaul_container_bootstrap.ContainerBootstrapAdvance(delta)
    inv_overhaul_container_presenter.ContainerPresenterContinueInitialSlotLoad()
    inv_overhaul_container_presenter.ContainerPresenterContinueCachedPlayerEntryRefresh()
    inv_overhaul_inventory_layout_runtime.InventoryLayoutRuntimeContinueQueuedSave()
    inv_overhaul_container_presenter.ContainerPresenterAdvanceMoneyPolling(delta)
    inv_overhaul_container_session.ContainerSessionAdvance(delta)
    inv_overhaul_container_paging_controller.ContainerPagingSyncDragHoverFromCursor()
    inv_overhaul_container_paging_controller.ContainerPagingUpdateDragHover(delta)
  end

  function OnMouseMove(x: int, y: int) -> void
    if inv_overhaul_container_drag.ContainerDragIsActive() then
      local target: int =
        inv_overhaul_container_drag_controller.ContainerDragControllerFindTargetAt(
          x, y)
      inv_overhaul_container_drag_controller.ContainerDragControllerApplyPointerTarget(
        target)
    end
  end

  function OnMouseLeave() -> void
    if inv_overhaul_container_drag.ContainerDragIsActive() then
      inv_overhaul_container_drag_controller.ContainerDragControllerSetHighlightedTarget(
        -1)
    end
  end

  function OnLButtonUp(x: int, y: int) -> void
    if inv_overhaul_container_drag.ContainerDragIsActive() then
      local target: int =
        inv_overhaul_container_drag_controller.ContainerDragControllerFindTargetAt(
          x, y)
      inv_overhaul_container_drag_controller.ContainerDragControllerApplyPointerTarget(
        target)
      inv_overhaul_container_drag_controller.ContainerDragControllerFinish(target)
    end
  end

  function OnChar(char: int) -> void
    inv_overhaul_container_input_controller.ContainerInputHandleChar(char)
  end

  function OnKeyDown(key: int) -> void
    inv_overhaul_container_input_controller.ContainerInputHandleKeyDown(key)
  end

  function OnKeyUp(key: int) -> void
    inv_overhaul_container_input_controller.ContainerInputHandleKeyUp(key)
  end
end
