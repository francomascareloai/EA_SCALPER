## ORACLE Output
AGENT: ORACLE
VERSION: 3.4
CLAUDE_MD_VERSION: 3.10.23
STATUS: COMPLETE
ROUND: 5 of 6

---

# TrendFollow Validation Suite Design

## Executive Summary

This document defines a comprehensive validation suite to prove/disprove the parameter recommendations from Rounds 1-4. The approach follows a **falsification-first** protocol: invest minimal time in quick disproof tests before committing to expensive full backtests.

**Key Decision**: Ghost Test (1 hour) is the gatekeeper. If signals don't add value beyond filters, STOP immediately.

---

## 1. Backtest Suite Design

### 1.1 Parameter Configurations to Test

| Config | sep_ticks | touch_dist | SL_buffer | Expected Behavior |
|--------|-----------|------------|-----------|-------------------|
| A - CONSERVATIVE | 25 | 0.15 * ATR | 0.50 * ATR | Fewer trades, higher WR, lower exposure |
| B - MODERATE | 20 | 0.17 * ATR | 0.45 * ATR | Balanced trade frequency and WR |
| C - AGGRESSIVE | 15 | 0.20 * ATR | 0.40 * ATR | More trades, lower WR, higher profit potential |
| **D - BALANCED+** | **20** | **0.175 * ATR** | **0.50 * ATR** | **Primary: 30-38 trades/mo, 53-56% WR** |

**CRITICAL**: All configs include bounce logic fix from line 182.

### 1.2 Data Split Strategy

| Split | Period | Purpose |
|-------|--------|---------|
| Training (IS) | 2003-2018 (70%) | Parameter optimization |
| Out-of-Sample (OOS) | 2018-2025 (30%) | Validation |
| Walk-Forward | 12 rolling 70/30 windows | Robustness check |

### 1.3 Success Criteria per Configuration

| Metric | Minimum | Target | Abort Threshold |
|--------|---------|--------|-----------------|
| Trade Count (monthly) | 15 | 30-38 | < 10 (signal starvation) |
| Profit Factor | 1.3 | 1.6 | < 0.8 |
| Win Rate | 45% | 53-56% | < 35% |
| Sharpe | 1.5 | 2.0 | < 0 |
| Max DD (observed) | - | 2.5% | > 4.0% |

---

## 2. Risk/Reward Metrics to Validate

### 2.1 Core Metrics

| Metric | Target | Calculation | Rationale |
|--------|--------|-------------|-----------|
| **Profit Factor** | > 1.3 | sum(wins) / sum(losses) | Basic edge indicator |
| **Win Rate** | 50-60% | winning_trades / total_trades | TrendFollow with tight entry |
| **R:R Ratio** | > 1.3:1 | avg_win / avg_loss | Required for 50% WR breakeven at 1:1 |
| **Expectancy** | > 1.5 pips/trade | (WR * avg_win) - ((1-WR) * avg_loss) | Per-trade profit expectation |
| **Recovery Factor** | > 3.0 | Net_Profit / Max_DD | Apex compatibility |

### 2.2 Expectancy Calculations

```
At 50% WR with SL=10 pips:
- For PF=1.3: avg_win = 13 pips
- Expectancy = 0.50 * 13 - 0.50 * 10 = 1.5 pips/trade

At 55% WR with SL=10 pips:
- Expectancy = 0.55 * 13 - 0.45 * 10 = 2.65 pips/trade
```

### 2.3 Execution Cost Impact

| Parameter | Value | Source |
|-----------|-------|--------|
| Typical XAUUSD spread | 1.5-3.0 pips | Historical observation |
| Conservative spread (1.5x) | 4.5 pips | Stress test value |
| Slippage (adverse) | 1.0 pip | Conservative assumption |
| **Total round-trip cost** | **5.5 pips** | Conservative scenario |

**Impact Analysis**:
- If SL = 10 pips and execution cost = 5.5 pips
- Effective SL = 15.5 pips
- Must recalculate expectancy with these costs

---

## 3. Monte Carlo Stress Test Design

