# Phase 7: Backtest Execution

**Phase ID**: 07
**Status**: ⏳ Pending
**Estimated Agents**: 4+ (Full Parallel)
**Execution Mode**: Parallel
**Model**: opus (all agents)

---

## Objective

Execute comprehensive backtests including baseline, Walk-Forward Analysis, Monte Carlo simulations, and per-session testing.

---

## Prerequisites

- Phase 6 completed (framework ready)
- Event-driven engine tested
- WFA and Monte Carlo configured
- All data validated (Phases 2-5)

---

## Orchestration

### Agent Spawn Pattern

All 4 main agents spawn simultaneously:

```
Task[7.1 Baseline] || Task[7.2 WFA] || Task[7.3 Monte Carlo] || Task[7.4 Sessions]
```

Note: Task 7.4 (Sessions) internally spawns 6 sub-tasks for each session.

---

## Tasks

### Task 7.1: Baseline Backtest

**Agent**: ORACLE
**Spec**: `.claude/agents/oracle-backtest-commander.md`
**Model**: opus

**Prompt**:
```
You are ORACLE executing baseline backtest for XAUUSD strategy.

TASK: Run full backtest on in-sample and out-of-sample data.

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
- Max drawdown
- Average trade duration
- Average profit per trade
- Equity curve data points

APEX COMPLIANCE:
- Verify no trades after 4:30 PM ET
- Verify no overnight positions
- Verify trailing DD never exceeded 5%
- Verify no single day > 30% profit

OUTPUT:
{
  "is_period": {
    "start": "2020-01-01",
    "end": "2023-12-31",
    "trades": <int>,
    "win_rate": <float>,
    "profit_factor": <float>,
    "sharpe_ratio": <float>,
    "max_dd": <float>,
    "total_return": <float>
  },
  "oos_period": {
    "start": "2024-01-01",
    "end": "2024-12-31",
    "trades": <int>,
    "win_rate": <float>,
    "profit_factor": <float>,
    "sharpe_ratio": <float>,
    "max_dd": <float>,
    "total_return": <float>
  },
  "is_vs_oos_degradation": <float>,
  "apex_compliance": {
    "time_gate_violations": <int>,
    "overnight_violations": <int>,
    "max_trailing_dd": <float>,
    "max_daily_profit": <float>,
    "compliant": true/false
  },
  "equity_curve_path": "data/backtest_results/baseline_equity.csv"
}

FILE: DOCS/03_RESEARCH/FINDINGS/PHASE7_BASELINE_BACKTEST.json

Apply CRITIC self-review before reporting done.
```

---

### Task 7.2: Walk-Forward Analysis

**Agent**: ORACLE
**Spec**: `.claude/agents/oracle-backtest-commander.md`
**Model**: opus

**Prompt**:
```
You are ORACLE executing Walk-Forward Analysis for XAUUSD strategy.

TASK: Run 12-window rolling WFA to validate strategy robustness.

CONFIGURATION:
- Windows: 12
- IS ratio: 80%
- OOS ratio: 20%
- Period: 2020-01-01 to 2023-12-31

WFA EXECUTION:

For each window i (1 to 12):
1. Define IS period: months 1-8 of window
2. Define OOS period: months 9-10 of window
3. Optimize on IS (if optimization enabled)
4. Validate on OOS
5. Record metrics for both periods

WINDOW SCHEDULE:
Window 1:  IS=2020-01 to 2020-08, OOS=2020-09 to 2020-10
Window 2:  IS=2020-03 to 2020-10, OOS=2020-11 to 2020-12
Window 3:  IS=2020-05 to 2020-12, OOS=2021-01 to 2021-02
... (continue rolling)
Window 12: IS=2023-01 to 2023-08, OOS=2023-09 to 2023-10

METRICS PER WINDOW:
- IS Sharpe, IS Return, IS DD
- OOS Sharpe, OOS Return, OOS DD
- Window WFE = OOS_Return / IS_Return

AGGREGATED METRICS:
- Overall WFE (mean of window WFEs)
- % of OOS windows profitable
- OOS Sharpe consistency
- Max OOS DD across all windows

THRESHOLDS:
- WFE >= 0.60 (CRITICAL)
- OOS Windows Positive >= 70% (HIGH)

OUTPUT:
{
  "windows": [
    {
      "window_id": 1,
      "is_period": {"start": "...", "end": "..."},
      "oos_period": {"start": "...", "end": "..."},
      "is_sharpe": <float>,
      "is_return": <float>,
      "oos_sharpe": <float>,
      "oos_return": <float>,
      "wfe": <float>
    },
    ... (12 windows)
  ],
  "aggregate": {
    "mean_wfe": <float>,
    "oos_windows_positive_pct": <float>,
    "oos_sharpe_mean": <float>,
    "oos_sharpe_std": <float>,
    "max_oos_dd": <float>
  },
  "thresholds": {
    "wfe_threshold": 0.60,
    "wfe_passed": true/false,
    "oos_positive_threshold": 0.70,
    "oos_positive_passed": true/false
  },
  "overall_status": "PASS/FAIL"
}

FILE: DOCS/03_RESEARCH/FINDINGS/PHASE7_WFA_RESULTS.json

Apply CRITIC self-review before reporting done.
```

