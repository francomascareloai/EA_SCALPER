# BRIEF v2: Strategy Simplification & Validation

## Document Context

| Field | Value |
|-------|-------|
| Version | 2.0 |
| Previous | 00-BRIEF.md (v1.0) |
| Date | 2025-12-23 |
| Status | PIVOT - Evidence-Based Scope Reduction |
| Author | DOCS Subagent |
| Reviewed By | ORACLE, FORGE, SENTINEL, CRUCIBLE, ARGUS |

---

## PIVOT NOTICE

**This document supersedes 00-BRIEF.md based on empirical evidence and multi-agent review.**

| Aspect | Original (v1.0) | Revised (v2.0) |
|--------|-----------------|----------------|
| Philosophy | Activate ALL strategies for robustness | Simplify ONE strategy first, validate, then diversify |
| Factors | 9-factor confluence system | 3-4 factor simplified scorer |
| Architecture | StrategySelector (6 gates) + AdaptiveEVRouter (Thompson) | Simple regime filter + session gate |
| Trade Target | Implicit (200+) | Explicit: 200+ in 6 months mandatory |
| Validation | Backtest-only GO/NO-GO | Paper trading 2 weeks mandatory before GO |

**Reason for Pivot:** Empirical evidence (7 trades in 6 months, 8/9 factors scoring 0) demonstrates the current architecture is statistically invalid and over-engineered. Research confirms momentum strategies outperform mean reversion for gold, and 3-4 factors is the optimal confluence count.

---

## Objective

**Simplify and validate a single robust strategy with proven statistical edge before considering multi-strategy diversification.**

### Key Goals

1. Fix semantic collision (Priority 1 blocker)
2. Reduce confluence factors from 9 to 3-4 (remove dead weight)
3. Achieve 200+ trades in 6 months (statistical validity)
4. Validate edge with WFE >= 0.6, SQN >= 2.0, DSR >= 0.80, PBO < 25%
5. Complete 2 weeks paper trading before GO decision

---

## Problem Statement

The current system is fundamentally broken:

### Empirical Evidence (2024-01-01 to 2024-06-30 Backtest)

| Metric | Observed | Required | Gap |
|--------|----------|----------|-----|
| Total Trades | 7 | 200+ | 28x fewer |
| Factor Activation | 1 of 9 | All factors contribute | 8 factors DEAD |
| Net PnL | +$319 (0.6%) | Statistically meaningful | INVALID sample |
| Statistical Power | n=7 | n=200+ | CANNOT compute WFE/SQN |

### Root Causes Identified

1. **Semantic Collision (P0):** Variable `_mtf_order_blocks` overwritten by LTF detection. Confluence scorer receives M5 data thinking it is M15 structural zones. 8 of 9 factors score 0 because they receive wrong data.

2. **Over-Engineering (P1):** 15,000+ lines of code for 7 trades in 6 months. Thompson sampling router in permanent cold-start mode. 6-gate StrategySelector for single functioning strategy.

3. **Invalid Multi-Strategy Architecture (P1):** Multi-strategy diversification requires 200+ trades per strategy to measure correlation. Current 7 trades makes diversification benefits unmeasurable.

4. **Mean Reversion Mismatch (P2):** Gold exhibits positive time series momentum. Research shows mean reversion strategies produce "almost negative returns" for gold. MEAN_REVERT strategy is fundamentally wrong for XAUUSD.

### Agent Consensus

| Agent | Verdict | Key Finding |
|-------|---------|-------------|
| ORACLE | CONDITIONAL | 7 trades is statistically invalid; DSR/PBO missing; no holdout period |
| FORGE | CONDITIONAL | File paths incorrect; bracket_sl_canceled undiagnosed; 3-week timeline |
| SENTINEL | BLOCKED | No paper trading phase; no broker-side SL verification; HWM calculation unverified |
| CRUCIBLE | CONDITIONAL | 9 factors where 8 score 0 is broken, not sophisticated; simplify aggressively |
| ARGUS | BLOCKING | Thompson sampling cannot converge at ~14 trades/year; architecture 100x over-engineered |

---

## Scope

### IN-SCOPE

#### Priority 0 (Blockers)

1. **Fix Semantic Collision**
   - Rename variables: `_mtf_order_blocks` to `_htf_order_blocks`, `_mtf_order_blocks`, `_ltf_order_blocks`
   - Fix OB/FVG detection to use correct timeframe data
   - Verify all factors receive intended data

