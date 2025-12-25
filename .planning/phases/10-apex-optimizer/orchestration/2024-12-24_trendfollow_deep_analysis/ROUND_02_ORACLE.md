# ROUND 02: ORACLE Cross-Agent Synthesis - TrendFollow Strategy

## ORACLE Output
```
AGENT: ORACLE
VERSION: 3.4
CLAUDE_MD_VERSION: 3.10.23
STATUS: COMPLETE
ROUND: 2 of 6
```

---

## 1. Executive Summary

This Round 2 analysis synthesizes findings from all three Round 1 agents (ORACLE, CRUCIBLE, SENTINEL) to identify common themes, contradictions, and prioritize improvement proposals with specific disproof tests.

**Key Findings:**
1. **CONSENSUS**: All agents agree Hurst gate (H >= 0.55) is critical and recently implemented - MUST validate first
2. **CONSENSUS**: Entry confirmation is weak (ORACLE: candle quality, CRUCIBLE: sweep confirmation)
3. **TENSION**: ORACLE favors threshold tweaks vs CRUCIBLE favors SMC methodology - RESOLVED: threshold FIRST, SMC if needed
4. **VERIFIED**: SENTINEL confirms Apex compliance mechanisms (time gates, DD throttle, position sizing) are sound
5. **GAP**: All proposals are code-based, lacking actual data analysis from losing months

---

## 2. Cross-Agent Synthesis

### 2.1 Common Themes (All Agents Agree)

| Theme | ORACLE | CRUCIBLE | SENTINEL | Strength |
|-------|--------|----------|----------|----------|
| Hurst gate is critical | Positive addition | Essential for Apex | Would have prevented -4% DD | STRONG |
| Entry confirmation weak | No candle quality | No sweep confirmation | N/A | STRONG |
| Signal quality filtering inadequate | sep_ticks too low | Missing SMC patterns | N/A | STRONG |
| Apex compliance OK | N/A | N/A | Time gates, DD throttle verified | STRONG |
| SL concerns | Buffer adequate | 0.25*ATR may fail Asia/news | Bypasses clamping | MEDIUM |

### 2.2 Conflicts/Contradictions

| Conflict | ORACLE Position | CRUCIBLE Position | Resolution |
|----------|-----------------|-------------------|------------|
| **Improvement approach** | Threshold tweaks (sep_ticks=40, min_score=75) | SMC methodology (OB/FVG/structure) | Threshold FIRST (lower effort, testable quickly) |
| **Breakout fix** | Candle quality filter (body >= 50% range) | Confirmation delay (prior bar broke + current holds) | Both are COMPLEMENTARY - implement both |
| **SL adequacy** | Adequate | Marginal during Asia/news | SENTINEL says position sizing compensates - MEDIUM priority |
| **Priority #1** | sep_ticks increase | Breakout confirmation delay | Validation FIRST, then sep_ticks, then confirmation |
| **Scope of changes** | Minimal parameter changes | Significant SMC additions | Sequential elimination - start minimal |

### 2.3 Resolution Strategy

**DECISION: THRESHOLD FIRST, SMC IF NEEDED**

Reasoning:
1. ORACLE's threshold proposals: LOW effort, HIGH expected impact
2. CRUCIBLE's SMC proposals: MEDIUM-HIGH effort, UNCERTAIN impact
3. SMC concepts are popular but not validated for THIS strategy
4. Threshold changes testable in days vs SMC additions in weeks

Implementation path:
```
IF threshold changes produce WFE > 0.60, PSR > 0.85:
    STOP - improvements sufficient
ELSE:
    EVALUATE CRUCIBLE's SMC proposals
    RUN ghost test to verify SMC adds genuine edge
```

---

## 3. Top 5 Proposals Ranked by Expected Impact

### Rank 1: HURST GATE VALIDATION (All Agents)

| Attribute | Value |
|-----------|-------|
| **Current** | Hurst >= 0.55 gate implemented (lines 137-138) |
| **Action** | VALIDATE that it would have prevented Mar/Jun 2024 losses |
| **Expected Impact** | IF validates: eliminates -4% DD scenario entirely |
| **Effort** | LOW (run backtest with existing code) |
| **Owner** | ORACLE |

**Quantification:**
- Target: MC95DD reduction from >4% to <3%
- Signal count reduction: Estimate 30-50% in choppy months
- Win rate improvement: Estimate +10-20% (no choppy market signals)

### Rank 2: INCREASE sep_ticks THRESHOLD (ORACLE)

