# SIMPLIFICATION PLAN: From 9 Factors to 3-4

**Document:** 08-SIMPLIFICATION_PLAN.md
**Created:** 2025-12-23
**Agent:** CRUCIBLE v4.2
**CLAUDE_MD_VERSION:** 3.10.21
**STATUS:** COMPLETE

---

## Executive Summary

**Why we are simplifying - evidence from ARGUS research:**

The current 9-factor confluence system is fundamentally broken. ARGUS research triangulated academic papers, code analysis, and empirical observations to conclude:

> "9 factors where 8 score 0 is the WORST of both worlds: complexity overhead without complexity benefit. SIMPLIFY AGGRESSIVELY."

Key evidence:
1. **Only 1 of 9 factors fires** - Structure scores 15.0, all others score 0.0
2. **7 trades in 6 months** - Expected 200+ for a scalping system
3. **Thompson sampling cannot converge** - AdaptiveEVRouter is permanently in cold-start mode
4. **Simple systems outperform complex ones** - Academic research strongly favors Occam's Razor
5. **ICT SMC was developed for daily charts** - M5 application is unvalidated

**Bottom Line:** We have a 15,000-line system that produces 7 trades. A 200-line EMA crossover would produce 100+. The complexity is not justified.

---

## Current State (BROKEN)

| Metric | Current | Problem |
|--------|---------|---------|
| Confluence factors | 9 | 8 score 0.0 (dead code) |
| Factors firing | 1 (structure only) | Not "confluence" - single factor |
| Trades in 6 months | 7 | 28x fewer than minimum for validation |
| Score threshold | 35 | Cannot be reached when only structure fires |
| AdaptiveEVRouter | Active (Thompson sampling) | Cold-start forever with 1 trade/month |
| Code complexity | ~15,000 LOC | For 7 trades? |

### Factor Analysis (Empirical Observations)

| Factor | Weight | Observed Score | Status |
|--------|--------|----------------|--------|
| Structure (BOS/CHoCH) | 15pts | 15.0 | **ONLY ONE FIRING** |
| Regime (Hurst/Entropy) | 10pts | 0.0 | Dead |
| Order Blocks | 15pts | 0.0 | Semantic collision |
| FVG | 10pts | 0.0 | Semantic collision |
| Liquidity Sweep | 10pts | 0.0 | Dead |
| AMD Cycle | 10pts | 0.0 | Dead |
| Fibonacci | 5pts | 0.0 | Dead |
| MTF Alignment | 15pts | 0.0 | Semantic collision |
| Footprint | 10pts | 0.0 | **No futures data!** |

### Root Causes Identified

1. **Semantic Collision:** Variable `_mtf_order_blocks` is overwritten by LTF detection. Scorer receives M5 data thinking it is M15 structural zones.

2. **Footprint Analyzer:** Requires futures volume data that does not exist. Dead code since day one.

3. **Session Adjustment Bug:** Was killing scores (fixed in commit 58b84178), but underlying factor issues remain.

4. **Over-engineering:** Thompson sampling router for a system producing ~1 trade/month.

---

## Target State (SIMPLIFIED)

| Metric | Current | Target | Improvement |
|--------|---------|--------|-------------|
| Active factors | 1 | 3-4 | All contribute |
| Trades in 6 months | 7 | 100-200+ | 15-30x increase |
| Threshold | 35 (old scale) | 50 (new scale) | Calibrated to factors |
| Adaptive routing | Active (useless) | Disabled | Remove dead complexity |
| Code complexity | ~15,000 LOC | ~10,000 LOC | 33% reduction |

---

## Factors to KEEP (with rationale)

### 1. Structure (Weight: 40%)

**Evidence:**
- Currently the ONLY factor that fires (score=15.0)
- Validates market structure (HH/HL/LH/LL, BOS/CHoCH)
- ARGUS: "Structure detection works (fires consistently)"

**Rationale:**
- This is the CORE of SMC philosophy
- Without structure, there is no valid SMC signal
- Structure represents the "story" of price action

**Weight Justification:**
- Receives highest weight because it is necessary (but not sufficient) for any signal
- 40% ensures structure alone cannot trigger a trade

---

### 2. Order Blocks (Weight: 30%)

**Evidence:**
- Currently scoring 0 due to semantic collision
- Core SMC concept - institutional accumulation/distribution zones
- ARGUS research validates OBs but notes they need HTF confirmation

