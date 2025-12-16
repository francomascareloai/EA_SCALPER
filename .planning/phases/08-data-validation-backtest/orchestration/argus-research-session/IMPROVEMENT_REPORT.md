# ARGUS Research: Pipeline Improvement Report

**Date**: 2025-12-16
**Objective**: Identify better approaches for all phases of the Data Validation & Backtest Pipeline
**Status**: ✅ COMPLETE

---

## Executive Summary

ARGUS research identified **15+ significant improvements** across all phases. The most impactful changes involve:

1. **DuckDB/Polars** for 3-25x faster Parquet validation with memory safety
2. **CPCV** replacing PBO for superior overfitting detection
3. **GJR-GARCH** for asymmetric volatility (gold's leverage effect)
4. **zoneinfo** (stdlib) replacing pytz for correct DST handling
5. **Minimum 200 trades** requirement for statistical significance

---

## Phase-by-Phase Improvements

### Phase 1-A & 2: Data Validation

| Current | Improvement | Impact |
|---------|-------------|--------|
| PyArrow `pq.read_metadata()` | **DuckDB 1.0+** with SQL queries | 3-25x faster, spill-to-disk |
| Load chunks manually | **Polars `scan_parquet().collect(streaming=True)`** | Memory-safe for 654M ticks |
| Basic schema check | **Pandera** for DataFrame validation | Type hints, lazy validation |
| Manual holiday calendar | **pandas_market_calendars** | Automated gap classification |
| Standard Hurst | **Whittle estimator** (`whittlehurst` package) | Faster, more accurate |
| No synthetic detection | **ReMeDI microstructure noise test** | Detect fake data |

**New Libraries**:
- `duckdb>=1.0` - SQL on Parquet with memory management
- `polars>=0.20` - Streaming LazyFrame
- `pandera` - Schema validation
- `whittlehurst` - Fast Hurst calculation
- `benford_py` - Benford's Law tests
- `PyOD` - Anomaly detection

---

### Phase 3 & 4: Session Validation & Integrity

| Current | Improvement | Impact |
|---------|-------------|--------|
| pytz for timezones | **zoneinfo (stdlib)** + `tzdata` | Correct pre-2007 DST |
| Manual DST tables | zoneinfo with IANA tzdb | Automatic rule application |
| Basic .trash/ cleanup | Add JSON metadata file | Better audit trail |
| No lineage tracking | **OpenLineage** (optional) | Full transformation history |

**Key Insight**: zoneinfo correctly handles Energy Policy Act 2005 (DST rule change in 2007). Pre-2007 data (2003-2006) automatically uses old transition dates.

**New Libraries**:
- `zoneinfo` (stdlib Python 3.9+) - Replace pytz
- `tzdata` - IANA timezone database
- `openlineage-python` - Data lineage (optional)

---

### Phase 5: Advanced Validation

| Current | Improvement | Impact |
|---------|-------------|--------|
| Basic GARCH | **GJR-GARCH / EGARCH** | Captures leverage effect |
| ACF only | **Stylized Facts Battery** | Comprehensive authenticity |
| No jump detection | **Lee-Mykland test** | Detect price discontinuities |
| Manual look-ahead audit | **AST-based scanner** | Automated bias detection |
| No microstructure tests | **ReMeDI, Bid-Ask Bounce** | Validate tick authenticity |

**Stylized Facts Battery** (new validation suite):
1. Volatility clustering (GARCH LR test)
2. Fat tails (Student-t df 3-6)
3. Leverage effect (negative correlation)
4. Slow ACF decay of squared returns
5. Jump detection (Lee-Mykland)

**New Libraries**:
- `arch` - GJR-GARCH, EGARCH, HAR-RV
- `highfrequency` (R) - Jump tests, realized measures
- Lee-Mykland Python implementation (GitHub Gist)

---

### Phase 6, 7, 8: Backtest & GO/NO-GO

| Current | Improvement | Impact |
|---------|-------------|--------|
| PBO for overfitting | **CPCV (Combinatorial Purged CV)** | Superior detection |
| IID bootstrap? | **Block bootstrap** with block_size=sqrt(N) | Preserves autocorrelation |
| PSR >= 0.90 | **PSR >= 0.85** (adjusted for fat tails) | More realistic threshold |
| Min 100 trades | **Min 200 trades** | Statistical significance |
| No upper SQN check | **SQN < 5.0** suspicion flag | Detect curve-fitting |
| No MinTRL | **MinTRL formula** | Verify track record length |
| No regime detection | **HMM regime classification** | Per-regime validation |

**New Thresholds**:

| Metric | Old | New | Reason |
|--------|-----|-----|--------|
| Min Trades | 100 | **200** | Institutional standard |
| PSR | ≥ 0.90 | **≥ 0.85** | Fat tails adjustment |
| PBO | < 25% | Use **CPCV** instead | Superior method |
| SQN Upper | None | **< 5.0** | Suspicion flag |

**New Libraries**:
- `mlfinlab` - CPCV, DSR, PSR, purging, embargo
- `timeseriescv` - CombPurgedKFoldCV
- `hmmlearn` - Hidden Markov Models for regimes
- `arch` - Block bootstrap, circular bootstrap

---

## Priority Implementation Matrix

### HIGH Priority (Implement Before Execution)

| # | Improvement | Phase | Effort | Impact |
|---|-------------|-------|--------|--------|
| 1 | DuckDB for Parquet validation | 1-A, 2 | Medium | 3-25x faster |
| 2 | Polars streaming mode | All | Low | Memory safety |
| 3 | zoneinfo replace pytz | 3 | Low | Correct DST |
| 4 | Min 200 trades threshold | 8 | Low | Statistical rigor |
| 5 | GJR-GARCH for volatility | 5 | Medium | Leverage effect |

### MEDIUM Priority (Implement After MVP)

| # | Improvement | Phase | Effort | Impact |
|---|-------------|-------|--------|--------|
| 6 | CPCV replace PBO | 7, 8 | High | Superior overfitting |
| 7 | Stylized Facts Battery | 5 | Medium | Synthetic detection |
| 8 | Lee-Mykland jump test | 5 | Medium | Price validation |
| 9 | Pandera schema validation | 2, 3 | Medium | Type safety |
| 10 | HMM regime detection | 7 | High | Per-regime metrics |

### LOW Priority (Nice to Have)

| # | Improvement | Phase | Effort | Impact |
|---|-------------|-------|--------|--------|
| 11 | OpenLineage tracking | 4 | High | Audit trail |
| 12 | AST look-ahead scanner | 5 | High | Automated detection |
| 13 | MinTRL formula | 8 | Low | Track record verify |
| 14 | Whittle Hurst estimator | 2 | Low | Speed improvement |

---

## Requirements.txt Additions

```txt
# Data Processing (HIGH PRIORITY)
duckdb>=1.0.0
polars>=0.20.0
pandera>=0.18.0

# Statistical Analysis
arch>=6.0.0
hmmlearn>=0.3.0

# Backtesting Validation
mlfinlab>=2.0.0
timeseriescv>=0.1.0

# Utilities
benford-py>=0.5.0
pyod>=1.1.0
```

---

## Threshold Updates for Phase 8

```yaml
# Updated GO/NO-GO Criteria
backtest_criteria:
  wfe: ">= 0.60"           # unchanged
  sqn: ">= 2.0 AND < 5.0"  # UPDATED: upper bound added
  psr: ">= 0.85"           # UPDATED: was 0.90
  dsr: "> 0"               # unchanged
  mc_dd_95: "< 4%"         # unchanged
  min_trades: ">= 200"     # UPDATED: was 100
  ror_10pct: "< 5%"        # unchanged

# New Metrics to Add
new_metrics:
  cpcv_score: ">= 0.6"     # Combinatorial Purged CV
  regime_consistency: "all regimes profitable"
  mintrl_check: "PASS"
```

---

## Next Steps

1. **Immediate**: Update `requirements.txt` with new libraries
2. **Before Execution**: Implement DuckDB/Polars validation utilities
3. **Phase 5**: Add GJR-GARCH and Stylized Facts Battery
4. **Phase 8**: Update thresholds (200 trades, PSR 0.85, SQN upper bound)
5. **Post-MVP**: Implement CPCV and HMM regime detection

---

## Source Files

- `ARGUS_PHASE_1A_2.md` - Data validation research
- `ARGUS_PHASE_3_4.md` - Session/integrity research
- `ARGUS_PHASE_5.md` - Advanced validation research
- `ARGUS_PHASE_6_7_8.md` - Backtest/GO-NOGO research

---

*Generated by ARGUS Quant Researcher - 2025-12-16*
