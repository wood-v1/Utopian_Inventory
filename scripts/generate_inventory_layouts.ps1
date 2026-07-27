Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$uiDirectory = [System.IO.Path]::GetFullPath((Join-Path $PSScriptRoot "..\resources\ui"))
Add-Type -AssemblyName System.Drawing
$transparentSlotPath = Join-Path $uiDirectory "utopian_slot_transparent.png"
$transparentSlot = [System.Drawing.Bitmap]::new(1, 1, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
$transparentSlotStream = [System.IO.MemoryStream]::new()
try {
    $transparentSlot.SetPixel(0, 0, [System.Drawing.Color]::FromArgb(0, 0, 0, 0))
    $transparentSlot.Save($transparentSlotStream, [System.Drawing.Imaging.ImageFormat]::Png)
    [System.IO.File]::WriteAllBytes($transparentSlotPath, $transparentSlotStream.ToArray())
}
finally {
    $transparentSlotStream.Dispose()
    $transparentSlot.Dispose()
}

$emptySlotTgaPath = Join-Path $uiDirectory "utopian_slot_empty.tga"
$emptySlotTga = [byte[]]::new(18 + 64 * 64 * 4)
$emptySlotTga[2] = 2
$emptySlotTga[12] = 64
$emptySlotTga[14] = 64
$emptySlotTga[16] = 32
$emptySlotTga[17] = 40
for ($pixel = 0; $pixel -lt 64 * 64; $pixel++) {
    $emptySlotTga[18 + $pixel * 4 + 3] = 255
}
[System.IO.File]::WriteAllBytes($emptySlotTgaPath, $emptySlotTga)

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
"@
$russianStringsBase64 = "QDE0MDAK0JjQvdCy0LXQvdGC0LDRgNGMINC/0L7Qu9C+0L0uCkAxNDAxCtCf0LXRgNC10YLQsNGJ0LjRgtC1INC/0YDQtdC00LzQtdGCINGB0Y7QtNCwIOKAlCDQstGL0LHRgNC+0YHQuNGC0Ywg0LXQs9C+ClNoaWZ0ICsg0LvQtdCy0YvQuSDQutC70LjQuiDigJQg0LLRi9Cx0YDQvtGB0LjRgtGMINCy0LXRgdGMINGB0YLQsNC6CkAxNDAyCtCa0L7QvdGC0LXQudC90LXRgCDQt9Cw0L/QvtC70L3QtdC9LgpAMTQwMwrQndCwINGC0YDRg9C/0LUg0LHQvtC70YzRiNC1INC90LXRgiDQvNC10YHRgtCwLgpAMTQwNApDdHJsICsg0LvQtdCy0YvQuSDQutC70LjQuiDigJQg0L/QtdGA0LXQvdC10YHRgtC4INC/0YDQtdC00LzQtdGCINC90LAg0LTRgNGD0LPRg9GOINGB0YLRgNCw0L3QuNGG0YMg0LjQvdCy0LXQvdGC0LDRgNGPCtCf0LXRgNC10YLQsNGJ0LjRgtC1INC/0YDQtdC00LzQtdGCINC90LAg0YHRgtGA0LXQu9C60YMg4oCUINC/0LXRgNC10L3QtdGB0YLQuCDQtdCz0L4g0L3QsCDQtNGA0YPQs9GD0Y4g0YHRgtGA0LDQvdC40YbRgw=="
$russianStrings = [System.Text.Encoding]::UTF8.GetString(
    [System.Convert]::FromBase64String($russianStringsBase64))
[System.IO.File]::WriteAllText(
    (Join-Path $stringsDirectory "utopian_inventory.txt"),
    $englishStrings,
    [System.Text.Encoding]::Unicode)
[System.IO.File]::WriteAllText(
    (Join-Path $stringsDirectory "utopian_inventory_ru.txt"),
    $russianStrings,
    [System.Text.Encoding]::Unicode)

$layouts = @(
    @{ File = "utopian_inventory.xml"; LootFile = "utopian_container.xml"; CorpseFile = "utopian_corpse.xml"; Width = 800; Height = 600; PanelX = 25; PanelY = 50; PanelW = 750; PanelH = 500; PhotoX = 50; PhotoY = 157; PhotoW = 250; PhotoH = 383; GridX = 359; GridY = 225; Step = 58; Columns = 6; Slots = 24; ContainerX = 79; ContainerY = 250; OrganX = 49; OrganY = 482; MoneyX = 655; MoneyY = 465; WeaponX = 234; WeaponY = 337; FeetX = 156; FeetY = 429; HeadX = 156; HeadY = 159; BodyX = 156; BodyY = 271; HandsX = 68; HandsY = 311; DropX = 501; DropY = 455; TimeX = 294; TimeY = 54 },
    @{ File = "utopian_inventory_1024x768.xml"; LootFile = "utopian_container_1024x768.xml"; CorpseFile = "utopian_corpse_1024x768.xml"; Width = 1024; Height = 768; PanelX = 32; PanelY = 64; PanelW = 960; PanelH = 640; PhotoX = 60; PhotoY = 187; PhotoW = 325; PhotoH = 499; GridX = 468; GridY = 266; Step = 61; Columns = 7; Slots = 35; ContainerX = 121; ContainerY = 300; OrganX = 90; OrganY = 570; MoneyX = 864; MoneyY = 616; WeaponX = 315; WeaponY = 438; FeetX = 207; FeetY = 569; HeadX = 207; HeadY = 188; BodyX = 207; BodyY = 346; HandsX = 86; HandsY = 399; DropX = 650; DropY = 580; TimeX = 406; TimeY = 68 },
    @{ File = "utopian_inventory_1280x1024.xml"; LootFile = "utopian_container_1280x1024.xml"; CorpseFile = "utopian_corpse_1280x1024.xml"; RootY = 32; Width = 1280; Height = 960; PanelX = 40; PanelY = 80; PanelW = 1200; PanelH = 800; PhotoX = 75; PhotoY = 230; PhotoW = 405; PhotoH = 623; GridX = 600; GridY = 182; Step = 64; Columns = 8; Slots = 56; ContainerX = 170; ContainerY = 350; OrganX = 138; OrganY = 650; MoneyX = 1100; MoneyY = 770; WeaponX = 395; WeaponY = 550; FeetX = 270; FeetY = 740; HeadX = 270; HeadY = 240; BodyX = 270; BodyY = 428; HandsX = 125; HandsY = 500; DropX = 806; DropY = 685; TimeX = 534; TimeY = 87 },
    @{ File = "utopian_inventory_1920x1080.xml"; LootFile = "utopian_container_1920x1080.xml"; CorpseFile = "utopian_corpse_1920x1080.xml"; Width = 1920; Height = 1080; PanelX = 360; PanelY = 140; PanelW = 1200; PanelH = 800; PhotoX = 395; PhotoY = 290; PhotoW = 405; PhotoH = 623; GridX = 825; GridY = 245; Step = 96; SlotSize = 82; EquipSlotSize = 48; OrganSlotSize = 57; OrganStep = 67; Columns = 7; Slots = 35; ContainerX = 455; ContainerY = 410; OrganX = 469; OrganY = 780; MoneyX = 1390; MoneyY = 780; WeaponX = 690; WeaponY = 610; FeetX = 590; FeetY = 800; HeadX = 590; HeadY = 300; BodyX = 590; BodyY = 488; HandsX = 445; HandsY = 560; DropX = 1067; DropY = 780; TimeX = 854; TimeY = 147 }
)

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
    Add-Line $Builder "  <form name=`"panel_background`" x=`"$($Layout.PanelX)`" y=`"$($Layout.PanelY)`" w=`"$($Layout.PanelW)`" h=`"$($Layout.PanelH)`" script=`"utopian_inventory_background.bin`">"
    Add-Line $Builder "  </form>"
}

