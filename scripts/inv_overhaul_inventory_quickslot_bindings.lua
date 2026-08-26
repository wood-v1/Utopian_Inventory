import "inv_overhaul_inventory_items"

module inv_overhaul_inventory_quickslot_bindings do
  local const QuickslotCount: int = 10
  local const QuickslotVersion: int = 1
  local const WeaponCategory: int = 0
  local const ClothesCategory: int = 1
  local const CategoryCount: int = 5

  local itemCache: object
  local categoryCache: object
  local occurrenceCache: object

  function InventoryQuickslotInitializeState() -> void
    local newItemCache: object
    local newCategoryCache: object
    local newOccurrenceCache: object
    native.CreateIntVector(newItemCache)
    native.CreateIntVector(newCategoryCache)
    native.CreateIntVector(newOccurrenceCache)
    itemCache = newItemCache
    categoryCache = newCategoryCache
    occurrenceCache = newOccurrenceCache
    for slot = 1, QuickslotCount do
      itemCache->add(-1)
      categoryCache->add(-1)
      occurrenceCache->add(-1)
    end
  end

  function InventoryQuickslotGetItemVariable(slot: int) -> string
    return "inv_overhaul_quickslot_item_" + slot
  end

  function InventoryQuickslotGetCategoryVariable(slot: int) -> string
    return "inv_overhaul_quickslot_category_" + slot
  end

  function InventoryQuickslotGetDepletedVariable(slot: int) -> string
    return "inv_overhaul_quickslot_depleted_" + slot
  end

  function InventoryQuickslotGetOccurrenceVariable(slot: int) -> string
    return "inv_overhaul_quickslot_occurrence_" + slot
  end

  function InventoryQuickslotInitializeBindings() -> void
    local version: int = 0
    native.GetVariable("inv_overhaul_quickslot_version", version)
    if version == QuickslotVersion then return end
    for slot = 1, QuickslotCount do
      native.SetVariable(InventoryQuickslotGetItemVariable(slot), -1)
      native.SetVariable(InventoryQuickslotGetCategoryVariable(slot), -1)
    end
    native.SetVariable("inv_overhaul_quickslot_version", QuickslotVersion)
  end

  function InventoryQuickslotRefreshCache() -> void
    for slot = 1, QuickslotCount do
      local assignedCategory: int = -1
      local assignedItem: int = -1
      local assignedOccurrence: int = -1
      native.GetVariable(InventoryQuickslotGetCategoryVariable(slot), assignedCategory)
      native.GetVariable(InventoryQuickslotGetItemVariable(slot), assignedItem)
      native.GetVariable(InventoryQuickslotGetOccurrenceVariable(slot), assignedOccurrence)
      categoryCache->set(slot - 1, assignedCategory)
      itemCache->set(slot - 1, assignedItem)
      occurrenceCache->set(slot - 1, assignedOccurrence)
    end
  end

  function InventoryQuickslotGetItemBinding(
    category: int,
    itemID: int) -> int
    for slot = 1, QuickslotCount do
      local assignedCategory: int = -1
      local assignedItem: int = -1
      categoryCache->get(assignedCategory, slot - 1)
      itemCache->get(assignedItem, slot - 1)
      if assignedCategory == category && assignedItem == itemID then return slot end
    end
    return 0
  end

  function InventoryQuickslotGetDisplayedBinding(
    category: int,
    index: int,
    itemID: int) -> int
    local occurrence: int = inv_overhaul_inventory_items.InventoryItemsGetOccurrence(category, index, itemID)
    for slot = 1, QuickslotCount do
      local assignedCategory: int = -1
      local assignedItem: int = -1
      local assignedOccurrence: int = -1
      categoryCache->get(assignedCategory, slot - 1)
      itemCache->get(assignedItem, slot - 1)
      occurrenceCache->get(assignedOccurrence, slot - 1)
      if assignedCategory == category && assignedItem == itemID &&
        assignedOccurrence == occurrence then return slot end
    end
    return 0
  end

  function InventoryQuickslotIsEligible(category: int, itemID: int) -> bool
    if category == WeaponCategory then
      local weapon: bool
      native.HasInvItemProperty(weapon, itemID, "Weapon")
      return weapon
    end
    if category == ClothesCategory then
      local group: bool
      native.HasInvItemProperty(group, itemID, "Group")
      return group
    end
    return category >= 2 && category < CategoryCount
  end

  function InventoryQuickslotAssign(
    slot: int,
    category: int,
    index: int) -> bool
    if slot < 1 || slot > QuickslotCount then return false end
    local container: object = inv_overhaul_inventory_items.InventoryItemsGetPlayerContainer()
    local item: object
    local itemID: int
    container->GetItem(item, index, category)
    if !item then return false end
    item->GetItemID(itemID)
    if !InventoryQuickslotIsEligible(category, itemID) then return false end
    local occurrence: int = inv_overhaul_inventory_items.InventoryItemsGetOccurrence(category, index, itemID)

    local oldCategory: int = -1
    local oldItem: int = -1
    local oldOccurrence: int = 0
    native.GetVariable(InventoryQuickslotGetCategoryVariable(slot), oldCategory)
    native.GetVariable(InventoryQuickslotGetItemVariable(slot), oldItem)
    native.GetVariable(InventoryQuickslotGetOccurrenceVariable(slot), oldOccurrence)
    if oldCategory == category && oldItem == itemID && oldOccurrence == occurrence then
      native.SetVariable(InventoryQuickslotGetCategoryVariable(slot), -1)
      native.SetVariable(InventoryQuickslotGetItemVariable(slot), -1)
      native.SetVariable(InventoryQuickslotGetDepletedVariable(slot), 0)
      native.SetVariable(InventoryQuickslotGetOccurrenceVariable(slot), -1)
      categoryCache->set(slot - 1, -1)
      itemCache->set(slot - 1, -1)
      occurrenceCache->set(slot - 1, -1)
      native.Trace("inv_overhaul_quickslot cleared slot=" + slot + " item=" + itemID)
    else
      for other = 1, QuickslotCount do
        local otherCategory: int = -1
        local otherItem: int = -1
        local otherOccurrence: int = 0
        native.GetVariable(InventoryQuickslotGetCategoryVariable(other), otherCategory)
        native.GetVariable(InventoryQuickslotGetItemVariable(other), otherItem)
        native.GetVariable(InventoryQuickslotGetOccurrenceVariable(other), otherOccurrence)
        if otherCategory == category && otherItem == itemID && otherOccurrence == occurrence then
          native.SetVariable(InventoryQuickslotGetCategoryVariable(other), -1)
          native.SetVariable(InventoryQuickslotGetItemVariable(other), -1)
          native.SetVariable(InventoryQuickslotGetDepletedVariable(other), 0)
          native.SetVariable(InventoryQuickslotGetOccurrenceVariable(other), -1)
          categoryCache->set(other - 1, -1)
          itemCache->set(other - 1, -1)
          occurrenceCache->set(other - 1, -1)
        end
      end
      native.SetVariable(InventoryQuickslotGetCategoryVariable(slot), category)
      native.SetVariable(InventoryQuickslotGetItemVariable(slot), itemID)
      native.SetVariable(InventoryQuickslotGetDepletedVariable(slot), 0)
      native.SetVariable(InventoryQuickslotGetOccurrenceVariable(slot), occurrence)
      categoryCache->set(slot - 1, category)
      itemCache->set(slot - 1, itemID)
      occurrenceCache->set(slot - 1, occurrence)
      native.Trace("inv_overhaul_quickslot assigned slot=" + slot + " category=" + category +
        " item=" + itemID + " occurrence=" + occurrence)
    end
    return true
  end

  function InventoryQuickslotGetSlotByKey(key: int) -> int
    if key >= 49 && key <= 57 then return key - 48 end
    if key == 48 then return 10 end
    if key >= 97 && key <= 105 then return key - 96 end
    if key == 96 then return 10 end
    return 0
  end
end
