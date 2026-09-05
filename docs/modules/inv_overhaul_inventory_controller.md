# Inventory Controller

## Source

`scripts/player_inventory/inv_overhaul_inventory_controller.lua`

DSL unit: `module inv_overhaul_inventory_controller`

## Responsibility

Orchestrates the player inventory screen: initialization, projection, incremental rendering, equipment, drag/drop, paging, quickslots, tooltips, persistence, and callback routing.

## Dependencies

- `inv_overhaul_inventory_sounds` — Plays drag, placement, equipment, quickslot, and paging feedback.

- `inv_overhaul_inventory_layout` — Defines the pure default mapping between backpack cells, linear slots, and pages.
- `inv_overhaul_inventory_layout_runtime` — Owns the mutable saved cell-to-item order, normalization, exact insertion/removal, swapping, and incremental persistence.
- `inv_overhaul_inventory_geometry` — Maps supported window sizes and character branches to player-grid, equipment, money, paging, and doll hit-test geometry.
- `inv_overhaul_inventory_protocol` — Defines and encodes the numeric UI message protocol shared by inventory forms and controllers.
- `inv_overhaul_inventory_items` — Builds the canonical projection of unequipped player items into backpack ordinals and cached category/index references.
- `inv_overhaul_inventory_quickslot_bindings` — Owns saved quickslot item/category/occurrence bindings and the player-screen binding cache.
- `inv_overhaul_inventory_equipment` — Implements equipment compatibility, equip/unequip/replacement, and layout restoration around equipment mutations.
- `inv_overhaul_inventory_snapshot` — Captures item-identity snapshots and reconciles saved layout cells after game inventory order changes or equipment mutations.
- `inv_overhaul_inventory_drag` — Owns player-screen drag state, drag cursor publication, highlighting, and source/target bookkeeping.
- `inv_overhaul_inventory_view` — Emits player inventory UI messages for slot contents, metadata, highlights, equipment, money, paging, and readiness.
- `inv_overhaul_inventory_paging` — Owns player inventory page bounds, current page, and drag-hover page timing.
- `inv_overhaul_inventory_tooltip` — Owns shared tooltip text, money pseudo-item metadata, suspension, and show/hide messaging.
- `inv_overhaul_inventory_drop` — Drops a player inventory entry into the world through the engine container API.
- `inv_overhaul_inventory_presenter` — Coordinates player-screen slot/equipment refreshes and incremental view publication.
- `inv_overhaul_inventory_input_controller` — Maps player-inventory keyboard and character input to close, paging, quickslot, and modified-click actions.
- Pathologic native API — engine state, object access, persistence variables, UI messaging, timing, or rendering as listed per function.

## Used by

- `scripts/player_inventory/inv_overhaul_inventory.lua`

## State

- `windowWidth: int` — current or cached layout value for window width.
- `windowHeight: int` — current or cached layout value for window height.
- `visibleSlots: int` — current or cached layout value for visible slots.
- `lastLayoutWidth: int` — current or cached layout value for last layout width.
- `lastLayoutHeight: int` — current or cached layout value for last layout height.
- `lastLayoutSlots: int` — current or cached layout value for last layout slots.
- `deferredInventoryRefresh: float` — mutable runtime state for deferred inventory refresh.
- `inventoryFullMessageCooldown: float` — timing state for inventory full message cooldown.
- `shiftHeld: bool` — lifecycle/behavior flag for shift held.
- `controlHeld: bool` — lifecycle/behavior flag for control held.
- `inventoryPollCooldown: float` — timing state for inventory poll cooldown.
- `observedContentGeneration: int` — mutable runtime state for observed content generation.
- `layoutLoadStartCell: int` — mutable runtime state for layout load start cell.
- `closingWindow: bool` — lifecycle/behavior flag for closing window.

## Public API

All functions below are compiler-visible when the module is imported; the DSL has no private declaration.

### `PlayerControllerInitialize() -> void`

Source: `scripts/player_inventory/inv_overhaul_inventory_controller.lua`

Purpose: Initializes player controller in the inventory controller subsystem.

Parameters:

None.

Returns:

None.

Side effects:

- Mutates module/task state: `lastLayoutWidth`, `lastLayoutHeight`, `lastLayoutSlots`, `deferredInventoryRefresh`, `inventoryFullMessageCooldown`, `shiftHeld`, `controlHeld`, `inventoryPollCooldown`, `… and 3 more`.
- Writes shared engine variable(s): `"inv_overhaul_inventory_drag_item"`, `"inv_overhaul_inventory_page_hover"`.
- Invokes engine/native operations: `native.Trace`, `native.SetVariable`, `native.SetCursor`, `native.ShowCursor`, `native.CaptureKeyboard`, `native.SetOwnerDraw`, `native.SetNeedUpdate`, `native.ProcessEvents`.

Called by:

- `scripts/player_inventory/inv_overhaul_inventory.lua :: init`

Calls:

- `inv_overhaul_inventory_view.PlayerViewInitializeState`
- `inv_overhaul_inventory_view.DebugLoggingEnabled`
- `native.Trace`
- `inv_overhaul_inventory_paging.PlayerPagingInitialize`
- `inv_overhaul_inventory_drag.PlayerDragInitializeState`
- `inv_overhaul_inventory_tooltip.InterfaceTooltipInitializeState`
- `native.GetVariable`
- `inv_overhaul_inventory_quickslot_bindings.QuickslotBindingsInitializeState`
- `InitializeQuickslotBindings`
- `RefreshQuickslotCache`
- `inv_overhaul_inventory_tooltip.InitializeMoneyItem`
- `inv_overhaul_inventory_snapshot.SnapshotInitializeState`
- `… and 11 more`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `ReadWindowWidth() -> int`

Source: `scripts/player_inventory/inv_overhaul_inventory_controller.lua`

Purpose: Returns window width in the inventory controller subsystem.

Parameters:

None.

Returns:

- `number` (integer) — result of: returns window width in the inventory controller subsystem.

Side effects:

- None directly observable beyond calls listed below.

Called by:

- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: PlayerControllerConfigureSlotRenderSize`
- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: PlayerControllerUpdateLayout`
- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: PlayerControllerIsInsideSpecialTarget`
- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: PlayerControllerIsInsideMoney`
- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: FindBackpackSlotAt`
- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: PlayerControllerIsInsideSlotDropArea`
- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: PlayerControllerGetSlotTargetFromPointerMessage`
- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: PlayerControllerGetPageControlX`
- `… and 3 more`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `ReadVisibleSlots() -> int`

Source: `scripts/player_inventory/inv_overhaul_inventory_controller.lua`

Purpose: Returns visible slots in the inventory controller subsystem.

Parameters:

None.

Returns:

- `number` (integer) — result of: returns visible slots in the inventory controller subsystem.

Side effects:

- None directly observable beyond calls listed below.

Called by:

- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: OrderFreeCellsByDisplayForCount`
- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: PlayerControllerGetVisibleCell`
- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: PlayerControllerGetCellForLinearSlot`
- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: PlayerControllerGetTargetWndName`
- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: ReconcileBackpackSnapshot`
- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: RestoreOrderAfterEquipmentReplacement`
- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: RestoreOrderAfterEquipmentSelection`
- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: PlayerControllerGetMaxPage`
- `… and 11 more`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `ReadPage() -> int`

Source: `scripts/player_inventory/inv_overhaul_inventory_controller.lua`

Purpose: Returns page in the inventory controller subsystem.

Parameters:

None.

Returns:

- `number` (integer) — result of: returns page in the inventory controller subsystem.

Side effects:

- Delegates to compiler-visible module APIs and inherits their documented side effects.

Called by:

- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: PlayerControllerUpdatePageControls`
- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: PlayerControllerMoveSlotToOtherPage`
- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: UpdateDragPageHover`
- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: SyncDragPageHoverFromCursor`

Calls:

- `inv_overhaul_inventory_paging.GetPage`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `ReadDragSourceSlot() -> int`

Source: `scripts/player_inventory/inv_overhaul_inventory_controller.lua`

Purpose: Returns drag source slot in the inventory controller subsystem.

Parameters:

None.

Returns:

- `number` (integer) — result of: returns drag source slot in the inventory controller subsystem.

Side effects:

- Delegates to compiler-visible module APIs and inherits their documented side effects.

Called by:

- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: StartDragAction`

Calls:

- `inv_overhaul_inventory_drag.GetSourceSlot`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `ReadDragSourceCell() -> int`

Source: `scripts/player_inventory/inv_overhaul_inventory_controller.lua`

Purpose: Returns drag source cell in the inventory controller subsystem.

Parameters:

None.

Returns:

- `number` (integer) — result of: returns drag source cell in the inventory controller subsystem.

Side effects:

- Delegates to compiler-visible module APIs and inherits their documented side effects.

Called by:

- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: FinishLeftAction`

Calls:

- `inv_overhaul_inventory_drag.GetSourceCell`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `ReadHighlightedSlot() -> int`

Source: `scripts/player_inventory/inv_overhaul_inventory_controller.lua`

Purpose: Returns highlighted slot in the inventory controller subsystem.

Parameters:

None.

Returns:

- `number` (integer) — result of: returns highlighted slot in the inventory controller subsystem.

Side effects:

- Delegates to compiler-visible module APIs and inherits their documented side effects.

Called by:

- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: PlayerControllerHandleDragLifecycleMessage`

Calls:

- `inv_overhaul_inventory_drag.PlayerDragGetHighlightedTarget`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `ReadDragItemCategory() -> int`

Source: `scripts/player_inventory/inv_overhaul_inventory_controller.lua`

Purpose: Returns drag item category in the inventory controller subsystem.

Parameters:

None.

Returns:

- `number` (integer) — result of: returns drag item category in the inventory controller subsystem.

Side effects:

- Delegates to compiler-visible module APIs and inherits their documented side effects.

Called by:

- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: IsSpecialTargetCompatible`
- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: FinishLeftAction`

Calls:

- `inv_overhaul_inventory_drag.GetItemCategory`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `ReadDragItemIndex() -> int`

Source: `scripts/player_inventory/inv_overhaul_inventory_controller.lua`

Purpose: Returns drag item index in the inventory controller subsystem.

Parameters:

None.

Returns:

- `number` (integer) — result of: returns drag item index in the inventory controller subsystem.

Side effects:

- Delegates to compiler-visible module APIs and inherits their documented side effects.

Called by:

- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: FinishLeftAction`

Calls:

- `inv_overhaul_inventory_drag.GetItemIndex`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `ReadDragItemGroup() -> int`

Source: `scripts/player_inventory/inv_overhaul_inventory_controller.lua`

Purpose: Returns drag item group in the inventory controller subsystem.

Parameters:

None.

Returns:

- `number` (integer) — result of: returns drag item group in the inventory controller subsystem.

Side effects:

- Delegates to compiler-visible module APIs and inherits their documented side effects.

Called by:

- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: IsSpecialTargetCompatible`

Calls:

- `inv_overhaul_inventory_drag.GetItemGroup`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `ReadDragItemIsWeapon() -> bool`

Source: `scripts/player_inventory/inv_overhaul_inventory_controller.lua`

Purpose: Returns drag item is weapon in the inventory controller subsystem.

Parameters:

None.

Returns:

- `boolean` — result of: returns drag item is weapon in the inventory controller subsystem.

Side effects:

- Delegates to compiler-visible module APIs and inherits their documented side effects.

Called by:

- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: IsSpecialTargetCompatible`

Calls:

- `inv_overhaul_inventory_drag.GetItemIsWeapon`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `ReadLastBackpackItemCount() -> int`

Source: `scripts/player_inventory/inv_overhaul_inventory_controller.lua`

Purpose: Returns last backpack item count in the inventory controller subsystem.

Parameters:

None.

Returns:

- `number` (integer) — result of: returns last backpack item count in the inventory controller subsystem.

Side effects:

- Delegates to compiler-visible module APIs and inherits their documented side effects.

Called by:

- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: InitializePersistentBackpackSnapshot`
- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: TryWarmStartGrid`
- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: RunMetadataAndLoadingStage`

Calls:

- `inv_overhaul_inventory_snapshot.GetLastBackpackItemCount`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `ReadLayoutLoadStartCell() -> int`

Source: `scripts/player_inventory/inv_overhaul_inventory_controller.lua`

Purpose: Returns layout load start cell in the inventory controller subsystem.

Parameters:

None.

Returns:

- `number` (integer) — result of: returns layout load start cell in the inventory controller subsystem.

Side effects:

- None directly observable beyond calls listed below.

Called by:

- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: ContinueIncrementalLayoutLoad`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `ReadPerfCacheEpoch() -> int`

Source: `scripts/player_inventory/inv_overhaul_inventory_controller.lua`

Purpose: Returns perf cache epoch in the inventory controller subsystem.

Parameters:

None.

Returns:

- `number` (integer) — result of: returns perf cache epoch in the inventory controller subsystem.

Side effects:

- Delegates to compiler-visible module APIs and inherits their documented side effects.

Called by:

- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: MeasureInitialTextureCacheCoverage`

Calls:

- `inv_overhaul_inventory_view.GetCacheEpoch`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `InitSlotOrder() -> void`

Source: `scripts/player_inventory/inv_overhaul_inventory_controller.lua`

Purpose: Initializes slot order in the inventory controller subsystem.

Parameters:

None.

Returns:

None.

Side effects:

- Delegates to compiler-visible module APIs and inherits their documented side effects.

Called by:

- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: PlayerControllerInitialize`

Calls:

- `inv_overhaul_inventory_layout_runtime.LayoutRuntimeInitialize`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `GetBranch() -> int`

Source: `scripts/player_inventory/inv_overhaul_inventory_controller.lua`

Purpose: Returns branch in the inventory controller subsystem.

Parameters:

None.

Returns:

- `number` (integer) — result of: returns branch in the inventory controller subsystem.

Side effects:

- None directly observable beyond calls listed below.

Called by:

- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: PlayerControllerIsInsideSpecialTarget`
- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: PlayerControllerIsInsideMoney`
- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: PlayerControllerGetPageControlY`
- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: PlayerControllerIsInsidePlayerPaging`

Calls:

- `native.GetVariable`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `PlayerControllerGetOrderValue(slot: int) -> int`

Source: `scripts/player_inventory/inv_overhaul_inventory_controller.lua`

Purpose: Returns order value for player controller in the inventory controller subsystem.

Parameters:

- `slot: int` — slot index or encoded slot target interpreted by this function.

Returns:

- `number` (integer) — result of: returns order value for player controller in the inventory controller subsystem.

Side effects:

- Delegates to compiler-visible module APIs and inherits their documented side effects.

