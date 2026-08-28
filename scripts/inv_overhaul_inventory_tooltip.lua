import "inv_overhaul_inventory_protocol"

module inv_overhaul_inventory_tooltip do
  local target: int
  local moneyItem: object
  local resumeDelay: float

  function InventoryTooltipInitializeState() -> void
    target = -999
    resumeDelay = 0
  end

  function InventoryTooltipInitializeMoneyItem() -> void
    local item: object
    native.CreateInvItem(item)
    moneyItem = item
    moneyItem->SetItemName("Money")
  end

  function InventoryTooltipGetMoneyItemID() -> int
    local item: object = moneyItem
    local itemID: int
    item->GetItemID(itemID)
    return itemID
  end

  function InventoryTooltipGetTarget() -> int
    return target
  end

  function InventoryTooltipIsSuspended() -> bool
    return resumeDelay > 0
  end

  function InventoryTooltipSuspend(delay: float) -> void
    resumeDelay = delay
  end

  function InventoryTooltipClear() -> void
    target = -1
    native.SendMessage(-1, "panel_background")
  end

  function InventoryTooltipAdvanceSuspension(delta: float) -> void
    if resumeDelay <= 0 then return end
    InventoryTooltipClear()
    resumeDelay = resumeDelay - delta
    if resumeDelay <= 0 then resumeDelay = 0 end
  end

  function InventoryTooltipShowText(newTarget: int, textID: int) -> void
    target = newTarget
    native.SetVariable("inv_overhaul_inventory_tooltip_item", -1)
    native.SetVariable("inv_overhaul_inventory_tooltip_text_id", textID)
    native.SetVariable("inv_overhaul_inventory_tooltip_type", 5)
  end

  function InventoryTooltipShowMoneyForTarget(newTarget: int) -> void
    if target == newTarget then return end
    target = newTarget
    local item: object = moneyItem
    native.SendMessage(1, "panel_background", item)
  end

  function InventoryTooltipShowMoney() -> void
    InventoryTooltipShowMoneyForTarget(inv_overhaul_inventory_protocol.TargetMoney)
  end

  function InventoryTooltipShowItem(newTarget: int, item: object) -> void
    if target == newTarget then return end
    if item then
      target = newTarget
      native.SendMessage(1, "panel_background", item)
    else
      InventoryTooltipClear()
    end
  end

end
