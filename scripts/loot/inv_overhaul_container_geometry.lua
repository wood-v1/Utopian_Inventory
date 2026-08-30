module inv_overhaul_container_geometry do
  local const c_iPanelPointerStride: int = 2000
  local const c_iSlotHotZone: int = 52
  local const c_iSlotDropInset: int = 1

  function LootGeometryGetVisibleSlots(windowWidth: int) -> int
    if windowWidth >= 1000 then return 35 end
    return 24
  end

  function LootGeometryGetGridStartX(windowWidth: int) -> int
    if windowWidth >= 1900 then return 825 end
    if windowWidth >= 1200 then return 507 end
    if windowWidth >= 1000 then return 468 end
    return 359
  end

  function LootGeometryGetGridStartY(windowWidth: int) -> int
    if windowWidth >= 1900 then return 245 end
    if windowWidth >= 1200 then return 182 end
    if windowWidth >= 1000 then return 186 end
    return 145
  end

  function LootGeometryGetGridStep(windowWidth: int) -> int
    if windowWidth >= 1900 then return 96 end
    if windowWidth >= 1200 then return 96 end
    if windowWidth >= 1000 then return 61 end
    return 58
  end

  function LootGeometryGetGridColumns(windowWidth: int) -> int
    if windowWidth >= 1900 then return 7 end
    if windowWidth >= 1200 then return 7 end
    if windowWidth >= 1000 then return 7 end
    return 6
  end

  function GetContainerStartX(windowWidth: int) -> int
    if windowWidth >= 1900 then return 455 end
    if windowWidth >= 1200 then return 170 end
    if windowWidth >= 1000 then return 121 end
    return 79
  end

  function GetContainerStartY(windowWidth: int) -> int
    return LootGeometryGetGridStartY(windowWidth)
  end

  function GetOrganStartX(windowWidth: int) -> int
    if windowWidth >= 1900 then return 469 end
    if windowWidth >= 1200 then return 138 end
    if windowWidth >= 1000 then return 90 end
    return 49
  end

  function GetOrganStartY(windowWidth: int) -> int
    if windowWidth >= 1900 then return 780 end
    if windowWidth >= 1200 then return 690 end
    if windowWidth >= 1000 then return 570 end
    return 482
  end

  function GetOrganStep(windowWidth: int) -> int
    if windowWidth >= 1900 then return 67 end
    if windowWidth >= 1200 then return 64 end
    return LootGeometryGetGridStep(windowWidth)
  end

  function LootGeometryGetMoneyLeft(windowWidth: int) -> int
    if windowWidth >= 1900 then return 1390 end
    if windowWidth >= 1200 then return 1100 end
    if windowWidth >= 1000 then return 864 end
    return 655
  end

  function LootGeometryGetMoneyTop(windowWidth: int) -> int
    if windowWidth >= 1900 then return 780 end
    if windowWidth >= 1200 then return 690 end
    if windowWidth >= 1000 then return 616 end
    return 465
  end

  function GetSlotHotZone(windowWidth: int) -> int
    if windowWidth >= 1200 then return 82 end
    return c_iSlotHotZone
  end

  function GetOrganSlotHotZone(windowWidth: int) -> int
    if windowWidth >= 1900 then return 57 end
    return c_iSlotHotZone
  end

  function LootGeometryIsInsideSlotDropArea(
    localX: int,
    localY: int,
    hotZone: int) -> bool
    return localX >= c_iSlotDropInset && localY >= c_iSlotDropInset &&
      localX < hotZone - c_iSlotDropInset && localY < hotZone - c_iSlotDropInset
  end

  function FindGridSlotAt(
    x: int,
    y: int,
    startX: int,
    startY: int,
    columns: int,
    rows: int,
    count: int,
    hotZone: int,
    step: int) -> int
    if x < startX || y < startY ||
      x >= startX + columns * step || y >= startY + rows * step then return -1 end
    local column: int = (x - startX) / step
    local row: int = (y - startY) / step
    local localX: int = x - startX - column * step
    local localY: int = y - startY - row * step
    if !LootGeometryIsInsideSlotDropArea(localX, localY, hotZone) then return -1 end
    local slot: int = row * columns + column
    if slot < 0 || slot >= count then return -1 end
    return slot
  end

  function FindPlayerSlotAt(
    windowWidth: int,
    visibleSlots: int,
    x: int,
    y: int) -> int
    local columns: int = LootGeometryGetGridColumns(windowWidth)
    local rows: int = (visibleSlots + columns - 1) / columns
    return FindGridSlotAt(
      x, y,
      LootGeometryGetGridStartX(windowWidth),
      LootGeometryGetGridStartY(windowWidth),
      columns, rows, visibleSlots,
      GetSlotHotZone(windowWidth),
      LootGeometryGetGridStep(windowWidth))
  end

  function FindContainerSlotAt(
    windowWidth: int,
    slotCount: int,
    x: int,
    y: int) -> int
    return FindGridSlotAt(
      x, y,
      GetContainerStartX(windowWidth),
      GetContainerStartY(windowWidth),
      3, 4, slotCount,
      GetSlotHotZone(windowWidth),
      LootGeometryGetGridStep(windowWidth))
  end

  function FindOrganSlotAt(
    windowWidth: int,
    slotCount: int,
    x: int,
    y: int) -> int
    return FindGridSlotAt(
      x, y,
      GetOrganStartX(windowWidth),
      GetOrganStartY(windowWidth),
      4, 1, slotCount,
      GetOrganSlotHotZone(windowWidth),
      GetOrganStep(windowWidth))
  end

  function LootGeometryIsInsideMoney(windowWidth: int, x: int, y: int) -> bool
    local left: int = LootGeometryGetMoneyLeft(windowWidth)
    local top: int = LootGeometryGetMoneyTop(windowWidth)
    local hotZone: int = GetSlotHotZone(windowWidth)
    return x >= left && y >= top && x < left + hotZone && y < top + hotZone
  end

  function LootGeometryIsInsideQuickslotHelp(windowWidth: int, x: int, y: int) -> bool
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
    return x >= helpX && x < helpX + 28 && y >= helpY && y < helpY + 28
  end

  function GetPlayerPageControlX(windowWidth: int) -> int
    if windowWidth >= 1900 then return 1082 end
    if windowWidth >= 1200 then return 778 end
    if windowWidth >= 1000 then return 626 end
    return 467
  end

  function GetPlayerPageControlY(windowWidth: int) -> int
    if windowWidth >= 1900 then return 826 end
    if windowWidth >= 1200 then return 736 end
    if windowWidth >= 1000 then return 632 end
    return 481
  end

  function GetContainerPageControlX(windowWidth: int) -> int
    local controlX: int = GetContainerStartX(windowWidth) + 28
    if windowWidth >= 1900 then controlX = GetContainerStartX(windowWidth) + 73 end
    if windowWidth >= 1200 && windowWidth < 1900 then
      controlX = GetContainerStartX(windowWidth) + 71
    end
    return controlX
  end

  function GetContainerPageControlY(windowWidth: int, slotCount: int) -> int
    return GetContainerStartY(windowWidth) +
      slotCount / 3 * LootGeometryGetGridStep(windowWidth) - 4
  end

  function IsInsidePageControl(
    maxPage: int,
    x: int,
    y: int,
    controlX: int,
    controlY: int) -> bool
    if maxPage <= 0 then return false end
    return x >= controlX && x < controlX + 132 && y >= controlY && y < controlY + 36
  end

  function GetPageControlAction(
    x: int,
    y: int,
    controlX: int,
    controlY: int) -> int
    if y < controlY || y >= controlY + 36 then return 0 end
    if x >= controlX && x < controlX + 40 then return -1 end
    if x >= controlX + 92 && x < controlX + 132 then return 1 end
    return 0
  end

  function IsPageButtonHovered(
    action: int,
    currentPage: int,
    maxPage: int,
    x: int,
    y: int,
    controlX: int,
    controlY: int) -> bool
    if maxPage <= 0 then return false end
    if action < 0 && currentPage <= 0 then return false end
    if action > 0 && currentPage >= maxPage then return false end
    return GetPageControlAction(x, y, controlX, controlY) == action
  end

  function LootGeometryDecodePanelPointerX(message: int, base: int) -> int
    return (message - base) / c_iPanelPointerStride
  end

  function LootGeometryDecodePanelPointerY(message: int, base: int) -> int
    local encoded: int = message - base
    local x: int = encoded / c_iPanelPointerStride
    return encoded - x * c_iPanelPointerStride
  end
end