2. **Achieve Statistical Validity**
   - Target: 200+ trades in 6 months
   - Lower confluence threshold from 35 to 25 (if needed after semantic fix)
   - Add diagnostic logging to understand factor activation rates

3. **Add Holdout Period**
   - Reserve 2021-2025 as TRUE holdout (NEVER optimize on this data)
   - Run all development/ablation on 2003-2020 only
   - Final validation ONLY on holdout

#### Priority 1 (Simplification)

4. **Reduce Factors from 9 to 3-4**
   - KEEP: Structure (BOS/CHoCH) - confirmed working
   - KEEP: Order Blocks - after semantic fix
   - KEEP: Fair Value Gap - after semantic fix
   - KEEP: Session Filter - confirmed working
   - REMOVE: Regime (Hurst) - scoring 0, expensive computation
   - REMOVE: AMD Cycle - scoring 0
   - REMOVE: Fibonacci - scoring 0
   - REMOVE: MTF Alignment - scoring 0, redundant with session
   - REMOVE: Footprint - scoring 0, no futures data

5. **Archive AdaptiveEVRouter**
   - Thompson sampling requires O(ln(T)) samples per arm to converge
   - At ~14 trades/year, convergence would take decades
   - Replace with simple static strategy selection until trade frequency exceeds 200/year

6. **Simplify StrategySelector**
   - Reduce 6 gates to 2: regime filter (trade/no-trade) + session gate
   - Remove complexity not justified by current trade frequency

#### Priority 2 (Validation)

7. **Simple Baseline Comparison**
   - Test: EMA 20/50 crossover + session filter + same risk management
   - This is the BAR that SMC must clear to justify its complexity
   - If baseline wins, archive SMC approach entirely

8. **Add Missing Metrics**
   - DSR (Deflated Sharpe Ratio) >= 0.80 - mandatory for GO/NO-GO
   - PBO (Probability of Backtest Overfitting) < 25% - mandatory for GO/NO-GO
   - MC 5000 runs with block bootstrap (block size = average trade duration)
   - 12-window Walk-Forward (IS: 2 years, OOS: 6 months, purge gap)

9. **Paper Trading Phase**
   - Minimum 2 weeks with live data feed
   - Verify time gates (4:30 PM block, 4:55 PM emergency, 4:59 PM flatten)
   - Verify HWM calculation uses BID/ASK (not MID)
   - MANDATORY before any GO decision (per CLAUDE.md production_workflow)

### OUT-OF-SCOPE (Archive for Later)

| Component | Reason | Recovery Condition |
|-----------|--------|-------------------|
| **AdaptiveEVRouter** | Thompson sampling in permanent cold-start | Trade frequency > 200/year per strategy |
| **MEAN_REVERT Strategy** | Research shows momentum >> mean reversion for gold | Academic evidence of gold mean reversion at M5 |
| **Complex Multi-Strategy** | Cannot measure diversification with < 200 trades | Each strategy validated with 200+ trades |
| **6-Gate StrategySelector** | Over-engineered for single functioning strategy | Multiple validated strategies exist |
| **Footprint Analyzer** | No futures data available | Access to centralized order book data |
| **NEWS_TRADER** | Not applicable to our trading approach | Never |

---

## Success Criteria

### Mandatory (All Must Pass)

| Criterion | Threshold | Rationale |
|-----------|-----------|-----------|
| Trade Frequency | >= 200 in 6 months | Statistical validity minimum |
| WFE (Walk-Forward Efficiency) | >= 0.6 | OOS performance ratio |
| SQN (System Quality Number) | >= 2.0 | Risk-adjusted performance |
| PSR (Probabilistic Sharpe Ratio) | >= 0.85 | Sharpe with confidence |
| **DSR (Deflated Sharpe Ratio)** | >= 0.80 | Multiple testing correction (NEW) |
| **PBO (Probability Backtest Overfitting)** | < 25% | Overfitting probability (NEW) |
| MC95DD (Monte Carlo 95th DD) | < 4% | Apex safety margin |
| Factor Contribution | All 3-4 factors score > 0 | No dead weight |
| Paper Trading | 2 weeks without critical issues | Real-time validation (NEW) |
| Holdout Validation | Edge maintained on 2021-2025 | True OOS confirmation (NEW) |

### Apex Compliance (Non-Negotiable)

| Requirement | Verified By |
|-------------|-------------|
| Trailing DD < 5% from HWM | SENTINEL |
| Daily DD < 3% halt | SENTINEL |
| Close all positions by 4:59 PM ET | Time gate tests |
| Block new trades after 4:30 PM ET | Time gate tests |
| Emergency close from 4:55 PM ET | Time gate tests |
| HWM uses BID/ASK not MID | HWM calculation tests |
| Broker-side SL as backup | Integration verification |