function Add-InventorySlot([System.Text.StringBuilder]$Builder, [int]$Number, [int]$X, [int]$Y, [int]$Size) {
    $name = "slot{0:D2}" -f $Number
    Add-Line $Builder "  <form name=`"$name`" x=`"$X`" y=`"$Y`" w=`"$Size`" h=`"$Size`" script=`"utopian_inv_slot.bin`">"
    Add-Line $Builder '    <image name="default" x="0" y="0" w="1" h="1">ui/utopian_slot_empty.tga</image>'
    Add-Line $Builder '    <image name="selected" x="0" y="0" w="1" h="1">ui/utopian_slot_black.png</image>'
    Add-Line $Builder '    <image name="disabled" x="0" y="0" w="1" h="1">ui/utopian_slot_black.png</image>'
    Add-Line $Builder '    <image name="occupied" x="0" y="0" w="1" h="1">ui/utopian_slot_occupied.png</image>'
    Add-Line $Builder '    <image name="target" x="0" y="0" w="1" h="1">ui/utopian_slot_target.png</image>'
    Add-Line $Builder '    <image name="hidden" x="0" y="0" w="1" h="1">ui/utopian_slot_transparent.png</image>'
    Add-Line $Builder '    <font name="default" size="8" face="fritz_quadrata" />'
    Add-Line $Builder "  </form>"
}

