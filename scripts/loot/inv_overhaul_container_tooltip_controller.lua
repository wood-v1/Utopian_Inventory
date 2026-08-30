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

  function LootTooltipClear() -> void
    inv_overhaul_inventory_tooltip.InterfaceTooltipClear()
  end

  function ShowPlayerPaging() -> void
    inv_overhaul_inventory_tooltip.ShowText(
      inv_overhaul_container_protocol.ContainerTargetPaging, 1404)
  end

  function ShowQuickslotHelp() -> void
    inv_overhaul_inventory_tooltip.ShowText(
      inv_overhaul_container_protocol.ContainerTargetQuickslotHelp, 1407)
  end

  function LootTooltipIsInsidePlayerPaging(
    maxPlayerPage: int,
    windowWidth: int,
    x: int,
    y: int) -> bool
    return inv_overhaul_container_geometry.IsInsidePageControl(
      maxPlayerPage, x, y,
      inv_overhaul_container_geometry.GetPlayerPageControlX(windowWidth),
      inv_overhaul_container_geometry.GetPlayerPageControlY(windowWidth))
  end

  function ResolvePlayerItem(
    playerPage: int,
    visibleSlots: int,
    target: int) -> object
    local item: object = null
    local linear: int = playerPage * visibleSlots + target
    local cell: int =
      inv_overhaul_inventory_layout.LayoutGetCellForLinearSlot(
        linear, visibleSlots, InventoryCapacity)
    local ordinal: int =
      inv_overhaul_inventory_layout_runtime.LayoutRuntimeGetOrderValue(cell)
    local reference: int =
      inv_overhaul_inventory_items.ResolveCachedOrdinal(ordinal)
    if reference < 0 then return item end
    local category: int =
      inv_overhaul_inventory_items.DecodeReferenceCategory(reference)
    local index: int =
      inv_overhaul_inventory_items.DecodeReferenceIndex(reference)
    local player: object =
      inv_overhaul_inventory_items.ItemsGetPlayerContainer()
    player->GetItem(item, index, category)
    return item
  end

  function ResolveExternalItem(
    target: int,
    containerPage: int,
    showOrgans: bool) -> object
    local item: object = null
    local reference: int = -1
    if inv_overhaul_container_protocol.IsContainerTarget(target) then
      local slot: int =
        inv_overhaul_container_protocol.GetContainerSlot(target)
      local visual: int = containerPage * ContainerSlots + slot
      local ordinal: int =
        inv_overhaul_container_projection.GetContainerOrder(visual)
      reference =
        inv_overhaul_container_projection.ResolveNormalOrdinal(ordinal)
    else
      if showOrgans &&
        inv_overhaul_container_protocol.IsOrganTarget(target) then
        local external: object
        native.GetContainer(external)
        reference =
          inv_overhaul_container_projection.ResolveOrganVisual(
            external,
            inv_overhaul_container_protocol.GetOrganSlot(target))
      end
    end
    if reference < 0 then return item end
    local external: object
    native.GetContainer(external)
    local index: int =
      inv_overhaul_container_projection.GetReferenceIndex(reference)
    external->GetItem(item, index)
    return item
  end

  function Update(
    windowWidth: int,
    visibleSlots: int,
    playerPage: int,
    containerPage: int,
    showOrgans: bool,
    maxPlayerPage: int,
    x: int,
    y: int) -> void
    if inv_overhaul_inventory_tooltip.IsSuspended() ||
      inv_overhaul_container_drag.LootDragIsActive() then
      LootTooltipClear()
      return
    end
    if inv_overhaul_container_geometry.LootGeometryIsInsideQuickslotHelp(
      windowWidth, x, y) then
      ShowQuickslotHelp()
      return
    end
    if LootTooltipIsInsidePlayerPaging(
      maxPlayerPage, windowWidth, x, y) then
      ShowPlayerPaging()
      return
    end
    if inv_overhaul_container_geometry.LootGeometryIsInsideMoney(
      windowWidth, x, y) then
      inv_overhaul_inventory_tooltip.ShowMoneyForTarget(
        inv_overhaul_container_protocol.ContainerTargetMoney)
      return
    end

    local target: int =
      inv_overhaul_container_protocol.LootProtocolFindTargetAt(
        windowWidth, visibleSlots, showOrgans, x, y)
    local item: object = null
    if inv_overhaul_container_protocol.IsPlayerTarget(
      target, visibleSlots) then
      item = ResolvePlayerItem(playerPage, visibleSlots, target)
    else
      item = ResolveExternalItem(target, containerPage, showOrgans)
    end
    if !item then
      LootTooltipClear()
      return
    end
    inv_overhaul_inventory_tooltip.ShowItem(target, item)
  end
end
