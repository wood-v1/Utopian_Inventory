# Inventory Background

## Source

`scripts/inventory_interface/inv_overhaul_inventory_background.lua`

DSL unit: `maintask InventoryOverhaulBackground`

## Responsibility

Renders the shared panel background and forwards panel-level pointer events to the owning controller.

## Dependencies

- `inv_overhaul_inventory_geometry` — Maps supported window sizes and character branches to player-grid, equipment, money, paging, and doll hit-test geometry.
- `inv_overhaul_inventory_protocol` — Defines and encodes the numeric UI message protocol shared by inventory forms and controllers.
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

- `image: string` — mutable runtime state for image.
- `characterBranch: int` — mutable runtime state for character branch.
- `emptyImage: string` — mutable runtime state for empty image.
- `occupiedImage: string` — mutable runtime state for occupied image.
- `targetImage: string` — mutable runtime state for target image.
- `quickslotHelpImage: string` — current or cached layout value for quickslot help image.
- `panelWidth: int` — current or cached layout value for panel width.
- `panelHeight: int` — current or cached layout value for panel height.
- `rootWidth: int` — current or cached layout value for root width.
- `rootHeight: int` — current or cached layout value for root height.
- `tooltipActive: bool` — lifecycle/behavior flag for tooltip active.
- `itemIDs: object` — engine object/vector storage for item ids; exact runtime shape follows its method usage.
- `amounts: object` — engine object/vector storage for amounts; exact runtime shape follows its method usage.
- `quickslots: object` — current or cached layout value for quickslots.
- `hiddenSlots: object` — current or cached layout value for hidden slots.
- `highlightedSlots: object` — current interaction state for highlighted slots.
- `sprites: object` — engine object/vector storage for sprites; exact runtime shape follows its method usage.
- `loadedImages: object` — engine object/vector storage for loaded images; exact runtime shape follows its method usage.
- `resourcesReleased: bool` — lifecycle/behavior flag for resources released.
- `firstDrawProfiled: bool` — lifecycle/behavior flag for first draw profiled.
- `gridEnabled: bool` — lifecycle/behavior flag for grid enabled.
- `helpHoverActive: bool` — lifecycle/behavior flag for help hover active.
- `perfDiagnostics: int` — mutable runtime state for perf diagnostics.

## Public API

No importable module API. Runtime entry points are documented under Events / callbacks.

## Internal API

### `LoadTrackedImage(path: string) -> void`

Source: `scripts/inventory_interface/inv_overhaul_inventory_background.lua`

Purpose: Loads tracked image in the inventory background subsystem.

Parameters:

- `path: string` — value interpreted according to the function purpose; no narrower contract is established by current code.

Returns:

None.

Side effects:

- Invokes engine/native operations: `native.LoadImage`.
- May mutate engine/UI objects through: `loadedImages.add`.

Called by:

- `scripts/inventory_interface/inv_overhaul_inventory_background.lua :: init`
- `scripts/inventory_interface/inv_overhaul_inventory_background.lua :: HandleGridRendererMessage`

Calls:

- `loadedImages.size`
- `loadedImages.get`
- `native.LoadImage`
- `loadedImages.add`

Notes / invariants:

- Maintask helper; callable within its task unless the engine invokes it by a documented callback name.

### `ReleaseTrackedImages() -> void`

Source: `scripts/inventory_interface/inv_overhaul_inventory_background.lua`

Purpose: Releases tracked images in the inventory background subsystem.

Parameters:

None.

Returns:

None.

Side effects:

- Mutates module/task state: `resourcesReleased`, `gridEnabled`, `helpHoverActive`.
- Invokes engine/native operations: `native.SetOwnerDraw`, `native.ReleaseImage`, `native.Trace`.
- May mutate engine/UI objects through: `loadedImages.clear`.

Called by:

- `scripts/inventory_interface/inv_overhaul_inventory_background.lua :: OnUIMessage`

Calls:

- `native.SetOwnerDraw`
- `loadedImages.size`
- `loadedImages.get`
- `native.ReleaseImage`
- `loadedImages.clear`
- `native.Trace`

Notes / invariants:

- Maintask helper; callable within its task unless the engine invokes it by a documented callback name.

### `GetPanelLeft() -> int`

Source: `scripts/inventory_interface/inv_overhaul_inventory_background.lua`

Purpose: Returns panel left in the inventory background subsystem.

Parameters:

None.

Returns:

- `number` (integer) — result of: returns panel left in the inventory background subsystem.

Side effects:

- None directly observable beyond calls listed below.

