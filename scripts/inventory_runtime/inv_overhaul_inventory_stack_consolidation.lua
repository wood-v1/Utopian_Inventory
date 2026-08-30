import "inv_overhaul_inventory_overflow"

module inv_overhaul_inventory_stack_consolidation do
  local const InventoryStackCategoryCount: int = 5
  local const InventoryStackQuickslotCount: int = 10

  function StackItemVariable(slot: int) -> string
    return "inv_overhaul_quickslot_item_" + slot
  end

  function StackCategoryVariable(slot: int) -> string
    return "inv_overhaul_quickslot_category_" + slot
  end

  function StackOccurrenceVariable(slot: int) -> string
    return "inv_overhaul_quickslot_occurrence_" + slot
  end

  function StackDepletedVariable(slot: int) -> string
    return "inv_overhaul_quickslot_depleted_" + slot
  end

  function NormalizeQuickslots(category: int, itemID: int) -> void
    for slot = 1, InventoryStackQuickslotCount do
      local boundCategory: int = -1
      local boundItemID: int = -1
      native.GetVariable(StackCategoryVariable(slot), boundCategory)
      native.GetVariable(StackItemVariable(slot), boundItemID)
      if boundCategory == category && boundItemID == itemID then
        native.SetVariable(StackOccurrenceVariable(slot), 0)
        native.SetVariable(StackDepletedVariable(slot), 0)
      end
    end
  end

  function GetOtherAmount(
    player: object,
    category: int,
    keepIndex: int,
    itemID: int
  ) -> int
    local count: int
    local total: int = 0
    player->GetItemCount(count, category)
    for index = 0, count - 1 do
      if index != keepIndex then
        local candidate: object
        player->GetItem(candidate, index, category)
        if candidate then
          local candidateID: int
          candidate->GetItemID(candidateID)
          if candidateID == itemID then
            local amount: int
            player->GetItemAmount(amount, index, category)
            total = total + amount
          end
        end
      end
    end
    return total
  end

  function Merge(
    player: object,
    category: int,
    keepIndex: int,
    itemID: int,
    count: int
  ) -> bool
    local keepAmount: int
    local totalAmount: int
    local duplicateCount: int = 0
    player->GetItemAmount(keepAmount, keepIndex, category)
    totalAmount = keepAmount
    for index = keepIndex + 1, count - 1 do
      local candidate: object
      player->GetItem(candidate, index, category)
      if candidate then
        local candidateID: int
        candidate->GetItemID(candidateID)
        if candidateID == itemID then
          local amount: int
          player->GetItemAmount(amount, index, category)
          totalAmount = totalAmount + amount
          duplicateCount = duplicateCount + 1
        end
      end
    end
    if duplicateCount <= 0 then return false end

    player->SetItemAmount(totalAmount, keepIndex, category)
    local verifiedAmount: int
    player->GetItemAmount(verifiedAmount, keepIndex, category)
    if verifiedAmount != totalAmount then
      player->SetItemAmount(keepAmount, keepIndex, category)
      native.Trace("inv_overhaul_inventory_guard stack merge rejected category=" +
        category + " item=" + itemID + " requested=" + totalAmount +
        " actual=" + verifiedAmount)
      return false
    end

    local removeIndex: int = count - 1
    while removeIndex > keepIndex do
      local candidate: object
      player->GetItem(candidate, removeIndex, category)
      if candidate then
        local candidateID: int
        candidate->GetItemID(candidateID)
        if candidateID == itemID then
          local amount: int
          player->GetItemAmount(amount, removeIndex, category)
          if amount > 0 then player->RemoveItem(removeIndex, amount, category) end
        end
      end
      removeIndex = removeIndex - 1
    end

    local remainingOtherAmount: int = GetOtherAmount(
      player, category, keepIndex, itemID)
    if remainingOtherAmount > 0 then
      player->SetItemAmount(totalAmount - remainingOtherAmount, keepIndex, category)
    end
    NormalizeQuickslots(category, itemID)
    return true
  end

  function Consolidate(categoryCounts: object) -> bool
    local player: object =
      inv_overhaul_inventory_overflow.OverflowGetPlayer()
    local changed: bool = false
    for category = 0, InventoryStackCategoryCount - 1 do
      local count: int
      player->GetItemCount(count, category)
      local index: int = 0
      while index < count do
        local item: object
        player->GetItem(item, index, category)
        if item then
          local itemID: int
          local maxStackSize: int
          item->GetItemID(itemID)
          native.GetInvItemMaxStackSize(maxStackSize, itemID)
          if maxStackSize > 1 && Merge(
            player, category, index, itemID, count) then
            changed = true
            player->GetItemCount(count, category)
          end
        end
        index = index + 1
      end
      player->GetItemCount(count, category)
      categoryCounts->set(category, count)
    end
    if changed then
      inv_overhaul_inventory_overflow.AdvanceContentGeneration()
      local generation: int = 0
      native.GetVariable("inv_overhaul_inventory_reorder_generation", generation)
      native.SetVariable("inv_overhaul_inventory_reorder_generation", generation + 1)
    end
    return changed
  end
end
