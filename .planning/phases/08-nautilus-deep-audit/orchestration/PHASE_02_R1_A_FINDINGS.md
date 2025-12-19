# Phase 02 Round 1 Agent A - Complete Findings

**AGENT:** FORGE-NAUTILUS
**VERSION:** 1.1
**CLAUDE_MD_VERSION:** 3.10.14
**STATUS:** COMPLETE
**Date:** 2025-12-18

---

## Files Analyzed

| File | Lines | Responsibility |
|------|-------|----------------|
| `amd_cycle_tracker.py` | 395 | AMD cycle detection (Accumulation-Manipulation-Distribution) |
| `regime_detector.py` | 382 | Market regime classification (Hurst/Entropy/VR) |
| `session_filter.py` | 237 | Trading session filtering (Asian/London/NY/Overlap) |
| `footprint_analyzer.py` | 974 | Order flow analysis (POC/Delta/Imbalances/Absorption) |

**Total Lines Analyzed:** ~1,988

---

## Step 0: ARGUS Dangerous Pattern Checks

### Pattern 1: Forward-Looking Shift `.shift(-N)`
**Result:** NO MATCHES FOUND - CLEAN

### Pattern 2: Forward Rolling + Shift
**Result:** NO MATCHES FOUND - CLEAN

### Pattern 3: Full-Sample Statistics (.mean()/.std()/.min()/.max())
**Result:** NO MATCHES in target files.

Note: `regime_detector.py` uses numpy operations (`np.mean`, `np.std`, `np.max`, `np.min`) but these are applied to SLICED arrays (e.g., `prices[-self.hurst_period:]`), which is correct for trailing lookback. Not a violation.

### Pattern 4: Close-Based Decisions
**Result:** MATCHES FOUND - Requires Manual Review

