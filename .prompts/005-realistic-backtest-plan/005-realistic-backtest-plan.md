# PROMPT 005: Realistic Backtest Validation Plan

## Objective

**Create comprehensive plan** for realistic backtest validation of all strategies after audits are complete:
- Define test scenarios (normal, stress, edge cases)
- Specify metrics and success criteria
- Establish WFA (Walk-Forward Analysis) protocol
- Define Monte Carlo simulation parameters
- Create GO/NO-GO decision framework
- Plan iterative testing workflow

**Why it matters**: After fixing issues found in audits, need systematic validation to prove strategies are ready for live Apex trading. Must test under realistic conditions before risking capital.

---

## Context

**Dependencies** (MUST READ FIRST):
- @.prompts/001-nautilus-plan-refine/nautilus-plan-audit.md (module status)
- @.prompts/002-backtest-data-research/backtest-data-research.md (data source recommendation)
- @.prompts/003-backtest-code-audit/backtest-code-audit.md (bugs/gaps to fix)
- @.prompts/004-apex-risk-audit/apex-risk-audit.md (Apex compliance status)

**Current state**: Based on audit findings, create validation plan AFTER fixes applied

**Target**: All strategies in `nautilus_gold_scalper/src/strategies/`

**Constraints**:
- Apex Trading compliance required
- Realistic execution modeling (slippage, spreads, fills)
- 5+ years historical data
- WFA mandatory (no in-sample only)
- Monte Carlo for robustness testing

**Dynamic context**:
- !`ls nautilus_gold_scalper/src/strategies/*.py` (strategies to test)
- !`find data/ -name "*.parquet" 2>/dev/null` (available data)

---

## Requirements

### 1. Test Scenarios Definition

**Scenario types**:

#### Normal Market Conditions
- Trending markets (bull/bear)
- Range-bound markets
- Normal volatility (ATR 20-40 for XAUUSD)
- Typical spreads (15-25 cents)
- Regular session hours (London/NY overlap)

#### Stress Conditions
- High volatility (ATR >60, e.g., March 2020 COVID)
- Wide spreads (>50 cents, e.g., low liquidity)
- Gap events (Sunday opens, FOMC)
- Holiday thin markets
- Flash crashes (if in data)

#### Edge Cases
- Regime transitions (trending → ranging)
- Consecutive losses (5+ in row)
- Long win streaks (test for overconfidence)
- Near DD limit scenarios (test circuit breaker)
- End-of-day forced closure (4:59 PM ET)

**For EACH scenario**:
- Date ranges (specific periods from 5-year data)
- Expected behavior (what should strategy do?)
- Success metrics (what "passing" looks like)

### 2. Metrics & Success Criteria

**Core metrics**:
| Metric | Target | Minimum | Blocker |
|--------|--------|---------|---------|
| Sharpe Ratio | >2.0 | >1.5 | <1.0 |
| Sortino Ratio | >3.0 | >2.0 | <1.5 |
| Calmar Ratio | >3.0 | >2.0 | <1.0 |
| Max Drawdown % | <8% | <10% | >10% |
| Win Rate % | >55% | >50% | <45% |
| Profit Factor | >2.0 | >1.5 | <1.2 |
| SQN (System Quality Number) | >3.0 | >2.0 | <1.5 |
| Expectancy ($/trade) | >$50 | >$25 | <$10 |

**Apex-specific**:
| Metric | Target | Blocker |
|--------|--------|---------|
| Trailing DD breaches | 0 | >0 (fail) |
| Post-4:59 PM trades | 0 | >0 (fail) |
| Consistency rule violations | 0 | >0 (fail) |
| Max risk/trade exceeded | 0 | >0 (fail) |

**Realism checks**:
- Avg slippage: 5-15 cents (realistic for XAUUSD)
- Avg spread paid: 15-30 cents (realistic bid/ask)
- Fill rate: 95-98% (some rejections expected)
- Avg trade duration: Consistent with strategy type (scalper <1hr)

