# Phase 10 Plan 01: Backtest Integration Summary

**Reusable backtest_adapter.py module with BacktestRunner integration, CLI with real optimization path, and 14 smoke tests**

## Accomplishments
- Created `backtest_adapter.py` module with factory function `create_backtest_fn()` that produces ApexOptimizer-compatible backtest functions
- Updated `__main__.py` CLI to use the new adapter and run real optimizations (not just placeholder instructions)
- Added CLI flags for smoke testing: `--train-start`, `--train-end`, `--feed`, `--initial-balance`, `--ltf-minutes`, `--sample-rate`
- Implemented proper CLI override support using `dataclasses.replace()` for frozen config
- Created comprehensive smoke test suite (14 tests) with mocked BacktestRunner to validate adapter contract

## Files Created/Modified
- `nautilus_gold_scalper/src/optimization/backtest_adapter.py` - New adapter module (~320 lines)
  - `BacktestAdapterConfig` dataclass for configuration
  - `create_backtest_fn()` factory that wraps BacktestRunner
  - Parameter dotpath extraction helpers (`_get_value`, `_get_param_int`, `_get_param_bool`, `_get_param_float`)
  - `_extract_trades_df()` - extracts trades with required schema (timestamp, pnl, entry_time, exit_time)
  - `_extract_equity_series()` - extracts MTM equity from DrawdownTracker or cumulative PnL fallback
- `nautilus_gold_scalper/src/optimization/__main__.py` - Updated CLI (~150 lines changed)
  - Added new CLI arguments for date range and adapter configuration
  - Removed placeholder "NOTE: integrate..." message
  - Now actually runs optimization with injected backtest_fn
- `nautilus_gold_scalper/tests/test_optimization/test_backtest_adapter_smoke.py` - New test module (14 tests)
  - Tests for trades DataFrame schema
  - Tests for equity series properties
  - Tests for factory function behavior
  - Tests for parameter dotpath expansion
  - Tests for adapter config dataclass
  - Tests for ApexOptimizer integration

## Decisions Made
- **Separate module vs inline**: Created `backtest_adapter.py` as a standalone module (vs inlining in `scripts/optimize.py`) for better reusability and testability
- **Config dataclass**: Used frozen dataclass for adapter configuration to match OptimizationConfig pattern
- **Dynamic import**: Used `@lru_cache` for thread-safe lazy import of BacktestRunner (avoids circular imports)
- **MTM equity extraction**: Prioritizes DrawdownTracker history (accurate for Apex DD), falls back to cumulative PnL
- **Feed mode forcing**: Bars-only runs automatically disable prop_firm_enabled (not valid for Apex compliance)

## Deviations from Plan

None - plan executed exactly as written.

## Issues Encountered
- Pre-existing mypy errors in `levy_enhanced.py`, `asha.py`, and `news_data.py` (not introduced by this plan)
- These are numpy typing issues and unrelated to backtest adapter work

## Next Step
Ready for 10-02-PLAN.md (Grid/Random Search) - already marked as COMPLETE in MASTER.

---
*Phase: 10-apex-optimizer*
*Completed: 2025-12-28*
