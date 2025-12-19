# Phase 03 Step 2 (Integration Verification): Cross-Module Gatekeeper Call Chain

Date: 2025-12-18
Scope: Nautilus Deep Audit – Phase 03 (Risk Modules) – Step 2 Integration Verification

## Objective
Verify cross-module integration and the actual “gatekeeper” call chain from strategy → risk modules → order entry/close. Confirm:
- Single entry point (`prop_firm_manager.can_trade()`) used before EVERY entry
- Priority ordering enforced (DD > Time > Consistency)
- Emergency close path exists and can bypass circuit breaker cooldown
- Equity source used for DD is conservative BID/ASK vs MID
- Exceptions fail-safe (no trade / close positions) vs fail-open

## Files Traced (minimum + supporting)
Primary required set:
- `/home/franco/projetos/EA_SCALPER_XAUUSD/nautilus_gold_scalper/src/strategies/gold_scalper_strategy.py`
- `/home/franco/projetos/EA_SCALPER_XAUUSD/nautilus_gold_scalper/src/strategies/base_strategy.py`
- `/home/franco/projetos/EA_SCALPER_XAUUSD/nautilus_gold_scalper/src/risk/prop_firm_manager.py`
- `/home/franco/projetos/EA_SCALPER_XAUUSD/nautilus_gold_scalper/src/risk/time_constraint_manager.py`
- `/home/franco/projetos/EA_SCALPER_XAUUSD/nautilus_gold_scalper/src/risk/drawdown_tracker.py`
- `/home/franco/projetos/EA_SCALPER_XAUUSD/nautilus_gold_scalper/src/risk/dd_protection.py`
- `/home/franco/projetos/EA_SCALPER_XAUUSD/nautilus_gold_scalper/src/risk/circuit_breaker.py`
- `/home/franco/projetos/EA_SCALPER_XAUUSD/nautilus_gold_scalper/src/risk/position_sizer.py`
- `/home/franco/projetos/EA_SCALPER_XAUUSD/nautilus_gold_scalper/src/risk/spread_monitor.py`

## Integration Map (actual call chain)

### Strategy initialization wiring
In `GoldScalperStrategy.__init__` (within `/home/franco/projetos/EA_SCALPER_XAUUSD/nautilus_gold_scalper/src/strategies/gold_scalper_strategy.py`) the strategy instantiates and retains:
- `self._prop_firm = PropFirmManager(...)` and `self._prop_firm.set_strategy(self)` when `config.prop_firm_enabled` (around `gold_scalper_strategy.py:523-552`).
- `self._position_sizer = PositionSizer(...)` and `self._drawdown_tracker = DrawdownTracker(...)` when `config.prop_firm_enabled` (same region).
- `self._time_manager = TimeConstraintManager(strategy=self, ...)` (around `gold_scalper_strategy.py:576-585`).
- `self._circuit_breaker = CircuitBreaker(...)` with parameterized thresholds copied from config (around `gold_scalper_strategy.py:587-604`).
- `self._spread_monitor = SpreadMonitor(...)` always (around `gold_scalper_strategy.py:565-574`).

Key integration note: the strategy uses BOTH:
- “New” consolidated prop-firm manager (`PropFirmManager`, with embedded `DDProtectionCalculator`)
- “Legacy/aux” `DrawdownTracker` and `CircuitBreaker` in parallel
This means DD enforcement can occur via multiple independent mechanisms.

### Tick-level feeds (mark-to-market equity)
On each `QuoteTick`, `GoldScalperStrategy.on_quote_tick` calls `super().on_quote_tick(tick)` (base handles generic spread + drawdown tracker feed), then performs its own feeds. In the excerpt region `gold_scalper_strategy.py:1845-1913`:
- Time gate enforced early: `if prop_firm_enabled and _time_manager and not _time_manager.check(tick.ts_event): return` (at `gold_scalper_strategy.py:1852-1854`).
- Spread monitor updated with `bid` and `ask` and snapshot cached (at `gold_scalper_strategy.py:1859-1888`).
- Prop firm equity feed: compute equity from tick, then `self._prop_firm.update_equity(equity, now=tick_dt)`; immediately checks `if not self._prop_firm.can_trade(now=tick_dt): return` (at `gold_scalper_strategy.py:1889-1898`).
- Circuit breaker equity feed: compute equity and call `_circuit_breaker.update_equity(equity, now=tick_dt)` (at `gold_scalper_strategy.py:1902-1910`).

