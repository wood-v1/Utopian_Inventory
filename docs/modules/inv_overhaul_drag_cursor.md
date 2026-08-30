# Drag Cursor

## Source

`scripts/compatibility/ui_runtime/inv_overhaul_drag_cursor.lua`

DSL unit: `maintask InvOverhaulDragCursor`

## Responsibility

Retained compatibility cursor form that renders a dragged item sprite.

This source is compatibility-only. Active packages must not import it.

## Dependencies

- No local DSL imports.
- Pathologic native API — engine state, object access, persistence variables, UI messaging, timing, or rendering as listed per function.

## Used by

- No local import or direct runtime reference was resolved. It may be retained for external/save compatibility.

## State

- `itemID: int` — mutable runtime state for item id.
- `loadedItemID: int` — mutable runtime state for loaded item id.
- `sprite: string` — mutable runtime state for sprite.
- `updateSeen: bool` — lifecycle/behavior flag for update seen.

## Public API

No importable module API. Runtime entry points are documented under Events / callbacks.

## Internal API

### `OnCursorWndChange(newWindow: object, previousWindow: object) -> void`

Source: `scripts/compatibility/ui_runtime/inv_overhaul_drag_cursor.lua`

Purpose: Handles the engine/UI `OnCursorWndChange` callback for the drag cursor runtime.

Parameters:

- `newWindow: object` — engine object/vector; type/shape not fully determined beyond the method usage in current code.
- `previousWindow: object` — engine object/vector; type/shape not fully determined beyond the method usage in current code.

Returns:

None.

Side effects:

- Writes shared engine variable(s): `"inv_overhaul_inventory_page_hover"`.
- Invokes engine/native operations: `native.SetVariable`.

Called by:

- No in-repository caller was resolved; this may be an engine/XML callback or a conventionally public helper.

Calls:

- `newWindow.GetTooltipText`
- `native.SetVariable`

Notes / invariants:

- Maintask helper; callable within its task unless the engine invokes it by a documented callback name.


## Events / callbacks

### `init() -> void`

Source: `scripts/compatibility/ui_runtime/inv_overhaul_drag_cursor.lua`

Purpose: Initializes the drag cursor runtime and establishes its starting state and engine/UI integration.

Parameters:

None.

Returns:

None.

Side effects:

- Mutates module/task state: `itemID`, `loadedItemID`, `sprite`, `updateSeen`.
- Writes shared engine variable(s): `"inv_overhaul_inventory_page_hover"`.
- Invokes engine/native operations: `native.SetVariable`, `native.SetOwnerDraw`, `native.SetNeedUpdate`, `native.ProcessEvents`.

Called by:

- No in-repository caller was resolved; this may be an engine/XML callback or a conventionally public helper.

Calls:

- `native.SetVariable`
- `native.SetOwnerDraw`
- `native.SetNeedUpdate`
- `native.ProcessEvents`

Notes / invariants:

- Maintask helper; callable within its task unless the engine invokes it by a documented callback name.

### `OnUpdate(delta: float) -> void`

Source: `scripts/compatibility/ui_runtime/inv_overhaul_drag_cursor.lua`

Purpose: Handles the engine/UI `OnUpdate` callback for the drag cursor runtime.

Parameters:

- `delta: float` — elapsed update time in seconds.

Returns:

None.

Side effects:

- Mutates module/task state: `updateSeen`.

Called by:

- No in-repository caller was resolved; this may be an engine/XML callback or a conventionally public helper.

Notes / invariants:

- Callback recognition is name-based in `pathologic_lua_compiler`; `OnUpdate` is an engine event name.

### `OnDraw() -> void`

Source: `scripts/compatibility/ui_runtime/inv_overhaul_drag_cursor.lua`

Purpose: Handles the engine/UI `OnDraw` callback for the drag cursor runtime.

Parameters:

None.

Returns:

None.

Side effects:

- Mutates module/task state: `loadedItemID`.
- Invokes engine/native operations: `native.Blit`, `native.LoadImage`, `native.StretchBlit`.

Called by:

- No in-repository caller was resolved; this may be an engine/XML callback or a conventionally public helper.

Calls:

- `native.GetVariable`
- `native.Blit`
- `native.GetInvItemSprite`
- `native.LoadImage`
- `native.StretchBlit`

Notes / invariants:

- Callback recognition is name-based in `pathologic_lua_compiler`; `OnDraw` is an engine event name.


## Important constants

No module/task-level constants.

## Architectural notes

- No additional module-specific issue identified beyond repository-wide shared-variable and compiler-visible API constraints.
