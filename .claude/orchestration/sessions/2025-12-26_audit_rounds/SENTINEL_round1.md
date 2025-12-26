SENTINEL v3.2 - Apex Trading Guardian
Adversarial Apex Compliance Audit (Round 1)
Date: 2025-12-26
Repo: /home/franco/projetos/EA_SCALPER_XAUUSD

GO/NO-GO
========
VERDICT: NO-GO

Rationale (top-line)
--------------------
The Python/Nautilus path is close to compliant (time gates + conservative HWM/DD logic exist), but there are still credible, account-ending violation paths.
Separately, the MQL5 EA implementation contains a CRITICAL timekeeping defect (manual ET offset) and does not fully match the required time-gate semantics.
Given the prompt scope (“any remaining ways the system could violate”), this is a NO-GO until mitigations are applied/locked.


Apex Rule Coverage Snapshot
==========================
1) Time gates
-------------
Python/Nautilus:
- 16:30 ET (4:30 PM) block new trades: Implemented via TimeConstraintManager.can_open_new().
- 16:55 ET (4:55 PM) emergency flatten: Implemented via TimeConstraintManager.check() -> _force_close_all().
- 16:59 ET (4:59 PM) hard close: Implemented via TimeConstraintManager.check() cutoff.
- Feed-stall enforcement: Optional Clock timer path exists (TimeConstraintManager.check_wall_clock + on_timer).

MQL5:
- Implements flatten after 16:55 ET but relies on manual ET offset (InpETOffset=-5) and does not explicitly enforce 16:30 entry block.

2) Trailing DD (5% from HWM; HWM includes unrealized @ conservative BID/ASK)
--------------------------------------------------------------------------
Python/Nautilus:
- Mark-to-market equity uses conservative exit price (LONG=BID, SHORT=ASK).
- PropFirmManager HWM updates on equity peaks; DDProtection hard-block at trailing >= 4.0% (buffer) and daily >= 3.0%.
- DrawdownTracker documents Apex HWM semantics and supports ET day boundary.

MQL5:
- Not verified in this round for conservative HWM semantics across unrealized; timekeeping already blocks GO.

3) Daily DD semantics + reset timing
-----------------------------------
Python/Nautilus:
- Strategy-level ET daily reset exists (GoldScalperStrategy._check_daily_reset) and resets daily counters + time manager + prop firm + circuit breaker.
- DrawdownTracker supports day_boundary_tz and has tests for America/New_York.


CRITICAL Failure Modes (Adversarial)
===================================
FM-1 (CRITICAL): MQL5 ET timekeeping / DST mismatch
--------------------------------------------------
What fails:
- MQL5 uses InpETOffset=-5 (fixed) to convert GMT->ET for cutoff/reset logic.
- During EDT (UTC-4), this produces a 1-hour error.

1st-order consequence:
- Cutoff/flatten can occur 1 hour late or early vs real ET, enabling overnight positions or premature flatten.

2nd-order consequence:
- Apex rule breach (position open past 4:59 PM ET) becomes likely under DST.

3rd-order consequence:
- Account termination / evaluation failure due to hard rule violation, even if strategy edge is good.

Required mitigation:
- Eliminate manual ET offset; derive ET via timezone rules (America/New_York) or broker-provided server time mapping with DST awareness.
- Add explicit 16:30 block new trades + 16:59 hard close (even if emergency at 16:55).
- Add a self-test log on startup showing computed ET offset and next close deadline.


FM-2 (CRITICAL): Feed-stall path can be disabled (Python) -> overnight risk
--------------------------------------------------------------------------
What fails:
- TimeConstraintManager enforcement is event-driven (ticks/bars) unless the Clock timer is enabled.
- Config allows disabling time_gate_use_clock_timer, or clock may not be wired in some runtime contexts.

1st-order consequence:
- If market events stop arriving near/after 16:55/16:59 ET, no enforcement call is executed.

2nd-order consequence:
- Position stays open into/after the close window.

