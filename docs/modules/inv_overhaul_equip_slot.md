# Equip Slot

## Source

`scripts/player_inventory/widgets/inv_overhaul_equip_slot.lua`

DSL unit: `maintask InvOverhaulEquipSlot`

## Responsibility

Renders one equipment target and publishes pointer, drag, and tooltip protocol messages.

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

- `item: object` — engine object/vector storage for item; exact runtime shape follows its method usage.
- `image: string` — mutable runtime state for image.
- `highlighted: bool` — current interaction state for highlighted.
- `label: string` — mutable runtime state for label.
- `loadedItemID: int` — mutable runtime state for loaded item id.
- `slotWidth: int` — current or cached layout value for slot width.
- `slotHeight: int` — current or cached layout value for slot height.
- `highResolutionSprite: bool` — lifecycle/behavior flag for high resolution sprite.
- `tooltipSuppressed: bool` — lifecycle/behavior flag for tooltip suppressed.
- `quickslot: int` — current or cached layout value for quickslot.

## Public API

No importable module API. Runtime entry points are documented under Events / callbacks.

## Internal API

### `UpdateBackground() -> void`

Source: `scripts/player_inventory/widgets/inv_overhaul_equip_slot.lua`

Purpose: Updates background in the equip slot subsystem.

Parameters:

None.

Returns:

None.

Side effects:

- Invokes engine/native operations: `native.SetBackground`.

Called by:

- `scripts/player_inventory/widgets/inv_overhaul_equip_slot.lua :: OnUIMessage`

Calls:

- `native.SetBackground`

Notes / invariants:

- Maintask helper; callable within its task unless the engine invokes it by a documented callback name.

### `UpdateTooltip() -> void`

Source: `scripts/player_inventory/widgets/inv_overhaul_equip_slot.lua`

Purpose: Updates tooltip in the equip slot subsystem.

Parameters:

None.

Returns:

None.

Side effects:

- Invokes engine/native operations: `native.SetTooltip`.

Called by:

- `scripts/player_inventory/widgets/inv_overhaul_equip_slot.lua :: OnMouseEnter`

Calls:

- `native.SetTooltip`

Notes / invariants:

- Maintask helper; callable within its task unless the engine invokes it by a documented callback name.

### `IsInside(x: int, y: int) -> bool`

Source: `scripts/player_inventory/widgets/inv_overhaul_equip_slot.lua`

Purpose: Returns whether inside in the equip slot subsystem.

Parameters:

- `x: int` — pointer/layout coordinate interpreted by this function.
- `y: int` — pointer/layout coordinate interpreted by this function.

Returns:

- `boolean` — result of: returns whether inside in the equip slot subsystem.

Side effects:

- None directly observable beyond calls listed below.

Called by:

- `scripts/player_inventory/widgets/inv_overhaul_equip_slot.lua :: OnLButtonUp`
- `scripts/player_inventory/widgets/inv_overhaul_equip_slot.lua :: OnDragEnd`

Notes / invariants:

- Maintask helper; callable within its task unless the engine invokes it by a documented callback name.


## Events / callbacks

### `init() -> void`

Source: `scripts/player_inventory/widgets/inv_overhaul_equip_slot.lua`

Purpose: Initializes the equip slot runtime and establishes its starting state and engine/UI integration.

Parameters:

None.

Returns:

None.

Side effects:

- Mutates module/task state: `item`, `image`, `highlighted`, `label`, `loadedItemID`, `highResolutionSprite`, `tooltipSuppressed`, `quickslot`, `… and 2 more`.
- Invokes engine/native operations: `native.SetBackground`, `native.SetOwnerDraw`, `native.ProcessEvents`.

Called by:

- No in-repository caller was resolved; this may be an engine/XML callback or a conventionally public helper.

Calls:

- `native.GetWindowSize`
- `native.SetBackground`
- `native.SetOwnerDraw`
- `native.ProcessEvents`

Notes / invariants:

- Maintask helper; callable within its task unless the engine invokes it by a documented callback name.

### `OnDraw() -> void`

Source: `scripts/player_inventory/widgets/inv_overhaul_equip_slot.lua`

Purpose: Handles the engine/UI `OnDraw` callback for the equip slot runtime.

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

### `OnMouseEnter() -> void`

Source: `scripts/player_inventory/widgets/inv_overhaul_equip_slot.lua`

Purpose: Handles the engine/UI `OnMouseEnter` callback for the equip slot runtime.

Parameters:

None.

Returns:

None.

Side effects:

- Invokes engine/native operations: `native.SendMessageToParent`.

Called by:

- No in-repository caller was resolved; this may be an engine/XML callback or a conventionally public helper.

Calls:

- `UpdateTooltip`
- `native.SendMessageToParent`

Notes / invariants:

