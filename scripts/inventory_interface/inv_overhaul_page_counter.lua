maintask InvOverhaulPageCounter do
  local label: string
  local visible: bool

  function init() -> void
    label = "1 / 1"
    visible = false
    native.SetBackground("hidden")
    native.SetOwnerDraw(true)
    native.ProcessEvents()
  end

  function OnDraw() -> void
    if visible then native.Print("default", 7, 9, label) end
  end

  function OnUIMessage(message: int, sender: string, data: object) -> void
    if message == -92 then
      visible = true
      native.SetBackground("default")
      return
    end
    if message == -93 then
      visible = false
      native.SetBackground("hidden")
      return
    end
    local current: int = message / 100
    local total: int = message - current * 100
    if current < 1 then current = 1 end
    if total < 1 then total = 1 end
    label = current + " / " + total
  end

end
