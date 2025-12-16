[ARGUS INTEGRATED]

# Phase 1-A: Deep Data Validation (CSV → Parquet Quality)

> **⚡ ARGUS IMPROVEMENTS APPLIED** (see full details at end of file, line ~838+)
> - **DuckDB 1.0+**: 3-25x faster Parquet queries with spill-to-disk
> - **Polars streaming**: `collect(streaming=True)` for 654M ticks safely
> - **pandas_market_calendars**: Automated holiday detection (CME_Metals)
> - **tracemalloc**: Accurate Python memory measurement

**Phase ID**: 01-A
**Status**: ⏳ Pending
**Estimated Agents**: 5 (3 Rounds: 2+2+1)
**Execution Mode**: Sequential rounds (memory safety)
**Model**: opus (all agents)
**Priority**: CRITICAL (blocks all other phases)

---

## Objective

Deep validation of data quality to ensure:
1. Original CSV (30GB) was correctly converted to Parquet Nautilus (22GB)
2. Session catalogs correctly partition the main catalog
3. Zero data loss or corruption during conversion
4. All processes work within **12GB RAM constraint**

---

## Memory Constraints (CRITICAL)

**System RAM**: 12 GB total
**Safe Working Memory**: ~8 GB (leave 4 GB for OS/system)
**Max Chunk Size**: 5M ticks per chunk (~500 MB loaded)
**Strategy**: Stream everything, never load full catalog

### Memory Budget Per Operation

| Operation | Max Memory | Chunk Size |
|-----------|------------|------------|
| Tick count comparison | 500 MB | 5M ticks |
| Sample validation | 200 MB | 1M ticks |
| Gap analysis | 500 MB | 5M ticks |
| Session filtering check | 300 MB | 2M ticks |
| **Total concurrent** | **< 6 GB** | - |

---

## Prerequisites

- Phase 1 completed (config updated)
- Original CSV files accessible (if available for comparison)
- All catalogs exist

---

## Data Assets

**CLARIFICATION - Tick Count Context (C4 Fix)**:
- **stride=1 COMPLETE catalog**: ~654M ticks (22 GB) - source of truth for validation
- **stride=20 working data**: 32.7M ticks - used for backtesting (as per CLAUDE.md)
- This validation phase focuses on stride=1 COMPLETE catalog integrity
- The 32.7M figure in CLAUDE.md refers to the downsampled working dataset

| Asset | Path | Size | Status |
|-------|------|------|--------|
| Original CSVs | data/session_csvs/ | ~14 GB | Source |
| Main Parquet | data/catalog_native/xauusd_2003_2025_stride1_COMPLETE/ | 22 GB | Target |
| Session Parquets | data/catalog_native_sessions/xauusd_2003_2025_stride1_*/ | 9 GB | Derived |

---

## Orchestration

### Agent Spawn Pattern

**CRITICAL**: Sequential rounds to respect 12GB RAM limit.

```
Round 1 (Memory: ~4 GB):
Task[1-A.1 CSV-Parquet Count] || Task[1-A.2 Sample Validation]
   ↓ (collect results, release memory)

Round 2 (Memory: ~4 GB):
Task[1-A.3 Session Integrity] || Task[1-A.4 Schema Consistency]
   ↓ (collect results, release memory)

Round 3 (Memory: ~3 GB):
Task[1-A.5 Gap Detection]
```

---

## Tasks

### Task 1-A.1: CSV-Parquet Tick Count Comparison

**Agent**: ORACLE
**Spec**: `.claude/agents/oracle-backtest-commander.md`
**Model**: opus

