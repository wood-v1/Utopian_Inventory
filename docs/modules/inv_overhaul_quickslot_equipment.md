# Quickslot Equipment

## Source

`scripts/quickslots/inv_overhaul_quickslot_equipment.lua`

DSL unit: `module inv_overhaul_quickslot_equipment`

## Responsibility

Applies the quickslot equipment toggle policy while preserving inventory layout hints.

## Dependencies

- `inv_overhaul_quickslot_activation` — Provides shared persistent quickslot activation state, binding lookup, feedback, and equipment-removal hints.
- Pathologic native API — engine state, object access, persistence variables, UI messaging, timing, or rendering as listed per function.

## Used by

- `scripts/quickslots/inv_overhaul_quickslots.lua`

## State

No module/task-level mutable state.

## Public API

All functions below are compiler-visible when the module is imported; the DSL has no private declaration.

### `EquipmentPolicyToggle(category: int, index: int, itemID: int, occurrence: int, selected: bool) -> void`

Source: `scripts/quickslots/inv_overhaul_quickslot_equipment.lua`

Purpose: Toggles equipment policy in the quickslot equipment subsystem.

Parameters:

- `category: int` — zero-based engine inventory category identifier.
- `index: int` — zero-based entry index in the relevant engine container/category.
- `itemID: int` — engine item or callback identifier interpreted by this function.
- `occurrence: int` — zero-based occurrence of an item ID within its category.
- `selected: bool` — behavior flag interpreted by this function.

Returns:

None.

Side effects:

- Writes shared engine variable(s): `"inv_overhaul_quickslot_weapon_item"`, `"inv_overhaul_quickslot_weapon_occurrence"`.
- Invokes engine/native operations: `native.SetVariable`, `native.Trace`.
- May mutate engine/UI objects through: `player.ApplyEffect`, `player.SelectItem`.

Called by:

- `scripts/quickslots/inv_overhaul_quickslots.lua :: ToggleEquipment`

Calls:

- `inv_overhaul_quickslot_activation.ActivationGetPlayer`
- `native.SetVariable`
- `player.ApplyEffect`
- `native.Trace`
- `inv_overhaul_quickslot_activation.ActivationGetBackpackItemCount`
- `inv_overhaul_quickslot_activation.ShowMessage`
- `player.SelectItem`
- `inv_overhaul_quickslot_activation.MarkInventoryChanged`
- `inv_overhaul_quickslot_activation.ShowFeedback`
- `inv_overhaul_quickslot_activation.PublishEquipmentRemovalHint`
- `native.GetInvItemProperty`
- `player.GetItemCount`
- `… and 5 more`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.


## Internal API

No additional maintask helpers.

## Events / callbacks

No engine callbacks; this is an imported module.

## Important constants

- `QuickslotEquipmentWeaponCategory: int = 0` — engine inventory category value for quickslot equipment weapon category.
- `QuickslotEquipmentCapacity: int = 56` — fixed limit/count for quickslot equipment capacity.
- `QuickslotEquipmentFullText: int = 1400` — named behavior/layout value for quickslot equipment full text.
- `QuickslotEquipmentMissingText: int = 1405` — named behavior/layout value for quickslot equipment missing text.

## Architectural notes

- No additional module-specific issue identified beyond repository-wide shared-variable and compiler-visible API constraints.
