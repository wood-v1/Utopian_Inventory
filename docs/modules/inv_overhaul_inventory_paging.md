# Inventory Paging

## Source

`scripts/player_inventory/inv_overhaul_inventory_paging.lua`

DSL unit: `module inv_overhaul_inventory_paging`

## Responsibility

Owns player inventory page bounds, current page, and drag-hover page timing.

## Dependencies

- `inv_overhaul_inventory_layout` — Defines the pure default mapping between backpack cells, linear slots, and pages.

## Used by

- `scripts/player_inventory/inv_overhaul_inventory_controller.lua`
- `scripts/player_inventory/inv_overhaul_inventory_input_controller.lua`

## State

- `page: int` — current or cached paging state for page.

## Public API

All functions below are compiler-visible when the module is imported; the DSL has no private declaration.

### `PlayerPagingInitialize() -> void`

Source: `scripts/player_inventory/inv_overhaul_inventory_paging.lua`

Purpose: Initializes player paging in the inventory paging subsystem.

Parameters:

None.

Returns:

None.

Side effects:

- Mutates module/task state: `page`.

Called by:

- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: PlayerControllerInitialize`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `GetPage() -> int`

Source: `scripts/player_inventory/inv_overhaul_inventory_paging.lua`

Purpose: Returns page in the inventory paging subsystem.

Parameters:

None.

Returns:

- `number` (integer) — result of: returns page in the inventory paging subsystem.

Side effects:

- None directly observable beyond calls listed below.

Called by:

- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: ReadPage`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `PlayerPagingGetMaxPage(inventoryCapacity: int, visibleSlots: int) -> int`

Source: `scripts/player_inventory/inv_overhaul_inventory_paging.lua`

Purpose: Returns max page for player paging in the inventory paging subsystem.

Parameters:

- `inventoryCapacity: int` — value interpreted according to the function purpose; no narrower contract is established by current code.
- `visibleSlots: int` — slot index or encoded slot target interpreted by this function.

Returns:

- `number` (integer) — result of: returns max page for player paging in the inventory paging subsystem.

Side effects:

- Delegates to compiler-visible module APIs and inherits their documented side effects.

Called by:

- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: PlayerControllerGetMaxPage`
- `scripts/player_inventory/inv_overhaul_inventory_paging.lua :: Clamp`

Calls:

- `inv_overhaul_inventory_layout.LayoutGetMaxPage`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `Clamp(inventoryCapacity: int, visibleSlots: int) -> void`

Source: `scripts/player_inventory/inv_overhaul_inventory_paging.lua`

Purpose: Clamps inventory paging in the inventory paging subsystem.

Parameters:

- `inventoryCapacity: int` — value interpreted according to the function purpose; no narrower contract is established by current code.
- `visibleSlots: int` — slot index or encoded slot target interpreted by this function.

Returns:

None.

Side effects:

- Mutates module/task state: `page`.

Called by:

- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: ClampPage`
- `scripts/player_inventory/inv_overhaul_inventory_paging.lua :: Change`

Calls:

- `PlayerPagingGetMaxPage`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `Change(delta: int, inventoryCapacity: int, visibleSlots: int) -> void`

Source: `scripts/player_inventory/inv_overhaul_inventory_paging.lua`

Purpose: Changes inventory paging in the inventory paging subsystem.

Parameters:

- `delta: int` — elapsed update time in seconds.
- `inventoryCapacity: int` — value interpreted according to the function purpose; no narrower contract is established by current code.
- `visibleSlots: int` — slot index or encoded slot target interpreted by this function.

Returns:

None.

Side effects:

- Mutates module/task state: `page`.

Called by:

- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: ChangePage`

Calls:

- `Clamp`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `PlayerPagingGetVisibleCell(slot: int, visibleSlots: int, inventoryCapacity: int) -> int`

Source: `scripts/player_inventory/inv_overhaul_inventory_paging.lua`

Purpose: Returns visible cell for player paging in the inventory paging subsystem.

Parameters:

- `slot: int` — slot index or encoded slot target interpreted by this function.
- `visibleSlots: int` — slot index or encoded slot target interpreted by this function.
- `inventoryCapacity: int` — value interpreted according to the function purpose; no narrower contract is established by current code.

Returns:

- `number` (integer) — result of: returns visible cell for player paging in the inventory paging subsystem.

Side effects:

- None directly observable beyond calls listed below.

Called by:

- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: PlayerControllerGetVisibleCell`

Calls:

- `PlayerPagingGetCellForLinearSlot`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `PlayerPagingGetCellForLinearSlot(linear: int, visibleSlots: int, inventoryCapacity: int) -> int`

