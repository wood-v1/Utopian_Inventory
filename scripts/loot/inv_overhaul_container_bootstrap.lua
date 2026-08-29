import "inv_overhaul_inventory_layout_runtime"
import "inv_overhaul_inventory_snapshot"
import "inv_overhaul_container_presenter"
import "inv_overhaul_inventory_items"

module inv_overhaul_container_bootstrap do
  local const InventoryCapacity: int = 56

  local initialSlotLoadPending: bool
  local initialSlotLoadDelay: float
  local initialMetadataStage: int

  function ContainerBootstrapInitializeState() -> void
    initialSlotLoadPending = true
    initialSlotLoadDelay = 0.05
    initialMetadataStage = 0
  end

  function ContainerBootstrapInitializePersistentPlayerSnapshot() -> void
    if inv_overhaul_inventory_snapshot.InventorySnapshotCanReusePersistent() then
      inv_overhaul_inventory_snapshot.InventorySnapshotCapturePrevious()
      return
    end
    local currentCount: int =
      inv_overhaul_inventory_snapshot.InventorySnapshotCaptureCurrentCount()
    if currentCount > InventoryCapacity then currentCount = InventoryCapacity end
    local loaded: bool =
      inv_overhaul_inventory_snapshot.InventorySnapshotLoadPersistent()
    local changed: bool = false
    if loaded then
      changed =
        inv_overhaul_inventory_snapshot.InventorySnapshotDiffers(currentCount)
    end
    if changed then
      local oldCount: int =
        inv_overhaul_inventory_snapshot.InventorySnapshotGetLastBackpackItemCount()
      local visibleSlots: int =
        inv_overhaul_container_presenter.ContainerPresenterGetVisibleSlots()
      inv_overhaul_inventory_snapshot.InventorySnapshotReconcile(
        currentCount, visibleSlots)
      inv_overhaul_inventory_layout_runtime.InventoryLayoutRuntimeQueueSave()
      native.Trace("inv_overhaul_container persistent snapshot reconciled old=" +
        oldCount + " current=" + currentCount)
    end
    inv_overhaul_inventory_snapshot.InventorySnapshotCopyCurrent(currentCount)
    -- Persist after the fallback comparison so saves without the content
    -- generation stamp are migrated only after their IDs are checked.
    inv_overhaul_inventory_snapshot.InventorySnapshotSavePersistent()
    if !loaded then
      native.Trace("inv_overhaul_container persistent snapshot initialized count=" +
        currentCount)
    end
  end

  function ContainerBootstrapOrderFreeCellsByDisplay() -> void
    local itemCount: int =
      inv_overhaul_inventory_items.InventoryItemsGetBackpackCount()
    local visibleSlots: int =
      inv_overhaul_container_presenter.ContainerPresenterGetVisibleSlots()
    if inv_overhaul_inventory_layout_runtime.InventoryLayoutRuntimeOrderFreeCellsByDisplay(
      itemCount, visibleSlots) then
      inv_overhaul_inventory_layout_runtime.InventoryLayoutRuntimeQueueSave()
    end
  end

  function ContainerBootstrapAdvance(delta: float) -> void
    if !initialSlotLoadPending then return end
    initialSlotLoadDelay = initialSlotLoadDelay - delta
    if initialSlotLoadDelay > 0 then return end
    if initialMetadataStage == 0 then
      if inv_overhaul_inventory_layout_runtime.InventoryLayoutRuntimeContinueIncrementalLoad(
        -1) then
        initialMetadataStage = 1
        initialSlotLoadDelay = 0.01
      else
        initialSlotLoadDelay = 0
      end
      return
    end
    if initialMetadataStage == 1 then
      ContainerBootstrapInitializePersistentPlayerSnapshot()
      initialMetadataStage = 2
      initialSlotLoadDelay = 0.01
      return
    end
    ContainerBootstrapOrderFreeCellsByDisplay()
    initialSlotLoadPending = false
    inv_overhaul_container_presenter.ContainerPresenterBeginInitialSlotLoad()
  end
end
