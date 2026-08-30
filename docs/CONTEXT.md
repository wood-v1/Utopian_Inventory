# Codebase context

## Change routing

- Backpack item identity/count/order: [inventory items](modules/inv_overhaul_inventory_items.md), [layout runtime](modules/inv_overhaul_inventory_layout_runtime.md), [snapshots](modules/inv_overhaul_inventory_snapshot.md)
- Player inventory behavior or input: [player entry](modules/inv_overhaul_inventory.md), [controller](modules/inv_overhaul_inventory_controller.md)
- Player inventory rendering/widgets: [view](modules/inv_overhaul_inventory_view.md), [presenter](modules/inv_overhaul_inventory_presenter.md), [shared interface](modules/inv_overhaul_inv_slot.md)
- Equipment/drop/paging: [equipment](modules/inv_overhaul_inventory_equipment.md), [drop](modules/inv_overhaul_inventory_drop.md), [paging](modules/inv_overhaul_inventory_paging.md)
- Containers/corpses: [container entry](modules/inv_overhaul_container.md), [session](modules/inv_overhaul_container_session.md), [presenter](modules/inv_overhaul_container_presenter.md)
- Container transfers/drag/input: [transfer core](modules/inv_overhaul_container_transfer.md), [drag controller](modules/inv_overhaul_container_drag_controller.md), [input controller](modules/inv_overhaul_container_input_controller.md)
- Quickslots/hotkeys: [bindings](modules/inv_overhaul_inventory_quickslot_bindings.md), [activation](modules/inv_overhaul_quickslot_activation.md), [persistent effect](modules/inv_overhaul_quickslots.md), [request transports](modules/inv_overhaul_quickslot_requests.md)
- Capacity/overflow/stacking/special inventory: [guard](modules/inv_overhaul_inventory_guard.md), [overflow](modules/inv_overhaul_inventory_overflow.md), [stack consolidation](modules/inv_overhaul_inventory_stack_consolidation.md), [special bridge](modules/inv_overhaul_special_inventory_bridge.md)
- Numeric UI messages or hit testing: [inventory protocol](modules/inv_overhaul_inventory_protocol.md), [inventory geometry](modules/inv_overhaul_inventory_geometry.md), [container protocol](modules/inv_overhaul_container_protocol.md), [container geometry](modules/inv_overhaul_container_geometry.md)
- Dormant legacy behavior: [compatibility modules](README.md#module-documentation); active sources must not import `scripts/compatibility/`.

## Required workflow

Before modifying Lua code:

1. Read this file.
2. Read documentation for the affected module.
3. Check [API_INDEX.md](API_INDEX.md) if compiler-visible functions are involved.
4. Inspect implementation and callers only as needed; source remains authoritative.
5. Preserve typed Pathologic DSL semantics; do not assume standard Lua behavior.

After changing public APIs, responsibilities, imports, shared state, events/callbacks, important constants, or significant behavior, update the corresponding `/docs` files in the same task.