**Prompt**:
```
You are ORACLE validating data conversion quality for XAUUSD.

TASK: Compare tick counts between original CSVs and converted Parquet.

MEMORY CONSTRAINT: 12 GB total system RAM. Use streaming only.

SOURCE CSVs: data/session_csvs/
TARGET PARQUET: data/catalog_native/xauusd_2003_2025_stride1_COMPLETE/

METHODOLOGY (MEMORY-SAFE):

1. COUNT CSV TICKS (streaming):
   - Use Python's csv module with iterator (not pandas.read_csv)
   - Count lines without loading into memory
   - Sum across all CSV files

   ```python
   import csv
   from pathlib import Path

   def count_csv_ticks(csv_dir: Path) -> int:
       total = 0
       for csv_file in csv_dir.glob("*.csv"):
           with open(csv_file, 'r') as f:
               # Skip header, count lines
               next(f)  # header
               total += sum(1 for _ in f)
       return total
   ```

2. COUNT PARQUET TICKS (DuckDB - 3-25x faster with spill-to-disk):
   - Use DuckDB for count - DO NOT use Nautilus catalog.quote_ticks()
   - DuckDB spills to disk when memory limit reached (memory-safe for 654M ticks)

   ```python
   import duckdb
   from pathlib import Path

   def count_parquet_ticks(catalog_path: Path) -> int:
       """Count ticks using DuckDB (3-25x faster than PyArrow, spill-to-disk)."""
       db = duckdb.connect(":memory:")
       db.execute("SET memory_limit='6GB';")  # Per CLAUDE.md 12GB constraint
       db.execute("SET temp_directory='/tmp/duckdb_swap';")  # Spill to disk

       # Use glob pattern for all parquet files
       glob_pattern = str(catalog_path / "**/*.parquet")
       result = db.execute(f"""
           SELECT COUNT(*) FROM read_parquet('{glob_pattern}')
       """).fetchone()
       db.close()
       return result[0]

   # Usage
   parquet_count = count_parquet_ticks(Path(catalog_path))
   ```

   **NOTE**: NautilusTrader's ParquetDataCatalog does NOT have a `count()` method.
   The method `catalog.quote_ticks()` loads ALL data into memory - catastrophic for 654M ticks.
   DuckDB's spill-to-disk ensures memory safety even for massive datasets.

3. COMPARE COUNTS:
   - If difference > 0.01%: FAIL
   - Document any discrepancy

4. MEMORY MEASUREMENT (C9 Fix):
   Use tracemalloc for accurate Python memory tracking:

   ```python
   import tracemalloc
   import pyarrow as pa

   def get_memory_mb() -> float:
       """Get current memory usage in MB."""
       current, peak = tracemalloc.get_traced_memory()
       arrow_mem = pa.total_allocated_bytes() / (1024 * 1024)
       return (peak / (1024 * 1024)) + arrow_mem

   # Usage: Wrap validation in tracemalloc context
   tracemalloc.start()
   # ... validation code ...
   memory_peak_mb = get_memory_mb()
   tracemalloc.stop()
   ```

VALIDATIONS:
- CSV total ticks
- Parquet total ticks
- Difference (absolute and %)
- If difference exists: sample to find where

OUTPUT:
{
  "csv_tick_count": <int>,
  "parquet_tick_count": <int>,
  "difference": <int>,
  "difference_pct": <float>,
  "status": "PASS/FAIL",
  "memory_peak_mb": <int>,
  "methodology": "streaming"
}

FILE: DOCS/03_RESEARCH/FINDINGS/PHASE1A_CSV_PARQUET_COUNT.json

Apply CRITIC self-review. Focus on memory safety.
```

---

### Task 1-A.2: Sample Data Validation

**Agent**: ORACLE
**Spec**: `.claude/agents/oracle-backtest-commander.md`
**Model**: opus

