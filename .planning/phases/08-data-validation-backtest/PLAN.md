# PLAN.md - Data Validation & Backtesting Pipeline

**Plan ID**: 08-data-validation-backtest
**Created**: 2025-12-15
**Last Updated**: 2025-12-16
**Status**: READY FOR EXECUTION

---

## Quick Start

```bash
# Execute full plan
/run-plan .planning/phases/08-data-validation-backtest/PLAN.md

# Or execute phase by phase
/run-plan .planning/phases/08-data-validation-backtest/01-PHASE-PLAN.md
```

---

## Plan Overview

**Objective**: Comprehensive data validation and backtesting pipeline to ensure 100% data quality for XAUUSD scalping strategy before go-live.

**Data Assets**:
- Original CSVs: ~30 GB (source of truth)
- Main Parquet: 22 GB (654.6M ticks, stride-1 catalog, 2003-2025)
- 6 session catalogs (ASIAN, LONDON, OVERLAP, NY, LATE_NY, EVENING) - **ALREADY EXIST** (~9 GB total)

**Memory Constraint**: 12 GB RAM total - ALL processes must use streaming/chunking
**Max Chunk Size**: 5M ticks (~500 MB) per operation
**NautilusTrader**: Use native ParquetDataCatalog for ALL data operations

**Total Agents**: 35+ across all phases (batched into rounds of 2-3 for memory safety)
**Parallelism**: Batched rounds (recommended) or unlimited (if confirmed)
**Model**: Opus for all trading/validation agents

**CRITIC Review**: 3-WAY PARALLEL REVIEW COMPLETED (2025-12-16)
- CRITIC-1 (Data Validation): CONDITIONAL - 5 CRITICAL fixed
- CRITIC-2 (Backtest Framework): CONDITIONAL - 5 CRITICAL fixed
- CRITIC-3 (Orchestration): CONDITIONAL - 4 CRITICAL fixed
- **ALL 11 CRITICAL ISSUES FIXED**

---

## Phase Summary

| Phase | Name | Agents | Mode | Status |
|-------|------|--------|------|--------|
| 1 | Discovery & Config | 1 | Sequential | ⏳ Pending |
| **1-A** | **Deep Data Validation** | **4** | **2 Rounds (2+2)** | **⏳ Pending** |
| 2 | Main Catalog Validation | 8 | 2 Rounds (4+4) | ⏳ Pending |
| 3 | Session Validation | 6 | 2 Rounds (3+3) | ⏳ Pending |
| 4 | Integrity & Cleanup | 3 | Mixed (2 || 1) | ⏳ Pending |
| 5 | Advanced Validation | 4 | 1 Round (4) | ⏳ Pending |
| 6 | Backtest Framework | 3 | Sequential | ⏳ Pending |
| 7 | Backtest Execution | 4+ | 1 Round (4) | ⏳ Pending |
| 8 | GO/NO-GO Decision | 1 | Sequential | ⏳ Pending |

---

## Execution Instructions

### GLOBAL MEMORY CONSTRAINT (12 GB RAM)

**ALL phases must respect these limits**:
- Max chunk size: 5M ticks (~500 MB)
- Max concurrent memory: 6 GB (leave 6 GB for OS/system)
- Streaming required: NEVER load full catalog into memory
- NautilusTrader native: Use ParquetDataCatalog for ALL data operations
- Polars lazy: Use scan_parquet, not read_parquet

```python
# CORRECT: Streaming with Polars lazy
import polars as pl
df = pl.scan_parquet(path).filter(...).collect()

# WRONG: Loading everything into memory
df = pl.read_parquet(path)  # DON'T DO THIS
```

### Phase 1: Discovery & Config
```
Execute directly (no sub-agents needed).
Tasks:
1. Update config.yaml → stride1_COMPLETE
2. Create catalog inventory
3. Validate config resolution
```

### Phase 1-A: Deep Data Validation (NEW - CRITICAL)
```
Spawn in 2 rounds of 2 agents (memory safety):

Round 1 (2 agents, ~4 GB):
- 1-A.1 CSV-Parquet tick count comparison
- 1-A.2 Sample data validation (250K ticks)

Round 2 (2 agents, ~4 GB):
- 1-A.3 Session catalog integrity check
- 1-A.4 Schema and format consistency

All use model: opus
All output to: DOCS/03_RESEARCH/FINDINGS/PHASE1A_*.json
Memory limit: <6 GB peak per round
```

