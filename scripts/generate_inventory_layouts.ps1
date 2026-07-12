Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$layouts = @(
    @{ File = "utopian_inventory.xml"; Width = 800; Height = 600; PanelX = 28; PanelY = 45; PanelW = 744; PanelH = 510; PhotoX = 79; PhotoY = 105; PhotoW = 221; PhotoH = 350; GridX = 384; GridY = 150; Step = 58; Columns = 6; Slots = 24; MoneyX = 674; MoneyY = 82; WeaponX = 270; WeaponY = 315; FeetX = 167; FeetY = 405; HeadX = 167; HeadY = 110; BodyX = 167; BodyY = 235; HandsX = 66; HandsY = 260; DropX = 526; DropY = 410 },
    @{ File = "utopian_inventory_1024x768.xml"; Width = 1024; Height = 768; PanelX = 45; PanelY = 50; PanelW = 934; PanelH = 668; PhotoX = 90; PhotoY = 130; PhotoW = 309; PhotoH = 490; GridX = 500; GridY = 170; Step = 61; Columns = 7; Slots = 35; MoneyX = 866; MoneyY = 95; WeaponX = 360; WeaponY = 410; FeetX = 218; FeetY = 540; HeadX = 218; HeadY = 138; BodyX = 218; BodyY = 300; HandsX = 85; HandsY = 335; DropX = 682; DropY = 500 },
    @{ File = "utopian_inventory_1280x1024.xml"; Width = 1280; Height = 1024; PanelX = 70; PanelY = 70; PanelW = 1140; PanelH = 850; PhotoX = 115; PhotoY = 155; PhotoW = 410; PhotoH = 650; GridX = 640; GridY = 190; Step = 64; Columns = 8; Slots = 40; MoneyX = 1088; MoneyY = 115; WeaponX = 470; WeaponY = 520; FeetX = 294; FeetY = 720; HeadX = 294; HeadY = 165; BodyX = 294; BodyY = 360; HandsX = 125; HandsY = 415; DropX = 846; DropY = 555 }
)

function Add-Line([System.Text.StringBuilder]$Builder, [string]$Line) {
    [void]$Builder.AppendLine($Line)
}

function Add-Frame([System.Text.StringBuilder]$Builder, $Layout) {
    $right = $Layout.PanelX + $Layout.PanelW - 2
    $bottom = $Layout.PanelY + $Layout.PanelH - 2
    Add-Line $Builder "  <form name=`"panel_background`" x=`"$($Layout.PanelX)`" y=`"$($Layout.PanelY)`" w=`"$($Layout.PanelW)`" h=`"$($Layout.PanelH)`">"
    Add-Line $Builder '    <image name="default" x="0.00390625" y="0.828125" w="0.0625" h="0.125">ui/ui_group_7_1.tex</image>'
    Add-Line $Builder "  </form>"
    Add-Line $Builder "  <form name=`"frame_top`" x=`"$($Layout.PanelX)`" y=`"$($Layout.PanelY)`" w=`"$($Layout.PanelW)`" h=`"2`">"
    Add-Line $Builder '    <image name="default" x="0.71875" y="0.25" w="0.03125" h="0.5">ui/ui_group_3_1.tex</image>'
    Add-Line $Builder "  </form>"
    Add-Line $Builder "  <form name=`"frame_bottom`" x=`"$($Layout.PanelX)`" y=`"$bottom`" w=`"$($Layout.PanelW)`" h=`"2`">"
    Add-Line $Builder '    <image name="default" x="0.71875" y="0.25" w="0.03125" h="0.5">ui/ui_group_3_1.tex</image>'
    Add-Line $Builder "  </form>"
    Add-Line $Builder "  <form name=`"frame_left`" x=`"$($Layout.PanelX)`" y=`"$($Layout.PanelY)`" w=`"2`" h=`"$($Layout.PanelH)`">"
    Add-Line $Builder '    <image name="default" x="0.59375" y="0.25" w="0.0625" h="0.25">ui/ui_group_3_1.tex</image>'
    Add-Line $Builder "  </form>"
    Add-Line $Builder "  <form name=`"frame_right`" x=`"$right`" y=`"$($Layout.PanelY)`" w=`"2`" h=`"$($Layout.PanelH)`">"
    Add-Line $Builder '    <image name="default" x="0.59375" y="0.25" w="0.0625" h="0.25">ui/ui_group_3_1.tex</image>'
    Add-Line $Builder "  </form>"
}

