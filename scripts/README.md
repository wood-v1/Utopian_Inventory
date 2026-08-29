# Lua source architecture

Lua/DSL sources are organized by gameplay ownership. Runtime script names do
not include these source folders: the build stages every source by its existing
basename before invoking `pathologic_lua_compiler`, so generated `.bin` names
remain compatible with XML, native code, effects, and saved references.

- `backpack/` owns the shared 56-cell backpack projection, layout, persistence,
  and snapshots.
- `inventory_interface/` owns UI protocols and reusable inventory forms.
- `player_inventory/` owns the player screen, with player-only forms in
  `widgets/`.
- `loot/` owns container and corpse sessions, presentation, interaction, and
  transfer behavior, with loot-only forms in `widgets/`.
- `quickslots/` owns active quickslot bindings, activation policies, effects,
  and native request transports in `requests/`.
- `inventory_runtime/` owns persistent capacity, overflow, consolidation,
  snapshot seeding, and special-inventory integration.
- `compatibility/` retains dormant or superseded runtimes whose external or
  save-game callers have not yet been ruled out. Active packages must not import
  compatibility sources.

Imports intentionally remain basename-based because the compiler's documented
contract is sibling-relative and does not provide project include paths. Always
compile through `build_lua.ps1` (or `deploy.ps1`, which calls it); do not compile
a nested source entry directly.

Run the structural checks without compiling:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\validate_lua_architecture.ps1
```
