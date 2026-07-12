maintask UtopianCharacterDoll do
  local const c_iBranchDanko: int = 0
  local const c_iBranchBurah: int = 1
  local const c_iBranchKlara: int = 2
  local layoutWidth: int

  function init() -> void
    layoutWidth = 800
    local branch: int = c_iBranchDanko
    native.GetVariable("branch", branch)

    if branch == c_iBranchBurah then
      native.SetBackground("haruspex")
    else
      if branch == c_iBranchKlara then
        native.SetBackground("clara")
      else
        native.SetBackground("bachelor")
      end
    end

    native.ProcessEvents()
  end

  function GetDollLeft() -> int
    if layoutWidth >= 1200 then return 115 end
    if layoutWidth >= 1000 then return 90 end
    return 79
  end

  function GetDollTop() -> int
    if layoutWidth >= 1200 then return 155 end
    if layoutWidth >= 1000 then return 130 end
    return 105
  end

  function IsInside(x: int, y: int, left: int, top: int) -> bool
    return x >= left && y >= top && x < left + 52 && y < top + 52
  end

  function HitsTarget(rawX: int, rawY: int, left: int, top: int) -> bool
    return IsInside(rawX, rawY, left, top)
  end

  function GetTargetMessage(globalX: int, globalY: int) -> int
    if layoutWidth >= 1200 then
      if HitsTarget(globalX, globalY, 470, 520) then return -50 end
      if HitsTarget(globalX, globalY, 294, 720) then return -51 end
      if HitsTarget(globalX, globalY, 294, 165) then return -52 end
      if HitsTarget(globalX, globalY, 294, 360) then return -53 end
      if HitsTarget(globalX, globalY, 125, 415) then return -54 end
    else
      if layoutWidth >= 1000 then
        if HitsTarget(globalX, globalY, 360, 410) then return -50 end
        if HitsTarget(globalX, globalY, 218, 540) then return -51 end
        if HitsTarget(globalX, globalY, 218, 138) then return -52 end
        if HitsTarget(globalX, globalY, 218, 300) then return -53 end
        if HitsTarget(globalX, globalY, 85, 335) then return -54 end
      else
        if HitsTarget(globalX, globalY, 270, 315) then return -50 end
        if HitsTarget(globalX, globalY, 167, 405) then return -51 end
        if HitsTarget(globalX, globalY, 167, 110) then return -52 end
        if HitsTarget(globalX, globalY, 167, 235) then return -53 end
        if HitsTarget(globalX, globalY, 66, 260) then return -54 end
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

  function OnUIMessage(message: int, sender: string, data: object) -> void
    if message >= 800 then
      layoutWidth = message
      native.Trace("utopian_character_doll layout=" + layoutWidth)
    end
  end
end
