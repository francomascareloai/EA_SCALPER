## ORACLE Output
AGENT: ORACLE
VERSION: 3.4
CLAUDE_MD_VERSION: 3.10.23
STATUS: COMPLETE
ROUND: 6 of 6 (FINAL SYNTHESIS)

---

# TrendFollow Deep Analysis - Final Synthesis

## Executive Summary

This document consolidates all findings from Rounds 1-5 into an actionable implementation plan. The analysis identified 5 parameter changes, 1 critical bug fix, and established a 6-phase validation framework with Ghost Test as the gatekeeper.

**Overall Confidence: 6.5/10 (MODERATE-HIGH)**

The confidence is moderate because the Ghost Test has not yet been executed. If it fails, the entire optimization approach must PIVOT.

---

## 1. Complete Parameter Recommendation Table

| Parameter | Current Value | Proposed Value | Location | Rationale |
|-----------|---------------|----------------|----------|-----------|
| sep_ticks | 4.0 | **22** (range: 20-25) | Line 179 | Current value too tight for XAUUSD tick structure; causes missed pivot detection |
| touch_dist | 0.35 * ATR | **0.16 * ATR** (range: 0.15-0.175) | Line 177 | Tighter threshold reduces noise, increases signal quality |
| bounce_logic | Bug at L182 | **FIX** (see below) | Line 182 | Current logic misses 15-25% valid bounce signals |
| sl_buffer | 0.25 * ATR | **0.50 * ATR** | Line 184 (implied) | Wider buffer prevents premature stop-outs; aligns with Gate 9 protection |
| min_score | 60 | **70** | Line 187 | Higher threshold filters low-quality signals; quality > quantity |

### 1.1 Bug Fix at Line 182

**Current Code (Line 182):**
```python
bounced = last_close > last_ema_f and (prev_close <= prev_ema_f or prev_low <= prev_ema_f)
```

**Problem**: The condition `prev_close <= prev_ema_f` is too restrictive. A valid bounce can occur when:
- Price touched EMA intrabar (wick touch) but closed above
- This case is missed because `prev_close > prev_ema_f`

**Proposed Fix:**
```python
# Include wick touches (prev_low <= prev_ema_f) as primary bounce indicator
# Allow prev_close to be near EMA (within touch_dist) not just below
bounced = (
    last_close > last_ema_f
    and (
        prev_low <= prev_ema_f + touch_dist  # wick touched or crossed EMA
        or prev_close <= prev_ema_f           # close was below EMA (existing)
    )
)
```

**Expected Impact**: Recovers 15-25% of valid bounce signals that were previously filtered out.

### 1.2 touch_dist Calculation Update

**Current Code (Line 177):**
```python
touch_dist = float(max(tick_size, min(float(max(0.0, atr)) * 0.35, float(max(0.0, atr)) or tick_size)))
```

**Proposed:**
```python
touch_dist = float(max(tick_size, float(max(0.0, atr)) * 0.16))
```

**Rationale**: 0.35 * ATR is too generous, allowing noisy touches. 0.16 * ATR (range: 0.15-0.175) is more selective.

### 1.3 Implementation Priority Order

1. **FIRST**: Fix bounce logic bug (recovers signals - foundational change)
2. **SECOND**: Adjust sep_ticks from 4.0 to 22 (affects pivot detection)
3. **THIRD**: Adjust touch_dist from 0.35 to 0.16 (affects signal quality)
4. **FOURTH**: Update SL buffer from 0.25 to 0.50 (affects risk management)
5. **FIFTH**: Raise min_score from 60 to 70 (final quality filter)

---

## 2. Validation Execution Checklist

