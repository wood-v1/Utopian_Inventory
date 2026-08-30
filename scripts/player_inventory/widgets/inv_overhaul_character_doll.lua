import "inv_overhaul_inventory_protocol"
import "inv_overhaul_inventory_geometry"

maintask InvOverhaulCharacterDoll do
  local const c_iBranchDanko: int = 0
  local const c_iBranchBurah: int = 1
  local const c_iBranchKlara: int = 2
  local const c_iReleaseResources: int = -200
  local layoutWidth: int
  local layoutHeight: int
  local image: string
  local dollWidth: int
  local dollHeight: int
  local characterBranch: int
  local imageLoaded: bool
  local firstDrawProfiled: bool
  local perfDiagnostics: int

  function init() -> void
    perfDiagnostics = 0
    native.GetVariable("inv_overhaul_perf_diagnostics", perfDiagnostics)
    if perfDiagnostics == 1 then native.Trace("INV_OVERHAUL_PERF_STEP doll_init_begin") end
    layoutWidth = 800
    layoutHeight = 600
    local branch: int = c_iBranchDanko
    native.GetVariable("branch", branch)
    characterBranch = branch
    imageLoaded = false
    firstDrawProfiled = false

    if branch == c_iBranchBurah then
      image = "ui/inv_overhaul_doll_haruspex.tex"
    else
      if branch == c_iBranchKlara then
        image = "ui/inv_overhaul_doll_clara.tex"
      else
        image = "ui/inv_overhaul_doll_bachelor.tex"
      end
    end

    native.GetWindowSize(dollWidth, dollHeight)
    native.Trace("inv_overhaul_character_doll branch=" + branch + " image=" + image)
    if perfDiagnostics == 1 then native.Trace("INV_OVERHAUL_PERF_STEP doll_image_begin") end
    native.LoadImage(image)
    imageLoaded = true
    if perfDiagnostics == 1 then native.Trace("INV_OVERHAUL_PERF_STEP doll_image_end") end
    native.SetOwnerDraw(true)
    native.ProcessEvents()
    if perfDiagnostics == 1 then native.Trace("INV_OVERHAUL_PERF_STEP doll_init_end") end
  end

  function OnDraw() -> void
    if !imageLoaded then return end
    if perfDiagnostics == 1 && !firstDrawProfiled then native.Trace("INV_OVERHAUL_PERF_STEP doll_first_draw_begin") end
    local paddingX: int = 15
    local claraOffsetY: int = 12
    if dollWidth >= 400 then
      paddingX = 25
      claraOffsetY = 20
    else
      if dollWidth >= 320 then
        paddingX = 20
        claraOffsetY = 16
      end
    end

    local drawX: int = paddingX
    local drawY: int = 0
    local drawWidth: int = dollWidth - paddingX
    local drawHeight: int = dollHeight - claraOffsetY
    if characterBranch == c_iBranchBurah then
      drawX = paddingX / 2
    end
    if characterBranch == c_iBranchKlara then
      drawWidth = drawWidth * 9 / 10
      drawHeight = drawHeight * 9 / 10
      drawX = (dollWidth - drawWidth) / 2 - dollWidth * 3 / 40 + 5
      drawY = dollHeight - drawHeight
    end
    native.StretchBlit(image, drawX, drawY, drawWidth, drawHeight)
    if !firstDrawProfiled then
      firstDrawProfiled = true
      if perfDiagnostics == 1 then native.Trace("INV_OVERHAUL_PERF_STEP doll_first_draw_end") end
    end
  end

  function GetLeft() -> int
    return inv_overhaul_inventory_geometry.GetDollLeft(layoutWidth)
  end

  function GetTop() -> int
    return inv_overhaul_inventory_geometry.GetDollTop(layoutWidth)
  end

  function IsInside(x: int, y: int, left: int, top: int) -> bool
    return inv_overhaul_inventory_geometry.IsInsideRect(x, y, left, top, 52, 52)
  end

  function HitsTarget(rawX: int, rawY: int, left: int, top: int) -> bool
    return inv_overhaul_inventory_geometry.IsInsideRect(rawX, rawY, left, top, 52, 52)
  end

  function GetTargetMessage(globalX: int, globalY: int) -> int
    return inv_overhaul_inventory_geometry.GetDollTargetMessage(
      layoutWidth, characterBranch, globalX, globalY)
  end

  function OnMouseMove(x: int, y: int) -> void
    local globalX: int = GetLeft() + x
    local globalY: int = GetTop() + y
    local targetMessage: int = GetTargetMessage(globalX, globalY)
    if targetMessage != 0 then
      native.SendMessageToParent(targetMessage)
    end
  end

  function OnMouseLeave() -> void
  end

  function GetTargetAtLocalPoint(x: int, y: int) -> int
    return GetTargetMessage(GetLeft() + x, GetTop() + y)
  end

  function OnLButtonDown(x: int, y: int) -> void
    local message: int = inv_overhaul_inventory_protocol.GetDollSourceMessage(
      GetTargetAtLocalPoint(x, y), -60)
    if message != 0 then
      native.Trace("inv_overhaul_character_doll equipment left message=" + message)
      native.SendMessageToParent(message)
    end
  end

  function OnRButtonDown(x: int, y: int) -> void
    local message: int = inv_overhaul_inventory_protocol.GetDollSourceMessage(
      GetTargetAtLocalPoint(x, y), -70)
    if message != 0 then
      native.Trace("inv_overhaul_character_doll equipment right message=" + message)
      native.SendMessageToParent(message)
    end
  end

  function OnDragBegin(x: int, y: int) -> void
    local message: int = inv_overhaul_inventory_protocol.GetDollSourceMessage(
      GetTargetAtLocalPoint(x, y), -60)
    if message != 0 then
      native.SendMessageToParent(message)
    end
  end

  function OnLButtonUp(x: int, y: int) -> void
    native.SendMessageToParent(8)
  end

  function OnDragEnd(x: int, y: int, accepted: bool) -> void
    native.SendMessageToParent(8)
  end

  function OnUIMessage(message: int, sender: string, data: object) -> void
    if message == c_iReleaseResources then
      if imageLoaded then
        -- The parent window is destroyed after this message returns.  Disable
        -- owner drawing first so no final frame references the released doll.
        native.SetOwnerDraw(false)
        imageLoaded = false
        native.ReleaseImage(image)
        native.Trace("INV_OVERHAUL_DOLL_RESOURCE_RELEASED branch=" + characterBranch)
      end
      return
    end
    if message >= 5000 then
      layoutHeight = message - 5000
      native.Trace("inv_overhaul_character_doll height=" + layoutHeight)
    else
    if message >= 800 then
      layoutWidth = message
      native.Trace("inv_overhaul_character_doll layout=" + layoutWidth)
    end
    end
  end

end
