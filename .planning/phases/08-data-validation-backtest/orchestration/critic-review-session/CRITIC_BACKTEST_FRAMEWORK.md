# CRITIC ADVERSARIAL REVIEW
## Backtest Framework & Execution (Phases 6-7)

**Artifact**: Phase 6 (06-PHASE-PLAN.md) + Phase 7 (07-PHASE-PLAN.md)
**Type**: Plan/Framework
**Reviewer**: CRITIC v1.1
**Date**: 2025-12-15
**Sequential Thinking**: 15 thoughts applied

---

## VERDICT: CONDITIONAL APPROVAL

The plans have solid structure but contain **5 CRITICAL issues** that MUST be addressed before execution.

---

## CRITICAL ISSUES (Must Fix)

### 1. Monte Carlo DD Threshold Too Loose
**Location**: Phase 6.3 / Phase 7.3 (Monte Carlo Configuration)
**Description**: Plan specifies "MC 95th percentile DD < 8%"
**Impact**: CRITIC spec requires "MC95 DD < 4%" for Apex compliance. With Apex's 5% trailing DD rule, an 8% threshold means 5% of scenarios exceed 8% DD - guaranteeing account blow-up.
**Fix**:
- Change threshold from 8% to 4% in both phase plans
- Update monte_carlo.py `ftmo_verdict` logic for Apex limits
- Add Apex-specific thresholds as configuration option

### 2. WFA Validation Misses 2024 Data
**Location**: Phase 6.2 (WFA Window Schedule)
**Description**: Window schedule ends at "Window 12: IS=2023-01 to 2023-08, OOS=2023-09 to 2023-10"
**Impact**: 2024 is only tested in baseline OOS (Phase 7.1), not in WFA validation. If 2024 is regime-anomalous (it is - record gold highs, low vol), strategy may pass WFA but fail live.
**Fix**:
- Extend WFA windows to include 2024
- Add Windows 13-14: IS through early 2024, OOS through late 2024
- Or: Reduce window count but extend date range

### 3. Trailing DD Ignores Unrealized P/L
**Location**: run_backtest.py / Phase 7.1 Apex Compliance
**Description**: Backtest tracks realized equity only. Apex trailing DD is from HIGH-WATER MARK including UNREALIZED P/L.
**Impact**: Position opens +$500 unrealized (HWM increases), reverses to -$200 unrealized. Actual DD = $700/$HWM. Backtest only sees final realized. This can cause 1-2% DD underestimation.
**Fix**:
- Implement tick-level HWM tracking with unrealized P/L
- Update on every quote tick if position exists
- Calculate DD from peak unrealized equity, not closed balance

### 4. Task Dependency Contradiction
**Location**: Phase 7 (Task 7.3)
**Description**: Phase 7 claims "All 4 main agents spawn simultaneously" but Task 7.3 says "INPUT: Trade results from baseline backtest (Task 7.1)"
**Impact**: MC simulation requires baseline trade data. If running parallel, 7.3 starts before 7.1 finishes - no input data available.
**Fix**:
- Option A: Run 7.1 first, then 7.2/7.3/7.4 parallel
- Option B: MC uses pre-existing trade data from prior validated backtest (specify source)
- Option C: Split Phase 7 into 7a (baseline) and 7b (validation)

### 5. DSR/PBO Metrics Not Calculated
**Location**: Phase 6.2, 6.3 and Phase 7.2, 7.3
**Description**: CRITIC spec requires DSR > 0 and PBO < 25% for overfitting validation. Neither WFA nor MC calculates these.
**Impact**: Cannot verify strategy is not overfitted to historical data. deflated_sharpe.py exists in scripts/oracle/ but is not integrated.
**Fix**:
- Integrate deflated_sharpe.py into WFA pipeline
- Add PBO calculation using Combinatorial Purged CV methodology
- Add DSR/PBO to success criteria table

---

## HIGH ISSUES

### 6. WFA Uses Trade-Index Windows, Not Calendar-Based
**Location**: walk_forward.py
**Description**: Script divides by trade count, plan specifies date ranges. Trade clustering in volatile periods creates regime imbalance.
**Fix**: Implement date-based window slicing or add regime-aware sampling.

### 7. Monte Carlo Calibrated for FTMO, Not Apex
**Location**: monte_carlo.py
**Description**: Uses ftmo_daily_limit=5%, ftmo_total_limit=10%. Apex only has trailing DD (5%), different risk profile.
**Fix**: Add Apex-specific limits: trailing_dd_limit=5%, no separate total limit.

### 8. Block Bootstrap Capped at 20 Trades
**Location**: monte_carlo.py, optimal_block_size()
**Description**: Block size clamped 5-20 regardless of autocorrelation. Scalping strategies may have 30-50 trade streaks.
**Fix**: Increase cap to 50 or make configurable based on measured autocorrelation.

### 9. 30% Daily Profit Consistency Rule Not Verified
**Location**: Phase 7.1 Apex Compliance
**Description**: Plan mentions verification but no implementation. MetricsCalculator doesn't compute daily profit distribution.
**Fix**: Add daily profit analysis: max(daily_profit) / account_value check.

### 10. WFA Purge Gap Not Specified
**Location**: Phase 6.2
**Description**: Plan doesn't specify purge between IS/OOS. walk_forward.py default is purge_gap=0.
**Impact**: Last IS tick and first OOS tick could be milliseconds apart - microstructure leakage.
**Fix**: Specify purge_gap=100+ trades (or 1 hour equivalent) for tick-level data.

