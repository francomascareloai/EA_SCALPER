# Nautilus Deep Audit - MANIFEST

## Audit Session
- **Start Date:** 2025-12-16
- **Baseline Tag:** `audit-baseline-20251216`
- **Total Scope:** ~40,588 lines (20,256 src + 20,332 scripts)
- **All Plans Status:** 12/12 APPROVED by CRITIC (initial) + 5/5 APPROVED WITH NOTES (ARGUS integration review)

## Phase Status

| Phase | Status | Output File | Key Findings | Issues |
|-------|--------|-------------|--------------|--------|
| 00 | COMPLETE | PHASE_00_FINDINGS.md | All thresholds verified, baseline GREEN | 0 CRITICAL, 0 HIGH, 2 MEDIUM |
| 01 | COMPLETE (BLOCKED) | PHASE_01_FINDINGS.md | CRITICAL HWM MID pricing + time reset/session timezone risks | 1 CRITICAL, 3 HIGH, 3 MEDIUM, 2 LOW |
| 02 R0 | COMPLETE | PHASE_02_R0_MTF_FINDINGS.md | MTFManager clean; caller must provide completed bars | 0 CRITICAL, 0 HIGH, 2 MEDIUM, 3 LOW |
| 02 R1 | COMPLETE (REMEDIATED) | PHASE_02_R1_B_FINDINGS.md | Remediated OB/FVG temporal design: no future bars in detection | 2 CRITICAL, 6 HIGH, 8 MEDIUM, 6 LOW |
| 02 R2 | COMPLETE | PHASE_02_R2_FOLLOWUP_FINDINGS.md | R1 remediations verified (OB/FVG causal), tests present for OB/FVG/Liquidity; remaining items are completeness/enhancements | 0 CRITICAL, 5 HIGH (defer), 2 MEDIUM (open), 0 LOW |
| 03 | COMPLETE (REMEDIATED) | PHASE_03_B_APEX_FINDINGS.md | Remediated time gates + DD semantics + conservative HWM pricing + validate_trade gate | 9 CRITICAL, 11 HIGH, 9 MEDIUM, 2 LOW |
| 03 R2 | COMPLETE | PHASE_03_R2_FOLLOWUP_FINDINGS.md | Re-validated Phase 03 integration contracts: time gates + validate_trade are wired; remaining risks are fail-open on feed errors and no independent close scheduler | 0 CRITICAL (verified), 2 HIGH (open), 2 MEDIUM (open), 0 LOW |
| 04 | COMPLETE (BLOCKED) | PHASE_04_FINDINGS.md | Scoring correctness (at_poi), MTF test mismatch, news tz crash risk | 3 CRITICAL, 6 HIGH, 10 MEDIUM, 5 LOW |
| 04.5 | COMPLETE (BLOCKED) | PHASE_04.5_ML_FINDINGS.md | Stacking KFold look-ahead + train/inference parity gaps | 1 CRITICAL, 2 HIGH, 2 MEDIUM |
| 05 | COMPLETE (BLOCKED) | PHASE_05_FINDINGS.md | Execution lifecycle not production-ready; adapters stubs; protective orders not guaranteed | 9 CRITICAL, 5 HIGH, 4 MEDIUM, 0 LOW |
| 06 R1 | COMPLETE (BLOCKED) | PHASE_06_FINDINGS.md | Confirmed temporal leakage + Apex invariants missing across scripts | 12 CRITICAL, 21 HIGH, 19 MEDIUM, 8 LOW |
| 06 R2 | COMPLETE (BLOCKED) | PHASE_06_FINDINGS.md | Validation scripts inherit leakage / execution optimism | 12 CRITICAL, 21 HIGH, 19 MEDIUM, 8 LOW |
| 07 | COMPLETE (BLOCK) | PHASE_07_COVERAGE_FINDINGS.md | Coverage below minimums; strategy orchestration largely untested | 2 CRITICAL, 3 HIGH, 2 MEDIUM, 0 LOW |
| 08 | COMPLETE (BLOCKED) | PHASE_08_FINDINGS.md | Integration blockers: fail-safe execution, DD force-flat, time-gate scheduler, timestamp wiring | 7 CRITICAL, 10 HIGH, 6 MEDIUM, 2 LOW |
| 09 | COMPLETE (NO-GO) | AUDIT_REPORT.md | Final synthesis: NO-GO; move to remediation WPs | Open issues (deduped): 40 CRITICAL, 54 HIGH, 42 MEDIUM, 17 LOW |

## Plan Review Status (CRITIC)

