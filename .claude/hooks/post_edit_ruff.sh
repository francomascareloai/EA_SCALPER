#!/usr/bin/env bash
set -euo pipefail

# Run fast Python formatting/linting after Claude edits files.
# Keeps it cheap: only touches the edited file and only when it's a .py.

input="$(cat)"

if ! command -v jq >/dev/null 2>&1; then
  exit 0
fi

file_path="$(printf '%s' "$input" | jq -r '.tool_input.file_path // .tool_input.filePath // empty' 2>/dev/null || true)"

if [[ -z "$file_path" ]]; then
  exit 0
fi

# Only Python.
if [[ "$file_path" != *.py ]]; then
  exit 0
fi

# Ensure file exists.
if [[ ! -f "$file_path" ]]; then
  exit 0
fi

if [[ -z "${CLAUDE_PROJECT_DIR:-}" ]]; then
  exit 0
fi

ruff_bin="$CLAUDE_PROJECT_DIR/.venv/bin/ruff"
if [[ ! -x "$ruff_bin" ]]; then
  exit 0
fi

# Run from project root (so ruff picks up config).
cd "$CLAUDE_PROJECT_DIR"

"$ruff_bin" format --quiet "$file_path" 2>/dev/null || true
"$ruff_bin" check --fix --quiet "$file_path" 2>/dev/null || true

exit 0
