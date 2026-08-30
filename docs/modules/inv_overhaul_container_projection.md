# Container Projection

## Source

`scripts/loot/inv_overhaul_container_projection.lua`

DSL unit: `module inv_overhaul_container_projection`

## Responsibility

Builds and queries the visible container/corpse item projection independently of the player backpack projection.

## Dependencies

- No local DSL imports.
- Pathologic native API — engine state, object access, persistence variables, UI messaging, timing, or rendering as listed per function.

## Used by

- `scripts/loot/inv_overhaul_container.lua`
- `scripts/loot/inv_overhaul_container_drag_controller.lua`
- `scripts/loot/inv_overhaul_container_input_controller.lua`
- `scripts/loot/inv_overhaul_container_paging_controller.lua`
- `scripts/loot/inv_overhaul_container_presenter.lua`
- `scripts/loot/inv_overhaul_container_quick_transfer.lua`
- `scripts/loot/inv_overhaul_container_tooltip_controller.lua`
- `scripts/loot/inv_overhaul_container_transfer_external.lua`
- `scripts/loot/inv_overhaul_container_transfer_player.lua`

## State

- `containerOrder: object` — engine object/vector storage for container order; exact runtime shape follows its method usage.
- `containerIndexCache: object` — cached container index data used to avoid rebuilding engine/container lookups.
- `cachedNormalContainerCount: int` — cached d normal container count data used to avoid rebuilding engine/container lookups.

## Public API

All functions below are compiler-visible when the module is imported; the DSL has no private declaration.

### `LootProjectionInitialize() -> void`

Source: `scripts/loot/inv_overhaul_container_projection.lua`

Purpose: Initializes loot projection in the container projection subsystem.

Parameters:

None.

Returns:

None.

Side effects:

- Mutates module/task state: `containerOrder`, `containerIndexCache`, `cachedNormalContainerCount`.
- Invokes engine/native operations: `native.CreateIntVector`.
- May mutate engine/UI objects through: `newContainerOrder.add`, `newContainerIndexCache.add`.

Called by:

- `scripts/loot/inv_overhaul_container.lua :: init`

Calls:

- `native.CreateIntVector`
- `newContainerOrder.add`
- `newContainerIndexCache.add`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `GetContainerOrder(visual: int) -> int`

Source: `scripts/loot/inv_overhaul_container_projection.lua`

Purpose: Returns container order in the container projection subsystem.

Parameters:

- `visual: int` — value interpreted according to the function purpose; no narrower contract is established by current code.

Returns:

- `number` (integer) — result of: returns container order in the container projection subsystem.

Side effects:

- None directly observable beyond calls listed below.

Called by:

- `scripts/loot/inv_overhaul_container_presenter.lua :: ResolveContainerVisualSlot`
- `scripts/loot/inv_overhaul_container_projection.lua :: GetLastOccupiedVisual`
- `scripts/loot/inv_overhaul_container_projection.lua :: FindFirstFreeContainerVisual`
- `scripts/loot/inv_overhaul_container_projection.lua :: InsertContainerOrdinalAt`
- `scripts/loot/inv_overhaul_container_projection.lua :: RemoveContainerOrdinal`
- `scripts/loot/inv_overhaul_container_projection.lua :: SwapVisuals`
- `scripts/loot/inv_overhaul_container_tooltip_controller.lua :: ResolveExternalItem`

Calls:

- `values.get`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `SetContainerOrder(visual: int, value: int) -> void`

Source: `scripts/loot/inv_overhaul_container_projection.lua`

Purpose: Sets container order in the container projection subsystem.

Parameters:

- `visual: int` — value interpreted according to the function purpose; no narrower contract is established by current code.
- `value: int` — value interpreted according to the function purpose; no narrower contract is established by current code.

Returns:

None.

Side effects:

- May mutate engine/UI objects through: `values.set`.

Called by:

- `scripts/loot/inv_overhaul_container_projection.lua :: InsertContainerOrdinalAt`
- `scripts/loot/inv_overhaul_container_projection.lua :: RemoveContainerOrdinal`
- `scripts/loot/inv_overhaul_container_projection.lua :: SwapVisuals`
- `scripts/loot/inv_overhaul_container_transfer_player.lua :: ExchangeWithContainer`

Calls:

- `values.set`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `IsOrganItem(item: object) -> bool`

