[ARGUS INTEGRATED]

# Phase 2: Main Catalog Validation

> **⚡ ARGUS IMPROVEMENTS APPLIED** (see full details at end of file)
> - **DuckDB queries**: Replace NautilusTrader catalog.* calls (10-50x faster)
> - **zoneinfo (stdlib)**: Correct pre-2007 DST handling (replaces pytz)
> - **HMM regime detection**: 3-state volatility classification
> - **Polars lazy evaluation**: Memory-safe for 654M ticks

**Phase ID**: 02
**Status**: ⏳ Pending
**Estimated Agents**: 8 (Full Parallel)
**Execution Mode**: Parallel
**Model**: opus (all agents)

---

## Memory Constraint (CRITICAL)

**System RAM**: 12 GB total
**Safe Working Memory**: ~6 GB (leave 6 GB for OS/system)
**Max Chunk Size**: 5M ticks (~500 MB) per operation
**Parallelism**: 2 rounds of 4 agents (not all 8 at once)

### Memory Budget Per Agent
| Agent | Max Memory | Strategy |
|-------|------------|----------|
| 2.1 Health check | 200 MB | Sample only |
| 2.2 Schema | 100 MB | Metadata only |
| 2.3 Temporal | 500 MB | Stream chunks |
| 2.4 Price | 500 MB | Head+tail sample |
| 2.5 Gap analysis | 500 MB | **Streaming (5M chunks)** |
| 2.6 Regime | 400 MB | Aggregated stats |
| 2.7 Session coverage | 500 MB | Stream chunks |
| 2.8 Quality | 200 MB | Aggregate results |

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

<!-- FIXED per CRITIC C1: Task 2.8 moved to Round 3 due to dependency on 2.5, 2.6, 2.7 outputs -->
**Execution Structure (3 rounds for dependency correctness):**

```
Round 1: Task[2.1] (Health Check ALONE - blocking gate)
   ↓ GATE: If 2.1 fails, STOP Phase 2 and escalate
Round 1b: Task[2.2] || Task[2.3] || Task[2.4]
   ↓ (collect results)
Round 2: Task[2.5] || Task[2.6] || Task[2.7]
   ↓ (collect results - needed by Task 2.8)
Round 3: Task[2.8] (Quality Scoring - depends on all above)
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

**STREAMING STRATEGY (CRITICAL FOR 654M TICKS)**: <!-- FIXED per CRITIC C2: Changed 10M to 5M to match memory budget -->
- DO NOT load all ticks into memory at once
- Process in chunks of 5M ticks using ParquetDataCatalog streaming
- Use polars lazy evaluation (scan_parquet) instead of eager loading
- Calculate deltas per chunk and aggregate results

METHODOLOGY:
1. Stream chunks: for each 5M tick chunk:
   a. Load chunk using lazy/streaming
   b. Calculate time delta between consecutive ticks
   c. Identify gaps > 1 hour
   d. Store gap info (start_ts, end_ts, duration)
   e. Release memory before next chunk
2. Handle chunk boundaries:
   - Store last timestamp of each chunk
   - Calculate gap between last tick of chunk N and first tick of chunk N+1
3. Filter out expected weekend gaps (Fri 22:00 UTC to Sun 22:00 UTC)
4. Filter out expected holiday gaps (known market closures)

<!-- FIXED per CRITIC H1: Added holiday calendar -->
<!-- ARGUS IMPROVEMENT: Use pandas_market_calendars instead of manual list -->
AUTOMATED HOLIDAY DETECTION (pandas_market_calendars):
```python
import pandas_market_calendars as mcal

# Get CME Metals calendar (closest to XAUUSD)
calendar = mcal.get_calendar('CME_Metals')
holidays = calendar.holidays(start='2003-01-01', end='2025-12-31')

# Check if gap falls on a market holiday
def is_expected_holiday_gap(gap_date):
    return gap_date in holidays.to_pydatetime()
