# ROUND 04: ORACLE - Parameter Optimization Proposals

## ORACLE Output
```
AGENT: ORACLE
VERSION: 3.4
CLAUDE_MD_VERSION: 3.10.23
ROUND: 4 of 6
STATUS: COMPLETE
```

---

## 1. SENSITIVITY ANALYSIS

### Parameter Impact Rankings

| Rank | Parameter | Signal Count Impact | Win Rate Impact | Max DD Impact |
|------|-----------|---------------------|-----------------|---------------|
| 1 | **sep_ticks** | HIGHEST (-60% at 50 vs 4) | HIGH (+5-10%) | HIGHEST |
| 2 | **min_hurst** | HIGH (-20% at 0.60 vs 0.50) | MEDIUM (+5-7%) | HIGH |
| 3 | **min_score** | MEDIUM (-30% at 75 vs 60) | HIGHEST (+8-12%) | MEDIUM |
| 4 | **touch_dist** | MEDIUM (-30% pullback) | LOW (+2-3%) | LOW |
| 5 | **breakout_lookback** | LOW (-15% breakout) | LOW (+2-4%) | LOW |

### Optimization Priority Order
```
1. sep_ticks     → Primary lever for all metrics
2. min_hurst     → Secondary lever, Apex compliance
3. min_score     → Quality vs quantity trade-off
4. touch_dist    → Pullback-specific tuning
5. breakout_lookback → Breakout-specific tuning
```

**KEY INSIGHT:** sep_ticks dominates all three metrics (signals, WR, DD). This is the PRIMARY optimization target.

---

## 2. STARVATION MITIGATION ANALYSIS

### Options Ranked (Best to Worst)

| Rank | Option | Signal Gain | Risk | Complexity | Verdict |
|------|--------|-------------|------|------------|---------|
| **1** | **D: Fix Bounce Logic Bug** | +10-20% (Pullback) | NONE | LOW | **HIGHEST VALUE** |
| **2** | **C: Hurst Relaxation (0.55 → 0.52)** | +15-20% | WR drop | LOW | **HIGH VALUE** |
| **3** | A: Variant-Specific Thresholds | +15-20% (Pullback) | Complexity | MEDIUM | MODERATE VALUE |
| **4** | B: Adaptive min_score | +10-15% | Overfitting | HIGH | LOW VALUE |
| **5** | E: Remove Breakout Confirmation | +30-50% (Breakout) | SEVERE WR drop | LOW | **NOT RECOMMENDED** |

### Detailed Analysis

#### Option D: Fix Bounce Logic Bug (RECOMMENDED)
```python
# CURRENT (line 182) - Misses single-bar bounces
bounced = last_close > last_ema_f and (prev_close <= prev_ema_f or prev_low <= prev_ema_f)

# PROPOSED - Captures single-bar bounces
touch_threshold = last_ema_f + touch_dist
single_bar_bounce = last_low <= touch_threshold and last_close > last_ema_f
two_bar_bounce = (prev_close <= prev_ema_f or prev_low <= prev_ema_f) and last_close > last_ema_f
bounced = single_bar_bounce or two_bar_bounce
```
- **Rationale:** This is a BUG, not a parameter. Fixing it recovers legitimate signals with no quality trade-off.
- **Effort:** 30 minutes (3 lines of code)
- **Expected gain:** +10-20% Pullback signals

#### Option C: Hurst Relaxation
- Current: 0.55 (reject ~40% of borderline trending periods)
- Proposed: 0.52 (accept borderline trending)
- **Expected gain:** +15-20% signals
- **Risk:** More range-market signals → need to verify WR holds above 50%

#### Option E: Remove Breakout Confirmation
- **NOT RECOMMENDED** - This filter prevents false breakouts
- Removing it would add +30-50% Breakout signals but at -10-15% WR
- The resulting edge may not survive Apex DD constraints

---

## 3. TIERED PARAMETER CONFIGURATIONS

### Config A - CONSERVATIVE (Max Quality)
```python
CONFIG_CONSERVATIVE = {
    "sep_ticks": 40,           # Wide separation
    "touch_dist": 0.15,        # Tight bounces (ATR multiplier)
    "min_score": 75,           # High quality only
    "breakout_lookback": 25,   # Strong breakouts
    "min_hurst": 0.58,         # Strong trending only
}
```
| Metric | Expected | Notes |
|--------|----------|-------|
| Signals/month | 12-18 | **BELOW MINIMUM (32)** |
| Win Rate | 58-62% | Excellent |
| Expected P&L | $1,440-2,232/mo | At 0.5% risk, 1.5:1 RR |

**VERDICT:** NOT VIABLE for Apex - insufficient signal count

---

