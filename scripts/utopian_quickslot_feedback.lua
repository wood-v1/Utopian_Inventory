maintask UtopianQuickslotFeedback do
  local const c_iCWeapon: int = 0
  local const c_iCClothes: int = 1
  local const c_iCategoryCount: int = 5
  local const c_iInventoryCapacity: int = 56
  local const c_iQuickslotCount: int = 10
  local const c_iWMPlayerAddItem: int = 3
  local const c_iWMHelpMessage: int = 200
  local const c_iWMQuickslotFeedback: int = 260
  local const c_iWMQuickslotHandsItem: int = 261
  local const c_iInventoryFullTextID: int = 1400
  local const c_iQuickslotMissingTextID: int = 1405
  local const c_iQuickslotUnusableTextID: int = 1406
  local const c_fVisibleTime: float = 2.0
  local const c_fMessageCooldown: float = 0.75

  local itemID: int
  local amount: int
  local sprite: string
  local timeLeft: float
  local messageCooldown: float

  function GetPlayer() -> object
    local player: object
    native.GetPlayerContainer(player)
    return player
  end

  function GetQuickslotItemVariable(slot: int) -> string
    return "utopian_quickslot_item_" + slot
  end

  function GetQuickslotCategoryVariable(slot: int) -> string
    return "utopian_quickslot_category_" + slot
  end

  function GetQuickslotOccurrenceVariable(slot: int) -> string
    return "utopian_quickslot_occurrence_" + slot
  end

  function GetQuickslotDepletedVariable(slot: int) -> string
    return "utopian_quickslot_depleted_" + slot
  end

  function ClearQuickslotBinding(slot: int) -> void
    native.SetVariable(GetQuickslotItemVariable(slot), -1)
    native.SetVariable(GetQuickslotCategoryVariable(slot), -1)
    native.SetVariable(GetQuickslotOccurrenceVariable(slot), -1)
    native.SetVariable(GetQuickslotDepletedVariable(slot), 1)
    native.Trace("utopian_quickslot UI cleared exhausted binding slot=" + slot)
  end

  function ShowMessage(textID: int) -> void
    if messageCooldown > 0 then return end
    local text: object
    native.CreateIntVector(text)
    text->add(textID)
    native.SendWorldWndMessage(c_iWMHelpMessage, text)
    messageCooldown = c_fMessageCooldown
  end

  function IsEquippable(category: int, candidateItemID: int) -> bool
    local property: bool
    if category == c_iCWeapon then
      native.HasInvItemProperty(property, candidateItemID, "Weapon")
      return property
    end
    if category == c_iCClothes then
      native.HasInvItemProperty(property, candidateItemID, "Group")
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
    local candidate: object
    local candidateItemID: int
    player->GetItem(candidate, index, category)
    if !candidate then return false end
    candidate->GetItemID(candidateItemID)
    return IsEquippable(category, candidateItemID)
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
    native.Trace("utopian_quickslot UI removal hint ordinal=" + ordinal +
      " old=" + oldCount)
  end

  function FindBoundItem(
    category: int,
    wantedItemID: int,
    wantedOccurrence: int,
    index: int,
    selected: bool
  ) -> bool
    index = -1
    selected = false
    if category < 0 || category >= c_iCategoryCount ||
      wantedItemID < 0 || wantedOccurrence < 0 then return false end

    local player: object = GetPlayer()
    local count: int
    local occurrence: int = 0
    player->GetItemCount(count, category)
    for candidateIndex = 0, count - 1 do
      local candidate: object
      local candidateItemID: int
      player->GetItem(candidate, candidateIndex, category)
      if candidate then
        candidate->GetItemID(candidateItemID)
        if candidateItemID == wantedItemID then
          if occurrence == wantedOccurrence then
            player->IsItemSelected(selected, candidateIndex, category)
            index = candidateIndex
            return true
          end
          occurrence = occurrence + 1
        end
      end
    end
    return false
  end

  function ShowFeedback(newItemID: int) -> void
    itemID = newItemID
    amount = 1
    native.GetInvItemSprite(sprite, itemID)
    if sprite != "" then native.LoadImage(sprite) end
    timeLeft = c_fVisibleTime

    local data: object
    native.CreateIntVector(data)
    data->add(newItemID)
    data->add(1)
    native.SendWorldWndMessage(c_iWMPlayerAddItem, data)
  end

  function MarkInventoryChanged() -> void
    local generation: int = 0
    native.GetVariable("utopian_inventory_reorder_generation", generation)
    native.SetVariable("utopian_inventory_reorder_generation", generation + 1)
  end

  function ToggleEquipment(category: int, index: int, candidateItemID: int, selected: bool) -> void
    local player: object = GetPlayer()
    if selected then
      if GetBackpackItemCount() >= c_iInventoryCapacity then
        ShowMessage(c_iInventoryFullTextID)
        return
      end
      player->SelectItem(index, false, category)
      if category == c_iCWeapon then native.SetPlayerHandsItem(-1) end
      MarkInventoryChanged()
      ShowFeedback(candidateItemID)
      return
    end

    if category == c_iCWeapon then
      local count: int
      player->GetItemCount(count, category)
      for other = 0, count - 1 do player->SelectItem(other, false, category) end
      player->SelectItem(index, true, category)
      native.SetPlayerHandsItem(candidateItemID)
      MarkInventoryChanged()
      ShowFeedback(candidateItemID)
      return
    end

    local group: int
    native.GetInvItemProperty(group, candidateItemID, "Group")
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
    ShowFeedback(candidateItemID)
  end

  function UseConsumable(slot: int, category: int, index: int, candidateItemID: int) -> void
    local player: object = GetPlayer()
    local amountBefore: int
    player->GetItemAmount(amountBefore, index, category)
    local removalOrdinal: int = GetBackpackOrdinal(category, index)
    local oldBackpackCount: int = GetBackpackItemCount()

    local used: bool
    native.UseItem(index, category, used)
    native.Trace("utopian_quickslot UI UseItem result=" + used +
      " slot=" + slot + " category=" + category +
      " index=" + index + " item=" + candidateItemID +
      " amount=" + amountBefore)
    if !used then
      ShowMessage(c_iQuickslotUnusableTextID)
      return
    end

    local remaining: int = amountBefore - 1
    if remaining <= 0 then
      PublishRemovalHint(removalOrdinal, oldBackpackCount)
      player->RemoveItem(index, 1, category)
      ClearQuickslotBinding(slot)
    else
      player->SetItemAmount(remaining, index, category)
    end
    MarkInventoryChanged()
    ShowFeedback(candidateItemID)
    native.Trace("utopian_quickslot UI consumed item=" + candidateItemID +
      " remaining=" + remaining)
  end

  function ActivateQuickslot(slot: int) -> void
    if slot < 1 || slot > c_iQuickslotCount then return end
    local category: int = -1
    local boundItemID: int = -1
    local occurrence: int = -1
    native.GetVariable(GetQuickslotCategoryVariable(slot), category)
    native.GetVariable(GetQuickslotItemVariable(slot), boundItemID)
    native.GetVariable(GetQuickslotOccurrenceVariable(slot), occurrence)
    native.Trace("utopian_quickslot UI request slot=" + slot +
      " category=" + category + " item=" + boundItemID +
      " occurrence=" + occurrence)

    if category < 0 || boundItemID < 0 then
      local depleted: int = 0
      native.GetVariable(GetQuickslotDepletedVariable(slot), depleted)
      if depleted == 1 then ShowMessage(c_iQuickslotMissingTextID) end
      return
    end

    local index: int
    local selected: bool
    if !FindBoundItem(category, boundItemID, occurrence, index, selected) then
      ShowMessage(c_iQuickslotMissingTextID)
      return
    end
    if IsEquippable(category, boundItemID) then
      ToggleEquipment(category, index, boundItemID, selected)
    else
      UseConsumable(slot, category, index, boundItemID)
    end
  end

  function ProcessQuickslotRequest() -> void
    local request: int = 0
    native.GetVariable("utopian_quickslot_ui_request", request)
    if request <= 0 then return end
    native.SetVariable("utopian_quickslot_ui_request", 0)
    ActivateQuickslot(request)
  end

  function init() -> void
    itemID = -1
    amount = 0
    sprite = ""
    timeLeft = 0
    messageCooldown = 0
    native.SetOwnerDraw(true)
    native.SetNeedUpdate(true)
    native.Trace("UTOPIAN_QUICKSLOT_FEEDBACK_VERSION 2026.07.30-ui-runtime-1")
    enable OnGameMessage
    native.ProcessEvents()
  end

  function OnGameMessage(id: int, data: object) -> void
    if id == c_iWMQuickslotHandsItem then
      if !data then return end
      local handsSize: int
      data->size(handsSize)
      if handsSize < 1 then return end
      local handsItemID: int
      data->get(handsItemID, 0)
      native.SetPlayerHandsItem(handsItemID)
      return
    end
    if id != c_iWMQuickslotFeedback || !data then return end
    local size: int
    data->size(size)
    if size < 1 then return end
    local newItemID: int
    data->get(newItemID, 0)
    if newItemID >= 0 then ShowFeedback(newItemID) end
  end

  function OnUpdate(delta: float) -> void
    ProcessQuickslotRequest()
    if messageCooldown > 0 then
      messageCooldown = messageCooldown - delta
      if messageCooldown < 0 then messageCooldown = 0 end
    end
    if timeLeft <= 0 then return end
    timeLeft = timeLeft - delta
    if timeLeft <= 0 then
      timeLeft = 0
      sprite = ""
      itemID = -1
    end
  end

  function OnDraw() -> void
    if itemID < 0 || sprite == "" || timeLeft <= 0 then return end
    local alpha: float = 1
    if timeLeft < 0.5 then alpha = timeLeft / 0.5 end
    native.Blit("slot", 40, 40, alpha)
    native.Blit(sprite, 41, 41, alpha)
    native.StretchBlit("target", 35, 35, 52, 52, alpha)
    if amount > 1 then native.Print("default", 42, 75, amount, 1, 1, 1, alpha) end
  end
end
