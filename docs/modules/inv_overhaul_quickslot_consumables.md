# Quickslot Consumables

## Source

`scripts/quickslots/inv_overhaul_quickslot_consumables.lua`

DSL unit: `module inv_overhaul_quickslot_consumables`

## Responsibility

Maps supported consumable item IDs to their use-effect script names.

## Dependencies

- No local DSL imports.

## Used by

- `scripts/quickslots/inv_overhaul_quickslots.lua`

## State

No module/task-level mutable state.

## Public API

All functions below are compiler-visible when the module is imported; the DSL has no private declaration.

### `GetUseEffect(itemID: int) -> string`

Source: `scripts/quickslots/inv_overhaul_quickslot_consumables.lua`

Purpose: Returns use effect in the quickslot consumables subsystem.

Parameters:

- `itemID: int` — engine item or callback identifier interpreted by this function.

Returns:

- `string` — result of: returns use effect in the quickslot consumables subsystem.

Side effects:

- None directly observable beyond calls listed below.

Called by:

- `scripts/quickslots/inv_overhaul_quickslots.lua :: GetUseEffect`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.


## Internal API

No additional maintask helpers.

## Events / callbacks

No engine callbacks; this is an imported module.

## Important constants

No module/task-level constants.

## Architectural notes

- No additional module-specific issue identified beyond repository-wide shared-variable and compiler-visible API constraints.
