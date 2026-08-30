# Inventory Guard

## Source

`scripts/inventory_runtime/inv_overhaul_inventory_guard.lua`

DSL unit: `maintask TEffect`

## Responsibility

Continuously enforces backpack capacity, queues overflow drops, consolidates stacks, seeds snapshots, and bridges special inventories.

## Dependencies

- `inv_overhaul_inventory_overflow` — Counts unequipped backpack entries and drops excess items near the player without treating equipped items as capacity usage.
- `inv_overhaul_inventory_stack_consolidation` — Merges duplicate stackable entries while preserving quickslot occurrence bindings and reporting layout-affecting removals.
- `inv_overhaul_inventory_snapshot_seed` — Creates the initial persistent backpack snapshot variables when an older save has no snapshot.
- `inv_overhaul_special_inventory_bridge` — Consumes native special-inventory remap requests and advances their persistent generation handshake.
- Pathologic native API — engine state, object access, persistence variables, UI messaging, timing, or rendering as listed per function.

## Used by

- No local import or direct runtime reference was resolved. It may be retained for external/save compatibility.

## State

- `m_iAllowedSlots: int` — current or cached layout value for allowed slots.
- `m_iQueueRead: int` — queue state for read.
- `m_iQueueWrite: int` — queue state for write.
- `m_iQueueCount: int` — queue state for count.
- `m_QueueID1: object` — queue state for m  id1.
- `m_QueueID2: object` — queue state for m  id2.
- `m_QueueCategory: object` — queue state for m  category.
- `m_CategoryCounts: object` — cached or current count for m category counts.
- `m_fMessageCooldown: float` — timing state for message cooldown.
- `m_iEffectGeneration: int` — mutable runtime state for effect generation.
- `m_bResolvingOverflow: bool` — lifecycle/behavior flag for resolving overflow.
- `m_bResolvingStackMerge: bool` — lifecycle/behavior flag for resolving stack merge.
- `m_bStackMergePending: bool` — deferred-work state for stack merge pending.

## Public API

No importable module API. Runtime entry points are documented under Events / callbacks.

## Internal API

### `GetPlayer() -> object`

Source: `scripts/inventory_runtime/inv_overhaul_inventory_guard.lua`

Purpose: Returns player in the inventory guard subsystem.

Parameters:

None.

Returns:

- `object` — result of: returns player in the inventory guard subsystem.

Side effects:

- None directly observable beyond calls listed below.

Called by:

- `scripts/inventory_runtime/inv_overhaul_inventory_guard.lua :: DropOverflowItem`
- `scripts/inventory_runtime/inv_overhaul_inventory_guard.lua :: init`
- `scripts/inventory_runtime/inv_overhaul_inventory_guard.lua :: OnInventoryAddItem`
- `scripts/inventory_runtime/inv_overhaul_inventory_guard.lua :: OnInventoryRemoveItem`

Calls:

- `native.self`

Notes / invariants:

- Maintask helper; callable within its task unless the engine invokes it by a documented callback name.

### `GetBackpackItemCount() -> int`

Source: `scripts/inventory_runtime/inv_overhaul_inventory_guard.lua`

Purpose: Returns backpack item count in the inventory guard subsystem.

Parameters:

None.

Returns:

- `number` (integer) — result of: returns backpack item count in the inventory guard subsystem.

Side effects:

- Delegates to compiler-visible module APIs and inherits their documented side effects.

Called by:

- `scripts/inventory_runtime/inv_overhaul_inventory_guard.lua :: ProcessOverflowQueue`
- `scripts/inventory_runtime/inv_overhaul_inventory_guard.lua :: init`
- `scripts/inventory_runtime/inv_overhaul_inventory_guard.lua :: OnInventoryRemoveItem`

Calls:

- `inv_overhaul_inventory_overflow.OverflowGetBackpackItemCount`

Notes / invariants:

- Maintask helper; callable within its task unless the engine invokes it by a documented callback name.

### `ProcessSpecialRemap() -> void`

Source: `scripts/inventory_runtime/inv_overhaul_inventory_guard.lua`

Purpose: Processes special remap in the inventory guard subsystem.