---

### Task 7.3: Monte Carlo Simulation

**Agent**: ORACLE
**Spec**: `.claude/agents/oracle-backtest-commander.md`
**Model**: opus

**Prompt**:
```
You are ORACLE executing Monte Carlo simulations for XAUUSD strategy.

TASK: Run 5000+ Monte Carlo simulations to assess statistical robustness.

INPUT: Trade results from baseline backtest (Task 7.1)

MC CONFIGURATION:
- Simulations: 5000
- Method: Block Bootstrap
- Block size: 20 trades (preserves autocorrelation)
- Metrics per simulation: Return, Max DD, Sharpe

EXECUTION:

1. LOAD TRADES
   - Load trade results from baseline backtest
   - Extract: trade P&L, duration, timestamp

2. BLOCK BOOTSTRAP
   - Divide trades into blocks of ~20
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

THRESHOLDS:
- MC 95th percentile DD < 8% (CRITICAL)
- Risk of Ruin (10% DD) < 5% (HIGH)
- P(Daily DD > 5%) < 5% (HIGH)
- P(Total DD > 10%) < 2% (HIGH)

OUTPUT:
{
  "config": {
    "simulations": 5000,
    "block_size": 20,
    "input_trades": <int>
  },
  "return_distribution": {
    "mean": <float>,
    "std": <float>,
    "p5": <float>,
    "p50": <float>,
    "p95": <float>
  },
  "drawdown_distribution": {
    "dd_50": <float>,
    "dd_90": <float>,
    "dd_95": <float>,
    "dd_99": <float>
  },
  "sharpe_distribution": {
    "mean": <float>,
    "std": <float>,
    "p5": <float>
  },
  "risk_of_ruin": {
    "ror_5pct": <float>,
    "ror_10pct": <float>,
    "ror_15pct": <float>
  },
  "thresholds": {
    "dd95_threshold": 0.08,
    "dd95_passed": true/false,
    "ror_10pct_threshold": 0.05,
    "ror_10pct_passed": true/false
  },
  "overall_status": "PASS/FAIL"
}

FILE: DOCS/03_RESEARCH/FINDINGS/PHASE7_MONTE_CARLO_RESULTS.json

Apply CRITIC self-review before reporting done.
```

---

### Task 7.4: Per-Session Backtests

**Agent**: SCALE-RUNNER
**Spec**: `.claude/agents/scale-runner.md`
**Model**: opus

**Prompt**:
```
You are SCALE-RUNNER executing parallel per-session backtests.

TASK: Run backtests on each of the 6 trading sessions.

SESSION CATALOGS:
- data/catalog_native_sessions/xauusd_2003_2025_stride1_ASIAN/
- data/catalog_native_sessions/xauusd_2003_2025_stride1_LONDON/
- data/catalog_native_sessions/xauusd_2003_2025_stride1_OVERLAP/
- data/catalog_native_sessions/xauusd_2003_2025_stride1_NY/
- data/catalog_native_sessions/xauusd_2003_2025_stride1_LATE_NY/
- data/catalog_native_sessions/xauusd_2003_2025_stride1_EVENING/

EXECUTION (PARALLEL):
Run 6 backtests simultaneously, one per session.
Period: 2020-01-01 to 2024-12-31

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

OUTPUT:
{
  "sessions": {
    "ASIAN": {
      "trades": <int>,
      "win_rate": <float>,
      "profit_factor": <float>,
      "sharpe": <float>,
      "max_dd": <float>,
      "total_return": <float>
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

FILE: DOCS/03_RESEARCH/FINDINGS/PHASE7_SESSION_BACKTESTS.json

Apply CRITIC self-review before reporting done.
```

---

## Success Criteria

| Criterion | Threshold | Priority |
|-----------|-----------|----------|
| Baseline OOS profitable | > 0% return | HIGH |
| WFE | ≥ 0.60 | CRITICAL |
| OOS windows positive | ≥ 70% | HIGH |
| MC 95th DD | < 8% | CRITICAL |
| Risk of Ruin (10% DD) | < 5% | HIGH |
| Apex compliance | 100% | CRITICAL |

---

## Deliverables

1. **PHASE7_BASELINE_BACKTEST.json** - Baseline results
2. **PHASE7_WFA_RESULTS.json** - Walk-forward analysis
3. **PHASE7_MONTE_CARLO_RESULTS.json** - Monte Carlo statistics
4. **PHASE7_SESSION_BACKTESTS.json** - Per-session results
5. **data/backtest_results/** - Raw data files
6. **BACKTEST_EXECUTION_REPORT.md** - Consolidated summary

---

## Data Output Structure

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

---

## Next Phase

After completion, proceed to [Phase 8: GO/NO-GO Decision](./08-PHASE-PLAN.md)
