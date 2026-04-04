# ── PATH trimming (prevents E2BIG when cabal spawns GHC) ─────────────────────
_GHC_BIN   := $(shell dirname $(shell which ghc   2>/dev/null) 2>/dev/null)
_CABAL_BIN := $(shell dirname $(shell which cabal 2>/dev/null) 2>/dev/null)
_SLIM_PATH := $(_GHC_BIN):$(_CABAL_BIN):/usr/bin:/bin
CABAL      := env PATH="$(_SLIM_PATH)" cabal

HS_SOURCES := $(shell find src -name '*.hs') design-tokens.cabal $(wildcard cabal.project*)

# ── Phony help ────────────────────────────────────────────────────────────────

.PHONY: help
help: ## Show available targets
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | \
	awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-22s\033[0m %s\n", $$1, $$2}'

# ── Haskell ───────────────────────────────────────────────────────────────────

.PHONY: build
build: ## Compile all Haskell executables
	$(CABAL) build --offline

# ── Generate design tokens ────────────────────────────────────────────────────

.PHONY: gen
gen: build ## Generate dist/ design tokens (JSON + Elm package)
	$(CABAL) run --offline design-tokens-gen

dist: gen

all: dist

# ── Testing & linting ─────────────────────────────────────────────────────────

.PHONY: test
test: ## Run Haskell test suite and hlint
	$(CABAL) test --offline
	$(MAKE) check

.PHONY: check
check: ## Run hlint + elm-review on generated code
	hlint src tests
	cd dist/design-tokens-elm && elm-review --config ../../review

.PHONY: format
format: ## Auto-format Haskell source files
	find src tests -name '*.hs' | xargs fourmolu --mode inplace

# ── REPL ──────────────────────────────────────────────────────────────────────

.PHONY: repl
repl: ## Open GHCi REPL
	$(CABAL) repl --offline

# ── Cleanup ───────────────────────────────────────────────────────────────────

.PHONY: clean
clean: ## Remove build artifacts and dist/
	$(CABAL) clean
	rm -rf dist/