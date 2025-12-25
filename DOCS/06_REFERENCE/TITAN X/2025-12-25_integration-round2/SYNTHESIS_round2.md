# TITAN X → Our Robot (Nautilus) — Integration Round 2 Synthesis

**Date:** 2025-12-25
**Input:** `DOCS/06_REFERENCE/TITAN X/Titan_X.md`
**Prior study:** `DOCS/06_REFERENCE/TITAN X/2025-12-25_deep-study/`

## Objective
Translate Titan’s *best* ideas into our Nautilus robot in an **Apex-safe** way.

## Non-negotiable constraint (why this is not a port)
Titan’s core “ladder/grid + lot multiplier + breakeven TP” is structurally **negative convexity** and is incompatible with Apex **5% trailing DD from HWM (includes unrealized)**.

We will **not** import:
- cost-averaging into losers
- lot multipliers / martingale-ish scaling
- bidirectional ladders
- removing exits (TP/SL deletion)

(See `SENTINEL_round2.md` and `FORGE_round2.md`.)

## What we *can* adopt (best concepts)
From CRUCIBLE + FORGE + SENTINEL, the safest/highest-value borrow set is:

1) **Portfolio exposure caps ("Max Charts" analogue)**
- Cap concurrent instruments and positions; start with `max_concurrent_instruments=1` until proven safe.
- Value: prevents correlated blow-ups; forces selectivity.

2) **Schedule guard as a first-class entry gate + force-close path**
- Hard ET gates: 4:30 block new entries; 4:55 emergency close; 4:59 flat.
- Value: direct Apex compliance; prevents overnight risk.

3) **News guard (entries only; exits never blocked)**
- Block new entries in pre/post windows; do **not** remove protective exits.
- Value: reduces gap/spread shock exposure.

4) **Volatility-aware pacing (adaptive trade density)**
- Scale cooldown/spacing with volatility (ATR/ATR%).
- Value: prevents overtrading during volatility expansion regimes.

5) **Virtual gating ("ghost" as observe-before-risk-on filter)**
- Use a shadow state machine that only influences *permission to enter*, never triggers averaging.
- Value: reduces early-trend / exhaustion-misread entries if done conservatively.

6) **Stateful risk response ("manager" idea) as policy tiers**
- As DD approaches buffers: reduce size → block entries → flatten.
- Value: matches Apex kill zones and reduces HWM trap risk.

## Minimal tunables (<=8)
To avoid "manager soup" overfit:
- `base_cooldown_s`
- `atr_pacing_mult`
- `max_concurrent_positions`
- `max_concurrent_instruments`
- `daily_dd_halt_pct` (<= 3.0%)
- `trailing_dd_halt_pct` (<= 4.0%)
- `profit_lock_trigger_pct`
- `spread_shock_threshold`

## Where this maps in our codebase (high level)
- Exposure caps: new small module under `nautilus_gold_scalper/src/risk/` + enforcement hook in `src/strategies/gold_scalper_strategy.py`.
- ET gates: reinforce `src/risk/time_constraint_manager.py` usage; ensure forced close bypasses other guards.
- News guard: feed `src/signals/news_calendar.py` into selector/strategy as an entry-only gate.
- Volatility spacing + virtual gate: new modules under `nautilus_gold_scalper/src/signals/`.
- Unified risk policy: small adapter around existing `dd_protection.py`, `circuit_breaker.py`, `prop_firm_manager.py`.

## Falsification-first validation plan (fast)
Before any big refactor:
1) **Exit-always-allowed invariant tests**: schedule/news/DD must never block forced close.
2) **Ablation runs**: add ONE concept at a time; require improvement in survival metrics.
3) **Hostile execution stress**: spread/slippage/latency multipliers; score by termination probability + MC95DD.
4) **Ghost test**: randomize entry while keeping gates; if performance similar, entry logic is placebo.

## Next actions (recommended order)
1) Implement **Exposure Caps + NewsGuard (entry-only) + VolatilitySpacing** (low-risk, high safety value).
2) Implement **Unified RiskPolicy tiers** (single source of truth for “most restrictive wins”).
3) Add **VirtualGate** last (hardest to validate; highest look-ahead risk).

## Artifacts
- `CRUCIBLE_round2.md`
- `FORGE_round2.md`
- `SENTINEL_round2.md`

