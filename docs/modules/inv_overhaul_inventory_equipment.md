# Inventory Equipment

## Source

`scripts/player_inventory/inv_overhaul_inventory_equipment.lua`

DSL unit: `module inv_overhaul_inventory_equipment`

## Responsibility

Implements equipment compatibility, equip/unequip/replacement, and layout restoration around equipment mutations.

## Dependencies

- `inv_overhaul_inventory_items` — Builds the canonical projection of unequipped player items into backpack ordinals and cached category/index references.
- `inv_overhaul_inventory_protocol` — Defines and encodes the numeric UI message protocol shared by inventory forms and controllers.
- Pathologic native API — engine state, object access, persistence variables, UI messaging, timing, or rendering as listed per function.

## Used by

- `scripts/player_inventory/inv_overhaul_inventory_controller.lua`

## State

- `categoryCache: object` — cached category data used to avoid rebuilding engine/container lookups.
- `indexCache: object` — cached index data used to avoid rebuilding engine/container lookups.

## Public API

All functions below are compiler-visible when the module is imported; the DSL has no private declaration.

### `InitializeCache() -> void`

Source: `scripts/player_inventory/inv_overhaul_inventory_equipment.lua`

Purpose: Initializes cache in the inventory equipment subsystem.

Parameters:

None.

Returns:

None.

Side effects:

- Mutates module/task state: `categoryCache`, `indexCache`.
- Invokes engine/native operations: `native.CreateIntVector`.
- May mutate engine/UI objects through: `categoryCache.add`, `indexCache.add`.

Called by:

- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: PlayerControllerInitialize`

Calls:

- `native.CreateIntVector`
- `categoryCache.add`
- `indexCache.add`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `BuildCache() -> void`

Source: `scripts/player_inventory/inv_overhaul_inventory_equipment.lua`

Purpose: Builds cache in the inventory equipment subsystem.

Parameters:

None.

Returns:

None.

Side effects:

- May mutate engine/UI objects through: `categoryCache.set`, `indexCache.set`, `container.IsItemSelected`.

Called by:

- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: BuildEquipmentIndexCache`

Calls:

- `categoryCache.set`
- `indexCache.set`
- `inv_overhaul_inventory_items.ItemsGetPlayerContainer`
- `container.GetItemCount`
- `container.IsItemSelected`
- `container.GetItem`
- `weapon.GetItemID`
- `native.HasInvItemProperty`
- `clothes.GetItemID`
- `native.GetInvItemProperty`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `PlayerEquipmentGetCachedCategory(cache: int) -> int`

Source: `scripts/player_inventory/inv_overhaul_inventory_equipment.lua`

Purpose: Returns cached category for player equipment in the inventory equipment subsystem.

Parameters:

- `cache: int` — value interpreted according to the function purpose; no narrower contract is established by current code.

Returns:

- `number` (integer) — result of: returns cached category for player equipment in the inventory equipment subsystem.

Side effects:

- None directly observable beyond calls listed below.

Called by:

- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: MeasureInitialTextureCacheCoverage`
- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: PlayerControllerContinueInitialSlotLoad`
- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: UpdateCachedEquipmentSlot`

Calls:

- `categoryCache.get`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `PlayerEquipmentGetCachedIndex(cache: int) -> int`

Source: `scripts/player_inventory/inv_overhaul_inventory_equipment.lua`

Purpose: Returns cached index for player equipment in the inventory equipment subsystem.

Parameters:

- `cache: int` — value interpreted according to the function purpose; no narrower contract is established by current code.

Returns:

- `number` (integer) — result of: returns cached index for player equipment in the inventory equipment subsystem.

Side effects:

- None directly observable beyond calls listed below.

Called by:

- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: MeasureInitialTextureCacheCoverage`
- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: PlayerControllerContinueInitialSlotLoad`
- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: UpdateCachedEquipmentSlot`

Calls:

- `indexCache.get`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `ResolveTarget(target: int) -> int`

Source: `scripts/player_inventory/inv_overhaul_inventory_equipment.lua`

Purpose: Resolves target in the inventory equipment subsystem.

Parameters:

- `target: int` — value interpreted according to the function purpose; no narrower contract is established by current code.

Returns:

- `number` (integer) — result of: resolves target in the inventory equipment subsystem.

Side effects:

- May mutate engine/UI objects through: `container.IsItemSelected`.

Called by:

- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: ResolveEquipmentTarget`

Calls:

- `inv_overhaul_inventory_items.ItemsGetPlayerContainer`
- `container.GetItemCount`
- `container.IsItemSelected`
- `container.GetItem`
- `item.GetItemID`
- `native.HasInvItemProperty`
- `inv_overhaul_inventory_items.ItemsEncodeReference`
- `native.GetInvItemProperty`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `Unequip(category: int, index: int) -> bool`

Source: `scripts/player_inventory/inv_overhaul_inventory_equipment.lua`

Purpose: Unequips inventory equipment in the inventory equipment subsystem.

Parameters:

- `category: int` — zero-based engine inventory category identifier.
- `index: int` — zero-based entry index in the relevant engine container/category.

Returns:

- `boolean` — result of: unequips inventory equipment in the inventory equipment subsystem.

Side effects:

- Invokes engine/native operations: `native.SetPlayerHandsItem`.
- May mutate engine/UI objects through: `container.IsItemSelected`, `container.SelectItem`.

Called by:

- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: UnequipItem`

Calls:

- `inv_overhaul_inventory_items.ItemsGetPlayerContainer`
- `container.IsItemSelected`
- `container.SelectItem`
- `native.SetPlayerHandsItem`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `Equip(target: int, category: int, index: int) -> bool`

Source: `scripts/player_inventory/inv_overhaul_inventory_equipment.lua`

Purpose: Equips inventory equipment in the inventory equipment subsystem.

Parameters:

- `target: int` — value interpreted according to the function purpose; no narrower contract is established by current code.
- `category: int` — zero-based engine inventory category identifier.
- `index: int` — zero-based entry index in the relevant engine container/category.

Returns:

- `boolean` — result of: equips inventory equipment in the inventory equipment subsystem.

Side effects:

- Invokes engine/native operations: `native.SetPlayerHandsItem`.
- May mutate engine/UI objects through: `container.IsItemSelected`, `container.SelectItem`.

Called by:

- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: EquipDraggedItem`

Calls:

- `inv_overhaul_inventory_items.ItemsGetPlayerContainer`
- `container.GetItem`
- `item.GetItemID`
- `native.HasInvItemProperty`
- `native.SetPlayerHandsItem`
- `container.GetItemCount`
- `container.IsItemSelected`
- `container.SelectItem`
- `native.GetInvItemProperty`
- `other.GetItemID`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `PlayerEquipmentToggle(category: int, index: int) -> int`

Source: `scripts/player_inventory/inv_overhaul_inventory_equipment.lua`

Purpose: Toggles player equipment in the inventory equipment subsystem.

Parameters:

- `category: int` — zero-based engine inventory category identifier.
- `index: int` — zero-based entry index in the relevant engine container/category.

Returns:

- `number` (integer) — result of: toggles player equipment in the inventory equipment subsystem.

Side effects:

- Invokes engine/native operations: `native.SetPlayerHandsItem`, `native.UseItem`.
- May mutate engine/UI objects through: `container.IsItemSelected`, `container.SelectItem`, `container.RemoveItem`, `container.SetItemAmount`.

Called by:

- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: ToggleSlot`

Calls:

- `inv_overhaul_inventory_items.ItemsGetPlayerContainer`
- `container.GetItem`
- `item.GetItemID`
- `container.GetItemAmount`
- `container.IsItemSelected`
- `native.HasInvItemProperty`
- `container.SelectItem`
- `native.SetPlayerHandsItem`
- `container.GetItemCount`
- `native.GetInvItemProperty`
- `other.GetItemID`
- `native.UseItem`
- `… and 2 more`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `PlayerEquipmentIsTargetCompatible(target: int, category: int, isWeapon: bool, group: int) -> bool`

Source: `scripts/player_inventory/inv_overhaul_inventory_equipment.lua`

Purpose: Returns whether target compatible for player equipment in the inventory equipment subsystem.

Parameters:

- `target: int` — value interpreted according to the function purpose; no narrower contract is established by current code.
- `category: int` — zero-based engine inventory category identifier.
- `isWeapon: bool` — behavior flag interpreted by this function.
- `group: int` — value interpreted according to the function purpose; no narrower contract is established by current code.

Returns:

- `boolean` — result of: returns whether target compatible for player equipment in the inventory equipment subsystem.

Side effects:

- None directly observable beyond calls listed below.

Called by:

- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: IsSpecialTargetCompatible`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.


## Internal API

No additional maintask helpers.

## Events / callbacks

No engine callbacks; this is an imported module.

## Important constants

- `WeaponCategory: int = 0` — engine inventory category value for weapon category.
- `ClothesCategory: int = 1` — engine inventory category value for clothes category.

## Architectural notes

- No additional module-specific issue identified beyond repository-wide shared-variable and compiler-visible API constraints.
