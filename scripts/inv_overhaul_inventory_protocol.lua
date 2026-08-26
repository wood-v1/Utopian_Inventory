module inv_overhaul_inventory_protocol do
  local const PointerMoveBase: int = 1000000
  local const PointerDownBase: int = 4000000
  local const PointerUpBase: int = 7000000
  local const PointerRightBase: int = 10000000
  local const PointerDragBeginBase: int = 13000000
  local const PointerDragEndBase: int = 16000000
  local const PointerLeaveBase: int = 19000000
  local const PointerStride: int = 2000

  local const GridRendererMessageBase: int = 30000000
  local const GridRendererSlotStride: int = 100000
  local const GridRendererOperationStride: int = 20000
  local const GridRendererItem: int = 1
  local const GridRendererEmpty: int = 2
  local const GridRendererHidden: int = 3
  local const GridRendererHighlight: int = 4
  local const GridRendererReady: int = 29900000

  local const TargetWeapon: int = 100
  local const TargetClothesBase: int = 100
  local const TargetDrop: int = 200
  local const TargetMoney: int = 300
  local const TargetPaging: int = 400
  local const TargetQuickslotHelp: int = 401
  local const QuickslotHelpHover: int = 29800001
  local const PageHoverEnter: int = -110
  local const PageHoverLeave: int = -111

  function InventoryProtocolEncodePanelPointer(base: int, x: int, y: int) -> int
    return base + x * PointerStride + y
  end

  function InventoryProtocolDecodePanelPointerX(message: int, base: int) -> int
    return (message - base) / PointerStride
  end

  function InventoryProtocolDecodePanelPointerY(message: int, base: int) -> int
    local encoded: int = message - base
    local x: int = encoded / PointerStride
    return encoded - x * PointerStride
  end

  function InventoryProtocolEncodeGridRenderer(slot: int, operation: int, value: int) -> int
    return GridRendererMessageBase + slot * GridRendererSlotStride +
      operation * GridRendererOperationStride + value
  end

  function InventoryProtocolDecodeGridRendererSlot(message: int) -> int
    return (message - GridRendererMessageBase) / GridRendererSlotStride
  end

  function InventoryProtocolDecodeGridRendererOperation(message: int) -> int
    local encoded: int = message - GridRendererMessageBase
    local slot: int = encoded / GridRendererSlotStride
    encoded = encoded - slot * GridRendererSlotStride
    return encoded / GridRendererOperationStride
  end

  function InventoryProtocolDecodeGridRendererValue(message: int) -> int
    local encoded: int = message - GridRendererMessageBase
    local slot: int = encoded / GridRendererSlotStride
    encoded = encoded - slot * GridRendererSlotStride
    local operation: int = encoded / GridRendererOperationStride
    return encoded - operation * GridRendererOperationStride
  end

  function InventoryProtocolGetSlotWindowName(slot: int) -> string
    local number: int = slot + 1
    if number < 10 then return "slot0" + number end
    return "slot" + number
  end

  function InventoryProtocolGetSlotBySender(sender: string, visibleSlots: int) -> int
    for slot = 0, visibleSlots - 1 do
      if sender == InventoryProtocolGetSlotWindowName(slot) then return slot end
    end
    return -1
  end

  function InventoryProtocolGetSpecialTargetBySender(sender: string) -> int
    if sender == "equip_weapon" then return TargetWeapon end
    if sender == "equip_feet" then return TargetClothesBase + 1 end
    if sender == "equip_head" then return TargetClothesBase + 2 end
    if sender == "equip_body" then return TargetClothesBase + 3 end
    if sender == "equip_hands" then return TargetClothesBase + 4 end
    if sender == "drop_slot" then return TargetDrop end
    return -1
  end

  function InventoryProtocolGetDollTargetByHoverMessage(message: int) -> int
    if message == -50 then return TargetWeapon end
    if message == -51 then return TargetClothesBase + 1 end
    if message == -52 then return TargetClothesBase + 2 end
    if message == -53 then return TargetClothesBase + 3 end
    if message == -54 then return TargetClothesBase + 4 end
    return -1
  end

  function InventoryProtocolGetDollTargetBySourceMessage(message: int, base: int) -> int
    local offset: int = base - message
    if offset == 0 then return TargetWeapon end
    if offset >= 1 && offset <= 4 then return TargetClothesBase + offset end
    return -1
  end

  function InventoryProtocolGetDollSourceMessage(targetMessage: int, base: int) -> int
    if targetMessage == -50 then return base end
    if targetMessage <= -51 && targetMessage >= -54 then
      return base - (-50 - targetMessage)
    end
    return 0
  end
end
