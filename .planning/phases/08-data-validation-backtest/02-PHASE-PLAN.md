# Phase 2: Main Catalog Validation

**Phase ID**: 02
**Status**: ⏳ Pending
**Estimated Agents**: 8 (Full Parallel)
**Execution Mode**: Parallel
**Model**: opus (all agents)

---

## Objective

Comprehensive validation of the main 654.6M tick catalog (stride-1 COMPLETE) using 8 parallel validation agents.

---

## Prerequisites

- Phase 1 completed
- `config.yaml` updated to point to `stride1_COMPLETE`

---

## Orchestration

### Agent Spawn Pattern

All 8 agents spawn simultaneously in a single message with multiple Task tool calls:

```
Task[2.1] || Task[2.2] || Task[2.3] || Task[2.4] || Task[2.5] || Task[2.6] || Task[2.7] || Task[2.8]
```

### Common Context for All Agents

```yaml
catalog_path: data/catalog_native/xauusd_2003_2025_stride1_COMPLETE
instrument_id: XAU/USD.SIM
expected_ticks: 654,586,033
date_range: 2003-05-05 to 2025-11-28
```

---

## Tasks

### Task 2.1: Quick Health Check

**Agent**: ORACLE
**Spec**: `.claude/agents/oracle-backtest-commander.md`
**Model**: opus

**Prompt**:
```
You are ORACLE validating the XAUUSD main catalog.

TASK: Quick health check of the Nautilus catalog.

CATALOG: data/catalog_native/xauusd_2003_2025_stride1_COMPLETE
EXPECTED: 654,586,033 ticks

CHECKS:
1. Catalog can be opened (ParquetDataCatalog)
2. Basic query works (sample first 1000 ticks)
3. Basic query works (sample last 1000 ticks)
4. Tick count matches expected
5. Date range matches expected (2003-05-05 to 2025-11-28)

OUTPUT: JSON with status (PASS/FAIL) for each check
FILE: DOCS/03_RESEARCH/FINDINGS/PHASE2_HEALTH_CHECK.json

Apply CRITIC self-review before reporting done.
```

---

### Task 2.2: Schema Validation

**Agent**: ORACLE
**Spec**: `.claude/agents/oracle-backtest-commander.md`
**Model**: opus

**Prompt**:
```
You are ORACLE validating the XAUUSD main catalog.

TASK: Validate Parquet schema consistency across all files.

CATALOG: data/catalog_native/xauusd_2003_2025_stride1_COMPLETE/data/quote_tick/XAU%2FUSD.SIM/

CHECKS:
1. All parquet files have same schema
2. Required columns exist: instrument_id, ts_event, ts_init, bid_price, ask_price, bid_size, ask_size
3. Column types are correct (int64 for prices, uint64 for timestamps)
4. No unexpected columns

OUTPUT: JSON with schema details and any inconsistencies
FILE: DOCS/03_RESEARCH/FINDINGS/PHASE2_SCHEMA_VALIDATION.json

Apply CRITIC self-review before reporting done.
```

---

### Task 2.3: Temporal Consistency

**Agent**: ORACLE
**Spec**: `.claude/agents/oracle-backtest-commander.md`
**Model**: opus

**Prompt**:
```
You are ORACLE validating the XAUUSD main catalog.

TASK: Validate temporal consistency of timestamps.

CATALOG: data/catalog_native/xauusd_2003_2025_stride1_COMPLETE

CHECKS:
1. Timestamps are monotonically non-decreasing
2. No duplicate timestamps (or document if expected)
3. No future timestamps (beyond 2025-11-28)
4. No timestamps before 2003-05-05
5. Timestamp gaps are reasonable (no >1 week gaps except weekends)
6. Sample 1M ticks from start, middle, end for efficiency

OUTPUT: JSON with temporal analysis
FILE: DOCS/03_RESEARCH/FINDINGS/PHASE2_TEMPORAL_CONSISTENCY.json

Apply CRITIC self-review before reporting done.
```

---

### Task 2.4: Price Validation

**Agent**: ORACLE
**Spec**: `.claude/agents/oracle-backtest-commander.md`
**Model**: opus

**Prompt**:
```
You are ORACLE validating the XAUUSD main catalog.

TASK: Validate price data quality.

CATALOG: data/catalog_native/xauusd_2003_2025_stride1_COMPLETE

CHECKS:
1. All bid <= ask (no crossed quotes)
2. Spread = ask - bid, check spread distribution
3. Price range reasonable ($300-$3500 for XAUUSD 2003-2025)
4. No NaN or Inf values
5. No zero or negative prices
6. Spread 95th percentile < 100 cents
7. Average spread < 30 cents

SAMPLING: Head+tail strategy (2M ticks from start/end)

OUTPUT: JSON with price statistics and any violations
FILE: DOCS/03_RESEARCH/FINDINGS/PHASE2_PRICE_VALIDATION.json

Apply CRITIC self-review before reporting done.
```

---

### Task 2.5: Gap Analysis

**Agent**: ORACLE
**Spec**: `.claude/agents/oracle-backtest-commander.md`
**Model**: opus

