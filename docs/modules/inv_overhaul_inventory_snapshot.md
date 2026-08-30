# Inventory Snapshot

## Source

`scripts/backpack/inv_overhaul_inventory_snapshot.lua`

DSL unit: `module inv_overhaul_inventory_snapshot`

## Responsibility

Captures item-identity snapshots and reconciles saved layout cells after game inventory order changes or equipment mutations.

## Dependencies

- `inv_overhaul_inventory_items` — Builds the canonical projection of unequipped player items into backpack ordinals and cached category/index references.
- `inv_overhaul_inventory_layout` — Defines the pure default mapping between backpack cells, linear slots, and pages.
- `inv_overhaul_inventory_layout_runtime` — Owns the mutable saved cell-to-item order, normalization, exact insertion/removal, swapping, and incremental persistence.
- Pathologic native API — engine state, object access, persistence variables, UI messaging, timing, or rendering as listed per function.

## Used by

- `scripts/loot/inv_overhaul_container.lua`
- `scripts/loot/inv_overhaul_container_bootstrap.lua`
- `scripts/loot/inv_overhaul_container_input_controller.lua`
- `scripts/player_inventory/inv_overhaul_inventory_controller.lua`

## State

- `backpackSnapshot: object` — snapshot storage for backpack reconciliation.
- `currentBackpackSnapshot: object` — snapshot storage for current backpack reconciliation.
- `oldToNewOrder: object` — engine object/vector storage for old to new order; exact runtime shape follows its method usage.
- `claimedNewOrder: object` — engine object/vector storage for claimed new order; exact runtime shape follows its method usage.
- `usedLayoutCell: object` — engine object/vector storage for used layout cell; exact runtime shape follows its method usage.
- `lastBackpackItemCount: int` — cached or current count for last backpack item count.

## Public API

All functions below are compiler-visible when the module is imported; the DSL has no private declaration.

### `SnapshotInitializeState() -> void`

Source: `scripts/backpack/inv_overhaul_inventory_snapshot.lua`

Purpose: Initializes state for snapshot in the inventory snapshot subsystem.

Parameters:

None.

Returns:

None.

Side effects:

- Mutates module/task state: `backpackSnapshot`, `currentBackpackSnapshot`, `oldToNewOrder`, `claimedNewOrder`, `usedLayoutCell`, `lastBackpackItemCount`.
- Invokes engine/native operations: `native.CreateIntVector`.
- May mutate engine/UI objects through: `backpackSnapshot.add`, `currentBackpackSnapshot.add`, `oldToNewOrder.add`, `claimedNewOrder.add`, `usedLayoutCell.add`.

Called by:

- `scripts/loot/inv_overhaul_container.lua :: init`
- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: PlayerControllerInitialize`

Calls:

- `native.CreateIntVector`
- `backpackSnapshot.add`
- `currentBackpackSnapshot.add`
- `oldToNewOrder.add`
- `claimedNewOrder.add`
- `usedLayoutCell.add`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `GetLastBackpackItemCount() -> int`

Source: `scripts/backpack/inv_overhaul_inventory_snapshot.lua`

Purpose: Returns last backpack item count in the inventory snapshot subsystem.

Parameters:

None.

Returns:

- `number` (integer) — result of: returns last backpack item count in the inventory snapshot subsystem.

Side effects:

- None directly observable beyond calls listed below.

Called by:

- `scripts/loot/inv_overhaul_container_bootstrap.lua :: InitializePersistentPlayerSnapshot`
- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: ReadLastBackpackItemCount`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `CapturePrevious() -> void`

Source: `scripts/backpack/inv_overhaul_inventory_snapshot.lua`

Purpose: Captures previous in the inventory snapshot subsystem.

Parameters:

None.

Returns:

None.

Side effects:

- Mutates module/task state: `lastBackpackItemCount`.

Called by:

- `scripts/backpack/inv_overhaul_inventory_snapshot.lua :: PersistCurrent`
- `scripts/loot/inv_overhaul_container_bootstrap.lua :: InitializePersistentPlayerSnapshot`

Calls:

- `inv_overhaul_inventory_items.CaptureIdentitySnapshot`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `ClampLastBackpackItemCount() -> void`

Source: `scripts/backpack/inv_overhaul_inventory_snapshot.lua`

Purpose: Clamps last backpack item count in the inventory snapshot subsystem.

Parameters:

None.

Returns:

None.

Side effects:

- Mutates module/task state: `lastBackpackItemCount`.

Called by:

