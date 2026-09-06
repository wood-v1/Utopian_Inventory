# Architecture

## Runtime boundary

The mod combines a native Win32 DLL (`bootstrap.cpp`), OynonTools hooks, typed Lua/DSL scripts, and XML UI forms. The DLL selects replacement player/container/corpse XML, configures engine capacities, publishes native state through engine variables, and installs `inv_overhaul_inventory_bootstrap.bin` as the player bootstrap effect. XML forms instantiate UI maintasks by compiled basename. Lua modules are compiled into each importing maintask; imports are basename-based and dependency-first.

## Domains and ownership

| Domain | Owns | Does not own |
| --- | --- | --- |
| `backpack/` | Unequipped-item projection, 56 visual cells, layout persistence, identity snapshots | Engine container mutation policy or UI widgets |
| `inventory_interface/` | Shared numeric protocols, geometry, tooltips, interaction sounds, slot/background/money/page forms | Player/container domain decisions |
| `player_inventory/` | Player screen lifecycle, input, equipment, drag/drop, paging, rendering orchestration | Persistent capacity enforcement |
| `loot/` | Container/corpse session, external projection, transfer directions, organs, loot UI | Quickslot activation policy |
| `quickslots/` | Saved bindings, activation policy/effects, native key-request transport | Inventory rendering |
| `inventory_runtime/` | Long-lived capacity guard, overflow drops, stack consolidation, snapshot seeding, special-inventory handshake | Screen-local presentation |
| `compatibility/` | Dormant/superseded entry points retained for unresolved callers | Active runtime dependencies |

## Dependency direction

```text
Native bootstrap / XML forms
-> maintask entry points
-> screen/effect controllers
-> domain modules (loot, player inventory, quickslots, runtime)
-> backpack projection/layout + shared interface protocol/geometry
-> Pathologic native/object APIs and shared engine variables
```

Active sources may depend across active domains but must not import `compatibility/`. The structural validator enforces unique basenames, resolved imports, no import cycles, and the compatibility boundary.

## Initialization flows

Persistent player effects:

```text
bootstrap.cpp configures inv_overhaul_inventory_bootstrap.bin
-> InventoryOverhaulBootstrap.init waits one world tick
-> increments inv_overhaul_effect_generation
-> applies inv_overhaul_inventory_guard.bin
-> applies inv_overhaul_quickslots.bin
-> guard seeds persistent snapshots and begins capacity/stack/overflow polling
-> quickslot effect initializes saved activation state and polls native key requests
```

Player inventory screen:

```text
Native inventory redirect selects inv_overhaul_inventory*.xml
-> native open profiler starts before the prepare callback
-> XML instantiates InventoryOverhaulUI
-> InventoryOverhaulUI.init
-> inv_overhaul_inventory_controller.PlayerControllerInitialize
-> initialize view/presenter/drag/paging/tooltip/quickslot/layout/snapshot state
-> child forms synchronously initialize fixed chrome, equipment, money, and doll resources
-> frame stages load packed layout, reconcile projection, load item textures/metadata, persist layout, refresh UI
```

The player screen deliberately stages item/equipment sprite publication after window creation,
one occupied entry per update. Fixed chrome still loads during child-form creation. With debug
logging enabled, native and script probes report prepare/create, child readiness, layout,
first-item, fixed-image, open-sound, and completion timings without adding probes to release
build behavior.

Container/corpse screen:

```text
Native loot redirect selects container or corpse XML
-> XML instantiates InvOverhaulContainerUI
-> initialize session, feedback, bootstrap, input, drag, tooltip, bindings, projection, snapshot, layout
-> detect external container kind
-> staged presenter load and per-frame session/paging/persistence updates
```

## Important event flows

Inventory drag/drop:

```text
slot/background/widget pointer callback
-> numeric inventory protocol message
-> player controller
-> drag/equipment/drop/layout module
-> snapshot/layout reconciliation
-> presenter/view refresh
```

Container transfer:

```text
slot pointer or contextual click
-> container input controller
-> quick-transfer or drag controller
-> player/external transfer adapter
-> shared transfer primitives + engine container mutation
-> player layout hint/reconciliation
-> container/player projection refresh
```

Quickslot activation:

```text
native key hook
-> inv_overhaul_quickslot_request_N.bin
-> shared inv_overhaul_quickslot_request variable
-> persistent quickslot effect poll
-> binding lookup
-> consumable effect, equipment toggle, hands request, or weapon effect
-> inventory generation/layout hints + UI feedback
```

## Shared state and persistence

- Module locals compile to global storage inside each compiled maintask; they are not repository-wide singletons across separate `.bin` scripts.
- Cross-script persistent coordination uses dynamically named engine variables such as layout cells, snapshots, quickslot bindings, content/reorder generations, page-hover state, special-inventory remap state, and effect generations.
- Player layout persistence version 5 packs five 6-bit cell ordinals into each of 12 signed-safe engine integers. Versions 3 and 4 are read once and migrated; this keeps the hot reopen path from issuing one engine-variable read per cell.
- The native bootstrap publishes `inv_overhaul_debug_enabled` before constructing the player inventory UI so performance probes follow the global `[Debug] Enabled` setting; other mod traces are centrally filtered after operational console listeners consume them.
- The player backpack projection excludes selected weapon/clothing entries. Equipment has dedicated targets and does not consume the 56-cell backpack capacity.
- Layout runtime maps visual cells to projected item ordinals. Snapshot reconciliation preserves cells across category/index changes, equipment selection/replacement, transfers, and scripted mutations.
- The guard owns enforcement after arbitrary game `AddItem`/`RemoveItem` callbacks. Screen controllers perform preflight checks for user-initiated transfers; the guard is the final persistent safety net.

## UI/domain boundaries

View/widget maintasks publish or consume numeric messages and render state; domain mutations belong in controller, transfer, equipment, layout, quickslot, or runtime modules. `InventoryView` and `ContainerView` should not directly mutate engine inventory contents. Protocol constants and sender names form an ABI with XML form names and, for some page-hit/quickslot paths, native code.

## Compiler constraints

- This is a typed Lua-like DSL, not standard Lua.
- Imports resolve sibling-first by basename and module functions have compiler-visible bare labels; same-named functions across modules are unsafe.
- Module initialization runs before maintask `init()`.
- Callback recognition is function-name based.
- Declaration/import/order and task naming can affect generated storage, labels, task IDs, and event tables.

## Architectural risks

- `inv_overhaul_inventory_controller` remains a broad compiler-visible orchestration module despite the extracted player submodules.
- Shared engine-variable names and numeric UI protocols create implicit cross-script/native/XML coupling that imports alone do not reveal.
- Script initialization runs after the native XML creation timer ends: resource work is not included in `create_us`. A resource-only HUD companion preloads and holds the non-streaming inventory-open OGG buffer. The three player backgrounds/dolls are predecoded RGBA8 DDS assets to avoid compressed NPOT texture conversion on opening. Dimensions and decoded asset pixels are unchanged. See `INVENTORY_OPEN_PERFORMANCE.md` for measurements and remaining runtime checks.
- Hard-coded geometry exists in Lua, generated XML, and selected native hit tests and must remain synchronized.
- Compatibility quickslot/UI runtimes duplicate active behavior and can become stale, but removal requires proof that no external/save caller remains.
