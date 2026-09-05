import "inv_overhaul_inventory_layout_runtime"
import "inv_overhaul_container_feedback"
import "inv_overhaul_container_presenter"
import "inv_overhaul_container_transfer"
import "inv_overhaul_inventory_items"
import "inv_overhaul_inventory_sounds"

module inv_overhaul_container_player_actions do
  local const WeaponCategory: int = 0

  function LootPlayerActionsSwapCells(
    sourceCell: int,
    targetCell: int) -> void
    if !inv_overhaul_inventory_layout_runtime.LayoutRuntimeSwapCells(
      sourceCell, targetCell) then return end
    inv_overhaul_inventory_sounds.InventorySoundsPlayItemEquip()
    inv_overhaul_inventory_layout_runtime.QueueSave()
    local visibleSlots: int =
      inv_overhaul_container_presenter.LootPresenterGetVisibleSlots()
    for visibleSlot = 0, visibleSlots - 1 do
      local visibleCell: int =
        inv_overhaul_container_presenter.LootPresenterGetVisibleCell(
          visibleSlot)
      if visibleCell == sourceCell || visibleCell == targetCell then
        inv_overhaul_container_presenter.UpdatePlayerSlot(
          visibleSlot)
      end
    end
  end

  function DropToWorld(
    sourceSlot: int,
    requestedAmount: int) -> void
    local reference: int =
      inv_overhaul_container_presenter.LootPresenterResolveVisibleSlot(
        sourceSlot)
    if reference < 0 then return end
    local player: object =
      inv_overhaul_inventory_items.ItemsGetPlayerContainer()
    local category: int =
      inv_overhaul_inventory_items.DecodeReferenceCategory(reference)
    local index: int =
      inv_overhaul_inventory_items.DecodeReferenceIndex(reference)
    local beforeBackpack: int =
      inv_overhaul_inventory_items.GetBackpackCount()
    local usedOrder: int =
      inv_overhaul_inventory_items.ItemsGetBackpackOrdinal(category, index)
    local item: object
    player->GetItem(item, index, category)
    if !item then return end
    local availableAmount: int
    player->GetItemAmount(availableAmount, index, category)
    local amount: int =
      inv_overhaul_container_transfer.NormalizeAmount(
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
      inv_overhaul_inventory_items.GetBackpackCount()
    if afterBackpack < beforeBackpack then
      inv_overhaul_inventory_layout_runtime.RemoveOrdinalExact(
        usedOrder, beforeBackpack)
    end
    inv_overhaul_container_presenter.UpdateAllSlots()
  end

  function LootPlayerActionsMoveSlotToOtherPage(sourceSlot: int) -> void
    local maxPage: int =
      inv_overhaul_container_presenter.GetMaxPlayerPage()
    if maxPage <= 0 then return end
    local playerPage: int =
      inv_overhaul_container_presenter.GetPlayerPage()
    local targetPage: int = playerPage + 1
    if targetPage > maxPage then targetPage = 0 end
    local backpackCount: int =
      inv_overhaul_inventory_items.GetBackpackCount()
    local visibleSlots: int =
      inv_overhaul_container_presenter.LootPresenterGetVisibleSlots()
    local targetCell: int = -1
    for targetSlot = 0, visibleSlots - 1 do
      local linear: int = targetPage * visibleSlots + targetSlot
      local cell: int =
        inv_overhaul_container_presenter.LootPresenterGetCellForLinearSlot(
          linear)
      if cell >= 0 then
        local order: int =
          inv_overhaul_inventory_layout_runtime.LayoutRuntimeGetOrderValue(
            cell)
        if order >= backpackCount then
          targetCell = cell
          targetSlot = visibleSlots
        end
      end
    end
    if targetCell < 0 then
      inv_overhaul_container_feedback.LootFeedbackShowInventoryFull()
      return
    end
    local sourceCell: int =
      inv_overhaul_container_presenter.LootPresenterGetVisibleCell(sourceSlot)
    LootPlayerActionsSwapCells(sourceCell, targetCell)
    native.Trace("inv_overhaul_container ctrl-page-move sourcePage=" + playerPage +
      " targetPage=" + targetPage)
  end
end
