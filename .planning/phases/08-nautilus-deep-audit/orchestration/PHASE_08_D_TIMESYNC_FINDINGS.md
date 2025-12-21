# Phase 08 (Agent D) Findings: Time Synchronization

AGENT: NAUTILUS
VERSION: 3.1
CLAUDE_MD_VERSION: 3.10.9
STATUS: COMPLETE

## Scope
Trace and audit all timestamp/timezone usage across the Nautilus gold scalper modules, focusing on:
- Canonical `America/New_York` handling (DST via `zoneinfo`)
- Single time source vs mixed `datetime.now()` / `clock` / `ts_event` usage
- ET session boundaries and daily reset alignment
- Apex time gates enforcement consistency:
  - 16:30 ET block new entries
  - 16:55 ET emergency force-close start
  - 16:59 ET hard flatten deadline
- Degraded-mode behavior if ET timezone conversion is unavailable

## Files Reviewed (time-related)
- `/home/franco/projetos/EA_SCALPER_XAUUSD/nautilus_gold_scalper/src/risk/time_constraint_manager.py`
- `/home/franco/projetos/EA_SCALPER_XAUUSD/nautilus_gold_scalper/src/strategies/gold_scalper_strategy.py`
- `/home/franco/projetos/EA_SCALPER_XAUUSD/nautilus_gold_scalper/src/strategies/base_strategy.py`
- `/home/franco/projetos/EA_SCALPER_XAUUSD/nautilus_gold_scalper/src/risk/prop_firm_manager.py`
- `/home/franco/projetos/EA_SCALPER_XAUUSD/nautilus_gold_scalper/src/risk/consistency_tracker.py`
- `/home/franco/projetos/EA_SCALPER_XAUUSD/nautilus_gold_scalper/src/risk/drawdown_tracker.py`
- `/home/franco/projetos/EA_SCALPER_XAUUSD/nautilus_gold_scalper/src/risk/circuit_breaker.py`
- `/home/franco/projetos/EA_SCALPER_XAUUSD/nautilus_gold_scalper/src/risk/spread_monitor.py`
- `/home/franco/projetos/EA_SCALPER_XAUUSD/nautilus_gold_scalper/src/execution/human_simulator.py`
- `/home/franco/projetos/EA_SCALPER_XAUUSD/nautilus_gold_scalper/src/execution/human_config.py`
- `/home/franco/projetos/EA_SCALPER_XAUUSD/nautilus_gold_scalper/src/execution/delayed_executor.py`
- `/home/franco/projetos/EA_SCALPER_XAUUSD/nautilus_gold_scalper/src/execution/economic_calendar.py`
- `/home/franco/projetos/EA_SCALPER_XAUUSD/nautilus_gold_scalper/src/indicators/session_filter.py`
- `/home/franco/projetos/EA_SCALPER_XAUUSD/nautilus_gold_scalper/src/signals/news_calendar.py`
- `/home/franco/projetos/EA_SCALPER_XAUUSD/nautilus_gold_scalper/src/signals/entry_optimizer.py`
- `/home/franco/projetos/EA_SCALPER_XAUUSD/nautilus_gold_scalper/src/validation/core/config.py`
- `/home/franco/projetos/EA_SCALPER_XAUUSD/nautilus_gold_scalper/src/validation/phases/phase_3_4.py`

## Time-Flow (Observed)

```
Nautilus DataEvent (Bar/QuoteTick)
  └─ provides ts_event (ns)
       ├─ Strategy converts to dt_utc: datetime.fromtimestamp(ts_event/1e9, tz=timezone.utc)
       ├─ ET calendar date: datetime.fromtimestamp(ts_event/1e9, tz=ZoneInfo("America/New_York")).date()
       ├─ Entry block: TimeConstraintManager.can_open_new(ts_event)
       ├─ Emergency close: TimeConstraintManager.check(ts_event) → close_all_positions + block flags
       └─ Risk updates: PropFirmManager.update_equity(equity, now=dt_utc)

Other modules
  ├─ Some use wall-clock: datetime.now(timezone.utc) (SpreadMonitor, EntryOptimizer, parts of risk)
  └─ One uses Nautilus Clock: clock.utc_now() (DelayedExecutor)
```

## Canonical ET / DST Handling

### Positive
- ET timezone is consistently named as `ZoneInfo("America/New_York")` in multiple modules.
- When `ZoneInfo("America/New_York")` works, DST transitions are correctly handled by `zoneinfo`.

### Consistency problems
- ET acquisition is inconsistent:
  - `TimeConstraintManager` guards ET creation (`ET_TZ` may be `None`).
  - `GoldScalperStrategy._check_daily_reset` falls back to `timezone.utc` if `ZoneInfo` fails.
  - `ConsistencyTracker` constructs `ZoneInfo(tz)` with **no fallback** (init will raise if tz data missing).
  - HBS modules (`human_simulator.py`, `human_config.py`, `economic_calendar.py`) bind `ET = ZoneInfo("America/New_York")` at import with **no fallback**.

## Apex Time Gates: 16:30 / 16:55 / 16:59 ET

### Where enforced (integration trace)
- **16:30 ET block new entries**
  - `GoldScalperStrategy._check_for_signal(...)` calls `TimeConstraintManager.can_open_new(bar.ts_event)` and rejects entry if False.
