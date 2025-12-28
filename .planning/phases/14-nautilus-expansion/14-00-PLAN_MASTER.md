# Phase 14 — Nautilus Expansion (MASTER PLAN)

Created: 2025-12-27
Last updated: 2025-12-28
Status: ACTIVE (triaged with CRITIC/NAUTILUS/FORGE value review)

This plan is intentionally exhaustive. It preserves the full scope discovered in NautilusTrader docs/examples and turns it into an implementation program that avoids retrabalho.

## Scope sources (full annexes, durable)

These files are the durable “scope dump” from subagents and are authoritative for scope:

- `/.planning/phases/14-nautilus-expansion/orchestration/EXECUTION_ALGOS_AND_ORDERS.md`
- `/.planning/phases/14-nautilus-expansion/orchestration/RISK_ENGINE_AND_SIZING.md`
- `/.planning/phases/14-nautilus-expansion/orchestration/DATA_HANDLING_AND_CACHING.md`
- `/.planning/phases/14-nautilus-expansion/orchestration/NATIVE_INDICATORS.md`
- `/.planning/phases/14-nautilus-expansion/orchestration/STRATEGY_PATTERNS_AND_ACTORS.md`
- `/.planning/phases/14-nautilus-expansion/orchestration/PORTFOLIO_AND_ACCOUNT.md`

## Review artifacts (durable)

These contain the review outputs which drove the changes below:

- `/.planning/phases/14-nautilus-expansion/orchestration/CRITIC_REVIEW.md`
- `/.planning/phases/14-nautilus-expansion/orchestration/FORGE_REVIEW.md`
- `/.planning/phases/14-nautilus-expansion/orchestration/CRUCIBLE_REVIEW.md`

---

# Executive Objective

Turn `nautilus_gold_scalper/` into a production-grade “machine” by implementing the full set of NautilusTrader features discovered, while maintaining Apex safety invariants and preventing overfit.

Capabilities in-scope (exhaustive scope; annex-backed):

1. Risk hardening (RiskEngineConfig rate limits + max notional + enforcement tests)
2. Position sizing upgrade (adapter to Nautilus FixedRiskSizer without breaking existing sizing policy)
3. Execution hardening (TWAP integration + order mgmt patterns) with strict time-gate safety
4. Indicator suite integration (KeltnerPosition / VWAP / Pressure / EfficiencyRatio / FuzzyCandlesticks) as gates/penalties first
5. Data fidelity upgrades (Renko + aggregation options + iterator patterns)
6. Signal bus architecture (publish/subscribe + custom data) to decouple regime/risk from execution
7. Controller orchestration (multi-strategy) — deferred until safety and event semantics are proven
8. Persistence + recovery (on_save/on_load) — promoted earlier because it’s safety-critical
9. Portfolio/account reporting — last, and explicitly non-authoritative for risk decisions

## 2025-12-28 Triage (CRITIC + NAUTILUS + FORGE)

This plan intentionally contains the *full discovered scope* (annexes). But shipping everything is not automatically “better”.

We operate with two layers:
- **Exhaustive scope (reference)**: annexes listed at the top (what exists in Nautilus and could be integrated).
- **Authoritative roadmap (action)**: the prioritized sequence below (what we actually implement next).

### Clarification: “multi-strategy” vs “controller”

There are two different meanings people mix:

1) **Multi-mode inside a single Strategy** (already present)
- SMC / Trend-follow / Mean-revert are *multiple decision templates* living inside one Strategy process.
- This can already be “multi-strategy” in the trading sense (multiple edges), without adding orchestration topology.

2) **Multi-strategy orchestration via a Nautilus Controller** (not the same thing)
- A Controller is lifecycle/portfolio orchestration: create/start/stop strategies, coordinate shared exposure, unify risk budgets.
- This adds failure modes (stale state, cross-strategy coupling, stop-path bugs) and creates new Apex blow-up paths if not proven.

So the question is not “do we want multiple edges?” (yes) — it’s “do we need a Controller topology now?” (only if we can prove net survival improvement).

### When a Controller becomes justified (gating criteria)

We implement a Nautilus Controller only if at least one is true:

- **Operational need**: we must start/stop strategies independently (e.g., staged rollouts, kill-switch per mode) and we cannot do it safely within a single Strategy.
- **Portfolio-level risk budgeting**: we need a shared risk budget across modes which cannot be expressed cleanly in the current `UnifiedRiskPolicy`.
- **Proven tail-risk reduction**: empirical evidence (Monte Carlo survival under Apex trailing DD constraints) shows the Controller topology reduces blow-up probability vs the single-strategy multi-mode design.

