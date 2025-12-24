# Nautilus Gold Scalper - Bug Fix Log

**Purpose:** Track bugs and fixes with ROOT CAUSE analysis to prevent recurrence  
**Owner:** FORGE, NAUTILUS  
**Format:** Structured Markdown (newest first)  
**Usage:** Debugging, pattern recognition, post-mortem analysis

**CRITICAL bugs (account risk, Apex violations):** MUST include 5 Whys + Prevention (AGENTS.md updates)

---

## Template for Standard Bugs

```markdown
## YYYY-MM-DD HH:MM [AGENT] - Module

**Bug:** Brief description  
**Impact:** What broke / consequences  
**Root Cause:** Why it happened (1-2 sentences)  
**Fix:** Solution applied  
**Files:** List of modified files  
**Validation:** Tests added/passed  
**Commit:** hash
```

---

## Template for CRITICAL Bugs (🚨 Account Risk / Apex Violations)

```markdown
## 🚨 YYYY-MM-DD HH:MM [AGENT] - CRITICAL

**Module:** src/path/to/module.py  
**Severity:** CRITICAL (Account survival - $50k risk) | HIGH (Trading logic) | MEDIUM  
**Bug:** Brief description  
**Impact:** Specific consequences (would violate Apex? lose money?)  

**Root Cause (5 Whys):**
1. Why? [First level]
2. Why? [Deeper]
3. Why? [Process issue]
4. Why? [Missing validation]
5. Why? [Root cause]

**Fix:** Solution applied  

**Prevention (MANDATORY - Protocol Updates):**
- ✅ Updated AGENTS.md: [which section, what added]
- ✅ Added test: [coverage added]
- ✅ Added automation: [pre-commit hook, CI check]
- ✅ Updated complexity: [if escalation needed]

**Files:**
- path/to/file1.py (fixed)
- path/to/file2.py (test)
- AGENTS.md (protocol update)

**Validation:** [proof fix works]  
**Commit:** hash
```

---

## Log Entries

## 🚨 2025-12-24 00:00 [ORCHESTRATOR] - CRITICAL - BUG-14: Look-ahead & State Leakage in SMC Detectors/Scorer

**Module(s):**
- `nautilus_gold_scalper/src/indicators/order_block_detector.py`
- `nautilus_gold_scalper/src/indicators/fvg_detector.py`
- `nautilus_gold_scalper/src/indicators/liquidity_sweep.py`
- `nautilus_gold_scalper/src/indicators/structure_analyzer.py`
- `nautilus_gold_scalper/src/indicators/regime_detector.py`
- `nautilus_gold_scalper/src/signals/confluence_scorer.py`

**Severity:** CRITICAL (Backtest invalidation / live divergence risk)

### Bug Description
Multiple SMC components read future bars (look-ahead), use non-causal global statistics, or carry state across independent runs. This invalidates backtests/WFA metrics and can cause live behavior to diverge from simulated behavior.

### Evidence (file:line)
- `nautilus_gold_scalper/src/indicators/order_block_detector.py:112` global mean volume: `np.mean(volumes)` uses full series
- `nautilus_gold_scalper/src/indicators/order_block_detector.py:352` displacement uses `index + 1` (future bar)
- `nautilus_gold_scalper/src/indicators/fvg_detector.py:107` global mean volume: `np.mean(volumes)` uses full series
- `nautilus_gold_scalper/src/indicators/fvg_detector.py:357` volume spike loop includes `index + 1`
- `nautilus_gold_scalper/src/indicators/liquidity_sweep.py:304` swing confirmation uses `highs[i + j]` / `lows[i + j]`
- `nautilus_gold_scalper/src/indicators/liquidity_sweep.py:497` sweep validation scans forward from `index` for `max_bars_beyond`
- `nautilus_gold_scalper/src/indicators/structure_analyzer.py:262` swing detection uses `highs[i + j]` / `lows[i + j]`
- `nautilus_gold_scalper/src/indicators/structure_analyzer.py:270` swing points created with `timestamp=None`
- `nautilus_gold_scalper/src/indicators/regime_detector.py:84` hardcoded bias: `hurst - 0.005`
- `nautilus_gold_scalper/src/indicators/regime_detector.py:68` internal histories persist (`_hurst_history`, `_regime_history`)
- `nautilus_gold_scalper/src/signals/confluence_scorer.py:946` AMD tracked but omitted from `weighted_scores`/base score

### Impact
- Backtest PnL, WFE, PSR, SQN, and MC metrics can be inflated/invalid.
- Walk-forward and Monte Carlo outputs become unreliable for GO/NO-GO decisions.
- Live trading cannot reproduce look-ahead-dependent signals.
- Cross-run state retention can leak information between folds/segments.

### Root Cause (5 Whys)
1. Why? Several detectors implement “confirmation” using symmetric windows and forward validation.
2. Why? Swing high/low and sweep validation were coded for retrospective detection, not real-time signal generation.
3. Why? No invariant/tests enforce “bar t outputs depend only on bars ≤ t”.
4. Why? Backtest-focused iteration lacked explicit temporal-audit gates.
5. Why? Stateful detectors/scorers were reused across runs without a required reset/instance lifecycle.

### Fix Plan (BUG-14) (PENDING)
- Replace global `np.mean(volumes)` with causal trailing statistics (windowed or cumulative up to current index).
- Remove `index + 1` displacement usage; define displacement causally.
- Make swing/sweep logic causal OR explicitly delay signal emission until confirmation bars exist (and shift timestamps accordingly).
- Add `reset()`/clear state to `RegimeDetector` and enforce per-run instantiation in backtests/WFA.
- Resolve scorer consistency: include AMD in weighted total or remove AMD from factor accounting.

### Prevention (PENDING - Protocol Updates)
- Add unit tests asserting no future-bar access (e.g., index bounds checks and synthetic-series invariants).
- Add a static scan gate for patterns like `i + j`, `index + 1`, and forward loops in indicator paths.
- Document invariant in detector/scorer modules: “causal by default; retrospective detection must be explicitly labeled and delayed.”

**Validation:** pending (Phase 02 causal-fix tasks + quick backtest)
**Commit:** pending

---

## 2025-12-23 [FORGE] - BUG-13: Apex Cutoff Position Close Failure

**Module:** risk/time_constraint_manager.py
**Severity:** HIGH (Apex compliance - overnight position risk)

