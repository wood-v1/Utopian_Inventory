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

  function PlayerViewInitializeState() -> void
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

  function DiagnosticsEnabled() -> bool return diagnosticsEnabled end

  function ClaimChildWindowsReady() -> bool
    if childWindowsReady then return false end
    childWindowsReady = true
    return true
  end

  function ChildWindowsReady() -> bool return childWindowsReady end

  function AdvanceMetadataDelay(delta: float) -> bool
    if !metadataPending then return false end
    metadataDelay = metadataDelay - delta
    return metadataDelay <= 0
  end

  function GetMetadataStage() -> int return metadataStage end
  function AdvanceMetadataStage() -> void metadataStage = metadataStage + 1 end

  function CompleteMetadata() -> void
    metadataPending = false
  end

  function IsMetadataPending() -> bool return metadataPending end

  function MarkRendererReady() -> void rendererReady = true end

  function BeginWarmStartAttempt() -> bool
    if warmStartAttempted || !rendererReady || !metadataPending then return false end
    warmStartAttempted = true
    return true
  end

  function MarkWarmGridLoaded() -> void
    warmGridLoaded = true
    metadataStage = 2
    metadataDelay = 0
  end

  function IsWarmGridLoaded() -> bool return warmGridLoaded end

  function BeginInitialLoad(visibleSlots: int) -> void
    if warmGridLoaded then nextSlot = visibleSlots else nextSlot = 0 end
    nextEquipment = 0
    spriteCooldown = 0
    initialLoadActive = true
  end

  function IsInitialLoadActive() -> bool return initialLoadActive end

  function TakeNextEquipment() -> int
    if nextEquipment >= 5 then return -1 end
    local result: int = nextEquipment
    nextEquipment = nextEquipment + 1
    return result
  end

  function TakeNextSlot(visibleSlots: int) -> int
    if nextSlot >= visibleSlots then return -1 end
    local result: int = nextSlot
    nextSlot = nextSlot + 1
    return result
  end

  function InitialLoadComplete(visibleSlots: int) -> bool
    return nextEquipment >= 5 && nextSlot >= visibleSlots
  end

  function FinishInitialLoad() -> void initialLoadActive = false end

  function AdvanceSpriteCooldown(delta: float) -> bool
    if spriteCooldown > 0 then spriteCooldown = spriteCooldown - delta end
    return spriteCooldown <= 0
  end

  function ResetSpriteCooldown() -> void
    spriteCooldown = InventoryViewInitialItemLoadInterval
  end

  function ResetCacheCoverage() -> void
    stackCount = 0
    equipmentCount = 0
    cacheHits = 0
    cacheMisses = 0
    cacheEpoch = 0
    local currentCacheEpoch: int = cacheEpoch
    native.GetVariable("inv_overhaul_ui_cache_epoch", currentCacheEpoch)
    cacheEpoch = currentCacheEpoch
  end

  function GetCacheEpoch() -> int return cacheEpoch end

  function RecordStackCacheResult(hit: bool) -> void
    stackCount = stackCount + 1
    if hit then cacheHits = cacheHits + 1 else cacheMisses = cacheMisses + 1 end
  end

  function RecordEquipmentCacheResult(hit: bool) -> void
    equipmentCount = equipmentCount + 1
    if hit then cacheHits = cacheHits + 1 else cacheMisses = cacheMisses + 1 end
  end

  function GetCacheHits() -> int return cacheHits end
  function GetCacheMisses() -> int return cacheMisses end

  function PlayerViewReportFirstInitialItem() -> void
    if !diagnosticsEnabled || firstItemReported then return end
    firstItemReported = true
    native.Trace("INV_OVERHAUL_PERF_PHASE first_item")
  end

  function PlayerViewReportInitialLoadComplete() -> void
    if !diagnosticsEnabled || completeReported then return end
    if !firstItemReported then PlayerViewReportFirstInitialItem() end
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

  function PlayerViewSendGridRendererState(
    slot: int,
    operation: int,
    value: int,
    data: object) -> void
    local message: int = inv_overhaul_inventory_protocol.EncodeGridRenderer(
      slot, operation, value)
    native.SendMessage(message, "panel_background", data)
  end

  function PlayerViewSetGridRendererHighlight(slot: int, enabled: bool) -> void
    local value: int = 0
    if enabled then value = 1 end
    PlayerViewSendGridRendererState(
      slot, inv_overhaul_inventory_protocol.GridRendererHighlight, value, null)
  end

  function GetTargetWindowName(target: int, visibleSlots: int) -> string
    if target >= 0 && target < visibleSlots then
      return inv_overhaul_inventory_protocol.GetSlotWindowName(target)
    end
    if target == inv_overhaul_inventory_protocol.TargetWeapon then return "equip_weapon" end
    if target == inv_overhaul_inventory_protocol.TargetFeet then return "equip_feet" end
    if target == inv_overhaul_inventory_protocol.TargetHead then return "equip_head" end
    if target == inv_overhaul_inventory_protocol.TargetBody then return "equip_body" end
    if target == inv_overhaul_inventory_protocol.TargetHands then return "equip_hands" end
    if target == inv_overhaul_inventory_protocol.TargetDrop then return "drop_slot" end
    return ""
  end

  function GetTargetDebugName(target: int, visibleSlots: int) -> string
    if target >= 0 && target < visibleSlots then return "BACKPACK_" + target end
    if target == inv_overhaul_inventory_protocol.TargetWeapon then return "WEAPON" end
    if target == inv_overhaul_inventory_protocol.TargetFeet then return "FEET" end
    if target == inv_overhaul_inventory_protocol.TargetHead then return "HEAD" end
    if target == inv_overhaul_inventory_protocol.TargetBody then return "BODY" end
    if target == inv_overhaul_inventory_protocol.TargetHands then return "HANDS" end
    if target == inv_overhaul_inventory_protocol.TargetDrop then return "DROP" end
    return "OUTSIDE"
  end
end