**Rationale:**
- Order Blocks represent where "smart money" accumulated positions
- AFTER FIX: Renaming `_mtf_order_blocks` should restore functionality
- Must use M15 structural zones, not M5 noise

**Weight Justification:**
- Second highest because OBs provide the "where" to trade
- 30% allows Structure + OB to form valid signal

**Implementation Note:**
```
BEFORE: _mtf_order_blocks (overwritten by LTF)
AFTER:  _htf_order_blocks (M15+, untouched)
        _ltf_order_blocks (M5, separate)
```

---

### 3. FVG (Weight: 20%)

**Evidence:**
- Currently scoring 0 due to semantic collision
- Fair Value Gaps represent market imbalance
- ARGUS: Valid SMC concept, but noisier on short timeframes

**Rationale:**
- FVGs show where price moved too fast, leaving inefficiency
- Price tends to return to fill FVGs
- Provides additional confluence for entry timing

**Weight Justification:**
- Lower weight than OB because FVGs are more noise-prone on M5
- 20% means FVG alone is not sufficient, but adds meaningful confluence

**Implementation Note:**
Same semantic collision fix as OB - separate HTF/LTF variables.

---

### 4. Session (Weight: 10%)

**Evidence:**
- Working correctly in observations (Asian blocked, Overlap allowed)
- ARGUS: "Session-based scalping: NY session focus, 5-15 pips per trade, 8-12% monthly"
- Prop firms focus on 7:30-10:00 AM ET (London-NY overlap)

**Rationale:**
- This is a FILTER, not a signal
- Prevents trading during low-liquidity Asian session
- Aligns with XAUUSD best trading windows

**Weight Justification:**
- Lowest weight because it is binary (allowed/blocked)
- 10% provides bonus during optimal sessions
- Does not prevent signals during acceptable sessions

---

## Factors to REMOVE (with rationale)

### 5. Regime - REMOVE

**Evidence:**
- Scoring 0.0 in all observations
- ARGUS: "Hurst exponent is appropriate but current implementation appears broken"
- CRUCIBLE: "Redundant with StrategySelector"

**Rationale:**
- Hurst exponent is computationally expensive
- StrategySelector already has regime detection gate
- Duplicating regime logic in confluence is redundant

**Action:** Set weight = 0, archive code later

---

### 6. AMD - REMOVE

**Evidence:**
- Scoring 0.0 consistently
- No evidence of edge in ARGUS research
- Accumulation/Manipulation/Distribution is for DAILY charts

**Rationale:**
- ICT AMD concept applies to daily/weekly cycles
- On M5, AMD patterns are noise
- Over-complicates without proven value

**Action:** Set weight = 0, archive code later

---

### 7. Fib - REMOVE

**Evidence:**
- Scoring 0.0
- ARGUS: "No unique edge for M5 XAUUSD"
- Fibonacci is a lagging indicator

**Rationale:**
- Structure detection already identifies key levels
- Fib overlaps with structure without adding unique information
- Self-fulfilling prophecy effect is diluted on short timeframes

**Action:** Set weight = 0, archive code later

---

### 8. MTF (as separate factor) - REMOVE

**Evidence:**
- Scoring 0.0 due to semantic collision
- ARGUS: Semantic collision makes it unreliable

**Rationale:**
- MTF alignment is IMPLICIT in OB/FVG detection
- When we fix OB to use M15 zones for M5 entries, MTF is embedded
- Separate MTF factor is redundant

**Action:** Set weight = 0; MTF concept lives on through OB/FVG timeframe separation

---

### 9. Footprint - REMOVE

**Evidence:**
- No futures volume data available
- ARGUS: "Dead code since day one"

**Rationale:**
- Footprint analysis requires tick-by-tick volume from futures markets
- We have forex spot data only
- Cannot fire, ever

**Action:** Archive entire `footprint_analyzer.py` and related tests

---

### 10. Sweep - REMOVE (for now)

**Evidence:**
- Scoring 0.0
- Liquidity sweeps are valid SMC concept

**Rationale:**
- On M5 tick data with stride 20, sweep detection may miss events
- Sweeps happen in milliseconds; stride 20 discards 95% of ticks
- May add back if simplified system works and we get better data

**Action:** Set weight = 0; revisit after simplification validates

---

