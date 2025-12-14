# Realistic Backtest Validation Plan

<metadata>
<confidence>HIGH</confidence>
<strategies_covered>1</strategies_covered>
<test_scenarios>16</test_scenarios>
<estimated_duration>20 days</estimated_duration>
<created>2025-12-07</created>
<version>1.1</version>
<updated>2025-12-07</updated>
<changelog>v1.1: Fixed WFA rolling windows (18 folds), tightened WFE to 0.60, corrected metadata, added compliance validation, added realism calibration, updated timeline</changelog>
</metadata>

## Executive Summary

This plan defines a rigorous 7-phase validation framework for the EA_SCALPER_XAUUSD NautilusTrader strategies before Apex Trading live deployment. Based on findings from audits 001-004, **critical P0 issues must be fixed before validation can begin**.

**Current State Assessment:**
- **Migration Status**: 87.5% complete (35/40 modules functional)
- **Backtest Realism**: 5/10 (costs and cutoff in place; depth/latency still idealized)
- **Apex Compliance**: 3/10 (NO-GO - missing time constraints, consistency rule, circuit breaker integration)
- **Data Source**: Dukascopy recommended (20+ years free tick data, realistic spreads)

**Critical Path**: Fix P0 blockers (4.25 days) → Data preparation + realism calibration (2.5 days) → Baseline backtest + Apex validation (2.5 days) → WFA 18 folds + Apex validation (4 days) → Monte Carlo + Apex validation (2.5 days) → GO/NO-GO decision (1 day) → Paper trading (30 days)

**Success Criteria**: All core metrics ≥ minimum thresholds, 0 Apex violations across all phases, WFE ≥ 0.60 (target) or ≥ 0.50 (minimum), Monte Carlo 95th percentile DD < 8%, realism calibrated from data

---

## Prerequisites (from Audits)

### Issues to Fix BEFORE Testing (P0 Blockers)

Based on audits 001-004, these issues MUST be resolved before validation:

#### From Audit 001 (Nautilus Migration)
| Issue | File | Fix Required | Effort |
|-------|------|--------------|--------|
| ORACLE Bug #2 | gold_scalper_strategy.py:67 | Change `execution_threshold: int = 65` → `70` | 0.25 hr |
| ORACLE Bug #4 | confluence_scorer.py | Enforce `confluence_min_score` from config | 1 hr |
| MTF Manager duplication | indicators/ vs signals/ | Consolidate to single implementation | 2 hr |
| NinjaTrader adapter stub | ninjatrader_adapter.py | Implement for live trading (P1, not blocker for backtest) | 8-12 hr |

#### From Audit 003 (Backtest Code)
| Issue | Module | Fix Required | Effort |
|-------|--------|--------------|--------|
| CircuitBreaker orphaned | gold_scalper_strategy.py | Integrate into signal path | 2 hr |
| StrategySelector unused | runners | Wire into backtest flow | 2 hr |
| EntryOptimizer unused | strategy | Integrate for GENIUS v4.2 | 2 hr |
| DrawdownTracker wall-clock | drawdown_tracker.py | Use backtest clock for daily reset | 1 hr |
| YAML realism knobs ignored | runners | Load slippage/commission/latency from config | 2 hr |
| No Sharpe/Sortino/Calmar/SQN | metrics | Implement telemetry outputs | 3 hr |

#### From Audit 004 (Apex Risk) - CRITICAL
| Issue | Impact | Fix Required | Effort |
|-------|--------|--------------|--------|
| NO time constraints | Account termination risk | Implement TimeConstraintManager with 4:59 PM ET deadline | 16 hr |
| NO consistency rule | Account termination risk | Implement 30% daily profit limit tracking | 8 hr |
| CircuitBreaker not integrated | Higher DD breach risk | Wire into pre-trade checks | 4 hr |
| Unrealized P&L uncertain | Wrong DD calculation | Verify and document inclusion | 4 hr |
| No account termination | Breach continues | Add TERMINATE_ACCOUNT() on DD > 10% | 2 hr |

**Total P0 Effort**: ~34 hours (4.25 days)

### Data Source (from Audit 002)

**Primary**: **Dukascopy** (APPROVED)
- 20+ years XAUUSD tick data (2003-present)
- True bid/ask with realistic spreads (20-50 cents)
- Free, well-validated by quant community

**Backup**: **FXCM** (for cross-validation)
- 10 years data (2015-present)
- Different liquidity source

**QC Checklist** (must pass before use):
- [ ] Convert timestamps to ET, enforce flat book by 4:59 PM ET Friday
- [ ] Max gap ≤ 60 seconds intraday
- [ ] Median spread: 0.20-0.50 USD
- [ ] 99th percentile spread < 1.00 USD (except news)
- [ ] Deduplicate identical timestamps/quotes

### Apex Compliance Status (from Audit 004)

**Current Score: 3/10** - Must reach 10/10 before live trading

| Rule | Required | Implemented | Status |
|------|----------|-------------|--------|
| Trailing DD 10% from HWM | YES | ✅ Yes (PropFirmManager) | PASS |
| Unrealized P&L in DD | YES | ❓ Unverified | VERIFY |
| 4:59 PM ET deadline | YES | ❌ Missing | FIX |
| No overnight positions | YES | ❌ Missing | FIX |
| Consistency 30% max | YES | ❌ Missing | FIX |
| Circuit breaker | YES | ❌ Orphaned | INTEGRATE |
| Account termination on breach | YES | ⚠️ Partial | ENHANCE |

---

## Test Scenarios

### 1. Normal Market Conditions

#### 1.1 Trending Bull Market
| Parameter | Value |
|-----------|-------|
| **Date Range** | 2020-04-01 to 2020-08-31 (Gold rally) |
| **Characteristics** | Strong uptrend, ATR 25-35, normal spreads |
| **Expected Behavior** | Long signals dominate, high win rate, steady equity curve |
| **Success Metrics** | Win rate > 60%, Profit Factor > 2.0, Max DD < 5% |

#### 1.2 Trending Bear Market
| Parameter | Value |
|-----------|-------|
| **Date Range** | 2021-06-01 to 2021-08-31 (Gold correction) |
| **Characteristics** | Sustained downtrend, ATR 20-30 |
| **Expected Behavior** | Short signals dominate, controlled exits |
| **Success Metrics** | Win rate > 55%, Profit Factor > 1.8, Max DD < 6% |

