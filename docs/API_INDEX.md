# Repository API index

Compiler-visible module functions and maintask engine entry points are indexed below. See each module document for parameters, returns, side effects, callers, and calls.

## Inventory Items

Source: `scripts/backpack/inv_overhaul_inventory_items.lua`

Responsibility: Builds the canonical projection of unequipped player items into backpack ordinals and cached category/index references.

Functions:

- `InitializeProjection() -> void` — Initializes projection in the inventory items subsystem.
- `ItemsGetPlayerContainer() -> object` — Returns player container for items in the inventory items subsystem.
- `IsEquipped(category: int, index: int) -> bool` — Returns whether equipped in the inventory items subsystem.
- `GetBackpackCount() -> int` — Returns backpack count in the inventory items subsystem.
- `CaptureIdentitySnapshot(snapshot: object) -> int` — Captures identity snapshot in the inventory items subsystem.
- `ItemsBuildIndexCache() -> void` — Builds index cache for items in the inventory items subsystem.
- `BuildIndexCacheAndSnapshot(snapshot: object) -> int` — Builds index cache and snapshot in the inventory items subsystem.
- `GetCachedBackpackCount() -> int` — Returns cached backpack count in the inventory items subsystem.
- `GetAppendedCategoryOrdinal(category: int, beforeCount: int) -> int` — Returns appended category ordinal in the inventory items subsystem.
- `InsertCachedEntry(insertedOrdinal: int, beforeCount: int, category: int, index: int) -> void` — Inserts cached entry in the inventory items subsystem.
- `RemoveCachedEntry(removedOrdinal: int, beforeCount: int, removedCategory: int, removedIndex: int) -> void` — Removes cached entry in the inventory items subsystem.
- `ItemsGetBackpackOrdinal(category: int, index: int) -> int` — Returns backpack ordinal for items in the inventory items subsystem.
- `GetOccurrence(category: int, index: int, itemID: int) -> int` — Returns occurrence in the inventory items subsystem.
- `ItemsEncodeReference(category: int, index: int) -> int` — Encodes reference for items in the inventory items subsystem.
- `ResolveCachedOrdinal(ordinal: int) -> int` — Resolves cached ordinal in the inventory items subsystem.
- `ItemsGetCachedCategory(ordinal: int) -> int` — Returns cached category for items in the inventory items subsystem.
- `ItemsGetCachedIndex(ordinal: int) -> int` — Returns cached index for items in the inventory items subsystem.
- `DecodeReferenceCategory(reference: int) -> int` — Decodes reference category in the inventory items subsystem.
- `DecodeReferenceIndex(reference: int) -> int` — Decodes reference index in the inventory items subsystem.

See: [module documentation](modules/inv_overhaul_inventory_items.md)

## Inventory Layout

Source: `scripts/backpack/inv_overhaul_inventory_layout.lua`

Responsibility: Defines the pure default mapping between backpack cells, linear slots, and pages.

Functions:

- `GetDefaultOrderForCell(cell: int) -> int` — Returns default order for cell in the inventory layout subsystem.
- `LayoutGetCellForLinearSlot(linear: int, visibleSlots: int, inventoryCapacity: int) -> int` — Returns cell for linear slot for layout in the inventory layout subsystem.
- `LayoutGetMaxPage(inventoryCapacity: int, visibleSlots: int) -> int` — Returns max page for layout in the inventory layout subsystem.

See: [module documentation](modules/inv_overhaul_inventory_layout.md)

## Inventory Layout Runtime

Source: `scripts/backpack/inv_overhaul_inventory_layout_runtime.lua`

Responsibility: Owns the mutable saved cell-to-item order, normalization, exact insertion/removal, swapping, and incremental persistence.

Functions:

- `LayoutRuntimeInitialize() -> void` — Initializes layout runtime in the inventory layout runtime subsystem.
- `LayoutRuntimeGetOrderValue(cell: int) -> int` — Returns order value for layout runtime in the inventory layout runtime subsystem.
- `SetOrderValue(cell: int, value: int) -> void` — Sets order value in the inventory layout runtime subsystem.
- `GetCellVariableName(cell: int) -> string` — Returns cell variable name in the inventory layout runtime subsystem.
- `IsOrderUsedBefore(cell: int, order: int) -> bool` — Returns whether order used before in the inventory layout runtime subsystem.
- `IsOrderUsedAtOrBefore(cell: int, order: int) -> bool` — Returns whether order used at or before in the inventory layout runtime subsystem.
- `FindFirstUnusedOrder(cell: int) -> int` — Finds first unused order in the inventory layout runtime subsystem.
- `Normalize() -> void` — Normalizes inventory layout runtime in the inventory layout runtime subsystem.
- `SaveAll() -> void` — Persists all in the inventory layout runtime subsystem.
- `QueueSave() -> void` — Queues save in the inventory layout runtime subsystem.
- `HasQueuedSave() -> bool` — Returns whether queued save in the inventory layout runtime subsystem.
- `ContinueQueuedSave() -> void` — Continues queued save in the inventory layout runtime subsystem.
- `Load() -> void` — Loads inventory layout runtime in the inventory layout runtime subsystem.
- `ContinueIncrementalLoad(loadStartCell: int) -> bool` — Continues incremental load in the inventory layout runtime subsystem.
- `SaveCell(cell: int) -> void` — Persists cell in the inventory layout runtime subsystem.
- `FinishIncrementalSave() -> void` — Completes incremental save in the inventory layout runtime subsystem.
- `LayoutRuntimeOrderFreeCellsByDisplay(itemCount: int, visibleSlots: int) -> bool` — Orders free cells by display for layout runtime in the inventory layout runtime subsystem.
- `LayoutRuntimeSwapCells(sourceCell: int, targetCell: int) -> bool` — Swaps cells for layout runtime in the inventory layout runtime subsystem.
- `RemoveOrdinal(removedOrder: int, beforeCount: int, currentCount: int, visibleSlots: int) -> void` — Removes ordinal in the inventory layout runtime subsystem.
- `RemoveOrdinalExact(removedOrder: int, beforeCount: int) -> bool` — Removes ordinal exact in the inventory layout runtime subsystem.
- `FindFirstFreeCell(itemCount: int, visibleSlots: int) -> int` — Finds first free cell in the inventory layout runtime subsystem.
- `InsertOrdinal(insertedOrder: int, beforeCount: int, targetCell: int, currentCount: int, visibleSlots: int) -> bool` — Inserts ordinal in the inventory layout runtime subsystem.
- `InsertOrdinalExactAtVisibleSlot(insertedOrder: int, beforeCount: int, page: int, visibleSlots: int, preferredSlot: int) -> bool` — Inserts ordinal exact at visible slot in the inventory layout runtime subsystem.

See: [module documentation](modules/inv_overhaul_inventory_layout_runtime.md)

## Inventory Snapshot

Source: `scripts/backpack/inv_overhaul_inventory_snapshot.lua`

Responsibility: Captures item-identity snapshots and reconciles saved layout cells after game inventory order changes or equipment mutations.

Functions:

- `SnapshotInitializeState() -> void` — Initializes state for snapshot in the inventory snapshot subsystem.
- `GetLastBackpackItemCount() -> int` — Returns last backpack item count in the inventory snapshot subsystem.
- `CapturePrevious() -> void` — Captures previous in the inventory snapshot subsystem.
- `ClampLastBackpackItemCount() -> void` — Clamps last backpack item count in the inventory snapshot subsystem.
- `CaptureCurrentCount() -> int` — Captures current count in the inventory snapshot subsystem.
- `BuildIndexCacheAndPrevious() -> int` — Builds index cache and previous in the inventory snapshot subsystem.
- `GetVariableName(ordinal: int) -> string` — Returns variable name in the inventory snapshot subsystem.
- `LoadPersistent() -> bool` — Loads persistent in the inventory snapshot subsystem.
- `CanReusePersistent() -> bool` — Returns whether reuse persistent in the inventory snapshot subsystem.
- `SavePersistent() -> void` — Persists persistent in the inventory snapshot subsystem.
- `CopyCurrent(newCount: int) -> void` — Copies current in the inventory snapshot subsystem.
- `Differs(newCount: int) -> bool` — Returns whether inventory snapshot in the inventory snapshot subsystem.
- `PersistCurrent() -> void` — Persists current in the inventory snapshot subsystem.
- `SnapshotGetCellForLinearSlot(linear: int, visibleSlots: int) -> int` — Returns cell for linear slot for snapshot in the inventory snapshot subsystem.
- `FindFirstUnusedDisplayCell(visibleSlots: int) -> int` — Finds first unused display cell in the inventory snapshot subsystem.
- `Reconcile(newCount: int, visibleSlots: int) -> void` — Reconciles inventory snapshot in the inventory snapshot subsystem.
- `RestoreAfterEquipmentReplacement(replacedOrder: int, itemCount: int, visibleSlots: int) -> bool` — Restores after equipment replacement in the inventory snapshot subsystem.
- `RestoreAfterEquipmentSelection(removedOrder: int, beforeCount: int, visibleSlots: int) -> bool` — Restores after equipment selection in the inventory snapshot subsystem.

See: [module documentation](modules/inv_overhaul_inventory_snapshot.md)

## Holster Drop

Source: `scripts/compatibility/quickslots/inv_overhaul_holster_drop.lua`

Responsibility: Retained compatibility effect that delays and completes a weapon holster/drop request.

Functions:

- `init() -> void` — Initializes the holster drop runtime and establishes its starting state and engine/UI integration.

See: [module documentation](modules/inv_overhaul_holster_drop.md)

## Quickslot Feedback

Source: `scripts/compatibility/quickslots/inv_overhaul_quickslot_feedback.lua`

Responsibility: Retained compatibility UI runtime combining quickslot activation and transient feedback rendering.

Functions:

- `init() -> void` — Initializes the quickslot feedback runtime and establishes its starting state and engine/UI integration.
- `OnGameMessage(id: int, data: object) -> void` — Handles the engine/UI `OnGameMessage` callback for the quickslot feedback runtime.
- `OnUpdate(delta: float) -> void` — Handles the engine/UI `OnUpdate` callback for the quickslot feedback runtime.
- `OnDraw() -> void` — Handles the engine/UI `OnDraw` callback for the quickslot feedback runtime.

See: [module documentation](modules/inv_overhaul_quickslot_feedback.md)

## Quickslot UI

Source: `scripts/compatibility/quickslots/inv_overhaul_quickslot_ui.lua`

Responsibility: Retained compatibility UI runtime that directly activates saved quickslot bindings.

Functions:

- `init() -> void` — Initializes the quickslot ui runtime and establishes its starting state and engine/UI integration.

See: [module documentation](modules/inv_overhaul_quickslot_ui.md)

## Drag Cursor

Source: `scripts/compatibility/ui_runtime/inv_overhaul_drag_cursor.lua`

Responsibility: Retained compatibility cursor form that renders a dragged item sprite.

Functions:

- `init() -> void` — Initializes the drag cursor runtime and establishes its starting state and engine/UI integration.
- `OnUpdate(delta: float) -> void` — Handles the engine/UI `OnUpdate` callback for the drag cursor runtime.
- `OnDraw() -> void` — Handles the engine/UI `OnDraw` callback for the drag cursor runtime.

See: [module documentation](modules/inv_overhaul_drag_cursor.md)

## Texture Cache

Source: `scripts/compatibility/ui_runtime/inv_overhaul_texture_cache.lua`

Responsibility: Retained compatibility placeholder form with an empty initialization entry point.

Functions:

- `init() -> void` — Initializes the texture cache runtime and establishes its starting state and engine/UI integration.

See: [module documentation](modules/inv_overhaul_texture_cache.md)

## UI Texture Cache

Source: `scripts/compatibility/ui_runtime/inv_overhaul_ui_texture_cache.lua`

Responsibility: Retained compatibility runtime that incrementally preloads item textures for older UI paths.

Functions:

- `init() -> void` — Initializes the ui texture cache runtime and establishes its starting state and engine/UI integration.
- `OnUpdate(delta: float) -> void` — Handles the engine/UI `OnUpdate` callback for the ui texture cache runtime.

See: [module documentation](modules/inv_overhaul_ui_texture_cache.md)

## Inv Slot

Source: `scripts/inventory_interface/inv_overhaul_inv_slot.lua`

Responsibility: Renders one reusable inventory slot form and translates mouse interaction into controller protocol messages.

Functions:

- `init() -> void` — Initializes the inv slot runtime and establishes its starting state and engine/UI integration.
- `OnDraw() -> void` — Handles the engine/UI `OnDraw` callback for the inv slot runtime.
- `OnLButtonDown(x: int, y: int) -> void` — Handles the engine/UI `OnLButtonDown` callback for the inv slot runtime.
- `OnLButtonUp(x: int, y: int) -> void` — Handles the engine/UI `OnLButtonUp` callback for the inv slot runtime.
- `OnRButtonDown(x: int, y: int) -> void` — Handles the engine/UI `OnRButtonDown` callback for the inv slot runtime.
- `OnDragBegin(x: int, y: int) -> void` — Handles the engine/UI `OnDragBegin` callback for the inv slot runtime.
- `OnDragEnd(x: int, y: int, accepted: bool) -> void` — Handles the engine/UI `OnDragEnd` callback for the inv slot runtime.
- `OnMouseEnter() -> void` — Handles the engine/UI `OnMouseEnter` callback for the inv slot runtime.
- `OnMouseMove(x: int, y: int) -> void` — Handles the engine/UI `OnMouseMove` callback for the inv slot runtime.
- `OnMouseLeave() -> void` — Handles the engine/UI `OnMouseLeave` callback for the inv slot runtime.
- `OnUIMessage(message: int, sender: string, data: object) -> void` — Handles the engine/UI `OnUIMessage` callback for the inv slot runtime.

See: [module documentation](modules/inv_overhaul_inv_slot.md)

## Inventory Background

