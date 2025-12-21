# Remediation Guide & Checklist (Post-Audit)

This document is the **working playbook** for taking the project from **NO-GO** to **GO** after the Nautilus Deep Audit.

## Quick Links
- Index/status by phase: `MANIFEST.md`
- Final synthesis (GO/NO-GO + criteria): `AUDIT_REPORT.md`
- Prioritized actions (what to fix first): `RECOMMENDATIONS.md`
- Deduped issue inventory (what to track): `ISSUES_TRACKER.md`

## How to Use This (Team Workflow)
1) Pick the **next work package** from the list below (WP0 → WP5).
2) Create a PR for that work package.
3) While implementing:
   - Set impacted issues in `ISSUES_TRACKER.md` to **In Progress**.
   - For each fix, record **PR link/number** and **commit hash** in the issue row (or in the “Evidence Log” section below).
4) Before merging:
   - Run the validation commands in **Validation Gate**.
   - Add/adjust tests to make the fixes regress-proof.
5) After merging:
   - Mark issues as **Fixed (<commit>)**.
   - If any issue is intentionally not fixed, mark **Accepted** and document the rationale.

## Status Conventions (Required)
Use these statuses consistently in `ISSUES_TRACKER.md`:
- **Open**: Not started.
- **In Progress**: Being worked on (must have an owner/PR).
- **Fixed (<commit>)**: Resolved and merged; include a commit hash.
- **Accepted**: Risk accepted with written justification.
- **Deferred**: Not in current milestone; explicitly postponed.

## Work Packages (PR-sized)
These are ordered to eliminate **catastrophic failure modes first**.

### WP0 — Execution Fail-Safe (Bracket + Order Lifecycle)
**Primary goal:** Never allow an open position without confirmed protective SL/TP, and never reuse stale pending SL/TP.

**Issues to cover (minimum):**
- P08-004, P08-005 (from `MANIFEST.md`)
- Phase 05 critical execution lifecycle gaps (`PHASE_05_FINDINGS.md`)

**Acceptance criteria:**
- If entry is rejected/canceled (IOC) and no position opens, pending SL/TP is cleared.
- If position opens but bracket submit fails/rejects, system triggers **fail-safe emergency close + halt**.
- Order/position lifecycle is deterministic and test-covered.

**Checklist:**
- [ ] Add order-event handling (accept/reject/cancel/fill/partial)
- [ ] Ensure pending SL/TP is scoped to one position only
- [ ] Fail-safe: unprotected position → immediate close + trading halt
- [ ] Tests for reject/cancel and bracket reject scenarios

---

### WP1 — Time Gates Robust Under Feed Stalls (Scheduler/Clock)
**Primary goal:** Guarantee Apex close behavior even if ticks/bars stop arriving.

**Issues to cover (minimum):**
- P08-006, P08-007

**Acceptance criteria:**
- At/after 16:55 ET: emergency close attempts happen without relying on `ts_event` updates.
- By 16:59 ET: system guarantees **flat**, and cancels working orders.

**Checklist:**
- [ ] Add wall-clock / scheduler-driven enforcement loop
- [ ] Ensure it cancels orders + closes positions
- [ ] Add deterministic tests simulating “no ticks after 16:54 ET”

---

### WP2 — Force-Flat on DD Safety Breach (While In-Position)
**Primary goal:** DD breach must not merely block entries; it must force-flatten open risk at safety-buffer thresholds.

**Issues to cover (minimum):**
- P08-001, P08-002

**Acceptance criteria:**
- If trailing DD ≥ safety buffer while in-position: force-close on next control loop/tick, then halt.
- DD thresholds/enforcement are harmonized across modules (single source of truth or explicit hierarchy).

**Checklist:**
- [ ] Harmonize thresholds across DDProtection / DrawdownTracker / CircuitBreaker
- [ ] Ensure breach triggers flatten + halt
- [ ] Tests for intrabar breach while holding a position

---

### WP3 — Remove Confirmed Look-Ahead / Leakage in Evaluation Scripts
**Primary goal:** Backtest/validation metrics become trustworthy (no future bars leak into decision-time).

**Issues to cover (minimum):**
- A-001 and other Phase 06 CRITICAL leakage items (`PHASE_06_FINDINGS.md`)

**Acceptance criteria:**
- HTF/MTF inputs are enforced “as-of now” (no future rows).
- Negative tests fail if 1 future bar leaks.

**Checklist:**
- [ ] Enforce “as-of” slicing contracts for HTF/MTF inputs
- [ ] Add negative tests for leakage (1 future bar)
- [ ] Prevent leaky scripts from generating Apex-labeled metrics

---

### WP4 — Determinism Cleanup (Remove Wall-Clock From Backtest-Sensitive Paths)
**Primary goal:** Backtests/replays are reproducible and do not depend on `datetime.now()`.

**Issues to cover (minimum):**
- P08-015 and related wall-clock findings

**Acceptance criteria:**
- Modules that affect signals/execution use event time or the Nautilus clock in a controlled way.

**Checklist:**
- [ ] Replace wall-clock rate limits with event-time-driven logic (or make deterministic under backtest)
- [ ] Add regression tests for deterministic behavior

---

### WP5 — Raise Test Coverage on Critical Paths (Minimums First)
**Primary goal:** Make regressions hard by covering the strategy’s critical safety logic.

**Issues to cover (minimum):**
- P07-001, P07-002

**Acceptance criteria:**
- Add tests that directly cover: time gates, DD flatten, bracket fail-safe, and (at least one) real signal path.
- Coverage increases meaningfully in critical modules (not just trivial lines).

**Checklist:**
- [ ] Add tests for safety invariants (time/DD/bracket)
- [ ] Add at least one deterministic integration-style test for strategy orchestration

## Validation Gate (Run Before Marking “Fixed”)
- `pytest`
- `mypy --strict` (or project’s strict subset if configured)

## Evidence Log (Optional Template)
Use this section if you prefer not to add columns to the big tables.

| Work Package | PR | Commit(s) | Tests Run | Notes |
|---|---|---|---|---|
| WP0 |  |  |  |  |
| WP1 |  |  |  |  |
| WP2 |  |  |  |  |
| WP3 |  |  |  |  |
| WP4 |  |  |  |  |
| WP5 |  |  |  |  |
