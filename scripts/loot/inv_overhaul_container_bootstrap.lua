import "inv_overhaul_inventory_layout_runtime"
import "inv_overhaul_inventory_snapshot"
import "inv_overhaul_container_presenter"
import "inv_overhaul_inventory_items"

module inv_overhaul_container_bootstrap do
  local const InventoryCapacity: int = 56

  local initialSlotLoadPending: bool
  local initialSlotLoadDelay: float
  local initialMetadataStage: int

  function LootBootstrapInitializeState() -> void
    initialSlotLoadPending = true
    initialSlotLoadDelay = 0.05
    initialMetadataStage = 0
  end

  function InitializePersistentPlayerSnapshot() -> void
    if inv_overhaul_inventory_snapshot.CanReusePersistent() then
      inv_overhaul_inventory_snapshot.CapturePrevious()
      return
    end
    local currentCount: int =
      inv_overhaul_inventory_snapshot.CaptureCurrentCount()
    if currentCount > InventoryCapacity then currentCount = InventoryCapacity end
    local loaded: bool =
      inv_overhaul_inventory_snapshot.LoadPersistent()
    local changed: bool = false
    if loaded then
      changed =
        inv_overhaul_inventory_snapshot.Differs(currentCount)
    end
    if changed then
      local oldCount: int =
        inv_overhaul_inventory_snapshot.GetLastBackpackItemCount()
      local visibleSlots: int =
        inv_overhaul_container_presenter.LootPresenterGetVisibleSlots()
      inv_overhaul_inventory_snapshot.Reconcile(
        currentCount, visibleSlots)
      inv_overhaul_inventory_layout_runtime.QueueSave()
      native.Trace("inv_overhaul_container persistent snapshot reconciled old=" +
        oldCount + " current=" + currentCount)
    end
    inv_overhaul_inventory_snapshot.CopyCurrent(currentCount)
    -- Persist after the fallback comparison so saves without the content
    -- generation stamp are migrated only after their IDs are checked.
    inv_overhaul_inventory_snapshot.SavePersistent()
    if !loaded then
      native.Trace("inv_overhaul_container persistent snapshot initialized count=" +
        currentCount)
    end
  end

  function LootBootstrapOrderFreeCellsByDisplay() -> void
    local itemCount: int =
      inv_overhaul_inventory_items.GetBackpackCount()
    local visibleSlots: int =
      inv_overhaul_container_presenter.LootPresenterGetVisibleSlots()
    if inv_overhaul_inventory_layout_runtime.LayoutRuntimeOrderFreeCellsByDisplay(
      itemCount, visibleSlots) then
      inv_overhaul_inventory_layout_runtime.QueueSave()
    end
  end

  function LootBootstrapAdvance(delta: float) -> void
    if !initialSlotLoadPending then return end
    initialSlotLoadDelay = initialSlotLoadDelay - delta
    if initialSlotLoadDelay > 0 then return end
    if initialMetadataStage == 0 then
      if inv_overhaul_inventory_layout_runtime.ContinueIncrementalLoad(
        -1) then
        initialMetadataStage = 1
        initialSlotLoadDelay = 0.01
      else
        initialSlotLoadDelay = 0
      end
      return
    end
    if initialMetadataStage == 1 then
      InitializePersistentPlayerSnapshot()
      initialMetadataStage = 2
      initialSlotLoadDelay = 0.01
      return
    end
    LootBootstrapOrderFreeCellsByDisplay()
    initialSlotLoadPending = false
    inv_overhaul_container_presenter.LootPresenterBeginInitialSlotLoad()
  end
end
