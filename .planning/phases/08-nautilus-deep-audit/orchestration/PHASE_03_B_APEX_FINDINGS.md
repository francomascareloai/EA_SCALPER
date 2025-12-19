# Phase 03 (Agent B) Findings: Apex Rules Stack

**Scope:** Apex time-gate enforcement (4:30 / 4:55 / 4:59 PM ET), DST handling (`America/New_York`), fail-safe behavior, 30% consistency rule enforcement, and rule priority ordering.

**Files reviewed (source of truth):**
- `/home/franco/projetos/EA_SCALPER_XAUUSD/nautilus_gold_scalper/src/risk/time_constraint_manager.py`
- `/home/franco/projetos/EA_SCALPER_XAUUSD/nautilus_gold_scalper/src/risk/consistency_tracker.py`
- `/home/franco/projetos/EA_SCALPER_XAUUSD/nautilus_gold_scalper/src/risk/prop_firm_manager.py`

**Protocols applied:** Protocol 0, 2, 8, 11, 12, 13, 14 from `/home/franco/projetos/EA_SCALPER_XAUUSD/.planning/phases/08-nautilus-deep-audit/PROTOCOLS.md`.

---

## Executive Verdict (Agent B)

**Overall Apex compliance (time gates + consistency): PARTIAL / FAIL-SAFE GAPS PRESENT → BLOCKED for live/paper-trading gate.**

Primary blockers are in `TimeConstraintManager`: it does **not** implement the required 4:30 PM ET entry block or 4:55 PM ET emergency close behavior, and its timezone fallback can become **non-ET** (fail-open relative to compliance).

---

## 1) Time Gates (4:30 / 4:55 / 4:59 ET) — Protocol 14.B + Protocol 8

### Expected (Apex non-negotiables)
- **4:30 PM ET:** block **new entries** (existing positions may remain, but must be actively managed toward flatten).
- **4:55 PM ET:** emergency close begins; retry loop until flat.
- **4:59 PM ET:** must be flat (hard deadline).
- Must use `America/New_York` (DST safe) and be robust to timezone/clock issues (prefer fail-safe early close).

### Found in `/nautilus_gold_scalper/src/risk/time_constraint_manager.py`

**Implementation summary**
- Uses `ZoneInfo("America/New_York")` when available.
- Emits staged warnings at default times:
  - `warning=16:00`, `urgent=16:30`, `emergency=16:55`
- Performs a **single forced close** only when `now_time >= cutoff` (default `16:59`).

**Critical gap 1 — 4:30 PM entry block NOT implemented**
- The `urgent=16:30` is only a *log warning* gate; it does not block new entries.
- There is no explicit policy “no new trades after 4:30 PM ET”.
- Consequence: strategy can still open trades at 16:58:50 ET (depending on caller discipline), relying on a last-second forced close at 16:59.

**Critical gap 2 — 4:55 PM emergency close behavior NOT implemented**
- The `emergency=16:55` gate also only logs a warning.
- There is no “begin flatten and retry” loop from 16:55 to 16:59.
- `_force_close_all()` attempts `close_all_positions()` once; fallback loops positions once; exceptions are swallowed.
- Consequence: if close requests fail/reject/partial-fill, the system has no built-in escalation cadence to force flat by 16:59.

**Critical gap 3 — timezone fallback is unsafe (may be non-ET)**
- If `ZoneInfo("America/New_York")` fails, `dt_et = datetime.fromtimestamp(...)` is created without tz.
- A naive datetime uses the host’s local timezone semantics when comparing `time()`; it is *not guaranteed ET*.
- This is a compliance hazard: incorrect time gate decisions → potential overnight violation.

**Critical gap 4 — no clock-drift / degraded-mode handling**
- CLAUDE.md timekeeping contract requires NTP drift checks and degraded-mode earlier gates if time uncertain.
- `TimeConstraintManager` has no drift validation and no conservative earlier cutoff mode.

**Secondary concern — daily reset coupling**
- Warnings/cutoff use `_issued` set and require `reset_daily()` to clear.
- If caller forgets to call `reset_daily()`, the “cutoff” action will not be emitted again; trading remains blocked (fail-safe) but telemetry/cleanup semantics may degrade.

### Severity
- **CRITICAL (BLOCKER)**: missing 4:30 entry block, missing 4:55 emergency close & retries, unsafe tz fallback.

---

## 2) DST Handling (America/New_York) — Protocol 14.B

### Positive
- `ZoneInfo("America/New_York")` is the correct canonical timezone for DST-safe ET handling.

### Problems
- If `ZoneInfo` fails, the code does **not** fail-safe by assuming worst-case “close early”. It simply drops to naive time.
- DST transitions are not explicitly tested in these modules (no test hooks seen here; may exist elsewhere).

### Severity
- **HIGH**: DST itself is handled when `ZoneInfo` works; but the fallback behavior is not safe for a compliance module.

---

## 3) Consistency Rule ("30% max daily profit") — Protocol 14.D

