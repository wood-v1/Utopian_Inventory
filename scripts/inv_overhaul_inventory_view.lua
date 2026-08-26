import "inv_overhaul_inventory_protocol"

module inv_overhaul_inventory_view do
  local const InventoryViewInitialItemLoadInterval: float = 0.00

  local diagnosticsEnabled: bool
  local firstItemReported: bool
  local completeReported: bool
  local stackCount: int
  local equipmentCount: int
  local cacheHits: int
  local cacheMisses: int
  local cacheEpoch: int
  local rendererReady: bool
  local warmGridLoaded: bool
  local warmStartAttempted: bool
  local childWindowsReady: bool
  local metadataPending: bool
  local metadataDelay: float
  local metadataStage: int
  local initialLoadActive: bool
  local nextSlot: int
  local nextEquipment: int
  local spriteCooldown: float

  function InventoryViewInitializeState() -> void
    local diagnostics: int = 0
    native.GetVariable("inv_overhaul_perf_diagnostics", diagnostics)
    diagnosticsEnabled = diagnostics == 1
    firstItemReported = false
    completeReported = false
    stackCount = 0
    equipmentCount = 0
    cacheHits = 0
    cacheMisses = 0
    cacheEpoch = 0
    rendererReady = false
    warmGridLoaded = false
    warmStartAttempted = false
    childWindowsReady = false
    metadataPending = true
    metadataDelay = 0
    metadataStage = 0
    initialLoadActive = false
    nextSlot = 0
    nextEquipment = 0
    spriteCooldown = 0
  end

  function InventoryViewDiagnosticsEnabled() -> bool return diagnosticsEnabled end

  function InventoryViewClaimChildWindowsReady() -> bool
    if childWindowsReady then return false end
    childWindowsReady = true
    return true
  end

  function InventoryViewChildWindowsReady() -> bool return childWindowsReady end

  function InventoryViewAdvanceMetadataDelay(delta: float) -> bool
    if !metadataPending then return false end
    metadataDelay = metadataDelay - delta
    return metadataDelay <= 0
  end

  function InventoryViewGetMetadataStage() -> int return metadataStage end
  function InventoryViewAdvanceMetadataStage() -> void metadataStage = metadataStage + 1 end

  function InventoryViewCompleteMetadata() -> void
    metadataPending = false
  end

  function InventoryViewIsMetadataPending() -> bool return metadataPending end

  function InventoryViewMarkRendererReady() -> void rendererReady = true end

  function InventoryViewBeginWarmStartAttempt() -> bool
    if warmStartAttempted || !rendererReady || !metadataPending then return false end
    warmStartAttempted = true
    return true
  end

  function InventoryViewMarkWarmGridLoaded() -> void
    warmGridLoaded = true
    metadataStage = 2
    metadataDelay = 0
  end

  function InventoryViewIsWarmGridLoaded() -> bool return warmGridLoaded end

  function InventoryViewBeginInitialLoad(visibleSlots: int) -> void
    if warmGridLoaded then nextSlot = visibleSlots else nextSlot = 0 end
    nextEquipment = 0
    spriteCooldown = 0
    initialLoadActive = true
  end

  function InventoryViewIsInitialLoadActive() -> bool return initialLoadActive end

  function InventoryViewTakeNextEquipment() -> int
    if nextEquipment >= 5 then return -1 end
    local result: int = nextEquipment
    nextEquipment = nextEquipment + 1
    return result
  end

  function InventoryViewTakeNextSlot(visibleSlots: int) -> int
    if nextSlot >= visibleSlots then return -1 end
    local result: int = nextSlot
    nextSlot = nextSlot + 1
    return result
  end

  function InventoryViewInitialLoadComplete(visibleSlots: int) -> bool
    return nextEquipment >= 5 && nextSlot >= visibleSlots
  end

  function InventoryViewFinishInitialLoad() -> void initialLoadActive = false end

  function InventoryViewAdvanceSpriteCooldown(delta: float) -> bool
    if spriteCooldown > 0 then spriteCooldown = spriteCooldown - delta end
    return spriteCooldown <= 0
  end

  function InventoryViewResetSpriteCooldown() -> void
    spriteCooldown = InventoryViewInitialItemLoadInterval
  end

  function InventoryViewResetCacheCoverage() -> void
    stackCount = 0
    equipmentCount = 0
    cacheHits = 0
    cacheMisses = 0
    cacheEpoch = 0
    local currentCacheEpoch: int = cacheEpoch
    native.GetVariable("inv_overhaul_ui_cache_epoch", currentCacheEpoch)
    cacheEpoch = currentCacheEpoch
  end

  function InventoryViewGetCacheEpoch() -> int return cacheEpoch end

  function InventoryViewRecordStackCacheResult(hit: bool) -> void
    stackCount = stackCount + 1
    if hit then cacheHits = cacheHits + 1 else cacheMisses = cacheMisses + 1 end
  end

  function InventoryViewRecordEquipmentCacheResult(hit: bool) -> void
    equipmentCount = equipmentCount + 1
    if hit then cacheHits = cacheHits + 1 else cacheMisses = cacheMisses + 1 end
  end

  function InventoryViewGetCacheHits() -> int return cacheHits end
  function InventoryViewGetCacheMisses() -> int return cacheMisses end

  function InventoryViewReportFirstInitialItem() -> void
    if !diagnosticsEnabled || firstItemReported then return end
    firstItemReported = true
    native.Trace("INV_OVERHAUL_PERF_PHASE first_item")
  end

  function InventoryViewReportInitialLoadComplete() -> void
    if !diagnosticsEnabled || completeReported then return end
    if !firstItemReported then InventoryViewReportFirstInitialItem() end
    completeReported = true
    local warmed: int = 0
    local warmStarted: int = 0
    if warmGridLoaded then warmStarted = 1 end
    native.GetVariable("inv_overhaul_ui_cache_loaded", warmed)
    native.Trace("INV_OVERHAUL_PERF_PHASE complete stacks=" + stackCount +
      " equipment=" + equipmentCount + " hits=" + cacheHits +
      " misses=" + cacheMisses + " warmed=" + warmed +
      " warm_start=" + warmStarted)
  end

  function InventoryViewSendGridRendererState(
    slot: int,
    operation: int,
    value: int,
    data: object) -> void
    local message: int = inv_overhaul_inventory_protocol.InventoryProtocolEncodeGridRenderer(
      slot, operation, value)
    native.SendMessage(message, "panel_background", data)
  end

  function InventoryViewSetGridRendererHighlight(slot: int, enabled: bool) -> void
    local value: int = 0
    if enabled then value = 1 end
    InventoryViewSendGridRendererState(slot, 4, value, null)
  end

  function InventoryViewGetTargetWindowName(target: int, visibleSlots: int) -> string
    if target >= 0 && target < visibleSlots then
      return inv_overhaul_inventory_protocol.InventoryProtocolGetSlotWindowName(target)
    end
    if target == 100 then return "equip_weapon" end
    if target == 101 then return "equip_feet" end
    if target == 102 then return "equip_head" end
    if target == 103 then return "equip_body" end
    if target == 104 then return "equip_hands" end
    if target == 200 then return "drop_slot" end
    return ""
  end

  function InventoryViewGetTargetDebugName(target: int, visibleSlots: int) -> string
    if target >= 0 && target < visibleSlots then return "BACKPACK_" + target end
    if target == 100 then return "WEAPON" end
    if target == 101 then return "FEET" end
    if target == 102 then return "HEAD" end
    if target == 103 then return "BODY" end
    if target == 104 then return "HANDS" end
    if target == 200 then return "DROP" end
    return "OUTSIDE"
  end
end
