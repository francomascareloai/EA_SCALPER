#!/usr/bin/env bash
set -euo pipefail

# Guardrail for Claude Code Bash tool usage.
# Blocks destructive git ops and CLIProxy kills unless you explicitly decide otherwise.

input="$(cat)"

# Fast-path: avoid spawning jq unless the raw payload contains a potentially blocked token.
# This hook runs before every Bash tool call, so this keeps common commands snappy.
shopt -s nocasematch
case "$input" in
  *"git checkout"*|*"git switch"*|*"git restore"*|*"git reset --hard"*|*"git clean -fd"*|*"git clean -fx"*|*"pkill"*"cli-proxy-api"*|*"kill"*"cli-proxy-api"*|*"killall"*"cli-proxy-api"*)
    ;;
  *)
    shopt -u nocasematch
    exit 0
    ;;
esac
shopt -u nocasematch

# Preserve previous behavior: if jq isn't available, do nothing.
if ! command -v jq >/dev/null 2>&1; then
  exit 0
fi

cmd="$(printf '%s' "$input" | jq -r '.tool_input.command // empty' 2>/dev/null || true)"

# If we can't parse, do nothing.
if [[ -z "$cmd" ]]; then
  exit 0
fi

shopt -s nocasematch

# Git safety (repo policy).
if [[ "$cmd" == *"git checkout"* || "$cmd" == *"git switch"* ]]; then
  echo "Blocked by project policy: git checkout/switch requires explicit Franco confirmation." >&2
  shopt -u nocasematch
  exit 2
fi

if [[ "$cmd" == *"git restore"* || "$cmd" == *"git reset --hard"* || "$cmd" == *"git clean -fd"* || "$cmd" == *"git clean -fx"* ]]; then
  echo "Blocked by project policy: destructive git restore/reset/clean requires explicit Franco confirmation." >&2
  shopt -u nocasematch
  exit 2
fi

# CLIProxy protection (repo policy).
if [[ "$cmd" == *"pkill"*"cli-proxy-api"* || "$cmd" == *"kill"*"cli-proxy-api"* || "$cmd" == *"killall"*"cli-proxy-api"* ]]; then
  echo "Blocked by project policy: do not stop/restart CLIProxy without explicit Franco confirmation." >&2
  shopt -u nocasematch
  exit 2
fi

shopt -u nocasematch
exit 0
