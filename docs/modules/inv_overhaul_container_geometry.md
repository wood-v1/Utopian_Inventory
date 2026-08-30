# Container Geometry

## Source

`scripts/loot/inv_overhaul_container_geometry.lua`

DSL unit: `module inv_overhaul_container_geometry`

## Responsibility

Maps supported layouts to player, container, organ, money, paging, and pointer hit-test geometry.

## Dependencies

- No local DSL imports.

## Used by

- `scripts/loot/inv_overhaul_container_input_controller.lua`
- `scripts/loot/inv_overhaul_container_paging_controller.lua`
- `scripts/loot/inv_overhaul_container_presenter.lua`
- `scripts/loot/inv_overhaul_container_protocol.lua`
- `scripts/loot/inv_overhaul_container_tooltip_controller.lua`

## State

No module/task-level mutable state.

## Public API

All functions below are compiler-visible when the module is imported; the DSL has no private declaration.

### `LootGeometryGetVisibleSlots(windowWidth: int) -> int`

Source: `scripts/loot/inv_overhaul_container_geometry.lua`

Purpose: Returns visible slots for loot geometry in the container geometry subsystem.

Parameters:

- `windowWidth: int` — current UI/layout size in pixels.

Returns:

- `number` (integer) — result of: returns visible slots for loot geometry in the container geometry subsystem.

Side effects:

- None directly observable beyond calls listed below.

Called by:

- `scripts/loot/inv_overhaul_container_presenter.lua :: LootPresenterUpdateLayout`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `LootGeometryGetGridStartX(windowWidth: int) -> int`

Source: `scripts/loot/inv_overhaul_container_geometry.lua`

Purpose: Returns grid start x for loot geometry in the container geometry subsystem.

Parameters:

- `windowWidth: int` — current UI/layout size in pixels.

Returns:

- `number` (integer) — result of: returns grid start x for loot geometry in the container geometry subsystem.

Side effects:

- None directly observable beyond calls listed below.

Called by:

- `scripts/loot/inv_overhaul_container_geometry.lua :: FindPlayerSlotAt`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `LootGeometryGetGridStartY(windowWidth: int) -> int`

Source: `scripts/loot/inv_overhaul_container_geometry.lua`

Purpose: Returns grid start y for loot geometry in the container geometry subsystem.

Parameters:

- `windowWidth: int` — current UI/layout size in pixels.

Returns:

- `number` (integer) — result of: returns grid start y for loot geometry in the container geometry subsystem.

Side effects:

- None directly observable beyond calls listed below.

Called by:

- `scripts/loot/inv_overhaul_container_geometry.lua :: GetContainerStartY`
- `scripts/loot/inv_overhaul_container_geometry.lua :: FindPlayerSlotAt`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `LootGeometryGetGridStep(windowWidth: int) -> int`

Source: `scripts/loot/inv_overhaul_container_geometry.lua`

Purpose: Returns grid step for loot geometry in the container geometry subsystem.

Parameters:

- `windowWidth: int` — current UI/layout size in pixels.

Returns:

- `number` (integer) — result of: returns grid step for loot geometry in the container geometry subsystem.

Side effects:

- None directly observable beyond calls listed below.

Called by:

- `scripts/loot/inv_overhaul_container_geometry.lua :: GetOrganStep`
- `scripts/loot/inv_overhaul_container_geometry.lua :: FindPlayerSlotAt`
- `scripts/loot/inv_overhaul_container_geometry.lua :: FindContainerSlotAt`
- `scripts/loot/inv_overhaul_container_geometry.lua :: GetContainerPageControlY`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `LootGeometryGetGridColumns(windowWidth: int) -> int`

Source: `scripts/loot/inv_overhaul_container_geometry.lua`

Purpose: Returns grid columns for loot geometry in the container geometry subsystem.

Parameters:

- `windowWidth: int` — current UI/layout size in pixels.

Returns:

- `number` (integer) — result of: returns grid columns for loot geometry in the container geometry subsystem.

Side effects:

- None directly observable beyond calls listed below.

Called by:

