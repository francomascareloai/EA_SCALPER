# HEAVY AUDIT PLAN - 5 Rounds of Empirical Testing

**Date:** 2025-12-24
**Objective:** Rigorous empirical validation with real backtest results

---

## Round Structure

### ROUND 1: Baseline Reality Check
- Run current system with full telemetry
- Capture factor activation rates over FULL dataset
- Compare stride 1 vs stride 20 impact
- Document actual metrics (not estimated)

### ROUND 2: Factor Isolation Tests
- Test each confluence factor individually (ON/OFF)
- Measure contribution of each to performance
- Identify dead factors with real data

### ROUND 3: Timeframe Analysis
- Test M5, M15, H1, H4 entry timeframes
- Compare performance across timeframes
- Identify optimal combination

### ROUND 4: Parameter Sensitivity
- Test key parameter variations (ATR, Hurst, EMA, etc.)
- Monte Carlo on parameter ranges
- Identify robust vs fragile parameters

### ROUND 5: Final Validation Battery
- Full WFA (12+ windows)
- Monte Carlo survival (1000+ paths)
- PSR/DSR/PBO calculation
- Apex compliance under stress

---

## Key Files to Use

| Component | Path |
|-----------|------|
| Backtest Runner | `nautilus_gold_scalper/scripts/backtest/run_backtest.py` |
| Confluence Scorer | `nautilus_gold_scalper/src/signals/confluence_scorer.py` |
| Trend Follow | `nautilus_gold_scalper/src/signals/trend_follow.py` |
| Optimizer | `nautilus_gold_scalper/src/optimization/optimizer.py` |
| SMC Config | `nautilus_gold_scalper/configs/grids/smc_optimization.yaml` |
| Data (stride 20) | `data/raw/full_parquet/xauusd_2003_2025_stride20_full.parquet` |

---

## Test Periods

| Period | Start | End | Purpose |
|--------|-------|-----|---------|
| Full Historical | 2003-05-05 | 2025-11-28 | Statistical validity |
| Training | 2010-01-01 | 2022-12-31 | IS optimization |
| Testing | 2023-01-01 | 2024-12-31 | OOS validation |
| Recent | 2024-01-01 | 2024-12-31 | Current market conditions |

---

## Success Criteria

| Metric | Minimum | Target |
|--------|---------|--------|
| Trade Count | 200 | 500+ |
| WFE | 0.6 | 0.7+ |
| SQN | 2.0 | 2.5+ |
| PSR | 0.85 | 0.90+ |
| MC95DD | <4% | <3% |
| 1-Year Survival | 95% | 97%+ |

---

*Audit execution begins now...*