### 3. Walk-Forward Analysis Protocol

**WFA parameters**:
- **In-sample period**: 6 months (training)
- **Out-of-sample period**: 3 months (testing)
- **Step size**: 3 months (overlap allowed)
- **Total folds**: ~15-20 folds (for 5 years)
- **Optimization**: Grid search or Bayesian (if params tuned)

**WFE (Walk-Forward Efficiency)**:
```
WFE = Out-of-sample_performance / In-sample_performance
Target: WFE >= 0.6 (60% of in-sample performance maintained)
Minimum: WFE >= 0.5
Blocker: WFE < 0.4 (severe overfitting)
```

**Procedure**:
1. Split data into folds
2. For each fold:
   - Train on in-sample (if applicable)
   - Test on out-of-sample
   - Record metrics
3. Aggregate results
4. Calculate WFE
5. Check for degradation over time (drift)

### 4. Monte Carlo Simulation

**Purpose**: Test robustness to random variations

**Parameters**:
- **Runs**: 10,000 simulations
- **Method**: Bootstrap resampling of trades
- **Variations**: Random entry/exit timing, slippage, spreads

**Metrics to extract**:
- **95th percentile DD**: Must be <8% for Apex safety
- **Probability of ruin**: Must be <1% (P(DD>10%) < 0.01)
- **Confidence interval**: 95% CI for Sharpe, profit, etc.

**Success criteria**:
- 95th percentile DD < 8%: PASS
- 95th percentile DD 8-10%: CONDITIONAL (risky)
- 95th percentile DD > 10%: FAIL (unacceptable for Apex)

### 5. GO/NO-GO Decision Framework

**Decision tree**:
```
IF all audits (001-004) pass:
  IF core metrics >= Minimum:
    IF Apex metrics == 0 violations:
      IF WFE >= 0.5:
        IF Monte Carlo 95th DD < 8%:
          → GO (approve for paper trading)
        ELSE:
          → NO-GO (DD risk too high)
      ELSE:
        → NO-GO (overfitting detected)
    ELSE:
      → NO-GO (Apex violations)
  ELSE:
    → NO-GO (poor performance)
ELSE:
  → NO-GO (fix audit issues first)
```

**Paper trading phase**:
- Duration: 1 month
- Conditions: Same as live (Apex rules enforced)
- Success: Replicate backtest metrics (within 20%)
- Only then: Approve live trading

### 6. Testing Workflow

**Phase 1: Fix Issues** (from audits 001-004)
1. Fix P0 bugs (blockers)
2. Fix P1 issues (important)
3. Re-run audits to verify

**Phase 2: Data Preparation**
1. Download/validate data (per audit 002 recommendation)
2. Clean and preprocess
3. Split into WFA folds
4. Validate completeness (no gaps)

**Phase 3: Baseline Backtest**
1. Run single full backtest (all 5 years)
2. Check core metrics
3. Identify issues
4. If fails: Fix and repeat

**Phase 4: WFA**
1. Run WFA protocol (15-20 folds)
2. Calculate WFE
3. Check for drift
4. If fails: Investigate overfitting

**Phase 5: Monte Carlo**
1. Run 10k simulations
2. Extract 95th percentile DD
3. Check probability of ruin
4. If fails: Reduce risk or improve strategy

**Phase 6: GO/NO-GO**
1. Apply decision framework
2. Document verdict with evidence
3. If GO: Plan paper trading
4. If NO-GO: Document blockers and next steps

**Phase 7: Paper Trading** (if GO)
1. Set up paper account (Apex sim)
2. Run for 1 month
3. Compare to backtest
4. If replicates: Approve live
5. If diverges: Investigate and fix

### 7. Reporting Template

