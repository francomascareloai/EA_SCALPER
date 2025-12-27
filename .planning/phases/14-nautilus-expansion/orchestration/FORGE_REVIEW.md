# FORGE Review — Phase 14 Plan

AGENT: forge-nautilus
STATUS: COMPLETE
VERDICT: needs changes

Source plan:
- `/.planning/phases/14-nautilus-expansion/14-00-PLAN_MASTER.md`

Agent output (verbatim):

```
AGENT: FORGE-NAUTILUS
VERSION: 1.2
CLAUDE_MD_VERSION: 3.10.23
STATUS: COMPLETE
BUGS_FIXED: 0
```

Decision
- Option A (incremental): Implement Phase B→J behind config flags, reusing existing `nautilus_gold_scalper/src/risk/*`, `src/execution/*`, and `src/strategies/*` layers; add Nautilus-native hooks only where they strengthen enforcement (engine-level risk limits, TWAP algo).
- Option B (big refactor): Re-architect around Nautilus Actor/Controller patterns first, then retrofit risk/execution.
- Pick: Option A (lower duplication risk, preserves current Apex/DD/time gates + test suite stability).

Verdict
- needs changes

Rationale (feasibility + existing coverage)
- Phase B is feasible and partially already present: `RiskEngineConfig(bypass=False)` is already wired in `/home/franco/projetos/EA_SCALPER_XAUUSD/nautilus_gold_scalper/scripts/backtest/run_backtest.py` (engine setup). Installed Nautilus version is `nautilus-trader 1.221.0` and `RiskEngineConfig` supports `max_order_submit_rate`, `max_order_modify_rate`, `max_notional_per_order`, `debug`, `bypass`.
- Phase C conflicts with current project stance: `/home/franco/projetos/EA_SCALPER_XAUUSD/nautilus_gold_scalper/src/risk/position_sizer.py` explicitly documents keeping a custom sizer (Kelly/ATR/adaptive/DD throttles). Plan must reconcile this to avoid duplicative sizing logic.
- Phase D is feasible: TWAP exists as `TWAPExecAlgorithm` / `TWAPExecAlgorithmConfig` in installed examples (`.../site-packages/nautilus_trader/examples/algorithms/twap.py`), but engine integration API must be verified (how to register exec algorithms in your `NautilusEngine` build path).
- Many Phase E/F/G/H items overlap with existing code: time gates (`src/risk/time_constraint_manager.py`), HWM/DD semantics (`src/risk/drawdown_tracker.py`, `src/risk/prop_firm_manager.py`), selector/orchestration logic (`src/strategies/strategy_selector.py`), and anti-lookahead filters (`src/risk/virtual_gate.py`).

File-by-file touch list (expected)
- Plan reference only: `/home/franco/projetos/EA_SCALPER_XAUUSD/.planning/phases/14-nautilus-expansion/14-00-PLAN_MASTER.md`
- Engine/config wiring: `/home/franco/projetos/EA_SCALPER_XAUUSD/nautilus_gold_scalper/scripts/backtest/run_backtest.py`
- Config schema/knobs: `/home/franco/projetos/EA_SCALPER_XAUUSD/nautilus_gold_scalper/configs/strategy_config.yaml`, `/home/franco/projetos/EA_SCALPER_XAUUSD/nautilus_gold_scalper/src/optimization/config.py`
- Risk layering: `/home/franco/projetos/EA_SCALPER_XAUUSD/nautilus_gold_scalper/src/risk/position_sizer.py`, `/home/franco/projetos/EA_SCALPER_XAUUSD/nautilus_gold_scalper/src/risk/drawdown_tracker.py`, `/home/franco/projetos/EA_SCALPER_XAUUSD/nautilus_gold_scalper/src/risk/time_constraint_manager.py`, `/home/franco/projetos/EA_SCALPER_XAUUSD/nautilus_gold_scalper/src/risk/prop_firm_manager.py`
- Execution policy hooks: `/home/franco/projetos/EA_SCALPER_XAUUSD/nautilus_gold_scalper/src/execution/*`
- Indicator integration: `/home/franco/projetos/EA_SCALPER_XAUUSD/nautilus_gold_scalper/src/indicators/*`, `/home/franco/projetos/EA_SCALPER_XAUUSD/nautilus_gold_scalper/src/strategies/base_strategy.py`, `/home/franco/projetos/EA_SCALPER_XAUUSD/nautilus_gold_scalper/src/strategies/gold_scalper_strategy.py`
- Tests: `/home/franco/projetos/EA_SCALPER_XAUUSD/nautilus_gold_scalper/tests/test_risk/*`, `/home/franco/projetos/EA_SCALPER_XAUUSD/nautilus_gold_scalper/tests/test_execution/*`, `/home/franco/projetos/EA_SCALPER_XAUUSD/nautilus_gold_scalper/tests/test_integration/*`, `/home/franco/projetos/EA_SCALPER_XAUUSD/nautilus_gold_scalper/tests/test_backtest/*`

5 concrete adjustments to make the plan executable
1. Rewrite Phase C as “Sizing adapter + invariant tests”: keep `/src/risk/position_sizer.py` as canonical; optionally add a thin adapter that can call Nautilus `FixedRiskSizer` only if you can prove it matches XAUUSD point-value semantics and doesn’t regress DD throttles.
2. Phase B: make it a modification, not an addition: extend existing `RiskEngineConfig(bypass=False)` in `run_backtest.py` to also set `max_*_rate` and `max_notional_per_order` from YAML.
3. Phase D: add an explicit “verify engine registration API” step before coding.
4. Phase F: split Renko into a separate backtest mode.
5. Phase G/H: start with Actor bus signals, delay Controller.

API uncertainty that must be verified (installed Nautilus 1.221.0)
- How to access runtime RiskEngine instance to call `set_max_notional_per_order(...)`.
- Exact exec-algo registration API on `NautilusEngine` for `TWAPExecAlgorithm`.
- How to define/serialize custom `Data` classes for `subscribe_data(DataType(...))`.
- Strategy `on_save/on_load` signature and persistence plumbing.

Next step
- Edit `/.planning/phases/14-nautilus-expansion/14-00-PLAN_MASTER.md` to apply the 5 adjustments, then execute Phase B only with unit tests proving enforcement.
