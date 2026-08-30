# Inventory Quickslot Bindings

## Source

`scripts/quickslots/inv_overhaul_inventory_quickslot_bindings.lua`

DSL unit: `module inv_overhaul_inventory_quickslot_bindings`

## Responsibility

Owns saved quickslot item/category/occurrence bindings and the player-screen binding cache.

## Dependencies

- `inv_overhaul_inventory_items` — Builds the canonical projection of unequipped player items into backpack ordinals and cached category/index references.
- Pathologic native API — engine state, object access, persistence variables, UI messaging, timing, or rendering as listed per function.

## Used by

- `scripts/loot/inv_overhaul_container.lua`
- `scripts/loot/inv_overhaul_container_input_controller.lua`
- `scripts/loot/inv_overhaul_container_presenter.lua`
- `scripts/player_inventory/inv_overhaul_inventory_controller.lua`
- `scripts/player_inventory/inv_overhaul_inventory_presenter.lua`

## State

- `itemCache: object` — cached item data used to avoid rebuilding engine/container lookups.
- `categoryCache: object` — cached category data used to avoid rebuilding engine/container lookups.
- `occurrenceCache: object` — cached occurrence data used to avoid rebuilding engine/container lookups.

## Public API

All functions below are compiler-visible when the module is imported; the DSL has no private declaration.

### `QuickslotBindingsInitializeState() -> void`

Source: `scripts/quickslots/inv_overhaul_inventory_quickslot_bindings.lua`

Purpose: Initializes state for quickslot bindings in the inventory quickslot bindings subsystem.

Parameters:

None.

Returns:

None.

Side effects:

- Mutates module/task state: `itemCache`, `categoryCache`, `occurrenceCache`.
- Invokes engine/native operations: `native.CreateIntVector`.
- May mutate engine/UI objects through: `itemCache.add`, `categoryCache.add`, `occurrenceCache.add`.

Called by:

- `scripts/loot/inv_overhaul_container.lua :: init`
- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: PlayerControllerInitialize`

Calls:

- `native.CreateIntVector`
- `itemCache.add`
- `categoryCache.add`
- `occurrenceCache.add`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `GetItemVariable(slot: int) -> string`

Source: `scripts/quickslots/inv_overhaul_inventory_quickslot_bindings.lua`

Purpose: Returns item variable in the inventory quickslot bindings subsystem.

Parameters:

- `slot: int` — 1-based quickslot number.

Returns:

- `string` — result of: returns item variable in the inventory quickslot bindings subsystem.

Side effects:

- None directly observable beyond calls listed below.

Called by:

- `scripts/quickslots/inv_overhaul_inventory_quickslot_bindings.lua :: InitializeBindings`
- `scripts/quickslots/inv_overhaul_inventory_quickslot_bindings.lua :: RefreshCache`
- `scripts/quickslots/inv_overhaul_inventory_quickslot_bindings.lua :: Assign`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `GetCategoryVariable(slot: int) -> string`

Source: `scripts/quickslots/inv_overhaul_inventory_quickslot_bindings.lua`

Purpose: Returns category variable in the inventory quickslot bindings subsystem.

Parameters:

- `slot: int` — 1-based quickslot number.

Returns:

- `string` — result of: returns category variable in the inventory quickslot bindings subsystem.

Side effects:

- None directly observable beyond calls listed below.

Called by:

- `scripts/quickslots/inv_overhaul_inventory_quickslot_bindings.lua :: InitializeBindings`
- `scripts/quickslots/inv_overhaul_inventory_quickslot_bindings.lua :: RefreshCache`
- `scripts/quickslots/inv_overhaul_inventory_quickslot_bindings.lua :: Assign`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `GetDepletedVariable(slot: int) -> string`

Source: `scripts/quickslots/inv_overhaul_inventory_quickslot_bindings.lua`

Purpose: Returns depleted variable in the inventory quickslot bindings subsystem.

Parameters:

- `slot: int` — 1-based quickslot number.

Returns:

- `string` — result of: returns depleted variable in the inventory quickslot bindings subsystem.

Side effects:

- None directly observable beyond calls listed below.

Called by:

- `scripts/quickslots/inv_overhaul_inventory_quickslot_bindings.lua :: Assign`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `GetOccurrenceVariable(slot: int) -> string`

Source: `scripts/quickslots/inv_overhaul_inventory_quickslot_bindings.lua`

Purpose: Returns occurrence variable in the inventory quickslot bindings subsystem.

Parameters:

- `slot: int` — 1-based quickslot number.

Returns:

- `string` — result of: returns occurrence variable in the inventory quickslot bindings subsystem.

Side effects:

- None directly observable beyond calls listed below.

Called by:

- `scripts/quickslots/inv_overhaul_inventory_quickslot_bindings.lua :: RefreshCache`
- `scripts/quickslots/inv_overhaul_inventory_quickslot_bindings.lua :: Assign`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `InitializeBindings() -> void`

Source: `scripts/quickslots/inv_overhaul_inventory_quickslot_bindings.lua`

Purpose: Initializes bindings in the inventory quickslot bindings subsystem.

Parameters:

None.

Returns:

None.

Side effects:

- Writes shared engine variable(s): `computed value`, `"inv_overhaul_quickslot_version"`.
- Invokes engine/native operations: `native.SetVariable`.

Called by:

- `scripts/loot/inv_overhaul_container.lua :: init`
- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: InitializeQuickslotBindings`