function Add-EquipSlot([System.Text.StringBuilder]$Builder, [string]$Name, [int]$X, [int]$Y, [int]$Size) {
    Add-Line $Builder "  <form name=`"$Name`" x=`"$X`" y=`"$Y`" w=`"$Size`" h=`"$Size`" script=`"utopian_equip_slot.bin`">"
    Add-Line $Builder '    <image name="default" x="0" y="0" w="1" h="1">ui/utopian_slot_black.png</image>'
    Add-Line $Builder '    <image name="occupied" x="0" y="0" w="1" h="1">ui/utopian_slot_occupied.png</image>'
    Add-Line $Builder '    <image name="target" x="0" y="0" w="1" h="1">ui/utopian_slot_target.png</image>'
    Add-Line $Builder '    <font name="default" size="8" face="fritz_quadrata" />'
    Add-Line $Builder "  </form>"
}

function Add-LootSlot([System.Text.StringBuilder]$Builder, [string]$Name, [int]$X, [int]$Y, [bool]$CanHide, [int]$Size) {
    Add-Line $Builder "  <form name=`"$Name`" x=`"$X`" y=`"$Y`" w=`"$Size`" h=`"$Size`" script=`"utopian_inv_slot.bin`">"
    Add-Line $Builder '    <image name="default" x="0" y="0" w="1" h="1">ui/utopian_slot_empty.tga</image>'
    Add-Line $Builder '    <image name="selected" x="0" y="0" w="1" h="1">ui/utopian_slot_black.png</image>'
    Add-Line $Builder '    <image name="disabled" x="0" y="0" w="1" h="1">ui/utopian_slot_black.png</image>'
    Add-Line $Builder '    <image name="occupied" x="0" y="0" w="1" h="1">ui/utopian_slot_occupied.png</image>'
    Add-Line $Builder '    <image name="target" x="0" y="0" w="1" h="1">ui/utopian_slot_target.png</image>'
    Add-Line $Builder '    <image name="hidden" x="0" y="0" w="1" h="1">ui/utopian_slot_transparent.png</image>'
    if ($CanHide) {
        # Exact vanilla corpse-slot overlay: crop the 52x52 scalpel tile from
        # the original 64x64 DXT5 atlas copied as utopian_organ_blocked.tex.
        Add-Line $Builder '    <image name="blocked" x="0.015625" y="0.015625" w="0.8125" h="0.8125">ui/utopian_organ_blocked.tex</image>'
    }
    Add-Line $Builder '    <font name="default" size="8" face="fritz_quadrata" />'
    Add-Line $Builder "  </form>"
}

