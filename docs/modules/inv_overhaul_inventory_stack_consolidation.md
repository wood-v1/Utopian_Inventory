# Inventory Stack Consolidation

## Source

`scripts/inventory_runtime/inv_overhaul_inventory_stack_consolidation.lua`

DSL unit: `module inv_overhaul_inventory_stack_consolidation`

## Responsibility

Merges duplicate stackable entries while preserving quickslot occurrence bindings and reporting layout-affecting removals.

## Dependencies

- `inv_overhaul_inventory_overflow` — Counts unequipped backpack entries and drops excess items near the player without treating equipped items as capacity usage.
- Pathologic native API — engine state, object access, persistence variables, UI messaging, timing, or rendering as listed per function.

## Used by

- `scripts/inventory_runtime/inv_overhaul_inventory_guard.lua`

## State

No module/task-level mutable state.

## Public API

All functions below are compiler-visible when the module is imported; the DSL has no private declaration.

### `StackItemVariable(slot: int) -> string`

Source: `scripts/inventory_runtime/inv_overhaul_inventory_stack_consolidation.lua`

Purpose: Returns the shared engine-variable name used for stack item variable in the inventory stack consolidation subsystem.

Parameters:

- `slot: int` — slot index or encoded slot target interpreted by this function.

Returns:

- `string` — result of: returns the shared engine-variable name used for stack item variable in the inventory stack consolidation subsystem.

Side effects:

- None directly observable beyond calls listed below.

Called by:

- `scripts/inventory_runtime/inv_overhaul_inventory_stack_consolidation.lua :: NormalizeQuickslots`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `StackCategoryVariable(slot: int) -> string`

Source: `scripts/inventory_runtime/inv_overhaul_inventory_stack_consolidation.lua`

Purpose: Returns the shared engine-variable name used for stack category variable in the inventory stack consolidation subsystem.

Parameters:

- `slot: int` — slot index or encoded slot target interpreted by this function.

Returns:

- `string` — result of: returns the shared engine-variable name used for stack category variable in the inventory stack consolidation subsystem.

Side effects:

- None directly observable beyond calls listed below.

Called by:

- `scripts/inventory_runtime/inv_overhaul_inventory_stack_consolidation.lua :: NormalizeQuickslots`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `StackOccurrenceVariable(slot: int) -> string`

Source: `scripts/inventory_runtime/inv_overhaul_inventory_stack_consolidation.lua`

Purpose: Returns the shared engine-variable name used for stack occurrence variable in the inventory stack consolidation subsystem.

Parameters:

- `slot: int` — slot index or encoded slot target interpreted by this function.

Returns:

- `string` — result of: returns the shared engine-variable name used for stack occurrence variable in the inventory stack consolidation subsystem.

Side effects:

- None directly observable beyond calls listed below.

Called by:

- `scripts/inventory_runtime/inv_overhaul_inventory_stack_consolidation.lua :: NormalizeQuickslots`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `StackDepletedVariable(slot: int) -> string`

Source: `scripts/inventory_runtime/inv_overhaul_inventory_stack_consolidation.lua`

Purpose: Returns whether variable for stack in the inventory stack consolidation subsystem.

Parameters:

- `slot: int` — slot index or encoded slot target interpreted by this function.

Returns:

- `string` — result of: returns whether variable for stack in the inventory stack consolidation subsystem.

Side effects:

- None directly observable beyond calls listed below.

Called by:

- `scripts/inventory_runtime/inv_overhaul_inventory_stack_consolidation.lua :: NormalizeQuickslots`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `NormalizeQuickslots(category: int, itemID: int) -> void`

Source: `scripts/inventory_runtime/inv_overhaul_inventory_stack_consolidation.lua`

Purpose: Normalizes quickslots in the inventory stack consolidation subsystem.

Parameters:

- `category: int` — zero-based engine inventory category identifier.
- `itemID: int` — engine item or callback identifier interpreted by this function.

Returns:

None.

Side effects:

- Writes shared engine variable(s): `computed value`.
- Invokes engine/native operations: `native.SetVariable`.

Called by:

- `scripts/inventory_runtime/inv_overhaul_inventory_stack_consolidation.lua :: Merge`

