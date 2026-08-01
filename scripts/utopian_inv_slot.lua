maintask UtopianInventorySlot do
  local const c_iTooltipNone: int = -1
  local const c_iTooltipInvObject: int = 1
  local const c_iSlotSelected: int = 16384
  local const c_iSlotEmpty: int = 32768
  local const c_iSlotNumber: int = 65536
  local const c_iSlotDisabled: int = 131072
  local const c_iSlotMask: int = 16383
  local const c_iHoverMessageBase: int = 100000
  local const c_iReleaseMessageBase: int = 200000
  local const c_iDragEndMessageBase: int = 300000
  local amount: int
  local maxStackSize: int
  local item: object
  local image: string
  local disabled: bool
  local dragging: bool
  local selected: bool
  local highlighted: bool
  local hidden: bool
  local blocked: bool
  local loadedItemID: int
  local slotWidth: int
  local slotHeight: int
  local highResolutionSprite: bool
  local tooltipSuppressed: bool
  local quickslot: int

  function init() -> void
    item = null
    amount = 1
    disabled = false
    dragging = false
    selected = false
    highlighted = false
    hidden = false
    blocked = false
    loadedItemID = -1
    highResolutionSprite = false
    tooltipSuppressed = false
    quickslot = 0
    native.GetWindowSize(slotWidth, slotHeight)
    if slotWidth <= 0 then slotWidth = 52 end
    if slotHeight <= 0 then slotHeight = 52 end
    native.SetBackground("default")
    native.SetOwnerDraw(true)
    native.ProcessEvents()
  end

  function UpdateBackground() -> void
    if hidden then
      native.SetBackground("hidden")
      return
    end

    if highlighted then
      native.SetBackground("target")
      return
    end

    if item then
      native.SetBackground("occupied")
      return
    end

    if selected then
      native.SetBackground("selected")
    else
      native.SetBackground("default")
    end
  end

  function UpdateTooltip() -> void
    if tooltipSuppressed || disabled || !item then
      native.Trace("UTOPIAN_TOOLTIP_DIAG grid tooltip clear item=" + loadedItemID + " suppressed=" + tooltipSuppressed)
      native.SetTooltip(c_iTooltipNone, "")
    else
      native.Trace("UTOPIAN_TOOLTIP_DIAG grid tooltip set item=" + loadedItemID)
      native.SetTooltip(c_iTooltipInvObject, "", item)
    end
  end

  function EncodePointerMessage(base: int, x: int, y: int) -> int
    return base + x * 100 + y
  end

  function IsInsideSlotForm(x: int, y: int) -> bool
    return x >= 0 && y >= 0 && x < slotWidth && y < slotHeight
  end

  function OnDraw() -> void
    if hidden then
      return
    end
    if blocked then
      native.StretchBlit("blocked", 1, 1, slotWidth - 2, slotHeight - 2)
      return
    end
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

      if amount > 1 then
        native.Print("default", 2, slotHeight - 17, amount)
      end

      if disabled then
        native.StretchBlit("disabled", 1, 1, slotWidth - 2, slotHeight - 2)
      end

      if quickslot > 0 then
        local displayNumber: int = quickslot
        if displayNumber == 10 then displayNumber = 0 end
        native.Print("quickslot", slotWidth - 17, 3, displayNumber)
      end
    end
  end

  function OnLButtonDown(x: int, y: int) -> void
    if hidden || blocked || !item then
      return
    end

    UpdateBackground()
    native.SendMessageToParent(2)
  end

  function OnLButtonUp(x: int, y: int) -> void
    if hidden || blocked then return end
    if IsInsideSlotForm(x, y) then
      native.SendMessageToParent(EncodePointerMessage(c_iReleaseMessageBase, x, y))
    else
      native.SendMessageToParent(8)
    end
    highlighted = IsInsideSlotForm(x, y)
    UpdateBackground()
    dragging = false
  end

  function OnRButtonDown(x: int, y: int) -> void
    if !hidden && !blocked && item then
      native.SendMessageToParent(1)
    end
  end

  function OnDragBegin(x: int, y: int) -> void
    if hidden || blocked || !item then
      return
    end

    dragging = true
    native.SendMessageToParent(3)
  end

  function OnDragEnd(x: int, y: int, accepted: bool) -> void
    if hidden || blocked then return end
    if IsInsideSlotForm(x, y) then
      native.SendMessageToParent(EncodePointerMessage(c_iDragEndMessageBase, x, y))
    else
      native.SendMessageToParent(8)
    end
    highlighted = IsInsideSlotForm(x, y)
    UpdateBackground()
  end

  function OnMouseEnter() -> void
    native.Trace("UTOPIAN_TOOLTIP_DIAG grid enter item=" + loadedItemID + " suppressed=" + tooltipSuppressed)
    if !hidden && !blocked then
      highlighted = true
      UpdateBackground()
      -- Updating the grid after a drop must not re-register a tooltip for a
      -- window that the cursor has already left. The engine can keep that
      -- tooltip's original screen position for one frame, which produces a
      -- visible flash after drag-and-drop. Tooltips are registered only from
      -- OnMouseEnter.
      native.SetTooltip(c_iTooltipNone, "")
    end
  end

  function OnMouseMove(x: int, y: int) -> void
    if hidden || blocked then return end
    if IsInsideSlotForm(x, y) then
      if !highlighted then
        highlighted = true
        UpdateBackground()
      end
      native.SendMessageToParent(EncodePointerMessage(c_iHoverMessageBase, x, y))
    else
      native.SendMessageToParent(7)
    end
  end

  function OnMouseLeave() -> void
    native.Trace("UTOPIAN_TOOLTIP_DIAG grid leave item=" + loadedItemID + " suppressed=" + tooltipSuppressed)
    highlighted = false
    UpdateBackground()
    if tooltipSuppressed then tooltipSuppressed = false end
    native.SetTooltip(c_iTooltipNone, "")
    native.SendMessageToParent(7)
  end

  function OnUIMessage(message: int, sender: string, data: object) -> void
    if message == -140 then
      quickslot = 0
      return
    end

    if message <= -141 && message >= -150 then
      quickslot = -message - 140
      return
    end

    if message == -26 then
      slotWidth = 82
      slotHeight = 82
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

    if message == -29 then
      slotWidth = 57
      slotHeight = 57
      highResolutionSprite = true
      loadedItemID = -1
      return
    end

    if message == -130 then
      native.Trace("UTOPIAN_TOOLTIP_DIAG grid suppress item=" + loadedItemID)
      tooltipSuppressed = true
      native.SetTooltip(c_iTooltipNone, "")
      return
    end

    if message == -22 then
      hidden = true
      highlighted = false
      native.SetBackground("hidden")
      native.SetTooltip(c_iTooltipNone, "")
      return
    end

    if message == -23 then
      hidden = false
      UpdateBackground()
      return
    end

    if message == -24 then
      blocked = true
      item = null
      highlighted = false
      loadedItemID = -1
      UpdateBackground()
      native.SetTooltip(c_iTooltipNone, "")
      return
    end

    if message == -25 then
      blocked = false
      UpdateBackground()
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

    if message >= c_iSlotDisabled then
      disabled = true
      message = message - c_iSlotDisabled
    else
      disabled = false
    end

    if message >= c_iSlotNumber then
      amount = message - c_iSlotNumber
      return
    end

    if message >= c_iSlotEmpty then
      item = null
      quickslot = 0
      loadedItemID = -1
      selected = false
      UpdateBackground()
      native.SetTooltip(c_iTooltipNone, "")
      return
    end

    if message >= c_iSlotSelected then
      selected = true
    else
      selected = false
    end
    UpdateBackground()

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
        native.GetInvItemMaxStackSize(maxStackSize, itemID)
      end
      -- Slot data is refreshed for the entire grid after every drop. Calling
      -- UpdateTooltip here registers every occupied slot on the cursor and
      -- revives the pre-drag tooltip for one frame. The panel hit-test and
      -- OnMouseEnter are the only legitimate tooltip activation paths.
      native.SetTooltip(c_iTooltipNone, "")
    else
      loadedItemID = -1
      native.SetTooltip(c_iTooltipNone, "")
    end
  end
end