Called by:

- `scripts/inventory_interface/inv_overhaul_inventory_background.lua :: SendPointer`
- `scripts/inventory_interface/inv_overhaul_inventory_background.lua :: DrawSlot`

Notes / invariants:

- Maintask helper; callable within its task unless the engine invokes it by a documented callback name.

### `GetPanelTop() -> int`

Source: `scripts/inventory_interface/inv_overhaul_inventory_background.lua`

Purpose: Returns panel top in the inventory background subsystem.

Parameters:

None.

Returns:

- `number` (integer) — result of: returns panel top in the inventory background subsystem.

Side effects:

- None directly observable beyond calls listed below.

Called by:

- `scripts/inventory_interface/inv_overhaul_inventory_background.lua :: SendPointer`
- `scripts/inventory_interface/inv_overhaul_inventory_background.lua :: DrawSlot`

Notes / invariants:

- Maintask helper; callable within its task unless the engine invokes it by a documented callback name.

### `SendPointer(base: int, x: int, y: int) -> void`

Source: `scripts/inventory_interface/inv_overhaul_inventory_background.lua`

Purpose: Sends pointer in the inventory background subsystem.

Parameters:

- `base: int` — value interpreted according to the function purpose; no narrower contract is established by current code.
- `x: int` — pointer/layout coordinate interpreted by this function.
- `y: int` — pointer/layout coordinate interpreted by this function.

Returns:

None.

Side effects:

- Invokes engine/native operations: `native.SendMessageToParent`.

Called by:

- `scripts/inventory_interface/inv_overhaul_inventory_background.lua :: OnMouseMove`
- `scripts/inventory_interface/inv_overhaul_inventory_background.lua :: OnLButtonDown`
- `scripts/inventory_interface/inv_overhaul_inventory_background.lua :: OnLButtonUp`
- `scripts/inventory_interface/inv_overhaul_inventory_background.lua :: OnRButtonDown`
- `scripts/inventory_interface/inv_overhaul_inventory_background.lua :: OnDragBegin`
- `scripts/inventory_interface/inv_overhaul_inventory_background.lua :: OnDragEnd`

Calls:

- `GetPanelLeft`
- `GetPanelTop`
- `native.SendMessageToParent`
- `inv_overhaul_inventory_protocol.EncodePanelPointer`

Notes / invariants:

- Maintask helper; callable within its task unless the engine invokes it by a documented callback name.

### `DrawSlot(slot: int) -> void`

Source: `scripts/inventory_interface/inv_overhaul_inventory_background.lua`

Purpose: Draws slot in the inventory background subsystem.

Parameters:

- `slot: int` — slot index or encoded slot target interpreted by this function.

Returns:

None.

Side effects:

- Invokes engine/native operations: `native.StretchBlit`, `native.Print`.

Called by:

- `scripts/inventory_interface/inv_overhaul_inventory_background.lua :: OnDraw`

Calls:

- `inv_overhaul_inventory_geometry.InterfaceGeometryGetGridColumns`
- `inv_overhaul_inventory_geometry.GetSlotSize`
- `inv_overhaul_inventory_geometry.InterfaceGeometryGetGridStartX`
- `GetPanelLeft`
- `inv_overhaul_inventory_geometry.InterfaceGeometryGetGridStep`
- `inv_overhaul_inventory_geometry.InterfaceGeometryGetGridStartY`
- `GetPanelTop`
- `hiddenSlots.get`
- `itemIDs.get`
- `native.StretchBlit`
- `sprites.get`
- `amounts.get`
- `… and 3 more`

Notes / invariants:

- Maintask helper; callable within its task unless the engine invokes it by a documented callback name.

### `HandleGridRendererMessage(message: int, data: object) -> bool`

Source: `scripts/inventory_interface/inv_overhaul_inventory_background.lua`

Purpose: Handles grid renderer message in the inventory background subsystem.

Parameters:

- `message: int` — numeric engine/UI protocol message.
- `data: object` — engine callback/UI payload object; shape depends on the message.

Returns:

- `boolean` — result of: handles grid renderer message in the inventory background subsystem.

Side effects:

- May mutate engine/UI objects through: `highlightedSlots.set`, `hiddenSlots.set`, `itemIDs.set`, `amounts.set`, `quickslots.set`, `sprites.set`.

Called by:

- `scripts/inventory_interface/inv_overhaul_inventory_background.lua :: OnUIMessage`

Calls:

- `inv_overhaul_inventory_protocol.DecodeGridRendererSlot`
- `inv_overhaul_inventory_protocol.DecodeGridRendererOperation`
- `inv_overhaul_inventory_protocol.DecodeGridRendererValue`
- `highlightedSlots.set`
- `hiddenSlots.set`
- `itemIDs.set`
- `amounts.set`
- `quickslots.set`
- `data.GetItemID`
- `itemIDs.get`
- `native.GetInvItemSprite2`
- `LoadTrackedImage`
- `… and 1 more`

Notes / invariants:

- Maintask helper; callable within its task unless the engine invokes it by a documented callback name.


## Events / callbacks

### `init() -> void`

Source: `scripts/inventory_interface/inv_overhaul_inventory_background.lua`

Purpose: Initializes the inventory background runtime and establishes its starting state and engine/UI integration.

Parameters:

None.

Returns:

None.

Side effects:

- Mutates module/task state: `perfDiagnostics`, `characterBranch`, `image`, `emptyImage`, `occupiedImage`, `targetImage`, `quickslotHelpImage`, `resourcesReleased`, `… and 6 more`.
- Writes shared engine variable(s): `"inv_overhaul_inventory_tooltip_item"`, `"inv_overhaul_inventory_tooltip_type"`.
- Invokes engine/native operations: `native.Trace`, `native.CreateIntVector`, `native.CreateStringVector`, `native.SetVariable`, `native.SetOwnerDraw`, `native.ProcessEvents`, `native.SendMessageToParent`.
- May mutate engine/UI objects through: `itemIDs.add`, `amounts.add`, `quickslots.add`, `hiddenSlots.add`, `highlightedSlots.add`, `sprites.add`.

Called by:

- No in-repository caller was resolved; this may be an engine/XML callback or a conventionally public helper.

Calls:

- `native.GetVariable`
- `native.Trace`
- `native.CreateIntVector`
- `native.CreateStringVector`
- `itemIDs.add`
- `amounts.add`
- `quickslots.add`
- `hiddenSlots.add`
- `highlightedSlots.add`
- `sprites.add`
- `native.GetWindowSize`
- `native.SetVariable`
- `… and 4 more`

Notes / invariants:

- Maintask helper; callable within its task unless the engine invokes it by a documented callback name.

### `OnDraw() -> void`

Source: `scripts/inventory_interface/inv_overhaul_inventory_background.lua`

Purpose: Handles the engine/UI `OnDraw` callback for the inventory background runtime.

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
- `inv_overhaul_inventory_geometry.InterfaceGeometryGetVisibleSlots`
- `DrawSlot`

Notes / invariants:

- Callback recognition is name-based in `pathologic_lua_compiler`; `OnDraw` is an engine event name.

### `OnMouseMove(x: int, y: int) -> void`

Source: `scripts/inventory_interface/inv_overhaul_inventory_background.lua`

Purpose: Handles the engine/UI `OnMouseMove` callback for the inventory background runtime.

Parameters:

- `x: int` — pointer/layout coordinate interpreted by this function.
- `y: int` — pointer/layout coordinate interpreted by this function.

Returns:

None.

Side effects:

- Mutates module/task state: `helpHoverActive`, `tooltipActive`.
- Writes shared engine variable(s): `"inv_overhaul_inventory_tooltip_item"`, `"inv_overhaul_inventory_tooltip_text_id"`, `"inv_overhaul_inventory_tooltip_type"`.
- Invokes engine/native operations: `native.SendMessageToParent`, `native.SetVariable`.

Called by:

- No in-repository caller was resolved; this may be an engine/XML callback or a conventionally public helper.

Calls:

- `native.SendMessageToParent`
- `native.SetVariable`
- `SendPointer`

Notes / invariants:

- Callback recognition is name-based in `pathologic_lua_compiler`; `OnMouseMove` is an engine event name.

### `OnMouseLeave() -> void`

Source: `scripts/inventory_interface/inv_overhaul_inventory_background.lua`

Purpose: Handles the engine/UI `OnMouseLeave` callback for the inventory background runtime.

Parameters:

None.

Returns:

None.

Side effects:

- Mutates module/task state: `helpHoverActive`, `tooltipActive`.
- Writes shared engine variable(s): `"inv_overhaul_inventory_tooltip_item"`, `"inv_overhaul_inventory_tooltip_type"`.
- Invokes engine/native operations: `native.SetTooltip`, `native.SetVariable`, `native.SendMessageToParent`.

Called by:

- No in-repository caller was resolved; this may be an engine/XML callback or a conventionally public helper.

Calls:

- `native.SetTooltip`
- `native.SetVariable`
- `native.SendMessageToParent`

Notes / invariants:

- Callback recognition is name-based in `pathologic_lua_compiler`; `OnMouseLeave` is an engine event name.

### `OnLButtonDown(x: int, y: int) -> void`

Source: `scripts/inventory_interface/inv_overhaul_inventory_background.lua`

Purpose: Handles the engine/UI `OnLButtonDown` callback for the inventory background runtime.

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

- `SendPointer`

Notes / invariants:

- Callback recognition is name-based in `pathologic_lua_compiler`; `OnLButtonDown` is an engine event name.

### `OnLButtonUp(x: int, y: int) -> void`

Source: `scripts/inventory_interface/inv_overhaul_inventory_background.lua`

Purpose: Handles the engine/UI `OnLButtonUp` callback for the inventory background runtime.

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

- `SendPointer`

Notes / invariants:

- Callback recognition is name-based in `pathologic_lua_compiler`; `OnLButtonUp` is an engine event name.

### `OnRButtonDown(x: int, y: int) -> void`

Source: `scripts/inventory_interface/inv_overhaul_inventory_background.lua`

Purpose: Handles the engine/UI `OnRButtonDown` callback for the inventory background runtime.

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

- `SendPointer`

Notes / invariants:

- Callback recognition is name-based in `pathologic_lua_compiler`; `OnRButtonDown` is an engine event name.

### `OnDragBegin(x: int, y: int) -> void`

Source: `scripts/inventory_interface/inv_overhaul_inventory_background.lua`

Purpose: Handles the engine/UI `OnDragBegin` callback for the inventory background runtime.

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

- `SendPointer`

Notes / invariants:

- Callback recognition is name-based in `pathologic_lua_compiler`; `OnDragBegin` is an engine event name.

### `OnDragEnd(x: int, y: int, accepted: bool) -> void`

Source: `scripts/inventory_interface/inv_overhaul_inventory_background.lua`

Purpose: Handles the engine/UI `OnDragEnd` callback for the inventory background runtime.

Parameters:

- `x: int` — pointer/layout coordinate interpreted by this function.
- `y: int` — pointer/layout coordinate interpreted by this function.
- `accepted: bool` — behavior flag interpreted by this function.

Returns:

None.

Side effects:

- None directly observable beyond calls listed below.

Called by:

- No in-repository caller was resolved; this may be an engine/XML callback or a conventionally public helper.

Calls:

- `SendPointer`

Notes / invariants:

- Callback recognition is name-based in `pathologic_lua_compiler`; `OnDragEnd` is an engine event name.

### `OnUIMessage(message: int, sender: string, data: object) -> void`

Source: `scripts/inventory_interface/inv_overhaul_inventory_background.lua`

Purpose: Handles the engine/UI `OnUIMessage` callback for the inventory background runtime.

Parameters:

- `message: int` — numeric engine/UI protocol message.
- `sender: string` — name of the UI form that emitted the message.
- `data: object` — engine callback/UI payload object; shape depends on the message.

Returns:

None.

Side effects:

- Mutates module/task state: `gridEnabled`, `rootHeight`, `rootWidth`, `tooltipActive`.
- Writes shared engine variable(s): `"inv_overhaul_inventory_tooltip_item"`, `"inv_overhaul_inventory_tooltip_type"`.
- Invokes engine/native operations: `native.SetVariable`, `native.SetTooltip`.

Called by:

- No in-repository caller was resolved; this may be an engine/XML callback or a conventionally public helper.

Calls:

- `ReleaseTrackedImages`
- `HandleGridRendererMessage`
- `data.GetItemID`
- `native.SetVariable`
- `native.SetTooltip`

Notes / invariants:

- Callback recognition is name-based in `pathologic_lua_compiler`; `OnUIMessage` is an engine event name.


## Important constants

- `c_iBranchDanko: int = 0` — named behavior/layout value for branch danko.
- `c_iBranchBurah: int = 1` — named behavior/layout value for branch burah.
- `c_iBranchKlara: int = 2` — named behavior/layout value for branch klara.
- `c_iInventoryCapacity: int = 56` — fixed limit/count for inventory capacity.
- `c_iTooltipNone: int = -1` — named behavior/layout value for tooltip none.
- `c_iTooltipInvObject: int = 1` — named behavior/layout value for tooltip inv object.
- `c_iReleaseResources: int = -200` — named behavior/layout value for release resources.

## Architectural notes

- No additional module-specific issue identified beyond repository-wide shared-variable and compiler-visible API constraints.
