# Container Transfer External

## Source

`scripts/loot/inv_overhaul_container_transfer_external.lua`

DSL unit: `module inv_overhaul_container_transfer_external`

## Responsibility

Adapts shared transfer operations for items moving from the external container into the player backpack.

## Dependencies

- `inv_overhaul_inventory_sounds` — Plays item-equipment or money-pickup feedback after successful transfers.

- `inv_overhaul_inventory_layout_runtime` — Owns the mutable saved cell-to-item order, normalization, exact insertion/removal, swapping, and incremental persistence.
- `inv_overhaul_container_drag` — Owns container-screen drag state, source identity, target highlighting, and drag cancellation/commit bookkeeping.
- `inv_overhaul_container_feedback` — Owns transient loot-screen message cooldown and localized feedback publication.
- `inv_overhaul_container_presenter` — Projects session state into loot UI forms, including incremental item metadata/texture loading, money, organs, and page controls.
- `inv_overhaul_container_projection` — Builds and queries the visible container/corpse item projection independently of the player backpack projection.
- `inv_overhaul_container_transfer` — Provides shared capacity checks, stack movement, and transfer primitives used by player/external transfer adapters.
- `inv_overhaul_inventory_tooltip` — Owns shared tooltip text, money pseudo-item metadata, suspension, and show/hide messaging.
- `inv_overhaul_inventory_items` — Builds the canonical projection of unequipped player items into backpack ordinals and cached category/index references.
- Pathologic native API — engine state, object access, persistence variables, UI messaging, timing, or rendering as listed per function.

## Used by

- `scripts/loot/inv_overhaul_container.lua`
- `scripts/loot/inv_overhaul_container_drag_controller.lua`
- `scripts/loot/inv_overhaul_container_quick_transfer.lua`
- `scripts/loot/inv_overhaul_container_transfer_player.lua`

## State

- `moneyItemID: int` — mutable runtime state for money item id.

## Public API

All functions below are compiler-visible when the module is imported; the DSL has no private declaration.

### `ExternalTransferInitializeState() -> void`

Source: `scripts/loot/inv_overhaul_container_transfer_external.lua`

Purpose: Transfers initialize state for external in the container transfer external subsystem.

Parameters:

None.

Returns:

None.

Side effects:

- Mutates module/task state: `moneyItemID`.

Called by:

- `scripts/loot/inv_overhaul_container.lua :: init`

Calls:

- `inv_overhaul_inventory_tooltip.GetMoneyItemID`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `GetAppendedBackpackOrdinal(category: int, beforeCount: int) -> int`

Source: `scripts/loot/inv_overhaul_container_transfer_external.lua`

Purpose: Returns appended backpack ordinal in the container transfer external subsystem.

Parameters:

- `category: int` — zero-based engine inventory category identifier.
- `beforeCount: int` — value interpreted according to the function purpose; no narrower contract is established by current code.

Returns:

- `number` (integer) — result of: returns appended backpack ordinal in the container transfer external subsystem.

Side effects:

- Delegates to compiler-visible module APIs and inherits their documented side effects.

Called by:

- `scripts/loot/inv_overhaul_container_transfer_external.lua :: MoveResolvedAmountToPlayer`

Calls:

- `inv_overhaul_inventory_items.GetAppendedCategoryOrdinal`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `InsertPlayerCache(insertedOrdinal: int, beforeCount: int, category: int, index: int) -> bool`

Source: `scripts/loot/inv_overhaul_container_transfer_external.lua`

Purpose: Inserts player cache in the container transfer external subsystem.

Parameters:

- `insertedOrdinal: int` — value interpreted according to the function purpose; no narrower contract is established by current code.
- `beforeCount: int` — value interpreted according to the function purpose; no narrower contract is established by current code.
- `category: int` — zero-based engine inventory category identifier.
- `index: int` — zero-based entry index in the relevant engine container/category.

Returns:

- `boolean` — result of: inserts player cache in the container transfer external subsystem.

Side effects:

- Invokes engine/native operations: `native.Trace`.

Called by:

- `scripts/loot/inv_overhaul_container_transfer_external.lua :: MoveResolvedAmountToPlayer`

Calls:

- `native.Trace`
- `inv_overhaul_inventory_items.ItemsBuildIndexCache`
- `inv_overhaul_inventory_items.InsertCachedEntry`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `MoveAmountToPlayer(organSource: bool, sourceSlot: int, targetSlot: int, requestedAmount: int, restorePageIfMerged: int) -> void`

Source: `scripts/loot/inv_overhaul_container_transfer_external.lua`

Purpose: Moves amount to player in the container transfer external subsystem.