3rd-order consequence:
- Overnight violation -> Apex breach; or large gap/illiquidity -> trailing DD breach at reopen.

Required mitigation:
- In prop_firm_enabled mode, force-enable timer enforcement (or enforce via a separate wall-clock watchdog process).
- Add a hard “no-timer in prop firm mode” startup block (fail closed).
- Add runtime telemetry/alerts when timer is not armed.


FM-3 (CRITICAL): Multi-position / multi-instrument state could undercount unrealized equity/DD
--------------------------------------------------------------------------------------------
What fails:
- BaseStrategy._compute_equity_from_tick computes equity using ONLY self._position (single position assumption).
- Risk/DD enforcement (DrawdownTracker/PropFirmManager) is fed from this single-position equity.

1st-order consequence:
- If a bug/race condition creates multiple open positions, trailing DD and HWM tracking can be wrong (understated).

2nd-order consequence:
- System may allow new risk while actually near Apex trailing DD limit.

3rd-order consequence:
- Account termination due to hidden DD breach that was not detected early enough.

Required mitigation:
- Enforce a single-position invariant at the execution layer (reject any new entry when any position is open, across all instruments).
- If multi-position is ever allowed, compute MTM equity by summing unrealized PnL across cache.positions_open() using conservative BID/ASK per side.


FM-4 (HIGH): Time drift/NTP contract not enforced at runtime
-----------------------------------------------------------
What fails:
- CLAUDE.md requires clock drift validation and degraded-mode time gates when time is uncertain.
- Current code paths rely on zoneinfo conversion and (optionally) Nautilus Clock timestamp, but do not demonstrate explicit drift checks.

Consequence:
- Mis-timed enforcement windows under drift; higher risk of trading too close to close.

Required mitigation:
- Add startup drift check + degrade to earlier gates if uncertain.


FM-5 (HIGH): Close-order retry semantics depend on cache visibility/order IDs
----------------------------------------------------------------------------
What fails:
- TimeConstraintManager attempts to detect rejected close orders via cache.orders delta and OrderStatus.REJECTED.
- If order IDs cannot be reliably captured (batch close) or cache is stale, rejections may not be detected.

Consequence:
- Positions could remain open longer than expected near close.

Required mitigation:
- Ensure individual close path logs confirm fills, and add a “still open at 16:58:30 ET” escalation alert.


Required Mitigations (Minimum to lift NO-GO)
===========================================
M1 (MANDATORY): Fix MQL5 timekeeping
- Replace InpETOffset manual logic with DST-aware ET time determination.
- Enforce 16:30 entry block, 16:55 emergency flatten, 16:59 hard close.
- Add self-check logs and unit-style checks if possible.

M2 (MANDATORY): Lock time gate enforcement in prop firm mode (Python)
- Prevent disabling the Clock timer enforcement (or provide equivalent watchdog).
- Alert/abort if clock/timer not available in live/paper.

M3 (MANDATORY): Eliminate multi-position DD blind spot
- Enforce single-position invariant OR compute MTM equity across all open positions conservatively.

M4 (RECOMMENDED): Add explicit time drift validation and degraded-mode gates


Confidence
==========
High confidence on identifying the MQL5 DST/time-gate mismatch as a CRITICAL compliance risk.
Moderate-high confidence on Python feed-stall/timer-config footgun as a CRITICAL risk (depends on deployment config discipline).

Files Reviewed (key)
====================
- nautilus_gold_scalper/src/risk/time_constraint_manager.py
- nautilus_gold_scalper/src/strategies/gold_scalper_strategy.py
- nautilus_gold_scalper/src/strategies/base_strategy.py
- nautilus_gold_scalper/src/risk/drawdown_tracker.py
- nautilus_gold_scalper/src/risk/prop_firm_manager.py
- nautilus_gold_scalper/src/risk/dd_protection.py
- nautilus_gold_scalper/tests/test_risk/test_time_constraint_manager.py
- nautilus_gold_scalper/tests/test_apex_compliance.py
- MQL5/Experts/EA_SCALPER_XAUUSD.mq5
