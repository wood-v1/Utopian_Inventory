import "inv_overhaul_inventory_protocol"

module inv_overhaul_inventory_geometry do
  function InterfaceGeometryGetGridStartX(windowWidth: int) -> int
    if windowWidth >= 1900 then return 825 end
    if windowWidth >= 1200 then return 507 end
    if windowWidth >= 1000 then return 460 end
    return 351
  end

  function InterfaceGeometryGetGridStartY(windowWidth: int) -> int
    if windowWidth >= 1900 then return 245 end
    if windowWidth >= 1200 then return 182 end
    if windowWidth >= 1000 then return 186 end
    return 145
  end

  function InterfaceGeometryGetGridStep(windowWidth: int) -> int
    if windowWidth >= 1900 then return 96 end
    if windowWidth >= 1200 then return 96 end
    if windowWidth >= 1000 then return 61 end
    return 58
  end

  function InterfaceGeometryGetGridColumns(windowWidth: int) -> int
    if windowWidth >= 1900 then return 7 end
    if windowWidth >= 1200 then return 7 end
    if windowWidth >= 1000 then return 7 end
    return 6
  end

  function InterfaceGeometryGetVisibleSlots(windowWidth: int) -> int
    if windowWidth >= 1900 then return 35 end
    if windowWidth >= 1200 then return 35 end
    if windowWidth >= 1000 then return 35 end
    return 24
  end

  function GetSlotSize(windowWidth: int) -> int
    if windowWidth >= 1200 then return 82 end
    return 52
  end

  function GetEquipmentSlotSize(windowWidth: int) -> int
    if windowWidth >= 1900 then return 48 end
    return 52
  end

  function IsInsideRect(
    x: int,
    y: int,
    left: int,
    top: int,
    width: int,
    height: int) -> bool
    return x >= left && y >= top && x < left + width && y < top + height
  end

  function InterfaceGeometryIsInsideSlotDropArea(
    windowWidth: int,
    inset: int,
    localX: int,
    localY: int) -> bool
    local size: int = GetSlotSize(windowWidth)
    return localX >= inset && localY >= inset && localX < size - inset && localY < size - inset
  end

  function FindBackpackSlot(
    windowWidth: int,
    visibleSlots: int,
    inset: int,
    x: int,
    y: int) -> int
    local startX: int = InterfaceGeometryGetGridStartX(windowWidth)
    local startY: int = InterfaceGeometryGetGridStartY(windowWidth)
    local step: int = InterfaceGeometryGetGridStep(windowWidth)
    local columns: int = InterfaceGeometryGetGridColumns(windowWidth)
    if x < startX || y < startY then return -1 end

    local rows: int = (visibleSlots + columns - 1) / columns
    if x >= startX + columns * step || y >= startY + rows * step then return -1 end

    local column: int = (x - startX) / step
    local row: int = (y - startY) / step
    if column < 0 || column >= columns || row < 0 || row >= rows then return -1 end

    local localX: int = x - startX - column * step
    local localY: int = y - startY - row * step
    if !InterfaceGeometryIsInsideSlotDropArea(windowWidth, inset, localX, localY) then return -1 end

    local slot: int = row * columns + column
    if slot < 0 || slot >= visibleSlots then return -1 end
    return slot
  end

  function GetSpecialTargetLeft(windowWidth: int, branch: int, target: int) -> int
    local clara: bool = branch == 2
    if windowWidth >= 1900 then
      if target == inv_overhaul_inventory_protocol.TargetWeapon then return 660 end
      if target == inv_overhaul_inventory_protocol.TargetClothesBase + 1 then return 590 end
      if target == inv_overhaul_inventory_protocol.TargetClothesBase + 2 then return 590 end
      if target == inv_overhaul_inventory_protocol.TargetClothesBase + 3 then
        if clara then return 560 end
        return 590
      end
      if target == inv_overhaul_inventory_protocol.TargetClothesBase + 4 then return 445 end
      if target == inv_overhaul_inventory_protocol.TargetDrop then return 825 end
    else
      if windowWidth >= 1200 then
        if target == inv_overhaul_inventory_protocol.TargetWeapon then return 375 end
        if target == inv_overhaul_inventory_protocol.TargetClothesBase + 1 then return 270 end
        if target == inv_overhaul_inventory_protocol.TargetClothesBase + 2 then return 270 end
        if target == inv_overhaul_inventory_protocol.TargetClothesBase + 3 then
          if clara then return 250 end
          return 270
        end
        if target == inv_overhaul_inventory_protocol.TargetClothesBase + 4 then return 125 end
        if target == inv_overhaul_inventory_protocol.TargetDrop then return 507 end
      else
        if windowWidth >= 1000 then
          if target == inv_overhaul_inventory_protocol.TargetWeapon then return 299 end
          if target == inv_overhaul_inventory_protocol.TargetClothesBase + 1 then return 207 end
          if target == inv_overhaul_inventory_protocol.TargetClothesBase + 2 then return 207 end
          if target == inv_overhaul_inventory_protocol.TargetClothesBase + 3 then
            if clara then return 191 end
            return 207
          end
          if target == inv_overhaul_inventory_protocol.TargetClothesBase + 4 then return 86 end
          if target == inv_overhaul_inventory_protocol.TargetDrop then return 460 end
        else
          if target == inv_overhaul_inventory_protocol.TargetWeapon then
            if clara then return 213 end
            return 222
          end
          if target == inv_overhaul_inventory_protocol.TargetClothesBase + 1 then
            if clara then return 169 end
            return 156
          end
          if target == inv_overhaul_inventory_protocol.TargetClothesBase + 2 then
            if clara then return 169 end
            return 156
          end
          if target == inv_overhaul_inventory_protocol.TargetClothesBase + 3 then
            if clara then return 150 end
            return 156
          end
          if target == inv_overhaul_inventory_protocol.TargetClothesBase + 4 then
            if clara then return 78 end
            return 68
          end
          if target == inv_overhaul_inventory_protocol.TargetDrop then return 351 end
        end
      end
    end
    return -1000
  end

  function GetSpecialTargetTop(windowWidth: int, branch: int, target: int) -> int
    local clara: bool = branch == 2
    local headOffset: int = 8
    if windowWidth >= 1900 then
      headOffset = 15
      if clara then headOffset = 100 end
    else
      if windowWidth >= 1200 then
        headOffset = 12
        if clara then headOffset = 94 end
      else
        if windowWidth >= 1000 then
          headOffset = 9
          if clara then headOffset = 84 end
        else
          if clara then headOffset = 54 end
        end
      end
    end
    if windowWidth >= 1900 then
      if target == inv_overhaul_inventory_protocol.TargetWeapon then
        if clara then return 512 end
        return 580
      end
      if target == inv_overhaul_inventory_protocol.TargetClothesBase + 1 then return 800 end
      if target == inv_overhaul_inventory_protocol.TargetClothesBase + 2 then return 300 + headOffset end
      if target == inv_overhaul_inventory_protocol.TargetClothesBase + 3 then return 488 end
      if target == inv_overhaul_inventory_protocol.TargetClothesBase + 4 then return 560 end
      if target == inv_overhaul_inventory_protocol.TargetDrop then return 780 end
    else
      if windowWidth >= 1200 then
        if target == inv_overhaul_inventory_protocol.TargetWeapon then
          if clara then return 458 end
          return 528
        end
        if target == inv_overhaul_inventory_protocol.TargetClothesBase + 1 then return 660 end
        if target == inv_overhaul_inventory_protocol.TargetClothesBase + 2 then return 240 + headOffset end
        if target == inv_overhaul_inventory_protocol.TargetClothesBase + 3 then return 428 end
        if target == inv_overhaul_inventory_protocol.TargetClothesBase + 4 then return 500 end
        if target == inv_overhaul_inventory_protocol.TargetDrop then return 690 end
      else
        if windowWidth >= 1000 then
          if target == inv_overhaul_inventory_protocol.TargetWeapon then
            if clara then return 351 end
            return 418
          end
          if target == inv_overhaul_inventory_protocol.TargetClothesBase + 1 then
            if clara then return 550 end
            return 569
          end
          if target == inv_overhaul_inventory_protocol.TargetClothesBase + 2 then return 188 + headOffset end
          if target == inv_overhaul_inventory_protocol.TargetClothesBase + 3 then return 346 end
          if target == inv_overhaul_inventory_protocol.TargetClothesBase + 4 then return 399 end
          if target == inv_overhaul_inventory_protocol.TargetDrop then
            if clara then return 550 end
            return 616
          end
        else
          if target == inv_overhaul_inventory_protocol.TargetWeapon then
            if clara then return 283 end
            return 323
          end
          if target == inv_overhaul_inventory_protocol.TargetClothesBase + 1 then
            if clara then return 440 end
            return 429
          end
          if target == inv_overhaul_inventory_protocol.TargetClothesBase + 2 then return 159 + headOffset end
          if target == inv_overhaul_inventory_protocol.TargetClothesBase + 3 then
            if clara then return 290 end
            return 271
          end
          if target == inv_overhaul_inventory_protocol.TargetClothesBase + 4 then
            if clara then return 313 end
            return 311
          end
          if target == inv_overhaul_inventory_protocol.TargetDrop then
            if clara then return 440 end
            return 465
          end
        end
      end
    end
    return -1000
  end

  function InterfaceGeometryIsInsideSpecialTarget(
    windowWidth: int,
    branch: int,
    target: int,
    x: int,
    y: int) -> bool
    local left: int = GetSpecialTargetLeft(windowWidth, branch, target)
    local top: int = GetSpecialTargetTop(windowWidth, branch, target)
    local size: int = GetEquipmentSlotSize(windowWidth)
    if target == inv_overhaul_inventory_protocol.TargetDrop then
      size = GetSlotSize(windowWidth)
    end
    return IsInsideRect(x, y, left, top, size, size)
  end

  function InterfaceGeometryGetMoneyLeft(windowWidth: int) -> int
    if windowWidth >= 1900 then return 1390 end
    if windowWidth >= 1200 then return 1100 end
    if windowWidth >= 1000 then return 864 end
    return 655
  end

  function InterfaceGeometryGetMoneyTop(windowWidth: int, branch: int) -> int
    if windowWidth >= 1900 then return 780 end
    if windowWidth >= 1200 then return 690 end
    if windowWidth >= 1000 then
      if branch == 2 then return 550 end
      return 616
    end
    if branch == 2 then return 440 end
    return 465
  end

  function InterfaceGeometryIsInsideMoney(windowWidth: int, branch: int, x: int, y: int) -> bool
    return IsInsideRect(
      x,
      y,
      InterfaceGeometryGetMoneyLeft(windowWidth),
      InterfaceGeometryGetMoneyTop(windowWidth, branch),
      GetSlotSize(windowWidth),
      GetSlotSize(windowWidth))
  end

  function InterfaceGeometryGetPageControlX(windowWidth: int) -> int
    if windowWidth >= 1900 then return 1082 end
    if windowWidth >= 1200 then return 778 end
    if windowWidth >= 1000 then return 622 end
    return 463
  end

  function InterfaceGeometryGetPageControlY(windowWidth: int, branch: int) -> int
    if windowWidth >= 1900 then return 826 end
    if windowWidth >= 1200 then return 736 end
    if windowWidth >= 1000 then
      if branch == 2 then return 558 end
      return 632
    end
    if branch == 2 then return 448 end
    return 481
  end

  function InterfaceGeometryIsInsidePlayerPaging(
    windowWidth: int,
    branch: int,
    maxPage: int,
    x: int,
    y: int) -> bool
    if maxPage <= 0 then return false end
    return IsInsideRect(
      x,
      y,
      InterfaceGeometryGetPageControlX(windowWidth),
      InterfaceGeometryGetPageControlY(windowWidth, branch),
      132,
      36)
  end

  function InterfaceGeometryIsInsideQuickslotHelp(windowWidth: int, x: int, y: int) -> bool
    local helpX: int = 701
    local helpY: int = 121
    if windowWidth >= 1900 then
      helpX = 1486
      helpY = 211
    else
      if windowWidth >= 1200 then
        helpX = 1166
        helpY = 151
      else
        if windowWidth >= 1000 then
          helpX = 918
          helpY = 135
        end
      end
    end
    return IsInsideRect(x, y, helpX, helpY, 28, 28)
  end

  function GetDollLeft(layoutWidth: int) -> int
    if layoutWidth >= 1900 then return 395 end
    if layoutWidth >= 1200 then return 75 end
    if layoutWidth >= 1000 then return 60 end
    return 50
  end

  function GetDollTop(layoutWidth: int) -> int
    if layoutWidth >= 1900 then return 290 end
    if layoutWidth >= 1200 then return 230 end
    if layoutWidth >= 1000 then return 187 end
    return 157
  end

  function GetDollTargetMessage(
    layoutWidth: int,
    branch: int,
    globalX: int,
    globalY: int) -> int
    local target: int = inv_overhaul_inventory_protocol.TargetWeapon
    if IsInsideRect(
      globalX, globalY,
      GetSpecialTargetLeft(layoutWidth, branch, target),
      GetSpecialTargetTop(layoutWidth, branch, target), 52, 52) then return -50 end
    target = inv_overhaul_inventory_protocol.TargetClothesBase + 1
    if IsInsideRect(
      globalX, globalY,
      GetSpecialTargetLeft(layoutWidth, branch, target),
      GetSpecialTargetTop(layoutWidth, branch, target), 52, 52) then return -51 end
    target = inv_overhaul_inventory_protocol.TargetClothesBase + 2
    if IsInsideRect(
      globalX, globalY,
      GetSpecialTargetLeft(layoutWidth, branch, target),
      GetSpecialTargetTop(layoutWidth, branch, target), 52, 52) then return -52 end
    target = inv_overhaul_inventory_protocol.TargetClothesBase + 3
    if IsInsideRect(
      globalX, globalY,
      GetSpecialTargetLeft(layoutWidth, branch, target),
      GetSpecialTargetTop(layoutWidth, branch, target), 52, 52) then return -53 end
    target = inv_overhaul_inventory_protocol.TargetClothesBase + 4
    if IsInsideRect(
      globalX, globalY,
      GetSpecialTargetLeft(layoutWidth, branch, target),
      GetSpecialTargetTop(layoutWidth, branch, target), 52, 52) then return -54 end
    return 0
  end
end
