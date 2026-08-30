# Container Paging Controller

## Source

`scripts/loot/inv_overhaul_container_paging_controller.lua`

DSL unit: `module inv_overhaul_container_paging_controller`

## Responsibility

Owns player/container page changes and drag-hover page switching on the loot screen.

## Dependencies

- `inv_overhaul_container_drag` — Owns container-screen drag state, source identity, target highlighting, and drag cancellation/commit bookkeeping.
- `inv_overhaul_container_drag_controller` — Resolves pointer targets and coordinates completion of container-screen drag actions.
- `inv_overhaul_container_geometry` — Maps supported layouts to player, container, organ, money, paging, and pointer hit-test geometry.
- `inv_overhaul_container_presenter` — Projects session state into loot UI forms, including incremental item metadata/texture loading, money, organs, and page controls.
- `inv_overhaul_container_projection` — Builds and queries the visible container/corpse item projection independently of the player backpack projection.
- `inv_overhaul_container_view` — Defines loot-screen window names and emits UI messages that render slots, organs, drag state, and page controls.
- Pathologic native API — engine state, object access, persistence variables, UI messaging, timing, or rendering as listed per function.

## Used by

- `scripts/loot/inv_overhaul_container.lua`
- `scripts/loot/inv_overhaul_container_input_controller.lua`

## State

No module/task-level mutable state.

## Public API

All functions below are compiler-visible when the module is imported; the DSL has no private declaration.

### `HandleControlAt(x: int, y: int) -> bool`

Source: `scripts/loot/inv_overhaul_container_paging_controller.lua`

Purpose: Handles control at in the container paging controller subsystem.

Parameters:

- `x: int` — pointer/layout coordinate interpreted by this function.
- `y: int` — pointer/layout coordinate interpreted by this function.

Returns:

- `boolean` — result of: handles control at in the container paging controller subsystem.

Side effects:

- Delegates to compiler-visible module APIs and inherits their documented side effects.

Called by:

- `scripts/loot/inv_overhaul_container_input_controller.lua :: LootInputHandlePanelPointer`

Calls:

- `inv_overhaul_container_presenter.GetWindowWidth`
- `inv_overhaul_container_presenter.GetPlayerPage`
- `inv_overhaul_container_presenter.GetMaxPlayerPage`
- `inv_overhaul_container_geometry.GetPageControlAction`
- `inv_overhaul_container_geometry.GetPlayerPageControlX`
- `inv_overhaul_container_geometry.GetPlayerPageControlY`
- `inv_overhaul_container_presenter.ChangePlayerPage`
- `inv_overhaul_container_projection.LootProjectionGetMaxPage`
- `inv_overhaul_container_geometry.GetContainerPageControlX`
- `inv_overhaul_container_geometry.GetContainerPageControlY`
- `inv_overhaul_container_presenter.GetContainerPage`
- `inv_overhaul_container_presenter.ChangeContainerPage`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `UpdateControlHover(x: int, y: int) -> void`

Source: `scripts/loot/inv_overhaul_container_paging_controller.lua`

Purpose: Updates control hover in the container paging controller subsystem.

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

- `inv_overhaul_container_presenter.GetWindowWidth`
- `inv_overhaul_container_geometry.GetPlayerPageControlX`
- `inv_overhaul_container_geometry.GetPlayerPageControlY`
- `inv_overhaul_container_presenter.GetPlayerPage`
- `inv_overhaul_container_presenter.GetMaxPlayerPage`
- `inv_overhaul_container_view.SetPageButtonHover`
- `inv_overhaul_container_geometry.IsPageButtonHovered`
- `inv_overhaul_container_geometry.GetContainerPageControlX`
- `inv_overhaul_container_geometry.GetContainerPageControlY`
- `inv_overhaul_container_presenter.GetContainerPage`
- `inv_overhaul_container_projection.LootProjectionGetMaxPage`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `GetDragHoverAction(sender: string) -> int`

