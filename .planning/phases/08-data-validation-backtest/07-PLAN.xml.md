---
type: plan
description: "Phase 7: Backtest Execution"
phase_id: "07"
status: pending
priority: CRITICAL
model: opus
changelog: "2025-12-17: Added Protocol 0 (Mandatory Delegation)"
---

## ⚠️ MANDATORY DELEGATION (Protocol 0)

> **CRITICAL: The orchestrator MUST NOT run backtests or read large result files directly.**
>
> Phase 7 executes extensive backtests (baseline, WFA, Monte Carlo).
> Sub-agents handle all execution and write results to disk.

### Required Sub-Agent Prompt

```
DELEGATION PROTOCOL (MANDATORY):
1. YOU run backtests and analyze results - orchestrator has NOT
2. Write COMPLETE results to: [output_path]
3. Return ONLY summary (max 300 words) with:
   - Status: PASS/FAIL
   - Key metrics (WFE, SQN, PSR, MC DD 95%, trades count)
   - Apex compliance status
   - Output file path

Plan: .planning/phases/08-data-validation-backtest/07-PLAN.xml.md
```

---

<objective>
Execute comprehensive backtests including:
1. Baseline backtest (IS + OOS)
2. Walk-Forward Analysis (16 windows)
3. Monte Carlo simulations (5000+)
4. Per-session backtests (6 sessions)

REGRA: USE scripts existentes de scripts/oracle/ e nautilus_gold_scalper/scripts/. NÃO crie novos.
Referência: SCRIPT_REGISTRY.md

All backtests must meet CLAUDE.md ml_validation criteria and Apex compliance.
</objective>

<execution_context>
Memory: 12GB system total
- Per-Backtest Memory: ~3 GB max
- Monte Carlo: Process in batches of 500 simulations
- Sessions: Run SEQUENTIALLY (not parallel) due to memory constraints

Execution:
- Round 1: Tasks 7.1, 7.2, 7.4 in parallel (max 3GB each)
- Round 2: Task 7.3 alone (depends on 7.1 output)

Dependencies: Phase 6 completed (framework validated)
Scripts: nautilus_gold_scalper/scripts/run_backtest.py, scripts/oracle/walk_forward.py, scripts/oracle/monte_carlo.py, scripts/oracle/go_nogo_validator.py
Reference: .planning/phases/08-data-validation-backtest/07-PLAN.xml.md
</execution_context>

<context>
- CLAUDE.md for project rules and ml_validation thresholds
- SCRIPT_REGISTRY.md for existing scripts
- .claude/agents/oracle-backtest-commander.md for ORACLE agent
- .claude/agents/scale-runner.md for SCALE-RUNNER agent
- Phase 6 completed (framework validated)
- Strategy: nautilus_gold_scalper/src/strategies/
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
<!-- ROUND 1: Tasks 7.1, 7.2, 7.4 in parallel -->
<task id="7.1" type="auto" agent="oracle-backtest-commander" round="1">
<name>Baseline Backtest</name>
<prompt>
You are ORACLE executing baseline backtest for XAUUSD strategy.

TASK: Run full backtest on in-sample and out-of-sample data.

STRATEGY: nautilus_gold_scalper/src/strategies/
SCRIPT: nautilus_gold_scalper/scripts/run_backtest.py

DATA CONFIGURATION:
- In-Sample: 2020-01-01 to 2023-12-31 (4 years)
- Out-of-Sample: 2024-01-01 to 2024-12-31 (1 year)
- Catalog: data/catalog_native/xauusd_2003_2025_stride1_COMPLETE

EXECUTION:
1. Run backtest on IS period (2020-2023)
2. Record all trades, metrics, equity curve
3. Run backtest on OOS period (2024)
4. Compare IS vs OOS performance

METRICS TO COLLECT:
- Total trades
- Win rate
- Profit factor
- Sharpe ratio
- SQN (System Quality Number) - REQUIRED per CLAUDE.md
- PSR (Probabilistic Sharpe Ratio) - REQUIRED per CLAUDE.md
- Max drawdown
- Average trade duration
- Average profit per trade
- Equity curve data points

APEX COMPLIANCE:
- Verify no trades after 4:30 PM ET
- Verify no overnight positions
- Verify trailing DD never exceeded 4% (BUFFER - Apex limit is 5%)
- Verify no single day > 30% profit
- CRITICAL: Trailing DD calculated from HWM INCLUDING unrealized P/L

