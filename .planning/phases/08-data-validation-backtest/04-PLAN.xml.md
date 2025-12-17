---
type: plan
description: "Phase 4: Integrity & Cleanup"
phase_id: "04"
status: pending
priority: CRITICAL
model: opus
changelog: "2025-12-17: Added Protocol 0 (Mandatory Delegation)"
---

## ⚠️ MANDATORY DELEGATION (Protocol 0)

> **CRITICAL: The orchestrator MUST NOT read catalog data for cross-validation directly.**
>
> Phase 4 performs cross-catalog checks. Sub-agents handle all file I/O.

### Required Sub-Agent Prompt

```
DELEGATION PROTOCOL (MANDATORY):
1. YOU read catalogs and perform cross-validation - orchestrator has NOT
2. Write COMPLETE analysis to: [output_path]
3. Return ONLY summary (max 300 words) with:
   - Status: PASS/FAIL
   - Consistency metrics (tick reconciliation, overlap checks)
   - Any CRITICAL/HIGH issues found
   - Output file path

Plan: .planning/phases/08-data-validation-backtest/04-PLAN.xml.md
```

---

<objective>
Ensure cross-catalog consistency and audit metadata completeness.
CLEANUP IS DEFERRED to after Phase 7 backtest succeeds and requires USER APPROVAL.

REGRA: USE scripts existentes de scripts/oracle/ e scripts/data/. NÃO crie novos.
Referência: SCRIPT_REGISTRY.md

Key validation:
- Cross-catalog tick count: EXACT MATCH (0 difference)
- No overlaps between sessions
- No gaps in coverage
- Metadata completeness
</objective>

<execution_context>
Memory: 12GB system, 6GB max for validation
Execution: 2 rounds (4.1 || 4.2) then 4.3 DEFERRED to post-Phase 7
Dependencies: duckdb, polars
Scripts: scripts/data/validate_nautilus_catalog.py
Reference: .planning/phases/08-data-validation-backtest/04-PLAN.xml.md
</execution_context>

<context>
- CLAUDE.md for project rules
- SCRIPT_REGISTRY.md for existing scripts
- .claude/agents/oracle-backtest-commander.md for ORACLE agent
- .claude/agents/forge-nautilus.md for FORGE agent
- Phase 2 and 3 completed with PASS status
</context>

<anti_duplication_rule>
ANTES de criar qualquer código:
1. Ler SCRIPT_REGISTRY.md
2. Verificar se funcionalidade existe em scripts/oracle/ ou scripts/data/
3. Se existe: USAR o script existente via CLI ou import
4. Se não existe: PERGUNTAR ao usuário antes de criar
5. NUNCA criar scripts em .planning/ - use scripts/ se necessário
</anti_duplication_rule>

<tasks>
<!-- ROUND 1: Tasks 4.1 and 4.2 in parallel -->
<task id="4.1" type="auto" agent="oracle-backtest-commander" round="1">
<name>Cross-Catalog Consistency</name>
<prompt>
You are ORACLE validating cross-catalog consistency for XAUUSD.

TASK: Verify that session catalogs correctly partition the main catalog.

MAIN CATALOG: data/catalog_native/xauusd_2003_2025_stride1_COMPLETE
SESSION CATALOGS: data/catalog_native_sessions/xauusd_2003_2025_stride1_*/

SESSION DEFINITION:
Sessions are TEMPORAL trading windows (intraday time-of-day based):
- ASIAN:   00:00 - 07:00 UTC
- LONDON:  07:00 - 12:00 UTC
- OVERLAP: 12:00 - 15:00 UTC
- NY:      15:00 - 17:00 UTC
- LATE_NY: 17:00 - 21:00 UTC
- EVENING: 21:00 - 00:00 UTC

BOUNDARY RULE: [start, end) - start inclusive, end exclusive

VALIDATIONS:

1. TICK COUNT RECONCILIATION (EXACT MATCH)
   - Sum of all session ticks MUST EXACTLY equal main catalog ticks (0 difference)
   - TOLERANCE: 0 (exact match required)
   - If difference != 0: Generate reconciliation report

2. NO OVERLAP CHECK
   - Sample timestamps from each session pair
   - Verify no timestamp appears in multiple sessions
   - Check boundary ticks: tick at 07:00:00.000 belongs to LONDON, not ASIAN

3. NO GAPS CHECK
   - Verify union of sessions covers all main catalog time ranges
   - Weekend/holiday gaps are EXPECTED

4. DATE RANGE CONSISTENCY
   - min(all_session_starts) == main.start (2003-05-05)
   - max(all_session_ends) == main.end (2025-11-28)

5. INSTRUMENT ID CONSISTENCY
   - All catalogs use XAU/USD.SIM