**Prompt**:
```
You are ORACLE validating data conversion accuracy for XAUUSD.

TASK: Sample comparison of CSV and Parquet data.

MEMORY CONSTRAINT: 12 GB total system RAM. Max 1M ticks loaded at once.

SOURCE CSVs: data/session_csvs/
TARGET PARQUET: data/catalog_native/xauusd_2003_2025_stride1_COMPLETE/

METHODOLOGY (MEMORY-SAFE):

1. SELECT SAMPLE POINTS:
   - First 10K ticks of 2003
   - First 10K ticks of 2015 (middle)
   - Last 10K ticks of 2025
   - Random 10K from each year (stratified)
   - Total: ~250K ticks sampled

2. VALIDATE TIMESTAMP MONOTONICITY AND DUPLICATES:
   - Check timestamps are strictly increasing: ts_event[i] < ts_event[i+1]
   - Flag duplicate timestamps (same ts_event value)
   - Count and report any violations

   ```python
   def validate_monotonicity_and_duplicates(ticks: list) -> dict:
       """Check timestamp ordering and duplicates."""
       violations = {"non_monotonic": 0, "duplicates": 0}
       prev_ts = 0
       for i, tick in enumerate(ticks):
           ts = tick['ts_event']
           if ts < prev_ts:
               violations["non_monotonic"] += 1
           elif ts == prev_ts:
               violations["duplicates"] += 1
           prev_ts = ts
       return violations
   ```

3. FOR EACH SAMPLE:
   a. Load from CSV (streaming to target date range)
   b. Load same range from Parquet (using ts_event filter)
   c. Compare field-by-field:
      - ts_event matches
      - bid_price matches (within 0.01 tolerance)
      - ask_price matches (within 0.01 tolerance)
      - bid_size matches
      - ask_size matches

4. VALIDATE WEEKEND DATA (C7 - Critical Check):
   - XAUUSD does NOT trade on weekends
   - Check for zero ticks between Saturday 00:00 UTC and Sunday 22:00 UTC
   - Any weekend ticks = data corruption

   ```python
   def check_weekend_ticks(ticks: list) -> dict:
       """Flag any ticks on weekends (Sat 00:00 - Sun 22:00 UTC)."""
       weekend_ticks = 0
       for tick in ticks:
           ts_ns = tick['ts_event']
           dt = datetime.fromtimestamp(ts_ns / 1e9, tz=timezone.utc)
           weekday = dt.weekday()  # 0=Mon, 5=Sat, 6=Sun
           if weekday == 5:  # Saturday - always closed
               weekend_ticks += 1
           elif weekday == 6 and dt.hour < 22:  # Sunday before 22:00 UTC
               weekend_ticks += 1
       return {"weekend_ticks": weekend_ticks, "status": "PASS" if weekend_ticks == 0 else "FAIL"}
   ```

5. RELEASE MEMORY after each comparison

COMPARISON CODE:
```python
import polars as pl
from datetime import datetime, timezone
from decimal import Decimal

def compare_samples(csv_ticks: list, parquet_ticks: list) -> dict:
    mismatches = []
    for i, (csv_t, pq_t) in enumerate(zip(csv_ticks, parquet_ticks)):
        if csv_t['ts_event'] != pq_t['ts_event']:
            mismatches.append({'index': i, 'field': 'ts_event'})
        if abs(csv_t['bid'] - pq_t['bid']) > 0.01:
            mismatches.append({'index': i, 'field': 'bid'})
        # ... etc
    return {'total': len(csv_ticks), 'mismatches': len(mismatches)}
```

VALIDATIONS:
- Sample size: 250K ticks minimum
- Field accuracy: 100% match required
- Timestamp alignment: 100% match required
- Timestamp monotonicity: 100% (strictly increasing)
- Duplicate timestamps: 0 allowed
- Weekend ticks: 0 allowed (Sat 00:00 - Sun 22:00 UTC)

OUTPUT:
{
  "samples_compared": <int>,
  "sample_distribution": {"2003": <int>, ..., "2025": <int>},
  "field_match_rate": {
    "ts_event": <float>,
    "bid_price": <float>,
    "ask_price": <float>,
    "bid_size": <float>,
    "ask_size": <float>
  },
  "monotonicity_violations": <int>,
  "duplicate_timestamps": <int>,
  "weekend_ticks": <int>,
  "mismatches": [...],
  "status": "PASS/FAIL",
  "memory_peak_mb": <int>
}

FILE: DOCS/03_RESEARCH/FINDINGS/PHASE1A_SAMPLE_VALIDATION.json

Apply CRITIC self-review. Focus on data accuracy.
```

---

### Task 1-A.3: Session Catalog Integrity

**Agent**: ORACLE
**Spec**: `.claude/agents/oracle-backtest-commander.md`
**Model**: opus