OUTPUT JSON:
{
  "is_period": {
    "start": "2020-01-01",
    "end": "2023-12-31",
    "trades": int,
    "win_rate": float,
    "profit_factor": float,
    "sharpe_ratio": float,
    "sqn": float,
    "psr": float,
    "max_dd": float,
    "total_return": float
  },
  "oos_period": {
    "start": "2024-01-01",
    "end": "2024-12-31",
    "trades": int,
    "win_rate": float,
    "profit_factor": float,
    "sharpe_ratio": float,
    "sqn": float,
    "psr": float,
    "max_dd": float,
    "total_return": float
  },
  "is_vs_oos_degradation": float,
  "apex_compliance": {
    "time_gate_violations": int,
    "overnight_violations": int,
    "max_trailing_dd": float,
    "max_daily_profit": float,
    "emergency_close_tested": true/false,
    "compliant": true/false
  },
  "equity_curve_path": "data/backtest_results/baseline_equity.csv"
}

Apply CRITIC self-review before reporting done.
</prompt>
<output>.planning/phases/08-data-validation-backtest/outputs/PHASE7_BASELINE_BACKTEST.json</output>
</task>

<task id="7.2" type="auto" agent="oracle-backtest-commander" round="1">
<name>Walk-Forward Analysis</name>
<prompt>
You are ORACLE executing Walk-Forward Analysis for XAUUSD strategy.

TASK: Run 16-window rolling WFA to validate strategy robustness.

CONFIGURATION:
- Windows: 16 (extended to include full 2020-2024)
- IS ratio: 80%
- OOS ratio: 20%
- Period: 2020-01-01 to 2024-08-31

WFA EXECUTION:

For each window i (1 to 16):
1. Define IS period: months 1-8 of window
2. Define OOS period: months 9-10 of window
3. Optimize on IS (if optimization enabled)
4. Validate on OOS
5. Record metrics for both periods

WINDOW SCHEDULE (2024 reserved for baseline OOS, not WFA training):
Window 1:  IS=2020-01 to 2020-08, OOS=2020-09 to 2020-10
Window 2:  IS=2020-03 to 2020-10, OOS=2020-11 to 2020-12
Window 3:  IS=2020-05 to 2020-12, OOS=2021-01 to 2021-02
Window 4:  IS=2020-07 to 2021-02, OOS=2021-03 to 2021-04
Window 5:  IS=2020-09 to 2021-04, OOS=2021-05 to 2021-06
Window 6:  IS=2020-11 to 2021-06, OOS=2021-07 to 2021-08
Window 7:  IS=2021-01 to 2021-08, OOS=2021-09 to 2021-10
Window 8:  IS=2021-03 to 2021-10, OOS=2021-11 to 2021-12
Window 9:  IS=2021-05 to 2021-12, OOS=2022-01 to 2022-02
Window 10: IS=2021-07 to 2022-02, OOS=2022-03 to 2022-04
Window 11: IS=2021-09 to 2022-04, OOS=2022-05 to 2022-06
Window 12: IS=2021-11 to 2022-06, OOS=2022-07 to 2022-08
Window 13: IS=2022-01 to 2022-08, OOS=2022-09 to 2022-10
Window 14: IS=2022-03 to 2022-10, OOS=2022-11 to 2022-12
Window 15: IS=2022-05 to 2022-12, OOS=2023-01 to 2023-02
Window 16: IS=2022-07 to 2023-02, OOS=2023-03 to 2023-04

METRICS PER WINDOW:
- IS Sharpe, IS Return, IS DD
- OOS Sharpe, OOS Return, OOS DD
- Window WFE = OOS_Return / IS_Return

AGGREGATED METRICS:
- Overall WFE (mean of window WFEs)
- % of OOS windows profitable
- OOS Sharpe consistency (mean and std)
- Max OOS DD across all windows
- Deflated Sharpe Ratio (DSR)
- CPCV score (replaces PBO)
- Probabilistic Sharpe Ratio (PSR)
- Total trades across all windows

THRESHOLDS (ARGUS Research):
- WFE >= 0.60 (CRITICAL)
- OOS Windows Positive >= 70% (HIGH)
- DSR > 0 (HIGH)
- CPCV score >= 0.6 (CRITICAL - replaces PBO)
- PSR >= 0.85 (HIGH - adjusted for fat tails)
- Minimum trades >= 200 (CRITICAL - increased from 100)