Hard requirements if we ever add Controller:
- Emergency close remains a **top-level** enforcement path (not stoppable by Controller/strategy lifecycle).
- Controller decisions apply **next bar only** (no same-bar regime/controller switches).
- The Controller adds **near-zero tunables** (avoid a new optimization surface).

### Decision matrix (value vs complexity)

Rules of thumb used by all 3 reviewers:
- Safety/ops guardrails (engine-level risk limits, notional caps) are high ROI.
- Execution state machines (TWAP/child orders) and data transforms (Renko) are high risk unless slippage/noise is a proven bottleneck.
- New indicators are *assumed overfit* until falsification tests prove otherwise.

| Area | Problem it solves | Main upside | Main downside | Verdict |
|---|---|---|---|---|
| Phase B: RiskEngineConfig hardening | Order spam + fat-finger notional | Apex survival ↑ (tail risk ↓) | Misconfig can block orders | **IMPLEMENT (MUST)** |
| Phase C: FixedRiskSizer adapter | Standardize sizing math | Possible code deletion | Silent sizing distribution shift | **DEFER (only if it deletes code)** |
| Phase D: TWAP entries | Reduce impact/slippage | Potential slippage ↓ | Deadline/time-gate interactions; partial fills | **DEFER (experimental)** |
| Phase E: 5 indicators | More confluence inputs | Maybe fewer bad trades | Parameter/overfit explosion | **SKIP by default** |
| Phase F: Renko mode | Noise reduction | Cleaner structure (maybe) | Look-ahead + fill realism risk | **DEFER (experiment-only)** |
| Phase G: Signal bus | Decouple + observability | Debuggability ↑ | Stale/out-of-order data | **DEFER / MINIMAL (telemetry)** |
| Phase H: Controller | True multi-strategy topology | Portfolio orchestration | Correlation blow-ups + stop-path bugs | **SKIP for now** |
| Phase J: Reporting | Post-mortems + drift detection | Faster iteration, fewer blind spots | Wrong accounting/timezone lies | **DEFER (keep tight)** |

### Hard gates (falsification-first, before shipping complexity)

These are mandatory “fastest disproof” gates:

1) **GHOST TEST (edge attribution)**
- Replace the entry signal with random direction/timing while keeping *all* existing gates (time/DD/circuit breaker/spread).
- If performance remains positive/acceptable → signals/indicators are not the edge; filters/risk are.
- Action: stop adding indicators and focus on risk + execution realism.

2) **Apex survival (tail-risk first)**
- Required improvements must be reported as ΔMC95DD and survival probability under Apex trailing DD constraints.
- Any feature which improves Sharpe but worsens MC95DD/survival is rejected.

3) **Time-gate invariants (structural safety)**
- Nothing may weaken the hard invariants:
  - Block new trades after 4:30 PM ET.
  - Emergency close from 4:55 PM ET.
  - Flat by 4:59 PM ET.
- Any execution feature (TWAP, Controller) must be provably overrideable by the emergency close path.

4) **Complexity budget**
- Any new feature which adds tunables must delete others or stay behind a default-OFF toggle.
- If a human cannot explain “why did we trade?” quickly from logs, complexity is too high.

### Roadmap (authoritative for implementation)

1. **Phase B (MUST)**: finish RiskEngineConfig hardening + tests proving enforcement.
2. **Run GHOST TEST**: decide if “signals” add edge beyond filters.
3. **Phase G (optional, minimal)**: add/keep signal bus as *telemetry* only (state-change events), not as core decision wiring.
4. **Phase D (optional)**: TWAP only if we can prove entry slippage is materially hurting (and keep it OFF by default).
5. **Phase F (optional)**: Renko as an isolated experiment only after strict look-ahead + hostile-cost tests.
6. **Phase E (optional)**: indicators only one-at-a-time, only if they replace equivalent math and pass falsification.
7. **Phase J (later)**: reporting when it directly supports decisions/kill-switches.
8. **Phase H (last)**: Controller only if we truly need multi-strategy lifecycle management *and* it improves Apex survival.

---

# Global Non-Negotiables

## A) Apex / Prop constraints (authoritative)

Per `CLAUDE.md`:
- Trailing DD is from **High-Water Mark** and includes unrealized PnL.
- No overnight positions: close all by 4:59 PM ET.
- Time gate: block new trades after 4:30 PM ET; emergency close from 4:55 PM ET.
- HWM must be conservative:
  - LONG: unrealized uses **BID** as exit basis
  - SHORT: unrealized uses **ASK** as exit basis
  - NEVER use mid

