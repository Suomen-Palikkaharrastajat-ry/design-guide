#!/usr/bin/env python3
"""Rasterize SVG with cairosvg at 4× then downscale with PIL NEAREST + mode filter.

Usage: svg_rasterize.py <svg_path> <target_width>
Outputs: raw RGBA bytes (width * height * 4), preceded by a 2-line header:
  width\n
  height\n
"""
import sys
import cairosvg
import io
from PIL import Image


def mode_filter(img, kernel=3):
    """3×3 mode filter: replace each opaque pixel's colour with the dominant
    colour in its neighbourhood.  Matches brick_blockify.py _mode_filter."""
    img = img.convert('RGBA')
    pixels = img.load()
    w, h = img.size
    out = img.copy()
    out_px = out.load()
    half = kernel // 2
    for y in range(h):
        for x in range(w):
            if pixels[x, y][3] < 128:
                continue
            counts = {}
            for dy in range(-half, half + 1):
                for dx in range(-half, half + 1):
                    nx, ny = x + dx, y + dy
                    if 0 <= nx < w and 0 <= ny < h:
                        r2, g2, b2, a2 = pixels[nx, ny]
                        if a2 >= 128:
                            c = (r2, g2, b2)
                            counts[c] = counts.get(c, 0) + 1
            if counts:
                dominant = max(counts, key=counts.__getitem__)
                out_px[x, y] = dominant + (pixels[x, y][3],)
    return out


def main():
    if len(sys.argv) != 3:
        sys.stderr.write("Usage: svg_rasterize.py <svg_path> <target_width>\n")
        sys.exit(1)

    svg_path = sys.argv[1]
    target_w = int(sys.argv[2])

    with open(svg_path, 'rb') as f:
        svg_data = f.read()

    # Render at 4× resolution with cairosvg
    png_data = cairosvg.svg2png(bytestring=svg_data, output_width=target_w * 4)
    img4x = Image.open(io.BytesIO(png_data)).convert('RGBA')

    # Apply 3×3 mode filter (removes anti-aliasing artefacts)
    img4x = mode_filter(img4x, kernel=3)

    # Downscale to target width with PIL NEAREST (centre-of-pixel mapping)
    target_h = int(target_w * img4x.height / img4x.width)
    img = img4x.resize((target_w, target_h), Image.NEAREST)

    # Output: header then raw RGBA bytes
    w, h = img.size
    sys.stdout.buffer.write(("%d\n%d\n" % (w, h)).encode())
    sys.stdout.buffer.write(img.tobytes())  # raw RGBA, row-major


if __name__ == '__main__':
    main()
