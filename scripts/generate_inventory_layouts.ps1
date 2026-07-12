Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$layouts = @(
    @{ File = "utopian_inventory.xml"; Width = 800; Height = 600; PanelX = 25; PanelY = 50; PanelW = 750; PanelH = 500; PhotoX = 50; PhotoY = 157; PhotoW = 250; PhotoH = 383; GridX = 359; GridY = 225; Step = 58; Columns = 6; Slots = 24; MoneyX = 655; MoneyY = 465; WeaponX = 234; WeaponY = 337; FeetX = 156; FeetY = 429; HeadX = 156; HeadY = 159; BodyX = 156; BodyY = 271; HandsX = 68; HandsY = 311; DropX = 501; DropY = 455; TimeX = 294; TimeY = 54 },
    @{ File = "utopian_inventory_1024x768.xml"; Width = 1024; Height = 768; PanelX = 32; PanelY = 64; PanelW = 960; PanelH = 640; PhotoX = 60; PhotoY = 187; PhotoW = 325; PhotoH = 499; GridX = 468; GridY = 266; Step = 61; Columns = 7; Slots = 35; MoneyX = 864; MoneyY = 616; WeaponX = 315; WeaponY = 438; FeetX = 207; FeetY = 569; HeadX = 207; HeadY = 188; BodyX = 207; BodyY = 346; HandsX = 86; HandsY = 399; DropX = 650; DropY = 596; TimeX = 406; TimeY = 68 },
    @{ File = "utopian_inventory_1280x1024.xml"; RootY = 32; Width = 1280; Height = 960; PanelX = 40; PanelY = 80; PanelW = 1200; PanelH = 800; PhotoX = 75; PhotoY = 230; PhotoW = 405; PhotoH = 623; GridX = 600; GridY = 310; Step = 64; Columns = 8; Slots = 40; MoneyX = 1100; MoneyY = 770; WeaponX = 395; WeaponY = 550; FeetX = 270; FeetY = 740; HeadX = 270; HeadY = 240; BodyX = 270; BodyY = 428; HandsX = 125; HandsY = 500; DropX = 806; DropY = 685; TimeX = 534; TimeY = 87 },
    @{ File = "utopian_inventory_1920x1080.xml"; Width = 1920; Height = 1080; PanelX = 360; PanelY = 140; PanelW = 1200; PanelH = 800; PhotoX = 395; PhotoY = 290; PhotoW = 405; PhotoH = 623; GridX = 920; GridY = 370; Step = 64; Columns = 8; Slots = 40; MoneyX = 1420; MoneyY = 830; WeaponX = 715; WeaponY = 610; FeetX = 590; FeetY = 800; HeadX = 590; HeadY = 300; BodyX = 590; BodyY = 488; HandsX = 445; HandsY = 560; DropX = 1126; DropY = 745; TimeX = 854; TimeY = 147 }
)

function Add-Line([System.Text.StringBuilder]$Builder, [string]$Line) {
    [void]$Builder.AppendLine($Line)
}

function Add-Frame([System.Text.StringBuilder]$Builder, $Layout) {
    Add-Line $Builder "  <form name=`"panel_background`" x=`"$($Layout.PanelX)`" y=`"$($Layout.PanelY)`" w=`"$($Layout.PanelW)`" h=`"$($Layout.PanelH)`" script=`"utopian_inventory_background.bin`">"
    Add-Line $Builder "  </form>"
}

function Add-InventorySlot([System.Text.StringBuilder]$Builder, [int]$Number, [int]$X, [int]$Y) {
    $name = "slot{0:D2}" -f $Number
    Add-Line $Builder "  <form name=`"$name`" x=`"$X`" y=`"$Y`" w=`"52`" h=`"52`" script=`"utopian_inv_slot.bin`">"
    Add-Line $Builder '    <image name="default" x="0" y="0" w="1" h="1">ui/utopian_slot_black.png</image>'
    Add-Line $Builder '    <image name="selected" x="0" y="0" w="1" h="1">ui/utopian_slot_black.png</image>'
    Add-Line $Builder '    <image name="disabled" x="0" y="0" w="1" h="1">ui/utopian_slot_black.png</image>'
    Add-Line $Builder '    <image name="target" x="0" y="0" w="1" h="1">ui/utopian_slot_target.png</image>'
    Add-Line $Builder '    <font name="default" size="8" face="fritz_quadrata" />'
    Add-Line $Builder "  </form>"
}

function Add-EquipSlot([System.Text.StringBuilder]$Builder, [string]$Name, [int]$X, [int]$Y) {
    Add-Line $Builder "  <form name=`"$Name`" x=`"$X`" y=`"$Y`" w=`"52`" h=`"52`" script=`"utopian_equip_slot.bin`">"
    Add-Line $Builder '    <image name="default" x="0" y="0" w="1" h="1">ui/utopian_slot_black.png</image>'
    Add-Line $Builder '    <image name="target" x="0" y="0" w="1" h="1">ui/utopian_slot_target.png</image>'
    Add-Line $Builder '    <font name="default" size="8" face="fritz_quadrata" />'
    Add-Line $Builder "  </form>"
}