Source: `scripts/loot/inv_overhaul_container_paging_controller.lua`

Purpose: Returns drag hover action in the container paging controller subsystem.

Parameters:

- `sender: string` — name of the UI form that emitted the message.

Returns:

- `number` (integer) — result of: returns drag hover action in the container paging controller subsystem.

Side effects:

- Delegates to compiler-visible module APIs and inherits their documented side effects.

Called by:

- `scripts/loot/inv_overhaul_container_input_controller.lua :: HandleLifecycleMessage`
- `scripts/loot/inv_overhaul_container_paging_controller.lua :: BeginDragHover`

Calls:

- `inv_overhaul_container_presenter.GetPlayerPage`
- `inv_overhaul_container_presenter.GetContainerPage`
- `inv_overhaul_container_presenter.GetMaxPlayerPage`
- `inv_overhaul_container_projection.LootProjectionGetMaxPage`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `BeginDragHover(sender: string) -> void`

Source: `scripts/loot/inv_overhaul_container_paging_controller.lua`

Purpose: Begins drag hover in the container paging controller subsystem.

Parameters:

- `sender: string` — name of the UI form that emitted the message.

Returns:

None.

Side effects:

- Invokes engine/native operations: `native.Trace`.

Called by:

- `scripts/loot/inv_overhaul_container_input_controller.lua :: HandleLifecycleMessage`

Calls:

- `inv_overhaul_container_drag.LootDragIsActive`
- `GetDragHoverAction`
- `inv_overhaul_container_drag.LootDragBeginPageHover`
- `inv_overhaul_container_drag.GetSource`
- `native.Trace`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `UpdateDragHover(delta: float) -> void`

Source: `scripts/loot/inv_overhaul_container_paging_controller.lua`

Purpose: Updates drag hover in the container paging controller subsystem.

Parameters:

- `delta: float` — elapsed update time in seconds.

Returns:

None.

Side effects:

- Invokes engine/native operations: `native.Trace`.

Called by:

- `scripts/loot/inv_overhaul_container.lua :: OnUpdate`

Calls:

- `inv_overhaul_container_drag.LootDragIsActive`
- `inv_overhaul_container_drag.LootDragGetPageHoverAction`
- `inv_overhaul_container_presenter.GetPlayerPage`
- `inv_overhaul_container_presenter.GetContainerPage`
- `inv_overhaul_container_drag_controller.CancelPageHover`
- `inv_overhaul_container_presenter.GetMaxPlayerPage`
- `inv_overhaul_container_projection.LootProjectionGetMaxPage`
- `inv_overhaul_container_drag.LootDragAdvancePageHover`
- `inv_overhaul_container_drag_controller.LootDragControllerSetHighlightedTarget`
- `native.Trace`
- `inv_overhaul_container_presenter.ChangePlayerPage`
- `inv_overhaul_container_presenter.ChangeContainerPage`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `SyncDragHoverFromCursor() -> void`

Source: `scripts/loot/inv_overhaul_container_paging_controller.lua`

Purpose: Synchronizes drag hover from cursor in the container paging controller subsystem.

Parameters:

None.

Returns:

None.

Side effects:

- Invokes engine/native operations: `native.Trace`.

Called by:

- `scripts/loot/inv_overhaul_container.lua :: OnUpdate`

Calls:

- `inv_overhaul_container_drag.LootDragIsActive`
- `inv_overhaul_container_drag_controller.CancelPageHover`
- `native.GetVariable`
- `inv_overhaul_container_presenter.GetPlayerPage`
- `inv_overhaul_container_presenter.GetContainerPage`
- `inv_overhaul_container_presenter.GetMaxPlayerPage`
- `inv_overhaul_container_projection.LootProjectionGetMaxPage`
- `inv_overhaul_container_drag.LootDragBeginPageHover`
- `native.Trace`

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
