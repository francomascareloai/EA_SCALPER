# SENTINEL Round 4: Risk-Optimized Parameter Recommendations

**Agent:** SENTINEL v3.2 - Apex Trading Guardian
**Round:** 4 of 6
**Date:** 2024-12-24
**Focus:** Risk-optimized parameter recommendations for TrendFollow strategy

---

## Executive Summary

SENTINEL provides risk-optimized parameter bounds for Apex compliance. The TrendFollow strategy CAN be made Apex-safe, but requires:
1. Starvation mitigation (current 7-15 trades/month is unacceptable)
2. HWM trap mitigation (scale-out, profit protection)
3. Walk-forward validation (WFE >= 0.50)
4. Monte Carlo confirmation (MC95 DD <= 3%)

**CURRENT VERDICT: CONDITIONAL GO** (pending validation)

---

## 1. Risk-Optimal Parameter Bounds

### Core Parameters

| Parameter | Proposed Range | Risk Impact | Apex-Safe Bound | Rationale |
|-----------|---------------|-------------|-----------------|-----------|
| sep_ticks | 15-50 | Higher = fewer signals, lower DD variance | Min 20 | Quality over quantity |
| min_score | 60-75 | Higher = better quality, less variance | Min 65 | Maintains confluence |
| min_hurst | 0.50-0.60 | Higher = less regime risk, fewer signals | Min 0.52 | Balance trending confirmation |
| sl_buffer | 0.25-0.75*ATR | Higher = wider SL, smaller lots | 0.40-0.60*ATR | Optimal survival zone |
| max_risk_per_trade | Fixed | N/A | 0.5% | Apex-optimal, non-negotiable |

### Variant-Specific sep_ticks (Recommended)

| Variant | Recommended sep_ticks | Reason |
|---------|----------------------|--------|
| OB_FVG_PULL | 20-25 | Smaller structures, tighter separation |
| FVG_SWEEP | 30-35 | Medium structures |
| OB_RAID_FVG | 35-40 | Larger structures need more separation |
| BOUNCE variants | 25-30 | Reactive patterns |

### Risk Gate Parameters

| Setting | Value | Apex Threshold | Buffer |
|---------|-------|----------------|--------|
| Daily DD WARN | 1.5% | N/A | N/A |
| Daily DD CAUTION | 2.0% | N/A | N/A |
| Daily DD HALT | 2.5% | 3.0% | 0.5% |
| Trailing DD WARN | 2.5% | N/A | N/A |
| Trailing DD CAUTION | 3.0% | N/A | N/A |
| Trailing DD HALT | 3.5% | 4.5% | 1.0% |
| Trailing DD TERMINATE | 5.0% | 5.0% | 0% |

---

## 2. Position Sizing Sensitivity Analysis

### Base Scenario
- Account: $50,000
- Risk per trade: 0.5% = $250
- ATR: $5.00 (typical for XAUUSD)
- XAUUSD: 1 standard lot = 100 oz

### SL Width Impact

| SL Buffer | SL Distance | Position Size | Win (1.5R) | Loss |
|-----------|-------------|---------------|------------|------|
| 0.25*ATR | $1.25 | 2.0 lots | +$375 | -$250 |
| 0.50*ATR | $2.50 | 1.0 lot | +$375 | -$250 |
| 0.60*ATR | $3.00 | 0.83 lots | +$375 | -$250 |

**Critical Insight:** Dollar P&L is IDENTICAL regardless of SL width because RR is a ratio!
- Tighter SL = More lots, but more stop-outs (noise hits stops)
- Wider SL = Fewer lots, but better survival (fewer false stops)

**SENTINEL Recommendation:** Use 0.50*ATR for optimal survival without sacrificing P&L.

---

## 3. Worst-Case Scenario Modeling

### Scenario A: Bad Month
- Trades: 10 (starvation)
- Win rate: 40% (below target)
- RR: 1.2:1 (below target)
- Risk: 0.5% per trade

**Calculation:**
```
Expected wins: 10 * 40% = 4 winners
Expected losses: 10 * 60% = 6 losers
Win P&L: 4 * $250 * 1.2 = $1,200
Loss P&L: 6 * $250 = -$1,500
Net: -$300 (-0.6% of account)
```

**Max DD during sequence (worst ordering):**
- 6 losses first: 6 * 0.5% = 3.0%
- Status: Hits CAUTION threshold!

### Scenario B: Very Bad Week
- 5 consecutive losses at 0.5% risk

**Calculation:**
```
DD after 5 losses: 5 * 0.5% = 2.5%
Status: REDUCE (50% size, A/B setups only)

Remaining buffer to HALT: 3.5% - 2.5% = 1.0%
More losses at 0.5% before HALT: 2
More losses at 0.25% (reduced) before HALT: 4
```

### Consecutive Loss Probabilities (40% win rate)

