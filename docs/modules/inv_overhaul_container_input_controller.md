# Container Input Controller

## Source

`scripts/loot/inv_overhaul_container_input_controller.lua`

DSL unit: `module inv_overhaul_container_input_controller`

## Responsibility

Routes loot-screen UI messages, keyboard input, and contextual actions to the appropriate domain controller.

## Dependencies

- `inv_overhaul_inventory_layout_runtime` — Owns the mutable saved cell-to-item order, normalization, exact insertion/removal, swapping, and incremental persistence.
- `inv_overhaul_inventory_snapshot` — Captures item-identity snapshots and reconciles saved layout cells after game inventory order changes or equipment mutations.
- `inv_overhaul_container_drag` — Owns container-screen drag state, source identity, target highlighting, and drag cancellation/commit bookkeeping.
- `inv_overhaul_container_drag_controller` — Resolves pointer targets and coordinates completion of container-screen drag actions.
- `inv_overhaul_container_geometry` — Maps supported layouts to player, container, organ, money, paging, and pointer hit-test geometry.
- `inv_overhaul_container_paging_controller` — Owns player/container page changes and drag-hover page switching on the loot screen.
- `inv_overhaul_container_player_actions` — Implements player-side equip, unequip, use, and drop actions initiated from the loot screen.
- `inv_overhaul_container_presenter` — Projects session state into loot UI forms, including incremental item metadata/texture loading, money, organs, and page controls.
- `inv_overhaul_container_projection` — Builds and queries the visible container/corpse item projection independently of the player backpack projection.
- `inv_overhaul_container_protocol` — Defines the loot screen's numeric messages, target identifiers, and sender-name mappings.
- `inv_overhaul_container_quick_transfer` — Chooses and executes the appropriate contextual quick-transfer direction for a clicked loot-screen slot.
- `inv_overhaul_container_session` — Owns the active external container object, container/corpse kind, generation tracking, and close lifecycle.
- `inv_overhaul_container_tooltip_controller` — Resolves loot-screen pointer targets into item, money, organ, and help tooltips.
- `inv_overhaul_container_view` — Defines loot-screen window names and emits UI messages that render slots, organs, drag state, and page controls.
- `inv_overhaul_inventory_tooltip` — Owns shared tooltip text, money pseudo-item metadata, suspension, and show/hide messaging.
- `inv_overhaul_inventory_items` — Builds the canonical projection of unequipped player items into backpack ordinals and cached category/index references.
- `inv_overhaul_inventory_quickslot_bindings` — Owns saved quickslot item/category/occurrence bindings and the player-screen binding cache.
- Pathologic native API — engine state, object access, persistence variables, UI messaging, timing, or rendering as listed per function.

## Used by

- `scripts/loot/inv_overhaul_container.lua`

## State

- `shiftHeld: bool` — lifecycle/behavior flag for shift held.
- `controlHeld: bool` — lifecycle/behavior flag for control held.

## Public API

All functions below are compiler-visible when the module is imported; the DSL has no private declaration.

### `LootInputInitializeState() -> void`

Source: `scripts/loot/inv_overhaul_container_input_controller.lua`

Purpose: Initializes state for loot input in the container input controller subsystem.

Parameters:

None.

Returns:

None.

Side effects:

- Mutates module/task state: `shiftHeld`, `controlHeld`.

Called by:

- `scripts/loot/inv_overhaul_container.lua :: init`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `LootInputAssignHoveredQuickslot(slot: int) -> void`

Source: `scripts/loot/inv_overhaul_container_input_controller.lua`

Purpose: Assigns hovered quickslot for loot input in the container input controller subsystem.

Parameters:

- `slot: int` — slot index or encoded slot target interpreted by this function.

Returns:

None.

Side effects:

- Delegates to compiler-visible module APIs and inherits their documented side effects.

Called by:

- `scripts/loot/inv_overhaul_container_input_controller.lua :: HandleKeyDown`

Calls:

- `inv_overhaul_container_drag.LootDragIsActive`
- `inv_overhaul_container_drag.LootDragGetHighlightedTarget`
- `inv_overhaul_inventory_tooltip.GetTarget`
- `inv_overhaul_container_presenter.LootPresenterGetVisibleSlots`
- `inv_overhaul_container_presenter.LootPresenterResolveVisibleSlot`
- `inv_overhaul_inventory_items.DecodeReferenceCategory`
- `inv_overhaul_inventory_items.DecodeReferenceIndex`
- `inv_overhaul_inventory_quickslot_bindings.Assign`
- `inv_overhaul_container_presenter.UpdatePlayerSlots`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `LootInputHandleModifiedDrop(source: int) -> bool`

