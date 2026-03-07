# US-001: Rewrite build pipeline in Haskell

**Status:** In progress
**Priority:** High

---

## Story

As a contributor to the Suomen Palikkaharrastajat ry logo project,
I want the build pipeline to be a single compiled Haskell executable
(`cabal run logo-gen`) so that the pipeline is type-safe, fast, and
easy to test without a Python runtime.

---

## Acceptance criteria

- [ ] `cabal build` succeeds with GHC 9.6
- [ ] `cabal run logo-gen` produces the same set of output files as the Python pipeline:
  - 19 design SVGs in `design/`
  - All brick-art SVGs in `logo/square/svg/` and `logo/horizontal/svg/`
  - PNG + WebP rasters at 800px width for every SVG
  - Animated GIF + WebP for skin-tone and rainbow sequences
  - Favicon assets in `favicon/`
  - `brand.json` with the same schema as the current file
- [ ] `cabal test` passes (Brand.Colors, Logo.Designs, Logo.Blockify tests)
- [ ] `hlint src tests` produces no warnings
- [ ] The Makefile wraps `cabal run logo-gen` (targets: `build`, `run`, `test`, `check`, `clean`, `repl`, `watch`)
- [ ] `devenv.nix` provides the full Haskell toolchain (GHC 9.6, cabal, fourmolu, hlint, HLS)
  and external raster tools (`rsvg-convert`, `cwebp`, `img2webp`, `icotool`)
- [ ] Python scripts are deleted after output parity is verified

---

## Design notes

- Sequential pipeline, no Shake (matches planet's `Main.hs` pattern)
- External raster tools called via `System.Process` (`rsvg-convert`, `cwebp`, `img2webp`, `icotool`, `gifski`)
- `Brand.Colors` is the single source of truth for all brand constants
- Brick algorithm: rasterize SVG → correct aspect ratio (12/15) → one `<rect>` per opaque pixel
- `Logo.Compose`: appends subtitle text with `textLength=canvasW` and `lengthAdjust=spacingAndGlyphs`

---

## Related

- `TODO.md.example` — full implementation checklist
- `agents/adrs/ADR-0000-agent-guidance.md` — commit conventions
