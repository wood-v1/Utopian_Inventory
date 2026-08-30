# Container Drag Controller

## Source

`scripts/loot/inv_overhaul_container_drag_controller.lua`

DSL unit: `module inv_overhaul_container_drag_controller`

## Responsibility

Resolves pointer targets and coordinates completion of container-screen drag actions.

## Dependencies

- `inv_overhaul_container_drag` — Owns container-screen drag state, source identity, target highlighting, and drag cancellation/commit bookkeeping.
- `inv_overhaul_container_player_actions` — Implements player-side equip, unequip, use, and drop actions initiated from the loot screen.
- `inv_overhaul_container_presenter` — Projects session state into loot UI forms, including incremental item metadata/texture loading, money, organs, and page controls.
- `inv_overhaul_container_projection` — Builds and queries the visible container/corpse item projection independently of the player backpack projection.
- `inv_overhaul_container_protocol` — Defines the loot screen's numeric messages, target identifiers, and sender-name mappings.
- `inv_overhaul_container_tooltip_controller` — Resolves loot-screen pointer targets into item, money, organ, and help tooltips.
- `inv_overhaul_container_transfer_external` — Adapts shared transfer operations for items moving from the external container into the player backpack.
- `inv_overhaul_container_transfer_player` — Adapts shared transfer operations for items moving from the player backpack into the external container.
- `inv_overhaul_container_view` — Defines loot-screen window names and emits UI messages that render slots, organs, drag state, and page controls.
- `inv_overhaul_inventory_tooltip` — Owns shared tooltip text, money pseudo-item metadata, suspension, and show/hide messaging.
- `inv_overhaul_inventory_items` — Builds the canonical projection of unequipped player items into backpack ordinals and cached category/index references.
- Pathologic native API — engine state, object access, persistence variables, UI messaging, timing, or rendering as listed per function.

## Used by

- `scripts/loot/inv_overhaul_container.lua`
- `scripts/loot/inv_overhaul_container_input_controller.lua`
- `scripts/loot/inv_overhaul_container_paging_controller.lua`

## State

No module/task-level mutable state.

## Public API

All functions below are compiler-visible when the module is imported; the DSL has no private declaration.

### `LootDragControllerGetTargetBySender(sender: string) -> int`

Source: `scripts/loot/inv_overhaul_container_drag_controller.lua`

Purpose: Returns target by sender for loot drag controller in the container drag controller subsystem.

Parameters:

- `sender: string` — name of the UI form that emitted the message.

Returns:

- `number` (integer) — result of: returns target by sender for loot drag controller in the container drag controller subsystem.

Side effects:

- Delegates to compiler-visible module APIs and inherits their documented side effects.

Called by:

- `scripts/loot/inv_overhaul_container_input_controller.lua :: LootInputHandleDragLifecycleMessage`
- `scripts/loot/inv_overhaul_container_input_controller.lua :: LootInputHandleRegularSlotMessage`

Calls:

- `inv_overhaul_container_presenter.LootPresenterGetVisibleSlots`
- `inv_overhaul_container_protocol.LootProtocolGetTargetBySender`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `LootDragControllerFindTargetAt(x: int, y: int) -> int`

Source: `scripts/loot/inv_overhaul_container_drag_controller.lua`

Purpose: Finds target at for loot drag controller in the container drag controller subsystem.

Parameters:

- `x: int` — pointer/layout coordinate interpreted by this function.
- `y: int` — pointer/layout coordinate interpreted by this function.

Returns:

- `number` (integer) — result of: finds target at for loot drag controller in the container drag controller subsystem.

Side effects:

- Delegates to compiler-visible module APIs and inherits their documented side effects.

Called by:

- `scripts/loot/inv_overhaul_container.lua :: OnMouseMove`
- `scripts/loot/inv_overhaul_container.lua :: OnLButtonUp`
- `scripts/loot/inv_overhaul_container_input_controller.lua :: LootInputStartPanelPointerDrag`
- `scripts/loot/inv_overhaul_container_input_controller.lua :: LootInputHandlePanelPointer`

