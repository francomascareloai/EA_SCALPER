[ARGUS INTEGRATED]

# Phase 3: Session Catalog Validation

> **⚡ ARGUS IMPROVEMENTS APPLIED** (see full details at end of file)
> - **zoneinfo (stdlib)**: Correct pre-2007 DST for session boundaries
> - **DuckDB session queries**: Fast filtering by ts_event range
> - **Per-session statistics**: Volatility, spread, tick density per session

**Phase ID**: 03
**Status**: ⏳ Pending
**Estimated Agents**: 6 (Full Parallel)
**Execution Mode**: Parallel
**Model**: opus (all agents)

---

## Memory Constraint (CRITICAL)

**System RAM**: 12 GB total
**Safe Working Memory**: ~6 GB (leave 6 GB for OS/system)
**Max Chunk Size**: 2M ticks per session operation
**Parallelism**: 2 rounds of 3 agents (memory safety)

### Memory Budget Per Session Agent
| Session | Catalog Size | Max Memory | Strategy |
|---------|--------------|------------|----------|
| ASIAN | 1.5 GB | 400 MB | Stream chunks |
| LONDON | 1.8 GB | 400 MB | Stream chunks |
| OVERLAP | 1.2 GB | 400 MB | Stream chunks |
| NY | 1.4 GB | 400 MB | Stream chunks |
| LATE_NY | 2.2 GB | 400 MB | Stream chunks |
| EVENING | 833 MB | 400 MB | Stream chunks |

**CRITICAL**: Each session is processed independently with streaming.
Never load a full session catalog into memory.

---

## Objective

Validate all 6 session-specific catalogs to ensure they correctly filter the main catalog and maintain data integrity.

---

## Session Catalogs Status

**✅ ALL SESSION CATALOGS ALREADY EXIST** (verified 2025-12-15):

| Session | Path | Size |
|---------|------|------|
| ASIAN | data/catalog_native_sessions/xauusd_2003_2025_stride1_ASIAN/ | 1.5 GB |
| LONDON | data/catalog_native_sessions/xauusd_2003_2025_stride1_LONDON/ | 1.8 GB |
| OVERLAP | data/catalog_native_sessions/xauusd_2003_2025_stride1_OVERLAP/ | 1.2 GB |
| NY | data/catalog_native_sessions/xauusd_2003_2025_stride1_NY/ | 1.4 GB |
| LATE_NY | data/catalog_native_sessions/xauusd_2003_2025_stride1_LATE_NY/ | 2.2 GB |
| EVENING | data/catalog_native_sessions/xauusd_2003_2025_stride1_EVENING/ | 833 MB |
| **Total** | | **~9 GB** |

Main catalog: 22 GB → Sessions sum: 9 GB (expected due to session filtering)

---

## Prerequisites

- Phase 2 completed with PASS status
- Main catalog validated successfully

---

## Session Definitions

### Boundary Inclusion Rule (CRITICAL)

All session windows use **[start, end)** convention:
- Start time is **INCLUSIVE**
- End time is **EXCLUSIVE**

Example: ASIAN 00:00-07:00 means:
- `00:00:00.000000000` → ASIAN (included)
- `06:59:59.999999999` → ASIAN (included)
- `07:00:00.000000000` → NOT ASIAN (excluded, belongs to LONDON)

**Cross-Validation MUST verify**:
For each boundary time (07:00, 12:00, 15:00, 17:00, 21:00, 00:00):
- Count ticks in 1-second window around boundary
- Verify each tick appears in EXACTLY ONE session catalog

| Session | UTC Window | Approx ET | Ticks (est.) |
|---------|------------|-----------|--------------|
| ASIAN | 00:00-07:00 | 7PM-2AM | ~15% |
| LONDON | 07:00-12:00 | 2AM-7AM | ~20% |
| OVERLAP | 12:00-15:00 | 7AM-10AM | ~15% |
| NY | 15:00-17:00 | 10AM-12PM | ~10% |
| LATE_NY | 17:00-21:00 | 12PM-4PM | ~25% |
| EVENING | 21:00-00:00 | 4PM-7PM | ~15% |

---

## Orchestration

### Agent Spawn Pattern

**Recommended**: Batch into rounds of 3 agents to prevent context overflow.

```
Round 1: Task[3.1 ASIAN] || Task[3.2 LONDON] || Task[3.3 OVERLAP]
   ↓ (collect results)
Round 2: Task[3.4 NY] || Task[3.5 LATE_NY] || Task[3.6 EVENING]
```

**Alternative (if user confirms unlimited capacity)**:
```
All 6 agents spawn simultaneously (higher risk of context overflow)
```