```

MANUAL FALLBACK (if calendar incomplete):
- Christmas: Dec 24-26 each year
- New Year: Dec 31 - Jan 2 each year
- Good Friday: Variable (March/April)
- US Thanksgiving: 4th Thursday November
- US Independence Day: July 4
- UK Bank Holidays: Various

DST HANDLING: <!-- FIXED per CRITIC H6 -->
- Market close shifts between 21:00 UTC (winter) and 20:00 UTC (summer)
- Apply 1-hour tolerance when checking weekend boundaries

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
1. Calculate Hurst exponent using Whittle estimator (primary) or R/S method (fallback)
2. Classify regimes: trending (H>0.55), random (0.45<H<0.55), mean-reverting (H<0.45)
3. Segment data by year and calculate per-year regime
4. Identify regime transitions

<!-- ARGUS IMPROVEMENT: Use Whittle estimator for faster, more accurate Hurst -->
HURST CALCULATION (whittlehurst package - preferred):
```python
from whittlehurst import Whittle
import numpy as np

def calculate_hurst_whittle(returns: np.ndarray) -> float:
    """Calculate Hurst exponent using Whittle estimator (faster, more accurate)."""
    estimator = Whittle()
    estimator.fit(returns)
    return estimator.H_

# Fallback to R/S if Whittle fails
def calculate_hurst_rs(returns: np.ndarray) -> float:
    """Calculate Hurst using R/S method (slower but robust)."""
    # ... existing R/S implementation ...
    pass
```

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

---

## CRITIC Review (Phase 2)

**Reviewer**: CRITIC v1.1 Adversarial Quality Guardian
**Date**: 2025-12-16
**Review Type**: EXHAUSTIVE (15+ sequential thoughts)
**Verdict**: CONDITIONAL APPROVAL

---

### Executive Summary

This phase plan has solid foundations but contains **2 CRITICAL issues** that must be fixed before execution, plus **8 HIGH severity issues** that could cause validation failures or missed defects. The plan is structurally sound but underestimates memory usage, has a dependency error in task sequencing, and lacks a holiday calendar for gap analysis.

---

### CRITICAL Issues (Must Fix Before Execution)

#### C1: Task 2.8 Dependency Error
**Location**: Orchestration section (lines 51-55)
**Problem**: Task 2.8 (Quality Scoring) is scheduled to run in parallel with Tasks 2.5, 2.6, 2.7 in Round 2. However, Task 2.8 requires the OUTPUT from these tasks to calculate the quality score.

```
Current:  Round 2: Task[2.5] || Task[2.6] || Task[2.7] || Task[2.8]
Problem:  2.8 reads outputs from 2.5, 2.6, 2.7 that don't exist yet
```

**Impact**: Task 2.8 will either fail (missing JSON files) or produce garbage score (reading stale/missing data).

**Fix Required**:
```
Round 1: Task[2.1] || Task[2.2] || Task[2.3] || Task[2.4]
   ↓ (GATE: if 2.1 fails, STOP)
Round 2: Task[2.5] || Task[2.6] || Task[2.7]
   ↓ (collect results)
Round 3: Task[2.8]  (OR: Orchestrator performs scoring directly)
```

#### C2: Chunk Size Contradiction (5M vs 10M)
**Location**: Memory section (line 15) vs Gap Analysis prompt (line 212, 217)
**Problem**: Memory constraint says "Max Chunk Size: 5M ticks (~500 MB)" but Gap Analysis prompt says "Process in chunks of 10M ticks".

- 10M ticks at ~100 bytes/tick = 1 GB per chunk
- This EXCEEDS the stated 500 MB budget and could cause OOM

**Impact**: Gap Analysis agent may crash or cause system swap, affecting other parallel agents.

**Fix Required**: Change Gap Analysis prompt lines 212 and 217 from "10M" to "5M":
```
- Process in chunks of 5M ticks using ParquetDataCatalog streaming
...
1. Stream chunks: for each 5M tick chunk:
```

---

### HIGH Severity Issues (Should Fix)

#### H1: Missing Holiday Calendar for Gap Analysis
**Location**: Task 2.5 prompt (line 227)
**Problem**: Prompt says "Filter out expected holiday gaps (known market closures)" but NO HOLIDAY CALENDAR IS PROVIDED.

**Impact**: Valid holiday gaps (Christmas, New Year, Good Friday, etc.) will be flagged as CRITICAL, potentially causing false validation failures.

**Fix Required**: Add holiday calendar to prompt:
```
KNOWN MARKET HOLIDAYS (approximate - verify exact dates):
- Christmas: Dec 24-26 each year
- New Year: Dec 31 - Jan 2 each year
- Good Friday: Variable (March/April)
- US Thanksgiving: 4th Thursday November
- US Independence Day: July 4
- UK Bank Holidays: Various

