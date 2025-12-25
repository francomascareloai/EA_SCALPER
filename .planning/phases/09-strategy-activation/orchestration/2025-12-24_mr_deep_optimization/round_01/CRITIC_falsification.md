# CRITIC Round 1: Falsification Analysis

**Agent:** CRITIC v1.3
**Mode:** EXTERNAL-CRITIC (fresh context adversarial review)
**Date:** 2025-12-24
**Artifact:** Mean Revert Strategy Optimization Plan (10 rounds)

---

## Executive Summary

**VERDICT: BLOCKED**

The 10-round optimization plan violates falsification-first protocol. It proposes optimizing parameters BEFORE validating that mean reversion works at all for XAUUSD M5. This is cart-before-horse reasoning.

The current results (Sharpe: -0.47, SQN: -0.25, 75% WR with 3.4x loss ratio) are consistent with either:
1. A broken signal with broken R:R (fixable), OR
2. A fundamentally inappropriate strategy for this asset/timeframe (unfixable)

We cannot distinguish these hypotheses without running disproof tests first.

---

## Core Assumption Challenges

### Assumption 1: "Gold mean-reverts on M5 timeframe"
**Status: UNVALIDATED**

This is the foundational premise. If false, no optimization helps.

**Counter-evidence:**
- Gold exhibits strong trending behavior during macro flows (Fed, geopolitics)
- Session opens (London, NY) create directional momentum, not reversion
- News events cause sustained directional moves lasting hours
- Hurst exponent for XAUUSD on short timeframes often exceeds 0.5 (trending)

**Challenge:** What percentage of M5 bars actually mean-revert vs continue trending? Without this data, we're optimizing in the dark.

### Assumption 2: "BB touches = reversion opportunity"
**Status: FLAWED**

Bollinger Band touches during trends are continuation signals, not reversal signals. Price "walks the band" in strong trends, creating repeated touches that are all losing fade trades.

**The 25% losers that are 3.4x winners are likely TREND TRADES where price walked the band.**

**Challenge:** If we segment performance by market regime:
- Ranging: Likely profitable (BB works as intended)
- Trending: Likely catastrophic (BB touches are suicide)

This suggests a REGIME FILTER is the solution, not BB parameter optimization.

### Assumption 3: "RSI extremes = exhaustion"
**Status: MYTHOLOGY**

This is one of the most common retail trading myths. Research evidence:
- Momentum effect is well-documented: winners tend to keep winning
- RSI > 70 during uptrends = STRENGTH, often leads to MORE gains
- RSI can stay >70 or <30 for extended periods during trends
- "Markets can stay irrational longer than you can stay solvent"

**Challenge:** Count how many M5 bars RSI stays extreme after hitting threshold. If average persistence >3 bars, fading RSI is suicide.

### Assumption 4: "The signal has predictive value"
**Status: UNVALIDATED**

The 75% win rate LOOKS good but may be entirely explained by asymmetric R:R.

**Mathematical trap:**
- With 3.4:1 loss ratio, break-even WR = 77.3%
- Current WR = 75%
- Strategy is 2.3% WR short of break-even

This could mean:
1. Signal has SOME edge but R:R destroys it (fixable)
2. 75% WR is artifact of wide stop, not signal accuracy (unfixable without complete redesign)

### Assumption 5: "Optimization can fix this"
**Status: QUESTIONABLE**

The MANIFEST hypothesis states: "Strategy failed due to lack of optimization, not fundamental flaw."

**Counter-hypothesis:** Strategy failed because:
1. Mean reversion is wrong for gold at M5
2. BB/RSI combination is noise
3. R:R structure is fundamentally inverted

Optimization cannot fix fundamental architectural flaws. It can only tune parameters within a valid architecture.

---

## Edge Attribution Analysis

