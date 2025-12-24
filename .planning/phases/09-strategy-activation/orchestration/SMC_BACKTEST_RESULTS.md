# SMC_BACKTEST_RESULTS

## Purpose

Document the **actual backtest results** used to validate Phase 02.

This file focuses on:
- What was run (inputs, period)
- What was observed (trade count, PnL, DD)
- Whether Phase 02 acceptance criteria are met

Important: Phase 02 requires a statistically meaningful sample (≥200 trades) for GO. If the sample is too small, the correct output is **NO-GO due to insufficient evidence**.

## Backtest artifact location (evidence)

This Phase 02 work references the latest backtest artifacts captured under:
- `nautilus_gold_scalper/logs/backtest_latest/`
  - `positions.csv`
  - `fills.csv`
  - `account.csv`

## Observed results (from latest artifacts)

### Trade count

From `nautilus_gold_scalper/logs/backtest_latest/positions.csv`:
- Position rows: **4**
- “Snapshot” rows: **3**

Interpretation:
- The run produced **4 closed positions** total (very low sample).

### PnL

From `positions.csv` (realized PnL per position):
- Total realized PnL: **+$38.93** (USD)

From `nautilus_gold_scalper/logs/backtest_latest/account.csv`:
- Final account total: **$100,038.93**

### Execution / slippage

From `nautilus_gold_scalper/logs/backtest_latest/fills.csv`:
- Most fills show `slippage = 0.0`
- One STOP_MARKET fill shows `slippage ≈ 0.82`

Note:
- With only 4 positions, any inference about slippage realism or distribution is not meaningful.

## Phase 02 required metrics vs observed

Phase 02 plan requires (for GO):
- WFE ≥ 0.6
- SQN ≥ 2.0
- PSR ≥ 0.85
- MC95DD < 4%
- Min trades ≥ 200
- Profit Factor > 1.3

### Observed vs thresholds

- **Trades:** 4 (FAIL; threshold ≥200)
- **SQN / PSR / WFE / MC95DD / PF:** Not computable here with confidence given the extremely small trade sample.

## Interpretation

- These results are **not sufficient to claim edge** or validate SMC scoring thresholds.
- The correct Phase 02 outcome based on the plan’s acceptance criteria is **NO-GO (insufficient sample / insufficient evidence)**.

## Link to Phase 01 diagnostic evidence

Phase 01 diagnostic runs also showed very low trade counts in early windows:
- 2024-01-01 → 2024-01-07: 4 trades
- 2024-01-01 → 2024-02-01: 6 trades
- 2024-01-01 → 2024-04-01: 6 trades
  - Evidence: `.planning/phases/09-strategy-activation/orchestration/PHASE_01_DIAGNOSTIC_RESULTS.md`

This suggests the primary blocker is not “one bad week”, but **signal scarcity** (or gating that is too strict / factors never firing).

## Next actions (for Phase 03+ or Phase 02 follow-up)

- Run a longer backtest window (multi-year) and ensure ≥200 trades.
- Capture metric outputs (WFE/SQN/PSR/MC) from the reporting pipeline.
- Re-check factor activation counters to confirm OB/FVG/Sweep/AMD/MTF/Footprint contribute non-zero frequently enough.
