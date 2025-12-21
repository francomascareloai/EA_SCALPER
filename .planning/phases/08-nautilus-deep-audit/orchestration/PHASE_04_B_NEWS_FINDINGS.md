# Agent B - Signal Generators Audit Findings (News Modules)

## Summary
- Modules reviewed: `nautilus_gold_scalper/src/signals/news_calendar.py`, `nautilus_gold_scalper/src/signals/news_trader.py`
- Lines analyzed: ~1,319
- Issues found: **CRITICAL: 1 | HIGH: 2 | MEDIUM: 3 | LOW: 2**

## Module: news_calendar.py

### Overview
`NewsCalendar` provides a lightweight economic-news proximity filter.
- Stores events as `NewsEvent(time_utc=...)`.
- Calculates “in window” status and recommended `NewsTradeAction` based on minutes-to-event.
- Uses a short-lived cache (`_cache_ttl_minutes=60`) and a 5-second result memoization when called without a custom `now`.

### Findings

| ID | Severity | Issue | Location | Recommendation |
|----|----------|-------|----------|----------------|
| P04-B-001 | HIGH | **Naive timestamps are silently assumed to be UTC**, which can shift event time by 4–5 hours if an upstream source provides ET timestamps without tzinfo (DST-dependent). | `nautilus_gold_scalper/src/signals/news_calendar.py:58-62` | Prefer rejecting naive datetimes (raise) or require an explicit timezone on input; if upstream is ET, parse in `America/New_York` then convert to UTC using `zoneinfo`. |
| P04-B-002 | HIGH | **Hardcoded calendar coverage is extremely narrow** (only a handful of Dec 2025 events). In 2026+ live trading the cache becomes empty, disabling news protection; in historical backtests, future-year hardcoded events are irrelevant and provide no realistic news filter. | `nautilus_gold_scalper/src/signals/news_calendar.py:165-223`, `:573-591` | Treat hardcoded events as a last-resort fallback only. Add an explicit “data unavailable → conservative block” mode, or integrate a proper calendar data source and distinguish live vs backtest feeds. |
| P04-B-003 | MEDIUM | “Today/This week” calculations are defined in **UTC day boundaries**, not `America/New_York`. This can mismatch trader expectations around midnight ET and around DST transitions if used for reporting/ops. | `nautilus_gold_scalper/src/signals/news_calendar.py:285-310` | If the intent is “today in ET”, compute boundaries in `America/New_York` then convert to UTC for comparisons. |
| P04-B-004 | MEDIUM | `diff_minutes = int(diff_seconds / 60)` truncates toward zero, slightly **expanding** blackout/window edges by up to ~59 seconds, especially on the “after release” side. | `nautilus_gold_scalper/src/signals/news_calendar.py:421-423`, `:456-490` | If minute-precision is intended, document this behavior; otherwise use exact seconds comparisons or floor/ceil appropriately for before/after. |
| P04-B-005 | LOW | `NewsEvent` contains `forecast/previous/actual` but the calendar currently never populates them; risk of confusion about whether the module supports result-based signals. | `nautilus_gold_scalper/src/signals/news_calendar.py:43-56`, `:161-163` | Clarify contract: calendar provides time-only filtering; result-based logic belongs elsewhere and must be gated to post-release only. |

### Checklist Results
- ✅ Impact classification: explicit enum levels (CRITICAL/HIGH/MEDIUM)
- ⚠️ Buffer times configurable: yes, but split between `NewsCalendar` and per-`NewsEvent` buffers (see cross-module mismatch)
- ⚠️ Historical backtest vs live mode distinction: not implemented
- ⚠️ Fallback when data unavailable: currently “no events → allow trading” (unsafe for live)

### Look-Ahead Verification
- `check_news_window(now=...)` uses only `event.time_utc`, `impact`, and configured buffers. It does **not** read `event.actual`/results.
- Scheduled event timestamps *in the future* are accessed (calendar knowledge), which is acceptable for live trading and many backtests.
- **Risk surface:** if an upstream calendar injects “actual” values before the release time, the calendar does not consume them; look-ahead risk is primarily in `news_trader.py` or in integration code.

### Apex Compliance
- This module does not implement Apex session time gates directly; it can only block around scheduled news events.

## Module: news_trader.py

