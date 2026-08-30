# Inventory Layout

## Source

`scripts/backpack/inv_overhaul_inventory_layout.lua`

DSL unit: `module inv_overhaul_inventory_layout`

## Responsibility

Defines the pure default mapping between backpack cells, linear slots, and pages.

## Dependencies

- No local DSL imports.

## Used by

- `scripts/backpack/inv_overhaul_inventory_layout_runtime.lua`
- `scripts/backpack/inv_overhaul_inventory_snapshot.lua`
- `scripts/loot/inv_overhaul_container_presenter.lua`
- `scripts/loot/inv_overhaul_container_tooltip_controller.lua`
- `scripts/player_inventory/inv_overhaul_inventory_controller.lua`
- `scripts/player_inventory/inv_overhaul_inventory_paging.lua`

## State

No module/task-level mutable state.

## Public API

All functions below are compiler-visible when the module is imported; the DSL has no private declaration.

### `GetDefaultOrderForCell(cell: int) -> int`

Source: `scripts/backpack/inv_overhaul_inventory_layout.lua`

Purpose: Returns default order for cell in the inventory layout subsystem.

Parameters:

- `cell: int` — zero-based backpack layout cell.

Returns:

- `number` (integer) — result of: returns default order for cell in the inventory layout subsystem.

Side effects:

- None directly observable beyond calls listed below.

Called by:

- `scripts/backpack/inv_overhaul_inventory_layout_runtime.lua :: LayoutRuntimeInitialize`
- `scripts/backpack/inv_overhaul_inventory_layout_runtime.lua :: Load`
- `scripts/backpack/inv_overhaul_inventory_layout_runtime.lua :: ContinueIncrementalLoad`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `LayoutGetCellForLinearSlot(linear: int, visibleSlots: int, inventoryCapacity: int) -> int`

Source: `scripts/backpack/inv_overhaul_inventory_layout.lua`

Purpose: Returns cell for linear slot for layout in the inventory layout subsystem.

Parameters:

- `linear: int` — value interpreted according to the function purpose; no narrower contract is established by current code.
- `visibleSlots: int` — slot index or encoded slot target interpreted by this function.
- `inventoryCapacity: int` — value interpreted according to the function purpose; no narrower contract is established by current code.

Returns:

- `number` (integer) — result of: returns cell for linear slot for layout in the inventory layout subsystem.

Side effects:

- None directly observable beyond calls listed below.

Called by:

- `scripts/backpack/inv_overhaul_inventory_layout_runtime.lua :: LayoutRuntimeOrderFreeCellsByDisplay`
- `scripts/backpack/inv_overhaul_inventory_layout_runtime.lua :: FindFirstFreeCell`
- `scripts/backpack/inv_overhaul_inventory_layout_runtime.lua :: InsertOrdinalExactAtVisibleSlot`
- `scripts/backpack/inv_overhaul_inventory_snapshot.lua :: SnapshotGetCellForLinearSlot`
- `scripts/loot/inv_overhaul_container_presenter.lua :: LootPresenterGetCellForLinearSlot`
- `scripts/loot/inv_overhaul_container_tooltip_controller.lua :: ResolvePlayerItem`
- `scripts/player_inventory/inv_overhaul_inventory_paging.lua :: PlayerPagingGetCellForLinearSlot`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `LayoutGetMaxPage(inventoryCapacity: int, visibleSlots: int) -> int`

Source: `scripts/backpack/inv_overhaul_inventory_layout.lua`

Purpose: Returns max page for layout in the inventory layout subsystem.

Parameters:

- `inventoryCapacity: int` — value interpreted according to the function purpose; no narrower contract is established by current code.
- `visibleSlots: int` — slot index or encoded slot target interpreted by this function.

Returns:

- `number` (integer) — result of: returns max page for layout in the inventory layout subsystem.

Side effects:

- None directly observable beyond calls listed below.

Called by:

- `scripts/loot/inv_overhaul_container_presenter.lua :: GetMaxPlayerPage`
- `scripts/player_inventory/inv_overhaul_inventory_paging.lua :: PlayerPagingGetMaxPage`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.


## Internal API

No additional maintask helpers.

## Events / callbacks

No engine callbacks; this is an imported module.

## Important constants

No module/task-level constants.

## Architectural notes

- No additional module-specific issue identified beyond repository-wide shared-variable and compiler-visible API constraints.
