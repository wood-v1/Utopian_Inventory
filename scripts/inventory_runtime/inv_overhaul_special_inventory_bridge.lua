module inv_overhaul_special_inventory_bridge do
  function SpecialInventoryBridgeReset() -> void
    native.SetVariable("inv_overhaul_special_inventory_remap_request", 0)
  end

  function SpecialInventoryBridgeProcess() -> void
    local request: int = 0
    native.GetVariable("inv_overhaul_special_inventory_remap_request", request)
    if request != 1 then return end
    native.SetVariable("inv_overhaul_special_inventory_remap_request", 0)

    local mask: int = 0
    native.GetVariable("inv_overhaul_special_inventory_remap_mask", mask)
    local generation: int = 0
    native.GetVariable("inv_overhaul_inventory_reorder_generation", generation)
    native.SetVariable("inv_overhaul_inventory_reorder_generation", generation + 1)
    native.Trace("inv_overhaul_inventory_guard special reorder published mask=" + mask +
      " generation=" + (generation + 1))
  end
end
