# CRITIC Adversarial Review: ROADMAP v1 vs v2

## Metadata

| Field | Value |
|-------|-------|
| Reviewer | CRITIC v1.2 |
| Mode | EXTERNAL-CRITIC |
| Date | 2025-12-23 |
| v1 File | `.planning/phases/09-strategy-activation/01-ROADMAP.md` |
| v2 File | `.planning/phases/09-strategy-activation/01-ROADMAP-v2.md` |
| CLAUDE_MD_VERSION | 3.10.21 |

---

## Executive Summary

**VERDICT: v2 is the CORRECT direction but requires surgical fixes before it can stand alone.**

| Aspect | v1 | v2 | Assessment |
|--------|----|----|------------|
| Blocking issues addressed | 40% | 88-92% | v2 WINS |
| Context/debugging detail | Rich | Thin | v1 WINS |
| Standalone executability | Partial | Needs v1 | TIE (both need work) |
| Phase structure | 7 phases | 9 phases (with gaps) | v2 conceptually better, numbering problematic |
| Timeline realism | 6-8 weeks | 10-12 weeks | v2 WINS |

**Bottom Line:** Use v2 as PRIMARY with 5-7 surgical edits. Archive v1 as reference material.

---

## 1. What Was LOST in Consolidation

### 1.1 Empirical Observations (MEDIUM Severity)

**v1 contained (lines 17-59):**
```
structure=15.0, regime=0.0, ob=0.0, fvg=0.0, sweep=0.0, amd=0.0, fib=0.0, mtf=0.0, footprint=0.0
```
- Session-specific score ranges: Asian 16-22, London 30-40, Overlap 44-52, NY 35-48
- Commit reference: 58b84178 (Score=0.0 bug fix)
- Root cause hypothesis for semantic collision

**v2 retains:** Brief mention that "8 of 9 factors dead" but no debugging context.

**Impact:** Developer loses debugging context. Someone working on Phase 00 semantic collision fix would benefit from knowing exact score ranges per session.

### 1.2 Detailed Agent Reviews (HIGH Severity)

**v1 contained ~1,200 lines of inline agent reviews:**

| Agent | Lines | Key Lost Content |
|-------|-------|------------------|
| ORACLE | 186 | 6 blocking issues with DSR/PBO formulas, WFA window recommendations |
| FORGE | 143 | Corrected file paths table (Planned vs Actual), time estimate reality check |
| SENTINEL | 248 | 5-level circuit breaker specification, 8-row failure mode analysis table |
| CRUCIBLE | 290 | "15,000-line system produces 7 trades" analysis, complexity trap table |
| ARGUS (x2) | 400 | 13 academic citations, architecture decision matrix by trade frequency |

**v2 retains:** 12-line summary table (lines 617-629) with one sentence per agent.

**Impact:** Actionable implementation detail is lost. v2 states "All detailed findings remain in 01-ROADMAP.md for reference" - creating dependency on v1.

### 1.3 Corrected File Paths Table (HIGH Severity)

**v1 FORGE review (lines 896-908) contained:**

| Planned Path | Actual Path | Exists |
|--------------|-------------|--------|
| `src/indicators/mtf_manager.py` | `nautilus_gold_scalper/src/indicators/mtf_manager.py` | YES |
| `src/signals/mtf_manager.py` | `nautilus_gold_scalper/src/signals/mtf_manager.py` | YES |
| `tests/test_signals/test_mtf_manager.py` | Does not exist | MISSING |

**v2 retains:** "Fixed all file paths per FORGE" without showing the corrections.

**Impact:** Anyone executing Phase 00 must consult v1 to know correct paths.

### 1.4 Academic Sources (MEDIUM Severity)

**v1 ARGUS review contained 13 academic citations:**
- Stanford Thompson Sampling Tutorial
- Oxford Advanced Financial Learning Lecture 15
- JMLR PAC Bounds for Multi-Armed Bandits
- PMC Hurst Exponent Regime Detection
- arXiv Machine Learning for Trading Strategy Selection
- And 8 more practitioner sources

**v2 retains:** Zero citations.

**Impact:** Claims like "Thompson sampling cannot converge with 7 trades" lose their evidence basis.

