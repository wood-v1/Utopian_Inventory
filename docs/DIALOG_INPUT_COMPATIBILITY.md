# Dialog compatibility (Disco Dialogues 0.2.3)

InputBridge now uses shared OynonTools UI lifecycle state before keyboard item
actions, the additional handcombat command observer, and RetryPendingQuickslot.
This is an explicit modal-state check; OynonKeyboardCallback returns void and
GetAsyncKeyState notifications cannot be consumed by the dialogue Lua UI.

ItemHotkeysBlocked compares OynonUIDialogInputGeneration to cancel stale pending
quickslot work and queries OynonUIDialogBlocksItemHotkeys. All number-row/numpad
quickslots and the configurable handcombat binding are blocked in dialog/inline
character info. Escape and dialogue events still reach the game normally. No
user binding or inventory/loot script has been changed.

The closing press remains guarded until released. A fresh press after closure
works normally. Existing pending requests are cancelled instead of executing
after the dialog. No new input/update loop or dependency on DiscoDialogues.dll.

Build/deploy with the updated OynonTools containing both exports. The two matching
DLLs are also staged in DiscoDialogues/release/compatibility. Replace the existing
installed InventoryOverhaul.dll and OynonTools.dll with the game closed; preserve
scripts, INI and the existing Launcher ownership manifest.

Automated: Release Win32 build, and the real input_bridge.cpp under deterministic
mock transports in DiscoDialogues/tests/inventory_dialog_input_test.cpp (CTest).
Actual Launcher install/delete in a disposable fixture preserved 79 inventory
files and the new shared DLL. No in-game run has been performed.

Manual: put healing/other items on 1/2, choose dialog answers with 1/2, check 3/4
with only two answers, numpad, remapped Q, character info, mouse selection, Escape,
held Leave key, and a fresh 1 after closing. No item should activate inside the
dialog; inventory should resume outside it.
