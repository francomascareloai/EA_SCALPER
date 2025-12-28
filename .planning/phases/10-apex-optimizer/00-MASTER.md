# Phase 10: Apex Optimizer — Master (Research + Decisions + Plan Breakdown)

## Objective
Transformar o `DOCS/02_IMPLEMENTATION/APEX_OPTIMIZER_PRD.md` em um conjunto de planos executáveis e atômicos (2–3 tasks por plano), priorizando **reuso do que já existe** e fechando os gaps reais do código.

## Context (authoritative)
- PRD: `DOCS/02_IMPLEMENTATION/APEX_OPTIMIZER_PRD.md`
- Implementação atual (já existe):
  - `nautilus_gold_scalper/src/optimization/optimizer.py` (ApexOptimizer core; TODO: grid/random + integração backtest)
  - `nautilus_gold_scalper/src/optimization/config.py` (YAML spec + ParameterSpec dotpath)
  - `nautilus_gold_scalper/src/optimization/search/bayesian.py` (Optuna/TPE + pruning)
  - `nautilus_gold_scalper/src/optimization/validation/wfa_inline.py` (inline WFA)
  - `nautilus_gold_scalper/src/optimization/constraints/apex.py` (Apex compliance checker)
  - `nautilus_gold_scalper/src/optimization/reporting/summary.py` (reporting)
  - `nautilus_gold_scalper/src/optimization/__main__.py` (CLI; ainda sem integração de backtest)
- Backtest runner existente:
  - `nautilus_gold_scalper/scripts/backtest/run_backtest.py` (class `BacktestRunner`)
- Stress/validação reutilizável (scripts/ORACLE):
  - `scripts/oracle/monte_carlo.py` (BlockBootstrapMC)
  - `scripts/oracle/rigorous_validator.py` (WFA/CPCV/MC; referência de métricas e execução realista)

---

## Implementation Status (2025-12-28)

### Summary Table

| Plan | Description | Status | Progress |
|------|-------------|--------|----------|
| **10-01** | Backtest Integration | ✅ COMPLETE | 100% |
| **10-02** | Grid/Random Search | ✅ COMPLETE | 100% |
| **10-03** | Constraints Semantics | ⚠️ PARTIAL | 75% |
| **10-04** | Monte Carlo Layer 3 | ✅ COMPLETE | 95% |
| **10-05** | Anti-Overfit Detectors | ✅ COMPLETE | 100% |
| **10-06** | Handoff Format | ✅ COMPLETE | 100% |

### Detailed Status

#### 10-01: Backtest Integration ✅ (Completed 2025-12-28)
- ✅ `backtest_adapter.py` created as reusable module
- ✅ `create_backtest_fn()` factory with `BacktestAdapterConfig`
- ✅ CLI `__main__.py` runs real optimization (not placeholder)
- ✅ `test_backtest_adapter_smoke.py` with 14 passing tests
- ✅ CLI flags for smoke testing: `--train-start`, `--train-end`, `--feed`, etc.

#### 10-02: Grid/Random Search ✅
- ✅ `search/grid.py` with max_grid_size cap, lazy iterator
- ✅ `search/random.py` with LHS and reproducible seed
- ✅ `StreamingSobolGenerator` bonus (~3.5x better than LHS)
- ✅ CLI accepts `--mode grid|random`
- ✅ Tests exist and pass

#### 10-03: Constraints Semantics ⚠️
- ✅ `get_constraint_values()` returns Optuna format
- ✅ `-999.0` hard reject consistent across all searchers
- ✅ Hard/soft separation correct
- ❌ `test_constraints_semantics.py` MISSING (no edge case tests)

#### 10-04: Monte Carlo Layer 3 ✅
- ✅ `stress/monte_carlo_dd.py` - new optimized implementation
- ✅ Runs only for top_n candidates
- ✅ `mc_95_dd`/`mc_99_dd` fields in TrialResult
- ✅ Reporting includes stress fields
- ⚠️ Some specific test files missing (covered by generic tests)

