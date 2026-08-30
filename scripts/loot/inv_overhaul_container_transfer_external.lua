import "inv_overhaul_inventory_layout_runtime"
import "inv_overhaul_container_drag"
import "inv_overhaul_container_feedback"
import "inv_overhaul_container_presenter"
import "inv_overhaul_container_projection"
import "inv_overhaul_container_transfer"
import "inv_overhaul_inventory_tooltip"
import "inv_overhaul_inventory_items"

module inv_overhaul_container_transfer_external do
  local const InventoryCapacity: int = 56
  local const CategoryCount: int = 5

  local moneyItemID: int

  function ExternalTransferInitializeState() -> void
    moneyItemID =
      inv_overhaul_inventory_tooltip.GetMoneyItemID()
  end

  function GetAppendedBackpackOrdinal(
    category: int,
    beforeCount: int) -> int
    if beforeCount < 0 || beforeCount > InventoryCapacity then return -1 end
    return inv_overhaul_inventory_items.GetAppendedCategoryOrdinal(
      category, beforeCount)
  end

  function InsertPlayerCache(
    insertedOrdinal: int,
    beforeCount: int,
    category: int,
    index: int) -> bool
    if beforeCount < 0 || beforeCount >= InventoryCapacity ||
      insertedOrdinal < 0 || insertedOrdinal > beforeCount ||
      category < 0 || category >= CategoryCount || index < 0 then
      native.Trace("inv_overhaul_container cache insert rejected ordinal=" +
        insertedOrdinal + " before=" + beforeCount + " category=" + category +
        " index=" + index)
      inv_overhaul_inventory_items.ItemsBuildIndexCache()
      return false
    end
    inv_overhaul_inventory_items.InsertCachedEntry(
      insertedOrdinal, beforeCount, category, index)
    return true
  end

  function MoveAmountToPlayer(
    organSource: bool,
    sourceSlot: int,
    targetSlot: int,
    requestedAmount: int,
    restorePageIfMerged: int) -> void
    local sourceIndex: int = -1
    local sourceOrdinal: int = -1
    if inv_overhaul_container_drag.GetKind() >= 1 &&
      inv_overhaul_container_drag.GetContainerIndex() >= 0 then
      sourceIndex = inv_overhaul_container_drag.GetContainerIndex()
      sourceOrdinal = inv_overhaul_container_drag.GetContainerOrdinal()
    else
      local reference: int
      if organSource then
        reference =
          inv_overhaul_container_presenter.ResolveOrganVisualSlot(
            sourceSlot)
      else
        reference =
          inv_overhaul_container_presenter.ResolveContainerVisualSlot(
            sourceSlot)
      end
      if reference < 0 then return end
      sourceIndex =
        inv_overhaul_container_projection.GetReferenceIndex(reference)
      sourceOrdinal =
        inv_overhaul_container_projection.GetReferenceOrdinal(reference)
    end
    MoveResolvedAmountToPlayer(
      organSource, sourceIndex, sourceOrdinal, sourceSlot, targetSlot,
      requestedAmount, restorePageIfMerged)
  end

  function MoveResolvedAmountToPlayer(
    organSource: bool,
    sourceIndex: int,
    sourceOrdinal: int,
    sourceSlot: int,
    targetSlot: int,
    requestedAmount: int,
    restorePageIfMerged: int) -> void
    local external: object
    native.GetContainer(external)
    local player: object =
      inv_overhaul_inventory_items.ItemsGetPlayerContainer()
    local beforeNormal: int =
      inv_overhaul_container_presenter.GetNormalContainerItemCount()
    local beforeBackpack: int =
      inv_overhaul_inventory_items.GetCachedBackpackCount()
    if beforeBackpack < 0 then
      inv_overhaul_inventory_items.ItemsBuildIndexCache()
      beforeBackpack =
        inv_overhaul_inventory_items.GetCachedBackpackCount()
    end
    local item: object
    local amount: int
    external->GetItem(item, sourceIndex)
    external->GetItemAmount(amount, sourceIndex)
    if !item || amount <= 0 then return end
    local transferAmount: int =
      inv_overhaul_container_transfer.NormalizeAmount(
        requestedAmount, amount)
    if transferAmount <= 0 then return end

    local itemID: int
    item->GetItemID(itemID)
    local knownMoneyItemID: int = moneyItemID
    if itemID == knownMoneyItemID then
      local money: int
      player->GetProperty("money", money)
      player->SetProperty("money", money + amount)
      external->RemoveItem(sourceIndex, amount)
      if !organSource then
        inv_overhaul_container_projection.RemoveContainerOrdinal(
          sourceOrdinal, beforeNormal)
      end
      native.Trace("inv_overhaul_container took money amount=" + amount)
      if organSource then
        inv_overhaul_container_presenter.UpdateOrganSlots()
      else
        inv_overhaul_container_presenter.RefreshVisibleContainerItem(
          itemID, sourceSlot)
      end
      inv_overhaul_container_presenter.LootPresenterUpdateMoney()
      return
    end

    local category: int
    native.GetInvItemProperty(category, itemID, "Category")
    local mergeIndex: int =
      inv_overhaul_container_transfer.FindPlayerMergeIndex(
        player, category, itemID)
    if beforeBackpack >= InventoryCapacity && mergeIndex < 0 then
      inv_overhaul_container_feedback.LootFeedbackShowInventoryFull()
      native.Trace("inv_overhaul_container container-to-player refused: inventory full")
      return
    end
    local outcome: object =
      inv_overhaul_container_transfer.MoveExternalItemAmountToPlayer(
        player, external, item, organSource, sourceIndex, amount,
        transferAmount, category, itemID)
    if inv_overhaul_container_transfer.ExternalToPlayerWasRejected(
      outcome) then
      inv_overhaul_container_feedback.LootFeedbackShowInventoryFull()
      local success: bool =
        inv_overhaul_container_transfer.GetExternalToPlayerSuccess(
          outcome)
      local beforePlayerAmount: int =
        inv_overhaul_container_transfer.GetExternalToPlayerBeforeAmount(
          outcome)
      local afterPlayerAmount: int =
        inv_overhaul_container_transfer.GetExternalToPlayerAfterAmount(
          outcome)
      native.Trace("inv_overhaul_container container-to-player rejected source=" +
        sourceSlot + " success=" + success + " before_amount=" +
        beforePlayerAmount + " after_amount=" + afterPlayerAmount)
      if organSource then
        inv_overhaul_container_presenter.UpdateOrganSlots()
      else
        inv_overhaul_container_presenter.RefreshVisibleContainerItem(
          itemID, sourceSlot)
      end
      return
    end

    if inv_overhaul_container_transfer.ExternalToPlayerSourceDepleted(
      outcome) then
      if !organSource then
        inv_overhaul_container_projection.RemoveContainerOrdinal(
          sourceOrdinal, beforeNormal)
      end
    end

    local afterCategoryCount: int
    player->GetItemCount(afterCategoryCount, category)
    local afterBackpack: int =
      inv_overhaul_inventory_items.GetBackpackCount()
    if restorePageIfMerged >= 0 && afterBackpack == beforeBackpack then
      inv_overhaul_container_presenter.SetPlayerPage(
        restorePageIfMerged)
    end
    local insertedIntoPlayerCache: bool = false
    if afterBackpack > beforeBackpack then
      local insertedIndex: int = afterCategoryCount - 1
      local insertedOrder: int =
        GetAppendedBackpackOrdinal(category, beforeBackpack)
      insertedIntoPlayerCache = InsertPlayerCache(
        insertedOrder, beforeBackpack, category, insertedIndex)
      if insertedIntoPlayerCache then
        local page: int =
          inv_overhaul_container_presenter.GetPlayerPage()
        local visibleSlots: int =
          inv_overhaul_container_presenter.LootPresenterGetVisibleSlots()
        inv_overhaul_inventory_layout_runtime.InsertOrdinalExactAtVisibleSlot(
          insertedOrder, beforeBackpack, page, visibleSlots, targetSlot)
      end
      mergeIndex = insertedIndex
    end
    if organSource then native.PlaySound("take_organ") end
    local renderedPage: int =
      inv_overhaul_container_presenter.GetRenderedPlayerPage()
    local currentPage: int =
      inv_overhaul_container_presenter.GetPlayerPage()
    if afterBackpack > beforeBackpack && insertedIntoPlayerCache &&
      renderedPage != currentPage then
      inv_overhaul_container_presenter.UpdatePlayerSlots()
    else
      if afterBackpack > beforeBackpack && insertedIntoPlayerCache then
        inv_overhaul_container_presenter.UpdatePlayerSlot(targetSlot)
        inv_overhaul_container_presenter.UpdatePlayerPageControls()
      else
        if afterBackpack > beforeBackpack then
          inv_overhaul_container_presenter.UpdatePlayerSlots()
        end
        inv_overhaul_container_presenter.QueueCachedPlayerEntryRefresh(
          category, mergeIndex)
      end
    end
    if organSource then
      inv_overhaul_container_presenter.UpdateOrganSlots()
    else
      inv_overhaul_container_presenter.RefreshVisibleContainerItem(
        itemID, sourceSlot)
    end
    inv_overhaul_container_presenter.LootPresenterUpdateMoney()
  end

  function MoveToPlayer(
    organSource: bool,
    sourceSlot: int,
    targetSlot: int,
    restorePageIfMerged: int) -> void
    MoveAmountToPlayer(
      organSource, sourceSlot, targetSlot, 1, restorePageIfMerged)
  end
end