Called by:

- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: PlayerControllerResolveVisibleSlot`
- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: PlayerControllerHandleModifiedDrop`
- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: PlayerControllerMoveSlotToOtherPage`
- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: HandleSlotMessage`
- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: FinishLeftAction`

Calls:

- `inv_overhaul_inventory_layout_runtime.LayoutRuntimeGetOrderValue`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `LoadLayoutVariables() -> void`

Source: `scripts/player_inventory/inv_overhaul_inventory_controller.lua`

Purpose: Loads layout variables in the inventory controller subsystem.

Parameters:

None.

Returns:

None.

Side effects:

- Delegates to compiler-visible module APIs and inherits their documented side effects.

Called by:

- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: TryWarmStartGrid`

Calls:

- `inv_overhaul_inventory_layout_runtime.Load`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `ContinueIncrementalLayoutLoad() -> bool`

Source: `scripts/player_inventory/inv_overhaul_inventory_controller.lua`

Purpose: Continues incremental layout load in the inventory controller subsystem.

Parameters:

None.

Returns:

- `boolean` — result of: continues incremental layout load in the inventory controller subsystem.

Side effects:

- Mutates module/task state: `layoutLoadStartCell`.

Called by:

- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: RunMetadataAndLoadingStage`

Calls:

- `inv_overhaul_inventory_layout_runtime.ContinueIncrementalLoad`
- `ReadLayoutLoadStartCell`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `SaveLayoutVariables() -> void`

Source: `scripts/player_inventory/inv_overhaul_inventory_controller.lua`

Purpose: Persists layout variables in the inventory controller subsystem.

Parameters:

None.

Returns:

None.

Side effects:

- Delegates to compiler-visible module APIs and inherits their documented side effects.

Called by:

- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: OnChar`
- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: OnKeyDown`

Calls:

- `inv_overhaul_inventory_layout_runtime.SaveAll`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `QueueLayoutSave() -> void`

Source: `scripts/player_inventory/inv_overhaul_inventory_controller.lua`

Purpose: Queues layout save in the inventory controller subsystem.

Parameters:

None.

Returns:

None.

Side effects:

- Delegates to compiler-visible module APIs and inherits their documented side effects.

Called by:

- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: OrderFreeCellsByDisplayForCount`
- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: ReconcileBackpackSnapshot`
- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: RestoreOrderAfterEquipmentReplacement`
- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: RestoreOrderAfterEquipmentSelection`
- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: SwapSlotOrderCells`
- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: RemoveOrderOrdinal`
- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: InsertOrderOrdinalAtCell`

Calls:

- `inv_overhaul_inventory_layout_runtime.QueueSave`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `ContinueLayoutSave() -> void`

Source: `scripts/player_inventory/inv_overhaul_inventory_controller.lua`

Purpose: Continues layout save in the inventory controller subsystem.

Parameters:

None.

Returns:

None.

Side effects:

- Delegates to compiler-visible module APIs and inherits their documented side effects.

Called by:

- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: RunPersistenceAndRefreshStage`

Calls:

- `inv_overhaul_inventory_layout_runtime.ContinueQueuedSave`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `OrderFreeCellsByDisplayForCount(itemCount: int) -> void`

Source: `scripts/player_inventory/inv_overhaul_inventory_controller.lua`

Purpose: Orders free cells by display for count in the inventory controller subsystem.

Parameters:

- `itemCount: int` — value interpreted according to the function purpose; no narrower contract is established by current code.

Returns:

None.

Side effects:

- Delegates to compiler-visible module APIs and inherits their documented side effects.

Called by:

- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: TryWarmStartGrid`
- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: RunMetadataAndLoadingStage`

Calls:

- `inv_overhaul_inventory_layout_runtime.LayoutRuntimeOrderFreeCellsByDisplay`
- `ReadVisibleSlots`
- `QueueLayoutSave`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `PlayerControllerGetPlayerContainer() -> object`

Source: `scripts/player_inventory/inv_overhaul_inventory_controller.lua`

Purpose: Returns player container for player controller in the inventory controller subsystem.

Parameters:

None.

Returns:

- `object` — result of: returns player container for player controller in the inventory controller subsystem.

Side effects:

- Delegates to compiler-visible module APIs and inherits their documented side effects.

Called by:

- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: BeginDragCursor`
- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: PlayerControllerUpdateMoney`
- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: PlayerControllerUpdateSlot`
- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: PlayerControllerMarkItemTextureLoaded`
- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: MeasureInitialTextureCacheCoverage`
- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: UpdateCachedEquipmentSlot`
- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: PlayerControllerHandleModifiedDrop`
- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: UpdatePanelTooltip`

Calls:

- `inv_overhaul_inventory_items.ItemsGetPlayerContainer`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `BeginDragCursor(slot: int) -> void`

Source: `scripts/player_inventory/inv_overhaul_inventory_controller.lua`

Purpose: Begins drag cursor in the inventory controller subsystem.

Parameters:

- `slot: int` — slot index or encoded slot target interpreted by this function.

Returns:

None.

Side effects:

- Writes shared engine variable(s): `"inv_overhaul_inventory_drag_item"`.
- Invokes engine/native operations: `native.SetVariable`.

Called by:

- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: StartDragAction`

Calls:

- `native.SetVariable`
- `inv_overhaul_inventory_drag.ClearItem`
- `ResolveDragSource`
- `inv_overhaul_inventory_items.DecodeReferenceCategory`
- `inv_overhaul_inventory_items.DecodeReferenceIndex`
- `PlayerControllerGetPlayerContainer`
- `container.GetItem`
- `item.GetItemID`
- `native.HasInvItemProperty`
- `native.GetInvItemProperty`
- `inv_overhaul_inventory_drag.BeginItem`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `EndDragCursor() -> void`

Source: `scripts/player_inventory/inv_overhaul_inventory_controller.lua`

Purpose: Ends drag cursor in the inventory controller subsystem.

Parameters:

None.

Returns:

None.

Side effects:

- Writes shared engine variable(s): `"inv_overhaul_inventory_drag_item"`, `"inv_overhaul_inventory_page_hover"`.
- Invokes engine/native operations: `native.SetVariable`.

Called by:

- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: CancelDragAction`
- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: FinishLeftAction`

Calls:

- `native.SetVariable`
- `inv_overhaul_inventory_drag.ClearItem`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `PlayerControllerConfigureSlotRenderSize() -> void`

Source: `scripts/player_inventory/inv_overhaul_inventory_controller.lua`

Purpose: Configures slot render size for player controller in the inventory controller subsystem.

Parameters:

None.

Returns:

None.

Side effects:

- Delegates to compiler-visible module APIs and inherits their documented side effects.

Called by:

- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: PlayerControllerUpdateLayout`

Calls:

- `inv_overhaul_inventory_presenter.PlayerPresenterConfigureSlotRenderSize`
- `ReadWindowWidth`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `PlayerControllerUpdateLayout() -> void`

Source: `scripts/player_inventory/inv_overhaul_inventory_controller.lua`

Purpose: Updates layout for player controller in the inventory controller subsystem.

Parameters:

None.

Returns:

None.

Side effects:

- Mutates module/task state: `windowWidth`, `windowHeight`, `visibleSlots`, `lastLayoutWidth`, `lastLayoutHeight`, `lastLayoutSlots`.
- Invokes engine/native operations: `native.Trace`, `native.SendMessage`.

Called by:

- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: PlayerControllerInitialize`
- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: PlayerControllerBeginInitialSlotLoad`
- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: UpdateSlots`
- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: RunFramePreparationStage`

Calls:

- `native.GetWindowSize`
- `native.GetScreenSize`
- `inv_overhaul_inventory_geometry.InterfaceGeometryGetVisibleSlots`
- `ReadWindowWidth`
- `native.Trace`
- `inv_overhaul_inventory_view.ChildWindowsReady`
- `native.SendMessage`
- `PlayerControllerConfigureSlotRenderSize`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `PlayerControllerSendGridRendererState(slot: int, operation: int, value: int, data: object) -> void`

Source: `scripts/player_inventory/inv_overhaul_inventory_controller.lua`

Purpose: Sends grid renderer state for player controller in the inventory controller subsystem.

Parameters:

- `slot: int` — slot index or encoded slot target interpreted by this function.
- `operation: int` — value interpreted according to the function purpose; no narrower contract is established by current code.
- `value: int` — value interpreted according to the function purpose; no narrower contract is established by current code.
- `data: object` — engine callback/UI payload object; shape depends on the message.

Returns:

None.

Side effects:

- Delegates to compiler-visible module APIs and inherits their documented side effects.

Called by:

- No in-repository caller was resolved; this may be an engine/XML callback or a conventionally public helper.

Calls:

- `inv_overhaul_inventory_presenter.PlayerPresenterSendGridRendererState`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `PlayerControllerSetGridRendererHighlight(slot: int, enabled: bool) -> void`

Source: `scripts/player_inventory/inv_overhaul_inventory_controller.lua`

Purpose: Sets grid renderer highlight for player controller in the inventory controller subsystem.

Parameters:

- `slot: int` — slot index or encoded slot target interpreted by this function.
- `enabled: bool` — behavior flag interpreted by this function.

Returns:

None.

Side effects:

- Delegates to compiler-visible module APIs and inherits their documented side effects.

Called by:

- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: SetHighlightedSlot`

Calls:

- `inv_overhaul_inventory_presenter.PlayerPresenterSetGridRendererHighlight`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `PlayerControllerGetVisibleCell(slot: int) -> int`

Source: `scripts/player_inventory/inv_overhaul_inventory_controller.lua`

Purpose: Returns visible cell for player controller in the inventory controller subsystem.

Parameters:

- `slot: int` — slot index or encoded slot target interpreted by this function.

Returns:

- `number` (integer) — result of: returns visible cell for player controller in the inventory controller subsystem.

Side effects:

- Delegates to compiler-visible module APIs and inherits their documented side effects.

Called by:

- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: PlayerControllerResolveVisibleSlot`
- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: PlayerControllerUpdateSlot`
- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: PlayerControllerContinueInitialSlotLoad`
- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: UpdateVisibleCell`
- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: PlayerControllerHandleModifiedDrop`
- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: PlayerControllerMoveSlotToOtherPage`
- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: HandleSlotMessage`
- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: StartDragAction`
- `… and 3 more`

Calls:

- `inv_overhaul_inventory_paging.PlayerPagingGetVisibleCell`
- `ReadVisibleSlots`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `PlayerControllerGetCellForLinearSlot(linear: int) -> int`

Source: `scripts/player_inventory/inv_overhaul_inventory_controller.lua`

Purpose: Returns cell for linear slot for player controller in the inventory controller subsystem.

Parameters:

- `linear: int` — value interpreted according to the function purpose; no narrower contract is established by current code.

Returns:

- `number` (integer) — result of: returns cell for linear slot for player controller in the inventory controller subsystem.

Side effects:

- Delegates to compiler-visible module APIs and inherits their documented side effects.

Called by:

- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: PlayerControllerMoveSlotToOtherPage`

Calls:

- `inv_overhaul_inventory_paging.PlayerPagingGetCellForLinearSlot`
- `ReadVisibleSlots`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `PlayerControllerGetTargetWndName(target: int) -> string`

Source: `scripts/player_inventory/inv_overhaul_inventory_controller.lua`

Purpose: Returns target wnd name for player controller in the inventory controller subsystem.

Parameters:

- `target: int` — value interpreted according to the function purpose; no narrower contract is established by current code.

Returns:

- `string` — result of: returns target wnd name for player controller in the inventory controller subsystem.

Side effects:

- Delegates to compiler-visible module APIs and inherits their documented side effects.

Called by:

- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: PlayerControllerBeginInitialSlotLoad`
- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: UpdateCachedEquipmentSlot`
- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: SetHighlightedSlot`
- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: CancelDragAction`
- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: FinishLeftAction`

Calls:

- `inv_overhaul_inventory_view.GetTargetWindowName`
- `ReadVisibleSlots`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `PlayerControllerIsInsideSpecialTarget(target: int, x: int, y: int) -> bool`

Source: `scripts/player_inventory/inv_overhaul_inventory_controller.lua`

Purpose: Returns whether inside special target for player controller in the inventory controller subsystem.

Parameters:

- `target: int` — value interpreted according to the function purpose; no narrower contract is established by current code.
- `x: int` — pointer/layout coordinate interpreted by this function.
- `y: int` — pointer/layout coordinate interpreted by this function.

Returns:

- `boolean` — result of: returns whether inside special target for player controller in the inventory controller subsystem.

Side effects:

- Delegates to compiler-visible module APIs and inherits their documented side effects.

Called by:

- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: FindSpecialTargetAt`
- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: FindEquipmentTargetAt`
- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: UpdatePanelTooltip`

Calls:

- `inv_overhaul_inventory_geometry.InterfaceGeometryIsInsideSpecialTarget`
- `ReadWindowWidth`
- `GetBranch`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `PlayerControllerIsInsideMoney(x: int, y: int) -> bool`

Source: `scripts/player_inventory/inv_overhaul_inventory_controller.lua`

Purpose: Returns whether inside money for player controller in the inventory controller subsystem.

Parameters:

- `x: int` — pointer/layout coordinate interpreted by this function.
- `y: int` — pointer/layout coordinate interpreted by this function.

Returns:

- `boolean` — result of: returns whether inside money for player controller in the inventory controller subsystem.

Side effects:

- Delegates to compiler-visible module APIs and inherits their documented side effects.

Called by:

- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: UpdatePanelTooltip`

Calls:

- `inv_overhaul_inventory_geometry.InterfaceGeometryIsInsideMoney`
- `ReadWindowWidth`
- `GetBranch`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `FindSpecialTargetAt(x: int, y: int) -> int`

Source: `scripts/player_inventory/inv_overhaul_inventory_controller.lua`

Purpose: Finds special target at in the inventory controller subsystem.

Parameters:

- `x: int` — pointer/layout coordinate interpreted by this function.
- `y: int` — pointer/layout coordinate interpreted by this function.

Returns:

- `number` (integer) — result of: finds special target at in the inventory controller subsystem.

Side effects:

- Delegates to compiler-visible module APIs and inherits their documented side effects.

Called by:

- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: FindSlotAt`

Calls:

- `inv_overhaul_inventory_drag.GetItemCategory`
- `inv_overhaul_inventory_drag.GetItemIsWeapon`
- `PlayerControllerIsInsideSpecialTarget`
- `inv_overhaul_inventory_drag.GetItemGroup`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `FindEquipmentTargetAt(x: int, y: int) -> int`

Source: `scripts/player_inventory/inv_overhaul_inventory_controller.lua`

Purpose: Finds equipment target at in the inventory controller subsystem.

Parameters:

- `x: int` — pointer/layout coordinate interpreted by this function.
- `y: int` — pointer/layout coordinate interpreted by this function.

Returns:

- `number` (integer) — result of: finds equipment target at in the inventory controller subsystem.

Side effects:

- None directly observable beyond calls listed below.

Called by:

- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: PlayerControllerStartPanelPointerDrag`
- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: UpdatePanelTooltip`
- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: PlayerControllerHandlePanelPointer`
- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: OnLButtonDown`
- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: OnRButtonDown`

Calls:

- `PlayerControllerIsInsideSpecialTarget`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `PlayerControllerGetBackpackItemCount() -> int`

Source: `scripts/player_inventory/inv_overhaul_inventory_controller.lua`

Purpose: Returns backpack item count for player controller in the inventory controller subsystem.

Parameters:

None.

Returns:

- `number` (integer) — result of: returns backpack item count for player controller in the inventory controller subsystem.

Side effects:

- Delegates to compiler-visible module APIs and inherits their documented side effects.

Called by:

- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: PlayerControllerHandleModifiedDrop`
- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: PlayerControllerMoveSlotToOtherPage`
- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: HandleSlotMessage`
- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: UnequipTarget`
- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: RemoveOrderOrdinal`
- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: InsertOrderOrdinalAtCell`
- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: FinishLeftAction`

Calls:

- `inv_overhaul_inventory_items.GetBackpackCount`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `LoadPersistentBackpackSnapshot() -> bool`

Source: `scripts/player_inventory/inv_overhaul_inventory_controller.lua`

Purpose: Loads persistent backpack snapshot in the inventory controller subsystem.

Parameters:

None.

Returns:

- `boolean` — result of: loads persistent backpack snapshot in the inventory controller subsystem.

Side effects:

- Delegates to compiler-visible module APIs and inherits their documented side effects.

Called by:

- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: InitializePersistentBackpackSnapshot`

Calls:

- `inv_overhaul_inventory_snapshot.LoadPersistent`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `CanReusePersistentBackpackSnapshot() -> bool`

Source: `scripts/player_inventory/inv_overhaul_inventory_controller.lua`

Purpose: Returns whether reuse persistent backpack snapshot in the inventory controller subsystem.

Parameters:

None.

Returns:

- `boolean` — result of: returns whether reuse persistent backpack snapshot in the inventory controller subsystem.

Side effects:

- Delegates to compiler-visible module APIs and inherits their documented side effects.

Called by:

- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: InitializePersistentBackpackSnapshot`

Calls:

- `inv_overhaul_inventory_snapshot.CanReusePersistent`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `SavePersistentBackpackSnapshot() -> void`

Source: `scripts/player_inventory/inv_overhaul_inventory_controller.lua`

Purpose: Persists persistent backpack snapshot in the inventory controller subsystem.

Parameters:

None.

Returns:

None.

Side effects:

- Delegates to compiler-visible module APIs and inherits their documented side effects.

Called by:

- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: ReconcileInventoryContentGeneration`
- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: InitializePersistentBackpackSnapshot`

Calls:

- `inv_overhaul_inventory_snapshot.SavePersistent`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `CopyCurrentBackpackSnapshot(newCount: int) -> void`

Source: `scripts/player_inventory/inv_overhaul_inventory_controller.lua`

Purpose: Copies current backpack snapshot in the inventory controller subsystem.

Parameters:

- `newCount: int` — value interpreted according to the function purpose; no narrower contract is established by current code.

Returns:

None.

Side effects:

- Delegates to compiler-visible module APIs and inherits their documented side effects.

Called by:

- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: InitializePersistentBackpackSnapshot`

Calls:

- `inv_overhaul_inventory_snapshot.CopyCurrent`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `BackpackSnapshotDiffers(newCount: int) -> bool`

Source: `scripts/player_inventory/inv_overhaul_inventory_controller.lua`

Purpose: Returns whether backpack snapshot in the inventory controller subsystem.

Parameters:

- `newCount: int` — value interpreted according to the function purpose; no narrower contract is established by current code.

Returns:

- `boolean` — result of: returns whether backpack snapshot in the inventory controller subsystem.

Side effects:

- Delegates to compiler-visible module APIs and inherits their documented side effects.

Called by:

- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: ReconcileInventoryContentGeneration`
- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: InitializePersistentBackpackSnapshot`

Calls:

- `inv_overhaul_inventory_snapshot.Differs`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `PersistCurrentBackpackSnapshot() -> void`

Source: `scripts/player_inventory/inv_overhaul_inventory_controller.lua`

Purpose: Persists current backpack snapshot in the inventory controller subsystem.

Parameters:

None.

Returns:

None.

Side effects:

- Delegates to compiler-visible module APIs and inherits their documented side effects.

Called by:

- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: OnChar`
- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: OnKeyDown`

Calls:

- `inv_overhaul_inventory_snapshot.PersistCurrent`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `ReconcileInventoryContentGeneration(currentGeneration: int) -> bool`

Source: `scripts/player_inventory/inv_overhaul_inventory_controller.lua`

Purpose: Reconciles inventory content generation in the inventory controller subsystem.

Parameters:

- `currentGeneration: int` — value interpreted according to the function purpose; no narrower contract is established by current code.

Returns:

- `boolean` — result of: reconciles inventory content generation in the inventory controller subsystem.

Side effects:

- Mutates module/task state: `observedContentGeneration`.

Called by:

- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: StartDragAction`
- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: FinishLeftAction`
- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: RunPersistenceAndRefreshStage`

Calls:

- `inv_overhaul_inventory_drag.PlayerDragIsActive`
- `CancelDragAction`
- `inv_overhaul_inventory_snapshot.CaptureCurrentCount`
- `BackpackSnapshotDiffers`
- `ReconcileBackpackSnapshot`
- `UpdateSlots`
- `SavePersistentBackpackSnapshot`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `InitializePersistentBackpackSnapshot() -> void`

Source: `scripts/player_inventory/inv_overhaul_inventory_controller.lua`

Purpose: Initializes persistent backpack snapshot in the inventory controller subsystem.

Parameters:

None.

Returns:

None.

Side effects:

- Invokes engine/native operations: `native.Trace`.

Called by:

- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: TryWarmStartGrid`
- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: RunMetadataAndLoadingStage`

Calls:

- `CanReusePersistentBackpackSnapshot`
- `inv_overhaul_inventory_snapshot.BuildIndexCacheAndPrevious`
- `inv_overhaul_inventory_snapshot.ClampLastBackpackItemCount`
- `inv_overhaul_inventory_snapshot.CaptureCurrentCount`
- `LoadPersistentBackpackSnapshot`
- `BackpackSnapshotDiffers`
- `ReconcileBackpackSnapshot`
- `native.Trace`
- `ReadLastBackpackItemCount`
- `CopyCurrentBackpackSnapshot`
- `SavePersistentBackpackSnapshot`
- `BuildBackpackIndexCache`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `ReconcileBackpackSnapshot(newCount: int) -> void`

Source: `scripts/player_inventory/inv_overhaul_inventory_controller.lua`

Purpose: Reconciles backpack snapshot in the inventory controller subsystem.

Parameters:

- `newCount: int` — value interpreted according to the function purpose; no narrower contract is established by current code.

Returns:

None.

Side effects:

- Delegates to compiler-visible module APIs and inherits their documented side effects.

Called by:

- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: ReconcileInventoryContentGeneration`
- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: InitializePersistentBackpackSnapshot`

Calls:

- `inv_overhaul_inventory_snapshot.Reconcile`
- `ReadVisibleSlots`
- `QueueLayoutSave`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `RestoreOrderAfterEquipmentReplacement(replacedOrder: int, itemCount: int) -> bool`

Source: `scripts/player_inventory/inv_overhaul_inventory_controller.lua`

Purpose: Restores order after equipment replacement in the inventory controller subsystem.

Parameters:

- `replacedOrder: int` — value interpreted according to the function purpose; no narrower contract is established by current code.
- `itemCount: int` — value interpreted according to the function purpose; no narrower contract is established by current code.

Returns:

- `boolean` — result of: restores order after equipment replacement in the inventory controller subsystem.

Side effects:

- Delegates to compiler-visible module APIs and inherits their documented side effects.

Called by:

- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: HandleSlotMessage`
- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: FinishLeftAction`

Calls:

- `inv_overhaul_inventory_snapshot.RestoreAfterEquipmentReplacement`
- `ReadVisibleSlots`
- `QueueLayoutSave`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `RestoreOrderAfterEquipmentSelection(removedOrder: int, beforeCount: int) -> bool`

Source: `scripts/player_inventory/inv_overhaul_inventory_controller.lua`

Purpose: Restores order after equipment selection in the inventory controller subsystem.

Parameters:

- `removedOrder: int` — value interpreted according to the function purpose; no narrower contract is established by current code.
- `beforeCount: int` — value interpreted according to the function purpose; no narrower contract is established by current code.

Returns:

- `boolean` — result of: restores order after equipment selection in the inventory controller subsystem.

Side effects:

- Delegates to compiler-visible module APIs and inherits their documented side effects.

Called by:

- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: HandleSlotMessage`
- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: FinishLeftAction`

Calls:

- `inv_overhaul_inventory_snapshot.RestoreAfterEquipmentSelection`
- `ReadVisibleSlots`
- `QueueLayoutSave`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `PlayerControllerShowInventoryFull() -> void`

Source: `scripts/player_inventory/inv_overhaul_inventory_controller.lua`

Purpose: Shows inventory full for player controller in the inventory controller subsystem.

Parameters:

None.

Returns:

None.

Side effects:

- Mutates module/task state: `inventoryFullMessageCooldown`.
- Invokes engine/native operations: `native.CreateIntVector`, `native.SendWorldWndMessage`.
- May mutate engine/UI objects through: `text.add`.

Called by:

- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: PlayerControllerMoveSlotToOtherPage`
- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: UnequipTarget`
- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: FinishLeftAction`

Calls:

- `native.CreateIntVector`
- `text.add`
- `native.SendWorldWndMessage`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `PlayerControllerGetMaxPage() -> int`

Source: `scripts/player_inventory/inv_overhaul_inventory_controller.lua`

Purpose: Returns max page for player controller in the inventory controller subsystem.

Parameters:

None.

Returns:

- `number` (integer) — result of: returns max page for player controller in the inventory controller subsystem.

Side effects:

- Delegates to compiler-visible module APIs and inherits their documented side effects.

Called by:

- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: PlayerControllerUpdatePageControls`
- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: PlayerControllerMoveSlotToOtherPage`
- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: PlayerControllerGetDragPageHoverAction`
- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: UpdateDragPageHover`
- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: SyncDragPageHoverFromCursor`
- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: PlayerControllerIsInsidePlayerPaging`
- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: HandlePageControlAt`
- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: UpdatePageControlHover`
- `… and 1 more`

Calls:

- `inv_overhaul_inventory_paging.PlayerPagingGetMaxPage`
- `ReadVisibleSlots`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `ClampPage() -> void`

Source: `scripts/player_inventory/inv_overhaul_inventory_controller.lua`

Purpose: Clamps page in the inventory controller subsystem.

Parameters:

None.

Returns:

None.

Side effects:

- Delegates to compiler-visible module APIs and inherits their documented side effects.

Called by:

- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: TryWarmStartGrid`
- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: PlayerControllerBeginInitialSlotLoad`
- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: UpdateSlots`

Calls:

- `inv_overhaul_inventory_paging.Clamp`
- `ReadVisibleSlots`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `PlayerControllerUpdatePageControls() -> void`

Source: `scripts/player_inventory/inv_overhaul_inventory_controller.lua`

Purpose: Updates page controls for player controller in the inventory controller subsystem.

Parameters:

None.

Returns:

None.

Side effects:

- Delegates to compiler-visible module APIs and inherits their documented side effects.

Called by:

- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: PlayerControllerBeginInitialSlotLoad`
- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: UpdateSlots`
- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: RefreshEquipmentMutation`
- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: RunFramePreparationStage`

Calls:

- `PlayerControllerGetMaxPage`
- `ReadPage`
- `inv_overhaul_inventory_presenter.PlayerPresenterUpdatePageControls`
- `ReadVisibleSlots`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `PlayerControllerResolveVisibleSlot(slot: int) -> int`

Source: `scripts/player_inventory/inv_overhaul_inventory_controller.lua`

Purpose: Resolves visible slot for player controller in the inventory controller subsystem.

Parameters:

- `slot: int` — slot index or encoded slot target interpreted by this function.

Returns:

- `number` (integer) — result of: resolves visible slot for player controller in the inventory controller subsystem.

Side effects:

- Delegates to compiler-visible module APIs and inherits their documented side effects.

Called by:

- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: PlayerControllerUpdateSlot`
- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: PlayerControllerContinueInitialSlotLoad`
- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: ResolveDragSource`
- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: PlayerControllerHandleModifiedDrop`
- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: HandleSlotMessage`
- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: PlayerControllerStartPanelPointerDrag`
- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: UpdatePanelTooltip`

Calls:

- `PlayerControllerGetOrderValue`
- `PlayerControllerGetVisibleCell`
- `inv_overhaul_inventory_items.ResolveCachedOrdinal`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `BuildBackpackIndexCache() -> void`

Source: `scripts/player_inventory/inv_overhaul_inventory_controller.lua`

Purpose: Builds backpack index cache in the inventory controller subsystem.

Parameters:

None.

Returns:

None.

Side effects:

- Delegates to compiler-visible module APIs and inherits their documented side effects.

Called by:

- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: InitializePersistentBackpackSnapshot`

Calls:

- `inv_overhaul_inventory_items.ItemsBuildIndexCache`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `BuildBackpackIndexCacheAndSnapshot() -> int`

Source: `scripts/player_inventory/inv_overhaul_inventory_controller.lua`

Purpose: Builds backpack index cache and snapshot in the inventory controller subsystem.

Parameters:

None.

Returns:

- `number` (integer) — result of: builds backpack index cache and snapshot in the inventory controller subsystem.

Side effects:

- Delegates to compiler-visible module APIs and inherits their documented side effects.

Called by:

- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: UpdateSlots`
- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: RefreshEquipmentMutation`

Calls:

- `inv_overhaul_inventory_snapshot.BuildIndexCacheAndPrevious`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `PlayerControllerUpdateMoney() -> void`

Source: `scripts/player_inventory/inv_overhaul_inventory_controller.lua`

Purpose: Updates money for player controller in the inventory controller subsystem.

Parameters:

None.

Returns:

None.

Side effects:

- Delegates to compiler-visible module APIs and inherits their documented side effects.

Called by:

- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: RunFramePreparationStage`
- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: RunPersistenceAndRefreshStage`

Calls:

- `inv_overhaul_inventory_presenter.PlayerPresenterUpdateMoney`
- `PlayerControllerGetPlayerContainer`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `InitializeQuickslotBindings() -> void`

Source: `scripts/player_inventory/inv_overhaul_inventory_controller.lua`

Purpose: Initializes quickslot bindings in the inventory controller subsystem.

Parameters:

None.

Returns:

None.

Side effects:

- Delegates to compiler-visible module APIs and inherits their documented side effects.

Called by:

- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: PlayerControllerInitialize`

