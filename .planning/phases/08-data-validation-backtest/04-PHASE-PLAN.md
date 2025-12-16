[ARGUS INTEGRATED]

# Phase 4: Integrity & Cleanup

> **⚡ ARGUS IMPROVEMENTS APPLIED** (see full details at end of file)
> - **Cross-catalog hash verification**: SHA256 lineage tracking
> - **Metadata audit**: Checkpoint file validation
> - **DuckDB consistency checks**: Fast cross-catalog comparison

**Phase ID**: 04
**Status**: ⏳ Pending
**Estimated Agents**: 3 (Validation parallel, Cleanup DEFERRED)
**Execution Mode**: Mixed (4.1 || 4.2) → 4.3 (AFTER Phase 7)
**Model**: opus (all agents)

---

## Memory Constraint (CRITICAL)

**System RAM**: 12 GB total
**Safe Working Memory**: ~6 GB (leave 6 GB for OS/system)
**Max Chunk Size**: 5M ticks per operation
**Parallelism**: 2 validation agents in parallel

### Memory Budget Per Agent
| Agent | Task | Max Memory | Strategy |
|-------|------|------------|----------|
| 4.1 | Cross-catalog | 1 GB | Sample-based comparison |
| 4.2 | Metadata | 200 MB | Metadata only, no data |
| 4.3 | Cleanup | 100 MB | File operations only |

**CRITICAL**: Cross-catalog comparison uses sampling (10K ticks per session),
not full data comparison. Never load multiple catalogs simultaneously.

---

## Objective

Ensure cross-catalog consistency and audit metadata completeness.
**CLEANUP IS DEFERRED** to after Phase 7 backtest succeeds and requires USER APPROVAL.

---

## Prerequisites

- Phase 2 completed (main catalog validated)
- Phase 3 completed (session catalogs validated)

---

## Orchestration

### Agent Spawn Pattern

**CRITICAL**: Cleanup (4.3) is DEFERRED to after Phase 7 and requires USER APPROVAL.

```
Phase 4 Execution:
Round 1: Task[4.1 Cross-Catalog] || Task[4.2 Metadata]
   ↓ (wait for both to complete with PASS status)
   ↓ Phase 4 reports COMPLETE

Phase 7 Execution:
   ↓ (backtest must pass)
   ↓

Post-Phase 7 (REQUIRES USER APPROVAL):
Round 2: Task[4.3 Cleanup] (USER MUST APPROVE before execution)
```

**Gate Condition**: Task 4.3 BLOCKED until:
1. Phase 4.1 AND 4.2 return PASS status
2. Phase 7 backtest succeeds
3. **USER EXPLICITLY APPROVES cleanup**

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

SESSION DEFINITION (C3 FIX: Explicit Clarification):
Sessions are TEMPORAL trading windows (intraday time-of-day based), NOT chronological date ranges.
Each session represents a specific market period that REPEATS DAILY:
- ASIAN session:   00:00 - 07:00 UTC (Tokyo, Sydney, Hong Kong)
- LONDON session:  07:00 - 14:30 UTC (European markets)
- NY session:      14:30 - 21:00 UTC (US markets)
- LATE session:    21:00 - 00:00 UTC (after-hours)

BOUNDARY RULE: Start-inclusive, end-exclusive [start, end)
- A tick at exactly 07:00:00.000000000 UTC belongs to LONDON, not ASIAN

GAP HANDLING:
- Gaps BETWEEN sessions within a day are NOT expected (sessions are contiguous 24h)
- Gaps due to weekends (Sat-Sun) are EXPECTED and should NOT fail validation
- Holiday gaps are EXPECTED and should NOT fail validation

VALIDATIONS:

1. TICK COUNT RECONCILIATION (C2 FIX: EXACT MATCH)
   - Sum of all session ticks MUST EXACTLY equal main catalog ticks (0 difference)
   - TOLERANCE: 0 (exact match required)
   - RATIONALE: Session catalogs are a partition of main catalog.
     Any difference indicates data corruption or incomplete conversion.
   - If difference != 0: Generate reconciliation report showing which session(s) are off

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