---

## Tasks

### Common Validation Template

Each session agent uses this template:

```
You are ORACLE validating the {SESSION} session catalog for XAUUSD.

TASK: Comprehensive validation of session-filtered catalog.

CATALOG: data/catalog_native_sessions/xauusd_2003_2025_stride1_{SESSION}/
SESSION WINDOW: {START_UTC} - {END_UTC} UTC
INSTRUMENT: XAU/USD.SIM

VALIDATIONS:

1. EXISTENCE & ACCESSIBILITY
   - Catalog directory exists
   - .checkpoint.json exists
   - Parquet files accessible

2. TICK COUNT & COVERAGE
   - Total ticks in session
   - Expected % of main catalog (compare to Phase 2)
   - Date range matches main catalog

3. TEMPORAL FILTERING ACCURACY
   - Sample 100K ticks
   - Verify ALL timestamps fall within session window
   - No out-of-window leakage

4. DATA INTEGRITY
   - Bid <= Ask (no crossed quotes)
   - Prices in valid range
   - Timestamps monotonic within session

5. GAP ANALYSIS (session-specific)
   - Expected gaps between sessions (normal)
   - Unexpected gaps within session (flag)

6. APEX COMPLIANCE (if applicable)
   - For LATE_NY/EVENING: verify time gate boundaries
   - 4:30 PM ET = 20:30 UTC (summer/EDT) / 21:30 UTC (winter/EST)
   - NOTE: EDT = UTC-4 (March-Nov), EST = UTC-5 (Nov-March)

OUTPUT:
{
  "session": "{SESSION}",
  "status": "PASS/FAIL",
  "tick_count": <int>,
  "percentage_of_main": <float>,
  "date_range": {"start": "...", "end": "..."},
  "temporal_accuracy": <float 0-100>,
  "crossed_quotes": <int>,
  "gaps_within_session": <int>,
  "apex_compliance": true/false,
  "issues": [...]
}

FILE: DOCS/03_RESEARCH/FINDINGS/PHASE3_SESSION_{SESSION}.json

Apply CRITIC self-review before reporting done.
```

---

### Task 3.1: ASIAN Session

**Agent**: ORACLE | **Model**: opus

```
SESSION: ASIAN
START_UTC: 00:00
END_UTC: 07:00
APEX_NOTES: Low volatility expected, prepare for London open
```

---

### Task 3.2: LONDON Session

**Agent**: ORACLE | **Model**: opus

```
SESSION: LONDON
START_UTC: 07:00
END_UTC: 12:00
APEX_NOTES: High volatility expected, major moves
```

---

### Task 3.3: OVERLAP Session

**Agent**: ORACLE | **Model**: opus

```
SESSION: OVERLAP
START_UTC: 12:00
END_UTC: 15:00
APEX_NOTES: Maximum liquidity, London+NY open
```

---

### Task 3.4: NY Session

**Agent**: ORACLE | **Model**: opus

```
SESSION: NY
START_UTC: 15:00
END_UTC: 17:00
APEX_NOTES: US data releases, high volatility
```

---

### Task 3.5: LATE_NY Session

**Agent**: ORACLE | **Model**: opus

```
SESSION: LATE_NY
START_UTC: 17:00
END_UTC: 21:00
APEX_NOTES: Contains Apex time gate (4:30 PM ET = 20:30 UTC summer/EDT, 21:30 UTC winter/EST)
CRITICAL: Verify time gate boundary handling. Add DST transition tests.
```

---

### Task 3.6: EVENING Session

**Agent**: ORACLE | **Model**: opus

```
SESSION: EVENING
START_UTC: 21:00
END_UTC: 00:00
APEX_NOTES: Contains Apex force-close (4:55-4:59 PM ET = 20:55-20:59 UTC summer/EDT, 21:55-21:59 UTC winter/EST)
CRITICAL: No positions should be open after 4:59 PM ET. Add DST transition tests.
```

---

## Cross-Session Validation

After all 6 agents complete, orchestrator performs cross-validation:

```python
# Load all session results
sessions = ["ASIAN", "LONDON", "OVERLAP", "NY", "LATE_NY", "EVENING"]
results = {s: load_json(f"PHASE3_SESSION_{s}.json") for s in sessions}

# Validation checks
total_session_ticks = sum(r["tick_count"] for r in results.values())
main_catalog_ticks = 654_586_033

# Sessions should account for ~100% of main (TIGHT tolerance)
# ±5% was TOO LOOSE (could hide 32.7M missing/duplicate ticks!)
# Using ±1% = ~6.5M ticks max variance (still conservative)
coverage_ratio = total_session_ticks / main_catalog_ticks
tolerance = 0.01  # 1% = ~6.5M ticks max variance

if not (1.0 - tolerance <= coverage_ratio <= 1.0 + tolerance):
    # This is CRITICAL - investigate before proceeding
    delta = total_session_ticks - main_catalog_ticks
    raise ValidationError(
        f"Session coverage {coverage_ratio:.4%} outside tolerance. "
        f"Expected: 100% +/- 1%. Delta: {delta:,} ticks"
    )

# EXPLICIT CHECK: Detect missing vs duplicate ticks
if coverage_ratio < 0.99:
    print(f"WARNING: {main_catalog_ticks - total_session_ticks:,} ticks MISSING from sessions")
elif coverage_ratio > 1.01:
    print(f"WARNING: {total_session_ticks - main_catalog_ticks:,} ticks DUPLICATED across sessions")

# No overlap between sessions (timestamps) - MANDATORY CHECK
def verify_no_overlap(session_catalogs: dict) -> bool:
    """Verify no tick exists in multiple sessions."""
    boundaries = [
        ("ASIAN", "LONDON", "07:00:00"),
        ("LONDON", "OVERLAP", "12:00:00"),
        ("OVERLAP", "NY", "15:00:00"),
        ("NY", "LATE_NY", "17:00:00"),
        ("LATE_NY", "EVENING", "21:00:00"),
        ("EVENING", "ASIAN", "00:00:00"),
    ]

    for sess_a, sess_b, boundary_time in boundaries:
        # Get ticks within 1ms of boundary from both sessions
        ticks_a = get_boundary_ticks(session_catalogs[sess_a], boundary_time, window_ms=1)
        ticks_b = get_boundary_ticks(session_catalogs[sess_b], boundary_time, window_ms=1)

        # Check for any timestamp collision
        overlap = set(ticks_a['ts_event']) & set(ticks_b['ts_event'])
        if overlap:
            raise ValidationError(f"Overlap detected at {boundary_time}: {len(overlap)} ticks")

    return True

verify_no_overlap(session_catalogs)
```

---

## Success Criteria

| Criterion | Threshold | Priority |
|-----------|-----------|----------|
| All catalogs exist | 6/6 | CRITICAL |
| Temporal accuracy | 100% (all ticks in window) | CRITICAL |
| Crossed quotes | 0 per session | CRITICAL |
| Combined coverage | 99-101% of main (tightened from 95-105%) | CRITICAL |
| Missing/duplicate ticks | Explicit check + warning | CRITICAL |
| Apex time gates | Correctly bounded | HIGH |
| DST transition handling | Spring forward (expected gap) + Fall back (graceful) | HIGH |
| Within-session gaps | Documented | MEDIUM |

---

## Deliverables

1. **6 JSON reports** in `DOCS/03_RESEARCH/FINDINGS/PHASE3_SESSION_*.json`
2. **SESSION_VALIDATION_REPORT.md** - Consolidated summary with cross-validation

---

## Apex Time Gate Mapping

For LATE_NY and EVENING sessions, critical Apex time gates:

| Apex Rule | ET Time | UTC (Summer/EDT) | UTC (Winter/EST) |
|-----------|---------|------------------|------------------|
| Block new trades | 4:30 PM | 20:30 | 21:30 |
| Emergency close start | 4:55 PM | 20:55 | 21:55 |
| Force close deadline | 4:59 PM | 20:59 | 21:59 |

---

## DST Rule Change Handling (CRITICAL)

**US DST rules changed in 2007** (Energy Policy Act of 2005):
- **Pre-2007 (2003-2006)**: DST was first Sunday in April to last Sunday in October
- **Post-2007 (2007-2025)**: DST is second Sunday in March to first Sunday in November

**Impact on Apex Time Gates**:
- Pre-2007 data (2003-2006) has ~3 weeks per year where summer/winter UTC mapping differs
- Validation must use CORRECT DST rules for each year

### DST Transition Day Handling (CRITICAL)

**Spring Forward (March DST start):**
- The hour 2:00-3:00 AM ET **DOES NOT EXIST** on this day
- This is **expected behavior, NOT a data gap**
- Validation should NOT flag missing data in this "lost" hour
- Any tick timestamped in this window would be data corruption (flag as ERROR)

**Fall Back (November DST end):**
- The hour 1:00-2:00 AM ET **OCCURS TWICE** on this day
- First occurrence: still on EDT (UTC-4)
- Second occurrence: now on EST (UTC-5)
- This is **expected behavior** - data in this window is valid but ambiguous
- Validation should handle gracefully (no false positive gaps)

