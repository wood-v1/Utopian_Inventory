import "inv_overhaul_quickslot_activation"

module inv_overhaul_quickslot_equipment do
  local const QuickslotEquipmentWeaponCategory: int = 0
  local const QuickslotEquipmentCapacity: int = 56
  local const QuickslotEquipmentFullText: int = 1400
  local const QuickslotEquipmentMissingText: int = 1405

  function EquipmentPolicyToggle(
    category: int,
    index: int,
    itemID: int,
    occurrence: int,
    selected: bool
  ) -> void
    local player: object =
      inv_overhaul_quickslot_activation.ActivationGetPlayer()
    if category == QuickslotEquipmentWeaponCategory then
      native.SetVariable("inv_overhaul_quickslot_weapon_item", itemID)
      native.SetVariable("inv_overhaul_quickslot_weapon_occurrence", occurrence)
      player->ApplyEffect("inv_overhaul_quickslot_weapon.bin")
      native.Trace("inv_overhaul_quickslot weapon action dispatched item=" +
        itemID + " occurrence=" + occurrence + " selected=" + selected)
      return
    end

    if selected then
      if inv_overhaul_quickslot_activation.ActivationGetBackpackItemCount() >=
        QuickslotEquipmentCapacity then
        inv_overhaul_quickslot_activation.ShowMessage(
          QuickslotEquipmentFullText)
        return
      end
      player->SelectItem(index, false, category)
      inv_overhaul_quickslot_activation.MarkInventoryChanged()
      inv_overhaul_quickslot_activation.ShowFeedback(itemID)
      return
    end

    inv_overhaul_quickslot_activation.PublishEquipmentRemovalHint(
      category, index)
    local group: int
    native.GetInvItemProperty(group, itemID, "Group")
    local count: int
    player->GetItemCount(count, category)
    for other = 0, count - 1 do
      local otherItem: object
      local otherID: int
      local hasGroup: bool
      player->GetItem(otherItem, other, category)
      if otherItem then
        otherItem->GetItemID(otherID)
        native.HasInvItemProperty(hasGroup, otherID, "Group")
        if hasGroup then
          local otherGroup: int
          native.GetInvItemProperty(otherGroup, otherID, "Group")
          if otherGroup == group then player->SelectItem(other, false, category) end
        end
      end
    end

    local refreshedIndex: int =
      inv_overhaul_quickslot_activation.FindBoundItemIndex(
        category, itemID, occurrence)
    if refreshedIndex < 0 then
      inv_overhaul_quickslot_activation.CancelLastEquipmentRemovalHint()
      inv_overhaul_quickslot_activation.ShowMessage(
        QuickslotEquipmentMissingText)
      return
    end
    player->SelectItem(refreshedIndex, true, category)
    inv_overhaul_quickslot_activation.MarkInventoryChanged()
    inv_overhaul_quickslot_activation.ShowFeedback(itemID)
  end
end
