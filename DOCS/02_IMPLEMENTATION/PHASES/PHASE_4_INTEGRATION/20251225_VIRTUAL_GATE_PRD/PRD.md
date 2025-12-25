# Virtual Gate + Safety Layer (Titan-inspired, Apex-safe) — PRD

**Date:** 2025-12-25
**Owner:** Franco
**Scope:** `nautilus_gold_scalper/` (Python/Nautilus)

## 1) Problem Statement
Our current strategies have struggled with robustness and Apex survival. We need a **fail-closed safety layer** that:
- Improves survival under hostile execution (spread/slippage/latency)
- Enforces Apex non-negotiables (HWM trailing DD + ET time gates)
- Reduces “bad entries” during volatility expansion/news/spread shock

We want to borrow *safe* concepts from Titan X **without importing grid/martingale mechanics**.

## 2) Non-Negotiable Constraints (MUST)

### 2.1 Forbidden (explicit)
- No cost-averaging into losers.
- No lot-multiplier / martingale scaling.
- No bidirectional ladders.
- Never delete/remove protective exits (TP/SL) near news.
- Exits must never be blocked by entry guards.

### 2.2 Apex compliance
- Canonical timezone: `America/New_York`.
- Block new trades after 4:30 PM ET.
- Emergency close starts 4:55 PM ET.
- Flat by 4:59 PM ET.
- Trailing DD is tracked from **HWM including unrealized**, with conservative BID/ASK marking.
- Hard blocks: trailing DD ≥ 4.0% OR daily DD ≥ 3.0% ⇒ HALT.

## 3) Solution Overview
Implement a **Safety Layer** used by the strategy selector and strategy execution path:

### 3.1 Components
1) **VirtualGate (observe-before-risk-on)**
- A *shadow* state machine producing `gate_ok`, `gate_reason`, optional `gate_score`.
- Inputs: completed bars only + cached features (volatility regime, spread regime, recent stop-outs).
- Output affects only permission to open new entries and/or raises entry threshold.

2) **ExposureCaps (portfolio risk hygiene)**
- Caps on concurrent instruments/positions; start strict.

3) **NewsGuard (entries only)**
- Blocks new entries during configured windows; exits/force-close unaffected.

4) **VolatilitySpacing (density control)**
- Cooldown / minimum spacing scales up with volatility.

5) **UnifiedRiskPolicy (single source of truth)**
- Merges DD, time gates, market-quality, and data-integrity into one policy surface:
  - `can_open_new`
  - `size_factor`
  - `must_flatten`
  - `halt_reason`

## 4) Requirements

### 4.1 Functional requirements
- The strategy must call Safety Layer before any new order submission.
- Safety Layer decisions must be logged via telemetry with reasons.
- Force-close path must bypass all entry-blocking guards.

### 4.2 Invariants (must be test-protected)
- **Exit-always-allowed:** no guard can block forced close.
- **No grid re-entry:** cooldown/spacing cannot be implemented as repeated add-to-loser logic.
- **Temporal correctness:** VirtualGate and volatility features use completed bars only (no look-ahead).
- **Determinism:** given same event stream, VirtualGate decisions are identical.

## 5) Tunables (keep ≤ 8)
- `base_cooldown_s`
- `atr_pacing_mult`
- `max_concurrent_positions`
- `max_concurrent_instruments`
- `daily_dd_halt_pct` (<= 3.0)
- `trailing_dd_halt_pct` (<= 4.0)
- `profit_lock_trigger_pct`
- `spread_shock_threshold`

## 6) Out of Scope
- Any Titan-style ladder/grid implementation.
- Any replication of third-party proprietary code.

## 7) Validation Plan (definition of done)

### 7.1 Unit tests
- Time gates (ET) transitions.
- HWM/trailing DD math (conservative marking) + range assertions.
- VirtualGate temporal contract + determinism.
- NewsGuard window math.
- ExposureCaps counting rules.

### 7.2 Integration tests
- With `in_news_window=True`, entries blocked but forced close executes.
- After 4:55 PM ET, forced flatten triggers regardless of other guards.
- DD breach triggers HALT + flatten.

### 7.3 Empirical “fastest disproof” backtests
- Ablation: add one component at a time and measure survival metrics.
- Hostile execution stress (spread/slippage/latency multipliers).
- Ghost test: randomize entry, keep gates; if similar survival, entry logic is placebo.

## 8) Deliverables
- PRD (this document)
- Test checklist document
- Implementation plan (phased)
- After implementation: backtest report showing survival improvements or falsification
