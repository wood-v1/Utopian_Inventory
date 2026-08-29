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

  function ContainerExternalTransferInitializeState() -> void
    moneyItemID =
      inv_overhaul_inventory_tooltip.InventoryTooltipGetMoneyItemID()
  end

  function ContainerExternalTransferGetAppendedBackpackOrdinal(
    category: int,
    beforeCount: int) -> int
    if beforeCount < 0 || beforeCount > InventoryCapacity then return -1 end
    return inv_overhaul_inventory_items.InventoryItemsGetAppendedCategoryOrdinal(
      category, beforeCount)
  end

  function ContainerExternalTransferInsertPlayerCache(
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
      inv_overhaul_inventory_items.InventoryItemsBuildIndexCache()
      return false
    end
    inv_overhaul_inventory_items.InventoryItemsInsertCachedEntry(
      insertedOrdinal, beforeCount, category, index)
    return true
  end

  function ContainerExternalTransferMoveAmountToPlayer(
    organSource: bool,
    sourceSlot: int,
    targetSlot: int,
    requestedAmount: int,
    restorePageIfMerged: int) -> void
    local sourceIndex: int = -1
    local sourceOrdinal: int = -1
    if inv_overhaul_container_drag.ContainerDragGetKind() >= 1 &&
      inv_overhaul_container_drag.ContainerDragGetContainerIndex() >= 0 then
      sourceIndex = inv_overhaul_container_drag.ContainerDragGetContainerIndex()
      sourceOrdinal = inv_overhaul_container_drag.ContainerDragGetContainerOrdinal()
    else
      local reference: int
      if organSource then
        reference =
          inv_overhaul_container_presenter.ContainerPresenterResolveOrganVisualSlot(
            sourceSlot)
      else
        reference =
          inv_overhaul_container_presenter.ContainerPresenterResolveContainerVisualSlot(
            sourceSlot)
      end
      if reference < 0 then return end
      sourceIndex =
        inv_overhaul_container_projection.ContainerProjectionGetReferenceIndex(reference)
      sourceOrdinal =
        inv_overhaul_container_projection.ContainerProjectionGetReferenceOrdinal(reference)
    end
    ContainerExternalTransferMoveResolvedAmountToPlayer(
      organSource, sourceIndex, sourceOrdinal, sourceSlot, targetSlot,
      requestedAmount, restorePageIfMerged)
  end

  function ContainerExternalTransferMoveResolvedAmountToPlayer(
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
      inv_overhaul_inventory_items.InventoryItemsGetPlayerContainer()
    local beforeNormal: int =
      inv_overhaul_container_presenter.ContainerPresenterGetNormalContainerItemCount()
    local beforeBackpack: int =
      inv_overhaul_inventory_items.InventoryItemsGetCachedBackpackCount()
    if beforeBackpack < 0 then
      inv_overhaul_inventory_items.InventoryItemsBuildIndexCache()
      beforeBackpack =
        inv_overhaul_inventory_items.InventoryItemsGetCachedBackpackCount()
    end
    local item: object
    local amount: int
    external->GetItem(item, sourceIndex)
    external->GetItemAmount(amount, sourceIndex)
    if !item || amount <= 0 then return end
    local transferAmount: int =
      inv_overhaul_container_transfer.ContainerTransferNormalizeAmount(
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
        inv_overhaul_container_projection.ContainerProjectionRemoveContainerOrdinal(
          sourceOrdinal, beforeNormal)
      end
      native.Trace("inv_overhaul_container took money amount=" + amount)
      if organSource then
        inv_overhaul_container_presenter.ContainerPresenterUpdateOrganSlots()
      else
        inv_overhaul_container_presenter.ContainerPresenterRefreshVisibleContainerItem(
          itemID, sourceSlot)
      end
      inv_overhaul_container_presenter.ContainerPresenterUpdateMoney()
      return
    end

    local category: int
    native.GetInvItemProperty(category, itemID, "Category")
    local mergeIndex: int =
      inv_overhaul_container_transfer.ContainerTransferFindPlayerMergeIndex(
        player, category, itemID)
    if beforeBackpack >= InventoryCapacity && mergeIndex < 0 then
      inv_overhaul_container_feedback.ContainerFeedbackShowInventoryFull()
      native.Trace("inv_overhaul_container container-to-player refused: inventory full")
      return
    end
    local outcome: object =
      inv_overhaul_container_transfer.ContainerTransferMoveExternalItemAmountToPlayer(
        player, external, item, organSource, sourceIndex, amount,
        transferAmount, category, itemID)
    if inv_overhaul_container_transfer.ContainerTransferExternalToPlayerWasRejected(
      outcome) then
      inv_overhaul_container_feedback.ContainerFeedbackShowInventoryFull()
      local success: bool =
        inv_overhaul_container_transfer.ContainerTransferGetExternalToPlayerSuccess(
          outcome)
      local beforePlayerAmount: int =
        inv_overhaul_container_transfer.ContainerTransferGetExternalToPlayerBeforeAmount(
          outcome)
      local afterPlayerAmount: int =
        inv_overhaul_container_transfer.ContainerTransferGetExternalToPlayerAfterAmount(
          outcome)
      native.Trace("inv_overhaul_container container-to-player rejected source=" +
        sourceSlot + " success=" + success + " before_amount=" +
        beforePlayerAmount + " after_amount=" + afterPlayerAmount)
      if organSource then
        inv_overhaul_container_presenter.ContainerPresenterUpdateOrganSlots()
      else
        inv_overhaul_container_presenter.ContainerPresenterRefreshVisibleContainerItem(
          itemID, sourceSlot)
      end
      return
    end

    if inv_overhaul_container_transfer.ContainerTransferExternalToPlayerSourceDepleted(
      outcome) then
      if !organSource then
        inv_overhaul_container_projection.ContainerProjectionRemoveContainerOrdinal(
          sourceOrdinal, beforeNormal)
      end
    end

    local afterCategoryCount: int
    player->GetItemCount(afterCategoryCount, category)
    local afterBackpack: int =
      inv_overhaul_inventory_items.InventoryItemsGetBackpackCount()
    if restorePageIfMerged >= 0 && afterBackpack == beforeBackpack then
      inv_overhaul_container_presenter.ContainerPresenterSetPlayerPage(
        restorePageIfMerged)
    end
    local insertedIntoPlayerCache: bool = false
    if afterBackpack > beforeBackpack then
      local insertedIndex: int = afterCategoryCount - 1
      local insertedOrder: int =
        ContainerExternalTransferGetAppendedBackpackOrdinal(category, beforeBackpack)
      insertedIntoPlayerCache = ContainerExternalTransferInsertPlayerCache(
        insertedOrder, beforeBackpack, category, insertedIndex)
      if insertedIntoPlayerCache then
        local page: int =
          inv_overhaul_container_presenter.ContainerPresenterGetPlayerPage()
        local visibleSlots: int =
          inv_overhaul_container_presenter.ContainerPresenterGetVisibleSlots()
        inv_overhaul_inventory_layout_runtime.InventoryLayoutRuntimeInsertOrdinalExactAtVisibleSlot(
          insertedOrder, beforeBackpack, page, visibleSlots, targetSlot)
      end
      mergeIndex = insertedIndex
    end
    if organSource then native.PlaySound("take_organ") end
    local renderedPage: int =
      inv_overhaul_container_presenter.ContainerPresenterGetRenderedPlayerPage()
    local currentPage: int =
      inv_overhaul_container_presenter.ContainerPresenterGetPlayerPage()
    if afterBackpack > beforeBackpack && insertedIntoPlayerCache &&
      renderedPage != currentPage then
      inv_overhaul_container_presenter.ContainerPresenterUpdatePlayerSlots()
    else
      if afterBackpack > beforeBackpack && insertedIntoPlayerCache then
        inv_overhaul_container_presenter.ContainerPresenterUpdatePlayerSlot(targetSlot)
        inv_overhaul_container_presenter.ContainerPresenterUpdatePlayerPageControls()
      else
        if afterBackpack > beforeBackpack then
          inv_overhaul_container_presenter.ContainerPresenterUpdatePlayerSlots()
        end
        inv_overhaul_container_presenter.ContainerPresenterQueueCachedPlayerEntryRefresh(
          category, mergeIndex)
      end
    end
    if organSource then
      inv_overhaul_container_presenter.ContainerPresenterUpdateOrganSlots()
    else
      inv_overhaul_container_presenter.ContainerPresenterRefreshVisibleContainerItem(
        itemID, sourceSlot)
    end
    inv_overhaul_container_presenter.ContainerPresenterUpdateMoney()
  end

  function ContainerExternalTransferMoveToPlayer(
    organSource: bool,
    sourceSlot: int,
    targetSlot: int,
    restorePageIfMerged: int) -> void
    ContainerExternalTransferMoveAmountToPlayer(
      organSource, sourceSlot, targetSlot, 1, restorePageIfMerged)
  end
end
