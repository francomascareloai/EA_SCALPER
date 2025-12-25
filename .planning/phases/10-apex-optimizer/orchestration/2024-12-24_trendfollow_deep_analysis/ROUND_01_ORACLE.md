# ROUND 01: ORACLE Deep Analysis - TrendFollow Strategy

## ORACLE Output
```
AGENT: ORACLE
VERSION: 3.4
CLAUDE_MD_VERSION: 3.10.23
STATUS: COMPLETE
```

---

## 1. Executive Summary

1. **CRITICAL: sep_ticks threshold (4.0) is 10-20x too permissive** - For XAUUSD at $2000+, 4 ticks = $0.04 = 0.002% of price. This is noise, not trend. Any micro-oscillation triggers signals.

2. **HIGH: Scoring formula provides no quality gate** - Base scores (60/62) equal the min_score threshold (60), meaning even marginal conditions immediately pass. There is no "weak signal rejection."

3. **MEDIUM: Pullback touch_dist (0.35*ATR) is too wide** - With typical ATR of $5, this creates a $1.75 zone around EMA. Almost any price action in a trend qualifies as a "touch."

4. **MEDIUM: Breakout lacks momentum/candle confirmation** - Raw Donchian breakout with only EMA direction filter. Known for false breakouts in choppy conditions.

5. **The Hurst gate (H >= 0.55) is a positive addition** but was just implemented and its effect is not yet reflected in the historical loss data.

---

## 2. Code Analysis

### 2.1 File Structure
- **Location**: `/home/franco/projetos/EA_SCALPER_XAUUSD/nautilus_gold_scalper/src/signals/trend_follow.py`
- **Lines**: 268
- **Variants**: PULLBACK and BREAKOUT
- **Output**: `TrendFollowCandidate` with score (0-100), direction, sl_distance, reason, meta

### 2.2 Trend Direction Logic (Lines 149-156)
```python
ema_f = _ema(c, ema_fast)   # EMA(20)
ema_s = _ema(c, ema_slow)   # EMA(50)
sep = float(abs(ema_f[-1] - ema_s[-1]))
sep_ticks = sep / tick_size
is_up = ema_f[-1] > ema_s[-1]
is_down = ema_f[-1] < ema_s[-1]
```

**Analysis**: Simple and deterministic. No look-ahead (uses only `[-1]` and prior bars). The issue is not the logic but the thresholds.

### 2.3 Pullback Scoring (Lines 179-196)
```python
if is_up and sep_ticks >= 4.0:
    # ... touch and bounce logic ...
    score = 60.0 + min(25.0, sep_ticks * 1.5) + min(10.0, (atr_p - 40.0) * 0.2)
```

**Formula breakdown**:
| Component | Min | Max | Formula |
|-----------|-----|-----|---------|
| Base | 60 | 60 | Fixed |
| sep_ticks contribution | 0 | 25 | `min(25, sep_ticks * 1.5)` - maxes at sep_ticks=16.67 |
| ATR contribution | -8 | 10 | `(atr_p - 40) * 0.2` - negative if atr_p < 40 |
| **TOTAL** | **52** | **95** | |

**Problem**: At sep_ticks=4 (minimum), atr_p=60 (median):
- Score = 60 + 6 + 4 = **70** (easily passes min_score=60)

### 2.4 Breakout Scoring (Lines 224-256)
```python
if atr_p >= float(min_atr_percentile_breakout):  # default: 65.0
    if is_up and last_close > prev_high + tick_size:
        score = 62.0 + min(20.0, sep_ticks * 1.2) + min(12.0, (atr_p - 50.0) * 0.25)
```

**Formula breakdown**:
| Component | Min | Max | Formula |
|-----------|-----|-----|---------|
| Base | 62 | 62 | Fixed |
| sep_ticks contribution | 0 | 20 | `min(20, sep_ticks * 1.2)` - maxes at sep_ticks=16.67 |
| ATR contribution | 3.75 | 12 | `(atr_p - 50) * 0.25` - starts at atr_p=65 (min requirement) |
| **TOTAL** | **65.75** | **94** | |

**Note**: The min_atr_percentile_breakout=65 gate provides some quality control, but only for volatility, not trend strength.

