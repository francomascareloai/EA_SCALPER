# ORACLE Extended Backtest Analysis: Mean Revert Strategy (2-Year)

## ORACLE Output
AGENT: ORACLE
VERSION: 3.4
CLAUDE_MD_VERSION: 3.10.23
STATUS: COMPLETE

---

## Executive Summary

**DECISION: NO-GO**

The 2-year extended backtest of the Mean Revert strategy has **FAILED** statistical validation. Despite generating 68 trades (below the 100 minimum threshold), the strategy shows **negative expectancy** and **catastrophic risk-adjusted returns**. The strategy is not viable for live trading.

---

## Test Configuration

| Parameter | Value |
|-----------|-------|
| Period | 2023-01-03 to 2024-12-31 |
| Duration | 728 days (2 years) |
| Mode | MR-only (--mr-only) |
| Confluence Threshold | 65 |
| Initial Balance | $100,000 |
| Data Points | 4,631,521 ticks |
| Elapsed Time | 21 minutes 15 seconds |

---

## Full Metrics Table

### Core Performance Metrics

| Metric | Value | Target | Status |
|--------|-------|--------|--------|
| Total Trades | 68 | >= 100 | **FAIL** |
| Win Rate | 75.0% | 50-60% | WARN (suspiciously high) |
| Total PnL | -$778.60 | > $0 | **FAIL** |
| PnL % | -0.78% | > 0% | **FAIL** |
| Expectancy | -$11.45/trade | > $0 | **FAIL** |
| Profit Factor | 0.89 | >= 1.8 | **FAIL** |
| Max Drawdown | 2.83% | < 4% | PASS |

### Risk-Adjusted Metrics

| Metric | Value | Target | Status |
|--------|-------|--------|--------|
| Sharpe Ratio | -0.47 | >= 1.5 | **FAIL** |
| Sortino Ratio | -0.58 | >= 2.0 | **FAIL** |
| Calmar Ratio | -1.01 | > 0 | **FAIL** |
| SQN | -0.25 | >= 2.0 | **FAIL** |

### Trade Distribution

| Metric | Value |
|--------|-------|
| Max Winner | +$1,183.80 |
| Avg Winner | +$118.40 |
| Min Winner | +$1.30 |
| Max Loser | -$1,366.70 |
| Avg Loser | -$400.99 |
| Min Loser | -$0.20 |
| Long Ratio | 46% |
| Returns Volatility | 2.85% annualized |

---

## Trade Count Validation

**FAILED: 68 trades < 100 minimum**

The strategy generated only 68 positions over 2 years:
- Average: ~2.8 trades/month
- Far below statistical significance threshold
- Insufficient sample for reliable conclusions

**Root Cause Analysis:**
1. **MR signal filtering too strict**: Confluence threshold 65 filtering out most opportunities
2. **Session/time constraints**: Trading only during allowed sessions (no weekends, Apex time gates)
3. **Signal quality issues**: Many signal checks returned `None (insufficient data or error)`

---

## SQN Recalculation

**SQN = (Expectancy / StdDev of Trade Returns) * sqrt(N)**

Given:
- Expectancy = -$11.45
- N = 68 trades
- Reported SQN = -0.25

The negative SQN confirms:
- No positive edge exists
- System is worse than random
- Cannot be scaled profitably

**SQN Interpretation:**
| SQN Range | Assessment |
|-----------|------------|
| < 0 | Losing system |
| 0 - 1.6 | Below average |
| 1.7 - 2.0 | Tradeable |
| 2.0 - 3.0 | Good |
| > 3.0 | Excellent |

**Current SQN (-0.25): LOSING SYSTEM**

---

## Monthly/Quarterly Breakdown

### 2023 Performance (Estimated from closed position timestamps)

| Quarter | Trades | Notable P&L |
|---------|--------|-------------|
| Q1 2023 | ~10 | -$1,366.70 (worst loser Mar 7), +$31.80, +$40.30, -$700.20 |
| Q2 2023 | ~6 | +$23.80, +$14.30, -$893.20, +$51.80 |
| Q3 2023 | ~8 | +$35.30, +$24.30, +$39.80, +$53.30, +$9.30 |
| Q4 2023 | ~6 | +$5.80, -$8.20, +$28.80, -$194.70, -$50.70 |

### 2024 Performance (Estimated from closed position timestamps)

| Quarter | Trades | Notable P&L |
|---------|--------|-------------|
| Q1 2024 | ~9 | +$835.30, -$177.20, +$73.80, +$833.80, +$69.80, -$664.20 |
| Q2 2024 | ~15 | -$1,239.20 (major loss Apr 22), multiple small wins |
| Q3 2024 | ~7 | Mixed small wins and losses |
| Q4 2024 | ~9 | +$650.30 (Nov 25), +$115.80, +$42.80, +$14.80 |

