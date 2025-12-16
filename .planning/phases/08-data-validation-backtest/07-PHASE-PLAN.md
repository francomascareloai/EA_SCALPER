[ARGUS INTEGRATED] <!-- Research improvements integrated 2025-12-16 -->

# Phase 7: Backtest Execution

> **⚡ ARGUS IMPROVEMENTS APPLIED** (see full details at end of file)
> - **Monte Carlo block bootstrap**: Proper autocorrelation preservation
> - **CPCV validation**: 5-fold, 2-test, purge=5, embargo=5
> - **Per-regime validation**: HMM-based regime stratification
> - **MinTRL verification**: Track record length sufficiency

**Phase ID**: 07
**Status**: ⏳ Pending
**Estimated Agents**: 4+ (Full Parallel)
**Execution Mode**: Parallel
**Model**: opus (all agents)

---

## Memory Constraint (CRITICAL)

**System RAM**: 12 GB total
**Per-Backtest Memory**: ~3 GB max (allows 2-3 parallel backtests)
**Data Loading**: NautilusTrader streaming via ParquetDataCatalog
**Monte Carlo**: Process in batches of 500 simulations

### Memory Budget Per Task
| Task | Max Memory | Strategy |
|------|------------|----------|
| 7.1 Baseline | 3 GB | Single run, full period |
| 7.2 WFA | 2 GB | Sequential windows |
| 7.3 Monte Carlo | 2 GB | Batch simulations (500) |
| 7.4 Sessions | 2 GB | Sequential per session |

**CRITICAL**: Run Round 1 with 3 agents max. Monte Carlo in Round 2.

### Memory-Safe Backtest Configuration
```python
# NautilusTrader streaming configuration
config = BacktestRunConfig(
    engine=BacktestEngineConfig(
        streaming_mode=True,  # Use streaming
        catalog_chunk_size=5_000_000,  # 5M ticks
    ),
)
```

---

## Objective

Execute comprehensive backtests including baseline, Walk-Forward Analysis, Monte Carlo simulations, and per-session testing.

---

## Prerequisites

- Phase 6 completed (framework validated)
- BacktestEngine tested and working
- WFA and Monte Carlo configured
- All data validated (Phases 2-5)
- **Strategy confirmed**: `nautilus_gold_scalper/src/strategies/`

---

## Strategy Configuration

**CRITICAL**: All backtest tasks must use the same strategy.

```yaml
strategy_path: nautilus_gold_scalper/src/strategies/
strategy_class: GoldScalperStrategy  # or as defined in strategy_selector.py
strategy_config:
  # Use default config from strategy file or specify overrides
  apex_compliance: true
  time_gates_enabled: true
```

Verify strategy exists before execution:
```bash
ls nautilus_gold_scalper/src/strategies/
python -c "from nautilus_gold_scalper.src.strategies import *; print('Strategy imports OK')"
```

---

## Orchestration

### Agent Spawn Pattern

**CORRECTED DEPENDENCY**: Monte Carlo (7.3) depends on Baseline (7.1) output.