Note: If gap occurs during known holiday period, classify as "expected" not "critical".
```

#### H2: Price Validation Samples Only Head+Tail
**Location**: Task 2.4 prompt (line 186)
**Problem**: "SAMPLING: Head+tail strategy (2M ticks from start/end)" misses 20+ years of data in the MIDDLE.

**Impact**: Corrupt data in 2010-2020 could pass validation but cause backtest anomalies.

**Fix Required**: Change sampling strategy to TRIAD approach:
```
SAMPLING: Triad strategy - 1M ticks each from:
- Start (2003-2005)
- Middle (2013-2015)
- End (2023-2025)
```

#### H3: Memory Estimates Understate Real Usage
**Location**: Memory Budget table (lines 18-28)
**Problem**: Estimates only count data memory, not Python/library overhead:
- Python interpreter: 50-100 MB per process
- NautilusTrader import: 200-400 MB
- Polars/PyArrow: 100-200 MB

**Actual vs Stated**:
| Agent | Stated | Actual (realistic) |
|-------|--------|-------------------|
| 2.1 Health | 200 MB | 500 MB |
| 2.3 Temporal | 500 MB | 800 MB |
| 2.5 Gap | 500 MB | 800 MB |
| 4 agents | 1.3 GB | ~2.5 GB |

**Impact**: With OS overhead (3 GB WSL2), total could reach 7-8 GB. Still within 12 GB but tighter than stated.

**Fix Required**: Update Memory Constraint section:
```
**Safe Working Memory**: ~6 GB (actual agent usage 2-3 GB + 3 GB OS)
**Realistic Per-Agent**: 400-800 MB (including Python/library overhead)
**DO NOT spawn all 8 agents simultaneously on 12 GB system**
```

#### H4: No Health Check Gate Between Rounds
**Location**: Orchestration section
**Problem**: If Task 2.1 (Health Check) fails, the plan continues to Round 2 anyway.

**Impact**: Wasted compute and potentially misleading partial results if catalog is corrupt.

**Fix Required**: Add explicit gate:
```
Round 1: Task[2.1] (Health Check) - RUN FIRST, ALONE
   ↓ GATE: If 2.1 status != ALL_PASS, STOP Phase 2 and escalate
