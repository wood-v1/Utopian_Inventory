maintask UtopianDropSlot do
  local const c_iTooltipMapObject: int = 5
  local const c_iDropTooltipTextID: int = 1401
  local highlighted: bool
  local tooltip: string

  function init() -> void
    highlighted = false
    native.SetBackground("default")
    native.SetOwnerDraw(true)
    native.GetStringByID(tooltip, c_iDropTooltipTextID)
    native.SetTooltip(c_iTooltipMapObject, tooltip)
    native.ProcessEvents()
  end

  function UpdateBackground() -> void
    if highlighted then
      native.SetBackground("target")
    else
      native.SetBackground("default")
    end
  end

  function OnDraw() -> void
    native.Print("default", 10, 20, "DROP")
  end

  function OnMouseEnter() -> void
    native.SetTooltip(c_iTooltipMapObject, tooltip)
    native.SendMessageToParent(-40)
  end

  function OnMouseMove(x: int, y: int) -> void
    native.SetTooltip(c_iTooltipMapObject, tooltip)
    native.SendMessageToParent(-40)
  end

  function OnMouseLeave() -> void
  end

  function OnLButtonUp(x: int, y: int) -> void
    native.SendMessageToParent(-42)
  end

  function OnUIMessage(message: int, sender: string, data: object) -> void
    if message == -20 then
      highlighted = true
      UpdateBackground()
    else
      if message == -21 then
        highlighted = false
        UpdateBackground()
      end
    end
  end
end
