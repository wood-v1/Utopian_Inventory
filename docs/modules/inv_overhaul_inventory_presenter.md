# Inventory Presenter

## Source

`scripts/player_inventory/inv_overhaul_inventory_presenter.lua`

DSL unit: `module inv_overhaul_inventory_presenter`

## Responsibility

Coordinates player-screen slot/equipment refreshes and incremental view publication.

## Dependencies

- `inv_overhaul_inventory_view` — Emits player inventory UI messages for slot contents, metadata, highlights, equipment, money, paging, and readiness.
- `inv_overhaul_inventory_protocol` — Defines and encodes the numeric UI message protocol shared by inventory forms and controllers.
- `inv_overhaul_inventory_items` — Builds the canonical projection of unequipped player items into backpack ordinals and cached category/index references.
- `inv_overhaul_inventory_quickslot_bindings` — Owns saved quickslot item/category/occurrence bindings and the player-screen binding cache.
- Pathologic native API — engine state, object access, persistence variables, UI messaging, timing, or rendering as listed per function.

## Used by

- `scripts/player_inventory/inv_overhaul_inventory_controller.lua`

## State

No module/task-level mutable state.

## Public API

All functions below are compiler-visible when the module is imported; the DSL has no private declaration.

### `PlayerPresenterConfigureSlotRenderSize(windowWidth: int) -> void`

Source: `scripts/player_inventory/inv_overhaul_inventory_presenter.lua`

Purpose: Configures slot render size for player presenter in the inventory presenter subsystem.

Parameters:

- `windowWidth: int` — current UI/layout size in pixels.

Returns:

None.

Side effects:

- Invokes engine/native operations: `native.SendMessage`.

Called by:

- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: PlayerControllerConfigureSlotRenderSize`

Calls:

- `native.SendMessage`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `PlayerPresenterSendGridRendererState(slot: int, capacity: int, operation: int, value: int, data: object) -> void`

Source: `scripts/player_inventory/inv_overhaul_inventory_presenter.lua`

Purpose: Sends grid renderer state for player presenter in the inventory presenter subsystem.

Parameters:

- `slot: int` — slot index or encoded slot target interpreted by this function.
- `capacity: int` — value interpreted according to the function purpose; no narrower contract is established by current code.
- `operation: int` — value interpreted according to the function purpose; no narrower contract is established by current code.
- `value: int` — value interpreted according to the function purpose; no narrower contract is established by current code.
- `data: object` — engine callback/UI payload object; shape depends on the message.

Returns:

None.

Side effects:

- Delegates to compiler-visible module APIs and inherits their documented side effects.

Called by:

- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: PlayerControllerSendGridRendererState`
- `scripts/player_inventory/inv_overhaul_inventory_presenter.lua :: PlayerPresenterUpdateSlot`

Calls:

- `inv_overhaul_inventory_view.PlayerViewSendGridRendererState`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `PlayerPresenterSetGridRendererHighlight(slot: int, enabled: bool) -> void`

Source: `scripts/player_inventory/inv_overhaul_inventory_presenter.lua`

Purpose: Sets grid renderer highlight for player presenter in the inventory presenter subsystem.

Parameters:

- `slot: int` — slot index or encoded slot target interpreted by this function.
- `enabled: bool` — behavior flag interpreted by this function.

Returns:

None.

Side effects:

- Delegates to compiler-visible module APIs and inherits their documented side effects.

Called by:

- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: PlayerControllerSetGridRendererHighlight`

Calls:

- `inv_overhaul_inventory_view.PlayerViewSetGridRendererHighlight`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `PlayerPresenterUpdatePageControls(visibleSlots: int, capacity: int, maxPage: int, currentPage: int) -> void`

Source: `scripts/player_inventory/inv_overhaul_inventory_presenter.lua`

Purpose: Updates page controls for player presenter in the inventory presenter subsystem.

Parameters:

- `visibleSlots: int` — slot index or encoded slot target interpreted by this function.
- `capacity: int` — value interpreted according to the function purpose; no narrower contract is established by current code.
- `maxPage: int` — zero-based page or page-related value.
- `currentPage: int` — zero-based page or page-related value.

Returns:

None.

Side effects:

- Invokes engine/native operations: `native.SendMessage`.

Called by:

- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: PlayerControllerUpdatePageControls`

Calls:

- `native.SendMessage`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `PlayerPresenterUpdateMoney(container: object) -> void`

Source: `scripts/player_inventory/inv_overhaul_inventory_presenter.lua`

Purpose: Updates money for player presenter in the inventory presenter subsystem.

