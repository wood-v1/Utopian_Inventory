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

  function QuickslotBindingsInitializeState() -> void
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

  function GetItemVariable(slot: int) -> string
    return "inv_overhaul_quickslot_item_" + slot
  end

  function GetCategoryVariable(slot: int) -> string
    return "inv_overhaul_quickslot_category_" + slot
  end

  function GetDepletedVariable(slot: int) -> string
    return "inv_overhaul_quickslot_depleted_" + slot
  end

  function GetOccurrenceVariable(slot: int) -> string
    return "inv_overhaul_quickslot_occurrence_" + slot
  end

  function InitializeBindings() -> void
    local version: int = 0
    native.GetVariable("inv_overhaul_quickslot_version", version)
    if version == QuickslotVersion then return end
    for slot = 1, QuickslotCount do
      native.SetVariable(GetItemVariable(slot), -1)
      native.SetVariable(GetCategoryVariable(slot), -1)
    end
    native.SetVariable("inv_overhaul_quickslot_version", QuickslotVersion)
  end

  function RefreshCache() -> void
    for slot = 1, QuickslotCount do
      local assignedCategory: int = -1
      local assignedItem: int = -1
      local assignedOccurrence: int = -1
      native.GetVariable(GetCategoryVariable(slot), assignedCategory)
      native.GetVariable(GetItemVariable(slot), assignedItem)
      native.GetVariable(GetOccurrenceVariable(slot), assignedOccurrence)
      categoryCache->set(slot - 1, assignedCategory)
      itemCache->set(slot - 1, assignedItem)
      occurrenceCache->set(slot - 1, assignedOccurrence)
    end
  end

  function GetItemBinding(
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

  function GetDisplayedBinding(
    category: int,
    index: int,
    itemID: int) -> int
    if GetItemBinding(category, itemID) <= 0 then return 0 end
    local occurrence: int = inv_overhaul_inventory_items.GetOccurrence(category, index, itemID)
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

  function IsEligible(category: int, itemID: int) -> bool
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

  function Assign(
    slot: int,
    category: int,
    index: int,
    emitTrace: bool) -> bool
    if slot < 1 || slot > QuickslotCount then return false end
    local container: object = inv_overhaul_inventory_items.ItemsGetPlayerContainer()
    local item: object
    local itemID: int
    container->GetItem(item, index, category)
    if !item then return false end
    item->GetItemID(itemID)
    if !IsEligible(category, itemID) then return false end
    local occurrence: int = inv_overhaul_inventory_items.GetOccurrence(category, index, itemID)

    local oldCategory: int = -1
    local oldItem: int = -1
    local oldOccurrence: int = 0
    native.GetVariable(GetCategoryVariable(slot), oldCategory)
    native.GetVariable(GetItemVariable(slot), oldItem)
    native.GetVariable(GetOccurrenceVariable(slot), oldOccurrence)
    if oldCategory == category && oldItem == itemID && oldOccurrence == occurrence then
      native.SetVariable(GetCategoryVariable(slot), -1)
      native.SetVariable(GetItemVariable(slot), -1)
      native.SetVariable(GetDepletedVariable(slot), 0)
      native.SetVariable(GetOccurrenceVariable(slot), -1)
      categoryCache->set(slot - 1, -1)
      itemCache->set(slot - 1, -1)
      occurrenceCache->set(slot - 1, -1)
      if emitTrace then
        native.Trace("inv_overhaul_quickslot cleared slot=" + slot + " item=" + itemID)
      end
    else
      for other = 1, QuickslotCount do
        local otherCategory: int = -1
        local otherItem: int = -1
        local otherOccurrence: int = 0
        native.GetVariable(GetCategoryVariable(other), otherCategory)
        native.GetVariable(GetItemVariable(other), otherItem)
        native.GetVariable(GetOccurrenceVariable(other), otherOccurrence)
        if otherCategory == category && otherItem == itemID && otherOccurrence == occurrence then
          native.SetVariable(GetCategoryVariable(other), -1)
          native.SetVariable(GetItemVariable(other), -1)
          native.SetVariable(GetDepletedVariable(other), 0)
          native.SetVariable(GetOccurrenceVariable(other), -1)
          categoryCache->set(other - 1, -1)
          itemCache->set(other - 1, -1)
          occurrenceCache->set(other - 1, -1)
        end
      end
      native.SetVariable(GetCategoryVariable(slot), category)
      native.SetVariable(GetItemVariable(slot), itemID)
      native.SetVariable(GetDepletedVariable(slot), 0)
      native.SetVariable(GetOccurrenceVariable(slot), occurrence)
      categoryCache->set(slot - 1, category)
      itemCache->set(slot - 1, itemID)
      occurrenceCache->set(slot - 1, occurrence)
      if emitTrace then
        native.Trace("inv_overhaul_quickslot assigned slot=" + slot + " category=" + category +
          " item=" + itemID + " occurrence=" + occurrence)
      end
    end
    return true
  end

  function GetSlotByKey(key: int) -> int
    if key >= 49 && key <= 57 then return key - 48 end
    if key == 48 then return 10 end
    if key >= 97 && key <= 105 then return key - 96 end
    if key == 96 then return 10 end
    return 0
  end
end
