# Drop Slot

## Source

`scripts/player_inventory/widgets/inv_overhaul_drop_slot.lua`

DSL unit: `maintask InvOverhaulDropSlot`

## Responsibility

Renders the drop target and publishes its pointer/drag protocol messages.

## Dependencies

- No local DSL imports.
- Pathologic native API — engine state, object access, persistence variables, UI messaging, timing, or rendering as listed per function.

## Used by

- `resources/ui/inv_overhaul_inventory.xml` (runtime/XML script reference)
- `resources/ui/inv_overhaul_inventory_1024x768.xml` (runtime/XML script reference)
- `resources/ui/inv_overhaul_inventory_1280x1024.xml` (runtime/XML script reference)
- `resources/ui/inv_overhaul_inventory_1920x1080.xml` (runtime/XML script reference)
- `resources/ui/inv_overhaul_inventory_clara.xml` (runtime/XML script reference)
- `resources/ui/inv_overhaul_inventory_clara_1024x768.xml` (runtime/XML script reference)
- `resources/ui/inv_overhaul_inventory_clara_1280x1024.xml` (runtime/XML script reference)
- `resources/ui/inv_overhaul_inventory_clara_1920x1080.xml` (runtime/XML script reference)

## State

- `highlighted: bool` — current interaction state for highlighted.
- `tooltip: string` — mutable runtime state for tooltip.
- `slotWidth: int` — current or cached layout value for slot width.
- `slotHeight: int` — current or cached layout value for slot height.

## Public API

No importable module API. Runtime entry points are documented under Events / callbacks.

## Internal API

### `UpdateBackground() -> void`

Source: `scripts/player_inventory/widgets/inv_overhaul_drop_slot.lua`

Purpose: Updates background in the drop slot subsystem.

Parameters:

None.

Returns:

None.

Side effects:

- Invokes engine/native operations: `native.SetBackground`.

Called by:

- `scripts/player_inventory/widgets/inv_overhaul_drop_slot.lua :: OnUIMessage`

Calls:

- `native.SetBackground`

Notes / invariants:

- Maintask helper; callable within its task unless the engine invokes it by a documented callback name.


## Events / callbacks

### `init() -> void`

Source: `scripts/player_inventory/widgets/inv_overhaul_drop_slot.lua`

Purpose: Initializes the drop slot runtime and establishes its starting state and engine/UI integration.

Parameters:

None.

Returns:

None.

Side effects:

- Mutates module/task state: `highlighted`, `slotWidth`, `slotHeight`.
- Invokes engine/native operations: `native.SetBackground`, `native.SetOwnerDraw`, `native.SetTooltip`, `native.ProcessEvents`.

Called by:

- No in-repository caller was resolved; this may be an engine/XML callback or a conventionally public helper.

Calls:

- `native.GetWindowSize`
- `native.SetBackground`
- `native.SetOwnerDraw`
- `native.GetStringByID`
- `native.SetTooltip`
- `native.ProcessEvents`

Notes / invariants:

- Maintask helper; callable within its task unless the engine invokes it by a documented callback name.

### `OnDraw() -> void`

Source: `scripts/player_inventory/widgets/inv_overhaul_drop_slot.lua`

Purpose: Handles the engine/UI `OnDraw` callback for the drop slot runtime.

Parameters:

None.

Returns:

None.

Side effects:

- Invokes engine/native operations: `native.Print`, `native.StretchBlit`.

Called by:

- No in-repository caller was resolved; this may be an engine/XML callback or a conventionally public helper.

Calls:

- `native.Print`
- `native.StretchBlit`

Notes / invariants:

- Callback recognition is name-based in `pathologic_lua_compiler`; `OnDraw` is an engine event name.

### `OnMouseEnter() -> void`

Source: `scripts/player_inventory/widgets/inv_overhaul_drop_slot.lua`

Purpose: Handles the engine/UI `OnMouseEnter` callback for the drop slot runtime.

Parameters:

None.

Returns:

None.

Side effects:

- Writes shared engine variable(s): `"inv_overhaul_inventory_tooltip_item"`, `"inv_overhaul_inventory_tooltip_text_id"`, `"inv_overhaul_inventory_tooltip_type"`.
- Invokes engine/native operations: `native.SetVariable`, `native.SetTooltip`, `native.SendMessageToParent`.

