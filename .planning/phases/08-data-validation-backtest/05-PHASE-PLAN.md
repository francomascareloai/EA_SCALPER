# Phase 5: Advanced Validation

**Phase ID**: 05
**Status**: ⏳ Pending
**Estimated Agents**: 4 (Full Parallel)
**Execution Mode**: Parallel
**Model**: opus (all agents)

---

## Objective

Deep statistical validation including volatility analysis, look-ahead bias detection, data lineage documentation, and performance benchmarking.

---

## Prerequisites

- Phase 2 completed (main catalog validated)
- Phase 3 completed (session catalogs validated)

---

## Orchestration

### Agent Spawn Pattern

All 4 agents spawn simultaneously:

```
Task[5.1 Volatility] || Task[5.2 Look-Ahead] || Task[5.3 Lineage] || Task[5.4 Benchmark]
```

---

## Tasks

### Task 5.1: Volatility Clustering Analysis

**Agent**: ARGUS
**Spec**: `.claude/agents/argus-quant-researcher.md`
**Model**: opus

**Prompt**:
```
You are ARGUS conducting volatility analysis on XAUUSD data.

TASK: Verify data authenticity through volatility clustering patterns.

DATA SOURCE: data/catalog_native/xauusd_2003_2025_stride1_COMPLETE
REFERENCE: GARCH-like autocorrelation check from validate_data.py

ANALYSIS:

1. VOLATILITY AUTOCORRELATION
   - Calculate returns from tick data
   - Compute volatility (rolling window)
   - Test autocorrelation of volatility (should be significant)
   - Real markets show volatility clustering (high vol follows high vol)

2. FAT TAILS CHECK
   - Calculate return distribution
   - Compare to normal distribution
   - Real markets have kurtosis > 3 (fat tails)

3. VOLATILITY REGIME DETECTION
   - Identify high/medium/low volatility regimes
   - Mark regime transitions
   - Correlate with known events (2008 crisis, 2020 COVID, etc.)

4. INTRADAY VOLATILITY PATTERNS
   - Calculate volatility by hour of day
   - Should show higher vol during London/NY overlap
   - Lower vol during Asian session

VALIDITY CHECKS:
- Volatility autocorrelation significant (p < 0.01)
- Kurtosis > 3
- Intraday pattern matches expected

OUTPUT:
{
  "volatility_autocorrelation": {
    "lag_1": <float>,
    "lag_5": <float>,
    "lag_20": <float>,
    "significant": true/false
  },
  "distribution": {
    "kurtosis": <float>,
    "skewness": <float>,
    "fat_tails_confirmed": true/false
  },
  "regimes": {
    "high_vol_periods": [...],
    "correlates_with_events": true/false
  },
  "intraday_pattern": {
    "peak_hours_utc": [...],
    "trough_hours_utc": [...],
    "pattern_valid": true/false
  },
  "authenticity_score": <float 0-100>
}

FILE: DOCS/03_RESEARCH/FINDINGS/PHASE5_VOLATILITY_ANALYSIS.json

Apply CRITIC self-review before reporting done.
```

---

### Task 5.2: Look-Ahead Bias Detection

**Agent**: SENTINEL
**Spec**: `.claude/agents/sentinel-apex-guardian.md`
**Model**: opus

**Prompt**:
```
You are SENTINEL detecting look-ahead bias in XAUUSD data pipeline.

TASK: Audit data for any potential look-ahead bias or data leakage.

CRITICAL: Look-ahead bias is a fatal flaw that invalidates all backtests.

AREAS TO CHECK:

1. TIMESTAMP ORDERING
   - Data sorted by ts_event (event time), not ts_init (processing time)
   - No future information leaking into past via wrong sorting
   - Sample 1M ticks and verify ordering

2. DATA TRANSFORMATIONS
   - Review scripts/data/*.py for any operations that use future data
   - Check for pandas operations like .shift(-1) or .fillna(method='bfill')
   - Verify no forward-filling of prices

3. INDICATOR CALCULATIONS
   - If any indicators are pre-computed in data, verify they're causal
   - Moving averages should use only past data
   - No future peeking in any calculations

4. SPREAD CALCULATIONS
   - Spread = ask - bid (at same timestamp)
   - No use of future bid/ask in spread calculation

5. SESSION FILTERING
   - Verify session filters use only current tick timestamp
   - No look-ahead in session boundary detection

AUDIT SCRIPTS:
- scripts/data/convert_tick_data.py
- scripts/convert_csv_to_nautilus_catalog.py
- nautilus_gold_scalper/indicators/*.py

OUTPUT:
{
  "timestamp_ordering": {
    "correct": true/false,
    "issues": [...]
  },
  "transformations": {
    "scripts_audited": <int>,
    "look_ahead_detected": [...],
    "safe_scripts": [...]
  },
  "indicators": {
    "causal": true/false,
    "issues": [...]
  },
  "overall_status": "CLEAN/CONTAMINATED",
  "severity": "NONE/LOW/HIGH/CRITICAL"
}

FILE: DOCS/03_RESEARCH/FINDINGS/PHASE5_LOOKAHEAD_AUDIT.json

Apply CRITIC self-review before reporting done.
```

---

### Task 5.3: Data Lineage Documentation

