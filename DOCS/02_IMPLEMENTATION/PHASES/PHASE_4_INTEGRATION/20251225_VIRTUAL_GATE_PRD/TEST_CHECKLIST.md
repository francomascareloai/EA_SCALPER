# Virtual Gate + Safety Layer — Test & Invariants Checklist

**Date:** 2025-12-25
**Purpose:** Convert CRITIC gate concerns into enforceable invariants + minimal tests.

## A) Non-negotiable invariants (must always hold)

### A1. Exit-always-allowed
- Invariant: NewsGuard / VirtualGate / ExposureCaps / VolatilitySpacing **must never** block forced close.
- Invariant: TimeConstraintManager and DD breach paths bypass entry-only guards.

### A2. No grid / no martingale
- Invariant: Strategy must not open additional positions just because price moved against an open position.
- Invariant: Any “cooldown/spacing” logic cannot be used to schedule repeated re-entries into a loser.

### A3. Temporal correctness (no look-ahead)
- Invariant: VirtualGate uses **completed bars only** and data timestamps strictly < decision time.
- Invariant: ATR/volatility regime features use completed bars; no `center=True`-style future leakage.

### A4. Determinism
- Invariant: Given identical event stream (ticks/bars + news schedule), gate outcomes are identical.

### A5. Apex compliance
- Invariant: Canonical timezone is `America/New_York`.
- Invariant: 4:30 PM ET blocks new entries; 4:55 PM ET triggers emergency close; 4:59 PM ET must be flat.
- Invariant: HWM includes unrealized PnL (conservative BID/ASK marking).

## B) Unit tests (minimum set)

### B1. Time gates
- Assert: `can_open_new` flips to false after 4:30 PM ET.
- Assert: `must_flatten` becomes true at/after 4:55 PM ET.
- Assert: flattened by/at 4:59 PM ET in simulated timeline.

### B2. Trailing DD / HWM math
- Assert: `trailing_dd_pct = (hwm - equity) / hwm * 100` with `hwm > 0`.
- Assert: LONG uses BID and SHORT uses ASK for unrealized marking.
- Assert: dd is within [0, 100].

### B3. News window math (entry-only)
- Assert: entries blocked inside blackout.
- Assert: exit/force-close not blocked during blackout.

### B4. Exposure caps
- Assert: when max instruments/positions reached, new entry rejected with reason.
- Assert: closing/flattening still allowed.

### B5. Volatility spacing monotonicity
- Assert: spacing/cooldown increases with volatility.
- Assert: spacing bounded by min/max.

### B6. VirtualGate temporal contract + determinism
- Assert: uses completed bar timestamps only.
- Assert: repeated evaluation produces identical outputs.

## C) Integration tests (minimum set)

### C1. Force-close bypass
Scenario: `in_news_window=True` AND time >= 4:55 PM ET.
- Expectation: forced close orders are submitted.

### C2. DD breach bypass
Scenario: `trailing_dd_pct >= 4.0`.
- Expectation: HALT + flatten triggers; no further entries; exits proceed.

### C3. Gate composition precedence
Scenario: multiple gates disagree.
- Expectation: “most restrictive wins” for entries; “must_flatten wins” globally.

## D) Fastest disproof empirical checks (before scaling)

### D1. Ablation
- Baseline vs +ExposureCaps vs +NewsGuard vs +VolSpacing vs +VirtualGate.
- Stop if survival metrics do not improve.

### D2. Hostile execution
- Stress: spread×{2,3}, slippage×{3,5}, latency×{5,10}.
- Evaluate termination probability under Apex constraints.

### D3. Ghost test
- Randomize entry, keep safety layer.
- If results ~same, entry logic is placebo → prioritize safety layer, then redesign signals.
