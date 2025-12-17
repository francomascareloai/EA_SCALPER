---
type: plan
description: "Phase 3: Session Catalog Validation (6 Sessions)"
phase_id: "03"
status: pending
priority: CRITICAL
model: opus
changelog: "2025-12-17: Added Protocol 0 (Mandatory Delegation)"
---

## ⚠️ MANDATORY DELEGATION (Protocol 0)

> **CRITICAL: The orchestrator MUST NOT read session catalog data directly.**
>
> Phase 3 validates 6 session catalogs. Sub-agents handle all file I/O.

### Required Sub-Agent Prompt

```
DELEGATION PROTOCOL (MANDATORY):
1. YOU read session catalog data and validate - orchestrator has NOT
2. Write COMPLETE analysis to: [output_path]
3. Return ONLY summary (max 300 words) with:
   - Status: PASS/FAIL
   - Session metrics (tick counts, temporal accuracy)
   - Any CRITICAL/HIGH issues found
   - Output file path

Plan: .planning/phases/08-data-validation-backtest/03-PLAN.xml.md
```

---

<objective>
Validate all 6 session-specific catalogs to ensure they correctly filter the main catalog and maintain data integrity.

REGRA: USE scripts existentes de scripts/oracle/ e scripts/data/. NÃO crie novos.
Referência: SCRIPT_REGISTRY.md

Session catalogs:
- data/catalog_native_sessions/xauusd_2003_2025_stride1_ASIAN/
- data/catalog_native_sessions/xauusd_2003_2025_stride1_LONDON/
- data/catalog_native_sessions/xauusd_2003_2025_stride1_OVERLAP/
- data/catalog_native_sessions/xauusd_2003_2025_stride1_NY/
- data/catalog_native_sessions/xauusd_2003_2025_stride1_LATE_NY/
- data/catalog_native_sessions/xauusd_2003_2025_stride1_EVENING/

Boundary Rule: [start, end) - start inclusive, end exclusive
</objective>

<execution_context>
Memory: 12GB system, 6GB max for validation
Execution: 2 rounds of 3 agents each (memory safety)
Dependencies: duckdb, polars, zoneinfo
Scripts: scripts/data/validate_nautilus_catalog.py
Reference: .planning/phases/08-data-validation-backtest/03-PLAN.xml.md
</execution_context>

<context>
- CLAUDE.md for project rules
- SCRIPT_REGISTRY.md for existing scripts
- .claude/agents/oracle-backtest-commander.md for ORACLE agent
- Phase 2 completed with PASS status
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
<!-- ROUND 1: ASIAN, LONDON, OVERLAP in parallel -->
<task id="3.1" type="auto" agent="oracle-backtest-commander" round="1">
<name>ASIAN Session Validation</name>
<prompt>
You are ORACLE validating the ASIAN session catalog for XAUUSD.

SESSION: ASIAN
START_UTC: 00:00
END_UTC: 07:00
CATALOG: data/catalog_native_sessions/xauusd_2003_2025_stride1_ASIAN/
APEX_NOTES: Low volatility expected, prepare for London open

VALIDATIONS:

1. EXISTENCE &amp; ACCESSIBILITY
   - Catalog directory exists
   - .checkpoint.json exists
   - Parquet files accessible

2. TICK COUNT &amp; COVERAGE
   - Total ticks in session
   - Expected % of main catalog (~15%)
   - Date range matches main catalog (2003-2025)

3. TEMPORAL FILTERING ACCURACY
   - Sample 100K ticks + first/last 1000 per trading day
   - Verify ALL timestamps fall within 00:00-07:00 UTC
   - No out-of-window leakage

4. DATA INTEGRITY
   - Bid <= Ask (no crossed quotes)
   - Prices in valid range
   - Timestamps monotonic within session

5. GAP ANALYSIS (session-specific)
   - Expected gaps between sessions (normal)
   - Unexpected gaps within session (flag if >120s)
   - Weekend/holiday exclusions applied

OUTPUT JSON with session validation results.

Apply CRITIC self-review before reporting done.
</prompt>
<output>.planning/phases/08-data-validation-backtest/outputs/PHASE3_SESSION_ASIAN.json</output>
</task>

