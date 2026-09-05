module inv_overhaul_inventory_sounds do
  function InventorySoundsPlayOpen() -> void
    native.PlaySound("inv_overhaul_inv_open")
  end

  function InventorySoundsPlayItemEquip() -> void
    native.PlaySound("inv_overhaul_item_equip")
  end

  function InventorySoundsPlayAction() -> void
    native.PlaySound("inv_overhaul_inv_action")
  end

  function InventorySoundsPlayMoneyPickup() -> void
    native.PlaySound("inv_overhaul_money_pickup")
  end
end
