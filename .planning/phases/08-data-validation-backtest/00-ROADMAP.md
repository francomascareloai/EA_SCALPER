# ROADMAP: Data Validation & Backtesting Pipeline

**Project**: EA_SCALPER_XAUUSD - Apex Trading
**Phase ID**: 08-data-validation-backtest
**Version**: 1.0
**Last Updated**: 2025-12-15

---

## Phase Overview

```
┌─────────────────────────────────────────────────────────────────────────────────┐
│                           DATA VALIDATION & BACKTEST                            │
├─────────────────────────────────────────────────────────────────────────────────┤
│                                                                                 │
│  ┌──────────────┐                                                               │
│  │   PHASE 1    │  Discovery & Config                                          │
│  │  (1 prompt)  │  - Fix config.yaml                                           │
│  └──────┬───────┘  - Catalog inventory                                         │
│         │                                                                       │
│         ▼                                                                       │
│  ┌──────────────────────────────────────────────────────────────────────────┐   │
│  │                           PHASE 2 (8 agents parallel)                     │   │
│  │  Main Catalog Validation (654.6M ticks)                                   │   │
│  │  ┌────┐ ┌────┐ ┌────┐ ┌────┐ ┌────┐ ┌────┐ ┌────┐ ┌────┐                 │   │
│  │  │2.1 │ │2.2 │ │2.3 │ │2.4 │ │2.5 │ │2.6 │ │2.7 │ │2.8 │                 │   │
│  │  │Hlth│ │Schm│ │Temp│ │Pric│ │Gaps│ │Regm│ │Sess│ │Scor│                 │   │
│  │  └────┘ └────┘ └────┘ └────┘ └────┘ └────┘ └────┘ └────┘                 │   │
│  └──────────────────────────────────────────────────────────────────────────┘   │
│         │                                                                       │
│         ▼                                                                       │
│  ┌──────────────────────────────────────────────────────────────────────────┐   │
│  │                           PHASE 3 (6 agents parallel)                     │   │
│  │  Session Catalog Validation                                               │   │
│  │  ┌──────┐ ┌──────┐ ┌──────┐ ┌──────┐ ┌──────┐ ┌──────┐                   │   │
│  │  │ASIAN │ │LONDON│ │OVERL │ │  NY  │ │LATENY│ │EVENG │                   │   │
│  │  └──────┘ └──────┘ └──────┘ └──────┘ └──────┘ └──────┘                   │   │
│  └──────────────────────────────────────────────────────────────────────────┘   │
│         │                                                                       │
│         ▼                                                                       │
│  ┌──────────────────────────────────────────────────────────────────────────┐   │
│  │                           PHASE 4 (3 agents parallel)                     │   │
│  │  Integrity & Cleanup                                                      │   │
│  │  ┌─────────────┐ ┌─────────────┐ ┌─────────────┐                         │   │
│  │  │Cross-Catalog│ │  Metadata   │ │   Cleanup   │                         │   │
│  │  │ Consistency │ │Completeness │ │  Redundant  │                         │   │
│  │  └─────────────┘ └─────────────┘ └─────────────┘                         │   │
│  └──────────────────────────────────────────────────────────────────────────┘   │
│         │                                                                       │
│         ▼                                                                       │
│  ┌──────────────────────────────────────────────────────────────────────────┐   │
│  │                           PHASE 5 (4 agents parallel)                     │   │
│  │  Advanced Validation                                                      │   │
│  │  ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────────┐                     │   │
│  │  │Volatility│ │Look-Ahead│ │  Data    │ │   Perf   │                     │   │
│  │  │Clustering│ │  Bias    │ │ Lineage  │ │Benchmark │                     │   │
│  │  └──────────┘ └──────────┘ └──────────┘ └──────────┘                     │   │
│  └──────────────────────────────────────────────────────────────────────────┘   │
│         │                                                                       │
│         ▼                                                                       │
│  ┌──────────────┐                                                               │
│  │   PHASE 6    │  Backtest Framework (Sequential - dependencies)              │
│  │ (3 prompts)  │  - Event-driven engine                                       │
│  └──────┬───────┘  - WFA setup                                                 │
│         │          - Monte Carlo infrastructure                                │
│         ▼                                                                       │
│  ┌──────────────────────────────────────────────────────────────────────────┐   │
│  │                           PHASE 7 (4+ agents parallel)                    │   │
│  │  Backtest Execution                                                       │   │
│  │  ┌─────────┐ ┌─────────┐ ┌─────────┐ ┌─────────┐                         │   │
│  │  │Baseline │ │   WFA   │ │  Monte  │ │ Session │                         │   │
│  │  │2020-2024│ │12 window│ │  Carlo  │ │ Tests   │                         │   │
│  │  └─────────┘ └─────────┘ └─────────┘ └─────────┘                         │   │
│  └──────────────────────────────────────────────────────────────────────────┘   │
│         │                                                                       │
│         ▼                                                                       │
│  ┌──────────────┐                                                               │
│  │   PHASE 8    │  GO/NO-GO Decision                                           │
│  │ (1 prompt)   │  - Consolidate results                                       │
│  └──────────────┘  - Apply thresholds                                          │
│                    - Final recommendation                                       │
│                                                                                 │
└─────────────────────────────────────────────────────────────────────────────────┘
```