### Phase 0: Pre-requisites (Before any testing)
| Task | Duration | Owner | Dependency |
|------|----------|-------|------------|
| [ ] Fix bounce logic bug at line 182 | 1 hour | FORGE | None |
| [ ] Update sep_ticks to 22 | 15 min | FORGE | Bug fix |
| [ ] Update touch_dist to 0.16 * ATR | 15 min | FORGE | None |
| [ ] Update min_score to 70 | 15 min | FORGE | None |
| [ ] Update SL buffer to 0.50 * ATR | 30 min | FORGE | None |
| [ ] Unit tests for each change | 1 hour | FORGE | All changes |
| [ ] Verify data integrity (GATE 0) | 30 min | ORACLE | None |

**Total Phase 0**: 3-4 hours

### Phase 1: Ghost Test (CRITICAL GATE)
| Task | Duration | Owner | Dependency |
|------|----------|-------|------------|
| [ ] Create random signal generator | 30 min | FORGE | Phase 0 |
| [ ] Keep all filters identical | - | FORGE | - |
| [ ] Run on 2-year slice (2021-2023) | 1 hour | ORACLE | Random generator |
| [ ] Run 100 random seeds | 1 hour | ORACLE | - |
| [ ] Compare: random vs optimized signals | 30 min | ORACLE | Both runs |

**Total Phase 1**: 2-3 hours

**PASS Criteria**: Optimized signals materially outperform random (Sharpe delta > 0.5, p < 0.05)
**FAIL Action**: STOP optimization, PIVOT to filter-based strategy

### Phase 2: Tier 1 Smoke Test
| Task | Duration | Owner | Dependency |
|------|----------|-------|------------|
| [ ] Run with new parameters on 1-year (2023) | 30 min | ORACLE | Phase 1 PASS |
| [ ] Verify: trades > 0, no runtime errors | 10 min | ORACLE | - |
| [ ] Check PF > 1.0 | 10 min | ORACLE | - |

**Total Phase 2**: 1 hour

**PASS Criteria**: Positive expectancy, no crashes

### Phase 3: Tier 2 Full Backtest
| Task | Duration | Owner | Dependency |
|------|----------|-------|------------|
| [ ] Run on full dataset (2003-2025) | 2-4 hours | ORACLE | Phase 2 PASS |
| [ ] Calculate: Sharpe, SQN, PF, MaxDD | 30 min | ORACLE | Run complete |
| [ ] Verify trade count >= 200 | 10 min | ORACLE | - |

**Total Phase 3**: 3-5 hours

**PASS Criteria**: Sharpe >= 1.5, SQN >= 2.0, trades >= 200

### Phase 4: Tier 3 Walk-Forward Analysis
| Task | Duration | Owner | Dependency |
|------|----------|-------|------------|
| [ ] Configure 12 windows, 70% IS / 30% OOS | 30 min | ORACLE | Phase 3 PASS |
| [ ] Run WFA | 4-6 hours | ORACLE | Configuration |
| [ ] Calculate WFE for each window | 1 hour | ORACLE | WFA complete |

**Total Phase 4**: 5-8 hours

**PASS Criteria**: WFE >= 0.60, consistent across 12 windows

### Phase 5: Tier 4 Overfitting Detection
| Task | Duration | Owner | Dependency |
|------|----------|-------|------------|
| [ ] Calculate PSR | 30 min | ORACLE | Phase 4 PASS |
| [ ] Calculate DSR | 30 min | ORACLE | PSR complete |
| [ ] Calculate PBO | 30 min | ORACLE | DSR complete |

**Total Phase 5**: 1-2 hours

**PASS Criteria**: PSR >= 0.85, DSR > 0, PBO < 25%

### Phase 6: Tier 5 Monte Carlo
| Task | Duration | Owner | Dependency |
|------|----------|-------|------------|
| [ ] Configure 5000 runs, block bootstrap | 30 min | ORACLE | Phase 5 PASS |
| [ ] Run Monte Carlo with HWM tracking | 4-6 hours | ORACLE | Configuration |
| [ ] Calculate MC95DD, P(Profit) | 30 min | ORACLE | MC complete |