### 3.1 Simulation Parameters

| Parameter | Value | Rationale |
|-----------|-------|-----------|
| Runs | 5,000 | Statistical significance |
| Bootstrap type | Block (preserves autocorrelation) | Realistic streak modeling |
| Block size | 5-10 trades | Preserves win/loss patterns |
| Starting equity | $50,000 | Apex standard |
| Position risk | 2.0% per trade | Per risk budget |

### 3.2 HWM/Floor Algorithm (Apex-Specific)

```python
def update_hwm_and_check_dd(balance, unrealized_pnl, current_hwm):
    """
    CRITICAL: This is the EXACT algorithm Apex uses.
    HWM includes unrealized PnL - the HWM trap.
    """
    current_equity = balance + unrealized_pnl
    new_hwm = max(current_hwm, current_equity)
    floor = new_hwm * 0.95  # 5% trailing DD
    is_breached = current_equity < floor
    current_dd_pct = ((new_hwm - current_equity) / new_hwm) * 100
    return new_hwm, floor, is_breached, current_dd_pct
```

### 3.3 MC Metrics to Track

| Metric | Target | Critical Threshold |
|--------|--------|-------------------|
| MC95DD | <= 2.5% | > 4.0% = NO-GO |
| MC99DD | <= 4.0% | > 5.0% = ABORT |
| Survival Rate | >= 95% | < 85% = NO-GO |
| P(Profit) | >= 85% | < 70% = NO-GO |

### 3.4 Worst-Case Sequence Analysis

Track per simulation:
- Maximum consecutive losses
- Recovery time from max DD (in trades and days)
- Frequency of DD > 2.0%
- Intra-trade HWM trap occurrences

---

## 4. Tiered Validation Plan

### Tier 1: Smoke Test (15 min each, 1 hour total)

| Aspect | Value |
|--------|-------|
| **Data** | 1 month (trending month, e.g., March 2024) |
| **Purpose** | Quick sanity check |
| **Configs** | All 4 (A, B, C, D) |
| **Pass** | >= 5 trades, Sharpe > 0 |
| **Fail** | 0 trades OR negative Sharpe |
| **Output** | Trade count, Sharpe, PF per config |

### Tier 2: Ghost Test Falsification (1 hour) - CRITICAL GATE

| Aspect | Value |
|--------|-------|
| **Data** | 6 months (mixed regimes) |
| **Purpose** | Prove signals add value beyond filters |
| **Method** | Replace signal generator with random entry, keep all filters |
| **Pass** | Full system >> Ghost (p < 0.05) |
| **Fail** | Full system ~ Ghost (signals are noise) |
| **Action if Fail** | PIVOT to pure filter-based approach |

### Tier 3: Focused Validation (1 hour per config, select 1-2)

| Aspect | Value |
|--------|-------|
| **Data** | 6 months including problem periods (ranging/choppy) |
| **Purpose** | Test robustness in adverse conditions |
| **Configs** | Best 1-2 from Tier 1 |
| **Pass** | PF > 1.0, WR > 45%, max daily loss < 1% |
| **Fail** | PF < 0.8 OR 3+ consecutive losing weeks |
| **Output** | Detailed performance breakdown by regime |

### Tier 4: Full WFA (4 hours)

| Aspect | Value |
|--------|-------|
| **Data** | 2003-2025 (full dataset) |
| **Purpose** | Comprehensive walk-forward analysis |
| **Configs** | Best config from Tier 3 |
| **Windows** | 12 rolling, 70% IS / 30% OOS |
| **Pass** | WFE >= 0.60, all OOS windows profitable |
| **Fail** | WFE < 0.30 OR > 3 OOS windows negative |
| **Output** | WFE, PSR, per-window performance |

### Tier 5: Monte Carlo Stress (2 hours)

| Aspect | Value |
|--------|-------|
| **Data** | Trade results from Tier 4 |
| **Purpose** | Stress test under randomized conditions |
| **Runs** | 5,000 block bootstrap |
| **Pass** | MC95DD <= 2.5%, survival >= 95% |
| **Fail** | MC95DD > 4% OR survival < 85% |
| **Output** | DD distribution, survival curves |