Result: intraday HWM + trailing DD for PropFirmManager and CB are fed mark-to-market, not only at trade close. This is required for Apex-style HWM trap.

### Bar-level entry gating (pre-entry “can I open a position?”)
Order entries happen in `GoldScalperStrategy._check_for_signal` → (various signal logic) → eventually `_enter_long(...)` or `_enter_short(...)`.

Risk gates inside `_check_for_signal` are (in the excerpt region `gold_scalper_strategy.py:927-1134`):
1) Base safety gates: `instrument` must exist, `_is_trading_allowed` must be True, must be flat.
2) Session filter (not part of requested risk stack).
3) TimeConstraintManager check: `if prop_firm_enabled and _time_manager and not _time_manager.check(bar.ts_event): return` (`gold_scalper_strategy.py:979-986`).
4) `_trading_blocked_today` flag gate (set by TimeConstraintManager after cutoff) (`gold_scalper_strategy.py:987-993`).
5) PropFirmManager “global gate”: `if prop_firm_enabled and _prop_firm and not _prop_firm.can_trade(now=bar_time): ... return` (`gold_scalper_strategy.py:995-1003`).
6) Circuit breaker gate: checks `_circuit_breaker.can_trade(now=bar_time)` and blocks if False (`gold_scalper_strategy.py:1005-1038`) and later a second guard at `gold_scalper_strategy.py:1080-1088`.
7) Strategy selector (not requested).
8) Consistency tracker: `_consistency_tracker.can_trade(...)` blocks and sets `_is_trading_allowed = False` (`gold_scalper_strategy.py:1070-1078`).
9) News filter and spread filter.

### Order entry itself
Actual order submission uses BaseStrategy `_enter_long/_enter_short`:
- `_enter_long` creates a market order and submits it, and stores pending SL/TP. Then `on_position_opened` submits broker-side stop-market SL and TP orders (BaseStrategy at `base_strategy.py:489-593`, notably `stop_market(... trigger_price=self._pending_sl, ...)` at `base_strategy.py:565-576`).

This is important for “broker-side stop required”: code creates stop-market orders; in Nautilus this generally means server-side/exchange order. So the enforcement exists, contingent on venue support.

## Required Checks (answers with code references)

### 1) Single entry point gatekeeper (`prop_firm_manager.can_trade()`) used before EVERY entry?

Finding: NO. There is no single gatekeeper function that is the “only” pre-entry permission check. The strategy uses a chain of separate gates.

Evidence:
- `_check_for_signal` checks `_time_manager.check(...)`, then `_prop_firm.can_trade(...)`, then `_circuit_breaker.can_trade(...)`, then `_consistency_tracker.can_trade(...)` (see `gold_scalper_strategy.py:979-1088`).
- Additionally, tick-level flow checks `_time_manager.check(...)` and then `_prop_firm.can_trade(...)` after feeding equity (`gold_scalper_strategy.py:1852-1898`).

Also critical gap: per-trade validation (`PropFirmManager.validate_trade`) is not integrated into the order-entry sizing/approval flow.
- `PropFirmManager.validate_trade(...)` exists (`prop_firm_manager.py:157-186`), but there are no calls to `_prop_firm.validate_trade(...)` in `gold_scalper_strategy.py` (confirmed by search in this audit). Consequently, “can trade at all” is checked, but “this particular trade’s risk would breach dynamic daily limit or 4.5% emergency threshold” is NOT enforced via that API.