OUTPUT JSON:
{
  "windows": [
    {
      "window_id": 1,
      "is_period": {"start": "...", "end": "..."},
      "oos_period": {"start": "...", "end": "..."},
      "is_sharpe": float,
      "is_return": float,
      "oos_sharpe": float,
      "oos_return": float,
      "wfe": float
    },
    ... (16 windows)
  ],
  "aggregate": {
    "mean_wfe": float,
    "oos_windows_positive_pct": float,
    "oos_sharpe_mean": float,
    "oos_sharpe_std": float,
    "max_oos_dd": float,
    "deflated_sharpe_ratio": float,
    "cpcv_score": float,
    "psr": float,
    "total_trades": int
  },
  "thresholds": {
    "wfe_threshold": 0.60,
    "wfe_passed": true/false,
    "oos_positive_threshold": 0.70,
    "oos_positive_passed": true/false,
    "dsr_threshold": 0,
    "dsr_passed": true/false,
    "cpcv_threshold": 0.6,
    "cpcv_passed": true/false,
    "psr_threshold": 0.85,
    "psr_passed": true/false,
    "min_trades_threshold": 200,
    "min_trades_passed": true/false
  },
  "overall_status": "PASS/FAIL"
}

Apply CRITIC self-review before reporting done.
</prompt>
<output>.planning/phases/08-data-validation-backtest/outputs/PHASE7_WFA_RESULTS.json</output>
</task>

<task id="7.4" type="auto" agent="scale-runner" round="1">
<name>Per-Session Backtests</name>
<prompt>
You are SCALE-RUNNER executing per-session backtests.

TASK: Run backtests on each of the 6 trading sessions.

SESSION CATALOGS:
- data/catalog_native_sessions/xauusd_2003_2025_stride1_ASIAN/
- data/catalog_native_sessions/xauusd_2003_2025_stride1_LONDON/
- data/catalog_native_sessions/xauusd_2003_2025_stride1_OVERLAP/
- data/catalog_native_sessions/xauusd_2003_2025_stride1_NY/
- data/catalog_native_sessions/xauusd_2003_2025_stride1_LATE_NY/
- data/catalog_native_sessions/xauusd_2003_2025_stride1_EVENING/

EXECUTION (SEQUENTIAL - memory safety):
Run 6 backtests SEQUENTIALLY, one per session.
Memory budget: 2 GB max per session backtest.
Period: 2020-01-01 to 2024-12-31

PRE-FLIGHT CHECK:
```bash
ls data/catalog_native_sessions/
```
Verify all 6 session catalogs exist before starting.

METRICS PER SESSION:
- Total trades
- Win rate
- Profit factor
- Sharpe ratio
- Max drawdown
- Avg trade duration
- Total return

ANALYSIS:
- Identify best performing sessions
- Identify worst performing sessions
- Session-specific strategy tuning recommendations
- Apex time gate impact (LATE_NY, EVENING)

OUTPUT JSON:
{
  "sessions": {
    "ASIAN": {
      "trades": int,
      "win_rate": float,
      "profit_factor": float,
      "sharpe": float,
      "max_dd": float,
      "total_return": float
    },
    "LONDON": {...},
    "OVERLAP": {...},
    "NY": {...},
    "LATE_NY": {...},
    "EVENING": {...}
  },
  "ranking": ["OVERLAP", "LONDON", "NY", ...],
  "best_session": "...",
  "worst_session": "...",
  "apex_impact": {
    "late_ny_affected": true/false,
    "evening_affected": true/false,
    "recommendation": "..."
  }
}

Apply CRITIC self-review before reporting done.
</prompt>
<output>.planning/phases/08-data-validation-backtest/outputs/PHASE7_SESSION_BACKTESTS.json</output>
</task>

<!-- ROUND 2: Task 7.3 alone (depends on 7.1) -->
<task id="7.3" type="auto" agent="oracle-backtest-commander" round="2">
<name>Monte Carlo Simulation</name>
<prompt>
You are ORACLE executing Monte Carlo simulations for XAUUSD strategy.

TASK: Run 5000+ Monte Carlo simulations to assess statistical robustness.

INPUT: Trade results from baseline backtest (Task 7.1)
PATH: data/backtest_results/baseline/is_trades.csv

PRE-CONDITION: Task 7.1 must be complete. If 7.1 output not found, ABORT with clear error.

MC CONFIGURATION (ARGUS Research):
- Simulations: 5000
- Method: Block Bootstrap (StationaryBootstrap)
- Block size: sqrt(N) where N = trade count
- Minimum block size: 10 trades
- Metrics per simulation: Return, Max DD, Sharpe