#### 1.3 Range-Bound Market
| Parameter | Value |
|-----------|-------|
| **Date Range** | 2022-04-01 to 2022-07-31 (Consolidation) |
| **Characteristics** | Sideways movement, ATR 18-25 |
| **Expected Behavior** | Reduced trade frequency, mean-reversion signals |
| **Success Metrics** | Win rate > 50%, Profit Factor > 1.5, Max DD < 5% |

#### 1.4 London/NY Overlap Session
| Parameter | Value |
|-----------|-------|
| **Date Range** | Any 3-month period, 8:00 AM - 12:00 PM ET only |
| **Characteristics** | Highest liquidity, tightest spreads (15-25 cents) |
| **Expected Behavior** | Best execution quality, lowest slippage |
| **Success Metrics** | Avg spread < 25 cents, Fill rate > 98%, Avg slippage < 10 cents |

### 2. Stress Conditions

#### 2.1 COVID-19 Crash (Extreme Volatility)
| Parameter | Value |
|-----------|-------|
| **Date Range** | 2020-03-01 to 2020-03-31 |
| **Characteristics** | ATR > 60, spreads 50-200+ cents, gap events |
| **Expected Behavior** | Circuit breaker triggers, reduced position sizes, potential trading halt |
| **Success Metrics** | Max DD < 8%, No Apex violations, Circuit breaker activation verified |

#### 2.2 FOMC High Impact Events
| Parameter | Value |
|-----------|-------|
| **Date Range** | Collection of FOMC days (2020-2024) |
| **Characteristics** | Spike volatility, wide spreads at announcement |
| **Expected Behavior** | Trading paused 15 min before/after, spread gating active |
| **Success Metrics** | No trades during news window, Spread gate triggers verified |

#### 2.3 NFP Release Days
| Parameter | Value |
|-----------|-------|
| **Date Range** | First Friday of each month, 8:30 AM ET (2020-2024) |
| **Characteristics** | 30-60 second spike, spreads 40-80 cents |
| **Expected Behavior** | Position closure before news, no new entries until settled |
| **Success Metrics** | No trades 8:25-8:40 AM on NFP days |

#### 2.4 Low Liquidity (Asian Session)
| Parameter | Value |
|-----------|-------|
| **Date Range** | Any 3-month period, Asian session only (7 PM - 3 AM ET) |
| **Characteristics** | Wide spreads (30-50 cents), low tick density |
| **Expected Behavior** | Session filter blocks trades (allow_asian=False) |
| **Success Metrics** | Zero trades during Asian session |

#### 2.5 Holiday Thin Markets
| Parameter | Value |
|-----------|-------|
| **Date Ranges** | Christmas (Dec 23-26), New Year (Dec 31-Jan 2), July 4th |
| **Characteristics** | Very low liquidity, erratic spreads |
| **Expected Behavior** | HolidayDetector blocks trading |
| **Success Metrics** | Zero trades on major holidays |

### 3. Edge Cases

#### 3.1 Consecutive Loss Streak
| Parameter | Value |
|-----------|-------|
| **Scenario** | Simulate 5+ consecutive losses |
| **Expected Behavior** | Circuit breaker Level 2 triggers (15 min pause, size -25%) |
| **Success Metrics** | Pause verified, Position size reduced 25% |

#### 3.2 Near DD Limit
| Parameter | Value |
|-----------|-------|
| **Scenario** | Equity approaching 8% DD (2% buffer from 10% limit) |
| **Expected Behavior** | Circuit breaker Level 4 (pause until next day), emergency size reduction |
| **Success Metrics** | Trading halts before 10% breach, No Apex violation |

#### 3.3 End-of-Day Forced Closure
| Parameter | Value |
|-----------|-------|
| **Scenario** | Open positions at 4:00 PM, 4:30 PM, 4:55 PM ET |
| **Expected Behavior** | Progressive urgency alerts, forced closure by 4:59 PM |
| **Success Metrics** | Zero positions open at 5:00 PM ET |

#### 3.4 Regime Transition
| Parameter | Value |
|-----------|-------|
| **Scenario** | Trending → Ranging → Trending transition |
| **Expected Behavior** | Regime detector updates mode, entry logic adapts |
| **Success Metrics** | No false signals at regime boundaries |

#### 3.5 Consistency Rule Edge
| Parameter | Value |
|-----------|-------|
| **Scenario** | Daily profit approaches 30% of total profit |
| **Expected Behavior** | Trading halts when limit approached (25% warning) |
| **Success Metrics** | No consistency rule violation |

#### 3.6 High Water Mark Reset
| Parameter | Value |
|-----------|-------|
| **Scenario** | $500 profit → new floor → $300 pullback |
| **Expected Behavior** | DD calculated from HWM, not initial balance |
| **Success Metrics** | DD shows 3% (300/10000), not 0% |

#### 3.7 Overnight Position Attempt
| Parameter | Value |
|-----------|-------|
| **Scenario** | Position opened at 4:58 PM ET on Friday |
| **Expected Behavior** | Position rejected or immediately closed |
| **Success Metrics** | Zero weekend exposure |

---

## Metrics & Success Criteria

### Core Performance Metrics

| Metric | Formula | Target | Minimum | Blocker |
|--------|---------|--------|---------|---------|
| **Sharpe Ratio** | (Return - Rf) / StdDev | > 2.0 | > 1.5 | < 1.0 |
| **Sortino Ratio** | (Return - Rf) / DownsideStdDev | > 3.0 | > 2.0 | < 1.5 |
| **Calmar Ratio** | CAGR / MaxDD | > 3.0 | > 2.0 | < 1.0 |
| **Max Drawdown %** | (Peak - Trough) / Peak | < 6% | < 8% | > 10% |
| **Win Rate %** | Wins / TotalTrades | > 55% | > 50% | < 45% |
| **Profit Factor** | GrossProfit / GrossLoss | > 2.0 | > 1.5 | < 1.2 |
| **SQN** | √N × Expectancy / StdDev | > 3.0 | > 2.0 | < 1.5 |
| **Expectancy** | (WinRate × AvgWin) - (LossRate × AvgLoss) | > $50/trade | > $25/trade | < $10/trade |
| **Average Trade** | TotalProfit / TotalTrades | > $30 | > $15 | < $5 |
| **Recovery Factor** | NetProfit / MaxDD | > 3.0 | > 2.0 | < 1.0 |

