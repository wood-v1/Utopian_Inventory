maintask UtopianDropSlot do
  local highlighted: bool

  function init() -> void
    highlighted = false
    native.SetBackground("default")
    native.SetOwnerDraw(true)
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
    native.SendMessageToParent(-40)
  end

  function OnMouseMove(x: int, y: int) -> void
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
