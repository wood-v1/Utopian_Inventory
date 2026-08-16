maintask InvOverhaulUITextureCache do
  local const c_sScriptVersion: string = "2026.08.09-ui-companion-cache-2"
  local const c_iCategoryCount: int = 5
  local const c_iMaxCachedItems: int = 96
  local const c_fLoadStep: float = 0.04
  local const c_fGenerationPollDelay: float = 0.25

  local cachedItemIDs: object
  local cachedImages: object
  local scanCategory: int
  local scanIndex: int
  local scanGeneration: int
  local completedGeneration: int
  local cacheEpoch: int
  local loadedCount: int
  local cachedBranch: int
  local characterStage: int
  local updateDelay: float
  local scanActive: bool
  local scanOverflowed: bool

  function GetItemEpochVariable(itemID: int) -> string
    return "inv_overhaul_ui_cache_item_" + itemID
  end

  function GetBackground(branch: int) -> string
    if branch == 1 then return "ui/inv_overhaul_inventory_bg_haruspex.tex" end
    if branch == 2 then return "ui/inv_overhaul_inventory_bg_clara.tex" end
    return "ui/inv_overhaul_inventory_bg_bachelor.tex"
  end

  function GetDoll(branch: int) -> string
    if branch == 1 then return "ui/inv_overhaul_doll_haruspex.tex" end
    if branch == 2 then return "ui/inv_overhaul_doll_clara.tex" end
    return "ui/inv_overhaul_doll_bachelor.tex"
  end

  function HoldImage(sprite: string) -> void
    if sprite == "" then return end
    native.LoadImage(sprite)
    cachedImages->add(sprite)
  end

  function ResetCharacterCache(branch: int) -> void
    cachedBranch = branch
    characterStage = 0
    native.SetVariable("inv_overhaul_ui_cache_character_ready", 0)
    native.SetVariable("inv_overhaul_ui_cache_fully_warmed", 0)
    updateDelay = 0
    native.Trace("INV_OVERHAUL_UI_CACHE_LIFECYCLE character branch=" + branch +
      " epoch=" + cacheEpoch)
  end

  function BeginScan() -> void
    scanCategory = 0
    scanIndex = 0
    scanOverflowed = false
    native.GetVariable("inv_overhaul_inventory_content_generation", scanGeneration)
    scanActive = true
    native.SetVariable("inv_overhaul_ui_cache_fully_warmed", 0)
  end

  function init() -> void
    native.CreateIntVector(cachedItemIDs)
    native.CreateStringVector(cachedImages)
    scanCategory = 0
    scanIndex = 0
    scanGeneration = -1
    completedGeneration = -1
    loadedCount = 0
    cachedBranch = -999
    characterStage = 0
    updateDelay = 0.04
    scanActive = false
    scanOverflowed = false

    cacheEpoch = 0
    native.GetVariable("inv_overhaul_ui_cache_epoch", cacheEpoch)
    cacheEpoch = cacheEpoch + 1
    if cacheEpoch <= 0 || cacheEpoch > 1000000000 then cacheEpoch = 1 end
    native.SetVariable("inv_overhaul_ui_cache_epoch", cacheEpoch)
    native.SetVariable("inv_overhaul_ui_cache_loaded", 0)
    native.SetVariable("inv_overhaul_ui_cache_character_ready", 0)
    native.SetVariable("inv_overhaul_ui_cache_completed_generation", -1)
    native.SetVariable("inv_overhaul_ui_cache_fully_warmed", 0)

    local branch: int = 0
    native.GetVariable("branch", branch)
    ResetCharacterCache(branch)
    updateDelay = 0.25
    native.Trace("INV_OVERHAUL_UI_CACHE_VERSION " + c_sScriptVersion +
      " branch=" + branch + " epoch=" + cacheEpoch +
      " limit=" + c_iMaxCachedItems)
    native.SetNeedUpdate(true)
    native.ProcessEvents()
  end

  function IsCached(itemID: int) -> bool
    local count: int
    cachedItemIDs->size(count)
    for index = 0, count - 1 do
      local cachedID: int
      cachedItemIDs->get(cachedID, index)
      if cachedID == itemID then return true end
    end
    return false
  end

  function CacheItem(itemID: int) -> bool
    if itemID < 0 || IsCached(itemID) then return false end
    if loadedCount >= c_iMaxCachedItems then
      scanOverflowed = true
      return false
    end

    local sprite: string = ""
    native.GetInvItemSprite2(sprite, itemID)
    if sprite == "" then return false end
    HoldImage(sprite)
    cachedItemIDs->add(itemID)
    loadedCount = loadedCount + 1
    native.SetVariable("inv_overhaul_ui_cache_loaded", loadedCount)
    native.SetVariable(GetItemEpochVariable(itemID), cacheEpoch)
    return true
  end

  function CompleteScan() -> void
    local currentGeneration: int = 0
    native.GetVariable("inv_overhaul_inventory_content_generation", currentGeneration)
    if currentGeneration != scanGeneration then
      BeginScan()
      return
    end
    completedGeneration = currentGeneration
    scanActive = false
    native.SetVariable("inv_overhaul_ui_cache_completed_generation", completedGeneration)
    if scanOverflowed then
      native.SetVariable("inv_overhaul_ui_cache_fully_warmed", 0)
    else
      native.SetVariable("inv_overhaul_ui_cache_fully_warmed", 1)
    end
    native.Trace("INV_OVERHAUL_UI_CACHE_SCAN complete generation=" +
      completedGeneration + " loaded=" + loadedCount +
      " overflow=" + scanOverflowed)
    updateDelay = c_fGenerationPollDelay
  end

  function ProcessCharacterCache() -> bool
    local branch: int = 0
    native.GetVariable("branch", branch)
    if branch != cachedBranch then ResetCharacterCache(branch) end
    if characterStage == 0 then
      HoldImage(GetBackground(branch))
      characterStage = 1
      updateDelay = c_fLoadStep
      return true
    end
    if characterStage == 1 then
      HoldImage(GetDoll(branch))
      characterStage = 2
      native.SetVariable("inv_overhaul_ui_cache_character_ready", 1)
      BeginScan()
      updateDelay = c_fLoadStep
      return true
    end
    return false
  end

  function ProcessInventoryCache() -> void
    if !scanActive then
      local currentGeneration: int = 0
      native.GetVariable("inv_overhaul_inventory_content_generation", currentGeneration)
      if currentGeneration != completedGeneration then
        BeginScan()
      else
        updateDelay = c_fGenerationPollDelay
      end
      return
    end

    local player: object
    native.GetPlayerContainer(player)
    if !player then
      updateDelay = c_fGenerationPollDelay
      return
    end

    if scanCategory >= c_iCategoryCount then
      CompleteScan()
      return
    end

    local count: int
    player->GetItemCount(count, scanCategory)
    if scanIndex >= count then
      scanCategory = scanCategory + 1
      scanIndex = 0
      updateDelay = 0
      return
    end

    local item: object
    player->GetItem(item, scanIndex, scanCategory)
    scanIndex = scanIndex + 1
    if item then
      local itemID: int = -1
      item->GetItemID(itemID)
      if CacheItem(itemID) then
        updateDelay = c_fLoadStep
      else
        updateDelay = 0
      end
    else
      updateDelay = 0
    end
  end

  function OnUpdate(delta: float) -> void
    updateDelay = updateDelay - delta
    if updateDelay > 0 then return end
    if ProcessCharacterCache() then return end
    ProcessInventoryCache()
  end
end