Calls:

- `inv_overhaul_inventory_quickslot_bindings.InitializeBindings`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `RefreshQuickslotCache() -> void`

Source: `scripts/player_inventory/inv_overhaul_inventory_controller.lua`

Purpose: Refreshes quickslot cache in the inventory controller subsystem.

Parameters:

None.

Returns:

None.

Side effects:

- Delegates to compiler-visible module APIs and inherits their documented side effects.

Called by:

- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: PlayerControllerInitialize`

Calls:

- `inv_overhaul_inventory_quickslot_bindings.RefreshCache`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `GetDisplayedQuickslot(category: int, index: int, itemID: int) -> int`

Source: `scripts/player_inventory/inv_overhaul_inventory_controller.lua`

Purpose: Returns displayed quickslot in the inventory controller subsystem.

Parameters:

- `category: int` — zero-based engine inventory category identifier.
- `index: int` — zero-based entry index in the relevant engine container/category.
- `itemID: int` — engine item or callback identifier interpreted by this function.

Returns:

- `number` (integer) — result of: returns displayed quickslot in the inventory controller subsystem.

Side effects:

- Delegates to compiler-visible module APIs and inherits their documented side effects.

Called by:

- No in-repository caller was resolved; this may be an engine/XML callback or a conventionally public helper.

Calls:

- `inv_overhaul_inventory_quickslot_bindings.GetDisplayedBinding`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `AssignQuickslot(slot: int, category: int, index: int) -> void`

Source: `scripts/player_inventory/inv_overhaul_inventory_controller.lua`

Purpose: Assigns quickslot in the inventory controller subsystem.

Parameters:

- `slot: int` — slot index or encoded slot target interpreted by this function.
- `category: int` — zero-based engine inventory category identifier.
- `index: int` — zero-based entry index in the relevant engine container/category.

Returns:

None.

Side effects:

- Delegates to compiler-visible module APIs and inherits their documented side effects.

Called by:

- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: PlayerControllerAssignHoveredQuickslot`

Calls:

- `inv_overhaul_inventory_quickslot_bindings.Assign`
- `UpdateSlots`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `GetQuickslotByKey(key: int) -> int`

Source: `scripts/player_inventory/inv_overhaul_inventory_controller.lua`

Purpose: Returns quickslot by key in the inventory controller subsystem.

Parameters:

- `key: int` — value interpreted according to the function purpose; no narrower contract is established by current code.

Returns:

- `number` (integer) — result of: returns quickslot by key in the inventory controller subsystem.

Side effects:

- Delegates to compiler-visible module APIs and inherits their documented side effects.

Called by:

- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: OnKeyDown`

Calls:

- `inv_overhaul_inventory_quickslot_bindings.GetSlotByKey`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `PlayerControllerAssignHoveredQuickslot(slot: int) -> void`

Source: `scripts/player_inventory/inv_overhaul_inventory_controller.lua`

Purpose: Assigns hovered quickslot for player controller in the inventory controller subsystem.

Parameters:

- `slot: int` — slot index or encoded slot target interpreted by this function.

Returns:

None.

Side effects:

- Delegates to compiler-visible module APIs and inherits their documented side effects.

Called by:

- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: OnKeyDown`

Calls:

- `inv_overhaul_inventory_drag.PlayerDragIsActive`
- `inv_overhaul_inventory_drag.PlayerDragGetHighlightedTarget`
- `inv_overhaul_inventory_tooltip.GetTarget`
- `ResolveDragSource`
- `AssignQuickslot`
- `inv_overhaul_inventory_items.DecodeReferenceCategory`
- `inv_overhaul_inventory_items.DecodeReferenceIndex`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `PlayerControllerUpdateSlot(slot: int) -> void`

Source: `scripts/player_inventory/inv_overhaul_inventory_controller.lua`

Purpose: Updates slot for player controller in the inventory controller subsystem.

Parameters:

- `slot: int` — slot index or encoded slot target interpreted by this function.

Returns:

None.

Side effects:

- Delegates to compiler-visible module APIs and inherits their documented side effects.

Called by:

- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: TryWarmStartGrid`
- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: PlayerControllerContinueInitialSlotLoad`
- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: UpdateSlots`
- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: UpdateVisibleCell`
- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: SwapSlotOrderCells`

Calls:

- `PlayerControllerGetPlayerContainer`
- `PlayerControllerGetVisibleCell`
- `PlayerControllerResolveVisibleSlot`
- `inv_overhaul_inventory_presenter.PlayerPresenterUpdateSlot`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `PlayerControllerIsItemTexturePreloaded(itemID: int, cacheEpoch: int) -> bool`

Source: `scripts/player_inventory/inv_overhaul_inventory_controller.lua`

Purpose: Returns whether item texture preloaded for player controller in the inventory controller subsystem.

Parameters:

- `itemID: int` — engine item or callback identifier interpreted by this function.
- `cacheEpoch: int` — value interpreted according to the function purpose; no narrower contract is established by current code.

Returns:

- `boolean` — result of: returns whether item texture preloaded for player controller in the inventory controller subsystem.

Side effects:

- Delegates to compiler-visible module APIs and inherits their documented side effects.

Called by:

- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: MeasureInitialTextureCacheCoverage`

Calls:

- `inv_overhaul_inventory_presenter.PlayerPresenterIsItemTexturePreloaded`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `PlayerControllerMarkItemTextureLoaded(category: int, index: int) -> void`

Source: `scripts/player_inventory/inv_overhaul_inventory_controller.lua`

Purpose: Marks item texture loaded for player controller in the inventory controller subsystem.

Parameters:

- `category: int` — zero-based engine inventory category identifier.
- `index: int` — zero-based entry index in the relevant engine container/category.

Returns:

None.

Side effects:

- Delegates to compiler-visible module APIs and inherits their documented side effects.

Called by:

- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: PlayerControllerContinueInitialSlotLoad`

Calls:

- `inv_overhaul_inventory_presenter.PlayerPresenterMarkItemTextureLoaded`
- `PlayerControllerGetPlayerContainer`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `MeasureInitialTextureCacheCoverage() -> void`

Source: `scripts/player_inventory/inv_overhaul_inventory_controller.lua`

Purpose: Measures initial texture cache coverage in the inventory controller subsystem.

Parameters:

None.

Returns:

None.

Side effects:

- Delegates to compiler-visible module APIs and inherits their documented side effects.

Called by:

- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: TryWarmStartGrid`
- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: PlayerControllerBeginInitialSlotLoad`

Calls:

- `inv_overhaul_inventory_view.ResetCacheCoverage`
- `PlayerControllerGetPlayerContainer`
- `inv_overhaul_inventory_items.ItemsGetCachedCategory`
- `inv_overhaul_inventory_items.ItemsGetCachedIndex`
- `container.GetItem`
- `item.GetItemID`
- `PlayerControllerIsItemTexturePreloaded`
- `ReadPerfCacheEpoch`
- `inv_overhaul_inventory_view.RecordStackCacheResult`
- `inv_overhaul_inventory_equipment.PlayerEquipmentGetCachedCategory`
- `inv_overhaul_inventory_equipment.PlayerEquipmentGetCachedIndex`
- `inv_overhaul_inventory_view.RecordEquipmentCacheResult`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `PlayerControllerReportFirstInitialItem() -> void`

Source: `scripts/player_inventory/inv_overhaul_inventory_controller.lua`

Purpose: Reports first initial item for player controller in the inventory controller subsystem.

Parameters:

None.

Returns:

None.

Side effects:

- Delegates to compiler-visible module APIs and inherits their documented side effects.

Called by:

- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: PlayerControllerContinueInitialSlotLoad`

Calls:

- `inv_overhaul_inventory_view.PlayerViewReportFirstInitialItem`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `PlayerControllerReportInitialLoadComplete() -> void`

Source: `scripts/player_inventory/inv_overhaul_inventory_controller.lua`

Purpose: Reports initial load complete for player controller in the inventory controller subsystem.

Parameters:

None.

Returns:

None.

Side effects:

- Delegates to compiler-visible module APIs and inherits their documented side effects.

Called by:

- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: PlayerControllerContinueInitialSlotLoad`

Calls:

- `inv_overhaul_inventory_view.PlayerViewReportInitialLoadComplete`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `TryWarmStartGrid() -> void`

Source: `scripts/player_inventory/inv_overhaul_inventory_controller.lua`

Purpose: Attempts warm start grid in the inventory controller subsystem.

Parameters:

None.

Returns:

None.

Side effects:

- Invokes engine/native operations: `native.Trace`.

Called by:

- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: HandleGlobalProtocolMessage`

Calls:

- `inv_overhaul_inventory_view.BeginWarmStartAttempt`
- `native.GetVariable`
- `inv_overhaul_inventory_view.DebugLoggingEnabled`
- `native.Trace`
- `LoadLayoutVariables`
- `InitializePersistentBackpackSnapshot`
- `OrderFreeCellsByDisplayForCount`
- `ReadLastBackpackItemCount`
- `BuildEquipmentIndexCache`
- `MeasureInitialTextureCacheCoverage`
- `inv_overhaul_inventory_view.GetCacheHits`
- `inv_overhaul_inventory_view.GetCacheMisses`
- `… and 3 more`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `PlayerControllerBeginInitialSlotLoad() -> void`

Source: `scripts/player_inventory/inv_overhaul_inventory_controller.lua`

Purpose: Begins initial slot load for player controller in the inventory controller subsystem.

Parameters:

None.

Returns:

None.

Side effects:

- Invokes engine/native operations: `native.SendMessage`, `native.Trace`.

Called by:

- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: RunMetadataAndLoadingStage`

Calls:

- `PlayerControllerUpdateLayout`
- `ClampPage`
- `BuildEquipmentIndexCache`
- `MeasureInitialTextureCacheCoverage`
- `PlayerControllerUpdatePageControls`
- `inv_overhaul_inventory_view.BeginInitialLoad`
- `ReadVisibleSlots`
- `PlayerControllerGetTargetWndName`
- `native.SendMessage`
- `native.Trace`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `PlayerControllerContinueInitialSlotLoad() -> void`

Source: `scripts/player_inventory/inv_overhaul_inventory_controller.lua`

Purpose: Continues initial slot load for player controller in the inventory controller subsystem.

Parameters:

None.

Returns:

None.

Side effects:

- Invokes engine/native operations: `native.Trace`.

Called by:

- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: RunMetadataAndLoadingStage`

Calls:

- `inv_overhaul_inventory_view.IsInitialLoadActive`
- `inv_overhaul_inventory_view.DebugLoggingEnabled`
- `native.Trace`
- `inv_overhaul_inventory_view.TakeNextEquipment`
- `inv_overhaul_inventory_equipment.PlayerEquipmentGetCachedCategory`
- `inv_overhaul_inventory_equipment.PlayerEquipmentGetCachedIndex`
- `UpdateCachedEquipmentSlot`
- `PlayerControllerMarkItemTextureLoaded`
- `PlayerControllerReportFirstInitialItem`
- `inv_overhaul_inventory_view.TakeNextSlot`
- `ReadVisibleSlots`
- `PlayerControllerGetVisibleCell`
- `… and 7 more`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `UpdateSlots() -> void`

Source: `scripts/player_inventory/inv_overhaul_inventory_controller.lua`

Purpose: Updates slots in the inventory controller subsystem.

Parameters:

None.

Returns:

None.

Side effects:

- Delegates to compiler-visible module APIs and inherits their documented side effects.

Called by:

- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: ReconcileInventoryContentGeneration`
- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: AssignQuickslot`
- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: PlayerControllerHandleModifiedDrop`
- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: HandleSlotMessage`
- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: UnequipTarget`
- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: FinishLeftAction`
- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: ChangePage`
- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: RunPersistenceAndRefreshStage`

Calls:

- `inv_overhaul_inventory_view.FinishInitialLoad`
- `PlayerControllerUpdateLayout`
- `ClampPage`
- `BuildBackpackIndexCacheAndSnapshot`
- `PlayerControllerUpdateSlot`
- `UpdateEquipmentSlots`
- `PlayerControllerUpdatePageControls`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `BuildEquipmentIndexCache() -> void`

Source: `scripts/player_inventory/inv_overhaul_inventory_controller.lua`

Purpose: Builds equipment index cache in the inventory controller subsystem.

Parameters:

None.

Returns:

None.

Side effects:

- Delegates to compiler-visible module APIs and inherits their documented side effects.

Called by:

- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: TryWarmStartGrid`
- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: PlayerControllerBeginInitialSlotLoad`
- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: UpdateEquipmentSlots`
- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: RefreshEquipmentMutation`

Calls:

- `inv_overhaul_inventory_equipment.BuildCache`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `UpdateCachedEquipmentSlot(cache: int) -> void`

Source: `scripts/player_inventory/inv_overhaul_inventory_controller.lua`

Purpose: Updates cached equipment slot in the inventory controller subsystem.

Parameters:

- `cache: int` — value interpreted according to the function purpose; no narrower contract is established by current code.

Returns:

None.

Side effects:

- Delegates to compiler-visible module APIs and inherits their documented side effects.

Called by:

- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: PlayerControllerContinueInitialSlotLoad`
- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: UpdateEquipmentSlots`
- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: RefreshEquipmentMutation`

Calls:

- `PlayerControllerGetTargetWndName`
- `inv_overhaul_inventory_equipment.PlayerEquipmentGetCachedCategory`
- `inv_overhaul_inventory_equipment.PlayerEquipmentGetCachedIndex`
- `inv_overhaul_inventory_presenter.UpdateEquipmentSlot`
- `PlayerControllerGetPlayerContainer`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `UpdateEquipmentSlots() -> void`

Source: `scripts/player_inventory/inv_overhaul_inventory_controller.lua`

Purpose: Updates equipment slots in the inventory controller subsystem.

Parameters:

None.

Returns:

None.

Side effects:

- None directly observable beyond calls listed below.

Called by:

- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: UpdateSlots`

