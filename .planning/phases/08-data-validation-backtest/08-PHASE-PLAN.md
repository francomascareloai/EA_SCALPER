[ARGUS INTEGRATED] <!-- Research improvements integrated 2025-12-16 -->

# Phase 8: GO/NO-GO Decision

> **⚡ ARGUS IMPROVEMENTS APPLIED** (see full details at end of file, line ~495+)
> - **PSR threshold**: ≥0.85 (was 0.90) - adjusted for fat tails
> - **Min trades**: ≥200 (was 100) - elevated to CRITICAL
> - **SQN bounds**: ≥2.0 AND <5.0 - upper bound detects curve-fitting
> - **CPCV ≥0.6**: Replaces PBO <25% (superior overfitting detection)
> - **Regime consistency**: All HMM regimes must be profitable

**Phase ID**: 08
**Status**: ⏳ Pending
**Estimated Agents**: 1 (ORACLE + SENTINEL review)
**Execution Mode**: Sequential
**Model**: opus

---

## Objective

Consolidate all validation and backtest results, apply GO/NO-GO thresholds, and produce final recommendation with evidence.

---

## Prerequisites

- All Phases 1, 1-A, 2, 3, 4, 5, 6, 7 completed successfully <!-- FIXED per CRITIC: aligned with input list -->
- All JSON reports available in `DOCS/03_RESEARCH/FINDINGS/`
- No CRITICAL failures in any phase
- Sample requirements met: ≥2 years data AND ≥3 regimes tested <!-- FIXED per CRITIC C5 -->

---

## Input Documents

<!-- FIXED per CRITIC C2-C4: Added missing Phase 1, 1-A, and 6 inputs -->

### Phase 1: Discovery & Configuration
- PHASE1_DISCOVERY.json
- PHASE1_CONFIG.json

### Phase 1-A: Deep Data Validation
- PHASE1A_CSV_PARQUET_COUNT.json
- PHASE1A_SAMPLE_VALIDATION.json
- PHASE1A_SESSION_INTEGRITY.json
- PHASE1A_SCHEMA_CONSISTENCY.json

### Phase 2: Main Catalog Validation
- PHASE2_HEALTH_CHECK.json
- PHASE2_SCHEMA_VALIDATION.json
- PHASE2_TEMPORAL_CONSISTENCY.json
- PHASE2_PRICE_VALIDATION.json
- PHASE2_GAP_ANALYSIS.json
- PHASE2_REGIME_ANALYSIS.json
- PHASE2_SESSION_COVERAGE.json
- PHASE2_QUALITY_SCORE.json

### Phase 3: Session Validation
- PHASE3_SESSION_ASIAN.json
- PHASE3_SESSION_LONDON.json
- PHASE3_SESSION_OVERLAP.json
- PHASE3_SESSION_NY.json
- PHASE3_SESSION_LATE_NY.json
- PHASE3_SESSION_EVENING.json

### Phase 4: Integrity & Cleanup
- PHASE4_CROSS_CATALOG_CONSISTENCY.json
- PHASE4_METADATA_AUDIT.json
- PHASE4_CLEANUP_REPORT.json

### Phase 5: Advanced Validation
- PHASE5_VOLATILITY_ANALYSIS.json
- PHASE5_LOOKAHEAD_AUDIT.json
- PHASE5_LINEAGE_STATUS.json
- PHASE5_PERFORMANCE_BENCHMARK.json

### Phase 6: Backtest Framework <!-- FIXED per CRITIC C4: Added missing Phase 6 inputs -->
- PHASE6_BACKTESTER_VALIDATION.json
- PHASE6_WFA_SETUP.json
- PHASE6_MONTE_CARLO_SETUP.json

### Phase 7: Backtest Results
- PHASE7_BASELINE_BACKTEST.json
- PHASE7_WFA_RESULTS.json
- PHASE7_MONTE_CARLO_RESULTS.json
- PHASE7_SESSION_BACKTESTS.json

---

## GO/NO-GO Criteria

