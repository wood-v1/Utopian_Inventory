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

  function IsPlayerTarget(target: int, visibleSlots: int) -> bool
    return target >= 0 && target < visibleSlots
  end

  function IsContainerTarget(target: int) -> bool
    return target >= TargetContainerBase &&
      target < TargetContainerBase + ContainerSlots
  end

  function IsOrganTarget(target: int) -> bool
    return target >= TargetOrganBase && target < TargetOrganBase + OrganSlots
  end

  function GetContainerSlot(target: int) -> int
    if !IsContainerTarget(target) then return -1 end
    return target - TargetContainerBase
  end

  function GetOrganSlot(target: int) -> int
    if !IsOrganTarget(target) then return -1 end
    return target - TargetOrganBase
  end

  function LootProtocolGetTargetBySender(
    sender: string,
    visibleSlots: int) -> int
    for slot = 0, visibleSlots - 1 do
      if sender == inv_overhaul_container_view.GetPlayerSlotWndName(slot) then
        return slot
      end
    end
    for slot = 0, ContainerSlots - 1 do
      if sender == inv_overhaul_container_view.GetContainerSlotWndName(slot) then
        return TargetContainerBase + slot
      end
    end
    for slot = 0, OrganSlots - 1 do
      if sender == inv_overhaul_container_view.GetOrganSlotWndName(slot) then
        return TargetOrganBase + slot
      end
    end
    if sender == "drop_slot" then return TargetDrop end
    return -1
  end

  function LootProtocolFindTargetAt(
    windowWidth: int,
    visibleSlots: int,
    showOrgans: bool,
    x: int,
    y: int) -> int
    local slot: int =
      inv_overhaul_container_geometry.FindPlayerSlotAt(
        windowWidth, visibleSlots, x, y)
    if slot >= 0 then return slot end
    slot = inv_overhaul_container_geometry.FindContainerSlotAt(
      windowWidth, ContainerSlots, x, y)
    if slot >= 0 then return TargetContainerBase + slot end
    if showOrgans then
      slot = inv_overhaul_container_geometry.FindOrganSlotAt(
        windowWidth, OrganSlots, x, y)
      if slot >= 0 then return TargetOrganBase + slot end
    end
    return -1
  end

  function LootProtocolIsTargetCompatible(
    sourceKind: int,
    target: int,
    visibleSlots: int) -> bool
    if sourceKind == 0 then
      return IsPlayerTarget(target, visibleSlots) ||
        IsContainerTarget(target)
    end
    if sourceKind == 1 then
      return IsPlayerTarget(target, visibleSlots) ||
        IsContainerTarget(target)
    end
    if sourceKind == 2 then
      return IsPlayerTarget(target, visibleSlots)
    end
    return false
  end

  function LootProtocolGetSlotTargetFromPointerMessage(
    message: int,
    base: int,
    sender: string,
    visibleSlots: int,
    windowWidth: int) -> int
    local target: int = LootProtocolGetTargetBySender(sender, visibleSlots)
    if target < 0 then return -1 end
    local encoded: int = message - base
    local localX: int = encoded / SlotPointerStride
    local localY: int = encoded - localX * SlotPointerStride
    local hotZone: int =
      inv_overhaul_container_geometry.GetSlotHotZone(windowWidth)
    if IsOrganTarget(target) then
      hotZone =
        inv_overhaul_container_geometry.GetOrganSlotHotZone(windowWidth)
    end
    if inv_overhaul_container_geometry.LootGeometryIsInsideSlotDropArea(
      localX, localY, hotZone) then return target end
    return -1
  end

  function IsPanelPointerMessage(message: int) -> bool
    return message >= PanelPointerMoveBase
  end

  function GetPanelPointerAction(message: int) -> int
    if message >= PanelPointerLeaveBase then return -1 end
    if message >= PanelPointerDragEndBase then return 3 end
    if message >= PanelPointerDragBeginBase then return 1 end
    if message >= PanelPointerRightBase then return 2 end
    if message >= PanelPointerUpBase then return 3 end
    if message >= PanelPointerDownBase then return 1 end
    return 0
  end

  function GetPanelPointerBase(message: int) -> int
    if message >= PanelPointerDragEndBase then return PanelPointerDragEndBase end
    if message >= PanelPointerDragBeginBase then return PanelPointerDragBeginBase end
    if message >= PanelPointerRightBase then return PanelPointerRightBase end
    if message >= PanelPointerUpBase then return PanelPointerUpBase end
    if message >= PanelPointerDownBase then return PanelPointerDownBase end
    return PanelPointerMoveBase
  end

  function GetSlotPointerAction(message: int) -> int
    if message >= DragEndMessageBase then return 3 end
    if message >= ReleaseMessageBase then return 2 end
    if message >= HoverMessageBase then return 1 end
    return 0
  end

  function GetSlotPointerBase(message: int) -> int
    if message >= DragEndMessageBase then return DragEndMessageBase end
    if message >= ReleaseMessageBase then return ReleaseMessageBase end
    if message >= HoverMessageBase then return HoverMessageBase end
    return 0
  end
end
