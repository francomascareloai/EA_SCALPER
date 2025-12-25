# CRITIC v2.1 - ADVERSARIAL REVIEW (FINAL)

```
AGENT: CRITIC
VERSION: 2.1
ROUND: FINAL (Post Round 6)
STATUS: COMPLETE
MODE: EXTERNAL-CRITIC (fresh context, falsification-first)
CLAUDE_MD_VERSION: 3.10.23
DATE: 2024-12-24
```

---

## EXECUTIVE SUMMARY

### VERDICT: **BLOCKED**

**Cannot issue GO or CONDITIONAL_GO** until blocking conditions are resolved.

| Category | Count | Details |
|----------|-------|---------|
| BLOCKS | 4 | Ghost Test pending, WR unverified, signal count unknown, sep_ticks unjustified |
| WARNINGS | 4 | Loss clustering, Hurst lag, scale-out complexity, risk conservatism |
| ACCEPTED | 7 | Time gates, DD throttle, HWM calc, Profit Panic, SL buffer, framework, checklist |

### CONFIDENCE: 4.5/10 (LOW-MEDIUM)

**Rationale**: Framework design is sound and Apex-compliant, but core performance claims rest on unverified assumptions. The proposed 5.5x increase in sep_ticks threshold (4 to 22) lacks empirical justification and may cause signal starvation.

### MOST LIKELY FAILURE MODES

1. **Signal Starvation** (P=40%): sep_ticks=22 too restrictive, insufficient trades during evaluation
2. **HWM Trap** (P=25%): Scale-out creates unrealized peaks that raise floor permanently
3. **Win Rate Degradation** (P=20%): Tighter entry filters fewer trades but not better trades

---

## 1. INVERSION ATTACK

**Question**: "What would make this strategy FAIL catastrophically?"

### Findings

| Assumption Inverted | Consequence |
|---------------------|-------------|
| "Tighter entry = better WR" | Could filter out good setups, keeping only edge cases |
| "Scale-out locks profit" | Creates HWM spikes that raise trailing DD floor |
| "Hurst filter blocks bad regimes" | 2-3 bar lag means late entry AND late exit |
| "0.40% risk is safe" | Too conservative = can't recover from small losing streaks |

### Key Insight

The Round 1-6 analysis may be **over-engineering entry** when the real issue is **exit management and regime timing**. The problematic windows (Mar/Jun 2024) showed correct entries but poor exits. Tightening entry doesn't fix exit.

---

## 2. PRE-MORTEM

**Scenario**: "It's 2026. The Apex account was terminated. What happened?"

### Most Likely Narratives

**Narrative A: The Signal Drought** (P=40%)
> After implementing sep_ticks=22, the strategy went silent for 3 weeks during the evaluation period. The few signals that fired had normal win rate (~45%), but with only 12 trades in the first month, a single 3-loss streak put us at -1.2% daily DD. We reduced size per protocol, but couldn't generate enough trades to recover. Evaluation failed due to insufficient activity.

**Narrative B: The HWM Trap** (P=25%)
> A strong trend generated +2.5% unrealized on a LONG position. The scale-out at 1R locked 50%, but the remaining 50% continued to +3.5% before reversing sharply. HWM was set at the peak. The reversal hit SL, but the new floor was so high that the next 2 normal losses triggered trailing DD breach.

**Narrative C: The Regime Whipsaw** (P=20%)
> Market transitioned from trending to ranging. Hurst dropped from 0.62 to 0.48 over 5 bars. Due to 2-3 bar lag in Hurst calculation, we entered 2 trades in the "dead zone" between regimes. Both hit SL. When Hurst finally confirmed ranging, we were already down 0.8% daily.

---

## 3. STRESS TEST

### Extreme Conditions Applied