Calls:

- `native.GetVariable`
- `native.SetVariable`
- `GetItemVariable`
- `GetCategoryVariable`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `RefreshCache() -> void`

Source: `scripts/quickslots/inv_overhaul_inventory_quickslot_bindings.lua`

Purpose: Refreshes cache in the inventory quickslot bindings subsystem.

Parameters:

None.

Returns:

None.

Side effects:

- May mutate engine/UI objects through: `categoryCache.set`, `itemCache.set`, `occurrenceCache.set`.

Called by:

- `scripts/loot/inv_overhaul_container.lua :: init`
- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: RefreshQuickslotCache`

Calls:

- `native.GetVariable`
- `GetCategoryVariable`
- `GetItemVariable`
- `GetOccurrenceVariable`
- `categoryCache.set`
- `itemCache.set`
- `occurrenceCache.set`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `GetItemBinding(category: int, itemID: int) -> int`

Source: `scripts/quickslots/inv_overhaul_inventory_quickslot_bindings.lua`

Purpose: Returns item binding in the inventory quickslot bindings subsystem.

Parameters:

- `category: int` — zero-based engine inventory category identifier.
- `itemID: int` — engine item or callback identifier interpreted by this function.

Returns:

- `number` (integer) — result of: returns item binding in the inventory quickslot bindings subsystem.

Side effects:

- None directly observable beyond calls listed below.

Called by:

- `scripts/quickslots/inv_overhaul_inventory_quickslot_bindings.lua :: GetDisplayedBinding`

Calls:

- `categoryCache.get`
- `itemCache.get`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `GetDisplayedBinding(category: int, index: int, itemID: int) -> int`

Source: `scripts/quickslots/inv_overhaul_inventory_quickslot_bindings.lua`

Purpose: Returns displayed binding in the inventory quickslot bindings subsystem.

Parameters:

- `category: int` — zero-based engine inventory category identifier.
- `index: int` — zero-based entry index in the relevant engine container/category.
- `itemID: int` — engine item or callback identifier interpreted by this function.

Returns:

- `number` (integer) — result of: returns displayed binding in the inventory quickslot bindings subsystem.

Side effects:

- Delegates to compiler-visible module APIs and inherits their documented side effects.

Called by:

- `scripts/loot/inv_overhaul_container_presenter.lua :: UpdatePlayerSlot`
- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: GetDisplayedQuickslot`
- `scripts/player_inventory/inv_overhaul_inventory_presenter.lua :: PlayerPresenterUpdateSlot`
- `scripts/player_inventory/inv_overhaul_inventory_presenter.lua :: UpdateEquipmentSlot`

