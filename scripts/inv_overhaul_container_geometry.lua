module inv_overhaul_container_geometry do
  local const c_iPanelPointerStride: int = 2000
  local const c_iSlotHotZone: int = 52
  local const c_iSlotDropInset: int = 1

  function ContainerGeometryGetVisibleSlots(windowWidth: int) -> int
    if windowWidth >= 1000 then return 35 end
    return 24
  end

  function ContainerGeometryGetGridStartX(windowWidth: int) -> int
    if windowWidth >= 1900 then return 825 end
    if windowWidth >= 1200 then return 507 end
    if windowWidth >= 1000 then return 468 end
    return 359
  end

  function ContainerGeometryGetGridStartY(windowWidth: int) -> int
    if windowWidth >= 1900 then return 245 end
    if windowWidth >= 1200 then return 182 end
    if windowWidth >= 1000 then return 186 end
    return 145
  end

  function ContainerGeometryGetGridStep(windowWidth: int) -> int
    if windowWidth >= 1900 then return 96 end
    if windowWidth >= 1200 then return 96 end
    if windowWidth >= 1000 then return 61 end
    return 58
  end

  function ContainerGeometryGetGridColumns(windowWidth: int) -> int
    if windowWidth >= 1900 then return 7 end
    if windowWidth >= 1200 then return 7 end
    if windowWidth >= 1000 then return 7 end
    return 6
  end

  function ContainerGeometryGetContainerStartX(windowWidth: int) -> int
    if windowWidth >= 1900 then return 455 end
    if windowWidth >= 1200 then return 170 end
    if windowWidth >= 1000 then return 121 end
    return 79
  end

  function ContainerGeometryGetContainerStartY(windowWidth: int) -> int
    return ContainerGeometryGetGridStartY(windowWidth)
  end

  function ContainerGeometryGetOrganStartX(windowWidth: int) -> int
    if windowWidth >= 1900 then return 469 end
    if windowWidth >= 1200 then return 138 end
    if windowWidth >= 1000 then return 90 end
    return 49
  end

  function ContainerGeometryGetOrganStartY(windowWidth: int) -> int
    if windowWidth >= 1900 then return 780 end
    if windowWidth >= 1200 then return 690 end
    if windowWidth >= 1000 then return 570 end
    return 482
  end

  function ContainerGeometryGetOrganStep(windowWidth: int) -> int
    if windowWidth >= 1900 then return 67 end
    if windowWidth >= 1200 then return 64 end
    return ContainerGeometryGetGridStep(windowWidth)
  end

  function ContainerGeometryGetMoneyLeft(windowWidth: int) -> int
    if windowWidth >= 1900 then return 1390 end
    if windowWidth >= 1200 then return 1100 end
    if windowWidth >= 1000 then return 864 end
    return 655
  end

  function ContainerGeometryGetMoneyTop(windowWidth: int) -> int
    if windowWidth >= 1900 then return 780 end
    if windowWidth >= 1200 then return 690 end
    if windowWidth >= 1000 then return 616 end
    return 465
  end

  function ContainerGeometryGetSlotHotZone(windowWidth: int) -> int
    if windowWidth >= 1200 then return 82 end
    return c_iSlotHotZone
  end

  function ContainerGeometryGetOrganSlotHotZone(windowWidth: int) -> int
    if windowWidth >= 1900 then return 57 end
    return c_iSlotHotZone
  end

  function ContainerGeometryIsInsideSlotDropArea(
    localX: int,
    localY: int,
    hotZone: int) -> bool
    return localX >= c_iSlotDropInset && localY >= c_iSlotDropInset &&
      localX < hotZone - c_iSlotDropInset && localY < hotZone - c_iSlotDropInset
  end

  function ContainerGeometryFindGridSlotAt(
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
    if !ContainerGeometryIsInsideSlotDropArea(localX, localY, hotZone) then return -1 end
    local slot: int = row * columns + column
    if slot < 0 || slot >= count then return -1 end
    return slot
  end

  function ContainerGeometryFindPlayerSlotAt(
    windowWidth: int,
    visibleSlots: int,
    x: int,
    y: int) -> int
    local columns: int = ContainerGeometryGetGridColumns(windowWidth)
    local rows: int = (visibleSlots + columns - 1) / columns
    return ContainerGeometryFindGridSlotAt(
      x, y,
      ContainerGeometryGetGridStartX(windowWidth),
      ContainerGeometryGetGridStartY(windowWidth),
      columns, rows, visibleSlots,
      ContainerGeometryGetSlotHotZone(windowWidth),
      ContainerGeometryGetGridStep(windowWidth))
  end

  function ContainerGeometryFindContainerSlotAt(
    windowWidth: int,
    slotCount: int,
    x: int,
    y: int) -> int
    return ContainerGeometryFindGridSlotAt(
      x, y,
      ContainerGeometryGetContainerStartX(windowWidth),
      ContainerGeometryGetContainerStartY(windowWidth),
      3, 4, slotCount,
      ContainerGeometryGetSlotHotZone(windowWidth),
      ContainerGeometryGetGridStep(windowWidth))
  end

  function ContainerGeometryFindOrganSlotAt(
    windowWidth: int,
    slotCount: int,
    x: int,
    y: int) -> int
    return ContainerGeometryFindGridSlotAt(
      x, y,
      ContainerGeometryGetOrganStartX(windowWidth),
      ContainerGeometryGetOrganStartY(windowWidth),
      4, 1, slotCount,
      ContainerGeometryGetOrganSlotHotZone(windowWidth),
      ContainerGeometryGetOrganStep(windowWidth))
  end

  function ContainerGeometryIsInsideMoney(windowWidth: int, x: int, y: int) -> bool
    local left: int = ContainerGeometryGetMoneyLeft(windowWidth)
    local top: int = ContainerGeometryGetMoneyTop(windowWidth)
    local hotZone: int = ContainerGeometryGetSlotHotZone(windowWidth)
    return x >= left && y >= top && x < left + hotZone && y < top + hotZone
  end

  function ContainerGeometryIsInsideQuickslotHelp(windowWidth: int, x: int, y: int) -> bool
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

  function ContainerGeometryGetPlayerPageControlX(windowWidth: int) -> int
    if windowWidth >= 1900 then return 1082 end
    if windowWidth >= 1200 then return 778 end
    if windowWidth >= 1000 then return 626 end
    return 467
  end

  function ContainerGeometryGetPlayerPageControlY(windowWidth: int) -> int
    if windowWidth >= 1900 then return 826 end
    if windowWidth >= 1200 then return 736 end
    if windowWidth >= 1000 then return 632 end
    return 481
  end

  function ContainerGeometryGetContainerPageControlX(windowWidth: int) -> int
    local controlX: int = ContainerGeometryGetContainerStartX(windowWidth) + 28
    if windowWidth >= 1900 then controlX = ContainerGeometryGetContainerStartX(windowWidth) + 73 end
    if windowWidth >= 1200 && windowWidth < 1900 then
      controlX = ContainerGeometryGetContainerStartX(windowWidth) + 71
    end
    return controlX
  end

  function ContainerGeometryGetContainerPageControlY(windowWidth: int, slotCount: int) -> int
    return ContainerGeometryGetContainerStartY(windowWidth) +
      slotCount / 3 * ContainerGeometryGetGridStep(windowWidth) - 4
  end

  function ContainerGeometryIsInsidePageControl(
    maxPage: int,
    x: int,
    y: int,
    controlX: int,
    controlY: int) -> bool
    if maxPage <= 0 then return false end
    return x >= controlX && x < controlX + 132 && y >= controlY && y < controlY + 36
  end

  function ContainerGeometryGetPageControlAction(
    x: int,
    y: int,
    controlX: int,
    controlY: int) -> int
    if y < controlY || y >= controlY + 36 then return 0 end
    if x >= controlX && x < controlX + 40 then return -1 end
    if x >= controlX + 92 && x < controlX + 132 then return 1 end
    return 0
  end

  function ContainerGeometryIsPageButtonHovered(
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
    return ContainerGeometryGetPageControlAction(x, y, controlX, controlY) == action
  end

  function ContainerGeometryDecodePanelPointerX(message: int, base: int) -> int
    return (message - base) / c_iPanelPointerStride
  end

  function ContainerGeometryDecodePanelPointerY(message: int, base: int) -> int
    local encoded: int = message - base
    local x: int = encoded / c_iPanelPointerStride
    return encoded - x * c_iPanelPointerStride
  end
end