Source: `scripts/inventory_interface/inv_overhaul_inventory_background.lua`

Responsibility: Renders the shared panel background and forwards panel-level pointer events to the owning controller.

Functions:

- `init() -> void` — Initializes the inventory background runtime and establishes its starting state and engine/UI integration.
- `OnDraw() -> void` — Handles the engine/UI `OnDraw` callback for the inventory background runtime.
- `OnMouseMove(x: int, y: int) -> void` — Handles the engine/UI `OnMouseMove` callback for the inventory background runtime.
- `OnMouseLeave() -> void` — Handles the engine/UI `OnMouseLeave` callback for the inventory background runtime.
- `OnLButtonDown(x: int, y: int) -> void` — Handles the engine/UI `OnLButtonDown` callback for the inventory background runtime.
- `OnLButtonUp(x: int, y: int) -> void` — Handles the engine/UI `OnLButtonUp` callback for the inventory background runtime.
- `OnRButtonDown(x: int, y: int) -> void` — Handles the engine/UI `OnRButtonDown` callback for the inventory background runtime.
- `OnDragBegin(x: int, y: int) -> void` — Handles the engine/UI `OnDragBegin` callback for the inventory background runtime.
- `OnDragEnd(x: int, y: int, accepted: bool) -> void` — Handles the engine/UI `OnDragEnd` callback for the inventory background runtime.
- `OnUIMessage(message: int, sender: string, data: object) -> void` — Handles the engine/UI `OnUIMessage` callback for the inventory background runtime.

See: [module documentation](modules/inv_overhaul_inventory_background.md)

## Inventory Geometry

Source: `scripts/inventory_interface/inv_overhaul_inventory_geometry.lua`

Responsibility: Maps supported window sizes and character branches to player-grid, equipment, money, paging, and doll hit-test geometry.

Functions:

- `InterfaceGeometryGetGridStartX(windowWidth: int) -> int` — Returns grid start x for interface geometry in the inventory geometry subsystem.
- `InterfaceGeometryGetGridStartY(windowWidth: int) -> int` — Returns grid start y for interface geometry in the inventory geometry subsystem.
- `InterfaceGeometryGetGridStep(windowWidth: int) -> int` — Returns grid step for interface geometry in the inventory geometry subsystem.
- `InterfaceGeometryGetGridColumns(windowWidth: int) -> int` — Returns grid columns for interface geometry in the inventory geometry subsystem.
- `InterfaceGeometryGetVisibleSlots(windowWidth: int) -> int` — Returns visible slots for interface geometry in the inventory geometry subsystem.
- `GetSlotSize(windowWidth: int) -> int` — Returns slot size in the inventory geometry subsystem.
- `GetEquipmentSlotSize(windowWidth: int) -> int` — Returns equipment slot size in the inventory geometry subsystem.
- `IsInsideRect(x: int, y: int, left: int, top: int, width: int, height: int) -> bool` — Returns whether inside rect in the inventory geometry subsystem.
- `InterfaceGeometryIsInsideSlotDropArea(windowWidth: int, inset: int, localX: int, localY: int) -> bool` — Returns whether inside slot drop area for interface geometry in the inventory geometry subsystem.
- `FindBackpackSlot(windowWidth: int, visibleSlots: int, inset: int, x: int, y: int) -> int` — Finds backpack slot in the inventory geometry subsystem.
- `GetSpecialTargetLeft(windowWidth: int, branch: int, target: int) -> int` — Returns special target left in the inventory geometry subsystem.
- `GetSpecialTargetTop(windowWidth: int, branch: int, target: int) -> int` — Returns special target top in the inventory geometry subsystem.
- `InterfaceGeometryIsInsideSpecialTarget(windowWidth: int, branch: int, target: int, x: int, y: int) -> bool` — Returns whether inside special target for interface geometry in the inventory geometry subsystem.
- `InterfaceGeometryGetMoneyLeft(windowWidth: int) -> int` — Returns money left for interface geometry in the inventory geometry subsystem.
- `InterfaceGeometryGetMoneyTop(windowWidth: int, branch: int) -> int` — Returns money top for interface geometry in the inventory geometry subsystem.
- `InterfaceGeometryIsInsideMoney(windowWidth: int, branch: int, x: int, y: int) -> bool` — Returns whether inside money for interface geometry in the inventory geometry subsystem.
- `InterfaceGeometryGetPageControlX(windowWidth: int) -> int` — Returns page control x for interface geometry in the inventory geometry subsystem.
- `InterfaceGeometryGetPageControlY(windowWidth: int, branch: int) -> int` — Returns page control y for interface geometry in the inventory geometry subsystem.
- `InterfaceGeometryIsInsidePlayerPaging(windowWidth: int, branch: int, maxPage: int, x: int, y: int) -> bool` — Returns whether inside player paging for interface geometry in the inventory geometry subsystem.
- `InterfaceGeometryIsInsideQuickslotHelp(windowWidth: int, x: int, y: int) -> bool` — Returns whether inside quickslot help for interface geometry in the inventory geometry subsystem.
- `GetDollLeft(layoutWidth: int) -> int` — Returns doll left in the inventory geometry subsystem.
- `GetDollTop(layoutWidth: int) -> int` — Returns doll top in the inventory geometry subsystem.
- `GetDollTargetMessage(layoutWidth: int, branch: int, globalX: int, globalY: int) -> int` — Returns doll target message in the inventory geometry subsystem.

See: [module documentation](modules/inv_overhaul_inventory_geometry.md)

## Inventory Protocol

Source: `scripts/inventory_interface/inv_overhaul_inventory_protocol.lua`

Responsibility: Defines and encodes the numeric UI message protocol shared by inventory forms and controllers.

Functions:

- `EncodePanelPointer(base: int, x: int, y: int) -> int` — Encodes panel pointer in the inventory protocol subsystem.
- `InterfaceProtocolDecodePanelPointerX(message: int, base: int) -> int` — Decodes panel pointer x for interface protocol in the inventory protocol subsystem.
- `InterfaceProtocolDecodePanelPointerY(message: int, base: int) -> int` — Decodes panel pointer y for interface protocol in the inventory protocol subsystem.
- `EncodeGridRenderer(slot: int, operation: int, value: int) -> int` — Encodes grid renderer in the inventory protocol subsystem.
- `DecodeGridRendererSlot(message: int) -> int` — Decodes grid renderer slot in the inventory protocol subsystem.
- `DecodeGridRendererOperation(message: int) -> int` — Decodes grid renderer operation in the inventory protocol subsystem.
- `DecodeGridRendererValue(message: int) -> int` — Decodes grid renderer value in the inventory protocol subsystem.
- `GetSlotWindowName(slot: int) -> string` — Returns slot window name in the inventory protocol subsystem.
- `GetSlotBySender(sender: string, visibleSlots: int) -> int` — Returns slot by sender in the inventory protocol subsystem.
- `GetSpecialTargetBySender(sender: string) -> int` — Returns special target by sender in the inventory protocol subsystem.
- `GetDollTargetByHoverMessage(message: int) -> int` — Returns doll target by hover message in the inventory protocol subsystem.
- `GetDollTargetBySourceMessage(message: int, base: int) -> int` — Returns doll target by source message in the inventory protocol subsystem.
- `GetDollSourceMessage(targetMessage: int, base: int) -> int` — Returns doll source message in the inventory protocol subsystem.

See: [module documentation](modules/inv_overhaul_inventory_protocol.md)

## Inventory Tooltip

Source: `scripts/inventory_interface/inv_overhaul_inventory_tooltip.lua`

Responsibility: Owns shared tooltip text, money pseudo-item metadata, suspension, and show/hide messaging.

Functions:

- `InterfaceTooltipInitializeState() -> void` — Initializes state for interface tooltip in the inventory tooltip subsystem.
- `InitializeMoneyItem() -> void` — Initializes money item in the inventory tooltip subsystem.
- `GetMoneyItemID() -> int` — Returns money item id in the inventory tooltip subsystem.
- `GetTarget() -> int` — Returns target in the inventory tooltip subsystem.
- `IsSuspended() -> bool` — Returns whether suspended in the inventory tooltip subsystem.
- `Suspend(delay: float) -> void` — Suspends tooltip publication for the requested delay.
- `InterfaceTooltipClear() -> void` — Clears interface tooltip in the inventory tooltip subsystem.
- `AdvanceSuspension(delta: float) -> void` — Advances suspension in the inventory tooltip subsystem.
- `ShowText(newTarget: int, textID: int) -> void` — Shows text in the inventory tooltip subsystem.
- `ShowMoneyForTarget(newTarget: int) -> void` — Shows money for target in the inventory tooltip subsystem.
- `ShowMoney() -> void` — Shows money in the inventory tooltip subsystem.
- `ShowItem(newTarget: int, item: object) -> void` — Shows item in the inventory tooltip subsystem.

See: [module documentation](modules/inv_overhaul_inventory_tooltip.md)

## Money Slot

Source: `scripts/inventory_interface/inv_overhaul_money_slot.lua`

Responsibility: Renders the money slot and responds to money-display UI messages.

Functions:

- `init() -> void` — Initializes the money slot runtime and establishes its starting state and engine/UI integration.
- `OnDraw() -> void` — Handles the engine/UI `OnDraw` callback for the money slot runtime.
- `OnUIMessage(message: int, sender: string, data: object) -> void` — Handles the engine/UI `OnUIMessage` callback for the money slot runtime.

See: [module documentation](modules/inv_overhaul_money_slot.md)

## Page Button

Source: `scripts/inventory_interface/inv_overhaul_page_button.lua`

Responsibility: Renders and emits interaction messages for one previous/next page button.

Functions:

- `init() -> void` — Initializes the page button runtime and establishes its starting state and engine/UI integration.
- `OnDraw() -> void` — Handles the engine/UI `OnDraw` callback for the page button runtime.
- `OnMouseEnter() -> void` — Handles the engine/UI `OnMouseEnter` callback for the page button runtime.
- `OnMouseLeave() -> void` — Handles the engine/UI `OnMouseLeave` callback for the page button runtime.
- `OnLButtonDown(x: int, y: int) -> void` — Handles the engine/UI `OnLButtonDown` callback for the page button runtime.
- `OnLButtonUp(x: int, y: int) -> void` — Handles the engine/UI `OnLButtonUp` callback for the page button runtime.
- `OnUIMessage(message: int, sender: string, data: object) -> void` — Handles the engine/UI `OnUIMessage` callback for the page button runtime.

See: [module documentation](modules/inv_overhaul_page_button.md)

## Page Counter

Source: `scripts/inventory_interface/inv_overhaul_page_counter.lua`

Responsibility: Renders the current page label supplied by the owning controller.

Functions:

- `init() -> void` — Initializes the page counter runtime and establishes its starting state and engine/UI integration.
- `OnDraw() -> void` — Handles the engine/UI `OnDraw` callback for the page counter runtime.
- `OnUIMessage(message: int, sender: string, data: object) -> void` — Handles the engine/UI `OnUIMessage` callback for the page counter runtime.

See: [module documentation](modules/inv_overhaul_page_counter.md)

## Quickslot Help

Source: `scripts/inventory_interface/inv_overhaul_quickslot_help.lua`

Responsibility: Publishes the quickslot-help tooltip from its hoverable UI form.

Functions:

- `init() -> void` — Initializes the quickslot help runtime and establishes its starting state and engine/UI integration.
- `OnMouseEnter() -> void` — Handles the engine/UI `OnMouseEnter` callback for the quickslot help runtime.
- `OnMouseMove(x: int, y: int) -> void` — Handles the engine/UI `OnMouseMove` callback for the quickslot help runtime.
- `OnMouseLeave() -> void` — Handles the engine/UI `OnMouseLeave` callback for the quickslot help runtime.

See: [module documentation](modules/inv_overhaul_quickslot_help.md)

## Inventory Bootstrap

Source: `scripts/inventory_runtime/inv_overhaul_inventory_bootstrap.lua`

Responsibility: Starts the persistent inventory guard and quickslot player effects after the native bootstrap hook creates the player task.

Functions:

- `init() -> void` — Initializes the inventory bootstrap runtime and establishes its starting state and engine/UI integration.

See: [module documentation](modules/inv_overhaul_inventory_bootstrap.md)

## Inventory Guard

Source: `scripts/inventory_runtime/inv_overhaul_inventory_guard.lua`

Responsibility: Continuously enforces backpack capacity, queues overflow drops, consolidates stacks, seeds snapshots, and bridges special inventories.

Functions:

- `init() -> void` — Initializes the inventory guard runtime and establishes its starting state and engine/UI integration.
- `OnInventoryAddItem(item: object, id1: int, id2: int, category: int) -> void` — Handles the engine/UI `OnInventoryAddItem` callback for the inventory guard runtime.
- `OnInventoryRemoveItem(item: object, id1: int, id2: int, category: int) -> void` — Handles the engine/UI `OnInventoryRemoveItem` callback for the inventory guard runtime.

See: [module documentation](modules/inv_overhaul_inventory_guard.md)

## Inventory Overflow

Source: `scripts/inventory_runtime/inv_overhaul_inventory_overflow.lua`

Responsibility: Counts unequipped backpack entries and drops excess items near the player without treating equipped items as capacity usage.

Functions:

- `OverflowGetPlayer() -> object` — Returns player for overflow in the inventory overflow subsystem.
- `OverflowIsEquippedItem(category: int, index: int) -> bool` — Returns whether equipped item for overflow in the inventory overflow subsystem.
- `OverflowGetBackpackItemCount() -> int` — Returns backpack item count for overflow in the inventory overflow subsystem.
- `ShouldQueue(allowedSlots: int, previousCategoryCount: int, currentCategoryCount: int) -> bool` — Returns whether queue in the inventory overflow subsystem.
- `DropItem(index: int, itemID: int, category: int) -> bool` — Drops item in the inventory overflow subsystem.
- `AdvanceContentGeneration() -> void` — Advances content generation in the inventory overflow subsystem.

