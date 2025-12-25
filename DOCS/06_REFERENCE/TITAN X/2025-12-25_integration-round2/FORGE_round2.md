# FORGE – Titan X Integration Round 2 (Architecture-Only)

Goal: map *adoptable* Titan X concepts (from `Titan_X.md` + deep-study `SYNTHESIS.md`) into our NautilusTrader codebase without copying proprietary implementation. Focus is **guards, telemetry, risk engine, selector**.

## Decision
Option A (chosen): integrate Titan ideas as **small, testable guards/policies** wired into existing gates (risk + selector), while explicitly rejecting Titan’s ladder/multiplier core.

Option B (rejected for now): create a monolithic “Titan layer” and route all behavior through it (higher churn, duplicates existing risk modules).

## Non-adoptable (explicit NO-GO)
- **Cost-averaging ladders / martingale / lot multipliers / BE-zone TP mechanics** are structurally incompatible with Apex **5% trailing DD from HWM (includes unrealized)**. We will not port these mechanics.

## Adoptable concepts → where they live

### 1) Portfolio exposure caps (“Max Charts” analogue)
**Concept:** cap concurrent exposure to avoid correlated blow-ups.

**Target modules/files:**
- `/home/franco/projetos/EA_SCALPER_XAUUSD/nautilus_gold_scalper/src/risk/` (new small module)
- `/home/franco/projetos/EA_SCALPER_XAUUSD/nautilus_gold_scalper/src/strategies/gold_scalper_strategy.py` (enforcement hook)
- `/home/franco/projetos/EA_SCALPER_XAUUSD/nautilus_gold_scalper/src/strategies/strategy_selector.py` (Gate 1 input: `exposure_ok`)

**Smallest code changes:**
- Add `risk/exposure_caps.py` with a config (e.g., `max_active_instruments`, `max_open_positions`) and `validate_portfolio(cache)` returning `(ok, reason, metrics)`.
- In strategy, before submitting any *new* order: compute `exposure_ok` and pass into selector/safety gate; block entries if not ok.
- Emit telemetry event when blocked.

**Test checklist:**
- Unit: given mocked open positions, verify distinct instrument counting and blocking at threshold.
- Unit: ensure “pending close” does not count as new exposure (define rule explicitly).
- Integration: multi-instrument backtest harness (or simulated cache) confirms 4th instrument entry is rejected while existing positions still managed/closed.

### 2) Schedule controls (Apex time gates) as first-class guard
**Concept:** time-based “power down” with hard flatten deadline.

**Already exists:**
- `/home/franco/projetos/EA_SCALPER_XAUUSD/nautilus_gold_scalper/src/risk/time_constraint_manager.py`

**Smallest code changes:**
- Ensure strategy calls `TimeConstraintManager.can_open_new(ts_ns)` for entry gating, and `check(ts_ns)` for forced flatten path (already designed as separate concerns).
- Add a single “policy surface” so other gates cannot accidentally override forced close.

**Test checklist:**
- Unit: time conversions ET (DST-aware) for 4:30 block, 4:55 emergency, 4:59 cutoff.
- Integration: simulate tick timestamps around gates; verify: entries blocked after 4:30 ET; forced close submitted at/after 4:55/4:59 even if other guards would block trading.

### 3) News gating (entries only; exits never blocked)
**Concept:** news windows are dangerous; Titan can block both open/close—*we must not*.

**Target modules/files:**
- `/home/franco/projetos/EA_SCALPER_XAUUSD/nautilus_gold_scalper/src/signals/news_calendar.py` (source of windows)
- `/home/franco/projetos/EA_SCALPER_XAUUSD/nautilus_gold_scalper/src/strategies/strategy_selector.py` (Gate 3)
- `/home/franco/projetos/EA_SCALPER_XAUUSD/nautilus_gold_scalper/src/strategies/gold_scalper_strategy.py` (entry-only enforcement)

**Smallest code changes:**
- Introduce a `NewsGuard` concept (can be a thin function/class) that outputs `can_open_new` and a severity/penalty.
- Wire into selector context: if in blackout → `can_trade=False` for *new entries* only.
- Explicit invariant: forced close path (TimeConstraintManager / DD breach) bypasses news guard.

**Test checklist:**
- Unit: blackout window math (before/after minutes).
- Integration: with `in_news_window=True`, verify no new orders submitted; then trigger time cutoff and confirm close orders are still submitted.

### 4) Volatility-aware spacing (adaptive trade density)
**Concept:** adjust entry spacing/cooldown with volatility regime (Titan: multi-TF ATR average).

