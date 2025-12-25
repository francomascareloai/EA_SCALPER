# Phase 11-01 — SUMMARY (Unified Safety Policy Surface)

## Accomplishments
- Added a minimal unified decision contract (`RiskDecision`) and a single policy surface (`UnifiedRiskPolicy.evaluate_entry`) to centralize entry gating precedence.
- Wired unified policy evaluation into the strategy entry path (`GoldScalperStrategy._check_for_signal`) without touching forced-close / flatten enforcement paths.
- Added unit tests to lock precedence semantics (must_flatten wins) and size_factor bounds (clamp [0, 1]).

## Files Created/Modified
- Created: `nautilus_gold_scalper/src/risk/unified_risk_policy.py`
- Modified: `nautilus_gold_scalper/src/strategies/gold_scalper_strategy.py`
- Created: `nautilus_gold_scalper/tests/test_risk/test_unified_risk_policy.py`

## Decisions Made
- Keep Phase 11-01 policy dependency-light and focused on precedence semantics; concrete gates (ExposureCaps/NewsGuard/VolatilitySpacing/VirtualGate) will be added as inputs in later plans.
- Enforce policy as entry-only gating in `_check_for_signal`; forced-close/flatten remains handled by existing enforcement paths (TimeConstraintManager / prop-firm enforcement).

## Deviations from Plan
- Verification executed via the project venv at `nautilus_gold_scalper/.venv/` and with absolute paths due to repo layout and differing pytest/mypy configs.

## Verification (Executed)
- `nautilus_gold_scalper/.venv/bin/python -m compileall -q nautilus_gold_scalper/src/risk/unified_risk_policy.py`
- `nautilus_gold_scalper/.venv/bin/python -m pytest -q nautilus_gold_scalper/tests/test_risk/test_unified_risk_policy.py` (3 passed)
- `nautilus_gold_scalper/.venv/bin/python -m pytest -q nautilus_gold_scalper/tests` (399 passed, 7 skipped)
- `nautilus_gold_scalper/.venv/bin/mypy --config-file mypy.ini --strict [changed files]` (no issues)

## Issues Encountered
- Root-level `pytest` invocation collected 0 tests due to config/rootdir differences; running from the `nautilus_gold_scalper` venv and targeting `nautilus_gold_scalper/tests` resolved this.
- Root-level `mypy --strict` (without config scoping) reports pre-existing errors across many unrelated test files; scoped mypy run against changed files passes.

## Next Phase Readiness
- Ready to proceed to **11-02** to implement concrete entry-only gates (ExposureCaps + NewsGuard + VolatilitySpacing) feeding into `UnifiedRiskPolicy`.