Source: `scripts/loot/inv_overhaul_container_input_controller.lua`

Purpose: Handles modified drop for loot input in the container input controller subsystem.

Parameters:

- `source: int` — value interpreted according to the function purpose; no narrower contract is established by current code.

Returns:

- `boolean` — result of: handles modified drop for loot input in the container input controller subsystem.

Side effects:

- Delegates to compiler-visible module APIs and inherits their documented side effects.

Called by:

- `scripts/loot/inv_overhaul_container_input_controller.lua :: LootInputStartPanelPointerDrag`
- `scripts/loot/inv_overhaul_container_input_controller.lua :: LootInputHandleDragLifecycleMessage`

Calls:

- `inv_overhaul_container_presenter.LootPresenterGetVisibleSlots`
- `inv_overhaul_container_presenter.LootPresenterResolveVisibleSlot`
- `inv_overhaul_container_player_actions.LootPlayerActionsMoveSlotToOtherPage`
- `inv_overhaul_inventory_items.ItemsGetPlayerContainer`
- `inv_overhaul_inventory_items.DecodeReferenceCategory`
- `inv_overhaul_inventory_items.DecodeReferenceIndex`
- `player.GetItemAmount`
- `inv_overhaul_container_player_actions.DropToWorld`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `LootInputStartPanelPointerDrag(x: int, y: int) -> void`

Source: `scripts/loot/inv_overhaul_container_input_controller.lua`

Purpose: Starts panel pointer drag for loot input in the container input controller subsystem.

Parameters:

- `x: int` — pointer/layout coordinate interpreted by this function.
- `y: int` — pointer/layout coordinate interpreted by this function.

Returns:

None.

Side effects:

- Delegates to compiler-visible module APIs and inherits their documented side effects.

Called by:

- `scripts/loot/inv_overhaul_container_input_controller.lua :: LootInputHandlePanelPointer`

Calls:

- `inv_overhaul_container_drag_controller.LootDragControllerFindTargetAt`
- `LootInputHandleModifiedDrop`
- `inv_overhaul_container_drag_controller.Start`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `LootInputHandlePanelPointer(message: int) -> void`

Source: `scripts/loot/inv_overhaul_container_input_controller.lua`

Purpose: Handles panel pointer for loot input in the container input controller subsystem.

Parameters:

- `message: int` — numeric engine/UI protocol message.

Returns:

None.

Side effects:

- Delegates to compiler-visible module APIs and inherits their documented side effects.

Called by:

- `scripts/loot/inv_overhaul_container_input_controller.lua :: HandleUIMessage`

Calls:

- `inv_overhaul_container_protocol.GetPanelPointerAction`
- `inv_overhaul_container_tooltip_controller.LootTooltipClear`
- `inv_overhaul_container_view.ClearPageControlHover`
- `inv_overhaul_container_protocol.GetPanelPointerBase`
- `inv_overhaul_container_geometry.LootGeometryDecodePanelPointerX`
- `inv_overhaul_container_geometry.LootGeometryDecodePanelPointerY`
- `inv_overhaul_container_paging_controller.UpdateControlHover`
- `inv_overhaul_container_presenter.GetWindowWidth`
- `inv_overhaul_container_presenter.LootPresenterGetVisibleSlots`
- `inv_overhaul_container_presenter.GetPlayerPage`
- `inv_overhaul_container_presenter.GetContainerPage`
- `inv_overhaul_container_presenter.LootPresenterShowsOrgans`
- `… and 9 more`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `HandleLifecycleMessage(message: int, sender: string) -> bool`

Source: `scripts/loot/inv_overhaul_container_input_controller.lua`

Purpose: Handles lifecycle message in the container input controller subsystem.

Parameters:

- `message: int` — numeric engine/UI protocol message.
- `sender: string` — name of the UI form that emitted the message.

Returns:

- `boolean` — result of: handles lifecycle message in the container input controller subsystem.

Side effects:

- Invokes engine/native operations: `native.SendMessage`.

Called by:

- `scripts/loot/inv_overhaul_container_input_controller.lua :: HandleUIMessage`

Calls:

- `inv_overhaul_container_tooltip_controller.ShowQuickslotHelp`
- `native.SendMessage`
- `inv_overhaul_container_paging_controller.BeginDragHover`
- `inv_overhaul_container_paging_controller.GetDragHoverAction`
- `inv_overhaul_container_drag_controller.CancelPageHover`
- `inv_overhaul_container_session.ActivateCorpseMode`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `HandlePagingMessage(message: int, sender: string) -> bool`

