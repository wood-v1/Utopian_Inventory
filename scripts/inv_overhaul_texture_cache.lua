maintask InvOverhaulTextureCache do
  function init() -> void
    -- Compatibility tombstone for saves created while the experimental
    -- persistent preloader was enabled. Returning from init terminates the old
    -- effect instead of keeping its per-frame inventory scan alive.
    native.SetVariable("inv_overhaul_texture_cache_loaded", 0)
    native.SetVariable("inv_overhaul_texture_cache_disabled", 1)
    native.Trace("INV_OVERHAUL_TEXTURE_CACHE_DISABLED 2026.08.10")
  end
end