### Phase 2: Main Catalog Validation
```
Spawn in 2 rounds of 4 agents:

Round 1 (4 agents):
- 2.1 Health check
- 2.2 Schema validation
- 2.3 Temporal consistency
- 2.4 Price validation

Round 2 (4 agents):
- 2.5 Gap analysis
- 2.6 Regime analysis (ARGUS)
- 2.7 Session coverage
- 2.8 Quality scoring

All use model: opus
All output to: DOCS/03_RESEARCH/FINDINGS/PHASE2_*.json
```

### Phase 3: Session Validation
```
Spawn in 2 rounds of 3 agents:

Round 1 (3 sessions):
- 3.1 ASIAN
- 3.2 LONDON
- 3.3 OVERLAP

Round 2 (3 sessions):
- 3.4 NY
- 3.5 LATE_NY (Apex time gates!)
- 3.6 EVENING (Apex force-close!)

All use model: opus
All output to: DOCS/03_RESEARCH/FINDINGS/PHASE3_SESSION_*.json
```

### Phase 4: Integrity & Cleanup
```
Mixed execution (validation parallel, cleanup sequential):

Round 1 (parallel):
- 4.1 Cross-catalog consistency (ORACLE)
- 4.2 Metadata audit (ORACLE)

Round 2 (BLOCKED until Round 1 PASS):
- 4.3 Cleanup redundant data (FORGE)

All use model: opus
All output to: DOCS/03_RESEARCH/FINDINGS/PHASE4_*.json
```

### Phase 5: Advanced Validation
```
Spawn 4 agents in parallel:
- 5.1 Volatility clustering (ARGUS)
- 5.2 Look-ahead bias (SENTINEL)
- 5.3 Data lineage (FORGE)
- 5.4 Performance benchmarks (PERF_OPT)

All use model: opus
All output to: DOCS/03_RESEARCH/FINDINGS/PHASE5_*.json
```

### Phase 6: Backtest Framework
```
Execute sequentially (dependencies):
- 6.1 Event-driven engine (FORGE + NAUTILUS)
- 6.2 WFA setup (ORACLE)
- 6.3 Monte Carlo setup (ORACLE)

All use model: opus
```

### Phase 7: Backtest Execution
```
Spawn 4 agents in parallel:
- 7.1 Baseline backtest (ORACLE)
- 7.2 Walk-Forward Analysis (ORACLE)
- 7.3 Monte Carlo simulation (ORACLE)
- 7.4 Per-session backtests (SCALE-RUNNER)

All use model: opus
All output to: DOCS/03_RESEARCH/FINDINGS/PHASE7_*.json
```

### Phase 8: GO/NO-GO Decision
```
Execute as final consolidation:
- Load all Phase 2-7 results
- Apply GO/NO-GO thresholds
- Generate decision document

Output: DOCS/04_REPORTS/GO_NOGO_DECISION.md
```

---

## GO/NO-GO Thresholds

### Critical (Any fail = NO-GO)
- WFE ≥ 0.60
- MC 95th DD < 4% (CLAUDE.md compliant)
- Realized Max DD < 4% (with buffer for Apex 5%)
- Total Drawdown < 4.5% (Apex buffer)
- Trailing DD < 4% (including unrealized P/L)
- Look-ahead bias: NONE
- Apex time gates: 0 violations
- Critical gaps: 0

### High (>2 fail = NO-GO)
- OOS Windows Positive ≥ 70%
- PSR ≥ 0.90
- DSR > 0 (Deflated Sharpe Ratio)
- PBO < 25% (Probability of Backtest Overfitting)
- Risk of Ruin < 5%
- Profit Factor ≥ 1.3
- Quality Score ≥ 70

### Cleanup (Requires USER APPROVAL)
- Data cleanup (Phase 4.3) is DEFERRED to after Phase 7
- User must explicitly approve any data deletion

---

## Output Protocol

Per CLAUDE.md orchestration_output_protocol:

1. **Before spawning**: Create session folder
   - Location: `.planning/phases/08-data-validation-backtest/orchestration/`

2. **Each agent prompt includes**:
   ```
   OUTPUT PROTOCOL (MANDATORY):
   - Write COMPLETE analysis to: [session_folder]/[AGENT_NAME]_output.md
   - Return ONLY SUMMARY (max 300 words) to chat
   ```

3. **After agents complete**: Create MANIFEST.md

---

## File Structure