### Apex Trading Compliance Metrics

| Metric | Target | Blocker | Action on Breach |
|--------|--------|---------|------------------|
| **Trailing DD breaches** | 0 | > 0 | FAIL - Account terminated |
| **Post-4:59 PM trades** | 0 | > 0 | FAIL - Account terminated |
| **Overnight positions** | 0 | > 0 | FAIL - Account terminated |
| **Consistency violations** | 0 | > 0 | FAIL - Account terminated |
| **Max risk/trade exceeded** | 0 | > 0 | WARNING - Review sizing |
| **Circuit breaker triggers** | Any | N/A | LOG - Verify appropriate response |

### Realism Validation Metrics

| Metric | Expected Range | Warning | Action |
|--------|----------------|---------|--------|
| **Avg slippage** | 5-15 cents | > 20 cents | Review slippage model |
| **Avg spread paid** | 15-30 cents | > 40 cents | Check data quality |
| **Fill rate** | 95-98% | < 90% | Review rejection logic |
| **Avg trade duration** | < 60 min (scalper) | > 120 min | Review exit logic |
| **Commission/trade** | $7 round-trip | Varies | Validate broker rates |
| **Latency impact** | < 5 cents | > 10 cents | Review timing |

### Walk-Forward Efficiency (WFE) Metrics

| Metric | Formula | Target | Minimum | Blocker |
|--------|---------|--------|---------|---------|
| **WFE Sharpe** | OOS_Sharpe / IS_Sharpe | ≥ 0.70 | ≥ 0.60 | < 0.40 |
| **WFE Profit Factor** | OOS_PF / IS_PF | ≥ 0.70 | ≥ 0.60 | < 0.40 |
| **WFE Win Rate** | OOS_WR / IS_WR | ≥ 0.80 | ≥ 0.70 | < 0.50 |
| **WFE Drawdown** | IS_DD / OOS_DD | ≥ 0.80 | ≥ 0.60 | < 0.40 |
| **Combined WFE** | Average of above | ≥ 0.70 | ≥ 0.60 (target), ≥ 0.50 (minimum) | < 0.45 |

### Monte Carlo Metrics

| Metric | Formula | Target | Minimum | Blocker |
|--------|---------|--------|---------|---------|
| **95th percentile DD** | MC simulation | < 6% | < 8% | > 10% |
| **99th percentile DD** | MC simulation | < 8% | < 10% | > 12% |
| **Probability of ruin** | P(DD > 10%) | < 0.5% | < 1% | > 5% |
| **Expected Sharpe (median)** | MC simulation | > 1.8 | > 1.4 | < 1.0 |
| **Sharpe 5th percentile** | MC simulation | > 1.0 | > 0.7 | < 0.5 |

---

## WFA Protocol

### Walk-Forward Analysis Parameters

| Parameter | Value | Rationale |
|-----------|-------|-----------|
| **Total data period** | 2020-01-01 to 2024-12-31 (5 years) | Covers COVID, rate hikes, multiple regimes |
| **In-sample period** | 6 months | Sufficient for pattern learning |
| **Out-of-sample period** | 3 months | Meaningful forward test |
| **Step size** | 3 months (rolling window) | Strict temporal separation, no data leakage |
| **Total folds** | 18 folds | Comprehensive coverage through 2024-12-31 |
| **Optimization method** | None (fixed parameters) or Bayesian (if tuning) | Avoid overfitting |

### WFA Fold Schedule

**Rolling 6m IS / 3m OOS window** - prevents data leakage and tests recent market conditions:

| Fold | In-Sample Start | In-Sample End | OOS Start | OOS End |
|------|-----------------|---------------|-----------|---------|
| 1 | 2020-01-01 | 2020-06-30 | 2020-07-01 | 2020-09-30 |
| 2 | 2020-04-01 | 2020-09-30 | 2020-10-01 | 2020-12-31 |
| 3 | 2020-07-01 | 2020-12-31 | 2021-01-01 | 2021-03-31 |
| 4 | 2020-10-01 | 2021-03-31 | 2021-04-01 | 2021-06-30 |
| 5 | 2021-01-01 | 2021-06-30 | 2021-07-01 | 2021-09-30 |
| 6 | 2021-04-01 | 2021-09-30 | 2021-10-01 | 2021-12-31 |
| 7 | 2021-07-01 | 2021-12-31 | 2022-01-01 | 2022-03-31 |
| 8 | 2021-10-01 | 2022-03-31 | 2022-04-01 | 2022-06-30 |
| 9 | 2022-01-01 | 2022-06-30 | 2022-07-01 | 2022-09-30 |
| 10 | 2022-04-01 | 2022-09-30 | 2022-10-01 | 2022-12-31 |
| 11 | 2022-07-01 | 2022-12-31 | 2023-01-01 | 2023-03-31 |
| 12 | 2022-10-01 | 2023-03-31 | 2023-04-01 | 2023-06-30 |
| 13 | 2023-01-01 | 2023-06-30 | 2023-07-01 | 2023-09-30 |
| 14 | 2023-04-01 | 2023-09-30 | 2023-10-01 | 2023-12-31 |
| 15 | 2023-07-01 | 2023-12-31 | 2024-01-01 | 2024-03-31 |
| 16 | 2023-10-01 | 2024-03-31 | 2024-04-01 | 2024-06-30 |
| 17 | 2024-01-01 | 2024-06-30 | 2024-07-01 | 2024-09-30 |
| 18 | 2024-04-01 | 2024-09-30 | 2024-10-01 | 2024-12-31 |

### WFE Calculation Procedure

```python
def calculate_wfe(in_sample_metrics: dict, out_sample_metrics: dict) -> dict:
    """
    Calculate Walk-Forward Efficiency for each metric.
    
    WFE = Out-of-Sample Performance / In-Sample Performance
    
    Interpretation:
    - WFE >= 0.7: Excellent (robust strategy)
    - WFE 0.6-0.7: Good (meets target threshold)
    - WFE 0.5-0.6: Acceptable (meets minimum threshold)
    - WFE 0.4-0.5: Marginal (review required, below minimum)
    - WFE < 0.4: Poor (likely overfitting, NO-GO)
    """
    wfe = {}
    
    # Sharpe Ratio WFE
    wfe['sharpe'] = out_sample_metrics['sharpe'] / in_sample_metrics['sharpe']
    
    # Profit Factor WFE
    wfe['profit_factor'] = out_sample_metrics['profit_factor'] / in_sample_metrics['profit_factor']
    
    # Win Rate WFE
    wfe['win_rate'] = out_sample_metrics['win_rate'] / in_sample_metrics['win_rate']
    
    # Drawdown WFE (inverted - lower OOS DD is better)
    wfe['drawdown'] = in_sample_metrics['max_dd'] / out_sample_metrics['max_dd']
    
    # Combined WFE
    wfe['combined'] = np.mean([wfe['sharpe'], wfe['profit_factor'], wfe['win_rate'], wfe['drawdown']])
    
    return wfe
```