| Condition | Impact on Strategy | Survival? |
|-----------|-------------------|-----------|
| Spread 3x normal | SL buffer 2x may be insufficient; need 3x+ | UNCERTAIN |
| Slippage 5x normal | Scale-out partial fills become problematic | FAIL |
| Latency 10x (500ms) | Time gate at 4:55 PM may miss close | FAIL |
| Weekend gap 2% | Conservative sizing limits damage to ~0.4% | PASS |
| Flash crash 3% | Broker SL won't fill at expected price | UNCERTAIN |
| Asia session (low liquidity) | Breakout variant suffers false signals | FAIL |

### Critical Stress Findings

1. **sep_ticks=22 under low volatility**: In quiet markets (ATR < 20th percentile), EMA separation rarely reaches 22 ticks. Strategy goes completely silent.

2. **touch_dist=0.15*ATR precision claim**: With typical ATR of 2.5 pips, touch_dist = 0.375 pips. This is SMALLER than spread in most sessions. Precision is illusory.

3. **Scale-out under fast reversal**: If price hits 1R, we exit 50%, then market reverses in 2 bars to hit SL. Net result: worse than full exit at 1R.

---

## 4. REGIME SENSITIVITY

### Hurst Lag Analysis

| Event | Hurst Value | Actual State | Lag | Consequence |
|-------|-------------|--------------|-----|-------------|
| Trend starts | 0.52 | Trending | +2 bars | Late entry, missed best setup |
| Trend ends | 0.58 | Ranging | +3 bars | Late exit, caught in reversal |
| Range starts | 0.48 | Ranging | +2 bars | No trade (correct) |
| Range ends | 0.44 | Trending | +2 bars | Missed early trend |

### Critical Gap

**Hurst gates ENTRY but not EXIT**. A position entered during H=0.62 (trending) remains open even if H drops to 0.45 (ranging). The exit logic (trailing stop, scale-out) doesn't account for regime change mid-trade.

### Proposed Fix (Not in Round 1-6)

Add regime-aware exit: If H drops below 0.50 while in position, tighten trailing stop to 0.5R or trigger immediate partial exit.

---

## 5. APEX TRAP SCENARIOS

### Scenario Analysis

| Trap | Setup | Outcome | Defense Status |
|------|-------|---------|----------------|
| HWM spike from unrealized | +2% unrealized, reverses | New floor traps account | PARTIAL (Profit Panic at 0.5%) |
| Overnight position | Trade at 4:50 PM | Force-close at 4:55 PM | COVERED |
| 30% daily profit | Exceptionally good day | Block new trades | COVERED (live only) |
| Trailing DD after recovery | Recover to HWM-0.5%, then lose | Very tight floor | NOT ADDRESSED |

### HWM Trap Deep Dive

The Profit Panic Rule (exit at 0.5% unrealized) is set too low for the strategy's typical R:R. With target 1.5R and entry risk 0.40%, the expected unrealized peak is:

```
Expected unrealized = 0.40% * 1.5 = 0.60%
```

This exceeds the Profit Panic threshold (0.5%), meaning the rule would trigger on nearly every winning trade, potentially cutting winners short.

**Recommendation**: Raise Profit Panic to 0.75% or 1.0% unrealized.

---

## 6. ASSUMPTION AUDIT

### Complete Assumption Table

| ID | Assumption | Source | Validation Status | Risk if Wrong |
|----|------------|--------|-------------------|---------------|
| A1 | Win rate will improve with tighter entry | CRUCIBLE R6 | UNVERIFIED | HIGH - survival model fails |
| A2 | sep_ticks=22 is optimal | ORACLE R6 | UNVERIFIED | HIGH - signal starvation |
| A3 | touch_dist=0.15*ATR is precise enough | CRUCIBLE R6 | UNVERIFIED | MEDIUM - false negatives |
| A4 | Scale-out at 1R helps overall P&L | SENTINEL R6 | UNVERIFIED | MEDIUM - may hurt in reversals |
| A5 | Hurst >= 0.55 identifies trending regimes | All | PARTIALLY VERIFIED | HIGH - lag causes misclassification |
| A6 | 45% win rate is achievable | SENTINEL R6 | CONTRADICTED | HIGH - observed 40-42% in hard windows |
| A7 | Losses are approximately independent | SENTINEL R6 | UNVERIFIED | MEDIUM - clustering changes survival |
| A8 | Slippage <= 0.5 pips average | SENTINEL R6 | UNVERIFIED | LOW - affects PF but not survival |
| A9 | Latency <= 50ms median | SENTINEL R6 | UNVERIFIED | LOW - affects execution quality |
| A10 | Regime filter blocks 95%+ of bad trades | ORACLE R6 | UNVERIFIED | HIGH - core edge assumption |
| A11 | Current code has look-ahead bias | All | VERIFIED | N/A - fixed in trend_follow.py |
| A12 | Bounce logic bug exists | ORACLE R2 | VERIFIED | N/A - identified and fix proposed |
| A13 | Mar/Jun 2024 failures are fixable | All | ASSUMED | MEDIUM - may be market structure |
| A14 | ATR percentile thresholds are correct | CRUCIBLE R6 | UNVERIFIED | MEDIUM - affects breakout variant |
| A15 | 0.40% base risk is appropriate | SENTINEL R6 | UNVERIFIED | LOW - conservative default is safe |

