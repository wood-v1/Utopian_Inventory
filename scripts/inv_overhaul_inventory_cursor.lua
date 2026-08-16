maintask UI_Cursor do
  local const c_iTooltipNone: int = -1
  local const c_iTooltipInvObject: int = 1
  local const c_iTooltipMapObject: int = 5
  local const c_iTooltipWidth: int = 250
  local const c_fOpaqueTime: float = 0.5
  local const c_fBlendTime: float = 0.15

  local wndCur: object
  local tooltipObject: object
  local tooltipText: string
  local tooltipType: int
  local tooltipTime: float
  local dragItemID: int
  local loadedDragItemID: int
  local dragSprite: string
  local initialized: bool
  local updateSeen: bool
  local drawSeen: bool
  local tooltipReadyLogged: bool
  local tooltipDrawLogged: bool
  local trackedTooltipItemID: int
  local trackedTooltipType: int
  local trackedTooltipTextID: int
  function EnsureInitialized() -> void
    if initialized then return end
    initialized = true
    tooltipType = c_iTooltipNone
    tooltipText = ""
    tooltipTime = 0
    dragItemID = -1
    loadedDragItemID = -1
    dragSprite = ""
    updateSeen = false
    drawSeen = false
    tooltipReadyLogged = false
    tooltipDrawLogged = false
    trackedTooltipItemID = -1
    trackedTooltipType = c_iTooltipNone
    trackedTooltipTextID = 1401
    native.CreateInvItem(tooltipObject)
    native.SetOwnerDraw(true)
    native.SetNeedUpdate(true)
    native.ProcessEvents()
  end

  function init() -> void
    EnsureInitialized()
  end

  function SetPageHover(window: object) -> void
    local windowName: string = ""
    local hoverTarget: int = 0
    if window then window->GetTooltipText(windowName) end
    if windowName == "page_prev" then hoverTarget = 1 end
    if windowName == "page_next" then hoverTarget = 2 end
    if windowName == "player_page_prev" then hoverTarget = 3 end
    if windowName == "player_page_next" then hoverTarget = 4 end
    if windowName == "container_page_prev" then hoverTarget = 5 end
    if windowName == "container_page_next" then hoverTarget = 6 end
    native.SetVariable("inv_overhaul_inventory_page_hover", hoverTarget)
  end

  function LoadTooltip() -> void
    EnsureInitialized()
    tooltipReadyLogged = false
    tooltipDrawLogged = false
    if !wndCur then
      tooltipType = c_iTooltipNone
      tooltipText = ""
      tooltipObject = null
      tooltipTime = 0
      return
    end

    wndCur->GetTooltipType(tooltipType)
    wndCur->GetTooltipText(tooltipText)
    wndCur->GetTooltipObject(tooltipObject)
    if tooltipObject then
      local itemID: int
      local sprite: string
      tooltipObject->GetItemID(itemID)
      native.GetInvItemSprite2(sprite, itemID)
      native.LoadImage(sprite)
    end
    tooltipTime = 0
  end

  function OnCursorWndChange(newWindow: object, previousWindow: object) -> void
    EnsureInitialized()
    SetPageHover(newWindow)
  end

  function TooltipChanged() -> bool
    if !wndCur then return tooltipType != c_iTooltipNone end

    local newType: int
    local newText: string
    local newObject: object
    wndCur->GetTooltipType(newType)
    wndCur->GetTooltipText(newText)
    wndCur->GetTooltipObject(newObject)

    if newType != tooltipType || newText != tooltipText then return true end
    if !newObject && tooltipObject then return true end
    if newObject && !tooltipObject then return true end
    if newObject && tooltipObject then
      local newID: int
      local oldID: int
      newObject->GetItemID(newID)
      tooltipObject->GetItemID(oldID)
      if newID != oldID then return true end
    end
    return false
  end

  function OnUpdate(delta: float) -> void
    EnsureInitialized()
    if !updateSeen then
      updateSeen = true
    end
    native.GetVariable("inv_overhaul_inventory_drag_item", dragItemID)
    if dragItemID >= 0 then
      tooltipTime = 0
      if dragItemID != loadedDragItemID then
        native.GetInvItemSprite2(dragSprite, dragItemID)
        native.LoadImage(dragSprite)
        loadedDragItemID = dragItemID
      end
      return
    end

    local publishedItemID: int = -1
    local publishedType: int = c_iTooltipNone
    local publishedTextID: int = 1401
    native.GetVariable("inv_overhaul_inventory_tooltip_item", publishedItemID)
    native.GetVariable("inv_overhaul_inventory_tooltip_type", publishedType)
    native.GetVariable("inv_overhaul_inventory_tooltip_text_id", publishedTextID)
    if publishedItemID != trackedTooltipItemID || publishedType != trackedTooltipType || publishedTextID != trackedTooltipTextID then
      trackedTooltipItemID = publishedItemID
      trackedTooltipType = publishedType
      trackedTooltipTextID = publishedTextID
      tooltipType = publishedType
      tooltipText = ""
      tooltipTime = 0
      tooltipReadyLogged = false
      tooltipDrawLogged = false
      if publishedItemID >= 0 && publishedType == c_iTooltipInvObject then
        local itemName: string
        local sprite: string
        native.GetInvItemName(itemName, publishedItemID)
        tooltipObject->SetItemName(itemName)
        native.GetInvItemSprite2(sprite, publishedItemID)
        native.LoadImage(sprite)
      else
        if publishedType == c_iTooltipMapObject then
          native.GetStringByID(tooltipText, publishedTextID)
        end
      end
    end
    if tooltipType != c_iTooltipNone then
      tooltipTime = tooltipTime + delta
      if tooltipTime >= c_fOpaqueTime && !tooltipReadyLogged then
        tooltipReadyLogged = true
      end
    end
  end

  function DrawBorder(x: int, y: int, width: int, height: int, alpha: float) -> void
    native.BlitClipped("bg", x, y, x, y, width, height, alpha)
    native.StretchBlit("border", x, y, width, 1, alpha)
    native.StretchBlit("border", x, y + height - 1, width, 1, alpha)
    native.StretchBlit("border", x, y, 1, height, alpha)
    native.StretchBlit("border", x + width - 1, y, 1, height, alpha)
  end

  function DrawItemImage(x: int, y: int, item: object, alpha: float) -> void
    if !item then return end
    local itemID: int
    local sprite: string
    item->GetItemID(itemID)
    native.GetInvItemSprite2(sprite, itemID)
    native.StretchBlit(sprite, x, y, 218, 218, alpha)
    native.StretchBlit("border", x, y, 218, 1, alpha)
    native.StretchBlit("border", x, y + 217, 218, 1, alpha)
    native.StretchBlit("border", x, y, 1, 218, alpha)
    native.StretchBlit("border", x + 217, y, 1, 218, alpha)
  end

  function DrawInventoryTooltip(cursorX: int, cursorY: int, item: object, extraText: string, alpha: float) -> void
    if !item then return end

    local itemID: int
    item->GetItemID(itemID)

    local description: string = ""
    local hasDescription: bool
    native.HasInvItemProperty(hasDescription, itemID, "Description")
    if hasDescription then
      local descriptionID: int
      native.GetInvItemProperty(descriptionID, itemID, "Description")
      native.GetStringByID(description, descriptionID)
    end

    local textHeight: int
    native.GetTextHeightInWidth(textHeight, "default", c_iTooltipWidth - 32, description)
    local fontHeight: int
    native.GetFontHeight(fontHeight, "default")
    local contentHeight: int = textHeight + fontHeight

    local durabilityText: string = ""
    local hasDurabilityDefinition: bool
    local hasDurability: bool
    native.HasInvItemProperty(hasDurabilityDefinition, itemID, "HasDurability")
    item->HasProperty(hasDurability, "durability")
    if hasDurability || hasDurabilityDefinition then
      local durability: int = 100
      if hasDurability then item->GetProperty(durability, "durability") end
      native.GetStringByID(durabilityText, 7)
      durabilityText = durabilityText + " " + durability + "%"
      local durabilityHeight: int
      native.GetTextHeightInWidth(durabilityHeight, "default", c_iTooltipWidth - 32, durabilityText)
      contentHeight = contentHeight + durabilityHeight
    end

    local usesText: string = ""
    local hasUsesDefinition: bool
    local hasUses: bool
    native.HasInvItemProperty(hasUsesDefinition, itemID, "HasUses")
    item->HasProperty(hasUses, "uses")
    if hasUses || hasUsesDefinition then
      local uses: int = 1
      if hasUses then item->GetProperty(uses, "uses") end
      native.GetStringByID(usesText, 1006)
      usesText = usesText + " " + uses
      local usesHeight: int
      native.GetTextHeightInWidth(usesHeight, "default", c_iTooltipWidth - 32, usesText)
      contentHeight = contentHeight + usesHeight
    end

    local extraHeight: int = 0
    if extraText != "" then
      native.GetTextHeightInWidth(extraHeight, "default", c_iTooltipWidth - 32, extraText)
      contentHeight = contentHeight + extraHeight
    end

    local totalHeight: int = contentHeight + 266
    local screenWidth: int
    local screenHeight: int
    native.GetScreenSize(screenWidth, screenHeight)

    local drawX: int = cursorX
    if screenWidth - cursorX <= c_iTooltipWidth then drawX = cursorX - c_iTooltipWidth end
    local drawY: int = cursorY
    if cursorY > totalHeight then
      drawY = cursorY - totalHeight
    else
      if drawY + totalHeight > screenHeight then drawY = screenHeight - totalHeight end
    end
    native.ScreenToClient(drawX, drawY)

    DrawBorder(drawX, drawY, c_iTooltipWidth, totalHeight, alpha)
    DrawItemImage(drawX + 16, drawY + 16, item, alpha)

    local textY: int = drawY + 250
    native.PrintInWidth(textHeight, "default", drawX + 16, textY, c_iTooltipWidth - 32,
      description, 0.647, 0.647, 0.647, alpha)
    textY = textY + textHeight + fontHeight

    if durabilityText != "" then
      local durabilityHeight: int
      native.PrintInWidth(durabilityHeight, "default", drawX + 16, textY, c_iTooltipWidth - 32,
        durabilityText, 0.647, 0.647, 0.647, alpha)
      textY = textY + durabilityHeight
    end
    if usesText != "" then
      local usesHeight: int
      native.PrintInWidth(usesHeight, "default", drawX + 16, textY, c_iTooltipWidth - 32,
        usesText, 0.647, 0.647, 0.647, alpha)
      textY = textY + usesHeight
    end
    if extraText != "" then
      native.PrintInWidth(extraHeight, "default", drawX + 16, textY, c_iTooltipWidth - 32,
        extraText, 0.647, 0.647, 0.647, alpha)
    end
  end

  function DrawTextTooltip(cursorX: int, cursorY: int, text: string, alpha: float) -> void
    if text == "" then return end
    local textHeight: int
    native.GetTextHeightInWidth(textHeight, "default", c_iTooltipWidth - 32, text)
    local totalHeight: int = textHeight + 32
    local screenWidth: int
    local screenHeight: int
    native.GetScreenSize(screenWidth, screenHeight)
    local drawX: int = cursorX
    local drawY: int = cursorY
    if trackedTooltipTextID == 1407 then
      drawX = cursorX - c_iTooltipWidth - 12
      drawY = cursorY + 12
    else
      if screenWidth - cursorX <= c_iTooltipWidth then drawX = cursorX - c_iTooltipWidth end
      if cursorY > totalHeight then drawY = cursorY - totalHeight end
    end
    if drawX < 0 then drawX = 0 end
    if drawX + c_iTooltipWidth > screenWidth then drawX = screenWidth - c_iTooltipWidth end
    if drawY < 0 then drawY = 0 end
    if drawY + totalHeight > screenHeight then drawY = screenHeight - totalHeight end
    native.ScreenToClient(drawX, drawY)
    DrawBorder(drawX, drawY, c_iTooltipWidth, totalHeight, alpha)
    native.PrintInWidth(textHeight, "default", drawX + 16, drawY + 16, c_iTooltipWidth - 32,
      text, 0.647, 0.647, 0.647, alpha)
  end

  function OnDraw() -> void
    EnsureInitialized()
    if !drawSeen then
      drawSeen = true
    end
    native.GetVariable("inv_overhaul_inventory_drag_item", dragItemID)
    if dragItemID >= 0 then
      if dragItemID != loadedDragItemID then
        native.GetInvItemSprite2(dragSprite, dragItemID)
        native.LoadImage(dragSprite)
        loadedDragItemID = dragItemID
      end
      native.StretchBlit(dragSprite, 24, 24, 80, 80, 0.85)
      native.StretchBlit("default", 0, 0, 32, 32)
      return
    end

    local alpha: float = 0
    if tooltipTime >= c_fOpaqueTime + c_fBlendTime then
      alpha = 1
    else
      if tooltipTime >= c_fOpaqueTime then alpha = (tooltipTime - c_fOpaqueTime) / c_fBlendTime end
    end

    if alpha > 0 then
      if !tooltipDrawLogged then
        tooltipDrawLogged = true
      end
      local cursorX: int = 0
      local cursorY: int = 0
      native.ClientToScreen(cursorX, cursorY)
      if tooltipType == c_iTooltipInvObject then
        DrawInventoryTooltip(cursorX, cursorY, tooltipObject, tooltipText, alpha)
      else
        if tooltipType == c_iTooltipMapObject then
          DrawTextTooltip(cursorX, cursorY, tooltipText, alpha)
        end
      end
    end
    native.StretchBlit("default", 0, 0, 32, 32)
  end

end