See: [module documentation](modules/inv_overhaul_inventory_overflow.md)

## Inventory Snapshot Seed

Source: `scripts/inventory_runtime/inv_overhaul_inventory_snapshot_seed.lua`

Responsibility: Creates the initial persistent backpack snapshot variables when an older save has no snapshot.

Functions:

- `VariableName(ordinal: int) -> string` — Returns the shared engine-variable name used for variable name in the inventory snapshot seed subsystem.
- `InitializeIfMissing() -> void` — Initializes if missing in the inventory snapshot seed subsystem.

See: [module documentation](modules/inv_overhaul_inventory_snapshot_seed.md)

## Inventory Stack Consolidation

Source: `scripts/inventory_runtime/inv_overhaul_inventory_stack_consolidation.lua`

Responsibility: Merges duplicate stackable entries while preserving quickslot occurrence bindings and reporting layout-affecting removals.

Functions:

- `StackItemVariable(slot: int) -> string` — Returns the shared engine-variable name used for stack item variable in the inventory stack consolidation subsystem.
- `StackCategoryVariable(slot: int) -> string` — Returns the shared engine-variable name used for stack category variable in the inventory stack consolidation subsystem.
- `StackOccurrenceVariable(slot: int) -> string` — Returns the shared engine-variable name used for stack occurrence variable in the inventory stack consolidation subsystem.
- `StackDepletedVariable(slot: int) -> string` — Returns whether variable for stack in the inventory stack consolidation subsystem.
- `NormalizeQuickslots(category: int, itemID: int) -> void` — Normalizes quickslots in the inventory stack consolidation subsystem.
- `GetOtherAmount(player: object, category: int, keepIndex: int, itemID: int) -> int` — Returns other amount in the inventory stack consolidation subsystem.
- `Merge(player: object, category: int, keepIndex: int, itemID: int, count: int) -> bool` — Merges inventory stack consolidation in the inventory stack consolidation subsystem.
- `Consolidate(categoryCounts: object) -> bool` — Consolidates inventory stack consolidation in the inventory stack consolidation subsystem.

See: [module documentation](modules/inv_overhaul_inventory_stack_consolidation.md)

## Special Inventory Bridge

Source: `scripts/inventory_runtime/inv_overhaul_special_inventory_bridge.lua`

Responsibility: Consumes native special-inventory remap requests and advances their persistent generation handshake.

Functions:

- `Reset() -> void` — Resets special inventory bridge in the special inventory bridge subsystem.
- `Process() -> void` — Processes special inventory bridge in the special inventory bridge subsystem.

See: [module documentation](modules/inv_overhaul_special_inventory_bridge.md)

## Container

Source: `scripts/loot/inv_overhaul_container.lua`

Responsibility: Is the container/corpse UI maintask and delegates initialization, callbacks, and frame updates to loot-domain modules.

Functions:

- `init() -> void` — Initializes the container runtime and establishes its starting state and engine/UI integration.
- `OnUIMessage(message: int, sender: string, data: object) -> void` — Handles the engine/UI `OnUIMessage` callback for the container runtime.
- `OnUpdate(delta: float) -> void` — Handles the engine/UI `OnUpdate` callback for the container runtime.
- `OnMouseMove(x: int, y: int) -> void` — Handles the engine/UI `OnMouseMove` callback for the container runtime.
- `OnMouseLeave() -> void` — Handles the engine/UI `OnMouseLeave` callback for the container runtime.
- `OnLButtonUp(x: int, y: int) -> void` — Handles the engine/UI `OnLButtonUp` callback for the container runtime.
- `OnChar(char: int) -> void` — Handles the engine/UI `OnChar` callback for the container runtime.
- `OnKeyDown(key: int) -> void` — Handles the engine/UI `OnKeyDown` callback for the container runtime.
- `OnKeyUp(key: int) -> void` — Handles the engine/UI `OnKeyUp` callback for the container runtime.

See: [module documentation](modules/inv_overhaul_container.md)

## Container Bootstrap

Source: `scripts/loot/inv_overhaul_container_bootstrap.lua`

Responsibility: Stages the container screen's initial loading and readiness handshake.

Functions:

- `LootBootstrapInitializeState() -> void` — Initializes state for loot bootstrap in the container bootstrap subsystem.
- `InitializePersistentPlayerSnapshot() -> void` — Initializes persistent player snapshot in the container bootstrap subsystem.
- `LootBootstrapOrderFreeCellsByDisplay() -> void` — Orders free cells by display for loot bootstrap in the container bootstrap subsystem.
- `LootBootstrapAdvance(delta: float) -> void` — Advances loot bootstrap in the container bootstrap subsystem.

See: [module documentation](modules/inv_overhaul_container_bootstrap.md)

## Container Drag

Source: `scripts/loot/inv_overhaul_container_drag.lua`

Responsibility: Owns container-screen drag state, source identity, target highlighting, and drag cancellation/commit bookkeeping.

Functions:

- `LootDragInitializeState() -> void` — Initializes state for loot drag in the container drag subsystem.
- `BeginPlayerSource(newSource: int, newItemID: int, newCategory: int, newIndex: int, newCell: int) -> void` — Begins player source in the container drag subsystem.
- `BeginExternalSource(newSource: int, newKind: int, newItemID: int, newIndex: int, newOrdinal: int, newVisual: int) -> void` — Begins external source in the container drag subsystem.
- `ClearSource() -> void` — Clears source in the container drag subsystem.
- `LootDragIsActive() -> bool` — Returns whether active for loot drag in the container drag subsystem.
- `GetSource() -> int` — Returns source in the container drag subsystem.
- `GetKind() -> int` — Returns kind in the container drag subsystem.
- `LootDragGetItemID() -> int` — Returns item id for loot drag in the container drag subsystem.
- `GetPlayerCategory() -> int` — Returns player category in the container drag subsystem.
- `GetPlayerIndex() -> int` — Returns player index in the container drag subsystem.
- `GetPlayerCell() -> int` — Returns player cell in the container drag subsystem.
- `GetContainerIndex() -> int` — Returns container index in the container drag subsystem.
- `GetContainerOrdinal() -> int` — Returns container ordinal in the container drag subsystem.
- `GetContainerVisual() -> int` — Returns container visual in the container drag subsystem.
- `LootDragGetHighlightedTarget() -> int` — Returns highlighted target for loot drag in the container drag subsystem.
- `LootDragSetHighlightedTarget(target: int) -> void` — Sets highlighted target for loot drag in the container drag subsystem.
- `RecordPointerTarget(target: int, sameSource: bool, compatible: bool) -> int` — Records pointer target in the container drag subsystem.
- `LootDragResolveReleaseTarget(target: int) -> int` — Resolves release target for loot drag in the container drag subsystem.
- `LootDragBeginPageHover(action: int) -> bool` — Begins page hover for loot drag in the container drag subsystem.
- `LootDragCanCancelPageHover(action: int) -> bool` — Returns whether cancel page hover for loot drag in the container drag subsystem.
- `LootDragClearPageHover() -> void` — Clears page hover for loot drag in the container drag subsystem.
- `LootDragGetPageHoverAction() -> int` — Returns page hover action for loot drag in the container drag subsystem.
- `LootDragGetPageHoverElapsed() -> float` — Returns page hover elapsed for loot drag in the container drag subsystem.
- `LootDragAdvancePageHover(delta: float) -> int` — Advances page hover for loot drag in the container drag subsystem.

See: [module documentation](modules/inv_overhaul_container_drag.md)

## Container Drag Controller

Source: `scripts/loot/inv_overhaul_container_drag_controller.lua`

Responsibility: Resolves pointer targets and coordinates completion of container-screen drag actions.

Functions:

- `LootDragControllerGetTargetBySender(sender: string) -> int` — Returns target by sender for loot drag controller in the container drag controller subsystem.
- `LootDragControllerFindTargetAt(x: int, y: int) -> int` — Finds target at for loot drag controller in the container drag controller subsystem.
- `LootDragControllerIsTargetCompatible(target: int) -> bool` — Returns whether target compatible for loot drag controller in the container drag controller subsystem.
- `ResolveSource(source: int) -> bool` — Resolves source in the container drag controller subsystem.
- `BeginCursor(source: int) -> bool` — Begins cursor in the container drag controller subsystem.
- `EndCursor() -> void` — Ends cursor in the container drag controller subsystem.
- `LootDragControllerSetHighlightedTarget(target: int) -> void` — Sets highlighted target for loot drag controller in the container drag controller subsystem.
- `LootDragControllerApplyPointerTarget(target: int) -> void` — Applies pointer target for loot drag controller in the container drag controller subsystem.
- `CancelPageHover(action: int) -> void` — Cancels page hover in the container drag controller subsystem.
- `Start(source: int) -> void` — Starts container drag controller in the container drag controller subsystem.
- `Finish(target: int) -> void` — Completes container drag controller in the container drag controller subsystem.

See: [module documentation](modules/inv_overhaul_container_drag_controller.md)

## Container Feedback

Source: `scripts/loot/inv_overhaul_container_feedback.lua`

Responsibility: Owns transient loot-screen message cooldown and localized feedback publication.

Functions:

- `LootFeedbackInitializeState() -> void` — Initializes state for loot feedback in the container feedback subsystem.
- `LootFeedbackShowInventoryFull() -> void` — Shows inventory full for loot feedback in the container feedback subsystem.
- `ShowContainerFull() -> void` — Shows container full in the container feedback subsystem.
- `LootFeedbackAdvance(delta: float) -> void` — Advances loot feedback in the container feedback subsystem.

See: [module documentation](modules/inv_overhaul_container_feedback.md)

## Container Geometry

Source: `scripts/loot/inv_overhaul_container_geometry.lua`

Responsibility: Maps supported layouts to player, container, organ, money, paging, and pointer hit-test geometry.

Functions:

- `LootGeometryGetVisibleSlots(windowWidth: int) -> int` — Returns visible slots for loot geometry in the container geometry subsystem.
- `LootGeometryGetGridStartX(windowWidth: int) -> int` — Returns grid start x for loot geometry in the container geometry subsystem.
- `LootGeometryGetGridStartY(windowWidth: int) -> int` — Returns grid start y for loot geometry in the container geometry subsystem.
- `LootGeometryGetGridStep(windowWidth: int) -> int` — Returns grid step for loot geometry in the container geometry subsystem.
- `LootGeometryGetGridColumns(windowWidth: int) -> int` — Returns grid columns for loot geometry in the container geometry subsystem.
- `GetContainerStartX(windowWidth: int) -> int` — Returns container start x in the container geometry subsystem.
- `GetContainerStartY(windowWidth: int) -> int` — Returns container start y in the container geometry subsystem.
- `GetOrganStartX(windowWidth: int) -> int` — Returns organ start x in the container geometry subsystem.
- `GetOrganStartY(windowWidth: int) -> int` — Returns organ start y in the container geometry subsystem.
- `GetOrganStep(windowWidth: int) -> int` — Returns organ step in the container geometry subsystem.
- `LootGeometryGetMoneyLeft(windowWidth: int) -> int` — Returns money left for loot geometry in the container geometry subsystem.
- `LootGeometryGetMoneyTop(windowWidth: int) -> int` — Returns money top for loot geometry in the container geometry subsystem.
- `GetSlotHotZone(windowWidth: int) -> int` — Returns slot hot zone in the container geometry subsystem.
- `GetOrganSlotHotZone(windowWidth: int) -> int` — Returns organ slot hot zone in the container geometry subsystem.
- `LootGeometryIsInsideSlotDropArea(localX: int, localY: int, hotZone: int) -> bool` — Returns whether inside slot drop area for loot geometry in the container geometry subsystem.
- `FindGridSlotAt(x: int, y: int, startX: int, startY: int, columns: int, rows: int, count: int, hotZone: int, step: int) -> int` — Finds grid slot at in the container geometry subsystem.
- `FindPlayerSlotAt(windowWidth: int, visibleSlots: int, x: int, y: int) -> int` — Finds player slot at in the container geometry subsystem.
- `FindContainerSlotAt(windowWidth: int, slotCount: int, x: int, y: int) -> int` — Finds container slot at in the container geometry subsystem.
- `FindOrganSlotAt(windowWidth: int, slotCount: int, x: int, y: int) -> int` — Finds organ slot at in the container geometry subsystem.
- `LootGeometryIsInsideMoney(windowWidth: int, x: int, y: int) -> bool` — Returns whether inside money for loot geometry in the container geometry subsystem.
- `LootGeometryIsInsideQuickslotHelp(windowWidth: int, x: int, y: int) -> bool` — Returns whether inside quickslot help for loot geometry in the container geometry subsystem.
- `GetPlayerPageControlX(windowWidth: int) -> int` — Returns player page control x in the container geometry subsystem.
- `GetPlayerPageControlY(windowWidth: int) -> int` — Returns player page control y in the container geometry subsystem.
- `GetContainerPageControlX(windowWidth: int) -> int` — Returns container page control x in the container geometry subsystem.
- `GetContainerPageControlY(windowWidth: int, slotCount: int) -> int` — Returns container page control y in the container geometry subsystem.
- `IsInsidePageControl(maxPage: int, x: int, y: int, controlX: int, controlY: int) -> bool` — Returns whether inside page control in the container geometry subsystem.
- `GetPageControlAction(x: int, y: int, controlX: int, controlY: int) -> int` — Returns page control action in the container geometry subsystem.
- `IsPageButtonHovered(action: int, currentPage: int, maxPage: int, x: int, y: int, controlX: int, controlY: int) -> bool` — Returns whether page button hovered in the container geometry subsystem.
- `LootGeometryDecodePanelPointerX(message: int, base: int) -> int` — Decodes panel pointer x for loot geometry in the container geometry subsystem.
- `LootGeometryDecodePanelPointerY(message: int, base: int) -> int` — Decodes panel pointer y for loot geometry in the container geometry subsystem.