Impact:
- Global “allowed to trade” may remain True while an individual proposed trade is too large versus remaining buffer (especially near 4.0%/4.5% zones). The code relies on sizing being small enough and on mark-to-market exits, but the explicit rule “NEVER allow trade if DD + trade risk > …” is not guaranteed.

### 2) Priority ordering enforced (DD > Time > Consistency)?

Finding: NOT strictly enforced in the requested ordering.

Actual gating order in `_check_for_signal`:
- TimeConstraintManager blocks BEFORE PropFirmManager is consulted (Time gate first, then “blocked_today”, then PropFirmManager) (`gold_scalper_strategy.py:979-1003`).
- Consistency is checked AFTER PropFirmManager and AFTER CircuitBreaker and after selector (at `gold_scalper_strategy.py:1070-1078`).

Interpretation:
- The system is “fail-safe enough” in the sense that any gate can block trading, but it does not implement a single deterministic priority where DD checks are evaluated before time checks.

More serious: TimeConstraintManager does not implement a 4:30 PM ET “hard block new trades”; it only escalates warnings and blocks only at `cutoff` (default 16:59). In `time_constraint_manager.py:20-27`, `urgent` defaults to 16:30 and `emergency` to 16:55, but these are warnings only (see `time_constraint_manager.py:56-60`). Trading remains allowed until `now_time >= cutoff` (`time_constraint_manager.py:61-69`).

So the system currently enforces “force-flat at cutoff” but not “block new trades after 4:30 PM ET” as described in CLAUDE.md.

### 3) Emergency close path exists and can bypass circuit breaker cooldown?

Finding: PARTIAL YES.

Emergency/forced close path exists via TimeConstraintManager `_force_close_all`:
- Trigger condition: `now_time >= cutoff` causes `_force_close_all(dt_et)` and returns False (see `time_constraint_manager.py:61-69`).
- `_force_close_all` closes positions using `strategy.close_all_positions(...)`, falling back to iterating `strategy.cache.positions_open()` if needed; it then sets `strategy._is_trading_allowed=False` and `strategy._trading_blocked_today=True` (see `time_constraint_manager.py:75-93`).

Bypass of circuit breaker cooldown:
- TimeConstraintManager directly calls close methods on the strategy and does not consult CircuitBreaker state. Therefore it will attempt to flatten even if CircuitBreaker is in cooldown. This satisfies “close path bypasses CB cooldown” in practice.

But: The “Emergency close at 4:55 PM ET” as a distinct forced-flatten time is NOT implemented. `emergency` time is treated as a warning tier (see `time_constraint_manager.py:32-37` and `time_constraint_manager.py:56-60`). The actual flatten occurs at `cutoff`, which by default is `16:59` (`time_constraint_manager.py:23` and default config in strategy `flatten_time_et: "16:59"` at `gold_scalper_strategy.py:231-233`).

So, it implements “flatten by 4:59”, but not “start force-close from 4:55”.

### 4) Equity source used for DD: conservative BID/ASK or MID?

Finding: MIXED by module, but the primary mark-to-market equity for prop-firm trailing DD uses conservative BID/ASK.

Evidence:
- `GoldScalperStrategy._compute_equity_from_tick` uses BID for LONG and ASK for SHORT to value unrealized PnL (conservative) at `gold_scalper_strategy.py:1956-1967`.
- This equity is used to feed:
  - PropFirmManager trailing HWM via `update_equity(equity, now=...)` (`gold_scalper_strategy.py:1894-1896`).
  - CircuitBreaker via `update_equity(equity, now=...)` (`gold_scalper_strategy.py:1906-1908`).
  - DrawdownTracker via BaseStrategy tick handler; BaseStrategy calls `self._compute_equity_from_tick(tick)` and, because it is a virtual call, it resolves to GoldScalperStrategy override if present (`base_strategy.py:338-343` combined with `gold_scalper_strategy.py:1956-1967`).

