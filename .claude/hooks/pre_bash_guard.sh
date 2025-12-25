#!/usr/bin/env bash
set -euo pipefail

# Guardrail for Claude Code Bash tool usage.
# Blocks destructive git ops and CLIProxy kills unless you explicitly decide otherwise.

input="$(cat)"

if ! command -v jq >/dev/null 2>&1; then
  exit 0
fi

cmd="$(printf '%s' "$input" | jq -r '.tool_input.command // empty' 2>/dev/null || true)"

# If we can't parse, do nothing.
if [[ -z "$cmd" ]]; then
  exit 0
fi

# Normalize for matching (lowercase).
cmd_lc="$(printf '%s' "$cmd" | tr '[:upper:]' '[:lower:]')"

# Git safety (repo policy).
if [[ "$cmd_lc" == *"git checkout"* || "$cmd_lc" == *"git switch"* ]]; then
  echo "Blocked by project policy: git checkout/switch requires explicit Franco confirmation." >&2
  exit 2
fi

if [[ "$cmd_lc" == *"git restore"* || "$cmd_lc" == *"git reset --hard"* || "$cmd_lc" == *"git clean -fd"* || "$cmd_lc" == *"git clean -fx"* ]]; then
  echo "Blocked by project policy: destructive git restore/reset/clean requires explicit Franco confirmation." >&2
  exit 2
fi

# CLIProxy protection (repo policy).
if [[ "$cmd_lc" == *"pkill"*"cli-proxy-api"* || "$cmd_lc" == *"kill"*"cli-proxy-api"* || "$cmd_lc" == *"killall"*"cli-proxy-api"* ]]; then
  echo "Blocked by project policy: do not stop/restart CLIProxy without explicit Franco confirmation." >&2
  exit 2
fi

exit 0