### Assumptions by Verification Status

- **VERIFIED**: A11, A12 (2/15 = 13%)
- **PARTIALLY VERIFIED**: A5 (1/15 = 7%)
- **CONTRADICTED**: A6 (1/15 = 7%)
- **UNVERIFIED**: A1-A4, A7-A10, A13-A15 (11/15 = 73%)

**73% of assumptions are unverified.** This is a BLOCKING concern.

---

## 7. GHOST TEST PREDICTION

### Test Design

**Objective**: Determine if TrendFollow signals add edge beyond the regime/session filters.

**Methodology**:
```python
# Null hypothesis: Signals are noise; filters provide all edge
# Test: Replace generate_trend_follow_candidates() with random.choice(['LONG', 'SHORT', None])
# Keep: Hurst filter, session filter, time gates, DD throttle, position sizing
# Compare: Equity curves, Sharpe, MC95DD over 5 years
```

### Prediction

| Outcome | Probability | Interpretation |
|---------|-------------|----------------|
| Full system >> Baseline | 30% | Signals have genuine edge |
| Full system ~ Baseline | 40% | Filters are the edge, not signals |
| Full system < Baseline | 30% | Signals are actively harmful (noise-fitting) |

**Most likely (40%)**: The regime/session filters are doing the heavy lifting. The specific entry logic (EMA bounce, breakout) adds marginal value that may not survive costs.

### If Ghost Test Fails

Recommended pivot: **Simplified Filter-First Strategy**
- Keep: Hurst filter, session windows, time gates, DD throttle
- Simplify: Replace complex entry with simple momentum (e.g., close > open AND Hurst > 0.55)
- Focus: Exit management as the primary edge

---

## 8. ALTERNATIVES PROPOSED (Discovery Mode)

### Alternative 1: Simplified Filter-First

| Aspect | Current Proposal | Alternative |
|--------|------------------|-------------|
| Entry logic | Complex EMA bounce + breakout | Simple momentum (close > prev_high) |
| Parameters | 5 tuneable params | 2 tuneable params |
| Regime filter | Hurst >= 0.55 | Hurst >= 0.55 (same) |
| Exit | Scale-out 3 tiers | Simple 1R target + trailing |

**Expected Upside**: Simpler = more robust, easier to validate, faster to falsify
**Key Risk**: May have lower raw performance in ideal conditions
**Fastest Falsification**: Run 3-month backtest, compare Sharpe to current proposal

### Alternative 2: Regime-Adaptive Dual Strategy

| Aspect | Trending (H > 0.55) | Ranging (H < 0.45) |
|--------|---------------------|-------------------|
| Strategy | TrendFollow (current) | MeanRevert (new) |
| Entry | EMA bounce/breakout | Range bound reversals |
| Exit | Trailing stop | Fixed target (small R) |
| Risk | 0.40% | 0.20% (half size in ranging) |

**Expected Upside**: Captures more market time, diversifies regime exposure
**Key Risk**: Complexity, potential for regime misclassification
**Fastest Falsification**: Backtest MeanRevert alone in ranging windows, verify positive expectancy

