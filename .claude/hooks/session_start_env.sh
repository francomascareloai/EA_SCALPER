#!/usr/bin/env bash
set -euo pipefail

# Persist venv activation for subsequent Bash tool calls in this session.
# Claude Code provides:
# - CLAUDE_PROJECT_DIR: project root
# - CLAUDE_ENV_FILE: file to append env exports/sourcing commands

if [[ -z "${CLAUDE_ENV_FILE:-}" || -z "${CLAUDE_PROJECT_DIR:-}" ]]; then
  exit 0
fi

activate_path="$CLAUDE_PROJECT_DIR/.venv/bin/activate"
if [[ ! -f "$activate_path" ]]; then
  exit 0
fi

# Avoid duplicating lines across multiple SessionStart triggers.
if grep -Fq "$activate_path" "$CLAUDE_ENV_FILE" 2>/dev/null; then
  exit 0
fi

echo "source '$activate_path'" >> "$CLAUDE_ENV_FILE"
