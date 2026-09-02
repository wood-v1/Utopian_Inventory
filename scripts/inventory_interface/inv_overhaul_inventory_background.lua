import "inv_overhaul_inventory_geometry"
import "inv_overhaul_inventory_protocol"

maintask InventoryOverhaulBackground do
  local const c_iBranchDanko: int = 0
  local const c_iBranchBurah: int = 1
  local const c_iBranchKlara: int = 2
  local const c_iInventoryCapacity: int = 56
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
  local debugEnabled: int

  function LoadTrackedImage(path: string) -> void
    if path == "" || resourcesReleased then return end
    local loadedCount: int
    loadedImages->size(loadedCount)
    for index = 0, loadedCount - 1 do
      local loadedPath: string
      loadedImages->get(loadedPath, index)
      if loadedPath == path then return end
    end
    native.LoadImage(path)
    loadedImages->add(path)
  end

  function ReleaseTrackedImages() -> void
    if resourcesReleased then return end
    -- DestroyWindow is deferred until the current UI event has finished.  Stop
    -- owner drawing before releasing the dynamically loaded images, otherwise
    -- the renderer can execute one last OnDraw with already invalid handles.
    resourcesReleased = true
    gridEnabled = false
    helpHoverActive = false
    native.SetOwnerDraw(false)
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
    debugEnabled = 0
    native.GetVariable("inv_overhaul_debug_enabled", debugEnabled)
    if debugEnabled == 1 then native.Trace("INV_OVERHAUL_PERF_STEP background_init_begin") end
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
    if debugEnabled == 1 then native.Trace("INV_OVERHAUL_PERF_STEP background_image_begin") end
    LoadTrackedImage(image)
    if debugEnabled == 1 then native.Trace("INV_OVERHAUL_PERF_STEP background_image_end") end
    LoadTrackedImage(emptyImage)
    LoadTrackedImage(occupiedImage)
    LoadTrackedImage(targetImage)
    LoadTrackedImage(quickslotHelpImage)
    if characterBranch == c_iBranchKlara then
      native.Trace("INV_OVERHAUL_CLARA_RENDER_PROFILE sprite=large doll=enabled background=enabled empty_slots=enabled profiler=steps")
    end
    native.SetOwnerDraw(true)
    native.ProcessEvents()
    native.SendMessageToParent(inv_overhaul_inventory_protocol.GridRendererReady)
    if debugEnabled == 1 then native.Trace("INV_OVERHAUL_PERF_STEP background_init_end") end
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

  function SendPointer(base: int, x: int, y: int) -> void
    local globalX: int = GetPanelLeft() + x
    local globalY: int = GetPanelTop() + y
    native.SendMessageToParent(
      inv_overhaul_inventory_protocol.EncodePanelPointer(base, globalX, globalY))
  end

  function DrawSlot(slot: int) -> void
    local columns: int = inv_overhaul_inventory_geometry.InterfaceGeometryGetGridColumns(rootWidth)
    local column: int = slot - (slot / columns) * columns
    local row: int = slot / columns
    local size: int = inv_overhaul_inventory_geometry.GetSlotSize(rootWidth)
    local x: int = inv_overhaul_inventory_geometry.InterfaceGeometryGetGridStartX(rootWidth) -
      GetPanelLeft() + column * inv_overhaul_inventory_geometry.InterfaceGeometryGetGridStep(rootWidth)
    local y: int = inv_overhaul_inventory_geometry.InterfaceGeometryGetGridStartY(rootWidth) -
      GetPanelTop() + row * inv_overhaul_inventory_geometry.InterfaceGeometryGetGridStep(rootWidth)
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
    if resourcesReleased then return end
    if debugEnabled == 1 && !firstDrawProfiled then native.Trace("INV_OVERHAUL_PERF_STEP background_first_draw_begin") end
    native.StretchBlit(image, 0, 0, panelWidth, panelHeight)
    if gridEnabled && rootWidth > 0 then
      for slot = 0, inv_overhaul_inventory_geometry.InterfaceGeometryGetVisibleSlots(rootWidth) - 1 do
        DrawSlot(slot)
      end
    end
    native.StretchBlit(quickslotHelpImage, panelWidth - 74, 71, 28, 28)
    if !firstDrawProfiled then
      firstDrawProfiled = true
      if debugEnabled == 1 then native.Trace("INV_OVERHAUL_PERF_STEP background_first_draw_end") end
    end
  end

  function OnMouseMove(x: int, y: int) -> void
    local helpX: int = panelWidth - 74
    if x >= helpX && x < helpX + 28 && y >= 71 && y < 99 then
      if !helpHoverActive then
        helpHoverActive = true
        native.SendMessageToParent(inv_overhaul_inventory_protocol.QuickslotHelpHover)
      end
      native.SetVariable("inv_overhaul_inventory_tooltip_item", -1)
      native.SetVariable("inv_overhaul_inventory_tooltip_text_id", 1407)
      native.SetVariable("inv_overhaul_inventory_tooltip_type", 5)
      tooltipActive = true
      return
    end
    helpHoverActive = false
    SendPointer(inv_overhaul_inventory_protocol.PointerMoveBase, x, y)
  end

  function OnMouseLeave() -> void
    helpHoverActive = false
    native.SetTooltip(c_iTooltipNone, "")
    native.SetVariable("inv_overhaul_inventory_tooltip_item", -1)
    native.SetVariable("inv_overhaul_inventory_tooltip_type", c_iTooltipNone)
    tooltipActive = false
    native.SendMessageToParent(inv_overhaul_inventory_protocol.PointerLeaveBase)
  end

  function OnLButtonDown(x: int, y: int) -> void
    SendPointer(inv_overhaul_inventory_protocol.PointerDownBase, x, y)
  end

  function OnLButtonUp(x: int, y: int) -> void
    SendPointer(inv_overhaul_inventory_protocol.PointerUpBase, x, y)
  end

  function OnRButtonDown(x: int, y: int) -> void
    SendPointer(inv_overhaul_inventory_protocol.PointerRightBase, x, y)
  end

  function OnDragBegin(x: int, y: int) -> void
    SendPointer(inv_overhaul_inventory_protocol.PointerDragBeginBase, x, y)
  end

  function OnDragEnd(x: int, y: int, accepted: bool) -> void
    SendPointer(inv_overhaul_inventory_protocol.PointerDragEndBase, x, y)
  end

  function HandleGridRendererMessage(message: int, data: object) -> bool
    if message < inv_overhaul_inventory_protocol.GridRendererMessageBase then return false end
    local slot: int = inv_overhaul_inventory_protocol.DecodeGridRendererSlot(message)
    if slot < 0 || slot >= c_iInventoryCapacity then return true end
    local operation: int = inv_overhaul_inventory_protocol.DecodeGridRendererOperation(message)
    local value: int = inv_overhaul_inventory_protocol.DecodeGridRendererValue(message)

    if operation == inv_overhaul_inventory_protocol.GridRendererHighlight then
      highlightedSlots->set(slot, value)
      return true
    end

    if operation == inv_overhaul_inventory_protocol.GridRendererHidden then
      hiddenSlots->set(slot, 1)
      highlightedSlots->set(slot, 0)
      return true
    end

    hiddenSlots->set(slot, 0)
    if operation == inv_overhaul_inventory_protocol.GridRendererEmpty then
      itemIDs->set(slot, -1)
      amounts->set(slot, 1)
      quickslots->set(slot, 0)
      return true
    end

    if operation == inv_overhaul_inventory_protocol.GridRendererItem && data then
      local itemID: int
      data->GetItemID(itemID)
      local loadedItemID: int
      itemIDs->get(loadedItemID, slot)
      if loadedItemID != itemID then
        local sprite: string = ""
        native.GetInvItemSprite2(sprite, itemID)
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