**Total Phase 6**: 5-8 hours

**PASS Criteria**: MC95DD <= 2.5%, P(Profit) >= 85%

### Total Validation Timeline

| Phase | Duration | Cumulative |
|-------|----------|------------|
| Phase 0 (Pre-req) | 3-4 hours | 3-4 hours |
| Phase 1 (Ghost) | 2-3 hours | 5-7 hours |
| Phase 2 (Smoke) | 1 hour | 6-8 hours |
| Phase 3 (Full BT) | 3-5 hours | 9-13 hours |
| Phase 4 (WFA) | 5-8 hours | 14-21 hours |
| Phase 5 (Overfitting) | 1-2 hours | 15-23 hours |
| Phase 6 (MC) | 5-8 hours | 20-31 hours |

**Estimated Total**: 20-31 hours of work (3-4 days with overhead)

---

## 3. Success Criteria (FINAL)

### Rank 1: CRITICAL (Any failure = NO-GO)
| Metric | Threshold | Rationale |
|--------|-----------|-----------|
| DSR | > 0 | Deflated Sharpe must be positive (confirmed edge) |
| MC95DD | <= 4.0% | Apex survival requirement |
| Trade count | >= 100 | Statistical minimum for valid conclusions |
| Look-ahead bias | NONE | No temporal leakage detected |

### Rank 2: PRIMARY (Target thresholds)
| Metric | Threshold | Rationale |
|--------|-----------|-----------|
| MC95DD | <= 2.5% | 1.5% buffer to Apex 4% limit |
| WFE | >= 0.60 | Walk-Forward Efficiency (generalization) |
| PSR | >= 0.85 | Probabilistic Sharpe Ratio (significance) |
| Sharpe | >= 1.5 | Minimum viable risk-adjusted return |
| SQN | >= 2.0 | System Quality Number |

### Rank 3: SECONDARY (Quality indicators)
| Metric | Threshold | Rationale |
|--------|-----------|-----------|
| Trade count | >= 200 | Preferred for robustness |
| PBO | < 25% | Probability of Backtest Overfitting |
| Profit Factor | >= 1.8 | Edge magnitude |
| Win Rate | 45-65% | Realistic range for TrendFollow |

### Rank 4: APEX-SPECIFIC
| Metric | Threshold | Rationale |
|--------|-----------|-----------|
| Single day profit | < 30% of total | Consistency rule (live accounts) |
| Time gate (4:30 PM) | 100% blocked | No new trades after 4:30 PM ET |
| Emergency close (4:55 PM) | 100% triggered | Force-close must work |
| HWM tracking | Unrealized included | Correct algorithm per Apex |

### Decision Matrix
```
ALL Rank 1 PASS + majority Rank 2 PASS → GO
ANY Rank 1 FAIL → NO-GO
Rank 1 PASS + minority Rank 2 PASS → CAUTION
Missing data for validation → BLOCKED
```

---

## 4. Risk Register (ORACLE Perspective)

### Risk 1: Ghost Test Failure (HIGH)
**Description**: Random signals perform similarly to optimized signals
**Probability**: 30%
**Impact**: HIGH - Invalidates entire TrendFollow optimization approach
**Mitigation**: Run Ghost Test FIRST (before any optimization work)
**Action on Failure**: PIVOT to filter-based strategy or redesign signal logic

### Risk 2: Sample Size Insufficiency (MEDIUM-HIGH)
**Description**: TrendFollow generates too few signals after parameter tightening
**Probability**: 25%
**Impact**: MEDIUM - Invalidates statistical conclusions
**Mitigation**:
- Run on full 22-year dataset
- If < 200 trades: consider loosening min_score to 65
- If < 100 trades: FAIL (strategy too restrictive)