<task id="3.2" type="auto" agent="oracle-backtest-commander" round="1">
<name>LONDON Session Validation</name>
<prompt>
You are ORACLE validating the LONDON session catalog for XAUUSD.

SESSION: LONDON
START_UTC: 07:00
END_UTC: 12:00
CATALOG: data/catalog_native_sessions/xauusd_2003_2025_stride1_LONDON/
APEX_NOTES: High volatility expected, major moves

VALIDATIONS:

1. EXISTENCE &amp; ACCESSIBILITY
   - Catalog directory exists
   - .checkpoint.json exists
   - Parquet files accessible

2. TICK COUNT &amp; COVERAGE
   - Total ticks in session
   - Expected % of main catalog (~20%)
   - Date range matches main catalog

3. TEMPORAL FILTERING ACCURACY
   - Sample 100K ticks + first/last 1000 per trading day
   - Verify ALL timestamps fall within 07:00-12:00 UTC
   - No out-of-window leakage

4. DATA INTEGRITY
   - Bid <= Ask (no crossed quotes)
   - Prices in valid range
   - Timestamps monotonic within session

5. GAP ANALYSIS (session-specific)
   - Flag if gap >60s within session

OUTPUT JSON with session validation results.

Apply CRITIC self-review before reporting done.
</prompt>
<output>.planning/phases/08-data-validation-backtest/outputs/PHASE3_SESSION_LONDON.json</output>
</task>

<task id="3.3" type="auto" agent="oracle-backtest-commander" round="1">
<name>OVERLAP Session Validation</name>
<prompt>
You are ORACLE validating the OVERLAP session catalog for XAUUSD.

SESSION: OVERLAP
START_UTC: 12:00
END_UTC: 15:00
CATALOG: data/catalog_native_sessions/xauusd_2003_2025_stride1_OVERLAP/
APEX_NOTES: Maximum liquidity, London+NY open

VALIDATIONS:

1. EXISTENCE &amp; ACCESSIBILITY
   - Catalog directory exists
   - .checkpoint.json exists
   - Parquet files accessible

2. TICK COUNT &amp; COVERAGE
   - Total ticks in session
   - Expected % of main catalog (~15%)
   - Date range matches main catalog

3. TEMPORAL FILTERING ACCURACY
   - Sample 100K ticks + first/last 1000 per trading day
   - Verify ALL timestamps fall within 12:00-15:00 UTC
   - No out-of-window leakage

4. DATA INTEGRITY
   - Bid <= Ask (no crossed quotes)
   - Prices in valid range
   - Timestamps monotonic within session

5. GAP ANALYSIS (session-specific)
   - Flag if gap >30s within session (high liquidity expected)

OUTPUT JSON with session validation results.

Apply CRITIC self-review before reporting done.
</prompt>
<output>.planning/phases/08-data-validation-backtest/outputs/PHASE3_SESSION_OVERLAP.json</output>
</task>

<!-- ROUND 2: NY, LATE_NY, EVENING in parallel -->
<task id="3.4" type="auto" agent="oracle-backtest-commander" round="2">
<name>NY Session Validation</name>
<prompt>
You are ORACLE validating the NY session catalog for XAUUSD.

SESSION: NY
START_UTC: 15:00
END_UTC: 17:00
CATALOG: data/catalog_native_sessions/xauusd_2003_2025_stride1_NY/
APEX_NOTES: US data releases, high volatility

VALIDATIONS:

1. EXISTENCE &amp; ACCESSIBILITY
   - Catalog directory exists
   - .checkpoint.json exists
   - Parquet files accessible

2. TICK COUNT &amp; COVERAGE
   - Total ticks in session
   - Expected % of main catalog (~10%)
   - Date range matches main catalog

3. TEMPORAL FILTERING ACCURACY
   - Sample 100K ticks + first/last 1000 per trading day
   - Verify ALL timestamps fall within 15:00-17:00 UTC
   - No out-of-window leakage

4. DATA INTEGRITY
   - Bid <= Ask (no crossed quotes)
   - Prices in valid range
   - Timestamps monotonic within session

5. GAP ANALYSIS (session-specific)
   - Flag if gap >30s within session