### WFA Success Criteria

| Criterion | Threshold | Action if Failed |
|-----------|-----------|------------------|
| All folds WFE ≥ 0.40 | PASS | NO-GO if any fold < 0.40 |
| Mean WFE ≥ 0.60 (target), ≥ 0.50 (minimum) | PASS | NO-GO if mean < 0.50, CONDITIONAL if 0.50-0.60 |
| WFE trend not declining | Slope ≥ -0.01/fold | Investigate drift |
| Consistency across folds | StdDev(WFE) < 0.15 | Investigate instability |

### Drift Detection

Monitor for performance degradation over time:

```python
def detect_drift(fold_metrics: List[dict]) -> dict:
    """
    Detect if strategy performance is degrading over time.
    """
    sharpes = [f['oos_sharpe'] for f in fold_metrics]
    folds = list(range(len(sharpes)))
    
    # Linear regression for trend
    slope, intercept = np.polyfit(folds, sharpes, 1)
    
    return {
        'trend_slope': slope,
        'is_declining': slope < -0.05,  # More than 0.05 Sharpe drop per fold
        'early_avg': np.mean(sharpes[:len(sharpes)//2]),
        'late_avg': np.mean(sharpes[len(sharpes)//2:]),
        'degradation_pct': (np.mean(sharpes[:len(sharpes)//2]) - np.mean(sharpes[len(sharpes)//2:])) / np.mean(sharpes[:len(sharpes)//2]) * 100
    }
```

---

## Monte Carlo Simulation

### Parameters

| Parameter | Value | Rationale |
|-----------|-------|-----------|
| **Number of runs** | 10,000 | Statistical significance |
| **Resampling method** | Bootstrap with replacement | Preserve trade distribution |
| **Block size** | 5 trades | Capture short-term correlation |
| **Variations applied** | Entry timing ±10 ticks, Slippage 0.5x-2.0x, Spreads 0.8x-1.5x | Model execution uncertainty |
| **Initial equity** | $100,000 | Match Apex account size |
| **Risk-free rate** | 5% annual | Current Fed rate |

### Simulation Procedure

```python
def run_monte_carlo(trades: pd.DataFrame, n_simulations: int = 10000) -> dict:
    """
    Run Monte Carlo simulation on backtest trades.
    
    Parameters:
    - trades: DataFrame with columns [entry_price, exit_price, pnl, direction, duration]
    - n_simulations: Number of bootstrap iterations
    
    Returns:
    - Dictionary with distribution statistics
    """
    results = {
        'max_drawdowns': [],
        'sharpe_ratios': [],
        'total_returns': [],
        'win_rates': [],
        'profit_factors': []
    }
    
    n_trades = len(trades)
    
    for i in range(n_simulations):
        # Bootstrap resample with replacement (block bootstrap)
        block_size = 5
        n_blocks = n_trades // block_size + 1
        sampled_indices = []
        
        for _ in range(n_blocks):
            start_idx = np.random.randint(0, n_trades - block_size)
            sampled_indices.extend(range(start_idx, start_idx + block_size))
        
        sampled_indices = sampled_indices[:n_trades]
        resampled_trades = trades.iloc[sampled_indices].copy()
        
        # Apply random variations
        slippage_factor = np.random.uniform(0.5, 2.0)
        spread_factor = np.random.uniform(0.8, 1.5)
        
        # Adjust P&L for slippage/spread variations
        resampled_trades['adjusted_pnl'] = resampled_trades['pnl'] * (1 - 0.001 * slippage_factor * spread_factor)
        
        # Calculate metrics
        equity_curve = 100000 + resampled_trades['adjusted_pnl'].cumsum()
        peak = equity_curve.cummax()
        drawdown = (peak - equity_curve) / peak
        
        results['max_drawdowns'].append(drawdown.max() * 100)
        
        daily_returns = resampled_trades['adjusted_pnl'] / 100000
        results['sharpe_ratios'].append(daily_returns.mean() / daily_returns.std() * np.sqrt(252))
        
        results['total_returns'].append(resampled_trades['adjusted_pnl'].sum())
        results['win_rates'].append((resampled_trades['adjusted_pnl'] > 0).mean() * 100)
        
        wins = resampled_trades[resampled_trades['adjusted_pnl'] > 0]['adjusted_pnl'].sum()
        losses = abs(resampled_trades[resampled_trades['adjusted_pnl'] < 0]['adjusted_pnl'].sum())
        results['profit_factors'].append(wins / losses if losses > 0 else float('inf'))
    
    return {
        'max_dd_95th': np.percentile(results['max_drawdowns'], 95),
        'max_dd_99th': np.percentile(results['max_drawdowns'], 99),
        'prob_ruin': np.mean([dd > 10 for dd in results['max_drawdowns']]) * 100,
        'sharpe_median': np.median(results['sharpe_ratios']),
        'sharpe_5th': np.percentile(results['sharpe_ratios'], 5),
        'sharpe_95th': np.percentile(results['sharpe_ratios'], 95),
        'return_median': np.median(results['total_returns']),
        'return_5th': np.percentile(results['total_returns'], 5),
        'win_rate_median': np.median(results['win_rates']),
        'profit_factor_median': np.median(results['profit_factors'])
    }
```

### Monte Carlo Success Criteria

| Criterion | Threshold | Verdict |
|-----------|-----------|---------|
| 95th percentile DD < 6% | Target | GREEN - Excellent risk |
| 95th percentile DD < 8% | Minimum | YELLOW - Acceptable |
| 95th percentile DD > 8% | Blocker | RED - Unacceptable for Apex |
| Probability of ruin < 0.5% | Target | GREEN |
| Probability of ruin < 1% | Minimum | YELLOW |
| Probability of ruin > 5% | Blocker | RED - Too risky |
| Sharpe 5th percentile > 1.0 | Target | GREEN |
| Sharpe 5th percentile > 0.7 | Minimum | YELLOW |
| Sharpe 5th percentile < 0.5 | Blocker | RED - Inconsistent |

