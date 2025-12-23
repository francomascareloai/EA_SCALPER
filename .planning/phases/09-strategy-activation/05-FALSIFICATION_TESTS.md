# FALSIFICATION TESTS - Phase 00 Priority Insert

## Changelog
- v1.0 (2025-12-23): Created from DeepThink Red Team Audit

## Purpose
**Critical Discovery:** DeepThink identified that our system may suffer from "Quant-Narrative Dissonance" - fitting subjective SMC into statistical framework under hostile Apex constraints.

These tests are designed to **KILL BAD IDEAS FAST** before we waste months on overfitted complexity.

---

## Test Priority Ranking

| Priority | Test | Purpose | Time | Blocking |
|----------|------|---------|------|----------|
| **P0** | Null Signal Test | Prove filters vs signals edge source | 2 hours | Phase 00 Week 2 |
| **P0** | Apex HWM Survival | Prove swing vs scalp under HWM trap | 3 hours | Phase 00 Week 2 |
| **P1** | Shifted Levels Test | Falsify OB precision claims | 2 hours | Phase 02 |
| **P1** | Wick Destruction Test | Falsify sweep detection logic | 2 hours | Phase 02 |
| **P2** | Permutation Importance | Better ablation methodology | 4 hours | Phase 00 Week 2 |

---

## P0-A: NULL SIGNAL TEST (The "Ghost Strategy")

### Hypothesis to Disprove
**Claim:** SMC confluence scoring (9 factors) provides directional edge.

**Null Hypothesis:** Edge comes purely from regime filtering (Hurst, session, time gates). SMC signals are "Complexity Theater."

### Test Design

#### Step 1: Clone Strategy
```python
# Create Strategy_Ghost (clone of GoldScalperStrategy)
class GhostStrategy(GoldScalperStrategy):
    """
    Identical to production EXCEPT signal generation.
    Keeps ALL filters, replaces SMC with random entries.
    """
    pass
```

#### Step 2: Lobotomize Signal Generation
```python
def _generate_signal(self) -> Signal:
    # KEEP: All filters (time gates, regime, session, Hurst)
    if not self._can_trade_now():  # Time gates
        return Signal.FLAT

    if self._regime == RegimeType.RANDOM_WALK:  # Hurst filter
        return Signal.FLAT

    # REPLACE: SMC 9-factor confluence with random choice
    import random
    direction = random.choice([Signal.LONG, Signal.SHORT])

    # Generate entry every 15 minutes (inside valid window)
    if self._bar_count % 3 == 0:  # Assuming M5 bars
        return direction
    return Signal.FLAT
```

#### Step 3: Run Backtest (Same Dataset)
- **Data:** xauusd_2003_2025_stride20_full.parquet
- **Config:** Identical risk params (lot sizing, stops, targets)
- **Metrics:** WFE, SQN, Sharpe, PSR, MC95DD

### Success Criteria (Falsification Thresholds)

| Outcome | Sharpe(Ghost) | Sharpe(SMC) | Interpretation | Action |
|---------|---------------|-------------|----------------|--------|
| **A** | > 0.5 | > 0.5 | Edge is FILTERS. SMC is placebo. | **KILL SMC** → Simplify to filters + random/momentum |
| **B** | < 0 | > 1.0 | SMC adds real directional value | **KEEP SMC** → Proceed with ablation |
| **C** | ≈ 0 | ≈ 0 | No edge anywhere | **STOP EVERYTHING** → Investigate filters |

**Statistical Rigor:**
- Min 200 trades per strategy
- Bootstrap 1000 runs with different random seeds
- p-value < 0.05 for difference to be significant

### Deliverable
- `GHOST_TEST_RESULTS.md` with verdict: KILL SMC / KEEP SMC / INCONCLUSIVE

---

## P0-B: APEX HWM SURVIVAL TEST (Monte Carlo)

### Hypothesis to Disprove
**Claim:** SMC swing-style (1:3 R:R, hold for runners) works under Apex constraints.

**Null Hypothesis:** Apex HWM trap mathematically kills swing trading. Only scalp + aggressive scale-out survives.

### Test Design

#### Strategy Profiles
**Strategy A (SMC Swing):**
- Win Rate: 40%
- R:R: 1:3 (hold for runners)
- Scale-out: None (full position close at TP)

**Strategy B (Aggressive Scalp):**
- Win Rate: 60%
- R:R: 1:1
- Scale-out: 50% at +0.5R, 50% at +1R

**Strategy C (Hybrid):**
- Win Rate: 50%
- R:R: 1:2
- Scale-out: 75% at +1R, 25% runners to +3R

