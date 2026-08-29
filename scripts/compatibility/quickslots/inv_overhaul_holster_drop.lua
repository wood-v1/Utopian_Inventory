maintask InvOverhaulHolsterDropEffect do
  local const c_iCWeapon: int = 0
  local const c_iQuickslotCount: int = 10

  function GetItemVariable(slot: int) -> string
    return "inv_overhaul_quickslot_item_" + slot
  end

  function GetCategoryVariable(slot: int) -> string
    return "inv_overhaul_quickslot_category_" + slot
  end

  function GetOccurrenceVariable(slot: int) -> string
    return "inv_overhaul_quickslot_occurrence_" + slot
  end

  function GetDepletedVariable(slot: int) -> string
    return "inv_overhaul_quickslot_depleted_" + slot
  end

  function MarkInventoryChanged() -> void
    local generation: int = 0
    native.GetVariable("inv_overhaul_inventory_reorder_generation", generation)
    native.SetVariable("inv_overhaul_inventory_reorder_generation", generation + 1)
  end

  function AdjustBindings(itemID: int, occurrence: int) -> void
    for slot = 1, c_iQuickslotCount do
      local assignedCategory: int = -1
      local assignedItemID: int = -1
      local assignedOccurrence: int = -1
      native.GetVariable(GetCategoryVariable(slot), assignedCategory)
      native.GetVariable(GetItemVariable(slot), assignedItemID)
      native.GetVariable(GetOccurrenceVariable(slot), assignedOccurrence)
      if assignedCategory == c_iCWeapon && assignedItemID == itemID then
        if assignedOccurrence == occurrence then
          native.SetVariable(GetItemVariable(slot), -1)
          native.SetVariable(GetCategoryVariable(slot), -1)
          native.SetVariable(GetOccurrenceVariable(slot), -1)
          native.SetVariable(GetDepletedVariable(slot), 1)
        else
          if assignedOccurrence > occurrence then
            native.SetVariable(GetOccurrenceVariable(slot), assignedOccurrence - 1)
          end
        end
      end
    end
  end

  function init() -> void
    local player: object
    native.self(player)
    if !player then return end

    local count: int = 0
    local selectedIndex: int = -1
    local itemID: int = -1
    local occurrence: int = 0
    local item: object
    player->GetItemCount(count, c_iCWeapon)
    for index = 0, count - 1 do
      local selected: bool = false
      player->IsItemSelected(selected, index, c_iCWeapon)
      if selected then
        selectedIndex = index
        player->GetItem(item, index, c_iCWeapon)
        if item then item->GetItemID(itemID) end
        for previous = 0, index - 1 do
          local previousItem: object
          local previousID: int = -1
          player->GetItem(previousItem, previous, c_iCWeapon)
          if previousItem then
            previousItem->GetItemID(previousID)
            if previousID == itemID then occurrence = occurrence + 1 end
          end
        end
        index = count
      end
    end
    if selectedIndex < 0 || !item then
      native.Trace("inv_overhaul_holster_drop ignored: no selected weapon")
      return
    end

    local currentItem: object
    local currentID: int = -1
    player->GetItem(currentItem, selectedIndex, c_iCWeapon)
    if currentItem then currentItem->GetItemID(currentID) end
    -- The console-command filter suppresses vanilla handcombat before this
    -- effect starts, so the captured entry is still the actual held weapon.
    -- Revalidate identity before creating the world drop as an item-loss guard.
    if !currentItem || currentID != itemID then
      native.Trace("inv_overhaul_holster_drop cancelled: weapon changed item=" + itemID)
      return
    end

    player->DropItems(currentItem, 1)
    native.Trace("INV_OVERHAUL_QUICKSLOT_NATIVE_HANDS -1")
    player->SelectItem(selectedIndex, false, c_iCWeapon)
    player->RemoveItem(selectedIndex, 1, c_iCWeapon)
    AdjustBindings(itemID, occurrence)
    native.SetVariable("inv_overhaul_quickslot_active_weapon", -1)
    MarkInventoryChanged()
    native.Trace("inv_overhaul_drop_hands completed item=" + itemID +
      " index=" + selectedIndex + " source=holster_effect")
  end
end