**For each strategy tested**:
```markdown
# Strategy X Backtest Report

## Summary
- Status: PASS/FAIL/CONDITIONAL
- GO/NO-GO: GO/NO-GO
- Test Date: YYYY-MM-DD

## Core Metrics
| Metric | Value | Target | Status |
|--------|-------|--------|--------|
| Sharpe | X.XX | >1.5 | ✅/❌ |
...

## Apex Compliance
- Trailing DD breaches: N
- Time violations: N
- Consistency violations: N
- Status: ✅ PASS / ❌ FAIL

## WFA Results
- Folds: N
- WFE: X.XX (target >=0.6)
- Status: ✅ PASS / ❌ FAIL

## Monte Carlo
- Runs: 10,000
- 95th percentile DD: X.X%
- P(ruin): X.X%
- Status: ✅ PASS / ❌ FAIL

## Scenarios
| Scenario | Period | Result | Notes |
|----------|--------|--------|-------|
| Normal trending | 2022-Q1 | PASS | ... |
| High volatility | 2020-03 | FAIL | Spread too wide |
...

## Issues Found
1. [Issue + severity + proposed fix]
2. ...

## Verdict
GO/NO-GO - [Rationale]

## Next Steps
1. [Action]
2. ...
```

### 8. Tools & Automation

**Scripts to create**:
- `run_full_backtest.py` (baseline test)
- `run_wfa.py` (walk-forward analysis)
- `run_monte_carlo.py` (robustness test)
- `generate_report.py` (auto-generate markdown report)

**Integration**:
- Use existing `nautilus_gold_scalper/scripts/` infrastructure
- Leverage NautilusTrader BacktestEngine
- Output to `DOCS/04_REPORTS/BACKTESTS/`

---

## Droid Assignment

**Use ORACLE droid** for this task:
- Expert in backtest validation and statistical analysis
- Knows WFA, Monte Carlo, GO/NO-GO frameworks
- Can define rigorous testing protocols
- Understands Apex Trading constraints

Invoke with:
```
Task(
  subagent_type="oracle-backtest-commander",
  description="Backtest validation plan",
  prompt="[This entire prompt]"
)
```

---

## Output Specification

### Primary Output

**File**: `.prompts/005-realistic-backtest-plan/realistic-backtest-plan.md`

**Structure**:
```markdown
# Realistic Backtest Validation Plan

<metadata>
<confidence>HIGH|MEDIUM|LOW</confidence>
<strategies_covered>N</strategies_covered>
<test_scenarios>N</test_scenarios>
<estimated_duration>X days</estimated_duration>
</metadata>

## Executive Summary

[300 words - plan overview, key phases, expected outcomes]

## Prerequisites (from Audits)

### Issues to Fix First
[Summarize P0/P1 issues from audits 001-004 that MUST be fixed before testing]

### Data Source
[Recommendation from audit 002]

### Apex Compliance
[Status from audit 004 - must be compliant before testing]

## Test Scenarios

[Detailed definition of Normal, Stress, Edge Case scenarios with date ranges]

## Metrics & Success Criteria

[Complete tables with Target/Minimum/Blocker thresholds]

## WFA Protocol

[Detailed procedure with parameters, formulas, success criteria]

## Monte Carlo Simulation

[Detailed procedure with parameters, formulas, success criteria]

## GO/NO-GO Framework

[Decision tree with clear logic]

## Testing Workflow

### Phase 1: Fix Issues
- [ ] Task 1 (effort: X hours)
- [ ] Task 2 (effort: X hours)
...

### Phase 2: Data Preparation
- [ ] Task 1
- [ ] Task 2
...

[Repeat for all 7 phases]

## Reporting Template

[Show example report structure]

## Tools & Automation

### Scripts to Create
1. `run_full_backtest.py` - [Purpose + key features]
2. `run_wfa.py` - [Purpose + key features]
...

### Integration Points
- [How to integrate with existing codebase]

## Timeline Estimate

| Phase | Tasks | Duration | Dependencies |
|-------|-------|----------|--------------|
| 1. Fix issues | N | X days | Audit findings |
| 2. Data prep | N | X days | Phase 1 |
...

**Total**: X days to completion

## Success Criteria

**Overall plan**:
- [ ] All test scenarios defined with date ranges
- [ ] Metrics have clear Target/Minimum/Blocker thresholds
- [ ] WFA and Monte Carlo protocols are rigorous
- [ ] GO/NO-GO framework is unambiguous
- [ ] Workflow is step-by-step actionable
- [ ] Tools/automation plan is clear

**Execution** (when plan is run):
- [ ] All core metrics meet Minimum thresholds
- [ ] Apex compliance: 0 violations
- [ ] WFE >= 0.5
- [ ] Monte Carlo 95th DD < 8%
- [ ] GO verdict achieved

## Risks & Mitigation

| Risk | Impact | Mitigation |
|------|--------|------------|
| Data quality issues | HIGH | Validate with audit 002 recommendations |
| Overfitting in WFA | MEDIUM | Use conservative WFE threshold (>=0.6) |
| Monte Carlo shows high DD | HIGH | Reduce position sizing or improve strategy |
...

## Next Steps After Plan Approval

1. [First action - e.g., "Fix P0 bugs from audit 003"]
2. [Second action]
3. ...

<open_questions>
- [What remains uncertain]
</open_questions>

<assumptions>
- [E.g., "Assumed 5 years of Dukascopy data available"]
</assumptions>

<dependencies>
- [E.g., "Requires completion of audits 001-004 first"]
</dependencies>
```

