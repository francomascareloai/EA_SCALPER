# Phase 6: Backtest Framework

**Phase ID**: 06
**Status**: ⏳ Pending
**Estimated Agents**: 3 (Sequential)
**Execution Mode**: Sequential (dependencies)
**Model**: opus (all agents)

---

## Objective

Prepare backtesting infrastructure including event-driven engine, Walk-Forward Analysis (WFA) setup, and Monte Carlo simulation framework.

---

## Prerequisites

- All Phase 1-5 completed successfully
- Data fully validated and approved
- Performance benchmarks established

---

## Why Sequential

These tasks have dependencies:
1. Event-driven engine must exist before WFA can use it
2. WFA setup depends on engine capabilities
3. Monte Carlo depends on both

---

## Tasks

### Task 6.1: Event-Driven Backtester

**Agent**: FORGE + NAUTILUS
**Spec**: `.claude/agents/forge-nautilus.md` + `.claude/agents/nautilus-trader-architect.md`
**Model**: opus

**Prompt**:
```
You are FORGE building an event-driven backtester for XAUUSD.

TASK: Implement institutional-grade event-driven backtest engine.

REFERENCE: DOCS/04_REPORTS/VALIDATION/BACKTEST_MASTER_PLAN.md

EXISTING COMPONENTS:
- nautilus_gold_scalper/scripts/run_backtest.py (basic implementation)
- nautilus_gold_scalper/scripts/nautilus_backtest.py (event-driven start)
- BacktestEngine from nautilus_trader.backtest.engine

REQUIREMENTS:

1. EVENT-DRIVEN ARCHITECTURE
   - Process one tick at a time (no vectorized look-ahead)
   - Strategy receives tick, makes decision, engine executes
   - Full trade lifecycle: signal → order → fill → position

2. REALISTIC EXECUTION
   - Configurable spread model (static, dynamic, time-based)
   - Slippage simulation (latency-based)
   - Fill simulation (partial fills, rejection probability)
   - Commission model (maker/taker fees)

3. POSITION MANAGEMENT
   - Track open positions with entry price, size, SL, TP
   - Support multiple positions per instrument
   - Accurate P&L calculation including costs

4. APEX COMPLIANCE
   - Built-in time gate checks (4:30 PM, 4:55 PM, 4:59 PM ET)
   - Trailing DD calculation from high-water mark
   - Daily DD tracking
   - 30% max profit/day enforcement

5. METRICS COLLECTION
   - Per-trade metrics: entry, exit, P&L, duration, slippage
   - Aggregated metrics: win rate, profit factor, Sharpe, max DD
   - Equity curve generation

6. DATA INTEGRATION
   - Load from Nautilus ParquetDataCatalog
   - Support date range filtering
   - Support session filtering

IMPLEMENTATION PATH:
- Enhance nautilus_gold_scalper/scripts/run_backtest.py
- Create nautilus_gold_scalper/backtest/event_engine.py
- Create nautilus_gold_scalper/backtest/execution_models.py
- Create nautilus_gold_scalper/backtest/metrics.py

OUTPUT:
{
  "files_created": [...],
  "files_modified": [...],
  "features_implemented": [...],
  "tests_written": [...],
  "validation_passed": true/false
}

FILE: DOCS/03_RESEARCH/FINDINGS/PHASE6_EVENT_ENGINE.json

Apply CRITIC self-review. Verify no look-ahead bias. Test with sample data.
```

---

### Task 6.2: Walk-Forward Analysis Setup

**Agent**: ORACLE
**Spec**: `.claude/agents/oracle-backtest-commander.md`
**Model**: opus

**Depends on**: Task 6.1 complete

**Prompt**:
```
You are ORACLE setting up Walk-Forward Analysis infrastructure.

TASK: Configure WFA pipeline for robust out-of-sample validation.

REFERENCE: DOCS/04_REPORTS/VALIDATION/BACKTEST_MASTER_PLAN.md

EXISTING SCRIPT: scripts/oracle/walk_forward.py (review and enhance)

WFA CONFIGURATION:

1. DATA SPLIT
   - In-Sample (IS): 80% (training)
   - Out-of-Sample (OOS): 20% (validation)
   - 12 rolling windows

2. WINDOW STRUCTURE (for 2020-2024 data)
   Window 1: IS=Jan 2020-Oct 2020, OOS=Nov-Dec 2020
   Window 2: IS=Mar 2020-Dec 2020, OOS=Jan-Feb 2021
   ... (rolling forward)
   Window 12: IS=Jan 2023-Oct 2023, OOS=Nov-Dec 2023

3. OPTIMIZATION TARGET
   - Optimize on IS data
   - Validate on OOS data
   - Compute Walk-Forward Efficiency (WFE)

4. WFE CALCULATION
   WFE = OOS_performance / IS_performance
   - WFE >= 0.60 required for PASS

5. ADDITIONAL METRICS
   - % of OOS windows profitable
   - OOS Sharpe ratio
   - OOS max drawdown
   - Consistency across windows

IMPLEMENTATION:
- Update scripts/oracle/walk_forward.py
- Create WFA configuration file (YAML)
- Integrate with event-driven engine from 6.1

OUTPUT:
{
  "wfa_config": {
    "windows": 12,
    "is_ratio": 0.8,
    "oos_ratio": 0.2,
    "date_range": ["2020-01-01", "2024-12-31"]
  },
  "script_path": "scripts/oracle/walk_forward.py",
  "config_path": "configs/wfa_config.yaml",
  "ready_to_execute": true/false
}

FILE: DOCS/03_RESEARCH/FINDINGS/PHASE6_WFA_SETUP.json

Apply CRITIC self-review before reporting done.
```

