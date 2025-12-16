# Phase 3: Session Catalog Validation

**Phase ID**: 03
**Status**: ⏳ Pending
**Estimated Agents**: 6 (Full Parallel)
**Execution Mode**: Parallel
**Model**: opus (all agents)

---

## Objective

Validate all 6 session-specific catalogs to ensure they correctly filter the main catalog and maintain data integrity.

---

## Prerequisites

- Phase 2 completed with PASS status
- Main catalog validated successfully

---

## Session Definitions

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

All 6 agents spawn simultaneously:

```
Task[3.1 ASIAN] || Task[3.2 LONDON] || Task[3.3 OVERLAP] || Task[3.4 NY] || Task[3.5 LATE_NY] || Task[3.6 EVENING]
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
   - 4:30 PM ET = 21:30 UTC (summer) / 22:30 UTC (winter)

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
APEX_NOTES: Contains Apex time gate (4:30 PM ET = 21:30 UTC summer)
CRITICAL: Verify time gate boundary handling
```

---

### Task 3.6: EVENING Session

**Agent**: ORACLE | **Model**: opus

```
SESSION: EVENING
START_UTC: 21:00
END_UTC: 00:00
APEX_NOTES: Contains Apex force-close (4:55-4:59 PM ET = 21:55-21:59 UTC summer)
CRITICAL: No positions should be open after 4:59 PM ET
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

# Sessions should account for ~100% of main (with tolerance)
coverage_ratio = total_session_ticks / main_catalog_ticks
assert 0.95 <= coverage_ratio <= 1.05, f"Session coverage mismatch: {coverage_ratio}"

# No overlap between sessions (timestamps)
# This would require sampling from each and checking
```

---

## Success Criteria

| Criterion | Threshold | Priority |
|-----------|-----------|----------|
| All catalogs exist | 6/6 | CRITICAL |
| Temporal accuracy | 100% (all ticks in window) | CRITICAL |
| Crossed quotes | 0 per session | CRITICAL |
| Combined coverage | 95-105% of main | HIGH |
| Apex time gates | Correctly bounded | HIGH |
| Within-session gaps | Documented | MEDIUM |

---

## Deliverables

1. **6 JSON reports** in `DOCS/03_RESEARCH/FINDINGS/PHASE3_SESSION_*.json`
2. **SESSION_VALIDATION_REPORT.md** - Consolidated summary with cross-validation

---

## Apex Time Gate Mapping

For LATE_NY and EVENING sessions, critical Apex time gates:

| Apex Rule | ET Time | UTC (Summer) | UTC (Winter) |
|-----------|---------|--------------|--------------|
| Block new trades | 4:30 PM | 20:30 | 21:30 |
| Emergency close start | 4:55 PM | 20:55 | 21:55 |
| Force close deadline | 4:59 PM | 20:59 | 21:59 |

---

## Next Phase

After completion, proceed to [Phase 4: Integrity & Cleanup](./04-PHASE-PLAN.md)
