import "inv_overhaul_inventory_layout"

module inv_overhaul_inventory_paging do
  local page: int

  function PlayerPagingInitialize() -> void
    page = 0
  end

  function GetPage() -> int
    return page
  end

  function PlayerPagingGetMaxPage(inventoryCapacity: int, visibleSlots: int) -> int
    return inv_overhaul_inventory_layout.LayoutGetMaxPage(
      inventoryCapacity, visibleSlots)
  end

  function Clamp(inventoryCapacity: int, visibleSlots: int) -> void
    local maxPage: int = PlayerPagingGetMaxPage(inventoryCapacity, visibleSlots)
    if page < 0 then page = 0 end
    if page > maxPage then page = maxPage end
  end

  function Change(delta: int, inventoryCapacity: int, visibleSlots: int) -> void
    page = page + delta
    Clamp(inventoryCapacity, visibleSlots)
  end

  function PlayerPagingGetVisibleCell(
    slot: int,
    visibleSlots: int,
    inventoryCapacity: int) -> int
    local linear: int = page * visibleSlots + slot
    return PlayerPagingGetCellForLinearSlot(linear, visibleSlots, inventoryCapacity)
  end

  function PlayerPagingGetCellForLinearSlot(
    linear: int,
    visibleSlots: int,
    inventoryCapacity: int) -> int
    return inv_overhaul_inventory_layout.LayoutGetCellForLinearSlot(
      linear, visibleSlots, inventoryCapacity)
  end

  function GetNextPage(maxPage: int) -> int
    local targetPage: int = page + 1
    if targetPage > maxPage then targetPage = 0 end
    return targetPage
  end

  function CanMove(action: int, maxPage: int) -> bool
    if action < 0 then return page > 0 end
    if action > 0 then return page < maxPage end
    return false
  end

  function GetCursorHoverAction(hoverTarget: int, maxPage: int) -> int
    if hoverTarget == 1 && CanMove(-1, maxPage) then return -1 end
    if hoverTarget == 2 && CanMove(1, maxPage) then return 1 end
    return 0
  end

  function GetControlAction(
    x: int,
    y: int,
    controlX: int,
    controlY: int) -> int
    if y < controlY || y >= controlY + 36 then return 0 end
    if x >= controlX && x < controlX + 40 then return -1 end
    if x >= controlX + 92 && x < controlX + 132 then return 1 end
    return 0
  end

  function IsControlHovered(
    action: int,
    x: int,
    y: int,
    controlX: int,
    controlY: int,
    maxPage: int) -> bool
    if !CanMove(action, maxPage) then return false end
    if y < controlY || y >= controlY + 36 then return false end
    if action < 0 then return x >= controlX && x < controlX + 40 end
    return x >= controlX + 92 && x < controlX + 132
  end
end
