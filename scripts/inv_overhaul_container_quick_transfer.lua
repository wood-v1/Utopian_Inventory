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

  function ContainerQuickTransferExecute(source: int, wholeStack: bool) -> void
    local visibleSlots: int =
      inv_overhaul_container_presenter.ContainerPresenterGetVisibleSlots()
    if inv_overhaul_container_protocol.ContainerProtocolIsPlayerTarget(
      source, visibleSlots) then
      if inv_overhaul_container_presenter.ContainerPresenterResolveVisibleSlot(
        source) < 0 then return end
      local normalCount: int =
        inv_overhaul_container_presenter.ContainerPresenterGetNormalContainerItemCount()
      local visual: int =
        inv_overhaul_container_projection.ContainerProjectionFindFirstFreeContainerVisual(
          normalCount)
      if visual < 0 then
        inv_overhaul_container_feedback.ContainerFeedbackShowContainerFull()
        native.Trace("inv_overhaul_container quick player-to-container refused: no visual slot")
        return
      end
      local previousPage: int =
        inv_overhaul_container_presenter.ContainerPresenterGetContainerPage()
      local targetPage: int = visual / ContainerSlots
      inv_overhaul_container_presenter.ContainerPresenterSetContainerPage(targetPage)
      local targetSlot: int = visual - targetPage * ContainerSlots
      if wholeStack then
        inv_overhaul_container_transfer_player.ContainerPlayerTransferMoveAmountToContainer(
          source, targetSlot, -1, previousPage)
      else
        inv_overhaul_container_transfer_player.ContainerPlayerTransferMoveToContainer(
          source, targetSlot, previousPage)
      end
      return
    end

    local backpackCount: int =
      inv_overhaul_inventory_items.InventoryItemsGetBackpackCount()
    local playerVisual: int =
      inv_overhaul_inventory_layout_runtime.InventoryLayoutRuntimeFindFirstFreeCell(
        backpackCount, visibleSlots)
    if playerVisual < 0 then playerVisual = 0 end
    local playerLinear: int = playerVisual
    if visibleSlots < InventoryCapacity then
      playerLinear = playerVisual - 16
      if playerLinear < 0 then playerLinear = playerLinear + InventoryCapacity end
    end
    local previousPage: int =
      inv_overhaul_container_presenter.ContainerPresenterGetPlayerPage()
    local targetPage: int = playerLinear / visibleSlots
    inv_overhaul_container_presenter.ContainerPresenterSetPlayerPage(targetPage)
    local playerTarget: int = playerLinear - targetPage * visibleSlots
    if inv_overhaul_container_protocol.ContainerProtocolIsContainerTarget(source) then
      local containerSlot: int =
        inv_overhaul_container_protocol.ContainerProtocolGetContainerSlot(source)
      if wholeStack then
        inv_overhaul_container_transfer_external.ContainerExternalTransferMoveAmountToPlayer(
          false, containerSlot, playerTarget, -1, previousPage)
      else
        inv_overhaul_container_transfer_external.ContainerExternalTransferMoveToPlayer(
          false, containerSlot, playerTarget, previousPage)
      end
      return
    end
    if inv_overhaul_container_protocol.ContainerProtocolIsOrganTarget(source) then
      local organSlot: int =
        inv_overhaul_container_protocol.ContainerProtocolGetOrganSlot(source)
      if wholeStack then
        inv_overhaul_container_transfer_external.ContainerExternalTransferMoveAmountToPlayer(
          true, organSlot, playerTarget, -1, previousPage)
      else
        inv_overhaul_container_transfer_external.ContainerExternalTransferMoveToPlayer(
          true, organSlot, playerTarget, previousPage)
      end
    end
  end
end
