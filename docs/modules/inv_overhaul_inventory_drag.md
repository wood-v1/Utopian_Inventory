# Inventory Drag

## Source

`scripts/player_inventory/inv_overhaul_inventory_drag.lua`

DSL unit: `module inv_overhaul_inventory_drag`

## Responsibility

Owns player-screen drag state, drag cursor publication, highlighting, and source/target bookkeeping.

## Dependencies

- No local DSL imports.

## Used by

- `scripts/player_inventory/inv_overhaul_inventory_controller.lua`

## State

- `sourceSlot: int` — current or cached layout value for source slot.
- `sourceCell: int` — mutable runtime state for source cell.
- `hoverTarget: int` — mutable runtime state for hover target.
- `highlightedTarget: int` — current interaction state for highlighted target.
- `moved: bool` — lifecycle/behavior flag for moved.
- `latchedTarget: int` — mutable runtime state for latched target.
- `invalidTargetFrames: int` — mutable runtime state for invalid target frames.
- `itemID: int` — mutable runtime state for item id.
- `itemCategory: int` — mutable runtime state for item category.
- `itemIndex: int` — mutable runtime state for item index.
- `itemGroup: int` — mutable runtime state for item group.
- `itemIsWeapon: bool` — lifecycle/behavior flag for item is weapon.
- `pageHoverAction: int` — current or cached paging state for page hover action.
- `pageHoverElapsed: float` — current or cached paging state for page hover elapsed.
- `pageHoverConsumed: bool` — current or cached paging state for page hover consumed.

## Public API

All functions below are compiler-visible when the module is imported; the DSL has no private declaration.

### `PlayerDragInitializeState() -> void`

Source: `scripts/player_inventory/inv_overhaul_inventory_drag.lua`

Purpose: Initializes state for player drag in the inventory drag subsystem.

Parameters:

None.

Returns:

None.

Side effects:

- Mutates module/task state: `sourceSlot`, `sourceCell`, `hoverTarget`, `highlightedTarget`, `moved`, `latchedTarget`, `invalidTargetFrames`, `itemID`, `… and 7 more`.

Called by:

- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: PlayerControllerInitialize`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `BeginItem(newItemID: int, newCategory: int, newIndex: int, newGroup: int, newIsWeapon: bool) -> void`

Source: `scripts/player_inventory/inv_overhaul_inventory_drag.lua`

Purpose: Begins item in the inventory drag subsystem.

Parameters:

- `newItemID: int` — engine item or callback identifier interpreted by this function.
- `newCategory: int` — zero-based engine inventory category identifier.
- `newIndex: int` — zero-based entry index in the relevant engine container/category.
- `newGroup: int` — value interpreted according to the function purpose; no narrower contract is established by current code.
- `newIsWeapon: bool` — behavior flag interpreted by this function.

Returns:

None.

Side effects:

- Mutates module/task state: `itemID`, `itemCategory`, `itemIndex`, `itemGroup`, `itemIsWeapon`.

Called by:

- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: BeginDragCursor`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `ClearItem() -> void`

Source: `scripts/player_inventory/inv_overhaul_inventory_drag.lua`

Purpose: Clears item in the inventory drag subsystem.

Parameters:

None.

Returns:

None.

Side effects:

- Mutates module/task state: `itemID`, `itemCategory`, `itemIndex`, `itemGroup`, `itemIsWeapon`.

Called by:

- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: BeginDragCursor`
- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: EndDragCursor`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `BeginTransaction(newSourceSlot: int, newSourceCell: int) -> void`

Source: `scripts/player_inventory/inv_overhaul_inventory_drag.lua`

Purpose: Begins transaction in the inventory drag subsystem.

Parameters:

- `newSourceSlot: int` — slot index or encoded slot target interpreted by this function.
- `newSourceCell: int` — zero-based backpack layout cell.

Returns:

None.

Side effects:

- Mutates module/task state: `sourceSlot`, `sourceCell`, `hoverTarget`, `moved`, `latchedTarget`, `invalidTargetFrames`.

Called by:

- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: StartDragAction`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `ClearTransaction() -> void`

Source: `scripts/player_inventory/inv_overhaul_inventory_drag.lua`

Purpose: Clears transaction in the inventory drag subsystem.

Parameters:

None.

Returns:

None.

Side effects:

- Mutates module/task state: `sourceSlot`, `sourceCell`, `hoverTarget`, `moved`, `latchedTarget`, `invalidTargetFrames`.

Called by:

- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: CancelDragAction`
- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: FinishLeftAction`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `PlayerDragIsActive() -> bool`

Source: `scripts/player_inventory/inv_overhaul_inventory_drag.lua`

Purpose: Returns whether active for player drag in the inventory drag subsystem.

Parameters:

None.

Returns:

- `boolean` — result of: returns whether active for player drag in the inventory drag subsystem.

Side effects:

- None directly observable beyond calls listed below.

Called by:

- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: ReconcileInventoryContentGeneration`
- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: PlayerControllerAssignHoveredQuickslot`
- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: CancelDragAction`
- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: FinishLeftAction`
- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: ApplyPointerSlot`
- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: BeginDragPageHover`
- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: UpdateDragPageHover`
- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: SyncDragPageHoverFromCursor`
- `… and 9 more`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `GetSourceSlot() -> int`

Source: `scripts/player_inventory/inv_overhaul_inventory_drag.lua`

Purpose: Returns source slot in the inventory drag subsystem.

Parameters:

None.

Returns:

- `number` (integer) — result of: returns source slot in the inventory drag subsystem.

Side effects:

- None directly observable beyond calls listed below.

Called by:

- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: ReadDragSourceSlot`
- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: CancelDragAction`
- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: FinishLeftAction`
- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: ApplyPointerSlot`
- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: BeginDragPageHover`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `GetSourceCell() -> int`

Source: `scripts/player_inventory/inv_overhaul_inventory_drag.lua`

Purpose: Returns source cell in the inventory drag subsystem.

Parameters:

None.

Returns:

- `number` (integer) — result of: returns source cell in the inventory drag subsystem.

Side effects:

- None directly observable beyond calls listed below.

Called by:

- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: ReadDragSourceCell`
- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: FinishLeftAction`
- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: ApplyPointerSlot`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `GetHoverTarget() -> int`

Source: `scripts/player_inventory/inv_overhaul_inventory_drag.lua`

Purpose: Returns hover target in the inventory drag subsystem.

Parameters:

None.

Returns:

- `number` (integer) — result of: returns hover target in the inventory drag subsystem.

Side effects:

- None directly observable beyond calls listed below.

Called by:

- No in-repository caller was resolved; this may be an engine/XML callback or a conventionally public helper.

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `SetHoverTarget(target: int) -> void`

Source: `scripts/player_inventory/inv_overhaul_inventory_drag.lua`

Purpose: Sets hover target in the inventory drag subsystem.

Parameters:

- `target: int` — value interpreted according to the function purpose; no narrower contract is established by current code.

Returns:

None.

Side effects:

- Mutates module/task state: `hoverTarget`.

Called by:

- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: HandleEquipmentProtocolMessage`
- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: HandleSlotPointerProtocolMessage`
- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: PlayerControllerHandleDragLifecycleMessage`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `PlayerDragGetHighlightedTarget() -> int`

Source: `scripts/player_inventory/inv_overhaul_inventory_drag.lua`

Purpose: Returns highlighted target for player drag in the inventory drag subsystem.

Parameters:

None.

Returns:

- `number` (integer) — result of: returns highlighted target for player drag in the inventory drag subsystem.

Side effects:

- None directly observable beyond calls listed below.

Called by:

- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: ReadHighlightedSlot`
- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: PlayerControllerAssignHoveredQuickslot`
- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: SetHighlightedSlot`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `PlayerDragSetHighlightedTarget(target: int) -> void`

Source: `scripts/player_inventory/inv_overhaul_inventory_drag.lua`

Purpose: Sets highlighted target for player drag in the inventory drag subsystem.

Parameters:

- `target: int` — value interpreted according to the function purpose; no narrower contract is established by current code.

Returns:

None.

Side effects:

- Mutates module/task state: `highlightedTarget`.

Called by:

- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: SetHighlightedSlot`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `HasMoved() -> bool`

Source: `scripts/player_inventory/inv_overhaul_inventory_drag.lua`

Purpose: Returns whether moved in the inventory drag subsystem.

Parameters:

None.

Returns:

- `boolean` — result of: returns whether moved in the inventory drag subsystem.

Side effects:

- None directly observable beyond calls listed below.

Called by:

- No in-repository caller was resolved; this may be an engine/XML callback or a conventionally public helper.

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `PlayerDragGetItemID() -> int`

Source: `scripts/player_inventory/inv_overhaul_inventory_drag.lua`

Purpose: Returns item id for player drag in the inventory drag subsystem.

Parameters:

None.

Returns:

- `number` (integer) — result of: returns item id for player drag in the inventory drag subsystem.

Side effects:

- None directly observable beyond calls listed below.

Called by:

- No in-repository caller was resolved; this may be an engine/XML callback or a conventionally public helper.

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `GetItemCategory() -> int`

Source: `scripts/player_inventory/inv_overhaul_inventory_drag.lua`

Purpose: Returns item category in the inventory drag subsystem.

Parameters:

None.

Returns:

- `number` (integer) — result of: returns item category in the inventory drag subsystem.

Side effects:

- None directly observable beyond calls listed below.

Called by:

- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: ReadDragItemCategory`
- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: FindSpecialTargetAt`
- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: FinishLeftAction`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `GetItemIndex() -> int`

Source: `scripts/player_inventory/inv_overhaul_inventory_drag.lua`

Purpose: Returns item index in the inventory drag subsystem.

Parameters:

None.

Returns:

- `number` (integer) — result of: returns item index in the inventory drag subsystem.

Side effects:

- None directly observable beyond calls listed below.

Called by:

- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: ReadDragItemIndex`
- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: FinishLeftAction`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `GetItemGroup() -> int`

Source: `scripts/player_inventory/inv_overhaul_inventory_drag.lua`

Purpose: Returns item group in the inventory drag subsystem.

Parameters:

None.

Returns:

- `number` (integer) — result of: returns item group in the inventory drag subsystem.

Side effects:

- None directly observable beyond calls listed below.

Called by:

- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: ReadDragItemGroup`
- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: FindSpecialTargetAt`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `GetItemIsWeapon() -> bool`

Source: `scripts/player_inventory/inv_overhaul_inventory_drag.lua`

Purpose: Returns item is weapon in the inventory drag subsystem.

Parameters:

None.

Returns:

- `boolean` — result of: returns item is weapon in the inventory drag subsystem.

Side effects:

- None directly observable beyond calls listed below.

Called by:

- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: ReadDragItemIsWeapon`
- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: FindSpecialTargetAt`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `PlayerDragApplyPointerTarget(target: int, sameSource: bool) -> int`

Source: `scripts/player_inventory/inv_overhaul_inventory_drag.lua`

Purpose: Applies pointer target for player drag in the inventory drag subsystem.

Parameters:

- `target: int` — value interpreted according to the function purpose; no narrower contract is established by current code.
- `sameSource: bool` — behavior flag interpreted by this function.

Returns:

- `number` (integer) — result of: applies pointer target for player drag in the inventory drag subsystem.

Side effects:

- Mutates module/task state: `moved`, `latchedTarget`, `invalidTargetFrames`.

Called by:

- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: ApplyPointerSlot`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `PlayerDragResolveReleaseTarget(target: int) -> int`

