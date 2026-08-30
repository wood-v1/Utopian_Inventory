# Money Slot

## Source

`scripts/inventory_interface/inv_overhaul_money_slot.lua`

DSL unit: `maintask InvOverhaulMoneySlot`

## Responsibility

Renders the money slot and responds to money-display UI messages.

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

- `moneyAmount: int` — mutable runtime state for money amount.
- `moneySprite: string` — mutable runtime state for money sprite.
- `slotWidth: int` — current or cached layout value for slot width.
- `slotHeight: int` — current or cached layout value for slot height.
- `highResolutionSprite: bool` — lifecycle/behavior flag for high resolution sprite.

## Public API

No importable module API. Runtime entry points are documented under Events / callbacks.

## Internal API

### `InitSprite() -> void`

Source: `scripts/inventory_interface/inv_overhaul_money_slot.lua`

Purpose: Initializes sprite in the money slot subsystem.

Parameters:

None.

Returns:

None.

Side effects:

- Invokes engine/native operations: `native.LoadImage`, `native.Trace`.

Called by:

- `scripts/inventory_interface/inv_overhaul_money_slot.lua :: init`
- `scripts/inventory_interface/inv_overhaul_money_slot.lua :: OnUIMessage`

Calls:

- `native.GetInvItemByName`
- `native.GetInvItemSprite2`
- `native.GetInvItemSprite`
- `native.LoadImage`
- `native.Trace`

Notes / invariants:

- Maintask helper; callable within its task unless the engine invokes it by a documented callback name.


## Events / callbacks

### `init() -> void`

Source: `scripts/inventory_interface/inv_overhaul_money_slot.lua`

Purpose: Initializes the money slot runtime and establishes its starting state and engine/UI integration.

Parameters:

None.

Returns:

None.

Side effects:

- Mutates module/task state: `moneyAmount`, `moneySprite`, `highResolutionSprite`, `slotWidth`, `slotHeight`.
- Invokes engine/native operations: `native.SetBackground`, `native.SetOwnerDraw`, `native.ProcessEvents`.

Called by:

- No in-repository caller was resolved; this may be an engine/XML callback or a conventionally public helper.

Calls:

- `native.GetWindowSize`
- `InitSprite`
- `native.SetBackground`
- `native.SetOwnerDraw`
- `native.ProcessEvents`

Notes / invariants:

- Maintask helper; callable within its task unless the engine invokes it by a documented callback name.

### `OnDraw() -> void`

Source: `scripts/inventory_interface/inv_overhaul_money_slot.lua`

Purpose: Handles the engine/UI `OnDraw` callback for the money slot runtime.

Parameters:

None.

Returns:

None.

Side effects:

- Invokes engine/native operations: `native.StretchBlit`, `native.Blit`, `native.Print`.

Called by:

- No in-repository caller was resolved; this may be an engine/XML callback or a conventionally public helper.

Calls:

- `native.StretchBlit`
- `native.Blit`
- `native.Print`

Notes / invariants:

- Callback recognition is name-based in `pathologic_lua_compiler`; `OnDraw` is an engine event name.

### `OnUIMessage(message: int, sender: string, data: object) -> void`

Source: `scripts/inventory_interface/inv_overhaul_money_slot.lua`

Purpose: Handles the engine/UI `OnUIMessage` callback for the money slot runtime.

Parameters:

- `message: int` — numeric engine/UI protocol message.
- `sender: string` — name of the UI form that emitted the message.
- `data: object` — engine callback/UI payload object; shape depends on the message.

Returns:

None.

Side effects:

- Mutates module/task state: `slotWidth`, `slotHeight`, `highResolutionSprite`, `moneyAmount`.

Called by:

- No in-repository caller was resolved; this may be an engine/XML callback or a conventionally public helper.

Calls:

- `InitSprite`

Notes / invariants:

- Callback recognition is name-based in `pathologic_lua_compiler`; `OnUIMessage` is an engine event name.


## Important constants

No module/task-level constants.

## Architectural notes

- No additional module-specific issue identified beyond repository-wide shared-variable and compiler-visible API constraints.
