maintask UtopianMoneySlot do
  local moneyAmount: int
  local moneySprite: string
  local slotWidth: int
  local slotHeight: int
  local highResolutionSprite: bool

  function init() -> void
    moneyAmount = 0
    moneySprite = ""
    highResolutionSprite = false
    native.GetWindowSize(slotWidth, slotHeight)
    if slotWidth <= 0 then slotWidth = 52 end
    if slotHeight <= 0 then slotHeight = 52 end
    InitMoneySprite()
    native.SetBackground("default")
    native.SetOwnerDraw(true)
    native.ProcessEvents()
  end

  function InitMoneySprite() -> void
    local moneyID: int
    native.GetInvItemByName(moneyID, "Money")
    if moneyID >= 0 then
      if highResolutionSprite then
        native.GetInvItemSprite2(moneySprite, moneyID)
      else
        native.GetInvItemSprite(moneySprite, moneyID)
      end
      native.LoadImage(moneySprite)
      native.Trace("utopian_money_slot sprite " + moneySprite)
    end
  end

  function OnDraw() -> void
    if moneySprite != "" then
      if highResolutionSprite then
        native.StretchBlit(moneySprite, 2, 2, slotWidth - 4, slotHeight - 4)
      else
      if slotWidth > 52 then
        native.StretchBlit(moneySprite, 1, 1, (slotWidth - 2) * 64 / 52, (slotHeight - 2) * 64 / 52)
      else
        native.Blit(moneySprite, 1, 1)
      end
      end
    end
    native.Print("default", 2, slotHeight - 17, moneyAmount)
  end

  function OnUIMessage(message: int, sender: string, data: object) -> void
    if message == -26 then
      slotWidth = 82
      slotHeight = 82
      highResolutionSprite = true
      InitMoneySprite()
      return
    end
    if message == -27 then
      slotWidth = 52
      slotHeight = 52
      highResolutionSprite = false
      InitMoneySprite()
      return
    end
    moneyAmount = message
  end
end
