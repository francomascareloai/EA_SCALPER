# Prompt 006: Critical Bugs Fix - Status Analysis

**Generated**: 2025-12-07  
**Objective**: Analyze what has been done and what remains for fixing all 12 P0 bugs

---

## Executive Summary

**Overall Progress**: ~58% Complete (7/12 bugs implemented, 0/12 validated with tests)

**Status by Phase**:
- **Phase 1 (Apex Compliance)**: ✅ 5/5 bugs CODED | ⚠️ 0/5 TESTED
- **Phase 2 (Backtest Realism)**: 🔶 3/4 bugs CODED | ⚠️ 0/4 TESTED  
- **Phase 3 (Code Correctness)**: ❌ 0/3 bugs STARTED

**Critical Gap**: ALL implementations lack automated validation. Tests written but NOT executed.

**Risk**: Without test execution, we don't know if fixes actually work or if they introduce regressions.

---

## Phase 1: Apex Compliance (5 bugs) ✅ CODED / ⚠️ NOT TESTED

### Bug #8: Time Constraint Manager ✅ CODED
**Status**: Code implemented, tests written but not executed  
**What was done**:
- ✅ Created `nautilus_gold_scalper/src/risk/time_constraint_manager.py` (new module)
- ✅ 4-level warning system (4:00 PM, 4:30 PM, 4:55 PM, 4:59 PM ET)
- ✅ Force close all positions at 4:59 PM ET cutoff
- ✅ Integrated into `gold_scalper_strategy.py` (checks on every bar/tick)
- ✅ Daily reset mechanism for new trading day
- ✅ Test file created: `tests/test_risk/test_time_constraint_manager.py`

**What remains**:
- ⚠️ Execute unit tests to validate time logic
- ⚠️ Test DST transition handling
- ⚠️ Integration test: Verify backtest respects 4:59 PM cutoff
- ⚠️ Validate that positions are actually closed (not just blocked)

**Evidence**: `time_constraint_manager.py` lines 1-120

---

### Bug #9: Consistency Rule Tracker ✅ CODED
**Status**: Code implemented, tests written but not executed  
**What was done**:
- ✅ Created `nautilus_gold_scalper/src/risk/consistency_tracker.py` (new module)
- ✅ Tracks total profit and daily profit separately
- ✅ Blocks new orders if daily profit > 30% of total profit
- ✅ Warning levels at 20%, 25%, 30%
- ✅ Integrated into `base_strategy.py` and `gold_scalper_strategy.py`
- ✅ Daily reset at midnight ET
- ✅ Test file created: `tests/test_risk/test_consistency_tracker.py`

**What remains**:
- ⚠️ Execute unit tests to validate 30% calculation
- ⚠️ Test edge case: What happens when total profit is negative?
- ⚠️ Integration test: Verify strategy actually blocks trades at 30% limit
- ⚠️ Multi-day backtest: Confirm daily reset works across multiple days

**Evidence**: `consistency_tracker.py` lines 1-85

---

### Bug #10: Circuit Breaker Integration ✅ CODED
**Status**: Code integrated, tests written but not executed  
**What was done**:
- ✅ Circuit breaker (already existed) now integrated into strategy
- ✅ Pre-trade guard checks `circuit_breaker.can_trade()` before orders
- ✅ Size multiplier applied based on circuit breaker level
- ✅ Equity feed per tick for real-time monitoring
- ✅ Trade result feed updates circuit breaker state
- ✅ Test file created: `tests/test_risk/test_circuit_breaker_levels.py`

**What remains**:
- ⚠️ Execute integration tests for all 6 circuit breaker levels
- ⚠️ Verify size reduction actually applied (not just calculated)
- ⚠️ Test emergency halt scenario
- ⚠️ Validate circuit breaker persists state across backtests

**Evidence**: `gold_scalper_strategy.py` lines with circuit_breaker references

---

### Bug #11: Strengthen Termination Logic ✅ CODED
**Status**: Code implemented, tests written but not executed  
**What was done**:
- ✅ Modified `prop_firm_manager.py` to call `strategy.stop()` on DD breach
- ✅ Flatten all positions when DD limit exceeded
- ✅ PropFirmManager now holds reference to strategy
- ✅ Test file created: `tests/test_risk/test_prop_firm_manager_apex.py`

