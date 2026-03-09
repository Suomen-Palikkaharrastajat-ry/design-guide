.PHONY: help all build run assets site dev dev-watch deploy install test check format clean watch watch-elm repl develop shell

# When elm-pages comes from the Nix store the wrapper does not include the
# package's own node_modules/.bin (elm-optimize-level-2, etc.) in PATH.
# Detect the store root from the resolved elm-pages binary and prepend it.
_ELM_PAGES_BIN  := $(shell which elm-pages 2>/dev/null)
_ELM_PAGES_ROOT := $(shell readlink -f $(_ELM_PAGES_BIN) 2>/dev/null | xargs -I{} dirname {} | xargs -I{} dirname {} 2>/dev/null)
ifneq ($(_ELM_PAGES_ROOT),)
export PATH := $(_ELM_PAGES_ROOT)/lib/node_modules/.bin:$(PATH)
endif

# ── Pipeline constants ────────────────────────────────────────────────────────
# These are the single documented source of truth for all tunable parameters.
# Changing any value here invalidates logo/.stamp and triggers regeneration.
# They are forwarded verbatim as CLI flags to logo-gen, so no Haskell rebuild
# is needed when you change them.

SOURCE_SVG   := source.svg
FONT_PATH    := fonts/Outfit-VariableFont_wght.ttf

SQ_PX        := 14          # Square blockify target raster width (px)
HZ_PX        := 62          # Horizontal blockify target raster width (px)
BLK_W        := 24          # Brick SVG unit width
BLK_H        := 20          # Brick SVG unit height
PAD          := 1           # Transparent column padding each side
SQ_PAD_V     := 20          # Vertical padding for square logos
HZ_PAD_TOP   := 20          # Top padding for horizontal logos
TXT_SIZE     := 57          # Subtitle font size (SVG units)
ANIM_MS      := 10000       # Animation frame duration (ms)
RASTER_W     := 800         # PNG/WebP export width (px)

LOGO_GEN_ARGS := \
  --source     $(SOURCE_SVG) \
  --font-path  $(FONT_PATH) \
  --sq-px      $(SQ_PX) \
  --hz-px      $(HZ_PX) \
  --blk-w      $(BLK_W) \
  --blk-h      $(BLK_H) \
  --pad        $(PAD) \
  --sq-pad-v   $(SQ_PAD_V) \
  --hz-pad-top $(HZ_PAD_TOP) \
  --txt-size   $(TXT_SIZE) \
  --anim-ms    $(ANIM_MS) \
  --raster-w   $(RASTER_W)

# Haskell source files – stamp depends on these so code changes also invalidate it
HS_SOURCES := $(shell find src app -name '*.hs') logo.cabal $(wildcard cabal.project*)

LOGO_STAMP := logo/.stamp

# The devenv shell's PATH can grow to 100 KB+ from hundreds of individual
# Haskell dep bin-dirs (one per nativeBuildInput).  When cabal spawns GHC and
# GHC in turn spawns cc/ar, Linux's per-string MAX_ARG_STRLEN limit (128 KB)
# is easily exceeded, producing posix_spawnp E2BIG.  Strip PATH to just the
# entries cabal, GHC, and the runtime image tools need; GHC resolves its own
# libtools via -Blibdir so only its bin dir is required.
_GHC_BIN    := $(shell dirname $(shell which ghc          2>/dev/null) 2>/dev/null)
_CABAL_BIN  := $(shell dirname $(shell which cabal        2>/dev/null) 2>/dev/null)
_RSVG_BIN   := $(shell dirname $(shell which rsvg-convert 2>/dev/null) 2>/dev/null)
_WEBP_BIN   := $(shell dirname $(shell which cwebp        2>/dev/null) 2>/dev/null)
_GIFSKI_BIN := $(shell dirname $(shell which gifski       2>/dev/null) 2>/dev/null)
_ICO_BIN    := $(shell dirname $(shell which icotool      2>/dev/null) 2>/dev/null)
_MAGICK_BIN := $(shell dirname $(shell which convert      2>/dev/null) 2>/dev/null)
_SLIM_PATH  := $(_GHC_BIN):$(_CABAL_BIN):$(_RSVG_BIN):$(_WEBP_BIN):$(_GIFSKI_BIN):$(_ICO_BIN):$(_MAGICK_BIN):/usr/bin:/bin
CABAL       := env PATH="$(_SLIM_PATH)" cabal

