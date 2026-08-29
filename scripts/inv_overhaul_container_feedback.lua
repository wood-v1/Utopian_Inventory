import "inv_overhaul_container_session"

module inv_overhaul_container_feedback do
  local const HelpMessage: int = 200
  local const InventoryFullTextID: int = 1400
  local const ContainerFullTextID: int = 1402
  local const CorpseFullTextID: int = 1403

  local messageCooldown: float

  function ContainerFeedbackInitializeState() -> void
    messageCooldown = 0
  end

  function ContainerFeedbackShowInventoryFull() -> void
    if messageCooldown > 0 then return end
    local text: object
    native.CreateIntVector(text)
    text->add(InventoryFullTextID)
    native.SendWorldWndMessage(HelpMessage, text)
    messageCooldown = 1.0
  end

  function ContainerFeedbackShowContainerFull() -> void
    if messageCooldown > 0 then return end
    local text: object
    native.CreateIntVector(text)
    if inv_overhaul_container_session.ContainerSessionIsCorpse() then
      text->add(CorpseFullTextID)
    else
      text->add(ContainerFullTextID)
    end
    native.SendWorldWndMessage(HelpMessage, text)
    messageCooldown = 1.0
  end

  function ContainerFeedbackAdvance(delta: float) -> void
    if messageCooldown <= 0 then return end
    messageCooldown = messageCooldown - delta
    if messageCooldown < 0 then messageCooldown = 0 end
  end
end