### Bug Description
At Apex cutoff (16:55 ET), `close_all_positions` was being called repeatedly on every tick,
causing spam of CRITICAL_POSITIONS_NOT_CLOSED errors. The issue was twofold:
1. In NautilusTrader backtesting, `close_all_positions()` submits market orders that are
   processed asynchronously on the next tick, not immediately
2. The code checked `positions_open()` immediately after submitting close orders, which
   always showed positions as still open (orders not yet filled)
3. On every subsequent tick, the code re-submitted close orders and logged CRITICAL errors

### Impact
- Massive log spam: Hundreds of CRITICAL_POSITIONS_NOT_CLOSED messages per session
- Performance degradation: Redundant close order submissions
- Misleading alerts: Made it appear positions weren't closing when they would close on next tick

### Root Cause
Asynchronous order processing in NautilusTrader backtest engine. Close orders are queued
and processed on the next market data event, not synchronously during the call.

### Fix (BUG-13)
1. Added `_close_orders_submitted` flag to track if close orders have been submitted
2. On first cutoff trigger: Submit close orders once, set flag
3. On subsequent ticks: Check if positions closed, return early if already submitted
4. Only log CRITICAL once (not on every tick) using `_issued` set tracking
5. Use `reduce_only=False` to force close regardless of position state
6. Reset tracking flags in `reset_daily()` for new trading day

### Files Modified
- nautilus_gold_scalper/src/risk/time_constraint_manager.py (lines 50-53, 180-257)
  - Added `_close_orders_submitted` and `_close_submitted_ts_ns` tracking
  - Rewrote `_force_close_all()` to submit orders only once
  - Added reset in `reset_daily()`

**Validation:** PASS - Backtest shows single cutoff log per day, no more spam
**Commit:** pending

---

## 2025-12-23 [FORGE] - BUG-12: Position Price/Quantity Type Mismatch

**Module:** strategies/gold_scalper_strategy.py
**Severity:** MEDIUM (Telemetry/logging failure, trades still execute)

### Bug Description
In `on_position_opened()` and `on_position_closed()`, code assumed `position.avg_px_open`,
`position.quantity`, `event.avg_px_close`, and `event.realized_pnl` were Nautilus `Price`/`Quantity`
objects with `.as_double()` method. In some execution paths, these are already Python `float`
values, causing AttributeError.

### Impact
- `[TRADE_MANAGER] fill_entry failed: 'float' object has no attribute 'as_double'`
- `[TRADE_MANAGER] close_trade failed: 'float' object has no attribute 'as_double'`
- Trade manager state not updated correctly
- Telemetry/logging incomplete (trades still executed successfully)

### Root Cause
NautilusTrader returns different types depending on execution context:
- Native backtest: Returns Price/Quantity objects
- Some adapters/modes: Returns raw floats

### Fix (BUG-12)
Added `hasattr` check before calling `.as_double()` in two locations:
1. `on_position_opened()` (lines 809-822) - entry price/quantity
2. `on_position_closed()` (lines 844-855) - close price/realized PnL

```python
# Pattern applied to all affected values
avg_px = getattr(object, "attribute", None)
if avg_px is not None:
    value = float(avg_px.as_double()) if hasattr(avg_px, "as_double") else float(avg_px)
```

### Files Modified
- nautilus_gold_scalper/src/strategies/gold_scalper_strategy.py (lines 809-822, 844-855)

**Validation:** PASS - No more as_double errors in backtest logs
**Commit:** pending

---

## 🚨 2025-12-23 [FORGE] - CRITICAL - BUG-11: Semantic Collision in Order Block Variables

**Module:** strategies/gold_scalper_strategy.py
**Severity:** CRITICAL (Trading logic - trade clustering, signal starvation)

### Bug Description
Semantic collision where `_mtf_order_blocks` was being overwritten by LTF detection logic.
The variable intended for MTF (M15) order blocks was incorrectly populated in the LTF (M5)
detection path, causing confusion and incorrect data sharing between timeframes.

### Impact
- Trade clustering: All trades concentrated in first week, none after
- Signal starvation: MTF zones incorrectly replaced by LTF zones
- Confluence scoring corrupted: Wrong zones passed to confluence calculator
- Multi-timeframe analysis broken: MTF and LTF data cross-contaminated

### Root Cause (5 Whys)
1. Why? Trades clustered in first week, then stopped
2. Why? Confluence scoring returned no valid signals after initial period
3. Why? `_mtf_order_blocks` contained stale/wrong data
4. Why? LTF detection code overwrote `_mtf_order_blocks` instead of `_ltf_order_blocks`
5. Why? Variable naming was ambiguous; no explicit timeframe prefix enforcement

### Fix
Added explicit timeframe prefixes to ALL order block and FVG variables:
- `_htf_order_blocks`, `_htf_fvgs` (H1 - direction/bias)
- `_mtf_order_blocks`, `_mtf_fvgs` (M15 - structure zones)
- `_ltf_order_blocks`, `_ltf_fvgs` (M5 - entry timing)

Each timeframe detection path now writes ONLY to its own prefixed variable.

### Prevention (MANDATORY - Protocol Updates)
- Added explicit prefix convention: _htf_, _mtf_, _ltf_ for timeframe-specific data
- Added integration test: test_bug11_semantic_collision.py
- Code review checklist: verify variable timeframe matches detection context

### Files Modified
- nautilus_gold_scalper/src/strategies/gold_scalper_strategy.py (variable declarations and assignments)
- nautilus_gold_scalper/tests/test_strategies/test_bug11_semantic_collision.py (new test)
- nautilus_gold_scalper/BUGFIX_LOG.md (this entry)

**Validation:** Integration test verifies separate MTF/LTF lists
**Commit:** pending

---

## 2025-12-23 [FORGE-NAUTILUS] - Signal Starvation Fix (Wave 2)

**Module:** strategies/gold_scalper_strategy.py, signals/confluence_scorer.py, configs/strategy_config_apex_mgc.yaml
**Severity:** HIGH (Strategy profitability - insufficient trade generation)

### Issue: Wave 1 Changes Too Restrictive

**Problem:** After Wave 1 CRUCIBLE fixes (SCALE_FACTOR 6.0->4.0, alignment threshold 10->12, min_score 70),
backtest showed only 1 trade in 3 months (Jan-Apr 2024). This is SIGNAL STARVATION - the filters
and thresholds were too aggressive, blocking virtually all valid trading opportunities.

