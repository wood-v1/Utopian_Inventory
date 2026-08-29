import "inv_overhaul_inventory_layout_runtime"
import "inv_overhaul_container_feedback"
import "inv_overhaul_container_presenter"
import "inv_overhaul_container_transfer"
import "inv_overhaul_inventory_items"

module inv_overhaul_container_player_actions do
  local const WeaponCategory: int = 0

  function ContainerPlayerActionsSwapCells(
    sourceCell: int,
    targetCell: int) -> void
    if !inv_overhaul_inventory_layout_runtime.InventoryLayoutRuntimeSwapCells(
      sourceCell, targetCell) then return end
    inv_overhaul_inventory_layout_runtime.InventoryLayoutRuntimeQueueSave()
    local visibleSlots: int =
      inv_overhaul_container_presenter.ContainerPresenterGetVisibleSlots()
    for visibleSlot = 0, visibleSlots - 1 do
      local visibleCell: int =
        inv_overhaul_container_presenter.ContainerPresenterGetVisibleCell(
          visibleSlot)
      if visibleCell == sourceCell || visibleCell == targetCell then
        inv_overhaul_container_presenter.ContainerPresenterUpdatePlayerSlot(
          visibleSlot)
      end
    end
  end

  function ContainerPlayerActionsDropToWorld(
    sourceSlot: int,
    requestedAmount: int) -> void
    local reference: int =
      inv_overhaul_container_presenter.ContainerPresenterResolveVisibleSlot(
        sourceSlot)
    if reference < 0 then return end
    local player: object =
      inv_overhaul_inventory_items.InventoryItemsGetPlayerContainer()
    local category: int =
      inv_overhaul_inventory_items.InventoryItemsDecodeReferenceCategory(reference)
    local index: int =
      inv_overhaul_inventory_items.InventoryItemsDecodeReferenceIndex(reference)
    local beforeBackpack: int =
      inv_overhaul_inventory_items.InventoryItemsGetBackpackCount()
    local usedOrder: int =
      inv_overhaul_inventory_items.InventoryItemsGetBackpackOrdinal(category, index)
    local item: object
    player->GetItem(item, index, category)
    if !item then return end
    local availableAmount: int
    player->GetItemAmount(availableAmount, index, category)
    local amount: int =
      inv_overhaul_container_transfer.ContainerTransferNormalizeAmount(
        requestedAmount, availableAmount)
    if amount <= 0 then return end
    if category == WeaponCategory then
      local selected: bool
      player->IsItemSelected(selected, index, category)
      if selected then native.SetPlayerHandsItem(-1) end
    end
    player->DropItems(item, amount)
    player->RemoveItem(index, amount, category)
    local afterBackpack: int =
      inv_overhaul_inventory_items.InventoryItemsGetBackpackCount()
    if afterBackpack < beforeBackpack then
      inv_overhaul_inventory_layout_runtime.InventoryLayoutRuntimeRemoveOrdinalExact(
        usedOrder, beforeBackpack)
    end
    inv_overhaul_container_presenter.ContainerPresenterUpdateAllSlots()
  end

  function ContainerPlayerActionsMoveSlotToOtherPage(sourceSlot: int) -> void
    local maxPage: int =
      inv_overhaul_container_presenter.ContainerPresenterGetMaxPlayerPage()
    if maxPage <= 0 then return end
    local playerPage: int =
      inv_overhaul_container_presenter.ContainerPresenterGetPlayerPage()
    local targetPage: int = playerPage + 1
    if targetPage > maxPage then targetPage = 0 end
    local backpackCount: int =
      inv_overhaul_inventory_items.InventoryItemsGetBackpackCount()
    local visibleSlots: int =
      inv_overhaul_container_presenter.ContainerPresenterGetVisibleSlots()
    local targetCell: int = -1
    for targetSlot = 0, visibleSlots - 1 do
      local linear: int = targetPage * visibleSlots + targetSlot
      local cell: int =
        inv_overhaul_container_presenter.ContainerPresenterGetCellForLinearSlot(
          linear)
      if cell >= 0 then
        local order: int =
          inv_overhaul_inventory_layout_runtime.InventoryLayoutRuntimeGetOrderValue(
            cell)
        if order >= backpackCount then
          targetCell = cell
          targetSlot = visibleSlots
        end
      end
    end
    if targetCell < 0 then
      inv_overhaul_container_feedback.ContainerFeedbackShowInventoryFull()
      return
    end
    local sourceCell: int =
      inv_overhaul_container_presenter.ContainerPresenterGetVisibleCell(sourceSlot)
    ContainerPlayerActionsSwapCells(sourceCell, targetCell)
    native.Trace("inv_overhaul_container ctrl-page-move sourcePage=" + playerPage +
      " targetPage=" + targetPage)
  end
end
