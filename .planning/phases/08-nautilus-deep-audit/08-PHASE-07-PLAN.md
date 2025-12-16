# PLAN: Phase 07 - Test Coverage Analysis

> **Changelog:**
> - 2025-12-16: Applied CRITIC review fixes (C-001 to C-013). Added mock realism audit, temporal correctness checks, HWM + unrealized P/L edge case, quantitative coverage thresholds, pytest --cov baseline, expanded time gates, disabled test detection, fixture audit, and gap remediation framework.

## Objective
Analyze test suite coverage to identify gaps, critical paths untested, and missing edge case coverage. Ensure tests are realistic, temporally correct, and comprehensively cover Apex compliance requirements.

## Coverage Thresholds (Target)

| Metric | Target | Minimum |
|--------|--------|---------|
| Line Coverage | 85% | 70% |
| Branch Coverage | 75% | 60% |
| Critical Path Coverage | 100% | 100% |
| Edge Case Coverage | 90% | 80% |

## Files Under Review

### Test Directory Structure
```
nautilus_gold_scalper/tests/
├── __init__.py
├── test_apex_compliance.py
├── test_holiday_detector.py
├── test_onnx_migration.py
├── test_onnx_simple.py
├── test_spread_monitor.py
├── test_execution/
│   ├── __init__.py
│   ├── test_execution_model.py
│   └── test_trade_manager.py
├── test_indicators/
│   ├── __init__.py
│   ├── test_fibonacci_levels.py
│   ├── test_footprint_analyzer.py
│   ├── test_footprint_analyzer_signal.py
│   ├── test_footprint_configurable.py
│   ├── test_mtf_manager.py
│   ├── test_regime_detector.py
│   ├── test_session_filter.py
│   └── test_smc_detectors.py
├── test_integration/
│   ├── __init__.py
│   ├── test_strategy_flow.py
│   └── test_tick_backtest_e2e.py
├── test_ml/
│   └── __init__.py
├── test_risk/
│   ├── __init__.py
│   ├── test_circuit_breaker_integration.py
│   ├── test_circuit_breaker_levels.py
│   ├── test_consistency_integration.py
│   ├── test_consistency_tracker.py
│   ├── test_dd_protection.py
│   ├── test_drawdown_tracker.py
│   ├── test_position_sizer.py
│   ├── test_prop_firm_manager.py
│   ├── test_prop_firm_manager_apex.py
│   └── test_time_constraint_manager.py
├── test_signals/
│   ├── __init__.py
│   └── test_entry_optimizer_fib.py
├── test_strategies/
│   └── __init__.py
└── test_utils/
    └── test_metrics.py
```

## Execution Plan

### Step 1: Baseline Coverage Measurement
**Run pytest --cov to establish quantitative baseline:**
```bash
pytest --cov=nautilus_gold_scalper --cov-report=term-missing --cov-report=html tests/
```

### Step 2: Analysis Tasks
**1 opus agent** (trading-critical analysis) to:
1. Parse pytest --cov output for line/branch coverage
2. List all test files and map to source modules
3. Identify coverage gaps (uncovered modules, low-coverage modules)
4. Catalog missing edge case tests
5. **Audit mock realism** (slippage, latency, partial fills in mocks)
6. **Check temporal correctness** (no look-ahead / future data leakage in tests)
7. **Detect disabled tests** (pytest.skip, pytest.mark.skip, xfail markers)
8. **Audit fixtures** (conftest.py for hidden complexity)
9. **Check BUGFIX_LOG.md correlation** (fixed bugs lacking regression tests)

## Analysis Framework

### Coverage Mapping

| Source Module | Test File | Coverage Status |
|--------------|-----------|-----------------|
| `gold_scalper_strategy.py` | ? | TBD |
| `base_strategy.py` | ? | TBD |
| `strategy_selector.py` | ? | TBD |
| `amd_cycle_tracker.py` | ? | TBD |
| `footprint_analyzer.py` | `test_footprint_*.py` | TBD |
| `fvg_detector.py` | `test_smc_detectors.py`? | TBD |
| `liquidity_sweep.py` | `test_smc_detectors.py`? | TBD |
| `mtf_manager.py` | `test_mtf_manager.py` | TBD |
| `order_block_detector.py` | `test_smc_detectors.py`? | TBD |
| `regime_detector.py` | `test_regime_detector.py` | TBD |
| `session_filter.py` | `test_session_filter.py` | TBD |
| `structure_analyzer.py` | ? | TBD |
| `circuit_breaker.py` | `test_circuit_breaker_*.py` | TBD |
| `consistency_tracker.py` | `test_consistency_*.py` | TBD |
| `dd_protection.py` | `test_dd_protection.py` | TBD |
| `drawdown_tracker.py` | `test_drawdown_tracker.py` | TBD |
| `position_sizer.py` | `test_position_sizer.py` | TBD |
| `prop_firm_manager.py` | `test_prop_firm_manager*.py` | TBD |
| `spread_monitor.py` | `test_spread_monitor.py` | TBD |
| `time_constraint_manager.py` | `test_time_constraint_manager.py` | TBD |
| `var_calculator.py` | ? | TBD |
| `confluence_scorer.py` | ? | TBD |
| `entry_optimizer.py` | `test_entry_optimizer_fib.py` | TBD |
| `signals/mtf_manager.py` | ? | TBD |
| `news_calendar.py` | ? | TBD |
| `news_trader.py` | ? | TBD |
| `trade_manager.py` | `test_trade_manager.py` | TBD |
| `execution_model.py` | `test_execution_model.py` | TBD |

