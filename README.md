# Design Tokens Pipeline

Reads TOML definitions from `content/`, generates:

- **`dist/design-tokens.tokens.json`** — W3C Design Tokens (2025.10) compliant JSON
- **`dist/design-tokens-elm/`** — publishable Elm package with typed constants

## Prerequisites

[devenv](https://devenv.sh/) (provides GHC, Cabal, Elm tooling).

```bash
devenv shell
```

## Quick start

```bash
make build   # compile Haskell pipeline
make dist    # content/ TOML → dist/ (JSON + Elm package)
make test    # run test suite + hlint + elm-review
```

## Content directory (source of truth)

| File | Tokens |
|------|--------|
| `content/meta.toml` | Org metadata, version, canonical URL |
| `content/colors.toml` | Brand (3), skin-tone (4), rainbow (7), semantic (11) |
| `content/typography.toml` | Font family, 10 type-scale entries |
| `content/spacing.toml` | Base unit, 8 scale steps, 4 breakpoints, border radii |
| `content/motion.toml` | 3 durations, 3 cubic-bezier easings |
| `content/effects.toml` | 6 box shadows, 6 z-index layers |
| `content/accessibility.toml` | 3 focus ring tokens |
| `content/opacity.toml` | 9-step opacity scale |
| `content/components.toml` | 25 component → token-dependency mappings |

Edit any TOML file, then `make dist` to regenerate outputs.

## Output formats

### W3C Design Tokens JSON

`dist/design-tokens.tokens.json` follows the [W3C Design Tokens Community Group](https://design-tokens.github.io/community-group/format/) format with `$type`, `$value`, and `$description` keys.

### Elm package

`dist/design-tokens-elm/` is a self-contained Elm package (`palikkaharrastajat/design-tokens`) exposing:

- `DesignTokens` — version string
- `DesignTokens.Colors` — hex color strings
- `DesignTokens.Typography` — font family, sizes, weights, line heights
- `DesignTokens.Spacing` — spacing scale, breakpoints, border radii
- `DesignTokens.Motion` — durations (ms) and cubic-bezier easing records
- `DesignTokens.Effects` — box shadow CSS strings and z-index integers
- `DesignTokens.Accessibility` — focus ring width, offset, color, Tailwind class
- `DesignTokens.Opacity` — opacity scale (0–100)
- `DesignTokens.Components` — per-component token dependency lists

## Makefile targets

| Target | Description |
|--------|-------------|
| `make build` | Compile Haskell executables |
| `make dist` | Generate `dist/` from `content/` TOML |
| `make test` | Run test suite + `make check` |
| `make check` | hlint + elm-review on generated code |
| `make format` | Auto-format Haskell with fourmolu |
| `make clean` | Remove build artifacts and `dist/` |

## Project structure

```
content/          TOML source of truth
src/DesignTokensGen/
  Types.hs        ADTs for all token types
  Toml.hs         Multi-file TOML parser
  Json.hs         W3C DTCG JSON generator
  ElmGen.hs       Elm package generator
  Main.hs         Executable entry point
tests/            Tasty test suite
review/           elm-review config (3 LLM-friendly rules)
dist/             Generated output (gitignored)
```
