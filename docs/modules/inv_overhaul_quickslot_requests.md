# Quickslot Request Transports

## Source

- `scripts/quickslots/requests/inv_overhaul_quickslot_request_1.lua` — `maintask InvOverhaulQuickslotRequest1`
- `scripts/quickslots/requests/inv_overhaul_quickslot_request_10.lua` — `maintask InvOverhaulQuickslotRequest10`
- `scripts/quickslots/requests/inv_overhaul_quickslot_request_2.lua` — `maintask InvOverhaulQuickslotRequest2`
- `scripts/quickslots/requests/inv_overhaul_quickslot_request_3.lua` — `maintask InvOverhaulQuickslotRequest3`
- `scripts/quickslots/requests/inv_overhaul_quickslot_request_4.lua` — `maintask InvOverhaulQuickslotRequest4`
- `scripts/quickslots/requests/inv_overhaul_quickslot_request_5.lua` — `maintask InvOverhaulQuickslotRequest5`
- `scripts/quickslots/requests/inv_overhaul_quickslot_request_6.lua` — `maintask InvOverhaulQuickslotRequest6`
- `scripts/quickslots/requests/inv_overhaul_quickslot_request_7.lua` — `maintask InvOverhaulQuickslotRequest7`
- `scripts/quickslots/requests/inv_overhaul_quickslot_request_8.lua` — `maintask InvOverhaulQuickslotRequest8`
- `scripts/quickslots/requests/inv_overhaul_quickslot_request_9.lua` — `maintask InvOverhaulQuickslotRequest9`

## Responsibility

Contains ten native transport maintasks; each maps one numeric key request script to a saved quickslot request value.

Each file is a separate compiled runtime entry point referenced by native code. It does not own activation policy or item state.

## Dependencies

- No local DSL imports.
- Pathologic native API — writes the shared `inv_overhaul_quickslot_request` engine variable.

## Used by

- `bootstrap.cpp` formats `inv_overhaul_quickslot_request_%d.bin` and applies the corresponding effect for numeric keys.

## State

No task-level mutable state.

## Public API

No importable module API.

## Internal API

No internal helpers.

## Events / callbacks

### `init() -> void`

Source: `scripts/quickslots/requests/inv_overhaul_quickslot_request_1.lua`

Purpose: Initializes the quickslot request 1 runtime and establishes its starting state and engine/UI integration.

Parameters:

None.

Returns:

None.

Side effects:

- Writes shared engine variable(s): `"inv_overhaul_quickslot_request"`.
- Invokes engine/native operations: `native.SetVariable`.

Called by:

- No in-repository caller was resolved; this may be an engine/XML callback or a conventionally public helper.

Calls:

- `native.SetVariable`

Notes / invariants:

- Maintask helper; callable within its task unless the engine invokes it by a documented callback name.

### `init() -> void`

Source: `scripts/quickslots/requests/inv_overhaul_quickslot_request_10.lua`

Purpose: Initializes the quickslot request 10 runtime and establishes its starting state and engine/UI integration.

Parameters:

None.

Returns:

None.

Side effects:

- Writes shared engine variable(s): `"inv_overhaul_quickslot_request"`.
- Invokes engine/native operations: `native.SetVariable`.

Called by:

- No in-repository caller was resolved; this may be an engine/XML callback or a conventionally public helper.

Calls:

- `native.SetVariable`

Notes / invariants:

- Maintask helper; callable within its task unless the engine invokes it by a documented callback name.

### `init() -> void`

Source: `scripts/quickslots/requests/inv_overhaul_quickslot_request_2.lua`

Purpose: Initializes the quickslot request 2 runtime and establishes its starting state and engine/UI integration.

Parameters:

None.

Returns:

None.

Side effects:

- Writes shared engine variable(s): `"inv_overhaul_quickslot_request"`.
- Invokes engine/native operations: `native.SetVariable`.

Called by:

- No in-repository caller was resolved; this may be an engine/XML callback or a conventionally public helper.

Calls:

- `native.SetVariable`

Notes / invariants:

- Maintask helper; callable within its task unless the engine invokes it by a documented callback name.

### `init() -> void`

Source: `scripts/quickslots/requests/inv_overhaul_quickslot_request_3.lua`

Purpose: Initializes the quickslot request 3 runtime and establishes its starting state and engine/UI integration.

Parameters:

None.

Returns:

None.

Side effects:

- Writes shared engine variable(s): `"inv_overhaul_quickslot_request"`.
- Invokes engine/native operations: `native.SetVariable`.

Called by:

- No in-repository caller was resolved; this may be an engine/XML callback or a conventionally public helper.

Calls:

- `native.SetVariable`

Notes / invariants:

- Maintask helper; callable within its task unless the engine invokes it by a documented callback name.

### `init() -> void`

Source: `scripts/quickslots/requests/inv_overhaul_quickslot_request_4.lua`

Purpose: Initializes the quickslot request 4 runtime and establishes its starting state and engine/UI integration.

Parameters:

None.

Returns:

None.

Side effects:

- Writes shared engine variable(s): `"inv_overhaul_quickslot_request"`.
- Invokes engine/native operations: `native.SetVariable`.

Called by:

- No in-repository caller was resolved; this may be an engine/XML callback or a conventionally public helper.

Calls:

- `native.SetVariable`

Notes / invariants:

- Maintask helper; callable within its task unless the engine invokes it by a documented callback name.

### `init() -> void`

Source: `scripts/quickslots/requests/inv_overhaul_quickslot_request_5.lua`

Purpose: Initializes the quickslot request 5 runtime and establishes its starting state and engine/UI integration.

Parameters:

None.

Returns:

None.

Side effects:

- Writes shared engine variable(s): `"inv_overhaul_quickslot_request"`.
- Invokes engine/native operations: `native.SetVariable`.

Called by:

- No in-repository caller was resolved; this may be an engine/XML callback or a conventionally public helper.

Calls:

- `native.SetVariable`

Notes / invariants:

- Maintask helper; callable within its task unless the engine invokes it by a documented callback name.

### `init() -> void`

Source: `scripts/quickslots/requests/inv_overhaul_quickslot_request_6.lua`

Purpose: Initializes the quickslot request 6 runtime and establishes its starting state and engine/UI integration.

Parameters:

None.

Returns:

None.

Side effects:

- Writes shared engine variable(s): `"inv_overhaul_quickslot_request"`.
- Invokes engine/native operations: `native.SetVariable`.

Called by:

- No in-repository caller was resolved; this may be an engine/XML callback or a conventionally public helper.

Calls:

- `native.SetVariable`

Notes / invariants:

- Maintask helper; callable within its task unless the engine invokes it by a documented callback name.

### `init() -> void`

Source: `scripts/quickslots/requests/inv_overhaul_quickslot_request_7.lua`

Purpose: Initializes the quickslot request 7 runtime and establishes its starting state and engine/UI integration.

Parameters:

None.

Returns:

None.

Side effects:

- Writes shared engine variable(s): `"inv_overhaul_quickslot_request"`.
- Invokes engine/native operations: `native.SetVariable`.

Called by:

- No in-repository caller was resolved; this may be an engine/XML callback or a conventionally public helper.

Calls:

- `native.SetVariable`

Notes / invariants:

- Maintask helper; callable within its task unless the engine invokes it by a documented callback name.

### `init() -> void`

Source: `scripts/quickslots/requests/inv_overhaul_quickslot_request_8.lua`

Purpose: Initializes the quickslot request 8 runtime and establishes its starting state and engine/UI integration.

Parameters:

None.

Returns:

None.

Side effects:

- Writes shared engine variable(s): `"inv_overhaul_quickslot_request"`.
- Invokes engine/native operations: `native.SetVariable`.

Called by:

- No in-repository caller was resolved; this may be an engine/XML callback or a conventionally public helper.

Calls:

- `native.SetVariable`

Notes / invariants:

- Maintask helper; callable within its task unless the engine invokes it by a documented callback name.

### `init() -> void`

Source: `scripts/quickslots/requests/inv_overhaul_quickslot_request_9.lua`

Purpose: Initializes the quickslot request 9 runtime and establishes its starting state and engine/UI integration.

Parameters:

None.

Returns:

None.

Side effects:

- Writes shared engine variable(s): `"inv_overhaul_quickslot_request"`.
- Invokes engine/native operations: `native.SetVariable`.

Called by:

- No in-repository caller was resolved; this may be an engine/XML callback or a conventionally public helper.

Calls:

- `native.SetVariable`

Notes / invariants:

- Maintask helper; callable within its task unless the engine invokes it by a documented callback name.

## Important constants

No task-level constants.

## Architectural notes

- The ten near-identical maintasks are intentional distinct runtime `.bin` entry points selected by native code; consolidating them would change the external transport contract.
