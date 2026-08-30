# Inventory Layout Runtime

## Source

`scripts/backpack/inv_overhaul_inventory_layout_runtime.lua`

DSL unit: `module inv_overhaul_inventory_layout_runtime`

## Responsibility

Owns the mutable saved cell-to-item order, normalization, exact insertion/removal, swapping, and incremental persistence.

## Dependencies

- `inv_overhaul_inventory_layout` — Defines the pure default mapping between backpack cells, linear slots, and pages.
- Pathologic native API — engine state, object access, persistence variables, UI messaging, timing, or rendering as listed per function.

## Used by

- `scripts/backpack/inv_overhaul_inventory_snapshot.lua`
- `scripts/loot/inv_overhaul_container.lua`
- `scripts/loot/inv_overhaul_container_bootstrap.lua`
- `scripts/loot/inv_overhaul_container_input_controller.lua`
- `scripts/loot/inv_overhaul_container_player_actions.lua`
- `scripts/loot/inv_overhaul_container_presenter.lua`
- `scripts/loot/inv_overhaul_container_quick_transfer.lua`
- `scripts/loot/inv_overhaul_container_tooltip_controller.lua`
- `scripts/loot/inv_overhaul_container_transfer_external.lua`
- `scripts/loot/inv_overhaul_container_transfer_player.lua`
- `scripts/player_inventory/inv_overhaul_inventory_controller.lua`

## State

- `slotOrder: object` — current or cached layout value for slot order.
- `savePending: bool` — deferred-work state for save pending.
- `saveNextCell: int` — mutable runtime state for save next cell.

## Public API

All functions below are compiler-visible when the module is imported; the DSL has no private declaration.

### `LayoutRuntimeInitialize() -> void`

Source: `scripts/backpack/inv_overhaul_inventory_layout_runtime.lua`

Purpose: Initializes layout runtime in the inventory layout runtime subsystem.

Parameters:

None.

Returns:

None.

Side effects:

- Mutates module/task state: `slotOrder`, `savePending`, `saveNextCell`.
- Invokes engine/native operations: `native.CreateIntVector`.
- May mutate engine/UI objects through: `slotOrder.add`.

Called by:

- `scripts/loot/inv_overhaul_container.lua :: init`
- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: InitSlotOrder`

Calls:

- `native.CreateIntVector`
- `slotOrder.add`
- `inv_overhaul_inventory_layout.GetDefaultOrderForCell`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `LayoutRuntimeGetOrderValue(cell: int) -> int`

Source: `scripts/backpack/inv_overhaul_inventory_layout_runtime.lua`

Purpose: Returns order value for layout runtime in the inventory layout runtime subsystem.

Parameters:

- `cell: int` — zero-based backpack layout cell.

Returns:

- `number` (integer) — result of: returns order value for layout runtime in the inventory layout runtime subsystem.

Side effects:

- None directly observable beyond calls listed below.

Called by:

- `scripts/backpack/inv_overhaul_inventory_layout_runtime.lua :: IsOrderUsedBefore`
- `scripts/backpack/inv_overhaul_inventory_layout_runtime.lua :: IsOrderUsedAtOrBefore`
- `scripts/backpack/inv_overhaul_inventory_layout_runtime.lua :: Normalize`
- `scripts/backpack/inv_overhaul_inventory_layout_runtime.lua :: SaveAll`
- `scripts/backpack/inv_overhaul_inventory_layout_runtime.lua :: SaveCell`
- `scripts/backpack/inv_overhaul_inventory_layout_runtime.lua :: LayoutRuntimeOrderFreeCellsByDisplay`
- `scripts/backpack/inv_overhaul_inventory_layout_runtime.lua :: LayoutRuntimeSwapCells`
- `scripts/backpack/inv_overhaul_inventory_layout_runtime.lua :: RemoveOrdinal`
- `… and 13 more`

Calls:

- `slotOrder.get`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `SetOrderValue(cell: int, value: int) -> void`

Source: `scripts/backpack/inv_overhaul_inventory_layout_runtime.lua`

Purpose: Sets order value in the inventory layout runtime subsystem.

Parameters:

- `cell: int` — zero-based backpack layout cell.
- `value: int` — value interpreted according to the function purpose; no narrower contract is established by current code.

Returns:

None.

Side effects:

- May mutate engine/UI objects through: `slotOrder.set`.

Called by:

- `scripts/backpack/inv_overhaul_inventory_layout_runtime.lua :: Normalize`
- `scripts/backpack/inv_overhaul_inventory_layout_runtime.lua :: Load`
- `scripts/backpack/inv_overhaul_inventory_layout_runtime.lua :: ContinueIncrementalLoad`
- `scripts/backpack/inv_overhaul_inventory_layout_runtime.lua :: LayoutRuntimeOrderFreeCellsByDisplay`
- `scripts/backpack/inv_overhaul_inventory_layout_runtime.lua :: LayoutRuntimeSwapCells`
- `scripts/backpack/inv_overhaul_inventory_layout_runtime.lua :: RemoveOrdinal`
- `scripts/backpack/inv_overhaul_inventory_layout_runtime.lua :: RemoveOrdinalExact`
- `scripts/backpack/inv_overhaul_inventory_layout_runtime.lua :: InsertOrdinal`
- `… and 4 more`

Calls:

- `slotOrder.set`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `GetCellVariableName(cell: int) -> string`

Source: `scripts/backpack/inv_overhaul_inventory_layout_runtime.lua`

Purpose: Returns cell variable name in the inventory layout runtime subsystem.

Parameters:

- `cell: int` — zero-based backpack layout cell.

Returns:

- `string` — result of: returns cell variable name in the inventory layout runtime subsystem.

Side effects:

- None directly observable beyond calls listed below.

Called by:

- `scripts/backpack/inv_overhaul_inventory_layout_runtime.lua :: SaveAll`
- `scripts/backpack/inv_overhaul_inventory_layout_runtime.lua :: Load`
- `scripts/backpack/inv_overhaul_inventory_layout_runtime.lua :: ContinueIncrementalLoad`
- `scripts/backpack/inv_overhaul_inventory_layout_runtime.lua :: SaveCell`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `IsOrderUsedBefore(cell: int, order: int) -> bool`

Source: `scripts/backpack/inv_overhaul_inventory_layout_runtime.lua`

Purpose: Returns whether order used before in the inventory layout runtime subsystem.

Parameters:

- `cell: int` — zero-based backpack layout cell.
- `order: int` — value interpreted according to the function purpose; no narrower contract is established by current code.

Returns:

- `boolean` — result of: returns whether order used before in the inventory layout runtime subsystem.

Side effects:

- None directly observable beyond calls listed below.

Called by:

- `scripts/backpack/inv_overhaul_inventory_layout_runtime.lua :: Normalize`

Calls:

- `LayoutRuntimeGetOrderValue`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `IsOrderUsedAtOrBefore(cell: int, order: int) -> bool`

Source: `scripts/backpack/inv_overhaul_inventory_layout_runtime.lua`

Purpose: Returns whether order used at or before in the inventory layout runtime subsystem.

Parameters:

- `cell: int` — zero-based backpack layout cell.
- `order: int` — value interpreted according to the function purpose; no narrower contract is established by current code.

Returns:

- `boolean` — result of: returns whether order used at or before in the inventory layout runtime subsystem.

Side effects:

- None directly observable beyond calls listed below.

Called by:

- `scripts/backpack/inv_overhaul_inventory_layout_runtime.lua :: FindFirstUnusedOrder`

Calls:

- `LayoutRuntimeGetOrderValue`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `FindFirstUnusedOrder(cell: int) -> int`

Source: `scripts/backpack/inv_overhaul_inventory_layout_runtime.lua`

Purpose: Finds first unused order in the inventory layout runtime subsystem.

Parameters:

- `cell: int` — zero-based backpack layout cell.

Returns:

- `number` (integer) — result of: finds first unused order in the inventory layout runtime subsystem.

Side effects:

- None directly observable beyond calls listed below.

Called by:

- `scripts/backpack/inv_overhaul_inventory_layout_runtime.lua :: Normalize`

Calls:

- `IsOrderUsedAtOrBefore`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `Normalize() -> void`

Source: `scripts/backpack/inv_overhaul_inventory_layout_runtime.lua`

Purpose: Normalizes inventory layout runtime in the inventory layout runtime subsystem.

Parameters:

None.

Returns:

None.

Side effects:

- None directly observable beyond calls listed below.

Called by:

- `scripts/backpack/inv_overhaul_inventory_layout_runtime.lua :: Load`
- `scripts/backpack/inv_overhaul_inventory_layout_runtime.lua :: ContinueIncrementalLoad`
- `scripts/backpack/inv_overhaul_inventory_layout_runtime.lua :: RemoveOrdinal`
- `scripts/backpack/inv_overhaul_inventory_layout_runtime.lua :: InsertOrdinal`
- `scripts/backpack/inv_overhaul_inventory_snapshot.lua :: Reconcile`
- `scripts/backpack/inv_overhaul_inventory_snapshot.lua :: RestoreAfterEquipmentReplacement`
- `scripts/backpack/inv_overhaul_inventory_snapshot.lua :: RestoreAfterEquipmentSelection`

Calls:

- `LayoutRuntimeGetOrderValue`
- `IsOrderUsedBefore`
- `SetOrderValue`
- `FindFirstUnusedOrder`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `SaveAll() -> void`

Source: `scripts/backpack/inv_overhaul_inventory_layout_runtime.lua`

Purpose: Persists all in the inventory layout runtime subsystem.

Parameters:

None.

Returns:

None.

Side effects:

- Mutates module/task state: `savePending`, `saveNextCell`.
- Writes shared engine variable(s): `computed value`, `"inv_overhaul_inventory_layout_initialized"`, `"inv_overhaul_inventory_layout_version"`.
- Invokes engine/native operations: `native.SetVariable`.

Called by:

- `scripts/backpack/inv_overhaul_inventory_layout_runtime.lua :: Load`
- `scripts/loot/inv_overhaul_container_input_controller.lua :: PersistAndClose`
- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: SaveLayoutVariables`

