# Container Tooltip Controller

## Source

`scripts/loot/inv_overhaul_container_tooltip_controller.lua`

DSL unit: `module inv_overhaul_container_tooltip_controller`

## Responsibility

Resolves loot-screen pointer targets into item, money, organ, and help tooltips.

## Dependencies

- `inv_overhaul_inventory_layout` — Defines the pure default mapping between backpack cells, linear slots, and pages.
- `inv_overhaul_inventory_layout_runtime` — Owns the mutable saved cell-to-item order, normalization, exact insertion/removal, swapping, and incremental persistence.
- `inv_overhaul_container_geometry` — Maps supported layouts to player, container, organ, money, paging, and pointer hit-test geometry.
- `inv_overhaul_container_drag` — Owns container-screen drag state, source identity, target highlighting, and drag cancellation/commit bookkeeping.
- `inv_overhaul_container_projection` — Builds and queries the visible container/corpse item projection independently of the player backpack projection.
- `inv_overhaul_container_protocol` — Defines the loot screen's numeric messages, target identifiers, and sender-name mappings.
- `inv_overhaul_inventory_tooltip` — Owns shared tooltip text, money pseudo-item metadata, suspension, and show/hide messaging.
- `inv_overhaul_inventory_items` — Builds the canonical projection of unequipped player items into backpack ordinals and cached category/index references.
- Pathologic native API — engine state, object access, persistence variables, UI messaging, timing, or rendering as listed per function.

## Used by

- `scripts/loot/inv_overhaul_container_drag_controller.lua`
- `scripts/loot/inv_overhaul_container_input_controller.lua`

## State

No module/task-level mutable state.

## Public API

All functions below are compiler-visible when the module is imported; the DSL has no private declaration.

### `LootTooltipClear() -> void`

Source: `scripts/loot/inv_overhaul_container_tooltip_controller.lua`

Purpose: Clears loot tooltip in the container tooltip controller subsystem.

Parameters:

None.

Returns:

None.

Side effects:

- Delegates to compiler-visible module APIs and inherits their documented side effects.

Called by:

- `scripts/loot/inv_overhaul_container_drag_controller.lua :: Start`
- `scripts/loot/inv_overhaul_container_drag_controller.lua :: Finish`
- `scripts/loot/inv_overhaul_container_input_controller.lua :: LootInputHandlePanelPointer`
- `scripts/loot/inv_overhaul_container_tooltip_controller.lua :: Update`

Calls:

- `inv_overhaul_inventory_tooltip.InterfaceTooltipClear`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `ShowPlayerPaging() -> void`

Source: `scripts/loot/inv_overhaul_container_tooltip_controller.lua`

Purpose: Shows player paging in the container tooltip controller subsystem.

Parameters:

None.

Returns:

None.

Side effects:

- Delegates to compiler-visible module APIs and inherits their documented side effects.

Called by:

- `scripts/loot/inv_overhaul_container_tooltip_controller.lua :: Update`

Calls:

- `inv_overhaul_inventory_tooltip.ShowText`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `ShowQuickslotHelp() -> void`

Source: `scripts/loot/inv_overhaul_container_tooltip_controller.lua`

Purpose: Shows quickslot help in the container tooltip controller subsystem.

Parameters:

None.

Returns:

None.

Side effects:

- Delegates to compiler-visible module APIs and inherits their documented side effects.

Called by:

- `scripts/loot/inv_overhaul_container_input_controller.lua :: HandleLifecycleMessage`
- `scripts/loot/inv_overhaul_container_tooltip_controller.lua :: Update`

Calls:

- `inv_overhaul_inventory_tooltip.ShowText`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `LootTooltipIsInsidePlayerPaging(maxPlayerPage: int, windowWidth: int, x: int, y: int) -> bool`

Source: `scripts/loot/inv_overhaul_container_tooltip_controller.lua`

Purpose: Returns whether inside player paging for loot tooltip in the container tooltip controller subsystem.

Parameters:

- `maxPlayerPage: int` — zero-based page or page-related value.
- `windowWidth: int` — current UI/layout size in pixels.
- `x: int` — pointer/layout coordinate interpreted by this function.
- `y: int` — pointer/layout coordinate interpreted by this function.

Returns:

- `boolean` — result of: returns whether inside player paging for loot tooltip in the container tooltip controller subsystem.

Side effects:

- Delegates to compiler-visible module APIs and inherits their documented side effects.

Called by:

- `scripts/loot/inv_overhaul_container_tooltip_controller.lua :: Update`

Calls:

- `inv_overhaul_container_geometry.IsInsidePageControl`
- `inv_overhaul_container_geometry.GetPlayerPageControlX`
- `inv_overhaul_container_geometry.GetPlayerPageControlY`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `ResolvePlayerItem(playerPage: int, visibleSlots: int, target: int) -> object`