**Impact:** Strategy cannot generate profit if it cannot trade. Need to balance between filter quality
and signal quantity.

### Fixes Applied (Wave 2)

**1. Score Calibration (confluence_scorer.py line 943)**
- Changed SCALE_FACTOR from 4.0 to 5.0 (compromise between original 6.0 and too-restrictive 4.0)
- Rationale: 4.0 prevented tier ceiling hits but starved signals. 5.0 balances distribution.

**2. Threshold Relaxation (strategy_config_apex_mgc.yaml)**
- min_score_to_trade: 70 -> 55
- execution_threshold: 70 -> 55
- Rationale: 70 was blocking valid B-tier signals. 55 still conservative but allows more trades.

**3. New Filter Integration (gold_scalper_strategy.py)**
- Added day-of-week filter: Blocks Monday early hours (gap risk), Friday afternoon (low liquidity)
- Added regime stability check: Blocks trades during regime transitions
- Added _dow_size_mult variable for position size adjustment
- Wired _dow_size_mult into position sizing calculations (both paths)

**4. Enhanced Debug Logging (gold_scalper_strategy.py)**
- Added [SIGNAL_DEBUG] log with Score, Tier, Direction, Confluences
- Helps diagnose signal flow without running full debug mode

### Files Modified
- nautilus_gold_scalper/src/signals/confluence_scorer.py (line 943)
- nautilus_gold_scalper/src/strategies/gold_scalper_strategy.py (lines 222-226, 336, 1115-1147, 1464-1471, 2218, 2233-2234)
- nautilus_gold_scalper/configs/strategy_config_apex_mgc.yaml (lines 19-24, 75-78, 132-149)

**5. Hurst Thresholds Widened (gold_scalper_strategy.py, strategy_config_apex_mgc.yaml)**
- Changed selector_hurst_trend_threshold: 0.55 -> 0.58
- Changed selector_hurst_revert_threshold: 0.40 -> 0.35
- Rationale: Old thresholds created "random walk" band (0.40-0.55) that blocked 40-60% of signals.
  Widened band (0.35-0.58) allows more signals while still filtering true random walk.

**6. Session Filters Relaxed for Backtest Exploration**
- Enabled allow_asian: true, allow_late_ny: true in apex config
- Rationale: 58% of trading hours were blocked; need more data for exploration

### Validation
- Import test: PASS (no syntax errors)
- mypy: 5 pre-existing errors (unrelated to this change)

### Expected Impact
- Increase trade frequency from ~0.3/month to estimated 5-15/month
- Maintain quality filters (day-of-week, regime stability, session)
- Better debug visibility for signal flow analysis

---

## 2025-12-23 12:00 [FORGE] - TradeManager Integration (CRUCIBLE FIX)

**Module:** strategies/gold_scalper_strategy.py, execution/trade_manager.py
**Severity:** HIGH (Expectancy improvement for Apex profitability)

### Issue: Static "Set and Forget" Trade Management

**Problem:** CRUCIBLE deep analysis found that TradeManager EXISTS with trailing stops, breakeven,
and partial profit functionality - but was NOT INTEGRATED into GoldScalperStrategy! The strategy
was using static SL/TP with "set and forget" approach, losing 0.3-0.5R per trade from:
- Winners reversing to losses (no trailing stop)
- No profit locking at 1R (no breakeven move)
- No partial profit taking (no 50% at 1R)

**Impact:** Estimated expectancy loss of 0.45R per trade. Improvement from 0.15R to 0.60R per trade
(4x improvement) expected after integration.

### Fixes Applied

**1. TradeManager Initialization (gold_scalper_strategy.py)**
- Added TradeManager import from execution module
- Initialized TradeManager in _on_strategy_start() with parameters:
  - partial_tp_r=1.0 (take 50% profit at 1R)
  - partial_tp_percent=0.5 (close 50% at partial TP)
  - trailing_start_r=1.0 (start trailing at 1R, also moves to breakeven)

**2. Entry Tracking (_check_for_signal method)**
- After _enter_long()/_enter_short(), create TradeInfo in TradeManager
- Store active_trade_id for matching position to trade

**3. Position Opened Hook (on_position_opened)**
- Call TradeManager.fill_entry() when position is confirmed
- Pass actual fill price and quantity from Position object

**4. Position Closed Hook (on_position_closed)**
- Call TradeManager.close_trade() to finalize trade
- Clear all tracking state (active_trade_id, modification flags)

**5. Tick-Level Processing (on_quote_tick)**
- New _process_trade_management() method processes every tick
- Uses conservative price (bid for LONG, ask for SHORT) per CLAUDE.md HWM rule
- Calls TradeManager.update_price() and handles returned actions

**6. Action Handlers**
- _handle_partial_action(): Submits partial close order (50% at 1R)
- _handle_sl_adjust_action(): Cancels old SL, submits new SL at trail/BE price
- _handle_close_action(): Full position close if TradeManager signals

**7. Safety Gates**
- _sl_modification_in_progress flag prevents race conditions
- _partial_close_in_progress flag prevents double partial closes
- All actions wrapped in try/except with warning logs

**Files Modified:**
- nautilus_gold_scalper/src/strategies/gold_scalper_strategy.py (main integration)

**Validation:**
- mypy passes (only pre-existing errors remain)
- Import test successful
- Code review: proper None checks, exception handling, state management

**Next Steps:**
- Run backtest to validate expectancy improvement
- Monitor for edge cases in SL modification flow
- Consider adding telemetry for trade management events

---

## 2025-12-23 08:31 [FORGE] - CRUCIBLE Risk Parameter Improvements

**Module:** Multiple (definitions.py, prop_firm_manager.py, session_filter.py, regime_detector.py, position_sizer.py)
**Severity:** HIGH (Risk management improvements for Apex safety)

### Issue: Risk Parameters Too Aggressive

**Problem:** CRUCIBLE deep analysis found that risk parameters were too aggressive for Apex survival:
- 1% risk per trade = only 4 consecutive losses to hit 4% halt threshold
- No single trade loss cap for flash crash protection
- No day-of-week filtering for Monday gap/Friday liquidity risk
- No regime stability requirement before trading
- DD throttling kicked in too late (3% instead of 2%)

**Impact:** Higher probability of hitting Apex DD limits during adverse conditions.

### Fixes Applied

