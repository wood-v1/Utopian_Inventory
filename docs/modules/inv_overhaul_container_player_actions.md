# Container Player Actions

## Source

`scripts/loot/inv_overhaul_container_player_actions.lua`

DSL unit: `module inv_overhaul_container_player_actions`

## Responsibility

Implements player-side equip, unequip, use, and drop actions initiated from the loot screen.

## Dependencies

- `inv_overhaul_inventory_sounds` — Plays feedback after successful player-slot placement or Ctrl page movement.

- `inv_overhaul_inventory_layout_runtime` — Owns the mutable saved cell-to-item order, normalization, exact insertion/removal, swapping, and incremental persistence.
- `inv_overhaul_container_feedback` — Owns transient loot-screen message cooldown and localized feedback publication.
- `inv_overhaul_container_presenter` — Projects session state into loot UI forms, including incremental item metadata/texture loading, money, organs, and page controls.
- `inv_overhaul_container_transfer` — Provides shared capacity checks, stack movement, and transfer primitives used by player/external transfer adapters.
- `inv_overhaul_inventory_items` — Builds the canonical projection of unequipped player items into backpack ordinals and cached category/index references.
- Pathologic native API — engine state, object access, persistence variables, UI messaging, timing, or rendering as listed per function.

## Used by

- `scripts/loot/inv_overhaul_container_drag_controller.lua`
- `scripts/loot/inv_overhaul_container_input_controller.lua`

## State

No module/task-level mutable state.

## Public API

All functions below are compiler-visible when the module is imported; the DSL has no private declaration.

### `LootPlayerActionsSwapCells(sourceCell: int, targetCell: int) -> void`

Source: `scripts/loot/inv_overhaul_container_player_actions.lua`

Purpose: Swaps cells for loot player actions in the container player actions subsystem.

Parameters:

- `sourceCell: int` — zero-based backpack layout cell.
- `targetCell: int` — zero-based backpack layout cell.

Returns:

None.

Side effects:

- Delegates to compiler-visible module APIs and inherits their documented side effects.

Called by:

- `scripts/loot/inv_overhaul_container_drag_controller.lua :: Finish`
- `scripts/loot/inv_overhaul_container_player_actions.lua :: LootPlayerActionsMoveSlotToOtherPage`

Calls:

- `inv_overhaul_inventory_layout_runtime.LayoutRuntimeSwapCells`
- `inv_overhaul_inventory_sounds.InventorySoundsPlayItemEquip`
- `inv_overhaul_inventory_layout_runtime.QueueSave`
- `inv_overhaul_container_presenter.LootPresenterGetVisibleSlots`
- `inv_overhaul_container_presenter.LootPresenterGetVisibleCell`
- `inv_overhaul_container_presenter.UpdatePlayerSlot`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `DropToWorld(sourceSlot: int, requestedAmount: int) -> void`

Source: `scripts/loot/inv_overhaul_container_player_actions.lua`

Purpose: Drops to world in the container player actions subsystem.

Parameters:

- `sourceSlot: int` — slot index or encoded slot target interpreted by this function.
- `requestedAmount: int` — value interpreted according to the function purpose; no narrower contract is established by current code.

Returns:

None.

Side effects:

- Invokes engine/native operations: `native.SetPlayerHandsItem`.
- May mutate engine/UI objects through: `player.IsItemSelected`, `player.DropItems`, `player.RemoveItem`.

Called by:

- `scripts/loot/inv_overhaul_container_input_controller.lua :: LootInputHandleModifiedDrop`

Calls:

- `inv_overhaul_container_presenter.LootPresenterResolveVisibleSlot`
- `inv_overhaul_inventory_items.ItemsGetPlayerContainer`
- `inv_overhaul_inventory_items.DecodeReferenceCategory`
- `inv_overhaul_inventory_items.DecodeReferenceIndex`
- `inv_overhaul_inventory_items.GetBackpackCount`
- `inv_overhaul_inventory_items.ItemsGetBackpackOrdinal`
- `player.GetItem`
- `player.GetItemAmount`
- `inv_overhaul_container_transfer.NormalizeAmount`
- `player.IsItemSelected`
- `native.SetPlayerHandsItem`
- `player.DropItems`
- `… and 3 more`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `LootPlayerActionsMoveSlotToOtherPage(sourceSlot: int) -> void`

Source: `scripts/loot/inv_overhaul_container_player_actions.lua`

Purpose: Moves slot to other page for loot player actions in the container player actions subsystem.

Parameters:

- `sourceSlot: int` — slot index or encoded slot target interpreted by this function.

Returns:

None.

Side effects:

- Invokes engine/native operations: `native.Trace`.

Called by:

- `scripts/loot/inv_overhaul_container_input_controller.lua :: LootInputHandleModifiedDrop`

Calls:

- `inv_overhaul_container_presenter.GetMaxPlayerPage`
- `inv_overhaul_container_presenter.GetPlayerPage`
- `inv_overhaul_inventory_items.GetBackpackCount`
- `inv_overhaul_container_presenter.LootPresenterGetVisibleSlots`
- `inv_overhaul_container_presenter.LootPresenterGetCellForLinearSlot`
- `inv_overhaul_inventory_layout_runtime.LayoutRuntimeGetOrderValue`
- `inv_overhaul_container_feedback.LootFeedbackShowInventoryFull`
- `inv_overhaul_container_presenter.LootPresenterGetVisibleCell`
- `LootPlayerActionsSwapCells`
- `native.Trace`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.


## Internal API

No additional maintask helpers.

## Events / callbacks

No engine callbacks; this is an imported module.

## Important constants

- `WeaponCategory: int = 0` — engine inventory category value for weapon category.

## Architectural notes

- No additional module-specific issue identified beyond repository-wide shared-variable and compiler-visible API constraints.
