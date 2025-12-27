# CRITIC Review — Phase 14 Plan

AGENT: critic-adversarial
STATUS: COMPLETE
VERDICT: FAIL

Source plan:
- `/.planning/phases/14-nautilus-expansion/14-00-PLAN_MASTER.md`
- `/.planning/phases/14-nautilus-expansion/orchestration/MANIFEST.md`

Agent output (verbatim):

1) FAIL

2) Top 10 risks (with mitigation)

1. API/behavior assumptions (RiskEngine + ExecAlgos) may be wrong
   - Risk: plan relies on annex “documented” calls like `risk_engine.set_max_notional_per_order(...)` without verifying against the installed NautilusTrader version; this can silently no-op or break live.
   - Mitigation: add a hard “API verification gate” before Phase B/D: grep/inspect installed Nautilus sources for each method + signature; add a unit test that fails if config is not applied.

2. Emergency close can be blocked by RiskEngine rate/notional limits
   - Risk: TWAP slices + reduce-only closes can get rejected/throttled, leaving open positions past `4:59 PM ET` (Apex termination-level).
   - Mitigation: explicitly exempt reduce-only closing orders from notional/rate limits OR implement a dedicated “close override path” that bypasses those limits while still preventing new entries.

3. TWAP near the deadline is structurally unsafe
   - Risk: TWAP horizon/interval can extend beyond the deadline; partial fills leave residual position overnight.
   - Mitigation: add a hard cutoff: after `4:55 PM ET` only immediate close (market/IOC reduce-only). TWAP allowed only when time-to-deadline is comfortably large.

4. HWM/DD semantics can be corrupted by mid-price valuation
   - Risk: Nautilus portfolio/account “equity” may be mid-marked; if reused for Apex HWM, unrealized profit inflates HWM and raises trailing floor (Apex trap).
   - Mitigation: enforce a single authoritative Apex DD tracker using conservative bid/ask marking; forbid using portfolio equity for HWM.

5. Controller/actors introduce failure modes and hidden coupling
   - Risk: controller pauses/stops strategies on HALT/regime change, but open positions remain because emergency close lives “inside” a stopped strategy path.
   - Mitigation: make emergency close a top-level risk/time enforcer independent of strategy lifecycle; verify it runs even if all strategies are stopped.

6. Look-ahead via Renko/aggregation + regime switching
   - Risk: Renko brick formation and regime classifiers can embed future tick information if decisions are applied in the same bar/brick.
   - Mitigation: “decide on close, act next bar” rule for regime/controller; explicitly test timestamp ordering and bar completion semantics per bar type.

7. Performance budget not pinned to event granularity
   - Risk: indicator pack + pub/sub can blow `on_bar <1ms` / `on_quote_tick <100us` if computed on ticks.
   - Mitigation: specify per-component cadence: risk guard tick-driven; indicators/regime bar-driven; add microbench/profiling assertions.

8. Overbroad scope (“implement everything discovered”) is untestable
   - Risk: plan becomes a feature grab-bag with no measurable acceptance criteria; hard to attribute regressions.
   - Mitigation: enforce “one capability per phase” with explicit success metrics and kill-switch toggles; require delta metrics (ΔPSR/ΔMC95DD) per added feature.

9. Timekeeping contract (NTP drift, degraded mode) missing from plan
   - Risk: ET gates wrong under drift/DST issues -> overnight violation.
   - Mitigation: add an explicit phase to implement/validate the `America/New_York` time source, drift detection, and degraded earlier close behavior per `/home/franco/projetos/EA_SCALPER_XAUUSD/CLAUDE.md`.

10. Reporting hooks can accidentally become stateful dependencies
   - Risk: “report generation” code starts being reused for risk decisions, adding side effects and latency.
   - Mitigation: enforce reporting as read-only snapshots; static typing boundaries (no imports from reporting into risk).

3) Missing items

- A dedicated “Apex invariants” test suite: HWM monotonicity, conservative marking (bid for long, ask for short), trailing DD formula, time-gate absolute behavior (4:30 block / 4:55 force-close / 4:59 flat).
- Explicit “close always wins” policy when risk engine throttles: what happens on reject/partial/no-fill; retry rules; escalation to more aggressive order types.
- A clear bar-completion / event timestamp contract for each data mode (time bars vs Renko vs aggregated bars).
- A minimal hostile execution model requirement (spread/slippage/latency multipliers) before adding TWAP/controller complexity.

4) Suggested re-ordering

- Insert new Phase 0 (before Phase B): “Apex timekeeping + DD invariants lockdown” (tests first).
- Move Phase I (persistence) earlier than controller/actors: persistence of HWM/time-gate state is safety-critical if the process restarts.
- Defer Phase H (controller) until after Phase D/F are proven safe under hostile execution and time gates.
- Defer Phase J (reporting) to last and explicitly keep it non-authoritative.

5) Minimal falsification-first tests (run before big implementation)

- “Emergency close survival” test: simulate time at 4:55–4:59 with open position + rate limits; assert flat by 4:59 even with partial fills/rejects.
- “HWM trap” test: feed a price path with unrealized spike then reversal; assert HWM uses conservative bid/ask and never decreases; verify trailing floor behavior.
- “Renko look-ahead” test: ensure signals/regime decisions at event time T only use data with timestamp < T; controller changes apply next bar only.
- “Risk config applied” test: intentionally oversize an order and assert RiskEngine blocks it; fail hard if it slips through (detect config being ignored).
