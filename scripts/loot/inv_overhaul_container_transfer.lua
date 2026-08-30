import "inv_overhaul_inventory_items"

module inv_overhaul_container_transfer do
  local const PlayerWeaponCategory: int = 0
  local const PlayerToExternalRejected: int = 1
  local const PlayerToExternalCompleted: int = 2
  local const ExternalToPlayerRejected: int = 1
  local const ExternalToPlayerCompleted: int = 2

  function NormalizeAmount(requestedAmount: int, availableAmount: int) -> int
    if requestedAmount <= 0 || requestedAmount > availableAmount then return availableAmount end
    return requestedAmount
  end

  function FindPlayerMergeIndex(
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
      if !inv_overhaul_inventory_items.IsEquipped(category, index) then
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

  function GetPlayerItemTotalAmount(
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

  function GetExternalItemTotalAmount(
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

  function CreatePlayerToExternalOutcome(
    status: int,
    itemID: int,
    success: bool,
    beforeExternalAmount: int,
    afterExternalAmount: int) -> object
    -- Local outcome layout: status, item ID, AddItem success, amount before,
    -- amount after. Keeping it function-local avoids mutable module scratch.
    local outcome: object
    local successValue: int = 0
    if success then successValue = 1 end
    native.CreateIntVector(outcome)
    outcome->add(status)
    outcome->add(itemID)
    outcome->add(successValue)
    outcome->add(beforeExternalAmount)
    outcome->add(afterExternalAmount)
    return outcome
  end

  function MovePlayerAmountToExternal(
    player: object,
    external: object,
    category: int,
    index: int,
    requestedAmount: int) -> object
    local item: object
    player->GetItem(item, index, category)
    if !item then return null end

    local availableAmount: int
    player->GetItemAmount(availableAmount, index, category)
    local transferAmount: int =
      NormalizeAmount(requestedAmount, availableAmount)
    if transferAmount <= 0 then return null end

    local itemID: int
    item->GetItemID(itemID)
    local beforeExternalAmount: int =
      GetExternalItemTotalAmount(external, itemID)
    local success: bool
    external->AddItem(success, item, 0, transferAmount)
    local afterExternalAmount: int =
      GetExternalItemTotalAmount(external, itemID)
    local addedAmount: int = afterExternalAmount - beforeExternalAmount
    if !success || addedAmount <= 0 then
      return CreatePlayerToExternalOutcome(
        PlayerToExternalRejected, itemID, success,
        beforeExternalAmount, afterExternalAmount)
    end

    if category == PlayerWeaponCategory then
      local selected: bool
      player->IsItemSelected(selected, index, category)
      if selected then native.SetPlayerHandsItem(-1) end
    end
    if addedAmount > transferAmount then addedAmount = transferAmount end
    player->RemoveItem(index, addedAmount, category)
    return CreatePlayerToExternalOutcome(
      PlayerToExternalCompleted, itemID, success,
      beforeExternalAmount, afterExternalAmount)
  end

  function PlayerToExternalWasRejected(outcome: object) -> bool
    if !outcome then return false end
    local status: int = 0
    outcome->get(status, 0)
    return status == PlayerToExternalRejected
  end

  function GetPlayerToExternalItemID(outcome: object) -> int
    local itemID: int = -1
    if outcome then outcome->get(itemID, 1) end
    return itemID
  end

  function GetPlayerToExternalSuccess(outcome: object) -> bool
    local success: int = 0
    if outcome then outcome->get(success, 2) end
    return success == 1
  end

  function GetPlayerToExternalBeforeAmount(outcome: object) -> int
    local amount: int = 0
    if outcome then outcome->get(amount, 3) end
    return amount
  end

  function GetPlayerToExternalAfterAmount(outcome: object) -> int
    local amount: int = 0
    if outcome then outcome->get(amount, 4) end
    return amount
  end

  function CreateExternalToPlayerOutcome(
    status: int,
    success: bool,
    beforePlayerAmount: int,
    afterPlayerAmount: int,
    sourceDepleted: bool) -> object
    -- Local outcome layout: status, AddItem success, amount before, amount
    -- after, source depleted. It carries rollback/result data without globals.
    local outcome: object
    local successValue: int = 0
    local depletedValue: int = 0
    if success then successValue = 1 end
    if sourceDepleted then depletedValue = 1 end
    native.CreateIntVector(outcome)
    outcome->add(status)
    outcome->add(successValue)
    outcome->add(beforePlayerAmount)
    outcome->add(afterPlayerAmount)
    outcome->add(depletedValue)
    return outcome
  end

  function MoveExternalItemAmountToPlayer(
    player: object,
    external: object,
    item: object,
    organSource: bool,
    sourceIndex: int,
    amount: int,
    transferAmount: int,
    category: int,
    itemID: int) -> object
    local beforePlayerAmount: int =
      GetPlayerItemTotalAmount(player, category, itemID)
    -- Preserve the pre-add category read even though the controller currently
    -- needs only the post-add count for layout insertion.
    local beforeCategoryCount: int
    player->GetItemCount(beforeCategoryCount, category)
    if organSource then
      item->SetProperty("InvOverhaulOrgan", 1)
      item->RemoveProperty("Organ")
    end

    local success: bool
    player->AddItem(success, item, category, transferAmount)
    local afterPlayerAmount: int =
      GetPlayerItemTotalAmount(player, category, itemID)
    local addedAmount: int = afterPlayerAmount - beforePlayerAmount
    if !success || addedAmount <= 0 then
      if organSource then
        item->RemoveProperty("InvOverhaulOrgan")
        item->SetProperty("Organ", 1)
      end
      return CreateExternalToPlayerOutcome(
        ExternalToPlayerRejected, success,
        beforePlayerAmount, afterPlayerAmount, false)
    end

    if addedAmount > transferAmount then addedAmount = transferAmount end
    external->RemoveItem(sourceIndex, addedAmount)
    return CreateExternalToPlayerOutcome(
      ExternalToPlayerCompleted, success,
      beforePlayerAmount, afterPlayerAmount, addedAmount >= amount)
  end

  function ExternalToPlayerWasRejected(outcome: object) -> bool
    if !outcome then return false end
    local status: int = 0
    outcome->get(status, 0)
    return status == ExternalToPlayerRejected
  end

  function GetExternalToPlayerSuccess(outcome: object) -> bool
    local success: int = 0
    if outcome then outcome->get(success, 1) end
    return success == 1
  end

  function GetExternalToPlayerBeforeAmount(outcome: object) -> int
    local amount: int = 0
    if outcome then outcome->get(amount, 2) end
    return amount
  end

  function GetExternalToPlayerAfterAmount(outcome: object) -> int
    local amount: int = 0
    if outcome then outcome->get(amount, 3) end
    return amount
  end

  function ExternalToPlayerSourceDepleted(outcome: object) -> bool
    local depleted: int = 0
    if outcome then outcome->get(depleted, 4) end
    return depleted == 1
  end

  function SwapAppendedEntry(
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