---

## MEDIUM ISSUES

### 11. 5000 MC Sims May Be Insufficient
For 99th percentile accuracy, need 10000+ sims. 5000 sims = ~50 samples at 99th percentile - high variance.

### 12. Partial Fill and Order Rejection Not Tested
Parameters exist in run_backtest.py but plan doesn't require testing these scenarios.

### 13. Dynamic Spread Modeling Missing
Fixed slippage regardless of time/volatility. No stress spread (150+ points during news) simulation.

### 14. Weekend Gap Risk Not Modeled
Sunday open gaps (50-100 pips) not simulated. Position held Friday EVENING to Monday ASIAN = gap exposure.

### 15. Session Catalog Loading Not Verified
Phase 7.4 uses session catalogs but run_backtest.py loads from config.yaml active_dataset. Session path override not tested.

---

## LOW ISSUES

### 16. WFA Split Documentation Error
Plan says 80/20 but example shows 10 months IS + 2 months OOS = 83%/17%.

### 17. Strategy Import Validation Not Explicit
Phase 6.1 says "Validate strategy compiles" but no explicit import test step.

### 18. Catalog Row Count Assumed
Phase 6 assumes Phase 5 validated catalogs. No re-verification before backtest.

---

## ASSUMPTIONS CHALLENGED

| Assumption | Challenge | Recommendation |
|------------|-----------|----------------|
| Strategy loads correctly | File exists but may have import errors | Add explicit Python import test in 6.1 |
| 80/20 split is optimal | Literature suggests 70/30 for regime changes | Test multiple split ratios |
| 5000 sims sufficient | 99th percentile noisy with 50 samples | Use 10000+ for production |
| 2024 is representative OOS | 2024 had record highs, low vol anomaly | Include 2024 in WFA windows |
| Fixed slippage realistic | News events cause 10x+ spread | Add volatility-dependent slippage |

---

## EDGE CASES NOT COVERED

| Scenario | Risk | Recommendation |
|----------|------|----------------|
| Position open at 4:58 PM with 500ms latency | Close order arrives after 4:59 PM cutoff | Test extreme latency scenarios |
| Order rejected at emergency close time | Position left open overnight | Test rejection handling in time-critical window |
| Partial fill during force-close | Orphan position risk | Test partial fill at cutoff |
| Sunday 100-pip gap with position | Unexpected overnight exposure | Model weekend gap scenarios |
| Flash crash (10-second 500-pip move) | Stop-loss slippage exceeds risk | Stress test with historical flash crashes |

---

## STRESS TEST GAPS

| Condition | Current Coverage | Recommendation |
|-----------|-----------------|----------------|
| Spread 3x normal | Not tested | Add high-spread simulation mode |
| Latency 10x normal | Parameter exists, not tested | Add latency stress test |
| Low liquidity (Asia) | Session backtest exists | Verify spread modeling in ASIAN catalog |
| Flash crash | Not modeled | Include Aug 2024 and historical crash data |
| Correlation breakdown | Not tested | Add regime detection failure scenarios |

---

## MANUAL VERIFICATION NEEDED

- [ ] Verify GoldScalperStrategy implements proper on_start/on_bar/on_stop lifecycle
- [ ] Confirm time gate logic is in strategy, not just config
- [ ] Check if strategy properly closes positions in on_stop
- [ ] Verify no look-ahead bias in strategy signal generation
- [ ] Test session catalogs load correctly with run_backtest.py
- [ ] Confirm deflated_sharpe.py is functional and can integrate

---

## CONFIDENCE: HIGH

**Reason**:
- Reviewed actual code implementations (monte_carlo.py, walk_forward.py, run_backtest.py)
- Verified catalog paths and strategy files exist
- Compared plan specifications against implementation details
- Cross-referenced with Apex rules from CRITIC spec
- Applied all 7 adversarial techniques systematically

---

## PRE-MORTEM SUMMARY

**Most Likely Failure Mode**:
Strategy passes WFA/MC but fails live due to trailing DD calculated without unrealized P/L. A position goes +$1000 unrealized (HWM rises), then reverses to close at -$500. Actual trailing DD from HWM is $1500/$HWM = much higher than backtest calculated. Apex terminates account.

**Second Most Likely**:
2024 regime shift causes performance collapse. WFA validated only through Oct 2023. Strategy optimized for 2020-2023 volatility regime. 2024's low-vol consolidation pattern causes slow bleed-out that looks like bad luck initially, triggers trailing DD halt after 3 weeks.

**Third Most Likely**:
Monte Carlo passed at DD95=6% (under 8% threshold) but should have been blocked at 4%. First losing streak in live exceeds DD buffer, hits Apex 5% trailing DD limit.

**Mitigation**: Fix all 5 CRITICAL issues before Phase 7 execution. Extend WFA to cover 2024. Implement unrealized P/L tracking. Lower MC threshold to 4%. Add DSR/PBO calculations.

---

## NEXT STEPS

1. **Immediate**: Update Phase 6.3 and 7.3 MC threshold from 8% to 4%
2. **Before Phase 7**: Extend WFA window schedule to include 2024
3. **Before Phase 7**: Fix task dependency issue (7.3 needs 7.1 first)
4. **Implementation Required**: Add unrealized P/L tracking to backtest
5. **Implementation Required**: Integrate DSR/PBO calculations
6. **Validation**: Manual review of GoldScalperStrategy time gate implementation

---

*CRITIC v1.1 - "Every bug found now is a loss prevented later."*