Calls:

- `inv_overhaul_container_presenter.GetWindowWidth`
- `inv_overhaul_container_presenter.LootPresenterGetVisibleSlots`
- `inv_overhaul_container_presenter.LootPresenterShowsOrgans`
- `inv_overhaul_container_protocol.LootProtocolFindTargetAt`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `LootDragControllerIsTargetCompatible(target: int) -> bool`

Source: `scripts/loot/inv_overhaul_container_drag_controller.lua`

Purpose: Returns whether target compatible for loot drag controller in the container drag controller subsystem.

Parameters:

- `target: int` — value interpreted according to the function purpose; no narrower contract is established by current code.

Returns:

- `boolean` — result of: returns whether target compatible for loot drag controller in the container drag controller subsystem.

Side effects:

- Delegates to compiler-visible module APIs and inherits their documented side effects.

Called by:

- `scripts/loot/inv_overhaul_container_drag_controller.lua :: LootDragControllerSetHighlightedTarget`
- `scripts/loot/inv_overhaul_container_drag_controller.lua :: LootDragControllerApplyPointerTarget`
- `scripts/loot/inv_overhaul_container_drag_controller.lua :: Finish`

Calls:

- `inv_overhaul_container_drag.GetKind`
- `inv_overhaul_container_presenter.LootPresenterGetVisibleSlots`
- `inv_overhaul_container_protocol.LootProtocolIsTargetCompatible`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `ResolveSource(source: int) -> bool`

Source: `scripts/loot/inv_overhaul_container_drag_controller.lua`

Purpose: Resolves source in the container drag controller subsystem.

Parameters:

- `source: int` — value interpreted according to the function purpose; no narrower contract is established by current code.

Returns:

- `boolean` — result of: resolves source in the container drag controller subsystem.

Side effects:

- Delegates to compiler-visible module APIs and inherits their documented side effects.

Called by:

- `scripts/loot/inv_overhaul_container_drag_controller.lua :: BeginCursor`

Calls:

- `inv_overhaul_container_presenter.LootPresenterGetVisibleSlots`
- `inv_overhaul_container_protocol.IsPlayerTarget`
- `inv_overhaul_container_presenter.LootPresenterResolveVisibleSlot`
- `inv_overhaul_inventory_items.DecodeReferenceCategory`
- `inv_overhaul_inventory_items.DecodeReferenceIndex`
- `inv_overhaul_container_presenter.LootPresenterGetVisibleCell`
- `inv_overhaul_inventory_items.ItemsGetPlayerContainer`
- `player.GetItem`
- `inv_overhaul_container_protocol.IsContainerTarget`
- `inv_overhaul_container_protocol.GetContainerSlot`
- `inv_overhaul_container_presenter.ResolveContainerVisualSlot`
- `inv_overhaul_container_presenter.GetContainerPage`
- `… and 10 more`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `BeginCursor(source: int) -> bool`

Source: `scripts/loot/inv_overhaul_container_drag_controller.lua`

Purpose: Begins cursor in the container drag controller subsystem.

Parameters:

- `source: int` — value interpreted according to the function purpose; no narrower contract is established by current code.

Returns:

- `boolean` — result of: begins cursor in the container drag controller subsystem.

Side effects:

- Writes shared engine variable(s): `"inv_overhaul_inventory_drag_item"`.
- Invokes engine/native operations: `native.SetVariable`.

Called by:

- `scripts/loot/inv_overhaul_container_drag_controller.lua :: Start`

Calls:

- `native.SetVariable`
- `ResolveSource`
- `inv_overhaul_container_drag.LootDragGetItemID`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `EndCursor() -> void`

Source: `scripts/loot/inv_overhaul_container_drag_controller.lua`