Source: `scripts/loot/inv_overhaul_container_input_controller.lua`

Purpose: Handles paging message in the container input controller subsystem.

Parameters:

- `message: int` — numeric engine/UI protocol message.
- `sender: string` — name of the UI form that emitted the message.

Returns:

- `boolean` — result of: handles paging message in the container input controller subsystem.

Side effects:

- Delegates to compiler-visible module APIs and inherits their documented side effects.

Called by:

- `scripts/loot/inv_overhaul_container_input_controller.lua :: HandleUIMessage`

Calls:

- `inv_overhaul_container_presenter.GetPlayerPage`
- `inv_overhaul_container_presenter.ChangePlayerPage`
- `inv_overhaul_container_presenter.GetMaxPlayerPage`
- `inv_overhaul_container_presenter.GetContainerPage`
- `inv_overhaul_container_presenter.ChangeContainerPage`
- `inv_overhaul_container_projection.LootProjectionGetMaxPage`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `GetSlotPointerTarget(message: int, base: int, sender: string) -> int`

Source: `scripts/loot/inv_overhaul_container_input_controller.lua`

Purpose: Returns slot pointer target in the container input controller subsystem.

Parameters:

- `message: int` — numeric engine/UI protocol message.
- `base: int` — value interpreted according to the function purpose; no narrower contract is established by current code.
- `sender: string` — name of the UI form that emitted the message.

Returns:

- `number` (integer) — result of: returns slot pointer target in the container input controller subsystem.

Side effects:

- Delegates to compiler-visible module APIs and inherits their documented side effects.

Called by:

- `scripts/loot/inv_overhaul_container_input_controller.lua :: HandleSlotPointerMessage`

Calls:

- `inv_overhaul_container_presenter.LootPresenterGetVisibleSlots`
- `inv_overhaul_container_presenter.GetWindowWidth`
- `inv_overhaul_container_protocol.LootProtocolGetSlotTargetFromPointerMessage`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `HandleSlotPointerMessage(message: int, sender: string) -> bool`

Source: `scripts/loot/inv_overhaul_container_input_controller.lua`

Purpose: Handles slot pointer message in the container input controller subsystem.

Parameters:

- `message: int` — numeric engine/UI protocol message.
- `sender: string` — name of the UI form that emitted the message.

Returns:

- `boolean` — result of: handles slot pointer message in the container input controller subsystem.

Side effects:

- Delegates to compiler-visible module APIs and inherits their documented side effects.

Called by:

- `scripts/loot/inv_overhaul_container_input_controller.lua :: HandleUIMessage`

Calls:

- `inv_overhaul_container_protocol.GetSlotPointerAction`
- `inv_overhaul_container_protocol.GetSlotPointerBase`
- `GetSlotPointerTarget`
- `inv_overhaul_container_drag_controller.LootDragControllerApplyPointerTarget`
- `inv_overhaul_container_drag_controller.Finish`
- `inv_overhaul_container_drag.LootDragIsActive`
- `inv_overhaul_container_drag_controller.LootDragControllerSetHighlightedTarget`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `LootInputHandleDragLifecycleMessage(message: int, sender: string) -> bool`

Source: `scripts/loot/inv_overhaul_container_input_controller.lua`

Purpose: Handles drag lifecycle message for loot input in the container input controller subsystem.

Parameters:

- `message: int` — numeric engine/UI protocol message.
- `sender: string` — name of the UI form that emitted the message.

Returns:

- `boolean` — result of: handles drag lifecycle message for loot input in the container input controller subsystem.

Side effects:

- Delegates to compiler-visible module APIs and inherits their documented side effects.

Called by:

- `scripts/loot/inv_overhaul_container_input_controller.lua :: HandleUIMessage`

Calls:

- `inv_overhaul_container_drag_controller.LootDragControllerGetTargetBySender`
- `LootInputHandleModifiedDrop`
- `inv_overhaul_container_drag_controller.Start`
- `inv_overhaul_container_drag.LootDragIsActive`
- `inv_overhaul_container_drag_controller.LootDragControllerApplyPointerTarget`
- `inv_overhaul_container_drag_controller.LootDragControllerSetHighlightedTarget`
- `inv_overhaul_container_drag.LootDragGetHighlightedTarget`
- `inv_overhaul_container_drag_controller.Finish`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `LootInputHandleRegularSlotMessage(message: int, sender: string, data: object) -> bool`