### Monte Carlo Visualization

Generate the following plots:
1. **Drawdown distribution histogram** - Show 95th/99th percentiles
2. **Sharpe ratio distribution** - Show confidence interval
3. **Equity curve fan chart** - 5th/25th/50th/75th/95th percentile paths
4. **Probability of ruin by equity level** - P(DD > X%) for X = 5, 8, 10, 15, 20

---

## GO/NO-GO Decision Framework

### Decision Tree

```
┌─────────────────────────────────────────────────────────────────┐
│                    GO/NO-GO DECISION TREE                       │
└─────────────────────────────────────────────────────────────────┘

PHASE 1: AUDIT VALIDATION
├── All P0 issues from audits 001-004 fixed?
│   ├── YES → Continue to Phase 2
│   └── NO → NO-GO (Fix P0 issues first)

PHASE 2: BASELINE BACKTEST
├── Core metrics ≥ Minimum thresholds?
│   ├── YES → Continue to Phase 3
│   └── NO → NO-GO (Improve strategy performance)
│
├── Any BLOCKER metrics triggered?
│   ├── NO → Continue to Phase 3
│   └── YES → NO-GO (Critical performance failure)

PHASE 3: APEX COMPLIANCE
├── Trailing DD breaches = 0?
│   ├── YES → Continue
│   └── NO → NO-GO (DD management failure)
│
├── Post-4:59 PM trades = 0?
│   ├── YES → Continue
│   └── NO → NO-GO (Time constraint failure)
│
├── Overnight positions = 0?
│   ├── YES → Continue
│   └── NO → NO-GO (Overnight violation)
│
├── Consistency violations = 0?
│   ├── YES → Continue to Phase 4
│   └── NO → NO-GO (Consistency rule failure)

PHASE 4: WFA VALIDATION
├── Combined WFE ≥ 0.60 (target) or ≥ 0.50 (minimum)?
│   ├── YES (≥ 0.60) → Continue to Phase 5
│   ├── CONDITIONAL (0.50-0.60) → Review + Continue with caution
│   └── NO (< 0.50) → NO-GO (Overfitting detected)
│
├── All folds WFE ≥ 0.40?
│   ├── YES → Continue
│   └── NO → NO-GO (Inconsistent performance)
│
├── Performance drift detected?
│   ├── NO → Continue to Phase 5
│   └── YES → CONDITIONAL (Investigate cause)

PHASE 5: MONTE CARLO
├── 95th percentile DD < 8%?
│   ├── YES → Continue
│   └── NO → NO-GO (Unacceptable DD risk)
│
├── Probability of ruin < 1%?
│   ├── YES → Continue
│   └── NO → NO-GO (Ruin risk too high)
│
├── Sharpe 5th percentile > 0.7?
│   ├── YES → GO (Paper trading approved)
│   └── NO → CONDITIONAL (Review edge consistency)

FINAL VERDICT
├── GO → Approve for paper trading (30 days)
├── CONDITIONAL → Manual review + specific fixes required
└── NO-GO → Document blockers + return to development
```

### Verdict Definitions

| Verdict | Meaning | Next Steps |
|---------|---------|------------|
| **GO** | All criteria passed | Proceed to paper trading |
| **CONDITIONAL** | Minor concerns, addressable | Fix specific issues, re-run affected tests |
| **NO-GO** | Critical failures | Return to development, fix blockers, restart validation |

### Paper Trading Approval Conditions

If GO verdict achieved:
- **Duration**: 30 calendar days minimum
- **Environment**: Apex demo/simulation account
- **Rules**: Full Apex rules enforced
- **Success criteria**: Replicate backtest metrics within 20% tolerance
- **Monitoring**: Daily P&L review, weekly full analysis

### Paper Trading Success Criteria

| Metric | Backtest Value | Paper Trading Min (80%) | Paper Trading Target (100%) |
|--------|----------------|-------------------------|----------------------------|
| Sharpe | 2.0 | 1.6 | 2.0 |
| Max DD | 6% | 7.2% (max) | 6% (max) |
| Win Rate | 55% | 44% | 55% |
| Profit Factor | 2.0 | 1.6 | 2.0 |
| Apex violations | 0 | 0 (no tolerance) | 0 |

### Live Approval Gate

Paper trading → Live trading requires:
- [ ] 30 days of paper trading completed
- [ ] All metrics within 20% of backtest
- [ ] Zero Apex rule violations
- [ ] No significant system errors or crashes
- [ ] Manual review and sign-off by owner

---

## Testing Workflow

### Phase 1: Fix Issues (4.25 days)

**Objective**: Resolve all P0 blockers identified in audits

| Task | Owner | Effort | Dependencies | Validation |
|------|-------|--------|--------------|------------|
| 1.1 Fix execution threshold (65→70) | FORGE | 0.25 hr | None | Unit test |
| 1.2 Enforce confluence_min_score config | FORGE | 1 hr | None | Integration test |
| 1.3 Consolidate MTF Manager | FORGE | 2 hr | None | Import test |
| 1.4 Implement TimeConstraintManager | FORGE | 16 hr | None | Unit + integration test |
| 1.5 Implement consistency rule | FORGE | 8 hr | None | Unit test |
| 1.6 Integrate CircuitBreaker | FORGE | 4 hr | 1.4, 1.5 | Integration test |
| 1.7 Verify unrealized P&L inclusion | ORACLE | 4 hr | None | Trace test |
| 1.8 Add account termination | FORGE | 2 hr | 1.4 | Unit test |
| 1.9 Wire YAML realism knobs | FORGE | 2 hr | None | Config test |
| 1.10 Implement metrics telemetry | FORGE | 3 hr | None | Output test |
| 1.11 Re-run all audits | ORACLE | 2 hr | 1.1-1.10 | All pass |

**Exit criteria**: All audit checks pass, no P0 issues remaining

### Phase 2: Data Preparation (2.5 days)

**Objective**: Download, validate, calibrate realism, and prepare backtest data

