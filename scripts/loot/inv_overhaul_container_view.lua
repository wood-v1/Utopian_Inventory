module inv_overhaul_container_view do
  local const c_iSlotEmpty: int = 32768
  local const c_iSlotNumber: int = 65536
  local const c_iTargetDrop: int = 200
  local const c_iTargetContainerBase: int = 300
  local const c_iTargetOrganBase: int = 400
  local const c_iContainerSlots: int = 12
  local const c_iOrganSlots: int = 4

  function ContainerViewGetPlayerSlotWndName(slot: int) -> string
    local number: int = slot + 1
    if number < 10 then return "slot0" + number end
    return "slot" + number
  end

  function ContainerViewGetContainerSlotWndName(slot: int) -> string
    local number: int = slot + 1
    if number < 10 then return "cslot0" + number end
    return "cslot" + number
  end

  function ContainerViewGetOrganSlotWndName(slot: int) -> string
    local number: int = slot + 1
    if number < 10 then return "oslot0" + number end
    return "oslot" + number
  end

  function ContainerViewGetTargetWndName(target: int, visibleSlots: int) -> string
    if target >= 0 && target < visibleSlots then
      return ContainerViewGetPlayerSlotWndName(target)
    end
    if target >= c_iTargetContainerBase &&
      target < c_iTargetContainerBase + c_iContainerSlots then
      return ContainerViewGetContainerSlotWndName(target - c_iTargetContainerBase)
    end
    if target >= c_iTargetOrganBase && target < c_iTargetOrganBase + c_iOrganSlots then
      return ContainerViewGetOrganSlotWndName(target - c_iTargetOrganBase)
    end
    if target == c_iTargetDrop then return "drop_slot" end
    return ""
  end

  function ContainerViewConfigureSlotRenderSize(
    windowWidth: int,
    visibleSlots: int) -> void
    local sizeMessage: int = -27
    local organSizeMessage: int = -27
    if windowWidth >= 1200 then sizeMessage = -26 end
    if windowWidth >= 1900 then organSizeMessage = -29 end
    for slot = 0, visibleSlots - 1 do
      native.SendMessage(sizeMessage, ContainerViewGetPlayerSlotWndName(slot))
    end
    for slot = 0, c_iContainerSlots - 1 do
      native.SendMessage(sizeMessage, ContainerViewGetContainerSlotWndName(slot))
    end
    for slot = 0, c_iOrganSlots - 1 do
      native.SendMessage(organSizeMessage, ContainerViewGetOrganSlotWndName(slot))
    end
    native.SendMessage(sizeMessage, "money")
  end

  function ContainerViewUpdatePageControls(
    prefix: string,
    currentPage: int,
    maxPage: int) -> void
    local visibilityMessage: int = -93
    if maxPage > 0 then visibilityMessage = -92 end
    native.SendMessage(visibilityMessage, prefix + "page_prev")
    native.SendMessage(visibilityMessage, prefix + "page_counter")
    native.SendMessage(visibilityMessage, prefix + "page_next")
    if maxPage <= 0 then return end
    native.SendMessage(-90, prefix + "page_prev")
    native.SendMessage(-91, prefix + "page_next")
    if currentPage > 0 then
      native.SendMessage(-97, prefix + "page_prev")
    else
      native.SendMessage(-96, prefix + "page_prev")
    end
    if currentPage < maxPage then
      native.SendMessage(-97, prefix + "page_next")
    else
      native.SendMessage(-96, prefix + "page_next")
    end
    native.SendMessage((currentPage + 1) * 100 + maxPage + 1, prefix + "page_counter")
  end

  function ContainerViewResetPageControls(
    prefix: string,
    resetPreviousMessage: int,
    resetNextMessage: int) -> void
    native.SendMessage(resetPreviousMessage, prefix + "page_prev")
    native.SendMessage(resetNextMessage, prefix + "page_next")
  end

  function ContainerViewRenderPlayerSlotUnavailable(wnd: string) -> void
    native.SendMessage(c_iSlotEmpty, wnd)
    native.SendMessage(-140, wnd)
    native.SendMessage(-22, wnd)
  end

  function ContainerViewBeginPlayerSlot(wnd: string) -> void
    native.SendMessage(-23, wnd)
  end

  function ContainerViewRenderPlayerSlotEmpty(wnd: string) -> void
    native.SendMessage(c_iSlotEmpty, wnd)
    native.SendMessage(-140, wnd)
  end

  function ContainerViewRenderPlayerSlotItem(
    wnd: string,
    item: object,
    amount: int) -> void
    native.SendMessage(0, wnd, item)
    native.SendMessage(amount + c_iSlotNumber, wnd)
  end

  function ContainerViewRenderPlayerQuickslot(wnd: string, quickslot: int) -> void
    native.SendMessage(-140, wnd)
    if quickslot > 0 then native.SendMessage(-140 - quickslot, wnd) end
  end

  function ContainerViewRenderContainerSlotEmpty(wnd: string) -> void
    native.SendMessage(c_iSlotEmpty, wnd)
  end

  function ContainerViewRenderContainerSlotItem(
    wnd: string,
    item: object,
    amount: int) -> void
    native.SendMessage(0, wnd, item)
    native.SendMessage(amount + c_iSlotNumber, wnd)
  end

  function ContainerViewRenderOrganSlotHidden(wnd: string) -> void
    native.SendMessage(c_iSlotEmpty, wnd)
    native.SendMessage(-22, wnd)
  end

  function ContainerViewBeginOrganSlot(wnd: string) -> void
    native.SendMessage(-23, wnd)
  end

  function ContainerViewRenderOrganSlotEmpty(wnd: string) -> void
    native.SendMessage(c_iSlotEmpty, wnd)
    native.SendMessage(-24, wnd)
  end

  function ContainerViewRenderOrganSlotItem(
    wnd: string,
    item: object,
    amount: int) -> void
    native.SendMessage(0, wnd, item)
    native.SendMessage(amount + c_iSlotNumber, wnd)
  end

  function ContainerViewBeginOrganSlotItem(wnd: string) -> void
    native.SendMessage(-25, wnd)
  end

  function ContainerViewSetTargetHighlighted(
    target: int,
    visibleSlots: int,
    highlighted: bool) -> void
    local message: int = -21
    if highlighted then message = -20 end
    native.SendMessage(message, ContainerViewGetTargetWndName(target, visibleSlots))
  end

  function ContainerViewSetPageButtonHover(wnd: string, highlighted: bool) -> void
    if highlighted then native.SendMessage(-94, wnd) else native.SendMessage(-95, wnd) end
  end

  function ContainerViewClearPageControlHover() -> void
    ContainerViewSetPageButtonHover("player_page_prev", false)
    ContainerViewSetPageButtonHover("player_page_next", false)
    ContainerViewSetPageButtonHover("container_page_prev", false)
    ContainerViewSetPageButtonHover("container_page_next", false)
  end
end