| Consecutive Losses | Probability | DD Impact | Status |
|-------------------|-------------|-----------|--------|
| 5 | 7.78% | 2.5% | REDUCE |
| 6 | 4.67% | 3.0% | CAUTION |
| 7 | 2.80% | 3.5% | HALT |
| 8 | 1.68% | 4.0% | CRITICAL |

Over 100 trades (~4-6 months at current rate):
- Expected 5+ loss streaks: ~7.8 occurrences
- Expected 8+ loss streaks: ~1.7 occurrences

**CONCERN:** 8 consecutive losses (4% DD) is statistically likely over reasonable horizon.

---

## 4. Optimal Risk Budget Allocation

Given 3% trailing DD user limit (with 1.5% buffer to Apex HALT):

| Risk Category | Budget | Notes |
|---------------|--------|-------|
| Position losses | 2.0% | Main market exposure |
| Slippage reserve | 0.3% | Conservative fill assumptions |
| Gap risk | 0% | Apex mandate: no overnight |
| Execution latency | 0.1% | Emergency close buffer |
| Safety margin | 0.6% | "Oh shit" margin |
| **TOTAL** | **3.0%** | User limit |

**Buffers:**
- To Apex HALT (4.5%): 1.5%
- To Apex TERMINATE (5%): 2.0%

**Position Loss Budget Math:**
- At 0.5% per trade: 4 losses before budget exhausted
- At 0.25% (reduced): 8 losses before budget exhausted

---

## 5. Starvation Mitigation Options (Risk-Ranked)

| Rank | Option | Signal Gain | Risk Impact | Verdict |
|------|--------|-------------|-------------|---------|
| 1 | D. Bounce logic fix | +10-20% | NEUTRAL | **APPROVE** - Bug fix, not relaxation |
| 2 | A. Variant-specific sep_ticks | +15-20% | NEUTRAL | **APPROVE** - Optimization, not relaxation |
| 3 | B. Adaptive min_score (65-70) | +10-15% | SLIGHT NEGATIVE | **CAUTION** - Only with quality evidence |
| 4 | C. Hurst relaxation (0.52) | +25-30% | MODERATE NEGATIVE | **CONDITIONAL** - Combine with stricter gates |
| 5 | E. Remove confirmation | +30-40% | HIGH NEGATIVE | **REJECT** - Would blow account faster |

### Detailed Risk Analysis

**Option D (Bounce fix) - APPROVE:**
- This is a bug fix, not a parameter relaxation
- Recovers valid signals that are incorrectly filtered
- Zero additional risk

**Option A (Variant sep_ticks) - APPROVE:**
- Different OB/FVG sizes justify different separations
- This is parameter tuning, not quality compromise
- Neutral risk impact

**Option B (Adaptive score) - CAUTION:**
- Lowering threshold admits lower-quality setups
- May gain 10% signals but lose 5% win rate
- Only approve if backtest shows maintained win rate

**Option C (Hurst 0.52) - CONDITIONAL:**
- Trading closer to random walk increases regime risk
- Acceptable ONLY if combined with stricter score/time gates
- Monitor regime closely

**Option E (Remove confirmation) - REJECT:**
- Confirmation exists to filter false signals
- Removing means entering on first touch, not confirmed reaction
- Dramatically increases false positives
- This would accelerate account blow-up

---

## 6. GO/NO-GO Criteria

### Critical Metrics (Must Pass All)

| Metric | Current Est. | Target | Hard Limit | Status |
|--------|-------------|--------|------------|--------|
| Trades/month | 7-15 | 25-35 | Min 20 | **FAIL** |
| Win rate | ~40% | 50%+ | Min 45% | **FAIL** |
| Trailing DD (MC95) | >4%? | <2.5% | Max 3% | **TBD** |
| Daily DD (MC95) | ? | <1.5% | Max 2% | **TBD** |
| Annual Survival | 88% | >95% | Min 90% | **FAIL** |

### Secondary Metrics (Should Pass Majority)

| Metric | Current Est. | Target | Threshold |
|--------|-------------|--------|-----------|
| Profit Factor | ? | >1.5 | Min 1.3 |
| WFE | ? | >0.60 | Min 0.50 |
| SQN | ? | >2.0 | Min 1.5 |
| Expectancy | ? | >$150/trade | >$100/trade |
| Max Consecutive Loss | 8 | <6 | Max 7 |

### GO Criteria (All Required)

1. Trades/month >= 20 (signal sufficiency)
2. Win rate >= 45% (edge confirmation)
3. MC95 DD <= 3% (Apex safety)
4. Annual survival >= 90% (survivability)
5. Profit Factor >= 1.3 (positive expectancy)
6. WFE >= 0.50 (walk-forward validity)

### NO-GO Criteria (Any = Immediate Stop)

1. Trades/month < 15 (starvation)
2. Win rate < 40% (no edge)
3. MC95 DD > 4% (Apex danger)
4. Annual survival < 85% (unacceptable risk)
5. Max consecutive losses > 8 (HALT inevitable)
6. WFE < 0.40 (overfit)

---

## 7. HWM Trap Analysis

### The Trap Scenario