### Expected
Apex “consistency” rule is typically interpreted as:
- No single day’s profit should exceed **30%** of the *total profits* at payout evaluation.
- Practical enforcement requires tracking the **best day profit** across days (or at least the maximum daily profit), not just “today vs total”.
- Must define response: block new entries / reduce size / alert; and decide how unrealized PnL is treated.

### Found in `/nautilus_gold_scalper/src/risk/consistency_tracker.py`

**Implementation summary**
- Tracks `total_profit` and `daily_profit` as `Decimal`.
- Resets day when `now.date()` changes.
- Triggers `_limit_hit` when:
  - `total_profit > 0` and `(daily_profit / total_profit) >= 0.25` (25% safety buffer).

**Critical gap 1 — wrong metric for the published “30% daily consistency” concept**
- The rule implemented is “today’s profit share of total profit so far” rather than “max daily profit share of total profit”.
- Over multiple days, the constraint should use the **max(day_profit)** to ensure no *any* day breaches the ratio.
- This implementation forgets prior days’ peak once the day resets.

**Critical gap 2 — early-phase behavior is overly sensitive and potentially inconsistent**
- On the first profitable day, `daily_profit == total_profit`, so daily_pct = 100% and limit is hit immediately.
- This might be intentional to force smoothing, but it is not aligned with the typical payout rule interpretation (which is evaluated at payout total, not intraday on day 1).

**Scope mismatch — unrealized PnL not included**
- Tracker only updates on trade close via `update_profit(trade_pnl, now)`.
- There is no integration for unrealized PnL peaks.
- Whether unrealized must be included is ambiguous; Protocol 14.D suggests verifying it and being conservative. If conservative inclusion is required, this module does not satisfy it.

**Minor positive — numerical type choice**
- Using `Decimal` avoids float error accumulation for profit accounting.

### Severity
- **HIGH (likely BLOCKER for “strict Apex consistency enforcement”)**: metric and state model appear mismatched to the rule; enforcement resets lose prior-day peak.

---

## 4) Rule Orchestration / Priority Ordering — Protocol 14 + CLAUDE.md

### Expected priority (per CLAUDE.md / Sentinel directive)
- Most restrictive gate must win: **DD protections > Time gates > Consistency**.
- Also: any time gate should always allow “close/flatten” actions even if trade entries are blocked.

### Found in `/nautilus_gold_scalper/src/risk/prop_firm_manager.py`

**Observations**
- `PropFirmManager` integrates:
  - DD protections via `DDProtectionCalculator` (multi-tier) and legacy daily/trailing checks.
  - Consistency via `ConsistencyTracker`.
- There is **no** integration with `TimeConstraintManager` in this module.

**Critical gap — no unified gatekeeper for time + DD + consistency**
- `PropFirmManager.can_trade()` can block trading based on DD and consistency, but it does not enforce time gates.
- This violates the plan’s “single gatekeeper” intent unless the strategy layer composes all checks correctly (not verifiable from this Agent B scope).

**Priority implementation detail**
- `can_trade()` calls `get_state()` first (DD-based). If DD disallows, it triggers `_hard_stop()` and termination semantics.
- Only after `state.is_trading_allowed` is true does it check consistency and potentially return `False`.
- This ordering matches **DD > consistency**, but time is missing.

**Consistency action semantics**
- On consistency breach, `can_trade()` returns `False` but does not flatten or raise `AccountTerminatedException`.
- Depending on your intended policy, this may be acceptable (“block new entries only”) or insufficient (“must reduce/close to avoid violating payout rules”).

### Severity
- **CRITICAL (integration blocker)**: time gates are not part of `PropFirmManager` (no clear single point for Apex compliance).

---

## 5) Fail-Safe / Fail-Open Assessment — Protocol 14 + Failure Mode tables in plan

### `TimeConstraintManager`
- If ET timezone unavailable: behavior becomes ambiguous/non-ET → **fail-open** relative to compliance.
- If close fails: exceptions swallowed, no retry → **fail-open** (positions may remain open into deadline).
- If reset_daily not called: system blocks trading (fail-safe), but may not re-trigger close events.

### `ConsistencyTracker`
- On errors: no explicit exception handling. If an exception is thrown upstream, behavior depends on caller.
- Behavior resets daily, potentially losing prior-day peak; that is a “logic fail-open” (could allow a later payout-violating shape).

### `PropFirmManager`
- DD breach path is aggressive (raises/stop/flatten) and generally fail-safe.
- Time gate missing ⇒ overall system compliance depends on external composition.

---

## 6) Protocol 11/12/13 Application Notes

- **Protocol 11 (Dangerous Pattern Detection):** Not directly applicable to these three small risk modules (no pandas shift/bfill/ML transforms). Manual scan did not observe the listed leakage patterns.
- **Protocol 12 (Nautilus config verification):** Not applicable here; these modules do not configure `ts_init_delta`, `bar_execution`, etc.
- **Protocol 13 (Statistical validation metrics):** Not applicable; these modules do not compute strategy metrics.

