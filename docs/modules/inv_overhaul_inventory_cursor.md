# Inventory Cursor

## Source

`scripts/player_inventory/widgets/inv_overhaul_inventory_cursor.lua`

DSL unit: `maintask UI_Cursor`

## Responsibility

Renders the custom inventory drag cursor from item metadata supplied through UI messages.

## Dependencies

- No local DSL imports.
- Pathologic native API — engine state, object access, persistence variables, UI messaging, timing, or rendering as listed per function.

## Used by

- `resources/ui/inv_overhaul_container.xml` (runtime/XML script reference)
- `resources/ui/inv_overhaul_container_1024x768.xml` (runtime/XML script reference)
- `resources/ui/inv_overhaul_container_1280x1024.xml` (runtime/XML script reference)
- `resources/ui/inv_overhaul_container_1920x1080.xml` (runtime/XML script reference)
- `resources/ui/inv_overhaul_corpse.xml` (runtime/XML script reference)
- `resources/ui/inv_overhaul_corpse_1024x768.xml` (runtime/XML script reference)
- `resources/ui/inv_overhaul_corpse_1280x1024.xml` (runtime/XML script reference)
- `resources/ui/inv_overhaul_corpse_1920x1080.xml` (runtime/XML script reference)
- `… and 8 more` (runtime/XML script reference)

## State

- `wndCur: object` — engine object/vector storage for wnd cur; exact runtime shape follows its method usage.
- `tooltipObject: object` — engine object/vector storage for tooltip object; exact runtime shape follows its method usage.
- `tooltipText: string` — mutable runtime state for tooltip text.
- `tooltipType: int` — mutable runtime state for tooltip type.
- `tooltipTime: float` — mutable runtime state for tooltip time.
- `dragItemID: int` — current interaction state for drag item id.
- `loadedDragItemID: int` — current interaction state for loaded drag item id.
- `dragSprite: string` — current interaction state for drag sprite.
- `initialized: bool` — lifecycle/behavior flag for initialized.
- `updateSeen: bool` — lifecycle/behavior flag for update seen.
- `drawSeen: bool` — lifecycle/behavior flag for draw seen.
- `tooltipReadyLogged: bool` — lifecycle/behavior flag for tooltip ready logged.
- `tooltipDrawLogged: bool` — lifecycle/behavior flag for tooltip draw logged.
- `trackedTooltipItemID: int` — mutable runtime state for tracked tooltip item id.
- `trackedTooltipType: int` — mutable runtime state for tracked tooltip type.
- `trackedTooltipTextID: int` — mutable runtime state for tracked tooltip text id.

## Public API

No importable module API. Runtime entry points are documented under Events / callbacks.

## Internal API

### `EnsureInitialized() -> void`

Source: `scripts/player_inventory/widgets/inv_overhaul_inventory_cursor.lua`

Purpose: Ensures initialized in the inventory cursor subsystem.

Parameters:

None.

Returns:

None.

Side effects:

- Mutates module/task state: `initialized`, `tooltipType`, `tooltipText`, `tooltipTime`, `dragItemID`, `loadedDragItemID`, `dragSprite`, `updateSeen`, `… and 6 more`.
- Invokes engine/native operations: `native.CreateInvItem`, `native.SetOwnerDraw`, `native.SetNeedUpdate`, `native.ProcessEvents`.

Called by:

- `scripts/player_inventory/widgets/inv_overhaul_inventory_cursor.lua :: init`
- `scripts/player_inventory/widgets/inv_overhaul_inventory_cursor.lua :: LoadTooltip`
- `scripts/player_inventory/widgets/inv_overhaul_inventory_cursor.lua :: OnCursorWndChange`
- `scripts/player_inventory/widgets/inv_overhaul_inventory_cursor.lua :: OnUpdate`
- `scripts/player_inventory/widgets/inv_overhaul_inventory_cursor.lua :: OnDraw`

Calls:

