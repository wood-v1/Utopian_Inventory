# Inventory

## Source

`scripts/player_inventory/inv_overhaul_inventory.lua`

DSL unit: `maintask InventoryOverhaulUI`

## Responsibility

Is the player inventory UI maintask and forwards engine/UI callbacks into the player controller.

## Dependencies

- `inv_overhaul_inventory_sounds` — Plays the inventory-open sound immediately before the blocking UI event loop.

- `inv_overhaul_inventory_controller` — Orchestrates the player inventory screen: initialization, projection, incremental rendering, equipment, drag/drop, paging, quickslots, tooltips, persistence, and callback routing.

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

No module/task-level mutable state.

## Public API

No importable module API. Runtime entry points are documented under Events / callbacks.

## Internal API

No additional maintask helpers.

## Events / callbacks

### `init() -> void`

Source: `scripts/player_inventory/inv_overhaul_inventory.lua`

Purpose: Initializes the inventory runtime and establishes its starting state and engine/UI integration.

Parameters:

None.

Returns:

None.

Side effects:

- Delegates to compiler-visible module APIs and inherits their documented side effects.

Called by:

- No in-repository caller was resolved; this may be an engine/XML callback or a conventionally public helper.

Calls:

- `inv_overhaul_inventory_controller.PlayerControllerInitialize`

Notes / invariants:

- Maintask helper; callable within its task unless the engine invokes it by a documented callback name.

### `OnUpdate(delta: float) -> void`

Source: `scripts/player_inventory/inv_overhaul_inventory.lua`

Purpose: Handles the engine/UI `OnUpdate` callback for the inventory runtime.

Parameters:

- `delta: float` — elapsed update time in seconds.

Returns:

None.

Side effects:

- Delegates to compiler-visible module APIs and inherits their documented side effects.

Called by:

- No in-repository caller was resolved; this may be an engine/XML callback or a conventionally public helper.

Calls:

- `inv_overhaul_inventory_controller.RunFramePreparationStage`
- `inv_overhaul_inventory_controller.RunMetadataAndLoadingStage`
- `inv_overhaul_inventory_controller.RunPersistenceAndRefreshStage`
- `inv_overhaul_inventory_controller.RunDragHoverStage`

Notes / invariants:

- Callback recognition is name-based in `pathologic_lua_compiler`; `OnUpdate` is an engine event name.

### `OnUIMessage(message: int, sender: string, data: object) -> void`

Source: `scripts/player_inventory/inv_overhaul_inventory.lua`

Purpose: Handles the engine/UI `OnUIMessage` callback for the inventory runtime.

Parameters:

- `message: int` — numeric engine/UI protocol message.
- `sender: string` — name of the UI form that emitted the message.
- `data: object` — engine callback/UI payload object; shape depends on the message.

Returns:

None.

Side effects:

- Delegates to compiler-visible module APIs and inherits their documented side effects.

Called by:

- No in-repository caller was resolved; this may be an engine/XML callback or a conventionally public helper.

Calls:

- `inv_overhaul_inventory_controller.OnUIMessage`

Notes / invariants:

- Callback recognition is name-based in `pathologic_lua_compiler`; `OnUIMessage` is an engine event name.

### `OnLButtonDown(x: int, y: int) -> void`

Source: `scripts/player_inventory/inv_overhaul_inventory.lua`

Purpose: Handles the engine/UI `OnLButtonDown` callback for the inventory runtime.

Parameters:

- `x: int` — pointer/layout coordinate interpreted by this function.
- `y: int` — pointer/layout coordinate interpreted by this function.

Returns:

None.

Side effects:

- Delegates to compiler-visible module APIs and inherits their documented side effects.

Called by:

- No in-repository caller was resolved; this may be an engine/XML callback or a conventionally public helper.

Calls:

- `inv_overhaul_inventory_controller.OnLButtonDown`

Notes / invariants:

- Callback recognition is name-based in `pathologic_lua_compiler`; `OnLButtonDown` is an engine event name.

### `OnRButtonDown(x: int, y: int) -> void`

Source: `scripts/player_inventory/inv_overhaul_inventory.lua`

Purpose: Handles the engine/UI `OnRButtonDown` callback for the inventory runtime.

Parameters:

- `x: int` — pointer/layout coordinate interpreted by this function.
- `y: int` — pointer/layout coordinate interpreted by this function.

Returns:

None.

Side effects:

- Delegates to compiler-visible module APIs and inherits their documented side effects.

Called by:

- No in-repository caller was resolved; this may be an engine/XML callback or a conventionally public helper.

Calls:

- `inv_overhaul_inventory_controller.OnRButtonDown`

