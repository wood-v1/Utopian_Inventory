from pathlib import Path

from PIL import Image, ImageChops, ImageOps


UI_DIR = Path(__file__).resolve().parent.parent / "resources" / "ui"
IMAGE_DIR = Path(__file__).resolve().parent.parent / "resources" / "image"
CHARACTERS = ("bachelor", "haruspex", "clara")
ATLAS_SIZE = (512, 1024)
DOLL_VISIBLE_SIZE = (410, 650)
DOLL_GAME_SIZE = (205, 325)
BACKGROUND_GAME_SIZE = (800, 533)
BACKGROUND_GAME_SIZE_OVERRIDES = {}
BACKGROUND_SOURCES = {
    # This source has the correct 3:2 composition, full-resolution details,
    # and no hanging hooks in the right inventory panel.
    "clara": "clara_inventory_bg.png",
}
LOOT_DOLL_SIZE = (205, 325)
LOOT_DOLLS = {
    "container": "container.png",
    "corpse": "doll.png",
}


def save_tex(image: Image.Image, target: Path, pixel_format: str) -> None:
    """Save a Pathologic .tex file (a DDS container with DXT compression)."""
    prepared = image.convert("RGBA" if pixel_format == "DXT5" else "RGB")
    prepared.save(target, format="DDS", pixel_format=pixel_format)
    print(
        f"prepared {target.name}: {prepared.width}x{prepared.height} "
        f"{pixel_format} TEX"
    )


save_tex(
    Image.new("RGB", (64, 64), (0, 0, 0)),
    UI_DIR / "inv_overhaul_slot_black.tex",
    "DXT1",
)
save_tex(
    Image.new("RGB", (64, 64), (0, 0, 0)),
    UI_DIR / "inv_overhaul_slot_empty.tex",
    "DXT1",
)
save_tex(
    Image.new("RGBA", (4, 4), (0, 0, 0, 0)),
    UI_DIR / "inv_overhaul_slot_transparent.tex",
    "DXT5",
)

for name in ("slot_occupied", "slot_target", "quickslot_help"):
    source = IMAGE_DIR / f"inv_overhaul_{name}_source.png"
    with Image.open(source) as image:
        save_tex(
            image.convert("RGBA"),
            UI_DIR / f"inv_overhaul_{name}.tex",
            "DXT5",
        )


for character in CHARACTERS:
    source = IMAGE_DIR / f"inv_overhaul_doll_{character}_source.png"
    target = UI_DIR / f"inv_overhaul_doll_{character}.tex"
    with Image.open(source) as image:
        rgba = image.convert("RGBA")
        if rgba.size != ATLAS_SIZE:
            raise RuntimeError(f"{source.name}: expected {ATLAS_SIZE}, got {rgba.size}")
        visible = rgba.crop((0, 0, DOLL_VISIBLE_SIZE[0], DOLL_VISIBLE_SIZE[1]))
        doll = visible.resize(DOLL_GAME_SIZE, Image.Resampling.LANCZOS)
        save_tex(doll, target, "DXT5")


for character in CHARACTERS:
    source = IMAGE_DIR / BACKGROUND_SOURCES.get(
        character,
        f"{character}_inventory_bg.png",
    )
    target = UI_DIR / f"inv_overhaul_inventory_bg_{character}.tex"
    with Image.open(source) as image:
        background = image.convert("RGB").resize(
            BACKGROUND_GAME_SIZE_OVERRIDES.get(character, BACKGROUND_GAME_SIZE),
            Image.Resampling.LANCZOS,
        )
        save_tex(background, target, "DXT1")


for kind, source_name in LOOT_DOLLS.items():
    source = IMAGE_DIR / source_name
    target = UI_DIR / f"inv_overhaul_loot_{kind}.tex"
    with Image.open(source) as image:
        rgba = image.convert("RGBA")
        source_alpha = rgba.getchannel("A")
        if source_alpha.getextrema() == (255, 255):
            # Supplied images contain a baked near-white/checkerboard
            # background. The subjects are dark, so a luminance matte removes
            # it while retaining antialiased edges.
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
        save_tex(prepared, target, "DXT5")
