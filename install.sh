#!/usr/bin/env bash
# Install every agent into a Claude Code agents directory, plus the shared conventions file.
# Usage:
#   ./install.sh            # install at project scope (./.claude/agents)
#   ./install.sh --user     # install at user scope (~/.claude/agents)
set -euo pipefail

ROOT=".claude"
[ "${1:-}" = "--user" ] && ROOT="$HOME/.claude"
DEST="$ROOT/agents"

SRC="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
mkdir -p "$DEST"

SETS=(audit-agents feature-planner-agents bugfix-planner-agents feature-implementer-agents)
count=0
for dir in "${SETS[@]}"; do
  [ -d "$SRC/$dir" ] || continue
  while IFS= read -r -d '' f; do
    cp "$f" "$DEST/"
    count=$((count + 1))
  done < <(find "$SRC/$dir" -name '*.md' ! -name 'README.md' -print0)
done

# The conventions file has no agent frontmatter, so it lives beside agents/, not inside it.
cp "$SRC/shared-conventions.md" "$ROOT/agent-conventions.md"

echo "Installed $count agents into $DEST"
echo "Installed shared conventions to $ROOT/agent-conventions.md"
echo "Run /agents in Claude Code to verify."