### Data Quality Criteria

| Criterion | Threshold | Source | Weight |
|-----------|-----------|--------|--------|
| Coverage | ≥ 36 months | Phase 2 | CRITICAL |
| Clean data | ≥ 99% | Phase 2 | CRITICAL |
| Critical gaps | 0 | Phase 2 | CRITICAL |
| Quality score | ≥ 70/100 | Phase 2 | HIGH |
| Look-ahead bias | NONE | Phase 5 | CRITICAL |
| Cross-catalog consistency | ≤ 0.1% difference | Phase 4 | HIGH |

### Backtest Criteria

<!-- ARGUS: Updated thresholds based on research improvements -->

| Criterion | Threshold | Source | Weight |
|-----------|-----------|--------|--------|
| Walk-Forward Efficiency (WFE) | >= 0.60 | Phase 7 | CRITICAL |
| SQN (System Quality Number) | >= 2.0 AND < 5.0 | Phase 7 | CRITICAL | <!-- ARGUS: Added upper bound -->
| OOS Windows Positive | >= 70% | Phase 7 | HIGH |
| Monte Carlo 95th DD | < 4% | Phase 7 | CRITICAL |
| Probabilistic Sharpe (PSR) | >= 0.85 | Phase 7 | HIGH | <!-- ARGUS: Adjusted from 0.90 -->
| Deflated Sharpe Ratio (DSR) | > 0 | Phase 7 | HIGH |
| CPCV Score | >= 0.6 | Phase 7 | CRITICAL | <!-- ARGUS: Replaces PBO -->
| Risk of Ruin (5% DD) | < 1% | Phase 7 | HIGH | <!-- ARGUS: Changed from 10% DD -->
| P(Daily DD Breach) | < 5% | Phase 7 | HIGH |
| P(Total DD Breach) | < 2% | Phase 7 | HIGH |
| Minimum Trades | >= 200 | Phase 7 | CRITICAL | <!-- ARGUS: Increased from 100 -->
| Profit Factor | >= 1.3 | Phase 7 | HIGH |
| Realized Max DD | < 4% | Phase 7 | CRITICAL |
| Total Drawdown | < 4.5% | Phase 7 | CRITICAL |
| Regime Consistency | All regimes profitable | Phase 7 | HIGH | <!-- ARGUS: New metric -->
| MinTRL Check | observed_years >= min_trl | Phase 7 | HIGH | <!-- ARGUS: New metric -->

### Apex Compliance Criteria

| Criterion | Threshold | Source | Weight |
|-----------|-----------|--------|--------|
| Time gate violations | 0 | Phase 7 | CRITICAL |
| Overnight violations | 0 | Phase 7 | CRITICAL |
| Trailing DD max (incl. unrealized) | < 4% | Phase 7 | CRITICAL |
| Max daily profit | < 30% | Phase 7 | HIGH |

**NOTE**: Trailing DD is calculated from High Water Mark INCLUDING unrealized P/L (Apex rule).

---

## Decision Logic

```python
def go_nogo_decision(results):
    """
    Decision logic for GO/NO-GO.

    Rules:
    1. Any CRITICAL criterion fails → NO-GO
    2. More than 2 HIGH criteria fail → NO-GO
    3. All CRITICAL pass AND ≤2 HIGH fail → GO (with conditions)
    4. All criteria pass → GO
    """

    critical_failures = []
    high_failures = []

    # Check each criterion
    for criterion, result in results.items():
        if result['weight'] == 'CRITICAL' and not result['passed']:
            critical_failures.append(criterion)
        elif result['weight'] == 'HIGH' and not result['passed']:
            high_failures.append(criterion)

    # Decision
    if critical_failures:
        return "NO-GO", f"CRITICAL failures: {critical_failures}"
    elif len(high_failures) > 2:
        return "NO-GO", f"Too many HIGH failures: {high_failures}"
    elif high_failures:
        return "GO-CONDITIONAL", f"Address before live: {high_failures}"
    else:
        return "GO", "All criteria passed"
```