foreach ($layout in $layouts) {
    $builder = [System.Text.StringBuilder]::new()
    $rootX = if ($layout.ContainsKey("RootX")) { $layout.RootX } else { 0 }
    $rootY = if ($layout.ContainsKey("RootY")) { $layout.RootY } else { 0 }
    Add-Line $builder "<form name=`"utopian_inventory`" x=`"$rootX`" y=`"$rootY`" w=`"$($layout.Width)`" h=`"$($layout.Height)`" script=`"utopian_inventory.bin`">"
    Add-Frame $builder $layout
    Add-Line $builder "  <form name=`"time`" x=`"$($layout.TimeX)`" y=`"$($layout.TimeY)`" w=`"213`" h=`"24`" script=`"ui_inventory_time.bin`">"
    Add-Line $builder '    <image name="default" x="0" y="0" w="1" h="1">ui/utopian_slot_black.png</image>'
    Add-Line $builder '    <font name="default" size="14" face="fritz_quadrata" />'
    Add-Line $builder "  </form>"
    Add-Line $builder "  <form name=`"character_doll`" x=`"$($layout.PhotoX)`" y=`"$($layout.PhotoY)`" w=`"$($layout.PhotoW)`" h=`"$($layout.PhotoH)`" script=`"utopian_character_doll.bin`">"
    Add-Line $builder "  </form>"

    Add-EquipSlot $builder "equip_head" $layout.HeadX $layout.HeadY
    Add-EquipSlot $builder "equip_body" $layout.BodyX $layout.BodyY
    Add-EquipSlot $builder "equip_hands" $layout.HandsX $layout.HandsY
    Add-EquipSlot $builder "equip_feet" $layout.FeetX $layout.FeetY
    Add-EquipSlot $builder "equip_weapon" $layout.WeaponX $layout.WeaponY

    Add-Line $builder "  <form name=`"money`" x=`"$($layout.MoneyX)`" y=`"$($layout.MoneyY)`" w=`"52`" h=`"52`" script=`"utopian_money_slot.bin`">"
    Add-Line $builder '    <image name="default" x="0" y="0" w="1" h="1">ui/utopian_slot_black.png</image>'
    Add-Line $builder '    <font name="default" size="8" face="fritz_quadrata" />'
    Add-Line $builder "  </form>"

    for ($slot = 0; $slot -lt $layout.Slots; $slot++) {
        $column = $slot % $layout.Columns
        $row = [Math]::Floor($slot / $layout.Columns)
        Add-InventorySlot $builder ($slot + 1) ($layout.GridX + $column * $layout.Step) ($layout.GridY + $row * $layout.Step)
    }

    Add-Line $builder "  <form name=`"drop_slot`" x=`"$($layout.DropX)`" y=`"$($layout.DropY)`" w=`"52`" h=`"52`" script=`"utopian_drop_slot.bin`">"
    Add-Line $builder '    <image name="default" x="0" y="0" w="1" h="1">ui/utopian_slot_black.png</image>'
    Add-Line $builder '    <image name="target" x="0" y="0" w="1" h="1">ui/utopian_slot_target.png</image>'
    Add-Line $builder '    <font name="default" size="8" face="fritz_quadrata" />'
    Add-Line $builder "  </form>"

    Add-Line $builder '  <cursor name="default" script="ui_tooltip_cursor.bin" w="32" h="32">'
    Add-Line $builder '    <image name="default" x="0" y="0" w="1" h="1">ui/ui_cursor.tga</image>'
    Add-Line $builder '    <image name="border" x="0" y="0" w="1" h="1">ui/ui_tooltip_border.png</image>'
    Add-Line $builder '    <image name="bg" x="0" y="0" w="1" h="1">ui/ui_tooltip_bg.png</image>'
    Add-Line $builder '    <font name="default" size="10" face="fritz_quadrata" />'
    Add-Line $builder '    <font name="big" size="12" face="fritz_quadrata" />'
    Add-Line $builder "  </cursor>"
    Add-Line $builder '  <cursor name="drag_item" script="utopian_drag_cursor.bin" w="64" h="64">'
    Add-Line $builder '    <image name="default" x="0" y="0" w="0.5" h="0.5">ui/ui_cursor_drag.tga</image>'
    Add-Line $builder "  </cursor>"
    Add-Line $builder "</form>"

    $target = Join-Path (Join-Path $PSScriptRoot "..\resources\ui") $layout.File
    [System.IO.File]::WriteAllText($target, $builder.ToString(), [System.Text.UTF8Encoding]::new($false))
    Write-Host "generated $target"
}
