maintask UtopianEquipSlot do
  local const c_iTooltipNone: int = -1
  local const c_iTooltipInvObject: int = 1
  local const c_iSlotEmpty: int = 32768
  local const c_iSlotSize: int = 52

  local item: object
  local image: string
  local highlighted: bool
  local label: string
  local loadedItemID: int

  function init() -> void
    item = null
    image = ""
    highlighted = false
    label = ""
    loadedItemID = -1
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
      native.Blit(image, 1, 1)
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

  function IsInsideSlot(x: int, y: int) -> bool
    return x >= 0 && y >= 0 && x < c_iSlotSize && y < c_iSlotSize
  end

  function OnLButtonUp(x: int, y: int) -> void
    if IsInsideSlot(x, y) then
      native.SendMessageToParent(-42)
    else
      native.SendMessageToParent(8)
    end
  end

  function OnLButtonDown(x: int, y: int) -> void
    if item then
      native.SendMessageToParent(2)
    end
  end

  function OnRButtonDown(x: int, y: int) -> void
    if item then
      native.SendMessageToParent(-43)
    end
  end

  function OnDragBegin(x: int, y: int) -> void
    if item then
      native.SendMessageToParent(3)
    end
  end

  function OnDragEnd(x: int, y: int, accepted: bool) -> void
    if IsInsideSlot(x, y) then
      native.SendMessageToParent(-42)
    else
      native.SendMessageToParent(8)
    end
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
      loadedItemID = -1
      native.SetTooltip(c_iTooltipNone, "")
      return
    end

    item = data
    if item then
      local itemID: int
      item->GetItemID(itemID)
      if itemID != loadedItemID then
        loadedItemID = itemID
        native.GetInvItemSprite(image, itemID)
        native.LoadImage(image)
      end
      native.SetTooltip(c_iTooltipInvObject, "", item)
    else
      loadedItemID = -1
      native.SetTooltip(c_iTooltipNone, "")
    end
  end
end