**Agent**: FORGE
**Spec**: `.claude/agents/forge-nautilus.md`
**Model**: opus

**Prompt**:
```
You are FORGE documenting data lineage for XAUUSD pipeline.

TASK: Create comprehensive data lineage documentation.

PURPOSE: Track all transformations from source to final catalog for audit trail.

LINEAGE TO DOCUMENT:

1. SOURCE DATA
   - Original file: Python_Agent_Hub/ml_pipeline/data/CSV_2003-2025XAUUSD_ftmo_all-TICK-NoSession.csv
   - Provider: FTMO
   - Size: 30.6 GB
   - Rows: 654,586,033

2. TRANSFORMATION PIPELINE
   Step 1: CSV → Nautilus Catalog
   - Script: scripts/convert_csv_to_nautilus_catalog.py
   - Parameters: stride=1, chunk_size=XX
   - Quality gates applied
   - Output: data/catalog_native/xauusd_2003_2025_stride1_COMPLETE/

   Step 2: Full Catalog → Session Catalogs
   - Script: scripts/slice_catalog_by_session.py
   - Session windows defined (UTC)
   - Output: data/catalog_native_sessions/

3. QUALITY GATES APPLIED
   - Max invalid rows
   - Crossed quote detection
   - Disjoint timestamp detection

4. VALIDATION STEPS
   - Schema validation
   - Temporal consistency
   - Price validation

CREATE DOCUMENT:
- DOCS/06_REFERENCE/DATA_LINEAGE.md
- Include diagrams (ASCII)
- Include script locations
- Include transformation parameters
- Include validation checkpoints

OUTPUT:
{
  "lineage_documented": true,
  "source_hash": "<sha256 of source if available>",
  "transformation_steps": <int>,
  "validation_checkpoints": <int>,
  "document_path": "DOCS/06_REFERENCE/DATA_LINEAGE.md"
}

FILE: DOCS/03_RESEARCH/FINDINGS/PHASE5_LINEAGE_STATUS.json

Apply CRITIC self-review before reporting done.
```

---

### Task 5.4: Performance Benchmarks

**Agent**: PERF_OPT
**Spec**: `.claude/agents/performance-optimizer.md`
**Model**: opus

**Prompt**:
```
You are PERF_OPT benchmarking data loading performance.

TASK: Establish performance baselines for data operations.

BENCHMARKS TO RUN:

1. FULL CATALOG LOAD
   - Time to open ParquetDataCatalog
   - Time to query full date range
   - Peak memory usage

2. TIME-RANGE QUERY
   - Query 1 month of data
   - Query 1 week of data
   - Query 1 day of data
   - Measure time and memory for each

3. SESSION QUERY
   - Query each session for 1 month
   - Compare times across sessions

4. STREAMING PERFORMANCE
   - Iterate over 1M ticks
   - Measure throughput (ticks/second)

5. BACKTEST SIMULATION
   - Simulate backtest engine loading pattern
   - Sequential tick iteration with strategy calls

PERFORMANCE TARGETS (from CLAUDE.md):
- OnTick < 50ms
- ONNX < 5ms
- Python Hub < 400ms

BENCHMARK CODE LOCATION:
- Use or create scripts/benchmark_data_loading.py

OUTPUT:
{
  "full_catalog_load": {
    "time_seconds": <float>,
    "memory_mb": <float>
  },
  "time_range_queries": {
    "1_month": {"time_ms": <float>, "memory_mb": <float>},
    "1_week": {"time_ms": <float>, "memory_mb": <float>},
    "1_day": {"time_ms": <float>, "memory_mb": <float>}
  },
  "session_queries": {
    "ASIAN": {"time_ms": <float>},
    "LONDON": {"time_ms": <float>},
    ...
  },
  "streaming": {
    "ticks_per_second": <float>,
    "memory_stable": true/false
  },
  "backtest_simulation": {
    "ticks_processed": <int>,
    "total_time_seconds": <float>,
    "avg_tick_time_us": <float>
  },
  "meets_performance_targets": true/false
}

FILE: DOCS/03_RESEARCH/FINDINGS/PHASE5_PERFORMANCE_BENCHMARK.json

Apply CRITIC self-review before reporting done.
```

---

## Success Criteria

| Criterion | Threshold | Priority |
|-----------|-----------|----------|
| Volatility clustering | Significant autocorrelation | HIGH |
| Fat tails | Kurtosis > 3 | MEDIUM |
| Look-ahead bias | NONE detected | CRITICAL |
| Lineage documented | Complete | HIGH |
| Performance targets | Met | HIGH |

---

## Deliverables

1. **PHASE5_VOLATILITY_ANALYSIS.json** - Authenticity verification
2. **PHASE5_LOOKAHEAD_AUDIT.json** - Bias detection results
3. **PHASE5_LINEAGE_STATUS.json** - Lineage doc status
4. **DOCS/06_REFERENCE/DATA_LINEAGE.md** - Full lineage document
5. **PHASE5_PERFORMANCE_BENCHMARK.json** - Performance baselines
6. **ADVANCED_VALIDATION_REPORT.md** - Consolidated summary

---

## Next Phase

After completion, proceed to [Phase 6: Backtest Framework](./06-PHASE-PLAN.md)
