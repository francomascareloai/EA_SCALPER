# Realistic Backtest Validation Plan - Summary

## One-Liner

7-phase validation framework: Fix P0 blockers (4.25d) → Dukascopy data prep + realism calibration (2.5d) → Baseline backtest + Apex validation (2.5d) → WFA (18 rolling folds, WFE ≥ 0.60 target) → Monte Carlo (10k runs, 95th DD < 8%) + Apex validation → GO/NO-GO decision → Paper trading (30d)

---

## Version

**v1.1** - Fixed critical audit findings (2025-12-07)
- v1.0: Initial plan
- v1.1: Fixed WFA rolling windows (18 folds), tightened WFE to 0.60, corrected metadata, added Apex compliance validation, added realism calibration

---

## Key Components

| Component | Details |
|-----------|---------|
| **Test Scenarios** | 16 scenarios: 4 normal, 5 stress, 7 edge cases |
| **WFA Protocol** | 18 folds, 6mo IS / 3mo OOS, rolling window (no data leakage) |
| **Monte Carlo** | 10,000 bootstrap simulations with slippage/spread variations |
| **Success Threshold** | WFE ≥ 0.60 (target), ≥ 0.50 (minimum), 95th percentile DD < 8%, P(ruin) < 1% |
| **Apex Compliance** | 0 tolerance for violations (DD breach, time, overnight, consistency) |
| **Timeline** | ~50 days total (20 days validation with buffer + 30 days paper trading) |

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
P0 Fixed? → Core Metrics ≥ Min? → Apex 0 Violations? → WFE ≥ 0.60 (target) or ≥ 0.50 (min)? → MC 95th DD < 8%? → GO
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
2. **Approve timeline** (~50 days to live trading with 20% buffer)
3. **Confirm Apex slippage/commission** values for realism calibration task
4. **Decide ML inclusion** - Test ML modules separately or in main validation?
5. **Approve compute optimization** - Use parallel fold execution or cloud compute to reduce timeline?

---

## Blockers

| Blocker | Impact | Resolution Path |
|---------|--------|-----------------|
| ~~P0 issues unfixed~~ | ~~Cannot start~~ | ✅ **RESOLVED** (2025-12-07: All P0 items complete) |
| ~~Data download pending~~ | ~~Cannot backtest~~ | ✅ **RESOLVED** (2025-12-07: 25.5M ticks ready) |
| ~~Baseline backtest~~ | ~~Cannot validate~~ | ✅ **RESOLVED** (2025-12-09: Executed successfully) |
| Apex demo account | Cannot paper trade | Owner to provision |
| NinjaTrader adapter | Cannot go live | Complete after paper trading |

---

## Timeline Overview

| Phase | Duration | Output |
|-------|----------|--------|
| 1. Fix Issues | 4.25 days | All P0 resolved |
| 2. Data Prep + Calibration | 2.5 days | QC'd Parquet files, realism params calibrated |
| 3. Baseline + Apex Validation | 2.5 days | Metrics baseline, 0 violations confirmed |
| 4. WFA (18 folds) + Compliance | 4 days | WFE scores, Apex validated across folds |
| 5. Monte Carlo + Compliance | 2.5 days | Risk distribution, Apex validated |
| 6. GO/NO-GO | 1 day | Final verdict |
| 7. Paper Trading | 30 days | Live readiness |
| **Total** | **~50 days** (with 20% buffer) | **Live trading approval** |

---

## Next Steps

| # | Action | Owner | Status |
|---|--------|-------|--------|
| 1 | Fix ORACLE Bug #2 (threshold 65→70) | FORGE | ✅ DONE |
| 2 | Implement TimeConstraintManager | FORGE | ✅ DONE |
| 3 | Implement consistency rule | FORGE | ✅ DONE |
| 4 | Integrate CircuitBreaker | FORGE | ✅ DONE |
| 5 | ~~Download Dukascopy data~~ | FORGE | ✅ **DATA EXISTS** (25.5M ticks) |
| 6 | Run baseline backtest | ORACLE | ✅ **EXECUTADO (2025-12-09)** |

**UPDATE 2025-12-07**: Items 1-10 complete (91%). Data at `data/ticks/xauusd_2020_2024_stride20.parquet`.
**UPDATE 2025-12-11**: Baseline backtest executed successfully after audit.

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

*Created: 2025-12-07 | Updated: 2025-12-11 (após auditoria) | Version: 1.1*