Calls:

- `native.SetVariable`
- `GetCellVariableName`
- `LayoutRuntimeGetOrderValue`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `QueueSave() -> void`

Source: `scripts/backpack/inv_overhaul_inventory_layout_runtime.lua`

Purpose: Queues save in the inventory layout runtime subsystem.

Parameters:

None.

Returns:

None.

Side effects:

- Mutates module/task state: `savePending`, `saveNextCell`.

Called by:

- `scripts/backpack/inv_overhaul_inventory_layout_runtime.lua :: RemoveOrdinalExact`
- `scripts/backpack/inv_overhaul_inventory_layout_runtime.lua :: InsertOrdinalExactAtVisibleSlot`
- `scripts/loot/inv_overhaul_container_bootstrap.lua :: InitializePersistentPlayerSnapshot`
- `scripts/loot/inv_overhaul_container_bootstrap.lua :: LootBootstrapOrderFreeCellsByDisplay`
- `scripts/loot/inv_overhaul_container_player_actions.lua :: LootPlayerActionsSwapCells`
- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: QueueLayoutSave`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `HasQueuedSave() -> bool`

Source: `scripts/backpack/inv_overhaul_inventory_layout_runtime.lua`

Purpose: Returns whether queued save in the inventory layout runtime subsystem.

Parameters:

None.

Returns:

- `boolean` — result of: returns whether queued save in the inventory layout runtime subsystem.

Side effects:

- None directly observable beyond calls listed below.

Called by:

- `scripts/loot/inv_overhaul_container_input_controller.lua :: PersistAndClose`
- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: OnChar`
- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: OnKeyDown`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `ContinueQueuedSave() -> void`

Source: `scripts/backpack/inv_overhaul_inventory_layout_runtime.lua`

Purpose: Continues queued save in the inventory layout runtime subsystem.

Parameters:

None.

Returns:

None.

Side effects:

- Mutates module/task state: `saveNextCell`, `savePending`.

Called by:

- `scripts/loot/inv_overhaul_container.lua :: OnUpdate`
- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: ContinueLayoutSave`

