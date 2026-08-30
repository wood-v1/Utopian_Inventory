# Container Transfer

## Source

`scripts/loot/inv_overhaul_container_transfer.lua`

DSL unit: `module inv_overhaul_container_transfer`

## Responsibility

Provides shared capacity checks, stack movement, and transfer primitives used by player/external transfer adapters.

## Dependencies

- `inv_overhaul_inventory_items` — Builds the canonical projection of unequipped player items into backpack ordinals and cached category/index references.
- Pathologic native API — engine state, object access, persistence variables, UI messaging, timing, or rendering as listed per function.

## Used by

- `scripts/loot/inv_overhaul_container_player_actions.lua`
- `scripts/loot/inv_overhaul_container_transfer_external.lua`
- `scripts/loot/inv_overhaul_container_transfer_player.lua`

## State

No module/task-level mutable state.

## Public API

All functions below are compiler-visible when the module is imported; the DSL has no private declaration.

### `NormalizeAmount(requestedAmount: int, availableAmount: int) -> int`

Source: `scripts/loot/inv_overhaul_container_transfer.lua`

Purpose: Normalizes amount in the container transfer subsystem.

Parameters:

- `requestedAmount: int` — value interpreted according to the function purpose; no narrower contract is established by current code.
- `availableAmount: int` — value interpreted according to the function purpose; no narrower contract is established by current code.

Returns:

- `number` (integer) — result of: normalizes amount in the container transfer subsystem.

Side effects:

- None directly observable beyond calls listed below.

Called by:

- `scripts/loot/inv_overhaul_container_player_actions.lua :: DropToWorld`
- `scripts/loot/inv_overhaul_container_transfer.lua :: MovePlayerAmountToExternal`
- `scripts/loot/inv_overhaul_container_transfer_external.lua :: MoveResolvedAmountToPlayer`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `FindPlayerMergeIndex(player: object, category: int, itemID: int) -> int`

Source: `scripts/loot/inv_overhaul_container_transfer.lua`

Purpose: Finds player merge index in the container transfer subsystem.

Parameters:

- `player: object` — player engine container/object used for inventory reads or mutations.
- `category: int` — zero-based engine inventory category identifier.
- `itemID: int` — engine item or callback identifier interpreted by this function.

Returns:

- `number` (integer) — result of: finds player merge index in the container transfer subsystem.

Side effects:

- Delegates to compiler-visible module APIs and inherits their documented side effects.

Called by:

- `scripts/loot/inv_overhaul_container_transfer_external.lua :: MoveResolvedAmountToPlayer`
- `scripts/loot/inv_overhaul_container_transfer_player.lua :: ExchangeWithContainer`

Calls:

- `native.GetInvItemMaxStackSize`
- `player.GetItemCount`
- `inv_overhaul_inventory_items.IsEquipped`
- `player.GetItem`
- `candidate.GetItemID`
- `player.GetItemAmount`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `GetPlayerItemTotalAmount(player: object, category: int, wantedItemID: int) -> int`

Source: `scripts/loot/inv_overhaul_container_transfer.lua`

Purpose: Returns player item total amount in the container transfer subsystem.

Parameters:

- `player: object` — player engine container/object used for inventory reads or mutations.
- `category: int` — zero-based engine inventory category identifier.
- `wantedItemID: int` — engine item or callback identifier interpreted by this function.

Returns:

- `number` (integer) — result of: returns player item total amount in the container transfer subsystem.

Side effects:

- None directly observable beyond calls listed below.

Called by:

- `scripts/loot/inv_overhaul_container_transfer.lua :: MoveExternalItemAmountToPlayer`
- `scripts/loot/inv_overhaul_container_transfer_player.lua :: ExchangeWithContainer`

Calls:

- `player.GetItemCount`
- `player.GetItem`
- `candidate.GetItemID`
- `player.GetItemAmount`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `GetExternalItemTotalAmount(external: object, wantedItemID: int) -> int`

Source: `scripts/loot/inv_overhaul_container_transfer.lua`

Purpose: Returns external item total amount in the container transfer subsystem.

Parameters:

- `external: object` — external world container/corpse engine object used for inventory reads or mutations.
- `wantedItemID: int` — engine item or callback identifier interpreted by this function.

Returns:

- `number` (integer) — result of: returns external item total amount in the container transfer subsystem.

Side effects:

- None directly observable beyond calls listed below.

Called by:

- `scripts/loot/inv_overhaul_container_transfer.lua :: MovePlayerAmountToExternal`

Calls:

- `external.GetItemCount`
- `external.GetItem`
- `candidate.GetItemID`
- `external.GetItemAmount`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `CreatePlayerToExternalOutcome(status: int, itemID: int, success: bool, beforeExternalAmount: int, afterExternalAmount: int) -> object`

