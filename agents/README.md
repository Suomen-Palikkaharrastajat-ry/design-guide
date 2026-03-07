# agents/

Supporting documents for AI agents working in this repository.

## What this repository is

A Haskell build pipeline (`cabal run logo-gen`) that generates all logo assets for
**Suomen Palikkaharrastajat ry** from a single master SVG (`source.svg`) and brand
constants (`src/Brand/Colors.hs`).

Outputs: brick-art SVGs, PNG/WebP/GIF rasters, favicons, and `brand.json`.

## What this repository is not

- Not an Elm application (Elm codegen lives in TODO-2 / `Brand.ElmGen`)
- Not a web server
- Not a design tool — edit `source.svg` in Inkscape, then `make run`

## Directory contents

| File | Purpose |
|------|---------|
| `GLOSSARY.md` | Canonical terms used throughout the codebase |
| `adrs/` | Architecture Decision Records |
| `stories/` | User stories (feature requirements) |

## Quick start

```bash
make run        # build everything
make test       # run tests + hlint
make check      # hlint only
cabal repl      # interactive REPL
```
