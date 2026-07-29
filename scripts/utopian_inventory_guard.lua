maintask TEffect do
  local const c_iCWeapon: int = 0
  local const c_iCClothes: int = 1
  local const c_iCategoryCount: int = 5
  local const c_iInventoryCapacity: int = 56
  local const c_iSnapshotVersion: int = 1
  local const c_iOverflowQueueSize: int = 64
  local const c_iWMHelpMessage: int = 200
  local const c_iInventoryFullTextID: int = 1400
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
    native.Trace("UTOPIAN_INVENTORY_GUARD_VERSION 2026.07.29-snapshot-reconcile-1 allowed=" + m_iAllowedSlots)

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
    end
    local count: int = GetBackpackItemCount()
    if count < m_iAllowedSlots then
      m_iAllowedSlots = count
      if m_iAllowedSlots < c_iInventoryCapacity then m_iAllowedSlots = c_iInventoryCapacity end
    end
  end
end
