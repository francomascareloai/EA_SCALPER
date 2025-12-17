---
type: plan
description: "Phase 5: Advanced Validation (GJR-GARCH, Stylized Facts, Look-Ahead)"
phase_id: "05"
status: pending
priority: CRITICAL
model: opus
changelog: "2025-12-17: Added Protocol 0 (Mandatory Delegation)"
---

## ⚠️ MANDATORY DELEGATION (Protocol 0)

> **CRITICAL: The orchestrator MUST NOT read data or run statistical analysis directly.**
>
> Phase 5 performs advanced statistical analysis. Sub-agents handle all computations.

### Required Sub-Agent Prompt

```
DELEGATION PROTOCOL (MANDATORY):
1. YOU read data and run statistical analysis - orchestrator has NOT
2. Write COMPLETE analysis to: [output_path]
3. Return ONLY summary (max 300 words) with:
   - Status: PASS/FAIL/CONTAMINATED
   - Key metrics (authenticity score, stylized facts results)
   - Any CRITICAL issues (especially look-ahead bias)
   - Output file path

Plan: .planning/phases/08-data-validation-backtest/05-PLAN.xml.md
```

---

<objective>
Deep statistical validation including:
1. GJR-GARCH volatility analysis (gold's leverage effect)
2. Look-ahead bias detection (BLOCKING GATE)
3. Data lineage documentation
4. Performance benchmarking
5. Stylized Facts Battery (5 authenticity tests)

REGRA: USE scripts existentes de scripts/oracle/ e scripts/data/. NÃO crie novos.
Referência: SCRIPT_REGISTRY.md
</objective>

<execution_context>
Memory: 12GB system, 6GB max for validation
Execution: 3 sequential rounds (look-ahead is blocking gate)
Dependencies: arch>=6.0.0, scipy>=1.11.0, statsmodels>=0.14.0
Scripts: scripts/oracle/validate_data_v2.py (includes Hurst/entropy)
Reference: .planning/phases/08-data-validation-backtest/05-PLAN.xml.md
</execution_context>

<context>
- CLAUDE.md for project rules
- SCRIPT_REGISTRY.md for existing scripts
- .claude/agents/argus-quant-researcher.md for ARGUS agent
- .claude/agents/sentinel-apex-guardian.md for SENTINEL agent
- .claude/agents/forge-nautilus.md for FORGE agent
- .claude/agents/performance-optimizer.md for PERF_OPT agent
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
<!-- ROUND 1: Task 5.2 ALONE (BLOCKING GATE) -->
<task id="5.2" type="auto" agent="sentinel-apex-guardian" round="1">
<name>Look-Ahead Bias Detection (BLOCKING GATE)</name>
<prompt>
You are SENTINEL detecting look-ahead bias in XAUUSD data pipeline.

TASK: Audit data for any potential look-ahead bias or data leakage.

⚠️ BLOCKING GATE: If CONTAMINATED detected, ABORT all subsequent phases ⚠️

AREAS TO CHECK:

1. TIMESTAMP ORDERING
   - Data sorted by ts_event (event time), not ts_init (processing time)
   - No future information leaking into past
   - Sample 1M ticks and verify ordering

2. DATA TRANSFORMATIONS
   - Review scripts/data/*.py for operations using future data
   - Check for .shift(-1) or .fillna(method='bfill')
   - Verify no forward-filling of prices

3. INDICATOR CALCULATIONS
   - If indicators are pre-computed, verify they're causal
   - Moving averages should use only past data

4. SPREAD CALCULATIONS
   - Spread = ask - bid (at same timestamp)
   - No use of future bid/ask

5. SESSION FILTERING
   - Verify session filters use only current tick timestamp

6. AST-BASED AUTOMATED SCAN (optional)
   - Scan for dangerous patterns: .shift(-N), .bfill(), iloc[i+N]

AUDIT SCRIPTS:
- scripts/data/convert_tick_data.py
- scripts/convert_csv_to_nautilus_catalog.py
- nautilus_gold_scalper/indicators/*.py
- scripts/slice_catalog_by_session.py

OUTPUT JSON:
{
  "overall_status": "CLEAN/CONTAMINATED",
  "severity": "NONE/LOW/HIGH/CRITICAL",
  "timestamp_ordering": {...},
  "transformations": {...},
  "indicators": {...},
  "ast_scan": {...}
}

If CONTAMINATED: Create DOCS/04_REPORTS/CRITICAL_FAILURE_LOOKAHEAD.md

Apply CRITIC self-review before reporting done.
</prompt>
<output>.planning/phases/08-data-validation-backtest/outputs/PHASE5_LOOKAHEAD_AUDIT.json</output>
</task>

<!-- ROUND 2: Tasks 5.1, 5.3, 5.5 in parallel (only if Round 1 CLEAN) -->
<task id="5.1" type="auto" agent="argus-quant-researcher" round="2">
<name>GJR-GARCH Volatility Analysis</name>
<prompt>
You are ARGUS conducting volatility analysis on XAUUSD data using GJR-GARCH.

TASK: Verify data authenticity through volatility clustering patterns.

DATA: data/catalog_native/xauusd_2003_2025_stride1_COMPLETE
PREPROCESSING: Aggregate tick data to 1-minute bars first (~200K bars)

WHY GJR-GARCH:
Gold exhibits asymmetric volatility (leverage effect) - negative returns increase
volatility more than positive returns. Basic GARCH(1,1) misses this.

ANALYSIS:

1. VOLATILITY AUTOCORRELATION
   - Calculate returns from 1-min bars
   - Test autocorrelation: ACF(1) > 0.15 AND ACF(5) > 0.08
   - Real markets show volatility clustering

2. GJR-GARCH MODEL FIT
   ```python
   from arch import arch_model
   model = arch_model(returns, vol='Garch', p=1, o=1, q=1)
   result = model.fit(disp='off')
   # Verify gamma > 0 (leverage effect present)
   ```

3. FAT TAILS CHECK
   - Calculate return distribution
   - Real markets have EXCESS kurtosis > 0 (scipy default)
   - Or Raw Kurtosis > 3

4. VOLATILITY REGIME DETECTION
   - Identify high/medium/low volatility regimes
   - Correlate with known events (2008 crisis, 2020 COVID)

5. INTRADAY VOLATILITY PATTERNS
   - Higher vol during London/NY overlap
   - Lower vol during Asian session

OUTPUT JSON with authenticity_score (0-100), must be >= 70.

Apply CRITIC self-review before reporting done.
</prompt>
<output>.planning/phases/08-data-validation-backtest/outputs/PHASE5_VOLATILITY_ANALYSIS.json</output>
</task>

<task id="5.3" type="auto" agent="forge-nautilus" round="2">
<name>Data Lineage Documentation</name>
<prompt>
You are FORGE documenting data lineage for XAUUSD pipeline.

TASK: Create comprehensive data lineage documentation.

LINEAGE TO DOCUMENT:

1. SOURCE DATA
   - Original: Python_Agent_Hub/ml_pipeline/data/CSV_2003-2025XAUUSD_ftmo_all-TICK-NoSession.csv
   - Provider: FTMO
   - Size: 30.6 GB
   - Rows: 654,586,033

2. TRANSFORMATION PIPELINE
   Step 1: CSV → Nautilus Catalog
   - Script: scripts/convert_csv_to_nautilus_catalog.py
   - Output: data/catalog_native/xauusd_2003_2025_stride1_COMPLETE/

   Step 2: Full Catalog → Session Catalogs
   - Script: scripts/slice_catalog_by_session.py
   - Output: data/catalog_native_sessions/

3. QUALITY GATES APPLIED
   - Max invalid rows
   - Crossed quote detection
   - Disjoint timestamp detection

4. VALIDATION STEPS
   - Schema validation
   - Temporal consistency
   - Price validation

CREATE: DOCS/06_REFERENCE/DATA_LINEAGE.md

OUTPUT JSON with lineage status.

Apply CRITIC self-review before reporting done.
</prompt>
<output>.planning/phases/08-data-validation-backtest/outputs/PHASE5_LINEAGE_STATUS.json</output>
</task>

<task id="5.5" type="auto" agent="argus-quant-researcher" round="2">
<name>Stylized Facts Battery</name>
<prompt>
You are ARGUS conducting comprehensive stylized facts validation on XAUUSD data.

TASK: Run the Stylized Facts Battery to verify data authenticity.

DATA: Use 1-min aggregated data (reuse from Task 5.1 if available)

THE 5 STYLIZED FACTS TO VALIDATE:

1. VOLATILITY CLUSTERING (GARCH LR Test)
   - Fit GARCH(1,1) model
   - Perform Likelihood Ratio test vs constant variance null
   - Pass: LR test p < 0.01

2. FAT TAILS (Student-t Distribution Fit)
   - Fit Student-t distribution to returns
   - Pass: df in range [3, 6]

3. LEVERAGE EFFECT (Return-Volatility Correlation)
   - Calculate: corr(returns[t], volatility[t+1])
   - Pass: correlation < 0 (negative)

4. SLOW ACF DECAY OF SQUARED RETURNS
   - Calculate ACF of squared returns up to lag 50
   - Pass: ACF[50] > 0.05

5. JUMP DETECTION (Lee-Mykland 2008)
   - Detect statistically significant price jumps
   - Pass: at least some jumps detected in 20+ years

PASS CRITERIA: >= 4 of 5 tests must pass for AUTHENTIC verdict

OUTPUT JSON:
{
  "volatility_clustering": true/false,
  "fat_tails": true/false,
  "leverage_effect": true/false,
  "slow_acf_decay": true/false,
  "jumps_detected": true/false,
  "tests_passed": int,
  "authenticity_verdict": "AUTHENTIC/SUSPICIOUS"
}

Apply CRITIC self-review before reporting done.
</prompt>
<output>.planning/phases/08-data-validation-backtest/outputs/PHASE5_STYLIZED_FACTS.json</output>
</task>

<!-- ROUND 3: Task 5.4 alone (clean I/O measurement) -->
<task id="5.4" type="auto" agent="performance-optimizer" round="3">
<name>Performance Benchmarks</name>
<prompt>
You are PERF_OPT benchmarking data loading performance.

TASK: Establish performance baselines for data operations.

BENCHMARKS TO RUN:

1. FULL CATALOG LOAD
   - Time to open ParquetDataCatalog
   - Time to query full date range
   - Peak memory usage

2. TIME-RANGE QUERY
   - Query 1 month of data (use 2024-01)
   - Query 1 week of data
   - Query 1 day of data
   - Measure time and memory for each

3. SESSION QUERY
   - Query each session for 1 month
   - Compare times across sessions

4. STREAMING PERFORMANCE
   - Iterate over 1M ticks
   - Measure throughput (ticks/second)
   - Target: > 100K ticks/second

5. BACKTEST SIMULATION
   - Simulate backtest engine loading pattern
   - Sequential tick iteration with strategy calls

DATA LOADING TARGETS:
- Catalog metadata open: < 2 seconds
- 1-month query: < 5 seconds
- Streaming throughput: > 100K ticks/second
- Memory growth during streaming: < 10%

Run benchmarks twice: cold cache first, then warm cache.

OUTPUT JSON with benchmark results.

Apply CRITIC self-review before reporting done.
</prompt>
<output>.planning/phases/08-data-validation-backtest/outputs/PHASE5_PERFORMANCE_BENCHMARK.json</output>
</task>
</tasks>

<verification>
STOP GATE (after Round 1):
- If Task 5.2 returns CONTAMINATED → ABORT Phase 5 and all subsequent phases
- Create CRITICAL_FAILURE_LOOKAHEAD.md

After all 5 tasks complete (if no stop gate triggered):
1. All 5 JSON files exist in .planning/phases/08-data-validation-backtest/outputs/PHASE5_*.json
2. Task 5.2 (Look-ahead): CLEAN
3. Task 5.1 (Volatility): authenticity_score >= 70
4. Task 5.5 (Stylized Facts): >= 4/5 tests pass
5. Task 5.4 (Performance): meets targets
</verification>

<success_criteria>
- Look-ahead bias: NONE detected (CRITICAL)
- Volatility clustering: Significant autocorrelation
- GJR-GARCH leverage: gamma > 0 (leverage effect confirmed)
- Fat tails: Kurtosis > 3
- Stylized Facts Battery: >= 4 of 5 tests pass
- Lineage documented: Complete
- Performance targets: Met
</success_criteria>
