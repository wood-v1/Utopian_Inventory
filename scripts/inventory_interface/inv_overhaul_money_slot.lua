maintask InvOverhaulMoneySlot do
  local const c_iReleaseResources: int = -200
  local moneyAmount: int
  local moneySprite: string
  local slotWidth: int
  local slotHeight: int
  local highResolutionSprite: bool
  local debugEnabled: int

  function init() -> void
    debugEnabled = 0
    native.GetVariable("inv_overhaul_debug_enabled", debugEnabled)
    if debugEnabled == 1 then native.Trace("INV_OVERHAUL_PERF_STEP money_init_begin") end
    moneyAmount = 0
    moneySprite = ""
    native.GetWindowSize(slotWidth, slotHeight)
    if slotWidth <= 0 then slotWidth = 52 end
    if slotHeight <= 0 then slotHeight = 52 end
    highResolutionSprite = slotWidth > 52
    if debugEnabled == 1 then native.Trace("INV_OVERHAUL_PERF_STEP money_image_begin") end
    InitSprite()
    if debugEnabled == 1 then native.Trace("INV_OVERHAUL_PERF_STEP money_image_end") end
    native.SetBackground("default")
    native.SetOwnerDraw(true)
    native.ProcessEvents()
    if debugEnabled == 1 then native.Trace("INV_OVERHAUL_PERF_STEP money_init_end") end
  end

  function InitSprite() -> void
    if moneySprite != "" then native.ReleaseImage(moneySprite) end
    moneySprite = ""
    local moneyID: int
    native.GetInvItemByName(moneyID, "Money")
    if moneyID >= 0 then
      if highResolutionSprite then
        native.GetInvItemSprite2(moneySprite, moneyID)
      else
        native.GetInvItemSprite(moneySprite, moneyID)
      end
      native.LoadImage(moneySprite)
      native.Trace("inv_overhaul_money_slot sprite " + moneySprite)
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
    if message == c_iReleaseResources then
      native.SetOwnerDraw(false)
      if moneySprite != "" then native.ReleaseImage(moneySprite) end
      moneySprite = ""
      return
    end
    if message == -26 then
      if slotWidth != 82 || slotHeight != 82 || !highResolutionSprite then
        slotWidth = 82
        slotHeight = 82
        highResolutionSprite = true
        InitSprite()
      end
      return
    end
    if message == -27 then
      if slotWidth != 52 || slotHeight != 52 || highResolutionSprite then
        slotWidth = 52
        slotHeight = 52
        highResolutionSprite = false
        InitSprite()
      end
      return
    end
    moneyAmount = message
  end
end
