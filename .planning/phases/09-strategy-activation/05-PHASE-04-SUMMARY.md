# SUMMARY: Phase 04 - MEAN_REVERT Decision

## Goal

Resolve the integrity gap where `StrategyType.STRATEGY_MEAN_REVERT` could be selected by `StrategySelector` but had no dedicated implementation, by implementing an opt-in mean reversion signal leg (BB+RSI) and integrating it into routing + validation.

## Work Completed (vs plan)

### ✅ Mean Revert implementation (opt-in)
- Implemented a deterministic, backtest-safe Mean Reversion candidate generator based on **Bollinger Bands + RSI (Wilder)**.
- Integrated MEAN_REVERT into `GoldScalperStrategy` decision flow with explicit gating:
  - `enable_mean_revert` toggle (defaults to `False`)
  - requires `StrategySelector` to select `STRATEGY_MEAN_REVERT`
- Added `RouterArm.MEAN_REVERT` wiring so AdaptiveEVRouter can attribute performance to the MR leg.

### ✅ Validation gate
- `mypy --strict nautilus_gold_scalper/` → PASS
- `pytest -q` → PASS

### ✅ Quick backtest (1 week)
Plan command expects:

```bash
python -m nautilus_gold_scalper.run_backtest --start 2024-01-01 --end 2024-01-07
```

Observed output (2024-01-01 → 2024-01-07 quick run):
- Dataset: `data/raw/full_parquet/xauusd_2003_2025_stride20_full.parquet`
- Ticks loaded: `29,654` (2024-01-02 → 2024-01-05 slice)
- Trades: `5` (W:2 L:3)
- Order fills: `10`
- Final balance: `$99,865.68`
- Total PnL: `$-134.32 (-0.13%)`
- No runtime `[ERROR]` / `[FAILSAFE]` log events (grep checked)

## Key Decisions

- **Decision = IMPLEMENT** (recorded in `orchestration/PHASE_04_DECISION.md`).
- Implementation is **opt-in** (`enable_mean_revert = false` by default) to avoid unintended behavior change.
- Mean Revert is treated as a **candidate generator** feeding the same routing/scoring pipeline as other legs.

## Files Changed

- `nautilus_gold_scalper/src/signals/mean_revert.py`
- `nautilus_gold_scalper/src/strategies/gold_scalper_strategy.py`
- `nautilus_gold_scalper/src/strategies/adaptive_router.py`
- `nautilus_gold_scalper/src/strategies/base_strategy.py`
- `nautilus_gold_scalper/src/risk/time_constraint_manager.py`
- `nautilus_gold_scalper/tests/test_signals/test_mean_revert.py`
- `.planning/phases/09-strategy-activation/orchestration/PHASE_04_DECISION.md`
- `.planning/phases/09-strategy-activation/orchestration/MEAN_REVERT_RESEARCH.md`

## Commands Run

- `.venv/bin/mypy --strict nautilus_gold_scalper/`
- `.venv/bin/pytest -q`
- `.venv/bin/python -m nautilus_gold_scalper.run_backtest --start 2024-01-01 --end 2024-01-07 --reports summary --quiet`

## Risks / Follow-ups

- Mean Revert edge is unproven on full sample/regimes; treat Phase 04 as **implementation + wiring**, not GO.
- Next validation step should be portfolio-level evaluation (Phase 06) with falsification-first patterns (ghost test / shifted levels) and Monte Carlo survival under Apex constraints.

## Next Step

Proceed to `06-PHASE-05-PLAN.md` (framework integration) or to the next planned strategy activation, keeping MR disabled until Oracle/CRITIC validation confirms it adds edge.
