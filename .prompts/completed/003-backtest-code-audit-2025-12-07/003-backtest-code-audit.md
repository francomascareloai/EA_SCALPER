# PROMPT 003: Backtest Code Complete Audit

## Objective

**Complete audit** of Python backtest implementation to verify it tests what it claims to test:
- Validate all 40 modules are correctly integrated
- Check if strategies are properly implemented vs plan
- Verify realistic execution modeling (slippage, spreads, fills)
- Validate data pipeline (loading, cleaning, validation)
- Check metrics calculation correctness
- Identify bugs, gaps, and false assumptions

**Why it matters**: User suspects "o código diz que testa alguma coisa, mas não testa 100%". Need to verify backtest is trustworthy before making trading decisions.

---

## Context

**Dependencies**:
- @.prompts/001-nautilus-plan-refine/nautilus-plan-audit.md (module status verification)
- @.prompts/002-backtest-data-research/backtest-data-research.md (data source validation)

**Target files**:
- `nautilus_gold_scalper/scripts/run_backtest.py`
- `nautilus_gold_scalper/scripts/nautilus_tick_backtest.py`
- `nautilus_gold_scalper/scripts/nautilus_backtest.py`
- `nautilus_gold_scalper/src/strategies/*strategy*.py`
- All 40 modules in `nautilus_gold_scalper/src/`

**Known issues** (from plan):
1. 4 bugs already found (DD%, threshold, Sharpe, config) - may be more
2. "Setup de backtest está ruim" - user complaint
3. Risk management was FTMO, now Apex - may not be updated
4. "Não testa 100%" - incomplete testing suspected

**Dynamic context**:
- !`find nautilus_gold_scalper/scripts -name "*backtest*.py"` (backtest scripts)
- !`wc -l nautilus_gold_scalper/src/**/*.py` (code size)
- !`grep -r "TODO\|FIXME\|BUG\|HACK" nautilus_gold_scalper/ | wc -l` (code smells)

---

## Requirements

### 1. Module Integration Audit

**For each of the 40 modules**:
- Is it imported by backtest scripts?
- Is it actually used in execution flow?
- Are parameters configured correctly?
- Are outputs consumed/validated?

**Create call graph**:
```
run_backtest.py
├─> gold_scalper_strategy.py
│   ├─> confluence_scorer.py ✅ USED
│   ├─> regime_detector.py ✅ USED
│   ├─> spread_monitor.py ❌ NOT USED (bug!)
│   └─> ...
```

### 2. Strategy Implementation Validation

**Compare strategy code to plan**:
- Does `gold_scalper_strategy.py` implement GENIUS v4.2 logic?
- Are all 7 ICT sequential steps present?
- Are session-specific weights applied?
- Are Phase 1 multipliers correct?
- Is strategy_selector.py used or bypassed?

**Test coverage**:
- What % of strategy logic has tests?
- Are edge cases covered (gaps, holidays, high spread)?

### 3. Execution Realism Audit

**Check modeling of**:
- **Slippage**: Is it applied? Realistic values (5-15 cents for XAUUSD)?
- **Spreads**: Real bid/ask or assumed constant?
- **Fills**: Instant or delayed? Market impact?
- **Rejections**: Can orders be rejected (margin, volatility)?
- **Partial fills**: Modeled or always full size?

**Apex-specific**:
- Trailing DD (10% from HWM) - correctly implemented?
- 4:59 PM ET cutoff - enforced?
- Consistency rule (30% max profit/day) - checked?
- No overnight positions - validated?

**Code inspection**:
```python
# Example checks:
grep -n "slippage" nautilus_gold_scalper/src/**/*.py
grep -n "spread" nautilus_gold_scalper/src/**/*.py
grep -n "trailing.*drawdown\|HWM\|high.*water" nautilus_gold_scalper/src/**/*.py
grep -n "4:59\|cutoff\|ET" nautilus_gold_scalper/src/**/*.py
```

