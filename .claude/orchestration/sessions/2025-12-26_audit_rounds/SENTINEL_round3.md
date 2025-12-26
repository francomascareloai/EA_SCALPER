# SENTINEL round 3 (Apex compliance recheck)

- Date: 2025-12-26
- Scope: bars-mode temporal correctness + staged time gates + config wiring
- Verdict: **NO_GO (conservative pending confirmation)**

## What passes

- Bars timestamp shift uses `ltf_minutes` and adds a step sanity-check:
  - `nautilus_gold_scalper/scripts/backtest/run_backtest.py:491`
  - `nautilus_gold_scalper/scripts/backtest/run_backtest.py:562`
- Staged time gates (urgent 16:30, emergency 16:55, cutoff 16:59) are implemented and enforced:
  - `nautilus_gold_scalper/src/risk/time_constraint_manager.py:89`
  - `nautilus_gold_scalper/src/risk/time_constraint_manager.py:146`
  - `nautilus_gold_scalper/src/strategies/gold_scalper_strategy.py:1537`
  - `nautilus_gold_scalper/src/strategies/gold_scalper_strategy.py:3645`
- Config wiring from YAML `time.*` into `GoldScalperConfig` and then into `TimeConstraintManager`:
  - `nautilus_gold_scalper/configs/strategy_config.yaml:122`
  - `nautilus_gold_scalper/scripts/backtest/run_backtest.py:714`
  - `nautilus_gold_scalper/scripts/backtest/run_backtest.py:877`
  - `nautilus_gold_scalper/src/strategies/gold_scalper_strategy.py:1004`

## Remaining blockers for unconditional GO

- Bars timestamp basis ambiguity: loader always shifts by duration; if bars are already close-timestamped, this will double-shift.
  - `nautilus_gold_scalper/scripts/backtest/run_backtest.py:565`
- Feed-stall protection disabled by default in `feed=bars` path (timer off unless overridden).
  - `nautilus_gold_scalper/scripts/backtest/run_backtest.py:2695`

## Validation steps

- `pytest -q nautilus_gold_scalper/tests/test_risk/test_time_constraint_manager.py`
- Run a narrow backtest around 16:25–17:05 ET and confirm:
  - no new orders after 16:30 ET
  - flatten begins at 16:55 ET
  - flat by 16:59 ET
