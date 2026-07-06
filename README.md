# Utopian Inventory

Centered one-cell inventory UI prototype for Pathologic Classic HD.

The mod keeps vanilla item storage, categories, saves, item definitions, trade,
loot, and equipment state intact. OynonTools redirects only vanilla
`inventory.xml` to `utopian_inventory.xml`; container, corpse, apparatus, and
doctor-apparatus windows remain vanilla.

## Build

```powershell
cmake -S . -B build-win32 -A Win32
cmake --build build-win32 --config Release
```

## Deploy

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\deploy.ps1 -GameRoot "<Pathologic Classic HD root>"
```
