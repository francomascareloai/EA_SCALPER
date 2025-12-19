# Phase 03A Findings (DD Stack): Drawdown + Protection + Circuit Breaker

## Status
**COMPLETE** — DD stack reviewed for Apex trailing DD (HWM-based) compliance, protection actions, fail-safe behavior, and numerical precision.

## Scope
Files audited:
- `/home/franco/projetos/EA_SCALPER_XAUUSD/nautilus_gold_scalper/src/risk/drawdown_tracker.py`
- `/home/franco/projetos/EA_SCALPER_XAUUSD/nautilus_gold_scalper/src/risk/dd_protection.py`
- `/home/franco/projetos/EA_SCALPER_XAUUSD/nautilus_gold_scalper/src/risk/circuit_breaker.py`

Protocols applied (per request): Protocol 0, 2, 3, 8, 11–14 from:
- `/home/franco/projetos/EA_SCALPER_XAUUSD/.planning/phases/08-nautilus-deep-audit/PROTOCOLS.md`

## Executive Summary
The DD stack is conceptually aligned with an equity/HWM drawdown model, but **is not yet Apex-safe** as implemented. The main problems are:
1) **Threshold and semantics mismatches** against project CORE (CLAUDE.md) hard-block rules (e.g., trailing DD ≥4.0% must HALT, but `dd_protection.py` maps 4.0% to STOP_NEW),
2) **Circuit breaker escalation uses daily DD** for “4.0/4.5” levels, despite Apex termination risk being **trailing DD from HWM**; and
3) **Fail-open / non-fail-safe edge handling** (invalid equity, NaN, negative DD, comparison operators `>` vs `>=`).

Net: the system can **permit trading in the termination zone** under realistic multi-day or spike/retrace paths.

## Issue Summary
Total issues: **11**
- **CRITICAL:** 3
- **HIGH:** 5
- **MEDIUM:** 3
- **LOW:** 0

## Apex Verification Report (Protocols 8 + 14)
### A. Trailing Drawdown (5% from HWM; HWM includes unrealized)
- **HWM update present:** YES (but only via `current_equity` input)
  - `drawdown_tracker.py`: updates `_high_water_mark` when `current_equity > _high_water_mark`.
  - `circuit_breaker.py`: updates `peak_equity` when `current_equity > peak_equity`.
- **Includes unrealized P/L:** **DEPENDENT ON CALLER** (not computed here)
  - None of the audited modules compute unrealized PnL from positions.
  - None implement conservative pricing basis (BID for longs / ASK for shorts).
- **TRADOVATE “eternal trailing” handling:** NOT VERIFIED in these modules (they are generic).
- **Bar vs tick-level HWM:** Not explicit; HWM updates at call frequency (likely per-bar in backtests).

**Verdict:** **FAIL / PARTIAL** (HWM math exists, but unrealized inclusion + conservative basis not enforced; safety buffers mismatched).

### Buffer thresholds (per project CORE)
Project CORE (`CLAUDE.md`) hard blocks:
- Trailing DD **≥ 4.0%** → **HALT immediately**
- Daily DD **≥ 3.0%** → **HALT immediately**

Findings:
- `dd_protection.py`: total DD tiers include 4.0% but action is **STOP_NEW** (not HALT). 4.5% is HALT_ALL, 5.0% is TERMINATED.
- `circuit_breaker.py`: levels 4/5 use **daily DD** thresholds (4.0/4.5), not trailing.

**Verdict:** **FAIL** (buffers exist but actions and metrics used are inconsistent with project’s non-negotiables).

## Detailed Findings by Module

### 1) drawdown_tracker.py (core drawdown state)
**What it does well**
- Implements daily drawdown % as `(daily_start_equity - current_equity) / daily_start_equity`.
- Implements total drawdown % as `(high_water_mark - current_equity) / high_water_mark`.
- Updates HWM whenever `current_equity` exceeds prior HWM.
- Uses caller-supplied `now` for backtest determinism.

