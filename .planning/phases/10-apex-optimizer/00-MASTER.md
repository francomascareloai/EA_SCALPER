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

## Current State vs PRD (delta)
- ✅ Layer 1 (Bayesian/Optuna) existe.
- ✅ Layer 2 (inline WFA + Apex checker) existe.
- ⚠️ Integração com backtest real está pendente (`__main__.py` e `optimizer.py` indicam TODO).
- ⚠️ Grid/Random search: não implementado em `optimizer.py` (modo != bayesian dá NotImplementedError).
- ⚠️ Layer 3 (stress): Monte Carlo/Degradation/anti-overfit e PBO estão no PRD/config, mas não estão conectados ao pipeline.
- ⚠️ “Apex compliance como constraint (não penalty)”: hoje o checker calcula `score_penalty` e o Optuna também faz hard reject (-999) quando constraint violada; precisamos padronizar a semântica.

## Decisions Needed (decision gates)
1. **Integração do backtest_fn**: Vamos adaptar `BacktestRunner` (`nautilus_gold_scalper/scripts/backtest/run_backtest.py`) para retornar exatamente `(trades_df, equity_series)` como esperado por `ApexOptimizer`?
2. **Fonte de Monte Carlo**: Reusar `scripts/oracle/monte_carlo.py` diretamente (import) ou copiar uma versão reduzida para `nautilus_gold_scalper/src/optimization/stress/`?
3. **PBO/CPCV**: Implementar já no Phase 10 (mínimo viável) ou deixar PBO para Phase 11 (mais pesado)?

## Proposed Plan Breakdown (atomic plans)
Each plan below should become a `10-XX-PLAN.md` with 2–3 tasks.

- 10-01: Audit + wiring do `BacktestRunner` para `backtest_fn` (integração mínima end-to-end)
- 10-02: Implementar `grid` e `random` search (só o necessário + dry-run/grid size)
- 10-03: Consolidar semântica de constraints (hard reject vs penalty) + testes
- 10-04: Integrar Monte Carlo (Layer 3) no pipeline (top N) + persistência em report
- 10-05: Implementar anti-overfit detectors (cliff/island/regime-bias) + incluir no report/handoff
- 10-06: Handoff format (ORACLE/SENTINEL) + checklist de validação (pytest/mypy) e exemplo de execução

## Validation Gates (global)
- `./.venv/bin/pytest -q`
- `./.venv/bin/mypy --strict nautilus_gold_scalper/src/optimization`

## Next Action
Se você aprovar o breakdown acima, eu gero os arquivos:
- `10-01-PLAN.md` … `10-06-PLAN.md`
com formato XML executável + protocolo obrigatório de execução.
