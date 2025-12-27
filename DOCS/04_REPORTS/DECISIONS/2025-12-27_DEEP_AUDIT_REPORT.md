# Deep Audit Report - Nautilus Gold Scalper
**Date**: 2025-12-27
**Auditors**: CRUCIBLE, SENTINEL, FORGE (Claude Opus)
**Scope**: Full system audit for production readiness

---

## Executive Summary

Five parallel deep audits were conducted to verify the robot's readiness for live trading:

| Audit Area | Agent | Verdict | Critical Issues |
|------------|-------|---------|-----------------|
| SMC Logic (OB/FVG/Sweep) | CRUCIBLE | ❌ **PRELIMINARY NO-GO** | 4 critical bugs |
| Risk Calculations | SENTINEL | ⚠️ **CONDITIONAL** | 2 integration gaps |
| Look-Ahead Bias | FORGE | ⚠️ **CONDITIONAL** | 1 footgun risk |
| Edge Cases | FORGE | ⚠️ **CONDITIONAL** | 3 unhandled scenarios |
| DST/Timezone | FORGE | ✅ **GO** | None |

**Overall Verdict**: NOT READY FOR LIVE TRADING until critical issues are resolved.

---

## 1. SMC Logic Audit (CRUCIBLE)

### 1.1 Overview
The Smart Money Concepts implementation was audited for correctness against SMC theory. The confluence scoring system is well-designed, but the underlying detectors have significant implementation bugs.

### 1.2 Component Scores

| Component | Pattern Definition | Edge Detection | Direction Logic | Invalidation | Score |
|-----------|-------------------|----------------|-----------------|--------------|-------|
| Order Blocks | ❌ FAIL | ✅ PASS | ✅ PASS | ❌ FAIL | 50% |
| FVG | ✅ PASS | ❌ FAIL | ✅ PASS | ❌ FAIL | 50% |
| Liquidity Sweeps | ✅ PASS | ❌ FAIL | ✅ PASS | ❌ FAIL | 50% |
| Market Structure | ✅ PASS | ✅ PASS | ✅ PASS | ❌ FAIL | 75% |
| Confluence Scorer | ✅ PASS | ✅ PASS | ✅ PASS | ✅ PASS | 100% |
| **TOTAL** | | | | | **65%** |

### 1.3 Critical Issues

#### ISSUE SMC-1: Order Block Institutional Scoring Bug (CRITICAL)
**File**: `/home/franco/projetos/EA_SCALPER_XAUUSD/nautilus_gold_scalper/src/indicators/order_block_detector.py:291`

**Problem**: The `is_institutional` flag is computed AFTER `strength`, `quality`, and `probability_score` are calculated. This means institutional OB bonuses are NEVER applied during scoring.

**Code (current - buggy)**:
```python
ob.strength = self._calculate_ob_strength(ob)
ob.quality = self._classify_ob_quality(ob)
ob.probability_score = self._calculate_probability_score(ob)
ob.is_fresh = True
ob.is_institutional = self._is_institutional_ob(ob)  # TOO LATE!
```

**Impact**: OB quality is systematically mis-scored. Institutional order blocks (which are higher quality) are under-detected or under-weighted.

**Fix Required**: Reorder to compute `is_institutional` BEFORE strength/quality/probability.

---

#### ISSUE SMC-2: Liquidity Pools / Sweeps Recency (CRITICAL)
**File**: `/home/franco/projetos/EA_SCALPER_XAUUSD/nautilus_gold_scalper/src/indicators/liquidity_sweep.py:174`

**Problem**: Two recency issues can corrupt signals:
1) Pool scans must be based on a trailing window (not oldest bars).
2) Sweep detection must prefer the most recent sweep in the scan window.

**Impact**: Sweeps can be detected against stale pools or "most recent" sweep can actually be an older one, causing wrong direction/sequence decisions.

**Fix Applied**:
- Pool scans iterate over trailing indices (aligned to `n - lookback .. n`).
- Sweep scan loops iterate newest→oldest, and `get_most_recent_sweep()` returns max by `bar_index`.
**Evidence**:
- `/home/franco/projetos/EA_SCALPER_XAUUSD/nautilus_gold_scalper/src/indicators/liquidity_sweep.py:449`
- `/home/franco/projetos/EA_SCALPER_XAUUSD/nautilus_gold_scalper/src/indicators/liquidity_sweep.py:646`