## AdaptiveEVRouter Decision

### Problem

ARGUS finding:
> "Thompson sampling is COMPLETELY INAPPROPRIATE for our trade frequency. With ~1 trade/month, it would take DECADES for the bandit to converge. REMOVE AdaptiveEVRouter until trade frequency increases 10x."

### Evidence

| Requirement | Needed | Current | Assessment |
|-------------|--------|---------|------------|
| Sample size for convergence | O(ln(T)) per arm | 7 total | CANNOT CONVERGE |
| Pulls per arm for PAC bounds | ~50-100 | ~2-3 per strategy | MEANINGLESS |
| Reward signal | Stable, identifiable | Insufficient | CANNOT LEARN |

### Decision: DISABLE

**Implementation:**
1. Set `router_adaptive_ev = False` in strategy config
2. Use static allocation: SMC_SCALPER = 100%
3. Archive `adaptive_router.py` to `_archive/deferred/`

**Recovery Plan:**
Re-enable when:
- Trade frequency > 200/year per strategy
- Multiple strategies have validated edge
- Correlation matrix can be computed

---

## New Weight Distribution

### Old System (broken)

| Factor | Weight | Contribution |
|--------|--------|--------------|
| Structure | 15pts | 15.0 (ONLY ONE) |
| Regime | 10pts | 0.0 |
| Order Blocks | 15pts | 0.0 |
| FVG | 10pts | 0.0 |
| Sweep | 10pts | 0.0 |
| AMD | 10pts | 0.0 |
| Fib | 5pts | 0.0 |
| MTF | 15pts | 0.0 |
| Footprint | 10pts | 0.0 |
| **TOTAL** | 100pts | **15.0** |

**Threshold: 35 -- UNREACHABLE with only structure firing**

### New System (simplified)

| Factor | Weight | Expected Contribution |
|--------|--------|----------------------|
| Structure | 40pts | 40.0 (when valid) |
| Order Blocks | 30pts | 15-30 (partial-full) |
| FVG | 20pts | 10-20 (partial-full) |
| Session | 10pts | 0-10 (bonus) |
| **TOTAL** | 100pts | **65-100** |

**New Threshold: 50**

### Threshold Rationale

| Scenario | Score | Outcome |
|----------|-------|---------|
| Structure alone | 40 | NO TRADE (< 50) |
| Structure + partial OB | 55 | TRADE |
| Structure + OB | 70 | STRONG TRADE |
| Structure + OB + FVG | 90 | EXCELLENT TRADE |
| Structure + Overlap bonus | 50 | MARGINAL TRADE |

This ensures:
- Structure is necessary but not sufficient
- At least one additional factor must confirm
- Trade frequency should increase 15-30x

---

## Implementation Steps

### Step 1: Diagnostic Logging (Day 1, 2 hours)

**Objective:** Understand exactly why each factor scores 0

**Tasks:**
1. Add verbose logging to `confluence_scorer.py`:
   - Log each factor's raw calculation
   - Log input data (OB list, FVG list, etc.)
   - Log before/after weights
2. Run 1-week backtest with diagnostic output
3. Analyze logs to confirm root causes

**Gate:** Can see each factor's contribution in logs

**Owner:** FORGE

---

### Step 2: Fix Semantic Collision (Day 1-2, 4 hours)

**Objective:** Separate HTF/MTF/LTF data flows

**Tasks:**
1. Rename variables in `gold_scalper_strategy.py`:
   ```python
   # BEFORE
   self._mtf_order_blocks = []  # Overwritten!

   # AFTER
   self._htf_order_blocks = []  # M15+, preserved
   self._mtf_order_blocks = []  # M5-M15
   self._ltf_order_blocks = []  # M5, entry timing
   ```
2. Same for FVGs:
   ```python
   self._htf_fvgs = []
   self._mtf_fvgs = []
   self._ltf_fvgs = []
   ```
3. Update `mtf_manager.py` to populate correct lists
4. Update confluence scorer to receive HTF data
5. Run validation backtest

**Gate:** OB and FVG score > 0 in diagnostic log

**Owner:** FORGE

---

### Step 3: Disable Dead Factors (Day 2, 2 hours)

**Objective:** Remove 6 non-contributing factors from scoring

