# CRITIC ADVERSARIAL REVIEW - Data Validation Phases 2-5

**Artifact**: Phase Plans 02-05 for Data Validation Backtest
**Type**: Plan/Strategy
**Reviewer**: CRITIC v1.1
**Date**: 2025-12-15
**Thinking Depth**: 15 sequential thoughts

---

## VERDICT: CONDITIONAL APPROVAL

The plans are comprehensive and well-structured but contain several issues that must be addressed before execution. The most critical issues relate to memory/performance feasibility with 654M ticks, missing prerequisites, and premature data cleanup.

---

## CRITICAL ISSUES (Must Fix)

### C1: Gap Analysis Memory Bomb

**Location**: Phase 2.5 (02-PHASE-PLAN.md, lines 175-206)

**Description**: Phase 2.5 Gap Analysis requires "Calculate time delta between consecutive ticks" across 654M ticks. This requires a full sequential scan with no streaming strategy specified.

**Impact**:
- 654M ticks x ~50 bytes = 32.7 GB raw data
- Loading full DataFrame would crash most systems
- Even with Arrow, no chunk size specified
- Agent could hang indefinitely or OOM-kill

**Fix**:
```markdown
METHODOLOGY:
1. Use Arrow streaming with 1M tick chunks
2. Process chunks sequentially, maintaining only last timestamp of previous chunk
3. Memory cap: 4GB per agent
4. Progress reporting every 10M ticks
5. Timeout: 30 minutes maximum
```

---

### C2: Session Catalogs Assumed to Exist

**Location**: Phase 3 (03-PHASE-PLAN.md, line 68)

**Description**: Phase 3 tasks reference `data/catalog_native_sessions/xauusd_2003_2025_stride1_{SESSION}/` but no creation step exists in the plan.

**Impact**: All 6 Phase 3 agents will fail immediately if session catalogs don't exist.

**Fix**:
Add prerequisite check OR add Phase 2.5b to create session catalogs:
```markdown
## Prerequisites
- Phase 2 completed with PASS status
- Session catalogs exist at data/catalog_native_sessions/
- OR: Add Task 2.9 to slice main catalog into sessions before Phase 3
```

---

### C3: Cleanup Before Full Backtest Validation

**Location**: Phase 4.3 (04-PHASE-PLAN.md, lines 170-238)

**Description**: Cleanup deletes ~14GB of original source data (session_csvs/) after Phase 2-4 validation passes, but BEFORE backtest (Phase 6) validates the data actually works.

**Impact**:
- If converted Parquet data has subtle bugs only visible in backtest, originals are gone
- Cannot re-convert from source
- Irreversible data loss

**Fix**:
```markdown
PRE-CONDITIONS (all must be true):
- Phase 2 quality score >= 70
- Phase 3 all sessions PASS
- Phase 4.1 cross-catalog PASS
- **Phase 6 backtest completes successfully** ← ADD THIS
- OR: Keep originals for minimum 30 days after backtest
```

---

### C4: DST 2007 Rule Change Not Handled

**Location**: Phase 3 (03-PHASE-PLAN.md, lines 249-256)

**Description**: US DST rules changed in 2007 (Energy Policy Act of 2005):
- Before 2007: 1st Sunday April → last Sunday October
- After 2007: 2nd Sunday March → 1st Sunday November

The plans assume post-2007 rules for all 22 years.

**Impact**:
- 2003-2006 data (4 years) has wrong time gate calculations
- Apex time gates could be off by 1 hour for early data
- Could cause validation failures or worse, incorrect live trading

**Fix**:
Add DST transition table:
```markdown
## DST Transition Table (Required)
| Year | Spring Forward | Fall Back | Rule |
|------|----------------|-----------|------|
| 2003 | Apr 6 | Oct 26 | Pre-2007 |
| 2004 | Apr 4 | Oct 31 | Pre-2007 |
| 2005 | Apr 3 | Oct 30 | Pre-2007 |
| 2006 | Apr 2 | Oct 29 | Pre-2007 |
| 2007 | Mar 11 | Nov 4 | Post-2007 |
| ... | ... | ... | ... |
```

