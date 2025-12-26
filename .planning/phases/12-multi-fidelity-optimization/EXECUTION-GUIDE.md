# Phase 12: Multi-Fidelity Optimization — EXECUTION GUIDE

**Date:** 2025-12-25
**Status:** NEEDS UPDATE (tournament module not implemented in repo)

---

## Quick Reference

This guide describes the original **Phase 12 multi-fidelity tournament** execution.

Current reality (2025-12-26): the repo does **not** contain `nautilus_gold_scalper/src/optimization/fidelity/`, so plans 12-01..12-06 are **not runnable as-written**.
The production path today is the existing optimizer with anti-overfit gates:
- `constraints.apex.daily_dd_max`
- Layer3 stress metrics: `mc_95_dd`, `mc_99_dd`, `degradation_survived`
- Candidate-set PBO proxy: `pbo_candidate_set`

(Once the tournament module exists, the plan order below becomes actionable.)

```
┌─────────────────────────────────────────────────────────────┐
│  TOURNAMENT EXECUTION ORDER (Sequential - DO NOT SKIP)      │
├─────────────────────────────────────────────────────────────┤
│  12-01: Rank Correlation  ──► BLOCKING GATE                │
│         ↓ (must pass ρ ≥ 0.7)                              │
│  12-02: Sensitivity Score  ─┬─► Can run in parallel        │
│  12-03: Pipeline Architecture─┘                             │
│         ↓                                                   │
│  12-04: Pessimistic Execution                               │
│         ↓                                                   │
│  12-05: Grid Integration                                    │
│         ↓                                                   │
│  12-06: Production Workflow                                 │
└─────────────────────────────────────────────────────────────┘
```

---

## Execution Commands

### Step 1: Rank Correlation Validation (BLOCKER)

```bash
/run-plan .planning/phases/12-multi-fidelity-optimization/12-01-PLAN.md
```

(Original draft included runtime estimates here; intentionally removed to avoid anchoring on unmeasured timings.)

**GO/NO-GO Gate:**
- ✅ GO if: Spearman ρ(stride5, stride1) ≥ 0.7 AND ρ(stride10, stride1) ≥ 0.5
- ❌ NO-GO if: Correlation below thresholds → STOP Phase 12, use stride 1 only

**DO NOT PROCEED TO 12-02+ UNTIL 12-01 PASSES**

---

### Step 2: Sensitivity + Pipeline (Parallel)

After 12-01 passes, run these two in parallel:

```bash
# Terminal 1
/run-plan .planning/phases/12-multi-fidelity-optimization/12-02-PLAN.md

# Terminal 2
/run-plan .planning/phases/12-multi-fidelity-optimization/12-03-PLAN.md
```

---

### Step 3: Pessimistic Execution

```bash
/run-plan .planning/phases/12-multi-fidelity-optimization/12-04-PLAN.md
```

---

### Step 4: Grid Integration

```bash
/run-plan .planning/phases/12-multi-fidelity-optimization/12-05-PLAN.md
```

---

### Step 5: Production Workflow

```bash
/run-plan .planning/phases/12-multi-fidelity-optimization/12-06-PLAN.md
```

---

## Verification Commands

After each plan, run these to confirm success:

```bash
# Tests pass
.venv/bin/pytest -q nautilus_gold_scalper/tests/

# Type checking
.venv/bin/mypy --strict nautilus_gold_scalper/src/optimization/

# Quick sanity backtest
.venv/bin/python -m nautilus_gold_scalper.scripts.backtest.run_backtest \
  --source catalog \
  --catalog-path data/catalog_native/xauusd_2003_2025_stride1_COMPLETE \
  --sample 10 \
  --start 2024-06-03 --end 2024-06-10 \
  --enable-trend-follow
```

---

## Full Phase Execution (One Command)

To run all plans sequentially with automatic progression:

```bash
# NOT RECOMMENDED - prefer manual execution to validate gates
# But if you want to run everything:

for plan in 01 02 03 04 05 06; do
  echo "=== Running 12-${plan}-PLAN.md ==="
  /run-plan .planning/phases/12-multi-fidelity-optimization/12-${plan}-PLAN.md

  # Check for failures
  if [ $? -ne 0 ]; then
    echo "PLAN 12-${plan} FAILED - stopping execution"
    exit 1
  fi
done
```

---

## Monitoring Long-Running Tasks

```bash
# Watch optimizer progress (current implementation writes to logs/optimization/<timestamp>/)
# Example:
# tail -f logs/optimization/*/optimize.log

# (Tournament log path is a placeholder for the deferred multi-fidelity module.)
# tail -f data/optimization/tournament_*/tournament.log

# Check system resources during stride 1 runs
htop

# Monitor disk space (parquet files can be large)
df -h data/
```

---

## Recovery Commands

If a plan fails or is interrupted:

```bash
# Resume from specific plan
/run-plan .planning/phases/12-multi-fidelity-optimization/12-0X-PLAN.md

# Check what was completed
cat .planning/phases/12-multi-fidelity-optimization/12-0X-SUMMARY.md

# If tournament was interrupted, resume:
# NOTE: Tournament resume is not implemented yet (no `src/optimization/fidelity/` module).
# Current optimizer resumption uses checkpoints; see `nautilus_gold_scalper/src/optimization/checkpointing.py`.
# Example placeholder for future tournament resume:
#   python ... --mf-resume tournament_YYYYMMDD_HHMMSS
```

---

## Files Created by Phase 12

After successful completion:

```
nautilus_gold_scalper/
├── src/optimization/fidelity/
│   ├── __init__.py
│   ├── stages.py           # FidelityStage enum, STAGE_CONFIGS
│   ├── optimizer.py        # MultiFidelityOptimizer
│   ├── sensitivity.py      # StrideSensitivityScorer
│   ├── pessimistic_fill.py # PessimisticFillModel
│   ├── spread_gate.py      # SpreadBufferGate
│   ├── persistence.py      # TournamentPersistence
│   └── logging.py          # TournamentLogger
├── scripts/optimization/
│   ├── rank_correlation_test.py
│   ├── rank_correlation_analysis.py
│   ├── validate_mf_config.py
│   └── analyze_tournament.py
├── configs/grids/
│   ├── multi_fidelity_template.yaml
│   └── rank_correlation_configs.json
└── tests/optimization/
    ├── test_sensitivity.py
    ├── test_multi_fidelity.py
    ├── test_pessimistic_fill.py
    └── test_mf_integration.py

DOCS/
├── 02_IMPLEMENTATION/
│   └── MULTI_FIDELITY_WORKFLOW.md
└── 04_REPORTS/VALIDATION/
    ├── STRIDE_COMPARISON_REPORT_20251225.md
    └── RANK_CORRELATION_REPORT.md

data/
├── validation/
│   └── rank_correlation_results.parquet
└── optimization/
    └── tournament_*/
        ├── metadata.json
        ├── stage_0_results.parquet
        ├── stage_1_results.parquet
        ├── stage_2_results.parquet
        ├── stage_3_results.parquet
        └── finalists.json
```

---

## Notes

- This document contains runtime estimates (hours) from the original Phase 12 draft; treat them as historical notes, not execution guidance.
- Once `nautilus_gold_scalper/src/optimization/fidelity/` exists, these estimates should be replaced with measured values from actual runs.

---

## Success Criteria (Phase 12 Complete)

- [ ] 12-01: Rank correlation validated (ρ ≥ 0.7 for stride 5)
- [ ] 12-02: Sensitivity scoring implemented and tested
- [ ] 12-03: Multi-fidelity pipeline runs end-to-end
- [ ] 12-04: Pessimistic execution model integrated
- [ ] 12-05: Tournament CLI flags integrated (DEFERRED)
- [ ] 12-06: Production workflow documented
- [ ] All tests pass: `pytest -q`
- [ ] Type checking passes: `mypy --strict`
- [ ] At least one full grid search completed successfully

---

*"Don't build a system that needs reality removed to look good."* — DAEMON
