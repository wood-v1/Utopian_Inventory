maintask InvOverhaulQuickslotPlayerEffect do
  local const c_iCWeapon: int = 0
  local const c_iCClothes: int = 1
  local const c_iCategoryCount: int = 5
  local const c_iQuickslotCount: int = 10
  local const c_iInventoryCapacity: int = 56
  local const c_iWMHelpMessage: int = 200
  local const c_iWMPlayerAddItem: int = 3
  local const c_iInventoryFullTextID: int = 1400
  local const c_iQuickslotMissingTextID: int = 1405
  local const c_iQuickslotUnusableTextID: int = 1406
  local const c_fRequestPollDelay: float = 0.05

  local m_bPendingConsumption: bool
  local m_iPendingSlot: int
  local m_iPendingCategory: int
  local m_iPendingItemID: int
  local m_iPendingOccurrence: int
  local m_iPendingAmountBefore: int
  local m_bPendingVerification: bool
  local m_fVerificationDelay: float
  local m_iVerificationCategory: int
  local m_iVerificationItemID: int
  local m_iVerificationSlot: int
  local m_fRequestPollCooldown: float
  local m_iEffectGeneration: int
  local m_bTrackedWeaponSelected: bool
  local m_iTrackedWeaponID: int
  local m_iTrackedWeaponOccurrence: int
  local m_bPendingHandsDrop: bool
  local m_iPendingHandsDropItemID: int
  local m_iPendingHandsDropOccurrence: int
  local m_fPendingHandsDropDelay: float
  local m_fPendingHandsDropTimeout: float
  local m_bPendingHandsDropWasHolstered: bool
  local m_fTrackedWeaponGrace: float

  function GetPlayer() -> object
    local player: object
    native.self(player)
    return player
  end

  function GetItemVariable(slot: int) -> string
    return "inv_overhaul_quickslot_item_" + slot
  end

  function GetCategoryVariable(slot: int) -> string
    return "inv_overhaul_quickslot_category_" + slot
  end

  function GetOccurrenceVariable(slot: int) -> string
    return "inv_overhaul_quickslot_occurrence_" + slot
  end

  function GetDepletedVariable(slot: int) -> string
    return "inv_overhaul_quickslot_depleted_" + slot
  end

  function ClearBinding(slot: int) -> void
    native.SetVariable(GetItemVariable(slot), -1)
    native.SetVariable(GetCategoryVariable(slot), -1)
    native.SetVariable(GetOccurrenceVariable(slot), -1)
    native.SetVariable(GetDepletedVariable(slot), 1)
  end

  function ShowMessage(textID: int) -> void
    local data: object
    native.CreateIntVector(data)
    data->add(textID)
    native.SendWorldWndMessage(c_iWMHelpMessage, data)
  end

  function ShowFeedback(itemID: int) -> void
    local data: object
    native.CreateIntVector(data)
    data->add(itemID)
    data->add(1)
    native.SendWorldWndMessage(c_iWMPlayerAddItem, data)
  end

  function MarkInventoryChanged() -> void
    local generation: int = 0
    native.GetVariable("inv_overhaul_inventory_reorder_generation", generation)
    native.SetVariable("inv_overhaul_inventory_reorder_generation", generation + 1)
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

  function PublishRemovalHint(category: int, index: int) -> void
    local ordinal: int = GetBackpackOrdinal(category, index)
    if ordinal < 0 then return end
    native.SetVariable("inv_overhaul_inventory_removed_ordinal_hint", ordinal)
    native.SetVariable("inv_overhaul_inventory_removed_ordinal_old_count", GetBackpackItemCount())
    native.SetVariable("inv_overhaul_inventory_removed_ordinal_valid", 1)
  end

  function GetUseEffect(itemID: int) -> string
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

  function IsEquippable(category: int, itemID: int) -> bool
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

  function IsEquippedItem(category: int, index: int) -> bool
    if category != c_iCWeapon && category != c_iCClothes then return false end
    local player: object = GetPlayer()
    local selected: bool
    player->IsItemSelected(selected, index, category)
    return selected
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

  function FindBoundItemIndex(
    category: int,
    itemID: int,
    wantedOccurrence: int
  ) -> int
    if category < 0 || category >= c_iCategoryCount ||
      itemID < 0 || wantedOccurrence < 0 then return -1 end

    local player: object = GetPlayer()
    local count: int
    local occurrence: int = 0
    player->GetItemCount(count, category)
    for candidate = 0, count - 1 do
      local item: object
      local candidateID: int
      player->GetItem(item, candidate, category)
      if item then
        item->GetItemID(candidateID)
        if candidateID == itemID then
          if occurrence == wantedOccurrence then
            return candidate
          end
          occurrence = occurrence + 1
        end
      end
    end
    return -1
  end

  function UpdateTrackedWeapon(delta: float) -> void
    local player: object = GetPlayer()
    local count: int
    player->GetItemCount(count, c_iCWeapon)
    for index = 0, count - 1 do
      local selected: bool
      player->IsItemSelected(selected, index, c_iCWeapon)
      if selected then
        local item: object
        local itemID: int = -1
        local occurrence: int = 0
        player->GetItem(item, index, c_iCWeapon)
        if !item then return end
        item->GetItemID(itemID)
        for previous = 0, index - 1 do
          local previousItem: object
          local previousID: int = -1
          player->GetItem(previousItem, previous, c_iCWeapon)
          if previousItem then
            previousItem->GetItemID(previousID)
            if previousID == itemID then occurrence = occurrence + 1 end
          end
        end
        m_iTrackedWeaponID = itemID
        m_iTrackedWeaponOccurrence = occurrence
        m_bTrackedWeaponSelected = true
        m_fTrackedWeaponGrace = 0.3
        return
      end
    end
    m_fTrackedWeaponGrace = m_fTrackedWeaponGrace - delta
    if m_fTrackedWeaponGrace <= 0 then
      m_bTrackedWeaponSelected = false
    end
  end

  function AdjustBindingsAfterWeaponDrop(itemID: int, occurrence: int) -> void
    for slot = 1, c_iQuickslotCount do
      local assignedCategory: int = -1
      local assignedItemID: int = -1
      local assignedOccurrence: int = -1
      native.GetVariable(GetCategoryVariable(slot), assignedCategory)
      native.GetVariable(GetItemVariable(slot), assignedItemID)
      native.GetVariable(GetOccurrenceVariable(slot), assignedOccurrence)
      if assignedCategory == c_iCWeapon && assignedItemID == itemID then
        if assignedOccurrence == occurrence then
          ClearBinding(slot)
        else
          if assignedOccurrence > occurrence then
            native.SetVariable(GetOccurrenceVariable(slot), assignedOccurrence - 1)
          end
        end
      end
    end
  end

  function ScheduleHandsDrop() -> void
    if !m_bTrackedWeaponSelected || m_bPendingHandsDrop then
      native.Trace("inv_overhaul_drop_hands ignored no selected weapon")
      return
    end
    m_iPendingHandsDropItemID = m_iTrackedWeaponID
    m_iPendingHandsDropOccurrence = m_iTrackedWeaponOccurrence
    m_fPendingHandsDropDelay = 0.12
    m_fPendingHandsDropTimeout = 0.75
    local wasHolstered: bool
    native.IsWeaponHolstered(wasHolstered)
    m_bPendingHandsDropWasHolstered = wasHolstered
    m_bPendingHandsDrop = true
    m_bTrackedWeaponSelected = false
    native.Trace("inv_overhaul_drop_hands scheduled item=" +
      m_iPendingHandsDropItemID + " occurrence=" +
      m_iPendingHandsDropOccurrence)
  end

  function ProcessPendingHandsDrop(delta: float) -> void
    if !m_bPendingHandsDrop then return end
    m_fPendingHandsDropDelay = m_fPendingHandsDropDelay - delta
    m_fPendingHandsDropTimeout = m_fPendingHandsDropTimeout - delta
    if m_fPendingHandsDropDelay > 0 then return end

    local index: int = FindBoundItemIndex(
      c_iCWeapon,
      m_iPendingHandsDropItemID,
      m_iPendingHandsDropOccurrence)
    if index < 0 then
      m_bPendingHandsDrop = false
      native.Trace("inv_overhaul_drop_hands item vanished before drop item=" +
        m_iPendingHandsDropItemID)
      return
    end

    local player: object = GetPlayer()
    local item: object
    local amount: int
    local selected: bool
    player->GetItem(item, index, c_iCWeapon)
    player->GetItemAmount(amount, index, c_iCWeapon)
    player->IsItemSelected(selected, index, c_iCWeapon)
    if !item || amount <= 0 then
      m_bPendingHandsDrop = false
      return
    end
    local holstered: bool
    native.IsWeaponHolstered(holstered)
    local holsterTransition: bool =
      !m_bPendingHandsDropWasHolstered && holstered
    if selected && !holsterTransition then
      if m_fPendingHandsDropTimeout <= 0 then
        m_bPendingHandsDrop = false
        native.Trace("inv_overhaul_drop_hands cancelled weapon stayed selected item=" +
          m_iPendingHandsDropItemID)
      else
        m_fPendingHandsDropDelay = 0.05
      end
      return
    end

    m_bPendingHandsDrop = false
    PublishRemovalHint(c_iCWeapon, index)
    player->DropItems(item, 1)
    native.Trace("INV_OVERHAUL_QUICKSLOT_NATIVE_HANDS -1")
    if selected then player->SelectItem(index, false, c_iCWeapon) end
    player->RemoveItem(index, 1, c_iCWeapon)
    AdjustBindingsAfterWeaponDrop(
      m_iPendingHandsDropItemID,
      m_iPendingHandsDropOccurrence)
    native.SetVariable("inv_overhaul_quickslot_active_weapon", -1)
    MarkInventoryChanged()
    native.Trace("inv_overhaul_drop_hands completed item=" +
      m_iPendingHandsDropItemID + " index=" + index)
  end

  function ProcessHandCombatRequest() -> void
    local requested: int = 0
    native.GetVariable("inv_overhaul_handcombat_request", requested)
    if requested <= 0 then return end
    native.SetVariable("inv_overhaul_handcombat_request", 0)
    native.Trace("inv_overhaul_drop_hands handcombat action requested")
    ScheduleHandsDrop()
  end

  function TraceInventoryState(tag: string, category: int, targetItemID: int) -> void
    local player: object = GetPlayer()
    local count: int
    local targetEntries: int = 0
    local targetAmount: int = 0
    player->GetItemCount(count, category)
    for index = 0, count - 1 do
      local item: object
      local itemID: int = -1
      local amount: int = 0
      player->GetItem(item, index, category)
      if item then
        item->GetItemID(itemID)
        if itemID == targetItemID then
          targetEntries = targetEntries + 1
          player->GetItemAmount(amount, index, category)
          targetAmount = targetAmount + amount
          native.Trace("inv_overhaul_quickslot diag " + tag +
            " target index=" + index + " amount=" + amount)
        end
      end
    end
    native.Trace("inv_overhaul_quickslot diag " + tag +
      " category=" + category + " count=" + count +
      " targetItem=" + targetItemID + " targetEntries=" + targetEntries +
      " targetAmount=" + targetAmount)
  end

  function ScheduleVerification(slot: int, category: int, itemID: int) -> void
    m_iVerificationSlot = slot
    m_iVerificationCategory = category
    m_iVerificationItemID = itemID
    m_fVerificationDelay = 0.25
    m_bPendingVerification = true
  end

  function ProcessPendingVerification(delta: float) -> void
    if !m_bPendingVerification then return end
    m_fVerificationDelay = m_fVerificationDelay - delta
    if m_fVerificationDelay > 0 then return end
    m_bPendingVerification = false
    TraceInventoryState(
      "delayed slot=" + m_iVerificationSlot,
      m_iVerificationCategory,
      m_iVerificationItemID)
    native.SetVariable("inv_overhaul_quickslot_diag_active", 0)
  end

  function ToggleEquipment(
    category: int,
    index: int,
    itemID: int,
    occurrence: int,
    selected: bool
  ) -> void
    local player: object = GetPlayer()
    if category == c_iCWeapon then
      native.SetVariable("inv_overhaul_quickslot_weapon_item", itemID)
      native.SetVariable("inv_overhaul_quickslot_weapon_occurrence", occurrence)
      player->ApplyEffect("inv_overhaul_quickslot_weapon.bin")
      native.Trace("inv_overhaul_quickslot weapon action dispatched item=" +
        itemID + " occurrence=" + occurrence + " selected=" + selected)
      return
    end

    if selected then
      if GetBackpackItemCount() >= c_iInventoryCapacity then
        ShowMessage(c_iInventoryFullTextID)
        return
      end
      player->SelectItem(index, false, category)
      MarkInventoryChanged()
      ShowFeedback(itemID)
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
    MarkInventoryChanged()
    ShowFeedback(itemID)
  end

  function ProcessPendingConsumption() -> void
    if !m_bPendingConsumption then return end
    m_bPendingConsumption = false

    local index: int = FindBoundItemIndex(
        m_iPendingCategory,
        m_iPendingItemID,
        m_iPendingOccurrence)
    if index < 0 then
      native.Trace("inv_overhaul_quickslot pending item already consumed item=" +
        m_iPendingItemID)
      ClearBinding(m_iPendingSlot)
      MarkInventoryChanged()
      ShowFeedback(m_iPendingItemID)
      return
    end

    local player: object = GetPlayer()
    local amount: int
    player->GetItemAmount(amount, index, m_iPendingCategory)
    TraceInventoryState(
      "before-commit slot=" + m_iPendingSlot,
      m_iPendingCategory,
      m_iPendingItemID)
    if amount >= m_iPendingAmountBefore then amount = amount - 1 end
    if amount <= 0 then
      PublishRemovalHint(m_iPendingCategory, index)
      player->RemoveItem(index, 1, m_iPendingCategory)
      ClearBinding(m_iPendingSlot)
    else
      player->SetItemAmount(amount, index, m_iPendingCategory)
    end
    TraceInventoryState(
      "immediate-after-commit slot=" + m_iPendingSlot,
      m_iPendingCategory,
      m_iPendingItemID)
    native.Trace("inv_overhaul_quickslot pending consume committed slot=" +
      m_iPendingSlot + " category=" + m_iPendingCategory +
      " index=" + index + " item=" + m_iPendingItemID +
      " amountBefore=" + m_iPendingAmountBefore + " amountAfter=" + amount)
    MarkInventoryChanged()
    ShowFeedback(m_iPendingItemID)
    ScheduleVerification(
      m_iPendingSlot,
      m_iPendingCategory,
      m_iPendingItemID)
  end

  function UseConsumable(
    slot: int,
    category: int,
    index: int,
    itemID: int,
    occurrence: int
  ) -> void
    if m_bPendingConsumption then return end
    local effect: string = GetUseEffect(itemID)
    if effect == "" then
      native.Trace("inv_overhaul_quickslot unsupported consumable item=" + itemID)
      ShowMessage(c_iQuickslotUnusableTextID)
      return
    end

    local player: object = GetPlayer()
    local amount: int
    player->GetItemAmount(amount, index, category)
    m_iPendingSlot = slot
    m_iPendingCategory = category
    m_iPendingItemID = itemID
    m_iPendingOccurrence = occurrence
    m_iPendingAmountBefore = amount
    m_bPendingConsumption = true
    native.SetVariable("inv_overhaul_quickslot_diag_active", 1)
    TraceInventoryState("before-effect slot=" + slot, category, itemID)
    player->ApplyEffect(effect)
    TraceInventoryState("immediate-after-effect slot=" + slot, category, itemID)
    native.Trace("inv_overhaul_quickslot player-effect applied=" + effect +
      " slot=" + slot + " category=" + category +
      " index=" + index + " item=" + itemID +
      " amount=" + amount)
  end

  function ActivateQuickslot(slot: int) -> void
    local category: int = -1
    local itemID: int = -1
    local occurrence: int = -1
    native.GetVariable(GetCategoryVariable(slot), category)
    native.GetVariable(GetItemVariable(slot), itemID)
    native.GetVariable(GetOccurrenceVariable(slot), occurrence)
    if category < 0 || itemID < 0 then
      local depleted: int = 0
      native.GetVariable(GetDepletedVariable(slot), depleted)
      if depleted == 1 then ShowMessage(c_iQuickslotMissingTextID) end
      return
    end

    local index: int = FindBoundItemIndex(category, itemID, occurrence)
    if index < 0 then
      ShowMessage(c_iQuickslotMissingTextID)
      return
    end
    local player: object = GetPlayer()
    local selected: bool
    player->IsItemSelected(selected, index, category)

    native.Trace("inv_overhaul_quickslot player-effect activate slot=" + slot +
      " category=" + category + " index=" + index + " item=" + itemID)
    if IsEquippable(category, itemID) then
      ToggleEquipment(category, index, itemID, occurrence, selected)
    else
      UseConsumable(slot, category, index, itemID, occurrence)
    end
  end

  function init() -> void
    m_bPendingConsumption = false
    m_bPendingVerification = false
    m_fRequestPollCooldown = 0
    m_iEffectGeneration = 0
    m_bPendingHandsDrop = false
    m_bTrackedWeaponSelected = false
    m_iTrackedWeaponID = -1
    m_iTrackedWeaponOccurrence = -1
    m_fTrackedWeaponGrace = 0
    native.GetVariable("inv_overhaul_effect_generation", m_iEffectGeneration)
    native.SetVariable("inv_overhaul_quickslot_diag_active", 0)
    native.SetVariable("inv_overhaul_handcombat_request", 0)
    UpdateTrackedWeapon(0)
    native.Trace("INV_OVERHAUL_EFFECT_LIFECYCLE quickslots start generation=" + m_iEffectGeneration)
    native.Trace("INV_OVERHAUL_QUICKSLOT_PLAYER_EFFECT_VERSION 2026.08.12-ready-signal-1")
    while true do
      native.Sleep(c_fRequestPollDelay)
      local currentGeneration: int = 0
      native.GetVariable("inv_overhaul_effect_generation", currentGeneration)
      if currentGeneration != m_iEffectGeneration then
        native.Trace("INV_OVERHAUL_EFFECT_LIFECYCLE quickslots stop generation=" +
          m_iEffectGeneration + " current=" + currentGeneration)
        return
      end
      local delta: float = c_fRequestPollDelay
      ProcessPendingConsumption()
      ProcessPendingVerification(delta)
      ProcessHandCombatRequest()
      ProcessPendingHandsDrop(delta)
      m_fRequestPollCooldown = m_fRequestPollCooldown - delta
      if m_fRequestPollCooldown <= 0 then
        m_fRequestPollCooldown = c_fRequestPollDelay
        local request: int = 0
        native.GetVariable("inv_overhaul_quickslot_request", request)
        if request > 0 then
          native.SetVariable("inv_overhaul_quickslot_request", 0)
          if request <= c_iQuickslotCount then ActivateQuickslot(request) end
        end
      end
      UpdateTrackedWeapon(delta)
    end
  end
end