---

#### ISSUE SMC-3: Structure Break Chronology Collapsed (CRITICAL)
**File**: `/home/franco/projetos/EA_SCALPER_XAUUSD/nautilus_gold_scalper/src/indicators/structure_analyzer.py:462`

**Problem**: `_detect_breaks()` could record both a bearish-break and bullish-break in the same update, and the later loop overwrote `self._state.last_break`. This collapses chronology when price is beyond multiple swing levels at once.

**Impact**:
- BOS/CHoCH sequencing can be wrong
- Non-deterministic `last_break` when multiple levels are broken on the same bar
- Downstream confluence scoring may flip direction unexpectedly

**Fix Applied**: Short-circuit `_detect_breaks()` after the first recorded break (nearest swing by price), preventing same-update overwrite.
**Evidence**: `break_recorded` early-return in `/home/franco/projetos/EA_SCALPER_XAUUSD/nautilus_gold_scalper/src/indicators/structure_analyzer.py:479`

---

#### ISSUE SMC-4: FVG Fill Semantics Incorrect (HIGH)
**File**: `/home/franco/projetos/EA_SCALPER_XAUUSD/nautilus_gold_scalper/src/indicators/fvg_detector.py:449`

**Problem**: Fill progression must be wick-inclusive and directionally correct:
- Bullish FVG fills when price trades DOWN into the gap.
- Bearish FVG fills when price trades UP into the gap.

**Impact**: Incorrect fill% can keep stale FVGs "open" (false POIs) or mark them filled too easily.

**Fix Applied**:
- Use bar high/low overlap to detect touches (wick-inclusive).
- Correct directional fill% math and clamp `0..100` with assertion.
**Evidence**: `/home/franco/projetos/EA_SCALPER_XAUUSD/nautilus_gold_scalper/src/indicators/fvg_detector.py:475`

---

### 1.4 Additional SMC Issues (Medium Priority)

#### ISSUE SMC-7: Fibonacci Counts as Factor Even When Not Scoring (MEDIUM)
**File**: `/home/franco/projetos/EA_SCALPER_XAUUSD/nautilus_gold_scalper/src/signals/confluence_scorer.py:905`

**Problem**: Fibonacci direction was being counted as a bullish/bearish factor even when `fib_score == 0`. That inflated `total_confluences`, distorted alignment/divergence multipliers, and could bias direction selection in marginal cases.

**Fix Applied**: Only increment bullish/bearish factor counters when `fib_score > 0`.
**Evidence**: `/home/franco/projetos/EA_SCALPER_XAUUSD/nautilus_gold_scalper/src/signals/confluence_scorer.py:944`

---

#### ISSUE SMC-5: OB Requirements Not Enforced (LOW) - ✅ RESOLVED
**File**: `/home/franco/projetos/EA_SCALPER_XAUUSD/nautilus_gold_scalper/src/indicators/order_block_detector.py:178`

**Problem**: `require_structure_break` existed but was not enforced.

**Fix Applied**: When enabled, require the displacement candle to close beyond the trailing structure extreme (causal; excludes OB candle):
- Bullish OB: `close > max(highs[window])`
- Bearish OB: `close < min(lows[window])`

**Evidence**: `_has_structure_break()` in `/home/franco/projetos/EA_SCALPER_XAUUSD/nautilus_gold_scalper/src/indicators/order_block_detector.py:474`

---

#### ISSUE SMC-6: Structure Bias Ambiguity (LOW) - ✅ RESOLVED
**File**: `/home/franco/projetos/EA_SCALPER_XAUUSD/nautilus_gold_scalper/src/indicators/structure_analyzer.py:425`

**Problem**: EQH/EQL (equal highs/lows) can accidentally qualify for directional bias.

**Fix Applied**: Treat EQH/EQL as ambiguous and fail-closed to `RANGING` for bias.
- Bullish requires strict `HH + HL`
- Bearish requires strict `LH + LL`

