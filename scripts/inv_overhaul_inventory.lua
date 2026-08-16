maintask InventoryOverhaulUI do
  local const c_sScriptVersion: string = "2026.08.11-open-image-cadence-40ms-1"
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
  local const c_iWMHelpMessage: int = 200
  local const c_iInventoryFullTextID: int = 1400
  local const c_iSlotSelected: int = 16384
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
  local const c_iGridRendererMessageBase: int = 30000000
  local const c_iGridRendererSlotStride: int = 100000
  local const c_iGridRendererOperationStride: int = 20000
  local const c_iGridRendererItem: int = 1
  local const c_iGridRendererEmpty: int = 2
  local const c_iGridRendererHidden: int = 3
  local const c_iGridRendererHighlight: int = 4
  local const c_iGridRendererReady: int = 29900000
  local const c_iSlotHotZone: int = 52
  local const c_iSlotDropInset: int = 1
  local const c_iTargetWeapon: int = 100
  local const c_iTargetClothesBase: int = 100
  local const c_iTargetDrop: int = 200
  local const c_iTargetMoney: int = 300
  local const c_iTargetPaging: int = 400
  local const c_iTargetQuickslotHelp: int = 401
  local const c_iQuickslotHelpHover: int = 29800001
  local const c_iPageHoverEnter: int = -110
  local const c_iPageHoverLeave: int = -111
  local const c_fPageHoverDelay: float = 1.00
  local const c_fInitialItemLoadInterval: float = 0.04
  local const c_iInitialSlotLoadBatch: int = 1

  local windowWidth: int
  local windowHeight: int
  local visibleSlots: int
  local page: int
  local resolvedCategory: int
  local resolvedIndex: int
  local slotOrder: object
  local dragSourceSlot: int
  local dragSourceCell: int
  local hoverSlot: int
  local highlightedSlot: int
  local dragMoved: bool
  local dragDebugLastTargetSlot: int
  local lastPointerSlot: int
  local dragDebugLastPointerSlot: int
  local lastValidDropTarget: int
  local invalidDropTargetFrames: int
  local dragDebugLastAppliedTarget: int
  local dragItemID: int
  local dragItemCategory: int
  local dragItemIndex: int
  local dragItemGroup: int
  local dragItemIsWeapon: bool
  local lastLayoutWidth: int
  local lastLayoutHeight: int
  local lastLayoutSlots: int
  local panelTooltipTarget: int
  local moneyTooltipItem: object
  local backpackSnapshot: object
  local currentBackpackSnapshot: object
  local backpackCategoryCache: object
  local backpackIndexCache: object
  local oldToNewOrder: object
  local claimedNewOrder: object
  local usedLayoutCell: object
  local lastBackpackItemCount: int
  local deferredInventoryRefresh: float
  local inventoryFullMessageCooldown: float
  local shiftHeld: bool
  local controlHeld: bool
  local inventoryPollCooldown: float
  local dragPageHoverAction: int
  local dragPageHoverElapsed: float
  local dragPageHoverConsumed: bool
  local tooltipResumeDelay: float
  local initialSlotLoadActive: bool
  local initialSlotLoadNext: int
  local initialEquipmentLoadNext: int
  local initialSlotLoadPending: bool
  local initialSlotLoadDelay: float
  local initialSpriteLoadCooldown: float
  local initialMetadataStage: int
  local childWindowsReady: bool
  local equipmentCategoryCache: object
  local equipmentIndexCache: object
  local quickslotItemCache: object
  local quickslotCategoryCache: object
  local quickslotOccurrenceCache: object
  local layoutSavePending: bool
  local layoutSaveNextCell: int
  local perfDiagnostics: int
  local perfFirstItemReported: bool
  local perfCompleteReported: bool
  local perfStackCount: int
  local perfEquipmentCount: int
  local perfCacheHits: int
  local perfCacheMisses: int
  local perfCacheEpoch: int
  local gridRendererReady: bool
  local warmGridLoaded: bool
  local warmStartAttempted: bool
  local closingWindow: bool

  function init() -> void
    native.Trace("INV_OVERHAUL_PERF_STEP root_init_begin")
    native.Trace("INV_OVERHAUL_INVENTORY_VERSION " + c_sScriptVersion + " screen=inventory")
    page = 0
    resolvedCategory = -1
    resolvedIndex = -1
    dragSourceSlot = -1
    dragSourceCell = -1
    hoverSlot = -1
    highlightedSlot = -1
    dragMoved = false
    dragDebugLastTargetSlot = -999
    lastPointerSlot = -1
    dragDebugLastPointerSlot = -999
    lastValidDropTarget = -1
    invalidDropTargetFrames = 0
    dragDebugLastAppliedTarget = -999
    dragItemID = -1
    dragItemCategory = -1
    dragItemIndex = -1
    dragItemGroup = -1
    dragItemIsWeapon = false
    lastLayoutWidth = -1
    lastLayoutHeight = -1
    lastLayoutSlots = -1
    panelTooltipTarget = -999
    deferredInventoryRefresh = 0
    inventoryFullMessageCooldown = 0
    shiftHeld = false
    controlHeld = false
    inventoryPollCooldown = 0.25
    dragPageHoverAction = 0
    dragPageHoverElapsed = 0
    dragPageHoverConsumed = false
    tooltipResumeDelay = 0
    initialSlotLoadActive = false
    initialSlotLoadNext = 0
    initialEquipmentLoadNext = 0
    initialSlotLoadPending = true
    initialSlotLoadDelay = 0
    initialSpriteLoadCooldown = 0
    initialMetadataStage = 0
    childWindowsReady = false
    layoutSavePending = false
    layoutSaveNextCell = -1
    perfDiagnostics = 0
    perfFirstItemReported = false
    perfCompleteReported = false
    perfStackCount = 0
    perfEquipmentCount = 0
    perfCacheHits = 0
    perfCacheMisses = 0
    perfCacheEpoch = 0
    gridRendererReady = false
    warmGridLoaded = false
    warmStartAttempted = false
    closingWindow = false
    native.GetVariable("inv_overhaul_perf_diagnostics", perfDiagnostics)
    if perfDiagnostics == 1 then
      local warmed: int = 0
      native.GetVariable("inv_overhaul_ui_cache_loaded", warmed)
      native.Trace("INV_OVERHAUL_PERF_PHASE cache_snapshot warmed=" + warmed)
    end
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
    native.Trace("INV_OVERHAUL_PERF_STEP root_quickslots_ready")
    native.CreateInvItem(moneyTooltipItem)
    moneyTooltipItem->SetItemName("Money")
    native.CreateIntVector(backpackSnapshot)
    native.CreateIntVector(currentBackpackSnapshot)
    native.CreateIntVector(backpackCategoryCache)
    native.CreateIntVector(backpackIndexCache)
    native.CreateIntVector(oldToNewOrder)
    native.CreateIntVector(claimedNewOrder)
    native.CreateIntVector(usedLayoutCell)
    native.CreateIntVector(equipmentCategoryCache)
    native.CreateIntVector(equipmentIndexCache)
    for i = 0, c_iInventoryCapacity - 1 do
      backpackSnapshot->add(-1)
      currentBackpackSnapshot->add(-1)
      backpackCategoryCache->add(-1)
      backpackIndexCache->add(-1)
      oldToNewOrder->add(-1)
      claimedNewOrder->add(0)
      usedLayoutCell->add(0)
    end
    for i = 0, 4 do
      equipmentCategoryCache->add(-1)
      equipmentIndexCache->add(-1)
    end
    lastBackpackItemCount = 0
    InitSlotOrder()
    native.Trace("INV_OVERHAUL_PERF_STEP root_vectors_ready")
    UpdateLayout()
    native.SetVariable("inv_overhaul_inventory_drag_item", -1)
    native.SetVariable("inv_overhaul_inventory_page_hover", 0)
    native.SetCursor("inv_overhaul_inventory")
    native.ShowCursor()
    native.CaptureKeyboard()
    native.SetOwnerDraw(false)
    native.SetNeedUpdate(true)
    native.Trace("INV_OVERHAUL_PERF_STEP root_before_process_events")
    native.ProcessEvents()
    native.Trace("INV_OVERHAUL_PERF_STEP root_init_end")
  end

  function InitSlotOrder() -> void
    native.CreateIntVector(slotOrder)
    for i = 0, c_iInventoryCapacity - 1 do
      slotOrder->add(GetDefaultOrderForCell(i))
    end
  end

  function GetDefaultOrderForCell(cell: int) -> int
    if cell < 16 then return cell + 40 end
    return cell - 16
  end

  function GetBranch() -> int
    local branch: int = -1
    native.GetVariable("branch", branch)
    return branch
  end

  function GetOrderValue(slot: int) -> int
    local order: int = slot
    if slot >= 0 && slot < c_iInventoryCapacity then
      slotOrder->get(order, slot)
    end
    return order
  end

  function SetOrderValue(slot: int, value: int) -> void
    if slot >= 0 && slot < c_iInventoryCapacity then
      slotOrder->set(slot, value)
    end
  end

  function GetCellVariableName(slot: int) -> string
    return "inv_overhaul_inventory_cell_" + slot
  end

  function LoadLayoutVariables() -> void
    local initialized: int = 0
    local layoutVersion: int = 0
    native.GetVariable("inv_overhaul_inventory_layout_initialized", initialized)
    native.GetVariable("inv_overhaul_inventory_layout_version", layoutVersion)
    if initialized != 1 then
      SaveLayoutVariables()
      return
    end

    local storedSlots: int = c_iInventoryCapacity
    if layoutVersion == 3 then storedSlots = 40 end
    if layoutVersion != 3 && layoutVersion != c_iLayoutVersion then
      SaveLayoutVariables()
      return
    end

    if layoutVersion == 3 then
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
    if layoutVersion == 3 then SaveLayoutVariables() end
    native.Trace("inv_overhaul_inventory layout loaded from variables")
  end

  function ContinueIncrementalLayoutLoad() -> bool
    if layoutSaveNextCell < 0 then
      local initialized: int = 0
      local layoutVersion: int = 0
      native.GetVariable("inv_overhaul_inventory_layout_initialized", initialized)
      native.GetVariable("inv_overhaul_inventory_layout_version", layoutVersion)
      if initialized != 1 || layoutVersion != c_iLayoutVersion then
        LoadLayoutVariables()
        return true
      end
      layoutSaveNextCell = 0
    end
    for batch = 0, c_iInventoryCapacity - 1 do
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
    for i = 0, c_iInventoryCapacity - 1 do
      native.SetVariable(GetCellVariableName(i), GetOrderValue(i))
    end
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
      if GetOrderValue(i) == order then
        return true
      end
    end
    return false
  end

  function IsOrderUsedAtOrBefore(slot: int, order: int) -> bool
    for i = 0, slot do
      if GetOrderValue(i) == order then
        return true
      end
    end
    return false
  end

  function FindFirstUnusedOrder(slot: int) -> int
    for candidate = 0, c_iInventoryCapacity - 1 do
      if !IsOrderUsedAtOrBefore(slot, candidate) then
        return candidate
      end
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

  function OrderFreeCellsByDisplayForCount(itemCount: int) -> void
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

  function OrderFreeCellsByDisplay() -> void
    OrderFreeCellsByDisplayForCount(GetBackpackItemCount())
  end

  function GetPlayerContainer() -> object
    local container: object
    native.GetPlayerContainer(container)
    return container
  end

  function BeginDragCursor(slot: int) -> void
    native.SetVariable("inv_overhaul_inventory_drag_item", -1)
    dragItemID = -1
    dragItemCategory = -1
    dragItemIndex = -1
    dragItemGroup = -1
    dragItemIsWeapon = false
    if !ResolveDragSource(slot) then
      return
    end

    local container: object = GetPlayerContainer()
    local item: object
    container->GetItem(item, resolvedIndex, resolvedCategory)
    if !item then
      return
    end

    local itemID: int
    item->GetItemID(itemID)
    dragItemID = itemID
    dragItemCategory = resolvedCategory
    dragItemIndex = resolvedIndex
    if dragItemCategory == c_iCWeapon then
      native.HasInvItemProperty(dragItemIsWeapon, dragItemID, "Weapon")
    end
    if dragItemCategory == c_iCClothes then
      local hasGroup: bool
      native.HasInvItemProperty(hasGroup, dragItemID, "Group")
      if hasGroup then
        native.GetInvItemProperty(dragItemGroup, dragItemID, "Group")
      end
    end
    native.SetVariable("inv_overhaul_inventory_drag_item", itemID)
  end

  function EndDragCursor() -> void
    native.SetVariable("inv_overhaul_inventory_drag_item", -1)
    native.SetVariable("inv_overhaul_inventory_page_hover", 0)
    dragItemID = -1
    dragItemCategory = -1
    dragItemIndex = -1
    dragItemGroup = -1
    dragItemIsWeapon = false
  end

  function ConfigureSlotRenderSize() -> void
    local sizeMessage: int = -27
    local equipSizeMessage: int = -27
    if windowWidth >= 1900 then sizeMessage = -26 end
    if windowWidth >= 1900 then equipSizeMessage = -28 end
    native.SendMessage(equipSizeMessage, "equip_head")
    native.SendMessage(equipSizeMessage, "equip_body")
    native.SendMessage(equipSizeMessage, "equip_hands")
    native.SendMessage(equipSizeMessage, "equip_feet")
    native.SendMessage(equipSizeMessage, "equip_weapon")
    native.SendMessage(sizeMessage, "drop_slot")
    native.SendMessage(sizeMessage, "money")
  end

  function UpdateLayout() -> void
    native.GetWindowSize(windowWidth, windowHeight)
    if windowWidth <= 0 || windowHeight <= 0 then
      native.GetScreenSize(windowWidth, windowHeight)
    end
    if windowWidth >= 1900 then
      visibleSlots = 35
    else
    if windowWidth >= 1200 then
      visibleSlots = c_iInventoryCapacity
    else
      if windowWidth >= 1000 then
        visibleSlots = 35
      else
        visibleSlots = 24
      end
    end
    end
    if windowWidth != lastLayoutWidth || windowHeight != lastLayoutHeight || visibleSlots != lastLayoutSlots then
      native.Trace("inv_overhaul_inventory layout window=" + windowWidth + "x" + windowHeight + " slots=" + visibleSlots)
      if childWindowsReady then
        native.SendMessage(windowWidth, "character_doll")
        native.SendMessage(5000 + windowHeight, "character_doll")
        native.SendMessage(windowWidth, "panel_background")
        native.SendMessage(5000 + windowHeight, "panel_background")
        ConfigureSlotRenderSize()
      end
      lastLayoutWidth = windowWidth
      lastLayoutHeight = windowHeight
      lastLayoutSlots = visibleSlots
    end
  end

  function GetSlotWndName(slot: int) -> string
    local number: int = slot + 1
    if number < 10 then
      return "slot0" + number
    end
    return "slot" + number
  end

  function SendGridRendererState(slot: int, operation: int, value: int, data: object) -> void
    if slot < 0 || slot >= c_iInventoryCapacity then return end
    if value < 0 then value = 0 end
    if value > 19999 then value = 19999 end
    native.SendMessage(
      c_iGridRendererMessageBase + slot * c_iGridRendererSlotStride +
      operation * c_iGridRendererOperationStride + value,
      "panel_background",
      data)
  end

  function SetGridRendererHighlight(slot: int, enabled: bool) -> void
    local value: int = 0
    if enabled then value = 1 end
    SendGridRendererState(slot, c_iGridRendererHighlight, value, null)
  end

  function GetVisibleCell(slot: int) -> int
    local linear: int = page * visibleSlots + slot
    return GetCellForLinearSlot(linear)
  end

  function GetCellForLinearSlot(linear: int) -> int
    if linear < 0 || linear >= c_iInventoryCapacity then return -1 end
    if visibleSlots < c_iInventoryCapacity then return (linear + 16) - ((linear + 16) / c_iInventoryCapacity) * c_iInventoryCapacity end
    return linear
  end

  function GetGridStartX() -> int
    if windowWidth >= 1900 then
      return 825
    end
    if windowWidth >= 1200 then
      return 600
    end
    if windowWidth >= 1000 then
      return 468
    end
    return 359
  end

  function GetRootLeft() -> int
    return 0
  end

  function GetRootTop() -> int
    return 0
  end

  function GetGridStartY() -> int
    if windowWidth >= 1900 then
      return 245
    end
    if windowWidth >= 1200 then
      return 182
    end
    if windowWidth >= 1000 then
      return 266
    end
    return 225
  end

  function GetGridStep() -> int
    if windowWidth >= 1900 then
      return 96
    end
    if windowWidth >= 1200 then
      return 64
    end
    if windowWidth >= 1000 then
      return 61
    end
    return 58
  end

  function GetGridColumns() -> int
    if windowWidth >= 1900 then
      return 7
    end
    if windowWidth >= 1200 then
      return 8
    end
    if windowWidth >= 1000 then
      return 7
    end
    return 6
  end

  function GetSlotLeft(slot: int) -> int
    local columns: int = GetGridColumns()
    local column: int = slot - (slot / columns) * columns
    return GetGridStartX() + column * GetGridStep()
  end

  function GetSlotTop(slot: int) -> int
    local columns: int = GetGridColumns()
    return GetGridStartY() + (slot / columns) * GetGridStep()
  end

  function GetTargetWndName(target: int) -> string
    if target >= 0 && target < visibleSlots then
      return GetSlotWndName(target)
    end
    if target == c_iTargetWeapon then
      return "equip_weapon"
    end
    if target == c_iTargetClothesBase + 1 then
      return "equip_feet"
    end
    if target == c_iTargetClothesBase + 2 then
      return "equip_head"
    end
    if target == c_iTargetClothesBase + 3 then
      return "equip_body"
    end
    if target == c_iTargetClothesBase + 4 then
      return "equip_hands"
    end
    if target == c_iTargetDrop then
      return "drop_slot"
    end
    return ""
  end

  function GetTargetDebugName(target: int) -> string
    if target >= 0 && target < visibleSlots then
      return "BACKPACK_" + target
    end
    if target == c_iTargetWeapon then return "WEAPON" end
    if target == c_iTargetClothesBase + 1 then return "FEET" end
    if target == c_iTargetClothesBase + 2 then return "HEAD" end
    if target == c_iTargetClothesBase + 3 then return "BODY" end
    if target == c_iTargetClothesBase + 4 then return "HANDS" end
    if target == c_iTargetDrop then return "DROP" end
    return "OUTSIDE"
  end

  function TraceDragTarget(target: int) -> void
    if target == dragDebugLastAppliedTarget then
      return
    end
    dragDebugLastAppliedTarget = target

  end

  function GetSpecialTargetLeft(target: int) -> int
    local clara: bool = GetBranch() == 2
    if windowWidth >= 1900 then
      if target == c_iTargetWeapon then return 660 end
      if target == c_iTargetClothesBase + 1 then return 590 end
      if target == c_iTargetClothesBase + 2 then return 590 end
      if target == c_iTargetClothesBase + 3 then
        if clara then return 560 end
        return 590
      end
      if target == c_iTargetClothesBase + 4 then return 445 end
      if target == c_iTargetDrop then return 825 end
    else
    if windowWidth >= 1200 then
      if target == c_iTargetWeapon then return 375 end
      if target == c_iTargetClothesBase + 1 then return 270 end
      if target == c_iTargetClothesBase + 2 then return 270 end
      if target == c_iTargetClothesBase + 3 then
        if clara then return 250 end
        return 270
      end
      if target == c_iTargetClothesBase + 4 then return 125 end
      if target == c_iTargetDrop then return 600 end
    else
      if windowWidth >= 1000 then
        if target == c_iTargetWeapon then return 299 end
        if target == c_iTargetClothesBase + 1 then return 207 end
        if target == c_iTargetClothesBase + 2 then return 207 end
        if target == c_iTargetClothesBase + 3 then
          if clara then return 191 end
          return 207
        end
        if target == c_iTargetClothesBase + 4 then return 86 end
        if target == c_iTargetDrop then return 468 end
      else
        if target == c_iTargetWeapon then return 222 end
        if target == c_iTargetClothesBase + 1 then return 156 end
        if target == c_iTargetClothesBase + 2 then return 156 end
        if target == c_iTargetClothesBase + 3 then
          if clara then return 144 end
          return 156
        end
        if target == c_iTargetClothesBase + 4 then return 68 end
        if target == c_iTargetDrop then return 359 end
      end
    end
    end
    return -1000
  end

  function GetSpecialTargetTop(target: int) -> int
    local clara: bool = GetBranch() == 2
    local headOffset: int = 8
    if windowWidth >= 1900 then
      headOffset = 15
      if clara then headOffset = 100 end
    else
      if windowWidth >= 1200 then
        headOffset = 12
        if clara then headOffset = 94 end
      else
        if windowWidth >= 1000 then
          headOffset = 9
          if clara then headOffset = 84 end
        else
          if clara then headOffset = 78 end
        end
      end
    end
    if windowWidth >= 1900 then
      if target == c_iTargetWeapon then
        if clara then return 512 end
        return 580
      end
      if target == c_iTargetClothesBase + 1 then return 800 end
      if target == c_iTargetClothesBase + 2 then return 300 + headOffset end
      if target == c_iTargetClothesBase + 3 then return 488 end
      if target == c_iTargetClothesBase + 4 then return 560 end
      if target == c_iTargetDrop then return 780 end
    else
    if windowWidth >= 1200 then
      if target == c_iTargetWeapon then
        if clara then return 458 end
        return 528
      end
      if target == c_iTargetClothesBase + 1 then return 740 end
      if target == c_iTargetClothesBase + 2 then return 240 + headOffset end
      if target == c_iTargetClothesBase + 3 then return 428 end
      if target == c_iTargetClothesBase + 4 then return 500 end
      if target == c_iTargetDrop then return 770 end
    else
      if windowWidth >= 1000 then
        if target == c_iTargetWeapon then
          if clara then return 351 end
          return 418
        end
        if target == c_iTargetClothesBase + 1 then return 569 end
        if target == c_iTargetClothesBase + 2 then return 188 + headOffset end
        if target == c_iTargetClothesBase + 3 then return 346 end
        if target == c_iTargetClothesBase + 4 then return 399 end
        if target == c_iTargetDrop then return 616 end
      else
        if target == c_iTargetWeapon then
          if clara then return 255 end
          return 323
        end
        if target == c_iTargetClothesBase + 1 then return 429 end
        if target == c_iTargetClothesBase + 2 then return 159 + headOffset end
        if target == c_iTargetClothesBase + 3 then return 271 end
        if target == c_iTargetClothesBase + 4 then return 311 end
        if target == c_iTargetDrop then return 465 end
      end
    end
    end
    return -1000
  end

  function IsInsideSpecialTarget(target: int, x: int, y: int) -> bool
    local left: int = GetSpecialTargetLeft(target)
    local top: int = GetSpecialTargetTop(target)
    local hotZone: int = GetEquipSlotHotZone()
    if target == c_iTargetDrop then hotZone = GetSlotHotZone() end
    return x >= left && y >= top && x < left + hotZone && y < top + hotZone
  end

  function GetSlotHotZone() -> int
    if windowWidth >= 1900 then return 82 end
    return c_iSlotHotZone
  end

  function GetEquipSlotHotZone() -> int
    if windowWidth >= 1900 then return 48 end
    return c_iSlotHotZone
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

  function IsInsideMoney(x: int, y: int) -> bool
    local left: int = GetMoneyLeft()
    local top: int = GetMoneyTop()
    local hotZone: int = GetSlotHotZone()
    return x >= left && y >= top && x < left + hotZone && y < top + hotZone
  end

  function FindSpecialTargetAt(x: int, y: int) -> int
    if dragItemCategory == c_iCWeapon && dragItemIsWeapon then
      if IsInsideSpecialTarget(c_iTargetWeapon, x, y) then
        return c_iTargetWeapon
      end
    end

    if dragItemCategory == c_iCClothes && dragItemGroup >= 1 && dragItemGroup <= 4 then
      local clothesTarget: int = c_iTargetClothesBase + dragItemGroup
      if IsInsideSpecialTarget(clothesTarget, x, y) then
        return clothesTarget
      end
    end

    if IsInsideSpecialTarget(c_iTargetDrop, x, y) then
      return c_iTargetDrop
    end
    return -1
  end

  function FindEquipmentTargetAt(x: int, y: int) -> int
    if IsInsideSpecialTarget(c_iTargetWeapon, x, y) then return c_iTargetWeapon end
    for group = 1, 4 do
      local target: int = c_iTargetClothesBase + group
      if IsInsideSpecialTarget(target, x, y) then return target end
    end
    return -1
  end

  function IsEquippedItem(category: int, index: int) -> bool
    if category != c_iCWeapon && category != c_iCClothes then
      return false
    end

    local container: object = GetPlayerContainer()
    local selected: bool
    container->IsItemSelected(selected, index, category)
    if !selected then
      return false
    end

    local item: object
    container->GetItem(item, index, category)
    local itemID: int
    item->GetItemID(itemID)

    if category == c_iCWeapon then
      local hasWeapon: bool
      native.HasInvItemProperty(hasWeapon, itemID, "Weapon")
      return hasWeapon
    end

    local hasGroup: bool
    native.HasInvItemProperty(hasGroup, itemID, "Group")
    return hasGroup
  end

  function GetBackpackItemCount() -> int
    local container: object = GetPlayerContainer()
    local total: int = 0

    for category = 0, c_iCategoryCount - 1 do
      local count: int
      container->GetItemCount(count, category)
      for index = 0, count - 1 do
        if !IsEquippedItem(category, index) then
          total = total + 1
        end
      end
    end

    return total
  end

  function CaptureBackpackItems(snapshot: object) -> int
    local container: object = GetPlayerContainer()
    local ordinal: int = 0
    for i = 0, c_iInventoryCapacity - 1 do snapshot->set(i, -1) end
    for category = 0, c_iCategoryCount - 1 do
      local count: int
      container->GetItemCount(count, category)
      for index = 0, count - 1 do
        if !IsEquippedItem(category, index) then
          if ordinal < c_iInventoryCapacity then
            local item: object
            local itemID: int
            container->GetItem(item, index, category)
            if item then
              item->GetItemID(itemID)
              snapshot->set(ordinal, itemID)
            end
          end
          ordinal = ordinal + 1
        end
      end
    end
    return ordinal
  end

  function SnapshotBackpackItems() -> void
    lastBackpackItemCount = CaptureBackpackItems(backpackSnapshot)
  end

  function GetSnapshotVariableName(ordinal: int) -> string
    return "inv_overhaul_inventory_snapshot_" + ordinal
  end

  function LoadPersistentBackpackSnapshot() -> bool
    local valid: int = 0
    local version: int = 0
    local count: int = 0
    native.GetVariable("inv_overhaul_inventory_snapshot_valid", valid)
    native.GetVariable("inv_overhaul_inventory_snapshot_version", version)
    native.GetVariable("inv_overhaul_inventory_snapshot_count", count)
    if valid != 1 || version != c_iSnapshotVersion || count < 0 || count > c_iInventoryCapacity then
      return false
    end
    for ordinal = 0, c_iInventoryCapacity - 1 do
      local itemID: int = -1
      if ordinal < count then native.GetVariable(GetSnapshotVariableName(ordinal), itemID) end
      backpackSnapshot->set(ordinal, itemID)
    end
    lastBackpackItemCount = count
    return true
  end

  function CanReusePersistentBackpackSnapshot() -> bool
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

  function SavePersistentBackpackSnapshot() -> void
    local count: int = lastBackpackItemCount
    if count < 0 then count = 0 end
    if count > c_iInventoryCapacity then count = c_iInventoryCapacity end
    for ordinal = 0, c_iInventoryCapacity - 1 do
      local itemID: int = -1
      backpackSnapshot->get(itemID, ordinal)
      native.SetVariable(GetSnapshotVariableName(ordinal), itemID)
    end
    native.SetVariable("inv_overhaul_inventory_snapshot_count", count)
    native.SetVariable("inv_overhaul_inventory_snapshot_version", c_iSnapshotVersion)
    native.SetVariable("inv_overhaul_inventory_snapshot_valid", 1)
    local generation: int = 0
    native.GetVariable("inv_overhaul_inventory_reorder_generation", generation)
    native.SetVariable("inv_overhaul_inventory_snapshot_generation", generation)
  end

  function CopyCurrentBackpackSnapshot(newCount: int) -> void
    for ordinal = 0, c_iInventoryCapacity - 1 do
      local itemID: int = -1
      currentBackpackSnapshot->get(itemID, ordinal)
      backpackSnapshot->set(ordinal, itemID)
    end
    lastBackpackItemCount = newCount
    if lastBackpackItemCount > c_iInventoryCapacity then lastBackpackItemCount = c_iInventoryCapacity end
  end

  function BackpackSnapshotDiffers(newCount: int) -> bool
    local comparableCount: int = newCount
    if comparableCount > c_iInventoryCapacity then comparableCount = c_iInventoryCapacity end
    if comparableCount != lastBackpackItemCount then return true end
    for ordinal = 0, comparableCount - 1 do
      local previousID: int
      local currentID: int
      backpackSnapshot->get(previousID, ordinal)
      currentBackpackSnapshot->get(currentID, ordinal)
      if previousID != currentID then return true end
    end
    return false
  end

  function PersistCurrentBackpackSnapshot() -> void
    lastBackpackItemCount = CaptureBackpackItems(backpackSnapshot)
    if lastBackpackItemCount > c_iInventoryCapacity then lastBackpackItemCount = c_iInventoryCapacity end
    SavePersistentBackpackSnapshot()
  end

  function InitializePersistentBackpackSnapshot() -> void
    if CanReusePersistentBackpackSnapshot() then
      lastBackpackItemCount = BuildBackpackIndexCacheAndSnapshot()
      if lastBackpackItemCount > c_iInventoryCapacity then lastBackpackItemCount = c_iInventoryCapacity end
      return
    end
    local currentCount: int = CaptureBackpackItems(currentBackpackSnapshot)
    if currentCount > c_iInventoryCapacity then currentCount = c_iInventoryCapacity end
    local loaded: bool = LoadPersistentBackpackSnapshot()
    local changed: bool = loaded && BackpackSnapshotDiffers(currentCount)
    if changed then
      ReconcileBackpackSnapshot(currentCount)
      native.Trace("inv_overhaul_inventory persistent snapshot reconciled old=" + lastBackpackItemCount +
        " current=" + currentCount)
    end
    CopyCurrentBackpackSnapshot(currentCount)
    if !loaded || changed then SavePersistentBackpackSnapshot() end
    if !loaded then native.Trace("inv_overhaul_inventory persistent snapshot initialized count=" + currentCount) end
    BuildBackpackIndexCache()
  end

  function FindFirstUnusedDisplayCell() -> int
    for linear = 0, c_iInventoryCapacity - 1 do
      local cell: int = GetCellForLinearSlot(linear)
      local used: int = 0
      usedLayoutCell->get(used, cell)
      if used == 0 then return cell end
    end
    return -1
  end

  function ReconcileBackpackSnapshot(newCount: int) -> void
    local oldCount: int = lastBackpackItemCount
    if oldCount > c_iInventoryCapacity then oldCount = c_iInventoryCapacity end
    if newCount > c_iInventoryCapacity then newCount = c_iInventoryCapacity end
    if oldCount < 0 then oldCount = 0 end
    if newCount < 0 then newCount = 0 end

    for i = 0, c_iInventoryCapacity - 1 do
      oldToNewOrder->set(i, -1)
      claimedNewOrder->set(i, 0)
      usedLayoutCell->set(i, 0)
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
      newCount == oldCount - 1 &&
      removalHintOrdinal >= 0 &&
      removalHintOrdinal < oldCount

    if removalHintApplies then
      for oldOrdinal = 0, oldCount - 1 do
        if oldOrdinal < removalHintOrdinal then
          oldToNewOrder->set(oldOrdinal, oldOrdinal)
          claimedNewOrder->set(oldOrdinal, 1)
        end
        if oldOrdinal > removalHintOrdinal then
          oldToNewOrder->set(oldOrdinal, oldOrdinal - 1)
          claimedNewOrder->set(oldOrdinal - 1, 1)
        end
      end
      native.Trace("inv_overhaul_inventory applied removal hint ordinal=" + removalHintOrdinal +
        " old=" + oldCount + " new=" + newCount)
    else
      for oldOrdinal = 0, oldCount - 1 do
        if oldOrdinal < newCount then
          local previousID: int
          local currentID: int
          backpackSnapshot->get(previousID, oldOrdinal)
          currentBackpackSnapshot->get(currentID, oldOrdinal)
          if previousID == currentID then
            oldToNewOrder->set(oldOrdinal, oldOrdinal)
            claimedNewOrder->set(oldOrdinal, 1)
          end
        end
      end

      for oldOrdinal = 0, oldCount - 1 do
        local mapped: int = -1
        oldToNewOrder->get(mapped, oldOrdinal)
        if mapped < 0 then
          local wantedID: int
          backpackSnapshot->get(wantedID, oldOrdinal)
          for newOrdinal = 0, newCount - 1 do
            local claimed: int
            claimedNewOrder->get(claimed, newOrdinal)
            local currentID: int
            currentBackpackSnapshot->get(currentID, newOrdinal)
            if claimed == 0 && currentID == wantedID then
              oldToNewOrder->set(oldOrdinal, newOrdinal)
              claimedNewOrder->set(newOrdinal, 1)
              newOrdinal = newCount
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
        oldToNewOrder->get(mappedOrder, oldOrder)
        if mappedOrder >= 0 then
          SetOrderValue(cell, mappedOrder)
          usedLayoutCell->set(cell, 1)
        end
      end
    end

    for insertedOrder = 0, newCount - 1 do
      local claimed: int
      claimedNewOrder->get(claimed, insertedOrder)
      if claimed == 0 then
        local freeCell: int = FindFirstUnusedDisplayCell()
        if freeCell >= 0 then
          SetOrderValue(freeCell, insertedOrder)
          usedLayoutCell->set(freeCell, 1)
        end
      end
    end

    local freeOrder: int = newCount
    for linear = 0, c_iInventoryCapacity - 1 do
      local freeCell: int = GetCellForLinearSlot(linear)
      local used: int
      usedLayoutCell->get(used, freeCell)
      if used == 0 then
        SetOrderValue(freeCell, freeOrder)
        freeOrder = freeOrder + 1
      end
    end
    NormalizeSlotOrder()
    QueueLayoutSave()
    native.Trace("inv_overhaul_inventory reconciled generic snapshot old=" + oldCount + " new=" + newCount)
  end

  function ReconcileExternalAdditions(newCount: int) -> void
    ReconcileBackpackSnapshot(newCount)
  end

  function RestoreOrderAfterEquipmentReplacement(replacedOrder: int, itemCount: int) -> bool
    if replacedOrder < 0 || replacedOrder >= itemCount then return false end
    local currentCount: int = CaptureBackpackItems(currentBackpackSnapshot)
    if currentCount != itemCount then return false end

    for i = 0, c_iInventoryCapacity - 1 do
      oldToNewOrder->set(i, -1)
      claimedNewOrder->set(i, 0)
      usedLayoutCell->set(i, 0)
    end

    for oldOrder = 0, itemCount - 1 do
      if oldOrder != replacedOrder then
        local wantedID: int
        backpackSnapshot->get(wantedID, oldOrder)
        for currentOrder = 0, itemCount - 1 do
          local claimed: int
          local currentID: int
          claimedNewOrder->get(claimed, currentOrder)
          currentBackpackSnapshot->get(currentID, currentOrder)
          if claimed == 0 && currentID == wantedID then
            oldToNewOrder->set(oldOrder, currentOrder)
            claimedNewOrder->set(currentOrder, 1)
            currentOrder = itemCount
          end
        end
      end
    end

    local replacementOrder: int = -1
    for currentOrder = 0, itemCount - 1 do
      local claimed: int
      claimedNewOrder->get(claimed, currentOrder)
      if claimed == 0 then
        replacementOrder = currentOrder
        currentOrder = itemCount
      end
    end
    if replacementOrder < 0 then return false end

    for cell = 0, c_iInventoryCapacity - 1 do
      local oldOrder: int = GetOrderValue(cell)
      if oldOrder >= 0 && oldOrder < itemCount then
        local mappedOrder: int = replacementOrder
        if oldOrder != replacedOrder then oldToNewOrder->get(mappedOrder, oldOrder) end
        if mappedOrder < 0 then return false end
        SetOrderValue(cell, mappedOrder)
        usedLayoutCell->set(cell, 1)
      end
    end

    local freeOrder: int = itemCount
    for linear = 0, c_iInventoryCapacity - 1 do
      local freeCell: int = GetCellForLinearSlot(linear)
      local used: int
      usedLayoutCell->get(used, freeCell)
      if used == 0 then
        SetOrderValue(freeCell, freeOrder)
        freeOrder = freeOrder + 1
      end
    end
    NormalizeSlotOrder()
    OrderFreeCellsByDisplay()
    QueueLayoutSave()
    native.Trace("inv_overhaul_inventory equipment replacement restored sourceOrder=" + replacedOrder +
      " replacementOrder=" + replacementOrder)
    return true
  end

  function RestoreOrderAfterEquipmentSelection(removedOrder: int, beforeCount: int) -> bool
    if removedOrder < 0 || removedOrder >= beforeCount then return false end
    local afterCount: int = CaptureBackpackItems(currentBackpackSnapshot)
    if afterCount != beforeCount - 1 then return false end

    for i = 0, c_iInventoryCapacity - 1 do
      oldToNewOrder->set(i, -1)
      claimedNewOrder->set(i, 0)
      usedLayoutCell->set(i, 0)
    end

    for oldOrder = 0, beforeCount - 1 do
      if oldOrder != removedOrder then
        local wantedID: int
        backpackSnapshot->get(wantedID, oldOrder)
        for currentOrder = 0, afterCount - 1 do
          local claimed: int
          local currentID: int
          claimedNewOrder->get(claimed, currentOrder)
          currentBackpackSnapshot->get(currentID, currentOrder)
          if claimed == 0 && currentID == wantedID then
            oldToNewOrder->set(oldOrder, currentOrder)
            claimedNewOrder->set(currentOrder, 1)
            currentOrder = afterCount
          end
        end
      end
    end

    for cell = 0, c_iInventoryCapacity - 1 do
      local oldOrder: int = GetOrderValue(cell)
      if oldOrder >= 0 && oldOrder < beforeCount then
        if oldOrder == removedOrder then
          SetOrderValue(cell, afterCount)
        else
          local mappedOrder: int
          oldToNewOrder->get(mappedOrder, oldOrder)
          if mappedOrder < 0 then return false end
          SetOrderValue(cell, mappedOrder)
          usedLayoutCell->set(cell, 1)
        end
      end
    end

    local freeOrder: int = afterCount
    for linear = 0, c_iInventoryCapacity - 1 do
      local freeCell: int = GetCellForLinearSlot(linear)
      local used: int
      usedLayoutCell->get(used, freeCell)
      if used == 0 then
        SetOrderValue(freeCell, freeOrder)
        freeOrder = freeOrder + 1
      end
    end
    NormalizeSlotOrder()
    OrderFreeCellsByDisplay()
    QueueLayoutSave()
    native.Trace("inv_overhaul_inventory equipment selection restored removedOrder=" + removedOrder +
      " before=" + beforeCount + " after=" + afterCount)
    return true
  end

  function ShowInventoryFull() -> void
    if inventoryFullMessageCooldown > 0 then return end
    local text: object
    native.CreateIntVector(text)
    text->add(c_iInventoryFullTextID)
    native.SendWorldWndMessage(c_iWMHelpMessage, text)
    inventoryFullMessageCooldown = 1.0
  end

  function GetMaxPage() -> int
    if visibleSlots <= 0 then return 0 end
    return (c_iInventoryCapacity - 1) / visibleSlots
  end

  function ClampPage() -> void
    local maxPage: int = GetMaxPage()

    if page < 0 then
      page = 0
    end
    if page > maxPage then
      page = maxPage
    end
  end

  function UpdatePageControls() -> void
    if visibleSlots >= c_iInventoryCapacity then return end
    local maxPage: int = GetMaxPage()
    local visibilityMessage: int = -93
    native.SendMessage(-112, "page_prev")
    native.SendMessage(-113, "page_next")
    if maxPage > 0 then visibilityMessage = -92 end
    native.SendMessage(visibilityMessage, "page_prev")
    native.SendMessage(visibilityMessage, "page_counter")
    native.SendMessage(visibilityMessage, "page_next")
    if maxPage <= 0 then return end
    native.SendMessage(-90, "page_prev")
    native.SendMessage(-91, "page_next")
    if page > 0 then native.SendMessage(-97, "page_prev") else native.SendMessage(-96, "page_prev") end
    if page < maxPage then native.SendMessage(-97, "page_next") else native.SendMessage(-96, "page_next") end
    native.SendMessage((page + 1) * 100 + maxPage + 1, "page_counter")
  end

  function ResolveVisibleSlot(slot: int) -> bool
    resolvedCategory = -1
    resolvedIndex = -1

    local target: int = GetOrderValue(GetVisibleCell(slot))
    if target < 0 || target >= c_iInventoryCapacity then return false end
    backpackCategoryCache->get(resolvedCategory, target)
    backpackIndexCache->get(resolvedIndex, target)
    return resolvedCategory >= 0 && resolvedIndex >= 0
  end

  function BuildBackpackIndexCache() -> void
    for ordinal = 0, c_iInventoryCapacity - 1 do
      backpackCategoryCache->set(ordinal, -1)
      backpackIndexCache->set(ordinal, -1)
    end
    local container: object = GetPlayerContainer()
    local ordinal: int = 0
    for category = 0, c_iCategoryCount - 1 do
      local count: int
      container->GetItemCount(count, category)
      for index = 0, count - 1 do
        if !IsEquippedItem(category, index) then
          if ordinal < c_iInventoryCapacity then
            backpackCategoryCache->set(ordinal, category)
            backpackIndexCache->set(ordinal, index)
          end
          ordinal = ordinal + 1
        end
      end
    end
  end

  function BuildBackpackIndexCacheAndSnapshot() -> int
    for ordinal = 0, c_iInventoryCapacity - 1 do
      backpackCategoryCache->set(ordinal, -1)
      backpackIndexCache->set(ordinal, -1)
      backpackSnapshot->set(ordinal, -1)
    end
    local container: object = GetPlayerContainer()
    local ordinal: int = 0
    for category = 0, c_iCategoryCount - 1 do
      local count: int
      container->GetItemCount(count, category)
      for index = 0, count - 1 do
        if !IsEquippedItem(category, index) then
          if ordinal < c_iInventoryCapacity then
            local item: object
            local itemID: int = -1
            backpackCategoryCache->set(ordinal, category)
            backpackIndexCache->set(ordinal, index)
            container->GetItem(item, index, category)
            if item then item->GetItemID(itemID) end
            backpackSnapshot->set(ordinal, itemID)
          end
          ordinal = ordinal + 1
        end
      end
    end
    return ordinal
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
      native.Trace("inv_overhaul_quickslot cleared slot=" + slot + " item=" + itemID)
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
      native.Trace("inv_overhaul_quickslot assigned slot=" + slot + " category=" + category +
        " item=" + itemID + " occurrence=" + occurrence)
    end
    UpdateSlots()
  end

  function GetQuickslotByKey(key: int) -> int
    if key >= 49 && key <= 57 then return key - 48 end
    if key == 48 then return 10 end
    if key >= 97 && key <= 105 then return key - 96 end
    if key == 96 then return 10 end
    return 0
  end

  function AssignHoveredQuickslot(slot: int) -> void
    if dragSourceSlot >= 0 then return end
    local target: int = highlightedSlot
    if target < 0 then target = panelTooltipTarget end
    if ResolveDragSource(target) then
      AssignQuickslot(slot, resolvedCategory, resolvedIndex)
    end
  end

  function UpdateSlot(slot: int) -> void
    local container: object = GetPlayerContainer()
    if GetVisibleCell(slot) < 0 then
      SendGridRendererState(slot, c_iGridRendererHidden, 0, null)
    else
      if ResolveVisibleSlot(slot) then
        local item: object
        local amount: int
        container->GetItem(item, resolvedIndex, resolvedCategory)
        container->GetItemAmount(amount, resolvedIndex, resolvedCategory)
        local itemID: int
        item->GetItemID(itemID)
        local quickslot: int = GetDisplayedQuickslot(resolvedCategory, resolvedIndex, itemID)
        if amount > 1800 then amount = 1800 end
        SendGridRendererState(slot, c_iGridRendererItem, amount * 11 + quickslot, item)
      else
        SendGridRendererState(slot, c_iGridRendererEmpty, 0, null)
      end
    end
  end

  function IsItemTexturePreloaded(itemID: int, cacheEpoch: int) -> bool
    if itemID < 0 then return false end
    if cacheEpoch > 0 then
      local itemEpoch: int = 0
      native.GetVariable("inv_overhaul_ui_cache_item_" + itemID, itemEpoch)
      if itemEpoch == cacheEpoch then return true end
    end
    local runtimeEpoch: int = 0
    local loadedEpoch: int = -1
    native.GetVariable("inv_overhaul_runtime_texture_epoch", runtimeEpoch)
    if runtimeEpoch <= 0 then return false end
    native.GetVariable("inv_overhaul_runtime_texture_item_" + itemID, loadedEpoch)
    return loadedEpoch == runtimeEpoch
  end

  function MarkItemTextureLoaded(category: int, index: int) -> void
    if category < 0 || index < 0 then return end
    local runtimeEpoch: int = 0
    native.GetVariable("inv_overhaul_runtime_texture_epoch", runtimeEpoch)
    if runtimeEpoch <= 0 then return end
    local container: object = GetPlayerContainer()
    local item: object
    local itemID: int = -1
    container->GetItem(item, index, category)
    if item then item->GetItemID(itemID) end
    if itemID >= 0 then
      native.SetVariable("inv_overhaul_runtime_texture_item_" + itemID, runtimeEpoch)
    end
  end

  function MeasureInitialTextureCacheCoverage() -> void
    perfStackCount = 0
    perfEquipmentCount = 0
    perfCacheHits = 0
    perfCacheMisses = 0
    perfCacheEpoch = 0
    native.GetVariable("inv_overhaul_ui_cache_epoch", perfCacheEpoch)
    local container: object = GetPlayerContainer()

    for ordinal = 0, c_iInventoryCapacity - 1 do
      local category: int
      local index: int
      backpackCategoryCache->get(category, ordinal)
      backpackIndexCache->get(index, ordinal)
      if category >= 0 && index >= 0 then
        local item: object
        local itemID: int = -1
        container->GetItem(item, index, category)
        if item then item->GetItemID(itemID) end
        perfStackCount = perfStackCount + 1
        if IsItemTexturePreloaded(itemID, perfCacheEpoch) then
          perfCacheHits = perfCacheHits + 1
        else
          perfCacheMisses = perfCacheMisses + 1
        end
      end
    end

    for equipment = 0, 4 do
      local category: int
      local index: int
      equipmentCategoryCache->get(category, equipment)
      equipmentIndexCache->get(index, equipment)
      if category >= 0 && index >= 0 then
        local item: object
        local itemID: int = -1
        container->GetItem(item, index, category)
        if item then item->GetItemID(itemID) end
        perfEquipmentCount = perfEquipmentCount + 1
        if IsItemTexturePreloaded(itemID, perfCacheEpoch) then
          perfCacheHits = perfCacheHits + 1
        else
          perfCacheMisses = perfCacheMisses + 1
        end
      end
    end
  end

  function IsContainerItemTexturePreloaded(category: int, index: int) -> bool
    if category < 0 || index < 0 then return true end
    local container: object = GetPlayerContainer()
    local item: object
    local itemID: int = -1
    container->GetItem(item, index, category)
    if item then item->GetItemID(itemID) end
    return IsItemTexturePreloaded(itemID, perfCacheEpoch)
  end

  function ReportFirstInitialItem() -> void
    if perfDiagnostics != 1 || perfFirstItemReported then return end
    perfFirstItemReported = true
    native.Trace("INV_OVERHAUL_PERF_PHASE first_item")
  end

  function ReportInitialItemIcon(category: int, index: int, source: string, slot: int) -> void
    if perfDiagnostics != 1 || category < 0 || index < 0 then return end
    local container: object = GetPlayerContainer()
    local item: object
    local itemID: int = -1
    local sprite: string = ""
    container->GetItem(item, index, category)
    if item then
      item->GetItemID(itemID)
      if windowWidth >= 1900 then
        native.GetInvItemSprite2(sprite, itemID)
      else
        native.GetInvItemSprite(sprite, itemID)
      end
    end
    native.Trace("INV_OVERHAUL_PERF_ICON source=" + source + " slot=" + slot +
      " category=" + category + " index=" + index + " item=" + itemID +
      " sprite=" + sprite)
  end

  function ReportInitialLoadComplete() -> void
    if perfDiagnostics != 1 || perfCompleteReported then return end
    if !perfFirstItemReported then ReportFirstInitialItem() end
    perfCompleteReported = true
    local warmed: int = 0
    local warmStarted: int = 0
    if warmGridLoaded then warmStarted = 1 end
    native.GetVariable("inv_overhaul_ui_cache_loaded", warmed)
    native.Trace("INV_OVERHAUL_PERF_PHASE complete stacks=" + perfStackCount +
      " equipment=" + perfEquipmentCount + " hits=" + perfCacheHits +
      " misses=" + perfCacheMisses + " warmed=" + warmed +
      " warm_start=" + warmStarted)
  end

  function TryWarmStartGrid() -> void
    if warmStartAttempted || !gridRendererReady || !initialSlotLoadPending then return end
    warmStartAttempted = true

    local characterReady: int = 0
    local fullyWarmed: int = 0
    local completedGeneration: int = -1
    local currentGeneration: int = 0
    native.GetVariable("inv_overhaul_ui_cache_character_ready", characterReady)
    native.GetVariable("inv_overhaul_ui_cache_fully_warmed", fullyWarmed)
    native.GetVariable("inv_overhaul_ui_cache_completed_generation", completedGeneration)
    native.GetVariable("inv_overhaul_inventory_content_generation", currentGeneration)
    if characterReady != 1 || fullyWarmed != 1 || completedGeneration != currentGeneration then
      if perfDiagnostics == 1 then
        native.Trace("INV_OVERHAUL_PERF_PHASE warm_start ready=0 generation=" +
          completedGeneration + " current=" + currentGeneration)
      end
      return
    end

    LoadLayoutVariables()
    InitializePersistentBackpackSnapshot()
    OrderFreeCellsByDisplayForCount(lastBackpackItemCount)
    BuildEquipmentIndexCache()
    MeasureInitialTextureCacheCoverage()
    if perfCacheMisses > 0 then
      if perfDiagnostics == 1 then
        native.Trace("INV_OVERHAUL_PERF_PHASE warm_start ready=0 hits=" +
          perfCacheHits + " misses=" + perfCacheMisses)
      end
      return
    end

    ClampPage()
    for slot = 0, visibleSlots - 1 do UpdateSlot(slot) end
    warmGridLoaded = true
    initialMetadataStage = 2
    initialSlotLoadDelay = 0
    if perfDiagnostics == 1 then
      native.Trace("INV_OVERHAUL_PERF_PHASE warm_start ready=1 hits=" +
        perfCacheHits + " misses=" + perfCacheMisses)
    end
  end

  function BeginInitialSlotLoad() -> void
    UpdateLayout()
    ClampPage()
    BuildEquipmentIndexCache()
    MeasureInitialTextureCacheCoverage()
    UpdatePageControls()
    if warmGridLoaded then
      initialSlotLoadNext = visibleSlots
    else
      initialSlotLoadNext = 0
    end
    initialEquipmentLoadNext = 0
    initialSpriteLoadCooldown = 0
    -- Every inventory window is created with empty slot backgrounds already
    -- assigned by the child scripts.  Initialise the five equipment labels in
    -- one cheap pass; ContinueInitialSlotLoad then spends frames only on
    -- occupied slots whose sprites actually have to be decoded.
    for cache = 0, 4 do
      local wndName: string = GetTargetWndName(c_iTargetWeapon + cache)
      native.SendMessage(c_iSlotEmpty, wndName)
      native.SendMessage(-140, wndName)
      native.SendMessage(-30 - cache, wndName)
    end
    initialSlotLoadActive = true
    native.Trace("inv_overhaul_inventory deferred initial slots count=" + visibleSlots)
  end

  function ContinueInitialSlotLoad() -> void
    if !initialSlotLoadActive then return end
    native.Trace("INV_OVERHAUL_PERF_STEP slot_pass_begin")
    for batch = 0, c_iInitialSlotLoadBatch - 1 do
      local loadedSprite: bool = false

      -- Empty equipment slots have already been initialised in
      -- BeginInitialSlotLoad.  Skip them without consuming a whole frame.
      while !loadedSprite && initialEquipmentLoadNext < 5 do
        local category: int
        local index: int
        equipmentCategoryCache->get(category, initialEquipmentLoadNext)
        equipmentIndexCache->get(index, initialEquipmentLoadNext)
        if category >= 0 && index >= 0 then
          local preloaded: bool = IsContainerItemTexturePreloaded(category, index)
          UpdateCachedEquipmentSlot(initialEquipmentLoadNext)
          MarkItemTextureLoaded(category, index)
          ReportFirstInitialItem()
          loadedSprite = true
        end
        initialEquipmentLoadNext = initialEquipmentLoadNext + 1
      end

      -- A freshly-created empty grid slot already has the correct background.
      -- Only occupied cells need an item message and native.LoadImage. Invalid
      -- cells on a short final page are still explicitly hidden.
      while !loadedSprite && initialSlotLoadNext < visibleSlots do
        local slot: int = initialSlotLoadNext
        initialSlotLoadNext = initialSlotLoadNext + 1
        if GetVisibleCell(slot) < 0 then
          UpdateSlot(slot)
        else
          if ResolveVisibleSlot(slot) then
            local preloaded: bool = IsContainerItemTexturePreloaded(resolvedCategory, resolvedIndex)
            UpdateSlot(slot)
            MarkItemTextureLoaded(resolvedCategory, resolvedIndex)
            ReportFirstInitialItem()
            loadedSprite = true
          end
        end
      end
    end
    if initialEquipmentLoadNext >= 5 && initialSlotLoadNext >= visibleSlots then
      initialSlotLoadActive = false
      ReportInitialLoadComplete()
      native.Trace("inv_overhaul_inventory sequential initial slots complete batch=" +
        c_iInitialSlotLoadBatch)
    end
    native.Trace("INV_OVERHAUL_PERF_STEP slot_pass_end")
  end

  function UpdateSlots() -> void
    initialSlotLoadActive = false
    UpdateLayout()
    ClampPage()
    lastBackpackItemCount = BuildBackpackIndexCacheAndSnapshot()
    for slot = 0, visibleSlots - 1 do UpdateSlot(slot) end
    UpdateEquipmentSlots()
    UpdatePageControls()
  end

  function UpdateEquipmentSlot(target: int) -> void
    local wndName: string = GetTargetWndName(target)
    if ResolveEquipmentTarget(target) then
      local container: object = GetPlayerContainer()
      local item: object
      container->GetItem(item, resolvedIndex, resolvedCategory)
      native.SendMessage(0, wndName, item)
      local itemID: int
      item->GetItemID(itemID)
      local quickslot: int = GetDisplayedQuickslot(resolvedCategory, resolvedIndex, itemID)
      native.SendMessage(-140, wndName)
      if quickslot > 0 then native.SendMessage(-140 - quickslot, wndName) end
    else
      native.SendMessage(c_iSlotEmpty, wndName)
      native.SendMessage(-140, wndName)
    end
    native.SendMessage(-30 - (target - c_iTargetWeapon), wndName)
  end

  function BuildEquipmentIndexCache() -> void
    for cache = 0, 4 do
      equipmentCategoryCache->set(cache, -1)
      equipmentIndexCache->set(cache, -1)
    end

    local container: object = GetPlayerContainer()
    local weaponCount: int
    container->GetItemCount(weaponCount, c_iCWeapon)
    for weaponIndex = 0, weaponCount - 1 do
      local selectedWeapon: bool
      container->IsItemSelected(selectedWeapon, weaponIndex, c_iCWeapon)
      if selectedWeapon then
        local weapon: object
        local weaponID: int
        local hasWeapon: bool
        container->GetItem(weapon, weaponIndex, c_iCWeapon)
        weapon->GetItemID(weaponID)
        native.HasInvItemProperty(hasWeapon, weaponID, "Weapon")
        if hasWeapon then
          equipmentCategoryCache->set(0, c_iCWeapon)
          equipmentIndexCache->set(0, weaponIndex)
          weaponIndex = weaponCount
        end
      end
    end

    local clothesCount: int
    container->GetItemCount(clothesCount, c_iCClothes)
    for clothesIndex = 0, clothesCount - 1 do
      local selectedClothes: bool
      container->IsItemSelected(selectedClothes, clothesIndex, c_iCClothes)
      if selectedClothes then
        local clothes: object
        local clothesID: int
        local hasGroup: bool
        container->GetItem(clothes, clothesIndex, c_iCClothes)
        clothes->GetItemID(clothesID)
        native.HasInvItemProperty(hasGroup, clothesID, "Group")
        if hasGroup then
          local group: int
          native.GetInvItemProperty(group, clothesID, "Group")
          if group >= 1 && group <= 4 then
            equipmentCategoryCache->set(group, c_iCClothes)
            equipmentIndexCache->set(group, clothesIndex)
          end
        end
      end
    end

  end

  function UpdateCachedEquipmentSlot(cache: int) -> void
    local category: int
    local index: int
    local wndName: string = GetTargetWndName(c_iTargetWeapon + cache)
    equipmentCategoryCache->get(category, cache)
    equipmentIndexCache->get(index, cache)
    if category >= 0 && index >= 0 then
      local container: object = GetPlayerContainer()
      local item: object
      container->GetItem(item, index, category)
      native.SendMessage(0, wndName, item)
      local itemID: int
      item->GetItemID(itemID)
      local quickslot: int = GetDisplayedQuickslot(category, index, itemID)
      native.SendMessage(-140, wndName)
      if quickslot > 0 then native.SendMessage(-140 - quickslot, wndName) end
    else
      native.SendMessage(c_iSlotEmpty, wndName)
      native.SendMessage(-140, wndName)
    end
    native.SendMessage(-30 - cache, wndName)
  end

  function UpdateEquipmentSlots() -> void
    BuildEquipmentIndexCache()
    for cache = 0, 4 do
      UpdateCachedEquipmentSlot(cache)
    end
  end

  function UpdateVisibleCell(cell: int) -> void
    if cell < 0 then return end
    for slot = 0, visibleSlots - 1 do
      if GetVisibleCell(slot) == cell then
        UpdateSlot(slot)
        return
      end
    end
  end

  function RefreshEquipmentMutation(changedCell: int, equipmentTarget: int) -> void
    initialSlotLoadActive = false
    lastBackpackItemCount = BuildBackpackIndexCacheAndSnapshot()
    if lastBackpackItemCount > c_iInventoryCapacity then lastBackpackItemCount = c_iInventoryCapacity end
    UpdateVisibleCell(changedCell)
    BuildEquipmentIndexCache()
    local cache: int = equipmentTarget - c_iTargetWeapon
    if cache >= 0 && cache < 5 then UpdateCachedEquipmentSlot(cache) end
    UpdatePageControls()
  end

  function ResolveEquipmentTarget(target: int) -> bool
    resolvedCategory = -1
    resolvedIndex = -1
    local container: object = GetPlayerContainer()

    if target == c_iTargetWeapon then
      local weaponCount: int
      container->GetItemCount(weaponCount, c_iCWeapon)
      for index = 0, weaponCount - 1 do
        local selected: bool
        container->IsItemSelected(selected, index, c_iCWeapon)
        if selected then
          local item: object
          container->GetItem(item, index, c_iCWeapon)
          local itemID: int
          item->GetItemID(itemID)
          local hasWeapon: bool
          native.HasInvItemProperty(hasWeapon, itemID, "Weapon")
          if hasWeapon then
            resolvedCategory = c_iCWeapon
            resolvedIndex = index
            return true
          end
        end
      end
      return false
    end

    if target <= c_iTargetClothesBase || target > c_iTargetClothesBase + 4 then
      return false
    end

    local requiredGroup: int = target - c_iTargetClothesBase
    local clothesCount: int
    container->GetItemCount(clothesCount, c_iCClothes)
    for index = 0, clothesCount - 1 do
      local selected: bool
      container->IsItemSelected(selected, index, c_iCClothes)
      if selected then
        local item: object
        container->GetItem(item, index, c_iCClothes)
        local itemID: int
        item->GetItemID(itemID)
        local hasGroup: bool
        native.HasInvItemProperty(hasGroup, itemID, "Group")
        if hasGroup then
          local group: int
          native.GetInvItemProperty(group, itemID, "Group")
          if group == requiredGroup then
            resolvedCategory = c_iCClothes
            resolvedIndex = index
            return true
          end
        end
      end
    end
    return false
  end

  function ResolveDragSource(source: int) -> bool
    if source >= 0 && source < visibleSlots then
      return ResolveVisibleSlot(source)
    end
    return ResolveEquipmentTarget(source)
  end

  function UnequipItem(category: int, index: int) -> bool
    if category != c_iCWeapon && category != c_iCClothes then return false end
    local container: object = GetPlayerContainer()
    local selected: bool
    container->IsItemSelected(selected, index, category)
    if !selected then return false end
    container->SelectItem(index, false, category)
    if category == c_iCWeapon then
      native.SetPlayerHandsItem(-1)
    end
    return true
  end

  function EquipDraggedItem(target: int, category: int, index: int) -> bool
    local container: object = GetPlayerContainer()
    local item: object
    container->GetItem(item, index, category)
    if !item then return false end

    local itemID: int
    item->GetItemID(itemID)
    if target == c_iTargetWeapon then
      if category != c_iCWeapon then return false end
      local hasWeapon: bool
      native.HasInvItemProperty(hasWeapon, itemID, "Weapon")
      if !hasWeapon then return false end

      native.SetPlayerHandsItem(itemID)
      local count: int
      container->GetItemCount(count, c_iCWeapon)
      for i = 0, count - 1 do
        local otherSelected: bool
        container->IsItemSelected(otherSelected, i, c_iCWeapon)
        if otherSelected then container->SelectItem(i, false, c_iCWeapon) end
      end
      container->SelectItem(index, true, c_iCWeapon)
      return true
    end

    if target <= c_iTargetClothesBase || target > c_iTargetClothesBase + 4 then return false end
    if category != c_iCClothes then return false end
    local hasGroup: bool
    native.HasInvItemProperty(hasGroup, itemID, "Group")
    if !hasGroup then return false end
    local group: int
    native.GetInvItemProperty(group, itemID, "Group")
    if target != c_iTargetClothesBase + group then return false end

    local count: int
    container->GetItemCount(count, c_iCClothes)
    for i = 0, count - 1 do
      local other: object
      container->GetItem(other, i, c_iCClothes)
      local otherID: int
      other->GetItemID(otherID)
      local otherHasGroup: bool
      native.HasInvItemProperty(otherHasGroup, otherID, "Group")
      if otherHasGroup then
        local otherGroup: int
        native.GetInvItemProperty(otherGroup, otherID, "Group")
        if otherGroup == group then container->SelectItem(i, false, c_iCClothes) end
      end
    end
    container->SelectItem(index, true, c_iCClothes)
    return true
  end

  function ToggleSlot(category: int, index: int) -> void
    local container: object = GetPlayerContainer()
    local item: object
    container->GetItem(item, index, category)

    local itemID: int
    item->GetItemID(itemID)

    local amount: int
    container->GetItemAmount(amount, index, category)

    local selected: bool
    container->IsItemSelected(selected, index, category)

    if category == c_iCWeapon then
      local hasWeapon: bool
      native.HasInvItemProperty(hasWeapon, itemID, "Weapon")
      if !hasWeapon then
        return
      end

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
      if !hasGroup then
        return
      end

      local group: int
      native.GetInvItemProperty(group, itemID, "Group")
      if selected then
        container->SelectItem(index, false, category)
      else
        local count: int
        container->GetItemCount(count, category)
        for i = 0, count - 1 do
          local otherSelected: bool
          container->IsItemSelected(otherSelected, i, category)
          if otherSelected then
            local other: object
            container->GetItem(other, i, category)
            local otherID: int
            other->GetItemID(otherID)
            local otherHasGroup: bool
            native.HasInvItemProperty(otherHasGroup, otherID, "Group")
            if otherHasGroup then
              local otherGroup: int
              native.GetInvItemProperty(otherGroup, otherID, "Group")
              if otherGroup == group then
                container->SelectItem(i, false, category)
              end
            end
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
      if amount == 0 then
        container->RemoveItem(index, 1, category)
      else
        container->SetItemAmount(amount, index, category)
      end
    end
  end

  function DropSlot(category: int, index: int, requestedAmount: int) -> bool
    local container: object
    native.GetContainer(container)
    if !container then
      native.Trace("inv_overhaul_inventory drop failed: world container unavailable")
      return false
    end

    local playerContainer: object = GetPlayerContainer()
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
      native.Trace("inv_overhaul_inventory drop failed: AddItem rejected category=" + category + " index=" + index)
      return false
    end

    if category == c_iCWeapon then
      local selected: bool
      playerContainer->IsItemSelected(selected, index, category)
      if selected then
        native.SetPlayerHandsItem(-1)
      end
    end

    playerContainer->RemoveItem(index, amount, category)
    native.Trace("inv_overhaul_inventory drop success category=" + category + " index=" + index + " amount=" + amount)
    return true
  end

  function HandleModifiedDrop(sourceSlot: int) -> bool
    if !shiftHeld && !controlHeld then return false end
    if sourceSlot < 0 || sourceSlot >= visibleSlots then return false end
    if !ResolveVisibleSlot(sourceSlot) then return true end

    if controlHeld && !shiftHeld then
      MoveSlotToOtherPage(sourceSlot)
      return true
    end

    local category: int = resolvedCategory
    local index: int = resolvedIndex
    local amount: int
    local player: object = GetPlayerContainer()
    player->GetItemAmount(amount, index, category)

    local beforeCount: int = GetBackpackItemCount()
    local usedOrder: int = GetOrderValue(GetVisibleCell(sourceSlot))
    if DropSlot(category, index, amount) then
      local afterCount: int = GetBackpackItemCount()
      if afterCount < beforeCount then RemoveOrderOrdinal(usedOrder, beforeCount) end
      UpdateSlots()
    end
    return true
  end

  function MoveSlotToOtherPage(sourceSlot: int) -> void
    local maxPage: int = GetMaxPage()
    if maxPage <= 0 then return end

    local targetPage: int = page + 1
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

    local sourceCell: int = GetVisibleCell(sourceSlot)
    SwapSlotOrderCells(sourceCell, targetCell)
    native.Trace("inv_overhaul_inventory ctrl-page-move sourcePage=" + page + " targetPage=" + targetPage)
  end

  function HandleSlotMessage(message: int, sender: string) -> bool
    for slot = 0, visibleSlots - 1 do
      if sender == GetSlotWndName(slot) then
        if ResolveVisibleSlot(slot) then
          if message == 1 then
            local beforeCount: int = GetBackpackItemCount()
            local usedOrder: int = GetOrderValue(GetVisibleCell(slot))
            local category: int = resolvedCategory
            ToggleSlot(resolvedCategory, resolvedIndex)
            local afterCount: int = GetBackpackItemCount()
            native.Trace("inv_overhaul_inventory slot toggle category=" + category + " order=" + usedOrder +
              " before=" + beforeCount + " after=" + afterCount)
            if afterCount < beforeCount then
              if category == c_iCWeapon || category == c_iCClothes then
                if !RestoreOrderAfterEquipmentSelection(usedOrder, beforeCount) then
                  RemoveOrderOrdinal(usedOrder, beforeCount)
                end
              else
                RemoveOrderOrdinal(usedOrder, beforeCount)
              end
            else
              if afterCount == beforeCount && (category == c_iCWeapon || category == c_iCClothes) then
                RestoreOrderAfterEquipmentReplacement(usedOrder, beforeCount)
              end
            end
          else
            native.Trace("inv_overhaul_inventory left click ignored " + sender)
          end
        end
        UpdateSlots()
        return true
      end
    end
    return false
  end

  function GetSlotBySender(sender: string) -> int
    for slot = 0, visibleSlots - 1 do
      if sender == GetSlotWndName(slot) then
        return slot
      end
    end
    return -1
  end

  function GetDragSourceBySender(sender: string) -> int
    local backpackSource: int = GetSlotBySender(sender)
    if backpackSource >= 0 then return backpackSource end
    return GetSpecialTargetBySender(sender)
  end

  function GetSpecialTargetBySender(sender: string) -> int
    if sender == "equip_weapon" then return c_iTargetWeapon end
    if sender == "equip_feet" then return c_iTargetClothesBase + 1 end
    if sender == "equip_head" then return c_iTargetClothesBase + 2 end
    if sender == "equip_body" then return c_iTargetClothesBase + 3 end
    if sender == "equip_hands" then return c_iTargetClothesBase + 4 end
    if sender == "drop_slot" then return c_iTargetDrop end
    return -1
  end

  function GetSpecialTargetByDollMessage(message: int) -> int
    if message == -50 then return c_iTargetWeapon end
    if message == -51 then return c_iTargetClothesBase + 1 end
    if message == -52 then return c_iTargetClothesBase + 2 end
    if message == -53 then return c_iTargetClothesBase + 3 end
    if message == -54 then return c_iTargetClothesBase + 4 end
    return -1
  end

  function GetSpecialTargetByDollSourceMessage(message: int, base: int) -> int
    local offset: int = base - message
    if offset == 0 then return c_iTargetWeapon end
    if offset >= 1 && offset <= 4 then return c_iTargetClothesBase + offset end
    return -1
  end

  function IsSpecialTargetCompatible(target: int) -> bool
    if target == c_iTargetDrop then return true end
    if target == c_iTargetWeapon then
      return dragItemCategory == c_iCWeapon && dragItemIsWeapon
    end
    if target > c_iTargetClothesBase && target <= c_iTargetClothesBase + 4 then
      return dragItemCategory == c_iCClothes && target == c_iTargetClothesBase + dragItemGroup
    end
    return false
  end

  function StartDragAction(source: int, sender: string) -> void
    CancelDragPageHover(0)
    ClearPanelTooltip()
    dragSourceSlot = source
    dragSourceCell = -1
    if source >= 0 && source < visibleSlots then dragSourceCell = GetVisibleCell(source) end
    hoverSlot = dragSourceSlot
    lastPointerSlot = dragSourceSlot
    dragDebugLastPointerSlot = -999
    dragDebugLastAppliedTarget = -999
    dragMoved = false
    lastValidDropTarget = -1
    invalidDropTargetFrames = 0
    SetHighlightedSlot(-1)
    BeginDragCursor(dragSourceSlot)
    native.Trace("inv_overhaul_inventory press " + sender + " " + dragSourceSlot)
  end

  function UnequipTarget(target: int, reason: string) -> void
    if ResolveEquipmentTarget(target) then
      local beforeCount: int = GetBackpackItemCount()
      if beforeCount >= c_iInventoryCapacity then
        native.Trace("inv_overhaul_inventory unequip refused: backpack full target=" + target)
        ShowInventoryFull()
        return
      end
      local category: int = resolvedCategory
      local index: int = resolvedIndex
      if UnequipItem(category, index) then
        InsertOrderOrdinal(GetBackpackOrdinal(category, index), beforeCount)
        native.Trace("inv_overhaul_inventory unequipped by " + reason + " target=" + target)
      end
      UpdateSlots()
    end
  end

  function SwapSlotOrder(sourceSlot: int, targetSlot: int) -> void
    if sourceSlot < 0 || targetSlot < 0 || sourceSlot == targetSlot then
      return
    end
    if sourceSlot >= visibleSlots || targetSlot >= visibleSlots then
      return
    end

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
      if visibleCell == sourceCell || visibleCell == targetCell then UpdateSlot(visibleSlot) end
    end
  end

  function RemoveOrderOrdinal(removedOrder: int, beforeCount: int) -> void
    if removedOrder < 0 then
      return
    end

    local emptyOrder: int = beforeCount - 1
    for slot = 0, c_iInventoryCapacity - 1 do
      local order: int = GetOrderValue(slot)
      if order == removedOrder then
        SetOrderValue(slot, emptyOrder)
      else
        if order > removedOrder && order < beforeCount then
          SetOrderValue(slot, order - 1)
        end
      end
    end
    NormalizeSlotOrder()
    OrderFreeCellsByDisplay()
    QueueLayoutSave()
  end

  function FindFirstFreeVisualSlot(itemCount: int) -> int
    for linear = 0, c_iInventoryCapacity - 1 do
      local cell: int = GetCellForLinearSlot(linear)
      if cell >= 0 && GetOrderValue(cell) >= itemCount then
        return cell
      end
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
          if currentCategory == category && currentIndex == index then
            return ordinal
          end
          ordinal = ordinal + 1
        end
      end
    end
    return -1
  end

  function InsertOrderOrdinal(insertedOrder: int, beforeCount: int) -> bool
    return InsertOrderOrdinalAtCell(insertedOrder, beforeCount, FindFirstFreeVisualSlot(beforeCount))
  end

  function InsertOrderOrdinalAtCell(insertedOrder: int, beforeCount: int, targetCell: int) -> bool
    if insertedOrder < 0 || targetCell < 0 || targetCell >= c_iInventoryCapacity then return false end
    local freeCell: int = FindFirstFreeVisualSlot(beforeCount)
    if freeCell < 0 then return false end

    local targetOrder: int = GetOrderValue(targetCell)
    local targetOccupied: bool = targetOrder >= 0 && targetOrder < beforeCount
    local displacedOrder: int = targetOrder
    if targetOccupied && displacedOrder >= insertedOrder then
      displacedOrder = displacedOrder + 1
    end

    for cell = 0, c_iInventoryCapacity - 1 do
      local order: int = GetOrderValue(cell)
      if order >= insertedOrder && order < beforeCount then
        SetOrderValue(cell, order + 1)
      end
    end

    if freeCell != targetCell then
      if targetOccupied then
        SetOrderValue(freeCell, displacedOrder)
      else
        SetOrderValue(freeCell, targetOrder)
      end
    end
    SetOrderValue(targetCell, insertedOrder)
    NormalizeSlotOrder()
    OrderFreeCellsByDisplay()
    QueueLayoutSave()
    native.Trace("inv_overhaul_inventory inserted ordinal=" + insertedOrder + " targetCell=" + targetCell +
      " displacedCell=" + freeCell + " occupied=" + targetOccupied)
    return true
  end

  function SetHighlightedSlot(slot: int) -> void
    if highlightedSlot == slot then
      return
    end

    if highlightedSlot >= 0 then
      if highlightedSlot < visibleSlots then
        SetGridRendererHighlight(highlightedSlot, false)
      else
        native.SendMessage(-21, GetTargetWndName(highlightedSlot))
      end
    end

    highlightedSlot = slot
    if highlightedSlot >= 0 then
      if highlightedSlot < visibleSlots then
        SetGridRendererHighlight(highlightedSlot, true)
      else
        native.SendMessage(-20, GetTargetWndName(highlightedSlot))
      end
    end
  end

  function FinishLeftAction(targetSlot: int) -> void
    if dragSourceSlot < 0 then
      return
    end

    local sourceSlot: int = dragSourceSlot

    if targetSlot < 0 && lastValidDropTarget >= 0 && invalidDropTargetFrames <= 3 then
      targetSlot = lastValidDropTarget
      native.Trace("inv_overhaul_inventory release latched target=" + targetSlot)
    end

    tooltipResumeDelay = 0.2
    ClearPanelTooltip()
    if sourceSlot >= visibleSlots && sourceSlot <= c_iTargetClothesBase + 4 then
      native.SendMessage(-130, GetTargetWndName(sourceSlot))
    end
    if targetSlot >= visibleSlots && targetSlot <= c_iTargetClothesBase + 4 then
      native.SendMessage(-130, GetTargetWndName(targetSlot))
    end

    if sourceSlot >= c_iTargetWeapon && sourceSlot <= c_iTargetClothesBase + 4 then
      if targetSlot >= 0 && targetSlot < visibleSlots then
        local beforeCount: int = GetBackpackItemCount()
        if beforeCount < c_iInventoryCapacity then
          if UnequipItem(dragItemCategory, dragItemIndex) then
            InsertOrderOrdinalAtCell(
              GetBackpackOrdinal(dragItemCategory, dragItemIndex),
              beforeCount,
              GetVisibleCell(targetSlot))
            native.Trace("inv_overhaul_inventory unequipped by drag source=" + sourceSlot + " target=" + targetSlot)
          end
        else
          native.Trace("inv_overhaul_inventory unequip drag refused: backpack full source=" + sourceSlot)
          ShowInventoryFull()
        end
        RefreshEquipmentMutation(GetVisibleCell(targetSlot), sourceSlot)
      else
        if targetSlot == c_iTargetDrop then
          DropSlot(dragItemCategory, dragItemIndex, 1)
          UpdateSlots()
        else
          native.Trace("inv_overhaul_inventory equipped source release ignored source=" + sourceSlot + " target=" + targetSlot)
        end
      end
    else
      if targetSlot >= 0 && targetSlot < visibleSlots && GetVisibleCell(targetSlot) != dragSourceCell then
        native.Trace("inv_overhaul_inventory swap " + sourceSlot + " " + targetSlot)
        SwapSlotOrderCells(dragSourceCell, GetVisibleCell(targetSlot))
      else
        if targetSlot >= c_iTargetWeapon && targetSlot <= c_iTargetClothesBase + 4 then
          if dragItemCategory >= 0 && dragItemIndex >= 0 then
            local beforeCount: int = GetBackpackItemCount()
            local usedOrder: int = GetOrderValue(dragSourceCell)
            local equipped: bool = EquipDraggedItem(targetSlot, dragItemCategory, dragItemIndex)
            if equipped then
              local afterCount: int = GetBackpackItemCount()
              if afterCount < beforeCount then
                if !RestoreOrderAfterEquipmentSelection(usedOrder, beforeCount) then
                  RemoveOrderOrdinal(usedOrder, beforeCount)
                end
              else
                if afterCount == beforeCount then
                  RestoreOrderAfterEquipmentReplacement(usedOrder, beforeCount)
                end
              end
              native.Trace("inv_overhaul_inventory equipped target=" + targetSlot)
            else
              native.Trace("inv_overhaul_inventory incompatible target=" + targetSlot)
            end
            if equipped then RefreshEquipmentMutation(dragSourceCell, targetSlot) end
          end
        else
          if targetSlot == c_iTargetDrop then
            if dragItemCategory >= 0 && dragItemIndex >= 0 then
              local beforeCount: int = GetBackpackItemCount()
              local usedOrder: int = GetOrderValue(dragSourceCell)
              DropSlot(dragItemCategory, dragItemIndex, 1)
              local afterCount: int = GetBackpackItemCount()
              if afterCount < beforeCount then RemoveOrderOrdinal(usedOrder, beforeCount) end
              UpdateSlots()
            end
          else
            native.Trace("inv_overhaul_inventory left release " + sourceSlot)
          end
        end
      end
    end

    dragSourceSlot = -1
    dragSourceCell = -1
    hoverSlot = -1
    lastPointerSlot = -1
    SetHighlightedSlot(-1)
    dragMoved = false
    lastValidDropTarget = -1
    invalidDropTargetFrames = 0
    dragDebugLastAppliedTarget = -999
    EndDragCursor()
    CancelDragPageHover(0)
  end

  function FindBackpackSlotAt(x: int, y: int) -> int
    local startX: int = GetGridStartX()
    local startY: int = GetGridStartY()
    local step: int = GetGridStep()
    local columns: int = GetGridColumns()

    if x < startX || y < startY then
      return -1
    end

    local rows: int = (visibleSlots + columns - 1) / columns
    if x >= startX + columns * step || y >= startY + rows * step then
      return -1
    end

    local column: int = (x - startX) / step
    local row: int = (y - startY) / step
    if column < 0 || column >= columns || row < 0 || row >= rows then
      return -1
    end

    local localX: int = x - startX - column * step
    local localY: int = y - startY - row * step
    if !IsInsideSlotDropArea(localX, localY) then
      return -1
    end

    local slot: int = row * columns + column
    if slot < 0 || slot >= visibleSlots then
      return -1
    end
    return slot
  end

  function FindSlotAt(x: int, y: int) -> int
    local backpackSlot: int = FindBackpackSlotAt(x, y)
    if backpackSlot >= 0 then return backpackSlot end
    return FindSpecialTargetAt(x, y)
  end

  function IsInsideSlotDropArea(localX: int, localY: int) -> bool
    local hotZone: int = GetSlotHotZone()
    return localX >= c_iSlotDropInset &&
      localY >= c_iSlotDropInset &&
      localX < hotZone - c_iSlotDropInset &&
      localY < hotZone - c_iSlotDropInset
  end

  function FindSlotAtPointer(x: int, y: int) -> int
    return FindSlotAt(x, y)
  end

  function UpdatePointerSlot(x: int, y: int) -> int
    lastPointerSlot = FindSlotAtPointer(x, y)
    if lastPointerSlot != dragDebugLastPointerSlot then
      dragDebugLastPointerSlot = lastPointerSlot
    end
    return lastPointerSlot
  end

  function IsCursorPollingReady() -> bool
    return false
  end

  function UpdatePointerSlotFromCursorVariables() -> int
    local cursorX: int = -1
    local cursorY: int = -1
    native.GetVariable("inv_overhaul_inventory_cursor_x", cursorX)
    native.GetVariable("inv_overhaul_inventory_cursor_y", cursorY)
    if cursorX < 0 || cursorY < 0 then
      lastPointerSlot = -1
      if lastPointerSlot != dragDebugLastPointerSlot then
        dragDebugLastPointerSlot = lastPointerSlot
      end
      return -1
    end

    lastPointerSlot = FindSlotAtPointer(cursorX, cursorY)
    if lastPointerSlot != dragDebugLastPointerSlot then
      dragDebugLastPointerSlot = lastPointerSlot
    end
    return lastPointerSlot
  end

  function ApplyPointerSlot(slot: int) -> void
    if dragSourceSlot < 0 then
      return
    end

    TraceDragTarget(slot)

    local sameSource: bool = false
    if slot == dragSourceSlot then sameSource = true end
    if dragSourceCell >= 0 && slot >= 0 && slot < visibleSlots then
      if GetVisibleCell(slot) == dragSourceCell then sameSource = true else sameSource = false end
    end
    if slot >= 0 && !sameSource then
      dragMoved = true
      lastValidDropTarget = slot
      invalidDropTargetFrames = 0
      SetHighlightedSlot(slot)
    else
      if slot < 0 then
        invalidDropTargetFrames = invalidDropTargetFrames + 1
      else
        invalidDropTargetFrames = 0
      end
      SetHighlightedSlot(-1)
    end
  end

  function GetCurrentDropSlot(message: int, base: int, sender: string) -> int
    if IsCursorPollingReady() then
      return UpdatePointerSlotFromCursorVariables()
    end
    return GetSlotTargetFromPointerMessage(message, base, sender)
  end

  function GetSlotTargetFromPointerMessage(message: int, base: int, sender: string) -> int
    local senderSlot: int = GetSlotBySender(sender)
    if senderSlot < 0 then
      return -1
    end

    local encoded: int = message - base
    local localX: int = encoded / 100
    local localY: int = encoded - localX * 100
    local targetSlot: int = -1
    if IsInsideSlotDropArea(localX, localY) then
      targetSlot = senderSlot
    end
    if targetSlot != dragDebugLastTargetSlot then
      dragDebugLastTargetSlot = targetSlot
    end
    return targetSlot
  end

  function ChangePage(delta: int) -> void
    page = page + delta
    ClampPage()
    UpdateSlots()
  end

  function GetDragPageHoverAction(sender: string) -> int
    if sender == "page_prev" && page > 0 then return -1 end
    if sender == "page_next" && page < GetMaxPage() then return 1 end
    return 0
  end

  function BeginDragPageHover(sender: string) -> void
    if dragSourceSlot < 0 then return end
    local action: int = GetDragPageHoverAction(sender)
    if action == 0 then return end
    if dragPageHoverAction == action then return end
    dragPageHoverAction = action
    dragPageHoverElapsed = 0
    dragPageHoverConsumed = false
    native.Trace("inv_overhaul_inventory page-hover begin sender=" + sender + " action=" + action + " source=" + dragSourceSlot)
  end

  function CancelDragPageHover(action: int) -> void
    if action != 0 && dragPageHoverAction != action then return end
    if dragPageHoverAction != 0 then
      native.Trace("inv_overhaul_inventory page-hover cancel action=" + dragPageHoverAction + " elapsed=" + dragPageHoverElapsed)
    end
    dragPageHoverAction = 0
    dragPageHoverElapsed = 0
    dragPageHoverConsumed = false
  end

  function UpdateDragPageHover(delta: float) -> void
    if dragSourceSlot < 0 || dragPageHoverAction == 0 || dragPageHoverConsumed then return end
    if dragPageHoverAction < 0 && page <= 0 then
      CancelDragPageHover(dragPageHoverAction)
      return
    end
    if dragPageHoverAction > 0 && page >= GetMaxPage() then
      CancelDragPageHover(dragPageHoverAction)
      return
    end
    dragPageHoverElapsed = dragPageHoverElapsed + delta
    if dragPageHoverElapsed < c_fPageHoverDelay then return end
    dragPageHoverConsumed = true
    lastValidDropTarget = -1
    invalidDropTargetFrames = 0
    SetHighlightedSlot(-1)
    native.Trace("inv_overhaul_inventory page-hover switch action=" + dragPageHoverAction + " page=" + page)
    ChangePage(dragPageHoverAction)
  end

  function SyncDragPageHoverFromCursor() -> void
    if dragSourceSlot < 0 then
      CancelDragPageHover(0)
      return
    end
    local hoverTarget: int = 0
    local action: int = 0
    native.GetVariable("inv_overhaul_inventory_page_hover", hoverTarget)
    if hoverTarget == 1 && page > 0 then action = -1 end
    if hoverTarget == 2 && page < GetMaxPage() then action = 1 end
    if action == 0 then
      CancelDragPageHover(0)
      return
    end
    if action == dragPageHoverAction then return end
    dragPageHoverAction = action
    dragPageHoverElapsed = 0
    dragPageHoverConsumed = false
    native.Trace("inv_overhaul_inventory page-hover cursor target=" + hoverTarget + " action=" + action + " page=" + page)
  end

  function OnUpdate(delta: float) -> void
    if !childWindowsReady then
      native.Trace("INV_OVERHAUL_PERF_STEP first_update_begin")
      childWindowsReady = true
      if perfDiagnostics == 1 then native.Trace("INV_OVERHAUL_PERF_PHASE child_ready") end
      lastLayoutWidth = -1
      lastLayoutHeight = -1
      lastLayoutSlots = -1
      UpdateLayout()
      UpdatePageControls()
      UpdateMoney()
      native.Trace("INV_OVERHAUL_PERF_STEP first_update_children_ready")
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
          native.Trace("INV_OVERHAUL_PERF_STEP layout_batch_begin")
          if ContinueIncrementalLayoutLoad() then initialMetadataStage = 1 end
          native.Trace("INV_OVERHAUL_PERF_STEP layout_batch_end")
        end
        if initialMetadataStage == 1 then
          native.Trace("INV_OVERHAUL_PERF_STEP snapshot_begin")
          InitializePersistentBackpackSnapshot()
          initialMetadataStage = 2
          native.Trace("INV_OVERHAUL_PERF_STEP snapshot_end")
        end
        if initialMetadataStage == 2 then
          native.Trace("INV_OVERHAUL_PERF_STEP free_order_begin")
          OrderFreeCellsByDisplayForCount(lastBackpackItemCount)
          native.Trace("INV_OVERHAUL_PERF_STEP free_order_end")
          if perfDiagnostics == 1 then native.Trace("INV_OVERHAUL_PERF_PHASE layout_ready") end
          initialSlotLoadPending = false
          native.Trace("INV_OVERHAUL_PERF_STEP initial_load_begin")
          BeginInitialSlotLoad()
          native.Trace("INV_OVERHAUL_PERF_STEP initial_load_end")
        end
      end
    end
    if initialSlotLoadActive then
      if initialSpriteLoadCooldown > 0 then
        initialSpriteLoadCooldown = initialSpriteLoadCooldown - delta
      end
      if initialSpriteLoadCooldown <= 0 then
        ContinueInitialSlotLoad()
        if initialSlotLoadActive then
          initialSpriteLoadCooldown = c_fInitialItemLoadInterval
        end
      end
    end
    ContinueLayoutSave()
    inventoryPollCooldown = inventoryPollCooldown - delta
    if inventoryPollCooldown <= 0 then
      inventoryPollCooldown = 0.25
      UpdateMoney()
      local currentBackpackCount: int = CaptureBackpackItems(currentBackpackSnapshot)
      if dragSourceSlot < 0 && BackpackSnapshotDiffers(currentBackpackCount) then
        ReconcileBackpackSnapshot(currentBackpackCount)
        UpdateSlots()
        SavePersistentBackpackSnapshot()
      end
    end
    if deferredInventoryRefresh > 0 then
      deferredInventoryRefresh = deferredInventoryRefresh - delta
      if deferredInventoryRefresh <= 0 then
        UpdateSlots()
        native.Trace("inv_overhaul_inventory deferred item-use refresh")
      end
    end
    if dragSourceSlot >= 0 && IsCursorPollingReady() then
      ApplyPointerSlot(UpdatePointerSlotFromCursorVariables())
    end
    SyncDragPageHoverFromCursor()
    UpdateDragPageHover(delta)
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

  function StartPanelPointerDrag(x: int, y: int) -> void
    if dragSourceSlot >= 0 then return end

    local equipmentTarget: int = FindEquipmentTargetAt(x, y)
    if equipmentTarget >= 0 && ResolveEquipmentTarget(equipmentTarget) then
      StartDragAction(equipmentTarget, "panel_background")
      return
    end

    local backpackSlot: int = FindBackpackSlotAt(x, y)
    if backpackSlot >= 0 && HandleModifiedDrop(backpackSlot) then return end
    if backpackSlot >= 0 && ResolveVisibleSlot(backpackSlot) then
      StartDragAction(backpackSlot, "panel_background")
    end
  end

  function ClearPanelTooltip() -> void
    if panelTooltipTarget != -1 then
    end
    panelTooltipTarget = -1
    native.SendMessage(-1, "panel_background")
  end

  function ShowDropPanelTooltip() -> void
    if panelTooltipTarget != c_iTargetDrop then
      panelTooltipTarget = c_iTargetDrop
    end
    native.SetVariable("inv_overhaul_inventory_tooltip_item", -1)
    native.SetVariable("inv_overhaul_inventory_tooltip_text_id", 1401)
    native.SetVariable("inv_overhaul_inventory_tooltip_type", 5)
  end

  function ShowPagingPanelTooltip() -> void
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
    if GetMaxPage() <= 0 then return false end
    local controlX: int = 467
    local controlY: int = 481
    if windowWidth >= 1900 then
      controlX = 1082
      controlY = 826
    else
    if windowWidth >= 1000 then
      controlX = 626
      controlY = 632
    end
    end
    return x >= controlX && x < controlX + 132 && y >= controlY && y < controlY + 36
  end

  function UpdatePanelTooltip(x: int, y: int) -> void
    if tooltipResumeDelay > 0 then
      ClearPanelTooltip()
      return
    end
    if dragSourceSlot >= 0 then
      ClearPanelTooltip()
      return
    end
    if IsInsideQuickslotHelp(x, y) then
      ShowQuickslotHelpPanelTooltip()
      return
    end
    if IsInsidePlayerPaging(x, y) then
      ShowPagingPanelTooltip()
      return
    end

    if IsInsideSpecialTarget(c_iTargetDrop, x, y) then
      ShowDropPanelTooltip()
      return
    end

    if IsInsideMoney(x, y) then
      if panelTooltipTarget != c_iTargetMoney then
        panelTooltipTarget = c_iTargetMoney
        native.SendMessage(1, "panel_background", moneyTooltipItem)
      end
      return
    end

    local target: int = FindBackpackSlotAt(x, y)
    local found: bool = false
    if target >= 0 then
      found = ResolveVisibleSlot(target)
    else
      target = FindEquipmentTargetAt(x, y)
      if target >= 0 then found = ResolveEquipmentTarget(target) end
    end

    if !found then
      ClearPanelTooltip()
      return
    end
    if panelTooltipTarget == target then return end

    local container: object = GetPlayerContainer()
    local item: object
    container->GetItem(item, resolvedIndex, resolvedCategory)
    if item then
      panelTooltipTarget = target
      native.SendMessage(1, "panel_background", item)
    else
      ClearPanelTooltip()
    end
  end

  function HandlePanelPointer(message: int) -> void
    local base: int = c_iPanelPointerMoveBase
    local action: int = 0

    if message >= c_iPanelPointerLeaveBase then
      ClearPanelTooltip()
      native.SendMessage(-95, "page_prev")
      native.SendMessage(-95, "page_next")
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
      local equipmentTarget: int = FindEquipmentTargetAt(x, y)
      if equipmentTarget >= 0 then
        UnequipTarget(equipmentTarget, "panel right click")
        return
      end
      local backpackSlot: int = FindBackpackSlotAt(x, y)
      if backpackSlot >= 0 then HandleSlotMessage(1, GetSlotWndName(backpackSlot)) end
      return
    end

    local targetSlot: int = FindSlotAt(x, y)
    if action == 3 then
      if dragSourceSlot >= 0 then
        ApplyPointerSlot(targetSlot)
        FinishLeftAction(targetSlot)
      end
      return
    end

    if dragSourceSlot >= 0 then ApplyPointerSlot(targetSlot) end
  end

  function HandlePageControlAt(x: int, y: int) -> bool
    if visibleSlots >= c_iInventoryCapacity then return false end

    local controlX: int = 467
    local controlY: int = 481
    if windowWidth >= 1900 then
      controlX = 1082
      controlY = 826
    else
    if windowWidth >= 1000 then
      controlX = 626
      controlY = 632
    end
    end

    if y < controlY || y >= controlY + 36 then return false end
    if x >= controlX && x < controlX + 40 then
      if page > 0 then ChangePage(-1) end
      return true
    end
    if x >= controlX + 92 && x < controlX + 132 then
      if page < GetMaxPage() then ChangePage(1) end
      return true
    end
    return false
  end

  function UpdatePageControlHover(x: int, y: int) -> void
    if GetMaxPage() <= 0 then return end
    local controlX: int = 467
    local controlY: int = 481
    if windowWidth >= 1900 then
      controlX = 1082
      controlY = 826
    else
    if windowWidth >= 1000 then
      controlX = 626
      controlY = 632
    end
    end
    if page > 0 && x >= controlX && x < controlX + 40 && y >= controlY && y < controlY + 36 then
      native.SendMessage(-94, "page_prev")
    else
      native.SendMessage(-95, "page_prev")
    end
    if page < GetMaxPage() && x >= controlX + 92 && x < controlX + 132 && y >= controlY && y < controlY + 36 then
      native.SendMessage(-94, "page_next")
    else
      native.SendMessage(-95, "page_next")
    end
  end

  function OnUIMessage(message: int, sender: string, data: object) -> void
    if message == c_iQuickslotHelpHover && sender == "panel_background" then
      ShowQuickslotHelpPanelTooltip()
      return
    end
    if message == c_iGridRendererReady then
      gridRendererReady = true
      TryWarmStartGrid()
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
    if sender == "panel_background" && message >= c_iPanelPointerMoveBase then
      HandlePanelPointer(message)
      return
    end

    if message == -43 then
      local unequipTarget: int = GetSpecialTargetBySender(sender)
      UnequipTarget(unequipTarget, "right click")
      return
    end

    if message <= -60 && message >= -64 then
      local dollSource: int = GetSpecialTargetByDollSourceMessage(message, -60)
      if ResolveEquipmentTarget(dollSource) then
        StartDragAction(dollSource, "character_doll")
      end
      return
    end

    if message <= -70 && message >= -74 then
      local dollTarget: int = GetSpecialTargetByDollSourceMessage(message, -70)
      UnequipTarget(dollTarget, "doll right click")
      return
    end

    if message == -40 then
      if dragSourceSlot >= 0 then
        local specialTarget: int = GetSpecialTargetBySender(sender)
        if specialTarget >= 0 && IsSpecialTargetCompatible(specialTarget) then
          hoverSlot = specialTarget
          ApplyPointerSlot(specialTarget)
        else
          hoverSlot = -1
          ApplyPointerSlot(-1)
        end
      else
        SetHighlightedSlot(GetSpecialTargetBySender(sender))
      end
      return
    end

    if message <= -50 && message >= -54 then
      if dragSourceSlot >= 0 then
        local dollTarget: int = GetSpecialTargetByDollMessage(message)
        if dollTarget >= 0 && IsSpecialTargetCompatible(dollTarget) then
          hoverSlot = dollTarget
          ApplyPointerSlot(dollTarget)
        else
          hoverSlot = -1
          ApplyPointerSlot(-1)
        end
      end
      return
    end

    if message == -42 then
      if dragSourceSlot >= 0 then
        local releaseTarget: int = GetSpecialTargetBySender(sender)
        if releaseTarget >= 0 && IsSpecialTargetCompatible(releaseTarget) then
          ApplyPointerSlot(releaseTarget)
          FinishLeftAction(releaseTarget)
        end
      end
      return
    end

    if message == -41 then
      if dragSourceSlot >= 0 then
        hoverSlot = -1
        ApplyPointerSlot(-1)
      else
        SetHighlightedSlot(-1)
      end
      return
    end

    if sender == "page_prev" && message == 0 then
      if page > 0 then ChangePage(-1) end
      return
    end
    if sender == "page_next" && message == 0 then
      if page < GetMaxPage() then ChangePage(1) end
      return
    end

    if message >= c_iDragEndMessageBase then
      local targetSlot: int = GetCurrentDropSlot(message, c_iDragEndMessageBase, sender)
      ApplyPointerSlot(targetSlot)
      FinishLeftAction(targetSlot)
      return
    end

    if message >= c_iReleaseMessageBase then
      local targetSlot: int = GetCurrentDropSlot(message, c_iReleaseMessageBase, sender)
      ApplyPointerSlot(targetSlot)
      FinishLeftAction(targetSlot)
      return
    end

    if message >= c_iHoverMessageBase then
      if dragSourceSlot >= 0 then
        if IsCursorPollingReady() then
          hoverSlot = UpdatePointerSlotFromCursorVariables()
        else
          hoverSlot = GetSlotTargetFromPointerMessage(message, c_iHoverMessageBase, sender)
        end
        ApplyPointerSlot(hoverSlot)
      else
        SetHighlightedSlot(GetSlotTargetFromPointerMessage(message, c_iHoverMessageBase, sender))
      end
      return
    end

    if message == 2 || message == 3 then
      local source: int = GetDragSourceBySender(sender)
      if HandleModifiedDrop(source) then return end
      StartDragAction(source, sender)
      return
    end

    if message == 4 then
      native.Trace("inv_overhaul_inventory system drag message 4 ignored")
      return
    end

    if message == 5 then
      native.Trace("inv_overhaul_inventory system drag message 5 ignored")
      return
    end

    if message == 6 then
      return
    end

    if message == 7 then
      if dragSourceSlot >= 0 then
        hoverSlot = -1
        lastPointerSlot = -1
      end
      SetHighlightedSlot(-1)
      return
    end

    if message == 8 then
      if dragSourceSlot >= 0 && IsCursorPollingReady() then
        local targetSlot: int = UpdatePointerSlotFromCursorVariables()
        if targetSlot < 0 then
          targetSlot = highlightedSlot
        end
        ApplyPointerSlot(targetSlot)
        FinishLeftAction(targetSlot)
      else
        FinishLeftAction(highlightedSlot)
      end
      return
    end

    if message != 0 && message != 1 then
      return
    end
    if data then
      return
    end
    HandleSlotMessage(message, sender)
  end
  function OnLButtonDown(x: int, y: int) -> void
    if HandlePageControlAt(x, y) then return end
    local equipmentTarget: int = FindEquipmentTargetAt(x, y)
    if equipmentTarget >= 0 && ResolveEquipmentTarget(equipmentTarget) then
      StartDragAction(equipmentTarget, "root")
      return
    end
  end


  function OnRButtonDown(x: int, y: int) -> void
    local equipmentTarget: int = FindEquipmentTargetAt(x, y)
    if equipmentTarget >= 0 then
      UnequipTarget(equipmentTarget, "root right click")
    end
  end

  function OnMouseMove(x: int, y: int) -> void
    if dragSourceSlot >= 0 then
      local slot: int
      if IsCursorPollingReady() then
        slot = UpdatePointerSlotFromCursorVariables()
      else
        slot = UpdatePointerSlot(x, y)
      end
      ApplyPointerSlot(slot)
    end
  end

  function OnMouseLeave() -> void
    if dragSourceSlot >= 0 then
      lastPointerSlot = -1
      SetHighlightedSlot(-1)
    end
  end

  function OnLButtonUp(x: int, y: int) -> void
    if dragSourceSlot >= 0 then
      local targetSlot: int
      if IsCursorPollingReady() then
        targetSlot = UpdatePointerSlotFromCursorVariables()
      else
        targetSlot = UpdatePointerSlot(x, y)
      end
      ApplyPointerSlot(targetSlot)
      FinishLeftAction(targetSlot)
    end
  end

  function CloseInventoryWindow() -> void
    if closingWindow then return end
    closingWindow = true
    native.SetNeedUpdate(false)
    native.SetVariable("inv_overhaul_inventory_drag_item", -1)
    native.SetVariable("inv_overhaul_inventory_page_hover", 0)
    native.SendMessage(-200, "panel_background")
    native.SendMessage(-200, "character_doll")
    native.DestroyWindow()
  end

  function OnChar(char: int) -> void
    if char >= 48 && char <= 57 then return end
    native.Trace("inv_overhaul_inventory OnChar close")
    if layoutSavePending then SaveLayoutVariables() end
    PersistCurrentBackpackSnapshot()
    CloseInventoryWindow()
  end

  function OnKeyDown(key: int) -> void
    native.Trace("inv_overhaul_inventory OnKeyDown " + key)
    if key == c_iVKShift then shiftHeld = true end
    if key == c_iVKControl then controlHeld = true end
    local quickslot: int = GetQuickslotByKey(key)
    if quickslot > 0 then
      AssignHoveredQuickslot(quickslot)
      return
    end
    if key == 27 || key == 73 || key == 105 then
      if layoutSavePending then SaveLayoutVariables() end
      PersistCurrentBackpackSnapshot()
      CloseInventoryWindow()
    end
  end

  function OnKeyUp(key: int) -> void
    if key == c_iVKShift then shiftHeld = false end
    if key == c_iVKControl then controlHeld = false end
  end
end