**What remains**:
- ⚠️ Execute unit test: Verify strategy actually stops on DD breach
- ⚠️ Integration test: Confirm backtest HALTS (doesn't continue after breach)
- ⚠️ Test: Verify positions are flattened before strategy stops
- ⚠️ Edge case: What if flatten fails? Does strategy still stop?

**Evidence**: `prop_firm_manager.py` lines with stop() + flatten logic

---

### Bug #12: Unrealized P&L in DD Calculation ✅ CODED
**Status**: Code implemented, tests written but not executed  
**What was done**:
- ✅ Equity calculation includes unrealized P&L from open positions
- ✅ HWM (high-water mark) updates with unrealized gains
- ✅ Equity marked-to-market on every tick in `gold_scalper_strategy.py`
- ✅ PropFirmManager receives updated equity for DD calculation
- ✅ Test file created: `tests/test_risk/test_prop_firm_manager_apex.py`

**What remains**:
- ⚠️ Execute unit test: Verify unrealized P&L included in equity
- ⚠️ Test: HWM updates correctly with open positions
- ⚠️ Test: DD calculated correctly with mixed realized/unrealized P&L
- ⚠️ Edge case: What if position has NaN unrealized P&L?

**Evidence**: `gold_scalper_strategy.py` equity calculation, `prop_firm_manager.py` HWM logic

---

## Phase 2: Backtest Realism (4 bugs) 🔶 PARTIAL

### Bug #5: Slippage & Commission 🔶 PARTIAL
**Status**: Execution model created, integration incomplete  
**What was done**:
- ✅ Created `nautilus_gold_scalper/src/execution/execution_model.py`
- ✅ Slippage model: Base 10 cents + volatility adjustment
- ✅ Commission model: $5 per lot (configurable)
- ✅ ExecutionModel instantiated in strategy
- ✅ Costs applied per fill (entry/exit) in `base_strategy.py`
- ✅ PnL reported net of costs to DD/prop/circuit breaker
- ✅ Unit test created: `tests/test_execution/test_execution_model.py`

**What remains**:
- ⚠️ Execute unit tests to validate cost calculations
- ⚠️ **CRITICAL**: Validate costs in backtest runners (`run_backtest.py`, `mass_backtest.py`)
- ⚠️ Integration test: Run short backtest and verify costs are applied on EVERY fill
- ⚠️ Compare backtest results before/after costs (should be worse with costs)
- ⚠️ Ensure trade_manager.py doesn't duplicate cost application

**Evidence**: `execution_model.py` exists, referenced in strategy

---

### Bug #7: Threshold Alignment ✅ CODED
**Status**: Config updated, needs validation  
**What was done**:
- ✅ Updated `configs/strategy_config.yaml`: `execution_threshold: 70`
- ✅ Updated `scripts/run_backtest.py`: Default threshold = 70, sweep centered on 70
- ✅ Updated `scripts/mass_backtest.py`: Default threshold = 70, grid centered on 70
- ✅ Documentation updated in `INDEX.md`
- ✅ Single source of truth established in YAML config

**What remains**:
- ⚠️ **CRITICAL**: Re-run backtests with threshold=70 to validate impact
- ⚠️ Grep entire codebase for any remaining hardcoded 65 or 50 values
- ⚠️ Confirm `confluence_scorer.py` reads threshold from config (Bug #2 overlap)
- ⚠️ Generate before/after comparison report

**Evidence**: `strategy_config.yaml` line 75, `run_backtest.py` line 112

---

### Bug #6: Position Sizer Units 🔶 PARTIAL
**Status**: Pip_value passed to sizer, conversion logic unclear  
**What was done**:
- ✅ Modified `gold_scalper_strategy.py` to pass `pip_value` from instrument to PositionSizer

**What remains**:
- ⚠️ **BLOCKER**: Review `position_sizer.py` to confirm it actually USES pip_value
- ⚠️ Add unit conversion logic: XAUUSD price → pips/points
- ⚠️ Write unit test for XAUUSD pip/point conversion
- ⚠️ Test lot sizing calculation with different stop losses
- ⚠️ Integration test: Validate position sizes are reasonable in backtest

**Evidence**: `gold_scalper_strategy.py` passes pip_value, but `position_sizer.py` not verified

---

### Bug #4: Daily Reset Hook ❌ NOT STARTED
**Status**: Not implemented  
**What needs to be done**:
1. Add `on_new_day()` method to `base_strategy.py`
2. Schedule daily reset at midnight ET using `clock.set_timer()`
3. Call reset methods on all modules:
   - `prop_firm_manager.reset_daily()`
   - `consistency_tracker.reset_daily()`
   - `time_constraint_manager.reset_daily()`
   - `circuit_breaker.reset_daily_metrics()` (if applicable)
4. Write integration test for multi-day backtest
5. Verify counters actually reset in logs

**Files to modify**:
- `base_strategy.py` (add on_new_day method)
- `prop_firm_manager.py` (add reset_daily method if missing)
- Test file: `tests/test_risk/test_daily_resets.py` (new)

**Estimated effort**: 0.5 day

---

## Phase 3: Code Correctness (3 bugs) ❌ NOT STARTED

### Bug #1: Threshold 65 → 70 ❌ NOT STARTED
**Status**: Not done (overlaps with Bug #7 but different scope)  
**What needs to be done**:
1. Search for hardcoded `65` in `gold_scalper_strategy.py`
2. Change to `70` or read from config
3. Grep entire codebase for other instances of 65
4. Update any hardcoded thresholds found

**Files to check**:
- `gold_scalper_strategy.py` (line ~67)
- Any other strategy files
- Backtest runners (already done in Bug #7)

**Estimated effort**: 0.5 hour

---

### Bug #2: Enforce confluence_min_score Config ❌ NOT STARTED
**Status**: Not implemented  
**What needs to be done**:
1. Review `confluence_scorer.py` current implementation
2. Add check: `if final_score < self.config.confluence_min_score: return 0.0`
3. Write unit test: Signals below min_score are rejected
4. Integration test: Fewer signals generated when min_score enforced
5. Update config to ensure `confluence_min_score` is set (should be 70)

**Files to modify**:
- `confluence_scorer.py` (add enforcement)
- Test file: `tests/test_signals/test_confluence_scorer.py` (new or update)

**Estimated effort**: 0.5 hour

---

### Bug #3: NinjaTrader Adapter ❌ NOT STARTED
**Status**: 42-line stub exists, full implementation not done  
**What needs to be done**:
1. Decide if this is needed NOW or can be DEFERRED
2. If needed:
   - Implement full NinjaTrader 8 ATI integration (~500-600 lines)
   - Order management (submit, cancel, modify)
   - Position tracking
   - Fill notifications
   - Error handling & reconnection
3. Write integration tests with NT8 simulator
4. Manual testing with paper account

**Files to create/modify**:
- `nautilus_gold_scalper/src/execution/ninjatrader_adapter.py` (expand from 42 to ~600 lines)
- `configs/execution_config.yaml` (add NT8 config)
- Test file: `tests/test_execution/test_ninjatrader_adapter.py` (new)

**Estimated effort**: 2 days  
**Recommendation**: **DEFER** to Phase 4 if paper trading not immediate priority

---

## Critical Gap: Test Execution

### Tests Written But NOT Executed
All test files exist but have NEVER been run:
- `tests/test_risk/test_time_constraint_manager.py`
- `tests/test_risk/test_consistency_tracker.py`
- `tests/test_risk/test_prop_firm_manager_apex.py`
- `tests/test_risk/test_circuit_breaker_levels.py`
- `tests/test_execution/test_execution_model.py`

**Why not executed**: User policy = "never" for test execution approval

**Risk**: 
- Fixes may not work as intended
- Regressions may have been introduced
- Integration issues may exist
- Edge cases may fail

**Mitigation needed**:
1. Get approval to execute tests
2. Run all Phase 1 tests
3. Run all Phase 2 tests (as completed)
4. Fix any failures
5. Add missing tests (integration tests, multi-day tests, etc.)

---

## Missing Tests (Need to be Written + Executed)

### Phase 1
- [ ] Integration: Multi-day backtest respects 4:59 PM cutoff EVERY day
- [ ] Integration: Consistency rule blocks trades across multiple days
- [ ] Integration: DD breach halts backtest (not just blocks trades)
- [ ] Edge case: DST transition handling for time constraints
- [ ] Edge case: Negative total profit for consistency rule
- [ ] Edge case: Flatten failure during termination

### Phase 2
- [ ] Integration: Slippage/commission applied in full backtest
- [ ] Integration: Position sizing in pips (not price) for XAUUSD
- [ ] Integration: Multi-day reset works across 30+ day backtest
- [ ] Validation: Before/after comparison with costs
- [ ] Unit: XAUUSD pip/point conversion

### Phase 3
- [ ] Unit: confluence_min_score rejection
- [ ] Integration: Threshold 70 impact on signal count

---

## Files Modified Summary

### New Files Created (7)
```
✅ nautilus_gold_scalper/src/risk/time_constraint_manager.py (120 lines)
✅ nautilus_gold_scalper/src/risk/consistency_tracker.py (85 lines)
✅ nautilus_gold_scalper/src/execution/execution_model.py (150 lines)
✅ nautilus_gold_scalper/tests/test_execution/test_execution_model.py (50 lines)
✅ nautilus_gold_scalper/tests/test_risk/test_time_constraint_manager.py (80 lines)
✅ nautilus_gold_scalper/tests/test_risk/test_consistency_tracker.py (70 lines)
✅ nautilus_gold_scalper/tests/test_risk/test_prop_firm_manager_apex.py (90 lines)
```

### Modified Files (12)
```
✅ nautilus_gold_scalper/src/strategies/gold_scalper_strategy.py (+150 lines)
✅ nautilus_gold_scalper/src/strategies/base_strategy.py (+100 lines)
✅ nautilus_gold_scalper/src/risk/prop_firm_manager.py (+50 lines)
✅ nautilus_gold_scalper/src/risk/__init__.py (+3 imports)
✅ nautilus_gold_scalper/configs/strategy_config.yaml (+4 lines)
✅ nautilus_gold_scalper/scripts/run_backtest.py (+92 lines)
✅ nautilus_gold_scalper/scripts/mass_backtest.py (+4 lines)
✅ nautilus_gold_scalper/INDEX.md (+2 lines)
✅ .prompts/006-fix-critical-bugs/SUMMARY.md
✅ .prompts/006-fix-critical-bugs/fix-implementation-report.md
✅ nautilus_gold_scalper/src/signals/news_calendar.py (minor changes)
✅ nautilus_gold_scalper/src/risk/circuit_breaker.py (integration only)
```

### Not Started (3)
```
❌ nautilus_gold_scalper/src/signals/confluence_scorer.py (Bug #2 - needs enforcement)
❌ nautilus_gold_scalper/src/execution/ninjatrader_adapter.py (Bug #3 - stub only)
❌ base_strategy.py on_new_day() method (Bug #4 - daily reset)
```

---

## Repository Status

**Git status**: Dirty with 43 files modified, 7 new files, 5 deleted  
**Commits**: None (changes not committed yet)  
**Reason**: Awaiting test validation before commit

**TODOs/FIXMEs in codebase**: 5 found (mostly unrelated to prompt 006)
- `news_calendar.py`: TODO for January 2026+ events
- `news_calendar.py`: TODO for optional Forex Factory scraping
- Others are documentation notes

---

## Next Steps (Prioritized)

### Immediate (Today)
1. **Execute Phase 1 tests** - Validate all Apex compliance fixes work
   ```bash
   pytest nautilus_gold_scalper/tests/test_risk/test_time_constraint_manager.py -v
   pytest nautilus_gold_scalper/tests/test_risk/test_consistency_tracker.py -v
   pytest nautilus_gold_scalper/tests/test_risk/test_prop_firm_manager_apex.py -v
   pytest nautilus_gold_scalper/tests/test_risk/test_circuit_breaker_levels.py -v
   ```

2. **Execute Phase 2 tests** - Validate execution model costs
   ```bash
   pytest nautilus_gold_scalper/tests/test_execution/test_execution_model.py -v
   ```

3. **Fix any test failures** - Debug and resolve issues found

### Short Term (This Week)
4. **Complete Bug #4** - Implement daily reset hook in base_strategy.py (0.5 day)
5. **Complete Bug #6** - Verify position sizer unit conversion works (0.5 day)
6. **Validate Bug #5** - Run short backtest to confirm costs applied per fill (0.5 day)
7. **Complete Bug #1** - Change threshold 65 → 70 in strategy (0.5 hour)
8. **Complete Bug #2** - Enforce confluence_min_score in scorer (0.5 hour)

### Medium Term (Next Week)
9. **Write missing integration tests** - Multi-day, cutoff, consistency, costs
10. **Run full backtest validation** - 30-day backtest with all fixes + costs
11. **Compare before/after** - Quantify impact of fixes on metrics
12. **Re-run audits 003 & 004** - Verify all P0s are actually resolved

### Long Term (Defer if Needed)
13. **Bug #3** - NinjaTrader adapter full implementation (2 days) - OPTIONAL DEFER

---

## GO/NO-GO Assessment

**Current Status**: ⚠️ **CONDITIONAL GO**

**Conditions to achieve full GO**:
1. ✅ Phase 1 code implemented → **DONE**
2. ⚠️ Phase 1 tests pass → **PENDING**
3. ⚠️ Phase 2 code complete → **PARTIAL** (Bug #4 not started)
4. ⚠️ Phase 2 tests pass → **PENDING**
5. ⚠️ Phase 3 bugs fixed → **NOT STARTED** (Bugs #1, #2 easy; Bug #3 optional)
6. ⚠️ Integration tests pass → **PENDING**
7. ⚠️ Full backtest validation → **PENDING**

**Estimated time to full GO**: 3-4 days (assuming all tests pass on first try)

**Risks**:
- Tests may reveal bugs in implementation
- Integration issues between modules
- Backtest may show unexpected behavior with costs
- Edge cases may fail

**Recommendation**: 
1. Execute ALL existing tests ASAP
2. Fix failures before proceeding to Phase 3
3. Complete Bug #4 (daily reset) - critical for multi-day accuracy
4. Defer Bug #3 (NinjaTrader) unless paper trading is imminent
5. Run validation backtest before declaring GO

---

## Effort Summary

### Completed (Actual)
- Phase 1: ~1.5 days (5 bugs coded + tests written)
- Phase 2: ~0.3 days (3/4 bugs partial)
- **Total so far**: ~1.8 days

### Remaining (Estimated)
- Phase 1 test validation: 0.5 day (execute + fix failures)
- Phase 2 completion: 1.0 day (Bug #4 + Bug #6 verification + Bug #5 validation)
- Phase 2 test validation: 0.5 day
- Phase 3: 0.2 day (Bugs #1 + #2, skip Bug #3)
- Integration tests: 1.0 day (write + execute)
- Full validation: 0.5 day (backtest + comparison)
- **Total remaining**: ~3.7 days

### Original Estimate
- Phase 1: 3-4 days → **Actual: 1.5 days** (faster than expected)
- Phase 2: 2 days → **In progress: 0.3 days so far** (on track)
- Phase 3: 2.5 days → **Not started** (can be reduced to 0.2 day by deferring Bug #3)

**Conclusion**: On pace to complete in ~5.5 days total (vs 7-8 day estimate), assuming no major test failures.

---

## Open Questions

1. **Test execution approval**: Can tests be executed now?
2. **Bug #3 priority**: Is NinjaTrader adapter needed immediately or can it be deferred?
3. **Commit strategy**: Commit after each phase or wait until all validated?
4. **Threshold sweep**: Should we re-run threshold sweep (65-75) after fixes or stick with 70?
5. **Cost parameters**: Are slippage (10 cents base) and commission ($5/lot) realistic?

---

## Files to Review Next

For completing remaining work:
1. `nautilus_gold_scalper/src/strategies/base_strategy.py` - Add on_new_day() for Bug #4
2. `nautilus_gold_scalper/src/risk/position_sizer.py` - Verify pip conversion for Bug #6
3. `nautilus_gold_scalper/src/signals/confluence_scorer.py` - Add enforcement for Bug #2
4. `nautilus_gold_scalper/src/strategies/gold_scalper_strategy.py` - Check for hardcoded 65 (Bug #1)

---

**End of Analysis**
