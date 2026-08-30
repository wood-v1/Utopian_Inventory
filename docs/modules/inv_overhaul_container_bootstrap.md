# Container Bootstrap

## Source

`scripts/loot/inv_overhaul_container_bootstrap.lua`

DSL unit: `module inv_overhaul_container_bootstrap`

## Responsibility

Stages the container screen's initial loading and readiness handshake.

## Dependencies

- `inv_overhaul_inventory_layout_runtime` — Owns the mutable saved cell-to-item order, normalization, exact insertion/removal, swapping, and incremental persistence.
- `inv_overhaul_inventory_snapshot` — Captures item-identity snapshots and reconciles saved layout cells after game inventory order changes or equipment mutations.
- `inv_overhaul_container_presenter` — Projects session state into loot UI forms, including incremental item metadata/texture loading, money, organs, and page controls.
- `inv_overhaul_inventory_items` — Builds the canonical projection of unequipped player items into backpack ordinals and cached category/index references.
- Pathologic native API — engine state, object access, persistence variables, UI messaging, timing, or rendering as listed per function.

## Used by

- `scripts/loot/inv_overhaul_container.lua`

## State

- `initialSlotLoadPending: bool` — deferred-work state for initial slot load pending.
- `initialSlotLoadDelay: float` — timing state for initial slot load delay.
- `initialMetadataStage: int` — mutable runtime state for initial metadata stage.

## Public API

All functions below are compiler-visible when the module is imported; the DSL has no private declaration.

### `LootBootstrapInitializeState() -> void`

Source: `scripts/loot/inv_overhaul_container_bootstrap.lua`

Purpose: Initializes state for loot bootstrap in the container bootstrap subsystem.

Parameters:

None.

Returns:

None.

Side effects:

- Mutates module/task state: `initialSlotLoadPending`, `initialSlotLoadDelay`, `initialMetadataStage`.

Called by:

- `scripts/loot/inv_overhaul_container.lua :: init`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `InitializePersistentPlayerSnapshot() -> void`

Source: `scripts/loot/inv_overhaul_container_bootstrap.lua`

Purpose: Initializes persistent player snapshot in the container bootstrap subsystem.

Parameters:

None.

Returns:

None.

Side effects:

- Invokes engine/native operations: `native.Trace`.

Called by:

- `scripts/loot/inv_overhaul_container_bootstrap.lua :: LootBootstrapAdvance`

Calls:

- `inv_overhaul_inventory_snapshot.CanReusePersistent`
- `inv_overhaul_inventory_snapshot.CapturePrevious`
- `inv_overhaul_inventory_snapshot.CaptureCurrentCount`
- `inv_overhaul_inventory_snapshot.LoadPersistent`
- `inv_overhaul_inventory_snapshot.Differs`
- `inv_overhaul_inventory_snapshot.GetLastBackpackItemCount`
- `inv_overhaul_container_presenter.LootPresenterGetVisibleSlots`
- `inv_overhaul_inventory_snapshot.Reconcile`
- `inv_overhaul_inventory_layout_runtime.QueueSave`
- `native.Trace`
- `inv_overhaul_inventory_snapshot.CopyCurrent`
- `inv_overhaul_inventory_snapshot.SavePersistent`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `LootBootstrapOrderFreeCellsByDisplay() -> void`

Source: `scripts/loot/inv_overhaul_container_bootstrap.lua`

Purpose: Orders free cells by display for loot bootstrap in the container bootstrap subsystem.

Parameters:

None.

Returns:

None.

Side effects:

- Delegates to compiler-visible module APIs and inherits their documented side effects.

Called by:

- `scripts/loot/inv_overhaul_container_bootstrap.lua :: LootBootstrapAdvance`

Calls:

- `inv_overhaul_inventory_items.GetBackpackCount`
- `inv_overhaul_container_presenter.LootPresenterGetVisibleSlots`
- `inv_overhaul_inventory_layout_runtime.LayoutRuntimeOrderFreeCellsByDisplay`
- `inv_overhaul_inventory_layout_runtime.QueueSave`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `LootBootstrapAdvance(delta: float) -> void`

Source: `scripts/loot/inv_overhaul_container_bootstrap.lua`

Purpose: Advances loot bootstrap in the container bootstrap subsystem.

Parameters:

- `delta: float` — elapsed update time in seconds.

Returns:

None.

Side effects:

- Mutates module/task state: `initialSlotLoadDelay`, `initialMetadataStage`, `initialSlotLoadPending`.

Called by:

- `scripts/loot/inv_overhaul_container.lua :: OnUpdate`

Calls:

- `inv_overhaul_inventory_layout_runtime.ContinueIncrementalLoad`
- `InitializePersistentPlayerSnapshot`
- `LootBootstrapOrderFreeCellsByDisplay`
- `inv_overhaul_container_presenter.LootPresenterBeginInitialSlotLoad`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.


## Internal API

No additional maintask helpers.

## Events / callbacks

No engine callbacks; this is an imported module.

## Important constants

- `InventoryCapacity: int = 56` — fixed limit/count for inventory capacity.

## Architectural notes

- No additional module-specific issue identified beyond repository-wide shared-variable and compiler-visible API constraints.
