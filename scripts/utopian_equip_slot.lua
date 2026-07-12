maintask UtopianEquipSlot do
  local const c_iTooltipNone: int = -1
  local const c_iTooltipInvObject: int = 1
  local const c_iSlotEmpty: int = 32768

  local item: object
  local image: string
  local highlighted: bool
  local label: string

  function init() -> void
    item = null
    image = ""
    highlighted = false
    label = ""
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
    if item then
      native.StretchBlit(image, 4, 4, 44, 44)
    else
      native.Print("default", 2, 20, label)
    end
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
      return
    end
    if message == -21 then
      highlighted = false
      UpdateBackground()
      return
    end
    if message == -30 then
      label = "WEAPON"
      return
    end
    if message == -31 then
      label = "FEET"
      return
    end
    if message == -32 then
      label = "HEAD"
      return
    end
    if message == -33 then
      label = "BODY"
      return
    end
    if message == -34 then
      label = "HANDS"
      return
    end
    if message >= c_iSlotEmpty then
      item = null
      native.SetTooltip(c_iTooltipNone, "")
      return
    end

    item = data
    if item then
      local itemID: int
      item->GetItemID(itemID)
      native.GetInvItemSprite(image, itemID)
      native.LoadImage(image)
      native.SetTooltip(c_iTooltipInvObject, "", item)
    else
      native.SetTooltip(c_iTooltipNone, "")
    end
  end
end
