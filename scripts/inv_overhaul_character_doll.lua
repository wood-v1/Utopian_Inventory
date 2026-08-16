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

  function init() -> void
    native.Trace("INV_OVERHAUL_PERF_STEP doll_init_begin")
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
    native.Trace("INV_OVERHAUL_PERF_STEP doll_image_begin")
    native.LoadImage(image)
    imageLoaded = true
    native.Trace("INV_OVERHAUL_PERF_STEP doll_image_end")
    native.SetOwnerDraw(true)
    native.ProcessEvents()
    native.Trace("INV_OVERHAUL_PERF_STEP doll_init_end")
  end

  function OnDraw() -> void
    if !imageLoaded then return end
    if !firstDrawProfiled then native.Trace("INV_OVERHAUL_PERF_STEP doll_first_draw_begin") end
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
      drawX = (dollWidth - drawWidth) / 2 - dollWidth * 3 / 40
      drawY = dollHeight - drawHeight
    end
    native.StretchBlit(image, drawX, drawY, drawWidth, drawHeight)
    if !firstDrawProfiled then
      firstDrawProfiled = true
      native.Trace("INV_OVERHAUL_PERF_STEP doll_first_draw_end")
    end
  end

  function GetDollLeft() -> int
    if layoutWidth >= 1900 then return 395 end
    if layoutWidth >= 1200 then return 75 end
    if layoutWidth >= 1000 then return 60 end
    return 50
  end

  function GetDollTop() -> int
    if layoutWidth >= 1900 then return 290 end
    if layoutWidth >= 1200 then return 230 end
    if layoutWidth >= 1000 then return 187 end
    return 157
  end

  function IsInside(x: int, y: int, left: int, top: int) -> bool
    return x >= left && y >= top && x < left + 52 && y < top + 52
  end

  function HitsTarget(rawX: int, rawY: int, left: int, top: int) -> bool
    return IsInside(rawX, rawY, left, top)
  end

  function GetTargetMessage(globalX: int, globalY: int) -> int
    local clara: bool = characterBranch == c_iBranchKlara
    local headOffset: int = 8
    if layoutWidth >= 1900 then
      headOffset = 15
      if clara then headOffset = 100 end
    else
      if layoutWidth >= 1200 then
        headOffset = 12
        if clara then headOffset = 94 end
      else
        if layoutWidth >= 1000 then
          headOffset = 9
          if clara then headOffset = 84 end
        else
          if clara then headOffset = 78 end
        end
      end
    end
    if layoutWidth >= 1900 then
      if clara then
        if HitsTarget(globalX, globalY, 660, 512) then return -50 end
      else
        if HitsTarget(globalX, globalY, 660, 580) then return -50 end
      end
      if HitsTarget(globalX, globalY, 590, 800) then return -51 end
      if HitsTarget(globalX, globalY, 590, 300 + headOffset) then return -52 end
      if clara then
        if HitsTarget(globalX, globalY, 560, 488) then return -53 end
      else
        if HitsTarget(globalX, globalY, 590, 488) then return -53 end
      end
      if HitsTarget(globalX, globalY, 445, 560) then return -54 end
    else
      if layoutWidth >= 1200 then
        if clara then
          if HitsTarget(globalX, globalY, 375, 458) then return -50 end
        else
          if HitsTarget(globalX, globalY, 375, 528) then return -50 end
        end
        if HitsTarget(globalX, globalY, 270, 740) then return -51 end
        if HitsTarget(globalX, globalY, 270, 240 + headOffset) then return -52 end
        if clara then
          if HitsTarget(globalX, globalY, 250, 428) then return -53 end
        else
          if HitsTarget(globalX, globalY, 270, 428) then return -53 end
        end
        if HitsTarget(globalX, globalY, 125, 500) then return -54 end
      else
        if layoutWidth >= 1000 then
          if clara then
            if HitsTarget(globalX, globalY, 299, 351) then return -50 end
          else
            if HitsTarget(globalX, globalY, 299, 418) then return -50 end
          end
          if HitsTarget(globalX, globalY, 207, 569) then return -51 end
          if HitsTarget(globalX, globalY, 207, 188 + headOffset) then return -52 end
          if clara then
            if HitsTarget(globalX, globalY, 191, 346) then return -53 end
          else
            if HitsTarget(globalX, globalY, 207, 346) then return -53 end
          end
          if HitsTarget(globalX, globalY, 86, 399) then return -54 end
        else
          if clara then
            if HitsTarget(globalX, globalY, 222, 255) then return -50 end
          else
            if HitsTarget(globalX, globalY, 222, 323) then return -50 end
          end
          if HitsTarget(globalX, globalY, 156, 429) then return -51 end
          if HitsTarget(globalX, globalY, 156, 159 + headOffset) then return -52 end
          if clara then
            if HitsTarget(globalX, globalY, 144, 271) then return -53 end
          else
            if HitsTarget(globalX, globalY, 156, 271) then return -53 end
          end
          if HitsTarget(globalX, globalY, 68, 311) then return -54 end
        end
      end
    end
    return 0
  end

  function OnMouseMove(x: int, y: int) -> void
    local globalX: int = GetDollLeft() + x
    local globalY: int = GetDollTop() + y
    local targetMessage: int = GetTargetMessage(globalX, globalY)
    if targetMessage != 0 then
      native.SendMessageToParent(targetMessage)
    end
  end

  function OnMouseLeave() -> void
  end

  function GetSourceMessage(targetMessage: int, base: int) -> int
    if targetMessage == -50 then return base end
    if targetMessage <= -51 && targetMessage >= -54 then
      return base - (-50 - targetMessage)
    end
    return 0
  end

  function GetTargetAtLocalPoint(x: int, y: int) -> int
    return GetTargetMessage(GetDollLeft() + x, GetDollTop() + y)
  end

  function OnLButtonDown(x: int, y: int) -> void
    local message: int = GetSourceMessage(GetTargetAtLocalPoint(x, y), -60)
    if message != 0 then
      native.Trace("inv_overhaul_character_doll equipment left message=" + message)
      native.SendMessageToParent(message)
    end
  end

  function OnRButtonDown(x: int, y: int) -> void
    local message: int = GetSourceMessage(GetTargetAtLocalPoint(x, y), -70)
    if message != 0 then
      native.Trace("inv_overhaul_character_doll equipment right message=" + message)
      native.SendMessageToParent(message)
    end
  end

  function OnDragBegin(x: int, y: int) -> void
    local message: int = GetSourceMessage(GetTargetAtLocalPoint(x, y), -60)
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
