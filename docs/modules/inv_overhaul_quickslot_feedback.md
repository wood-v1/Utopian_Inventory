# Quickslot Feedback

## Source

`scripts/compatibility/quickslots/inv_overhaul_quickslot_feedback.lua`

DSL unit: `maintask InvOverhaulQuickslotFeedback`

## Responsibility

Retained compatibility UI runtime combining quickslot activation and transient feedback rendering.

This source is compatibility-only. Active packages must not import it.

## Dependencies

- No local DSL imports.
- Pathologic native API — engine state, object access, persistence variables, UI messaging, timing, or rendering as listed per function.

## Used by

- `resources/ui/inv_overhaul_quickslot_feedback.xml` (runtime/XML script reference)

## State

- `itemID: int` — mutable runtime state for item id.
- `amount: int` — mutable runtime state for amount.
- `sprite: string` — mutable runtime state for sprite.
- `timeLeft: float` — timing state for time left.
- `messageCooldown: float` — timing state for message cooldown.

## Public API

No importable module API. Runtime entry points are documented under Events / callbacks.

## Internal API

### `GetPlayer() -> object`

Source: `scripts/compatibility/quickslots/inv_overhaul_quickslot_feedback.lua`

Purpose: Returns player in the quickslot feedback subsystem.

Parameters:

None.

Returns:

- `object` — result of: returns player in the quickslot feedback subsystem.

Side effects:

- None directly observable beyond calls listed below.

Called by:

- `scripts/compatibility/quickslots/inv_overhaul_quickslot_feedback.lua :: IsEquippedItem`
- `scripts/compatibility/quickslots/inv_overhaul_quickslot_feedback.lua :: GetBackpackItemCount`
- `scripts/compatibility/quickslots/inv_overhaul_quickslot_feedback.lua :: GetBackpackOrdinal`
- `scripts/compatibility/quickslots/inv_overhaul_quickslot_feedback.lua :: FindBoundItem`
- `scripts/compatibility/quickslots/inv_overhaul_quickslot_feedback.lua :: ToggleEquipment`
- `scripts/compatibility/quickslots/inv_overhaul_quickslot_feedback.lua :: UseConsumable`

Calls:

- `native.GetPlayerContainer`

Notes / invariants:

- Maintask helper; callable within its task unless the engine invokes it by a documented callback name.

### `GetItemVariable(slot: int) -> string`

Source: `scripts/compatibility/quickslots/inv_overhaul_quickslot_feedback.lua`

Purpose: Returns item variable in the quickslot feedback subsystem.

Parameters:

- `slot: int` — 1-based quickslot number.

Returns:

- `string` — result of: returns item variable in the quickslot feedback subsystem.

Side effects:

- None directly observable beyond calls listed below.

Called by:

- `scripts/compatibility/quickslots/inv_overhaul_quickslot_feedback.lua :: ClearBinding`
- `scripts/compatibility/quickslots/inv_overhaul_quickslot_feedback.lua :: Activate`

Notes / invariants:

- Maintask helper; callable within its task unless the engine invokes it by a documented callback name.

### `GetCategoryVariable(slot: int) -> string`

Source: `scripts/compatibility/quickslots/inv_overhaul_quickslot_feedback.lua`

Purpose: Returns category variable in the quickslot feedback subsystem.

Parameters:

- `slot: int` — 1-based quickslot number.

Returns:

- `string` — result of: returns category variable in the quickslot feedback subsystem.

Side effects:

- None directly observable beyond calls listed below.

Called by:

- `scripts/compatibility/quickslots/inv_overhaul_quickslot_feedback.lua :: ClearBinding`
- `scripts/compatibility/quickslots/inv_overhaul_quickslot_feedback.lua :: Activate`

Notes / invariants:

- Maintask helper; callable within its task unless the engine invokes it by a documented callback name.

### `GetOccurrenceVariable(slot: int) -> string`

Source: `scripts/compatibility/quickslots/inv_overhaul_quickslot_feedback.lua`

Purpose: Returns occurrence variable in the quickslot feedback subsystem.

Parameters:

- `slot: int` — 1-based quickslot number.

Returns:

- `string` — result of: returns occurrence variable in the quickslot feedback subsystem.

Side effects:

- None directly observable beyond calls listed below.

Called by:

- `scripts/compatibility/quickslots/inv_overhaul_quickslot_feedback.lua :: ClearBinding`
- `scripts/compatibility/quickslots/inv_overhaul_quickslot_feedback.lua :: Activate`

Notes / invariants:

- Maintask helper; callable within its task unless the engine invokes it by a documented callback name.

### `GetDepletedVariable(slot: int) -> string`

Source: `scripts/compatibility/quickslots/inv_overhaul_quickslot_feedback.lua`

Purpose: Returns depleted variable in the quickslot feedback subsystem.

Parameters:

- `slot: int` — 1-based quickslot number.

Returns:

- `string` — result of: returns depleted variable in the quickslot feedback subsystem.

Side effects:

- None directly observable beyond calls listed below.

Called by:

- `scripts/compatibility/quickslots/inv_overhaul_quickslot_feedback.lua :: ClearBinding`
- `scripts/compatibility/quickslots/inv_overhaul_quickslot_feedback.lua :: Activate`

Notes / invariants:

- Maintask helper; callable within its task unless the engine invokes it by a documented callback name.

### `ClearBinding(slot: int) -> void`

Source: `scripts/compatibility/quickslots/inv_overhaul_quickslot_feedback.lua`

Purpose: Clears binding in the quickslot feedback subsystem.

Parameters:

- `slot: int` — 1-based quickslot number.

Returns:

None.

Side effects:

- Writes shared engine variable(s): `computed value`.
- Invokes engine/native operations: `native.SetVariable`, `native.Trace`.

Called by:

- `scripts/compatibility/quickslots/inv_overhaul_quickslot_feedback.lua :: UseConsumable`

Calls:

- `native.SetVariable`
- `GetItemVariable`
- `GetCategoryVariable`
- `GetOccurrenceVariable`
- `GetDepletedVariable`
- `native.Trace`

Notes / invariants:

- Maintask helper; callable within its task unless the engine invokes it by a documented callback name.

### `ShowMessage(textID: int) -> void`

Source: `scripts/compatibility/quickslots/inv_overhaul_quickslot_feedback.lua`

Purpose: Shows message in the quickslot feedback subsystem.

Parameters:

- `textID: int` — value interpreted according to the function purpose; no narrower contract is established by current code.

Returns:

None.

Side effects:

- Mutates module/task state: `messageCooldown`.
- Invokes engine/native operations: `native.CreateIntVector`, `native.SendWorldWndMessage`.
- May mutate engine/UI objects through: `text.add`.

Called by:

- `scripts/compatibility/quickslots/inv_overhaul_quickslot_feedback.lua :: ToggleEquipment`
- `scripts/compatibility/quickslots/inv_overhaul_quickslot_feedback.lua :: UseConsumable`
- `scripts/compatibility/quickslots/inv_overhaul_quickslot_feedback.lua :: Activate`

Calls:

- `native.CreateIntVector`
- `text.add`
- `native.SendWorldWndMessage`

Notes / invariants:

- Maintask helper; callable within its task unless the engine invokes it by a documented callback name.

### `IsEquippable(category: int, candidateItemID: int) -> bool`

Source: `scripts/compatibility/quickslots/inv_overhaul_quickslot_feedback.lua`

Purpose: Returns whether equippable in the quickslot feedback subsystem.

Parameters:

- `category: int` — zero-based engine inventory category identifier.
- `candidateItemID: int` — engine item or callback identifier interpreted by this function.

Returns:

- `boolean` — result of: returns whether equippable in the quickslot feedback subsystem.

Side effects:

- None directly observable beyond calls listed below.

Called by:

- `scripts/compatibility/quickslots/inv_overhaul_quickslot_feedback.lua :: IsEquippedItem`
- `scripts/compatibility/quickslots/inv_overhaul_quickslot_feedback.lua :: Activate`

Calls:

- `native.HasInvItemProperty`

