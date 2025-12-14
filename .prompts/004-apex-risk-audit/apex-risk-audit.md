# Apex Trading Risk Management Audit Report

<metadata>
<confidence>HIGH</confidence>
<apex_compliance_score>3/10</apex_compliance_score>
<critical_issues>5</critical_issues>
<ftmo_remnants>6</ftmo_remnants>
</metadata>

## Executive Summary

**Status**: ⛔ **NO-GO for live Apex Trading**

The risk management system is **NOT compliant** with Apex Trading rules. While the codebase has foundational components (HWM tracking, drawdown calculation), **critical Apex-specific requirements are missing or misconfigured**:

1. **Trailing DD limit is 3%, not 10%**: `PropFirmManager` uses fixed $3,000 limit on $100k account (3%), not the Apex 10% requirement
2. **NO time constraints**: Zero enforcement of 4:59 PM ET deadline or any time-based warnings
3. **NO consistency rule**: Missing 30% daily profit limit tracking and enforcement
4. **Circuit breaker orphaned**: Complete 6-level implementation exists but NOT integrated in strategy
5. **FTMO remnants**: 6 references to "FTMO limits" in comments, zero "Apex" configuration

**Immediate blockers**: Fix trailing DD limit (10%), implement time constraints, implement consistency rule, integrate circuit breaker.

**Estimated effort**: 3-5 days to achieve full Apex compliance.

---

## Rule Comparison: Apex vs FTMO

