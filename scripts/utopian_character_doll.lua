maintask UtopianCharacterDoll do
  local const c_iBranchDanko: int = 0
  local const c_iBranchBurah: int = 1
  local const c_iBranchKlara: int = 2
  local layoutWidth: int
  local layoutHeight: int
  local image: string
  local dollWidth: int
  local dollHeight: int
  local characterBranch: int

  function init() -> void
    layoutWidth = 800
    layoutHeight = 600
    local branch: int = c_iBranchDanko
    native.GetVariable("branch", branch)
    characterBranch = branch

    if branch == c_iBranchBurah then
      image = "ui/utopian_doll_haruspex.tga"
    else
      if branch == c_iBranchKlara then
        image = "ui/utopian_doll_clara.tga"
      else
        image = "ui/utopian_doll_bachelor.tga"
      end
    end

    native.GetWindowSize(dollWidth, dollHeight)
    native.Trace("utopian_character_doll branch=" + branch + " image=" + image)
    native.LoadImage(image)
    native.SetOwnerDraw(true)
    native.ProcessEvents()
  end

  function OnDraw() -> void
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
    if characterBranch == c_iBranchKlara then
      drawX = 0
      drawY = claraOffsetY
    end
    native.StretchBlit(image, drawX, drawY, dollWidth - paddingX, dollHeight - claraOffsetY)
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
    if layoutWidth >= 1900 then
      if HitsTarget(globalX, globalY, 715, 610) then return -50 end
      if HitsTarget(globalX, globalY, 590, 800) then return -51 end
      if HitsTarget(globalX, globalY, 590, 300) then return -52 end
      if HitsTarget(globalX, globalY, 590, 488) then return -53 end
      if HitsTarget(globalX, globalY, 445, 560) then return -54 end
    else
      if layoutWidth >= 1200 then
        if HitsTarget(globalX, globalY, 395, 550) then return -50 end
        if HitsTarget(globalX, globalY, 270, 740) then return -51 end
        if HitsTarget(globalX, globalY, 270, 240) then return -52 end
        if HitsTarget(globalX, globalY, 270, 428) then return -53 end
        if HitsTarget(globalX, globalY, 125, 500) then return -54 end
      else
        if layoutWidth >= 1000 then
          if HitsTarget(globalX, globalY, 315, 438) then return -50 end
          if HitsTarget(globalX, globalY, 207, 569) then return -51 end
          if HitsTarget(globalX, globalY, 207, 188) then return -52 end
          if HitsTarget(globalX, globalY, 207, 346) then return -53 end
          if HitsTarget(globalX, globalY, 86, 399) then return -54 end
        else
          if HitsTarget(globalX, globalY, 234, 337) then return -50 end
          if HitsTarget(globalX, globalY, 156, 429) then return -51 end
          if HitsTarget(globalX, globalY, 156, 159) then return -52 end
          if HitsTarget(globalX, globalY, 156, 271) then return -53 end
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
      native.Trace("utopian_character_doll equipment left message=" + message)
      native.SendMessageToParent(message)
    end
  end

  function OnRButtonDown(x: int, y: int) -> void
    local message: int = GetSourceMessage(GetTargetAtLocalPoint(x, y), -70)
    if message != 0 then
      native.Trace("utopian_character_doll equipment right message=" + message)
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
    if message >= 5000 then
      layoutHeight = message - 5000
      native.Trace("utopian_character_doll height=" + layoutHeight)
    else
    if message >= 800 then
      layoutWidth = message
      native.Trace("utopian_character_doll layout=" + layoutWidth)
    end
    end
  end
end