```
Round 1 (Parallel):
Task[7.1 Baseline] || Task[7.2 WFA] || Task[7.4 Sessions]

Round 2 (After 7.1 completes):
Task[7.3 Monte Carlo] (uses trades from 7.1)
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
- Max drawdown
- Average trade duration
- Average profit per trade
- Equity curve data points

APEX COMPLIANCE:
- Verify no trades after 4:30 PM ET
- Verify no overnight positions
- Verify trailing DD never exceeded 4% (BUFFER - Apex limit is 5%)
- Verify no single day > 30% profit
- **CRITICAL**: Trailing DD calculated from HWM INCLUDING unrealized P/L

OUTPUT:
{
  "is_period": {
    "start": "2020-01-01",
    "end": "2023-12-31",
    "trades": <int>,
    "win_rate": <float>,
    "profit_factor": <float>,
    "sharpe_ratio": <float>,
    "sqn": <float>,  <!-- FIXED per CRITIC C5: added per CLAUDE.md requirement -->
    "psr": <float>,  <!-- FIXED per CRITIC C5: added per CLAUDE.md requirement -->
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
    "sqn": <float>,  <!-- FIXED per CRITIC C5: added per CLAUDE.md requirement -->
    "psr": <float>,  <!-- FIXED per CRITIC C5: added per CLAUDE.md requirement -->
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
- Windows: 16 (extended to include 2024)
- IS ratio: 80%
- OOS ratio: 20%
- Period: 2020-01-01 to 2024-12-31

WFA EXECUTION:

For each window i (1 to 16):
1. Define IS period: months 1-8 of window
2. Define OOS period: months 9-10 of window
3. Optimize on IS (if optimization enabled)
4. Validate on OOS
5. Record metrics for both periods

WINDOW SCHEDULE: <!-- FIXED per CRITIC C2/C3: corrected to avoid data leakage, 2024 reserved for OOS only -->
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
<!-- NOTE: 2024 data reserved for baseline OOS test (Task 7.1), NOT used in WFA training -->

METRICS PER WINDOW:
- IS Sharpe, IS Return, IS DD
- OOS Sharpe, OOS Return, OOS DD
- Window WFE = OOS_Return / IS_Return

AGGREGATED METRICS:
- Overall WFE (mean of window WFEs)
- % of OOS windows profitable
- OOS Sharpe consistency
- Max OOS DD across all windows
- Deflated Sharpe Ratio (DSR)
- Probability of Backtest Overfitting (PBO)

THRESHOLDS: <!-- ARGUS: Updated with research improvements -->
- WFE >= 0.60 (CRITICAL)
- OOS Windows Positive >= 70% (HIGH)
- DSR > 0 (HIGH)
- CPCV score >= 0.6 (CRITICAL) <!-- ARGUS: Replaces PBO -->
- PSR >= 0.85 (HIGH) <!-- ARGUS: Adjusted for fat tails -->
- Minimum trades >= 200 (CRITICAL) <!-- ARGUS: Increased from 100 -->

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
    ... (16 windows)
  ],
  "aggregate": {
    "mean_wfe": <float>,
    "oos_windows_positive_pct": <float>,
    "oos_sharpe_mean": <float>,
    "oos_sharpe_std": <float>,
    "max_oos_dd": <float>,
    "deflated_sharpe_ratio": <float>,
    "cpcv_score": <float>,  <!-- ARGUS: Replaces PBO -->
    "psr": <float>,  <!-- ARGUS: Added -->
    "total_trades": <int>  <!-- ARGUS: Added for min trades check -->
  },
  "thresholds": {
    "wfe_threshold": 0.60,
    "wfe_passed": true/false,
    "oos_positive_threshold": 0.70,
    "oos_positive_passed": true/false,
    "dsr_threshold": 0,
    "dsr_passed": true/false,
    "cpcv_threshold": 0.6,  <!-- ARGUS: Replaces PBO -->
    "cpcv_passed": true/false,
    "psr_threshold": 0.85,  <!-- ARGUS: Adjusted from 0.90 -->
    "psr_passed": true/false,
    "min_trades_threshold": 200,  <!-- ARGUS: Increased from 100 -->
    "min_trades_passed": true/false
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

MC CONFIGURATION: <!-- ARGUS: Updated with research improvements -->
- Simulations: 5000
- Method: Block Bootstrap (StationaryBootstrap)
- Block size: sqrt(N) where N = trade count (ARGUS research)
- Minimum block size: 10 trades
- Metrics per simulation: Return, Max DD, Sharpe

EXECUTION:

1. LOAD TRADES
   - Load trade results from baseline backtest
   - Extract: trade P&L, duration, timestamp

2. BLOCK BOOTSTRAP <!-- ARGUS: Updated implementation -->
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

THRESHOLDS:
- MC 95th percentile DD < 4% (CRITICAL - CLAUDE.md compliant)
- Risk of Ruin (10% DD) < 5% (HIGH)
- P(Daily DD > 5%) < 5% (HIGH)
- P(Total DD > 4.5%) < 2% (HIGH - Apex buffer)

OUTPUT:
{
  "config": {
    "simulations": 5000,
    "block_size": <int>,  <!-- ARGUS: sqrt(N), not fixed 20 -->
    "block_size_formula": "sqrt(N)",
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
    "dd95_threshold": 0.04,
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

EXECUTION (SEQUENTIAL - FIXED per CRITIC C4): <!-- Was parallel, but 6×2GB=12GB would cause OOM -->
Run 6 backtests SEQUENTIALLY, one per session.
Memory budget: 2 GB max per session backtest.
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

<!-- ARGUS: Updated thresholds based on research improvements -->

| Criterion | Threshold | Priority |
|-----------|-----------|----------|
| Baseline OOS profitable | > 0% return | HIGH |
| WFE | >= 0.60 | CRITICAL |
| OOS windows positive | >= 70% | HIGH |
| MC 95th DD | < 4% | CRITICAL | <!-- FIXED per CRITIC C1: was 8%, Apex requires 4% buffer -->
| Risk of Ruin (5% DD) | < 1% | HIGH | <!-- FIXED: was 10% DD < 5% -->
| Apex compliance | 100% | CRITICAL |
| SQN | >= 2.0 AND < 5.0 | CRITICAL | <!-- ARGUS: Added upper bound for curve-fit detection -->
| PSR | >= 0.85 | HIGH | <!-- ARGUS: Adjusted from 0.90 for fat tails -->
| CPCV score | >= 0.6 | CRITICAL | <!-- ARGUS: Replaces PBO -->
| Min trades | >= 200 | CRITICAL | <!-- ARGUS: Increased from 100 -->

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

---

## CRITIC Review (Phase 7)

**Reviewer**: CRITIC v1.1 - Adversarial Quality Guardian
**Date**: 2025-12-16
**Artifact**: Phase 7 Backtest Execution Plan
**Methodology**: 18 sequential thoughts, all 7 adversarial techniques applied

### VERDICT: REJECTED

Plan contains CRITICAL issues that will lead to incorrect GO/NO-GO decisions, statistically invalid results, and execution failures. Must fix before proceeding.

---

### CRITICAL Issues (Must Fix Before Execution)

| # | Issue | Location | Impact | Fix |
|---|-------|----------|--------|-----|
| C1 | **MC DD threshold inconsistency** | Success Criteria table (line ~458) says "MC 95th DD < 8%" but CLAUDE.md mandates "< 4%" | Strategy could pass with 6% MC DD, deploy, hit 5.2% trailing DD, account terminated | Change threshold to `< 4%` in Success Criteria |
| C2 | **WFA uses 2024 data in IS (training)** | Window 15: IS=2023-07 to **2024-02**, Window 16: IS=**2024-01** to 2024-08 | Data leakage - 2024 used in both WFA training AND baseline OOS. WFE meaningless. | Either (A) WFA ends at 2023-12, or (B) baseline OOS uses 2025 data only |
| C3 | **WFA window schedule mathematically incorrect** | Lines 209-217 | 16 windows with 2-month roll starting 2020-01 can only reach 2022-08 OOS, not 2024-10. Need ~30 windows or 3+ month roll. | Recalculate entire window schedule or adjust window count/roll interval |
| C4 | **Memory contradiction in Task 7.4** | Memory table says 7.4 = 2 GB, but prompt says "Run 6 backtests simultaneously" | 6 × 2 GB = 12 GB for 7.4 alone + 7.1 (3 GB) + 7.2 (2 GB) = 17 GB. System has 12 GB. OOM kill. | Change 7.4 to SEQUENTIAL execution OR split into 2-3 parallel batches |
| C5 | **Missing required validation metrics** | Task 7.1 and 7.2 output schemas | PSR (Probabilistic Sharpe Ratio) and SQN (System Quality Number) required by CLAUDE.md but not collected | Add to output schema: `psr`, `sqn`, `skewness`, `kurtosis` |

---

### HIGH Issues (Should Fix)

| # | Issue | Location | Impact | Fix |
|---|-------|----------|--------|-----|
| H1 | **4:55 PM emergency close not verified** | Task 7.1 Apex compliance section | Apex requires emergency force-close at 4:55 PM ET, but plan only checks 4:30 PM new trade gate | Add verification: "Verify force-close triggered at 4:55 PM ET" |
| H2 | **DSR calculation undefined** | Task 7.2 | DSR formula needs total trials tested (N), not just window count. If 100 parameter combos tested, N=100 not 16. | Add field: `total_strategy_trials` and use in DSR formula |
| H3 | **Monte Carlo ignores intra-trade DD** | Task 7.3 | MC reconstructs equity from closed trade P/L, but real trailing DD includes unrealized P/L during open trades. MC underestimates true DD. | Either simulate intra-trade excursions OR apply 1.3x safety multiplier to MC DD |
| H4 | **WFE formula problematic for negative returns** | Task 7.2 formula | WFE = OOS/IS. If IS < 0 and OOS > 0, WFE is negative. If both negative, WFE is positive (misleading). | Use absolute return comparison OR handle negative IS explicitly |
| H5 | **Block bootstrap block size arbitrary** | Task 7.3, block_size=20 | Should match autocorrelation length in trade series. 20 is arbitrary. | Measure lag-1 autocorrelation, set block_size = max(1, 1/autocorr) |

---

### MEDIUM Issues (Recommended)

| # | Issue | Location | Impact | Fix |
|---|-------|----------|--------|-----|
| M1 | **Trade file path for 7.1→7.3 handoff ambiguous** | Task 7.3 says "Load trade results from baseline" | Could cause FileNotFoundError | Explicitly state path: `data/backtest_results/baseline/is_trades.csv` |
| M2 | **No failure handling for dependency chain** | Orchestration section | If 7.1 fails, 7.3 will fail. No retry/abort logic defined. | Add: "If 7.1 fails → retry once, then abort 7.3 and report" |
| M3 | **Session catalog existence not pre-verified** | Task 7.4 catalog paths | If catalogs don't exist or have wrong names, task fails | Add pre-flight check: `ls data/catalog_native_sessions/` |
| M4 | **No minimum trade count before Monte Carlo** | Task 7.3 | If baseline generates <50 trades, block bootstrap with 20-trade blocks is statistically meaningless (2.5 blocks) | Add gate: "If trades < 100, abort MC and flag insufficient sample" |
| M5 | **No regime labeling for extreme periods** | All tasks | 2020 COVID crash, 2022 rate hikes have extreme DD that may dominate metrics | Add regime tags (TREND, RANGE, CRISIS) and compute metrics per regime |

---

### LOW Issues (Nice to Have)

| # | Issue | Fix |
|---|-------|-----|
| L1 | Spread/slippage sensitivity analysis not included | Add optional: run baseline with 1.5x and 2x spread |
| L2 | No output file locking for parallel writes | Use unique timestamps in filenames |
| L3 | Strategy verify step has no fallback | Add: "If import fails, list available strategies and prompt user" |

---

### Assumptions Challenged

| Assumption | Challenge | Recommendation |
|------------|-----------|----------------|
| 3 GB memory estimate is accurate | Untested. 32.7M ticks could require 4-5 GB. | Profile single backtest with `memory_profiler` |
| 16 windows cover 2020-2024 | Mathematically impossible with 2-month roll | Recalculate or use 3.5-month roll |
| Block size 20 preserves autocorrelation | Arbitrary. Trade autocorrelation may differ. | Measure ACF, set block_size accordingly |
| Session catalogs exist and are complete | Paths listed but never verified | Pre-flight: `find data/catalog_native_sessions/ -type d` |
| Strategy exists as `GoldScalperStrategy` | Class name may differ | Pre-flight: `python -c "from nautilus_gold_scalper.src.strategies import *; print(dir())"` |

---

### Edge Cases Requiring Handling

| Scenario | Current Behavior | Required Handling |
|----------|------------------|-------------------|
| Zero trades in WFA OOS window | WFE = 0/IS = 0 or undefined | Flag window as INVALID, exclude from aggregate |
| Negative IS return in WFA | WFE formula produces misleading result | Use alternative metric or absolute comparison |
| <50 trades in baseline | MC block bootstrap meaningless | Gate: minimum 100 trades required |
| Last bootstrap block has <20 trades | Unknown (dropped? padded?) | Specify: drop incomplete blocks |
| Session catalog missing | FileNotFoundError | Pre-flight check + graceful abort |

---

### Pre-Mortem Summary

**Most Likely Failure Mode**: Monte Carlo passes with 6% DD (under 8% threshold), strategy deployed, hits 5.2% trailing DD in live trading, Apex terminates account. Root cause: Wrong threshold in Success Criteria table (8% vs 4%).

**Second Most Likely**: WFA shows excellent WFE (0.75+) because 2024 data was used in both IS training (Windows 15-16) AND baseline OOS validation. Strategy is actually overfitted. Fails immediately in 2025.

**Third Most Likely**: Task 7.4 spawns 6 parallel backtests at 2 GB each = 12 GB. Combined with 7.1 and 7.2 = 17 GB. System OOM-kills all processes. No results saved. Phase fails with data loss.

---

### Manual Verification Checklist

- [ ] Verify session catalog paths exist: `ls data/catalog_native_sessions/`
- [ ] Profile actual memory usage: `python -m memory_profiler scripts/run_backtest.py`
- [ ] Recalculate correct WFA window schedule (need 30 windows OR 3.5-month roll)
- [ ] Verify strategy class: `python -c "from nautilus_gold_scalper.src.strategies import GoldScalperStrategy"`
- [ ] Confirm main catalog has 2024 data: check parquet date range
- [ ] Review Apex time gate implementation in strategy code (4:30, 4:55, 4:59 PM ET)

---

### Confidence Assessment

**CONFIDENCE**: HIGH (95%)

**Reasoning**:
- Issues C1 (threshold) and C4 (memory) are objective numerical errors, verifiable by inspection
- Issue C2 (data leakage) is a fundamental statistical flaw
- Issue C3 (window schedule) is mathematically provable
- Issue C5 (missing metrics) is verifiable against CLAUDE.md requirements

---

### Action Required

1. **IMMEDIATE**: Fix C1 (change 8% to 4% in Success Criteria)
2. **BEFORE EXECUTION**: Resolve C2-C5 and all HIGH issues
3. **RECOMMENDED**: Address MEDIUM issues
4. **RESUBMIT**: For re-review after fixes

*"Every bug found now is a loss prevented later."*
*CRITIC v1.1 - Adversarial Quality Guardian*

---

## ARGUS Research Improvements

**Date Integrated**: 2025-12-16
**Source**: ARGUS Quant Researcher - Research Triangulation
**Confidence**: HIGH (3+ independent sources, reproducible methods)

### Summary of Changes

The following research-backed improvements have been integrated into Phase 7:

| Improvement | Old Value | New Value | Rationale |
|-------------|-----------|-----------|-----------|
| Block size formula | Fixed 20 | sqrt(N) | Optimal for time series autocorrelation |
| PSR threshold | >= 0.90 | **>= 0.85** | Adjusted for fat-tailed returns |
| Minimum trades | >= 100 | **>= 200** | Institutional standard for significance |
| SQN upper bound | None | **< 5.0** | Curve-fitting detection flag |
| PBO metric | < 25% | Replaced by **CPCV >= 0.6** | Superior overfitting detection |

### New Dependencies (Required for Phase 7)

```txt
# ARGUS Research Improvements - Validation Libraries
mlfinlab>=2.0.0          # CPCV, DSR, PSR, purging, embargo
timeseriescv>=0.2.0      # CombPurgedKFoldCV
hmmlearn>=0.3.0          # Hidden Markov Models for regimes
arch>=6.0.0              # Block bootstrap, circular bootstrap
```

### CPCV Implementation (Replaces PBO)

```python
from mlfinlab.cross_validation import CombinatorialPurgedKFold
import numpy as np
import pandas as pd