- `scripts/loot/inv_overhaul_container_geometry.lua :: FindPlayerSlotAt`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `GetContainerStartX(windowWidth: int) -> int`

Source: `scripts/loot/inv_overhaul_container_geometry.lua`

Purpose: Returns container start x in the container geometry subsystem.

Parameters:

- `windowWidth: int` — current UI/layout size in pixels.

Returns:

- `number` (integer) — result of: returns container start x in the container geometry subsystem.

Side effects:

- None directly observable beyond calls listed below.

Called by:

- `scripts/loot/inv_overhaul_container_geometry.lua :: FindContainerSlotAt`
- `scripts/loot/inv_overhaul_container_geometry.lua :: GetContainerPageControlX`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `GetContainerStartY(windowWidth: int) -> int`

Source: `scripts/loot/inv_overhaul_container_geometry.lua`

Purpose: Returns container start y in the container geometry subsystem.

Parameters:

- `windowWidth: int` — current UI/layout size in pixels.

Returns:

- `number` (integer) — result of: returns container start y in the container geometry subsystem.

Side effects:

- None directly observable beyond calls listed below.

Called by:

- `scripts/loot/inv_overhaul_container_geometry.lua :: FindContainerSlotAt`
- `scripts/loot/inv_overhaul_container_geometry.lua :: GetContainerPageControlY`

Calls:

- `LootGeometryGetGridStartY`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `GetOrganStartX(windowWidth: int) -> int`

Source: `scripts/loot/inv_overhaul_container_geometry.lua`

Purpose: Returns organ start x in the container geometry subsystem.

Parameters:

- `windowWidth: int` — current UI/layout size in pixels.

Returns:

- `number` (integer) — result of: returns organ start x in the container geometry subsystem.

Side effects:

- None directly observable beyond calls listed below.

Called by:

- `scripts/loot/inv_overhaul_container_geometry.lua :: FindOrganSlotAt`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `GetOrganStartY(windowWidth: int) -> int`

Source: `scripts/loot/inv_overhaul_container_geometry.lua`

Purpose: Returns organ start y in the container geometry subsystem.

Parameters:

- `windowWidth: int` — current UI/layout size in pixels.

Returns:

- `number` (integer) — result of: returns organ start y in the container geometry subsystem.

Side effects:

- None directly observable beyond calls listed below.

Called by:

- `scripts/loot/inv_overhaul_container_geometry.lua :: FindOrganSlotAt`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `GetOrganStep(windowWidth: int) -> int`

Source: `scripts/loot/inv_overhaul_container_geometry.lua`

Purpose: Returns organ step in the container geometry subsystem.

Parameters:

- `windowWidth: int` — current UI/layout size in pixels.

Returns:

- `number` (integer) — result of: returns organ step in the container geometry subsystem.

Side effects:

- None directly observable beyond calls listed below.

Called by:

- `scripts/loot/inv_overhaul_container_geometry.lua :: FindOrganSlotAt`

Calls:

- `LootGeometryGetGridStep`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `LootGeometryGetMoneyLeft(windowWidth: int) -> int`

Source: `scripts/loot/inv_overhaul_container_geometry.lua`

Purpose: Returns money left for loot geometry in the container geometry subsystem.

Parameters:

- `windowWidth: int` — current UI/layout size in pixels.

Returns:

- `number` (integer) — result of: returns money left for loot geometry in the container geometry subsystem.

Side effects:

- None directly observable beyond calls listed below.

Called by:

- `scripts/loot/inv_overhaul_container_geometry.lua :: LootGeometryIsInsideMoney`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `LootGeometryGetMoneyTop(windowWidth: int) -> int`

Source: `scripts/loot/inv_overhaul_container_geometry.lua`

Purpose: Returns money top for loot geometry in the container geometry subsystem.

Parameters:

- `windowWidth: int` — current UI/layout size in pixels.

Returns:

- `number` (integer) — result of: returns money top for loot geometry in the container geometry subsystem.

Side effects:

- None directly observable beyond calls listed below.

Called by:

- `scripts/loot/inv_overhaul_container_geometry.lua :: LootGeometryIsInsideMoney`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `GetSlotHotZone(windowWidth: int) -> int`