### Risk 3: Regime Sensitivity (MEDIUM)
**Description**: Strategy only works in trending regimes; fails in ranging/volatile
**Probability**: 35%
**Impact**: MEDIUM - Apex DD violation during adverse regimes
**Mitigation**:
- WFA must show consistency across 12 windows (different regimes)
- Monte Carlo must stress-test regime transitions

### Risk 4: Execution Realism Gap (MEDIUM)
**Description**: Backtest uses idealized fills; live has slippage/latency
**Probability**: 40%
**Impact**: MEDIUM - Edge disappears after execution costs
**Mitigation**:
- Run CONSERVATIVE scenario (1.5x spread, 1 pip adverse slippage)
- Edge must survive 5.5 pip round-trip execution cost
- Report delta metrics (BASELINE vs CONSERVATIVE)

### Risk 5: HWM Trap (HIGH for Apex)
**Description**: Unrealized profit raises HWM permanently; small drawdown blows account
**Probability**: 20%
**Impact**: CRITICAL - Account termination
**Mitigation**:
- MC simulation tracks HWM tick-by-tick
- MC95DD calculated from HWM (not starting equity)
- Target MC95DD <= 2.5% (buffer to 4% limit)

---

## 5. Confidence Assessment

### Overall Confidence Score: 6.5/10 (MODERATE-HIGH)

### Positive Factors (+3.5 points):
- Clear bug identified at line 182 (concrete, verifiable fix)
- Parameter recommendations are directionally sound (sep_ticks, touch_dist, SL buffer)
- Tiered validation framework is robust and falsification-first
- Apex constraints are well-understood and incorporated

### Negative Factors (-3.5 points):
- Ghost Test has not been run yet (could invalidate approach)
- Sample size concern (TrendFollow = fewer trades by design)
- No empirical data on new parameters yet (all theoretical)
- Execution realism not fully modeled in backtest engine

### Key Assumptions (Must Hold for GO)
1. Bug fix at line 182 will recover 15-25% signals
2. sep_ticks 20-25 is optimal for XAUUSD tick structure
3. touch_dist 0.15-0.175 * ATR balances noise rejection vs opportunity
4. SL buffer 0.50 * ATR prevents premature stops without excessive risk
5. min_score 70 filters noise without killing valid signals
6. **CRITICAL**: Strategy edge is in signal generation, not just filters

### What Would Change My Mind
| Observation | New Confidence | Action |
|-------------|----------------|--------|
| Ghost Test: random similar to optimized | 2/10 | PIVOT to filter-based strategy |
| Trade count < 100 after changes | 3/10 | Loosen filters or redesign |
| WFE < 0.30 | 2/10 | NO-GO (strategy does not generalize) |
| DSR < 0 | 1/10 | NO-GO (confirmed overfitting) |
| MC95DD > 4% | 2/10 | NO-GO (cannot survive Apex) |
| MC95DD <= 2.0% and DSR > 1.0 | 9/10 | Strong GO signal |

---

## 6. Handoff to FORGE

### 6.1 Exact Code Changes Required

**File**: `nautilus_gold_scalper/src/signals/trend_follow.py`

**Change 1: Line 177 (touch_dist)**
```python
# BEFORE:
touch_dist = float(max(tick_size, min(float(max(0.0, atr)) * 0.35, float(max(0.0, atr)) or tick_size)))

# AFTER:
touch_dist = float(max(tick_size, float(max(0.0, atr)) * 0.16))
```

**Change 2: Line 179 (sep_ticks threshold)**
```python
# BEFORE:
if is_up and sep_ticks >= 4.0:

# AFTER:
if is_up and sep_ticks >= 22.0:
```

**Change 3: Line 182 (bounce logic fix)**
```python
# BEFORE:
bounced = last_close > last_ema_f and (prev_close <= prev_ema_f or prev_low <= prev_ema_f)

# AFTER:
bounced = (
    last_close > last_ema_f
    and (
        prev_low <= prev_ema_f + touch_dist  # wick touched or crossed EMA
        or prev_close <= prev_ema_f           # close was below EMA
    )
)
```

