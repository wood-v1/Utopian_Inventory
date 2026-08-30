# Container Protocol

## Source

`scripts/loot/inv_overhaul_container_protocol.lua`

DSL unit: `module inv_overhaul_container_protocol`

## Responsibility

Defines the loot screen's numeric messages, target identifiers, and sender-name mappings.

## Dependencies

- `inv_overhaul_container_geometry` — Maps supported layouts to player, container, organ, money, paging, and pointer hit-test geometry.
- `inv_overhaul_container_view` — Defines loot-screen window names and emits UI messages that render slots, organs, drag state, and page controls.

## Used by

- `scripts/loot/inv_overhaul_container_drag_controller.lua`
- `scripts/loot/inv_overhaul_container_input_controller.lua`
- `scripts/loot/inv_overhaul_container_quick_transfer.lua`
- `scripts/loot/inv_overhaul_container_tooltip_controller.lua`

## State

No module/task-level mutable state.

## Public API

All functions below are compiler-visible when the module is imported; the DSL has no private declaration.

### `IsPlayerTarget(target: int, visibleSlots: int) -> bool`

Source: `scripts/loot/inv_overhaul_container_protocol.lua`

Purpose: Returns whether player target in the container protocol subsystem.

Parameters:

- `target: int` — value interpreted according to the function purpose; no narrower contract is established by current code.
- `visibleSlots: int` — slot index or encoded slot target interpreted by this function.

Returns:

- `boolean` — result of: returns whether player target in the container protocol subsystem.

Side effects:

- None directly observable beyond calls listed below.

Called by:

- `scripts/loot/inv_overhaul_container_drag_controller.lua :: ResolveSource`
- `scripts/loot/inv_overhaul_container_drag_controller.lua :: LootDragControllerApplyPointerTarget`
- `scripts/loot/inv_overhaul_container_drag_controller.lua :: Finish`
- `scripts/loot/inv_overhaul_container_protocol.lua :: LootProtocolIsTargetCompatible`
- `scripts/loot/inv_overhaul_container_quick_transfer.lua :: Execute`
- `scripts/loot/inv_overhaul_container_tooltip_controller.lua :: Update`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `IsContainerTarget(target: int) -> bool`

Source: `scripts/loot/inv_overhaul_container_protocol.lua`

Purpose: Returns whether container target in the container protocol subsystem.

Parameters:

- `target: int` — value interpreted according to the function purpose; no narrower contract is established by current code.

Returns:

- `boolean` — result of: returns whether container target in the container protocol subsystem.

Side effects:

- None directly observable beyond calls listed below.

Called by:

- `scripts/loot/inv_overhaul_container_drag_controller.lua :: ResolveSource`
- `scripts/loot/inv_overhaul_container_drag_controller.lua :: LootDragControllerApplyPointerTarget`
- `scripts/loot/inv_overhaul_container_drag_controller.lua :: Finish`
- `scripts/loot/inv_overhaul_container_protocol.lua :: GetContainerSlot`
- `scripts/loot/inv_overhaul_container_protocol.lua :: LootProtocolIsTargetCompatible`
- `scripts/loot/inv_overhaul_container_quick_transfer.lua :: Execute`
- `scripts/loot/inv_overhaul_container_tooltip_controller.lua :: ResolveExternalItem`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `IsOrganTarget(target: int) -> bool`

Source: `scripts/loot/inv_overhaul_container_protocol.lua`

Purpose: Returns whether organ target in the container protocol subsystem.

Parameters:

- `target: int` — value interpreted according to the function purpose; no narrower contract is established by current code.

Returns:

- `boolean` — result of: returns whether organ target in the container protocol subsystem.

Side effects:

- None directly observable beyond calls listed below.

Called by:

- `scripts/loot/inv_overhaul_container_drag_controller.lua :: ResolveSource`
- `scripts/loot/inv_overhaul_container_protocol.lua :: GetOrganSlot`
- `scripts/loot/inv_overhaul_container_protocol.lua :: LootProtocolGetSlotTargetFromPointerMessage`
- `scripts/loot/inv_overhaul_container_quick_transfer.lua :: Execute`
- `scripts/loot/inv_overhaul_container_tooltip_controller.lua :: ResolveExternalItem`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `GetContainerSlot(target: int) -> int`

Source: `scripts/loot/inv_overhaul_container_protocol.lua`

Purpose: Returns container slot in the container protocol subsystem.

Parameters:

- `target: int` — value interpreted according to the function purpose; no narrower contract is established by current code.

Returns:

- `number` (integer) — result of: returns container slot in the container protocol subsystem.

Side effects:

- None directly observable beyond calls listed below.

Called by:

- `scripts/loot/inv_overhaul_container_drag_controller.lua :: ResolveSource`
- `scripts/loot/inv_overhaul_container_drag_controller.lua :: LootDragControllerApplyPointerTarget`
- `scripts/loot/inv_overhaul_container_drag_controller.lua :: Finish`
- `scripts/loot/inv_overhaul_container_quick_transfer.lua :: Execute`
- `scripts/loot/inv_overhaul_container_tooltip_controller.lua :: ResolveExternalItem`

Calls:

- `IsContainerTarget`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `GetOrganSlot(target: int) -> int`

Source: `scripts/loot/inv_overhaul_container_protocol.lua`

Purpose: Returns organ slot in the container protocol subsystem.

Parameters:

- `target: int` — value interpreted according to the function purpose; no narrower contract is established by current code.

Returns:

- `number` (integer) — result of: returns organ slot in the container protocol subsystem.

Side effects:

- None directly observable beyond calls listed below.

Called by:

- `scripts/loot/inv_overhaul_container_drag_controller.lua :: ResolveSource`
- `scripts/loot/inv_overhaul_container_drag_controller.lua :: Finish`
- `scripts/loot/inv_overhaul_container_quick_transfer.lua :: Execute`
- `scripts/loot/inv_overhaul_container_tooltip_controller.lua :: ResolveExternalItem`

Calls:

- `IsOrganTarget`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `LootProtocolGetTargetBySender(sender: string, visibleSlots: int) -> int`

Source: `scripts/loot/inv_overhaul_container_protocol.lua`

Purpose: Returns target by sender for loot protocol in the container protocol subsystem.

Parameters:

- `sender: string` — name of the UI form that emitted the message.
- `visibleSlots: int` — slot index or encoded slot target interpreted by this function.

Returns:

- `number` (integer) — result of: returns target by sender for loot protocol in the container protocol subsystem.

Side effects:

- Delegates to compiler-visible module APIs and inherits their documented side effects.

Called by:

- `scripts/loot/inv_overhaul_container_drag_controller.lua :: LootDragControllerGetTargetBySender`
- `scripts/loot/inv_overhaul_container_protocol.lua :: LootProtocolGetSlotTargetFromPointerMessage`

Calls:

- `inv_overhaul_container_view.GetPlayerSlotWndName`
- `inv_overhaul_container_view.GetContainerSlotWndName`
- `inv_overhaul_container_view.GetOrganSlotWndName`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `LootProtocolFindTargetAt(windowWidth: int, visibleSlots: int, showOrgans: bool, x: int, y: int) -> int`

Source: `scripts/loot/inv_overhaul_container_protocol.lua`

Purpose: Finds target at for loot protocol in the container protocol subsystem.

Parameters:

- `windowWidth: int` — current UI/layout size in pixels.
- `visibleSlots: int` — slot index or encoded slot target interpreted by this function.
- `showOrgans: bool` — behavior flag interpreted by this function.
- `x: int` — pointer/layout coordinate interpreted by this function.
- `y: int` — pointer/layout coordinate interpreted by this function.

Returns:

- `number` (integer) — result of: finds target at for loot protocol in the container protocol subsystem.

Side effects:

