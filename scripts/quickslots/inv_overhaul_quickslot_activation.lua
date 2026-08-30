module inv_overhaul_quickslot_activation do
  local const QuickslotActivationWeaponCategory: int = 0
  local const QuickslotActivationClothesCategory: int = 1
  local const QuickslotActivationCategoryCount: int = 5
  local const QuickslotActivationHelpMessage: int = 200
  local const QuickslotActivationPlayerAddItem: int = 3

  function ActivationGetPlayer() -> object
    local player: object
    native.self(player)
    return player
  end

  function ActivationItemVariable(slot: int) -> string
    return "inv_overhaul_quickslot_item_" + slot
  end

  function ActivationCategoryVariable(slot: int) -> string
    return "inv_overhaul_quickslot_category_" + slot
  end

  function ActivationOccurrenceVariable(slot: int) -> string
    return "inv_overhaul_quickslot_occurrence_" + slot
  end

  function ActivationDepletedVariable(slot: int) -> string
    return "inv_overhaul_quickslot_depleted_" + slot
  end

  function ClearBinding(slot: int) -> void
    native.SetVariable(ActivationItemVariable(slot), -1)
    native.SetVariable(ActivationCategoryVariable(slot), -1)
    native.SetVariable(ActivationOccurrenceVariable(slot), -1)
    native.SetVariable(ActivationDepletedVariable(slot), 1)
  end

  function ShowMessage(textID: int) -> void
    local data: object
    native.CreateIntVector(data)
    data->add(textID)
    native.SendWorldWndMessage(QuickslotActivationHelpMessage, data)
  end

  function ShowFeedback(itemID: int) -> void
    local data: object
    native.CreateIntVector(data)
    data->add(itemID)
    data->add(1)
    native.SendWorldWndMessage(QuickslotActivationPlayerAddItem, data)
  end

  function MarkInventoryChanged() -> void
    local generation: int = 0
    native.GetVariable("inv_overhaul_inventory_reorder_generation", generation)
    native.SetVariable("inv_overhaul_inventory_reorder_generation", generation + 1)
  end

  function ActivationIsEquippedItem(category: int, index: int) -> bool
    if category != QuickslotActivationWeaponCategory &&
      category != QuickslotActivationClothesCategory then return false end
    local player: object = ActivationGetPlayer()
    local selected: bool
    player->IsItemSelected(selected, index, category)
    return selected
  end

  function ActivationGetBackpackItemCount() -> int
    local player: object = ActivationGetPlayer()
    local total: int = 0
    for category = 0, QuickslotActivationCategoryCount - 1 do
      local count: int
      player->GetItemCount(count, category)
      for index = 0, count - 1 do
        if !ActivationIsEquippedItem(category, index) then
          total = total + 1
        end
      end
    end
    return total
  end

  function ActivationGetBackpackOrdinal(
    targetCategory: int,
    targetIndex: int
  ) -> int
    local player: object = ActivationGetPlayer()
    local ordinal: int = 0
    for category = 0, QuickslotActivationCategoryCount - 1 do
      local count: int
      player->GetItemCount(count, category)
      for index = 0, count - 1 do
        if !ActivationIsEquippedItem(category, index) then
          if category == targetCategory && index == targetIndex then return ordinal end
          ordinal = ordinal + 1
        end
      end
    end
    return -1
  end

  function PublishRemovalHint(category: int, index: int) -> void
    local ordinal: int = ActivationGetBackpackOrdinal(category, index)
    if ordinal < 0 then return end
    native.SetVariable("inv_overhaul_inventory_removed_ordinal_hint", ordinal)
    native.SetVariable(
      "inv_overhaul_inventory_removed_ordinal_old_count",
      ActivationGetBackpackItemCount())
    native.SetVariable("inv_overhaul_inventory_removed_ordinal_valid", 1)
  end

  function PublishEquipmentRemovalHint(
    category: int,
    index: int
  ) -> void
    local ordinal: int = ActivationGetBackpackOrdinal(category, index)
    if ordinal < 0 then return end
    local currentCount: int = ActivationGetBackpackItemCount()
    local queueCount: int = 0
    native.GetVariable("inv_overhaul_inventory_equipment_removal_count", queueCount)
    if queueCount < 0 || queueCount >= 8 then queueCount = 0 end
    if queueCount > 0 then
      local previousCount: int = -1
      native.GetVariable(
        "inv_overhaul_inventory_equipment_removal_old_count_" + (queueCount - 1),
        previousCount)
      if currentCount != previousCount - 1 then queueCount = 0 end
    end
    native.SetVariable(
      "inv_overhaul_inventory_equipment_removal_ordinal_" + queueCount, ordinal)
    native.SetVariable(
      "inv_overhaul_inventory_equipment_removal_old_count_" + queueCount,
      currentCount)
    native.SetVariable("inv_overhaul_inventory_equipment_removal_count", queueCount + 1)
    native.SetVariable("inv_overhaul_inventory_removed_ordinal_valid", 0)
    native.Trace("inv_overhaul_quickslot equipment removal queued ordinal=" + ordinal +
      " old=" + currentCount + " queue=" + (queueCount + 1))
  end

  function CancelLastEquipmentRemovalHint() -> void
    local queueCount: int = 0
    native.GetVariable("inv_overhaul_inventory_equipment_removal_count", queueCount)
    if queueCount > 0 then
      native.SetVariable(
        "inv_overhaul_inventory_equipment_removal_count", queueCount - 1)
    end
  end

  function IsEquippable(category: int, itemID: int) -> bool
    local property: bool
    if category == QuickslotActivationWeaponCategory then
      native.HasInvItemProperty(property, itemID, "Weapon")
      return property
    end
    if category == QuickslotActivationClothesCategory then
      native.HasInvItemProperty(property, itemID, "Group")
      return property
    end
    return false
  end

  function FindBoundItemIndex(
    category: int,
    itemID: int,
    wantedOccurrence: int
  ) -> int
    if category < 0 || category >= QuickslotActivationCategoryCount ||
      itemID < 0 || wantedOccurrence < 0 then return -1 end
    local player: object = ActivationGetPlayer()
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
          if occurrence == wantedOccurrence then return candidate end
          occurrence = occurrence + 1
        end
      end
    end
    return -1
  end

  function InitializePersistentState() -> void
    native.SetVariable("inv_overhaul_quickslot_request", 0)
    local stateVersion: int = 0
    native.GetVariable("inv_overhaul_quickslot_state_version", stateVersion)
    if stateVersion == 2 then return end
    native.SetVariable("inv_overhaul_quickslot_active_weapon", -1)
    for slot = 1, 10 do
      native.SetVariable(ActivationDepletedVariable(slot), 0)
      local occurrence: int = 0
      native.GetVariable(ActivationOccurrenceVariable(slot), occurrence)
      if occurrence < 0 then
        native.SetVariable(ActivationOccurrenceVariable(slot), 0)
      end
    end
    native.SetVariable("inv_overhaul_quickslot_state_version", 2)
  end
end
