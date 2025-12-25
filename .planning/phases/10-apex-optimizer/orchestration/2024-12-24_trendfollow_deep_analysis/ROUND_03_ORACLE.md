# ORACLE Round 3 Analysis Report

## ORACLE Output
AGENT: ORACLE
VERSION: 3.4
CLAUDE_MD_VERSION: 3.10.23
STATUS: COMPLETE
ROUND: 3 of 6
FOCUS: Missed Entries + Edge Cases + Filter Interaction

---

## Executive Summary

Round 3 analysis reveals a **confirmed logic bug** in the bounce detection that misses legitimate single-bar touch-and-bounce patterns, a **critical unhandled edge case** (spread > SL distance), and significant **signal starvation risk** (~80% reduction) if all proposed filters are applied simultaneously. Breakout variant faces ~92% reduction (severe).

**Confidence Update**: 7.0/10 (down from 7.5)

---

## 1. Missed Entry Patterns Analysis

### Pattern 1: Same-Bar Touch-and-Bounce (CONFIRMED BUG)

**Location**: Lines 181-182, 200-201

**Current Logic (LONG example)**:
```python
touched = min(prev_low, last_low) <= ema_ref + touch_dist
bounced = last_close > last_ema_f and (prev_close <= prev_ema_f or prev_low <= prev_ema_f)
```

