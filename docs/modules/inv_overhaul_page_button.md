# Page Button

## Source

`scripts/inventory_interface/inv_overhaul_page_button.lua`

DSL unit: `maintask InvOverhaulPageButton`

## Responsibility

Renders and emits interaction messages for one previous/next page button.

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

- `label: string` — mutable runtime state for label.
- `highlighted: bool` — current interaction state for highlighted.
- `visible: bool` — lifecycle/behavior flag for visible.
- `enabled: bool` — lifecycle/behavior flag for enabled.
- `hoverTarget: int` — mutable runtime state for hover target.

## Public API

No importable module API. Runtime entry points are documented under Events / callbacks.

## Internal API

### `UpdateBackground() -> void`

Source: `scripts/inventory_interface/inv_overhaul_page_button.lua`

Purpose: Updates background in the page button subsystem.

Parameters:

None.

Returns:

None.

Side effects:

- Invokes engine/native operations: `native.SetBackground`.

Called by:

- `scripts/inventory_interface/inv_overhaul_page_button.lua :: OnMouseEnter`
- `scripts/inventory_interface/inv_overhaul_page_button.lua :: OnMouseLeave`
- `scripts/inventory_interface/inv_overhaul_page_button.lua :: OnUIMessage`

Calls:

- `native.SetBackground`

Notes / invariants:

- Maintask helper; callable within its task unless the engine invokes it by a documented callback name.


## Events / callbacks

### `init() -> void`

Source: `scripts/inventory_interface/inv_overhaul_page_button.lua`

Purpose: Initializes the page button runtime and establishes its starting state and engine/UI integration.

Parameters:

None.

Returns:

None.

Side effects:

- Mutates module/task state: `label`, `highlighted`, `visible`, `enabled`, `hoverTarget`.
- Invokes engine/native operations: `native.SetTooltip`, `native.SetBackground`, `native.SetOwnerDraw`, `native.ProcessEvents`.

Called by:

- No in-repository caller was resolved; this may be an engine/XML callback or a conventionally public helper.

Calls:

- `native.SetTooltip`
- `native.SetBackground`
- `native.SetOwnerDraw`
- `native.ProcessEvents`

Notes / invariants:

- Maintask helper; callable within its task unless the engine invokes it by a documented callback name.

### `OnDraw() -> void`

Source: `scripts/inventory_interface/inv_overhaul_page_button.lua`

Purpose: Handles the engine/UI `OnDraw` callback for the page button runtime.

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

Source: `scripts/inventory_interface/inv_overhaul_page_button.lua`

Purpose: Handles the engine/UI `OnMouseEnter` callback for the page button runtime.

Parameters:

None.

Returns:

None.

Side effects:

- Mutates module/task state: `highlighted`.
- Writes shared engine variable(s): `"inv_overhaul_inventory_tooltip_item"`, `"inv_overhaul_inventory_tooltip_text_id"`, `"inv_overhaul_inventory_tooltip_type"`, `"inv_overhaul_inventory_page_hover"`.
- Invokes engine/native operations: `native.Trace`, `native.SetVariable`, `native.SendMessageToParent`.

Called by:

- No in-repository caller was resolved; this may be an engine/XML callback or a conventionally public helper.

Calls:

- `native.Trace`
- `native.SetVariable`
- `UpdateBackground`
- `native.SendMessageToParent`

Notes / invariants:

- Callback recognition is name-based in `pathologic_lua_compiler`; `OnMouseEnter` is an engine event name.

### `OnMouseLeave() -> void`

Source: `scripts/inventory_interface/inv_overhaul_page_button.lua`

Purpose: Handles the engine/UI `OnMouseLeave` callback for the page button runtime.

Parameters:

None.

Returns:

None.

Side effects:

- Mutates module/task state: `highlighted`.
- Writes shared engine variable(s): `"inv_overhaul_inventory_page_hover"`.
- Invokes engine/native operations: `native.Trace`, `native.SetVariable`, `native.SendMessageToParent`.

Called by:

- No in-repository caller was resolved; this may be an engine/XML callback or a conventionally public helper.

Calls:

- `native.Trace`
- `UpdateBackground`
- `native.SetVariable`
- `native.SendMessageToParent`

Notes / invariants:

- Callback recognition is name-based in `pathologic_lua_compiler`; `OnMouseLeave` is an engine event name.

### `OnLButtonDown(x: int, y: int) -> void`

Source: `scripts/inventory_interface/inv_overhaul_page_button.lua`

Purpose: Handles the engine/UI `OnLButtonDown` callback for the page button runtime.

Parameters:

- `x: int` — pointer/layout coordinate interpreted by this function.
- `y: int` — pointer/layout coordinate interpreted by this function.

Returns:

None.

Side effects:

- Invokes engine/native operations: `native.Trace`, `native.SendMessageToParent`.

Called by:

- No in-repository caller was resolved; this may be an engine/XML callback or a conventionally public helper.

Calls:

- `native.Trace`
- `native.SendMessageToParent`

Notes / invariants:

- Callback recognition is name-based in `pathologic_lua_compiler`; `OnLButtonDown` is an engine event name.

### `OnLButtonUp(x: int, y: int) -> void`

Source: `scripts/inventory_interface/inv_overhaul_page_button.lua`

Purpose: Handles the engine/UI `OnLButtonUp` callback for the page button runtime.

Parameters:

- `x: int` — pointer/layout coordinate interpreted by this function.
- `y: int` — pointer/layout coordinate interpreted by this function.

Returns:

None.

Side effects:

- Invokes engine/native operations: `native.Trace`.

Called by:

- No in-repository caller was resolved; this may be an engine/XML callback or a conventionally public helper.

Calls:

- `native.Trace`

Notes / invariants:

- Callback recognition is name-based in `pathologic_lua_compiler`; `OnLButtonUp` is an engine event name.

### `OnUIMessage(message: int, sender: string, data: object) -> void`

Source: `scripts/inventory_interface/inv_overhaul_page_button.lua`

Purpose: Handles the engine/UI `OnUIMessage` callback for the page button runtime.

Parameters:

- `message: int` — numeric engine/UI protocol message.
- `sender: string` — name of the UI form that emitted the message.
- `data: object` — engine callback/UI payload object; shape depends on the message.

Returns:

None.

Side effects:

- Mutates module/task state: `hoverTarget`, `label`, `visible`, `highlighted`, `enabled`.
- Writes shared engine variable(s): `"inv_overhaul_inventory_page_hover"`.
- Invokes engine/native operations: `native.SetTooltip`, `native.SetVariable`.

Called by:

- No in-repository caller was resolved; this may be an engine/XML callback or a conventionally public helper.

Calls:

- `native.SetTooltip`
- `UpdateBackground`
- `native.SetVariable`

Notes / invariants:

- Callback recognition is name-based in `pathologic_lua_compiler`; `OnUIMessage` is an engine event name.


## Important constants

- `c_iTooltipNone: int = -1` — named behavior/layout value for tooltip none.

## Architectural notes

- No additional module-specific issue identified beyond repository-wide shared-variable and compiler-visible API constraints.
