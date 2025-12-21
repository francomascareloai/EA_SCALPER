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
- Added order event handlers (`on_order_rejected/on_order_canceled/on_order_accepted`) to clear stale pending state on entry reject/cancel.
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

**Fix:** Enabled clock-timer scheduling by default (`time_gate_use_clock_timer=True`) and set a conservative timer interval (`1s`) so `check_wall_clock()` runs even with stalled feeds.

**Files:**
- `nautilus_gold_scalper/src/strategies/base_strategy.py`
- `nautilus_gold_scalper/tests/test_risk/test_time_constraint_manager.py`

**Validation:** `.venv/bin/pytest -q`, `.venv/bin/mypy --config-file mypy.ini`
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
