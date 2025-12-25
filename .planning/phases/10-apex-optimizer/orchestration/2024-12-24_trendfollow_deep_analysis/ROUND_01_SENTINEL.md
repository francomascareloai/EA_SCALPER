# SENTINEL ROUND 1: TrendFollow Risk Analysis

**Agent**: SENTINEL v3.2 - Apex Trading Guardian
**Date**: 2024-12-24
**Round**: 1 of 6
**Focus**: TrendFollow Strategy Risk Assessment for Apex Compliance
**Status**: COMPLETE

---

## 1. Executive Summary

- **CRITICAL FINDING**: The Hurst regime gate (H > 0.55) is NOW implemented and should prevent the -4% DD observed in Mar/Jun 2024, which occurred in choppy markets without this gate.
- **MEDIUM FINDING**: TrendFollow's sl_distance bypasses MIN/MAX clamping in `gold_scalper_strategy.py`, but position sizing formula limits actual $ loss regardless.
- **VERIFIED OK**: Time gates properly enforce Apex compliance (4:30 PM block new, 4:55 PM emergency close, 4:59 PM cutoff).
- **VERIFIED OK**: Position sizing has DD throttle (2%->75%, 3%->50%, 5%->25%) and 0.75% max risk cap.
- **VERIFIED OK**: DD protection tiers halt trading at 4.0% total DD (buffer before Apex's 5% termination).

---

## 2. Risk Analysis

### 2.1 SL Distance Calculation

**Location**: `src/signals/trend_follow.py`

**Pullback Variant** (lines 183-184):
```python
sl = max(0.0, last_close - (recent_low - tick_size))
```

**Breakout Variant** (lines 226-227):
```python
sl_level = prev_high - max(tick_size, float(max(0.0, atr)) * 0.25)
sl = max(0.0, last_close - sl_level)
```

**Issue**: Neither variant bounds sl_distance to `[MIN_SL_DISTANCE=15.0, MAX_SL_DISTANCE=50.0]`. The only guard is `sl > tick_size` (0.01), which is far below the MIN_SL_DISTANCE.

**Strategy Integration Bug** (lines 1807, 1873-1874 in `gold_scalper_strategy.py`):
```python
sl_distance = float(selected_trend.sl_distance)  # Direct use, no clamping
# ...
if sl_distance <= 0.0:  # Clamping only when sl_distance is zero!
    sl_distance = self._calculate_sl_distance(bar, signal)
```

**Risk Assessment**: MEDIUM (not CRITICAL)
- Position sizing formula: `lot = (balance * risk%) / (sl_pips * pip_value)`
- Even with unbounded SL, the lot size adjusts proportionally
- MAX_LOT (100) and MIN_LOT (0.01) provide additional guardrails
- Real impact: strategy efficiency (tiny SL = frequent stops; large SL = tiny positions)

### 2.2 Position Sizing

**Location**: `src/risk/position_sizer.py`

**Safeguards Verified**:
| Mechanism | Value | Status |
|-----------|-------|--------|
| Max Risk Per Trade | 0.75% | OK |
| Default Risk Per Trade | 0.5% | OK |
| Lot Normalization | floor() not round() | OK |
| Final Safety Check | lines 215-226 | OK |

**DD Throttle** (lines 281-304):
| Drawdown | Risk Multiplier |
|----------|-----------------|
| >= 5% (dd_hard) | 0.25x (75% cut) |
| >= 3% (dd_soft) | 0.50x (50% cut) |
| >= 2% | 0.75x (25% cut) |

### 2.3 Maximum Loss Scenarios

**Single Trade Maximum Loss**:
- With 0.5% risk and $50k account: $250 max loss per trade
- Position sizing formula guarantees this regardless of SL distance
- Final safety check (lines 215-226) re-verifies before order

**Daily Maximum Loss**:
- Daily DD 3.0% triggers EMERGENCY_HALT
- $50k account: $1,500 max daily loss before halt
- Number of trades to reach: 6 trades at 0.5% risk each (worst case)

**Weekly Maximum Loss**:
- Total DD 4.0% triggers HALT_ALL (buffer before Apex's 5%)
- $50k account: $2,000 max total DD before halt
- 1% buffer to Apex termination provides 1 trading day recovery window

---

## 3. Apex Compliance Assessment

| Requirement | Implementation | Status |
|-------------|----------------|--------|
| 5% Trailing DD Limit | 4.0% HALT_ALL threshold provides buffer | OK |
| No Overnight Positions | 4:59 PM ET force close | OK |
| Time Gate: Block New | 4:30 PM ET via `can_open_new()` | OK |
| Time Gate: Emergency Close | 4:55 PM ET via `_force_close_all()` | OK |
| HWM Includes Unrealized | Needs verification in live code | VERIFY |
| SL Distance Bounds | TrendFollow bypasses clamping | WARN |
| Regime Gating | Hurst > 0.55 now implemented | OK |

### 3.1 Time Constraint Manager Deep Dive

**Location**: `src/risk/time_constraint_manager.py`

**Time Gates**:
| Gate | Time (ET) | Action |
|------|-----------|--------|
| Warning | 4:00 PM | Log warning |
| Urgent | 4:30 PM | Block new trades |
| Emergency | 4:55 PM | Force close all |
| Cutoff | 4:59 PM | Absolute force close |

**BUG-13 Fix Verified**: Close order tracking prevents spamming (line 52-53):
```python
self._close_orders_submitted: bool = False
self._close_submitted_ts_ns: int | None = None
```

---

## 4. Drawdown Scenarios

### Scenario 1: Death by 1000 Cuts (HISTORICAL - FIXED)

**What Happened** (Mar/Jun 2024):
- TrendFollow signals generated in choppy/ranging markets (H < 0.55)
- Many small losing trades accumulated to -4% trailing DD
- No Hurst regime gate to filter signals

**Current Status**: MITIGATED
- Hurst regime gate now active (lines 133-138 in `trend_follow.py`)
- Returns empty list when `hurst < min_hurst` (default 0.55)
- Trending regime requirement should prevent choppy market signals

### Scenario 2: Single Large Adverse Move

**Risk Profile**:
- Position sizing limits single trade loss to 0.5-0.75% of equity
- Even with unbounded SL, lot size adjusts proportionally
- DD throttle reduces size further if already in drawdown

**Worst Case**: 6 consecutive losing trades at 0.5% each = 3% DD (HALT triggered)

### Scenario 3: Rapid Market Gap

**Risk Profile**:
- Apex allows futures trading; gaps possible at open
- SL may not execute at exact price
- Slippage could exceed expected SL distance

**Mitigation**:
- Broker-side SL (if configured) provides backstop
- Position sizing limits exposure even with slippage
- 4.0% HALT provides 1% buffer before Apex termination

---

## 5. Risk Mitigation Proposals

### FIX 1: SL Distance Clamping (RECOMMENDED)

**Priority**: MEDIUM
**Location**: `src/signals/trend_follow.py`, lines 184 and 227

**Current**:
```python
sl = max(0.0, last_close - (recent_low - tick_size))
```

**Proposed**:
```python
from ..core.definitions import MIN_SL_DISTANCE, MAX_SL_DISTANCE

raw_sl = max(0.0, last_close - (recent_low - tick_size))
sl = max(MIN_SL_DISTANCE, min(raw_sl, MAX_SL_DISTANCE))
```

**Rationale**: Ensures strategy efficiency and predictable SL distances. Not a safety blocker due to position sizing formula.

### FIX 2: Strategy-Level SL Validation (LOW)

**Priority**: LOW
**Location**: `src/strategies/gold_scalper_strategy.py`, after line 1807

**Proposed**:
```python
sl_distance = float(selected_trend.sl_distance)
# Belt-and-suspenders: clamp regardless of source
sl_distance = max(MIN_SL_DISTANCE, min(sl_distance, MAX_SL_DISTANCE))
```

### FIX 3: Telemetry Enhancement (LOW)

**Priority**: LOW
**Action**: Add logging for TrendFollow sl_distance distribution to identify edge cases

---

## 6. Questions for Next Round

1. **Hurst Gate Validation**: What is the backtest performance BEFORE vs AFTER Hurst gate implementation? Does the -4% DD disappear with H > 0.55 filter?

2. **SL Distance Distribution**: What is the historical distribution of sl_distance values from TrendFollow signals? Are there outliers that exceed MAX_SL_DISTANCE?

3. **HWM Calculation Verification**: Does the live code use bid price for LONG unrealized and ask price for SHORT unrealized as required by CLAUDE.md price_basis rule?

4. **Hurst Calculation Latency**: What is the computational cost of Hurst exponent calculation? Does it fit within the 50ms OnTick budget?

5. **Regime Transition Handling**: What happens when Hurst crosses 0.55 mid-trade? Are existing positions affected or only new signals filtered?

---

## 7. GO/NO-GO Verdict

### Preliminary Verdict: CONDITIONAL GO

**Reasoning**:

1. **Root Cause Addressed**: The -4% trailing DD was caused by TrendFollow signals in choppy markets. The Hurst regime gate (H > 0.55) is now implemented and should prevent this pattern.

2. **Safety Mechanisms Verified**: Time gates, position sizing, DD throttle, and HALT thresholds are all properly implemented with appropriate buffers.

3. **SL Clamping is Quality, Not Safety**: The unbounded SL issue affects strategy efficiency but not catastrophic risk, because position sizing formula adjusts lot size proportionally.

4. **Remaining Verification Needed**:
   - Backtest with Hurst gate to confirm -4% DD elimination
   - HWM calculation with bid/ask prices for unrealized

### Conditions for Full GO:

| Condition | Owner | Priority |
|-----------|-------|----------|
| Backtest TrendFollow with Hurst gate, verify DD < 3% | ORACLE | HIGH |
| Verify HWM uses bid/ask for unrealized PnL | FORGE/REVIEWER | HIGH |
| Implement SL clamping in trend_follow.py | FORGE | MEDIUM |
| Add SL distance telemetry | FORGE | LOW |

### Blocking Conditions (would change to NO-GO):

- If Hurst gate backtest still shows > 3% trailing DD
- If HWM calculation does NOT include unrealized PnL
- If position sizing formula has implementation bugs

---

## Appendix: Files Analyzed

| File | Purpose | Lines Reviewed |
|------|---------|----------------|
| `src/signals/trend_follow.py` | Signal generation | Full (268 lines) |
| `src/strategies/gold_scalper_strategy.py` | Strategy integration | 1806-1874, 2339-2402 |
| `src/risk/position_sizer.py` | Position sizing | Full (443 lines) |
| `src/risk/time_constraint_manager.py` | Time gates | Full (307 lines) |
| `src/risk/dd_protection.py` | DD protection tiers | Full |
| `src/core/definitions.py` | Constants | Full (286 lines) |

---

*SENTINEL v3.2 - "Trailing DD does not forgive. The clock does not wait."*
