# CRITIC Adversarial Audit: ONNX_BUILDER v2.1

**Artifact**: `.claude/agents/onnx-model-builder.md`
**Type**: Agent Specification
**Reviewer**: CRITIC v1.1
**Date**: 2025-12-16
**CLAUDE_MD_VERSION**: 3.10.9

---

## VERDICT: ISSUES_FOUND

The ONNX_BUILDER v2.1 spec is functional for basic ML-to-ONNX workflows but has significant gaps that could lead to production failures, Apex violations, and incomplete quality assurance.

---

## CRITICAL ISSUES (5 findings)

### C1: No Version Reporting Compliance
**Location**: Entire spec (missing)
**Impact**: CLAUDE.md v3.10.9 requires all sub-agents to include `AGENT_VERSION: [version from spec header]` in output. This spec makes no mention of this requirement.
**Fix**: Add to output format:
```
## Agent Output Header
AGENT: ONNX_BUILDER
VERSION: v2.1
CLAUDE_MD_VERSION: [current]
STATUS: COMPLETE/PARTIAL/FAILED
```

### C2: No Structured Output Format Template
**Location**: Lines 19-20 mention output but no template
**Impact**: Other agents (CRITIC, ORACLE) have detailed output formats. ONNX_BUILDER output is vague ("GO/CAUTION/NO-GO + artifacts + metrics + risks + next handoffs") leading to inconsistent outputs.
**Fix**: Add structured output template similar to CRITIC's format with all required sections.

### C3: Missing End-to-End Latency Budget
**Location**: Lines 35, 44
**Impact**: Spec only specifies "ONNX inference <5ms" but total inference path = feature_compute + normalize + ONNX + postprocess. Model could pass ONNX benchmark but violate total OnTick budget (<50ms).
**Fix**: Add end-to-end latency specification:
```
Total inference path budget: <10ms
- Feature computation: <3ms
- Normalization: <1ms
- ONNX inference: <5ms
- Post-processing: <1ms
```

### C4: No Mandatory SENTINEL Check Before GO
**Location**: Lines 53-55 (Handoffs section)
**Impact**: SENTINEL is listed as handoff for "risk/Apex impact" but it's not mandatory. Agent could issue GO without Apex compliance verification, leading to model deployment that violates prop firm rules.
**Fix**: Add to workflow:
```
Step 7: MANDATORY - Handoff to SENTINEL for Apex compliance before issuing GO
- No GO verdict without SENTINEL approval
- SENTINEL has veto power
```

### C5: CRITIC Self-Review Protocol Incomplete
**Location**: Lines 59-67
**Impact**: Self-review mentions only 3 of 7 CRITIC techniques (INVERSION, PRE-MORTEM, ASSUMPTION AUDIT). Missing: STRESS TEST, REGIME SHIFT, APEX TRAP, EDGE CASE HUNTING. Also missing: loop-until-pass mechanism.
**Fix**: Expand section:
```
Apply ALL CRITIC techniques:
1. INVERSION - how could this model fail?
2. PRE-MORTEM - it's 2026, account blew up, why?
3. STRESS TEST - 2x spread, 5x slippage, 10x latency
4. REGIME SHIFT - trend/chop/volatile/low-vol
5. APEX TRAP - trailing DD, time gates, 30% consistency
6. EDGE CASE HUNTING - NaN, partial fills, timeouts
7. ASSUMPTION AUDIT - challenge every assumption

Loop until all critical issues resolved before reporting.
```

---

## HIGH ISSUES (7 findings)

### H1: No Model Versioning/Registry System
**Location**: Lines 46-50 (Minimal Artifacts)
**Impact**: Only outputs are model.onnx, scaler.json, features.md, bench.json. No model registry, no version tracking, no rollback capability.
**Fix**: Add required artifacts:
```
- model_v{version}_{timestamp}.onnx
- model_registry.json (version history, checksums)
- model_card.md (provenance, training data, limitations)
```

### H2: No Feature Drift Monitoring or Staleness Checks
**Location**: Entire spec (missing)
**Impact**: Model trained on historical data has no mechanism to detect when features drift out of training distribution in production.
**Fix**: Add to workflow:
```
Step 6b: Define feature monitoring
- Feature distribution bounds from training
- Drift detection thresholds
- Staleness triggers (retrain after X days/trades)
```