---

### Task 6.3: Monte Carlo Infrastructure

**Agent**: ORACLE
**Spec**: `.claude/agents/oracle-backtest-commander.md`
**Model**: opus

**Depends on**: Task 6.1, 6.2 complete

**Prompt**:
```
You are ORACLE setting up Monte Carlo simulation infrastructure.

TASK: Configure Monte Carlo framework for statistical validation.

REFERENCE: DOCS/04_REPORTS/VALIDATION/BACKTEST_MASTER_PLAN.md

EXISTING SCRIPT: scripts/oracle/monte_carlo.py (review and enhance)

MONTE CARLO CONFIGURATION:

1. BLOCK BOOTSTRAP METHOD
   - Preserve autocorrelation in returns
   - Block size: ~20 trades (tune based on autocorrelation)
   - Resample with replacement

2. SIMULATION PARAMETERS
   - Number of simulations: 5000+
   - Confidence levels: 90%, 95%, 99%
   - Metrics to compute per simulation:
     * Total return
     * Max drawdown
     * Sharpe ratio
     * Win rate

3. OUTPUT DISTRIBUTIONS
   - Drawdown distribution (compute DD95, DD99)
   - Return distribution
   - Risk of Ruin calculation

4. THRESHOLD VALIDATION
   - MC 95th percentile DD < 8%
   - Risk of Ruin (10% DD) < 5%
   - P(Daily DD > 5%) < 5%
   - P(Total DD > 10%) < 2%

5. VISUALIZATION
   - Equity curve cone (confidence bands)
   - Drawdown histogram
   - Return distribution

IMPLEMENTATION:
- Update scripts/oracle/monte_carlo.py
- Create Monte Carlo configuration file
- Integrate with backtest results

OUTPUT:
{
  "mc_config": {
    "simulations": 5000,
    "block_size": 20,
    "confidence_levels": [0.90, 0.95, 0.99]
  },
  "script_path": "scripts/oracle/monte_carlo.py",
  "config_path": "configs/monte_carlo_config.yaml",
  "thresholds": {...},
  "ready_to_execute": true/false
}

FILE: DOCS/03_RESEARCH/FINDINGS/PHASE6_MONTE_CARLO_SETUP.json

Apply CRITIC self-review before reporting done.
```

---

## Success Criteria

| Criterion | Threshold | Priority |
|-----------|-----------|----------|
| Event engine compiles | No errors | CRITICAL |
| No look-ahead bias | Verified | CRITICAL |
| WFA configured | 12 windows | HIGH |
| Monte Carlo ready | 5000 sims | HIGH |
| Tests pass | All green | HIGH |

---

## Deliverables

1. **Event-driven backtest engine** - nautilus_gold_scalper/backtest/
2. **WFA configuration** - configs/wfa_config.yaml
3. **Monte Carlo configuration** - configs/monte_carlo_config.yaml
4. **PHASE6_EVENT_ENGINE.json**
5. **PHASE6_WFA_SETUP.json**
6. **PHASE6_MONTE_CARLO_SETUP.json**
7. **BACKTEST_FRAMEWORK_REPORT.md** - Consolidated summary

---

## Test Protocol

Before proceeding to Phase 7:

```bash
# 1. Unit tests for event engine
python -m pytest nautilus_gold_scalper/tests/test_backtest/ -v

# 2. Integration test with sample data
python nautilus_gold_scalper/scripts/run_backtest.py \
  --start 2024-01-01 --end 2024-01-31 --validate

# 3. WFA dry run (1 window only)
python scripts/oracle/walk_forward.py --windows 1 --dry-run

# 4. Monte Carlo dry run (100 sims only)
python scripts/oracle/monte_carlo.py --sims 100 --dry-run
```

---

## Next Phase

After completion, proceed to [Phase 7: Backtest Execution](./07-PHASE-PLAN.md)