function Add-InventorySlot([System.Text.StringBuilder]$Builder, [int]$Number, [int]$X, [int]$Y) {
    $name = "slot{0:D2}" -f $Number
    Add-Line $Builder "  <form name=`"$name`" x=`"$X`" y=`"$Y`" w=`"52`" h=`"52`" script=`"utopian_inv_slot.bin`">"
    Add-Line $Builder '    <image name="default" x="0" y="0" w="1" h="1">ui/ui_hud_item_slot.png</image>'
    Add-Line $Builder '    <image name="selected" x="0.015625" y="0.015625" w="0.8125" h="0.8125">ui/ui_group_1_3.tex</image>'
    Add-Line $Builder '    <image name="disabled" x="0" y="0" w="1" h="1">ui/ui_hud_item_slot.png</image>'
    Add-Line $Builder '    <image name="target" x="0.015625" y="0.015625" w="0.8125" h="0.8125">ui/ui_group_1_3.tex</image>'
    Add-Line $Builder '    <font name="default" size="8" face="fritz_quadrata" />'
    Add-Line $Builder "  </form>"
}

function Add-EquipSlot([System.Text.StringBuilder]$Builder, [string]$Name, [int]$X, [int]$Y) {
    Add-Line $Builder "  <form name=`"$Name`" x=`"$X`" y=`"$Y`" w=`"52`" h=`"52`" script=`"utopian_equip_slot.bin`">"
    Add-Line $Builder '    <image name="default" x="0" y="0" w="1" h="1">ui/ui_hud_item_slot.png</image>'
    Add-Line $Builder '    <image name="target" x="0.015625" y="0.015625" w="0.8125" h="0.8125">ui/ui_group_1_3.tex</image>'
    Add-Line $Builder '    <font name="default" size="8" face="fritz_quadrata" />'
    Add-Line $Builder "  </form>"
}

foreach ($layout in $layouts) {
    $builder = [System.Text.StringBuilder]::new()
    Add-Line $builder "<form name=`"utopian_inventory`" x=`"0`" y=`"0`" w=`"$($layout.Width)`" h=`"$($layout.Height)`" script=`"utopian_inventory.bin`">"
    Add-Frame $builder $layout
    Add-Line $builder "  <form name=`"character_doll`" x=`"$($layout.PhotoX)`" y=`"$($layout.PhotoY)`" w=`"$($layout.PhotoW)`" h=`"$($layout.PhotoH)`" script=`"utopian_character_doll.bin`">"
    Add-Line $builder '    <image name="bachelor" x="0" y="0" w="0.80078125" h="0.634765625">ui/utopian_doll_bachelor.png</image>'
    Add-Line $builder '    <image name="haruspex" x="0" y="0" w="0.80078125" h="0.634765625">ui/utopian_doll_haruspex.png</image>'
    Add-Line $builder '    <image name="clara" x="0" y="0" w="0.80078125" h="0.634765625">ui/utopian_doll_clara.png</image>'
    Add-Line $builder "  </form>"

    Add-EquipSlot $builder "equip_head" $layout.HeadX $layout.HeadY
    Add-EquipSlot $builder "equip_body" $layout.BodyX $layout.BodyY
    Add-EquipSlot $builder "equip_hands" $layout.HandsX $layout.HandsY
    Add-EquipSlot $builder "equip_feet" $layout.FeetX $layout.FeetY
    Add-EquipSlot $builder "equip_weapon" $layout.WeaponX $layout.WeaponY

    Add-Line $builder "  <form name=`"money`" x=`"$($layout.MoneyX)`" y=`"$($layout.MoneyY)`" w=`"52`" h=`"52`" script=`"utopian_money_slot.bin`">"
    Add-Line $builder '    <image name="default" x="0" y="0" w="1" h="1">ui/ui_hud_item_slot.png</image>'
    Add-Line $builder '    <font name="default" size="8" face="fritz_quadrata" />'
    Add-Line $builder "  </form>"

    for ($slot = 0; $slot -lt $layout.Slots; $slot++) {
        $column = $slot % $layout.Columns
        $row = [Math]::Floor($slot / $layout.Columns)
        Add-InventorySlot $builder ($slot + 1) ($layout.GridX + $column * $layout.Step) ($layout.GridY + $row * $layout.Step)
    }

    Add-Line $builder "  <form name=`"drop_slot`" x=`"$($layout.DropX)`" y=`"$($layout.DropY)`" w=`"52`" h=`"52`" script=`"utopian_drop_slot.bin`">"
    Add-Line $builder '    <image name="default" x="0" y="0" w="1" h="1">ui/ui_hud_item_slot.png</image>'
    Add-Line $builder '    <image name="target" x="0.015625" y="0.015625" w="0.8125" h="0.8125">ui/ui_group_1_3.tex</image>'
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