### Config B - BALANCED (Apex Minimum)
```python
CONFIG_BALANCED = {
    "sep_ticks": 25,           # Moderate separation
    "touch_dist": 0.20,        # Balanced (ATR multiplier)
    "min_score": 68,           # Good quality
    "breakout_lookback": 20,   # Standard
    "min_hurst": 0.53,         # Accept borderline trending
}
```
| Metric | Expected | Calculation |
|--------|----------|-------------|
| Signals/month | 25-32 | Borderline viable |
| Win Rate | 52-55% | Acceptable |
| Expected P&L | $1,875-2,400/mo | 28 trades * 53% WR * (0.53*1.5 - 0.47*1) = 28 * 0.325 = 9.1R |

**VERDICT:** MINIMUM VIABLE for Apex

---

### Config C - AGGRESSIVE (Max Signals)
```python
CONFIG_AGGRESSIVE = {
    "sep_ticks": 18,           # Tighter separation
    "touch_dist": 0.25,        # Wider bounces (ATR multiplier)
    "min_score": 60,           # Lower threshold
    "breakout_lookback": 15,   # More breakouts
    "min_hurst": 0.50,         # Borderline range accepted
}
```
| Metric | Expected | Calculation |
|--------|----------|-------------|
| Signals/month | 40-50 | Good volume |
| Win Rate | 48-52% | Marginal |
| Expected P&L | $2,250-3,125/mo | 45 trades * 50% WR = 11.25R |

**VERDICT:** Higher volume but HIGHER RISK - more DD variance

---

### Config D - BALANCED+ (RECOMMENDED)
```python
CONFIG_BALANCED_PLUS = {
    "sep_ticks": 25,           # Moderate separation
    "touch_dist": 0.20,        # Balanced (ATR multiplier)
    "min_score": 68,           # Good quality
    "breakout_lookback": 20,   # Standard
    "min_hurst": 0.53,         # Accept borderline trending
    "bounce_fix_applied": True, # Bug fix for single-bar bounces
}
```
| Metric | Expected | Notes |
|--------|----------|-------|
| Signals/month | 30-38 | Bug fix adds +10-20% |
| Win Rate | 53-56% | Quality maintained |
| Expected P&L | $2,625-3,420/mo | 34 trades * 54% WR = 10.7R |

**VERDICT:** RECOMMENDED - Best balance of quality and quantity

---

## 4. PARAMETER OPTIMIZATION GRID

### Full Grid (Reference)
```
sep_ticks:        [15, 20, 25, 30, 40, 50] = 6 values
touch_dist:       [0.10, 0.15, 0.20, 0.25] = 4 values
min_score:        [60, 65, 70, 75] = 4 values
breakout_lookback: [10, 15, 20, 25, 30] = 5 values
min_hurst:        [0.50, 0.52, 0.55, 0.58, 0.60] = 5 values

TOTAL: 6 x 4 x 4 x 5 x 5 = 2,400 combinations
```

### Reduced Grid (Phased Approach)

#### Phase 1: sep_ticks x min_hurst Sweep (30 configs)
Focus on the two highest-impact parameters:
```python
PHASE_1_GRID = {
    "sep_ticks": [15, 20, 25, 30, 40, 50],  # 6 values
    "min_hurst": [0.50, 0.52, 0.55, 0.58, 0.60],  # 5 values
    # FIXED:
    "touch_dist": 0.20,
    "min_score": 65,
    "breakout_lookback": 20,
}
# Total: 6 x 5 = 30 configs
```

#### Phase 2: Fine-tune Quality Parameters (20 configs)
Take top 5 combos from Phase 1:
```python
PHASE_2_GRID = {
    "sep_ticks": [TOP_5_FROM_PHASE_1],
    "min_hurst": [TOP_5_FROM_PHASE_1],
    "touch_dist": [0.15, 0.20, 0.25],  # 3 values
    "min_score": [60, 68, 75],  # 3 values (reduced)
    "breakout_lookback": 20,  # FIXED
}
# Total: 5 x 2 x 2 = 20 configs (sampled)
```

#### Phase 3: Breakout-Specific Tuning (10 configs)
For Breakout variant only:
```python
PHASE_3_GRID = {
    "breakout_lookback": [10, 15, 20, 25, 30],  # 5 values
    # Use top 2 configs from Phase 2
}
# Total: 2 x 5 = 10 configs
```

**TOTAL REDUCED GRID: 30 + 20 + 10 = 60 configs**

---

## 5. VALIDATION PLAN

### Stage 1: Quick Validation (1 Month)
```
Period:  November 2024
Purpose: Eliminate clearly broken configs
Runtime: ~30 sec/config = 30 min for 60 configs
```

| Metric | GO Threshold | NO-GO Threshold |
|--------|--------------|-----------------|
| Trades | >= 3 (36/year) | < 2 |
| Win Rate | >= 45% | < 40% |
| Max DD | < 6% | > 8% |
| Profit Factor | > 1.0 | < 0.8 |

**Expected survivors:** 20-30 configs

---

### Stage 2: Extended Validation (6 Months WFA)
```
Period:  June - November 2024
Purpose: Test robustness across months
WFA:     4 windows, 70% IS / 30% OOS
Runtime: ~2 min/config = 1 hour for 25 configs
```

