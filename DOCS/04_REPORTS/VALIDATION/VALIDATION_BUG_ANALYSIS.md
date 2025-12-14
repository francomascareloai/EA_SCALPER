# 🔮 ORACLE VALIDATION BUG ANALYSIS

**Date:** 2025-12-03  
**Status:** 🔴 CRITICAL BUGS FOUND  
**Investigation:** Python Backtester Validation Failure

---

## Executive Summary

The COMPREHENSIVE_VALIDATION.md reported impossible metrics:
- **Max Drawdown:** 1,075,000% (IMPOSSIBLE - bug confirmed)
- **Sharpe Ratio:** -29.73 (abnormally negative)
- **Win Rate:** 34.7% (possible strategy issue)
- **WFE:** -0.47 (poor out-of-sample performance)

**Root cause identified:** Multiple bugs in the validation pipeline.

---

## 🐛 BUG #1: WRONG METRIC KEY (CRITICAL - THE SMOKING GUN)

### Location
`scripts/backtest/comprehensive_validation.py` lines 249, 329, 444

### Problem
The validation script uses `bt_result.get('max_drawdown', 0) * 100` but `ablation_study.py` returns:
- `max_drawdown`: **ABSOLUTE DOLLAR VALUE** (e.g., $10,750)
- `max_drawdown_pct`: **DECIMAL FRACTION** (e.g., 0.1075 for 10.75%)

### Evidence
`python
# ablation_study.py _calculate_metrics() returns:
return {
    'max_drawdown_pct': max_dd_pct,  # Correct key for percentage
    'max_drawdown': max_dd,           # Dollar value, NOT percentage!
    ...
}

# comprehensive_validation.py INCORRECTLY uses:
print(f"  Max DD: {bt_result.get('max_drawdown', 0)*100:.2f}%")  # BUG!
`

### Result
If max_drawdown = $10,750 (absolute), then:
- **Displayed:** $10,750 × 100 = 1,075,000%
- **Should be:** `max_drawdown_pct × 100 = 10.75%`

### Fix Required
`python
# Change ALL occurrences of:
bt_result.get('max_drawdown', 0)

# To:
bt_result.get('max_drawdown_pct', 0)
`

---

## 🐛 BUG #2: SIGNAL PARITY MISMATCH (CRITICAL)

### Location
`scripts/backtest/strategies/ea_logic_python.py` lines 142, 534
`scripts/backtest/tick_backtester.py` lines 558-572

### Problem
Python backtester uses **drastically relaxed thresholds** compared to MQL5:

| Parameter | MQL5 (Real EA) | Python (ea_logic_python.py) | Python (tick_backtester.py) |
|-----------|----------------|-----------------------------|-----------------------------|
| Min Score | **70** | 50 (hardcoded) | **40** |
| Min Confluences | **3** | 2 (hardcoded) | N/A |
| execution_threshold | 70 | 50 (default) | **40** |

### Evidence
`cpp
// MQL5: CConfluenceScorer.mqh line 869
m_min_score = TIER_B_MIN;       // 70 minimum
m_min_confluences = 3;          // At least 3 factors
`

`python
# ea_logic_python.py line 534 - HARDCODED, ignores config!
valid = score >= 50 and confs >= 2 and direction != SignalType.NONE

# tick_backtester.py line 558-561 - Intentionally relaxed for "debugging"
ea_cfg = EAConfig(
    execution_threshold=40.0,   # Very relaxed for debugging
    confluence_min_score=40.0,  # Very relaxed for debugging
`

### Impact
- Python accepts trades that MQL5 would REJECT
- Win rate drops because low-quality signals are taken
- More trades = more losses = higher drawdown

### Fix Required
1. `ea_logic_python.py` line 534: Change hardcoded `50, 2` to use `self.cfg` values
2. `ea_logic_python.py` line 142: Change default `execution_threshold` from 50 to 70
3. `tick_backtester.py` line 559-561: Change from 40 to 70 for production tests

---

## 🐛 BUG #3: SHARPE OVER-ANNUALIZATION (MODERATE)

### Location
`scripts/backtest/ablation_study.py` line 494