See: [module documentation](modules/inv_overhaul_container_geometry.md)

## Container Input Controller

Source: `scripts/loot/inv_overhaul_container_input_controller.lua`

Responsibility: Routes loot-screen UI messages, keyboard input, and contextual actions to the appropriate domain controller.

Functions:

- `LootInputInitializeState() -> void` — Initializes state for loot input in the container input controller subsystem.
- `LootInputAssignHoveredQuickslot(slot: int) -> void` — Assigns hovered quickslot for loot input in the container input controller subsystem.
- `LootInputHandleModifiedDrop(source: int) -> bool` — Handles modified drop for loot input in the container input controller subsystem.
- `LootInputStartPanelPointerDrag(x: int, y: int) -> void` — Starts panel pointer drag for loot input in the container input controller subsystem.
- `LootInputHandlePanelPointer(message: int) -> void` — Handles panel pointer for loot input in the container input controller subsystem.
- `HandleLifecycleMessage(message: int, sender: string) -> bool` — Handles lifecycle message in the container input controller subsystem.
- `HandlePagingMessage(message: int, sender: string) -> bool` — Handles paging message in the container input controller subsystem.
- `GetSlotPointerTarget(message: int, base: int, sender: string) -> int` — Returns slot pointer target in the container input controller subsystem.
- `HandleSlotPointerMessage(message: int, sender: string) -> bool` — Handles slot pointer message in the container input controller subsystem.
- `LootInputHandleDragLifecycleMessage(message: int, sender: string) -> bool` — Handles drag lifecycle message for loot input in the container input controller subsystem.
- `LootInputHandleRegularSlotMessage(message: int, sender: string, data: object) -> bool` — Handles regular slot message for loot input in the container input controller subsystem.
- `HandleUIMessage(message: int, sender: string, data: object) -> void` — Handles ui message in the container input controller subsystem.
- `PersistAndClose() -> void` — Persists and close in the container input controller subsystem.
- `HandleChar(char: int) -> void` — Handles char in the container input controller subsystem.
- `HandleKeyDown(key: int) -> void` — Handles key down in the container input controller subsystem.
- `HandleKeyUp(key: int) -> void` — Handles key up in the container input controller subsystem.

See: [module documentation](modules/inv_overhaul_container_input_controller.md)

## Container Paging Controller

Source: `scripts/loot/inv_overhaul_container_paging_controller.lua`

Responsibility: Owns player/container page changes and drag-hover page switching on the loot screen.

Functions:

- `HandleControlAt(x: int, y: int) -> bool` — Handles control at in the container paging controller subsystem.
- `UpdateControlHover(x: int, y: int) -> void` — Updates control hover in the container paging controller subsystem.
- `GetDragHoverAction(sender: string) -> int` — Returns drag hover action in the container paging controller subsystem.
- `BeginDragHover(sender: string) -> void` — Begins drag hover in the container paging controller subsystem.
- `UpdateDragHover(delta: float) -> void` — Updates drag hover in the container paging controller subsystem.
- `SyncDragHoverFromCursor() -> void` — Synchronizes drag hover from cursor in the container paging controller subsystem.

See: [module documentation](modules/inv_overhaul_container_paging_controller.md)

## Container Player Actions

Source: `scripts/loot/inv_overhaul_container_player_actions.lua`

Responsibility: Implements player-side equip, unequip, use, and drop actions initiated from the loot screen.

Functions:

- `LootPlayerActionsSwapCells(sourceCell: int, targetCell: int) -> void` — Swaps cells for loot player actions in the container player actions subsystem.
- `DropToWorld(sourceSlot: int, requestedAmount: int) -> void` — Drops to world in the container player actions subsystem.
- `LootPlayerActionsMoveSlotToOtherPage(sourceSlot: int) -> void` — Moves slot to other page for loot player actions in the container player actions subsystem.

See: [module documentation](modules/inv_overhaul_container_player_actions.md)

## Container Presenter

Source: `scripts/loot/inv_overhaul_container_presenter.lua`

Responsibility: Projects session state into loot UI forms, including incremental item metadata/texture loading, money, organs, and page controls.

Functions:

- `LootPresenterInitializeState() -> void` — Initializes state for loot presenter in the container presenter subsystem.
- `GetWindowWidth() -> int` — Returns window width in the container presenter subsystem.
- `GetWindowHeight() -> int` — Returns window height in the container presenter subsystem.
- `LootPresenterGetVisibleSlots() -> int` — Returns visible slots for loot presenter in the container presenter subsystem.
- `GetPlayerPage() -> int` — Returns player page in the container presenter subsystem.
- `GetContainerPage() -> int` — Returns container page in the container presenter subsystem.
- `GetRenderedPlayerPage() -> int` — Returns rendered player page in the container presenter subsystem.
- `GetRenderedContainerPage() -> int` — Returns rendered container page in the container presenter subsystem.
- `LootPresenterIsCorpse() -> bool` — Returns whether corpse for loot presenter in the container presenter subsystem.
- `LootPresenterShowsOrgans() -> bool` — Returns whether organs for loot presenter in the container presenter subsystem.
- `SetPlayerPage(page: int) -> void` — Sets player page in the container presenter subsystem.
- `SetContainerPage(page: int) -> void` — Sets container page in the container presenter subsystem.
- `SetCorpseMode(newIsCorpse: bool, newShowOrgans: bool) -> void` — Sets corpse mode in the container presenter subsystem.
- `LootPresenterUpdateLayout() -> void` — Updates layout for loot presenter in the container presenter subsystem.
- `LootPresenterGetCellForLinearSlot(linear: int) -> int` — Returns cell for linear slot for loot presenter in the container presenter subsystem.
- `LootPresenterGetVisibleCell(slot: int) -> int` — Returns visible cell for loot presenter in the container presenter subsystem.
- `GetMaxPlayerPage() -> int` — Returns max player page in the container presenter subsystem.
- `ClampPlayerPage() -> void` — Clamps player page in the container presenter subsystem.
- `LootPresenterResolveVisibleSlot(slot: int) -> int` — Resolves visible slot for loot presenter in the container presenter subsystem.
- `QueueCachedPlayerEntryRefresh(category: int, index: int) -> void` — Queues cached player entry refresh in the container presenter subsystem.
- `ContinueCachedPlayerEntryRefresh() -> void` — Continues cached player entry refresh in the container presenter subsystem.
- `GetVisibleSlotForCell(cell: int) -> int` — Returns visible slot for cell in the container presenter subsystem.
- `GetNormalContainerItemCount() -> int` — Returns normal container item count in the container presenter subsystem.
- `BuildContainerIndexCache() -> void` — Builds container index cache in the container presenter subsystem.
- `ResolveContainerVisualSlot(slot: int) -> int` — Resolves container visual slot in the container presenter subsystem.
- `ResolveOrganVisualSlot(slot: int) -> int` — Resolves organ visual slot in the container presenter subsystem.
- `ClampContainerPage() -> void` — Clamps container page in the container presenter subsystem.
- `UpdatePlayerPageControls() -> void` — Updates player page controls in the container presenter subsystem.
- `UpdateContainerPageControls() -> void` — Updates container page controls in the container presenter subsystem.
- `LootPresenterUpdateMoney() -> void` — Updates money for loot presenter in the container presenter subsystem.
- `UpdatePlayerSlot(slot: int) -> void` — Updates player slot in the container presenter subsystem.
- `UpdatePlayerSlots() -> void` — Updates player slots in the container presenter subsystem.
- `UpdateContainerSlot(slot: int) -> void` — Updates container slot in the container presenter subsystem.
- `UpdateContainerSlots() -> void` — Updates container slots in the container presenter subsystem.
- `UpdateOrganSlots() -> void` — Updates organ slots in the container presenter subsystem.
- `UpdateAllSlots() -> void` — Updates all slots in the container presenter subsystem.
- `RefreshVisibleContainerItem(itemID: int, fallbackSlot: int) -> void` — Refreshes visible container item in the container presenter subsystem.
- `LootPresenterBeginInitialSlotLoad() -> void` — Begins initial slot load for loot presenter in the container presenter subsystem.
- `LootPresenterContinueInitialSlotLoad() -> void` — Continues initial slot load for loot presenter in the container presenter subsystem.
- `AdvanceMoneyPolling(delta: float) -> void` — Advances money polling in the container presenter subsystem.
- `ChangePlayerPage(delta: int) -> void` — Changes player page in the container presenter subsystem.
- `ChangeContainerPage(delta: int) -> void` — Changes container page in the container presenter subsystem.

See: [module documentation](modules/inv_overhaul_container_presenter.md)

## Container Projection

Source: `scripts/loot/inv_overhaul_container_projection.lua`

Responsibility: Builds and queries the visible container/corpse item projection independently of the player backpack projection.

Functions:

- `LootProjectionInitialize() -> void` — Initializes loot projection in the container projection subsystem.
- `GetContainerOrder(visual: int) -> int` — Returns container order in the container projection subsystem.
- `SetContainerOrder(visual: int, value: int) -> void` — Sets container order in the container projection subsystem.
- `IsOrganItem(item: object) -> bool` — Returns whether organ item in the container projection subsystem.
- `GetNormalItemCount(container: object) -> int` — Returns normal item count in the container projection subsystem.
- `LootProjectionBuildIndexCache(container: object) -> void` — Builds index cache for loot projection in the container projection subsystem.
- `GetCachedNormalCount() -> int` — Returns cached normal count in the container projection subsystem.
- `LootProjectionEncodeReference(index: int, ordinal: int) -> int` — Encodes reference for loot projection in the container projection subsystem.
- `GetReferenceIndex(reference: int) -> int` — Returns reference index in the container projection subsystem.
- `GetReferenceOrdinal(reference: int) -> int` — Returns reference ordinal in the container projection subsystem.
- `ResolveNormalOrdinal(ordinal: int) -> int` — Resolves normal ordinal in the container projection subsystem.
- `GetOrganSlotByItemID(itemID: int) -> int` — Returns organ slot by item id in the container projection subsystem.
- `ResolveOrganVisual(container: object, slot: int) -> int` — Resolves organ visual in the container projection subsystem.
- `GetLastOccupiedVisual() -> int` — Returns last occupied visual in the container projection subsystem.
- `LootProjectionGetMaxPage() -> int` — Returns max page for loot projection in the container projection subsystem.
- `FindFirstFreeContainerVisual(itemCount: int) -> int` — Finds first free container visual in the container projection subsystem.
- `InsertContainerOrdinalAt(page: int, insertedOrder: int, beforeCount: int, preferredSlot: int) -> bool` — Inserts container ordinal at in the container projection subsystem.
- `RemoveContainerOrdinal(removedOrder: int, beforeCount: int) -> void` — Removes container ordinal in the container projection subsystem.
- `SwapVisuals(sourceVisual: int, targetVisual: int) -> bool` — Swaps visuals in the container projection subsystem.

See: [module documentation](modules/inv_overhaul_container_projection.md)

## Container Protocol

Source: `scripts/loot/inv_overhaul_container_protocol.lua`

Responsibility: Defines the loot screen's numeric messages, target identifiers, and sender-name mappings.

Functions:

- `IsPlayerTarget(target: int, visibleSlots: int) -> bool` — Returns whether player target in the container protocol subsystem.
- `IsContainerTarget(target: int) -> bool` — Returns whether container target in the container protocol subsystem.
- `IsOrganTarget(target: int) -> bool` — Returns whether organ target in the container protocol subsystem.
- `GetContainerSlot(target: int) -> int` — Returns container slot in the container protocol subsystem.
- `GetOrganSlot(target: int) -> int` — Returns organ slot in the container protocol subsystem.
- `LootProtocolGetTargetBySender(sender: string, visibleSlots: int) -> int` — Returns target by sender for loot protocol in the container protocol subsystem.
- `LootProtocolFindTargetAt(windowWidth: int, visibleSlots: int, showOrgans: bool, x: int, y: int) -> int` — Finds target at for loot protocol in the container protocol subsystem.
- `LootProtocolIsTargetCompatible(sourceKind: int, target: int, visibleSlots: int) -> bool` — Returns whether target compatible for loot protocol in the container protocol subsystem.
- `LootProtocolGetSlotTargetFromPointerMessage(message: int, base: int, sender: string, visibleSlots: int, windowWidth: int) -> int` — Returns slot target from pointer message for loot protocol in the container protocol subsystem.
- `IsPanelPointerMessage(message: int) -> bool` — Returns whether panel pointer message in the container protocol subsystem.
- `GetPanelPointerAction(message: int) -> int` — Returns panel pointer action in the container protocol subsystem.
- `GetPanelPointerBase(message: int) -> int` — Returns panel pointer base in the container protocol subsystem.
- `GetSlotPointerAction(message: int) -> int` — Returns slot pointer action in the container protocol subsystem.
- `GetSlotPointerBase(message: int) -> int` — Returns slot pointer base in the container protocol subsystem.

See: [module documentation](modules/inv_overhaul_container_protocol.md)

## Container Quick Transfer

Source: `scripts/loot/inv_overhaul_container_quick_transfer.lua`

Responsibility: Chooses and executes the appropriate contextual quick-transfer direction for a clicked loot-screen slot.

Functions:

- `Execute(source: int, wholeStack: bool) -> void` — Executes a contextual whole-stack or single-item transfer for the selected loot-screen source.

See: [module documentation](modules/inv_overhaul_container_quick_transfer.md)

## Container Session

Source: `scripts/loot/inv_overhaul_container_session.lua`

Responsibility: Owns the active external container object, container/corpse kind, generation tracking, and close lifecycle.

Functions:

- `LootSessionInitializeState() -> void` — Initializes state for loot session in the container session subsystem.
- `LootSessionIsCorpse() -> bool` — Returns whether corpse for loot session in the container session subsystem.
- `LootSessionShowsOrgans() -> bool` — Returns whether organs for loot session in the container session subsystem.
- `ActivateCorpseMode() -> void` — Activates corpse mode in the container session subsystem.
- `DetectContainerKind() -> void` — Detects container kind in the container session subsystem.
- `LootSessionAdvance(delta: float) -> void` — Advances loot session in the container session subsystem.
- `CloseWindow() -> void` — Closes window in the container session subsystem.

