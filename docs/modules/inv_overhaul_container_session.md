# Container Session

## Source

`scripts/loot/inv_overhaul_container_session.lua`

DSL unit: `module inv_overhaul_container_session`

## Responsibility

Owns the active external container object, container/corpse kind, generation tracking, and close lifecycle.

## Dependencies

- `inv_overhaul_container_presenter` — Projects session state into loot UI forms, including incremental item metadata/texture loading, money, organs, and page controls.
- Pathologic native API — engine state, object access, persistence variables, UI messaging, timing, or rendering as listed per function.

## Used by

- `scripts/loot/inv_overhaul_container.lua`
- `scripts/loot/inv_overhaul_container_feedback.lua`
- `scripts/loot/inv_overhaul_container_input_controller.lua`

## State

- `isCorpse: bool` — lifecycle/behavior flag for is corpse.
- `showOrgans: bool` — lifecycle/behavior flag for show organs.
- `corpseVisualPending: bool` — deferred-work state for corpse visual pending.
- `organVisibilityRefresh: float` — mutable runtime state for organ visibility refresh.
- `deferredContainerRefresh: float` — mutable runtime state for deferred container refresh.

## Public API

All functions below are compiler-visible when the module is imported; the DSL has no private declaration.

### `LootSessionInitializeState() -> void`

Source: `scripts/loot/inv_overhaul_container_session.lua`

Purpose: Initializes state for loot session in the container session subsystem.

Parameters:

None.

Returns:

None.

Side effects:

- Mutates module/task state: `isCorpse`, `showOrgans`, `corpseVisualPending`, `organVisibilityRefresh`, `deferredContainerRefresh`.

Called by:

- `scripts/loot/inv_overhaul_container.lua :: init`

Calls:

- `inv_overhaul_container_presenter.SetCorpseMode`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `LootSessionIsCorpse() -> bool`

Source: `scripts/loot/inv_overhaul_container_session.lua`

Purpose: Returns whether corpse for loot session in the container session subsystem.

Parameters:

None.

Returns:

- `boolean` — result of: returns whether corpse for loot session in the container session subsystem.

Side effects:

- None directly observable beyond calls listed below.

Called by:

- `scripts/loot/inv_overhaul_container_feedback.lua :: ShowContainerFull`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `LootSessionShowsOrgans() -> bool`

Source: `scripts/loot/inv_overhaul_container_session.lua`

Purpose: Returns whether organs for loot session in the container session subsystem.

Parameters:

None.

Returns:

- `boolean` — result of: returns whether organs for loot session in the container session subsystem.

Side effects:

- None directly observable beyond calls listed below.

Called by:

- No in-repository caller was resolved; this may be an engine/XML callback or a conventionally public helper.

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `ActivateCorpseMode() -> void`

Source: `scripts/loot/inv_overhaul_container_session.lua`

Purpose: Activates corpse mode in the container session subsystem.

Parameters:

None.

Returns:

None.

Side effects:

- Mutates module/task state: `isCorpse`, `corpseVisualPending`, `organVisibilityRefresh`, `showOrgans`, `deferredContainerRefresh`.
- Invokes engine/native operations: `native.Trace`, `native.SendMessage`.

Called by:

- `scripts/loot/inv_overhaul_container_input_controller.lua :: HandleLifecycleMessage`
- `scripts/loot/inv_overhaul_container_session.lua :: DetectContainerKind`

Calls:

- `native.GetVariable`
- `inv_overhaul_container_presenter.SetCorpseMode`
- `native.Trace`
- `native.SendMessage`
- `inv_overhaul_container_presenter.UpdateContainerSlots`
- `inv_overhaul_container_presenter.UpdateOrganSlots`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `DetectContainerKind() -> void`

Source: `scripts/loot/inv_overhaul_container_session.lua`

Purpose: Detects container kind in the container session subsystem.

Parameters:

None.

Returns:

None.

Side effects:

- Mutates module/task state: `isCorpse`, `showOrgans`.
- Invokes engine/native operations: `native.IsCorpseContainer`, `native.Trace`.

Called by:

- `scripts/loot/inv_overhaul_container.lua :: init`

Calls:

- `inv_overhaul_container_presenter.SetCorpseMode`
- `native.GetContainer`
- `native.IsCorpseContainer`
- `native.Trace`
- `ActivateCorpseMode`
- `external.GetItemCount`
- `external.GetItem`
- `item.HasProperty`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `LootSessionAdvance(delta: float) -> void`

Source: `scripts/loot/inv_overhaul_container_session.lua`

Purpose: Advances loot session in the container session subsystem.

Parameters:

- `delta: float` — elapsed update time in seconds.

Returns:

None.

Side effects:

- Mutates module/task state: `organVisibilityRefresh`, `corpseVisualPending`, `deferredContainerRefresh`.
- Invokes engine/native operations: `native.SendMessage`.

Called by:

- `scripts/loot/inv_overhaul_container.lua :: OnUpdate`

Calls:

- `inv_overhaul_container_presenter.UpdateOrganSlots`
- `native.SendMessage`
- `inv_overhaul_container_presenter.UpdateContainerSlots`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `CloseWindow() -> void`

Source: `scripts/loot/inv_overhaul_container_session.lua`

Purpose: Closes window in the container session subsystem.

Parameters:

None.

Returns:

None.

Side effects:

- Invokes the engine/native `native.DestroyWindow` operation.

Called by:

- `scripts/loot/inv_overhaul_container_input_controller.lua :: PersistAndClose`

Calls:

- `native.DestroyWindow`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.
- The current form owns only the `inv_overhaul_inventory` cursor. Window
  destruction restores the underlying UI cursor; selecting an undeclared
  `default` cursor before destruction causes an engine lookup error.


## Internal API

No additional maintask helpers.

## Events / callbacks

No engine callbacks; this is an imported module.

## Important constants

- `BranchBurah: int = 1` — named behavior/layout value for branch burah.

## Architectural notes

- No additional module-specific issue identified beyond repository-wide shared-variable and compiler-visible API constraints.
