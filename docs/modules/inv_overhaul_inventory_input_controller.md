# Inventory Input Controller

## Source

`scripts/player_inventory/inv_overhaul_inventory_input_controller.lua`

DSL unit: `module inv_overhaul_inventory_input_controller`

## Responsibility

Maps player-inventory keyboard and character input to close, paging, quickslot, and modified-click actions.

## Dependencies

- `inv_overhaul_inventory_geometry` — Maps supported window sizes and character branches to player-grid, equipment, money, paging, and doll hit-test geometry.
- `inv_overhaul_inventory_protocol` — Defines and encodes the numeric UI message protocol shared by inventory forms and controllers.
- `inv_overhaul_inventory_paging` — Owns player inventory page bounds, current page, and drag-hover page timing.

## Used by

- `scripts/player_inventory/inv_overhaul_inventory_controller.lua`

## State

No module/task-level mutable state.

## Public API

All functions below are compiler-visible when the module is imported; the DSL has no private declaration.

### `PlayerInputGetSlotTargetFromPointerMessage(message: int, base: int, sender: string, visibleSlots: int, windowWidth: int, dropInset: int) -> int`

Source: `scripts/player_inventory/inv_overhaul_inventory_input_controller.lua`

Purpose: Returns slot target from pointer message for player input in the inventory input controller subsystem.

Parameters:

- `message: int` — numeric engine/UI protocol message.
- `base: int` — value interpreted according to the function purpose; no narrower contract is established by current code.
- `sender: string` — name of the UI form that emitted the message.
- `visibleSlots: int` — slot index or encoded slot target interpreted by this function.
- `windowWidth: int` — current UI/layout size in pixels.
- `dropInset: int` — value interpreted according to the function purpose; no narrower contract is established by current code.

Returns:

- `number` (integer) — result of: returns slot target from pointer message for player input in the inventory input controller subsystem.

Side effects:

- Delegates to compiler-visible module APIs and inherits their documented side effects.

Called by:

- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: PlayerControllerGetSlotTargetFromPointerMessage`

Calls:

- `inv_overhaul_inventory_protocol.GetSlotBySender`
- `inv_overhaul_inventory_geometry.InterfaceGeometryIsInsideSlotDropArea`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `PlayerInputGetDragPageHoverAction(sender: string, maxPage: int) -> int`

Source: `scripts/player_inventory/inv_overhaul_inventory_input_controller.lua`

Purpose: Returns drag page hover action for player input in the inventory input controller subsystem.

Parameters:

- `sender: string` — name of the UI form that emitted the message.
- `maxPage: int` — zero-based page or page-related value.

Returns:

- `number` (integer) — result of: returns drag page hover action for player input in the inventory input controller subsystem.

Side effects:

- Delegates to compiler-visible module APIs and inherits their documented side effects.

Called by:

- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: PlayerControllerGetDragPageHoverAction`

Calls:

- `inv_overhaul_inventory_paging.CanMove`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `PlayerInputGetPageControlX(windowWidth: int) -> int`

Source: `scripts/player_inventory/inv_overhaul_inventory_input_controller.lua`

Purpose: Returns page control x for player input in the inventory input controller subsystem.

Parameters:

- `windowWidth: int` — current UI/layout size in pixels.

Returns:

- `number` (integer) — result of: returns page control x for player input in the inventory input controller subsystem.

Side effects:

- Delegates to compiler-visible module APIs and inherits their documented side effects.

Called by:

- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: PlayerControllerGetPageControlX`

Calls:

- `inv_overhaul_inventory_geometry.InterfaceGeometryGetPageControlX`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `PlayerInputGetPageControlY(windowWidth: int, branch: int) -> int`

Source: `scripts/player_inventory/inv_overhaul_inventory_input_controller.lua`

Purpose: Returns page control y for player input in the inventory input controller subsystem.

Parameters:

- `windowWidth: int` — current UI/layout size in pixels.
- `branch: int` — value interpreted according to the function purpose; no narrower contract is established by current code.

Returns:

- `number` (integer) — result of: returns page control y for player input in the inventory input controller subsystem.

Side effects:

- Delegates to compiler-visible module APIs and inherits their documented side effects.

Called by:

- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: PlayerControllerGetPageControlY`

Calls:

- `inv_overhaul_inventory_geometry.InterfaceGeometryGetPageControlY`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `PlayerInputIsInsideQuickslotHelp(windowWidth: int, x: int, y: int) -> bool`

Source: `scripts/player_inventory/inv_overhaul_inventory_input_controller.lua`

Purpose: Returns whether inside quickslot help for player input in the inventory input controller subsystem.

Parameters:

- `windowWidth: int` — current UI/layout size in pixels.
- `x: int` — pointer/layout coordinate interpreted by this function.
- `y: int` — pointer/layout coordinate interpreted by this function.

Returns:

- `boolean` — result of: returns whether inside quickslot help for player input in the inventory input controller subsystem.

Side effects:

- Delegates to compiler-visible module APIs and inherits their documented side effects.

Called by:

- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: PlayerControllerIsInsideQuickslotHelp`

Calls:

- `inv_overhaul_inventory_geometry.InterfaceGeometryIsInsideQuickslotHelp`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `PlayerInputIsInsidePlayerPaging(windowWidth: int, branch: int, maxPage: int, x: int, y: int) -> bool`

Source: `scripts/player_inventory/inv_overhaul_inventory_input_controller.lua`

Purpose: Returns whether inside player paging for player input in the inventory input controller subsystem.

Parameters:

- `windowWidth: int` — current UI/layout size in pixels.
- `branch: int` — value interpreted according to the function purpose; no narrower contract is established by current code.
- `maxPage: int` — zero-based page or page-related value.
- `x: int` — pointer/layout coordinate interpreted by this function.
- `y: int` — pointer/layout coordinate interpreted by this function.

Returns:

- `boolean` — result of: returns whether inside player paging for player input in the inventory input controller subsystem.

Side effects:

- Delegates to compiler-visible module APIs and inherits their documented side effects.

Called by:

- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: PlayerControllerIsInsidePlayerPaging`

Calls:

- `inv_overhaul_inventory_geometry.InterfaceGeometryIsInsidePlayerPaging`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `DecodePanelPointerAction(message: int) -> int`

Source: `scripts/player_inventory/inv_overhaul_inventory_input_controller.lua`

Purpose: Decodes panel pointer action in the inventory input controller subsystem.

Parameters:

- `message: int` — numeric engine/UI protocol message.

Returns:

- `number` (integer) — result of: decodes panel pointer action in the inventory input controller subsystem.

Side effects:

- None directly observable beyond calls listed below.

Called by:

- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: PlayerControllerHandlePanelPointer`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `DecodePanelPointerBase(message: int) -> int`

Source: `scripts/player_inventory/inv_overhaul_inventory_input_controller.lua`

Purpose: Decodes panel pointer base in the inventory input controller subsystem.

Parameters:

- `message: int` — numeric engine/UI protocol message.

Returns:

- `number` (integer) — result of: decodes panel pointer base in the inventory input controller subsystem.

Side effects:

- None directly observable beyond calls listed below.

Called by:

- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: PlayerControllerHandlePanelPointer`

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
