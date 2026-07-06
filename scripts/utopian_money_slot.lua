maintask UtopianMoneySlot do
  local moneyAmount: int
  local moneySprite: string

  function init() -> void
    moneyAmount = 0
    moneySprite = ""
    InitMoneySprite()
    native.SetBackground("default")
    native.SetOwnerDraw(true)
    native.ProcessEvents()
  end

  function InitMoneySprite() -> void
    local moneyID: int
    native.GetInvItemByName(moneyID, "Money")
    if moneyID >= 0 then
      native.GetInvItemSprite(moneySprite, moneyID)
      native.LoadImage(moneySprite)
      native.Trace("utopian_money_slot sprite " + moneySprite)
    end
  end

  function OnDraw() -> void
    if moneySprite != "" then
      native.Blit(moneySprite, 1, 1)
    end
    native.Print("default", 2, 35, moneyAmount)
  end

  function OnUIMessage(message: int, sender: string, data: object) -> void
    moneyAmount = message
  end
end