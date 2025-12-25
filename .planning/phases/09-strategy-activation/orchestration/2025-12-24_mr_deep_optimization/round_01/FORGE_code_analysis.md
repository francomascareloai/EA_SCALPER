# FORGE Code Analysis Report - Round 01

**AGENT**: FORGE-NAUTILUS v1.1
**Date**: 2025-12-24
**Task**: Deep code analysis of Mean Revert (MR) strategy implementation
**Status**: COMPLETE

---

## Executive Summary

The Mean Revert strategy has **CRITICAL bugs** preventing proper execution. The primary failure mode is a type mismatch in trade management that causes runtime crashes. Secondary issues include overly restrictive signal filtering and misleading log messages that obscure debugging.

**Priority Fixes Required**:
1. **P0-CRITICAL**: Fix `'bool' object has no attribute 'get'` crash in trade management
2. **P1-HIGH**: Improve signal generation diagnostic logging
3. **P2-MEDIUM**: Relax overly restrictive filtering thresholds

---

## Files Analyzed

| File | Lines | Coverage |
|------|-------|----------|
| `nautilus_gold_scalper/src/signals/mean_revert.py` | 198 | Full |
| `nautilus_gold_scalper/src/strategies/gold_scalper_strategy.py` | ~3200 | Key sections (1590-1689, 2570-2689) |
| `nautilus_gold_scalper/src/strategies/base_strategy.py` | 1463 | Full |
| `nautilus_gold_scalper/src/execution/trade_manager.py` | ~500 | Key sections (300-399) |
| `nautilus_gold_scalper/src/signals/confluence_scorer.py` | ~600 | Key sections (1-100, 250-449, 480-599) |

---

## 1. Bugs and Issues

### BUG-01: `'bool' object has no attribute 'get'` [P0-CRITICAL]

**Location**: `gold_scalper_strategy.py` lines 2595-2600

**Root Cause**: Type mismatch between `trade_manager.py` return value and `gold_scalper_strategy.py` consumption.

**In trade_manager.py (lines 300-310)**:
```python
actions: dict[str, Any] = {
    'current_r': r_multiple,
    'state_changed': False  # <-- BOOLEAN value
}
# ...
if old_state != trade.state:
    actions['state_changed'] = True  # <-- Still BOOLEAN
    actions['old_state'] = old_state.name  # Separate keys
    actions['new_state'] = trade.state.name
```

**In gold_scalper_strategy.py (lines 2595-2600)**:
```python
for action_type, action_data in actions.items():
    # ...
    elif action_type == "state_changed":
        self.log.info(
            f"[TRADE_MANAGER] State changed to {action_data.get('new_state', 'UNKNOWN')}: "
            f"{action_data.get('reason', '')}"
        )  # <-- CRASH: action_data is True/False, not a dict!
```

**Impact**: Runtime crash on any state transition (OPEN -> BREAKEVEN -> TRAILING -> etc.), completely preventing trade management.

**Fix Options**:

**Option A (Recommended)**: Modify `gold_scalper_strategy.py` to handle boolean:
```python
elif action_type == "state_changed":
    if action_data:  # True = state changed
        new_state = actions.get('new_state', 'UNKNOWN')
        reason = actions.get('reason', '')
        self.log.info(f"[TRADE_MANAGER] State changed to {new_state}: {reason}")
```

**Option B**: Modify `trade_manager.py` to return dict for state_changed:
```python
if old_state != trade.state:
    actions['state_changed'] = {
        'changed': True,
        'old_state': old_state.name,
        'new_state': trade.state.name,
        'reason': 'State transition'
    }
```

**Decision**: Option A is safer (minimal changes, no API contract change).

---

### BUG-02: Misleading "Confluence returned None" Log [P1-HIGH]

**Location**: `gold_scalper_strategy.py` line 1623

**Root Cause**: `confluence_result` is initialized to `None` at line 1513 and only populated when `enable_smc=True`. When MR strategy is selected and SMC is disabled, this logs "Confluence returned None" which is misleading.