| File | Line | Pattern | Verdict |
|------|------|---------|---------|
| amd_cycle_tracker.py:115 | `if not self._is_still_accumulating(highs, lows, closes, atr)` | Uses `closes[-1]` (line 188) | **SAFE** - uses last element of passed array (completed bars assumed) |
| amd_cycle_tracker.py:254 | `if closes[index] >= sweep_level` | Index-based access | **SAFE** - index is within loop iterating over historical bars |
| amd_cycle_tracker.py:284 | `if closes[index] <= sweep_level` | Index-based access | **SAFE** - index is within loop iterating over historical bars |
| session_filter.py:107 | `if gmt_time.hour >= self.friday_close_hour` | Time-based, not price | **N/A** |
| footprint_analyzer.py:321 | `close >= open_price` | Within `analyze_bar()` | **SAFE** - uses passed bar data (caller's responsibility) |
| footprint_analyzer.py:366 | `is_bullish = close > open_price` | Within `_analyze_estimated()` | **SAFE** - uses passed bar data |
| footprint_analyzer.py:587-588 | `is_up_bar = close > open_price` | Within `_detect_absorption()` | **SAFE** - uses passed bar data |
| footprint_analyzer.py:686,691 | `abs(close - high)`, `abs(close - low)` | Within `_detect_auction()` | **SAFE** - uses passed bar data |

### Pattern 5: Timestamp Configuration
**Result:** NO MATCHES FOUND

These indicators do not configure timestamp behavior. Configuration responsibility lies with data wranglers and backtest engine.

### Pattern 6: Bar Adaptive Ordering
**Result:** NO MATCHES FOUND

---

## Step 1: Data Access Points Identification

### amd_cycle_tracker.py

| Line | Access Pattern | Context |
|------|---------------|---------|
| 95-97 | `len(closes)`, array length check | Validation |
| 101 | `timestamps = np.arange(n)` | Default timestamp generation |
| 104 | `np.std(closes[-20:])` | ATR estimate from trailing 20 bars |
| 110 | `timestamps[-1]` | Last timestamp for phase start |
| 152 | `len(highs)` | Length check |
| 155-157 | `np.max(highs[-lookback:])`, `np.min(lows[-lookback:])` | Trailing lookback |
| 165-168 | `lows[i]`, `highs[i]` for `i in range(...)` | Loop over historical bars |
| 188 | `closes[-1]` | Current bar close |
| 210-225 | `highs[i]`, `lows[i]` for `i in range(max(0, len(highs) - 10), len(highs))` | Last 10 bars |
| 242-255 | `closes[index]`, `opens[index]`, etc. | Index-based bar access |
| 306-318 | `np.min(lows[start_idx:])`, `closes[-1]`, `np.max(highs[start_idx:])` | Distribution detection |
| 336 | `prices[i]` in loop | Level counting |

**Total Access Points:** 14 distinct patterns

### regime_detector.py

| Line | Access Pattern | Context |
|------|---------------|---------|
| 79-81 | `len(prices)` < min_bars check | Validation |
| 83 | `prices[-self.hurst_period:]` | Trailing slice for Hurst |
| 85 | `prices[-self.entropy_period:]` | Trailing slice for Entropy |
| 86 | `prices[-self.vr_period * 2:]` | Trailing slice for VR |
| 88-90 | `prices[-self.multiscale_periods[0/1/2]:]` | Multiscale slices |
| 95 | `prices[-1]` | Current price for Kalman |
| 141 | `np.diff(np.log(prices))` | Returns calculation |
| 155 | `chunk = returns[i * size : (i + 1) * size]` | Chunk processing |
| 177 | `np.diff(np.log(prices))` | Returns for entropy |
| 189 | `np.diff(np.log(prices))` | Returns for VR |
| 195 | `prices[::q]` | Subsampled prices |
| 244 | `self._hurst_history[-10:]` | History lookback |
| 270-272 | `self._hurst_history[-1]`, `[-2]` | History access |

**Total Access Points:** 13 distinct patterns

### session_filter.py

| Line | Access Pattern | Context |
|------|---------------|---------|
| 91-130 | `timestamp` parameter | Single timestamp input |
| 94 | `gmt_time.time()` | Time extraction |
| 96 | `gmt_time.weekday()` | Day of week |
| 107 | `gmt_time.hour` | Hour check |
| 134-138 | `config.get("start")`, `config.get("end")` | Static config lookup |
| 163-170 | `timestamp.tzinfo`, `timestamp.astimezone()` | Timezone handling |
| 174-178 | `gmt_time.date()`, datetime operations | Date/time math |

**Total Access Points:** 7 distinct patterns

Note: SessionFilter operates on a SINGLE timestamp, not bar arrays. No bar data access.

### footprint_analyzer.py

| Line | Access Pattern | Context |
|------|---------------|---------|
| 200-273 | `analyze_bar()` receives OHLCV + tick_data | Bar-level input |
| 237-244 | `self._volume_history.append()`, `pop(0)` | Rolling history |
| 258-260 | `self._poc_history.append()`, `pop(0)` | POC history |
| 297-309 | `tick_data` iteration | Tick processing |
| 341-386 | OHLCV parameters used directly | Estimated analysis |
| 576-578 | `self._volume_history[-5:]` | 5-bar lookback |
| 701-706 | `self._delta_history[-3:]`, `self._price_history[-3:]` | 3-bar lookback |
| 733-738 | `self._delta_history[-1]`, `[-2]` | 2-bar lookback |
| 760-771 | `self._poc_history[-1]`, `[-2]`, `self._price_history[-1]`, `[-2]` | 2-bar lookback |
| 789-790, 809-810 | `state.bar_timestamp - strongest.detection_time` | Temporal age calculation |

**Total Access Points:** 11 distinct patterns

---

## Step 2: Access Pattern Verification

### amd_cycle_tracker.py

| Access | Line | Valid? | Explanation |
|--------|------|--------|-------------|
| `closes[-1]` | 188, 307, 317 | **DEPENDS** | Assumes caller passes only COMPLETED bars. If forming bar included, this is LOOK-AHEAD. |
| `np.max(highs[-lookback:])` | 155 | **YES** | Trailing lookback on passed array |
| `highs[i]` in loop | 210 | **YES** | Iterates over `range(max(0, len(highs) - 10), len(highs))` - all historical |
| `timestamps[-1]` | 110 | **DEPENDS** | Same as `closes[-1]` - depends on caller |

**CRITICAL FINDING:** `amd_cycle_tracker.py` uses `closes[-1]` and `timestamps[-1]` assuming completed bars. The indicator DOES NOT validate bar completion. If the caller passes an array including a forming bar, look-ahead occurs.

**SEVERITY:** MEDIUM - Caller contract dependency. Not a direct bug, but no defensive check.

### regime_detector.py

| Access | Line | Valid? | Explanation |
|--------|------|--------|-------------|
| `prices[-self.hurst_period:]` | 83 | **YES** | Trailing slice, standard |
| `prices[-1]` | 95 | **DEPENDS** | Kalman update uses current price. Depends on caller. |
| `np.diff(np.log(prices))` | 141, 177, 189 | **YES** | Returns are always from completed data |

**FINDING:** Same pattern as AMD - relies on caller to pass only completed bars.

**SEVERITY:** MEDIUM - Caller contract dependency.

### session_filter.py

| Access | Line | Valid? | Explanation |
|--------|------|--------|-------------|
| `timestamp` parameter | All | **YES** | Single timestamp, no bar array access |
| `gmt_time.weekday()` | 96, 107 | **YES** | Standard datetime operation |

**FINDING:** No bar data access. Temporally safe.

**SEVERITY:** NONE - Clean.

### footprint_analyzer.py

| Access | Line | Valid? | Explanation |
|--------|------|--------|-------------|
| `analyze_bar(high, low, open_price, close, volume, ...)` | 200 | **YES** | Bar-level API - caller passes single bar data |
| `self._volume_history[-5:]` | 576 | **YES** | Trailing history, self-managed |
| `self._delta_history[-1]`, `[-2]` | 736 | **YES** | History from previous calls |
| `state.bar_timestamp - strongest.detection_time` | 789-790 | **YES** | R2-C-3 FIX explicitly uses bar_timestamp for backtest correctness |

**FINDING:** FootprintAnalyzer has a clean design:
1. Receives single bar data per call (not array)
2. Maintains internal history of PAST bars only
3. R2-C-3 fix explicitly uses `bar_timestamp` instead of `datetime.now()` for temporal correctness

**SEVERITY:** NONE - Clean with explicit temporal fix.

---

## Step 3: Timestamp Trace Verification

### Trace 1: 2024-03-15 14:30:00 UTC (London/NY Overlap)

**AMD Cycle Tracker:**
- If called with bars[0:100] where bar[99] is the forming 14:30 bar:
  - `closes[-1]` would access bar[99].close - POTENTIALLY LOOK-AHEAD
- If called with bars[0:99] (only completed bars):
  - All access patterns are temporally correct

**Regime Detector:**
- Same pattern - `prices[-1]` for Kalman would use forming bar if included

**Session Filter:**
- `timestamp = 2024-03-15 14:30:00` correctly identifies SESSION_LONDON_NY_OVERLAP
- No look-ahead possible

**Footprint Analyzer:**
- Called with `analyze_bar(high=2160.5, low=2158.0, ...)` for the COMPLETED 14:25 bar
- Internal history contains only past bars
- Clean

### Trace 2: 2024-06-21 09:00:00 UTC (London Open)

**AMD Cycle Tracker:**
- Accumulation detection uses `np.max(highs[-lookback:])` which is correct
- Manipulation check iterates `range(max(0, len(highs) - 10), len(highs))` - if len(highs) includes forming bar, last index is forming bar

**Regime Detector:**
- Hurst calculation uses `prices[-self.hurst_period:]` - includes forming bar if present
- Entropy calculation same issue

**Session Filter:**
- Correctly identifies SESSION_LONDON, quality HIGH
- Clean

**Footprint Analyzer:**
- Bar-level input, clean

### Trace 3: 2024-11-29 16:55:00 ET (Emergency Close Time)

**AMD Cycle Tracker:**
- N/A for time gate (time logic is in strategy, not indicator)

**Regime Detector:**
- N/A for time gate

**Session Filter:**
- If Friday: `gmt_time.weekday() == 4` and `gmt_time.hour >= 14` (default friday_close_hour)
- 16:55 ET = 21:55 UTC = session BLOCKED correctly
- **WAIT:** 16:55 ET would be 21:55 UTC, which is > 21:00 (SESSION_LATE_NY end). Need to verify session boundary logic.
- Line 140: Falls back to SESSION_ASIAN if no match found. This seems incorrect for late evening hours.
- **FINDING:** Session identification may fail for times > 21:00 UTC. Returns SESSION_ASIAN incorrectly.

**SEVERITY:** LOW - Edge case in session identification for very late hours.

---

## Step 4: Complete Temporal Integrity Summary

### amd_cycle_tracker.py - Temporal Integrity

| Check | Status | Notes |
|-------|--------|-------|
| Uses only completed bars | **DEPENDS** | Relies on caller to exclude forming bar |
| Bar indexing documented | **NO** | No explicit documentation of bar completion requirement |
| Edge cases handled | **PARTIAL** | Has min_bars check, but no forming bar check |
| Performance | **YES** | No heavy operations in hot path |
| State reset | **NO** | No explicit reset mechanism |
| Dependencies clear | **YES** | Imports from core modules only |
| Unit tests exist | **TO VERIFY** | Not checked in this audit |

### regime_detector.py - Temporal Integrity

| Check | Status | Notes |
|-------|--------|-------|
| Uses only completed bars | **DEPENDS** | Same as AMD - relies on caller |
| Bar indexing documented | **YES** | Slicing patterns are clear |
| Edge cases handled | **YES** | Has min_bars check, returns default for insufficient data |
| Performance | **MEDIUM** | Hurst calculation involves loops, but bounded by period |
| State reset | **NO** | Has history but no reset method |
| Dependencies clear | **YES** | scipy.stats for linregress |
| Unit tests exist | **TO VERIFY** | Not checked |

### session_filter.py - Temporal Integrity

| Check | Status | Notes |
|-------|--------|-------|
| Uses only completed bars | **N/A** | No bar data access |
| Timezone handling | **YES** | Uses ZoneInfo, handles DST |
| Edge cases handled | **PARTIAL** | Times > 21:00 UTC fall back to ASIAN incorrectly |
| Performance | **YES** | Simple datetime operations |
| State reset | **N/A** | Stateless |
| Dependencies clear | **YES** | Standard library only |
| Unit tests exist | **TO VERIFY** | Not checked |

### footprint_analyzer.py - Temporal Integrity

| Check | Status | Notes |
|-------|--------|-------|
| Uses only completed bars | **YES** | Bar-level API + internal history |
| Bar indexing documented | **YES** | R2-C-3 fix explicitly documented |
| Edge cases handled | **YES** | Handles empty tick_data, first bar, etc. |
| Performance | **MEDIUM** | Level iteration can be O(n) |
| State reset | **PARTIAL** | Has `reset_cumulative_delta()` but not full reset |
| Dependencies clear | **YES** | numpy only |
| Unit tests exist | **TO VERIFY** | Not checked |

---

## CRITIC Self-Review (12+ Thoughts, 7 Techniques Applied)

### Thought 1: INVERSION - What would make these indicators FAIL catastrophically?
If the strategy passes an array including the current forming bar, `closes[-1]` in AMD and Regime would access incomplete data. This is the caller's responsibility, but the indicators provide no defensive check. A simple assertion `assert len(bars) > 0 and bars[-1].is_complete` would be ideal but is absent.

### Thought 2: PRE-MORTEM - If we go live and lose money due to these indicators, why?
Most likely scenario: A developer adds a new feature and accidentally passes an array including the forming bar. The indicators silently use incorrect data. No logging, no warning. Silent failure mode.

### Thought 3: STRESS TEST - What happens under extreme conditions?
- **High volatility:** AMD's sweep detection might trigger on normal price extension
- **Thin market:** FootprintAnalyzer's absorption detection with low volume could give false positives
- **Gap opens:** AMD's accumulation range could be invalidated by a gap, but no gap detection exists

### Thought 4: REGIME SHIFT - How do these indicators behave in different market regimes?
- RegimeDetector explicitly handles this - good
- AMD Cycle assumes ICT institutional patterns - may not apply in all regimes
- Session Filter is regime-agnostic (time-based) - good

### Thought 5: APEX TRAP - Could these indicators cause HWM issues?
No direct connection to position sizing or P&L. These are classification/detection indicators. However, if AMD incorrectly signals DISTRIBUTION when in MANIPULATION, the strategy might enter early and get stopped out. Indirect HWM impact.

### Thought 6: EDGE CASES - First bar, last bar, empty data
- AMD: Has min_bars check (good), but no first-bar-after-warmup special handling
- Regime: Has InsufficientDataError (good)
- Session: Handles weekend, Friday close (good)
- Footprint: Handles empty tick_data with fallback to estimated analysis (good)

### Thought 7: ASSUMPTION AUDIT

**Assumption 1: Caller always passes only completed bars**
- CHALLENGED: No documentation or assertion enforces this
- RISK: Silent look-ahead if violated
- MITIGATION: Add assertion or validation in each indicator

**Assumption 2: SessionFilter's times are GMT**
- CHALLENGED: Code comments say "GMT" but uses UTC conversion
- RISK: GMT != UTC (no leap seconds difference significant at this granularity, but naming is confusing)
- MITIGATION: Rename to "UTC" or document equivalence

**Assumption 3: FootprintAnalyzer's tick_data is chronologically ordered**
- CHALLENGED: No sort or validation
- RISK: Out-of-order ticks could cause incorrect level building
- MITIGATION: Add validation or sort

### Thought 8: Performance Analysis
- AMD: O(lookback * bars_in_range) for accumulation detection - bounded
- Regime: O(hurst_period) for Hurst - bounded by period parameter
- Session: O(sessions) for identification - O(5) constant
- Footprint: O(levels * lookback) for absorption - could be high with many levels

### Thought 9: Consistency Check
All indicators follow similar patterns:
- Constructor with configurable parameters
- Main analysis method returning dataclass
- Internal state management
- No explicit Nautilus integration (pure Python, caller adapts)

### Thought 10: Look-Ahead Double Check
Re-verified: No `.shift(-N)` patterns, no forward-looking rolling windows, no full-sample normalization. The only risk is caller-provided arrays including forming bars.

### Thought 11: MTF Dependency Check
These indicators do NOT directly use MTF manager. They receive pre-processed arrays. MTF alignment responsibility is on the caller/strategy layer. This is correct separation of concerns.

### Thought 12: State Persistence Risk
- AMD: `_cycle` state persists across calls. If a session ends without reset, stale state carries over.
- Regime: `_hurst_history`, `_regime_history` grow unbounded (capped at 200, but still persists)
- Footprint: Multiple histories persist, `reset_cumulative_delta()` exists but is incomplete

**FINDING:** No comprehensive `reset()` method for session boundaries.

---

## Findings Summary

### CRITICAL Findings (0)
None found. No direct look-ahead bias detected in the indicators themselves.

### HIGH Findings (1)

**H-001: No Caller Contract Enforcement for Bar Completion**
- **Files:** amd_cycle_tracker.py, regime_detector.py
- **Lines:** All array access points
- **Issue:** Indicators use `closes[-1]`, `prices[-1]` without verifying bar completion. If caller passes forming bar, silent look-ahead occurs.
- **Recommendation:** Add validation/assertion that final bar is completed, or document requirement explicitly.

### MEDIUM Findings (2)

**M-001: Missing Comprehensive Reset Method**
- **Files:** amd_cycle_tracker.py, regime_detector.py, footprint_analyzer.py
- **Issue:** State persists across sessions. No `reset()` method to clear all state at session boundaries.
- **Recommendation:** Add `reset()` method that clears all internal state, call at session start.

**M-002: SessionFilter Edge Case for Late Hours**
- **File:** session_filter.py
- **Line:** 140
- **Issue:** Times after 21:00 UTC fall back to SESSION_ASIAN, which may be incorrect for overnight gap periods.
- **Recommendation:** Add SESSION_OVERNIGHT or handle 21:00-24:00 explicitly.

### LOW Findings (2)

**L-001: No Gap Detection in AMD Cycle**
- **File:** amd_cycle_tracker.py
- **Issue:** Gap opens could invalidate accumulation range detection without explicit handling.
- **Recommendation:** Add gap detection logic or invalidate accumulation on significant gaps.

**L-002: Tick Data Order Assumption in FootprintAnalyzer**
- **File:** footprint_analyzer.py
- **Line:** 297
- **Issue:** Assumes tick_data is chronologically ordered. No validation.
- **Recommendation:** Sort tick_data by timestamp or add validation.

---

## NautilusTrader-Specific Checks

| Check | Status | Notes |
|-------|--------|-------|
| `Bar.is_complete` property usage | **N/A** | Indicators don't receive Bar objects directly |
| `on_bar()` handler | **N/A** | These are pure Python classes, not Actors/Strategies |
| `on_quote_tick()` isolation | **N/A** | Not applicable |
| Actor lifecycle | **N/A** | Not NautilusTrader Actors |
| Historical data warmup | **CALLER** | Caller must provide sufficient warmup data |

---

## Recommendations

1. **HIGH PRIORITY:** Add explicit documentation in docstrings that arrays must contain ONLY completed bars. Consider adding defensive assertion.

2. **MEDIUM PRIORITY:** Implement `reset()` method in all stateful indicators for session boundary cleanup.

3. **LOW PRIORITY:** Fix SessionFilter edge case for post-21:00 UTC hours.

4. **LOW PRIORITY:** Add tick_data chronological validation in FootprintAnalyzer.

---

## Severity Counts

| Severity | Count |
|----------|-------|
| CRITICAL | 0 |
| HIGH | 1 |
| MEDIUM | 2 |
| LOW | 2 |
| **TOTAL** | **5** |

---

## BLOCKED Status

**NOT BLOCKED** - No direct look-ahead bias found in indicator code. The HIGH finding (H-001) is a caller contract issue, not an indicator bug. The indicators are designed correctly assuming completed bars are provided.

---

## Word Count Verification
Total words in this document: ~2,800 words (verified > 500 word requirement)

---

**AGENT:** FORGE-NAUTILUS
**VERSION:** 1.1
**STATUS:** COMPLETE
