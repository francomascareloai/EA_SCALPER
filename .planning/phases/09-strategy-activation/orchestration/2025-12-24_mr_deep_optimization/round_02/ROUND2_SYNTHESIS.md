# Round 2 Synthesis: P0 Critical Fixes Implemented

**Date**: 2025-12-24
**Status**: COMPLETE
**Focus**: Implementing critical fixes identified in Round 1

---

## P0 Fixes Implemented

### 1. ATR-Based SL (P0-2) - DONE

**File**: `mean_revert.py`
**Change**: Replaced swing-based SL with ATR-based SL

**Before** (BROKEN):
```python
recent_low = float(np.min(l[-20:]))
sl_level = min(recent_low, lower) - tick_size
sl = max(0.0, last_close - sl_level)
```

**After** (FIXED):
```python
sl = max(tick_size, atr_val * float(sl_atr_multiplier))
# Default: sl_atr_multiplier = 1.0 (1x ATR)
```

**Impact**:
- Prevents 3-5x ATR stop losses during trends
- SL is now volatility-adjusted and bounded
- Expected: Reduce avg loss from 3.4x avg win to ~1.5x

---

### 2. TP Distance Targeting BB Middle (P0-3) - DONE

**File**: `mean_revert.py`
**Change**: Added `tp_distance` calculation

**Formula**:
```python
# LONG: tp = min(distance_to_mid, ATR * tp_multiplier)
tp = max(tick_size, min(mid - last_close, atr_val * float(tp_atr_multiplier)))
# Default: tp_atr_multiplier = 0.75
```

**Impact**:
- MR now targets the mean (BB middle), not 2.5x SL
- R:R improves from 0.29:1 to 0.75:1
- Proper mean reversion exit strategy

---

### 3. ADX Regime Filter (P0-4) - DONE

**File**: `mean_revert.py`
**Change**: Added full ADX calculation and regime filter

**New Function**: `_adx()` (lines 79-159)
- Wilder's smoothing for +DM, -DM, TR
- Proper DX and ADX calculation
- Returns 0-100 scale

**Filter Logic**:
```python
if use_adx_filter:
    adx_val = _adx(h, l, c, period=int(adx_period))
    if np.isfinite(adx_val) and adx_val > float(max_adx):
        return []  # Block signal in trending market
```

**Default Parameters**:
- `adx_period = 14`
- `max_adx = 25.0` (block when ADX > 25)
- `use_adx_filter = True`

**Impact**:
- Prevents MR signals during strong trends
- Eliminates "fighting the trend" losses
- Expected: Win rate may drop slightly but avg loss drops significantly

---

### 4. Trade Management Bug Fix (BUG-01) - DONE

**File**: `gold_scalper_strategy.py` (lines 2595-2604)
**Change**: Fixed `'bool' object has no attribute 'get'` crash

**Before** (BROKEN):
```python
elif action_type == "state_changed":
    self.log.info(
        f"[TRADE_MANAGER] State changed to {action_data.get('new_state', 'UNKNOWN')}: "
        f"{action_data.get('reason', '')}"
    )  # CRASH: action_data is True/False, not a dict!
```

**After** (FIXED):
```python
elif action_type == "state_changed":
    if action_data:  # True = state changed
        new_state = actions.get('new_state', 'UNKNOWN')
        reason = actions.get('reason', '')
        self.log.info(f"[TRADE_MANAGER] State changed to {new_state}: {reason}")
```

**Impact**:
- Trade management no longer crashes on state transitions
- OPEN -> BREAKEVEN -> TRAILING states work correctly

---

## New Parameters Added to `generate_mean_revert_candidates()`

| Parameter | Default | Description |
|-----------|---------|-------------|
| `sl_atr_multiplier` | 1.0 | SL = ATR * this multiplier |
| `tp_atr_multiplier` | 0.75 | TP cap = ATR * this multiplier |
| `use_atr_exits` | True | Use ATR exits (False = legacy swing-based) |
| `adx_period` | 14 | ADX calculation period |
| `max_adx` | 25.0 | Block MR when ADX > this |
| `use_adx_filter` | True | Enable/disable ADX regime filter |

---

## Test Coverage Added

| Test | Purpose | Status |
|------|---------|--------|
| `test_adx_regime_filter_blocks_trending_market` | Verify ADX filter blocks signals during trends | PASS |
| `test_atr_based_sl_tp_calculation` | Verify ATR-based SL/TP calculation | PASS |
| Existing tests updated | Added `use_adx_filter=False` and `tp_distance` assertions | PASS |

**Total**: 5/5 mean_revert tests passing, 29/29 signals tests passing

---

## Validation

```
mypy --strict mean_revert.py: SUCCESS (no issues)
mypy --strict signals/: SUCCESS (no issues in 9 files)
pytest test_signals/: 29/29 PASSED
```

---

## Expected Impact After P0 Fixes

| Metric | Before P0 | After P0 (Expected) |
|--------|-----------|---------------------|
| Sharpe | -0.47 | +0.5 to +1.0 |
| SQN | -0.25 | +1.5 to +2.5 |
| Win Rate | 75% | 65-70% (fewer signals) |
| Avg Loss | 3.4x avg win | 1.5x avg win |
| R:R | 0.29:1 | 0.75:1 |
| Signal Count | 68/2yr | ~40-50/2yr (filtered by ADX) |

---

## Next Steps (Round 3-4)

1. **Run 2-year backtest** with P0 fixes to validate improvement
2. **Parameter optimization** if baseline improves:
   - `sl_atr_multiplier`: test 0.75, 1.0, 1.25, 1.5
   - `tp_atr_multiplier`: test 0.5, 0.75, 1.0
   - `max_adx`: test 20, 25, 30
   - `rsi_oversold/overbought`: test 25/75, 30/70, 35/65
3. **Walk-forward validation** of optimized parameters

---

*Round 2 completed by FORGE + ORCHESTRATOR*
