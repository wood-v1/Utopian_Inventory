import "inv_overhaul_inventory_controller"

maintask InventoryOverhaulUI do
  function init() -> void
    inv_overhaul_inventory_controller.PlayerControllerInitialize()
  end

  function OnUpdate(delta: float) -> void
    inv_overhaul_inventory_controller.RunFramePreparationStage(delta)
    inv_overhaul_inventory_controller.RunMetadataAndLoadingStage(delta)
    inv_overhaul_inventory_controller.RunPersistenceAndRefreshStage(delta)
    inv_overhaul_inventory_controller.RunDragHoverStage(delta)
  end

  function OnUIMessage(message: int, sender: string, data: object) -> void
    inv_overhaul_inventory_controller.OnUIMessage(message, sender, data)
  end

  function OnLButtonDown(x: int, y: int) -> void
    inv_overhaul_inventory_controller.OnLButtonDown(x, y)
  end

  function OnRButtonDown(x: int, y: int) -> void
    inv_overhaul_inventory_controller.OnRButtonDown(x, y)
  end

  function OnMouseMove(x: int, y: int) -> void
    inv_overhaul_inventory_controller.OnMouseMove(x, y)
  end

  function OnMouseLeave() -> void
    inv_overhaul_inventory_controller.OnMouseLeave()
  end

  function OnLButtonUp(x: int, y: int) -> void
    inv_overhaul_inventory_controller.OnLButtonUp(x, y)
  end

  function OnChar(char: int) -> void
    inv_overhaul_inventory_controller.OnChar(char)
  end

  function OnKeyDown(key: int) -> void
    inv_overhaul_inventory_controller.OnKeyDown(key)
  end

  function OnKeyUp(key: int) -> void
    inv_overhaul_inventory_controller.OnKeyUp(key)
  end
end
