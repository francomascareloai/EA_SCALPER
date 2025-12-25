# SENTINEL ROUND 2: Risk Impact Analysis of ORACLE/CRUCIBLE Proposals

**Agent**: SENTINEL v3.2 - Apex Trading Guardian
**Date**: 2024-12-24
**Round**: 2 of 6
**Focus**: Risk Implications of Proposed TrendFollow Modifications
**Status**: COMPLETE

---

## 1. Executive Summary

- **ORACLE's sep_ticks=40 proposal is RISK-POSITIVE**: Reduces noise signals by 60-80%, directly lowers expected DD
- **CRUCIBLE's breakout confirmation is RISK-POSITIVE**: Eliminates ~40% of false breakout entries
- **Session SL multiplier APPROVED**: Directly addresses Gate 9 (3x spread rule) during low-liquidity sessions
- **CRITICAL GAP IDENTIFIED**: HWM trap (unrealized profit reversal) is NOT addressed by any proposal
- **NEW SENTINEL PROPOSAL**: Profit scaling mechanism to protect HWM from erosion
- **HWM bid/ask handling remains UNVERIFIED**: Flagged for FORGE/REVIEWER

**User DD Limit**: 2-3% (stricter than Apex's 5%)
**Updated Verdict**: CONDITIONAL GO (unchanged from Round 1)

---

## 2. Risk Impact: ORACLE Proposals

### 2.1 sep_ticks >= 40 (up from 4)

| Aspect | Current | Proposed | Risk Impact |
|--------|---------|----------|-------------|
| Threshold | 4 ticks = $0.04 | 40 ticks = $0.40 | **POSITIVE** |
| Signal Count | High | 60-80% reduction | Fewer trades = lower daily exposure |
| Quality Gate | Noise passes | Only strong trends | Higher win rate expected |
| Sample Size | Adequate | May be insufficient | **CAUTION** - needs validation |

**Risk Analysis**:
1. Fewer signals = fewer trades per day = lower cumulative exposure
2. Stronger trend requirement = higher probability entries
3. If daily trades drop from 5 to 1, daily max exposure drops from 2.5% to 0.5%

**Concerns**:
- Low sample size during backtest validation (60-80% signal reduction)
- May miss early trend entries (entry when trend already established)

**Verdict**: **APPROVE** - Risk-positive change

### 2.2 min_score >= 75 (up from 60)

**Combined Effect with sep_ticks=40**:
```
At sep_ticks=40, atr_p=60:
  score = 60 + min(25, 40*1.5) + (60-40)*0.2
  score = 60 + 25 + 4 = 89 (passes min_score=75)
```

**Risk Analysis**:
- If sep_ticks=40 is implemented, min_score=75 is largely REDUNDANT
- min_score primarily filters on ATR percentile (weak signals in low volatility)
- Marginal additional filtering, not a primary risk control

**Verdict**: **CONDITIONAL APPROVE** - Test after sep_ticks change; may be unnecessary

---

## 3. Risk Impact: CRUCIBLE Proposals

### 3.1 Breakout Confirmation Delay

**Current**:
```python
if is_up and last_close > prev_high + tick_size:
    # Enter immediately
```

**Proposed**:
```python
prior_broke = closes[-2] > prev_high + tick_size
current_holds = last_close > prev_high
if is_up and prior_broke and current_holds:
    # Enter only after 2-bar confirmation
```

| Aspect | Risk Impact | Assessment |
|--------|-------------|------------|
| False breakout reduction | -40% (CRUCIBLE estimate) | **POSITIVE** |
| Entry timing | 1 bar later = worse price | Acceptable trade-off |
| Interaction with Hurst | Additional filter (belt-and-suspenders) | **POSITIVE** |

**Verdict**: **APPROVE** - Low implementation risk, high DD reduction potential

### 3.2 FVG Detection

**Proposed**: Detect Fair Value Gaps for entry confirmation

**Risk Analysis**:
| Implementation | Signal Reduction | Risk |
|----------------|------------------|------|
| Hard filter | Significant | Over-filtering concern |
| Score boost (+10) | Marginal | Low risk |

**Concerns**:
- CRUCIBLE claims +10-15% win rate - UNVALIDATED
- Combined with sep_ticks=40, may reduce signals excessively

**Verdict**: **CONDITIONAL APPROVE** - Implement as SCORE BOOST only, requires backtest validation

### 3.3 Session-Aware SL Multiplier

**Proposed**:
```python
def session_sl_multiplier(session: str) -> float:
    multipliers = {
        "asia": 1.5,   # Wider SL = smaller lot
        "london": 1.0,
        "ny": 1.1,
        "overlap": 0.9,
        "news": 2.0,   # 2x SL during news
    }
    return multipliers.get(session, 1.0)
```

**Risk Analysis**:

1. **Position Sizing Impact**:
   - Wider SL = smaller position (formula: lot = risk$ / (SL * pip_value))
   - Asia: 1.5x SL = 0.67x lot size
   - News: 2.0x SL = 0.50x lot size
   - **RISK-CONSERVATIVE**

2. **Gate 9 Compliance**:
   - CRUCIBLE noted 0.25*ATR may be tight during Asia
   - Asia spread = 30-50 pips, 3x = 90-150 pips required
   - With 1.5x multiplier: SL = 0.375*ATR = ~150 pips
   - **SATISFIES Gate 9**

3. **HWM Trap Interaction**:
   - Smaller positions during volatile sessions = less HWM spike risk
   - If position reverses, DD is also smaller
   - **POSITIVE for Apex survival**

**Verdict**: **APPROVE** - Requires robust time zone handling

---

## 4. Combined DD Modeling

### Baseline (Current System)
- Historical: -4% trailing DD in Mar/Jun 2024 (BEFORE Hurst gate)
- With Hurst gate: Expected improvement (unvalidated)

### Scenario Modeling

| Scenario | Changes | Estimated DD | Signal Reduction |
|----------|---------|--------------|------------------|
| 1 | sep_ticks=40 alone | -2.5% | 60-80% |
| 2 | + Breakout confirmation | -2.0% | ~85% |
| 3 | + Session SL multiplier | -1.8% | ~85% |
| 4 | + FVG score boost | -1.5% | ~90% |

**User DD Limit Compatibility**:
- User wants 2-3% max DD
- Scenario 3/4 estimates: -1.5% to -2% DD
- **WITHIN USER'S LIMIT** (if estimates hold)

**Critical Caveat**: All estimates are HYPOTHETICAL. Monte Carlo backtest required.

---

## 5. Position Sizing Recommendations

### Current DD Throttle (position_sizer.py)
```python
if drawdown_pct >= self._dd_hard:  # 5%
    throttled *= 0.25
elif drawdown_pct >= self._dd_soft:  # 3%
    throttled *= 0.50
elif drawdown_pct >= 0.02:  # 2%
    throttled *= 0.75
```

### Proposed Tighter Throttle (for user's 2-3% DD limit)

| DD Threshold | Current Multiplier | Proposed Multiplier |
|--------------|-------------------|---------------------|
| >= 1.0% | N/A | 0.85x |
| >= 1.5% | N/A | 0.65x |
| >= 2.0% | 0.75x | 0.40x |
| >= 2.5% | N/A | 0.20x |
| >= 3.0% | 0.50x | **0.00x (HALT)** |

**Rationale**: User's 3% limit is HARD - must HALT before reaching it, not after.

### Session + DD Compound Effect

Example at 2% DD during Asia session:
- DD throttle: 0.40x (proposed)
- Session multiplier: 0.67x (1.5x SL = smaller lot)
- Combined: 0.40 * 0.67 = **0.27x lot size**

This is VERY CONSERVATIVE - appropriate for Apex survival.

---

## 6. HWM Verification Status

### What Was Verified
- `DrawdownTracker` updates HWM when `current_equity > _high_water_mark`
- `DDProtectionCalculator` calculates trailing DD from HWM
- Docstrings indicate equity should include unrealized PnL

### What Was NOT Verified
- **Price basis for unrealized PnL**: Does strategy use bid for LONG, ask for SHORT?
- **Caller responsibility**: Trackers ASSUME correct equity is passed
- **No enforcement**: Code does not validate price basis

### CLAUDE.md Requirement (price_basis rule)
```
LONG positions: use BID price for unrealized exit value (conservative)
SHORT positions: use ASK price for unrealized exit value (conservative)
NEVER use MID price - it can artificially inflate unrealized profit
```

**Status**: **UNVERIFIED** - Flagged for FORGE/REVIEWER

---

## 7. HWM Trap Analysis (NEW FINDING)

### Problem
Unrealized profit raises HWM, but reversal still hits DD floor.

**Example**:
```
Account: $50,000 starting equity
Trade goes to $52,000 unrealized profit -> HWM = $52,000
New trailing DD floor = $52,000 * 0.95 = $49,400
Trade reverses to $49,000 -> ACCOUNT BLOWN (5% from $52k HWM)
Net result: Lost only $1,000 from starting but BLOWN because HWM was $52k
```

### Gap Analysis
- **Neither ORACLE nor CRUCIBLE addressed this**
- Current system has NO protection against HWM erosion
- This is a **CRITICAL** Apex survival issue

### SENTINEL Proposal: Profit Scaling Mechanism

**Option 1: Trailing Stop on Unrealized**
- When unrealized > 1.5% equity: move SL to breakeven
- When unrealized > 2.5% equity: lock in 50% of profit

**Option 2: Aggressive Scaling Out (RECOMMENDED)**
```python
# At +1% unrealized: close 25% of position
# At +2% unrealized: close another 25%
# At +3% unrealized: close remaining 50%
```

**Benefit**: HWM rises, but REALIZED profit rises with it. Prevents reversal from eroding buffer.

---

## 8. Updated GO/NO-GO Assessment

### Round 1 Verdict: CONDITIONAL GO

### Round 2 Update: CONDITIONAL GO (unchanged)

**Conditions Carried Forward**:
| Condition | Owner | Priority | Status |
|-----------|-------|----------|--------|
| Backtest with Hurst gate, verify DD < 3% | ORACLE | HIGH | PENDING |
| Verify HWM uses bid/ask for unrealized | FORGE/REVIEWER | HIGH | **UNVERIFIED** |
| Implement SL clamping in trend_follow.py | FORGE | MEDIUM | PENDING |

**New Conditions from Round 2**:
| Condition | Owner | Priority | Status |
|-----------|-------|----------|--------|
| Backtest with sep_ticks=40 | ORACLE | HIGH | NEW |
| Implement profit scaling for HWM protection | FORGE | **CRITICAL** | NEW |
| Implement session SL multiplier | FORGE | MEDIUM | NEW |
| Tighten DD throttle for user's 2-3% limit | FORGE | HIGH | NEW |

### Blocking Conditions
1. HWM bid/ask handling NOT verified (carry forward)
2. Profit lock mechanism MISSING (new)
3. Backtest validation of proposals NOT completed

---

## 9. Questions for Round 3

### For ORACLE:
1. **Minimum sample size**: At sep_ticks=40, how many trades/year expected? Is this sufficient for statistical validity?
2. **Stratified analysis**: Can you split backtest by Hurst range (0.55-0.65, 0.65-0.75, 0.75+)?

### For CRUCIBLE:
1. **FVG implementation**: Hard filter or score boost? If score boost, what value (+10? +15?)?
2. **Session detection**: Does codebase have session classification logic? If not, adds complexity.

### For FORGE/REVIEWER:
1. **VERIFY**: Does gold_scalper_strategy.py use bid/ask for unrealized PnL calculation?
2. **IMPLEMENT**: Profit scaling mechanism (scale out at +1%, +2%, +3% unrealized)
3. **IMPLEMENT**: Tighter DD throttle for user's 2-3% limit

---

## 10. Confidence Level

| Component | Confidence | Reasoning |
|-----------|------------|-----------|
| sep_ticks=40 risk impact | 8/10 | Math is clear, signal reduction is risk-positive |
| Breakout confirmation risk impact | 7/10 | Logical but unvalidated |
| Session SL multiplier | 8/10 | Directly addresses Gate 9 |
| FVG detection | 5/10 | Unvalidated claims |
| Position sizing adjustments | 9/10 | Code analysis straightforward |
| HWM calculation | 4/10 | NOT VERIFIED |
| Profit lock proposal | 6/10 | New proposal, needs validation |
| Combined DD estimate | 5/10 | All estimates hypothetical |

**Overall Round 2 Confidence: 6/10** (decreased from 7/10 due to HWM uncertainty)

---

## 11. Appendix: Risk Summary Table

| Proposal | Source | Risk Impact | Verdict | Priority |
|----------|--------|-------------|---------|----------|
| sep_ticks=40 | ORACLE | POSITIVE | APPROVE | HIGH |
| min_score=75 | ORACLE | MARGINAL | CONDITIONAL | LOW |
| Breakout confirmation | CRUCIBLE | POSITIVE | APPROVE | HIGH |
| FVG detection | CRUCIBLE | UNCERTAIN | CONDITIONAL | MEDIUM |
| Session SL multiplier | CRUCIBLE | POSITIVE | APPROVE | MEDIUM |
| Profit scaling | SENTINEL (NEW) | CRITICAL | PROPOSE | **CRITICAL** |
| Tighter DD throttle | SENTINEL (NEW) | POSITIVE | PROPOSE | HIGH |

---

*SENTINEL v3.2 - "Trailing DD does not forgive. The clock does not wait."*
*"Unrealized profit raises floor PERMANENTLY - lock in gains before they evaporate."*
