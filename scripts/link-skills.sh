#!/usr/bin/env bash
set -euo pipefail

# Symlink skills from this repository into agent skill directories.
#
# Usage:
#   ./scripts/link-skills.sh [TARGET...]
#   ./scripts/link-skills.sh --project DIR [TARGET...]
#   ./scripts/link-skills.sh --help
#
# TARGET (global install; default: all):
#   claude    -> ~/.claude/skills
#   opencode  -> ~/.config/opencode/skills
#   agents    -> ~/.agents/skills  (also discovered by OpenCode)
#   all       -> claude + opencode + agents
#
# --project DIR
#   Also link into DIR/.opencode/skills (when opencode or all is selected)
#   and DIR/.claude/skills (when claude or all is selected).

REPO="$(cd "$(dirname "$0")/.." && pwd)"

declare -A GLOBAL_DESTS=(
  [claude]="${HOME}/.claude/skills"
  [opencode]="${HOME}/.config/opencode/skills"
  [agents]="${HOME}/.agents/skills"
)

usage() {
  cat <<'EOF'
Symlink skills from this repository into agent skill directories.

Usage:
  ./scripts/link-skills.sh [TARGET...]
  ./scripts/link-skills.sh --project DIR [TARGET...]
  ./scripts/link-skills.sh --help

TARGET (global install; default: all):
  claude    -> ~/.claude/skills
  opencode  -> ~/.config/opencode/skills
  agents    -> ~/.agents/skills  (also discovered by OpenCode)
  all       -> claude + opencode + agents

--project DIR
  Also link into project skill dirs (.opencode/skills, .claude/skills, .agents/skills)
EOF
  exit 0
}

guard_dest() {
  local dest="$1"
  if [[ -L "$dest" ]]; then
    local resolved
    resolved="$(readlink -f "$dest")"
    case "$resolved" in
      "$REPO"|"$REPO"/*)
        echo "error: $dest is a symlink into this repo ($resolved)." >&2
        echo "Remove it (rm \"$dest\") and re-run; the script will recreate it as a real directory." >&2
        exit 1
        ;;
    esac
  fi
}

link_skills_to() {
  local dest="$1"
  guard_dest "$dest"
  mkdir -p "$dest"

  find "$REPO/skills" -name SKILL.md -not -path '*/node_modules/*' -not -path '*/deprecated/*' -print0 |
    while IFS= read -r -d '' skill_md; do
      local src name target
      src="$(dirname "$skill_md")"
      name="$(basename "$src")"
      target="$dest/$name"

      if [[ -e "$target" && ! -L "$target" ]]; then
        rm -rf "$target"
      fi

      ln -sfn "$src" "$target"
      echo "linked $name -> $src ($dest)"
    done
}

PROJECT_DIR=""
TARGETS=()

while [[ $# -gt 0 ]]; do
  case "$1" in
    -h | --help) usage ;;
    -p | --project)
      shift
      [[ $# -gt 0 ]] || { echo "error: --project requires a directory" >&2; exit 1; }
      PROJECT_DIR="$(cd "$1" && pwd)"
      shift
      ;;
    claude | opencode | agents | all)
      TARGETS+=("$1")
      shift
      ;;
    *)
      echo "error: unknown argument: $1" >&2
      usage
      ;;
  esac
done

if [[ ${#TARGETS[@]} -eq 0 ]]; then
  TARGETS=(all)
fi

expand_targets() {
  local -n _out=$1
  _out=()
  for t in "${TARGETS[@]}"; do
    case "$t" in
      all) _out+=(claude opencode agents) ;;
      *) _out+=("$t") ;;
    esac
  done
}

expanded=()
expand_targets expanded

# Deduplicate targets
declare -A seen=()
unique=()
for t in "${expanded[@]}"; do
  [[ -n "${seen[$t]:-}" ]] && continue
  seen[$t]=1
  unique+=("$t")
done

for t in "${unique[@]}"; do
  case "$t" in
    claude | opencode | agents)
      link_skills_to "${GLOBAL_DESTS[$t]}"
      ;;
    *)
      echo "error: internal unknown target $t" >&2
      exit 1
      ;;
  esac
done

if [[ -n "$PROJECT_DIR" ]]; then
  for t in "${unique[@]}"; do
    case "$t" in
      opencode)
        link_skills_to "$PROJECT_DIR/.opencode/skills"
        ;;
      agents)
        link_skills_to "$PROJECT_DIR/.agents/skills"
        ;;
      claude)
        link_skills_to "$PROJECT_DIR/.claude/skills"
        ;;
    esac
  done
fi
