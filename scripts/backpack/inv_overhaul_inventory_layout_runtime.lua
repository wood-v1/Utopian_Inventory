import "inv_overhaul_inventory_layout"

module inv_overhaul_inventory_layout_runtime do
  local const InventoryCapacity: int = 56
  local const LayoutVersion: int = 4
  local slotOrder: object
  local savePending: bool
  local saveNextCell: int

  function InventoryLayoutRuntimeInitialize() -> void
    local newOrder: object
    native.CreateIntVector(newOrder)
    slotOrder = newOrder
    for cell = 0, InventoryCapacity - 1 do
      slotOrder->add(inv_overhaul_inventory_layout.InventoryLayoutGetDefaultOrderForCell(cell))
    end
    savePending = false
    saveNextCell = -1
  end

  function InventoryLayoutRuntimeGetOrderValue(cell: int) -> int
    local order: int = cell
    if cell >= 0 && cell < InventoryCapacity then slotOrder->get(order, cell) end
    return order
  end

  function InventoryLayoutRuntimeSetOrderValue(cell: int, value: int) -> void
    if cell >= 0 && cell < InventoryCapacity then slotOrder->set(cell, value) end
  end

  function InventoryLayoutRuntimeGetCellVariableName(cell: int) -> string
    return "inv_overhaul_inventory_cell_" + cell
  end

  function InventoryLayoutRuntimeIsOrderUsedBefore(cell: int, order: int) -> bool
    for candidateCell = 0, cell - 1 do
      if InventoryLayoutRuntimeGetOrderValue(candidateCell) == order then return true end
    end
    return false
  end

  function InventoryLayoutRuntimeIsOrderUsedAtOrBefore(cell: int, order: int) -> bool
    for candidateCell = 0, cell do
      if InventoryLayoutRuntimeGetOrderValue(candidateCell) == order then return true end
    end
    return false
  end

  function InventoryLayoutRuntimeFindFirstUnusedOrder(cell: int) -> int
    for candidate = 0, InventoryCapacity - 1 do
      if !InventoryLayoutRuntimeIsOrderUsedAtOrBefore(cell, candidate) then return candidate end
    end
    return cell
  end

  function InventoryLayoutRuntimeNormalize() -> void
    for cell = 0, InventoryCapacity - 1 do
      local order: int = InventoryLayoutRuntimeGetOrderValue(cell)
      if order < 0 || order >= InventoryCapacity ||
        InventoryLayoutRuntimeIsOrderUsedBefore(cell, order) then
        InventoryLayoutRuntimeSetOrderValue(cell, InventoryLayoutRuntimeFindFirstUnusedOrder(cell))
      end
    end
  end

  function InventoryLayoutRuntimeSaveAll() -> void
    for cell = 0, InventoryCapacity - 1 do
      native.SetVariable(
        InventoryLayoutRuntimeGetCellVariableName(cell),
        InventoryLayoutRuntimeGetOrderValue(cell))
    end
    native.SetVariable("inv_overhaul_inventory_layout_initialized", 1)
    native.SetVariable("inv_overhaul_inventory_layout_version", LayoutVersion)
    savePending = false
    saveNextCell = 0
  end

  function InventoryLayoutRuntimeQueueSave() -> void
    savePending = true
    saveNextCell = 0
  end

  function InventoryLayoutRuntimeHasQueuedSave() -> bool return savePending end

  function InventoryLayoutRuntimeContinueQueuedSave() -> void
    if !savePending then return end
    for batch = 0, 1 do
      if saveNextCell < InventoryCapacity then
        local cell: int = saveNextCell
        InventoryLayoutRuntimeSaveCell(cell)
        saveNextCell = saveNextCell + 1
      end
    end
    if saveNextCell >= InventoryCapacity then
      InventoryLayoutRuntimeFinishIncrementalSave()
      savePending = false
      saveNextCell = 0
    end
  end

  function InventoryLayoutRuntimeLoad() -> void
    local initialized: int = 0
    local layoutVersion: int = 0
    native.GetVariable("inv_overhaul_inventory_layout_initialized", initialized)
    native.GetVariable("inv_overhaul_inventory_layout_version", layoutVersion)
    if initialized != 1 then
      InventoryLayoutRuntimeSaveAll()
      return
    end

    local storedSlots: int = InventoryCapacity
    if layoutVersion == 3 then storedSlots = 40 end
    if layoutVersion != 3 && layoutVersion != LayoutVersion then
      InventoryLayoutRuntimeSaveAll()
      return
    end

    if layoutVersion == 3 then
      for cell = 0, 15 do InventoryLayoutRuntimeSetOrderValue(cell, cell + 40) end
      for legacyCell = 0, 39 do
        local legacyOrder: int = legacyCell
        native.GetVariable(InventoryLayoutRuntimeGetCellVariableName(legacyCell), legacyOrder)
        if legacyOrder < 0 || legacyOrder >= 40 then legacyOrder = legacyCell end
        InventoryLayoutRuntimeSetOrderValue(legacyCell + 16, legacyOrder)
      end
    else
      for cell = 0, storedSlots - 1 do
        local order: int = inv_overhaul_inventory_layout.InventoryLayoutGetDefaultOrderForCell(cell)
        native.GetVariable(InventoryLayoutRuntimeGetCellVariableName(cell), order)
        if order < 0 || order >= storedSlots then
          order = inv_overhaul_inventory_layout.InventoryLayoutGetDefaultOrderForCell(cell)
        end
        InventoryLayoutRuntimeSetOrderValue(cell, order)
      end
    end
    InventoryLayoutRuntimeNormalize()
    if layoutVersion == 3 then InventoryLayoutRuntimeSaveAll() end
    native.Trace("inv_overhaul_inventory layout loaded from variables")
  end

  function InventoryLayoutRuntimeContinueIncrementalLoad(loadStartCell: int) -> bool
    local nextCell: int = loadStartCell
    if nextCell < 0 then
      local initialized: int = 0
      local layoutVersion: int = 0
      native.GetVariable("inv_overhaul_inventory_layout_initialized", initialized)
      native.GetVariable("inv_overhaul_inventory_layout_version", layoutVersion)
      if initialized != 1 || layoutVersion != LayoutVersion then
        InventoryLayoutRuntimeLoad()
        return true
      end
      nextCell = 0
    end
    for batch = 0, InventoryCapacity - 1 do
      if nextCell < InventoryCapacity then
        local order: int = inv_overhaul_inventory_layout.InventoryLayoutGetDefaultOrderForCell(nextCell)
        native.GetVariable(InventoryLayoutRuntimeGetCellVariableName(nextCell), order)
        if order < 0 || order >= InventoryCapacity then
          order = inv_overhaul_inventory_layout.InventoryLayoutGetDefaultOrderForCell(nextCell)
        end
        InventoryLayoutRuntimeSetOrderValue(nextCell, order)
        nextCell = nextCell + 1
      end
    end
    if nextCell >= InventoryCapacity then
      InventoryLayoutRuntimeNormalize()
      return true
    end
    return false
  end

  function InventoryLayoutRuntimeSaveCell(cell: int) -> void
    if cell < 0 || cell >= InventoryCapacity then return end
    native.SetVariable(
      InventoryLayoutRuntimeGetCellVariableName(cell),
      InventoryLayoutRuntimeGetOrderValue(cell))
  end

  function InventoryLayoutRuntimeFinishIncrementalSave() -> void
    native.SetVariable("inv_overhaul_inventory_layout_initialized", 1)
    native.SetVariable("inv_overhaul_inventory_layout_version", LayoutVersion)
  end

  function InventoryLayoutRuntimeOrderFreeCellsByDisplay(
    itemCount: int,
    visibleSlots: int) -> bool
    if itemCount > InventoryCapacity then return false end
    local nextFreeOrder: int = itemCount
    local changed: bool = false
    for linear = 0, InventoryCapacity - 1 do
      local cell: int = inv_overhaul_inventory_layout.InventoryLayoutGetCellForLinearSlot(
        linear, visibleSlots, InventoryCapacity)
      if cell >= 0 && InventoryLayoutRuntimeGetOrderValue(cell) >= itemCount then
        if InventoryLayoutRuntimeGetOrderValue(cell) != nextFreeOrder then
          InventoryLayoutRuntimeSetOrderValue(cell, nextFreeOrder)
          changed = true
        end
        nextFreeOrder = nextFreeOrder + 1
      end
    end
    return changed
  end

  function InventoryLayoutRuntimeSwapCells(sourceCell: int, targetCell: int) -> bool
    if sourceCell == targetCell || sourceCell < 0 || targetCell < 0 then return false end
    local sourceOrder: int = InventoryLayoutRuntimeGetOrderValue(sourceCell)
    local targetOrder: int = InventoryLayoutRuntimeGetOrderValue(targetCell)
    InventoryLayoutRuntimeSetOrderValue(sourceCell, targetOrder)
    InventoryLayoutRuntimeSetOrderValue(targetCell, sourceOrder)
    return true
  end

  function InventoryLayoutRuntimeRemoveOrdinal(
    removedOrder: int,
    beforeCount: int,
    currentCount: int,
    visibleSlots: int) -> void
    if removedOrder < 0 then return end
    local emptyOrder: int = beforeCount - 1
    for cell = 0, InventoryCapacity - 1 do
      local order: int = InventoryLayoutRuntimeGetOrderValue(cell)
      if order == removedOrder then
        InventoryLayoutRuntimeSetOrderValue(cell, emptyOrder)
      else
        if order > removedOrder && order < beforeCount then
          InventoryLayoutRuntimeSetOrderValue(cell, order - 1)
        end
      end
    end
    InventoryLayoutRuntimeNormalize()
    InventoryLayoutRuntimeOrderFreeCellsByDisplay(currentCount, visibleSlots)
  end

  function InventoryLayoutRuntimeRemoveOrdinalExact(
    removedOrder: int,
    beforeCount: int) -> bool
    if removedOrder < 0 then return false end
    local emptyOrder: int = beforeCount - 1
    for cell = 0, InventoryCapacity - 1 do
      local order: int = InventoryLayoutRuntimeGetOrderValue(cell)
      if order == removedOrder then
        InventoryLayoutRuntimeSetOrderValue(cell, emptyOrder)
      else
        if order > removedOrder && order < beforeCount then
          InventoryLayoutRuntimeSetOrderValue(cell, order - 1)
        end
      end
    end
    InventoryLayoutRuntimeQueueSave()
    return true
  end

  function InventoryLayoutRuntimeFindFirstFreeCell(itemCount: int, visibleSlots: int) -> int
    for linear = 0, InventoryCapacity - 1 do
      local cell: int = inv_overhaul_inventory_layout.InventoryLayoutGetCellForLinearSlot(
        linear, visibleSlots, InventoryCapacity)
      if cell >= 0 && InventoryLayoutRuntimeGetOrderValue(cell) >= itemCount then return cell end
    end
    return -1
  end

  function InventoryLayoutRuntimeInsertOrdinal(
    insertedOrder: int,
    beforeCount: int,
    targetCell: int,
    currentCount: int,
    visibleSlots: int) -> bool
    if insertedOrder < 0 || targetCell < 0 || targetCell >= InventoryCapacity then return false end
    local freeCell: int = InventoryLayoutRuntimeFindFirstFreeCell(beforeCount, visibleSlots)
    if freeCell < 0 then return false end

    local targetOrder: int = InventoryLayoutRuntimeGetOrderValue(targetCell)
    local targetOccupied: bool = targetOrder >= 0 && targetOrder < beforeCount
    local displacedOrder: int = targetOrder
    if targetOccupied && displacedOrder >= insertedOrder then displacedOrder = displacedOrder + 1 end

    for cell = 0, InventoryCapacity - 1 do
      local order: int = InventoryLayoutRuntimeGetOrderValue(cell)
      if order >= insertedOrder && order < beforeCount then
        InventoryLayoutRuntimeSetOrderValue(cell, order + 1)
      end
    end

    if freeCell != targetCell then
      if targetOccupied then
        InventoryLayoutRuntimeSetOrderValue(freeCell, displacedOrder)
      else
        InventoryLayoutRuntimeSetOrderValue(freeCell, targetOrder)
      end
    end
    InventoryLayoutRuntimeSetOrderValue(targetCell, insertedOrder)
    InventoryLayoutRuntimeNormalize()
    InventoryLayoutRuntimeOrderFreeCellsByDisplay(currentCount, visibleSlots)
    native.Trace("inv_overhaul_inventory inserted ordinal=" + insertedOrder + " targetCell=" + targetCell +
      " displacedCell=" + freeCell + " occupied=" + targetOccupied)
    return true
  end

  function InventoryLayoutRuntimeInsertOrdinalExactAtVisibleSlot(
    insertedOrder: int,
    beforeCount: int,
    page: int,
    visibleSlots: int,
    preferredSlot: int) -> bool
    if insertedOrder < 0 || beforeCount >= InventoryCapacity then return false end

    local insertedCell: int = -1
    for cell = 0, InventoryCapacity - 1 do
      if InventoryLayoutRuntimeGetOrderValue(cell) == beforeCount then
        insertedCell = cell
      end
    end
    if insertedCell < 0 then return false end

    for cell = 0, InventoryCapacity - 1 do
      local order: int = InventoryLayoutRuntimeGetOrderValue(cell)
      if cell != insertedCell && order >= insertedOrder && order < beforeCount then
        InventoryLayoutRuntimeSetOrderValue(cell, order + 1)
      end
    end
    InventoryLayoutRuntimeSetOrderValue(insertedCell, insertedOrder)

    local preferredCell: int =
      inv_overhaul_inventory_layout.InventoryLayoutGetCellForLinearSlot(
        page * visibleSlots + preferredSlot, visibleSlots, InventoryCapacity)
    if preferredSlot >= 0 && preferredSlot < visibleSlots &&
      preferredCell != insertedCell then
      local preferredOrder: int = InventoryLayoutRuntimeGetOrderValue(preferredCell)
      InventoryLayoutRuntimeSetOrderValue(preferredCell, insertedOrder)
      InventoryLayoutRuntimeSetOrderValue(insertedCell, preferredOrder)
    end
    InventoryLayoutRuntimeQueueSave()
    return true
  end
end
