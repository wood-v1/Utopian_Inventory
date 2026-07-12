maintask UtopianInventoryBackground do
  local const c_iBranchDanko: int = 0
  local const c_iBranchBurah: int = 1
  local const c_iBranchKlara: int = 2
  local const c_iPointerMoveBase: int = 1000000
  local const c_iPointerDownBase: int = 4000000
  local const c_iPointerUpBase: int = 7000000
  local const c_iPointerRightBase: int = 10000000
  local const c_iPointerDragBeginBase: int = 13000000
  local const c_iPointerDragEndBase: int = 16000000
  local const c_iPointerLeaveBase: int = 19000000
  local const c_iPointerStride: int = 2000
  local const c_iTooltipNone: int = -1
  local const c_iTooltipInvObject: int = 1

  local image: string
  local panelWidth: int
  local panelHeight: int
  local rootWidth: int
  local rootHeight: int

  function init() -> void
    local branch: int = c_iBranchDanko
    native.GetVariable("branch", branch)

    if branch == c_iBranchBurah then
      image = "ui/utopian_inventory_bg_haruspex.tga"
    else
      if branch == c_iBranchKlara then
        image = "ui/utopian_inventory_bg_clara.tga"
      else
        image = "ui/utopian_inventory_bg_bachelor.tga"
      end
    end

    native.GetWindowSize(panelWidth, panelHeight)
    rootWidth = 0
    rootHeight = 0
    native.Trace("utopian_inventory_background branch=" + branch + " size=" + panelWidth + "x" + panelHeight)
    native.LoadImage(image)
    native.SetOwnerDraw(true)
    native.ProcessEvents()
  end

  function GetPanelLeft() -> int
    if rootWidth >= 1900 then return 360 end
    if panelWidth >= 1100 then return 40 end
    if panelWidth >= 900 then return 32 end
    return 25
  end

  function GetPanelTop() -> int
    if rootWidth >= 1900 then return 140 end
    if panelWidth >= 1100 then return 80 end
    if panelWidth >= 900 then return 64 end
    return 50
  end

  function SendPointer(base: int, x: int, y: int) -> void
    local globalX: int = GetPanelLeft() + x
    local globalY: int = GetPanelTop() + y
    native.SendMessageToParent(base + globalX * c_iPointerStride + globalY)
  end

  function OnDraw() -> void
    native.StretchBlit(image, 0, 0, panelWidth, panelHeight)
  end

  function OnMouseMove(x: int, y: int) -> void
    SendPointer(c_iPointerMoveBase, x, y)
  end

  function OnMouseLeave() -> void
    native.SetTooltip(c_iTooltipNone, "")
    native.SendMessageToParent(c_iPointerLeaveBase)
  end

  function OnLButtonDown(x: int, y: int) -> void
    SendPointer(c_iPointerDownBase, x, y)
  end

  function OnLButtonUp(x: int, y: int) -> void
    SendPointer(c_iPointerUpBase, x, y)
  end

  function OnRButtonDown(x: int, y: int) -> void
    SendPointer(c_iPointerRightBase, x, y)
  end

  function OnDragBegin(x: int, y: int) -> void
    SendPointer(c_iPointerDragBeginBase, x, y)
  end

  function OnDragEnd(x: int, y: int, accepted: bool) -> void
    SendPointer(c_iPointerDragEndBase, x, y)
  end

  function OnUIMessage(message: int, sender: string, data: object) -> void
    if message >= 5000 then
      rootHeight = message - 5000
      return
    end
    if message >= 800 then
      rootWidth = message
      return
    end
    if message == c_iTooltipInvObject && data then
      native.SetTooltip(c_iTooltipInvObject, "", data)
    else
      native.SetTooltip(c_iTooltipNone, "")
    end
  end
end
