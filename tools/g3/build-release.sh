#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
G3_DIR="${ROOT_DIR}/tools/g3"

cd "${G3_DIR}"
cargo build --release

mkdir -p "${ROOT_DIR}/tools/bin"
ln -sf "${G3_DIR}/target/release/g3" "${ROOT_DIR}/tools/bin/g3"

if [[ ! -f "${ROOT_DIR}/g3" || -L "${ROOT_DIR}/g3" ]]; then
  cat > "${ROOT_DIR}/g3" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
exec "${ROOT_DIR}/tools/bin/g3" -c "${ROOT_DIR}/tools/g3/config.local.toml" "$@"
EOF
  chmod +x "${ROOT_DIR}/g3"
fi

echo "OK: ${ROOT_DIR}/tools/bin/g3 -> ${G3_DIR}/target/release/g3"
echo "OK: ${ROOT_DIR}/g3 uses ${ROOT_DIR}/tools/g3/config.local.toml"
