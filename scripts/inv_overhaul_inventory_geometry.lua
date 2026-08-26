import "inv_overhaul_inventory_protocol"

module inv_overhaul_inventory_geometry do
  function InventoryGeometryGetGridStartX(windowWidth: int) -> int
    if windowWidth >= 1900 then return 825 end
    if windowWidth >= 1200 then return 507 end
    if windowWidth >= 1000 then return 460 end
    return 351
  end

  function InventoryGeometryGetGridStartY(windowWidth: int) -> int
    if windowWidth >= 1900 then return 245 end
    if windowWidth >= 1200 then return 182 end
    if windowWidth >= 1000 then return 186 end
    return 145
  end

  function InventoryGeometryGetGridStep(windowWidth: int) -> int
    if windowWidth >= 1900 then return 96 end
    if windowWidth >= 1200 then return 96 end
    if windowWidth >= 1000 then return 61 end
    return 58
  end

  function InventoryGeometryGetGridColumns(windowWidth: int) -> int
    if windowWidth >= 1900 then return 7 end
    if windowWidth >= 1200 then return 7 end
    if windowWidth >= 1000 then return 7 end
    return 6
  end

  function InventoryGeometryGetVisibleSlots(windowWidth: int) -> int
    if windowWidth >= 1900 then return 35 end
    if windowWidth >= 1200 then return 35 end
    if windowWidth >= 1000 then return 35 end
    return 24
  end

  function InventoryGeometryGetSlotSize(windowWidth: int) -> int
    if windowWidth >= 1200 then return 82 end
    return 52
  end

  function InventoryGeometryGetEquipmentSlotSize(windowWidth: int) -> int
    if windowWidth >= 1900 then return 48 end
    return 52
  end

  function InventoryGeometryIsInsideRect(
    x: int,
    y: int,
    left: int,
    top: int,
    width: int,
    height: int) -> bool
    return x >= left && y >= top && x < left + width && y < top + height
  end

  function InventoryGeometryIsInsideSlotDropArea(
    windowWidth: int,
    inset: int,
    localX: int,
    localY: int) -> bool
    local size: int = InventoryGeometryGetSlotSize(windowWidth)
    return localX >= inset && localY >= inset && localX < size - inset && localY < size - inset
  end

  function InventoryGeometryFindBackpackSlot(
    windowWidth: int,
    visibleSlots: int,
    inset: int,
    x: int,
    y: int) -> int
    local startX: int = InventoryGeometryGetGridStartX(windowWidth)
    local startY: int = InventoryGeometryGetGridStartY(windowWidth)
    local step: int = InventoryGeometryGetGridStep(windowWidth)
    local columns: int = InventoryGeometryGetGridColumns(windowWidth)
    if x < startX || y < startY then return -1 end

    local rows: int = (visibleSlots + columns - 1) / columns
    if x >= startX + columns * step || y >= startY + rows * step then return -1 end

    local column: int = (x - startX) / step
    local row: int = (y - startY) / step
    if column < 0 || column >= columns || row < 0 || row >= rows then return -1 end

    local localX: int = x - startX - column * step
    local localY: int = y - startY - row * step
    if !InventoryGeometryIsInsideSlotDropArea(windowWidth, inset, localX, localY) then return -1 end

    local slot: int = row * columns + column
    if slot < 0 || slot >= visibleSlots then return -1 end
    return slot
  end

  function InventoryGeometryGetSpecialTargetLeft(windowWidth: int, branch: int, target: int) -> int
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

  function InventoryGeometryGetSpecialTargetTop(windowWidth: int, branch: int, target: int) -> int
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

  function InventoryGeometryIsInsideSpecialTarget(
    windowWidth: int,
    branch: int,
    target: int,
    x: int,
    y: int) -> bool
    local left: int = InventoryGeometryGetSpecialTargetLeft(windowWidth, branch, target)
    local top: int = InventoryGeometryGetSpecialTargetTop(windowWidth, branch, target)
    local size: int = InventoryGeometryGetEquipmentSlotSize(windowWidth)
    if target == inv_overhaul_inventory_protocol.TargetDrop then
      size = InventoryGeometryGetSlotSize(windowWidth)
    end
    return InventoryGeometryIsInsideRect(x, y, left, top, size, size)
  end

  function InventoryGeometryGetMoneyLeft(windowWidth: int) -> int
    if windowWidth >= 1900 then return 1390 end
    if windowWidth >= 1200 then return 1100 end
    if windowWidth >= 1000 then return 864 end
    return 655
  end

  function InventoryGeometryGetMoneyTop(windowWidth: int, branch: int) -> int
    if windowWidth >= 1900 then return 780 end
    if windowWidth >= 1200 then return 690 end
    if windowWidth >= 1000 then
      if branch == 2 then return 550 end
      return 616
    end
    if branch == 2 then return 440 end
    return 465
  end

  function InventoryGeometryIsInsideMoney(windowWidth: int, branch: int, x: int, y: int) -> bool
    return InventoryGeometryIsInsideRect(
      x,
      y,
      InventoryGeometryGetMoneyLeft(windowWidth),
      InventoryGeometryGetMoneyTop(windowWidth, branch),
      InventoryGeometryGetSlotSize(windowWidth),
      InventoryGeometryGetSlotSize(windowWidth))
  end

  function InventoryGeometryGetPageControlX(windowWidth: int) -> int
    if windowWidth >= 1900 then return 1082 end
    if windowWidth >= 1200 then return 778 end
    if windowWidth >= 1000 then return 622 end
    return 463
  end

  function InventoryGeometryGetPageControlY(windowWidth: int, branch: int) -> int
    if windowWidth >= 1900 then return 826 end
    if windowWidth >= 1200 then return 736 end
    if windowWidth >= 1000 then
      if branch == 2 then return 558 end
      return 632
    end
    if branch == 2 then return 448 end
    return 481
  end

  function InventoryGeometryIsInsidePlayerPaging(
    windowWidth: int,
    branch: int,
    maxPage: int,
    x: int,
    y: int) -> bool
    if maxPage <= 0 then return false end
    return InventoryGeometryIsInsideRect(
      x,
      y,
      InventoryGeometryGetPageControlX(windowWidth),
      InventoryGeometryGetPageControlY(windowWidth, branch),
      132,
      36)
  end

  function InventoryGeometryIsInsideQuickslotHelp(windowWidth: int, x: int, y: int) -> bool
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
    return InventoryGeometryIsInsideRect(x, y, helpX, helpY, 28, 28)
  end

  function InventoryGeometryGetDollLeft(layoutWidth: int) -> int
    if layoutWidth >= 1900 then return 395 end
    if layoutWidth >= 1200 then return 75 end
    if layoutWidth >= 1000 then return 60 end
    return 50
  end

  function InventoryGeometryGetDollTop(layoutWidth: int) -> int
    if layoutWidth >= 1900 then return 290 end
    if layoutWidth >= 1200 then return 230 end
    if layoutWidth >= 1000 then return 187 end
    return 157
  end

  function InventoryGeometryGetDollTargetMessage(
    layoutWidth: int,
    branch: int,
    globalX: int,
    globalY: int) -> int
    local target: int = inv_overhaul_inventory_protocol.TargetWeapon
    if InventoryGeometryIsInsideRect(
      globalX, globalY,
      InventoryGeometryGetSpecialTargetLeft(layoutWidth, branch, target),
      InventoryGeometryGetSpecialTargetTop(layoutWidth, branch, target), 52, 52) then return -50 end
    target = inv_overhaul_inventory_protocol.TargetClothesBase + 1
    if InventoryGeometryIsInsideRect(
      globalX, globalY,
      InventoryGeometryGetSpecialTargetLeft(layoutWidth, branch, target),
      InventoryGeometryGetSpecialTargetTop(layoutWidth, branch, target), 52, 52) then return -51 end
    target = inv_overhaul_inventory_protocol.TargetClothesBase + 2
    if InventoryGeometryIsInsideRect(
      globalX, globalY,
      InventoryGeometryGetSpecialTargetLeft(layoutWidth, branch, target),
      InventoryGeometryGetSpecialTargetTop(layoutWidth, branch, target), 52, 52) then return -52 end
    target = inv_overhaul_inventory_protocol.TargetClothesBase + 3
    if InventoryGeometryIsInsideRect(
      globalX, globalY,
      InventoryGeometryGetSpecialTargetLeft(layoutWidth, branch, target),
      InventoryGeometryGetSpecialTargetTop(layoutWidth, branch, target), 52, 52) then return -53 end
    target = inv_overhaul_inventory_protocol.TargetClothesBase + 4
    if InventoryGeometryIsInsideRect(
      globalX, globalY,
      InventoryGeometryGetSpecialTargetLeft(layoutWidth, branch, target),
      InventoryGeometryGetSpecialTargetTop(layoutWidth, branch, target), 52, 52) then return -54 end
    return 0
  end
end
