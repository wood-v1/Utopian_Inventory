# Inventory Overflow

## Source

`scripts/inventory_runtime/inv_overhaul_inventory_overflow.lua`

DSL unit: `module inv_overhaul_inventory_overflow`

## Responsibility

Counts unequipped backpack entries and drops excess items near the player without treating equipped items as capacity usage.

## Dependencies

- No local DSL imports.
- Pathologic native API — engine state, object access, persistence variables, UI messaging, timing, or rendering as listed per function.

## Used by

- `scripts/inventory_runtime/inv_overhaul_inventory_guard.lua`
- `scripts/inventory_runtime/inv_overhaul_inventory_snapshot_seed.lua`
- `scripts/inventory_runtime/inv_overhaul_inventory_stack_consolidation.lua`

## State

No module/task-level mutable state.

## Public API

All functions below are compiler-visible when the module is imported; the DSL has no private declaration.

### `OverflowGetPlayer() -> object`

Source: `scripts/inventory_runtime/inv_overhaul_inventory_overflow.lua`

Purpose: Returns player for overflow in the inventory overflow subsystem.

Parameters:

None.

Returns:

- `object` — result of: returns player for overflow in the inventory overflow subsystem.

Side effects:

- None directly observable beyond calls listed below.

Called by:

- `scripts/inventory_runtime/inv_overhaul_inventory_overflow.lua :: OverflowIsEquippedItem`
- `scripts/inventory_runtime/inv_overhaul_inventory_overflow.lua :: OverflowGetBackpackItemCount`
- `scripts/inventory_runtime/inv_overhaul_inventory_overflow.lua :: DropItem`
- `scripts/inventory_runtime/inv_overhaul_inventory_snapshot_seed.lua :: InitializeIfMissing`
- `scripts/inventory_runtime/inv_overhaul_inventory_stack_consolidation.lua :: Consolidate`

Calls:

- `native.self`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `OverflowIsEquippedItem(category: int, index: int) -> bool`

Source: `scripts/inventory_runtime/inv_overhaul_inventory_overflow.lua`

Purpose: Returns whether equipped item for overflow in the inventory overflow subsystem.

Parameters:

- `category: int` — zero-based engine inventory category identifier.
- `index: int` — zero-based entry index in the relevant engine container/category.

Returns:

- `boolean` — result of: returns whether equipped item for overflow in the inventory overflow subsystem.

Side effects:

- May mutate engine/UI objects through: `player.IsItemSelected`.

Called by:

- `scripts/inventory_runtime/inv_overhaul_inventory_overflow.lua :: OverflowGetBackpackItemCount`
- `scripts/inventory_runtime/inv_overhaul_inventory_overflow.lua :: DropItem`
- `scripts/inventory_runtime/inv_overhaul_inventory_snapshot_seed.lua :: InitializeIfMissing`

Calls:

- `OverflowGetPlayer`
- `player.IsItemSelected`
- `player.GetItem`
- `item.GetItemID`
- `native.HasInvItemProperty`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `OverflowGetBackpackItemCount() -> int`

Source: `scripts/inventory_runtime/inv_overhaul_inventory_overflow.lua`

Purpose: Returns backpack item count for overflow in the inventory overflow subsystem.

Parameters:

None.

Returns:

- `number` (integer) — result of: returns backpack item count for overflow in the inventory overflow subsystem.

Side effects:

- None directly observable beyond calls listed below.

Called by:

- `scripts/inventory_runtime/inv_overhaul_inventory_guard.lua :: GetBackpackItemCount`
- `scripts/inventory_runtime/inv_overhaul_inventory_overflow.lua :: ShouldQueue`

Calls:

- `OverflowGetPlayer`
- `player.GetItemCount`
- `OverflowIsEquippedItem`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `ShouldQueue(allowedSlots: int, previousCategoryCount: int, currentCategoryCount: int) -> bool`

Source: `scripts/inventory_runtime/inv_overhaul_inventory_overflow.lua`

Purpose: Returns whether queue in the inventory overflow subsystem.

Parameters:

- `allowedSlots: int` — slot index or encoded slot target interpreted by this function.
- `previousCategoryCount: int` — zero-based engine inventory category identifier.
- `currentCategoryCount: int` — zero-based engine inventory category identifier.

Returns:

- `boolean` — result of: returns whether queue in the inventory overflow subsystem.

Side effects:

- None directly observable beyond calls listed below.

Called by:

- `scripts/inventory_runtime/inv_overhaul_inventory_guard.lua :: OnInventoryAddItem`

Calls:

- `OverflowGetBackpackItemCount`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `DropItem(index: int, itemID: int, category: int) -> bool`

Source: `scripts/inventory_runtime/inv_overhaul_inventory_overflow.lua`

Purpose: Drops item in the inventory overflow subsystem.

Parameters:

- `index: int` — zero-based entry index in the relevant engine container/category.
- `itemID: int` — engine item or callback identifier interpreted by this function.
- `category: int` — zero-based engine inventory category identifier.

Returns:

- `boolean` — result of: drops item in the inventory overflow subsystem.

Side effects:

- May mutate engine/UI objects through: `player.DropItems`, `player.RemoveItem`.

Called by:

- `scripts/inventory_runtime/inv_overhaul_inventory_guard.lua :: DropOverflowItem`

Calls:

- `OverflowGetPlayer`
- `player.GetItemCount`
- `OverflowIsEquippedItem`
- `player.GetItem`
- `player.GetItemAmount`
- `item.GetItemID`
- `player.DropItems`
- `player.RemoveItem`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `AdvanceContentGeneration() -> void`

Source: `scripts/inventory_runtime/inv_overhaul_inventory_overflow.lua`

Purpose: Advances content generation in the inventory overflow subsystem.

Parameters:

None.

Returns:

None.

Side effects:

- Writes shared engine variable(s): `"inv_overhaul_inventory_content_generation"`.
- Invokes engine/native operations: `native.SetVariable`.

Called by:

- `scripts/inventory_runtime/inv_overhaul_inventory_guard.lua :: AdvanceContentGeneration`
- `scripts/inventory_runtime/inv_overhaul_inventory_stack_consolidation.lua :: Consolidate`

Calls:

- `native.GetVariable`
- `native.SetVariable`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.


## Internal API

No additional maintask helpers.

## Events / callbacks

No engine callbacks; this is an imported module.

## Important constants

- `InventoryOverflowWeaponCategory: int = 0` — engine inventory category value for inventory overflow weapon category.
- `InventoryOverflowClothesCategory: int = 1` — engine inventory category value for inventory overflow clothes category.
- `InventoryOverflowCategoryCount: int = 5` — fixed limit/count for inventory overflow category count.

## Architectural notes

- No additional module-specific issue identified beyond repository-wide shared-variable and compiler-visible API constraints.
