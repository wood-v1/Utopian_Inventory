import "inv_overhaul_container_drag"
import "inv_overhaul_container_drag_controller"
import "inv_overhaul_container_geometry"
import "inv_overhaul_container_presenter"
import "inv_overhaul_container_projection"
import "inv_overhaul_container_view"

module inv_overhaul_container_paging_controller do
  local const ContainerSlots: int = 12

  function ContainerPagingHandleControlAt(x: int, y: int) -> bool
    local windowWidth: int =
      inv_overhaul_container_presenter.ContainerPresenterGetWindowWidth()
    local playerPage: int =
      inv_overhaul_container_presenter.ContainerPresenterGetPlayerPage()
    local playerMaxPage: int =
      inv_overhaul_container_presenter.ContainerPresenterGetMaxPlayerPage()
    if playerMaxPage > 0 then
      local playerAction: int =
        inv_overhaul_container_geometry.ContainerGeometryGetPageControlAction(
          x, y,
          inv_overhaul_container_geometry.ContainerGeometryGetPlayerPageControlX(
            windowWidth),
          inv_overhaul_container_geometry.ContainerGeometryGetPlayerPageControlY(
            windowWidth))
      if playerAction != 0 then
        if playerAction < 0 && playerPage > 0 then
          inv_overhaul_container_presenter.ContainerPresenterChangePlayerPage(-1)
        end
        if playerAction > 0 && playerPage < playerMaxPage then
          inv_overhaul_container_presenter.ContainerPresenterChangePlayerPage(1)
        end
        return true
      end
    end

    local containerMaxPage: int =
      inv_overhaul_container_projection.ContainerProjectionGetMaxPage()
    if containerMaxPage > 0 then
      local containerAction: int =
        inv_overhaul_container_geometry.ContainerGeometryGetPageControlAction(
          x, y,
          inv_overhaul_container_geometry.ContainerGeometryGetContainerPageControlX(
            windowWidth),
          inv_overhaul_container_geometry.ContainerGeometryGetContainerPageControlY(
            windowWidth, ContainerSlots))
      if containerAction != 0 then
        local containerPage: int =
          inv_overhaul_container_presenter.ContainerPresenterGetContainerPage()
        if containerAction < 0 && containerPage > 0 then
          inv_overhaul_container_presenter.ContainerPresenterChangeContainerPage(-1)
        end
        if containerAction > 0 && containerPage < containerMaxPage then
          inv_overhaul_container_presenter.ContainerPresenterChangeContainerPage(1)
        end
        return true
      end
    end
    return false
  end

  function ContainerPagingUpdateControlHover(x: int, y: int) -> void
    local windowWidth: int =
      inv_overhaul_container_presenter.ContainerPresenterGetWindowWidth()
    local playerX: int =
      inv_overhaul_container_geometry.ContainerGeometryGetPlayerPageControlX(
        windowWidth)
    local playerY: int =
      inv_overhaul_container_geometry.ContainerGeometryGetPlayerPageControlY(
        windowWidth)
    local playerPage: int =
      inv_overhaul_container_presenter.ContainerPresenterGetPlayerPage()
    local playerMaxPage: int =
      inv_overhaul_container_presenter.ContainerPresenterGetMaxPlayerPage()
    inv_overhaul_container_view.ContainerViewSetPageButtonHover(
      "player_page_prev",
      inv_overhaul_container_geometry.ContainerGeometryIsPageButtonHovered(
        -1, playerPage, playerMaxPage, x, y, playerX, playerY))
    inv_overhaul_container_view.ContainerViewSetPageButtonHover(
      "player_page_next",
      inv_overhaul_container_geometry.ContainerGeometryIsPageButtonHovered(
        1, playerPage, playerMaxPage, x, y, playerX, playerY))

    local containerX: int =
      inv_overhaul_container_geometry.ContainerGeometryGetContainerPageControlX(
        windowWidth)
    local containerY: int =
      inv_overhaul_container_geometry.ContainerGeometryGetContainerPageControlY(
        windowWidth, ContainerSlots)
    local containerPage: int =
      inv_overhaul_container_presenter.ContainerPresenterGetContainerPage()
    local containerMaxPage: int =
      inv_overhaul_container_projection.ContainerProjectionGetMaxPage()
    inv_overhaul_container_view.ContainerViewSetPageButtonHover(
      "container_page_prev",
      inv_overhaul_container_geometry.ContainerGeometryIsPageButtonHovered(
        -1, containerPage, containerMaxPage, x, y, containerX, containerY))
    inv_overhaul_container_view.ContainerViewSetPageButtonHover(
      "container_page_next",
      inv_overhaul_container_geometry.ContainerGeometryIsPageButtonHovered(
        1, containerPage, containerMaxPage, x, y, containerX, containerY))
  end

  function ContainerPagingGetDragHoverAction(sender: string) -> int
    local playerPage: int =
      inv_overhaul_container_presenter.ContainerPresenterGetPlayerPage()
    local containerPage: int =
      inv_overhaul_container_presenter.ContainerPresenterGetContainerPage()
    if sender == "player_page_prev" && playerPage > 0 then return -1 end
    if sender == "player_page_next" && playerPage <
      inv_overhaul_container_presenter.ContainerPresenterGetMaxPlayerPage() then
      return 1
    end
    if sender == "container_page_prev" && containerPage > 0 then return -2 end
    if sender == "container_page_next" && containerPage <
      inv_overhaul_container_projection.ContainerProjectionGetMaxPage() then
      return 2
    end
    return 0
  end

  function ContainerPagingBeginDragHover(sender: string) -> void
    if !inv_overhaul_container_drag.ContainerDragIsActive() then return end
    local action: int = ContainerPagingGetDragHoverAction(sender)
    if !inv_overhaul_container_drag.ContainerDragBeginPageHover(action) then return end
    local source: int = inv_overhaul_container_drag.ContainerDragGetSource()
    native.Trace("inv_overhaul_container page-hover begin sender=" + sender +
      " action=" + action + " source=" + source)
  end

  function ContainerPagingUpdateDragHover(delta: float) -> void
    if !inv_overhaul_container_drag.ContainerDragIsActive() then return end
    local action: int =
      inv_overhaul_container_drag.ContainerDragGetPageHoverAction()
    if action == 0 then return end
    local playerPage: int =
      inv_overhaul_container_presenter.ContainerPresenterGetPlayerPage()
    local containerPage: int =
      inv_overhaul_container_presenter.ContainerPresenterGetContainerPage()
    if action == -1 && playerPage <= 0 then
      inv_overhaul_container_drag_controller.ContainerDragControllerCancelPageHover(
        action)
      return
    end
    if action == 1 && playerPage >=
      inv_overhaul_container_presenter.ContainerPresenterGetMaxPlayerPage() then
      inv_overhaul_container_drag_controller.ContainerDragControllerCancelPageHover(
        action)
      return
    end
    if action == -2 && containerPage <= 0 then
      inv_overhaul_container_drag_controller.ContainerDragControllerCancelPageHover(
        action)
      return
    end
    if action == 2 && containerPage >=
      inv_overhaul_container_projection.ContainerProjectionGetMaxPage() then
      inv_overhaul_container_drag_controller.ContainerDragControllerCancelPageHover(
        action)
      return
    end
    action = inv_overhaul_container_drag.ContainerDragAdvancePageHover(delta)
    if action == 0 then return end
    inv_overhaul_container_drag_controller.ContainerDragControllerSetHighlightedTarget(
      -1)
    native.Trace("inv_overhaul_container page-hover switch action=" + action +
      " player_page=" + playerPage + " container_page=" + containerPage)
    if action == -1 then
      inv_overhaul_container_presenter.ContainerPresenterChangePlayerPage(-1)
    end
    if action == 1 then
      inv_overhaul_container_presenter.ContainerPresenterChangePlayerPage(1)
    end
    if action == -2 then
      inv_overhaul_container_presenter.ContainerPresenterChangeContainerPage(-1)
    end
    if action == 2 then
      inv_overhaul_container_presenter.ContainerPresenterChangeContainerPage(1)
    end
  end

  function ContainerPagingSyncDragHoverFromCursor() -> void
    if !inv_overhaul_container_drag.ContainerDragIsActive() then
      inv_overhaul_container_drag_controller.ContainerDragControllerCancelPageHover(0)
      return
    end
    local hoverTarget: int = 0
    local action: int = 0
    native.GetVariable("inv_overhaul_inventory_page_hover", hoverTarget)
    local playerPage: int =
      inv_overhaul_container_presenter.ContainerPresenterGetPlayerPage()
    local containerPage: int =
      inv_overhaul_container_presenter.ContainerPresenterGetContainerPage()
    if (hoverTarget == 1 || hoverTarget == 3) && playerPage > 0 then
      action = -1
    end
    if (hoverTarget == 2 || hoverTarget == 4) && playerPage <
      inv_overhaul_container_presenter.ContainerPresenterGetMaxPlayerPage() then
      action = 1
    end
    if hoverTarget == 5 && containerPage > 0 then action = -2 end
    if hoverTarget == 6 && containerPage <
      inv_overhaul_container_projection.ContainerProjectionGetMaxPage() then
      action = 2
    end
    if action == 0 then
      inv_overhaul_container_drag_controller.ContainerDragControllerCancelPageHover(0)
      return
    end
    if !inv_overhaul_container_drag.ContainerDragBeginPageHover(action) then return end
    native.Trace("inv_overhaul_container page-hover cursor target=" + hoverTarget +
      " action=" + action + " player_page=" + playerPage +
      " container_page=" + containerPage)
  end
end
