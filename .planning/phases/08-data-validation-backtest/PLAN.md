# PLAN.md - Data Validation & Backtesting Pipeline

**Plan ID**: 08-data-validation-backtest
**Created**: 2025-12-15
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
- 654.6M ticks (stride-1 catalog, 2003-2025)
- 6 session catalogs (ASIAN, LONDON, OVERLAP, NY, LATE_NY, EVENING)

**Total Agents**: 30+ across all phases
**Parallelism**: Unlimited (user confirmed capacity)
**Model**: Opus for all trading/validation agents

---

## Phase Summary

| Phase | Name | Agents | Mode | Status |
|-------|------|--------|------|--------|
| 1 | Discovery & Config | 1 | Sequential | ⏳ Pending |
| 2 | Main Catalog Validation | 8 | Parallel | ⏳ Pending |
| 3 | Session Validation | 6 | Parallel | ⏳ Pending |
| 4 | Integrity & Cleanup | 3 | Parallel | ⏳ Pending |
| 5 | Advanced Validation | 4 | Parallel | ⏳ Pending |
| 6 | Backtest Framework | 3 | Sequential | ⏳ Pending |
| 7 | Backtest Execution | 4+ | Parallel | ⏳ Pending |
| 8 | GO/NO-GO Decision | 1 | Sequential | ⏳ Pending |

---

## Execution Instructions

### Phase 1: Discovery & Config
```
Execute directly (no sub-agents needed).
Tasks:
1. Update config.yaml → stride1_COMPLETE
2. Create catalog inventory
3. Validate config resolution
```

### Phase 2: Main Catalog Validation
```
Spawn 8 ORACLE agents in parallel:
- 2.1 Health check
- 2.2 Schema validation
- 2.3 Temporal consistency
- 2.4 Price validation
- 2.5 Gap analysis
- 2.6 Regime analysis (ARGUS)
- 2.7 Session coverage
- 2.8 Quality scoring

All use model: opus
All output to: DOCS/03_RESEARCH/FINDINGS/PHASE2_*.json
```

### Phase 3: Session Validation
```
Spawn 6 ORACLE agents in parallel (one per session):
- 3.1 ASIAN
- 3.2 LONDON
- 3.3 OVERLAP
- 3.4 NY
- 3.5 LATE_NY
- 3.6 EVENING

All use model: opus
All output to: DOCS/03_RESEARCH/FINDINGS/PHASE3_SESSION_*.json
```

### Phase 4: Integrity & Cleanup
```
Spawn 3 agents in parallel:
- 4.1 Cross-catalog consistency (ORACLE)
- 4.2 Metadata audit (ORACLE)
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
- MC 95th DD < 8%
- Realized Max DD < 8%
- Look-ahead bias: NONE
- Apex time gates: 0 violations
- Critical gaps: 0

### High (>2 fail = NO-GO)
- OOS Windows Positive ≥ 70%
- PSR ≥ 0.90
- Risk of Ruin < 5%
- Profit Factor ≥ 1.3
- Quality Score ≥ 70

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