---

## Task: Final Decision

**Agent**: ORACLE + SENTINEL review
**Model**: opus

**Prompt**:
```
You are ORACLE and SENTINEL jointly making the GO/NO-GO decision.

TASK: Consolidate all results and produce final recommendation.

PROCESS:

0. VERIFY DATA LINEAGE <!-- FIXED per CRITIC C6: Added data lineage verification -->
   - Read PHASE5_LINEAGE_STATUS.json
   - Verify catalog hash matches across all phases
   - Confirm Phase 7 used same validated data as Phases 2-5
   - If mismatch detected → ABORT with "DATA_LINEAGE_MISMATCH" error

1. LOAD ALL RESULTS
   - Read all PHASE*.json files from DOCS/03_RESEARCH/FINDINGS/
   - Extract key metrics

2. EVALUATE CRITERIA
   - For each criterion in GO/NO-GO table
   - Compare actual value to threshold
   - Mark PASS/FAIL

3. APPLY DECISION LOGIC
   - Count CRITICAL failures → if any, NO-GO
   - Count HIGH failures → if >2, NO-GO
   - Otherwise, determine GO or GO-CONDITIONAL

4. GENERATE EVIDENCE
   - For each criterion, show:
     * Actual value
     * Threshold
     * Status (PASS/FAIL)
     * Source document

5. RECOMMENDATIONS
   - If NO-GO: What needs to be fixed?
   - If GO-CONDITIONAL: What to address before live?
   - If GO: Any monitoring recommendations?

6. RISK ASSESSMENT
   - Identify remaining risks
   - Propose mitigations

OUTPUT DOCUMENT: DOCS/04_REPORTS/GO_NOGO_DECISION.md

STRUCTURE:
```markdown
# GO/NO-GO Decision: XAUUSD Scalper v2.2

**Decision Date**: YYYY-MM-DD
**Decision**: [GO / GO-CONDITIONAL / NO-GO]
**Confidence**: [HIGH / MEDIUM / LOW]

## Executive Summary
[1-2 paragraphs summarizing decision and key factors]

## Criteria Evaluation

### Data Quality
| Criterion | Threshold | Actual | Status |
|-----------|-----------|--------|--------|
| Coverage | ≥36 months | XX months | ✅/❌ |
...

### Backtest Performance
| Criterion | Threshold | Actual | Status |
|-----------|-----------|--------|--------|
| WFE | ≥0.60 | X.XX | ✅/❌ |
...

### Apex Compliance
| Criterion | Threshold | Actual | Status |
|-----------|-----------|--------|--------|
| Time gates | 0 violations | X | ✅/❌ |
...

## Summary
- CRITICAL: X/Y passed
- HIGH: X/Y passed
- MEDIUM: X/Y passed

## Decision Rationale
[Detailed explanation of decision]

## Conditions (if GO-CONDITIONAL)
[List of items to address before live]

## Risks & Mitigations
| Risk | Severity | Mitigation |
|------|----------|------------|
...

## Next Steps
1. ...
2. ...
3. ...

## Appendix: Source Documents
- Phase 2: [list]
- Phase 3: [list]
...
```

FILE: DOCS/04_REPORTS/GO_NOGO_DECISION.md
JSON: DOCS/03_RESEARCH/FINDINGS/PHASE8_DECISION_SUMMARY.json

<!-- FIXED per CRITIC C7: Changed from self-review to external CRITIC spawning -->
EXTERNAL CRITIC REVIEW (MANDATORY):
After ORACLE+SENTINEL complete their analysis, Orchestrator MUST spawn EXTERNAL CRITIC agent
using `.claude/agents/critic-adversarial.md` to review the GO/NO-GO decision.
This is a PRODUCTION DECISION - maximum rigor required.
```

---

## Success Criteria

| Criterion | Requirement |
|-----------|-------------|
| All inputs loaded | 20+ JSON files |
| All criteria evaluated | 100% coverage |
| Decision documented | GO_NOGO_DECISION.md created |
| Evidence provided | All metrics with sources |
| Next steps defined | Clear action items |