```
.planning/phases/08-data-validation-backtest/
├── PLAN.md                 # This file (execution entry point)
├── 00-BRIEF.md             # Project overview
├── 00-ROADMAP.md           # High-level phases
├── 01-PHASE-PLAN.md        # Discovery & Config
├── 01-A-PHASE-PLAN.md      # Deep Data Validation (NEW)
├── 02-PHASE-PLAN.md        # Main Catalog Validation
├── 03-PHASE-PLAN.md        # Session Validation
├── 04-PHASE-PLAN.md        # Integrity & Cleanup
├── 05-PHASE-PLAN.md        # Advanced Validation
├── 06-PHASE-PLAN.md        # Backtest Framework
├── 07-PHASE-PLAN.md        # Backtest Execution
├── 08-PHASE-PLAN.md        # GO/NO-GO Decision
└── orchestration/          # Sub-agent outputs (created during execution)
```

---

## Checkpoint Protocol

After each phase:
1. Collect all agent outputs
2. Generate phase summary
3. Store consolidated report
4. If context heavy → consider fresh conversation

---

## Related Documents

- [BACKTEST_MASTER_PLAN.md](../../DOCS/04_REPORTS/VALIDATION/BACKTEST_MASTER_PLAN.md)
- [DATA_QUALITY_REPORT.md](../../DOCS/04_REPORTS/VALIDATION/DATA_QUALITY_REPORT.md)
- [NAUTILUS_DATA_PIPELINE_HANDOFF](../../DOCS/03_RESEARCH/FINDINGS/NAUTILUS_DATA_PIPELINE_HANDOFF_20251216.md)

---

## CRITIC Review (PLAN.md)

**Reviewer**: CRITIC v1.1 - Adversarial Quality Guardian
**Date**: 2025-12-16
**Artifact**: PLAN.md (Data Validation & Backtesting Pipeline)
**Methodology**: 7 adversarial techniques, 18 sequential thoughts

---

### VERDICT: CONDITIONAL APPROVAL

**Conditions for FULL APPROVAL:**
1. CRITICAL: Resolve dataset mismatch (stride-1 vs stride-20)
2. CRITICAL: Add SQN ≥ 2.0 to GO/NO-GO
3. CRITICAL: Add 30% consistency rule validation

---

### CRITICAL ISSUES (Must fix before execution)

| # | Issue | Location | Impact | Recommended Fix |
|---|-------|----------|--------|-----------------|
| C1 | **DATASET MISMATCH** | Data Assets section (line 27-29) | PLAN validates stride-1 (654.6M ticks, 22GB) but CLAUDE.md mandates stride-20 (32.7M ticks) for ALL backtests. Validation becomes worthless. | Clarify: either update PLAN to validate stride-20 OR update CLAUDE.md to use stride-1 |
| C2 | **SQN MISSING FROM GO/NO-GO** | GO/NO-GO Thresholds section | CLAUDE.md requires SQN≥2.0 in approval_gate. Completely absent from GO/NO-GO. Incomplete validation. | Add to Critical: `SQN ≥ 2.0` |
| C3 | **30% CONSISTENCY RULE MISSING** | GO/NO-GO Thresholds section | Apex requires max 30% profit/day. Not validated anywhere. Could pass GO/NO-GO but violate Apex in production. | Add validation: `Max daily profit ≤ 30% (consistency rule)` |

---

### HIGH ISSUES (Should fix)

| # | Issue | Location | Impact | Recommended Fix |
|---|-------|----------|--------|-----------------|
| H1 | **PSR THRESHOLD MISMATCH** | GO/NO-GO High section | PLAN: PSR ≥ 0.90. CLAUDE.md: PSR ≥ 0.85. Inconsistency creates confusion. | Align to CLAUDE.md: `PSR ≥ 0.85` |
| H2 | **SAMPLE SIZE NOT IN GO/NO-GO** | GO/NO-GO section | CLAUDE.md requires ≥100 trades AND ≥2 years AND multiple regimes. Not verified. | Add to Critical: `Trades ≥ 100, Coverage ≥ 2 years` |
| H3 | **PHASE 6 NO OUTPUT LOCATION** | Phase 6 section | Where do backtest framework outputs go? Undefined. | Add: `Output to: DOCS/03_RESEARCH/FINDINGS/PHASE6_*.json` |
| H4 | **CLEANUP TIMING AMBIGUOUS** | Phase 4 & GO/NO-GO section | Says "DEFERRED to after Phase 7" but cleanup is Phase 4.3. Should be after Phase 8 GO decision. | Clarify: "Cleanup Phase 4.3 executes ONLY after Phase 8 GO decision AND user approval" |

---

### MEDIUM ISSUES (Recommended fixes)

