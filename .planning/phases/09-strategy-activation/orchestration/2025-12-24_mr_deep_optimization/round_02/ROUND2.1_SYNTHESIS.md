# Round 2.1 Synthesis: P0 Integration Fixes + Validation

**Date**: 2025-12-24
**Status**: COMPLETE
**Focus**: Fixing strategy integration issues discovered during backtest validation

---

## Issues Found During Validation

After Round 2 P0 fixes, initial backtest showed 5.7% win rate - WORSE than before.
Root cause: Strategy was not properly using the MR candidate's parameters.

### Issue 1: ATR Multipliers Not Passed to Generator (FIXED)

**File**: `gold_scalper_strategy.py` (lines 1611-1633)
**Problem**: Strategy called `generate_mean_revert_candidates()` without the new ATR multiplier params
**Fix**: Added all 6 new parameters to the call:

```python
mean_candidates = generate_mean_revert_candidates(
    # ... existing params ...
    # P0 FIX: ATR-based exits (calibrated for M1 timeframe)
    sl_atr_multiplier=float(getattr(self.config, "mean_revert_sl_atr_multiplier", 10.0)),
    tp_atr_multiplier=float(getattr(self.config, "mean_revert_tp_atr_multiplier", 8.0)),
    use_atr_exits=bool(getattr(self.config, "mean_revert_use_atr_exits", True)),
    # P0 FIX: ADX regime filter (block MR during strong trends)
    adx_period=int(getattr(self.config, "mean_revert_adx_period", 14)),
    max_adx=float(getattr(self.config, "mean_revert_max_adx", 25.0)),
    use_adx_filter=bool(getattr(self.config, "mean_revert_use_adx_filter", True)),
)
```

### Issue 2: TP Distance Override (CRITICAL - FIXED)

**File**: `gold_scalper_strategy.py` (lines 1939 and 1999)
**Problem**: Strategy ignored `selected_mean.tp_distance` and used `sl_distance * 2.5` for ALL trades
**Impact**: MR's BB-middle targeting was never used - trades had unrealistic 2.5:1 R:R targets

**Before (BROKEN)**:
```python
tp_distance = sl_distance * self.config.target_rr_ratio  # Always 2.5x SL
```

**After (FIXED)**:
```python
# P0 FIX: MR uses its own tp_distance (targets BB middle), not 2.5x SL
if selected_mean is not None:
    tp_distance = float(selected_mean.tp_distance)
else:
    tp_distance = sl_distance * self.config.target_rr_ratio
```

### Issue 3: Config Parameters Added (FIXED)

**File**: `gold_scalper_strategy.py` (lines 137-145)
**Change**: Added 6 new config params for MR ATR multipliers and ADX filter:

```python
# P0 FIX: ATR-based exit multipliers (calibrated for M1 timeframe)
mean_revert_sl_atr_multiplier: float = 10.0
mean_revert_tp_atr_multiplier: float = 8.0
mean_revert_use_atr_exits: bool = True
# P0 FIX: ADX regime filter
mean_revert_adx_period: int = 14
mean_revert_max_adx: float = 25.0
mean_revert_use_adx_filter: bool = True
```

---

## Validation Results

### 6-Month Backtest (2024-01-01 to 2024-06-01)

| Metric | Before P0 | After P0 Integration |
|--------|-----------|---------------------|
| Win Rate | 5.7% | **55.2%** |
| Trades | 88 | 58 |
| Total PnL | -$3,301 | -$1,086 |
| Avg PnL/trade | -$37.51 | -$18.72 |

### 2-Year Backtest (2023-01-01 to 2025-01-01)

| Metric | Value |
|--------|-------|
| Win Rate | 44.1% |
| Trades | 59 (W:26, L:33) |
| Total PnL | -$2,505.72 (-2.51%) |
| Avg PnL/trade | -$42.47 |
| Circuit Breaker Triggers | 12+ |

---

## Observations

1. **Win rate improved significantly** (5.7% → 44.1%) after fixes
2. **Strategy still unprofitable** - avg loss exceeds avg win
3. **Many circuit breaker DD breaches** - SL may still be too wide for session limits
4. **Fewer trades than expected** - ADX filter blocking many signals

---

## Remaining Issues (For Round 3-4)

### Issue A: Position Sizing vs SL Distance Mismatch
- SL = 10x M1 ATR = $8-15 per unit
- With position sizing based on risk %, large SL = smaller position
- But even small adverse moves trigger circuit breaker (session DD limit)
- **Consider**: Reduce SL multiplier from 10x to 5x, or use dynamic session-aware sizing

### Issue B: Win Rate Not High Enough for R:R
- With 44.1% win rate and TP << SL, expectancy is negative
- MR R:R is typically 0.8:1 (TP = 8x ATR, SL = 10x ATR)
- Need either: higher win rate (>55%) OR better R:R

### Issue C: ADX Filter May Be Too Restrictive
- Only 59 trades in 2 years (very low signal count)
- ADX threshold of 25 may block too many valid MR setups
- **Consider**: Test ADX thresholds 20, 25, 30, 35

---

## Next Steps (Round 3)

1. **Parameter optimization sweep**:
   - `sl_atr_multiplier`: 3.0, 5.0, 7.0, 10.0
   - `tp_atr_multiplier`: 5.0, 6.0, 7.0, 8.0
   - `max_adx`: 20, 25, 30, 35
   - `rsi_oversold/overbought`: 25/75, 30/70, 35/65

2. **Risk/sizing analysis**:
   - Calculate per-trade risk in session DD terms
   - Ensure no single trade can trigger circuit breaker

3. **Deeper MR viability analysis**:
   - Is gold mean-reverting at M1 timeframe?
   - Compare MR vs TF performance metrics

---

*Round 2.1 completed by ORCHESTRATOR*
