# Agent instructions

## Build commands

All build commands must be run inside the devenv shell:

```
devenv shell -- make build
devenv shell -- make dist
devenv shell -- make test
devenv shell -- make check
devenv shell -- make format
```

Do **not** use `npx`, bare `elm`, or bare `cabal` — they are not on PATH outside devenv.

## Project overview

Pure design token pipeline for Suomen Palikkaharrastajat ry (Finnish LEGO enthusiast org).
Reads TOML token definitions from `content/`, generates:
- `dist/design-tokens.tokens.json` — W3C Design Tokens 2025.10 compliant JSON
- `dist/design-tokens-elm/` — publishable Elm package with typed constants
- `dist/design-tokens.css` — Tailwind v4 stylesheet fragment (@theme + @utility blocks)

Key directories:
- `content/` — TOML source of truth (9 files)
- `src/DesignTokensGen/` — Haskell pipeline: Types, Toml, Json, ElmGen, CssGen, Main
- `tests/` — Tasty test suite
- `review/` — elm-review config; the shared LlmAgent rules live in master-builder (fetched into gitignored `review/vendor/`)
- `reference/` — LEGO color catalog (`allowed-colors.csv`) that the brand color tokens derive from

## Content directory

| File | Tokens |
|------|--------|
| `content/meta.toml` | Org metadata, version, canonical URL |
| `content/colors.toml` | Brand (5), skin-tones (4), rainbow (7), semantic (11) |
| `content/typography.toml` | Font family, 10 type scale entries |
| `content/spacing.toml` | Base unit, 8 scale steps, 4 breakpoints, border radii |
| `content/motion.toml` | 3 durations, 3 easings |
| `content/effects.toml` | 6 box shadows, 6 z-index layers |
| `content/accessibility.toml` | 3 focus ring tokens |
| `content/opacity.toml` | 9-step opacity scale |
| `content/components.toml` | 25 component token mappings |

## Haskell pipeline modules

| Module | Purpose |
|--------|---------|
| `DesignTokensGen.Types` | ADTs for all token types |
| `DesignTokensGen.Toml` | Multi-file TOML parser (`parseContentDir`) |
| `DesignTokensGen.Json` | W3C DTCG JSON generator (`generateJson`) |
| `DesignTokensGen.ElmGen` | Elm package generator (`generateElmPackage`) |
| `DesignTokensGen.CssGen` | Tailwind v4 CSS generator (`generateCss`) |
| `DesignTokensGen.Main` | Executable entry point |

## Makefile key targets

| Target | Description |
|--------|-------------|
| `make build` | Compile Haskell executables |
| `make dist` | Run design-tokens-gen: content/ TOML → dist/ JSON + Elm + CSS |
| `make test` | Run test suite + `make check` |
| `make check` | hlint + elm-review on generated code |
| `make format` | Auto-format Haskell with fourmolu |
| `make clean` | Remove build artifacts and dist/ |

## Design tokens output

- `dist/design-tokens.tokens.json` — W3C DTCG 2025.10: `$type`, `$value`, `$description`
- `dist/design-tokens-elm/` — Elm package (type=package, exposed modules under `DesignTokens.*`)
- `dist/design-tokens.css` — Tailwind v4 CSS fragment (@theme + @utility classes)

The `@theme` block deliberately omits border radii, shadows, breakpoints and
`--font-mono`. Tailwind has defaults under the same variable names, so emitting
them would restyle every `rounded-*`, `shadow-*` and responsive utility in the
consumer apps. Do not add them back; they stay available in the JSON and Elm outputs.

## elm-review

Three shared rules from master-builder's `review/src/LlmAgent/` (single source of truth, fetched by `make check` into `review/vendor/`) enforce LLM-friendly generated code:
- `NoExposingEverything` — require explicit export lists
- `RequireModuleDoc` — require module documentation comments
- `RequireTypeAnnotation` — require type annotations on all top-level values

Run: `make check` (after `make dist` to ensure dist/ exists).

## Git / commit rules

- Do **not** commit `TODO.md` or any `TODO-*.md` files
- `content/*.toml` files ARE committed (source of truth)
- `dist/` is gitignored (generated build output)
- `review/elm-stuff/` and `review/vendor/` are gitignored (`review/vendor/` is the fetched master-builder checkout)
