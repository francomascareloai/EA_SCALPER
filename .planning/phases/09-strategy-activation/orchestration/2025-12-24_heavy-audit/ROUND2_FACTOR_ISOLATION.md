# ROUND 2: Factor Isolation Results

**Date:** 2025-12-24
**Objective:** Test each signal type and filter combination individually

---

## TrendFollow Signal Results

### BREAKOUT Variant
| Month | Filters | Trades | Win Rate | PnL | Avg/Trade |
|-------|---------|--------|----------|-----|-----------|
| Jan 2024 | OFF | 22 | **0.0%** | -$1,852 | -$84.19 |

**VERDICT: BREAKOUT = TOXIC (0% win rate)**

### PULLBACK Variant
| Month | Filters | Trades | Win Rate | PnL | Avg/Trade |
|-------|---------|--------|----------|-----|-----------|
| Jan 2024 | OFF | 20 | 15.0% | -$378 | -$18.90 |
| Jan 2024 | Both ON | 18 | 11.1% | -$418 | -$23.23 |
| Apr 2024 | Both ON | 22 | **0.0%** | -$3,204 | -$145.64 |
| Apr 2024 | OFF | 22 | **0.0%** | -$3,335 | -$151.59 |

**VERDICT: PULLBACK = TOXIC (0-15% win rate, always losing)**

---

## MeanRevert Signal Results

### Individual Month Tests (Session ON, Regime OFF)
| Month | Trades | Win Rate | PnL | Avg/Trade | Result |
|-------|--------|----------|-----|-----------|--------|
| Jan 2024* | 6 | 16.7% | +$366 | +$61.01 | **POSITIVE** |
| Feb 2024 | 4 | 25.0% | -$561 | -$140.25 | Negative |
| Mar 2024 | 5 | 0.0% | -$270 | -$54.08 | Negative |
| Apr 2024 | 11 | 36.4% | +$1,061 | +$96.45 | **POSITIVE** |
| May 2024 | 10 | 30.0% | -$1,250 | -$124.95 | Negative |
| Jun 2024 | 8 | 12.5% | -$213 | -$26.58 | Negative |
| Jul 2024 | 13 | 23.1% | -$1,153 | -$88.69 | Negative |
| Aug 2024 | 11 | 27.3% | -$260 | -$23.59 | Negative |
| Sep 2024 | 10 | 30.0% | -$273 | -$27.32 | Negative |
| Oct 2024 | 10 | 30.0% | +$40 | +$3.96 | **POSITIVE** |

*Jan 2024 tested with Both filters ON

### Aggregate Period Tests
| Period | Config | Trades | Win Rate | PnL | Avg/Trade |
|--------|--------|--------|----------|-----|-----------|
| H1 2024 (Jan-Jun) | Sess ON | 34 | 20.6% | -$1,490 | -$43.83 |
| Jul-Oct 2024 | Sess ON | 19 | 21.1% | -$4,026 | -$211.92 |

**VERDICT: MeanRevert = MARGINALLY LESS BAD but still NEGATIVE EXPECTANCY**
- Only 3/10 months positive
- Aggregate H1 2024: -$1,490
- Aggregate Jul-Oct 2024: -$4,026

---

## Filter Impact Analysis

### MeanRevert April 2024 (Best Month) - Filter Comparison
| Configuration | Trades | Win Rate | PnL | Avg/Trade |
|---------------|--------|----------|-----|-----------|
| Filters OFF | 12 | 33.3% | +$909 | +$75.75 |
| Session ON only | 11 | 36.4% | +$1,061 | **+$96.45** |
| Regime ON only | 11 | 36.4% | +$961 | +$87.35 |
| Both ON | 11 | 36.4% | +$601 | +$54.60 |

**KEY FINDING:** Session filter alone = BEST configuration
- Session ON only: +17% improvement over no filters
- Both ON: -34% degradation vs session only

### MeanRevert July 2024 (Worst Month) - Filter Comparison
| Configuration | Trades | Win Rate | PnL | Avg/Trade |
|---------------|--------|----------|-----|-----------|
| Session ON, Regime OFF | 13 | 23.1% | -$1,153 | -$88.69 |
| Session OFF, Regime ON | 14 | 28.6% | -$1,013 | -$72.34 |

**KEY FINDING:** Regime filter slightly better in bad month

---

## Critical Discoveries

### 1. BOTH SIGNAL TYPES HAVE NEGATIVE EXPECTANCY
- TrendFollow (Breakout): 0% win rate = TOXIC
- TrendFollow (Pullback): 0-15% win rate = TOXIC
- MeanRevert: 20-30% win rate = Marginal but STILL LOSING

### 2. FILTERS PROVIDE MINIMAL EDGE
- Session filter: Small improvement but NOT enough to flip sign
- Regime filter: Minimal impact, sometimes negative
- Combined filters: WORSE than session alone

### 3. HIGH MONTH-TO-MONTH VARIANCE
- MeanRevert ranges from +$1,061 (Apr) to -$4,026 (Jul-Oct aggregate)
- No consistent pattern = HIGH REGIME SENSITIVITY

### 4. COST OF TRADING IS SIGNIFICANT
- Commissions: ~$3-6 per trade
- Spread impact: ~$30-50 per entry
- At 20-30% win rate, costs dominate returns

---

## Ghost Test Implication

**Previous hypothesis:** "Filters might be the edge, not signals"

**ROUND 2 disproof:** Filters alone do NOT create positive expectancy. When applied:
- Session filter improves slightly but signal remains negative
- Regime filter has minimal impact
- Neither can transform negative signal into positive

**REVISED CONCLUSION:** The core signal logic is fundamentally flawed. Neither TrendFollow nor MeanRevert provides tradeable edge in current configuration.

---

## Recommendations

1. **ABORT TrendFollow** - Both variants have near-zero win rate
2. **INVESTIGATE MeanRevert parameters** - Some months positive suggests edge may exist with different thresholds
3. **TEST HIGHER TIMEFRAMES** - M5 may be too noisy; test M15/H1 entry signals
4. **REVIEW STOP LOSS LOGIC** - Current SL may be too tight, causing premature exits

---

*ROUND 2 Complete | 2025-12-24*
