# UI Texture Cache

## Source

`scripts/compatibility/ui_runtime/inv_overhaul_ui_texture_cache.lua`

DSL unit: `maintask InvOverhaulUITextureCache`

## Responsibility

Retained compatibility runtime that incrementally preloads item textures for older UI paths.

This source is compatibility-only. Active packages must not import it.

## Dependencies

- No local DSL imports.
- Pathologic native API — engine state, object access, persistence variables, UI messaging, timing, or rendering as listed per function.

## Used by

- `resources/ui/inv_overhaul_ui_texture_cache.xml` (runtime/XML script reference)

## State

- `cachedItemIDs: object` — cached d item ids data used to avoid rebuilding engine/container lookups.
- `cachedImages: object` — cached d images data used to avoid rebuilding engine/container lookups.
- `scanCategory: int` — mutable runtime state for scan category.
- `scanIndex: int` — mutable runtime state for scan index.
- `scanGeneration: int` — mutable runtime state for scan generation.
- `completedGeneration: int` — mutable runtime state for completed generation.
- `cacheEpoch: int` — cached epoch data used to avoid rebuilding engine/container lookups.
- `loadedCount: int` — cached or current count for loaded count.
- `cachedBranch: int` — cached d branch data used to avoid rebuilding engine/container lookups.
- `characterStage: int` — mutable runtime state for character stage.
- `updateDelay: float` — timing state for update delay.
- `scanActive: bool` — lifecycle/behavior flag for scan active.
- `scanOverflowed: bool` — lifecycle/behavior flag for scan overflowed.

## Public API

No importable module API. Runtime entry points are documented under Events / callbacks.

## Internal API

### `GetItemEpochVariable(itemID: int) -> string`

Source: `scripts/compatibility/ui_runtime/inv_overhaul_ui_texture_cache.lua`

Purpose: Returns item epoch variable in the ui texture cache subsystem.

Parameters:

- `itemID: int` — engine item or callback identifier interpreted by this function.

Returns:

- `string` — result of: returns item epoch variable in the ui texture cache subsystem.

Side effects:

- None directly observable beyond calls listed below.

Called by:

- `scripts/compatibility/ui_runtime/inv_overhaul_ui_texture_cache.lua :: CacheItem`

Notes / invariants:

- Maintask helper; callable within its task unless the engine invokes it by a documented callback name.

### `GetBackground(branch: int) -> string`

Source: `scripts/compatibility/ui_runtime/inv_overhaul_ui_texture_cache.lua`

Purpose: Returns background in the ui texture cache subsystem.

Parameters:

- `branch: int` — value interpreted according to the function purpose; no narrower contract is established by current code.

Returns:

- `string` — result of: returns background in the ui texture cache subsystem.

Side effects:

- None directly observable beyond calls listed below.

Called by:

- `scripts/compatibility/ui_runtime/inv_overhaul_ui_texture_cache.lua :: ProcessCharacterCache`

Notes / invariants:

- Maintask helper; callable within its task unless the engine invokes it by a documented callback name.

### `GetDoll(branch: int) -> string`

Source: `scripts/compatibility/ui_runtime/inv_overhaul_ui_texture_cache.lua`

Purpose: Returns doll in the ui texture cache subsystem.

Parameters:

- `branch: int` — value interpreted according to the function purpose; no narrower contract is established by current code.

Returns:

- `string` — result of: returns doll in the ui texture cache subsystem.

Side effects:

- None directly observable beyond calls listed below.

Called by:

- `scripts/compatibility/ui_runtime/inv_overhaul_ui_texture_cache.lua :: ProcessCharacterCache`

Notes / invariants:

- Maintask helper; callable within its task unless the engine invokes it by a documented callback name.

### `HoldImage(sprite: string) -> void`

Source: `scripts/compatibility/ui_runtime/inv_overhaul_ui_texture_cache.lua`

Purpose: Retains image in the ui texture cache subsystem.

Parameters:

- `sprite: string` — value interpreted according to the function purpose; no narrower contract is established by current code.

Returns:

None.

Side effects:

- Invokes engine/native operations: `native.LoadImage`.
- May mutate engine/UI objects through: `cachedImages.add`.

Called by:

- `scripts/compatibility/ui_runtime/inv_overhaul_ui_texture_cache.lua :: CacheItem`
- `scripts/compatibility/ui_runtime/inv_overhaul_ui_texture_cache.lua :: ProcessCharacterCache`

Calls:

- `native.LoadImage`
- `cachedImages.add`

Notes / invariants:

- Maintask helper; callable within its task unless the engine invokes it by a documented callback name.

### `ResetCharacterCache(branch: int) -> void`

Source: `scripts/compatibility/ui_runtime/inv_overhaul_ui_texture_cache.lua`