(Still documented here to satisfy “apply protocols” requirement and explicitly mark non-applicability.)

---

## 7) Apex Compliance Matrix (Agent B)

| Rule / Gate | Required | Found | Location | Verdict |
|---|---:|---:|---|---|
| 4:30 PM ET block new entries | YES | NO | `time_constraint_manager.py:20-69` | FAIL (CRITICAL) |
| 4:55 PM ET emergency close | YES | NO | `time_constraint_manager.py:56-67` | FAIL (CRITICAL) |
| 4:59 PM ET hard close/flat | YES | PARTIAL (single attempt at 16:59) | `time_constraint_manager.py:61-67` | FAIL (CRITICAL: no retry) |
| DST via America/New_York | YES | YES (when ZoneInfo works) | `time_constraint_manager.py:11-53` | PARTIAL |
| Consistency 30% max/day | YES | PARTIAL (25% daily/total, no max-day tracking) | `consistency_tracker.py:11-61` | PARTIAL/HIGH |
| Rule priority DD > Time > Consistency | YES | PARTIAL (DD > consistency; time missing) | `prop_firm_manager.py:138-155` | FAIL (CRITICAL integration) |

---

## Issues List (with severities)

### CRITICAL (Blockers)
1. **TCM-001:** Missing 4:30 PM ET “no new trades” enforcement (`time_constraint_manager.py`).
2. **TCM-002:** Missing 4:55 PM ET emergency flatten + retry loop; only logs warning at 16:55.
3. **TCM-003:** Unsafe timezone fallback to naive local time if `ZoneInfo` fails (compliance fail-open).
4. **PFM-001:** `PropFirmManager` does not orchestrate time gates; no single Apex-compliance gatekeeper.

### HIGH
1. **CT-001:** Consistency rule implemented as “today/total so far” and resets daily without tracking max-day profit; likely mismatched to payout consistency concept.
2. **TCM-004:** No degraded-mode earlier cutoffs / no clock-drift awareness per timekeeping contract.

### MEDIUM
1. **CT-002:** Unrealized PnL is not considered for consistency (if conservative inclusion is required).
2. **PFM-002:** On consistency breach, `can_trade()` blocks entries but does not enforce flatten (policy decision; may be insufficient).

### LOW
1. **TCM-005:** Float conversion from `ts_ns / 1e9` could lose ns precision; likely acceptable for minute-level gates.

---

## Recommendations (for Phase 03 consolidation)

- Treat time-gate stack as **non-compliant** until 4:30/4:55/4:59 gates are explicit, DST fallback is fail-safe, and close/flatten has retry semantics.
- Ensure there is a **single gatekeeper** (either `PropFirmManager` owns time gates or the strategy reliably composes them in a strict order). Document the call chain in Phase 03 integration step.
- Decide and document what “consistency enforcement” means operationally in this project (evaluation vs PA/live, realized vs unrealized, when to start enforcing). Current implementation is likely not the intended final form.

---

## CRITIC Self-Review Notes

### Verification
- Sequential thinking thoughts used: 12
- Adversarial techniques applied: INVERSION, PRE-MORTEM, EDGE CASE STRESS, APEX_TRAP checks

### Techniques Applied (with examples)
1. **INVERSION:** Assumed the worst: the system clock is not ET and `ZoneInfo` fails → does the module still keep us flat by 4:59 ET? Result: no; naive fallback can mis-time gates.
2. **PRE-MORTEM:** “It’s 4:58:50 ET, a new trade is opened, close_all_positions fails once, no retries, position remains open at 5:00.” Result: plausible given current `_force_close_all()` behavior.
3. **EDGE CASES:**
   - DST fall-back day: local timezone confusion if tz unavailable.
   - Partial fills / order rejections during emergency close window: no retry/escalation present.
   - Daily reset not called: cutoff action not re-emitted.
4. **APEX_TRAP:** Looked for any reliance on “Apex will auto-close” or “trailing forgiving” logic; no explicit reliance found, but missing retry logic effectively assumes closes will work.

### Issues Found During Self-Review
1. Initially categorized consistency implementation as CRITICAL; downgraded to HIGH because enforcement interpretation can be policy-dependent (evaluation vs payout), but still likely incorrect for the stated “30% daily” concept.
2. Considered `reset_daily()` omission as CRITICAL; revised to MEDIUM/LOW because it fails-safe (blocks trading) but can harm observability.

### Assumptions Challenged
1. **Assumption:** ZoneInfo always available on deployment. **Challenge:** minimal container / restricted tzdata. **Conclusion:** must handle tz failure safely.
2. **Assumption:** close_all_positions always succeeds quickly. **Challenge:** network/API failure, rate limits, partial fills. **Conclusion:** emergency close needs retry/escalation.

### Confidence Level
**HIGH** — The missing explicit 4:30/4:55 enforcement and unsafe tz fallback are direct, unambiguous gaps visible in code paths.