Source: `scripts/loot/inv_overhaul_container_projection.lua`

Purpose: Returns whether organ item in the container projection subsystem.

Parameters:

- `item: object` — engine inventory-item object; available properties and methods are supplied by the game.

Returns:

- `boolean` — result of: returns whether organ item in the container projection subsystem.

Side effects:

- None directly observable beyond calls listed below.

Called by:

- `scripts/loot/inv_overhaul_container_projection.lua :: GetNormalItemCount`
- `scripts/loot/inv_overhaul_container_projection.lua :: LootProjectionBuildIndexCache`
- `scripts/loot/inv_overhaul_container_projection.lua :: ResolveOrganVisual`

Calls:

- `item.HasProperty`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `GetNormalItemCount(container: object) -> int`

Source: `scripts/loot/inv_overhaul_container_projection.lua`

Purpose: Returns normal item count in the container projection subsystem.

Parameters:

- `container: object` — external world container/corpse engine object used for inventory reads or mutations.

Returns:

- `number` (integer) — result of: returns normal item count in the container projection subsystem.

Side effects:

- None directly observable beyond calls listed below.

Called by:

- `scripts/loot/inv_overhaul_container_presenter.lua :: GetNormalContainerItemCount`

Calls:

- `container.GetItemCount`
- `container.GetItem`
- `IsOrganItem`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `LootProjectionBuildIndexCache(container: object) -> void`

Source: `scripts/loot/inv_overhaul_container_projection.lua`

Purpose: Builds index cache for loot projection in the container projection subsystem.

Parameters:

- `container: object` — external world container/corpse engine object used for inventory reads or mutations.

Returns:

None.

Side effects:

- Mutates module/task state: `containerIndexCache`, `cachedNormalContainerCount`.
- Invokes engine/native operations: `native.CreateIntVector`.
- May mutate engine/UI objects through: `newIndexCache.add`.

Called by:

- `scripts/loot/inv_overhaul_container_presenter.lua :: BuildContainerIndexCache`

Calls:

- `native.CreateIntVector`
- `container.GetItemCount`
- `container.GetItem`
- `IsOrganItem`
- `newIndexCache.add`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `GetCachedNormalCount() -> int`

Source: `scripts/loot/inv_overhaul_container_projection.lua`

Purpose: Returns cached normal count in the container projection subsystem.

Parameters:

None.

Returns:

- `number` (integer) — result of: returns cached normal count in the container projection subsystem.

Side effects:

- None directly observable beyond calls listed below.

Called by:

- `scripts/loot/inv_overhaul_container_presenter.lua :: UpdateContainerPageControls`
- `scripts/loot/inv_overhaul_container_transfer_player.lua :: ExchangeWithContainer`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `LootProjectionEncodeReference(index: int, ordinal: int) -> int`

Source: `scripts/loot/inv_overhaul_container_projection.lua`

Purpose: Encodes reference for loot projection in the container projection subsystem.

Parameters:

- `index: int` — zero-based entry index in the relevant engine container/category.
- `ordinal: int` — value interpreted according to the function purpose; no narrower contract is established by current code.

Returns:

- `number` (integer) — result of: encodes reference for loot projection in the container projection subsystem.

Side effects:

- None directly observable beyond calls listed below.

Called by:

- `scripts/loot/inv_overhaul_container_projection.lua :: ResolveNormalOrdinal`
- `scripts/loot/inv_overhaul_container_projection.lua :: ResolveOrganVisual`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `GetReferenceIndex(reference: int) -> int`

Source: `scripts/loot/inv_overhaul_container_projection.lua`

Purpose: Returns reference index in the container projection subsystem.

Parameters:

- `reference: int` — value interpreted according to the function purpose; no narrower contract is established by current code.

Returns:

- `number` (integer) — result of: returns reference index in the container projection subsystem.

Side effects:

- None directly observable beyond calls listed below.

Called by:

- `scripts/loot/inv_overhaul_container_drag_controller.lua :: ResolveSource`
- `scripts/loot/inv_overhaul_container_presenter.lua :: UpdateContainerSlot`
- `scripts/loot/inv_overhaul_container_presenter.lua :: UpdateOrganSlots`
- `scripts/loot/inv_overhaul_container_presenter.lua :: RefreshVisibleContainerItem`
- `scripts/loot/inv_overhaul_container_tooltip_controller.lua :: ResolveExternalItem`
- `scripts/loot/inv_overhaul_container_transfer_external.lua :: MoveAmountToPlayer`
- `scripts/loot/inv_overhaul_container_transfer_player.lua :: ExchangeWithContainer`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `GetReferenceOrdinal(reference: int) -> int`