Purpose: Resets character cache in the ui texture cache subsystem.

Parameters:

- `branch: int` — value interpreted according to the function purpose; no narrower contract is established by current code.

Returns:

None.

Side effects:

- Mutates module/task state: `cachedBranch`, `characterStage`, `updateDelay`.
- Writes shared engine variable(s): `"inv_overhaul_ui_cache_character_ready"`, `"inv_overhaul_ui_cache_fully_warmed"`.
- Invokes engine/native operations: `native.SetVariable`, `native.Trace`.

Called by:

- `scripts/compatibility/ui_runtime/inv_overhaul_ui_texture_cache.lua :: init`
- `scripts/compatibility/ui_runtime/inv_overhaul_ui_texture_cache.lua :: ProcessCharacterCache`

Calls:

- `native.SetVariable`
- `native.Trace`

Notes / invariants:

- Maintask helper; callable within its task unless the engine invokes it by a documented callback name.

### `BeginScan() -> void`

Source: `scripts/compatibility/ui_runtime/inv_overhaul_ui_texture_cache.lua`

Purpose: Begins scan in the ui texture cache subsystem.

Parameters:

None.

Returns:

None.

Side effects:

- Mutates module/task state: `scanCategory`, `scanIndex`, `scanOverflowed`, `scanActive`.
- Writes shared engine variable(s): `"inv_overhaul_ui_cache_fully_warmed"`.
- Invokes engine/native operations: `native.SetVariable`.

Called by:

- `scripts/compatibility/ui_runtime/inv_overhaul_ui_texture_cache.lua :: CompleteScan`
- `scripts/compatibility/ui_runtime/inv_overhaul_ui_texture_cache.lua :: ProcessCharacterCache`
- `scripts/compatibility/ui_runtime/inv_overhaul_ui_texture_cache.lua :: ProcessInventoryCache`

Calls:

- `native.GetVariable`
- `native.SetVariable`

Notes / invariants:

- Maintask helper; callable within its task unless the engine invokes it by a documented callback name.

### `IsCached(itemID: int) -> bool`

Source: `scripts/compatibility/ui_runtime/inv_overhaul_ui_texture_cache.lua`

Purpose: Returns whether cached in the ui texture cache subsystem.

Parameters:

- `itemID: int` — engine item or callback identifier interpreted by this function.

Returns:

- `boolean` — result of: returns whether cached in the ui texture cache subsystem.

Side effects:

- None directly observable beyond calls listed below.

Called by:

- `scripts/compatibility/ui_runtime/inv_overhaul_ui_texture_cache.lua :: CacheItem`

Calls:

- `cachedItemIDs.size`
- `cachedItemIDs.get`

Notes / invariants:

- Maintask helper; callable within its task unless the engine invokes it by a documented callback name.

### `CacheItem(itemID: int) -> bool`

Source: `scripts/compatibility/ui_runtime/inv_overhaul_ui_texture_cache.lua`

Purpose: Caches item in the ui texture cache subsystem.

Parameters:

- `itemID: int` — engine item or callback identifier interpreted by this function.

Returns:

- `boolean` — result of: caches item in the ui texture cache subsystem.

Side effects:

- Mutates module/task state: `scanOverflowed`, `loadedCount`.
- Writes shared engine variable(s): `"inv_overhaul_ui_cache_loaded"`, `computed value`.
- Invokes engine/native operations: `native.SetVariable`.
- May mutate engine/UI objects through: `cachedItemIDs.add`.

Called by:

- `scripts/compatibility/ui_runtime/inv_overhaul_ui_texture_cache.lua :: ProcessInventoryCache`

Calls:

- `IsCached`
- `native.GetInvItemSprite2`
- `HoldImage`
- `cachedItemIDs.add`
- `native.SetVariable`
- `GetItemEpochVariable`

Notes / invariants:

- Maintask helper; callable within its task unless the engine invokes it by a documented callback name.

### `CompleteScan() -> void`

Source: `scripts/compatibility/ui_runtime/inv_overhaul_ui_texture_cache.lua`

Purpose: Completes scan in the ui texture cache subsystem.

Parameters:

None.

Returns:

None.

Side effects:

- Mutates module/task state: `completedGeneration`, `scanActive`, `updateDelay`.
- Writes shared engine variable(s): `"inv_overhaul_ui_cache_completed_generation"`, `"inv_overhaul_ui_cache_fully_warmed"`.
- Invokes engine/native operations: `native.SetVariable`, `native.Trace`.

Called by:

- `scripts/compatibility/ui_runtime/inv_overhaul_ui_texture_cache.lua :: ProcessInventoryCache`

Calls:

- `native.GetVariable`
- `BeginScan`
- `native.SetVariable`
- `native.Trace`

