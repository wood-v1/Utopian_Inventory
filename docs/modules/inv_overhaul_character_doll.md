# Character Doll

## Source

`scripts/player_inventory/widgets/inv_overhaul_character_doll.lua`

DSL unit: `maintask InvOverhaulCharacterDoll`

## Responsibility

Renders the branch-specific character silhouette and publishes doll/equipment hover and drag messages.

## Dependencies

- `inv_overhaul_inventory_protocol` — Defines and encodes the numeric UI message protocol shared by inventory forms and controllers.
- `inv_overhaul_inventory_geometry` — Maps supported window sizes and character branches to player-grid, equipment, money, paging, and doll hit-test geometry.
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

- `layoutWidth: int` — current or cached layout value for layout width.
- `layoutHeight: int` — current or cached layout value for layout height.
- `image: string` — mutable runtime state for image.
- `dollWidth: int` — current or cached layout value for doll width.
- `dollHeight: int` — current or cached layout value for doll height.
- `characterBranch: int` — mutable runtime state for character branch.
- `imageLoaded: bool` — lifecycle/behavior flag for image loaded.
- `firstDrawProfiled: bool` — lifecycle/behavior flag for first draw profiled.
- `debugEnabled: int` — cached global debug-logging flag used by performance traces.

## Public API

No importable module API. Runtime entry points are documented under Events / callbacks.

## Internal API

### `GetLeft() -> int`

Source: `scripts/player_inventory/widgets/inv_overhaul_character_doll.lua`

Purpose: Returns left in the character doll subsystem.

Parameters:

None.

Returns:

- `number` (integer) — result of: returns left in the character doll subsystem.

Side effects:

- Delegates to compiler-visible module APIs and inherits their documented side effects.

Called by:

- `scripts/player_inventory/widgets/inv_overhaul_character_doll.lua :: OnMouseMove`
- `scripts/player_inventory/widgets/inv_overhaul_character_doll.lua :: GetTargetAtLocalPoint`

Calls:

- `inv_overhaul_inventory_geometry.GetDollLeft`

Notes / invariants:

- Maintask helper; callable within its task unless the engine invokes it by a documented callback name.

### `GetTop() -> int`

Source: `scripts/player_inventory/widgets/inv_overhaul_character_doll.lua`

Purpose: Returns top in the character doll subsystem.

Parameters:

None.

Returns:

- `number` (integer) — result of: returns top in the character doll subsystem.

Side effects:

- Delegates to compiler-visible module APIs and inherits their documented side effects.

Called by:

- `scripts/player_inventory/widgets/inv_overhaul_character_doll.lua :: OnMouseMove`
- `scripts/player_inventory/widgets/inv_overhaul_character_doll.lua :: GetTargetAtLocalPoint`

Calls:

- `inv_overhaul_inventory_geometry.GetDollTop`

Notes / invariants:

- Maintask helper; callable within its task unless the engine invokes it by a documented callback name.

### `IsInside(x: int, y: int, left: int, top: int) -> bool`

Source: `scripts/player_inventory/widgets/inv_overhaul_character_doll.lua`

Purpose: Returns whether inside in the character doll subsystem.

Parameters:

- `x: int` — pointer/layout coordinate interpreted by this function.
- `y: int` — pointer/layout coordinate interpreted by this function.
- `left: int` — value interpreted according to the function purpose; no narrower contract is established by current code.
- `top: int` — value interpreted according to the function purpose; no narrower contract is established by current code.

Returns:

- `boolean` — result of: returns whether inside in the character doll subsystem.

Side effects:

- Delegates to compiler-visible module APIs and inherits their documented side effects.

Called by:

- No in-repository caller was resolved; this may be an engine/XML callback or a conventionally public helper.

Calls:

- `inv_overhaul_inventory_geometry.IsInsideRect`

Notes / invariants:

- Maintask helper; callable within its task unless the engine invokes it by a documented callback name.

### `HitsTarget(rawX: int, rawY: int, left: int, top: int) -> bool`

Source: `scripts/player_inventory/widgets/inv_overhaul_character_doll.lua`

Purpose: Returns whether target in the character doll subsystem.

Parameters:

- `rawX: int` — value interpreted according to the function purpose; no narrower contract is established by current code.
- `rawY: int` — value interpreted according to the function purpose; no narrower contract is established by current code.
- `left: int` — value interpreted according to the function purpose; no narrower contract is established by current code.
- `top: int` — value interpreted according to the function purpose; no narrower contract is established by current code.

Returns:

- `boolean` — result of: returns whether target in the character doll subsystem.

Side effects:

- Delegates to compiler-visible module APIs and inherits their documented side effects.

Called by:

- No in-repository caller was resolved; this may be an engine/XML callback or a conventionally public helper.

Calls:

- `inv_overhaul_inventory_geometry.IsInsideRect`

Notes / invariants:

- Maintask helper; callable within its task unless the engine invokes it by a documented callback name.

### `GetTargetMessage(globalX: int, globalY: int) -> int`

Source: `scripts/player_inventory/widgets/inv_overhaul_character_doll.lua`

Purpose: Returns target message in the character doll subsystem.

Parameters:

- `globalX: int` — pointer/layout coordinate interpreted by this function.
- `globalY: int` — pointer/layout coordinate interpreted by this function.

Returns:

- `number` (integer) — result of: returns target message in the character doll subsystem.

Side effects:

- Delegates to compiler-visible module APIs and inherits their documented side effects.

Called by:

- `scripts/player_inventory/widgets/inv_overhaul_character_doll.lua :: OnMouseMove`
- `scripts/player_inventory/widgets/inv_overhaul_character_doll.lua :: GetTargetAtLocalPoint`

Calls:

- `inv_overhaul_inventory_geometry.GetDollTargetMessage`

Notes / invariants:

- Maintask helper; callable within its task unless the engine invokes it by a documented callback name.

### `GetTargetAtLocalPoint(x: int, y: int) -> int`

Source: `scripts/player_inventory/widgets/inv_overhaul_character_doll.lua`

Purpose: Returns target at local point in the character doll subsystem.

Parameters:

- `x: int` — pointer/layout coordinate interpreted by this function.
- `y: int` — pointer/layout coordinate interpreted by this function.

Returns:

- `number` (integer) — result of: returns target at local point in the character doll subsystem.

Side effects:

- None directly observable beyond calls listed below.

Called by:

- `scripts/player_inventory/widgets/inv_overhaul_character_doll.lua :: OnLButtonDown`
- `scripts/player_inventory/widgets/inv_overhaul_character_doll.lua :: OnRButtonDown`
- `scripts/player_inventory/widgets/inv_overhaul_character_doll.lua :: OnDragBegin`

Calls:

- `GetTargetMessage`
- `GetLeft`
- `GetTop`

Notes / invariants:

- Maintask helper; callable within its task unless the engine invokes it by a documented callback name.


## Events / callbacks

### `init() -> void`

Source: `scripts/player_inventory/widgets/inv_overhaul_character_doll.lua`

Purpose: Initializes the character doll runtime and establishes its starting state and engine/UI integration.

Parameters:

None.

Returns:

None.

Side effects:

- Mutates module/task state: `debugEnabled`, `layoutWidth`, `layoutHeight`, `characterBranch`, `imageLoaded`, `firstDrawProfiled`, `image`.
- Invokes engine/native operations: `native.Trace`, `native.LoadImage`, `native.SetOwnerDraw`, `native.ProcessEvents`.

Called by:

- No in-repository caller was resolved; this may be an engine/XML callback or a conventionally public helper.

Calls:

- `native.GetVariable`
- `native.Trace`
- `native.GetWindowSize`
- `native.LoadImage`
- `native.SetOwnerDraw`
- `native.ProcessEvents`

Notes / invariants:

- Maintask helper; callable within its task unless the engine invokes it by a documented callback name.

### `OnDraw() -> void`

Source: `scripts/player_inventory/widgets/inv_overhaul_character_doll.lua`

Purpose: Handles the engine/UI `OnDraw` callback for the character doll runtime.

Parameters:

None.

Returns:

None.

Side effects:

- Mutates module/task state: `firstDrawProfiled`.
- Invokes engine/native operations: `native.Trace`, `native.StretchBlit`.

Called by:

- No in-repository caller was resolved; this may be an engine/XML callback or a conventionally public helper.

Calls:

- `native.Trace`
- `native.StretchBlit`

Notes / invariants:

- Callback recognition is name-based in `pathologic_lua_compiler`; `OnDraw` is an engine event name.

### `OnMouseMove(x: int, y: int) -> void`

Source: `scripts/player_inventory/widgets/inv_overhaul_character_doll.lua`

Purpose: Handles the engine/UI `OnMouseMove` callback for the character doll runtime.

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

- `GetLeft`
- `GetTop`
- `GetTargetMessage`
- `native.SendMessageToParent`

Notes / invariants:

