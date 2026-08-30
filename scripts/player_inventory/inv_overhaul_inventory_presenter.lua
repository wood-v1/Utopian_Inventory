import "inv_overhaul_inventory_view"
import "inv_overhaul_inventory_protocol"
import "inv_overhaul_inventory_items"
import "inv_overhaul_inventory_quickslot_bindings"

module inv_overhaul_inventory_presenter do
  function PlayerPresenterConfigureSlotRenderSize(windowWidth: int) -> void
    local sizeMessage: int = -27
    local equipSizeMessage: int = -27
    if windowWidth >= 1200 then sizeMessage = -26 end
    if windowWidth >= 1900 then equipSizeMessage = -28 end
    native.SendMessage(equipSizeMessage, "equip_head")
    native.SendMessage(equipSizeMessage, "equip_body")
    native.SendMessage(equipSizeMessage, "equip_hands")
    native.SendMessage(equipSizeMessage, "equip_feet")
    native.SendMessage(equipSizeMessage, "equip_weapon")
    native.SendMessage(sizeMessage, "drop_slot")
    native.SendMessage(sizeMessage, "money")
  end

  function PlayerPresenterSendGridRendererState(
    slot: int,
    capacity: int,
    operation: int,
    value: int,
    data: object
  ) -> void
    if slot < 0 || slot >= capacity then return end
    if value < 0 then value = 0 end
    if value > 19999 then value = 19999 end
    inv_overhaul_inventory_view.PlayerViewSendGridRendererState(
      slot, operation, value, data)
  end

  function PlayerPresenterSetGridRendererHighlight(slot: int, enabled: bool) -> void
    inv_overhaul_inventory_view.PlayerViewSetGridRendererHighlight(slot, enabled)
  end

  function PlayerPresenterUpdatePageControls(
    visibleSlots: int,
    capacity: int,
    maxPage: int,
    currentPage: int
  ) -> void
    if visibleSlots >= capacity then return end
    local visibilityMessage: int = -93
    native.SendMessage(-112, "page_prev")
    native.SendMessage(-113, "page_next")
    if maxPage > 0 then visibilityMessage = -92 end
    native.SendMessage(visibilityMessage, "page_prev")
    native.SendMessage(visibilityMessage, "page_counter")
    native.SendMessage(visibilityMessage, "page_next")
    if maxPage <= 0 then return end
    native.SendMessage(-90, "page_prev")
    native.SendMessage(-91, "page_next")
    if currentPage > 0 then
      native.SendMessage(-97, "page_prev")
    else
      native.SendMessage(-96, "page_prev")
    end
    if currentPage < maxPage then
      native.SendMessage(-97, "page_next")
    else
      native.SendMessage(-96, "page_next")
    end
    native.SendMessage((currentPage + 1) * 100 + maxPage + 1, "page_counter")
  end

  function PlayerPresenterUpdateMoney(container: object) -> void
    local money: int
    container->GetProperty("money", money)
    native.SendMessage(money, "money")
  end

  function PlayerPresenterUpdateSlot(
    slot: int,
    capacity: int,
    visibleCell: int,
    reference: int,
    container: object
  ) -> void
    if visibleCell < 0 then
      PlayerPresenterSendGridRendererState(
        slot, capacity, inv_overhaul_inventory_protocol.GridRendererHidden, 0, null)
      return
    end
    if reference < 0 then
      PlayerPresenterSendGridRendererState(
        slot, capacity, inv_overhaul_inventory_protocol.GridRendererEmpty, 0, null)
      return
    end

    local category: int =
      inv_overhaul_inventory_items.DecodeReferenceCategory(reference)
    local index: int =
      inv_overhaul_inventory_items.DecodeReferenceIndex(reference)
    local item: object
    local amount: int
    container->GetItem(item, index, category)
    container->GetItemAmount(amount, index, category)
    local itemID: int
    item->GetItemID(itemID)
    local quickslot: int =
      inv_overhaul_inventory_quickslot_bindings.GetDisplayedBinding(
        category, index, itemID)
    if amount > 1800 then amount = 1800 end
    PlayerPresenterSendGridRendererState(
      slot, capacity, inv_overhaul_inventory_protocol.GridRendererItem,
      amount * 11 + quickslot, item)
  end

  function UpdateEquipmentSlot(
    cache: int,
    wndName: string,
    category: int,
    index: int,
    container: object,
    emptyMessage: int
  ) -> void
    if category >= 0 && index >= 0 then
      local item: object
      container->GetItem(item, index, category)
      native.SendMessage(0, wndName, item)
      local itemID: int
      item->GetItemID(itemID)
      local quickslot: int =
        inv_overhaul_inventory_quickslot_bindings.GetDisplayedBinding(
          category, index, itemID)
      native.SendMessage(-140, wndName)
      if quickslot > 0 then native.SendMessage(-140 - quickslot, wndName) end
    else
      native.SendMessage(emptyMessage, wndName)
      native.SendMessage(-140, wndName)
    end
    native.SendMessage(-30 - cache, wndName)
  end

  function PlayerPresenterIsItemTexturePreloaded(
    itemID: int,
    cacheEpoch: int
  ) -> bool
    if itemID < 0 then return false end
    if cacheEpoch > 0 then
      local itemEpoch: int = 0
      native.GetVariable("inv_overhaul_ui_cache_item_" + itemID, itemEpoch)
      if itemEpoch == cacheEpoch then return true end
    end
    local runtimeEpoch: int = 0
    local loadedEpoch: int = -1
    native.GetVariable("inv_overhaul_runtime_texture_epoch", runtimeEpoch)
    if runtimeEpoch <= 0 then return false end
    native.GetVariable("inv_overhaul_runtime_texture_item_" + itemID, loadedEpoch)
    return loadedEpoch == runtimeEpoch
  end

  function PlayerPresenterMarkItemTextureLoaded(
    container: object,
    category: int,
    index: int
  ) -> void
    if category < 0 || index < 0 then return end
    local runtimeEpoch: int = 0
    native.GetVariable("inv_overhaul_runtime_texture_epoch", runtimeEpoch)
    if runtimeEpoch <= 0 then return end
    local item: object
    local itemID: int = -1
    container->GetItem(item, index, category)
    if item then item->GetItemID(itemID) end
    if itemID >= 0 then
      native.SetVariable("inv_overhaul_runtime_texture_item_" + itemID, runtimeEpoch)
    end
  end
end