- **16:55 ET emergency force-close start**
  - `GoldScalperStrategy.on_quote_tick(...)` calls `TimeConstraintManager.check(tick.ts_event)` early; if False it returns (after `_force_close_all`).
  - `GoldScalperStrategy._on_m5_bar(...)` does the same with `bar.ts_event`.
- **16:59 ET flatten deadline**
  - Configured via `GoldScalperConfig.flatten_time_et = "16:59"` and passed to `TimeConstraintManager(cutoff=...)`.

### Enforcement gaps
1) **Live robustness risk: gates depend on incoming market events**
- All time-gate checks are driven by `bar.ts_event` / `tick.ts_event`.
- If data delivery stalls, or if no ticks arrive near close, there is no scheduler/wall-clock callback to guarantee emergency close attempts before 16:59 ET.
- For Apex compliance, time gates should be driven by wall clock (`self.clock.utc_now()` or scheduled callbacks) with data-timestamp as secondary.

2) **"16:59 cutoff" code path is effectively shadowed by the 16:55 branch**
- In `TimeConstraintManager.check()`, the `>= emergency` branch triggers for all `>= 16:55`, including times past 16:59.
- As a result, the `>= cutoff` branch is typically unreachable with default configuration (emergency < cutoff).
- The system *does* keep forcing closes after 16:55, but does not separately assert “flat by 16:59”; it only retries closes opportunistically on subsequent calls.

3) **Force-close action does not cancel orders**
- `_force_close_all()` closes positions but does not explicitly cancel orders.
- For end-of-day compliance, order cancellation should be part of the emergency close playbook (architecture-level requirement).

## Daily Reset / Session Boundary Alignment

### Strategy-level resets (ET)
- `GoldScalperStrategy._check_daily_reset(ts_event)` resets daily counters when ET calendar day changes and also resets:
  - `PropFirmManager.on_new_day(...)`
  - `TimeConstraintManager.reset_daily()`
  - `ConsistencyTracker.reset_daily()`
  - `CircuitBreaker.reset_daily(now=...)`
  - `DrawdownTracker.reset_daily()`

### Module-level day logic (mixed)
- `DrawdownTracker._check_new_day()` uses `now.date()` in **UTC**.
- `CircuitBreakerState.daily_reset_time` default uses `datetime.now(timezone.utc)` and (based on state fields) appears UTC-centric.
- This mixture can cause “daily” metrics to roll at UTC midnight, not ET midnight, unless all resets are exclusively driven by the strategy.

## Single Time Source vs Mixed Sources

### Observed sources
- **Event-time (preferred for backtest determinism):** `bar.ts_event`, `tick.ts_event` (ns)
- **Wall clock (UTC):** `datetime.now(timezone.utc)` appears across multiple modules
- **Nautilus Clock:** `clock.utc_now()` in `DelayedExecutor`

### Risk
- Backtests can become non-deterministic or mis-modeled when modules use wall clock:
  - `SpreadMonitor.update()` rate limits using wall-clock seconds; in backtests (fast), it will frequently return cached snapshots.
  - `EntryOptimizer` sets `valid_until = datetime.now(timezone.utc) + ...`, which is misaligned with historical bars/ticks.

## Degraded Mode When ET TZ Unavailable

### Best effort present
- `TimeConstraintManager`: if `ET_TZ is None`, it blocks new trades and calls `_force_close_all` (fail-safe intent).

### Inconsistent / unsafe elsewhere
- HBS + calendar modules can fail import if `ZoneInfo("America/New_York")` is unavailable.
- `GoldScalperStrategy._check_daily_reset` falls back to UTC day boundaries which can re-enable trading at the wrong boundary (mitigated only if `TimeConstraintManager` also blocks).

## Issues (Severity)

### CRITICAL (Apex compliance blockers)
1. **Time gates in live mode are data-driven (no wall-clock/scheduler fail-safe).**
2. **No guaranteed “flat by 16:59 ET” enforcement loop independent of tick arrival; force-close is opportunistic.**

### HIGH
3. **Mixed daily boundary logic (ET vs UTC) across risk modules (DrawdownTracker/CircuitBreaker) risks inconsistent daily limits.**
4. **Wall-clock usage in backtest-sensitive modules (e.g., SpreadMonitor, EntryOptimizer) can break determinism and distort validation.**
5. **ET ZoneInfo availability handling is inconsistent (some fail-safe, some fail-hard).**

### MEDIUM
6. **`TimeConstraintManager.check()` cutoff branch is typically shadowed by emergency branch (default config); reduces clarity/telemetry accuracy.**
7. **Emergency close does not explicitly cancel open orders (only closes positions).**

### LOW
8. **Naive datetime handling varies (some modules `replace(tzinfo=ET)`); safe in current call paths but fragile if reused elsewhere.**

## Validation Criteria (what to verify next)
- Confirm `ts_event` semantics in live TradingNode: is it exchange time or ingestion time, and how it behaves under feed stalls.
- Simulate/force a “no ticks after 16:54 ET” scenario: verify whether the strategy still flattens.
- Validate day-boundary behavior around DST transitions (March/November) using `ZoneInfo("America/New_York")`.
- Run a fast backtest and confirm `SpreadMonitor` behavior does not become wall-clock-rate-limited.
