.PHONY: help build run test check clean watch repl develop shell

help: ## Show available targets
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | \
	awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'

build: ## Compile Haskell executable
	cabal build

run: ## Run the full logo generation pipeline
	cabal run logo-gen

test: ## Run test suite and hlint
	cabal test
	make check

check: ## Run hlint static analysis
	hlint src tests

repl: ## Open GHCi REPL
	cabal repl

watch: ## Rebuild and rerun on source changes (requires entr)
	find src -name '*.hs' | entr -r cabal run logo-gen

clean: ## Remove generated files and cabal build artifacts
	cabal clean
	rm -rf design/ logo/ favicon/ brand.json __pycache__

develop: devenv.local.nix devenv.local.yaml ## Bootstrap devenv
	devenv shell --profile=devcontainer -- code .

shell: ## Enter devenv shell
	devenv shell

devenv.local.nix:
	cp devenv.local.nix.example devenv.local.nix

devenv.local.yaml:
	cp devenv.local.yaml.example devenv.local.yaml
