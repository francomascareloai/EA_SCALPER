#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
CFG="${ROOT_DIR}/tools/g3/config.local.toml"
G3="${ROOT_DIR}/g3"

if [[ ! -f "${CFG}" ]]; then
  echo "ERROR: missing ${CFG}"
  echo "Create it from: ${ROOT_DIR}/tools/g3/config.local.toml.example"
  exit 1
fi

api_key="$(grep -m1 -E '^[[:space:]]*api_key[[:space:]]*=' "${CFG}" 2>/dev/null | sed -E 's/.*"([^"]+)".*/\1/' || true)"
base_url="$(grep -m1 -E '^[[:space:]]*base_url[[:space:]]*=' "${CFG}" 2>/dev/null | sed -E 's/.*"([^"]+)".*/\1/' || true)"
model="$(grep -m1 -E '^[[:space:]]*model[[:space:]]*=' "${CFG}" 2>/dev/null | sed -E 's/.*"([^"]+)".*/\1/' || true)"

if [[ -z "${api_key}" || -z "${base_url}" || -z "${model}" ]]; then
  echo "ERROR: couldn't parse api_key/base_url/model from ${CFG}"
  exit 1
fi

echo "Proxy: ${base_url}"
echo "Model: ${model}"

echo ""
echo "[1/3] Proxy /v1/models..."
curl -fsS -H "Authorization: Bearer ${api_key}" "${base_url}/models" >/dev/null
echo "OK"

echo ""
echo "[2/3] Proxy /v1/chat/completions (non-stream)..."
payload="$(printf '{"model":"%s","messages":[{"role":"user","content":"ping"}],"stream":false,"max_completion_tokens":16}' "${model}")"
curl -fsS -H "Authorization: Bearer ${api_key}" -H "Content-Type: application/json" \
  -d "${payload}" "${base_url}/chat/completions" >/dev/null
echo "OK"

echo ""
echo "[3/3] g3 single-shot..."
if [[ ! -x "${G3}" ]]; then
  echo "ERROR: missing executable ${G3}"
  exit 1
fi

# Keep it tiny to avoid burning tokens.
"${G3}" "reply with exactly: pong" >/dev/null
echo "OK"

echo ""
echo "All smoke tests passed."
