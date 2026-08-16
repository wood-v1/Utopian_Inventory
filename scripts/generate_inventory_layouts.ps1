Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$uiDirectory = [System.IO.Path]::GetFullPath((Join-Path $PSScriptRoot "..\resources\ui"))
$textureScript = Join-Path $PSScriptRoot "prepare_character_textures.py"
& python $textureScript
if ($LASTEXITCODE -ne 0) {
    throw "Texture preparation failed with exit code $LASTEXITCODE"
}

$stringsDirectory = [System.IO.Path]::GetFullPath((Join-Path $PSScriptRoot "..\resources\strings"))
$englishStrings = @"
@1400
Inventory is full.
@1401
Drag an item here - drop it
Shift + Left Click - drop the entire stack
@1402
Container is full.
@1403
The corpse cannot hold any more items.
@1404
Ctrl + Left Click - move the item to the other inventory page
Drag item to arrow - move it to the other page
@1405
The assigned quick-slot item is not in the inventory.
@1406
This item cannot be used.
@1407
Quick slots
Hover an item and press 1-0 to assign it.
Press 1-0 outside the inventory to use or equip it.
"@
$russianStringsBase64 = "QDE0MDAK0JjQvdCy0LXQvdGC0LDRgNGMINC/0L7Qu9C+0L0uCkAxNDAxCtCf0LXRgNC10YLQsNGJ0LjRgtC1INC/0YDQtdC00LzQtdGCINGB0Y7QtNCwIOKAlCDQstGL0LHRgNC+0YHQuNGC0Ywg0LXQs9C+ClNoaWZ0ICsg0LvQtdCy0YvQuSDQutC70LjQuiDigJQg0LLRi9Cx0YDQvtGB0LjRgtGMINCy0LXRgdGMINGB0YLQsNC6CkAxNDAyCtCa0L7QvdGC0LXQudC90LXRgCDQt9Cw0L/QvtC70L3QtdC9LgpAMTQwMwrQndCwINGC0YDRg9C/0LUg0LHQvtC70YzRiNC1INC90LXRgiDQvNC10YHRgtCwLgpAMTQwNApDdHJsICsg0LvQtdCy0YvQuSDQutC70LjQuiDigJQg0L/QtdGA0LXQvdC10YHRgtC4INC/0YDQtdC00LzQtdGCINC90LAg0LTRgNGD0LPRg9GOINGB0YLRgNCw0L3QuNGG0YMg0LjQvdCy0LXQvdGC0LDRgNGPCtCf0LXRgNC10YLQsNGJ0LjRgtC1INC/0YDQtdC00LzQtdGCINC90LAg0YHRgtGA0LXQu9C60YMg4oCUINC/0LXRgNC10L3QtdGB0YLQuCDQtdCz0L4g0L3QsCDQtNGA0YPQs9GD0Y4g0YHRgtGA0LDQvdC40YbRgw=="
$russianStrings = [System.Text.Encoding]::UTF8.GetString(
    [System.Convert]::FromBase64String($russianStringsBase64))
$russianQuickslotStringsBase64 = "QDE0MDUK0J3QsNC30L3QsNGH0LXQvdC90L7Qs9C+INC/0YDQtdC00LzQtdGC0LAg0LHRi9GB0YLRgNC+0LPQviDQtNC+0YHRgtGD0L/QsCDQvdC10YIg0LIg0LjQvdCy0LXQvdGC0LDRgNC1LgpAMTQwNgrQrdGC0L7RgiDQv9GA0LXQtNC80LXRgiDQvdC10LvRjNC30Y8g0LjRgdC/0L7Qu9GM0LfQvtCy0LDRgtGMLgpAMTQwNwrQkdGL0YHRgtGA0YvQtSDRgdC70L7RgtGLCtCd0LDQstC10LTQuNGC0LUg0LrRg9GA0YHQvtGAINC90LAg0L/RgNC10LTQvNC10YIg0Lgg0L3QsNC20LzQuNGC0LUgMS0wLCDRh9GC0L7QsdGLINC90LDQt9C90LDRh9C40YLRjCDQtdCz0L4uCtCd0LDQttC80LjRgtC1IDEtMCDQstC90LUg0LjQvdCy0LXQvdGC0LDRgNGPLCDRh9GC0L7QsdGLINC40YHQv9C+0LvRjNC30L7QstCw0YLRjCDQuNC70Lgg0Y3QutC40L/QuNGA0L7QstCw0YLRjCDQv9GA0LXQtNC80LXRgi4="
$russianStrings += "`n" + [System.Text.Encoding]::UTF8.GetString(
    [System.Convert]::FromBase64String($russianQuickslotStringsBase64))
