---
name: setup-laravel-git-hooks
description: Set up git pre-commit hooks for Laravel projects — Pint on staged PHP, then Pest/PHPUnit and optional PHPStan. Use when user wants pre-commit hooks, commit-time formatting, or quality gates without Node/Husky.
---

# Setup Laravel Git Hooks

## What this sets up

- **`.githooks/pre-commit`** — runs on every commit
- **`git config core.hooksPath .githooks`** — points Git at the repo hooks (committed, shareable)
- **Pint** on changed PHP files (`--dirty`)
- **Tests** via Pest or PHPUnit (full suite or `--parallel` if configured)
- **PHPStan** (optional — only if `phpstan.neon` / `phpstan.neon.dist` exists)

No Node, Husky, or Prettier — this is the PHP-native path most Laravel teams want.

## Steps

### 1. Detect tooling

Read `composer.json` and the repo:

| Tool | Detect |
|------|--------|
| Pint | `laravel/pint` in require-dev |
| Pest | `pestphp/pest` + `pest.php` |
| PHPUnit only | `phpunit/phpunit` without Pest |
| PHPStan | `phpstan.neon` or `phpstan.neon.dist` |
| Larastan | `larastan/larastan` |

If Pint is missing, offer to add it: `composer require laravel/pint --dev`.

### 2. Create `.githooks/pre-commit`

```bash
#!/usr/bin/env bash
set -euo pipefail

ROOT="$(git rev-parse --show-toplevel)"
cd "$ROOT"

if [ -f ./vendor/bin/pint ]; then
  ./vendor/bin/pint --dirty
fi

if [ -f ./vendor/bin/pest ]; then
  ./vendor/bin/pest
elif [ -f ./vendor/bin/phpunit ]; then
  ./vendor/bin/phpunit
else
  php artisan test
fi

if [ -f ./vendor/bin/phpstan ] && { [ -f phpstan.neon ] || [ -f phpstan.neon.dist ]; }; then
  ./vendor/bin/phpstan analyse --memory-limit=2G
fi
```

**Adapt:**

- If the project uses `./vendor/bin/pest --parallel` in CI, match that here.
- If full-suite tests are too slow for pre-commit, switch to `./vendor/bin/pint --dirty` only and document running tests in CI — ask the user.
- Omit PHPStan block if not configured.

Make executable: `chmod +x .githooks/pre-commit`

### 3. Point Git at the hooks directory

```bash
git config core.hooksPath .githooks
```

Tell the user to run this once per clone (or document it in the project README). Optionally add a Composer `post-install-cmd` script if the team wants automation.

### 4. Verify

- [ ] `.githooks/pre-commit` exists and is executable
- [ ] `git config core.hooksPath` returns `.githooks`
- [ ] Dry run: `bash .githooks/pre-commit` from repo root

### 5. Commit

Stage `.githooks/pre-commit` and any `composer.json` changes. Suggested message: `Add Laravel pre-commit hooks (Pint + tests)`

## Notes

- `--dirty` limits Pint to changed files — fast on large codebases
- For monorepos with multiple apps, scope commands per package or ask the user which subdirectory owns the hook
- Alternative tools (Captain Hook, GrumPHP) are fine if already present — don't replace them; extend their config instead
