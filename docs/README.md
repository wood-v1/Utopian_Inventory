# Lua codebase documentation

This directory maps the current typed Lua/DSL sources under `scripts/` to their responsibilities, state, dependencies, callbacks, and function contracts. It is optimized for fast code navigation and remains a developer reference.

Start with [CONTEXT.md](CONTEXT.md), then use [ARCHITECTURE.md](ARCHITECTURE.md) for system flow or [API_INDEX.md](API_INDEX.md) to locate a function.

## Module documentation

- [Inventory Sounds](modules/inv_overhaul_inventory_sounds.md) — `scripts/inventory_interface/inv_overhaul_inventory_sounds.lua`

- [Character Doll](modules/inv_overhaul_character_doll.md) — `scripts/player_inventory/widgets/inv_overhaul_character_doll.lua`
- [Container](modules/inv_overhaul_container.md) — `scripts/loot/inv_overhaul_container.lua`
- [Container Bootstrap](modules/inv_overhaul_container_bootstrap.md) — `scripts/loot/inv_overhaul_container_bootstrap.lua`
- [Container Drag](modules/inv_overhaul_container_drag.md) — `scripts/loot/inv_overhaul_container_drag.lua`
- [Container Drag Controller](modules/inv_overhaul_container_drag_controller.md) — `scripts/loot/inv_overhaul_container_drag_controller.lua`
- [Container Feedback](modules/inv_overhaul_container_feedback.md) — `scripts/loot/inv_overhaul_container_feedback.lua`
- [Container Geometry](modules/inv_overhaul_container_geometry.md) — `scripts/loot/inv_overhaul_container_geometry.lua`
- [Container Input Controller](modules/inv_overhaul_container_input_controller.md) — `scripts/loot/inv_overhaul_container_input_controller.lua`
- [Container Paging Controller](modules/inv_overhaul_container_paging_controller.md) — `scripts/loot/inv_overhaul_container_paging_controller.lua`
- [Container Player Actions](modules/inv_overhaul_container_player_actions.md) — `scripts/loot/inv_overhaul_container_player_actions.lua`
- [Container Presenter](modules/inv_overhaul_container_presenter.md) — `scripts/loot/inv_overhaul_container_presenter.lua`
- [Container Projection](modules/inv_overhaul_container_projection.md) — `scripts/loot/inv_overhaul_container_projection.lua`
- [Container Protocol](modules/inv_overhaul_container_protocol.md) — `scripts/loot/inv_overhaul_container_protocol.lua`
- [Container Quick Transfer](modules/inv_overhaul_container_quick_transfer.md) — `scripts/loot/inv_overhaul_container_quick_transfer.lua`
- [Container Session](modules/inv_overhaul_container_session.md) — `scripts/loot/inv_overhaul_container_session.lua`
- [Container Tooltip Controller](modules/inv_overhaul_container_tooltip_controller.md) — `scripts/loot/inv_overhaul_container_tooltip_controller.lua`
- [Container Transfer](modules/inv_overhaul_container_transfer.md) — `scripts/loot/inv_overhaul_container_transfer.lua`
- [Container Transfer External](modules/inv_overhaul_container_transfer_external.md) — `scripts/loot/inv_overhaul_container_transfer_external.lua`
- [Container Transfer Player](modules/inv_overhaul_container_transfer_player.md) — `scripts/loot/inv_overhaul_container_transfer_player.lua`
- [Container View](modules/inv_overhaul_container_view.md) — `scripts/loot/inv_overhaul_container_view.lua`
- [Corpse Marker](modules/inv_overhaul_corpse_marker.md) — `scripts/loot/widgets/inv_overhaul_corpse_marker.lua`
- [Drag Cursor](modules/inv_overhaul_drag_cursor.md) — `scripts/compatibility/ui_runtime/inv_overhaul_drag_cursor.lua`
- [Drop Slot](modules/inv_overhaul_drop_slot.md) — `scripts/player_inventory/widgets/inv_overhaul_drop_slot.lua`
- [Equip Slot](modules/inv_overhaul_equip_slot.md) — `scripts/player_inventory/widgets/inv_overhaul_equip_slot.lua`
- [Holster Drop](modules/inv_overhaul_holster_drop.md) — `scripts/compatibility/quickslots/inv_overhaul_holster_drop.lua`
- [Inv Slot](modules/inv_overhaul_inv_slot.md) — `scripts/inventory_interface/inv_overhaul_inv_slot.lua`
- [Inventory](modules/inv_overhaul_inventory.md) — `scripts/player_inventory/inv_overhaul_inventory.lua`
- [Inventory Background](modules/inv_overhaul_inventory_background.md) — `scripts/inventory_interface/inv_overhaul_inventory_background.lua`
- [Inventory Bootstrap](modules/inv_overhaul_inventory_bootstrap.md) — `scripts/inventory_runtime/inv_overhaul_inventory_bootstrap.lua`
- [Inventory Controller](modules/inv_overhaul_inventory_controller.md) — `scripts/player_inventory/inv_overhaul_inventory_controller.lua`
- [Inventory Cursor](modules/inv_overhaul_inventory_cursor.md) — `scripts/player_inventory/widgets/inv_overhaul_inventory_cursor.lua`
- [Inventory Drag](modules/inv_overhaul_inventory_drag.md) — `scripts/player_inventory/inv_overhaul_inventory_drag.lua`
- [Inventory Drop](modules/inv_overhaul_inventory_drop.md) — `scripts/player_inventory/inv_overhaul_inventory_drop.lua`
- [Inventory Equipment](modules/inv_overhaul_inventory_equipment.md) — `scripts/player_inventory/inv_overhaul_inventory_equipment.lua`
- [Inventory Geometry](modules/inv_overhaul_inventory_geometry.md) — `scripts/inventory_interface/inv_overhaul_inventory_geometry.lua`
- [Inventory Guard](modules/inv_overhaul_inventory_guard.md) — `scripts/inventory_runtime/inv_overhaul_inventory_guard.lua`
- [Inventory Input Controller](modules/inv_overhaul_inventory_input_controller.md) — `scripts/player_inventory/inv_overhaul_inventory_input_controller.lua`
- [Inventory Items](modules/inv_overhaul_inventory_items.md) — `scripts/backpack/inv_overhaul_inventory_items.lua`
- [Inventory Layout](modules/inv_overhaul_inventory_layout.md) — `scripts/backpack/inv_overhaul_inventory_layout.lua`
- [Inventory Layout Runtime](modules/inv_overhaul_inventory_layout_runtime.md) — `scripts/backpack/inv_overhaul_inventory_layout_runtime.lua`
- [Inventory Overflow](modules/inv_overhaul_inventory_overflow.md) — `scripts/inventory_runtime/inv_overhaul_inventory_overflow.lua`
- [Inventory Paging](modules/inv_overhaul_inventory_paging.md) — `scripts/player_inventory/inv_overhaul_inventory_paging.lua`
- [Inventory Presenter](modules/inv_overhaul_inventory_presenter.md) — `scripts/player_inventory/inv_overhaul_inventory_presenter.lua`
- [Inventory Protocol](modules/inv_overhaul_inventory_protocol.md) — `scripts/inventory_interface/inv_overhaul_inventory_protocol.lua`
- [Inventory Quickslot Bindings](modules/inv_overhaul_inventory_quickslot_bindings.md) — `scripts/quickslots/inv_overhaul_inventory_quickslot_bindings.lua`
- [Inventory Snapshot](modules/inv_overhaul_inventory_snapshot.md) — `scripts/backpack/inv_overhaul_inventory_snapshot.lua`
- [Inventory Snapshot Seed](modules/inv_overhaul_inventory_snapshot_seed.md) — `scripts/inventory_runtime/inv_overhaul_inventory_snapshot_seed.lua`
- [Inventory Stack Consolidation](modules/inv_overhaul_inventory_stack_consolidation.md) — `scripts/inventory_runtime/inv_overhaul_inventory_stack_consolidation.lua`
- [Inventory Tooltip](modules/inv_overhaul_inventory_tooltip.md) — `scripts/inventory_interface/inv_overhaul_inventory_tooltip.lua`
- [Inventory View](modules/inv_overhaul_inventory_view.md) — `scripts/player_inventory/inv_overhaul_inventory_view.lua`
- [Loot Doll](modules/inv_overhaul_loot_doll.md) — `scripts/loot/widgets/inv_overhaul_loot_doll.lua`
- [Money Slot](modules/inv_overhaul_money_slot.md) — `scripts/inventory_interface/inv_overhaul_money_slot.lua`
- [Page Button](modules/inv_overhaul_page_button.md) — `scripts/inventory_interface/inv_overhaul_page_button.lua`
- [Page Counter](modules/inv_overhaul_page_counter.md) — `scripts/inventory_interface/inv_overhaul_page_counter.lua`
- [Quickslot Activation](modules/inv_overhaul_quickslot_activation.md) — `scripts/quickslots/inv_overhaul_quickslot_activation.lua`
- [Quickslot Consumables](modules/inv_overhaul_quickslot_consumables.md) — `scripts/quickslots/inv_overhaul_quickslot_consumables.lua`
- [Quickslot Equipment](modules/inv_overhaul_quickslot_equipment.md) — `scripts/quickslots/inv_overhaul_quickslot_equipment.lua`
- [Quickslot Feedback](modules/inv_overhaul_quickslot_feedback.md) — `scripts/compatibility/quickslots/inv_overhaul_quickslot_feedback.lua`
- [Quickslot Hands](modules/inv_overhaul_quickslot_hands.md) — `scripts/quickslots/inv_overhaul_quickslot_hands.lua`
- [Quickslot Help](modules/inv_overhaul_quickslot_help.md) — `scripts/inventory_interface/inv_overhaul_quickslot_help.lua`
- [Quickslot Requests](modules/inv_overhaul_quickslot_requests.md) — `10 request scripts`
- [Quickslot UI](modules/inv_overhaul_quickslot_ui.md) — `scripts/compatibility/quickslots/inv_overhaul_quickslot_ui.lua`
- [Quickslot Weapon](modules/inv_overhaul_quickslot_weapon.md) — `scripts/quickslots/inv_overhaul_quickslot_weapon.lua`
- [Quickslots](modules/inv_overhaul_quickslots.md) — `scripts/quickslots/inv_overhaul_quickslots.lua`
- [Special Inventory Bridge](modules/inv_overhaul_special_inventory_bridge.md) — `scripts/inventory_runtime/inv_overhaul_special_inventory_bridge.lua`
- [Texture Cache](modules/inv_overhaul_texture_cache.md) — `scripts/compatibility/ui_runtime/inv_overhaul_texture_cache.lua`
- [UI Texture Cache](modules/inv_overhaul_ui_texture_cache.md) — `scripts/compatibility/ui_runtime/inv_overhaul_ui_texture_cache.lua`
