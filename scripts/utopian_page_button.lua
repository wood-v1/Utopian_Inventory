maintask UtopianPageButton do
  local const c_iTooltipNone: int = -1
  local label: string
  local highlighted: bool
  local visible: bool
  local enabled: bool
  local hoverTarget: int

  function init() -> void
    label = "?"
    highlighted = false
    visible = false
    enabled = false
    hoverTarget = 0
    native.SetTooltip(c_iTooltipNone, "")
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
    if visible then native.Print("default", 15, 7, label) end
  end

  function OnMouseEnter() -> void
    native.Trace("utopian_page_button diagnostics enter label=" + label + " visible=" + visible + " enabled=" + enabled)
    if visible && hoverTarget >= 1 && hoverTarget <= 4 then
      native.SetVariable("utopian_inventory_tooltip_item", -1)
      native.SetVariable("utopian_inventory_tooltip_text_id", 1404)
      native.SetVariable("utopian_inventory_tooltip_type", 5)
    end
    if visible && enabled then
      highlighted = true
      UpdateBackground()
      native.SetVariable("utopian_inventory_page_hover", hoverTarget)
      native.SendMessageToParent(-110)
    end
  end

  function OnMouseLeave() -> void
    native.Trace("utopian_page_button diagnostics leave label=" + label)
    highlighted = false
    UpdateBackground()
    native.SetVariable("utopian_inventory_page_hover", 0)
    native.SendMessageToParent(-111)
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
    if message == -112 then
      hoverTarget = 1
      native.SetTooltip(c_iTooltipNone, "page_prev")
    end
    if message == -113 then
      hoverTarget = 2
      native.SetTooltip(c_iTooltipNone, "page_next")
    end
    if message == -114 then
      hoverTarget = 3
      native.SetTooltip(c_iTooltipNone, "player_page_prev")
    end
    if message == -115 then
      hoverTarget = 4
      native.SetTooltip(c_iTooltipNone, "player_page_next")
    end
    if message == -116 then
      hoverTarget = 5
      native.SetTooltip(c_iTooltipNone, "container_page_prev")
    end
    if message == -117 then
      hoverTarget = 6
      native.SetTooltip(c_iTooltipNone, "container_page_next")
    end
    if message == -90 then label = "<" end
    if message == -91 then label = ">" end
    if message == -92 then
      visible = true
      UpdateBackground()
    end
    if message == -93 then
      visible = false
      highlighted = false
      native.SetVariable("utopian_inventory_page_hover", 0)
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
      native.SetVariable("utopian_inventory_page_hover", 0)
      UpdateBackground()
    end
    if message == -97 then
      enabled = true
      UpdateBackground()
    end
  end
end