Source: `scripts/loot/inv_overhaul_container_geometry.lua`

Purpose: Returns slot hot zone in the container geometry subsystem.

Parameters:

- `windowWidth: int` — current UI/layout size in pixels.

Returns:

- `number` (integer) — result of: returns slot hot zone in the container geometry subsystem.

Side effects:

- None directly observable beyond calls listed below.

Called by:

- `scripts/loot/inv_overhaul_container_geometry.lua :: FindPlayerSlotAt`
- `scripts/loot/inv_overhaul_container_geometry.lua :: FindContainerSlotAt`
- `scripts/loot/inv_overhaul_container_geometry.lua :: LootGeometryIsInsideMoney`
- `scripts/loot/inv_overhaul_container_protocol.lua :: LootProtocolGetSlotTargetFromPointerMessage`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `GetOrganSlotHotZone(windowWidth: int) -> int`

Source: `scripts/loot/inv_overhaul_container_geometry.lua`

Purpose: Returns organ slot hot zone in the container geometry subsystem.

Parameters:

- `windowWidth: int` — current UI/layout size in pixels.

Returns:

- `number` (integer) — result of: returns organ slot hot zone in the container geometry subsystem.

Side effects:

- None directly observable beyond calls listed below.

Called by:

- `scripts/loot/inv_overhaul_container_geometry.lua :: FindOrganSlotAt`
- `scripts/loot/inv_overhaul_container_protocol.lua :: LootProtocolGetSlotTargetFromPointerMessage`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `LootGeometryIsInsideSlotDropArea(localX: int, localY: int, hotZone: int) -> bool`

Source: `scripts/loot/inv_overhaul_container_geometry.lua`

Purpose: Returns whether inside slot drop area for loot geometry in the container geometry subsystem.

Parameters:

- `localX: int` — pointer/layout coordinate interpreted by this function.
- `localY: int` — pointer/layout coordinate interpreted by this function.
- `hotZone: int` — value interpreted according to the function purpose; no narrower contract is established by current code.

Returns:

- `boolean` — result of: returns whether inside slot drop area for loot geometry in the container geometry subsystem.

Side effects:

- None directly observable beyond calls listed below.

Called by:

- `scripts/loot/inv_overhaul_container_geometry.lua :: FindGridSlotAt`
- `scripts/loot/inv_overhaul_container_protocol.lua :: LootProtocolGetSlotTargetFromPointerMessage`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `FindGridSlotAt(x: int, y: int, startX: int, startY: int, columns: int, rows: int, count: int, hotZone: int, step: int) -> int`

Source: `scripts/loot/inv_overhaul_container_geometry.lua`

Purpose: Finds grid slot at in the container geometry subsystem.

Parameters:

- `x: int` — pointer/layout coordinate interpreted by this function.
- `y: int` — pointer/layout coordinate interpreted by this function.
- `startX: int` — value interpreted according to the function purpose; no narrower contract is established by current code.
- `startY: int` — value interpreted according to the function purpose; no narrower contract is established by current code.
- `columns: int` — value interpreted according to the function purpose; no narrower contract is established by current code.
- `rows: int` — value interpreted according to the function purpose; no narrower contract is established by current code.
- `count: int` — value interpreted according to the function purpose; no narrower contract is established by current code.
- `hotZone: int` — value interpreted according to the function purpose; no narrower contract is established by current code.
- `step: int` — value interpreted according to the function purpose; no narrower contract is established by current code.

Returns:

- `number` (integer) — result of: finds grid slot at in the container geometry subsystem.

Side effects:

- None directly observable beyond calls listed below.

Called by:

- `scripts/loot/inv_overhaul_container_geometry.lua :: FindPlayerSlotAt`
- `scripts/loot/inv_overhaul_container_geometry.lua :: FindContainerSlotAt`
- `scripts/loot/inv_overhaul_container_geometry.lua :: FindOrganSlotAt`

Calls:

- `LootGeometryIsInsideSlotDropArea`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `FindPlayerSlotAt(windowWidth: int, visibleSlots: int, x: int, y: int) -> int`