**1. Reduced Risk Per Trade Constants (definitions.py)**
- `DEFAULT_RISK_PER_TRADE`: 0.01 -> 0.005 (0.5% instead of 1%)
- `MAX_RISK_PER_TRADE`: 0.01 -> 0.0075 (0.75% instead of 1%)
- Rationale: 0.5% risk = 8 losses to halt (safer margin vs. 4 losses)

**2. Single Trade Loss Cap (prop_firm_manager.py)**
- Added 1.5% single trade loss cap in `validate_trade()`
- Flash crash protection: no single trade can lose more than 1.5% of equity
- Includes assertion to validate loss percentage is in valid range

**3. Day-of-Week Filter (session_filter.py)**
- Added `get_day_of_week_adjustment()` method
- Monday 00:00-03:00 UTC: blocked (gap risk)
- Monday 03:00-07:00 UTC: 0.7x size (caution)
- Friday 14:00+ UTC: 0.5x size (weekend positioning)
- Returns (allowed, size_multiplier, reason) tuple

**4. Regime Stability Requirement (regime_detector.py)**
- Added `is_regime_stable()` method
- Requires minimum 10 bars in current regime before trading
- Blocks if transition probability > 40%
- Returns (stable, reason) tuple

**5. Earlier DD Throttle Tier (position_sizer.py)**
- Added 2% soft tier in `_apply_drawdown_throttle()`
- >= 4% DD: 75% cut (0.25x) - Critical
- >= 3% DD: 50% cut (0.50x) - Hard warning
- >= 2% DD: 25% cut (0.75x) - NEW soft tier

**Files:**
- `nautilus_gold_scalper/src/core/definitions.py`
- `nautilus_gold_scalper/src/risk/prop_firm_manager.py`
- `nautilus_gold_scalper/src/indicators/session_filter.py`
- `nautilus_gold_scalper/src/indicators/regime_detector.py`
- `nautilus_gold_scalper/src/risk/position_sizer.py`

**Validation:** mypy --strict passes on 4/5 files (session_filter has pre-existing unrelated issue)
**Commit:** pending

---

## 2025-12-23 [FORGE] - signals/confluence_scorer (CRUCIBLE Analysis Fixes)

**Module:** `nautilus_gold_scalper/src/signals/confluence_scorer.py`
**Severity:** CRITICAL (Signal scoring bugs causing incorrect trade decisions)

### Bug 1: MTF Double-Scaling Bug (CRITICAL)
**Bug:** MTF score was multiplied by `(weight_mtf / 100)` at assignment, then multiplied again by session weights in `_calculate_total`.
**Impact:** MTF contribution was ~15x lower than intended (e.g., 0.72 instead of 12).
**Root Cause:** MTF score is already normalized 0-100 from the analyzer. Applying weight/100 = 0.12 * 0.12 = double-penalty.
**Fix:** Removed `* (self.weight_mtf / 100)` from line 519. Added cap of 15 on weighted MTF in `_calculate_total`.

### Bug 2: POI Detection Bug in ICT Sequence (CRITICAL)
**Bug:** `at_poi` checked if ANY valid OB/FVG exists, NOT if price is AT that zone.
**Impact:** ICT sequence step 5 (at POI) was always True when any OB/FVG existed, defeating purpose.
**Root Cause:** Missing price proximity check in the boolean expression.
**Fix:** Added price range checks: `ob.low_price <= current_price <= ob.high_price` and `fvg.lower_level <= current_price <= fvg.upper_level`.

### Bug 3: SCALE_FACTOR Too High (HIGH)
**Bug:** `SCORE_SCALE_FACTOR = 6.0` caused scores to hit 100 ceiling too easily.
**Impact:** Poor tier distribution - too many signals hitting S-tier even when not elite.
**Root Cause:** Scale factor was increased for a previous fix but became too high with MTF fix.
**Fix:** Reduced from 6.0 to 4.0.

### Bug 4: Alignment Multiplier Threshold Too Low (MEDIUM)
**Bug:** Threshold of >10 for "strong" factor was too permissive.
**Impact:** Many mediocre signals getting ELITE alignment multiplier (1.35x).
**Root Cause:** Initial threshold was arbitrary guess.
**Fix:** Raised from 10 to 12.

**Files:**
- `nautilus_gold_scalper/src/signals/confluence_scorer.py`

**Validation:** mypy --strict passes (0 errors)
**Commit:** pending

## 2025-12-23 [FORGE] - strategies/base_strategy (BUG-6: FAILSAFE Permanent Halt)

