# Glossary

Canonical terms used throughout the codebase, tests, and documentation.

---

**brick**
A single rectangular element in the output SVG, representing one LEGO-like
brick. Rendered as `<rect width=blkW height=blkH>` in the brick-art output.

**skin tone**
One of the four face-fill colors used in the logo variants:
Yellow (`#F2CD37`), Light Nougat (`#F6D7B3`), Nougat (`#CC8E69`),
Dark Nougat (`#AD6140`). Defined in `Brand.Colors.skinTones`.

**design variant**
One of the 19 intermediate SVG files written to `design/` by `Logo.Designs`.
Named by stem: `square`, `square-light-nougat`, `horizontal`, `horizontal-rot1`,
`minifig-colorful`, `minifig-rainbow`, `horizontal-rainbow`, etc.

**blockify**
The process of rasterizing a design SVG at low pixel width (`sqPx` or `hzPx`),
then emitting one `<rect>` per opaque pixel to create a brick-art SVG.
Implemented in `Logo.Blockify`.

**stud**
The circular or rectangular bump on the top face of a LEGO brick. In the
Python pipeline the brick SVG included stud geometry; the Haskell pipeline
uses plain `<rect>` elements.

**face color**
The fill color of the minifig head face path in `source.svg`.
The source file uses `#f8c70b` (defined as `Brand.Colors.headSvgFaceColor`).
`Logo.Designs` replaces this value with a skin tone or band color.

**band**
A horizontal stripe in the `minifig-colorful` or `minifig-rainbow` design
variant. Each band spans the full viewBox width and is clipped to the face
path via an SVG `clipPath`.

**rainbow rotation**
One step in the 7-frame rainbow animation where the sliding window of 4
rainbow colors advances by one position in the 7-color `rainbowColors` list.

**h_pitch / v_pitch**
Horizontal and vertical spacing between brick centers in the output SVG.
With `blkW=24`, `blkH=20`: `h_pitch = blkW / 2 = 12`, `v_pitch = 15` (derived
from stud geometry — see `Logo.Blockify`). Used for aspect-ratio correction.

**aspect-ratio correction**
Scaling the rasterized image height by `h_pitch / v_pitch` (≈ 12/15) before
sampling, so that a square source SVG produces a visually square brick output.
