# Signal Flow Diagnosis - EA_SCALPER_XAUUSD

**Date:** 2025-12-23
**Issue:** Signal Starvation - Only 1 trade in 3 months of backtesting
**Agent:** FORGE-NAUTILUS v1.1

## Executive Summary

The strategy generates almost no trades due to a **multiplicative filter cascade** that blocks nearly all potential signals. The combination of session filters, regime detection, HTF alignment, and score thresholds creates an extremely restrictive environment where only ~1-3% of bars can potentially generate valid signals.

---

## Signal Flow Path

```
on_bar (base_strategy.py)
    |
    +---> Route to HTF/MTF/LTF storage
    |
    +---> LTF bar triggers signal check
    |
    v
_has_enough_data() --- GATE 1
    |
    +---> Requires: 50 LTF, 20 MTF, 10 HTF bars
    |
    v
_check_for_signal() (gold_scalper_strategy.py)
    |
    +---> GATE 2: instrument loaded
    +---> GATE 3: _is_trading_allowed
    +---> GATE 4: is_flat (not in position)
    +---> GATE 5: session filter (Asian/Late NY blocked) *** CRITICAL ***
    +---> GATE 6: time manager (after 4:30 PM ET)
    +---> GATE 7: _trading_blocked_today flag
    +---> GATE 8: prop firm can_trade()
    +---> GATE 9: circuit breaker
    +---> GATE 10: strategy selector *** CRITICAL - RANDOM WALK BLOCKS ***
    +---> GATE 11: consistency tracker (30% cap)
    +---> GATE 12: circuit breaker guard
    +---> GATE 13: news filter
    +---> GATE 14: spread missing/blocked/too high
    +---> GATE 15: HTF bias is None *** CRITICAL ***
    +---> GATE 16: HTF bias RANGING/TRANSITION *** CRITICAL ***
    +---> GATE 17: HTF direction vs signal direction *** CRITICAL ***
    |
    v
_calculate_confluence()
    |
    +---> Structure analysis
    +---> Regime analysis
    +---> MTF analysis (requires 50 bars each TF)
    +---> Footprint = 0 (NOT AVAILABLE IN BACKTEST) *** CRITICAL ***
    +---> Order blocks / FVGs
    +---> Liquidity sweeps
    +---> AMD cycle
    +---> ICT 7-step sequence validation
    |
    v
confluence_scorer.calculate_score()
    |
    +---> GATE 18: score < 70 (execution_threshold) *** CRITICAL ***
    +---> GATE 19: signal == SIGNAL_NONE
    |
    v
Execute trade (if all gates pass)
```

---

## Potential Blockers

| # | Blocker | Condition | Est. Block Rate | Priority | Fix |
|---|---------|-----------|-----------------|----------|-----|
| 1 | **Session Filter** | Asian (00-07 UTC), Late NY (17-21 UTC), Weekend blocked | ~58% | CRITICAL | Enable Asian/Late NY for backtest, or tune session windows |
| 2 | **Strategy Selector - Random Walk** | Hurst between 0.40-0.55 = STRATEGY_NONE | ~40-60% | CRITICAL | Widen Hurst thresholds (e.g., 0.35-0.60 for "random") |
| 3 | **HTF Alignment Required** | HTF bias None, RANGING, TRANSITION, or opposite direction | ~30-50% | HIGH | Make require_htf_align configurable for backtest |
| 4 | **Score Threshold 70** | Score must be >= 70 to trigger trade | ~50-70% | HIGH | Lower to 60 for backtest exploration |
| 5 | **Footprint = 0** | Footprint data not available in backtest | 100% missing | HIGH | Either mock footprint or reduce its weight |
| 6 | **ICT Sequence Penalty** | Steps 3-6 require sweep/POI/MTF alignment | Variable | MEDIUM | Reduce sequence requirements |
| 7 | **MTF Not Aligned** | mtf_aligned = False reduces bonus | Variable | MEDIUM | Relax MTF alignment requirements |
| 8 | **Warmup Period** | First ~200 bars have insufficient data | ~1-2% | LOW | Expected behavior |

### Multiplicative Effect

The filters are cumulative (multiplicative):
```
Session allowed (42%) x Regime allowed (50%) x HTF aligned (50%) x Score passes (30%)
= 42% x 50% x 50% x 30%
= 3.15% of bars can potentially generate signals
```

In 3 months (M5 bars = ~12 bars/hour x 24 hours x 90 days = ~25,920 bars):
- 25,920 x 3.15% = ~816 bars might pass filters
- But many of those will still fail due to:
  - Not at OB/FVG zone
  - No liquidity sweep
  - Signal direction unclear
  - etc.

**Result: ~1-5 trades over 3 months is mathematically expected with current settings.**

---

## Root Causes (Ranked by Impact)

### 1. Strategy Selector Random Walk Block (CRITICAL)

**File:** `nautilus_gold_scalper/src/strategies/strategy_selector.py` (lines 436-441)

```python
if self._context.is_random:
    result.strategy = StrategyType.STRATEGY_NONE
    result.can_trade = False
    result.reason = f"Random walk regime (Hurst ~{self._context.hurst:.2f})"
    return result
```

**Problem:** Hurst exponent often oscillates around 0.5 (random walk). Markets spend significant time between 0.40-0.55, which is classified as "random" and blocks ALL trading.

