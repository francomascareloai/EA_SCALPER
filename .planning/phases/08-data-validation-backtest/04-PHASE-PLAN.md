# Phase 4: Integrity & Cleanup

**Phase ID**: 04
**Status**: ⏳ Pending
**Estimated Agents**: 3 (Full Parallel)
**Execution Mode**: Parallel
**Model**: opus (all agents)

---

## Objective

Ensure cross-catalog consistency, audit metadata completeness, and safely remove redundant data to free storage.

---

## Prerequisites

- Phase 2 completed (main catalog validated)
- Phase 3 completed (session catalogs validated)

---

## Orchestration

### Agent Spawn Pattern

All 3 agents spawn simultaneously:

```
Task[4.1 Cross-Catalog] || Task[4.2 Metadata] || Task[4.3 Cleanup]
```

---

## Tasks

### Task 4.1: Cross-Catalog Consistency

**Agent**: ORACLE
**Spec**: `.claude/agents/oracle-backtest-commander.md`
**Model**: opus

**Prompt**:
```
You are ORACLE validating cross-catalog consistency for XAUUSD.

TASK: Verify that session catalogs correctly partition the main catalog.

MAIN CATALOG: data/catalog_native/xauusd_2003_2025_stride1_COMPLETE
SESSION CATALOGS: data/catalog_native_sessions/xauusd_2003_2025_stride1_*/

VALIDATIONS:

1. TICK COUNT RECONCILIATION
   - Sum of all session ticks should equal main catalog ticks (±0.1%)
   - Document any discrepancy

2. NO OVERLAP CHECK
   - Sample timestamps from each session pair
   - Verify no timestamp appears in multiple sessions
   - Edge case: ticks exactly at session boundary

3. NO GAPS CHECK
   - Verify union of sessions covers all main catalog time ranges
   - No missing time windows

4. DATE RANGE CONSISTENCY
   - All catalogs should have same start date (2003-05-05)
   - All catalogs should have same end date (2025-11-28)

5. INSTRUMENT ID CONSISTENCY
   - All catalogs use XAU/USD.SIM

METHODOLOGY:
- Use head+tail sampling (1M ticks from each boundary)
- For overlap check, sample 10K ticks from each session

OUTPUT:
{
  "tick_reconciliation": {
    "main_catalog": <int>,
    "session_sum": <int>,
    "difference": <int>,
    "difference_pct": <float>,
    "status": "PASS/FAIL"
  },
  "overlap_check": {
    "pairs_tested": <int>,
    "overlaps_found": <int>,
    "status": "PASS/FAIL"
  },
  "gap_check": {
    "covered_ranges": [...],
    "uncovered_ranges": [...],
    "status": "PASS/FAIL"
  },
  "date_consistency": {
    "all_same_start": true/false,
    "all_same_end": true/false,
    "status": "PASS/FAIL"
  }
}

FILE: DOCS/03_RESEARCH/FINDINGS/PHASE4_CROSS_CATALOG_CONSISTENCY.json

Apply CRITIC self-review before reporting done.
```

---

### Task 4.2: Metadata Completeness

**Agent**: ORACLE
**Spec**: `.claude/agents/oracle-backtest-commander.md`
**Model**: opus

**Prompt**:
```
You are ORACLE auditing metadata completeness for all XAUUSD catalogs.

TASK: Ensure all catalogs have complete and accurate metadata.

CATALOGS TO AUDIT:
- data/catalog_native/xauusd_2003_2025_stride1_COMPLETE/
- data/catalog_native_sessions/xauusd_2003_2025_stride1_*/

METADATA FILES TO CHECK:

1. .checkpoint.json (per catalog)
   - Exists
   - Valid JSON
   - Contains: rows_processed, ticks_written, completed_at
   - ticks_written matches actual parquet row count

2. Parquet Metadata
   - Each parquet file has valid row group metadata
   - Schema consistent across files

3. config.yaml Integration
   - Catalog paths correctly referenced
   - Fallback paths valid

GENERATE IF MISSING:
- Document which metadata files need to be created
- Propose metadata content based on actual data

OUTPUT:
{
  "catalogs_audited": <int>,
  "checkpoints_found": <int>,
  "checkpoints_valid": <int>,
  "checkpoints_missing": [...],
  "parquet_metadata_valid": true/false,
  "config_integration": "PASS/FAIL",
  "proposed_fixes": [...]
}

FILE: DOCS/03_RESEARCH/FINDINGS/PHASE4_METADATA_AUDIT.json

Apply CRITIC self-review before reporting done.
```

