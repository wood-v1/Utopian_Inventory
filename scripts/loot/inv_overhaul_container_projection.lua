module inv_overhaul_container_projection do
  local const c_iContainerSlots: int = 12
  local const c_iOrganSlots: int = 4
  local const c_iMaxContainerVisuals: int = 128
  local const c_iReferenceStride: int = 100000

  local containerOrder: object
  local containerIndexCache: object
  local cachedNormalContainerCount: int

  function LootProjectionInitialize() -> void
    local newContainerOrder: object
    native.CreateIntVector(newContainerOrder)
    for visual = 0, c_iMaxContainerVisuals - 1 do newContainerOrder->add(visual) end
    containerOrder = newContainerOrder

    local newContainerIndexCache: object
    native.CreateIntVector(newContainerIndexCache)
    for ordinal = 0, c_iMaxContainerVisuals - 1 do newContainerIndexCache->add(-1) end
    containerIndexCache = newContainerIndexCache
    cachedNormalContainerCount = 0

  end

  function GetContainerOrder(visual: int) -> int
    local order: int = visual
    if visual >= 0 && visual < c_iMaxContainerVisuals then
      local values: object = containerOrder
      values->get(order, visual)
    end
    return order
  end

  function SetContainerOrder(visual: int, value: int) -> void
    if visual < 0 || visual >= c_iMaxContainerVisuals then return end
    local values: object = containerOrder
    values->set(visual, value)
  end

  function IsOrganItem(item: object) -> bool
    if !item then return false end
    local organ: bool = false
    item->HasProperty(organ, "Organ")
    return organ
  end

  function GetNormalItemCount(container: object) -> int
    if !container then return 0 end
    local count: int
    container->GetItemCount(count)
    local normalCount: int = 0
    for index = 0, count - 1 do
      local item: object
      container->GetItem(item, index)
      if !IsOrganItem(item) then normalCount = normalCount + 1 end
    end
    return normalCount
  end

  function LootProjectionBuildIndexCache(container: object) -> void
    -- Rebuild into a fresh local vector. Calling set() through an object copied
    -- from module-global state is not runtime-safe in every generated global
    -- layout, even though the compiler and assembler accept that receiver.
    local newIndexCache: object
    native.CreateIntVector(newIndexCache)
    local normalCount: int = 0
    if container then
      local count: int
      container->GetItemCount(count)
      for index = 0, count - 1 do
        local item: object
        container->GetItem(item, index)
        if !IsOrganItem(item) then
          if normalCount < c_iMaxContainerVisuals then
            newIndexCache->add(index)
          end
          normalCount = normalCount + 1
        end
      end
    end
    for ordinal = normalCount, c_iMaxContainerVisuals - 1 do
      newIndexCache->add(-1)
    end
    containerIndexCache = newIndexCache
    cachedNormalContainerCount = normalCount
  end

  function GetCachedNormalCount() -> int
    return cachedNormalContainerCount
  end

  function LootProjectionEncodeReference(index: int, ordinal: int) -> int
    if index < 0 || ordinal < 0 then return -1 end
    return (ordinal + 1) * c_iReferenceStride + index
  end

  function GetReferenceIndex(reference: int) -> int
    if reference < 0 then return -1 end
    local encodedOrdinal: int = reference / c_iReferenceStride
    return reference - encodedOrdinal * c_iReferenceStride
  end

  function GetReferenceOrdinal(reference: int) -> int
    if reference < 0 then return -1 end
    return reference / c_iReferenceStride - 1
  end

  function ResolveNormalOrdinal(ordinal: int) -> int
    if ordinal < 0 || ordinal >= cachedNormalContainerCount || ordinal >= c_iMaxContainerVisuals then return -1 end
    local index: int = -1
    local indexCache: object = containerIndexCache
    indexCache->get(index, ordinal)
    return LootProjectionEncodeReference(index, ordinal)
  end

  function GetOrganSlotByItemID(itemID: int) -> int
    local knownID: int
    native.GetInvItemByName(knownID, "liver")
    if itemID == knownID then return 0 end
    native.GetInvItemByName(knownID, "diseased_liver")
    if itemID == knownID then return 0 end
    native.GetInvItemByName(knownID, "kidney")
    if itemID == knownID then return 1 end
    native.GetInvItemByName(knownID, "diseased_kidney")
    if itemID == knownID then return 1 end
    native.GetInvItemByName(knownID, "heart")
    if itemID == knownID then return 2 end
    native.GetInvItemByName(knownID, "diseased_heart")
    if itemID == knownID then return 2 end
    native.GetInvItemByName(knownID, "blood")
    if itemID == knownID then return 3 end
    native.GetInvItemByName(knownID, "diseased_blood")
    if itemID == knownID then return 3 end
    return -1
  end

  function ResolveOrganVisual(container: object, slot: int) -> int
    if !container then return -1 end
    local count: int
    container->GetItemCount(count)
    for index = 0, count - 1 do
      local item: object
      container->GetItem(item, index)
      if IsOrganItem(item) then
        local itemID: int
        item->GetItemID(itemID)
        if GetOrganSlotByItemID(itemID) == slot then
          return LootProjectionEncodeReference(index, slot)
        end
      end
    end
    return -1
  end

  function GetLastOccupiedVisual() -> int
    local count: int = cachedNormalContainerCount
    if count <= 0 then return -1 end
    local last: int = -1
    for visual = 0, c_iMaxContainerVisuals - 1 do
      if GetContainerOrder(visual) < count then last = visual end
    end
    return last
  end

  function LootProjectionGetMaxPage() -> int
    local lastVisual: int = GetLastOccupiedVisual()
    if lastVisual < 0 then return 0 end
    return lastVisual / c_iContainerSlots
  end

  function FindFirstFreeContainerVisual(itemCount: int) -> int
    for visual = 0, c_iMaxContainerVisuals - 1 do
      if GetContainerOrder(visual) >= itemCount then return visual end
    end
    return -1
  end

  function InsertContainerOrdinalAt(
    page: int,
    insertedOrder: int,
    beforeCount: int,
    preferredSlot: int) -> bool
    if insertedOrder < 0 then return false end
    if beforeCount >= c_iMaxContainerVisuals then return false end
    local preferredVisual: int = page * c_iContainerSlots + preferredSlot
    local insertedVisual: int = -1
    for visual = 0, c_iMaxContainerVisuals - 1 do
      local order: int = GetContainerOrder(visual)
      if order == beforeCount then
        SetContainerOrder(visual, insertedOrder)
        insertedVisual = visual
      else
        if order >= insertedOrder && order < beforeCount then
          SetContainerOrder(visual, order + 1)
        end
      end
    end
    if insertedVisual < 0 then return false end
    if preferredSlot >= 0 && preferredSlot < c_iContainerSlots && preferredVisual != insertedVisual then
      local preferredOrder: int = GetContainerOrder(preferredVisual)
      SetContainerOrder(preferredVisual, insertedOrder)
      SetContainerOrder(insertedVisual, preferredOrder)
    end
    return true
  end

  function RemoveContainerOrdinal(removedOrder: int, beforeCount: int) -> void
    if removedOrder < 0 then return end
    local emptyOrder: int = beforeCount - 1
    for visual = 0, c_iMaxContainerVisuals - 1 do
      local order: int = GetContainerOrder(visual)
      if order == removedOrder then
        SetContainerOrder(visual, emptyOrder)
      else
        if order > removedOrder && order < beforeCount then
          SetContainerOrder(visual, order - 1)
        end
      end
    end
  end

  function SwapVisuals(
    sourceVisual: int,
    targetVisual: int) -> bool
    if sourceVisual < 0 || sourceVisual >= c_iMaxContainerVisuals then return false end
    if targetVisual < 0 || targetVisual >= c_iMaxContainerVisuals ||
      sourceVisual == targetVisual then return false end
    local sourceOrder: int = GetContainerOrder(sourceVisual)
    local targetOrder: int = GetContainerOrder(targetVisual)
    SetContainerOrder(sourceVisual, targetOrder)
    SetContainerOrder(targetVisual, sourceOrder)
    return true
  end

end
