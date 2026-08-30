# Inventory Geometry

## Source

`scripts/inventory_interface/inv_overhaul_inventory_geometry.lua`

DSL unit: `module inv_overhaul_inventory_geometry`

## Responsibility

Maps supported window sizes and character branches to player-grid, equipment, money, paging, and doll hit-test geometry.

## Dependencies

- `inv_overhaul_inventory_protocol` — Defines and encodes the numeric UI message protocol shared by inventory forms and controllers.

## Used by

- `scripts/inventory_interface/inv_overhaul_inventory_background.lua`
- `scripts/player_inventory/inv_overhaul_inventory_controller.lua`
- `scripts/player_inventory/inv_overhaul_inventory_input_controller.lua`
- `scripts/player_inventory/widgets/inv_overhaul_character_doll.lua`

## State

No module/task-level mutable state.

## Public API

All functions below are compiler-visible when the module is imported; the DSL has no private declaration.

### `InterfaceGeometryGetGridStartX(windowWidth: int) -> int`

Source: `scripts/inventory_interface/inv_overhaul_inventory_geometry.lua`

Purpose: Returns grid start x for interface geometry in the inventory geometry subsystem.

Parameters:

- `windowWidth: int` — current UI/layout size in pixels.

Returns:

- `number` (integer) — result of: returns grid start x for interface geometry in the inventory geometry subsystem.

Side effects:

- None directly observable beyond calls listed below.

Called by:

- `scripts/inventory_interface/inv_overhaul_inventory_background.lua :: DrawSlot`
- `scripts/inventory_interface/inv_overhaul_inventory_geometry.lua :: FindBackpackSlot`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `InterfaceGeometryGetGridStartY(windowWidth: int) -> int`

Source: `scripts/inventory_interface/inv_overhaul_inventory_geometry.lua`

Purpose: Returns grid start y for interface geometry in the inventory geometry subsystem.

Parameters:

- `windowWidth: int` — current UI/layout size in pixels.

Returns:

- `number` (integer) — result of: returns grid start y for interface geometry in the inventory geometry subsystem.

Side effects:

- None directly observable beyond calls listed below.

Called by:

- `scripts/inventory_interface/inv_overhaul_inventory_background.lua :: DrawSlot`
- `scripts/inventory_interface/inv_overhaul_inventory_geometry.lua :: FindBackpackSlot`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `InterfaceGeometryGetGridStep(windowWidth: int) -> int`

Source: `scripts/inventory_interface/inv_overhaul_inventory_geometry.lua`

Purpose: Returns grid step for interface geometry in the inventory geometry subsystem.

Parameters:

- `windowWidth: int` — current UI/layout size in pixels.

Returns:

- `number` (integer) — result of: returns grid step for interface geometry in the inventory geometry subsystem.

Side effects:

- None directly observable beyond calls listed below.

Called by:

- `scripts/inventory_interface/inv_overhaul_inventory_background.lua :: DrawSlot`
- `scripts/inventory_interface/inv_overhaul_inventory_geometry.lua :: FindBackpackSlot`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `InterfaceGeometryGetGridColumns(windowWidth: int) -> int`

Source: `scripts/inventory_interface/inv_overhaul_inventory_geometry.lua`

Purpose: Returns grid columns for interface geometry in the inventory geometry subsystem.

Parameters:

- `windowWidth: int` — current UI/layout size in pixels.

Returns:

- `number` (integer) — result of: returns grid columns for interface geometry in the inventory geometry subsystem.

Side effects:

- None directly observable beyond calls listed below.

Called by:

- `scripts/inventory_interface/inv_overhaul_inventory_background.lua :: DrawSlot`
- `scripts/inventory_interface/inv_overhaul_inventory_geometry.lua :: FindBackpackSlot`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `InterfaceGeometryGetVisibleSlots(windowWidth: int) -> int`

Source: `scripts/inventory_interface/inv_overhaul_inventory_geometry.lua`

Purpose: Returns visible slots for interface geometry in the inventory geometry subsystem.

Parameters:

- `windowWidth: int` — current UI/layout size in pixels.

Returns:

- `number` (integer) — result of: returns visible slots for interface geometry in the inventory geometry subsystem.

Side effects:

- None directly observable beyond calls listed below.

Called by:

- `scripts/inventory_interface/inv_overhaul_inventory_background.lua :: OnDraw`
- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: PlayerControllerUpdateLayout`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `GetSlotSize(windowWidth: int) -> int`

Source: `scripts/inventory_interface/inv_overhaul_inventory_geometry.lua`

Purpose: Returns slot size in the inventory geometry subsystem.

Parameters:

- `windowWidth: int` — current UI/layout size in pixels.

Returns:

- `number` (integer) — result of: returns slot size in the inventory geometry subsystem.

Side effects:

- None directly observable beyond calls listed below.

Called by:

- `scripts/inventory_interface/inv_overhaul_inventory_background.lua :: DrawSlot`
- `scripts/inventory_interface/inv_overhaul_inventory_geometry.lua :: InterfaceGeometryIsInsideSlotDropArea`
- `scripts/inventory_interface/inv_overhaul_inventory_geometry.lua :: InterfaceGeometryIsInsideSpecialTarget`
- `scripts/inventory_interface/inv_overhaul_inventory_geometry.lua :: InterfaceGeometryIsInsideMoney`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `GetEquipmentSlotSize(windowWidth: int) -> int`

Source: `scripts/inventory_interface/inv_overhaul_inventory_geometry.lua`

Purpose: Returns equipment slot size in the inventory geometry subsystem.

Parameters:

- `windowWidth: int` — current UI/layout size in pixels.

Returns:

- `number` (integer) — result of: returns equipment slot size in the inventory geometry subsystem.

Side effects:

- None directly observable beyond calls listed below.

Called by:

- `scripts/inventory_interface/inv_overhaul_inventory_geometry.lua :: InterfaceGeometryIsInsideSpecialTarget`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `IsInsideRect(x: int, y: int, left: int, top: int, width: int, height: int) -> bool`

Source: `scripts/inventory_interface/inv_overhaul_inventory_geometry.lua`

Purpose: Returns whether inside rect in the inventory geometry subsystem.

Parameters:

- `x: int` — pointer/layout coordinate interpreted by this function.
- `y: int` — pointer/layout coordinate interpreted by this function.
- `left: int` — value interpreted according to the function purpose; no narrower contract is established by current code.
- `top: int` — value interpreted according to the function purpose; no narrower contract is established by current code.
- `width: int` — current UI/layout size in pixels.
- `height: int` — current UI/layout size in pixels.

Returns:

- `boolean` — result of: returns whether inside rect in the inventory geometry subsystem.

Side effects:

- None directly observable beyond calls listed below.

Called by:

- `scripts/inventory_interface/inv_overhaul_inventory_geometry.lua :: InterfaceGeometryIsInsideSpecialTarget`
- `scripts/inventory_interface/inv_overhaul_inventory_geometry.lua :: InterfaceGeometryIsInsideMoney`
- `scripts/inventory_interface/inv_overhaul_inventory_geometry.lua :: InterfaceGeometryIsInsidePlayerPaging`
- `scripts/inventory_interface/inv_overhaul_inventory_geometry.lua :: InterfaceGeometryIsInsideQuickslotHelp`
- `scripts/inventory_interface/inv_overhaul_inventory_geometry.lua :: GetDollTargetMessage`
- `scripts/player_inventory/widgets/inv_overhaul_character_doll.lua :: IsInside`
- `scripts/player_inventory/widgets/inv_overhaul_character_doll.lua :: HitsTarget`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `InterfaceGeometryIsInsideSlotDropArea(windowWidth: int, inset: int, localX: int, localY: int) -> bool`

Source: `scripts/inventory_interface/inv_overhaul_inventory_geometry.lua`

Purpose: Returns whether inside slot drop area for interface geometry in the inventory geometry subsystem.

Parameters:

- `windowWidth: int` — current UI/layout size in pixels.
- `inset: int` — value interpreted according to the function purpose; no narrower contract is established by current code.
- `localX: int` — pointer/layout coordinate interpreted by this function.
- `localY: int` — pointer/layout coordinate interpreted by this function.

Returns:

- `boolean` — result of: returns whether inside slot drop area for interface geometry in the inventory geometry subsystem.

Side effects:

- None directly observable beyond calls listed below.

Called by:

- `scripts/inventory_interface/inv_overhaul_inventory_geometry.lua :: FindBackpackSlot`
- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: PlayerControllerIsInsideSlotDropArea`
- `scripts/player_inventory/inv_overhaul_inventory_input_controller.lua :: PlayerInputGetSlotTargetFromPointerMessage`