### Tier 6: Overfitting Detection (30 min)

| Aspect | Value |
|--------|-------|
| **Method** | DSR, PSR, PBO calculation |
| **Pass** | PSR >= 0.85, DSR > 0, PBO < 15% |
| **Fail** | DSR < 0 (confirmed overfitting) |
| **Output** | Overfitting metrics with confidence |

### Validation Timeline

| Phase | Duration | Cumulative |
|-------|----------|------------|
| Pre-validation (Gate 0, setup) | 30 min | 0.5 hr |
| Tier 1: Smoke tests | 1 hr | 1.5 hr |
| Tier 2: Ghost test | 1 hr | 2.5 hr |
| Tier 3: Focused validation | 2 hr | 4.5 hr |
| Tier 4: Full WFA | 4 hr | 8.5 hr |
| Tier 5: Monte Carlo | 2 hr | 10.5 hr |
| Tier 6: Overfitting | 0.5 hr | 11 hr |
| **Total** | **~12 hours** | |

**Critical Path**: Ghost test (Tier 2) is the gatekeeper. If it fails, save 9+ hours.

---

## 5. GO/NO-GO Criteria

### 5.1 Gate Structure

| Gate | Check | Pass | Critical Fail |
|------|-------|------|---------------|
| **0** | Data Quality | No nulls, monotonic timestamps | Any data issue |
| **1** | Sample Size | >= 100 trades, >= 2 years OOS | < 50 trades |
| **2** | Performance | Sharpe >= 1.5, SQN >= 2.0, DD <= 2.5% | Sharpe < 0, DD > 4% |
| **2.5** | Execution Realism | CONSERVATIVE scenario profitable | Edge disappears with costs |
| **3** | Walk-Forward | WFE >= 0.60 | WFE < 0.30 |
| **4** | Monte Carlo | MC95DD <= 2.5%, survival >= 95% | MC99DD > 5% |
| **5** | Overfitting | PSR >= 0.85, DSR > 0 | DSR < 0 |

### 5.2 Decision Matrix

| Outcome | Action |
|---------|--------|
| All gates PASS | **GO** - Proceed to paper trading |
| 1-2 minor fails | **CAUTION** - Address issues, retest |
| Any critical fail | **NO-GO** - Back to parameter design |
| Missing WFA/MC | **BLOCKED** - Cannot make decision |
| Gate 0 fail | **BLOCKED** - Fix data first |

### 5.3 Abort Conditions (Immediate NO-GO)

- DSR < 0 (confirmed overfitting)
- WFE < 0.30 (strategy does NOT generalize)
- MC99DD > 5% (Apex blow-up risk)
- Ghost test shows signals = noise
- Zero trades in any tier test
- CONSERVATIVE scenario fails any critical threshold

---

## 6. Execution Realism Validation (Gate 2.5)

### 6.1 Scenario Matrix

| Scenario | Spread Model | Slippage Model | Latency Model | Purpose |
|----------|--------------|----------------|---------------|---------|
| BASELINE | Observed bid/ask | 0 | 0 | Reference only |
| **CONSERVATIVE** | observed * 1.5 | max(0.5 * spread, 1 pip) adverse | Next 3 ticks | **Must pass for GO** |
| HOSTILE | observed * 2.0 | 1.0 * spread adverse | Next bar open + slip | Stress test |

### 6.2 XAUUSD Specific Values

| Parameter | BASELINE | CONSERVATIVE | HOSTILE |
|-----------|----------|--------------|---------|
| Spread | 2.0 pips | 3.0 pips | 4.0 pips |
| Slippage | 0 | 1.5 pips | 2.0 pips |
| Latency | 0 | 3 ticks | 1 bar |
| **Total cost/RT** | **2.0 pips** | **4.5 pips** | **6.0 pips** |

### 6.3 Pass/Fail Rules