Calls:

- `SaveCell`
- `FinishIncrementalSave`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `Load() -> void`

Source: `scripts/backpack/inv_overhaul_inventory_layout_runtime.lua`

Purpose: Loads inventory layout runtime in the inventory layout runtime subsystem.

Parameters:

None.

Returns:

None.

Side effects:

- Invokes engine/native operations: `native.Trace`.

Called by:

- `scripts/backpack/inv_overhaul_inventory_layout_runtime.lua :: ContinueIncrementalLoad`
- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: LoadLayoutVariables`

Calls:

- `native.GetVariable`
- `SaveAll`
- `SetOrderValue`
- `GetCellVariableName`
- `inv_overhaul_inventory_layout.GetDefaultOrderForCell`
- `Normalize`
- `native.Trace`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `ContinueIncrementalLoad(loadStartCell: int) -> bool`

Source: `scripts/backpack/inv_overhaul_inventory_layout_runtime.lua`

Purpose: Continues incremental load in the inventory layout runtime subsystem.

Parameters:

- `loadStartCell: int` — zero-based backpack layout cell.

Returns:

- `boolean` — result of: continues incremental load in the inventory layout runtime subsystem.

Side effects:

- Delegates to compiler-visible module APIs and inherits their documented side effects.

Called by:

- `scripts/loot/inv_overhaul_container_bootstrap.lua :: LootBootstrapAdvance`
- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: ContinueIncrementalLayoutLoad`

Calls:

- `native.GetVariable`
- `Load`
- `inv_overhaul_inventory_layout.GetDefaultOrderForCell`
- `GetCellVariableName`
- `SetOrderValue`
- `Normalize`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `SaveCell(cell: int) -> void`

Source: `scripts/backpack/inv_overhaul_inventory_layout_runtime.lua`

Purpose: Persists cell in the inventory layout runtime subsystem.

Parameters:

- `cell: int` — zero-based backpack layout cell.

Returns:

None.

Side effects:

- Writes shared engine variable(s): `computed value`.
- Invokes engine/native operations: `native.SetVariable`.

Called by:

- `scripts/backpack/inv_overhaul_inventory_layout_runtime.lua :: ContinueQueuedSave`

Calls:

- `native.SetVariable`
- `GetCellVariableName`
- `LayoutRuntimeGetOrderValue`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `FinishIncrementalSave() -> void`

Source: `scripts/backpack/inv_overhaul_inventory_layout_runtime.lua`

Purpose: Completes incremental save in the inventory layout runtime subsystem.

Parameters:

None.

Returns:

None.

Side effects:

- Writes shared engine variable(s): `"inv_overhaul_inventory_layout_initialized"`, `"inv_overhaul_inventory_layout_version"`.
- Invokes engine/native operations: `native.SetVariable`.

Called by:

- `scripts/backpack/inv_overhaul_inventory_layout_runtime.lua :: ContinueQueuedSave`

Calls:

- `native.SetVariable`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `LayoutRuntimeOrderFreeCellsByDisplay(itemCount: int, visibleSlots: int) -> bool`

Source: `scripts/backpack/inv_overhaul_inventory_layout_runtime.lua`

Purpose: Orders free cells by display for layout runtime in the inventory layout runtime subsystem.

Parameters:

- `itemCount: int` — value interpreted according to the function purpose; no narrower contract is established by current code.
- `visibleSlots: int` — slot index or encoded slot target interpreted by this function.

Returns:

- `boolean` — result of: orders free cells by display for layout runtime in the inventory layout runtime subsystem.

Side effects:

- Delegates to compiler-visible module APIs and inherits their documented side effects.

Called by:

- `scripts/backpack/inv_overhaul_inventory_layout_runtime.lua :: RemoveOrdinal`
- `scripts/backpack/inv_overhaul_inventory_layout_runtime.lua :: InsertOrdinal`
- `scripts/backpack/inv_overhaul_inventory_snapshot.lua :: RestoreAfterEquipmentReplacement`
- `scripts/backpack/inv_overhaul_inventory_snapshot.lua :: RestoreAfterEquipmentSelection`
- `scripts/loot/inv_overhaul_container_bootstrap.lua :: LootBootstrapOrderFreeCellsByDisplay`
- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: OrderFreeCellsByDisplayForCount`

Calls:

- `inv_overhaul_inventory_layout.LayoutGetCellForLinearSlot`
- `LayoutRuntimeGetOrderValue`
- `SetOrderValue`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `LayoutRuntimeSwapCells(sourceCell: int, targetCell: int) -> bool`

Source: `scripts/backpack/inv_overhaul_inventory_layout_runtime.lua`

Purpose: Swaps cells for layout runtime in the inventory layout runtime subsystem.

Parameters:

- `sourceCell: int` — zero-based backpack layout cell.
- `targetCell: int` — zero-based backpack layout cell.

Returns:

- `boolean` — result of: swaps cells for layout runtime in the inventory layout runtime subsystem.

Side effects:

- None directly observable beyond calls listed below.

Called by:

- `scripts/loot/inv_overhaul_container_player_actions.lua :: LootPlayerActionsSwapCells`
- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: SwapSlotOrderCells`

Calls:

- `LayoutRuntimeGetOrderValue`
- `SetOrderValue`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `RemoveOrdinal(removedOrder: int, beforeCount: int, currentCount: int, visibleSlots: int) -> void`

Source: `scripts/backpack/inv_overhaul_inventory_layout_runtime.lua`

Purpose: Removes ordinal in the inventory layout runtime subsystem.

Parameters:

- `removedOrder: int` — value interpreted according to the function purpose; no narrower contract is established by current code.
- `beforeCount: int` — value interpreted according to the function purpose; no narrower contract is established by current code.
- `currentCount: int` — value interpreted according to the function purpose; no narrower contract is established by current code.
- `visibleSlots: int` — slot index or encoded slot target interpreted by this function.

Returns:

None.

Side effects:

- None directly observable beyond calls listed below.

Called by:

- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: RemoveOrderOrdinal`

Calls:

- `LayoutRuntimeGetOrderValue`
- `SetOrderValue`
- `Normalize`
- `LayoutRuntimeOrderFreeCellsByDisplay`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `RemoveOrdinalExact(removedOrder: int, beforeCount: int) -> bool`

Source: `scripts/backpack/inv_overhaul_inventory_layout_runtime.lua`

Purpose: Removes ordinal exact in the inventory layout runtime subsystem.

Parameters:

- `removedOrder: int` — value interpreted according to the function purpose; no narrower contract is established by current code.
- `beforeCount: int` — value interpreted according to the function purpose; no narrower contract is established by current code.

Returns:

- `boolean` — result of: removes ordinal exact in the inventory layout runtime subsystem.

Side effects:

- None directly observable beyond calls listed below.

Called by:

- `scripts/loot/inv_overhaul_container_player_actions.lua :: DropToWorld`
- `scripts/loot/inv_overhaul_container_transfer_player.lua :: MoveAmountToContainer`

Calls:

- `LayoutRuntimeGetOrderValue`
- `SetOrderValue`
- `QueueSave`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `FindFirstFreeCell(itemCount: int, visibleSlots: int) -> int`

Source: `scripts/backpack/inv_overhaul_inventory_layout_runtime.lua`

Purpose: Finds first free cell in the inventory layout runtime subsystem.

Parameters:

- `itemCount: int` — value interpreted according to the function purpose; no narrower contract is established by current code.
- `visibleSlots: int` — slot index or encoded slot target interpreted by this function.

Returns:

- `number` (integer) — result of: finds first free cell in the inventory layout runtime subsystem.

Side effects:

- Delegates to compiler-visible module APIs and inherits their documented side effects.

Called by:

- `scripts/backpack/inv_overhaul_inventory_layout_runtime.lua :: InsertOrdinal`
- `scripts/loot/inv_overhaul_container_quick_transfer.lua :: Execute`
- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: FindFirstFreeVisualSlot`

