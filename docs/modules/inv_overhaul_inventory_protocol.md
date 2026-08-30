# Inventory Protocol

## Source

`scripts/inventory_interface/inv_overhaul_inventory_protocol.lua`

DSL unit: `module inv_overhaul_inventory_protocol`

## Responsibility

Defines and encodes the numeric UI message protocol shared by inventory forms and controllers.

## Dependencies

- No local DSL imports.

## Used by

- `scripts/inventory_interface/inv_overhaul_inventory_background.lua`
- `scripts/inventory_interface/inv_overhaul_inventory_geometry.lua`
- `scripts/inventory_interface/inv_overhaul_inventory_tooltip.lua`
- `scripts/player_inventory/inv_overhaul_inventory_controller.lua`
- `scripts/player_inventory/inv_overhaul_inventory_equipment.lua`
- `scripts/player_inventory/inv_overhaul_inventory_input_controller.lua`
- `scripts/player_inventory/inv_overhaul_inventory_presenter.lua`
- `scripts/player_inventory/inv_overhaul_inventory_view.lua`
- `scripts/player_inventory/widgets/inv_overhaul_character_doll.lua`

## State

No module/task-level mutable state.

## Public API

All functions below are compiler-visible when the module is imported; the DSL has no private declaration.

### `EncodePanelPointer(base: int, x: int, y: int) -> int`

Source: `scripts/inventory_interface/inv_overhaul_inventory_protocol.lua`

Purpose: Encodes panel pointer in the inventory protocol subsystem.

Parameters:

- `base: int` — value interpreted according to the function purpose; no narrower contract is established by current code.
- `x: int` — pointer/layout coordinate interpreted by this function.
- `y: int` — pointer/layout coordinate interpreted by this function.

Returns:

- `number` (integer) — result of: encodes panel pointer in the inventory protocol subsystem.

Side effects:

- None directly observable beyond calls listed below.

Called by:

- `scripts/inventory_interface/inv_overhaul_inventory_background.lua :: SendPointer`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `InterfaceProtocolDecodePanelPointerX(message: int, base: int) -> int`

Source: `scripts/inventory_interface/inv_overhaul_inventory_protocol.lua`

Purpose: Decodes panel pointer x for interface protocol in the inventory protocol subsystem.

Parameters:

- `message: int` — numeric engine/UI protocol message.
- `base: int` — value interpreted according to the function purpose; no narrower contract is established by current code.

Returns:

- `number` (integer) — result of: decodes panel pointer x for interface protocol in the inventory protocol subsystem.

Side effects:

- None directly observable beyond calls listed below.

Called by:

- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: PlayerControllerHandlePanelPointer`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `InterfaceProtocolDecodePanelPointerY(message: int, base: int) -> int`

Source: `scripts/inventory_interface/inv_overhaul_inventory_protocol.lua`

Purpose: Decodes panel pointer y for interface protocol in the inventory protocol subsystem.

Parameters:

- `message: int` — numeric engine/UI protocol message.
- `base: int` — value interpreted according to the function purpose; no narrower contract is established by current code.

Returns:

- `number` (integer) — result of: decodes panel pointer y for interface protocol in the inventory protocol subsystem.

Side effects:

- None directly observable beyond calls listed below.

Called by:

- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: PlayerControllerHandlePanelPointer`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `EncodeGridRenderer(slot: int, operation: int, value: int) -> int`

Source: `scripts/inventory_interface/inv_overhaul_inventory_protocol.lua`

Purpose: Encodes grid renderer in the inventory protocol subsystem.

Parameters:

- `slot: int` — slot index or encoded slot target interpreted by this function.
- `operation: int` — value interpreted according to the function purpose; no narrower contract is established by current code.
- `value: int` — value interpreted according to the function purpose; no narrower contract is established by current code.

Returns:

- `number` (integer) — result of: encodes grid renderer in the inventory protocol subsystem.

Side effects:

- None directly observable beyond calls listed below.

Called by:

- `scripts/player_inventory/inv_overhaul_inventory_view.lua :: PlayerViewSendGridRendererState`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `DecodeGridRendererSlot(message: int) -> int`

Source: `scripts/inventory_interface/inv_overhaul_inventory_protocol.lua`

Purpose: Decodes grid renderer slot in the inventory protocol subsystem.

