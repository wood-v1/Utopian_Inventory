# Container Presenter

## Source

`scripts/loot/inv_overhaul_container_presenter.lua`

DSL unit: `module inv_overhaul_container_presenter`

## Responsibility

Projects session state into loot UI forms, including incremental item metadata/texture loading, money, organs, and page controls.

## Dependencies

- `inv_overhaul_inventory_sounds` — Plays feedback when the visible player or container page changes.

- `inv_overhaul_inventory_layout` — Defines the pure default mapping between backpack cells, linear slots, and pages.
- `inv_overhaul_inventory_layout_runtime` — Owns the mutable saved cell-to-item order, normalization, exact insertion/removal, swapping, and incremental persistence.
- `inv_overhaul_container_geometry` — Maps supported layouts to player, container, organ, money, paging, and pointer hit-test geometry.
- `inv_overhaul_container_projection` — Builds and queries the visible container/corpse item projection independently of the player backpack projection.
- `inv_overhaul_container_view` — Defines loot-screen window names and emits UI messages that render slots, organs, drag state, and page controls.
- `inv_overhaul_inventory_items` — Builds the canonical projection of unequipped player items into backpack ordinals and cached category/index references.
- `inv_overhaul_inventory_quickslot_bindings` — Owns saved quickslot item/category/occurrence bindings and the player-screen binding cache.
- Pathologic native API — engine state, object access, persistence variables, UI messaging, timing, or rendering as listed per function.

## Used by

- `scripts/loot/inv_overhaul_container.lua`
- `scripts/loot/inv_overhaul_container_bootstrap.lua`
- `scripts/loot/inv_overhaul_container_drag_controller.lua`
- `scripts/loot/inv_overhaul_container_input_controller.lua`
- `scripts/loot/inv_overhaul_container_paging_controller.lua`
- `scripts/loot/inv_overhaul_container_player_actions.lua`
- `scripts/loot/inv_overhaul_container_quick_transfer.lua`
- `scripts/loot/inv_overhaul_container_session.lua`
- `scripts/loot/inv_overhaul_container_transfer_external.lua`
- `scripts/loot/inv_overhaul_container_transfer_player.lua`

## State

- `windowWidth: int` — current or cached layout value for window width.
- `windowHeight: int` — current or cached layout value for window height.
- `visibleSlots: int` — current or cached layout value for visible slots.
- `playerPage: int` — current or cached paging state for player page.
- `containerPage: int` — current or cached paging state for container page.
- `renderedPlayerPage: int` — current or cached paging state for rendered player page.
- `renderedContainerPage: int` — current or cached paging state for rendered container page.
- `lastLayoutWidth: int` — current or cached layout value for last layout width.
- `lastLayoutHeight: int` — current or cached layout value for last layout height.
- `lastContainerMaxPage: int` — current or cached paging state for last container max page.
- `initialSlotLoadActive: bool` — current or cached layout value for initial slot load active.
- `initialPlayerSlotLoadNext: int` — current or cached layout value for initial player slot load next.
- `initialContainerSlotLoadNext: int` — current or cached layout value for initial container slot load next.
- `moneyPollCooldown: float` — timing state for money poll cooldown.
- `pendingPlayerEntryCategory: int` — deferred-work state for pending player entry category.
- `pendingPlayerEntryIndex: int` — deferred-work state for pending player entry index.
- `pendingPlayerEntryScanSlot: int` — deferred-work state for pending player entry scan slot.
- `isCorpse: bool` — lifecycle/behavior flag for is corpse.
- `showOrgans: bool` — lifecycle/behavior flag for show organs.

## Public API

All functions below are compiler-visible when the module is imported; the DSL has no private declaration.

### `LootPresenterInitializeState() -> void`

Source: `scripts/loot/inv_overhaul_container_presenter.lua`

Purpose: Initializes state for loot presenter in the container presenter subsystem.

Parameters:

None.

Returns:

None.

Side effects:

- Mutates module/task state: `windowWidth`, `windowHeight`, `visibleSlots`, `playerPage`, `containerPage`, `renderedPlayerPage`, `renderedContainerPage`, `lastLayoutWidth`, `… and 11 more`.

Called by:

- `scripts/loot/inv_overhaul_container.lua :: init`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `GetWindowWidth() -> int`

Source: `scripts/loot/inv_overhaul_container_presenter.lua`

Purpose: Returns window width in the container presenter subsystem.

Parameters:

None.

Returns:

- `number` (integer) — result of: returns window width in the container presenter subsystem.

Side effects:

- None directly observable beyond calls listed below.

Called by:

- `scripts/loot/inv_overhaul_container_drag_controller.lua :: LootDragControllerFindTargetAt`
- `scripts/loot/inv_overhaul_container_input_controller.lua :: LootInputHandlePanelPointer`
- `scripts/loot/inv_overhaul_container_input_controller.lua :: GetSlotPointerTarget`
- `scripts/loot/inv_overhaul_container_paging_controller.lua :: HandleControlAt`
- `scripts/loot/inv_overhaul_container_paging_controller.lua :: UpdateControlHover`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `GetWindowHeight() -> int`

Source: `scripts/loot/inv_overhaul_container_presenter.lua`

Purpose: Returns window height in the container presenter subsystem.

Parameters:

None.

Returns:

