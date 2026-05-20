# Laravel Agent Skills

Composable agent skills for **real Laravel engineering** — not vibe coding. Small, adaptable practices you can mix into any project. Works with **OpenCode**, Claude Code, Cursor, Codex, and other agents.

Forked from [mattpocock/skills](https://github.com/mattpocock/skills) and adapted for PHP, Pest, Pint, and Laravel conventions.

## Quickstart

### OpenCode

OpenCode discovers skills from `~/.config/opencode/skills/` (global) and `.agents/skills/` in a project. This repo includes a local plugin that wraps the install scripts as tools.

```bash
# Install skills globally for OpenCode (and Claude / Agents)
./scripts/link-skills.sh opencode
# Or all targets:
./scripts/link-skills.sh

# Install into a Laravel project's .agents/skills/
./scripts/link-skills.sh --project /path/to/your-app opencode
```

When you open **this repository** in OpenCode, `.opencode/plugins/laravel-skills.ts` loads automatically and exposes `link_skills` and `list_skills` tools (same behaviour as the bash scripts). OpenCode runs `bun install` in `.opencode/` on startup for `@opencode-ai/plugin`.

See [OpenCode skills](https://opencode.ai/docs/skills) and [plugins](https://opencode.ai/docs/plugins).

### Claude Code

```bash
./scripts/link-skills.sh claude
```

Or use `.claude-plugin/plugin.json` with the Claude plugin installer.

### Other agents

```bash
./scripts/link-skills.sh agents   # ~/.agents/skills (also read by OpenCode)
./scripts/list-skills.sh          # list SKILL.md paths in this repo
```

### Laravel project setup

1. **Run `/setup-laravel-skills` once per Laravel repo.** It records:
   - Issue tracker (GitHub, GitLab, or local markdown)
   - Triage label vocabulary
   - Domain doc layout (`CONTEXT.md`, `docs/adr/`)
   - Laravel stack (Pest vs PHPUnit, Blade/Livewire/Inertia, Pint, PHPStan, dev environment)

2. Use the skills that match your workflow — `/grill-with-docs` before big changes, `/tdd` for features, `/diagnose` for hard bugs.

## Why these skills exist

Same failure modes as any agent-assisted project — misalignment, verbose jargon, weak feedback loops, and fast-growing complexity. These skills encode fundamentals:

| Problem | Skill |
|---------|--------|
| Agent didn't understand what you want | [`/grill-me`](./skills/productivity/grill-me/SKILL.md), [`/grill-with-docs`](./skills/engineering/grill-with-docs/SKILL.md) |
| Agent uses the wrong vocabulary | [`/grill-with-docs`](./skills/engineering/grill-with-docs/SKILL.md) → `CONTEXT.md` |
| Code doesn't work / no feedback | [`/tdd`](./skills/engineering/tdd/SKILL.md), [`/diagnose`](./skills/engineering/diagnose/SKILL.md) |
| Ball of mud | [`/improve-codebase-architecture`](./skills/engineering/improve-codebase-architecture/SKILL.md), [`/zoom-out`](./skills/engineering/zoom-out/SKILL.md) |

### Shared language example

**Before:** "There's a problem when a lesson inside a section of a course is made real in the filesystem."

**After:** "There's a problem with the materialization cascade."

Define terms once in `CONTEXT.md`; agents and humans stay aligned.

### Laravel feedback loops

- **Static analysis** — PHPStan / Larastan
- **Format** — Pint
- **Tests** — Pest Feature tests through HTTP, unit tests on Actions
- **Fakes** — `Http::fake()`, `Queue::fake()`, `Mail::fake()`
- **Local run** — Sail, Herd, or `php artisan serve`

The [`/tdd`](./skills/engineering/tdd/SKILL.md) skill enforces red-green-refactor with vertical slices — one failing Pest test, minimal implementation, repeat.

## Reference

### Engineering

- **[diagnose](./skills/engineering/diagnose/SKILL.md)** — Reproduce → minimise → hypothesise → instrument → fix → regression-test.
- **[grill-with-docs](./skills/engineering/grill-with-docs/SKILL.md)** — Grilling session + `CONTEXT.md` + ADRs.
- **[triage](./skills/engineering/triage/SKILL.md)** — Issue triage state machine.
- **[improve-codebase-architecture](./skills/engineering/improve-codebase-architecture/SKILL.md)** — Deepening opportunities using domain language and ADRs.
- **[setup-laravel-skills](./skills/engineering/setup-laravel-skills/SKILL.md)** — Per-repo config: issue tracker, triage labels, domain docs, **Laravel stack**. Run first.
- **[tdd](./skills/engineering/tdd/SKILL.md)** — TDD with Pest/PHPUnit; integration-style tests through HTTP and Actions.
- **[to-issues](./skills/engineering/to-issues/SKILL.md)** — Break plans into vertical-slice issues.
- **[to-prd](./skills/engineering/to-prd/SKILL.md)** — Synthesise conversation into a PRD on the issue tracker.
- **[zoom-out](./skills/engineering/zoom-out/SKILL.md)** — Higher-level context on unfamiliar code.
- **[prototype](./skills/engineering/prototype/SKILL.md)** — Artisan logic simulator or multi-variant UI (Blade / Livewire / Inertia).

### Productivity

- **[caveman](./skills/productivity/caveman/SKILL.md)** — Ultra-compressed communication mode.
- **[grill-me](./skills/productivity/grill-me/SKILL.md)** — Interview until the decision tree is resolved.
- **[handoff](./skills/productivity/handoff/SKILL.md)** — Compact handoff for the next agent session.
- **[write-a-skill](./skills/productivity/write-a-skill/SKILL.md)** — Author new skills with proper structure.

### Misc

- **[git-guardrails-claude-code](./skills/misc/git-guardrails-claude-code/SKILL.md)** — Block dangerous git commands via Claude hooks.
- **[setup-laravel-git-hooks](./skills/misc/setup-laravel-git-hooks/SKILL.md)** — Pre-commit: Pint + Pest + optional PHPStan (no Node).

## Buckets

See [AGENTS.md](./AGENTS.md) for how skills are organised (`engineering/`, `productivity/`, `misc/`, `personal/`, `in-progress/`, `deprecated/`).

## What changed from the TypeScript upstream

| Change | Reason |
|--------|--------|
| `setup-matt-pocock-skills` → **`setup-laravel-skills`** | Records Pest/PHPUnit, UI layer, Pint, PHPStan |
| **Removed** `migrate-to-shoehorn` | `@total-typescript/shoehorn` is TS-only |
| **Removed** `scaffold-exercises` | Tied to `ai-hero-cli` / TS course layout |
| **Removed** `setup-pre-commit` (Husky/Prettier) | Replaced by **`setup-laravel-git-hooks`** |
| **Rewrote** `tdd/*`, `prototype/*`, `diagnose` | Pest, HTTP Feature tests, Artisan, Blade/Livewire |

Personal, in-progress, and deprecated buckets are unchanged from upstream (not listed in README).