Counter-evidence / risk:
- BaseStrategy’s own `_compute_equity_from_tick` uses MID price (`base_strategy.py:690-701`), which is explicitly disallowed by CLAUDE.md for HWM calculation. However, in the actual running strategy class (`GoldScalperStrategy`), this method is overridden, so the base implementation should not be used at runtime for this strategy.
- This is still a maintenance hazard: any future strategy subclass that doesn’t override `_compute_equity_from_tick` will revert to MID-based unrealized PnL.

Conclusion:
- For GoldScalperStrategy, equity basis is conservative BID/ASK.

### 5) Exceptions in risk modules fail-safe (no trade / close) or fail-open?

Finding: MIXED; several “fail-open” paths exist due to exception swallowing.

Fail-safe examples:
- TimeConstraintManager forced close attempts are wrapped in try/except and fall back to iterative closing; it then blocks trading flags regardless (`time_constraint_manager.py:75-93`).
- PropFirmManager.can_trade returns False when state disallows trading (`prop_firm_manager.py:138-155`). In the strategy, when can_trade is False it blocks further trading by setting `_is_trading_allowed=False` (`gold_scalper_strategy.py:1001-1002`).

Fail-open examples:
- In `GoldScalperStrategy.on_quote_tick`, the prop firm equity feed is wrapped:
  - On exception: logs debug and continues, leaving trading potentially enabled (`gold_scalper_strategy.py:1899-1900`). This is fail-open relative to “if we cannot compute equity/HWM safely, block trading”.
- SpreadMonitor update is wrapped; on exception it sets `_spread_snapshot = None` (`gold_scalper_strategy.py:1886-1888`). Since later gates treat missing snapshot as “spread OK” (`gold_scalper_strategy.py:1052-1053`), this is fail-open under monitor failure.

- PropFirmManager.update_equity does not catch exceptions, but callers often do. The risk is not in update_equity itself; it is in callers swallowing errors.

- In PropFirmManager.can_trade, there is confusing double-call to `_hard_stop` even when `_raise_on_breach` is False (see `prop_firm_manager.py:142-152`). Strategy sets `raise_on_breach=False`, so `_hard_stop` is not invoked from the first branch; yet the method still sets `_terminated=True` and tries `_hard_stop` in a try/except afterwards. This is partially fail-safe (it ends up returning False) but the internal logic is inconsistent and could be brittle in future changes.

## Additional Integration Observations

### DD enforcement duplication and inconsistency risk
There are at least three DD-related mechanisms:
1) `PropFirmManager` maintains `_high_water` and uses `DDProtectionCalculator.calculate_state(...)` which computes daily_dd_pct and total_dd_pct from HWM and day start (see `prop_firm_manager.py:187-197` and `dd_protection.py:193-259`).
2) `DrawdownTracker` computes daily drawdown from daily start equity and total drawdown from high-water mark (see `drawdown_tracker.py:152-161`).
3) `CircuitBreaker` computes daily_dd_percent from daily_start_equity and total_dd_percent from peak_equity (its own peak) (see `circuit_breaker.py:218-231`).

Because these are updated on different schedules and by different inputs, they can disagree (e.g., if one feed is missed due to exception handling).

### Missing per-trade risk guardrail hook
`DDProtectionCalculator.validate_trade(...)` explicitly intends to enforce:
- “Current total DD + proposed risk_pct must not exceed 4.5%” (`dd_protection.py:282-289`)
- “Current daily DD + proposed risk_pct must not exceed dynamic max daily dd” (`dd_protection.py:290-296`)

But this is only invoked inside `PropFirmManager.validate_trade(...)` (`prop_firm_manager.py:157-185`), which is not called from the strategy entry flow. This is a notable integration gap versus the phase plan’s requirement “DD > Time > Consistency and per-trade risk”.

### Time gate mismatch vs Apex spec
Strategy uses TimeConstraintManager at `bar` and `tick` level (good), but the manager blocks only at `cutoff` and treats 16:30 and 16:55 as warnings only. This does not implement “block new trades after 4:30 PM ET” nor “force-close from 4:55 PM ET” as hard gates.