### 4. Data Pipeline Validation

**Verify**:
- Data loading: Correct file format? Validation? Error handling?
- Cleaning: Outlier removal? Gap handling? Timezone conversion?
- Resampling: If needed, correct aggregation?
- Integrity: Checksums? Completeness checks?

**Inspect**:
```python
# Example:
Read("nautilus_gold_scalper/scripts/run_backtest.py")
# Look for:
# - ParquetDataCatalog usage
# - Data validation functions
# - Error handling for missing data
```

### 5. Metrics Calculation Audit

**Known bugs** (from plan):
1. `max_drawdown` vs `max_drawdown_pct` confusion
2. Sharpe over-annualization (√(252×288))
3. Threshold mismatch (50 Python vs 70 MQL5)

**Full audit**:
- Are ALL known bugs fixed?
- Are there other metric bugs?
- Are formulas correct vs literature?
  - Sharpe ratio: (R - Rf) / σ × √periods
  - Sortino: (R - MAR) / downside_σ × √periods
  - Calmar: CAGR / max_DD
  - SQN: avg(R-trade) / std(R-trade) × √N

**Validation**:
```python
# Compare to reference implementations:
# - empyrical library
# - quantstats library
# - Nautilus built-in metrics
```

### 6. Risk Management Validation

**Apex vs FTMO**:
- `prop_firm_manager.py`: Is it configured for Apex?
- Trailing DD: 10% from HWM (not fixed 10% from start)
- DD calculation: Includes unrealized P&L?
- Time checks: 4:59 PM ET enforced?

**Position sizing**:
- Kelly criterion: Correct formula? Capped?
- ATR-based: Window size? Multiplier?
- Max risk/trade: 0.5-1% enforced?

**Circuit breaker**:
- 6 levels documented - all implemented?
- Triggers: Loss streaks, DD%, win rate?
- Actions: Reduce size, skip trades, halt?

### 7. Code Quality Audit

**Scan for**:
- Silent exceptions (try/except with pass)
- Unused variables/functions
- Magic numbers (hardcoded constants)
- TODO/FIXME/HACK comments
- Type safety issues (missing annotations)
- Logging gaps (insufficient debug info)

**Tools**:
```bash
# Example scans:
grep -rn "except.*pass" nautilus_gold_scalper/
grep -rn "TODO\|FIXME\|BUG\|HACK" nautilus_gold_scalper/
grep -rn "magic.*number\|hardcoded" nautilus_gold_scalper/
```

### 8. Gap Identification

**What's missing**:
- Tests that should exist but don't
- Features promised in plan but not implemented
- Integration points (NinjaTrader adapter, news feed)
- Documentation (how to run, interpret results)

---

## Droid Assignment

**Use ORACLE droid** for this task:
- Expert in backtest validation
- Knows statistical validation methods
- Can assess execution realism
- Understands WFA, Monte Carlo, GO/NO-GO decisions

Invoke with:
```
Task(
  subagent_type="oracle-backtest-commander",
  description="Backtest code audit",
  prompt="[This entire prompt]"
)
```

**Optionally combine with FORGE** for code quality checks:
```
Task(
  subagent_type="forge-code-architect",
  description="Code quality audit",
  prompt="[Code quality section of this prompt]"
)
```

---

## Output Specification

### Primary Output

**File**: `.prompts/003-backtest-code-audit/backtest-code-audit.md`