#### Monte Carlo Simulation (1000 runs each)
```python
# HWM Trap Simulation
starting_equity = 50_000
trailing_dd_limit = 0.05  # 5% from HWM

for each trade:
    # Update HWM with UNREALIZED PnL
    hwm = max(hwm, equity + unrealized_pnl)

    # Check drawdown from HWM
    current_dd = (hwm - equity) / hwm

    if current_dd >= trailing_dd_limit:
        ACCOUNT_TERMINATED
        survival_rate -= 1
```

#### Track Metrics
- **Survival Rate:** % of runs that don't hit 5% trailing DD
- **Average Lifespan:** Days before termination
- **HWM Trap Events:** Trades that profit but consume DD buffer

### Success Criteria

| Strategy | Expected Survival | Verdict |
|----------|-------------------|---------|
| SMC Swing (A) | < 80% | **INCOMPATIBLE** with Apex |
| Scalp (B) | > 95% | **VIABLE** |
| Hybrid (C) | > 90% | **OPTIMAL** |

**Decision Rule:**
- If Strategy A survival < 85% → **PIVOT IMMEDIATELY** to scalp-focused
- Implement mandatory 50-75% scale-out at +1R (non-negotiable)

### Deliverable
- `APEX_SURVIVAL_ANALYSIS.md` with Monte Carlo results + mandatory scale-out rules

---

## P1-A: SHIFTED LEVELS TEST (Spatial Falsification)

### Hypothesis to Disprove
**Claim:** Order Block precision (specific price levels) provides edge.

**Null Hypothesis:** OBs are "Hindsight Geometry." We're just trading volatility expansion, levels are irrelevant.

### Test Design

#### Step 1: Perturb Levels
```python
# Before execution, add random offset to ALL OB levels
for ob in order_blocks:
    offset = random.uniform(-2.0, +2.0)  # ±$2 in gold
    ob.high_price += offset
    ob.low_price += offset
```

#### Step 2: Run Backtest
- Compare `Performance(Exact)` vs `Performance(Shifted)`
- Bootstrap 100 runs with different random offsets

### Success Criteria
- **Performance(Exact) > Performance(Shifted)** with p < 0.05 → OBs are real
- **Performance(Exact) ≈ Performance(Shifted)** → OBs are illusion, DELETE

### Deliverable
- `SHIFTED_LEVELS_RESULTS.md` with p-values and decision: KEEP OBs / DELETE OBs

---

## P1-B: WICK DESTRUCTION TEST (Pattern Falsification)

### Hypothesis to Disprove
**Claim:** Liquidity Sweeps (wick patterns) provide edge.

**Null Hypothesis:** We're just trading momentum breakouts, "Stop Hunts" are narrativized noise.

### Test Design

#### Step 1: Modify Historical Data
```python
# Pre-process data: shrink all wicks by 50%
for bar in bars:
    body_high = max(bar.open, bar.close)
    body_low = min(bar.open, bar.close)

    upper_wick = bar.high - body_high
    lower_wick = body_low - bar.low

    # Shrink wicks, keep bodies
    bar.high = body_high + (upper_wick * 0.5)
    bar.low = body_low - (lower_wick * 0.5)
```

#### Step 2: Run Backtest on Modified Data
- If strategy still triggers and performs → Sweep logic is hallucinating
- If strategy fails → Sweep detection is real

### Success Criteria
- **Performance(Shrunk Wicks) < Performance(Original)** with p < 0.05 → Sweeps are real
- **Performance(Shrunk Wicks) ≈ Performance(Original)** → DELETE sweep logic

### Deliverable
- `WICK_DESTRUCTION_RESULTS.md` with verdict: KEEP Sweeps / DELETE Sweeps

---

## P2: PERMUTATION IMPORTANCE (Better Ablation)

### Why Better Than Standard Ablation
**Standard Ablation:** Disable factor → retest (loses correlation structure)
**Permutation Importance:** Shuffle factor values → breaks correlation but keeps distribution

### Test Design

#### For Each of 9 Factors:
```python
# Example: Test Fibonacci factor
baseline_sharpe = backtest(all_factors_enabled)

# Shuffle Fibonacci scores (breaks correlation with price)
fib_scores_shuffled = np.random.permutation(fib_scores)

shuffled_sharpe = backtest(fib_scores_shuffled)

# Calculate importance
importance = baseline_sharpe - shuffled_sharpe
```

### Success Criteria

| Importance | Action |
|------------|--------|
| **Δ Sharpe > +0.2** | Factor is CRITICAL, keep |
| **Δ Sharpe ≈ 0** | Factor is NOISE, delete |
| **Δ Sharpe < -0.1** | Factor is TOXIC, delete |

**Expected Keepers (Prediction):**
- Regime (Hurst) ✅
- Structure (HH/LL) ✅
- Time Gates ✅

**Expected Deletions:**
- Fibonacci ❌
- Footprint ❌
- AMD (maybe) ❓

### Deliverable
- `PERMUTATION_IMPORTANCE_RESULTS.md` with factor ranking + simplified 3-5 factor list

