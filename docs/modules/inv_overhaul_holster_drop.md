# Holster Drop

## Source

`scripts/compatibility/quickslots/inv_overhaul_holster_drop.lua`

DSL unit: `maintask InvOverhaulHolsterDropEffect`

## Responsibility

Retained compatibility effect that delays and completes a weapon holster/drop request.

This source is compatibility-only. Active packages must not import it.

## Dependencies

- No local DSL imports.
- Pathologic native API — engine state, object access, persistence variables, UI messaging, timing, or rendering as listed per function.

## Used by

- No local import or direct runtime reference was resolved. It may be retained for external/save compatibility.

## State

No module/task-level mutable state.

## Public API

No importable module API. Runtime entry points are documented under Events / callbacks.

## Internal API

### `GetItemVariable(slot: int) -> string`

Source: `scripts/compatibility/quickslots/inv_overhaul_holster_drop.lua`

Purpose: Returns item variable in the holster drop subsystem.

Parameters:

- `slot: int` — 1-based quickslot number.

Returns:

- `string` — result of: returns item variable in the holster drop subsystem.

Side effects:

- None directly observable beyond calls listed below.

Called by:

- `scripts/compatibility/quickslots/inv_overhaul_holster_drop.lua :: AdjustBindings`

Notes / invariants:

- Maintask helper; callable within its task unless the engine invokes it by a documented callback name.

### `GetCategoryVariable(slot: int) -> string`

Source: `scripts/compatibility/quickslots/inv_overhaul_holster_drop.lua`

Purpose: Returns category variable in the holster drop subsystem.

Parameters:

- `slot: int` — 1-based quickslot number.

Returns:

- `string` — result of: returns category variable in the holster drop subsystem.

Side effects:

- None directly observable beyond calls listed below.

Called by:

- `scripts/compatibility/quickslots/inv_overhaul_holster_drop.lua :: AdjustBindings`

Notes / invariants:

- Maintask helper; callable within its task unless the engine invokes it by a documented callback name.

### `GetOccurrenceVariable(slot: int) -> string`

Source: `scripts/compatibility/quickslots/inv_overhaul_holster_drop.lua`

Purpose: Returns occurrence variable in the holster drop subsystem.

Parameters:

- `slot: int` — 1-based quickslot number.

Returns:

- `string` — result of: returns occurrence variable in the holster drop subsystem.

Side effects:

- None directly observable beyond calls listed below.

Called by:

- `scripts/compatibility/quickslots/inv_overhaul_holster_drop.lua :: AdjustBindings`

Notes / invariants:

- Maintask helper; callable within its task unless the engine invokes it by a documented callback name.

### `GetDepletedVariable(slot: int) -> string`

Source: `scripts/compatibility/quickslots/inv_overhaul_holster_drop.lua`

Purpose: Returns depleted variable in the holster drop subsystem.

Parameters:

- `slot: int` — 1-based quickslot number.

Returns:

- `string` — result of: returns depleted variable in the holster drop subsystem.

Side effects:

- None directly observable beyond calls listed below.

Called by:

- `scripts/compatibility/quickslots/inv_overhaul_holster_drop.lua :: AdjustBindings`

Notes / invariants:

- Maintask helper; callable within its task unless the engine invokes it by a documented callback name.

### `MarkInventoryChanged() -> void`

Source: `scripts/compatibility/quickslots/inv_overhaul_holster_drop.lua`

Purpose: Marks inventory changed in the holster drop subsystem.

Parameters:

None.

Returns:

None.

Side effects:

- Writes shared engine variable(s): `"inv_overhaul_inventory_reorder_generation"`.
- Invokes engine/native operations: `native.SetVariable`.

Called by:

- `scripts/compatibility/quickslots/inv_overhaul_holster_drop.lua :: init`

Calls:

- `native.GetVariable`
- `native.SetVariable`

Notes / invariants:

- Maintask helper; callable within its task unless the engine invokes it by a documented callback name.

### `AdjustBindings(itemID: int, occurrence: int) -> void`

Source: `scripts/compatibility/quickslots/inv_overhaul_holster_drop.lua`

Purpose: Adjusts bindings in the holster drop subsystem.

Parameters:

- `itemID: int` — engine item or callback identifier interpreted by this function.
- `occurrence: int` — zero-based occurrence of an item ID within its category.

Returns:

None.

Side effects:

- Writes shared engine variable(s): `computed value`.
- Invokes engine/native operations: `native.SetVariable`.

Called by:

- `scripts/compatibility/quickslots/inv_overhaul_holster_drop.lua :: init`

Calls:

- `native.GetVariable`
- `GetCategoryVariable`
- `GetItemVariable`
- `GetOccurrenceVariable`
- `native.SetVariable`
- `GetDepletedVariable`

Notes / invariants:

- Maintask helper; callable within its task unless the engine invokes it by a documented callback name.


## Events / callbacks

### `init() -> void`

Source: `scripts/compatibility/quickslots/inv_overhaul_holster_drop.lua`

Purpose: Initializes the holster drop runtime and establishes its starting state and engine/UI integration.

Parameters:

None.

Returns:

None.

Side effects:

- Writes shared engine variable(s): `"inv_overhaul_quickslot_active_weapon"`.
- Invokes engine/native operations: `native.Trace`, `native.SetVariable`.
- May mutate engine/UI objects through: `player.IsItemSelected`, `player.DropItems`, `player.SelectItem`, `player.RemoveItem`.

Called by:

- No in-repository caller was resolved; this may be an engine/XML callback or a conventionally public helper.

Calls:

- `native.self`
- `player.GetItemCount`
- `player.IsItemSelected`
- `player.GetItem`
- `item.GetItemID`
- `previousItem.GetItemID`
- `native.Trace`
- `currentItem.GetItemID`
- `player.DropItems`
- `player.SelectItem`
- `player.RemoveItem`
- `AdjustBindings`
- `… and 2 more`

Notes / invariants:

- Maintask helper; callable within its task unless the engine invokes it by a documented callback name.


## Important constants

- `c_iCWeapon: int = 0` — named behavior/layout value for cweapon.
- `c_iQuickslotCount: int = 10` — fixed limit/count for quickslot count.

## Architectural notes

- No additional module-specific issue identified beyond repository-wide shared-variable and compiler-visible API constraints.
