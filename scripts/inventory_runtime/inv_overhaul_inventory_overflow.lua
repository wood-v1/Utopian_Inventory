module inv_overhaul_inventory_overflow do
  local const InventoryOverflowWeaponCategory: int = 0
  local const InventoryOverflowClothesCategory: int = 1
  local const InventoryOverflowCategoryCount: int = 5

  function OverflowGetPlayer() -> object
    local player: object
    native.self(player)
    return player
  end

  function OverflowIsEquippedItem(category: int, index: int) -> bool
    if category != InventoryOverflowWeaponCategory &&
      category != InventoryOverflowClothesCategory then return false end

    local selected: bool
    local player: object = OverflowGetPlayer()
    player->IsItemSelected(selected, index, category)
    if !selected then return false end

    local item: object
    player->GetItem(item, index, category)
    local itemID: int
    item->GetItemID(itemID)
    if category == InventoryOverflowWeaponCategory then
      local weapon: bool
      native.HasInvItemProperty(weapon, itemID, "Weapon")
      return weapon
    end
    local group: bool
    native.HasInvItemProperty(group, itemID, "Group")
    return group
  end

  function OverflowGetBackpackItemCount() -> int
    local player: object = OverflowGetPlayer()
    local total: int = 0
    for category = 0, InventoryOverflowCategoryCount - 1 do
      local count: int
      player->GetItemCount(count, category)
      for index = 0, count - 1 do
        if !OverflowIsEquippedItem(category, index) then
          total = total + 1
        end
      end
    end
    return total
  end

  function ShouldQueue(
    allowedSlots: int,
    previousCategoryCount: int,
    currentCategoryCount: int
  ) -> bool
    return OverflowGetBackpackItemCount() > allowedSlots &&
      currentCategoryCount > previousCategoryCount
  end

  function DropItem(
    index: int,
    itemID: int,
    category: int
  ) -> bool
    if category < 0 || category >= InventoryOverflowCategoryCount then return false end
    local player: object = OverflowGetPlayer()
    local count: int
    player->GetItemCount(count, category)
    if index < 0 || index >= count ||
      OverflowIsEquippedItem(category, index) then return false end

    local item: object
    local amount: int
    player->GetItem(item, index, category)
    player->GetItemAmount(amount, index, category)
    if !item || amount <= 0 then return false end
    local currentItemID: int
    item->GetItemID(currentItemID)
    if currentItemID != itemID then return false end

    player->DropItems(item, amount)
    player->RemoveItem(index, amount, category)
    return true
  end

  function AdvanceContentGeneration() -> void
    local generation: int = 0
    native.GetVariable("inv_overhaul_inventory_content_generation", generation)
    generation = generation + 1
    if generation <= 0 || generation > 1000000000 then generation = 1 end
    native.SetVariable("inv_overhaul_inventory_content_generation", generation)
  end
end
