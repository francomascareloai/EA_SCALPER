# ROUND 5: Walk-Forward Analysis Validation

**Date:** 2025-12-24
**Test Period:** 2024 Full Year (split into IS/OOS windows)
**Objective:** Validate strategy robustness via Walk-Forward Analysis

---

## Methodology

- **Window Structure:** 2-month IS (in-sample) → 1-month OOS (out-of-sample)
- **Configuration:** Baseline MeanRevert (BB20/RSI14-30/70/ADX25/SL10x/TP8x)
- **Metric:** Walk-Forward Efficiency (WFE) = OOS Performance / IS Performance

---

## Walk-Forward Window Results

### Window-by-Window Analysis

| Window | Period | Type | Trades | Win Rate | PnL | Verdict |
|--------|--------|------|--------|----------|-----|---------|
| **W1** | Jan-Feb 2024 | IS | 16 | 56.2% | -$1,880.33 | NEGATIVE |
| **W1** | Mar 2024 | OOS | 11 | 18.2% | -$2,754.38 | **CATASTROPHIC** |
| **W2** | Apr-May 2024 | IS | 4 | 25.0% | -$3,325.46 | NEGATIVE |
| **W2** | Jun 2024 | OOS | 13 | 38.5% | -$2,105.79 | NEGATIVE |
| **W3** | Jul-Aug 2024 | IS | 20 | 45.0% | -$3,792.48 | NEGATIVE |
| **W3** | Sep 2024 | OOS | 5 | 80.0% | +$518.54 | **POSITIVE** |
| **W4** | Oct-Nov 2024 | IS | 25 | 56.0% | +$1,594.54 | **POSITIVE** |

### Full Year Validation

| Period | Trades | Win Rate | PnL | Result |
|--------|--------|----------|-----|--------|
| **2024 (Jan-Nov)** | 16 | 56.2% | -$1,880.48 | **NEGATIVE** |

---

## Walk-Forward Efficiency Analysis

### WFE Calculation (where computable)

| Window | IS PnL | OOS PnL | WFE | Interpretation |
|--------|--------|---------|-----|----------------|
| W1 | -$1,880 | -$2,754 | N/A | Both negative - no edge |
| W2 | -$3,325 | -$2,106 | N/A | Both negative - no edge |
| W3 | -$3,792 | +$519 | N/A | IS negative, OOS positive (inverted) |
| W4 | +$1,595 | N/A | N/A | No OOS window tested |

**WFE Assessment:** Cannot compute meaningful WFE because IS periods are predominantly negative.

---

## Statistical Significance Concerns

| Issue | Impact |
|-------|--------|
| Low trade counts (4-25 per window) | Insufficient for statistical significance |
| High variance in win rates (18.2% - 80.0%) | Results dominated by randomness |
| Only 2/7 windows positive | 28.6% positive rate |
| Net PnL over all windows | **Strongly Negative** |

**Minimum Required:** ≥30 trades per window for 95% confidence
**Actual:** 4-25 trades per window → **INSUFFICIENT**

---

## Critical Findings

### 1. NO POSITIVE EDGE DETECTED
- 5 of 7 windows show NEGATIVE PnL
- Only 2 positive windows: W3 OOS (+$519) and W4 IS (+$1,595)
- Net across all windows: **STRONGLY NEGATIVE**

### 2. EXTREME REGIME DEPENDENCE
- W1 OOS: 18.2% win rate (catastrophic)
- W3 OOS: 80.0% win rate (excellent)
- This 62 percentage point swing indicates pure regime luck

### 3. IS→OOS DEGRADATION
- W1: IS negative → OOS worse
- W2: IS negative → OOS still negative
- W3: IS negative → OOS positive (anomaly/luck)
- Pattern: No consistent improvement or transfer

### 4. TRADE FREQUENCY TOO LOW
- Average: 13.4 trades per window
- Required: ≥30 trades for significance
- **Strategy generates too few signals for reliable validation**

---

## WFA Verdict

| Criterion | Required | Actual | Pass? |
|-----------|----------|--------|-------|
| WFE ≥ 0.6 | 60% | N/A (negative IS) | **FAIL** |
| Net OOS PnL | Positive | -$4,341.63 | **FAIL** |
| Trades per window | ≥30 | 4-25 | **FAIL** |
| Consistent positive windows | ≥50% | 28.6% | **FAIL** |

**OVERALL WFA VERDICT: FAIL**

---

## Monte Carlo / PSR/DSR Assessment

Due to:
1. Negative overall PnL
2. Insufficient trade counts
3. High variance between windows

**Monte Carlo survival probability would be near 0%** under Apex constraints:
- 5% trailing DD from HWM would be breached rapidly
- Any losing streak (common at 18-45% win rates) causes account termination

**PSR (Probabilistic Sharpe Ratio):** Cannot be meaningfully positive with negative returns.
**DSR (Deflated Sharpe Ratio):** N/A - no positive Sharpe to deflate.
**PBO (Probability of Backtest Overfitting):** Irrelevant - strategy shows no edge to overfit.

---

## Conclusions

### Strategy Status: **NO TRADEABLE EDGE**

1. **Edge Attribution (from ROUND 4):** Any edge comes from ADX regime filter, not BB/RSI signals
2. **WFA Validation:** FAILED - no consistent out-of-sample performance
3. **Trade Frequency:** Too low for statistical validation
4. **Regime Dependence:** Extreme - performance swings 60+ percentage points
5. **Apex Viability:** ZERO - would blow account within first losing streak

---

## Recommendations

### Immediate
1. **DO NOT deploy this strategy to live trading**
2. **DO NOT deploy to paper trading for validation** - waste of time

### Strategic Options
1. **Abandon MeanRevert signal generator entirely**
2. **Keep ADX filter only** - test if ADX alone provides edge with random signals (Ghost Test)
3. **Require minimum 5x signal frequency** to enable proper validation
4. **Consider different strategy paradigm** (trend-follow, breakout, etc.)

---

**Status:** ROUND 5 COMPLETE
**Verdict:** STRATEGY FAILS ALL VALIDATION CRITERIA
**Next:** SYNTHESIS - Aggregate findings and final recommendations
