import "inv_overhaul_inventory_layout_runtime"
import "inv_overhaul_container_drag"
import "inv_overhaul_container_feedback"
import "inv_overhaul_container_presenter"
import "inv_overhaul_container_projection"
import "inv_overhaul_container_transfer"
import "inv_overhaul_container_transfer_external"
import "inv_overhaul_inventory_items"

module inv_overhaul_container_transfer_player do
  local const WeaponCategory: int = 0
  local const CategoryCount: int = 5
  local const InventoryCapacity: int = 56
  local const ContainerSlots: int = 12
  local const MaxContainerVisuals: int = 128

  function ContainerPlayerTransferRemovePlayerCache(
    removedOrdinal: int,
    beforeCount: int,
    removedCategory: int,
    removedIndex: int) -> bool
    if beforeCount <= 0 || beforeCount > InventoryCapacity ||
      removedOrdinal < 0 || removedOrdinal >= beforeCount ||
      removedCategory < 0 || removedCategory >= CategoryCount || removedIndex < 0 then
      native.Trace("inv_overhaul_container cache remove rejected ordinal=" +
        removedOrdinal + " before=" + beforeCount + " category=" +
        removedCategory + " index=" + removedIndex)
      inv_overhaul_inventory_items.InventoryItemsBuildIndexCache()
      return false
    end
    inv_overhaul_inventory_items.InventoryItemsRemoveCachedEntry(
      removedOrdinal, beforeCount, removedCategory, removedIndex)
    return true
  end

  function ContainerPlayerTransferMoveAmountToContainer(
    sourceSlot: int,
    targetSlot: int,
    requestedAmount: int,
    restorePageIfMerged: int) -> void
    local category: int = -1
    local index: int = -1
    if inv_overhaul_container_drag.ContainerDragGetKind() == 0 &&
      inv_overhaul_container_drag.ContainerDragGetPlayerCategory() >= 0 &&
      inv_overhaul_container_drag.ContainerDragGetPlayerIndex() >= 0 then
      category = inv_overhaul_container_drag.ContainerDragGetPlayerCategory()
      index = inv_overhaul_container_drag.ContainerDragGetPlayerIndex()
    else
      local reference: int =
        inv_overhaul_container_presenter.ContainerPresenterResolveVisibleSlot(
          sourceSlot)
      if reference < 0 then return end
      category =
        inv_overhaul_inventory_items.InventoryItemsDecodeReferenceCategory(reference)
      index =
        inv_overhaul_inventory_items.InventoryItemsDecodeReferenceIndex(reference)
    end
    local player: object =
      inv_overhaul_inventory_items.InventoryItemsGetPlayerContainer()
    local external: object
    native.GetContainer(external)
    if !external then return end

    local beforeBackpack: int =
      inv_overhaul_inventory_items.InventoryItemsGetCachedBackpackCount()
    if beforeBackpack < 0 then
      inv_overhaul_inventory_items.InventoryItemsBuildIndexCache()
      beforeBackpack =
        inv_overhaul_inventory_items.InventoryItemsGetCachedBackpackCount()
    end
    local sourceCell: int =
      inv_overhaul_container_presenter.ContainerPresenterGetVisibleCell(sourceSlot)
    if inv_overhaul_container_drag.ContainerDragGetKind() == 0 &&
      inv_overhaul_container_drag.ContainerDragGetPlayerCell() >= 0 then
      sourceCell = inv_overhaul_container_drag.ContainerDragGetPlayerCell()
    end
    local usedOrder: int =
      inv_overhaul_inventory_layout_runtime.InventoryLayoutRuntimeGetOrderValue(
        sourceCell)
    if usedOrder < 0 || usedOrder >= beforeBackpack then
      usedOrder =
        inv_overhaul_inventory_items.InventoryItemsGetBackpackOrdinal(category, index)
    end
    local beforeCategoryCount: int
    player->GetItemCount(beforeCategoryCount, category)
    local beforeExternal: int =
      inv_overhaul_container_presenter.ContainerPresenterGetNormalContainerItemCount()
    if beforeExternal >= MaxContainerVisuals then
      inv_overhaul_container_feedback.ContainerFeedbackShowContainerFull()
      return
    end
    local outcome: object =
      inv_overhaul_container_transfer.ContainerTransferMovePlayerAmountToExternal(
        player, external, category, index, requestedAmount)
    if !outcome then return end
    local itemID: int =
      inv_overhaul_container_transfer.ContainerTransferGetPlayerToExternalItemID(
        outcome)
    if inv_overhaul_container_transfer.ContainerTransferPlayerToExternalWasRejected(
      outcome) then
      inv_overhaul_container_feedback.ContainerFeedbackShowContainerFull()
      local success: bool =
        inv_overhaul_container_transfer.ContainerTransferGetPlayerToExternalSuccess(
          outcome)
      local beforeExternalAmount: int =
        inv_overhaul_container_transfer.ContainerTransferGetPlayerToExternalBeforeAmount(
          outcome)
      local afterExternalAmount: int =
        inv_overhaul_container_transfer.ContainerTransferGetPlayerToExternalAfterAmount(
          outcome)
      native.Trace("inv_overhaul_container player-to-container rejected slot=" +
        sourceSlot + " success=" + success + " before_amount=" +
        beforeExternalAmount + " after_amount=" + afterExternalAmount)
      inv_overhaul_container_presenter.ContainerPresenterRefreshVisibleContainerItem(
        itemID, targetSlot)
      return
    end

    local afterCategoryCount: int
    player->GetItemCount(afterCategoryCount, category)
    local afterBackpack: int =
      inv_overhaul_inventory_items.InventoryItemsGetBackpackCount()
    if afterBackpack < beforeBackpack then
      if ContainerPlayerTransferRemovePlayerCache(
        usedOrder, beforeBackpack, category, index) then
        inv_overhaul_inventory_layout_runtime.InventoryLayoutRuntimeRemoveOrdinalExact(
          usedOrder, beforeBackpack)
      end
    end
    local afterExternal: int =
      inv_overhaul_container_presenter.ContainerPresenterGetNormalContainerItemCount()
    if restorePageIfMerged >= 0 && afterExternal == beforeExternal then
      inv_overhaul_container_presenter.ContainerPresenterSetContainerPage(
        restorePageIfMerged)
    end
    if afterExternal > beforeExternal then
      local page: int =
        inv_overhaul_container_presenter.ContainerPresenterGetContainerPage()
      inv_overhaul_container_projection.ContainerProjectionInsertContainerOrdinalAt(
        page, beforeExternal, beforeExternal, targetSlot)
    end
    if beforeExternal <= ContainerSlots && afterExternal > ContainerSlots then
      native.Trace("inv_overhaul_container corpse/container page 2 activated count=" +
        afterExternal)
    end
    local visibleSourceSlot: int =
      inv_overhaul_container_presenter.ContainerPresenterGetVisibleSlotForCell(
        sourceCell)
    if visibleSourceSlot >= 0 then
      inv_overhaul_container_presenter.ContainerPresenterUpdatePlayerSlot(
        visibleSourceSlot)
      inv_overhaul_container_presenter.ContainerPresenterUpdatePlayerPageControls()
    end
    inv_overhaul_container_presenter.ContainerPresenterRefreshVisibleContainerItem(
      itemID, targetSlot)
    inv_overhaul_container_presenter.ContainerPresenterUpdateMoney()
  end

  function ContainerPlayerTransferMoveToContainer(
    sourceSlot: int,
    targetSlot: int,
    restorePageIfMerged: int) -> void
    ContainerPlayerTransferMoveAmountToContainer(
      sourceSlot, targetSlot, 1, restorePageIfMerged)
  end

  function ContainerPlayerTransferExchangeWithContainer(
    sourceSlot: int,
    targetSlot: int) -> void
    local exchangedReference: int =
      inv_overhaul_container_presenter.ContainerPresenterResolveContainerVisualSlot(
        targetSlot)
    if exchangedReference < 0 then
      ContainerPlayerTransferMoveToContainer(sourceSlot, targetSlot, -1)
      return
    end

    local exchangedContainerIndex: int =
      inv_overhaul_container_projection.ContainerProjectionGetReferenceIndex(
        exchangedReference)
    local exchangedContainerOrdinal: int =
      inv_overhaul_container_projection.ContainerProjectionGetReferenceOrdinal(
        exchangedReference)
    local external: object
    native.GetContainer(external)
    local exchangedItem: object
    local exchangedAmount: int
    local externalCountBefore: int
    external->GetItem(exchangedItem, exchangedContainerIndex)
    external->GetItemAmount(exchangedAmount, exchangedContainerIndex)
    external->GetItemCount(externalCountBefore)
    if !exchangedItem then return end

    local sourceCategory: int = -1
    local sourceIndex: int = -1
    if inv_overhaul_container_drag.ContainerDragGetPlayerCategory() >= 0 &&
      inv_overhaul_container_drag.ContainerDragGetPlayerIndex() >= 0 then
      sourceCategory = inv_overhaul_container_drag.ContainerDragGetPlayerCategory()
      sourceIndex = inv_overhaul_container_drag.ContainerDragGetPlayerIndex()
    else
      local sourceReference: int =
        inv_overhaul_container_presenter.ContainerPresenterResolveVisibleSlot(
          sourceSlot)
      if sourceReference < 0 then return end
      sourceCategory =
        inv_overhaul_inventory_items.InventoryItemsDecodeReferenceCategory(
          sourceReference)
      sourceIndex =
        inv_overhaul_inventory_items.InventoryItemsDecodeReferenceIndex(
          sourceReference)
    end
    local player: object =
      inv_overhaul_inventory_items.InventoryItemsGetPlayerContainer()
    local sourceItem: object
    local sourceAmount: int
    player->GetItem(sourceItem, sourceIndex, sourceCategory)
    player->GetItemAmount(sourceAmount, sourceIndex, sourceCategory)
    if !sourceItem || sourceAmount <= 0 then return end
    local sourceItemID: int
    sourceItem->GetItemID(sourceItemID)
    local beforeSourceAmount: int =
      inv_overhaul_container_transfer.ContainerTransferGetPlayerItemTotalAmount(
        player, sourceCategory, sourceItemID)

    local cachedCount: int =
      inv_overhaul_inventory_items.InventoryItemsGetCachedBackpackCount()
    if cachedCount < 0 then
      inv_overhaul_inventory_items.InventoryItemsBuildIndexCache()
      cachedCount =
        inv_overhaul_inventory_items.InventoryItemsGetCachedBackpackCount()
    end
    if cachedCount >= InventoryCapacity && sourceAmount > 1 then
      local exchangedItemID: int
      local exchangedCategory: int
      exchangedItem->GetItemID(exchangedItemID)
      native.GetInvItemProperty(exchangedCategory, exchangedItemID, "Category")
      local exchangedMergeIndex: int =
        inv_overhaul_container_transfer.ContainerTransferFindPlayerMergeIndex(
          player, exchangedCategory, exchangedItemID)
      if exchangedMergeIndex < 0 then
        inv_overhaul_container_feedback.ContainerFeedbackShowInventoryFull()
        return
      end
    end

    ContainerPlayerTransferMoveToContainer(sourceSlot, targetSlot, -1)
    local afterSourceAmount: int =
      inv_overhaul_container_transfer.ContainerTransferGetPlayerItemTotalAmount(
        player, sourceCategory, sourceItemID)
    if afterSourceAmount >= beforeSourceAmount then return end

    local exchangedMovedToIndex: int = exchangedContainerIndex
    local exchangedMovedToOrdinal: int = exchangedContainerOrdinal
    local appendedIndex: int =
      inv_overhaul_container_transfer.ContainerTransferSwapAppendedEntry(
        external, exchangedItem, exchangedAmount, exchangedContainerIndex,
        sourceItemID, externalCountBefore)
    if appendedIndex >= 0 then
      inv_overhaul_container_presenter.ContainerPresenterBuildContainerIndexCache()
      for visual = 0, MaxContainerVisuals - 1 do
        inv_overhaul_container_projection.ContainerProjectionSetContainerOrder(
          visual, visual)
      end
      exchangedMovedToIndex = appendedIndex
      exchangedMovedToOrdinal =
        inv_overhaul_container_projection.ContainerProjectionGetCachedNormalCount() - 1
    end

    inv_overhaul_container_transfer_external.ContainerExternalTransferMoveResolvedAmountToPlayer(
      false, exchangedMovedToIndex, exchangedMovedToOrdinal,
      targetSlot, sourceSlot, -1, -1)
    inv_overhaul_container_presenter.ContainerPresenterUpdateContainerSlots()
    native.Trace("inv_overhaul_container exchanged occupied container slot=" +
      targetSlot)
  end
end