See: [module documentation](modules/inv_overhaul_container_session.md)

## Container Tooltip Controller

Source: `scripts/loot/inv_overhaul_container_tooltip_controller.lua`

Responsibility: Resolves loot-screen pointer targets into item, money, organ, and help tooltips.

Functions:

- `LootTooltipClear() -> void` — Clears loot tooltip in the container tooltip controller subsystem.
- `ShowPlayerPaging() -> void` — Shows player paging in the container tooltip controller subsystem.
- `ShowQuickslotHelp() -> void` — Shows quickslot help in the container tooltip controller subsystem.
- `LootTooltipIsInsidePlayerPaging(maxPlayerPage: int, windowWidth: int, x: int, y: int) -> bool` — Returns whether inside player paging for loot tooltip in the container tooltip controller subsystem.
- `ResolvePlayerItem(playerPage: int, visibleSlots: int, target: int) -> object` — Resolves player item in the container tooltip controller subsystem.
- `ResolveExternalItem(target: int, containerPage: int, showOrgans: bool) -> object` — Resolves external item in the container tooltip controller subsystem.
- `Update(windowWidth: int, visibleSlots: int, playerPage: int, containerPage: int, showOrgans: bool, maxPlayerPage: int, x: int, y: int) -> void` — Updates container tooltip controller in the container tooltip controller subsystem.

See: [module documentation](modules/inv_overhaul_container_tooltip_controller.md)

## Container Transfer

Source: `scripts/loot/inv_overhaul_container_transfer.lua`

Responsibility: Provides shared capacity checks, stack movement, and transfer primitives used by player/external transfer adapters.

Functions:

- `NormalizeAmount(requestedAmount: int, availableAmount: int) -> int` — Normalizes amount in the container transfer subsystem.
- `FindPlayerMergeIndex(player: object, category: int, itemID: int) -> int` — Finds player merge index in the container transfer subsystem.
- `GetPlayerItemTotalAmount(player: object, category: int, wantedItemID: int) -> int` — Returns player item total amount in the container transfer subsystem.
- `GetExternalItemTotalAmount(external: object, wantedItemID: int) -> int` — Returns external item total amount in the container transfer subsystem.
- `CreatePlayerToExternalOutcome(status: int, itemID: int, success: bool, beforeExternalAmount: int, afterExternalAmount: int) -> object` — Creates player to external outcome in the container transfer subsystem.
- `MovePlayerAmountToExternal(player: object, external: object, category: int, index: int, requestedAmount: int) -> object` — Moves player amount to external in the container transfer subsystem.
- `PlayerToExternalWasRejected(outcome: object) -> bool` — Returns whether rejected for player to external in the container transfer subsystem.
- `GetPlayerToExternalItemID(outcome: object) -> int` — Returns player to external item id in the container transfer subsystem.
- `GetPlayerToExternalSuccess(outcome: object) -> bool` — Returns player to external success in the container transfer subsystem.
- `GetPlayerToExternalBeforeAmount(outcome: object) -> int` — Returns player to external before amount in the container transfer subsystem.
- `GetPlayerToExternalAfterAmount(outcome: object) -> int` — Returns player to external after amount in the container transfer subsystem.
- `CreateExternalToPlayerOutcome(status: int, success: bool, beforePlayerAmount: int, afterPlayerAmount: int, sourceDepleted: bool) -> object` — Creates external to player outcome in the container transfer subsystem.
- `MoveExternalItemAmountToPlayer(player: object, external: object, item: object, organSource: bool, sourceIndex: int, amount: int, transferAmount: int, category: int, itemID: int) -> object` — Moves external item amount to player in the container transfer subsystem.
- `ExternalToPlayerWasRejected(outcome: object) -> bool` — Returns whether rejected for external to player in the container transfer subsystem.
- `GetExternalToPlayerSuccess(outcome: object) -> bool` — Returns external to player success in the container transfer subsystem.
- `GetExternalToPlayerBeforeAmount(outcome: object) -> int` — Returns external to player before amount in the container transfer subsystem.
- `GetExternalToPlayerAfterAmount(outcome: object) -> int` — Returns external to player after amount in the container transfer subsystem.
- `ExternalToPlayerSourceDepleted(outcome: object) -> bool` — Returns whether external to player source in the container transfer subsystem.
- `SwapAppendedEntry(external: object, exchangedItem: object, exchangedAmount: int, exchangedIndex: int, expectedAppendedItemID: int, countBefore: int) -> int` — Swaps appended entry in the container transfer subsystem.

See: [module documentation](modules/inv_overhaul_container_transfer.md)

## Container Transfer External

Source: `scripts/loot/inv_overhaul_container_transfer_external.lua`

Responsibility: Adapts shared transfer operations for items moving from the external container into the player backpack.

Functions:

- `ExternalTransferInitializeState() -> void` — Transfers initialize state for external in the container transfer external subsystem.
- `GetAppendedBackpackOrdinal(category: int, beforeCount: int) -> int` — Returns appended backpack ordinal in the container transfer external subsystem.
- `InsertPlayerCache(insertedOrdinal: int, beforeCount: int, category: int, index: int) -> bool` — Inserts player cache in the container transfer external subsystem.
- `MoveAmountToPlayer(organSource: bool, sourceSlot: int, targetSlot: int, requestedAmount: int, restorePageIfMerged: int) -> void` — Moves amount to player in the container transfer external subsystem.
- `MoveResolvedAmountToPlayer(organSource: bool, sourceIndex: int, sourceOrdinal: int, sourceSlot: int, targetSlot: int, requestedAmount: int, restorePageIfMerged: int) -> void` — Moves resolved amount to player in the container transfer external subsystem.
- `MoveToPlayer(organSource: bool, sourceSlot: int, targetSlot: int, restorePageIfMerged: int) -> void` — Moves to player in the container transfer external subsystem.

See: [module documentation](modules/inv_overhaul_container_transfer_external.md)

## Container Transfer Player

Source: `scripts/loot/inv_overhaul_container_transfer_player.lua`

Responsibility: Adapts shared transfer operations for items moving from the player backpack into the external container.

Functions:

- `RemovePlayerCache(removedOrdinal: int, beforeCount: int, removedCategory: int, removedIndex: int) -> bool` — Removes player cache in the container transfer player subsystem.
- `MoveAmountToContainer(sourceSlot: int, targetSlot: int, requestedAmount: int, restorePageIfMerged: int) -> void` — Moves amount to container in the container transfer player subsystem.
- `MoveToContainer(sourceSlot: int, targetSlot: int, restorePageIfMerged: int) -> void` — Moves to container in the container transfer player subsystem.
- `ExchangeWithContainer(sourceSlot: int, targetSlot: int) -> void` — Exchanges with container in the container transfer player subsystem.

See: [module documentation](modules/inv_overhaul_container_transfer_player.md)

## Container View

Source: `scripts/loot/inv_overhaul_container_view.lua`

Responsibility: Defines loot-screen window names and emits UI messages that render slots, organs, drag state, and page controls.

Functions:

- `GetPlayerSlotWndName(slot: int) -> string` — Returns player slot wnd name in the container view subsystem.
- `GetContainerSlotWndName(slot: int) -> string` — Returns container slot wnd name in the container view subsystem.
- `GetOrganSlotWndName(slot: int) -> string` — Returns organ slot wnd name in the container view subsystem.
- `LootViewGetTargetWndName(target: int, visibleSlots: int) -> string` — Returns target wnd name for loot view in the container view subsystem.
- `LootViewConfigureSlotRenderSize(windowWidth: int, visibleSlots: int) -> void` — Configures slot render size for loot view in the container view subsystem.
- `LootViewUpdatePageControls(prefix: string, currentPage: int, maxPage: int) -> void` — Updates page controls for loot view in the container view subsystem.
- `ResetPageControls(prefix: string, resetPreviousMessage: int, resetNextMessage: int) -> void` — Resets page controls in the container view subsystem.
- `RenderPlayerSlotUnavailable(wnd: string) -> void` — Renders player slot unavailable in the container view subsystem.
- `BeginPlayerSlot(wnd: string) -> void` — Begins player slot in the container view subsystem.
- `RenderPlayerSlotEmpty(wnd: string) -> void` — Renders player slot empty in the container view subsystem.
- `RenderPlayerSlotItem(wnd: string, item: object, amount: int) -> void` — Renders player slot item in the container view subsystem.
- `RenderPlayerQuickslot(wnd: string, quickslot: int) -> void` — Renders player quickslot in the container view subsystem.
- `RenderContainerSlotEmpty(wnd: string) -> void` — Renders container slot empty in the container view subsystem.
- `RenderContainerSlotItem(wnd: string, item: object, amount: int) -> void` — Renders container slot item in the container view subsystem.
- `RenderOrganSlotHidden(wnd: string) -> void` — Renders organ slot hidden in the container view subsystem.
- `BeginOrganSlot(wnd: string) -> void` — Begins organ slot in the container view subsystem.
- `RenderOrganSlotEmpty(wnd: string) -> void` — Renders organ slot empty in the container view subsystem.
- `RenderOrganSlotItem(wnd: string, item: object, amount: int) -> void` — Renders organ slot item in the container view subsystem.
- `BeginOrganSlotItem(wnd: string) -> void` — Begins organ slot item in the container view subsystem.
- `SetTargetHighlighted(target: int, visibleSlots: int, highlighted: bool) -> void` — Sets target highlighted in the container view subsystem.
- `SetPageButtonHover(wnd: string, highlighted: bool) -> void` — Sets page button hover in the container view subsystem.
- `ClearPageControlHover() -> void` — Clears page control hover in the container view subsystem.

See: [module documentation](modules/inv_overhaul_container_view.md)

## Corpse Marker

Source: `scripts/loot/widgets/inv_overhaul_corpse_marker.lua`

Responsibility: Renders the corpse-only marker form according to controller messages.

Functions:

- `init() -> void` — Initializes the corpse marker runtime and establishes its starting state and engine/UI integration.
- `OnUpdate(delta: float) -> void` — Handles the engine/UI `OnUpdate` callback for the corpse marker runtime.
- `OnUIMessage(message: int, sender: string, data: object) -> void` — Handles the engine/UI `OnUIMessage` callback for the corpse marker runtime.

See: [module documentation](modules/inv_overhaul_corpse_marker.md)

## Loot Doll

Source: `scripts/loot/widgets/inv_overhaul_loot_doll.lua`

Responsibility: Renders the container/corpse silhouette selected by controller messages.

Functions:

- `init() -> void` — Initializes the loot doll runtime and establishes its starting state and engine/UI integration.
- `OnUIMessage(message: int, sender: string, data: object) -> void` — Handles the engine/UI `OnUIMessage` callback for the loot doll runtime.

See: [module documentation](modules/inv_overhaul_loot_doll.md)

## Inventory

Source: `scripts/player_inventory/inv_overhaul_inventory.lua`

Responsibility: Is the player inventory UI maintask and forwards engine/UI callbacks into the player controller.

Functions:

- `init() -> void` — Initializes the inventory runtime and establishes its starting state and engine/UI integration.
- `OnUpdate(delta: float) -> void` — Handles the engine/UI `OnUpdate` callback for the inventory runtime.
- `OnUIMessage(message: int, sender: string, data: object) -> void` — Handles the engine/UI `OnUIMessage` callback for the inventory runtime.
- `OnLButtonDown(x: int, y: int) -> void` — Handles the engine/UI `OnLButtonDown` callback for the inventory runtime.
- `OnRButtonDown(x: int, y: int) -> void` — Handles the engine/UI `OnRButtonDown` callback for the inventory runtime.
- `OnMouseMove(x: int, y: int) -> void` — Handles the engine/UI `OnMouseMove` callback for the inventory runtime.
- `OnMouseLeave() -> void` — Handles the engine/UI `OnMouseLeave` callback for the inventory runtime.
- `OnLButtonUp(x: int, y: int) -> void` — Handles the engine/UI `OnLButtonUp` callback for the inventory runtime.
- `OnChar(char: int) -> void` — Handles the engine/UI `OnChar` callback for the inventory runtime.
- `OnKeyDown(key: int) -> void` — Handles the engine/UI `OnKeyDown` callback for the inventory runtime.
- `OnKeyUp(key: int) -> void` — Handles the engine/UI `OnKeyUp` callback for the inventory runtime.

See: [module documentation](modules/inv_overhaul_inventory.md)

## Inventory Controller

Source: `scripts/player_inventory/inv_overhaul_inventory_controller.lua`

Responsibility: Orchestrates the player inventory screen: initialization, projection, incremental rendering, equipment, drag/drop, paging, quickslots, tooltips, persistence, and callback routing.

Functions:

- `PlayerControllerInitialize() -> void` — Initializes player controller in the inventory controller subsystem.
- `ReadWindowWidth() -> int` — Returns window width in the inventory controller subsystem.
- `ReadVisibleSlots() -> int` — Returns visible slots in the inventory controller subsystem.
- `ReadPage() -> int` — Returns page in the inventory controller subsystem.
- `ReadDragSourceSlot() -> int` — Returns drag source slot in the inventory controller subsystem.
- `ReadDragSourceCell() -> int` — Returns drag source cell in the inventory controller subsystem.
- `ReadHighlightedSlot() -> int` — Returns highlighted slot in the inventory controller subsystem.
- `ReadDragItemCategory() -> int` — Returns drag item category in the inventory controller subsystem.
- `ReadDragItemIndex() -> int` — Returns drag item index in the inventory controller subsystem.
- `ReadDragItemGroup() -> int` — Returns drag item group in the inventory controller subsystem.
- `ReadDragItemIsWeapon() -> bool` — Returns drag item is weapon in the inventory controller subsystem.
- `ReadLastBackpackItemCount() -> int` — Returns last backpack item count in the inventory controller subsystem.
- `ReadLayoutLoadStartCell() -> int` — Returns layout load start cell in the inventory controller subsystem.
- `ReadPerfCacheEpoch() -> int` — Returns perf cache epoch in the inventory controller subsystem.
- `InitSlotOrder() -> void` — Initializes slot order in the inventory controller subsystem.
- `GetBranch() -> int` — Returns branch in the inventory controller subsystem.
- `PlayerControllerGetOrderValue(slot: int) -> int` — Returns order value for player controller in the inventory controller subsystem.
- `LoadLayoutVariables() -> void` — Loads layout variables in the inventory controller subsystem.
- `ContinueIncrementalLayoutLoad() -> bool` — Continues incremental layout load in the inventory controller subsystem.
- `SaveLayoutVariables() -> void` — Persists layout variables in the inventory controller subsystem.
- `QueueLayoutSave() -> void` — Queues layout save in the inventory controller subsystem.
- `ContinueLayoutSave() -> void` — Continues layout save in the inventory controller subsystem.
- `OrderFreeCellsByDisplayForCount(itemCount: int) -> void` — Orders free cells by display for count in the inventory controller subsystem.
- `PlayerControllerGetPlayerContainer() -> object` — Returns player container for player controller in the inventory controller subsystem.
- `BeginDragCursor(slot: int) -> void` — Begins drag cursor in the inventory controller subsystem.
- `EndDragCursor() -> void` — Ends drag cursor in the inventory controller subsystem.
- `PlayerControllerConfigureSlotRenderSize() -> void` — Configures slot render size for player controller in the inventory controller subsystem.
- `PlayerControllerUpdateLayout() -> void` — Updates layout for player controller in the inventory controller subsystem.
- `PlayerControllerSendGridRendererState(slot: int, operation: int, value: int, data: object) -> void` — Sends grid renderer state for player controller in the inventory controller subsystem.
- `PlayerControllerSetGridRendererHighlight(slot: int, enabled: bool) -> void` — Sets grid renderer highlight for player controller in the inventory controller subsystem.
- `PlayerControllerGetVisibleCell(slot: int) -> int` — Returns visible cell for player controller in the inventory controller subsystem.
- `PlayerControllerGetCellForLinearSlot(linear: int) -> int` — Returns cell for linear slot for player controller in the inventory controller subsystem.
- `PlayerControllerGetTargetWndName(target: int) -> string` — Returns target wnd name for player controller in the inventory controller subsystem.
- `PlayerControllerIsInsideSpecialTarget(target: int, x: int, y: int) -> bool` — Returns whether inside special target for player controller in the inventory controller subsystem.
- `PlayerControllerIsInsideMoney(x: int, y: int) -> bool` — Returns whether inside money for player controller in the inventory controller subsystem.
- `FindSpecialTargetAt(x: int, y: int) -> int` — Finds special target at in the inventory controller subsystem.
- `FindEquipmentTargetAt(x: int, y: int) -> int` — Finds equipment target at in the inventory controller subsystem.
- `PlayerControllerGetBackpackItemCount() -> int` — Returns backpack item count for player controller in the inventory controller subsystem.
- `LoadPersistentBackpackSnapshot() -> bool` — Loads persistent backpack snapshot in the inventory controller subsystem.
- `CanReusePersistentBackpackSnapshot() -> bool` — Returns whether reuse persistent backpack snapshot in the inventory controller subsystem.
- `SavePersistentBackpackSnapshot() -> void` — Persists persistent backpack snapshot in the inventory controller subsystem.
- `CopyCurrentBackpackSnapshot(newCount: int) -> void` — Copies current backpack snapshot in the inventory controller subsystem.
- `BackpackSnapshotDiffers(newCount: int) -> bool` — Returns whether backpack snapshot in the inventory controller subsystem.
- `PersistCurrentBackpackSnapshot() -> void` — Persists current backpack snapshot in the inventory controller subsystem.
- `ReconcileInventoryContentGeneration(currentGeneration: int) -> bool` — Reconciles inventory content generation in the inventory controller subsystem.
- `InitializePersistentBackpackSnapshot() -> void` — Initializes persistent backpack snapshot in the inventory controller subsystem.
- `ReconcileBackpackSnapshot(newCount: int) -> void` — Reconciles backpack snapshot in the inventory controller subsystem.
- `RestoreOrderAfterEquipmentReplacement(replacedOrder: int, itemCount: int) -> bool` — Restores order after equipment replacement in the inventory controller subsystem.
- `RestoreOrderAfterEquipmentSelection(removedOrder: int, beforeCount: int) -> bool` — Restores order after equipment selection in the inventory controller subsystem.
- `PlayerControllerShowInventoryFull() -> void` — Shows inventory full for player controller in the inventory controller subsystem.
- `PlayerControllerGetMaxPage() -> int` — Returns max page for player controller in the inventory controller subsystem.
- `ClampPage() -> void` — Clamps page in the inventory controller subsystem.
- `PlayerControllerUpdatePageControls() -> void` — Updates page controls for player controller in the inventory controller subsystem.
- `PlayerControllerResolveVisibleSlot(slot: int) -> int` — Resolves visible slot for player controller in the inventory controller subsystem.
- `BuildBackpackIndexCache() -> void` — Builds backpack index cache in the inventory controller subsystem.
- `BuildBackpackIndexCacheAndSnapshot() -> int` — Builds backpack index cache and snapshot in the inventory controller subsystem.
- `PlayerControllerUpdateMoney() -> void` — Updates money for player controller in the inventory controller subsystem.
- `InitializeQuickslotBindings() -> void` — Initializes quickslot bindings in the inventory controller subsystem.
- `RefreshQuickslotCache() -> void` — Refreshes quickslot cache in the inventory controller subsystem.
- `GetDisplayedQuickslot(category: int, index: int, itemID: int) -> int` — Returns displayed quickslot in the inventory controller subsystem.
- `AssignQuickslot(slot: int, category: int, index: int) -> void` — Assigns quickslot in the inventory controller subsystem.
- `GetQuickslotByKey(key: int) -> int` — Returns quickslot by key in the inventory controller subsystem.
- `PlayerControllerAssignHoveredQuickslot(slot: int) -> void` — Assigns hovered quickslot for player controller in the inventory controller subsystem.
- `PlayerControllerUpdateSlot(slot: int) -> void` — Updates slot for player controller in the inventory controller subsystem.
- `PlayerControllerIsItemTexturePreloaded(itemID: int, cacheEpoch: int) -> bool` — Returns whether item texture preloaded for player controller in the inventory controller subsystem.
- `PlayerControllerMarkItemTextureLoaded(category: int, index: int) -> void` — Marks item texture loaded for player controller in the inventory controller subsystem.
- `MeasureInitialTextureCacheCoverage() -> void` — Measures initial texture cache coverage in the inventory controller subsystem.
- `PlayerControllerReportFirstInitialItem() -> void` — Reports first initial item for player controller in the inventory controller subsystem.
- `PlayerControllerReportInitialLoadComplete() -> void` — Reports initial load complete for player controller in the inventory controller subsystem.
- `TryWarmStartGrid() -> void` — Attempts warm start grid in the inventory controller subsystem.
- `PlayerControllerBeginInitialSlotLoad() -> void` — Begins initial slot load for player controller in the inventory controller subsystem.
- `PlayerControllerContinueInitialSlotLoad() -> void` — Continues initial slot load for player controller in the inventory controller subsystem.
- `UpdateSlots() -> void` — Updates slots in the inventory controller subsystem.
- `BuildEquipmentIndexCache() -> void` — Builds equipment index cache in the inventory controller subsystem.
- `UpdateCachedEquipmentSlot(cache: int) -> void` — Updates cached equipment slot in the inventory controller subsystem.
- `UpdateEquipmentSlots() -> void` — Updates equipment slots in the inventory controller subsystem.
- `UpdateVisibleCell(cell: int) -> void` — Updates visible cell in the inventory controller subsystem.
- `RefreshEquipmentMutation(changedCell: int, equipmentTarget: int) -> void` — Refreshes equipment mutation in the inventory controller subsystem.
- `ResolveEquipmentTarget(target: int) -> int` — Resolves equipment target in the inventory controller subsystem.
- `ResolveDragSource(source: int) -> int` — Resolves drag source in the inventory controller subsystem.
- `UnequipItem(category: int, index: int) -> bool` — Unequips item in the inventory controller subsystem.
- `EquipDraggedItem(target: int, category: int, index: int) -> bool` — Equips dragged item in the inventory controller subsystem.
- `ToggleSlot(category: int, index: int) -> void` — Toggles slot in the inventory controller subsystem.
- `PlayerControllerHandleModifiedDrop(sourceSlot: int) -> bool` — Handles modified drop for player controller in the inventory controller subsystem.
- `PlayerControllerMoveSlotToOtherPage(sourceSlot: int) -> void` — Moves slot to other page for player controller in the inventory controller subsystem.
- `HandleSlotMessage(message: int, sender: string) -> bool` — Handles slot message in the inventory controller subsystem.
- `GetDragSourceBySender(sender: string) -> int` — Returns drag source by sender in the inventory controller subsystem.
- `IsSpecialTargetCompatible(target: int) -> bool` — Returns whether special target compatible in the inventory controller subsystem.
- `StartDragAction(source: int, sender: string) -> void` — Starts drag action in the inventory controller subsystem.
- `UnequipTarget(target: int, reason: string) -> void` — Unequips target in the inventory controller subsystem.
- `SwapSlotOrderCells(sourceCell: int, targetCell: int) -> void` — Swaps slot order cells in the inventory controller subsystem.
- `RemoveOrderOrdinal(removedOrder: int, beforeCount: int) -> void` — Removes order ordinal in the inventory controller subsystem.
- `FindFirstFreeVisualSlot(itemCount: int) -> int` — Finds first free visual slot in the inventory controller subsystem.
- `PlayerControllerGetBackpackOrdinal(category: int, index: int) -> int` — Returns backpack ordinal for player controller in the inventory controller subsystem.
- `InsertOrderOrdinal(insertedOrder: int, beforeCount: int) -> bool` — Inserts order ordinal in the inventory controller subsystem.
- `InsertOrderOrdinalAtCell(insertedOrder: int, beforeCount: int, targetCell: int) -> bool` — Inserts order ordinal at cell in the inventory controller subsystem.
- `SetHighlightedSlot(slot: int) -> void` — Sets highlighted slot in the inventory controller subsystem.
- `CancelDragAction() -> void` — Cancels drag action in the inventory controller subsystem.
- `FinishLeftAction(targetSlot: int) -> void` — Completes left action in the inventory controller subsystem.
- `FindBackpackSlotAt(x: int, y: int) -> int` — Finds backpack slot at in the inventory controller subsystem.
- `FindSlotAt(x: int, y: int) -> int` — Finds slot at in the inventory controller subsystem.
- `PlayerControllerIsInsideSlotDropArea(localX: int, localY: int) -> bool` — Returns whether inside slot drop area for player controller in the inventory controller subsystem.
- `FindSlotAtPointer(x: int, y: int) -> int` — Finds slot at pointer in the inventory controller subsystem.
- `UpdatePointerSlot(x: int, y: int) -> int` — Updates pointer slot in the inventory controller subsystem.
- `ApplyPointerSlot(slot: int) -> void` — Applies pointer slot in the inventory controller subsystem.
- `GetCurrentDropSlot(message: int, base: int, sender: string) -> int` — Returns current drop slot in the inventory controller subsystem.
- `PlayerControllerGetSlotTargetFromPointerMessage(message: int, base: int, sender: string) -> int` — Returns slot target from pointer message for player controller in the inventory controller subsystem.
- `ChangePage(delta: int) -> void` — Changes page in the inventory controller subsystem.
- `PlayerControllerGetDragPageHoverAction(sender: string) -> int` — Returns drag page hover action for player controller in the inventory controller subsystem.
- `BeginDragPageHover(sender: string) -> void` — Begins drag page hover in the inventory controller subsystem.
- `CancelDragPageHover(action: int) -> void` — Cancels drag page hover in the inventory controller subsystem.
- `UpdateDragPageHover(delta: float) -> void` — Updates drag page hover in the inventory controller subsystem.
- `SyncDragPageHoverFromCursor() -> void` — Synchronizes drag page hover from cursor in the inventory controller subsystem.
- `RunFramePreparationStage(delta: float) -> void` — Runs frame preparation stage in the inventory controller subsystem.
- `RunMetadataAndLoadingStage(delta: float) -> void` — Runs metadata and loading stage in the inventory controller subsystem.
- `RunPersistenceAndRefreshStage(delta: float) -> void` — Runs persistence and refresh stage in the inventory controller subsystem.
- `RunDragHoverStage(delta: float) -> void` — Runs drag hover stage in the inventory controller subsystem.
- `PlayerControllerStartPanelPointerDrag(x: int, y: int) -> void` — Starts panel pointer drag for player controller in the inventory controller subsystem.
- `PlayerControllerGetPageControlX() -> int` — Returns page control x for player controller in the inventory controller subsystem.
- `PlayerControllerGetPageControlY() -> int` — Returns page control y for player controller in the inventory controller subsystem.
- `PlayerControllerIsInsideQuickslotHelp(x: int, y: int) -> bool` — Returns whether inside quickslot help for player controller in the inventory controller subsystem.
- `PlayerControllerIsInsidePlayerPaging(x: int, y: int) -> bool` — Returns whether inside player paging for player controller in the inventory controller subsystem.
- `UpdatePanelTooltip(x: int, y: int) -> void` — Updates panel tooltip in the inventory controller subsystem.
- `PlayerControllerHandlePanelPointer(message: int) -> void` — Handles panel pointer for player controller in the inventory controller subsystem.
- `HandlePageControlAt(x: int, y: int) -> bool` — Handles page control at in the inventory controller subsystem.
- `UpdatePageControlHover(x: int, y: int) -> void` — Updates page control hover in the inventory controller subsystem.
- `HandleGlobalProtocolMessage(message: int, sender: string) -> bool` — Handles global protocol message in the inventory controller subsystem.
- `HandleEquipmentProtocolMessage(message: int, sender: string) -> bool` — Handles equipment protocol message in the inventory controller subsystem.
- `HandlePagingProtocolMessage(message: int, sender: string) -> bool` — Handles paging protocol message in the inventory controller subsystem.
- `HandleSlotPointerProtocolMessage(message: int, sender: string) -> bool` — Handles slot pointer protocol message in the inventory controller subsystem.
- `PlayerControllerHandleDragLifecycleMessage(message: int, sender: string) -> bool` — Handles drag lifecycle message for player controller in the inventory controller subsystem.
- `PlayerControllerHandleRegularSlotMessage(message: int, sender: string, data: object) -> bool` — Handles regular slot message for player controller in the inventory controller subsystem.
- `OnUIMessage(message: int, sender: string, data: object) -> void` — Handles the engine/UI `OnUIMessage` callback for the inventory controller runtime.
- `OnLButtonDown(x: int, y: int) -> void` — Handles the engine/UI `OnLButtonDown` callback for the inventory controller runtime.
- `OnRButtonDown(x: int, y: int) -> void` — Handles the engine/UI `OnRButtonDown` callback for the inventory controller runtime.
- `OnMouseMove(x: int, y: int) -> void` — Handles the engine/UI `OnMouseMove` callback for the inventory controller runtime.
- `OnMouseLeave() -> void` — Handles the engine/UI `OnMouseLeave` callback for the inventory controller runtime.
- `OnLButtonUp(x: int, y: int) -> void` — Handles the engine/UI `OnLButtonUp` callback for the inventory controller runtime.
- `CloseInventoryWindow() -> void` — Closes inventory window in the inventory controller subsystem.
- `OnChar(char: int) -> void` — Handles the engine/UI `OnChar` callback for the inventory controller runtime.
- `OnKeyDown(key: int) -> void` — Handles the engine/UI `OnKeyDown` callback for the inventory controller runtime.
- `OnKeyUp(key: int) -> void` — Handles the engine/UI `OnKeyUp` callback for the inventory controller runtime.

