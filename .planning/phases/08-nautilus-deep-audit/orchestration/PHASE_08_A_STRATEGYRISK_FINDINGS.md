# PHASE 08A — Strategy ↔ Risk Integration Findings (GoldScalperStrategy)

AGENT: NAUTILUS
VERSION: 3.1
CLAUDE_MD_VERSION: 3.10.9
STATUS: COMPLETE

## Scope
Trace Strategy ↔ Risk integration across:
- `GoldScalperStrategy` → `PropFirmManager` → `DDProtectionCalculator` + `ConsistencyTracker`
- `GoldScalperStrategy`/`BaseGoldStrategy` → `DrawdownTracker` + `CircuitBreaker` + `TimeConstraintManager` + `PositionSizer`

Primary files reviewed:
- `/home/franco/projetos/EA_SCALPER_XAUUSD/nautilus_gold_scalper/src/strategies/gold_scalper_strategy.py`
- `/home/franco/projetos/EA_SCALPER_XAUUSD/nautilus_gold_scalper/src/strategies/base_strategy.py`
- `/home/franco/projetos/EA_SCALPER_XAUUSD/nautilus_gold_scalper/src/risk/prop_firm_manager.py`
- `/home/franco/projetos/EA_SCALPER_XAUUSD/nautilus_gold_scalper/src/risk/dd_protection.py`
- `/home/franco/projetos/EA_SCALPER_XAUUSD/nautilus_gold_scalper/src/risk/time_constraint_manager.py`
- `/home/franco/projetos/EA_SCALPER_XAUUSD/nautilus_gold_scalper/src/risk/circuit_breaker.py`
- `/home/franco/projetos/EA_SCALPER_XAUUSD/nautilus_gold_scalper/src/risk/drawdown_tracker.py`
- `/home/franco/projetos/EA_SCALPER_XAUUSD/nautilus_gold_scalper/src/risk/position_sizer.py`

Tests referenced (behavior contract):
- `/home/franco/projetos/EA_SCALPER_XAUUSD/nautilus_gold_scalper/tests/test_apex_compliance.py`
- `/home/franco/projetos/EA_SCALPER_XAUUSD/nautilus_gold_scalper/tests/test_risk/test_prop_firm_manager.py`
- `/home/franco/projetos/EA_SCALPER_XAUUSD/nautilus_gold_scalper/tests/test_risk/test_prop_firm_manager_apex.py`
- `/home/franco/projetos/EA_SCALPER_XAUUSD/nautilus_gold_scalper/tests/test_risk/test_circuit_breaker_levels.py`

## Sequential Thinking Trace (12 steps)
1. Identify *where* entries are decided: `_check_for_signal` (bar-driven) and `_enter_long/_enter_short` (order submission).
2. Identify *where* risk state is updated: tick-driven equity updates (`on_quote_tick`) and trade-close events (`on_position_closed`).
3. Map *all* blockers for new entries: `_is_trading_allowed`, time entry gate, `_trading_blocked_today`, `PropFirmManager.can_trade`, `CircuitBreaker.can_trade`, consistency, news/spread/session filters.
4. Verify *call order* in `_check_for_signal`: time gate → prop firm → circuit breaker → selector → consistency → spread/news → sizing → `validate_trade` → submit.
5. Verify *frequency*: time gates and equity DD checks are invoked on every tick and LTF bar; consistency only updates on trade close.
6. Verify *enforcement semantics*: check whether “False” prevents order submission (must return before `_enter_*`).
7. Verify *enforcement for open positions*: identify whether any module force-flattens immediately on breach.
8. Verify *state sync after fills*: ensure position quantity and realized pnl propagate into sizer/circuit/propfirm/dd trackers.
9. Check *temporal correctness* of risk (no future peek): ensure bar/tick timestamps used, not wall clock.
10. Check *Apex invariants*: ET time gates (4:30/4:55/4:59), trailing DD from HWM incl unrealized, 30% consistency.
11. Pre-mortem: how could account blow up despite blockers (e.g., breach occurs while in-position; only entry blocked, not flatten).
12. Conclude integration gaps + concrete handoff actions.

## Integration Topology (as implemented)

Entry path (bar-driven):
- `BaseGoldStrategy.on_bar` → `_on_ltf_bar` (strategy-specific) → `BaseGoldStrategy._check_for_signal` (strategy-specific)
- `GoldScalperStrategy._check_for_signal` applies risk gates and then calls `_enter_long/_enter_short`.

