import "inv_overhaul_inventory_layout_runtime"
import "inv_overhaul_container_feedback"
import "inv_overhaul_container_presenter"
import "inv_overhaul_container_projection"
import "inv_overhaul_container_protocol"
import "inv_overhaul_container_transfer_external"
import "inv_overhaul_container_transfer_player"
import "inv_overhaul_inventory_items"

module inv_overhaul_container_quick_transfer do
  local const InventoryCapacity: int = 56
  local const ContainerSlots: int = 12

  function Execute(source: int, wholeStack: bool) -> void
    local visibleSlots: int =
      inv_overhaul_container_presenter.LootPresenterGetVisibleSlots()
    if inv_overhaul_container_protocol.IsPlayerTarget(
      source, visibleSlots) then
      if inv_overhaul_container_presenter.LootPresenterResolveVisibleSlot(
        source) < 0 then return end
      local normalCount: int =
        inv_overhaul_container_presenter.GetNormalContainerItemCount()
      local visual: int =
        inv_overhaul_container_projection.FindFirstFreeContainerVisual(
          normalCount)
      if visual < 0 then
        inv_overhaul_container_feedback.ShowContainerFull()
        native.Trace("inv_overhaul_container quick player-to-container refused: no visual slot")
        return
      end
      local previousPage: int =
        inv_overhaul_container_presenter.GetContainerPage()
      local targetPage: int = visual / ContainerSlots
      inv_overhaul_container_presenter.SetContainerPage(targetPage)
      local targetSlot: int = visual - targetPage * ContainerSlots
      if wholeStack then
        inv_overhaul_container_transfer_player.MoveAmountToContainer(
          source, targetSlot, -1, previousPage)
      else
        inv_overhaul_container_transfer_player.MoveToContainer(
          source, targetSlot, previousPage)
      end
      return
    end

    local backpackCount: int =
      inv_overhaul_inventory_items.GetBackpackCount()
    local playerVisual: int =
      inv_overhaul_inventory_layout_runtime.FindFirstFreeCell(
        backpackCount, visibleSlots)
    if playerVisual < 0 then playerVisual = 0 end
    local playerLinear: int = playerVisual
    if visibleSlots < InventoryCapacity then
      playerLinear = playerVisual - 16
      if playerLinear < 0 then playerLinear = playerLinear + InventoryCapacity end
    end
    local previousPage: int =
      inv_overhaul_container_presenter.GetPlayerPage()
    local targetPage: int = playerLinear / visibleSlots
    inv_overhaul_container_presenter.SetPlayerPage(targetPage)
    local playerTarget: int = playerLinear - targetPage * visibleSlots
    if inv_overhaul_container_protocol.IsContainerTarget(source) then
      local containerSlot: int =
        inv_overhaul_container_protocol.GetContainerSlot(source)
      if wholeStack then
        inv_overhaul_container_transfer_external.MoveAmountToPlayer(
          false, containerSlot, playerTarget, -1, previousPage)
      else
        inv_overhaul_container_transfer_external.MoveToPlayer(
          false, containerSlot, playerTarget, previousPage)
      end
      return
    end
    if inv_overhaul_container_protocol.IsOrganTarget(source) then
      local organSlot: int =
        inv_overhaul_container_protocol.GetOrganSlot(source)
      if wholeStack then
        inv_overhaul_container_transfer_external.MoveAmountToPlayer(
          true, organSlot, playerTarget, -1, previousPage)
      else
        inv_overhaul_container_transfer_external.MoveToPlayer(
          true, organSlot, playerTarget, previousPage)
      end
    end
  end
end
