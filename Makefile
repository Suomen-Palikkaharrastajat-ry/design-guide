.PHONY: help all build blay-compose assets site dev dev-watch deploy install test check format clean watch watch-elm repl develop shell

# When elm-pages comes from the Nix store the wrapper does not include the
# package's own node_modules/.bin (elm-optimize-level-2, etc.) in PATH.
# Detect the store root from the resolved elm-pages binary and prepend it.
_ELM_PAGES_BIN  := $(shell which elm-pages 2>/dev/null)
_ELM_PAGES_ROOT := $(shell readlink -f $(_ELM_PAGES_BIN) 2>/dev/null | xargs -I{} dirname {} | xargs -I{} dirname {} 2>/dev/null)
ifneq ($(_ELM_PAGES_ROOT),)
export PATH := $(_ELM_PAGES_ROOT)/lib/node_modules/.bin:$(PATH)
endif

# ── Pipeline constants ────────────────────────────────────────────────────────
# Single documented source of truth for all tunable parameters.
# Forwarded verbatim as CLI flags to logo-gen; no Haskell rebuild needed when
# changing these values.

FONT_PATH    := fonts/Outfit-VariableFont_wght.ttf

BLK_W        := 24          # Brick SVG unit width
BLK_H        := 20          # Brick SVG unit height
SQ_PAD_V     := 20          # Vertical padding for square logos
HZ_PAD_TOP   := 20          # Top padding for horizontal logos
TXT_SIZE     := 57          # Subtitle font size (SVG units)
ANIM_MS      := 10000       # Animation frame duration (ms)
RASTER_W     := 800         # PNG/WebP export width (px)

LOGO_GEN_ARGS := \
  --font-path  $(FONT_PATH) \
  --blk-w      $(BLK_W) \
  --blk-h      $(BLK_H) \
  --sq-pad-v   $(SQ_PAD_V) \
  --hz-pad-top $(HZ_PAD_TOP) \
  --txt-size   $(TXT_SIZE) \
  --anim-ms    $(ANIM_MS) \
  --raster-w   $(RASTER_W)

BLAY_COMPOSE_ARGS := \
  --hz-pad-top $(HZ_PAD_TOP) \
  --gap-studs  2

# Haskell source files – stamp depends on these so code changes invalidate it
HS_SOURCES := $(shell find src app -name '*.hs') logo.cabal $(wildcard cabal.project*)

# All committed .blay files (masters + derived outputs of blay-compose)
BLAY_FILES  := $(wildcard layout/*.blay)
BLAY_STAMP  := logo/.blay-stamp

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

# Outline subtitle text in composed horizontal SVGs only (not squares, not logo-only horizontals)
OUTLINE_TEXT := python3 scripts/text_to_path.py $(FONT_PATH) \
  logo/horizontal/svg/*-full.svg \
  logo/horizontal/svg/*-full-dark.svg

# ── Targets ───────────────────────────────────────────────────────────────────

help: ## Show available targets
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | \
	awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'

all: site ## Build everything: Haskell pipeline → assets → elm-pages → dist/

# ── Haskell pipeline ─────────────────────────────────────────────────────────

build: ## Compile all Haskell executables (no run)
	$(CABAL) build --offline

# ── blay-compose (developer step, run locally before committing) ──────────────
#
# Reads layout/first.blay … fourth.blay (master layouts, human-authored) and
# writes all derived .blay files: square skin-tone variants + rainbow horizontals.
# Commit the outputs so CI only needs logo-gen.
#
# To draft a new master from source SVG use:
#   cabal run --offline blay-draft -- --source source.svg --output layout/first.blay

blay-compose: build ## Generate derived .blay files from masters (run locally before committing)
	$(CABAL) run --offline blay-compose -- $(BLAY_COMPOSE_ARGS)

# ── logo-gen render (CI-safe: reads only committed .blay files) ───────────────

# Incremental: only re-renders when .blay files, fonts, Haskell source, or
# Makefile constants change.
$(BLAY_STAMP): $(BLAY_FILES) $(FONT_PATH) $(HS_SOURCES) Makefile scripts/text_to_path.py
	$(CABAL) build --offline
	$(CABAL) run --offline logo-gen -- $(LOGO_GEN_ARGS)
	$(OUTLINE_TEXT)
	@mkdir -p logo
	touch $(BLAY_STAMP)

render: $(BLAY_STAMP) ## Render .blay files → logo/, favicon/, design tokens (incremental)

render-force: build ## Force re-render from .blay files regardless of stamp
	$(CABAL) run --offline logo-gen -- $(LOGO_GEN_ARGS)
	$(OUTLINE_TEXT)

# ── elm-pages site ────────────────────────────────────────────────────────────

install: ## Install npm deps and resolve Elm packages (run once after checkout)
	npm install

assets: render ## Copy generated assets into public/ for elm-pages
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

watch: ## Re-run logo-gen on .hs/.cabal changes (requires entr)
	find src app tests -name '*.hs' -o -name '*.cabal' | entr -r sh -c '$(CABAL) run --offline logo-gen -- $(LOGO_GEN_ARGS) && $(OUTLINE_TEXT)'

watch-elm: ## elm-pages dev server only (assumes assets already in public/)
	elm-pages dev

# ── REPL ──────────────────────────────────────────────────────────────────────

repl: ## Open GHCi REPL
	$(CABAL) repl --offline

# ── Cleanup ───────────────────────────────────────────────────────────────────

clean: ## Remove all generated files, build artifacts, and dist/
	$(CABAL) clean
	rm -rf logo/ favicon/ design-guide.json design-guide/ __pycache__
	rm -rf dist/ .elm-pages/
	rm -f src/Brand/Generated.elm src/Brand/Tokens.elm
	rm -rf public/design-guide.json public/design-guide public/logo public/favicon public/fonts

# ── Devenv ────────────────────────────────────────────────────────────────────

develop: devenv.local.nix devenv.local.yaml ## Bootstrap devenv shell + VS Code
	devenv shell --profile=devcontainer -- code .

shell: ## Enter devenv shell
	devenv shell

devenv.local.nix:
	cp devenv.local.nix.example devenv.local.nix

devenv.local.yaml:
	cp devenv.local.yaml.example devenv.local.yaml