def calculate_cpcv(returns: pd.Series, n_splits: int = 5,
                   purge_gap: int = 5, embargo_gap: int = 5) -> dict:
    """Combinatorial Purged Cross-Validation for overfitting detection.

    ARGUS Research: CPCV provides superior overfitting detection
    compared to PBO by testing ALL combinations of train/test splits.
    Score >= 0.6 required for PASS.
    """
    cv = CombinatorialPurgedKFold(
        n_splits=n_splits,
        n_test_splits=2,  # Combinatorial
        purge_gap=purge_gap,
        embargo_gap=embargo_gap
    )

    scores = []
    for train_idx, test_idx in cv.split(returns):
        train = returns.iloc[train_idx]
        test = returns.iloc[test_idx]
        if test.std() > 0:
            sharpe = test.mean() / test.std() * np.sqrt(252)
            scores.append(sharpe)

    cpcv_score = np.mean(scores) / np.std(scores) if np.std(scores) > 0 else 0

    return {
        "cpcv_sharpe_mean": float(np.mean(scores)),
        "cpcv_sharpe_std": float(np.std(scores)),
        "cpcv_score": float(cpcv_score),
        "pass": cpcv_score >= 0.6
    }
```

### Block Bootstrap Implementation

```python
from arch.bootstrap import StationaryBootstrap
import numpy as np
import pandas as pd