---

## 9. ACCEPTANCE MATRIX

### BLOCKS (Must Resolve Before Proceeding)

| ID | Issue | Resolution Path | Owner |
|----|-------|-----------------|-------|
| B1 | Ghost Test not executed | Run Ghost Test per Section 7 design | ORACLE |
| B2 | Win Rate assumption contradicted | Backtest with new params, verify WR >= 42% | ORACLE |
| B3 | Signal count unknown | Backtest new params, count trades/month, require >= 30 | ORACLE |
| B4 | sep_ticks=22 unjustified | Provide empirical basis OR test range [10, 15, 20, 25] | CRUCIBLE |

### WARNINGS (Monitor, Don't Block)

| ID | Issue | Mitigation | Owner |
|----|-------|------------|-------|
| W1 | Loss clustering not modeled | Add MC simulation with correlated losses | ORACLE |
| W2 | Hurst lag (2-3 bars) | Document as known limitation, consider regime-aware exit | CRUCIBLE |
| W3 | Scale-out complexity | Simplify to 2 tiers or test 3-tier vs 1-tier | SENTINEL |
| W4 | 0.40% risk possibly too conservative | Test 0.50% in parallel, compare growth vs survival | SENTINEL |

### ACCEPTED (Proceed As-Is)

| ID | Item | Rationale |
|----|------|-----------|
| A1 | Time gates (4:30/4:55/4:59 ET) | Comprehensive, buffer included |
| A2 | DD throttle (6-tier) | Progressive, conservative, correct thresholds |
| A3 | HWM calculation | Conservative pricing (BID/ASK), never decreases |
| A4 | Profit Panic Rule concept | Good idea, threshold may need adjustment |
| A5 | SL buffer 2x concept | Correct direction, verify empirically |
| A6 | Validation framework (6-phase) | Thorough, includes Ghost Test |
| A7 | Apex compliance checklist | Complete, covers all requirements |

---

## 10. TEMPORAL CORRECTNESS CHECK

### Audit Results

| Check | Status | Details |
|-------|--------|---------|
| Data access points verified | PASS | Only uses `closes[-N:]`, `highs[-N:]`, `lows[-N:]` |
| Timestamp ordering | PASS | Last element is current closed bar |
| Look-ahead indicators | PASS | EMA uses standard causal calculation |
| Bar completion verified | PASS | Function expects closed bars only |

**Overall**: PASS - No look-ahead bias detected in `trend_follow.py`.

Note: Bounce logic bug (line 182) is a logic error, not look-ahead. The condition checks `prev_close <= prev_ema_f` which may be too restrictive, but doesn't use future data.

---

## 11. ARGUS RESEARCH GATE

### Triggers Activated

1. **New technique/claim**: sep_ticks=22 is a 5.5x increase with no precedent
2. **Methodology risk**: Hurst-based regime detection has known lag issues
3. **Possible "too good" results**: 92-95% survival with 45% WR needs verification

### ARGUS_REQUEST (Required Before GO)

```
ARGUS_REQUEST
=============
CLAIM: TrendFollow with sep_ticks>=22 improves risk-adjusted returns vs sep_ticks>=4
FASTEST_DISPROOF_TEST:
  - Run backtest: 2023-01 to 2024-06 (18 months)
  - Compare: sep_ticks=4 vs sep_ticks=22
  - Metrics: trade count, WR, Sharpe, MC95DD
  - FAIL if: trades < 100 OR WR < 40% OR Sharpe < 0.5
SOURCES_NEEDED:
  - Empirical only (no academic precedent for this specific threshold)
  - Historical slippage data for XAUUSD
APEX_MAPPING:
  - Signal starvation risk during 30-day evaluation
  - DD recovery capability with reduced trade frequency
OUTPUT_LIMIT: <=300 words + pass/fail on each metric
```

---

## 12. PRE-MORTEM SUMMARY

### Failure Mode Ranking

