# Phase 03 - TREND_FOLLOW

## Goal
Validate TrendFollow (Pullback + Breakout) in isolation, harden configuration safety, and decide GO/NO-GO for activation.

## Scope
- Strategy wiring: `nautilus_gold_scalper/src/strategies/gold_scalper_strategy.py`
- Backtest runner: `nautilus_gold_scalper/scripts/backtest/run_backtest.py`
- Signal generator: `nautilus_gold_scalper/src/signals/trend_follow.py`

## Safety / Correctness Hardening (Applied)
- **HTF alignment cannot be bypassed by TrendFollow** when `require_htf_align=True`.
- **trend_follow_mode is fail-closed**:
  - Invalid value => TrendFollow candidates disabled, warn-once.
- **Regime stability gate is fail-closed** when enabled:
  - If `regime_stability_min_bars>0` and HTF regime is not initialized yet => block (warn-once).
  - If detector missing => block (warn-once).

## Backtest (Isolated TrendFollow)
**Dataset:** `data/raw/full_parquet/xauusd_2003_2025_stride20_full.parquet`
**Window:** 2024-01-01 → 2024-01-15
**Feed:** ticks
**Config:** `enable_smc=false`, TrendFollow enabled.

### Observed metrics (from backtest output)
- **BOTH**: Trades=14, WinRate=71.4%, TotalPnL=$16.20, FinalBalance=$100,016.20
- **PULLBACK_ONLY**: Trades=13, WinRate=76.9%, TotalPnL=$-34.71, FinalBalance=$99,965.29
- **BREAKOUT_ONLY**: Trades=17, WinRate=64.7%, TotalPnL=$839.25, FinalBalance=$100,839.25

Notes:
- Frequent `[FAILSAFE]` triggers were observed in these short-window runs (cutoff pending close, bracket cancel, prop_firm_dd_breach). These were expected under the safety-first execution model; they must not spam logs.

## Reviews
### FORGE (Sonnet)
- Confirmed mode validation is fail-closed + log-once.
- Confirmed TrendFollow respects HTF alignment gate.
- Flagged regime stability gate as previously fail-open during warmup; patched to fail-closed.

### CRITIC (Sonnet)
- **VERDICT: GO** (post-fix validation)
- Fastest disproof test suggestion: enable `regime_stability_min_bars=5` on a fresh backtest and verify **0 trades** until HTF regime stabilizes.

## Decision (Current)
- **Engineering readiness:** GO (CRITIC)
- **Performance/edge readiness:** Not fully proven (sample too small: <200 trades, short horizon). Treat these results as a smoke test, not edge confirmation.

## Next steps
1. Run a longer TrendFollow-only backtest (multi-year) and report WFE/SQN/PSR/DSR/MC95DD.
2. If only one variant remains robust, lock the mode to that variant.
3. Only after Oracle validation: consider setting `enable_trend_follow=True` by default.