- `number` (integer) — result of: returns window height in the container presenter subsystem.

Side effects:

- None directly observable beyond calls listed below.

Called by:

- No in-repository caller was resolved; this may be an engine/XML callback or a conventionally public helper.

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `LootPresenterGetVisibleSlots() -> int`

Source: `scripts/loot/inv_overhaul_container_presenter.lua`

Purpose: Returns visible slots for loot presenter in the container presenter subsystem.

Parameters:

None.

Returns:

- `number` (integer) — result of: returns visible slots for loot presenter in the container presenter subsystem.

Side effects:

- None directly observable beyond calls listed below.

Called by:

- `scripts/loot/inv_overhaul_container_bootstrap.lua :: InitializePersistentPlayerSnapshot`
- `scripts/loot/inv_overhaul_container_bootstrap.lua :: LootBootstrapOrderFreeCellsByDisplay`
- `scripts/loot/inv_overhaul_container_drag_controller.lua :: LootDragControllerGetTargetBySender`
- `scripts/loot/inv_overhaul_container_drag_controller.lua :: LootDragControllerFindTargetAt`
- `scripts/loot/inv_overhaul_container_drag_controller.lua :: LootDragControllerIsTargetCompatible`
- `scripts/loot/inv_overhaul_container_drag_controller.lua :: ResolveSource`
- `scripts/loot/inv_overhaul_container_drag_controller.lua :: LootDragControllerSetHighlightedTarget`
- `scripts/loot/inv_overhaul_container_drag_controller.lua :: LootDragControllerApplyPointerTarget`
- `… and 9 more`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `GetPlayerPage() -> int`

Source: `scripts/loot/inv_overhaul_container_presenter.lua`

Purpose: Returns player page in the container presenter subsystem.

Parameters:

None.

Returns:

- `number` (integer) — result of: returns player page in the container presenter subsystem.

Side effects:

- None directly observable beyond calls listed below.

Called by:

- `scripts/loot/inv_overhaul_container_input_controller.lua :: LootInputHandlePanelPointer`
- `scripts/loot/inv_overhaul_container_input_controller.lua :: HandlePagingMessage`
- `scripts/loot/inv_overhaul_container_paging_controller.lua :: HandleControlAt`
- `scripts/loot/inv_overhaul_container_paging_controller.lua :: UpdateControlHover`
- `scripts/loot/inv_overhaul_container_paging_controller.lua :: GetDragHoverAction`
- `scripts/loot/inv_overhaul_container_paging_controller.lua :: UpdateDragHover`
- `scripts/loot/inv_overhaul_container_paging_controller.lua :: SyncDragHoverFromCursor`
- `scripts/loot/inv_overhaul_container_player_actions.lua :: LootPlayerActionsMoveSlotToOtherPage`
- `… and 2 more`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `GetContainerPage() -> int`

Source: `scripts/loot/inv_overhaul_container_presenter.lua`

Purpose: Returns container page in the container presenter subsystem.

Parameters:

None.

Returns:

- `number` (integer) — result of: returns container page in the container presenter subsystem.

Side effects:

- None directly observable beyond calls listed below.

Called by:

- `scripts/loot/inv_overhaul_container_drag_controller.lua :: ResolveSource`
- `scripts/loot/inv_overhaul_container_drag_controller.lua :: LootDragControllerApplyPointerTarget`
- `scripts/loot/inv_overhaul_container_drag_controller.lua :: Finish`
- `scripts/loot/inv_overhaul_container_input_controller.lua :: LootInputHandlePanelPointer`
- `scripts/loot/inv_overhaul_container_input_controller.lua :: HandlePagingMessage`
- `scripts/loot/inv_overhaul_container_paging_controller.lua :: HandleControlAt`
- `scripts/loot/inv_overhaul_container_paging_controller.lua :: UpdateControlHover`
- `scripts/loot/inv_overhaul_container_paging_controller.lua :: GetDragHoverAction`
- `… and 4 more`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `GetRenderedPlayerPage() -> int`

Source: `scripts/loot/inv_overhaul_container_presenter.lua`

Purpose: Returns rendered player page in the container presenter subsystem.

Parameters:

None.

Returns:

- `number` (integer) — result of: returns rendered player page in the container presenter subsystem.

Side effects:

- None directly observable beyond calls listed below.

Called by:

- `scripts/loot/inv_overhaul_container_transfer_external.lua :: MoveResolvedAmountToPlayer`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `GetRenderedContainerPage() -> int`

Source: `scripts/loot/inv_overhaul_container_presenter.lua`

Purpose: Returns rendered container page in the container presenter subsystem.

Parameters:

None.

Returns:

- `number` (integer) — result of: returns rendered container page in the container presenter subsystem.

Side effects:

- None directly observable beyond calls listed below.

Called by:

- No in-repository caller was resolved; this may be an engine/XML callback or a conventionally public helper.

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `LootPresenterIsCorpse() -> bool`

Source: `scripts/loot/inv_overhaul_container_presenter.lua`

Purpose: Returns whether corpse for loot presenter in the container presenter subsystem.

Parameters:

None.

Returns:

- `boolean` — result of: returns whether corpse for loot presenter in the container presenter subsystem.

Side effects:

- None directly observable beyond calls listed below.

Called by:

- No in-repository caller was resolved; this may be an engine/XML callback or a conventionally public helper.

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `LootPresenterShowsOrgans() -> bool`

Source: `scripts/loot/inv_overhaul_container_presenter.lua`

Purpose: Returns whether organs for loot presenter in the container presenter subsystem.

Parameters:

None.

Returns:

- `boolean` — result of: returns whether organs for loot presenter in the container presenter subsystem.

Side effects:

- None directly observable beyond calls listed below.

Called by:

- `scripts/loot/inv_overhaul_container_drag_controller.lua :: LootDragControllerFindTargetAt`
- `scripts/loot/inv_overhaul_container_input_controller.lua :: LootInputHandlePanelPointer`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `SetPlayerPage(page: int) -> void`

Source: `scripts/loot/inv_overhaul_container_presenter.lua`

Purpose: Sets player page in the container presenter subsystem.

Parameters:

- `page: int` — zero-based page or page-related value.

Returns:

None.

Side effects:

- Mutates module/task state: `playerPage`.

Called by:

- `scripts/loot/inv_overhaul_container_quick_transfer.lua :: Execute`
- `scripts/loot/inv_overhaul_container_transfer_external.lua :: MoveResolvedAmountToPlayer`

Calls:

- `ClampPlayerPage`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `SetContainerPage(page: int) -> void`

Source: `scripts/loot/inv_overhaul_container_presenter.lua`

Purpose: Sets container page in the container presenter subsystem.

Parameters:

- `page: int` — zero-based page or page-related value.

Returns:

None.

Side effects:

- Mutates module/task state: `containerPage`.

Called by:

- `scripts/loot/inv_overhaul_container_quick_transfer.lua :: Execute`
- `scripts/loot/inv_overhaul_container_transfer_player.lua :: MoveAmountToContainer`

Calls:

- `ClampContainerPage`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `SetCorpseMode(newIsCorpse: bool, newShowOrgans: bool) -> void`

Source: `scripts/loot/inv_overhaul_container_presenter.lua`

Purpose: Sets corpse mode in the container presenter subsystem.

Parameters:

- `newIsCorpse: bool` — behavior flag interpreted by this function.
- `newShowOrgans: bool` — behavior flag interpreted by this function.

Returns:

None.

Side effects:

- Mutates module/task state: `isCorpse`, `showOrgans`.

Called by:

- `scripts/loot/inv_overhaul_container_session.lua :: LootSessionInitializeState`
- `scripts/loot/inv_overhaul_container_session.lua :: ActivateCorpseMode`
- `scripts/loot/inv_overhaul_container_session.lua :: DetectContainerKind`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `LootPresenterUpdateLayout() -> void`

Source: `scripts/loot/inv_overhaul_container_presenter.lua`

Purpose: Updates layout for loot presenter in the container presenter subsystem.

Parameters:

None.

Returns:

None.

Side effects:

- Mutates module/task state: `lastLayoutWidth`, `lastLayoutHeight`, `windowWidth`, `windowHeight`, `visibleSlots`.
- Invokes engine/native operations: `native.SendMessage`.

Called by:

- `scripts/loot/inv_overhaul_container.lua :: init`
- `scripts/loot/inv_overhaul_container.lua :: OnUpdate`
- `scripts/loot/inv_overhaul_container_presenter.lua :: UpdateAllSlots`
- `scripts/loot/inv_overhaul_container_presenter.lua :: LootPresenterBeginInitialSlotLoad`

Calls:

- `native.GetWindowSize`
- `native.GetScreenSize`
- `inv_overhaul_container_geometry.LootGeometryGetVisibleSlots`
- `native.SendMessage`
- `inv_overhaul_container_view.LootViewConfigureSlotRenderSize`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `LootPresenterGetCellForLinearSlot(linear: int) -> int`

Source: `scripts/loot/inv_overhaul_container_presenter.lua`

Purpose: Returns cell for linear slot for loot presenter in the container presenter subsystem.

Parameters:

- `linear: int` — value interpreted according to the function purpose; no narrower contract is established by current code.

Returns:

- `number` (integer) — result of: returns cell for linear slot for loot presenter in the container presenter subsystem.

Side effects:

- Delegates to compiler-visible module APIs and inherits their documented side effects.

Called by:

- `scripts/loot/inv_overhaul_container_player_actions.lua :: LootPlayerActionsMoveSlotToOtherPage`
- `scripts/loot/inv_overhaul_container_presenter.lua :: LootPresenterGetVisibleCell`

Calls:

- `inv_overhaul_inventory_layout.LayoutGetCellForLinearSlot`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `LootPresenterGetVisibleCell(slot: int) -> int`

Source: `scripts/loot/inv_overhaul_container_presenter.lua`

Purpose: Returns visible cell for loot presenter in the container presenter subsystem.

Parameters:

- `slot: int` — slot index or encoded slot target interpreted by this function.

Returns:

- `number` (integer) — result of: returns visible cell for loot presenter in the container presenter subsystem.

Side effects:

- None directly observable beyond calls listed below.

Called by:

- `scripts/loot/inv_overhaul_container_drag_controller.lua :: ResolveSource`
- `scripts/loot/inv_overhaul_container_drag_controller.lua :: LootDragControllerApplyPointerTarget`
- `scripts/loot/inv_overhaul_container_drag_controller.lua :: Finish`
- `scripts/loot/inv_overhaul_container_player_actions.lua :: LootPlayerActionsSwapCells`
- `scripts/loot/inv_overhaul_container_player_actions.lua :: LootPlayerActionsMoveSlotToOtherPage`
- `scripts/loot/inv_overhaul_container_presenter.lua :: LootPresenterResolveVisibleSlot`
- `scripts/loot/inv_overhaul_container_presenter.lua :: ContinueCachedPlayerEntryRefresh`
- `scripts/loot/inv_overhaul_container_presenter.lua :: GetVisibleSlotForCell`
- `… and 2 more`

Calls:

- `LootPresenterGetCellForLinearSlot`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `GetMaxPlayerPage() -> int`

Source: `scripts/loot/inv_overhaul_container_presenter.lua`

Purpose: Returns max player page in the container presenter subsystem.

Parameters:

None.

Returns:

- `number` (integer) — result of: returns max player page in the container presenter subsystem.

Side effects:

- Delegates to compiler-visible module APIs and inherits their documented side effects.

Called by:

- `scripts/loot/inv_overhaul_container_input_controller.lua :: LootInputHandlePanelPointer`
- `scripts/loot/inv_overhaul_container_input_controller.lua :: HandlePagingMessage`
- `scripts/loot/inv_overhaul_container_paging_controller.lua :: HandleControlAt`
- `scripts/loot/inv_overhaul_container_paging_controller.lua :: UpdateControlHover`
- `scripts/loot/inv_overhaul_container_paging_controller.lua :: GetDragHoverAction`
- `scripts/loot/inv_overhaul_container_paging_controller.lua :: UpdateDragHover`
- `scripts/loot/inv_overhaul_container_paging_controller.lua :: SyncDragHoverFromCursor`
- `scripts/loot/inv_overhaul_container_player_actions.lua :: LootPlayerActionsMoveSlotToOtherPage`
- `… and 2 more`

Calls:

- `inv_overhaul_inventory_layout.LayoutGetMaxPage`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `ClampPlayerPage() -> void`

Source: `scripts/loot/inv_overhaul_container_presenter.lua`

Purpose: Clamps player page in the container presenter subsystem.

Parameters:

None.

Returns:

None.

Side effects:

- Mutates module/task state: `playerPage`.

Called by:

- `scripts/loot/inv_overhaul_container_presenter.lua :: SetPlayerPage`
- `scripts/loot/inv_overhaul_container_presenter.lua :: UpdatePlayerSlots`
- `scripts/loot/inv_overhaul_container_presenter.lua :: LootPresenterBeginInitialSlotLoad`
- `scripts/loot/inv_overhaul_container_presenter.lua :: ChangePlayerPage`

Calls:

- `GetMaxPlayerPage`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `LootPresenterResolveVisibleSlot(slot: int) -> int`

Source: `scripts/loot/inv_overhaul_container_presenter.lua`

Purpose: Resolves visible slot for loot presenter in the container presenter subsystem.

Parameters:

- `slot: int` — slot index or encoded slot target interpreted by this function.

Returns:

- `number` (integer) — result of: resolves visible slot for loot presenter in the container presenter subsystem.

Side effects:

- Delegates to compiler-visible module APIs and inherits their documented side effects.

Called by:

- `scripts/loot/inv_overhaul_container_drag_controller.lua :: ResolveSource`
- `scripts/loot/inv_overhaul_container_input_controller.lua :: LootInputAssignHoveredQuickslot`
- `scripts/loot/inv_overhaul_container_input_controller.lua :: LootInputHandleModifiedDrop`
- `scripts/loot/inv_overhaul_container_player_actions.lua :: DropToWorld`
- `scripts/loot/inv_overhaul_container_presenter.lua :: UpdatePlayerSlot`
- `scripts/loot/inv_overhaul_container_quick_transfer.lua :: Execute`
- `scripts/loot/inv_overhaul_container_transfer_player.lua :: MoveAmountToContainer`
- `scripts/loot/inv_overhaul_container_transfer_player.lua :: ExchangeWithContainer`

Calls:

- `inv_overhaul_inventory_layout_runtime.LayoutRuntimeGetOrderValue`
- `LootPresenterGetVisibleCell`
- `inv_overhaul_inventory_items.ResolveCachedOrdinal`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `QueueCachedPlayerEntryRefresh(category: int, index: int) -> void`

Source: `scripts/loot/inv_overhaul_container_presenter.lua`

Purpose: Queues cached player entry refresh in the container presenter subsystem.

Parameters:

- `category: int` — zero-based engine inventory category identifier.
- `index: int` — zero-based entry index in the relevant engine container/category.

Returns:

None.

Side effects:

- Mutates module/task state: `pendingPlayerEntryCategory`, `pendingPlayerEntryIndex`, `pendingPlayerEntryScanSlot`.

Called by:

- `scripts/loot/inv_overhaul_container_transfer_external.lua :: MoveResolvedAmountToPlayer`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `ContinueCachedPlayerEntryRefresh() -> void`

Source: `scripts/loot/inv_overhaul_container_presenter.lua`

Purpose: Continues cached player entry refresh in the container presenter subsystem.

Parameters:

None.

Returns:

None.

Side effects:

- Mutates module/task state: `pendingPlayerEntryCategory`, `pendingPlayerEntryIndex`, `pendingPlayerEntryScanSlot`.

Called by:

- `scripts/loot/inv_overhaul_container.lua :: OnUpdate`

Calls:

- `UpdatePlayerPageControls`
- `inv_overhaul_inventory_layout_runtime.LayoutRuntimeGetOrderValue`
- `LootPresenterGetVisibleCell`
- `inv_overhaul_inventory_items.GetCachedBackpackCount`
- `inv_overhaul_inventory_items.ItemsGetCachedCategory`
- `inv_overhaul_inventory_items.ItemsGetCachedIndex`
- `UpdatePlayerSlot`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `GetVisibleSlotForCell(cell: int) -> int`

Source: `scripts/loot/inv_overhaul_container_presenter.lua`

Purpose: Returns visible slot for cell in the container presenter subsystem.

Parameters:

- `cell: int` — zero-based backpack layout cell.

Returns:

- `number` (integer) — result of: returns visible slot for cell in the container presenter subsystem.

Side effects:

- None directly observable beyond calls listed below.

Called by:

- `scripts/loot/inv_overhaul_container_transfer_player.lua :: MoveAmountToContainer`

Calls:

- `LootPresenterGetVisibleCell`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `GetNormalContainerItemCount() -> int`

Source: `scripts/loot/inv_overhaul_container_presenter.lua`

Purpose: Returns normal container item count in the container presenter subsystem.

Parameters:

None.

Returns:

- `number` (integer) — result of: returns normal container item count in the container presenter subsystem.

Side effects:

- Delegates to compiler-visible module APIs and inherits their documented side effects.

Called by:

- `scripts/loot/inv_overhaul_container_quick_transfer.lua :: Execute`
- `scripts/loot/inv_overhaul_container_transfer_external.lua :: MoveResolvedAmountToPlayer`
- `scripts/loot/inv_overhaul_container_transfer_player.lua :: MoveAmountToContainer`

Calls:

- `native.GetContainer`
- `inv_overhaul_container_projection.GetNormalItemCount`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `BuildContainerIndexCache() -> void`

Source: `scripts/loot/inv_overhaul_container_presenter.lua`

Purpose: Builds container index cache in the container presenter subsystem.

Parameters:

None.

Returns:

None.

Side effects:

- Delegates to compiler-visible module APIs and inherits their documented side effects.

Called by:

- `scripts/loot/inv_overhaul_container_presenter.lua :: UpdateContainerSlots`
- `scripts/loot/inv_overhaul_container_presenter.lua :: RefreshVisibleContainerItem`
- `scripts/loot/inv_overhaul_container_presenter.lua :: LootPresenterBeginInitialSlotLoad`
- `scripts/loot/inv_overhaul_container_transfer_player.lua :: ExchangeWithContainer`

Calls:

- `native.GetContainer`
- `inv_overhaul_container_projection.LootProjectionBuildIndexCache`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `ResolveContainerVisualSlot(slot: int) -> int`

Source: `scripts/loot/inv_overhaul_container_presenter.lua`

Purpose: Resolves container visual slot in the container presenter subsystem.

Parameters:

- `slot: int` — slot index or encoded slot target interpreted by this function.

Returns:

- `number` (integer) — result of: resolves container visual slot in the container presenter subsystem.

Side effects:

- Delegates to compiler-visible module APIs and inherits their documented side effects.

Called by:

- `scripts/loot/inv_overhaul_container_drag_controller.lua :: ResolveSource`
- `scripts/loot/inv_overhaul_container_presenter.lua :: UpdateContainerSlot`
- `scripts/loot/inv_overhaul_container_presenter.lua :: RefreshVisibleContainerItem`
- `scripts/loot/inv_overhaul_container_transfer_external.lua :: MoveAmountToPlayer`
- `scripts/loot/inv_overhaul_container_transfer_player.lua :: ExchangeWithContainer`

Calls:

- `inv_overhaul_container_projection.GetContainerOrder`
- `inv_overhaul_container_projection.ResolveNormalOrdinal`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `ResolveOrganVisualSlot(slot: int) -> int`

Source: `scripts/loot/inv_overhaul_container_presenter.lua`

Purpose: Resolves organ visual slot in the container presenter subsystem.

Parameters:

- `slot: int` — slot index or encoded slot target interpreted by this function.

Returns:

- `number` (integer) — result of: resolves organ visual slot in the container presenter subsystem.

Side effects:

- Delegates to compiler-visible module APIs and inherits their documented side effects.

Called by:

- `scripts/loot/inv_overhaul_container_drag_controller.lua :: ResolveSource`
- `scripts/loot/inv_overhaul_container_presenter.lua :: UpdateOrganSlots`
- `scripts/loot/inv_overhaul_container_transfer_external.lua :: MoveAmountToPlayer`

Calls:

- `native.GetContainer`
- `inv_overhaul_container_projection.ResolveOrganVisual`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `ClampContainerPage() -> void`

Source: `scripts/loot/inv_overhaul_container_presenter.lua`

Purpose: Clamps container page in the container presenter subsystem.

Parameters:

None.

Returns:

None.

Side effects:

- Mutates module/task state: `containerPage`.

Called by:

- `scripts/loot/inv_overhaul_container_presenter.lua :: SetContainerPage`
- `scripts/loot/inv_overhaul_container_presenter.lua :: UpdateContainerSlots`
- `scripts/loot/inv_overhaul_container_presenter.lua :: LootPresenterBeginInitialSlotLoad`
- `scripts/loot/inv_overhaul_container_presenter.lua :: ChangeContainerPage`

Calls:

- `inv_overhaul_container_projection.LootProjectionGetMaxPage`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `UpdatePlayerPageControls() -> void`

Source: `scripts/loot/inv_overhaul_container_presenter.lua`

Purpose: Updates player page controls in the container presenter subsystem.

Parameters:

None.

Returns:

None.

Side effects:

- Delegates to compiler-visible module APIs and inherits their documented side effects.

Called by:

- `scripts/loot/inv_overhaul_container.lua :: init`
- `scripts/loot/inv_overhaul_container_presenter.lua :: ContinueCachedPlayerEntryRefresh`
- `scripts/loot/inv_overhaul_container_presenter.lua :: UpdatePlayerSlots`
- `scripts/loot/inv_overhaul_container_presenter.lua :: LootPresenterBeginInitialSlotLoad`
- `scripts/loot/inv_overhaul_container_transfer_external.lua :: MoveResolvedAmountToPlayer`
- `scripts/loot/inv_overhaul_container_transfer_player.lua :: MoveAmountToContainer`

Calls:

- `GetMaxPlayerPage`
- `inv_overhaul_container_view.ResetPageControls`
- `inv_overhaul_container_view.LootViewUpdatePageControls`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `UpdateContainerPageControls() -> void`

Source: `scripts/loot/inv_overhaul_container_presenter.lua`

Purpose: Updates container page controls in the container presenter subsystem.

Parameters:

None.

Returns:

None.

Side effects:

- Mutates module/task state: `lastContainerMaxPage`.
- Invokes engine/native operations: `native.Trace`.

Called by:

- `scripts/loot/inv_overhaul_container.lua :: init`
- `scripts/loot/inv_overhaul_container_presenter.lua :: UpdateContainerSlots`
- `scripts/loot/inv_overhaul_container_presenter.lua :: RefreshVisibleContainerItem`
- `scripts/loot/inv_overhaul_container_presenter.lua :: LootPresenterBeginInitialSlotLoad`

Calls:

- `inv_overhaul_container_projection.LootProjectionGetMaxPage`
- `inv_overhaul_container_view.ResetPageControls`
- `native.Trace`
- `inv_overhaul_container_projection.GetCachedNormalCount`
- `inv_overhaul_container_view.LootViewUpdatePageControls`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `LootPresenterUpdateMoney() -> void`

Source: `scripts/loot/inv_overhaul_container_presenter.lua`

Purpose: Updates money for loot presenter in the container presenter subsystem.

Parameters:

None.

Returns:

None.

Side effects:

- Invokes engine/native operations: `native.SendMessage`.

Called by:

- `scripts/loot/inv_overhaul_container_presenter.lua :: UpdateAllSlots`
- `scripts/loot/inv_overhaul_container_presenter.lua :: LootPresenterBeginInitialSlotLoad`
- `scripts/loot/inv_overhaul_container_presenter.lua :: AdvanceMoneyPolling`
- `scripts/loot/inv_overhaul_container_transfer_external.lua :: MoveResolvedAmountToPlayer`
- `scripts/loot/inv_overhaul_container_transfer_player.lua :: MoveAmountToContainer`

Calls:

- `inv_overhaul_inventory_items.ItemsGetPlayerContainer`
- `player.GetProperty`
- `native.SendMessage`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `UpdatePlayerSlot(slot: int) -> void`

Source: `scripts/loot/inv_overhaul_container_presenter.lua`

Purpose: Updates player slot in the container presenter subsystem.

Parameters:

- `slot: int` — slot index or encoded slot target interpreted by this function.

Returns:

None.

Side effects:

- Delegates to compiler-visible module APIs and inherits their documented side effects.

Called by:

- `scripts/loot/inv_overhaul_container_player_actions.lua :: LootPlayerActionsSwapCells`
- `scripts/loot/inv_overhaul_container_presenter.lua :: ContinueCachedPlayerEntryRefresh`
- `scripts/loot/inv_overhaul_container_presenter.lua :: UpdatePlayerSlots`
- `scripts/loot/inv_overhaul_container_presenter.lua :: LootPresenterContinueInitialSlotLoad`
- `scripts/loot/inv_overhaul_container_transfer_external.lua :: MoveResolvedAmountToPlayer`
- `scripts/loot/inv_overhaul_container_transfer_player.lua :: MoveAmountToContainer`

Calls:

- `inv_overhaul_inventory_items.ItemsGetPlayerContainer`
- `inv_overhaul_container_view.GetPlayerSlotWndName`
- `LootPresenterGetVisibleCell`
- `inv_overhaul_container_view.RenderPlayerSlotUnavailable`
- `inv_overhaul_container_view.BeginPlayerSlot`
- `LootPresenterResolveVisibleSlot`
- `inv_overhaul_container_view.RenderPlayerSlotEmpty`
- `inv_overhaul_inventory_items.DecodeReferenceCategory`
- `inv_overhaul_inventory_items.DecodeReferenceIndex`
- `player.GetItem`
- `player.GetItemAmount`
- `inv_overhaul_container_view.RenderPlayerSlotItem`
- `… and 3 more`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `UpdatePlayerSlots() -> void`

