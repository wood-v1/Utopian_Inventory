# Container Drag

## Source

`scripts/loot/inv_overhaul_container_drag.lua`

DSL unit: `module inv_overhaul_container_drag`

## Responsibility

Owns container-screen drag state, source identity, target highlighting, and drag cancellation/commit bookkeeping.

## Dependencies

- No local DSL imports.

## Used by

- `scripts/loot/inv_overhaul_container.lua`
- `scripts/loot/inv_overhaul_container_drag_controller.lua`
- `scripts/loot/inv_overhaul_container_input_controller.lua`
- `scripts/loot/inv_overhaul_container_paging_controller.lua`
- `scripts/loot/inv_overhaul_container_tooltip_controller.lua`
- `scripts/loot/inv_overhaul_container_transfer_external.lua`
- `scripts/loot/inv_overhaul_container_transfer_player.lua`

## State

- `source: int` — mutable runtime state for source.
- `kind: int` — mutable runtime state for kind.
- `itemID: int` — mutable runtime state for item id.
- `playerCategory: int` — mutable runtime state for player category.
- `playerIndex: int` — mutable runtime state for player index.
- `playerCell: int` — mutable runtime state for player cell.
- `containerIndex: int` — mutable runtime state for container index.
- `containerOrdinal: int` — mutable runtime state for container ordinal.
- `containerVisual: int` — mutable runtime state for container visual.
- `highlightedTarget: int` — current interaction state for highlighted target.
- `lastValidTarget: int` — mutable runtime state for last valid target.
- `invalidTargetFrames: int` — mutable runtime state for invalid target frames.
- `pageHoverAction: int` — current or cached paging state for page hover action.
- `pageHoverElapsed: float` — current or cached paging state for page hover elapsed.
- `pageHoverConsumed: bool` — current or cached paging state for page hover consumed.

## Public API

All functions below are compiler-visible when the module is imported; the DSL has no private declaration.

### `LootDragInitializeState() -> void`

Source: `scripts/loot/inv_overhaul_container_drag.lua`

Purpose: Initializes state for loot drag in the container drag subsystem.

Parameters:

None.

Returns:

None.

Side effects:

- Mutates module/task state: `source`, `kind`, `itemID`, `playerCategory`, `playerIndex`, `playerCell`, `containerIndex`, `containerOrdinal`, `… and 7 more`.

Called by:

- `scripts/loot/inv_overhaul_container.lua :: init`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `BeginPlayerSource(newSource: int, newItemID: int, newCategory: int, newIndex: int, newCell: int) -> void`

Source: `scripts/loot/inv_overhaul_container_drag.lua`

Purpose: Begins player source in the container drag subsystem.

Parameters:

- `newSource: int` — value interpreted according to the function purpose; no narrower contract is established by current code.
- `newItemID: int` — engine item or callback identifier interpreted by this function.
- `newCategory: int` — zero-based engine inventory category identifier.
- `newIndex: int` — zero-based entry index in the relevant engine container/category.
- `newCell: int` — zero-based backpack layout cell.

Returns:

None.

Side effects:

- Mutates module/task state: `source`, `kind`, `itemID`, `playerCategory`, `playerIndex`, `playerCell`, `containerIndex`, `containerOrdinal`, `… and 3 more`.

Called by:

- `scripts/loot/inv_overhaul_container_drag_controller.lua :: ResolveSource`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `BeginExternalSource(newSource: int, newKind: int, newItemID: int, newIndex: int, newOrdinal: int, newVisual: int) -> void`

Source: `scripts/loot/inv_overhaul_container_drag.lua`

Purpose: Begins external source in the container drag subsystem.

Parameters:

- `newSource: int` — value interpreted according to the function purpose; no narrower contract is established by current code.
- `newKind: int` — value interpreted according to the function purpose; no narrower contract is established by current code.
- `newItemID: int` — engine item or callback identifier interpreted by this function.
- `newIndex: int` — zero-based entry index in the relevant engine container/category.
- `newOrdinal: int` — value interpreted according to the function purpose; no narrower contract is established by current code.
- `newVisual: int` — value interpreted according to the function purpose; no narrower contract is established by current code.

Returns:

None.

Side effects:

- Mutates module/task state: `source`, `kind`, `itemID`, `playerCategory`, `playerIndex`, `playerCell`, `containerIndex`, `containerOrdinal`, `… and 3 more`.

Called by:

- `scripts/loot/inv_overhaul_container_drag_controller.lua :: ResolveSource`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `ClearSource() -> void`

Source: `scripts/loot/inv_overhaul_container_drag.lua`

Purpose: Clears source in the container drag subsystem.

Parameters:

None.

Returns:

None.

Side effects:

- Mutates module/task state: `source`, `kind`, `itemID`, `playerCategory`, `playerIndex`, `playerCell`, `containerIndex`, `containerOrdinal`, `… and 3 more`.

Called by:

- `scripts/loot/inv_overhaul_container_drag_controller.lua :: EndCursor`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `LootDragIsActive() -> bool`

Source: `scripts/loot/inv_overhaul_container_drag.lua`

Purpose: Returns whether active for loot drag in the container drag subsystem.

Parameters:

None.

Returns:

- `boolean` — result of: returns whether active for loot drag in the container drag subsystem.

Side effects:

- None directly observable beyond calls listed below.

Called by:

- `scripts/loot/inv_overhaul_container.lua :: OnMouseMove`
- `scripts/loot/inv_overhaul_container.lua :: OnMouseLeave`
- `scripts/loot/inv_overhaul_container.lua :: OnLButtonUp`
- `scripts/loot/inv_overhaul_container_drag_controller.lua :: LootDragControllerSetHighlightedTarget`
- `scripts/loot/inv_overhaul_container_drag_controller.lua :: LootDragControllerApplyPointerTarget`
- `scripts/loot/inv_overhaul_container_drag_controller.lua :: Start`
- `scripts/loot/inv_overhaul_container_drag_controller.lua :: Finish`
- `scripts/loot/inv_overhaul_container_input_controller.lua :: LootInputAssignHoveredQuickslot`
- `… and 7 more`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `GetSource() -> int`

Source: `scripts/loot/inv_overhaul_container_drag.lua`

Purpose: Returns source in the container drag subsystem.

Parameters:

None.

Returns:

- `number` (integer) — result of: returns source in the container drag subsystem.

Side effects:

- None directly observable beyond calls listed below.

Called by:

- `scripts/loot/inv_overhaul_container_drag_controller.lua :: LootDragControllerApplyPointerTarget`
- `scripts/loot/inv_overhaul_container_drag_controller.lua :: Finish`
- `scripts/loot/inv_overhaul_container_paging_controller.lua :: BeginDragHover`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `GetKind() -> int`

Source: `scripts/loot/inv_overhaul_container_drag.lua`

Purpose: Returns kind in the container drag subsystem.

Parameters:

None.

Returns:

- `number` (integer) — result of: returns kind in the container drag subsystem.

Side effects:

- None directly observable beyond calls listed below.

Called by:

- `scripts/loot/inv_overhaul_container_drag_controller.lua :: LootDragControllerIsTargetCompatible`
- `scripts/loot/inv_overhaul_container_drag_controller.lua :: LootDragControllerApplyPointerTarget`
- `scripts/loot/inv_overhaul_container_drag_controller.lua :: Finish`
- `scripts/loot/inv_overhaul_container_transfer_external.lua :: MoveAmountToPlayer`
- `scripts/loot/inv_overhaul_container_transfer_player.lua :: MoveAmountToContainer`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `LootDragGetItemID() -> int`

Source: `scripts/loot/inv_overhaul_container_drag.lua`

Purpose: Returns item id for loot drag in the container drag subsystem.

Parameters:

None.

Returns:

- `number` (integer) — result of: returns item id for loot drag in the container drag subsystem.

Side effects:

- None directly observable beyond calls listed below.

Called by:

- `scripts/loot/inv_overhaul_container_drag_controller.lua :: BeginCursor`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `GetPlayerCategory() -> int`

Source: `scripts/loot/inv_overhaul_container_drag.lua`

Purpose: Returns player category in the container drag subsystem.

Parameters:

None.

Returns:

- `number` (integer) — result of: returns player category in the container drag subsystem.

Side effects:

- None directly observable beyond calls listed below.

Called by:

- `scripts/loot/inv_overhaul_container_transfer_player.lua :: MoveAmountToContainer`
- `scripts/loot/inv_overhaul_container_transfer_player.lua :: ExchangeWithContainer`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `GetPlayerIndex() -> int`

Source: `scripts/loot/inv_overhaul_container_drag.lua`

Purpose: Returns player index in the container drag subsystem.

Parameters:

None.

