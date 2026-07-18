maintask UtopianLootDoll do
  function init() -> void
    native.SetBackground("container")
    native.ProcessEvents()
  end

  function OnUIMessage(message: int, sender: string, data: object) -> void
    if message == -100 then
      native.SetBackground("corpse")
      return
    end
    if message == -101 then native.SetBackground("container") end
  end
end