### Overview
`NewsTrader` is a “news logic” helper which:
- Maintains an internal list of `NewsEvent` objects and blackout windows based on `event.buffer_before_min/after_min`.
- Can produce a post-release `SignalType` from `(actual, forecast, previous)` via `get_news_signal`.
- Contains optional pre-position/straddle/pullback mode scaffolding.

### Findings

| ID | Severity | Issue | Location | Recommendation |
|----|----------|-------|----------|----------------|
| P04-B-006 | **CRITICAL** | **Timezone-aware vs naive datetime mismatch**: the module uses `datetime.utcnow()` (naive) by default, but `NewsEvent.time_utc` is timezone-aware (UTC). Comparing or subtracting these will raise `TypeError` at runtime and can disable all news filtering/signals. | `nautilus_gold_scalper/src/signals/news_trader.py:175-191`, `:193-216`, `:218-254`, `:284-291`, `:318-329`, `:372-376`, `:445-452`, `:654-677` | Standardize on timezone-aware UTC everywhere (`datetime.now(timezone.utc)`), or accept a tz-aware `now` from the caller and validate it. |
| P04-B-007 | MEDIUM | Calendar duplication/key collision: `events_by_time[event.time_utc] = event` will overwrite events with identical timestamps (e.g., NFP and Unemployment Rate released at the same minute). | `nautilus_gold_scalper/src/signals/news_trader.py:161-174` | Use a list per timestamp or key by `(time_utc, event_name)`.
| P04-B-008 | MEDIUM | `update_calendar()` only appends and never de-duplicates, so repeated updates can accumulate duplicates and distort window logic. | `nautilus_gold_scalper/src/signals/news_trader.py:161-170` | Normalize/deduplicate on update (stable key), or replace the calendar snapshot per refresh. |
| P04-B-009 | LOW | Pre-release “bias” logic uses forecast as a proxy for “actual” (`_analyze_news_impact(forecast, forecast, previous)`), which is not economically meaningful and may mislead if used for trading decisions. | `nautilus_gold_scalper/src/signals/news_trader.py:334-339`, `:391-397` | Treat pre-release direction as `UNCERTAIN` unless a separate, defensible model exists; otherwise restrict to filtering only. |
| P04-B-010 | LOW | Null checks are inconsistent with types: `forecast`/`previous` are typed as floats but code checks against `None`. Suggests upstream may pass `None` and that contracts are not strict. | `nautilus_gold_scalper/src/signals/news_trader.py:331-333`, `:390-399` | Tighten typing and validate inputs at boundaries. |

### Checklist Results
- ❌ Timezone handling correct: currently not (naive/aware mismatch)
- ⚠️ Buffer times configurable: yes via per-event buffers, but not clearly aligned with `NewsCalendar` defaults
- ⚠️ Historical backtest vs live mode distinction: not implemented

### Look-Ahead Verification
- `get_news_signal()` explicitly gates result usage: it returns `None` if `now < event.time_utc` or if more than 5 minutes after release. This is correct *if* `now` and `event.time_utc` are comparable (currently they are not due to the tz mismatch).
- There is no guard preventing a caller from passing “future actuals”, but the release-time gate is the primary protection.

### Apex Compliance
- This module does not enforce Apex time gates (4:30/4:55/4:59 ET). Integration must ensure those gates override any news-driven actions.

## Cross-Module Dependencies
- `news_trader.py` imports `NewsEvent`/`NewsImpact` from `news_calendar.py`.
- Buffer policy mismatch: `NewsCalendar` uses its own `(minutes_before_high/after_high/...)` + `blackout_minutes`, while `NewsTrader` uses per-event `buffer_before_min/buffer_after_min`.
  - If both are used simultaneously, the system may apply inconsistent blackout windows depending on which module is consulted.

## Recommendations (Prioritized)
1. **Fix CRITICAL tz-awareness mismatch in `news_trader.py`** so news filtering cannot crash.
2. Make timezone contract explicit: require tz-aware datetimes and define whether inputs are UTC or `America/New_York` (convert using `zoneinfo`, no manual DST).
3. Add a clear live/backtest calendar policy: either reliable data source or conservative fallback (do not silently “allow trading” when calendar is empty in live).
4. Harmonize blackout-window semantics between `NewsCalendar` and `NewsTrader`.
5. Add a minimal look-ahead regression test: ensure result-based signals are impossible pre-release and that timestamps are always tz-aware.
