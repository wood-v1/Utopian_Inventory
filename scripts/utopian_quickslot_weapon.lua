maintask UtopianQuickslotWeaponEffect do
  local const c_iCWeapon: int = 0
  local const c_iCClothes: int = 1
  local const c_iCategoryCount: int = 5
  local const c_iInventoryCapacity: int = 56
  local const c_iWMHelpMessage: int = 200
  local const c_iWMPlayerAddItem: int = 3
  local const c_iInventoryFullTextID: int = 1400
  local const c_iQuickslotMissingTextID: int = 1405

  function GetPlayer() -> object
    local player: object
    native.self(player)
    return player
  end

  function FindWeaponIndex(itemID: int, wantedOccurrence: int) -> int
    local player: object = GetPlayer()
    local count: int
    local occurrence: int = 0
    player->GetItemCount(count, c_iCWeapon)
    for candidate = 0, count - 1 do
      local item: object
      local candidateID: int = -1
      player->GetItem(item, candidate, c_iCWeapon)
      if item then
        item->GetItemID(candidateID)
        if candidateID == itemID then
          if occurrence == wantedOccurrence then return candidate end
          occurrence = occurrence + 1
        end
      end
    end
    return -1
  end

  function IsEquippedItem(category: int, index: int) -> bool
    if category != c_iCWeapon && category != c_iCClothes then return false end
    local player: object = GetPlayer()
    local selected: bool
    player->IsItemSelected(selected, index, category)
    return selected
  end

  function GetBackpackItemCount() -> int
    local player: object = GetPlayer()
    local total: int = 0
    for category = 0, c_iCategoryCount - 1 do
      local count: int
      player->GetItemCount(count, category)
      for index = 0, count - 1 do
        if !IsEquippedItem(category, index) then total = total + 1 end
      end
    end
    return total
  end

  function ShowMessage(textID: int) -> void
    local data: object
    native.CreateIntVector(data)
    data->add(textID)
    native.SendWorldWndMessage(c_iWMHelpMessage, data)
  end

  function ShowFeedback(itemID: int) -> void
    local data: object
    native.CreateIntVector(data)
    data->add(itemID)
    data->add(1)
    native.SendWorldWndMessage(c_iWMPlayerAddItem, data)
  end

  function MarkInventoryChanged() -> void
    local generation: int = 0
    native.GetVariable("utopian_inventory_reorder_generation", generation)
    native.SetVariable("utopian_inventory_reorder_generation", generation + 1)
  end

  function init() -> void
    local itemID: int = -1
    local occurrence: int = -1
    native.GetVariable("utopian_quickslot_weapon_item", itemID)
    native.GetVariable("utopian_quickslot_weapon_occurrence", occurrence)
    local index: int = FindWeaponIndex(itemID, occurrence)
    if index < 0 then
      ShowMessage(c_iQuickslotMissingTextID)
      return
    end

    local player: object = GetPlayer()
    local selected: bool
    player->IsItemSelected(selected, index, c_iCWeapon)
    native.Trace("UTOPIAN_QUICKSLOT_WEAPON_VERSION 2026.08.01-native-context-1 item=" +
      itemID + " occurrence=" + occurrence + " index=" + index +
      " selected=" + selected)

    if selected then
      if GetBackpackItemCount() >= c_iInventoryCapacity then
        ShowMessage(c_iInventoryFullTextID)
        return
      end
      native.Trace("UTOPIAN_QUICKSLOT_NATIVE_HANDS -1")
      player->SelectItem(index, false, c_iCWeapon)
      MarkInventoryChanged()
      ShowFeedback(itemID)
      native.Trace("utopian_quickslot weapon unequipped item=" + itemID)
      return
    end

    native.Trace("UTOPIAN_QUICKSLOT_NATIVE_HANDS " + itemID)
    local count: int
    player->GetItemCount(count, c_iCWeapon)
    for other = 0, count - 1 do
      player->SelectItem(other, false, c_iCWeapon)
    end
    player->SelectItem(index, true, c_iCWeapon)
    MarkInventoryChanged()
    ShowFeedback(itemID)
    native.Trace("utopian_quickslot weapon equipped item=" + itemID +
      " index=" + index)
  end
end