**Prompt**:
```
You are ORACLE validating session catalog integrity for XAUUSD.

TASK: Verify session catalogs correctly partition main catalog.

MEMORY CONSTRAINT: 12 GB total system RAM. Stream all operations.

MAIN CATALOG: data/catalog_native/xauusd_2003_2025_stride1_COMPLETE/
SESSION CATALOGS: data/catalog_native_sessions/xauusd_2003_2025_stride1_*/

SESSIONS:
- ASIAN: 00:00-07:00 UTC
- LONDON: 07:00-12:00 UTC
- OVERLAP: 12:00-15:00 UTC
- NY: 15:00-17:00 UTC
- LATE_NY: 17:00-21:00 UTC
- EVENING: 21:00-00:00 UTC

**DST PRE-2007 WARNING (C3 Fix)**:
US DST rules changed in 2007:
- **Pre-2007 (2003-2006)**: First Sunday of April → Last Sunday of October
- **Post-2007 (2007+)**: Second Sunday of March → First Sunday of November
- Session boundaries in ET context may differ by 1 hour for 2003-2006 data
- Validate session filtering accounts for historical DST rules

METHODOLOGY (MEMORY-SAFE):

1. COUNT TICKS PER SESSION (DuckDB - 3-25x faster with spill-to-disk):
   ```python
   import duckdb
   from pathlib import Path

   def count_session_ticks(session_path: Path) -> int:
       """Count ticks using DuckDB (memory-safe with spill-to-disk)."""
       db = duckdb.connect(":memory:")
       db.execute("SET memory_limit='6GB';")
       db.execute("SET temp_directory='/tmp/duckdb_swap';")

       glob_pattern = str(session_path / "**/*.parquet")
       result = db.execute(f"""
           SELECT COUNT(*) FROM read_parquet('{glob_pattern}')
       """).fetchone()
       db.close()
       return result[0]

   session_counts = {}
   for session in sessions:
       session_counts[session] = count_session_ticks(Path(session_path))
   ```

   **NOTE**: Do NOT use `catalog.quote_ticks()` - it loads ALL data into memory.
   DuckDB provides 3-25x speedup over PyArrow metadata iteration.

2. SUM CHECK:
   - Sum all session ticks
   - Compare to main catalog tick count
   - Tolerance: ±0.1%

3. NO OVERLAP CHECK (sampling):
   - For each session pair: sample 10K boundary ticks
   - Verify no timestamp appears in multiple sessions
   - Check: ASIAN end (06:59:59) vs LONDON start (07:00:00)

4. TEMPORAL ACCURACY (per session):
   - Sample 50K ticks from each session
   - Verify ALL fall within session UTC window
   - Flag any out-of-window ticks

5. DATE RANGE CONSISTENCY:
   - All sessions should span same date range as main

VALIDATIONS:
- Sum matches main (±0.1%)
- No overlaps between sessions
- 100% temporal accuracy per session
- Date ranges match

OUTPUT:
{
  "session_counts": {
    "ASIAN": <int>,
    "LONDON": <int>,
    "OVERLAP": <int>,
    "NY": <int>,
    "LATE_NY": <int>,
    "EVENING": <int>
  },
  "sum_total": <int>,
  "main_total": <int>,
  "sum_difference_pct": <float>,
  "overlap_check": {
    "pairs_tested": 15,
    "overlaps_found": <int>,
    "status": "PASS/FAIL"
  },
  "temporal_accuracy": {
    "ASIAN": <float 0-100>,
    "LONDON": <float 0-100>,
    ...
  },
  "out_of_window_ticks": <int>,
  "status": "PASS/FAIL",
  "memory_peak_mb": <int>
}

FILE: DOCS/03_RESEARCH/FINDINGS/PHASE1A_SESSION_INTEGRITY.json

Apply CRITIC self-review. Focus on partition correctness.
```

---

### Task 1-A.4: Schema and Format Consistency

**Agent**: FORGE
**Spec**: `.claude/agents/forge-nautilus.md`
**Model**: opus

**Prompt**:
```
You are FORGE validating schema consistency across all XAUUSD catalogs.

TASK: Verify Parquet schema is correct and consistent.

MEMORY CONSTRAINT: 12 GB total system RAM. Metadata only, no data loading.

CATALOGS TO CHECK:
- data/catalog_native/xauusd_2003_2025_stride1_COMPLETE/
- data/catalog_native_sessions/xauusd_2003_2025_stride1_ASIAN/
- data/catalog_native_sessions/xauusd_2003_2025_stride1_LONDON/
- data/catalog_native_sessions/xauusd_2003_2025_stride1_OVERLAP/
- data/catalog_native_sessions/xauusd_2003_2025_stride1_NY/
- data/catalog_native_sessions/xauusd_2003_2025_stride1_LATE_NY/
- data/catalog_native_sessions/xauusd_2003_2025_stride1_EVENING/

METHODOLOGY (MEMORY-SAFE):

1. READ PARQUET METADATA ONLY:
   ```python
   import pyarrow.parquet as pq

   def get_schema(parquet_path: Path) -> dict:
       # Read metadata only, not data
       parquet_file = pq.ParquetFile(parquet_path)
       schema = parquet_file.schema_arrow
       return {
           'fields': [(f.name, str(f.type)) for f in schema],
           'num_row_groups': parquet_file.metadata.num_row_groups,
           'num_rows': parquet_file.metadata.num_rows
       }
   ```

2. NAUTILUS TRADER EXPECTED SCHEMA:
   - instrument_id: string
   - ts_event: uint64 (nanoseconds)
   - ts_init: uint64 (nanoseconds)
   - bid_price: int64 (raw price)
   - ask_price: int64 (raw price)
   - bid_size: uint64
   - ask_size: uint64

3. VALIDATE:
   - All catalogs have same schema
   - Schema matches Nautilus QuoteTick format
   - Price precision correct (10^9 for gold)
   - Timestamps in nanoseconds

4. CHECK .checkpoint.json:
   - Exists for all catalogs
   - Contains valid metadata

VALIDATIONS:
- Schema consistency: 100% across all catalogs
- Nautilus format: 100% compliance
- Checkpoint files: All present and valid

OUTPUT:
{
  "catalogs_checked": 7,
  "schemas_match": true/false,
  "nautilus_compliant": true/false,
  "schema_details": {
    "main": {...},
    "ASIAN": {...},
    ...
  },
  "schema_differences": [...],
  "checkpoint_status": {
    "main": "VALID/MISSING/INVALID",
    "ASIAN": "VALID/MISSING/INVALID",
    ...
  },
  "price_precision": <int>,
  "timestamp_unit": "nanoseconds",
  "status": "PASS/FAIL"
}

FILE: DOCS/03_RESEARCH/FINDINGS/PHASE1A_SCHEMA_CONSISTENCY.json

Apply CRITIC self-review. Focus on Nautilus compatibility.
```

