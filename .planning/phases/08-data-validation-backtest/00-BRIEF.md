# PROJECT BRIEF: Data Validation & Backtesting Pipeline

**Project**: EA_SCALPER_XAUUSD - Apex Trading
**Phase ID**: 08-data-validation-backtest
**Created**: 2025-12-15
**Owner**: Franco
**Status**: PLANNING

---

## Executive Summary

Comprehensive data validation and backtesting pipeline to ensure 100% data quality for the XAUUSD scalping strategy before go-live. This plan covers:

1. **Full validation of 654.6M ticks** (stride-1 catalog, 2003-2025)
2. **Session catalog validation** (6 trading sessions)
3. **Infrastructure cleanup** (remove redundant data, update configs)
4. **Backtesting framework** (event-driven, WFA, Monte Carlo)
5. **GO/NO-GO decision** (statistical validation against thresholds)

---

## Current State Assessment

### Data Assets

| Asset | Size | Ticks | Period | Status |
|-------|------|-------|--------|--------|
| Stride-1 COMPLETE Catalog | 13 GB | 654.6M | 2003-2025 | ✅ Built |
| Stride-20 Parquet | 393 MB | 32.7M | 2003-2025 | ✅ Available |
| Session Catalogs (6) | ~2 GB each | Variable | 2003-2025 | ⚠️ Needs validation |
| Redundant CSVs | 14 GB | N/A | N/A | ❌ To delete |

### Validation Infrastructure

| Component | Status | Location |
|-----------|--------|----------|
| validate_data_v2.py | ✅ Ready | scripts/oracle/ |
| validate_nautilus_catalog.py | ✅ Ready | scripts/data/ |
| quick_check_parquet.py | ✅ Ready | scripts/ |
| validate_data_structure.py | ✅ Ready | scripts/ |
| Schema validator | ❌ Missing | To create |
| Temporal consistency | ❌ Missing | To create |
| Catalog integrity | ⚠️ Basic | To enhance |

### Backtesting Infrastructure

| Component | Status | Location |
|-----------|--------|----------|
| BacktestEngine integration | ✅ Ready | nautilus_gold_scalper/scripts/ |
| Event-driven engine | ⚠️ Documented | scripts/backtest/ |
| WFA scripts | ✅ Ready | scripts/oracle/ |
| Monte Carlo | ✅ Ready | scripts/oracle/ |
| GO/NO-GO validator | ✅ Ready | scripts/oracle/ |

---

## Configuration Issues to Fix

### Critical: config.yaml Outdated

```yaml
# Current (incorrect):
active_dataset: xauusd_2003_2025_stride1_full

# Should be:
active_dataset: xauusd_2003_2025_stride1_COMPLETE
```

---

## Success Criteria

### Data Quality

| Metric | Threshold | Priority |
|--------|-----------|----------|
| Coverage | ≥36 months | CRITICAL |
| Clean data | ≥99% | CRITICAL |
| Critical gaps (>24h) | 0 | CRITICAL |
| Quality score | ≥70/100 | HIGH |
| Regime diversity | All 3 >10% | MEDIUM |
| Session coverage | All 6 >5% | MEDIUM |
| Avg spread | <30 cents | MEDIUM |

### Backtest Validation (GO/NO-GO)

| Metric | Threshold | Source |
|--------|-----------|--------|
| Walk-Forward Efficiency (WFE) | ≥0.60 | BACKTEST_MASTER_PLAN.md |
| OOS Windows Positive | ≥70% | BACKTEST_MASTER_PLAN.md |
| Monte Carlo 95th DD | <8% | BACKTEST_MASTER_PLAN.md |
| Probabilistic Sharpe (PSR) | ≥0.90 | BACKTEST_MASTER_PLAN.md |
| Risk of Ruin (10% DD) | <5% | BACKTEST_MASTER_PLAN.md |
| P(Daily DD Breach) | <5% | BACKTEST_MASTER_PLAN.md |
| P(Total DD Breach) | <2% | BACKTEST_MASTER_PLAN.md |
| Minimum Trades | ≥100 | BACKTEST_MASTER_PLAN.md |
| Profit Factor | ≥1.3 | BACKTEST_MASTER_PLAN.md |
| Realized Max DD | <8% | BACKTEST_MASTER_PLAN.md |

---

## Orchestration Model

### Resource Allocation

- **Parallel Execution**: Unlimited (user confirmed capacity)
- **Per-Round Agents**: No limit (override default 2-3)
- **Model Policy**: Opus for all trading/validation agents

### Agent Mapping

| Phase | Agents | Parallelism |
|-------|--------|-------------|
| Phase 1: Discovery | 1 (Orchestrator) | Sequential |
| Phase 2: Main Catalog Validation | 8 validators | Full parallel |
| Phase 3: Session Validation | 6 validators | Full parallel |
| Phase 4: Integrity & Cleanup | 3 validators | Full parallel |
| Phase 5: Advanced Validation | 4 validators | Full parallel |
| Phase 6: Backtest Framework | 3 builders | Sequential |
| Phase 7: Backtest Execution | 4+ runners | Full parallel |
| Phase 8: GO/NO-GO | 1 (ORACLE) | Sequential |

---

## Risk Register

| Risk | Impact | Mitigation |
|------|--------|------------|
| Context overflow | HIGH | Checkpoint summaries between phases |
| Catalog corruption | HIGH | Validate before any cleanup |
| False positive quality | MEDIUM | Use multiple validators in parallel |
| Backtest overfitting | HIGH | Strict OOS validation, Monte Carlo |
| Data loss | CRITICAL | No deletions without validation |

---

## Key Documents

- **BACKTEST_MASTER_PLAN.md**: `DOCS/04_REPORTS/VALIDATION/`
- **DATA_QUALITY_REPORT.md**: `DOCS/04_REPORTS/VALIDATION/`
- **NAUTILUS_DATA_PIPELINE_HANDOFF**: `DOCS/03_RESEARCH/FINDINGS/`
- **DB_OPTIMIZATION_REPORT**: `DOCS/03_RESEARCH/FINDINGS/`

---

## Deliverables

1. **DATA_VALIDATION_REPORT.md**: Complete quality assessment
2. **SESSION_VALIDATION_REPORT.md**: Per-session validation results
3. **CLEANUP_REPORT.md**: Redundant data removal summary
4. **BACKTEST_RESULTS.md**: WFA, Monte Carlo, statistical analysis
5. **GO_NOGO_DECISION.md**: Final recommendation with evidence

---

## Next Steps

See `00-ROADMAP.md` for phase sequence and `0X-PHASE-PLAN.md` for detailed execution plans.
