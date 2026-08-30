import "inv_overhaul_inventory_protocol"

module inv_overhaul_inventory_tooltip do
  local target: int
  local moneyItem: object
  local resumeDelay: float

  function InterfaceTooltipInitializeState() -> void
    target = -999
    resumeDelay = 0
  end

  function InitializeMoneyItem() -> void
    local item: object
    native.CreateInvItem(item)
    moneyItem = item
    moneyItem->SetItemName("Money")
  end

  function GetMoneyItemID() -> int
    local item: object = moneyItem
    local itemID: int
    item->GetItemID(itemID)
    return itemID
  end

  function GetTarget() -> int
    return target
  end

  function IsSuspended() -> bool
    return resumeDelay > 0
  end

  function Suspend(delay: float) -> void
    resumeDelay = delay
  end

  function InterfaceTooltipClear() -> void
    target = -1
    native.SendMessage(-1, "panel_background")
  end

  function AdvanceSuspension(delta: float) -> void
    if resumeDelay <= 0 then return end
    InterfaceTooltipClear()
    resumeDelay = resumeDelay - delta
    if resumeDelay <= 0 then resumeDelay = 0 end
  end

  function ShowText(newTarget: int, textID: int) -> void
    target = newTarget
    native.SetVariable("inv_overhaul_inventory_tooltip_item", -1)
    native.SetVariable("inv_overhaul_inventory_tooltip_text_id", textID)
    native.SetVariable("inv_overhaul_inventory_tooltip_type", 5)
  end

  function ShowMoneyForTarget(newTarget: int) -> void
    if target == newTarget then return end
    target = newTarget
    local item: object = moneyItem
    native.SendMessage(1, "panel_background", item)
  end

  function ShowMoney() -> void
    ShowMoneyForTarget(inv_overhaul_inventory_protocol.TargetMoney)
  end

  function ShowItem(newTarget: int, item: object) -> void
    if target == newTarget then return end
    if item then
      target = newTarget
      native.SendMessage(1, "panel_background", item)
    else
      InterfaceTooltipClear()
    end
  end

end