**Structure**:
```markdown
# Backtest Code Complete Audit Report

<metadata>
<confidence>HIGH|MEDIUM|LOW</confidence>
<modules_audited>40/40</modules_audited>
<bugs_found>N</bugs_found>
<gaps_found>N</gaps_found>
<execution_realism_score>0-10</execution_realism_score>
</metadata>

## Executive Summary

[300 words - overall assessment, critical issues, go/no-go recommendation]

## Module Integration Matrix

| Module | Imported? | Used? | Configured? | Issues | Status |
|--------|-----------|-------|-------------|--------|--------|
| confluence_scorer.py | ✅ | ✅ | ✅ | Threshold=50 (should be 70) | ⚠️ |
| spread_monitor.py | ✅ | ❌ | N/A | NOT USED IN FLOW | ❌ CRITICAL |
...

**Call graph**: [Diagram or text representation of execution flow]

## Strategy Implementation Validation

### GENIUS v4.2 Logic
- [ ] 7 ICT sequential steps: [COMPLETE/PARTIAL/MISSING]
- [ ] Session-specific weights: [COMPLETE/PARTIAL/MISSING]
- [ ] Phase 1 multipliers: [COMPLETE/PARTIAL/MISSING]

**Evidence**: [Code snippets showing implementation]

### Test Coverage
- Strategy logic: X% covered
- Edge cases: [List covered vs missing]

## Execution Realism Audit

### Slippage Modeling
**Status**: ✅ IMPLEMENTED | ⚠️ PARTIAL | ❌ MISSING
**Details**: [How it's modeled, realistic values?]
**Code**: [File:line references]

### Spread Modeling
**Status**: [...]
**Details**: [Real bid/ask vs constant?]

### Fill Modeling
**Status**: [...]
**Details**: [Instant, delayed, partial fills?]

### Order Rejections
**Status**: [...]
**Details**: [Can orders fail? Why?]

### Apex-Specific
- [ ] Trailing DD (10% HWM): [IMPLEMENTED/MISSING]
- [ ] 4:59 PM ET cutoff: [IMPLEMENTED/MISSING]
- [ ] 30% consistency rule: [IMPLEMENTED/MISSING]
- [ ] No overnight: [IMPLEMENTED/MISSING]

**Execution Realism Score**: X/10 - [Rationale]

## Data Pipeline Validation

### Loading
**Status**: [CORRECT/ISSUES]
**Issues**: [If any]

### Cleaning
**Status**: [CORRECT/ISSUES]
**Checks**: [Outliers, gaps, timezones]

### Integrity
**Status**: [CORRECT/ISSUES]
**Validation**: [Checksums, completeness]

## Metrics Calculation Audit

### Known Bugs Status
1. max_drawdown_pct: ✅ FIXED | ❌ NOT FIXED
2. Sharpe annualization: ✅ FIXED | ❌ NOT FIXED
3. Threshold 70: ✅ FIXED | ❌ NOT FIXED

### New Bugs Found
1. [Bug description + location + impact + proposed fix]
2. ...

### Formula Validation
- Sharpe: [CORRECT/INCORRECT - evidence]
- Sortino: [CORRECT/INCORRECT - evidence]
- Calmar: [CORRECT/INCORRECT - evidence]
- SQN: [CORRECT/INCORRECT - evidence]

## Risk Management Validation

### Apex Configuration
- `prop_firm_manager.py`: ✅ APEX | ❌ STILL FTMO
- Trailing DD: [CORRECT/INCORRECT implementation]
- Time enforcement: [CORRECT/INCORRECT]

### Position Sizing
- Kelly: [CORRECT/INCORRECT formula]
- ATR-based: [CORRECT/INCORRECT params]
- Max risk: [ENFORCED/NOT ENFORCED]

### Circuit Breaker
- 6 levels: [X/6 IMPLEMENTED]
- Triggers: [List what works vs what's missing]

## Code Quality Issues

### Critical (P0)
1. [Issue + file + line + impact]
2. ...

### Important (P1)
1. [Issue + file + line + impact]
2. ...

### Minor (P2)
1. [Issue + file + line]
2. ...

**Code smells found**: N
**Silent exceptions**: N
**TODOs**: N
**Magic numbers**: N

## Gap Analysis

### Missing Features
1. [Feature + where it should be + priority]
2. ...

### Missing Tests
1. [Test + module + priority]
2. ...

### Missing Documentation
1. [Doc + topic + priority]
2. ...

## GO/NO-GO Assessment

**Current Status**: ⛔ NO-GO | ⚠️ CONDITIONAL | ✅ GO

**Blockers** (if NO-GO):
1. [Critical issue that must be fixed]
2. ...

**Conditions** (if CONDITIONAL):
1. [Issue to fix + estimated effort]
2. ...

**Rationale**: [Why this verdict]

## Recommendations

### Immediate Actions (P0)
1. [Action + owner + estimated effort]
2. ...

### Important Actions (P1)
1. [Action + owner + estimated effort]
2. ...

### Nice-to-Have (P2)
1. [Action + owner]
2. ...

## Next Steps

1. [Concrete next action]
2. [Concrete next action]
3. ...

<open_questions>
- [What remains uncertain after audit]
</open_questions>

<assumptions>
- [What was assumed during audit]
</assumptions>

<dependencies>
- [What's needed to proceed - e.g., "Fix bugs before re-audit"]
</dependencies>
```