---

## Deliverables

1. **DOCS/04_REPORTS/GO_NOGO_DECISION.md** - Final decision document
2. **PHASE8_DECISION_SUMMARY.json** - Machine-readable summary
3. **Updated DOCS/_INDEX.md** - Link to decision document

---

## Post-Decision Actions

### If GO:
1. Update CHANGELOG.md with validation completion
2. **Proceed to Phase 9: Paper Trading (MANDATORY)** <!-- FIXED per CRITIC H2/H4: Added mandatory paper trading -->
3. Paper trading minimum: 2 weeks with live data feed
4. Set up monitoring dashboards
5. Only after paper trading success: Prepare for live deployment

### If GO-CONDITIONAL:
1. Create action items for conditions
2. Schedule follow-up validation
3. Document acceptable risk tolerance

### If NO-GO:
1. Create detailed remediation plan
2. Identify root causes of failures
3. Schedule re-validation after fixes

---

## Completion

This phase marks the end of the Data Validation & Backtesting Pipeline.

**Output**: Clear GO/NO-GO decision with full evidence trail.

---

## CRITIC Review (Phase 8)

**Review Date**: 2025-12-16
**Reviewer**: CRITIC v1.1 - Adversarial Quality Guardian
**CLAUDE.md Version**: 3.10.9
**Methodology**: 18 sequential thoughts, all 7 adversarial techniques applied
**Confidence**: HIGH

---

### VERDICT: REJECTED

This plan has fundamental alignment issues with CLAUDE.md v3.10.9 and cannot be executed as-is. The critical issues would allow a strategy to pass validation without meeting all requirements, potentially leading to account loss.

---

### CRITICAL ISSUES (7 - Must Fix Before Execution)

| # | Issue | Location | Impact | Fix |
|---|-------|----------|--------|-----|
| C1 | **SQN ≥ 2.0 missing from criteria** | Backtest Criteria table | Strategy with unreliable edge (SQN 1.2) could pass | Add: `SQN \| ≥ 2.0 \| Phase 7 \| CRITICAL` |
| C2 | **Phase 1 outputs missing from input list** | Input Documents | Can't verify Discovery & Configuration completed | Add PHASE1_*.json files to input list |
| C3 | **Phase 1-A outputs missing from input list** | Input Documents | Critical data validation not verified | Add PHASE1A_*.json files to input list |
| C4 | **Phase 6 outputs missing from input list** | Input Documents | Backtest Framework setup not verified | Add PHASE6_*.json files to input list |
| C5 | **Sample requirements incomplete** | Backtest Criteria | CLAUDE.md requires "≥2 years AND multiple regimes" | Add: Coverage years and regime diversity criteria |
| C6 | **Data lineage not verified** | Decision Logic | Phase 7 might use different data than validated in Phases 2-5 | Add data hash/version verification step |
| C7 | **Self-review instead of EXTERNAL CRITIC** | Task prompt (line 251) | CLAUDE.md production_workflow requires external spawned CRITIC for go-live | Change to: "Orchestrator spawns EXTERNAL CRITIC agent" |

---

### HIGH ISSUES (5 - Should Fix)

| # | Issue | Location | Impact | Fix |
|---|-------|----------|--------|-----|
| H1 | **Prerequisites mismatch** | Line 19 | Claims "Phases 1-7" but inputs list only 2-5, 7 | Align prerequisites with actual input list |
| H2 | **No paper trading phase** | Post-Decision Actions | CLAUDE.md v3.10.9 requires mandatory paper trading before live | Add paper trading as required step between GO and live |
| H3 | **No criteria count validation** | Decision Logic | Empty results dict would return "GO" | Add: `assert len(results) >= 20` |
| H4 | **GO path skips paper trading** | Line 280 | Says "prepare for live" directly | Change to: "Proceed to Phase 9: Paper Trading (mandatory)" |
| H5 | **ORACLE+SENTINEL merged** | Task prompt | No conflict resolution if they disagree | Separate agents with SENTINEL final authority per verdict_synthesizer |