### Observations:
- Large losses (-$1,366.70, -$1,239.20, -$893.20, -$700.20) wipe out many small wins
- Win rate is high (75%) but avg loser ($400.99) >> avg winner ($118.40)
- Risk:reward ratio is inverted (~3.4:1 against)

---

## Validation Gate Results

### GATE 0: Data Quality
**PASS** - 4,631,521 ticks loaded successfully, 173 invalid spreads filtered

### GATE 1: Sample Size
**FAIL**
- Trades: 68 < 100 minimum
- Period: 2 years (PASS)
- Regimes: Multiple covered (PASS)

### GATE 2: Performance Metrics
**FAIL**
- Sharpe: -0.47 < 1.5 (FAIL)
- SQN: -0.25 < 2.0 (FAIL)
- Max DD: 2.83% < 4% (PASS)
- Profit Factor: 0.89 < 1.8 (FAIL)

### GATE 3: Walk-Forward Analysis
**NOT APPLICABLE** - Insufficient trades for meaningful WFA

### GATE 4: Monte Carlo
**NOT APPLICABLE** - Cannot run MC on losing strategy

### GATE 5: Overfitting Detection
**NOT APPLICABLE** - No positive edge to overfit

### GATE 6: Apex Consistency Rule
**N/A** - Strategy is unprofitable

### GATE 7: Paper Trading
**BLOCKED** - Cannot proceed to paper trading

---

## GO/NO-GO Recommendation

## **DECISION: NO-GO**

### Critical Failures:
1. **Negative Expectancy**: -$11.45 per trade
2. **Negative Sharpe**: -0.47 (worse than risk-free rate)
3. **Negative SQN**: -0.25 (losing system)
4. **Inverted Risk:Reward**: Avg loss 3.4x avg win
5. **Insufficient Sample**: 68 trades < 100 minimum
6. **Profit Factor < 1**: 0.89 means losing money

### Why High Win Rate Is Misleading:
The 75% win rate is a **trap**. Small wins ($118 avg) cannot offset occasional large losses ($401 avg). This is characteristic of:
- Mean reversion gone wrong
- Holding losers too long
- Taking profits too early
- Insufficient stop-loss discipline

---

## Root Cause Analysis

### 1. Signal Quality Issues
Throughout the backtest logs:
```
[SIGNAL_CHECK] Confluence returned None (insufficient data or error)
```
This indicates the MR signal generator is failing to produce valid signals most of the time.

### 2. Trade Management Bug
Repeated errors:
```
[TRADE_MANAGER] _process_trade_management failed: 'bool' object has no attribute 'get'
```
This type error in trade management may be causing improper exit timing.

### 3. Asymmetric Exit Logic
- Winners exited quickly (avg hold time ~hours)
- Losers held to stop-loss or time-based exit (avg hold time ~days)
- This creates the observed inverted risk:reward

---

## Recommendations

### Immediate Actions:
1. **DO NOT deploy this strategy** - It has negative expectancy
2. **Fix the trade management bug** - `'bool' object has no attribute 'get'`
3. **Investigate MR signal generator** - Why so many `None` returns?

### Strategy Improvements Needed:
1. **Tighten stop-loss** - Max loser of -$1,366 is unacceptable
2. **Improve exit timing** - Current TP:SL ratio is inverted
3. **Lower confluence threshold** - 65 may be too restrictive (test 55-60)
4. **Consider abandoning MR-only mode** - May not have standalone edge

### Alternative Path:
Consider MR as a **filter/enhancement** for the TF strategy rather than standalone mode. The 6-month backtest showed promise with TF+MR combined.

---

## Comparison: 6-Month vs 2-Year Results

| Metric | 6-Month (Prior) | 2-Year (Extended) | Delta |
|--------|-----------------|-------------------|-------|
| Trades | 29 | 68 | +39 |
| Win Rate | 79.3% | 75.0% | -4.3% |
| Sharpe | 2.73 | -0.47 | -3.20 |
| SQN | 0.78 | -0.25 | -1.03 |
| Net PnL | Unknown | -$778.60 | N/A |

**The extended test reveals the 6-month results were likely:**
- Lucky variance (small sample)
- Survivorship bias (cherry-picked period)
- NOT representative of true edge

---

## Conclusion

The Mean Revert strategy in isolation **does not have a tradeable edge**. The 2-year backtest definitively shows:

1. **No statistical edge**: Negative expectancy, negative Sharpe, negative SQN
2. **Poor risk management**: Inverted risk:reward ratio
3. **Insufficient signal quality**: Too many failed signal checks
4. **Code bugs**: Trade management errors affecting execution

**Recommendation: Abandon MR-only mode. Return to combined TF+MR approach or redesign MR signal generation from scratch.**

---

*Report generated by ORACLE v3.4*
*Date: 2024-12-24*
*Backtest Run ID: 880b6604-1fdc-4cb0-b770-8195eda1a937*