Parameters:

None.

Returns:

None.

Side effects:

- Delegates to compiler-visible module APIs and inherits their documented side effects.

Called by:

- `scripts/inventory_runtime/inv_overhaul_inventory_guard.lua :: init`

Calls:

- `inv_overhaul_special_inventory_bridge.Process`

Notes / invariants:

- Maintask helper; callable within its task unless the engine invokes it by a documented callback name.

### `InitializePersistentSnapshotIfMissing() -> void`

Source: `scripts/inventory_runtime/inv_overhaul_inventory_guard.lua`

Purpose: Initializes persistent snapshot if missing in the inventory guard subsystem.

Parameters:

None.

Returns:

None.

Side effects:

- Delegates to compiler-visible module APIs and inherits their documented side effects.

Called by:

- `scripts/inventory_runtime/inv_overhaul_inventory_guard.lua :: init`

Calls:

- `inv_overhaul_inventory_snapshot_seed.InitializeIfMissing`

Notes / invariants:

- Maintask helper; callable within its task unless the engine invokes it by a documented callback name.

### `ShowFullMessage() -> void`

Source: `scripts/inventory_runtime/inv_overhaul_inventory_guard.lua`

Purpose: Shows full message in the inventory guard subsystem.

Parameters:

None.

Returns:

None.

Side effects:

- Mutates module/task state: `m_fMessageCooldown`.
- Invokes engine/native operations: `native.CreateIntVector`, `native.SendWorldWndMessage`.
- May mutate engine/UI objects through: `text.add`.

Called by:

- `scripts/inventory_runtime/inv_overhaul_inventory_guard.lua :: ProcessOverflowQueue`

Calls:

- `native.CreateIntVector`
- `text.add`
- `native.SendWorldWndMessage`

Notes / invariants:

- Maintask helper; callable within its task unless the engine invokes it by a documented callback name.

### `EnqueueOverflow(index: int, itemID: int, category: int) -> void`

Source: `scripts/inventory_runtime/inv_overhaul_inventory_guard.lua`

Purpose: Enqueues overflow in the inventory guard subsystem.

Parameters:

- `index: int` — zero-based entry index in the relevant engine container/category.
- `itemID: int` — engine item or callback identifier interpreted by this function.
- `category: int` — zero-based engine inventory category identifier.

Returns:

None.

Side effects:

- Mutates module/task state: `m_iQueueWrite`, `m_iQueueCount`.
- Invokes engine/native operations: `native.Trace`.
- May mutate engine/UI objects through: `m_QueueID1.set`, `m_QueueID2.set`, `m_QueueCategory.set`.

Called by:

- `scripts/inventory_runtime/inv_overhaul_inventory_guard.lua :: OnInventoryAddItem`

Calls:

- `native.Trace`
- `m_QueueID1.set`
- `m_QueueID2.set`
- `m_QueueCategory.set`

Notes / invariants:

- Maintask helper; callable within its task unless the engine invokes it by a documented callback name.

### `DropOverflowItem(index: int, itemID: int, category: int) -> bool`

Source: `scripts/inventory_runtime/inv_overhaul_inventory_guard.lua`

Purpose: Drops overflow item in the inventory guard subsystem.

Parameters:

- `index: int` — zero-based entry index in the relevant engine container/category.
- `itemID: int` — engine item or callback identifier interpreted by this function.
- `category: int` — zero-based engine inventory category identifier.

Returns:

- `boolean` — result of: drops overflow item in the inventory guard subsystem.

Side effects:

- Invokes engine/native operations: `native.Trace`.
- May mutate engine/UI objects through: `m_CategoryCounts.set`.

Called by:

- `scripts/inventory_runtime/inv_overhaul_inventory_guard.lua :: ProcessOverflowQueue`

Calls:

- `inv_overhaul_inventory_overflow.DropItem`
- `GetPlayer`
- `player.GetItemCount`
- `m_CategoryCounts.set`
- `native.Trace`

Notes / invariants:

- Maintask helper; callable within its task unless the engine invokes it by a documented callback name.

### `ProcessOverflowQueue() -> void`

