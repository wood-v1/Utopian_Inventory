# Utopian Inventory

A complete inventory and loot-interface overhaul for Pathologic Classic HD.

Utopian Inventory keeps the game's item definitions, saves, categories, trade,
loot, and quest scripts compatible, while replacing the player inventory,
container, and corpse windows. The native twelve-stack limit of each player
category is lifted through OynonTools and replaced by one backpack limit of 56
occupied cells. Equipment lives in five dedicated character slots and does not
consume backpack capacity. Adding to an existing stack remains possible when all
56 cells are occupied.

## Features

- Character-specific, centered inventory frames and silhouettes for the
  Bachelor, Haruspex, and Changeling.
- Five equipment targets for headwear, body clothing, gloves, footwear, and
  weapons. Items can be equipped, unequipped, replaced, and moved to an exact
  backpack cell with drag-and-drop or contextual clicks.
- A stable 56-cell backpack layout. Existing items retain their saved visual
  cells when equipment, loot, scripts, or vanilla apparatus interfaces change
  the underlying game containers.
- Larger paged grids where all 56 cells do not fit on screen. Page buttons,
  drag-hover page switching, and `Ctrl + Left Click` moving between player pages
  are supported.
- Separate container and corpse layouts with bidirectional drag-and-drop,
  right-click transfer, stack transfer, and container pagination. Haruspex-only
  organ slots preserve the vanilla corpse-harvesting rules.
- A drop target and stack-aware drop shortcuts. Capacity checks reject unsafe
  transfers instead of deleting items, and scripted overflow is dropped near
  the player with a localized message.
- Quickslots `1` through `0`. Hover an inventory item and press a number to bind
  it; outside the inventory the same key consumes the item or toggles compatible
  equipment. Bindings and item feedback persist correctly across saves.
- Vanilla apparatus, doctor-apparatus, and microscope windows remain untouched.
  Immediately before they open, compatible vanilla items are stably moved to
  the front of their real categories through OynonTools, while the custom
  inventory's visual layout is reconciled without shuffling.
- English and Russian strings, item/drop/page hints, money display, clock, and
  configurable empty-slot opacity.

## Configuration

`bin\Final\mods\UtopianInventory.ini`:

```ini
[General]
Enabled=1
EmptySlotOpacity=0.78
```

`EmptySlotOpacity` accepts a floating-point value from `0` (fully transparent)
to `1` (fully opaque). The packaged default is `0.78`.

## Installation with Utopian Launcher

Install the game-root-layout folder or archive through **Install Mod** and select
`UtopianInventory.dll` as the primary DLL. The package contains the required
`OynonTools.dll`, compiled scripts, UI layouts, textures, strings, INI, and
uninstall manifest. A clean installation does not require replacing vanilla
inventory or apparatus scripts manually.

The package layout starts with:

```text
bin\Final\mods\UtopianInventory.dll
bin\Final\mods\UtopianInventory.ini
bin\Final\mods\UtopianInventory.manifest.ini
bin\Final\mods\OynonTools.dll
data\Scripts\utopian_*.bin
data\UI\utopian_*.xml
data\Textures\UI\utopian_*
data\Strings\utopian_inventory*.txt
```

The launcher must register either `utopian_inventory` or
`utopian_inventory_ru` in the game's `[Strings]` section. The repository
`deploy.ps1` does this automatically for development deployments.

## Regenerating layouts

All supported player, container, and corpse layouts are generated from the
coordinate tables in one script:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\generate_inventory_layouts.ps1
```

UI XML is installed in `data\UI`; assets referenced as `ui/...` are installed in
`data\Textures\UI`, matching the game's texture resolver.

## Build

The native DLLs must be built for Win32/x86. OynonTools is a required sibling
repository.

```powershell
cmake -S . -B build-win32 -A Win32 -DOYNONTOOLS_ROOT="..\OynonTools"
cmake --build build-win32 --config Release
```

Lua sources are compiled by `deploy.ps1` with `pathologic_lua_compiler` and the
`pathologic_re` definitions.

## Development deploy

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\deploy.ps1 `
  -GameRoot "<Pathologic Classic HD root>"
```

The deploy script builds both native projects unless skipped, recompiles all Lua
scripts, copies only mod-owned resources, removes obsolete experimental
apparatus overrides, registers localized strings, and verifies copied file
hashes.