---

### MEDIUM ISSUES (6 - Recommended Fixes)

| # | Issue | Location | Impact | Fix |
|---|-------|----------|--------|-----|
| M1 | No regime-stratified validation | Backtest Criteria | Can't detect regime-specific failures | Add regime breakdown requirements |
| M2 | No forward regime risk assessment | Criteria | Future regime shifts unaddressed | Add regime adaptability criterion |
| M3 | Decision logic lacks input validation | Python code | Typos in 'weight' field silently ignored | Add whitelist validation for weight values |
| M4 | GO-CONDITIONAL lacks action mapping | Post-Decision | Unclear what conditions require what fixes | Add condition-to-action table |
| M5 | Evidence trail lacks versions | Output template | Can't reproduce decision later | Add CLAUDE.md version, agent versions, data versions |
| M6 | Output lacks structured_handoff format | Output template | Information loss to Phase 9 | Add Assumptions, Open Questions sections |

---

### LOW ISSUES (1 - Nice to Have)

| # | Issue | Impact | Fix |
|---|-------|--------|-----|
| L1 | No checksums for input files | Can't verify file integrity | Add SHA256 checksums in output |

---

### ASSUMPTIONS CHALLENGED

| Assumption | Challenge | Recommendation |
|------------|-----------|----------------|
| "All Phases 1-7 completed successfully" | No completion markers or checksums | Add explicit phase completion verification |
| JSON files are current and consistent | Files could be from different dates/runs | Add timestamp validation, require all from same session |
| Phase 7 used validated data | No lineage tracking | Add data catalog hash verification |
| Thresholds apply to all account sizes | $50k vs $300k may need different buffers | Parameterize thresholds by account size |
| Single GO/NO-GO is sufficient | No continuous validation | Add monitoring requirements for live |

---

### EDGE CASES NEEDING HANDLING

| Edge Case | Current Behavior | Required Behavior |
|-----------|------------------|-------------------|
| Exactly 2 HIGH failures | GO-CONDITIONAL | Consider: Should 2 HIGH failures be NO-GO? |
| Zero trades in backtest | HIGH failure only | Should be CRITICAL failure |
| WFE = NaN (division by zero) | Undefined | Explicit FAIL on any NaN/Inf |
| Empty results dict | Returns "GO" | Return "NO-GO: validation incomplete" |
| JSON files from different dates | Accepted | Reject if timestamps differ by >1 day |

---

### PRE-MORTEM SUMMARY

**Most Likely Failure Mode**: Strategy with SQN 1.5 (below 2.0 threshold) passes Phase 8 because SQN is not checked. During live trading, the strategy hits a normal losing streak that exceeds DD limits because the edge wasn't robust enough.

**Second Most Likely**: Paper trading is skipped (GO → live directly). Time gates work fine in backtest but fail in production due to timezone handling or latency issues. Position still open at 5:00 PM ET, Apex terminates account.

**Third Most Likely**: Phase 7 backtest ran on stale data catalog (pre-Phase 2-5 fixes). Decision based on results that don't reflect validated data quality.

---

### REQUIRED FIXES BEFORE RE-REVIEW

1. [ ] Add SQN ≥ 2.0 as CRITICAL criterion in Backtest Criteria table
2. [ ] Add Phase 1, 1-A, 6 outputs to Input Documents section
3. [ ] Add data lineage verification step (catalog hash matching)
4. [ ] Change CRITIC self-review to EXTERNAL CRITIC spawning
5. [ ] Add paper trading as mandatory phase between GO and live
6. [ ] Separate ORACLE and SENTINEL with clear hierarchy (SENTINEL = final)
7. [ ] Add sample requirements: "≥2 years data AND ≥3 regimes tested"
8. [ ] Add validation: `assert len(results) >= EXPECTED_CRITERIA_COUNT`
9. [ ] Add version tracking to output template

---

### CHECKLIST RESULTS