Notes / invariants:

- Maintask helper; callable within its task unless the engine invokes it by a documented callback name.

### `IsEquippedItem(category: int, index: int) -> bool`

Source: `scripts/compatibility/quickslots/inv_overhaul_quickslot_feedback.lua`

Purpose: Returns whether equipped item in the quickslot feedback subsystem.

Parameters:

- `category: int` — zero-based engine inventory category identifier.
- `index: int` — zero-based entry index in the relevant engine container/category.

Returns:

- `boolean` — result of: returns whether equipped item in the quickslot feedback subsystem.

Side effects:

- May mutate engine/UI objects through: `player.IsItemSelected`.

Called by:

- `scripts/compatibility/quickslots/inv_overhaul_quickslot_feedback.lua :: GetBackpackItemCount`
- `scripts/compatibility/quickslots/inv_overhaul_quickslot_feedback.lua :: GetBackpackOrdinal`

Calls:

- `GetPlayer`
- `player.IsItemSelected`
- `player.GetItem`
- `candidate.GetItemID`
- `IsEquippable`

Notes / invariants:

- Maintask helper; callable within its task unless the engine invokes it by a documented callback name.

### `GetBackpackItemCount() -> int`

Source: `scripts/compatibility/quickslots/inv_overhaul_quickslot_feedback.lua`

Purpose: Returns backpack item count in the quickslot feedback subsystem.

Parameters:

None.

Returns:

- `number` (integer) — result of: returns backpack item count in the quickslot feedback subsystem.

Side effects:

- None directly observable beyond calls listed below.

Called by:

- `scripts/compatibility/quickslots/inv_overhaul_quickslot_feedback.lua :: ToggleEquipment`
- `scripts/compatibility/quickslots/inv_overhaul_quickslot_feedback.lua :: UseConsumable`

Calls:

- `GetPlayer`
- `player.GetItemCount`
- `IsEquippedItem`

Notes / invariants:

- Maintask helper; callable within its task unless the engine invokes it by a documented callback name.

### `GetBackpackOrdinal(targetCategory: int, targetIndex: int) -> int`

Source: `scripts/compatibility/quickslots/inv_overhaul_quickslot_feedback.lua`

Purpose: Returns backpack ordinal in the quickslot feedback subsystem.

Parameters:

- `targetCategory: int` — zero-based engine inventory category identifier.
- `targetIndex: int` — zero-based entry index in the relevant engine container/category.

Returns:

- `number` (integer) — result of: returns backpack ordinal in the quickslot feedback subsystem.

Side effects:

- None directly observable beyond calls listed below.

Called by:

- `scripts/compatibility/quickslots/inv_overhaul_quickslot_feedback.lua :: UseConsumable`

Calls:

- `GetPlayer`
- `player.GetItemCount`
- `IsEquippedItem`

Notes / invariants:

- Maintask helper; callable within its task unless the engine invokes it by a documented callback name.

### `PublishRemovalHint(ordinal: int, oldCount: int) -> void`

Source: `scripts/compatibility/quickslots/inv_overhaul_quickslot_feedback.lua`

Purpose: Publishes removal hint in the quickslot feedback subsystem.

Parameters:

- `ordinal: int` — value interpreted according to the function purpose; no narrower contract is established by current code.
- `oldCount: int` — value interpreted according to the function purpose; no narrower contract is established by current code.

Returns:

None.

Side effects:

- Writes shared engine variable(s): `"inv_overhaul_inventory_removed_ordinal_hint"`, `"inv_overhaul_inventory_removed_ordinal_old_count"`, `"inv_overhaul_inventory_removed_ordinal_valid"`.
- Invokes engine/native operations: `native.SetVariable`, `native.Trace`.

Called by:

- `scripts/compatibility/quickslots/inv_overhaul_quickslot_feedback.lua :: UseConsumable`

Calls:

- `native.SetVariable`
- `native.Trace`

Notes / invariants:

- Maintask helper; callable within its task unless the engine invokes it by a documented callback name.

