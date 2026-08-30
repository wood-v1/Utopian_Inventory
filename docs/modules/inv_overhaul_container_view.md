# Container View

## Source

`scripts/loot/inv_overhaul_container_view.lua`

DSL unit: `module inv_overhaul_container_view`

## Responsibility

Defines loot-screen window names and emits UI messages that render slots, organs, drag state, and page controls.

## Dependencies

- No local DSL imports.
- Pathologic native API — engine state, object access, persistence variables, UI messaging, timing, or rendering as listed per function.

## Used by

- `scripts/loot/inv_overhaul_container.lua`
- `scripts/loot/inv_overhaul_container_drag_controller.lua`
- `scripts/loot/inv_overhaul_container_input_controller.lua`
- `scripts/loot/inv_overhaul_container_paging_controller.lua`
- `scripts/loot/inv_overhaul_container_presenter.lua`
- `scripts/loot/inv_overhaul_container_protocol.lua`

## State

No module/task-level mutable state.

## Public API

All functions below are compiler-visible when the module is imported; the DSL has no private declaration.

### `GetPlayerSlotWndName(slot: int) -> string`

Source: `scripts/loot/inv_overhaul_container_view.lua`

Purpose: Returns player slot wnd name in the container view subsystem.

Parameters:

- `slot: int` — slot index or encoded slot target interpreted by this function.

Returns:

- `string` — result of: returns player slot wnd name in the container view subsystem.

Side effects:

- None directly observable beyond calls listed below.

Called by:

- `scripts/loot/inv_overhaul_container_presenter.lua :: UpdatePlayerSlot`
- `scripts/loot/inv_overhaul_container_protocol.lua :: LootProtocolGetTargetBySender`
- `scripts/loot/inv_overhaul_container_view.lua :: LootViewGetTargetWndName`
- `scripts/loot/inv_overhaul_container_view.lua :: LootViewConfigureSlotRenderSize`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `GetContainerSlotWndName(slot: int) -> string`

Source: `scripts/loot/inv_overhaul_container_view.lua`

Purpose: Returns container slot wnd name in the container view subsystem.

Parameters:

- `slot: int` — slot index or encoded slot target interpreted by this function.

Returns:

- `string` — result of: returns container slot wnd name in the container view subsystem.

Side effects:

- None directly observable beyond calls listed below.

Called by:

- `scripts/loot/inv_overhaul_container_presenter.lua :: UpdateContainerSlot`
- `scripts/loot/inv_overhaul_container_protocol.lua :: LootProtocolGetTargetBySender`
- `scripts/loot/inv_overhaul_container_view.lua :: LootViewGetTargetWndName`
- `scripts/loot/inv_overhaul_container_view.lua :: LootViewConfigureSlotRenderSize`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `GetOrganSlotWndName(slot: int) -> string`

Source: `scripts/loot/inv_overhaul_container_view.lua`

Purpose: Returns organ slot wnd name in the container view subsystem.

Parameters:

- `slot: int` — slot index or encoded slot target interpreted by this function.

Returns:

- `string` — result of: returns organ slot wnd name in the container view subsystem.

Side effects:

- None directly observable beyond calls listed below.

Called by:

- `scripts/loot/inv_overhaul_container.lua :: init`
- `scripts/loot/inv_overhaul_container_presenter.lua :: UpdateOrganSlots`
- `scripts/loot/inv_overhaul_container_protocol.lua :: LootProtocolGetTargetBySender`
- `scripts/loot/inv_overhaul_container_view.lua :: LootViewGetTargetWndName`
- `scripts/loot/inv_overhaul_container_view.lua :: LootViewConfigureSlotRenderSize`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `LootViewGetTargetWndName(target: int, visibleSlots: int) -> string`

Source: `scripts/loot/inv_overhaul_container_view.lua`

Purpose: Returns target wnd name for loot view in the container view subsystem.

Parameters:

- `target: int` — value interpreted according to the function purpose; no narrower contract is established by current code.
- `visibleSlots: int` — slot index or encoded slot target interpreted by this function.

Returns:

- `string` — result of: returns target wnd name for loot view in the container view subsystem.

Side effects:

- None directly observable beyond calls listed below.

Called by:

- `scripts/loot/inv_overhaul_container_drag_controller.lua :: Finish`
- `scripts/loot/inv_overhaul_container_view.lua :: SetTargetHighlighted`

Calls:

- `GetPlayerSlotWndName`
- `GetContainerSlotWndName`
- `GetOrganSlotWndName`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `LootViewConfigureSlotRenderSize(windowWidth: int, visibleSlots: int) -> void`

Source: `scripts/loot/inv_overhaul_container_view.lua`

Purpose: Configures slot render size for loot view in the container view subsystem.

Parameters:

- `windowWidth: int` — current UI/layout size in pixels.
- `visibleSlots: int` — slot index or encoded slot target interpreted by this function.

Returns:

None.

Side effects:

- Invokes engine/native operations: `native.SendMessage`.

Called by:

- `scripts/loot/inv_overhaul_container_presenter.lua :: LootPresenterUpdateLayout`

Calls:

- `native.SendMessage`
- `GetPlayerSlotWndName`
- `GetContainerSlotWndName`
- `GetOrganSlotWndName`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `LootViewUpdatePageControls(prefix: string, currentPage: int, maxPage: int) -> void`

Source: `scripts/loot/inv_overhaul_container_view.lua`

Purpose: Updates page controls for loot view in the container view subsystem.

Parameters:

- `prefix: string` — value interpreted according to the function purpose; no narrower contract is established by current code.
- `currentPage: int` — zero-based page or page-related value.
- `maxPage: int` — zero-based page or page-related value.

Returns:

None.

Side effects:

- Invokes engine/native operations: `native.SendMessage`.

Called by:

- `scripts/loot/inv_overhaul_container_presenter.lua :: UpdatePlayerPageControls`
- `scripts/loot/inv_overhaul_container_presenter.lua :: UpdateContainerPageControls`

Calls:

- `native.SendMessage`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `ResetPageControls(prefix: string, resetPreviousMessage: int, resetNextMessage: int) -> void`

Source: `scripts/loot/inv_overhaul_container_view.lua`

Purpose: Resets page controls in the container view subsystem.

Parameters:

- `prefix: string` — value interpreted according to the function purpose; no narrower contract is established by current code.
- `resetPreviousMessage: int` — value interpreted according to the function purpose; no narrower contract is established by current code.
- `resetNextMessage: int` — value interpreted according to the function purpose; no narrower contract is established by current code.

Returns:

None.

Side effects:

- Invokes engine/native operations: `native.SendMessage`.

Called by:

- `scripts/loot/inv_overhaul_container_presenter.lua :: UpdatePlayerPageControls`
- `scripts/loot/inv_overhaul_container_presenter.lua :: UpdateContainerPageControls`

Calls:

- `native.SendMessage`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `RenderPlayerSlotUnavailable(wnd: string) -> void`

Source: `scripts/loot/inv_overhaul_container_view.lua`

Purpose: Renders player slot unavailable in the container view subsystem.

Parameters:

- `wnd: string` — value interpreted according to the function purpose; no narrower contract is established by current code.

Returns:

None.

Side effects:

- Invokes engine/native operations: `native.SendMessage`.

Called by:

- `scripts/loot/inv_overhaul_container_presenter.lua :: UpdatePlayerSlot`

Calls:

- `native.SendMessage`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `BeginPlayerSlot(wnd: string) -> void`

Source: `scripts/loot/inv_overhaul_container_view.lua`

Purpose: Begins player slot in the container view subsystem.

Parameters:

- `wnd: string` — value interpreted according to the function purpose; no narrower contract is established by current code.

Returns:

None.

Side effects:

- Invokes engine/native operations: `native.SendMessage`.

Called by:

- `scripts/loot/inv_overhaul_container_presenter.lua :: UpdatePlayerSlot`

Calls:

- `native.SendMessage`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `RenderPlayerSlotEmpty(wnd: string) -> void`

Source: `scripts/loot/inv_overhaul_container_view.lua`

Purpose: Renders player slot empty in the container view subsystem.

Parameters:

- `wnd: string` — value interpreted according to the function purpose; no narrower contract is established by current code.

Returns:

None.

Side effects:

- Invokes engine/native operations: `native.SendMessage`.

