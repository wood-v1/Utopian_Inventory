from pathlib import Path

from PIL import Image


UI_DIR = Path(__file__).resolve().parent.parent / "resources" / "ui"
IMAGE_DIR = Path(__file__).resolve().parent.parent / "resources" / "image"
CHARACTERS = ("bachelor", "haruspex", "clara")
ATLAS_SIZE = (512, 1024)
DOLL_VISIBLE_SIZE = (410, 650)
DOLL_GAME_SIZE = (205, 325)
BACKGROUND_SOURCE_SIZE = (1536, 1024)
BACKGROUND_GAME_SIZE = (800, 533)

Image.new("RGB", (64, 64), (0, 0, 0)).save(
    UI_DIR / "utopian_slot_black.png",
    format="PNG",
    optimize=True,
)


for character in CHARACTERS:
    source = UI_DIR / f"utopian_doll_{character}.png"
    target = UI_DIR / f"utopian_doll_{character}.tga"
    with Image.open(source) as image:
        rgba = image.convert("RGBA")
        if rgba.size != ATLAS_SIZE:
            raise RuntimeError(f"{source.name}: expected {ATLAS_SIZE}, got {rgba.size}")
        visible = rgba.crop((0, 0, DOLL_VISIBLE_SIZE[0], DOLL_VISIBLE_SIZE[1]))
        doll = visible.resize(DOLL_GAME_SIZE, Image.Resampling.LANCZOS)
        doll.save(target, format="TGA", compression="tga_rle")
    print(f"prepared {target.name}: 205x325 RGBA RLE TGA")


for character in CHARACTERS:
    source = IMAGE_DIR / f"{character}_inventory_bg.png"
    png_target = UI_DIR / f"utopian_inventory_bg_{character}.png"
    tga_target = UI_DIR / f"utopian_inventory_bg_{character}.tga"
    with Image.open(source) as image:
        rgba = image.convert("RGBA")
        if rgba.size != BACKGROUND_SOURCE_SIZE:
            raise RuntimeError(
                f"{source.name}: expected {BACKGROUND_SOURCE_SIZE}, got {rgba.size}"
            )
        background = rgba.resize(BACKGROUND_GAME_SIZE, Image.Resampling.LANCZOS)
        background.save(png_target, format="PNG", optimize=True)
        background.convert("RGB").save(
            tga_target,
            format="TGA",
            compression="tga_rle",
        )
    print(f"prepared {png_target.name}: 800x533 RGBA PNG")
    print(f"prepared {tga_target.name}: 800x533 RGB RLE TGA")
