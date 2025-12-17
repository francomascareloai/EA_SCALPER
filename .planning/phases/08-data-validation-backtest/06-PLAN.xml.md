---
type: plan
description: "Phase 6: Backtest Framework"
phase_id: "06"
status: pending
priority: CRITICAL
model: opus
changelog: "2025-12-17: Added Protocol 0 (Mandatory Delegation)"
---

## ⚠️ MANDATORY DELEGATION (Protocol 0)

> **CRITICAL: The orchestrator MUST NOT read strategy code or run backtests directly.**
>
> Phase 6 validates backtest infrastructure. Sub-agents handle all validation.

### Required Sub-Agent Prompt

```
DELEGATION PROTOCOL (MANDATORY):
1. YOU read code, run tests, and validate infrastructure - orchestrator has NOT
2. Write COMPLETE analysis to: [output_path]
3. Return ONLY summary (max 300 words) with:
   - Status: PASS/FAIL
   - Validation results (backtester works, look-ahead test passed)
   - Any CRITICAL issues found
   - Output file path

Plan: .planning/phases/08-data-validation-backtest/06-PLAN.xml.md
```

---

<objective>
Prepare backtesting infrastructure by:
1. Validating existing BacktestEngine works with our catalogs
2. Configuring Walk-Forward Analysis (WFA) parameters
3. Setting up Monte Carlo simulation framework

REGRA: USE scripts existentes de scripts/oracle/ e nautilus_gold_scalper/scripts/. NÃO crie novos.
Referência: SCRIPT_REGISTRY.md

SCOPE CLARIFICATION: This phase uses and validates EXISTING NautilusTrader infrastructure, not building from scratch.
</objective>

<execution_context>
Memory: 12GB system, 8GB max for backtest (leave 4GB for OS)
Execution: 3 sequential rounds (dependencies between tasks)
Dependencies: nautilus_trader, arch>=6.0.0, hmmlearn>=0.3.0
Scripts: nautilus_gold_scalper/scripts/run_backtest.py, scripts/oracle/walk_forward.py, scripts/oracle/monte_carlo.py
Reference: .planning/phases/08-data-validation-backtest/06-PLAN.xml.md
</execution_context>

<context>
- CLAUDE.md for project rules
- SCRIPT_REGISTRY.md for existing scripts
- .claude/agents/forge-nautilus.md for FORGE agent
- .claude/agents/oracle-backtest-commander.md for ORACLE agent
- Phase 1-5 completed successfully
- Data fully validated and approved
</context>

<anti_duplication_rule>
ANTES de criar qualquer código:
1. Ler SCRIPT_REGISTRY.md
2. Verificar se funcionalidade existe em scripts/oracle/ ou nautilus_gold_scalper/scripts/
3. Se existe: USAR o script existente via CLI ou import
4. Se não existe: PERGUNTAR ao usuário antes de criar
5. NUNCA criar scripts em .planning/ - use scripts/ se necessário
</anti_duplication_rule>

<tasks>
<!-- ROUND 1: Task 6.1 ALONE (foundation for WFA and MC) -->
<task id="6.1" type="auto" agent="forge-nautilus" round="1">
<name>Validate Existing Backtester</name>
<prompt>
You are FORGE validating and enhancing the existing backtest infrastructure for XAUUSD.

TASK: Validate existing BacktestEngine works with validated catalogs. Add minimal enhancements if needed.

SCOPE: VALIDATION + MINIMAL ENHANCEMENT (not building from scratch)

EXISTING COMPONENTS (USE THESE):
- nautilus_gold_scalper/scripts/run_backtest.py (PRIMARY - enhance this)
- nautilus_gold_scalper/scripts/nautilus_backtest.py (reference)
- BacktestEngine from nautilus_trader.backtest.engine (CORE - use directly)

VALIDATION CHECKLIST:
1. [ ] run_backtest.py loads from stride1_COMPLETE catalog
2. [ ] BacktestEngine processes ticks correctly
3. [ ] Strategy loads and executes
4. [ ] Trades are recorded
5. [ ] Metrics are computed

MINIMAL ENHANCEMENTS (only if missing):
- Apex time gate checks (if not present)
- Trailing DD calculation from HWM including unrealized
- Metrics export to JSON