Notes / invariants:

- Callback recognition is name-based in `pathologic_lua_compiler`; `OnRButtonDown` is an engine event name.

### `OnMouseMove(x: int, y: int) -> void`

Source: `scripts/player_inventory/inv_overhaul_inventory.lua`

Purpose: Handles the engine/UI `OnMouseMove` callback for the inventory runtime.

Parameters:

- `x: int` — pointer/layout coordinate interpreted by this function.
- `y: int` — pointer/layout coordinate interpreted by this function.

Returns:

None.

Side effects:

- Delegates to compiler-visible module APIs and inherits their documented side effects.

Called by:

- No in-repository caller was resolved; this may be an engine/XML callback or a conventionally public helper.

Calls:

- `inv_overhaul_inventory_controller.OnMouseMove`

Notes / invariants:

- Callback recognition is name-based in `pathologic_lua_compiler`; `OnMouseMove` is an engine event name.

### `OnMouseLeave() -> void`

Source: `scripts/player_inventory/inv_overhaul_inventory.lua`

Purpose: Handles the engine/UI `OnMouseLeave` callback for the inventory runtime.

Parameters:

None.

Returns:

None.

Side effects:

- Delegates to compiler-visible module APIs and inherits their documented side effects.

Called by:

- No in-repository caller was resolved; this may be an engine/XML callback or a conventionally public helper.

Calls:

- `inv_overhaul_inventory_controller.OnMouseLeave`

Notes / invariants:

- Callback recognition is name-based in `pathologic_lua_compiler`; `OnMouseLeave` is an engine event name.

### `OnLButtonUp(x: int, y: int) -> void`

Source: `scripts/player_inventory/inv_overhaul_inventory.lua`

Purpose: Handles the engine/UI `OnLButtonUp` callback for the inventory runtime.

Parameters:

- `x: int` — pointer/layout coordinate interpreted by this function.
- `y: int` — pointer/layout coordinate interpreted by this function.

Returns:

None.

Side effects:

- Delegates to compiler-visible module APIs and inherits their documented side effects.

Called by:

- No in-repository caller was resolved; this may be an engine/XML callback or a conventionally public helper.

Calls:

- `inv_overhaul_inventory_controller.OnLButtonUp`

Notes / invariants:

- Callback recognition is name-based in `pathologic_lua_compiler`; `OnLButtonUp` is an engine event name.

### `OnChar(char: int) -> void`

Source: `scripts/player_inventory/inv_overhaul_inventory.lua`

Purpose: Handles the engine/UI `OnChar` callback for the inventory runtime.

Parameters:

- `char: int` — value interpreted according to the function purpose; no narrower contract is established by current code.

Returns:

None.

Side effects:

- Delegates to compiler-visible module APIs and inherits their documented side effects.

Called by:

- No in-repository caller was resolved; this may be an engine/XML callback or a conventionally public helper.

Calls:

- `inv_overhaul_inventory_controller.OnChar`

Notes / invariants:

- Callback recognition is name-based in `pathologic_lua_compiler`; `OnChar` is an engine event name.

### `OnKeyDown(key: int) -> void`

Source: `scripts/player_inventory/inv_overhaul_inventory.lua`

Purpose: Handles the engine/UI `OnKeyDown` callback for the inventory runtime.

Parameters:

- `key: int` — value interpreted according to the function purpose; no narrower contract is established by current code.

Returns:

None.

Side effects:

- Delegates to compiler-visible module APIs and inherits their documented side effects.

Called by:

- No in-repository caller was resolved; this may be an engine/XML callback or a conventionally public helper.

Calls:

- `inv_overhaul_inventory_controller.OnKeyDown`

Notes / invariants:

- Callback recognition is name-based in `pathologic_lua_compiler`; `OnKeyDown` is an engine event name.

### `OnKeyUp(key: int) -> void`

Source: `scripts/player_inventory/inv_overhaul_inventory.lua`

Purpose: Handles the engine/UI `OnKeyUp` callback for the inventory runtime.

Parameters:

- `key: int` — value interpreted according to the function purpose; no narrower contract is established by current code.

Returns:

None.

Side effects:

- Delegates to compiler-visible module APIs and inherits their documented side effects.

Called by:

- No in-repository caller was resolved; this may be an engine/XML callback or a conventionally public helper.

Calls:

- `inv_overhaul_inventory_controller.OnKeyUp`

Notes / invariants:

- Callback recognition is name-based in `pathologic_lua_compiler`; `OnKeyUp` is an engine event name.


## Important constants

No module/task-level constants.

## Architectural notes

- No additional module-specific issue identified beyond repository-wide shared-variable and compiler-visible API constraints.