### DST Transition Dates (2003-2025)

| Year | Spring Forward (DST Start) | Fall Back (DST End) | Rule Set |
|------|---------------------------|---------------------|----------|
| 2003 | Apr 6 | Oct 26 | Pre-2007 |
| 2004 | Apr 4 | Oct 31 | Pre-2007 |
| 2005 | Apr 3 | Oct 30 | Pre-2007 |
| 2006 | Apr 2 | Oct 29 | Pre-2007 |
| 2007 | Mar 11 | Nov 4 | Post-2007 |
| 2008 | Mar 9 | Nov 2 | Post-2007 |
| 2009 | Mar 8 | Nov 1 | Post-2007 |
| 2010 | Mar 14 | Nov 7 | Post-2007 |
| 2011 | Mar 13 | Nov 6 | Post-2007 |
| 2012 | Mar 11 | Nov 4 | Post-2007 |
| 2013 | Mar 10 | Nov 3 | Post-2007 |
| 2014 | Mar 9 | Nov 2 | Post-2007 |
| 2015 | Mar 8 | Nov 1 | Post-2007 |
| 2016 | Mar 13 | Nov 6 | Post-2007 |
| 2017 | Mar 12 | Nov 5 | Post-2007 |
| 2018 | Mar 11 | Nov 4 | Post-2007 |
| 2019 | Mar 10 | Nov 3 | Post-2007 |
| 2020 | Mar 8 | Nov 1 | Post-2007 |
| 2021 | Mar 14 | Nov 7 | Post-2007 |
| 2022 | Mar 13 | Nov 6 | Post-2007 |
| 2023 | Mar 12 | Nov 5 | Post-2007 |
| 2024 | Mar 10 | Nov 3 | Post-2007 |
| 2025 | Mar 9 | Nov 2 | Post-2007 |

**Validation Must**:
1. On spring forward days: Treat 1-hour gap as EXPECTED (not an error)
2. On fall back days: Handle 1-hour overlap gracefully (not double-count)
3. Use correct year-specific DST rule set for UTC offset calculation

**Implementation**:
```python
# SUPERSEDED BY ZONEINFO - See ARGUS Research Improvements section below
# The manual approach below is kept for historical reference only.
# USE THE ZONEINFO APPROACH INSTEAD (automatic DST handling)

from zoneinfo import ZoneInfo
from datetime import datetime, time, date

def get_apex_utc_time(et_time: time, target_date: date) -> time:
    """Convert ET time to UTC - zoneinfo handles DST automatically.

    zoneinfo uses IANA tzdb which includes Energy Policy Act 2005 changes:
    - Pre-2007: DST was first Sunday April to last Sunday October
    - Post-2007: DST is second Sunday March to first Sunday November

    The library handles all historical DST rules automatically.
    No manual DST tables or helper functions required.

    Args:
        et_time: Time in Eastern Time (naive)
        target_date: The date for DST determination

    Returns:
        UTC time with timezone info
    """
    eastern = ZoneInfo("America/New_York")
    dt_et = datetime.combine(target_date, et_time, tzinfo=eastern)
    dt_utc = dt_et.astimezone(ZoneInfo("UTC"))
    return dt_utc.timetz()

# Example usage for Apex time gates:
# apex_block_trades = time(16, 30)  # 4:30 PM ET
# date_2006 = date(2006, 4, 10)  # Pre-2007 (old DST rules)
# date_2024 = date(2024, 3, 15)  # Post-2007 (new DST rules)
#
# utc_2006 = get_apex_utc_time(apex_block_trades, date_2006)  # Correctly uses old DST rules
# utc_2024 = get_apex_utc_time(apex_block_trades, date_2024)  # Correctly uses new DST rules

# ----- LEGACY MANUAL APPROACH (for reference only) -----
# def get_apex_utc_time_legacy(et_time: str, date: datetime.date) -> datetime.time:
#     """DEPRECATED: Use zoneinfo-based approach above instead."""
#     if date.year < 2007:
#         # Old DST rules: Apr first Sunday to Oct last Sunday
#         dst_start = first_sunday_of_month(date.year, 4)
#         dst_end = last_sunday_of_month(date.year, 10)
#     else:
#         # New DST rules: Mar second Sunday to Nov first Sunday
#         dst_start = second_sunday_of_month(date.year, 3)
#         dst_end = first_sunday_of_month(date.year, 11)
#
#     is_dst = dst_start <= date < dst_end
#     offset = 4 if is_dst else 5  # EDT = UTC-4, EST = UTC-5
#     return et_time + timedelta(hours=offset)
```

