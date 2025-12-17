---
type: plan
description: "Phase 8: GO/NO-GO Decision"
phase_id: "08"
status: pending
priority: CRITICAL
model: opus
changelog: "2025-12-17: Added Protocol 0 (Mandatory Delegation)"
---

## ⚠️ MANDATORY DELEGATION (Protocol 0)

> **CRITICAL: The orchestrator MUST delegate the GO/NO-GO analysis to sub-agents.**
>
> Phase 8 reads all Phase 1-7 JSON outputs (these are summaries, safe to consolidate).
> However, the synthesis and decision-making should be delegated.

### Required Sub-Agent Prompt

```
DELEGATION PROTOCOL (MANDATORY):
1. YOU read all PHASE*.json files from outputs/ directory - orchestrator has NOT
2. Verify data lineage (catalog hash consistency)
3. Evaluate all CRITICAL and HIGH criteria
4. Write COMPLETE analysis to: DOCS/04_REPORTS/GO_NOGO_DECISION.md
5. Write JSON summary to: outputs/PHASE8_DECISION_SUMMARY.json
6. Return ONLY summary (max 400 words) with:
   - Decision: GO/GO-CONDITIONAL/NO-GO
   - Confidence level
   - CRITICAL/HIGH pass counts
   - Any blocking issues
   - Next steps

Plan: .planning/phases/08-data-validation-backtest/08-PLAN.xml.md
```

---

<objective>
Consolidate all validation and backtest results, apply GO/NO-GO thresholds, and produce final recommendation with evidence.

REGRA: USE scripts existentes de scripts/oracle/. NÃO crie novos.
Referência: SCRIPT_REGISTRY.md - scripts/oracle/go_nogo_validator.py é o principal

This phase:
1. Verifies data lineage (catalog hash matches across phases)
2. Loads all Phase 1-7 results
3. Evaluates all CRITICAL and HIGH criteria
4. Applies decision logic
5. Produces GO/NO-GO decision with full evidence trail
</objective>

<execution_context>
Memory: 12GB system, 4GB max for decision processing
Execution: 1 round, ORACLE + SENTINEL review
External CRITIC review: MANDATORY for production decisions
Dependencies: All Phases 1-7 completed successfully
Scripts: scripts/oracle/go_nogo_validator.py, scripts/oracle/deflated_sharpe.py, nautilus_gold_scalper/scripts/validate_apex_compliance.py
Reference: .planning/phases/08-data-validation-backtest/08-PLAN.xml.md
</execution_context>

<context>
- CLAUDE.md for project rules and ml_validation thresholds
- SCRIPT_REGISTRY.md for existing scripts
- .claude/agents/oracle-backtest-commander.md for ORACLE agent
- .claude/agents/sentinel-apex-guardian.md for SENTINEL agent
- .claude/agents/critic-adversarial.md for EXTERNAL CRITIC review
- All Phase 1-7 outputs in .planning/phases/08-data-validation-backtest/outputs/
</context>

<anti_duplication_rule>
ANTES de criar qualquer código:
1. Ler SCRIPT_REGISTRY.md
2. Verificar se funcionalidade existe em scripts/oracle/
3. Se existe: USAR o script existente via CLI ou import
4. Se não existe: PERGUNTAR ao usuário antes de criar
5. NUNCA criar scripts em .planning/ - use scripts/ se necessário
</anti_duplication_rule>

<tasks>
<!-- ROUND 1: Single task - ORACLE + SENTINEL final decision -->
<task id="8.1" type="auto" agent="oracle-backtest-commander" round="1">
<name>GO/NO-GO Decision</name>
<prompt>
You are ORACLE and SENTINEL jointly making the GO/NO-GO decision.

TASK: Consolidate all results and produce final recommendation.

PROCESS:

0. VERIFY DATA LINEAGE (MANDATORY FIRST STEP)
   - Read PHASE5_LINEAGE_STATUS.json
   - Verify catalog hash matches across all phases
   - Confirm Phase 7 used same validated data as Phases 2-5
   - If mismatch detected → ABORT with "DATA_LINEAGE_MISMATCH" error

