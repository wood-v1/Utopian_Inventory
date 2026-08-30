# Quickslot Weapon

## Source

`scripts/quickslots/inv_overhaul_quickslot_weapon.lua`

DSL unit: `maintask InvOverhaulQuickslotWeaponEffect`

## Responsibility

Applies weapon selection for the quickslot runtime and records the active weapon identity.

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

### `GetPlayer() -> object`

Source: `scripts/quickslots/inv_overhaul_quickslot_weapon.lua`

Purpose: Returns player in the quickslot weapon subsystem.

Parameters:

None.

Returns:

- `object` — result of: returns player in the quickslot weapon subsystem.

Side effects:

- None directly observable beyond calls listed below.

Called by:

- `scripts/quickslots/inv_overhaul_quickslot_weapon.lua :: FindWeaponIndex`
- `scripts/quickslots/inv_overhaul_quickslot_weapon.lua :: IsEquippedItem`
- `scripts/quickslots/inv_overhaul_quickslot_weapon.lua :: GetBackpackItemCount`
- `scripts/quickslots/inv_overhaul_quickslot_weapon.lua :: init`

Calls:

- `native.self`

Notes / invariants:

- Maintask helper; callable within its task unless the engine invokes it by a documented callback name.

### `FindWeaponIndex(itemID: int, wantedOccurrence: int) -> int`

Source: `scripts/quickslots/inv_overhaul_quickslot_weapon.lua`

Purpose: Finds weapon index in the quickslot weapon subsystem.

Parameters:

- `itemID: int` — engine item or callback identifier interpreted by this function.
- `wantedOccurrence: int` — zero-based occurrence of an item ID within its category.

Returns:

- `number` (integer) — result of: finds weapon index in the quickslot weapon subsystem.

Side effects:

- None directly observable beyond calls listed below.

Called by:

- `scripts/quickslots/inv_overhaul_quickslot_weapon.lua :: init`

Calls:

- `GetPlayer`
- `player.GetItemCount`
- `player.GetItem`
- `item.GetItemID`

Notes / invariants:

- Maintask helper; callable within its task unless the engine invokes it by a documented callback name.

### `IsEquippedItem(category: int, index: int) -> bool`

Source: `scripts/quickslots/inv_overhaul_quickslot_weapon.lua`

Purpose: Returns whether equipped item in the quickslot weapon subsystem.

Parameters:

- `category: int` — zero-based engine inventory category identifier.
- `index: int` — zero-based entry index in the relevant engine container/category.

Returns:

- `boolean` — result of: returns whether equipped item in the quickslot weapon subsystem.

Side effects:

- May mutate engine/UI objects through: `player.IsItemSelected`.

Called by:

- `scripts/quickslots/inv_overhaul_quickslot_weapon.lua :: GetBackpackItemCount`

Calls:

- `GetPlayer`
- `player.IsItemSelected`

Notes / invariants:

- Maintask helper; callable within its task unless the engine invokes it by a documented callback name.

### `GetBackpackItemCount() -> int`

Source: `scripts/quickslots/inv_overhaul_quickslot_weapon.lua`

Purpose: Returns backpack item count in the quickslot weapon subsystem.

Parameters:

None.

Returns:

- `number` (integer) — result of: returns backpack item count in the quickslot weapon subsystem.

Side effects:

- None directly observable beyond calls listed below.

Called by:

- `scripts/quickslots/inv_overhaul_quickslot_weapon.lua :: init`

Calls:

- `GetPlayer`
- `player.GetItemCount`
- `IsEquippedItem`

Notes / invariants:

- Maintask helper; callable within its task unless the engine invokes it by a documented callback name.

### `ShowMessage(textID: int) -> void`

Source: `scripts/quickslots/inv_overhaul_quickslot_weapon.lua`

Purpose: Shows message in the quickslot weapon subsystem.

Parameters:

