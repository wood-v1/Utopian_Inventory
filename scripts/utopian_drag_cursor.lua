maintask UtopianDragCursor do
  local itemID: int
  local loadedItemID: int
  local sprite: string

  function init() -> void
    itemID = -1
    loadedItemID = -1
    sprite = ""
    native.SetOwnerDraw(true)
    native.ProcessEvents()
  end

  function OnDraw() -> void
    native.GetVariable("utopian_inventory_drag_item", itemID)
    if itemID <= 0 then
      native.Blit("default", 0, 0)
      return
    end

    if itemID != loadedItemID then
      native.GetInvItemSprite(sprite, itemID)
      native.LoadImage(sprite)
      loadedItemID = itemID
    end

    native.StretchBlit(sprite, 8, 8, 50, 50, 0.85)
    native.Blit("default", 0, 0)
  end
end