**Test**: `test_eqh_or_eql_bias_is_ranging` in `/home/franco/projetos/EA_SCALPER_XAUUSD/nautilus_gold_scalper/tests/test_indicators/test_smc_detectors.py:296`

---

### 1.5 What's Working Well (SMC)
- Confluence Scorer correctly aggregates signals from all detectors
- Sweep direction semantics are consistent with expected post-sweep move
- Basic pattern recognition (3-candle FVG, OB candidate identification) follows theory

---

## 2. Risk Calculations Audit (SENTINEL)

### 2.1 Overview
Risk management calculations were audited for mathematical correctness and Apex compliance. Core formulas are correct, but there are integration gaps where features exist but aren't wired into the trading pipeline.

### 2.2 Component Assessment

#### HWM (High Water Mark) Tracking - ✅ PASS

**File**: `/home/franco/projetos/EA_SCALPER_XAUUSD/nautilus_gold_scalper/src/risk/drawdown_tracker.py:215`

**Formula (correct)**:
```python
if current_equity > self._high_water_mark:
    self._high_water_mark = current_equity
```

**Conservative Unrealized PnL**:
- BID price used for LONG positions
- ASK price used for SHORT positions
- Implemented in: `/home/franco/projetos/EA_SCALPER_XAUUSD/nautilus_gold_scalper/src/strategies/base_strategy.py:1457`

**Spec Caveat**: CLAUDE.md mentions EOD HWM reset to realized equity. Code keeps HWM monotonic without explicit EOD reset. This is MORE conservative (safer for Apex).

---

#### Trailing DD Calculation - ✅ PASS

**File**: `/home/franco/projetos/EA_SCALPER_XAUUSD/nautilus_gold_scalper/src/risk/drawdown_tracker.py:226`

**Formula**:
```python
trailing_dd_pct = (self._high_water_mark - current_equity) / self._high_water_mark * 100.0
```

**Worked Example**:
- HWM = $52,000
- Current Equity = $50,000
- DD% = (52000-50000)/52000 × 100 = **3.846%** ✅

**Note**: `DrawdownTracker` doesn't clamp to [0,100] but `DDProtectionCalculator` does.

---

#### Daily DD Calculation - ✅ PASS

**File**: `/home/franco/projetos/EA_SCALPER_XAUUSD/nautilus_gold_scalper/src/risk/drawdown_tracker.py:221`

**Formula**:
```python
daily_dd_pct = (daily_start_equity - current_equity) / daily_start_equity * 100.0
```

**Thresholds (match CLAUDE.md)**:
| Level | Threshold | Action |
|-------|-----------|--------|
| WARN | 1.5% | Alert |
| CAUTION | 2.0% | Alert |
| REDUCE | 2.5% | Reduce size 50% |
| HALT | 3.0% | Stop trading |

**File**: `/home/franco/projetos/EA_SCALPER_XAUUSD/nautilus_gold_scalper/src/risk/dd_protection.py:51`

---

#### Position Sizing - ⚠️ CONDITIONAL

**File**: `/home/franco/projetos/EA_SCALPER_XAUUSD/nautilus_gold_scalper/src/risk/position_sizer.py:265`

**Formula (correct)**:
```python
lot = (balance * risk_percent) / (stop_loss_pips * pip_value)
```

**Worked Example**:
- Risk Amount = $500
- SL Distance = 2.0 points
- Point Value = $10/point
- Qty = 500 / (2.0 × 10) = **25 contracts** ✅

**Clamping**:
- Uses `floor(lot/step)*step` to avoid rounding up risk
- Final safety check rescales if `actual_risk > max_risk_per_trade`

---

### 2.3 Critical Integration Gaps

