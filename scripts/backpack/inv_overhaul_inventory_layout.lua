module inv_overhaul_inventory_layout do
  function InventoryLayoutGetDefaultOrderForCell(cell: int) -> int
    if cell < 16 then return cell + 40 end
    return cell - 16
  end

  function InventoryLayoutGetCellForLinearSlot(
    linear: int,
    visibleSlots: int,
    inventoryCapacity: int) -> int
    if linear < 0 || linear >= inventoryCapacity then return -1 end
    if visibleSlots < inventoryCapacity then
      return (linear + 16) - ((linear + 16) / inventoryCapacity) * inventoryCapacity
    end
    return linear
  end

  function InventoryLayoutGetMaxPage(inventoryCapacity: int, visibleSlots: int) -> int
    if visibleSlots <= 0 then return 0 end
    return (inventoryCapacity - 1) / visibleSlots
  end
end
