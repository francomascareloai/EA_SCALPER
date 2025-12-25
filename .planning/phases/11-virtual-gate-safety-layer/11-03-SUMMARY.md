# Phase 11-03 — SUMMARY (VirtualGate: completed bars only, deterministic)

## Accomplishments
- Implemented `VirtualGate` as a pure, deterministic entry-only filter based on completed-bar data.
- Enforced the temporal contract: any bar timestamp used by VirtualGate must be strictly `< decision_ts_ns` (fail-closed on violation).
- Integrated VirtualGate into `UnifiedRiskPolicy.evaluate_entry` under “most restrictive wins” semantics.
- Wired strategy entry path to pass only completed LTF bars (excluding the current bar) into the unified policy via `VirtualGateInput`.

## Files Created/Modified
- Created: `nautilus_gold_scalper/src/risk/virtual_gate.py`
- Modified: `nautilus_gold_scalper/src/risk/unified_risk_policy.py`
- Modified: `nautilus_gold_scalper/src/strategies/gold_scalper_strategy.py`
- Created: `nautilus_gold_scalper/tests/test_risk/test_virtual_gate.py`

## Decisions Made
- Use a conservative initial rule: block on range spikes vs recent median range (keeps logic simple and deterministic).
- Fail-closed if VirtualGate is enabled but inputs are missing (`virtual_gate_missing_input`).
- Ensure completed-bars-only by slicing `self._ltf_bars[-21:-1]` in the strategy (excludes the current LTF bar).

## Deviations from Plan
- Plan verification commands referenced `pytest -q` / `python` generically; used venv python path for verification in this environment.

## Verification (Executed)
- `nautilus_gold_scalper/.venv/bin/python3 -m pytest -q nautilus_gold_scalper/tests/test_risk/test_virtual_gate.py` (2 passed)
- `nautilus_gold_scalper/.venv/bin/python3 -m pytest -q nautilus_gold_scalper/tests` (409 passed, 7 skipped)
- `nautilus_gold_scalper/.venv/bin/python3 -m mypy --config-file mypy.ini --strict [touched files]` (no issues)

## Issues Encountered
- `python` and `nautilus_gold_scalper/.venv/bin/python` were not available in this shell; switched to `nautilus_gold_scalper/.venv/bin/python3`.

## Next Phase Readiness
- Ready for **11-04** (Integration backtest + falsification checks), including ablation + hostile execution smoke.
