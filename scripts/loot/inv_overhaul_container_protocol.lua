import "inv_overhaul_container_geometry"
import "inv_overhaul_container_view"

module inv_overhaul_container_protocol do
  local const HoverMessageBase: int = 100000
  local const ReleaseMessageBase: int = 200000
  local const DragEndMessageBase: int = 300000
  local const SlotPointerStride: int = 100

  local const PanelPointerMoveBase: int = 1000000
  local const PanelPointerDownBase: int = 4000000
  local const PanelPointerUpBase: int = 7000000
  local const PanelPointerRightBase: int = 10000000
  local const PanelPointerDragBeginBase: int = 13000000
  local const PanelPointerDragEndBase: int = 16000000
  local const PanelPointerLeaveBase: int = 19000000

  local const TargetDrop: int = 200
  local const TargetContainerBase: int = 300
  local const TargetOrganBase: int = 400
  local const ContainerTargetMoney: int = 500
  local const ContainerTargetPaging: int = 600
  local const ContainerTargetQuickslotHelp: int = 601
  local const ContainerQuickslotHelpHover: int = 29800001
  local const ContainerGridRendererReady: int = 29900000
  local const ContainerPageHoverEnter: int = -110
  local const ContainerPageHoverLeave: int = -111
  local const ContainerSlots: int = 12
  local const OrganSlots: int = 4

  function ContainerProtocolIsPlayerTarget(target: int, visibleSlots: int) -> bool
    return target >= 0 && target < visibleSlots
  end

  function ContainerProtocolIsContainerTarget(target: int) -> bool
    return target >= TargetContainerBase &&
      target < TargetContainerBase + ContainerSlots
  end

  function ContainerProtocolIsOrganTarget(target: int) -> bool
    return target >= TargetOrganBase && target < TargetOrganBase + OrganSlots
  end

  function ContainerProtocolGetContainerSlot(target: int) -> int
    if !ContainerProtocolIsContainerTarget(target) then return -1 end
    return target - TargetContainerBase
  end

  function ContainerProtocolGetOrganSlot(target: int) -> int
    if !ContainerProtocolIsOrganTarget(target) then return -1 end
    return target - TargetOrganBase
  end

  function ContainerProtocolGetTargetBySender(
    sender: string,
    visibleSlots: int) -> int
    for slot = 0, visibleSlots - 1 do
      if sender == inv_overhaul_container_view.ContainerViewGetPlayerSlotWndName(slot) then
        return slot
      end
    end
    for slot = 0, ContainerSlots - 1 do
      if sender == inv_overhaul_container_view.ContainerViewGetContainerSlotWndName(slot) then
        return TargetContainerBase + slot
      end
    end
    for slot = 0, OrganSlots - 1 do
      if sender == inv_overhaul_container_view.ContainerViewGetOrganSlotWndName(slot) then
        return TargetOrganBase + slot
      end
    end
    if sender == "drop_slot" then return TargetDrop end
    return -1
  end

  function ContainerProtocolFindTargetAt(
    windowWidth: int,
    visibleSlots: int,
    showOrgans: bool,
    x: int,
    y: int) -> int
    local slot: int =
      inv_overhaul_container_geometry.ContainerGeometryFindPlayerSlotAt(
        windowWidth, visibleSlots, x, y)
    if slot >= 0 then return slot end
    slot = inv_overhaul_container_geometry.ContainerGeometryFindContainerSlotAt(
      windowWidth, ContainerSlots, x, y)
    if slot >= 0 then return TargetContainerBase + slot end
    if showOrgans then
      slot = inv_overhaul_container_geometry.ContainerGeometryFindOrganSlotAt(
        windowWidth, OrganSlots, x, y)
      if slot >= 0 then return TargetOrganBase + slot end
    end
    return -1
  end

  function ContainerProtocolIsTargetCompatible(
    sourceKind: int,
    target: int,
    visibleSlots: int) -> bool
    if sourceKind == 0 then
      return ContainerProtocolIsPlayerTarget(target, visibleSlots) ||
        ContainerProtocolIsContainerTarget(target)
    end
    if sourceKind == 1 then
      return ContainerProtocolIsPlayerTarget(target, visibleSlots) ||
        ContainerProtocolIsContainerTarget(target)
    end
    if sourceKind == 2 then
      return ContainerProtocolIsPlayerTarget(target, visibleSlots)
    end
    return false
  end

  function ContainerProtocolGetSlotTargetFromPointerMessage(
    message: int,
    base: int,
    sender: string,
    visibleSlots: int,
    windowWidth: int) -> int
    local target: int = ContainerProtocolGetTargetBySender(sender, visibleSlots)
    if target < 0 then return -1 end
    local encoded: int = message - base
    local localX: int = encoded / SlotPointerStride
    local localY: int = encoded - localX * SlotPointerStride
    local hotZone: int =
      inv_overhaul_container_geometry.ContainerGeometryGetSlotHotZone(windowWidth)
    if ContainerProtocolIsOrganTarget(target) then
      hotZone =
        inv_overhaul_container_geometry.ContainerGeometryGetOrganSlotHotZone(windowWidth)
    end
    if inv_overhaul_container_geometry.ContainerGeometryIsInsideSlotDropArea(
      localX, localY, hotZone) then return target end
    return -1
  end

  function ContainerProtocolIsPanelPointerMessage(message: int) -> bool
    return message >= PanelPointerMoveBase
  end

  function ContainerProtocolGetPanelPointerAction(message: int) -> int
    if message >= PanelPointerLeaveBase then return -1 end
    if message >= PanelPointerDragEndBase then return 3 end
    if message >= PanelPointerDragBeginBase then return 1 end
    if message >= PanelPointerRightBase then return 2 end
    if message >= PanelPointerUpBase then return 3 end
    if message >= PanelPointerDownBase then return 1 end
    return 0
  end

  function ContainerProtocolGetPanelPointerBase(message: int) -> int
    if message >= PanelPointerDragEndBase then return PanelPointerDragEndBase end
    if message >= PanelPointerDragBeginBase then return PanelPointerDragBeginBase end
    if message >= PanelPointerRightBase then return PanelPointerRightBase end
    if message >= PanelPointerUpBase then return PanelPointerUpBase end
    if message >= PanelPointerDownBase then return PanelPointerDownBase end
    return PanelPointerMoveBase
  end

  function ContainerProtocolGetSlotPointerAction(message: int) -> int
    if message >= DragEndMessageBase then return 3 end
    if message >= ReleaseMessageBase then return 2 end
    if message >= HoverMessageBase then return 1 end
    return 0
  end

  function ContainerProtocolGetSlotPointerBase(message: int) -> int
    if message >= DragEndMessageBase then return DragEndMessageBase end
    if message >= ReleaseMessageBase then return ReleaseMessageBase end
    if message >= HoverMessageBase then return HoverMessageBase end
    return 0
  end
end
