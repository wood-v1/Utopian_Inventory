# Inventory Bootstrap

## Source

`scripts/inventory_runtime/inv_overhaul_inventory_bootstrap.lua`

DSL unit: `maintask InventoryOverhaulBootstrap`

## Responsibility

Starts the persistent inventory guard and quickslot player effects after the native bootstrap hook creates the player task.

## Dependencies

- No local DSL imports.
- Pathologic native API — engine state, object access, persistence variables, UI messaging, timing, or rendering as listed per function.

## Used by

- `bootstrap.cpp` (runtime/XML script reference)

## State

No module/task-level mutable state.

## Public API

No importable module API. Runtime entry points are documented under Events / callbacks.

## Internal API

No additional maintask helpers.

## Events / callbacks

### `init() -> void`

Source: `scripts/inventory_runtime/inv_overhaul_inventory_bootstrap.lua`

Purpose: Initializes the inventory bootstrap runtime and establishes its starting state and engine/UI integration.

Parameters:

None.

Returns:

None.

Side effects:

- Writes shared engine variable(s): `"inv_overhaul_effect_generation"`.
- Invokes engine/native operations: `native.Trace`, `native.SetVariable`.
- May mutate engine/UI objects through: `player.ApplyEffect`.

Called by:

- No in-repository caller was resolved; this may be an engine/XML callback or a conventionally public helper.

Calls:

- `native.self`
- `native.sync`
- `native.GetVariable`
- `native.Trace`
- `native.SetVariable`
- `player.ApplyEffect`

Notes / invariants:

- Maintask helper; callable within its task unless the engine invokes it by a documented callback name.


## Important constants

No module/task-level constants.

## Architectural notes

- No additional module-specific issue identified beyond repository-wide shared-variable and compiler-visible API constraints.
