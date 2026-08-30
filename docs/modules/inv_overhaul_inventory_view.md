# Inventory View

## Source

`scripts/player_inventory/inv_overhaul_inventory_view.lua`

DSL unit: `module inv_overhaul_inventory_view`

## Responsibility

Emits player inventory UI messages for slot contents, metadata, highlights, equipment, money, paging, and readiness.

## Dependencies

- `inv_overhaul_inventory_protocol` — Defines and encodes the numeric UI message protocol shared by inventory forms and controllers.
- Pathologic native API — engine state, object access, persistence variables, UI messaging, timing, or rendering as listed per function.

## Used by

- `scripts/player_inventory/inv_overhaul_inventory_controller.lua`
- `scripts/player_inventory/inv_overhaul_inventory_presenter.lua`

## State

- `diagnosticsEnabled: bool` — lifecycle/behavior flag for diagnostics enabled.
- `firstItemReported: bool` — lifecycle/behavior flag for first item reported.
- `completeReported: bool` — lifecycle/behavior flag for complete reported.
- `stackCount: int` — cached or current count for stack count.
- `equipmentCount: int` — cached or current count for equipment count.
- `cacheHits: int` — cached hits data used to avoid rebuilding engine/container lookups.
- `cacheMisses: int` — cached misses data used to avoid rebuilding engine/container lookups.
- `cacheEpoch: int` — cached epoch data used to avoid rebuilding engine/container lookups.
- `rendererReady: bool` — lifecycle/behavior flag for renderer ready.
- `warmGridLoaded: bool` — lifecycle/behavior flag for warm grid loaded.
- `warmStartAttempted: bool` — lifecycle/behavior flag for warm start attempted.
- `childWindowsReady: bool` — lifecycle/behavior flag for child windows ready.
- `metadataPending: bool` — deferred-work state for metadata pending.
- `metadataDelay: float` — timing state for metadata delay.
- `metadataStage: int` — mutable runtime state for metadata stage.
- `initialLoadActive: bool` — lifecycle/behavior flag for initial load active.
- `nextSlot: int` — current or cached layout value for next slot.
- `nextEquipment: int` — mutable runtime state for next equipment.
- `spriteCooldown: float` — timing state for sprite cooldown.

## Public API

All functions below are compiler-visible when the module is imported; the DSL has no private declaration.

### `PlayerViewInitializeState() -> void`

Source: `scripts/player_inventory/inv_overhaul_inventory_view.lua`

Purpose: Initializes state for player view in the inventory view subsystem.

Parameters:

None.

Returns:

None.

Side effects:

- Mutates module/task state: `diagnosticsEnabled`, `firstItemReported`, `completeReported`, `stackCount`, `equipmentCount`, `cacheHits`, `cacheMisses`, `cacheEpoch`, `… and 11 more`.

Called by:

- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: PlayerControllerInitialize`

Calls:

- `native.GetVariable`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `DiagnosticsEnabled() -> bool`

Source: `scripts/player_inventory/inv_overhaul_inventory_view.lua`

Purpose: Returns whether diagnostics in the inventory view subsystem.

Parameters:

None.

Returns:

- `boolean` — result of: returns whether diagnostics in the inventory view subsystem.

Side effects:

- None directly observable beyond calls listed below.

Called by:

- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: PlayerControllerInitialize`
- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: TryWarmStartGrid`
- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: PlayerControllerContinueInitialSlotLoad`
- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: RunFramePreparationStage`
- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: RunMetadataAndLoadingStage`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `ClaimChildWindowsReady() -> bool`

Source: `scripts/player_inventory/inv_overhaul_inventory_view.lua`

Purpose: Claims child windows ready in the inventory view subsystem.

Parameters:

None.

Returns:

- `boolean` — result of: claims child windows ready in the inventory view subsystem.

Side effects:

- Mutates module/task state: `childWindowsReady`.

Called by:

- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: RunFramePreparationStage`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `ChildWindowsReady() -> bool`

Source: `scripts/player_inventory/inv_overhaul_inventory_view.lua`

Purpose: Returns whether child windows in the inventory view subsystem.

Parameters:

None.

Returns:

- `boolean` — result of: returns whether child windows in the inventory view subsystem.

Side effects:

- None directly observable beyond calls listed below.

Called by:

- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: PlayerControllerUpdateLayout`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `AdvanceMetadataDelay(delta: float) -> bool`

Source: `scripts/player_inventory/inv_overhaul_inventory_view.lua`

Purpose: Advances metadata delay in the inventory view subsystem.

Parameters:

- `delta: float` — elapsed update time in seconds.

Returns:

- `boolean` — result of: advances metadata delay in the inventory view subsystem.

Side effects:

- Mutates module/task state: `metadataDelay`.