1. LOAD ALL RESULTS
   Read all PHASE*.json files from .planning/phases/08-data-validation-backtest/outputs/:

   Phase 1: Discovery &amp; Configuration
   - PHASE1_DISCOVERY.json
   - PHASE1_CONFIG.json

   Phase 1-A: Deep Data Validation
   - PHASE1A_CSV_PARQUET_COUNT.json
   - PHASE1A_SAMPLE_VALIDATION.json
   - PHASE1A_SESSION_INTEGRITY.json
   - PHASE1A_SCHEMA_CONSISTENCY.json

   Phase 2: Main Catalog Validation
   - PHASE2_HEALTH_CHECK.json
   - PHASE2_SCHEMA_VALIDATION.json
   - PHASE2_TEMPORAL_CONSISTENCY.json
   - PHASE2_PRICE_VALIDATION.json
   - PHASE2_GAP_ANALYSIS.json
   - PHASE2_REGIME_ANALYSIS.json
   - PHASE2_SESSION_COVERAGE.json
   - PHASE2_QUALITY_SCORE.json

   Phase 3: Session Validation
   - PHASE3_SESSION_*.json (6 files)

   Phase 4: Integrity &amp; Cleanup
   - PHASE4_CROSS_CATALOG_CONSISTENCY.json
   - PHASE4_METADATA_AUDIT.json

   Phase 5: Advanced Validation
   - PHASE5_VOLATILITY_ANALYSIS.json
   - PHASE5_LOOKAHEAD_AUDIT.json
   - PHASE5_LINEAGE_STATUS.json
   - PHASE5_PERFORMANCE_BENCHMARK.json

   Phase 6: Backtest Framework
   - PHASE6_BACKTESTER_VALIDATION.json
   - PHASE6_WFA_SETUP.json
   - PHASE6_MONTE_CARLO_SETUP.json

   Phase 7: Backtest Results
   - PHASE7_BASELINE_BACKTEST.json
   - PHASE7_WFA_RESULTS.json
   - PHASE7_MONTE_CARLO_RESULTS.json
   - PHASE7_SESSION_BACKTESTS.json

2. EVALUATE CRITERIA

DATA QUALITY CRITERIA:
| Criterion | Threshold | Weight |
|-----------|-----------|--------|
| Coverage | >= 36 months | CRITICAL |
| Clean data | >= 99% | CRITICAL |
| Critical gaps | 0 | CRITICAL |
| Quality score | >= 70/100 | HIGH |
| Look-ahead bias | NONE | CRITICAL |
| Cross-catalog consistency | <= 0.1% difference | HIGH |

BACKTEST CRITERIA (ARGUS Research):
| Criterion | Threshold | Weight |
|-----------|-----------|--------|
| WFE | >= 0.60 | CRITICAL |
| SQN | >= 2.0 AND &lt; 5.0 | CRITICAL |
| OOS Windows Positive | >= 70% | HIGH |
| MC 95th DD | &lt; 4% | CRITICAL |
| PSR | >= 0.85 | HIGH |
| DSR | > 0 | HIGH |
| CPCV Score | >= 0.6 | CRITICAL |
| Risk of Ruin (5% DD) | &lt; 1% | HIGH |
| P(Daily DD Breach) | &lt; 5% | HIGH |
| P(Total DD Breach) | &lt; 2% | HIGH |
| Minimum Trades | >= 200 | CRITICAL |
| Profit Factor | >= 1.3 | HIGH |
| Realized Max DD | &lt; 4% | CRITICAL |
| Total Drawdown | &lt; 4.5% | CRITICAL |
| Regime Consistency | All profitable | HIGH |
| MinTRL Check | observed >= min_trl | HIGH |

APEX COMPLIANCE CRITERIA:
| Criterion | Threshold | Weight |
|-----------|-----------|--------|
| Time gate violations | 0 | CRITICAL |
| Overnight violations | 0 | CRITICAL |
| Trailing DD max (incl. unrealized) | &lt; 4% | CRITICAL |
| Max daily profit | &lt; 30% | HIGH |

3. APPLY DECISION LOGIC

