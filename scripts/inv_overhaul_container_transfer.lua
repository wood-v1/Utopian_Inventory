import "inv_overhaul_inventory_items"

module inv_overhaul_container_transfer do
  function ContainerTransferNormalizeAmount(requestedAmount: int, availableAmount: int) -> int
    if requestedAmount <= 0 || requestedAmount > availableAmount then return availableAmount end
    return requestedAmount
  end

  function ContainerTransferFindPlayerMergeIndex(
    player: object,
    category: int,
    itemID: int) -> int
    if !player then return -1 end
    local maxStackSize: int
    native.GetInvItemMaxStackSize(maxStackSize, itemID)
    if maxStackSize <= 1 then return -1 end
    local count: int
    player->GetItemCount(count, category)
    for index = 0, count - 1 do
      if !inv_overhaul_inventory_items.InventoryItemsIsEquipped(category, index) then
        local candidate: object
        local candidateID: int
        local candidateAmount: int
        player->GetItem(candidate, index, category)
        candidate->GetItemID(candidateID)
        player->GetItemAmount(candidateAmount, index, category)
        if candidateID == itemID && candidateAmount < maxStackSize then return index end
      end
    end
    return -1
  end

  function ContainerTransferGetPlayerItemTotalAmount(
    player: object,
    category: int,
    wantedItemID: int) -> int
    if !player then return 0 end
    local count: int
    local total: int = 0
    player->GetItemCount(count, category)
    for index = 0, count - 1 do
      local candidate: object
      player->GetItem(candidate, index, category)
      if candidate then
        local candidateID: int
        candidate->GetItemID(candidateID)
        if candidateID == wantedItemID then
          local candidateAmount: int
          player->GetItemAmount(candidateAmount, index, category)
          total = total + candidateAmount
        end
      end
    end
    return total
  end

  function ContainerTransferGetExternalItemTotalAmount(
    external: object,
    wantedItemID: int) -> int
    if !external then return 0 end
    local count: int
    external->GetItemCount(count)
    local total: int = 0
    for index = 0, count - 1 do
      local candidate: object
      external->GetItem(candidate, index)
      if candidate then
        local candidateID: int
        candidate->GetItemID(candidateID)
        if candidateID == wantedItemID then
          local candidateAmount: int
          external->GetItemAmount(candidateAmount, index)
          total = total + candidateAmount
        end
      end
    end
    return total
  end

  function ContainerTransferSwapAppendedEntry(
    external: object,
    exchangedItem: object,
    exchangedAmount: int,
    exchangedIndex: int,
    expectedAppendedItemID: int,
    countBefore: int) -> int
    if !external || !exchangedItem then return -1 end
    local countAfter: int
    external->GetItemCount(countAfter)
    if countAfter != countBefore + 1 then return -1 end
    local appendedIndex: int = countAfter - 1
    local appendedItem: object
    local appendedAmount: int
    local appendedItemID: int = -1
    external->GetItem(appendedItem, appendedIndex)
    external->GetItemAmount(appendedAmount, appendedIndex)
    if appendedItem then appendedItem->GetItemID(appendedItemID) end
    if !appendedItem || appendedItemID != expectedAppendedItemID then return -1 end
    external->SetItem(appendedItem, appendedAmount, exchangedIndex, 0)
    external->SetItem(exchangedItem, exchangedAmount, appendedIndex, 0)
    return appendedIndex
  end
end