| Task | Owner | Effort | Dependencies | Validation |
|------|-------|--------|--------------|------------|
| 2.1 Download Dukascopy 2020-2024 | FORGE | 4 hr | None | File exists |
| 2.2 Run QC checklist | ORACLE | 2 hr | 2.1 | All checks pass |
| 2.3 **Calibrate realism parameters** | ORACLE | 4 hr | 2.2 | **Derive slippage/latency distributions from tick spreads** |
| 2.4 Convert to Parquet format | FORGE | 2 hr | 2.2 | Load test |
| 2.5 Split into WFA folds | FORGE | 2 hr | 2.4 | 18 folds created |
| 2.6 Create scenario data subsets | ORACLE | 4 hr | 2.4 | 16 scenarios ready |
| 2.7 Download FXCM validation set | FORGE | 2 hr | None | File exists |

**Exit criteria**: All data validated, QC passed, **realism parameters calibrated and documented**, folds/scenarios ready

### Phase 3: Baseline Backtest (2 days)

**Objective**: Run single full-period backtest to establish baseline

| Task | Owner | Effort | Dependencies | Validation |
|------|-------|--------|--------------|------------|
| 3.1 Configure backtest parameters | ORACLE | 1 hr | Phase 2 | Config file ready |
| 3.2 Run full 5-year backtest | ORACLE | 4 hr (compute) | 3.1 | Completes without error |
| 3.3 Calculate all metrics | ORACLE | 2 hr | 3.2 | Metrics populated |
| 3.4 Check vs minimum thresholds | ORACLE | 1 hr | 3.3 | Pass/fail documented |
| 3.5 Run scenario backtests | ORACLE | 8 hr | 3.1 | 16 scenarios complete |
| 3.6 **Validate Apex compliance** | SENTINEL | 1 hr | 3.2 | **Zero violations confirmed** |
| 3.7 Document baseline results | ORACLE | 2 hr | 3.3, 3.5, 3.6 | Report generated |

**Exit criteria**: Baseline metrics meet minimum thresholds, **Apex compliance validated (0 violations)**, no blockers

### Phase 4: Walk-Forward Analysis (3 days)

**Objective**: Validate out-of-sample performance consistency

| Task | Owner | Effort | Dependencies | Validation |
|------|-------|--------|--------------|------------|
| 4.1 Configure WFA parameters | ORACLE | 1 hr | Phase 3 | Config ready |
| 4.2 Run 18 WFA folds | ORACLE | 14 hr (compute) | 4.1 | All folds complete |
| 4.3 Calculate WFE per fold | ORACLE | 2 hr | 4.2 | WFE values |
| 4.4 Calculate combined WFE | ORACLE | 1 hr | 4.3 | Combined WFE |
| 4.5 Detect drift | ORACLE | 1 hr | 4.3 | Drift analysis |
| 4.6 **Validate Apex compliance (all folds)** | SENTINEL | 2 hr | 4.2 | **Zero violations across all OOS periods** |
| 4.7 Document WFA results | ORACLE | 2 hr | 4.3-4.6 | Report generated |
| 4.8 Cross-validate with FXCM | ORACLE | 4 hr | 2.6, 4.1 | Comparison done |

**Exit criteria**: Combined WFE ≥ 0.60 (target) or ≥ 0.50 (minimum), **Apex compliance validated across all folds**, no drift detected

### Phase 5: Monte Carlo Simulation (2 days)

**Objective**: Validate robustness to random variations

| Task | Owner | Effort | Dependencies | Validation |
|------|-------|--------|--------------|------------|
| 5.1 Configure MC parameters | ORACLE | 1 hr | Phase 3 | Config ready |
| 5.2 Run 10,000 simulations | ORACLE | 8 hr (compute) | 5.1 | Completes |
| 5.3 Extract distribution statistics | ORACLE | 2 hr | 5.2 | Stats populated |
| 5.4 Generate visualizations | ORACLE | 2 hr | 5.3 | Plots generated |
| 5.5 Check vs thresholds | ORACLE | 1 hr | 5.3 | Pass/fail documented |
| 5.6 **Validate Apex compliance (MC runs)** | SENTINEL | 2 hr | 5.2 | **Check violations in simulated scenarios** |
| 5.7 Document MC results | ORACLE | 2 hr | 5.3-5.6 | Report generated |

**Exit criteria**: 95th percentile DD < 8%, P(ruin) < 1%, **Apex compliance maintained across MC simulations**

### Phase 6: GO/NO-GO Decision (1 day)

**Objective**: Make final decision on paper trading approval

| Task | Owner | Effort | Dependencies | Validation |
|------|-------|--------|--------------|------------|
| 6.1 Compile all results | ORACLE | 2 hr | Phases 3-5 | Summary ready |
| 6.2 Apply decision tree | SENTINEL | 1 hr | 6.1 | Verdict determined |
| 6.3 Document rationale | SENTINEL | 2 hr | 6.2 | Decision documented |
| 6.4 Create final report | ORACLE | 2 hr | 6.1-6.3 | Report complete |
| 6.5 Owner review | OWNER | 1 hr | 6.4 | Sign-off |

**Exit criteria**: GO/NO-GO verdict documented with full evidence

### Phase 7: Paper Trading (30 days)

**Objective**: Validate strategy in real-time conditions

| Task | Owner | Effort | Dependencies | Validation |
|------|-------|--------|--------------|------------|
| 7.1 Set up Apex demo account | OWNER | 2 hr | Phase 6 GO | Account ready |
| 7.2 Deploy strategy | FORGE | 4 hr | 7.1 | Running without errors |
| 7.3 Daily monitoring | SENTINEL | 0.5 hr/day × 30 | 7.2 | Daily logs |
| 7.4 Weekly analysis | ORACLE | 2 hr/week × 4 | 7.3 | Weekly reports |
| 7.5 Final comparison to backtest | ORACLE | 4 hr | 7.3, 7.4 | Deviation analysis |
| 7.6 Live trading decision | OWNER | 2 hr | 7.5 | Final approval |

**Exit criteria**: Metrics within 20% of backtest, zero Apex violations

---

## Reporting Template

### Strategy Backtest Report Template