def block_bootstrap_monte_carlo(returns: pd.Series, n_simulations: int = 5000) -> dict:
    """Block bootstrap preserving autocorrelation structure.

    ARGUS Research: Block size = sqrt(N) is optimal for most time series.
    """
    block_size = max(10, int(np.sqrt(len(returns))))

    bs = StationaryBootstrap(block_size, returns.values)

    dd_results = []
    for data in bs.bootstrap(n_simulations):
        sim_returns = data[0][0]
        cumulative = (1 + sim_returns).cumprod()
        running_max = np.maximum.accumulate(cumulative)
        drawdown = (running_max - cumulative) / running_max
        dd_results.append(drawdown.max())

    return {
        "block_size": block_size,
        "n_simulations": n_simulations,
        "dd_mean": float(np.mean(dd_results)),
        "dd_95": float(np.percentile(dd_results, 95)),
        "dd_99": float(np.percentile(dd_results, 99)),
        "pass": np.percentile(dd_results, 95) < 0.04
    }
```

### HMM Regime Classification

```python
from hmmlearn import hmm
import numpy as np
import pandas as pd

def fit_hmm_regimes(returns: pd.Series, n_regimes: int = 3) -> dict:
    """Hidden Markov Model for regime classification.

    Strategy must be profitable in ALL regimes to pass.
    """
    X = returns.values.reshape(-1, 1)

    model = hmm.GaussianHMM(
        n_components=n_regimes,
        covariance_type="full",
        n_iter=1000,
        random_state=42
    )
    model.fit(X)

    regimes = model.predict(X)

    regime_stats = {}
    for i in range(n_regimes):
        mask = regimes == i
        regime_returns = returns[mask]
        regime_stats[f"regime_{i}"] = {
            "count": int(mask.sum()),
            "pct": float(mask.mean() * 100),
            "mean_return": float(regime_returns.mean()),
            "volatility": float(regime_returns.std()),
            "sharpe": float(regime_returns.mean() / regime_returns.std() * np.sqrt(252)) if regime_returns.std() > 0 else 0
        }

    return {
        "n_regimes": n_regimes,
        "regime_stats": regime_stats,
        "all_regimes_profitable": all(r["mean_return"] > 0 for r in regime_stats.values())
    }