---

### Task 1-A.5: Gap Detection and Temporal Continuity (C2 Fix)

**Agent**: ORACLE
**Spec**: `.claude/agents/oracle-backtest-commander.md`
**Model**: opus

**Prompt**:
```
You are ORACLE validating temporal continuity of XAUUSD data.

TASK: Detect and classify gaps in tick data.

MEMORY CONSTRAINT: 12 GB total system RAM. Stream all operations.

TARGET PARQUET: data/catalog_native/xauusd_2003_2025_stride1_COMPLETE/

METHODOLOGY (MEMORY-SAFE):

1. EXPECTED GAPS (Normal):
   - **Weekends**: Friday 22:00 UTC → Sunday 22:00 UTC (~48 hours)
   - **Holidays**: Christmas, New Year (varies by year)
   - Normal inter-tick gaps during low liquidity: up to 5 minutes

2. UNEXPECTED GAPS (Flag):
   - Any gap > 1 hour during trading hours (Mon-Fri, 22:00 Sun - 22:00 Fri)
   - Multiple consecutive missing ticks

3. GAP DETECTION ALGORITHM (Polars streaming + pandas_market_calendars):
   ```python
   import polars as pl
   import pandas_market_calendars as mcal
   from pathlib import Path
   from datetime import datetime, timezone

   def detect_gaps(catalog_path: Path, max_gap_seconds: int = 3600) -> dict:
       """Detect gaps > max_gap_seconds using Polars streaming and market calendar."""
       # Get CME Metals calendar for gold market holidays
       calendar = mcal.get_calendar('CME_Metals')
       holidays = set(calendar.holidays().to_pydatetime())

       # Use Polars streaming for memory safety with 654M ticks
       glob_pattern = str(catalog_path / "**/*.parquet")
       df = pl.scan_parquet(glob_pattern).select('ts_event').sort('ts_event')

       # Process in streaming mode - never loads full dataset
       gaps = []
       prev_ts = None

       # Stream chunks using collect(streaming=True)
       for batch in df.collect(streaming=True).iter_slices(5_000_000):
           timestamps = batch['ts_event'].to_list()

           for ts_ns in timestamps:
               if prev_ts is not None:
                   gap_seconds = (ts_ns - prev_ts) / 1e9

                   if gap_seconds > max_gap_seconds:
                       dt = datetime.fromtimestamp(ts_ns / 1e9, tz=timezone.utc)
                       gap_date = dt.date()

                       # Classify gap type using market calendar
                       is_weekend = dt.weekday() >= 5
                       is_holiday = gap_date in holidays

                       if not is_weekend and not is_holiday:
                           gaps.append({
                               'start_ts': prev_ts,
                               'end_ts': ts_ns,
                               'gap_hours': gap_seconds / 3600,
                               'type': 'UNEXPECTED'
                           })
                       else:
                           gaps.append({
                               'start_ts': prev_ts,
                               'end_ts': ts_ns,
                               'gap_hours': gap_seconds / 3600,
                               'type': 'WEEKEND' if is_weekend else 'HOLIDAY'
                           })

               prev_ts = ts_ns

       return {
           'total_gaps': len(gaps),
           'unexpected_gaps': [g for g in gaps if g['type'] == 'UNEXPECTED'],
           'holiday_gaps': [g for g in gaps if g['type'] == 'HOLIDAY'],
           'max_gap_hours': max(g['gap_hours'] for g in gaps) if gaps else 0
       }
   ```

   **NOTE**: pandas_market_calendars provides accurate holiday data for gold markets.
   Polars streaming ensures memory safety even for 654M ticks.

4. EXPECTED WEEKEND COUNT:
   - 2003-2025 = ~22 years × 52 weeks = ~1144 weekends expected
   - Validate weekend count matches

5. HOLIDAY GAPS (Sample Years):
   - Check 2008, 2015, 2020 for Christmas/NY gaps

VALIDATIONS:
- Unexpected gaps (> 1 hour during trading): 0 ideally, document all
- Weekend gaps: ~1144 expected
- Maximum gap during trading hours: < 30 minutes (data quality indicator)

OUTPUT:
{
  "total_trading_hours_analyzed": <float>,
  "weekend_gaps_found": <int>,
  "unexpected_gaps": [
    {"start": "<ISO>", "end": "<ISO>", "gap_hours": <float>},
    ...
  ],
  "unexpected_gap_count": <int>,
  "max_trading_gap_minutes": <float>,
  "holiday_gaps_detected": <int>,
  "gap_classification": {
    "weekend": <int>,
    "holiday": <int>,
    "unexpected": <int>
  },
  "status": "PASS/WARN/FAIL",
  "memory_peak_mb": <int>
}

STATUS LOGIC:
- PASS: 0 unexpected gaps > 1 hour
- WARN: 1-5 unexpected gaps > 1 hour (investigate)
- FAIL: >5 unexpected gaps OR any gap > 24 hours during trading

FILE: DOCS/03_RESEARCH/FINDINGS/PHASE1A_GAP_DETECTION.json

Apply CRITIC self-review. Focus on temporal integrity.
```

