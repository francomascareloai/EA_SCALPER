# EXECUTION GUIDE: Phase 09 - Strategy Activation

**Document:** 00-EXECUTION-GUIDE.md
**Version:** 1.1
**Created:** 2025-12-23
**Master Plan:** 01-ROADMAP-FINAL.md (v2.0 ARGUS-Integrated)

---

## Quick Reference

```
OUTPUT FOLDER: .planning/phases/09-strategy-activation/orchestration/
```

---

## Execution Prompts

### Phase 00-A: BASELINE VALIDATION

```
/run-plan .planning/phases/09-strategy-activation/09-PHASE-00A-PLAN.md
```

---

### Phase 00-B: CRITICAL BUG FIXES

```
/run-plan .planning/phases/09-strategy-activation/10-PHASE-00B-PLAN.md
```

---

### Phase 01: DIAGNOSTIC & BASELINE

```
/run-plan .planning/phases/09-strategy-activation/02-PHASE-01-PLAN.md
```

---

### Phase 02: SMC DEEP AUDIT

```
/run-plan .planning/phases/09-strategy-activation/03-PHASE-02-PLAN.md
```

---

### Phase 03: TREND_FOLLOW ACTIVATION

```
/run-plan .planning/phases/09-strategy-activation/04-PHASE-03-PLAN.md
```

---

### Phase 04: MEAN_REVERT DECISION

```
/run-plan .planning/phases/09-strategy-activation/05-PHASE-04-PLAN.md
```

---

### Phase 05: FRAMEWORK INTEGRATION

```
/run-plan .planning/phases/09-strategy-activation/06-PHASE-05-PLAN.md
```

---

### Phase 06: MULTI-STRATEGY BACKTEST

```
/run-plan .planning/phases/09-strategy-activation/07-PHASE-06-PLAN.md
```

---

### Phase 07: PAPER TRADING

```
/run-plan .planning/phases/09-strategy-activation/11-PHASE-07-PLAN.md
```

---

### Phase 08: PRODUCTION READINESS

```
/run-plan .planning/phases/09-strategy-activation/12-PHASE-08-PLAN.md
```

---

## Execution Order

```
Phase 00-A (2-4h) → GO/NO-GO gate
      ↓
Phase 00-B (1 week) → Bug fixes
      ↓
Phase 01 (3 days) → Diagnostics
      ↓
Phase 02 (2 weeks) → SMC audit
      ↓
Phase 03 (1 week) → TREND_FOLLOW
      ↓
Phase 04 (3 days) → MEAN_REVERT decision
      ↓
Phase 05 (1 week) → Integration
      ↓
Phase 06 (1 week) → Multi-strategy backtest
      ↓
Phase 07 (2 weeks) → Paper trading
      ↓
Phase 08 (1 week) → Production readiness
```

**Total: 10-11 weeks**

---

## Output Files

### Orchestration Folder

```
.planning/phases/09-strategy-activation/orchestration/
├── PHASE_00A_BASELINE_RESULTS.md
├── PHASE_00B_BUGFIX_REPORT.md
├── PHASE_01_DIAGNOSTIC_RESULTS.md
├── LOOKAHEAD_CHECKLIST.md
├── NAUTILUS_CONFIG_AUDIT.md
├── HWM_PROTECTION_DESIGN.md
├── PHASE_02_SMC_AUDIT.md
├── PHASE_03_TREND_FOLLOW.md
├── MEAN_REVERT_RESEARCH.md
├── PHASE_04_DECISION.md
├── PHASE_05_INTEGRATION.md
├── FAILURE_MODE_MATRIX.md
├── PHASE_06_MULTI_STRATEGY.md
├── EXECUTION_MODE_TEST.md
├── PHASE_07_PAPER_TRADING.md
├── PHASE_08_CRITIC_REVIEW.md
└── PHASE_08_SENTINEL_APPROVAL.md
```

---

## Hard Exit Criteria

| Gate | Condition | Action |
|------|-----------|--------|
| Phase 00-A | EMA > SMC | STOP or PIVOT |
| Phase 00-B | Bugs not fixed after 2 weeks | STOP or PIVOT |
| Phase 01 | < 50 trades after fix | Trigger Plan B |
| Phase 02 | WFE < 0.3 on dev set | STOP |
| Holdout | Negative return 2021-2025 | STOP |
| Any | Engineering hours > 400 | HARD PAUSE |

---

*End of Execution Guide*
