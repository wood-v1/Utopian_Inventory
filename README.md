# Utopian Inventory

Full-screen equipment and backpack UI for Pathologic Classic HD.

The mod keeps vanilla item storage, categories, saves, item definitions, trade,
loot, and equipment state intact. OynonTools redirects only vanilla
`inventory.xml` to `utopian_inventory.xml`; container, corpse, apparatus, and
doctor-apparatus windows remain vanilla.

The adaptive layouts place the backpack grid on the right and the current
character silhouette on the left. The silhouette automatically follows the
active story branch (Bachelor, Haruspex, or Changeling). Five drag targets equip weapons, footwear,
headwear, body clothing, and gloves. A separate `DROP` target moves one item to
the world container. Equipped items remain visible in the backpack and are also
mirrored in their character slots.

The three XML layouts are generated from one coordinate table:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\generate_inventory_layouts.ps1
```

UI XML files are deployed to `data/UI`; assets referenced as `ui/...` are
deployed separately to `data/Textures/UI`, matching the game's texture resolver.

## Build

```powershell
cmake -S . -B build-win32 -A Win32
cmake --build build-win32 --config Release
```

## Deploy

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\deploy.ps1 -GameRoot "<Pathologic Classic HD root>"
```
