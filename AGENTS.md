# Agent Guidance — Suomen Palikkaharrastajat ry Logo Generator

This file is the primary entry point for all AI agents working in this repository.
Read it fully before making any changes.

---

## 1. Source of truth & precedence

When sources conflict, resolve in this order (highest to lowest):

1. **Tests** — if a test asserts behaviour, the behaviour is correct
2. **ADRs** (`agents/adrs/`) — architectural decisions that have been accepted
3. **User stories** (`agents/stories/`) — feature requirements
4. **Source code comments** — local rationale
5. **This file** — general guidance

---

## 2. Agent self-guidance work loop

Before making any change:

1. Read `AGENTS.md` (this file) and the relevant user story in `agents/stories/`
2. Read the ADRs in `agents/adrs/` that apply to your task
3. Identify which source files are affected (see repository map below)
4. Run `cabal build` to confirm the project compiles before you start
5. Make the minimal change that satisfies the story / task
6. Add or update tests in `tests/` for any changed behaviour
7. Run `cabal test` and `hlint src tests` — both must pass
8. Commit with a Conventional Commit message (see ADR-0000)

---

## 3. Repository map

| Path | Purpose |
|------|---------|
| `source.svg` | Master vector head design (Inkscape); edit this to change the logo shape |
| `src/Brand/Colors.hs` | Single source of truth for all brand colors and constants |
| `src/Brand/Json.hs` | Generates `brand.json` (machine-readable brand manifest) |
| `src/Brand/ElmGen.hs` | Generates `elm-app/src/Brand/Generated.elm` (see TODO-2) |
| `src/Logo/Designs.hs` | SVG design generation — produces `design/` files from `source.svg` |
| `src/Logo/Blockify.hs` | Rasterize SVG → sample pixels → emit brick-art SVG |
| `src/Logo/Compose.hs` | Append subtitle text below brick SVG to produce `-full` variants |
| `src/Logo/Animate.hs` | Assemble PNG frames into animated GIF / WebP |
| `src/Logo/Raster.hs` | Export SVG → PNG / WebP via `rsvg-convert` / `cwebp` |
| `src/Logo/Favicons.hs` | Generate `favicon/` assets via `rsvg-convert` / `icotool` |
| `src/Main.hs` | Sequential pipeline entry point — calls all steps in order |
| `tests/` | `tasty` test suite; run with `cabal test` |
| `logo.cabal` | Build configuration (GHC 9.6, dependencies) |
| `Makefile` | Thin wrapper around `cabal run logo-gen` |
| `devenv.nix` | Reproducible dev environment (Haskell toolchain + external tools) |
| `fonts/` | Outfit variable font (OFL-1.1) |
| `agents/` | Glossary, ADRs, user stories |

Generated output directories (not committed):

| Path | Contents |
|------|---------|
| `design/` | Intermediate SVG designs (19 files) |
| `logo/square/svg/` | Brick-art square SVGs |
| `logo/square/png/` | PNG / WebP / GIF raster exports |
| `logo/horizontal/svg/` | Brick-art horizontal SVGs |
| `logo/horizontal/png/` | PNG / WebP / GIF raster exports |
| `favicon/` | Favicon assets |
| `brand.json` | Machine-readable brand manifest |

---

## 4. Change rules

- **No behaviour change without a test.** Add a test before or alongside any code change.
- **Conventional Commits** for all commit messages (see `agents/adrs/ADR-0000-agent-guidance.md`).
- **`Brand.Colors` is the single source of truth** for colors. Never hard-code a hex value in another module; import from `Brand.Colors`.
- **External tools** (`rsvg-convert`, `cwebp`, `img2webp`, `icotool`) are called via `System.Process`. Never add new binary dependencies without updating `devenv.nix`.
- **Do not commit generated files** (`design/`, `logo/`, `favicon/`, `brand.json`).
- **`TODO.md` is gitignored** (local working notes only). Committed reference: `TODO.md.example`.

---

## 5. Decision escalation rules

Escalate (ask the user) when:

- A change would modify the `brand.json` schema (field names, nesting, array order)
- A change would alter the set of output files or their naming convention
- A change requires a new external binary dependency
- A change removes or renames a public function in any `Brand.*` or `Logo.*` module
- Two ADRs conflict and there is no clear precedence