### `FindBoundItem(category: int, wantedItemID: int, wantedOccurrence: int, index: int, selected: bool) -> bool`

Source: `scripts/compatibility/quickslots/inv_overhaul_quickslot_feedback.lua`

Purpose: Finds bound item in the quickslot feedback subsystem.

Parameters:

- `category: int` — zero-based engine inventory category identifier.
- `wantedItemID: int` — engine item or callback identifier interpreted by this function.
- `wantedOccurrence: int` — zero-based occurrence of an item ID within its category.
- `index: int` — zero-based entry index in the relevant engine container/category.
- `selected: bool` — behavior flag interpreted by this function.

Returns:

- `boolean` — result of: finds bound item in the quickslot feedback subsystem.

Side effects:

- May mutate engine/UI objects through: `player.IsItemSelected`.

Called by:

- `scripts/compatibility/quickslots/inv_overhaul_quickslot_feedback.lua :: Activate`

Calls:

- `GetPlayer`
- `player.GetItemCount`
- `player.GetItem`
- `candidate.GetItemID`
- `player.IsItemSelected`

Notes / invariants:

- Maintask helper; callable within its task unless the engine invokes it by a documented callback name.

### `ShowFeedback(newItemID: int) -> void`

Source: `scripts/compatibility/quickslots/inv_overhaul_quickslot_feedback.lua`

Purpose: Shows feedback in the quickslot feedback subsystem.

Parameters:

- `newItemID: int` — engine item or callback identifier interpreted by this function.

Returns:

None.

Side effects:

- Mutates module/task state: `itemID`, `amount`, `timeLeft`.
- Invokes engine/native operations: `native.LoadImage`, `native.CreateIntVector`, `native.SendWorldWndMessage`.
- May mutate engine/UI objects through: `data.add`.

Called by:

- `scripts/compatibility/quickslots/inv_overhaul_quickslot_feedback.lua :: ToggleEquipment`
- `scripts/compatibility/quickslots/inv_overhaul_quickslot_feedback.lua :: UseConsumable`
- `scripts/compatibility/quickslots/inv_overhaul_quickslot_feedback.lua :: OnGameMessage`

Calls:

- `native.GetInvItemSprite`
- `native.LoadImage`
- `native.CreateIntVector`
- `data.add`
- `native.SendWorldWndMessage`

Notes / invariants:

- Maintask helper; callable within its task unless the engine invokes it by a documented callback name.

### `MarkInventoryChanged() -> void`

Source: `scripts/compatibility/quickslots/inv_overhaul_quickslot_feedback.lua`

Purpose: Marks inventory changed in the quickslot feedback subsystem.

Parameters:

None.

Returns:

None.

Side effects:

- Writes shared engine variable(s): `"inv_overhaul_inventory_reorder_generation"`.
- Invokes engine/native operations: `native.SetVariable`.

Called by:

- `scripts/compatibility/quickslots/inv_overhaul_quickslot_feedback.lua :: ToggleEquipment`
- `scripts/compatibility/quickslots/inv_overhaul_quickslot_feedback.lua :: UseConsumable`

Calls:

- `native.GetVariable`
- `native.SetVariable`

Notes / invariants:

- Maintask helper; callable within its task unless the engine invokes it by a documented callback name.

### `ToggleEquipment(category: int, index: int, candidateItemID: int, selected: bool) -> void`

Source: `scripts/compatibility/quickslots/inv_overhaul_quickslot_feedback.lua`

Purpose: Toggles equipment in the quickslot feedback subsystem.

Parameters:

- `category: int` — zero-based engine inventory category identifier.
- `index: int` — zero-based entry index in the relevant engine container/category.
- `candidateItemID: int` — engine item or callback identifier interpreted by this function.
- `selected: bool` — behavior flag interpreted by this function.

Returns:

None.

Side effects:

- Invokes engine/native operations: `native.SetPlayerHandsItem`.
- May mutate engine/UI objects through: `player.SelectItem`.

Called by:

- `scripts/compatibility/quickslots/inv_overhaul_quickslot_feedback.lua :: Activate`

Calls:

- `GetPlayer`
- `GetBackpackItemCount`
- `ShowMessage`
- `player.SelectItem`
- `native.SetPlayerHandsItem`
- `MarkInventoryChanged`
- `ShowFeedback`
- `player.GetItemCount`
- `native.GetInvItemProperty`
- `player.GetItem`
- `otherItem.GetItemID`
- `native.HasInvItemProperty`

Notes / invariants:

- Maintask helper; callable within its task unless the engine invokes it by a documented callback name.

### `UseConsumable(slot: int, category: int, index: int, candidateItemID: int) -> void`

Source: `scripts/compatibility/quickslots/inv_overhaul_quickslot_feedback.lua`

Purpose: Uses consumable in the quickslot feedback subsystem.

Parameters:

- `slot: int` — 1-based quickslot number.
- `category: int` — zero-based engine inventory category identifier.
- `index: int` — zero-based entry index in the relevant engine container/category.
- `candidateItemID: int` — engine item or callback identifier interpreted by this function.

Returns:

None.

Side effects:

- Invokes engine/native operations: `native.UseItem`, `native.Trace`.
- May mutate engine/UI objects through: `player.RemoveItem`, `player.SetItemAmount`.

Called by:

- `scripts/compatibility/quickslots/inv_overhaul_quickslot_feedback.lua :: Activate`

Calls:

- `GetPlayer`
- `player.GetItemAmount`
- `GetBackpackOrdinal`
- `GetBackpackItemCount`
- `native.UseItem`
- `native.Trace`
- `ShowMessage`
- `PublishRemovalHint`
- `player.RemoveItem`
- `ClearBinding`
- `player.SetItemAmount`
- `MarkInventoryChanged`
- `… and 1 more`

Notes / invariants:

- Maintask helper; callable within its task unless the engine invokes it by a documented callback name.

### `Activate(slot: int) -> void`

Source: `scripts/compatibility/quickslots/inv_overhaul_quickslot_feedback.lua`

Purpose: Activates quickslot feedback in the quickslot feedback subsystem.

Parameters:

- `slot: int` — 1-based quickslot number.

Returns:

None.

Side effects:

- Invokes engine/native operations: `native.Trace`.

Called by:

- `scripts/compatibility/quickslots/inv_overhaul_quickslot_feedback.lua :: ProcessRequest`

Calls:

- `native.GetVariable`
- `GetCategoryVariable`
- `GetItemVariable`
- `GetOccurrenceVariable`
- `native.Trace`
- `GetDepletedVariable`
- `ShowMessage`
- `FindBoundItem`
- `IsEquippable`
- `ToggleEquipment`
- `UseConsumable`

Notes / invariants:

- Maintask helper; callable within its task unless the engine invokes it by a documented callback name.

### `ProcessRequest() -> void`

Source: `scripts/compatibility/quickslots/inv_overhaul_quickslot_feedback.lua`

Purpose: Processes request in the quickslot feedback subsystem.

Parameters:

None.

Returns:

None.

Side effects:

- Writes shared engine variable(s): `"inv_overhaul_quickslot_ui_request"`.
- Invokes engine/native operations: `native.SetVariable`.

Called by:

- `scripts/compatibility/quickslots/inv_overhaul_quickslot_feedback.lua :: OnUpdate`

Calls:

- `native.GetVariable`
- `native.SetVariable`
- `Activate`

Notes / invariants:

- Maintask helper; callable within its task unless the engine invokes it by a documented callback name.


## Events / callbacks

### `init() -> void`

Source: `scripts/compatibility/quickslots/inv_overhaul_quickslot_feedback.lua`

Purpose: Initializes the quickslot feedback runtime and establishes its starting state and engine/UI integration.

Parameters:

None.

Returns:

None.

Side effects:

- Mutates module/task state: `itemID`, `amount`, `sprite`, `timeLeft`, `messageCooldown`.
- Invokes engine/native operations: `native.SetOwnerDraw`, `native.SetNeedUpdate`, `native.Trace`, `native.ProcessEvents`.

Called by:

- No in-repository caller was resolved; this may be an engine/XML callback or a conventionally public helper.

