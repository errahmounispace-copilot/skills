---
name: setup-laravel-skills
description: Sets up an `## Agent skills` block in AGENTS.md/CLAUDE.md and `docs/agents/` so engineering skills know this repo's issue tracker, triage labels, domain docs, and Laravel stack (Pest vs PHPUnit, frontend, quality tools). Run before first use of `to-issues`, `to-prd`, `triage`, `diagnose`, `tdd`, `improve-codebase-architecture`, or `zoom-out` — or when those skills lack context.
disable-model-invocation: true
---

# Setup Laravel Skills

Scaffold the per-repo configuration that the engineering skills assume:

- **Issue tracker** — where issues live (GitHub by default; local markdown is also supported)
- **Triage labels** — strings for the five canonical triage roles
- **Domain docs** — where `CONTEXT.md` and ADRs live
- **Laravel stack** — test runner, UI layer, and quality-tool commands the agent should use

This is a prompt-driven skill, not a deterministic script. Explore, present what you found, confirm with the user, then write.

## Process

### 1. Explore

Look at the current repo. Read whatever exists; don't assume:

- `git remote -v` — GitHub, GitLab, or none?
- `composer.json` — Laravel version, `laravel/framework`, dev tools (`pestphp/pest`, `larastan/larastan`, `laravel/pint`)
- `artisan`, `phpunit.xml`, `pest.php`, `tests/` layout (`Feature/`, `Unit/`)
- Frontend signals: `resources/views/`, Livewire (`livewire/livewire`), Inertia (`inertiajs/inertia-laravel`), Filament, API-only (`routes/api.php` only)
- `AGENTS.md` and `CLAUDE.md` — existing `## Agent skills` section?
- `CONTEXT.md`, `CONTEXT-MAP.md`, `docs/adr/`, `docs/agents/`, `.scratch/`

### 2. Present findings and ask

Summarise what's present and what's missing. Walk the user through **one section at a time** — present a section, get the answer, then move on. Don't dump all sections at once.

Assume the user may not know these terms. Each section starts with a short explainer, then choices and the default.

**Section A — Issue tracker.**

> Explainer: Where issues live for this repo. Skills like `to-issues`, `triage`, and `to-prd` read from and write to it.

Default: GitHub if `git remote` points at GitHub; GitLab if GitLab; otherwise offer:

- **GitHub** — `gh` CLI
- **GitLab** — `glab` CLI
- **Local markdown** — `.scratch/<feature>/` (solo / no remote)
- **Other** — user describes workflow in one paragraph; record as freeform prose

**Section B — Triage label vocabulary.**

> Explainer: The `triage` skill moves issues through a state machine. It needs the label strings you actually use in your tracker.

Five canonical roles:

- `needs-triage` — maintainer needs to evaluate
- `needs-info` — waiting on reporter
- `ready-for-agent` — fully specified, AFK-ready
- `ready-for-human` — needs human implementation
- `wontfix` — will not be actioned

Default: each role's string equals its name. Ask if they want overrides.

**Section C — Domain docs.**

> Explainer: Skills read `CONTEXT.md` for domain language and `docs/adr/` for past decisions.

- **Single-context** — one `CONTEXT.md` + `docs/adr/` at repo root (typical Laravel app)
- **Multi-context** — `CONTEXT-MAP.md` pointing at per-package or per-module `CONTEXT.md` (monorepo, `nwidart/laravel-modules`, `packages/*`)

**Section D — Laravel stack.**

> Explainer: So the agent runs the right test and quality commands and prototypes in the right layer.

Confirm (infer from repo first, then ask only if unclear):

| Choice | Options | How to detect |
|--------|---------|---------------|
| Test runner | **Pest** (preferred for new Laravel) or **PHPUnit** | `pestphp/pest` in composer, `pest.php` exists |
| UI layer | **Blade**, **Livewire**, **Inertia (Vue/React)**, **Filament**, **API-only** | `livewire/*`, `inertiajs/*`, `routes/api.php` without web UI |
| Format / analyse | **Pint**, **PHPStan/Larastan** (paths if non-default) | `laravel/pint`, `larastan/larastan`, `phpstan.neon` |
| Dev environment | **Sail**, **Herd**, **Valet**, **plain `php artisan serve`** | `docker-compose.yml`, user preference |

Record exact commands in `docs/agents/laravel-stack.md` (see seed template).

### 3. Confirm and edit

Show a draft of:

- The `## Agent skills` block for `CLAUDE.md` / `AGENTS.md`
- `docs/agents/issue-tracker.md`, `triage-labels.md`, `domain.md`, `laravel-stack.md`

Let the user edit before writing.

### 4. Write

**Pick the file to edit:**

- If `CLAUDE.md` exists, edit it.
- Else if `AGENTS.md` exists, edit it.
- If neither exists, ask which to create.

Never create `AGENTS.md` when `CLAUDE.md` already exists (or vice versa).

If `## Agent skills` already exists, update in-place.

```markdown
## Agent skills

### Issue tracker

[one-line summary]. See `docs/agents/issue-tracker.md`.

### Triage labels

[one-line summary]. See `docs/agents/triage-labels.md`.

### Domain docs

[single-context or multi-context]. See `docs/agents/domain.md`.

### Laravel stack

[one-line: Pest + Livewire + Pint, etc.]. See `docs/agents/laravel-stack.md`.
```

Write `docs/agents/*` from seed templates in this folder:

- [issue-tracker-github.md](./issue-tracker-github.md)
- [issue-tracker-gitlab.md](./issue-tracker-gitlab.md)
- [issue-tracker-local.md](./issue-tracker-local.md)
- [triage-labels.md](./triage-labels.md)
- [domain.md](./domain.md)
- [laravel-stack.md](./laravel-stack.md)

For "other" issue trackers, write `issue-tracker.md` from the user's description.

### 5. Done

Tell the user setup is complete and which skills now consume these files. They can edit `docs/agents/*.md` directly later.
