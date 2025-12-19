# ROADMAP: Deep Audit - Nautilus Strategies & Infrastructure (v2.0)

## Changelog
- v2.0: Added Phase 00, Phase 04.5, reduced parallel agents, added output protocol
- v2.1: Phase 00 COMPLETE (2025-12-16) - Foundation verified, all thresholds match

## Progress
- **Phases Completed:** 4/11
- **Current Phase:** Phase 04

## Phase Overview

| Phase | Focus | Agents | Rounds | Priority | Status |
|-------|-------|--------|--------|----------|--------|
| 00 | Foundation Verification | 1 | 1 | P0 - BLOCKER | COMPLETE |
| 01 | Core Strategy Audit | 1-2 | 1 | P0 - CRITICAL | COMPLETE (BLOCKED) |
| 02 | Indicators SMC Audit | 2+2 | 2 | P0 - CRITICAL | COMPLETE (R0+R1+R2) |
| 03 | Risk Modules Audit | 2+1 | 2 | P0 - CRITICAL | COMPLETE (REMEDIATED + R2) |
| 04 | Signal Generators Audit | 2 | 1 | P1 - HIGH | PENDING |
| 04.5 | ML Pipeline Audit | 1 | 1 | P0 - CRITICAL | PENDING |
| 05 | Execution Layer Audit | 2 | 1 | P1 - HIGH | PENDING |
| 06 | Backtest Scripts Audit | 2+2 | 2 | P1 - HIGH | PENDING |
| 07 | Test Coverage Analysis | 1 | 1 | P2 - MEDIUM | PENDING |
| 08 | Integration Points Audit | 2 | 1 | P1 - HIGH | PENDING |
| 09 | Final Synthesis | 1 | 1 | P0 - CRITICAL | PENDING |

**Total Agents:** ~18 (reduced from 21)
**Max Parallel:** 2-3 per round (CLAUDE.md compliant)

---

## Phase 00: Foundation Verification (NEW - BLOCKER)

**Files:**
- `src/core/definitions.py` - Thresholds, Apex constants
- `src/core/data_types.py` - Data structures
- `src/core/exceptions.py` - Custom exceptions

**Tasks:**
1. Create git tag `audit-baseline-YYYYMMDD`
2. Run pytest baseline
3. Verify ALL thresholds against CLAUDE.md
4. Count lines for scope verification
5. Create orchestration/ directory

**Agent:** 1 opus
**Blocking:** If definitions don't match CLAUDE.md, STOP audit

---

## Phase 01: Core Strategy Audit

**Files (~1,400 lines):**
- `gold_scalper_strategy.py`
- `base_strategy.py`
- `strategy_selector.py`

**CRITIC Focus:**
- Apex compliance (5 rules)
- Look-ahead bias
- Performance budget
- Position lifecycle

**Agent:** 1 FORGE (opus)

---

## Phase 02: Indicators SMC Audit (SPLIT INTO 2 ROUNDS)

**Files (~4,100 lines):**

### Round 1 (2 agents parallel)
**Agent A:** `regime_detector.py` + `session_filter.py` + `amd_cycle_tracker.py` (~860 lines)
**Agent B:** `order_block_detector.py` + `fvg_detector.py` (~1,179 lines)

### Round 2 (2 agents parallel)
**Agent C:** `liquidity_sweep.py` + `structure_analyzer.py` (~1,232 lines)
**Agent D:** `footprint_analyzer.py` + `mtf_manager.py` (~1,120 lines)

**Checkpoint between rounds**

**CRITIC Focus:**
- SMC logic correctness
- Look-ahead bias (temporal verification method)
- Edge cases

**Agents:** 2+2 FORGE (opus)

---

## Phase 03: Risk Modules Audit (SPLIT INTO 2 ROUNDS)

**Files (~2,989 lines):**

### Round 1 (2 agents parallel)
**Agent A:** `drawdown_tracker.py` + `dd_protection.py` + `prop_firm_manager.py` (~935 lines)
**Agent B:** `circuit_breaker.py` + `time_constraint_manager.py` (~648 lines)

### Round 2 (1 agent)
**Agent C:** `position_sizer.py` + `spread_monitor.py` + `var_calculator.py` + `consistency_tracker.py` (~1,330 lines)

**Checkpoint between rounds**

**CRITIC Focus:**
- Apex compliance verification (all 5 rules)
- Trailing DD from HIGH-WATER MARK
- Time gate enforcement

**Agents:** 2+1 SENTINEL (opus)

---

## Phase 04: Signal Generators Audit

**Files (~3,450 lines):**
- `confluence_scorer.py` (1002 lines)
- `entry_optimizer.py` (699 lines)
- `mtf_manager.py` (395 lines)
- `news_calendar.py` (628 lines)
- `news_trader.py` (688 lines)

