# Inv Slot

## Source

`scripts/inventory_interface/inv_overhaul_inv_slot.lua`

DSL unit: `maintask InventoryOverhaulSlot`

## Responsibility

Renders one reusable inventory slot form and translates mouse interaction into controller protocol messages.

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

- `amount: int` — mutable runtime state for amount.
- `maxStackSize: int` — mutable runtime state for max stack size.
- `item: object` — engine object/vector storage for item; exact runtime shape follows its method usage.
- `image: string` — mutable runtime state for image.
- `disabled: bool` — lifecycle/behavior flag for disabled.
- `dragging: bool` — current interaction state for dragging.
- `selected: bool` — lifecycle/behavior flag for selected.
- `highlighted: bool` — current interaction state for highlighted.
- `hidden: bool` — lifecycle/behavior flag for hidden.
- `blocked: bool` — lifecycle/behavior flag for blocked.
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

Source: `scripts/inventory_interface/inv_overhaul_inv_slot.lua`

Purpose: Updates background in the inv slot subsystem.

Parameters:

None.

Returns:

None.

Side effects:

- Invokes engine/native operations: `native.SetBackground`.

Called by:

- `scripts/inventory_interface/inv_overhaul_inv_slot.lua :: OnLButtonDown`
- `scripts/inventory_interface/inv_overhaul_inv_slot.lua :: OnLButtonUp`
- `scripts/inventory_interface/inv_overhaul_inv_slot.lua :: OnDragEnd`
- `scripts/inventory_interface/inv_overhaul_inv_slot.lua :: OnMouseEnter`
- `scripts/inventory_interface/inv_overhaul_inv_slot.lua :: OnMouseMove`
- `scripts/inventory_interface/inv_overhaul_inv_slot.lua :: OnMouseLeave`
- `scripts/inventory_interface/inv_overhaul_inv_slot.lua :: OnUIMessage`

Calls:

- `native.SetBackground`

Notes / invariants:

- Maintask helper; callable within its task unless the engine invokes it by a documented callback name.

### `UpdateTooltip() -> void`

Source: `scripts/inventory_interface/inv_overhaul_inv_slot.lua`

Purpose: Updates tooltip in the inv slot subsystem.

Parameters:

None.

Returns:

None.

Side effects:

- Invokes engine/native operations: `native.SetTooltip`.

Called by:

- No in-repository caller was resolved; this may be an engine/XML callback or a conventionally public helper.

Calls:

- `native.SetTooltip`

Notes / invariants:

- Maintask helper; callable within its task unless the engine invokes it by a documented callback name.

### `EncodePointerMessage(base: int, x: int, y: int) -> int`

Source: `scripts/inventory_interface/inv_overhaul_inv_slot.lua`

Purpose: Encodes pointer message in the inv slot subsystem.

Parameters:

- `base: int` — value interpreted according to the function purpose; no narrower contract is established by current code.
- `x: int` — pointer/layout coordinate interpreted by this function.
- `y: int` — pointer/layout coordinate interpreted by this function.

Returns:

- `number` (integer) — result of: encodes pointer message in the inv slot subsystem.

Side effects:

- None directly observable beyond calls listed below.

Called by:

- `scripts/inventory_interface/inv_overhaul_inv_slot.lua :: OnLButtonUp`
- `scripts/inventory_interface/inv_overhaul_inv_slot.lua :: OnDragEnd`
- `scripts/inventory_interface/inv_overhaul_inv_slot.lua :: OnMouseMove`

Notes / invariants:

- Maintask helper; callable within its task unless the engine invokes it by a documented callback name.

### `IsInsideForm(x: int, y: int) -> bool`

Source: `scripts/inventory_interface/inv_overhaul_inv_slot.lua`

Purpose: Returns whether inside form in the inv slot subsystem.

Parameters:

- `x: int` — pointer/layout coordinate interpreted by this function.
- `y: int` — pointer/layout coordinate interpreted by this function.

Returns:

- `boolean` — result of: returns whether inside form in the inv slot subsystem.

Side effects:

- None directly observable beyond calls listed below.

Called by:

- `scripts/inventory_interface/inv_overhaul_inv_slot.lua :: OnLButtonUp`
- `scripts/inventory_interface/inv_overhaul_inv_slot.lua :: OnDragEnd`
- `scripts/inventory_interface/inv_overhaul_inv_slot.lua :: OnMouseMove`

