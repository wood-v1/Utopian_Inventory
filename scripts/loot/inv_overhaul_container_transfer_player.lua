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

  function RemovePlayerCache(
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
      inv_overhaul_inventory_items.ItemsBuildIndexCache()
      return false
    end
    inv_overhaul_inventory_items.RemoveCachedEntry(
      removedOrdinal, beforeCount, removedCategory, removedIndex)
    return true
  end

  function MoveAmountToContainer(
    sourceSlot: int,
    targetSlot: int,
    requestedAmount: int,
    restorePageIfMerged: int) -> void
    local category: int = -1
    local index: int = -1
    if inv_overhaul_container_drag.GetKind() == 0 &&
      inv_overhaul_container_drag.GetPlayerCategory() >= 0 &&
      inv_overhaul_container_drag.GetPlayerIndex() >= 0 then
      category = inv_overhaul_container_drag.GetPlayerCategory()
      index = inv_overhaul_container_drag.GetPlayerIndex()
    else
      local reference: int =
        inv_overhaul_container_presenter.LootPresenterResolveVisibleSlot(
          sourceSlot)
      if reference < 0 then return end
      category =
        inv_overhaul_inventory_items.DecodeReferenceCategory(reference)
      index =
        inv_overhaul_inventory_items.DecodeReferenceIndex(reference)
    end
    local player: object =
      inv_overhaul_inventory_items.ItemsGetPlayerContainer()
    local external: object
    native.GetContainer(external)
    if !external then return end

    local beforeBackpack: int =
      inv_overhaul_inventory_items.GetCachedBackpackCount()
    if beforeBackpack < 0 then
      inv_overhaul_inventory_items.ItemsBuildIndexCache()
      beforeBackpack =
        inv_overhaul_inventory_items.GetCachedBackpackCount()
    end
    local sourceCell: int =
      inv_overhaul_container_presenter.LootPresenterGetVisibleCell(sourceSlot)
    if inv_overhaul_container_drag.GetKind() == 0 &&
      inv_overhaul_container_drag.GetPlayerCell() >= 0 then
      sourceCell = inv_overhaul_container_drag.GetPlayerCell()
    end
    local usedOrder: int =
      inv_overhaul_inventory_layout_runtime.LayoutRuntimeGetOrderValue(
        sourceCell)
    if usedOrder < 0 || usedOrder >= beforeBackpack then
      usedOrder =
        inv_overhaul_inventory_items.ItemsGetBackpackOrdinal(category, index)
    end
    local beforeCategoryCount: int
    player->GetItemCount(beforeCategoryCount, category)
    local beforeExternal: int =
      inv_overhaul_container_presenter.GetNormalContainerItemCount()
    if beforeExternal >= MaxContainerVisuals then
      inv_overhaul_container_feedback.ShowContainerFull()
      return
    end
    local outcome: object =
      inv_overhaul_container_transfer.MovePlayerAmountToExternal(
        player, external, category, index, requestedAmount)
    if !outcome then return end
    local itemID: int =
      inv_overhaul_container_transfer.GetPlayerToExternalItemID(
        outcome)
    if inv_overhaul_container_transfer.PlayerToExternalWasRejected(
      outcome) then
      inv_overhaul_container_feedback.ShowContainerFull()
      local success: bool =
        inv_overhaul_container_transfer.GetPlayerToExternalSuccess(
          outcome)
      local beforeExternalAmount: int =
        inv_overhaul_container_transfer.GetPlayerToExternalBeforeAmount(
          outcome)
      local afterExternalAmount: int =
        inv_overhaul_container_transfer.GetPlayerToExternalAfterAmount(
          outcome)
      native.Trace("inv_overhaul_container player-to-container rejected slot=" +
        sourceSlot + " success=" + success + " before_amount=" +
        beforeExternalAmount + " after_amount=" + afterExternalAmount)
      inv_overhaul_container_presenter.RefreshVisibleContainerItem(
        itemID, targetSlot)
      return
    end

    local afterCategoryCount: int
    player->GetItemCount(afterCategoryCount, category)
    local afterBackpack: int =
      inv_overhaul_inventory_items.GetBackpackCount()
    if afterBackpack < beforeBackpack then
      if RemovePlayerCache(
        usedOrder, beforeBackpack, category, index) then
        inv_overhaul_inventory_layout_runtime.RemoveOrdinalExact(
          usedOrder, beforeBackpack)
      end
    end
    local afterExternal: int =
      inv_overhaul_container_presenter.GetNormalContainerItemCount()
    if restorePageIfMerged >= 0 && afterExternal == beforeExternal then
      inv_overhaul_container_presenter.SetContainerPage(
        restorePageIfMerged)
    end
    if afterExternal > beforeExternal then
      local page: int =
        inv_overhaul_container_presenter.GetContainerPage()
      inv_overhaul_container_projection.InsertContainerOrdinalAt(
        page, beforeExternal, beforeExternal, targetSlot)
    end
    if beforeExternal <= ContainerSlots && afterExternal > ContainerSlots then
      native.Trace("inv_overhaul_container corpse/container page 2 activated count=" +
        afterExternal)
    end
    local visibleSourceSlot: int =
      inv_overhaul_container_presenter.GetVisibleSlotForCell(
        sourceCell)
    if visibleSourceSlot >= 0 then
      inv_overhaul_container_presenter.UpdatePlayerSlot(
        visibleSourceSlot)
      inv_overhaul_container_presenter.UpdatePlayerPageControls()
    end
    inv_overhaul_container_presenter.RefreshVisibleContainerItem(
      itemID, targetSlot)
    inv_overhaul_container_presenter.LootPresenterUpdateMoney()
  end

  function MoveToContainer(
    sourceSlot: int,
    targetSlot: int,
    restorePageIfMerged: int) -> void
    MoveAmountToContainer(
      sourceSlot, targetSlot, 1, restorePageIfMerged)
  end

  function ExchangeWithContainer(
    sourceSlot: int,
    targetSlot: int) -> void
    local exchangedReference: int =
      inv_overhaul_container_presenter.ResolveContainerVisualSlot(
        targetSlot)
    if exchangedReference < 0 then
      MoveToContainer(sourceSlot, targetSlot, -1)
      return
    end

    local exchangedContainerIndex: int =
      inv_overhaul_container_projection.GetReferenceIndex(
        exchangedReference)
    local exchangedContainerOrdinal: int =
      inv_overhaul_container_projection.GetReferenceOrdinal(
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
    if inv_overhaul_container_drag.GetPlayerCategory() >= 0 &&
      inv_overhaul_container_drag.GetPlayerIndex() >= 0 then
      sourceCategory = inv_overhaul_container_drag.GetPlayerCategory()
      sourceIndex = inv_overhaul_container_drag.GetPlayerIndex()
    else
      local sourceReference: int =
        inv_overhaul_container_presenter.LootPresenterResolveVisibleSlot(
          sourceSlot)
      if sourceReference < 0 then return end
      sourceCategory =
        inv_overhaul_inventory_items.DecodeReferenceCategory(
          sourceReference)
      sourceIndex =
        inv_overhaul_inventory_items.DecodeReferenceIndex(
          sourceReference)
    end
    local player: object =
      inv_overhaul_inventory_items.ItemsGetPlayerContainer()
    local sourceItem: object
    local sourceAmount: int
    player->GetItem(sourceItem, sourceIndex, sourceCategory)
    player->GetItemAmount(sourceAmount, sourceIndex, sourceCategory)
    if !sourceItem || sourceAmount <= 0 then return end
    local sourceItemID: int
    sourceItem->GetItemID(sourceItemID)
    local beforeSourceAmount: int =
      inv_overhaul_container_transfer.GetPlayerItemTotalAmount(
        player, sourceCategory, sourceItemID)

    local cachedCount: int =
      inv_overhaul_inventory_items.GetCachedBackpackCount()
    if cachedCount < 0 then
      inv_overhaul_inventory_items.ItemsBuildIndexCache()
      cachedCount =
        inv_overhaul_inventory_items.GetCachedBackpackCount()
    end
    if cachedCount >= InventoryCapacity && sourceAmount > 1 then
      local exchangedItemID: int
      local exchangedCategory: int
      exchangedItem->GetItemID(exchangedItemID)
      native.GetInvItemProperty(exchangedCategory, exchangedItemID, "Category")
      local exchangedMergeIndex: int =
        inv_overhaul_container_transfer.FindPlayerMergeIndex(
          player, exchangedCategory, exchangedItemID)
      if exchangedMergeIndex < 0 then
        inv_overhaul_container_feedback.LootFeedbackShowInventoryFull()
        return
      end
    end

    MoveToContainer(sourceSlot, targetSlot, -1)
    local afterSourceAmount: int =
      inv_overhaul_container_transfer.GetPlayerItemTotalAmount(
        player, sourceCategory, sourceItemID)
    if afterSourceAmount >= beforeSourceAmount then return end

    local exchangedMovedToIndex: int = exchangedContainerIndex
    local exchangedMovedToOrdinal: int = exchangedContainerOrdinal
    local appendedIndex: int =
      inv_overhaul_container_transfer.SwapAppendedEntry(
        external, exchangedItem, exchangedAmount, exchangedContainerIndex,
        sourceItemID, externalCountBefore)
    if appendedIndex >= 0 then
      inv_overhaul_container_presenter.BuildContainerIndexCache()
      for visual = 0, MaxContainerVisuals - 1 do
        inv_overhaul_container_projection.SetContainerOrder(
          visual, visual)
      end
      exchangedMovedToIndex = appendedIndex
      exchangedMovedToOrdinal =
        inv_overhaul_container_projection.GetCachedNormalCount() - 1
    end

    inv_overhaul_container_transfer_external.MoveResolvedAmountToPlayer(
      false, exchangedMovedToIndex, exchangedMovedToOrdinal,
      targetSlot, sourceSlot, -1, -1)
    inv_overhaul_container_presenter.UpdateContainerSlots()
    native.Trace("inv_overhaul_container exchanged occupied container slot=" +
      targetSlot)
  end
end