Parameters:

- `message: int` — numeric engine/UI protocol message.

Returns:

- `number` (integer) — result of: decodes grid renderer slot in the inventory protocol subsystem.

Side effects:

- None directly observable beyond calls listed below.

Called by:

- `scripts/inventory_interface/inv_overhaul_inventory_background.lua :: HandleGridRendererMessage`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `DecodeGridRendererOperation(message: int) -> int`

Source: `scripts/inventory_interface/inv_overhaul_inventory_protocol.lua`

Purpose: Decodes grid renderer operation in the inventory protocol subsystem.

Parameters:

- `message: int` — numeric engine/UI protocol message.

Returns:

- `number` (integer) — result of: decodes grid renderer operation in the inventory protocol subsystem.

Side effects:

- None directly observable beyond calls listed below.

Called by:

- `scripts/inventory_interface/inv_overhaul_inventory_background.lua :: HandleGridRendererMessage`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `DecodeGridRendererValue(message: int) -> int`

Source: `scripts/inventory_interface/inv_overhaul_inventory_protocol.lua`

Purpose: Decodes grid renderer value in the inventory protocol subsystem.

Parameters:

- `message: int` — numeric engine/UI protocol message.

Returns:

- `number` (integer) — result of: decodes grid renderer value in the inventory protocol subsystem.

Side effects:

- None directly observable beyond calls listed below.

Called by:

- `scripts/inventory_interface/inv_overhaul_inventory_background.lua :: HandleGridRendererMessage`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `GetSlotWindowName(slot: int) -> string`

Source: `scripts/inventory_interface/inv_overhaul_inventory_protocol.lua`

Purpose: Returns slot window name in the inventory protocol subsystem.

Parameters:

- `slot: int` — slot index or encoded slot target interpreted by this function.

Returns:

- `string` — result of: returns slot window name in the inventory protocol subsystem.

Side effects:

- None directly observable beyond calls listed below.

Called by:

- `scripts/inventory_interface/inv_overhaul_inventory_protocol.lua :: GetSlotBySender`
- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: HandleSlotMessage`
- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: PlayerControllerHandlePanelPointer`
- `scripts/player_inventory/inv_overhaul_inventory_view.lua :: GetTargetWindowName`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `GetSlotBySender(sender: string, visibleSlots: int) -> int`

Source: `scripts/inventory_interface/inv_overhaul_inventory_protocol.lua`

Purpose: Returns slot by sender in the inventory protocol subsystem.

Parameters:

- `sender: string` — name of the UI form that emitted the message.
- `visibleSlots: int` — slot index or encoded slot target interpreted by this function.

Returns:

- `number` (integer) — result of: returns slot by sender in the inventory protocol subsystem.

Side effects:

- None directly observable beyond calls listed below.

Called by:

- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: GetDragSourceBySender`
- `scripts/player_inventory/inv_overhaul_inventory_input_controller.lua :: PlayerInputGetSlotTargetFromPointerMessage`

Calls:

- `GetSlotWindowName`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `GetSpecialTargetBySender(sender: string) -> int`

Source: `scripts/inventory_interface/inv_overhaul_inventory_protocol.lua`

Purpose: Returns special target by sender in the inventory protocol subsystem.

Parameters:

- `sender: string` — name of the UI form that emitted the message.

Returns:

- `number` (integer) — result of: returns special target by sender in the inventory protocol subsystem.

Side effects:

- None directly observable beyond calls listed below.

Called by:

- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: GetDragSourceBySender`
- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: HandleEquipmentProtocolMessage`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `GetDollTargetByHoverMessage(message: int) -> int`

Source: `scripts/inventory_interface/inv_overhaul_inventory_protocol.lua`

Purpose: Returns doll target by hover message in the inventory protocol subsystem.

Parameters:

- `message: int` — numeric engine/UI protocol message.

Returns:

- `number` (integer) — result of: returns doll target by hover message in the inventory protocol subsystem.

Side effects:

- None directly observable beyond calls listed below.

Called by:

- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: HandleEquipmentProtocolMessage`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `GetDollTargetBySourceMessage(message: int, base: int) -> int`

Source: `scripts/inventory_interface/inv_overhaul_inventory_protocol.lua`