---

## Phase Sequence

| # | Phase | Agents | Parallelism | Depends On | Deliverable |
|---|-------|--------|-------------|------------|-------------|
| 1 | Discovery & Config | 1 | Sequential | - | Updated config.yaml |
| 2 | Main Catalog Validation | 8 | Full Parallel | 1 | MAIN_CATALOG_REPORT.md |
| 3 | Session Validation | 6 | Full Parallel | 2 | SESSION_VALIDATION_REPORT.md |
| 4 | Integrity & Cleanup | 3 | Full Parallel | 2, 3 | CLEANUP_REPORT.md |
| 5 | Advanced Validation | 4 | Full Parallel | 2 | ADVANCED_VALIDATION_REPORT.md |
| 6 | Backtest Framework | 3 | Sequential | 1-5 | Implemented scripts |
| 7 | Backtest Execution | 4+ | Full Parallel | 6 | BACKTEST_RESULTS.md |
| 8 | GO/NO-GO Decision | 1 | Sequential | 7 | GO_NOGO_DECISION.md |

---

## Detailed Phase Descriptions

### Phase 1: Discovery & Config
**Objective**: Establish single source of truth, fix configuration

| Task | Description | Agent |
|------|-------------|-------|
| 1.1 | Update config.yaml → stride1_COMPLETE | Orchestrator |
| 1.2 | Catalog inventory (sizes, dates, status) | Orchestrator |
| 1.3 | Validate config → catalog path resolution | Orchestrator |

---

### Phase 2: Main Catalog Validation
**Objective**: Full validation of 654.6M tick catalog

| Task | Description | Agent Spec | Output |
|------|-------------|------------|--------|
| 2.1 | Quick health check | ORACLE | health_status.json |
| 2.2 | Schema validation | ORACLE | schema_report.json |
| 2.3 | Temporal consistency | ORACLE | temporal_report.json |
| 2.4 | Price validation (bid/ask/spread) | ORACLE | price_report.json |
| 2.5 | Gap analysis | ORACLE | gaps_report.json |
| 2.6 | Regime analysis (Hurst) | ARGUS | regime_report.json |
| 2.7 | Session coverage | ORACLE | session_coverage.json |
| 2.8 | Quality scoring (0-100) | ORACLE | quality_score.json |

---

### Phase 3: Session Catalog Validation
**Objective**: Validate all 6 session catalogs

| Task | Session | Window (UTC) | Agent Spec |
|------|---------|--------------|------------|
| 3.1 | ASIAN | 00:00-07:00 | ORACLE |
| 3.2 | LONDON | 07:00-12:00 | ORACLE |
| 3.3 | OVERLAP | 12:00-15:00 | ORACLE |
| 3.4 | NY | 15:00-17:00 | ORACLE |
| 3.5 | LATE_NY | 17:00-21:00 | ORACLE |
| 3.6 | EVENING | 21:00-00:00 | ORACLE |

Each validates: tick count, date range, gaps, quality score, Apex time compliance

---

### Phase 4: Integrity & Cleanup
**Objective**: Ensure cross-catalog consistency, remove redundant data

| Task | Description | Agent Spec | Output |
|------|-------------|------------|--------|
| 4.1 | Cross-catalog consistency (main vs sessions) | ORACLE | consistency_report.json |
| 4.2 | Metadata completeness audit | ORACLE | metadata_report.json |
| 4.3 | Redundant data cleanup (CSVs) | FORGE | cleanup_report.json |

---

### Phase 5: Advanced Validation
**Objective**: Deep statistical validation

| Task | Description | Agent Spec | Output |
|------|-------------|------------|--------|
| 5.1 | Volatility clustering (GARCH-like) | ARGUS | volatility_report.json |
| 5.2 | Look-ahead bias detection | SENTINEL | lookahead_report.json |
| 5.3 | Data lineage documentation | FORGE | lineage_doc.md |
| 5.4 | Performance benchmarks | PERF_OPT | benchmark_report.json |