```
Account: $50,000
Week 1: 4 winners at 1.5:1 RR
- Net P&L: +$1,500
- Equity: $51,500
- HWM: $51,500 (RAISED)
- New floor: $48,925

Week 2: 6 consecutive losses
- Net P&L: -$1,500
- Equity: $50,000 (back to start!)
- DD from HWM: ($51,500 - $50,000) / $51,500 = 2.91%
```

**Result:** At 2.91% DD despite being at starting equity!

### Mitigation Strategies

| Strategy | Implementation | Impact |
|----------|----------------|--------|
| Scale-out winners | 50% at 1:1, 50% at 2:1 | Locks profit before unrealized HWM |
| Profit protection stops | Move SL to BE at +1R | Prevents winner becoming loser |
| Daily profit cap | Stop trading after +2% | Prevents HWM running ahead |
| Conservative HWM buffer | Treat DD as HWM+0.5% | Always assume worse than reality |

---

## 8. Recommended Parameter Set (Final)

### Strategy Parameters

| Parameter | Current | SENTINEL Recommended | Change |
|-----------|---------|---------------------|--------|
| max_risk_per_trade | 0.5% | 0.5% | None |
| min_hurst | 0.55 | 0.52 | Loosen |
| min_score | 70 | 65 | Loosen |
| sep_ticks | Uniform 30 | Variant-specific (20-40) | Optimize |
| sl_buffer | 0.25*ATR | 0.50*ATR | Widen |
| session_filter | London+NY | London+NY | None |
| time_block | 4:30 PM ET | 4:30 PM ET | None |

### Circuit Breaker Settings

| Level | DD Range | Size Multiplier | Action |
|-------|----------|-----------------|--------|
| NORMAL | <2.5% | 100% | Full trading |
| CAUTION | 2.5-3.0% | 75% | Reduce size |
| REDUCE | 3.0-3.5% | 50% | A+ setups only |
| HALT | >3.5% | 0% | No new trades |

---

## 9. Confidence Assessment

| Assessment | Confidence | Notes |
|------------|------------|-------|
| HWM implementation correctness | 95% | Verified BID/ASK usage in Round 3 |
| Parameter bounds are Apex-safe | 85% | Conservative choices throughout |
| Starvation mitigation will work | 60% | Needs empirical validation |
| 90%+ annual survival achievable | 70% | With all mitigations implemented |
| Strategy is production-ready | 35% | Too many unknowns remain |

### Most Likely Failure Mode

**HWM Trap + Starvation Combination:**
- Not enough trades to recover from HWM trap
- Each losing streak ratchets DD up
- Winners raise HWM, losers keep DD elevated
- Eventually hit HALT without ever being net-negative

---

## 10. Handoffs

### Immediate (High Priority)

| To Agent | Task | Input |
|----------|------|-------|
| ORACLE | Run backtest with recommended params | Parameter set from Section 8 |
| ORACLE | Execute Monte Carlo (1000 runs) | For DD distribution |
| ORACLE | Execute walk-forward validation | For WFE calculation |

### After Validation (Medium Priority)

| To Agent | Task | Input |
|----------|------|-------|
| CRUCIBLE | Implement scale-out protocol | 50% at 1:1, 50% at 2:1 |
| CRUCIBLE | Add profit protection stops | Move SL to BE at +1R |
| FORGE | Update parameter bounds in config | Ranges from Section 1 |

### Blocking Issues (Must Resolve)

1. **Signal sufficiency**: Need evidence 20+ trades/month with relaxed params
2. **Win rate stability**: Need evidence 45%+ win rate maintained
3. **MC95 DD validation**: Need actual Monte Carlo with < 3% result
4. **WFE confirmation**: Need walk-forward with WFE >= 0.50

---

## 11. Open Questions for ORACLE

1. What are actual trade counts per variant in backtest?
2. What is actual win rate distribution across variants?
3. What is worst-case max DD in Monte Carlo (1000 runs)?
4. What is WFE for each walk-forward fold?
5. What is the correlation between consecutive losses and variant type?

---

## 12. SENTINEL Sign-Off

**Status:** CONDITIONAL GO

The TrendFollow strategy is NOT ready for live trading until:
- Signal sufficiency is proven (20+ trades/month)
- Monte Carlo DD is validated (< 3%)
- Walk-forward is passed (WFE >= 0.50)
- HWM trap mitigations are implemented

SENTINEL will provide final GO/NO-GO after ORACLE completes validation runs.

---

**Critical Reminders for Live Trading:**
1. Broker-side SL is MANDATORY - Client-side can fail
2. 4:59 PM ET is ABSOLUTE - No exceptions, ever
3. HWM includes unrealized - Conservative BID/ASK pricing
4. 30% consistency rule - Cap daily profit
5. Paper trade 2 weeks minimum - Before any live

---

*"Trailing DD does not forgive. The clock does not wait."*
*"Unrealized profit raises floor PERMANENTLY."*

SENTINEL v3.2 - Apex Trading Guardian
