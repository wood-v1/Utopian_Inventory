# Container Feedback

## Source

`scripts/loot/inv_overhaul_container_feedback.lua`

DSL unit: `module inv_overhaul_container_feedback`

## Responsibility

Owns transient loot-screen message cooldown and localized feedback publication.

## Dependencies

- `inv_overhaul_container_session` — Owns the active external container object, container/corpse kind, generation tracking, and close lifecycle.
- Pathologic native API — engine state, object access, persistence variables, UI messaging, timing, or rendering as listed per function.

## Used by

- `scripts/loot/inv_overhaul_container.lua`
- `scripts/loot/inv_overhaul_container_player_actions.lua`
- `scripts/loot/inv_overhaul_container_quick_transfer.lua`
- `scripts/loot/inv_overhaul_container_transfer_external.lua`
- `scripts/loot/inv_overhaul_container_transfer_player.lua`

## State

- `messageCooldown: float` — timing state for message cooldown.

## Public API

All functions below are compiler-visible when the module is imported; the DSL has no private declaration.

### `LootFeedbackInitializeState() -> void`

Source: `scripts/loot/inv_overhaul_container_feedback.lua`

Purpose: Initializes state for loot feedback in the container feedback subsystem.

Parameters:

None.

Returns:

None.

Side effects:

- Mutates module/task state: `messageCooldown`.

Called by:

- `scripts/loot/inv_overhaul_container.lua :: init`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `LootFeedbackShowInventoryFull() -> void`

Source: `scripts/loot/inv_overhaul_container_feedback.lua`

Purpose: Shows inventory full for loot feedback in the container feedback subsystem.

Parameters:

None.

Returns:

None.

Side effects:

- Mutates module/task state: `messageCooldown`.
- Invokes engine/native operations: `native.CreateIntVector`, `native.SendWorldWndMessage`.
- May mutate engine/UI objects through: `text.add`.

Called by:

- `scripts/loot/inv_overhaul_container_player_actions.lua :: LootPlayerActionsMoveSlotToOtherPage`
- `scripts/loot/inv_overhaul_container_transfer_external.lua :: MoveResolvedAmountToPlayer`
- `scripts/loot/inv_overhaul_container_transfer_player.lua :: ExchangeWithContainer`

Calls:

- `native.CreateIntVector`
- `text.add`
- `native.SendWorldWndMessage`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `ShowContainerFull() -> void`

Source: `scripts/loot/inv_overhaul_container_feedback.lua`

Purpose: Shows container full in the container feedback subsystem.

Parameters:

None.

Returns:

None.

Side effects:

- Mutates module/task state: `messageCooldown`.
- Invokes engine/native operations: `native.CreateIntVector`, `native.SendWorldWndMessage`.
- May mutate engine/UI objects through: `text.add`.

Called by:

- `scripts/loot/inv_overhaul_container_quick_transfer.lua :: Execute`
- `scripts/loot/inv_overhaul_container_transfer_player.lua :: MoveAmountToContainer`

Calls:

- `native.CreateIntVector`
- `inv_overhaul_container_session.LootSessionIsCorpse`
- `text.add`
- `native.SendWorldWndMessage`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `LootFeedbackAdvance(delta: float) -> void`

Source: `scripts/loot/inv_overhaul_container_feedback.lua`

Purpose: Advances loot feedback in the container feedback subsystem.

Parameters:

- `delta: float` — elapsed update time in seconds.

Returns:

None.

Side effects:

- Mutates module/task state: `messageCooldown`.

Called by:

- `scripts/loot/inv_overhaul_container.lua :: OnUpdate`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.


## Internal API

No additional maintask helpers.

## Events / callbacks

No engine callbacks; this is an imported module.

## Important constants

- `HelpMessage: int = 200` — numeric engine/UI protocol value for help message.
- `InventoryFullTextID: int = 1400` — localized string identifier for inventory full.
- `ContainerFullTextID: int = 1402` — localized string identifier for container full.
- `CorpseFullTextID: int = 1403` — localized string identifier for corpse full.

## Architectural notes

- No additional module-specific issue identified beyond repository-wide shared-variable and compiler-visible API constraints.