Source: `scripts/loot/inv_overhaul_container_tooltip_controller.lua`

Purpose: Resolves player item in the container tooltip controller subsystem.

Parameters:

- `playerPage: int` — zero-based page or page-related value.
- `visibleSlots: int` — slot index or encoded slot target interpreted by this function.
- `target: int` — value interpreted according to the function purpose; no narrower contract is established by current code.

Returns:

- `object` — result of: resolves player item in the container tooltip controller subsystem.

Side effects:

- Delegates to compiler-visible module APIs and inherits their documented side effects.

Called by:

- `scripts/loot/inv_overhaul_container_tooltip_controller.lua :: Update`

Calls:

- `inv_overhaul_inventory_layout.LayoutGetCellForLinearSlot`
- `inv_overhaul_inventory_layout_runtime.LayoutRuntimeGetOrderValue`
- `inv_overhaul_inventory_items.ResolveCachedOrdinal`
- `inv_overhaul_inventory_items.DecodeReferenceCategory`
- `inv_overhaul_inventory_items.DecodeReferenceIndex`
- `inv_overhaul_inventory_items.ItemsGetPlayerContainer`
- `player.GetItem`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `ResolveExternalItem(target: int, containerPage: int, showOrgans: bool) -> object`

Source: `scripts/loot/inv_overhaul_container_tooltip_controller.lua`

Purpose: Resolves external item in the container tooltip controller subsystem.

Parameters:

- `target: int` — value interpreted according to the function purpose; no narrower contract is established by current code.
- `containerPage: int` — zero-based page or page-related value.
- `showOrgans: bool` — behavior flag interpreted by this function.

Returns:

- `object` — result of: resolves external item in the container tooltip controller subsystem.

Side effects:

- Delegates to compiler-visible module APIs and inherits their documented side effects.

Called by:

- `scripts/loot/inv_overhaul_container_tooltip_controller.lua :: Update`

Calls:

- `inv_overhaul_container_protocol.IsContainerTarget`
- `inv_overhaul_container_protocol.GetContainerSlot`
- `inv_overhaul_container_projection.GetContainerOrder`
- `inv_overhaul_container_projection.ResolveNormalOrdinal`
- `inv_overhaul_container_protocol.IsOrganTarget`
- `native.GetContainer`
- `inv_overhaul_container_projection.ResolveOrganVisual`
- `inv_overhaul_container_protocol.GetOrganSlot`
- `inv_overhaul_container_projection.GetReferenceIndex`
- `external.GetItem`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `Update(windowWidth: int, visibleSlots: int, playerPage: int, containerPage: int, showOrgans: bool, maxPlayerPage: int, x: int, y: int) -> void`

Source: `scripts/loot/inv_overhaul_container_tooltip_controller.lua`

Purpose: Updates container tooltip controller in the container tooltip controller subsystem.

Parameters:

- `windowWidth: int` — current UI/layout size in pixels.
- `visibleSlots: int` — slot index or encoded slot target interpreted by this function.
- `playerPage: int` — zero-based page or page-related value.
- `containerPage: int` — zero-based page or page-related value.
- `showOrgans: bool` — behavior flag interpreted by this function.
- `maxPlayerPage: int` — zero-based page or page-related value.
- `x: int` — pointer/layout coordinate interpreted by this function.
- `y: int` — pointer/layout coordinate interpreted by this function.

Returns:

None.

Side effects:

- Delegates to compiler-visible module APIs and inherits their documented side effects.

Called by:

- `scripts/loot/inv_overhaul_container_input_controller.lua :: LootInputHandlePanelPointer`

Calls:

- `inv_overhaul_inventory_tooltip.IsSuspended`
- `inv_overhaul_container_drag.LootDragIsActive`
- `LootTooltipClear`
- `inv_overhaul_container_geometry.LootGeometryIsInsideQuickslotHelp`
- `ShowQuickslotHelp`
- `LootTooltipIsInsidePlayerPaging`
- `ShowPlayerPaging`
- `inv_overhaul_container_geometry.LootGeometryIsInsideMoney`
- `inv_overhaul_inventory_tooltip.ShowMoneyForTarget`
- `inv_overhaul_container_protocol.LootProtocolFindTargetAt`
- `inv_overhaul_container_protocol.IsPlayerTarget`
- `ResolvePlayerItem`
- `… and 2 more`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.


## Internal API

No additional maintask helpers.

## Events / callbacks

No engine callbacks; this is an imported module.

## Important constants

- `InventoryCapacity: int = 56` — fixed limit/count for inventory capacity.
- `ContainerSlots: int = 12` — named behavior/layout value for container slots.

## Architectural notes

- No additional module-specific issue identified beyond repository-wide shared-variable and compiler-visible API constraints.
