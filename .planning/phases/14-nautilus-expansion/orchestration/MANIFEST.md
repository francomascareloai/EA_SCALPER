# Phase 14 — Nautilus Expansion (Orchestration Manifest)

Created: 2025-12-27
Scope: Consolidate *complete* Explorer findings into durable files (no chat-loss), then build an exhaustive implementation plan.

## Source of Truth Files (Full Findings)
- `/.planning/phases/14-nautilus-expansion/orchestration/EXECUTION_ALGOS_AND_ORDERS.md`
- `/.planning/phases/14-nautilus-expansion/orchestration/RISK_ENGINE_AND_SIZING.md`
- `/.planning/phases/14-nautilus-expansion/orchestration/DATA_HANDLING_AND_CACHING.md`
- `/.planning/phases/14-nautilus-expansion/orchestration/NATIVE_INDICATORS.md`
- `/.planning/phases/14-nautilus-expansion/orchestration/STRATEGY_PATTERNS_AND_ACTORS.md`
- `/.planning/phases/14-nautilus-expansion/orchestration/PORTFOLIO_AND_ACCOUNT.md`

## Planning File (Implementation)
- `/.planning/phases/14-nautilus-expansion/14-00-PLAN_MASTER.md`

## Notes
- These findings are intentionally verbose/complete to avoid retrabalho.
- Implementation should follow `14-00-PLAN_MASTER.md` and reference these annexes for API/signature details.

## 2025-12-28 Review outcome (CRITIC + NAUTILUS + FORGE)

**Key insight:** “full scope discovered” ≠ “should ship everything”. We keep annexes as the durable scope dump, but we implement only the prioritized roadmap.

### Authoritative priority order
1. Phase B: RiskEngineConfig hardening (MUST)
2. Run GHOST TEST (edge attribution: filters vs signals)
3. Phase G: Signal bus minimal (telemetry/state-change only) (optional)
4. Phase D: TWAP (experimental; only if slippage is proven bottleneck) (optional)
5. Phase F: Renko (experiment-only; strict anti-lookahead + hostile-cost tests) (optional)
6. Phase E: Indicators (one-at-a-time only, falsification-first) (optional)
7. Phase J: Reporting (later, keep scope tight)
8. Phase H: Controller (last; only if justified by gating criteria)

### Controller gating criteria (do not start without)
- Operational need for independent lifecycle management, OR
- Portfolio-level risk budgeting requirement, OR
- Proven tail-risk reduction in Apex Monte Carlo survival.

### Hard gates before adding complexity
- GHOST TEST
- Apex survival metrics (ΔMC95DD + survival probability)
- Time-gate invariants (4:30 block, 4:55 emergency, 4:59 flat)
- Complexity budget (near-zero new tunables unless deleting others)