- Callback recognition is name-based in `pathologic_lua_compiler`; `OnMouseMove` is an engine event name.

### `OnMouseLeave() -> void`

Source: `scripts/player_inventory/widgets/inv_overhaul_character_doll.lua`

Purpose: Handles the engine/UI `OnMouseLeave` callback for the character doll runtime.

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

### `OnLButtonDown(x: int, y: int) -> void`

Source: `scripts/player_inventory/widgets/inv_overhaul_character_doll.lua`

Purpose: Handles the engine/UI `OnLButtonDown` callback for the character doll runtime.

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

- `inv_overhaul_inventory_protocol.GetDollSourceMessage`
- `GetTargetAtLocalPoint`
- `native.Trace`
- `native.SendMessageToParent`

Notes / invariants:

- Callback recognition is name-based in `pathologic_lua_compiler`; `OnLButtonDown` is an engine event name.

### `OnRButtonDown(x: int, y: int) -> void`

Source: `scripts/player_inventory/widgets/inv_overhaul_character_doll.lua`

Purpose: Handles the engine/UI `OnRButtonDown` callback for the character doll runtime.

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

- `inv_overhaul_inventory_protocol.GetDollSourceMessage`
- `GetTargetAtLocalPoint`
- `native.Trace`
- `native.SendMessageToParent`

Notes / invariants:

- Callback recognition is name-based in `pathologic_lua_compiler`; `OnRButtonDown` is an engine event name.

### `OnDragBegin(x: int, y: int) -> void`

Source: `scripts/player_inventory/widgets/inv_overhaul_character_doll.lua`

Purpose: Handles the engine/UI `OnDragBegin` callback for the character doll runtime.

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

- `inv_overhaul_inventory_protocol.GetDollSourceMessage`
- `GetTargetAtLocalPoint`
- `native.SendMessageToParent`

Notes / invariants:

- Callback recognition is name-based in `pathologic_lua_compiler`; `OnDragBegin` is an engine event name.

### `OnLButtonUp(x: int, y: int) -> void`

Source: `scripts/player_inventory/widgets/inv_overhaul_character_doll.lua`

Purpose: Handles the engine/UI `OnLButtonUp` callback for the character doll runtime.

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

### `OnDragEnd(x: int, y: int, accepted: bool) -> void`

Source: `scripts/player_inventory/widgets/inv_overhaul_character_doll.lua`

Purpose: Handles the engine/UI `OnDragEnd` callback for the character doll runtime.

Parameters:

- `x: int` — pointer/layout coordinate interpreted by this function.
- `y: int` — pointer/layout coordinate interpreted by this function.
- `accepted: bool` — behavior flag interpreted by this function.

Returns:

None.

Side effects:

- Invokes engine/native operations: `native.SendMessageToParent`.

Called by:

- No in-repository caller was resolved; this may be an engine/XML callback or a conventionally public helper.

Calls:

- `native.SendMessageToParent`

Notes / invariants:

- Callback recognition is name-based in `pathologic_lua_compiler`; `OnDragEnd` is an engine event name.

### `OnUIMessage(message: int, sender: string, data: object) -> void`

Source: `scripts/player_inventory/widgets/inv_overhaul_character_doll.lua`

Purpose: Handles the engine/UI `OnUIMessage` callback for the character doll runtime.

Parameters:

- `message: int` — numeric engine/UI protocol message.
- `sender: string` — name of the UI form that emitted the message.
- `data: object` — engine callback/UI payload object; shape depends on the message.

Returns:

None.

Side effects:

- Mutates module/task state: `imageLoaded`, `layoutHeight`, `layoutWidth`.
- Invokes engine/native operations: `native.SetOwnerDraw`, `native.ReleaseImage`, `native.Trace`.

Called by:

- No in-repository caller was resolved; this may be an engine/XML callback or a conventionally public helper.

Calls:

- `native.SetOwnerDraw`
- `native.ReleaseImage`
- `native.Trace`

Notes / invariants:

- Callback recognition is name-based in `pathologic_lua_compiler`; `OnUIMessage` is an engine event name.


## Important constants

- `c_iBranchDanko: int = 0` — named behavior/layout value for branch danko.
- `c_iBranchBurah: int = 1` — named behavior/layout value for branch burah.
- `c_iBranchKlara: int = 2` — named behavior/layout value for branch klara.
- `c_iReleaseResources: int = -200` — named behavior/layout value for release resources.

## Architectural notes

- No additional module-specific issue identified beyond repository-wide shared-variable and compiler-visible API constraints.