#### 10-05: Anti-Overfit Detectors ✅ (Implemented 2025-12-28)
- ✅ `constraints/anti_overfit.py` created with all detectors
- ✅ `detect_cliff()` - detects params at edge of range
- ✅ `detect_island()` - detects isolated optima
- ✅ `detect_regime_bias()` - detects regime-specific overfit
- ✅ `overfit_warnings` field added to TrialResult
- ✅ Integrated into optimizer.py (Layer 3c)
- ✅ `test_anti_overfit.py` with 21 tests (all passing)

#### 10-06: Handoff Format ✅ (Completed 2025-12-28)
- ✅ `generate_handoff()` in summary.py
- ✅ Ghost Test fully implemented
- ✅ Stratification Summary section
- ✅ Overfitting Analysis section (cliff/island/regime_bias)
- ✅ Apex Compliance Limits section with buffers
- ✅ CLI `--help` shows happy path
- ✅ `test_handoff_format.py` with 13 passing tests

---

## Missing Files

### Implementation
- ~~`nautilus_gold_scalper/src/optimization/backtest_adapter.py`~~ ✅ Created 2025-12-28
- ~~`nautilus_gold_scalper/src/optimization/constraints/anti_overfit.py`~~ ✅ Created 2025-12-28

### Tests
- ~~`tests/test_optimization/test_backtest_adapter_smoke.py`~~ ✅ Created 2025-12-28 (14 tests)
- `tests/test_optimization/test_constraints_semantics.py`
- ~~`tests/test_optimization/test_anti_overfit.py`~~ ✅ Created 2025-12-28 (21 tests)
- `tests/test_optimization/test_reporting_overfit_fields.py`
- `tests/test_optimization/test_reporting_stress_fields.py`
- ~~`tests/test_optimization/test_handoff_format.py`~~ ✅ Created 2025-12-28 (13 tests)

### Summaries
- ~~`10-01-SUMMARY.md`~~ ✅ Created 2025-12-28
- `10-03-SUMMARY.md`
- `10-04-SUMMARY.md`
- ~~`10-05-SUMMARY.md`~~ ✅ Created 2025-12-28
- ~~`10-06-SUMMARY.md`~~ ✅ Created 2025-12-28

---

## Decisions Made

1. **Backtest Integration:** Implemented via `scripts/optimize.py` instead of separate `backtest_adapter.py`
2. **Monte Carlo:** New implementation in `stress/monte_carlo_dd.py` instead of reusing `scripts/oracle/monte_carlo.py`
3. **PBO/CPCV:** Partially implemented (exists in `test_pbo_cscv.py` tests)

---

## Proposed Plan Breakdown (atomic plans)

- 10-01: Audit + wiring do `BacktestRunner` para `backtest_fn` (integração mínima end-to-end)
- 10-02: Implementar `grid` e `random` search (só o necessário + dry-run/grid size)
- 10-03: Consolidar semântica de constraints (hard reject vs penalty) + testes
- 10-04: Integrar Monte Carlo (Layer 3) no pipeline (top N) + persistência em report
- 10-05: Implementar anti-overfit detectors (cliff/island/regime-bias) + incluir no report/handoff
- 10-06: Handoff format (ORACLE/SENTINEL) + checklist de validação (pytest/mypy) e exemplo de execução

## Validation Gates (global)
- `./.venv/bin/pytest -q`
- `./.venv/bin/mypy --strict nautilus_gold_scalper/src/optimization`

## Orchestration Analysis
See `orchestration/2024-12-24_trendfollow_deep_analysis/ORCHESTRATION_SUMMARY.md` for detailed analysis of the TrendFollow strategy validation sessions.

## Execution Guide
See `EXECUTION_GUIDE.md` for step-by-step instructions to complete remaining work.