OUTPUT JSON:
{
  "overall_status": "PASS/FAIL",
  "pass_condition": "ALL individual checks must be PASS",
  "tick_reconciliation": {..., "status": "PASS/FAIL"},
  "overlap_check": {..., "status": "PASS/FAIL"},
  "gap_check": {..., "status": "PASS/FAIL"},
  "date_consistency": {..., "status": "PASS/FAIL"}
}

Apply CRITIC self-review before reporting done.
</prompt>
<output>.planning/phases/08-data-validation-backtest/outputs/PHASE4_CROSS_CATALOG_CONSISTENCY.json</output>
</task>

<task id="4.2" type="auto" agent="oracle-backtest-commander" round="1">
<name>Metadata Completeness</name>
<prompt>
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
   - ticks_written matches actual parquet row count (EXACT MATCH)

2. Parquet Metadata
   - Each parquet file has valid row group metadata
   - Schema consistent across files
   - REQUIRED COLUMNS: ts_event, ts_init, bid_price, ask_price, bid_size, ask_size

3. config.yaml Integration
   - Catalog paths correctly referenced
   - Fallback paths valid

OUTPUT JSON:
{
  "overall_status": "PASS/FAIL",
  "pass_condition": "All checkpoints valid AND parquet_metadata_valid AND config_integration PASS",
  "catalogs_audited": int,
  "checkpoints_valid": int,
  "checkpoints_missing": [...],
  "parquet_metadata_valid": true/false,
  "config_integration": "PASS/FAIL"
}

Apply CRITIC self-review before reporting done.
</prompt>
<output>.planning/phases/08-data-validation-backtest/outputs/PHASE4_METADATA_AUDIT.json</output>
</task>

<!-- ROUND 2: Task 4.3 DEFERRED to post-Phase 7, requires USER APPROVAL -->
<task id="4.3" type="manual" agent="forge-nautilus" round="post-phase-7">
<name>Redundant Data Cleanup (DEFERRED)</name>
<prompt>
You are FORGE executing safe cleanup of redundant data.

⚠️ THIS TASK REQUIRES EXPLICIT USER APPROVAL BEFORE EXECUTION ⚠️
⚠️ ONLY EXECUTE AFTER PHASE 7 BACKTEST PASSES ⚠️

TASK: Remove redundant data files after validation confirms they are unnecessary.

REDUNDANT DATA IDENTIFIED:
1. Session CSVs: data/session_csvs/ (~14 GB)
2. Incomplete catalogs: data/catalog_native/xauusd_2003_2025_stride20_full_INCOMPLETE/
3. Old catalog versions: data/catalog_native/xauusd_2003_2025_stride1_full/

ROLLBACK MECHANISM:
1. Calculate space needed: du -sh target_dirs + 10% buffer
2. Verify sufficient disk space for .trash/ staging
3. MOVE files to data/.trash_YYYYMMDD_HHMMSS/
4. Create JSON metadata for each file (audit trail)
5. 7-day retention in .trash/
6. Only permanent delete after user confirmation

PRE-CONDITIONS (all must be true):
- Phase 2 quality score >= 70
- Phase 3 all sessions PASS
- Phase 4.1 cross-catalog PASS
- Phase 7 backtest PASS
- USER EXPLICITLY APPROVES

OUTPUT JSON:
{
  "overall_status": "PASS/FAIL/SKIPPED",
  "files_deleted": int,
  "space_recovered_gb": float,
  "trash_folder": "data/.trash_YYYYMMDD_HHMMSS/",
  "retention_expires": "YYYY-MM-DD (7 days from move)",
  "execution_status": "DRY_RUN/MOVED_TO_TRASH/SKIPPED"
}

Apply CRITIC self-review before reporting done.
</prompt>
<output>.planning/phases/08-data-validation-backtest/outputs/PHASE4_CLEANUP_REPORT.json</output>
</task>
</tasks>

<verification>
After Tasks 4.1 and 4.2 complete:
1. Both JSON files exist in .planning/phases/08-data-validation-backtest/outputs/PHASE4_*.json
2. Both tasks report overall_status PASS
3. Tick reconciliation: EXACT MATCH (0 difference)
4. No overlaps detected
5. Metadata complete for all catalogs

Task 4.3 verification (post-Phase 7):
6. User approval obtained
7. Files safely moved to .trash/
8. Metadata JSON files created
</verification>

<success_criteria>
- Tick reconciliation: EXACT match (0 difference)
- No overlaps: 0 overlapping timestamps
- No gaps: 100% coverage (excluding weekends/holidays)
- Metadata complete: All checkpoints valid
- Cleanup safe: Pre-conditions met + .trash/ rollback
</success_criteria>