Returns:

- `number` (integer) — result of: returns player index in the container drag subsystem.

Side effects:

- None directly observable beyond calls listed below.

Called by:

- `scripts/loot/inv_overhaul_container_transfer_player.lua :: MoveAmountToContainer`
- `scripts/loot/inv_overhaul_container_transfer_player.lua :: ExchangeWithContainer`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `GetPlayerCell() -> int`

Source: `scripts/loot/inv_overhaul_container_drag.lua`

Purpose: Returns player cell in the container drag subsystem.

Parameters:

None.

Returns:

- `number` (integer) — result of: returns player cell in the container drag subsystem.

Side effects:

- None directly observable beyond calls listed below.

Called by:

- `scripts/loot/inv_overhaul_container_drag_controller.lua :: LootDragControllerApplyPointerTarget`
- `scripts/loot/inv_overhaul_container_drag_controller.lua :: Finish`
- `scripts/loot/inv_overhaul_container_transfer_player.lua :: MoveAmountToContainer`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `GetContainerIndex() -> int`

Source: `scripts/loot/inv_overhaul_container_drag.lua`

Purpose: Returns container index in the container drag subsystem.

Parameters:

None.

Returns:

- `number` (integer) — result of: returns container index in the container drag subsystem.

Side effects:

- None directly observable beyond calls listed below.

Called by:

- `scripts/loot/inv_overhaul_container_transfer_external.lua :: MoveAmountToPlayer`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `GetContainerOrdinal() -> int`

Source: `scripts/loot/inv_overhaul_container_drag.lua`

Purpose: Returns container ordinal in the container drag subsystem.

Parameters:

None.

Returns:

- `number` (integer) — result of: returns container ordinal in the container drag subsystem.

Side effects:

- None directly observable beyond calls listed below.

Called by:

- `scripts/loot/inv_overhaul_container_transfer_external.lua :: MoveAmountToPlayer`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `GetContainerVisual() -> int`

Source: `scripts/loot/inv_overhaul_container_drag.lua`

Purpose: Returns container visual in the container drag subsystem.

Parameters:

None.

Returns:

- `number` (integer) — result of: returns container visual in the container drag subsystem.

Side effects:

- None directly observable beyond calls listed below.

Called by:

- `scripts/loot/inv_overhaul_container_drag_controller.lua :: LootDragControllerApplyPointerTarget`
- `scripts/loot/inv_overhaul_container_drag_controller.lua :: Finish`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `LootDragGetHighlightedTarget() -> int`

Source: `scripts/loot/inv_overhaul_container_drag.lua`

Purpose: Returns highlighted target for loot drag in the container drag subsystem.

Parameters:

None.

Returns:

- `number` (integer) — result of: returns highlighted target for loot drag in the container drag subsystem.

Side effects:

- None directly observable beyond calls listed below.

Called by:

- `scripts/loot/inv_overhaul_container_drag_controller.lua :: LootDragControllerSetHighlightedTarget`
- `scripts/loot/inv_overhaul_container_input_controller.lua :: LootInputAssignHoveredQuickslot`
- `scripts/loot/inv_overhaul_container_input_controller.lua :: LootInputHandleDragLifecycleMessage`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `LootDragSetHighlightedTarget(target: int) -> void`

Source: `scripts/loot/inv_overhaul_container_drag.lua`

Purpose: Sets highlighted target for loot drag in the container drag subsystem.

Parameters:

- `target: int` — value interpreted according to the function purpose; no narrower contract is established by current code.

Returns:

None.

Side effects:

- Mutates module/task state: `highlightedTarget`.

Called by:

- `scripts/loot/inv_overhaul_container_drag_controller.lua :: LootDragControllerSetHighlightedTarget`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `RecordPointerTarget(target: int, sameSource: bool, compatible: bool) -> int`

Source: `scripts/loot/inv_overhaul_container_drag.lua`

Purpose: Records pointer target in the container drag subsystem.

Parameters:

- `target: int` — value interpreted according to the function purpose; no narrower contract is established by current code.
- `sameSource: bool` — behavior flag interpreted by this function.
- `compatible: bool` — behavior flag interpreted by this function.

Returns:

- `number` (integer) — result of: records pointer target in the container drag subsystem.

Side effects:

- Mutates module/task state: `lastValidTarget`, `invalidTargetFrames`.

Called by:

- `scripts/loot/inv_overhaul_container_drag_controller.lua :: LootDragControllerApplyPointerTarget`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `LootDragResolveReleaseTarget(target: int) -> int`

Source: `scripts/loot/inv_overhaul_container_drag.lua`

Purpose: Resolves release target for loot drag in the container drag subsystem.

Parameters:

- `target: int` — value interpreted according to the function purpose; no narrower contract is established by current code.

Returns:

- `number` (integer) — result of: resolves release target for loot drag in the container drag subsystem.

Side effects:

- None directly observable beyond calls listed below.

Called by:

- `scripts/loot/inv_overhaul_container_drag_controller.lua :: Finish`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `LootDragBeginPageHover(action: int) -> bool`

Source: `scripts/loot/inv_overhaul_container_drag.lua`

Purpose: Begins page hover for loot drag in the container drag subsystem.

Parameters:

- `action: int` — value interpreted according to the function purpose; no narrower contract is established by current code.

Returns:

- `boolean` — result of: begins page hover for loot drag in the container drag subsystem.

Side effects:

- Mutates module/task state: `pageHoverAction`, `pageHoverElapsed`, `pageHoverConsumed`.

Called by:

- `scripts/loot/inv_overhaul_container_paging_controller.lua :: BeginDragHover`
- `scripts/loot/inv_overhaul_container_paging_controller.lua :: SyncDragHoverFromCursor`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `LootDragCanCancelPageHover(action: int) -> bool`

Source: `scripts/loot/inv_overhaul_container_drag.lua`

Purpose: Returns whether cancel page hover for loot drag in the container drag subsystem.

Parameters:

- `action: int` — value interpreted according to the function purpose; no narrower contract is established by current code.

Returns:

- `boolean` — result of: returns whether cancel page hover for loot drag in the container drag subsystem.

Side effects:

- None directly observable beyond calls listed below.

Called by:

- `scripts/loot/inv_overhaul_container_drag_controller.lua :: CancelPageHover`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `LootDragClearPageHover() -> void`

Source: `scripts/loot/inv_overhaul_container_drag.lua`

Purpose: Clears page hover for loot drag in the container drag subsystem.

Parameters:

None.

Returns:

None.

Side effects:

- Mutates module/task state: `pageHoverAction`, `pageHoverElapsed`, `pageHoverConsumed`.

Called by:

- `scripts/loot/inv_overhaul_container_drag_controller.lua :: CancelPageHover`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `LootDragGetPageHoverAction() -> int`

Source: `scripts/loot/inv_overhaul_container_drag.lua`

Purpose: Returns page hover action for loot drag in the container drag subsystem.

Parameters:

None.

Returns:

- `number` (integer) — result of: returns page hover action for loot drag in the container drag subsystem.

Side effects:

- None directly observable beyond calls listed below.

Called by:

- `scripts/loot/inv_overhaul_container_drag_controller.lua :: CancelPageHover`
- `scripts/loot/inv_overhaul_container_paging_controller.lua :: UpdateDragHover`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `LootDragGetPageHoverElapsed() -> float`

Source: `scripts/loot/inv_overhaul_container_drag.lua`

Purpose: Returns page hover elapsed for loot drag in the container drag subsystem.

Parameters:

None.

Returns:

- `number` — result of: returns page hover elapsed for loot drag in the container drag subsystem.

Side effects:

- None directly observable beyond calls listed below.

Called by:

- `scripts/loot/inv_overhaul_container_drag_controller.lua :: CancelPageHover`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `LootDragAdvancePageHover(delta: float) -> int`

Source: `scripts/loot/inv_overhaul_container_drag.lua`

Purpose: Advances page hover for loot drag in the container drag subsystem.

Parameters:

- `delta: float` — elapsed update time in seconds.

Returns:

- `number` (integer) — result of: advances page hover for loot drag in the container drag subsystem.

Side effects:

- Mutates module/task state: `pageHoverElapsed`, `pageHoverConsumed`, `lastValidTarget`, `invalidTargetFrames`.

Called by:

- `scripts/loot/inv_overhaul_container_paging_controller.lua :: UpdateDragHover`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.


## Internal API

No additional maintask helpers.

## Events / callbacks

No engine callbacks; this is an imported module.

## Important constants

- `c_fPageHoverDelay: float = 1.00` — timing value, in seconds, for page hover delay.

## Architectural notes

- No additional module-specific issue identified beyond repository-wide shared-variable and compiler-visible API constraints.