Notes / invariants:

- Maintask helper; callable within its task unless the engine invokes it by a documented callback name.

### `ProcessCharacterCache() -> bool`

Source: `scripts/compatibility/ui_runtime/inv_overhaul_ui_texture_cache.lua`

Purpose: Processes character cache in the ui texture cache subsystem.

Parameters:

None.

Returns:

- `boolean` — result of: processes character cache in the ui texture cache subsystem.

Side effects:

- Mutates module/task state: `characterStage`, `updateDelay`.
- Writes shared engine variable(s): `"inv_overhaul_ui_cache_character_ready"`.
- Invokes engine/native operations: `native.SetVariable`.

Called by:

- `scripts/compatibility/ui_runtime/inv_overhaul_ui_texture_cache.lua :: OnUpdate`

Calls:

- `native.GetVariable`
- `ResetCharacterCache`
- `HoldImage`
- `GetBackground`
- `GetDoll`
- `native.SetVariable`
- `BeginScan`

Notes / invariants:

- Maintask helper; callable within its task unless the engine invokes it by a documented callback name.

### `ProcessInventoryCache() -> void`

Source: `scripts/compatibility/ui_runtime/inv_overhaul_ui_texture_cache.lua`

Purpose: Processes inventory cache in the ui texture cache subsystem.

Parameters:

None.

Returns:

None.

Side effects:

- Mutates module/task state: `updateDelay`, `scanCategory`, `scanIndex`.

Called by:

- `scripts/compatibility/ui_runtime/inv_overhaul_ui_texture_cache.lua :: OnUpdate`

Calls:

- `native.GetVariable`
- `BeginScan`
- `native.GetPlayerContainer`
- `CompleteScan`
- `player.GetItemCount`
- `player.GetItem`
- `item.GetItemID`
- `CacheItem`

Notes / invariants:

- Maintask helper; callable within its task unless the engine invokes it by a documented callback name.


## Events / callbacks

### `init() -> void`

Source: `scripts/compatibility/ui_runtime/inv_overhaul_ui_texture_cache.lua`

Purpose: Initializes the ui texture cache runtime and establishes its starting state and engine/UI integration.

Parameters:

None.

Returns:

None.

Side effects:

- Mutates module/task state: `scanCategory`, `scanIndex`, `scanGeneration`, `completedGeneration`, `loadedCount`, `cachedBranch`, `characterStage`, `updateDelay`, `… and 3 more`.
- Writes shared engine variable(s): `"inv_overhaul_ui_cache_epoch"`, `"inv_overhaul_ui_cache_loaded"`, `"inv_overhaul_ui_cache_character_ready"`, `"inv_overhaul_ui_cache_completed_generation"`, `"inv_overhaul_ui_cache_fully_warmed"`.
- Invokes engine/native operations: `native.CreateIntVector`, `native.CreateStringVector`, `native.SetVariable`, `native.Trace`, `native.SetNeedUpdate`, `native.ProcessEvents`.

Called by:

- No in-repository caller was resolved; this may be an engine/XML callback or a conventionally public helper.

Calls:

- `native.CreateIntVector`
- `native.CreateStringVector`
- `native.GetVariable`
- `native.SetVariable`
- `ResetCharacterCache`
- `native.Trace`
- `native.SetNeedUpdate`
- `native.ProcessEvents`

Notes / invariants:

- Maintask helper; callable within its task unless the engine invokes it by a documented callback name.

### `OnUpdate(delta: float) -> void`

Source: `scripts/compatibility/ui_runtime/inv_overhaul_ui_texture_cache.lua`

Purpose: Handles the engine/UI `OnUpdate` callback for the ui texture cache runtime.

Parameters:

- `delta: float` — elapsed update time in seconds.

Returns:

None.

Side effects:

- Mutates module/task state: `updateDelay`.

Called by:

- No in-repository caller was resolved; this may be an engine/XML callback or a conventionally public helper.

Calls:

- `ProcessCharacterCache`
- `ProcessInventoryCache`

Notes / invariants:

- Callback recognition is name-based in `pathologic_lua_compiler`; `OnUpdate` is an engine event name.


## Important constants

- `c_sScriptVersion: string = "2026.08.09-ui-companion-cache-2"` — schema/runtime version marker for script version.
- `c_iCategoryCount: int = 5` — fixed limit/count for category count.
- `c_iMaxCachedItems: int = 96` — named behavior/layout value for max cached items.
- `c_fLoadStep: float = 0.04` — named behavior/layout value for load step.
- `c_fGenerationPollDelay: float = 0.25` — timing value, in seconds, for generation poll delay.

## Architectural notes

- No additional module-specific issue identified beyond repository-wide shared-variable and compiler-visible API constraints.
