# Inventory Items

## Source

`scripts/backpack/inv_overhaul_inventory_items.lua`

DSL unit: `module inv_overhaul_inventory_items`

## Responsibility

Builds the canonical projection of unequipped player items into backpack ordinals and cached category/index references.

## Dependencies

- No local DSL imports.
- Pathologic native API — engine state, object access, persistence variables, UI messaging, timing, or rendering as listed per function.

## Used by

- `scripts/backpack/inv_overhaul_inventory_snapshot.lua`
- `scripts/loot/inv_overhaul_container.lua`
- `scripts/loot/inv_overhaul_container_bootstrap.lua`
- `scripts/loot/inv_overhaul_container_drag_controller.lua`
- `scripts/loot/inv_overhaul_container_input_controller.lua`
- `scripts/loot/inv_overhaul_container_player_actions.lua`
- `scripts/loot/inv_overhaul_container_presenter.lua`
- `scripts/loot/inv_overhaul_container_quick_transfer.lua`
- `scripts/loot/inv_overhaul_container_tooltip_controller.lua`
- `scripts/loot/inv_overhaul_container_transfer.lua`
- `scripts/loot/inv_overhaul_container_transfer_external.lua`
- `scripts/loot/inv_overhaul_container_transfer_player.lua`
- `scripts/player_inventory/inv_overhaul_inventory_controller.lua`
- `scripts/player_inventory/inv_overhaul_inventory_drop.lua`
- `scripts/player_inventory/inv_overhaul_inventory_equipment.lua`
- `scripts/player_inventory/inv_overhaul_inventory_presenter.lua`
- `scripts/quickslots/inv_overhaul_inventory_quickslot_bindings.lua`

## State

- `categoryCache: object` — cached category data used to avoid rebuilding engine/container lookups.
- `indexCache: object` — cached index data used to avoid rebuilding engine/container lookups.
- `cachedBackpackCount: int` — cached d backpack count data used to avoid rebuilding engine/container lookups.

## Public API

All functions below are compiler-visible when the module is imported; the DSL has no private declaration.

### `InitializeProjection() -> void`

Source: `scripts/backpack/inv_overhaul_inventory_items.lua`

Purpose: Initializes projection in the inventory items subsystem.

Parameters:

None.

Returns:

None.

Side effects:

- Mutates module/task state: `categoryCache`, `indexCache`, `cachedBackpackCount`.
- Invokes engine/native operations: `native.CreateIntVector`.
- May mutate engine/UI objects through: `categoryCache.add`, `indexCache.add`.

Called by:

