maintask InventoryOverhaulBackground do
  local const c_iBranchDanko: int = 0
  local const c_iBranchBurah: int = 1
  local const c_iBranchKlara: int = 2
  local const c_iInventoryCapacity: int = 56
  local const c_iPointerMoveBase: int = 1000000
  local const c_iPointerDownBase: int = 4000000
  local const c_iPointerUpBase: int = 7000000
  local const c_iPointerRightBase: int = 10000000
  local const c_iPointerDragBeginBase: int = 13000000
  local const c_iPointerDragEndBase: int = 16000000
  local const c_iPointerLeaveBase: int = 19000000
  local const c_iPointerStride: int = 2000
  local const c_iGridRendererMessageBase: int = 30000000
  local const c_iGridRendererSlotStride: int = 100000
  local const c_iGridRendererOperationStride: int = 20000
  local const c_iGridRendererItem: int = 1
  local const c_iGridRendererEmpty: int = 2
  local const c_iGridRendererHidden: int = 3
  local const c_iGridRendererHighlight: int = 4
  local const c_iGridRendererReady: int = 29900000
  local const c_iQuickslotHelpHover: int = 29800001
  local const c_iTooltipNone: int = -1
  local const c_iTooltipInvObject: int = 1
  local const c_iReleaseResources: int = -200

  local image: string
  local characterBranch: int
  local emptyImage: string
  local occupiedImage: string
  local targetImage: string
  local quickslotHelpImage: string
  local panelWidth: int
  local panelHeight: int
  local rootWidth: int
  local rootHeight: int
  local tooltipActive: bool
  local itemIDs: object
  local amounts: object
  local quickslots: object
  local hiddenSlots: object
  local highlightedSlots: object
  local sprites: object
  local loadedImages: object
  local resourcesReleased: bool
  local firstDrawProfiled: bool
  local gridEnabled: bool
  local helpHoverActive: bool

  function LoadTrackedImage(path: string) -> void
    if path == "" || resourcesReleased then return end
    native.LoadImage(path)
    loadedImages->add(path)
  end

  function ReleaseTrackedImages() -> void
    if resourcesReleased then return end
    resourcesReleased = true
    local count: int
    loadedImages->size(count)
    local index: int = count - 1
    while index >= 0 do
      local path: string
      loadedImages->get(path, index)
      if path != "" then native.ReleaseImage(path) end
      index = index - 1
    end
    loadedImages->clear()
    native.Trace("INV_OVERHAUL_RENDER_RESOURCES_RELEASED count=" + count + " branch=" + characterBranch)
  end

  function init() -> void
    native.Trace("INV_OVERHAUL_PERF_STEP background_init_begin")
    local branch: int = c_iBranchDanko
    native.GetVariable("branch", branch)
    characterBranch = branch

    if branch == c_iBranchBurah then
      image = "ui/inv_overhaul_inventory_bg_haruspex.tex"
    else
      if branch == c_iBranchKlara then
        image = "ui/inv_overhaul_inventory_bg_clara.tex"
      else
        image = "ui/inv_overhaul_inventory_bg_bachelor.tex"
      end
    end

    emptyImage = "ui/inv_overhaul_slot_empty_runtime.tga"
    occupiedImage = "ui/inv_overhaul_slot_occupied.tex"
    targetImage = "ui/inv_overhaul_slot_target.tex"
    quickslotHelpImage = "ui/inv_overhaul_quickslot_help.tex"
    native.CreateIntVector(itemIDs)
    native.CreateIntVector(amounts)
    native.CreateIntVector(quickslots)
    native.CreateIntVector(hiddenSlots)
    native.CreateIntVector(highlightedSlots)
    native.CreateStringVector(sprites)
    native.CreateStringVector(loadedImages)
    resourcesReleased = false
    gridEnabled = true
    helpHoverActive = false
    for slot = 0, c_iInventoryCapacity - 1 do
      itemIDs->add(-1)
      amounts->add(1)
      quickslots->add(0)
      hiddenSlots->add(0)
      highlightedSlots->add(0)
      sprites->add("")
    end

    native.GetWindowSize(panelWidth, panelHeight)
    rootWidth = 0
    rootHeight = 0
    tooltipActive = false
    firstDrawProfiled = false
    native.SetVariable("inv_overhaul_inventory_tooltip_item", -1)
    native.SetVariable("inv_overhaul_inventory_tooltip_type", c_iTooltipNone)
    native.Trace("INV_OVERHAUL_PERF_STEP background_image_begin")
    LoadTrackedImage(image)
    native.Trace("INV_OVERHAUL_PERF_STEP background_image_end")
    LoadTrackedImage(emptyImage)
    LoadTrackedImage(occupiedImage)
    LoadTrackedImage(targetImage)
    LoadTrackedImage(quickslotHelpImage)
    if characterBranch == c_iBranchKlara then
      native.Trace("INV_OVERHAUL_CLARA_RENDER_PROFILE sprite=large doll=enabled background=enabled empty_slots=enabled profiler=steps")
    end
    native.SetOwnerDraw(true)
    native.ProcessEvents()
    native.SendMessageToParent(c_iGridRendererReady)
    native.Trace("INV_OVERHAUL_PERF_STEP background_init_end")
  end

  function GetPanelLeft() -> int
    if rootWidth >= 1900 then return 360 end
    if panelWidth >= 1100 then return 40 end
    if panelWidth >= 900 then return 32 end
    return 25
  end

  function GetPanelTop() -> int
    if rootWidth >= 1900 then return 140 end
    if panelWidth >= 1100 then return 80 end
    if panelWidth >= 900 then return 64 end
    return 50
  end

  function GetGridStartX() -> int
    if rootWidth >= 1900 then return 825 end
    if rootWidth >= 1200 then return 600 end
    if rootWidth >= 1000 then return 468 end
    return 359
  end

  function GetGridStartY() -> int
    if rootWidth >= 1900 then return 245 end
    if rootWidth >= 1200 then return 182 end
    if rootWidth >= 1000 then return 266 end
    return 225
  end

  function GetGridStep() -> int
    if rootWidth >= 1900 then return 96 end
    if rootWidth >= 1200 then return 64 end
    if rootWidth >= 1000 then return 61 end
    return 58
  end

  function GetGridColumns() -> int
    if rootWidth >= 1900 then return 7 end
    if rootWidth >= 1200 then return 8 end
    if rootWidth >= 1000 then return 7 end
    return 6
  end

  function GetVisibleSlots() -> int
    if rootWidth >= 1900 then return 35 end
    if rootWidth >= 1200 then return 56 end
    if rootWidth >= 1000 then return 35 end
    return 24
  end

  function GetSlotSize() -> int
    if rootWidth >= 1900 then return 82 end
    return 52
  end

  function SendPointer(base: int, x: int, y: int) -> void
    local globalX: int = GetPanelLeft() + x
    local globalY: int = GetPanelTop() + y
    native.SendMessageToParent(base + globalX * c_iPointerStride + globalY)
  end

  function DrawSlot(slot: int) -> void
    local columns: int = GetGridColumns()
    local column: int = slot - (slot / columns) * columns
    local row: int = slot / columns
    local size: int = GetSlotSize()
    local x: int = GetGridStartX() - GetPanelLeft() + column * GetGridStep()
    local y: int = GetGridStartY() - GetPanelTop() + row * GetGridStep()
    local hidden: int
    hiddenSlots->get(hidden, slot)
    if hidden == 1 then return end

    local itemID: int
    itemIDs->get(itemID, slot)
    if itemID >= 0 then
      native.StretchBlit(occupiedImage, x, y, size, size)
      local sprite: string
      sprites->get(sprite, slot)
      if sprite != "" then native.StretchBlit(sprite, x + 2, y + 2, size - 4, size - 4) end

      local amount: int
      amounts->get(amount, slot)
      if amount > 1 then native.Print("default", x + 2, y + size - 17, amount) end

      local quickslot: int
      quickslots->get(quickslot, slot)
      if quickslot > 0 then
        local displayNumber: int = quickslot
        if displayNumber == 10 then displayNumber = 0 end
        native.Print("quickslot", x + size - 17, y + 3, displayNumber)
      end
    else
      native.StretchBlit(emptyImage, x, y, size, size)
    end

    local highlighted: int
    highlightedSlots->get(highlighted, slot)
    if highlighted == 1 then native.StretchBlit(targetImage, x, y, size, size) end
  end

  function OnDraw() -> void
    if !firstDrawProfiled then native.Trace("INV_OVERHAUL_PERF_STEP background_first_draw_begin") end
    native.StretchBlit(image, 0, 0, panelWidth, panelHeight)
    if gridEnabled && rootWidth > 0 then
      for slot = 0, GetVisibleSlots() - 1 do DrawSlot(slot) end
    end
    native.StretchBlit(quickslotHelpImage, panelWidth - 74, 71, 28, 28)
    if !firstDrawProfiled then
      firstDrawProfiled = true
      native.Trace("INV_OVERHAUL_PERF_STEP background_first_draw_end")
    end
  end

  function OnMouseMove(x: int, y: int) -> void
    local helpX: int = panelWidth - 74
    if x >= helpX && x < helpX + 28 && y >= 71 && y < 99 then
      if !helpHoverActive then
        helpHoverActive = true
        native.SendMessageToParent(c_iQuickslotHelpHover)
      end
      native.SetVariable("inv_overhaul_inventory_tooltip_item", -1)
      native.SetVariable("inv_overhaul_inventory_tooltip_text_id", 1407)
      native.SetVariable("inv_overhaul_inventory_tooltip_type", 5)
      tooltipActive = true
      return
    end
    helpHoverActive = false
    SendPointer(c_iPointerMoveBase, x, y)
  end

  function OnMouseLeave() -> void
    helpHoverActive = false
    native.SetTooltip(c_iTooltipNone, "")
    native.SetVariable("inv_overhaul_inventory_tooltip_item", -1)
    native.SetVariable("inv_overhaul_inventory_tooltip_type", c_iTooltipNone)
    tooltipActive = false
    native.SendMessageToParent(c_iPointerLeaveBase)
  end

  function OnLButtonDown(x: int, y: int) -> void
    SendPointer(c_iPointerDownBase, x, y)
  end

  function OnLButtonUp(x: int, y: int) -> void
    SendPointer(c_iPointerUpBase, x, y)
  end

  function OnRButtonDown(x: int, y: int) -> void
    SendPointer(c_iPointerRightBase, x, y)
  end

  function OnDragBegin(x: int, y: int) -> void
    SendPointer(c_iPointerDragBeginBase, x, y)
  end

  function OnDragEnd(x: int, y: int, accepted: bool) -> void
    SendPointer(c_iPointerDragEndBase, x, y)
  end

  function HandleGridRendererMessage(message: int, data: object) -> bool
    if message < c_iGridRendererMessageBase then return false end
    local encoded: int = message - c_iGridRendererMessageBase
    local slot: int = encoded / c_iGridRendererSlotStride
    if slot < 0 || slot >= c_iInventoryCapacity then return true end
    encoded = encoded - slot * c_iGridRendererSlotStride
    local operation: int = encoded / c_iGridRendererOperationStride
    local value: int = encoded - operation * c_iGridRendererOperationStride

    if operation == c_iGridRendererHighlight then
      highlightedSlots->set(slot, value)
      return true
    end

    if operation == c_iGridRendererHidden then
      hiddenSlots->set(slot, 1)
      highlightedSlots->set(slot, 0)
      return true
    end

    hiddenSlots->set(slot, 0)
    if operation == c_iGridRendererEmpty then
      itemIDs->set(slot, -1)
      amounts->set(slot, 1)
      quickslots->set(slot, 0)
      return true
    end

    if operation == c_iGridRendererItem && data then
      local itemID: int
      data->GetItemID(itemID)
      local loadedItemID: int
      itemIDs->get(loadedItemID, slot)
      if loadedItemID != itemID then
        local sprite: string = ""
        if rootWidth >= 1900 then
          native.GetInvItemSprite2(sprite, itemID)
        else
          native.GetInvItemSprite(sprite, itemID)
        end
        if sprite != "" then LoadTrackedImage(sprite) end
        sprites->set(slot, sprite)
        itemIDs->set(slot, itemID)
      end
      amounts->set(slot, value / 11)
      quickslots->set(slot, value - (value / 11) * 11)
      return true
    end
    return true
  end

  function OnUIMessage(message: int, sender: string, data: object) -> void
    if message == c_iReleaseResources then
      ReleaseTrackedImages()
      return
    end
    if message == -201 then
      gridEnabled = false
      return
    end
    if HandleGridRendererMessage(message, data) then return end
    if message >= 5000 then
      rootHeight = message - 5000
      return
    end
    if message >= 800 then
      rootWidth = message
      return
    end
    if message == c_iTooltipInvObject && data then
      local tooltipItemID: int
      data->GetItemID(tooltipItemID)
      tooltipActive = true
      native.SetVariable("inv_overhaul_inventory_tooltip_item", tooltipItemID)
      native.SetVariable("inv_overhaul_inventory_tooltip_type", c_iTooltipInvObject)
      native.SetTooltip(c_iTooltipInvObject, "", data)
    else
      tooltipActive = false
      native.SetVariable("inv_overhaul_inventory_tooltip_item", -1)
      native.SetVariable("inv_overhaul_inventory_tooltip_type", c_iTooltipNone)
      native.SetTooltip(c_iTooltipNone, "")
    end
  end
end