Notes / invariants:

- Maintask helper; callable within its task unless the engine invokes it by a documented callback name.


## Events / callbacks

### `init() -> void`

Source: `scripts/inventory_interface/inv_overhaul_inv_slot.lua`

Purpose: Initializes the inv slot runtime and establishes its starting state and engine/UI integration.

Parameters:

None.

Returns:

None.

Side effects:

- Mutates module/task state: `item`, `amount`, `disabled`, `dragging`, `selected`, `highlighted`, `hidden`, `blocked`, `… and 6 more`.
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

Source: `scripts/inventory_interface/inv_overhaul_inv_slot.lua`

Purpose: Handles the engine/UI `OnDraw` callback for the inv slot runtime.

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

### `OnLButtonDown(x: int, y: int) -> void`

Source: `scripts/inventory_interface/inv_overhaul_inv_slot.lua`

Purpose: Handles the engine/UI `OnLButtonDown` callback for the inv slot runtime.

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

- `UpdateBackground`
- `native.SendMessageToParent`

Notes / invariants:

- Callback recognition is name-based in `pathologic_lua_compiler`; `OnLButtonDown` is an engine event name.

### `OnLButtonUp(x: int, y: int) -> void`

Source: `scripts/inventory_interface/inv_overhaul_inv_slot.lua`

Purpose: Handles the engine/UI `OnLButtonUp` callback for the inv slot runtime.

Parameters:

- `x: int` — pointer/layout coordinate interpreted by this function.
- `y: int` — pointer/layout coordinate interpreted by this function.

Returns:

None.

Side effects:

- Mutates module/task state: `highlighted`, `dragging`.
- Invokes engine/native operations: `native.SendMessageToParent`.

Called by:

- No in-repository caller was resolved; this may be an engine/XML callback or a conventionally public helper.

Calls:

- `IsInsideForm`
- `native.SendMessageToParent`
- `EncodePointerMessage`
- `UpdateBackground`

Notes / invariants:

- Callback recognition is name-based in `pathologic_lua_compiler`; `OnLButtonUp` is an engine event name.

### `OnRButtonDown(x: int, y: int) -> void`

Source: `scripts/inventory_interface/inv_overhaul_inv_slot.lua`

Purpose: Handles the engine/UI `OnRButtonDown` callback for the inv slot runtime.

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

Source: `scripts/inventory_interface/inv_overhaul_inv_slot.lua`

Purpose: Handles the engine/UI `OnDragBegin` callback for the inv slot runtime.

Parameters:

- `x: int` — pointer/layout coordinate interpreted by this function.
- `y: int` — pointer/layout coordinate interpreted by this function.

Returns:

None.

Side effects:

- Mutates module/task state: `dragging`.
- Invokes engine/native operations: `native.SendMessageToParent`.

Called by:

- No in-repository caller was resolved; this may be an engine/XML callback or a conventionally public helper.

Calls:

- `native.SendMessageToParent`

Notes / invariants:

- Callback recognition is name-based in `pathologic_lua_compiler`; `OnDragBegin` is an engine event name.

### `OnDragEnd(x: int, y: int, accepted: bool) -> void`

Source: `scripts/inventory_interface/inv_overhaul_inv_slot.lua`

Purpose: Handles the engine/UI `OnDragEnd` callback for the inv slot runtime.

Parameters:

- `x: int` — pointer/layout coordinate interpreted by this function.
- `y: int` — pointer/layout coordinate interpreted by this function.
- `accepted: bool` — behavior flag interpreted by this function.

Returns:

None.

Side effects:

- Mutates module/task state: `highlighted`.
- Invokes engine/native operations: `native.SendMessageToParent`.

Called by:

- No in-repository caller was resolved; this may be an engine/XML callback or a conventionally public helper.

Calls:

- `IsInsideForm`
- `native.SendMessageToParent`
- `EncodePointerMessage`
- `UpdateBackground`

Notes / invariants:

- Callback recognition is name-based in `pathologic_lua_compiler`; `OnDragEnd` is an engine event name.

### `OnMouseEnter() -> void`

Source: `scripts/inventory_interface/inv_overhaul_inv_slot.lua`

Purpose: Handles the engine/UI `OnMouseEnter` callback for the inv slot runtime.

Parameters:

None.

Returns:

None.

Side effects:

- Mutates module/task state: `highlighted`.
- Invokes engine/native operations: `native.SetTooltip`.

