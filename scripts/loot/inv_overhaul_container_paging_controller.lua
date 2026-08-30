import "inv_overhaul_container_drag"
import "inv_overhaul_container_drag_controller"
import "inv_overhaul_container_geometry"
import "inv_overhaul_container_presenter"
import "inv_overhaul_container_projection"
import "inv_overhaul_container_view"

module inv_overhaul_container_paging_controller do
  local const ContainerSlots: int = 12

  function HandleControlAt(x: int, y: int) -> bool
    local windowWidth: int =
      inv_overhaul_container_presenter.GetWindowWidth()
    local playerPage: int =
      inv_overhaul_container_presenter.GetPlayerPage()
    local playerMaxPage: int =
      inv_overhaul_container_presenter.GetMaxPlayerPage()
    if playerMaxPage > 0 then
      local playerAction: int =
        inv_overhaul_container_geometry.GetPageControlAction(
          x, y,
          inv_overhaul_container_geometry.GetPlayerPageControlX(
            windowWidth),
          inv_overhaul_container_geometry.GetPlayerPageControlY(
            windowWidth))
      if playerAction != 0 then
        if playerAction < 0 && playerPage > 0 then
          inv_overhaul_container_presenter.ChangePlayerPage(-1)
        end
        if playerAction > 0 && playerPage < playerMaxPage then
          inv_overhaul_container_presenter.ChangePlayerPage(1)
        end
        return true
      end
    end

    local containerMaxPage: int =
      inv_overhaul_container_projection.LootProjectionGetMaxPage()
    if containerMaxPage > 0 then
      local containerAction: int =
        inv_overhaul_container_geometry.GetPageControlAction(
          x, y,
          inv_overhaul_container_geometry.GetContainerPageControlX(
            windowWidth),
          inv_overhaul_container_geometry.GetContainerPageControlY(
            windowWidth, ContainerSlots))
      if containerAction != 0 then
        local containerPage: int =
          inv_overhaul_container_presenter.GetContainerPage()
        if containerAction < 0 && containerPage > 0 then
          inv_overhaul_container_presenter.ChangeContainerPage(-1)
        end
        if containerAction > 0 && containerPage < containerMaxPage then
          inv_overhaul_container_presenter.ChangeContainerPage(1)
        end
        return true
      end
    end
    return false
  end

  function UpdateControlHover(x: int, y: int) -> void
    local windowWidth: int =
      inv_overhaul_container_presenter.GetWindowWidth()
    local playerX: int =
      inv_overhaul_container_geometry.GetPlayerPageControlX(
        windowWidth)
    local playerY: int =
      inv_overhaul_container_geometry.GetPlayerPageControlY(
        windowWidth)
    local playerPage: int =
      inv_overhaul_container_presenter.GetPlayerPage()
    local playerMaxPage: int =
      inv_overhaul_container_presenter.GetMaxPlayerPage()
    inv_overhaul_container_view.SetPageButtonHover(
      "player_page_prev",
      inv_overhaul_container_geometry.IsPageButtonHovered(
        -1, playerPage, playerMaxPage, x, y, playerX, playerY))
    inv_overhaul_container_view.SetPageButtonHover(
      "player_page_next",
      inv_overhaul_container_geometry.IsPageButtonHovered(
        1, playerPage, playerMaxPage, x, y, playerX, playerY))

    local containerX: int =
      inv_overhaul_container_geometry.GetContainerPageControlX(
        windowWidth)
    local containerY: int =
      inv_overhaul_container_geometry.GetContainerPageControlY(
        windowWidth, ContainerSlots)
    local containerPage: int =
      inv_overhaul_container_presenter.GetContainerPage()
    local containerMaxPage: int =
      inv_overhaul_container_projection.LootProjectionGetMaxPage()
    inv_overhaul_container_view.SetPageButtonHover(
      "container_page_prev",
      inv_overhaul_container_geometry.IsPageButtonHovered(
        -1, containerPage, containerMaxPage, x, y, containerX, containerY))
    inv_overhaul_container_view.SetPageButtonHover(
      "container_page_next",
      inv_overhaul_container_geometry.IsPageButtonHovered(
        1, containerPage, containerMaxPage, x, y, containerX, containerY))
  end

  function GetDragHoverAction(sender: string) -> int
    local playerPage: int =
      inv_overhaul_container_presenter.GetPlayerPage()
    local containerPage: int =
      inv_overhaul_container_presenter.GetContainerPage()
    if sender == "player_page_prev" && playerPage > 0 then return -1 end
    if sender == "player_page_next" && playerPage <
      inv_overhaul_container_presenter.GetMaxPlayerPage() then
      return 1
    end
    if sender == "container_page_prev" && containerPage > 0 then return -2 end
    if sender == "container_page_next" && containerPage <
      inv_overhaul_container_projection.LootProjectionGetMaxPage() then
      return 2
    end
    return 0
  end

  function BeginDragHover(sender: string) -> void
    if !inv_overhaul_container_drag.LootDragIsActive() then return end
    local action: int = GetDragHoverAction(sender)
    if !inv_overhaul_container_drag.LootDragBeginPageHover(action) then return end
    local source: int = inv_overhaul_container_drag.GetSource()
    native.Trace("inv_overhaul_container page-hover begin sender=" + sender +
      " action=" + action + " source=" + source)
  end

  function UpdateDragHover(delta: float) -> void
    if !inv_overhaul_container_drag.LootDragIsActive() then return end
    local action: int =
      inv_overhaul_container_drag.LootDragGetPageHoverAction()
    if action == 0 then return end
    local playerPage: int =
      inv_overhaul_container_presenter.GetPlayerPage()
    local containerPage: int =
      inv_overhaul_container_presenter.GetContainerPage()
    if action == -1 && playerPage <= 0 then
      inv_overhaul_container_drag_controller.CancelPageHover(
        action)
      return
    end
    if action == 1 && playerPage >=
      inv_overhaul_container_presenter.GetMaxPlayerPage() then
      inv_overhaul_container_drag_controller.CancelPageHover(
        action)
      return
    end
    if action == -2 && containerPage <= 0 then
      inv_overhaul_container_drag_controller.CancelPageHover(
        action)
      return
    end
    if action == 2 && containerPage >=
      inv_overhaul_container_projection.LootProjectionGetMaxPage() then
      inv_overhaul_container_drag_controller.CancelPageHover(
        action)
      return
    end
    action = inv_overhaul_container_drag.LootDragAdvancePageHover(delta)
    if action == 0 then return end
    inv_overhaul_container_drag_controller.LootDragControllerSetHighlightedTarget(
      -1)
    native.Trace("inv_overhaul_container page-hover switch action=" + action +
      " player_page=" + playerPage + " container_page=" + containerPage)
    if action == -1 then
      inv_overhaul_container_presenter.ChangePlayerPage(-1)
    end
    if action == 1 then
      inv_overhaul_container_presenter.ChangePlayerPage(1)
    end
    if action == -2 then
      inv_overhaul_container_presenter.ChangeContainerPage(-1)
    end
    if action == 2 then
      inv_overhaul_container_presenter.ChangeContainerPage(1)
    end
  end

  function SyncDragHoverFromCursor() -> void
    if !inv_overhaul_container_drag.LootDragIsActive() then
      inv_overhaul_container_drag_controller.CancelPageHover(0)
      return
    end
    local hoverTarget: int = 0
    local action: int = 0
    native.GetVariable("inv_overhaul_inventory_page_hover", hoverTarget)
    local playerPage: int =
      inv_overhaul_container_presenter.GetPlayerPage()
    local containerPage: int =
      inv_overhaul_container_presenter.GetContainerPage()
    if (hoverTarget == 1 || hoverTarget == 3) && playerPage > 0 then
      action = -1
    end
    if (hoverTarget == 2 || hoverTarget == 4) && playerPage <
      inv_overhaul_container_presenter.GetMaxPlayerPage() then
      action = 1
    end
    if hoverTarget == 5 && containerPage > 0 then action = -2 end
    if hoverTarget == 6 && containerPage <
      inv_overhaul_container_projection.LootProjectionGetMaxPage() then
      action = 2
    end
    if action == 0 then
      inv_overhaul_container_drag_controller.CancelPageHover(0)
      return
    end
    if !inv_overhaul_container_drag.LootDragBeginPageHover(action) then return end
    native.Trace("inv_overhaul_container page-hover cursor target=" + hoverTarget +
      " action=" + action + " player_page=" + playerPage +
      " container_page=" + containerPage)
  end
end