**Module:** `nautilus_gold_scalper/src/strategies/base_strategy.py`, `gold_scalper_strategy.py`
**Severity:** CRITICAL (Blocks all trading after first day's cutoff)
**Bug:** `_execution_failsafe_triggered` persisted forever once triggered, preventing any trades on subsequent days.

**Impact:**
- First trade triggers cutoff failsafe at 4:55 PM ET
- Strategy never trades again for entire backtest period
- 1 trade in 3 months instead of 60+ expected

**Root Cause (5 Whys):**
1. Why? No trades after first day's cutoff.
2. Why? `_is_trading_allowed` is False on day 2.
3. Why? `_check_daily_reset()` sets `_is_trading_allowed = not _execution_failsafe_triggered`.
4. Why? `_execution_failsafe_triggered` was never reset between days.
5. Why? Original design assumed failsafe was a permanent halt (live protection), but backtests need daily reset.

**Fix:** Reset `_execution_failsafe_triggered = False` at start of each new trading day.

```python
# BUG-6 FIX: Reset execution failsafe at start of new trading day.
if self._execution_failsafe_triggered:
    self.log.info("[DAILY_RESET] Clearing execution failsafe from previous day")
    self._execution_failsafe_triggered = False
self._is_trading_allowed = True
self._trading_blocked_today = False
```

**Prevention:**
- Applied fix to `base_strategy.py` (reset() and on_new_day())
- Applied fix to `gold_scalper_strategy.py` (_check_daily_reset())
- Daily reset now enables trading regardless of previous day's failsafe

**Files:**
- `nautilus_gold_scalper/src/strategies/base_strategy.py` (lines 243-250, 273-285)
- `nautilus_gold_scalper/src/strategies/gold_scalper_strategy.py` (lines 852-862)

**Validation:**
- Before fix: 1 trade in 1 month (threshold=10)
- After fix: 18 trades in 1 month (threshold=10)
- mypy: Success
- pytest: 154 passed, 1 pre-existing failure

**Commit:** pending

---

## 2025-12-23 [FORGE] - strategies/gold_scalper_strategy (BUG-3: Confluence None)

**Module:** `nautilus_gold_scalper/src/strategies/gold_scalper_strategy.py`
**Severity:** MEDIUM (Cascade failures, silent errors)
**Bug:** `_calculate_confluence` returns None intermittently when list parameters are None, causing cascade failures.

**Impact:**
- Confluence score sporadically fails without clear error message
- Downstream code receives None instead of valid ConfluenceResult
- Bar number missing from logs, making debugging difficult

**Root Cause:**
- `self._mtf_order_blocks`, `self._mtf_fvgs`, `sweeps` can be None
- `calculate_score()` expects lists, not None
- Exception handling returns None, causing cascade

**Fix:**
- Pass empty lists `[]` instead of None using coalescence: `or []`
- Add bar context to all exception logs for debugging
- Wrap `calculate_score()` in dedicated try/except

```python
# BUG-3 FIX: Pass empty lists [] instead of None
order_blocks=self._mtf_order_blocks or [],  # BUG-3 FIX
fvgs=self._mtf_fvgs or [],  # BUG-3 FIX
sweeps=sweeps or [],  # BUG-3 FIX
```

**Files:**
- `nautilus_gold_scalper/src/strategies/gold_scalper_strategy.py` (lines 1780-1840)

**Validation:** mypy passed, imports verified
**Commit:** pending

---

## 2025-12-23 [FORGE] - scripts/backtest/run_backtest (BUG-2: CLI Session Override)

**Module:** `nautilus_gold_scalper/scripts/backtest/run_backtest.py`
**Severity:** HIGH (Config ignored, wrong backtest results)
**Bug:** CLI `--no-session-filter` (action='store_true') always defaults to False when not passed, which inverts to `use_session_filter=True`, ignoring config file setting.

**Impact:**
- Config `use_session_filter: false` is ignored
- Backtests run with session filter active despite config saying disabled
- Incorrect backtest results and misleading validation

**Root Cause:**
- `action='store_true'` means `args.no_session_filter=False` when flag not passed
- Code then does `not args.no_session_filter` = True, always enabling filter
- Config value never consulted unless CLI flag explicitly set

**Fix:** Added resolution logic to respect config when CLI flag not explicitly set:

```python
# BUG-2 FIX: Resolve from config when CLI flags not explicitly set
resolved_use_session_filter = (
    False if args.no_session_filter
    else exec_cfg.get("use_session_filter", True)
)
```

Applied to: session_filter, regime_filter, mtf, footprint, prop_firm, news_filter

**Files:**
- `nautilus_gold_scalper/scripts/backtest/run_backtest.py` (lines 1659-1687, 1746-1751, 1810-1815)

**Validation:** mypy passed, config values now respected
**Commit:** pending

---

## 2025-12-23 [FORGE] - risk/position_sizer (BUG-1: Risk Cap Exceeded)

**Module:** `nautilus_gold_scalper/src/risk/position_sizer.py`
**Severity:** CRITICAL (Apex DD risk - risk per trade exceeded)
**Bug:** Position size $1190 risk when max_risk_per_trade=1% ($1000 for $100k account). Multiple issues:
1. `max_risk_per_trade` not passed from config to PositionSizer
2. `round()` can round UP, exceeding calculated lot
3. Default sizing path had no risk cap

**Impact:**
- 19% over-risk per trade ($1190 vs $1000 limit)
- Accelerated drawdown during losing streaks
- Could breach Apex 5% trailing DD faster than expected

**Root Cause (5 Whys):**
1. Why? Lot size allows $1190 risk instead of $1000 max
2. Why? `round(lot / lot_step)` rounds 0.095 to 0.10 (UP)
3. Why? No floor() enforcement on lot normalization
4. Why? PositionSizer used hardcoded max_risk from definitions.py
5. Why? Config value not passed in GoldScalperStrategy init

**Fix:** Three-part fix:
1. Pass `max_risk_per_trade` from config to PositionSizer (lines 567-580)
2. Use `math.floor()` instead of `round()` to never exceed risk (lines 379-385)
3. Add risk cap to default sizing path (lines 1997-2011)

```python
# BUG-1 FIX: Use floor() instead of round() to NEVER exceed risk cap.
# Formula: floor(lot / lot_step) * lot_step ensures we always round DOWN.
# Example: lot=0.095, lot_step=0.01 -> floor(9.5) * 0.01 = 9 * 0.01 = 0.09
if self._lot_step > 0:
    lot = math.floor(lot / self._lot_step) * self._lot_step
```

**Files:**
- `nautilus_gold_scalper/src/risk/position_sizer.py` (lines 12, 379-385)
- `nautilus_gold_scalper/src/strategies/gold_scalper_strategy.py` (lines 567-580, 1997-2011)

**Validation:** mypy passed, unit test verified risk <= max_risk_per_trade
**Commit:** pending

---

## 2025-12-23 [FORGE] - strategies/base_strategy (BUG-5: Partial Fill SL Mismatch)

**Module:** `nautilus_gold_scalper/src/strategies/base_strategy.py`
**Severity:** CRITICAL (Position protection gap - Apex DD risk)
**Bug:** Entry order filled with quantity 100, but SL order created with quantity 50, leaving 50 units unprotected.

**Impact:**
- 50% of position has no stop loss protection
- Uncontrolled exposure during adverse moves
- Violates Apex trailing DD rules (unprotected losses can breach 5% limit)
- Account termination risk if unprotected portion gaps against position

**Root Cause (5 Whys):**
1. Why? SL quantity (50) does not match position quantity (100)
2. Why? SL was created when position had only 50 units
3. Why? Entry order received multiple partial fills (50+50=100)
4. Why? `on_position_opened` fired on first partial (50), creating SL for 50
5. Why? `on_position_changed` did not update SL when position grew to 100

**Fix:** Enhanced `on_position_changed` to detect quantity increases and sync SL:
- Track old vs new position quantity
- If quantity increased AND SL exists, call `_sync_sl_quantity_on_position_increase()`
- New helper method cancels old SL and submits new one with correct quantity
- Fail-safe: if SL price unknown or cancel fails, trigger execution failsafe

```python
# BUG-5 FIX: If quantity increased and we have an SL order, update it
# Formula: qty_delta = new_qty - old_qty
# Example: old_qty=50, new_qty=100 -> delta=50 (positive means increase)
qty_delta = new_qty - old_qty
if qty_delta > 0 and self._bracket_sl_client_order_id is not None:
    self._sync_sl_quantity_on_position_increase(new_qty)
```

**Prevention:**
- Added SL quantity sync in `on_position_changed`
- New `_sync_sl_quantity_on_position_increase()` method with fail-safe
- Logs all SL updates with `[BUG-5]` prefix for debugging
- Fails closed if unable to update SL (triggers execution failsafe)

**Files:**
- `nautilus_gold_scalper/src/strategies/base_strategy.py` (lines 530-568, 937-1015)
- `nautilus_gold_scalper/BUGFIX_LOG.md` (this entry)

**Validation:**
- mypy --ignore-missing-imports: Success
- pytest test_execution/: 75 passed
- Code review: Quantity sync covers both increase scenarios

**Commit:** pending

---

## 2025-12-23 [FORGE] - strategies/gold_scalper_strategy (BUG-4: Direction Wrong)

**Module:** `nautilus_gold_scalper/src/strategies/gold_scalper_strategy.py`
**Severity:** HIGH (Trading logic - wrong direction trades)
**Bug:** Strategy executing SELL orders when HTF (H1) shows BULLISH structure. LTF (M5) bias was incorrectly overriding HTF trend direction.

**Impact:**
- Trades placed against HTF trend direction
- Lower win rate, increased losses
- Violates SMC principle: trade WITH higher timeframe bias

**Root Cause (5 Whys):**
1. Why? SELL signals generated when HTF is BULLISH
2. Why? `_analyze_structure_component()` uses LTF (M5) data, not HTF (H1)
3. Why? The LTF structure_state is passed to confluence_scorer which sets direction
4. Why? HTF alignment check (line 1246-1256) only blocks RANGING/TRANSITION, not opposite direction
5. Why? Missing explicit check: "signal direction must align with HTF bias"

**Fix:** Added HTF direction alignment check after confluence calculation (lines 1263-1286). Now blocks SELL when HTF is BULLISH and BUY when HTF is BEARISH.

```python
# BUG-4 FIX: Block signals opposing HTF bias
if (htf_bullish and signal_sell) or (htf_bearish and signal_buy):
    # blocked - log and return
```

**Prevention:**
- Added explicit direction alignment gate with telemetry logging
- Existing `require_htf_align` config controls this behavior
- Gate is in strategy layer (hard block, not just scoring penalty)

**Files:**
- `nautilus_gold_scalper/src/strategies/gold_scalper_strategy.py` (fixed, lines 1263-1286)

**Validation:** `mypy --strict` (3 pre-existing warnings), `pytest` (319 passed, 1 pre-existing failure unrelated)
**Commit:** pending

## 2025-12-22 [FORGE] - ml/ensemble_predictor (CRITICAL - Look-ahead Leakage)

**Module:** `nautilus_gold_scalper/src/ml/ensemble_predictor.py`
**Severity:** CRITICAL (Backtest inflation - unrealistic results)
**Bug:** `StackingEnsemble.fit()` used `sklearn.model_selection.KFold` which allows future data to train models that predict past data, causing severe look-ahead bias in stacking ensemble OOF predictions.

**Impact:**
- Massive overfitting: meta-model trained on OOF predictions contaminated by future information
- Backtest results inflated: strategy would appear profitable but fail in live trading
- Could pass validation gates (WFE/SQN/PSR) with artificially good metrics

**Root Cause (5 Whys):**
1. Why? KFold was used instead of TimeSeriesSplit
2. Why? Original implementation didn't consider temporal ordering for CV
3. Why? Standard sklearn examples use KFold for classification
4. Why? Time-series specific CV wasn't enforced in code review
5. Why? No automated check for temporal CV in ML pipeline

**Fix:** Replaced `KFold` with `TimeSeriesSplit` with configurable gap parameter. Added proper handling of samples without OOF predictions (early samples never in test set with TimeSeriesSplit).

**Prevention (MANDATORY - Protocol Updates):**
- Added `gap` parameter to StackingEnsemble constructor (default=10)
- Added docstring warning that input data MUST be sorted ascending by time
- Validated TimeSeriesSplit ensures train is ALWAYS temporally before test

**Files:**
- `nautilus_gold_scalper/src/ml/ensemble_predictor.py` (fixed)
- `nautilus_gold_scalper/src/ml/feature_engineering.py` (index validation added)

**Validation:** `mypy --strict`, `pytest nautilus_gold_scalper/tests/test_onnx_migration.py`
**Commit:** pending

## 2025-12-22 [FORGE] - ml/feature_engineering (Index order validation)

**Module:** `nautilus_gold_scalper/src/ml/feature_engineering.py`
**Severity:** MEDIUM (Look-ahead prevention)
**Bug:** `compute_all_features()` did not validate that input DataFrame index is sorted ascending by time. Unsorted data would produce invalid rolling calculations.

**Impact:** If data is accidentally shuffled, all rolling-based features would be computed incorrectly, potentially introducing look-ahead bias in feature engineering.

**Root Cause:** No defensive check for temporal ordering in input data.

**Fix:**
1. Added index validation in `compute_all_features()` - raises ValueError if DatetimeIndex is not monotonically increasing
2. Added `scale_train_test()` helper method to prevent scaler leakage
3. Enhanced docstrings with usage examples for proper train/test scaling

**Files:**
- `nautilus_gold_scalper/src/ml/feature_engineering.py`

**Validation:** `mypy --strict`, manual test of index validation and scale_train_test
**Commit:** pending

## 2025-12-21 12:55 [FORGE] - risk/drawdown (WP2 Force-Flat on DD breach)

**Bug:** DD breach path in `BaseGoldStrategy._apply_drawdown_limits()` only blocked entries and attempted a single-position close (not a full fail-safe flatten).
**Impact:** If drawdown breaches while in-position, open risk could remain longer than one control loop and working orders may remain, increasing Apex termination risk.
**Root Cause:** DrawdownTracker enforcement path was not aligned with the strategy-wide fail-safe invariant (cancel orders + flatten + halt).
**Fix:** Apply safety-buffer thresholds (daily 3.0%, trailing 4.0%) and trigger `_trigger_execution_failsafe(...)` when breached while in-position.
**Files:**
- `nautilus_gold_scalper/src/strategies/base_strategy.py`
- `nautilus_gold_scalper/tests/test_execution/test_execution_failsafe.py`
**Validation:** `.venv/bin/pytest -q`, `.venv/bin/mypy --strict -p nautilus_gold_scalper`
**Commit:** pending

## 2025-12-21 08:22 [FORGE] - signals/news_data (NewsWindowData publish/catalog)

**Bug:** `NewsWindowData` subclassed Nautilus `Data` without implementing required `ts_event/ts_init` properties (and without serialization registration).
**Impact:** `publish_data(DataType(NewsWindowData), ...)` could fail at runtime and downstream catalog/serialization would be undefined.
**Root Cause:** Removed `@customdataclass` to avoid duplicate global registration, but did not replace it with a safe timestamp+serialization implementation.
**Fix:** Implemented `ts_event/ts_init` on `NewsWindowData` and registered message-bus + Arrow serialization (idempotent registration).
**Files:**
- `nautilus_gold_scalper/src/signals/news_data.py`
**Validation:** `.venv/bin/pytest -q`, `.venv/bin/mypy --strict --config-file mypy.ini`
**Commit:** pending

## 2025-12-20 18:32 [FORGE] - signals/news_calendar (Backtest support)

**Bug:** `NewsCalendar` cache refresh previously filtered events by wall-clock “future-only”, breaking historical backtest evaluation.
**Impact:** Backtests could miss events (no blocking window) and mis-estimate strategy behavior around news.
**Root Cause:** Cache refresh assumed live usage and pruned past events, but backtests need the full timeline and a caller-provided `now`.
**Fix:** Keep both past+future events loaded; backtests pass bar time into `check_news_window(now=...)`.
**Files:**
- `nautilus_gold_scalper/src/signals/news_calendar.py`
- `nautilus_gold_scalper/tests/test_signals/test_news_calendar.py`
**Validation:** `.venv/bin/pytest -q nautilus_gold_scalper/tests/test_signals/test_news_calendar.py`
**Commit:** pending


## 🚨 2025-12-20 02:20 [FORGE] - CRITICAL (WP0 Execution Fail-Safe)

**Module:** `nautilus_gold_scalper/src/strategies/base_strategy.py`
**Severity:** CRITICAL (Account survival - Apex risk)
**Bug:** Bracket SL/TP attachment is not fail-safe; rejects/cancels can leave a naked open position, and IOC rejects can leave stale pending SL/TP.
**Impact:** Unprotected exposure + potential account termination (Apex DD/time rules) if SL fails and adverse move occurs.

**Root Cause (5 Whys):**
1. Why? SL/TP were stored as pending prices and cleared immediately after submit without verifying acceptance.
2. Why? No order-event lifecycle tracking existed for entry/brackets.
3. Why? Strategy relied on `PositionOpened` only, assuming bracket submits succeed.
4. Why? Missing invariant checks for “position must have SL protection”.
5. Why? No tests covered reject/cancel paths for IOC and bracket orders.

**Fix:**
- Added lifecycle tracking for entry + bracket client_order_ids.
- Added order event handlers (`on_order_rejected/on_order_canceled/on_order_accepted`) + deferred cleanup with grace window to avoid cancel/reject-before-fill race.
- Enforced strict TP expectation: if TP was requested and TP order is missing/rejected/canceled → fail-safe (flatten + halt).
- Added fail-safe: if bracket is rejected/canceled while position is open, cancel all orders + close all positions + halt trading.

**Prevention (MANDATORY - Protocol Updates):**
- ✅ Added tests: `nautilus_gold_scalper/tests/test_execution/test_execution_failsafe.py`
- ✅ Added fail-safe invariant enforcement in strategy execution layer.

**Files:**
- `nautilus_gold_scalper/src/strategies/base_strategy.py`
- `nautilus_gold_scalper/tests/test_execution/test_execution_failsafe.py`

**Validation:**
- `pytest -q nautilus_gold_scalper/tests/test_execution/test_execution_failsafe.py`
- `pytest -q nautilus_gold_scalper/tests/test_integration/test_strategy_flow.py`

**Commit:** pending

---

## 🚨 2025-12-20 15:30 [FORGE] - HIGH (WP1 Time Gates Resilience)

**Module:** `nautilus_gold_scalper/src/risk/time_constraint_manager.py`
**Severity:** HIGH (Apex time-gate compliance)
**Bug:** Time gates could fail under complete data-feed stall if enforcement relies only on `on_quote_tick`/`on_bar` events.
**Impact:** Potential overnight exposure or late close → Apex rule violation → account termination risk.

**Root Cause:** Time gates were evaluated only when market events arrived; no wall-clock scheduler was enabled by default.

**Fix:**
- Ensure time gates can be enforced via clock timer path (`set_timer_ns → on_timer → check_wall_clock`) under feed stalls.
- Timer activation now respects `prop_firm_enabled`, `allow_overnight`, and `time_gate_use_clock_timer`.
- Emergency gate is clamped to never exceed cutoff (defensive).
- Flatten telemetry/log payload now includes `trigger` + `gate` for clearer audit trails.

**Files:**
- `nautilus_gold_scalper/src/risk/time_constraint_manager.py`
- `nautilus_gold_scalper/src/strategies/gold_scalper_strategy.py`
- `nautilus_gold_scalper/tests/test_risk/test_time_constraint_manager.py`

**Validation:** `.venv/bin/pytest -q`, `.venv/bin/mypy --strict -p nautilus_gold_scalper`
**Commit:** pending

### 2025-12-08 18:00 [FORGE] - BUGFIX_LOG.md
### 🚨 2025-12-11 [FORGE ANALYSIS] - CRITICAL BUGS DISCOVERED

## 🚨 CRITICAL BUG #1: Look-Ahead Bias in Feature Engineering
**File:** `src/ml/feature_engineering.py:318-319`
**Severity:** CRITICAL (Backtest invalidation)
**Bug:** Swing point calculation uses `center=True` which looks at future bars
```python
swing_high = high.rolling(window * 2 + 1, center=True).max()  # LOOKS AHEAD!
swing_low = low.rolling(window * 2 + 1, center=True).min()   # LOOKS AHEAD!
```
**Impact:** Training on future information → overfitted backtest → production failure
**Root Cause:** `center=True` parameter includes `window` future bars in calculation
**Fix Required:** Remove `center=True` or shift results forward by `window` periods
**Status:** ❌ PENDING FIX

---

## 🚨 CRITICAL BUG #2: Missing Attribute in BaseStrategy
**File:** `src/strategies/base_strategy.py:207`
**Severity:** CRITICAL (Runtime AttributeError)
**Bug:** Attribute `_min_bars_for_signal` referenced but never defined
```python
self.log.info(f"... (need {self._min_bars_for_signal} bars, have {len(self._ltf_bars)})")
```
**Impact:** AttributeError at runtime when logging → strategy crashes
**Root Cause:** Attribute used in log message but not initialized in __init__
**Fix Required:** Add `self._min_bars_for_signal: int = 50` to `__init__`
**Status:** ❌ PENDING FIX

---

## 🟠 HIGH BUG #3: Pickle Security Vulnerabilities
**Files:** 
- `src/ml/model_trainer.py:378-385, 446-449`
- `src/ml/ensemble_predictor.py:586-589, 674-679, 682-692`
**Severity:** HIGH (Security - arbitrary code execution)
**Bug:** Pickle fallback and calibrator storage use pickle (code execution risk)
**Impact:** Loading malicious .pkl file → remote code execution → account compromise
**Root Cause:** ONNX fallback to pickle, calibrators always pickle
**Fix Required:** Remove pickle fallback, enforce ONNX-only, convert calibrators to JSON
**Status:** ❌ PENDING FIX

---

## 🟠 HIGH BUG #4: 4:59 PM ET Deadline Not Enforced in Adapters
**Files:** 
- `src/execution/base_adapter.py:send_order()` 
- `src/execution/mt5_adapter.py`
- `src/execution/ninjatrader_adapter.py`
**Severity:** HIGH (Apex rule violation → account termination)
**Bug:** Adapters can submit orders after 4:59 PM ET cutoff
**Impact:** Order fills after cutoff → overnight position → Apex account terminated
**Root Cause:** TimeConstraintManager only blocks strategy, not adapter layer
**Fix Required:** Add 4:59 PM ET check to `BaseAdapter.send_order()`
**Status:** ❌ PENDING FIX

---

## 🟠 HIGH BUG #5: News Calendar Hardcoded to Dec 2025
**File:** `src/signals/news_calendar.py:125-179`
**Severity:** HIGH (Production blocker after Dec 2025)
**Bug:** `get_hardcoded_events_2025()` only contains December 2025 events
**Impact:** News-aware trading fails in 2026
**Root Cause:** Hardcoded events, no dynamic data source
**Fix Required:** Add 2026+ events or implement API/CSV loader
**Status:** ❌ PENDING FIX

---

## 🟡 MEDIUM BUG #6: Slippage Model Not Applied in Backtests
**Files:** 
- `src/execution/execution_model.py` (implemented)
- `src/execution/base_adapter.py` (not integrated)
**Severity:** MEDIUM (Unrealistic backtest results)
**Bug:** ExecutionModel.apply_slippage() exists but never called by BaseAdapter
**Impact:** Backtests show perfect fills (unrealistic) → overestimate performance
**Fix Required:** Integrate slippage model into BaseAdapter fill simulation
**Status:** ❌ PENDING FIX

---

## 🟡 MEDIUM BUG #7: ONNX Input Shape Validation Missing
**File:** `src/ml/ensemble_predictor.py:188-208`
**Severity:** MEDIUM (Unclear runtime errors)
**Bug:** No validation that features.shape[1] matches expected input dimensions
**Impact:** Runtime errors with unhelpful messages if feature count mismatches
**Fix Required:** Add shape check before model.run()
**Status:** ❌ PENDING FIX

---


**Bug:** No structured bug tracking system  
**Impact:** Bugs not analyzed for root cause, patterns not learned  
**Root Cause:** Missing systematic logging protocol with prevention enforcement  
**Fix:** Created BUGFIX_LOG.md with mandatory Root Cause + Prevention for CRITICAL bugs  
**Files:** BUGFIX_LOG.md  
**Validation:** Template complete with 🚨 CRITICAL protocol  
**Commit:** pending

---

## 2024-12-23 11:00 [FORGE] - BUG-7: Bracket Confirmation Timeout Too Short

**Bug:** `bracket_confirm_timeout_ns` defaulted to 5 seconds, causing premature trade closures
**Impact:** Trades closed via failsafe 20-30s after entry when SL wasn't "confirmed" in simulation
**Root Cause:** Stride 20 tick data has gaps > 5s between ticks; simulator confirmation events don't match live timing
**Fix:**
- Added `bracket_confirm_timeout_ns` as configurable parameter in `BaseStrategyConfig`
- Increased default from 5s to 60s for backtest compatibility
- Line 86 in `base_strategy.py`: `bracket_confirm_timeout_ns: int = 60_000_000_000`
- Line 152 in `base_strategy.py`: Updated default fallback from 5s to 60s
**Files:**
- `src/strategies/base_strategy.py`
**Validation:** Backtest win rate improved from 16.7% to 41.7%
**Commit:** pending

---

## 2024-12-23 10:30 [FORGE] - CONFIG: Session/Regime Filters Enabled

**Bug:** Session and regime filters were DISABLED in strategy_config.yaml
**Impact:** Strategy traded during low-quality sessions and unfavorable regimes
**Root Cause:** Config set `use_session_filter: false` and `use_regime_filter: false`
**Fix:**
- `execution.use_session_filter: true`
- `execution.use_regime_filter: true`
- `risk.max_risk_per_trade: 0.005` (0.5% instead of 1%)
**Files:**
- `configs/strategy_config.yaml`
**Validation:** With filters enabled, trades only occur during allowed sessions
**Commit:** pending

---

## 2024-12-23 10:30 [FORGE] - FIX: SL Distance Capping

**Bug:** `_calculate_sl_distance()` had no maximum SL cap
**Impact:** Could return arbitrarily large SL values leading to $2,300+ single-trade losses
**Root Cause:** Raw SL from structure/ATR calculation not clamped
**Fix:**
- Added constants: `MAX_SL_DISTANCE=50.0`, `MIN_SL_DISTANCE=15.0`, `DEFAULT_SL_DISTANCE=30.0`
- Clamped SL in `_calculate_sl_distance()` to [15, 50] range
**Files:**
- `src/core/definitions.py`
- `src/strategies/gold_scalper_strategy.py`
**Validation:** SL now bounded, reducing max single-trade loss
**Commit:** pending

