# Command contract: every repo built from this template answers the same verbs.
# CI, pre-commit, Claude Code and you all call these. Never bypass them.
.DEFAULT_GOAL := help
SHELL := /bin/bash

HAS_PY := $(wildcard pyproject.toml)
HAS_JS := $(wildcard package.json)

help: ## Show this help
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-12s\033[0m %s\n", $$1, $$2}'

setup: ## Install dependencies + git hooks (run once per clone)
ifneq ($(HAS_PY),)
	uv sync --all-extras --dev
endif
ifneq ($(HAS_JS),)
	pnpm install
endif
	pre-commit install --install-hooks
	pre-commit install --hook-type commit-msg
	pre-commit install --hook-type pre-push

setup-ci: ## Dependencies only, no git hooks
ifneq ($(HAS_PY),)
	uv sync --all-extras --dev
endif
ifneq ($(HAS_JS),)
	pnpm install --frozen-lockfile || pnpm install --no-frozen-lockfile
endif

format: ## Auto-format and auto-fix
ifneq ($(HAS_PY),)
	uv run ruff format .
	uv run ruff check --fix .
endif
ifneq ($(HAS_JS),)
	pnpm exec biome check --write .
endif

lint: ## Lint without writing
ifneq ($(HAS_PY),)
	uv run ruff format --check .
	uv run ruff check .
endif
ifneq ($(HAS_JS),)
	pnpm exec biome ci .
endif

typecheck: ## Static type check
ifneq ($(HAS_PY),)
	uv run mypy src
endif
ifneq ($(HAS_JS),)
	pnpm exec tsc --noEmit
endif

test: ## Run tests
ifneq ($(HAS_PY),)
	uv run pytest -q
endif
ifneq ($(HAS_JS),)
	pnpm exec vitest run
endif

check: lint typecheck test ## Everything CI enforces

secrets: ## Scan working tree for committed secrets
	gitleaks detect --no-banner --redact --source .

prune-py: ## Drop the Python half of the template
	rm -rf pyproject.toml uv.lock src/example.py tests/test_example.py

prune-js: ## Drop the TypeScript half of the template
	rm -rf package.json pnpm-lock.yaml tsconfig.json biome.json src/index.ts tests/example.test.ts

clean:
	rm -rf .venv node_modules .pytest_cache .ruff_cache .mypy_cache dist build

.PHONY: help setup setup-ci format lint typecheck test check secrets prune-py prune-js clean
