# Special Inventory Bridge

## Source

`scripts/inventory_runtime/inv_overhaul_special_inventory_bridge.lua`

DSL unit: `module inv_overhaul_special_inventory_bridge`

## Responsibility

Consumes native special-inventory remap requests and advances their persistent generation handshake.

## Dependencies

- No local DSL imports.
- Pathologic native API — engine state, object access, persistence variables, UI messaging, timing, or rendering as listed per function.

## Used by

- `scripts/inventory_runtime/inv_overhaul_inventory_guard.lua`

## State

No module/task-level mutable state.

## Public API

All functions below are compiler-visible when the module is imported; the DSL has no private declaration.

### `Reset() -> void`

Source: `scripts/inventory_runtime/inv_overhaul_special_inventory_bridge.lua`

Purpose: Resets special inventory bridge in the special inventory bridge subsystem.

Parameters:

None.

Returns:

None.

Side effects:

- Writes shared engine variable(s): `"inv_overhaul_special_inventory_remap_request"`.
- Invokes engine/native operations: `native.SetVariable`.

Called by:

- `scripts/inventory_runtime/inv_overhaul_inventory_guard.lua :: init`

Calls:

- `native.SetVariable`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `Process() -> void`

Source: `scripts/inventory_runtime/inv_overhaul_special_inventory_bridge.lua`

Purpose: Processes special inventory bridge in the special inventory bridge subsystem.

Parameters:

None.

Returns:

None.

Side effects:

- Writes shared engine variable(s): `"inv_overhaul_special_inventory_remap_request"`, `"inv_overhaul_inventory_reorder_generation"`.
- Invokes engine/native operations: `native.SetVariable`, `native.Trace`.

Called by:

- `scripts/inventory_runtime/inv_overhaul_inventory_guard.lua :: ProcessSpecialRemap`

Calls:

- `native.GetVariable`
- `native.SetVariable`
- `native.Trace`

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
