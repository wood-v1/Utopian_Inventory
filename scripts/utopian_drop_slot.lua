maintask UtopianDropSlot do
  local const c_iTooltipMapObject: int = 5
  local const c_iDropTooltipTextID: int = 1401
  local highlighted: bool
  local tooltip: string
  local slotWidth: int
  local slotHeight: int

  function init() -> void
    highlighted = false
    native.GetWindowSize(slotWidth, slotHeight)
    if slotWidth <= 0 then slotWidth = 52 end
    if slotHeight <= 0 then slotHeight = 52 end
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
    native.Print("default", (slotWidth - 32) / 2, (slotHeight - 12) / 2, "DROP")
  end

  function OnMouseEnter() -> void
    native.SetVariable("utopian_inventory_tooltip_item", -1)
    native.SetVariable("utopian_inventory_tooltip_type", c_iTooltipMapObject)
    native.SetTooltip(c_iTooltipMapObject, tooltip)
    native.SendMessageToParent(-40)
  end

  function OnMouseMove(x: int, y: int) -> void
    native.SetVariable("utopian_inventory_tooltip_item", -1)
    native.SetVariable("utopian_inventory_tooltip_type", c_iTooltipMapObject)
    native.SetTooltip(c_iTooltipMapObject, tooltip)
    native.SendMessageToParent(-40)
  end

  function OnMouseLeave() -> void
    native.SetVariable("utopian_inventory_tooltip_item", -1)
    native.SetVariable("utopian_inventory_tooltip_type", -1)
  end

  function OnLButtonUp(x: int, y: int) -> void
    native.SendMessageToParent(-42)
  end

  function OnUIMessage(message: int, sender: string, data: object) -> void
    if message == -26 then
      slotWidth = 82
      slotHeight = 82
      return
    end
    if message == -27 then
      slotWidth = 52
      slotHeight = 52
      return
    end
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