Calls:

- `BuildEquipmentIndexCache`
- `UpdateCachedEquipmentSlot`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `UpdateVisibleCell(cell: int) -> void`

Source: `scripts/player_inventory/inv_overhaul_inventory_controller.lua`

Purpose: Updates visible cell in the inventory controller subsystem.

Parameters:

- `cell: int` — zero-based backpack layout cell.

Returns:

None.

Side effects:

- None directly observable beyond calls listed below.

Called by:

- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: RefreshEquipmentMutation`

Calls:

- `PlayerControllerGetVisibleCell`
- `PlayerControllerUpdateSlot`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `RefreshEquipmentMutation(changedCell: int, equipmentTarget: int) -> void`

Source: `scripts/player_inventory/inv_overhaul_inventory_controller.lua`

Purpose: Refreshes equipment mutation in the inventory controller subsystem.

Parameters:

- `changedCell: int` — zero-based backpack layout cell.
- `equipmentTarget: int` — value interpreted according to the function purpose; no narrower contract is established by current code.

Returns:

None.

Side effects:

- Delegates to compiler-visible module APIs and inherits their documented side effects.

Called by:

- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: FinishLeftAction`

Calls:

- `inv_overhaul_inventory_view.FinishInitialLoad`
- `BuildBackpackIndexCacheAndSnapshot`
- `inv_overhaul_inventory_snapshot.ClampLastBackpackItemCount`
- `UpdateVisibleCell`
- `BuildEquipmentIndexCache`
- `UpdateCachedEquipmentSlot`
- `PlayerControllerUpdatePageControls`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `ResolveEquipmentTarget(target: int) -> int`

Source: `scripts/player_inventory/inv_overhaul_inventory_controller.lua`

Purpose: Resolves equipment target in the inventory controller subsystem.

Parameters:

- `target: int` — value interpreted according to the function purpose; no narrower contract is established by current code.

Returns:

- `number` (integer) — result of: resolves equipment target in the inventory controller subsystem.

Side effects:

- Delegates to compiler-visible module APIs and inherits their documented side effects.

Called by:

- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: ResolveDragSource`
- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: UnequipTarget`
- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: PlayerControllerStartPanelPointerDrag`
- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: UpdatePanelTooltip`
- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: HandleEquipmentProtocolMessage`
- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: OnLButtonDown`

Calls:

- `inv_overhaul_inventory_equipment.ResolveTarget`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `ResolveDragSource(source: int) -> int`

Source: `scripts/player_inventory/inv_overhaul_inventory_controller.lua`

Purpose: Resolves drag source in the inventory controller subsystem.

Parameters:

- `source: int` — value interpreted according to the function purpose; no narrower contract is established by current code.

Returns:

- `number` (integer) — result of: resolves drag source in the inventory controller subsystem.

Side effects:

- None directly observable beyond calls listed below.

Called by:

- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: BeginDragCursor`
- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: PlayerControllerAssignHoveredQuickslot`

Calls:

- `PlayerControllerResolveVisibleSlot`
- `ResolveEquipmentTarget`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `UnequipItem(category: int, index: int) -> bool`

Source: `scripts/player_inventory/inv_overhaul_inventory_controller.lua`

Purpose: Unequips item in the inventory controller subsystem.

Parameters:

- `category: int` — zero-based engine inventory category identifier.
- `index: int` — zero-based entry index in the relevant engine container/category.

Returns:

- `boolean` — result of: unequips item in the inventory controller subsystem.

Side effects:

- Delegates to compiler-visible module APIs and inherits their documented side effects.

Called by:

- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: UnequipTarget`
- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: FinishLeftAction`

Calls:

- `inv_overhaul_inventory_equipment.Unequip`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `EquipDraggedItem(target: int, category: int, index: int) -> bool`

Source: `scripts/player_inventory/inv_overhaul_inventory_controller.lua`

Purpose: Equips dragged item in the inventory controller subsystem.

Parameters:

- `target: int` — value interpreted according to the function purpose; no narrower contract is established by current code.
- `category: int` — zero-based engine inventory category identifier.
- `index: int` — zero-based entry index in the relevant engine container/category.

Returns:

- `boolean` — result of: equips dragged item in the inventory controller subsystem.

Side effects:

- Delegates to compiler-visible module APIs and inherits their documented side effects.

Called by:

- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: FinishLeftAction`

Calls:

- `inv_overhaul_inventory_equipment.Equip`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `ToggleSlot(category: int, index: int) -> void`

Source: `scripts/player_inventory/inv_overhaul_inventory_controller.lua`

Purpose: Toggles slot in the inventory controller subsystem.

Parameters:

- `category: int` — zero-based engine inventory category identifier.
- `index: int` — zero-based entry index in the relevant engine container/category.

Returns:

None.

Side effects:

- Mutates module/task state: `deferredInventoryRefresh`.

Called by:

- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: HandleSlotMessage`

Calls:

- `inv_overhaul_inventory_equipment.PlayerEquipmentToggle`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `PlayerControllerHandleModifiedDrop(sourceSlot: int) -> bool`

Source: `scripts/player_inventory/inv_overhaul_inventory_controller.lua`

Purpose: Handles modified drop for player controller in the inventory controller subsystem.

Parameters:

- `sourceSlot: int` — slot index or encoded slot target interpreted by this function.

Returns:

- `boolean` — result of: handles modified drop for player controller in the inventory controller subsystem.

Side effects:

- Delegates to compiler-visible module APIs and inherits their documented side effects.

Called by:

- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: PlayerControllerStartPanelPointerDrag`
- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: PlayerControllerHandleDragLifecycleMessage`

Calls:

- `PlayerControllerResolveVisibleSlot`
- `PlayerControllerMoveSlotToOtherPage`
- `inv_overhaul_inventory_items.DecodeReferenceCategory`
- `inv_overhaul_inventory_items.DecodeReferenceIndex`
- `PlayerControllerGetPlayerContainer`
- `player.GetItemAmount`
- `PlayerControllerGetBackpackItemCount`
- `PlayerControllerGetOrderValue`
- `PlayerControllerGetVisibleCell`
- `inv_overhaul_inventory_drop.Slot`
- `RemoveOrderOrdinal`
- `UpdateSlots`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `PlayerControllerMoveSlotToOtherPage(sourceSlot: int) -> void`

Source: `scripts/player_inventory/inv_overhaul_inventory_controller.lua`

Purpose: Moves slot to other page for player controller in the inventory controller subsystem.

Parameters:

- `sourceSlot: int` — slot index or encoded slot target interpreted by this function.

Returns:

None.

Side effects:

- Invokes engine/native operations: `native.Trace`.

Called by:

- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: PlayerControllerHandleModifiedDrop`

Calls:

- `PlayerControllerGetMaxPage`
- `inv_overhaul_inventory_paging.GetNextPage`
- `PlayerControllerGetBackpackItemCount`
- `PlayerControllerGetCellForLinearSlot`
- `PlayerControllerGetOrderValue`
- `PlayerControllerShowInventoryFull`
- `PlayerControllerGetVisibleCell`
- `SwapSlotOrderCells`
- `native.Trace`
- `ReadPage`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `HandleSlotMessage(message: int, sender: string) -> bool`

Source: `scripts/player_inventory/inv_overhaul_inventory_controller.lua`

Purpose: Handles slot message in the inventory controller subsystem.

Parameters:

- `message: int` — numeric engine/UI protocol message.
- `sender: string` — name of the UI form that emitted the message.

Returns:

- `boolean` — result of: handles slot message in the inventory controller subsystem.

Side effects:

- Invokes engine/native operations: `native.Trace`.

Called by:

- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: PlayerControllerHandlePanelPointer`
- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: PlayerControllerHandleRegularSlotMessage`

Calls:

- `inv_overhaul_inventory_protocol.GetSlotWindowName`
- `PlayerControllerResolveVisibleSlot`
- `PlayerControllerGetBackpackItemCount`
- `PlayerControllerGetOrderValue`
- `PlayerControllerGetVisibleCell`
- `inv_overhaul_inventory_items.DecodeReferenceCategory`
- `inv_overhaul_inventory_items.DecodeReferenceIndex`
- `ToggleSlot`
- `native.Trace`
- `RestoreOrderAfterEquipmentSelection`
- `RemoveOrderOrdinal`
- `RestoreOrderAfterEquipmentReplacement`
- `… and 1 more`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `GetDragSourceBySender(sender: string) -> int`

Source: `scripts/player_inventory/inv_overhaul_inventory_controller.lua`

Purpose: Returns drag source by sender in the inventory controller subsystem.

Parameters:

- `sender: string` — name of the UI form that emitted the message.

Returns:

- `number` (integer) — result of: returns drag source by sender in the inventory controller subsystem.

Side effects:

- Delegates to compiler-visible module APIs and inherits their documented side effects.

Called by:

- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: PlayerControllerHandleDragLifecycleMessage`

Calls:

- `inv_overhaul_inventory_protocol.GetSlotBySender`
- `ReadVisibleSlots`
- `inv_overhaul_inventory_protocol.GetSpecialTargetBySender`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `IsSpecialTargetCompatible(target: int) -> bool`

Source: `scripts/player_inventory/inv_overhaul_inventory_controller.lua`

Purpose: Returns whether special target compatible in the inventory controller subsystem.

Parameters:

- `target: int` — value interpreted according to the function purpose; no narrower contract is established by current code.

Returns:

- `boolean` — result of: returns whether special target compatible in the inventory controller subsystem.

Side effects:

- Delegates to compiler-visible module APIs and inherits their documented side effects.

Called by:

- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: HandleEquipmentProtocolMessage`

Calls:

- `inv_overhaul_inventory_equipment.PlayerEquipmentIsTargetCompatible`
- `ReadDragItemCategory`
- `ReadDragItemIsWeapon`
- `ReadDragItemGroup`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `StartDragAction(source: int, sender: string) -> void`

Source: `scripts/player_inventory/inv_overhaul_inventory_controller.lua`

Purpose: Starts drag action in the inventory controller subsystem.

Parameters:

- `source: int` — value interpreted according to the function purpose; no narrower contract is established by current code.
- `sender: string` — name of the UI form that emitted the message.

Returns:

None.

Side effects:

- Invokes engine/native operations: `native.Trace`.

Called by:

- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: PlayerControllerStartPanelPointerDrag`
- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: HandleEquipmentProtocolMessage`
- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: PlayerControllerHandleDragLifecycleMessage`
- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: OnLButtonDown`

Calls:

- `native.GetVariable`
- `ReconcileInventoryContentGeneration`
- `CancelDragPageHover`
- `inv_overhaul_inventory_tooltip.InterfaceTooltipClear`
- `PlayerControllerGetVisibleCell`
- `inv_overhaul_inventory_drag.BeginTransaction`
- `SetHighlightedSlot`
- `BeginDragCursor`
- `ReadDragSourceSlot`
- `native.Trace`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `UnequipTarget(target: int, reason: string) -> void`

Source: `scripts/player_inventory/inv_overhaul_inventory_controller.lua`

Purpose: Unequips target in the inventory controller subsystem.

Parameters:

- `target: int` — value interpreted according to the function purpose; no narrower contract is established by current code.
- `reason: string` — value interpreted according to the function purpose; no narrower contract is established by current code.

Returns:

None.

Side effects:

- Invokes engine/native operations: `native.Trace`.

Called by:

- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: PlayerControllerHandlePanelPointer`
- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: HandleEquipmentProtocolMessage`
- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: OnRButtonDown`

Calls:

- `ResolveEquipmentTarget`
- `PlayerControllerGetBackpackItemCount`
- `native.Trace`
- `PlayerControllerShowInventoryFull`
- `inv_overhaul_inventory_items.DecodeReferenceCategory`
- `inv_overhaul_inventory_items.DecodeReferenceIndex`
- `UnequipItem`
- `InsertOrderOrdinal`
- `PlayerControllerGetBackpackOrdinal`
- `UpdateSlots`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `SwapSlotOrderCells(sourceCell: int, targetCell: int) -> void`

Source: `scripts/player_inventory/inv_overhaul_inventory_controller.lua`

Purpose: Swaps slot order cells in the inventory controller subsystem.

Parameters:

- `sourceCell: int` — zero-based backpack layout cell.
- `targetCell: int` — zero-based backpack layout cell.

Returns:

None.

Side effects:

- Delegates to compiler-visible module APIs and inherits their documented side effects.

Called by:

- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: PlayerControllerMoveSlotToOtherPage`
- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: FinishLeftAction`

Calls:

- `inv_overhaul_inventory_layout_runtime.LayoutRuntimeSwapCells`
- `QueueLayoutSave`
- `PlayerControllerGetVisibleCell`
- `PlayerControllerUpdateSlot`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `RemoveOrderOrdinal(removedOrder: int, beforeCount: int) -> void`

Source: `scripts/player_inventory/inv_overhaul_inventory_controller.lua`

Purpose: Removes order ordinal in the inventory controller subsystem.

Parameters:

- `removedOrder: int` — value interpreted according to the function purpose; no narrower contract is established by current code.
- `beforeCount: int` — value interpreted according to the function purpose; no narrower contract is established by current code.

Returns:

None.

Side effects:

- Delegates to compiler-visible module APIs and inherits their documented side effects.

Called by:

- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: PlayerControllerHandleModifiedDrop`
- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: HandleSlotMessage`
- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: FinishLeftAction`

Calls:

- `inv_overhaul_inventory_layout_runtime.RemoveOrdinal`
- `PlayerControllerGetBackpackItemCount`
- `ReadVisibleSlots`
- `QueueLayoutSave`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `FindFirstFreeVisualSlot(itemCount: int) -> int`

Source: `scripts/player_inventory/inv_overhaul_inventory_controller.lua`

Purpose: Finds first free visual slot in the inventory controller subsystem.

Parameters:

- `itemCount: int` — value interpreted according to the function purpose; no narrower contract is established by current code.

Returns:

- `number` (integer) — result of: finds first free visual slot in the inventory controller subsystem.

Side effects:

- Delegates to compiler-visible module APIs and inherits their documented side effects.

Called by:

- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: InsertOrderOrdinal`

Calls:

- `inv_overhaul_inventory_layout_runtime.FindFirstFreeCell`
- `ReadVisibleSlots`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `PlayerControllerGetBackpackOrdinal(category: int, index: int) -> int`

Source: `scripts/player_inventory/inv_overhaul_inventory_controller.lua`

Purpose: Returns backpack ordinal for player controller in the inventory controller subsystem.