- Callback recognition is name-based in `pathologic_lua_compiler`; `OnMouseEnter` is an engine event name.

### `OnMouseMove(x: int, y: int) -> void`

Source: `scripts/player_inventory/widgets/inv_overhaul_equip_slot.lua`

Purpose: Handles the engine/UI `OnMouseMove` callback for the equip slot runtime.

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

- Callback recognition is name-based in `pathologic_lua_compiler`; `OnMouseMove` is an engine event name.

### `OnMouseLeave() -> void`

Source: `scripts/player_inventory/widgets/inv_overhaul_equip_slot.lua`

Purpose: Handles the engine/UI `OnMouseLeave` callback for the equip slot runtime.

Parameters:

None.

Returns:

None.

Side effects:

- Mutates module/task state: `tooltipSuppressed`.
- Invokes engine/native operations: `native.SetTooltip`, `native.SendMessageToParent`.

Called by:

- No in-repository caller was resolved; this may be an engine/XML callback or a conventionally public helper.

Calls:

- `native.SetTooltip`
- `native.SendMessageToParent`

Notes / invariants:

- Callback recognition is name-based in `pathologic_lua_compiler`; `OnMouseLeave` is an engine event name.

### `OnLButtonUp(x: int, y: int) -> void`

Source: `scripts/player_inventory/widgets/inv_overhaul_equip_slot.lua`

Purpose: Handles the engine/UI `OnLButtonUp` callback for the equip slot runtime.

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

- `IsInside`
- `native.SendMessageToParent`

Notes / invariants:

- Callback recognition is name-based in `pathologic_lua_compiler`; `OnLButtonUp` is an engine event name.

### `OnLButtonDown(x: int, y: int) -> void`

Source: `scripts/player_inventory/widgets/inv_overhaul_equip_slot.lua`

Purpose: Handles the engine/UI `OnLButtonDown` callback for the equip slot runtime.

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

- Callback recognition is name-based in `pathologic_lua_compiler`; `OnLButtonDown` is an engine event name.

### `OnRButtonDown(x: int, y: int) -> void`

Source: `scripts/player_inventory/widgets/inv_overhaul_equip_slot.lua`

Purpose: Handles the engine/UI `OnRButtonDown` callback for the equip slot runtime.

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

- Callback recognition is name-based in `pathologic_lua_compiler`; `OnRButtonDown` is an engine event name.

### `OnDragBegin(x: int, y: int) -> void`

Source: `scripts/player_inventory/widgets/inv_overhaul_equip_slot.lua`

Purpose: Handles the engine/UI `OnDragBegin` callback for the equip slot runtime.

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

- Callback recognition is name-based in `pathologic_lua_compiler`; `OnDragBegin` is an engine event name.

### `OnDragEnd(x: int, y: int, accepted: bool) -> void`

Source: `scripts/player_inventory/widgets/inv_overhaul_equip_slot.lua`

Purpose: Handles the engine/UI `OnDragEnd` callback for the equip slot runtime.

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

- `IsInside`
- `native.SendMessageToParent`

Notes / invariants:

- Callback recognition is name-based in `pathologic_lua_compiler`; `OnDragEnd` is an engine event name.

### `OnUIMessage(message: int, sender: string, data: object) -> void`

Source: `scripts/player_inventory/widgets/inv_overhaul_equip_slot.lua`

Purpose: Handles the engine/UI `OnUIMessage` callback for the equip slot runtime.

Parameters:

- `message: int` — numeric engine/UI protocol message.
- `sender: string` — name of the UI form that emitted the message.
- `data: object` — engine callback/UI payload object; shape depends on the message.

Returns:

None.

Side effects:

- Mutates module/task state: `quickslot`, `slotWidth`, `slotHeight`, `highResolutionSprite`, `loadedItemID`, `tooltipSuppressed`, `highlighted`, `label`, `… and 1 more`.
- Invokes engine/native operations: `native.SetTooltip`, `native.LoadImage`.

Called by:

- No in-repository caller was resolved; this may be an engine/XML callback or a conventionally public helper.

Calls:

- `native.SetTooltip`
- `UpdateBackground`
- `item.GetItemID`
- `native.GetInvItemSprite2`
- `native.GetInvItemSprite`
- `native.LoadImage`

Notes / invariants:

- Callback recognition is name-based in `pathologic_lua_compiler`; `OnUIMessage` is an engine event name.


## Important constants

- `c_iTooltipNone: int = -1` — named behavior/layout value for tooltip none.
- `c_iTooltipInvObject: int = 1` — named behavior/layout value for tooltip inv object.
- `c_iSlotEmpty: int = 32768` — named behavior/layout value for slot empty.

## Architectural notes

- No additional module-specific issue identified beyond repository-wide shared-variable and compiler-visible API constraints.