Source: `scripts/loot/inv_overhaul_container_transfer.lua`

Purpose: Creates player to external outcome in the container transfer subsystem.

Parameters:

- `status: int` — value interpreted according to the function purpose; no narrower contract is established by current code.
- `itemID: int` — engine item or callback identifier interpreted by this function.
- `success: bool` — behavior flag interpreted by this function.
- `beforeExternalAmount: int` — value interpreted according to the function purpose; no narrower contract is established by current code.
- `afterExternalAmount: int` — value interpreted according to the function purpose; no narrower contract is established by current code.

Returns:

- `object` — five-element integer-vector outcome: `[status, itemID, addSucceeded, amountBefore, amountAfter]`; `null` when the source/amount cannot be resolved before transfer.

Side effects:

- Invokes engine/native operations: `native.CreateIntVector`.
- May mutate engine/UI objects through: `outcome.add`.

Called by:

- `scripts/loot/inv_overhaul_container_transfer.lua :: MovePlayerAmountToExternal`

Calls:

- `native.CreateIntVector`
- `outcome.add`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `MovePlayerAmountToExternal(player: object, external: object, category: int, index: int, requestedAmount: int) -> object`

Source: `scripts/loot/inv_overhaul_container_transfer.lua`

Purpose: Moves player amount to external in the container transfer subsystem.

Parameters:

- `player: object` — player engine container/object used for inventory reads or mutations.
- `external: object` — external world container/corpse engine object used for inventory reads or mutations.
- `category: int` — zero-based engine inventory category identifier.
- `index: int` — zero-based entry index in the relevant engine container/category.
- `requestedAmount: int` — value interpreted according to the function purpose; no narrower contract is established by current code.

Returns:

- `object` — result of: moves player amount to external in the container transfer subsystem.

Side effects:

- Invokes engine/native operations: `native.SetPlayerHandsItem`.
- May mutate engine/UI objects through: `external.AddItem`, `player.IsItemSelected`, `player.RemoveItem`.

Called by:

- `scripts/loot/inv_overhaul_container_transfer_player.lua :: MoveAmountToContainer`

Calls:

- `player.GetItem`
- `player.GetItemAmount`
- `NormalizeAmount`
- `item.GetItemID`
- `GetExternalItemTotalAmount`
- `external.AddItem`
- `CreatePlayerToExternalOutcome`
- `player.IsItemSelected`
- `native.SetPlayerHandsItem`
- `player.RemoveItem`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `PlayerToExternalWasRejected(outcome: object) -> bool`

Source: `scripts/loot/inv_overhaul_container_transfer.lua`

Purpose: Returns whether rejected for player to external in the container transfer subsystem.

Parameters:

- `outcome: object` — five-element integer-vector outcome: `[status, itemID, addSucceeded, amountBefore, amountAfter]`.

Returns:

- `boolean` — result of: returns whether rejected for player to external in the container transfer subsystem.

Side effects:

- None directly observable beyond calls listed below.

Called by:

- `scripts/loot/inv_overhaul_container_transfer_player.lua :: MoveAmountToContainer`

Calls:

- `outcome.get`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `GetPlayerToExternalItemID(outcome: object) -> int`

Source: `scripts/loot/inv_overhaul_container_transfer.lua`

Purpose: Returns player to external item id in the container transfer subsystem.

Parameters:

- `outcome: object` — five-element integer-vector outcome: `[status, itemID, addSucceeded, amountBefore, amountAfter]`.

Returns:

- `number` (integer) — result of: returns player to external item id in the container transfer subsystem.

Side effects:

- None directly observable beyond calls listed below.

Called by:

- `scripts/loot/inv_overhaul_container_transfer_player.lua :: MoveAmountToContainer`

Calls:

- `outcome.get`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `GetPlayerToExternalSuccess(outcome: object) -> bool`

Source: `scripts/loot/inv_overhaul_container_transfer.lua`

Purpose: Returns player to external success in the container transfer subsystem.

Parameters:

- `outcome: object` — five-element integer-vector outcome: `[status, itemID, addSucceeded, amountBefore, amountAfter]`.

Returns:

- `boolean` — result of: returns player to external success in the container transfer subsystem.

Side effects:

- None directly observable beyond calls listed below.

Called by:

- `scripts/loot/inv_overhaul_container_transfer_player.lua :: MoveAmountToContainer`

Calls:

- `outcome.get`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `GetPlayerToExternalBeforeAmount(outcome: object) -> int`

Source: `scripts/loot/inv_overhaul_container_transfer.lua`

Purpose: Returns player to external before amount in the container transfer subsystem.

Parameters:

- `outcome: object` — five-element integer-vector outcome: `[status, itemID, addSucceeded, amountBefore, amountAfter]`.

Returns:

- `number` (integer) — result of: returns player to external before amount in the container transfer subsystem.

Side effects:

- None directly observable beyond calls listed below.

Called by:

- `scripts/loot/inv_overhaul_container_transfer_player.lua :: MoveAmountToContainer`

Calls:

- `outcome.get`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `GetPlayerToExternalAfterAmount(outcome: object) -> int`

Source: `scripts/loot/inv_overhaul_container_transfer.lua`

Purpose: Returns player to external after amount in the container transfer subsystem.

Parameters:

- `outcome: object` — five-element integer-vector outcome: `[status, itemID, addSucceeded, amountBefore, amountAfter]`.

Returns:

- `number` (integer) — result of: returns player to external after amount in the container transfer subsystem.

Side effects:

- None directly observable beyond calls listed below.

Called by:

- `scripts/loot/inv_overhaul_container_transfer_player.lua :: MoveAmountToContainer`

Calls:

- `outcome.get`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `CreateExternalToPlayerOutcome(status: int, success: bool, beforePlayerAmount: int, afterPlayerAmount: int, sourceDepleted: bool) -> object`

Source: `scripts/loot/inv_overhaul_container_transfer.lua`

Purpose: Creates external to player outcome in the container transfer subsystem.

Parameters:

- `status: int` — value interpreted according to the function purpose; no narrower contract is established by current code.
- `success: bool` — behavior flag interpreted by this function.
- `beforePlayerAmount: int` — value interpreted according to the function purpose; no narrower contract is established by current code.
- `afterPlayerAmount: int` — value interpreted according to the function purpose; no narrower contract is established by current code.
- `sourceDepleted: bool` — behavior flag interpreted by this function.

Returns:

- `object` — five-element integer-vector outcome: `[status, addSucceeded, amountBefore, amountAfter, sourceDepleted]`.

Side effects:

- Invokes engine/native operations: `native.CreateIntVector`.
- May mutate engine/UI objects through: `outcome.add`.

Called by:

- `scripts/loot/inv_overhaul_container_transfer.lua :: MoveExternalItemAmountToPlayer`

Calls:

- `native.CreateIntVector`
- `outcome.add`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `MoveExternalItemAmountToPlayer(player: object, external: object, item: object, organSource: bool, sourceIndex: int, amount: int, transferAmount: int, category: int, itemID: int) -> object`

Source: `scripts/loot/inv_overhaul_container_transfer.lua`

Purpose: Moves external item amount to player in the container transfer subsystem.

Parameters:

- `player: object` — player engine container/object used for inventory reads or mutations.
- `external: object` — external world container/corpse engine object used for inventory reads or mutations.
- `item: object` — engine inventory-item object; available properties and methods are supplied by the game.
- `organSource: bool` — behavior flag interpreted by this function.
- `sourceIndex: int` — zero-based entry index in the relevant engine container/category.
- `amount: int` — value interpreted according to the function purpose; no narrower contract is established by current code.
- `transferAmount: int` — value interpreted according to the function purpose; no narrower contract is established by current code.
- `category: int` — zero-based engine inventory category identifier.
- `itemID: int` — engine item or callback identifier interpreted by this function.

Returns:

- `object` — result of: moves external item amount to player in the container transfer subsystem.

Side effects:

- May mutate engine/UI objects through: `item.SetProperty`, `item.RemoveProperty`, `player.AddItem`, `external.RemoveItem`.

Called by:

- `scripts/loot/inv_overhaul_container_transfer_external.lua :: MoveResolvedAmountToPlayer`

Calls:

- `GetPlayerItemTotalAmount`
- `player.GetItemCount`
- `item.SetProperty`
- `item.RemoveProperty`
- `player.AddItem`
- `CreateExternalToPlayerOutcome`
- `external.RemoveItem`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `ExternalToPlayerWasRejected(outcome: object) -> bool`

Source: `scripts/loot/inv_overhaul_container_transfer.lua`

Purpose: Returns whether rejected for external to player in the container transfer subsystem.

Parameters:

- `outcome: object` — five-element integer-vector outcome: `[status, addSucceeded, amountBefore, amountAfter, sourceDepleted]`.

Returns:

- `boolean` — result of: returns whether rejected for external to player in the container transfer subsystem.

Side effects:

- None directly observable beyond calls listed below.

Called by:

- `scripts/loot/inv_overhaul_container_transfer_external.lua :: MoveResolvedAmountToPlayer`

Calls:

- `outcome.get`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `GetExternalToPlayerSuccess(outcome: object) -> bool`

Source: `scripts/loot/inv_overhaul_container_transfer.lua`