**Key gaps vs Apex requirements**
1. **Unrealized PnL inclusion not enforced** (HIGH)
   - The module assumes `current_equity` “includes unrealized” but does not compute it.
   - If upstream equity uses mid-price or ignores spread, HWM can be inflated or understated.

2. **No conservative pricing basis** (HIGH)
   - Project requires: LONG uses BID, SHORT uses ASK for unrealized equity to avoid artificial HWM inflation.
   - This module is position-agnostic and does not accept bid/ask inputs.

3. **Fail-safe violation on invalid equity** (MEDIUM/HIGH)
   - `update()` early-returns `get_analysis()` when `current_equity <= 0`.
   - This “do nothing” behavior is not fail-safe; it can preserve a previous “safe” state while equity input is corrupted.

4. **Precision/threshold handling not conservative** (MEDIUM)
   - Uses floats and no rounding strategy.
   - No explicit conservative comparisons (e.g., `>=` at threshold boundaries) because this module doesn’t enforce limits; but it feeds other modules.

**Impact**
- Safe operation relies on upstream providing properly computed equity (incl unrealized and conservative mark), otherwise HWM/DD is not Apex-faithful.


### 2) dd_protection.py (tiering + trade validation)
**What it does well**
- Encodes daily tiers: 1.5/2.0/2.5/3.0.
- Encodes total tiers: 3.0/3.5/4.0/4.5/5.0.
- Computes dynamic daily limit: `min(3%, remaining_buffer * 0.6)`.
- `validate_trade()` checks:
  - total_dd + risk against **4.5% emergency threshold**
  - daily_dd + risk against dynamic daily limit

**Critical gaps**
1. **4.0% trailing buffer action mismatch** (CRITICAL)
   - Project CORE says trailing DD ≥4.0% → HALT immediately.
   - `TOTAL_DD_TIERS` maps 4.0% to `DDAction.STOP_NEW` (not HALT).
   - This permits “management trading” paths at a level the project defines as a hard stop.

2. **`can_trade` is effectively fail-open for HALT conditions** (CRITICAL)
   - `can_trade = daily_action != TERMINATED and total_action != TERMINATED`.
   - This means `HALT_ALL` (4.5% total DD) and `EMERGENCY_HALT` (3.0% daily DD) still yield `can_trade=True`.
   - Downstream callers that only check `can_trade` could continue operating.

3. **Non-conservative comparisons in `validate_trade`** (HIGH)
   - Uses `potential_total_dd > 4.5` (should be `>=` for conservative compliance).
   - Uses `potential_daily_dd > max_daily_dd_pct` similarly.

4. **Negative/over-limit buffer not clamped** (MEDIUM)
   - `remaining_buffer_pct = 5.0 - total_dd_pct` can go negative if DD already beyond limit.
   - `max_daily_dd_pct` can become negative; that will block trades (good), but state values become confusing and may break UI/logging.

**Impact**
- This module is intended to be “the rules”, but its action semantics do not match project CORE hard blocks.
- The module’s own wording says “HALT” at 4.5% but its state can still appear tradable.


### 3) circuit_breaker.py (cooldowns + lockout)
**What it does well**
- Thread-safe state, cooldown timers, and escalation levels.
- Tracks both `daily_dd_percent` and `total_dd_percent`.
- Implements size multipliers for loss-streak or DD levels.

**Critical gaps**
1. **Escalation uses daily DD thresholds for Level 4/5 (4.0/4.5)** (CRITICAL)
   - `_check_and_escalate()` escalates to Level 4/5 based on `daily_dd_percent`.
   - Apex termination risk is **trailing DD from HWM**, not only daily.
   - A multi-day drawdown that slowly consumes trailing buffer may never trigger Level 5 lockdown.

2. **Total DD percent is computed but not used for lockout** (HIGH)
   - `total_dd_percent` exists but does not drive any escalation path.