| Check | Status | Notes |
|-------|--------|-------|
| CRITICAL thresholds aligned with CLAUDE.md | FAIL | SQN missing |
| MC 95th DD < 4% | PASS | Correctly set |
| Trailing DD < 4% | PASS | Correctly set |
| Total DD < 4.5% | PASS | Correctly set |
| Decision logic correct | PARTIAL | Logic OK but lacks validation |
| All Phase 1-7 outputs listed | FAIL | 1, 1-A, 6 missing |
| Phase 1-A outputs included | FAIL | Not listed |
| Evidence trail complete | PARTIAL | Missing versions |
| Post-decision actions for all 3 outcomes | PARTIAL | GO missing paper trading |

---

### STRESS TEST RESULTS

| Condition | Outcome |
|-----------|---------|
| All JSON files empty | FAIL: No error handling defined |
| Contradictory results (Phase 2 vs Phase 5) | FAIL: No conflict resolution |
| Floating point edge (WFE = 0.599999) | UNCERTAIN: May incorrectly fail |
| Missing Phase 6 entirely | FAIL: Would not be detected |

---

### APEX TRAP ANALYSIS

| Trap | Status | Notes |
|------|--------|-------|
| Trailing DD from HWM including unrealized | PASS | Correctly documented in NOTE |
| Time gate verification | PARTIAL | Checks violations=0 but not implementation |
| Emergency close tested | FAIL | No requirement to test edge case |
| Paper trading before live | FAIL | Not included in plan |

---

**SIGNATURE**: CRITIC v1.1
**STATUS**: REJECTED - 7 CRITICAL issues must be resolved
**NEXT ACTION**: Fix all CRITICAL and HIGH issues, then request re-review

---

## ARGUS Research Improvements

**Date Integrated**: 2025-12-16
**Source**: ARGUS Quant Researcher - Research Triangulation
**Confidence**: HIGH (3+ independent sources, reproducible methods)

### Summary of Changes

The following research-backed improvements have been integrated into Phase 8 GO/NO-GO criteria:

| Improvement | Old Value | New Value | Rationale |
|-------------|-----------|-----------|-----------|
| PSR threshold | >= 0.90 | **>= 0.85** | Adjusted for fat-tailed returns (Bailey & Lopez de Prado) |
| Minimum trades | >= 100 | **>= 200** | Institutional standard for statistical significance |
| SQN bounds | >= 2.0 | **>= 2.0 AND < 5.0** | Upper bound detects curve-fitting (SQN > 5 is suspiciously good) |
| PBO metric | < 25% | **Replaced by CPCV >= 0.6** | CPCV provides superior overfitting detection |
| Risk of Ruin DD | 10% DD | **5% DD** | Aligned with Apex termination threshold |
| Min Trades Weight | HIGH | **CRITICAL** | Elevated due to statistical significance importance |

### New Metrics Added

| Metric | Threshold | Weight | Description |
|--------|-----------|--------|-------------|
| CPCV Score | >= 0.6 | CRITICAL | Combinatorial Purged Cross-Validation (replaces PBO) |
| Regime Consistency | All profitable | HIGH | Strategy must profit in all HMM-detected regimes |
| MinTRL Check | observed >= min_trl | HIGH | Track record length sufficient for Sharpe significance |

### Updated GO/NO-GO Thresholds (ARGUS Research)

