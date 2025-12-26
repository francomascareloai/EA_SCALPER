# ROADMAP — Nautilus Gold Scalper Optimization & Safety

**Date:** 2025-12-25
**Scope:** `nautilus_gold_scalper/`

---

## Milestones

- ✅ **v1.0 Safety Layer** - Phase 11 (complete)
- 🚧 **v1.1 Multi-Fidelity Optimization** - Phase 12 (in progress)

---

## Phases

<details>
<summary>✅ Phase 11 — Safety Layer (Apex-safe) - COMPLETE</summary>

### Guiding order (risk-first)
1. Implement low-risk, high-value safety gates first: ExposureCaps + NewsGuard + VolatilitySpacing.
2. Unify decision-making into a single `UnifiedRiskPolicy` surface and enforce "most restrictive wins" for entries while "must_flatten wins" globally.
3. Add VirtualGate last (highest look-ahead/determinism risk).

### Plans
- [x] **11-01**: Add unified policy interface + entry/exit bypass contract.
- [x] **11-02**: Implement ExposureCaps + NewsGuard + VolatilitySpacing (entry-only, exit-always-allowed).
- [x] **11-03**: Implement VirtualGate (completed bars only, deterministic) + tests.
- [x] **11-04**: Integration backtest + falsification checks (ablation + hostile execution smoke).

**Status:** Phase 11 summary at `09-strategy-activation/13-PHASE-11-PLAN.md`

</details>

### 🚧 Phase 12 — Multi-Fidelity Optimization Infrastructure

**Goal:** Enable efficient grid search across 1000+ parameter configurations using tournament-style multi-fidelity optimization.

**Philosophy:** RANKING PRESERVATION > VALUE CORRECTION | FALSIFICATION-FIRST

**Research Foundation:**
- Stride 5 shows +7% error vs stride 1 (best proxy)
- Strides 2-4 overestimate by 170-700% (UNUSABLE)
- Multi-fidelity tournament is industry standard for quant firms

**Plans:**
- [ ] **12-01**: Rank Correlation Validation (DISPROOF TEST - must pass before proceeding)
- [ ] **12-02**: Stride Sensitivity Score Implementation
- [ ] **12-03**: Multi-Fidelity Pipeline Architecture
- [ ] **12-04**: Pessimistic Execution Model
- [ ] **12-05**: Grid Optimizer Integration
- [ ] **12-06**: Production Grid Workflow

**Dependencies:** Phase 11 complete (VirtualGate required)

**GO/NO-GO Gate (12-01):**
- Spearman rank correlation stride5 vs stride1 >= 0.7
- Spearman rank correlation stride10 vs stride1 >= 0.5
- If fails: Multi-fidelity approach is invalid, return to stride 1 only

---

## Progress

| Phase | Milestone | Plans Complete | Status | Completed |
|-------|-----------|----------------|--------|-----------|
| 11. Safety Layer | v1.0 | 4/4 | Complete | 2025-12-25 |
| 12. Multi-Fidelity | v1.1 | 0/6 | Not started | - |

---

## Plan Paths

### Phase 11 (complete)
- `.planning/phases/11-virtual-gate-safety-layer/11-01-PLAN.md`
- `.planning/phases/11-virtual-gate-safety-layer/11-02-PLAN.md`
- `.planning/phases/11-virtual-gate-safety-layer/11-03-PLAN.md`
- `.planning/phases/11-virtual-gate-safety-layer/11-04-PLAN.md`

### Phase 12 (current)
- `.planning/phases/12-multi-fidelity-optimization/00-MASTER.md`
- `.planning/phases/12-multi-fidelity-optimization/12-01-PLAN.md`
- `.planning/phases/12-multi-fidelity-optimization/12-02-PLAN.md`
- `.planning/phases/12-multi-fidelity-optimization/12-03-PLAN.md`
- `.planning/phases/12-multi-fidelity-optimization/12-04-PLAN.md`
- `.planning/phases/12-multi-fidelity-optimization/12-05-PLAN.md`
- `.planning/phases/12-multi-fidelity-optimization/12-06-PLAN.md`

---

## References

- `.planning/BRIEF.md`
- `DOCS/04_REPORTS/VALIDATION/STRIDE_COMPARISON_REPORT_20251225.md`
- `DOCS/02_IMPLEMENTATION/PHASES/PHASE_4_INTEGRATION/20251225_VIRTUAL_GATE_PRD/PRD.md`
