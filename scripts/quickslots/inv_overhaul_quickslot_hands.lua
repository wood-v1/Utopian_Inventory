import "inv_overhaul_quickslot_activation"

module inv_overhaul_quickslot_hands do
  local const QuickslotHandsWeaponCategory: int = 0
  local const QuickslotHandsSlotCount: int = 10

  function AdjustBindingsAfterDrop(
    itemID: int,
    occurrence: int
  ) -> void
    for slot = 1, QuickslotHandsSlotCount do
      local assignedCategory: int = -1
      local assignedItemID: int = -1
      local assignedOccurrence: int = -1
      native.GetVariable(
        inv_overhaul_quickslot_activation.ActivationCategoryVariable(slot),
        assignedCategory)
      native.GetVariable(
        inv_overhaul_quickslot_activation.ActivationItemVariable(slot),
        assignedItemID)
      native.GetVariable(
        inv_overhaul_quickslot_activation.ActivationOccurrenceVariable(slot),
        assignedOccurrence)
      if assignedCategory == QuickslotHandsWeaponCategory && assignedItemID == itemID then
        if assignedOccurrence == occurrence then
          inv_overhaul_quickslot_activation.ClearBinding(slot)
        else
          if assignedOccurrence > occurrence then
            native.SetVariable(
              inv_overhaul_quickslot_activation.ActivationOccurrenceVariable(slot),
              assignedOccurrence - 1)
          end
        end
      end
    end
  end
end
