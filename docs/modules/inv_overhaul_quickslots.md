# Quickslots

## Source

`scripts/quickslots/inv_overhaul_quickslots.lua`

DSL unit: `maintask InvOverhaulQuickslotPlayerEffect`

## Responsibility

Runs the persistent player quickslot effect, polls native requests, activates items/equipment, and verifies delayed mutations.

## Dependencies

- `inv_overhaul_quickslot_activation` — Provides shared persistent quickslot activation state, binding lookup, feedback, and equipment-removal hints.
- `inv_overhaul_quickslot_consumables` — Maps supported consumable item IDs to their use-effect script names.
- `inv_overhaul_quickslot_equipment` — Applies the quickslot equipment toggle policy while preserving inventory layout hints.
- `inv_overhaul_quickslot_hands` — Requests hand-combat activation for the quickslot runtime.
- Pathologic native API — engine state, object access, persistence variables, UI messaging, timing, or rendering as listed per function.

## Used by

- No local import or direct runtime reference was resolved. It may be retained for external/save compatibility.

## State

- `m_bPendingConsumption: bool` — deferred-work state for pending consumption.
- `m_iPendingSlot: int` — deferred-work state for pending slot.
- `m_iPendingCategory: int` — deferred-work state for pending category.
- `m_iPendingItemID: int` — deferred-work state for pending item id.
- `m_iPendingOccurrence: int` — deferred-work state for pending occurrence.
- `m_iPendingAmountBefore: int` — deferred-work state for pending amount before.
- `m_bPendingVerification: bool` — deferred-work state for pending verification.
- `m_fVerificationDelay: float` — timing state for verification delay.
- `m_iVerificationCategory: int` — mutable runtime state for verification category.
- `m_iVerificationItemID: int` — mutable runtime state for verification item id.
- `m_iVerificationSlot: int` — current or cached layout value for verification slot.
- `m_fRequestPollCooldown: float` — timing state for request poll cooldown.
- `m_iEffectGeneration: int` — mutable runtime state for effect generation.
- `m_bTrackedWeaponSelected: bool` — lifecycle/behavior flag for tracked weapon selected.
- `m_iTrackedWeaponID: int` — mutable runtime state for tracked weapon id.
- `m_iTrackedWeaponOccurrence: int` — mutable runtime state for tracked weapon occurrence.
- `m_bPendingHandsDrop: bool` — deferred-work state for pending hands drop.
- `m_iPendingHandsDropItemID: int` — deferred-work state for pending hands drop item id.
- `m_iPendingHandsDropOccurrence: int` — deferred-work state for pending hands drop occurrence.
- `m_fPendingHandsDropDelay: float` — timing state for pending hands drop delay.
- `m_fPendingHandsDropTimeout: float` — deferred-work state for pending hands drop timeout.
- `m_bPendingHandsDropWasHolstered: bool` — deferred-work state for pending hands drop was holstered.
- `m_fTrackedWeaponGrace: float` — mutable runtime state for tracked weapon grace.

## Public API

No importable module API. Runtime entry points are documented under Events / callbacks.

## Internal API

### `GetPlayer() -> object`

Source: `scripts/quickslots/inv_overhaul_quickslots.lua`

Purpose: Returns player in the quickslots subsystem.

Parameters:

None.

Returns:

- `object` — result of: returns player in the quickslots subsystem.

Side effects:

- Delegates to compiler-visible module APIs and inherits their documented side effects.

Called by:

- `scripts/quickslots/inv_overhaul_quickslots.lua :: UpdateTrackedWeapon`
- `scripts/quickslots/inv_overhaul_quickslots.lua :: ProcessPendingHandsDrop`
- `scripts/quickslots/inv_overhaul_quickslots.lua :: TraceInventoryState`
- `scripts/quickslots/inv_overhaul_quickslots.lua :: ProcessPendingConsumption`
- `scripts/quickslots/inv_overhaul_quickslots.lua :: UseConsumable`
- `scripts/quickslots/inv_overhaul_quickslots.lua :: Activate`

