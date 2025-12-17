---
type: plan
description: "Phase 2: Main Catalog Validation (8 Tasks)"
phase_id: "02"
status: pending
priority: CRITICAL
model: opus
changelog: "2025-12-17: Added Protocol 0 (Mandatory Delegation)"
---

## ⚠️ MANDATORY DELEGATION (Protocol 0)

> **CRITICAL: The orchestrator MUST NOT read data files or run validation directly.**
>
> Phase 2 validates 654M+ ticks. Sub-agents handle all file I/O and analysis.

### Required Sub-Agent Prompt

```
DELEGATION PROTOCOL (MANDATORY):
1. YOU read catalog data and run validation - orchestrator has NOT
2. Write COMPLETE analysis to: [output_path]
3. Return ONLY summary (max 300 words) with:
   - Status: PASS/FAIL
   - Key metrics (tick counts, quality scores)
   - Any CRITICAL/HIGH issues found
   - Output file path

Plan: .planning/phases/08-data-validation-backtest/02-PLAN.xml.md
```

---

<objective>
Comprehensive validation of the main 654.6M tick catalog (stride-1 COMPLETE) using 8 validation tasks across 4 rounds.

REGRA: USE scripts existentes de scripts/oracle/ e scripts/data/. NÃO crie novos.
Referência: SCRIPT_REGISTRY.md

Key paths:
- CATALOG: data/catalog_native/xauusd_2003_2025_stride1_COMPLETE
- EXPECTED: 654,586,033 ticks
- DATE RANGE: 2003-05-05 to 2025-11-28
</objective>

<execution_context>
Memory: 12GB system, 6GB max for validation
Execution: 4 sequential rounds (memory safety + dependency correctness)
Dependencies: duckdb, polars, pandas-market-calendars, whittlehurst
Scripts: scripts/data/validate_nautilus_catalog.py, scripts/oracle/validate_data_v2.py
Reference: .planning/phases/08-data-validation-backtest/02-PLAN.xml.md
</execution_context>

<context>
- CLAUDE.md for project rules
- SCRIPT_REGISTRY.md for existing scripts
- .claude/agents/oracle-backtest-commander.md for ORACLE agent
- .claude/agents/argus-quant-researcher.md for ARGUS agent
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
<!-- ROUND 1: Task 2.1 ALONE (blocking gate) -->
<task id="2.1" type="auto" agent="oracle-backtest-commander" round="1">
<name>Quick Health Check</name>
<prompt>
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

OUTPUT JSON: status (PASS/FAIL) for each check
GATE: If ANY check fails, ABORT Phase 2 and escalate

Apply CRITIC self-review before reporting done.
</prompt>
<output>.planning/phases/08-data-validation-backtest/outputs/PHASE2_HEALTH_CHECK.json</output>
</task>

<!-- ROUND 1b: Tasks 2.2, 2.3, 2.4 in parallel -->
<task id="2.2" type="auto" agent="oracle-backtest-commander" round="1b">
<name>Schema Validation</name>
<prompt>
You are ORACLE validating the XAUUSD main catalog schema.

TASK: Validate Parquet schema consistency across all files.

CATALOG: data/catalog_native/xauusd_2003_2025_stride1_COMPLETE/data/quote_tick/XAU%2FUSD.SIM/

CHECKS:
1. All parquet files have same schema
2. Required columns exist: instrument_id, ts_event, ts_init, bid_price, ask_price, bid_size, ask_size
3. Column types are correct (int64 for prices, uint64 for timestamps)
4. No unexpected columns

OUTPUT JSON with schema details and any inconsistencies.

Apply CRITIC self-review before reporting done.
</prompt>
<output>.planning/phases/08-data-validation-backtest/outputs/PHASE2_SCHEMA_VALIDATION.json</output>
</task>

