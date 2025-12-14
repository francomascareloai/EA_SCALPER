# Realistic Backtest Validation Plan - Summary

## One-Liner

7-phase validation framework: Fix P0 blockers (4.25d) → Dukascopy data prep → Baseline backtest → WFA (16 folds, WFE ≥ 0.55) → Monte Carlo (10k runs, 95th DD < 8%) → GO/NO-GO decision → Paper trading (30d)

---

## Version

**v1.0** - Initial plan (2025-12-07)

---

## Key Components

| Component | Details |
|-----------|---------|
| **Test Scenarios** | 15 scenarios: 4 normal, 5 stress, 7 edge cases |
| **WFA Protocol** | 16 folds, 6mo IS / 3mo OOS, anchored expanding window |
| **Monte Carlo** | 10,000 bootstrap simulations with slippage/spread variations |
| **Success Threshold** | WFE ≥ 0.55, 95th percentile DD < 8%, P(ruin) < 1% |
| **Apex Compliance** | 0 tolerance for violations (DD breach, time, overnight, consistency) |
| **Timeline** | ~44 days total (14 days validation + 30 days paper trading) |

---

## Current State (from Audits)

| Audit | Status | Key Finding |
|-------|--------|-------------|
| **001: Migration** | 87.5% complete | 5 modules are stubs; ORACLE bugs #2 & #4 unfixed |
| **002: Data** | APPROVED | Dukascopy recommended (20+ years free tick data) |
| **003: Backtest Code** | CONDITIONAL | Realism 5/10; CircuitBreaker orphaned; no metrics telemetry |
| **004: Apex Risk** | NO-GO | Score 3/10; missing time constraints, consistency rule |

---

## P0 Blockers (Must Fix First)

| Issue | Source | Effort | Priority |
|-------|--------|--------|----------|
| TimeConstraintManager (4:59 PM ET deadline) | Audit 004 | 16 hr | CRITICAL |
| Consistency rule (30% daily profit limit) | Audit 004 | 8 hr | CRITICAL |
| CircuitBreaker integration | Audit 003/004 | 4 hr | HIGH |
| Execution threshold 65→70 | Audit 001 | 0.25 hr | HIGH |
| YAML realism knobs (slippage/commission) | Audit 003 | 2 hr | HIGH |
| Metrics telemetry (Sharpe/Sortino/Calmar/SQN) | Audit 003 | 3 hr | MEDIUM |

**Total P0 Effort**: ~34 hours (4.25 days)

---

## GO/NO-GO Decision Framework

```
P0 Fixed? → Core Metrics ≥ Min? → Apex 0 Violations? → WFE ≥ 0.55? → MC 95th DD < 8%? → GO
    ↓              ↓                    ↓                  ↓               ↓
 NO-GO         NO-GO               NO-GO              NO-GO           NO-GO
```

| Verdict | Criteria |
|---------|----------|
| **GO** | All thresholds passed → Paper trading approved |
| **CONDITIONAL** | Minor concerns → Fix and re-run affected tests |
| **NO-GO** | Critical failure → Return to development |

---

## Decisions Needed

1. **Approve Dukascopy** as primary data source (per audit 002)
2. **Approve timeline** (~44 days to live trading)
3. **Confirm Apex slippage/commission** values for realism modeling
4. **Decide ML inclusion** - Test ML modules separately or in main validation?

---

## Blockers

| Blocker | Impact | Resolution Path |
|---------|--------|-----------------|
| P0 issues unfixed | Cannot start validation | Complete Phase 1 (4.25 days) |
| Apex demo account | Cannot paper trade | Owner to provision |
| NinjaTrader adapter | Cannot go live | Complete after paper trading |

---

## Timeline Overview

| Phase | Duration | Output |
|-------|----------|--------|
| 1. Fix Issues | 4.25 days | All P0 resolved |
| 2. Data Prep | 2 days | QC'd Parquet files |
| 3. Baseline | 2 days | Metrics baseline |
| 4. WFA | 3 days | WFE scores |
| 5. Monte Carlo | 2 days | Risk distribution |
| 6. GO/NO-GO | 1 day | Final verdict |
| 7. Paper Trading | 30 days | Live readiness |
| **Total** | **~44 days** | **Live trading approval** |

---

## Next Steps

| # | Action | Owner | Target |
|---|--------|-------|--------|
| 1 | Fix ORACLE Bug #2 (threshold 65→70) | FORGE | Day 1 |
| 2 | Implement TimeConstraintManager | FORGE | Day 1-2 |
| 3 | Implement consistency rule | FORGE | Day 3 |
| 4 | Integrate CircuitBreaker | FORGE | Day 4 |
| 5 | Download Dukascopy data | FORGE | Day 6 |
| 6 | Run baseline backtest | ORACLE | Day 8 |

---

## Files

| File | Purpose |
|------|---------|
| `realistic-backtest-plan.md` | Full validation plan (this document's source) |
| `SUMMARY.md` | Executive summary (this document) |

---

## Confidence Level

**HIGH** - Plan synthesizes findings from 4 comprehensive audits with industry-standard validation methodology (WFA, Monte Carlo). All thresholds are conservative and Apex-compliant. Main uncertainty is execution timeline (P0 fixes may take longer).

---

*Created: 2025-12-07 | Version: 1.0*