| Attribute | Value |
|-----------|-------|
| **Current** | sep_ticks >= 4.0 ($0.04 = 0.002% = noise) |
| **Proposed** | sep_ticks >= 40 ($0.40 = 0.02% = meaningful) |
| **Expected Impact** | -60-80% signal count, +15-25% win rate |
| **Effort** | LOW (parameter change) |
| **Owner** | FORGE |

**Quantification:**
- Signal reduction: 60-80% (conservative estimate)
- WR improvement: +15-25 percentage points
- Rationale: 4 ticks is mathematically noise for $2000+ gold

### Rank 3: BREAKOUT CONFIRMATION DELAY (CRUCIBLE)

| Attribute | Value |
|-----------|-------|
| **Current** | Enter ON close above N-bar high |
| **Proposed** | Enter after prior bar broke AND current holds above |
| **Expected Impact** | -40% false breakout entries |
| **Effort** | LOW (3-4 lines of code) |
| **Owner** | FORGE |

**Code Change:**
```python
# Instead of:
if is_up and last_close > prev_high + tick_size:

# Use:
prior_broke = closes[-2] > prev_high + tick_size
current_holds = last_close > prev_high
if is_up and prior_broke and current_holds:
```

### Rank 4: RAISE min_score THRESHOLD (ORACLE)

| Attribute | Value |
|-----------|-------|
| **Current** | min_score = 60.0 (equals base score - no quality gate) |
| **Proposed** | min_score = 75.0 (requires quality contribution) |
| **Expected Impact** | -40-60% marginal signals |
| **Effort** | LOW (parameter change) |
| **Owner** | FORGE |

**Quantification:**
- At min_score=75, signals need sep_ticks >= 10 AND ATR contribution
- This works synergistically with sep_ticks increase

### Rank 5: TIGHTEN touch_dist (ORACLE)

| Attribute | Value |
|-----------|-------|
| **Current** | touch_dist = 0.35 * ATR (~$1.75 with $5 ATR) |
| **Proposed** | touch_dist = 0.15 * ATR (~$0.75) or fixed 30 ticks |
| **Expected Impact** | -50% pullback signals, +10-20% pullback WR |
| **Effort** | LOW (parameter change) |
| **Owner** | FORGE |

**Rationale:** Require actual EMA touch, not "near EMA"

---

## 4. Disproof Tests for Each Proposal

### 4.1 Hurst Gate Validation

**Claim:** Hurst >= 0.55 filter would have prevented Mar/Jun 2024 losses.

**Disproof Test:**
1. Run backtest Mar 2024 + Jun 2024 WITH Hurst gate active
2. Measure: signal count, win rate, max DD
3. **Falsified IF:** DD still exceeds 3% OR win rate doesn't improve
4. **Data needed:** Hurst values during Mar/Jun 2024 signal periods

**Expected Time:** 1-2 hours

### 4.2 sep_ticks Threshold Increase

**Claim:** sep_ticks=40 will reduce noise signals and improve WR.

**Disproof Test A (Historical Analysis):**
1. Stratify historical signals by sep_ticks buckets (4-10, 10-20, 20-40, 40+)
2. Compare win rate per bucket
3. **Falsified IF:** win rate is flat or decreasing with higher sep_ticks

**Disproof Test B (Backtest):**
1. Run backtest Mar+Jun 2024 with sep_ticks=40
2. Compare signal count and P&L to baseline
3. **Falsified IF:** still losing despite fewer signals

**Expected Time:** 1-2 hours each

### 4.3 Breakout Confirmation Delay

**Claim:** Waiting for confirmation reduces false breakout entries by 40%.

**Disproof Test:**
1. Tag historical breakout signals: immediate entry vs would-have-confirmation
2. Compare outcomes for each group
3. **Falsified IF:** confirmation signals have same or worse WR

**Alternative Ghost Test:**
- Random delay vs smart delay - if same outcome, delay is noise

**Expected Time:** 2-3 hours (requires backtest instrumentation)

### 4.4 Raise min_score to 75

**Claim:** Score >= 75 signals have better outcomes than 60-75.

**Disproof Test:**
1. Stratify historical signals by score bucket (60-70, 70-80, 80+)
2. Compare win rate and expectancy per bucket
3. **Falsified IF:** no correlation between score and outcome

**Expected Time:** 1 hour

### 4.5 Tighten touch_dist

**Claim:** Tighter touch requirement (0.15*ATR) improves pullback WR.