Calls:

- `GetSlotSize`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `FindBackpackSlot(windowWidth: int, visibleSlots: int, inset: int, x: int, y: int) -> int`

Source: `scripts/inventory_interface/inv_overhaul_inventory_geometry.lua`

Purpose: Finds backpack slot in the inventory geometry subsystem.

Parameters:

- `windowWidth: int` — current UI/layout size in pixels.
- `visibleSlots: int` — slot index or encoded slot target interpreted by this function.
- `inset: int` — value interpreted according to the function purpose; no narrower contract is established by current code.
- `x: int` — pointer/layout coordinate interpreted by this function.
- `y: int` — pointer/layout coordinate interpreted by this function.

Returns:

- `number` (integer) — result of: finds backpack slot in the inventory geometry subsystem.

Side effects:

- None directly observable beyond calls listed below.

Called by:

- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: FindBackpackSlotAt`

Calls:

- `InterfaceGeometryGetGridStartX`
- `InterfaceGeometryGetGridStartY`
- `InterfaceGeometryGetGridStep`
- `InterfaceGeometryGetGridColumns`
- `InterfaceGeometryIsInsideSlotDropArea`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `GetSpecialTargetLeft(windowWidth: int, branch: int, target: int) -> int`

Source: `scripts/inventory_interface/inv_overhaul_inventory_geometry.lua`

Purpose: Returns special target left in the inventory geometry subsystem.

Parameters:

- `windowWidth: int` — current UI/layout size in pixels.
- `branch: int` — value interpreted according to the function purpose; no narrower contract is established by current code.
- `target: int` — value interpreted according to the function purpose; no narrower contract is established by current code.

Returns:

- `number` (integer) — result of: returns special target left in the inventory geometry subsystem.

Side effects:

- None directly observable beyond calls listed below.

Called by:

- `scripts/inventory_interface/inv_overhaul_inventory_geometry.lua :: InterfaceGeometryIsInsideSpecialTarget`
- `scripts/inventory_interface/inv_overhaul_inventory_geometry.lua :: GetDollTargetMessage`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `GetSpecialTargetTop(windowWidth: int, branch: int, target: int) -> int`

Source: `scripts/inventory_interface/inv_overhaul_inventory_geometry.lua`

Purpose: Returns special target top in the inventory geometry subsystem.

Parameters:

- `windowWidth: int` — current UI/layout size in pixels.
- `branch: int` — value interpreted according to the function purpose; no narrower contract is established by current code.
- `target: int` — value interpreted according to the function purpose; no narrower contract is established by current code.

Returns:

- `number` (integer) — result of: returns special target top in the inventory geometry subsystem.

Side effects:

- None directly observable beyond calls listed below.

Called by:

- `scripts/inventory_interface/inv_overhaul_inventory_geometry.lua :: InterfaceGeometryIsInsideSpecialTarget`
- `scripts/inventory_interface/inv_overhaul_inventory_geometry.lua :: GetDollTargetMessage`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `InterfaceGeometryIsInsideSpecialTarget(windowWidth: int, branch: int, target: int, x: int, y: int) -> bool`

Source: `scripts/inventory_interface/inv_overhaul_inventory_geometry.lua`

Purpose: Returns whether inside special target for interface geometry in the inventory geometry subsystem.

Parameters:

- `windowWidth: int` — current UI/layout size in pixels.
- `branch: int` — value interpreted according to the function purpose; no narrower contract is established by current code.
- `target: int` — value interpreted according to the function purpose; no narrower contract is established by current code.
- `x: int` — pointer/layout coordinate interpreted by this function.
- `y: int` — pointer/layout coordinate interpreted by this function.

Returns:

- `boolean` — result of: returns whether inside special target for interface geometry in the inventory geometry subsystem.

Side effects:

- None directly observable beyond calls listed below.

Called by:

- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: PlayerControllerIsInsideSpecialTarget`