Calls:

- `inv_overhaul_quickslot_activation.ActivationGetPlayer`

Notes / invariants:

- Maintask helper; callable within its task unless the engine invokes it by a documented callback name.

### `GetItemVariable(slot: int) -> string`

Source: `scripts/quickslots/inv_overhaul_quickslots.lua`

Purpose: Returns item variable in the quickslots subsystem.

Parameters:

- `slot: int` — 1-based quickslot number.

Returns:

- `string` — result of: returns item variable in the quickslots subsystem.

Side effects:

- Delegates to compiler-visible module APIs and inherits their documented side effects.

Called by:

- `scripts/quickslots/inv_overhaul_quickslots.lua :: Activate`

Calls:

- `inv_overhaul_quickslot_activation.ActivationItemVariable`

Notes / invariants:

- Maintask helper; callable within its task unless the engine invokes it by a documented callback name.

### `GetCategoryVariable(slot: int) -> string`

Source: `scripts/quickslots/inv_overhaul_quickslots.lua`

Purpose: Returns category variable in the quickslots subsystem.

Parameters:

- `slot: int` — 1-based quickslot number.

Returns:

- `string` — result of: returns category variable in the quickslots subsystem.

Side effects:

- Delegates to compiler-visible module APIs and inherits their documented side effects.

Called by:

- `scripts/quickslots/inv_overhaul_quickslots.lua :: Activate`

Calls:

- `inv_overhaul_quickslot_activation.ActivationCategoryVariable`

Notes / invariants:

- Maintask helper; callable within its task unless the engine invokes it by a documented callback name.

### `GetOccurrenceVariable(slot: int) -> string`

Source: `scripts/quickslots/inv_overhaul_quickslots.lua`

Purpose: Returns occurrence variable in the quickslots subsystem.

Parameters:

- `slot: int` — 1-based quickslot number.

Returns:

- `string` — result of: returns occurrence variable in the quickslots subsystem.

Side effects:

- Delegates to compiler-visible module APIs and inherits their documented side effects.

Called by:

- `scripts/quickslots/inv_overhaul_quickslots.lua :: Activate`

Calls:

- `inv_overhaul_quickslot_activation.ActivationOccurrenceVariable`

Notes / invariants:

- Maintask helper; callable within its task unless the engine invokes it by a documented callback name.

### `GetDepletedVariable(slot: int) -> string`

Source: `scripts/quickslots/inv_overhaul_quickslots.lua`

Purpose: Returns depleted variable in the quickslots subsystem.

Parameters:

- `slot: int` — 1-based quickslot number.

Returns:

- `string` — result of: returns depleted variable in the quickslots subsystem.

Side effects:

- Delegates to compiler-visible module APIs and inherits their documented side effects.

Called by:

- `scripts/quickslots/inv_overhaul_quickslots.lua :: Activate`

Calls:

- `inv_overhaul_quickslot_activation.ActivationDepletedVariable`

Notes / invariants:

- Maintask helper; callable within its task unless the engine invokes it by a documented callback name.

### `ClearBinding(slot: int) -> void`

Source: `scripts/quickslots/inv_overhaul_quickslots.lua`

Purpose: Clears binding in the quickslots subsystem.

Parameters:

- `slot: int` — 1-based quickslot number.

Returns:

None.

Side effects:

- Delegates to compiler-visible module APIs and inherits their documented side effects.

Called by:

- `scripts/quickslots/inv_overhaul_quickslots.lua :: ProcessPendingConsumption`

Calls:

- `inv_overhaul_quickslot_activation.ClearBinding`

Notes / invariants:

- Maintask helper; callable within its task unless the engine invokes it by a documented callback name.

### `ShowMessage(textID: int) -> void`

Source: `scripts/quickslots/inv_overhaul_quickslots.lua`

Purpose: Shows message in the quickslots subsystem.

Parameters:

- `textID: int` — value interpreted according to the function purpose; no narrower contract is established by current code.

Returns:

None.

Side effects:

- Delegates to compiler-visible module APIs and inherits their documented side effects.

Called by:

- `scripts/quickslots/inv_overhaul_quickslots.lua :: UseConsumable`
- `scripts/quickslots/inv_overhaul_quickslots.lua :: Activate`

Calls:

- `inv_overhaul_quickslot_activation.ShowMessage`

Notes / invariants:

- Maintask helper; callable within its task unless the engine invokes it by a documented callback name.

### `ShowFeedback(itemID: int) -> void`

Source: `scripts/quickslots/inv_overhaul_quickslots.lua`

Purpose: Shows feedback in the quickslots subsystem.

Parameters:

- `itemID: int` — engine item or callback identifier interpreted by this function.

Returns:

None.

Side effects:

- Delegates to compiler-visible module APIs and inherits their documented side effects.

Called by:

- `scripts/quickslots/inv_overhaul_quickslots.lua :: ProcessPendingConsumption`

Calls:

- `inv_overhaul_quickslot_activation.ShowFeedback`

Notes / invariants:

- Maintask helper; callable within its task unless the engine invokes it by a documented callback name.

### `MarkInventoryChanged() -> void`

Source: `scripts/quickslots/inv_overhaul_quickslots.lua`

Purpose: Marks inventory changed in the quickslots subsystem.

Parameters:

None.

Returns:

None.

Side effects:

- Delegates to compiler-visible module APIs and inherits their documented side effects.

Called by:

- `scripts/quickslots/inv_overhaul_quickslots.lua :: ProcessPendingHandsDrop`
- `scripts/quickslots/inv_overhaul_quickslots.lua :: ProcessPendingConsumption`

Calls:

- `inv_overhaul_quickslot_activation.MarkInventoryChanged`

Notes / invariants:

- Maintask helper; callable within its task unless the engine invokes it by a documented callback name.

### `PublishRemovalHint(category: int, index: int) -> void`

Source: `scripts/quickslots/inv_overhaul_quickslots.lua`

Purpose: Publishes removal hint in the quickslots subsystem.

Parameters:

- `category: int` — zero-based engine inventory category identifier.
- `index: int` — zero-based entry index in the relevant engine container/category.

Returns:

None.

Side effects:

- Delegates to compiler-visible module APIs and inherits their documented side effects.

Called by:

- `scripts/quickslots/inv_overhaul_quickslots.lua :: ProcessPendingHandsDrop`
- `scripts/quickslots/inv_overhaul_quickslots.lua :: ProcessPendingConsumption`

Calls:

- `inv_overhaul_quickslot_activation.PublishRemovalHint`

Notes / invariants:

- Maintask helper; callable within its task unless the engine invokes it by a documented callback name.

### `GetUseEffect(itemID: int) -> string`

Source: `scripts/quickslots/inv_overhaul_quickslots.lua`

Purpose: Returns use effect in the quickslots subsystem.

Parameters:

- `itemID: int` — engine item or callback identifier interpreted by this function.

Returns:

- `string` — result of: returns use effect in the quickslots subsystem.

Side effects:

- Delegates to compiler-visible module APIs and inherits their documented side effects.

Called by:

- `scripts/quickslots/inv_overhaul_quickslots.lua :: UseConsumable`

Calls:

- `inv_overhaul_quickslot_consumables.GetUseEffect`

Notes / invariants:

- Maintask helper; callable within its task unless the engine invokes it by a documented callback name.

### `IsEquippable(category: int, itemID: int) -> bool`

Source: `scripts/quickslots/inv_overhaul_quickslots.lua`

Purpose: Returns whether equippable in the quickslots subsystem.

Parameters:

- `category: int` — zero-based engine inventory category identifier.
- `itemID: int` — engine item or callback identifier interpreted by this function.

Returns:

- `boolean` — result of: returns whether equippable in the quickslots subsystem.

Side effects:

- Delegates to compiler-visible module APIs and inherits their documented side effects.

Called by:

- `scripts/quickslots/inv_overhaul_quickslots.lua :: Activate`

Calls:

- `inv_overhaul_quickslot_activation.IsEquippable`

Notes / invariants:

- Maintask helper; callable within its task unless the engine invokes it by a documented callback name.

### `FindBoundItemIndex(category: int, itemID: int, wantedOccurrence: int) -> int`

Source: `scripts/quickslots/inv_overhaul_quickslots.lua`

Purpose: Finds bound item index in the quickslots subsystem.

Parameters:

- `category: int` — zero-based engine inventory category identifier.
- `itemID: int` — engine item or callback identifier interpreted by this function.
- `wantedOccurrence: int` — zero-based occurrence of an item ID within its category.

Returns:

- `number` (integer) — result of: finds bound item index in the quickslots subsystem.

Side effects:

- Delegates to compiler-visible module APIs and inherits their documented side effects.

Called by:

- `scripts/quickslots/inv_overhaul_quickslots.lua :: ProcessPendingHandsDrop`
- `scripts/quickslots/inv_overhaul_quickslots.lua :: ProcessPendingConsumption`
- `scripts/quickslots/inv_overhaul_quickslots.lua :: Activate`

Calls:

- `inv_overhaul_quickslot_activation.FindBoundItemIndex`

Notes / invariants:

- Maintask helper; callable within its task unless the engine invokes it by a documented callback name.

### `UpdateTrackedWeapon(delta: float) -> void`

Source: `scripts/quickslots/inv_overhaul_quickslots.lua`

Purpose: Updates tracked weapon in the quickslots subsystem.

Parameters:

- `delta: float` — elapsed update time in seconds.

Returns:

None.

Side effects:

- Mutates module/task state: `m_iTrackedWeaponID`, `m_iTrackedWeaponOccurrence`, `m_bTrackedWeaponSelected`, `m_fTrackedWeaponGrace`.
- May mutate engine/UI objects through: `player.IsItemSelected`.

Called by:

- `scripts/quickslots/inv_overhaul_quickslots.lua :: init`

Calls:

- `GetPlayer`
- `player.GetItemCount`
- `player.IsItemSelected`
- `player.GetItem`
- `item.GetItemID`
- `previousItem.GetItemID`

Notes / invariants:

- Maintask helper; callable within its task unless the engine invokes it by a documented callback name.

### `AdjustBindingsAfterWeaponDrop(itemID: int, occurrence: int) -> void`

Source: `scripts/quickslots/inv_overhaul_quickslots.lua`

Purpose: Adjusts bindings after weapon drop in the quickslots subsystem.

Parameters:

- `itemID: int` — engine item or callback identifier interpreted by this function.
- `occurrence: int` — zero-based occurrence of an item ID within its category.

Returns:

None.

Side effects:

- Delegates to compiler-visible module APIs and inherits their documented side effects.

Called by:

- `scripts/quickslots/inv_overhaul_quickslots.lua :: ProcessPendingHandsDrop`

Calls:

- `inv_overhaul_quickslot_hands.AdjustBindingsAfterDrop`

Notes / invariants:

- Maintask helper; callable within its task unless the engine invokes it by a documented callback name.

### `ScheduleHandsDrop() -> void`

Source: `scripts/quickslots/inv_overhaul_quickslots.lua`

Purpose: Schedules hands drop in the quickslots subsystem.

Parameters:

None.

Returns:

None.

Side effects:

- Mutates module/task state: `m_iPendingHandsDropItemID`, `m_iPendingHandsDropOccurrence`, `m_fPendingHandsDropDelay`, `m_fPendingHandsDropTimeout`, `m_bPendingHandsDropWasHolstered`, `m_bPendingHandsDrop`, `m_bTrackedWeaponSelected`.
- Invokes engine/native operations: `native.Trace`, `native.IsWeaponHolstered`.

Called by:

- `scripts/quickslots/inv_overhaul_quickslots.lua :: ProcessHandCombatRequest`

Calls:

- `native.Trace`
- `native.IsWeaponHolstered`

Notes / invariants:

- Maintask helper; callable within its task unless the engine invokes it by a documented callback name.