Calls:

- `native.GetVariable`
- `StackCategoryVariable`
- `StackItemVariable`
- `native.SetVariable`
- `StackOccurrenceVariable`
- `StackDepletedVariable`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `GetOtherAmount(player: object, category: int, keepIndex: int, itemID: int) -> int`

Source: `scripts/inventory_runtime/inv_overhaul_inventory_stack_consolidation.lua`

Purpose: Returns other amount in the inventory stack consolidation subsystem.

Parameters:

- `player: object` — player engine container/object used for inventory reads or mutations.
- `category: int` — zero-based engine inventory category identifier.
- `keepIndex: int` — zero-based entry index in the relevant engine container/category.
- `itemID: int` — engine item or callback identifier interpreted by this function.

Returns:

- `number` (integer) — result of: returns other amount in the inventory stack consolidation subsystem.

Side effects:

- None directly observable beyond calls listed below.

Called by:

- `scripts/inventory_runtime/inv_overhaul_inventory_stack_consolidation.lua :: Merge`

Calls:

- `player.GetItemCount`
- `player.GetItem`
- `candidate.GetItemID`
- `player.GetItemAmount`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `Merge(player: object, category: int, keepIndex: int, itemID: int, count: int) -> bool`

Source: `scripts/inventory_runtime/inv_overhaul_inventory_stack_consolidation.lua`

Purpose: Merges inventory stack consolidation in the inventory stack consolidation subsystem.

Parameters:

- `player: object` — player engine container/object used for inventory reads or mutations.
- `category: int` — zero-based engine inventory category identifier.
- `keepIndex: int` — zero-based entry index in the relevant engine container/category.
- `itemID: int` — engine item or callback identifier interpreted by this function.
- `count: int` — value interpreted according to the function purpose; no narrower contract is established by current code.

Returns:

- `boolean` — result of: merges inventory stack consolidation in the inventory stack consolidation subsystem.

Side effects:

- Invokes engine/native operations: `native.Trace`.
- May mutate engine/UI objects through: `player.SetItemAmount`, `player.RemoveItem`.

Called by:

- `scripts/inventory_runtime/inv_overhaul_inventory_stack_consolidation.lua :: Consolidate`

Calls:

- `player.GetItemAmount`
- `player.GetItem`
- `candidate.GetItemID`
- `player.SetItemAmount`
- `native.Trace`
- `player.RemoveItem`
- `GetOtherAmount`
- `NormalizeQuickslots`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `Consolidate(categoryCounts: object) -> bool`

Source: `scripts/inventory_runtime/inv_overhaul_inventory_stack_consolidation.lua`

Purpose: Consolidates inventory stack consolidation in the inventory stack consolidation subsystem.

Parameters:

- `categoryCounts: object` — integer vector indexed by zero-based inventory category; each element is the observed engine entry count.

Returns:

- `boolean` — result of: consolidates inventory stack consolidation in the inventory stack consolidation subsystem.

Side effects:

- Writes shared engine variable(s): `"inv_overhaul_inventory_reorder_generation"`.
- Invokes engine/native operations: `native.SetVariable`.
- May mutate engine/UI objects through: `categoryCounts.set`.

Called by:

- `scripts/inventory_runtime/inv_overhaul_inventory_guard.lua :: ConsolidatePlayerStacks`

Calls:

- `inv_overhaul_inventory_overflow.OverflowGetPlayer`
- `player.GetItemCount`
- `player.GetItem`
- `item.GetItemID`
- `native.GetInvItemMaxStackSize`
- `Merge`
- `categoryCounts.set`
- `inv_overhaul_inventory_overflow.AdvanceContentGeneration`
- `native.GetVariable`
- `native.SetVariable`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.


## Internal API

No additional maintask helpers.

## Events / callbacks

No engine callbacks; this is an imported module.

## Important constants

- `InventoryStackCategoryCount: int = 5` — fixed limit/count for inventory stack category count.
- `InventoryStackQuickslotCount: int = 10` — fixed limit/count for inventory stack quickslot count.

## Architectural notes

- No additional module-specific issue identified beyond repository-wide shared-variable and compiler-visible API constraints.