**Disproof Test:**
1. Stratify pullback signals by touch_dist (as % of ATR)
2. Compare outcomes for touch <= 0.15*ATR vs > 0.15*ATR
3. **Falsified IF:** no difference or inverse relationship

**Expected Time:** 1 hour

---

## 5. Backtest Configuration Recommendations

### BACKTEST 1: DIAGNOSTIC (Priority: HIGHEST - Run FIRST)

**Purpose:** Understand WHAT happened in losing months (data-driven)

| Parameter | Value |
|-----------|-------|
| **Period** | Mar 2024 + Jun 2024 |
| **Changes** | None (baseline) |
| **Instrumentation** | Capture per-signal: Hurst, sep_ticks, variant, score, TOD, outcome, SL distance |
| **Output** | CSV with per-signal diagnostics |

**Metrics to capture per signal:**
- Hurst value at signal generation
- sep_ticks value
- Variant (Pullback/Breakout)
- Score
- Time of day (hour)
- Outcome (win/loss)
- P&L
- SL distance used

### BACKTEST 2: HURST GATE VALIDATION

**Purpose:** Verify Hurst gate prevents losses

| Parameter | Value |
|-----------|-------|
| **Period** | Mar 2024 + Jun 2024 |
| **Changes** | Hurst gate active (min_hurst=0.55) |
| **Baseline** | Same period without Hurst gate |
| **Pass Criteria** | DD < 3%, signal count reduction > 50% |

### BACKTEST 3: sep_ticks SENSITIVITY

**Purpose:** Find optimal sep_ticks threshold

| Parameter | Value |
|-----------|-------|
| **Period** | Full dataset (2003-2025) with WFA |
| **Parameter sweep** | sep_ticks = [10, 20, 30, 40, 50, 60] |
| **Output** | Parameter response curve |
| **Metrics** | WFE, Sharpe, Win Rate, Signal Count, MC95DD |

### BACKTEST 4: COMBINED THRESHOLD IMPROVEMENT

**Purpose:** Test ORACLE's top proposals together

| Parameter | Value |
|-----------|-------|
| **Period** | Full dataset with WFA |
| **Changes** | sep_ticks=40, min_score=75, touch_dist=0.15*ATR |
| **Pass Criteria** | WFE > 0.60, PSR > 0.85, DSR > 0, MC95DD < 4% |

### BACKTEST 5: BREAKOUT CONFIRMATION

**Purpose:** Test CRUCIBLE's confirmation delay

| Parameter | Value |
|-----------|-------|
| **Period** | Full dataset with WFA |
| **Changes** | Breakout confirmation delay |
| **Compare to** | Baseline breakouts only |
| **Metrics** | Breakout WR, false breakout reduction, P&L |

### Execution Order:
```
1. BACKTEST 1 (understand problem) - 2 hours
2. BACKTEST 2 (validate existing gate) - 1 hour
3. BACKTEST 3 (optimize threshold) - 3 hours
4. BACKTEST 4 (combined improvement) - 2 hours
5. BACKTEST 5 (if breakout still problematic) - 2 hours
```

---

## 6. Gaps in Round 1 Analysis

| Gap | Description | Impact | Round 3 Action |
|-----|-------------|--------|----------------|
| **No actual data** | All proposals are code-based, not data-validated | Proposals may target wrong problems | Run BACKTEST 1 (diagnostic) |
| **Variant-level analysis missing** | Don't know if Pullback or Breakout is the bigger loser | May fix wrong variant | Capture variant in diagnostics |
| **Hurst distribution unknown** | Don't know if H was >0.55 or <0.55 during losses | Determines if gate helps | Capture Hurst in diagnostics |
| **Time-of-day unknown** | Don't know if losses cluster at specific hours | May need session filter | Capture TOD in diagnostics |
| **Interaction effects** | Don't know if combined filters over-filter | May reduce signals too much | Test filters incrementally |
| **HWM verification** | SENTINEL flagged bid/ask for unrealized needs check | Apex compliance risk | FORGE to verify |

---

## 7. Questions for Round 3

### Data Questions (need diagnostic backtest):

**Q1:** What were the actual Hurst values during Mar/Jun 2024 losing signals?
- IF H > 0.55 frequently: Hurst gate alone won't fix it
- IF H < 0.55 frequently: Hurst gate is the silver bullet

**Q2:** Which variant (Pullback vs Breakout) was responsible for most losses?
- Determines focus of improvements

