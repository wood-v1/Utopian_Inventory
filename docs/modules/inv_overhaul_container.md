# Container

## Source

`scripts/loot/inv_overhaul_container.lua`

DSL unit: `maintask InvOverhaulContainerUI`

## Responsibility

Is the container/corpse UI maintask and delegates initialization, callbacks, and frame updates to loot-domain modules.

## Dependencies

- `inv_overhaul_inventory_sounds` — Plays the loot-screen-open sound immediately before the blocking UI event loop.

- `inv_overhaul_inventory_layout_runtime` — Owns the mutable saved cell-to-item order, normalization, exact insertion/removal, swapping, and incremental persistence.
- `inv_overhaul_inventory_snapshot` — Captures item-identity snapshots and reconciles saved layout cells after game inventory order changes or equipment mutations.
- `inv_overhaul_container_bootstrap` — Stages the container screen's initial loading and readiness handshake.
- `inv_overhaul_container_drag` — Owns container-screen drag state, source identity, target highlighting, and drag cancellation/commit bookkeeping.
- `inv_overhaul_container_drag_controller` — Resolves pointer targets and coordinates completion of container-screen drag actions.
- `inv_overhaul_container_feedback` — Owns transient loot-screen message cooldown and localized feedback publication.
- `inv_overhaul_container_input_controller` — Routes loot-screen UI messages, keyboard input, and contextual actions to the appropriate domain controller.
- `inv_overhaul_container_paging_controller` — Owns player/container page changes and drag-hover page switching on the loot screen.
- `inv_overhaul_container_presenter` — Projects session state into loot UI forms, including incremental item metadata/texture loading, money, organs, and page controls.
- `inv_overhaul_container_projection` — Builds and queries the visible container/corpse item projection independently of the player backpack projection.
- `inv_overhaul_container_session` — Owns the active external container object, container/corpse kind, generation tracking, and close lifecycle.
- `inv_overhaul_container_transfer_external` — Adapts shared transfer operations for items moving from the external container into the player backpack.
- `inv_overhaul_container_view` — Defines loot-screen window names and emits UI messages that render slots, organs, drag state, and page controls.
- `inv_overhaul_inventory_tooltip` — Owns shared tooltip text, money pseudo-item metadata, suspension, and show/hide messaging.
- `inv_overhaul_inventory_items` — Builds the canonical projection of unequipped player items into backpack ordinals and cached category/index references.
- `inv_overhaul_inventory_quickslot_bindings` — Owns saved quickslot item/category/occurrence bindings and the player-screen binding cache.
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

Source: `scripts/loot/inv_overhaul_container.lua`

Purpose: Initializes the container runtime and establishes its starting state and engine/UI integration.

Parameters:

None.

Returns:

None.

Side effects:

- Writes shared engine variable(s): `"inv_overhaul_inventory_drag_item"`, `"inv_overhaul_inventory_page_hover"`.
- Invokes engine/native operations: `native.Trace`, `native.SetVariable`, `native.SetCursor`, `native.ShowCursor`, `native.CaptureKeyboard`, `native.SetOwnerDraw`, `native.SetNeedUpdate`, `native.SendMessage`, `… and 1 more`.

Called by:

- No in-repository caller was resolved; this may be an engine/XML callback or a conventionally public helper.

Calls:

- `native.Trace`
- `inv_overhaul_container_presenter.LootPresenterInitializeState`
- `inv_overhaul_container_session.LootSessionInitializeState`
- `inv_overhaul_container_feedback.LootFeedbackInitializeState`
- `inv_overhaul_container_bootstrap.LootBootstrapInitializeState`
- `inv_overhaul_container_input_controller.LootInputInitializeState`
- `inv_overhaul_container_drag.LootDragInitializeState`
- `inv_overhaul_inventory_tooltip.InterfaceTooltipInitializeState`
- `inv_overhaul_inventory_quickslot_bindings.QuickslotBindingsInitializeState`
- `inv_overhaul_inventory_quickslot_bindings.InitializeBindings`
- `inv_overhaul_inventory_quickslot_bindings.RefreshCache`
- `native.SetVariable`
- `… and 18 more`

Notes / invariants:

- Maintask helper; callable within its task unless the engine invokes it by a documented callback name.

### `OnUIMessage(message: int, sender: string, data: object) -> void`

Source: `scripts/loot/inv_overhaul_container.lua`

Purpose: Handles the engine/UI `OnUIMessage` callback for the container runtime.

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

- `inv_overhaul_container_input_controller.HandleUIMessage`

Notes / invariants:

- Callback recognition is name-based in `pathologic_lua_compiler`; `OnUIMessage` is an engine event name.

### `OnUpdate(delta: float) -> void`

Source: `scripts/loot/inv_overhaul_container.lua`

Purpose: Handles the engine/UI `OnUpdate` callback for the container runtime.

Parameters:

- `delta: float` — elapsed update time in seconds.

Returns:

None.

Side effects:

- Delegates to compiler-visible module APIs and inherits their documented side effects.

Called by:

- No in-repository caller was resolved; this may be an engine/XML callback or a conventionally public helper.

Calls:

- `inv_overhaul_inventory_tooltip.AdvanceSuspension`
- `inv_overhaul_container_feedback.LootFeedbackAdvance`
- `inv_overhaul_container_presenter.LootPresenterUpdateLayout`
- `inv_overhaul_container_bootstrap.LootBootstrapAdvance`
- `inv_overhaul_container_presenter.LootPresenterContinueInitialSlotLoad`
- `inv_overhaul_container_presenter.ContinueCachedPlayerEntryRefresh`
- `inv_overhaul_inventory_layout_runtime.ContinueQueuedSave`
- `inv_overhaul_container_presenter.AdvanceMoneyPolling`
- `inv_overhaul_container_session.LootSessionAdvance`
- `inv_overhaul_container_paging_controller.SyncDragHoverFromCursor`
- `inv_overhaul_container_paging_controller.UpdateDragHover`

Notes / invariants:

- Callback recognition is name-based in `pathologic_lua_compiler`; `OnUpdate` is an engine event name.

### `OnMouseMove(x: int, y: int) -> void`

Source: `scripts/loot/inv_overhaul_container.lua`

Purpose: Handles the engine/UI `OnMouseMove` callback for the container runtime.

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

- `inv_overhaul_container_drag.LootDragIsActive`
- `inv_overhaul_container_drag_controller.LootDragControllerFindTargetAt`
- `inv_overhaul_container_drag_controller.LootDragControllerApplyPointerTarget`

Notes / invariants:

- Callback recognition is name-based in `pathologic_lua_compiler`; `OnMouseMove` is an engine event name.

### `OnMouseLeave() -> void`

Source: `scripts/loot/inv_overhaul_container.lua`

Purpose: Handles the engine/UI `OnMouseLeave` callback for the container runtime.

Parameters:

None.

Returns:

None.

Side effects:

- Delegates to compiler-visible module APIs and inherits their documented side effects.

Called by:

- No in-repository caller was resolved; this may be an engine/XML callback or a conventionally public helper.

Calls:

- `inv_overhaul_container_drag.LootDragIsActive`
- `inv_overhaul_container_drag_controller.LootDragControllerSetHighlightedTarget`

Notes / invariants:

- Callback recognition is name-based in `pathologic_lua_compiler`; `OnMouseLeave` is an engine event name.

### `OnLButtonUp(x: int, y: int) -> void`

Source: `scripts/loot/inv_overhaul_container.lua`

Purpose: Handles the engine/UI `OnLButtonUp` callback for the container runtime.

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

- `inv_overhaul_container_drag.LootDragIsActive`
- `inv_overhaul_container_drag_controller.LootDragControllerFindTargetAt`
- `inv_overhaul_container_drag_controller.LootDragControllerApplyPointerTarget`
- `inv_overhaul_container_drag_controller.Finish`

Notes / invariants:

- Callback recognition is name-based in `pathologic_lua_compiler`; `OnLButtonUp` is an engine event name.

### `OnChar(char: int) -> void`

Source: `scripts/loot/inv_overhaul_container.lua`

Purpose: Handles the engine/UI `OnChar` callback for the container runtime.

Parameters:

- `char: int` — value interpreted according to the function purpose; no narrower contract is established by current code.

Returns:

None.

Side effects:

- Delegates to compiler-visible module APIs and inherits their documented side effects.

Called by:

- No in-repository caller was resolved; this may be an engine/XML callback or a conventionally public helper.

Calls:

- `inv_overhaul_container_input_controller.HandleChar`

Notes / invariants:

- Callback recognition is name-based in `pathologic_lua_compiler`; `OnChar` is an engine event name.

### `OnKeyDown(key: int) -> void`

Source: `scripts/loot/inv_overhaul_container.lua`

Purpose: Handles the engine/UI `OnKeyDown` callback for the container runtime.

Parameters:

- `key: int` — value interpreted according to the function purpose; no narrower contract is established by current code.

Returns:

None.

Side effects:

- Delegates to compiler-visible module APIs and inherits their documented side effects.

Called by:

- No in-repository caller was resolved; this may be an engine/XML callback or a conventionally public helper.

Calls:

- `inv_overhaul_container_input_controller.HandleKeyDown`

Notes / invariants:

- Callback recognition is name-based in `pathologic_lua_compiler`; `OnKeyDown` is an engine event name.

### `OnKeyUp(key: int) -> void`

Source: `scripts/loot/inv_overhaul_container.lua`

Purpose: Handles the engine/UI `OnKeyUp` callback for the container runtime.

Parameters:

- `key: int` — value interpreted according to the function purpose; no narrower contract is established by current code.

Returns:

None.

Side effects:

- Delegates to compiler-visible module APIs and inherits their documented side effects.

Called by:

- No in-repository caller was resolved; this may be an engine/XML callback or a conventionally public helper.

Calls:

- `inv_overhaul_container_input_controller.HandleKeyUp`

Notes / invariants:

- Callback recognition is name-based in `pathologic_lua_compiler`; `OnKeyUp` is an engine event name.


## Important constants

- `ScriptVersion: string = "2026.08.17-native-occupied-slot-exchange-1"` — schema/runtime version marker for script version.
- `OrganSlots: int = 4` — named behavior/layout value for organ slots.

## Architectural notes

- No additional module-specific issue identified beyond repository-wide shared-variable and compiler-visible API constraints.
