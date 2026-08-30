module inv_overhaul_container_view do
  local const c_iSlotEmpty: int = 32768
  local const c_iSlotNumber: int = 65536
  local const c_iTargetDrop: int = 200
  local const c_iTargetContainerBase: int = 300
  local const c_iTargetOrganBase: int = 400
  local const c_iContainerSlots: int = 12
  local const c_iOrganSlots: int = 4

  function GetPlayerSlotWndName(slot: int) -> string
    local number: int = slot + 1
    if number < 10 then return "slot0" + number end
    return "slot" + number
  end

  function GetContainerSlotWndName(slot: int) -> string
    local number: int = slot + 1
    if number < 10 then return "cslot0" + number end
    return "cslot" + number
  end

  function GetOrganSlotWndName(slot: int) -> string
    local number: int = slot + 1
    if number < 10 then return "oslot0" + number end
    return "oslot" + number
  end

  function LootViewGetTargetWndName(target: int, visibleSlots: int) -> string
    if target >= 0 && target < visibleSlots then
      return GetPlayerSlotWndName(target)
    end
    if target >= c_iTargetContainerBase &&
      target < c_iTargetContainerBase + c_iContainerSlots then
      return GetContainerSlotWndName(target - c_iTargetContainerBase)
    end
    if target >= c_iTargetOrganBase && target < c_iTargetOrganBase + c_iOrganSlots then
      return GetOrganSlotWndName(target - c_iTargetOrganBase)
    end
    if target == c_iTargetDrop then return "drop_slot" end
    return ""
  end

  function LootViewConfigureSlotRenderSize(
    windowWidth: int,
    visibleSlots: int) -> void
    local sizeMessage: int = -27
    local organSizeMessage: int = -27
    if windowWidth >= 1200 then sizeMessage = -26 end
    if windowWidth >= 1900 then organSizeMessage = -29 end
    for slot = 0, visibleSlots - 1 do
      native.SendMessage(sizeMessage, GetPlayerSlotWndName(slot))
    end
    for slot = 0, c_iContainerSlots - 1 do
      native.SendMessage(sizeMessage, GetContainerSlotWndName(slot))
    end
    for slot = 0, c_iOrganSlots - 1 do
      native.SendMessage(organSizeMessage, GetOrganSlotWndName(slot))
    end
    native.SendMessage(sizeMessage, "money")
  end

  function LootViewUpdatePageControls(
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

  function ResetPageControls(
    prefix: string,
    resetPreviousMessage: int,
    resetNextMessage: int) -> void
    native.SendMessage(resetPreviousMessage, prefix + "page_prev")
    native.SendMessage(resetNextMessage, prefix + "page_next")
  end

  function RenderPlayerSlotUnavailable(wnd: string) -> void
    native.SendMessage(c_iSlotEmpty, wnd)
    native.SendMessage(-140, wnd)
    native.SendMessage(-22, wnd)
  end

  function BeginPlayerSlot(wnd: string) -> void
    native.SendMessage(-23, wnd)
  end

  function RenderPlayerSlotEmpty(wnd: string) -> void
    native.SendMessage(c_iSlotEmpty, wnd)
    native.SendMessage(-140, wnd)
  end

  function RenderPlayerSlotItem(
    wnd: string,
    item: object,
    amount: int) -> void
    native.SendMessage(0, wnd, item)
    native.SendMessage(amount + c_iSlotNumber, wnd)
  end

  function RenderPlayerQuickslot(wnd: string, quickslot: int) -> void
    native.SendMessage(-140, wnd)
    if quickslot > 0 then native.SendMessage(-140 - quickslot, wnd) end
  end

  function RenderContainerSlotEmpty(wnd: string) -> void
    native.SendMessage(c_iSlotEmpty, wnd)
  end

  function RenderContainerSlotItem(
    wnd: string,
    item: object,
    amount: int) -> void
    native.SendMessage(0, wnd, item)
    native.SendMessage(amount + c_iSlotNumber, wnd)
  end

  function RenderOrganSlotHidden(wnd: string) -> void
    native.SendMessage(c_iSlotEmpty, wnd)
    native.SendMessage(-22, wnd)
  end

  function BeginOrganSlot(wnd: string) -> void
    native.SendMessage(-23, wnd)
  end

  function RenderOrganSlotEmpty(wnd: string) -> void
    native.SendMessage(c_iSlotEmpty, wnd)
    native.SendMessage(-24, wnd)
  end

  function RenderOrganSlotItem(
    wnd: string,
    item: object,
    amount: int) -> void
    native.SendMessage(0, wnd, item)
    native.SendMessage(amount + c_iSlotNumber, wnd)
  end

  function BeginOrganSlotItem(wnd: string) -> void
    native.SendMessage(-25, wnd)
  end

  function SetTargetHighlighted(
    target: int,
    visibleSlots: int,
    highlighted: bool) -> void
    local message: int = -21
    if highlighted then message = -20 end
    native.SendMessage(message, LootViewGetTargetWndName(target, visibleSlots))
  end

  function SetPageButtonHover(wnd: string, highlighted: bool) -> void
    if highlighted then native.SendMessage(-94, wnd) else native.SendMessage(-95, wnd) end
  end

  function ClearPageControlHover() -> void
    SetPageButtonHover("player_page_prev", false)
    SetPageButtonHover("player_page_next", false)
    SetPageButtonHover("container_page_prev", false)
    SetPageButtonHover("container_page_next", false)
  end
end