- `native.CreateInvItem`
- `native.SetOwnerDraw`
- `native.SetNeedUpdate`
- `native.ProcessEvents`

Notes / invariants:

- Maintask helper; callable within its task unless the engine invokes it by a documented callback name.

### `SetPageHover(window: object) -> void`

Source: `scripts/player_inventory/widgets/inv_overhaul_inventory_cursor.lua`

Purpose: Sets page hover in the inventory cursor subsystem.

Parameters:

- `window: object` — engine object/vector; type/shape not fully determined beyond the method usage in current code.

Returns:

None.

Side effects:

- Writes shared engine variable(s): `"inv_overhaul_inventory_page_hover"`.
- Invokes engine/native operations: `native.SetVariable`.

Called by:

- `scripts/player_inventory/widgets/inv_overhaul_inventory_cursor.lua :: OnCursorWndChange`

Calls:

- `window.GetTooltipText`
- `native.SetVariable`

Notes / invariants:

- Maintask helper; callable within its task unless the engine invokes it by a documented callback name.

### `LoadTooltip() -> void`

Source: `scripts/player_inventory/widgets/inv_overhaul_inventory_cursor.lua`

Purpose: Loads tooltip in the inventory cursor subsystem.

Parameters:

None.

Returns:

None.

Side effects:

- Mutates module/task state: `tooltipReadyLogged`, `tooltipDrawLogged`, `tooltipType`, `tooltipText`, `tooltipObject`, `tooltipTime`.
- Invokes engine/native operations: `native.LoadImage`.

Called by:

- No in-repository caller was resolved; this may be an engine/XML callback or a conventionally public helper.

Calls:

- `EnsureInitialized`
- `wndCur.GetTooltipType`
- `wndCur.GetTooltipText`
- `wndCur.GetTooltipObject`
- `tooltipObject.GetItemID`
- `native.GetInvItemSprite2`
- `native.LoadImage`

Notes / invariants:

- Maintask helper; callable within its task unless the engine invokes it by a documented callback name.

### `OnCursorWndChange(newWindow: object, previousWindow: object) -> void`

Source: `scripts/player_inventory/widgets/inv_overhaul_inventory_cursor.lua`

Purpose: Handles the engine/UI `OnCursorWndChange` callback for the inventory cursor runtime.

Parameters:

- `newWindow: object` — engine object/vector; type/shape not fully determined beyond the method usage in current code.
- `previousWindow: object` — engine object/vector; type/shape not fully determined beyond the method usage in current code.

Returns:

None.

Side effects:

- None directly observable beyond calls listed below.

Called by:

- No in-repository caller was resolved; this may be an engine/XML callback or a conventionally public helper.

Calls:

- `EnsureInitialized`
- `SetPageHover`

Notes / invariants:

- Maintask helper; callable within its task unless the engine invokes it by a documented callback name.

### `TooltipChanged() -> bool`

Source: `scripts/player_inventory/widgets/inv_overhaul_inventory_cursor.lua`

Purpose: Returns whether tooltip in the inventory cursor subsystem.

Parameters:

None.

Returns:

- `boolean` — result of: returns whether tooltip in the inventory cursor subsystem.

Side effects:

- None directly observable beyond calls listed below.

Called by:

- No in-repository caller was resolved; this may be an engine/XML callback or a conventionally public helper.

Calls:

- `wndCur.GetTooltipType`
- `wndCur.GetTooltipText`
- `wndCur.GetTooltipObject`
- `newObject.GetItemID`
- `tooltipObject.GetItemID`

Notes / invariants:

- Maintask helper; callable within its task unless the engine invokes it by a documented callback name.

### `DrawBorder(x: int, y: int, width: int, height: int, alpha: float) -> void`

Source: `scripts/player_inventory/widgets/inv_overhaul_inventory_cursor.lua`

Purpose: Draws border in the inventory cursor subsystem.

Parameters:

- `x: int` — pointer/layout coordinate interpreted by this function.
- `y: int` — pointer/layout coordinate interpreted by this function.
- `width: int` — current UI/layout size in pixels.
- `height: int` — current UI/layout size in pixels.
- `alpha: float` — value interpreted according to the function purpose; no narrower contract is established by current code.

Returns:

None.

Side effects:

- Invokes engine/native operations: `native.BlitClipped`, `native.StretchBlit`.

Called by:

- `scripts/player_inventory/widgets/inv_overhaul_inventory_cursor.lua :: DrawItemTooltip`
- `scripts/player_inventory/widgets/inv_overhaul_inventory_cursor.lua :: DrawTextTooltip`

Calls:

- `native.BlitClipped`
- `native.StretchBlit`

Notes / invariants:

- Maintask helper; callable within its task unless the engine invokes it by a documented callback name.

### `DrawItemImage(x: int, y: int, item: object, alpha: float) -> void`

Source: `scripts/player_inventory/widgets/inv_overhaul_inventory_cursor.lua`

Purpose: Draws item image in the inventory cursor subsystem.

Parameters:

- `x: int` — pointer/layout coordinate interpreted by this function.
- `y: int` — pointer/layout coordinate interpreted by this function.
- `item: object` — engine inventory-item object; available properties and methods are supplied by the game.
- `alpha: float` — value interpreted according to the function purpose; no narrower contract is established by current code.

Returns:

None.

Side effects:

- Invokes engine/native operations: `native.StretchBlit`.

Called by:

- `scripts/player_inventory/widgets/inv_overhaul_inventory_cursor.lua :: DrawItemTooltip`

Calls:

- `item.GetItemID`
- `native.GetInvItemSprite2`
- `native.StretchBlit`

Notes / invariants:

- Maintask helper; callable within its task unless the engine invokes it by a documented callback name.

### `DrawItemTooltip(cursorX: int, cursorY: int, item: object, extraText: string, alpha: float) -> void`

Source: `scripts/player_inventory/widgets/inv_overhaul_inventory_cursor.lua`

Purpose: Draws item tooltip in the inventory cursor subsystem.

Parameters:

- `cursorX: int` — value interpreted according to the function purpose; no narrower contract is established by current code.
- `cursorY: int` — value interpreted according to the function purpose; no narrower contract is established by current code.
- `item: object` — engine inventory-item object; available properties and methods are supplied by the game.
- `extraText: string` — value interpreted according to the function purpose; no narrower contract is established by current code.
- `alpha: float` — value interpreted according to the function purpose; no narrower contract is established by current code.

Returns:

None.

Side effects:

- Invokes engine/native operations: `native.ScreenToClient`, `native.PrintInWidth`.

Called by:

- `scripts/player_inventory/widgets/inv_overhaul_inventory_cursor.lua :: OnDraw`

Calls:

- `item.GetItemID`
- `native.HasInvItemProperty`
- `native.GetInvItemProperty`
- `native.GetStringByID`
- `native.GetTextHeightInWidth`
- `native.GetFontHeight`
- `item.HasProperty`
- `item.GetProperty`
- `native.GetScreenSize`
- `native.ScreenToClient`
- `DrawBorder`
- `DrawItemImage`
- `… and 1 more`

Notes / invariants:

- Maintask helper; callable within its task unless the engine invokes it by a documented callback name.

### `DrawTextTooltip(cursorX: int, cursorY: int, text: string, alpha: float) -> void`

Source: `scripts/player_inventory/widgets/inv_overhaul_inventory_cursor.lua`

Purpose: Draws text tooltip in the inventory cursor subsystem.

Parameters:

- `cursorX: int` — value interpreted according to the function purpose; no narrower contract is established by current code.
- `cursorY: int` — value interpreted according to the function purpose; no narrower contract is established by current code.
- `text: string` — value interpreted according to the function purpose; no narrower contract is established by current code.
- `alpha: float` — value interpreted according to the function purpose; no narrower contract is established by current code.

Returns:

None.

Side effects:

- Invokes engine/native operations: `native.ScreenToClient`, `native.PrintInWidth`.

Called by:

- `scripts/player_inventory/widgets/inv_overhaul_inventory_cursor.lua :: OnDraw`

Calls:

- `native.GetTextHeightInWidth`
- `native.GetScreenSize`
- `native.ScreenToClient`
- `DrawBorder`
- `native.PrintInWidth`

Notes / invariants:

- Maintask helper; callable within its task unless the engine invokes it by a documented callback name.


## Events / callbacks

### `init() -> void`

Source: `scripts/player_inventory/widgets/inv_overhaul_inventory_cursor.lua`

Purpose: Initializes the inventory cursor runtime and establishes its starting state and engine/UI integration.

Parameters:

None.

Returns:

None.

Side effects:

- None directly observable beyond calls listed below.

Called by:

- No in-repository caller was resolved; this may be an engine/XML callback or a conventionally public helper.

Calls:

- `EnsureInitialized`

Notes / invariants:

- Maintask helper; callable within its task unless the engine invokes it by a documented callback name.

### `OnUpdate(delta: float) -> void`

Source: `scripts/player_inventory/widgets/inv_overhaul_inventory_cursor.lua`

Purpose: Handles the engine/UI `OnUpdate` callback for the inventory cursor runtime.

Parameters:

- `delta: float` — elapsed update time in seconds.

Returns:

None.

Side effects:

- Mutates module/task state: `updateSeen`, `tooltipTime`, `loadedDragItemID`, `trackedTooltipItemID`, `trackedTooltipType`, `trackedTooltipTextID`, `tooltipType`, `tooltipText`, `… and 2 more`.
- Invokes engine/native operations: `native.LoadImage`.
- May mutate engine/UI objects through: `tooltipObject.SetItemName`.

Called by:

- No in-repository caller was resolved; this may be an engine/XML callback or a conventionally public helper.

Calls:

- `EnsureInitialized`
- `native.GetVariable`
- `native.GetInvItemSprite2`
- `native.LoadImage`
- `native.GetInvItemName`
- `tooltipObject.SetItemName`
- `native.GetStringByID`

Notes / invariants:

- Callback recognition is name-based in `pathologic_lua_compiler`; `OnUpdate` is an engine event name.

### `OnDraw() -> void`

Source: `scripts/player_inventory/widgets/inv_overhaul_inventory_cursor.lua`

Purpose: Handles the engine/UI `OnDraw` callback for the inventory cursor runtime.

Parameters:

None.

Returns:

None.

Side effects:

- Mutates module/task state: `drawSeen`, `loadedDragItemID`, `tooltipDrawLogged`.
- Invokes engine/native operations: `native.LoadImage`, `native.StretchBlit`, `native.ClientToScreen`.

Called by:

- No in-repository caller was resolved; this may be an engine/XML callback or a conventionally public helper.

Calls:

- `EnsureInitialized`
- `native.GetVariable`
- `native.GetInvItemSprite2`
- `native.LoadImage`
- `native.StretchBlit`
- `native.ClientToScreen`
- `DrawItemTooltip`
- `DrawTextTooltip`

Notes / invariants:

- Callback recognition is name-based in `pathologic_lua_compiler`; `OnDraw` is an engine event name.


## Important constants

- `c_iTooltipNone: int = -1` — named behavior/layout value for tooltip none.
- `c_iTooltipInvObject: int = 1` — named behavior/layout value for tooltip inv object.
- `c_iTooltipMapObject: int = 5` — named behavior/layout value for tooltip map object.
- `c_iTooltipWidth: int = 250` — named behavior/layout value for tooltip width.
- `c_fOpaqueTime: float = 0.5` — named behavior/layout value for opaque time.
- `c_fBlendTime: float = 0.15` — named behavior/layout value for blend time.

## Architectural notes

- No additional module-specific issue identified beyond repository-wide shared-variable and compiler-visible API constraints.