[System.IO.File]::WriteAllText(
    (Join-Path $stringsDirectory "inv_overhaul_inventory.txt"),
    $englishStrings,
    [System.Text.Encoding]::Unicode)
[System.IO.File]::WriteAllText(
    (Join-Path $stringsDirectory "inv_overhaul_inventory_ru.txt"),
    $russianStrings,
    [System.Text.Encoding]::Unicode)

$layouts = @(
    @{ File = "inv_overhaul_inventory.xml"; ClaraFile = "inv_overhaul_inventory_clara.xml"; LootFile = "inv_overhaul_container.xml"; CorpseFile = "inv_overhaul_corpse.xml"; Width = 800; Height = 600; PanelX = 25; PanelY = 50; PanelW = 750; PanelH = 500; PhotoX = 50; PhotoY = 157; PhotoW = 250; PhotoH = 383; GridX = 359; GridY = 225; Step = 58; Columns = 6; Slots = 24; ContainerX = 79; ContainerY = 250; OrganX = 49; OrganY = 482; MoneyX = 655; MoneyY = 465; WeaponX = 222; WeaponY = 323; ClaraWeaponY = 255; FeetX = 156; FeetY = 429; HeadX = 156; HeadY = 159; HeadOffset = 15; ClaraHeadOffset = 78; BodyX = 156; ClaraBodyX = 144; BodyY = 271; HandsX = 68; HandsY = 311; DropX = 501; DropY = 455; TimeX = 294; TimeY = 54 },
    @{ File = "inv_overhaul_inventory_1024x768.xml"; ClaraFile = "inv_overhaul_inventory_clara_1024x768.xml"; LootFile = "inv_overhaul_container_1024x768.xml"; CorpseFile = "inv_overhaul_corpse_1024x768.xml"; Width = 1024; Height = 768; PanelX = 32; PanelY = 64; PanelW = 960; PanelH = 640; PhotoX = 60; PhotoY = 187; PhotoW = 325; PhotoH = 499; GridX = 468; GridY = 266; Step = 61; Columns = 7; Slots = 35; ContainerX = 121; ContainerY = 300; OrganX = 90; OrganY = 570; MoneyX = 864; MoneyY = 616; WeaponX = 299; WeaponY = 418; ClaraWeaponY = 351; FeetX = 207; FeetY = 569; HeadX = 207; HeadY = 188; HeadOffset = 18; ClaraHeadOffset = 84; BodyX = 207; ClaraBodyX = 191; BodyY = 346; HandsX = 86; HandsY = 399; DropX = 650; DropY = 580; TimeX = 406; TimeY = 68 },
    @{ File = "inv_overhaul_inventory_1280x1024.xml"; ClaraFile = "inv_overhaul_inventory_clara_1280x1024.xml"; LootFile = "inv_overhaul_container_1280x1024.xml"; CorpseFile = "inv_overhaul_corpse_1280x1024.xml"; RootY = 32; Width = 1280; Height = 960; PanelX = 40; PanelY = 80; PanelW = 1200; PanelH = 800; PhotoX = 75; PhotoY = 230; PhotoW = 405; PhotoH = 623; GridX = 600; GridY = 182; Step = 64; Columns = 8; Slots = 56; ContainerX = 170; ContainerY = 350; OrganX = 138; OrganY = 650; MoneyX = 1100; MoneyY = 770; WeaponX = 375; WeaponY = 528; ClaraWeaponY = 458; FeetX = 270; FeetY = 740; HeadX = 270; HeadY = 240; HeadOffset = 24; ClaraHeadOffset = 94; BodyX = 270; ClaraBodyX = 250; BodyY = 428; HandsX = 125; HandsY = 500; DropX = 806; DropY = 685; TimeX = 534; TimeY = 87 },
    @{ File = "inv_overhaul_inventory_1920x1080.xml"; ClaraFile = "inv_overhaul_inventory_clara_1920x1080.xml"; LootFile = "inv_overhaul_container_1920x1080.xml"; CorpseFile = "inv_overhaul_corpse_1920x1080.xml"; Width = 1920; Height = 1080; PanelX = 360; PanelY = 140; PanelW = 1200; PanelH = 800; PhotoX = 395; PhotoY = 290; PhotoW = 405; PhotoH = 623; GridX = 825; GridY = 245; Step = 96; SlotSize = 82; EquipSlotSize = 48; OrganSlotSize = 57; OrganStep = 67; Columns = 7; Slots = 35; ContainerX = 455; ContainerY = 410; OrganX = 469; OrganY = 780; MoneyX = 1390; MoneyY = 780; WeaponX = 660; WeaponY = 580; ClaraWeaponY = 512; FeetX = 590; FeetY = 800; HeadX = 590; HeadY = 300; HeadOffset = 30; ClaraHeadOffset = 100; BodyX = 590; ClaraBodyX = 560; BodyY = 488; HandsX = 445; HandsY = 560; DropX = 1067; DropY = 780; TimeX = 854; TimeY = 147 }
)