```markdown
# Strategy Backtest Report: [STRATEGY_NAME]

## Summary
| Field | Value |
|-------|-------|
| Status | PASS / FAIL / CONDITIONAL |
| GO/NO-GO | GO / NO-GO |
| Test Date | YYYY-MM-DD |
| Data Period | YYYY-MM-DD to YYYY-MM-DD |
| Total Trades | N |
| Net P&L | $X,XXX |

## Core Metrics
| Metric | Value | Target | Minimum | Status |
|--------|-------|--------|---------|--------|
| Sharpe Ratio | X.XX | > 2.0 | > 1.5 | ✅/❌ |
| Sortino Ratio | X.XX | > 3.0 | > 2.0 | ✅/❌ |
| Calmar Ratio | X.XX | > 3.0 | > 2.0 | ✅/❌ |
| Max Drawdown % | X.X% | < 6% | < 8% | ✅/❌ |
| Win Rate % | XX.X% | > 55% | > 50% | ✅/❌ |
| Profit Factor | X.XX | > 2.0 | > 1.5 | ✅/❌ |
| SQN | X.XX | > 3.0 | > 2.0 | ✅/❌ |
| Expectancy | $XX | > $50 | > $25 | ✅/❌ |

## Apex Compliance
| Check | Count | Limit | Status |
|-------|-------|-------|--------|
| Trailing DD breaches | N | 0 | ✅/❌ |
| Post-4:59 PM trades | N | 0 | ✅/❌ |
| Overnight positions | N | 0 | ✅/❌ |
| Consistency violations | N | 0 | ✅/❌ |
| **Overall Apex Status** | | | ✅ PASS / ❌ FAIL |

## WFA Results
| Field | Value |
|-------|-------|
| Total Folds | N |
| Combined WFE | X.XX |
| Sharpe WFE | X.XX |
| Profit Factor WFE | X.XX |
| Win Rate WFE | X.XX |
| Drift Detected | YES/NO |
| **WFA Status** | ✅ PASS / ❌ FAIL |

## Monte Carlo Results (10,000 runs)
| Metric | Value | Threshold | Status |
|--------|-------|-----------|--------|
| 95th percentile DD | X.X% | < 8% | ✅/❌ |
| 99th percentile DD | X.X% | < 10% | ✅/❌ |
| P(ruin) | X.X% | < 1% | ✅/❌ |
| Sharpe median | X.XX | > 1.4 | ✅/❌ |
| Sharpe 5th pct | X.XX | > 0.7 | ✅/❌ |
| **MC Status** | | | ✅ PASS / ❌ FAIL |

## Scenario Results
| Scenario | Period | Result | Key Metrics | Notes |
|----------|--------|--------|-------------|-------|
| Normal trending | 2020-Q2 | PASS | Sharpe 2.1, DD 4% | Strong performance |
| COVID stress | 2020-03 | PASS | DD 7%, CB triggered | Circuit breaker worked |
| Asian session | 2023-H1 | PASS | 0 trades | Session filter active |
| FOMC events | Collection | PASS | 0 trades during news | News filter active |
| ... | ... | ... | ... | ... |

## Issues Found
| # | Severity | Description | Resolution |
|---|----------|-------------|------------|
| 1 | P1 | [Description] | [Fix applied / Pending] |
| 2 | P2 | [Description] | [Fix applied / Pending] |

## Verdict
**GO / NO-GO / CONDITIONAL**

### Rationale
[2-3 sentences explaining the verdict]

### Key Strengths
1. [Strength 1]
2. [Strength 2]

### Areas of Concern
1. [Concern 1 - if any]
2. [Concern 2 - if any]

## Next Steps
| # | Action | Owner | Due Date |
|---|--------|-------|----------|
| 1 | [Action] | [Owner] | YYYY-MM-DD |
| 2 | [Action] | [Owner] | YYYY-MM-DD |

## Appendix

### Equity Curve
[Insert equity curve chart]

### Drawdown Chart
[Insert drawdown chart]

### Monthly Returns Heatmap
[Insert heatmap]

### Trade Distribution
[Insert histogram of P&L per trade]
```

---

## Tools & Automation

### Scripts to Create

#### 1. `run_full_backtest.py`
**Purpose**: Execute baseline backtest with full metrics

**Key Features**:
- Load Dukascopy tick data from Parquet
- Apply slippage/commission/latency from config
- Run strategy with all risk modules enabled
- Calculate and export all metrics (Sharpe, Sortino, Calmar, SQN, etc.)
- Generate equity curve and drawdown charts
- Export trades to CSV for analysis

**Location**: `nautilus_gold_scalper/scripts/run_full_backtest.py`

#### 2. `run_wfa.py`
**Purpose**: Execute Walk-Forward Analysis across all folds

**Key Features**:
- Automated fold creation from config
- Parallel execution of folds (if resources allow)
- WFE calculation per fold and combined
- Drift detection and analysis
- Export fold results to structured JSON/CSV
- Generate WFA summary report

**Location**: `nautilus_gold_scalper/scripts/run_wfa.py`

#### 3. `run_monte_carlo.py`
**Purpose**: Execute Monte Carlo simulation

**Key Features**:
- Bootstrap resampling with configurable block size
- Apply random variations (slippage, spread, timing)
- Calculate distribution statistics (percentiles, P(ruin))
- Generate visualization plots
- Export full results for analysis

**Location**: `nautilus_gold_scalper/scripts/run_monte_carlo.py`

#### 4. `generate_report.py`
**Purpose**: Auto-generate markdown report from results

**Key Features**:
- Load results from backtest/WFA/MC outputs
- Apply GO/NO-GO decision tree
- Populate report template
- Insert charts as base64 images
- Export to `DOCS/04_REPORTS/BACKTESTS/`

**Location**: `nautilus_gold_scalper/scripts/generate_report.py`

#### 5. `validate_apex_compliance.py`
**Purpose**: Check trades for Apex rule violations

**Key Features**:
- Load trade log CSV
- Check each trade for time violations (post-4:59 PM)
- Check for overnight positions
- Calculate trailing DD on each tick
- Check consistency rule
- Report violations with timestamps

**Location**: `nautilus_gold_scalper/scripts/validate_apex_compliance.py`

### Integration Points

| Script | Input | Output | Integration |
|--------|-------|--------|-------------|
| run_full_backtest.py | Parquet data, config | trades.csv, metrics.json, charts | BacktestEngine |
| run_wfa.py | Parquet data, fold config | wfa_results.json, fold_*.csv | BacktestEngine |
| run_monte_carlo.py | trades.csv | mc_results.json, charts | Standalone analysis |
| generate_report.py | All JSON outputs | report.md | Template engine |
| validate_apex_compliance.py | trades.csv | violations.json | Standalone check |

### Output Location

All outputs to: `DOCS/04_REPORTS/BACKTESTS/[YYYYMMDD]_[STRATEGY]_[TYPE]/`