| File | Review 1 | Fixes | Review 2 | Final |
|------|----------|-------|----------|-------|
| 01-PHASE-00-PLAN.md | NEEDS REVISION | Applied | APPROVED | ✅ |
| 02-PHASE-01-PLAN.md | APPROVED WITH CHANGES | Applied | APPROVED | ✅ |
| 03-PHASE-02-PLAN.md | NEEDS REVISION | Applied | APPROVED | ✅ |
| 04-PHASE-03-PLAN.md | NEEDS REVISION | Applied | APPROVED | ✅ |
| 05-PHASE-04-PLAN.md | APPROVED WITH CHANGES | Applied | APPROVED | ✅ |
| 05.5-PHASE-04.5-PLAN.md | NEEDS REVISION | Applied | APPROVED | ✅ |
| 06-PHASE-05-PLAN.md | NEEDS REVISION | Applied | APPROVED | ✅ |
| 07-PHASE-06-PLAN.md | APPROVED WITH NOTES | Applied | APPROVED | ✅ |
| 08-PHASE-07-PLAN.md | NEEDS REVISION | Applied | APPROVED | ✅ |
| 09-PHASE-08-PLAN.md | NEEDS REVISION | Applied | APPROVED | ✅ |
| 10-PHASE-09-PLAN.md | CONDITIONALLY APPROVED | Applied | APPROVED | ✅ |
| PROTOCOLS.md | NEEDS REVISION | Applied | APPROVED | ✅ |

## Files in orchestration/

| File | Phase | Description |
|------|-------|-------------|
| MANIFEST.md | - | This index file |
| baseline_git_status.txt | 00 | Git status at audit start |
| baseline_git_log.txt | 00 | Recent commits at audit start |
| baseline_pytest.txt | 00 | Pytest results (all passing) |
| PHASE_00_FINDINGS.md | 00 | Foundation verification results |
| PHASE_01_FINDINGS.md | 01 | Core strategy audit findings |
| PHASE_01_CRITIC_REVIEW.md | 01 | External CRITIC adversarial review |
| PHASE_02_R0_MTF_FINDINGS.md | 02 R0 | MTFManager temporal integrity findings |
| PHASE_02_R1_A_FINDINGS.md | 02 R1 | Indicators A (AMD/Regime/Session/Footprint) findings |
| PHASE_02_R1_B_FINDINGS.md | 02 R1 | Indicators B (OrderBlock/FVG) findings - BLOCKED |
| PHASE_02_R1_C_FINDINGS.md | 02 R1 | Indicators C (Liquidity/Structure) findings |
| PHASE_03_A_DD_FINDINGS.md | 03 | Risk DD stack findings |
| PHASE_03_B_APEX_FINDINGS.md | 03 | Risk Apex rules findings |
| PHASE_03_C_SIZING_FINDINGS.md | 03 | Risk sizing stack findings |
| PHASE_03_INTEGRATION_FINDINGS.md | 03 | Risk integration verification findings |
| PHASE_03_R2_FOLLOWUP_FINDINGS.md | 03 R2 | Risk integration follow-up (R2) |
| PHASE_04.5_ML_FINDINGS.md | 04.5 | ML pipeline audit findings |

## Issue Summary (Cumulative)

> Canonical inventory: `ISSUES_TRACKER.md` (deduped). Counts below reflect the current post-audit deduped open inventory.

| Severity | Count | Resolved | Open |
|----------|-------|----------|------|
| CRITICAL | 40 | - | 40 |
| HIGH | 54 | - | 54 |
| MEDIUM | 42 | - | 42 |
| LOW | 17 | - | 17 |

## Open Issues (Cumulative)

> NOTE: This table is legacy/incomplete. Use `ISSUES_TRACKER.md` for the full deduped inventory and current statuses.

| ID | Phase | Severity | Description | Status |
|----|-------|----------|-------------|--------|
| M-001 | 00 | MEDIUM | DEFAULT_RISK_PER_TRADE differs (1% vs 0.5%) - MORE CONSERVATIVE | Acceptable |
| M-002 | 00 | MEDIUM | Consistency limit uses 25% (vs Apex 30%) - POSITIVE BUFFER | Acceptable |
| M-003 | 02 R0 | MEDIUM | No HTF bar completion verification (caller contract) | Open |
| M-004 | 02 R0 | MEDIUM | EMA performance borderline (needs profiling) | Open |
| L-001 | 02 R0 | LOW | No gap detection in momentum | Open |
| L-002 | 02 R0 | LOW | No warmup property exposed | Open |
| L-003 | 02 R0 | LOW | No formal warmup validation beyond exception | Open |
| C-001 | 01 | CRITICAL | Apex HWM price-basis violation: MID mark-to-market (must use BID/ASK conservative) | Resolved |
| C-002 | 02 R1 | CRITICAL | Look-ahead bias: OrderBlockDetector uses future bars for displacement confirmation | Resolved |
| C-003 | 02 R1 | CRITICAL | Look-ahead bias: FVGDetector accesses `index+1` (future bar) by design | Resolved |
| H-001 | 01 | HIGH | Daily reset not ET-anchored (timer-based reset risks drift) | Resolved |
| H-002 | 01 | HIGH | Session detection uses UTC-now buckets (DST + nondeterministic backtests) | Open |
| H-003 | 01 | HIGH | Time-gate enforcement depends on external manager (Phase 01 cannot verify 4:55/4:59 behavior) | Open |
| H-004 | 02 R1 | HIGH | Caller contract not enforced for bar completion (array `[-1]` usage) | Open |
| H-005 | 02 R1 | HIGH | Missing unit tests for liquidity/structure indicators | Open |
| H-006 | 02 R1 | HIGH | Missing internal vs external liquidity/structure distinction | Open |
| H-007 | 02 R1 | HIGH | Breaker block mentioned but not implemented (OB) | Open |
| H-008 | 02 R1 | HIGH | IFVG not implemented (FVG) | Open |
| H-009 | 02 R1 | HIGH | SessionFilter late-hours fallback may misclassify session | Open |
| C-ML-001 | 04.5 | CRITICAL | StackingEnsemble uses KFold (non-temporal) -> look-ahead leakage if used | Open |
| H-ML-001 | 04.5 | HIGH | Scaling/parity not enforced; scaler not persisted -> leakage + inference drift risk | Open |
| H-ML-002 | 04.5 | HIGH | No index order validation -> rolling windows can leak if data sorted descending | Open |
| M-ML-001 | 04.5 | MEDIUM | Feature order/metadata not enforced; silent inference mismatch risk | Open |
| M-ML-002 | 04.5 | MEDIUM | Label alignment not validated; future-shift labels can leak | Open |

