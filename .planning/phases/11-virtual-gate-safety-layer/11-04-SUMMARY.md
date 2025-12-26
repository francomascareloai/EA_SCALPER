# Phase 11-04: Integration backtest + falsification checks Summary

**Inline-WFA now computes Apex time-gate and overnight violations, and Phase 11-04 produced ablation + hostile-exec smoke artifacts with pytest/mypy verification green.**

## Accomplishments
- Verified Safety Layer invariants via integration tests (C1/C2/C3) in `nautilus_gold_scalper/tests/test_integration/test_safety_layer_bypass.py`.
- Produced falsification-first evidence artifacts for ablation and hostile execution smoke using saved CSV outputs.
- Closed the CRITIC NO-GO root cause by implementing real computation for optimization constraint metrics:
  - `time_gate_violations` (entries after 16:30 ET)
  - `overnight_positions` (exits after 16:59 ET and/or cross-day holds)

## Files Created/Modified
- `nautilus_gold_scalper/src/optimization/validation/wfa_inline.py` - Computes `time_gate_violations` + `overnight_positions` from extracted trades.
- `DOCS/04_REPORTS/DECISIONS/20251225_safety_layer_ablation.md` - Ablation report referencing concrete artifacts.
- `DOCS/04_REPORTS/DECISIONS/20251225_safety_layer_hostile_smoke.md` - Hostile execution smoke report referencing concrete artifacts.

## Decisions Made
- Use `entry_time` for time-gate counting when available (fallback to `timestamp`), aligning with the optimization trade extraction contract in `nautilus_gold_scalper/scripts/optimize.py`.
- Treat timezone conversion failure (ET unavailable) as a conservative non-zero violation count to avoid false Apex compliance in optimization.

## Deviations from Plan

- Ablation matrix in this execution only includes a VirtualGate ON/OFF comparison (plus baseline/no-trade and hostile smoke). The plan listed additional component-by-component steps (+ExposureCaps/+NewsGuard/+VolatilitySpacing) which are not fully populated by the current saved artifacts.

## Issues Encountered
- E2E tick backtest integration tests are skipped due to missing local tick data (`nautilus_gold_scalper/tests/test_integration/test_tick_backtest_e2e.py`).

## Verification
- `pytest -q` (passes; tick-data E2E tests skipped when data is absent)
- `mypy --strict nautilus_gold_scalper` (no issues)
- `python -m nautilus_gold_scalper.scripts.backtest.run_backtest --help` (OK)

## Next Phase Readiness
- Safety Layer precedence/invariants are locked by integration tests.
- Optimization pipeline is no longer blind to Apex time/overnight constraints at the InlineWFA layer.
- For stronger falsification evidence: run a longer slice and fill the full ablation ladder (+ExposureCaps/+NewsGuard/+VolatilitySpacing/+VirtualGate) and hostile multipliers per TEST_CHECKLIST D2.

---
*Phase: 11-virtual-gate-safety-layer*
*Completed: 2025-12-26*