**Code Path**:
```python
# Line 1513
confluence_result = None

# Line 1523-1540 (only runs if enable_smc=True)
if enable_smc and self._smc_ready and self._session_active:
    confluence_result = self._calculate_confluence(...)

# Line 1623 (misleading log)
if confluence_result is None:
    self.log.warning("[SIGNAL] Confluence returned None (insufficient data or error)")
```

**Impact**:
- Obscures real debugging - "insufficient data" is wrong when SMC is simply disabled
- Makes it hard to diagnose why MR trades aren't firing

**Fix**:
```python
if confluence_result is None:
    if not enable_smc:
        self.log.debug("[SIGNAL] SMC disabled - no confluence score (expected for MR)")
    else:
        self.log.warning("[SIGNAL] Confluence returned None (insufficient data or error)")
```

---

### BUG-03: Empty MeanRevert Candidates Without Diagnostic [P1-HIGH]

**Location**: `gold_scalper_strategy.py` lines 1598-1619

**Issue**: When `generate_mean_revert_candidates()` returns empty list, there's no diagnostic logging to explain WHY (insufficient bars? RSI not extreme? ATR too high? Price not touching bands?).

**Current Code**:
```python
mean_candidates = generate_mean_revert_candidates(
    closes=closes,
    highs=highs,
    lows=lows,
    tick_size=float(self._tick_size),
    atr=atr_val,
    atr_percentile=atr_pctl,
    bb_period=int(getattr(self.config, "mr_bb_period", 20)),
    # ... more params
)
# No logging if empty!
```

**Fix**: Add diagnostic logging in `mean_revert.py`:
```python
def generate_mean_revert_candidates(...) -> list[MeanRevertCandidate]:
    # Return empty with reason for debugging
    if closes.size < min_bars:
        return []  # Could log: f"Insufficient bars: {closes.size} < {min_bars}"
```

---

## 2. Suboptimal Implementations

### SUBOPT-01: Overly Restrictive Filtering in mean_revert.py [P2-MEDIUM]

**Location**: `mean_revert.py` lines 135-148, 167-180

**Issue**: Multiple AND conditions create very narrow signal windows:

```python
# Must ALL be true for LONG signal:
# 1. ATR percentile <= max (default 70%)
# 2. RSI <= oversold (default 30)  <- Very strict
# 3. Price low <= lower_band + touch_dist
# 4. Score >= min_score (execution threshold)
# 5. sl_distance > tick_size

if (atr_p <= float(max_atr_percentile)) and (rsi <= float(rsi_oversold)):
    if last_low <= lower + touch_dist:
        # ... calculate score ...
        if score >= float(min_score) and sl > tick_size:
            candidates.append(...)
```

**Impact**:
- RSI 30 is very extreme - many valid mean reversion setups occur at RSI 35-40
- The combination of RSI + BB + ATR + score makes signals extremely rare
- With 75% win rate but negative expectancy, the issue is likely R:R or trade frequency

**Recommendation**: Consider tiered thresholds:
- Primary zone: RSI <= 30 + BB touch = high score (80+)
- Secondary zone: RSI <= 40 + BB touch = medium score (65-75)

---

### SUBOPT-02: Score Calculation Lacks Volatility Normalization [P2-MEDIUM]

**Location**: `mean_revert.py` lines 142-146

**Issue**: Score is a linear combination without proper normalization:
```python
score = 60.0 + min(20.0, max(0.0, band_excess) * 6.0) + min(15.0, max(0.0, rsi_strength) * 30.0)
score -= min(10.0, max(0.0, atr_p - 40.0) * 0.25)
```

**Problems**:
- Base score of 60 means even weak setups start at 60
- `band_excess` can be negative (price inside bands), making contribution 0
- RSI contribution maxes at 15 points, which may not sufficiently differentiate extreme readings

**Impact**: Scores cluster in 60-75 range, making threshold tuning difficult.

---

### SUBOPT-03: Hardcoded 20-bar Lookback for SL Calculation [P3-LOW]

**Location**: `mean_revert.py` lines 138, 169

```python
recent_low = float(np.min(l[-20:]))  # Hardcoded 20
recent_high = float(np.max(h[-20:]))
```

**Issue**: SL placement uses fixed 20-bar lookback regardless of:
- Timeframe (M5 vs H1 have different bar significance)
- Volatility regime
- Strategy configuration

