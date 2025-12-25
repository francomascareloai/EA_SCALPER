# Phase 11-02 — SUMMARY (ExposureCaps + NewsGuard + VolatilitySpacing)

## Accomplishments
- Implemented three entry-only safety gates:
  - `ExposureCaps`: blocks new entries if concurrent exposure caps are reached.
  - `NewsGuard`: blocks new entries during `NewsTradeAction.BLOCK` windows (driven by existing `NewsCalendar` output).
  - `VolatilitySpacing`: monotonic, bounded cooldown based on a volatility proxy; blocks new entries until required cooldown elapses.
- Integrated these gates into `UnifiedRiskPolicy.evaluate_entry` with “most restrictive wins” semantics.
- Wired `GoldScalperStrategy` to feed deterministic inputs (bar `ts_event`, ATR, open position status, news window) into unified policy.
- Added unit tests covering the checklist intent (B3/B4/B5) and verified full test suite still passes.

## Files Created/Modified
- Created: `nautilus_gold_scalper/src/risk/exposure_caps.py`
- Created: `nautilus_gold_scalper/src/risk/news_guard.py`
- Created: `nautilus_gold_scalper/src/risk/volatility_spacing.py`
- Modified: `nautilus_gold_scalper/src/risk/unified_risk_policy.py`
- Modified: `nautilus_gold_scalper/src/strategies/gold_scalper_strategy.py`
- Created: `nautilus_gold_scalper/tests/test_risk/test_exposure_caps.py`
- Created: `nautilus_gold_scalper/tests/test_risk/test_news_guard.py`
- Created: `nautilus_gold_scalper/tests/test_risk/test_volatility_spacing.py`
- Modified: `.planning/phases/11-virtual-gate-safety-layer/11-02-PLAN.md` (fixed paths/commands)

## Decisions Made
- Use `NewsCalendar.check_news_window(now=bar_time)` as the authoritative, deterministic news window input; `NewsGuard` consumes `NewsWindow` without re-deriving time math.
- Use ATR (computed from completed bars) as the volatility proxy for spacing to avoid tick-level noise and preserve determinism.
- Track volatility spacing cooldown based on `bar.ts_event` (ns) and last entry bar timestamp.

## Deviations from Plan
- Plan file paths and verification commands originally referenced `src/...` and `pytest -q` at repo root; updated to `nautilus_gold_scalper/...` paths and venv commands.

## Verification (Executed)
- `nautilus_gold_scalper/.venv/bin/python -m compileall -q [new modules]`
- `nautilus_gold_scalper/.venv/bin/python -m pytest -q nautilus_gold_scalper/tests` (406 passed, 7 skipped)
- `nautilus_gold_scalper/.venv/bin/mypy --config-file mypy.ini --strict [touched files]` (no issues)

## Issues Encountered
- `mypy` surfaced a `news_window` ordering/redefinition issue due to duplicate blocks inside `_check_for_signal`; removed the duplicate block and consolidated the news window computation.

## Next Phase Readiness
- Ready to proceed to **11-03** (VirtualGate) once desired policy inputs for determinism and completed-bars-only semantics are confirmed in code.