## B) “Close always wins” policy (CRITIC requirement)

Emergency close must remain possible even under throttles/limits.

Implementation rule:
- Any limits we add (rate limits, notional caps, throttlers) must not prevent:
  - canceling orders
  - reducing-only closing positions
  - time-gate emergency close

Plan requirement:
- Introduce an explicit emergency close path whose acceptance criteria is:
  - Flat by 4:59 PM ET (test-enforced)
  - Even when rate limits are tight and even when some closes are rejected/partial

## C) TWAP safety policy (CRITIC requirement)

TWAP is **for smoothing**, not for deadline close.

Hard rule:
- After **4:55 PM ET**: emergency close uses immediate orders only (market/IOC reduce-only). No TWAP slicing.

Allowed:
- TWAP may be used **only when time-to-deadline is comfortably large** (configurable) and only for:
  - large entries (if any)
  - risk-off reduces earlier in the session

## D) Timekeeping contract (CRITIC requirement)

Per `CLAUDE.md` timekeeping_contract:
- Canonical timezone: `America/New_York`.
- Never manually calculate DST.
- Validate clock drift at startup and use degraded earlier close if uncertain.

## E) API verification gate (CRITIC + FORGE requirement)

Before implementing phases which rely on Nautilus APIs:
- Verify method signatures and availability in the installed Nautilus version (site-packages).
- If a method is referenced in annexes but differs in installed version, installed version wins.

This is a hard gate for:
- Risk engine runtime access methods
- ExecAlgorithm registration and IDs
- Strategy on_save/on_load signatures
- DataType / custom Data publish/subscribe

## F) Performance cadence (CRITIC requirement)

Explicitly constrain compute frequency:
- Tick-driven: drawdown/HWM tracking; time-gate checks
- Bar-driven: heavy indicator/regime calculations
- Never do pandas-heavy work in hot paths

Add microbench/profiling assertions where feasible (or at minimum: unit tests asserting functions do not allocate large objects on hot path).

## G) Overfit containment (CRUCIBLE requirement)

Indicator additions must default to being **risk reducers** (filters/gates) rather than “edge creators”.

Rules:
- Freeze canonical defaults where possible.
- Avoid “weight soup”: use stage gates + capped penalties.
- Each added component must justify itself with falsification-first tests.

---

# Phase 0 — Safety lockdown (tests-first) + API verification

This phase is inserted per CRITIC/FORGE; it must happen before we add more complexity.

## 0.1 Apex invariants test suite (must-have)

Add/extend tests to lock down the safety properties:

1) HWM monotonicity + conservative marking
- HWM never decreases within a session.
- LONG uses BID; SHORT uses ASK for unrealized.
- Trailing DD formula correctness.

2) Emergency close survival (4:55–4:59)
- Simulate a time window 4:55–4:59 with an open position.
- Add rate limits / notional caps.
- Assert the system is flat by 4:59, even if some close attempts are partial/rejected.

3) Risk config applied
- Configure a small `max_notional_per_order`.
- Intentionally oversize an order.
- Assert RiskEngine rejects it (fail hard if it slips through).

4) Renko look-ahead guard
- Ensure any decision made at event time T uses only information <= T.
- Enforce “decide on close, act next bar” for regime/controller.

## 0.2 Timekeeping contract enforcement

Add tests/logic to ensure:
- timezone conversions use `America/New_York`
- DST handled by system tz library (zoneinfo/pytz, no manual math)
- degraded earlier close behavior when drift/uncertainty is detected

## 0.3 API verification gate (implementation requirement)

Create a checklist section in code review / CI notes:
- Verify installed Nautilus version and method signatures in site-packages.
- Add a minimal “import + call signature” test for:
  - RiskEngineConfig fields we set
  - ExecAlgorithm registration entrypoint
  - Strategy persistence hooks

Deliverable:
- Plan appendix section “Verified APIs” with file paths + signatures.

---

# Phase A — Baseline integration map (no feature changes)

Purpose: reduce duplication and avoid fighting existing project modules.

Tasks:
1. Map current entry/exit flow and gating points:
   - where entries are created
   - where `submit_order` / `submit_order_list` happen
   - where time gates, spread gates, and DD gates currently live

2. Map existing project modules that may overlap with Phase 14 scope:
   - time gates (`src/risk/time_constraint_manager.py`)
   - drawdown/HWM logic (`src/risk/drawdown_tracker.py`, `src/risk/prop_firm_manager.py`)
   - sizing policy (`src/risk/position_sizer.py`)
   - strategy selection (`src/strategies/strategy_selector.py`)
   - anti-lookahead/safety layers (`src/risk/virtual_gate.py`)