### Critical Path Coverage

**Must-Have Tests (with specificity):**
| Critical Path | Sub-Path | Tested? |
|--------------|----------|---------|
| Trade entry flow | Signal -> Order -> Fill -> Position tracking | TBD |
| Trade exit flow | SL hit | TBD |
| Trade exit flow | TP hit | TBD |
| Trade exit flow | Manual close | TBD |
| Trade exit flow | Time-based close | TBD |
| Time gate: 4:30 PM ET | Block new trades | TBD |
| Time gate: 4:55 PM ET | Emergency force-close initiation | TBD |
| Time gate: 4:59 PM ET | Hard deadline (all positions must be closed) | TBD |
| DD limit: Daily DD | 1.5% warn -> 2.0% caution -> 2.5% reduce -> 3.0% HALT | TBD |
| DD limit: Total DD | 3.0% warn -> 3.5% caution -> 4.0% caution -> 4.5% HALT | TBD |
| DD limit: Trailing DD | 5% from HWM (includes unrealized P/L) | TBD |
| Circuit breaker activation | Sequential loss triggers | TBD |
| Emergency close | Connection recovery + force liquidation | TBD |
| Multi-day operation | Session reset, HWM carryover | TBD |
| ONNX model | Loading failure handling | TBD |
| Data feed | Interruption recovery | TBD |

### Mock Realism Audit

**Verify mocks simulate realistic conditions:**
| Mock Aspect | Realistic? | Notes |
|-------------|-----------|-------|
| Slippage modeling | TBD | Should use variable slippage, not zero |
| Latency simulation | TBD | Order -> Fill delay |
| Partial fill handling | TBD | Not all orders fill completely |
| Spread variation | TBD | Dynamic spreads during volatility |
| Market depth | TBD | Thin liquidity scenarios |
| Rejection scenarios | TBD | Order rejections, requotes |

### Temporal Correctness Audit

**Verify no look-ahead bias in tests:**
| Check Item | Status |
|------------|--------|
| Tests use only past data for signals | TBD |
| No future data leakage in features | TBD |
| Temporal train/test splits correct | TBD |
| Indicator calculations use available data only | TBD |
| Time-series aware (no shuffling) | TBD |

### Edge Case Coverage

**Must-Have Edge Cases:**
| Edge Case | Tested? | Priority |
|-----------|---------|----------|
| Position at 4:30 PM ET (new trade blocked) | TBD | CRITICAL |
| Position at 4:55 PM ET (force-close initiated) | TBD | CRITICAL |
| Position at 4:59 PM ET (must be closed) | TBD | CRITICAL |
| **HWM updates with unrealized P/L then reverses** | TBD | CRITICAL |
| Gap open against position | TBD | HIGH |
| Partial fill | TBD | HIGH |
| Multiple sequential partial fills | TBD | HIGH |
| Partial fill + timeout scenario | TBD | HIGH |
| Order rejection | TBD | HIGH |
| Spread spike | TBD | HIGH |
| Thin market | TBD | MEDIUM |
| News spike | TBD | MEDIUM |
| Weekend gap | TBD | MEDIUM |
| DST transition (spring forward) | TBD | HIGH |
| DST transition (fall back) | TBD | HIGH |
| Broker time vs system time drift | TBD | MEDIUM |
| DD at exactly 4.5% | TBD | CRITICAL |
| DD at exactly 5.0% | TBD | CRITICAL |
| DD fluctuating across thresholds (enters/exits danger zone) | TBD | HIGH |
| Simultaneous daily DD + total DD limits hit | TBD | HIGH |
| Consistency at 30% | TBD | HIGH |
| Connection loss during open position | TBD | HIGH |
| Slippage beyond stop loss (gap through SL) | TBD | HIGH |
| Order stuck in pending (never fills, never rejects) | TBD | MEDIUM |
| Rapid succession trades (rate limiting) | TBD | MEDIUM |
| Flash crash scenario (massive price movement in ms) | TBD | MEDIUM |
| Position opened at 4:50 PM that cannot close by 4:59 PM | TBD | CRITICAL |
| Simultaneous DD limit and time gate triggers (priority?) | TBD | CRITICAL |