Parameters:

- `organSource: bool` — behavior flag interpreted by this function.
- `sourceSlot: int` — slot index or encoded slot target interpreted by this function.
- `targetSlot: int` — slot index or encoded slot target interpreted by this function.
- `requestedAmount: int` — value interpreted according to the function purpose; no narrower contract is established by current code.
- `restorePageIfMerged: int` — zero-based page or page-related value.

Returns:

None.

Side effects:

- Delegates to compiler-visible module APIs and inherits their documented side effects.

Called by:

- `scripts/loot/inv_overhaul_container_quick_transfer.lua :: Execute`
- `scripts/loot/inv_overhaul_container_transfer_external.lua :: MoveToPlayer`

Calls:

- `inv_overhaul_container_drag.GetKind`
- `inv_overhaul_container_drag.GetContainerIndex`
- `inv_overhaul_container_drag.GetContainerOrdinal`
- `inv_overhaul_container_presenter.ResolveOrganVisualSlot`
- `inv_overhaul_container_presenter.ResolveContainerVisualSlot`
- `inv_overhaul_container_projection.GetReferenceIndex`
- `inv_overhaul_container_projection.GetReferenceOrdinal`
- `MoveResolvedAmountToPlayer`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `MoveResolvedAmountToPlayer(organSource: bool, sourceIndex: int, sourceOrdinal: int, sourceSlot: int, targetSlot: int, requestedAmount: int, restorePageIfMerged: int, playItemSound: bool) -> void`

Source: `scripts/loot/inv_overhaul_container_transfer_external.lua`

Purpose: Moves resolved amount to player in the container transfer external subsystem.

Parameters:

- `organSource: bool` — behavior flag interpreted by this function.
- `sourceIndex: int` — zero-based entry index in the relevant engine container/category.
- `sourceOrdinal: int` — value interpreted according to the function purpose; no narrower contract is established by current code.
- `sourceSlot: int` — slot index or encoded slot target interpreted by this function.
- `targetSlot: int` — slot index or encoded slot target interpreted by this function.
- `requestedAmount: int` — value interpreted according to the function purpose; no narrower contract is established by current code.
- `restorePageIfMerged: int` — zero-based page or page-related value.
- `playItemSound: bool` — whether a successful ordinary-item transfer should play the shared item-equipment sound.

Returns:

None.

Side effects:

- Invokes engine/native operations: `native.Trace`, `native.PlaySound`.
- May mutate engine/UI objects through: `player.SetProperty`, `external.RemoveItem`.

Called by:

- `scripts/loot/inv_overhaul_container_transfer_external.lua :: MoveAmountToPlayer`
- `scripts/loot/inv_overhaul_container_transfer_player.lua :: ExchangeWithContainer`

Calls:

- `native.GetContainer`
- `inv_overhaul_inventory_items.ItemsGetPlayerContainer`
- `inv_overhaul_container_presenter.GetNormalContainerItemCount`
- `inv_overhaul_inventory_items.GetCachedBackpackCount`
- `inv_overhaul_inventory_items.ItemsBuildIndexCache`
- `external.GetItem`
- `external.GetItemAmount`
- `inv_overhaul_container_transfer.NormalizeAmount`
- `item.GetItemID`
- `player.GetProperty`
- `player.SetProperty`
- `external.RemoveItem`
- `… and 28 more`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `MoveToPlayer(organSource: bool, sourceSlot: int, targetSlot: int, restorePageIfMerged: int) -> void`

Source: `scripts/loot/inv_overhaul_container_transfer_external.lua`

Purpose: Moves to player in the container transfer external subsystem.

Parameters:

- `organSource: bool` — behavior flag interpreted by this function.
- `sourceSlot: int` — slot index or encoded slot target interpreted by this function.
- `targetSlot: int` — slot index or encoded slot target interpreted by this function.
- `restorePageIfMerged: int` — zero-based page or page-related value.

Returns:

None.

Side effects:

- None directly observable beyond calls listed below.

Called by:

- `scripts/loot/inv_overhaul_container_drag_controller.lua :: Finish`
- `scripts/loot/inv_overhaul_container_quick_transfer.lua :: Execute`

Calls:

- `MoveAmountToPlayer`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.


## Internal API

No additional maintask helpers.

## Events / callbacks

No engine callbacks; this is an imported module.

## Important constants

- `InventoryCapacity: int = 56` — fixed limit/count for inventory capacity.
- `CategoryCount: int = 5` — fixed limit/count for category count.

## Architectural notes

- No additional module-specific issue identified beyond repository-wide shared-variable and compiler-visible API constraints.
