import "inv_overhaul_inventory_overflow"

module inv_overhaul_inventory_snapshot_seed do
  local const InventorySnapshotSeedCapacity: int = 56
  local const InventorySnapshotSeedCategoryCount: int = 5
  local const InventorySnapshotSeedVersion: int = 1

  function InventorySnapshotSeedVariableName(ordinal: int) -> string
    return "inv_overhaul_inventory_snapshot_" + ordinal
  end

  function InventorySnapshotSeedInitializeIfMissing() -> void
    local valid: int = 0
    local version: int = 0
    native.GetVariable("inv_overhaul_inventory_snapshot_valid", valid)
    native.GetVariable("inv_overhaul_inventory_snapshot_version", version)
    if valid == 1 && version == InventorySnapshotSeedVersion then return end

    local player: object =
      inv_overhaul_inventory_overflow.InventoryOverflowGetPlayer()
    local ordinal: int = 0
    for category = 0, InventorySnapshotSeedCategoryCount - 1 do
      local count: int
      player->GetItemCount(count, category)
      for index = 0, count - 1 do
        if !inv_overhaul_inventory_overflow.InventoryOverflowIsEquippedItem(
          category, index) then
          if ordinal < InventorySnapshotSeedCapacity then
            local item: object
            local itemID: int = -1
            player->GetItem(item, index, category)
            if item then item->GetItemID(itemID) end
            native.SetVariable(InventorySnapshotSeedVariableName(ordinal), itemID)
          end
          ordinal = ordinal + 1
        end
      end
    end
    local storedCount: int = ordinal
    if storedCount > InventorySnapshotSeedCapacity then
      storedCount = InventorySnapshotSeedCapacity
    end
    for emptyOrdinal = storedCount, InventorySnapshotSeedCapacity - 1 do
      native.SetVariable(InventorySnapshotSeedVariableName(emptyOrdinal), -1)
    end
    native.SetVariable("inv_overhaul_inventory_snapshot_count", storedCount)
    native.SetVariable("inv_overhaul_inventory_snapshot_version", InventorySnapshotSeedVersion)
    local reorderGeneration: int = 0
    local contentGeneration: int = 0
    native.GetVariable("inv_overhaul_inventory_reorder_generation", reorderGeneration)
    native.GetVariable("inv_overhaul_inventory_content_generation", contentGeneration)
    native.SetVariable("inv_overhaul_inventory_snapshot_generation", reorderGeneration)
    native.SetVariable("inv_overhaul_inventory_snapshot_content_generation", contentGeneration)
    native.SetVariable("inv_overhaul_inventory_snapshot_valid", 1)
    native.Trace("inv_overhaul_inventory_guard persistent snapshot initialized count=" + storedCount)
  end
end
