import "inv_overhaul_inventory_layout"

module inv_overhaul_inventory_layout_runtime do
  local const InventoryCapacity: int = 56
  local const LayoutVersion: int = 5
  local const PackedCellCount: int = 5
  local const PackedGroupCount: int = 12
  local const PackedRadix: int = 64
  local slotOrder: object
  local normalizationUsedOrders: object
  local savePending: bool
  local saveNextCell: int

  function LayoutRuntimeInitialize() -> void
    local newOrder: object
    local newNormalizationUsedOrders: object
    native.CreateIntVector(newOrder)
    native.CreateIntVector(newNormalizationUsedOrders)
    slotOrder = newOrder
    normalizationUsedOrders = newNormalizationUsedOrders
    for cell = 0, InventoryCapacity - 1 do
      slotOrder->add(inv_overhaul_inventory_layout.GetDefaultOrderForCell(cell))
      normalizationUsedOrders->add(0)
    end
    savePending = false
    saveNextCell = -1
  end

  function LayoutRuntimeGetOrderValue(cell: int) -> int
    local order: int = cell
    if cell >= 0 && cell < InventoryCapacity then slotOrder->get(order, cell) end
    return order
  end

  function SetOrderValue(cell: int, value: int) -> void
    if cell >= 0 && cell < InventoryCapacity then slotOrder->set(cell, value) end
  end

  function GetCellVariableName(cell: int) -> string
    return "inv_overhaul_inventory_cell_" + cell
  end

  function GetPackedVariableName(group: int) -> string
    return "inv_overhaul_inventory_cells_" + group
  end

  function EncodePackedGroup(group: int) -> int
    local packed: int = 0
    local multiplier: int = 1
    local firstCell: int = group * PackedCellCount
    for offset = 0, PackedCellCount - 1 do
      local cell: int = firstCell + offset
      if cell < InventoryCapacity then
        packed = packed + LayoutRuntimeGetOrderValue(cell) * multiplier
      end
      multiplier = multiplier * PackedRadix
    end
    return packed
  end

  function DecodePackedGroup(group: int, packed: int) -> void
    local firstCell: int = group * PackedCellCount
    for offset = 0, PackedCellCount - 1 do
      local cell: int = firstCell + offset
      if cell < InventoryCapacity then
        local reduced: int = packed / PackedRadix
        local order: int = packed - reduced * PackedRadix
        SetOrderValue(cell, order)
        packed = reduced
      end
    end
  end

  function IsOrderUsedBefore(cell: int, order: int) -> bool
    for candidateCell = 0, cell - 1 do
      if LayoutRuntimeGetOrderValue(candidateCell) == order then return true end
    end
    return false
  end

  function IsOrderUsedAtOrBefore(cell: int, order: int) -> bool
    for candidateCell = 0, cell do
      if LayoutRuntimeGetOrderValue(candidateCell) == order then return true end
    end
    return false
  end

  function FindFirstUnusedOrder(cell: int) -> int
    for candidate = 0, InventoryCapacity - 1 do
      if !IsOrderUsedAtOrBefore(cell, candidate) then return candidate end
    end
    return cell
  end

  function Normalize() -> void
    for order = 0, InventoryCapacity - 1 do
      normalizationUsedOrders->set(order, 0)
    end
    for cell = 0, InventoryCapacity - 1 do
      local order: int = LayoutRuntimeGetOrderValue(cell)
      local used: int = 1
      if order >= 0 && order < InventoryCapacity then
        normalizationUsedOrders->get(used, order)
      end
      if order < 0 || order >= InventoryCapacity || used == 1 then
        local replacement: int = 0
        local replacementUsed: int = 1
        while replacement < InventoryCapacity && replacementUsed == 1 do
          normalizationUsedOrders->get(replacementUsed, replacement)
          if replacementUsed == 1 then replacement = replacement + 1 end
        end
        SetOrderValue(cell, replacement)
        order = replacement
      end
      normalizationUsedOrders->set(order, 1)
    end
  end

  function SaveAll() -> void
    for group = 0, PackedGroupCount - 1 do
      native.SetVariable(
        GetPackedVariableName(group),
        EncodePackedGroup(group))
    end
    native.SetVariable("inv_overhaul_inventory_layout_initialized", 1)
    native.SetVariable("inv_overhaul_inventory_layout_version", LayoutVersion)
    savePending = false
    saveNextCell = 0
  end

  function QueueSave() -> void
    savePending = true
    saveNextCell = 0
  end

  function HasQueuedSave() -> bool return savePending end

  function ContinueQueuedSave() -> void
    if !savePending then return end
    for batch = 0, 1 do
      if saveNextCell < PackedGroupCount then
        local cell: int = saveNextCell * PackedCellCount
        SaveCell(cell)
        saveNextCell = saveNextCell + 1
      end
    end
    if saveNextCell >= PackedGroupCount then
      FinishIncrementalSave()
      savePending = false
      saveNextCell = 0
    end
  end

  function Load() -> void
    local initialized: int = 0
    local layoutVersion: int = 0
    native.GetVariable("inv_overhaul_inventory_layout_initialized", initialized)
    native.GetVariable("inv_overhaul_inventory_layout_version", layoutVersion)
    if initialized != 1 then
      SaveAll()
      return
    end

    local storedSlots: int = InventoryCapacity
    if layoutVersion == 3 then storedSlots = 40 end
    if layoutVersion != 3 && layoutVersion != 4 && layoutVersion != LayoutVersion then
      SaveAll()
      return
    end

    if layoutVersion == LayoutVersion then
      for group = 0, PackedGroupCount - 1 do
        local packed: int = EncodePackedGroup(group)
        native.GetVariable(GetPackedVariableName(group), packed)
        DecodePackedGroup(group, packed)
      end
    else
    if layoutVersion == 3 then
      for cell = 0, 15 do SetOrderValue(cell, cell + 40) end
      for legacyCell = 0, 39 do
        local legacyOrder: int = legacyCell
        native.GetVariable(GetCellVariableName(legacyCell), legacyOrder)
        if legacyOrder < 0 || legacyOrder >= 40 then legacyOrder = legacyCell end
        SetOrderValue(legacyCell + 16, legacyOrder)
      end
    else
      for cell = 0, storedSlots - 1 do
        local order: int = inv_overhaul_inventory_layout.GetDefaultOrderForCell(cell)
        native.GetVariable(GetCellVariableName(cell), order)
        if order < 0 || order >= storedSlots then
          order = inv_overhaul_inventory_layout.GetDefaultOrderForCell(cell)
        end
        SetOrderValue(cell, order)
      end
    end
    end
    Normalize()
    if layoutVersion == 3 || layoutVersion == 4 then SaveAll() end
    native.Trace("inv_overhaul_inventory layout loaded from variables")
  end

  function ContinueIncrementalLoad(loadStartCell: int) -> bool
    local nextCell: int = loadStartCell
    if nextCell < 0 then
      local initialized: int = 0
      local layoutVersion: int = 0
      native.GetVariable("inv_overhaul_inventory_layout_initialized", initialized)
      native.GetVariable("inv_overhaul_inventory_layout_version", layoutVersion)
      if initialized != 1 || layoutVersion != LayoutVersion then
        Load()
        return true
      end
      nextCell = 0
    end
    for group = 0, PackedGroupCount - 1 do
      if nextCell < PackedGroupCount then
        local packed: int = EncodePackedGroup(nextCell)
        native.GetVariable(GetPackedVariableName(nextCell), packed)
        DecodePackedGroup(nextCell, packed)
        nextCell = nextCell + 1
      end
    end
    if nextCell >= PackedGroupCount then
      Normalize()
      return true
    end
    return false
  end

  function SaveCell(cell: int) -> void
    if cell < 0 || cell >= InventoryCapacity then return end
    local group: int = cell / PackedCellCount
    native.SetVariable(
      GetPackedVariableName(group),
      EncodePackedGroup(group))
  end

  function FinishIncrementalSave() -> void
    native.SetVariable("inv_overhaul_inventory_layout_initialized", 1)
    native.SetVariable("inv_overhaul_inventory_layout_version", LayoutVersion)
  end

  function LayoutRuntimeOrderFreeCellsByDisplay(
    itemCount: int,
    visibleSlots: int) -> bool
    if itemCount > InventoryCapacity then return false end
    local nextFreeOrder: int = itemCount
    local changed: bool = false
    for linear = 0, InventoryCapacity - 1 do
      local cell: int = inv_overhaul_inventory_layout.LayoutGetCellForLinearSlot(
        linear, visibleSlots, InventoryCapacity)
      if cell >= 0 && LayoutRuntimeGetOrderValue(cell) >= itemCount then
        if LayoutRuntimeGetOrderValue(cell) != nextFreeOrder then
          SetOrderValue(cell, nextFreeOrder)
          changed = true
        end
        nextFreeOrder = nextFreeOrder + 1
      end
    end
    return changed
  end

  function LayoutRuntimeSwapCells(sourceCell: int, targetCell: int) -> bool
    if sourceCell == targetCell || sourceCell < 0 || targetCell < 0 then return false end
    local sourceOrder: int = LayoutRuntimeGetOrderValue(sourceCell)
    local targetOrder: int = LayoutRuntimeGetOrderValue(targetCell)
    SetOrderValue(sourceCell, targetOrder)
    SetOrderValue(targetCell, sourceOrder)
    return true
  end

  function RemoveOrdinal(
    removedOrder: int,
    beforeCount: int,
    currentCount: int,
    visibleSlots: int) -> void
    if removedOrder < 0 then return end
    local emptyOrder: int = beforeCount - 1
    for cell = 0, InventoryCapacity - 1 do
      local order: int = LayoutRuntimeGetOrderValue(cell)
      if order == removedOrder then
        SetOrderValue(cell, emptyOrder)
      else
        if order > removedOrder && order < beforeCount then
          SetOrderValue(cell, order - 1)
        end
      end
    end
    Normalize()
    LayoutRuntimeOrderFreeCellsByDisplay(currentCount, visibleSlots)
  end

  function RemoveOrdinalExact(
    removedOrder: int,
    beforeCount: int) -> bool
    if removedOrder < 0 then return false end
    local emptyOrder: int = beforeCount - 1
    for cell = 0, InventoryCapacity - 1 do
      local order: int = LayoutRuntimeGetOrderValue(cell)
      if order == removedOrder then
        SetOrderValue(cell, emptyOrder)
      else
        if order > removedOrder && order < beforeCount then
          SetOrderValue(cell, order - 1)
        end
      end
    end
    QueueSave()
    return true
  end

  function FindFirstFreeCell(itemCount: int, visibleSlots: int) -> int
    for linear = 0, InventoryCapacity - 1 do
      local cell: int = inv_overhaul_inventory_layout.LayoutGetCellForLinearSlot(
        linear, visibleSlots, InventoryCapacity)
      if cell >= 0 && LayoutRuntimeGetOrderValue(cell) >= itemCount then return cell end
    end
    return -1
  end

  function InsertOrdinal(
    insertedOrder: int,
    beforeCount: int,
    targetCell: int,
    currentCount: int,
    visibleSlots: int) -> bool
    if insertedOrder < 0 || targetCell < 0 || targetCell >= InventoryCapacity then return false end
    local freeCell: int = FindFirstFreeCell(beforeCount, visibleSlots)
    if freeCell < 0 then return false end

    local targetOrder: int = LayoutRuntimeGetOrderValue(targetCell)
    local targetOccupied: bool = targetOrder >= 0 && targetOrder < beforeCount
    local displacedOrder: int = targetOrder
    if targetOccupied && displacedOrder >= insertedOrder then displacedOrder = displacedOrder + 1 end

    for cell = 0, InventoryCapacity - 1 do
      local order: int = LayoutRuntimeGetOrderValue(cell)
      if order >= insertedOrder && order < beforeCount then
        SetOrderValue(cell, order + 1)
      end
    end

    if freeCell != targetCell then
      if targetOccupied then
        SetOrderValue(freeCell, displacedOrder)
      else
        SetOrderValue(freeCell, targetOrder)
      end
    end
    SetOrderValue(targetCell, insertedOrder)
    Normalize()
    LayoutRuntimeOrderFreeCellsByDisplay(currentCount, visibleSlots)
    native.Trace("inv_overhaul_inventory inserted ordinal=" + insertedOrder + " targetCell=" + targetCell +
      " displacedCell=" + freeCell + " occupied=" + targetOccupied)
    return true
  end

  function InsertOrdinalExactAtVisibleSlot(
    insertedOrder: int,
    beforeCount: int,
    page: int,
    visibleSlots: int,
    preferredSlot: int) -> bool
    if insertedOrder < 0 || beforeCount >= InventoryCapacity then return false end

    local insertedCell: int = -1
    for cell = 0, InventoryCapacity - 1 do
      if LayoutRuntimeGetOrderValue(cell) == beforeCount then
        insertedCell = cell
      end
    end
    if insertedCell < 0 then return false end

    for cell = 0, InventoryCapacity - 1 do
      local order: int = LayoutRuntimeGetOrderValue(cell)
      if cell != insertedCell && order >= insertedOrder && order < beforeCount then
        SetOrderValue(cell, order + 1)
      end
    end
    SetOrderValue(insertedCell, insertedOrder)

    local preferredCell: int =
      inv_overhaul_inventory_layout.LayoutGetCellForLinearSlot(
        page * visibleSlots + preferredSlot, visibleSlots, InventoryCapacity)
    if preferredSlot >= 0 && preferredSlot < visibleSlots &&
      preferredCell != insertedCell then
      local preferredOrder: int = LayoutRuntimeGetOrderValue(preferredCell)
      SetOrderValue(preferredCell, insertedOrder)
      SetOrderValue(insertedCell, preferredOrder)
    end
    QueueSave()
    return true
  end
end