OUTPUT JSON with session validation results.

Apply CRITIC self-review before reporting done.
</prompt>
<output>.planning/phases/08-data-validation-backtest/outputs/PHASE3_SESSION_NY.json</output>
</task>

<task id="3.5" type="auto" agent="oracle-backtest-commander" round="2">
<name>LATE_NY Session Validation</name>
<prompt>
You are ORACLE validating the LATE_NY session catalog for XAUUSD.

SESSION: LATE_NY
START_UTC: 17:00
END_UTC: 21:00
CATALOG: data/catalog_native_sessions/xauusd_2003_2025_stride1_LATE_NY/
APEX_NOTES:
- SUMMER (EDT): Contains Apex time gate (4:30 PM ET = 20:30 UTC). Force-close window 20:55-20:59 UTC.
- WINTER (EST): Apex time gates are NOT in LATE_NY - they are in EVENING session.

CRITICAL: Use zoneinfo for DST handling:
```python
from zoneinfo import ZoneInfo
eastern = ZoneInfo("America/New_York")
```

VALIDATIONS:

1. EXISTENCE &amp; ACCESSIBILITY
2. TICK COUNT &amp; COVERAGE (~25%)
3. TEMPORAL FILTERING ACCURACY (17:00-21:00 UTC)
4. DATA INTEGRITY
5. GAP ANALYSIS (flag if >60s)
6. APEX WINDOW COVERAGE (summer only)

DST TRANSITION TESTS:
- Spring forward: 1-hour gap is EXPECTED
- Fall back: 1-hour overlap handled gracefully

OUTPUT JSON with session validation results.

Apply CRITIC self-review before reporting done.
</prompt>
<output>.planning/phases/08-data-validation-backtest/outputs/PHASE3_SESSION_LATE_NY.json</output>
</task>

<task id="3.6" type="auto" agent="oracle-backtest-commander" round="2">
<name>EVENING Session Validation</name>
<prompt>
You are ORACLE validating the EVENING session catalog for XAUUSD.

SESSION: EVENING
START_UTC: 21:00
END_UTC: 00:00
CATALOG: data/catalog_native_sessions/xauusd_2003_2025_stride1_EVENING/
APEX_NOTES:
- SUMMER (EDT): Force-close window (20:55-20:59 UTC) is in LATE_NY, NOT Evening.
- WINTER (EST): Contains ALL Apex gates (4:30 PM = 21:30 UTC, 4:55-4:59 PM = 21:55-21:59 UTC).
- No positions should be open after 4:59 PM ET (varies by DST).

CRITICAL: Use zoneinfo for DST handling.

VALIDATIONS:

1. EXISTENCE &amp; ACCESSIBILITY
2. TICK COUNT &amp; COVERAGE (~15%)
3. TEMPORAL FILTERING ACCURACY (21:00-00:00 UTC)
4. DATA INTEGRITY
5. GAP ANALYSIS (flag if >120s)
6. APEX WINDOW COVERAGE (winter only)

OUTPUT JSON with session validation results.

Apply CRITIC self-review before reporting done.
</prompt>
<output>.planning/phases/08-data-validation-backtest/outputs/PHASE3_SESSION_EVENING.json</output>
</task>
</tasks>

<verification>
After all 6 tasks complete, orchestrator performs cross-validation:

1. All 6 JSON files exist in .planning/phases/08-data-validation-backtest/outputs/PHASE3_SESSION_*.json
2. All sessions report status PASS
3. Cross-validation checks:
   - Sum of all session ticks MUST equal main catalog (±1% tolerance)
   - No overlap at boundaries (verify_no_overlap)
   - Missing/duplicate tick detection
4. Memory peak < 6GB for all tasks
</verification>

<success_criteria>
- All catalogs exist: 6/6
- Temporal accuracy: 100% (all ticks in window)
- Crossed quotes: 0 per session
- Combined coverage: 99-101% of main
- Missing/duplicate ticks: Explicit check + warning
- Apex time gates: Correctly bounded
- DST transition handling: Spring forward (expected gap) + Fall back (graceful)
- Within-session gaps: Documented
</success_criteria>