- `scripts/loot/inv_overhaul_container.lua :: init`
- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: PlayerControllerInitialize`

Calls:

- `native.CreateIntVector`
- `categoryCache.add`
- `indexCache.add`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `ItemsGetPlayerContainer() -> object`

Source: `scripts/backpack/inv_overhaul_inventory_items.lua`

Purpose: Returns player container for items in the inventory items subsystem.

Parameters:

None.

Returns:

- `object` — result of: returns player container for items in the inventory items subsystem.

Side effects:

- None directly observable beyond calls listed below.

Called by:

- `scripts/backpack/inv_overhaul_inventory_items.lua :: IsEquipped`
- `scripts/backpack/inv_overhaul_inventory_items.lua :: GetBackpackCount`
- `scripts/backpack/inv_overhaul_inventory_items.lua :: CaptureIdentitySnapshot`
- `scripts/backpack/inv_overhaul_inventory_items.lua :: ItemsBuildIndexCache`
- `scripts/backpack/inv_overhaul_inventory_items.lua :: BuildIndexCacheAndSnapshot`
- `scripts/backpack/inv_overhaul_inventory_items.lua :: ItemsGetBackpackOrdinal`
- `scripts/backpack/inv_overhaul_inventory_items.lua :: GetOccurrence`
- `scripts/loot/inv_overhaul_container_drag_controller.lua :: ResolveSource`
- `… and 16 more`

Calls:

- `native.GetPlayerContainer`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `IsEquipped(category: int, index: int) -> bool`

Source: `scripts/backpack/inv_overhaul_inventory_items.lua`

Purpose: Returns whether equipped in the inventory items subsystem.

Parameters:

- `category: int` — zero-based engine inventory category identifier.
- `index: int` — zero-based entry index in the relevant engine container/category.

Returns:

- `boolean` — result of: returns whether equipped in the inventory items subsystem.

Side effects:

- May mutate engine/UI objects through: `container.IsItemSelected`.

Called by:

- `scripts/backpack/inv_overhaul_inventory_items.lua :: GetBackpackCount`
- `scripts/backpack/inv_overhaul_inventory_items.lua :: CaptureIdentitySnapshot`
- `scripts/backpack/inv_overhaul_inventory_items.lua :: ItemsBuildIndexCache`
- `scripts/backpack/inv_overhaul_inventory_items.lua :: BuildIndexCacheAndSnapshot`
- `scripts/backpack/inv_overhaul_inventory_items.lua :: ItemsGetBackpackOrdinal`
- `scripts/loot/inv_overhaul_container_transfer.lua :: FindPlayerMergeIndex`

Calls:

- `ItemsGetPlayerContainer`
- `container.IsItemSelected`
- `container.GetItem`
- `item.GetItemID`
- `native.HasInvItemProperty`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `GetBackpackCount() -> int`

Source: `scripts/backpack/inv_overhaul_inventory_items.lua`

Purpose: Returns backpack count in the inventory items subsystem.

Parameters:

None.

Returns:

- `number` (integer) — result of: returns backpack count in the inventory items subsystem.

Side effects:

- None directly observable beyond calls listed below.

Called by:

- `scripts/loot/inv_overhaul_container_bootstrap.lua :: LootBootstrapOrderFreeCellsByDisplay`
- `scripts/loot/inv_overhaul_container_player_actions.lua :: DropToWorld`
- `scripts/loot/inv_overhaul_container_player_actions.lua :: LootPlayerActionsMoveSlotToOtherPage`
- `scripts/loot/inv_overhaul_container_quick_transfer.lua :: Execute`
- `scripts/loot/inv_overhaul_container_transfer_external.lua :: MoveResolvedAmountToPlayer`
- `scripts/loot/inv_overhaul_container_transfer_player.lua :: MoveAmountToContainer`
- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: PlayerControllerGetBackpackItemCount`

Calls:

- `ItemsGetPlayerContainer`
- `container.GetItemCount`
- `IsEquipped`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `CaptureIdentitySnapshot(snapshot: object) -> int`

Source: `scripts/backpack/inv_overhaul_inventory_items.lua`

Purpose: Captures identity snapshot in the inventory items subsystem.

Parameters:

- `snapshot: object` — engine object/vector; type/shape not fully determined beyond the method usage in current code.

Returns:

- `number` (integer) — result of: captures identity snapshot in the inventory items subsystem.

Side effects:

- May mutate engine/UI objects through: `snapshot.set`.

Called by:

- `scripts/backpack/inv_overhaul_inventory_snapshot.lua :: CapturePrevious`
- `scripts/backpack/inv_overhaul_inventory_snapshot.lua :: CaptureCurrentCount`
- `scripts/backpack/inv_overhaul_inventory_snapshot.lua :: RestoreAfterEquipmentReplacement`
- `scripts/backpack/inv_overhaul_inventory_snapshot.lua :: RestoreAfterEquipmentSelection`

Calls:

- `ItemsGetPlayerContainer`
- `snapshot.set`
- `container.GetItemCount`
- `IsEquipped`
- `container.GetItem`
- `item.GetItemID`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `ItemsBuildIndexCache() -> void`

Source: `scripts/backpack/inv_overhaul_inventory_items.lua`

Purpose: Builds index cache for items in the inventory items subsystem.

Parameters:

None.

Returns:

None.

Side effects:

- Mutates module/task state: `cachedBackpackCount`.
- May mutate engine/UI objects through: `categoryCache.set`, `indexCache.set`.

Called by:

- `scripts/loot/inv_overhaul_container_presenter.lua :: UpdatePlayerSlots`
- `scripts/loot/inv_overhaul_container_presenter.lua :: LootPresenterBeginInitialSlotLoad`
- `scripts/loot/inv_overhaul_container_transfer_external.lua :: InsertPlayerCache`
- `scripts/loot/inv_overhaul_container_transfer_external.lua :: MoveResolvedAmountToPlayer`
- `scripts/loot/inv_overhaul_container_transfer_player.lua :: RemovePlayerCache`
- `scripts/loot/inv_overhaul_container_transfer_player.lua :: MoveAmountToContainer`
- `scripts/loot/inv_overhaul_container_transfer_player.lua :: ExchangeWithContainer`
- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: BuildBackpackIndexCache`

Calls:

- `categoryCache.set`
- `indexCache.set`
- `ItemsGetPlayerContainer`
- `container.GetItemCount`
- `IsEquipped`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `BuildIndexCacheAndSnapshot(snapshot: object) -> int`

Source: `scripts/backpack/inv_overhaul_inventory_items.lua`

Purpose: Builds index cache and snapshot in the inventory items subsystem.

Parameters:

- `snapshot: object` — engine object/vector; type/shape not fully determined beyond the method usage in current code.

Returns:

- `number` (integer) — result of: builds index cache and snapshot in the inventory items subsystem.

Side effects:

- Mutates module/task state: `cachedBackpackCount`.
- May mutate engine/UI objects through: `categoryCache.set`, `indexCache.set`, `snapshot.set`.

Called by:

- `scripts/backpack/inv_overhaul_inventory_snapshot.lua :: BuildIndexCacheAndPrevious`

Calls:

- `categoryCache.set`
- `indexCache.set`
- `snapshot.set`
- `ItemsGetPlayerContainer`
- `container.GetItemCount`
- `IsEquipped`
- `container.GetItem`
- `item.GetItemID`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `GetCachedBackpackCount() -> int`

Source: `scripts/backpack/inv_overhaul_inventory_items.lua`

Purpose: Returns cached backpack count in the inventory items subsystem.

Parameters:

None.

Returns:

- `number` (integer) — result of: returns cached backpack count in the inventory items subsystem.

Side effects:

- None directly observable beyond calls listed below.

Called by:

- `scripts/loot/inv_overhaul_container_presenter.lua :: ContinueCachedPlayerEntryRefresh`
- `scripts/loot/inv_overhaul_container_transfer_external.lua :: MoveResolvedAmountToPlayer`
- `scripts/loot/inv_overhaul_container_transfer_player.lua :: MoveAmountToContainer`
- `scripts/loot/inv_overhaul_container_transfer_player.lua :: ExchangeWithContainer`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `GetAppendedCategoryOrdinal(category: int, beforeCount: int) -> int`

Source: `scripts/backpack/inv_overhaul_inventory_items.lua`

Purpose: Returns appended category ordinal in the inventory items subsystem.

Parameters:

- `category: int` — zero-based engine inventory category identifier.
- `beforeCount: int` — value interpreted according to the function purpose; no narrower contract is established by current code.

Returns:

- `number` (integer) — result of: returns appended category ordinal in the inventory items subsystem.

Side effects:

- None directly observable beyond calls listed below.

Called by:

- `scripts/loot/inv_overhaul_container_transfer_external.lua :: GetAppendedBackpackOrdinal`

Calls:

- `categoryCache.get`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `InsertCachedEntry(insertedOrdinal: int, beforeCount: int, category: int, index: int) -> void`

Source: `scripts/backpack/inv_overhaul_inventory_items.lua`

Purpose: Inserts cached entry in the inventory items subsystem.

Parameters:

- `insertedOrdinal: int` — value interpreted according to the function purpose; no narrower contract is established by current code.
- `beforeCount: int` — value interpreted according to the function purpose; no narrower contract is established by current code.
- `category: int` — zero-based engine inventory category identifier.
- `index: int` — zero-based entry index in the relevant engine container/category.

Returns:

None.

Side effects:

- Mutates module/task state: `cachedBackpackCount`.
- May mutate engine/UI objects through: `categoryCache.set`, `indexCache.set`.

Called by:

- `scripts/loot/inv_overhaul_container_transfer_external.lua :: InsertPlayerCache`

Calls:

- `categoryCache.get`
- `indexCache.get`
- `categoryCache.set`
- `indexCache.set`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `RemoveCachedEntry(removedOrdinal: int, beforeCount: int, removedCategory: int, removedIndex: int) -> void`

Source: `scripts/backpack/inv_overhaul_inventory_items.lua`

Purpose: Removes cached entry in the inventory items subsystem.

Parameters:

- `removedOrdinal: int` — value interpreted according to the function purpose; no narrower contract is established by current code.
- `beforeCount: int` — value interpreted according to the function purpose; no narrower contract is established by current code.
- `removedCategory: int` — zero-based engine inventory category identifier.
- `removedIndex: int` — zero-based entry index in the relevant engine container/category.

Returns:

None.

Side effects:

- Mutates module/task state: `cachedBackpackCount`.
- May mutate engine/UI objects through: `categoryCache.set`, `indexCache.set`.

Called by:

- `scripts/loot/inv_overhaul_container_transfer_player.lua :: RemovePlayerCache`

Calls:

- `categoryCache.get`
- `indexCache.get`
- `categoryCache.set`
- `indexCache.set`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `ItemsGetBackpackOrdinal(category: int, index: int) -> int`

Source: `scripts/backpack/inv_overhaul_inventory_items.lua`

Purpose: Returns backpack ordinal for items in the inventory items subsystem.

Parameters:

- `category: int` — zero-based engine inventory category identifier.
- `index: int` — zero-based entry index in the relevant engine container/category.

Returns:

- `number` (integer) — result of: returns backpack ordinal for items in the inventory items subsystem.

Side effects:

- None directly observable beyond calls listed below.

Called by:

- `scripts/loot/inv_overhaul_container_player_actions.lua :: DropToWorld`
- `scripts/loot/inv_overhaul_container_transfer_player.lua :: MoveAmountToContainer`
- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: PlayerControllerGetBackpackOrdinal`