### 2.5 Touch Distance (Lines 177)
```python
touch_dist = float(max(tick_size, min(float(max(0.0, atr)) * 0.35, float(max(0.0, atr)) or tick_size)))
```

**Simplified**: `touch_dist = max(0.01, atr * 0.35)`

With ATR=$5: touch_dist = $1.75

This means price within $1.75 of EMA counts as a "touch" - far too generous.

### 2.6 Hurst Regime Gate (Lines 137-138)
```python
if hurst is not None and hurst < min_hurst:
    return []  # No TrendFollow signals when market is not trending
```

**Status**: Correctly implemented, blocks signals when H < 0.55. This is a positive addition but its effect is not in the historical backtest data.

---

## 3. Issues Identified

### 3.1 CRITICAL Severity

| Issue | Description | Impact | Evidence |
|-------|-------------|--------|----------|
| **sep_ticks too low** | 4 ticks = $0.04 = 0.002% of price. For $2000+ gold, this is noise. | Signals fire on every micro-oscillation | 4/5 months losing, high signal count |
| **Base score = min_score** | Pullback base=60, Breakout base=62, min_score=60. Any valid signal passes. | No quality gate for marginal conditions | Scoring formula analysis |

### 3.2 HIGH Severity

| Issue | Description | Impact | Evidence |
|-------|-------------|--------|----------|
| **touch_dist too wide** | 0.35*ATR = $1.75 zone. Most pullbacks qualify. | Over-triggers pullback signals | Formula: 0.35 * $5 = $1.75 |
| **No candle quality filter** | Breakouts accept any close above prior high | False breakouts on doji/spinning tops | Code review (lines 225, 241) |

### 3.3 MEDIUM Severity

| Issue | Description | Impact | Evidence |
|-------|-------------|--------|----------|
| **No momentum confirmation** | No RSI/MACD/volume check for breakouts | Breakouts at exhaustion points | Missing in code |
| **No time-of-day filter** | Signals at session opens (whipsaw zones) | Higher loss rate during opens | Not implemented |
| **EMA periods may be short** | EMA 20/50 on ~12-second bars = 4-10 minute trend | Micro-trends prone to noise | stride 20 with ~100 ticks/min |

### 3.4 LOW Severity

| Issue | Description | Impact | Evidence |
|-------|-------------|--------|----------|
| **trend_bias potential overfit** | Directional bias at micro level not validated | Could skew results on down-moves | Feature exists (off by default) |

---

## 4. Improvement Proposals

### 4.1 Priority 1: Increase sep_ticks Threshold (HIGHEST IMPACT)

**Current**: `sep_ticks >= 4.0`
**Proposed**: `sep_ticks >= 40` (10x stricter) or percentage-based: `sep_pct >= 0.02%`

**Implementation**:
```python
# Option A: Fixed tick threshold
MIN_SEP_TICKS = 40  # $0.40 on XAUUSD

# Option B: Percentage-based (better for varying price levels)
min_sep_pct = 0.0002  # 0.02% of price
sep_pct = sep / closes[-1]
if sep_pct < min_sep_pct:
    return []
```

**Expected Impact**:
- Reduce signal count by 60-80%
- Filter noise-driven signals
- Improve win rate by 15-25%

**Disproof Test**:
1. Run backtest with sep_ticks=40 on Mar/Jun 2024 (worst months)
2. Compare signal count and P&L
3. If still losing, threshold is not the primary issue

### 4.2 Priority 2: Raise min_score (HIGH IMPACT)

**Current**: `min_score = 60.0`
**Proposed**: `min_score = 75.0`

**Expected Impact**:
- Require sep_ticks >= 10 + some ATR contribution to pass
- Reduce signal count by 40-60%
- Keep only higher-quality setups

**Disproof Test**:
1. Stratify historical signals by score bucket (60-70, 70-80, 80+)
2. Compare win rates per bucket
3. If score >= 75 has lower win rate, hypothesis is wrong

### 4.3 Priority 3: Tighten touch_dist (MEDIUM IMPACT)

**Current**: `touch_dist = atr * 0.35`
**Proposed**: `touch_dist = atr * 0.15` or fixed 30 ticks ($0.30)