**Impact**: SL may be too tight (frequent stops) or too loose (poor R:R) depending on conditions.

---

## 3. Design Flaws

### DESIGN-01: Mixed Return Types in trade_manager.py [P1-HIGH]

**Location**: `trade_manager.py` lines 300-370

**Issue**: The `actions` dict mixes value types:
```python
actions: dict[str, Any] = {
    'current_r': r_multiple,        # float
    'state_changed': False,         # bool (BUG source)
    'take_partial': {...},          # dict
    'adjust_sl': {...},             # dict
    'close_position': {...},        # dict
    'old_state': 'OPEN',            # str
    'new_state': 'BREAKEVEN',       # str
}
```

**Impact**:
- Forces consuming code to type-check each value
- Caused BUG-01
- Makes refactoring error-prone

**Recommended Pattern**:
```python
from dataclasses import dataclass
from typing import Optional

@dataclass
class TradeAction:
    action_type: str  # 'partial', 'adjust_sl', 'close', 'state_change'
    data: dict[str, Any]

@dataclass
class TradeManagerResult:
    current_r: float
    state_changed: bool
    old_state: Optional[str]
    new_state: Optional[str]
    actions: list[TradeAction]
```

---

### DESIGN-02: Confluence/Signal Source Coupling [P2-MEDIUM]

**Location**: `gold_scalper_strategy.py` lines 1513-1623

**Issue**: The signal generation logic tightly couples SMC confluence with MeanRevert signals:
- `confluence_result = None` initially
- Only calculated if `enable_smc=True`
- MeanRevert signals are supposed to work WITHOUT SMC
- But logging treats None confluence as an error

**Impact**: MeanRevert strategy is confused with SMC strategy in logging and debugging.

**Recommendation**: Separate signal sources cleanly:
```python
# Clear separation
smc_signal: Optional[ConfluenceResult] = None
mr_signal: Optional[MeanRevertCandidate] = None
trend_signal: Optional[TrendCandidate] = None

# Each populates independently
if enable_smc:
    smc_signal = self._calculate_confluence(...)
if enable_mean_revert:
    mr_signal = self._calculate_mean_revert(...)
# etc.
```

---

### DESIGN-03: No Strategy-Specific Logging Context [P2-MEDIUM]

**Issue**: All strategies share the same logging prefix `[SIGNAL]`, making it hard to filter logs by strategy type.

**Current**:
```
[SIGNAL] Confluence returned None
[SIGNAL] Processing bar...
```

**Recommended**:
```
[SIGNAL:SMC] Confluence calculated: score=75
[SIGNAL:MR] No candidate: RSI=45 > oversold=30
[SIGNAL:TREND] Candidate found: LONG, score=82
```

---

## 4. Performance Issues

### PERF-01: Repeated Array Operations in mean_revert.py [P3-LOW]

**Location**: `mean_revert.py` lines 105-124

```python
c = closes.astype(np.float64, copy=False)
h = highs.astype(np.float64, copy=False)
l = lows.astype(np.float64, copy=False)

# Then later:
last_close = float(c[-1])
last_high = float(h[-1])
last_low = float(l[-1])
```

**Issue**: `astype(copy=False)` returns view only if already float64, otherwise copies. On every bar update, this may allocate new arrays.

**Impact**: Minor - numpy is efficient, but could be optimized by caching typed arrays.

---

### PERF-02: RSI Wilder Calculation is O(n) Every Call [P3-LOW]

**Location**: `mean_revert.py` lines 53-75

```python
def _rsi_wilder(values: NDArray[np.floating[Any]], period: int) -> float:
    # Iterates through ALL diffs every time
    for i in range(period, gains.size):
        avg_gain = (avg_gain * (period - 1) + float(gains[i])) / float(period)
        avg_loss = (avg_loss * (period - 1) + float(losses[i])) / float(period)
```

**Issue**: Full recalculation on every bar instead of incremental update.

**Impact**: For 1000+ bars, this adds latency. Not critical for M5 (bars arrive every 5 min) but suboptimal.

**Fix**: Cache previous avg_gain/avg_loss and update incrementally.

---

## 5. Missing Features