| Rank | Mode | Probability | Severity | Detection | Mitigation |
|------|------|-------------|----------|-----------|------------|
| 1 | Signal Starvation | 40% | HIGH | Trade count < 30/month | Lower sep_ticks to 15 |
| 2 | HWM Trap | 25% | CRITICAL | Peak unrealized > 1.5% | Raise Profit Panic to 0.75% |
| 3 | Win Rate Degradation | 20% | MEDIUM | WR < 42% over 50 trades | Loosen touch_dist to 0.25*ATR |
| 4 | Hurst Lag Whipsaw | 10% | MEDIUM | Consecutive regime losses | Add regime-aware exit |
| 5 | Infrastructure Failure | 5% | CRITICAL | Missed time gate | Redundant close mechanism |

### Combined Failure Probability

Using independence assumption (conservative):
```
P(at least one failure) = 1 - (0.60 * 0.75 * 0.80 * 0.90 * 0.95) = 1 - 0.31 = 69%
```

**69% probability of at least one significant issue** in first 90 days without validation fixes.

---

## 13. NEXT STEPS (Unblock Path)

### Immediate Actions (Before Any Live Testing)

1. **Run Ghost Test** (ORACLE, 2 hours)
   - If baseline ~ full system: Pivot to Simplified Filter-First
   - If full system >> baseline: Proceed with current design

2. **Backtest New Parameters** (ORACLE, 4 hours)
   - sep_ticks=22, touch_dist=0.15*ATR, min_score=70
   - Verify: trades >= 200 over 5 years, WR >= 42%, MC95DD < 2.5%
   - If fails: Test intermediate values [10, 15, 20]

3. **sep_ticks Sensitivity Study** (CRUCIBLE, 2 hours)
   - Run backtest sweep: sep_ticks = [4, 8, 12, 16, 20, 24]
   - Plot: trade count, WR, Sharpe vs threshold
   - Find optimal point (not necessarily 22)

4. **Profit Panic Calibration** (SENTINEL, 1 hour)
   - Analyze historical unrealized peaks
   - Set threshold at 80th percentile of winning trades
   - Likely result: 0.75% - 1.0%

### Paper Trading Gate (After Backtests Pass)

- 2 weeks minimum
- Track: actual WR, actual trade count, slippage, latency
- Verify: all time gates execute correctly
- FAIL if: WR < 40% OR trades < 15/week OR any time gate miss

### External CRITIC Before GO-LIVE

- Fresh context review of all artifacts
- Mandatory per CLAUDE.md production_workflow
- Must have SENTINEL final sign-off

---

## 14. BLIND SPOTS IDENTIFIED

### What All Three Agents Missed

1. **Parameter Interaction Effects**: sep_ticks, touch_dist, and min_score were optimized independently. Their combined effect is unknown and may be non-linear.

2. **Signal Starvation Risk**: No agent calculated expected trade count under new parameters. This is critical for Apex evaluation period.

3. **Profit Panic vs Expected R:R Conflict**: The 0.5% threshold will trigger on most winners, potentially cutting profits.

4. **Regime-Aware Exit**: All focus on regime-gated entry, but no discussion of regime-aware exit logic.

5. **Alternative Strategies**: No agent proposed simpler alternatives that might work as well with less complexity.

---

## 15. FOOTER

**CRITIC Prime Directive**: "If I can't find problems, I haven't looked hard enough."

**Final Statement**: This review identified 4 blocking issues, 4 warnings, and 7 accepted items. The core strategy framework (risk management, Apex compliance, time gates) is sound. However, the specific parameter changes (sep_ticks=22, touch_dist=0.15*ATR) lack empirical validation and may cause signal starvation. The Ghost Test has not been executed, meaning we cannot confirm whether signals add edge beyond regime filters.

**Recommendation**: Run Ghost Test and parameter backtest before proceeding. If Ghost Test fails (baseline ~ full system), pivot to Simplified Filter-First strategy.

**Confidence in Verdict**: HIGH - The blocking conditions are objective and testable.

---

*Document generated by CRITIC v2.1 | Date: 2024-12-24 | Mode: EXTERNAL-CRITIC*
