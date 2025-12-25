# Round 1 Synthesis: Fundamental Analysis Complete

**Date**: 2025-12-24
**Status**: COMPLETE
**Agents**: ARGUS, CRUCIBLE, CRITIC, FORGE, SENTINEL (5/5)

---

## Consensus Findings (All 5 Agents Agree)

### Root Cause #1: Inverted R:R (CRITICAL)
- **Source**: `gold_scalper_strategy.py:1922`
- **Issue**: `tp_distance = sl_distance * 2.5` (trend-following R:R applied to mean reversion)
- **Impact**: Avg loss 3.4x avg win, causing negative expectancy
- **Fix**: MR-specific TP = BB middle (0.75-1.0x ATR), not 2.5x SL

### Root Cause #2: SL Based on Swing Extremes (CRITICAL)
- **Source**: `mean_revert.py:138-140`
- **Issue**: `SL = min(20-bar low, BB_lower)` can be 3-5x ATR in trends
- **Impact**: When you lose, you lose BIG
- **Fix**: ATR-based SL (1.0-1.5x ATR), not swing-based

### Root Cause #3: No Regime Filter (CRITICAL)
- **All agents identified**: ADX filter missing
- **Issue**: Strategy trades during trends where MR is suicide
- **Fix**: `ADX(14) < 20` as prerequisite for any MR trade

### Root Cause #4: Trade Management Bug (P0)
- **Source**: `gold_scalper_strategy.py:2595-2600`
- **Issue**: `'bool' object has no attribute 'get'` crash
- **Impact**: Trade management fails on state transitions
- **Fix**: Option A - handle boolean correctly in strategy

---

## Additional Findings

| Agent | Key Finding | Priority |
|-------|-------------|----------|
| ARGUS | Gold half-life = 77 months (M1 fights physics) | P3 |
| CRUCIBLE | No reversal confirmation (catching knives) | P2 |
| CRITIC | Need falsification tests BEFORE optimization | P0 |
| FORGE | Misleading logs obscure debugging | P1 |
| SENTINEL | Monte Carlo survival < 50% | P0 |

---

## Prioritized Fix Order

### P0 - Critical (Block live trading)
1. Fix trade management bug (`bool` -> dict handling)
2. Change SL from swing-based to ATR-based (1.0x ATR)
3. Change TP from 2.5x SL to BB middle (0.75x ATR)
4. Add ADX regime filter (ADX < 20)

### P1 - High Priority
5. Add confirmation candle requirement
6. Fix misleading log messages
7. Add time-based exit (max N bars)

### P2 - Medium Priority
8. Session filter (Asian = MR, London/NY = avoid)
9. Z-score threshold > 2.0 (replace BB touch)
10. Walk feature (3-4 bars outside band)

### P3 - Structural (If P0-P2 fail)
11. Timeframe shift to 15M/1H
12. Replace BB with VWAP deviation
13. Abandon MR for gold scalping

---

## Expected Impact After P0 Fixes

| Metric | Current | Expected | Change |
|--------|---------|----------|--------|
| Sharpe | -0.47 | +0.5 to +1.0 | Positive! |
| Expectancy | -$11.75/trade | +$20-40/trade | Positive! |
| Win Rate | 75% | 65-70% | Slight decrease |
| Avg Loss | $401 | $100-150 | -70% |
| R:R | 0.29:1 | 0.75:1 | +158% |

---

## Round 2 Focus

**Objective**: Implement and test P0 fixes

**Tasks**:
1. FORGE: Fix trade management bug
2. FORGE: Implement ATR-based SL/TP
3. FORGE: Add ADX regime filter
4. ORACLE: Run backtest with P0 fixes
5. SENTINEL: Validate Apex compliance

---

*Synthesis completed by ORCHESTRATOR*
