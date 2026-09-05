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
import "inv_overhaul_inventory_sounds"

maintask InvOverhaulContainerUI do
  local const ScriptVersion: string = "2026.08.17-native-occupied-slot-exchange-1"
  local const OrganSlots: int = 4

  function init() -> void
    native.Trace("INV_OVERHAUL_INVENTORY_VERSION " + ScriptVersion +
      " screen=container")

    inv_overhaul_container_presenter.LootPresenterInitializeState()
    inv_overhaul_container_session.LootSessionInitializeState()
    inv_overhaul_container_feedback.LootFeedbackInitializeState()
    inv_overhaul_container_bootstrap.LootBootstrapInitializeState()
    inv_overhaul_container_input_controller.LootInputInitializeState()
    inv_overhaul_container_drag.LootDragInitializeState()
    inv_overhaul_inventory_tooltip.InterfaceTooltipInitializeState()
    inv_overhaul_inventory_quickslot_bindings.QuickslotBindingsInitializeState()
    inv_overhaul_inventory_quickslot_bindings.InitializeBindings()
    inv_overhaul_inventory_quickslot_bindings.RefreshCache()

    native.SetVariable("inv_overhaul_inventory_drag_item", -1)
    native.SetVariable("inv_overhaul_inventory_page_hover", 0)
    native.SetCursor("inv_overhaul_inventory")
    native.ShowCursor()
    native.CaptureKeyboard()
    native.SetOwnerDraw(false)
    native.SetNeedUpdate(true)

    inv_overhaul_inventory_tooltip.InitializeMoneyItem()
    inv_overhaul_container_transfer_external.ExternalTransferInitializeState()
    inv_overhaul_inventory_snapshot.SnapshotInitializeState()
    inv_overhaul_inventory_layout_runtime.LayoutRuntimeInitialize()
    inv_overhaul_inventory_items.InitializeProjection()
    inv_overhaul_container_projection.LootProjectionInitialize()

    -- Hide organ forms before the first event pass so ordinary containers do
    -- not render the corpse-only slots for one frame.
    for organSlot = 0, OrganSlots - 1 do
      native.SendMessage(
        -22,
        inv_overhaul_container_view.GetOrganSlotWndName(organSlot))
    end
    inv_overhaul_container_presenter.LootPresenterUpdateLayout()
    native.SendMessage(-201, "panel_background")
    inv_overhaul_container_session.DetectContainerKind()
    inv_overhaul_container_presenter.UpdatePlayerPageControls()
    inv_overhaul_container_presenter.UpdateContainerPageControls()
    inv_overhaul_inventory_sounds.InventorySoundsPlayOpen()
    native.ProcessEvents()
  end

  function OnUIMessage(message: int, sender: string, data: object) -> void
    inv_overhaul_container_input_controller.HandleUIMessage(
      message, sender, data)
  end

  function OnUpdate(delta: float) -> void
    inv_overhaul_inventory_tooltip.AdvanceSuspension(delta)
    inv_overhaul_container_feedback.LootFeedbackAdvance(delta)
    inv_overhaul_container_presenter.LootPresenterUpdateLayout()
    inv_overhaul_container_bootstrap.LootBootstrapAdvance(delta)
    inv_overhaul_container_presenter.LootPresenterContinueInitialSlotLoad()
    inv_overhaul_container_presenter.ContinueCachedPlayerEntryRefresh()
    inv_overhaul_inventory_layout_runtime.ContinueQueuedSave()
    inv_overhaul_container_presenter.AdvanceMoneyPolling(delta)
    inv_overhaul_container_session.LootSessionAdvance(delta)
    inv_overhaul_container_paging_controller.SyncDragHoverFromCursor()
    inv_overhaul_container_paging_controller.UpdateDragHover(delta)
  end

  function OnMouseMove(x: int, y: int) -> void
    if inv_overhaul_container_drag.LootDragIsActive() then
      local target: int =
        inv_overhaul_container_drag_controller.LootDragControllerFindTargetAt(
          x, y)
      inv_overhaul_container_drag_controller.LootDragControllerApplyPointerTarget(
        target)
    end
  end

  function OnMouseLeave() -> void
    if inv_overhaul_container_drag.LootDragIsActive() then
      inv_overhaul_container_drag_controller.LootDragControllerSetHighlightedTarget(
        -1)
    end
  end

  function OnLButtonUp(x: int, y: int) -> void
    if inv_overhaul_container_drag.LootDragIsActive() then
      local target: int =
        inv_overhaul_container_drag_controller.LootDragControllerFindTargetAt(
          x, y)
      inv_overhaul_container_drag_controller.LootDragControllerApplyPointerTarget(
        target)
      inv_overhaul_container_drag_controller.Finish(target)
    end
  end

  function OnChar(char: int) -> void
    inv_overhaul_container_input_controller.HandleChar(char)
  end

  function OnKeyDown(key: int) -> void
    inv_overhaul_container_input_controller.HandleKeyDown(key)
  end

  function OnKeyUp(key: int) -> void
    inv_overhaul_container_input_controller.HandleKeyUp(key)
  end
end