### Secondary Output

**File**: `.prompts/003-backtest-code-audit/SUMMARY.md`

```markdown
# Backtest Code Audit - Summary

## One-Liner
[E.g., "Found 7 critical bugs including spread_monitor not integrated; backtest NO-GO until fixed"]

## Version
v1 - Initial audit (2025-12-07)

## Key Findings
• [Critical finding 1 with impact]
• [Critical finding 2 with impact]
• [Critical finding 3 with impact]
• [GO/NO-GO verdict: ...]

## Decisions Needed
- [E.g., "Approve 3-day effort to fix P0 bugs before re-audit"]

## Blockers
- [E.g., "Spread monitor not integrated - critical for Apex realism"]

## Next Step
[E.g., "Fix 7 P0 bugs in backtest code, then re-audit"]
```

---

## Tools to Use

**Essential**:
- `Read` - Read backtest scripts and module implementations
- `Grep` - Search for patterns (slippage, TODO, silent exceptions)
- `Glob` - Find all relevant files
- `Execute` - Run validation checks (line counts, import tests)
- `code-reasoning` - For complex logic validation (use when stuck)

**Code inspection**:
```bash
# Module usage
grep -rn "import.*confluence_scorer" nautilus_gold_scalper/scripts/

# Execution realism
grep -rn "slippage\|spread\|fill.*delay" nautilus_gold_scalper/src/

# Risk management
grep -rn "trailing.*dd\|HWM\|high.*water\|4:59\|cutoff" nautilus_gold_scalper/src/

# Code smells
grep -rn "except.*pass\|TODO\|FIXME\|HACK" nautilus_gold_scalper/
```

---

## Success Criteria

**Audit Completeness**:
- [ ] All 40 modules integration status verified
- [ ] Strategy implementation validated vs plan
- [ ] Execution realism scored with evidence
- [ ] Known bugs re-checked + new bugs found
- [ ] Risk management Apex compliance verified
- [ ] Code quality issues catalogued

**Output Quality**:
- [ ] GO/NO-GO verdict is clear and justified
- [ ] Critical bugs have proposed fixes
- [ ] Recommendations are actionable with effort estimates
- [ ] SUMMARY.md has substantive assessment (not generic)

**Validation**:
- [ ] At least 3 modules traced through full execution flow
- [ ] At least 5 code quality checks performed
- [ ] Execution realism score backed by specific evidence

---

## Intelligence Rules

**Depth**: This is a complete audit - be thorough, not cursory.

**Evidence-based**: Every claim needs code reference (file:line).

**Parallelism**: Read multiple files simultaneously to speed up audit.

**Code reasoning**: Use code-reasoning tool for complex logic validation.

---

## Notes

- User suspects "não testa 100%" - validate this claim
- 4 known bugs may be tip of iceberg
- Apex vs FTMO shift may not be complete
- This audit is CRITICAL for prompt 005 (realistic backtest plan)
