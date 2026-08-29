import "inv_overhaul_inventory_geometry"
import "inv_overhaul_inventory_protocol"
import "inv_overhaul_inventory_paging"

module inv_overhaul_inventory_input_controller do
  function InventoryInputGetSlotTargetFromPointerMessage(
    message: int,
    base: int,
    sender: string,
    visibleSlots: int,
    windowWidth: int,
    dropInset: int
  ) -> int
    local senderSlot: int =
      inv_overhaul_inventory_protocol.InventoryProtocolGetSlotBySender(
        sender, visibleSlots)
    if senderSlot < 0 then return -1 end

    local encoded: int = message - base
    local localX: int = encoded / 100
    local localY: int = encoded - localX * 100
    if inv_overhaul_inventory_geometry.InventoryGeometryIsInsideSlotDropArea(
      windowWidth, dropInset, localX, localY) then
      return senderSlot
    end
    return -1
  end

  function InventoryInputGetDragPageHoverAction(sender: string, maxPage: int) -> int
    local action: int = 0
    if sender == "page_prev" then action = -1 end
    if sender == "page_next" then action = 1 end
    if !inv_overhaul_inventory_paging.InventoryPagingCanMove(action, maxPage) then
      action = 0
    end
    return action
  end

  function InventoryInputGetPageControlX(windowWidth: int) -> int
    return inv_overhaul_inventory_geometry.InventoryGeometryGetPageControlX(windowWidth)
  end

  function InventoryInputGetPageControlY(windowWidth: int, branch: int) -> int
    return inv_overhaul_inventory_geometry.InventoryGeometryGetPageControlY(
      windowWidth, branch)
  end

  function InventoryInputIsInsideQuickslotHelp(
    windowWidth: int,
    x: int,
    y: int
  ) -> bool
    return inv_overhaul_inventory_geometry.InventoryGeometryIsInsideQuickslotHelp(
      windowWidth, x, y)
  end

  function InventoryInputIsInsidePlayerPaging(
    windowWidth: int,
    branch: int,
    maxPage: int,
    x: int,
    y: int
  ) -> bool
    return inv_overhaul_inventory_geometry.InventoryGeometryIsInsidePlayerPaging(
      windowWidth, branch, maxPage, x, y)
  end

  function InventoryInputDecodePanelPointerAction(message: int) -> int
    if message >= inv_overhaul_inventory_protocol.PointerDragEndBase then return 3 end
    if message >= inv_overhaul_inventory_protocol.PointerDragBeginBase then return 1 end
    if message >= inv_overhaul_inventory_protocol.PointerRightBase then return 2 end
    if message >= inv_overhaul_inventory_protocol.PointerUpBase then return 3 end
    if message >= inv_overhaul_inventory_protocol.PointerDownBase then return 1 end
    return 0
  end

  function InventoryInputDecodePanelPointerBase(message: int) -> int
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