---

## Deliverables

### Phase 00 Outputs (Simplification Sprint)

| Deliverable | Location | Status |
|-------------|----------|--------|
| SEMANTIC_COLLISION_FIX.md | orchestration/ | Pending |
| SIMPLIFICATION_PLAN.md | orchestration/ | Pending (NEW) |
| ABLATION_RESULTS.md | orchestration/ | Pending |
| BASELINE_COMPARISON.md | orchestration/ | Pending (NEW) |
| ARCHITECTURE_SIMPLIFIED.md | DOCS/ | Pending |

### Validation Outputs

| Deliverable | Location | Status |
|-------------|----------|--------|
| SMC_SIMPLIFIED_BACKTEST.md | orchestration/ | Pending |
| DSR_PBO_ANALYSIS.md | orchestration/ | Pending (NEW) |
| HOLDOUT_VALIDATION.md | orchestration/ | Pending (NEW) |
| PAPER_TRADING_LOG.md | orchestration/ | Pending (NEW) |
| FINAL_GO_NOGO.md | orchestration/ | Pending |

### Code Changes

| Change | Files Affected | Status |
|--------|----------------|--------|
| Semantic collision fix | confluence_scorer.py, signals/ | Pending |
| Factor reduction (9 to 3-4) | confluence_scorer.py | Pending |
| Archive AdaptiveEVRouter | adaptive_router.py | Pending (NEW) |
| Simplify StrategySelector | strategy_selector.py | Pending (NEW) |
| Archive footprint | footprint_analyzer.py | Pending |
| Remove MEAN_REVERT enum | strategy_types.py | Pending (NEW) |

---

## Constraints

### Technical

| Constraint | Limit | Enforcement |
|------------|-------|-------------|
| On-tick latency | < 50ms | Block deploy if exceeded |
| Test coverage (line) | >= 70% | Block GO if below |
| Test coverage (branch) | >= 50% | Block GO if below |
| Performance budget (ONNX) | < 5ms | Block if exceeded |

### Methodology

| Constraint | Rule | Rationale |
|------------|------|-----------|
| No complex multi-strategy | Until trade frequency supports it | Cannot measure diversification |
| Holdout period sacred | 2021-2025 NEVER used for optimization | Prevent data leakage |
| Paper trading mandatory | 2 weeks minimum before GO | Real-time validation |
| Factor simplicity | 3-4 factors maximum | Overfitting protection |

### Data

| Constraint | Specification |
|------------|---------------|
| Dataset | xauusd_2003_2025_stride20_full.parquet |
| Development period | 2003-2020 |
| Holdout period | 2021-2025 |
| Minimum sample | 200+ trades for any statistical claim |

---

## Timeline (Revised)

### Phase 00: Simplification Sprint (3 weeks)

| Week | Focus | Key Deliverables |
|------|-------|------------------|
| 1 | Semantic collision fix + Diagnostic logging | SEMANTIC_COLLISION_FIX.md |
| 2 | Ablation study + Factor reduction | ABLATION_RESULTS.md, SIMPLIFICATION_PLAN.md |
| 3 | Baseline comparison + Documentation | BASELINE_COMPARISON.md, ARCHITECTURE_SIMPLIFIED.md |

### Phase 01-02: Single Strategy Validation (2-3 weeks)

- SMC Simplified OR TrendFollow (whichever produces 200+ trades first)
- Full WFE/SQN/PSR/DSR/PBO validation
- Holdout period confirmation

### Phase 03: Paper Trading (2 weeks minimum)

- Live data feed, no real money
- Time gate verification
- HWM/DD tracking verification
- SENTINEL formal sign-off

### Phase 04: Production Decision (1 week)

- External CRITIC review
- SENTINEL final approval
- GO/NO-GO for smallest account ($50k)

**Total: 8-10 weeks (vs original 6-8 weeks)**

---

## Decision Points

### Gate 1: Post-Ablation (End of Week 2)

**Question:** Which factors contribute?

| Outcome | Action |
|---------|--------|
| 3-4 factors contribute | Proceed with simplified scorer |
| Only structure contributes | Simplify to structure + session only |
| No factors contribute | HALT - investigate fundamental approach |

### Gate 2: Baseline Comparison (End of Week 3)

**Question:** Does SMC beat simple EMA crossover?