---

### Phase 6: Backtest Framework
**Objective**: Prepare backtesting infrastructure

| Task | Description | Agent Spec | Depends On |
|------|-------------|------------|------------|
| 6.1 | Event-driven backtester | FORGE + NAUTILUS | 6.2 |
| 6.2 | WFA configuration | ORACLE | 6.3 |
| 6.3 | Monte Carlo setup | ORACLE | - |

---

### Phase 7: Backtest Execution
**Objective**: Run comprehensive backtests

| Task | Description | Agent Spec | Parameters |
|------|-------------|------------|------------|
| 7.1 | Baseline backtest | ORACLE | IS: 2020-2023, OOS: 2024 |
| 7.2 | Walk-Forward Analysis | ORACLE | 12 windows, 80/20 split |
| 7.3 | Monte Carlo simulation | ORACLE | 5000+ sims |
| 7.4 | Per-session backtests | SCALE-RUNNER | 6 sessions parallel |

---

### Phase 8: GO/NO-GO Decision
**Objective**: Final recommendation

| Task | Description | Agent Spec |
|------|-------------|------------|
| 8.1 | Consolidate all results | ORACLE |
| 8.2 | Apply GO/NO-GO thresholds | SENTINEL |
| 8.3 | Generate decision document | ORACLE |

---

## Agent Specifications

| Agent | Spec File | Model | Purpose |
|-------|-----------|-------|---------|
| ORACLE | `.claude/agents/oracle-backtest-commander.md` | opus | Backtest validation |
| ARGUS | `.claude/agents/argus-quant-researcher.md` | opus | Research & analysis |
| SENTINEL | `.claude/agents/sentinel-apex-guardian.md` | opus | Risk & compliance |
| FORGE | `.claude/agents/forge-nautilus.md` | opus | Code implementation |
| NAUTILUS | `.claude/agents/nautilus-trader-architect.md` | opus | Architecture |
| PERF_OPT | `.claude/agents/performance-optimizer.md` | opus | Performance |
| SCALE-RUNNER | `.claude/agents/scale-runner.md` | opus | Parallel execution |
| CRITIC | `.claude/agents/critic-adversarial.md` | opus | Adversarial review |

---

## Orchestration Rules

### Parallel Execution
- **Phases 2, 3, 4, 5, 7**: All agents spawn simultaneously
- **No default limits**: User confirmed unlimited capacity
- **Each agent**: Independent task, no cross-dependencies within phase

### Sequential Execution
- **Phases 1, 6, 8**: Dependencies require ordered execution
- **Phase transitions**: Wait for all parallel agents before next phase

### Checkpoints
After each phase:
1. Collect all agent outputs
2. Generate phase summary
3. Store in phase deliverable
4. Consider fresh context if heavy

---

## Execution Command

To execute this plan:

```bash
# From project root
claude --plan .planning/phases/08-data-validation-backtest/
```

Or manually:
```bash
/run-plan .planning/phases/08-data-validation-backtest/01-PHASE-PLAN.md
```

---

## Progress Tracking

| Phase | Status | Started | Completed | Notes |
|-------|--------|---------|-----------|-------|
| 1 | ⏳ Pending | - | - | - |
| 2 | ⏳ Pending | - | - | - |
| 3 | ⏳ Pending | - | - | - |
| 4 | ⏳ Pending | - | - | - |
| 5 | ⏳ Pending | - | - | - |
| 6 | ⏳ Pending | - | - | - |
| 7 | ⏳ Pending | - | - | - |
| 8 | ⏳ Pending | - | - | - |

---

## Related Documents

- [00-BRIEF.md](./00-BRIEF.md) - Project overview
- [01-PHASE-PLAN.md](./01-PHASE-PLAN.md) - Discovery & Config details
- [02-PHASE-PLAN.md](./02-PHASE-PLAN.md) - Main Catalog Validation details
- [03-PHASE-PLAN.md](./03-PHASE-PLAN.md) - Session Validation details
- [04-PHASE-PLAN.md](./04-PHASE-PLAN.md) - Integrity & Cleanup details
- [05-PHASE-PLAN.md](./05-PHASE-PLAN.md) - Advanced Validation details
- [06-PHASE-PLAN.md](./06-PHASE-PLAN.md) - Backtest Framework details
- [07-PHASE-PLAN.md](./07-PHASE-PLAN.md) - Backtest Execution details
- [08-PHASE-PLAN.md](./08-PHASE-PLAN.md) - GO/NO-GO Decision details