Called by:

- No in-repository caller was resolved; this may be an engine/XML callback or a conventionally public helper.

Calls:

- `UpdateBackground`
- `native.SetTooltip`

Notes / invariants:

- Callback recognition is name-based in `pathologic_lua_compiler`; `OnMouseEnter` is an engine event name.

### `OnMouseMove(x: int, y: int) -> void`

Source: `scripts/inventory_interface/inv_overhaul_inv_slot.lua`

Purpose: Handles the engine/UI `OnMouseMove` callback for the inv slot runtime.

Parameters:

- `x: int` — pointer/layout coordinate interpreted by this function.
- `y: int` — pointer/layout coordinate interpreted by this function.

Returns:

None.

Side effects:

- Mutates module/task state: `highlighted`.
- Invokes engine/native operations: `native.SendMessageToParent`.

Called by:

- No in-repository caller was resolved; this may be an engine/XML callback or a conventionally public helper.

Calls:

- `IsInsideForm`
- `UpdateBackground`
- `native.SendMessageToParent`
- `EncodePointerMessage`

Notes / invariants:

- Callback recognition is name-based in `pathologic_lua_compiler`; `OnMouseMove` is an engine event name.

### `OnMouseLeave() -> void`

Source: `scripts/inventory_interface/inv_overhaul_inv_slot.lua`

Purpose: Handles the engine/UI `OnMouseLeave` callback for the inv slot runtime.

Parameters:

None.

Returns:

None.

Side effects:

- Mutates module/task state: `highlighted`, `tooltipSuppressed`.
- Invokes engine/native operations: `native.SetTooltip`, `native.SendMessageToParent`.

Called by:

- No in-repository caller was resolved; this may be an engine/XML callback or a conventionally public helper.

Calls:

- `UpdateBackground`
- `native.SetTooltip`
- `native.SendMessageToParent`

Notes / invariants:

- Callback recognition is name-based in `pathologic_lua_compiler`; `OnMouseLeave` is an engine event name.

### `OnUIMessage(message: int, sender: string, data: object) -> void`

Source: `scripts/inventory_interface/inv_overhaul_inv_slot.lua`

Purpose: Handles the engine/UI `OnUIMessage` callback for the inv slot runtime.

Parameters:

- `message: int` — numeric engine/UI protocol message.
- `sender: string` — name of the UI form that emitted the message.
- `data: object` — engine callback/UI payload object; shape depends on the message.

Returns:

None.

Side effects:

- Mutates module/task state: `quickslot`, `slotWidth`, `slotHeight`, `highResolutionSprite`, `loadedItemID`, `tooltipSuppressed`, `hidden`, `highlighted`, `… and 5 more`.
- Invokes engine/native operations: `native.SetTooltip`, `native.SetBackground`, `native.LoadImage`.

Called by:

- No in-repository caller was resolved; this may be an engine/XML callback or a conventionally public helper.

Calls:

- `native.SetTooltip`
- `native.SetBackground`
- `UpdateBackground`
- `item.GetItemID`
- `native.GetInvItemSprite2`
- `native.GetInvItemSprite`
- `native.LoadImage`
- `native.GetInvItemMaxStackSize`

Notes / invariants:

- Callback recognition is name-based in `pathologic_lua_compiler`; `OnUIMessage` is an engine event name.


## Important constants

- `c_iTooltipNone: int = -1` — named behavior/layout value for tooltip none.
- `c_iTooltipInvObject: int = 1` — named behavior/layout value for tooltip inv object.
- `c_iSlotSelected: int = 16384` — named behavior/layout value for slot selected.
- `c_iSlotEmpty: int = 32768` — named behavior/layout value for slot empty.
- `c_iSlotNumber: int = 65536` — named behavior/layout value for slot number.
- `c_iSlotDisabled: int = 131072` — named behavior/layout value for slot disabled.
- `c_iSlotMask: int = 16383` — named behavior/layout value for slot mask.
- `c_iHoverMessageBase: int = 100000` — numeric engine/UI protocol value for hover message base.
- `c_iReleaseMessageBase: int = 200000` — numeric engine/UI protocol value for release message base.
- `c_iDragEndMessageBase: int = 300000` — numeric engine/UI protocol value for drag end message base.

## Architectural notes

- No additional module-specific issue identified beyond repository-wide shared-variable and compiler-visible API constraints.