### Current MR Scorer Components (from code):
```python
# Score composition (lines 144-146, 175-177):
score = 60.0  # base
+ min(20.0, band_excess * 6.0)  # BB position: 0-20 pts
+ min(15.0, rsi_strength * 30.0)  # RSI strength: 0-15 pts
- min(10.0, (atr_p - 40.0) * 0.25)  # ATR penalty: 0-10 pts
```

**Analysis:** The scoring is dominated by:
1. Base score of 60 (meaningless - just shifts threshold)
2. BB excess (0-20 pts) - measures how far beyond band
3. RSI strength (0-15 pts) - measures how extreme

### Ghost Test Question

If we replace `generate_mean_revert_candidates()` with random entries but keep:
- Same position sizing
- Same SL/TP structure
- Same session filters
- Same time gates

Would performance be SIMILAR, BETTER, or WORSE?

**Hypothesis:** SIMILAR or BETTER

**Rationale:** The 75% WR with negative expectancy suggests the signal might be HARMFUL. It enters at extremes, which during trends means entering against momentum. A random entry might avoid this anti-selection.

### Permutation Importance Predictions

| Component | Shuffle Effect | Prediction |
|-----------|---------------|------------|
| BB position | Remove band-touch requirement | Delta ~0 (BB timing is noise) |
| RSI level | Remove RSI filter | Delta ~0 (RSI is noise) |
| ATR filter | Remove volatility gate | Delta NEGATIVE (this is the real edge) |

**Hypothesis:** The ATR percentile filter (`max_atr_percentile: 70.0`) is doing the heavy lifting. It blocks trades during volatility expansion (trend breakouts). The BB/RSI are just timing noise.

---

## Fastest Disproof Tests

### TEST 1: Fundamental MR Validity (1-2 hours)
**Objective:** Does gold mean-revert on M5 at BB extremes?

```python
# Pseudocode for disproof test
for each bar where close < lower_BB:
    forward_returns = [close[t+1], close[t+2], close[t+5]] / close[t] - 1

for each bar where close > upper_BB:
    forward_returns = [close[t+1], close[t+2], close[t+5]] / close[t] - 1

# Compare to random baseline (any bar's forward returns)
```

**Expected if MR works:**
- Lower BB touch -> positive forward returns (reversion up)
- Upper BB touch -> negative forward returns (reversion down)

**Expected if MR doesn't work:**
- Forward returns similar to random (no edge)
- OR opposite sign (momentum continuation)

**DISPROOF THRESHOLD:** If forward returns are neutral or opposite to expectation, MR concept is dead for this asset/timeframe. ABORT remaining rounds.

### TEST 2: Signal Accuracy (1:1 R:R) (1 hour)
**Objective:** Does the signal predict direction?

Run current MR signals with 1:1 R:R (TP = SL distance).

**Expected if signal works:** WR > 55%
**Expected if signal is noise:** WR ~ 50%

**DISPROOF THRESHOLD:** If WR with 1:1 R:R is <= 52%, signal has no directional edge. Delete scorer complexity.

### TEST 3: Ghost Entry Baseline (1 hour)
**Objective:** Is the signal adding value or subtracting it?

Replace MR entries with random entries (same trade frequency), keep all else identical.

**Expected if signal works:** Random performs significantly worse
**Expected if signal is noise:** Random performs similarly or BETTER

**DISPROOF THRESHOLD:** If random >= MR performance, the signal is anti-edge. Delete it entirely.

### TEST 4: Regime Segmentation (1 hour)
**Objective:** Does MR only work in ranging conditions?

Segment trades by Hurst exponent:
- Hurst < 0.45: Mean-reverting regime
- Hurst > 0.55: Trending regime
- 0.45 <= Hurst <= 0.55: Random walk

Calculate separate performance metrics for each regime.

**Expected if regime matters:**
- Ranging: Positive expectancy
- Trending: Negative expectancy (large losses)
- Random: ~Zero expectancy

**DISPROOF THRESHOLD:** If performance is negative across ALL regimes, MR is fundamentally dead. If positive only in ranging, solution is regime filter, not parameter optimization.