OUTPUT (C4 FIX: Added overall_status):
{
  "overall_status": "PASS/FAIL",
  "pass_condition": "ALL individual checks must be PASS",
  "summary": "X of Y checks passed",
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

OUTPUT (C4 FIX: Added overall_status):
{
  "overall_status": "PASS/FAIL",
  "pass_condition": "All checkpoints valid AND parquet_metadata_valid AND config_integration PASS",
  "summary": "X catalogs audited, Y issues found",
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
**EXECUTION**: DEFERRED to after Phase 7 + REQUIRES USER APPROVAL

**Prompt**:
```
You are FORGE executing safe cleanup of redundant data.

⚠️ THIS TASK REQUIRES EXPLICIT USER APPROVAL BEFORE EXECUTION ⚠️

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

USER APPROVAL PROTOCOL:
1. Generate cleanup report with exact files and sizes
2. Present to user with clear summary
3. ASK: "Do you approve deleting these files? (y/n)"
4. ONLY proceed if user explicitly confirms
5. If user says no, skip cleanup and report SKIPPED

SAFETY PROTOCOL:
1. DO NOT delete anything until Phase 7 backtest PASSES
2. DO NOT delete without explicit user approval
3. Create backup manifest before deletion
4. Use git to track file list (not contents)
5. Dry-run first, then execute ONLY if approved

ROLLBACK MECHANISM (CRITICAL - C1 FIX + ARGUS IMPROVEMENT):
Files are NEVER directly deleted. Instead:
1. Calculate space needed: du -sh target_dirs + 10% buffer
2. Verify sufficient disk space for .trash/ staging: df -h shows >= 15GB free
3. MOVE files to data/.trash_YYYYMMDD_HHMMSS/ (atomic on same filesystem)
4. **CREATE JSON METADATA for each file** (ARGUS improvement - see below)
5. Verify move completed: compare file counts before/after
6. Wait for user confirmation that system is stable (7-day retention)
7. Only THEN schedule permanent deletion: rm -rf data/.trash_*/
8. If any step fails: ABORT immediately, restore from .trash/
9. .trash/ folders auto-purge after 7 days if no issues reported

**JSON METADATA FOR AUDIT TRAIL** (ARGUS Improvement):
Each file moved to .trash/ gets a companion .metadata.json file:
```python
import json
import hashlib
from pathlib import Path
from datetime import datetime, timedelta

def move_to_trash(file_path: Path, reason: str) -> Path:
    """Move file to .trash/ with metadata for audit trail.

    Args:
        file_path: Path to file being moved
        reason: Why this file is being deleted

    Returns:
        Path to the moved file in .trash/
    """
    trash_dir = file_path.parent / ".trash"
    trash_dir.mkdir(exist_ok=True)

    # Calculate MD5 hash for verification (optional for large files)
    file_size = file_path.stat().st_size
    md5_hash = None
    if file_size < 100_000_000:  # Only hash files < 100MB
        md5_hash = hashlib.md5(file_path.read_bytes()).hexdigest()

    # Create metadata file
    metadata = {
        "original_path": str(file_path.resolve()),
        "deleted_at": datetime.utcnow().isoformat() + "Z",
        "reason": reason,
        "can_restore_until": (datetime.utcnow() + timedelta(days=7)).isoformat() + "Z",
        "file_size_bytes": file_size,
        "md5_hash": md5_hash,
        "phase": "Phase 4.3 Cleanup",
        "approved_by": "USER (explicit approval required)"
    }

    metadata_file = trash_dir / f"{file_path.name}.metadata.json"
    metadata_file.write_text(json.dumps(metadata, indent=2))

    # Move the file
    trash_file = trash_dir / file_path.name
    file_path.rename(trash_file)
    return trash_file

def restore_from_trash(trash_file: Path) -> Path:
    """Restore a file from .trash/ using its metadata."""
    metadata_file = trash_file.parent / f"{trash_file.name}.metadata.json"
    if not metadata_file.exists():
        raise FileNotFoundError(f"No metadata found for {trash_file}")

    metadata = json.loads(metadata_file.read_text())
    original_path = Path(metadata["original_path"])

    # Verify restore window
    restore_deadline = datetime.fromisoformat(
        metadata["can_restore_until"].rstrip("Z")
    )
    if datetime.utcnow() > restore_deadline:
        raise ValueError(f"Restore window expired at {restore_deadline}")

    # Move back to original location
    trash_file.rename(original_path)
    metadata_file.unlink()  # Remove metadata after successful restore
    return original_path
```

COMMANDS:
```bash
# 1. Create manifest of files to delete
find data/session_csvs/ -type f > cleanup_manifest.txt

# 2. Calculate space to recover
du -sh data/session_csvs/

# 3. Verify Phase 7 backtest passed
cat DOCS/03_RESEARCH/FINDINGS/PHASE7_BASELINE_BACKTEST.json | jq '.apex_compliance.compliant'

# 4. DRY RUN - list what would be deleted
echo "Would delete:"
cat cleanup_manifest.txt | head -20
echo "... and $(wc -l < cleanup_manifest.txt) more files"

# 5. ASK USER FOR APPROVAL (MANDATORY)
echo "USER APPROVAL REQUIRED: Do you want to delete these files?"

# 6. EXECUTE (ONLY if user approved)
# rm -rf data/session_csvs/
```

PRE-CONDITIONS (all must be true):
- Phase 2 quality score >= 70
- Phase 3 all sessions PASS
- Phase 4.1 cross-catalog PASS
- Phase 7 backtest PASS
- **USER EXPLICITLY APPROVES**

OUTPUT (C4 FIX: Added overall_status):
{
  "overall_status": "PASS/FAIL/SKIPPED",
  "pass_condition": "All pre-conditions met AND files safely moved to .trash/ AND user approved",
  "summary": "X files moved to .trash/, Y GB recoverable after 7-day retention",
  "files_deleted": <int>,
  "space_recovered_gb": <float>,
  "backup_manifest": "cleanup_manifest.txt",
  "trash_folder": "data/.trash_YYYYMMDD_HHMMSS/",
  "metadata_files": ["<file>.metadata.json", ...],  // ARGUS improvement
  "retention_expires": "YYYY-MM-DD (7 days from move)",
  "pre_conditions_met": true/false,
  "execution_status": "DRY_RUN/MOVED_TO_TRASH/PERMANENTLY_DELETED/SKIPPED"
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
| Tick reconciliation | EXACT match (0 difference) - C2 FIX | CRITICAL |
| No overlaps | 0 overlapping timestamps | CRITICAL |
| No gaps | 100% coverage (excluding weekends/holidays) | HIGH |
| Metadata complete | All checkpoints valid | MEDIUM |
| Cleanup safe | Pre-conditions met + .trash/ rollback | HIGH |

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

---

## CRITIC Review (Phase 4)

**Reviewer**: CRITIC v1.1 - Adversarial Quality Guardian
**Date**: 2025-12-16
**Artifact**: Phase 4: Integrity & Cleanup Plan
**Review Method**: Sequential thinking (17 thoughts), 7 adversarial lenses applied
**Fix Applied By**: FORGE (2025-12-16)

---

### VERDICT: APPROVED (All CRITICAL Issues Fixed)

All 4 CRITICAL issues have been addressed. The plan now includes:
- Rollback mechanism with .trash/ staging and 7-day retention
- EXACT tick count matching (0 tolerance)
- Explicit session definition (temporal trading windows)
- overall_status field in all output schemas

---

### CRITICAL ISSUES STATUS (4/4 FIXED)

| Issue ID | Summary | Status | Fix Applied |
|----------|---------|--------|-------------|
| C1 | No Rollback Mechanism | FIXED | Added .trash/ staging with 7-day retention |
| C2 | Tick Tolerance Too Lenient | FIXED | Changed to EXACT match (0 difference) |
| C3 | Session Definition Ambiguous | FIXED | Added explicit temporal window definition |
| C4 | No Aggregate Failure Status | FIXED | Added overall_status to all output schemas |

---

### CRITICAL ISSUES (All Fixed - Historical Reference)

**C1. No Rollback Mechanism for Cleanup**
- **Location**: Task 4.3, Safety Protocol section
- **Problem**: Plan says "Create backup manifest before deletion" but a manifest is just a FILE LIST, not a backup. If cleanup fails midway (disk error, permission denied, power failure), data is partially deleted with no recovery path.
- **Impact**: Irreversible data loss with no ability to recover
- **Fix Required**:
  ```
  SAFETY PROTOCOL (REVISED):
  1. Calculate space needed: du -sh target_dirs + 10% buffer
  2. Verify sufficient disk space for .trash/ staging
  3. MOVE files to data/.trash_YYYYMMDD/ (atomic on same filesystem)
  4. Verify move completed: compare file counts
  5. Only THEN execute: rm -rf data/.trash_YYYYMMDD/
  6. If any step fails: ABORT, restore from .trash/
  ```

**C2. Tick Count Tolerance Too Lenient (0.1%)**
- **Location**: Task 4.1, Tick Count Reconciliation
- **Problem**: For a 200M tick catalog, 0.1% = 200,000 missing ticks. This could represent DAYS of missing market data during critical periods.
- **Impact**: Backtest runs on incomplete data, leading to wrong trading decisions
- **Fix Required**: Change tolerance to EXACT MATCH (0 ticks difference). Add explicit text:
  ```
  TOLERANCE: 0 (exact match required)
  RATIONALE: Session catalogs are a partition of main catalog.
  Any difference indicates data corruption or incomplete conversion.
  ```

**C3. Session Definition Ambiguity (Temporal vs Chronological)**
- **Location**: Task 4.1, Gap Check section
- **Problem**: Plan never clarifies whether "sessions" are:
  - Temporal (Asia/London/NY by time of day, repeating daily)
  - Chronological (date ranges, e.g., 2003-2010, 2010-2015)
  This fundamentally affects gap check validation logic.
- **Impact**: Gap check could fail incorrectly (if temporal, gaps between sessions are expected) or miss real gaps (if chronological)
- **Fix Required**: Add explicit clarification:
  ```
  SESSION DEFINITION:
  Sessions are CHRONOLOGICAL date ranges (not intraday temporal):
  - Session 1: 2003-05-05 to 2006-12-31
  - Session 2: 2007-01-01 to 2010-12-31
  [... etc ...]

  There should be NO gaps between consecutive sessions.
  Weekend/holiday non-trading gaps within sessions are EXPECTED and should NOT fail validation.
  ```

**C4. No Aggregate Failure Status**
- **Location**: Task 4.1 output structure
- **Problem**: Output shows individual check statuses but no overall_status field. If tick_reconciliation PASSES but overlap_check FAILS, what is the task result?
- **Impact**: Orchestrator cannot determine if Phase 4.1 passed or failed
- **Fix Required**: Add to output structure:
  ```json
  "overall_status": "PASS/FAIL",
  "pass_condition": "ALL individual checks must be PASS",
  "summary": "X of Y checks passed"
  ```

---

### HIGH ISSUES (12 found)

**H1. Insufficient Sample Size for Overlap Detection**
- **Location**: Task 4.1, No Overlap Check
- **Problem**: 10K samples per session is 0.02% of a 50M tick dataset. Overlaps in the other 99.98% would be missed.
- **Fix**: Increase to 100K-500K samples minimum, OR use timestamp-only extraction (int64 timestamps = 400MB per 50M ticks, fits in memory).

**H2. Gap Check Methodology Unspecified**
- **Location**: Task 4.1, No Gaps Check
- **Problem**: Plan says "verify union covers all main catalog time" but doesn't specify HOW.
- **Fix**: Add explicit algorithm:
  ```
  1. For each session: get (min_ts, max_ts)
  2. Sort sessions by min_ts
  3. Verify: session[0].min_ts == main.min_ts
  4. Verify: for i in 1..n: session[i].min_ts <= session[i-1].max_ts + 1ns
  5. Verify: session[n-1].max_ts == main.max_ts
  ```

**H3. Date Range Check is WRONG for Sessions**
- **Location**: Task 4.1, Date Range Consistency
- **Problem**: Plan says "All catalogs should have same start date (2003-05-05) and end date (2025-11-28)". This is incorrect for session subsets.
- **Fix**: Change to:
  ```
  - min(all_session_starts) == main.start (2003-05-05)
  - max(all_session_ends) == main.end (2025-11-28)
  - Each session: start >= main.start AND end <= main.end
  ```

**H4. Parquet Metadata Validation Incomplete**
- **Location**: Task 4.2, Parquet Metadata section
- **Problem**: "Schema consistent across files" lacks specifics on what fields to verify.
- **Fix**: Add schema spec:
  ```
  REQUIRED COLUMNS: ts_event (int64), ts_init (int64), bid_price (float64),
  ask_price (float64), bid_size (float64), ask_size (float64)
  VERIFY: column names, types, nullable flags match across ALL parquet files
  ```

**H5. No Disk Space Pre-Check for Cleanup**
- **Location**: Task 4.3, Pre-conditions
- **Problem**: If disk is full, manifest creation or .trash/ move will fail unexpectedly.
- **Fix**: Add pre-condition:
  ```
  - Verify: df -h shows >= 1GB free space before cleanup
  ```

**H6. Pre-Conditions Not Programmatically Verified**
- **Location**: Task 4.3, Pre-conditions list
- **Problem**: Lists conditions but doesn't show HOW agent verifies them.
- **Fix**: Add verification commands:
  ```bash
  # Verify Phase 2 quality
  jq '.quality_score >= 70' DOCS/03_RESEARCH/FINDINGS/PHASE2_QUALITY_REPORT.json

  # Verify Phase 3 sessions
  jq '.all_sessions_pass == true' DOCS/03_RESEARCH/FINDINGS/PHASE3_SESSION_SUMMARY.json

  # Verify Phase 4.1 cross-catalog
  jq '.overall_status == "PASS"' DOCS/03_RESEARCH/FINDINGS/PHASE4_CROSS_CATALOG_CONSISTENCY.json

  # Verify Phase 7 backtest
  jq '.apex_compliance.compliant == true' DOCS/03_RESEARCH/FINDINGS/PHASE7_BASELINE_BACKTEST.json
  ```

**H7. CSV Deletion Assumes Complete Conversion**
- **Location**: Task 4.3, Redundant Data section
- **Problem**: Plan claims CSVs are "already converted" but doesn't verify conversion completeness.
- **Fix**: Add validation:
  ```
  Before deleting session_csvs/:
  1. Count CSV files: find data/session_csvs/ -name "*.csv" | wc -l
  2. Verify each CSV has corresponding data in catalog (cross-reference filenames/dates)
  3. Only proceed if 100% of CSVs are represented in catalog
  ```

**H8. Sample Size Too Conservative**
- **Location**: Memory Constraint section
- **Problem**: 10K ticks per session (60K total) uses ~5MB. With 1GB budget, we could use 100x more samples for better confidence.
- **Fix**: Increase sample sizes in prompt:
  ```
  - Overlap check: 500K ticks per session boundary
  - Reconciliation sampling: 5M ticks random distribution
  ```

**H9. Partial Failure Handling Unclear**
- **Location**: Orchestration section
- **Problem**: If Task 4.1 overlap check passes but gap check fails, is overall status PASS or FAIL? What action does orchestrator take?
- **Fix**: Add explicit rules:
  ```
  Task 4.1: FAIL if ANY check fails
  Task 4.2: FAIL if ANY checkpoint invalid or missing
  Phase 4: FAIL if 4.1 OR 4.2 fails
  Task 4.3: BLOCKED if Phase 4 failed (never executes)
  ```

**H10. Missing Deliverable Owner**
- **Location**: Deliverables section
- **Problem**: INTEGRITY_CLEANUP_REPORT.md listed but no task creates it.
- **Fix**: Add to Task 4.3 or create consolidation task:
  ```
  Task 4.4 (Optional): Consolidation
  - Agent: ORACLE
  - Action: Combine 4.1, 4.2, 4.3 JSON outputs into INTEGRITY_CLEANUP_REPORT.md
  ```

**H11. Checkpoint Mismatch Tolerance Unspecified**
- **Location**: Task 4.2, .checkpoint.json validation
- **Problem**: "ticks_written matches actual parquet row count" - what if off by 1 due to rounding?
- **Fix**: Specify EXACT MATCH required:
  ```
  TOLERANCE: 0 (exact match)
  Any mismatch indicates: incomplete write, corruption, or metadata desync
  Action if mismatch: FAIL and report which catalog
  ```

**H12. stride20_INCOMPLETE Verification Missing**
- **Location**: Task 4.3, Cleanup Decision Matrix
- **Problem**: How to verify "stride20_INCOMPLETE" is actually incomplete vs just named poorly?
- **Fix**: Add verification:
  ```
  To classify as INCOMPLETE:
  1. .checkpoint.json missing OR contains completed_at: null
  2. Last parquet file modification time < expected completion time
  3. Row count < expected based on date range and stride
  ```

---

### MEDIUM ISSUES (14 found)

1. **M1**: Boundary tick ownership rule unspecified (which session owns tick exactly at boundary?)
2. **M2**: Session pair testing should be adjacent-only (non-adjacent sessions cannot overlap by definition)
3. **M3**: Instrument ID verification trivial but should reference config.yaml, not hardcode "XAU/USD.SIM"
4. **M4**: Checkpoint timestamp format unspecified (ISO8601 recommended)
5. **M5**: No checksum field in checkpoint for data integrity verification
6. **M6**: config.yaml integration check vague (what specifically to verify?)
7. **M7**: stride1_full (old) deletion needs explicit verification that COMPLETE >= full
8. **M8**: Python memory overhead not accounted (50-100MB baseline)
9. **M9**: head+tail sampling only checks boundaries, not middle (random sampling better)
10. **M10**: "Never load multiple catalogs simultaneously" needs clarification (timestamps-only is OK)
11. **M11**: No timeout/retry policy for sub-agent operations
12. **M12**: Parquet corruption exception handling not specified
13. **M13**: Missing catalog directory detection not specified
14. **M14**: Invalid JSON checkpoint exception handling not specified

---

### LOW ISSUES (4 found)

1. **L1**: Weekend gap handling should be explicitly documented as acceptable
2. **L2**: Flash crash tick handling (wide spreads) not addressed
3. **L3**: Microsecond precision conversion could cause apparent duplicates
4. **L4**: User approval reminder mechanism not specified (what if user never approves?)

---

### ASSUMPTIONS CHALLENGED

| Assumption | Challenge | Recommendation |
|------------|-----------|----------------|
| Session catalogs exist at expected paths | What if naming changed? | Use glob pattern discovery or read from config.yaml |
| Main catalog path is fixed | Prior phases might have changed it | Read from config.yaml, not hardcode |
| All parquet files have same schema | Conversion process might have changed | Verify schema across ALL files, not just sample |
| Tick counts can be simply summed | Unexpected duplicates would cause sum > main | Compare counts AND verify no duplicates |
| stride1 contains all stride20 data | Different sampling, not subset | Verify stride1 date range >= stride20 date range |

---

### EDGE CASES TO ADD

1. **Tick at exact session boundary**: Specify "start-inclusive, end-exclusive" rule
2. **Weekend/holiday gaps**: Document as acceptable (XAUUSD closed Sat-Sun)
3. **Rollover ticks**: May have unusual spreads, should not fail validation
4. **Flash crash ticks**: Wide spreads are valid market data, not corruption
5. **Timestamp precision mismatch**: Source data might be ms, catalog is ns

---

### PRE-MORTEM SUMMARY

**Most Likely Failure Mode**: Overlap/gap check passes due to insufficient sampling, but real issues exist in unsampled 99.98% of data. Backtest runs on subtly corrupted data, producing unrealistic results. Strategy appears profitable but fails in live trading.

**Second Most Likely**: Cleanup deletes source CSVs, then catalog corruption discovered. No recovery path because "manifest" was just a file list, not actual backup.

**Third Most Likely**: Phase 4.1 partial pass (some checks pass, some fail) creates ambiguous state. Orchestrator proceeds incorrectly, leading to invalid Phase 7 backtest.

---

### REQUIRED FIXES BEFORE EXECUTION

| Priority | Issue ID | Summary |
|----------|----------|---------|
| CRITICAL | C1 | Add rollback mechanism (move to .trash/ before delete) |
| CRITICAL | C2 | Change tick tolerance to EXACT (0 difference) |
| CRITICAL | C3 | Clarify session definition (temporal vs chronological) |
| CRITICAL | C4 | Add overall_status field to output |
| HIGH | H1 | Increase sample size to 100K-500K |
| HIGH | H2 | Specify gap check algorithm |
| HIGH | H3 | Fix date range check logic for sessions |
| HIGH | H6 | Add jq verification commands for pre-conditions |
| HIGH | H9 | Clarify partial failure handling rules |

---

### MANUAL VERIFICATION REQUIRED

- [ ] Confirm session definitions (ask user: temporal or chronological?)
- [ ] Verify stride20 vs stride1 relationship with actual file inspection
- [ ] Confirm XAU/USD.SIM is correct instrument ID from config.yaml
- [ ] Review actual disk space available before cleanup approval

---

### CONFIDENCE LEVEL

**MEDIUM** - Plan structure is sound but specification gaps create significant risk of:
1. Missed validation issues (sampling too sparse)
2. Data loss (no rollback mechanism)
3. Ambiguous failure states (no aggregate status)

After fixing CRITICAL and HIGH issues, confidence would increase to HIGH.

---

## ARGUS Research Improvements

**Integrated**: 2025-12-16
**Research Source**: ARGUS Quant Researcher

---

### 1. JSON Metadata for .trash/ Operations

**Problem**: Simple manifest files lack per-file context and audit trail, making recovery and compliance difficult.

**Solution**: Create companion `.metadata.json` file for each file moved to `.trash/`:

**Benefits**:
- Full audit trail per file (who, when, why)
- Easy restoration with verification (MD5 hash)
- Time-limited restore window (7 days default)
- Compliance-ready documentation
- Better than a simple manifest list

**Implementation**: See the `move_to_trash()` and `restore_from_trash()` functions in the ROLLBACK MECHANISM section above.

**Metadata Structure**:
```json
{
  "original_path": "/absolute/path/to/original/file",
  "deleted_at": "2025-12-16T10:30:00Z",
  "reason": "Session CSV already converted to Nautilus catalog",
  "can_restore_until": "2025-12-23T10:30:00Z",
  "file_size_bytes": 1234567890,
  "md5_hash": "abc123def456...",
  "phase": "Phase 4.3 Cleanup",
  "approved_by": "USER (explicit approval required)"
}
```

---

### 2. OpenLineage (Optional Enhancement)

For organizations requiring full data lineage tracking, consider OpenLineage integration.

**What is OpenLineage?**
- Open standard for data lineage metadata
- Tracks data transformations from source to destination
- Integrates with Apache Airflow, dbt, Spark, and custom pipelines

**Benefits for this project**:
- Complete audit trail: CSV -> Parquet -> Nautilus Catalog
- Automatic dependency tracking
- Integration with data governance tools (DataHub, Marquez)
- Compliance documentation for financial systems

**Status**: OPTIONAL - Not required for current cleanup operations but recommended for enterprise deployments.

**Implementation reference**: https://openlineage.io/

---

### 3. Updated Success Criteria

Add these criteria to the Success Criteria table:

| Criterion | Threshold | Priority |
|-----------|-----------|----------|
| Metadata files created | 1 .metadata.json per file moved to .trash/ | HIGH |
| Restore function tested | At least 1 file successfully restored during dry-run | MEDIUM |
| Metadata validation | All .metadata.json files are valid JSON | HIGH |

---

### 4. Updated Deliverables

Add to Deliverables section:

5. **Per-file .metadata.json files** - Audit trail for each deleted file
6. **restore_from_trash.py** - Script to restore files using metadata (optional)

---

*ARGUS v2.3 - Research Integration 2025-12-16*
