# BRIEF — Virtual Gate + Safety Layer (Apex-safe)

**Date:** 2025-12-25
**Owner:** Franco
**Repo scope:** `nautilus_gold_scalper/`

## Problem
Current strategies are fragile under hostile execution and Apex constraints. We need a **fail-closed safety layer** that reduces bad entries and enforces non-negotiables (ET time gates + HWM trailing DD) without importing grid/martingale behavior.

## Goals (must)
- Enforce **Apex time gates** (America/New_York):
  - Block new entries after 4:30 PM ET
  - Emergency close at/after 4:55 PM ET
  - Flat by/at 4:59 PM ET
- Enforce **drawdown protection** with conservative marking and hard halts:
  - Trailing DD tracked from HWM including unrealized (BID for longs, ASK for shorts)
  - Hard blocks: trailing DD ≥ 4.0% OR daily DD ≥ 3.0% ⇒ HALT + flatten
- Implement **entry-only guards** that never block exits/forced close:
  - NewsGuard (entries only)
  - ExposureCaps (portfolio hygiene)
  - VolatilitySpacing (trade density control)
  - VirtualGate (observe-before-risk-on filter; completed bars only)
- Provide a single “policy surface” to strategy code:
  - `can_open_new`, `size_factor`, `must_flatten`, `halt_reason`

## Non-goals (explicit)
- Any Titan-style ladder/grid/martingale behavior (no cost averaging, no lot multipliers, no bidirectional ladders).
- Deleting/removing protective exits around news.
- Adding new strategy alpha; this is a safety/compliance layer first.

## Invariants (test protected)
- **Exit-always-allowed**: no guard can block forced close.
- **No grid re-entry**: spacing/cooldown cannot become repeated re-entries into losers.
- **Temporal correctness**: completed bars only; no look-ahead.
- **Determinism**: identical event stream ⇒ identical gate outcomes.

## Success criteria
- Minimum unit + integration tests exist for the invariants.
- Backtest runs with safety layer enabled and does not violate invariants (flat by 4:59 ET, forced close bypass works).
- No regressions in deterministic behavior (repeat run yields identical gate decisions).

## References
- `DOCS/02_IMPLEMENTATION/PHASES/PHASE_4_INTEGRATION/20251225_VIRTUAL_GATE_PRD/PRD.md`
- `DOCS/02_IMPLEMENTATION/PHASES/PHASE_4_INTEGRATION/20251225_VIRTUAL_GATE_PRD/TEST_CHECKLIST.md`
- `DOCS/06_REFERENCE/TITAN X/2025-12-25_integration-round2/SYNTHESIS_round2.md`