### H3: No Production Hardware Specification
**Location**: Line 35
**Impact**: "ONNX inference <5ms on target hardware" but target hardware is never defined. Benchmark in e2b sandbox may not match production.
**Fix**: Define target hardware OR require benchmarking on actual deployment environment.

### H4: Limited Scaler Support
**Location**: Line 48
**Impact**: "scaler.json (mean/std per feature)" assumes StandardScaler. What about MinMaxScaler, RobustScaler, log transforms, one-hot encoding?
**Fix**: Generalize:
```
- scaler.json OR transform_pipeline.json
- Support multiple transform types
- Document each feature's preprocessing
```

### H5: No Error Handling/Retry/Fallback Protocol
**Location**: Entire spec (missing)
**Impact**: What happens if:
- e2b times out?
- Training fails to converge?
- ONNX export fails?
- Parity test fails?
No error handling documented.
**Fix**: Add error handling section with retry logic and escalation paths.

### H6: No Escalation Triggers Defined
**Location**: Lines 52-55 list handoffs but not WHEN
**Impact**: Agent doesn't know when to escalate vs decide autonomously. Risk of autonomous decisions on edge cases that should involve human.
**Fix**: Add escalation triggers table:
```
| Condition | Escalate To | Action |
|-----------|-------------|--------|
| All gates fail | CRUCIBLE | Strategy redesign |
| Parity fails after 2 retries | FORGE | Debug runtime |
| Latency > 10ms | PERF_OPT | Optimization |
| Unclear target definition | USER | Clarification |
```

### H7: Missing Sample Size and Time Period Requirements
**Location**: Lines 32-34 (Gates)
**Impact**: Validation gates list WFE/PSR/DSR/PBO/SQN/MC but no mention of:
- Minimum 100 trades
- Minimum 2 years of data
- Multiple regime coverage
(These are in CLAUDE.md but not explicitly referenced)
**Fix**: Add: "Sample requirements from CLAUDE.md: >=100 trades AND >=2 years AND multiple regimes"

---

## MEDIUM ISSUES (7 findings)

### M1: No Hyperparameter Optimization Guidance
**Location**: Workflow (lines 39-44)
**Impact**: No mention of GridSearch, RandomSearch, Optuna, or any hyperparameter tuning. Risk of suboptimal model configuration.
**Fix**: Add step in workflow for hyperparameter optimization with validation.

### M2: No Model Interpretation Requirements
**Location**: Minimal Artifacts (lines 46-50)
**Impact**: No SHAP values, feature importance, or interpretability artifacts. Black box model with no understanding of what drives predictions.
**Fix**: Add: `feature_importance.json`, `shap_summary.png` to artifacts.

### M3: No Data Quality Validation Specified
**Location**: Workflow step 2 (line 40)
**Impact**: "Build features with strict temporal discipline" but what about:
- Gaps in data?
- Duplicate records?
- Bad price data (erroneous ticks)?
**Fix**: Add data quality validation step before feature engineering.

### M4: No XAUUSD-Specific Considerations
**Location**: Entire spec (generic ML focus)
**Impact**: This is for XAUUSD (Gold) scalping but spec is generic. Missing:
- Gold spread patterns
- Session volatility (London/NY/Asia)
- News impact (NFP, FOMC)
- Gold-specific feature recommendations
**Fix**: Add XAUUSD-specific guidance or defer to CRUCIBLE for domain expertise.

### M5: No p99 Latency or Memory Benchmarks
**Location**: Line 50
**Impact**: bench.json only has p50/p95. What about:
- p99 latency (tail risk)?
- Memory usage during inference?
- Model load time?
**Fix**: Expand bench.json requirements:
```
{
  "p50_ms": 2.1,
  "p95_ms": 3.8,
  "p99_ms": 4.5,
  "memory_mb": 45,
  "load_time_ms": 120
}
```

### M6: Minimal Artifacts List Incomplete
**Location**: Lines 46-50
**Impact**: Missing essential artifacts:
- training_config.json (hyperparameters, random seed)
- validation_report.md (detailed metrics, plots)
- test_parity.py (reproducible parity test)
**Fix**: Expand artifact requirements.

### M7: Handoff Content Not Specified
**Location**: Lines 52-55
**Impact**: "Handoffs to ORACLE/SENTINEL/FORGE" but WHAT is handed off?
- Just the ONNX file?
- Full artifact bundle?
- Integration code?
- Test harness?
**Fix**: Specify handoff content for each destination.

---

## LOW ISSUES (4 findings)