Source: `scripts/loot/inv_overhaul_container_projection.lua`

Purpose: Returns reference ordinal in the container projection subsystem.

Parameters:

- `reference: int` — value interpreted according to the function purpose; no narrower contract is established by current code.

Returns:

- `number` (integer) — result of: returns reference ordinal in the container projection subsystem.

Side effects:

- None directly observable beyond calls listed below.

Called by:

- `scripts/loot/inv_overhaul_container_drag_controller.lua :: ResolveSource`
- `scripts/loot/inv_overhaul_container_transfer_external.lua :: MoveAmountToPlayer`
- `scripts/loot/inv_overhaul_container_transfer_player.lua :: ExchangeWithContainer`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `ResolveNormalOrdinal(ordinal: int) -> int`

Source: `scripts/loot/inv_overhaul_container_projection.lua`

Purpose: Resolves normal ordinal in the container projection subsystem.

Parameters:

- `ordinal: int` — value interpreted according to the function purpose; no narrower contract is established by current code.

Returns:

- `number` (integer) — result of: resolves normal ordinal in the container projection subsystem.

Side effects:

- None directly observable beyond calls listed below.

Called by:

- `scripts/loot/inv_overhaul_container_presenter.lua :: ResolveContainerVisualSlot`
- `scripts/loot/inv_overhaul_container_tooltip_controller.lua :: ResolveExternalItem`

Calls:

- `indexCache.get`
- `LootProjectionEncodeReference`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `GetOrganSlotByItemID(itemID: int) -> int`

Source: `scripts/loot/inv_overhaul_container_projection.lua`

Purpose: Returns organ slot by item id in the container projection subsystem.

Parameters:

- `itemID: int` — engine item or callback identifier interpreted by this function.

Returns:

- `number` (integer) — result of: returns organ slot by item id in the container projection subsystem.

Side effects:

- None directly observable beyond calls listed below.

Called by:

- `scripts/loot/inv_overhaul_container_projection.lua :: ResolveOrganVisual`

Calls:

- `native.GetInvItemByName`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `ResolveOrganVisual(container: object, slot: int) -> int`

Source: `scripts/loot/inv_overhaul_container_projection.lua`

Purpose: Resolves organ visual in the container projection subsystem.

Parameters:

- `container: object` — external world container/corpse engine object used for inventory reads or mutations.
- `slot: int` — slot index or encoded slot target interpreted by this function.

Returns:

- `number` (integer) — result of: resolves organ visual in the container projection subsystem.

Side effects:

- None directly observable beyond calls listed below.

Called by:

- `scripts/loot/inv_overhaul_container_presenter.lua :: ResolveOrganVisualSlot`
- `scripts/loot/inv_overhaul_container_tooltip_controller.lua :: ResolveExternalItem`

Calls:

- `container.GetItemCount`
- `container.GetItem`
- `IsOrganItem`
- `item.GetItemID`
- `GetOrganSlotByItemID`
- `LootProjectionEncodeReference`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `GetLastOccupiedVisual() -> int`

Source: `scripts/loot/inv_overhaul_container_projection.lua`

Purpose: Returns last occupied visual in the container projection subsystem.

Parameters:

None.

Returns:

- `number` (integer) — result of: returns last occupied visual in the container projection subsystem.

Side effects:

- None directly observable beyond calls listed below.

Called by:

- `scripts/loot/inv_overhaul_container_projection.lua :: LootProjectionGetMaxPage`

Calls:

- `GetContainerOrder`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `LootProjectionGetMaxPage() -> int`

Source: `scripts/loot/inv_overhaul_container_projection.lua`

Purpose: Returns max page for loot projection in the container projection subsystem.

Parameters:

None.

Returns:

- `number` (integer) — result of: returns max page for loot projection in the container projection subsystem.

Side effects:

- None directly observable beyond calls listed below.

Called by:

- `scripts/loot/inv_overhaul_container_input_controller.lua :: HandlePagingMessage`
- `scripts/loot/inv_overhaul_container_paging_controller.lua :: HandleControlAt`
- `scripts/loot/inv_overhaul_container_paging_controller.lua :: UpdateControlHover`
- `scripts/loot/inv_overhaul_container_paging_controller.lua :: GetDragHoverAction`
- `scripts/loot/inv_overhaul_container_paging_controller.lua :: UpdateDragHover`
- `scripts/loot/inv_overhaul_container_paging_controller.lua :: SyncDragHoverFromCursor`
- `scripts/loot/inv_overhaul_container_presenter.lua :: ClampContainerPage`
- `scripts/loot/inv_overhaul_container_presenter.lua :: UpdateContainerPageControls`

Calls:

- `GetLastOccupiedVisual`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `FindFirstFreeContainerVisual(itemCount: int) -> int`

Source: `scripts/loot/inv_overhaul_container_projection.lua`

Purpose: Finds first free container visual in the container projection subsystem.

Parameters:

- `itemCount: int` — value interpreted according to the function purpose; no narrower contract is established by current code.

Returns:

- `number` (integer) — result of: finds first free container visual in the container projection subsystem.

Side effects:

- None directly observable beyond calls listed below.

Called by:

- `scripts/loot/inv_overhaul_container_quick_transfer.lua :: Execute`

Calls:

- `GetContainerOrder`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `InsertContainerOrdinalAt(page: int, insertedOrder: int, beforeCount: int, preferredSlot: int) -> bool`

Source: `scripts/loot/inv_overhaul_container_projection.lua`

Purpose: Inserts container ordinal at in the container projection subsystem.

Parameters:

- `page: int` — zero-based page or page-related value.
- `insertedOrder: int` — value interpreted according to the function purpose; no narrower contract is established by current code.
- `beforeCount: int` — value interpreted according to the function purpose; no narrower contract is established by current code.
- `preferredSlot: int` — slot index or encoded slot target interpreted by this function.

Returns:

- `boolean` — result of: inserts container ordinal at in the container projection subsystem.

Side effects:

- None directly observable beyond calls listed below.

Called by:

- `scripts/loot/inv_overhaul_container_transfer_player.lua :: MoveAmountToContainer`

Calls:

- `GetContainerOrder`
- `SetContainerOrder`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `RemoveContainerOrdinal(removedOrder: int, beforeCount: int) -> void`

Source: `scripts/loot/inv_overhaul_container_projection.lua`

Purpose: Removes container ordinal in the container projection subsystem.

Parameters:

- `removedOrder: int` — value interpreted according to the function purpose; no narrower contract is established by current code.
- `beforeCount: int` — value interpreted according to the function purpose; no narrower contract is established by current code.

Returns:

None.

Side effects:

- None directly observable beyond calls listed below.

Called by:

- `scripts/loot/inv_overhaul_container_transfer_external.lua :: MoveResolvedAmountToPlayer`

Calls:

- `GetContainerOrder`
- `SetContainerOrder`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `SwapVisuals(sourceVisual: int, targetVisual: int) -> bool`

Source: `scripts/loot/inv_overhaul_container_projection.lua`

Purpose: Swaps visuals in the container projection subsystem.

Parameters:

- `sourceVisual: int` — value interpreted according to the function purpose; no narrower contract is established by current code.
- `targetVisual: int` — value interpreted according to the function purpose; no narrower contract is established by current code.

Returns:

- `boolean` — result of: swaps visuals in the container projection subsystem.

Side effects:

- None directly observable beyond calls listed below.

Called by:

- `scripts/loot/inv_overhaul_container_drag_controller.lua :: Finish`

Calls:

- `GetContainerOrder`
- `SetContainerOrder`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.


## Internal API

No additional maintask helpers.

## Events / callbacks

No engine callbacks; this is an imported module.

## Important constants

- `c_iContainerSlots: int = 12` — named behavior/layout value for container slots.
- `c_iOrganSlots: int = 4` — named behavior/layout value for organ slots.
- `c_iMaxContainerVisuals: int = 128` — named behavior/layout value for max container visuals.
- `c_iReferenceStride: int = 100000` — encoding stride/base used by reference stride.

## Architectural notes

- No additional module-specific issue identified beyond repository-wide shared-variable and compiler-visible API constraints.