**Implementation**:
```python
# Tighter touch requirement
touch_dist = float(max(tick_size * 10, atr * 0.15))  # ~$0.75 with $5 ATR
```

**Expected Impact**:
- Reduce pullback signals by 50%
- Require actual EMA touch, not "near EMA"
- Improve pullback win rate by 10-20%

**Disproof Test**:
1. Compare pullback outcomes at touch_dist <= 0.15*ATR vs > 0.15*ATR
2. If no difference in win rate, touch precision doesn't matter

### 4.4 Priority 4: Add Candle Quality Filter for Breakouts (MEDIUM IMPACT)

**Current**: Any close above prior high
**Proposed**: Require body >= 50% of range (reject doji/spinning tops)

**Implementation**:
```python
# Candle quality check
bar_range = h[-1] - l[-1]
bar_body = abs(c[-1] - c[-2])  # or abs(close - open) if open available
body_ratio = bar_body / bar_range if bar_range > 0 else 0
if body_ratio < 0.5:
    # Skip this breakout - weak candle
    continue
```

**Expected Impact**:
- Filter 30-40% of false breakouts
- Improve breakout win rate by 15-20%

**Disproof Test**:
1. Compare breakout outcomes by body_ratio buckets
2. If body_ratio has no correlation with outcome, filter is useless

### 4.5 Lower Priority Proposals

| Proposal | Description | Expected Impact |
|----------|-------------|-----------------|
| **Time-of-day filter** | Block signals in first 30 min of NY/London open | Reduce 15-25% of whipsaw trades |
| **ATR penalty for breakouts** | If atr_p < 30, multiply score by 0.8 | Filter quiet-market breakouts |
| **RSI confirmation** | Require RSI > 60 (long) or < 40 (short) for breakouts | Improve breakout quality by 20-30% |
| **Multi-timeframe alignment** | Require higher-TF EMA alignment | Improve win rate by 15-25% |

---

## 5. Questions for Next Round

1. **What Hurst values were present during Mar/Jun 2024 losses?** If H < 0.55 was common, the new gate should help. If H > 0.55, the strategy failed DURING trending conditions.

2. **What is the actual signal count per month?** High signal count + low win rate = filter problem. Low signal count + large losses = stop-loss or sizing problem.

3. **Were both variants (Pullback + Breakout) equally bad?** If one variant is profitable and the other losing, we should focus improvements on the losing variant.

4. **What was the distribution of sep_ticks in actual signals?** If most signals fired at sep_ticks=4-10, tightening threshold will have huge impact. If signals already had high sep_ticks, the issue is elsewhere.

5. **Is there tick-level data quality issue?** Mar/Jun could have data gaps, spread spikes, or other anomalies.

---

## 6. Confidence Level

**Overall Confidence: 7/10**

| Component | Confidence | Reasoning |
|-----------|------------|-----------|
| Problem identification | 9/10 | Code is clear, issues are obvious from formula analysis |
| sep_ticks too low | 9/10 | Math is unambiguous: 4 ticks = 0.002% is noise |
| Scoring formula issue | 8/10 | Base = threshold is clearly no quality gate |
| Specific threshold values | 5/10 | Need backtests to validate 40 vs 60 vs 80 |
| Hurst gate effectiveness | 4/10 | Just implemented, no data yet |
| Expected impact % | 6/10 | Estimates based on similar systems, not this specific data |

**Key Uncertainties**:
1. Actual distribution of conditions in losing months (need backtest breakdown)
2. Whether tighter thresholds would have prevented losses OR just reduced signal count without improving outcomes
3. Whether Hurst gate alone is sufficient or additional filters are needed

---

## 7. Recommended Next Steps

1. **ROUND 02**: Run diagnostic backtest on Mar/Jun 2024 to capture:
   - Hurst distribution during signals
   - sep_ticks distribution during signals
   - Win rate by variant (Pullback vs Breakout)
   - Signal count per day

2. **ROUND 03**: Implement sep_ticks increase to 40 and retest worst months

3. **ROUND 04**: If still losing, add candle quality filter and retest

4. **ROUND 05**: Evaluate min_score increase if issues persist

5. **ROUND 06**: Final validation with full WFA/MC if improvements look promising

---

*Analysis completed by ORACLE v3.4 | 2024-12-24*
