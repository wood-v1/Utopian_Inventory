module inv_overhaul_quickslot_consumables do
  function QuickslotConsumablesGetUseEffect(itemID: int) -> string
    if itemID == 0 then return "item_alpha_pills.bin" end
    if itemID == 1 then return "item_beta_pills.bin" end
    if itemID == 2 then return "item_gamma_pills.bin" end
    if itemID == 3 then return "item_delta_pills.bin" end
    if itemID == 4 then return "item_black_vaccine.bin" end
    if itemID == 5 then return "item_blue_vaccine.bin" end
    if itemID == 6 then return "item_white_vaccine.bin" end
    if itemID == 7 then return "item_tvirin.bin" end
    if itemID == 8 then return "item_lemon.bin" end
    if itemID == 9 then return "item_powder.bin" end
    if itemID == 10 then return "item_burah_serum.bin" end
    if itemID == 11 then return "item_neomicin.bin" end
    if itemID == 12 then return "item_monomicin.bin" end
    if itemID == 13 then return "item_feromicin.bin" end
    if itemID == 14 then return "item_meradorm.bin" end
    if itemID == 15 then return "item_novocaine.bin" end
    if itemID == 16 then return "item_morfin.bin" end
    if itemID == 17 then return "item_etorfin.bin" end
    if itemID == 18 then return "item_bottle_water.bin" end
    if itemID == 19 then return "item_funduk.bin" end
    if itemID == 20 then return "item_peanut.bin" end
    if itemID == 21 then return "item_walnut.bin" end
    if itemID == 22 then return "item_rusk.bin" end
    if itemID == 23 then return "item_dried_fish.bin" end
    if itemID == 24 then return "item_egg.bin" end
    if itemID == 25 then return "item_vegetables.bin" end
    if itemID == 26 then return "item_milk.bin" end
    if itemID == 27 then return "item_dried_meat.bin" end
    if itemID == 28 then return "item_smoked_meat.bin" end
    if itemID == 29 then return "item_fresh_fish.bin" end
    if itemID == 30 then return "item_fresh_meat.bin" end
    if itemID == 31 then return "item_bandage.bin" end
    if itemID == 32 then return "item_tourniquet.bin" end
    if itemID == 33 then return "item_packet.bin" end
    if itemID == 34 then return "item_bread.bin" end
    if itemID == 71 then return "item_coffee.bin" end
    return ""
  end
end