---

## 2. Contradictions Between v1 and v2

### 2.1 Phase Structure (CRITICAL)

| v1 Phase | v2 Phase | Contradiction |
|----------|----------|---------------|
| Phase 00 (2 weeks) | Phase 00 (3 weeks) | Duration increased 50% |
| Phase 01 exists | Phase 01 merged into 02 | Phase eliminated |
| Phase 04 (Mean Revert) | Phase 04 REMOVED | Strategy direction changed |
| Phase 05: "Enable Router" | Phase 05: "Archive Router" | **180-DEGREE REVERSAL** |
| Phase 06: Multi-Strategy | Phase 06: Enhanced Validation | Purpose changed |
| Phases 07-08 don't exist | Phases 07-08 mandatory | New requirements |

**Critical Issue:** Phase 05 completely reversed direction:
- v1 (line 500): "Enable Router by Default" - `router_adaptive_ev=True`
- v2 (line 329): "Verify AdaptiveEVRouter archived"

### 2.2 Timeline

| Metric | v1 | v2 | Gap |
|--------|----|----|-----|
| Phase 00 duration | 2 weeks | 3 weeks | +50% |
| Total to production | 6-8 weeks | 10-12 weeks | +50% |
| Agent invocations | 18 | 15 | -17% |

### 2.3 Success Metrics

**v1 GO/NO-GO Criteria:**
- WFE >= 0.6
- SQN >= 2.0
- PSR >= 0.85
- MC95DD < 4%
- Min Trades >= 200
- Multi-strategy benefit >= 0%

**v2 ADDS (all required):**
- DSR >= 0.80 (Deflated Sharpe Ratio)
- PBO < 25% (Probability Backtest Overfitting)
- MC5DD < 3% (tail risk)
- Holdout validation: Positive
- Paper trading duration >= 10 days
- SENTINEL sign-off: Obtained

**Impact:** Work done under v1 criteria would be INSUFFICIENT for v2 GO/NO-GO.

### 2.4 Agent Allocation

| Phase | v1 Agents | v2 Agents | Change |
|-------|-----------|-----------|--------|
| Phase 00 | 8 (FORGE x3, ORACLE, CRUCIBLE, SENTINEL, DOCUMENTER, +1) | 6 (FORGE x4, ORACLE, SENTINEL) | -25% |
| Phase 05 | FORGE + SENTINEL | FORGE only | SENTINEL removed |
| Phase 06 | 2 ORACLE + DAEMON | 2 ORACLE + CRITIC | DAEMON -> CRITIC |

**Impact:** DAEMON (strategic advisor) removed entirely. Is this intentional?

---

## 3. Is v2 Actually Better?

### 3.1 Blocking Issues Resolution

**ORACLE (6 issues):** 6/6 FIXED in v2
1. No DSR calculation -> Added DSR >= 0.80
2. No holdout period -> Reserve 2020-2025
3. MC methodology unspecified -> 5000 runs, block bootstrap
4. PBO threshold missing -> PBO < 25%
5. 7 trades invalid -> Phase -1 baseline, min 200 trades
6. Paper trading after GO -> Phase 07 BEFORE GO

**FORGE (4 issues):** 2-3/4 FIXED in v2
1. File paths incorrect -> Claims fixed but paths not shown (UNCLEAR)
2. _archive/ missing -> SETUP-001 creates it (FIXED)
3. Footprint test dependencies -> Not addressed (MISSING)
4. Duplicate tasks -> Merged Phase 01 (FIXED)

**SENTINEL (4 issues):** 4/4 FIXED in v2
1. No paper trading -> Phase 07 added
2. No broker SL verification -> PT-006 added
3. HWM calculation -> Tests include BID/ASK
4. Circuit breaker untested -> PR-001 tests all 5 levels

**CRUCIBLE (4 issues):** 4/4 FIXED in v2
1. No baseline comparison -> Phase -1 added
2. Ablation before diagnostic -> SEM-007 adds logging
3. 7 trades as evidence -> 200+ required
4. No exit criteria -> Decision gates added

