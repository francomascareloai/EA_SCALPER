---
type: plan
description: "Phase 1-A: Deep Data Validation (CSV → Parquet Quality)"
phase_id: "01-A"
status: pending
priority: CRITICAL
model: opus
changelog: "2025-12-17: Added Protocol 0 (Mandatory Delegation)"
---

## ⚠️ MANDATORY DELEGATION (Protocol 0)

> **CRITICAL: The orchestrator MUST NOT read data files or run scripts directly.**
>
> Phase 1-A processes large datasets. Sub-agents handle all file I/O.

### Required Sub-Agent Prompt

```
DELEGATION PROTOCOL (MANDATORY):
1. YOU read and execute - orchestrator has NOT
2. Run the specified script(s) and capture output
3. Write COMPLETE results to: [output_path]
4. Return ONLY summary (max 300 words) with:
   - Status: PASS/FAIL
   - Key metrics (tick counts, scores)
   - Any CRITICAL/HIGH issues found
   - Output file path

Plan: .planning/phases/08-data-validation-backtest/01-A-PLAN.xml.md
```

---

<objective>
Deep validation of data quality using EXISTING scripts.

REGRA: USE scripts existentes de scripts/oracle/ e scripts/data/. NÃO crie novos.
Referência: SCRIPT_REGISTRY.md
</objective>

<execution_context>
Memory: 12GB system, 6GB max for validation
Execution: 2 rounds
Dependencies: duckdb, polars, pandas-market-calendars, pandera
Scripts: scripts/oracle/validate_data_v2.py, scripts/data/validate_nautilus_catalog.py
</execution_context>

<context>
- CLAUDE.md for project rules
- SCRIPT_REGISTRY.md for existing scripts
- scripts/oracle/validate_data_v2.py (50KB - data validation with Hurst/entropy)
- scripts/data/validate_nautilus_catalog.py (catalog validation)
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
<!-- ROUND 1: Validate main catalog and sessions using EXISTING scripts -->
<task id="1A.1" type="auto" agent="oracle-backtest-commander" round="1">
<name>Validate Main Catalog</name>
<prompt>
USE EXISTING SCRIPT: scripts/data/validate_nautilus_catalog.py

Execute:
```bash
python -m scripts.data.validate_nautilus_catalog \
  --catalog data/catalog_native/xauusd_2003_2025_stride1_COMPLETE \
  --venue SIM \
  --start 2003-01-01 \
  --end 2025-12-31
```

Capture output and save to JSON.

If script needs adaptation, COPY to scripts/data/validate_catalog_extended.py with clear reference to original.

OUTPUT JSON:
{
  "script_used": "scripts/data/validate_nautilus_catalog.py",
  "catalog_path": "...",
  "tick_count": int,
  "date_range": {"start": "...", "end": "..."},
  "validation_passed": true/false,
  "issues": [...]
}
</prompt>
<output>.planning/phases/08-data-validation-backtest/outputs/PHASE1A_CATALOG_VALIDATION.json</output>
</task>

<task id="1A.2" type="auto" agent="oracle-backtest-commander" round="1">
<name>Validate Data Quality</name>
<prompt>
USE EXISTING SCRIPT: scripts/oracle/validate_data_v2.py

Execute:
```bash
python -m scripts.oracle.validate_data_v2 \
  --input data/catalog_native/xauusd_2003_2025_stride1_COMPLETE
```

This script already includes:
- Hurst exponent calculation
- Entropy analysis
- Regime detection
- Quality scoring

Capture output and save to JSON.

OUTPUT JSON:
{
  "script_used": "scripts/oracle/validate_data_v2.py",
  "quality_score": float,
  "hurst_exponent": float,
  "entropy": float,
  "regimes_detected": [...],
  "validation_passed": true/false
}
</prompt>
<output>.planning/phases/08-data-validation-backtest/outputs/PHASE1A_DATA_QUALITY.json</output>
</task>

<!-- ROUND 2: Session validation -->
<task id="1A.3" type="auto" agent="oracle-backtest-commander" round="2">
<name>Validate Session Catalogs</name>
<prompt>
USE EXISTING SCRIPT: scripts/data/validate_nautilus_catalog.py

Execute for each session catalog:
```bash
for session in ASIAN LONDON OVERLAP NY LATE_NY EVENING; do
  python -m scripts.data.validate_nautilus_catalog \
    --catalog data/catalog_native_sessions/xauusd_2003_2025_stride1_${session} \
    --venue SIM
done
```

Aggregate results into single JSON.

OUTPUT JSON:
{
  "script_used": "scripts/data/validate_nautilus_catalog.py",
  "sessions": {
    "ASIAN": {"tick_count": int, "valid": true/false},
    "LONDON": {...},
    ...
  },
  "all_valid": true/false
}
</prompt>
<output>.planning/phases/08-data-validation-backtest/outputs/PHASE1A_SESSION_VALIDATION.json</output>
</task>
</tasks>

<verification>
1. All outputs use EXISTING scripts (no new scripts created)
2. PHASE1A_*.json files exist in outputs/
3. All validations passed
4. Script paths recorded in each JSON output
</verification>

<success_criteria>
- Used existing scripts: 100%
- New scripts created: 0
- Catalog validated: PASS
- Data quality: score >= 70
- Sessions validated: All 6 PASS
</success_criteria>
