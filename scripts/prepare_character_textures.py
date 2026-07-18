from pathlib import Path

from PIL import Image, ImageChops, ImageOps


UI_DIR = Path(__file__).resolve().parent.parent / "resources" / "ui"
IMAGE_DIR = Path(__file__).resolve().parent.parent / "resources" / "image"
CHARACTERS = ("bachelor", "haruspex", "clara")
ATLAS_SIZE = (512, 1024)
DOLL_VISIBLE_SIZE = (410, 650)
DOLL_GAME_SIZE = (205, 325)
BACKGROUND_SOURCE_SIZE = (1536, 1024)
BACKGROUND_GAME_SIZE = (800, 533)
LOOT_DOLL_SIZE = (205, 325)
LOOT_DOLLS = {
    "container": "container.png",
    "corpse": "doll.png",
}

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


for kind, source_name in LOOT_DOLLS.items():
    source = IMAGE_DIR / source_name
    png_target = UI_DIR / f"utopian_loot_{kind}.png"
    tga_target = UI_DIR / f"utopian_loot_{kind}.tga"
    with Image.open(source) as image:
        rgba = image.convert("RGBA")
        source_alpha = rgba.getchannel("A")
        if source_alpha.getextrema() == (255, 255):
            # The supplied PNGs contain a baked near-white/checkerboard
            # background rather than transparency. Both subjects are dark, so
            # a luminance matte removes it while retaining antialiased edges.
            luminance = ImageOps.grayscale(rgba)
            alpha_lut = []
            for value in range(256):
                if value >= 238:
                    alpha_lut.append(0)
                elif value <= 190:
                    alpha_lut.append(255)
                else:
                    alpha_lut.append((238 - value) * 255 // 48)
            extracted_alpha = luminance.point(alpha_lut)
            red, green, blue, unused_alpha = rgba.split()
            rgba = Image.merge(
                "RGBA",
                (
                    ImageChops.multiply(red, extracted_alpha),
                    ImageChops.multiply(green, extracted_alpha),
                    ImageChops.multiply(blue, extracted_alpha),
                    extracted_alpha,
                ),
            )
        alpha_bbox = rgba.getchannel("A").getbbox()
        if alpha_bbox is None:
            raise RuntimeError(f"{source.name}: image has no visible pixels")
        subject = rgba.crop(alpha_bbox)
        subject.thumbnail(LOOT_DOLL_SIZE, Image.Resampling.LANCZOS)
        prepared = Image.new("RGBA", LOOT_DOLL_SIZE, (0, 0, 0, 0))
        x = (LOOT_DOLL_SIZE[0] - subject.width) // 2
        y = (LOOT_DOLL_SIZE[1] - subject.height) // 2
        prepared.alpha_composite(subject, (x, y))
        red, green, blue, alpha = prepared.split()
        prepared = Image.merge(
            "RGBA",
            (
                ImageChops.multiply(red, alpha),
                ImageChops.multiply(green, alpha),
                ImageChops.multiply(blue, alpha),
                alpha,
            ),
        )
        prepared.save(png_target, format="PNG", optimize=True)
        # The legacy UI.dll RLE decoder crashes on some transparent pixel runs
        # before the form script is initialized. These two small overlays are
        # stored as plain type-2 RGBA TGA for deterministic loading.
        prepared.save(tga_target, format="TGA")
    print(f"prepared {png_target.name}: 205x325 RGBA PNG")
    print(f"prepared {tga_target.name}: 205x325 RGBA uncompressed TGA")