- Delegates to compiler-visible module APIs and inherits their documented side effects.

Called by:

- `scripts/loot/inv_overhaul_container_drag_controller.lua :: LootDragControllerFindTargetAt`
- `scripts/loot/inv_overhaul_container_tooltip_controller.lua :: Update`

Calls:

- `inv_overhaul_container_geometry.FindPlayerSlotAt`
- `inv_overhaul_container_geometry.FindContainerSlotAt`
- `inv_overhaul_container_geometry.FindOrganSlotAt`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `LootProtocolIsTargetCompatible(sourceKind: int, target: int, visibleSlots: int) -> bool`

Source: `scripts/loot/inv_overhaul_container_protocol.lua`

Purpose: Returns whether target compatible for loot protocol in the container protocol subsystem.

Parameters:

- `sourceKind: int` — value interpreted according to the function purpose; no narrower contract is established by current code.
- `target: int` — value interpreted according to the function purpose; no narrower contract is established by current code.
- `visibleSlots: int` — slot index or encoded slot target interpreted by this function.

Returns:

- `boolean` — result of: returns whether target compatible for loot protocol in the container protocol subsystem.

Side effects:

- None directly observable beyond calls listed below.

Called by:

- `scripts/loot/inv_overhaul_container_drag_controller.lua :: LootDragControllerIsTargetCompatible`

Calls:

- `IsPlayerTarget`
- `IsContainerTarget`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `LootProtocolGetSlotTargetFromPointerMessage(message: int, base: int, sender: string, visibleSlots: int, windowWidth: int) -> int`

Source: `scripts/loot/inv_overhaul_container_protocol.lua`

Purpose: Returns slot target from pointer message for loot protocol in the container protocol subsystem.

Parameters:

- `message: int` — numeric engine/UI protocol message.
- `base: int` — value interpreted according to the function purpose; no narrower contract is established by current code.
- `sender: string` — name of the UI form that emitted the message.
- `visibleSlots: int` — slot index or encoded slot target interpreted by this function.
- `windowWidth: int` — current UI/layout size in pixels.

Returns:

- `number` (integer) — result of: returns slot target from pointer message for loot protocol in the container protocol subsystem.

Side effects:

- Delegates to compiler-visible module APIs and inherits their documented side effects.

Called by:

- `scripts/loot/inv_overhaul_container_input_controller.lua :: GetSlotPointerTarget`

Calls:

- `LootProtocolGetTargetBySender`
- `inv_overhaul_container_geometry.GetSlotHotZone`
- `IsOrganTarget`
- `inv_overhaul_container_geometry.GetOrganSlotHotZone`
- `inv_overhaul_container_geometry.LootGeometryIsInsideSlotDropArea`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `IsPanelPointerMessage(message: int) -> bool`

Source: `scripts/loot/inv_overhaul_container_protocol.lua`

Purpose: Returns whether panel pointer message in the container protocol subsystem.

Parameters:

- `message: int` — numeric engine/UI protocol message.

Returns:

- `boolean` — result of: returns whether panel pointer message in the container protocol subsystem.

Side effects:

- None directly observable beyond calls listed below.

Called by:

- `scripts/loot/inv_overhaul_container_input_controller.lua :: HandleUIMessage`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `GetPanelPointerAction(message: int) -> int`

Source: `scripts/loot/inv_overhaul_container_protocol.lua`

Purpose: Returns panel pointer action in the container protocol subsystem.

Parameters:

- `message: int` — numeric engine/UI protocol message.

Returns:

- `number` (integer) — result of: returns panel pointer action in the container protocol subsystem.

Side effects:

- None directly observable beyond calls listed below.

Called by:

- `scripts/loot/inv_overhaul_container_input_controller.lua :: LootInputHandlePanelPointer`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `GetPanelPointerBase(message: int) -> int`

Source: `scripts/loot/inv_overhaul_container_protocol.lua`

Purpose: Returns panel pointer base in the container protocol subsystem.