### Problem
`python
sharpe = np.mean(returns) / np.std(returns) * np.sqrt(252 * 288)
`
- Annualization factor: √(72,576) ≈ **269.4**
- Assumes 288 five-minute bars per trading day
- If trades are infrequent (e.g., 100 trades over 1 year), this over-amplifies noise

### Impact
- Small negative mean return → huge negative Sharpe
- Example: mean=-0.001, std=0.01 → Sharpe = -0.001/0.01 × 269 = **-26.9**

### Fix Required
`python
# Use actual trade frequency for annualization
trades_per_year = len(pnls)
annualization = np.sqrt(trades_per_year)
sharpe = np.mean(returns) / np.std(returns) * annualization
`

---

## 🐛 BUG #4: confluence_min_score UNUSED (MINOR)

### Location
`scripts/backtest/strategies/ea_logic_python.py`

### Problem
`EAConfig.confluence_min_score = 70.0` is defined but **never used** in the scoring logic.

The `ConfluenceScorerPython.score()` method uses hardcoded values instead of reading from config:
`python
# Line 534 - Should use config but doesn't!
valid = score >= 50 and confs >= 2  # Hardcoded!
`

### Fix Required
Pass config to scorer and use `self.cfg.confluence_min_score` instead of hardcoded 50.

---

## 📊 Corrected Metrics Estimate

If we fix Bug #1 (metric key) and assume the actual `max_drawdown_pct` is around 10.75%:

| Metric | Reported (Bug) | Estimated (Fixed) | Target |
|--------|----------------|-------------------|--------|
| Max Drawdown | 1,075,000% | ~10.75% | < 10% |
| Win Rate | 34.7% | ~34.7% (real issue) | ≥ 40% |
| Profit Factor | 0.80 | ~0.80 (real issue) | ≥ 1.5 |
| Sharpe | -29.73 | ~-1.5 to 0 | > 0 |

**Note:** Even with Bug #1 fixed, the strategy still shows poor performance. Bug #2 (threshold mismatch) is likely the root cause of bad win rate and profit factor.

---

## 🛠️ Recommended Fixes

### Priority 1: Fix Metric Key (5 min)
`python
# comprehensive_validation.py - Fix ALL 3 locations
# Line 249:
print(f"  Max DD: {bt_result.get('max_drawdown_pct', 0)*100:.2f}%")

# Line 329:
if bt_result.get('max_drawdown_pct', 1) < 0.10:

# Line 444:
| Max Drawdown | {bt_result.get('max_drawdown_pct', 0)*100:.2f}%
`

### Priority 2: Fix Signal Parity (30 min)
`python
# ea_logic_python.py line 142:
execution_threshold: float = 70.0   # Was 50.0

# ea_logic_python.py line 534 - Use config instead of hardcoded:
valid = score >= self.min_score and confs >= self.min_confluences

# tick_backtester.py - Remove debug relaxation:
ea_cfg = EAConfig(
    execution_threshold=70.0,   # Match MQL5
    confluence_min_score=70.0,  # Match MQL5
`

### Priority 3: Fix Sharpe Calculation (15 min)
`python
# Use proper annualization based on trade frequency
`

---

## 📋 Verification Steps After Fix

1. Re-run comprehensive_validation.py
2. Verify max_drawdown shows reasonable % (5-15%)
3. Verify Sharpe is in normal range (-3 to +5)
4. Compare Python signal count vs MQL5 Strategy Tester
5. Validate trade entry/exit prices match

---

## 🔮 ORACLE Verdict

| Issue | Severity | Fix Complexity |
|-------|----------|----------------|
| Bug #1: Metric Key | 🔴 CRITICAL | Easy (5 min) |
| Bug #2: Thresholds | 🔴 CRITICAL | Medium (30 min) |
| Bug #3: Sharpe | 🟡 MODERATE | Easy (15 min) |
| Bug #4: Unused Config | 🟢 MINOR | Easy (10 min) |

**RECOMMENDATION:** Fix Bug #1 and #2 immediately before any further validation. The current metrics are meaningless due to these bugs.

---

*Generated by ORACLE v2.2 - Statistical Truth-Seeker*
*Investigation Date: 2025-12-03*