**Prompt**:
```
You are ORACLE validating the XAUUSD main catalog.

TASK: Comprehensive gap analysis.

CATALOG: data/catalog_native/xauusd_2003_2025_stride1_COMPLETE

METHODOLOGY:
1. Calculate time delta between consecutive ticks
2. Filter out expected weekend gaps (Fri 22:00 UTC to Sun 22:00 UTC)
3. Filter out expected holiday gaps (known market closures)

GAP CATEGORIES:
- Minor: 1-4 hours
- Moderate: 4-24 hours
- Critical: >24 hours (FAIL if not weekend/holiday)

OUTPUT:
- Total gaps by category
- List of all critical gaps with dates
- Histogram of gap distribution
FILE: DOCS/03_RESEARCH/FINDINGS/PHASE2_GAP_ANALYSIS.json

Apply CRITIC self-review before reporting done.
```

---

### Task 2.6: Regime Analysis

**Agent**: ARGUS
**Spec**: `.claude/agents/argus-quant-researcher.md`
**Model**: opus

**Prompt**:
```
You are ARGUS conducting regime analysis on XAUUSD data.

TASK: Analyze market regimes using Hurst exponent and other methods.

DATA SOURCE: Use scripts/oracle/validate_data_v2.py or implement similar

ANALYSIS:
1. Calculate Hurst exponent using R/S method
2. Classify regimes: trending (H>0.55), random (0.45<H<0.55), mean-reverting (H<0.45)
3. Segment data by year and calculate per-year regime
4. Identify regime transitions

REQUIREMENTS:
- All 3 regime types should have >10% representation
- No single regime should dominate >70%

OUTPUT: JSON with regime analysis
FILE: DOCS/03_RESEARCH/FINDINGS/PHASE2_REGIME_ANALYSIS.json

Apply CRITIC self-review before reporting done.
```

---

### Task 2.7: Session Coverage

**Agent**: ORACLE
**Spec**: `.claude/agents/oracle-backtest-commander.md`
**Model**: opus

**Prompt**:
```
You are ORACLE validating session coverage in XAUUSD data.

TASK: Analyze tick distribution across trading sessions.

SESSION WINDOWS (UTC):
- ASIAN: 00:00-07:00
- LONDON: 07:00-12:00
- OVERLAP: 12:00-15:00
- NY: 15:00-17:00
- LATE_NY: 17:00-21:00
- EVENING: 21:00-00:00

APEX TIME GATES (ET):
- Block new trades after 4:30 PM ET
- Force close from 4:55 PM ET
- No overnight positions past 4:59 PM ET

ANALYSIS:
1. Count ticks per session
2. Calculate percentage distribution
3. Verify all sessions have >5% coverage
4. Map Apex time gates to UTC for validation

OUTPUT: JSON with session distribution
FILE: DOCS/03_RESEARCH/FINDINGS/PHASE2_SESSION_COVERAGE.json

Apply CRITIC self-review before reporting done.
```

---

### Task 2.8: Quality Scoring

**Agent**: ORACLE
**Spec**: `.claude/agents/oracle-backtest-commander.md`
**Model**: opus

**Prompt**:
```
You are ORACLE computing final quality score for XAUUSD data.

TASK: Calculate comprehensive quality score (0-100).

SCORING COMPONENTS (from validate_data_v2.py):
- Coverage (25pts): ≥36 months = 25pts
- Clean Data (25pts): ≥99% = 25pts
- Gaps (15pts): 0 critical gaps = 15pts
- Regime Diversity (15pts): All 3 regimes >10% = 15pts
- Session Coverage (10pts): All sessions >5% = 10pts
- Spread Quality (10pts): Avg <30 cents = 10pts

APPROVAL CRITERIA:
- ≥36 months coverage
- ≥95% clean data
- 0 critical gaps (>24h non-weekend)
- Quality score ≥70

Use existing script: python scripts/oracle/validate_data_v2.py <catalog_path>

OUTPUT: JSON with breakdown and final score
FILE: DOCS/03_RESEARCH/FINDINGS/PHASE2_QUALITY_SCORE.json

Apply CRITIC self-review before reporting done.
```

---

## Consolidation

After all 8 agents complete, orchestrator consolidates:

```python
# Combine all Phase 2 outputs
phase2_results = {
    "health_check": load_json("PHASE2_HEALTH_CHECK.json"),
    "schema": load_json("PHASE2_SCHEMA_VALIDATION.json"),
    "temporal": load_json("PHASE2_TEMPORAL_CONSISTENCY.json"),
    "price": load_json("PHASE2_PRICE_VALIDATION.json"),
    "gaps": load_json("PHASE2_GAP_ANALYSIS.json"),
    "regime": load_json("PHASE2_REGIME_ANALYSIS.json"),
    "sessions": load_json("PHASE2_SESSION_COVERAGE.json"),
    "quality": load_json("PHASE2_QUALITY_SCORE.json"),
}

# Generate summary
overall_status = "PASS" if all checks pass else "FAIL"
```

---

## Success Criteria

| Criterion | Threshold | Priority |
|-----------|-----------|----------|
| Health check | All PASS | CRITICAL |
| Schema consistent | 100% | CRITICAL |
| Temporal consistency | No future timestamps, monotonic | CRITICAL |
| Crossed quotes | 0% | CRITICAL |
| Critical gaps | 0 (non-weekend) | CRITICAL |
| Quality score | ≥70/100 | HIGH |
| Regime diversity | All 3 >10% | MEDIUM |
| Session coverage | All 6 >5% | MEDIUM |

---

## Deliverables

1. **8 JSON reports** in `DOCS/03_RESEARCH/FINDINGS/`
2. **MAIN_CATALOG_VALIDATION_REPORT.md** - Consolidated summary

---

## Next Phase

After completion, proceed to [Phase 3: Session Catalog Validation](./03-PHASE-PLAN.md)