Source: `scripts/inventory_runtime/inv_overhaul_inventory_guard.lua`

Purpose: Processes overflow queue in the inventory guard subsystem.

Parameters:

None.

Returns:

None.

Side effects:

- Mutates module/task state: `m_bResolvingOverflow`, `m_iQueueCount`, `m_iQueueWrite`.
- Invokes engine/native operations: `native.Trace`.

Called by:

- `scripts/inventory_runtime/inv_overhaul_inventory_guard.lua :: init`

Calls:

- `m_QueueID1.get`
- `m_QueueID2.get`
- `m_QueueCategory.get`
- `GetBackpackItemCount`
- `DropOverflowItem`
- `native.Trace`
- `ShowFullMessage`

Notes / invariants:

- Maintask helper; callable within its task unless the engine invokes it by a documented callback name.

### `AdvanceContentGeneration() -> void`

Source: `scripts/inventory_runtime/inv_overhaul_inventory_guard.lua`

Purpose: Advances content generation in the inventory guard subsystem.

Parameters:

None.

Returns:

None.

Side effects:

- Delegates to compiler-visible module APIs and inherits their documented side effects.

Called by:

- `scripts/inventory_runtime/inv_overhaul_inventory_guard.lua :: OnInventoryAddItem`
- `scripts/inventory_runtime/inv_overhaul_inventory_guard.lua :: OnInventoryRemoveItem`

Calls:

- `inv_overhaul_inventory_overflow.AdvanceContentGeneration`

Notes / invariants:

- Maintask helper; callable within its task unless the engine invokes it by a documented callback name.

### `ConsolidatePlayerStacks() -> void`

Source: `scripts/inventory_runtime/inv_overhaul_inventory_guard.lua`

Purpose: Consolidates player stacks in the inventory guard subsystem.

Parameters:

None.

Returns:

None.

Side effects:

- Mutates module/task state: `m_bStackMergePending`, `m_bResolvingStackMerge`.

Called by:

- `scripts/inventory_runtime/inv_overhaul_inventory_guard.lua :: init`

Calls:

- `inv_overhaul_inventory_stack_consolidation.Consolidate`

Notes / invariants:

- Maintask helper; callable within its task unless the engine invokes it by a documented callback name.


## Events / callbacks

### `init() -> void`

Source: `scripts/inventory_runtime/inv_overhaul_inventory_guard.lua`

Purpose: Initializes the inventory guard runtime and establishes its starting state and engine/UI integration.

Parameters:

None.

Returns:

None.

Side effects:

- Mutates module/task state: `m_iQueueRead`, `m_iQueueWrite`, `m_iQueueCount`, `m_bResolvingOverflow`, `m_bResolvingStackMerge`, `m_bStackMergePending`, `m_fMessageCooldown`, `m_iEffectGeneration`, `… and 1 more`.
- Invokes engine/native operations: `native.CreateIntVector`, `native.Trace`, `native.Sleep`.
- May mutate engine/UI objects through: `m_QueueID1.add`, `m_QueueID2.add`, `m_QueueCategory.add`, `m_CategoryCounts.add`.

Called by:

- No in-repository caller was resolved; this may be an engine/XML callback or a conventionally public helper.

Calls:

- `native.CreateIntVector`
- `m_QueueID1.add`
- `m_QueueID2.add`
- `m_QueueCategory.add`
- `native.GetVariable`
- `GetPlayer`
- `player.GetItemCount`
- `m_CategoryCounts.add`
- `GetBackpackItemCount`
- `InitializePersistentSnapshotIfMissing`
- `inv_overhaul_special_inventory_bridge.Reset`
- `native.Trace`
- `… and 4 more`

Notes / invariants:

- Maintask helper; callable within its task unless the engine invokes it by a documented callback name.

### `OnInventoryAddItem(item: object, id1: int, id2: int, category: int) -> void`

Source: `scripts/inventory_runtime/inv_overhaul_inventory_guard.lua`

Purpose: Handles the engine/UI `OnInventoryAddItem` callback for the inventory guard runtime.

Parameters:

- `item: object` — engine inventory-item object; available properties and methods are supplied by the game.
- `id1: int` — engine item or callback identifier interpreted by this function.
- `id2: int` — engine item or callback identifier interpreted by this function.
- `category: int` — zero-based engine inventory category identifier.

Returns:

None.

Side effects:

- Mutates module/task state: `m_bStackMergePending`.
- Invokes engine/native operations: `native.Trace`.
- May mutate engine/UI objects through: `m_CategoryCounts.set`.

Called by:

- No in-repository caller was resolved; this may be an engine/XML callback or a conventionally public helper.

Calls:

- `GetPlayer`
- `m_CategoryCounts.get`
- `player.GetItemCount`
- `m_CategoryCounts.set`
- `AdvanceContentGeneration`
- `item.GetItemID`
- `native.GetInvItemMaxStackSize`
- `native.GetVariable`
- `native.Trace`
- `inv_overhaul_inventory_overflow.ShouldQueue`
- `EnqueueOverflow`

Notes / invariants:

- Callback recognition is name-based in `pathologic_lua_compiler`; `OnInventoryAddItem` is an engine event name.

### `OnInventoryRemoveItem(item: object, id1: int, id2: int, category: int) -> void`

Source: `scripts/inventory_runtime/inv_overhaul_inventory_guard.lua`

Purpose: Handles the engine/UI `OnInventoryRemoveItem` callback for the inventory guard runtime.

Parameters:

- `item: object` — engine inventory-item object; available properties and methods are supplied by the game.
- `id1: int` — engine item or callback identifier interpreted by this function.
- `id2: int` — engine item or callback identifier interpreted by this function.
- `category: int` — zero-based engine inventory category identifier.

Returns:

None.

Side effects:

- Mutates module/task state: `m_iAllowedSlots`.
- Invokes engine/native operations: `native.Trace`.
- May mutate engine/UI objects through: `m_CategoryCounts.set`.

Called by:

- No in-repository caller was resolved; this may be an engine/XML callback or a conventionally public helper.

Calls:

- `GetPlayer`
- `m_CategoryCounts.get`
- `player.GetItemCount`
- `m_CategoryCounts.set`
- `AdvanceContentGeneration`
- `native.GetVariable`
- `item.GetItemID`
- `native.Trace`
- `GetBackpackItemCount`

Notes / invariants:

- Callback recognition is name-based in `pathologic_lua_compiler`; `OnInventoryRemoveItem` is an engine event name.


## Important constants

- `c_iCWeapon: int = 0` — named behavior/layout value for cweapon.
- `c_iCClothes: int = 1` — named behavior/layout value for cclothes.
- `c_iCategoryCount: int = 5` — fixed limit/count for category count.
- `c_iInventoryCapacity: int = 56` — fixed limit/count for inventory capacity.
- `c_iSnapshotVersion: int = 1` — schema/runtime version marker for snapshot version.
- `c_iOverflowQueueSize: int = 64` — fixed limit/count for overflow queue size.
- `c_iWMHelpMessage: int = 200` — numeric engine/UI protocol value for wmhelp message.
- `c_iInventoryFullTextID: int = 1400` — localized string identifier for inventory full.
- `c_iQuickslotMissingTextID: int = 1405` — localized string identifier for quickslot missing.
- `c_iQuickslotUnusableTextID: int = 1406` — localized string identifier for quickslot unusable.
- `c_iQuickslotCount: int = 10` — fixed limit/count for quickslot count.
- `c_iWMQuickslotFeedback: int = 260` — numeric engine/UI protocol value for wmquickslot feedback.
- `c_iWMQuickslotHandsItem: int = 261` — numeric engine/UI protocol value for wmquickslot hands item.
- `c_iWMPlayerAddItem: int = 3` — numeric engine/UI protocol value for wmplayer add item.
- `c_fTickDelay: float = 0.05` — timing value, in seconds, for tick delay.
- `c_fMessageCooldown: float = 1.0` — timing value, in seconds, for message cooldown.

## Architectural notes

- This long-lived effect coordinates capacity, stack migration, snapshot seeding, and special-inventory remapping through shared engine variables, creating lifecycle and ordering coupling with native bootstrap code.