| # | Issue | Recommendation |
|---|-------|----------------|
| M1 | Phase 1 no output location | Add: `Output to: DOCS/03_RESEARCH/FINDINGS/PHASE1_*.json` |
| M2 | Memory per-agent not budgeted | Add per-agent limits: "Each agent: <1.5GB peak" |
| M3 | Time gate validation criteria not specific | Add explicit checks: "Block after 16:30 ET, force-close 16:55 ET, all closed 16:59 ET" |
| M4 | No resume/checkpoint for partial failure | Add: "If round fails, resume from failed round after fix" |
| M5 | Phase dependencies implicit | Add dependency diagram or explicit "Requires: Phase X complete" |

---

### LOW ISSUES (Nice to have)

| # | Issue | Recommendation |
|---|-------|----------------|
| L1 | Related documents may not exist | Verify existence before execution |
| L2 | Orchestration folder creation timing | Specify: "Create before Phase 1-A spawn" |
| L3 | NautilusTrader version not pinned | Add version requirement in Phase 6 |

---

### ASSUMPTIONS CHALLENGED

| Assumption | Challenge | Risk | Recommendation |
|------------|-----------|------|----------------|
| Session catalogs "ALREADY EXIST" | Are they from stride-1 or stride-20? Current? | Validation on stale/wrong catalogs | Verify provenance before Phase 3 |
| ParquetDataCatalog supports chunking | Does NautilusTrader actually chunk at 5M ticks? | OOM if loads all data | Test chunk loading first |
| 654.6M ticks stride-1 is correct | CLAUDE.md says stride-20 (32.7M) for backtests | Fundamental mismatch | Resolve before execution |
| 4 agents × any load fits 6GB | No per-agent budget | OOM if agents exceed ~1.5GB each | Add explicit limits |
| NautilusTrader WFA exists | Is WFA implemented? | Phase 6.2/7.2 blocks | Verify code exists |
| /run-plan command works | Format compatibility? | Command may not understand plan | Test with dry-run |

---

### EDGE CASES TESTED

| Scenario | Result |
|----------|--------|
| Empty session catalog | No handling specified - undefined behavior |
| Single trade in WFA fold | Metrics become meaningless - no check |
| All trades losers | Would fail MC95, but reporting unclear |
| 4:59:59 PM ET edge | Timezone/leap second handling unspecified |
| Weekend gap (48+ hours) | Gap analysis exists but usage unclear |
| Partial phase failure | No resume mechanism documented |

---

### STRESS TEST RESULTS

| Condition | Outcome |
|-----------|---------|
| Phase 2 Round 1 (4 agents × 2GB each) | Exceeds 6GB budget → OOM likely |
| Phase 7 (4 parallel backtests) | Disk I/O contention on WSL2 → slowdown |
| Phase 1-A CSV comparison (30GB) | Must stream - any full load → crash |
| ARGUS external search timeout | No fallback specified |

---

### MANUAL VERIFICATION NEEDED

- [ ] Confirm which dataset (stride-1 or stride-20) to use throughout pipeline
- [ ] Verify /run-plan command compatibility with this plan structure
- [ ] Check all referenced phase files (01-A, 02, 03, etc.) exist
- [ ] Verify session catalogs' provenance (built from which source?)
- [ ] Confirm NautilusTrader ParquetDataCatalog supports chunking as assumed
- [ ] Verify WFA implementation exists in codebase

---

### PRE-MORTEM SUMMARY

**Most likely failure mode**: Dataset mismatch - validating stride-1 catalog but backtesting on stride-20 per CLAUDE.md. All validation work becomes irrelevant.

**Second most likely**: Apex compliance gap - passing GO/NO-GO but violating 30% consistency rule in production because never validated.

**Third most likely**: Incomplete metrics - passing on WFE/PSR but failing on SQN (not measured), leading to false confidence.

**Mitigation**:
1. Before execution: Clarify which dataset throughout pipeline
2. Add SQN and consistency rule to validation
3. Add explicit sample size checks

---

### CONFIDENCE: MEDIUM

**Rationale**:
- Plan structure is solid (9 phases, clear rounds)
- Prior CRITIC review fixed 11 issues
- BUT new CRITICAL issues found related to CLAUDE.md alignment
- Cannot give HIGH confidence until dataset question resolved

---

### SEVERITY COUNTS

| Severity | Count |
|----------|-------|
| CRITICAL | 3 |
| HIGH | 4 |
| MEDIUM | 5 |
| LOW | 3 |
| **TOTAL** | **15** |

---

**STATUS**: CONDITIONAL APPROVAL - Fix CRITICAL issues C1, C2, C3 before execution.
