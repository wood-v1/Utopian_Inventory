maintask UtopianPageButton do
  local label: string
  local highlighted: bool
  local visible: bool
  local enabled: bool

  function init() -> void
    label = "?"
    highlighted = false
    visible = false
    enabled = false
    native.SetBackground("hidden")
    native.SetOwnerDraw(true)
    native.ProcessEvents()
  end

  function UpdateBackground() -> void
    if !visible then
      native.SetBackground("hidden")
    else
      if highlighted && enabled then native.SetBackground("target") else native.SetBackground("default") end
    end
  end

  function OnDraw() -> void
    if visible then native.Print("default", 11, 6, label) end
  end

  function OnMouseEnter() -> void
    if visible && enabled then
      highlighted = true
      UpdateBackground()
    end
  end

  function OnMouseLeave() -> void
    highlighted = false
    UpdateBackground()
  end

  function OnLButtonDown(x: int, y: int) -> void
    if visible && enabled then
      native.Trace("utopian_page_button down " + label)
      native.SendMessageToParent(0)
    end
  end

  function OnLButtonUp(x: int, y: int) -> void
    native.Trace("utopian_page_button up " + label)
  end

  function OnUIMessage(message: int, sender: string, data: object) -> void
    if message == -90 then label = "<" end
    if message == -91 then label = ">" end
    if message == -92 then
      visible = true
      UpdateBackground()
    end
    if message == -93 then
      visible = false
      highlighted = false
      UpdateBackground()
    end
    if message == -94 && visible && enabled then
      highlighted = true
      UpdateBackground()
    end
    if message == -95 then
      highlighted = false
      UpdateBackground()
    end
    if message == -96 then
      enabled = false
      highlighted = false
      UpdateBackground()
    end
    if message == -97 then
      enabled = true
      UpdateBackground()
    end
  end
end