**Tasks:**
1. In `confluence_scorer.py`, set weights to 0:
   ```python
   WEIGHTS = {
       'structure': 40,   # KEEP
       'ob': 30,          # KEEP
       'fvg': 20,         # KEEP
       'session': 10,     # KEEP
       'regime': 0,       # DISABLED
       'sweep': 0,        # DISABLED
       'amd': 0,          # DISABLED
       'fib': 0,          # DISABLED
       'mtf': 0,          # DISABLED (concept in OB/FVG)
       'footprint': 0,    # DISABLED
   }
   ```
2. OR: Remove disabled factors from calculation entirely
3. Update related tests

**Gate:** Only 4 factors contribute to score

**Owner:** FORGE

---

### Step 4: Lower Threshold (Day 2, 30 min)

**Objective:** Calibrate threshold to new scoring system

**Tasks:**
1. Change `score_threshold` from 35 to 50
2. Make threshold configurable in YAML
3. Document threshold meaning in code comments

**Gate:** Threshold matches expected score ranges

**Owner:** FORGE

---

### Step 5: Disable Adaptive Router (Day 2, 30 min)

**Objective:** Remove non-functioning complexity

**Tasks:**
1. Set `router_adaptive_ev = False` as default
2. Verify static allocation works
3. Document reason for disabling

**Gate:** Strategy uses direct SMC_SCALPER without router

**Owner:** FORGE

---

### Step 6: Validate Trade Frequency (Day 3, 2 hours)

**Objective:** Confirm simplified system produces sufficient trades

**Tasks:**
1. Run 6-month backtest (Jan-Jun 2024)
2. Count trades
3. If < 100 trades: lower threshold to 45
4. If still < 100: investigate further

**Gate:** >= 100 trades in 6 months (target: 200+)

**Owner:** ORACLE

---

### Step 7: Ablation on Simplified System (Day 3-4, 4 hours)

**Objective:** Verify each kept factor contributes edge

**Tasks:**
1. Run 4 ablation configs:
   - Baseline (all 4 factors)
   - Without Structure (expect failure)
   - Without OB
   - Without FVG
   - Without Session bonus
2. Compare WFE for each config
3. Any factor with < 5% WFE contribution: consider removal

**Gate:** Each kept factor contributes >= 5% WFE delta

**Owner:** CRUCIBLE + ORACLE

---

### Step 8: Archive Dead Code (Day 4, 2 hours)

**Objective:** Clean up codebase

**Tasks:**
1. Create `_archive/` directory structure:
   ```
   _archive/
     deferred/          # May re-enable later
       adaptive_router.py
     removed/           # Unlikely to return
       footprint_analyzer.py
       mean_revert.py (if exists)
     legacy/            # Old implementations
       indicators/mtf_manager.py
   ```
2. Move files
3. Update imports
4. Archive related tests
5. Verify all tests pass

**Gate:** Clean codebase, all tests pass

**Owner:** FORGE

---

## Code Changes Required

### 1. confluence_scorer.py

**Location:** `nautilus_gold_scalper/src/signals/confluence_scorer.py`

