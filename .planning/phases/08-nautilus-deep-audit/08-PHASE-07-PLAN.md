# PLAN: Phase 07 - Test Coverage Analysis

## Objective
Analyze test suite coverage to identify gaps, critical paths untested, and missing edge case coverage.

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

### Agent Assignment
**1 haiku agent** (lightweight analysis) to:
1. List all test files
2. Map tests to source modules
3. Identify coverage gaps
4. Catalog missing edge case tests

## Analysis Framework

### Coverage Mapping

| Source Module | Test File | Coverage Status |
|--------------|-----------|-----------------|
| `gold_scalper_strategy.py` | ? | ⬜ |
| `base_strategy.py` | ? | ⬜ |
| `strategy_selector.py` | ? | ⬜ |
| `amd_cycle_tracker.py` | ? | ⬜ |
| `footprint_analyzer.py` | `test_footprint_*.py` | ⬜ |
| `fvg_detector.py` | `test_smc_detectors.py`? | ⬜ |
| `liquidity_sweep.py` | `test_smc_detectors.py`? | ⬜ |
| `mtf_manager.py` | `test_mtf_manager.py` | ⬜ |
| `order_block_detector.py` | `test_smc_detectors.py`? | ⬜ |
| `regime_detector.py` | `test_regime_detector.py` | ⬜ |
| `session_filter.py` | `test_session_filter.py` | ⬜ |
| `structure_analyzer.py` | ? | ⬜ |
| `circuit_breaker.py` | `test_circuit_breaker_*.py` | ⬜ |
| `consistency_tracker.py` | `test_consistency_*.py` | ⬜ |
| `dd_protection.py` | `test_dd_protection.py` | ⬜ |
| `drawdown_tracker.py` | `test_drawdown_tracker.py` | ⬜ |
| `position_sizer.py` | `test_position_sizer.py` | ⬜ |
| `prop_firm_manager.py` | `test_prop_firm_manager*.py` | ⬜ |
| `spread_monitor.py` | `test_spread_monitor.py` | ⬜ |
| `time_constraint_manager.py` | `test_time_constraint_manager.py` | ⬜ |
| `var_calculator.py` | ? | ⬜ |
| `confluence_scorer.py` | ? | ⬜ |
| `entry_optimizer.py` | `test_entry_optimizer_fib.py` | ⬜ |
| `signals/mtf_manager.py` | ? | ⬜ |
| `news_calendar.py` | ? | ⬜ |
| `news_trader.py` | ? | ⬜ |
| `trade_manager.py` | `test_trade_manager.py` | ⬜ |
| `execution_model.py` | `test_execution_model.py` | ⬜ |

### Critical Path Coverage

**Must-Have Tests:**
| Critical Path | Tested? |
|--------------|---------|
| Trade entry flow | ⬜ |
| Trade exit flow | ⬜ |
| SL/TP hit | ⬜ |
| DD limit trigger | ⬜ |
| Time gate trigger | ⬜ |
| Circuit breaker activation | ⬜ |
| Emergency close | ⬜ |
| Multi-day operation | ⬜ |

### Edge Case Coverage

**Must-Have Edge Cases:**
| Edge Case | Tested? |
|-----------|---------|
| Position at 4:59 PM ET | ⬜ |
| Gap open against position | ⬜ |
| Partial fill | ⬜ |
| Order rejection | ⬜ |
| Spread spike | ⬜ |
| Thin market | ⬜ |
| News spike | ⬜ |
| Weekend gap | ⬜ |
| DST transition | ⬜ |
| DD at exactly 4.5% | ⬜ |
| DD at exactly 5.0% | ⬜ |
| Consistency at 30% | ⬜ |

## Questions to Answer

1. **What % of modules have tests?**
2. **What % of critical paths are tested?**
3. **What edge cases are missing?**
4. **Are there integration tests for full flow?**
5. **Are Apex compliance tests comprehensive?**
6. **Is pytest passing currently?**

## Success Criteria
- [ ] Coverage map completed
- [ ] Gap analysis done
- [ ] Missing critical tests identified
- [ ] Missing edge cases catalogued
- [ ] `PHASE_07_FINDINGS.md` completed

## Agent

**1 haiku agent**
- Lightweight coverage analysis
- Focus on gap identification
- No deep code review (done in other phases)

## Output
`PHASE_07_FINDINGS.md` in this directory