Source: `scripts/loot/inv_overhaul_container_input_controller.lua`

Purpose: Handles regular slot message for loot input in the container input controller subsystem.

Parameters:

- `message: int` — numeric engine/UI protocol message.
- `sender: string` — name of the UI form that emitted the message.
- `data: object` — engine callback/UI payload object; shape depends on the message.

Returns:

- `boolean` — result of: handles regular slot message for loot input in the container input controller subsystem.

Side effects:

- Delegates to compiler-visible module APIs and inherits their documented side effects.

Called by:

- `scripts/loot/inv_overhaul_container_input_controller.lua :: HandleUIMessage`

Calls:

- `inv_overhaul_container_drag_controller.LootDragControllerGetTargetBySender`
- `inv_overhaul_container_quick_transfer.Execute`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `HandleUIMessage(message: int, sender: string, data: object) -> void`

Source: `scripts/loot/inv_overhaul_container_input_controller.lua`

Purpose: Handles ui message in the container input controller subsystem.

Parameters:

- `message: int` — numeric engine/UI protocol message.
- `sender: string` — name of the UI form that emitted the message.
- `data: object` — engine callback/UI payload object; shape depends on the message.

Returns:

None.

Side effects:

- Delegates to compiler-visible module APIs and inherits their documented side effects.

Called by:

- `scripts/loot/inv_overhaul_container.lua :: OnUIMessage`

Calls:

- `HandleLifecycleMessage`
- `inv_overhaul_container_protocol.IsPanelPointerMessage`
- `LootInputHandlePanelPointer`
- `HandlePagingMessage`
- `HandleSlotPointerMessage`
- `LootInputHandleDragLifecycleMessage`
- `LootInputHandleRegularSlotMessage`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `PersistAndClose() -> void`

Source: `scripts/loot/inv_overhaul_container_input_controller.lua`

Purpose: Persists and close in the container input controller subsystem.

Parameters:

None.

Returns:

None.

Side effects:

- Delegates to compiler-visible module APIs and inherits their documented side effects.

Called by:

- `scripts/loot/inv_overhaul_container_input_controller.lua :: HandleChar`
- `scripts/loot/inv_overhaul_container_input_controller.lua :: HandleKeyDown`

Calls:

- `inv_overhaul_inventory_layout_runtime.HasQueuedSave`
- `inv_overhaul_inventory_layout_runtime.SaveAll`
- `inv_overhaul_inventory_snapshot.PersistCurrent`
- `inv_overhaul_container_session.CloseWindow`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `HandleChar(char: int) -> void`

Source: `scripts/loot/inv_overhaul_container_input_controller.lua`

Purpose: Handles char in the container input controller subsystem.

Parameters:

- `char: int` — value interpreted according to the function purpose; no narrower contract is established by current code.

Returns:

None.

Side effects:

- None directly observable beyond calls listed below.

Called by:

- `scripts/loot/inv_overhaul_container.lua :: OnChar`

Calls:

- `PersistAndClose`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `HandleKeyDown(key: int) -> void`

Source: `scripts/loot/inv_overhaul_container_input_controller.lua`

Purpose: Handles key down in the container input controller subsystem.

Parameters:

- `key: int` — value interpreted according to the function purpose; no narrower contract is established by current code.

Returns:

None.

Side effects:

- Mutates module/task state: `shiftHeld`, `controlHeld`.

Called by:

- `scripts/loot/inv_overhaul_container.lua :: OnKeyDown`

Calls:

- `inv_overhaul_inventory_quickslot_bindings.GetSlotByKey`
- `LootInputAssignHoveredQuickslot`
- `PersistAndClose`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `HandleKeyUp(key: int) -> void`

Source: `scripts/loot/inv_overhaul_container_input_controller.lua`

Purpose: Handles key up in the container input controller subsystem.

Parameters:

- `key: int` — value interpreted according to the function purpose; no narrower contract is established by current code.

Returns:

None.

Side effects:

- Mutates module/task state: `shiftHeld`, `controlHeld`.

Called by:

- `scripts/loot/inv_overhaul_container.lua :: OnKeyUp`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.


## Internal API

No additional maintask helpers.

## Events / callbacks

No engine callbacks; this is an imported module.

## Important constants

- `VKShift: int = 16` — named behavior/layout value for vkshift.
- `VKControl: int = 17` — named behavior/layout value for vkcontrol.

## Architectural notes

- No additional module-specific issue identified beyond repository-wide shared-variable and compiler-visible API constraints.