Source: `scripts/loot/inv_overhaul_container_geometry.lua`

Purpose: Finds player slot at in the container geometry subsystem.

Parameters:

- `windowWidth: int` — current UI/layout size in pixels.
- `visibleSlots: int` — slot index or encoded slot target interpreted by this function.
- `x: int` — pointer/layout coordinate interpreted by this function.
- `y: int` — pointer/layout coordinate interpreted by this function.

Returns:

- `number` (integer) — result of: finds player slot at in the container geometry subsystem.

Side effects:

- None directly observable beyond calls listed below.

Called by:

- `scripts/loot/inv_overhaul_container_protocol.lua :: LootProtocolFindTargetAt`

Calls:

- `LootGeometryGetGridColumns`
- `FindGridSlotAt`
- `LootGeometryGetGridStartX`
- `LootGeometryGetGridStartY`
- `GetSlotHotZone`
- `LootGeometryGetGridStep`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `FindContainerSlotAt(windowWidth: int, slotCount: int, x: int, y: int) -> int`

Source: `scripts/loot/inv_overhaul_container_geometry.lua`

Purpose: Finds container slot at in the container geometry subsystem.

Parameters:

- `windowWidth: int` — current UI/layout size in pixels.
- `slotCount: int` — slot index or encoded slot target interpreted by this function.
- `x: int` — pointer/layout coordinate interpreted by this function.
- `y: int` — pointer/layout coordinate interpreted by this function.

Returns:

- `number` (integer) — result of: finds container slot at in the container geometry subsystem.

Side effects:

- None directly observable beyond calls listed below.

Called by:

- `scripts/loot/inv_overhaul_container_protocol.lua :: LootProtocolFindTargetAt`

Calls:

- `FindGridSlotAt`
- `GetContainerStartX`
- `GetContainerStartY`
- `GetSlotHotZone`
- `LootGeometryGetGridStep`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `FindOrganSlotAt(windowWidth: int, slotCount: int, x: int, y: int) -> int`

Source: `scripts/loot/inv_overhaul_container_geometry.lua`

Purpose: Finds organ slot at in the container geometry subsystem.

Parameters:

- `windowWidth: int` — current UI/layout size in pixels.
- `slotCount: int` — slot index or encoded slot target interpreted by this function.
- `x: int` — pointer/layout coordinate interpreted by this function.
- `y: int` — pointer/layout coordinate interpreted by this function.

Returns:

- `number` (integer) — result of: finds organ slot at in the container geometry subsystem.

Side effects:

- None directly observable beyond calls listed below.

Called by:

- `scripts/loot/inv_overhaul_container_protocol.lua :: LootProtocolFindTargetAt`

Calls:

- `FindGridSlotAt`
- `GetOrganStartX`
- `GetOrganStartY`
- `GetOrganSlotHotZone`
- `GetOrganStep`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `LootGeometryIsInsideMoney(windowWidth: int, x: int, y: int) -> bool`

Source: `scripts/loot/inv_overhaul_container_geometry.lua`

Purpose: Returns whether inside money for loot geometry in the container geometry subsystem.

Parameters:

- `windowWidth: int` — current UI/layout size in pixels.
- `x: int` — pointer/layout coordinate interpreted by this function.
- `y: int` — pointer/layout coordinate interpreted by this function.

Returns:

- `boolean` — result of: returns whether inside money for loot geometry in the container geometry subsystem.

Side effects:

- None directly observable beyond calls listed below.

Called by:

- `scripts/loot/inv_overhaul_container_tooltip_controller.lua :: Update`

Calls:

- `LootGeometryGetMoneyLeft`
- `LootGeometryGetMoneyTop`
- `GetSlotHotZone`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `LootGeometryIsInsideQuickslotHelp(windowWidth: int, x: int, y: int) -> bool`

Source: `scripts/loot/inv_overhaul_container_geometry.lua`

Purpose: Returns whether inside quickslot help for loot geometry in the container geometry subsystem.

Parameters:

- `windowWidth: int` — current UI/layout size in pixels.
- `x: int` — pointer/layout coordinate interpreted by this function.
- `y: int` — pointer/layout coordinate interpreted by this function.

Returns:

- `boolean` — result of: returns whether inside quickslot help for loot geometry in the container geometry subsystem.

Side effects:

- None directly observable beyond calls listed below.

Called by:

- `scripts/loot/inv_overhaul_container_tooltip_controller.lua :: Update`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `GetPlayerPageControlX(windowWidth: int) -> int`

Source: `scripts/loot/inv_overhaul_container_geometry.lua`

Purpose: Returns player page control x in the container geometry subsystem.

Parameters:

- `windowWidth: int` — current UI/layout size in pixels.

Returns:

- `number` (integer) — result of: returns player page control x in the container geometry subsystem.

Side effects:

- None directly observable beyond calls listed below.

Called by:

- `scripts/loot/inv_overhaul_container_paging_controller.lua :: HandleControlAt`
- `scripts/loot/inv_overhaul_container_paging_controller.lua :: UpdateControlHover`
- `scripts/loot/inv_overhaul_container_tooltip_controller.lua :: LootTooltipIsInsidePlayerPaging`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `GetPlayerPageControlY(windowWidth: int) -> int`

Source: `scripts/loot/inv_overhaul_container_geometry.lua`

Purpose: Returns player page control y in the container geometry subsystem.

Parameters:

- `windowWidth: int` — current UI/layout size in pixels.

Returns:

- `number` (integer) — result of: returns player page control y in the container geometry subsystem.

Side effects:

- None directly observable beyond calls listed below.

Called by:

- `scripts/loot/inv_overhaul_container_paging_controller.lua :: HandleControlAt`
- `scripts/loot/inv_overhaul_container_paging_controller.lua :: UpdateControlHover`
- `scripts/loot/inv_overhaul_container_tooltip_controller.lua :: LootTooltipIsInsidePlayerPaging`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `GetContainerPageControlX(windowWidth: int) -> int`

Source: `scripts/loot/inv_overhaul_container_geometry.lua`

Purpose: Returns container page control x in the container geometry subsystem.

Parameters:

- `windowWidth: int` — current UI/layout size in pixels.

Returns:

- `number` (integer) — result of: returns container page control x in the container geometry subsystem.

Side effects:

- None directly observable beyond calls listed below.

Called by:

- `scripts/loot/inv_overhaul_container_paging_controller.lua :: HandleControlAt`
- `scripts/loot/inv_overhaul_container_paging_controller.lua :: UpdateControlHover`

Calls:

- `GetContainerStartX`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `GetContainerPageControlY(windowWidth: int, slotCount: int) -> int`

Source: `scripts/loot/inv_overhaul_container_geometry.lua`

Purpose: Returns container page control y in the container geometry subsystem.

Parameters:

- `windowWidth: int` — current UI/layout size in pixels.
- `slotCount: int` — slot index or encoded slot target interpreted by this function.

Returns:

- `number` (integer) — result of: returns container page control y in the container geometry subsystem.

Side effects:

- None directly observable beyond calls listed below.

Called by:

- `scripts/loot/inv_overhaul_container_paging_controller.lua :: HandleControlAt`
- `scripts/loot/inv_overhaul_container_paging_controller.lua :: UpdateControlHover`

Calls:

- `GetContainerStartY`
- `LootGeometryGetGridStep`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `IsInsidePageControl(maxPage: int, x: int, y: int, controlX: int, controlY: int) -> bool`

Source: `scripts/loot/inv_overhaul_container_geometry.lua`

Purpose: Returns whether inside page control in the container geometry subsystem.

Parameters:

- `maxPage: int` — zero-based page or page-related value.
- `x: int` — pointer/layout coordinate interpreted by this function.
- `y: int` — pointer/layout coordinate interpreted by this function.
- `controlX: int` — value interpreted according to the function purpose; no narrower contract is established by current code.
- `controlY: int` — value interpreted according to the function purpose; no narrower contract is established by current code.

Returns:

- `boolean` — result of: returns whether inside page control in the container geometry subsystem.