# Bachelor and Haruspex share the base layout. Clara keeps the deliberately
# lower branch-specific offsets stored in ClaraHeadOffset.
foreach ($layout in $layouts) {
    if ($layout.Width -ge 1900) { $layout.HeadOffset = 15 }
    elseif ($layout.Width -ge 1200) { $layout.HeadOffset = 12 }
    elseif ($layout.Width -ge 1000) { $layout.HeadOffset = 9 }
    else { $layout.HeadOffset = 8 }
}

function Add-Line([System.Text.StringBuilder]$Builder, [string]$Line) {
    [void]$Builder.AppendLine($Line)
}

function Assert-ValidXml([string]$Text, [string]$Target) {
    try {
        [void][xml]$Text
    }
    catch {
        throw "Generated invalid XML for ${Target}: $($_.Exception.Message)"
    }
}

function Add-Frame([System.Text.StringBuilder]$Builder, $Layout) {
    Add-Line $Builder "  <form name=`"panel_background`" x=`"$($Layout.PanelX)`" y=`"$($Layout.PanelY)`" w=`"$($Layout.PanelW)`" h=`"$($Layout.PanelH)`" script=`"inv_overhaul_inventory_background.bin`">"
    Add-Line $Builder '    <font name="default" size="8" face="fritz_quadrata" />'
    Add-Line $Builder '    <font name="quickslot" size="14" face="fritz_quadrata" />'
    Add-Line $Builder "  </form>"
}

function Add-InventorySlot([System.Text.StringBuilder]$Builder, [int]$Number, [int]$X, [int]$Y, [int]$Size) {
    $name = "slot{0:D2}" -f $Number
    Add-Line $Builder "  <form name=`"$name`" x=`"$X`" y=`"$Y`" w=`"$Size`" h=`"$Size`" script=`"inv_overhaul_inv_slot.bin`">"
    Add-Line $Builder '    <image name="default" x="0" y="0" w="1" h="1">ui/inv_overhaul_slot_empty_runtime.tga</image>'
    Add-Line $Builder '    <image name="selected" x="0" y="0" w="1" h="1">ui/inv_overhaul_slot_black.tex</image>'
    Add-Line $Builder '    <image name="disabled" x="0" y="0" w="1" h="1">ui/inv_overhaul_slot_black.tex</image>'
    Add-Line $Builder '    <image name="occupied" x="0" y="0" w="1" h="1">ui/inv_overhaul_slot_occupied.tex</image>'
    Add-Line $Builder '    <image name="target" x="0" y="0" w="1" h="1">ui/inv_overhaul_slot_target.tex</image>'
    Add-Line $Builder '    <image name="hidden" x="0" y="0" w="1" h="1">ui/inv_overhaul_slot_transparent.tex</image>'
    Add-Line $Builder '    <font name="default" size="8" face="fritz_quadrata" />'
    Add-Line $Builder '    <font name="quickslot" size="14" face="fritz_quadrata" />'
    Add-Line $Builder "  </form>"
}

function Add-EquipSlot([System.Text.StringBuilder]$Builder, [string]$Name, [int]$X, [int]$Y, [int]$Size) {
    Add-Line $Builder "  <form name=`"$Name`" x=`"$X`" y=`"$Y`" w=`"$Size`" h=`"$Size`" script=`"inv_overhaul_equip_slot.bin`">"
    Add-Line $Builder '    <image name="default" x="0" y="0" w="1" h="1">ui/inv_overhaul_slot_black.tex</image>'
    Add-Line $Builder '    <image name="occupied" x="0" y="0" w="1" h="1">ui/inv_overhaul_slot_occupied.tex</image>'
    Add-Line $Builder '    <image name="target" x="0" y="0" w="1" h="1">ui/inv_overhaul_slot_target.tex</image>'
    Add-Line $Builder '    <font name="default" size="8" face="fritz_quadrata" />'
    Add-Line $Builder '    <font name="quickslot" size="14" face="fritz_quadrata" />'
    Add-Line $Builder "  </form>"
}