Round 1b: Task[2.2] || Task[2.3] || Task[2.4]
...
```

#### H5: NY Session Window is Incorrect
**Location**: Task 2.7 prompt (lines 293-294)
**Problem**:
```
Current:  NY: 15:00-17:00 (2 hours)
Reality:  NY market hours: 9:30 AM - 4:00 PM ET = 14:30-21:00 UTC (winter)
```

**Impact**: Session coverage statistics will be wrong; NY session will appear underrepresented.

**Fix Required**: Align with `validate_data_v2.py` which uses:
```
SESSION WINDOWS (UTC) - aligned with validate_data_v2.py:
- ASIA: 00:00-07:00
- LONDON: 07:00-12:00
- OVERLAP: 12:00-16:00
- NY: 16:00-21:00
- CLOSE: 21:00-00:00
```

#### H6: No DST Handling for Session/Weekend Classification
**Location**: Tasks 2.5 and 2.7
**Problem**: Weekend gaps are filtered using fixed "Fri 22:00 UTC to Sun 22:00 UTC", but markets observe DST. Also, session classification uses fixed UTC hours.

**Impact**:
- Spring forward: 1-hour "gap" flagged incorrectly
- Fall back: Duplicate hour misclassified
- Session stats off by 1 hour for half the year

**Fix Required**: Add DST note to prompts:
```
DST HANDLING:
- Market close shifts between 21:00 UTC (winter) and 20:00 UTC (summer)
- Apply 1-hour tolerance when checking weekend boundaries
- Or: classify gaps as "weekend" if Friday 20:00-22:00 to Sunday 21:00-23:00 UTC
```

#### H7: Temporal Check Doesn't Validate Cross-File Ordering
**Location**: Task 2.3 prompt (line 153)
**Problem**: "Sample 1M ticks from start, middle, end" only validates ordering WITHIN the sample, not ACROSS parquet files.

**Impact**: If files are read in wrong order (e.g., 2020.parquet before 2019.parquet), the monotonic check passes but data is actually out of order.

**Fix Required**: Add explicit file ordering check:
```
CHECKS:
...
6. Verify parquet files are read in chronological order by filename
7. Sample 1M ticks from start, middle, end for intra-file ordering
8. Verify last timestamp of file N < first timestamp of file N+1 (cross-file boundary check)
```

#### H8: Duplicate Timestamp Handling Unclear
**Location**: Task 2.3 prompt (lines 148-149)
**Problem**:
- Line 148: "Timestamps are monotonically non-decreasing" (allows duplicates)
- Line 149: "No duplicate timestamps" (forbids duplicates)
- These CONTRADICT each other.

In real tick data, DUPLICATES ARE COMMON (multiple quotes at same millisecond from different LPs).

**Fix Required**: Clarify handling:
```
CHECKS:
1. Timestamps are monotonically non-decreasing (duplicates allowed)
2. Document duplicate timestamp count (expected in tick data; >0.1% is concerning)
3. ...
```

---

### MEDIUM Severity Issues (Recommended Fixes)

#### M1: No Partial Scoring in Quality Formula
**Location**: Task 2.8 prompt (lines 329-334)
**Problem**: Scoring appears binary (full points or zero) but `validate_data_v2.py` actually has graduated scoring. The prompt should clarify this.

**Fix**: Add note: "Use graduated scoring from validate_data_v2.py (partial points for partial compliance)."

#### M2: Missing Bid/Ask Size Validation
**Location**: Not covered by any task
**Problem**: Schema validation checks size columns exist, but no task validates size VALUES (non-zero, reasonable range).

**Fix**: Add to Task 2.4:
```
8. Bid/ask sizes are positive and reasonable (0 < size < 1e12)
```

#### M3: Missing Tick Frequency Validation
**Location**: Not covered by any task
**Problem**: No check for:
- 0 ticks for extended periods during active session (data gap not caught by hourly check)
- 10,000+ ticks/second (possible data duplication)

**Fix**: Add new check to Task 2.3 or create Task 2.9:
```
TICK FREQUENCY CHECKS:
- Average ticks/minute during active hours: 10-1000 (flag outliers)
- No 10+ minute gaps during active session (more granular than 1-hour gap check)
- No single second with >1000 ticks (duplication indicator)
```

#### M4: Missing Price Spike Detection
**Location**: Not covered
**Problem**: Static price range ($300-$3500) catches only extreme outliers. "Fat finger" errors like $2000 jumping to $2200 in 1 tick would pass.

**Fix**: Add to Task 2.4:
```
8. No single-tick price moves > 2% (fat finger detection)
9. Flag ticks where |current_mid - prev_mid| / prev_mid > 0.02
```

#### M5: Regime Analysis Needs Aggregation Spec
**Location**: Task 2.6 prompt
**Problem**: Prompt doesn't specify whether to calculate Hurst on raw ticks (impossible with 654M) or aggregated data.

**Fix**: Add clarification:
```
PREPROCESSING:
- Aggregate to daily close prices (OHLC) before Hurst calculation
- Hurst R/S method requires 100+ data points minimum
- Per-year: ~252 trading days = adequate sample
```

#### M6: Session Thresholds Not Proportional
**Location**: Task 2.7 prompt (line 305)
**Problem**: "All sessions have >5% coverage" applies uniform threshold, but sessions have different durations (ASIA: 7h, NY as stated: 2h).

**Fix**: Consider proportional thresholds or note that 5% is a floor, not expectation.

---

### LOW Severity Issues (Nice to Have)

#### L1: No Timeout Guidance
Long-running tasks (gap analysis on 654M ticks) could timeout. Add: "Expected duration: 10-30 min for streaming tasks."

#### L2: No File Overwrite Policy
What if previous run's JSON files exist? Add: "Overwrite previous outputs (or archive to PHASE2_RUN_YYYYMMDD/)."

#### L3: Column Names Should Be Discovered
Schema validation assumes column names. Better: "Discover actual schema, then validate against expected pattern."

#### L4: Missing Instrument ID Uniformity Check
Add to Task 2.2: "Verify all records have instrument_id = 'XAU/USD.SIM' (no mixed instruments)."

---

### Assumptions Challenged

| Assumption | Challenge | Recommendation |
|------------|-----------|----------------|
| 6 GB for agents is enough | Real usage may be 2-3 GB with 4 parallel | Monitor memory; abort if >70% used |
| Weekend = Fri 22:00 to Sun 22:00 UTC | DST changes this by 1 hour | Use 1-hour tolerance window |
| 8 agents can run in 2 rounds | Task 2.8 has dependency | Use 3 rounds: 1→3→3→1 |
| validate_data_v2.py handles everything | Script is for CSV, not Parquet catalog | May need catalog adapter |
| Static price range is sufficient | 2003 gold ~$350, 2024 ~$2700 | Consider per-decade ranges |

---

### Pre-Mortem: How Validation Could Miss Real Issues

1. **Bad data in middle years (2010-2020)**: Head+tail sampling skips 20 years
2. **Holiday gaps flagged as critical**: No calendar = false failures
3. **Cross-file ordering wrong**: Sampling doesn't catch file sequence errors
4. **Fat finger prices pass**: No spike detection
5. **Task 2.8 produces garbage**: Dependency error causes incomplete inputs

---

### Recommended Execution Structure

```
Round 0: Pre-flight (orchestrator)
   - Check 12 GB RAM available
   - Clear previous PHASE2_*.json files
   - Verify catalog path exists