**Agent A:** `confluence_scorer.py` + `mtf_manager.py` (~1,397 lines)
**Agent B:** `entry_optimizer.py` + `news_calendar.py` + `news_trader.py` (~2,015 lines)

**CRITIC Focus:**
- Scoring thresholds match CLAUDE.md
- Look-ahead in news data
- MTF temporal alignment

**Agents:** 2 CRUCIBLE (opus)

---

## Phase 04.5: ML Pipeline Audit (NEW - CRITICAL)

**Files (~500 lines):**
- `src/ml/feature_engineering.py`
- `src/ml/ensemble_predictor.py`
- `src/ml/model_trainer.py`

**Why Critical:**
ML is the #1 look-ahead danger zone. Features calculated from future data = instant failure.

**CRITIC Focus:**
- Feature engineering temporal integrity
- No future data in training
- Inference uses only past data

**Agent:** 1 FORGE (opus) with exhaustive temporal trace

---

## Phase 05: Execution Layer Audit

**Files (~908 lines):**
- `trade_manager.py` (633 lines)
- `base_adapter.py` (128 lines)
- `execution_model.py` (42 lines)
- `mt5_adapter.py` (44 lines)
- `ninjatrader_adapter.py` (42 lines)

**Also include:**
- `src/context/holiday_detector.py` (~100 lines)

**Agent A:** `trade_manager.py` + `execution_model.py` (~675 lines)
**Agent B:** Adapters + `holiday_detector.py` (~314 lines)

**CRITIC Focus:**
- Order lifecycle
- Slippage realism
- Holiday handling

**Agents:** 2 FORGE (opus)

---

## Phase 06: Backtest Scripts Audit (SPLIT INTO 2 ROUNDS)

**Files (~10,000+ lines):**

### Round 1 (2 agents parallel) - Core Strategies
**Agent A:** `ea_logic_full.py` (2696 lines)
**Agent B:** `ea_logic_python.py` + `adaptive_kelly.py` + `ea_logic_compat.py` (~1,558 lines)

### Round 2 (2 agents parallel) - Validation Scripts
**Agent C:** `fibonacci_analyzer.py` + `spread_analyzer.py` (~990 lines)
**Agent D:** `monte_carlo_degradation.py` + `wfa_filter_study.py` + `realistic_backtester.py`

**Checkpoint between rounds**

**CRITIC Focus:**
- Consistency with main strategy
- Data leakage detection
- Monte Carlo correctness
- Walk-forward correctness

**Agents:** 2+2 general-purpose (opus)

---

## Phase 07: Test Coverage Analysis

**Files:** `nautilus_gold_scalper/tests/` (all)

**Focus:**
- Coverage gaps
- Critical paths untested
- Edge case coverage

**Agent:** 1 general-purpose (opus) ← UPGRADED from haiku

---

## Phase 08: Integration Points Audit

**Focus:**
- Strategy ↔ Risk integration
- Indicator ↔ Strategy data flow
- Signal ↔ Execution handoff
- Time synchronization

**Agent A:** Strategy-Risk-Execution flow
**Agent B:** Indicator-Signal-Strategy flow

**Agents:** 2 NAUTILUS (opus)

---

## Phase 09: Final Synthesis

**Inputs:** All PHASE_XX_FINDINGS.md files

**Deliverables:**
1. `AUDIT_REPORT.md` - Master findings
2. `ISSUES_TRACKER.md` - All issues
3. `RECOMMENDATIONS.md` - Prioritized actions
4. GO/NO-GO decision

**Agent:** 1 DAEMON (opus)

---

## Execution Order

```
Phase 00 (Foundation) ← BLOCKER
    ↓
Phase 01 (Core Strategy)
    ↓
Phase 02 Round 1 (Indicators A,B)
    ↓ checkpoint
Phase 02 Round 2 (Indicators C,D)
    ↓
Phase 03 Round 1 (Risk A,B)
    ↓ checkpoint
Phase 03 Round 2 (Risk C)
    ↓
Phase 04 (Signals) + Phase 04.5 (ML) ← can run parallel
    ↓
Phase 05 (Execution)
    ↓
Phase 06 Round 1 (Backtest A,B)
    ↓ checkpoint
Phase 06 Round 2 (Backtest C,D)
    ↓
Phase 07 (Test Coverage)
    ↓
Phase 08 (Integration)
    ↓
Phase 09 (Synthesis)
```

---

## Checkpoint Protocol

After each phase/round:
1. Write findings to `orchestration/PHASE_XX_FINDINGS.md`
2. Create brief summary (≤300 words) in chat
3. If context heavy, consider fresh conversation for next phase
4. Update MANIFEST.md