Calls:

- `ItemsGetPlayerContainer`
- `container.GetItemCount`
- `IsEquipped`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `GetOccurrence(category: int, index: int, itemID: int) -> int`

Source: `scripts/backpack/inv_overhaul_inventory_items.lua`

Purpose: Returns occurrence in the inventory items subsystem.

Parameters:

- `category: int` — zero-based engine inventory category identifier.
- `index: int` — zero-based entry index in the relevant engine container/category.
- `itemID: int` — engine item or callback identifier interpreted by this function.

Returns:

- `number` (integer) — result of: returns occurrence in the inventory items subsystem.

Side effects:

- None directly observable beyond calls listed below.

Called by:

- `scripts/quickslots/inv_overhaul_inventory_quickslot_bindings.lua :: GetDisplayedBinding`
- `scripts/quickslots/inv_overhaul_inventory_quickslot_bindings.lua :: Assign`

Calls:

- `ItemsGetPlayerContainer`
- `container.GetItem`
- `candidateItem.GetItemID`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `ItemsEncodeReference(category: int, index: int) -> int`

Source: `scripts/backpack/inv_overhaul_inventory_items.lua`

Purpose: Encodes reference for items in the inventory items subsystem.

Parameters:

- `category: int` — zero-based engine inventory category identifier.
- `index: int` — zero-based entry index in the relevant engine container/category.

Returns:

- `number` (integer) — result of: encodes reference for items in the inventory items subsystem.

Side effects:

- None directly observable beyond calls listed below.

Called by:

- `scripts/backpack/inv_overhaul_inventory_items.lua :: ResolveCachedOrdinal`
- `scripts/player_inventory/inv_overhaul_inventory_equipment.lua :: ResolveTarget`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `ResolveCachedOrdinal(ordinal: int) -> int`

Source: `scripts/backpack/inv_overhaul_inventory_items.lua`

Purpose: Resolves cached ordinal in the inventory items subsystem.

Parameters:

- `ordinal: int` — value interpreted according to the function purpose; no narrower contract is established by current code.

Returns:

- `number` (integer) — result of: resolves cached ordinal in the inventory items subsystem.

Side effects:

- None directly observable beyond calls listed below.

Called by:

- `scripts/loot/inv_overhaul_container_presenter.lua :: LootPresenterResolveVisibleSlot`
- `scripts/loot/inv_overhaul_container_tooltip_controller.lua :: ResolvePlayerItem`
- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: PlayerControllerResolveVisibleSlot`

Calls:

- `categoryCache.get`
- `indexCache.get`
- `ItemsEncodeReference`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `ItemsGetCachedCategory(ordinal: int) -> int`

Source: `scripts/backpack/inv_overhaul_inventory_items.lua`

Purpose: Returns cached category for items in the inventory items subsystem.

Parameters:

- `ordinal: int` — value interpreted according to the function purpose; no narrower contract is established by current code.

Returns:

- `number` (integer) — result of: returns cached category for items in the inventory items subsystem.

Side effects:

- None directly observable beyond calls listed below.

Called by:

- `scripts/loot/inv_overhaul_container_presenter.lua :: ContinueCachedPlayerEntryRefresh`
- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: MeasureInitialTextureCacheCoverage`

