import "inv_overhaul_quickslot_activation"
import "inv_overhaul_quickslot_consumables"
import "inv_overhaul_quickslot_equipment"
import "inv_overhaul_quickslot_hands"

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
    return inv_overhaul_quickslot_activation.ActivationGetPlayer()
  end

  function GetItemVariable(slot: int) -> string
    return inv_overhaul_quickslot_activation.ActivationItemVariable(slot)
  end

  function GetCategoryVariable(slot: int) -> string
    return inv_overhaul_quickslot_activation.ActivationCategoryVariable(slot)
  end

  function GetOccurrenceVariable(slot: int) -> string
    return inv_overhaul_quickslot_activation.ActivationOccurrenceVariable(slot)
  end

  function GetDepletedVariable(slot: int) -> string
    return inv_overhaul_quickslot_activation.ActivationDepletedVariable(slot)
  end

  function ClearBinding(slot: int) -> void
    inv_overhaul_quickslot_activation.ClearBinding(slot)
  end

  function ShowMessage(textID: int) -> void
    inv_overhaul_quickslot_activation.ShowMessage(textID)
  end

  function ShowFeedback(itemID: int) -> void
    inv_overhaul_quickslot_activation.ShowFeedback(itemID)
  end

  function MarkInventoryChanged() -> void
    inv_overhaul_quickslot_activation.MarkInventoryChanged()
  end

  function PublishRemovalHint(category: int, index: int) -> void
    inv_overhaul_quickslot_activation.PublishRemovalHint(
      category, index)
  end

  function GetUseEffect(itemID: int) -> string
    return inv_overhaul_quickslot_consumables.GetUseEffect(itemID)
  end

  function IsEquippable(category: int, itemID: int) -> bool
    return inv_overhaul_quickslot_activation.IsEquippable(
      category, itemID)
  end

  function FindBoundItemIndex(
    category: int,
    itemID: int,
    wantedOccurrence: int
  ) -> int
    return inv_overhaul_quickslot_activation.FindBoundItemIndex(
      category, itemID, wantedOccurrence)
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
    inv_overhaul_quickslot_hands.AdjustBindingsAfterDrop(
      itemID, occurrence)
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
    inv_overhaul_quickslot_equipment.EquipmentPolicyToggle(
      category, index, itemID, occurrence, selected)
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

  function Activate(slot: int) -> void
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
    inv_overhaul_quickslot_activation.InitializePersistentState()
    native.SetVariable("inv_overhaul_quickslot_diag_active", 0)
    native.SetVariable("inv_overhaul_handcombat_request", 0)
    UpdateTrackedWeapon(0)
    native.Trace("INV_OVERHAUL_EFFECT_LIFECYCLE quickslots start generation=" + m_iEffectGeneration)
    native.Trace("INV_OVERHAUL_QUICKSLOT_PLAYER_EFFECT_VERSION 2026.08.21-equipment-layout-hint-1")
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
          if request <= c_iQuickslotCount then Activate(request) end
        end
      end
      UpdateTrackedWeapon(delta)
    end
  end
end
