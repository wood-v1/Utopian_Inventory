import "inv_overhaul_container_presenter"

module inv_overhaul_container_session do
  local const BranchBurah: int = 1

  local isCorpse: bool
  local showOrgans: bool
  local corpseVisualPending: bool
  local organVisibilityRefresh: float
  local deferredContainerRefresh: float

  function LootSessionInitializeState() -> void
    isCorpse = false
    showOrgans = false
    corpseVisualPending = false
    organVisibilityRefresh = 0.5
    deferredContainerRefresh = 0
    inv_overhaul_container_presenter.SetCorpseMode(false, false)
  end

  function LootSessionIsCorpse() -> bool
    local value: bool = isCorpse
    return value
  end

  function LootSessionShowsOrgans() -> bool
    local value: bool = showOrgans
    return value
  end

  function ActivateCorpseMode() -> void
    isCorpse = true
    corpseVisualPending = true
    organVisibilityRefresh = 0.5
    local branch: int = 0
    native.GetVariable("branch", branch)
    showOrgans = branch == BranchBurah
    local organs: bool = showOrgans
    inv_overhaul_container_presenter.SetCorpseMode(true, organs)
    native.Trace("inv_overhaul_container corpse marker branch=" + branch +
      " organs=" + organs)
    native.SendMessage(-100, "loot_doll")
    inv_overhaul_container_presenter.UpdateContainerSlots()
    inv_overhaul_container_presenter.UpdateOrganSlots()
    deferredContainerRefresh = 0.05
  end

  function DetectContainerKind() -> void
    isCorpse = false
    showOrgans = false
    inv_overhaul_container_presenter.SetCorpseMode(false, false)
    local external: object
    native.GetContainer(external)
    -- Generic Container actors do not expose Actor properties. Only the
    -- engine corpse flag, corpse_marker, and contained Organ items are safe.
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
      native.Trace("inv_overhaul_container external item count=" + count)
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

  function LootSessionAdvance(delta: float) -> void
    if organVisibilityRefresh > 0 then
      organVisibilityRefresh = organVisibilityRefresh - delta
      if organVisibilityRefresh <= 0 then
        inv_overhaul_container_presenter.UpdateOrganSlots()
      end
    end
    if corpseVisualPending then
      native.SendMessage(-100, "loot_doll")
      corpseVisualPending = false
    end
    if deferredContainerRefresh > 0 then
      deferredContainerRefresh = deferredContainerRefresh - delta
      if deferredContainerRefresh <= 0 then
        inv_overhaul_container_presenter.UpdateContainerSlots()
      end
    end
  end

  function CloseWindow() -> void
    native.SetCursor("default")
    native.DestroyWindow()
  end
end