<task id="2.3" type="auto" agent="oracle-backtest-commander" round="1b">
<name>Temporal Consistency</name>
<prompt>
You are ORACLE validating the XAUUSD main catalog temporal consistency.

TASK: Validate temporal consistency of timestamps.

CATALOG: data/catalog_native/xauusd_2003_2025_stride1_COMPLETE

CHECKS:
1. Timestamps are monotonically non-decreasing (duplicates allowed in tick data)
2. Document duplicate timestamp count (expected in tick data; >0.1% is concerning)
3. No future timestamps (beyond 2025-11-28)
4. No timestamps before 2003-05-05
5. Sample 1M ticks from start, middle, end for efficiency
6. Verify parquet files are read in chronological order
7. Verify last timestamp of file N < first timestamp of file N+1

OUTPUT JSON with temporal analysis.

Apply CRITIC self-review before reporting done.
</prompt>
<output>.planning/phases/08-data-validation-backtest/outputs/PHASE2_TEMPORAL_CONSISTENCY.json</output>
</task>

<task id="2.4" type="auto" agent="oracle-backtest-commander" round="1b">
<name>Price Validation</name>
<prompt>
You are ORACLE validating the XAUUSD main catalog price data.

TASK: Validate price data quality.

CATALOG: data/catalog_native/xauusd_2003_2025_stride1_COMPLETE

SAMPLING: Triad strategy - 1M ticks each from:
- Start (2003-2005)
- Middle (2013-2015)
- End (2023-2025)

CHECKS:
1. All bid <= ask (no crossed quotes)
2. Spread = ask - bid, check spread distribution
3. Price range reasonable ($300-$3500 for XAUUSD 2003-2025)
4. No NaN or Inf values
5. No zero or negative prices
6. Spread 95th percentile < 100 cents
7. Average spread < 30 cents
8. No single-tick price moves > 2% (fat finger detection)

OUTPUT JSON with price statistics and any violations.

Apply CRITIC self-review before reporting done.
</prompt>
<output>.planning/phases/08-data-validation-backtest/outputs/PHASE2_PRICE_VALIDATION.json</output>
</task>

<!-- ROUND 2: Tasks 2.5, 2.6, 2.7 in parallel -->
<task id="2.5" type="auto" agent="oracle-backtest-commander" round="2">
<name>Gap Analysis</name>
<prompt>
You are ORACLE validating the XAUUSD main catalog for gaps.

TASK: Comprehensive gap analysis.

CATALOG: data/catalog_native/xauusd_2003_2025_stride1_COMPLETE

MEMORY CONSTRAINT: 12 GB total. Use DuckDB with spill-to-disk.

```python
import duckdb
db = duckdb.connect(":memory:")
db.execute("SET memory_limit='6GB';")
db.execute("SET temp_directory='/tmp/duckdb_swap';")
```

AUTOMATED HOLIDAY DETECTION (pandas_market_calendars):
```python
import pandas_market_calendars as mcal
calendar = mcal.get_calendar('CME_Metals')
holidays = calendar.holidays(start='2003-01-01', end='2025-12-31')
```

DST HANDLING:
- Market close shifts between 21:00 UTC (winter) and 20:00 UTC (summer)
- Apply 1-hour tolerance when checking weekend boundaries

GAP CATEGORIES:
- Minor: 1-4 hours
- Moderate: 4-24 hours
- Critical: >24 hours (FAIL if not weekend/holiday)

OUTPUT JSON:
- Total gaps by category
- List of all critical gaps with dates
- Histogram of gap distribution

Apply CRITIC self-review before reporting done.
</prompt>
<output>.planning/phases/08-data-validation-backtest/outputs/PHASE2_GAP_ANALYSIS.json</output>
</task>

<task id="2.6" type="auto" agent="argus-quant-researcher" round="2">
<name>Regime Analysis</name>
<prompt>
You are ARGUS conducting regime analysis on XAUUSD data.

TASK: Analyze market regimes using Hurst exponent.

