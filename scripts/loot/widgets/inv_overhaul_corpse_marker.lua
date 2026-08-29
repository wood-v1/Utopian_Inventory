maintask InvOverhaulCorpseMarker do
  local active: bool
  local retryDelay: float

  function init() -> void
    active = true
    retryDelay = 0
    native.SetNeedUpdate(true)
    native.ProcessEvents()
    native.SendMessageToParent(-100)
  end

  function OnUpdate(delta: float) -> void
    if !active then return end
    retryDelay = retryDelay - delta
    if retryDelay > 0 then return end
    retryDelay = 0.05
    native.SendMessageToParent(-100)
  end

  function OnUIMessage(message: int, sender: string, data: object) -> void
    if message == -120 then
      active = false
      native.SetNeedUpdate(false)
      native.Trace("inv_overhaul_corpse_marker acknowledged")
    end
  end
end
