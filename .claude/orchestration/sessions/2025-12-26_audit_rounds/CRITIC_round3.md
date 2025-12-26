# CRITIC round 3 (adversarial recheck)

- Date: 2025-12-26
- Scope: verify fixes for prior NO_GO items
- Verdict: **GO**

## Residual issues (<=5)

1) Bars timestamp shift assumes bar-start labeling; close-labeled inputs skew timing
- Evidence: `nautilus_gold_scalper/scripts/backtest/run_backtest.py:565`

2) Non-5m look-ahead risk is neutralized mainly because `bars_file` is hard-blocked unless M5
- Evidence: `nautilus_gold_scalper/scripts/backtest/run_backtest.py:1559`

3) Resample correctness relies on right-label + left-closed bins (must not regress)
- Evidence: `nautilus_gold_scalper/scripts/backtest/run_backtest.py:1182`

4) Config drift risk: other configs may still set cutoff==emergency (16:55)
- Evidence: `nautilus_gold_scalper/configs/strategy_config.yaml:122`

5) Cutoff ordering: if cutoff is misconfigured earlier than emergency, cutoff wins
- Evidence: `nautilus_gold_scalper/src/risk/time_constraint_manager.py:165`