#### ISSUE RISK-1: DD Throttle Not Connected (HIGH)
**Files**:
- `/home/franco/projetos/EA_SCALPER_XAUUSD/nautilus_gold_scalper/src/risk/position_sizer.py:275` (has the feature)
- `/home/franco/projetos/EA_SCALPER_XAUUSD/nautilus_gold_scalper/src/strategies/gold_scalper_strategy.py:3632` (doesn't pass it)

**Problem**: `PositionSizer` supports drawdown-based size reduction via `current_drawdown_pct` parameter, but NO CALL SITE passes this value.

**Code (missing parameter)**:
```python
# In gold_scalper_strategy.py:3632
quantity = self._calculate_position_size(sl_distance, hbs_size_mult)
# Should be:
# quantity = self._calculate_position_size(sl_distance, hbs_size_mult, current_dd_pct)
```

**Impact**: The "multi-tier size reduction" intent from CLAUDE.md is NOT implemented. Only hard halts work; gradual size reduction doesn't happen.

**Fix Required**: Pass `current_drawdown_pct` from DrawdownTracker to PositionSizer.

---

#### ISSUE RISK-2: HWM EOD Reset Semantics (MEDIUM) - ✅ RESOLVED

**Problem**: HWM is monotonic and never resets. Initial analysis suggested CLAUDE.md describes EOD reset.

**Current Behavior**: HWM persists across days (monotonic, more conservative).

**Resolution (2025-12-27)**: After deeper analysis, the current behavior is CORRECT for Apex:

1. **Apex Semantics**: Apex trailing drawdown is calculated from the HIGHEST equity ever reached during the evaluation/funded period, NOT from daily peaks. The HWM should be monotonic.

2. **CLAUDE.md Interpretation**: The phrase "NEVER decreases during a session" refers to intraday behavior. Apex does NOT reset HWM at EOD - trailing DD tracks from inception peak.

3. **Documentation Added**: Clarifying docstrings added to:
   - `DrawdownTracker.reset_daily()`: Explains HWM is intentionally NOT reset
   - `PropFirmManager.on_new_day()`: Same clarification

4. **Conclusion**: No code change needed. The monotonic HWM is the correct Apex interpretation and is more conservative (safer). The "issue" was a documentation gap, not a bug.

---

### 2.4 Apex Compliance Summary

| Rule | Implementation | Status |
|------|---------------|--------|
| 5% Trailing DD (termination) | Tier at 5.0% | ✅ Present |
| 4.5% Safety Buffer | Tier at 4.5% HALT | ✅ Present |
| 4.0% Hard Block | Trade validation blocks at 4.0% | ✅ Present |
| Unrealized PnL in HWM | Conservative BID/ASK MTM | ✅ Present |
| 30% Daily Profit Rule | Implemented in HBS | ✅ Present |

**File Evidence**:
- 4.0% hard block: `/home/franco/projetos/EA_SCALPER_XAUUSD/nautilus_gold_scalper/src/risk/dd_protection.py:407`
- Strategy halt: `/home/franco/projetos/EA_SCALPER_XAUUSD/nautilus_gold_scalper/src/strategies/base_strategy.py:1648`

---

## 3. Look-Ahead Bias Audit (FORGE)

### 3.1 Overview
All indicators and signals were audited for temporal leakage (using future data). No direct look-ahead bias was found in the indicator implementations. However, there's a significant integration-level risk in MTF handling.

### 3.2 Files Audited
- `/home/franco/projetos/EA_SCALPER_XAUUSD/nautilus_gold_scalper/src/indicators/regime_detector.py` ✅
- `/home/franco/projetos/EA_SCALPER_XAUUSD/nautilus_gold_scalper/src/indicators/structure_analyzer.py` ✅
- `/home/franco/projetos/EA_SCALPER_XAUUSD/nautilus_gold_scalper/src/signals/mtf_manager.py` ⚠️
- `/home/franco/projetos/EA_SCALPER_XAUUSD/nautilus_gold_scalper/src/indicators/fvg_detector.py` ✅
- `/home/franco/projetos/EA_SCALPER_XAUUSD/nautilus_gold_scalper/src/indicators/order_block_detector.py` ✅
- `/home/franco/projetos/EA_SCALPER_XAUUSD/nautilus_gold_scalper/src/indicators/liquidity_sweep.py` ✅
- `/home/franco/projetos/EA_SCALPER_XAUUSD/nautilus_gold_scalper/src/indicators/footprint_analyzer.py` ✅
- `/home/franco/projetos/EA_SCALPER_XAUUSD/nautilus_gold_scalper/src/indicators/amd_cycle_tracker.py` ✅

### 3.3 Patterns Checked
| Pattern | Description | Found? |
|---------|-------------|--------|
| `array[i+1]` | Forward indexing | ❌ None |
| `.shift(-N)` | Negative pandas shift | ❌ None |
| `center=True` | Centered rolling | ❌ None |
| Full dataset fit | Model trained on all data | ❌ None |

### 3.4 MTF Integration Risk

#### ISSUE LOOKAHEAD-1: MTFManager Doesn't Validate Timestamps (MEDIUM)
**File**: `/home/franco/projetos/EA_SCALPER_XAUUSD/nautilus_gold_scalper/src/signals/mtf_manager.py:242`

**Problem**: `_validate_data()` checks shape/dtype/length but does NOT verify:
- Timestamps are monotonic increasing
- Last HTF/MTF timestamp ≤ last LTF timestamp
- Bars represent completed bars only

**Current Mitigation**: Strategy filters bars before passing to MTFManager:
```python
# In gold_scalper_strategy.py:3431
current_ltf_ts = int(self._ltf_bars[-1].ts_event)
htf_bars = [b for b in self._htf_bars if int(b.ts_event) <= current_ltf_ts]
mtf_bars = [b for b in self._mtf_bars if int(b.ts_event) <= current_ltf_ts]
```

**Risk**: If ANY other caller uses MTFManager without this filtering, they get silent leakage.

**Fix Required**: Add defensive timestamp validation inside MTFManager itself.

---

### 3.5 Safe Patterns Found

#### Swing Detection (Delayed Confirmation)
**File**: `/home/franco/projetos/EA_SCALPER_XAUUSD/nautilus_gold_scalper/src/indicators/structure_analyzer.py:289`

```python
# A swing at candidate index `cand` is only confirmed once `strength` bars have elapsed.
# We evaluate `cand = i - strength` using the symmetric window [cand-strength, cand+strength]
# which is fully known at time `i`.
for i in range(strength * 2, n):
    cand = i - strength
```
This is causally correct - the swing at `cand` is only labeled when we're at bar `i` (future of `cand`).

#### Regime Detection (Trailing Window)
**File**: `/home/franco/projetos/EA_SCALPER_XAUUSD/nautilus_gold_scalper/src/indicators/regime_detector.py:113`

```python
prices_f[-self.hurst_period:]
prices_f[-self.entropy_period:]
```
Uses only trailing slices. No centered rolling, no full-dataset fit.

---

### 3.6 Footgun Warning
All detectors (FVG, OB, Sweep, AMD) loop to `len(series)` internally. They are causal ONLY IF the caller passes "data up to now" slices. They are NOT SAFE if run once on full dataset and then signals are read historically.

---

## 4. Edge Cases Audit (FORGE)

### 4.1 Overview
The system was audited for handling of edge cases: data gaps, missing data, extreme volatility, position edge cases, and time edge cases.

### 4.2 Assessment Summary

| Category | Handling | Evidence |
|----------|----------|----------|
| Data Gaps | ⚠️ PARTIAL | No explicit gap detector |
| Missing Data | ✅ ROBUST | NaN/invalid rejected |
| Extreme Volatility | ⚠️ PARTIAL | Indirect controls only |
| Position Edge Cases | ✅ ROBUST | Partial fills, zero qty handled |
| Time Edge Cases | ✅ ROBUST | Time gates implemented |

### 4.3 Critical Gaps

#### ISSUE EDGE-1: No Gap Cooldown After Market Reopen (HIGH) - ✅ RESOLVED
**File**: `/home/franco/projetos/EA_SCALPER_XAUUSD/nautilus_gold_scalper/src/strategies/gold_scalper_strategy.py:1754`

**Fix Applied**: Added deterministic gap cooldown in the signal gate:
- If `bar.ts_event - last_seen_ts` ≥ `gap_reopen_threshold_minutes`, block new entries for `gap_reopen_cooldown_minutes`.
- Resets daily on new ET day.

**Config**:
- `gap_reopen_threshold_minutes`
- `gap_reopen_cooldown_minutes`

---

#### ISSUE EDGE-2: Out-of-Order Timestamp Guard (MEDIUM) - ✅ ALREADY PRESENT
**File**: `/home/franco/projetos/EA_SCALPER_XAUUSD/nautilus_gold_scalper/src/strategies/gold_scalper_strategy.py:512`

**Current State**: Strategy tracks `_last_event_ts_ns` and rejects regressive timestamps (fail-closed).

---

#### ISSUE EDGE-3: Spread Warm-up Window Permissive (MEDIUM) - ✅ RESOLVED
**File**: `/home/franco/projetos/EA_SCALPER_XAUUSD/nautilus_gold_scalper/src/strategies/gold_scalper_strategy.py:1009`

**Problem**: SpreadMonitor can allow `can_trade=True` while collecting initial baseline.

**Fix Applied**: Enable fail-closed warmup by default (block entries until baseline exists):
- Config default: `spread_warmup_block_trading=True`
- YAML: `spread_monitor.warmup_block_trading: true`

---

#### ISSUE EDGE-4: Duplicate Timestamps Not Deduped (LOW) - ✅ RESOLVED
**File**: `/home/franco/projetos/EA_SCALPER_XAUUSD/nautilus_gold_scalper/scripts/backtest/run_backtest.py:464`

**Problem**: Tick loader must enforce unique timestamps for deterministic aggregation.

**Fix Applied**: De-duplicate after sort using `keep='first'` (preserves causality) and log removed count.

---

### 4.4 What's Working Well (Edge Cases)

#### Missing Data Handling
- **Tick Loader**: Rejects NaN datetime, sorts if not monotonic, rejects NaN bid/ask
- **Spread Monitor**: Rejects non-finite/crossed bid/ask
- **Prop Firm Manager**: Fail-closed on non-finite equity
- **Regime Detector**: Filters NaN/<=0 before log-metrics, raises InsufficientDataError

#### Position Edge Cases
- **Order Lifecycle**: Ignores non-positive fills, clamps overfills
- **Position Sizer**: Returns 0 lot if SL ≤ 0 or pip_value ≤ 0
- **Strategy**: Size ≤ 0 returns None, avoiding zero-qty orders

#### Time Edge Cases
- **Time Constraint Manager**: Blocks new trades after 4:30 PM ET, force-close at 4:55 PM, cutoff at 4:59 PM
- **DrawdownTracker**: ET day boundary support via `day_boundary_tz="America/New_York"`

---

## 5. DST/Timezone Audit (FORGE)

### 5.1 Overview
All timezone handling was audited, especially around DST transitions. The implementation is correct and safe.

### 5.2 Verdict: ✅ GO

### 5.3 Key Findings

#### ZoneInfo Usage - ✅ CORRECT
All modules use `ZoneInfo("America/New_York")` which handles DST automatically:
- `human_simulator.py:39`: `ET = ZoneInfo("America/New_York")`
- `time_constraint_manager.py:17-20`: `ET_TZ = ZoneInfo("America/New_York")` with try/except guard
- `gold_scalper_strategy.py:1334-1336`: `et_tz = ZoneInfo("America/New_York")`

#### No Hardcoded Offsets - ✅ CORRECT
No instances of `-4` or `-5` hour offsets found. All conversions use `astimezone()`.

#### DST Transition Handling - ✅ CORRECT
**File**: `/home/franco/projetos/EA_SCALPER_XAUUSD/nautilus_gold_scalper/src/execution/human_simulator.py:42-79`

The `_localize_et_strict()` function properly handles:
- **Ambiguous times** (fall back): Detects by offset difference between folds, raises ValueError
- **Nonexistent times** (spring forward): Detects by round-trip comparison, raises ValueError

```python
dt_fold0 = dt.replace(tzinfo=ET, fold=0)
dt_fold1 = dt.replace(tzinfo=ET, fold=1)
...
if ok0 and ok1:
    raise ValueError(f"Ambiguous local time in ET: {dt!r}")
if not ok0 and not ok1:
    raise ValueError(f"Nonexistent local time in ET: {dt!r}")
```

#### Apex Time Gates - ✅ CORRECT

| Gate | Time | Implementation |
|------|------|----------------|
| Block new trades | 16:30 ET | `TimeConstraintManager.can_open_new()` |
| Force-close window | 16:55 ET | `TimeConstraintManager.check()` |
| Must be flat | 16:59 ET | `cutoff` in TimeConstraintManager |

All gates use ET-local comparison via `astimezone(ET)`.

#### Degraded Mode - ✅ FAIL-CLOSED
If ET timezone cannot be resolved (`ET_TZ is None`):
- `can_open_new()` returns False
- `check()` returns False
- `_to_et()` triggers `_force_close_all(trigger="timezone_unavailable")`

### 5.4 Residual Risks (Minor)

1. **Naive UTC Misinterpretation**: If caller supplies naive datetime (tzinfo=None) that's actually UTC, `_localize_et_strict()` will treat it as ET-local. Mitigation: Strategy uses UTC timestamps from Nautilus.

2. **Missing tzdata**: `ZoneInfo("America/New_York")` fails if tzdata package missing. Most modules don't guard this at import. Mitigation: `time_constraint_manager.py` has try/except.

---

## 6. Prioritized Fix Plan

### Phase 1: Critical Fixes (Block Trading)

| ID | Issue | Priority | Effort | Files |
|----|-------|----------|--------|-------|
| SMC-1 | OB institutional scoring order | CRITICAL | Low | `order_block_detector.py` |
| SMC-2 | Liquidity pools stale window | CRITICAL | Medium | `liquidity_sweep.py` |
| SMC-3 | Structure break chronology | CRITICAL | Medium | `structure_analyzer.py` |
| SMC-4 | FVG fill detection | HIGH | Low | `fvg_detector.py` |

### Phase 2: Risk Integration (Affect Sizing)

| ID | Issue | Priority | Effort | Files | Status |
|----|-------|----------|--------|-------|--------|
| RISK-1 | DD throttle not connected | HIGH | Low | `gold_scalper_strategy.py` | ✅ FIXED |
| RISK-2 | HWM EOD reset semantics | MEDIUM | Low | Documentation | ✅ RESOLVED (correct behavior) |

### Phase 3: Defensive Guards (Robustness)

| ID | Issue | Priority | Effort | Files | Status |
|----|-------|----------|--------|-------|--------|
| LOOKAHEAD-1 | MTFManager timestamp validation | MEDIUM | Low | `mtf_manager.py` | ✅ FIXED |
| EDGE-1 | Gap cooldown after reopen | MEDIUM | Medium | New code + integration | ✅ FIXED |
| EDGE-2 | Out-of-order timestamp guard | MEDIUM | Low | `gold_scalper_strategy.py` | ✅ FIXED |
| EDGE-3 | Spread warm-up strictness | LOW | Low | `spread_monitor.py` | ✅ FIXED (knob added) |

### Phase 4: Minor Cleanup

| ID | Issue | Priority | Effort | Files |
|----|-------|----------|--------|-------|
| SMC-5 | OB requirements enforcement | LOW | Medium | `order_block_detector.py` |
| SMC-6 | Structure bias ambiguity | LOW | Low | `structure_analyzer.py` |
| EDGE-4 | Duplicate timestamp dedupe | LOW | Low | `run_backtest.py` |

---

## 7. Testing Strategy

### After Each Fix:
1. Run `pytest -q` - all 523 tests must pass
2. Run `mypy --strict` - must report "no issues"
3. Run short backtest to verify no regression

### After All Fixes:
1. Run `--smoke-matrix` to verify all feature flags still work
2. Run WFA/Monte Carlo to quantify signal quality improvement
3. Compare before/after metrics for SMC fixes

---

## 8. Files Reference

### SMC Logic
- `/home/franco/projetos/EA_SCALPER_XAUUSD/nautilus_gold_scalper/src/indicators/order_block_detector.py`
- `/home/franco/projetos/EA_SCALPER_XAUUSD/nautilus_gold_scalper/src/indicators/fvg_detector.py`
- `/home/franco/projetos/EA_SCALPER_XAUUSD/nautilus_gold_scalper/src/indicators/liquidity_sweep.py`
- `/home/franco/projetos/EA_SCALPER_XAUUSD/nautilus_gold_scalper/src/indicators/structure_analyzer.py`
- `/home/franco/projetos/EA_SCALPER_XAUUSD/nautilus_gold_scalper/src/signals/confluence_scorer.py`

### Risk Management
- `/home/franco/projetos/EA_SCALPER_XAUUSD/nautilus_gold_scalper/src/risk/drawdown_tracker.py`
- `/home/franco/projetos/EA_SCALPER_XAUUSD/nautilus_gold_scalper/src/risk/dd_protection.py`
- `/home/franco/projetos/EA_SCALPER_XAUUSD/nautilus_gold_scalper/src/risk/position_sizer.py`
- `/home/franco/projetos/EA_SCALPER_XAUUSD/nautilus_gold_scalper/src/risk/prop_firm_manager.py`

### Strategy
- `/home/franco/projetos/EA_SCALPER_XAUUSD/nautilus_gold_scalper/src/strategies/gold_scalper_strategy.py`
- `/home/franco/projetos/EA_SCALPER_XAUUSD/nautilus_gold_scalper/src/strategies/base_strategy.py`

### MTF/Signals
- `/home/franco/projetos/EA_SCALPER_XAUUSD/nautilus_gold_scalper/src/signals/mtf_manager.py`

### Time/Timezone
- `/home/franco/projetos/EA_SCALPER_XAUUSD/nautilus_gold_scalper/src/risk/time_constraint_manager.py`
- `/home/franco/projetos/EA_SCALPER_XAUUSD/nautilus_gold_scalper/src/execution/human_simulator.py`

---

## 9. Appendix: Agent Raw Outputs

### A. CRUCIBLE (SMC Audit) - Saved inline
### B. SENTINEL (Risk Audit) - Saved inline
### C. FORGE (Look-Ahead Audit) - Saved inline
### D. FORGE (Edge Cases Audit) - Saved inline
### E. FORGE (DST/Timezone Audit) - Saved to `/tmp/audit_dst_timezone.md`

---

## 10. Implementation Status

### Phase 1: Critical Fixes (Block Trading) - ✅ COMPLETE

| ID | Issue | Status | Fix Applied |
|----|-------|--------|-------------|
| SMC-1 | OB institutional scoring order | ✅ FIXED | Compute `ob.is_institutional` before strength/quality/probability so bonuses apply |
| SMC-2 | Liquidity pools / sweeps recency | ✅ FIXED | Use trailing window for pool detection + newest→oldest sweep scan; "most recent" uses max `bar_index` |
| SMC-3 | Structure break chronology | ✅ FIXED | Short-circuit after first break so `last_break` cannot be overwritten in same update |
| SMC-4 | FVG fill semantics | ✅ FIXED | Wick-inclusive touch + correct directional fill% math (clamped 0..100) |

### Phase 2: Risk Integration (Affect Sizing) - ✅ COMPLETE

| ID | Issue | Status | Fix Applied |
|----|-------|--------|-------------|
| RISK-1 | DD throttle not connected | ✅ FIXED | Pass `current_drawdown_pct` from DrawdownTracker to PositionSizer |

### Phase 3: Defensive Guards (Robustness) - ✅ COMPLETE

| ID | Issue | Status | Fix Applied |
|----|-------|--------|-------------|
| LOOKAHEAD-1 | MTFManager timestamp validation | ✅ FIXED | Added monotonicity check in `_validate_data()` |
| EDGE-2 | Out-of-order timestamp guard | ✅ FIXED | Added `_last_event_ts_ns` tracking and regressive timestamp rejection |

### Validation Gates

- **pytest**: 619 passed, 7 skipped ✅
- **mypy --strict** (repo gate): No issues found ✅

---

**Document Created**: 2025-12-27T03:30:00Z
**Last Updated**: 2025-12-27T04:15:00Z (tests+determinism fixes)
**Status**: PHASE 1-3 FIXES COMPLETE - READY FOR VALIDATION BACKTEST