Side effects:

- None directly observable beyond calls listed below.

Called by:

- `scripts/loot/inv_overhaul_container_tooltip_controller.lua :: LootTooltipIsInsidePlayerPaging`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `GetPageControlAction(x: int, y: int, controlX: int, controlY: int) -> int`

Source: `scripts/loot/inv_overhaul_container_geometry.lua`

Purpose: Returns page control action in the container geometry subsystem.

Parameters:

- `x: int` — pointer/layout coordinate interpreted by this function.
- `y: int` — pointer/layout coordinate interpreted by this function.
- `controlX: int` — value interpreted according to the function purpose; no narrower contract is established by current code.
- `controlY: int` — value interpreted according to the function purpose; no narrower contract is established by current code.

Returns:

- `number` (integer) — result of: returns page control action in the container geometry subsystem.

Side effects:

- None directly observable beyond calls listed below.

Called by:

- `scripts/loot/inv_overhaul_container_geometry.lua :: IsPageButtonHovered`
- `scripts/loot/inv_overhaul_container_paging_controller.lua :: HandleControlAt`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `IsPageButtonHovered(action: int, currentPage: int, maxPage: int, x: int, y: int, controlX: int, controlY: int) -> bool`

Source: `scripts/loot/inv_overhaul_container_geometry.lua`

Purpose: Returns whether page button hovered in the container geometry subsystem.

Parameters:

- `action: int` — value interpreted according to the function purpose; no narrower contract is established by current code.
- `currentPage: int` — zero-based page or page-related value.
- `maxPage: int` — zero-based page or page-related value.
- `x: int` — pointer/layout coordinate interpreted by this function.
- `y: int` — pointer/layout coordinate interpreted by this function.
- `controlX: int` — value interpreted according to the function purpose; no narrower contract is established by current code.
- `controlY: int` — value interpreted according to the function purpose; no narrower contract is established by current code.

Returns:

- `boolean` — result of: returns whether page button hovered in the container geometry subsystem.

Side effects:

- None directly observable beyond calls listed below.

Called by:

- `scripts/loot/inv_overhaul_container_paging_controller.lua :: UpdateControlHover`

Calls:

- `GetPageControlAction`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `LootGeometryDecodePanelPointerX(message: int, base: int) -> int`

Source: `scripts/loot/inv_overhaul_container_geometry.lua`

Purpose: Decodes panel pointer x for loot geometry in the container geometry subsystem.

Parameters:

- `message: int` — numeric engine/UI protocol message.
- `base: int` — value interpreted according to the function purpose; no narrower contract is established by current code.

Returns:

- `number` (integer) — result of: decodes panel pointer x for loot geometry in the container geometry subsystem.

Side effects:

- None directly observable beyond calls listed below.

Called by:

- `scripts/loot/inv_overhaul_container_input_controller.lua :: LootInputHandlePanelPointer`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `LootGeometryDecodePanelPointerY(message: int, base: int) -> int`

Source: `scripts/loot/inv_overhaul_container_geometry.lua`

Purpose: Decodes panel pointer y for loot geometry in the container geometry subsystem.

Parameters:

- `message: int` — numeric engine/UI protocol message.
- `base: int` — value interpreted according to the function purpose; no narrower contract is established by current code.

Returns:

- `number` (integer) — result of: decodes panel pointer y for loot geometry in the container geometry subsystem.

Side effects:

- None directly observable beyond calls listed below.

Called by:

- `scripts/loot/inv_overhaul_container_input_controller.lua :: LootInputHandlePanelPointer`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.


## Internal API

No additional maintask helpers.

## Events / callbacks

No engine callbacks; this is an imported module.

## Important constants

- `c_iPanelPointerStride: int = 2000` — encoding stride/base used by panel pointer stride.
- `c_iSlotHotZone: int = 52` — named behavior/layout value for slot hot zone.
- `c_iSlotDropInset: int = 1` — named behavior/layout value for slot drop inset.

## Architectural notes

- Hard-coded coordinates mirror generated XML layouts and selected native hit tests. Layout changes must keep these representations synchronized.