**Bug Description**:
- `touched` can be satisfied by `last_low` (current bar's wick touches EMA)
- `bounced` only checks `prev_bar` conditions
- If current bar dips to EMA and recovers, but previous bar was entirely above EMA, signal is NOT generated

**Example Scenario**:
| Bar | Low | EMA | Close | Condition |
|-----|-----|-----|-------|-----------|
| -2 (prev) | 2000 | 1990 | 2005 | prev_low > prev_ema, prev_close > prev_ema |
| -1 (last) | 1988 | 1990 | 2003 | last_low <= ema (touch), last_close > ema (bounce) |

**Result**:
- `touched = TRUE` (min(2000, 1988) = 1988 <= 1990 + touch_dist)
- `bounced = TRUE AND (FALSE OR FALSE) = FALSE`
- **Signal NOT generated** despite valid pullback

**Impact Estimate**: ~10-15% of legitimate pullback signals missed

**Proposed Fix**:
```python
# Single-bar touch-and-bounce
single_bar_bounce = last_low <= last_ema_f + touch_dist and last_close > last_ema_f

# Two-bar setup
two_bar_bounce = (prev_close <= prev_ema_f or prev_low <= prev_ema_f) and last_close > last_ema_f

bounced = single_bar_bounce or two_bar_bounce
```

---

### Pattern 2: Low-Volatility Breakouts Filtered

**Location**: Line 224

**Current Logic**:
```python
if atr_p >= float(min_atr_percentile_breakout):  # Default 65.0
```

**Issue**: Breakouts during volatility compression (low ATR percentile) are blocked.

**Technical Analysis Conflict**: Classical TA wisdom says best breakouts come from compression periods. But for Apex DD constraints, low-vol breakouts mean smaller moves and worse RR.

**Recommendation**: Keep as-is for Apex safety. Document as intentional trade-off.

---

### Pattern 3: Trend-Leading Breakouts

**Location**: Lines 225, 241

**Issue**: Breakout requires EMA alignment (`is_up`/`is_down`). A breakout that PRECEDES the EMA cross is not captured.

**Impact**: Breakouts at trend initiation (before EMAs confirm) are missed.

**Recommendation**: Low priority. EMA alignment is a feature, not a bug. Catching early breakouts increases false positive risk.

---

## 2. Edge Case Catalog

### CRITICAL Risk

| ID | Edge Case | Location | Issue | Mitigation |
|----|-----------|----------|-------|------------|
| EC-5 | Spread > SL Distance | Lines 187, 206, 230, 246 | SL can be smaller than spread. Trade is guaranteed loser. | Add execution layer check: `SL_distance > 2*spread` |

### HIGH Risk

| ID | Edge Case | Location | Issue | Mitigation |
|----|-----------|----------|-------|------------|
| EC-1 | Market Gaps | Lines 166-167, 221-222 | After weekend/news gap, prev_high/prev_low from before gap is irrelevant | Add gap detection: `abs(open - prev_close) > threshold` |
| EC-6 | Minimum SL Too Low | Lines 187, 206, 230, 246 | SL as small as 0.02 (2 ticks) is allowed. XAUUSD needs 50+ ticks minimum. | Add min_sl_ticks parameter (default 50) |

### MEDIUM Risk

| ID | Edge Case | Location | Issue | Mitigation |
|----|-----------|----------|-------|------------|
| EC-3 | Zero/NaN ATR | Line 177 | ATR=0 degrades to tick_size (minimal touch_dist) | Add ATR validation, return [] if invalid |
| EC-4 | Extreme High ATR | Line 177 | touch_dist = 0.35*ATR can become very wide | Already addressed by reducing to 0.15*ATR |
| EC-7 | Concurrent Signals | Line 161 | Both PULLBACK and BREAKOUT can trigger on same bar | Document expected behavior, downstream must prioritize |
| EC-11 | NaN in Price Arrays | Throughout | NaN propagates through EMA, all comparisons fail silently | Add `np.isnan().any()` check at start |

### LOW Risk (Handled or Normal)

| ID | Edge Case | Status |
|----|-----------|--------|
| EC-2 | Threshold Boundaries | Normal behavior (>= vs >) |
| EC-8 | LONG + SHORT Simultaneously | Impossible by design (is_up/is_down mutually exclusive) |
| EC-9 | Hurst at Threshold | Normal behavior |
| EC-10 | Insufficient Data | Handled (line 140-141) |
| EC-12 | Lookback Beyond Data | Handled by Python slicing |
| EC-13 | tick_size = 0 | Handled (line 142-143) |
| EC-14 | Score at min_score | Normal behavior |

---

## 3. Filter Interaction Analysis

### Current Configuration
| Filter | Current Value | Strictness |
|--------|---------------|------------|
| sep_ticks | >= 4.0 | Very permissive |
| min_score | >= 60.0 | No filtering (base = 60) |
| touch_dist | 0.35 * ATR | Wide tolerance |
| Breakout confirm | Immediate | No delay |

### Proposed Configuration
| Filter | Proposed Value | Change Factor |
|--------|----------------|---------------|
| sep_ticks | >= 40 | 10x stricter |
| min_score | >= 75 | Requires 15+ bonus |
| touch_dist | 0.15 * ATR | 2.3x stricter |
| Breakout confirm | 1-bar delay | New filter |

### Reduction Estimates by Filter

| Filter | Independent Reduction | Notes |
|--------|----------------------|-------|
| sep_ticks >= 40 | ~65% | Dominant filter. Only strong trends pass. |
| touch_dist 0.15*ATR | ~30% | Stricter touch requirement |
| min_score >= 75 | ~5% | **REDUNDANT** if sep_ticks >= 40 |
| Breakout 1-bar | ~35% | Filters fakeouts but misses momentum |

### Why min_score >= 75 is Redundant

Score formula (PULLBACK):
```python
score = 60.0 + min(25.0, sep_ticks * 1.5) + min(10.0, (atr_p - 40.0) * 0.2)
```

With sep_ticks = 40:
- Base: 60.0
- sep_ticks contribution: min(25.0, 40 * 1.5) = min(25.0, 60) = **25.0**
- Minimum score without ATR bonus: **85.0**

**Conclusion**: Any signal passing sep_ticks >= 40 automatically scores >= 85. The min_score >= 75 gate is never the binding constraint.

### Combined Reduction Estimates

**PULLBACK Variant**:
```
P(pass) = P(sep >= 40) * P(touch | sep) * P(bounce | touch)
        = 0.35 * 0.70 * 0.80
        = 0.196 (~20% survival)
```

**BREAKOUT Variant**:
```
P(pass) = P(sep >= 40) * P(ATR >= 65) * P(confirm)
        = 0.35 * 0.35 * 0.65
        = 0.08 (~8% survival)
```

### Signal Starvation Risk Assessment

| Variant | Signal Survival | Starvation Level | Impact |
|---------|----------------|------------------|--------|
| PULLBACK | ~20% | Moderate | Acceptable if quality improves |
| BREAKOUT | ~8% | **SEVERE** | May need filter relaxation |

**Recommendation**:
1. Consider relaxing breakout ATR gate if sep_ticks already strict
2. Run diagnostic backtest to measure actual reduction before implementing

---

## 4. Diagnostic Backtest Specification

### Purpose
Answer: "What were the actual parameter distributions during losses?"

### Target Period
- March 2024 (worst month by Gate 9 failures)
- June 2024 (secondary problem period)
- Total: ~60 days of data

### Data Pipeline
```
1. Load: data/raw/full_parquet/xauusd_2003_2025_stride20_full.parquet
2. Filter: 2024-03-01 to 2024-03-31 + 2024-06-01 to 2024-06-30
3. Aggregate: 1-minute OHLC bars (~86,400 bars)
4. Calculate: EMA20, EMA50, ATR14, ATR percentile, Hurst
5. Run: Signal generator on each bar with full logging
6. Simulate: Trade outcomes for passed signals
```

### Output Artifacts

**File 1**: `diagnostics_all_evaluations.csv`
| Column | Type | Description |
|--------|------|-------------|
| timestamp | datetime | Bar timestamp |
| variant | enum | pullback/breakout |
| direction | enum | long/short |
| hurst | float | Hurst exponent at signal time |
| sep_ticks | float | EMA separation in ticks |
| touch_dist | float | Touch distance used |
| touched | bool | Touch condition met |
| bounced | bool | Bounce condition met |
| score | float | Calculated score |
| atr_pct | float | ATR percentile |
| passed | bool | Signal generated |
| filter_reason | string | Why filtered (if applicable) |

**File 2**: `diagnostics_trades.csv`
| Column | Type | Description |
|--------|------|-------------|
| timestamp | datetime | Entry timestamp |
| variant | enum | pullback/breakout |
| direction | enum | long/short |
| entry_price | float | Entry level |
| sl_distance | float | Stop loss distance |
| outcome | enum | sl_hit/tp_hit/time_exit |
| pnl | float | Realized PnL |
| bars_held | int | Trade duration |

### Analysis Queries

```sql
-- Q1: Losing trades by sep_ticks bucket
SELECT
  CASE WHEN sep_ticks < 10 THEN '<10'
       WHEN sep_ticks < 20 THEN '10-20'
       WHEN sep_ticks < 40 THEN '20-40'
       ELSE '40+' END as sep_bucket,
  COUNT(*) as trades,
  SUM(CASE WHEN pnl < 0 THEN 1 ELSE 0 END) as losers,
  AVG(pnl) as avg_pnl
FROM diagnostics_trades
GROUP BY sep_bucket;

-- Q2: Filter reasons distribution
SELECT filter_reason, COUNT(*) as filtered_count
FROM diagnostics_all_evaluations
WHERE NOT passed
GROUP BY filter_reason;

-- Q3: Hurst during losses
SELECT AVG(hurst), MIN(hurst), MAX(hurst)
FROM diagnostics_trades t
JOIN diagnostics_all_evaluations e ON t.timestamp = e.timestamp
WHERE t.pnl < 0;
```

### Execution Time Estimate
~5-7 minutes total

---

## 5. Questions for Round 4

| ID | Question | Priority | Data Needed |
|----|----------|----------|-------------|
| Q1 | What is actual sep_ticks distribution in full dataset? | HIGH | Histogram from diagnostic run |
| Q2 | What was Hurst distribution during Mar/Jun 2024? | HIGH | Should have blocked most signals if < 0.55 |
| Q3 | For the 3 Gate 9 blowup trades, what were exact parameters? | CRITICAL | Forensic trade data |
| Q4 | What % of filtered signals would have been winners? | MEDIUM | Counterfactual analysis |
| Q5 | Are PULLBACK and BREAKOUT failures correlated? | MEDIUM | Joint failure analysis |
| Q6 | During Asia/News sessions, what is typical ATR vs London? | MEDIUM | Session-segmented ATR |

---

## 6. Confidence Update

| Metric | Round 2 | Round 3 | Delta | Reason |
|--------|---------|---------|-------|--------|
| Confidence | 7.5/10 | 7.0/10 | -0.5 | Bug confirmed, critical edge case unhandled, starvation risk |

### Risk Factors Lowering Confidence
1. **Confirmed Logic Bug**: Same-bar touch-and-bounce pattern missed
2. **Critical Edge Case**: Spread > SL scenario allows guaranteed losing trades
3. **Signal Starvation**: Combined filters may reduce breakout signals by 92%
4. **Need Empirical Validation**: Estimates are theoretical, need diagnostic backtest

---

## 7. Handoff Recommendations

### To FORGE (Priority: HIGH)
1. Fix bounce logic bug (add single-bar pattern)
2. Implement diagnostic version of trend_follow.py
3. Add `meta['bounce_type']` field for analysis
4. Add spread validation check

**Deliverable**: `trend_follow_diagnostic.py` + fixed production version

### To CRUCIBLE (Priority: MEDIUM)
1. Review edge case catalog
2. Prioritize: EC-5 (Spread > SL), EC-1 (Gaps), EC-6 (Min SL)
3. Validate bounce logic fix doesn't weaken selectivity

**Deliverable**: Edge case mitigation priority list

### To SENTINEL (Priority: MEDIUM)
1. Assess signal starvation risk for Apex timeline
2. Question: Is 20% pullback survival acceptable?
3. Question: Is 8% breakout survival viable or should we drop the variant?

**Deliverable**: Signal frequency vs Apex target analysis

### To ORACLE Round 4 (Priority: HIGH)
1. Implement diagnostic backtest
2. Run on Mar/Jun 2024 data
3. Analyze: sep_ticks distribution, filter hit rates, loss forensics
4. Answer Q1-Q6 with empirical data

**Deliverable**: Diagnostic analysis report with recommendations

---

## 8. Summary of Key Findings

### Confirmed Issues
1. **Bounce Logic Bug** (Line 182): Single-bar pullback patterns missed
2. **Spread > SL Not Checked**: Critical edge case (EC-5)
3. **min_score >= 75 is Redundant**: sep_ticks >= 40 guarantees score >= 85

### Filter Interaction
- Combined filters: ~80% signal reduction
- Breakout variant: ~92% reduction (severe starvation)
- sep_ticks is the dominant filter

### Recommendations Summary
| Priority | Action | Owner |
|----------|--------|-------|
| CRITICAL | Add spread > SL validation | FORGE |
| HIGH | Fix bounce logic bug | FORGE |
| HIGH | Run diagnostic backtest | ORACLE R4 |
| MEDIUM | Relax breakout ATR gate if sep_ticks strict | CRUCIBLE |
| MEDIUM | Add gap detection filter | FORGE |
| LOW | Add NaN validation | FORGE |

---

*Generated by ORACLE v3.4 - Statistical Truth-Seeker*
*CLAUDE.md v3.10.23 compliant*