Calls:

- `inv_overhaul_inventory_layout.LayoutGetCellForLinearSlot`
- `LayoutRuntimeGetOrderValue`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `InsertOrdinal(insertedOrder: int, beforeCount: int, targetCell: int, currentCount: int, visibleSlots: int) -> bool`

Source: `scripts/backpack/inv_overhaul_inventory_layout_runtime.lua`

Purpose: Inserts ordinal in the inventory layout runtime subsystem.

Parameters:

- `insertedOrder: int` — value interpreted according to the function purpose; no narrower contract is established by current code.
- `beforeCount: int` — value interpreted according to the function purpose; no narrower contract is established by current code.
- `targetCell: int` — zero-based backpack layout cell.
- `currentCount: int` — value interpreted according to the function purpose; no narrower contract is established by current code.
- `visibleSlots: int` — slot index or encoded slot target interpreted by this function.

Returns:

- `boolean` — result of: inserts ordinal in the inventory layout runtime subsystem.

Side effects:

- Invokes engine/native operations: `native.Trace`.

Called by:

- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: InsertOrderOrdinalAtCell`

Calls:

- `FindFirstFreeCell`
- `LayoutRuntimeGetOrderValue`
- `SetOrderValue`
- `Normalize`
- `LayoutRuntimeOrderFreeCellsByDisplay`
- `native.Trace`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `InsertOrdinalExactAtVisibleSlot(insertedOrder: int, beforeCount: int, page: int, visibleSlots: int, preferredSlot: int) -> bool`

Source: `scripts/backpack/inv_overhaul_inventory_layout_runtime.lua`

Purpose: Inserts ordinal exact at visible slot in the inventory layout runtime subsystem.

Parameters:

- `insertedOrder: int` — value interpreted according to the function purpose; no narrower contract is established by current code.
- `beforeCount: int` — value interpreted according to the function purpose; no narrower contract is established by current code.
- `page: int` — zero-based page or page-related value.
- `visibleSlots: int` — slot index or encoded slot target interpreted by this function.
- `preferredSlot: int` — slot index or encoded slot target interpreted by this function.

Returns:

- `boolean` — result of: inserts ordinal exact at visible slot in the inventory layout runtime subsystem.

Side effects:

- Delegates to compiler-visible module APIs and inherits their documented side effects.

Called by:

- `scripts/loot/inv_overhaul_container_transfer_external.lua :: MoveResolvedAmountToPlayer`

Calls:

- `LayoutRuntimeGetOrderValue`
- `SetOrderValue`
- `inv_overhaul_inventory_layout.LayoutGetCellForLinearSlot`
- `QueueSave`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.


## Internal API

No additional maintask helpers.

## Events / callbacks

No engine callbacks; this is an imported module.

## Important constants

- `InventoryCapacity: int = 56` — fixed limit/count for inventory capacity.
- `LayoutVersion: int = 4` — schema/runtime version marker for layout version.

## Architectural notes

- Persistence is spread across dynamically named engine variables and incremental work state; callers depend on sequencing between load, normalization, queued save, and projection refresh.
