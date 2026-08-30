# Quickslot Activation

## Source

`scripts/quickslots/inv_overhaul_quickslot_activation.lua`

DSL unit: `module inv_overhaul_quickslot_activation`

## Responsibility

Provides shared persistent quickslot activation state, binding lookup, feedback, and equipment-removal hints.

## Dependencies

- No local DSL imports.
- Pathologic native API — engine state, object access, persistence variables, UI messaging, timing, or rendering as listed per function.

## Used by

- `scripts/quickslots/inv_overhaul_quickslot_equipment.lua`
- `scripts/quickslots/inv_overhaul_quickslot_hands.lua`
- `scripts/quickslots/inv_overhaul_quickslots.lua`

## State

No module/task-level mutable state.

## Public API

All functions below are compiler-visible when the module is imported; the DSL has no private declaration.

### `ActivationGetPlayer() -> object`

Source: `scripts/quickslots/inv_overhaul_quickslot_activation.lua`

Purpose: Returns player for activation in the quickslot activation subsystem.

Parameters:

None.

Returns:

- `object` — result of: returns player for activation in the quickslot activation subsystem.

Side effects:

- None directly observable beyond calls listed below.

Called by:

- `scripts/quickslots/inv_overhaul_quickslot_activation.lua :: ActivationIsEquippedItem`
- `scripts/quickslots/inv_overhaul_quickslot_activation.lua :: ActivationGetBackpackItemCount`
- `scripts/quickslots/inv_overhaul_quickslot_activation.lua :: ActivationGetBackpackOrdinal`
- `scripts/quickslots/inv_overhaul_quickslot_activation.lua :: FindBoundItemIndex`
- `scripts/quickslots/inv_overhaul_quickslot_equipment.lua :: EquipmentPolicyToggle`
- `scripts/quickslots/inv_overhaul_quickslots.lua :: GetPlayer`

Calls:

- `native.self`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `ActivationItemVariable(slot: int) -> string`

Source: `scripts/quickslots/inv_overhaul_quickslot_activation.lua`

Purpose: Returns the shared engine-variable name used for activation item variable in the quickslot activation subsystem.

Parameters:

- `slot: int` — 1-based quickslot number.

Returns:

- `string` — result of: returns the shared engine-variable name used for activation item variable in the quickslot activation subsystem.

Side effects:

- None directly observable beyond calls listed below.

Called by:

- `scripts/quickslots/inv_overhaul_quickslot_activation.lua :: ClearBinding`
- `scripts/quickslots/inv_overhaul_quickslot_hands.lua :: AdjustBindingsAfterDrop`
- `scripts/quickslots/inv_overhaul_quickslots.lua :: GetItemVariable`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `ActivationCategoryVariable(slot: int) -> string`

Source: `scripts/quickslots/inv_overhaul_quickslot_activation.lua`

Purpose: Returns the shared engine-variable name used for activation category variable in the quickslot activation subsystem.

Parameters:

- `slot: int` — 1-based quickslot number.

Returns:

- `string` — result of: returns the shared engine-variable name used for activation category variable in the quickslot activation subsystem.

Side effects:

- None directly observable beyond calls listed below.

Called by:

- `scripts/quickslots/inv_overhaul_quickslot_activation.lua :: ClearBinding`
- `scripts/quickslots/inv_overhaul_quickslot_hands.lua :: AdjustBindingsAfterDrop`
- `scripts/quickslots/inv_overhaul_quickslots.lua :: GetCategoryVariable`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `ActivationOccurrenceVariable(slot: int) -> string`

Source: `scripts/quickslots/inv_overhaul_quickslot_activation.lua`

Purpose: Returns the shared engine-variable name used for activation occurrence variable in the quickslot activation subsystem.

Parameters:

- `slot: int` — 1-based quickslot number.

Returns:

- `string` — result of: returns the shared engine-variable name used for activation occurrence variable in the quickslot activation subsystem.

Side effects:

- None directly observable beyond calls listed below.

Called by:

- `scripts/quickslots/inv_overhaul_quickslot_activation.lua :: ClearBinding`
- `scripts/quickslots/inv_overhaul_quickslot_activation.lua :: InitializePersistentState`
- `scripts/quickslots/inv_overhaul_quickslot_hands.lua :: AdjustBindingsAfterDrop`
- `scripts/quickslots/inv_overhaul_quickslots.lua :: GetOccurrenceVariable`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `ActivationDepletedVariable(slot: int) -> string`

Source: `scripts/quickslots/inv_overhaul_quickslot_activation.lua`

Purpose: Returns whether variable for activation in the quickslot activation subsystem.

Parameters:

- `slot: int` — 1-based quickslot number.

Returns:

- `string` — result of: returns whether variable for activation in the quickslot activation subsystem.

Side effects:

- None directly observable beyond calls listed below.

Called by:

- `scripts/quickslots/inv_overhaul_quickslot_activation.lua :: ClearBinding`
- `scripts/quickslots/inv_overhaul_quickslot_activation.lua :: InitializePersistentState`
- `scripts/quickslots/inv_overhaul_quickslots.lua :: GetDepletedVariable`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `ClearBinding(slot: int) -> void`

Source: `scripts/quickslots/inv_overhaul_quickslot_activation.lua`

Purpose: Clears binding in the quickslot activation subsystem.

Parameters:

- `slot: int` — 1-based quickslot number.

Returns:

None.

Side effects:

- Writes shared engine variable(s): `computed value`.
- Invokes engine/native operations: `native.SetVariable`.

Called by:

- `scripts/quickslots/inv_overhaul_quickslot_hands.lua :: AdjustBindingsAfterDrop`
- `scripts/quickslots/inv_overhaul_quickslots.lua :: ClearBinding`

Calls:

- `native.SetVariable`
- `ActivationItemVariable`
- `ActivationCategoryVariable`
- `ActivationOccurrenceVariable`
- `ActivationDepletedVariable`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `ShowMessage(textID: int) -> void`

Source: `scripts/quickslots/inv_overhaul_quickslot_activation.lua`

Purpose: Shows message in the quickslot activation subsystem.

Parameters:

- `textID: int` — value interpreted according to the function purpose; no narrower contract is established by current code.

Returns:

None.

Side effects:

- Invokes engine/native operations: `native.CreateIntVector`, `native.SendWorldWndMessage`.
- May mutate engine/UI objects through: `data.add`.

Called by:

- `scripts/quickslots/inv_overhaul_quickslot_equipment.lua :: EquipmentPolicyToggle`
- `scripts/quickslots/inv_overhaul_quickslots.lua :: ShowMessage`

Calls:

- `native.CreateIntVector`
- `data.add`
- `native.SendWorldWndMessage`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `ShowFeedback(itemID: int) -> void`

Source: `scripts/quickslots/inv_overhaul_quickslot_activation.lua`

Purpose: Shows feedback in the quickslot activation subsystem.

Parameters:

- `itemID: int` — engine item or callback identifier interpreted by this function.

Returns:

None.

Side effects:

- Invokes engine/native operations: `native.CreateIntVector`, `native.SendWorldWndMessage`.
- May mutate engine/UI objects through: `data.add`.

Called by:

- `scripts/quickslots/inv_overhaul_quickslot_equipment.lua :: EquipmentPolicyToggle`
- `scripts/quickslots/inv_overhaul_quickslots.lua :: ShowFeedback`

Calls:

- `native.CreateIntVector`
- `data.add`
- `native.SendWorldWndMessage`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `MarkInventoryChanged() -> void`

Source: `scripts/quickslots/inv_overhaul_quickslot_activation.lua`

Purpose: Marks inventory changed in the quickslot activation subsystem.

Parameters:

None.

Returns:

None.

Side effects:

- Writes shared engine variable(s): `"inv_overhaul_inventory_reorder_generation"`.
- Invokes engine/native operations: `native.SetVariable`.

Called by:

- `scripts/quickslots/inv_overhaul_quickslot_equipment.lua :: EquipmentPolicyToggle`
- `scripts/quickslots/inv_overhaul_quickslots.lua :: MarkInventoryChanged`

Calls:

- `native.GetVariable`
- `native.SetVariable`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `ActivationIsEquippedItem(category: int, index: int) -> bool`

Source: `scripts/quickslots/inv_overhaul_quickslot_activation.lua`

