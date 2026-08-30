# Quickslot Help

## Source

`scripts/inventory_interface/inv_overhaul_quickslot_help.lua`

DSL unit: `maintask InvOverhaulQuickslotHelp`

## Responsibility

Publishes the quickslot-help tooltip from its hoverable UI form.

## Dependencies

- No local DSL imports.
- Pathologic native API — engine state, object access, persistence variables, UI messaging, timing, or rendering as listed per function.

## Used by

- No local import or direct runtime reference was resolved. It may be retained for external/save compatibility.

## State

- `tooltip: string` — mutable runtime state for tooltip.

## Public API

No importable module API. Runtime entry points are documented under Events / callbacks.

## Internal API

### `PublishTooltip() -> void`

Source: `scripts/inventory_interface/inv_overhaul_quickslot_help.lua`

Purpose: Publishes tooltip in the quickslot help subsystem.

Parameters:

None.

Returns:

None.

Side effects:

- Writes shared engine variable(s): `"inv_overhaul_inventory_tooltip_item"`, `"inv_overhaul_inventory_tooltip_text_id"`, `"inv_overhaul_inventory_tooltip_type"`.
- Invokes engine/native operations: `native.SetVariable`, `native.SetTooltip`.

Called by:

- `scripts/inventory_interface/inv_overhaul_quickslot_help.lua :: OnMouseEnter`
- `scripts/inventory_interface/inv_overhaul_quickslot_help.lua :: OnMouseMove`

Calls:

- `native.SetVariable`
- `native.SetTooltip`

Notes / invariants:

- Maintask helper; callable within its task unless the engine invokes it by a documented callback name.


## Events / callbacks

### `init() -> void`

Source: `scripts/inventory_interface/inv_overhaul_quickslot_help.lua`

Purpose: Initializes the quickslot help runtime and establishes its starting state and engine/UI integration.

Parameters:

None.

Returns:

None.

Side effects:

- Invokes engine/native operations: `native.SetBackground`, `native.SetTooltip`, `native.ProcessEvents`.

Called by:

- No in-repository caller was resolved; this may be an engine/XML callback or a conventionally public helper.

Calls:

- `native.SetBackground`
- `native.GetStringByID`
- `native.SetTooltip`
- `native.ProcessEvents`

Notes / invariants:

- Maintask helper; callable within its task unless the engine invokes it by a documented callback name.

### `OnMouseEnter() -> void`

Source: `scripts/inventory_interface/inv_overhaul_quickslot_help.lua`

Purpose: Handles the engine/UI `OnMouseEnter` callback for the quickslot help runtime.

Parameters:

None.

Returns:

None.

Side effects:

- None directly observable beyond calls listed below.

Called by:

- No in-repository caller was resolved; this may be an engine/XML callback or a conventionally public helper.

Calls:

- `PublishTooltip`

Notes / invariants:

- Callback recognition is name-based in `pathologic_lua_compiler`; `OnMouseEnter` is an engine event name.

### `OnMouseMove(x: int, y: int) -> void`

Source: `scripts/inventory_interface/inv_overhaul_quickslot_help.lua`

Purpose: Handles the engine/UI `OnMouseMove` callback for the quickslot help runtime.

Parameters:

- `x: int` — pointer/layout coordinate interpreted by this function.
- `y: int` — pointer/layout coordinate interpreted by this function.

Returns:

None.

Side effects:

- None directly observable beyond calls listed below.

Called by:

- No in-repository caller was resolved; this may be an engine/XML callback or a conventionally public helper.

Calls:

- `PublishTooltip`

Notes / invariants:

- Callback recognition is name-based in `pathologic_lua_compiler`; `OnMouseMove` is an engine event name.

### `OnMouseLeave() -> void`

Source: `scripts/inventory_interface/inv_overhaul_quickslot_help.lua`

Purpose: Handles the engine/UI `OnMouseLeave` callback for the quickslot help runtime.

Parameters:

None.

Returns:

None.

Side effects:

- None directly observable beyond calls listed below.

Called by:

- No in-repository caller was resolved; this may be an engine/XML callback or a conventionally public helper.

Notes / invariants:

- Callback recognition is name-based in `pathologic_lua_compiler`; `OnMouseLeave` is an engine event name.


## Important constants

- `c_iTooltipMapObject: int = 5` — named behavior/layout value for tooltip map object.
- `c_iQuickslotHelpTextID: int = 1407` — localized string identifier for quickslot help.

## Architectural notes

- No additional module-specific issue identified beyond repository-wide shared-variable and compiler-visible API constraints.