Source: `scripts/player_inventory/inv_overhaul_inventory_paging.lua`

Purpose: Returns cell for linear slot for player paging in the inventory paging subsystem.

Parameters:

- `linear: int` — value interpreted according to the function purpose; no narrower contract is established by current code.
- `visibleSlots: int` — slot index or encoded slot target interpreted by this function.
- `inventoryCapacity: int` — value interpreted according to the function purpose; no narrower contract is established by current code.

Returns:

- `number` (integer) — result of: returns cell for linear slot for player paging in the inventory paging subsystem.

Side effects:

- Delegates to compiler-visible module APIs and inherits their documented side effects.

Called by:

- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: PlayerControllerGetCellForLinearSlot`
- `scripts/player_inventory/inv_overhaul_inventory_paging.lua :: PlayerPagingGetVisibleCell`

Calls:

- `inv_overhaul_inventory_layout.LayoutGetCellForLinearSlot`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `GetNextPage(maxPage: int) -> int`

Source: `scripts/player_inventory/inv_overhaul_inventory_paging.lua`

Purpose: Returns next page in the inventory paging subsystem.

Parameters:

- `maxPage: int` — zero-based page or page-related value.

Returns:

- `number` (integer) — result of: returns next page in the inventory paging subsystem.

Side effects:

- None directly observable beyond calls listed below.

Called by:

- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: PlayerControllerMoveSlotToOtherPage`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `CanMove(action: int, maxPage: int) -> bool`

Source: `scripts/player_inventory/inv_overhaul_inventory_paging.lua`

Purpose: Returns whether move in the inventory paging subsystem.

Parameters:

- `action: int` — value interpreted according to the function purpose; no narrower contract is established by current code.
- `maxPage: int` — zero-based page or page-related value.

Returns:

- `boolean` — result of: returns whether move in the inventory paging subsystem.

Side effects:

- None directly observable beyond calls listed below.

Called by:

- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: UpdateDragPageHover`
- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: HandlePageControlAt`
- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: HandlePagingProtocolMessage`
- `scripts/player_inventory/inv_overhaul_inventory_input_controller.lua :: PlayerInputGetDragPageHoverAction`
- `scripts/player_inventory/inv_overhaul_inventory_paging.lua :: GetCursorHoverAction`
- `scripts/player_inventory/inv_overhaul_inventory_paging.lua :: IsControlHovered`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `GetCursorHoverAction(hoverTarget: int, maxPage: int) -> int`

Source: `scripts/player_inventory/inv_overhaul_inventory_paging.lua`

Purpose: Returns cursor hover action in the inventory paging subsystem.

Parameters:

- `hoverTarget: int` — value interpreted according to the function purpose; no narrower contract is established by current code.
- `maxPage: int` — zero-based page or page-related value.

Returns:

- `number` (integer) — result of: returns cursor hover action in the inventory paging subsystem.

Side effects:

- None directly observable beyond calls listed below.

Called by:

- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: SyncDragPageHoverFromCursor`

Calls:

- `CanMove`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `GetControlAction(x: int, y: int, controlX: int, controlY: int) -> int`

Source: `scripts/player_inventory/inv_overhaul_inventory_paging.lua`

Purpose: Returns control action in the inventory paging subsystem.

Parameters:

- `x: int` — pointer/layout coordinate interpreted by this function.
- `y: int` — pointer/layout coordinate interpreted by this function.
- `controlX: int` — value interpreted according to the function purpose; no narrower contract is established by current code.
- `controlY: int` — value interpreted according to the function purpose; no narrower contract is established by current code.

Returns:

- `number` (integer) — result of: returns control action in the inventory paging subsystem.

Side effects:

- None directly observable beyond calls listed below.

Called by:

- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: HandlePageControlAt`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `IsControlHovered(action: int, x: int, y: int, controlX: int, controlY: int, maxPage: int) -> bool`

Source: `scripts/player_inventory/inv_overhaul_inventory_paging.lua`

Purpose: Returns whether control hovered in the inventory paging subsystem.

Parameters:

- `action: int` — value interpreted according to the function purpose; no narrower contract is established by current code.
- `x: int` — pointer/layout coordinate interpreted by this function.
- `y: int` — pointer/layout coordinate interpreted by this function.
- `controlX: int` — value interpreted according to the function purpose; no narrower contract is established by current code.
- `controlY: int` — value interpreted according to the function purpose; no narrower contract is established by current code.
- `maxPage: int` — zero-based page or page-related value.

Returns:

- `boolean` — result of: returns whether control hovered in the inventory paging subsystem.

Side effects:

- None directly observable beyond calls listed below.

Called by:

- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: UpdatePageControlHover`

Calls:

- `CanMove`

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