Risk state updates (tick + events):
- `GoldScalperStrategy.on_quote_tick`:
  - updates time gates (`TimeConstraintManager.check`)
  - updates mark-to-market equity → `PropFirmManager.update_equity` → `PropFirmManager.can_trade`
  - updates mark-to-market equity → `CircuitBreaker.update_equity`
- `BaseGoldStrategy.on_quote_tick` (called via `super()`):
  - updates mark-to-market equity → `DrawdownTracker.update` → `_apply_drawdown_limits`
- `BaseGoldStrategy.on_position_closed`:
  - realized pnl → updates `_equity_base`/`_daily_pnl`
  - `DrawdownTracker.update(..., pnl=net_pnl)`
  - `PropFirmManager.register_trade_close(contracts=qty, profit=net_pnl)`
  - `CircuitBreaker.register_trade_result(pnl=net_pnl, is_win=...)`
  - `PositionSizer.register_trade_result(net_pnl)`

## Risk Check Order & Frequency

### Tick frequency (highest priority enforcement)
1. **DrawdownTracker** intrabar update via `BaseGoldStrategy.on_quote_tick`.
2. **Daily reset** via `_check_daily_reset` (ET calendar day).
3. **TimeConstraintManager.check** (emergency flatten & cutoff block).
4. **PropFirmManager.update_equity + can_trade** (trailing HWM, DD protection + consistency).
5. **CircuitBreaker.update_equity** (DD-based escalation).

### Bar frequency (entry gating)
Inside `GoldScalperStrategy._check_for_signal` (only when flat):
1. General `_is_trading_allowed` flag.
2. Session filter.
3. `TimeConstraintManager.can_open_new` (4:30 PM ET entry gate).
4. `_trading_blocked_today` guard.
5. `PropFirmManager.can_trade`.
6. `CircuitBreaker.can_trade`.
7. Strategy selector (reads `DrawdownTracker` dd% and CB state).
8. ConsistencyTracker (duplicated check).
9. Spread/news blocks.
10. `PropFirmManager.validate_trade` (pre-submit risk).

## Enforcement Reality (Does “False” actually block?)

### New entries
PASS: risk checks reliably prevent calling `_enter_long/_enter_short`.
- Example: `validate_trade` is a hard gate immediately before order submission (returns early on failure).

### Open positions (critical)
MIXED: time-based emergency close is enforced; DD-based “stop trading” is often *not* coupled to forced flatten.
- `TimeConstraintManager.check` force-closes positions and blocks trading.
- `PropFirmManager.can_trade` returning `False` on tick currently stops processing further tick logic, but **does not force-close** positions when `raise_on_breach=False`.
- `CircuitBreaker` escalation blocks new trades but does **not** force-close positions.
- `DrawdownTracker/_apply_drawdown_limits` closes position only when reaching configured `daily_loss_limit_pct/total_loss_limit_pct` (defaults in config are 5%/5%, not the project buffer thresholds).

## State Synchronization After Fills / Partial Fills / Close

### Partial fills
- Partial fill is simulated *before* order submission by shrinking quantity. This is conservative because `validate_trade` uses the pre-simulated (larger) quantity, so it will not under-estimate risk.
- Bracket orders use the actual opened position quantity (`self._position.quantity`), so bracket sizing is consistent.

### Trade close propagation
On `PositionClosed`:
- `_equity_base` updated with realized net PnL (after costs).
- Risk modules updated:
  - `PropFirmManager.register_trade_close` (updates equity + streaks + consistency)
  - `CircuitBreaker.register_trade_result`
  - `PositionSizer.register_trade_result`
  - `DrawdownTracker.update(..., pnl=net_pnl)`
This wiring is coherent for realized events.

## Apex Invariants Audit

### Time gates (ET + DST)
PASS:
- Entry gate after **16:30 ET** via `TimeConstraintManager.can_open_new(ts_ns)`.
- Emergency close after **16:55 ET** via `TimeConstraintManager.check(ts_ns)` (force-close every call).
- Flat-by **16:59 ET** via cutoff; in practice emergency already triggers.
- Uses `ZoneInfo("America/New_York")` → DST-safe.