Purpose: Returns external to player success in the container transfer subsystem.

Parameters:

- `outcome: object` — five-element integer-vector outcome: `[status, addSucceeded, amountBefore, amountAfter, sourceDepleted]`.

Returns:

- `boolean` — result of: returns external to player success in the container transfer subsystem.

Side effects:

- None directly observable beyond calls listed below.

Called by:

- `scripts/loot/inv_overhaul_container_transfer_external.lua :: MoveResolvedAmountToPlayer`

Calls:

- `outcome.get`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `GetExternalToPlayerBeforeAmount(outcome: object) -> int`

Source: `scripts/loot/inv_overhaul_container_transfer.lua`

Purpose: Returns external to player before amount in the container transfer subsystem.

Parameters:

- `outcome: object` — five-element integer-vector outcome: `[status, addSucceeded, amountBefore, amountAfter, sourceDepleted]`.

Returns:

- `number` (integer) — result of: returns external to player before amount in the container transfer subsystem.

Side effects:

- None directly observable beyond calls listed below.

Called by:

- `scripts/loot/inv_overhaul_container_transfer_external.lua :: MoveResolvedAmountToPlayer`

Calls:

- `outcome.get`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `GetExternalToPlayerAfterAmount(outcome: object) -> int`

Source: `scripts/loot/inv_overhaul_container_transfer.lua`

Purpose: Returns external to player after amount in the container transfer subsystem.

Parameters:

- `outcome: object` — five-element integer-vector outcome: `[status, addSucceeded, amountBefore, amountAfter, sourceDepleted]`.

Returns:

- `number` (integer) — result of: returns external to player after amount in the container transfer subsystem.

Side effects:

- None directly observable beyond calls listed below.

Called by:

- `scripts/loot/inv_overhaul_container_transfer_external.lua :: MoveResolvedAmountToPlayer`

Calls:

- `outcome.get`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `ExternalToPlayerSourceDepleted(outcome: object) -> bool`

Source: `scripts/loot/inv_overhaul_container_transfer.lua`

Purpose: Returns whether external to player source in the container transfer subsystem.

Parameters:

- `outcome: object` — five-element integer-vector outcome: `[status, addSucceeded, amountBefore, amountAfter, sourceDepleted]`.

Returns:

- `boolean` — result of: returns whether external to player source in the container transfer subsystem.

Side effects:

- None directly observable beyond calls listed below.

Called by:

- `scripts/loot/inv_overhaul_container_transfer_external.lua :: MoveResolvedAmountToPlayer`

Calls:

- `outcome.get`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.

### `SwapAppendedEntry(external: object, exchangedItem: object, exchangedAmount: int, exchangedIndex: int, expectedAppendedItemID: int, countBefore: int) -> int`

Source: `scripts/loot/inv_overhaul_container_transfer.lua`

Purpose: Swaps appended entry in the container transfer subsystem.

Parameters:

- `external: object` — external world container/corpse engine object used for inventory reads or mutations.
- `exchangedItem: object` — engine inventory-item object; available properties and methods are supplied by the game.
- `exchangedAmount: int` — value interpreted according to the function purpose; no narrower contract is established by current code.
- `exchangedIndex: int` — zero-based entry index in the relevant engine container/category.
- `expectedAppendedItemID: int` — engine item or callback identifier interpreted by this function.
- `countBefore: int` — value interpreted according to the function purpose; no narrower contract is established by current code.

Returns:

- `number` (integer) — result of: swaps appended entry in the container transfer subsystem.

Side effects:

- May mutate engine/UI objects through: `external.SetItem`.

Called by:

- `scripts/loot/inv_overhaul_container_transfer_player.lua :: ExchangeWithContainer`

Calls:

- `external.GetItemCount`
- `external.GetItem`
- `external.GetItemAmount`
- `appendedItem.GetItemID`
- `external.SetItem`

Notes / invariants:

- Compiler-visible module function; the DSL has no private-function keyword.


## Internal API

No additional maintask helpers.

## Events / callbacks

No engine callbacks; this is an imported module.

## Important constants

- `PlayerWeaponCategory: int = 0` — engine inventory category value for player weapon category.
- `PlayerToExternalRejected: int = 1` — named behavior/layout value for player to external rejected.
- `PlayerToExternalCompleted: int = 2` — named behavior/layout value for player to external completed.
- `ExternalToPlayerRejected: int = 1` — named behavior/layout value for external to player rejected.
- `ExternalToPlayerCompleted: int = 2` — named behavior/layout value for external to player completed.

## Architectural notes

- Transfer primitives mutate engine containers and layout hints in an order-sensitive sequence. Player/external adapters deliberately retain direction-specific policy.