Calls:

- `categoryCache.get`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `ItemsGetCachedIndex(ordinal: int) -> int`

Source: `scripts/backpack/inv_overhaul_inventory_items.lua`

Purpose: Returns cached index for items in the inventory items subsystem.

Parameters:

- `ordinal: int` — value interpreted according to the function purpose; no narrower contract is established by current code.

Returns:

- `number` (integer) — result of: returns cached index for items in the inventory items subsystem.

Side effects:

- None directly observable beyond calls listed below.

Called by:

- `scripts/loot/inv_overhaul_container_presenter.lua :: ContinueCachedPlayerEntryRefresh`
- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: MeasureInitialTextureCacheCoverage`

Calls:

- `indexCache.get`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `DecodeReferenceCategory(reference: int) -> int`

Source: `scripts/backpack/inv_overhaul_inventory_items.lua`

Purpose: Decodes reference category in the inventory items subsystem.

Parameters:

- `reference: int` — value interpreted according to the function purpose; no narrower contract is established by current code.

Returns:

- `number` (integer) — result of: decodes reference category in the inventory items subsystem.

Side effects:

- None directly observable beyond calls listed below.

Called by:

- `scripts/loot/inv_overhaul_container_drag_controller.lua :: ResolveSource`
- `scripts/loot/inv_overhaul_container_input_controller.lua :: LootInputAssignHoveredQuickslot`
- `scripts/loot/inv_overhaul_container_input_controller.lua :: LootInputHandleModifiedDrop`
- `scripts/loot/inv_overhaul_container_player_actions.lua :: DropToWorld`
- `scripts/loot/inv_overhaul_container_presenter.lua :: UpdatePlayerSlot`
- `scripts/loot/inv_overhaul_container_tooltip_controller.lua :: ResolvePlayerItem`
- `scripts/loot/inv_overhaul_container_transfer_player.lua :: MoveAmountToContainer`
- `scripts/loot/inv_overhaul_container_transfer_player.lua :: ExchangeWithContainer`
- `… and 8 more`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `DecodeReferenceIndex(reference: int) -> int`

Source: `scripts/backpack/inv_overhaul_inventory_items.lua`

Purpose: Decodes reference index in the inventory items subsystem.

Parameters:

- `reference: int` — value interpreted according to the function purpose; no narrower contract is established by current code.

Returns:

- `number` (integer) — result of: decodes reference index in the inventory items subsystem.

Side effects:

- None directly observable beyond calls listed below.

Called by:

- `scripts/loot/inv_overhaul_container_drag_controller.lua :: ResolveSource`
- `scripts/loot/inv_overhaul_container_input_controller.lua :: LootInputAssignHoveredQuickslot`
- `scripts/loot/inv_overhaul_container_input_controller.lua :: LootInputHandleModifiedDrop`
- `scripts/loot/inv_overhaul_container_player_actions.lua :: DropToWorld`
- `scripts/loot/inv_overhaul_container_presenter.lua :: UpdatePlayerSlot`
- `scripts/loot/inv_overhaul_container_tooltip_controller.lua :: ResolvePlayerItem`
- `scripts/loot/inv_overhaul_container_transfer_player.lua :: MoveAmountToContainer`
- `scripts/loot/inv_overhaul_container_transfer_player.lua :: ExchangeWithContainer`
- `… and 8 more`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.


## Internal API

No additional maintask helpers.

## Events / callbacks

No engine callbacks; this is an imported module.

## Important constants

- `CategoryCount: int = 5` — fixed limit/count for category count.
- `InventoryCapacity: int = 56` — fixed limit/count for inventory capacity.
- `WeaponCategory: int = 0` — engine inventory category value for weapon category.
- `ClothesCategory: int = 1` — engine inventory category value for clothes category.
- `ItemReferenceStride: int = 100000` — encoding stride/base used by item reference stride.

## Architectural notes

- No additional module-specific issue identified beyond repository-wide shared-variable and compiler-visible API constraints.