| Outcome | Action |
|---------|--------|
| SMC > baseline by 20%+ | Proceed with SMC |
| SMC ~ baseline | Archive SMC, use simpler approach |
| SMC < baseline | HALT - abandon SMC, focus on TrendFollow |

### Gate 3: Trade Frequency (Post-Semantic Fix)

**Question:** Does system produce 200+ trades in 6 months?

| Outcome | Action |
|---------|--------|
| >= 200 trades | Proceed to validation |
| 50-200 trades | Adjust threshold, retest |
| < 50 trades | HALT - fundamental architecture problem |

### Gate 4: Holdout Validation

**Question:** Does edge persist on 2021-2025?

| Outcome | Action |
|---------|--------|
| Edge maintained (WFE >= 0.5) | Proceed to paper trading |
| Edge degraded (WFE 0.3-0.5) | Investigate regime shift, conditional proceed |
| Edge gone (WFE < 0.3) | HALT - likely overfitted |

### Gate 5: Paper Trading (End of 2 weeks)

**Question:** Does system work in real-time?

| Outcome | Action |
|---------|--------|
| No critical issues | SENTINEL sign-off, proceed to GO decision |
| Time gate issues | Fix and restart paper trading |
| HWM/DD issues | HALT - critical risk failure |

---

## Risk Assessment

### High Risks

| Risk | Probability | Impact | Mitigation |
|------|-------------|--------|------------|
| SMC approach is fundamentally flawed for M5 gold | MEDIUM | HIGH | Baseline comparison gate; TrendFollow fallback |
| Semantic collision fix does not restore factors | LOW | HIGH | Diagnostic logging before/after; rollback checkpoint |
| Trade frequency remains insufficient | MEDIUM | HIGH | Threshold adjustment; factor activation analysis |

### Medium Risks

| Risk | Probability | Impact | Mitigation |
|------|-------------|--------|------------|
| 3-week timeline extends | HIGH | MEDIUM | 50% buffer already included |
| Holdout period shows edge degradation | MEDIUM | MEDIUM | Regime analysis; recency weighting |
| Paper trading reveals time gate issues | LOW | MEDIUM | Extensive unit tests before paper trading |

### Low Risks

| Risk | Probability | Impact | Mitigation |
|------|-------------|--------|------------|
| EMA baseline outperforms SMC | LOW | LOW | Use simpler approach (not a bad outcome) |
| Footprint data becomes available | VERY LOW | LOW | Factor can be restored from archive |

---

## Exit Criteria

**Conditions under which we abandon the SMC approach entirely:**

1. Post-ablation: Structure is the only contributing factor AND structure alone < EMA baseline
2. Post-semantic-fix: Trade frequency remains < 50 in 6 months
3. Post-holdout: WFE < 0.3 on 2021-2025 period
4. Post-baseline: Simple EMA crossover outperforms SMC by > 20%

**Fallback Strategy:** TrendFollow (simpler, ~200 lines, expected 100+ trades)

---

## Owner

**Franco**

---

## Status

**READY FOR EXECUTION** - Pending user approval of scope changes

---

## References

### Planning Documents

- 00-BRIEF.md (superseded by this document)
- 01-ROADMAP.md (contains all agent reviews)
- 02-CRITICAL_ISSUES_AUDIT.md (34 issues detailed)
- 03-PRE_ACTIVATION_CHECKLIST.md (Phase 00 tasks)
- 04-EXECUTIVE_SUMMARY.md (decision document)

### Agent Reviews (in 01-ROADMAP.md)

- ORACLE Critical Review: Validation methodology gaps
- FORGE Critical Review: Implementation feasibility
- SENTINEL Critical Review: Apex compliance gaps
- CRUCIBLE Critical Review: Strategy philosophy
- ARGUS Research: Multi-strategy systems (12 sources)
- ARGUS Research: SMC & Gold trading (27 sources)

### Research Sources

- Thompson Sampling Convergence: Stanford Tutorial on TS
- Gold Momentum vs Mean Reversion: arxiv.org/abs/2511.08571
- Optimal Confluence Count: ColibritTrader, LiteFinance
- FTMO Gold Strategies: FTMO Blog case studies

---

## Changelog

| Version | Date | Changes |
|---------|------|---------|
| 2.0 | 2025-12-23 | PIVOT: Simplification-first approach; Added DSR/PBO; Holdout period; Paper trading mandatory; Archive AdaptiveEVRouter/MEAN_REVERT; Reduce factors 9 to 3-4; Baseline comparison gate |
| 1.0 | 2025-12-23 | Initial brief - Multi-strategy activation |