Purpose: Returns whether equipped item for activation in the quickslot activation subsystem.

Parameters:

- `category: int` — zero-based engine inventory category identifier.
- `index: int` — zero-based entry index in the relevant engine container/category.

Returns:

- `boolean` — result of: returns whether equipped item for activation in the quickslot activation subsystem.

Side effects:

- May mutate engine/UI objects through: `player.IsItemSelected`.

Called by:

- `scripts/quickslots/inv_overhaul_quickslot_activation.lua :: ActivationGetBackpackItemCount`
- `scripts/quickslots/inv_overhaul_quickslot_activation.lua :: ActivationGetBackpackOrdinal`

Calls:

- `ActivationGetPlayer`
- `player.IsItemSelected`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `ActivationGetBackpackItemCount() -> int`

Source: `scripts/quickslots/inv_overhaul_quickslot_activation.lua`

Purpose: Returns backpack item count for activation in the quickslot activation subsystem.

Parameters:

None.

Returns:

- `number` (integer) — result of: returns backpack item count for activation in the quickslot activation subsystem.

Side effects:

- None directly observable beyond calls listed below.

Called by:

- `scripts/quickslots/inv_overhaul_quickslot_activation.lua :: PublishRemovalHint`
- `scripts/quickslots/inv_overhaul_quickslot_activation.lua :: PublishEquipmentRemovalHint`
- `scripts/quickslots/inv_overhaul_quickslot_equipment.lua :: EquipmentPolicyToggle`

Calls:

- `ActivationGetPlayer`
- `player.GetItemCount`
- `ActivationIsEquippedItem`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `ActivationGetBackpackOrdinal(targetCategory: int, targetIndex: int) -> int`

Source: `scripts/quickslots/inv_overhaul_quickslot_activation.lua`

Purpose: Returns backpack ordinal for activation in the quickslot activation subsystem.

Parameters:

- `targetCategory: int` — zero-based engine inventory category identifier.
- `targetIndex: int` — zero-based entry index in the relevant engine container/category.

Returns:

- `number` (integer) — result of: returns backpack ordinal for activation in the quickslot activation subsystem.

Side effects:

- None directly observable beyond calls listed below.

Called by:

- `scripts/quickslots/inv_overhaul_quickslot_activation.lua :: PublishRemovalHint`
- `scripts/quickslots/inv_overhaul_quickslot_activation.lua :: PublishEquipmentRemovalHint`

Calls:

- `ActivationGetPlayer`
- `player.GetItemCount`
- `ActivationIsEquippedItem`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `PublishRemovalHint(category: int, index: int) -> void`

Source: `scripts/quickslots/inv_overhaul_quickslot_activation.lua`

Purpose: Publishes removal hint in the quickslot activation subsystem.

Parameters:

- `category: int` — zero-based engine inventory category identifier.
- `index: int` — zero-based entry index in the relevant engine container/category.

Returns:

None.

Side effects:

- Writes shared engine variable(s): `"inv_overhaul_inventory_removed_ordinal_hint"`, `"inv_overhaul_inventory_removed_ordinal_old_count"`, `"inv_overhaul_inventory_removed_ordinal_valid"`.
- Invokes engine/native operations: `native.SetVariable`.

Called by:

- `scripts/quickslots/inv_overhaul_quickslots.lua :: PublishRemovalHint`

Calls:

- `ActivationGetBackpackOrdinal`
- `native.SetVariable`
- `ActivationGetBackpackItemCount`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `PublishEquipmentRemovalHint(category: int, index: int) -> void`

Source: `scripts/quickslots/inv_overhaul_quickslot_activation.lua`

Purpose: Publishes equipment removal hint in the quickslot activation subsystem.

Parameters:

- `category: int` — zero-based engine inventory category identifier.
- `index: int` — zero-based entry index in the relevant engine container/category.

Returns:

None.

Side effects:

- Writes shared engine variable(s): `"inv_overhaul_inventory_equipment_removal_ordinal_" + queueCount`, `"inv_overhaul_inventory_equipment_removal_old_count_" + queueCount`, `"inv_overhaul_inventory_equipment_removal_count"`, `"inv_overhaul_inventory_removed_ordinal_valid"`.
- Invokes engine/native operations: `native.SetVariable`, `native.Trace`.

