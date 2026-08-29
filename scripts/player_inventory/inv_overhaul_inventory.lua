import "inv_overhaul_inventory_controller"

maintask InventoryOverhaulUI do
  function init() -> void
    inv_overhaul_inventory_controller.InventoryControllerInitialize()
  end

  function OnUpdate(delta: float) -> void
    inv_overhaul_inventory_controller.InventoryControllerRunFramePreparationStage(delta)
    inv_overhaul_inventory_controller.InventoryControllerRunMetadataAndLoadingStage(delta)
    inv_overhaul_inventory_controller.InventoryControllerRunPersistenceAndRefreshStage(delta)
    inv_overhaul_inventory_controller.InventoryControllerRunDragHoverStage(delta)
  end

  function OnUIMessage(message: int, sender: string, data: object) -> void
    inv_overhaul_inventory_controller.InventoryControllerOnUIMessage(message, sender, data)
  end

  function OnLButtonDown(x: int, y: int) -> void
    inv_overhaul_inventory_controller.InventoryControllerOnLButtonDown(x, y)
  end

  function OnRButtonDown(x: int, y: int) -> void
    inv_overhaul_inventory_controller.InventoryControllerOnRButtonDown(x, y)
  end

  function OnMouseMove(x: int, y: int) -> void
    inv_overhaul_inventory_controller.InventoryControllerOnMouseMove(x, y)
  end

  function OnMouseLeave() -> void
    inv_overhaul_inventory_controller.InventoryControllerOnMouseLeave()
  end

  function OnLButtonUp(x: int, y: int) -> void
    inv_overhaul_inventory_controller.InventoryControllerOnLButtonUp(x, y)
  end

  function OnChar(char: int) -> void
    inv_overhaul_inventory_controller.InventoryControllerOnChar(char)
  end

  function OnKeyDown(key: int) -> void
    inv_overhaul_inventory_controller.InventoryControllerOnKeyDown(key)
  end

  function OnKeyUp(key: int) -> void
    inv_overhaul_inventory_controller.InventoryControllerOnKeyUp(key)
  end
end