```
DOCS/04_REPORTS/BACKTESTS/
├── 20251215_GOLD_SCALPER_BASELINE/
│   ├── trades.csv
│   ├── metrics.json
│   ├── equity_curve.png
│   ├── drawdown.png
│   └── report.md
├── 20251218_GOLD_SCALPER_WFA/
│   ├── fold_01_results.csv
│   ├── ...
│   ├── fold_18_results.csv
│   ├── wfa_summary.json
│   └── report.md
├── 20251220_GOLD_SCALPER_MC/
│   ├── mc_results.json
│   ├── dd_distribution.png
│   ├── sharpe_distribution.png
│   ├── equity_fan.png
│   └── report.md
└── 20251221_GOLD_SCALPER_FINAL/
    └── go_nogo_report.md
```

---

## Timeline Estimate

| Phase | Tasks | Duration | Dependencies | Dates (Est.) |
|-------|-------|----------|--------------|--------------|
| **Phase 1: Fix Issues** | 11 tasks | 4.25 days | Audit findings | Dec 9-13 |
| **Phase 2: Data Prep** | 7 tasks | 2.5 days | Phase 1 | Dec 14-16 |
| **Phase 3: Baseline** | 7 tasks | 2.5 days | Phase 2 | Dec 17-19 |
| **Phase 4: WFA** | 8 tasks | 4 days | Phase 3 | Dec 20-23 |
| **Phase 5: Monte Carlo** | 7 tasks | 2.5 days | Phase 3 | Dec 24-26 |
| **Phase 6: GO/NO-GO** | 5 tasks | 1 day | Phases 4-5 | Dec 27 |
| **Phase 7: Paper Trading** | 6 tasks | 30 days | Phase 6 GO | Dec 28 - Jan 27 |

**Total Duration**: 
- Pre-paper trading: **16.75 days** (Phases 1-6) + **20% buffer** = **~20 days**
- Paper trading: **30 days** (Phase 7)
- **Total to live trading approval**: ~50 days

**Critical Path**: Phase 1 (fixes) → Phase 2 (data + realism calibration) → Phase 3 (baseline + Apex validation) → [Phase 4 (18 folds + compliance) & Phase 5 (MC + compliance) sequential] → Phase 6 (decision) → Phase 7 (paper)

**Compute Optimization Options**:
- **Parallel fold execution**: Reduce Phase 4 from 4 days to 2 days (requires 4+ CPU cores)
- **Cloud compute**: Use AWS/GCP for MC simulations (10k runs in 2-4 hours vs 8 hours locally)
- **Pre-compute folds**: Prepare fold data splits during Phase 2 for faster Phase 4 startup

---

## Success Criteria

### Plan Quality Checklist
- [x] All 16 test scenarios defined with specific date ranges
- [x] Metrics have Target/Minimum/Blocker thresholds
- [x] WFA protocol detailed (18 rolling folds, WFE ≥0.60 target, WFE formulas)
- [x] Monte Carlo parameters rigorous (10k runs, variations)
- [x] GO/NO-GO framework unambiguous (decision tree with Apex validation)
- [x] 7-phase workflow step-by-step actionable with Apex compliance checks
- [x] Timeline estimate realistic (~50 days total with 20% buffer)
- [x] Realism calibration task included (slippage/latency from tick data)

### Execution Success Criteria (when plan is run)
- [ ] All P0 issues fixed before Phase 3
- [ ] Data passes QC checklist
- [ ] Realism parameters calibrated from tick data
- [ ] Core metrics meet Minimum thresholds
- [ ] Apex compliance: 0 violations in baseline, WFA, and MC
- [ ] Combined WFE ≥ 0.60 (target) or ≥ 0.50 (minimum)
- [ ] Monte Carlo 95th percentile DD < 8%
- [ ] P(ruin) < 1%
- [ ] GO verdict achieved in Phase 6
- [ ] Paper trading replicates backtest within 20%

---

## Risks & Mitigation

| Risk | Impact | Probability | Mitigation |
|------|--------|-------------|------------|
| **Data quality issues** | HIGH | MEDIUM | Validate with QC checklist, cross-check FXCM |
| **P0 fixes take longer** | MEDIUM | MEDIUM | Allocate 50% buffer time (6 days → 9 days) |
| **WFA shows overfitting** | HIGH | MEDIUM | Use conservative WFE threshold (0.60 target, 0.50 minimum), consider param reduction |
| **Monte Carlo high DD** | HIGH | LOW | Reduce position sizing, add tighter circuit breaker |
| **Apex rules change** | MEDIUM | LOW | Monitor Apex announcements, design modular rule engine |
| **Paper diverges from backtest** | HIGH | MEDIUM | Investigate slippage/spread differences, adjust realism model |
| **Compute resource constraints** | LOW | MEDIUM | Optimize scripts, use cloud compute if needed |

---

## Next Steps After Plan Approval

1. **Immediate (Day 1)**: Begin Phase 1 - Fix ORACLE Bug #2 (threshold 65→70) and Bug #4 (config enforcement)
2. **Day 1-2**: Implement TimeConstraintManager (4:59 PM ET deadline)
3. **Day 3**: Implement consistency rule (30% max daily profit)
4. **Day 4**: Integrate CircuitBreaker into strategy
5. **Day 5**: Complete remaining P0 fixes, re-run audits
6. **Day 6-7**: Data preparation (download, QC, fold creation)
7. **Day 8+**: Begin validation phases (baseline → WFA → MC → decision)

---

<open_questions>
- Should ML modules (ensemble_predictor, feature_engineering) be included in backtest validation, or tested separately?
- What is the exact slippage/commission configuration for Apex Trading?
- Should bar-based runner be deprecated in favor of tick-only validation?
- Is 30-day paper trading sufficient, or should it be extended to 60 days?
</open_questions>

<assumptions>
- 5 years of Dukascopy data (2020-2024) available and downloadable
- Apex demo account available for paper trading phase
- Compute resources sufficient for 10k MC simulations (~8 hours)
- Strategy parameters are fixed (no optimization during WFA)
- Slippage/commission values from Apex live trading can be obtained
</assumptions>

<dependencies>
- Completion of all P0 fixes from audits 001-004
- Dukascopy data download successful
- NautilusTrader BacktestEngine functional
- Owner availability for Phase 6 sign-off and Phase 7 setup
</dependencies>