function Add-Pagination([System.Text.StringBuilder]$Builder, [string]$Prefix, [int]$X, [int]$Y) {
    $previousName = "${Prefix}page_prev"
    $counterName = "${Prefix}page_counter"
    $nextName = "${Prefix}page_next"
    Add-Line $Builder "  <form name=`"$previousName`" x=`"$X`" y=`"$Y`" w=`"40`" h=`"36`" script=`"utopian_page_button.bin`">"
    Add-Line $Builder '    <image name="default" x="0" y="0" w="1" h="1">ui/utopian_slot_black.png</image>'
    Add-Line $Builder '    <image name="target" x="0" y="0" w="1" h="1">ui/utopian_slot_target.png</image>'
    Add-Line $Builder '    <image name="hidden" x="0" y="0" w="1" h="1">ui/utopian_slot_transparent.png</image>'
    Add-Line $Builder '    <font name="default" size="18" face="fritz_quadrata" />'
    Add-Line $Builder "  </form>"
    Add-Line $Builder "  <form name=`"$counterName`" x=`"$($X + 40)`" y=`"$Y`" w=`"52`" h=`"36`" script=`"utopian_page_counter.bin`">"
    Add-Line $Builder '    <image name="default" x="0" y="0" w="1" h="1">ui/utopian_slot_black.png</image>'
    Add-Line $Builder '    <image name="hidden" x="0" y="0" w="1" h="1">ui/utopian_slot_transparent.png</image>'
    Add-Line $Builder '    <font name="default" size="16" face="fritz_quadrata" />'
    Add-Line $Builder "  </form>"
    Add-Line $Builder "  <form name=`"$nextName`" x=`"$($X + 92)`" y=`"$Y`" w=`"40`" h=`"36`" script=`"utopian_page_button.bin`">"
    Add-Line $Builder '    <image name="default" x="0" y="0" w="1" h="1">ui/utopian_slot_black.png</image>'
    Add-Line $Builder '    <image name="target" x="0" y="0" w="1" h="1">ui/utopian_slot_target.png</image>'
    Add-Line $Builder '    <image name="hidden" x="0" y="0" w="1" h="1">ui/utopian_slot_transparent.png</image>'
    Add-Line $Builder '    <font name="default" size="18" face="fritz_quadrata" />'
    Add-Line $Builder "  </form>"
}

