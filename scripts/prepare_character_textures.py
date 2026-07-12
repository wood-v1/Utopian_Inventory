from pathlib import Path

from PIL import Image


UI_DIR = Path(__file__).resolve().parent.parent / "resources" / "ui"
CHARACTERS = ("bachelor", "haruspex", "clara")
ATLAS_SIZE = (512, 1024)


for character in CHARACTERS:
    source = UI_DIR / f"utopian_doll_{character}.png"
    target = UI_DIR / f"utopian_doll_{character}.tga"
    with Image.open(source) as image:
        rgba = image.convert("RGBA")
        if rgba.size != ATLAS_SIZE:
            raise RuntimeError(f"{source.name}: expected {ATLAS_SIZE}, got {rgba.size}")
        rgba.save(target, format="TGA", compression=None)
    print(f"prepared {target.name}: {ATLAS_SIZE[0]}x{ATLAS_SIZE[1]} RGBA TGA")
