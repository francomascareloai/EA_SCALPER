# PHASE_01_DIAGNOSTIC_RESULTS

## Purpose

Provide **real** diagnostic numbers (not estimates) required by the Phase 01 gate:
- Factor activation report (real counts)
- Trade count > 50 **or** Plan B triggered

## Evidence: Real backtest outputs

### Quick backtest (plan canonical)
Command:
```bash
.venv/bin/python -m nautilus_gold_scalper.run_backtest --start 2024-01-01 --end 2024-01-07 --reports summary --out-dir logs/backtest_2024-01-01_2024-01-07
```
Observed:
- Trades: `4`
  - Evidence: `logs/backtest_2024-01-01_2024-01-07/positions.csv`
  - Captured stdout: `.planning/phases/09-strategy-activation/orchestration/evidence/phase01_backtest_stdout_2024-01-01_2024-01-07.txt`
- Factor counters:
  - Evidence JSON: `.planning/phases/09-strategy-activation/orchestration/evidence/phase01_factor_activation_counters_2024-01-01_2024-01-07.json`
  - Underlying stream: `logs/telemetry.jsonl` (large; do not commit)

### Extended window backtest (trade count check)
Command:
```bash
.venv/bin/python -m nautilus_gold_scalper.run_backtest --start 2024-01-01 --end 2024-02-01 --reports summary --out-dir logs/backtest_2024-01-01_2024-02-01
```
Observed:
- Trades: `6`
  - Evidence: `logs/backtest_2024-01-01_2024-02-01/positions.csv`
  - Captured stdout: `.planning/phases/09-strategy-activation/orchestration/evidence/phase01_backtest_stdout_2024-01-01_2024-02-01.txt`

Command:
```bash
.venv/bin/python -m nautilus_gold_scalper.run_backtest --start 2024-01-01 --end 2024-04-01 --reports summary --out-dir logs/backtest_2024-01-01_2024-04-01
```
Observed:
- Trades: `6`
  - Evidence: `logs/backtest_2024-01-01_2024-04-01/positions.csv`
  - Captured stdout: `.planning/phases/09-strategy-activation/orchestration/evidence/phase01_backtest_stdout_2024-01-01_2024-04-01.txt`

## Trade Count Gate

- Target: `Trades > 50`
- Actual (best seen so far in the runs above): `6`

### Plan B Trigger

✅ **Plan B TRIGGERED** (trade count < 50)

## Factor Activation Report

Source of truth:
- Strategy emits telemetry event `factor_activation_counters` on shutdown.
- Evidence JSON (persisted): `.planning/phases/09-strategy-activation/orchestration/evidence/phase01_factor_activation_counters_2024-01-01_2024-01-07.json`
- Underlying JSONL stream: `logs/telemetry.jsonl` (large; do not commit)

### Activation table (REAL numbers)

| Factor | Bars Analyzed | Times Fired | Activation Rate |
|--------|---------------|-------------|-----------------|
| Structure (BOS/CHoCH) | 37 | 37 | 100.00% |
| Order Blocks | 37 | 0 | 0.00% |
| FVG | 37 | 0 | 0.00% |
| Session Filter | 37 | 37 | 100.00% |
| MTF Alignment | 37 | 0 | 0.00% |
| AMD | 37 | 0 | 0.00% |
| Fibonacci | 37 | 0 | 0.00% |
| Footprint | 37 | 0 | 0.00% |
| Liquidity Sweep | 37 | 0 | 0.00% |

Notes:
- `Bars Analyzed` counts calls to `ConfluenceScorer.calculate_score(...)` (M5 bars processed by the scoring layer).
- `Times Fired` counts bars where the factor contributed a positive score (or, for Session Filter/MTF Alignment, where the boolean condition was true).

## Notes

- This file documents real backtest trade counts and explicitly triggers Plan B.
- Factor activation numbers are now available via telemetry evidence JSON.
