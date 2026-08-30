# Loot Doll

## Source

`scripts/loot/widgets/inv_overhaul_loot_doll.lua`

DSL unit: `maintask InvOverhaulLootDoll`

## Responsibility

Renders the container/corpse silhouette selected by controller messages.

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

## State

No module/task-level mutable state.

## Public API

No importable module API. Runtime entry points are documented under Events / callbacks.

## Internal API

No additional maintask helpers.

## Events / callbacks

### `init() -> void`

Source: `scripts/loot/widgets/inv_overhaul_loot_doll.lua`

Purpose: Initializes the loot doll runtime and establishes its starting state and engine/UI integration.

Parameters:

None.

Returns:

None.

Side effects:

- Invokes engine/native operations: `native.SetBackground`, `native.ProcessEvents`.

Called by:

- No in-repository caller was resolved; this may be an engine/XML callback or a conventionally public helper.

Calls:

- `native.SetBackground`
- `native.ProcessEvents`

Notes / invariants:

- Maintask helper; callable within its task unless the engine invokes it by a documented callback name.

### `OnUIMessage(message: int, sender: string, data: object) -> void`

Source: `scripts/loot/widgets/inv_overhaul_loot_doll.lua`

Purpose: Handles the engine/UI `OnUIMessage` callback for the loot doll runtime.

Parameters:

- `message: int` — numeric engine/UI protocol message.
- `sender: string` — name of the UI form that emitted the message.
- `data: object` — engine callback/UI payload object; shape depends on the message.

Returns:

None.

Side effects:

- Invokes engine/native operations: `native.SetBackground`.

Called by:

- No in-repository caller was resolved; this may be an engine/XML callback or a conventionally public helper.

Calls:

- `native.SetBackground`

Notes / invariants:

- Callback recognition is name-based in `pathologic_lua_compiler`; `OnUIMessage` is an engine event name.


## Important constants

No module/task-level constants.

## Architectural notes

- No additional module-specific issue identified beyond repository-wide shared-variable and compiler-visible API constraints.