function Add-LootSlot([System.Text.StringBuilder]$Builder, [string]$Name, [int]$X, [int]$Y, [bool]$CanHide, [int]$Size) {
    Add-Line $Builder "  <form name=`"$Name`" x=`"$X`" y=`"$Y`" w=`"$Size`" h=`"$Size`" script=`"inv_overhaul_inv_slot.bin`">"
    Add-Line $Builder '    <image name="default" x="0" y="0" w="1" h="1">ui/inv_overhaul_slot_empty_runtime.tga</image>'
    Add-Line $Builder '    <image name="selected" x="0" y="0" w="1" h="1">ui/inv_overhaul_slot_black.tex</image>'
    Add-Line $Builder '    <image name="disabled" x="0" y="0" w="1" h="1">ui/inv_overhaul_slot_black.tex</image>'
    Add-Line $Builder '    <image name="occupied" x="0" y="0" w="1" h="1">ui/inv_overhaul_slot_occupied.tex</image>'
    Add-Line $Builder '    <image name="target" x="0" y="0" w="1" h="1">ui/inv_overhaul_slot_target.tex</image>'
    Add-Line $Builder '    <image name="hidden" x="0" y="0" w="1" h="1">ui/inv_overhaul_slot_transparent.tex</image>'
    if ($CanHide) {
        # Exact vanilla corpse-slot overlay: crop the 52x52 scalpel tile from
        # the original 64x64 DXT5 atlas copied as inv_overhaul_organ_blocked.tex.
        Add-Line $Builder '    <image name="blocked" x="0.015625" y="0.015625" w="0.8125" h="0.8125">ui/inv_overhaul_organ_blocked.tex</image>'
    }
    Add-Line $Builder '    <font name="default" size="8" face="fritz_quadrata" />'
    Add-Line $Builder '    <font name="quickslot" size="14" face="fritz_quadrata" />'
    Add-Line $Builder "  </form>"
}

function Add-Pagination([System.Text.StringBuilder]$Builder, [string]$Prefix, [int]$X, [int]$Y) {
    $previousName = "${Prefix}page_prev"
    $counterName = "${Prefix}page_counter"
    $nextName = "${Prefix}page_next"
    Add-Line $Builder "  <form name=`"$previousName`" x=`"$X`" y=`"$Y`" w=`"40`" h=`"36`" script=`"inv_overhaul_page_button.bin`">"
    Add-Line $Builder '    <image name="default" x="0" y="0" w="1" h="1">ui/inv_overhaul_slot_black.tex</image>'
    Add-Line $Builder '    <image name="target" x="0" y="0" w="1" h="1">ui/inv_overhaul_slot_target.tex</image>'
    Add-Line $Builder '    <image name="hidden" x="0" y="0" w="1" h="1">ui/inv_overhaul_slot_transparent.tex</image>'
    Add-Line $Builder '    <font name="default" size="18" face="fritz_quadrata" />'
    Add-Line $Builder "  </form>"
    Add-Line $Builder "  <form name=`"$counterName`" x=`"$($X + 40)`" y=`"$Y`" w=`"52`" h=`"36`" script=`"inv_overhaul_page_counter.bin`">"
    Add-Line $Builder '    <image name="default" x="0" y="0" w="1" h="1">ui/inv_overhaul_slot_black.tex</image>'
    Add-Line $Builder '    <image name="hidden" x="0" y="0" w="1" h="1">ui/inv_overhaul_slot_transparent.tex</image>'
    Add-Line $Builder '    <font name="default" size="16" face="fritz_quadrata" />'
    Add-Line $Builder "  </form>"
    Add-Line $Builder "  <form name=`"$nextName`" x=`"$($X + 92)`" y=`"$Y`" w=`"40`" h=`"36`" script=`"inv_overhaul_page_button.bin`">"
    Add-Line $Builder '    <image name="default" x="0" y="0" w="1" h="1">ui/inv_overhaul_slot_black.tex</image>'
    Add-Line $Builder '    <image name="target" x="0" y="0" w="1" h="1">ui/inv_overhaul_slot_target.tex</image>'
    Add-Line $Builder '    <image name="hidden" x="0" y="0" w="1" h="1">ui/inv_overhaul_slot_transparent.tex</image>'
    Add-Line $Builder '    <font name="default" size="18" face="fritz_quadrata" />'
    Add-Line $Builder "  </form>"
}

