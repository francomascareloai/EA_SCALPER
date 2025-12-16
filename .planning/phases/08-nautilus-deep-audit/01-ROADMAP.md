# ROADMAP: Deep Audit - Nautilus Strategies & Infrastructure

## Phase Overview

| Phase | Focus | Est. Agents | Priority |
|-------|-------|-------------|----------|
| 01 | Core Strategy Audit | 2 (FORGE + CRITIC) | P0 - CRITICAL |
| 02 | Indicators SMC Audit | 3-4 parallel | P0 - CRITICAL |
| 03 | Risk Modules Audit | 2-3 parallel | P0 - CRITICAL |
| 04 | Signal Generators Audit | 2 parallel | P1 - HIGH |
| 05 | Execution Layer Audit | 2 parallel | P1 - HIGH |
| 06 | Backtest Scripts Audit | 4-5 parallel | P1 - HIGH |
| 07 | Test Coverage Analysis | 1 (haiku) | P2 - MEDIUM |
| 08 | Integration Points Audit | 2 parallel | P1 - HIGH |
| 09 | Final Synthesis | 1 (opus) | P0 - CRITICAL |

---

## Phase 01: Core Strategy Audit

**Files:**
- `gold_scalper_strategy.py` (~800 lines)
- `base_strategy.py` (~600 lines)
- `strategy_selector.py` (~200 lines)

**CRITIC Focus:**
- Apex compliance (trailing DD, time gates, overnight)
- Look-ahead bias in signal generation
- on_bar/on_tick performance
- Position lifecycle management
- Edge cases (partial fills, rejections, gaps)

**Agents:** FORGE (analysis) → CRITIC (self-review)

---

## Phase 02: Indicators SMC Audit

**Files (8 modules, ~4,100 lines):**
- `amd_cycle_tracker.py` - AMD cycle detection
- `footprint_analyzer.py` - Order flow analysis
- `fvg_detector.py` - Fair Value Gap detection
- `liquidity_sweep.py` - Liquidity hunt detection
- `mtf_manager.py` - Multi-timeframe management
- `order_block_detector.py` - OB detection
- `regime_detector.py` - Market regime classification
- `session_filter.py` - Trading session filtering
- `structure_analyzer.py` - Market structure analysis

**CRITIC Focus:**
- SMC logic correctness (OB, FVG, liquidity rules)
- Look-ahead bias (using future bars?)
- Temporal alignment across timeframes
- Edge cases (thin markets, news spikes)
- Performance (vectorized vs loop?)

**Agents:** 4 parallel FORGE agents, each with CRITIC self-review

---

## Phase 03: Risk Modules Audit

**Files (9 modules, ~2,989 lines):**
- `circuit_breaker.py` - Loss limits & cooldowns
- `consistency_tracker.py` - 30% rule tracking
- `dd_protection.py` - Drawdown protection
- `drawdown_tracker.py` - DD calculation
- `position_sizer.py` - Lot sizing
- `prop_firm_manager.py` - Apex rules enforcement
- `spread_monitor.py` - Spread tracking
- `time_constraint_manager.py` - Time gates
- `var_calculator.py` - Value at Risk

**CRITIC Focus:**
- Apex rule encoding accuracy
- Trailing DD from HIGH-WATER MARK (not static)
- Time gate enforcement (4:30 PM warning, 4:55 PM emergency)
- Circuit breaker escalation logic
- Edge cases (overnight positions, gap opens)

**Agents:** 3 parallel SENTINEL agents, each with CRITIC self-review

---

## Phase 04: Signal Generators Audit

**Files (5 modules, ~3,450 lines):**
- `confluence_scorer.py` - Score aggregation (1002 lines!)
- `entry_optimizer.py` - Entry optimization
- `mtf_manager.py` - MTF signal management
- `news_calendar.py` - News event handling
- `news_trader.py` - News-based signals

**CRITIC Focus:**
- Scoring logic (thresholds match CLAUDE.md?)
- MTF confluence correctness
- News filter implementation
- Look-ahead in news data
- Score inflation/deflation patterns

**Agents:** 2 parallel CRUCIBLE agents, each with CRITIC self-review

---

## Phase 05: Execution Layer Audit

**Files (5 modules, ~908 lines):**
- `base_adapter.py` - Base execution adapter
- `execution_model.py` - Execution cost model
- `mt5_adapter.py` - MT5 integration
- `ninjatrader_adapter.py` - NinjaTrader integration
- `trade_manager.py` - Trade lifecycle management

**CRITIC Focus:**
- Slippage modeling accuracy
- Commission calculations
- Partial fill handling
- Order lifecycle state machine
- Integration completeness

**Agents:** 2 parallel FORGE agents, each with CRITIC self-review

---

## Phase 06: Backtest Scripts Audit

**Files (50+ scripts, ~10,000+ lines):**
- `scripts/backtest/strategies/` - Strategy implementations
- `scripts/backtest/*.py` - Various backtest runners
- Key files:
  - `ea_logic_full.py` (2696 lines!)
  - `ea_logic_python.py` (704 lines)
  - `adaptive_kelly.py` (541 lines)
  - `fibonacci_analyzer.py` (539 lines)

**CRITIC Focus:**
- Consistency with main strategy logic
- Data leakage in backtest setup
- Realistic slippage/spread modeling
- Walk-forward validation correctness
- Monte Carlo implementation

**Agents:** 5 parallel general-purpose agents, each with CRITIC self-review

---

## Phase 07: Test Coverage Analysis

**Files:** `nautilus_gold_scalper/tests/` (all)

**Focus:**
- Coverage gaps
- Critical paths untested
- Edge case coverage
- Integration test completeness

**Agent:** 1 haiku agent (lightweight analysis)

---

## Phase 08: Integration Points Audit

**Focus:**
- Strategy ↔ Risk module integration
- Indicator ↔ Strategy data flow
- Signal ↔ Execution handoff
- Time synchronization across modules
- State consistency

**Agents:** 2 parallel NAUTILUS agents, each with CRITIC self-review

---

## Phase 09: Final Synthesis

**Deliverables:**
1. `AUDIT_REPORT.md` - Complete findings
2. `ISSUES_TRACKER.md` - All issues with severity
3. `RECOMMENDATIONS.md` - Prioritized improvements
4. GO/NO-GO recommendation for current codebase

**Agent:** 1 opus agent (DAEMON) for strategic synthesis

---

## Execution Notes

1. **CRITIC is mandatory** at each phase - no exceptions
2. **Parallel execution** allowed within phases
3. **Sequential between phases** for dependency management
4. **Checkpoint summaries** required after each phase
5. **All issues** tracked in ISSUES_TRACKER.md