### Trailing DD from HWM including unrealized PnL
PASS for calculation, PARTIAL for enforcement:
- Mark-to-market equity includes unrealized PnL using conservative bid/ask (LONG=BID, SHORT=ASK).
- HWM rises tick-by-tick.
- BUT: when trailing DD safety buffer is breached (e.g., 4.0% in DDProtection tiers / CB L4), system can block new trades without guaranteed immediate flatten.

### Consistency (max 30% daily profit of total)
PASS (mechanism exists):
- `ConsistencyTracker` tracks daily vs total profit in ET.
- Integrated into `PropFirmManager.can_trade` and also checked directly in strategy.
- Note: default tracker safety buffer is 25%, but strategy overwrites it from config (default 30%).

## Findings (Strategy ↔ Risk Integration)

### CRITICAL
1. **DD breach does not guarantee immediate flatten (open positions).**
   - `PropFirmManager` is constructed with `raise_on_breach=False`, so breaches return `False` but do not call `_hard_stop()`.
   - In `on_quote_tick`, strategy returns early when `prop_firm.can_trade` is `False`, but does not force-close positions.
   - `CircuitBreaker` Level 4/5 blocks trading but has no coupling to flatten.
   - `DrawdownTracker/_apply_drawdown_limits` only flattens at configured limits (default 5%/5%), not at project safety buffers (daily 3%, trailing 4%).

2. **Multiple DD systems exist with inconsistent thresholds + enforcement paths.**
   - DDProtection tiers: daily halt at 3.0%, total halt at 4.0% (safety buffer).
   - DrawdownTracker enforcement: tied to config (`daily_loss_limit_pct`, `total_loss_limit_pct`) which default to 5%.
   - CircuitBreaker: total_dd>=4.0→L4, total_dd>=4.5→L5, but no flatten.
   Result: you can reach the safety buffer state while still holding risk.

### HIGH
3. **PositionSizer drawdown throttle is not driven by live drawdown.**
   - `PositionSizer.calculate_lot(..., current_drawdown_pct=0.0 default)` is called without passing actual drawdown, so its dd-based throttling is inactive.
   - Only CB size multiplier affects sizing under drawdown.

4. **Tick-level equity sources differ across modules (potential drift).**
   - DrawdownTracker uses `BaseGoldStrategy._compute_equity_from_tick`.
   - PropFirmManager/CircuitBreaker use `GoldScalperStrategy._compute_equity_from_tick` (via `unrealized_pnl`).
   If these diverge (instrument multiplier semantics, rounding), HWM/DD state can become inconsistent across modules.

### MEDIUM
5. **Redundant/duplicated gates can create confusing “blocked” states.**
   - Consistency is checked both inside `PropFirmManager.can_trade` and again in `_check_for_signal`.
   - Circuit breaker checked twice: gate (no flag flip) and guard (flag flip). This can make behavior non-obvious.

6. **Daily loss check uses `abs(_daily_pnl)` (could block on profits).**
   - Daily DD should be loss-only; current check treats large profits as DD magnitude.

### LOW
7. **Max contracts naming vs units ambiguity.**
   - Strategy passes `qty_units` into `validate_trade(..., contracts=qty_units)`, but `qty_units` are “quantity units” (often oz), not necessarily “contracts”. Might be OK but naming invites misconfiguration.

## Validation Criteria (what to verify next)
- [ ] When trailing DD crosses **4.0%** intrabar with an open position, positions are force-closed within the next tick and trading halts for the day.
- [ ] When daily DD crosses **3.0%** intrabar with an open position, same behavior.
- [ ] All risk modules compute equity/HWM consistently (single shared method and price basis).
- [ ] `PositionSizer` actually reduces risk when drawdown rises (feed current drawdown).

## Handoff to FORGE (implementation tasks)
1. Add deterministic enforcement hook: when `PropFirmManager.can_trade(now)` becomes `False` on tick, force-close positions + block trading (align with safety buffers).
2. Align `DrawdownTracker/_apply_drawdown_limits` thresholds to project safety buffers (daily 3.0%, trailing 4.0%) or explicitly justify divergence.
3. Ensure circuit breaker L4/L5 triggers force-close (or is explicitly subordinate to DD protection enforcement).
4. Pass actual drawdown to `PositionSizer.calculate_lot(..., current_drawdown_pct=...)`.
5. Unify mark-to-market equity computation (single source of truth) used by DrawdownTracker, PropFirmManager, CircuitBreaker.
