# PLAN: Phase 04 - Signal Generators Audit

## Objective
Critical analysis of signal generation modules to verify scoring logic correctness, MTF confluence implementation, and news filter accuracy.

## Files Under Review

| File | Lines | Responsibility |
|------|-------|----------------|
| `confluence_scorer.py` | 1002 | Score aggregation |
| `entry_optimizer.py` | 699 | Entry optimization |
| `mtf_manager.py` | 395 | MTF signal management |
| `news_calendar.py` | 628 | News event handling |
| `news_trader.py` | 688 | News-based signals |

**Total:** ~3,412 lines

## Execution Plan

### Parallel Agent Assignment

**Agent A (CRUCIBLE):** Scoring and Confluence
- `confluence_scorer.py` (1002 lines - largest!)
- `mtf_manager.py` (395 lines)
- ~1,397 lines

**Agent B (CRUCIBLE):** Entry and News
- `entry_optimizer.py` (699 lines)
- `news_calendar.py` (628 lines)
- `news_trader.py` (688 lines)
- ~2,015 lines

## CRITICAL ANALYSIS AREAS

### confluence_scorer.py (LARGEST MODULE)

**Scoring Logic Verification:**
1. Score thresholds match CLAUDE.md?
   - TIER_S: ≥90
   - TIER_A: ≥80
   - TIER_B: ≥70
   - TIER_C: ≥60
   - TIER_INVALID: <60

2. Component weights documented?
3. Score inflation/deflation patterns?
4. Edge cases:
   - All components missing?
   - Conflicting signals?
   - Regime mismatch?

**Questions to Answer:**
- What's the execution_threshold? (Should be 70 = TIER_B_MIN)
- How are partial confluences handled?
- Is there score capping?
- Look-ahead in any component?

### mtf_manager.py

**MTF Logic Verification:**
1. HTF (H1) → Direction filter
2. MTF (M15) → Structure zones
3. LTF (M5) → Execution

**Questions to Answer:**
- Is HTF bar confirmed before MTF uses it?
- Temporal alignment correct?
- What if MTF contradicts HTF?
- Bar completion detection?

### entry_optimizer.py

**Entry Optimization Verification:**
1. Fibonacci level integration?
2. OB/FVG zone refinement?
3. Entry price calculation?

**Questions to Answer:**
- How is optimal entry determined?
- Risk/reward calculation correct?
- Look-ahead in optimization?
- Edge: zone fully mitigated?

### news_calendar.py

**News Filter Verification:**
1. Data source?
2. Event parsing?
3. Time buffer before/after?

**Questions to Answer:**
- Look-ahead in news data? (CRITICAL)
- How far ahead are events known?
- Impact classification (high/medium/low)?
- Timezone handling?

### news_trader.py

**News Signal Verification:**
1. Trade around news logic?
2. Size reduction near news?
3. Entry/exit timing?

**Questions to Answer:**
- Is this active or just filtering?
- Integration with main strategy?
- Look-ahead concerns?

## CRITIC Checklist

### Scoring (confluence_scorer.py)
| Check | Status |
|-------|--------|
| Thresholds match CLAUDE.md | ⬜ |
| No look-ahead in scoring | ⬜ |
| Edge cases handled | ⬜ |
| Score normalization correct | ⬜ |
| Component weight transparency | ⬜ |
| Unit tests exist | ⬜ |

### MTF (mtf_manager.py)
| Check | Status |
|-------|--------|
| Temporal alignment verified | ⬜ |
| HTF confirmed before use | ⬜ |
| Conflict resolution documented | ⬜ |
| Performance acceptable | ⬜ |

### Entry (entry_optimizer.py)
| Check | Status |
|-------|--------|
| Fibonacci calculation correct | ⬜ |
| Zone validation logic | ⬜ |
| R:R calculation accurate | ⬜ |
| No look-ahead | ⬜ |

### News (news_calendar.py + news_trader.py)
| Check | Status |
|-------|--------|
| No look-ahead in news data | ⬜ |
| Data source reliable? | ⬜ |
| Timezone handling correct | ⬜ |
| Impact classification accurate | ⬜ |
| Buffer times configurable | ⬜ |

## Specific Questions

1. **Score threshold 70**: Does this match `TIER_B_MIN` from definitions?
2. **MTF confluence requirement**: 50.0 - how is this calculated?
3. **News score penalty**: -15 - is this applied correctly?
4. **News size multiplier**: 0.5 - how does this integrate with position_sizer?

## Success Criteria
- [ ] All 5 signal modules reviewed
- [ ] Scoring logic verified against CLAUDE.md
- [ ] No look-ahead bias found
- [ ] MTF confluence logic validated
- [ ] News filter temporal integrity confirmed
- [ ] `PHASE_04_FINDINGS.md` completed

## Agents

**2 parallel CRUCIBLE agents (model: opus)**
- Each handles 2-3 modules
- Must apply CRITIC self-review internally
- Focus on scoring correctness

## Output
`PHASE_04_FINDINGS.md` in this directory