Called by:

- `scripts/loot/inv_overhaul_container_presenter.lua :: UpdatePlayerSlot`

Calls:

- `native.SendMessage`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `RenderPlayerSlotItem(wnd: string, item: object, amount: int) -> void`

Source: `scripts/loot/inv_overhaul_container_view.lua`

Purpose: Renders player slot item in the container view subsystem.

Parameters:

- `wnd: string` — value interpreted according to the function purpose; no narrower contract is established by current code.
- `item: object` — engine inventory-item object; available properties and methods are supplied by the game.
- `amount: int` — value interpreted according to the function purpose; no narrower contract is established by current code.

Returns:

None.

Side effects:

- Invokes engine/native operations: `native.SendMessage`.

Called by:

- `scripts/loot/inv_overhaul_container_presenter.lua :: UpdatePlayerSlot`

Calls:

- `native.SendMessage`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `RenderPlayerQuickslot(wnd: string, quickslot: int) -> void`

Source: `scripts/loot/inv_overhaul_container_view.lua`

Purpose: Renders player quickslot in the container view subsystem.

Parameters:

- `wnd: string` — value interpreted according to the function purpose; no narrower contract is established by current code.
- `quickslot: int` — slot index or encoded slot target interpreted by this function.

Returns:

None.

Side effects:

- Invokes engine/native operations: `native.SendMessage`.

Called by:

- `scripts/loot/inv_overhaul_container_presenter.lua :: UpdatePlayerSlot`

Calls:

- `native.SendMessage`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `RenderContainerSlotEmpty(wnd: string) -> void`

Source: `scripts/loot/inv_overhaul_container_view.lua`

Purpose: Renders container slot empty in the container view subsystem.

Parameters:

- `wnd: string` — value interpreted according to the function purpose; no narrower contract is established by current code.

Returns:

None.

Side effects:

- Invokes engine/native operations: `native.SendMessage`.

Called by:

- `scripts/loot/inv_overhaul_container_presenter.lua :: UpdateContainerSlot`

Calls:

- `native.SendMessage`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `RenderContainerSlotItem(wnd: string, item: object, amount: int) -> void`

Source: `scripts/loot/inv_overhaul_container_view.lua`

Purpose: Renders container slot item in the container view subsystem.

Parameters:

- `wnd: string` — value interpreted according to the function purpose; no narrower contract is established by current code.
- `item: object` — engine inventory-item object; available properties and methods are supplied by the game.
- `amount: int` — value interpreted according to the function purpose; no narrower contract is established by current code.

Returns:

None.

Side effects:

- Invokes engine/native operations: `native.SendMessage`.

Called by:

- `scripts/loot/inv_overhaul_container_presenter.lua :: UpdateContainerSlot`

Calls:

- `native.SendMessage`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `RenderOrganSlotHidden(wnd: string) -> void`

Source: `scripts/loot/inv_overhaul_container_view.lua`

Purpose: Renders organ slot hidden in the container view subsystem.

Parameters:

- `wnd: string` — value interpreted according to the function purpose; no narrower contract is established by current code.

Returns:

None.

Side effects:

- Invokes engine/native operations: `native.SendMessage`.

Called by:

- `scripts/loot/inv_overhaul_container_presenter.lua :: UpdateOrganSlots`

Calls:

- `native.SendMessage`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `BeginOrganSlot(wnd: string) -> void`

Source: `scripts/loot/inv_overhaul_container_view.lua`

Purpose: Begins organ slot in the container view subsystem.

Parameters:

- `wnd: string` — value interpreted according to the function purpose; no narrower contract is established by current code.

Returns:

None.

Side effects:

- Invokes engine/native operations: `native.SendMessage`.

Called by:

- `scripts/loot/inv_overhaul_container_presenter.lua :: UpdateOrganSlots`

Calls:

- `native.SendMessage`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `RenderOrganSlotEmpty(wnd: string) -> void`

Source: `scripts/loot/inv_overhaul_container_view.lua`

Purpose: Renders organ slot empty in the container view subsystem.

Parameters:

- `wnd: string` — value interpreted according to the function purpose; no narrower contract is established by current code.

Returns:

None.

Side effects:

- Invokes engine/native operations: `native.SendMessage`.

Called by:

- `scripts/loot/inv_overhaul_container_presenter.lua :: UpdateOrganSlots`

Calls:

- `native.SendMessage`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `RenderOrganSlotItem(wnd: string, item: object, amount: int) -> void`

Source: `scripts/loot/inv_overhaul_container_view.lua`

Purpose: Renders organ slot item in the container view subsystem.

Parameters:

- `wnd: string` — value interpreted according to the function purpose; no narrower contract is established by current code.
- `item: object` — engine inventory-item object; available properties and methods are supplied by the game.
- `amount: int` — value interpreted according to the function purpose; no narrower contract is established by current code.

Returns:

None.

Side effects:

- Invokes engine/native operations: `native.SendMessage`.

Called by:

- `scripts/loot/inv_overhaul_container_presenter.lua :: UpdateOrganSlots`

Calls:

- `native.SendMessage`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `BeginOrganSlotItem(wnd: string) -> void`

Source: `scripts/loot/inv_overhaul_container_view.lua`

Purpose: Begins organ slot item in the container view subsystem.

Parameters:

- `wnd: string` — value interpreted according to the function purpose; no narrower contract is established by current code.

Returns:

None.

Side effects:

- Invokes engine/native operations: `native.SendMessage`.

Called by:

- `scripts/loot/inv_overhaul_container_presenter.lua :: UpdateOrganSlots`

Calls:

- `native.SendMessage`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `SetTargetHighlighted(target: int, visibleSlots: int, highlighted: bool) -> void`

Source: `scripts/loot/inv_overhaul_container_view.lua`

Purpose: Sets target highlighted in the container view subsystem.

Parameters:

- `target: int` — value interpreted according to the function purpose; no narrower contract is established by current code.
- `visibleSlots: int` — slot index or encoded slot target interpreted by this function.
- `highlighted: bool` — behavior flag interpreted by this function.

Returns:

None.

Side effects:

- Invokes engine/native operations: `native.SendMessage`.

Called by:

- `scripts/loot/inv_overhaul_container_drag_controller.lua :: LootDragControllerSetHighlightedTarget`

Calls:

- `native.SendMessage`
- `LootViewGetTargetWndName`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `SetPageButtonHover(wnd: string, highlighted: bool) -> void`

Source: `scripts/loot/inv_overhaul_container_view.lua`

Purpose: Sets page button hover in the container view subsystem.

Parameters:

- `wnd: string` — value interpreted according to the function purpose; no narrower contract is established by current code.
- `highlighted: bool` — behavior flag interpreted by this function.

Returns:

None.

Side effects:

- Invokes engine/native operations: `native.SendMessage`.

Called by:

- `scripts/loot/inv_overhaul_container_paging_controller.lua :: UpdateControlHover`
- `scripts/loot/inv_overhaul_container_view.lua :: ClearPageControlHover`

Calls:

- `native.SendMessage`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `ClearPageControlHover() -> void`

Source: `scripts/loot/inv_overhaul_container_view.lua`

Purpose: Clears page control hover in the container view subsystem.

Parameters:

None.

Returns:

None.

Side effects:

- None directly observable beyond calls listed below.

Called by:

- `scripts/loot/inv_overhaul_container_input_controller.lua :: LootInputHandlePanelPointer`

Calls:

- `SetPageButtonHover`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.


## Internal API

No additional maintask helpers.

## Events / callbacks

No engine callbacks; this is an imported module.

## Important constants

- `c_iSlotEmpty: int = 32768` — named behavior/layout value for slot empty.
- `c_iSlotNumber: int = 65536` — named behavior/layout value for slot number.
- `c_iTargetDrop: int = 200` — numeric UI/action target identifier for target drop.
- `c_iTargetContainerBase: int = 300` — encoding stride/base used by target container base.
- `c_iTargetOrganBase: int = 400` — encoding stride/base used by target organ base.
- `c_iContainerSlots: int = 12` — named behavior/layout value for container slots.
- `c_iOrganSlots: int = 4` — named behavior/layout value for organ slots.

## Architectural notes

- No additional module-specific issue identified beyond repository-wide shared-variable and compiler-visible API constraints.