| Metric | GO Threshold | NO-GO Threshold |
|--------|--------------|-----------------|
| WFE | >= 0.50 | < 0.30 |
| OOS Trades | >= 20 total | < 10 |
| OOS Win Rate | >= 50% | < 45% |
| OOS Max DD | < 5% | > 6% |

**Expected survivors:** 5-10 configs

---

### Stage 3: Full Validation (5 Years + Monte Carlo)
```
Period:  2020 - 2024 (5 years)
Purpose: Final validation before paper trading
WFA:     12 windows, 70% IS / 30% OOS, purged CV
MC:      5,000 runs, block bootstrap
Runtime: ~10 min/config = 1-2 hours for top 5-10 configs
```

| Metric | GO Threshold | NO-GO Threshold | ORACLE Standard |
|--------|--------------|-----------------|-----------------|
| WFE | >= 0.60 | < 0.30 | REQUIRED |
| PSR | >= 0.85 | < 0.70 | REQUIRED |
| DSR | > 0 | <= 0 | **CRITICAL** |
| PBO | < 25% | > 50% | REQUIRED |
| MC 95th DD | < 4% | > 5% | Apex Buffer |
| OOS Trades | >= 100 | < 50 | 5-year total |
| Sharpe | >= 1.5 | < 1.0 | REQUIRED |

**Expected survivors:** 1-3 configs for paper trading

---

## 6. RECOMMENDED IMPLEMENTATION ORDER

```
┌─────────────────────────────────────────────────────────────┐
│  PRIORITY 1 (IMMEDIATE - Round 5)                           │
│  ─────────────────────────────────                          │
│  • Fix bounce logic bug (line 182)                          │
│  • Effort: 30 minutes                                       │
│  • Expected: +10-20% pullback signals, ZERO downside        │
└─────────────────────────────────────────────────────────────┘
          ↓
┌─────────────────────────────────────────────────────────────┐
│  PRIORITY 2 (Round 5-6)                                     │
│  ─────────────────────────────                              │
│  • Run Phase 1 parameter sweep (30 configs)                 │
│  • Quick validation on 1 month data                         │
│  • Identify optimal sep_ticks x min_hurst region            │
└─────────────────────────────────────────────────────────────┘
          ↓
┌─────────────────────────────────────────────────────────────┐
│  PRIORITY 3 (Post-Round 6)                                  │
│  ───────────────────────────                                │
│  • Full 3-stage validation                                  │
│  • Stage 1 → Stage 2 → Stage 3                              │
│  • Progressive filtering to final 1-3 configs               │
└─────────────────────────────────────────────────────────────┘
          ↓
┌─────────────────────────────────────────────────────────────┐
│  PRIORITY 4 (If Still Starved)                              │
│  ──────────────────────────────                             │
│  • Implement Hurst relaxation (Option C)                    │
│  • Re-run validation with min_hurst=0.52                    │
└─────────────────────────────────────────────────────────────┘
```

---

## 7. CONFIDENCE UPDATE

| Assessment | Confidence | Notes |
|------------|------------|-------|
| Signal starvation is PRIMARY risk | 95% | Confirmed across all analysis |
| Bug fix will help (+10-20%) | 85% | Logical fix, needs verification |
| Parameter optimization can reach 30+ trades/mo | 70% | Depends on market conditions |
| Breakout variant may need deprioritization | 80% | 92% reduction is SEVERE |
| Config B/D can pass ORACLE validation | 60% | Need actual backtest data |

---

## 8. QUESTIONS FOR ROUND 5

1. **Bug Fix Verification:** Should we run a targeted backtest with ONLY the bug fix applied (no parameter changes) to isolate its impact?

2. **Breakout Deprioritization:** Given 92% signal reduction for Breakout variant, should we:
   - (a) Focus optimization on Pullback only?
   - (b) Relax Breakout filters aggressively?
   - (c) Remove Breakout variant entirely for Apex?

3. **WR Floor Calculation:** For Apex with 1.5:1 RR and 5% trailing DD:
   - Break-even WR = 1 / (1 + 1.5) = 40%
   - With safety buffer (1.2x edge): WR >= 48%
   - Is 48% WR acceptable as minimum threshold?

4. **Adaptive Position Sizing:** Should we consider Kelly-based sizing to handle WR variance, or is fixed 0.5% risk per trade safer for Apex?

---

## 9. HANDOFF NOTES

### For FORGE (Round 5):
- Implement bounce logic bug fix at line 182
- Prepare parameter sweep infrastructure
- Ensure backtest outputs include: trades_per_month, win_rate, max_dd_from_hwm

### For SENTINEL (Round 6):
- Review tiered configs against Apex DD limits
- Calculate position sizing for each config tier
- Verify MC95DD calculation includes HWM tracking

### For CRUCIBLE (Round 5):
- Evaluate Breakout variant viability
- Consider variant-specific thresholds (Option A) if Breakout is worth saving
- Provide strategic direction on multi-variant vs single-variant approach

---

*ORACLE Round 4 Complete - Awaiting Round 5 synthesis*