## Issue List (integration-level)
Severity definitions are audit-local (C/H/M/L):

- C-INT-001 (CRITICAL): No single gatekeeper; per-trade risk validation not applied before entry. `PropFirmManager.validate_trade` exists but is unused in order-entry flow.
  - Evidence: `prop_firm_manager.py:157-186` exists; no call sites in `gold_scalper_strategy.py`.

- C-INT-002 (CRITICAL): Time gate spec mismatch: 4:30 PM ET “block new trades” and 4:55 PM ET “force-close” are not implemented as hard gates.
  - Evidence: `time_constraint_manager.py:56-69` only blocks at cutoff; `gold_scalper_strategy.py:231-233` cutoff default 16:59.

- H-INT-003 (HIGH): Fail-open behavior on risk module exceptions (prop firm equity update and spread monitor update). Under errors, system can continue trading without risk state.
  - Evidence: `gold_scalper_strategy.py:1899-1900` (prop firm update exception), `gold_scalper_strategy.py:1886-1888` (spread snapshot cleared).

- M-INT-004 (MEDIUM): BaseStrategy includes MID-based equity computation (maintenance hazard if reused by another strategy without override).
  - Evidence: `base_strategy.py:690-701`.

- M-INT-005 (MEDIUM): CircuitBreaker thresholds refer to “daily DD” while constructor also carries a `total_loss_limit` parameter; the module’s escalation uses daily_dd_percent thresholds for level 3/4/5, not total_dd_percent, but the strategy uses it as both daily and total risk feedback.
  - Evidence: `circuit_breaker.py:386-407` uses `daily_dd_percent` for all DD levels.

## Verdict (Phase 03 Step 2 – Integration Verification)
**STATUS: BLOCKED**

Rationale:
- The integration does not prove a single “can_trade() gatekeeper before every entry”, and per-trade risk validation (dynamic daily limit and 4.5% emergency threshold) is not applied at entry.
- Time gate hard requirements (4:30 block new entries; 4:55 force-close) are not enforced as described by CLAUDE.md; only final 16:59 cutoff is enforced.
- Multiple fail-open exception paths exist in core risk feeds.

## CRITIC Self-Review Notes (adversarial)

INVERSION: “What could blow the account even if everything looks gated?”
- A trade near end-of-day could be entered after 16:30 because the system only warns at 16:30 and still allows entries until 16:59. A fill + latency + partial fills could leave an open position close to cutoff; the forced close triggers at cutoff, but there is no enforced earlier ‘no-new-trade’ buffer.

APEX HWM TRAP:
- Mark-to-market equity feed uses conservative bid/ask in `GoldScalperStrategy._compute_equity_from_tick` (`gold_scalper_strategy.py:1956-1967`), which is correct. However, if `update_equity` fails (exception swallowed at `gold_scalper_strategy.py:1899-1900`), HWM may not update or breach may not be detected; trading continues (fail-open). That is precisely when protective logic is most needed.

STRESS TEST:
- If SpreadMonitor throws repeatedly, `_spread_snapshot` becomes None and downstream gates treat spread as OK (`gold_scalper_strategy.py:1052-1053`), allowing entries under unknown spread.

ASSUMPTION CHALLENGE:
- The architecture assumes that “small risk_per_trade” is enough without invoking `PropFirmManager.validate_trade`. This is unsafe when total DD is high; dynamic daily limit can drop below configured risk_per_trade.

EDGE CASE:
- Because `TimeConstraintManager` uses `datetime.fromtimestamp(ts_ns/1e9, tz=ET_TZ)` with `ET_TZ` potentially None (see `time_constraint_manager.py:49-53`), a misconfigured runtime without zoneinfo could interpret timestamps in local timezone and produce incorrect ET gating.

Conclusion of CRITIC:
- The call chain is present and mostly conservative, but the missing hard time gates and missing per-trade validation are high-risk gaps. Block until fixed.
