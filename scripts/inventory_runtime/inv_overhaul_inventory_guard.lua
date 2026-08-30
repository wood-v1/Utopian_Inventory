import "inv_overhaul_inventory_overflow"
import "inv_overhaul_inventory_stack_consolidation"
import "inv_overhaul_inventory_snapshot_seed"
import "inv_overhaul_special_inventory_bridge"

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
  local m_iEffectGeneration: int
  local m_bResolvingOverflow: bool
  local m_bResolvingStackMerge: bool
  local m_bStackMergePending: bool

  function GetPlayer() -> object
    local player: object
    native.self(player)
    return player
  end

  function GetBackpackItemCount() -> int
    return inv_overhaul_inventory_overflow.OverflowGetBackpackItemCount()
  end

  function ProcessSpecialRemap() -> void
    inv_overhaul_special_inventory_bridge.Process()
  end

  function InitializePersistentSnapshotIfMissing() -> void
    inv_overhaul_inventory_snapshot_seed.InitializeIfMissing()
  end

  function ShowFullMessage() -> void
    if m_fMessageCooldown > 0 then return end
    local text: object
    native.CreateIntVector(text)
    text->add(c_iInventoryFullTextID)
    native.SendWorldWndMessage(c_iWMHelpMessage, text)
    m_fMessageCooldown = c_fMessageCooldown
  end

  function EnqueueOverflow(index: int, itemID: int, category: int) -> void
    if m_iQueueCount >= c_iOverflowQueueSize then
      native.Trace("inv_overhaul_inventory_guard overflow queue full")
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
    local dropped: bool =
      inv_overhaul_inventory_overflow.DropItem(
        index, itemID, category)
    if dropped then
      local player: object = GetPlayer()
      local count: int
      player->GetItemCount(count, category)
      m_CategoryCounts->set(category, count)
      native.Trace("inv_overhaul_inventory_guard dropped new item index=" +
        index + " item=" + itemID + " category=" + category)
    end
    return dropped
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
          native.Trace("inv_overhaul_inventory_guard new overflow item not found index=" + index + " item=" + itemID + " category=" + category)
        end
      end
    end
    m_bResolvingOverflow = false
    if dropped then ShowFullMessage() end
  end

  function AdvanceContentGeneration() -> void
    inv_overhaul_inventory_overflow.AdvanceContentGeneration()
  end

  function ConsolidatePlayerStacks() -> void
    if !m_bStackMergePending then return end
    m_bStackMergePending = false
    m_bResolvingStackMerge = true
    inv_overhaul_inventory_stack_consolidation.Consolidate(
      m_CategoryCounts)
    m_bResolvingStackMerge = false
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
    m_bResolvingStackMerge = false
    -- Migrate duplicate stacks already present in an older save as well as
    -- new stacks subsequently delivered by any AddItem path.
    m_bStackMergePending = true
    m_fMessageCooldown = 0
    m_iEffectGeneration = 0
    native.GetVariable("inv_overhaul_effect_generation", m_iEffectGeneration)
    local player: object = GetPlayer()
    for category = 0, c_iCategoryCount - 1 do
      local categoryCount: int
      player->GetItemCount(categoryCount, category)
      m_CategoryCounts->add(categoryCount)
    end
    m_iAllowedSlots = GetBackpackItemCount()
    if m_iAllowedSlots < c_iInventoryCapacity then m_iAllowedSlots = c_iInventoryCapacity end
    InitializePersistentSnapshotIfMissing()
    inv_overhaul_special_inventory_bridge.Reset()
    native.Trace("INV_OVERHAUL_EFFECT_LIFECYCLE guard start generation=" + m_iEffectGeneration)
    native.Trace("INV_OVERHAUL_INVENTORY_GUARD_VERSION 2026.08.11-effect-generation-3 allowed=" + m_iAllowedSlots)

    while true do
      native.Sleep(c_fTickDelay)
      local currentGeneration: int = 0
      native.GetVariable("inv_overhaul_effect_generation", currentGeneration)
      if currentGeneration != m_iEffectGeneration then
        native.Trace("INV_OVERHAUL_EFFECT_LIFECYCLE guard stop generation=" +
          m_iEffectGeneration + " current=" + currentGeneration)
        return
      end
      if m_fMessageCooldown > 0 then
        m_fMessageCooldown = m_fMessageCooldown - c_fTickDelay
        if m_fMessageCooldown < 0 then m_fMessageCooldown = 0 end
      end
      ProcessSpecialRemap()
      ConsolidatePlayerStacks()
      ProcessOverflowQueue()
    end
  end

  function OnInventoryAddItem(item: object, id1: int, id2: int, category: int) -> void
    if m_bResolvingOverflow || m_bResolvingStackMerge then return end
    if category < 0 || category >= c_iCategoryCount then return end
    local previousCount: int
    local currentCount: int
    local player: object = GetPlayer()
    m_CategoryCounts->get(previousCount, category)
    player->GetItemCount(currentCount, category)
    m_CategoryCounts->set(category, currentCount)
    if currentCount > previousCount then AdvanceContentGeneration() end
    if item then
      local addedItemID: int
      local maxStackSize: int
      item->GetItemID(addedItemID)
      native.GetInvItemMaxStackSize(maxStackSize, addedItemID)
      if maxStackSize > 1 then m_bStackMergePending = true end
    end
    local quickslotDiag: int = 0
    native.GetVariable("inv_overhaul_quickslot_diag_active", quickslotDiag)
    if quickslotDiag == 1 then
      local addedItemID: int = -1
      if item then item->GetItemID(addedItemID) end
      native.Trace("inv_overhaul_quickslot diag OnInventoryAddItem category=" +
        category + " item=" + addedItemID + " previousCount=" +
        previousCount + " currentCount=" + currentCount)
    end
    if inv_overhaul_inventory_overflow.ShouldQueue(
      m_iAllowedSlots, previousCount, currentCount) then
      local itemID: int
      item->GetItemID(itemID)
      EnqueueOverflow(currentCount - 1, itemID, category)
      native.Trace("inv_overhaul_inventory_guard queued new overflow item index=" + (currentCount - 1) + " item=" + itemID + " category=" + category)
    end
  end

  function OnInventoryRemoveItem(item: object, id1: int, id2: int, category: int) -> void
    if m_bResolvingOverflow || m_bResolvingStackMerge then return end
    if category >= 0 && category < c_iCategoryCount then
      local previousCount: int
      local categoryCount: int
      local player: object = GetPlayer()
      m_CategoryCounts->get(previousCount, category)
      player->GetItemCount(categoryCount, category)
      m_CategoryCounts->set(category, categoryCount)
      if categoryCount < previousCount then AdvanceContentGeneration() end
      local quickslotDiag: int = 0
      native.GetVariable("inv_overhaul_quickslot_diag_active", quickslotDiag)
      if quickslotDiag == 1 then
        local removedItemID: int = -1
        if item then item->GetItemID(removedItemID) end
        native.Trace("inv_overhaul_quickslot diag OnInventoryRemoveItem category=" +
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