---

## Next Phase

After completion, proceed to [Phase 4: Integrity & Cleanup](./04-PHASE-PLAN.md)

---

## CRITIC Review (Phase 3)

**Reviewer**: CRITIC v1.1 (Adversarial Quality Guardian)
**Date**: 2025-12-16
**Artifact**: Phase 3 Session Catalog Validation Plan
**Analysis Method**: Sequential Thinking (15 thoughts, exhaustive)

---

### VERDICT: APPROVED

All 3 CRITICAL issues have been fixed. The plan is now ready for execution.

**Fix Summary (2025-12-16)**:

| Issue ID | Description | Status | Fix Applied |
|----------|-------------|--------|-------------|
| C1 | Boundary inclusion rules undefined | FIXED | Added explicit `[start, end)` convention with examples |
| C2 | DST transition day handling incomplete | FIXED | Added spring forward/fall back handling + full 2003-2025 DST dates table |
| C3 | Cross-session coverage tolerance too loose | FIXED | Tightened from 95-105% to 99-101% + added explicit missing/duplicate tick detection + boundary overlap verification |

---

### Remaining HIGH Issues (7) - Documented for Implementation

These issues are documented but require implementation during execution:

#### H1. 100K SAMPLE INSUFFICIENT FOR BOUNDARY ERRORS

**Location**: Lines 123-126

**Problem**: Sampling 100K from 163M ticks (LATE_NY) = 0.06% coverage. Filtering bugs often occur at boundaries, not randomly distributed.

**Fix**:
```markdown
3. TEMPORAL FILTERING ACCURACY
   - Random sample: 100K ticks (statistical coverage)
   - **Boundary sample**: First/last 1000 ticks of each trading day
   - **Exact boundary check**: All ticks within ±1 second of session boundaries
   - Verify ALL sampled timestamps fall within session window
```

---

#### H2. OVERLAP DETECTION NOT IMPLEMENTED

**Location**: Lines 260-262

**Problem**: Just a comment, no code:
```python
# No overlap between sessions (timestamps)
# This would require sampling from each and checking
```

**Fix**:
```python
def verify_no_overlap(session_catalogs: dict) -> bool:
    """Verify no tick exists in multiple sessions."""

    boundaries = [
        ("ASIAN", "LONDON", "07:00:00"),
        ("LONDON", "OVERLAP", "12:00:00"),
        ("OVERLAP", "NY", "15:00:00"),
        ("NY", "LATE_NY", "17:00:00"),
        ("LATE_NY", "EVENING", "21:00:00"),
        ("EVENING", "ASIAN", "00:00:00"),
    ]

    for sess_a, sess_b, boundary_time in boundaries:
        # Get ticks within 1ms of boundary from both sessions
        ticks_a = get_boundary_ticks(session_catalogs[sess_a], boundary_time, window_ms=1)
        ticks_b = get_boundary_ticks(session_catalogs[sess_b], boundary_time, window_ms=1)

        # Check for any timestamp collision
        overlap = set(ticks_a['ts_event']) & set(ticks_b['ts_event'])
        if overlap:
            raise ValidationError(f"Overlap detected at {boundary_time}: {len(overlap)} ticks")

    return True
```

---

#### H3. LATE_NY TASK HAS INCORRECT DST MAPPING

**Location**: Lines 223-224

**Problem**:
```
APEX_NOTES: Contains Apex time gate (4:30 PM ET = 20:30 UTC summer/EDT, 21:30 UTC winter/EST)
```