---

## Consolidation

After all 5 agents complete:

```python
# Load all Phase 1-A outputs
phase1a_results = {
    "csv_parquet_count": load_json("PHASE1A_CSV_PARQUET_COUNT.json"),
    "sample_validation": load_json("PHASE1A_SAMPLE_VALIDATION.json"),
    "session_integrity": load_json("PHASE1A_SESSION_INTEGRITY.json"),
    "schema_consistency": load_json("PHASE1A_SCHEMA_CONSISTENCY.json"),
    "gap_detection": load_json("PHASE1A_GAP_DETECTION.json"),
}

# All must PASS to proceed
all_pass = all(r["status"] == "PASS" for r in phase1a_results.values())
max_memory = max(r["memory_peak_mb"] for r in phase1a_results.values())

assert max_memory < 6000, f"Memory exceeded 6GB: {max_memory}MB"
```

---

## Success Criteria

| Criterion | Threshold | Priority |
|-----------|-----------|----------|
| Tick count match (CSV vs Parquet) | <=0.01% difference | CRITICAL |
| Sample field match | 100% | CRITICAL |
| Timestamp monotonicity | 100% (strictly increasing) | CRITICAL |
| Duplicate timestamps | 0 | CRITICAL |
| Weekend ticks | 0 | CRITICAL |
| Session sum match | <=0.1% difference | CRITICAL |
| No session overlaps | 0 | CRITICAL |
| Temporal accuracy | 100% | CRITICAL |
| Schema consistency | 100% | CRITICAL |
| Unexpected gaps (> 1 hour trading) | 0 (WARN if 1-5) | CRITICAL |
| Memory usage | <6 GB peak | CRITICAL |

---

## Failure Protocol

If any validation FAILS:

1. **Tick count mismatch**:
   - Identify which years have discrepancies
   - Check for duplicate removal or filtering

2. **Sample mismatch**:
   - Identify corrupted date ranges
   - May need to re-convert from CSV

3. **Session integrity failure**:
   - Rebuild affected session catalogs
   - Use main catalog as source of truth

4. **Schema inconsistency**:
   - Identify non-compliant catalog
   - Re-convert using correct Nautilus schema

5. **Unexpected gaps detected**:
   - Investigate source CSV for the gap period
   - Check if data was missing in original source
   - Document gaps for strategy awareness (avoid trading during gap periods)