Parameters:

- `category: int` — zero-based engine inventory category identifier.
- `index: int` — zero-based entry index in the relevant engine container/category.

Returns:

- `number` (integer) — result of: returns backpack ordinal for player controller in the inventory controller subsystem.

Side effects:

- Delegates to compiler-visible module APIs and inherits their documented side effects.

Called by:

- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: UnequipTarget`
- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: FinishLeftAction`

Calls:

- `inv_overhaul_inventory_items.ItemsGetBackpackOrdinal`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `InsertOrderOrdinal(insertedOrder: int, beforeCount: int) -> bool`

Source: `scripts/player_inventory/inv_overhaul_inventory_controller.lua`

Purpose: Inserts order ordinal in the inventory controller subsystem.

Parameters:

- `insertedOrder: int` — value interpreted according to the function purpose; no narrower contract is established by current code.
- `beforeCount: int` — value interpreted according to the function purpose; no narrower contract is established by current code.

Returns:

- `boolean` — result of: inserts order ordinal in the inventory controller subsystem.

Side effects:

- None directly observable beyond calls listed below.

Called by:

- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: UnequipTarget`

Calls:

- `InsertOrderOrdinalAtCell`
- `FindFirstFreeVisualSlot`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `InsertOrderOrdinalAtCell(insertedOrder: int, beforeCount: int, targetCell: int) -> bool`

Source: `scripts/player_inventory/inv_overhaul_inventory_controller.lua`

Purpose: Inserts order ordinal at cell in the inventory controller subsystem.

Parameters:

- `insertedOrder: int` — value interpreted according to the function purpose; no narrower contract is established by current code.
- `beforeCount: int` — value interpreted according to the function purpose; no narrower contract is established by current code.
- `targetCell: int` — zero-based backpack layout cell.

Returns:

- `boolean` — result of: inserts order ordinal at cell in the inventory controller subsystem.

Side effects:

- Delegates to compiler-visible module APIs and inherits their documented side effects.

Called by:

- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: InsertOrderOrdinal`
- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: FinishLeftAction`

Calls:

- `inv_overhaul_inventory_layout_runtime.InsertOrdinal`
- `PlayerControllerGetBackpackItemCount`
- `ReadVisibleSlots`
- `QueueLayoutSave`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `SetHighlightedSlot(slot: int) -> void`

Source: `scripts/player_inventory/inv_overhaul_inventory_controller.lua`

Purpose: Sets highlighted slot in the inventory controller subsystem.

Parameters:

- `slot: int` — slot index or encoded slot target interpreted by this function.

Returns:

None.

Side effects:

- Invokes engine/native operations: `native.SendMessage`.

Called by:

- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: StartDragAction`
- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: CancelDragAction`
- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: FinishLeftAction`
- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: ApplyPointerSlot`
- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: UpdateDragPageHover`
- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: HandleEquipmentProtocolMessage`
- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: HandleSlotPointerProtocolMessage`
- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: PlayerControllerHandleDragLifecycleMessage`
- `… and 1 more`

Calls:

- `inv_overhaul_inventory_drag.PlayerDragGetHighlightedTarget`
- `PlayerControllerSetGridRendererHighlight`
- `native.SendMessage`
- `PlayerControllerGetTargetWndName`
- `inv_overhaul_inventory_drag.PlayerDragSetHighlightedTarget`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `CancelDragAction() -> void`

Source: `scripts/player_inventory/inv_overhaul_inventory_controller.lua`

Purpose: Cancels drag action in the inventory controller subsystem.

Parameters:

None.

Returns:

None.

Side effects:

- Invokes engine/native operations: `native.SendMessage`.

Called by:

- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: ReconcileInventoryContentGeneration`
- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: HandleEquipmentProtocolMessage`

Calls:

- `inv_overhaul_inventory_drag.PlayerDragIsActive`
- `inv_overhaul_inventory_drag.GetSourceSlot`
- `inv_overhaul_inventory_tooltip.Suspend`
- `inv_overhaul_inventory_tooltip.InterfaceTooltipClear`
- `native.SendMessage`
- `PlayerControllerGetTargetWndName`
- `inv_overhaul_inventory_drag.ClearTransaction`
- `SetHighlightedSlot`
- `EndDragCursor`
- `CancelDragPageHover`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `FinishLeftAction(targetSlot: int) -> void`

Source: `scripts/player_inventory/inv_overhaul_inventory_controller.lua`

Purpose: Completes left action in the inventory controller subsystem.

Parameters:

- `targetSlot: int` — slot index or encoded slot target interpreted by this function.

Returns:

None.

Side effects:

- Invokes engine/native operations: `native.Trace`, `native.SendMessage`.

Called by:

- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: PlayerControllerHandlePanelPointer`
- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: HandleEquipmentProtocolMessage`
- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: HandleSlotPointerProtocolMessage`
- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: PlayerControllerHandleDragLifecycleMessage`
- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: OnLButtonUp`

Calls:

- `inv_overhaul_inventory_drag.PlayerDragIsActive`
- `native.GetVariable`
- `ReconcileInventoryContentGeneration`
- `inv_overhaul_inventory_drag.GetSourceSlot`
- `inv_overhaul_inventory_drag.PlayerDragResolveReleaseTarget`
- `native.Trace`
- `inv_overhaul_inventory_tooltip.Suspend`
- `inv_overhaul_inventory_tooltip.InterfaceTooltipClear`
- `native.SendMessage`
- `PlayerControllerGetTargetWndName`
- `PlayerControllerGetBackpackItemCount`
- `UnequipItem`
- `… and 23 more`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `FindBackpackSlotAt(x: int, y: int) -> int`

Source: `scripts/player_inventory/inv_overhaul_inventory_controller.lua`

Purpose: Finds backpack slot at in the inventory controller subsystem.

Parameters:

- `x: int` — pointer/layout coordinate interpreted by this function.
- `y: int` — pointer/layout coordinate interpreted by this function.

Returns:

- `number` (integer) — result of: finds backpack slot at in the inventory controller subsystem.

Side effects:

- Delegates to compiler-visible module APIs and inherits their documented side effects.

Called by:

- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: FindSlotAt`
- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: PlayerControllerStartPanelPointerDrag`
- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: UpdatePanelTooltip`
- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: PlayerControllerHandlePanelPointer`

Calls:

- `inv_overhaul_inventory_geometry.FindBackpackSlot`
- `ReadWindowWidth`
- `ReadVisibleSlots`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `FindSlotAt(x: int, y: int) -> int`

Source: `scripts/player_inventory/inv_overhaul_inventory_controller.lua`

Purpose: Finds slot at in the inventory controller subsystem.

Parameters:

- `x: int` — pointer/layout coordinate interpreted by this function.
- `y: int` — pointer/layout coordinate interpreted by this function.

Returns:

- `number` (integer) — result of: finds slot at in the inventory controller subsystem.

Side effects:

- None directly observable beyond calls listed below.

Called by:

- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: FindSlotAtPointer`
- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: PlayerControllerHandlePanelPointer`

Calls:

- `FindBackpackSlotAt`
- `FindSpecialTargetAt`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `PlayerControllerIsInsideSlotDropArea(localX: int, localY: int) -> bool`

Source: `scripts/player_inventory/inv_overhaul_inventory_controller.lua`

Purpose: Returns whether inside slot drop area for player controller in the inventory controller subsystem.

Parameters:

- `localX: int` — pointer/layout coordinate interpreted by this function.
- `localY: int` — pointer/layout coordinate interpreted by this function.

Returns:

- `boolean` — result of: returns whether inside slot drop area for player controller in the inventory controller subsystem.

Side effects:

- Delegates to compiler-visible module APIs and inherits their documented side effects.

Called by:

- No in-repository caller was resolved; this may be an engine/XML callback or a conventionally public helper.

Calls:

- `inv_overhaul_inventory_geometry.InterfaceGeometryIsInsideSlotDropArea`
- `ReadWindowWidth`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `FindSlotAtPointer(x: int, y: int) -> int`

Source: `scripts/player_inventory/inv_overhaul_inventory_controller.lua`

Purpose: Finds slot at pointer in the inventory controller subsystem.

Parameters:

- `x: int` — pointer/layout coordinate interpreted by this function.
- `y: int` — pointer/layout coordinate interpreted by this function.

Returns:

- `number` (integer) — result of: finds slot at pointer in the inventory controller subsystem.

Side effects:

- None directly observable beyond calls listed below.

Called by:

- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: UpdatePointerSlot`

Calls:

- `FindSlotAt`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `UpdatePointerSlot(x: int, y: int) -> int`

Source: `scripts/player_inventory/inv_overhaul_inventory_controller.lua`

Purpose: Updates pointer slot in the inventory controller subsystem.

Parameters:

- `x: int` — pointer/layout coordinate interpreted by this function.
- `y: int` — pointer/layout coordinate interpreted by this function.

Returns:

- `number` (integer) — result of: updates pointer slot in the inventory controller subsystem.

Side effects:

- None directly observable beyond calls listed below.

Called by:

- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: OnMouseMove`
- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: OnLButtonUp`

Calls:

- `FindSlotAtPointer`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `ApplyPointerSlot(slot: int) -> void`

Source: `scripts/player_inventory/inv_overhaul_inventory_controller.lua`

Purpose: Applies pointer slot in the inventory controller subsystem.

Parameters:

- `slot: int` — slot index or encoded slot target interpreted by this function.

Returns:

None.

Side effects:

- Delegates to compiler-visible module APIs and inherits their documented side effects.

Called by:

- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: PlayerControllerHandlePanelPointer`
- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: HandleEquipmentProtocolMessage`
- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: HandleSlotPointerProtocolMessage`
- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: OnMouseMove`
- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: OnLButtonUp`

Calls:

- `inv_overhaul_inventory_drag.PlayerDragIsActive`
- `inv_overhaul_inventory_drag.GetSourceSlot`
- `inv_overhaul_inventory_drag.GetSourceCell`
- `PlayerControllerGetVisibleCell`
- `inv_overhaul_inventory_drag.PlayerDragApplyPointerTarget`
- `SetHighlightedSlot`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `GetCurrentDropSlot(message: int, base: int, sender: string) -> int`

Source: `scripts/player_inventory/inv_overhaul_inventory_controller.lua`

Purpose: Returns current drop slot in the inventory controller subsystem.

Parameters:

- `message: int` — numeric engine/UI protocol message.
- `base: int` — value interpreted according to the function purpose; no narrower contract is established by current code.
- `sender: string` — name of the UI form that emitted the message.

Returns:

- `number` (integer) — result of: returns current drop slot in the inventory controller subsystem.

Side effects:

- None directly observable beyond calls listed below.

Called by:

- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: HandleSlotPointerProtocolMessage`

Calls:

- `PlayerControllerGetSlotTargetFromPointerMessage`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `PlayerControllerGetSlotTargetFromPointerMessage(message: int, base: int, sender: string) -> int`

Source: `scripts/player_inventory/inv_overhaul_inventory_controller.lua`

Purpose: Returns slot target from pointer message for player controller in the inventory controller subsystem.

Parameters:

- `message: int` — numeric engine/UI protocol message.
- `base: int` — value interpreted according to the function purpose; no narrower contract is established by current code.
- `sender: string` — name of the UI form that emitted the message.

Returns:

- `number` (integer) — result of: returns slot target from pointer message for player controller in the inventory controller subsystem.

Side effects:

- Delegates to compiler-visible module APIs and inherits their documented side effects.

Called by:

- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: GetCurrentDropSlot`
- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: HandleSlotPointerProtocolMessage`

Calls:

- `inv_overhaul_inventory_input_controller.PlayerInputGetSlotTargetFromPointerMessage`
- `ReadVisibleSlots`
- `ReadWindowWidth`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `ChangePage(delta: int) -> void`

Source: `scripts/player_inventory/inv_overhaul_inventory_controller.lua`

Purpose: Changes page in the inventory controller subsystem.

Parameters:

- `delta: int` — elapsed update time in seconds.

Returns:

None.

Side effects:

- Delegates to compiler-visible module APIs and inherits their documented side effects.

Called by:

- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: UpdateDragPageHover`
- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: HandlePageControlAt`
- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: HandlePagingProtocolMessage`

Calls:

- `inv_overhaul_inventory_paging.Change`
- `ReadVisibleSlots`
- `UpdateSlots`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `PlayerControllerGetDragPageHoverAction(sender: string) -> int`

Source: `scripts/player_inventory/inv_overhaul_inventory_controller.lua`

Purpose: Returns drag page hover action for player controller in the inventory controller subsystem.

Parameters:

- `sender: string` — name of the UI form that emitted the message.

Returns:

- `number` (integer) — result of: returns drag page hover action for player controller in the inventory controller subsystem.

Side effects:

- Delegates to compiler-visible module APIs and inherits their documented side effects.

Called by:

- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: BeginDragPageHover`
- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: HandleGlobalProtocolMessage`

Calls:

- `inv_overhaul_inventory_input_controller.PlayerInputGetDragPageHoverAction`
- `PlayerControllerGetMaxPage`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `BeginDragPageHover(sender: string) -> void`

Source: `scripts/player_inventory/inv_overhaul_inventory_controller.lua`

Purpose: Begins drag page hover in the inventory controller subsystem.

Parameters:

- `sender: string` — name of the UI form that emitted the message.

Returns:

None.

Side effects:

- Invokes engine/native operations: `native.Trace`.

Called by:

- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: HandleGlobalProtocolMessage`

Calls:

- `inv_overhaul_inventory_drag.PlayerDragIsActive`
- `PlayerControllerGetDragPageHoverAction`
- `inv_overhaul_inventory_drag.PlayerDragBeginPageHover`
- `native.Trace`
- `inv_overhaul_inventory_drag.GetSourceSlot`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `CancelDragPageHover(action: int) -> void`

Source: `scripts/player_inventory/inv_overhaul_inventory_controller.lua`

Purpose: Cancels drag page hover in the inventory controller subsystem.

Parameters:

- `action: int` — value interpreted according to the function purpose; no narrower contract is established by current code.

Returns:

None.

Side effects:

- Invokes engine/native operations: `native.Trace`.

Called by:

- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: StartDragAction`
- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: CancelDragAction`
- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: FinishLeftAction`
- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: UpdateDragPageHover`
- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: SyncDragPageHoverFromCursor`
- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: HandleGlobalProtocolMessage`

Calls:

- `inv_overhaul_inventory_drag.PlayerDragCanCancelPageHover`
- `inv_overhaul_inventory_drag.PlayerDragGetPageHoverAction`
- `native.Trace`
- `inv_overhaul_inventory_drag.PlayerDragGetPageHoverElapsed`
- `inv_overhaul_inventory_drag.PlayerDragClearPageHover`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `UpdateDragPageHover(delta: float) -> void`

Source: `scripts/player_inventory/inv_overhaul_inventory_controller.lua`

Purpose: Updates drag page hover in the inventory controller subsystem.

Parameters:

- `delta: float` — elapsed update time in seconds.

Returns:

None.

Side effects:

- Invokes engine/native operations: `native.Trace`.

Called by:

- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: RunDragHoverStage`

