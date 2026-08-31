# Inventory Tooltip

## Source

`scripts/inventory_interface/inv_overhaul_inventory_tooltip.lua`

DSL unit: `module inv_overhaul_inventory_tooltip`

## Responsibility

Owns shared tooltip text, per-instance item-property publication, money pseudo-item metadata, suspension, and show/hide messaging.

## Dependencies

- `inv_overhaul_inventory_protocol` — Defines and encodes the numeric UI message protocol shared by inventory forms and controllers.
- Pathologic native API — engine state, object access, persistence variables, UI messaging, timing, or rendering as listed per function.

## Used by

- `scripts/loot/inv_overhaul_container.lua`
- `scripts/loot/inv_overhaul_container_drag_controller.lua`
- `scripts/loot/inv_overhaul_container_input_controller.lua`
- `scripts/loot/inv_overhaul_container_tooltip_controller.lua`
- `scripts/loot/inv_overhaul_container_transfer_external.lua`
- `scripts/player_inventory/inv_overhaul_inventory_controller.lua`

## State

- `target: int` — mutable runtime state for target.
- `moneyItem: object` — engine object/vector storage for money item; exact runtime shape follows its method usage.
- `resumeDelay: float` — timing state for resume delay.

## Public API

All functions below are compiler-visible when the module is imported; the DSL has no private declaration.

### `InterfaceTooltipInitializeState() -> void`

Source: `scripts/inventory_interface/inv_overhaul_inventory_tooltip.lua`

Purpose: Initializes state for interface tooltip in the inventory tooltip subsystem.

Parameters:

None.

Returns:

None.

Side effects:

- Mutates module/task state: `target`, `resumeDelay`.

Called by:

- `scripts/loot/inv_overhaul_container.lua :: init`
- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: PlayerControllerInitialize`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `InitializeMoneyItem() -> void`

Source: `scripts/inventory_interface/inv_overhaul_inventory_tooltip.lua`

Purpose: Initializes money item in the inventory tooltip subsystem.

Parameters:

None.

Returns:

None.

Side effects:

- Mutates module/task state: `moneyItem`.
- Invokes engine/native operations: `native.CreateInvItem`.
- May mutate engine/UI objects through: `moneyItem.SetItemName`.

Called by:

- `scripts/loot/inv_overhaul_container.lua :: init`
- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: PlayerControllerInitialize`

Calls:

- `native.CreateInvItem`
- `moneyItem.SetItemName`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `GetMoneyItemID() -> int`

Source: `scripts/inventory_interface/inv_overhaul_inventory_tooltip.lua`

Purpose: Returns money item id in the inventory tooltip subsystem.

Parameters:

None.

Returns:

- `number` (integer) — result of: returns money item id in the inventory tooltip subsystem.

Side effects:

- None directly observable beyond calls listed below.

Called by:

- `scripts/loot/inv_overhaul_container_transfer_external.lua :: ExternalTransferInitializeState`

Calls:

- `item.GetItemID`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `GetTarget() -> int`

Source: `scripts/inventory_interface/inv_overhaul_inventory_tooltip.lua`

Purpose: Returns target in the inventory tooltip subsystem.

Parameters:

None.

Returns:

- `number` (integer) — result of: returns target in the inventory tooltip subsystem.

Side effects:

- None directly observable beyond calls listed below.

Called by:

- `scripts/loot/inv_overhaul_container_input_controller.lua :: LootInputAssignHoveredQuickslot`
- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: PlayerControllerAssignHoveredQuickslot`
- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: UpdatePanelTooltip`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `IsSuspended() -> bool`

Source: `scripts/inventory_interface/inv_overhaul_inventory_tooltip.lua`

Purpose: Returns whether suspended in the inventory tooltip subsystem.

Parameters:

None.

Returns:

- `boolean` — result of: returns whether suspended in the inventory tooltip subsystem.

Side effects:

- None directly observable beyond calls listed below.

Called by:

- `scripts/loot/inv_overhaul_container_tooltip_controller.lua :: Update`
- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: UpdatePanelTooltip`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `Suspend(delay: float) -> void`

Source: `scripts/inventory_interface/inv_overhaul_inventory_tooltip.lua`

Purpose: Suspends tooltip publication for the requested delay.

Parameters:

- `delay: float` — value interpreted according to the function purpose; no narrower contract is established by current code.

Returns:

None.

Side effects:

- Mutates module/task state: `resumeDelay`.

Called by:

- `scripts/loot/inv_overhaul_container_drag_controller.lua :: Finish`
- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: CancelDragAction`
- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: FinishLeftAction`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `InterfaceTooltipClear() -> void`

Source: `scripts/inventory_interface/inv_overhaul_inventory_tooltip.lua`

Purpose: Clears interface tooltip in the inventory tooltip subsystem.

Parameters:

None.

Returns:

None.

Side effects:

- Mutates module/task state: `target`.
- Invokes engine/native operations: `native.SendMessage`.

Called by:

- `scripts/inventory_interface/inv_overhaul_inventory_tooltip.lua :: AdvanceSuspension`
- `scripts/inventory_interface/inv_overhaul_inventory_tooltip.lua :: ShowItem`
- `scripts/loot/inv_overhaul_container_tooltip_controller.lua :: LootTooltipClear`
- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: StartDragAction`
- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: CancelDragAction`
- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: FinishLeftAction`
- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: UpdatePanelTooltip`
- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: PlayerControllerHandlePanelPointer`