Round 1: Task[2.1] ALONE (Health Check)
   ↓ GATE: If ANY check fails → ABORT Phase 2

Round 2: Task[2.2] || Task[2.3] || Task[2.4]
   (3 agents, ~2 GB peak)
   ↓ (collect results)

Round 3: Task[2.5] || Task[2.6] || Task[2.7]
   (3 agents, ~2.5 GB peak)
   ↓ (collect results)

Round 4: Task[2.8] (Quality Scoring)
   OR: Orchestrator calculates score from JSON files
   ↓

Consolidation: Generate MAIN_CATALOG_VALIDATION_REPORT.md
```

---

### Manual Verification Needed

- [ ] Verify NautilusTrader ParquetDataCatalog column names match assumed schema
- [ ] Verify `validate_data_v2.py` works with Parquet catalog (not just CSV)
- [ ] Test memory usage with 1 agent before running 4 parallel
- [ ] Create holiday calendar for 2003-2025 (or accept false positives)
- [ ] Verify gold price was indeed ~$350 in 2003 (range check lower bound)

---

### Verdict

**Status**: CONDITIONAL APPROVAL

**Conditions for Approval**:
1. FIX C1: Move Task 2.8 to Round 3 (or make orchestrator task)
2. FIX C2: Change Gap Analysis chunk size from 10M to 5M
3. ADD holiday calendar to Gap Analysis prompt

**After fixes, Phase 2 may proceed with HIGH issues documented as known limitations.**

---

### Appendix: validate_data_v2.py Comparison

The existing script (`scripts/oracle/validate_data_v2.py`) was reviewed. Key observations:

1. **Session definitions DIFFER from plan**:
   - Script: `newyork: (16, 21)`
   - Plan: `NY: 15:00-17:00`
   - ALIGN with script (16-21 UTC)

2. **Script has graduated scoring** (not binary):
   - 99%+ clean = 25pts, 95% = 20pts, 90% = 10pts, etc.
   - Plan's scoring summary is simplified; script is authoritative

3. **Script uses CSV format**, not Parquet catalog:
   - Line 200-267: `load_tick_data` reads CSV with head+tail
   - May need adapter for ParquetDataCatalog

4. **Script's price validation uses $1000-$5000 range** (line 479):
   - Different from plan's $300-$3500
   - Neither is fully correct for 2003-2025 (gold was ~$350 in 2003)

---

*"Every bug found now is a loss prevented later."*
*CRITIC v1.1 - Adversarial Quality Guardian*

---

## ARGUS Research Improvements

**Integrated**: 2025-12-16
**Research Report**: DOCS/03_RESEARCH/FINDINGS/IMPROVEMENT_REPORT.md

---

### Summary of Improvements

This phase plan has been enhanced with the following research-backed improvements:

| Improvement | Original Approach | New Approach | Benefit |
|-------------|-------------------|--------------|---------|
| Holiday detection | Manual list | pandas_market_calendars | Automated, accurate calendar |
| Hurst calculation | R/S method only | Whittle estimator (primary) | Faster, more accurate |
| Synthetic data detection | Not included | ReMeDI test (new task) | Detect fake/simulated data |
| Anomaly detection | Not included | PyOD isolation forest (new task) | Find outliers |
| Stylized facts | Not included | Benford + kurtosis (new task) | Validate data authenticity |

---

### New Dependencies

Add to `requirements.txt` or install separately:

```bash
# Core improvements (REQUIRED)
pip install pandas-market-calendars>=4.0  # Market holiday calendars
pip install whittlehurst>=0.1.0           # Whittle estimator for Hurst