# ── Targets ───────────────────────────────────────────────────────────────────

help: ## Show available targets
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | \
	awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'

all: site ## Build everything: Haskell pipeline → assets → elm-pages → dist/

# ── Haskell pipeline ─────────────────────────────────────────────────────────

build: ## Compile Haskell executable (no run)
	$(CABAL) build --offline

# Incremental: only re-runs logo-gen when source.svg, fonts/, Haskell source,
# or any constant in this Makefile has changed.
$(LOGO_STAMP): $(SOURCE_SVG) $(FONT_PATH) $(HS_SOURCES) Makefile
	$(CABAL) build --offline
	$(CABAL) run --offline logo-gen -- $(LOGO_GEN_ARGS)
	@mkdir -p logo
	touch $(LOGO_STAMP)

run: $(LOGO_STAMP) ## Haskell pipeline: generate logo/, favicon/, brand.json, Brand.Generated.elm (incremental)

run-force: ## Force-run logo-gen regardless of stamp
	$(CABAL) run --offline logo-gen -- $(LOGO_GEN_ARGS)

# ── elm-pages site ────────────────────────────────────────────────────────────

install: ## Install npm deps and resolve Elm packages (run once after checkout)
	npm install

assets: run ## Copy generated assets into public/ for elm-pages
	rm -rf public/logo public/favicon public/fonts public/design-guide.json public/design-guide
	cp -r logo favicon fonts design-guide.json design-guide public/

dev: assets ## Dev server: pipeline → copy assets → elm-pages dev (hot reload)
	elm-pages dev

site: assets ## Production build: pipeline → copy assets → elm-pages build → dist/
	elm-pages build

deploy: ## Push main branch to trigger GitHub Actions deploy
	git push origin main

# ── Testing & linting ─────────────────────────────────────────────────────────

test: ## Run Haskell test suite and hlint
	$(CABAL) test --offline
	$(MAKE) check

check: ## Run hlint static analysis
	hlint src tests

format: ## Format all hand-written Elm source files with elm-format
	elm-format --yes app/ src/Component/ src/Brand/Colors.elm

# ── Watching ──────────────────────────────────────────────────────────────────

dev-watch: assets ## Build all static assets, then watch with elm-pages dev (hot reload)
	elm-pages dev

watch: ## Re-run Haskell pipeline on .hs/.cabal changes (requires entr)
	find src app tests -name '*.hs' -o -name '*.cabal' | entr -r $(CABAL) run --offline logo-gen -- $(LOGO_GEN_ARGS)

watch-elm: ## elm-pages dev server only (assumes assets already in public/)
	elm-pages dev

# ── REPL ──────────────────────────────────────────────────────────────────────

repl: ## Open GHCi REPL
	$(CABAL) repl --offline

# ── Cleanup ───────────────────────────────────────────────────────────────────

clean: ## Remove all generated files, build artifacts, and dist/
	$(CABAL) clean
	rm -rf design/ logo/ favicon/ brand.json design-guide.json design-guide/ __pycache__
	rm -rf dist/ .elm-pages/
	rm -f src/Brand/Generated.elm src/Brand/Tokens.elm
	rm -rf public/brand.json public/design-guide.json public/design-guide public/logo public/favicon public/fonts

# ── Devenv ────────────────────────────────────────────────────────────────────

develop: devenv.local.nix devenv.local.yaml ## Bootstrap devenv shell + VS Code
	devenv shell --profile=devcontainer -- code .

shell: ## Enter devenv shell
	devenv shell

devenv.local.nix:
	cp devenv.local.nix.example devenv.local.nix

devenv.local.yaml:
	cp devenv.local.yaml.example devenv.local.yaml
