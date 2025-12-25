# DOCS INDEX

**Last Updated**: 2025-12-25
**Status**: Reorganizado conforme DOCS_REORGANIZATION_PLAN
**Note**: 2025-12-01 FORGE — ONNX gate optional + spread guard wired in `MQL5/Experts/EA_SCALPER_XAUUSD.mq5`; model path resolution hardened in `Bridge/COnnxBrain.mqh`.

---

## Quick Navigation

| Preciso de... | Vá para |
|---------------|---------|
| **🐙 NAUTILUS MIGRATION** | `02_IMPLEMENTATION/NAUTILUS_MIGRATION_MASTER_PLAN.md` |
| Código Nautilus Python | `nautilus_gold_scalper/src/` |
| Plano de implementação MQL5 | `02_IMPLEMENTATION/PLAN_v1.md` |
| Progresso atual | `02_IMPLEMENTATION/PROGRESS.md` |
| Deliverables de fase | `02_IMPLEMENTATION/PHASES/PHASE_N/` |
| Audit do código | `02_IMPLEMENTATION/PHASES/PHASE_0_AUDIT/` |
| Audit Analysis 2025-12-01 | `02_IMPLEMENTATION/PHASES/PHASE_0_AUDIT/20251201_ANALYSIS_MODULES_FIX.md` |
| Heavy Audit 2025-12-24 (NO-GO) | `.planning/phases/09-strategy-activation/orchestration/2025-12-24_heavy-audit/SYNTHESIS_FINAL_VERDICT.md` |
| Relatórios de backtest | `04_REPORTS/BACKTESTS/` |
| Validação (WFA/MC) | `04_REPORTS/VALIDATION/` |
| ML filter (telemetry→dataset→WFA) | `../nautilus_gold_scalper/scripts/ml/` |
| Decisões GO/NO-GO | `04_REPORTS/DECISIONS/` |
| Ideias e melhorias (Nautilus) | `../nautilus_gold_scalper/FUTURE_IMPROVEMENTS.md` |
| Pesquisa e findings | `03_RESEARCH/` |
| Auditorias de repos | `03_RESEARCH/REPOS/20251225_REPO_AUDIT_QTRADEX.md` |
| Guias de setup | `05_GUIDES/SETUP/` |
| Referência técnica | `06_REFERENCE/` |
| MCPs e integrações | `06_REFERENCE/INTEGRATIONS/` |
| Arquivos antigos | `_ARCHIVE/` |
| Especificação do time | `01_AGENTS/TEAM_SPECIFICATION.md` |
| Party Mode sessions | `01_AGENTS/PARTY_MODE/` |

---

## Agent Ownership

| Agent | Owns | Creates In |
|-------|------|------------|
| 🔥 CRUCIBLE | Strategy | `03_RESEARCH/FINDINGS/` |
| 🛡️ SENTINEL | Risk | `04_REPORTS/DECISIONS/` |
| ⚒️ FORGE | Code | `02_IMPLEMENTATION/PHASES/`, `05_GUIDES/` |
| 🔮 ORACLE | Validation | `04_REPORTS/BACKTESTS/`, `04_REPORTS/VALIDATION/` |
| 🔍 ARGUS | Research | `03_RESEARCH/PAPERS/`, `03_RESEARCH/FINDINGS/` |
| 🐙 NAUTILUS | Migration | `nautilus_gold_scalper/src/` |
| ALL | Progress | `02_IMPLEMENTATION/PROGRESS.md` |

---

## Naming Conventions

| Tipo | Pattern | Exemplo |
|------|---------|---------|
| Reports | `YYYYMMDD_TYPE_NAME.md` | `20251130_WFA_REPORT.md` |
| Findings | `TOPIC_FINDING.md` | `SMC_ORDER_BLOCKS_FINDING.md` |
| Papers | `YYYYMMDD_AUTHOR_TITLE.md` | `20251130_KOLM_ORDER_FLOW.md` |
| Guides | `TOOL_ACTION.md` | `MT5_SETUP.md` |
| Sessions | `SESSION_NNN_YYYY-MM-DD.md` | `SESSION_001_2025-11-29.md` |
| Decisions | `YYYYMMDD_DECISION.md` | `20251130_GO_NOGO.md` |

---

## Folder Structure

```
DOCS/
├── _INDEX.md                 # Este arquivo
├── _ARCHIVE/                 # 🗄️ Cold storage
│   ├── LEGACY/               # Docs superseded
│   ├── BOOKS/                # PDFs (já no RAG)
│   └── OLD_PROMPTS/          # Prompts antigos
│
├── 00_PROJECT/               # 📋 Project-level
│   └── DOCS_REORGANIZATION_PLAN.md
│
├── 01_AGENTS/                # 🤖 Sistema de Agentes
│   ├── TEAM_SPECIFICATION.md
│   ├── PARTY_MODE/           # Sessões colaborativas
│   └── BACKUPS/              # Backups de skills
│
├── 02_IMPLEMENTATION/        # 🚀 Implementação
│   ├── PLAN_v1.md            # Plano atual
│   ├── PROGRESS.md           # Tracker (criar quando iniciar)
│   └── PHASES/
│       ├── PHASE_0_AUDIT/
│       ├── PHASE_1_DATA/
│       ├── PHASE_2_VALIDATION/
│       ├── PHASE_3_ML/
│       ├── PHASE_4_INTEGRATION/
│       ├── PHASE_5_HARDENING/
│       └── PHASE_6_PAPER/
│
├── 03_RESEARCH/              # 🔍 Pesquisa (ARGUS)
│   ├── PAPERS/               # Resumos de papers
│   ├── FINDINGS/             # Descobertas
│   └── REPOS/                # Links (não clonar aqui)
│
├── 04_REPORTS/               # 📊 Relatórios (ORACLE)
│   ├── BACKTESTS/
│   ├── VALIDATION/
│   └── DECISIONS/
│
├── 05_GUIDES/                # 📚 Guias
│   ├── SETUP/
│   ├── USAGE/
│   └── TROUBLESHOOTING/
│
└── 06_REFERENCE/             # 📖 Referência Técnica
    ├── CLAUDE_REFERENCE.md
    ├── MQL5/
    ├── PYTHON/
    └── INTEGRATIONS/
        ├── MCP_INDEX.md
        └── MCP_RECOMMENDATIONS.md
```

---

## External Data (Moved from DOCS)

| O que | Nova localização |
|-------|------------------|
| Código MQL5 scraped | `data/scraped_mql5/` |
| Repos ML externos | `data/external_repos/` |

---

## RAG Status

| RAG DB | Conteúdo | Status |
|--------|----------|--------|
| `mql5-docs` | Reference MQL5, book tutorials | ✅ Indexado |
| `mql5-books` | PDFs trading/ML em `_ARCHIVE/BOOKS/` | ✅ Indexado |

---

*"Um lugar para cada coisa, cada coisa em seu lugar."*