Deliverable:
- Append an “Integration Map” section to this plan with file paths + key functions.

---

# Phase B — RiskEngineConfig hardening (rate limits + max notional)

(Updated per FORGE: treat as a modification to existing wiring, not a new system.)

Scope source: `RISK_ENGINE_AND_SIZING.md`.

## Implementation status (2025-12-28)

**DONE**
- YAML support for `risk_engine.max_order_modify_rate` added.
- Runner wiring parses and passes `max_order_modify_rate` into `RiskEngineConfig`.
- `max_notional_per_order` enforcement is covered by a focused integration test (real RiskEngine denial path).

Evidence:
- Config: `nautilus_gold_scalper/configs/strategy_config.yaml` (`risk_engine.max_order_modify_rate`).
- Wiring: `nautilus_gold_scalper/scripts/backtest/run_backtest.py` (`_risk_engine_config_from_cfg`).
- Tests:
  - `nautilus_gold_scalper/tests/test_backtest/test_risk_engine_config_wiring.py`
  - `nautilus_gold_scalper/tests/test_backtest/test_risk_engine_notional_enforcement.py`

Validation gate:
- `pytest -q` PASS (E2E tick test may skip if external tick fixture absent).
- `mypy --strict` PASS.

## Implementation requirements

1. Extend existing `RiskEngineConfig(bypass=False)` wiring to include:
   - `max_order_submit_rate`
   - `max_order_modify_rate`
   - `max_notional_per_order`

2. Values come from a single source of truth (YAML/config), not scattered constants.

3. Explicitly ensure “close always wins” is not violated:
   - If RiskEngine limits cannot be exempted for reduce-only, keep limits high enough for emergency close and enforce entry limits elsewhere.

## Performance + safety notes

- Parsing is a **cold path** (runner setup). No impact to per-tick performance.
- Runtime enforcement happens inside Nautilus RiskEngine per command; that is not a hot loop for us.
- Primary operational risk is misconfiguration (submit/modify rates too tight). Keep defaults high and validate emergency close behavior.

---

# Phase I (promoted) — State persistence (on_save/on_load)

(Updated per CRITIC: move persistence earlier; restart safety is critical.)

Scope source: `STRATEGY_PATTERNS_AND_ACTORS.md`.

Persist at minimum:
- HWM
- session start equity
- last risk state (ACTIVE/REDUCING/HALTED)
- last regime (if present)
- time-gate flags (after 4:30, after 4:55)

Tests:
- Save/load round-trip preserves all critical state.
- Emergency close still triggers correctly after reload.

---

# Phase C — Sizing upgrade (adapter approach, not replacement)

(Updated per FORGE: avoid duplicating/overriding current project sizing policy.)

Scope sources:
- `RISK_ENGINE_AND_SIZING.md` for `FixedRiskSizer`
- Existing project sizing policy in `nautilus_gold_scalper/src/risk/position_sizer.py`

Design:
- Keep project sizer as canonical.
- Add an optional adapter path that can call Nautilus `FixedRiskSizer` only if:
  - instrument point-value semantics are validated for XAUUSD
  - it does not bypass existing DD throttles and safety sizing reductions

Tests:
- Invariants: stop distance ↑ → qty ↓; equity ↑ → qty ↑; hard_limit enforced; batch rounding enforced.

---

# Phase D — Execution algorithms: TWAP integration + policy

(Updated per CRITIC/FORGE: add verification step and deadline safety constraints.)

Scope source: `EXECUTION_ALGOS_AND_ORDERS.md`.

Pre-gate:
- Verify how to register exec algorithms in our engine construction path.

Policy:
- TWAP is never used for 4:55–4:59 emergency close.
- For emergency close: immediate reduce-only close orders only.

“Close always wins” acceptance criteria:
- Under throttles/limits, emergency close still succeeds.

Tests:
- Emergency close never uses TWAP after 4:55.
- ExecAlgorithm integration does not break existing execution failsafes.

---

# Phase E — Indicator suite integration (framework + mandatory set)

(Updated per CRUCIBLE: indicators as gates/penalties; parameter discipline; falsification-first.)

Scope source: `NATIVE_INDICATORS.md`.

Mandatory set:
- KeltnerPosition
- VWAP
- Pressure
- EfficiencyRatio
- FuzzyCandlesticks