```yaml
# FINAL GO/NO-GO Criteria (ARGUS Integrated)
# All CRITICAL criteria must pass for GO decision

data_quality:
  coverage: ">= 36 months"           # CRITICAL
  clean_data: ">= 99%"               # CRITICAL
  critical_gaps: "0"                 # CRITICAL
  quality_score: ">= 70/100"         # HIGH
  look_ahead_bias: "NONE"            # CRITICAL
  cross_catalog_consistency: "<= 0.1%" # HIGH

backtest_criteria:
  wfe: ">= 0.60"                     # CRITICAL
  sqn: ">= 2.0 AND < 5.0"            # CRITICAL - ARGUS: upper bound added
  oos_windows_positive: ">= 70%"     # HIGH
  mc_dd_95: "< 4%"                   # CRITICAL
  psr: ">= 0.85"                     # HIGH - ARGUS: adjusted from 0.90
  dsr: "> 0"                         # HIGH
  cpcv_score: ">= 0.6"               # CRITICAL - ARGUS: replaces PBO
  ror_5pct: "< 1%"                   # HIGH - ARGUS: aligned with Apex
  p_daily_dd: "< 5%"                 # HIGH
  p_total_dd: "< 2%"                 # HIGH
  min_trades: ">= 200"               # CRITICAL - ARGUS: increased from 100
  profit_factor: ">= 1.3"            # HIGH
  realized_max_dd: "< 4%"            # CRITICAL
  total_drawdown: "< 4.5%"           # CRITICAL
  regime_consistency: "all profitable" # HIGH - ARGUS: new metric
  mintrl_check: "PASS"               # HIGH - ARGUS: new metric

apex_compliance:
  time_gate_violations: "0"          # CRITICAL
  overnight_violations: "0"          # CRITICAL
  trailing_dd_max: "< 4%"            # CRITICAL
  max_daily_profit: "< 30%"          # HIGH
```

### New Dependencies (Required for Phase 8)

```txt
# ARGUS Research Improvements - Validation Libraries
mlfinlab>=2.0.0          # CPCV, DSR, PSR, purging, embargo
timeseriescv>=0.2.0      # CombPurgedKFoldCV
hmmlearn>=0.3.0          # Hidden Markov Models for regimes
arch>=6.0.0              # Block bootstrap, circular bootstrap
scipy>=1.10.0            # MinTRL calculation
```

### Updated Decision Logic

```python
def go_nogo_decision_argus(results: dict) -> tuple[str, str]:
    """
    ARGUS-Enhanced GO/NO-GO Decision Logic.

    Rules:
    1. Any CRITICAL criterion fails -> NO-GO
    2. More than 2 HIGH criteria fail -> NO-GO
    3. All CRITICAL pass AND <=2 HIGH fail -> GO-CONDITIONAL
    4. All criteria pass -> GO

    ARGUS Updates:
    - SQN must be 2.0-5.0 (upper bound added)
    - PSR threshold lowered to 0.85
    - Min trades increased to 200 (now CRITICAL)
    - CPCV replaces PBO (now CRITICAL)
    - Regime consistency added
    - MinTRL check added
    """
    critical_failures = []
    high_failures = []

    # Validate minimum criteria count
    EXPECTED_CRITERIA = 20  # ARGUS: Updated count
    if len(results) < EXPECTED_CRITERIA:
        return "NO-GO", f"Incomplete validation: {len(results)}/{EXPECTED_CRITERIA} criteria"

    for criterion, result in results.items():
        if result.get('weight') == 'CRITICAL' and not result.get('passed'):
            critical_failures.append(criterion)
        elif result.get('weight') == 'HIGH' and not result.get('passed'):
            high_failures.append(criterion)

    # ARGUS: Enhanced SQN check (upper bound)
    sqn = results.get('sqn', {}).get('value', 0)
    if sqn >= 5.0:
        critical_failures.append(f"SQN suspiciously high ({sqn:.2f} >= 5.0, likely curve-fit)")

    # Decision
    if critical_failures:
        return "NO-GO", f"CRITICAL failures: {critical_failures}"
    elif len(high_failures) > 2:
        return "NO-GO", f"Too many HIGH failures ({len(high_failures)}): {high_failures}"
    elif high_failures:
        return "GO-CONDITIONAL", f"Address before live: {high_failures}"
    else:
        return "GO", "All criteria passed"
```

### CPCV Integration

