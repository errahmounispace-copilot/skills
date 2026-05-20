#!/usr/bin/env bash
set -euo pipefail

# List all SKILL.md paths in this repository (agent-agnostic).
#
# Usage:
#   ./scripts/list-skills.sh
#   ./scripts/list-skills.sh --name-only   # skill folder names only

REPO="$(cd "$(dirname "$0")/.." && pwd)"
NAME_ONLY=false

while [[ $# -gt 0 ]]; do
  case "$1" in
    -h | --help)
      echo "Usage: $0 [--name-only]"
      exit 0
      ;;
    --name-only)
      NAME_ONLY=true
      shift
      ;;
    *)
      echo "error: unknown argument: $1" >&2
      exit 1
      ;;
  esac
done

cd "$REPO"

if $NAME_ONLY; then
  find ./skills -name SKILL.md -not -path '*/node_modules/*' -not -path '*/deprecated/*' |
    while read -r path; do
      basename "$(dirname "$path")"
    done | sort -u
else
  find ./skills -name SKILL.md -not -path '*/node_modules/*' -not -path '*/deprecated/*' |
    sed 's|^\./||' | sort
fi