### `ProcessPendingHandsDrop(delta: float) -> void`

Source: `scripts/quickslots/inv_overhaul_quickslots.lua`

Purpose: Processes pending hands drop in the quickslots subsystem.

Parameters:

- `delta: float` — elapsed update time in seconds.

Returns:

None.

Side effects:

- Mutates module/task state: `m_fPendingHandsDropDelay`, `m_fPendingHandsDropTimeout`, `m_bPendingHandsDrop`.
- Writes shared engine variable(s): `"inv_overhaul_quickslot_active_weapon"`.
- Invokes engine/native operations: `native.Trace`, `native.IsWeaponHolstered`, `native.SetVariable`.
- May mutate engine/UI objects through: `player.IsItemSelected`, `player.DropItems`, `player.SelectItem`, `player.RemoveItem`.

Called by:

- `scripts/quickslots/inv_overhaul_quickslots.lua :: init`

Calls:

- `FindBoundItemIndex`
- `native.Trace`
- `GetPlayer`
- `player.GetItem`
- `player.GetItemAmount`
- `player.IsItemSelected`
- `native.IsWeaponHolstered`
- `PublishRemovalHint`
- `player.DropItems`
- `player.SelectItem`
- `player.RemoveItem`
- `AdjustBindingsAfterWeaponDrop`
- `… and 2 more`

Notes / invariants:

- Maintask helper; callable within its task unless the engine invokes it by a documented callback name.

### `ProcessHandCombatRequest() -> void`

Source: `scripts/quickslots/inv_overhaul_quickslots.lua`

Purpose: Processes hand combat request in the quickslots subsystem.

Parameters:

None.

Returns:

None.

Side effects:

- Writes shared engine variable(s): `"inv_overhaul_handcombat_request"`.
- Invokes engine/native operations: `native.SetVariable`, `native.Trace`.

Called by:

- `scripts/quickslots/inv_overhaul_quickslots.lua :: init`

Calls:

- `native.GetVariable`
- `native.SetVariable`
- `native.Trace`
- `ScheduleHandsDrop`

Notes / invariants:

- Maintask helper; callable within its task unless the engine invokes it by a documented callback name.

### `TraceInventoryState(tag: string, category: int, targetItemID: int) -> void`

Source: `scripts/quickslots/inv_overhaul_quickslots.lua`

Purpose: Traces inventory state in the quickslots subsystem.

Parameters:

- `tag: string` — value interpreted according to the function purpose; no narrower contract is established by current code.
- `category: int` — zero-based engine inventory category identifier.
- `targetItemID: int` — engine item or callback identifier interpreted by this function.

Returns:

None.

Side effects:

- Invokes engine/native operations: `native.Trace`.

Called by:

- `scripts/quickslots/inv_overhaul_quickslots.lua :: ProcessPendingVerification`
- `scripts/quickslots/inv_overhaul_quickslots.lua :: ProcessPendingConsumption`
- `scripts/quickslots/inv_overhaul_quickslots.lua :: UseConsumable`

Calls:

- `GetPlayer`
- `player.GetItemCount`
- `player.GetItem`
- `item.GetItemID`
- `player.GetItemAmount`
- `native.Trace`

Notes / invariants:

- Maintask helper; callable within its task unless the engine invokes it by a documented callback name.

### `ScheduleVerification(slot: int, category: int, itemID: int) -> void`

Source: `scripts/quickslots/inv_overhaul_quickslots.lua`

Purpose: Schedules verification in the quickslots subsystem.

Parameters:

- `slot: int` — 1-based quickslot number.
- `category: int` — zero-based engine inventory category identifier.
- `itemID: int` — engine item or callback identifier interpreted by this function.

Returns:

None.

Side effects:

- Mutates module/task state: `m_iVerificationSlot`, `m_iVerificationCategory`, `m_iVerificationItemID`, `m_fVerificationDelay`, `m_bPendingVerification`.

Called by:

- `scripts/quickslots/inv_overhaul_quickslots.lua :: ProcessPendingConsumption`