Purpose: Ends cursor in the container drag controller subsystem.

Parameters:

None.

Returns:

None.

Side effects:

- Writes shared engine variable(s): `"inv_overhaul_inventory_drag_item"`, `"inv_overhaul_inventory_page_hover"`.
- Invokes engine/native operations: `native.SetVariable`.

Called by:

- `scripts/loot/inv_overhaul_container_drag_controller.lua :: Finish`

Calls:

- `native.SetVariable`
- `inv_overhaul_container_drag.ClearSource`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `LootDragControllerSetHighlightedTarget(target: int) -> void`

Source: `scripts/loot/inv_overhaul_container_drag_controller.lua`

Purpose: Sets highlighted target for loot drag controller in the container drag controller subsystem.

Parameters:

- `target: int` — value interpreted according to the function purpose; no narrower contract is established by current code.

Returns:

None.

Side effects:

- Delegates to compiler-visible module APIs and inherits their documented side effects.

Called by:

- `scripts/loot/inv_overhaul_container.lua :: OnMouseLeave`
- `scripts/loot/inv_overhaul_container_drag_controller.lua :: LootDragControllerApplyPointerTarget`
- `scripts/loot/inv_overhaul_container_drag_controller.lua :: Start`
- `scripts/loot/inv_overhaul_container_drag_controller.lua :: Finish`
- `scripts/loot/inv_overhaul_container_input_controller.lua :: HandleSlotPointerMessage`
- `scripts/loot/inv_overhaul_container_input_controller.lua :: LootInputHandleDragLifecycleMessage`
- `scripts/loot/inv_overhaul_container_paging_controller.lua :: UpdateDragHover`

Calls:

- `inv_overhaul_container_drag.LootDragIsActive`
- `LootDragControllerIsTargetCompatible`
- `inv_overhaul_container_drag.LootDragGetHighlightedTarget`
- `inv_overhaul_container_presenter.LootPresenterGetVisibleSlots`
- `inv_overhaul_container_view.SetTargetHighlighted`
- `inv_overhaul_container_drag.LootDragSetHighlightedTarget`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `LootDragControllerApplyPointerTarget(target: int) -> void`

Source: `scripts/loot/inv_overhaul_container_drag_controller.lua`

Purpose: Applies pointer target for loot drag controller in the container drag controller subsystem.

Parameters:

- `target: int` — value interpreted according to the function purpose; no narrower contract is established by current code.

Returns:

None.

Side effects:

- Delegates to compiler-visible module APIs and inherits their documented side effects.

Called by:

- `scripts/loot/inv_overhaul_container.lua :: OnMouseMove`
- `scripts/loot/inv_overhaul_container.lua :: OnLButtonUp`
- `scripts/loot/inv_overhaul_container_input_controller.lua :: LootInputHandlePanelPointer`
- `scripts/loot/inv_overhaul_container_input_controller.lua :: HandleSlotPointerMessage`
- `scripts/loot/inv_overhaul_container_input_controller.lua :: LootInputHandleDragLifecycleMessage`

Calls:

- `inv_overhaul_container_drag.LootDragIsActive`
- `inv_overhaul_container_drag.GetSource`
- `inv_overhaul_container_drag.GetKind`
- `inv_overhaul_container_presenter.LootPresenterGetVisibleSlots`
- `inv_overhaul_container_protocol.IsPlayerTarget`
- `inv_overhaul_container_presenter.LootPresenterGetVisibleCell`
- `inv_overhaul_container_drag.GetPlayerCell`
- `inv_overhaul_container_protocol.IsContainerTarget`
- `inv_overhaul_container_presenter.GetContainerPage`
- `inv_overhaul_container_protocol.GetContainerSlot`
- `inv_overhaul_container_drag.GetContainerVisual`
- `LootDragControllerIsTargetCompatible`
- `… and 2 more`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `CancelPageHover(action: int) -> void`

Source: `scripts/loot/inv_overhaul_container_drag_controller.lua`