### MISSING-01: No Regime Filter for Mean Revert [P1-HIGH]

**Issue**: Mean reversion works best in ranging/consolidating markets, but there's no regime filter to suppress signals during strong trends.

**Current**: MR fires based solely on BB+RSI, ignoring market regime.

**Impact**: MR signals during strong trends lead to counter-trend entries that get stopped out (explaining negative expectancy despite 75% win rate - the 25% losers are large).

**Recommended Addition**:
```python
# In mean_revert.py or gold_scalper_strategy.py
def is_ranging_regime(closes: NDArray, period: int = 50) -> bool:
    """Check if market is in mean-reverting regime."""
    # Options:
    # 1. Hurst exponent < 0.5
    # 2. ADX < 25
    # 3. Price oscillating around SMA without directional bias
    pass
```

---

### MISSING-02: No Profit Target Logic in MeanRevert [P1-HIGH]

**Issue**: MR candidates specify `sl_distance` but have no explicit target logic. Mean reversion strategies typically target the mean (middle BB) or opposite band.

**Current**: Only SL is calculated:
```python
@dataclass(frozen=True, slots=True)
class MeanRevertCandidate:
    variant: MeanRevertVariant
    direction: TrendDirection
    score: float
    sl_distance: float  # Only SL
    reason: str
    meta: dict[str, Any]
```

**Missing**: `tp_distance` or `target_level` for proper R:R calculation.

**Impact**: Without explicit targets, the strategy relies on trade_manager's generic trailing logic, which may not suit mean reversion (MR should exit at mean, not trail).

---

### MISSING-03: No ATR Percentile Calculation [P2-MEDIUM]

**Issue**: `atr_percentile` is passed into `generate_mean_revert_candidates()` but must be calculated externally. The mean_revert module doesn't provide this calculation.

**Current API**:
```python
mean_candidates = generate_mean_revert_candidates(
    # ...
    atr_percentile=atr_pctl,  # Caller must compute this
)
```

**Recommendation**: Either:
1. Add `calculate_atr_percentile()` function to mean_revert.py
2. Document clearly how caller should compute it

---

### MISSING-04: No Multi-Timeframe Confirmation [P2-MEDIUM]

**Issue**: MR only looks at single timeframe. Best practice for mean reversion is to confirm with higher timeframe:
- H1 showing ranging regime
- M15/M5 showing BB+RSI extreme

**Current**: Single-timeframe analysis only.

---

## Recommended Fix Priority

| ID | Priority | Effort | Impact | Fix |
|----|----------|--------|--------|-----|
| BUG-01 | P0-CRITICAL | 10 min | Crash fix | Handle bool in state_changed |
| BUG-02 | P1-HIGH | 15 min | Debug clarity | Improve logging for SMC disabled |
| BUG-03 | P1-HIGH | 30 min | Debug clarity | Add diagnostic logging to MR |
| MISSING-01 | P1-HIGH | 2 hr | Edge improvement | Add regime filter |
| MISSING-02 | P1-HIGH | 1 hr | R:R improvement | Add TP calculation |
| DESIGN-01 | P1-HIGH | 1 hr | Maintainability | Use dataclasses for actions |
| SUBOPT-01 | P2-MEDIUM | 30 min | Signal frequency | Tiered thresholds |
| DESIGN-02 | P2-MEDIUM | 2 hr | Clean architecture | Separate signal sources |

---

## Next Steps for Round 02

1. **Fix BUG-01** immediately - this is blocking all trade management
2. **Add diagnostic logging** (BUG-02, BUG-03) to understand signal generation
3. **Implement regime filter** (MISSING-01) to prevent counter-trend MR
4. **Add TP calculation** (MISSING-02) for proper R:R

---

## Validation Checklist

- [ ] `mypy --strict nautilus_gold_scalper/src/` passes after fixes
- [ ] `pytest nautilus_gold_scalper/tests/` passes
- [ ] BUG-01 fix verified with unit test (state transition doesn't crash)
- [ ] MR backtest shows improved signal count
- [ ] MR backtest shows positive expectancy

---

**Report Generated**: 2025-12-24T[timestamp]
**FORGE-NAUTILUS v1.1**