DO NOT BUILD:
- New event-driven engine
- Custom execution models (use NautilusTrader's)
- Custom position management (use NautilusTrader's)

MANDATORY APEX COMPLIANCE (must be present):
- Time gate: block new trades after 4:30 PM ET
- Emergency close: force-close all positions at 4:55 PM ET
- Final close: close ALL by 4:59 PM ET
- Trailing DD from HWM (includes unrealized)
- 30% daily consistency check

LOOK-AHEAD DETECTION TEST:
```python
# 1. Run backtest on data[0:T]
# 2. Shuffle data[T:T+100] randomly
# 3. Re-run backtest - signals at T-1 should be IDENTICAL
# 4. If signals change, look-ahead bias detected
def test_no_lookahead():
    original_signals = run_backtest(data)
    shuffled_data = shuffle_future(data, pivot=len(data)-100)
    shuffled_signals = run_backtest(shuffled_data)
    assert signals_before_pivot_identical(original_signals, shuffled_signals)
```

REFERENCE: DOCS/04_REPORTS/VALIDATION/BACKTEST_MASTER_PLAN.md

STRATEGY LOCATION: nautilus_gold_scalper/src/strategies/
STRATEGY CONFIG: Validate strategy compiles and has no look-ahead

OUTPUT JSON:
{
  "backtest_engine_works": true/false,
  "catalog_loads": true/false,
  "strategy_executes": true/false,
  "apex_compliance_present": true/false,
  "look_ahead_test_passed": true/false,
  "enhancements_added": [...],
  "validation_passed": true/false
}

Apply CRITIC self-review. Verify no look-ahead bias. Test with 1 month sample data.
</prompt>
<output>.planning/phases/08-data-validation-backtest/outputs/PHASE6_BACKTESTER_VALIDATION.json</output>
</task>

<!-- ROUND 2: Task 6.2 (depends on 6.1) -->
<task id="6.2" type="auto" agent="oracle-backtest-commander" round="2">
<name>Walk-Forward Analysis Setup</name>
<prompt>
You are ORACLE setting up Walk-Forward Analysis infrastructure.

TASK: Configure WFA pipeline for robust out-of-sample validation.

REFERENCE: DOCS/04_REPORTS/VALIDATION/BACKTEST_MASTER_PLAN.md

EXISTING SCRIPT: scripts/oracle/walk_forward.py (review and enhance)

WFA CONFIGURATION:

1. DATA SPLIT
   - In-Sample (IS): 80% (training)
   - Out-of-Sample (OOS): 20% (validation)
   - 16 rolling windows (extended to include 2024)

2. WINDOW STRUCTURE (2020-2024 data)
   Window 1: IS=Jan 2020-Oct 2020, OOS=Nov-Dec 2020
   Window 2: IS=Mar 2020-Dec 2020, OOS=Jan-Feb 2021
   ... (rolling forward 2-month steps)
   Window 16: IS=Sep 2023-Jun 2024, OOS=Jul-Aug 2024

3. OPTIMIZATION TARGET
   - Optimize on IS data
   - Validate on OOS data
   - Compute Walk-Forward Efficiency (WFE)
   - Primary target: sharpe_ratio
   - Constraints: max_dd < 3%, min_trades >= 50

4. WFE CALCULATION
   WFE = OOS_performance / IS_performance
   - WFE >= 0.60 required for PASS
   - Handle negative IS explicitly (use absolute return comparison)

5. ADDITIONAL METRICS (ARGUS Research)
   - % of OOS windows profitable
   - OOS Sharpe ratio mean and std
   - OOS max drawdown
   - Deflated Sharpe Ratio (DSR)
   - CPCV Score >= 0.6 (replaces PBO)
   - Probabilistic Sharpe Ratio (PSR) >= 0.85
   - Minimum trades >= 200

IMPLEMENTATION:
- Update scripts/oracle/walk_forward.py
- Create WFA configuration file (YAML)
- Integrate with BacktestEngine from 6.1

TIMEZONE CONFIG:
timezone:
  data_source: UTC
  apex_gates: America/New_York
  dst_handling: automatic  # via zoneinfo

OUTPUT JSON:
{
  "wfa_config": {
    "windows": 16,
    "is_ratio": 0.8,
    "oos_ratio": 0.2,
    "date_range": ["2020-01-01", "2024-12-31"]
  },
  "optimization_target": {
    "primary": "sharpe_ratio",
    "constraints": {"max_dd": 0.03, "min_trades": 50}
  },
  "script_path": "scripts/oracle/walk_forward.py",
  "config_path": "configs/wfa_config.yaml",
  "ready_to_execute": true/false
}

Apply CRITIC self-review before reporting done.
</prompt>
<output>.planning/phases/08-data-validation-backtest/outputs/PHASE6_WFA_SETUP.json</output>
</task>

<!-- ROUND 3: Task 6.3 (depends on 6.1, 6.2) -->
<task id="6.3" type="auto" agent="oracle-backtest-commander" round="3">
<name>Monte Carlo Infrastructure</name>
<prompt>
You are ORACLE setting up Monte Carlo simulation infrastructure.

TASK: Configure Monte Carlo framework for statistical validation.

REFERENCE: DOCS/04_REPORTS/VALIDATION/BACKTEST_MASTER_PLAN.md

EXISTING SCRIPT: scripts/oracle/monte_carlo.py (review and enhance)

MONTE CARLO CONFIGURATION (ARGUS Research):

1. BLOCK BOOTSTRAP METHOD
   - Preserve autocorrelation in returns
   - Block size: sqrt(N) where N = number of trades (ARGUS research)
   - Fallback minimum: 10 trades per block
   - Use arch.bootstrap.StationaryBootstrap for implementation

2. SIMULATION PARAMETERS
   - Number of simulations: 5000+
   - Confidence levels: 90%, 95%, 99%
   - Metrics per simulation:
     * Total return
     * Max drawdown
     * Sharpe ratio
     * Win rate

3. OUTPUT DISTRIBUTIONS
   - Drawdown distribution (DD50, DD90, DD95, DD99)
   - Return distribution
   - Risk of Ruin calculation

4. THRESHOLD VALIDATION (APEX-COMPLIANT)
   - MC 95th percentile DD < 4%     # (1% buffer from Apex 5%)
   - Risk of Ruin (5% DD) < 1%      # (Apex termination level)
   - P(Daily DD > 2.5%) < 5%        # (HALT threshold is 3%)
   - P(Total DD > 4.5%) < 2%        # (HALT threshold is 4.5%)
   - Minimum trades: >= 200         # (ARGUS: increased from 100)

5. VISUALIZATION
   - Equity curve cone (confidence bands)
   - Drawdown histogram
   - Return distribution

PRE-MC VALIDATION:
```python
if trade_count < block_size * 5:  # Need 5x for meaningful bootstrap
    raise ValueError(f"Insufficient trades ({trade_count}) for MC block size {block_size}")
```

IMPLEMENTATION:
- Update scripts/oracle/monte_carlo.py
- Create Monte Carlo configuration file (configs/monte_carlo_config.yaml)
- Integrate with backtest results

OUTPUT JSON:
{
  "mc_config": {
    "simulations": 5000,
    "block_size_formula": "sqrt(N)",
    "min_block_size": 10,
    "confidence_levels": [0.90, 0.95, 0.99]
  },
  "thresholds": {
    "mc_dd_95": 0.04,
    "ror_5pct": 0.01,
    "p_daily_dd_breach": 0.05,
    "p_total_dd_breach": 0.02,
    "min_trades": 200
  },
  "script_path": "scripts/oracle/monte_carlo.py",
  "config_path": "configs/monte_carlo_config.yaml",
  "ready_to_execute": true/false
}

Apply CRITIC self-review before reporting done.
</prompt>
<output>.planning/phases/08-data-validation-backtest/outputs/PHASE6_MONTE_CARLO_SETUP.json</output>
</task>
</tasks>

<verification>
After all 3 tasks complete:
1. All 3 JSON files exist in .planning/phases/08-data-validation-backtest/outputs/PHASE6_*.json
2. Task 6.1: BacktestEngine validation PASS
3. Task 6.1: Look-ahead detection test PASS
4. Task 6.2: WFA configuration ready (16 windows)
5. Task 6.3: Monte Carlo configuration ready (5000 sims)
6. All tests pass (mypy --strict, pytest)

TEST PROTOCOL:
```bash
# 1. Unit tests for backtest integration
python -m pytest nautilus_gold_scalper/tests/test_backtest/ -v

# 2. Integration test with sample data
python nautilus_gold_scalper/scripts/run_backtest.py \
  --start 2024-01-01 --end 2024-01-31 --validate

# 3. WFA dry run (1 window only)
python scripts/oracle/walk_forward.py --windows 1 --dry-run

# 4. Monte Carlo dry run (100 sims only)
python scripts/oracle/monte_carlo.py --sims 100 --dry-run
```
</verification>

<success_criteria>
- BacktestEngine validation: PASS
- Look-ahead bias test: PASS (via shuffle test)
- WFA configured: 16 windows
- Monte Carlo ready: 5000 sims with sqrt(N) block size
- Apex compliance verified: All time gates present
- Tests pass: All green
</success_criteria>
