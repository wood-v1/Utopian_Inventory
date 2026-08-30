import "inv_overhaul_inventory_items"
import "inv_overhaul_inventory_protocol"

module inv_overhaul_inventory_equipment do
  local const WeaponCategory: int = 0
  local const ClothesCategory: int = 1

  local categoryCache: object
  local indexCache: object

  function InitializeCache() -> void
    local newCategoryCache: object
    local newIndexCache: object
    native.CreateIntVector(newCategoryCache)
    native.CreateIntVector(newIndexCache)
    categoryCache = newCategoryCache
    indexCache = newIndexCache
    for cache = 0, 4 do
      categoryCache->add(-1)
      indexCache->add(-1)
    end
  end

  function BuildCache() -> void
    for cache = 0, 4 do
      categoryCache->set(cache, -1)
      indexCache->set(cache, -1)
    end
    local container: object = inv_overhaul_inventory_items.ItemsGetPlayerContainer()
    local weaponCount: int
    container->GetItemCount(weaponCount, WeaponCategory)
    for weaponIndex = 0, weaponCount - 1 do
      local selectedWeapon: bool
      container->IsItemSelected(selectedWeapon, weaponIndex, WeaponCategory)
      if selectedWeapon then
        local weapon: object
        local weaponID: int
        local hasWeapon: bool
        container->GetItem(weapon, weaponIndex, WeaponCategory)
        weapon->GetItemID(weaponID)
        native.HasInvItemProperty(hasWeapon, weaponID, "Weapon")
        if hasWeapon then
          categoryCache->set(0, WeaponCategory)
          indexCache->set(0, weaponIndex)
          weaponIndex = weaponCount
        end
      end
    end

    local clothesCount: int
    container->GetItemCount(clothesCount, ClothesCategory)
    for clothesIndex = 0, clothesCount - 1 do
      local selectedClothes: bool
      container->IsItemSelected(selectedClothes, clothesIndex, ClothesCategory)
      if selectedClothes then
        local clothes: object
        local clothesID: int
        local hasGroup: bool
        container->GetItem(clothes, clothesIndex, ClothesCategory)
        clothes->GetItemID(clothesID)
        native.HasInvItemProperty(hasGroup, clothesID, "Group")
        if hasGroup then
          local group: int
          native.GetInvItemProperty(group, clothesID, "Group")
          if group >= 1 && group <= 4 then
            categoryCache->set(group, ClothesCategory)
            indexCache->set(group, clothesIndex)
          end
        end
      end
    end
  end

  function PlayerEquipmentGetCachedCategory(cache: int) -> int
    local category: int = -1
    categoryCache->get(category, cache)
    return category
  end

  function PlayerEquipmentGetCachedIndex(cache: int) -> int
    local index: int = -1
    indexCache->get(index, cache)
    return index
  end

  function ResolveTarget(target: int) -> int
    local container: object = inv_overhaul_inventory_items.ItemsGetPlayerContainer()
    if target == inv_overhaul_inventory_protocol.TargetWeapon then
      local weaponCount: int
      container->GetItemCount(weaponCount, WeaponCategory)
      for index = 0, weaponCount - 1 do
        local selected: bool
        container->IsItemSelected(selected, index, WeaponCategory)
        if selected then
          local item: object
          container->GetItem(item, index, WeaponCategory)
          local itemID: int
          item->GetItemID(itemID)
          local hasWeapon: bool
          native.HasInvItemProperty(hasWeapon, itemID, "Weapon")
          if hasWeapon then
            return inv_overhaul_inventory_items.ItemsEncodeReference(WeaponCategory, index)
          end
        end
      end
      return -1
    end

    if target <= inv_overhaul_inventory_protocol.TargetClothesBase ||
      target > inv_overhaul_inventory_protocol.TargetClothesBase + 4 then return -1 end
    local requiredGroup: int = target - inv_overhaul_inventory_protocol.TargetClothesBase
    local clothesCount: int
    container->GetItemCount(clothesCount, ClothesCategory)
    for index = 0, clothesCount - 1 do
      local selected: bool
      container->IsItemSelected(selected, index, ClothesCategory)
      if selected then
        local item: object
        container->GetItem(item, index, ClothesCategory)
        local itemID: int
        item->GetItemID(itemID)
        local hasGroup: bool
        native.HasInvItemProperty(hasGroup, itemID, "Group")
        if hasGroup then
          local group: int
          native.GetInvItemProperty(group, itemID, "Group")
          if group == requiredGroup then
            return inv_overhaul_inventory_items.ItemsEncodeReference(ClothesCategory, index)
          end
        end
      end
    end
    return -1
  end

  function Unequip(category: int, index: int) -> bool
    if category != WeaponCategory && category != ClothesCategory then return false end
    local container: object = inv_overhaul_inventory_items.ItemsGetPlayerContainer()
    local selected: bool
    container->IsItemSelected(selected, index, category)
    if !selected then return false end
    container->SelectItem(index, false, category)
    if category == WeaponCategory then native.SetPlayerHandsItem(-1) end
    return true
  end

  function Equip(target: int, category: int, index: int) -> bool
    local container: object = inv_overhaul_inventory_items.ItemsGetPlayerContainer()
    local item: object
    container->GetItem(item, index, category)
    if !item then return false end
    local itemID: int
    item->GetItemID(itemID)

    if target == inv_overhaul_inventory_protocol.TargetWeapon then
      if category != WeaponCategory then return false end
      local hasWeapon: bool
      native.HasInvItemProperty(hasWeapon, itemID, "Weapon")
      if !hasWeapon then return false end
      native.SetPlayerHandsItem(itemID)
      local count: int
      container->GetItemCount(count, WeaponCategory)
      for otherIndex = 0, count - 1 do
        local otherSelected: bool
        container->IsItemSelected(otherSelected, otherIndex, WeaponCategory)
        if otherSelected then container->SelectItem(otherIndex, false, WeaponCategory) end
      end
      container->SelectItem(index, true, WeaponCategory)
      return true
    end

    if target <= inv_overhaul_inventory_protocol.TargetClothesBase ||
      target > inv_overhaul_inventory_protocol.TargetClothesBase + 4 then return false end
    if category != ClothesCategory then return false end
    local hasGroup: bool
    native.HasInvItemProperty(hasGroup, itemID, "Group")
    if !hasGroup then return false end
    local group: int
    native.GetInvItemProperty(group, itemID, "Group")
    if target != inv_overhaul_inventory_protocol.TargetClothesBase + group then return false end

    local count: int
    container->GetItemCount(count, ClothesCategory)
    for otherIndex = 0, count - 1 do
      local other: object
      container->GetItem(other, otherIndex, ClothesCategory)
      local otherID: int
      other->GetItemID(otherID)
      local otherHasGroup: bool
      native.HasInvItemProperty(otherHasGroup, otherID, "Group")
      if otherHasGroup then
        local otherGroup: int
        native.GetInvItemProperty(otherGroup, otherID, "Group")
        if otherGroup == group then container->SelectItem(otherIndex, false, ClothesCategory) end
      end
    end
    container->SelectItem(index, true, ClothesCategory)
    return true
  end

  function PlayerEquipmentToggle(category: int, index: int) -> int
    local container: object = inv_overhaul_inventory_items.ItemsGetPlayerContainer()
    local item: object
    container->GetItem(item, index, category)
    local itemID: int
    item->GetItemID(itemID)
    local amount: int
    container->GetItemAmount(amount, index, category)
    local selected: bool
    container->IsItemSelected(selected, index, category)

    if category == WeaponCategory then
      local hasWeapon: bool
      native.HasInvItemProperty(hasWeapon, itemID, "Weapon")
      if !hasWeapon then return 0 end
      if selected then
        container->SelectItem(index, false, category)
        native.SetPlayerHandsItem(-1)
      else
        native.SetPlayerHandsItem(itemID)
        local count: int
        container->GetItemCount(count, category)
        for otherIndex = 0, count - 1 do
          local otherSelected: bool
          container->IsItemSelected(otherSelected, otherIndex, category)
          if otherSelected then container->SelectItem(otherIndex, false, category) end
        end
        container->SelectItem(index, true, category)
      end
      return 1
    end

    if category == ClothesCategory then
      local hasGroup: bool
      native.HasInvItemProperty(hasGroup, itemID, "Group")
      if !hasGroup then return 0 end
      local group: int
      native.GetInvItemProperty(group, itemID, "Group")
      if selected then
        container->SelectItem(index, false, category)
      else
        local count: int
        container->GetItemCount(count, category)
        for otherIndex = 0, count - 1 do
          local otherSelected: bool
          container->IsItemSelected(otherSelected, otherIndex, category)
          if otherSelected then
            local other: object
            container->GetItem(other, otherIndex, category)
            local otherID: int
            other->GetItemID(otherID)
            local otherHasGroup: bool
            native.HasInvItemProperty(otherHasGroup, otherID, "Group")
            if otherHasGroup then
              local otherGroup: int
              native.GetInvItemProperty(otherGroup, otherID, "Group")
              if otherGroup == group then container->SelectItem(otherIndex, false, category) end
            end
          end
        end
        container->SelectItem(index, true, category)
      end
      return 1
    end

    local used: bool
    native.UseItem(index, category, used)
    if !used then return 0 end
    amount = amount - 1
    if amount == 0 then
      container->RemoveItem(index, 1, category)
    else
      container->SetItemAmount(amount, index, category)
    end
    return 2
  end

  function PlayerEquipmentIsTargetCompatible(
    target: int,
    category: int,
    isWeapon: bool,
    group: int) -> bool
    if target == inv_overhaul_inventory_protocol.TargetDrop then return true end
    if target == inv_overhaul_inventory_protocol.TargetWeapon then
      return category == WeaponCategory && isWeapon
    end
    if target > inv_overhaul_inventory_protocol.TargetClothesBase &&
      target <= inv_overhaul_inventory_protocol.TargetClothesBase + 4 then
      return category == ClothesCategory && target == inv_overhaul_inventory_protocol.TargetClothesBase + group
    end
    return false
  end
end