Parameters:

- `message: int` — numeric engine/UI protocol message.

Returns:

- `number` (integer) — result of: returns panel pointer base in the container protocol subsystem.

Side effects:

- None directly observable beyond calls listed below.

Called by:

- `scripts/loot/inv_overhaul_container_input_controller.lua :: LootInputHandlePanelPointer`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `GetSlotPointerAction(message: int) -> int`

Source: `scripts/loot/inv_overhaul_container_protocol.lua`

Purpose: Returns slot pointer action in the container protocol subsystem.

Parameters:

- `message: int` — numeric engine/UI protocol message.

Returns:

- `number` (integer) — result of: returns slot pointer action in the container protocol subsystem.

Side effects:

- None directly observable beyond calls listed below.

Called by:

- `scripts/loot/inv_overhaul_container_input_controller.lua :: HandleSlotPointerMessage`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `GetSlotPointerBase(message: int) -> int`

Source: `scripts/loot/inv_overhaul_container_protocol.lua`

Purpose: Returns slot pointer base in the container protocol subsystem.

Parameters:

- `message: int` — numeric engine/UI protocol message.

Returns:

- `number` (integer) — result of: returns slot pointer base in the container protocol subsystem.

Side effects:

- None directly observable beyond calls listed below.

Called by:

- `scripts/loot/inv_overhaul_container_input_controller.lua :: HandleSlotPointerMessage`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.


## Internal API

No additional maintask helpers.

## Events / callbacks

No engine callbacks; this is an imported module.

## Important constants

- `HoverMessageBase: int = 100000` — numeric engine/UI protocol value for hover message base.
- `ReleaseMessageBase: int = 200000` — numeric engine/UI protocol value for release message base.
- `DragEndMessageBase: int = 300000` — numeric engine/UI protocol value for drag end message base.
- `SlotPointerStride: int = 100` — encoding stride/base used by slot pointer stride.
- `PanelPointerMoveBase: int = 1000000` — numeric engine/UI protocol value for panel pointer move base.
- `PanelPointerDownBase: int = 4000000` — numeric engine/UI protocol value for panel pointer down base.
- `PanelPointerUpBase: int = 7000000` — numeric engine/UI protocol value for panel pointer up base.
- `PanelPointerRightBase: int = 10000000` — numeric engine/UI protocol value for panel pointer right base.
- `PanelPointerDragBeginBase: int = 13000000` — numeric engine/UI protocol value for panel pointer drag begin base.
- `PanelPointerDragEndBase: int = 16000000` — numeric engine/UI protocol value for panel pointer drag end base.
- `PanelPointerLeaveBase: int = 19000000` — numeric engine/UI protocol value for panel pointer leave base.
- `TargetDrop: int = 200` — numeric UI/action target identifier for target drop.
- `TargetContainerBase: int = 300` — encoding stride/base used by target container base.
- `TargetOrganBase: int = 400` — encoding stride/base used by target organ base.
- `ContainerTargetMoney: int = 500` — numeric UI/action target identifier for container target money.
- `ContainerTargetPaging: int = 600` — numeric UI/action target identifier for container target paging.
- `ContainerTargetQuickslotHelp: int = 601` — numeric UI/action target identifier for container target quickslot help.
- `ContainerQuickslotHelpHover: int = 29800001` — named behavior/layout value for container quickslot help hover.
- `ContainerGridRendererReady: int = 29900000` — named behavior/layout value for container grid renderer ready.
- `ContainerPageHoverEnter: int = -110` — named behavior/layout value for container page hover enter.
- `ContainerPageHoverLeave: int = -111` — named behavior/layout value for container page hover leave.
- `ContainerSlots: int = 12` — named behavior/layout value for container slots.
- `OrganSlots: int = 4` — named behavior/layout value for organ slots.

## Architectural notes

- Message ranges and sender-name mappings are a manually coordinated UI ABI; numeric changes can affect multiple controllers and forms.
