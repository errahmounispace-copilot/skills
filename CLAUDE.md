Skills are organized into bucket folders under `skills/`:

- `engineering/` — daily code work
- `productivity/` — daily non-code workflow tools
- `misc/` — kept around but rarely used
- `personal/` — tied to my own setup, not promoted
- `in-progress/` — drafts not yet ready to ship
- `deprecated/` — no longer used

Every skill in `engineering/`, `productivity/`, or `misc/` must have a reference in the top-level `README.md` and an entry in `.claude-plugin/plugin.json`. Skills in `personal/`, `in-progress/`, and `deprecated/` must not appear in either.

Each skill entry in the top-level `README.md` must link the skill name to its `SKILL.md`.

Each bucket folder has a `README.md` that lists every skill in the bucket with a one-line description, with the skill name linked to its `SKILL.md`.

## OpenCode

- Install paths: `~/.config/opencode/skills/` (global), `.opencode/skills/` (project) — use `./scripts/link-skills.sh opencode` or `opencode`.
- Local plugin: `.opencode/plugins/laravel-skills.ts` (tools: `link_skills`, `list_skills`).
- Config: `opencode.json` at repo root. Plugin deps: `.opencode/package.json`.