---

### Task 4.3: Redundant Data Cleanup

**Agent**: FORGE
**Spec**: `.claude/agents/forge-nautilus.md`
**Model**: opus

**Prompt**:
```
You are FORGE executing safe cleanup of redundant data.

TASK: Remove redundant data files after validation confirms they are unnecessary.

REDUNDANT DATA IDENTIFIED (from DB_OPTIMIZATION_REPORT):
1. Session CSVs: data/session_csvs/ (~14 GB)
   - These are source files already converted to Nautilus catalogs
   - SAFE TO DELETE after validation

2. Incomplete catalogs (pending validation):
   - data/catalog_native/xauusd_2003_2025_stride20_full_INCOMPLETE/
   - Only delete if truly incomplete and superseded

3. Old catalog versions (pending validation):
   - data/catalog_native/xauusd_2003_2025_stride1_full/
   - Only delete if stride1_COMPLETE is validated

SAFETY PROTOCOL:
1. DO NOT delete anything until Phase 2 and 3 are PASS
2. Create backup manifest before deletion
3. Use git to track file list (not contents)
4. Dry-run first, then execute

COMMANDS:
```bash
# 1. Create manifest of files to delete
find data/session_csvs/ -type f > cleanup_manifest.txt

# 2. Calculate space to recover
du -sh data/session_csvs/

# 3. Verify main catalog is validated (check Phase 2 report)
cat DOCS/03_RESEARCH/FINDINGS/PHASE2_QUALITY_SCORE.json | jq '.status'

# 4. DRY RUN - list what would be deleted
echo "Would delete:"
cat cleanup_manifest.txt | head -20
echo "... and $(wc -l < cleanup_manifest.txt) more files"

# 5. EXECUTE (only if phases passed)
rm -rf data/session_csvs/
```

PRE-CONDITIONS (all must be true):
- Phase 2 quality score >= 70
- Phase 3 all sessions PASS
- Phase 4.1 cross-catalog PASS

OUTPUT:
{
  "files_deleted": <int>,
  "space_recovered_gb": <float>,
  "backup_manifest": "cleanup_manifest.txt",
  "pre_conditions_met": true/false,
  "execution_status": "DRY_RUN/EXECUTED/SKIPPED"
}

FILE: DOCS/03_RESEARCH/FINDINGS/PHASE4_CLEANUP_REPORT.json

Apply CRITIC self-review before reporting done.
```

---

## Cleanup Decision Matrix

| Data Type | Size | Delete If | Keep If |
|-----------|------|-----------|---------|
| session_csvs/ | 14 GB | Catalogs validated | Catalogs fail |
| stride20_INCOMPLETE | ~500 MB | Truly incomplete | Contains unique data |
| stride1_full (old) | ~13 GB | stride1_COMPLETE valid | COMPLETE has issues |

---

## Success Criteria

| Criterion | Threshold | Priority |
|-----------|-----------|----------|
| Tick reconciliation | ≤0.1% difference | CRITICAL |
| No overlaps | 0 overlapping timestamps | CRITICAL |
| No gaps | 100% coverage | HIGH |
| Metadata complete | All checkpoints valid | MEDIUM |
| Cleanup safe | Pre-conditions met | HIGH |

---

## Deliverables

1. **PHASE4_CROSS_CATALOG_CONSISTENCY.json**
2. **PHASE4_METADATA_AUDIT.json**
3. **PHASE4_CLEANUP_REPORT.json**
4. **cleanup_manifest.txt** - Deleted files record
5. **INTEGRITY_CLEANUP_REPORT.md** - Consolidated summary

---

## Storage Recovery Estimate

| Action | Space Freed |
|--------|-------------|
| Delete session_csvs/ | 14 GB |
| Delete stride20_INCOMPLETE | 0.5 GB |
| Keep stride1_full (backup) | 0 GB |
| **Total** | **~14.5 GB** |

---

## Next Phase

After completion, proceed to [Phase 5: Advanced Validation](./05-PHASE-PLAN.md)