Calls:

- `GetSpecialTargetLeft`
- `GetSpecialTargetTop`
- `GetEquipmentSlotSize`
- `GetSlotSize`
- `IsInsideRect`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `InterfaceGeometryGetMoneyLeft(windowWidth: int) -> int`

Source: `scripts/inventory_interface/inv_overhaul_inventory_geometry.lua`

Purpose: Returns money left for interface geometry in the inventory geometry subsystem.

Parameters:

- `windowWidth: int` — current UI/layout size in pixels.

Returns:

- `number` (integer) — result of: returns money left for interface geometry in the inventory geometry subsystem.

Side effects:

- None directly observable beyond calls listed below.

Called by:

- `scripts/inventory_interface/inv_overhaul_inventory_geometry.lua :: InterfaceGeometryIsInsideMoney`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `InterfaceGeometryGetMoneyTop(windowWidth: int, branch: int) -> int`

Source: `scripts/inventory_interface/inv_overhaul_inventory_geometry.lua`

Purpose: Returns money top for interface geometry in the inventory geometry subsystem.

Parameters:

- `windowWidth: int` — current UI/layout size in pixels.
- `branch: int` — value interpreted according to the function purpose; no narrower contract is established by current code.

Returns:

- `number` (integer) — result of: returns money top for interface geometry in the inventory geometry subsystem.

Side effects:

- None directly observable beyond calls listed below.

Called by:

- `scripts/inventory_interface/inv_overhaul_inventory_geometry.lua :: InterfaceGeometryIsInsideMoney`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `InterfaceGeometryIsInsideMoney(windowWidth: int, branch: int, x: int, y: int) -> bool`

Source: `scripts/inventory_interface/inv_overhaul_inventory_geometry.lua`

Purpose: Returns whether inside money for interface geometry in the inventory geometry subsystem.

Parameters:

- `windowWidth: int` — current UI/layout size in pixels.
- `branch: int` — value interpreted according to the function purpose; no narrower contract is established by current code.
- `x: int` — pointer/layout coordinate interpreted by this function.
- `y: int` — pointer/layout coordinate interpreted by this function.

Returns:

- `boolean` — result of: returns whether inside money for interface geometry in the inventory geometry subsystem.

Side effects:

- None directly observable beyond calls listed below.

Called by:

- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: PlayerControllerIsInsideMoney`

Calls:

- `IsInsideRect`
- `InterfaceGeometryGetMoneyLeft`
- `InterfaceGeometryGetMoneyTop`
- `GetSlotSize`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `InterfaceGeometryGetPageControlX(windowWidth: int) -> int`

Source: `scripts/inventory_interface/inv_overhaul_inventory_geometry.lua`

Purpose: Returns page control x for interface geometry in the inventory geometry subsystem.

Parameters:

- `windowWidth: int` — current UI/layout size in pixels.

Returns:

- `number` (integer) — result of: returns page control x for interface geometry in the inventory geometry subsystem.

Side effects:

- None directly observable beyond calls listed below.

Called by:

- `scripts/inventory_interface/inv_overhaul_inventory_geometry.lua :: InterfaceGeometryIsInsidePlayerPaging`
- `scripts/player_inventory/inv_overhaul_inventory_input_controller.lua :: PlayerInputGetPageControlX`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `InterfaceGeometryGetPageControlY(windowWidth: int, branch: int) -> int`

Source: `scripts/inventory_interface/inv_overhaul_inventory_geometry.lua`

Purpose: Returns page control y for interface geometry in the inventory geometry subsystem.

Parameters:

- `windowWidth: int` — current UI/layout size in pixels.
- `branch: int` — value interpreted according to the function purpose; no narrower contract is established by current code.

Returns:

- `number` (integer) — result of: returns page control y for interface geometry in the inventory geometry subsystem.

Side effects:

- None directly observable beyond calls listed below.

Called by:

- `scripts/inventory_interface/inv_overhaul_inventory_geometry.lua :: InterfaceGeometryIsInsidePlayerPaging`
- `scripts/player_inventory/inv_overhaul_inventory_input_controller.lua :: PlayerInputGetPageControlY`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `InterfaceGeometryIsInsidePlayerPaging(windowWidth: int, branch: int, maxPage: int, x: int, y: int) -> bool`

Source: `scripts/inventory_interface/inv_overhaul_inventory_geometry.lua`

Purpose: Returns whether inside player paging for interface geometry in the inventory geometry subsystem.

Parameters:

- `windowWidth: int` — current UI/layout size in pixels.
- `branch: int` — value interpreted according to the function purpose; no narrower contract is established by current code.
- `maxPage: int` — zero-based page or page-related value.
- `x: int` — pointer/layout coordinate interpreted by this function.
- `y: int` — pointer/layout coordinate interpreted by this function.

Returns:

- `boolean` — result of: returns whether inside player paging for interface geometry in the inventory geometry subsystem.

Side effects:

- None directly observable beyond calls listed below.

Called by:

- `scripts/player_inventory/inv_overhaul_inventory_input_controller.lua :: PlayerInputIsInsidePlayerPaging`

Calls:

- `IsInsideRect`
- `InterfaceGeometryGetPageControlX`
- `InterfaceGeometryGetPageControlY`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `InterfaceGeometryIsInsideQuickslotHelp(windowWidth: int, x: int, y: int) -> bool`

Source: `scripts/inventory_interface/inv_overhaul_inventory_geometry.lua`

Purpose: Returns whether inside quickslot help for interface geometry in the inventory geometry subsystem.

Parameters:

- `windowWidth: int` — current UI/layout size in pixels.
- `x: int` — pointer/layout coordinate interpreted by this function.
- `y: int` — pointer/layout coordinate interpreted by this function.

Returns:

- `boolean` — result of: returns whether inside quickslot help for interface geometry in the inventory geometry subsystem.

Side effects:

- None directly observable beyond calls listed below.

Called by:

- `scripts/player_inventory/inv_overhaul_inventory_input_controller.lua :: PlayerInputIsInsideQuickslotHelp`

Calls:

- `IsInsideRect`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `GetDollLeft(layoutWidth: int) -> int`

Source: `scripts/inventory_interface/inv_overhaul_inventory_geometry.lua`

Purpose: Returns doll left in the inventory geometry subsystem.

Parameters:

- `layoutWidth: int` — current UI/layout size in pixels.

Returns:

- `number` (integer) — result of: returns doll left in the inventory geometry subsystem.

Side effects:

- None directly observable beyond calls listed below.

Called by:

- `scripts/player_inventory/widgets/inv_overhaul_character_doll.lua :: GetLeft`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `GetDollTop(layoutWidth: int) -> int`

Source: `scripts/inventory_interface/inv_overhaul_inventory_geometry.lua`

Purpose: Returns doll top in the inventory geometry subsystem.

Parameters:

- `layoutWidth: int` — current UI/layout size in pixels.

Returns:

- `number` (integer) — result of: returns doll top in the inventory geometry subsystem.

Side effects:

- None directly observable beyond calls listed below.

Called by:

- `scripts/player_inventory/widgets/inv_overhaul_character_doll.lua :: GetTop`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `GetDollTargetMessage(layoutWidth: int, branch: int, globalX: int, globalY: int) -> int`

Source: `scripts/inventory_interface/inv_overhaul_inventory_geometry.lua`

Purpose: Returns doll target message in the inventory geometry subsystem.

Parameters:

- `layoutWidth: int` — current UI/layout size in pixels.
- `branch: int` — value interpreted according to the function purpose; no narrower contract is established by current code.
- `globalX: int` — pointer/layout coordinate interpreted by this function.
- `globalY: int` — pointer/layout coordinate interpreted by this function.

Returns:

- `number` (integer) — result of: returns doll target message in the inventory geometry subsystem.

Side effects:

- None directly observable beyond calls listed below.

Called by:

- `scripts/player_inventory/widgets/inv_overhaul_character_doll.lua :: GetTargetMessage`

Calls:

- `IsInsideRect`
- `GetSpecialTargetLeft`
- `GetSpecialTargetTop`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.


## Internal API

No additional maintask helpers.

## Events / callbacks

No engine callbacks; this is an imported module.

## Important constants

No module/task-level constants.

## Architectural notes

- Hard-coded coordinates mirror generated XML layouts and selected native hit tests. Layout changes must keep these representations synchronized.
