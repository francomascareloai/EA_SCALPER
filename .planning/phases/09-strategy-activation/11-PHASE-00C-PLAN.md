# PLAN: Phase 00-C - Portfolio Strategy Review (Deep Strategy Audit)

## Metadata
- **Phase:** 00-C
- **Priority:** P0 - CRITICAL (portfolio lock before deeper tuning)
- **Status:** READY
- **Owner:** CRUCIBLE (strategy) + ORACLE (validation) + SENTINEL (Apex risk)
- **Depends On:** Phase 00-A, Phase 00-B

---

## Objective
Lock the portfolio-level strategy direction with falsification-first tests:
- Decide what to **keep**, what to **consolidate**, and what to **defer**.
- Validate whether edge comes from **signals** or **filters/execution constraints**.

This phase is **analysis-first**. Minimal code changes only if required to run falsification tests.

---

## Inputs
- Portfolio review section: `nautilus_gold_scalper/FUTURE_IMPROVEMENTS.md` (CRUCIBLE 2025-12-24)
- Falsification suite: `05-FALSIFICATION_TESTS.md`
- Current routing: `nautilus_gold_scalper/src/strategies/strategy_selector.py` (reference)

---

## Tasks

### Task 00C-01: Portfolio Map + Redundancy Audit
**Goal:** Identify correlated/overlapping strategies and regime gaps.

**Checks:**
- Are `SMC_SCALPER` and `SCALPER` functionally distinct, or same microstructure bet?
- Do we have explicit mapping by regime/session (trend vs range vs expansion)?

**Deliverable:** 1-page summary inside `orchestration/PHASE_00C_PORTFOLIO_REVIEW.md`.

---

### Task 00C-02: Lock Decisions (Keep / Consolidate / Defer)
**Decision set:**
1. **Consolidation:** Merge `SMC_SCALPER + SCALPER` into one microstructure scalper (default) OR keep separate (only with evidence of low correlation).
2. **Additions (max 2, conditional):**
   - Volatility Expansion Breakout (range → impulse)
   - Anchored VWAP mean-reversion
3. **Apex/HWM hardening requirement:** mandatory de-risk in profit + time-based exits near 4:55–4:59 PM ET.

**Deliverable:** “Decision Log” section in `orchestration/PHASE_00C_PORTFOLIO_REVIEW.md`.

---

### Task 00C-03: Falsification-First Tests (Cheap)
Run tests in order (stop early if falsified):

1) **Ghost Test (Null Signal / Filters vs Signals)**
- Replace signal generation with baseline/random while keeping ALL filters/gates.
- Gate: if baseline ≈ production (within noise) → edge is filters/cost model; simplify signal logic.

2) **Shifted Levels Test (SMC precision falsification)**
- Jitter OB/FVG/liquidity levels.
- Gate: if performance unchanged → precision is illusion; move to zone-based logic.

3) **Apex HWM Survival (Monte Carlo survival)**
- Evaluate survival probability under HWM trailing DD including unrealized.
- Gate: reject any profile with high blow-up probability; require de-risk / scale-out rules.

**Deliverable:** “Falsification Results” section in `orchestration/PHASE_00C_PORTFOLIO_REVIEW.md`.

---

## GO/NO-GO Gate (Phase 00-C)
- [ ] Decisions are locked with rationale tied to Apex risk
- [ ] Falsification plan lists explicit pass/fail thresholds
- [ ] Next phase updated to reflect: keep/consolidate/defer outcomes

---

## Outputs
- `orchestration/PHASE_00C_PORTFOLIO_REVIEW.md`

---

## Next Phase
- Phase 01 (Cleanup & Consolidation)
