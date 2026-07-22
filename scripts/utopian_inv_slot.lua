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
  local const c_iSlotSize: int = 52

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

  function EncodePointerMessage(base: int, x: int, y: int) -> int
    return base + x * 100 + y
  end

  function IsInsideSlotForm(x: int, y: int) -> bool
    return x >= 0 && y >= 0 && x < c_iSlotSize && y < c_iSlotSize
  end

  function OnDraw() -> void
    if hidden then
      return
    end
    if blocked then
      native.Blit("blocked", 1, 1)
      return
    end
    if item then
      native.Blit(image, 1, 1)

      if amount > 1 then
        native.Print("default", 2, 35, amount)
      end

      if disabled then
        native.StretchBlit("disabled", 1, 1, 50, 50)
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
    if !hidden && !blocked then
      highlighted = true
      UpdateBackground()
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
    highlighted = false
    UpdateBackground()
    native.SendMessageToParent(7)
  end

  function OnUIMessage(message: int, sender: string, data: object) -> void
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
        native.GetInvItemSprite(image, itemID)
        native.LoadImage(image)
        native.GetInvItemMaxStackSize(maxStackSize, itemID)
      end
      if disabled then
        native.SetTooltip(c_iTooltipNone, "")
      else
        native.SetTooltip(c_iTooltipInvObject, "", item)
      end
    else
      loadedItemID = -1
      native.SetTooltip(c_iTooltipNone, "")
    end
  end
end
