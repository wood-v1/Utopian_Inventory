# Container Transfer Player

## Source

`scripts/loot/inv_overhaul_container_transfer_player.lua`

DSL unit: `module inv_overhaul_container_transfer_player`

## Responsibility

Adapts shared transfer operations for items moving from the player backpack into the external container.

## Dependencies

- `inv_overhaul_inventory_layout_runtime` — Owns the mutable saved cell-to-item order, normalization, exact insertion/removal, swapping, and incremental persistence.
- `inv_overhaul_container_drag` — Owns container-screen drag state, source identity, target highlighting, and drag cancellation/commit bookkeeping.
- `inv_overhaul_container_feedback` — Owns transient loot-screen message cooldown and localized feedback publication.
- `inv_overhaul_container_presenter` — Projects session state into loot UI forms, including incremental item metadata/texture loading, money, organs, and page controls.
- `inv_overhaul_container_projection` — Builds and queries the visible container/corpse item projection independently of the player backpack projection.
- `inv_overhaul_container_transfer` — Provides shared capacity checks, stack movement, and transfer primitives used by player/external transfer adapters.
- `inv_overhaul_container_transfer_external` — Adapts shared transfer operations for items moving from the external container into the player backpack.
- `inv_overhaul_inventory_items` — Builds the canonical projection of unequipped player items into backpack ordinals and cached category/index references.
- Pathologic native API — engine state, object access, persistence variables, UI messaging, timing, or rendering as listed per function.

## Used by

- `scripts/loot/inv_overhaul_container_drag_controller.lua`
- `scripts/loot/inv_overhaul_container_quick_transfer.lua`

## State

No module/task-level mutable state.

## Public API

All functions below are compiler-visible when the module is imported; the DSL has no private declaration.

### `RemovePlayerCache(removedOrdinal: int, beforeCount: int, removedCategory: int, removedIndex: int) -> bool`

Source: `scripts/loot/inv_overhaul_container_transfer_player.lua`

Purpose: Removes player cache in the container transfer player subsystem.

Parameters:

- `removedOrdinal: int` — value interpreted according to the function purpose; no narrower contract is established by current code.
- `beforeCount: int` — value interpreted according to the function purpose; no narrower contract is established by current code.
- `removedCategory: int` — zero-based engine inventory category identifier.
- `removedIndex: int` — zero-based entry index in the relevant engine container/category.

Returns:

- `boolean` — result of: removes player cache in the container transfer player subsystem.

Side effects:

- Invokes engine/native operations: `native.Trace`.

Called by:

- `scripts/loot/inv_overhaul_container_transfer_player.lua :: MoveAmountToContainer`

Calls:

- `native.Trace`
- `inv_overhaul_inventory_items.ItemsBuildIndexCache`
- `inv_overhaul_inventory_items.RemoveCachedEntry`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `MoveAmountToContainer(sourceSlot: int, targetSlot: int, requestedAmount: int, restorePageIfMerged: int) -> void`

Source: `scripts/loot/inv_overhaul_container_transfer_player.lua`

Purpose: Moves amount to container in the container transfer player subsystem.

Parameters:

- `sourceSlot: int` — slot index or encoded slot target interpreted by this function.
- `targetSlot: int` — slot index or encoded slot target interpreted by this function.
- `requestedAmount: int` — value interpreted according to the function purpose; no narrower contract is established by current code.
- `restorePageIfMerged: int` — zero-based page or page-related value.

Returns:

None.

Side effects:

- Invokes engine/native operations: `native.Trace`.

Called by:

- `scripts/loot/inv_overhaul_container_quick_transfer.lua :: Execute`
- `scripts/loot/inv_overhaul_container_transfer_player.lua :: MoveToContainer`

Calls:

- `inv_overhaul_container_drag.GetKind`
- `inv_overhaul_container_drag.GetPlayerCategory`
- `inv_overhaul_container_drag.GetPlayerIndex`
- `inv_overhaul_container_presenter.LootPresenterResolveVisibleSlot`
- `inv_overhaul_inventory_items.DecodeReferenceCategory`
- `inv_overhaul_inventory_items.DecodeReferenceIndex`
- `inv_overhaul_inventory_items.ItemsGetPlayerContainer`
- `native.GetContainer`
- `inv_overhaul_inventory_items.GetCachedBackpackCount`
- `inv_overhaul_inventory_items.ItemsBuildIndexCache`
- `inv_overhaul_container_presenter.LootPresenterGetVisibleCell`
- `inv_overhaul_container_drag.GetPlayerCell`
- `… and 23 more`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `MoveToContainer(sourceSlot: int, targetSlot: int, restorePageIfMerged: int) -> void`

Source: `scripts/loot/inv_overhaul_container_transfer_player.lua`

Purpose: Moves to container in the container transfer player subsystem.

Parameters:

- `sourceSlot: int` — slot index or encoded slot target interpreted by this function.
- `targetSlot: int` — slot index or encoded slot target interpreted by this function.
- `restorePageIfMerged: int` — zero-based page or page-related value.

Returns:

None.

Side effects:

- None directly observable beyond calls listed below.

Called by:

- `scripts/loot/inv_overhaul_container_quick_transfer.lua :: Execute`
- `scripts/loot/inv_overhaul_container_transfer_player.lua :: ExchangeWithContainer`

Calls:

- `MoveAmountToContainer`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `ExchangeWithContainer(sourceSlot: int, targetSlot: int) -> void`

Source: `scripts/loot/inv_overhaul_container_transfer_player.lua`

Purpose: Exchanges with container in the container transfer player subsystem.

Parameters:

- `sourceSlot: int` — slot index or encoded slot target interpreted by this function.
- `targetSlot: int` — slot index or encoded slot target interpreted by this function.

Returns:

None.

Side effects:

- Invokes engine/native operations: `native.Trace`.

Called by:

- `scripts/loot/inv_overhaul_container_drag_controller.lua :: Finish`

Calls:

- `inv_overhaul_container_presenter.ResolveContainerVisualSlot`
- `MoveToContainer`
- `inv_overhaul_container_projection.GetReferenceIndex`
- `inv_overhaul_container_projection.GetReferenceOrdinal`
- `native.GetContainer`
- `external.GetItem`
- `external.GetItemAmount`
- `external.GetItemCount`
- `inv_overhaul_container_drag.GetPlayerCategory`
- `inv_overhaul_container_drag.GetPlayerIndex`
- `inv_overhaul_container_presenter.LootPresenterResolveVisibleSlot`
- `inv_overhaul_inventory_items.DecodeReferenceCategory`
- `… and 19 more`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.


## Internal API

No additional maintask helpers.

## Events / callbacks

No engine callbacks; this is an imported module.

## Important constants

- `WeaponCategory: int = 0` — engine inventory category value for weapon category.
- `CategoryCount: int = 5` — fixed limit/count for category count.
- `InventoryCapacity: int = 56` — fixed limit/count for inventory capacity.
- `ContainerSlots: int = 12` — named behavior/layout value for container slots.
- `MaxContainerVisuals: int = 128` — named behavior/layout value for max container visuals.

## Architectural notes

- No additional module-specific issue identified beyond repository-wide shared-variable and compiler-visible API constraints.