function Add-Cursors([System.Text.StringBuilder]$Builder) {
    Add-Line $Builder '  <cursor name="utopian_inventory" script="utopian_inventory_cursor.bin" w="112" h="112">'
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
    $playerPagerY = $lowerControlsY
    Add-Line $builder "<form name=`"utopian_inventory`" x=`"$rootX`" y=`"$rootY`" w=`"$($layout.Width)`" h=`"$($layout.Height)`" script=`"utopian_inventory.bin`">"
    Add-Frame $builder $layout
    Add-Line $builder "  <form name=`"time`" x=`"$($layout.TimeX)`" y=`"$($layout.TimeY)`" w=`"213`" h=`"24`" script=`"ui_inventory_time.bin`">"
    Add-Line $builder '    <image name="default" x="0" y="0" w="1" h="1">ui/utopian_slot_black.png</image>'
    Add-Line $builder '    <font name="default" size="14" face="fritz_quadrata" />'
    Add-Line $builder "  </form>"
    Add-Line $builder "  <form name=`"character_doll`" x=`"$($layout.PhotoX)`" y=`"$($layout.PhotoY)`" w=`"$($layout.PhotoW)`" h=`"$($layout.PhotoH)`" script=`"utopian_character_doll.bin`">"
    Add-Line $builder "  </form>"

    Add-EquipSlot $builder "equip_head" $layout.HeadX $layout.HeadY $equipSlotSize
    Add-EquipSlot $builder "equip_body" $layout.BodyX $layout.BodyY $equipSlotSize
    Add-EquipSlot $builder "equip_hands" $layout.HandsX $layout.HandsY $equipSlotSize
    Add-EquipSlot $builder "equip_feet" $layout.FeetX $layout.FeetY $equipSlotSize
    Add-EquipSlot $builder "equip_weapon" $layout.WeaponX $layout.WeaponY $equipSlotSize

    Add-Line $builder "  <form name=`"money`" x=`"$($layout.MoneyX)`" y=`"$($layout.MoneyY)`" w=`"$slotSize`" h=`"$slotSize`" script=`"utopian_money_slot.bin`">"
    Add-Line $builder '    <image name="default" x="0" y="0" w="1" h="1">ui/utopian_slot_black.png</image>'
    Add-Line $builder '    <font name="default" size="8" face="fritz_quadrata" />'
    Add-Line $builder "  </form>"

    for ($slot = 0; $slot -lt $layout.Slots; $slot++) {
        $column = $slot % $layout.Columns
        $row = [Math]::Floor($slot / $layout.Columns)
        Add-InventorySlot $builder ($slot + 1) ($layout.GridX + $column * $layout.Step) ($layout.GridY + $row * $layout.Step) $slotSize
    }

    Add-Line $builder "  <form name=`"drop_slot`" x=`"$dropX`" y=`"$lowerControlsY`" w=`"$slotSize`" h=`"$slotSize`" script=`"utopian_drop_slot.bin`">"
    Add-Line $builder '    <image name="default" x="0" y="0" w="1" h="1">ui/utopian_slot_black.png</image>'
    Add-Line $builder '    <image name="target" x="0" y="0" w="1" h="1">ui/utopian_slot_target.png</image>'
    Add-Line $builder '    <font name="default" size="8" face="fritz_quadrata" />'
    Add-Line $builder "  </form>"

    if ($layout.Slots -lt 56) {
        Add-Pagination $builder "" $inventoryPagerX $playerPagerY
    }

    Add-Cursors $builder
    Add-Line $builder "</form>"

    $target = Join-Path (Join-Path $PSScriptRoot "..\resources\ui") $layout.File
    [System.IO.File]::WriteAllText($target, $builder.ToString(), [System.Text.UTF8Encoding]::new($false))
    Write-Host "generated $target"

    $lootBuilder = [System.Text.StringBuilder]::new()
    Add-Line $lootBuilder "<form name=`"utopian_container`" x=`"$rootX`" y=`"$rootY`" w=`"$($layout.Width)`" h=`"$($layout.Height)`" script=`"utopian_container.bin`">"
    Add-Frame $lootBuilder $layout
    $lootDollW = [Math]::Floor($layout.PhotoW / 2)
    $lootDollH = [Math]::Floor($layout.PhotoH / 2)
    $lootDollX = $layout.PhotoX + [Math]::Floor(($layout.PhotoW - $lootDollW) / 2)
    $lootDollY = $layout.PhotoY + $layout.PhotoH - $lootDollH
    Add-Line $lootBuilder "  <form name=`"loot_doll`" x=`"$lootDollX`" y=`"$lootDollY`" w=`"$lootDollW`" h=`"$lootDollH`" script=`"utopian_loot_doll.bin`">"
    Add-Line $lootBuilder '    <image name="container" x="0" y="0" w="1" h="1">ui/utopian_loot_container.tga</image>'
    Add-Line $lootBuilder '    <image name="corpse" x="0" y="0" w="1" h="1">ui/utopian_loot_corpse.tga</image>'
    Add-Line $lootBuilder "  </form>"
    Add-Line $lootBuilder "  <form name=`"time`" x=`"$($layout.TimeX)`" y=`"$($layout.TimeY)`" w=`"213`" h=`"24`" script=`"ui_inventory_time.bin`">"
    Add-Line $lootBuilder '    <image name="default" x="0" y="0" w="1" h="1">ui/utopian_slot_black.png</image>'
    Add-Line $lootBuilder '    <font name="default" size="14" face="fritz_quadrata" />'
    Add-Line $lootBuilder "  </form>"

    for ($slot = 0; $slot -lt 12; $slot++) {
        $column = $slot % 3
        $row = [Math]::Floor($slot / 3)
        Add-LootSlot $lootBuilder ("cslot{0:D2}" -f ($slot + 1)) ($layout.ContainerX + $column * $layout.Step) ($layout.GridY + $row * $layout.Step) $false $slotSize
    }
    Add-Line $lootBuilder "  <form name=`"money`" x=`"$($layout.MoneyX)`" y=`"$($layout.MoneyY)`" w=`"$slotSize`" h=`"$slotSize`" script=`"utopian_money_slot.bin`">"
    Add-Line $lootBuilder '    <image name="default" x="0" y="0" w="1" h="1">ui/utopian_slot_black.png</image>'
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
    Add-Line $corpseExtras '  <form name="corpse_marker" x="0" y="0" w="1" h="1" script="utopian_corpse_marker.bin">'
    Add-Line $corpseExtras '  </form>'
    $rootClose = $corpseText.LastIndexOf("</form>")
    if ($rootClose -lt 0) { throw "Cannot find root closing form in $($layout.CorpseFile)" }
    $corpseText = $corpseText.Insert($rootClose, $corpseExtras.ToString())
    $corpseTarget = Join-Path (Join-Path $PSScriptRoot "..\resources\ui") $layout.CorpseFile
    Assert-ValidXml $corpseText $corpseTarget
    [System.IO.File]::WriteAllText($corpseTarget, $corpseText, [System.Text.UTF8Encoding]::new($false))
    Write-Host "generated $corpseTarget"
}
