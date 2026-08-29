maintask InvOverhaulQuickslotHelp do
  local const c_iTooltipMapObject: int = 5
  local const c_iQuickslotHelpTextID: int = 1407
  local tooltip: string

  function PublishTooltip() -> void
    native.SetVariable("inv_overhaul_inventory_tooltip_item", -1)
    native.SetVariable(
      "inv_overhaul_inventory_tooltip_text_id",
      c_iQuickslotHelpTextID)
    native.SetVariable(
      "inv_overhaul_inventory_tooltip_type",
      c_iTooltipMapObject)
    native.SetTooltip(c_iTooltipMapObject, tooltip)
  end

  function init() -> void
    native.SetBackground("default")
    native.GetStringByID(tooltip, c_iQuickslotHelpTextID)
    native.SetTooltip(c_iTooltipMapObject, tooltip)
    native.ProcessEvents()
  end

  function OnMouseEnter() -> void
    PublishTooltip()
  end

  function OnMouseMove(x: int, y: int) -> void
    PublishTooltip()
  end

  function OnMouseLeave() -> void
  end
end