- `scripts/backpack/inv_overhaul_inventory_snapshot.lua :: PersistCurrent`
- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: InitializePersistentBackpackSnapshot`
- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: RefreshEquipmentMutation`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `CaptureCurrentCount() -> int`

Source: `scripts/backpack/inv_overhaul_inventory_snapshot.lua`

Purpose: Captures current count in the inventory snapshot subsystem.

Parameters:

None.

Returns:

- `number` (integer) — result of: captures current count in the inventory snapshot subsystem.

Side effects:

- Delegates to compiler-visible module APIs and inherits their documented side effects.

Called by:

- `scripts/loot/inv_overhaul_container_bootstrap.lua :: InitializePersistentPlayerSnapshot`
- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: ReconcileInventoryContentGeneration`
- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: InitializePersistentBackpackSnapshot`

Calls:

- `inv_overhaul_inventory_items.CaptureIdentitySnapshot`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `BuildIndexCacheAndPrevious() -> int`

Source: `scripts/backpack/inv_overhaul_inventory_snapshot.lua`

Purpose: Builds index cache and previous in the inventory snapshot subsystem.

Parameters:

None.

Returns:

- `number` (integer) — result of: builds index cache and previous in the inventory snapshot subsystem.

Side effects:

- Mutates module/task state: `lastBackpackItemCount`.

Called by:

- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: InitializePersistentBackpackSnapshot`
- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: BuildBackpackIndexCacheAndSnapshot`

Calls:

- `inv_overhaul_inventory_items.BuildIndexCacheAndSnapshot`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `GetVariableName(ordinal: int) -> string`

Source: `scripts/backpack/inv_overhaul_inventory_snapshot.lua`

Purpose: Returns variable name in the inventory snapshot subsystem.

Parameters:

- `ordinal: int` — value interpreted according to the function purpose; no narrower contract is established by current code.

Returns:

- `string` — result of: returns variable name in the inventory snapshot subsystem.

Side effects:

- None directly observable beyond calls listed below.

Called by:

- `scripts/backpack/inv_overhaul_inventory_snapshot.lua :: LoadPersistent`
- `scripts/backpack/inv_overhaul_inventory_snapshot.lua :: SavePersistent`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `LoadPersistent() -> bool`

Source: `scripts/backpack/inv_overhaul_inventory_snapshot.lua`

Purpose: Loads persistent in the inventory snapshot subsystem.

Parameters:

None.

Returns:

- `boolean` — result of: loads persistent in the inventory snapshot subsystem.

Side effects:

- Mutates module/task state: `lastBackpackItemCount`.
- May mutate engine/UI objects through: `backpackSnapshot.set`.

Called by:

- `scripts/loot/inv_overhaul_container_bootstrap.lua :: InitializePersistentPlayerSnapshot`
- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: LoadPersistentBackpackSnapshot`

Calls:

- `native.GetVariable`
- `GetVariableName`
- `backpackSnapshot.set`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `CanReusePersistent() -> bool`

Source: `scripts/backpack/inv_overhaul_inventory_snapshot.lua`

Purpose: Returns whether reuse persistent in the inventory snapshot subsystem.

Parameters:

None.

Returns:

- `boolean` — result of: returns whether reuse persistent in the inventory snapshot subsystem.

Side effects:

- None directly observable beyond calls listed below.

Called by:

- `scripts/loot/inv_overhaul_container_bootstrap.lua :: InitializePersistentPlayerSnapshot`
- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: CanReusePersistentBackpackSnapshot`

Calls:

- `native.GetVariable`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `SavePersistent() -> void`

Source: `scripts/backpack/inv_overhaul_inventory_snapshot.lua`

Purpose: Persists persistent in the inventory snapshot subsystem.

Parameters:

None.

Returns:

None.

Side effects:

- Writes shared engine variable(s): `computed value`, `"inv_overhaul_inventory_snapshot_count"`, `"inv_overhaul_inventory_snapshot_version"`, `"inv_overhaul_inventory_snapshot_generation"`, `"inv_overhaul_inventory_snapshot_content_generation"`, `"inv_overhaul_inventory_snapshot_valid"`.
- Invokes engine/native operations: `native.SetVariable`.

Called by:

- `scripts/backpack/inv_overhaul_inventory_snapshot.lua :: PersistCurrent`
- `scripts/loot/inv_overhaul_container_bootstrap.lua :: InitializePersistentPlayerSnapshot`
- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: SavePersistentBackpackSnapshot`

Calls:

- `backpackSnapshot.get`
- `native.SetVariable`
- `GetVariableName`
- `native.GetVariable`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `CopyCurrent(newCount: int) -> void`

Source: `scripts/backpack/inv_overhaul_inventory_snapshot.lua`

Purpose: Copies current in the inventory snapshot subsystem.

Parameters:

- `newCount: int` — value interpreted according to the function purpose; no narrower contract is established by current code.

Returns:

None.

Side effects:

- Mutates module/task state: `lastBackpackItemCount`.
- May mutate engine/UI objects through: `backpackSnapshot.set`.

Called by:

- `scripts/loot/inv_overhaul_container_bootstrap.lua :: InitializePersistentPlayerSnapshot`
- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: CopyCurrentBackpackSnapshot`

Calls:

- `currentBackpackSnapshot.get`
- `backpackSnapshot.set`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `Differs(newCount: int) -> bool`

Source: `scripts/backpack/inv_overhaul_inventory_snapshot.lua`

Purpose: Returns whether inventory snapshot in the inventory snapshot subsystem.

Parameters:

- `newCount: int` — value interpreted according to the function purpose; no narrower contract is established by current code.

Returns:

- `boolean` — result of: returns whether inventory snapshot in the inventory snapshot subsystem.

Side effects:

- None directly observable beyond calls listed below.

Called by:

- `scripts/loot/inv_overhaul_container_bootstrap.lua :: InitializePersistentPlayerSnapshot`
- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: BackpackSnapshotDiffers`

Calls:

- `backpackSnapshot.get`
- `currentBackpackSnapshot.get`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `PersistCurrent() -> void`

Source: `scripts/backpack/inv_overhaul_inventory_snapshot.lua`

Purpose: Persists current in the inventory snapshot subsystem.

Parameters:

None.

Returns:

None.

Side effects:

- None directly observable beyond calls listed below.

Called by:

- `scripts/loot/inv_overhaul_container_input_controller.lua :: PersistAndClose`
- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: PersistCurrentBackpackSnapshot`

Calls:

- `CapturePrevious`
- `ClampLastBackpackItemCount`
- `SavePersistent`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `SnapshotGetCellForLinearSlot(linear: int, visibleSlots: int) -> int`

Source: `scripts/backpack/inv_overhaul_inventory_snapshot.lua`

Purpose: Returns cell for linear slot for snapshot in the inventory snapshot subsystem.

Parameters:

- `linear: int` — value interpreted according to the function purpose; no narrower contract is established by current code.
- `visibleSlots: int` — slot index or encoded slot target interpreted by this function.

Returns:

- `number` (integer) — result of: returns cell for linear slot for snapshot in the inventory snapshot subsystem.

Side effects:

- Delegates to compiler-visible module APIs and inherits their documented side effects.

Called by:

- `scripts/backpack/inv_overhaul_inventory_snapshot.lua :: FindFirstUnusedDisplayCell`
- `scripts/backpack/inv_overhaul_inventory_snapshot.lua :: Reconcile`
- `scripts/backpack/inv_overhaul_inventory_snapshot.lua :: RestoreAfterEquipmentReplacement`
- `scripts/backpack/inv_overhaul_inventory_snapshot.lua :: RestoreAfterEquipmentSelection`

Calls:

- `inv_overhaul_inventory_layout.LayoutGetCellForLinearSlot`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `FindFirstUnusedDisplayCell(visibleSlots: int) -> int`

Source: `scripts/backpack/inv_overhaul_inventory_snapshot.lua`

Purpose: Finds first unused display cell in the inventory snapshot subsystem.

Parameters:

- `visibleSlots: int` — slot index or encoded slot target interpreted by this function.

Returns:

- `number` (integer) — result of: finds first unused display cell in the inventory snapshot subsystem.

Side effects:

- None directly observable beyond calls listed below.

Called by:

- `scripts/backpack/inv_overhaul_inventory_snapshot.lua :: Reconcile`

Calls:

- `SnapshotGetCellForLinearSlot`
- `usedLayoutCell.get`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `Reconcile(newCount: int, visibleSlots: int) -> void`

Source: `scripts/backpack/inv_overhaul_inventory_snapshot.lua`

Purpose: Reconciles inventory snapshot in the inventory snapshot subsystem.

Parameters:

- `newCount: int` — value interpreted according to the function purpose; no narrower contract is established by current code.
- `visibleSlots: int` — slot index or encoded slot target interpreted by this function.

Returns:

None.

Side effects:

- Writes shared engine variable(s): `"inv_overhaul_inventory_equipment_removal_count"`, `"inv_overhaul_inventory_removed_ordinal_valid"`.
- Invokes engine/native operations: `native.Trace`, `native.SetVariable`.
- May mutate engine/UI objects through: `oldToNewOrder.set`, `claimedNewOrder.set`, `usedLayoutCell.set`.

Called by:

- `scripts/loot/inv_overhaul_container_bootstrap.lua :: InitializePersistentPlayerSnapshot`
- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: ReconcileBackpackSnapshot`

Calls:

- `oldToNewOrder.set`
- `claimedNewOrder.set`
- `usedLayoutCell.set`
- `native.GetVariable`
- `oldToNewOrder.get`
- `native.Trace`
- `backpackSnapshot.get`
- `currentBackpackSnapshot.get`
- `claimedNewOrder.get`
- `native.SetVariable`
- `inv_overhaul_inventory_layout_runtime.LayoutRuntimeGetOrderValue`
- `inv_overhaul_inventory_layout_runtime.SetOrderValue`
- `… and 4 more`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `RestoreAfterEquipmentReplacement(replacedOrder: int, itemCount: int, visibleSlots: int) -> bool`

Source: `scripts/backpack/inv_overhaul_inventory_snapshot.lua`

Purpose: Restores after equipment replacement in the inventory snapshot subsystem.

Parameters:

- `replacedOrder: int` — value interpreted according to the function purpose; no narrower contract is established by current code.
- `itemCount: int` — value interpreted according to the function purpose; no narrower contract is established by current code.
- `visibleSlots: int` — slot index or encoded slot target interpreted by this function.

Returns:

- `boolean` — result of: restores after equipment replacement in the inventory snapshot subsystem.

Side effects:

- Invokes engine/native operations: `native.Trace`.
- May mutate engine/UI objects through: `oldToNewOrder.set`, `claimedNewOrder.set`, `usedLayoutCell.set`.

Called by:

- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: RestoreOrderAfterEquipmentReplacement`

Calls:

- `inv_overhaul_inventory_items.CaptureIdentitySnapshot`
- `oldToNewOrder.set`
- `claimedNewOrder.set`
- `usedLayoutCell.set`
- `backpackSnapshot.get`
- `claimedNewOrder.get`
- `currentBackpackSnapshot.get`
- `inv_overhaul_inventory_layout_runtime.LayoutRuntimeGetOrderValue`
- `oldToNewOrder.get`
- `inv_overhaul_inventory_layout_runtime.SetOrderValue`
- `SnapshotGetCellForLinearSlot`
- `usedLayoutCell.get`
- `… and 3 more`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `RestoreAfterEquipmentSelection(removedOrder: int, beforeCount: int, visibleSlots: int) -> bool`

Source: `scripts/backpack/inv_overhaul_inventory_snapshot.lua`

Purpose: Restores after equipment selection in the inventory snapshot subsystem.

Parameters:

- `removedOrder: int` — value interpreted according to the function purpose; no narrower contract is established by current code.
- `beforeCount: int` — value interpreted according to the function purpose; no narrower contract is established by current code.
- `visibleSlots: int` — slot index or encoded slot target interpreted by this function.

Returns:

- `boolean` — result of: restores after equipment selection in the inventory snapshot subsystem.

Side effects:

- Invokes engine/native operations: `native.Trace`.
- May mutate engine/UI objects through: `oldToNewOrder.set`, `claimedNewOrder.set`, `usedLayoutCell.set`.

Called by:

- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: RestoreOrderAfterEquipmentSelection`

Calls:

- `inv_overhaul_inventory_items.CaptureIdentitySnapshot`
- `oldToNewOrder.set`
- `claimedNewOrder.set`
- `usedLayoutCell.set`
- `backpackSnapshot.get`
- `claimedNewOrder.get`
- `currentBackpackSnapshot.get`
- `inv_overhaul_inventory_layout_runtime.LayoutRuntimeGetOrderValue`
- `inv_overhaul_inventory_layout_runtime.SetOrderValue`
- `oldToNewOrder.get`
- `SnapshotGetCellForLinearSlot`
- `usedLayoutCell.get`
- `… and 3 more`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.


## Internal API

No additional maintask helpers.

## Events / callbacks

No engine callbacks; this is an imported module.

## Important constants

- `InventoryCapacity: int = 56` — fixed limit/count for inventory capacity.
- `SnapshotVersion: int = 1` — schema/runtime version marker for snapshot version.

## Architectural notes

- Identity reconciliation depends on category/index/order snapshots and shared persistence variables rather than a first-class item identity supplied by the engine.