**Thresholds:**
- Hurst > 0.55 = TRENDING (allowed)
- Hurst < 0.40 = REVERTING (allowed)
- 0.40 <= Hurst <= 0.55 = RANDOM WALK = BLOCKED

### 2. Session Filter Too Restrictive (CRITICAL)

**File:** `nautilus_gold_scalper/src/indicators/session_filter.py` (lines 49-85)

**Allowed sessions:** Only London (07:00-12:00), Overlap (12:00-15:00), NY (15:00-17:00) = 10 hours/day
**Blocked:** Asian (7 hours), Late NY (4 hours), Weekend (48 hours)

**Block rate:** ~58% of all trading hours

### 3. HTF Alignment Requirement (HIGH)

**File:** `nautilus_gold_scalper/src/strategies/gold_scalper_strategy.py` (lines 1338-1389)

**Requirements:**
- HTF bias must not be None (needs enough H1 bars)
- HTF bias must not be RANGING or TRANSITION
- Signal direction must match HTF bias

**Block rate:** ~30-50% when HTF is unclear or ranging

### 4. Score Threshold 70 (HIGH)

**Config:** `execution_threshold: int = 70`

**Problem:** With footprint = 0 (always in backtest), the strategy is missing ~10-15 points of potential score. This makes reaching 70 significantly harder.

**Score components with footprint unavailable:**
- Structure: up to 15
- Regime: up to 10
- OB: up to 15
- FVG: up to 10
- Sweep: up to 12
- AMD: up to 10
- Fib: up to 10
- MTF: up to 15
- **Footprint: 0 (missing!)**
- Session bonuses: ~5-10

Maximum theoretical score without footprint: ~80-90 (with all aligned)
Typical score without footprint: ~40-60

---

## Recommendations

### Immediate Fixes (Quick Wins)

1. **Widen Hurst Thresholds** - File: `strategy_selector.py`
   ```python
   # Change from:
   hurst_trend_threshold: float = 0.55
   hurst_revert_threshold: float = 0.40

   # To:
   hurst_trend_threshold: float = 0.58
   hurst_revert_threshold: float = 0.35
   ```
   This narrows the "random walk" band from 0.40-0.55 (0.15 range) to 0.35-0.58 (0.23 range allows more trading).

2. **Lower Execution Threshold for Backtest** - File: `gold_scalper_strategy.py`
   ```python
   execution_threshold: int = 60  # Was 70
   ```

3. **Enable Asian Session for Backtest** - Config:
   ```python
   session_allow_asian: bool = True
   session_allow_late_ny: bool = True
   ```

4. **Make HTF Alignment Optional for Backtest** - Config:
   ```python
   require_htf_align: bool = False
   ```

### Medium-Term Fixes

5. **Mock Footprint Score in Backtest**
   - Use price action / volume as proxy for order flow
   - Or set a default footprint_score = 30 when not available

6. **Relax ICT Sequence Validator**
   - Remove sweep requirement as hard gate
   - Make MTF alignment contribute to score rather than blocking

7. **Add Diagnostic Logging**
   - Log WHY each signal was rejected
   - Count rejections by reason over backtest period

### Long-Term Fixes

8. **Tiered Filter System**
   - Separate "hard blocks" (session, circuit breaker) from "soft filters" (regime, HTF)
   - Soft filters reduce position size rather than blocking

9. **Backtest Mode Configuration**
   - Create a `backtest_mode` flag that relaxes certain filters
   - Maintain strict filters only for live trading

---

## Validation

To verify the diagnosis, run backtest with these config changes and compare trade count:

```python
# Relaxed config for diagnosis
config = GoldScalperConfig(
    execution_threshold=60,  # Was 70
    session_allow_asian=True,  # Was False
    session_allow_late_ny=True,  # Was False
    require_htf_align=False,  # Was True
    use_footprint=False,  # Disable footprint entirely
    selector_hurst_trend_threshold=0.58,  # Was 0.55
    selector_hurst_revert_threshold=0.35,  # Was 0.40
    prop_firm_enabled=False,  # Disable for initial diagnosis
    use_news_filter=False,  # Disable for initial diagnosis
)
```

Expected result: Trade count should increase from 1 to 50-200+ trades over 3 months.

---

## Files Analyzed

1. `/home/franco/projetos/EA_SCALPER_XAUUSD/nautilus_gold_scalper/src/strategies/gold_scalper_strategy.py`
2. `/home/franco/projetos/EA_SCALPER_XAUUSD/nautilus_gold_scalper/src/strategies/base_strategy.py`
3. `/home/franco/projetos/EA_SCALPER_XAUUSD/nautilus_gold_scalper/src/strategies/strategy_selector.py`
4. `/home/franco/projetos/EA_SCALPER_XAUUSD/nautilus_gold_scalper/src/signals/confluence_scorer.py`
5. `/home/franco/projetos/EA_SCALPER_XAUUSD/nautilus_gold_scalper/src/indicators/session_filter.py`
6. `/home/franco/projetos/EA_SCALPER_XAUUSD/nautilus_gold_scalper/src/core/definitions.py`

---

**AGENT: FORGE-NAUTILUS**
**VERSION: 1.1**
**CLAUDE_MD_VERSION: 3.10.21**
**STATUS: COMPLETE**