Notes / invariants:

- Maintask helper; callable within its task unless the engine invokes it by a documented callback name.

### `ProcessPendingVerification(delta: float) -> void`

Source: `scripts/quickslots/inv_overhaul_quickslots.lua`

Purpose: Processes pending verification in the quickslots subsystem.

Parameters:

- `delta: float` — elapsed update time in seconds.

Returns:

None.

Side effects:

- Mutates module/task state: `m_fVerificationDelay`, `m_bPendingVerification`.
- Writes shared engine variable(s): `"inv_overhaul_quickslot_diag_active"`.
- Invokes engine/native operations: `native.SetVariable`.

Called by:

- `scripts/quickslots/inv_overhaul_quickslots.lua :: init`

Calls:

- `TraceInventoryState`
- `native.SetVariable`

Notes / invariants:

- Maintask helper; callable within its task unless the engine invokes it by a documented callback name.

### `ToggleEquipment(category: int, index: int, itemID: int, occurrence: int, selected: bool) -> void`

Source: `scripts/quickslots/inv_overhaul_quickslots.lua`

Purpose: Toggles equipment in the quickslots subsystem.

Parameters:

- `category: int` — zero-based engine inventory category identifier.
- `index: int` — zero-based entry index in the relevant engine container/category.
- `itemID: int` — engine item or callback identifier interpreted by this function.
- `occurrence: int` — zero-based occurrence of an item ID within its category.
- `selected: bool` — behavior flag interpreted by this function.

Returns:

None.

Side effects:

- Delegates to compiler-visible module APIs and inherits their documented side effects.

Called by:

- `scripts/quickslots/inv_overhaul_quickslots.lua :: Activate`

Calls:

- `inv_overhaul_quickslot_equipment.EquipmentPolicyToggle`

Notes / invariants:

- Maintask helper; callable within its task unless the engine invokes it by a documented callback name.

### `ProcessPendingConsumption() -> void`

Source: `scripts/quickslots/inv_overhaul_quickslots.lua`

Purpose: Processes pending consumption in the quickslots subsystem.

Parameters:

None.

Returns:

None.

Side effects:

- Mutates module/task state: `m_bPendingConsumption`.
- Invokes engine/native operations: `native.Trace`.
- May mutate engine/UI objects through: `player.RemoveItem`, `player.SetItemAmount`.

Called by:

- `scripts/quickslots/inv_overhaul_quickslots.lua :: init`

Calls:

- `FindBoundItemIndex`
- `native.Trace`
- `ClearBinding`
- `MarkInventoryChanged`
- `ShowFeedback`
- `GetPlayer`
- `player.GetItemAmount`
- `TraceInventoryState`
- `PublishRemovalHint`
- `player.RemoveItem`
- `player.SetItemAmount`
- `ScheduleVerification`

Notes / invariants:

- Maintask helper; callable within its task unless the engine invokes it by a documented callback name.

### `UseConsumable(slot: int, category: int, index: int, itemID: int, occurrence: int) -> void`

Source: `scripts/quickslots/inv_overhaul_quickslots.lua`

Purpose: Uses consumable in the quickslots subsystem.

Parameters:

- `slot: int` — 1-based quickslot number.
- `category: int` — zero-based engine inventory category identifier.
- `index: int` — zero-based entry index in the relevant engine container/category.
- `itemID: int` — engine item or callback identifier interpreted by this function.
- `occurrence: int` — zero-based occurrence of an item ID within its category.

Returns:

None.

Side effects:

- Mutates module/task state: `m_iPendingSlot`, `m_iPendingCategory`, `m_iPendingItemID`, `m_iPendingOccurrence`, `m_iPendingAmountBefore`, `m_bPendingConsumption`.
- Writes shared engine variable(s): `"inv_overhaul_quickslot_diag_active"`.
- Invokes engine/native operations: `native.Trace`, `native.SetVariable`.
- May mutate engine/UI objects through: `player.ApplyEffect`.

Called by:

- `scripts/quickslots/inv_overhaul_quickslots.lua :: Activate`

Calls:

- `GetUseEffect`
- `native.Trace`
- `ShowMessage`
- `GetPlayer`
- `player.GetItemAmount`
- `native.SetVariable`
- `TraceInventoryState`
- `player.ApplyEffect`

Notes / invariants:

- Maintask helper; callable within its task unless the engine invokes it by a documented callback name.

### `Activate(slot: int) -> void`

Source: `scripts/quickslots/inv_overhaul_quickslots.lua`

Purpose: Activates quickslots in the quickslots subsystem.

Parameters:

- `slot: int` — 1-based quickslot number.

Returns:

None.

Side effects:

- Invokes engine/native operations: `native.Trace`.
- May mutate engine/UI objects through: `player.IsItemSelected`.

Called by:

- `scripts/quickslots/inv_overhaul_quickslots.lua :: init`

Calls:

- `native.GetVariable`
- `GetCategoryVariable`
- `GetItemVariable`
- `GetOccurrenceVariable`
- `GetDepletedVariable`
- `ShowMessage`
- `FindBoundItemIndex`
- `GetPlayer`
- `player.IsItemSelected`
- `native.Trace`
- `IsEquippable`
- `ToggleEquipment`
- `… and 1 more`

Notes / invariants:

- Maintask helper; callable within its task unless the engine invokes it by a documented callback name.


## Events / callbacks

### `init() -> void`

Source: `scripts/quickslots/inv_overhaul_quickslots.lua`

Purpose: Initializes the quickslots runtime and establishes its starting state and engine/UI integration.

Parameters:

None.

Returns:

None.

Side effects:

- Mutates module/task state: `m_bPendingConsumption`, `m_bPendingVerification`, `m_fRequestPollCooldown`, `m_iEffectGeneration`, `m_bPendingHandsDrop`, `m_bTrackedWeaponSelected`, `m_iTrackedWeaponID`, `m_iTrackedWeaponOccurrence`, `… and 1 more`.
- Writes shared engine variable(s): `"inv_overhaul_quickslot_diag_active"`, `"inv_overhaul_handcombat_request"`, `"inv_overhaul_quickslot_request"`.
- Invokes engine/native operations: `native.SetVariable`, `native.Trace`, `native.Sleep`.

Called by:

- No in-repository caller was resolved; this may be an engine/XML callback or a conventionally public helper.

Calls:

- `native.GetVariable`
- `inv_overhaul_quickslot_activation.InitializePersistentState`
- `native.SetVariable`
- `UpdateTrackedWeapon`
- `native.Trace`
- `native.Sleep`
- `ProcessPendingConsumption`
- `ProcessPendingVerification`
- `ProcessHandCombatRequest`
- `ProcessPendingHandsDrop`
- `Activate`

Notes / invariants:

- Maintask helper; callable within its task unless the engine invokes it by a documented callback name.


## Important constants

- `c_iCWeapon: int = 0` — named behavior/layout value for cweapon.
- `c_iCClothes: int = 1` — named behavior/layout value for cclothes.
- `c_iCategoryCount: int = 5` — fixed limit/count for category count.
- `c_iQuickslotCount: int = 10` — fixed limit/count for quickslot count.
- `c_iInventoryCapacity: int = 56` — fixed limit/count for inventory capacity.
- `c_iWMHelpMessage: int = 200` — numeric engine/UI protocol value for wmhelp message.
- `c_iWMPlayerAddItem: int = 3` — numeric engine/UI protocol value for wmplayer add item.
- `c_iInventoryFullTextID: int = 1400` — localized string identifier for inventory full.
- `c_iQuickslotMissingTextID: int = 1405` — localized string identifier for quickslot missing.
- `c_iQuickslotUnusableTextID: int = 1406` — localized string identifier for quickslot unusable.
- `c_fRequestPollDelay: float = 0.05` — timing value, in seconds, for request poll delay.

## Architectural notes

- No additional module-specific issue identified beyond repository-wide shared-variable and compiler-visible API constraints.