```python
from mlfinlab.cross_validation import CombinatorialPurgedKFold
import numpy as np
import pandas as pd

def validate_cpcv_for_gonogo(returns: pd.Series) -> dict:
    """Validate CPCV score for GO/NO-GO decision.

    ARGUS: CPCV score >= 0.6 is required (CRITICAL).
    This replaces PBO < 25% which was less reliable.
    """
    cv = CombinatorialPurgedKFold(
        n_splits=5,
        n_test_splits=2,
        purge_gap=5,
        embargo_gap=5
    )

    scores = []
    for train_idx, test_idx in cv.split(returns):
        test = returns.iloc[test_idx]
        if test.std() > 0:
            sharpe = test.mean() / test.std() * np.sqrt(252)
            scores.append(sharpe)

    cpcv_score = np.mean(scores) / np.std(scores) if np.std(scores) > 0 else 0

    return {
        "criterion": "CPCV Score",
        "threshold": ">= 0.6",
        "value": float(cpcv_score),
        "passed": cpcv_score >= 0.6,
        "weight": "CRITICAL",
        "source": "Phase 7"
    }
```

### Regime Consistency Check

```python
from hmmlearn import hmm
import numpy as np
import pandas as pd

def validate_regime_consistency(returns: pd.Series) -> dict:
    """Validate strategy is profitable across all regimes.

    ARGUS: Strategy must be profitable in ALL detected regimes.
    Uses 3-regime HMM (low/medium/high volatility).
    """
    X = returns.values.reshape(-1, 1)

    model = hmm.GaussianHMM(n_components=3, covariance_type="full", n_iter=1000)
    model.fit(X)
    regimes = model.predict(X)

    all_profitable = True
    regime_results = {}
    for i in range(3):
        mask = regimes == i
        regime_returns = returns[mask]
        mean_return = regime_returns.mean()
        regime_results[f"regime_{i}"] = {
            "count": int(mask.sum()),
            "mean_return": float(mean_return),
            "profitable": mean_return > 0
        }
        if mean_return <= 0:
            all_profitable = False

    return {
        "criterion": "Regime Consistency",
        "threshold": "All regimes profitable",
        "value": "PASS" if all_profitable else "FAIL",
        "passed": all_profitable,
        "weight": "HIGH",
        "source": "Phase 7",
        "details": regime_results
    }
```

### MinTRL Verification

```python
import numpy as np
from scipy.stats import norm

def validate_mintrl(sharpe_observed: float, years_observed: float,
                    skewness: float = 0, kurtosis: float = 3) -> dict:
    """Validate track record length is sufficient.

    ARGUS: Ensures observed track record is long enough
    for the Sharpe ratio to be statistically significant at 95%.
    """
    confidence = 0.95
    z = norm.ppf(confidence)

    # Standard error of Sharpe ratio
    se = np.sqrt((1 + 0.5 * sharpe_observed**2 - skewness * sharpe_observed +
                  (kurtosis - 3) / 4 * sharpe_observed**2))

    # Minimum track record length in years
    min_trl = ((z * se) / sharpe_observed) ** 2 if sharpe_observed > 0 else float('inf')

    passed = years_observed >= min_trl

    return {
        "criterion": "MinTRL Check",
        "threshold": f">= {min_trl:.2f} years",
        "value": f"{years_observed:.2f} years observed",
        "passed": passed,
        "weight": "HIGH",
        "source": "Phase 7",
        "details": {
            "sharpe_observed": sharpe_observed,
            "min_trl_years": float(min_trl),
            "years_observed": years_observed
        }
    }
```

### Pre-Decision Checklist

Before making GO/NO-GO decision, verify:

- [ ] All Phase 1-7 outputs available in DOCS/03_RESEARCH/FINDINGS/
- [ ] CPCV score calculated and meets >= 0.6 threshold
- [ ] SQN is within 2.0-5.0 range (not just >= 2.0)
- [ ] PSR threshold uses 0.85 (not 0.90)
- [ ] Minimum trades threshold is 200 (not 100)
- [ ] Regime consistency check performed (all regimes profitable)
- [ ] MinTRL verification completed
- [ ] Data lineage verified (catalog hash matches across phases)
- [ ] External CRITIC review spawned for production decision

---
