#!/usr/bin/env python3
"""Rasterize SVG to PNG at given width using cairosvg.
Usage: svg_to_png.py <svg_path> <png_path> <width>
"""
import sys
import os
import glob
import tempfile

# ── Font setup ────────────────────────────────────────────────────────────────
# Fontconfig has no default config in this Nix environment, so Pango can't find
# "Outfit" by name and falls back to a different font. We write a minimal config
# that adds our fonts/ dir and set FONTCONFIG_FILE *before* importing cairosvg,
# ensuring fontconfig is initialised with the right search path.

def _setup_fontconfig():
    fonts_dir = os.path.abspath("fonts")
    # Also include any Nix-store font dirs that fontconfig already knows about
    # (e.g. DejaVu), so fallback fonts still work.
    nix_font_dirs = sorted(glob.glob("/nix/store/*/share/fonts"))
    extra = "".join(f"  <dir>{d}</dir>\n" for d in nix_font_dirs)
    conf = (
        '<?xml version="1.0"?>\n'
        "<fontconfig>\n"
        f"  <dir>{fonts_dir}</dir>\n"
        f"{extra}"
        "</fontconfig>\n"
    )
    f = tempfile.NamedTemporaryFile(
        mode="w", suffix=".conf", delete=False, prefix="logo_fc_"
    )
    f.write(conf)
    f.close()
    os.environ["FONTCONFIG_FILE"] = f.name
    return f.name

_conf = _setup_fontconfig()

# Import cairosvg only after FONTCONFIG_FILE is set
import cairosvg  # noqa: E402

svg_path, png_path, width = sys.argv[1], sys.argv[2], int(sys.argv[3])
cairosvg.svg2png(url=svg_path, write_to=png_path, output_width=width)

os.unlink(_conf)