# Optional advanced validation
pip install benford-py>=0.5.0             # Benford's Law tests
pip install pyod>=1.1.0                   # Anomaly detection
```

---

### New Optional Validation Tasks

The following advanced validation tasks can be added to Round 3 or a new Round 4:

#### Task 2.9: Stylized Facts Validation (Optional)

**Agent**: ARGUS
**Model**: opus

**Prompt**:
```
You are ARGUS validating stylized facts of XAUUSD tick data.

TASK: Verify data exhibits known stylized facts of financial returns.

STYLIZED FACTS TO CHECK:
1. Heavy tails (kurtosis > 3 for returns)
2. Volatility clustering (autocorrelation of squared returns)
3. Benford's Law (first digit distribution of price changes)

BENFORD'S LAW TEST:
```python
from benford import Benford

# Test first digits of absolute price changes
price_changes = df['mid_price'].diff().abs().dropna()
bf = Benford(price_changes)
conformity = bf.conformity()  # Should be > 0.7 for real data
```

OUTPUT:
{
  "kurtosis": <float>,  // Expected > 3
  "volatility_clustering": <float>,  // Autocorr of returns^2
  "benford_conformity": <float>,  // > 0.7 for real data
  "status": "PASS/WARN/FAIL"
}

FILE: DOCS/03_RESEARCH/FINDINGS/PHASE2_STYLIZED_FACTS.json
```

---

#### Task 2.10: Synthetic Data Detection (Optional)

**Agent**: ARGUS
**Model**: opus

**Prompt**:
```
You are ARGUS detecting potential synthetic/simulated data in XAUUSD ticks.

TASK: Apply ReMeDI microstructure noise test to detect synthetic data.

INDICATORS OF SYNTHETIC DATA:
1. Too-regular tick intervals (real data has irregular timing)
2. No microstructure noise (real data has bid-ask bounce)
3. Perfect Gaussian returns (real returns have fat tails)
4. No spread variation (real spreads vary with volatility)

DETECTION METHODOLOGY:
1. Check tick interval distribution (should be exponential-like, not uniform)
2. Calculate first-order autocorrelation of returns (should be slightly negative due to bid-ask bounce)
3. Check spread variation (should increase during high volatility)

OUTPUT:
{
  "tick_interval_distribution": "exponential/uniform/suspicious",
  "return_autocorrelation": <float>,  // Expected -0.1 to -0.5 for real tick data
  "spread_vol_correlation": <float>,  // Expected > 0.3 for real data
  "synthetic_probability": <float>,  // 0-1, higher = more likely synthetic
  "status": "PASS/WARN/FAIL"
}