DATA: Aggregate tick data to daily OHLC before Hurst calculation.

ANALYSIS:
1. Calculate Hurst exponent using Whittle estimator (primary) or R/S method (fallback)
2. Classify regimes: trending (H>0.55), random (0.45<H<0.55), mean-reverting (H<0.45)
3. Segment data by year and calculate per-year regime
4. Identify regime transitions

REQUIREMENTS:
- All 3 regime types should have >10% representation
- No single regime should dominate >70%

OUTPUT JSON with regime analysis.

Apply CRITIC self-review before reporting done.
</prompt>
<output>.planning/phases/08-data-validation-backtest/outputs/PHASE2_REGIME_ANALYSIS.json</output>
</task>

<task id="2.7" type="auto" agent="oracle-backtest-commander" round="2">
<name>Session Coverage</name>
<prompt>
You are ORACLE validating session coverage in XAUUSD data.

TASK: Analyze tick distribution across trading sessions.

SESSION WINDOWS (UTC) - aligned with validate_data_v2.py:
- ASIAN: 00:00-07:00
- LONDON: 07:00-12:00
- OVERLAP: 12:00-16:00
- NY: 16:00-21:00
- CLOSE: 21:00-00:00

APEX TIME GATES (ET):
- Block new trades after 4:30 PM ET
- Force close from 4:55 PM ET
- No overnight positions past 4:59 PM ET

ANALYSIS:
1. Count ticks per session
2. Calculate percentage distribution
3. Verify all sessions have >5% coverage
4. Map Apex time gates to UTC for validation

OUTPUT JSON with session distribution.

Apply CRITIC self-review before reporting done.
</prompt>
<output>.planning/phases/08-data-validation-backtest/outputs/PHASE2_SESSION_COVERAGE.json</output>
</task>

<!-- ROUND 3: Task 2.8 alone (depends on 2.5, 2.6, 2.7) -->
<task id="2.8" type="auto" agent="oracle-backtest-commander" round="3">
<name>Quality Scoring</name>
<prompt>
You are ORACLE computing final quality score for XAUUSD data.

TASK: Calculate comprehensive quality score (0-100).

SCORING COMPONENTS (graduated scoring):
- Coverage (25pts): ≥36 months = 25pts
- Clean Data (25pts): ≥99% = 25pts
- Gaps (15pts): 0 critical gaps = 15pts
- Regime Diversity (15pts): All 3 regimes >10% = 15pts
- Session Coverage (10pts): All sessions >5% = 10pts
- Spread Quality (10pts): Avg <30 cents = 10pts

INPUT FILES (wait for these to exist):
- PHASE2_GAP_ANALYSIS.json
- PHASE2_REGIME_ANALYSIS.json
- PHASE2_SESSION_COVERAGE.json

APPROVAL CRITERIA:
- ≥36 months coverage
- ≥95% clean data
- 0 critical gaps (>24h non-weekend)
- Quality score ≥70

OUTPUT JSON with breakdown and final score.

Apply CRITIC self-review before reporting done.
</prompt>
<output>.planning/phases/08-data-validation-backtest/outputs/PHASE2_QUALITY_SCORE.json</output>
</task>
</tasks>

<verification>
After all 8 tasks complete:
1. All 8 JSON files exist in .planning/phases/08-data-validation-backtest/outputs/PHASE2_*.json
2. Task 2.1 (Health Check) status PASS (blocking gate)
3. Task 2.8 (Quality Score) ≥ 70
4. No CRITICAL failures in any task
5. Memory peak < 6GB for all tasks
</verification>

<success_criteria>
- Health check: All PASS
- Schema consistent: 100%
- Temporal consistency: No future timestamps, monotonic
- Crossed quotes: 0%
- Critical gaps: 0 (non-weekend)
- Quality score: ≥70/100
- Regime diversity: All 3 >10%
- Session coverage: All sessions >5%
</success_criteria>
