# Container Quick Transfer

## Source

`scripts/loot/inv_overhaul_container_quick_transfer.lua`

DSL unit: `module inv_overhaul_container_quick_transfer`

## Responsibility

Chooses and executes the appropriate contextual quick-transfer direction for a clicked loot-screen slot.

## Dependencies

- `inv_overhaul_inventory_layout_runtime` — Owns the mutable saved cell-to-item order, normalization, exact insertion/removal, swapping, and incremental persistence.
- `inv_overhaul_container_feedback` — Owns transient loot-screen message cooldown and localized feedback publication.
- `inv_overhaul_container_presenter` — Projects session state into loot UI forms, including incremental item metadata/texture loading, money, organs, and page controls.
- `inv_overhaul_container_projection` — Builds and queries the visible container/corpse item projection independently of the player backpack projection.
- `inv_overhaul_container_protocol` — Defines the loot screen's numeric messages, target identifiers, and sender-name mappings.
- `inv_overhaul_container_transfer_external` — Adapts shared transfer operations for items moving from the external container into the player backpack.
- `inv_overhaul_container_transfer_player` — Adapts shared transfer operations for items moving from the player backpack into the external container.
- `inv_overhaul_inventory_items` — Builds the canonical projection of unequipped player items into backpack ordinals and cached category/index references.
- Pathologic native API — engine state, object access, persistence variables, UI messaging, timing, or rendering as listed per function.

## Used by

- `scripts/loot/inv_overhaul_container_input_controller.lua`

## State

No module/task-level mutable state.

## Public API

All functions below are compiler-visible when the module is imported; the DSL has no private declaration.

### `Execute(source: int, wholeStack: bool) -> void`

Source: `scripts/loot/inv_overhaul_container_quick_transfer.lua`

Purpose: Executes a contextual whole-stack or single-item transfer for the selected loot-screen source.

Parameters:

- `source: int` — value interpreted according to the function purpose; no narrower contract is established by current code.
- `wholeStack: bool` — behavior flag interpreted by this function.

Returns:

None.

Side effects:

- Invokes engine/native operations: `native.Trace`.

Called by:

- `scripts/loot/inv_overhaul_container_input_controller.lua :: LootInputHandlePanelPointer`
- `scripts/loot/inv_overhaul_container_input_controller.lua :: LootInputHandleRegularSlotMessage`

Calls:

- `inv_overhaul_container_presenter.LootPresenterGetVisibleSlots`
- `inv_overhaul_container_protocol.IsPlayerTarget`
- `inv_overhaul_container_presenter.LootPresenterResolveVisibleSlot`
- `inv_overhaul_container_presenter.GetNormalContainerItemCount`
- `inv_overhaul_container_projection.FindFirstFreeContainerVisual`
- `inv_overhaul_container_feedback.ShowContainerFull`
- `native.Trace`
- `inv_overhaul_container_presenter.GetContainerPage`
- `inv_overhaul_container_presenter.SetContainerPage`
- `inv_overhaul_container_transfer_player.MoveAmountToContainer`
- `inv_overhaul_container_transfer_player.MoveToContainer`
- `inv_overhaul_inventory_items.GetBackpackCount`
- `… and 9 more`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.


## Internal API

No additional maintask helpers.

## Events / callbacks

No engine callbacks; this is an imported module.

## Important constants

- `InventoryCapacity: int = 56` — fixed limit/count for inventory capacity.
- `ContainerSlots: int = 12` — named behavior/layout value for container slots.

## Architectural notes

- No additional module-specific issue identified beyond repository-wide shared-variable and compiler-visible API constraints.