---

## Integration with Phase 00

### Updated Week 2 Schedule

**Day 6-7: FALSIFICATION TESTS (PRIORITY INSERT)** (12 hours)
- ⬜ **FALSE-001:** Implement Ghost Strategy (Null Signal Test) (3 hours)
- ⬜ **FALSE-002:** Run Ghost vs SMC backtest comparison (2 hours)
- ⬜ **FALSE-003:** Implement Apex HWM Survival Monte Carlo (4 hours)
- ⬜ **FALSE-004:** Run survival analysis (Strategy A vs B vs C) (2 hours)
- ⬜ **FALSE-005:** Document results + GO/NO-GO decision (1 hour)

**Checkpoint:** If Ghost Test shows Sharpe(Ghost) > 0.5 → **KILL SMC IMMEDIATELY**, pivot to simple regime + momentum

**Day 8-9: Ablation/Permutation Study** (14 hours)
- ⬜ **ABL-001:** Run Permutation Importance (replaces standard ablation) (8 hours)
- ⬜ **ABL-002:** Identify 3-5 keeper factors (2 hours)
- ⬜ **ABL-003:** Simplify confluence scorer (2 hours)
- ⬜ **ABL-004:** Validate simplified system (2 hours)

**Day 10: Shifted Levels + Wick Destruction (OPTIONAL)** (4 hours)
- Only run if Ghost Test shows SMC has value
- If SMC survives Ghost Test, then test precision claims

### Phase 00 GO/NO-GO Criteria (UPDATED)

| Criterion | Current | Target | Required |
|-----------|---------|--------|----------|
| **Null Signal Test Complete** | ❌ | ✅ | **YES** |
| **Apex Survival Analysis Complete** | ❌ | ✅ | **YES** |
| **Scale-out Rules Implemented** | ❌ | ✅ 50-75% at +1R | **YES** |
| MTF duplication resolved | ❌ | ✅ | YES |
| Semantic collision fixed (M15=State, M5=Event) | ❌ | ✅ | YES |
| Test coverage | 52.68% | ≥70% | YES |
| Permutation Importance complete | ❌ | ✅ | YES |
| CRITICAL issues | 34 open | ≤10 open | YES |

---

## DeepThink Recommendations Summary

### ✅ ADOPT IMMEDIATELY
1. **Null Signal Test** (Priority 1)
2. **Apex HWM Survival Monte Carlo** (Priority 1)
3. **M15=State, M5=Event** philosophy (fixes semantic collision)
4. **Mandatory 50-75% scale-out at +1R** (Apex compatibility)
5. **Permutation Importance** (better than ablation)

### 🤔 EVALUATE IN PHASE 02
1. **Shifted Levels Test** (only if SMC survives Ghost Test)
2. **Wick Destruction Test** (only if Sweeps survive Permutation)
3. **Pivot to Order Flow** (if SMC completely fails)

### ❌ REJECT (For Now)
- Immediate pivot to Order Flow (test SMC first with falsification)
- Deleting all 9 factors before testing (use Permutation to decide)

---

## Expected Outcomes (Predictions)

**Most Likely Scenario:**
1. **Ghost Test:** Sharpe(Ghost) ≈ 0.3, Sharpe(SMC) ≈ 0.6
   - **Interpretation:** Filters do 50% of work, SMC adds 50%
   - **Action:** Keep both, but simplify SMC to 3-5 factors

2. **Apex Survival:** Strategy A = 75%, Strategy B = 98%, Strategy C = 95%
   - **Interpretation:** Swing is risky, scalp + hybrid work
   - **Action:** Implement mandatory 75% scale-out at +1R

3. **Permutation Importance:** Regime + Structure + Time Gates = 80% of value
   - **Interpretation:** 9 factors → 5 factors with same edge
   - **Action:** Delete Fibonacci, Footprint, maybe AMD

**Worst Case Scenario:**
- Ghost Test shows Sharpe(Ghost) > Sharpe(SMC)
- **Action:** KILL ENTIRE SMC SYSTEM, pivot to simple regime filter + momentum/order flow

**Best Case Scenario:**
- SMC adds significant value (Sharpe delta > 0.5)
- OBs survive Shifted Levels test
- **Action:** Keep SMC but still simplify to 5 factors for robustness

---

## Final Notes

**DeepThink is RIGHT:** We are likely suffering from "Complexity Theater."

**The tests above will prove/disprove in 2-3 days of work** what would take 6 months of failed live trading to discover.

**Execution Rule:** Run these tests BEFORE Phase 02 SMC audit. If SMC fails Ghost Test, we skip entire Phase 02 and pivot immediately.

**Risk Management:** This is EXACTLY the kind of adversarial thinking that prevents catastrophic capital loss.

---

*Created from DeepThink Red Team Audit - 2025-12-23*