Source: `scripts/loot/inv_overhaul_container_presenter.lua`

Purpose: Updates player slots in the container presenter subsystem.

Parameters:

None.

Returns:

None.

Side effects:

- Mutates module/task state: `renderedPlayerPage`.

Called by:

- `scripts/loot/inv_overhaul_container_input_controller.lua :: LootInputAssignHoveredQuickslot`
- `scripts/loot/inv_overhaul_container_presenter.lua :: UpdateAllSlots`
- `scripts/loot/inv_overhaul_container_presenter.lua :: ChangePlayerPage`
- `scripts/loot/inv_overhaul_container_transfer_external.lua :: MoveResolvedAmountToPlayer`

Calls:

- `ClampPlayerPage`
- `inv_overhaul_inventory_items.ItemsBuildIndexCache`
- `UpdatePlayerSlot`
- `UpdatePlayerPageControls`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `UpdateContainerSlot(slot: int) -> void`

Source: `scripts/loot/inv_overhaul_container_presenter.lua`

Purpose: Updates container slot in the container presenter subsystem.

Parameters:

- `slot: int` — slot index or encoded slot target interpreted by this function.

Returns:

None.

Side effects:

- Delegates to compiler-visible module APIs and inherits their documented side effects.

Called by:

- `scripts/loot/inv_overhaul_container_presenter.lua :: UpdateContainerSlots`
- `scripts/loot/inv_overhaul_container_presenter.lua :: RefreshVisibleContainerItem`
- `scripts/loot/inv_overhaul_container_presenter.lua :: LootPresenterContinueInitialSlotLoad`

Calls:

- `native.GetContainer`
- `inv_overhaul_container_view.GetContainerSlotWndName`
- `ResolveContainerVisualSlot`
- `inv_overhaul_container_view.RenderContainerSlotEmpty`
- `inv_overhaul_container_projection.GetReferenceIndex`
- `container.GetItem`
- `container.GetItemAmount`
- `inv_overhaul_container_view.RenderContainerSlotItem`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `UpdateContainerSlots() -> void`

Source: `scripts/loot/inv_overhaul_container_presenter.lua`

Purpose: Updates container slots in the container presenter subsystem.

Parameters:

None.

Returns:

None.

Side effects:

- Mutates module/task state: `renderedContainerPage`.

Called by:

- `scripts/loot/inv_overhaul_container_drag_controller.lua :: Finish`
- `scripts/loot/inv_overhaul_container_presenter.lua :: UpdateAllSlots`
- `scripts/loot/inv_overhaul_container_presenter.lua :: RefreshVisibleContainerItem`
- `scripts/loot/inv_overhaul_container_presenter.lua :: ChangeContainerPage`
- `scripts/loot/inv_overhaul_container_session.lua :: ActivateCorpseMode`
- `scripts/loot/inv_overhaul_container_session.lua :: LootSessionAdvance`
- `scripts/loot/inv_overhaul_container_transfer_player.lua :: ExchangeWithContainer`

Calls:

- `BuildContainerIndexCache`
- `ClampContainerPage`
- `UpdateContainerSlot`
- `UpdateContainerPageControls`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `UpdateOrganSlots() -> void`

Source: `scripts/loot/inv_overhaul_container_presenter.lua`

Purpose: Updates organ slots in the container presenter subsystem.

Parameters:

None.

Returns:

None.

Side effects:

- Delegates to compiler-visible module APIs and inherits their documented side effects.

Called by:

- `scripts/loot/inv_overhaul_container_presenter.lua :: UpdateAllSlots`
- `scripts/loot/inv_overhaul_container_presenter.lua :: LootPresenterBeginInitialSlotLoad`
- `scripts/loot/inv_overhaul_container_session.lua :: ActivateCorpseMode`
- `scripts/loot/inv_overhaul_container_session.lua :: LootSessionAdvance`
- `scripts/loot/inv_overhaul_container_transfer_external.lua :: MoveResolvedAmountToPlayer`

Calls:

- `native.GetContainer`
- `inv_overhaul_container_view.GetOrganSlotWndName`
- `inv_overhaul_container_view.RenderOrganSlotHidden`
- `inv_overhaul_container_view.BeginOrganSlot`
- `ResolveOrganVisualSlot`
- `inv_overhaul_container_view.RenderOrganSlotEmpty`
- `inv_overhaul_container_projection.GetReferenceIndex`
- `inv_overhaul_container_view.BeginOrganSlotItem`
- `container.GetItem`
- `container.GetItemAmount`
- `inv_overhaul_container_view.RenderOrganSlotItem`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `UpdateAllSlots() -> void`

Source: `scripts/loot/inv_overhaul_container_presenter.lua`

Purpose: Updates all slots in the container presenter subsystem.

Parameters:

None.

Returns:

None.

Side effects:

- Mutates module/task state: `initialSlotLoadActive`.

Called by:

- `scripts/loot/inv_overhaul_container_player_actions.lua :: DropToWorld`

Calls:

- `LootPresenterUpdateLayout`
- `UpdatePlayerSlots`
- `UpdateContainerSlots`
- `UpdateOrganSlots`
- `LootPresenterUpdateMoney`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `RefreshVisibleContainerItem(itemID: int, fallbackSlot: int) -> void`

Source: `scripts/loot/inv_overhaul_container_presenter.lua`

Purpose: Refreshes visible container item in the container presenter subsystem.

Parameters:

- `itemID: int` — engine item or callback identifier interpreted by this function.
- `fallbackSlot: int` — slot index or encoded slot target interpreted by this function.

Returns:

None.

Side effects:

- Mutates module/task state: `initialSlotLoadActive`.

Called by:

- `scripts/loot/inv_overhaul_container_transfer_external.lua :: MoveResolvedAmountToPlayer`
- `scripts/loot/inv_overhaul_container_transfer_player.lua :: MoveAmountToContainer`

Calls:

- `UpdateContainerSlots`
- `BuildContainerIndexCache`
- `ResolveContainerVisualSlot`
- `inv_overhaul_container_projection.GetReferenceIndex`
- `native.GetContainer`
- `external.GetItem`
- `item.GetItemID`
- `UpdateContainerSlot`
- `UpdateContainerPageControls`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `LootPresenterBeginInitialSlotLoad() -> void`

Source: `scripts/loot/inv_overhaul_container_presenter.lua`

Purpose: Begins initial slot load for loot presenter in the container presenter subsystem.

Parameters:

None.

Returns:

None.

Side effects:

- Mutates module/task state: `initialPlayerSlotLoadNext`, `initialContainerSlotLoadNext`, `initialSlotLoadActive`.
- Invokes engine/native operations: `native.Trace`.

Called by:

- `scripts/loot/inv_overhaul_container_bootstrap.lua :: LootBootstrapAdvance`

Calls:

- `LootPresenterUpdateLayout`
- `ClampPlayerPage`
- `inv_overhaul_inventory_items.ItemsBuildIndexCache`
- `BuildContainerIndexCache`
- `ClampContainerPage`
- `UpdatePlayerPageControls`
- `UpdateContainerPageControls`
- `UpdateOrganSlots`
- `LootPresenterUpdateMoney`
- `native.Trace`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `LootPresenterContinueInitialSlotLoad() -> void`

Source: `scripts/loot/inv_overhaul_container_presenter.lua`

Purpose: Continues initial slot load for loot presenter in the container presenter subsystem.

Parameters:

None.

Returns:

None.

Side effects:

- Mutates module/task state: `initialContainerSlotLoadNext`, `initialPlayerSlotLoadNext`, `initialSlotLoadActive`.
- Invokes engine/native operations: `native.Trace`.

Called by:

- `scripts/loot/inv_overhaul_container.lua :: OnUpdate`

Calls:

- `UpdateContainerSlot`
- `UpdatePlayerSlot`
- `native.Trace`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `AdvanceMoneyPolling(delta: float) -> void`

Source: `scripts/loot/inv_overhaul_container_presenter.lua`

Purpose: Advances money polling in the container presenter subsystem.

Parameters:

- `delta: float` — elapsed update time in seconds.

Returns:

None.

Side effects:

- Mutates module/task state: `moneyPollCooldown`.

Called by:

- `scripts/loot/inv_overhaul_container.lua :: OnUpdate`

Calls:

- `LootPresenterUpdateMoney`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `ChangePlayerPage(delta: int) -> void`

Source: `scripts/loot/inv_overhaul_container_presenter.lua`

Purpose: Changes player page in the container presenter subsystem.

Parameters:

- `delta: int` — elapsed update time in seconds.

Returns:

None.

Side effects:

- Mutates module/task state: `playerPage`.

Called by:

- `scripts/loot/inv_overhaul_container_input_controller.lua :: HandlePagingMessage`
- `scripts/loot/inv_overhaul_container_paging_controller.lua :: HandleControlAt`
- `scripts/loot/inv_overhaul_container_paging_controller.lua :: UpdateDragHover`

Calls:

- `ClampPlayerPage`
- `UpdatePlayerSlots`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `ChangeContainerPage(delta: int) -> void`

Source: `scripts/loot/inv_overhaul_container_presenter.lua`

Purpose: Changes container page in the container presenter subsystem.

Parameters:

- `delta: int` — elapsed update time in seconds.

Returns:

None.

Side effects:

- Mutates module/task state: `containerPage`.

Called by:

- `scripts/loot/inv_overhaul_container_input_controller.lua :: HandlePagingMessage`
- `scripts/loot/inv_overhaul_container_paging_controller.lua :: HandleControlAt`
- `scripts/loot/inv_overhaul_container_paging_controller.lua :: UpdateDragHover`

Calls:

- `ClampContainerPage`
- `UpdateContainerSlots`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.


## Internal API

No additional maintask helpers.

## Events / callbacks

No engine callbacks; this is an imported module.

## Important constants

- `InventoryCapacity: int = 56` — fixed limit/count for inventory capacity.
- `ContainerSlots: int = 12` — named behavior/layout value for container slots.
- `OrganSlots: int = 4` — named behavior/layout value for organ slots.
- `InitialSlotLoadBatch: int = 1` — named behavior/layout value for initial slot load batch.

## Architectural notes

- Presentation, incremental resource loading, metadata completion, money polling, organs, and page-control rendering share one module and several timing states.
