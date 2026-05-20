# Laravel Skills

Agent skills (slash commands and behaviours) for Laravel projects. Skills live in bucket folders under `skills/` and consume per-repo configuration from `/setup-laravel-skills`.

## Language

**Issue tracker**:
The tool that hosts a repo's issues — GitHub Issues, GitLab Issues, a local `.scratch/` markdown convention, or similar. Skills like `to-issues`, `to-prd`, and `triage` read from and write to it.
_Avoid_: backlog manager, backlog backend, issue host

**Issue**:
A single tracked unit of work inside an **Issue tracker** — a bug, task, PRD, or slice produced by `to-issues`.
_Avoid_: ticket (use only when quoting external systems that call them tickets)

**Triage role**:
A canonical state-machine label applied to an **Issue** during triage (e.g. `needs-triage`, `ready-for-agent`). Each role maps to a real label string in the **Issue tracker** via `docs/agents/triage-labels.md`.

**Laravel stack**:
The repo's test runner (Pest or PHPUnit), UI layer (Blade, Livewire, Inertia, etc.), and quality-tool commands. Recorded in `docs/agents/laravel-stack.md` by `/setup-laravel-skills`.

## Relationships

- An **Issue tracker** holds many **Issues**
- An **Issue** carries one **Triage role** at a time
- **Laravel stack** config is read by `tdd`, `diagnose`, `prototype`, and related skills

## Flagged ambiguities

- "backlog" was previously used to mean both the *tool* hosting issues and the *body of work* inside it — resolved: the tool is the **Issue tracker**; "backlog" is no longer used as a domain term.
