import "inv_overhaul_inventory_items"
import "inv_overhaul_inventory_layout"
import "inv_overhaul_inventory_layout_runtime"

module inv_overhaul_inventory_snapshot do
  local const InventoryCapacity: int = 56
  local const SnapshotVersion: int = 1

  local backpackSnapshot: object
  local currentBackpackSnapshot: object
  local oldToNewOrder: object
  local claimedNewOrder: object
  local usedLayoutCell: object
  local lastBackpackItemCount: int

  function SnapshotInitializeState() -> void
    local newBackpackSnapshot: object
    local newCurrentBackpackSnapshot: object
    local newOldToNewOrder: object
    local newClaimedNewOrder: object
    local newUsedLayoutCell: object
    native.CreateIntVector(newBackpackSnapshot)
    native.CreateIntVector(newCurrentBackpackSnapshot)
    native.CreateIntVector(newOldToNewOrder)
    native.CreateIntVector(newClaimedNewOrder)
    native.CreateIntVector(newUsedLayoutCell)
    backpackSnapshot = newBackpackSnapshot
    currentBackpackSnapshot = newCurrentBackpackSnapshot
    oldToNewOrder = newOldToNewOrder
    claimedNewOrder = newClaimedNewOrder
    usedLayoutCell = newUsedLayoutCell
    for i = 0, InventoryCapacity - 1 do
      backpackSnapshot->add(-1)
      currentBackpackSnapshot->add(-1)
      oldToNewOrder->add(-1)
      claimedNewOrder->add(0)
      usedLayoutCell->add(0)
    end
    lastBackpackItemCount = 0
  end

  function GetLastBackpackItemCount() -> int
    return lastBackpackItemCount
  end

  function CapturePrevious() -> void
    local snapshot: object = backpackSnapshot
    lastBackpackItemCount =
      inv_overhaul_inventory_items.CaptureIdentitySnapshot(snapshot)
  end

  function ClampLastBackpackItemCount() -> void
    if lastBackpackItemCount > InventoryCapacity then lastBackpackItemCount = InventoryCapacity end
  end

  function CaptureCurrentCount() -> int
    local snapshot: object = currentBackpackSnapshot
    return inv_overhaul_inventory_items.CaptureIdentitySnapshot(snapshot)
  end

  function BuildIndexCacheAndPrevious() -> int
    local snapshot: object = backpackSnapshot
    lastBackpackItemCount =
      inv_overhaul_inventory_items.BuildIndexCacheAndSnapshot(
        snapshot)
    return lastBackpackItemCount
  end

  function GetVariableName(ordinal: int) -> string
    return "inv_overhaul_inventory_snapshot_" + ordinal
  end

  function LoadPersistent() -> bool
    local valid: int = 0
    local version: int = 0
    local count: int = 0
    native.GetVariable("inv_overhaul_inventory_snapshot_valid", valid)
    native.GetVariable("inv_overhaul_inventory_snapshot_version", version)
    native.GetVariable("inv_overhaul_inventory_snapshot_count", count)
    if valid != 1 || version != SnapshotVersion || count < 0 || count > InventoryCapacity then
      return false
    end
    for ordinal = 0, InventoryCapacity - 1 do
      local itemID: int = -1
      if ordinal < count then native.GetVariable(GetVariableName(ordinal), itemID) end
      backpackSnapshot->set(ordinal, itemID)
    end
    lastBackpackItemCount = count
    return true
  end

  function CanReusePersistent() -> bool
    local valid: int = 0
    local version: int = 0
    local count: int = 0
    local snapshotReorderGeneration: int = -1
    local currentReorderGeneration: int = 0
    local snapshotContentGeneration: int = -1
    local currentContentGeneration: int = 0
    native.GetVariable("inv_overhaul_inventory_snapshot_valid", valid)
    native.GetVariable("inv_overhaul_inventory_snapshot_version", version)
    native.GetVariable("inv_overhaul_inventory_snapshot_count", count)
    native.GetVariable("inv_overhaul_inventory_snapshot_generation", snapshotReorderGeneration)
    native.GetVariable("inv_overhaul_inventory_reorder_generation", currentReorderGeneration)
    native.GetVariable("inv_overhaul_inventory_snapshot_content_generation", snapshotContentGeneration)
    native.GetVariable("inv_overhaul_inventory_content_generation", currentContentGeneration)
    if valid != 1 || version != SnapshotVersion || count < 0 || count > InventoryCapacity then return false end
    return snapshotReorderGeneration == currentReorderGeneration &&
      snapshotContentGeneration == currentContentGeneration
  end

  function SavePersistent() -> void
    local count: int = lastBackpackItemCount
    if count < 0 then count = 0 end
    if count > InventoryCapacity then count = InventoryCapacity end
    for ordinal = 0, InventoryCapacity - 1 do
      local itemID: int = -1
      backpackSnapshot->get(itemID, ordinal)
      native.SetVariable(GetVariableName(ordinal), itemID)
    end
    native.SetVariable("inv_overhaul_inventory_snapshot_count", count)
    native.SetVariable("inv_overhaul_inventory_snapshot_version", SnapshotVersion)
    local reorderGeneration: int = 0
    local contentGeneration: int = 0
    native.GetVariable("inv_overhaul_inventory_reorder_generation", reorderGeneration)
    native.GetVariable("inv_overhaul_inventory_content_generation", contentGeneration)
    native.SetVariable("inv_overhaul_inventory_snapshot_generation", reorderGeneration)
    native.SetVariable("inv_overhaul_inventory_snapshot_content_generation", contentGeneration)
    native.SetVariable("inv_overhaul_inventory_snapshot_valid", 1)
  end

  function CopyCurrent(newCount: int) -> void
    for ordinal = 0, InventoryCapacity - 1 do
      local itemID: int = -1
      currentBackpackSnapshot->get(itemID, ordinal)
      backpackSnapshot->set(ordinal, itemID)
    end
    lastBackpackItemCount = newCount
    if lastBackpackItemCount > InventoryCapacity then lastBackpackItemCount = InventoryCapacity end
  end

  function Differs(newCount: int) -> bool
    local comparableCount: int = newCount
    if comparableCount > InventoryCapacity then comparableCount = InventoryCapacity end
    if comparableCount != lastBackpackItemCount then return true end
    for ordinal = 0, comparableCount - 1 do
      local previousID: int
      local currentID: int
      backpackSnapshot->get(previousID, ordinal)
      currentBackpackSnapshot->get(currentID, ordinal)
      if previousID != currentID then return true end
    end
    return false
  end

  function PersistCurrent() -> void
    CapturePrevious()
    ClampLastBackpackItemCount()
    SavePersistent()
  end

  function SnapshotGetCellForLinearSlot(linear: int, visibleSlots: int) -> int
    return inv_overhaul_inventory_layout.LayoutGetCellForLinearSlot(
      linear, visibleSlots, InventoryCapacity)
  end
  function FindFirstUnusedDisplayCell(visibleSlots: int) -> int
    for linear = 0, InventoryCapacity - 1 do
      local cell: int = SnapshotGetCellForLinearSlot(linear, visibleSlots)
      local used: int = 0
      usedLayoutCell->get(used, cell)
      if used == 0 then return cell end
    end
    return -1
  end

  function Reconcile(
    newCount: int,
    visibleSlots: int) -> void
    local oldCount: int = lastBackpackItemCount
    if oldCount > InventoryCapacity then oldCount = InventoryCapacity end
    if newCount > InventoryCapacity then newCount = InventoryCapacity end
    if oldCount < 0 then oldCount = 0 end
    if newCount < 0 then newCount = 0 end

    for i = 0, InventoryCapacity - 1 do
      oldToNewOrder->set(i, -1)
      claimedNewOrder->set(i, 0)
      usedLayoutCell->set(i, 0)
    end

    local removalHintValid: int = 0
    local removalHintOrdinal: int = -1
    local removalHintOldCount: int = -1
    native.GetVariable("inv_overhaul_inventory_removed_ordinal_valid", removalHintValid)
    native.GetVariable("inv_overhaul_inventory_removed_ordinal_hint", removalHintOrdinal)
    native.GetVariable("inv_overhaul_inventory_removed_ordinal_old_count", removalHintOldCount)
    local removalHintApplies: bool =
      removalHintValid == 1 &&
      removalHintOldCount == oldCount &&
      newCount == oldCount - 1 &&
      removalHintOrdinal >= 0 &&
      removalHintOrdinal < oldCount

    local equipmentRemovalCount: int = 0
    native.GetVariable("inv_overhaul_inventory_equipment_removal_count", equipmentRemovalCount)
    local equipmentRemovalApplies: bool =
      equipmentRemovalCount > 0 &&
      equipmentRemovalCount <= 8 &&
      newCount == oldCount - equipmentRemovalCount
    local expectedRemovalOldCount: int = oldCount
    if equipmentRemovalApplies then
      for hint = 0, equipmentRemovalCount - 1 do
        local hintOrdinal: int = -1
        local hintOldCount: int = -1
        native.GetVariable(
          "inv_overhaul_inventory_equipment_removal_ordinal_" + hint,
          hintOrdinal)
        native.GetVariable(
          "inv_overhaul_inventory_equipment_removal_old_count_" + hint,
          hintOldCount)
        if hintOldCount != expectedRemovalOldCount ||
          hintOrdinal < 0 || hintOrdinal >= expectedRemovalOldCount then
          equipmentRemovalApplies = false
        end
        expectedRemovalOldCount = expectedRemovalOldCount - 1
      end
    end

    if equipmentRemovalApplies then
      for oldOrdinal = 0, oldCount - 1 do oldToNewOrder->set(oldOrdinal, oldOrdinal) end
      for hint = 0, equipmentRemovalCount - 1 do
        local hintOrdinal: int = -1
        native.GetVariable(
          "inv_overhaul_inventory_equipment_removal_ordinal_" + hint,
          hintOrdinal)
        for oldOrdinal = 0, oldCount - 1 do
          local mapped: int = -1
          oldToNewOrder->get(mapped, oldOrdinal)
          if mapped == hintOrdinal then
            oldToNewOrder->set(oldOrdinal, -1)
          else
            if mapped > hintOrdinal then oldToNewOrder->set(oldOrdinal, mapped - 1) end
          end
        end
      end
      for oldOrdinal = 0, oldCount - 1 do
        local mapped: int = -1
        oldToNewOrder->get(mapped, oldOrdinal)
        if mapped >= 0 then claimedNewOrder->set(mapped, 1) end
      end
      native.Trace("inv_overhaul_inventory applied equipment removal queue count=" +
        equipmentRemovalCount + " old=" + oldCount + " new=" + newCount)
    else
    if removalHintApplies then
      for oldOrdinal = 0, oldCount - 1 do
        if oldOrdinal < removalHintOrdinal then
          oldToNewOrder->set(oldOrdinal, oldOrdinal)
          claimedNewOrder->set(oldOrdinal, 1)
        end
        if oldOrdinal > removalHintOrdinal then
          oldToNewOrder->set(oldOrdinal, oldOrdinal - 1)
          claimedNewOrder->set(oldOrdinal - 1, 1)
        end
      end
      native.Trace("inv_overhaul_inventory applied removal hint ordinal=" + removalHintOrdinal +
        " old=" + oldCount + " new=" + newCount)
    else
      for oldOrdinal = 0, oldCount - 1 do
        if oldOrdinal < newCount then
          local previousID: int
          local currentID: int
          backpackSnapshot->get(previousID, oldOrdinal)
          currentBackpackSnapshot->get(currentID, oldOrdinal)
          if previousID == currentID then
            oldToNewOrder->set(oldOrdinal, oldOrdinal)
            claimedNewOrder->set(oldOrdinal, 1)
          end
        end
      end

      for oldOrdinal = 0, oldCount - 1 do
        local mapped: int = -1
        oldToNewOrder->get(mapped, oldOrdinal)
        if mapped < 0 then
          local wantedID: int
          backpackSnapshot->get(wantedID, oldOrdinal)
          for newOrdinal = 0, newCount - 1 do
            local claimed: int
            claimedNewOrder->get(claimed, newOrdinal)
            local currentID: int
            currentBackpackSnapshot->get(currentID, newOrdinal)
            if claimed == 0 && currentID == wantedID then
              oldToNewOrder->set(oldOrdinal, newOrdinal)
              claimedNewOrder->set(newOrdinal, 1)
              newOrdinal = newCount
            end
          end
        end
      end
    end
    end
    if equipmentRemovalCount > 0 then
      native.SetVariable("inv_overhaul_inventory_equipment_removal_count", 0)
    end
    if removalHintValid == 1 then native.SetVariable("inv_overhaul_inventory_removed_ordinal_valid", 0) end

    for cell = 0, InventoryCapacity - 1 do
      local oldOrder: int = inv_overhaul_inventory_layout_runtime.LayoutRuntimeGetOrderValue(cell)
      if oldOrder >= 0 && oldOrder < oldCount then
        local mappedOrder: int
        oldToNewOrder->get(mappedOrder, oldOrder)
        if mappedOrder >= 0 then
          inv_overhaul_inventory_layout_runtime.SetOrderValue(cell, mappedOrder)
          usedLayoutCell->set(cell, 1)
        end
      end
    end

    for insertedOrder = 0, newCount - 1 do
      local claimed: int
      claimedNewOrder->get(claimed, insertedOrder)
      if claimed == 0 then
        local freeCell: int = FindFirstUnusedDisplayCell(visibleSlots)
        if freeCell >= 0 then
          inv_overhaul_inventory_layout_runtime.SetOrderValue(freeCell, insertedOrder)
          usedLayoutCell->set(freeCell, 1)
        end
      end
    end

    local freeOrder: int = newCount
    for linear = 0, InventoryCapacity - 1 do
      local freeCell: int = SnapshotGetCellForLinearSlot(linear, visibleSlots)
      local used: int
      usedLayoutCell->get(used, freeCell)
      if used == 0 then
        inv_overhaul_inventory_layout_runtime.SetOrderValue(freeCell, freeOrder)
        freeOrder = freeOrder + 1
      end
    end
    inv_overhaul_inventory_layout_runtime.Normalize()
    native.Trace("inv_overhaul_inventory reconciled generic snapshot old=" + oldCount + " new=" + newCount)
  end

  function RestoreAfterEquipmentReplacement(
    replacedOrder: int,
    itemCount: int,
    visibleSlots: int) -> bool
    if replacedOrder < 0 || replacedOrder >= itemCount then return false end
    local currentSnapshot: object = currentBackpackSnapshot
    local currentCount: int = inv_overhaul_inventory_items.CaptureIdentitySnapshot(currentSnapshot)
    if currentCount != itemCount then return false end

    for i = 0, InventoryCapacity - 1 do
      oldToNewOrder->set(i, -1)
      claimedNewOrder->set(i, 0)
      usedLayoutCell->set(i, 0)
    end

    for oldOrder = 0, itemCount - 1 do
      if oldOrder != replacedOrder then
        local wantedID: int
        backpackSnapshot->get(wantedID, oldOrder)
        for currentOrder = 0, itemCount - 1 do
          local claimed: int
          local currentID: int
          claimedNewOrder->get(claimed, currentOrder)
          currentBackpackSnapshot->get(currentID, currentOrder)
          if claimed == 0 && currentID == wantedID then
            oldToNewOrder->set(oldOrder, currentOrder)
            claimedNewOrder->set(currentOrder, 1)
            currentOrder = itemCount
          end
        end
      end
    end

    local replacementOrder: int = -1
    for currentOrder = 0, itemCount - 1 do
      local claimed: int
      claimedNewOrder->get(claimed, currentOrder)
      if claimed == 0 then
        replacementOrder = currentOrder
        currentOrder = itemCount
      end
    end
    if replacementOrder < 0 then return false end

    for cell = 0, InventoryCapacity - 1 do
      local oldOrder: int = inv_overhaul_inventory_layout_runtime.LayoutRuntimeGetOrderValue(cell)
      if oldOrder >= 0 && oldOrder < itemCount then
        local mappedOrder: int = replacementOrder
        if oldOrder != replacedOrder then oldToNewOrder->get(mappedOrder, oldOrder) end
        if mappedOrder < 0 then return false end
        inv_overhaul_inventory_layout_runtime.SetOrderValue(cell, mappedOrder)
        usedLayoutCell->set(cell, 1)
      end
    end

    local freeOrder: int = itemCount
    for linear = 0, InventoryCapacity - 1 do
      local freeCell: int = SnapshotGetCellForLinearSlot(linear, visibleSlots)
      local used: int
      usedLayoutCell->get(used, freeCell)
      if used == 0 then
        inv_overhaul_inventory_layout_runtime.SetOrderValue(freeCell, freeOrder)
        freeOrder = freeOrder + 1
      end
    end
    inv_overhaul_inventory_layout_runtime.Normalize()
    inv_overhaul_inventory_layout_runtime.LayoutRuntimeOrderFreeCellsByDisplay(itemCount, visibleSlots)
    native.Trace("inv_overhaul_inventory equipment replacement restored sourceOrder=" + replacedOrder +
      " replacementOrder=" + replacementOrder)
    return true
  end

  function RestoreAfterEquipmentSelection(
    removedOrder: int,
    beforeCount: int,
    visibleSlots: int) -> bool
    if removedOrder < 0 || removedOrder >= beforeCount then return false end
    local currentSnapshot: object = currentBackpackSnapshot
    local afterCount: int = inv_overhaul_inventory_items.CaptureIdentitySnapshot(currentSnapshot)
    if afterCount != beforeCount - 1 then return false end

    for i = 0, InventoryCapacity - 1 do
      oldToNewOrder->set(i, -1)
      claimedNewOrder->set(i, 0)
      usedLayoutCell->set(i, 0)
    end

    for oldOrder = 0, beforeCount - 1 do
      if oldOrder != removedOrder then
        local wantedID: int
        backpackSnapshot->get(wantedID, oldOrder)
        for currentOrder = 0, afterCount - 1 do
          local claimed: int
          local currentID: int
          claimedNewOrder->get(claimed, currentOrder)
          currentBackpackSnapshot->get(currentID, currentOrder)
          if claimed == 0 && currentID == wantedID then
            oldToNewOrder->set(oldOrder, currentOrder)
            claimedNewOrder->set(currentOrder, 1)
            currentOrder = afterCount
          end
        end
      end
    end

    for cell = 0, InventoryCapacity - 1 do
      local oldOrder: int = inv_overhaul_inventory_layout_runtime.LayoutRuntimeGetOrderValue(cell)
      if oldOrder >= 0 && oldOrder < beforeCount then
        if oldOrder == removedOrder then
          inv_overhaul_inventory_layout_runtime.SetOrderValue(cell, afterCount)
        else
          local mappedOrder: int
          oldToNewOrder->get(mappedOrder, oldOrder)
          if mappedOrder < 0 then return false end
          inv_overhaul_inventory_layout_runtime.SetOrderValue(cell, mappedOrder)
          usedLayoutCell->set(cell, 1)
        end
      end
    end

    local freeOrder: int = afterCount
    for linear = 0, InventoryCapacity - 1 do
      local freeCell: int = SnapshotGetCellForLinearSlot(linear, visibleSlots)
      local used: int
      usedLayoutCell->get(used, freeCell)
      if used == 0 then
        inv_overhaul_inventory_layout_runtime.SetOrderValue(freeCell, freeOrder)
        freeOrder = freeOrder + 1
      end
    end
    inv_overhaul_inventory_layout_runtime.Normalize()
    inv_overhaul_inventory_layout_runtime.LayoutRuntimeOrderFreeCellsByDisplay(afterCount, visibleSlots)
    native.Trace("inv_overhaul_inventory equipment selection restored removedOrder=" + removedOrder +
      " before=" + beforeCount + " after=" + afterCount)
    return true
  end
end
