maintask InventoryOverhaulBootstrap do
  function init() -> void
    local player: object
    native.self(player)
    -- OynonTools only creates this task after validating all five inventory
    -- categories. Yield one additional world tick so the guard and quickslot
    -- tasks are not constructed inside the native inventory callback itself.
    local warmup: float = 0.05
    while warmup > 0 do
      local delta: float
      native.sync(delta)
      warmup = warmup - delta
    end
    local branch: int = -1
    native.GetVariable("branch", branch)
    native.Trace("INV_OVERHAUL_PLAYER_BRANCH " + branch)
    local generation: int = 0
    native.GetVariable("inv_overhaul_effect_generation", generation)
    generation = generation + 1
    if generation <= 0 || generation > 1000000000 then generation = 1 end
    native.SetVariable("inv_overhaul_effect_generation", generation)
    native.Trace("INV_OVERHAUL_EFFECT_LIFECYCLE bootstrap generation=" +
      generation + " persistent_effects=enabled")
    player->ApplyEffect("inv_overhaul_inventory_guard.bin")
    player->ApplyEffect("inv_overhaul_quickslots.bin")
    native.Trace("INV_OVERHAUL_INVENTORY_BOOTSTRAP_VERSION 2026.08.11-persistent-effects-restored-1")
  end
end