---

### C5: Tick Reconciliation Tolerance Too Large

**Location**: Phase 4.1 (04-PHASE-PLAN.md, line 60)

**Description**: "Sum of all session ticks should equal main catalog ticks (±0.1%)"

0.1% of 654,586,033 = 654,586 ticks - over half a million missing ticks would pass!

**Impact**: Could mask serious data loss at session boundaries or conversion errors.

**Fix**:
```markdown
# Tighter tolerance
- Sum difference should be 0 (exact match)
- If non-zero: Investigate every missing tick
- Only allow tolerance for documented boundary edge cases (< 100 ticks)
```

---

## HIGH ISSUES (Should Fix)

### H1: Session Boundary Ambiguity

**Location**: Phase 2.7 (02-PHASE-PLAN.md) and Phase 3 (03-PHASE-PLAN.md)

**Description**: Session windows defined as ASIAN 00:00-07:00, LONDON 07:00-12:00, etc. but no specification of inclusive/exclusive boundaries.

**Question**: Is a tick at exactly 07:00:00.000000 UTC in ASIAN or LONDON?

**Impact**: Ticks at boundaries could be:
- Lost (neither session includes them)
- Duplicated (both sessions include them)
- Inconsistent (different agents interpret differently)

**Fix**:
```markdown
SESSION WINDOWS (UTC) - All boundaries are [start, end):
- ASIAN: [00:00, 07:00)  ← includes 00:00, excludes 07:00
- LONDON: [07:00, 12:00)
- etc.
```

---

### H2: Sampling Strategy Misses Middle Corruption

**Location**: Phase 2.3, 2.4 (02-PHASE-PLAN.md)

**Description**: Plans use "head+tail sampling" and "Sample 1M ticks from start, middle, end" but middle is vague.

**Impact**: 654M ticks with 100K sample = 0.015% coverage. A year-long corrupt period (e.g., 2015) could be completely missed.

**Fix**:
```markdown
SAMPLING STRATEGY (Stratified):
1. Divide data into 22 annual segments
2. Sample 50K ticks from each year
3. Within year, sample from each month
4. Total: ~1.1M ticks with guaranteed coverage of all periods
```

---

### H3: Static Price Range Validation

**Location**: Phase 2.4 (02-PHASE-PLAN.md, line 157)

**Description**: "Price range reasonable ($300-$3500 for XAUUSD 2003-2025)"

**Problem**: This range is too wide to catch era-specific errors:
- A tick at $2500 in 2003 is clearly wrong (actual price ~$350)
- A tick at $400 in 2024 is clearly wrong (actual price ~$2000-2700)

**Fix**:
```markdown
DYNAMIC PRICE BOUNDS:
| Period | Min | Max |
|--------|-----|-----|
| 2003-2007 | $300 | $850 |
| 2008-2012 | $700 | $2000 |
| 2013-2018 | $1000 | $1400 |
| 2019-2021 | $1200 | $2100 |
| 2022-2025 | $1600 | $3000 |
```

---

### H4: Expected Tick Count Source Unverified

**Location**: All phases reference 654,586,033 ticks

**Description**: This number appears hardcoded throughout plans but origin is not specified.

**Questions**:
- Is this from source CSV line count?
- From conversion script output?
- From previous validation run?
- Was it independently verified?

**Fix**:
Add verification step in Phase 2.1:
```markdown
TICK COUNT VERIFICATION:
1. Count rows in source CSV (if available)
2. Compare to expected 654,586,033
3. Document source of expected count
4. Any mismatch is CRITICAL failure
```

---

### H5: No NautilusTrader Compatibility Test

**Location**: Phase 2.2 (02-PHASE-PLAN.md)