Called by:

- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: RunMetadataAndLoadingStage`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `GetMetadataStage() -> int`

Source: `scripts/player_inventory/inv_overhaul_inventory_view.lua`

Purpose: Returns metadata stage in the inventory view subsystem.

Parameters:

None.

Returns:

- `number` (integer) — result of: returns metadata stage in the inventory view subsystem.

Side effects:

- None directly observable beyond calls listed below.

Called by:

- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: RunMetadataAndLoadingStage`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `AdvanceMetadataStage() -> void`

Source: `scripts/player_inventory/inv_overhaul_inventory_view.lua`

Purpose: Advances metadata stage in the inventory view subsystem.

Parameters:

None.

Returns:

None.

Side effects:

- Mutates module/task state: `metadataStage`.

Called by:

- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: RunMetadataAndLoadingStage`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `CompleteMetadata() -> void`

Source: `scripts/player_inventory/inv_overhaul_inventory_view.lua`

Purpose: Completes metadata in the inventory view subsystem.

Parameters:

None.

Returns:

None.

Side effects:

- Mutates module/task state: `metadataPending`.

Called by:

- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: RunMetadataAndLoadingStage`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `IsMetadataPending() -> bool`

Source: `scripts/player_inventory/inv_overhaul_inventory_view.lua`

Purpose: Returns whether metadata pending in the inventory view subsystem.

Parameters:

None.

Returns:

- `boolean` — result of: returns whether metadata pending in the inventory view subsystem.

Side effects:

- None directly observable beyond calls listed below.

Called by:

- No in-repository caller was resolved; this may be an engine/XML callback or a conventionally public helper.

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `MarkRendererReady() -> void`

Source: `scripts/player_inventory/inv_overhaul_inventory_view.lua`

Purpose: Marks renderer ready in the inventory view subsystem.

Parameters:

None.

Returns:

None.

Side effects:

- Mutates module/task state: `rendererReady`.

Called by:

- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: HandleGlobalProtocolMessage`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `BeginWarmStartAttempt() -> bool`

Source: `scripts/player_inventory/inv_overhaul_inventory_view.lua`

Purpose: Begins warm start attempt in the inventory view subsystem.

Parameters:

None.

Returns:

- `boolean` — result of: begins warm start attempt in the inventory view subsystem.

Side effects:

- Mutates module/task state: `warmStartAttempted`.

Called by:

- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: TryWarmStartGrid`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `MarkWarmGridLoaded() -> void`

Source: `scripts/player_inventory/inv_overhaul_inventory_view.lua`

Purpose: Marks warm grid loaded in the inventory view subsystem.

Parameters:

None.

Returns:

None.

Side effects:

- Mutates module/task state: `warmGridLoaded`, `metadataStage`, `metadataDelay`.

Called by:

- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: TryWarmStartGrid`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `IsWarmGridLoaded() -> bool`

Source: `scripts/player_inventory/inv_overhaul_inventory_view.lua`

Purpose: Returns whether warm grid loaded in the inventory view subsystem.

Parameters:

None.

Returns:

- `boolean` — result of: returns whether warm grid loaded in the inventory view subsystem.

Side effects:

- None directly observable beyond calls listed below.

Called by:

- No in-repository caller was resolved; this may be an engine/XML callback or a conventionally public helper.

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `BeginInitialLoad(visibleSlots: int) -> void`

Source: `scripts/player_inventory/inv_overhaul_inventory_view.lua`

Purpose: Begins initial load in the inventory view subsystem.

Parameters:

- `visibleSlots: int` — slot index or encoded slot target interpreted by this function.

Returns:

None.

Side effects:

- Mutates module/task state: `nextSlot`, `nextEquipment`, `spriteCooldown`, `initialLoadActive`.

Called by:

- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: PlayerControllerBeginInitialSlotLoad`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `IsInitialLoadActive() -> bool`

Source: `scripts/player_inventory/inv_overhaul_inventory_view.lua`

Purpose: Returns whether initial load active in the inventory view subsystem.

Parameters:

None.

Returns:

- `boolean` — result of: returns whether initial load active in the inventory view subsystem.

Side effects:

- None directly observable beyond calls listed below.

Called by:

- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: PlayerControllerContinueInitialSlotLoad`
- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: RunMetadataAndLoadingStage`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `TakeNextEquipment() -> int`

Source: `scripts/player_inventory/inv_overhaul_inventory_view.lua`

Purpose: Takes next equipment in the inventory view subsystem.

Parameters:

None.

Returns:

- `number` (integer) — result of: takes next equipment in the inventory view subsystem.

Side effects:

- Mutates module/task state: `nextEquipment`.

Called by:

- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: PlayerControllerContinueInitialSlotLoad`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `TakeNextSlot(visibleSlots: int) -> int`

Source: `scripts/player_inventory/inv_overhaul_inventory_view.lua`

Purpose: Takes next slot in the inventory view subsystem.

Parameters:

- `visibleSlots: int` — slot index or encoded slot target interpreted by this function.

Returns:

- `number` (integer) — result of: takes next slot in the inventory view subsystem.

Side effects:

- Mutates module/task state: `nextSlot`.

Called by:

- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: PlayerControllerContinueInitialSlotLoad`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `InitialLoadComplete(visibleSlots: int) -> bool`

Source: `scripts/player_inventory/inv_overhaul_inventory_view.lua`

Purpose: Loads complete for initial in the inventory view subsystem.

Parameters:

- `visibleSlots: int` — slot index or encoded slot target interpreted by this function.

Returns:

- `boolean` — result of: loads complete for initial in the inventory view subsystem.

Side effects:

- None directly observable beyond calls listed below.

Called by:

- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: PlayerControllerContinueInitialSlotLoad`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `FinishInitialLoad() -> void`

Source: `scripts/player_inventory/inv_overhaul_inventory_view.lua`

Purpose: Completes initial load in the inventory view subsystem.

Parameters:

None.

Returns:

None.

Side effects:

- Mutates module/task state: `initialLoadActive`.

Called by:

- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: PlayerControllerContinueInitialSlotLoad`
- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: UpdateSlots`
- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: RefreshEquipmentMutation`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `AdvanceSpriteCooldown(delta: float) -> bool`

Source: `scripts/player_inventory/inv_overhaul_inventory_view.lua`

Purpose: Advances sprite cooldown in the inventory view subsystem.

Parameters:

- `delta: float` — elapsed update time in seconds.

Returns:

- `boolean` — result of: advances sprite cooldown in the inventory view subsystem.

Side effects:

- Mutates module/task state: `spriteCooldown`.

Called by:

- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: RunMetadataAndLoadingStage`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `ResetSpriteCooldown() -> void`

Source: `scripts/player_inventory/inv_overhaul_inventory_view.lua`

Purpose: Resets sprite cooldown in the inventory view subsystem.

Parameters:

None.

Returns:

None.

Side effects:

- Mutates module/task state: `spriteCooldown`.

Called by:

- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: RunMetadataAndLoadingStage`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `ResetCacheCoverage() -> void`

Source: `scripts/player_inventory/inv_overhaul_inventory_view.lua`

Purpose: Resets cache coverage in the inventory view subsystem.

Parameters:

None.

Returns:

None.

Side effects:

- Mutates module/task state: `stackCount`, `equipmentCount`, `cacheHits`, `cacheMisses`, `cacheEpoch`.

Called by:

- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: MeasureInitialTextureCacheCoverage`

Calls:

- `native.GetVariable`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `GetCacheEpoch() -> int`

Source: `scripts/player_inventory/inv_overhaul_inventory_view.lua`

Purpose: Returns cache epoch in the inventory view subsystem.

Parameters:

None.

Returns:

- `number` (integer) — result of: returns cache epoch in the inventory view subsystem.

Side effects:

- None directly observable beyond calls listed below.

Called by:

- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: ReadPerfCacheEpoch`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `RecordStackCacheResult(hit: bool) -> void`

Source: `scripts/player_inventory/inv_overhaul_inventory_view.lua`

Purpose: Records stack cache result in the inventory view subsystem.

Parameters:

- `hit: bool` — behavior flag interpreted by this function.

Returns:

None.

Side effects:

- Mutates module/task state: `stackCount`, `cacheHits`, `cacheMisses`.

Called by:

- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: MeasureInitialTextureCacheCoverage`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `RecordEquipmentCacheResult(hit: bool) -> void`

Source: `scripts/player_inventory/inv_overhaul_inventory_view.lua`

Purpose: Records equipment cache result in the inventory view subsystem.

Parameters:

- `hit: bool` — behavior flag interpreted by this function.

Returns:

None.

Side effects:

- Mutates module/task state: `equipmentCount`, `cacheHits`, `cacheMisses`.

Called by:

- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: MeasureInitialTextureCacheCoverage`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `GetCacheHits() -> int`

Source: `scripts/player_inventory/inv_overhaul_inventory_view.lua`

Purpose: Returns cache hits in the inventory view subsystem.

Parameters:

None.

Returns:

- `number` (integer) — result of: returns cache hits in the inventory view subsystem.

Side effects:

- None directly observable beyond calls listed below.

Called by:

- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: TryWarmStartGrid`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `GetCacheMisses() -> int`

Source: `scripts/player_inventory/inv_overhaul_inventory_view.lua`

Purpose: Returns cache misses in the inventory view subsystem.

Parameters:

None.

Returns:

- `number` (integer) — result of: returns cache misses in the inventory view subsystem.

Side effects:

- None directly observable beyond calls listed below.

Called by:

- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: TryWarmStartGrid`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `PlayerViewReportFirstInitialItem() -> void`

Source: `scripts/player_inventory/inv_overhaul_inventory_view.lua`

Purpose: Reports first initial item for player view in the inventory view subsystem.

Parameters:

None.

Returns:

None.

Side effects:

- Mutates module/task state: `firstItemReported`.
- Invokes engine/native operations: `native.Trace`.

Called by:

- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: PlayerControllerReportFirstInitialItem`
- `scripts/player_inventory/inv_overhaul_inventory_view.lua :: PlayerViewReportInitialLoadComplete`

Calls:

- `native.Trace`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `PlayerViewReportInitialLoadComplete() -> void`

Source: `scripts/player_inventory/inv_overhaul_inventory_view.lua`

Purpose: Reports initial load complete for player view in the inventory view subsystem.

Parameters:

None.

Returns:

None.

Side effects:

- Mutates module/task state: `completeReported`.
- Invokes engine/native operations: `native.Trace`.

Called by:

- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: PlayerControllerReportInitialLoadComplete`

Calls:

- `PlayerViewReportFirstInitialItem`
- `native.GetVariable`
- `native.Trace`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `PlayerViewSendGridRendererState(slot: int, operation: int, value: int, data: object) -> void`

Source: `scripts/player_inventory/inv_overhaul_inventory_view.lua`

Purpose: Sends grid renderer state for player view in the inventory view subsystem.

Parameters:

- `slot: int` — slot index or encoded slot target interpreted by this function.
- `operation: int` — value interpreted according to the function purpose; no narrower contract is established by current code.
- `value: int` — value interpreted according to the function purpose; no narrower contract is established by current code.
- `data: object` — engine callback/UI payload object; shape depends on the message.

Returns:

None.

Side effects:

- Invokes engine/native operations: `native.SendMessage`.

Called by:

- `scripts/player_inventory/inv_overhaul_inventory_presenter.lua :: PlayerPresenterSendGridRendererState`
- `scripts/player_inventory/inv_overhaul_inventory_view.lua :: PlayerViewSetGridRendererHighlight`

Calls:

- `inv_overhaul_inventory_protocol.EncodeGridRenderer`
- `native.SendMessage`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `PlayerViewSetGridRendererHighlight(slot: int, enabled: bool) -> void`

Source: `scripts/player_inventory/inv_overhaul_inventory_view.lua`

Purpose: Sets grid renderer highlight for player view in the inventory view subsystem.

Parameters:

- `slot: int` — slot index or encoded slot target interpreted by this function.
- `enabled: bool` — behavior flag interpreted by this function.

Returns:

None.

Side effects:

- None directly observable beyond calls listed below.

Called by:

- `scripts/player_inventory/inv_overhaul_inventory_presenter.lua :: PlayerPresenterSetGridRendererHighlight`

Calls:

- `PlayerViewSendGridRendererState`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `GetTargetWindowName(target: int, visibleSlots: int) -> string`

Source: `scripts/player_inventory/inv_overhaul_inventory_view.lua`

Purpose: Returns target window name in the inventory view subsystem.

Parameters:

- `target: int` — value interpreted according to the function purpose; no narrower contract is established by current code.
- `visibleSlots: int` — slot index or encoded slot target interpreted by this function.

Returns:

- `string` — result of: returns target window name in the inventory view subsystem.

Side effects:

- Delegates to compiler-visible module APIs and inherits their documented side effects.

Called by:

- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: PlayerControllerGetTargetWndName`

Calls:

- `inv_overhaul_inventory_protocol.GetSlotWindowName`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `GetTargetDebugName(target: int, visibleSlots: int) -> string`

Source: `scripts/player_inventory/inv_overhaul_inventory_view.lua`

Purpose: Returns target debug name in the inventory view subsystem.

Parameters:

- `target: int` — value interpreted according to the function purpose; no narrower contract is established by current code.
- `visibleSlots: int` — slot index or encoded slot target interpreted by this function.

Returns:

- `string` — result of: returns target debug name in the inventory view subsystem.

Side effects:

- None directly observable beyond calls listed below.

Called by:

- No in-repository caller was resolved; this may be an engine/XML callback or a conventionally public helper.

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.


## Internal API

No additional maintask helpers.

## Events / callbacks

No engine callbacks; this is an imported module.

## Important constants

- `InventoryViewInitialItemLoadInterval: float = 0.00` — named behavior/layout value for inventory view initial item load interval.

## Architectural notes

- No additional module-specific issue identified beyond repository-wide shared-variable and compiler-visible API constraints.
