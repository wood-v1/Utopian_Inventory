# Quickslot Hands

## Source

`scripts/quickslots/inv_overhaul_quickslot_hands.lua`

DSL unit: `module inv_overhaul_quickslot_hands`

## Responsibility

Requests hand-combat activation for the quickslot runtime.

## Dependencies

- `inv_overhaul_quickslot_activation` — Provides shared persistent quickslot activation state, binding lookup, feedback, and equipment-removal hints.
- Pathologic native API — engine state, object access, persistence variables, UI messaging, timing, or rendering as listed per function.

## Used by

- `scripts/quickslots/inv_overhaul_quickslots.lua`

## State

No module/task-level mutable state.

## Public API

All functions below are compiler-visible when the module is imported; the DSL has no private declaration.

### `AdjustBindingsAfterDrop(itemID: int, occurrence: int) -> void`

Source: `scripts/quickslots/inv_overhaul_quickslot_hands.lua`

Purpose: Adjusts bindings after drop in the quickslot hands subsystem.

Parameters:

- `itemID: int` — engine item or callback identifier interpreted by this function.
- `occurrence: int` — zero-based occurrence of an item ID within its category.

Returns:

None.

Side effects:

- Writes shared engine variable(s): `computed value`.
- Invokes engine/native operations: `native.SetVariable`.

Called by:

- `scripts/quickslots/inv_overhaul_quickslots.lua :: AdjustBindingsAfterWeaponDrop`

Calls:

- `native.GetVariable`
- `inv_overhaul_quickslot_activation.ActivationCategoryVariable`
- `inv_overhaul_quickslot_activation.ActivationItemVariable`
- `inv_overhaul_quickslot_activation.ActivationOccurrenceVariable`
- `inv_overhaul_quickslot_activation.ClearBinding`
- `native.SetVariable`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.


## Internal API

No additional maintask helpers.

## Events / callbacks

No engine callbacks; this is an imported module.

## Important constants

- `QuickslotHandsWeaponCategory: int = 0` — engine inventory category value for quickslot hands weapon category.
- `QuickslotHandsSlotCount: int = 10` — fixed limit/count for quickslot hands slot count.

## Architectural notes

- No additional module-specific issue identified beyond repository-wide shared-variable and compiler-visible API constraints.