**Description**: Schema validation checks Parquet structure but not NautilusTrader API compatibility.

**Impact**: Data could be valid Parquet but fail when NT BacktestNode tries to load it.

**Fix**:
Add to Phase 2.1:
```python
# NT Compatibility Test
from nautilus_trader.persistence.catalog import ParquetDataCatalog
catalog = ParquetDataCatalog(catalog_path)
ticks = catalog.quote_ticks(["XAU/USD.SIM"])[:1000]
assert len(ticks) == 1000
```

---

### H6: No Timeout/Memory Budgets

**Location**: All phases

**Description**: No explicit timeout or memory limits specified for agents.

**Impact**: Agents processing 654M ticks could hang indefinitely or crash.

**Fix**:
Add to each task specification:
```markdown
RESOURCE LIMITS:
- Timeout: 30 minutes
- Memory: 4GB max
- Disk I/O: Log if >5 minutes on single file
- Progress: Report every 10M ticks or 5 minutes
```

---

## MEDIUM ISSUES

### M1: "Approximate ET" Table Inaccurate

**Location**: Phase 3 session definitions

**Description**: ASIAN shows "7PM-2AM ET" but this assumes EST (UTC-5). In EDT (summer), it's 8PM-3AM ET.

**Fix**: Either remove "Approx ET" column or add "(varies with DST)" note.

---

### M2: No Stuck Quote Detection

**Description**: Data could have frozen quotes (same bid/ask for hours) indicating stale feed, but no validation checks for this.

**Fix**: Add check: "No identical consecutive ticks for > 1 minute during trading hours"

---

### M3: No Weekend Tick Flagging

**Description**: Gap analysis filters weekend gaps but doesn't FLAG ticks that occur during weekend.

**Fix**: Add: "Weekend ticks (Sat 00:00 - Sun 22:00 UTC) should be 0. Any found = ERROR"

---

### M4: Quality Score Formula Arbitrary

**Description**: Weights (25/25/15/15/10/10) and thresholds are arbitrary with no validation.

**Fix**: Either document rationale or calibrate against known-good datasets.

---

### M5: No Write Performance Benchmark

**Location**: Phase 5.4

**Description**: Only tests read performance. If data needs regeneration, write performance matters.

**Fix**: Add write benchmark: "Time to write 1M ticks to new catalog"

---

### M6: Source Data Path External

**Location**: Phase 5.3 (05-PHASE-PLAN.md, line 200)

**Description**: `Python_Agent_Hub/ml_pipeline/data/CSV_2003-2025XAUUSD_ftmo_all-TICK-NoSession.csv` suggests source is outside this repo.

**Fix**: Verify path exists and is accessible, or update to correct location.

---

## LOW ISSUES

### L1: Leap Second Consideration Missing

2005, 2008, 2012, 2015, 2016, 2017 had leap seconds. Could cause timestamp ordering edge cases.

### L2: No Explicit Failure Handling Between Phases

What happens if 7 of 8 Phase 2 agents pass but 1 fails? Proceed? Abort? Retry?

### L3: Consolidation Code is Pseudocode

Phase 2 consolidation (lines 321-336) is untested Python pseudocode.

### L4: Holiday List Not Provided

Plans mention "known market closures" but don't list them.

---

## ASSUMPTIONS CHALLENGED

| Assumption | Challenge | Recommendation |
|------------|-----------|----------------|
| Tick count is 654,586,033 | Source unverified | Add verification step |
| Session catalogs exist | No creation step | Add prerequisite check |
| Sampling is representative | Head/tail misses middle | Use stratified sampling |
| UTC is canonical timezone | Source might be different TZ | Verify source TZ |
| Parquet files are valid | Could be partially corrupt | Add Arrow checksum validation |
| Sessions sum to 100% | Boundary handling unclear | Specify [start, end) convention |
| validate_data_v2.py exists | Referenced but not confirmed | Verify script exists |

