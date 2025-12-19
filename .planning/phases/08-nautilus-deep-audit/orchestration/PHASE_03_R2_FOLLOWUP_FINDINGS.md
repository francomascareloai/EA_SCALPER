# Phase 03 R2 Follow-Up Findings (Risk Modules Integration)

**Purpose:** Targeted follow-up to close or explicitly defer Phase 03 integration blockers and validate the real enforcement chain in code.

**Key constraint (Protocol 0):** Orchestrator does **not** read risk-critical source files directly; verification is based on **SENTINEL sub-agent inspection** with exact file:line references.

**Inputs referenced:**
- `.planning/phases/08-nautilus-deep-audit/orchestration/PHASE_03_INTEGRATION_FINDINGS.md`
- `.planning/phases/08-nautilus-deep-audit/orchestration/PHASE_03_A_DD_FINDINGS.md`
- `.planning/phases/08-nautilus-deep-audit/orchestration/PHASE_03_B_APEX_FINDINGS.md`
- `.planning/phases/08-nautilus-deep-audit/orchestration/PHASE_03_C_SIZING_FINDINGS.md`

**R2 verification agents:**
- SENTINEL time-gates verification (agent output summary, agentId `a1abe76`)
- SENTINEL per-trade validation + fail-open verification (agent output summary, agentId `a31ec45`)

---

## 1) Re-validated / Closed Items (from PHASE_03_INTEGRATION_FINDINGS.md)

### V-001: Time gates are enforced (4:30 entry block, 4:55 emergency flatten, 4:59 flat)
**Previously flagged (stale):** `C-INT-002` claimed 4:30 and 4:55 were only warnings.

**Current evidence (enforced in code):**
- `nautilus_gold_scalper/src/risk/time_constraint_manager.py:41-56` implements **4:30 PM ET no-new-trades** via `can_open_new()`.
- `nautilus_gold_scalper/src/risk/time_constraint_manager.py:77-81` implements **4:55 PM ET emergency force-close** via `_force_close_all()` and returns `False`.
- `nautilus_gold_scalper/src/risk/time_constraint_manager.py:82-88` enforces the **4:59 PM ET cutoff**.
- Strategy wiring confirms both bar-path and tick-path enforcement:
  - `nautilus_gold_scalper/src/strategies/gold_scalper_strategy.py:979-986` blocks entries after 4:30 via `can_open_new(...)`.
  - `nautilus_gold_scalper/src/strategies/gold_scalper_strategy.py:916-923` and `:1864-1869` call `check(...)` to trigger flatten/halts.

**Status:** RESOLVED (time gates exist and are wired).

### V-002: Per-trade risk guardrails are applied before order entry
**Previously flagged (stale):** `C-INT-001` claimed `PropFirmManager.validate_trade(...)` existed but was unused.

**Current evidence (pre-order gate exists):**
- `nautilus_gold_scalper/src/strategies/gold_scalper_strategy.py:1381` calls `self._prop_firm.validate_trade(...)` before entry.
- Order submission happens after the gate, via `_enter_long/_enter_short` at `nautilus_gold_scalper/src/strategies/gold_scalper_strategy.py:1436` and `:1472`.
- Validation delegates to DD protection calculator:
  - `nautilus_gold_scalper/src/risk/prop_firm_manager.py:175-176` delegates to `DDProtectionCalculator.validate_trade(...)`.
  - `nautilus_gold_scalper/src/risk/dd_protection.py:288-289` enforces total-DD safety buffer.
  - `nautilus_gold_scalper/src/risk/dd_protection.py:297-298` enforces dynamic daily-DD cap.

**Status:** RESOLVED (per-trade validation is wired in the entry path).

### V-003: Equity/HWM basis uses conservative BID/ASK (not MID) for GoldScalperStrategy
- `nautilus_gold_scalper/src/strategies/gold_scalper_strategy.py:1979` uses **BID for LONG / ASK for SHORT** mark-to-market equity.

**Status:** RESOLVED for `GoldScalperStrategy`.

---

## 2) Remaining Open Items (must be addressed or explicitly accepted before live)

### O-001 (HIGH): Fail-open on critical risk feed failures
**Problem:** Certain exceptions in risk feeds are logged but trading may continue.

**Evidence:**
- Prop-firm equity update exception is swallowed: `nautilus_gold_scalper/src/strategies/gold_scalper_strategy.py:1914-1915`.
- Spread monitor exceptions clear snapshot and can become permissive:
  - `nautilus_gold_scalper/src/strategies/gold_scalper_strategy.py:1901-1902`
  - Spread gating tends to treat missing snapshot as OK at `nautilus_gold_scalper/src/strategies/gold_scalper_strategy.py:1052`.

**Why this matters:** When equity/HWM cannot be updated, the safest action is **fail-closed** (block entries and attempt to flatten), not “log and continue”.

**Owner:** Phase 03 R2 remediation (risk integration), *not* defer.

### O-002 (HIGH): Emergency close depends on receiving tick/bar events (no independent scheduler)
**Problem:** `TimeConstraintManager.check()` is invoked on tick and bar callbacks. If feed stalls (disconnect / sparse ticks) during the close window, flatten may not trigger exactly at 4:55/4:59.

**Evidence:**
- Tick path: `nautilus_gold_scalper/src/strategies/gold_scalper_strategy.py:1864-1869`.
- Bar path: `nautilus_gold_scalper/src/strategies/gold_scalper_strategy.py:916-923`.

**Risk:** Under outage conditions, you can violate the “flat by 4:59 PM ET” rule without a periodic wall-clock safety loop.

**Owner:** Phase 05 (Execution Layer Audit) *or* Phase 03 R2 if we decide to implement a timer/actor-based scheduler.

### O-003 (MEDIUM): Day-boundary reset can fall back to UTC if ET conversion fails
- `nautilus_gold_scalper/src/strategies/gold_scalper_strategy.py:772-829` uses ET day reset; on exception it falls back to UTC.

**Owner:** Phase 03 R2 (small fix) or Phase 05 (infra/timekeeping).

### O-004 (MEDIUM): Phase 03 risk-module findings may be stale vs current code
Phase 03A/B/C documents show earlier blockers (e.g., time gates missing) which are contradicted by current code paths verified in this R2. These findings should be treated as **historical** unless re-audited in a fresh pass.

**Owner:** Documentation hygiene task (Phase 09 synthesis) — ensure the final report reflects the remediated state.

---

## 3) R2 Verdict

- **Phase 03 R2 is COMPLETE for integration contract validation**: time gates and `validate_trade` are present and wired.
- **Phase 03 is NOT “go-live safe” yet** due to remaining HIGH items:
  - fail-open on equity/spread feed errors
  - no independent scheduler for emergency close under feed stall

**Recommendation:** Continue to Phase 05 (Execution Layer Audit) next to address the scheduler/close mechanics, unless you want Phase 03 R2 to implement fail-closed behavior immediately.
