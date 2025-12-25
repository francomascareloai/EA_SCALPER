# SENTINEL Round 2 — Apex Compliance & Risk Hardening Plan (Titan concepts, safe-only)

**Date:** 2025-12-25

## Objective
Adopt ONLY Titan-derived *defensive controls* (gating, scheduling, exposure caps, telemetry) while staying strictly compliant with **Apex trailing DD (HWM includes unrealized)** and **flat by 4:59 PM ET**.

## Explicitly Forbidden (non-negotiable)
1) Any **grid / cost-averaging into losers** (adding size because price moved against us).
2) Any **lot multiplier / martingale-ish scaling** (including “interval multipliers” and rounding rules that force growth).
3) **Bidirectional ladders** (simultaneous long+short exposure stacks).
4) **Stacked ladders** (adding trades into profit *and* drawdown).
5) **Removing protective exits** (deleting TP/SL around news or any window).
6) Any live trade without **broker-side (server-side) SL** set at order entry.
7) Any “hedge” leg that can **cost-average** or **ignore its own stop**.
8) Any schedule/time logic not anchored to `America/New_York`, or operating with unknown clock drift.

## Safe Titan Concepts We CAN Adopt (defensive controls)
- **Virtual gating (“ghost trades”) as a filter only:** observe/score conditions before risk-on; never as a trigger to averaging.
- **Volatility-aware spacing:** reduce trade frequency when volatility/noise expands; never used to justify adding to losses.
- **Exposure caps + stateful risk response (“managers”):** rule-based switching to reduce risk, block entries, or force-close.

## Apex Guardrails (invariants)
### A) Trailing DD / HWM (Apex killer)
- **HWM includes unrealized P/L tick-by-tick.**
- **Conservative marking:** LONG uses **BID**, SHORT uses **ASK** for unrealized.
- **Formulas (must match runtime code):**
  - `floor = hwm * 0.95`
  - `trailing_dd_pct = (hwm - equity) / hwm * 100` (require `hwm > 0`)
- **Hard blocks (project taxonomy):**
  - Trailing DD ≥ **4.0%** → **HALT** (no new trades; flatten per playbook).
  - Trailing DD ≥ **4.5%** → **HALT ALL + force close** (no trading path out).

### B) Daily DD (session risk)
- Daily DD ≥ **3.0%** → **HALT**.
- Dynamic daily risk budget:
  - `remaining_buffer_pct = 5.0% - trailing_dd_pct`
  - `max_daily_dd_pct = min(3.0%, remaining_buffer_pct * 0.6)`

### C) ET time gates (Apex hard rule)
- **Block new trades after 4:30 PM ET.**
- **Emergency force-close starts 4:55 PM ET.**
- **Flat by 4:59 PM ET.**
- If time source is uncertain: block **4:20 PM ET**, emergency close **4:45 PM ET**.

### D) News windows
- **Block new entries** in configured pre/post windows for high-impact events.
- **Exits always allowed** (close/modify allowed; SL deletion forbidden).

## Portfolio Exposure Caps (caps, not suggestions)
- **Per-order cap:** worst-case loss to SL must fit the current buffer: `daily_dd + trade_risk <= max_daily_dd`.
- **Per-symbol (XAUUSD) cap:** max concurrent positions **1**, single direction only; no re-entry while position is losing.
- **Account/portfolio cap:** max concurrent instruments **1** until MC survival proves expansion is safe.
- **Consistency (LIVE best practice):** stop trading for the day if realized profit exceeds **30%** of the remaining profit target.

## Kill-switches (fail-closed triggers)
If any trigger fires: **ENTRY OFF** immediately, and execute the action.
- **DD:** trailing ≥ 4.0% or daily ≥ 3.0% → **HALT + flatten**.
- **Time:** ≥ 4:55 PM ET → **force close all**.
- **Market quality:** spread blowout, repeated rejections, abnormal slippage → **entry off + alert**; flatten if DD elevated.
- **Data integrity:** stale feed, timezone offset unexpected, HWM/DD math invalid (NaN/negative) → **entry off + alert**.

## Failure Modes (pre-mortem)
- **HWM trap:** unrealized peak raises floor; reversal terminates despite small net loss.
- **News gap/spread shock:** exits fill worse than modeled.
- **Clock/TZ error:** trading past 4:59 PM ET.

## Validation (must pass before live)
- Unit tests for HWM/trailing+daily DD math, ET gate transitions, and “exit-always-allowed” invariant.
- Monte Carlo survival under hostile execution (spread/slippage/latency): PASS requires termination probability ~0 and **MC95DD < 4%**.

## Next Step
Centralize these rules into a single risk policy module (single source of truth), then run a small-slice backtest focused on **survival**, not returns.
