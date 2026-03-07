# ADR-0000: Agent guidance conventions

**Status:** Accepted
**Date:** 2026-03-07

---

## Context

We need a consistent way for AI agents and human contributors to communicate
changes in this repository. Clear conventions reduce noise and make history
readable.

---

## Decision

All commits use **Conventional Commits** format:

```
<type>[scope]: <description>
```

Rules:
- Maximum 72 characters per line in subject
- Imperative mood, lowercase subject (`add`, not `Add` or `Added`)
- No period at end of subject

### Types

| Type | When to use |
|------|-------------|
| `feat` | New feature visible to users or consumers of `brand.json` |
| `fix` | Bug fix |
| `docs` | Documentation only |
| `style` | Formatting, whitespace (no logic change) |
| `refactor` | Code restructuring without behaviour change |
| `perf` | Performance improvement |
| `test` | Adding or fixing tests |
| `build` | Changes to `logo.cabal`, `devenv.nix`, `Makefile`, `stack.yaml` |
| `ci` | CI configuration |
| `chore` | Maintenance tasks that don't fit other categories |
| `revert` | Reverts a previous commit |

### Scope (optional)

Use a scope to indicate the affected module:

- `brand` — `Brand.*` modules
- `designs` — `Logo.Designs`
- `blockify` — `Logo.Blockify`
- `compose` — `Logo.Compose`
- `raster` — `Logo.Raster`
- `animate` — `Logo.Animate`
- `favicons` — `Logo.Favicons`
- `json` — `Brand.Json` / `brand.json` schema
- `deps` — dependency changes

### Examples

```
feat(designs): add horizontal-rainbow-full-dark variant
fix(blockify): correct aspect ratio for non-square inputs
build(deps): add aeson-pretty ^0.8
docs: update AGENTS.md repository map
test(brand): add hex format validation for rainbowColors
```

---

## Consequences

- History is machine-readable and searchable by type
- Agents can filter relevant commits when researching a bug
- Changelog generation is straightforward
