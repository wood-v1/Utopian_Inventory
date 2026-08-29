module inv_overhaul_inventory_items do
  local const CategoryCount: int = 5
  local const InventoryCapacity: int = 56
  local const WeaponCategory: int = 0
  local const ClothesCategory: int = 1
  local const ItemReferenceStride: int = 100000

  local categoryCache: object
  local indexCache: object
  local cachedBackpackCount: int

  function InventoryItemsInitializeProjection() -> void
    local newCategoryCache: object
    local newIndexCache: object
    native.CreateIntVector(newCategoryCache)
    native.CreateIntVector(newIndexCache)
    categoryCache = newCategoryCache
    indexCache = newIndexCache
    cachedBackpackCount = -1
    for ordinal = 0, InventoryCapacity - 1 do
      categoryCache->add(-1)
      indexCache->add(-1)
    end
  end

  function InventoryItemsGetPlayerContainer() -> object
    local container: object
    native.GetPlayerContainer(container)
    return container
  end

  function InventoryItemsIsEquipped(category: int, index: int) -> bool
    if category != WeaponCategory && category != ClothesCategory then return false end
    local container: object = InventoryItemsGetPlayerContainer()
    local selected: bool
    container->IsItemSelected(selected, index, category)
    if !selected then return false end

    local item: object
    container->GetItem(item, index, category)
    local itemID: int
    item->GetItemID(itemID)
    if category == WeaponCategory then
      local hasWeapon: bool
      native.HasInvItemProperty(hasWeapon, itemID, "Weapon")
      return hasWeapon
    end
    local hasGroup: bool
    native.HasInvItemProperty(hasGroup, itemID, "Group")
    return hasGroup
  end

  function InventoryItemsGetBackpackCount() -> int
    local container: object = InventoryItemsGetPlayerContainer()
    local total: int = 0
    for category = 0, CategoryCount - 1 do
      local count: int
      container->GetItemCount(count, category)
      for index = 0, count - 1 do
        if !InventoryItemsIsEquipped(category, index) then total = total + 1 end
      end
    end
    return total
  end

  function InventoryItemsCaptureIdentitySnapshot(snapshot: object) -> int
    local container: object = InventoryItemsGetPlayerContainer()
    local ordinal: int = 0
    for cell = 0, InventoryCapacity - 1 do snapshot->set(cell, -1) end
    for category = 0, CategoryCount - 1 do
      local count: int
      container->GetItemCount(count, category)
      for index = 0, count - 1 do
        if !InventoryItemsIsEquipped(category, index) then
          if ordinal < InventoryCapacity then
            local item: object
            local itemID: int
            container->GetItem(item, index, category)
            if item then
              item->GetItemID(itemID)
              snapshot->set(ordinal, itemID)
            end
          end
          ordinal = ordinal + 1
        end
      end
    end
    return ordinal
  end

  function InventoryItemsBuildIndexCache() -> void
    for ordinal = 0, InventoryCapacity - 1 do
      categoryCache->set(ordinal, -1)
      indexCache->set(ordinal, -1)
    end
    local container: object = InventoryItemsGetPlayerContainer()
    local ordinal: int = 0
    for category = 0, CategoryCount - 1 do
      local count: int
      container->GetItemCount(count, category)
      for index = 0, count - 1 do
        if !InventoryItemsIsEquipped(category, index) then
          if ordinal < InventoryCapacity then
            categoryCache->set(ordinal, category)
            indexCache->set(ordinal, index)
          end
          ordinal = ordinal + 1
        end
      end
    end
    cachedBackpackCount = ordinal
  end

  function InventoryItemsBuildIndexCacheAndSnapshot(
    snapshot: object) -> int
    for ordinal = 0, InventoryCapacity - 1 do
      categoryCache->set(ordinal, -1)
      indexCache->set(ordinal, -1)
      snapshot->set(ordinal, -1)
    end
    local container: object = InventoryItemsGetPlayerContainer()
    local ordinal: int = 0
    for category = 0, CategoryCount - 1 do
      local count: int
      container->GetItemCount(count, category)
      for index = 0, count - 1 do
        if !InventoryItemsIsEquipped(category, index) then
          if ordinal < InventoryCapacity then
            local item: object
            local itemID: int = -1
            categoryCache->set(ordinal, category)
            indexCache->set(ordinal, index)
            container->GetItem(item, index, category)
            if item then item->GetItemID(itemID) end
            snapshot->set(ordinal, itemID)
          end
          ordinal = ordinal + 1
        end
      end
    end
    cachedBackpackCount = ordinal
    return ordinal
  end

  function InventoryItemsGetCachedBackpackCount() -> int
    return cachedBackpackCount
  end

  function InventoryItemsGetAppendedCategoryOrdinal(
    category: int,
    beforeCount: int) -> int
    local insertedOrdinal: int = 0
    for ordinal = 0, beforeCount - 1 do
      local cachedCategory: int
      categoryCache->get(cachedCategory, ordinal)
      if cachedCategory <= category then insertedOrdinal = insertedOrdinal + 1 end
    end
    return insertedOrdinal
  end

  function InventoryItemsInsertCachedEntry(
    insertedOrdinal: int,
    beforeCount: int,
    category: int,
    index: int) -> void
    local ordinal: int = beforeCount
    while ordinal > insertedOrdinal do
      local previousCategory: int
      local previousIndex: int
      categoryCache->get(previousCategory, ordinal - 1)
      indexCache->get(previousIndex, ordinal - 1)
      categoryCache->set(ordinal, previousCategory)
      indexCache->set(ordinal, previousIndex)
      ordinal = ordinal - 1
    end
    categoryCache->set(insertedOrdinal, category)
    indexCache->set(insertedOrdinal, index)
    cachedBackpackCount = beforeCount + 1
  end

  function InventoryItemsRemoveCachedEntry(
    removedOrdinal: int,
    beforeCount: int,
    removedCategory: int,
    removedIndex: int) -> void
    for ordinal = removedOrdinal, beforeCount - 2 do
      local nextCategory: int
      local nextIndex: int
      categoryCache->get(nextCategory, ordinal + 1)
      indexCache->get(nextIndex, ordinal + 1)
      if nextCategory == removedCategory && nextIndex > removedIndex then
        nextIndex = nextIndex - 1
      end
      categoryCache->set(ordinal, nextCategory)
      indexCache->set(ordinal, nextIndex)
    end
    if beforeCount > 0 then
      categoryCache->set(beforeCount - 1, -1)
      indexCache->set(beforeCount - 1, -1)
    end
    cachedBackpackCount = beforeCount - 1
  end

  function InventoryItemsGetBackpackOrdinal(category: int, index: int) -> int
    local container: object = InventoryItemsGetPlayerContainer()
    local ordinal: int = 0
    for currentCategory = 0, CategoryCount - 1 do
      local count: int
      container->GetItemCount(count, currentCategory)
      for currentIndex = 0, count - 1 do
        if !InventoryItemsIsEquipped(currentCategory, currentIndex) then
          if currentCategory == category && currentIndex == index then return ordinal end
          ordinal = ordinal + 1
        end
      end
    end
    return -1
  end

  function InventoryItemsGetOccurrence(category: int, index: int, itemID: int) -> int
    local container: object = InventoryItemsGetPlayerContainer()
    local occurrence: int = 0
    for candidate = 0, index - 1 do
      local candidateItem: object
      local candidateID: int
      container->GetItem(candidateItem, candidate, category)
      if candidateItem then
        candidateItem->GetItemID(candidateID)
        if candidateID == itemID then occurrence = occurrence + 1 end
      end
    end
    return occurrence
  end

  function InventoryItemsEncodeReference(category: int, index: int) -> int
    if category < 0 || index < 0 then return -1 end
    return (category + 1) * ItemReferenceStride + index
  end

  function InventoryItemsResolveCachedOrdinal(
    ordinal: int) -> int
    if ordinal < 0 || ordinal >= InventoryCapacity then return -1 end
    local category: int = -1
    local index: int = -1
    categoryCache->get(category, ordinal)
    indexCache->get(index, ordinal)
    return InventoryItemsEncodeReference(category, index)
  end

  function InventoryItemsGetCachedCategory(ordinal: int) -> int
    local category: int = -1
    if ordinal >= 0 && ordinal < InventoryCapacity then categoryCache->get(category, ordinal) end
    return category
  end

  function InventoryItemsGetCachedIndex(ordinal: int) -> int
    local index: int = -1
    if ordinal >= 0 && ordinal < InventoryCapacity then indexCache->get(index, ordinal) end
    return index
  end

  function InventoryItemsDecodeReferenceCategory(reference: int) -> int
    if reference < 0 then return -1 end
    return reference / ItemReferenceStride - 1
  end

  function InventoryItemsDecodeReferenceIndex(reference: int) -> int
    if reference < 0 then return -1 end
    local categoryToken: int = reference / ItemReferenceStride
    return reference - categoryToken * ItemReferenceStride
  end
end
