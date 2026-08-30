# Texture Cache

## Source

`scripts/compatibility/ui_runtime/inv_overhaul_texture_cache.lua`

DSL unit: `maintask InvOverhaulTextureCache`

## Responsibility

Retained compatibility placeholder form with an empty initialization entry point.

This source is compatibility-only. Active packages must not import it.

## Dependencies

- No local DSL imports.
- Pathologic native API — engine state, object access, persistence variables, UI messaging, timing, or rendering as listed per function.

## Used by

- `resources/ui/inv_overhaul_texture_cache.xml` (runtime/XML script reference)

## State

No module/task-level mutable state.

## Public API

No importable module API. Runtime entry points are documented under Events / callbacks.

## Internal API

No additional maintask helpers.

## Events / callbacks

### `init() -> void`

Source: `scripts/compatibility/ui_runtime/inv_overhaul_texture_cache.lua`

Purpose: Initializes the texture cache runtime and establishes its starting state and engine/UI integration.

Parameters:

None.

Returns:

None.

Side effects:

- Writes shared engine variable(s): `"inv_overhaul_texture_cache_loaded"`, `"inv_overhaul_texture_cache_disabled"`.
- Invokes engine/native operations: `native.SetVariable`, `native.Trace`.

Called by:

- No in-repository caller was resolved; this may be an engine/XML callback or a conventionally public helper.

Calls:

- `native.SetVariable`
- `native.Trace`

Notes / invariants:

- Maintask helper; callable within its task unless the engine invokes it by a documented callback name.


## Important constants

No module/task-level constants.

## Architectural notes

- No additional module-specific issue identified beyond repository-wide shared-variable and compiler-visible API constraints.
