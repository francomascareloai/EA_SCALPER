# PLAN: Phase 02 - SMC Indicators Audit

## Objective
Critical analysis of all Smart Money Concepts (SMC) indicators to verify correctness, temporal integrity, and performance.

## Files Under Review

| File | Lines | Responsibility |
|------|-------|----------------|
| `amd_cycle_tracker.py` | ~250 | AMD cycle detection |
| `footprint_analyzer.py` | ~450 | Order flow analysis |
| `fvg_detector.py` | ~562 | Fair Value Gap detection |
| `liquidity_sweep.py` | ~611 | Liquidity hunt detection |
| `mtf_manager.py` | ~670 | Multi-timeframe management |
| `order_block_detector.py` | ~617 | Order Block detection |
| `regime_detector.py` | ~377 | Market regime classification |
| `session_filter.py` | ~233 | Trading session filtering |
| `structure_analyzer.py` | ~621 | Market structure analysis |

**Total:** ~4,391 lines

## Execution Plan

### Parallel Agent Assignment

**Agent A:** `amd_cycle_tracker.py` + `regime_detector.py` + `session_filter.py`
- Market context indicators
- ~860 lines total

**Agent B:** `order_block_detector.py` + `fvg_detector.py`
- SMC zone detection
- ~1,179 lines total

**Agent C:** `liquidity_sweep.py` + `structure_analyzer.py`
- Liquidity and structure analysis
- ~1,232 lines total

**Agent D:** `footprint_analyzer.py` + `mtf_manager.py`
- Order flow and MTF
- ~1,120 lines total

## CRITIC Focus Areas (All Agents)

### 1. SMC Logic Correctness
- Order Block definition matches ICT concepts?
- FVG detection rules accurate?
- Liquidity sweep identification correct?
- AMD cycle (Accumulation → Manipulation → Distribution) logic?

### 2. Temporal Integrity (CRITICAL)
- **NO LOOK-AHEAD**: Does indicator use only completed bars?
- Bar indexing: `bars[-1]` is current, `bars[-2]` is previous?
- MTF alignment: HTF bar completed before LTF uses it?

### 3. Edge Cases
- Thin market handling (low tick count)
- News spike behavior
- Gap handling (overnight, weekend)
- Session boundaries

### 4. Performance
- Vectorized operations vs loops?
- Caching of expensive calculations?
- Memory usage for bar storage?

### 5. State Management
- Indicator state reset between sessions?
- Historical data requirements clear?
- Warmup period defined?

## CRITIC Checklist per Indicator

| Check | Notes |
|-------|-------|
| Uses only completed bars | ⬜ |
| Bar indexing documented | ⬜ |
| Edge cases handled | ⬜ |
| Performance acceptable | ⬜ |
| State reset mechanism | ⬜ |
| Dependencies clear | ⬜ |
| Unit tests exist | ⬜ |

## Specific Questions to Answer

### Order Block Detector
1. How is "imbalance" measured?
2. What defines OB validity?
3. How long does OB stay valid?
4. Mitigation detection correct?

### FVG Detector
1. Gap threshold configuration?
2. Partial fill handling?
3. Expiration mechanism?

### Liquidity Sweep
1. Equal highs/lows tolerance?
2. Sweep confirmation logic?
3. False sweep filtering?

### Regime Detector
1. Regime classification accuracy?
2. Transition smoothing?
3. Volatile regime handling?

### Structure Analyzer
1. BOS/CHoCH detection rules?
2. Swing point identification?
3. Structure break confirmation?

### AMD Cycle Tracker
1. Cycle phase detection accuracy?
2. Transition timing?
3. Integration with trading signals?

### Footprint Analyzer
1. Delta calculation correctness?
2. Imbalance thresholds?
3. Data requirements?

### MTF Manager
1. Timeframe synchronization?
2. Bar completion detection?
3. Data consistency across TFs?

### Session Filter
1. Timezone handling (ET vs UTC)?
2. DST transitions?
3. Holiday detection?

## Success Criteria
- [ ] All 9 indicators reviewed
- [ ] No look-ahead bias found OR documented with fix plan
- [ ] Edge cases catalogued
- [ ] Performance bottlenecks identified
- [ ] `PHASE_02_FINDINGS.md` completed

## Agents

**4 parallel FORGE agents (model: opus)**
- Each handles 2-3 indicators
- Must apply CRITIC self-review internally
- Must document all assumptions challenged

## Output
`PHASE_02_FINDINGS.md` in this directory