---

## Minimum Viable Strategy

If disproof tests pass (MR has potential), here's the simplest possible MR that could work:

### Architecture
```python
# Entry: Single clear trigger
entry_long = close < lower_BB and regime == RANGING
entry_short = close > upper_BB and regime == RANGING

# Exit: Risk-adjusted (FLIP the current R:R)
stop_loss = 0.5 * ATR  # TIGHT (cut quickly if wrong)
take_profit = 2.0 * ATR  # WIDE (capture full reversion)
time_exit = 6 bars  # Force exit if neither hit

# Filters
- Block if ATR_percentile > 60 (no volatility expansion)
- Block during London/NY open (first 30 minutes)
- Block if Hurst > 0.50 (trending market)
```

### Key Changes from Current
1. **DELETE RSI** - Likely noise, adds complexity for no edge
2. **FLIP R:R** - Tight stop (cut losers fast), wide target (let winners run)
3. **ADD regime filter** - Only trade during mean-reverting conditions
4. **ADD session filter** - Avoid session opens where momentum dominates

### Mathematical Expectation
If MR actually works in ranging conditions:
- Target WR: 40-45% (lower due to tight stop)
- R:R: 4:1 (tight stop, wide target)
- Expected value: 0.40 * 4 - 0.60 * 1 = +1.0 per unit risked

This is POSITIVE expectancy even with lower win rate.

---

## Verdict

### VERDICT: BLOCKED

**Reason:** Optimization is proposed before fundamental validation. This violates falsification-first protocol.

### Required Before Proceeding

1. **Round 2 MUST run disproof tests** (not optimization)
2. Tests must complete with PASS/FAIL verdicts
3. If ANY disproof test fails -> ABORT remaining rounds, declare MR dead
4. If all tests pass -> Proceed with R:R restructuring in Round 3

### ARGUS_REQUEST (if tests inconclusive)

```
ARGUS_REQUEST
=============
CLAIM: Mean reversion on XAUUSD M5 has positive expectancy when regime-filtered
FASTEST_DISPROOF_TEST: Forward returns after BB touches (1-year data, 1 hour runtime)
SOURCES_NEEDED: Academic (MR in commodities) + Code (regime detection) + Empirical (XAUUSD autocorrelation)
APEX_MAPPING: MR R:R vs trailing DD sensitivity; session filter vs time gates
OUTPUT_LIMIT: <=300 words + 3 sources
```

### Risks if BLOCKED is Ignored

1. **Wasted rounds:** 8-9 rounds optimizing noise
2. **False confidence:** Finding "best" parameters for a broken concept
3. **Overfitting risk:** More parameters = more degrees of freedom = more overfit
4. **Opportunity cost:** Time not spent improving TrendFollow (proven to work)

---

## Pre-Mortem Summary

**Most Likely Failure Mode:**
MR optimization produces beautiful backtest metrics through overfitting. Live trading fails because:
1. Gold doesn't mean-revert reliably on M5
2. Optimized parameters are curve-fitted to historical noise
3. First trending week destroys account due to inverted R:R

**Second Most Likely:**
MR is killed correctly but after wasting 10 rounds of optimization. Should have been killed in Round 2.

**Mitigation:**
Run disproof tests in Round 2. If they fail, reallocate remaining rounds to TrendFollow enhancement or develop regime-aware hybrid.

---

## Confidence

**CONFIDENCE: HIGH**

**Reason:**
1. The math is clear: 75% WR with 3.4x loss ratio = negative expectancy
2. The architecture is inverted: wide stops / tight targets is backwards for MR
3. The fundamental premise (gold mean-reverts on M5) is unvalidated
4. Prior CRUCIBLE research already noted the need for regime gating
5. Falsification patterns from CLAUDE.md clearly apply

---

*CRITIC v1.3 - Adversarial Quality Guardian*
*"Assume it's broken until proven otherwise."*