Called by:

- No in-repository caller was resolved; this may be an engine/XML callback or a conventionally public helper.

Calls:

- `native.SetVariable`
- `native.SetTooltip`
- `native.SendMessageToParent`

Notes / invariants:

- Callback recognition is name-based in `pathologic_lua_compiler`; `OnMouseEnter` is an engine event name.

### `OnMouseMove(x: int, y: int) -> void`

Source: `scripts/player_inventory/widgets/inv_overhaul_drop_slot.lua`

Purpose: Handles the engine/UI `OnMouseMove` callback for the drop slot runtime.

Parameters:

- `x: int` — pointer/layout coordinate interpreted by this function.
- `y: int` — pointer/layout coordinate interpreted by this function.

Returns:

None.

Side effects:

- Writes shared engine variable(s): `"inv_overhaul_inventory_tooltip_item"`, `"inv_overhaul_inventory_tooltip_text_id"`, `"inv_overhaul_inventory_tooltip_type"`.
- Invokes engine/native operations: `native.SetVariable`, `native.SetTooltip`, `native.SendMessageToParent`.

Called by:

- No in-repository caller was resolved; this may be an engine/XML callback or a conventionally public helper.

Calls:

- `native.SetVariable`
- `native.SetTooltip`
- `native.SendMessageToParent`

Notes / invariants:

- Callback recognition is name-based in `pathologic_lua_compiler`; `OnMouseMove` is an engine event name.

### `OnMouseLeave() -> void`

Source: `scripts/player_inventory/widgets/inv_overhaul_drop_slot.lua`

Purpose: Handles the engine/UI `OnMouseLeave` callback for the drop slot runtime.

Parameters:

None.

Returns:

None.

Side effects:

- Writes shared engine variable(s): `"inv_overhaul_inventory_tooltip_item"`, `"inv_overhaul_inventory_tooltip_type"`.
- Invokes engine/native operations: `native.SetVariable`.

Called by:

- No in-repository caller was resolved; this may be an engine/XML callback or a conventionally public helper.

Calls:

- `native.SetVariable`

Notes / invariants:

- Callback recognition is name-based in `pathologic_lua_compiler`; `OnMouseLeave` is an engine event name.

### `OnLButtonUp(x: int, y: int) -> void`

Source: `scripts/player_inventory/widgets/inv_overhaul_drop_slot.lua`

Purpose: Handles the engine/UI `OnLButtonUp` callback for the drop slot runtime.

Parameters:

- `x: int` — pointer/layout coordinate interpreted by this function.
- `y: int` — pointer/layout coordinate interpreted by this function.

Returns:

None.

Side effects:

- Invokes engine/native operations: `native.SendMessageToParent`.

Called by:

- No in-repository caller was resolved; this may be an engine/XML callback or a conventionally public helper.

Calls:

- `native.SendMessageToParent`

Notes / invariants:

- Callback recognition is name-based in `pathologic_lua_compiler`; `OnLButtonUp` is an engine event name.

### `OnUIMessage(message: int, sender: string, data: object) -> void`

Source: `scripts/player_inventory/widgets/inv_overhaul_drop_slot.lua`

Purpose: Handles the engine/UI `OnUIMessage` callback for the drop slot runtime.

Parameters:

- `message: int` — numeric engine/UI protocol message.
- `sender: string` — name of the UI form that emitted the message.
- `data: object` — engine callback/UI payload object; shape depends on the message.

Returns:

None.

Side effects:

- Mutates module/task state: `slotWidth`, `slotHeight`, `highlighted`.

Called by:

- No in-repository caller was resolved; this may be an engine/XML callback or a conventionally public helper.

Calls:

- `UpdateBackground`

Notes / invariants:

- Callback recognition is name-based in `pathologic_lua_compiler`; `OnUIMessage` is an engine event name.


## Important constants

- `c_iTooltipMapObject: int = 5` — named behavior/layout value for tooltip map object.
- `c_iDropTooltipTextID: int = 1401` — localized string identifier for drop tooltip.

## Architectural notes

- No additional module-specific issue identified beyond repository-wide shared-variable and compiler-visible API constraints.
