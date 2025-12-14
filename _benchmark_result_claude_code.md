# BENCHMARK RESULT

| Field | Value |
|-------|-------|
| **Platform** | claude_code |
| **Test Version** | 1.0 |
| **Date** | 2025-12-13 20:15:25 |

---

## TIMING

| Metric | Value |
|--------|-------|
| **Start** | 20:15:25 |
| **End** | 20:17:03 |
| **Total Duration** | 98 segundos |

---

## SUBAGENT CALLS

| ID  | Type    | Called | Returned | Duration | Agent ID |
|-----|---------|--------|----------|----------|----------|
| A   | Explore | ✅     | ✅       | ~33s     | a109dad  |
| B   | Explore | ✅     | ✅       | ~33s     | a2ec3cc  |
| C   | Explore | ✅     | ✅       | ~33s     | afd5472  |
| D   | Explore | ✅     | ✅       | ~65s     | a7c37f3  |

**Nota:** Subagentes A, B, C foram chamados em paralelo (mesma janela de ~33s). Subagente D foi chamado sequencialmente após os 3 primeiros retornarem.

---

## RESULTS

### Subagent A (Python files)

**Total de arquivos .py em `nautilus_gold_scalper/`: 95 arquivos**

**Top 5 maiores arquivos (por tamanho em bytes):**

| Rank | Tamanho | Arquivo |
|------|---------|---------|
| 1 | 56,311 bytes | `/src/execution/_archive/apex_adapter.py` |
| 2 | 55,955 bytes | `/src/strategies/gold_scalper_strategy.py` |
| 3 | 38,745 bytes | `/src/indicators/footprint_analyzer.py` |
| 4 | 37,759 bytes | `/src/signals/confluence_scorer.py` |
| 5 | 35,385 bytes | `/scripts/run_backtest.py` |

**Observações:**
- Total combinado dos top 5: ~224 KB
- Maior arquivo ativo é a estratégia principal (gold_scalper_strategy.py)

---

### Subagent B (MD files)

**Total de arquivos .md em DOCS/: 435 arquivos**

**5 arquivos mais recentes (por data de modificação):**

| Rank | Data | Arquivo |
|------|------|---------|
| 1 | 2025-12-13 10:50 | `DOCS/prompt_migracao_nautilus.md` |
| 2 | 2025-12-13 10:50 | `DOCS/_INDEX.md` |
| 3 | 2025-12-13 10:50 | `DOCS/06_REFERENCE/XAUUSD_TDS_M15_CONFIG_SUMMARY.md` |
| 4 | 2025-12-13 10:50 | `DOCS/06_REFERENCE/INTEGRATIONS/MCP_RECOMMENDATIONS.md` |
| 5 | 2025-12-13 10:50 | `DOCS/06_REFERENCE/CLAUDE_REFERENCE.md` |

**Observação:** Todos os 5 mais recentes foram modificados hoje às 10:50 AM.

---

### Subagent C (Droids)

**Tamanho total do diretório `.factory/droids/`: 672 KB**

**Total de arquivos de droid (*.md): 26 arquivos**

| Categoria | Arquivos | Tamanho |
|-----------|----------|---------|
| **Ativos (root)** | 13 | ~157K |
| **Archived (versões antigas)** | 2 | ~43K |
| **Archive (pré-inheritance)** | 11 | ~393K |
| **TOTAL** | **26** | **672K** |

**Droids ativos (root):**

| Arquivo | Tamanho |
|---------|---------|
| `argus-quant-researcher.md` | 14K |
| `bmad-builder.md` | 5.0K |
| `crucible-gold-strategist.md` | 5.9K |
| `forge-mql5-architect.md` | 28K |
| `generic-code-reviewer.md` | 13K |
| `git-guardian.md` | 15K |
| `nautilus-nano.md` | 8.5K |
| `nautilus-trader-architect.md` | 12K |
| `onnx-model-builder.md` | 15K |
| `oracle-backtest-commander.md` | 8.8K |
| `performance-optimizer.md` | 10K |
| `sentinel-apex-guardian.md` | 7.2K |
| `trading-project-documenter.md` | 4.9K |

---

### Subagent D (AGENTS.md)

| Métrica | Valor |
|---------|-------|
| **Total de linhas** | 1.173 linhas |
| **Versão** | 3.7.1 |
| **Última atualização** | 2025-12-12 |

**Changelog v3.7.1:**
- Adicionou thresholds de validação (SQN≥2.0, PSR≥0.85, DSR>0, PBO<25%)
- Corrigiu Monte Carlo DD de 8%→4%
- Adicionou sample_requirements (100+ trades, 2+ anos)
- Adicionou REVIEWER ao quick_reference
- Alinhado com droids ORACLE/SENTINEL

---

## EXECUTION MODE

| Aspecto | Valor |
|---------|-------|
| **Parallel execution attempted** | SIM |
| **Evidence** | Subagentes A, B, C foram chamados em um único bloco `<function_calls>` com 3 invocações `<invoke name="Task">` simultâneas. Retornaram todos na mesma resposta (~33s cada, executados em paralelo). Subagente D foi chamado em bloco separado após os 3 primeiros retornarem. |

---

## RAW METRICS

| Métrica | Valor |
|---------|-------|
| **Subagents spawned** | 4 |
| **Subagents completed** | 4 |
| **Success rate** | 100% |
| **Errors** | none |
| **Parallel batch size** | 3 (A, B, C) |
| **Sequential calls** | 1 (D) |

---

## SUMMARY

```
┌─────────────────────────────────────────────────────────┐
│                   BENCHMARK SUMMARY                      │
├─────────────────────────────────────────────────────────┤
│  Platform:           Claude Code                         │
│  Total Duration:     98 seconds                          │
│  Subagents Called:   4                                   │
│  Subagents Success:  4 (100%)                            │
│  Parallel Execution: YES (3 concurrent)                  │
│  Errors:             0                                   │
├─────────────────────────────────────────────────────────┤
│  Data Retrieved:                                         │
│  - Python files:     95 in nautilus_gold_scalper/        │
│  - MD files:         435 in DOCS/                        │
│  - Droid files:      26 in .factory/droids/ (672KB)      │
│  - AGENTS.md:        1,173 lines (v3.7.1)                │
└─────────────────────────────────────────────────────────┘
```

---

*Generated by Claude Code benchmark test v1.0*
*Timestamp: 2025-12-13 20:17:03 (America/Sao_Paulo)*
