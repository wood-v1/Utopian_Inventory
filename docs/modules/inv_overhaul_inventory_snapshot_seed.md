# Inventory Snapshot Seed

## Source

`scripts/inventory_runtime/inv_overhaul_inventory_snapshot_seed.lua`

DSL unit: `module inv_overhaul_inventory_snapshot_seed`

## Responsibility

Creates the initial persistent backpack snapshot variables when an older save has no snapshot.

## Dependencies

- `inv_overhaul_inventory_overflow` — Counts unequipped backpack entries and drops excess items near the player without treating equipped items as capacity usage.
- Pathologic native API — engine state, object access, persistence variables, UI messaging, timing, or rendering as listed per function.

## Used by

- `scripts/inventory_runtime/inv_overhaul_inventory_guard.lua`

## State

No module/task-level mutable state.

## Public API

All functions below are compiler-visible when the module is imported; the DSL has no private declaration.

### `VariableName(ordinal: int) -> string`

Source: `scripts/inventory_runtime/inv_overhaul_inventory_snapshot_seed.lua`

Purpose: Returns the shared engine-variable name used for variable name in the inventory snapshot seed subsystem.

Parameters:

- `ordinal: int` — value interpreted according to the function purpose; no narrower contract is established by current code.

Returns:

- `string` — result of: returns the shared engine-variable name used for variable name in the inventory snapshot seed subsystem.

Side effects:

- None directly observable beyond calls listed below.

Called by:

- `scripts/inventory_runtime/inv_overhaul_inventory_snapshot_seed.lua :: InitializeIfMissing`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `InitializeIfMissing() -> void`

Source: `scripts/inventory_runtime/inv_overhaul_inventory_snapshot_seed.lua`

Purpose: Initializes if missing in the inventory snapshot seed subsystem.

Parameters:

None.

Returns:

None.

Side effects:

- Writes shared engine variable(s): `computed value`, `"inv_overhaul_inventory_snapshot_count"`, `"inv_overhaul_inventory_snapshot_version"`, `"inv_overhaul_inventory_snapshot_generation"`, `"inv_overhaul_inventory_snapshot_content_generation"`, `"inv_overhaul_inventory_snapshot_valid"`.
- Invokes engine/native operations: `native.SetVariable`, `native.Trace`.

Called by:

- `scripts/inventory_runtime/inv_overhaul_inventory_guard.lua :: InitializePersistentSnapshotIfMissing`

Calls:

- `native.GetVariable`
- `inv_overhaul_inventory_overflow.OverflowGetPlayer`
- `player.GetItemCount`
- `inv_overhaul_inventory_overflow.OverflowIsEquippedItem`
- `player.GetItem`
- `item.GetItemID`
- `native.SetVariable`
- `VariableName`
- `native.Trace`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.


## Internal API

No additional maintask helpers.

## Events / callbacks

No engine callbacks; this is an imported module.

## Important constants

- `InventorySnapshotSeedCapacity: int = 56` — fixed limit/count for inventory snapshot seed capacity.
- `InventorySnapshotSeedCategoryCount: int = 5` — fixed limit/count for inventory snapshot seed category count.
- `InventorySnapshotSeedVersion: int = 1` — schema/runtime version marker for inventory snapshot seed version.

## Architectural notes

- No additional module-specific issue identified beyond repository-wide shared-variable and compiler-visible API constraints.