**ARGUS (8 recommendations):** 7/8 ADDRESSED in v2
1. Remove AdaptiveEVRouter -> SIMP-005 archives it
2. Simplify to single strategy -> Approach maintained
3. Fix trade frequency -> Threshold 35->25
4. Preserve Hurst -> Regime filter kept
5. Add baseline comparison -> Phase -1
6. Reduce to 2-3 factors -> 3-4 factors (partial)
7. Defer Mean Revert -> Phase 04 removed
8. Simplify StrategySelector -> Regime filter only

**TOTAL SCORE:** 23-24 out of 26 blocking/key issues = **88-92% resolution rate**

### 3.2 What v2 Did BETTER

1. **Mandatory operational phases:** Phase 07 (Paper Trading) and Phase 08 (Production Readiness)
2. **Statistical rigor:** DSR, PBO, CPCV, holdout validation
3. **Realistic timeline:** 10-12 weeks vs optimistic 6-8 weeks
4. **Architectural simplification:** Removed over-engineered router
5. **Strategic focus:** Removed Mean Revert (gold trends, doesn't mean-revert)

### 3.3 What v2 Did WORSE

1. **Lost debugging context:** No empirical observations section
2. **Creates dependency:** Must reference v1 for full details
3. **Inconsistent detail:** Phase 02-03 thin, Phase 07-08 detailed
4. **Confusing numbering:** Gaps at Phase 01 and Phase 04

---

## 4. Frankenstein Analysis

### 4.1 Where Are The Stitches?

**Phase Numbering Gaps:**
- Execution order: -1, 00, 02, 03, 05, 06, 07, 08
- Missing: 01, 04
- A clean v2 would renumber: 0, 1, 2, 3, 4, 5, 6, 7

**Inconsistent Detail Levels:**

| Phase | Lines | Priority | Detail Quality |
|-------|-------|----------|----------------|
| Phase -1 | 27 | P0 - BLOCKER | Adequate |
| Phase 00 | 118 | P0 - BLOCKER | **Excellent** |
| Phase 02 | 28 | P0 - CRITICAL | **Thin** |
| Phase 03 | 28 | P0 - CRITICAL | **Thin** |
| Phase 05 | 44 | P1 - HIGH | Moderate |
| Phase 06 | 48 | P0 - CRITICAL | Good |
| Phase 07 | 45 | P0 - MANDATORY | Good |
| Phase 08 | 46 | P0 - MANDATORY | Good |

Phase 02 (SMC Audit) and Phase 03 (TrendFollow) are CRITICAL but have less detail than later phases.

### 4.2 Duplicate Information

"Mean Revert removed" stated 4 times:
1. Line 19: Changelog
2. Line 38-39: Executive Summary table
3. Line 95: Phase Overview footnote
4. Line 639: Summary table

### 4.3 Orphaned References

- Line 620: "All detailed findings remain in 01-ROADMAP.md for reference"
- This creates permanent dependency on v1, defeating consolidation purpose

### 4.4 Terminology Inconsistencies

- "Pre-Activation Sprint" (Phase 00) vs "Baseline Validation" (Phase -1)
- Phase -1 is actually the first phase but numbered negatively
- Confusing: Is Phase 02 the second or fourth phase in execution?

### 4.5 Architecture Diagram Mismatch

Lines 336-348 show 4-step signal flow:
```
Session Filter -> Regime Filter -> Strategy Selection -> Confluence Check -> Risk -> Trade
```

But SIMP-006 (line 180) says "Simplify StrategySelector to regime filter only" - reducing to 1-2 steps.

The architecture diagram was not updated to match simplified reality.

---

## 5. CRITIC Recommendation

### 5.1 Primary Recommendation: Use v2 with Surgical Fixes

**MANDATORY FIXES (Blocking):**

| # | Issue | Action |
|---|-------|--------|
| 1 | Corrected file paths not shown | ADD FORGE's file path table from v1 |
| 2 | Empirical observations missing | ADD session score ranges section from v1 |
| 3 | Phase numbering gaps | RENUMBER to sequential: 0-7 |
| 4 | Footprint test dependencies | ADD explicit handling per FORGE |
| 5 | Architecture diagram outdated | UPDATE to match SIMP-006 simplification |

**RECOMMENDED FIXES (High Priority):**

| # | Issue | Action |
|---|-------|--------|
| 6 | Agent reviews orphaned in v1 | CREATE `01-ROADMAP-REVIEWS.md` with full reviews |
| 7 | Phase 02-03 too thin | EXPAND GO/NO-GO criteria detail |
| 8 | Profit Factor missing | ADD PF >= 1.5 to Phase 06 criteria |
| 9 | Duplicate Mean Revert mentions | CONSOLIDATE to single mention |
| 10 | Task ID inconsistency | STANDARDIZE prefixes (BL-, MTF-, SEM-, etc.) |

### 5.2 Document Disposition

| Document | Action |
|----------|--------|
| 01-ROADMAP.md (v1) | ARCHIVE as `01-ROADMAP-v1-ARCHIVED.md` - keep for reference |
| 01-ROADMAP-v2.md | Apply fixes, rename to `01-ROADMAP.md` as PRIMARY |
| NEW: 01-ROADMAP-REVIEWS.md | Extract full agent reviews for reference |

### 5.3 Why NOT Other Options

**Keep v1 with fixes?** NO - Would need 8-10 significant edits including adding 3 phases. More work than fixing v2.

**Merge into v3?** NO - Diminishing returns. v2 is 92% there, merging would be significant effort for marginal gain.

**Start fresh?** NO - Would discard weeks of analysis. Not justified.

---

## 6. Issues Summary

### 6.1 Critical Issues (Must Fix)

| # | Description | Location | Impact |
|---|-------------|----------|--------|
| 1 | Corrected file paths not shown | Missing from v2 | Execution will fail |
| 2 | Footprint test dependencies unhandled | Missing from v2 | Test failures on archive |
| 3 | Phase numbering gaps confusing | Phase structure | Reader confusion |
| 4 | Architecture diagram outdated | Lines 336-348 | Misrepresents current design |
| 5 | Orphaned reference to v1 | Line 620 | Cannot standalone |

### 6.2 High Issues

| # | Description | Location | Impact |
|---|-------------|----------|--------|
| 6 | Empirical observations lost | Missing from v2 | Lost debugging context |
| 7 | Academic citations removed | ARGUS section | Claims lose evidence basis |
| 8 | Phase 02-03 thin on detail | Lines 252-311 | Critical phases under-specified |
| 9 | DAEMON removed from allocation | Agent table | Strategic advisory lost |

### 6.3 Medium Issues

| # | Description | Location | Impact |
|---|-------------|----------|--------|
| 10 | Duplicate information (4x Mean Revert) | Multiple | Noise |
| 11 | Task ID inconsistency | Phase tasks | Minor confusion |
| 12 | Profit Factor not in criteria | Phase 06 | Missing validation |

---

## 7. Manual Verification Needed

- [ ] Verify v2 Phase 00 task list matches v1 03-PRE_ACTIVATION_CHECKLIST.md
- [ ] Confirm corrected file paths are accurate for current codebase
- [ ] Verify Phase 05 simplified architecture is technically feasible
- [ ] Confirm DAEMON removal is intentional (strategic advisory gap?)
- [ ] Check if footprint test files still exist and need handling

---

## 8. Confidence Assessment

**Confidence: HIGH**

**Rationale:**
- 15-step sequential thinking analysis completed
- Both documents read in full (v1 1500+ lines, v2 657 lines)
- Quantitative resolution rate calculated (88-92%)
- All 7 agent reviews analyzed for coverage
- Contradictions identified with specific line references
- Recommendation is actionable with clear fix list

---

## 9. Pre-Mortem Summary

**Most Likely Failure Mode:** Team uses v2 but hits Phase 00 Day 1-2 without knowing correct file paths, causing grep/read operations to fail. Time lost discovering paths that were already documented in v1.

**Second Most Likely:** Phase 02-03 under-specification leads to incomplete SMC/TrendFollow audits, requiring rework after Phase 06 validation fails.

**Mitigation:** Apply the 5 mandatory fixes BEFORE starting Phase -1.

---

*CRITIC v1.2 - "If I can't find problems, I haven't looked hard enough."*

**Review Status:** COMPLETE - v2 CONDITIONAL APPROVAL pending surgical fixes