Calls:

- `GetItemBinding`
- `inv_overhaul_inventory_items.GetOccurrence`
- `categoryCache.get`
- `itemCache.get`
- `occurrenceCache.get`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `IsEligible(category: int, itemID: int) -> bool`

Source: `scripts/quickslots/inv_overhaul_inventory_quickslot_bindings.lua`

Purpose: Returns whether eligible in the inventory quickslot bindings subsystem.

Parameters:

- `category: int` — zero-based engine inventory category identifier.
- `itemID: int` — engine item or callback identifier interpreted by this function.

Returns:

- `boolean` — result of: returns whether eligible in the inventory quickslot bindings subsystem.

Side effects:

- None directly observable beyond calls listed below.

Called by:

- `scripts/quickslots/inv_overhaul_inventory_quickslot_bindings.lua :: Assign`

Calls:

- `native.HasInvItemProperty`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `Assign(slot: int, category: int, index: int, emitTrace: bool) -> bool`

Source: `scripts/quickslots/inv_overhaul_inventory_quickslot_bindings.lua`

Purpose: Assigns inventory quickslot bindings in the inventory quickslot bindings subsystem.

Parameters:

- `slot: int` — 1-based quickslot number.
- `category: int` — zero-based engine inventory category identifier.
- `index: int` — zero-based entry index in the relevant engine container/category.
- `emitTrace: bool` — behavior flag interpreted by this function.

Returns:

- `boolean` — result of: assigns inventory quickslot bindings in the inventory quickslot bindings subsystem.

Side effects:

- Writes shared engine variable(s): `computed value`.
- Invokes engine/native operations: `native.SetVariable`, `native.Trace`.
- May mutate engine/UI objects through: `categoryCache.set`, `itemCache.set`, `occurrenceCache.set`.

Called by:

- `scripts/loot/inv_overhaul_container_input_controller.lua :: LootInputAssignHoveredQuickslot`
- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: AssignQuickslot`

Calls:

- `inv_overhaul_inventory_items.ItemsGetPlayerContainer`
- `container.GetItem`
- `item.GetItemID`
- `IsEligible`
- `inv_overhaul_inventory_items.GetOccurrence`
- `native.GetVariable`
- `GetCategoryVariable`
- `GetItemVariable`
- `GetOccurrenceVariable`
- `native.SetVariable`
- `GetDepletedVariable`
- `categoryCache.set`
- `… and 3 more`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `GetSlotByKey(key: int) -> int`

Source: `scripts/quickslots/inv_overhaul_inventory_quickslot_bindings.lua`

Purpose: Returns slot by key in the inventory quickslot bindings subsystem.

Parameters:

- `key: int` — value interpreted according to the function purpose; no narrower contract is established by current code.

Returns:

- `number` (integer) — result of: returns slot by key in the inventory quickslot bindings subsystem.

Side effects:

- None directly observable beyond calls listed below.

Called by:

- `scripts/loot/inv_overhaul_container_input_controller.lua :: HandleKeyDown`
- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: GetQuickslotByKey`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.


## Internal API

No additional maintask helpers.

## Events / callbacks

No engine callbacks; this is an imported module.

## Important constants

- `QuickslotCount: int = 10` — fixed limit/count for quickslot count.
- `QuickslotVersion: int = 1` — schema/runtime version marker for quickslot version.
- `WeaponCategory: int = 0` — engine inventory category value for weapon category.
- `ClothesCategory: int = 1` — engine inventory category value for clothes category.
- `CategoryCount: int = 5` — fixed limit/count for category count.

## Architectural notes

- No additional module-specific issue identified beyond repository-wide shared-variable and compiler-visible API constraints.
