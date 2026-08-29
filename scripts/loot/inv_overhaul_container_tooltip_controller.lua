import "inv_overhaul_inventory_layout"
import "inv_overhaul_inventory_layout_runtime"
import "inv_overhaul_container_geometry"
import "inv_overhaul_container_drag"
import "inv_overhaul_container_projection"
import "inv_overhaul_container_protocol"
import "inv_overhaul_inventory_tooltip"
import "inv_overhaul_inventory_items"

module inv_overhaul_container_tooltip_controller do
  local const InventoryCapacity: int = 56
  local const ContainerSlots: int = 12

  function ContainerTooltipClear() -> void
    inv_overhaul_inventory_tooltip.InventoryTooltipClear()
  end

  function ContainerTooltipShowPlayerPaging() -> void
    inv_overhaul_inventory_tooltip.InventoryTooltipShowText(
      inv_overhaul_container_protocol.ContainerTargetPaging, 1404)
  end

  function ContainerTooltipShowQuickslotHelp() -> void
    inv_overhaul_inventory_tooltip.InventoryTooltipShowText(
      inv_overhaul_container_protocol.ContainerTargetQuickslotHelp, 1407)
  end

  function ContainerTooltipIsInsidePlayerPaging(
    maxPlayerPage: int,
    windowWidth: int,
    x: int,
    y: int) -> bool
    return inv_overhaul_container_geometry.ContainerGeometryIsInsidePageControl(
      maxPlayerPage, x, y,
      inv_overhaul_container_geometry.ContainerGeometryGetPlayerPageControlX(windowWidth),
      inv_overhaul_container_geometry.ContainerGeometryGetPlayerPageControlY(windowWidth))
  end

  function ContainerTooltipResolvePlayerItem(
    playerPage: int,
    visibleSlots: int,
    target: int) -> object
    local item: object = null
    local linear: int = playerPage * visibleSlots + target
    local cell: int =
      inv_overhaul_inventory_layout.InventoryLayoutGetCellForLinearSlot(
        linear, visibleSlots, InventoryCapacity)
    local ordinal: int =
      inv_overhaul_inventory_layout_runtime.InventoryLayoutRuntimeGetOrderValue(cell)
    local reference: int =
      inv_overhaul_inventory_items.InventoryItemsResolveCachedOrdinal(ordinal)
    if reference < 0 then return item end
    local category: int =
      inv_overhaul_inventory_items.InventoryItemsDecodeReferenceCategory(reference)
    local index: int =
      inv_overhaul_inventory_items.InventoryItemsDecodeReferenceIndex(reference)
    local player: object =
      inv_overhaul_inventory_items.InventoryItemsGetPlayerContainer()
    player->GetItem(item, index, category)
    return item
  end

  function ContainerTooltipResolveExternalItem(
    target: int,
    containerPage: int,
    showOrgans: bool) -> object
    local item: object = null
    local reference: int = -1
    if inv_overhaul_container_protocol.ContainerProtocolIsContainerTarget(target) then
      local slot: int =
        inv_overhaul_container_protocol.ContainerProtocolGetContainerSlot(target)
      local visual: int = containerPage * ContainerSlots + slot
      local ordinal: int =
        inv_overhaul_container_projection.ContainerProjectionGetContainerOrder(visual)
      reference =
        inv_overhaul_container_projection.ContainerProjectionResolveNormalOrdinal(ordinal)
    else
      if showOrgans &&
        inv_overhaul_container_protocol.ContainerProtocolIsOrganTarget(target) then
        local external: object
        native.GetContainer(external)
        reference =
          inv_overhaul_container_projection.ContainerProjectionResolveOrganVisual(
            external,
            inv_overhaul_container_protocol.ContainerProtocolGetOrganSlot(target))
      end
    end
    if reference < 0 then return item end
    local external: object
    native.GetContainer(external)
    local index: int =
      inv_overhaul_container_projection.ContainerProjectionGetReferenceIndex(reference)
    external->GetItem(item, index)
    return item
  end

  function ContainerTooltipUpdate(
    windowWidth: int,
    visibleSlots: int,
    playerPage: int,
    containerPage: int,
    showOrgans: bool,
    maxPlayerPage: int,
    x: int,
    y: int) -> void
    if inv_overhaul_inventory_tooltip.InventoryTooltipIsSuspended() ||
      inv_overhaul_container_drag.ContainerDragIsActive() then
      ContainerTooltipClear()
      return
    end
    if inv_overhaul_container_geometry.ContainerGeometryIsInsideQuickslotHelp(
      windowWidth, x, y) then
      ContainerTooltipShowQuickslotHelp()
      return
    end
    if ContainerTooltipIsInsidePlayerPaging(
      maxPlayerPage, windowWidth, x, y) then
      ContainerTooltipShowPlayerPaging()
      return
    end
    if inv_overhaul_container_geometry.ContainerGeometryIsInsideMoney(
      windowWidth, x, y) then
      inv_overhaul_inventory_tooltip.InventoryTooltipShowMoneyForTarget(
        inv_overhaul_container_protocol.ContainerTargetMoney)
      return
    end

    local target: int =
      inv_overhaul_container_protocol.ContainerProtocolFindTargetAt(
        windowWidth, visibleSlots, showOrgans, x, y)
    local item: object = null
    if inv_overhaul_container_protocol.ContainerProtocolIsPlayerTarget(
      target, visibleSlots) then
      item = ContainerTooltipResolvePlayerItem(playerPage, visibleSlots, target)
    else
      item = ContainerTooltipResolveExternalItem(target, containerPage, showOrgans)
    end
    if !item then
      ContainerTooltipClear()
      return
    end
    inv_overhaul_inventory_tooltip.InventoryTooltipShowItem(target, item)
  end
end
