import "inv_overhaul_inventory_geometry"
import "inv_overhaul_inventory_protocol"
import "inv_overhaul_inventory_paging"

module inv_overhaul_inventory_input_controller do
  function PlayerInputGetSlotTargetFromPointerMessage(
    message: int,
    base: int,
    sender: string,
    visibleSlots: int,
    windowWidth: int,
    dropInset: int
  ) -> int
    local senderSlot: int =
      inv_overhaul_inventory_protocol.GetSlotBySender(
        sender, visibleSlots)
    if senderSlot < 0 then return -1 end

    local encoded: int = message - base
    local localX: int = encoded / 100
    local localY: int = encoded - localX * 100
    if inv_overhaul_inventory_geometry.InterfaceGeometryIsInsideSlotDropArea(
      windowWidth, dropInset, localX, localY) then
      return senderSlot
    end
    return -1
  end

  function PlayerInputGetDragPageHoverAction(sender: string, maxPage: int) -> int
    local action: int = 0
    if sender == "page_prev" then action = -1 end
    if sender == "page_next" then action = 1 end
    if !inv_overhaul_inventory_paging.CanMove(action, maxPage) then
      action = 0
    end
    return action
  end

  function PlayerInputGetPageControlX(windowWidth: int) -> int
    return inv_overhaul_inventory_geometry.InterfaceGeometryGetPageControlX(windowWidth)
  end

  function PlayerInputGetPageControlY(windowWidth: int, branch: int) -> int
    return inv_overhaul_inventory_geometry.InterfaceGeometryGetPageControlY(
      windowWidth, branch)
  end

  function PlayerInputIsInsideQuickslotHelp(
    windowWidth: int,
    x: int,
    y: int
  ) -> bool
    return inv_overhaul_inventory_geometry.InterfaceGeometryIsInsideQuickslotHelp(
      windowWidth, x, y)
  end

  function PlayerInputIsInsidePlayerPaging(
    windowWidth: int,
    branch: int,
    maxPage: int,
    x: int,
    y: int
  ) -> bool
    return inv_overhaul_inventory_geometry.InterfaceGeometryIsInsidePlayerPaging(
      windowWidth, branch, maxPage, x, y)
  end

  function DecodePanelPointerAction(message: int) -> int
    if message >= inv_overhaul_inventory_protocol.PointerDragEndBase then return 3 end
    if message >= inv_overhaul_inventory_protocol.PointerDragBeginBase then return 1 end
    if message >= inv_overhaul_inventory_protocol.PointerRightBase then return 2 end
    if message >= inv_overhaul_inventory_protocol.PointerUpBase then return 3 end
    if message >= inv_overhaul_inventory_protocol.PointerDownBase then return 1 end
    return 0
  end

  function DecodePanelPointerBase(message: int) -> int
    if message >= inv_overhaul_inventory_protocol.PointerDragEndBase then
      return inv_overhaul_inventory_protocol.PointerDragEndBase
    end
    if message >= inv_overhaul_inventory_protocol.PointerDragBeginBase then
      return inv_overhaul_inventory_protocol.PointerDragBeginBase
    end
    if message >= inv_overhaul_inventory_protocol.PointerRightBase then
      return inv_overhaul_inventory_protocol.PointerRightBase
    end
    if message >= inv_overhaul_inventory_protocol.PointerUpBase then
      return inv_overhaul_inventory_protocol.PointerUpBase
    end
    if message >= inv_overhaul_inventory_protocol.PointerDownBase then
      return inv_overhaul_inventory_protocol.PointerDownBase
    end
    return inv_overhaul_inventory_protocol.PointerMoveBase
  end
end
