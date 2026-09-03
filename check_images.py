import os
from PIL import Image

folder = "/Users/magda/Documents/GitHub/LootClicker/assets/sprites/enemies/frozen/"
files = [f for f in os.listdir(folder) if f.endswith(".png") or f.endswith(".jpg")]

for f in files:
    path = os.path.join(folder, f)
    with Image.open(path) as img:
        img = img.convert("RGBA")
        width, height = img.size
        # Count magenta-ish pixels
        magenta_count = 0
        pixels = img.load()
        for y in range(height):
            for x in range(width):
                r, g, b, a = pixels[x, y]
                if a > 0 and r > 200 and g < 100 and b > 200:
                    magenta_count += 1
        print(f"{f}: {width}x{height}, Magenta pixels: {magenta_count}")
