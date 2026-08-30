# Corpse Marker

## Source

`scripts/loot/widgets/inv_overhaul_corpse_marker.lua`

DSL unit: `maintask InvOverhaulCorpseMarker`

## Responsibility

Renders the corpse-only marker form according to controller messages.

## Dependencies

- No local DSL imports.
- Pathologic native API — engine state, object access, persistence variables, UI messaging, timing, or rendering as listed per function.

## Used by

- `resources/ui/inv_overhaul_corpse.xml` (runtime/XML script reference)
- `resources/ui/inv_overhaul_corpse_1024x768.xml` (runtime/XML script reference)
- `resources/ui/inv_overhaul_corpse_1280x1024.xml` (runtime/XML script reference)
- `resources/ui/inv_overhaul_corpse_1920x1080.xml` (runtime/XML script reference)

## State

- `active: bool` — lifecycle/behavior flag for active.
- `retryDelay: float` — timing state for retry delay.

## Public API

No importable module API. Runtime entry points are documented under Events / callbacks.

## Internal API

No additional maintask helpers.

## Events / callbacks

### `init() -> void`

Source: `scripts/loot/widgets/inv_overhaul_corpse_marker.lua`

Purpose: Initializes the corpse marker runtime and establishes its starting state and engine/UI integration.

Parameters:

None.

Returns:

None.

Side effects:

- Mutates module/task state: `active`, `retryDelay`.
- Invokes engine/native operations: `native.SetNeedUpdate`, `native.ProcessEvents`, `native.SendMessageToParent`.

Called by:

- No in-repository caller was resolved; this may be an engine/XML callback or a conventionally public helper.

Calls:

- `native.SetNeedUpdate`
- `native.ProcessEvents`
- `native.SendMessageToParent`

Notes / invariants:

- Maintask helper; callable within its task unless the engine invokes it by a documented callback name.

### `OnUpdate(delta: float) -> void`

Source: `scripts/loot/widgets/inv_overhaul_corpse_marker.lua`

Purpose: Handles the engine/UI `OnUpdate` callback for the corpse marker runtime.

Parameters:

- `delta: float` — elapsed update time in seconds.

Returns:

None.

Side effects:

- Mutates module/task state: `retryDelay`.
- Invokes engine/native operations: `native.SendMessageToParent`.

Called by:

- No in-repository caller was resolved; this may be an engine/XML callback or a conventionally public helper.

Calls:

- `native.SendMessageToParent`

Notes / invariants:

- Callback recognition is name-based in `pathologic_lua_compiler`; `OnUpdate` is an engine event name.

### `OnUIMessage(message: int, sender: string, data: object) -> void`

Source: `scripts/loot/widgets/inv_overhaul_corpse_marker.lua`

Purpose: Handles the engine/UI `OnUIMessage` callback for the corpse marker runtime.

Parameters:

- `message: int` — numeric engine/UI protocol message.
- `sender: string` — name of the UI form that emitted the message.
- `data: object` — engine callback/UI payload object; shape depends on the message.

Returns:

None.

Side effects:

- Mutates module/task state: `active`.
- Invokes engine/native operations: `native.SetNeedUpdate`, `native.Trace`.

Called by:

- No in-repository caller was resolved; this may be an engine/XML callback or a conventionally public helper.

Calls:

- `native.SetNeedUpdate`
- `native.Trace`

Notes / invariants:

- Callback recognition is name-based in `pathologic_lua_compiler`; `OnUIMessage` is an engine event name.


## Important constants

No module/task-level constants.

## Architectural notes

- No additional module-specific issue identified beyond repository-wide shared-variable and compiler-visible API constraints.