Purpose: Returns doll target by source message in the inventory protocol subsystem.

Parameters:

- `message: int` — numeric engine/UI protocol message.
- `base: int` — value interpreted according to the function purpose; no narrower contract is established by current code.

Returns:

- `number` (integer) — result of: returns doll target by source message in the inventory protocol subsystem.

Side effects:

- None directly observable beyond calls listed below.

Called by:

- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: HandleEquipmentProtocolMessage`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `GetDollSourceMessage(targetMessage: int, base: int) -> int`

Source: `scripts/inventory_interface/inv_overhaul_inventory_protocol.lua`

Purpose: Returns doll source message in the inventory protocol subsystem.

Parameters:

- `targetMessage: int` — value interpreted according to the function purpose; no narrower contract is established by current code.
- `base: int` — value interpreted according to the function purpose; no narrower contract is established by current code.

Returns:

- `number` (integer) — result of: returns doll source message in the inventory protocol subsystem.

Side effects:

- None directly observable beyond calls listed below.

Called by:

- `scripts/player_inventory/widgets/inv_overhaul_character_doll.lua :: OnLButtonDown`
- `scripts/player_inventory/widgets/inv_overhaul_character_doll.lua :: OnRButtonDown`
- `scripts/player_inventory/widgets/inv_overhaul_character_doll.lua :: OnDragBegin`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.


## Internal API

No additional maintask helpers.

## Events / callbacks

No engine callbacks; this is an imported module.

## Important constants

- `PointerMoveBase: int = 1000000` — numeric engine/UI protocol value for pointer move base.
- `PointerDownBase: int = 4000000` — numeric engine/UI protocol value for pointer down base.
- `PointerUpBase: int = 7000000` — numeric engine/UI protocol value for pointer up base.
- `PointerRightBase: int = 10000000` — numeric engine/UI protocol value for pointer right base.
- `PointerDragBeginBase: int = 13000000` — numeric engine/UI protocol value for pointer drag begin base.
- `PointerDragEndBase: int = 16000000` — numeric engine/UI protocol value for pointer drag end base.
- `PointerLeaveBase: int = 19000000` — numeric engine/UI protocol value for pointer leave base.
- `PointerStride: int = 2000` — encoding stride/base used by pointer stride.
- `GridRendererMessageBase: int = 30000000` — numeric engine/UI protocol value for grid renderer message base.
- `GridRendererSlotStride: int = 100000` — encoding stride/base used by grid renderer slot stride.
- `GridRendererOperationStride: int = 20000` — encoding stride/base used by grid renderer operation stride.
- `GridRendererItem: int = 1` — named behavior/layout value for grid renderer item.
- `GridRendererEmpty: int = 2` — named behavior/layout value for grid renderer empty.
- `GridRendererHidden: int = 3` — named behavior/layout value for grid renderer hidden.
- `GridRendererHighlight: int = 4` — named behavior/layout value for grid renderer highlight.
- `GridRendererReady: int = 29900000` — named behavior/layout value for grid renderer ready.
- `TargetWeapon: int = 100` — numeric UI/action target identifier for target weapon.
- `TargetClothesBase: int = 100` — encoding stride/base used by target clothes base.
- `TargetFeet: int = 101` — numeric UI/action target identifier for target feet.
- `TargetHead: int = 102` — numeric UI/action target identifier for target head.
- `TargetBody: int = 103` — numeric UI/action target identifier for target body.
- `TargetHands: int = 104` — numeric UI/action target identifier for target hands.
- `TargetDrop: int = 200` — numeric UI/action target identifier for target drop.
- `TargetMoney: int = 300` — numeric UI/action target identifier for target money.
- `TargetPaging: int = 400` — numeric UI/action target identifier for target paging.
- `TargetQuickslotHelp: int = 401` — numeric UI/action target identifier for target quickslot help.
- `QuickslotHelpHover: int = 29800001` — named behavior/layout value for quickslot help hover.
- `PageHoverEnter: int = -110` — named behavior/layout value for page hover enter.
- `PageHoverLeave: int = -111` — named behavior/layout value for page hover leave.

## Architectural notes

- Message ranges and target IDs are a manually coordinated ABI shared with maintasks, widgets, XML form names, and some native code. Changing a value requires a repository-wide caller check.
