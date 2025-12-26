# CRITIC round 2 (external adversarial)

- Date: 2025-12-26
- Scope: Apex safety/compliance plumbing (strategy + backtest + optimizer + configs)
- Verdict: **NO_GO**

## Critical issues (must fix)

1) **Bars-mode look-ahead / timestamp corruption when `ltf_minutes != 5`**
- Location: `nautilus_gold_scalper/scripts/backtest/run_backtest.py:556`
- Evidence:
  - Hard-coded bar-close shift: `+ pd.Timedelta(minutes=5)`
- Impact:
  - Any LTF other than 5m gets a wrong “known time” for OHLC, which can create look-ahead bias and invalid time-gate logic.
- Required fix:
  - Shift timestamps by the *actual* bar duration (or ensure bars are already close-timestamped).
  - Add an invariant check that the index increment matches the expected timeframe.

2) **Cutoff collapses emergency window (changes Apex semantics)**
- Location: `nautilus_gold_scalper/configs/strategy_config.yaml:122`
- Evidence:
  - `cutoff_et: '16:55'`
  - `emergency_et: '16:55'`
- Impact:
  - Eliminates staged “16:55 emergency → 16:59 cutoff” behavior and can change compliance/performance comparability.
- Required fix:
  - Use `emergency_et: '16:55'` and `cutoff_et: '16:59'` unless intentionally stricter (then document explicitly).

## High issues (strongly recommended)

1) **Zero-cost execution fallback can invalidate HWM/DD realism**
- Location: `nautilus_gold_scalper/src/strategies/gold_scalper_strategy.py:867`
- Evidence:
  - On setup failure: `_execution_model = None` (implies “zero costs” unless engine applies fees/slippage elsewhere)
- Impact:
  - If this triggers in paper/live without engine fee/fill models, costs vanish → optimistic equity and distorted drawdown path.
- Recommended fix:
  - Fail-closed for paper/live when costs aren’t guaranteed elsewhere.

2) **Commission unit mismatch risk (engine vs strategy conversion authority)**
- Locations:
  - `nautilus_gold_scalper/scripts/backtest/run_backtest.py:1430`
  - `nautilus_gold_scalper/src/strategies/base_strategy.py:1383`
- Impact:
  - If `instrument.lot_size` differs from `XAUUSD_LOT_SIZE`, commissions diverge across accounting paths → inconsistent PnL/DD.
- Recommended fix:
  - Enforce single authority for lot-size conversion and assert equality when both are used.

## Medium issues

- `wfa_inline.py` uses `trailing_dd = max_dd  # Approximation` (`nautilus_gold_scalper/src/optimization/validation/wfa_inline.py:364`).
  - Document equity sampling requirements and fail closed if too sparse.

## Fastest disproof tests

1) Bars timestamp falsification:
- Compare `feed=ticks` vs `feed=bars` with `--ltf-minutes 15` over same 1–3 days.
- Disproof: materially different trade timings or bars-mode “improves” performance.

2) Time-gate stall test:
- Replay 16:25–17:05 ET with an open position and inject a no-ticks segment 16:54–17:02.
- Disproof: not flat by 16:59 ET or no close orders submitted starting 16:55 ET.

3) Cost invariance:
- Engine fees enabled + `fees_in_account=True` vs engine fees disabled + strategy costs enabled.
- Disproof: total commission/final equity differs beyond rounding noise.

4) Lot-size consistency:
- Assert `instrument.lot_size == XAUUSD_LOT_SIZE` at startup.
- Disproof: mismatch found.
