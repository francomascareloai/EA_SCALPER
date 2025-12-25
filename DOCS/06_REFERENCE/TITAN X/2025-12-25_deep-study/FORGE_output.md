AGENT: FORGE-NAUTILUS
VERSION: 1.1
CLAUDE_MD_VERSION: 3.10.9
STATUS: COMPLETE

# Deep Study (Implementation Engineer) — Titan_X.md → Generic Nautilus Modules

## DECISION
Two viable designs:
- Option A (pick): Single `PortfolioGridStrategy` that manages per-(instrument, side) ladder state, composed of pure-Python modules (EntryPolicy, LadderPlanner, RiskPolicyEngine, ScheduleGuard, NewsGuard, Telemetry). Best for determinism and testability.
- Option B: Per-instrument ladder Strategy + shared AccountRiskActor (portfolio caps/goals). Better separation, higher integration complexity.

Chosen: Option A. It preserves modularity while avoiding inter-component event plumbing early.

## FEATURE → MODULE MAP (generic, not Titan-specific)
1) Entry filters (start-trade gating)
- `EntryPolicy` (predicate pipeline with scopes):
  - Direction allowlist (long/short/both)
  - Candlestick bias filter (completed higher-TF bar)
  - MA regime filter (+ “entry delay” lockout until opposite-cross)
  - RSI threshold filter (trend/counter-trend semantics)
  - Spread filter (quote-derived)
  - Max-active-instruments (“max charts”)
  - Ghost/virtual ladder trigger (see below)

2) Ladder / grid manager
- `LadderState` per (instrument, side): levels, avg price, net qty, realized/unrealized PnL, timestamps.
- `LadderPlanner` (pure function): state + market snapshot → desired next action:
  - next level distance: pip-step types: fixed, dynamic(ATR aggregation), time-based, stacked
  - lot sizing: fixed / balance+leverage risk-based / auto-scale compounding
  - lot multiplier with interval + rounding + max-lot cap
  - max levels hard stop
  - take-profit anchored to breakeven (net position) + offset

3) Risk managers (Yoga/Lipo/Amp + equity protectors)
- `RiskPolicyEngine` returning explicit Actions with priority order:
  - FORCE_CLOSE_ALL (account) / FORCE_CLOSE_PAIR / PAUSE_START_TRADES / ALLOW_CA_ONLY / ALLOW
  - Yoga-like: when drawdown high, allow managing existing ladders but pause new ladders after a TP event until drawdown recovers.
  - Lipo-like: when exceeding a level threshold, close earliest/smallest level before adding new level.
  - Amp-like: when level count high AND account DD% above threshold, amputate (close all in that direction/instrument), then cooldown.
  - Account goals: daily/weekly profit targets and stop-after-target behavior.

4) Schedule & sessions
- `ScheduleGuard`:
  - Trading-day allowlist
  - Session windows with end actions (close-all / pause-start / nothing)
  - “pause after date/time once TP hit” (power-down behavior)

5) News filter
- `NewsGuard`:
  - Event ingestion abstraction (calendar provider) + per-impact actions.
  - Before/after windows that affect ENTRY vs MODIFY vs CLOSE separately (exits must remain allowed for safety).

6) Telemetry
- `TelemetryBus`:
  - Structured events: ladder_opened/level_added/tp_moved/risk_halt_triggered/news_pause_on/off.
  - Snapshot exporter for: levels, current pip step, margin-to-goals, current policy state.

## REQUIRED INVARIANTS (must hold always)
- Temporal correctness: all filters using candles/ATR must use completed bars only; no future data.
- Determinism: given identical event stream, LadderPlanner output is identical.
- Normalization: every computed quantity and price is normalized to instrument increment rules before submission.
- Safety precedence: force-close actions override schedule/news pauses; exits never blocked.
- Ladder accounting: breakeven/TP is computed from net position (qty-weighted avg) and matches actual orders.
- State consistency: ladder level count equals number of open child orders/positions attributed to that ladder.

## TESTS (unit + integration)
Unit (pure modules):
- `LadderPlanner`: next-level distance across step modes; lot multiplier interval + rounding rules; max-lot cap; max-level stop.
- `EntryPolicy`: scope rules (start-only vs CA-only vs all); MA-entry-delay lockout; candlestick bias on higher TF.
- `RiskPolicyEngine`: precedence ordering; Yoga/Lipo/Amp triggers; cooldown timing; goal thresholds.
- `ScheduleGuard`/`NewsGuard`: window math; action selection; “entry blocked but exit allowed”.

Integration (Nautilus backtest harness):
- Multi-instrument cap: ensure max-active-instruments enforced.
- Bidirectional ladders: independent states per side; no cross-contamination.
- News window: no new entries during window; forced close still executes.
- Goal hit: closes correct scope (pair vs account) and halts/resets per configuration.

## AMBIGUITIES / CLARIFICATIONS NEEDED
- “Pips” definition per instrument (XAUUSD often uses points/ticks): convert rules must be explicit.
- Dynamic pip step ATR(3) aggregation: exact ATR definition, price type, and handling of missing TF bars.
- “Breakeven point is halfway between first and last trade” (ghost trades): conflicts with qty-weighted breakeven; which is intended?
- Ghost trade trigger semantics: when GT max levels reached, do we trigger immediately at market, at next bar close, or on price touch?
- “Chart floating profits” scope: per-instrument? per-strategy instance? includes realized PnL?
- Weekly/daily baselines: how to define start balance/equity under deposits/withdrawals in a broker-agnostic system.
- News source: if not ForexFactory, what canonical event schema (timezones, impacted currencies, impact levels) is required?

## RISKS (1st/2nd/3rd ORDER)
- 1st: Incorrect unit conversions (pip/tick) causes runaway ladder density.
- 2nd: Conflicting policy rules without clear precedence creates non-reproducible behavior.
- 3rd: Portfolio-level halts/goals implemented per-instrument can leak exposure across symbols.

## NEXT STEP
Write a requirements questionnaire covering the ambiguities above and define the minimal integration test scenarios (multi-instrument, bidirectional, news, schedule, goal/stop) before any coding.