function Add-QuickslotHelp([System.Text.StringBuilder]$Builder, $Layout) {
    $helpSize = 28
    $helpX = $Layout.PanelX + $Layout.PanelW - 74
    $helpY = $Layout.PanelY + 71
    Add-Line $Builder "  <form name=`"quickslot_help`" x=`"$helpX`" y=`"$helpY`" w=`"$helpSize`" h=`"$helpSize`" script=`"inv_overhaul_quickslot_help.bin`">"
    Add-Line $Builder '    <image name="default" x="0" y="0" w="1" h="1">ui/inv_overhaul_quickslot_help.tex</image>'
    Add-Line $Builder "  </form>"
}

function Add-Cursors([System.Text.StringBuilder]$Builder) {
    Add-Line $Builder '  <cursor name="inv_overhaul_inventory" script="inv_overhaul_inventory_cursor.bin" w="112" h="112">'
    Add-Line $Builder '    <image name="default" x="0" y="0" w="1" h="1">ui/ui_cursor.tga</image>'
    Add-Line $Builder '    <image name="border" x="0" y="0" w="1" h="1">ui/ui_tooltip_border.png</image>'
    Add-Line $Builder '    <image name="bg" x="0" y="0" w="1" h="1">ui/ui_tooltip_bg.png</image>'
    Add-Line $Builder '    <font name="default" size="10" face="fritz_quadrata" />'
    Add-Line $Builder '    <font name="big" size="12" face="fritz_quadrata" />'
    Add-Line $Builder "  </cursor>"
}