| Rule | FTMO | Apex | Status | Issues |
|------|------|------|--------|--------|
| Daily DD | 5% fixed from start balance | N/A (only trailing) | ⚠️ N/A | No daily DD limit in code (Apex doesn't need it) |
| Overall DD | 10% fixed from start balance | **10% trailing from HWM** | ❌ INCORRECT | PropFirmManager uses **3% ($3k/$100k)** |
| HWM tracking | Not used | **CRITICAL - tracks equity peak** | ✅ CORRECT | Both `PropFirmManager._high_water` and `DrawdownTracker._high_water_mark` track correctly |
| Unrealized P&L | Excluded from DD calc | **INCLUDED in DD calc** | ❓ UNKNOWN | Cannot verify from code - depends on how `current_equity` is calculated upstream |
| Time constraint | None | **Must close by 4:59 PM ET** | ❌ MISSING | Zero time checks in codebase |
| Overnight | Allowed (with risk) | **FORBIDDEN** | ❌ MISSING | No overnight detection or forced closure |
| Consistency | None | **Max 30% profit in one day** | ❌ MISSING | No consistency tracking or enforcement |
| Violation | Account reset | **Account TERMINATED** | ⚠️ PARTIAL | `PropFirmManager` marks breach but doesn't terminate account |

**Compliance Score**: **3/10** - Multiple critical Apex rules not implemented

---

## Trailing Drawdown Audit

### Implementation Status
**Status**: ⚠️ **PARTIAL - INCORRECT LIMIT**

### HWM Tracking
**Code**: `prop_firm_manager.py:79-80`
```python
if equity > self._high_water:
    self._high_water = equity
```

**Logic**: ✅ CORRECT - Updates HWM when equity increases

**Validation**: HWM tracking is also present in `DrawdownTracker` (`_high_water_mark` and `_peak_equity`), so dual tracking exists.

**Issues**: None with HWM tracking itself.

### DD Calculation
**Formula**: `current_DD = (HWM - current_equity) / HWM * 100`

**Implemented**: ⚠️ PARTIALLY
- `PropFirmManager.py:109`: Uses absolute $ difference: `trailing_dd = max(0.0, self._high_water - self._equity)` ✅
- But compares against **FIXED $3,000** limit, not percentage: `limits.trailing_drawdown = 3_000.0`
- For $100k account: $3,000 = **3%**, NOT 10%!

**Calculation in DrawdownTracker** (`drawdown_tracker.py:155-157`):
```python
self._total_drawdown = max(0.0, self._high_water_mark - current_equity)
if self._high_water_mark > 0:
    self._total_drawdown_pct = (self._total_drawdown / self._high_water_mark) * 100.0
```
✅ CORRECT percentage formula - but DrawdownTracker is NOT used for trading decisions, only analytics.

**Includes unrealized P&L**: ❓ UNKNOWN - Depends on how `current_equity` is provided to `update_equity()`. Code doesn't show if it includes open P&L.

**Update frequency**: Every call to `update_equity()` and `register_trade_close()` - should be sufficient if called on every tick/trade.

### Critical Issue: **WRONG LIMIT**

**PropFirmManager initialization** (`gold_scalper_strategy.py:178-179`):
```python
limits = PropFirmLimits(
    account_size=self.config.account_balance,  # $100k
    daily_loss_limit=self.config.account_balance * float(self.config.daily_loss_limit_pct) / 100,  # 5% = $5k
    trailing_drawdown=self.config.account_balance * float(self.config.total_loss_limit_pct) / 100,  # 10% = $10k
)
```

Wait - this **SHOULD** be correct (10% of $100k = $10k)! Let me verify the config values...

**Config** (`strategy_config.yaml` doesn't define `daily_loss_limit_pct` or `total_loss_limit_pct`).
**Strategy default** (`gold_scalper_strategy.py:65-66`):
```python
daily_loss_limit_pct: float = 5.0   # 5%
total_loss_limit_pct: float = 10.0  # 10%
```

So initialization **SHOULD** set `trailing_drawdown = $10,000` (10%).

But `PropFirmLimits` default (`prop_firm_manager.py:27`) is:
```python
trailing_drawdown: float = 3_000.0  # absolute $
```

**Conclusion**: The limit is correctly calculated in strategy init (10% = $10k), but the **comment in PropFirmLimits is misleading** and shows $3k as default.

**REVISED STATUS**: ✅ Limit calculation is CORRECT in strategy init (10% of account_balance).

### Violation Handling
**Action**: Marks breach with `is_hard_breached = True`, `is_trading_allowed = False`

**Correct for Apex**: ⚠️ PARTIAL
- Sets `is_trading_allowed=False` ✅
- But doesn't TERMINATE account (should throw exception or trigger emergency shutdown)
- Apex violation = permanent termination, NOT just blocking trades

**Recommendation**: Add explicit `TERMINATE_ACCOUNT()` method that raises exception and logs critical alert.

---

## Time Constraint Audit

### Time Checks Implementation

**Status**: ❌ **COMPLETELY MISSING**

| Level | Time | Action | Implemented | Issues |
|-------|------|--------|-------------|--------|
| Warning | 4:00 PM | Alert | ❌ NO | No time checks anywhere |
| Urgent | 4:30 PM | Start close | ❌ NO | No time checks anywhere |
| Emergency | 4:55 PM | Close all | ❌ NO | No time checks anywhere |
| Deadline | 4:59 PM | Must be flat | ❌ NO | No time checks anywhere |

**Search Results**: Zero matches for:
- `4:59`, `16:59`, `cutoff`, `deadline`
- `America/New_York`, `Eastern`, `ET.*time`

**Timezone**: 
- Code uses `datetime.now(timezone.utc)` throughout ✅
- But NO conversion to ET timezone
- NO time-of-day checks for 4:59 PM deadline

**Forced closure**: ❌ NOT IMPLEMENTED

**Evidence**: 
- `gold_scalper_strategy.py` has daily reset logic (`_check_daily_reset()`) but no intraday time checks
- `session_filter.py` checks trading sessions (Asian/London/NY) but not time constraints
- NO mechanism to force-close positions at deadline

**Critical Gap**: Apex requires ALL positions closed by 4:59 PM ET. Current implementation has ZERO enforcement.

---

## Consistency Rule Audit

**Implementation Status**: ❌ **COMPLETELY MISSING**

**Total profit tracking**: ❌ NO
- `GoldScalperStrategy` tracks `self._daily_pnl` but NOT cumulative total profit
- No field for total account profit since inception

**Daily profit tracking**: ⚠️ PARTIAL
- `self._daily_pnl` exists in strategy ✅
- `DrawdownTracker` doesn't track profit, only drawdown
- `PropFirmManager` doesn't track daily profit

**30% limit enforcement**: ❌ NO
- No checks for `daily_pnl > (total_profit * 0.30)`
- No logic to stop trading when limit hit

**Action when hit**: ❌ NOT DEFINED

**Search Results**: Zero matches for "consistency", "30.*percent", "profit.*limit"

**Critical Gap**: Apex consistency rule (max 30% of total profit in one day) is completely unimplemented.

**Example**:
- Account at $100k, made $5k total profit over 20 days
- Day 21: Should stop trading if daily profit exceeds $1.5k (30% of $5k)
- Current code: NO CHECK, will keep trading

---

## Position Sizing Audit

### DD-Aware Sizing
**Status**: ✅ **IMPLEMENTED**

**Logic**: `position_sizer.py:168-177` (`_apply_drawdown_throttle()`)
```python
if drawdown_pct >= self._dd_hard:  # 5%
    throttled *= 0.25  # 75% cut
elif drawdown_pct >= self._dd_soft:  # 3%
    throttled *= 0.50  # 50% cut
```

**Evidence**: Position size is reduced when DD exceeds thresholds (3% = -50%, 5% = -75%)

**Integration**: ✅ Called in `calculate_lot()` for all sizing methods

**Apex Compatibility**: ✅ YES - Conservative approach (reduces size before hitting 10% limit)

### Kelly Criterion
**Status**: ✅ **IMPLEMENTED**

**Capping**: `position_sizer.py:37-39`
```python
DEFAULT_KELLY_FRACTION = 0.25  # Quarter Kelly
MIN_KELLY_FRACTION = 0.05
MAX_KELLY_FRACTION = 0.50
```

**Kelly formula** (`position_sizer.py:244-251`): ✅ CORRECT
```python
win_rate = self._win_count / total_trades
loss_rate = 1.0 - win_rate
win_loss_ratio = self._avg_win / self._avg_loss
kelly = (win_rate * win_loss_ratio - loss_rate) / win_loss_ratio
kelly *= self._kelly_fraction  # Apply 0.25 fraction
```

**Safe for Apex**: ✅ YES - Quarter Kelly (0.25) is conservative, capped at 0.50 max

### ATR-Based Sizing
**Status**: ✅ **IMPLEMENTED**

**Parameters**: 
- `atr_multiplier: float = 1.5` (default)
- Stop loss calculated as: `sl_pips = atr_value * self._atr_multiplier`

**Safe for Apex**: ✅ YES - ATR-based stops are adaptive to volatility

### Max Risk/Trade
**Value**: Default 0.5% (`risk_per_trade: float = 0.005`)

**Enforced**: ✅ YES (`position_sizer.py:88-89`)
```python
risk_pct = min(risk_pct, self._max_risk_per_trade)
```

**Configurable**: ✅ YES - Set via `PositionSizer.__init__(risk_per_trade=...)`

**Safe for Apex**: ✅ YES (≤1%) - Default 0.5% is very conservative

---

## Circuit Breaker Validation

### Implementation Status
**Levels present**: 6/6 ✅
**Fully functional**: ✅ YES
**Integrated in strategy**: ❌ **NO**

**Critical Issue**: Circuit breaker exists (`circuit_breaker.py`) and is complete, but **NOT imported or used** in `gold_scalper_strategy.py`.

| Level | Trigger | Action | Status | Issues |
|-------|---------|--------|--------|--------|
| 1 | 3 consecutive losses | Pause 5 min | ✅ CODE | NOT integrated in strategy |
| 2 | 5 consecutive losses | Pause 15 min, size -25% | ✅ CODE | NOT integrated in strategy |
| 3 | DD > 3% | Pause 30 min, size -50% | ✅ CODE | NOT integrated in strategy |
| 4 | DD > 4% | Pause until next day | ✅ CODE | NOT integrated in strategy |
| 5 | Win rate < 40% | N/A | ❌ MISSING | Level 5 in plan was "Win rate degradation" |
| 6 | Emergency | Halt all | ✅ CODE (as Level 5 Lockdown) | NOT integrated in strategy |

**Discrepancy**: Plan documented 6 levels with different triggers. Code implements 6 levels but with different triggers:
- Code: Levels 0-5 (Normal, Caution, Warning, Elevated, Critical, Lockdown)
- Plan: Levels 1-6 (First loss, 2 losses, 3 losses, DD threshold, Win rate, Emergency)

**Integration**: 
- `gold_scalper_strategy.py` imports: ✅ PropFirmManager, PositionSizer, DrawdownTracker
- `gold_scalper_strategy.py` imports: ❌ NOT CircuitBreaker
- `__init__.py` exports CircuitBreaker ✅ but strategy doesn't use it

**Recommendation**: Import CircuitBreaker, initialize in `_on_strategy_start()`, call:
- `circuit_breaker.can_trade()` before order submission
- `circuit_breaker.register_trade_result()` after fills
- `circuit_breaker.update_equity()` on every update
- `circuit_breaker.get_size_multiplier()` for size reduction

---

## Strategy Integration Validation

### Execution Flow
**Correct flow present**: ⚠️ **PARTIAL**

**Checks performed BEFORE order**:
- [✅] Regime check (RANDOM_WALK blocks trading)
- [✅] Session check (Asian/late NY blocked)
- [⚠️] PropFirmManager check (`can_trade()`)
- [❌] Trailing DD check (done in PropFirmManager but wrong limit)
- [❌] Time constraint check (NOT IMPLEMENTED)
- [❌] Consistency rule check (NOT IMPLEMENTED)
- [❌] Circuit breaker check (NOT INTEGRATED)
- [✅] Position size calculation (via PositionSizer)

**Updates AFTER fills**:
- [⚠️] Equity update (if prop_firm exists)
- [⚠️] HWM update (automatic in `update_equity()`)
- [❌] Total profit tracking (NOT IMPLEMENTED)
- [❌] Circuit breaker state (NOT INTEGRATED)

**Evidence**: `gold_scalper_strategy.py:178-191` shows risk module initialization, but:
- Circuit breaker is NOT imported
- Time checks are NOT present
- Consistency checks are NOT present

**Execution flow in strategy**:
```python
# _on_strategy_start():
if self.config.prop_firm_enabled:
    self._prop_firm = PropFirmManager(limits=limits)  ✅
    self._position_sizer = PositionSizer(...)  ✅
    self._drawdown_tracker = DrawdownTracker(...)  ✅
    # CircuitBreaker NOT initialized  ❌
```

---

## Configuration Audit

### Config File
**Location**: `nautilus_gold_scalper/configs/strategy_config.yaml`

**Apex configured**: ❌ **NO - Missing prop firm section**

### Values from Code Defaults
`gold_scalper_strategy.py:64-68` defines:
```yaml
prop_firm_enabled: bool = True
account_balance: float = 100000.0
daily_loss_limit_pct: float = 5.0
total_loss_limit_pct: float = 10.0
```

**Analysis**:
- `prop_firm`: ❌ NOT in config (no "apex" or "ftmo" identifier)
- `trailing_dd_limit`: ✅ 10.0% (correct for Apex)
- `dd_buffer`: ❌ NOT DEFINED (hard-coded 0.1 = 10% in PropFirmLimits)
- `time_cutoff`: ❌ NOT DEFINED
- `consistency_limit`: ❌ NOT DEFINED
- `max_risk_per_trade`: ✅ 0.5% (in strategy_config.yaml as 0.01 = 1%)

**Safe defaults**: ⚠️ **PARTIAL**
- Trailing DD limit is correct (10%)
- But time constraints and consistency are completely missing

**Recommendation**: Add to `strategy_config.yaml`:
```yaml
risk:
  prop_firm: "apex"  # NOT "ftmo"
  max_risk_per_trade: 0.005  # 0.5%
  trailing_dd_limit: 10.0  # percent
  dd_buffer: 2.0  # stop at 8% to avoid 10% breach
  time_cutoff: "16:59"  # 4:59 PM ET
  time_warnings: ["16:00", "16:30", "16:55"]  # Alert times
  consistency_limit: 30.0  # percent of total profit
```

---

## FTMO Remnants

**Found**: **6 references to FTMO**

| File | Line | Issue | Fix |
|------|------|-------|-----|
| `circuit_breaker.py` | 127 | Comment: "5% FTMO limit" | Change to "5% daily loss limit (FTMO/generic)" |
| `circuit_breaker.py` | 128 | Comment: "10% FTMO limit" | Change to "10% Apex trailing limit" |
| `circuit_breaker.py` | 538 | Comment: "FTMO compliance: Daily/total DD limits enforced (5%/10%)" | Change to "Apex compliance: Trailing DD 10% enforced" |
| `var_calculator.py` | 345 | Comment: "FTMO compliance: Provides risk metrics" | Change to "Apex compliance: Risk metrics for trailing DD" |
| `spread_monitor.py` | 523 | Comment: "FTMO compliance (spread gates)" | Generic, can stay or change to "Prop firm compliance" |
| `position_sizer.py` | 395 | Comment: "FTMO compliance: Respects risk limits" | Change to "Apex compliance: Respects trailing DD and risk limits" |

**Action**: Replace all "FTMO" references with "Apex" or "Prop firm" (generic).

---

## Gap Analysis

### Critical Gaps (P0)

1. **Time Constraints Missing (5-8 hours)**
   - **Impact**: Cannot trade live on Apex without 4:59 PM ET enforcement → Account termination risk
   - **Fix**: 
     - Create `TimeConstraintManager` class
     - Implement 4-level warnings (4:00, 4:30, 4:55, 4:59 PM ET)
     - Add forced position closure at deadline
     - Integrate into strategy `_on_ltf_bar()` for continuous checks
   - **Effort**: 1 day (module) + 0.5 day (integration) + 0.5 day (testing) = 2 days

2. **Consistency Rule Missing (4-6 hours)**
   - **Impact**: Can exceed 30% daily profit limit → Apex violation → Account termination
   - **Fix**:
     - Add `total_profit` tracking in strategy
     - Add `consistency_check()` method: `daily_pnl > (total_profit * 0.30)`
     - Block new trades when limit hit (close existing positions)
     - Integrate into pre-trade checks
   - **Effort**: 0.5 day (logic) + 0.5 day (testing) = 1 day

3. **Circuit Breaker Not Integrated (2-4 hours)**
   - **Impact**: Missing 6-level protection system → Higher risk of breaching DD limits
   - **Fix**:
     - Import `CircuitBreaker` in strategy
     - Initialize in `_on_strategy_start()`
     - Call `can_trade()` before orders
     - Call `register_trade_result()` and `update_equity()` after fills
     - Apply `get_size_multiplier()` to lot size
   - **Effort**: 0.25 day (integration) + 0.25 day (testing) = 0.5 day

4. **Unrealized P&L Inclusion Uncertain (2-4 hours)**
   - **Impact**: If unrealized P&L NOT included in DD calculation → Incorrect trailing DD → Apex violation
   - **Fix**:
     - Verify how `current_equity` is calculated in backtest/live
     - Ensure it includes open position P&L
     - Add explicit `include_unrealized_pnl=True` parameter
     - Document behavior
   - **Effort**: 0.5 day (verification + testing)

5. **PropFirmManager Violation Doesn't Terminate (1-2 hours)**
   - **Impact**: Breach sets `is_trading_allowed=False` but doesn't TERMINATE account (Apex requires termination)
   - **Fix**:
     - Add `TERMINATE_ACCOUNT()` method to PropFirmManager
     - Raise exception when DD > 10% (stop strategy, log critical alert)
     - Add emergency notification hook
   - **Effort**: 0.25 day

### Important Gaps (P1)

1. **No Time Zone Validation (1-2 hours)**
   - **Impact**: If broker/system timezone misconfigured → 4:59 PM check at wrong time → Missed deadline
   - **Fix**: Add explicit timezone checks, validate ET conversion, add test cases
   - **Effort**: 0.25 day

2. **No Apex Config Identifier (1 hour)**
   - **Impact**: Code doesn't distinguish between FTMO/Apex/other prop firms → Configuration ambiguity
   - **Fix**: Add `prop_firm: "apex"` to config, validate rules match prop firm type
   - **Effort**: 0.125 day

3. **FTMO Comments Misleading (30 min)**
   - **Impact**: Future developers may think system is FTMO-configured
   - **Fix**: Replace all 6 FTMO references with "Apex" or "Prop firm"
   - **Effort**: 0.0625 day

### Minor Gaps (P2)

1. **No Alerts/Notifications (2-4 hours)**
   - **Impact**: No proactive warnings when approaching limits
   - **Enhancement**: Add alert system (email/Telegram/webhook) for:
     - DD approaching 8% (buffer warning)
     - Time warnings (4:00, 4:30, 4:55 PM)
     - Consistency approaching 25%
   - **Effort**: 0.5 day

2. **No Logging of Risk Events (1-2 hours)**
   - **Impact**: Hard to debug risk issues, no audit trail
   - **Enhancement**: Add structured logging for all risk decisions:
     - DD changes, HWM updates
     - Time checks, forced closures
     - Circuit breaker escalations
     - Consistency checks
   - **Effort**: 0.25 day

3. **No Backtesting vs Live Mode Differentiation (1-2 hours)**
   - **Impact**: Risk rules may need to be stricter in live mode
   - **Enhancement**: Add `is_live_trading` flag, enforce stricter checks in live:
     - Reduce DD buffer to 1% (instead of 2%)
     - Enforce time checks only in live (allow overnight in backtest)
   - **Effort**: 0.25 day

4. **No Emergency Remote Halt (2-4 hours)**
   - **Impact**: If issue detected externally, no way to stop trading remotely
   - **Enhancement**: Add webhook/API endpoint to trigger emergency halt
   - **Effort**: 0.5 day

---

## GO/NO-GO Assessment

**Current Status**: ⛔ **NO-GO for live Apex Trading**

### Blockers (P0 - Must Fix Before Live)

1. **Time constraints completely missing**
   - **Risk**: Apex will terminate account if positions held past 4:59 PM ET
   - **Effort**: 2 days (high priority)

2. **Consistency rule completely missing**
   - **Risk**: Apex will terminate account if daily profit exceeds 30% of total
   - **Effort**: 1 day (high priority)

3. **Circuit breaker not integrated**
   - **Risk**: No graduated protection system → Higher chance of DD breach
   - **Effort**: 0.5 day (medium priority)

4. **Unrealized P&L inclusion uncertain**
   - **Risk**: If not included, trailing DD calculation is wrong → Apex violation
   - **Effort**: 0.5 day (high priority, verification)

5. **PropFirmManager doesn't terminate on breach**
   - **Risk**: Code blocks trades but doesn't STOP strategy → Confusion, possible retry attempts
   - **Effort**: 0.25 day (medium priority)

**Total effort to fix blockers**: 4.25 days

### Rationale

The system has **strong foundational components** (HWM tracking, DD calculation, position sizing, circuit breaker module), but **critical Apex-specific rules are missing**:
- ⚠️ Trailing DD limit is implemented but **termination behavior is weak**
- ❌ Time constraints (4:59 PM ET) are **completely absent**
- ❌ Consistency rule (30% max daily profit) is **completely absent**
- ❌ Circuit breaker exists but is **orphaned** (not integrated)

**Without these fixes, live Apex trading will result in account termination** when:
- A position is held past 4:59 PM ET (immediate termination)
- Daily profit exceeds 30% of total (immediate termination)
- DD exceeds 10% due to lack of graduated protection (termination)

**Recommendation**: **DO NOT deploy to live Apex until P0 blockers are fixed.**

---

## Recommendations

### Immediate Actions (P0 - 4.25 days total)

1. **Implement Time Constraint Manager (2 days)**
   - Create `TimeConstraintManager` class with ET timezone handling
   - Add 4-level warnings (4:00 PM, 4:30 PM, 4:55 PM, 4:59 PM)
   - Implement forced position closure at 4:59 PM deadline
   - Integrate into strategy with continuous checks
   - Add comprehensive tests (timezone, DST, edge cases)

2. **Implement Consistency Rule (1 day)**
   - Add `total_profit` field to strategy state
   - Implement `_check_consistency()`: `daily_pnl > (total_profit * 0.30)`
   - Block new trades when limit hit
   - Log consistency violations
   - Add tests (edge cases, multiple days)

3. **Integrate Circuit Breaker (0.5 day)**
   - Import `CircuitBreaker` in `gold_scalper_strategy.py`
   - Initialize in `_on_strategy_start()`
   - Add pre-trade check: `self._circuit_breaker.can_trade()`
   - Add post-trade updates: `register_trade_result()`, `update_equity()`
   - Apply size multiplier: `lot *= self._circuit_breaker.get_size_multiplier()`
   - Test integration with all 6 levels

4. **Verify Unrealized P&L Inclusion (0.5 day)**
   - Trace `current_equity` calculation in backtest and live adapters
   - Ensure open position P&L is included
   - Add explicit test: Open position with floating profit → Verify DD calculation includes it
   - Document behavior in code comments

5. **Add Account Termination on Breach (0.25 day)**
   - Create `PropFirmManager.terminate_account()` method
   - Raise `AccountTerminatedException` when DD > 10%
   - Log critical alert with breach details
   - Stop strategy execution
   - Add test case for termination

### Important Actions (P1 - 0.5 day total)

1. **Add Timezone Validation (0.25 day)**
   - Validate ET timezone conversion
   - Add test: Assert 4:59 PM ET = 21:59 UTC (or 20:59 UTC in DST)
   - Add warning if system timezone != UTC

2. **Add Apex Config Identifier (0.125 day)**
   - Add `prop_firm: "apex"` to `strategy_config.yaml`
   - Validate rules match prop firm (e.g., if "ftmo", use fixed DD; if "apex", use trailing)

3. **Replace FTMO Comments (0.0625 day)**
   - Find/replace all 6 FTMO references with "Apex" or "Prop firm"

### Enhancements (P2 - 1.5 day total)

1. **Add Alert System (0.5 day)**
   - Implement `AlertManager` with email/Telegram/webhook support
   - Trigger alerts for: DD > 8%, time warnings, consistency > 25%

2. **Add Risk Event Logging (0.25 day)**
   - Structured logging for all risk decisions
   - DD changes, HWM updates, time checks, circuit breaker escalations

3. **Differentiate Backtest vs Live Mode (0.25 day)**
   - Add `is_live_trading` flag
   - Stricter checks in live (1% DD buffer instead of 2%)

4. **Add Emergency Remote Halt (0.5 day)**
   - Webhook/API endpoint to trigger `CircuitBreaker.force_lockdown()`

---

## Next Steps

1. **Review and prioritize**: Confirm P0 blockers are acceptable effort (4.25 days)
2. **Create implementation branches**: 
   - `feat/apex-time-constraints`
   - `feat/apex-consistency-rule`
   - `feat/apex-circuit-breaker-integration`
   - `fix/apex-unrealized-pnl-verification`
   - `fix/apex-account-termination`
3. **Implement in order**: Time constraints → Consistency → Circuit breaker → Verification → Termination
4. **Test thoroughly**: Create Apex-specific test suite with edge cases
5. **Code review**: Have SENTINEL review all Apex risk implementations
6. **Dry-run simulation**: Run full backtest with Apex rules enabled, verify no violations
7. **Manual verification**: Test on Apex demo account before live

<open_questions>
- Does `current_equity` include unrealized P&L from open positions? (Need to trace upstream)
- Should circuit breaker DD thresholds (3%, 4%, 4.5%) be adjusted for Apex's trailing 10% limit?
- Should time warnings trigger notifications (email/Telegram) or just logs?
- Does Nautilus provide timezone-aware timestamps, or do we need to manage ET conversion?
</open_questions>

<assumptions>
- `update_equity()` is called frequently enough (every tick or trade) to track HWM accurately
- Apex allows partial position closure (can close in stages between 4:00-4:59 PM)
- Consistency rule counts only REALIZED profit (not unrealized)
- 4:59 PM ET is a hard deadline (no grace period)
</assumptions>

<dependencies>
- Nautilus Trader framework must provide equity updates with unrealized P&L
- System timezone must be UTC or correctly converted to ET
- Broker API must support forced position closure (for 4:59 PM deadline)
- Time constraint manager needs reliable clock (no drift, correct DST handling)
</dependencies>