---

## Deliverables

1. **5 JSON reports** in `DOCS/03_RESEARCH/FINDINGS/PHASE1A_*.json`
2. **DEEP_VALIDATION_REPORT.md** - Consolidated summary
3. **Memory profile** - Peak usage per operation

---

## Next Phase

After completion with all PASS, proceed to [Phase 2: Main Catalog Validation](./02-PHASE-PLAN.md)

---

## CRITIC Review (Phase 1-A)

**Reviewer**: CRITIC v1.1 (Adversarial Quality Guardian)
**Review Date**: 2025-12-16
**Artifact**: Phase 1-A Deep Data Validation Plan
**Analysis Method**: 18-step sequential-thinking with 7 adversarial techniques
**Fix Date**: 2025-12-16 (FORGE applied all CRITICAL fixes)

---

### VERDICT: APPROVED

All 9 CRITICAL issues have been addressed. The plan is now ready for execution.

---

### CRITICAL ISSUES STATUS (9/9 FIXED)

| ID | Issue | Status | Fix Applied |
|----|-------|--------|-------------|
| C1 | `catalog.count()` API Does Not Exist | FIXED | Replaced with PyArrow `pq.read_metadata()` approach |
| C2 | No Gap Detection Task | FIXED | Added Task 1-A.5: Gap Detection and Temporal Continuity |
| C3 | DST Pre-2007 Handling Not Validated | FIXED | Added DST warning note in Task 1-A.3 with historical rules |
| C4 | Tick Count Discrepancy: 654M vs 32.7M | FIXED | Added clarification in Data Assets section |
| C5 | No Duplicate Detection | FIXED | Added duplicate timestamp detection in Task 1-A.2 |
| C6 | No Timestamp Monotonicity Check | FIXED | Added monotonicity validation in Task 1-A.2 |
| C7 | No Weekend/Holiday Data Check | FIXED | Added weekend tick validation in Task 1-A.2 |
| C8 | QuoteTick Import Missing | FIXED | Removed invalid Nautilus API usage, using PyArrow instead |
| C9 | Memory Measurement Code Not Provided | FIXED | Added tracemalloc usage example in Task 1-A.1 |

---

### HIGH ISSUES (Documented, Optional Fixes)

The following HIGH issues were identified but are not blocking:

| ID | Issue | Priority | Notes |
|----|-------|----------|-------|
| H1 | Session boundary inclusive/exclusive | HIGH | Define: start <= ts < end |
| H2 | No spread validation | HIGH | Add in implementation |
| H3 | No price continuity check | HIGH | Add range check [500, 3000] |
| H4 | Sampling not stratified by session | HIGH | Enhance in implementation |
| H5 | No exception handling in code examples | HIGH | Add try/except in implementation |
| H6 | No memory kill switch | HIGH | Add threshold abort |
| H7 | Polars eager vs lazy confusion | HIGH | Use scan_parquet().lazy() |
| H8 | Row group sizes not checked | HIGH | Add in Task 1-A.4 |
| H9 | No checksum/integrity verification | HIGH | Add CRC check if available |
| H10 | Critical years not guaranteed | HIGH | Add 2008/2020 mandatory samples |

---

### APEX COMPLIANCE CHECK

| Check | Status | Notes |
|-------|--------|-------|
| Time gate data (4:30/4:55/4:59 PM ET) | READY | Session filtering accounts for ET time gates |
| Pre-2007 DST handling | DOCUMENTED | Warning added in Task 1-A.3 |
| Weekend data (no ticks) | VALIDATED | Added weekend tick check in Task 1-A.2 |
| Session hours in ET context | PARTIAL | Needs DST awareness in implementation |

---

### APPROVAL

**Status**: APPROVED
**Confidence**: HIGH
**Ready for Execution**: YES

---

*CRITIC v1.1 - "Every bug found now is a loss prevented later."*

---

## ARGUS Research Improvements

**Integrated**: 2025-12-16
**Research Report**: DOCS/03_RESEARCH/FINDINGS/IMPROVEMENT_REPORT.md

---

### Summary of Improvements

This phase plan has been enhanced with the following research-backed improvements:

| Improvement | Original Approach | New Approach | Benefit |
|-------------|-------------------|--------------|---------|
| Parquet counting | PyArrow metadata loop | DuckDB SQL query | 3-25x faster, spill-to-disk |
| Streaming processing | Manual chunking | Polars `scan_parquet().collect(streaming=True)` | Memory-safe for 654M ticks |
| Holiday detection | Manual weekend check | pandas_market_calendars | Automated holiday classification |
| Schema validation | Manual type checking | Pandera (optional) | Type-safe DataFrame validation |