### Inter-Module Integration Tests

**Verify interaction tests exist:**
| Interaction | Tested? |
|-------------|---------|
| DD tracker + Time gate (both trigger simultaneously) | TBD |
| Circuit breaker + DD tracker | TBD |
| Position sizer + DD limits | TBD |
| Time gate + Emergency close | TBD |
| ONNX model + Strategy decision | TBD |

### Disabled Tests Audit

**Check for skipped tests:**
| Marker | Count | Reason Valid? |
|--------|-------|---------------|
| @pytest.skip | TBD | TBD |
| @pytest.mark.skip | TBD | TBD |
| @pytest.mark.xfail | TBD | TBD |
| @pytest.mark.skipif | TBD | TBD |

### Fixture Audit

**Review conftest.py complexity:**
| Item | Status |
|------|--------|
| conftest.py locations identified | TBD |
| Fixtures are appropriately scoped | TBD |
| No hidden state between tests | TBD |
| Mock fixtures are realistic | TBD |

## Questions to Answer

1. **What % line coverage from pytest --cov?** (baseline)
2. **What % of modules have tests?**
3. **What % of critical paths are tested?**
4. **What edge cases are missing?**
5. **Are there integration tests for full flow?**
6. **Are Apex compliance tests comprehensive?**
7. **Is pytest passing currently?**
8. **Are mocks realistic (slippage, latency, partial fills)?**
9. **Is temporal correctness verified (no look-ahead)?**
10. **Are there disabled tests that should run?**
11. **Do fixed bugs in BUGFIX_LOG.md have regression tests?**

## Success Criteria
- [ ] pytest --cov baseline measured
- [ ] Coverage map completed with quantitative data
- [ ] Gap analysis done with severity ratings
- [ ] Mock realism audit completed
- [ ] Temporal correctness audit completed
- [ ] Disabled tests audited
- [ ] Fixture audit completed
- [ ] Missing critical tests identified and prioritized
- [ ] Missing edge cases catalogued and prioritized
- [ ] `PHASE_07_FINDINGS.md` completed

## Agent

**1 opus agent** (trading-critical analysis)
- Full depth analysis required for trading/risk coverage
- Mock realism and temporal correctness require careful review
- Cannot be done adequately with haiku

## Gap Remediation Framework

**When gaps are found, categorize by:**

| Priority | Criteria | Action |
|----------|----------|--------|
| CRITICAL | Apex compliance, DD limits, time gates, HWM | Immediate remediation before any production |
| HIGH | Core trading flow, partial fills, slippage | Remediate in Phase 08 |
| MEDIUM | Edge cases, integration tests | Remediate in Phase 09 |
| LOW | Nice-to-have coverage | Backlog |

**Follow-up Phase:**
- Create `PHASE_07A_REMEDIATION.md` with prioritized test additions
- Estimate effort for each gap
- Assign to subsequent phase work

## Output
`PHASE_07_FINDINGS.md` in this directory containing:
1. Quantitative coverage baseline (pytest --cov results)
2. Coverage map with status
3. Gap analysis with severity ratings
4. Mock realism assessment
5. Temporal correctness assessment
6. Disabled tests list
7. Recommended test additions (prioritized)
8. Remediation effort estimates

---

## CRITIC RE-REVIEW (2025-12-16)

### Previous Issues Status
| ID | Issue | Status |
|----|-------|--------|
| C-001 | Mock realism audit missing | FIXED (lines 147-158) |
| C-002 | Temporal correctness checks missing | FIXED (lines 159-169) |
| C-003 | HWM unrealized P/L edge case missing | FIXED (lines 140, 178) |
| C-004 | Quantitative coverage thresholds missing | FIXED (lines 9-16) |
| C-005 | pytest --cov baseline step missing | FIXED (lines 72-76) |
| C-006 | Time gates incomplete (only 4:59 PM) | FIXED (lines 135-137: 4:30/4:55/4:59) |
| C-007 | Disabled test detection missing | FIXED (lines 86, 215-223) |
| C-008 | Fixture audit missing | FIXED (lines 88, 225-233) |
| C-009 | Gap remediation framework missing | FIXED (lines 268-282) |
| C-010 | BUGFIX_LOG correlation check missing | FIXED (line 89) |
| C-011 | Edge case priorities not specified | FIXED (lines 172-202) |
| C-012 | Inter-module integration tests missing | FIXED (lines 204-213) |
| C-013 | Success criteria incomplete | FIXED (lines 249-259) |

### New Issues Found
None. The plan is comprehensive and covers all critical aspects:
- Apex compliance fully addressed (DD limits, time gates, HWM with unrealized P/L)
- Testing depth adequate (mock realism, temporal correctness, edge cases)
- Execution practical (single opus agent, clear output format)
- Remediation framework provides actionable follow-up path

### Verdict
APPROVED
