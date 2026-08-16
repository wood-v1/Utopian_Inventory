maintask InvOverhaulContainerUI do
  local const c_sScriptVersion: string = "2026.08.15-safe-container-kind-5"
  local const c_iCWeapon: int = 0
  local const c_iCClothes: int = 1
  local const c_iCategoryCount: int = 5
  local const c_iInventoryCapacity: int = 56
  local const c_iLayoutVersion: int = 4
  local const c_iSnapshotVersion: int = 1
  local const c_iVKShift: int = 16
  local const c_iVKControl: int = 17
  local const c_iQuickslotCount: int = 10
  local const c_iQuickslotVersion: int = 1
  local const c_iBranchBurah: int = 1
  local const c_iSlotEmpty: int = 32768
  local const c_iSlotNumber: int = 65536
  local const c_iHoverMessageBase: int = 100000
  local const c_iReleaseMessageBase: int = 200000
  local const c_iDragEndMessageBase: int = 300000
  local const c_iPanelPointerMoveBase: int = 1000000
  local const c_iPanelPointerDownBase: int = 4000000
  local const c_iPanelPointerUpBase: int = 7000000
  local const c_iPanelPointerRightBase: int = 10000000
  local const c_iPanelPointerDragBeginBase: int = 13000000
  local const c_iPanelPointerDragEndBase: int = 16000000
  local const c_iPanelPointerLeaveBase: int = 19000000
  local const c_iPanelPointerStride: int = 2000
  local const c_iSlotHotZone: int = 52
  local const c_iSlotDropInset: int = 1
  local const c_iTargetDrop: int = 200
  local const c_iTargetContainerBase: int = 300
  local const c_iTargetOrganBase: int = 400
  local const c_iTargetMoney: int = 500
  local const c_iTargetPaging: int = 600
  local const c_iTargetQuickslotHelp: int = 601
  local const c_iQuickslotHelpHover: int = 29800001
  local const c_iContainerSlots: int = 12
  local const c_iOrganSlots: int = 4
  local const c_iMaxContainerVisuals: int = 128
  local const c_iTransferMarker: int = 791337
  local const c_iWMHelpMessage: int = 200
  local const c_iInventoryFullTextID: int = 1400
  local const c_iContainerFullTextID: int = 1402
  local const c_iCorpseFullTextID: int = 1403
  local const c_iPageHoverEnter: int = -110
  local const c_iPageHoverLeave: int = -111
  local const c_iGridRendererReady: int = 29900000
  local const c_fPageHoverDelay: float = 1.00
  local const c_iInitialSlotLoadBatch: int = 1

  local windowWidth: int
  local windowHeight: int
  local visibleSlots: int
  local playerPage: int
  local containerPage: int
  local resolvedCategory: int
  local resolvedIndex: int
  local resolvedContainerIndex: int
  local resolvedContainerOrdinal: int
  local slotOrder: object
  local playerOrderSnapshot: object
  local playerOrdinalMap: object
  local playerCategoryCache: object
  local playerIndexCache: object
  local persistentUsedLayoutCell: object
  local containerOrder: object
  local containerIndexCache: object
  local cachedNormalContainerCount: int
  local organOrder: object
  local dragSource: int
  local dragKind: int
  local dragItemID: int
  local dragPlayerCategory: int
  local dragPlayerIndex: int
  local dragPlayerCell: int
  local dragContainerIndex: int
  local dragContainerOrdinal: int
  local dragContainerVisual: int
  local dragPlayerIsOrgan: bool
  local highlightedTarget: int
  local lastValidDropTarget: int
  local invalidDropTargetFrames: int
  local panelTooltipTarget: int
  local moneyTooltipItem: object
  local moneyItemID: int
  local isCorpse: bool
  local isDroppedRubbishHeap: bool
  local rubbishKindRefreshDelay: float
  local rubbishKindRefreshRemaining: float
  local windowClosing: bool
  local showOrgans: bool
  local corpseVisualPending: bool
  local organVisibilityRefresh: float
  local lastLayoutWidth: int
  local lastLayoutHeight: int
  local deferredInventoryRefresh: float
  local deferredContainerRefresh: float
  local inventoryFullMessageCooldown: float
  local lastContainerMaxPage: int
  local shiftHeld: bool
  local controlHeld: bool
  local dragPageHoverAction: int
  local dragPageHoverElapsed: float
  local dragPageHoverConsumed: bool
  local tooltipResumeDelay: float
  local initialSlotLoadActive: bool
  local initialPlayerSlotLoadNext: int
  local initialContainerSlotLoadNext: int
  local moneyPollCooldown: float
  local initialSlotLoadPending: bool
  local initialSlotLoadDelay: float
  local quickslotItemCache: object
  local quickslotCategoryCache: object
  local quickslotOccurrenceCache: object
  local layoutSavePending: bool
  local layoutSaveNextCell: int
  local initialMetadataStage: int

  function init() -> void
    native.Trace("INV_OVERHAUL_INVENTORY_VERSION " + c_sScriptVersion + " screen=container")
    playerPage = 0
    containerPage = 0
    resolvedCategory = -1
    resolvedIndex = -1
    resolvedContainerIndex = -1
    resolvedContainerOrdinal = -1
    dragSource = -1
    dragKind = -1
    dragItemID = -1
    dragPlayerCategory = -1
    dragPlayerIndex = -1
    dragPlayerCell = -1
    dragContainerIndex = -1
    dragContainerOrdinal = -1
    dragContainerVisual = -1
    dragPlayerIsOrgan = false
    dragPageHoverAction = 0
    dragPageHoverElapsed = 0
    dragPageHoverConsumed = false
    tooltipResumeDelay = 0
    initialSlotLoadActive = false
    initialPlayerSlotLoadNext = 0
    initialContainerSlotLoadNext = 0
    moneyPollCooldown = 0.25
    initialSlotLoadPending = true
    initialSlotLoadDelay = 0.05
    highlightedTarget = -1
    lastValidDropTarget = -1
    invalidDropTargetFrames = 0
    panelTooltipTarget = -999
    lastLayoutWidth = -1
    lastLayoutHeight = -1
    deferredInventoryRefresh = 0
    deferredContainerRefresh = 0
    inventoryFullMessageCooldown = 0
    lastContainerMaxPage = -1
    shiftHeld = false
    controlHeld = false
    corpseVisualPending = false
    isDroppedRubbishHeap = false
    rubbishKindRefreshDelay = 0
    rubbishKindRefreshRemaining = 0
    windowClosing = false
    organVisibilityRefresh = 0.5
    layoutSavePending = false
    layoutSaveNextCell = -1
    initialMetadataStage = 0
    native.CreateIntVector(quickslotItemCache)
    native.CreateIntVector(quickslotCategoryCache)
    native.CreateIntVector(quickslotOccurrenceCache)
    for quickslot = 1, c_iQuickslotCount do
      quickslotItemCache->add(-1)
      quickslotCategoryCache->add(-1)
      quickslotOccurrenceCache->add(-1)
    end
    InitializeQuickslotBindings()
    RefreshQuickslotCache()
    native.SetVariable("inv_overhaul_inventory_drag_item", -1)
    native.SetVariable("inv_overhaul_inventory_page_hover", 0)
    native.SetCursor("inv_overhaul_inventory")
    native.ShowCursor()
    native.CaptureKeyboard()
    native.SetOwnerDraw(false)
    native.SetNeedUpdate(true)
    native.CreateInvItem(moneyTooltipItem)
    moneyTooltipItem->SetItemName("Money")
    moneyTooltipItem->GetItemID(moneyItemID)
    InitSlotOrder()
    InitContainerOrders()
    UpdateLayout()
    native.SendMessage(-201, "panel_background")
    DetectContainerKind()
    if windowClosing then return end
    UpdatePlayerPageControls()
    UpdateContainerPageControls()
    native.ProcessEvents()
  end

  function GetPlayerContainer() -> object
    local container: object
    native.GetPlayerContainer(container)
    return container
  end

  function GetExternalContainer() -> object
    local container: object
    native.GetContainer(container)
    return container
  end

  function RefreshDroppedRubbishKind(closeIfEmpty: bool) -> bool
    return false
  end

  function DetectContainerKind() -> void
    isCorpse = false
    showOrgans = false
    local rubbishHeap: int = 0
    isDroppedRubbishHeap = false
    local external: object = GetExternalContainer()
    -- The selected world object may be a generic Container actor (dropped
    -- rubbish heaps use this type). It does not expose the Actor property
    -- interface, and calling HasProperty on it aborts UI init before
    -- ProcessEvents, leaving the player trapped in a static overlay. Corpse
    -- layouts are identified by the engine flag below and by corpse_marker.
    local nativeCorpse: bool = false
    native.IsCorpseContainer(nativeCorpse)
    if nativeCorpse then
      native.Trace("inv_overhaul_container corpse detected by engine container kind")
      ActivateCorpseMode()
      return
    end
    if external then
      local count: int
      external->GetItemCount(count)
      native.Trace("INV_OVERHAUL_EFFECT_LIFECYCLE loot init rubbish=" + rubbishHeap + " count=" + count)
      native.Trace("inv_overhaul_container external item count=" + count + " rubbish=" + rubbishHeap)
      if isDroppedRubbishHeap && count <= 0 then
        native.Trace("inv_overhaul_container closing empty dropped rubbish heap")
        windowClosing = true
        CloseContainerWindow()
        return
      end
      for index = 0, count - 1 do
        local item: object
        local organ: bool = false
        external->GetItem(item, index)
        item->HasProperty(organ, "Organ")
        if organ then
          native.Trace("inv_overhaul_container corpse detected by organ item")
          ActivateCorpseMode()
          return
        end
      end
    end
    native.Trace("inv_overhaul_container kind awaiting corpse marker")
  end

  function ActivateCorpseMode() -> void
    isCorpse = true
    corpseVisualPending = true
    organVisibilityRefresh = 0.5
    local branch: int = 0
    native.GetVariable("branch", branch)
    showOrgans = branch == c_iBranchBurah
    native.Trace("inv_overhaul_container corpse marker branch=" + branch + " organs=" + showOrgans)
    native.SendMessage(-100, "loot_doll")
    UpdateContainerSlots()
    UpdateOrganSlots()
    deferredContainerRefresh = 0.05
  end

  function InitSlotOrder() -> void
    native.CreateIntVector(slotOrder)
    for i = 0, c_iInventoryCapacity - 1 do slotOrder->add(GetDefaultOrderForCell(i)) end
    native.CreateIntVector(playerOrderSnapshot)
    native.CreateIntVector(playerOrdinalMap)
    native.CreateIntVector(playerCategoryCache)
    native.CreateIntVector(playerIndexCache)
    native.CreateIntVector(persistentUsedLayoutCell)
    for i = 0, c_iInventoryCapacity - 1 do playerOrderSnapshot->add(-1) end
    for i = 0, c_iInventoryCapacity - 1 do playerOrdinalMap->add(-1) end
    for i = 0, c_iInventoryCapacity - 1 do playerCategoryCache->add(-1) end
    for i = 0, c_iInventoryCapacity - 1 do playerIndexCache->add(-1) end
    for i = 0, c_iInventoryCapacity - 1 do persistentUsedLayoutCell->add(0) end
  end


  function GetDefaultOrderForCell(cell: int) -> int
    if cell < 16 then return cell + 40 end
    return cell - 16
  end

  function InitContainerOrders() -> void
    native.CreateIntVector(containerOrder)
    for i = 0, c_iMaxContainerVisuals - 1 do containerOrder->add(i) end
    native.CreateIntVector(containerIndexCache)
    for i = 0, c_iMaxContainerVisuals - 1 do containerIndexCache->add(-1) end
    cachedNormalContainerCount = 0
    native.CreateIntVector(organOrder)
    for i = 0, c_iOrganSlots - 1 do organOrder->add(i) end
  end

  function GetOrderValue(slot: int) -> int
    local order: int = slot
    if slot >= 0 && slot < c_iInventoryCapacity then slotOrder->get(order, slot) end
    return order
  end

  function SetOrderValue(slot: int, value: int) -> void
    if slot >= 0 && slot < c_iInventoryCapacity then slotOrder->set(slot, value) end
  end

  function GetContainerOrderValue(visual: int) -> int
    local order: int = visual
    if visual >= 0 && visual < c_iMaxContainerVisuals then containerOrder->get(order, visual) end
    return order
  end

  function SetContainerOrderValue(visual: int, value: int) -> void
    if visual >= 0 && visual < c_iMaxContainerVisuals then containerOrder->set(visual, value) end
  end

  function GetOrganOrderValue(visual: int) -> int
    local order: int = visual
    if visual >= 0 && visual < c_iOrganSlots then organOrder->get(order, visual) end
    return order
  end

  function SetOrganOrderValue(visual: int, value: int) -> void
    if visual >= 0 && visual < c_iOrganSlots then organOrder->set(visual, value) end
  end

  function GetCellVariableName(slot: int) -> string
    return "inv_overhaul_inventory_cell_" + slot
  end

  function LoadLayoutVariables() -> void
    local initialized: int = 0
    local version: int = 0
    native.GetVariable("inv_overhaul_inventory_layout_initialized", initialized)
    native.GetVariable("inv_overhaul_inventory_layout_version", version)
    if initialized != 1 then
      SaveLayoutVariables()
      return
    end
    local storedSlots: int = c_iInventoryCapacity
    if version == 3 then storedSlots = 40 end
    if version != 3 && version != c_iLayoutVersion then
      SaveLayoutVariables()
      return
    end
    if version == 3 then
      for i = 0, 15 do SetOrderValue(i, i + 40) end
      for i = 0, 39 do
        local order: int = i
        native.GetVariable(GetCellVariableName(i), order)
        if order < 0 || order >= 40 then order = i end
        SetOrderValue(i + 16, order)
      end
    else
      for i = 0, storedSlots - 1 do
        local order: int = GetDefaultOrderForCell(i)
        native.GetVariable(GetCellVariableName(i), order)
        if order < 0 || order >= storedSlots then order = GetDefaultOrderForCell(i) end
        SetOrderValue(i, order)
      end
    end
    NormalizeSlotOrder()
    if version == 3 then SaveLayoutVariables() end
  end

  function ContinueIncrementalLayoutLoad() -> bool
    if layoutSaveNextCell < 0 then
      local initialized: int = 0
      local version: int = 0
      native.GetVariable("inv_overhaul_inventory_layout_initialized", initialized)
      native.GetVariable("inv_overhaul_inventory_layout_version", version)
      if initialized != 1 || version != c_iLayoutVersion then
        LoadLayoutVariables()
        return true
      end
      layoutSaveNextCell = 0
    end
    for batch = 0, 7 do
      if layoutSaveNextCell < c_iInventoryCapacity then
        local order: int = GetDefaultOrderForCell(layoutSaveNextCell)
        native.GetVariable(GetCellVariableName(layoutSaveNextCell), order)
        if order < 0 || order >= c_iInventoryCapacity then order = GetDefaultOrderForCell(layoutSaveNextCell) end
        SetOrderValue(layoutSaveNextCell, order)
        layoutSaveNextCell = layoutSaveNextCell + 1
      end
    end
    if layoutSaveNextCell >= c_iInventoryCapacity then
      NormalizeSlotOrder()
      layoutSaveNextCell = 0
      return true
    end
    return false
  end

  function SaveLayoutVariables() -> void
    for i = 0, c_iInventoryCapacity - 1 do native.SetVariable(GetCellVariableName(i), GetOrderValue(i)) end
    native.SetVariable("inv_overhaul_inventory_layout_initialized", 1)
    native.SetVariable("inv_overhaul_inventory_layout_version", c_iLayoutVersion)
    layoutSavePending = false
    layoutSaveNextCell = 0
  end

  function QueueLayoutSave() -> void
    layoutSavePending = true
    layoutSaveNextCell = 0
  end

  function ContinueLayoutSave() -> void
    if !layoutSavePending then return end
    for batch = 0, 1 do
      if layoutSaveNextCell < c_iInventoryCapacity then
        native.SetVariable(GetCellVariableName(layoutSaveNextCell), GetOrderValue(layoutSaveNextCell))
        layoutSaveNextCell = layoutSaveNextCell + 1
      end
    end
    if layoutSaveNextCell >= c_iInventoryCapacity then
      native.SetVariable("inv_overhaul_inventory_layout_initialized", 1)
      native.SetVariable("inv_overhaul_inventory_layout_version", c_iLayoutVersion)
      layoutSavePending = false
      layoutSaveNextCell = 0
    end
  end

  function IsOrderUsedBefore(slot: int, order: int) -> bool
    for i = 0, slot - 1 do
      if GetOrderValue(i) == order then return true end
    end
    return false
  end

  function IsOrderUsedAtOrBefore(slot: int, order: int) -> bool
    for i = 0, slot do
      if GetOrderValue(i) == order then return true end
    end
    return false
  end

  function FindFirstUnusedOrder(slot: int) -> int
    for candidate = 0, c_iInventoryCapacity - 1 do
      if !IsOrderUsedAtOrBefore(slot, candidate) then return candidate end
    end
    return slot
  end

  function NormalizeSlotOrder() -> void
    for slot = 0, c_iInventoryCapacity - 1 do
      local order: int = GetOrderValue(slot)
      if order < 0 || order >= c_iInventoryCapacity || IsOrderUsedBefore(slot, order) then
        SetOrderValue(slot, FindFirstUnusedOrder(slot))
      end
    end
  end

  function OrderFreeCellsByDisplay() -> void
    local itemCount: int = GetBackpackItemCount()
    if itemCount > c_iInventoryCapacity then return end
    local nextFreeOrder: int = itemCount
    local changed: bool = false
    for linear = 0, c_iInventoryCapacity - 1 do
      local cell: int = GetCellForLinearSlot(linear)
      if cell >= 0 && GetOrderValue(cell) >= itemCount then
        if GetOrderValue(cell) != nextFreeOrder then
          SetOrderValue(cell, nextFreeOrder)
          changed = true
        end
        nextFreeOrder = nextFreeOrder + 1
      end
    end
    if changed then QueueLayoutSave() end
  end

  function ConfigureSlotRenderSize() -> void
    local sizeMessage: int = -27
    local organSizeMessage: int = -27
    if windowWidth >= 1900 then sizeMessage = -26 end
    if windowWidth >= 1900 then organSizeMessage = -29 end
    for slot = 0, visibleSlots - 1 do
      native.SendMessage(sizeMessage, GetSlotWndName(slot))
    end
    for containerSlot = 0, c_iContainerSlots - 1 do
      native.SendMessage(sizeMessage, GetContainerSlotWndName(containerSlot))
    end
    for organSlot = 0, c_iOrganSlots - 1 do
      native.SendMessage(organSizeMessage, GetOrganSlotWndName(organSlot))
    end
    native.SendMessage(sizeMessage, "money")
  end

  function UpdateLayout() -> void
    native.GetWindowSize(windowWidth, windowHeight)
    if windowWidth <= 0 || windowHeight <= 0 then native.GetScreenSize(windowWidth, windowHeight) end
    if windowWidth >= 1900 then
      visibleSlots = 35
    else
    if windowWidth >= 1200 then
      visibleSlots = c_iInventoryCapacity
    else
      if windowWidth >= 1000 then visibleSlots = 35 else visibleSlots = 24 end
    end
    end
    if windowWidth != lastLayoutWidth || windowHeight != lastLayoutHeight then
      native.SendMessage(windowWidth, "panel_background")
      native.SendMessage(5000 + windowHeight, "panel_background")
      ConfigureSlotRenderSize()
      lastLayoutWidth = windowWidth
      lastLayoutHeight = windowHeight
    end
  end

  function GetSlotWndName(slot: int) -> string
    local number: int = slot + 1
    if number < 10 then return "slot0" + number end
    return "slot" + number
  end

  function GetVisibleCell(slot: int) -> int
    local linear: int = playerPage * visibleSlots + slot
    return GetCellForLinearSlot(linear)
  end

  function GetCellForLinearSlot(linear: int) -> int
    if linear < 0 || linear >= c_iInventoryCapacity then return -1 end
    if visibleSlots < c_iInventoryCapacity then return (linear + 16) - ((linear + 16) / c_iInventoryCapacity) * c_iInventoryCapacity end
    return linear
  end

  function GetContainerSlotWndName(slot: int) -> string
    local number: int = slot + 1
    if number < 10 then return "cslot0" + number end
    return "cslot" + number
  end

  function GetOrganSlotWndName(slot: int) -> string
    local number: int = slot + 1
    if number < 10 then return "oslot0" + number end
    return "oslot" + number
  end

  function GetTargetWndName(target: int) -> string
    if target >= 0 && target < visibleSlots then return GetSlotWndName(target) end
    if target >= c_iTargetContainerBase && target < c_iTargetContainerBase + c_iContainerSlots then
      return GetContainerSlotWndName(target - c_iTargetContainerBase)
    end
    if target >= c_iTargetOrganBase && target < c_iTargetOrganBase + c_iOrganSlots then
      return GetOrganSlotWndName(target - c_iTargetOrganBase)
    end
    if target == c_iTargetDrop then return "drop_slot" end
    return ""
  end

  function GetGridStartX() -> int
    if windowWidth >= 1900 then return 825 end
    if windowWidth >= 1200 then return 600 end
    if windowWidth >= 1000 then return 468 end
    return 359
  end

  function GetGridStartY() -> int
    if windowWidth >= 1900 then return 245 end
    if windowWidth >= 1200 then return 182 end
    if windowWidth >= 1000 then return 266 end
    return 225
  end

  function GetGridStep() -> int
    if windowWidth >= 1900 then return 96 end
    if windowWidth >= 1200 then return 64 end
    if windowWidth >= 1000 then return 61 end
    return 58
  end

  function GetGridColumns() -> int
    if windowWidth >= 1900 then return 7 end
    if windowWidth >= 1200 then return 8 end
    if windowWidth >= 1000 then return 7 end
    return 6
  end

  function GetContainerStartX() -> int
    if windowWidth >= 1900 then return 455 end
    if windowWidth >= 1200 then return 170 end
    if windowWidth >= 1000 then return 121 end
    return 79
  end

  function GetContainerStartY() -> int
    return GetGridStartY()
  end

  function GetOrganStartX() -> int
    if windowWidth >= 1900 then return 469 end
    if windowWidth >= 1200 then return 138 end
    if windowWidth >= 1000 then return 90 end
    return 49
  end

  function GetOrganStartY() -> int
    if windowWidth >= 1900 then return 780 end
    if windowWidth >= 1200 then return 650 end
    if windowWidth >= 1000 then return 570 end
    return 482
  end

  function GetOrganStep() -> int
    if windowWidth >= 1900 then return 67 end
    return GetGridStep()
  end

  function GetDropLeft() -> int
    if windowWidth >= 1900 then return 1067 end
    if windowWidth >= 1200 then return 806 end
    if windowWidth >= 1000 then return 650 end
    return 501
  end

  function GetDropTop() -> int
    if windowWidth >= 1900 then return 780 end
    if windowWidth >= 1200 then return 685 end
    if windowWidth >= 1000 then return 596 end
    return 455
  end

  function GetMoneyLeft() -> int
    if windowWidth >= 1900 then return 1390 end
    if windowWidth >= 1200 then return 1100 end
    if windowWidth >= 1000 then return 864 end
    return 655
  end

  function GetMoneyTop() -> int
    if windowWidth >= 1900 then return 780 end
    if windowWidth >= 1200 then return 770 end
    if windowWidth >= 1000 then return 616 end
    return 465
  end

  function IsEquippedItem(category: int, index: int) -> bool
    if category != c_iCWeapon && category != c_iCClothes then return false end
    local container: object = GetPlayerContainer()
    local selected: bool
    container->IsItemSelected(selected, index, category)
    if !selected then return false end
    local item: object
    container->GetItem(item, index, category)
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
    local container: object = GetPlayerContainer()
    local total: int = 0
    for category = 0, c_iCategoryCount - 1 do
      local count: int
      container->GetItemCount(count, category)
      for index = 0, count - 1 do
        if !IsEquippedItem(category, index) then total = total + 1 end
      end
    end
    return total
  end

  function ShowInventoryFull() -> void
    if inventoryFullMessageCooldown > 0 then return end
    local text: object
    native.CreateIntVector(text)
    text->add(c_iInventoryFullTextID)
    native.SendWorldWndMessage(c_iWMHelpMessage, text)
    inventoryFullMessageCooldown = 1.0
  end

  function ShowContainerFull() -> void
    if inventoryFullMessageCooldown > 0 then return end
    local text: object
    native.CreateIntVector(text)
    if isCorpse then text->add(c_iCorpseFullTextID) else text->add(c_iContainerFullTextID) end
    native.SendWorldWndMessage(c_iWMHelpMessage, text)
    inventoryFullMessageCooldown = 1.0
  end

  function CanPlayerAcceptItem(item: object, category: int) -> bool
    if GetBackpackItemCount() < c_iInventoryCapacity then return true end
    if !item then return false end

    local itemID: int
    item->GetItemID(itemID)
    local maxStackSize: int
    native.GetInvItemMaxStackSize(maxStackSize, itemID)
    if maxStackSize <= 1 then return false end

    local player: object = GetPlayerContainer()
    local count: int
    player->GetItemCount(count, category)
    for index = 0, count - 1 do
      if !IsEquippedItem(category, index) then
        local candidate: object
        local candidateID: int
        local candidateAmount: int
        player->GetItem(candidate, index, category)
        candidate->GetItemID(candidateID)
        player->GetItemAmount(candidateAmount, index, category)
        if candidateID == itemID && candidateAmount < maxStackSize then return true end
      end
    end
    return false
  end

  function GetMaxPlayerPage() -> int
    if visibleSlots <= 0 then return 0 end
    return (c_iInventoryCapacity - 1) / visibleSlots
  end

  function ClampPlayerPage() -> void
    local maxPage: int = GetMaxPlayerPage()
    if playerPage < 0 then playerPage = 0 end
    if playerPage > maxPage then playerPage = maxPage end
  end

  function ResolveVisibleSlot(slot: int) -> bool
    resolvedCategory = -1
    resolvedIndex = -1
    local target: int = GetOrderValue(GetVisibleCell(slot))
    if target < 0 || target >= c_iInventoryCapacity then return false end
    playerCategoryCache->get(resolvedCategory, target)
    playerIndexCache->get(resolvedIndex, target)
    return resolvedCategory >= 0 && resolvedIndex >= 0
  end

  function BuildPlayerIndexCache() -> void
    for ordinal = 0, c_iInventoryCapacity - 1 do
      playerCategoryCache->set(ordinal, -1)
      playerIndexCache->set(ordinal, -1)
    end
    local container: object = GetPlayerContainer()
    local ordinal: int = 0
    for category = 0, c_iCategoryCount - 1 do
      local count: int
      container->GetItemCount(count, category)
      for index = 0, count - 1 do
        if !IsEquippedItem(category, index) then
          if ordinal < c_iInventoryCapacity then
            playerCategoryCache->set(ordinal, category)
            playerIndexCache->set(ordinal, index)
          end
          ordinal = ordinal + 1
        end
      end
    end
  end

  function IsOrganItem(item: object) -> bool
    if !item then return false end
    local organ: bool = false
    item->HasProperty(organ, "Organ")
    return organ
  end

  function IsKnownOrganItemID(itemID: int) -> bool
    local knownID: int
    native.GetInvItemByName(knownID, "liver")
    if itemID == knownID then return true end
    native.GetInvItemByName(knownID, "kidney")
    if itemID == knownID then return true end
    native.GetInvItemByName(knownID, "heart")
    if itemID == knownID then return true end
    native.GetInvItemByName(knownID, "blood")
    if itemID == knownID then return true end
    native.GetInvItemByName(knownID, "diseased_liver")
    if itemID == knownID then return true end
    native.GetInvItemByName(knownID, "diseased_kidney")
    if itemID == knownID then return true end
    native.GetInvItemByName(knownID, "diseased_heart")
    if itemID == knownID then return true end
    native.GetInvItemByName(knownID, "diseased_blood")
    return itemID == knownID
  end

  function IsPlayerOrganItem(category: int, index: int) -> bool
    local player: object = GetPlayerContainer()
    local item: object
    player->GetItem(item, index, category)
    if !item then return false end
    local storedOrgan: bool = false
    item->HasProperty(storedOrgan, "InvOverhaulOrgan")
    if storedOrgan then return true end
    local itemID: int
    item->GetItemID(itemID)
    return IsKnownOrganItemID(itemID)
  end

  function GetNormalContainerItemCount() -> int
    local container: object = GetExternalContainer()
    if !container then return 0 end
    local count: int
    container->GetItemCount(count)
    local normalCount: int = 0
    for index = 0, count - 1 do
      local item: object
      container->GetItem(item, index)
      if !IsOrganItem(item) then normalCount = normalCount + 1 end
    end
    return normalCount
  end

  function GetOrganItemCount() -> int
    local container: object = GetExternalContainer()
    if !container then return 0 end
    local count: int
    container->GetItemCount(count)
    local organCount: int = 0
    for index = 0, count - 1 do
      local item: object
      container->GetItem(item, index)
      if IsOrganItem(item) then organCount = organCount + 1 end
    end
    return organCount
  end

  function ResolveNormalContainerOrdinal(ordinal: int) -> bool
    resolvedContainerIndex = -1
    resolvedContainerOrdinal = -1
    if ordinal < 0 || ordinal >= cachedNormalContainerCount || ordinal >= c_iMaxContainerVisuals then return false end
    containerIndexCache->get(resolvedContainerIndex, ordinal)
    if resolvedContainerIndex < 0 then return false end
    resolvedContainerOrdinal = ordinal
    return true
  end

  function BuildContainerIndexCache() -> void
    for ordinal = 0, c_iMaxContainerVisuals - 1 do containerIndexCache->set(ordinal, -1) end
    cachedNormalContainerCount = 0
    local container: object = GetExternalContainer()
    if !container then return end
    local count: int
    container->GetItemCount(count)
    for index = 0, count - 1 do
      local item: object
      container->GetItem(item, index)
      if !IsOrganItem(item) then
        if cachedNormalContainerCount < c_iMaxContainerVisuals then
          containerIndexCache->set(cachedNormalContainerCount, index)
        end
        cachedNormalContainerCount = cachedNormalContainerCount + 1
      end
    end
  end

  function ResolveOrganOrdinal(ordinal: int) -> bool
    resolvedContainerIndex = -1
    resolvedContainerOrdinal = -1
    if ordinal < 0 then return false end
    local container: object = GetExternalContainer()
    if !container then return false end
    local count: int
    container->GetItemCount(count)
    local current: int = 0
    for index = 0, count - 1 do
      local item: object
      container->GetItem(item, index)
      if IsOrganItem(item) then
        if current == ordinal then
          resolvedContainerIndex = index
          resolvedContainerOrdinal = ordinal
          return true
        end
        current = current + 1
      end
    end
    return false
  end

  function ResolveContainerVisualSlot(slot: int) -> bool
    local visual: int = containerPage * c_iContainerSlots + slot
    return ResolveNormalContainerOrdinal(GetContainerOrderValue(visual))
  end

  function ResolveOrganVisualSlot(slot: int) -> bool
    if !showOrgans then return false end
    resolvedContainerIndex = -1
    resolvedContainerOrdinal = slot
    local container: object = GetExternalContainer()
    if !container then return false end
    local count: int
    container->GetItemCount(count)
    for index = 0, count - 1 do
      local item: object
      container->GetItem(item, index)
      if IsOrganItem(item) then
        local itemID: int
        item->GetItemID(itemID)
        local organSlot: int = GetOrganSlotByItemID(itemID)
        if organSlot == slot then
          resolvedContainerIndex = index
          return true
        end
      end
    end
    return false
  end

  function GetOrganSlotByItemID(itemID: int) -> int
    local knownID: int
    native.GetInvItemByName(knownID, "liver")
    if itemID == knownID then return 0 end
    native.GetInvItemByName(knownID, "diseased_liver")
    if itemID == knownID then return 0 end
    native.GetInvItemByName(knownID, "kidney")
    if itemID == knownID then return 1 end
    native.GetInvItemByName(knownID, "diseased_kidney")
    if itemID == knownID then return 1 end
    native.GetInvItemByName(knownID, "heart")
    if itemID == knownID then return 2 end
    native.GetInvItemByName(knownID, "diseased_heart")
    if itemID == knownID then return 2 end
    native.GetInvItemByName(knownID, "blood")
    if itemID == knownID then return 3 end
    native.GetInvItemByName(knownID, "diseased_blood")
    if itemID == knownID then return 3 end
    return -1
  end

  function GetLastOccupiedContainerVisual() -> int
    local count: int = cachedNormalContainerCount
    if count <= 0 then return -1 end
    local last: int = -1
    for visual = 0, c_iMaxContainerVisuals - 1 do
      if GetContainerOrderValue(visual) < count then last = visual end
    end
    return last
  end

  function ClampContainerPage() -> void
    local maxPage: int = GetMaxContainerPage()
    if containerPage < 0 then containerPage = 0 end
    if containerPage > maxPage then containerPage = maxPage end
  end

  function GetMaxContainerPage() -> int
    local lastVisual: int = GetLastOccupiedContainerVisual()
    if lastVisual < 0 then return 0 end
    return lastVisual / c_iContainerSlots
  end

  function SetPageControlsVisible(prefix: string, visible: bool) -> void
    local message: int = -93
    if visible then message = -92 end
    native.SendMessage(message, prefix + "page_prev")
    native.SendMessage(message, prefix + "page_counter")
    native.SendMessage(message, prefix + "page_next")
  end

  function UpdatePlayerPageControls() -> void
    local maxPage: int = GetMaxPlayerPage()
    native.SendMessage(-114, "player_page_prev")
    native.SendMessage(-115, "player_page_next")
    SetPageControlsVisible("player_", maxPage > 0)
    if maxPage <= 0 then return end
    native.SendMessage(-90, "player_page_prev")
    native.SendMessage(-91, "player_page_next")
    if playerPage > 0 then native.SendMessage(-97, "player_page_prev") else native.SendMessage(-96, "player_page_prev") end
    if playerPage < maxPage then native.SendMessage(-97, "player_page_next") else native.SendMessage(-96, "player_page_next") end
    native.SendMessage((playerPage + 1) * 100 + maxPage + 1, "player_page_counter")
  end

  function UpdateContainerPageControls() -> void
    local maxPage: int = GetMaxContainerPage()
    native.SendMessage(-116, "container_page_prev")
    native.SendMessage(-117, "container_page_next")
    if maxPage != lastContainerMaxPage then
      native.Trace("inv_overhaul_container pages count=" + cachedNormalContainerCount + " max=" + maxPage + " current=" + containerPage + " corpse=" + isCorpse)
      lastContainerMaxPage = maxPage
    end
    SetPageControlsVisible("container_", maxPage > 0)
    if maxPage <= 0 then return end
    native.SendMessage(-90, "container_page_prev")
    native.SendMessage(-91, "container_page_next")
    if containerPage > 0 then native.SendMessage(-97, "container_page_prev") else native.SendMessage(-96, "container_page_prev") end
    if containerPage < maxPage then native.SendMessage(-97, "container_page_next") else native.SendMessage(-96, "container_page_next") end
    native.SendMessage((containerPage + 1) * 100 + maxPage + 1, "container_page_counter")
  end

  function UpdateMoney() -> void
    local container: object = GetPlayerContainer()
    local money: int
    container->GetProperty("money", money)
    native.SendMessage(money, "money")
  end

  function GetQuickslotItemVariable(slot: int) -> string
    return "inv_overhaul_quickslot_item_" + slot
  end

  function GetQuickslotCategoryVariable(slot: int) -> string
    return "inv_overhaul_quickslot_category_" + slot
  end

  function GetQuickslotDepletedVariable(slot: int) -> string
    return "inv_overhaul_quickslot_depleted_" + slot
  end

  function GetQuickslotOccurrenceVariable(slot: int) -> string
    return "inv_overhaul_quickslot_occurrence_" + slot
  end

  function GetItemOccurrence(category: int, index: int, itemID: int) -> int
    local container: object = GetPlayerContainer()
    local occurrence: int = 0
    for candidate = 0, index - 1 do
      local candidateItem: object
      local candidateID: int
      container->GetItem(candidateItem, candidate, category)
      if candidateItem then
        candidateItem->GetItemID(candidateID)
        if candidateID == itemID then occurrence = occurrence + 1 end
      end
    end
    return occurrence
  end

  function InitializeQuickslotBindings() -> void
    local version: int = 0
    native.GetVariable("inv_overhaul_quickslot_version", version)
    if version == c_iQuickslotVersion then return end
    for slot = 1, c_iQuickslotCount do
      native.SetVariable(GetQuickslotItemVariable(slot), -1)
      native.SetVariable(GetQuickslotCategoryVariable(slot), -1)
    end
    native.SetVariable("inv_overhaul_quickslot_version", c_iQuickslotVersion)
  end

  function RefreshQuickslotCache() -> void
    for slot = 1, c_iQuickslotCount do
      local assignedCategory: int = -1
      local assignedItem: int = -1
      local assignedOccurrence: int = -1
      native.GetVariable(GetQuickslotCategoryVariable(slot), assignedCategory)
      native.GetVariable(GetQuickslotItemVariable(slot), assignedItem)
      native.GetVariable(GetQuickslotOccurrenceVariable(slot), assignedOccurrence)
      quickslotCategoryCache->set(slot - 1, assignedCategory)
      quickslotItemCache->set(slot - 1, assignedItem)
      quickslotOccurrenceCache->set(slot - 1, assignedOccurrence)
    end
  end

  function GetItemQuickslot(category: int, itemID: int) -> int
    for slot = 1, c_iQuickslotCount do
      local assignedCategory: int = -1
      local assignedItem: int = -1
      quickslotCategoryCache->get(assignedCategory, slot - 1)
      quickslotItemCache->get(assignedItem, slot - 1)
      if assignedCategory == category && assignedItem == itemID then return slot end
    end
    return 0
  end

  function GetDisplayedQuickslot(category: int, index: int, itemID: int) -> int
    local occurrence: int = GetItemOccurrence(category, index, itemID)
    for slot = 1, c_iQuickslotCount do
      local assignedCategory: int = -1
      local assignedItem: int = -1
      local assignedOccurrence: int = -1
      quickslotCategoryCache->get(assignedCategory, slot - 1)
      quickslotItemCache->get(assignedItem, slot - 1)
      quickslotOccurrenceCache->get(assignedOccurrence, slot - 1)
      if assignedCategory == category && assignedItem == itemID &&
        assignedOccurrence == occurrence then return slot end
    end
    return 0
  end

  function IsQuickslotEligible(category: int, itemID: int) -> bool
    if category == c_iCWeapon then
      local weapon: bool
      native.HasInvItemProperty(weapon, itemID, "Weapon")
      return weapon
    end
    if category == c_iCClothes then
      local group: bool
      native.HasInvItemProperty(group, itemID, "Group")
      return group
    end
    return category >= 2 && category < c_iCategoryCount
  end

  function AssignQuickslot(slot: int, category: int, index: int) -> void
    if slot < 1 || slot > c_iQuickslotCount then return end
    local container: object = GetPlayerContainer()
    local item: object
    local itemID: int
    container->GetItem(item, index, category)
    if !item then return end
    item->GetItemID(itemID)
    if !IsQuickslotEligible(category, itemID) then return end
    local occurrence: int = GetItemOccurrence(category, index, itemID)

    local oldCategory: int = -1
    local oldItem: int = -1
    local oldOccurrence: int = 0
    native.GetVariable(GetQuickslotCategoryVariable(slot), oldCategory)
    native.GetVariable(GetQuickslotItemVariable(slot), oldItem)
    native.GetVariable(GetQuickslotOccurrenceVariable(slot), oldOccurrence)
    if oldCategory == category && oldItem == itemID && oldOccurrence == occurrence then
      native.SetVariable(GetQuickslotCategoryVariable(slot), -1)
      native.SetVariable(GetQuickslotItemVariable(slot), -1)
      native.SetVariable(GetQuickslotDepletedVariable(slot), 0)
      native.SetVariable(GetQuickslotOccurrenceVariable(slot), -1)
      quickslotCategoryCache->set(slot - 1, -1)
      quickslotItemCache->set(slot - 1, -1)
      quickslotOccurrenceCache->set(slot - 1, -1)
    else
      for other = 1, c_iQuickslotCount do
        local otherCategory: int = -1
        local otherItem: int = -1
        local otherOccurrence: int = 0
        native.GetVariable(GetQuickslotCategoryVariable(other), otherCategory)
        native.GetVariable(GetQuickslotItemVariable(other), otherItem)
        native.GetVariable(GetQuickslotOccurrenceVariable(other), otherOccurrence)
        if otherCategory == category && otherItem == itemID && otherOccurrence == occurrence then
          native.SetVariable(GetQuickslotCategoryVariable(other), -1)
          native.SetVariable(GetQuickslotItemVariable(other), -1)
          native.SetVariable(GetQuickslotDepletedVariable(other), 0)
          native.SetVariable(GetQuickslotOccurrenceVariable(other), -1)
          quickslotCategoryCache->set(other - 1, -1)
          quickslotItemCache->set(other - 1, -1)
          quickslotOccurrenceCache->set(other - 1, -1)
        end
      end
      native.SetVariable(GetQuickslotCategoryVariable(slot), category)
      native.SetVariable(GetQuickslotItemVariable(slot), itemID)
      native.SetVariable(GetQuickslotDepletedVariable(slot), 0)
      native.SetVariable(GetQuickslotOccurrenceVariable(slot), occurrence)
      quickslotCategoryCache->set(slot - 1, category)
      quickslotItemCache->set(slot - 1, itemID)
      quickslotOccurrenceCache->set(slot - 1, occurrence)
    end
    UpdatePlayerSlots()
  end

  function GetQuickslotByKey(key: int) -> int
    if key >= 49 && key <= 57 then return key - 48 end
    if key == 48 then return 10 end
    if key >= 97 && key <= 105 then return key - 96 end
    if key == 96 then return 10 end
    return 0
  end

  function AssignHoveredQuickslot(slot: int) -> void
    if dragSource >= 0 then return end
    local target: int = highlightedTarget
    if target < 0 then target = panelTooltipTarget end
    if target < 0 || target >= visibleSlots then return end
    if ResolveVisibleSlot(target) then
      AssignQuickslot(slot, resolvedCategory, resolvedIndex)
    end
  end

  function UpdatePlayerSlot(slot: int) -> void
    local container: object = GetPlayerContainer()
    local wnd: string = GetSlotWndName(slot)
    if GetVisibleCell(slot) < 0 then
      native.SendMessage(c_iSlotEmpty, wnd)
      native.SendMessage(-140, wnd)
      native.SendMessage(-22, wnd)
    else
      native.SendMessage(-23, wnd)
      if ResolveVisibleSlot(slot) then
        local item: object
        local amount: int
        container->GetItem(item, resolvedIndex, resolvedCategory)
        container->GetItemAmount(amount, resolvedIndex, resolvedCategory)
        native.SendMessage(0, wnd, item)
        native.SendMessage(amount + c_iSlotNumber, wnd)
        local itemID: int
        item->GetItemID(itemID)
        local quickslot: int = GetDisplayedQuickslot(resolvedCategory, resolvedIndex, itemID)
        native.SendMessage(-140, wnd)
        if quickslot > 0 then native.SendMessage(-140 - quickslot, wnd) end
      else
        native.SendMessage(c_iSlotEmpty, wnd)
        native.SendMessage(-140, wnd)
      end
    end
  end

  function UpdatePlayerSlots() -> void
    ClampPlayerPage()
    BuildPlayerIndexCache()
    for slot = 0, visibleSlots - 1 do UpdatePlayerSlot(slot) end
    UpdatePlayerPageControls()
  end

  function UpdateContainerSlot(slot: int) -> void
    local container: object = GetExternalContainer()
    local wnd: string = GetContainerSlotWndName(slot)
    if ResolveContainerVisualSlot(slot) then
      local item: object
      local amount: int
      container->GetItem(item, resolvedContainerIndex)
      container->GetItemAmount(amount, resolvedContainerIndex)
      native.SendMessage(0, wnd, item)
      native.SendMessage(amount + c_iSlotNumber, wnd)
    else
      native.SendMessage(c_iSlotEmpty, wnd)
    end
  end

  function UpdateContainerSlots() -> void
    BuildContainerIndexCache()
    ClampContainerPage()
    for slot = 0, c_iContainerSlots - 1 do UpdateContainerSlot(slot) end
    UpdateContainerPageControls()
  end

  function UpdateOrganSlots() -> void
    local container: object = GetExternalContainer()
    for slot = 0, c_iOrganSlots - 1 do
      local wnd: string = GetOrganSlotWndName(slot)
      if !isCorpse || !showOrgans then
        native.SendMessage(c_iSlotEmpty, wnd)
        native.SendMessage(-22, wnd)
      else
        native.SendMessage(-23, wnd)
        if ResolveOrganVisualSlot(slot) then
          native.SendMessage(-25, wnd)
          local item: object
          local amount: int
          container->GetItem(item, resolvedContainerIndex)
          container->GetItemAmount(amount, resolvedContainerIndex)
          native.SendMessage(0, wnd, item)
          native.SendMessage(amount + c_iSlotNumber, wnd)
        else
          native.SendMessage(c_iSlotEmpty, wnd)
          native.SendMessage(-24, wnd)
        end
      end
    end
  end

  function UpdateAllSlots() -> void
    initialSlotLoadActive = false
    UpdateLayout()
    UpdatePlayerSlots()
    UpdateContainerSlots()
    UpdateOrganSlots()
    UpdateMoney()
  end

  function RefreshVisiblePlayerItem(itemID: int, fallbackSlot: int) -> void
    initialSlotLoadActive = false
    BuildPlayerIndexCache()
    local fallbackUpdated: bool = false
    for slot = 0, visibleSlots - 1 do
      local update: bool = false
      if slot == fallbackSlot then update = true end
      if ResolveVisibleSlot(slot) then
        local player: object = GetPlayerContainer()
        local item: object
        local visibleItemID: int = -1
        player->GetItem(item, resolvedIndex, resolvedCategory)
        if item then item->GetItemID(visibleItemID) end
        if visibleItemID == itemID then update = true end
      end
      if update then
        UpdatePlayerSlot(slot)
        if slot == fallbackSlot then fallbackUpdated = true end
      end
    end
    if !fallbackUpdated && fallbackSlot >= 0 && fallbackSlot < visibleSlots then UpdatePlayerSlot(fallbackSlot) end
    UpdatePlayerPageControls()
  end

  function RefreshVisibleContainerItem(itemID: int, fallbackSlot: int) -> void
    initialSlotLoadActive = false
    BuildContainerIndexCache()
    local fallbackUpdated: bool = false
    for slot = 0, c_iContainerSlots - 1 do
      local update: bool = false
      if slot == fallbackSlot then update = true end
      if ResolveContainerVisualSlot(slot) then
        local external: object = GetExternalContainer()
        local item: object
        local visibleItemID: int = -1
        external->GetItem(item, resolvedContainerIndex)
        if item then item->GetItemID(visibleItemID) end
        if visibleItemID == itemID then update = true end
      end
      if update then
        UpdateContainerSlot(slot)
        if slot == fallbackSlot then fallbackUpdated = true end
      end
    end
    if !fallbackUpdated && fallbackSlot >= 0 && fallbackSlot < c_iContainerSlots then UpdateContainerSlot(fallbackSlot) end
    UpdateContainerPageControls()
  end

  function BeginInitialSlotLoad() -> void
    UpdateLayout()
    ClampPlayerPage()
    BuildPlayerIndexCache()
    BuildContainerIndexCache()
    ClampContainerPage()
    UpdatePlayerPageControls()
    UpdateContainerPageControls()
    UpdateOrganSlots()
    UpdateMoney()
    initialPlayerSlotLoadNext = 0
    initialContainerSlotLoadNext = 0
    initialSlotLoadActive = true
    native.Trace("inv_overhaul_container deferred initial slots player=" + visibleSlots + " container=" + c_iContainerSlots)
  end

  function ContinueInitialSlotLoad() -> void
    if !initialSlotLoadActive then return end
    for batch = 0, c_iInitialSlotLoadBatch - 1 do
      if initialContainerSlotLoadNext < c_iContainerSlots then
        UpdateContainerSlot(initialContainerSlotLoadNext)
        initialContainerSlotLoadNext = initialContainerSlotLoadNext + 1
      else
        if initialPlayerSlotLoadNext < visibleSlots then
        UpdatePlayerSlot(initialPlayerSlotLoadNext)
        initialPlayerSlotLoadNext = initialPlayerSlotLoadNext + 1
        end
      end
    end
    if initialContainerSlotLoadNext >= c_iContainerSlots && initialPlayerSlotLoadNext >= visibleSlots then
      initialSlotLoadActive = false
      native.Trace("inv_overhaul_container sequential initial slots complete batch=" +
        c_iInitialSlotLoadBatch)
    end
  end

  function SwapSlotOrder(sourceSlot: int, targetSlot: int) -> void
    if sourceSlot < 0 || targetSlot < 0 || sourceSlot == targetSlot then return end
    if sourceSlot >= visibleSlots || targetSlot >= visibleSlots then return end
    SwapSlotOrderCells(GetVisibleCell(sourceSlot), GetVisibleCell(targetSlot))
  end

  function SwapSlotOrderCells(sourceCell: int, targetCell: int) -> void
    if sourceCell == targetCell then return end
    if sourceCell < 0 || targetCell < 0 then return end
    local sourceOrder: int = GetOrderValue(sourceCell)
    local targetOrder: int = GetOrderValue(targetCell)
    SetOrderValue(sourceCell, targetOrder)
    SetOrderValue(targetCell, sourceOrder)
    QueueLayoutSave()
    for visibleSlot = 0, visibleSlots - 1 do
      local visibleCell: int = GetVisibleCell(visibleSlot)
      if visibleCell == sourceCell || visibleCell == targetCell then UpdatePlayerSlot(visibleSlot) end
    end
  end

  function SwapContainerSlotOrder(sourceSlot: int, targetSlot: int) -> void
    if sourceSlot < 0 || sourceSlot >= c_iContainerSlots then return end
    if targetSlot < 0 || targetSlot >= c_iContainerSlots || sourceSlot == targetSlot then return end
    SwapContainerSlotOrderVisuals(containerPage * c_iContainerSlots + sourceSlot, containerPage * c_iContainerSlots + targetSlot)
  end

  function SwapContainerSlotOrderVisuals(sourceVisual: int, targetVisual: int) -> void
    if sourceVisual < 0 || sourceVisual >= c_iMaxContainerVisuals then return end
    if targetVisual < 0 || targetVisual >= c_iMaxContainerVisuals || sourceVisual == targetVisual then return end
    local sourceOrder: int = GetContainerOrderValue(sourceVisual)
    local targetOrder: int = GetContainerOrderValue(targetVisual)
    SetContainerOrderValue(sourceVisual, targetOrder)
    SetContainerOrderValue(targetVisual, sourceOrder)
    UpdateContainerSlots()
  end

  function RemoveOrderOrdinal(removedOrder: int, beforeCount: int) -> void
    if removedOrder < 0 then return end
    local emptyOrder: int = beforeCount - 1
    for slot = 0, c_iInventoryCapacity - 1 do
      local order: int = GetOrderValue(slot)
      if order == removedOrder then
        SetOrderValue(slot, emptyOrder)
      else
        if order > removedOrder && order < beforeCount then SetOrderValue(slot, order - 1) end
      end
    end
    NormalizeSlotOrder()
    QueueLayoutSave()
  end

  function FindFirstFreePlayerVisual(itemCount: int) -> int
    for linear = 0, c_iInventoryCapacity - 1 do
      local cell: int = GetCellForLinearSlot(linear)
      if cell >= 0 && GetOrderValue(cell) >= itemCount then return cell end
    end
    return -1
  end

  function GetBackpackOrdinal(category: int, index: int) -> int
    local container: object = GetPlayerContainer()
    local ordinal: int = 0
    for currentCategory = 0, c_iCategoryCount - 1 do
      local count: int
      container->GetItemCount(count, currentCategory)
      for currentIndex = 0, count - 1 do
        if !IsEquippedItem(currentCategory, currentIndex) then
          if currentCategory == category && currentIndex == index then return ordinal end
          ordinal = ordinal + 1
        end
      end
    end
    return -1
  end

  function CapturePlayerItemIDs(snapshot: object) -> int
    local player: object = GetPlayerContainer()
    local ordinal: int = 0
    for emptyOrdinal = 0, c_iInventoryCapacity - 1 do snapshot->set(emptyOrdinal, -1) end
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
            snapshot->set(ordinal, itemID)
          end
          ordinal = ordinal + 1
        end
      end
    end
    return ordinal
  end

  function SnapshotExistingPlayerOrder() -> void
    CapturePlayerItemIDs(playerOrderSnapshot)
  end

  function GetPersistentSnapshotVariableName(ordinal: int) -> string
    return "inv_overhaul_inventory_snapshot_" + ordinal
  end

  function LoadPersistentPlayerSnapshot() -> int
    local valid: int = 0
    local version: int = 0
    local count: int = 0
    native.GetVariable("inv_overhaul_inventory_snapshot_valid", valid)
    native.GetVariable("inv_overhaul_inventory_snapshot_version", version)
    native.GetVariable("inv_overhaul_inventory_snapshot_count", count)
    if valid != 1 || version != c_iSnapshotVersion || count < 0 || count > c_iInventoryCapacity then
      return -1
    end
    for ordinal = 0, c_iInventoryCapacity - 1 do
      local itemID: int = -1
      if ordinal < count then native.GetVariable(GetPersistentSnapshotVariableName(ordinal), itemID) end
      playerOrderSnapshot->set(ordinal, itemID)
    end
    return count
  end

  function CanReusePersistentPlayerSnapshot() -> bool
    local valid: int = 0
    local version: int = 0
    local count: int = 0
    local snapshotGeneration: int = -1
    local currentGeneration: int = 0
    native.GetVariable("inv_overhaul_inventory_snapshot_valid", valid)
    native.GetVariable("inv_overhaul_inventory_snapshot_version", version)
    native.GetVariable("inv_overhaul_inventory_snapshot_count", count)
    native.GetVariable("inv_overhaul_inventory_snapshot_generation", snapshotGeneration)
    native.GetVariable("inv_overhaul_inventory_reorder_generation", currentGeneration)
    if valid != 1 || version != c_iSnapshotVersion || count < 0 || count > c_iInventoryCapacity then return false end
    if snapshotGeneration == currentGeneration then return true end
    return false
  end

  function SavePersistentPlayerSnapshot(count: int) -> void
    if count < 0 then count = 0 end
    if count > c_iInventoryCapacity then count = c_iInventoryCapacity end
    for ordinal = 0, c_iInventoryCapacity - 1 do
      local itemID: int = -1
      playerOrderSnapshot->get(itemID, ordinal)
      native.SetVariable(GetPersistentSnapshotVariableName(ordinal), itemID)
    end
    native.SetVariable("inv_overhaul_inventory_snapshot_count", count)
    native.SetVariable("inv_overhaul_inventory_snapshot_version", c_iSnapshotVersion)
    native.SetVariable("inv_overhaul_inventory_snapshot_valid", 1)
    local generation: int = 0
    native.GetVariable("inv_overhaul_inventory_reorder_generation", generation)
    native.SetVariable("inv_overhaul_inventory_snapshot_generation", generation)
  end

  function PersistCurrentPlayerSnapshot() -> void
    local count: int = CapturePlayerItemIDs(playerOrderSnapshot)
    SavePersistentPlayerSnapshot(count)
  end

  function FindFirstUnusedPersistentCell() -> int
    for linear = 0, c_iInventoryCapacity - 1 do
      local cell: int = GetCellForLinearSlot(linear)
      local used: int = 0
      persistentUsedLayoutCell->get(used, cell)
      if used == 0 then return cell end
    end
    return -1
  end

  function PersistentPlayerSnapshotDiffers(oldCount: int, currentCount: int) -> bool
    if oldCount != currentCount then return true end
    for ordinal = 0, currentCount - 1 do
      local oldID: int
      local currentID: int
      playerOrderSnapshot->get(oldID, ordinal)
      playerCategoryCache->get(currentID, ordinal)
      if oldID != currentID then return true end
    end
    return false
  end

  function ReconcilePersistentPlayerLayout(oldCount: int, currentCount: int) -> void
    for ordinal = 0, c_iInventoryCapacity - 1 do
      playerOrdinalMap->set(ordinal, -1)
      playerIndexCache->set(ordinal, 0)
      persistentUsedLayoutCell->set(ordinal, 0)
    end

    local removalHintValid: int = 0
    local removalHintOrdinal: int = -1
    local removalHintOldCount: int = -1
    native.GetVariable("inv_overhaul_inventory_removed_ordinal_valid", removalHintValid)
    native.GetVariable("inv_overhaul_inventory_removed_ordinal_hint", removalHintOrdinal)
    native.GetVariable("inv_overhaul_inventory_removed_ordinal_old_count", removalHintOldCount)
    local removalHintApplies: bool =
      removalHintValid == 1 &&
      removalHintOldCount == oldCount &&
      currentCount == oldCount - 1 &&
      removalHintOrdinal >= 0 &&
      removalHintOrdinal < oldCount

    if removalHintApplies then
      for oldOrdinal = 0, oldCount - 1 do
        if oldOrdinal < removalHintOrdinal then
          playerOrdinalMap->set(oldOrdinal, oldOrdinal)
          playerIndexCache->set(oldOrdinal, 1)
        end
        if oldOrdinal > removalHintOrdinal then
          playerOrdinalMap->set(oldOrdinal, oldOrdinal - 1)
          playerIndexCache->set(oldOrdinal - 1, 1)
        end
      end
      native.Trace("inv_overhaul_container applied removal hint ordinal=" + removalHintOrdinal +
        " old=" + oldCount + " new=" + currentCount)
    else
      for oldOrdinal = 0, oldCount - 1 do
        if oldOrdinal < currentCount then
          local oldID: int
          local currentID: int
          playerOrderSnapshot->get(oldID, oldOrdinal)
          playerCategoryCache->get(currentID, oldOrdinal)
          if oldID == currentID then
            playerOrdinalMap->set(oldOrdinal, oldOrdinal)
            playerIndexCache->set(oldOrdinal, 1)
          end
        end
      end

      for oldOrdinal = 0, oldCount - 1 do
        local mapped: int = -1
        playerOrdinalMap->get(mapped, oldOrdinal)
        if mapped < 0 then
          local wantedID: int
          playerOrderSnapshot->get(wantedID, oldOrdinal)
          for currentOrdinal = 0, currentCount - 1 do
            local claimed: int
            local currentID: int
            playerIndexCache->get(claimed, currentOrdinal)
            playerCategoryCache->get(currentID, currentOrdinal)
            if claimed == 0 && currentID == wantedID then
              playerOrdinalMap->set(oldOrdinal, currentOrdinal)
              playerIndexCache->set(currentOrdinal, 1)
              currentOrdinal = currentCount
            end
          end
        end
      end
    end
    if removalHintValid == 1 then native.SetVariable("inv_overhaul_inventory_removed_ordinal_valid", 0) end

    for cell = 0, c_iInventoryCapacity - 1 do
      local oldOrder: int = GetOrderValue(cell)
      if oldOrder >= 0 && oldOrder < oldCount then
        local mappedOrder: int
        playerOrdinalMap->get(mappedOrder, oldOrder)
        if mappedOrder >= 0 then
          SetOrderValue(cell, mappedOrder)
          persistentUsedLayoutCell->set(cell, 1)
        end
      end
    end

    for insertedOrder = 0, currentCount - 1 do
      local claimed: int
      playerIndexCache->get(claimed, insertedOrder)
      if claimed == 0 then
        local freeCell: int = FindFirstUnusedPersistentCell()
        if freeCell >= 0 then
          SetOrderValue(freeCell, insertedOrder)
          persistentUsedLayoutCell->set(freeCell, 1)
        end
      end
    end

    local freeOrder: int = currentCount
    for linear = 0, c_iInventoryCapacity - 1 do
      local freeCell: int = GetCellForLinearSlot(linear)
      local used: int
      persistentUsedLayoutCell->get(used, freeCell)
      if used == 0 then
        SetOrderValue(freeCell, freeOrder)
        freeOrder = freeOrder + 1
      end
    end
    NormalizeSlotOrder()
    QueueLayoutSave()
    native.Trace("inv_overhaul_container reconciled generic snapshot old=" + oldCount + " new=" + currentCount)
  end

  function InitializePersistentPlayerSnapshot() -> void
    if CanReusePersistentPlayerSnapshot() then
      CapturePlayerItemIDs(playerOrderSnapshot)
      return
    end
    local currentCount: int = CapturePlayerItemIDs(playerCategoryCache)
    if currentCount > c_iInventoryCapacity then currentCount = c_iInventoryCapacity end
    local oldCount: int = LoadPersistentPlayerSnapshot()
    local changed: bool = oldCount >= 0 && PersistentPlayerSnapshotDiffers(oldCount, currentCount)
    if changed then
      ReconcilePersistentPlayerLayout(oldCount, currentCount)
    end
    for ordinal = 0, c_iInventoryCapacity - 1 do
      local itemID: int = -1
      playerCategoryCache->get(itemID, ordinal)
      playerOrderSnapshot->set(ordinal, itemID)
    end
    if oldCount < 0 || changed then SavePersistentPlayerSnapshot(currentCount) end
    if oldCount < 0 then native.Trace("inv_overhaul_container persistent snapshot initialized count=" + currentCount) end
  end

  function FindInsertedBackpackOrdinal(beforeCount: int) -> int
    local player: object = GetPlayerContainer()
    local oldOrdinal: int = 0
    local newOrdinal: int = 0
    for category = 0, c_iCategoryCount - 1 do
      local count: int
      player->GetItemCount(count, category)
      for index = 0, count - 1 do
        if !IsEquippedItem(category, index) then
          if oldOrdinal >= beforeCount then return newOrdinal end
          local item: object
          local currentItemID: int
          local previousItemID: int
          player->GetItem(item, index, category)
          item->GetItemID(currentItemID)
          playerOrderSnapshot->get(previousItemID, oldOrdinal)
          if currentItemID != previousItemID then return newOrdinal end
          oldOrdinal = oldOrdinal + 1
          newOrdinal = newOrdinal + 1
        end
      end
    end
    return newOrdinal
  end

  function FindSnapshotPlayerOrdinal(oldOrder: int, insertedCategory: int, insertedIndex: int) -> int
    local player: object = GetPlayerContainer()
    local wantedItemID: int
    playerOrderSnapshot->get(wantedItemID, oldOrder)
    local wantedOccurrence: int = 0
    for previousOrder = 0, oldOrder - 1 do
      local previousItemID: int
      playerOrderSnapshot->get(previousItemID, previousOrder)
      if previousItemID == wantedItemID then wantedOccurrence = wantedOccurrence + 1 end
    end
    local ordinal: int = 0
    local occurrence: int = 0
    for category = 0, c_iCategoryCount - 1 do
      local count: int
      player->GetItemCount(count, category)
      for index = 0, count - 1 do
        if !IsEquippedItem(category, index) then
          if category != insertedCategory || index != insertedIndex then
            local item: object
            local itemID: int
            player->GetItem(item, index, category)
            item->GetItemID(itemID)
            if itemID == wantedItemID then
              if occurrence == wantedOccurrence then return ordinal end
              occurrence = occurrence + 1
            end
          end
          ordinal = ordinal + 1
        end
      end
    end
    return -1
  end

  function BuildPlayerOrdinalMapAfterInsert(beforeCount: int, afterCount: int) -> int
    for ordinal = 0, c_iInventoryCapacity - 1 do
      playerOrdinalMap->set(ordinal, -1)
      playerCategoryCache->set(ordinal, -1)
      playerIndexCache->set(ordinal, 0)
    end

    local player: object = GetPlayerContainer()
    local newOrdinal: int = 0
    for category = 0, c_iCategoryCount - 1 do
      local count: int
      player->GetItemCount(count, category)
      for index = 0, count - 1 do
        if !IsEquippedItem(category, index) then
          if newOrdinal < c_iInventoryCapacity then
            local item: object
            local itemID: int
            player->GetItem(item, index, category)
            item->GetItemID(itemID)
            playerCategoryCache->set(newOrdinal, itemID)
          end
          newOrdinal = newOrdinal + 1
        end
      end
    end
    if newOrdinal != afterCount then return -1 end

    for oldOrdinal = 0, beforeCount - 1 do
      local wantedItemID: int
      playerOrderSnapshot->get(wantedItemID, oldOrdinal)
      for currentOrdinal = 0, afterCount - 1 do
        local claimed: int
        local currentItemID: int
        playerIndexCache->get(claimed, currentOrdinal)
        playerCategoryCache->get(currentItemID, currentOrdinal)
        if claimed == 0 && currentItemID == wantedItemID then
          playerOrdinalMap->set(oldOrdinal, currentOrdinal)
          playerIndexCache->set(currentOrdinal, 1)
          currentOrdinal = afterCount
        end
      end
    end

    for oldOrdinal = 0, beforeCount - 1 do
      local mappedOrdinal: int
      playerOrdinalMap->get(mappedOrdinal, oldOrdinal)
      if mappedOrdinal < 0 then return -1 end
    end
    for currentOrdinal = 0, afterCount - 1 do
      local claimed: int
      playerIndexCache->get(claimed, currentOrdinal)
      if claimed == 0 then return currentOrdinal end
    end
    return -1
  end

  function RestorePlayerOrderAfterInsert(beforeCount: int, afterCount: int, preferredSlot: int) -> bool
    if afterCount != beforeCount + 1 || beforeCount >= c_iInventoryCapacity then return false end
    local insertedOrder: int = BuildPlayerOrdinalMapAfterInsert(beforeCount, afterCount)
    if insertedOrder < 0 then
      native.Trace("inv_overhaul_container player order restore failed before=" + beforeCount + " after=" + afterCount)
      return false
    end
    local insertedSlot: int = FindFirstFreePlayerVisual(beforeCount)
    if insertedSlot < 0 then return false end
    for slot = 0, c_iInventoryCapacity - 1 do
      local oldOrder: int = GetOrderValue(slot)
      if oldOrder < beforeCount then
        local mappedOrder: int
        playerOrdinalMap->get(mappedOrder, oldOrder)
        if mappedOrder >= 0 then SetOrderValue(slot, mappedOrder) end
      end
    end
    SetOrderValue(insertedSlot, insertedOrder)
    local preferredCell: int = GetVisibleCell(preferredSlot)
    if preferredSlot >= 0 && preferredSlot < visibleSlots && preferredCell != insertedSlot then
      local preferredOrder: int = GetOrderValue(preferredCell)
      SetOrderValue(preferredCell, insertedOrder)
      SetOrderValue(insertedSlot, preferredOrder)
    end
    NormalizeSlotOrder()
    OrderFreeCellsByDisplay()
    QueueLayoutSave()
    native.Trace("inv_overhaul_container player order restored inserted=" + insertedOrder + " target=" + preferredSlot)
    return true
  end

  function RestorePlayerOrderAfterRemoveMapped(removedOrder: int, beforeCount: int, afterCount: int) -> bool
    if removedOrder < 0 || removedOrder >= beforeCount || afterCount != beforeCount - 1 then return false end
    for ordinal = 0, c_iInventoryCapacity - 1 do
      playerOrdinalMap->set(ordinal, -1)
      playerCategoryCache->set(ordinal, -1)
      playerIndexCache->set(ordinal, 0)
    end

    local player: object = GetPlayerContainer()
    local newOrdinal: int = 0
    for category = 0, c_iCategoryCount - 1 do
      local count: int
      player->GetItemCount(count, category)
      for index = 0, count - 1 do
        if !IsEquippedItem(category, index) then
          if newOrdinal < c_iInventoryCapacity then
            local item: object
            local itemID: int
            player->GetItem(item, index, category)
            item->GetItemID(itemID)
            playerCategoryCache->set(newOrdinal, itemID)
          end
          newOrdinal = newOrdinal + 1
        end
      end
    end
    if newOrdinal != afterCount then return false end

    for oldOrdinal = 0, beforeCount - 1 do
      if oldOrdinal != removedOrder then
        local wantedItemID: int
        playerOrderSnapshot->get(wantedItemID, oldOrdinal)
        for currentOrdinal = 0, afterCount - 1 do
          local claimed: int
          local currentItemID: int
          playerIndexCache->get(claimed, currentOrdinal)
          playerCategoryCache->get(currentItemID, currentOrdinal)
          if claimed == 0 && currentItemID == wantedItemID then
            playerOrdinalMap->set(oldOrdinal, currentOrdinal)
            playerIndexCache->set(currentOrdinal, 1)
            currentOrdinal = afterCount
          end
        end
      end
    end

    for oldOrdinal = 0, beforeCount - 1 do
      if oldOrdinal != removedOrder then
        local mappedOrdinal: int
        playerOrdinalMap->get(mappedOrdinal, oldOrdinal)
        if mappedOrdinal < 0 then return false end
      end
    end

    for cell = 0, c_iInventoryCapacity - 1 do
      local oldOrder: int = GetOrderValue(cell)
      if oldOrder == removedOrder then
        SetOrderValue(cell, afterCount)
      else
        if oldOrder >= 0 && oldOrder < beforeCount then
          local mappedOrder: int
          playerOrdinalMap->get(mappedOrder, oldOrder)
          if mappedOrder >= 0 then SetOrderValue(cell, mappedOrder) end
        end
      end
    end
    NormalizeSlotOrder()
    OrderFreeCellsByDisplay()
    QueueLayoutSave()
    native.Trace("inv_overhaul_container player order restored after remove=" + removedOrder)
    return true
  end

  function FindRemainingPlayerOrdinal(oldOrder: int, removedOrder: int) -> int
    local wantedItemID: int
    local removedItemID: int
    playerOrderSnapshot->get(wantedItemID, oldOrder)
    playerOrderSnapshot->get(removedItemID, removedOrder)
    local wantedOccurrence: int = 0
    for previousOrder = 0, oldOrder - 1 do
      local previousItemID: int
      playerOrderSnapshot->get(previousItemID, previousOrder)
      if previousItemID == wantedItemID then wantedOccurrence = wantedOccurrence + 1 end
    end
    if removedOrder < oldOrder && removedItemID == wantedItemID then
      wantedOccurrence = wantedOccurrence - 1
    end

    local player: object = GetPlayerContainer()
    local ordinal: int = 0
    local occurrence: int = 0
    for category = 0, c_iCategoryCount - 1 do
      local count: int
      player->GetItemCount(count, category)
      for index = 0, count - 1 do
        if !IsEquippedItem(category, index) then
          local item: object
          local itemID: int
          player->GetItem(item, index, category)
          item->GetItemID(itemID)
          if itemID == wantedItemID then
            if occurrence == wantedOccurrence then return ordinal end
            occurrence = occurrence + 1
          end
          ordinal = ordinal + 1
        end
      end
    end
    return -1
  end

  function RestorePlayerOrderAfterRemove(removedOrder: int, beforeCount: int) -> bool
    if removedOrder < 0 || removedOrder >= beforeCount then return false end
    for slot = 0, c_iInventoryCapacity - 1 do
      local oldOrder: int = GetOrderValue(slot)
      if oldOrder == removedOrder then
        SetOrderValue(slot, beforeCount - 1)
      else
        if oldOrder < beforeCount then
          local mappedOrder: int = FindRemainingPlayerOrdinal(oldOrder, removedOrder)
          if mappedOrder >= 0 then SetOrderValue(slot, mappedOrder) end
        end
      end
    end
    NormalizeSlotOrder()
    OrderFreeCellsByDisplay()
    QueueLayoutSave()
    return true
  end

  function InsertOrderOrdinalAt(insertedOrder: int, beforeCount: int, preferredSlot: int) -> bool
    if insertedOrder < 0 then return false end
    if beforeCount >= c_iInventoryCapacity then return false end
    local insertedSlot: int = FindFirstFreePlayerVisual(beforeCount)
    if insertedSlot < 0 then return false end
    for slot = 0, c_iInventoryCapacity - 1 do
      local order: int = GetOrderValue(slot)
      if slot != insertedSlot && order >= insertedOrder && order < beforeCount then SetOrderValue(slot, order + 1) end
    end
    SetOrderValue(insertedSlot, insertedOrder)
    local preferredCell: int = GetVisibleCell(preferredSlot)
    if preferredSlot >= 0 && preferredSlot < visibleSlots && preferredCell != insertedSlot then
      local preferredOrder: int = GetOrderValue(preferredCell)
      SetOrderValue(preferredCell, insertedOrder)
      SetOrderValue(insertedSlot, preferredOrder)
    end
    NormalizeSlotOrder()
    OrderFreeCellsByDisplay()
    QueueLayoutSave()
    return true
  end

  function FindFirstFreeContainerVisual(itemCount: int) -> int
    for visual = 0, c_iMaxContainerVisuals - 1 do
      if GetContainerOrderValue(visual) >= itemCount then return visual end
    end
    return -1
  end

  function InsertContainerOrdinalAt(insertedOrder: int, beforeCount: int, preferredSlot: int) -> bool
    if insertedOrder < 0 then return false end
    if beforeCount >= c_iMaxContainerVisuals then return false end
    local preferredVisual: int = containerPage * c_iContainerSlots + preferredSlot
    local insertedVisual: int = -1
    for visual = 0, c_iMaxContainerVisuals - 1 do
      local order: int = GetContainerOrderValue(visual)
      if order == beforeCount then
        SetContainerOrderValue(visual, insertedOrder)
        insertedVisual = visual
      else
        if order >= insertedOrder && order < beforeCount then SetContainerOrderValue(visual, order + 1) end
      end
    end
    if insertedVisual < 0 then return false end
    if preferredSlot >= 0 && preferredSlot < c_iContainerSlots && preferredVisual != insertedVisual then
      local preferredOrder: int = GetContainerOrderValue(preferredVisual)
      SetContainerOrderValue(preferredVisual, insertedOrder)
      SetContainerOrderValue(insertedVisual, preferredOrder)
    end
    return true
  end

  function FindFirstFreeOrganVisual(itemCount: int) -> int
    for visual = 0, c_iOrganSlots - 1 do
      if GetOrganOrderValue(visual) >= itemCount then return visual end
    end
    return -1
  end

  function InsertOrganOrdinalAt(insertedOrder: int, beforeCount: int, preferredSlot: int) -> bool
    if insertedOrder < 0 then return false end
    local freeSlot: int = -1
    if preferredSlot >= 0 && preferredSlot < c_iOrganSlots then
      if GetOrganOrderValue(preferredSlot) >= beforeCount then freeSlot = preferredSlot end
    end
    if freeSlot < 0 then freeSlot = FindFirstFreeOrganVisual(beforeCount) end
    if freeSlot < 0 then return false end
    local preferredOccupied: bool = preferredSlot >= 0 && preferredSlot < c_iOrganSlots && GetOrganOrderValue(preferredSlot) < beforeCount
    for visual = 0, c_iOrganSlots - 1 do
      if visual != freeSlot then
        local order: int = GetOrganOrderValue(visual)
        if order >= insertedOrder && order < beforeCount then SetOrganOrderValue(visual, order + 1) end
      end
    end
    if preferredOccupied then
      SetOrganOrderValue(freeSlot, GetOrganOrderValue(preferredSlot))
      SetOrganOrderValue(preferredSlot, insertedOrder)
    else
      SetOrganOrderValue(freeSlot, insertedOrder)
    end
    return true
  end

  function RemoveContainerOrdinal(removedOrder: int, beforeCount: int) -> void
    if removedOrder < 0 then return end
    local emptyOrder: int = beforeCount - 1
    for visual = 0, c_iMaxContainerVisuals - 1 do
      local order: int = GetContainerOrderValue(visual)
      if order == removedOrder then
        SetContainerOrderValue(visual, emptyOrder)
      else
        if order > removedOrder && order < beforeCount then SetContainerOrderValue(visual, order - 1) end
      end
    end
  end

  function RemoveOrganOrdinal(removedOrder: int, beforeCount: int) -> void
    if removedOrder < 0 then return end
    local emptyOrder: int = beforeCount - 1
    for visual = 0, c_iOrganSlots - 1 do
      local order: int = GetOrganOrderValue(visual)
      if order == removedOrder then
        SetOrganOrderValue(visual, emptyOrder)
      else
        if order > removedOrder && order < beforeCount then SetOrganOrderValue(visual, order - 1) end
      end
    end
  end

  function TogglePlayerSlot(category: int, index: int) -> void
    local container: object = GetPlayerContainer()
    local item: object
    container->GetItem(item, index, category)
    if !item then return end
    local itemID: int
    item->GetItemID(itemID)
    local amount: int
    container->GetItemAmount(amount, index, category)
    local selected: bool
    container->IsItemSelected(selected, index, category)

    if category == c_iCWeapon then
      local weapon: bool
      native.HasInvItemProperty(weapon, itemID, "Weapon")
      if !weapon then return end
      if selected then
        container->SelectItem(index, false, category)
        native.SetPlayerHandsItem(-1)
      else
        native.SetPlayerHandsItem(itemID)
        local count: int
        container->GetItemCount(count, category)
        for i = 0, count - 1 do
          local otherSelected: bool
          container->IsItemSelected(otherSelected, i, category)
          if otherSelected then container->SelectItem(i, false, category) end
        end
        container->SelectItem(index, true, category)
      end
      return
    end

    if category == c_iCClothes then
      local hasGroup: bool
      native.HasInvItemProperty(hasGroup, itemID, "Group")
      if !hasGroup then return end
      local group: int
      native.GetInvItemProperty(group, itemID, "Group")
      if selected then
        container->SelectItem(index, false, category)
      else
        local count: int
        container->GetItemCount(count, category)
        for i = 0, count - 1 do
          local other: object
          container->GetItem(other, i, category)
          local otherID: int
          other->GetItemID(otherID)
          local otherHasGroup: bool
          native.HasInvItemProperty(otherHasGroup, otherID, "Group")
          if otherHasGroup then
            local otherGroup: int
            native.GetInvItemProperty(otherGroup, otherID, "Group")
            if otherGroup == group then container->SelectItem(i, false, category) end
          end
        end
        container->SelectItem(index, true, category)
      end
      return
    end

    local used: bool
    native.UseItem(index, category, used)
    if used then
      deferredInventoryRefresh = 0.25
      amount = amount - 1
      if amount == 0 then container->RemoveItem(index, 1, category) else container->SetItemAmount(amount, index, category) end
    end
  end

  function FindPlayerTransferMarkerIndex(category: int) -> int
    local player: object = GetPlayerContainer()
    local count: int
    player->GetItemCount(count, category)
    for index = 0, count - 1 do
      local item: object
      player->GetItem(item, index, category)
      local hasMarker: bool = false
      item->HasProperty(hasMarker, "InvOverhaulTransferMarker")
      if hasMarker then return index end
    end
    return -1
  end

  function FindPlayerItemIndexByID(category: int, wantedItemID: int) -> int
    local player: object = GetPlayerContainer()
    local count: int
    player->GetItemCount(count, category)
    for index = 0, count - 1 do
      local candidate: object
      player->GetItem(candidate, index, category)
      local candidateID: int
      candidate->GetItemID(candidateID)
      if candidateID == wantedItemID then return index end
    end
    return -1
  end

  function GetPlayerItemTotalAmount(category: int, wantedItemID: int) -> int
    local player: object = GetPlayerContainer()
    local count: int
    local total: int = 0
    player->GetItemCount(count, category)
    for index = 0, count - 1 do
      local candidate: object
      player->GetItem(candidate, index, category)
      if candidate then
        local candidateID: int
        candidate->GetItemID(candidateID)
        if candidateID == wantedItemID then
          local candidateAmount: int
          player->GetItemAmount(candidateAmount, index, category)
          total = total + candidateAmount
        end
      end
    end
    return total
  end

  function FindExternalTransferMarkerOrdinal(organItem: bool) -> int
    local external: object = GetExternalContainer()
    local count: int
    external->GetItemCount(count)
    local ordinal: int = 0
    for index = 0, count - 1 do
      local item: object
      external->GetItem(item, index)
      if IsOrganItem(item) == organItem then
        local hasMarker: bool = false
        item->HasProperty(hasMarker, "InvOverhaulTransferMarker")
        if hasMarker then
          item->RemoveProperty("InvOverhaulTransferMarker")
          return ordinal
        end
        ordinal = ordinal + 1
      end
    end
    return -1
  end

  function FindExternalItemOrdinalByID(organItem: bool, wantedItemID: int) -> int
    local external: object = GetExternalContainer()
    local count: int
    external->GetItemCount(count)
    local ordinal: int = 0
    for index = 0, count - 1 do
      local candidate: object
      external->GetItem(candidate, index)
      if IsOrganItem(candidate) == organItem then
        local candidateID: int
        candidate->GetItemID(candidateID)
        if candidateID == wantedItemID then return ordinal end
        ordinal = ordinal + 1
      end
    end
    return -1
  end

  function GetExternalItemTotalAmount(wantedItemID: int) -> int
    local external: object = GetExternalContainer()
    if !external then return 0 end
    local count: int
    external->GetItemCount(count)
    local total: int = 0
    for index = 0, count - 1 do
      local candidate: object
      external->GetItem(candidate, index)
      if candidate then
        local candidateID: int
        candidate->GetItemID(candidateID)
        if candidateID == wantedItemID then
          local candidateAmount: int
          external->GetItemAmount(candidateAmount, index)
          total = total + candidateAmount
        end
      end
    end
    return total
  end

  function MovePlayerAmountToContainer(sourceSlot: int, targetSlot: int, asOrgan: bool, requestedAmount: int) -> void
    local category: int = -1
    local index: int = -1
    if dragKind == 0 && dragPlayerCategory >= 0 && dragPlayerIndex >= 0 then
      category = dragPlayerCategory
      index = dragPlayerIndex
    else
      if !ResolveVisibleSlot(sourceSlot) then return end
      category = resolvedCategory
      index = resolvedIndex
    end
    local player: object = GetPlayerContainer()
    local external: object = GetExternalContainer()
    if !external then return end

    local beforeBackpack: int = GetBackpackItemCount()
    local usedOrder: int = GetBackpackOrdinal(category, index)
    local beforeExternal: int
    if asOrgan then beforeExternal = GetOrganItemCount() else beforeExternal = GetNormalContainerItemCount() end
    if !asOrgan && beforeExternal >= c_iMaxContainerVisuals then
      ShowContainerFull()
      return
    end
    local item: object
    player->GetItem(item, index, category)
    if !item then return end
    local availableAmount: int
    player->GetItemAmount(availableAmount, index, category)
    local transferAmount: int = requestedAmount
    if transferAmount <= 0 || transferAmount > availableAmount then transferAmount = availableAmount end
    if transferAmount <= 0 then return end
    local itemID: int
    item->GetItemID(itemID)
    local beforeExternalAmount: int = GetExternalItemTotalAmount(itemID)
    SnapshotExistingPlayerOrder()

    if asOrgan then
      item->RemoveProperty("InvOverhaulOrgan")
      item->SetProperty("Organ", 1)
    end
    local success: bool
    external->AddItem(success, item, 0, transferAmount)
    local afterExternalAmount: int = GetExternalItemTotalAmount(itemID)
    local addedAmount: int = afterExternalAmount - beforeExternalAmount
    if !success || addedAmount <= 0 then
      if asOrgan then
        item->RemoveProperty("Organ")
        item->SetProperty("InvOverhaulOrgan", 1)
      end
      ShowContainerFull()
      native.Trace("inv_overhaul_container player-to-container rejected slot=" + sourceSlot + " success=" + success + " before_amount=" + beforeExternalAmount + " after_amount=" + afterExternalAmount)
      if asOrgan then UpdateOrganSlots() else RefreshVisibleContainerItem(itemID, targetSlot) end
      return
    end

    if category == c_iCWeapon then
      local selected: bool
      player->IsItemSelected(selected, index, category)
      if selected then native.SetPlayerHandsItem(-1) end
    end
    if addedAmount > transferAmount then addedAmount = transferAmount end
    player->RemoveItem(index, addedAmount, category)

    local afterBackpack: int = GetBackpackItemCount()
    if afterBackpack < beforeBackpack then
      if !RestorePlayerOrderAfterRemoveMapped(usedOrder, beforeBackpack, afterBackpack) then
        RemoveOrderOrdinal(usedOrder, beforeBackpack)
        native.Trace("inv_overhaul_container player remove fallback ordinal=" + usedOrder)
      end
    end
    local afterExternal: int
    if asOrgan then afterExternal = GetOrganItemCount() else afterExternal = GetNormalContainerItemCount() end
    if afterExternal > beforeExternal then
      if asOrgan then InsertOrganOrdinalAt(beforeExternal, beforeExternal, targetSlot) else InsertContainerOrdinalAt(beforeExternal, beforeExternal, targetSlot) end
    end
    if !asOrgan && beforeExternal <= c_iContainerSlots && afterExternal > c_iContainerSlots then
      native.Trace("inv_overhaul_container corpse/container page 2 activated count=" + afterExternal)
    end
    RefreshVisiblePlayerItem(itemID, sourceSlot)
    if asOrgan then UpdateOrganSlots() else RefreshVisibleContainerItem(itemID, targetSlot) end
    UpdateMoney()
  end

  function MovePlayerToContainer(sourceSlot: int, targetSlot: int, asOrgan: bool) -> void
    MovePlayerAmountToContainer(sourceSlot, targetSlot, asOrgan, 1)
  end

  function MoveExternalAmountToPlayer(organSource: bool, sourceSlot: int, targetSlot: int, requestedAmount: int) -> void
    if RefreshDroppedRubbishKind(true) then return end
    local sourceIndex: int = -1
    local sourceOrdinal: int = -1
    if dragKind >= 1 && dragContainerIndex >= 0 then
      sourceIndex = dragContainerIndex
      sourceOrdinal = dragContainerOrdinal
    else
      local found: bool
      if organSource then found = ResolveOrganVisualSlot(sourceSlot) else found = ResolveContainerVisualSlot(sourceSlot) end
      if !found then return end
      sourceIndex = resolvedContainerIndex
      sourceOrdinal = resolvedContainerOrdinal
    end

    local external: object = GetExternalContainer()
    local player: object = GetPlayerContainer()
    local beforeNormal: int = GetNormalContainerItemCount()
    local beforeOrgans: int = GetOrganItemCount()
    local beforeBackpack: int = GetBackpackItemCount()
    local item: object
    local amount: int
    external->GetItem(item, sourceIndex)
    external->GetItemAmount(amount, sourceIndex)
    if !item || amount <= 0 then return end
    local transferAmount: int = requestedAmount
    if transferAmount <= 0 || transferAmount > amount then transferAmount = amount end
    if transferAmount <= 0 then return end

    local itemID: int
    item->GetItemID(itemID)
    local externalStackCount: int = 0
    external->GetItemCount(externalStackCount)
    local closesDroppedRubbish: bool = isDroppedRubbishHeap && externalStackCount <= 1
    if itemID == moneyItemID then
      local money: int
      player->GetProperty("money", money)
      player->SetProperty("money", money + amount)
      external->RemoveItem(sourceIndex, amount)
      if closesDroppedRubbish then
        native.Trace("INV_OVERHAUL_EFFECT_LIFECYCLE loot removed final money stack; closing rubbish heap")
        windowClosing = true
        CloseContainerWindow()
        return
      end
      if organSource then RemoveOrganOrdinal(sourceOrdinal, beforeOrgans) else RemoveContainerOrdinal(sourceOrdinal, beforeNormal) end
      native.Trace("inv_overhaul_container took money amount=" + amount)
      if organSource then UpdateOrganSlots() else RefreshVisibleContainerItem(itemID, sourceSlot) end
      UpdateMoney()
      return
    end

    local category: int
    native.GetInvItemProperty(category, itemID, "Category")
    if !CanPlayerAcceptItem(item, category) then
      ShowInventoryFull()
      native.Trace("inv_overhaul_container container-to-player refused: inventory full")
      return
    end
    local beforePlayerAmount: int = GetPlayerItemTotalAmount(category, itemID)
    SnapshotExistingPlayerOrder()
    if organSource then
      item->SetProperty("InvOverhaulOrgan", 1)
      item->RemoveProperty("Organ")
    end
    local success: bool
    player->AddItem(success, item, category, transferAmount)
    local afterPlayerAmount: int = GetPlayerItemTotalAmount(category, itemID)
    local addedAmount: int = afterPlayerAmount - beforePlayerAmount
    if !success || addedAmount <= 0 then
      if organSource then
        item->RemoveProperty("InvOverhaulOrgan")
        item->SetProperty("Organ", 1)
      end
      ShowInventoryFull()
      native.Trace("inv_overhaul_container container-to-player rejected source=" + sourceSlot + " success=" + success + " before_amount=" + beforePlayerAmount + " after_amount=" + afterPlayerAmount)
      if organSource then UpdateOrganSlots() else RefreshVisibleContainerItem(itemID, sourceSlot) end
      return
    end

    if addedAmount > transferAmount then addedAmount = transferAmount end
    if closesDroppedRubbish && addedAmount >= amount then
      external->RemoveItem(sourceIndex, addedAmount)
      native.Trace("INV_OVERHAUL_EFFECT_LIFECYCLE loot removed final item stack; closing rubbish heap")
      windowClosing = true
      CloseContainerWindow()
      return
    end
    external->RemoveItem(sourceIndex, addedAmount)
    if addedAmount >= amount then
      if organSource then
        RemoveOrganOrdinal(sourceOrdinal, beforeOrgans)
      else
        RemoveContainerOrdinal(sourceOrdinal, beforeNormal)
      end
    end

    local afterBackpack: int = GetBackpackItemCount()
    if afterBackpack > beforeBackpack then
      if !RestorePlayerOrderAfterInsert(beforeBackpack, afterBackpack, targetSlot) then
        local insertedOrder: int = FindInsertedBackpackOrdinal(beforeBackpack)
        InsertOrderOrdinalAt(insertedOrder, beforeBackpack, targetSlot)
        native.Trace("inv_overhaul_container player insert fallback ordinal=" + insertedOrder + " target=" + targetSlot)
      end
    end
    if organSource then native.PlaySound("take_organ") end
    RefreshVisiblePlayerItem(itemID, targetSlot)
    if organSource then UpdateOrganSlots() else RefreshVisibleContainerItem(itemID, sourceSlot) end
    UpdateMoney()
  end

  function MoveExternalToPlayer(organSource: bool, sourceSlot: int, targetSlot: int) -> void
    MoveExternalAmountToPlayer(organSource, sourceSlot, targetSlot, 1)
  end

  function DropPlayerToWorld(sourceSlot: int, requestedAmount: int) -> void
    if !ResolveVisibleSlot(sourceSlot) then return end
    local player: object = GetPlayerContainer()
    local category: int = resolvedCategory
    local index: int = resolvedIndex
    local beforeBackpack: int = GetBackpackItemCount()
    local usedOrder: int = GetBackpackOrdinal(category, index)
    local item: object
    player->GetItem(item, index, category)
    if !item then return end
    local availableAmount: int
    player->GetItemAmount(availableAmount, index, category)
    local amount: int = requestedAmount
    if amount <= 0 || amount > availableAmount then amount = availableAmount end
    if amount <= 0 then return end
    if category == c_iCWeapon then
      local selected: bool
      player->IsItemSelected(selected, index, category)
      if selected then native.SetPlayerHandsItem(-1) end
    end
    player->DropItems(item, amount)
    player->RemoveItem(index, amount, category)
    if GetBackpackItemCount() < beforeBackpack then RemoveOrderOrdinal(usedOrder, beforeBackpack) end
    UpdateAllSlots()
  end

  function HandleModifiedDrop(source: int) -> bool
    if !shiftHeld && !controlHeld then return false end
    if source < 0 || source >= visibleSlots then return false end
    if !ResolveVisibleSlot(source) then return true end

    if controlHeld && !shiftHeld then
      MovePlayerSlotToOtherPage(source)
      return true
    end

    local amount: int
    local player: object = GetPlayerContainer()
    player->GetItemAmount(amount, resolvedIndex, resolvedCategory)
    DropPlayerToWorld(source, amount)
    return true
  end

  function MovePlayerSlotToOtherPage(sourceSlot: int) -> void
    local maxPage: int = GetMaxPlayerPage()
    if maxPage <= 0 then return end

    local targetPage: int = playerPage + 1
    if targetPage > maxPage then targetPage = 0 end
    local backpackCount: int = GetBackpackItemCount()
    local targetCell: int = -1
    for targetSlot = 0, visibleSlots - 1 do
      local linear: int = targetPage * visibleSlots + targetSlot
      local cell: int = GetCellForLinearSlot(linear)
      if cell >= 0 && GetOrderValue(cell) >= backpackCount then
        targetCell = cell
        targetSlot = visibleSlots
      end
    end
    if targetCell < 0 then
      ShowInventoryFull()
      return
    end

    SwapSlotOrderCells(GetVisibleCell(sourceSlot), targetCell)
    native.Trace("inv_overhaul_container ctrl-page-move sourcePage=" + playerPage + " targetPage=" + targetPage)
  end

  function ResolveDragSource(source: int) -> bool
    dragKind = -1
    dragPlayerCategory = -1
    dragPlayerIndex = -1
    dragPlayerCell = -1
    dragContainerIndex = -1
    dragContainerOrdinal = -1
    dragContainerVisual = -1
    dragPlayerIsOrgan = false
    local item: object

    if source >= 0 && source < visibleSlots then
      if !ResolveVisibleSlot(source) then return false end
      dragKind = 0
      dragPlayerCategory = resolvedCategory
      dragPlayerIndex = resolvedIndex
      dragPlayerCell = GetVisibleCell(source)
      dragPlayerIsOrgan = IsPlayerOrganItem(dragPlayerCategory, dragPlayerIndex)
      local player: object = GetPlayerContainer()
      player->GetItem(item, dragPlayerIndex, dragPlayerCategory)
    else
      if source >= c_iTargetContainerBase && source < c_iTargetContainerBase + c_iContainerSlots then
        if !ResolveContainerVisualSlot(source - c_iTargetContainerBase) then return false end
        dragKind = 1
        dragContainerVisual = containerPage * c_iContainerSlots + source - c_iTargetContainerBase
      else
        if source >= c_iTargetOrganBase && source < c_iTargetOrganBase + c_iOrganSlots then
          if !ResolveOrganVisualSlot(source - c_iTargetOrganBase) then return false end
          dragKind = 2
        else
          return false
        end
      end
      dragContainerIndex = resolvedContainerIndex
      dragContainerOrdinal = resolvedContainerOrdinal
      local external: object = GetExternalContainer()
      external->GetItem(item, dragContainerIndex)
    end

    if !item then return false end
    item->GetItemID(dragItemID)
    return true
  end

  function BeginDragCursor(source: int) -> bool
    native.SetVariable("inv_overhaul_inventory_drag_item", -1)
    dragItemID = -1
    if !ResolveDragSource(source) then return false end
    native.SetVariable("inv_overhaul_inventory_drag_item", dragItemID)
    return true
  end

  function EndDragCursor() -> void
    native.SetVariable("inv_overhaul_inventory_drag_item", -1)
    native.SetVariable("inv_overhaul_inventory_page_hover", 0)
    dragItemID = -1
    dragKind = -1
    dragPlayerCategory = -1
    dragPlayerIndex = -1
    dragPlayerCell = -1
    dragContainerIndex = -1
    dragContainerOrdinal = -1
    dragContainerVisual = -1
    dragPlayerIsOrgan = false
  end

  function GetPlayerSlotBySender(sender: string) -> int
    for slot = 0, visibleSlots - 1 do
      if sender == GetSlotWndName(slot) then return slot end
    end
    return -1
  end

  function GetContainerSlotBySender(sender: string) -> int
    for slot = 0, c_iContainerSlots - 1 do
      if sender == GetContainerSlotWndName(slot) then return slot end
    end
    return -1
  end

  function GetOrganSlotBySender(sender: string) -> int
    for slot = 0, c_iOrganSlots - 1 do
      if sender == GetOrganSlotWndName(slot) then return slot end
    end
    return -1
  end

  function GetTargetBySender(sender: string) -> int
    local slot: int = GetPlayerSlotBySender(sender)
    if slot >= 0 then return slot end
    slot = GetContainerSlotBySender(sender)
    if slot >= 0 then return c_iTargetContainerBase + slot end
    slot = GetOrganSlotBySender(sender)
    if slot >= 0 then return c_iTargetOrganBase + slot end
    if sender == "drop_slot" then return c_iTargetDrop end
    return -1
  end

  function IsInsideSlotDropArea(localX: int, localY: int, hotZone: int) -> bool
    return localX >= c_iSlotDropInset && localY >= c_iSlotDropInset &&
      localX < hotZone - c_iSlotDropInset && localY < hotZone - c_iSlotDropInset
  end

  function GetSlotHotZone() -> int
    if windowWidth >= 1900 then return 82 end
    return c_iSlotHotZone
  end

  function GetOrganSlotHotZone() -> int
    if windowWidth >= 1900 then return 57 end
    return c_iSlotHotZone
  end

  function FindGridSlotAt(x: int, y: int, startX: int, startY: int, columns: int, rows: int, count: int, hotZone: int, step: int) -> int
    if x < startX || y < startY || x >= startX + columns * step || y >= startY + rows * step then return -1 end
    local column: int = (x - startX) / step
    local row: int = (y - startY) / step
    local localX: int = x - startX - column * step
    local localY: int = y - startY - row * step
    if !IsInsideSlotDropArea(localX, localY, hotZone) then return -1 end
    local slot: int = row * columns + column
    if slot < 0 || slot >= count then return -1 end
    return slot
  end

  function FindPlayerSlotAt(x: int, y: int) -> int
    local columns: int = GetGridColumns()
    local rows: int = (visibleSlots + columns - 1) / columns
    return FindGridSlotAt(x, y, GetGridStartX(), GetGridStartY(), columns, rows, visibleSlots, GetSlotHotZone(), GetGridStep())
  end

  function FindContainerSlotAt(x: int, y: int) -> int
    return FindGridSlotAt(x, y, GetContainerStartX(), GetContainerStartY(), 3, 4, c_iContainerSlots, GetSlotHotZone(), GetGridStep())
  end

  function FindOrganSlotAt(x: int, y: int) -> int
    if !showOrgans then return -1 end
    return FindGridSlotAt(x, y, GetOrganStartX(), GetOrganStartY(), 4, 1, c_iOrganSlots, GetOrganSlotHotZone(), GetOrganStep())
  end

  function IsInsideMoney(x: int, y: int) -> bool
    local left: int = GetMoneyLeft()
    local top: int = GetMoneyTop()
    local hotZone: int = GetSlotHotZone()
    return x >= left && y >= top && x < left + hotZone && y < top + hotZone
  end

  function FindTargetAt(x: int, y: int) -> int
    local slot: int = FindPlayerSlotAt(x, y)
    if slot >= 0 then return slot end
    slot = FindContainerSlotAt(x, y)
    if slot >= 0 then return c_iTargetContainerBase + slot end
    slot = FindOrganSlotAt(x, y)
    if slot >= 0 then return c_iTargetOrganBase + slot end
    return -1
  end

  function IsTargetCompatible(target: int) -> bool
    if dragKind == 0 then
      if target >= 0 && target < visibleSlots then return true end
      if target >= c_iTargetContainerBase && target < c_iTargetContainerBase + c_iContainerSlots then return true end
      return false
    end
    if dragKind == 1 then
      if target >= 0 && target < visibleSlots then return true end
      return target >= c_iTargetContainerBase && target < c_iTargetContainerBase + c_iContainerSlots
    end
    if dragKind == 2 then return target >= 0 && target < visibleSlots end
    return false
  end

  function SetHighlightedTarget(target: int) -> void
    if dragSource >= 0 && target >= 0 && !IsTargetCompatible(target) then target = -1 end
    if highlightedTarget == target then return end
    if highlightedTarget >= 0 then native.SendMessage(-21, GetTargetWndName(highlightedTarget)) end
    highlightedTarget = target
    if highlightedTarget >= 0 then native.SendMessage(-20, GetTargetWndName(highlightedTarget)) end
  end

  function ApplyPointerTarget(target: int) -> void
    if dragSource < 0 then return end
    local sameSource: bool = false
    if target == dragSource then sameSource = true end
    if dragKind == 0 && target >= 0 && target < visibleSlots then
      if GetVisibleCell(target) == dragPlayerCell then sameSource = true else sameSource = false end
    end
    if dragKind == 1 && target >= c_iTargetContainerBase && target < c_iTargetContainerBase + c_iContainerSlots then
      if containerPage * c_iContainerSlots + target - c_iTargetContainerBase == dragContainerVisual then sameSource = true else sameSource = false end
    end
    if target >= 0 && !sameSource && IsTargetCompatible(target) then
      lastValidDropTarget = target
      invalidDropTargetFrames = 0
      SetHighlightedTarget(target)
    else
      if target < 0 then invalidDropTargetFrames = invalidDropTargetFrames + 1 else invalidDropTargetFrames = 0 end
      SetHighlightedTarget(-1)
    end
  end

  function StartDragAction(source: int, sender: string) -> void
    if dragSource >= 0 then return end
    CancelDragPageHover(0)
    ClearPanelTooltip()
    if !BeginDragCursor(source) then return end
    dragSource = source
    lastValidDropTarget = -1
    invalidDropTargetFrames = 0
    SetHighlightedTarget(-1)
  end

  function FinishDrag(target: int) -> void
    if dragSource < 0 then return end
    if target < 0 && lastValidDropTarget >= 0 && invalidDropTargetFrames <= 3 then target = lastValidDropTarget end
    local source: int = dragSource
    local sourceKind: int = dragKind
    tooltipResumeDelay = 0.2
    ClearPanelTooltip()
    if source >= 0 then
      native.SendMessage(-130, GetTargetWndName(source))
    end
    if target >= 0 then
      native.SendMessage(-130, GetTargetWndName(target))
    end

    if IsTargetCompatible(target) then
      if sourceKind == 0 then
        if target >= 0 && target < visibleSlots then
          if GetVisibleCell(target) != dragPlayerCell then
            SwapSlotOrderCells(dragPlayerCell, GetVisibleCell(target))
          end
        else
          if target >= c_iTargetContainerBase && target < c_iTargetContainerBase + c_iContainerSlots then
            MovePlayerToContainer(source, target - c_iTargetContainerBase, false)
          end
        end
      else
        if target >= 0 && target < visibleSlots then
          if sourceKind == 1 then
            MoveExternalToPlayer(false, source - c_iTargetContainerBase, target)
          else
            MoveExternalToPlayer(true, source - c_iTargetOrganBase, target)
          end
        else
          if sourceKind == 1 && target >= c_iTargetContainerBase && target < c_iTargetContainerBase + c_iContainerSlots then
            SwapContainerSlotOrderVisuals(dragContainerVisual, containerPage * c_iContainerSlots + target - c_iTargetContainerBase)
          end
        end
      end
    end

    dragSource = -1
    SetHighlightedTarget(-1)
    lastValidDropTarget = -1
    invalidDropTargetFrames = 0
    EndDragCursor()
    CancelDragPageHover(0)
  end

  function QuickTransfer(source: int) -> void
    if source >= 0 && source < visibleSlots then
      if !ResolveVisibleSlot(source) then return end
      local visual: int = FindFirstFreeContainerVisual(GetNormalContainerItemCount())
      if visual < 0 then
        ShowContainerFull()
        native.Trace("inv_overhaul_container quick player-to-container refused: no visual slot")
        return
      end
      containerPage = visual / c_iContainerSlots
      if shiftHeld then
        MovePlayerAmountToContainer(source, visual - containerPage * c_iContainerSlots, false, -1)
      else
        MovePlayerToContainer(source, visual - containerPage * c_iContainerSlots, false)
      end
      return
    end

    local playerVisual: int = FindFirstFreePlayerVisual(GetBackpackItemCount())
    if playerVisual < 0 then playerVisual = 0 end
    local playerLinear: int = playerVisual
    if visibleSlots < c_iInventoryCapacity then
      playerLinear = playerVisual - 16
      if playerLinear < 0 then playerLinear = playerLinear + c_iInventoryCapacity end
    end
    playerPage = playerLinear / visibleSlots
    local playerTarget: int = playerLinear - playerPage * visibleSlots
    if source >= c_iTargetContainerBase && source < c_iTargetContainerBase + c_iContainerSlots then
      if shiftHeld then
        MoveExternalAmountToPlayer(false, source - c_iTargetContainerBase, playerTarget, -1)
      else
        MoveExternalToPlayer(false, source - c_iTargetContainerBase, playerTarget)
      end
      return
    end
    if source >= c_iTargetOrganBase && source < c_iTargetOrganBase + c_iOrganSlots then
      if shiftHeld then
        MoveExternalAmountToPlayer(true, source - c_iTargetOrganBase, playerTarget, -1)
      else
        MoveExternalToPlayer(true, source - c_iTargetOrganBase, playerTarget)
      end
    end
  end

  function GetSlotTargetFromPointerMessage(message: int, base: int, sender: string) -> int
    local target: int = GetTargetBySender(sender)
    if target < 0 then return -1 end
    local encoded: int = message - base
    local localX: int = encoded / 100
    local localY: int = encoded - localX * 100
    local hotZone: int = GetSlotHotZone()
    if target >= c_iTargetOrganBase && target < c_iTargetOrganBase + c_iOrganSlots then
      hotZone = GetOrganSlotHotZone()
    end
    if IsInsideSlotDropArea(localX, localY, hotZone) then return target end
    return -1
  end

  function ClearPanelTooltip() -> void
    if panelTooltipTarget != -1 then
    end
    panelTooltipTarget = -1
    native.SendMessage(-1, "panel_background")
  end

  function ShowPlayerPagingTooltip() -> void
    panelTooltipTarget = c_iTargetPaging
    native.SetVariable("inv_overhaul_inventory_tooltip_item", -1)
    native.SetVariable("inv_overhaul_inventory_tooltip_text_id", 1404)
    native.SetVariable("inv_overhaul_inventory_tooltip_type", 5)
  end

  function ShowQuickslotHelpPanelTooltip() -> void
    panelTooltipTarget = c_iTargetQuickslotHelp
    native.SetVariable("inv_overhaul_inventory_tooltip_item", -1)
    native.SetVariable("inv_overhaul_inventory_tooltip_text_id", 1407)
    native.SetVariable("inv_overhaul_inventory_tooltip_type", 5)
  end

  function IsInsideQuickslotHelp(x: int, y: int) -> bool
    local helpX: int = 701
    local helpY: int = 121
    if windowWidth >= 1900 then
      helpX = 1486
      helpY = 211
    else
    if windowWidth >= 1200 then
      helpX = 1166
      helpY = 151
    else
    if windowWidth >= 1000 then
      helpX = 918
      helpY = 135
    end
    end
    end
    return x >= helpX && x < helpX + 28 && y >= helpY && y < helpY + 28
  end

  function IsInsidePlayerPaging(x: int, y: int) -> bool
    if GetMaxPlayerPage() <= 0 then return false end
    local playerX: int = 467
    local playerY: int = 481
    if windowWidth >= 1900 then
      playerX = 1082
      playerY = 826
    else
    if windowWidth >= 1000 then
      playerX = 626
      playerY = 632
    end
    end
    return x >= playerX && x < playerX + 132 && y >= playerY && y < playerY + 36
  end

  function UpdatePanelTooltip(x: int, y: int) -> void
    if tooltipResumeDelay > 0 then
      ClearPanelTooltip()
      return
    end
    if dragSource >= 0 then
      ClearPanelTooltip()
      return
    end
    if IsInsideQuickslotHelp(x, y) then
      ShowQuickslotHelpPanelTooltip()
      return
    end
    if IsInsidePlayerPaging(x, y) then
      ShowPlayerPagingTooltip()
      return
    end
    if IsInsideMoney(x, y) then
      if panelTooltipTarget != c_iTargetMoney then
        panelTooltipTarget = c_iTargetMoney
        native.SendMessage(1, "panel_background", moneyTooltipItem)
      end
      return
    end

    local target: int = FindTargetAt(x, y)
    local item: object = null
    if target >= 0 && target < visibleSlots then
      if ResolveVisibleSlot(target) then
        local player: object = GetPlayerContainer()
        player->GetItem(item, resolvedIndex, resolvedCategory)
      end
    else
      if target >= c_iTargetContainerBase && target < c_iTargetContainerBase + c_iContainerSlots then
        if ResolveContainerVisualSlot(target - c_iTargetContainerBase) then
          local external: object = GetExternalContainer()
          external->GetItem(item, resolvedContainerIndex)
        end
      else
        if target >= c_iTargetOrganBase && target < c_iTargetOrganBase + c_iOrganSlots then
          if ResolveOrganVisualSlot(target - c_iTargetOrganBase) then
            local external: object = GetExternalContainer()
            external->GetItem(item, resolvedContainerIndex)
          end
        end
      end
    end

    if !item then
      ClearPanelTooltip()
      return
    end
    if panelTooltipTarget != target then
      panelTooltipTarget = target
      native.SendMessage(1, "panel_background", item)
    end
  end

  function StartPanelPointerDrag(x: int, y: int) -> void
    local source: int = FindTargetAt(x, y)
    if source < 0 then return end
    if HandleModifiedDrop(source) then return end
    StartDragAction(source, "panel_background")
  end

  function GetPanelPointerX(message: int, base: int) -> int
    local encoded: int = message - base
    return encoded / c_iPanelPointerStride
  end

  function GetPanelPointerY(message: int, base: int) -> int
    local encoded: int = message - base
    local x: int = encoded / c_iPanelPointerStride
    return encoded - x * c_iPanelPointerStride
  end

  function HandlePanelPointer(message: int) -> void
    local base: int = c_iPanelPointerMoveBase
    local action: int = 0
    if message >= c_iPanelPointerLeaveBase then
      ClearPanelTooltip()
      ClearPageControlHover()
      return
    end
    if message >= c_iPanelPointerDragEndBase then
      base = c_iPanelPointerDragEndBase
      action = 3
    else
      if message >= c_iPanelPointerDragBeginBase then
        base = c_iPanelPointerDragBeginBase
        action = 1
      else
        if message >= c_iPanelPointerRightBase then
          base = c_iPanelPointerRightBase
          action = 2
        else
          if message >= c_iPanelPointerUpBase then
            base = c_iPanelPointerUpBase
            action = 3
          else
            if message >= c_iPanelPointerDownBase then
              base = c_iPanelPointerDownBase
              action = 1
            end
          end
        end
      end
    end

    local x: int = GetPanelPointerX(message, base)
    local y: int = GetPanelPointerY(message, base)
    if action == 0 then
      UpdatePageControlHover(x, y)
      UpdatePanelTooltip(x, y)
    end
    if action == 1 then
      ClearPanelTooltip()
      if HandlePageControlAt(x, y) then return end
      StartPanelPointerDrag(x, y)
      return
    end
    if action == 2 then
      QuickTransfer(FindTargetAt(x, y))
      return
    end
    local target: int = FindTargetAt(x, y)
    if action == 3 then
      ApplyPointerTarget(target)
      FinishDrag(target)
      return
    end
    if dragSource >= 0 then ApplyPointerTarget(target) end
  end

  function HandlePageControlAt(x: int, y: int) -> bool
    local playerMaxPage: int = GetMaxPlayerPage()
    if playerMaxPage > 0 then
      local playerX: int = 467
      local playerY: int = 481
      if windowWidth >= 1900 then
        playerX = 1082
        playerY = 826
      else
      if windowWidth >= 1000 then
        playerX = 626
        playerY = 632
      end
      end
      if x >= playerX && x < playerX + 40 && y >= playerY && y < playerY + 36 then
        if playerPage > 0 then ChangePlayerPage(-1) end
        return true
      end
      if x >= playerX + 92 && x < playerX + 132 && y >= playerY && y < playerY + 36 then
        if playerPage < playerMaxPage then ChangePlayerPage(1) end
        return true
      end
    end

    local containerMaxPage: int = GetMaxContainerPage()
    if containerMaxPage > 0 then
      local containerX: int = GetContainerStartX() + 28
      if windowWidth >= 1900 then containerX = GetContainerStartX() + 73 end
      local containerY: int = GetContainerStartY() + c_iContainerSlots / 3 * GetGridStep() - 4
      if x >= containerX && x < containerX + 40 && y >= containerY && y < containerY + 36 then
        if containerPage > 0 then ChangeContainerPage(-1) end
        return true
      end
      if x >= containerX + 92 && x < containerX + 132 && y >= containerY && y < containerY + 36 then
        if containerPage < containerMaxPage then ChangeContainerPage(1) end
        return true
      end
    end
    return false
  end

  function SetPageButtonHover(wnd: string, highlighted: bool) -> void
    if highlighted then native.SendMessage(-94, wnd) else native.SendMessage(-95, wnd) end
  end

  function ClearPageControlHover() -> void
    SetPageButtonHover("player_page_prev", false)
    SetPageButtonHover("player_page_next", false)
    SetPageButtonHover("container_page_prev", false)
    SetPageButtonHover("container_page_next", false)
  end

  function UpdatePageControlHover(x: int, y: int) -> void
    local playerX: int = 467
    local playerY: int = 481
    if windowWidth >= 1900 then
      playerX = 1082
      playerY = 826
    else
    if windowWidth >= 1000 then
      playerX = 626
      playerY = 632
    end
    end
    local playerVisible: bool = GetMaxPlayerPage() > 0
    SetPageButtonHover("player_page_prev", playerVisible && playerPage > 0 && x >= playerX && x < playerX + 40 && y >= playerY && y < playerY + 36)
    SetPageButtonHover("player_page_next", playerVisible && playerPage < GetMaxPlayerPage() && x >= playerX + 92 && x < playerX + 132 && y >= playerY && y < playerY + 36)

    local containerX: int = GetContainerStartX() + 28
    if windowWidth >= 1900 then containerX = GetContainerStartX() + 73 end
    local containerY: int = GetContainerStartY() + c_iContainerSlots / 3 * GetGridStep() - 4
    local containerVisible: bool = GetMaxContainerPage() > 0
    SetPageButtonHover("container_page_prev", containerVisible && containerPage > 0 && x >= containerX && x < containerX + 40 && y >= containerY && y < containerY + 36)
    SetPageButtonHover("container_page_next", containerVisible && containerPage < GetMaxContainerPage() && x >= containerX + 92 && x < containerX + 132 && y >= containerY && y < containerY + 36)
  end

  function ChangePlayerPage(delta: int) -> void
    playerPage = playerPage + delta
    ClampPlayerPage()
    UpdatePlayerSlots()
  end

  function ChangeContainerPage(delta: int) -> void
    containerPage = containerPage + delta
    ClampContainerPage()
    UpdateContainerSlots()
  end

  function GetDragPageHoverAction(sender: string) -> int
    if sender == "player_page_prev" && playerPage > 0 then return -1 end
    if sender == "player_page_next" && playerPage < GetMaxPlayerPage() then return 1 end
    if sender == "container_page_prev" && containerPage > 0 then return -2 end
    if sender == "container_page_next" && containerPage < GetMaxContainerPage() then return 2 end
    return 0
  end

  function BeginDragPageHover(sender: string) -> void
    if dragSource < 0 then return end
    local action: int = GetDragPageHoverAction(sender)
    if action == 0 || action == dragPageHoverAction then return end
    dragPageHoverAction = action
    dragPageHoverElapsed = 0
    dragPageHoverConsumed = false
    native.Trace("inv_overhaul_container page-hover begin sender=" + sender + " action=" + action + " source=" + dragSource)
  end

  function CancelDragPageHover(action: int) -> void
    if action != 0 && dragPageHoverAction != action then return end
    if dragPageHoverAction != 0 then
      native.Trace("inv_overhaul_container page-hover cancel action=" + dragPageHoverAction + " elapsed=" + dragPageHoverElapsed)
    end
    dragPageHoverAction = 0
    dragPageHoverElapsed = 0
    dragPageHoverConsumed = false
  end

  function UpdateDragPageHover(delta: float) -> void
    if dragSource < 0 || dragPageHoverAction == 0 || dragPageHoverConsumed then return end
    if dragPageHoverAction == -1 && playerPage <= 0 then
      CancelDragPageHover(dragPageHoverAction)
      return
    end
    if dragPageHoverAction == 1 && playerPage >= GetMaxPlayerPage() then
      CancelDragPageHover(dragPageHoverAction)
      return
    end
    if dragPageHoverAction == -2 && containerPage <= 0 then
      CancelDragPageHover(dragPageHoverAction)
      return
    end
    if dragPageHoverAction == 2 && containerPage >= GetMaxContainerPage() then
      CancelDragPageHover(dragPageHoverAction)
      return
    end
    dragPageHoverElapsed = dragPageHoverElapsed + delta
    if dragPageHoverElapsed < c_fPageHoverDelay then return end
    dragPageHoverConsumed = true
    lastValidDropTarget = -1
    invalidDropTargetFrames = 0
    SetHighlightedTarget(-1)
    native.Trace("inv_overhaul_container page-hover switch action=" + dragPageHoverAction + " player_page=" + playerPage + " container_page=" + containerPage)
    if dragPageHoverAction == -1 then ChangePlayerPage(-1) end
    if dragPageHoverAction == 1 then ChangePlayerPage(1) end
    if dragPageHoverAction == -2 then ChangeContainerPage(-1) end
    if dragPageHoverAction == 2 then ChangeContainerPage(1) end
  end

  function SyncDragPageHoverFromCursor() -> void
    if dragSource < 0 then
      CancelDragPageHover(0)
      return
    end
    local hoverTarget: int = 0
    local action: int = 0
    native.GetVariable("inv_overhaul_inventory_page_hover", hoverTarget)
    if (hoverTarget == 1 || hoverTarget == 3) && playerPage > 0 then action = -1 end
    if (hoverTarget == 2 || hoverTarget == 4) && playerPage < GetMaxPlayerPage() then action = 1 end
    if hoverTarget == 5 && containerPage > 0 then action = -2 end
    if hoverTarget == 6 && containerPage < GetMaxContainerPage() then action = 2 end
    if action == 0 then
      CancelDragPageHover(0)
      return
    end
    if action == dragPageHoverAction then return end
    dragPageHoverAction = action
    dragPageHoverElapsed = 0
    dragPageHoverConsumed = false
    native.Trace("inv_overhaul_container page-hover cursor target=" + hoverTarget + " action=" + action + " player_page=" + playerPage + " container_page=" + containerPage)
  end

  function OnUIMessage(message: int, sender: string, data: object) -> void
    if message == c_iQuickslotHelpHover && sender == "panel_background" then
      ShowQuickslotHelpPanelTooltip()
      return
    end
    if message == c_iGridRendererReady then
      native.SendMessage(-201, "panel_background")
      return
    end
    if message == c_iPageHoverEnter then
      BeginDragPageHover(sender)
      return
    end
    if message == c_iPageHoverLeave then
      CancelDragPageHover(GetDragPageHoverAction(sender))
      return
    end
    if message == -100 && sender == "corpse_marker" then
      ActivateCorpseMode()
      native.SendMessage(-120, "corpse_marker")
      return
    end
    if sender == "panel_background" && message >= c_iPanelPointerMoveBase then
      HandlePanelPointer(message)
      return
    end

    if sender == "player_page_prev" && message == 0 then
      if playerPage > 0 then ChangePlayerPage(-1) end
      return
    end
    if sender == "player_page_next" && message == 0 then
      if playerPage < GetMaxPlayerPage() then ChangePlayerPage(1) end
      return
    end
    if sender == "container_page_prev" && message == 0 then
      if containerPage > 0 then ChangeContainerPage(-1) end
      return
    end
    if sender == "container_page_next" && message == 0 then
      if containerPage < GetMaxContainerPage() then ChangeContainerPage(1) end
      return
    end

    if message >= c_iDragEndMessageBase then
      local target: int = GetSlotTargetFromPointerMessage(message, c_iDragEndMessageBase, sender)
      ApplyPointerTarget(target)
      FinishDrag(target)
      return
    end
    if message >= c_iReleaseMessageBase then
      local target: int = GetSlotTargetFromPointerMessage(message, c_iReleaseMessageBase, sender)
      ApplyPointerTarget(target)
      FinishDrag(target)
      return
    end
    if message >= c_iHoverMessageBase then
      local target: int = GetSlotTargetFromPointerMessage(message, c_iHoverMessageBase, sender)
      if dragSource >= 0 then ApplyPointerTarget(target) else SetHighlightedTarget(target) end
      return
    end
    if message == 2 || message == 3 then
      local source: int = GetTargetBySender(sender)
      if HandleModifiedDrop(source) then return end
      StartDragAction(source, sender)
      return
    end
    if message == 7 then
      if dragSource >= 0 then ApplyPointerTarget(-1) else SetHighlightedTarget(-1) end
      return
    end
    if message == 8 then
      FinishDrag(highlightedTarget)
      return
    end
    if message == 1 && !data then
      QuickTransfer(GetTargetBySender(sender))
    end
  end

  function OnUpdate(delta: float) -> void
    if windowClosing then return end
    if rubbishKindRefreshRemaining > 0 then
      rubbishKindRefreshRemaining = rubbishKindRefreshRemaining - delta
      rubbishKindRefreshDelay = rubbishKindRefreshDelay - delta
      if rubbishKindRefreshDelay <= 0 then
        rubbishKindRefreshDelay = 0.05
        if RefreshDroppedRubbishKind(true) then return end
      end
    end
    if tooltipResumeDelay > 0 then
      ClearPanelTooltip()
      tooltipResumeDelay = tooltipResumeDelay - delta
      if tooltipResumeDelay <= 0 then
        tooltipResumeDelay = 0
      end
    end
    if inventoryFullMessageCooldown > 0 then
      inventoryFullMessageCooldown = inventoryFullMessageCooldown - delta
      if inventoryFullMessageCooldown < 0 then inventoryFullMessageCooldown = 0 end
    end
    UpdateLayout()
    if initialSlotLoadPending then
      initialSlotLoadDelay = initialSlotLoadDelay - delta
      if initialSlotLoadDelay <= 0 then
        if initialMetadataStage == 0 then
          if ContinueIncrementalLayoutLoad() then
            initialMetadataStage = 1
            initialSlotLoadDelay = 0.01
          else
            initialSlotLoadDelay = 0
          end
        else
          if initialMetadataStage == 1 then
            InitializePersistentPlayerSnapshot()
            initialMetadataStage = 2
            initialSlotLoadDelay = 0.01
          else
            OrderFreeCellsByDisplay()
            initialSlotLoadPending = false
            BeginInitialSlotLoad()
          end
        end
      end
    end
    ContinueInitialSlotLoad()
    ContinueLayoutSave()
    moneyPollCooldown = moneyPollCooldown - delta
    if moneyPollCooldown <= 0 then
      moneyPollCooldown = 0.25
      UpdateMoney()
    end
    if organVisibilityRefresh > 0 then
      organVisibilityRefresh = organVisibilityRefresh - delta
      if organVisibilityRefresh <= 0 then UpdateOrganSlots() end
    end
    if corpseVisualPending then
      native.SendMessage(-100, "loot_doll")
      corpseVisualPending = false
    end
    if deferredInventoryRefresh > 0 then
      deferredInventoryRefresh = deferredInventoryRefresh - delta
      if deferredInventoryRefresh <= 0 then
        UpdatePlayerSlots()
        native.Trace("inv_overhaul_container deferred inventory refresh")
      end
    end
    if deferredContainerRefresh > 0 then
      deferredContainerRefresh = deferredContainerRefresh - delta
      if deferredContainerRefresh <= 0 then UpdateContainerSlots() end
    end
    SyncDragPageHoverFromCursor()
    UpdateDragPageHover(delta)
  end

  function OnMouseMove(x: int, y: int) -> void
    if dragSource >= 0 then ApplyPointerTarget(FindTargetAt(x, y)) end
  end

  function OnMouseLeave() -> void
    if dragSource >= 0 then SetHighlightedTarget(-1) end
  end

  function OnLButtonUp(x: int, y: int) -> void
    if dragSource >= 0 then
      local target: int = FindTargetAt(x, y)
      ApplyPointerTarget(target)
      FinishDrag(target)
    end
  end

  function CloseContainerWindow() -> void
    native.SetCursor("default")
    native.DestroyWindow()
  end

  function OnChar(char: int) -> void
    if char >= 48 && char <= 57 then return end
    if layoutSavePending then SaveLayoutVariables() end
    PersistCurrentPlayerSnapshot()
    CloseContainerWindow()
  end

  function OnKeyDown(key: int) -> void
    if key == c_iVKShift then shiftHeld = true end
    if key == c_iVKControl then controlHeld = true end
    local quickslot: int = GetQuickslotByKey(key)
    if quickslot > 0 then
      AssignHoveredQuickslot(quickslot)
      return
    end
    if key == 27 || key == 73 || key == 105 then
      if layoutSavePending then SaveLayoutVariables() end
      PersistCurrentPlayerSnapshot()
      CloseContainerWindow()
    end
  end

  function OnKeyUp(key: int) -> void
    if key == c_iVKShift then shiftHeld = false end
    if key == c_iVKControl then controlHeld = false end
  end
end
