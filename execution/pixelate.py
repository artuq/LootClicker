#!/usr/bin/env python3
"""
pixelate.py — wstrzykuje "pixel-art mix" w gładkie sprite'y z AI (Stardew/Cult of the Lamb vibe).

Mechanizm: downscale NEAREST do niskiej rozdzielczości "pixeli" + kwantyzacja palety
(flat shading) → upscale NEAREST z powrotem do rozmiaru docelowego (twarde, czytelne bloki).
Zakłada że wejście jest już znormalizowane (kwadrat, postać ~88%, przezroczyste tło).

Użycie:
    python execution/pixelate.py <plik_lub_folder> [--res 110] [--colors 32] [--out 384]
    # boss: --res 150 --out 512

Domyślnie: nadpisuje plik wejściowy (rób kopię / git przed!).
"""
import sys, os, argparse
from PIL import Image


def pixelate(img: Image.Image, pixel_res: int, colors: int, out_size: int) -> Image.Image:
    img = img.convert("RGBA")
    # 1) downscale do "siatki pikseli" (NEAREST = twarde krawędzie)
    small = img.resize((pixel_res, pixel_res), Image.NEAREST)
    # 2) kwantyzacja palety na RGB (flat shading), alpha zachowana osobno
    if colors and colors > 0:
        a = small.getchannel("A")
        rgb = small.convert("RGB").quantize(colors=colors, method=Image.FASTOCTREE).convert("RGB")
        small = Image.merge("RGBA", (*rgb.split(), a))
    # 3) wyczyść półprzezroczyste krawędzie (twardy alpha — pixel-art nie ma AA)
    a = small.getchannel("A").point(lambda v: 255 if v >= 128 else 0)
    small.putalpha(a)
    # 4) upscale NEAREST do rozmiaru docelowego (chunky pixele)
    return small.resize((out_size, out_size), Image.NEAREST)


def process_file(path: str, res: int, colors: int, out: int):
    img = Image.open(path)
    result = pixelate(img, res, colors, out)
    result.save(path)
    print(f"  ✓ {os.path.basename(path)}  → pixel_res={res}, colors={colors}, out={out}")


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("target", help="plik PNG albo folder")
    ap.add_argument("--res", type=int, default=110, help="rozdzielczość 'pikseli' (mniej = bardziej pixel-art). Wróg ~110, boss ~150")
    ap.add_argument("--colors", type=int, default=32, help="liczba kolorów w palecie (mniej = mocniejszy flat-shading)")
    ap.add_argument("--out", type=int, default=384, help="rozmiar wyjściowy px (wróg 384, boss 512)")
    args = ap.parse_args()

    if os.path.isdir(args.target):
        pngs = [os.path.join(args.target, f) for f in sorted(os.listdir(args.target)) if f.lower().endswith(".png")]
        print(f"Pikselizacja {len(pngs)} plików w {args.target}:")
        for p in pngs:
            process_file(p, args.res, args.colors, args.out)
    else:
        process_file(args.target, args.res, args.colors, args.out)
    print("Gotowe.")


if __name__ == "__main__":
    main()