Calls:

- `inv_overhaul_inventory_drag.PlayerDragGetPageHoverAction`
- `inv_overhaul_inventory_drag.PlayerDragIsActive`
- `inv_overhaul_inventory_paging.CanMove`
- `PlayerControllerGetMaxPage`
- `CancelDragPageHover`
- `inv_overhaul_inventory_drag.PlayerDragAdvancePageHover`
- `SetHighlightedSlot`
- `native.Trace`
- `ReadPage`
- `ChangePage`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `SyncDragPageHoverFromCursor() -> void`

Source: `scripts/player_inventory/inv_overhaul_inventory_controller.lua`

Purpose: Synchronizes drag page hover from cursor in the inventory controller subsystem.

Parameters:

None.

Returns:

None.

Side effects:

- Invokes engine/native operations: `native.Trace`.

Called by:

- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: RunDragHoverStage`

Calls:

- `inv_overhaul_inventory_drag.PlayerDragIsActive`
- `CancelDragPageHover`
- `native.GetVariable`
- `inv_overhaul_inventory_paging.GetCursorHoverAction`
- `PlayerControllerGetMaxPage`
- `inv_overhaul_inventory_drag.PlayerDragBeginPageHover`
- `native.Trace`
- `ReadPage`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `RunFramePreparationStage(delta: float) -> void`

Source: `scripts/player_inventory/inv_overhaul_inventory_controller.lua`

Purpose: Runs frame preparation stage in the inventory controller subsystem.

Parameters:

- `delta: float` — elapsed update time in seconds.

Returns:

None.

Side effects:

- Mutates module/task state: `lastLayoutWidth`, `lastLayoutHeight`, `lastLayoutSlots`, `inventoryFullMessageCooldown`.
- Invokes engine/native operations: `native.Trace`.

Called by:

- `scripts/player_inventory/inv_overhaul_inventory.lua :: OnUpdate`

Calls:

- `inv_overhaul_inventory_view.ClaimChildWindowsReady`
- `inv_overhaul_inventory_view.DebugLoggingEnabled`
- `native.Trace`
- `PlayerControllerUpdateLayout`
- `PlayerControllerUpdatePageControls`
- `PlayerControllerUpdateMoney`
- `inv_overhaul_inventory_tooltip.AdvanceSuspension`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `RunMetadataAndLoadingStage(delta: float) -> void`

Source: `scripts/player_inventory/inv_overhaul_inventory_controller.lua`

Purpose: Runs metadata and loading stage in the inventory controller subsystem.

Parameters:

- `delta: float` — elapsed update time in seconds.

Returns:

None.

Side effects:

- Invokes engine/native operations: `native.Trace`.

Called by:

- `scripts/player_inventory/inv_overhaul_inventory.lua :: OnUpdate`

Calls:

- `inv_overhaul_inventory_view.AdvanceMetadataDelay`
- `inv_overhaul_inventory_view.GetMetadataStage`
- `inv_overhaul_inventory_view.DebugLoggingEnabled`
- `native.Trace`
- `ContinueIncrementalLayoutLoad`
- `inv_overhaul_inventory_view.AdvanceMetadataStage`
- `InitializePersistentBackpackSnapshot`
- `OrderFreeCellsByDisplayForCount`
- `ReadLastBackpackItemCount`
- `inv_overhaul_inventory_view.CompleteMetadata`
- `PlayerControllerBeginInitialSlotLoad`
- `inv_overhaul_inventory_view.IsInitialLoadActive`
- `… and 3 more`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `RunPersistenceAndRefreshStage(delta: float) -> void`

Source: `scripts/player_inventory/inv_overhaul_inventory_controller.lua`

Purpose: Runs persistence and refresh stage in the inventory controller subsystem.

Parameters:

- `delta: float` — elapsed update time in seconds.

Returns:

None.

Side effects:

- Mutates module/task state: `inventoryPollCooldown`, `deferredInventoryRefresh`.
- Invokes engine/native operations: `native.Trace`.

Called by:

- `scripts/player_inventory/inv_overhaul_inventory.lua :: OnUpdate`

Calls:

- `ContinueLayoutSave`
- `PlayerControllerUpdateMoney`
- `native.GetVariable`
- `ReconcileInventoryContentGeneration`
- `UpdateSlots`
- `native.Trace`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `RunDragHoverStage(delta: float) -> void`

Source: `scripts/player_inventory/inv_overhaul_inventory_controller.lua`

Purpose: Runs drag hover stage in the inventory controller subsystem.

Parameters:

- `delta: float` — elapsed update time in seconds.

Returns:

None.

Side effects:

- None directly observable beyond calls listed below.

Called by:

- `scripts/player_inventory/inv_overhaul_inventory.lua :: OnUpdate`

Calls:

- `SyncDragPageHoverFromCursor`
- `UpdateDragPageHover`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `PlayerControllerStartPanelPointerDrag(x: int, y: int) -> void`

Source: `scripts/player_inventory/inv_overhaul_inventory_controller.lua`

Purpose: Starts panel pointer drag for player controller in the inventory controller subsystem.

Parameters:

- `x: int` — pointer/layout coordinate interpreted by this function.
- `y: int` — pointer/layout coordinate interpreted by this function.

Returns:

None.

Side effects:

- Delegates to compiler-visible module APIs and inherits their documented side effects.

Called by:

- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: PlayerControllerHandlePanelPointer`

Calls:

- `inv_overhaul_inventory_drag.PlayerDragIsActive`
- `FindEquipmentTargetAt`
- `ResolveEquipmentTarget`
- `StartDragAction`
- `FindBackpackSlotAt`
- `PlayerControllerHandleModifiedDrop`
- `PlayerControllerResolveVisibleSlot`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `PlayerControllerGetPageControlX() -> int`

Source: `scripts/player_inventory/inv_overhaul_inventory_controller.lua`

Purpose: Returns page control x for player controller in the inventory controller subsystem.

Parameters:

None.

Returns:

- `number` (integer) — result of: returns page control x for player controller in the inventory controller subsystem.

Side effects:

- Delegates to compiler-visible module APIs and inherits their documented side effects.

Called by:

- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: HandlePageControlAt`
- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: UpdatePageControlHover`

Calls:

- `inv_overhaul_inventory_input_controller.PlayerInputGetPageControlX`
- `ReadWindowWidth`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `PlayerControllerGetPageControlY() -> int`

Source: `scripts/player_inventory/inv_overhaul_inventory_controller.lua`

Purpose: Returns page control y for player controller in the inventory controller subsystem.

Parameters:

None.

Returns:

- `number` (integer) — result of: returns page control y for player controller in the inventory controller subsystem.

Side effects:

- Delegates to compiler-visible module APIs and inherits their documented side effects.

Called by:

- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: HandlePageControlAt`
- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: UpdatePageControlHover`

Calls:

- `inv_overhaul_inventory_input_controller.PlayerInputGetPageControlY`
- `ReadWindowWidth`
- `GetBranch`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `PlayerControllerIsInsideQuickslotHelp(x: int, y: int) -> bool`

Source: `scripts/player_inventory/inv_overhaul_inventory_controller.lua`

Purpose: Returns whether inside quickslot help for player controller in the inventory controller subsystem.

Parameters:

- `x: int` — pointer/layout coordinate interpreted by this function.
- `y: int` — pointer/layout coordinate interpreted by this function.

Returns:

- `boolean` — result of: returns whether inside quickslot help for player controller in the inventory controller subsystem.

Side effects:

- Delegates to compiler-visible module APIs and inherits their documented side effects.

Called by:

- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: UpdatePanelTooltip`

Calls:

- `inv_overhaul_inventory_input_controller.PlayerInputIsInsideQuickslotHelp`
- `ReadWindowWidth`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `PlayerControllerIsInsidePlayerPaging(x: int, y: int) -> bool`

Source: `scripts/player_inventory/inv_overhaul_inventory_controller.lua`

Purpose: Returns whether inside player paging for player controller in the inventory controller subsystem.

Parameters:

- `x: int` — pointer/layout coordinate interpreted by this function.
- `y: int` — pointer/layout coordinate interpreted by this function.

Returns:

- `boolean` — result of: returns whether inside player paging for player controller in the inventory controller subsystem.

Side effects:

- Delegates to compiler-visible module APIs and inherits their documented side effects.

Called by:

- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: UpdatePanelTooltip`

Calls:

- `inv_overhaul_inventory_input_controller.PlayerInputIsInsidePlayerPaging`
- `ReadWindowWidth`
- `GetBranch`
- `PlayerControllerGetMaxPage`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `UpdatePanelTooltip(x: int, y: int) -> void`

Source: `scripts/player_inventory/inv_overhaul_inventory_controller.lua`

Purpose: Updates panel tooltip in the inventory controller subsystem.

Parameters:

- `x: int` — pointer/layout coordinate interpreted by this function.
- `y: int` — pointer/layout coordinate interpreted by this function.

Returns:

None.

Side effects:

- Delegates to compiler-visible module APIs and inherits their documented side effects.

Called by:

- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: PlayerControllerHandlePanelPointer`

Calls:

- `inv_overhaul_inventory_tooltip.IsSuspended`
- `inv_overhaul_inventory_tooltip.InterfaceTooltipClear`
- `inv_overhaul_inventory_drag.PlayerDragIsActive`
- `PlayerControllerIsInsideQuickslotHelp`
- `inv_overhaul_inventory_tooltip.ShowText`
- `PlayerControllerIsInsidePlayerPaging`
- `PlayerControllerIsInsideSpecialTarget`
- `PlayerControllerIsInsideMoney`
- `inv_overhaul_inventory_tooltip.ShowMoney`
- `FindBackpackSlotAt`
- `PlayerControllerResolveVisibleSlot`
- `FindEquipmentTargetAt`
- `… and 7 more`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `PlayerControllerHandlePanelPointer(message: int) -> void`

Source: `scripts/player_inventory/inv_overhaul_inventory_controller.lua`

Purpose: Handles panel pointer for player controller in the inventory controller subsystem.

Parameters:

- `message: int` — numeric engine/UI protocol message.

Returns:

None.

Side effects:

- Invokes engine/native operations: `native.SendMessage`.

Called by:

- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: HandleGlobalProtocolMessage`

Calls:

- `inv_overhaul_inventory_tooltip.InterfaceTooltipClear`
- `native.SendMessage`
- `inv_overhaul_inventory_input_controller.DecodePanelPointerBase`
- `inv_overhaul_inventory_input_controller.DecodePanelPointerAction`
- `inv_overhaul_inventory_protocol.InterfaceProtocolDecodePanelPointerX`
- `inv_overhaul_inventory_protocol.InterfaceProtocolDecodePanelPointerY`
- `UpdatePageControlHover`
- `UpdatePanelTooltip`
- `HandlePageControlAt`
- `PlayerControllerStartPanelPointerDrag`
- `FindEquipmentTargetAt`
- `UnequipTarget`
- `… and 7 more`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `HandlePageControlAt(x: int, y: int) -> bool`

Source: `scripts/player_inventory/inv_overhaul_inventory_controller.lua`

Purpose: Handles page control at in the inventory controller subsystem.

Parameters:

- `x: int` — pointer/layout coordinate interpreted by this function.
- `y: int` — pointer/layout coordinate interpreted by this function.

Returns:

- `boolean` — result of: handles page control at in the inventory controller subsystem.

Side effects:

- Delegates to compiler-visible module APIs and inherits their documented side effects.

Called by:

- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: PlayerControllerHandlePanelPointer`
- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: OnLButtonDown`

Calls:

- `PlayerControllerGetPageControlX`
- `PlayerControllerGetPageControlY`
- `inv_overhaul_inventory_paging.GetControlAction`
- `inv_overhaul_inventory_paging.CanMove`
- `PlayerControllerGetMaxPage`
- `ChangePage`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `UpdatePageControlHover(x: int, y: int) -> void`

Source: `scripts/player_inventory/inv_overhaul_inventory_controller.lua`

Purpose: Updates page control hover in the inventory controller subsystem.

Parameters:

- `x: int` — pointer/layout coordinate interpreted by this function.
- `y: int` — pointer/layout coordinate interpreted by this function.

Returns:

None.

Side effects:

- Invokes engine/native operations: `native.SendMessage`.

Called by:

- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: PlayerControllerHandlePanelPointer`

Calls:

- `PlayerControllerGetMaxPage`
- `PlayerControllerGetPageControlX`
- `PlayerControllerGetPageControlY`
- `inv_overhaul_inventory_paging.IsControlHovered`
- `native.SendMessage`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `HandleGlobalProtocolMessage(message: int, sender: string) -> bool`

Source: `scripts/player_inventory/inv_overhaul_inventory_controller.lua`

Purpose: Handles global protocol message in the inventory controller subsystem.

Parameters:

- `message: int` — numeric engine/UI protocol message.
- `sender: string` — name of the UI form that emitted the message.

Returns:

- `boolean` — result of: handles global protocol message in the inventory controller subsystem.

Side effects:

- Delegates to compiler-visible module APIs and inherits their documented side effects.

Called by:

- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: OnUIMessage`

Calls:

- `inv_overhaul_inventory_tooltip.ShowText`
- `inv_overhaul_inventory_view.MarkRendererReady`
- `TryWarmStartGrid`
- `BeginDragPageHover`
- `CancelDragPageHover`
- `PlayerControllerGetDragPageHoverAction`
- `PlayerControllerHandlePanelPointer`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `HandleEquipmentProtocolMessage(message: int, sender: string) -> bool`

Source: `scripts/player_inventory/inv_overhaul_inventory_controller.lua`

Purpose: Handles equipment protocol message in the inventory controller subsystem.

Parameters:

- `message: int` — numeric engine/UI protocol message.
- `sender: string` — name of the UI form that emitted the message.

Returns:

- `boolean` — result of: handles equipment protocol message in the inventory controller subsystem.

Side effects:

- Delegates to compiler-visible module APIs and inherits their documented side effects.

Called by:

- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: OnUIMessage`

Calls:

- `inv_overhaul_inventory_protocol.GetSpecialTargetBySender`
- `UnequipTarget`
- `inv_overhaul_inventory_protocol.GetDollTargetBySourceMessage`
- `ResolveEquipmentTarget`
- `StartDragAction`
- `inv_overhaul_inventory_drag.PlayerDragIsActive`
- `IsSpecialTargetCompatible`
- `inv_overhaul_inventory_drag.SetHoverTarget`
- `ApplyPointerSlot`
- `SetHighlightedSlot`
- `inv_overhaul_inventory_protocol.GetDollTargetByHoverMessage`
- `FinishLeftAction`
- `… and 1 more`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `HandlePagingProtocolMessage(message: int, sender: string) -> bool`

Source: `scripts/player_inventory/inv_overhaul_inventory_controller.lua`

Purpose: Handles paging protocol message in the inventory controller subsystem.

Parameters:

- `message: int` — numeric engine/UI protocol message.
- `sender: string` — name of the UI form that emitted the message.

Returns:

- `boolean` — result of: handles paging protocol message in the inventory controller subsystem.

Side effects:

- Delegates to compiler-visible module APIs and inherits their documented side effects.

Called by:

- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: OnUIMessage`

Calls:

- `inv_overhaul_inventory_paging.CanMove`
- `PlayerControllerGetMaxPage`
- `ChangePage`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `HandleSlotPointerProtocolMessage(message: int, sender: string) -> bool`

Source: `scripts/player_inventory/inv_overhaul_inventory_controller.lua`

Purpose: Handles slot pointer protocol message in the inventory controller subsystem.

Parameters:

- `message: int` — numeric engine/UI protocol message.
- `sender: string` — name of the UI form that emitted the message.

Returns:

- `boolean` — result of: handles slot pointer protocol message in the inventory controller subsystem.

Side effects:

- Delegates to compiler-visible module APIs and inherits their documented side effects.

Called by:

- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: OnUIMessage`

Calls:

- `GetCurrentDropSlot`
- `ApplyPointerSlot`
- `FinishLeftAction`
- `inv_overhaul_inventory_drag.PlayerDragIsActive`
- `PlayerControllerGetSlotTargetFromPointerMessage`
- `inv_overhaul_inventory_drag.SetHoverTarget`
- `SetHighlightedSlot`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `PlayerControllerHandleDragLifecycleMessage(message: int, sender: string) -> bool`

Source: `scripts/player_inventory/inv_overhaul_inventory_controller.lua`

Purpose: Handles drag lifecycle message for player controller in the inventory controller subsystem.

Parameters:

- `message: int` — numeric engine/UI protocol message.
- `sender: string` — name of the UI form that emitted the message.

Returns:

- `boolean` — result of: handles drag lifecycle message for player controller in the inventory controller subsystem.

Side effects:

- Invokes engine/native operations: `native.Trace`.

Called by:

- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: OnUIMessage`

Calls:

- `GetDragSourceBySender`
- `PlayerControllerHandleModifiedDrop`
- `StartDragAction`
- `native.Trace`
- `inv_overhaul_inventory_drag.PlayerDragIsActive`
- `inv_overhaul_inventory_drag.SetHoverTarget`
- `SetHighlightedSlot`
- `FinishLeftAction`
- `ReadHighlightedSlot`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `PlayerControllerHandleRegularSlotMessage(message: int, sender: string, data: object) -> bool`

Source: `scripts/player_inventory/inv_overhaul_inventory_controller.lua`

Purpose: Handles regular slot message for player controller in the inventory controller subsystem.

Parameters:

- `message: int` — numeric engine/UI protocol message.
- `sender: string` — name of the UI form that emitted the message.
- `data: object` — engine callback/UI payload object; shape depends on the message.

Returns:

- `boolean` — result of: handles regular slot message for player controller in the inventory controller subsystem.

Side effects:

- None directly observable beyond calls listed below.

Called by:

- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: OnUIMessage`

Calls:

- `HandleSlotMessage`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `OnUIMessage(message: int, sender: string, data: object) -> void`

Source: `scripts/player_inventory/inv_overhaul_inventory_controller.lua`

Purpose: Handles the engine/UI `OnUIMessage` callback for the inventory controller runtime.

Parameters:

- `message: int` — numeric engine/UI protocol message.
- `sender: string` — name of the UI form that emitted the message.
- `data: object` — engine callback/UI payload object; shape depends on the message.

Returns:

None.

Side effects:

- None directly observable beyond calls listed below.

Called by:

- `scripts/player_inventory/inv_overhaul_inventory.lua :: OnUIMessage`

Calls:

- `HandleGlobalProtocolMessage`
- `HandleEquipmentProtocolMessage`
- `HandlePagingProtocolMessage`
- `HandleSlotPointerProtocolMessage`
- `PlayerControllerHandleDragLifecycleMessage`
- `PlayerControllerHandleRegularSlotMessage`

Notes / invariants:

- Callback recognition is name-based in `pathologic_lua_compiler`; `OnUIMessage` is an engine event name.

### `OnLButtonDown(x: int, y: int) -> void`

Source: `scripts/player_inventory/inv_overhaul_inventory_controller.lua`

Purpose: Handles the engine/UI `OnLButtonDown` callback for the inventory controller runtime.

Parameters:

- `x: int` — pointer/layout coordinate interpreted by this function.
- `y: int` — pointer/layout coordinate interpreted by this function.

Returns:

None.

Side effects:

- None directly observable beyond calls listed below.

Called by:

- `scripts/player_inventory/inv_overhaul_inventory.lua :: OnLButtonDown`

Calls:

- `HandlePageControlAt`
- `FindEquipmentTargetAt`
- `ResolveEquipmentTarget`
- `StartDragAction`

Notes / invariants:

- Callback recognition is name-based in `pathologic_lua_compiler`; `OnLButtonDown` is an engine event name.

### `OnRButtonDown(x: int, y: int) -> void`

Source: `scripts/player_inventory/inv_overhaul_inventory_controller.lua`

Purpose: Handles the engine/UI `OnRButtonDown` callback for the inventory controller runtime.

Parameters:

- `x: int` — pointer/layout coordinate interpreted by this function.
- `y: int` — pointer/layout coordinate interpreted by this function.

Returns:

None.

Side effects:

- None directly observable beyond calls listed below.

Called by:

- `scripts/player_inventory/inv_overhaul_inventory.lua :: OnRButtonDown`

Calls:

- `FindEquipmentTargetAt`
- `UnequipTarget`

Notes / invariants:

- Callback recognition is name-based in `pathologic_lua_compiler`; `OnRButtonDown` is an engine event name.

### `OnMouseMove(x: int, y: int) -> void`

Source: `scripts/player_inventory/inv_overhaul_inventory_controller.lua`

Purpose: Handles the engine/UI `OnMouseMove` callback for the inventory controller runtime.

Parameters:

- `x: int` — pointer/layout coordinate interpreted by this function.
- `y: int` — pointer/layout coordinate interpreted by this function.

Returns:

None.

Side effects:

- Delegates to compiler-visible module APIs and inherits their documented side effects.

Called by:

- `scripts/player_inventory/inv_overhaul_inventory.lua :: OnMouseMove`

Calls:

- `inv_overhaul_inventory_drag.PlayerDragIsActive`
- `UpdatePointerSlot`
- `ApplyPointerSlot`

Notes / invariants:

- Callback recognition is name-based in `pathologic_lua_compiler`; `OnMouseMove` is an engine event name.

### `OnMouseLeave() -> void`

Source: `scripts/player_inventory/inv_overhaul_inventory_controller.lua`

Purpose: Handles the engine/UI `OnMouseLeave` callback for the inventory controller runtime.

Parameters:

None.

Returns:

None.

Side effects:

- Delegates to compiler-visible module APIs and inherits their documented side effects.

Called by:

- `scripts/player_inventory/inv_overhaul_inventory.lua :: OnMouseLeave`

Calls:

- `inv_overhaul_inventory_drag.PlayerDragIsActive`
- `SetHighlightedSlot`

Notes / invariants:

- Callback recognition is name-based in `pathologic_lua_compiler`; `OnMouseLeave` is an engine event name.

### `OnLButtonUp(x: int, y: int) -> void`

Source: `scripts/player_inventory/inv_overhaul_inventory_controller.lua`

Purpose: Handles the engine/UI `OnLButtonUp` callback for the inventory controller runtime.

Parameters:

- `x: int` — pointer/layout coordinate interpreted by this function.
- `y: int` — pointer/layout coordinate interpreted by this function.

Returns:

None.

Side effects:

- Delegates to compiler-visible module APIs and inherits their documented side effects.

Called by:

- `scripts/player_inventory/inv_overhaul_inventory.lua :: OnLButtonUp`

Calls:

- `inv_overhaul_inventory_drag.PlayerDragIsActive`
- `UpdatePointerSlot`
- `ApplyPointerSlot`
- `FinishLeftAction`

Notes / invariants:

- Callback recognition is name-based in `pathologic_lua_compiler`; `OnLButtonUp` is an engine event name.

### `CloseInventoryWindow() -> void`

Source: `scripts/player_inventory/inv_overhaul_inventory_controller.lua`

Purpose: Closes inventory window in the inventory controller subsystem.

Parameters:

None.

Returns:

None.

Side effects:

- Mutates module/task state: `closingWindow`.
- Writes shared engine variable(s): `"inv_overhaul_inventory_drag_item"`, `"inv_overhaul_inventory_page_hover"`.
- Invokes engine/native operations: `native.SetNeedUpdate`, `native.SetVariable`, `native.SendMessage`, `native.DestroyWindow`.

Called by:

- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: OnChar`
- `scripts/player_inventory/inv_overhaul_inventory_controller.lua :: OnKeyDown`

Calls:

- `native.SetNeedUpdate`
- `native.SetVariable`
- `native.SendMessage`
- `native.DestroyWindow`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `OnChar(char: int) -> void`

Source: `scripts/player_inventory/inv_overhaul_inventory_controller.lua`

Purpose: Handles the engine/UI `OnChar` callback for the inventory controller runtime.

Parameters:

- `char: int` — value interpreted according to the function purpose; no narrower contract is established by current code.

Returns:

None.

Side effects:

- Invokes engine/native operations: `native.Trace`.

Called by:

- `scripts/player_inventory/inv_overhaul_inventory.lua :: OnChar`

Calls:

- `native.Trace`
- `inv_overhaul_inventory_layout_runtime.HasQueuedSave`
- `SaveLayoutVariables`
- `PersistCurrentBackpackSnapshot`
- `CloseInventoryWindow`

Notes / invariants:

- Callback recognition is name-based in `pathologic_lua_compiler`; `OnChar` is an engine event name.

### `OnKeyDown(key: int) -> void`

Source: `scripts/player_inventory/inv_overhaul_inventory_controller.lua`

Purpose: Handles the engine/UI `OnKeyDown` callback for the inventory controller runtime.

Parameters:

- `key: int` — value interpreted according to the function purpose; no narrower contract is established by current code.

Returns:

None.

Side effects:

- Mutates module/task state: `shiftHeld`, `controlHeld`.
- Invokes engine/native operations: `native.Trace`.

Called by:

- `scripts/player_inventory/inv_overhaul_inventory.lua :: OnKeyDown`

Calls:

- `native.Trace`
- `GetQuickslotByKey`
- `PlayerControllerAssignHoveredQuickslot`
- `inv_overhaul_inventory_layout_runtime.HasQueuedSave`
- `SaveLayoutVariables`
- `PersistCurrentBackpackSnapshot`
- `CloseInventoryWindow`

Notes / invariants:

- Callback recognition is name-based in `pathologic_lua_compiler`; `OnKeyDown` is an engine event name.

### `OnKeyUp(key: int) -> void`

Source: `scripts/player_inventory/inv_overhaul_inventory_controller.lua`

Purpose: Handles the engine/UI `OnKeyUp` callback for the inventory controller runtime.

Parameters:

- `key: int` — value interpreted according to the function purpose; no narrower contract is established by current code.

Returns:

None.

Side effects:

- Mutates module/task state: `shiftHeld`, `controlHeld`.

Called by:

- `scripts/player_inventory/inv_overhaul_inventory.lua :: OnKeyUp`

Notes / invariants:

- Callback recognition is name-based in `pathologic_lua_compiler`; `OnKeyUp` is an engine event name.


## Internal API

No additional maintask helpers.

## Events / callbacks

No engine callbacks; this is an imported module.

## Important constants

- `c_sScriptVersion: string = "2026.08.17-fast-open-generation-poll-1"` — schema/runtime version marker for script version.
- `c_iCWeapon: int = 0` — named behavior/layout value for cweapon.
- `c_iCClothes: int = 1` — named behavior/layout value for cclothes.
- `c_iCategoryCount: int = 5` — fixed limit/count for category count.
- `c_iInventoryCapacity: int = 56` — fixed limit/count for inventory capacity.
- `c_iLayoutVersion: int = 4` — schema/runtime version marker for layout version.
- `c_iVKShift: int = 16` — named behavior/layout value for vkshift.
- `c_iVKControl: int = 17` — named behavior/layout value for vkcontrol.
- `c_iQuickslotCount: int = 10` — fixed limit/count for quickslot count.
- `c_iQuickslotVersion: int = 1` — schema/runtime version marker for quickslot version.
- `c_iWMHelpMessage: int = 200` — numeric engine/UI protocol value for wmhelp message.
- `c_iInventoryFullTextID: int = 1400` — localized string identifier for inventory full.
- `c_iSlotSelected: int = 16384` — named behavior/layout value for slot selected.
- `c_iSlotEmpty: int = 32768` — named behavior/layout value for slot empty.
- `c_iSlotNumber: int = 65536` — named behavior/layout value for slot number.
- `c_iHoverMessageBase: int = 100000` — numeric engine/UI protocol value for hover message base.
- `c_iReleaseMessageBase: int = 200000` — numeric engine/UI protocol value for release message base.
- `c_iDragEndMessageBase: int = 300000` — numeric engine/UI protocol value for drag end message base.
- `c_iSlotHotZone: int = 52` — named behavior/layout value for slot hot zone.
- `c_iSlotDropInset: int = 1` — named behavior/layout value for slot drop inset.
- `c_iInitialSlotLoadBatch: int = 1` — named behavior/layout value for initial slot load batch.

## Architectural notes

- This compiler-visible module concentrates 142 functions spanning orchestration, rendering stages, input, drag/drop, paging, tooltips, quickslots, and persistence. The current decomposition lowers runtime callback complexity but leaves a broad change surface in one module.
- Many helpers are compiler-visible because the DSL has no private function keyword; intended public/internal boundaries are therefore conventional.