**Q3:** What was the actual distribution of sep_ticks in historical signals?
- Determines if threshold change has impact

**Q4:** Do higher-scored signals actually perform better?
- Validates scoring formula relevance

### Architecture Questions (for CRUCIBLE):

**Q5:** Should we create trend_follow_v2.py or modify existing?
- Affects testability and rollback capability

### Risk Questions (for SENTINEL):

**Q6:** Is HWM calculation using bid/ask for unrealized correctly?
- Must verify before GO decision

**Q7:** What's the minimum acceptable signal count per month?
- Risk of over-filtering

### Interaction Questions (for All):

**Q8:** What happens when Hurst + sep_ticks + min_score all filter together?
- Need factorial test or incremental tests

---

## 8. Pre-Mortem: What Could Go Wrong

| Failure Mode | Risk | Mitigation |
|--------------|------|------------|
| **Over-filtering** | Combined filters reduce signals to <10/month | Test filters incrementally, track signal count |
| **Wrong root cause** | -4% DD wasn't signal quality (maybe position sizing, data quality) | Run DIAGNOSTIC backtest first |
| **SMC is overfitting** | OB/FVG adds complexity without edge | Ghost test if pursuing SMC |
| **Hurst masks problems** | Gate works but hides fundamental weakness | Test with AND without gate |
| **Backtest != Live** | Slippage, spread widening in live | Use CONSERVATIVE execution model (1.5x spread) |
| **Oracle gates too strict** | DSR > 0, PBO < 25% near-impossible | Phase validation with paper trading |

---

## 9. Confidence Level Update

### Round 1 vs Round 2 Confidence:

| Component | R1 | R2 | Change | Notes |
|-----------|----|----|--------|-------|
| Problem identification | 8/10 | 9/10 | +1 | Cross-validated by 3 agents |
| Hurst gate as key fix | 7/10 | 7/10 | 0 | Still untested |
| sep_ticks too low | 9/10 | 9/10 | 0 | Math is unambiguous |
| Scoring formula issue | 8/10 | 8/10 | 0 | - |
| Optimal threshold values | 5/10 | 5/10 | 0 | Need backtests |
| SMC improvements value | N/A | 6/10 | NEW | Uncertain until tested |
| Apex compliance | 7/10 | 8/10 | +1 | SENTINEL verified |
| Implementation priority | 6/10 | 8/10 | +2 | Clear order now |

### Overall Confidence: 7.5/10 (up from 7/10)

**Improvements from Round 2:**
- Cross-validated problem identification
- Clear priority ordering (validation -> threshold -> confirmation)
- Well-defined disproof tests for each proposal
- Better understanding of gaps

**Remaining Uncertainty:**
- Actual data patterns in losing months
- Which proposals will have real impact
- Interaction effects between filters

---

## 10. Round 3 Handoff Recommendations

### For ORACLE R3:
- Execute BACKTEST 1 (diagnostic) to get actual data
- Analyze Hurst, sep_ticks, score distributions
- Provide data-backed answers to Q1-Q4
- Update threshold recommendations based on findings

### For CRUCIBLE R3:
- Answer architecture question (v2 vs modifications)
- Provide code specification for breakout confirmation
- Assess which SMC additions still add value if thresholds work

### For SENTINEL R3:
- Verify HWM calculation with bid/ask for unrealized
- Model lot sizes under reduced signal count
- Define minimum acceptable signal count

### Cross-Cutting R3:
- Define interaction test plan
- Establish paper trading success criteria

---

## 11. Summary Table

| Proposal | Expected Impact | Effort | Disproof Test | Priority |
|----------|-----------------|--------|---------------|----------|
| Hurst Gate Validation | Eliminate -4% DD | LOW | Backtest Mar/Jun with gate | 1 |
| sep_ticks 4->40 | -60-80% noise signals | LOW | Stratify by sep_ticks, compare WR | 2 |
| Breakout Confirmation | -40% false breakouts | LOW | Compare confirmed vs immediate | 3 |
| min_score 60->75 | -40-60% marginal signals | LOW | Stratify by score, compare WR | 4 |
| touch_dist 0.35->0.15 | -50% pullback signals | LOW | Stratify by touch_dist, compare WR | 5 |
| SMC Additions (OB/FVG) | +10-15% WR (uncertain) | HIGH | Ghost test vs random | DEFER |

---

*ORACLE v3.4 - Round 2 Complete | 2024-12-24*
*Next: Execute BACKTEST 1 (diagnostic) to move from speculation to data*