Calls:

- `native.SendMessage`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `AdvanceSuspension(delta: float) -> void`

Source: `scripts/inventory_interface/inv_overhaul_inventory_tooltip.lua`

Purpose: Advances suspension in the inventory tooltip subsystem.

Parameters:

- `delta: float` — elapsed update time in seconds.

Returns:

None.

Side effects:

- Mutates module/task state: `resumeDelay`.

Called by:

- `scripts/loot/inv_overhaul_container.lua :: OnUpdate`
- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: RunFramePreparationStage`

Calls:

- `InterfaceTooltipClear`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `ShowText(newTarget: int, textID: int) -> void`

Source: `scripts/inventory_interface/inv_overhaul_inventory_tooltip.lua`

Purpose: Shows text in the inventory tooltip subsystem.

Parameters:

- `newTarget: int` — value interpreted according to the function purpose; no narrower contract is established by current code.
- `textID: int` — value interpreted according to the function purpose; no narrower contract is established by current code.

Returns:

None.

Side effects:

- Mutates module/task state: `target`.
- Writes shared engine variable(s): `"inv_overhaul_inventory_tooltip_item"`, `"inv_overhaul_inventory_tooltip_durability"`, `"inv_overhaul_inventory_tooltip_uses"`, `"inv_overhaul_inventory_tooltip_text_id"`, `"inv_overhaul_inventory_tooltip_type"`.
- Invokes engine/native operations: `native.SetVariable`.

Called by:

- `scripts/loot/inv_overhaul_container_tooltip_controller.lua :: ShowPlayerPaging`
- `scripts/loot/inv_overhaul_container_tooltip_controller.lua :: ShowQuickslotHelp`
- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: UpdatePanelTooltip`
- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: HandleGlobalProtocolMessage`

Calls:

- `native.SetVariable`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `ShowMoneyForTarget(newTarget: int) -> void`

Source: `scripts/inventory_interface/inv_overhaul_inventory_tooltip.lua`

Purpose: Shows money for target in the inventory tooltip subsystem.

Parameters:

- `newTarget: int` — value interpreted according to the function purpose; no narrower contract is established by current code.

Returns:

None.

Side effects:

- Mutates module/task state: `target`.
- Writes shared engine variables `"inv_overhaul_inventory_tooltip_durability"` and `"inv_overhaul_inventory_tooltip_uses"` with absent-value sentinels.
- Invokes engine/native operations: `native.SendMessage`.

Called by:

- `scripts/inventory_interface/inv_overhaul_inventory_tooltip.lua :: ShowMoney`
- `scripts/loot/inv_overhaul_container_tooltip_controller.lua :: Update`

Calls:

- `native.SendMessage`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `ShowMoney() -> void`

Source: `scripts/inventory_interface/inv_overhaul_inventory_tooltip.lua`

Purpose: Shows money in the inventory tooltip subsystem.

Parameters:

None.

Returns:

None.

Side effects:

- None directly observable beyond calls listed below.

Called by:

- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: UpdatePanelTooltip`

Calls:

- `ShowMoneyForTarget`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `ShowItem(newTarget: int, item: object) -> void`

Source: `scripts/inventory_interface/inv_overhaul_inventory_tooltip.lua`

Purpose: Shows item in the inventory tooltip subsystem.

Parameters:

- `newTarget: int` — value interpreted according to the function purpose; no narrower contract is established by current code.
- `item: object` — engine inventory-item object; available properties and methods are supplied by the game.

Returns:

None.

Side effects:

- Mutates module/task state: `target`.
- Publishes the item's per-instance `durability` and `uses` values through shared engine variables, using `-1` when absent.
- Invokes engine/native operations: `native.SendMessage`.

Called by:

- `scripts/loot/inv_overhaul_container_tooltip_controller.lua :: Update`
- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: UpdatePanelTooltip`

Calls:

- `item.HasProperty`
- `item.GetProperty`
- `native.SetVariable`
- `native.SendMessage`
- `InterfaceTooltipClear`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.


## Internal API

No additional maintask helpers.

## Events / callbacks

No engine callbacks; this is an imported module.

## Important constants

No module/task-level constants.

## Architectural notes

- Per-instance properties must be published separately from item identity because cursor and controller are distinct UI maintasks and the direct tooltip-object channel is not reliable in the replacement panel.
