import "inv_overhaul_inventory_items"

module inv_overhaul_inventory_drop do
  local const WeaponCategory: int = 0

  function InventoryDropSlot(category: int, index: int, requestedAmount: int) -> bool
    local container: object
    native.GetContainer(container)
    if !container then
      native.Trace("inv_overhaul_inventory drop failed: world container unavailable")
      return false
    end

    local playerContainer: object =
      inv_overhaul_inventory_items.InventoryItemsGetPlayerContainer()
    local item: object
    playerContainer->GetItem(item, index, category)
    if !item then return false end
    local availableAmount: int
    playerContainer->GetItemAmount(availableAmount, index, category)
    local amount: int = requestedAmount
    if amount <= 0 || amount > availableAmount then amount = availableAmount end
    if amount <= 0 then return false end

    local success: bool
    container->AddItem(success, item, 0, amount)
    if !success then
      native.Trace("inv_overhaul_inventory drop failed: AddItem rejected category=" +
        category + " index=" + index)
      return false
    end

    if category == WeaponCategory then
      local selected: bool
      playerContainer->IsItemSelected(selected, index, category)
      if selected then native.SetPlayerHandsItem(-1) end
    end

    playerContainer->RemoveItem(index, amount, category)
    native.Trace("inv_overhaul_inventory drop success category=" + category +
      " index=" + index + " amount=" + amount)
    return true
  end
end