- If BASELINE passes but CONSERVATIVE fails: **NO-GO** (execution-sensitive edge)
- If CONSERVATIVE Sharpe < 50% of BASELINE Sharpe: **CAUTION** (fragile edge)
- If CONSERVATIVE passes all thresholds: **PROCEED** to Monte Carlo

---

## 7. Falsification Tests (From CLAUDE.md Patterns)

### 7.1 Ghost Test (Edge Attribution)

```python
# Replace signal generator with random
def ghost_signal():
    return random.choice(['LONG', 'SHORT', None])

# Keep all filters: regime, session, time gates
# If performance(ghost) ~ performance(full):
#   -> Filters are the edge, signals are noise
#   -> PIVOT to pure filter-based approach
```

### 7.2 Permutation Importance

```python
# Shuffle sep_ticks trigger array
# Shuffle touch_dist filter array
# Measure delta metric for each
# If delta ~= 0, parameter is noise
```

### 7.3 Shifted Levels

```python
# Add random offsets to level detection
# touch_dist_shifted = touch_dist + random.uniform(-0.05, 0.05) * ATR
# If performance unchanged, level precision is illusory
```

---

## 8. Pre-Mortem: What Could Go Wrong

| Risk | Probability | Impact | Mitigation |
|------|-------------|--------|------------|
| Signal Starvation | HIGH | NO-GO | Track trade count per tier, abort if < 15/month |
| Regime Overfitting | MEDIUM | Weak OOS | WFA with multiple regime windows |
| HWM Trap | HIGH | Apex blow | Intra-trade DD in MC simulations |
| Execution Cost Sensitivity | MEDIUM | Edge disappears | CONSERVATIVE scenario test |
| Bounce Fix Side Effects | LOW | New bugs | Compare before/after distribution |
| Data Mining Bias | MEDIUM | False positive | DSR check, require > 0 |
| Time Gate Interference | LOW (backtest) | Missed closes | Verify backtest includes time gates |

---

## 9. Handoff Recommendations

### Next Immediate Step: FORGE

Implement the following before validation can proceed:
1. Bounce logic fix at line 182
2. Parameter configuration structure for A/B/C/D
3. Ghost test infrastructure (random signal replacement)

### Post-Validation Handoff

| Outcome | Next Agent | Action |
|---------|------------|--------|
| GO | SENTINEL | Calculate position sizing, verify Apex compliance |
| CAUTION | FORGE | Implement mitigations, re-run specific tiers |
| NO-GO | CRUCIBLE | Revisit strategy design fundamentals |

---

## 10. Appendix: Calculation Examples

### Expectancy Calculation

```
# Formula: E = (WR * avg_win) - ((1-WR) * avg_loss)
#
# Example at 53% WR, 10 pip SL, R:R 1.3:1:
# avg_win = 13 pips, avg_loss = 10 pips
# E = 0.53 * 13 - 0.47 * 10
# E = 6.89 - 4.70 = 2.19 pips/trade
#
# With 30 trades/month:
# Monthly expected = 30 * 2.19 = 65.7 pips
```

### MC95DD Interpretation

```
# 5000 MC runs
# Sort max DD from each run
# MC95DD = DD at 95th percentile (4750th sorted value)
#
# If MC95DD = 2.3%:
#   - 95% of simulated paths stayed within 2.3% DD
#   - 5% of paths exceeded 2.3% DD
#   - Apex buffer = 5% - 2.3% = 2.7% safety margin
```

---

## Summary

This validation suite provides a structured, falsification-first approach to proving/disproving the TrendFollow parameter recommendations. The Ghost Test at Tier 2 is the critical gate - if signals don't add value beyond filters, we pivot immediately without wasting 10+ hours on full validation.

**Primary candidate**: Config D (BALANCED+) with sep_ticks=20, touch_dist=0.175*ATR, SL_buffer=0.50*ATR

**Go/No-Go decision requires**: All 6 gates pass, Ghost test shows signals add value, MC95DD <= 2.5%, DSR > 0, WFE >= 0.60

**Total validation time**: ~12 hours (with potential early exit at Ghost Test)