**Target modules/files:**
- `/home/franco/projetos/EA_SCALPER_XAUUSD/nautilus_gold_scalper/src/signals/` (new policy module)
- `/home/franco/projetos/EA_SCALPER_XAUUSD/nautilus_gold_scalper/src/signals/trend_follow.py`
- `/home/franco/projetos/EA_SCALPER_XAUUSD/nautilus_gold_scalper/src/signals/mean_revert.py`
- Optionally `/home/franco/projetos/EA_SCALPER_XAUUSD/nautilus_gold_scalper/src/signals/entry_optimizer.py`

**Smallest code changes:**
- Add `signals/volatility_spacing.py` that computes `min_distance_pips` and/or `min_time_between_entries` from ATR/ATR% (single TF first; multi-TF optional).
- Apply as a filter: candidate rejected if too close to last entry price/time for current volatility bucket.

**Test checklist:**
- Unit: spacing increases monotonically with ATR; bounds (min/max spacing) enforced.
- Unit: multi-TF aggregation uses only completed bars from cache (no look-ahead).
- Integration: compare candidate counts across low/high volatility slices; ensure behavior is stable and does not block forced exits.

### 5) Virtual gating (“Ghost Trades” as observe-before-risk-on)
**Concept:** use a virtual process as a *filter* against starting risk into strong trends.

**Target modules/files:**
- `/home/franco/projetos/EA_SCALPER_XAUUSD/nautilus_gold_scalper/src/signals/` (new module)
- `/home/franco/projetos/EA_SCALPER_XAUUSD/nautilus_gold_scalper/src/strategies/strategy_selector.py` (add fields)

**Smallest code changes:**
- Create `signals/virtual_gate.py` producing `ghost_ok`, `ghost_bias`, `ghost_confidence` using only bar + past state (no TP/BE ladder logic).
- StrategySelector Gate 1/6: if `ghost_ok=False`, block entries or require higher execution threshold.

**Test checklist:**
- Unit: state machine transitions (ok→blocked→reset) on completed bars only.
- Unit: determinism (same input bars → same gate decisions).
- Integration: “ghost test” ablation run: replace gate signal with random baseline to check if it adds real value (as per SYNTHESIS).

### 6) Stateful risk response (“managers” as policy switching)
**Concept:** switch behavior as risk grows (size cuts, blocks, cool-downs).

**Already exists (partial):**
- `/home/franco/projetos/EA_SCALPER_XAUUSD/nautilus_gold_scalper/src/risk/dd_protection.py`
- `/home/franco/projetos/EA_SCALPER_XAUUSD/nautilus_gold_scalper/src/risk/circuit_breaker.py`
- `/home/franco/projetos/EA_SCALPER_XAUUSD/nautilus_gold_scalper/src/risk/prop_firm_manager.py`

**Smallest code changes:**
- Add a single “RiskPolicy” adapter (new `risk/risk_policy.py` or a small method in PropFirmManager) that merges: DDProtectionState + CircuitBreakerLevel + TimeConstraintManager.
- Precedence rule: **most restrictive wins**; expose `can_open_new`, `size_factor`, `halt_reason`.
- Emit telemetry on policy transitions.

**Test checklist:**
- Unit: precedence matrix (DD halt overrides everything; time cutoff overrides all; circuit cooldown blocks entries but not forced exits).
- Unit: boundary thresholds (3.0/3.5/4.0/4.5/5.0) and dynamic daily cap.
- Integration: simulate equity path crossing thresholds; assert expected mode transitions + telemetry events.

## Telemetry (cross-cutting)
**Already exists:** `/home/franco/projetos/EA_SCALPER_XAUUSD/nautilus_gold_scalper/src/utils/telemetry.py`.

**Smallest code changes:** standardize event names/fields for: `entry_blocked` (reason + gate), `risk_policy_change`, `news_blackout`, `exposure_cap_hit`, `vol_spacing_block`, `apex_cutoff`.

## Risks (1st/2nd/3rd order) + mitigations
- 1st: accidentally blocking exits (news/schedule) → split `can_open_new` vs `force_close`, ensure TimeConstraintManager path is independent.
- 2nd: look-ahead bias in multi-TF ATR/virtual gate → only use completed bars from cache; unit tests for determinism.
- 3rd: selector bloat → keep new concepts as small modules; selector only consumes booleans/metrics.

## Next step
If you want Round 3 implementation: start with **Exposure Caps + NewsGuard + VolatilitySpacing** (lowest risk, highest safety value), then add VirtualGate.