See: [module documentation](modules/inv_overhaul_inventory_controller.md)

## Inventory Drag

Source: `scripts/player_inventory/inv_overhaul_inventory_drag.lua`

Responsibility: Owns player-screen drag state, drag cursor publication, highlighting, and source/target bookkeeping.

Functions:

- `PlayerDragInitializeState() -> void` — Initializes state for player drag in the inventory drag subsystem.
- `BeginItem(newItemID: int, newCategory: int, newIndex: int, newGroup: int, newIsWeapon: bool) -> void` — Begins item in the inventory drag subsystem.
- `ClearItem() -> void` — Clears item in the inventory drag subsystem.
- `BeginTransaction(newSourceSlot: int, newSourceCell: int) -> void` — Begins transaction in the inventory drag subsystem.
- `ClearTransaction() -> void` — Clears transaction in the inventory drag subsystem.
- `PlayerDragIsActive() -> bool` — Returns whether active for player drag in the inventory drag subsystem.
- `GetSourceSlot() -> int` — Returns source slot in the inventory drag subsystem.
- `GetSourceCell() -> int` — Returns source cell in the inventory drag subsystem.
- `GetHoverTarget() -> int` — Returns hover target in the inventory drag subsystem.
- `SetHoverTarget(target: int) -> void` — Sets hover target in the inventory drag subsystem.
- `PlayerDragGetHighlightedTarget() -> int` — Returns highlighted target for player drag in the inventory drag subsystem.
- `PlayerDragSetHighlightedTarget(target: int) -> void` — Sets highlighted target for player drag in the inventory drag subsystem.
- `HasMoved() -> bool` — Returns whether moved in the inventory drag subsystem.
- `PlayerDragGetItemID() -> int` — Returns item id for player drag in the inventory drag subsystem.
- `GetItemCategory() -> int` — Returns item category in the inventory drag subsystem.
- `GetItemIndex() -> int` — Returns item index in the inventory drag subsystem.
- `GetItemGroup() -> int` — Returns item group in the inventory drag subsystem.
- `GetItemIsWeapon() -> bool` — Returns item is weapon in the inventory drag subsystem.
- `PlayerDragApplyPointerTarget(target: int, sameSource: bool) -> int` — Applies pointer target for player drag in the inventory drag subsystem.
- `PlayerDragResolveReleaseTarget(target: int) -> int` — Resolves release target for player drag in the inventory drag subsystem.
- `PlayerDragBeginPageHover(action: int) -> bool` — Begins page hover for player drag in the inventory drag subsystem.
- `PlayerDragCanCancelPageHover(action: int) -> bool` — Returns whether cancel page hover for player drag in the inventory drag subsystem.
- `PlayerDragClearPageHover() -> void` — Clears page hover for player drag in the inventory drag subsystem.
- `PlayerDragGetPageHoverAction() -> int` — Returns page hover action for player drag in the inventory drag subsystem.
- `PlayerDragGetPageHoverElapsed() -> float` — Returns page hover elapsed for player drag in the inventory drag subsystem.
- `PlayerDragAdvancePageHover(delta: float) -> int` — Advances page hover for player drag in the inventory drag subsystem.

See: [module documentation](modules/inv_overhaul_inventory_drag.md)

## Inventory Drop

Source: `scripts/player_inventory/inv_overhaul_inventory_drop.lua`

Responsibility: Drops a player inventory entry into the world through the engine container API.

Functions:

- `Slot(category: int, index: int, requestedAmount: int) -> bool` — Drops the requested amount of a player inventory entry into the world.

See: [module documentation](modules/inv_overhaul_inventory_drop.md)

## Inventory Equipment

Source: `scripts/player_inventory/inv_overhaul_inventory_equipment.lua`

Responsibility: Implements equipment compatibility, equip/unequip/replacement, and layout restoration around equipment mutations.

Functions:

- `InitializeCache() -> void` — Initializes cache in the inventory equipment subsystem.
- `BuildCache() -> void` — Builds cache in the inventory equipment subsystem.
- `PlayerEquipmentGetCachedCategory(cache: int) -> int` — Returns cached category for player equipment in the inventory equipment subsystem.
- `PlayerEquipmentGetCachedIndex(cache: int) -> int` — Returns cached index for player equipment in the inventory equipment subsystem.
- `ResolveTarget(target: int) -> int` — Resolves target in the inventory equipment subsystem.
- `Unequip(category: int, index: int) -> bool` — Unequips inventory equipment in the inventory equipment subsystem.
- `Equip(target: int, category: int, index: int) -> bool` — Equips inventory equipment in the inventory equipment subsystem.
- `PlayerEquipmentToggle(category: int, index: int) -> int` — Toggles player equipment in the inventory equipment subsystem.
- `PlayerEquipmentIsTargetCompatible(target: int, category: int, isWeapon: bool, group: int) -> bool` — Returns whether target compatible for player equipment in the inventory equipment subsystem.

See: [module documentation](modules/inv_overhaul_inventory_equipment.md)

## Inventory Input Controller

Source: `scripts/player_inventory/inv_overhaul_inventory_input_controller.lua`

Responsibility: Maps player-inventory keyboard and character input to close, paging, quickslot, and modified-click actions.

Functions:

- `PlayerInputGetSlotTargetFromPointerMessage(message: int, base: int, sender: string, visibleSlots: int, windowWidth: int, dropInset: int) -> int` — Returns slot target from pointer message for player input in the inventory input controller subsystem.
- `PlayerInputGetDragPageHoverAction(sender: string, maxPage: int) -> int` — Returns drag page hover action for player input in the inventory input controller subsystem.
- `PlayerInputGetPageControlX(windowWidth: int) -> int` — Returns page control x for player input in the inventory input controller subsystem.
- `PlayerInputGetPageControlY(windowWidth: int, branch: int) -> int` — Returns page control y for player input in the inventory input controller subsystem.
- `PlayerInputIsInsideQuickslotHelp(windowWidth: int, x: int, y: int) -> bool` — Returns whether inside quickslot help for player input in the inventory input controller subsystem.
- `PlayerInputIsInsidePlayerPaging(windowWidth: int, branch: int, maxPage: int, x: int, y: int) -> bool` — Returns whether inside player paging for player input in the inventory input controller subsystem.
- `DecodePanelPointerAction(message: int) -> int` — Decodes panel pointer action in the inventory input controller subsystem.
- `DecodePanelPointerBase(message: int) -> int` — Decodes panel pointer base in the inventory input controller subsystem.

See: [module documentation](modules/inv_overhaul_inventory_input_controller.md)

## Inventory Paging

Source: `scripts/player_inventory/inv_overhaul_inventory_paging.lua`

Responsibility: Owns player inventory page bounds, current page, and drag-hover page timing.

Functions:

- `PlayerPagingInitialize() -> void` — Initializes player paging in the inventory paging subsystem.
- `GetPage() -> int` — Returns page in the inventory paging subsystem.
- `PlayerPagingGetMaxPage(inventoryCapacity: int, visibleSlots: int) -> int` — Returns max page for player paging in the inventory paging subsystem.
- `Clamp(inventoryCapacity: int, visibleSlots: int) -> void` — Clamps inventory paging in the inventory paging subsystem.
- `Change(delta: int, inventoryCapacity: int, visibleSlots: int) -> void` — Changes inventory paging in the inventory paging subsystem.
- `PlayerPagingGetVisibleCell(slot: int, visibleSlots: int, inventoryCapacity: int) -> int` — Returns visible cell for player paging in the inventory paging subsystem.
- `PlayerPagingGetCellForLinearSlot(linear: int, visibleSlots: int, inventoryCapacity: int) -> int` — Returns cell for linear slot for player paging in the inventory paging subsystem.
- `GetNextPage(maxPage: int) -> int` — Returns next page in the inventory paging subsystem.
- `CanMove(action: int, maxPage: int) -> bool` — Returns whether move in the inventory paging subsystem.
- `GetCursorHoverAction(hoverTarget: int, maxPage: int) -> int` — Returns cursor hover action in the inventory paging subsystem.
- `GetControlAction(x: int, y: int, controlX: int, controlY: int) -> int` — Returns control action in the inventory paging subsystem.
- `IsControlHovered(action: int, x: int, y: int, controlX: int, controlY: int, maxPage: int) -> bool` — Returns whether control hovered in the inventory paging subsystem.

See: [module documentation](modules/inv_overhaul_inventory_paging.md)

## Inventory Presenter

Source: `scripts/player_inventory/inv_overhaul_inventory_presenter.lua`

Responsibility: Coordinates player-screen slot/equipment refreshes and incremental view publication.

Functions:

- `PlayerPresenterConfigureSlotRenderSize(windowWidth: int) -> void` — Configures slot render size for player presenter in the inventory presenter subsystem.
- `PlayerPresenterSendGridRendererState(slot: int, capacity: int, operation: int, value: int, data: object) -> void` — Sends grid renderer state for player presenter in the inventory presenter subsystem.
- `PlayerPresenterSetGridRendererHighlight(slot: int, enabled: bool) -> void` — Sets grid renderer highlight for player presenter in the inventory presenter subsystem.
- `PlayerPresenterUpdatePageControls(visibleSlots: int, capacity: int, maxPage: int, currentPage: int) -> void` — Updates page controls for player presenter in the inventory presenter subsystem.
- `PlayerPresenterUpdateMoney(container: object) -> void` — Updates money for player presenter in the inventory presenter subsystem.
- `PlayerPresenterUpdateSlot(slot: int, capacity: int, visibleCell: int, reference: int, container: object) -> void` — Updates slot for player presenter in the inventory presenter subsystem.
- `UpdateEquipmentSlot(cache: int, wndName: string, category: int, index: int, container: object, emptyMessage: int) -> void` — Updates equipment slot in the inventory presenter subsystem.
- `PlayerPresenterIsItemTexturePreloaded(itemID: int, cacheEpoch: int) -> bool` — Returns whether item texture preloaded for player presenter in the inventory presenter subsystem.
- `PlayerPresenterMarkItemTextureLoaded(container: object, category: int, index: int) -> void` — Marks item texture loaded for player presenter in the inventory presenter subsystem.

See: [module documentation](modules/inv_overhaul_inventory_presenter.md)

## Inventory View

Source: `scripts/player_inventory/inv_overhaul_inventory_view.lua`

Responsibility: Emits player inventory UI messages for slot contents, metadata, highlights, equipment, money, paging, and readiness.

Functions:

- `PlayerViewInitializeState() -> void` — Initializes state for player view in the inventory view subsystem.
- `DebugLoggingEnabled() -> bool` — Returns whether global verbose/debug logging is enabled.
- `ClaimChildWindowsReady() -> bool` — Claims child windows ready in the inventory view subsystem.
- `ChildWindowsReady() -> bool` — Returns whether child windows in the inventory view subsystem.
- `AdvanceMetadataDelay(delta: float) -> bool` — Advances metadata delay in the inventory view subsystem.
- `GetMetadataStage() -> int` — Returns metadata stage in the inventory view subsystem.
- `AdvanceMetadataStage() -> void` — Advances metadata stage in the inventory view subsystem.
- `CompleteMetadata() -> void` — Completes metadata in the inventory view subsystem.
- `IsMetadataPending() -> bool` — Returns whether metadata pending in the inventory view subsystem.
- `MarkRendererReady() -> void` — Marks renderer ready in the inventory view subsystem.
- `BeginWarmStartAttempt() -> bool` — Begins warm start attempt in the inventory view subsystem.
- `MarkWarmGridLoaded() -> void` — Marks warm grid loaded in the inventory view subsystem.
- `IsWarmGridLoaded() -> bool` — Returns whether warm grid loaded in the inventory view subsystem.
- `BeginInitialLoad(visibleSlots: int) -> void` — Begins initial load in the inventory view subsystem.
- `IsInitialLoadActive() -> bool` — Returns whether initial load active in the inventory view subsystem.
- `TakeNextEquipment() -> int` — Takes next equipment in the inventory view subsystem.
- `TakeNextSlot(visibleSlots: int) -> int` — Takes next slot in the inventory view subsystem.
- `InitialLoadComplete(visibleSlots: int) -> bool` — Loads complete for initial in the inventory view subsystem.
- `FinishInitialLoad() -> void` — Completes initial load in the inventory view subsystem.
- `AdvanceSpriteCooldown(delta: float) -> bool` — Advances sprite cooldown in the inventory view subsystem.
- `ResetSpriteCooldown() -> void` — Resets sprite cooldown in the inventory view subsystem.
- `ResetCacheCoverage() -> void` — Resets cache coverage in the inventory view subsystem.
- `GetCacheEpoch() -> int` — Returns cache epoch in the inventory view subsystem.
- `RecordStackCacheResult(hit: bool) -> void` — Records stack cache result in the inventory view subsystem.
- `RecordEquipmentCacheResult(hit: bool) -> void` — Records equipment cache result in the inventory view subsystem.
- `GetCacheHits() -> int` — Returns cache hits in the inventory view subsystem.
- `GetCacheMisses() -> int` — Returns cache misses in the inventory view subsystem.
- `PlayerViewReportFirstInitialItem() -> void` — Reports first initial item for player view in the inventory view subsystem.
- `PlayerViewReportInitialLoadComplete() -> void` — Reports initial load complete for player view in the inventory view subsystem.
- `PlayerViewSendGridRendererState(slot: int, operation: int, value: int, data: object) -> void` — Sends grid renderer state for player view in the inventory view subsystem.
- `PlayerViewSetGridRendererHighlight(slot: int, enabled: bool) -> void` — Sets grid renderer highlight for player view in the inventory view subsystem.
- `GetTargetWindowName(target: int, visibleSlots: int) -> string` — Returns target window name in the inventory view subsystem.
- `GetTargetDebugName(target: int, visibleSlots: int) -> string` — Returns target debug name in the inventory view subsystem.

See: [module documentation](modules/inv_overhaul_inventory_view.md)

## Character Doll

Source: `scripts/player_inventory/widgets/inv_overhaul_character_doll.lua`

Responsibility: Renders the branch-specific character silhouette and publishes doll/equipment hover and drag messages.

Functions:

- `init() -> void` — Initializes the character doll runtime and establishes its starting state and engine/UI integration.
- `OnDraw() -> void` — Handles the engine/UI `OnDraw` callback for the character doll runtime.
- `OnMouseMove(x: int, y: int) -> void` — Handles the engine/UI `OnMouseMove` callback for the character doll runtime.
- `OnMouseLeave() -> void` — Handles the engine/UI `OnMouseLeave` callback for the character doll runtime.
- `OnLButtonDown(x: int, y: int) -> void` — Handles the engine/UI `OnLButtonDown` callback for the character doll runtime.
- `OnRButtonDown(x: int, y: int) -> void` — Handles the engine/UI `OnRButtonDown` callback for the character doll runtime.
- `OnDragBegin(x: int, y: int) -> void` — Handles the engine/UI `OnDragBegin` callback for the character doll runtime.
- `OnLButtonUp(x: int, y: int) -> void` — Handles the engine/UI `OnLButtonUp` callback for the character doll runtime.
- `OnDragEnd(x: int, y: int, accepted: bool) -> void` — Handles the engine/UI `OnDragEnd` callback for the character doll runtime.
- `OnUIMessage(message: int, sender: string, data: object) -> void` — Handles the engine/UI `OnUIMessage` callback for the character doll runtime.

See: [module documentation](modules/inv_overhaul_character_doll.md)

## Drop Slot

Source: `scripts/player_inventory/widgets/inv_overhaul_drop_slot.lua`

Responsibility: Renders the drop target and publishes its pointer/drag protocol messages.

Functions:

- `init() -> void` — Initializes the drop slot runtime and establishes its starting state and engine/UI integration.
- `OnDraw() -> void` — Handles the engine/UI `OnDraw` callback for the drop slot runtime.
- `OnMouseEnter() -> void` — Handles the engine/UI `OnMouseEnter` callback for the drop slot runtime.
- `OnMouseMove(x: int, y: int) -> void` — Handles the engine/UI `OnMouseMove` callback for the drop slot runtime.
- `OnMouseLeave() -> void` — Handles the engine/UI `OnMouseLeave` callback for the drop slot runtime.
- `OnLButtonUp(x: int, y: int) -> void` — Handles the engine/UI `OnLButtonUp` callback for the drop slot runtime.
- `OnUIMessage(message: int, sender: string, data: object) -> void` — Handles the engine/UI `OnUIMessage` callback for the drop slot runtime.

See: [module documentation](modules/inv_overhaul_drop_slot.md)

## Equip Slot

Source: `scripts/player_inventory/widgets/inv_overhaul_equip_slot.lua`

Responsibility: Renders one equipment target and publishes pointer, drag, and tooltip protocol messages.

Functions:

- `init() -> void` — Initializes the equip slot runtime and establishes its starting state and engine/UI integration.
- `OnDraw() -> void` — Handles the engine/UI `OnDraw` callback for the equip slot runtime.
- `OnMouseEnter() -> void` — Handles the engine/UI `OnMouseEnter` callback for the equip slot runtime.
- `OnMouseMove(x: int, y: int) -> void` — Handles the engine/UI `OnMouseMove` callback for the equip slot runtime.
- `OnMouseLeave() -> void` — Handles the engine/UI `OnMouseLeave` callback for the equip slot runtime.
- `OnLButtonUp(x: int, y: int) -> void` — Handles the engine/UI `OnLButtonUp` callback for the equip slot runtime.
- `OnLButtonDown(x: int, y: int) -> void` — Handles the engine/UI `OnLButtonDown` callback for the equip slot runtime.
- `OnRButtonDown(x: int, y: int) -> void` — Handles the engine/UI `OnRButtonDown` callback for the equip slot runtime.
- `OnDragBegin(x: int, y: int) -> void` — Handles the engine/UI `OnDragBegin` callback for the equip slot runtime.
- `OnDragEnd(x: int, y: int, accepted: bool) -> void` — Handles the engine/UI `OnDragEnd` callback for the equip slot runtime.
- `OnUIMessage(message: int, sender: string, data: object) -> void` — Handles the engine/UI `OnUIMessage` callback for the equip slot runtime.

See: [module documentation](modules/inv_overhaul_equip_slot.md)

## Inventory Cursor

Source: `scripts/player_inventory/widgets/inv_overhaul_inventory_cursor.lua`

Responsibility: Renders custom inventory tooltips from shared item identity and per-instance property messages.

Functions:

- `init() -> void` — Initializes the inventory cursor runtime and establishes its starting state and engine/UI integration.
- `OnUpdate(delta: float) -> void` — Handles the engine/UI `OnUpdate` callback for the inventory cursor runtime.
- `OnDraw() -> void` — Handles the engine/UI `OnDraw` callback for the inventory cursor runtime.

See: [module documentation](modules/inv_overhaul_inventory_cursor.md)

## Inventory Quickslot Bindings

Source: `scripts/quickslots/inv_overhaul_inventory_quickslot_bindings.lua`

Responsibility: Owns saved quickslot item/category/occurrence bindings and the player-screen binding cache.

Functions:

- `QuickslotBindingsInitializeState() -> void` — Initializes state for quickslot bindings in the inventory quickslot bindings subsystem.
- `GetItemVariable(slot: int) -> string` — Returns item variable in the inventory quickslot bindings subsystem.
- `GetCategoryVariable(slot: int) -> string` — Returns category variable in the inventory quickslot bindings subsystem.
- `GetDepletedVariable(slot: int) -> string` — Returns depleted variable in the inventory quickslot bindings subsystem.
- `GetOccurrenceVariable(slot: int) -> string` — Returns occurrence variable in the inventory quickslot bindings subsystem.
- `InitializeBindings() -> void` — Initializes bindings in the inventory quickslot bindings subsystem.
- `RefreshCache() -> void` — Refreshes cache in the inventory quickslot bindings subsystem.
- `GetItemBinding(category: int, itemID: int) -> int` — Returns item binding in the inventory quickslot bindings subsystem.
- `GetDisplayedBinding(category: int, index: int, itemID: int) -> int` — Returns displayed binding in the inventory quickslot bindings subsystem.
- `IsEligible(category: int, itemID: int) -> bool` — Returns whether eligible in the inventory quickslot bindings subsystem.
- `Assign(slot: int, category: int, index: int, emitTrace: bool) -> bool` — Assigns inventory quickslot bindings in the inventory quickslot bindings subsystem.
- `GetSlotByKey(key: int) -> int` — Returns slot by key in the inventory quickslot bindings subsystem.

See: [module documentation](modules/inv_overhaul_inventory_quickslot_bindings.md)

## Quickslot Activation

Source: `scripts/quickslots/inv_overhaul_quickslot_activation.lua`

Responsibility: Provides shared persistent quickslot activation state, binding lookup, feedback, and equipment-removal hints.

Functions:

- `ActivationGetPlayer() -> object` — Returns player for activation in the quickslot activation subsystem.
- `ActivationItemVariable(slot: int) -> string` — Returns the shared engine-variable name used for activation item variable in the quickslot activation subsystem.
- `ActivationCategoryVariable(slot: int) -> string` — Returns the shared engine-variable name used for activation category variable in the quickslot activation subsystem.
- `ActivationOccurrenceVariable(slot: int) -> string` — Returns the shared engine-variable name used for activation occurrence variable in the quickslot activation subsystem.
- `ActivationDepletedVariable(slot: int) -> string` — Returns whether variable for activation in the quickslot activation subsystem.
- `ClearBinding(slot: int) -> void` — Clears binding in the quickslot activation subsystem.
- `ShowMessage(textID: int) -> void` — Shows message in the quickslot activation subsystem.
- `ShowFeedback(itemID: int) -> void` — Shows feedback in the quickslot activation subsystem.
- `MarkInventoryChanged() -> void` — Marks inventory changed in the quickslot activation subsystem.
- `ActivationIsEquippedItem(category: int, index: int) -> bool` — Returns whether equipped item for activation in the quickslot activation subsystem.
- `ActivationGetBackpackItemCount() -> int` — Returns backpack item count for activation in the quickslot activation subsystem.
- `ActivationGetBackpackOrdinal(targetCategory: int, targetIndex: int) -> int` — Returns backpack ordinal for activation in the quickslot activation subsystem.
- `PublishRemovalHint(category: int, index: int) -> void` — Publishes removal hint in the quickslot activation subsystem.
- `PublishEquipmentRemovalHint(category: int, index: int) -> void` — Publishes equipment removal hint in the quickslot activation subsystem.
- `CancelLastEquipmentRemovalHint() -> void` — Cancels last equipment removal hint in the quickslot activation subsystem.
- `IsEquippable(category: int, itemID: int) -> bool` — Returns whether equippable in the quickslot activation subsystem.
- `FindBoundItemIndex(category: int, itemID: int, wantedOccurrence: int) -> int` — Finds bound item index in the quickslot activation subsystem.
- `InitializePersistentState() -> void` — Initializes persistent state in the quickslot activation subsystem.

See: [module documentation](modules/inv_overhaul_quickslot_activation.md)

## Quickslot Consumables

Source: `scripts/quickslots/inv_overhaul_quickslot_consumables.lua`

Responsibility: Maps supported consumable item IDs to their use-effect script names.

Functions:

- `GetUseEffect(itemID: int) -> string` — Returns use effect in the quickslot consumables subsystem.

See: [module documentation](modules/inv_overhaul_quickslot_consumables.md)

## Quickslot Equipment

Source: `scripts/quickslots/inv_overhaul_quickslot_equipment.lua`

Responsibility: Applies the quickslot equipment toggle policy while preserving inventory layout hints.

Functions:

- `EquipmentPolicyToggle(category: int, index: int, itemID: int, occurrence: int, selected: bool) -> void` — Toggles equipment policy in the quickslot equipment subsystem.

See: [module documentation](modules/inv_overhaul_quickslot_equipment.md)

## Quickslot Hands

Source: `scripts/quickslots/inv_overhaul_quickslot_hands.lua`

Responsibility: Requests hand-combat activation for the quickslot runtime.

Functions:

- `AdjustBindingsAfterDrop(itemID: int, occurrence: int) -> void` — Adjusts bindings after drop in the quickslot hands subsystem.

See: [module documentation](modules/inv_overhaul_quickslot_hands.md)

## Quickslot Weapon

Source: `scripts/quickslots/inv_overhaul_quickslot_weapon.lua`

Responsibility: Applies weapon selection for the quickslot runtime and records the active weapon identity.

Functions:

- `init() -> void` — Initializes the quickslot weapon runtime and establishes its starting state and engine/UI integration.

See: [module documentation](modules/inv_overhaul_quickslot_weapon.md)

## Quickslots

Source: `scripts/quickslots/inv_overhaul_quickslots.lua`

Responsibility: Runs the persistent player quickslot effect, polls native requests, activates items/equipment, and verifies delayed mutations.

Functions:

- `init() -> void` — Initializes the quickslots runtime and establishes its starting state and engine/UI integration.

See: [module documentation](modules/inv_overhaul_quickslots.md)

## Quickslot Request Transports

Sources: `scripts/quickslots/requests/inv_overhaul_quickslot_request_1.lua` through `inv_overhaul_quickslot_request_10.lua`

Responsibility: Ten native key-request entry points; each exposes `init() -> void` and publishes its fixed slot number.

See: [module documentation](modules/inv_overhaul_quickslot_requests.md)