3. **DD percent calculations are not clamped** (HIGH)
   - `daily_dd_percent` can be negative when current equity > daily start.
   - `total_dd_percent` can be negative when current equity > peak.
   - This can suppress protective triggers and also mislead telemetry.

4. **Apex compliance claim is overstated** (MEDIUM)
   - Comments claim “Trailing DD 5% enforced” but the enforcement path does not reference trailing thresholds.

**Impact**
- Circuit breaker cannot be trusted as the last safety layer for trailing termination.


## Failure Mode Analysis (Protocol expectations)
Expected: exceptions/invalid inputs → **fail-safe (block trading / halt / close)**.

Observed:
- `drawdown_tracker.update()` returns previous analysis if equity invalid (fail-open relative to “assume worst”).
- `dd_protection` is pure math, but can yield inconsistent state (negative buffers) and has permissive `can_trade` semantics.
- `circuit_breaker.update_equity()` accepts any float and can compute negative DD; escalation then may not occur.

**Overall:** Fail-safe behavior is **incomplete**.

## Temporal / Look-ahead (Protocol 3)
No explicit look-ahead patterns detected in these modules. They are state machines updated in time order.

Risk remains that backtest resolution (bar updates) understates **intra-bar HWM spikes** (Protocol 14 clarification: bar vs tick-level HWM). That is a model risk and should be explicitly called out in the audit: backtests may underestimate trailing DD trap severity.

## Recommendations (Audit-level; not implementation)
1. Align the “hard block” semantics with project CORE:
   - trailing DD ≥4.0% should map to HALT state (no trading).
2. Ensure all termination/lockout logic is driven by **trailing total DD** (HWM-based), not only daily DD.
3. Make validation comparisons conservative (`>=` at thresholds) and define rounding direction.
4. Fail-safe on invalid/NaN/Inf equity: assume worst case (halt) and alert.
5. Enforce or verify upstream equity computation uses conservative BID/ASK marks for unrealized PnL.

## CRITIC Self-Review Notes

### Verification
- Sequential thinking thoughts used: 12
- Adversarial techniques applied: INVERSION, PRE-MORTEM, EDGE CASE STRESS, APEX_TRAP

### Techniques Applied (with concrete examples)
1. **INVERSION**: Asked “What implementation would allow trading in the 4.5–5.0% termination zone?” → found `dd_protection.can_trade` only blocks on TERMINATED; `HALT_ALL` leaves `can_trade=True`.
2. **PRE-MORTEM**: Simulated “multi-day grind-down” where daily DD is small but trailing DD accumulates → circuit breaker Level 5 never triggers because it checks daily DD only.
3. **EDGE CASE STRESS**: Considered corrupted equity inputs (`<=0`, NaN) → `drawdown_tracker.update()` returns prior analysis, which could mask risk.
4. **APEX_TRAP**: Considered spike-then-retrace with bar-level updates → backtest may miss intra-bar HWM spikes, underestimating the trailing floor and buffer loss.

### Issues Found During Self-Review
1. Initially assumed `circuit_breaker.total_dd_percent` drives escalations; on re-read it is computed but unused → upgraded severity to CRITICAL mismatch.
2. Confirmed `dd_protection` 4.0% tier is STOP_NEW not HALT, which conflicts with `CLAUDE.md` hard blocks → classified as CRITICAL.

### Assumptions Challenged
1. Assumption: “Equity always includes unrealized correctly.” → Challenge: mark-to-market may be mid-price; no conservative basis here → Conclusion: must be enforced upstream or explicitly validated.
2. Assumption: “Circuit breaker is final safety.” → Challenge: thresholds are on daily DD only → Conclusion: cannot rely on CB for trailing termination protection.

### Confidence Level
**HIGH** — Findings are direct from control-flow/threshold definitions and require no speculative inference beyond documented project rules.