### Secondary Output

**File**: `.prompts/005-realistic-backtest-plan/SUMMARY.md`

```markdown
# Realistic Backtest Plan - Summary

## One-Liner
[E.g., "7-phase validation plan: fix bugs → WFA (15 folds) → Monte Carlo (10k runs) → GO/NO-GO"]

## Version
v1 - Initial plan (2025-12-07)

## Key Components
• [Component 1 - e.g., "WFA with WFE >= 0.6 threshold"]
• [Component 2 - e.g., "Monte Carlo 95th DD < 8% for Apex"]
• [Component 3 - e.g., "GO/NO-GO framework with paper trading gate"]
• [Estimated duration: X days]

## Decisions Needed
- [E.g., "Approve Dukascopy as data source (per audit 002)"]
- [E.g., "Approve 2-week timeline for Phase 1 fixes"]

## Blockers
- [E.g., "Must complete audits 001-004 before starting"]

## Next Step
[E.g., "Fix P0 bugs from backtest code audit (003)"]
```

---

## Tools to Use

**Planning**:
- `Read` - Read audit reports (001-004) to understand current state
- `calculator` - Calculate timeline estimates, metric thresholds

**Documentation**:
- `Create` - Create plan document

---

## Success Criteria

**Plan Quality**:
- [ ] All test scenarios defined with specific date ranges
- [ ] Metrics have Target/Minimum/Blocker thresholds
- [ ] WFA protocol is detailed and repeatable
- [ ] Monte Carlo parameters are rigorous (10k runs)
- [ ] GO/NO-GO framework is unambiguous
- [ ] 7-phase workflow is step-by-step actionable
- [ ] Timeline estimate is realistic

**Output Quality**:
- [ ] Plan is comprehensive yet concise
- [ ] Dependencies on audits 001-004 are clear
- [ ] SUMMARY.md captures key components
- [ ] Success criteria are measurable

**Validation**:
- [ ] Plan incorporates findings from all 4 audits
- [ ] Apex compliance is central to framework
- [ ] Realism (slippage, spreads) is emphasized

---

## Intelligence Rules

**Synthesis**: This plan integrates findings from 4 previous audits - read them carefully.

**Rigor**: Backtest validation must be bulletproof - conservative thresholds.

**Clarity**: Plan must be actionable by another agent or human.

---

## Notes

- This plan is FINAL step before actual backtest execution
- Depends on ALL 4 previous audits being complete
- Must enforce Apex rules (trailing DD, time, consistency)
- Success = GO verdict → paper trading → live approval