## Session Log

| Session | Date | Phases | Notes |
|---------|------|--------|-------|
| 1 | 2025-12-16 | 00 + Plan Review | Foundation verification + All 12 plans CRITIC reviewed and approved |
| 2 | 2025-12-16 | ARGUS Research | Prop Firm Failures (47 modes), Look-Ahead Detection (17 patterns), NT8 Add-On Stealth, Human Behavior Simulator Spec |
| 3 | 2025-12-16 | CRITIC Re-Review | 5 plans updated with ARGUS findings, all APPROVED WITH NOTES, fixes applied |
| 4 | 2025-12-17 | 02 R0 | MTFManager temporal integrity gate complete; venv created; pytest + mypy strict on mtf_manager.py pass |
| 5 | 2025-12-18 | 02 R1 | Parallel indicator audits complete; Agent B reports CRITICAL look-ahead in OB/FVG (BLOCKING) |
| 6 | 2025-12-18 | 01 | Core strategy audit complete; CRITIC confirms NO-GO due to MID HWM + time semantics risks |
| 7 | 2025-12-18 | 03 | Risk modules audit complete; multiple Apex compliance blockers (time gates, trailing DD semantics, per-trade cap, integration) |
| 8 | 2025-12-18 | 01+03 remediation | Implemented Apex time gates + DD safety buffer (4.0%) + conservative BID/ASK HWM mark-to-market + validate_trade gate; pytest passing |
| 9 | 2025-12-18 | 02 R1 remediation | Removed look-ahead in OB/FVG detectors (causal confirmation); pytest + mypy strict allowlist passing |

## ARGUS Research Outputs

| File | Topic | Key Findings |
|------|-------|--------------|
| ARGUS_PROP_FIRM_FAILURES.md | Apex Failure Modes | 47 failure modes, automation BANNED on PA/Live, TRADOVATE trailing never locks |
| ARGUS_LOOKAHEAD_DETECTION.md | Look-Ahead Bias | 17 grep patterns, PBO/DSR thresholds, NautilusTrader config |
| ARGUS_NINJATRADER_OIF.md | NinjaTrader Integration | OIF (not OTP), ATI audit trail, latency ~50-100ms |
| ARGUS_NT8_ADDON_STEALTH.md | Stealth Execution | OrderEntry.Manual, CME tag 1028, human simulation |
| HUMAN_BEHAVIOR_SIMULATOR_SPEC.md | Humanization | 16 techniques, Python + C# implementation, edge cost ~15-20% |

## CRITIC Re-Review Summary (ARGUS Integration)

| Plan | Verdict | Critical | High | Medium | Low | Fixes Applied |
|------|---------|----------|------|--------|-----|---------------|
| Phase 02 | APPROVED WITH NOTES | 0 | 0 | 2 | 7 | None required |
| Phase 03 | APPROVED WITH NOTES | 0 | 3 | 4 | 2 | Integration noted |
| Phase 04.5 | APPROVED WITH NOTES | 0 | 1 | 5 | 6 | PBO 20% justified |
| Phase 05 | APPROVED WITH NOTES | 0 | 2 | 5 | 2 | OIF defined, connection monitoring added |
| PROTOCOLS | APPROVED WITH NOTES | 1 | 6 | 6 | 4 | SQN>7.0, MC95 DD, HWM clarification |

---

## Execution Guide

**See:** `EXECUTION-GUIDE.md` for step-by-step commands

## Next Step

**Resolve Phase 02 R1 BLOCKER (OB/FVG temporal design), then proceed with Phase 01**

```
Phase 02 R1 is BLOCKED due to reported look-ahead bias in order_block_detector.py and fvg_detector.py. Reconcile indicator semantics (confirmation lag vs look-ahead) before continuing Phase 02 R2.

Proceed with Phase 01 Core Strategy Audit in parallel if desired: follow .planning/phases/08-nautilus-deep-audit/02-PHASE-01-PLAN.md and write findings to orchestration/PHASE_01_FINDINGS.md.
```
