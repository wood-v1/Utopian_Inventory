maintask TEffect do
  local const c_iCWeapon: int = 0
  local const c_iCClothes: int = 1
  local const c_iCategoryCount: int = 5
  local const c_iInventoryCapacity: int = 56
  local const c_iSnapshotVersion: int = 1
  local const c_iOverflowQueueSize: int = 64
  local const c_iWMHelpMessage: int = 200
  local const c_iInventoryFullTextID: int = 1400
  local const c_iQuickslotMissingTextID: int = 1405
  local const c_iQuickslotUnusableTextID: int = 1406
  local const c_iQuickslotCount: int = 10
  local const c_iWMQuickslotFeedback: int = 260
  local const c_iWMQuickslotHandsItem: int = 261
  local const c_iWMPlayerAddItem: int = 3
  local const c_fTickDelay: float = 0.05
  local const c_fMessageCooldown: float = 1.0

  local m_iAllowedSlots: int
  local m_iQueueRead: int
  local m_iQueueWrite: int
  local m_iQueueCount: int
  local m_QueueID1: object
  local m_QueueID2: object
  local m_QueueCategory: object
  local m_CategoryCounts: object
  local m_fMessageCooldown: float
  local m_bResolvingOverflow: bool

  function GetPlayer() -> object
    local player: object
    native.self(player)
    return player
  end

  function IsEquippedItem(category: int, index: int) -> bool
    if category != c_iCWeapon && category != c_iCClothes then return false end

    local selected: bool
    local player: object = GetPlayer()
    player->IsItemSelected(selected, index, category)
    if !selected then return false end

    local item: object
    player->GetItem(item, index, category)
    local itemID: int
    item->GetItemID(itemID)

    if category == c_iCWeapon then
      local weapon: bool
      native.HasInvItemProperty(weapon, itemID, "Weapon")
      return weapon
    end

    local group: bool
    native.HasInvItemProperty(group, itemID, "Group")
    return group
  end

  function GetBackpackItemCount() -> int
    local player: object = GetPlayer()
    local total: int = 0
    for category = 0, c_iCategoryCount - 1 do
      local count: int
      player->GetItemCount(count, category)
      for index = 0, count - 1 do
        if !IsEquippedItem(category, index) then total = total + 1 end
      end
    end
    return total
  end

  function GetBackpackOrdinal(targetCategory: int, targetIndex: int) -> int
    local player: object = GetPlayer()
    local ordinal: int = 0
    for category = 0, c_iCategoryCount - 1 do
      local count: int
      player->GetItemCount(count, category)
      for index = 0, count - 1 do
        if !IsEquippedItem(category, index) then
          if category == targetCategory && index == targetIndex then return ordinal end
          ordinal = ordinal + 1
        end
      end
    end
    return -1
  end

  function PublishBackpackRemovalHint(category: int, index: int) -> void
    local ordinal: int = GetBackpackOrdinal(category, index)
    if ordinal < 0 then return end
    native.SetVariable("utopian_inventory_removed_ordinal_hint", ordinal)
    native.SetVariable("utopian_inventory_removed_ordinal_old_count", GetBackpackItemCount())
    native.SetVariable("utopian_inventory_removed_ordinal_valid", 1)
    native.Trace("utopian_quickslot removal hint ordinal=" + ordinal +
      " category=" + category + " index=" + index)
  end

  function GetCategoryBackpackBase(targetCategory: int) -> int
    local player: object = GetPlayer()
    local ordinal: int = 0
    for category = 0, targetCategory - 1 do
      local count: int
      player->GetItemCount(count, category)
      for index = 0, count - 1 do
        if !IsEquippedItem(category, index) then ordinal = ordinal + 1 end
      end
    end
    return ordinal
  end

  function RemapPublishedLayout(category: int, count: int) -> void
    local initialized: int = 0
    local layoutVersion: int = 0
    native.GetVariable("utopian_inventory_layout_initialized", initialized)
    native.GetVariable("utopian_inventory_layout_version", layoutVersion)
    if initialized != 1 || layoutVersion != 4 then return end

    local base: int = GetCategoryBackpackBase(category)
    for cell = 0, c_iInventoryCapacity - 1 do
      local variableName: string = "utopian_inventory_cell_" + cell
      local oldOrder: int = -1
      native.GetVariable(variableName, oldOrder)
      if oldOrder >= base && oldOrder < base + count then
        local mappedIndex: int = -1
        local mapName: string = "utopian_special_inventory_map_" + category + "_" + (oldOrder - base)
        native.GetVariable(mapName, mappedIndex)
        if mappedIndex >= 0 then native.SetVariable(variableName, base + mappedIndex) end
      end
    end
  end

  function ProcessSpecialInventoryRemap() -> void
    local request: int = 0
    native.GetVariable("utopian_special_inventory_remap_request", request)
    if request != 1 then return end
    native.SetVariable("utopian_special_inventory_remap_request", 0)

    local mask: int = 0
    native.GetVariable("utopian_special_inventory_remap_mask", mask)
    local generation: int = 0
    native.GetVariable("utopian_inventory_reorder_generation", generation)
    native.SetVariable("utopian_inventory_reorder_generation", generation + 1)
    native.Trace("utopian_inventory_guard special reorder published mask=" + mask +
      " generation=" + (generation + 1))
  end

  function GetSnapshotVariableName(ordinal: int) -> string
    return "utopian_inventory_snapshot_" + ordinal
  end

  function InitializePersistentSnapshotIfMissing() -> void
    local valid: int = 0
    local version: int = 0
    native.GetVariable("utopian_inventory_snapshot_valid", valid)
    native.GetVariable("utopian_inventory_snapshot_version", version)
    if valid == 1 && version == c_iSnapshotVersion then return end

    local player: object = GetPlayer()
    local ordinal: int = 0
    for category = 0, c_iCategoryCount - 1 do
      local count: int
      player->GetItemCount(count, category)
      for index = 0, count - 1 do
        if !IsEquippedItem(category, index) then
          if ordinal < c_iInventoryCapacity then
            local item: object
            local itemID: int = -1
            player->GetItem(item, index, category)
            if item then item->GetItemID(itemID) end
            native.SetVariable(GetSnapshotVariableName(ordinal), itemID)
          end
          ordinal = ordinal + 1
        end
      end
    end
    local storedCount: int = ordinal
    if storedCount > c_iInventoryCapacity then storedCount = c_iInventoryCapacity end
    for emptyOrdinal = storedCount, c_iInventoryCapacity - 1 do
      native.SetVariable(GetSnapshotVariableName(emptyOrdinal), -1)
    end
    native.SetVariable("utopian_inventory_snapshot_count", storedCount)
    native.SetVariable("utopian_inventory_snapshot_version", c_iSnapshotVersion)
    native.SetVariable("utopian_inventory_snapshot_valid", 1)
    native.Trace("utopian_inventory_guard persistent snapshot initialized count=" + storedCount)
  end

  function ShowInventoryFull() -> void
    if m_fMessageCooldown > 0 then return end
    local text: object
    native.CreateIntVector(text)
    text->add(c_iInventoryFullTextID)
    native.SendWorldWndMessage(c_iWMHelpMessage, text)
    m_fMessageCooldown = c_fMessageCooldown
  end

  function ShowQuickslotMessage(textID: int) -> void
    if m_fMessageCooldown > 0 then return end
    local text: object
    native.CreateIntVector(text)
    text->add(textID)
    native.SendWorldWndMessage(c_iWMHelpMessage, text)
    m_fMessageCooldown = c_fMessageCooldown
  end

  function GetQuickslotItemVariable(slot: int) -> string
    return "utopian_quickslot_item_" + slot
  end

  function GetQuickslotCategoryVariable(slot: int) -> string
    return "utopian_quickslot_category_" + slot
  end

  function GetQuickslotDepletedVariable(slot: int) -> string
    return "utopian_quickslot_depleted_" + slot
  end

  function GetQuickslotOccurrenceVariable(slot: int) -> string
    return "utopian_quickslot_occurrence_" + slot
  end

  function ClearQuickslotBinding(slot: int) -> void
    native.SetVariable(GetQuickslotItemVariable(slot), -1)
    native.SetVariable(GetQuickslotCategoryVariable(slot), -1)
    native.SetVariable(GetQuickslotOccurrenceVariable(slot), -1)
    native.SetVariable(GetQuickslotDepletedVariable(slot), 1)
    native.Trace("utopian_quickslot cleared exhausted binding slot=" + slot)
  end

  function ShowQuickslotFeedback(itemID: int) -> void
    local data: object
    native.CreateIntVector(data)
    data->add(itemID)
    data->add(1)
    native.SendWorldWndMessage(c_iWMPlayerAddItem, data)
    native.SendWorldWndMessage(c_iWMQuickslotFeedback, data)
  end

  function SetQuickslotHandsItem(itemID: int) -> void
    local data: object
    native.CreateIntVector(data)
    data->add(itemID)
    native.SendWorldWndMessage(c_iWMQuickslotHandsItem, data)
  end

  function IsQuickslotEquippable(category: int, itemID: int) -> bool
    local property: bool
    if category == c_iCWeapon then
      native.HasInvItemProperty(property, itemID, "Weapon")
      return property
    end
    if category == c_iCClothes then
      native.HasInvItemProperty(property, itemID, "Group")
      return property
    end
    return false
  end

  function GetQuickslotUseEffect(itemID: int) -> string
    if itemID == 0 then return "item_alpha_pills.bin" end
    if itemID == 1 then return "item_beta_pills.bin" end
    if itemID == 2 then return "item_gamma_pills.bin" end
    if itemID == 3 then return "item_delta_pills.bin" end
    if itemID == 4 then return "item_black_vaccine.bin" end
    if itemID == 5 then return "item_blue_vaccine.bin" end
    if itemID == 6 then return "item_white_vaccine.bin" end
    if itemID == 7 then return "item_tvirin.bin" end
    if itemID == 8 then return "item_lemon.bin" end
    if itemID == 9 then return "item_powder.bin" end
    if itemID == 10 then return "item_burah_serum.bin" end
    if itemID == 11 then return "item_neomicin.bin" end
    if itemID == 12 then return "item_monomicin.bin" end
    if itemID == 13 then return "item_feromicin.bin" end
    if itemID == 14 then return "item_meradorm.bin" end
    if itemID == 15 then return "item_novocaine.bin" end
    if itemID == 16 then return "item_morfin.bin" end
    if itemID == 17 then return "item_etorfin.bin" end
    if itemID == 18 then return "item_bottle_water.bin" end
    if itemID == 19 then return "item_funduk.bin" end
    if itemID == 20 then return "item_peanut.bin" end
    if itemID == 21 then return "item_walnut.bin" end
    if itemID == 22 then return "item_rusk.bin" end
    if itemID == 23 then return "item_dried_fish.bin" end
    if itemID == 24 then return "item_egg.bin" end
    if itemID == 25 then return "item_vegetables.bin" end
    if itemID == 26 then return "item_milk.bin" end
    if itemID == 27 then return "item_dried_meat.bin" end
    if itemID == 28 then return "item_smoked_meat.bin" end
    if itemID == 29 then return "item_fresh_fish.bin" end
    if itemID == 30 then return "item_fresh_meat.bin" end
    if itemID == 31 then return "item_bandage.bin" end
    if itemID == 32 then return "item_tourniquet.bin" end
    if itemID == 33 then return "item_packet.bin" end
    if itemID == 34 then return "item_bread.bin" end
    if itemID == 71 then return "item_coffee.bin" end
    return ""
  end

  function ClampQuickslotProperty(value: float) -> float
    if value < 0 then return 0 end
    if value > 1 then return 1 end
    return value
  end

  function ApplyQuickslotPropertyDelta(player: object, name: string, delta: float) -> void
    local value: float
    player->GetProperty(name, value)
    player->SetProperty(name, ClampQuickslotProperty(value + delta))
  end

  function UseQuickslotSpecialItem(
    player: object,
    category: int,
    index: int,
    itemID: int,
    amountBefore: int
  ) -> bool
    if itemID == 42 then
      local visir: int
      player->GetProperty("visir", visir)
      if visir == 0 || visir >= 4 then return false end
      player->SetProperty("visir", visir + 1)
      if amountBefore <= 1 then PublishBackpackRemovalHint(category, index) end
      player->RemoveItem(index, 1, category)
      return true
    end

    local item: object
    player->GetItem(item, index, category)
    if !item then return false end

    if itemID == 55 then
      local healthDelta: float
      local immunityDelta: float
      item->GetProperty("hl_inc", healthDelta)
      item->GetProperty("im_inc", immunityDelta)
      ApplyQuickslotPropertyDelta(player, "health", healthDelta)
      ApplyQuickslotPropertyDelta(player, "immunity", immunityDelta)
      if amountBefore <= 1 then PublishBackpackRemovalHint(category, index) end
      player->RemoveItem(index, 1, category)
      return true
    end

    if itemID == 72 then
      local diseaseRate: float
      local healthDelta: float
      item->GetProperty("DiseaseRate", diseaseRate)
      item->GetProperty("HealthIncrease", healthDelta)
      ApplyQuickslotPropertyDelta(player, "health", healthDelta)
      local disease: float
      player->GetProperty("disease", disease)
      player->SetProperty("disease", ClampQuickslotProperty(disease * diseaseRate))
      if amountBefore <= 1 then PublishBackpackRemovalHint(category, index) end
      player->RemoveItem(index, 1, category)
      return true
    end
    return false
  end

  function FindQuickslotItem(
    category: int,
    itemID: int,
    occurrence: int,
    index: int,
    selected: bool
  ) -> bool
    index = -1
    selected = false
    if category < 0 || category >= c_iCategoryCount || itemID < 0 || occurrence < 0 then
      return false
    end

    local player: object = GetPlayer()
    local count: int
    local currentOccurrence: int = 0
    player->GetItemCount(count, category)
    for candidate = 0, count - 1 do
      local item: object
      local candidateID: int
      player->GetItem(item, candidate, category)
      if item then
        item->GetItemID(candidateID)
        if candidateID == itemID then
          if currentOccurrence == occurrence then
            player->IsItemSelected(selected, candidate, category)
            index = candidate
            return true
          end
          currentOccurrence = currentOccurrence + 1
        end
      end
    end
    return false
  end

  function ToggleQuickslotEquipment(category: int, index: int, itemID: int, selected: bool) -> void
    local player: object = GetPlayer()
    if category == c_iCWeapon then
      local activeWeapon: int = -1
      native.GetVariable("utopian_quickslot_active_weapon", activeWeapon)
      local shouldUnequip: bool = selected || activeWeapon == itemID
      native.Trace("utopian_quickslot weapon toggle item=" + itemID +
        " selected=" + selected + " tracked=" + activeWeapon +
        " unequip=" + shouldUnequip)

      if shouldUnequip then
        if GetBackpackItemCount() >= c_iInventoryCapacity then
          ShowInventoryFull()
          return
        end
        player->SelectItem(index, false, category)
        SetQuickslotHandsItem(-1)
        native.SetVariable("utopian_quickslot_active_weapon", -1)
        local generation: int = 0
        native.GetVariable("utopian_inventory_reorder_generation", generation)
        native.SetVariable("utopian_inventory_reorder_generation", generation + 1)
        native.Trace("utopian_quickslot unequipped weapon item=" + itemID)
        ShowQuickslotFeedback(itemID)
        return
      end

      local count: int
      player->GetItemCount(count, category)
      for other = 0, count - 1 do player->SelectItem(other, false, category) end
      player->SelectItem(index, true, category)
      SetQuickslotHandsItem(itemID)
      native.SetVariable("utopian_quickslot_active_weapon", itemID)
      local generation: int = 0
      native.GetVariable("utopian_inventory_reorder_generation", generation)
      native.SetVariable("utopian_inventory_reorder_generation", generation + 1)
      native.Trace("utopian_quickslot equipped weapon item=" + itemID)
      ShowQuickslotFeedback(itemID)
      return
    end

    if selected then
      if GetBackpackItemCount() >= c_iInventoryCapacity then
        ShowInventoryFull()
        return
      end
      player->SelectItem(index, false, category)
      native.Trace("utopian_quickslot unequipped category=" + category + " item=" + itemID)
      ShowQuickslotFeedback(itemID)
      return
    end

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
    player->SelectItem(index, true, category)
    native.Trace("utopian_quickslot equipped clothes item=" + itemID + " group=" + group)
    ShowQuickslotFeedback(itemID)
  end

  function UseQuickslotConsumable(slot: int, category: int, index: int, itemID: int) -> void
    local player: object = GetPlayer()
    local amountBefore: int
    player->GetItemAmount(amountBefore, index, category)
    if itemID == 42 || itemID == 55 || itemID == 72 then
      local specialUsed: bool = UseQuickslotSpecialItem(player, category, index, itemID, amountBefore)
      native.Trace("utopian_quickslot special use result=" + specialUsed +
        " category=" + category + " index=" + index + " item=" + itemID)
      if !specialUsed then
        ShowQuickslotMessage(c_iQuickslotUnusableTextID)
      else
        ShowQuickslotFeedback(itemID)
        if amountBefore <= 1 then ClearQuickslotBinding(slot) end
      end
      return
    end

    local effect: string = GetQuickslotUseEffect(itemID)
    if effect == "" then
      native.Trace("utopian_quickslot item has no use effect item=" + itemID)
      ShowQuickslotMessage(c_iQuickslotUnusableTextID)
      return
    end
    local amount: int = amountBefore
    native.Trace("utopian_quickslot consume amount before=" + amountBefore +
      " category=" + category + " index=" + index + " item=" + itemID)
    amount = amount - 1
    if amount <= 0 then
      PublishBackpackRemovalHint(category, index)
      player->RemoveItem(index, 1, category)
      ClearQuickslotBinding(slot)
    else
      player->SetItemAmount(amount, index, category)
    end
    local verifiedAmount: int = 0
    if amount > 0 then player->GetItemAmount(verifiedAmount, index, category) end
    native.Trace("utopian_quickslot consume committed expected=" + amount +
      " actual=" + verifiedAmount + " category=" + category + " item=" + itemID)

    player->ApplyEffect(effect)
    native.Trace("utopian_quickslot applied effect after consume=" + effect +
      " category=" + category + " item=" + itemID)
    ShowQuickslotFeedback(itemID)
  end

  function ProcessQuickslotRequest() -> void
    local slot: int = 0
    native.GetVariable("utopian_quickslot_request", slot)
    if slot <= 0 then return end
    native.SetVariable("utopian_quickslot_request", 0)
    if slot > c_iQuickslotCount then
      return
    end
    native.SetVariable("utopian_quickslot_action_request", slot)
    native.Trace("utopian_quickslot guard opening inventory-context UI runtime slot=" + slot)
    native.ShowWindow("inventory.xml", false)
  end

  function EnqueueOverflow(index: int, itemID: int, category: int) -> void
    if m_iQueueCount >= c_iOverflowQueueSize then
      native.Trace("utopian_inventory_guard overflow queue full")
      return
    end
    m_QueueID1->set(m_iQueueWrite, index)
    m_QueueID2->set(m_iQueueWrite, itemID)
    m_QueueCategory->set(m_iQueueWrite, category)
    m_iQueueWrite = m_iQueueWrite + 1
    if m_iQueueWrite >= c_iOverflowQueueSize then m_iQueueWrite = 0 end
    m_iQueueCount = m_iQueueCount + 1
  end

  function DropOverflowItem(index: int, itemID: int, category: int) -> bool
    if category < 0 || category >= c_iCategoryCount then return false end

    local player: object = GetPlayer()
    local count: int
    player->GetItemCount(count, category)
    if index < 0 || index >= count || IsEquippedItem(category, index) then return false end

    local item: object
    local amount: int
    player->GetItem(item, index, category)
    player->GetItemAmount(amount, index, category)
    if !item || amount <= 0 then return false end
    local currentItemID: int
    item->GetItemID(currentItemID)
    if currentItemID != itemID then return false end

    player->DropItems(item, amount)
    player->RemoveItem(index, amount, category)
    player->GetItemCount(count, category)
    m_CategoryCounts->set(category, count)
    native.Trace("utopian_inventory_guard dropped new item index=" + index + " item=" + itemID + " category=" + category)
    return true
  end

  function ProcessOverflowQueue() -> void
    if m_iQueueCount <= 0 then return end

    m_bResolvingOverflow = true
    local dropped: bool = false
    while m_iQueueCount > 0 do
      m_iQueueCount = m_iQueueCount - 1
      m_iQueueWrite = m_iQueueCount
      local index: int
      local itemID: int
      local category: int
      m_QueueID1->get(index, m_iQueueCount)
      m_QueueID2->get(itemID, m_iQueueCount)
      m_QueueCategory->get(category, m_iQueueCount)

      if GetBackpackItemCount() > m_iAllowedSlots then
        if DropOverflowItem(index, itemID, category) then
          dropped = true
        else
          native.Trace("utopian_inventory_guard new overflow item not found index=" + index + " item=" + itemID + " category=" + category)
        end
      end
    end
    m_bResolvingOverflow = false
    if dropped then ShowInventoryFull() end
  end

  function init() -> void
    native.CreateIntVector(m_QueueID1)
    native.CreateIntVector(m_QueueID2)
    native.CreateIntVector(m_QueueCategory)
    native.CreateIntVector(m_CategoryCounts)
    for i = 0, c_iOverflowQueueSize - 1 do
      m_QueueID1->add(-1)
      m_QueueID2->add(-1)
      m_QueueCategory->add(-1)
    end
    m_iQueueRead = 0
    m_iQueueWrite = 0
    m_iQueueCount = 0
    m_bResolvingOverflow = false
    m_fMessageCooldown = 0
    local player: object = GetPlayer()
    for category = 0, c_iCategoryCount - 1 do
      local categoryCount: int
      player->GetItemCount(categoryCount, category)
      m_CategoryCounts->add(categoryCount)
    end
    m_iAllowedSlots = GetBackpackItemCount()
    if m_iAllowedSlots < c_iInventoryCapacity then m_iAllowedSlots = c_iInventoryCapacity end
    InitializePersistentSnapshotIfMissing()
    native.SetVariable("utopian_special_inventory_remap_request", 0)
    native.SetVariable("utopian_quickslot_request", 0)
    local quickslotStateVersion: int = 0
    native.GetVariable("utopian_quickslot_state_version", quickslotStateVersion)
    if quickslotStateVersion != 2 then
      native.SetVariable("utopian_quickslot_active_weapon", -1)
      for slot = 1, c_iQuickslotCount do
        native.SetVariable(GetQuickslotDepletedVariable(slot), 0)
        local occurrence: int = 0
        native.GetVariable(GetQuickslotOccurrenceVariable(slot), occurrence)
        if occurrence < 0 then native.SetVariable(GetQuickslotOccurrenceVariable(slot), 0) end
      end
      native.SetVariable("utopian_quickslot_state_version", 2)
    end
    native.Trace("UTOPIAN_INVENTORY_GUARD_VERSION 2026.07.30-quickslots-feedback-6 allowed=" + m_iAllowedSlots)

    while true do
      local delta: float
      native.sync(delta)
      if m_fMessageCooldown > 0 then
        m_fMessageCooldown = m_fMessageCooldown - delta
        if m_fMessageCooldown < 0 then m_fMessageCooldown = 0 end
      end
      ProcessSpecialInventoryRemap()
      ProcessOverflowQueue()
    end
  end

  function OnInventoryAddItem(item: object, id1: int, id2: int, category: int) -> void
    if m_bResolvingOverflow then return end
    if category < 0 || category >= c_iCategoryCount then return end
    local previousCount: int
    local currentCount: int
    local player: object = GetPlayer()
    m_CategoryCounts->get(previousCount, category)
    player->GetItemCount(currentCount, category)
    m_CategoryCounts->set(category, currentCount)
    local quickslotDiag: int = 0
    native.GetVariable("utopian_quickslot_diag_active", quickslotDiag)
    if quickslotDiag == 1 then
      local addedItemID: int = -1
      if item then item->GetItemID(addedItemID) end
      native.Trace("utopian_quickslot diag OnInventoryAddItem category=" +
        category + " item=" + addedItemID + " previousCount=" +
        previousCount + " currentCount=" + currentCount)
    end
    if GetBackpackItemCount() > m_iAllowedSlots && currentCount > previousCount then
      local itemID: int
      item->GetItemID(itemID)
      EnqueueOverflow(currentCount - 1, itemID, category)
      native.Trace("utopian_inventory_guard queued new overflow item index=" + (currentCount - 1) + " item=" + itemID + " category=" + category)
    end
  end

  function OnInventoryRemoveItem(item: object, id1: int, id2: int, category: int) -> void
    if m_bResolvingOverflow then return end
    if category >= 0 && category < c_iCategoryCount then
      local categoryCount: int
      local player: object = GetPlayer()
      player->GetItemCount(categoryCount, category)
      m_CategoryCounts->set(category, categoryCount)
      local quickslotDiag: int = 0
      native.GetVariable("utopian_quickslot_diag_active", quickslotDiag)
      if quickslotDiag == 1 then
        local removedItemID: int = -1
        if item then item->GetItemID(removedItemID) end
        native.Trace("utopian_quickslot diag OnInventoryRemoveItem category=" +
          category + " item=" + removedItemID +
          " currentCount=" + categoryCount)
      end
    end
    local count: int = GetBackpackItemCount()
    if count < m_iAllowedSlots then
      m_iAllowedSlots = count
      if m_iAllowedSlots < c_iInventoryCapacity then m_iAllowedSlots = c_iInventoryCapacity end
    end
  end
end