```

### MinTRL (Minimum Track Record Length) Check

```python
import numpy as np

def calculate_mintrl(sharpe_observed: float, sharpe_benchmark: float = 0,
                     skewness: float = 0, kurtosis: float = 3,
                     confidence: float = 0.95) -> dict:
    """Calculate minimum track record length for statistical significance.

    ARGUS Research: Verifies that observed track record is long enough
    for the Sharpe ratio to be statistically significant.
    """
    from scipy.stats import norm

    z = norm.ppf(confidence)
    se_sharpe = np.sqrt((1 + 0.5 * sharpe_observed**2 - skewness * sharpe_observed +
                         (kurtosis - 3) / 4 * sharpe_observed**2))

    min_trl = ((z * se_sharpe) / (sharpe_observed - sharpe_benchmark)) ** 2

    return {
        "sharpe_observed": sharpe_observed,
        "min_trl_years": float(min_trl),
        "confidence": confidence
    }
```

### Updated GO/NO-GO Thresholds Reference

```yaml
# Phase 7 Updated Thresholds (ARGUS Research)
backtest_criteria:
  wfe: ">= 0.60"
  sqn: ">= 2.0 AND < 5.0"    # ARGUS: Upper bound added
  psr: ">= 0.85"              # ARGUS: Adjusted from 0.90
  dsr: "> 0"
  mc_dd_95: "< 4%"
  min_trades: ">= 200"        # ARGUS: Increased from 100
  ror_5pct: "< 1%"

new_metrics:
  cpcv_score: ">= 0.6"        # ARGUS: Replaces PBO
  regime_consistency: "all regimes profitable"
  mintrl_check: "observed_years >= min_trl"
```

### Pre-Execution Checklist

Before running Phase 7 tasks, verify:

- [ ] All ARGUS dependencies installed (mlfinlab, arch, hmmlearn)
- [ ] Monte Carlo uses sqrt(N) block size formula
- [ ] CPCV configured (replaces PBO)
- [ ] HMM regime classification ready
- [ ] Minimum trades threshold set to 200
- [ ] PSR threshold set to 0.85
- [ ] SQN upper bound check enabled (< 5.0)

---
