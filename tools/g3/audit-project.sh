#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
CFG="${ROOT_DIR}/tools/g3/config.local.toml"

if [[ ! -f "${CFG}" ]]; then
  echo "ERROR: missing ${CFG}"
  echo "Create it from: ${ROOT_DIR}/tools/g3/config.local.toml.example"
  exit 1
fi

echo "Running deep audit (read-only) with g3..."
echo "Tip: Ctrl-C stops; increase --max-turns for deeper coverage."
echo ""

cd "${ROOT_DIR}"

./g3 --config "${CFG}" --workspace "${ROOT_DIR}" --autonomous --max-turns 8 --requirements "$(cat <<'EOF'
Faça uma análise profunda do repositório EA_SCALPER_XAUUSD.

REGRAS:
1) Modo SOMENTE-LEITURA: NÃO modificar nenhum arquivo de código/Config. Não criar commits. Não rodar comandos destrutivos.
2) Use ferramentas para inspecionar a estrutura do repo (listar diretórios, buscar pontos críticos, ler docs).
3) Produza um relatório final em `G3_AUDIT_REPORT.md` na raiz do projeto.

O relatório deve incluir:
- Arquitetura (módulos/pastas principais e propósito)
- Pontos críticos e riscos (especialmente trading/risk/apex compliance)
- Dívidas técnicas (acoplamento, duplicação, scripts grandes, configs)
- Sugestões priorizadas (P0/P1/P2) com ações concretas
- “Quick wins” (mudanças pequenas com grande impacto)
EOF
)"
