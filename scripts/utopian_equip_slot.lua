maintask UtopianEquipSlot do
  local const c_iTooltipNone: int = -1
  local const c_iTooltipInvObject: int = 1
  local const c_iSlotEmpty: int = 32768
  local item: object
  local image: string
  local highlighted: bool
  local label: string
  local loadedItemID: int
  local slotWidth: int
  local slotHeight: int
  local highResolutionSprite: bool
  local tooltipSuppressed: bool

  function init() -> void
    item = null
    image = ""
    highlighted = false
    label = ""
    loadedItemID = -1
    highResolutionSprite = false
    tooltipSuppressed = false
    native.GetWindowSize(slotWidth, slotHeight)
    if slotWidth <= 0 then slotWidth = 52 end
    if slotHeight <= 0 then slotHeight = 52 end
    native.SetBackground("default")
    native.SetOwnerDraw(true)
    native.ProcessEvents()
  end

  function UpdateBackground() -> void
    if highlighted then
      native.SetBackground("target")
    else
      if item then
        native.SetBackground("occupied")
      else
        native.SetBackground("default")
      end
    end
  end

  function UpdateTooltip() -> void
    if tooltipSuppressed || !item then
      native.Trace("UTOPIAN_TOOLTIP_DIAG equip tooltip clear item=" + loadedItemID + " suppressed=" + tooltipSuppressed)
      native.SetTooltip(c_iTooltipNone, "")
    else
      native.Trace("UTOPIAN_TOOLTIP_DIAG equip tooltip set item=" + loadedItemID)
      native.SetTooltip(c_iTooltipInvObject, "", item)
    end
  end

  function OnDraw() -> void
    if item then
      if highResolutionSprite then
        native.StretchBlit(image, 2, 2, slotWidth - 4, slotHeight - 4)
      else
      if slotWidth > 52 then
        native.StretchBlit(image, 1, 1, (slotWidth - 2) * 64 / 52, (slotHeight - 2) * 64 / 52)
      else
        native.Blit(image, 1, 1)
      end
      end
    else
      native.Print("default", 2, (slotHeight - 12) / 2, label)
    end
  end

  function OnMouseEnter() -> void
    native.Trace("UTOPIAN_TOOLTIP_DIAG equip enter item=" + loadedItemID + " suppressed=" + tooltipSuppressed)
    UpdateTooltip()
    native.SendMessageToParent(-40)
  end

  function OnMouseMove(x: int, y: int) -> void
    native.SendMessageToParent(-40)
  end

  function OnMouseLeave() -> void
    native.Trace("UTOPIAN_TOOLTIP_DIAG equip leave item=" + loadedItemID + " suppressed=" + tooltipSuppressed)
    if tooltipSuppressed then tooltipSuppressed = false end
    native.SetTooltip(c_iTooltipNone, "")
  end

  function IsInsideSlot(x: int, y: int) -> bool
    return x >= 0 && y >= 0 && x < slotWidth && y < slotHeight
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
    if message == -26 then
      slotWidth = 82
      slotHeight = 82
      highResolutionSprite = true
      loadedItemID = -1
      return
    end

    if message == -28 then
      slotWidth = 48
      slotHeight = 48
      highResolutionSprite = true
      loadedItemID = -1
      return
    end

    if message == -27 then
      slotWidth = 52
      slotHeight = 52
      highResolutionSprite = false
      loadedItemID = -1
      return
    end

    if message == -130 then
      native.Trace("UTOPIAN_TOOLTIP_DIAG equip suppress item=" + loadedItemID)
      tooltipSuppressed = true
      native.SetTooltip(c_iTooltipNone, "")
      return
    end

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
      UpdateBackground()
      native.SetTooltip(c_iTooltipNone, "")
      return
    end

    item = data
    UpdateBackground()
    if item then
      local itemID: int
      item->GetItemID(itemID)
      if itemID != loadedItemID then
        loadedItemID = itemID
        if highResolutionSprite then
          native.GetInvItemSprite2(image, itemID)
        else
          native.GetInvItemSprite(image, itemID)
        end
        native.LoadImage(image)
      end
      -- Do not re-register the previous hover tooltip while equipment slots
      -- are refreshed after a drop. OnMouseEnter is the only place that
      -- enables the tooltip again.
      native.SetTooltip(c_iTooltipNone, "")
    else
      loadedItemID = -1
      native.SetTooltip(c_iTooltipNone, "")
    end
  end
end