Parameters:

- `container: object` — external world container/corpse engine object used for inventory reads or mutations.

Returns:

None.

Side effects:

- Invokes engine/native operations: `native.SendMessage`.

Called by:

- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: PlayerControllerUpdateMoney`

Calls:

- `container.GetProperty`
- `native.SendMessage`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `PlayerPresenterUpdateSlot(slot: int, capacity: int, visibleCell: int, reference: int, container: object) -> void`

Source: `scripts/player_inventory/inv_overhaul_inventory_presenter.lua`

Purpose: Updates slot for player presenter in the inventory presenter subsystem.

Parameters:

- `slot: int` — slot index or encoded slot target interpreted by this function.
- `capacity: int` — value interpreted according to the function purpose; no narrower contract is established by current code.
- `visibleCell: int` — zero-based backpack layout cell.
- `reference: int` — value interpreted according to the function purpose; no narrower contract is established by current code.
- `container: object` — external world container/corpse engine object used for inventory reads or mutations.

Returns:

None.

Side effects:

- Delegates to compiler-visible module APIs and inherits their documented side effects.

Called by:

- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: PlayerControllerUpdateSlot`

Calls:

- `PlayerPresenterSendGridRendererState`
- `inv_overhaul_inventory_items.DecodeReferenceCategory`
- `inv_overhaul_inventory_items.DecodeReferenceIndex`
- `container.GetItem`
- `container.GetItemAmount`
- `item.GetItemID`
- `inv_overhaul_inventory_quickslot_bindings.GetDisplayedBinding`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `UpdateEquipmentSlot(cache: int, wndName: string, category: int, index: int, container: object, emptyMessage: int) -> void`

Source: `scripts/player_inventory/inv_overhaul_inventory_presenter.lua`

Purpose: Updates equipment slot in the inventory presenter subsystem.

Parameters:

- `cache: int` — value interpreted according to the function purpose; no narrower contract is established by current code.
- `wndName: string` — value interpreted according to the function purpose; no narrower contract is established by current code.
- `category: int` — zero-based engine inventory category identifier.
- `index: int` — zero-based entry index in the relevant engine container/category.
- `container: object` — external world container/corpse engine object used for inventory reads or mutations.
- `emptyMessage: int` — value interpreted according to the function purpose; no narrower contract is established by current code.

Returns:

None.

Side effects:

- Invokes engine/native operations: `native.SendMessage`.

Called by:

- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: UpdateCachedEquipmentSlot`

Calls:

- `container.GetItem`
- `native.SendMessage`
- `item.GetItemID`
- `inv_overhaul_inventory_quickslot_bindings.GetDisplayedBinding`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `PlayerPresenterIsItemTexturePreloaded(itemID: int, cacheEpoch: int) -> bool`

Source: `scripts/player_inventory/inv_overhaul_inventory_presenter.lua`

Purpose: Returns whether item texture preloaded for player presenter in the inventory presenter subsystem.

Parameters:

- `itemID: int` — engine item or callback identifier interpreted by this function.
- `cacheEpoch: int` — value interpreted according to the function purpose; no narrower contract is established by current code.

Returns:

- `boolean` — result of: returns whether item texture preloaded for player presenter in the inventory presenter subsystem.

Side effects:

- None directly observable beyond calls listed below.

Called by:

- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: PlayerControllerIsItemTexturePreloaded`

Calls:

- `native.GetVariable`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `PlayerPresenterMarkItemTextureLoaded(container: object, category: int, index: int) -> void`

Source: `scripts/player_inventory/inv_overhaul_inventory_presenter.lua`

Purpose: Marks item texture loaded for player presenter in the inventory presenter subsystem.

Parameters:

- `container: object` — external world container/corpse engine object used for inventory reads or mutations.
- `category: int` — zero-based engine inventory category identifier.
- `index: int` — zero-based entry index in the relevant engine container/category.

Returns:

None.

Side effects:

- Writes shared engine variable(s): `"inv_overhaul_runtime_texture_item_" + itemID`.
- Invokes engine/native operations: `native.SetVariable`.

Called by:

- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: PlayerControllerMarkItemTextureLoaded`

Calls:

- `native.GetVariable`
- `container.GetItem`
- `item.GetItemID`
- `native.SetVariable`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.


## Internal API

No additional maintask helpers.

## Events / callbacks

No engine callbacks; this is an imported module.

## Important constants

No module/task-level constants.

## Architectural notes

- No additional module-specific issue identified beyond repository-wide shared-variable and compiler-visible API constraints.