Source: `scripts/player_inventory/inv_overhaul_inventory_drag.lua`

Purpose: Resolves release target for player drag in the inventory drag subsystem.

Parameters:

- `target: int` — value interpreted according to the function purpose; no narrower contract is established by current code.

Returns:

- `number` (integer) — result of: resolves release target for player drag in the inventory drag subsystem.

Side effects:

- None directly observable beyond calls listed below.

Called by:

- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: FinishLeftAction`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `PlayerDragBeginPageHover(action: int) -> bool`

Source: `scripts/player_inventory/inv_overhaul_inventory_drag.lua`

Purpose: Begins page hover for player drag in the inventory drag subsystem.

Parameters:

- `action: int` — value interpreted according to the function purpose; no narrower contract is established by current code.

Returns:

- `boolean` — result of: begins page hover for player drag in the inventory drag subsystem.

Side effects:

- Mutates module/task state: `pageHoverAction`, `pageHoverElapsed`, `pageHoverConsumed`.

Called by:

- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: BeginDragPageHover`
- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: SyncDragPageHoverFromCursor`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `PlayerDragCanCancelPageHover(action: int) -> bool`

Source: `scripts/player_inventory/inv_overhaul_inventory_drag.lua`

Purpose: Returns whether cancel page hover for player drag in the inventory drag subsystem.

Parameters:

- `action: int` — value interpreted according to the function purpose; no narrower contract is established by current code.

Returns:

- `boolean` — result of: returns whether cancel page hover for player drag in the inventory drag subsystem.

Side effects:

- None directly observable beyond calls listed below.

Called by:

- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: CancelDragPageHover`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `PlayerDragClearPageHover() -> void`

Source: `scripts/player_inventory/inv_overhaul_inventory_drag.lua`

Purpose: Clears page hover for player drag in the inventory drag subsystem.

Parameters:

None.

Returns:

None.

Side effects:

- Mutates module/task state: `pageHoverAction`, `pageHoverElapsed`, `pageHoverConsumed`.

Called by:

- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: CancelDragPageHover`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `PlayerDragGetPageHoverAction() -> int`

Source: `scripts/player_inventory/inv_overhaul_inventory_drag.lua`

Purpose: Returns page hover action for player drag in the inventory drag subsystem.

Parameters:

None.

Returns:

- `number` (integer) — result of: returns page hover action for player drag in the inventory drag subsystem.

Side effects:

- None directly observable beyond calls listed below.

Called by:

- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: CancelDragPageHover`
- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: UpdateDragPageHover`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `PlayerDragGetPageHoverElapsed() -> float`

Source: `scripts/player_inventory/inv_overhaul_inventory_drag.lua`

Purpose: Returns page hover elapsed for player drag in the inventory drag subsystem.

Parameters:

None.

Returns:

- `number` — result of: returns page hover elapsed for player drag in the inventory drag subsystem.

Side effects:

- None directly observable beyond calls listed below.

Called by:

- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: CancelDragPageHover`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `PlayerDragAdvancePageHover(delta: float) -> int`

Source: `scripts/player_inventory/inv_overhaul_inventory_drag.lua`

Purpose: Advances page hover for player drag in the inventory drag subsystem.

Parameters:

- `delta: float` — elapsed update time in seconds.

Returns:

- `number` (integer) — result of: advances page hover for player drag in the inventory drag subsystem.

Side effects:

- Mutates module/task state: `pageHoverElapsed`, `pageHoverConsumed`, `latchedTarget`, `invalidTargetFrames`.

Called by:

- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: UpdateDragPageHover`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.


## Internal API

No additional maintask helpers.

## Events / callbacks

No engine callbacks; this is an imported module.

## Important constants

- `InventoryDragPageHoverDelay: float = 1.00` — timing value, in seconds, for inventory drag page hover delay.

## Architectural notes

- No additional module-specific issue identified beyond repository-wide shared-variable and compiler-visible API constraints.
