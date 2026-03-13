# Suomen Palikkaharrastajat ry — Brändiohjeistus

Brand assets and design guide for Suomen Palikkaharrastajat ry. The logo mark
is a LEGO minifig head rendered as brick art. A full Finnish-language design
guide is served at [logo.palikkaharrastajat.fi](https://logo.palikkaharrastajat.fi).

## Brand Colors

| Color | Hex |
|-------|-----|
| **LEGO Yellow** | `#F2CD37` |
| **LEGO Black** | `#05131D` |
| **LEGO White** | `#FFFFFF` |
| Light Nougat | `#F6D7B3` |
| Nougat | `#D09168` |
| Dark Nougat | `#AD6140` |

## Quick start

```bash
devenv shell           # enter the Nix dev environment (GHC + Elm + Node.js)
make install           # npm install (once after checkout)
make build             # compile all Haskell executables
make render            # generate logo/, favicon/, design-guide.json
make dev               # render → copy assets → elm-pages dev server
```

## Makefile targets

| Target | What it does |
|--------|-------------|
| `make all` | `render` → `assets` → `elm-pages build` → `dist/` |
| `make build` | Compile all Haskell executables (no output generated) |
| `make blay-compose-all` | Derive all `.blay` files from masters (commit outputs) |
| `make render` | Render all `.blay` files → `logo/`, `favicon/`, `design-guide.json` |
| `make assets` | `render` + copy generated assets into `public/` |
| `make dev` | `assets` + `elm-pages dev` (hot-reload dev server) |
| `make site` | `assets` + `elm-pages build` → `dist/` (production) |
| `make deploy` | `git push origin main` (triggers GitHub Actions) |
| `make install` | `npm install` |
| `make test` | `cabal test` + `hlint` |
| `make check` | `hlint src tests` only |
| `make format` | `elm-format` on hand-written Elm sources |
| `make outline-text` | Convert subtitle text to paths in composed SVGs |
| `make watch` | Re-run `render` on `.hs`/`.cabal` changes (requires `entr`) |
| `make watch-elm` | `elm-pages dev` only (assets already in `public/`) |
| `make clean` | Remove all generated files and build artifacts |

## Pipeline

The asset pipeline is driven by five Haskell executables and GNU Make.
All color and text constants live in the Makefile — no Haskell rebuild is
required when changing them.

```
master SVGs —blay-draft—► layout/smile-xx.blay … layout/smile-xx.blay
                                      │
                              blay-compose
                                      │
                      ┌───────────────┼───────────────────┐
                      │               │                       │
              layout/square*.blay  layout/horizontal*.blay  layout/horizontal-rainbow*.blay
                      │               │                       │
                  blay-render     blay-render             blay-render
                      │               │                       │
              logo/square/        logo/horizontal/        logo/horizontal/
                svg/ png/           svg/ png/               svg/ png/
              (plain + favicon)   (plain + subtitle        (plain + subtitle
                                   light + dark)            light + dark)
                      │               │                       │
                  blay-animate    blay-animate            blay-animate
                      │               │                       │
              *-animated.{gif,webp}  *-animated.{gif,webp}  *-animated.{gif,webp}

brand-gen —► design-guide.json, design-guide/*.jsonld, src/Brand/Tokens.elm
```

### Step 1 — Draft master blays (manual, once per design)

```bash
cabal run blay-draft -- --source block-head.svg --output layout/block-head.blay
```

Each master `.blay` uses a placeholder face color (`F2CD37`) that is swapped
out in the next step.

### Step 2 — Derive `.blay` files

```bash
make blay-compose-all   # writes all 15 derived .blay files; commit them
```

`blay-compose --input FILE[:FROM:TO]` recolors and/or tiles blay files.
The derived blays are committed to the repo so CI can render without running
this step.

### Step 3 — Render

```bash
make render
```

`blay-render --input STEM.blay` produces all output formats in a single run:

- Plain SVG + PNG + WebP
- Subtitle-composed SVG + PNG + WebP (light background)
- Subtitle-composed SVG + PNG + WebP (dark background)
- Favicons (`favicon/`) when given `--favicon-dir`

### Step 4 — Animate

`blay-animate --input FRAME.png [--input …] --gif-out … --webp-out …` assembles
pre-rendered PNG frames into animated GIF and WebP. Called automatically by
`make render`.

### Step 5 — Brand assets

`brand-gen` generates `design-guide.json`, `design-guide/*.jsonld`, and
`src/Brand/Tokens.elm` from `Brand.Colors`. Called automatically by
`make render`.

## Executables

| Executable | Source | Purpose |
|------------|--------|---------|
| `blay-draft` | `app/Draft.hs` | Convert source SVG → `.blay` master |
| `blay-compose` | `app/Compose.hs` | Recolour and/or tile `.blay` files |
| `blay-render` | `app/Main.hs` | `.blay` → SVG + PNG + WebP + composed variants + favicons |
| `blay-animate` | `app/Animate.hs` | PNG frames → animated GIF + WebP |
| `brand-gen` | `app/BrandGen.hs` | Design-guide JSON + JSON-LD + Elm tokens |

## Source layout

| Path | Purpose |
|------|---------|
| `app/Draft.hs` | `blay-draft` entry point |
| `app/Compose.hs` | `blay-compose` entry point |
| `app/Main.hs` | `blay-render` entry point |
| `app/Animate.hs` | `blay-animate` entry point |
| `app/BrandGen.hs` | `brand-gen` entry point |
| `src/Brand/Colors.hs` | Brand colors (single source of truth) |
| `src/Brand/DesignData.hs` | Aggregated design data |
| `src/Brand/ElmGen.hs` | Generates `src/Brand/Tokens.elm` |
| `src/Brand/Json.hs` | Generates `design-guide.json` |
| `src/Brand/JsonLd.hs` | Generates `design-guide/*.jsonld` |
| `src/Logo/BrickLayout.hs` | `.blay` format parser and renderer |
| `src/Logo/Blockify.hs` | SVG → brick-art SVG |
| `src/Logo/Compose.hs` | Appends subtitle text to brick SVG |
| `src/Logo/Raster.hs` | SVG → PNG / WebP via rsvg-convert + cwebp |
| `src/Logo/Animate.hs` | Animated GIF / WebP helpers |
| `src/Logo/Favicons.hs` | Favicon generation |
| `layout/` | Master and derived `.blay` files |
| `app/` (Elm) | elm-pages route modules |
| `public/` | Static assets for elm-pages |
| `fonts/` | Outfit variable font (SIL OFL 1.1) |
| `scripts/` | `svg_rasterize.py`, `text_to_path.py` |

## Layout files

| File | Description |
|------|-------------|
| `layout/smile-01.blay` … `layout/smile-04.blay` | Master blays (placeholder face color `F2CD37`) |
| `layout/square-01.blay` | Yellow square logo |
| `layout/square-01.blay` | Light-nougat square |
| `layout/square-02.blay` | Nougat square |
| `layout/square-04.blay` | Dark-nougat square |
| `layout/horizontal.blay` | Four-face horizontal logo (skin tones) |
| `layout/horizontal-rot{1-3}.blay` | Rotated skin-tone variants |
| `layout/horizontal-rainbow.blay` | Rainbow horizontal (4-of-7 sliding window) |
| `layout/horizontal-rainbow-rot{1-6}.blay` | Rainbow rotations |

## Configuration

All colors and dimensions are Makefile variables — edit the top of the
`Makefile` to change them without recompiling:

```makefile
FONT_PATH := fonts/Outfit-VariableFont_wght.ttf
SUBTITLE  := Suomen Palikkaharrastajat ry
RASTER_W  := 800          # output PNG/WebP width in pixels
TXT_SIZE  := 63           # subtitle font size (SVG units)
ANIM_MS   := 10000        # animation loop duration in ms

SUBTITLE_LIGHT := 05131D  # subtitle colour on light background
SUBTITLE_DARK  := FFFFFF  # subtitle colour on dark background

FACE_PH           := F2CD37   # placeholder color in masters
SKIN_YELLOW       := F2CD37
SKIN_LIGHT_NOUGAT := F6D7B3
SKIN_NOUGAT       := D09168
SKIN_DARK_NOUGAT  := AD6140
```

## Requirements

Provided by `devenv.nix`:

- GHC 9.6 + Cabal
- rsvg-convert (librsvg)
- cwebp, img2webp (libwebp)
- gifski
- icotool (icoutils)
- Node.js + npm
- elm, elm-format, elm-json

## Fonts

Outfit variable font (SIL Open Font License 1.1) — `fonts/`.