Calls:

- `native.SetOwnerDraw`
- `native.SetNeedUpdate`
- `native.Trace`
- `native.ProcessEvents`

Notes / invariants:

- Maintask helper; callable within its task unless the engine invokes it by a documented callback name.

### `OnGameMessage(id: int, data: object) -> void`

Source: `scripts/compatibility/quickslots/inv_overhaul_quickslot_feedback.lua`

Purpose: Handles the engine/UI `OnGameMessage` callback for the quickslot feedback runtime.

Parameters:

- `id: int` — engine item or callback identifier interpreted by this function.
- `data: object` — engine callback/UI payload object; shape depends on the message.

Returns:

None.

Side effects:

- Invokes engine/native operations: `native.SetPlayerHandsItem`.

Called by:

- No in-repository caller was resolved; this may be an engine/XML callback or a conventionally public helper.

Calls:

- `data.size`
- `data.get`
- `native.SetPlayerHandsItem`
- `ShowFeedback`

Notes / invariants:

- Callback recognition is name-based in `pathologic_lua_compiler`; `OnGameMessage` is an engine event name.

### `OnUpdate(delta: float) -> void`

Source: `scripts/compatibility/quickslots/inv_overhaul_quickslot_feedback.lua`

Purpose: Handles the engine/UI `OnUpdate` callback for the quickslot feedback runtime.

Parameters:

- `delta: float` — elapsed update time in seconds.

Returns:

None.

Side effects:

- Mutates module/task state: `messageCooldown`, `timeLeft`, `sprite`, `itemID`.

Called by:

- No in-repository caller was resolved; this may be an engine/XML callback or a conventionally public helper.

Calls:

- `ProcessRequest`

Notes / invariants:

- Callback recognition is name-based in `pathologic_lua_compiler`; `OnUpdate` is an engine event name.

### `OnDraw() -> void`

Source: `scripts/compatibility/quickslots/inv_overhaul_quickslot_feedback.lua`

Purpose: Handles the engine/UI `OnDraw` callback for the quickslot feedback runtime.

Parameters:

None.

Returns:

None.

Side effects:

- Invokes engine/native operations: `native.Blit`, `native.StretchBlit`, `native.Print`.

Called by:

- No in-repository caller was resolved; this may be an engine/XML callback or a conventionally public helper.

Calls:

- `native.Blit`
- `native.StretchBlit`
- `native.Print`

Notes / invariants:

- Callback recognition is name-based in `pathologic_lua_compiler`; `OnDraw` is an engine event name.


## Important constants

- `c_iCWeapon: int = 0` — named behavior/layout value for cweapon.
- `c_iCClothes: int = 1` — named behavior/layout value for cclothes.
- `c_iCategoryCount: int = 5` — fixed limit/count for category count.
- `c_iInventoryCapacity: int = 56` — fixed limit/count for inventory capacity.
- `c_iQuickslotCount: int = 10` — fixed limit/count for quickslot count.
- `c_iWMPlayerAddItem: int = 3` — numeric engine/UI protocol value for wmplayer add item.
- `c_iWMHelpMessage: int = 200` — numeric engine/UI protocol value for wmhelp message.
- `c_iWMQuickslotFeedback: int = 260` — numeric engine/UI protocol value for wmquickslot feedback.
- `c_iWMQuickslotHandsItem: int = 261` — numeric engine/UI protocol value for wmquickslot hands item.
- `c_iInventoryFullTextID: int = 1400` — localized string identifier for inventory full.
- `c_iQuickslotMissingTextID: int = 1405` — localized string identifier for quickslot missing.
- `c_iQuickslotUnusableTextID: int = 1406` — localized string identifier for quickslot unusable.
- `c_fVisibleTime: float = 2.0` — timing value, in seconds, for visible time.
- `c_fMessageCooldown: float = 0.75` — timing value, in seconds, for message cooldown.

## Architectural notes

- This dormant compatibility maintask duplicates substantial binding, activation, and feedback behavior from the active quickslot modules; it is retained because external/save callers have not been ruled out.
