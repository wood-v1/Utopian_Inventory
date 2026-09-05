# Inventory Sounds

## Source

`scripts/inventory_interface/inv_overhaul_inventory_sounds.lua`

DSL unit: `module inv_overhaul_inventory_sounds`

## Responsibility

Centralizes the sound identifiers used by player-inventory and loot-screen interactions.

## Dependencies

- No local DSL imports.
- Pathologic native API — plays sounds registered on the active root UI form.

## Used by

- Player inventory controller.
- Container root, drag controller, input controller, player-action, presenter, and transfer modules.

## State

No module/task-level mutable state.

## Public API

- `InventorySoundsPlayOpen() -> void` — plays once when an inventory or loot screen opens.
- `InventorySoundsPlayItemEquip() -> void` — plays successful equipment, placement, page-move, or inter-inventory transfer feedback.
- `InventorySoundsPlayAction() -> void` — plays the page-change or quickslot-assignment sound.
- `InventorySoundsPlayMoneyPickup() -> void` — plays the successful money-transfer sound.

All functions call `native.PlaySound` with identifiers declared by every generated player-inventory, container, and corpse root XML form.

## Events / callbacks

No engine callbacks; this is an imported module.

## Important constants

Sound identifiers and deployed filenames use the `inv_overhaul_` prefix to avoid collisions with other mods.
