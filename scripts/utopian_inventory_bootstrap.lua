maintask UtopianInventoryBootstrap do
  function init() -> void
    local player: object
    native.self(player)
    -- The first effect on a freshly created player can be dispatched while the
    -- inventory subcontainers are still being rebuilt (especially after
    -- loading a save and then starting a new game).  Defer persistent effects
    -- until the actor has completed a few world ticks.
    local warmup: float = 0.25
    while warmup > 0 do
      local delta: float
      native.sync(delta)
      warmup = warmup - delta
    end
    local branch: int = -1
    native.GetVariable("branch", branch)
    native.Trace("UTOPIAN_PLAYER_BRANCH " + branch)
    player->ApplyEffect("utopian_inventory_guard.bin")
    player->ApplyEffect("utopian_quickslots.bin")
    native.Trace("UTOPIAN_INVENTORY_BOOTSTRAP_VERSION 2026.08.01-session-safe-3")
  end
end