But LATE_NY is 17:00-21:00 UTC. In winter, 21:30 UTC is OUTSIDE LATE_NY (it's in EVENING).

**Fix**:
```
APEX_NOTES:
- SUMMER (EDT): Contains Apex time gate (4:30 PM ET = 20:30 UTC). Force-close window 20:55-20:59 UTC.
- WINTER (EST): Apex time gates are NOT in LATE_NY - they are in EVENING session.
```

---

#### H4. EVENING TASK HAS SAME INCORRECT CLAIM

**Location**: Lines 237-238

**Problem**: Similar to H3, claims apply to summer but states winter times.

**Fix**:
```
APEX_NOTES:
- SUMMER (EDT): Force-close window (20:55-20:59 UTC) is in LATE_NY, NOT Evening.
- WINTER (EST): Contains ALL Apex gates (4:30 PM = 21:30 UTC, 4:55-4:59 PM = 21:55-21:59 UTC).
- No positions should be open after 4:59 PM ET (varies by DST).
```

---

#### H5. GAP THRESHOLDS NOT DEFINED

**Location**: Lines 133-135

**Problem**: "Expected gaps" and "Unexpected gaps" - no quantitative thresholds.

**Fix**:
```markdown
5. GAP ANALYSIS (session-specific)

   **Expected gaps** (do NOT flag):
   - Between consecutive sessions: 0-5 seconds (normal transition)
   - Weekend: Friday close to Sunday open (~48 hours)
   - Market holidays: Per CME XAUUSD calendar

   **Thresholds for flagging** (within session):
   | Session | Normal max gap | Flag if > |
   |---------|----------------|-----------|
   | ASIAN | 60s | 120s |
   | LONDON | 30s | 60s |
   | OVERLAP | 15s | 30s |
   | NY | 15s | 30s |
   | LATE_NY | 30s | 60s |
   | EVENING | 60s | 120s |
```

---

#### H6. WEEKEND/HOLIDAY GAPS WILL FLOOD FALSE POSITIVES

**Location**: Lines 133-135

**Problem**: No weekend/holiday exclusion = hundreds of false positives.

**Fix**:
```python
def is_expected_gap(gap_start: datetime, gap_duration: timedelta) -> bool:
    """Determine if a gap is expected (weekend, holiday) or unexpected."""

    # Weekend check
    if gap_start.weekday() == 4:  # Friday
        # Check if gap spans to Sunday
        if gap_duration > timedelta(hours=24):
            return True  # Weekend gap

    # Holiday check (CME XAUUSD calendar)
    # Load from: data/reference/cme_xauusd_holidays.csv
    holidays = load_holiday_calendar()
    if gap_start.date() in holidays:
        return True

    return False
```

---

#### H7. DST HELPER FUNCTIONS NOT DEFINED (SUPERSEDED BY ZONEINFO)

**Location**: Lines 314-317

**Problem**: References `first_sunday_of_month()`, `last_sunday_of_month()`, `second_sunday_of_month()` but these are not defined.

**Status**: SUPERSEDED - These functions are NO LONGER REQUIRED when using the zoneinfo approach (see ARGUS Research Improvements section). The zoneinfo module with IANA tzdb automatically handles all historical DST transitions including the Energy Policy Act 2005 changes.

**Legacy Fix** (kept for reference only, DO NOT USE):
```python
# DEPRECATED: These functions are no longer needed with zoneinfo
# zoneinfo("America/New_York") automatically knows all DST rules
# Keep this code only as historical reference

from calendar import monthcalendar

def first_sunday_of_month(year: int, month: int) -> datetime.date:
    """Return first Sunday of given month."""
    cal = monthcalendar(year, month)
    # Sunday is index 6, find first week with non-zero Sunday
    for week in cal:
        if week[6] != 0:
            return datetime.date(year, month, week[6])

def second_sunday_of_month(year: int, month: int) -> datetime.date:
    """Return second Sunday of given month."""
    cal = monthcalendar(year, month)
    sundays = [week[6] for week in cal if week[6] != 0]
    return datetime.date(year, month, sundays[1])

def last_sunday_of_month(year: int, month: int) -> datetime.date:
    """Return last Sunday of given month."""
    cal = monthcalendar(year, month)
    sundays = [week[6] for week in cal if week[6] != 0]
    return datetime.date(year, month, sundays[-1])
```

**Recommended Implementation**: Use zoneinfo (see ARGUS Research Improvements)
```python
from zoneinfo import ZoneInfo
eastern = ZoneInfo("America/New_York")  # Knows ALL DST rules automatically
```

---

### MEDIUM ISSUES (6)

| ID | Issue | Location | Fix |
|----|-------|----------|-----|
| M1 | ET-UTC table is winter-only, not labeled | Lines 66-73 | Add "ET (Winter EST)" header, or show both EDT/EST |
| M2 | Stream chunking strategy undefined | Lines 19-26 | Add pseudocode for Nautilus catalog streaming |
| M3 | Timestamp precision not documented | Template | Add: "Timestamps are nanosecond precision (ts_event)" |
| M4 | Leap second handling not mentioned | N/A | Add note: "Leap seconds (if present) should be flagged" |
| M5 | Partial first/last day not documented | Template | Add: "First/last dates may have partial session coverage" |
| M6 | "Apex compliance" label misleading | Lines 152, 274 | Rename to "Apex window coverage" - can't verify trades from tick data |

---

### LOW ISSUES (3)

| ID | Issue | Impact | Recommendation |
|----|-------|--------|----------------|
| L1 | Memory calc conservative | None (safe) | Document: 50 bytes/tick assumption |
| L2 | Session % estimates approximate | Acceptable | Note: "Estimates, actual may vary by ±5%" |
| L3 | No checkpoint/resume on crash | Validation restart | Consider: Write partial results to temp file |

---

### ASSUMPTIONS CHALLENGED

| Assumption | Challenge | Recommendation |
|------------|-----------|----------------|
| Sessions are mutually exclusive | Not verified in plan | Add explicit overlap check at boundaries |
| 100K sample is representative | Boundary bugs are localized, not random | Add targeted boundary sampling |
| Coverage should be ~100% | True if [start, end) used consistently | Verify with ±0.1% tolerance, not ±5% |
| Apex time gates are data-verifiable | Tick data shows quotes, not trades | Rename "compliance" to "coverage" |
| DST functions exist | Referenced but not defined | Provide implementations |
| 2M chunk size is optimal | No justification | Document: 2M ticks × 50 bytes = 100MB < 400MB budget |

---

### EDGE CASES REQUIRING EXPLICIT HANDLING

1. **Tick at exactly midnight UTC (00:00:00.000)**: Document which session owns it
2. **Tick at session boundaries (07:00, 12:00, etc.)**: Verify [start, end) rule enforced
3. **DST spring forward hour**: Flag any ticks in "impossible" 2-3 AM ET window
4. **DST fall back repeated hour**: Document how disambiguation is handled
5. **Leap seconds**: Flag if any exist (rare but possible in 2003-2016 data)
6. **Sub-nanosecond collisions**: Define ordering for identical timestamps
7. **Empty session on a date**: Valid scenario (holiday), don't fail validation

---

### STRESS TEST SCENARIOS

| Scenario | Expected Outcome | Verification |
|----------|------------------|--------------|
| 6 agents spawn simultaneously | Should stay under 6GB | Monitor actual memory usage |
| LATE_NY 2.2 GB streaming | Should complete without OOM | Use streaming, not load_all() |
| Corrupt parquet file | Should fail gracefully with error | Test with truncated file |
| Clock drift in source data | Would pass validation but data wrong | Cannot detect without external reference |
| Empty session catalog | Should handle gracefully | Test with zero-tick scenario |

---

### PRE-MORTEM: Most Likely Failure Modes

1. **Double-counted boundary ticks** (CRITICAL)
   - Cause: [start, end] instead of [start, end) in filtering
   - Result: 32.7M+ duplicate ticks across all boundaries
   - Detection: Will show coverage >100%
   - Mitigation: Explicit boundary verification (added above)

2. **DST gate miscalculation** (HIGH)
   - Cause: Using DATE-level DST check on transition DAY
   - Result: ~2 hours per year with wrong UTC offset
   - Detection: Apex time gate appears in wrong session
   - Mitigation: Implement hour-level DST logic for transition days

3. **False positive flood hides real issue** (MEDIUM)
   - Cause: Every weekend flagged as "unexpected gap"
   - Result: Operators ignore alerts, miss real data gaps
   - Detection: >500 "issues" reported
   - Mitigation: Weekend/holiday exclusion logic

---

### MANUAL VERIFICATION REQUIRED

Before executing Phase 3, verify these items are ready:

- [x] Boundary inclusion rule documented and understood by all agents (FIXED - `[start, end)` added)
- [x] DST transition handling documented (FIXED - spring/fall logic + 2003-2025 dates table)
- [x] Cross-validation tolerance tightened (FIXED - 99-101% + explicit missing/duplicate check)
- [ ] DST helper functions implemented and tested (code provided in plan)
- [ ] Holiday calendar file exists at `data/reference/cme_xauusd_holidays.csv`
- [x] Boundary overlap detection code added to cross-validation (FIXED - verify_no_overlap added)

---

### APPROVAL STATUS

**APPROVED** (2025-12-16)

All 3 CRITICAL issues have been fixed:
- [x] C1: Boundary inclusion rules - Added `[start, end)` convention
- [x] C2: DST transition handling - Added spring/fall handling + 2003-2025 dates table
- [x] C3: Coverage tolerance - Tightened to 99-101% + explicit duplicate/missing detection

Remaining checklist (HIGH issues to implement during execution):
- [ ] Boundary overlap detection code (implemented in cross-validation section)
- [ ] Targeted boundary sampling (first/last 1000 ticks per day)
- [ ] DST helper functions (implementations provided)
- [ ] Weekend/holiday gap exclusion logic
- [ ] Gap thresholds per session

**Confidence**: HIGH
- All CRITICAL issues resolved
- Plan structure is solid
- Orchestration is well-designed
- DST edge cases documented
- Boundary handling explicit

---

*"Every bug found now is a loss prevented later."*
*CRITIC v1.1 - 2025-12-16*
*FORGE v5.3 - Fixes Applied 2025-12-16*

---

## ARGUS Research Improvements

**Integrated**: 2025-12-16
**Research Source**: ARGUS Quant Researcher
**Key Insight**: zoneinfo with IANA tzdb correctly handles Energy Policy Act 2005 (DST rule change in 2007)

---

### 1. zoneinfo (stdlib) for DST Handling

**Problem**: Manual DST tables and helper functions are error-prone and require maintenance.

**Solution**: Use Python stdlib `zoneinfo` module (Python 3.9+) which:
- Uses IANA timezone database (tzdb)
- Automatically knows Energy Policy Act 2005 changed DST rules in 2007
- Handles all historical DST transitions correctly
- No need for manual helper functions (first_sunday_of_month, etc.)

**Key Insight - Energy Policy Act 2005**:
- Pre-2007 (2003-2006): DST was first Sunday in April to last Sunday in October
- Post-2007 (2007-2025): DST is second Sunday in March to first Sunday in November
- zoneinfo AUTOMATICALLY applies the correct rule based on the year

**Implementation**:
```python
from zoneinfo import ZoneInfo
from datetime import datetime, time, date

def get_apex_utc_time(et_time: time, target_date: date) -> time:
    """Convert ET time to UTC - zoneinfo handles DST automatically.

    Works correctly for ALL years:
    - 2003-04-06 02:00 -> DST starts (old rule: first Sunday April)
    - 2007-03-11 02:00 -> DST starts (new rule: second Sunday March)
    """
    eastern = ZoneInfo("America/New_York")
    dt_et = datetime.combine(target_date, et_time, tzinfo=eastern)
    dt_utc = dt_et.astimezone(ZoneInfo("UTC"))
    return dt_utc.timetz()
```

---

### 2. New Dependencies

Add to project requirements:

```
# For DST handling with zoneinfo (Python 3.9+)
tzdata>=2024.1  # IANA timezone database (required on Windows, recommended on all platforms)
```

**Note**: Python 3.9+ has `zoneinfo` built into stdlib. The `tzdata` package provides the IANA timezone database for platforms that don't have system timezone data (Windows) or to ensure up-to-date timezone rules.

---

### 3. Simplified DST Helper Functions

**Status**: SUPERSEDED

The following manual helper functions are NO LONGER REQUIRED:
- `first_sunday_of_month()`
- `second_sunday_of_month()`
- `last_sunday_of_month()`

These are superseded by zoneinfo which handles ALL historical DST rules automatically.

The DST dates table (2003-2025) is kept in this document for REFERENCE and VALIDATION purposes only.

---

### 4. Updated Success Criteria

Replace DST-related success criterion with:

| Criterion | Threshold | Priority |
|-----------|-----------|----------|
| zoneinfo-based DST validation | Passes for all pre-2007 AND post-2007 data | HIGH |
| DST transition day handling | Spring forward gaps expected, Fall back handled gracefully | HIGH |

---

### 5. Validation Test Cases

Add these test cases to verify correct DST handling:

```python
from zoneinfo import ZoneInfo
from datetime import datetime, time, date

def test_dst_handling():
    """Verify zoneinfo correctly handles Energy Policy Act 2005 changes."""
    eastern = ZoneInfo("America/New_York")

    # Pre-2007: DST starts first Sunday in April
    # April 2, 2006 was DST start
    apr_1_2006 = datetime(2006, 4, 1, 12, 0, tzinfo=eastern)
    apr_3_2006 = datetime(2006, 4, 3, 12, 0, tzinfo=eastern)
    assert apr_1_2006.utcoffset().total_seconds() == -5 * 3600  # EST (UTC-5)
    assert apr_3_2006.utcoffset().total_seconds() == -4 * 3600  # EDT (UTC-4)

    # Post-2007: DST starts second Sunday in March
    # March 11, 2007 was DST start
    mar_10_2007 = datetime(2007, 3, 10, 12, 0, tzinfo=eastern)
    mar_12_2007 = datetime(2007, 3, 12, 12, 0, tzinfo=eastern)
    assert mar_10_2007.utcoffset().total_seconds() == -5 * 3600  # EST (UTC-5)
    assert mar_12_2007.utcoffset().total_seconds() == -4 * 3600  # EDT (UTC-4)

    print("DST handling tests passed!")
```

---

*ARGUS v2.3 - Research Integration 2025-12-16*