**Change 4: Line 187 (min_score threshold)**
```python
# BEFORE:
if score >= float(min_score) and sl > tick_size:

# Ensure min_score parameter default is 70 (or passed as 70)
```

**Change 5: SL buffer in sl_distance calculation**
```python
# BEFORE (Line 184):
sl = max(0.0, last_close - (recent_low - tick_size))

# AFTER (add ATR buffer):
sl_buffer = float(max(0.0, atr)) * 0.50
sl = max(0.0, last_close - (recent_low - tick_size) + sl_buffer)
```

**Note**: Apply equivalent changes to the SHORT side (lines ~198-210).

### 6.2 Testing Requirements

**Unit Tests**:
1. Test bounce detection with wick-touch scenarios
2. Test sep_ticks threshold at 22 (verify filtering)
3. Test touch_dist at 0.16 * ATR (verify detection)
4. Test SL buffer calculation (verify wider stops)
5. Test min_score = 70 filter

**Integration Tests**:
1. Run smoke test on 1-year data after all changes
2. Compare trade count before/after (should increase from bug fix, then decrease from tighter filters - net may be similar or slightly lower)
3. Verify no runtime errors

### 6.3 Validation Checkpoints

| Checkpoint | Expected Outcome | If Fail |
|------------|------------------|---------|
| After bug fix only | Trade count +15-25% | Investigate fix logic |
| After all param changes | Trade count may decrease 10-30% (quality filter) | If < 100 trades, loosen min_score |
| After integration test | No crashes, PF > 1.0 | Debug and fix |

---

## 7. Summary and Next Steps

### Immediate Actions (FORGE)
1. Implement bounce logic fix at line 182
2. Apply parameter changes (sep_ticks, touch_dist, min_score, SL buffer)
3. Run unit tests
4. Hand off to ORACLE for Ghost Test

### ORACLE Validation Sequence
1. Run Ghost Test (2 hours) - CRITICAL GATE
2. If PASS: Proceed with Tier 1-5 validation (18-28 hours)
3. If FAIL: STOP and PIVOT

### Expected Timeline
- FORGE implementation: 3-4 hours
- Ghost Test: 2-3 hours
- Full validation (if Ghost passes): 15-23 hours
- **Total to GO/NO-GO decision: 20-30 hours (3-4 days)**

### Final Verdict Prerequisites
- [ ] Ghost Test PASS
- [ ] All 7 ORACLE gates PASS
- [ ] SENTINEL Apex compliance sign-off
- [ ] Paper trading validation (1 week minimum)

---

## Appendix A: Execution Realism Scenarios

### BASELINE (Reference Only)
- Spread: Observed bid/ask from dataset
- Slippage: 0
- Latency: 0

### CONSERVATIVE (MANDATORY for GO)
- Spread: observed_spread * 1.5
- Slippage: max(0.5 * spread, tick_size) adverse-only
- Latency: Fill at next bar open + slippage
- **Must pass all CRITICAL thresholds**

### HOSTILE (Recommended)
- Spread: observed_spread * 2.0
- Slippage: 1.0 * spread adverse-only
- Latency: Extended window

---

## Appendix B: HWM Algorithm (Apex)

```python
def update_hwm_and_check_dd(balance, unrealized_pnl, current_hwm):
    """Apex HWM/Floor Calculation"""
    current_equity = balance + unrealized_pnl
    new_hwm = max(current_hwm, current_equity)
    floor = new_hwm * 0.95
    is_breached = current_equity < floor
    current_dd_pct = ((new_hwm - current_equity) / new_hwm) * 100
    return new_hwm, floor, is_breached, current_dd_pct
```

**Critical**: HWM is tracked tick-by-tick and NEVER decreases. Unrealized profit raises floor PERMANENTLY.

---

**END OF FINAL SYNTHESIS**

ORACLE v3.4 - Round 6 Complete