Purpose: Cancels page hover in the container drag controller subsystem.

Parameters:

- `action: int` — value interpreted according to the function purpose; no narrower contract is established by current code.

Returns:

None.

Side effects:

- Invokes engine/native operations: `native.Trace`.

Called by:

- `scripts/loot/inv_overhaul_container_drag_controller.lua :: Start`
- `scripts/loot/inv_overhaul_container_drag_controller.lua :: Finish`
- `scripts/loot/inv_overhaul_container_input_controller.lua :: HandleLifecycleMessage`
- `scripts/loot/inv_overhaul_container_paging_controller.lua :: UpdateDragHover`
- `scripts/loot/inv_overhaul_container_paging_controller.lua :: SyncDragHoverFromCursor`

Calls:

- `inv_overhaul_container_drag.LootDragCanCancelPageHover`
- `inv_overhaul_container_drag.LootDragGetPageHoverAction`
- `native.Trace`
- `inv_overhaul_container_drag.LootDragGetPageHoverElapsed`
- `inv_overhaul_container_drag.LootDragClearPageHover`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `Start(source: int) -> void`

Source: `scripts/loot/inv_overhaul_container_drag_controller.lua`

Purpose: Starts container drag controller in the container drag controller subsystem.

Parameters:

- `source: int` — value interpreted according to the function purpose; no narrower contract is established by current code.

Returns:

None.

Side effects:

- Delegates to compiler-visible module APIs and inherits their documented side effects.

Called by:

- `scripts/loot/inv_overhaul_container_input_controller.lua :: LootInputStartPanelPointerDrag`
- `scripts/loot/inv_overhaul_container_input_controller.lua :: LootInputHandleDragLifecycleMessage`

Calls:

- `inv_overhaul_container_drag.LootDragIsActive`
- `CancelPageHover`
- `inv_overhaul_container_tooltip_controller.LootTooltipClear`
- `BeginCursor`
- `LootDragControllerSetHighlightedTarget`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `Finish(target: int) -> void`

Source: `scripts/loot/inv_overhaul_container_drag_controller.lua`

Purpose: Completes container drag controller in the container drag controller subsystem.

Parameters:

- `target: int` — value interpreted according to the function purpose; no narrower contract is established by current code.

Returns:

None.

Side effects:

- Invokes engine/native operations: `native.SendMessage`.

Called by:

- `scripts/loot/inv_overhaul_container.lua :: OnLButtonUp`
- `scripts/loot/inv_overhaul_container_input_controller.lua :: LootInputHandlePanelPointer`
- `scripts/loot/inv_overhaul_container_input_controller.lua :: HandleSlotPointerMessage`
- `scripts/loot/inv_overhaul_container_input_controller.lua :: LootInputHandleDragLifecycleMessage`

Calls:

- `inv_overhaul_container_drag.LootDragIsActive`
- `inv_overhaul_container_drag.LootDragResolveReleaseTarget`
- `inv_overhaul_container_drag.GetSource`
- `inv_overhaul_container_drag.GetKind`
- `inv_overhaul_container_drag.GetPlayerCell`
- `inv_overhaul_container_drag.GetContainerVisual`
- `inv_overhaul_container_presenter.LootPresenterGetVisibleSlots`
- `inv_overhaul_inventory_tooltip.Suspend`
- `inv_overhaul_container_tooltip_controller.LootTooltipClear`
- `native.SendMessage`
- `inv_overhaul_container_view.LootViewGetTargetWndName`
- `LootDragControllerIsTargetCompatible`
- `… and 14 more`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.


## Internal API

No additional maintask helpers.

## Events / callbacks

No engine callbacks; this is an imported module.

## Important constants

- `ContainerSlots: int = 12` — named behavior/layout value for container slots.

## Architectural notes

- No additional module-specific issue identified beyond repository-wide shared-variable and compiler-visible API constraints.