**Changes:**
- Add diagnostic logging (log each factor's score)
- Zero-weight or remove: regime, amd, fib, mtf, footprint, sweep
- Reweight remaining: structure=40, ob=30, fvg=20, session=10
- Update threshold: 35 --> 50
- Estimated delta: ~50 lines modified, ~100 lines simplified

### 2. gold_scalper_strategy.py

**Location:** `nautilus_gold_scalper/src/strategies/gold_scalper_strategy.py`

**Changes:**
- Fix semantic collision (rename OB/FVG variables)
- Set `router_adaptive_ev = False` as default
- Simplify candidate generation (remove dead paths)
- Estimated delta: ~100 lines modified

### 3. mtf_manager.py (signals/)

**Location:** `nautilus_gold_scalper/src/signals/mtf_manager.py`

**Changes:**
- Rename OB/FVG variables to include timeframe prefix
- Ensure HTF/MTF/LTF data flows are separated
- Estimated delta: ~30 lines modified

### 4. Files to Archive

| File | Destination | Reason |
|------|-------------|--------|
| `adaptive_router.py` | `_archive/deferred/` | Cannot converge at current trade frequency |
| `footprint_analyzer.py` | `_archive/removed/` | No futures data available |
| `indicators/mtf_manager.py` | `_archive/legacy/` | Duplicate of signals/ version |
| `test_footprint_*.py` (3 files) | `_archive/removed/tests/` | Tests for removed code |

---

## Success Criteria

| Metric | Before | Target | Validation |
|--------|--------|--------|------------|
| Active factors | 9 (8 dead) | 4 (all active) | Diagnostic logs |
| Factors scoring > 0 | 1 | 3-4 | Backtest output |
| Trades/6mo | 7 | 100+ (target 200+) | Backtest count |
| WFE | Unknown | >= 0.6 | ORACLE validation |
| Code complexity | ~15,000 LOC | ~10,000 LOC | LOC count |
| Adaptive router | Active (useless) | Disabled | Config check |

---

## Risk Mitigation

### Risk 1: Semantic collision fix does not make OB/FVG fire

**Probability:** Medium
**Impact:** High (plan fails)
**Mitigation:** Diagnostic logging first; understand root cause before fix
**Fallback:** If OB/FVG truly cannot fire, simplify to Structure + Session only

### Risk 2: Lowered threshold produces too many low-quality trades

**Probability:** Medium
**Impact:** Medium (worse WFE)
**Mitigation:** Ablation study validates each factor contributes edge
**Fallback:** Raise threshold incrementally until WFE >= 0.6

### Risk 3: Simplified system performs worse than broken complex system

**Probability:** Low
**Impact:** High (wasted effort)
**Mitigation:** Git branch before changes; A/B comparison
**Fallback:** Revert to original, investigate differently

### Risk 4: Removing adaptive router loses some value

**Probability:** Very Low (router never converged)
**Impact:** None
**Mitigation:** Archive, do not delete; re-enable when trade frequency justifies

### Risk 5: Structure-only signals are noise

**Probability:** Low
**Impact:** High
**Mitigation:** Compare to random entry baseline (add to validation)
**Fallback:** If Structure alone < random, SMC approach is invalid

### Git Strategy

1. Create branch: `simplify-confluence-v1`
2. Checkpoint commits after each step
3. Run validation backtest after each major change
4. Merge to main only after all gates pass

---

## Timeline

| Day | Task | Hours | Owner | Gate |
|-----|------|-------|-------|------|
| 1 AM | Diagnostic logging | 2h | FORGE | See factor contributions |
| 1 PM | Fix semantic collision | 4h | FORGE | OB/FVG score > 0 |
| 2 AM | Disable dead factors | 2h | FORGE | Only 4 factors active |
| 2 AM | Lower threshold | 0.5h | FORGE | Threshold = 50 |
| 2 AM | Disable adaptive router | 0.5h | FORGE | Static allocation |
| 3 AM | Validate trade frequency | 2h | ORACLE | >= 100 trades |
| 3 PM | Ablation study | 4h | CRUCIBLE + ORACLE | Each factor contributes |
| 4 AM | Archive dead code | 2h | FORGE | Clean codebase |

**Total: 4 days (17 hours work)**

vs. Original Phase 00: 2 weeks (49+ hours planned, 62-77 hours realistic)

---

## Handoff Chain

```
CRUCIBLE (this plan)
    |
    v
FORGE (implementation)
    |
    v
ORACLE (validation - WFE/SQN/PSR)
    |
    v
SENTINEL (Apex compliance check)
    |
    v
User GO/NO-GO
```

---

## Appendix: ARGUS Research Key Findings

### Multi-Strategy Systems

> "Thompson sampling requires logarithmic sample sizes to converge - with ~7 trades, the algorithm is permanently in cold-start mode and cannot have learned anything useful."

### Complexity vs Performance

> "Strong evidence that simpler systems outperform complex ones. The current 9-factor system (where 8 factors score 0) is the WORST of both worlds: complexity overhead without complexity benefit."

### SMC on M5 XAUUSD

> "ICT SMC was developed for forex DAILY charts. Order blocks represent institutional accumulation over hours/days. On M5, you see HFT and retail flow, NOT 'smart money footprints'."

### Recommendation

> "SIMPLIFY AGGRESSIVELY. Remove/archive all factors that do not fire. Simplify to structure + session filter + risk management. Validate this simple version FIRST. Add complexity ONLY when simple version proves insufficient."

---

*"A 9-factor confluence system where 8 factors score zero is not sophisticated - it is broken. Fix the foundation before adding floors."*

**CRUCIBLE v4.2 - The Backtest Quality Guardian**
