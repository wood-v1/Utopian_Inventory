# Inventory Drop

## Source

`scripts/player_inventory/inv_overhaul_inventory_drop.lua`

DSL unit: `module inv_overhaul_inventory_drop`

## Responsibility

Drops a player inventory entry into the world through the engine container API.

## Dependencies

- `inv_overhaul_inventory_sounds` — Plays feedback after a successful world drop.

- `inv_overhaul_inventory_items` — Builds the canonical projection of unequipped player items into backpack ordinals and cached category/index references.
- Pathologic native API — engine state, object access, persistence variables, UI messaging, timing, or rendering as listed per function.

## Used by

- `scripts/player_inventory/inv_overhaul_inventory_controller.lua`

## State

No module/task-level mutable state.

## Public API

All functions below are compiler-visible when the module is imported; the DSL has no private declaration.

### `Slot(category: int, index: int, requestedAmount: int) -> bool`

Source: `scripts/player_inventory/inv_overhaul_inventory_drop.lua`

Purpose: Drops the requested amount of a player inventory entry into the world.

Parameters:

- `category: int` — zero-based engine inventory category identifier.
- `index: int` — zero-based entry index in the relevant engine container/category.
- `requestedAmount: int` — value interpreted according to the function purpose; no narrower contract is established by current code.

Returns:

- `boolean` — result of: drops the requested amount of a player inventory entry into the world.

Side effects:

- Invokes engine/native operations: `native.Trace`, `native.SetPlayerHandsItem`.
- May mutate engine/UI objects through: `container.AddItem`, `playerContainer.IsItemSelected`, `playerContainer.RemoveItem`.

Called by:

- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: PlayerControllerHandleModifiedDrop`
- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: FinishLeftAction`

Calls:

- `native.GetContainer`
- `native.Trace`
- `inv_overhaul_inventory_items.ItemsGetPlayerContainer`
- `playerContainer.GetItem`
- `playerContainer.GetItemAmount`
- `container.AddItem`
- `playerContainer.IsItemSelected`
- `native.SetPlayerHandsItem`
- `playerContainer.RemoveItem`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.


## Internal API

No additional maintask helpers.

## Events / callbacks

No engine callbacks; this is an imported module.

## Important constants

- `WeaponCategory: int = 0` — engine inventory category value for weapon category.

## Architectural notes

- No additional module-specific issue identified beyond repository-wide shared-variable and compiler-visible API constraints.