EXECUTION:

1. LOAD TRADES
   - Load trade results from baseline backtest
   - Extract: trade P&L, duration, timestamp
   - VALIDATE: If trades < 100, abort MC with "insufficient sample"

2. BLOCK BOOTSTRAP
   - Calculate block size: max(10, sqrt(trade_count))
   - Use arch.bootstrap.StationaryBootstrap for implementation
   - Resample blocks with replacement
   - Reconstruct 5000 synthetic trade sequences

3. COMPUTE METRICS
   For each simulation:
   - Total return
   - Max drawdown
   - Sharpe ratio
   - Final equity

4. STATISTICAL ANALYSIS
   - Return distribution (mean, std, percentiles)
   - Drawdown distribution (DD50, DD90, DD95, DD99)
   - Sharpe distribution
   - Risk of Ruin calculation

THRESHOLDS (APEX-COMPLIANT):
- MC 95th percentile DD < 4% (CRITICAL - 1% buffer from Apex 5%)
- Risk of Ruin (5% DD) < 1% (HIGH - Apex termination)
- P(Daily DD > 2.5%) < 5% (HIGH)
- P(Total DD > 4.5%) < 2% (HIGH - Apex buffer)

INTRA-TRADE DD NOTE:
MC reconstructs equity from closed trade P/L, but real trailing DD includes
unrealized P/L during open trades. Apply 1.3x safety multiplier to MC DD results
OR simulate intra-trade excursions.

OUTPUT JSON:
{
  "config": {
    "simulations": 5000,
    "block_size": int,
    "block_size_formula": "sqrt(N)",
    "input_trades": int
  },
  "return_distribution": {
    "mean": float,
    "std": float,
    "p5": float,
    "p50": float,
    "p95": float
  },
  "drawdown_distribution": {
    "dd_50": float,
    "dd_90": float,
    "dd_95": float,
    "dd_99": float,
    "dd_95_with_safety": float  // dd_95 * 1.3
  },
  "sharpe_distribution": {
    "mean": float,
    "std": float,
    "p5": float
  },
  "risk_of_ruin": {
    "ror_5pct": float,
    "ror_10pct": float,
    "ror_15pct": float
  },
  "thresholds": {
    "dd95_threshold": 0.04,
    "dd95_passed": true/false,
    "ror_5pct_threshold": 0.01,
    "ror_5pct_passed": true/false
  },
  "overall_status": "PASS/FAIL"
}

Apply CRITIC self-review before reporting done.
</prompt>
<output>.planning/phases/08-data-validation-backtest/outputs/PHASE7_MONTE_CARLO_RESULTS.json</output>
</task>
</tasks>

<verification>
After all 4 tasks complete:
1. All 4 JSON files exist in .planning/phases/08-data-validation-backtest/outputs/PHASE7_*.json
2. Task 7.1: Baseline OOS profitable AND Apex compliant
3. Task 7.2: WFE >= 0.60, CPCV >= 0.6, min trades >= 200
4. Task 7.3: MC 95th DD < 4%, RoR(5%) < 1%
5. Task 7.4: All 6 sessions have results
6. Memory peak < 3GB for each task

DATA OUTPUT STRUCTURE:
```
data/backtest_results/
├── baseline/
│   ├── is_trades.csv
│   ├── oos_trades.csv
│   ├── equity_curve.csv
│   └── metrics.json
├── wfa/
│   ├── window_01/
│   ├── window_02/
│   └── ...
├── monte_carlo/
│   ├── simulations.parquet
│   └── distributions.json
└── sessions/
    ├── ASIAN/
    ├── LONDON/
    └── ...
```
</verification>

<success_criteria>
- Baseline OOS profitable: > 0% return (HIGH)
- WFE: >= 0.60 (CRITICAL)
- OOS windows positive: >= 70% (HIGH)
- MC 95th DD: < 4% (CRITICAL)
- Risk of Ruin (5% DD): < 1% (HIGH)
- Apex compliance: 100% (CRITICAL)
- SQN: >= 2.0 AND < 5.0 (CRITICAL - upper bound detects curve-fitting)
- PSR: >= 0.85 (HIGH - adjusted for fat tails)
- CPCV score: >= 0.6 (CRITICAL - replaces PBO)
- Min trades: >= 200 (CRITICAL - increased from 100)
</success_criteria>
