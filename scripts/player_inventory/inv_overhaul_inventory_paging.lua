import "inv_overhaul_inventory_layout"

module inv_overhaul_inventory_paging do
  local page: int

  function InventoryPagingInitialize() -> void
    page = 0
  end

  function InventoryPagingGetPage() -> int
    return page
  end

  function InventoryPagingGetMaxPage(inventoryCapacity: int, visibleSlots: int) -> int
    return inv_overhaul_inventory_layout.InventoryLayoutGetMaxPage(
      inventoryCapacity, visibleSlots)
  end

  function InventoryPagingClamp(inventoryCapacity: int, visibleSlots: int) -> void
    local maxPage: int = InventoryPagingGetMaxPage(inventoryCapacity, visibleSlots)
    if page < 0 then page = 0 end
    if page > maxPage then page = maxPage end
  end

  function InventoryPagingChange(delta: int, inventoryCapacity: int, visibleSlots: int) -> void
    page = page + delta
    InventoryPagingClamp(inventoryCapacity, visibleSlots)
  end

  function InventoryPagingGetVisibleCell(
    slot: int,
    visibleSlots: int,
    inventoryCapacity: int) -> int
    local linear: int = page * visibleSlots + slot
    return InventoryPagingGetCellForLinearSlot(linear, visibleSlots, inventoryCapacity)
  end

  function InventoryPagingGetCellForLinearSlot(
    linear: int,
    visibleSlots: int,
    inventoryCapacity: int) -> int
    return inv_overhaul_inventory_layout.InventoryLayoutGetCellForLinearSlot(
      linear, visibleSlots, inventoryCapacity)
  end

  function InventoryPagingGetNextPage(maxPage: int) -> int
    local targetPage: int = page + 1
    if targetPage > maxPage then targetPage = 0 end
    return targetPage
  end

  function InventoryPagingCanMove(action: int, maxPage: int) -> bool
    if action < 0 then return page > 0 end
    if action > 0 then return page < maxPage end
    return false
  end

  function InventoryPagingGetCursorHoverAction(hoverTarget: int, maxPage: int) -> int
    if hoverTarget == 1 && InventoryPagingCanMove(-1, maxPage) then return -1 end
    if hoverTarget == 2 && InventoryPagingCanMove(1, maxPage) then return 1 end
    return 0
  end

  function InventoryPagingGetControlAction(
    x: int,
    y: int,
    controlX: int,
    controlY: int) -> int
    if y < controlY || y >= controlY + 36 then return 0 end
    if x >= controlX && x < controlX + 40 then return -1 end
    if x >= controlX + 92 && x < controlX + 132 then return 1 end
    return 0
  end

  function InventoryPagingIsControlHovered(
    action: int,
    x: int,
    y: int,
    controlX: int,
    controlY: int,
    maxPage: int) -> bool
    if !InventoryPagingCanMove(action, maxPage) then return false end
    if y < controlY || y >= controlY + 36 then return false end
    if action < 0 then return x >= controlX && x < controlX + 40 end
    return x >= controlX + 92 && x < controlX + 132
  end
end