### L1: No A/B Testing or Shadow Mode Mentioned
**Impact**: No path to validate model in production before going live.
**Fix**: Add optional shadow mode deployment step.

### L2: No Ensemble Support
**Impact**: Single model assumption. No guidance for combining multiple models.
**Fix**: Add section for ensemble approaches if needed.

### L3: No Model Card Template
**Impact**: Model documentation format not standardized.
**Fix**: Provide model_card.md template.

### L4: No Cross-Validation Strategy Specified
**Impact**: Walk-forward mentioned but specific CV approach not defined.
**Fix**: Specify: "Use TimeSeriesSplit or walk-forward with minimum 5 folds"

---

## ASSUMPTIONS CHALLENGED

| Assumption | Challenge | Recommendation |
|------------|-----------|----------------|
| e2b sandbox matches production | Different CPU/GPU, library versions | Require production benchmark or specify e2b config |
| StandardScaler is sufficient | Some features need different transforms | Support transform pipeline |
| WFE>=0.6 is reliable | Aggregate metric may hide regime-specific failures | Add regime-specific validation |
| ONNX <5ms is the constraint | Total inference path may exceed budget | Define end-to-end budget |
| "Temporal splits" is clear | Multiple interpretations exist | Specify walk-forward parameters |
| ORACLE can validate ML | Traditional ORACLE may miss ML-specific biases | Verify ORACLE ML capabilities |

---

## EDGE CASES TESTED

| Scenario | Result |
|----------|--------|
| Model predicts exactly 0.65 threshold | Not addressed - floating point comparison risk |
| Empty feature list after selection | Not addressed |
| Training data has gaps/duplicates | Not addressed |
| Feature window > available data | Not addressed |
| NaN in feature at inference time | Not addressed |
| Prediction = 0.99 (extreme confidence) | Not addressed - no calibration check |
| Multiple targets requested | Partially addressed (examples given but no protocol) |
| ONNX runtime version mismatch | Not addressed |

---

## STRESS TEST RESULTS

| Condition | Outcome |
|-----------|---------|
| e2b sandbox timeout | No retry/fallback documented |
| Training fails to converge | No error handling |
| Model size > 100MB | No size limits specified |
| Inference latency spikes under load | Only static benchmark required |
| ONNX export fails | No error handling |

---

## MANUAL VERIFICATION NEEDED

- [ ] Verify ORACLE has ML-specific validation capabilities (target leakage, train/test contamination)
- [ ] Confirm e2b sandbox configuration matches production requirements
- [ ] Check if existing models follow this spec (gap analysis)
- [ ] Verify SENTINEL integration for Apex compliance checks
- [ ] Review if CLAUDE.md sample requirements are properly inherited

---

## CONFIDENCE: HIGH

**Reason**: Comprehensive adversarial review completed using all 7 CRITIC techniques. Spec was analyzed line-by-line and compared against CLAUDE.md v3.10.9 requirements and CRITIC v1.1 standards.

---

## PRE-MORTEM SUMMARY

**Most likely failure mode**: Model passes statistical validation (WFE/PSR/DSR) but fails in production due to:
1. Feature drift not detected (no monitoring)
2. Parity issues between Python training and production runtime
3. Latency spikes under production load (only sandbox benchmarked)

**Second most likely**: Apex violation due to model predictions near market close leading to trades after 4:30 PM ET, caught only after deployment because SENTINEL check was not mandatory.

**Mitigation**:
1. Make SENTINEL check mandatory before GO
2. Add feature drift monitoring
3. Require production hardware benchmark (not just e2b sandbox)
4. Add time-of-day awareness to model or validation

---

## RECOMMENDED IMPROVEMENTS (Priority Order)

1. **CRITICAL**: Add version reporting header to output format
2. **CRITICAL**: Create structured output template matching CRITIC's detail
3. **CRITICAL**: Define end-to-end latency budget (not just ONNX)
4. **CRITICAL**: Make SENTINEL approval mandatory before GO
5. **CRITICAL**: Complete CRITIC self-review with all 7 techniques
6. **HIGH**: Add model versioning and registry system
7. **HIGH**: Add feature drift monitoring requirements
8. **HIGH**: Define escalation triggers table
9. **HIGH**: Add error handling protocol
10. **MEDIUM**: Expand benchmark requirements (p99, memory, load time)

---

*CRITIC v1.1 - Adversarial Quality Guardian*
*"Every gap found now is a failure prevented later."*
