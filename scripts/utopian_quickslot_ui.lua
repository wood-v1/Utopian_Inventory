maintask UtopianQuickslotUIRuntime do
  local const c_iCWeapon: int = 0
  local const c_iCClothes: int = 1
  local const c_iCategoryCount: int = 5
  local const c_iQuickslotCount: int = 10
  local const c_iInventoryCapacity: int = 56
  local const c_iQuickslotVersion: int = 1
  local const c_iWMPlayerAddItem: int = 3
  local const c_iWMHelpMessage: int = 200
  local const c_iInventoryFullTextID: int = 1400
  local const c_iQuickslotMissingTextID: int = 1405
  local const c_iQuickslotUnusableTextID: int = 1406
  local const c_fMessageCooldown: float = 0.75

  local m_fMessageCooldown: float

  function GetPlayer() -> object
    local player: object
    native.GetPlayerContainer(player)
    return player
  end

  function GetItemVariable(slot: int) -> string
    return "utopian_quickslot_item_" + slot
  end

  function GetCategoryVariable(slot: int) -> string
    return "utopian_quickslot_category_" + slot
  end

  function GetOccurrenceVariable(slot: int) -> string
    return "utopian_quickslot_occurrence_" + slot
  end

  function GetDepletedVariable(slot: int) -> string
    return "utopian_quickslot_depleted_" + slot
  end

  function ClearBinding(slot: int) -> void
    native.SetVariable(GetItemVariable(slot), -1)
    native.SetVariable(GetCategoryVariable(slot), -1)
    native.SetVariable(GetOccurrenceVariable(slot), -1)
    native.SetVariable(GetDepletedVariable(slot), 1)
  end

  function InitializeBindings() -> void
    local version: int = 0
    native.GetVariable("utopian_quickslot_version", version)
    if version == c_iQuickslotVersion then return end
    for slot = 1, c_iQuickslotCount do
      native.SetVariable(GetItemVariable(slot), -1)
      native.SetVariable(GetCategoryVariable(slot), -1)
    end
    native.SetVariable("utopian_quickslot_version", c_iQuickslotVersion)
  end

  function ShowMessage(textID: int) -> void
    if m_fMessageCooldown > 0 then return end
    local text: object
    native.CreateIntVector(text)
    text->add(textID)
    native.SendWorldWndMessage(c_iWMHelpMessage, text)
    m_fMessageCooldown = c_fMessageCooldown
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

  function IsEquippable(category: int, itemID: int) -> bool
    local property: bool
    if category == c_iCWeapon then
      native.HasInvItemProperty(property, itemID, "Weapon")
      return property
    end
    if category == c_iCClothes then
      native.HasInvItemProperty(property, itemID, "Group")
      return property
    end
    return false
  end

  function IsEquippedItem(category: int, index: int) -> bool
    if category != c_iCWeapon && category != c_iCClothes then return false end
    local player: object = GetPlayer()
    local selected: bool
    player->IsItemSelected(selected, index, category)
    if !selected then return false end
    local item: object
    local itemID: int
    player->GetItem(item, index, category)
    if !item then return false end
    item->GetItemID(itemID)
    return IsEquippable(category, itemID)
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

  function GetBackpackOrdinal(targetCategory: int, targetIndex: int) -> int
    local player: object = GetPlayer()
    local ordinal: int = 0
    for category = 0, c_iCategoryCount - 1 do
      local count: int
      player->GetItemCount(count, category)
      for index = 0, count - 1 do
        if !IsEquippedItem(category, index) then
          if category == targetCategory && index == targetIndex then return ordinal end
          ordinal = ordinal + 1
        end
      end
    end
    return -1
  end

  function PublishRemovalHint(ordinal: int, oldCount: int) -> void
    if ordinal < 0 then return end
    native.SetVariable("utopian_inventory_removed_ordinal_hint", ordinal)
    native.SetVariable("utopian_inventory_removed_ordinal_old_count", oldCount)
    native.SetVariable("utopian_inventory_removed_ordinal_valid", 1)
  end

  function FindBoundItem(
    category: int,
    itemID: int,
    wantedOccurrence: int,
    index: int,
    selected: bool
  ) -> bool
    index = -1
    selected = false
    if category < 0 || category >= c_iCategoryCount ||
      itemID < 0 || wantedOccurrence < 0 then return false end
    local player: object = GetPlayer()
    local count: int
    local occurrence: int = 0
    player->GetItemCount(count, category)

    for candidate = 0, count - 1 do
      local item: object
      local candidateID: int
      player->GetItem(item, candidate, category)
      if item then
        item->GetItemID(candidateID)
        if candidateID == itemID then
          if occurrence == wantedOccurrence then
            player->IsItemSelected(selected, candidate, category)
            index = candidate
            return true
          end
          occurrence = occurrence + 1
        end
      end
    end
    return false
  end

  function ToggleEquipment(category: int, index: int, itemID: int, selected: bool) -> void
    local player: object = GetPlayer()
    if selected then
      if GetBackpackItemCount() >= c_iInventoryCapacity then
        ShowMessage(c_iInventoryFullTextID)
        return
      end
      player->SelectItem(index, false, category)
      if category == c_iCWeapon then native.SetPlayerHandsItem(-1) end
      MarkInventoryChanged()
      ShowFeedback(itemID)
      return
    end

    if category == c_iCWeapon then
      local count: int
      player->GetItemCount(count, category)
      for other = 0, count - 1 do player->SelectItem(other, false, category) end
      native.SetPlayerHandsItem(itemID)
      player->SelectItem(index, true, category)
      MarkInventoryChanged()
      ShowFeedback(itemID)
      return
    end

    local group: int
    native.GetInvItemProperty(group, itemID, "Group")
    local count: int
    player->GetItemCount(count, category)
    for other = 0, count - 1 do
      local otherItem: object
      local otherID: int
      local hasGroup: bool
      player->GetItem(otherItem, other, category)
      if otherItem then
        otherItem->GetItemID(otherID)
        native.HasInvItemProperty(hasGroup, otherID, "Group")
        if hasGroup then
          local otherGroup: int
          native.GetInvItemProperty(otherGroup, otherID, "Group")
          if otherGroup == group then player->SelectItem(other, false, category) end
        end
      end
    end
    player->SelectItem(index, true, category)
    MarkInventoryChanged()
    ShowFeedback(itemID)
  end

  function UseConsumable(slot: int, category: int, index: int, itemID: int) -> void
    local player: object = GetPlayer()
    local amount: int
    player->GetItemAmount(amount, index, category)
    local removalOrdinal: int = GetBackpackOrdinal(category, index)
    local oldBackpackCount: int = GetBackpackItemCount()

    local used: bool
    native.UseItem(index, category, used)
    native.Trace("utopian_quickslot window UseItem result=" + used +
      " slot=" + slot + " category=" + category +
      " index=" + index + " item=" + itemID +
      " amount=" + amount)
    if !used then
      ShowMessage(c_iQuickslotUnusableTextID)
      return
    end

    amount = amount - 1
    if amount <= 0 then
      PublishRemovalHint(removalOrdinal, oldBackpackCount)
      player->RemoveItem(index, 1, category)
      ClearBinding(slot)
    else
      player->SetItemAmount(amount, index, category)
    end
    MarkInventoryChanged()
    ShowFeedback(itemID)
  end

  function ActivateQuickslot(slot: int) -> void
    if slot < 1 || slot > c_iQuickslotCount then return end
    local category: int = -1
    local itemID: int = -1
    local occurrence: int = -1
    native.GetVariable(GetCategoryVariable(slot), category)
    native.GetVariable(GetItemVariable(slot), itemID)
    native.GetVariable(GetOccurrenceVariable(slot), occurrence)
    if category < 0 || itemID < 0 then
      local depleted: int = 0
      native.GetVariable(GetDepletedVariable(slot), depleted)
      if depleted == 1 then ShowMessage(c_iQuickslotMissingTextID) end
      return
    end
    native.Trace("utopian_quickslot window activate slot=" + slot +
      " category=" + category + " item=" + itemID +
      " occurrence=" + occurrence)

    local index: int
    local selected: bool
    if !FindBoundItem(category, itemID, occurrence, index, selected) then
      ShowMessage(c_iQuickslotMissingTextID)
      return
    end

    if IsEquippable(category, itemID) then
      ToggleEquipment(category, index, itemID, selected)
    else
      UseConsumable(slot, category, index, itemID)
    end
  end

  function init() -> void
    InitializeBindings()
    m_fMessageCooldown = 0
    local request: int = 0
    native.GetVariable("utopian_quickslot_action_request", request)
    native.SetVariable("utopian_quickslot_action_request", 0)
    native.SetVariable("ui_message_display", 0)
    native.SetVariable("ui_message_busy", 0)
    native.Trace("UTOPIAN_QUICKSLOT_ACTION_VERSION 2026.07.30-inventory-context-1 request=" + request)
    if request > 0 then ActivateQuickslot(request) end
    native.DestroyWindow()
  end
end