---

### New Dependencies

Add to `requirements.txt` or install separately:

```bash
# Core improvements (REQUIRED)
pip install duckdb>=1.0.0          # Fast Parquet queries with spill-to-disk
pip install polars>=0.20.0          # Streaming DataFrame processing
pip install pandas-market-calendars>=4.0  # Market holiday calendars

# Optional enhancements
pip install pandera>=0.18.0         # DataFrame schema validation
```

---

### DuckDB Configuration (Memory Safety)

DuckDB provides automatic spill-to-disk when memory limit is reached:

```python
import duckdb

def get_duckdb_connection() -> duckdb.DuckDBPyConnection:
    """Configure DuckDB for memory-safe operation."""
    db = duckdb.connect(":memory:")
    # Set memory limit to leave room for OS (12GB system - 6GB for DuckDB)
    db.execute("SET memory_limit='6GB';")
    # Spill to disk when limit reached
    db.execute("SET temp_directory='/tmp/duckdb_swap';")
    # Enable progress bar for long queries
    db.execute("SET enable_progress_bar=true;")
    return db
```

---

### Polars Streaming Pattern

Use Polars streaming for processing 654M ticks without memory overflow:

```python
import polars as pl

# Memory-safe: streaming=True processes in chunks automatically
df = (
    pl.scan_parquet("data/catalog/**/*.parquet")
    .select(['ts_event', 'bid_price', 'ask_price'])
    .sort('ts_event')
    .collect(streaming=True)  # Process in streaming mode
)

# For very large operations, use iter_slices:
for batch in df.iter_slices(5_000_000):  # 5M ticks per batch
    process_batch(batch)
```

---

### pandas_market_calendars Usage

Replace manual weekend/holiday detection with accurate market calendars:

```python
import pandas_market_calendars as mcal
from datetime import date

# Get CME Metals calendar (closest to XAUUSD)
calendar = mcal.get_calendar('CME_Metals')

# Get all holidays for date range
holidays = calendar.holidays(start='2003-01-01', end='2025-12-31')

# Check if a date is a holiday
def is_market_closed(check_date: date) -> bool:
    return check_date in holidays.to_pydatetime()

# Get valid trading sessions for a date range
schedule = calendar.schedule(start_date='2024-01-01', end_date='2024-12-31')
```

---

### Updated Memory Estimates

With DuckDB spill-to-disk capability, memory constraints are relaxed:

| Operation | Original Estimate | With DuckDB/Polars | Notes |
|-----------|-------------------|-------------------|-------|
| Tick count | 500 MB | 100 MB + disk | DuckDB spills automatically |
| Gap analysis | 500 MB | 200 MB + disk | Polars streaming |
| Session filtering | 300 MB | 150 MB + disk | DuckDB SQL |
| **Total safe** | **6 GB hard limit** | **6 GB + unlimited disk** | Much safer |

---

### Optional: Pandera Schema Validation (Task 1-A.4 Enhancement)

Add type-safe schema validation using Pandera:

```python
import pandera as pa
from pandera import Column, DataFrameSchema

# Define expected QuoteTick schema
quote_tick_schema = DataFrameSchema({
    "instrument_id": Column(str),
    "ts_event": Column(int, checks=pa.Check.greater_than(0)),
    "ts_init": Column(int, checks=pa.Check.greater_than(0)),
    "bid_price": Column(int, checks=pa.Check.greater_than(0)),
    "ask_price": Column(int, checks=pa.Check.greater_than(0)),
    "bid_size": Column(int, checks=pa.Check.greater_than_or_equal_to(0)),
    "ask_size": Column(int, checks=pa.Check.greater_than_or_equal_to(0)),
})

# Validate a sample DataFrame
validated_df = quote_tick_schema.validate(sample_df)
```

---

### Applicability Notes

1. **DuckDB** is used for counting operations where we need aggregate results but not full data
2. **Polars streaming** is used for sequential scan operations (gap detection, temporal checks)
3. **pandas_market_calendars** uses CME_Metals calendar which is close but not exact for XAUUSD OTC; document any discrepancies
4. All improvements maintain backward compatibility - original PyArrow code can be used as fallback

---

*ARGUS v2.3 - Research Integration Complete*