---

## EDGE CASES TESTED

| Scenario | Covered? | Status |
|----------|----------|--------|
| Crossed quotes (bid > ask) | Yes | GOOD |
| NaN/Inf values | Yes | GOOD |
| Zero/negative prices | Yes | GOOD |
| Stuck quotes | No | ADD |
| Weekend ticks | Filtered only | SHOULD FLAG |
| Boundary ticks (e.g., 07:00 UTC) | Undefined | MUST DEFINE |
| DST transition days | Mentioned | NEEDS TABLE |
| Leap seconds | No | LOW RISK |
| Empty parquet files | No | ADD |
| Extreme spreads at session open | Aggregate only | CONSIDER |

---

## STRESS TEST RESULTS

| Condition | Expected Outcome | Risk |
|-----------|------------------|------|
| 8 parallel agents, 4GB each | 32GB needed | HIGH if system < 64GB |
| Gap analysis full scan | 11+ min minimum | OK with streaming |
| Concurrent disk reads | I/O contention | MEDIUM |
| Agent timeout (30min) | Partial results | MUST HANDLE |
| Memory spike during load | OOM possible | MUST CAP |

---

## MANUAL VERIFICATION NEEDED

- [ ] Verify session catalogs exist at `data/catalog_native_sessions/`
- [ ] Confirm source of 654,586,033 tick count
- [ ] Verify `scripts/oracle/validate_data_v2.py` exists and works
- [ ] Confirm source CSV path and accessibility
- [ ] Test NautilusTrader can load catalog before running agents
- [ ] Generate DST transition table 2003-2025 (with 2007 rule change)
- [ ] Decide on session boundary convention ([start, end) vs [start, end])
- [ ] Set explicit timeout and memory limits for agents

---

## CONFIDENCE: MEDIUM

**Reason**: The plans show good intent and comprehensive coverage, but several operational details are missing that could cause cascading failures. The most critical issue is the lack of streaming strategy for 654M tick processing. With the fixes above, confidence would rise to HIGH.

---

## PRE-MORTEM SUMMARY

**Most likely failure mode**: Memory exhaustion during gap analysis (Phase 2.5) causes agent crash, no results captured, phase marked as failed, blocking all subsequent phases.

**Second most likely**: Session catalogs don't exist, all 6 Phase 3 agents fail immediately, wasting compute resources.

**Third most likely**: Cleanup (Phase 4.3) deletes source data, later backtest reveals subtle conversion bugs, cannot recover.

**Mitigation**:
1. Add streaming requirement for full-scan tasks
2. Add prerequisite validation before each phase
3. Defer cleanup until after successful backtest

---

## RECOMMENDATIONS SUMMARY

| Priority | Recommendation |
|----------|----------------|
| CRITICAL | Add streaming/chunking for 654M tick processing |
| CRITICAL | Verify session catalogs exist OR add creation step |
| CRITICAL | Defer cleanup to post-backtest (Phase 6+) |
| CRITICAL | Add DST transition table with 2007 rule change |
| CRITICAL | Tighten tick count tolerance from ±0.1% to exact |
| HIGH | Define session boundary convention explicitly |
| HIGH | Add stratified sampling across all years |
| HIGH | Add dynamic price bounds by era |
| HIGH | Verify expected tick count source |
| HIGH | Add NT compatibility test |
| HIGH | Set timeout/memory budgets for all agents |

---

## APPROVAL STATUS

**CONDITIONAL APPROVAL** - May proceed with implementation IF:
1. CRITICAL issues are addressed in plan updates
2. HIGH issues are tracked for implementation
3. Manual verification checklist is completed

**BLOCKED IF**:
- No streaming strategy added for gap analysis
- Session catalogs don't exist and no creation step added
- Cleanup remains before backtest validation

---

*CRITIC v1.1 - Adversarial Quality Guardian*
*"Every bug found now is a loss prevented later."*