Integration constraints:
- Use indicators as risk reducers first:
  - EfficiencyRatio: regime gate only
  - KeltnerPosition: location penalty (capped)
  - VWAP: anchor distance sanity check (beware volume semantics)
  - Pressure: diagnostic-first, then penalty/veto if validated
  - FuzzyCandlesticks: closed-bar only; veto entries lacking rejection confirmation

Overfit containment:
- Freeze canonical defaults.
- At most 1–2 tunables total (e.g., `min_confluence_score` + one regime threshold).

Falsification-first tests (must run before trusting improvements):
- Ghost test (random entries with gates fixed)
- Permutation importance (block-shuffle each indicator stream)
- Shifted-levels (bounded shifts to VWAP/levels)
- Cost-stress sweep (spread/slippage/latency multipliers)
- Session-split OOS (London/overlap vs NY-only vs Asia-only)

---

# Phase F — Data modes (Renko + aggregation) as separate backtest mode

(Updated per CRITIC/FORGE: separate mode and add look-ahead tests.)

Scope source: `DATA_HANDLING_AND_CACHING.md`.

Rules:
- Add Renko as a distinct mode/switch.
- Decide on close, act next bar.

Tests:
- Renko look-ahead guard tests.
- Smoke test: engine builds, bars arrive, indicators warm.

---

# Phase G — Signal bus architecture (publish/subscribe)

(Updated per FORGE: implement bus first; Controller later.)

Scope source: `STRATEGY_PATTERNS_AND_ACTORS.md`.

Design:
- Regime actor publishes RegimeData
- Risk actor publishes RiskData
- Strategy subscribes and gates entries/exits

Tests:
- Actor publishes → strategy receives → state updates.

---

# Phase H — Controller orchestration (deferred)

(Updated per CRITIC/FORGE: defer until safety/time semantics proven.)

Constraint:
- Emergency close must not live “inside” a stoppable strategy path.
- If we add a Controller, emergency close remains enforced by top-level risk/time enforcer.

---

# Phase J — Portfolio/account reporting (last, non-authoritative)

(Updated per CRITIC: reporting must remain read-only, not a dependency for risk.)

Scope source: `PORTFOLIO_AND_ACCOUNT.md`.

Rules:
- Reporting must not be imported into risk modules.
- Risk decisions must rely on the Apex-safe DD tracker, not returns-based analyzer stats.

---

# Execution order (updated)

Phases execute in this strict order (reference order; **implementation may stop early** if falsification gates reject optional items):

0 → A → B → I → C → D → E → F → G → H → J

Rationale:
- Tests-first safety lockdown and API verification
- Then engine-level risk enforcement
- Then persistence
- Then sizing
- Then execution
- Then indicators and data modes
- Then signal bus
- Controller late
- Reporting last

**Authoritative next steps** are defined in the triage roadmap earlier in this document (Phase B → GHOST TEST → optional phases).

---

# Rollout & Kill-Switch Rules (applies to all phases)

To prevent regressions and to make debugging/rollback cheap:

- Every major capability added in Phase 14 must be behind a config toggle (default safe).
  - Risk/time-gates remain always-on.
  - Experimental items (new indicators, Renko mode, TWAP usage, Controller, signal bus) default off until Phase 0 tests + targeted validation pass.
- Each toggle must have:
  - a single source of truth in config
  - deterministic logging when enabled/disabled

---

# Logging & Artifacts (project gates)

Per `CLAUDE.md` validation_gate:
- When a work unit is complete, update `CHANGELOG.md`.
- When a bug is discovered/fixed, update `nautilus_gold_scalper/BUGFIX_LOG.md` (Python side).

Artifacts to keep (paths only; no large log dumps in chat):
- Backtest summary metrics (and any account report outputs) should be saved as files and referenced by path.

---

# Validation checklist (applies to every phase)

- `pytest` passes (prefer targeted tests first, then full suite).
- `mypy --strict` passes.
- No look-ahead invariant tests pass.
- Apex time-gate invariants pass (flat by 4:59).
- For any new signal/indicator/regime change: run falsification-first suite before trusting results.

---

# Known gaps / explicit uncertainties

UNCERTAINTY (must verify before implementing):
- How to access runtime RiskEngine from our strategy/runner objects for runtime adjustments.
- ExecAlgorithm registration API in our engine build path.
- Strategy persistence plumbing (where state is stored and when on_save/on_load are invoked).
- Custom Data publish/subscribe serialization semantics.

Resolution method:
- Verify in installed site-packages Nautilus source and add a unit test asserting the integration actually works.