- `textID: int` — value interpreted according to the function purpose; no narrower contract is established by current code.

Returns:

None.

Side effects:

- Invokes engine/native operations: `native.CreateIntVector`, `native.SendWorldWndMessage`.
- May mutate engine/UI objects through: `data.add`.

Called by:

- `scripts/quickslots/inv_overhaul_quickslot_weapon.lua :: init`

Calls:

- `native.CreateIntVector`
- `data.add`
- `native.SendWorldWndMessage`

Notes / invariants:

- Maintask helper; callable within its task unless the engine invokes it by a documented callback name.

### `ShowFeedback(itemID: int) -> void`

Source: `scripts/quickslots/inv_overhaul_quickslot_weapon.lua`

Purpose: Shows feedback in the quickslot weapon subsystem.

Parameters:

- `itemID: int` — engine item or callback identifier interpreted by this function.

Returns:

None.

Side effects:

- Invokes engine/native operations: `native.CreateIntVector`, `native.SendWorldWndMessage`.
- May mutate engine/UI objects through: `data.add`.

Called by:

- `scripts/quickslots/inv_overhaul_quickslot_weapon.lua :: init`

Calls:

- `native.CreateIntVector`
- `data.add`
- `native.SendWorldWndMessage`

Notes / invariants:

- Maintask helper; callable within its task unless the engine invokes it by a documented callback name.

### `MarkInventoryChanged() -> void`

Source: `scripts/quickslots/inv_overhaul_quickslot_weapon.lua`

Purpose: Marks inventory changed in the quickslot weapon subsystem.

Parameters:

None.

Returns:

None.

Side effects:

- Writes shared engine variable(s): `"inv_overhaul_inventory_reorder_generation"`.
- Invokes engine/native operations: `native.SetVariable`.

Called by:

- `scripts/quickslots/inv_overhaul_quickslot_weapon.lua :: init`

Calls:

- `native.GetVariable`
- `native.SetVariable`

Notes / invariants:

- Maintask helper; callable within its task unless the engine invokes it by a documented callback name.


## Events / callbacks

### `init() -> void`

Source: `scripts/quickslots/inv_overhaul_quickslot_weapon.lua`

Purpose: Initializes the quickslot weapon runtime and establishes its starting state and engine/UI integration.

Parameters:

None.

Returns:

None.

Side effects:

- Invokes engine/native operations: `native.Trace`.
- May mutate engine/UI objects through: `player.IsItemSelected`, `player.SelectItem`, `player.SelectWeapon`.

Called by:

- No in-repository caller was resolved; this may be an engine/XML callback or a conventionally public helper.

Calls:

- `native.GetVariable`
- `FindWeaponIndex`
- `ShowMessage`
- `GetPlayer`
- `player.IsItemSelected`
- `native.Trace`
- `GetBackpackItemCount`
- `player.SelectItem`
- `player.SelectWeapon`
- `MarkInventoryChanged`
- `ShowFeedback`
- `player.GetItemCount`

Notes / invariants:

- Maintask helper; callable within its task unless the engine invokes it by a documented callback name.


## Important constants

- `c_iCWeapon: int = 0` — named behavior/layout value for cweapon.
- `c_iCClothes: int = 1` — named behavior/layout value for cclothes.
- `c_iCategoryCount: int = 5` — fixed limit/count for category count.
- `c_iInventoryCapacity: int = 56` — fixed limit/count for inventory capacity.
- `c_iWMHelpMessage: int = 200` — numeric engine/UI protocol value for wmhelp message.
- `c_iWMPlayerAddItem: int = 3` — numeric engine/UI protocol value for wmplayer add item.
- `c_iInventoryFullTextID: int = 1400` — localized string identifier for inventory full.
- `c_iQuickslotMissingTextID: int = 1405` — localized string identifier for quickslot missing.

## Architectural notes

- No additional module-specific issue identified beyond repository-wide shared-variable and compiler-visible API constraints.