Called by:

- `scripts/quickslots/inv_overhaul_quickslot_equipment.lua :: EquipmentPolicyToggle`

Calls:

- `ActivationGetBackpackOrdinal`
- `ActivationGetBackpackItemCount`
- `native.GetVariable`
- `native.SetVariable`
- `native.Trace`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `CancelLastEquipmentRemovalHint() -> void`

Source: `scripts/quickslots/inv_overhaul_quickslot_activation.lua`

Purpose: Cancels last equipment removal hint in the quickslot activation subsystem.

Parameters:

None.

Returns:

None.

Side effects:

- Writes shared engine variable(s): `"inv_overhaul_inventory_equipment_removal_count"`.
- Invokes engine/native operations: `native.SetVariable`.

Called by:

- `scripts/quickslots/inv_overhaul_quickslot_equipment.lua :: EquipmentPolicyToggle`

Calls:

- `native.GetVariable`
- `native.SetVariable`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `IsEquippable(category: int, itemID: int) -> bool`

Source: `scripts/quickslots/inv_overhaul_quickslot_activation.lua`

Purpose: Returns whether equippable in the quickslot activation subsystem.

Parameters:

- `category: int` — zero-based engine inventory category identifier.
- `itemID: int` — engine item or callback identifier interpreted by this function.

Returns:

- `boolean` — result of: returns whether equippable in the quickslot activation subsystem.

Side effects:

- None directly observable beyond calls listed below.

Called by:

- `scripts/quickslots/inv_overhaul_quickslots.lua :: IsEquippable`

Calls:

- `native.HasInvItemProperty`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `FindBoundItemIndex(category: int, itemID: int, wantedOccurrence: int) -> int`

Source: `scripts/quickslots/inv_overhaul_quickslot_activation.lua`

Purpose: Finds bound item index in the quickslot activation subsystem.

Parameters:

- `category: int` — zero-based engine inventory category identifier.
- `itemID: int` — engine item or callback identifier interpreted by this function.
- `wantedOccurrence: int` — zero-based occurrence of an item ID within its category.

Returns:

- `number` (integer) — result of: finds bound item index in the quickslot activation subsystem.

Side effects:

- None directly observable beyond calls listed below.

Called by:

- `scripts/quickslots/inv_overhaul_quickslot_equipment.lua :: EquipmentPolicyToggle`
- `scripts/quickslots/inv_overhaul_quickslots.lua :: FindBoundItemIndex`

Calls:

- `ActivationGetPlayer`
- `player.GetItemCount`
- `player.GetItem`
- `item.GetItemID`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `InitializePersistentState() -> void`

Source: `scripts/quickslots/inv_overhaul_quickslot_activation.lua`

Purpose: Initializes persistent state in the quickslot activation subsystem.

Parameters:

None.

Returns:

None.

Side effects:

- Writes shared engine variable(s): `"inv_overhaul_quickslot_request"`, `"inv_overhaul_quickslot_active_weapon"`, `computed value`, `"inv_overhaul_quickslot_state_version"`.
- Invokes engine/native operations: `native.SetVariable`.

Called by:

- `scripts/quickslots/inv_overhaul_quickslots.lua :: init`

Calls:

- `native.SetVariable`
- `native.GetVariable`
- `ActivationDepletedVariable`
- `ActivationOccurrenceVariable`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.


## Internal API

No additional maintask helpers.

## Events / callbacks

No engine callbacks; this is an imported module.

## Important constants

- `QuickslotActivationWeaponCategory: int = 0` — engine inventory category value for quickslot activation weapon category.
- `QuickslotActivationClothesCategory: int = 1` — engine inventory category value for quickslot activation clothes category.
- `QuickslotActivationCategoryCount: int = 5` — fixed limit/count for quickslot activation category count.
- `QuickslotActivationHelpMessage: int = 200` — numeric engine/UI protocol value for quickslot activation help message.
- `QuickslotActivationPlayerAddItem: int = 3` — named behavior/layout value for quickslot activation player add item.

## Architectural notes

- No additional module-specific issue identified beyond repository-wide shared-variable and compiler-visible API constraints.