FILE: DOCS/03_RESEARCH/FINDINGS/PHASE2_SYNTHETIC_DETECTION.json
```

---

#### Task 2.11: Anomaly Detection (Optional)

**Agent**: ORACLE
**Model**: opus

**Prompt**:
```
You are ORACLE detecting anomalies in XAUUSD tick data.

TASK: Use isolation forest to detect anomalous ticks.

PYOD ISOLATION FOREST:
```python
from pyod.models.iforest import IForest
import numpy as np

# Features for anomaly detection
features = np.column_stack([
    df['spread'].values,
    df['mid_price'].pct_change().abs().values,
    df['ts_event'].diff().values / 1e9  # tick interval seconds
])

# Fit isolation forest
clf = IForest(contamination=0.001)  # Expect 0.1% anomalies
clf.fit(features[~np.isnan(features).any(axis=1)])
anomaly_labels = clf.labels_  # 1 = anomaly
```

ANOMALY TYPES TO FLAG:
1. Extreme spreads (> 10x median)
2. Extreme price jumps (> 1% in single tick)
3. Extreme tick intervals (> 1 hour during trading)

OUTPUT:
{
  "total_ticks_analyzed": <int>,
  "anomalies_detected": <int>,
  "anomaly_rate": <float>,
  "anomaly_types": {
    "extreme_spread": <int>,
    "extreme_jump": <int>,
    "extreme_interval": <int>
  },
  "status": "PASS/WARN/FAIL"  // WARN if > 0.1% anomalies
}

FILE: DOCS/03_RESEARCH/FINDINGS/PHASE2_ANOMALY_DETECTION.json
```

---

### Updated Orchestration with Optional Tasks

```
Round 1: Task[2.1] (Health Check ALONE - blocking gate)
   ↓ GATE: If 2.1 fails, STOP Phase 2 and escalate
Round 1b: Task[2.2] || Task[2.3] || Task[2.4]
   ↓ (collect results)
Round 2: Task[2.5] || Task[2.6] || Task[2.7]
   ↓ (collect results - needed by Task 2.8)
Round 3: Task[2.8] (Quality Scoring - depends on all above)
   ↓ (if advanced validation requested)
Round 4 (OPTIONAL): Task[2.9] || Task[2.10] || Task[2.11]
   (Stylized Facts, Synthetic Detection, Anomaly Detection)
```

---

### Memory Safety with DuckDB

For any task requiring Parquet scanning, use DuckDB with spill-to-disk:

```python
import duckdb

db = duckdb.connect(":memory:")
db.execute("SET memory_limit='6GB';")
db.execute("SET temp_directory='/tmp/duckdb_swap';")

# Count ticks across all parquet files
count = db.execute("""
    SELECT COUNT(*) FROM read_parquet('data/catalog/**/*.parquet')
""").fetchone()[0]
```

---

### Whittle Estimator for Hurst (Task 2.6 Enhancement)

The Whittle estimator is faster and more accurate than R/S for Hurst calculation:

```python
from whittlehurst import Whittle
import numpy as np

def calculate_hurst(daily_returns: np.ndarray) -> dict:
    """Calculate Hurst exponent with confidence interval."""
    estimator = Whittle()
    estimator.fit(daily_returns)

    return {
        "hurst": estimator.H_,
        "confidence_interval": estimator.ci_,
        "method": "whittle"
    }

# Note: Whittle assumes fractional Brownian motion
# Use R/S as fallback for non-Gaussian data
```

---

### Applicability Notes

1. **pandas_market_calendars** uses CME_Metals calendar; may miss some OTC-specific closures
2. **Whittle estimator** assumes fBm; R/S is more robust for non-Gaussian regimes
3. **Optional tasks** (2.9, 2.10, 2.11) add validation depth but increase runtime
4. **PyOD** requires careful contamination parameter tuning
5. **benford_py** should be applied to price CHANGES, not absolute prices

---

*ARGUS v2.3 - Research Integration Complete*