foreach ($layout in $layouts) {
    $builder = [System.Text.StringBuilder]::new()
    $rootX = if ($layout.ContainsKey("RootX")) { $layout.RootX } else { 0 }
    $rootY = if ($layout.ContainsKey("RootY")) { $layout.RootY } else { 0 }
    $slotSize = if ($layout.ContainsKey("SlotSize")) { $layout.SlotSize } else { 52 }
    $equipSlotSize = if ($layout.ContainsKey("EquipSlotSize")) { $layout.EquipSlotSize } else { $slotSize }
    $organSlotSize = if ($layout.ContainsKey("OrganSlotSize")) { $layout.OrganSlotSize } else { $slotSize }
    $organStep = if ($layout.ContainsKey("OrganStep")) { $layout.OrganStep } else { $layout.Step }
    $dropX = $layout.GridX
    $lowerControlsY = $layout.MoneyY
    $inventoryPagerX = [Math]::Floor(($dropX + $slotSize + $layout.MoneyX - 132) / 2)
    $playerPagerX = $inventoryPagerX
    $playerPagerY = $lowerControlsY + $slotSize - 36
    Add-Line $builder "<form name=`"inv_overhaul_inventory`" x=`"$rootX`" y=`"$rootY`" w=`"$($layout.Width)`" h=`"$($layout.Height)`" script=`"inv_overhaul_inventory.bin`">"
    Add-Frame $builder $layout
    Add-Line $builder "  <form name=`"time`" x=`"$($layout.TimeX)`" y=`"$($layout.TimeY)`" w=`"213`" h=`"24`" script=`"ui_inventory_time.bin`">"
    Add-Line $builder '    <image name="default" x="0" y="0" w="1" h="1">ui/inv_overhaul_slot_black.tex</image>'
    Add-Line $builder '    <font name="default" size="14" face="fritz_quadrata" />'
    Add-Line $builder "  </form>"
    Add-Line $builder "  <form name=`"character_doll`" x=`"$($layout.PhotoX)`" y=`"$($layout.PhotoY)`" w=`"$($layout.PhotoW)`" h=`"$($layout.PhotoH)`" script=`"inv_overhaul_character_doll.bin`">"
    Add-Line $builder "  </form>"

    $headOffset = $layout.HeadOffset
    Add-EquipSlot $builder "equip_head" $layout.HeadX ($layout.HeadY + $headOffset) $equipSlotSize
    Add-EquipSlot $builder "equip_body" $layout.BodyX $layout.BodyY $equipSlotSize
    Add-EquipSlot $builder "equip_hands" $layout.HandsX $layout.HandsY $equipSlotSize
    Add-EquipSlot $builder "equip_feet" $layout.FeetX $layout.FeetY $equipSlotSize
    Add-EquipSlot $builder "equip_weapon" $layout.WeaponX $layout.WeaponY $equipSlotSize

    Add-Line $builder "  <form name=`"money`" x=`"$($layout.MoneyX)`" y=`"$($layout.MoneyY)`" w=`"$slotSize`" h=`"$slotSize`" script=`"inv_overhaul_money_slot.bin`">"
    Add-Line $builder '    <image name="default" x="0" y="0" w="1" h="1">ui/inv_overhaul_slot_black.tex</image>'
    Add-Line $builder '    <font name="default" size="8" face="fritz_quadrata" />'
    Add-Line $builder "  </form>"

    Add-Line $builder "  <form name=`"drop_slot`" x=`"$dropX`" y=`"$lowerControlsY`" w=`"$slotSize`" h=`"$slotSize`" script=`"inv_overhaul_drop_slot.bin`">"
    Add-Line $builder '    <image name="default" x="0" y="0" w="1" h="1">ui/inv_overhaul_slot_black.tex</image>'
    Add-Line $builder '    <image name="target" x="0" y="0" w="1" h="1">ui/inv_overhaul_slot_target.tex</image>'
    Add-Line $builder '    <font name="default" size="8" face="fritz_quadrata" />'
    Add-Line $builder "  </form>"

    if ($layout.Slots -lt 56) {
        Add-Pagination $builder "" $inventoryPagerX $playerPagerY
    }
    Add-Cursors $builder
    Add-Line $builder "</form>"

    $target = Join-Path (Join-Path $PSScriptRoot "..\resources\ui") $layout.File
    $inventoryText = $builder.ToString()
    Assert-ValidXml $inventoryText $target
    [System.IO.File]::WriteAllText($target, $inventoryText, [System.Text.UTF8Encoding]::new($false))
    Write-Host "generated $target"

    $claraHeadY = $layout.HeadY + $layout.ClaraHeadOffset
    $claraText = $inventoryText.Replace(
        "<form name=`"equip_head`" x=`"$($layout.HeadX)`" y=`"$($layout.HeadY + $layout.HeadOffset)`"",
        "<form name=`"equip_head`" x=`"$($layout.HeadX)`" y=`"$claraHeadY`"")
    $claraText = $claraText.Replace(
        "<form name=`"equip_body`" x=`"$($layout.BodyX)`" y=`"$($layout.BodyY)`"",
        "<form name=`"equip_body`" x=`"$($layout.ClaraBodyX)`" y=`"$($layout.BodyY)`"")
    $claraText = $claraText.Replace(
        "<form name=`"equip_weapon`" x=`"$($layout.WeaponX)`" y=`"$($layout.WeaponY)`"",
        "<form name=`"equip_weapon`" x=`"$($layout.WeaponX)`" y=`"$($layout.ClaraWeaponY)`"")
    $claraTarget = Join-Path (Join-Path $PSScriptRoot "..\resources\ui") $layout.ClaraFile
    Assert-ValidXml $claraText $claraTarget
    [System.IO.File]::WriteAllText($claraTarget, $claraText, [System.Text.UTF8Encoding]::new($false))
    Write-Host "generated $claraTarget"

    $lootBuilder = [System.Text.StringBuilder]::new()
    Add-Line $lootBuilder "<form name=`"inv_overhaul_container`" x=`"$rootX`" y=`"$rootY`" w=`"$($layout.Width)`" h=`"$($layout.Height)`" script=`"inv_overhaul_container.bin`">"
    Add-Frame $lootBuilder $layout
    $lootDollW = [Math]::Floor($layout.PhotoW / 2)
    $lootDollH = [Math]::Floor($layout.PhotoH / 2)
    $lootDollX = $layout.PhotoX + [Math]::Floor(($layout.PhotoW - $lootDollW) / 2)
    $lootDollY = $layout.PhotoY + $layout.PhotoH - $lootDollH
    Add-Line $lootBuilder "  <form name=`"loot_doll`" x=`"$lootDollX`" y=`"$lootDollY`" w=`"$lootDollW`" h=`"$lootDollH`" script=`"inv_overhaul_loot_doll.bin`">"
    Add-Line $lootBuilder '    <image name="container" x="0" y="0" w="1" h="1">ui/inv_overhaul_loot_container.tex</image>'
    Add-Line $lootBuilder '    <image name="corpse" x="0" y="0" w="1" h="1">ui/inv_overhaul_loot_corpse.tex</image>'
    Add-Line $lootBuilder "  </form>"
    Add-Line $lootBuilder "  <form name=`"time`" x=`"$($layout.TimeX)`" y=`"$($layout.TimeY)`" w=`"213`" h=`"24`" script=`"ui_inventory_time.bin`">"
    Add-Line $lootBuilder '    <image name="default" x="0" y="0" w="1" h="1">ui/inv_overhaul_slot_black.tex</image>'
    Add-Line $lootBuilder '    <font name="default" size="14" face="fritz_quadrata" />'
    Add-Line $lootBuilder "  </form>"

    for ($slot = 0; $slot -lt 12; $slot++) {
        $column = $slot % 3
        $row = [Math]::Floor($slot / 3)
        Add-LootSlot $lootBuilder ("cslot{0:D2}" -f ($slot + 1)) ($layout.ContainerX + $column * $layout.Step) ($layout.GridY + $row * $layout.Step) $false $slotSize
    }
    Add-Line $lootBuilder "  <form name=`"money`" x=`"$($layout.MoneyX)`" y=`"$($layout.MoneyY)`" w=`"$slotSize`" h=`"$slotSize`" script=`"inv_overhaul_money_slot.bin`">"
    Add-Line $lootBuilder '    <image name="default" x="0" y="0" w="1" h="1">ui/inv_overhaul_slot_black.tex</image>'
    Add-Line $lootBuilder '    <font name="default" size="8" face="fritz_quadrata" />'
    Add-Line $lootBuilder "  </form>"

    for ($slot = 0; $slot -lt $layout.Slots; $slot++) {
        $column = $slot % $layout.Columns
        $row = [Math]::Floor($slot / $layout.Columns)
        Add-InventorySlot $lootBuilder ($slot + 1) ($layout.GridX + $column * $layout.Step) ($layout.GridY + $row * $layout.Step) $slotSize
    }

    $containerPagerX = $layout.ContainerX + 28
    if ($layout.Width -ge 1900) { $containerPagerX = $layout.ContainerX + 73 }
    $containerPagerY = $layout.GridY + 4 * $layout.Step - 4
    Add-Pagination $lootBuilder "container_" $containerPagerX $containerPagerY
    Add-Pagination $lootBuilder "player_" $playerPagerX $playerPagerY
    for ($slot = 0; $slot -lt 4; $slot++) {
        Add-LootSlot $lootBuilder ("oslot{0:D2}" -f ($slot + 1)) ($layout.OrganX + $slot * $organStep) $layout.OrganY $true $organSlotSize
    }

    Add-Cursors $lootBuilder
    Add-Line $lootBuilder '  <sound name="take_organ" loop="0">take_organ.ogg</sound>'
    Add-Line $lootBuilder "</form>"

    $lootTarget = Join-Path (Join-Path $PSScriptRoot "..\resources\ui") $layout.LootFile
    $lootText = $lootBuilder.ToString()
    Assert-ValidXml $lootText $lootTarget
    [System.IO.File]::WriteAllText($lootTarget, $lootText, [System.Text.UTF8Encoding]::new($false))
    Write-Host "generated $lootTarget"

    $corpseText = $lootText
    $corpseExtras = [System.Text.StringBuilder]::new()
    Add-Line $corpseExtras '  <form name="corpse_marker" x="0" y="0" w="1" h="1" script="inv_overhaul_corpse_marker.bin">'
    Add-Line $corpseExtras '  </form>'
    $rootClose = $corpseText.LastIndexOf("</form>")
    if ($rootClose -lt 0) { throw "Cannot find root closing form in $($layout.CorpseFile)" }
    $corpseText = $corpseText.Insert($rootClose, $corpseExtras.ToString())
    $corpseTarget = Join-Path (Join-Path $PSScriptRoot "..\resources\ui") $layout.CorpseFile
    Assert-ValidXml $corpseText $corpseTarget
    [System.IO.File]::WriteAllText($corpseTarget, $corpseText, [System.Text.UTF8Encoding]::new($false))
    Write-Host "generated $corpseTarget"
}
