maintask UtopianDragCursor do
  local itemID: int
  local loadedItemID: int
  local sprite: string
  local updateSeen: bool

  function init() -> void
    itemID = -1
    loadedItemID = -1
    sprite = ""
    updateSeen = false
    native.SetVariable("utopian_inventory_page_hover", 0)
    native.SetOwnerDraw(true)
    native.SetNeedUpdate(true)
    native.ProcessEvents()
    native.Trace("utopian_drag_cursor diagnostics init")
  end

  function OnUpdate(delta: float) -> void
    if !updateSeen then
      updateSeen = true
      native.Trace("utopian_drag_cursor diagnostics update active")
    end
  end

  function OnDraw() -> void
    native.GetVariable("utopian_inventory_drag_item", itemID)
    if itemID < 0 then
      native.Blit("default", 0, 0)
      return
    end

    if itemID != loadedItemID then
      native.Trace("UTOPIAN_TOOLTIP_DIAG drag cursor draw item=" + itemID)
      native.GetInvItemSprite(sprite, itemID)
      native.LoadImage(sprite)
      loadedItemID = itemID
    end

    native.StretchBlit(sprite, 24, 24, 80, 80, 0.85)
    native.StretchBlit("default", 0, 0, 32, 32)
  end

  function OnCursorWndChange(newWindow: object, previousWindow: object) -> void
    local windowName: string = ""
    local hoverTarget: int = 0
    if newWindow then
      newWindow->GetTooltipText(windowName)
    end
    if windowName == "page_prev" then hoverTarget = 1 end
    if windowName == "page_next" then hoverTarget = 2 end
    if windowName == "player_page_prev" then hoverTarget = 3 end
    if windowName == "player_page_next" then hoverTarget = 4 end
    if windowName == "container_page_prev" then hoverTarget = 5 end
    if windowName == "container_page_next" then hoverTarget = 6 end
    native.SetVariable("utopian_inventory_page_hover", hoverTarget)
    native.Trace("UTOPIAN_TOOLTIP_DIAG drag cursor window='" + windowName + "' target=" + hoverTarget)
  end
end