```python
def go_nogo_decision(results):
    EXPECTED_CRITERIA = 25  # Minimum criteria count

    if len(results) &lt; EXPECTED_CRITERIA:
        return "NO-GO", f"Incomplete validation: {len(results)}/{EXPECTED_CRITERIA}"

    critical_failures = []
    high_failures = []

    for criterion, result in results.items():
        weight = result.get('weight', 'UNKNOWN')
        passed = result.get('passed', False)

        if weight == 'CRITICAL' and not passed:
            critical_failures.append(criterion)
        elif weight == 'HIGH' and not passed:
            high_failures.append(criterion)

    # SQN upper bound check
    sqn = results.get('sqn', {}).get('value', 0)
    if sqn >= 5.0:
        critical_failures.append(f"SQN curve-fit ({sqn:.2f} >= 5.0)")

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

4. GENERATE EVIDENCE
For each criterion, show:
- Actual value
- Threshold
- Status (PASS/FAIL)
- Source document

5. RECOMMENDATIONS
- If NO-GO: What needs to be fixed?
- If GO-CONDITIONAL: What to address before live?
- If GO: Proceed to Phase 9 (Paper Trading - MANDATORY)

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
**CLAUDE.md Version**: 3.10.9

## Executive Summary
[1-2 paragraphs summarizing decision and key factors]

## Data Lineage Verification
- Catalog hash: [verified/mismatch]
- Phases using same data: [yes/no]

## Criteria Evaluation

### Data Quality
| Criterion | Threshold | Actual | Status | Source |
|-----------|-----------|--------|--------|--------|
| Coverage | >= 36 months | XX months | PASS/FAIL | Phase 2 |
...

### Backtest Performance
| Criterion | Threshold | Actual | Status | Source |
|-----------|-----------|--------|--------|--------|
| WFE | >= 0.60 | X.XX | PASS/FAIL | Phase 7 |
...

### Apex Compliance
| Criterion | Threshold | Actual | Status | Source |
|-----------|-----------|--------|--------|--------|
| Time gates | 0 violations | X | PASS/FAIL | Phase 7 |
...

## Summary
- CRITICAL: X/Y passed
- HIGH: X/Y passed

## Decision Rationale
[Detailed explanation of decision]

## Conditions (if GO-CONDITIONAL)
[List of items to address before live]

## Risks &amp; Mitigations
| Risk | Severity | Mitigation |
|------|----------|------------|
...

## Next Steps
1. ...
2. ...
3. ...

## Appendix: Source Documents
- Phase 1: [list with file hashes]
- Phase 2: [list]
...
```

JSON OUTPUT:
{
  "decision": "GO/GO-CONDITIONAL/NO-GO",
  "confidence": "HIGH/MEDIUM/LOW",
  "critical_passed": int,
  "critical_total": int,
  "high_passed": int,
  "high_total": int,
  "critical_failures": [...],
  "high_failures": [...],
  "data_lineage_verified": true/false,
  "next_steps": [...]
}

EXTERNAL CRITIC REVIEW (MANDATORY):
After completing analysis, Orchestrator MUST spawn EXTERNAL CRITIC agent
using `.claude/agents/critic-adversarial.md` to review the GO/NO-GO decision.
This is a PRODUCTION DECISION - maximum rigor required.

Apply CRITIC self-review before reporting done.
</prompt>
<output>.planning/phases/08-data-validation-backtest/outputs/PHASE8_DECISION_SUMMARY.json</output>
</task>
</tasks>

<verification>
After Task 8.1 completes:
1. DOCS/04_REPORTS/GO_NOGO_DECISION.md exists
2. .planning/phases/08-data-validation-backtest/outputs/PHASE8_DECISION_SUMMARY.json exists
3. All 25+ criteria evaluated
4. Data lineage verified (catalog hash match)
5. Decision documented with full evidence trail
6. EXTERNAL CRITIC review completed
7. Next steps clearly defined
</verification>

<success_criteria>
- All input documents loaded: 25+ JSON files
- All criteria evaluated: 100% coverage
- Decision documented: GO_NOGO_DECISION.md created
- Evidence provided: All metrics with sources
- Data lineage: Verified (catalog hash matches)
- External CRITIC: Review completed
- Next steps defined: Clear action items
</success_criteria>

<post_decision_actions>
IF GO:
1. Update CHANGELOG.md with validation completion
2. Proceed to Phase 9: Paper Trading (MANDATORY)
3. Paper trading minimum: 2 weeks with live data feed
4. Set up monitoring dashboards
5. Only after paper trading success: Prepare for live deployment

IF GO-CONDITIONAL:
1. Create action items for conditions
2. Schedule follow-up validation
3. Document acceptable risk tolerance
4. Address conditions before proceeding to paper trading

IF NO-GO:
1. Create detailed remediation plan
2. Identify root causes of failures
3. Schedule re-validation after fixes
4. Document lessons learned
</post_decision_actions>
