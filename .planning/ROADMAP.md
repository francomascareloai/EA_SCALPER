# ROADMAP — Virtual Gate + Safety Layer (Apex-safe)

**Date:** 2025-12-25
**Scope:** `nautilus_gold_scalper/`

## Guiding order (risk-first)
1. Implement low-risk, high-value safety gates first: ExposureCaps + NewsGuard + VolatilitySpacing.
2. Unify decision-making into a single `UnifiedRiskPolicy` surface and enforce “most restrictive wins” for entries while “must_flatten wins” globally.
3. Add VirtualGate last (highest look-ahead/determinism risk).

## Phase list

### Phase 11 — Safety Layer (Apex-safe)

- **11-01**: Add unified policy interface + entry/exit bypass contract.
- **11-02**: Implement ExposureCaps + NewsGuard + VolatilitySpacing (entry-only, exit-always-allowed).
- **11-03**: Implement VirtualGate (completed bars only, deterministic) + tests.
- **11-04**: Integration backtest + falsification checks (ablation + hostile execution smoke).

## Plan count tracking
- Phase 11: 3/4 executed

## Plans (paths)
- `/.planning/phases/11-virtual-gate-safety-layer/11-01-PLAN.md`
- `/.planning/phases/11-virtual-gate-safety-layer/11-02-PLAN.md`
- `/.planning/phases/11-virtual-gate-safety-layer/11-03-PLAN.md`
- `/.planning/phases/11-virtual-gate-safety-layer/11-04-PLAN.md`

## References
- `.planning/BRIEF.md`
- `DOCS/02_IMPLEMENTATION/PHASES/PHASE_4_INTEGRATION/20251225_VIRTUAL_GATE_PRD/PRD.md`
- `DOCS/02_IMPLEMENTATION/PHASES/PHASE_4_INTEGRATION/20251225_VIRTUAL_GATE_PRD/TEST_CHECKLIST.md`
