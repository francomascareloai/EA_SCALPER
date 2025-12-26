AGENT: FORGE-NAUTILUS
VERSION: 1.1
CLAUDE_MD_VERSION: 3.10.9
STATUS: PARTIAL

# Audit Round 1 (Risk/Execution)
Scope: DrawdownTracker day boundary logic, HolidayDetector wiring, slippage_ticks/tick_size propagation, look-ahead risks, runtime exceptions/silent mis-modeling.

## 1) Findings
- `DrawdownTracker` day-boundary handling is explicitly timezone-aware and backtest-deterministic when `now` is provided; it anchors the first observed timestamp to avoid constructor wall-clock drift (`/home/franco/projetos/EA_SCALPER_XAUUSD/nautilus_gold_scalper/src/risk/drawdown_tracker.py:176-191`, `:405-417`).
- Strategy-level daily reset in `GoldScalperStrategy._check_daily_reset()` resets multiple subsystems (daily PnL counters, execution failsafe, DrawdownTracker, PropFirmManager, TimeConstraintManager, CircuitBreaker) at **ET calendar day** boundaries (`/home/franco/projetos/EA_SCALPER_XAUUSD/nautilus_gold_scalper/src/strategies/gold_scalper_strategy.py:1272-1356`).
- `HolidayDetector` exists and is injected into `StrategySelector`, but current `GoldScalperStrategy` usage constructs a `MarketContext` manually and calls `select_strategy(context)`, which bypasses `StrategySelector.update_context()` and therefore bypasses holiday/weekend/session auto-detection (`/home/franco/projetos/EA_SCALPER_XAUUSD/nautilus_gold_scalper/src/strategies/gold_scalper_strategy.py:1844-1882`, `/home/franco/projetos/EA_SCALPER_XAUUSD/nautilus_gold_scalper/src/strategies/strategy_selector.py:226-315`).
- Slippage modeling is “tick-like” but currently implemented by converting `slippage_ticks * tick_size` into `ExecutionCosts.base_slippage_cents` (plus multiplier/jitter), not by wiring `ExecutionRealism.slippage_ticks` (`/home/franco/projetos/EA_SCALPER_XAUUSD/nautilus_gold_scalper/src/strategies/gold_scalper_strategy.py:786-829`, `/home/franco/projetos/EA_SCALPER_XAUUSD/nautilus_gold_scalper/src/execution/execution_model.py:221-260`).
- Drawdown/HWM mark-to-market in `BaseGoldStrategy` is conservative (LONG uses BID, SHORT uses ASK) which is aligned with the HWM trap defense (`/home/franco/projetos/EA_SCALPER_XAUUSD/nautilus_gold_scalper/src/strategies/base_strategy.py:1308-1341`).

## 2) Potential bugs (file:line)
- HolidayDetector effectively unused in live selection path:
  - `GoldScalperStrategy` builds `MarketContext(...)` manually and passes it into `StrategySelector.select_strategy(context)` without setting `is_weekend`, `is_holiday`, or `reduced_liquidity`, so selector gates 1/5 (weekend/holiday) won’t trigger from the detector (`/home/franco/projetos/EA_SCALPER_XAUUSD/nautilus_gold_scalper/src/strategies/gold_scalper_strategy.py:1844-1882`).
  - `StrategySelector` only queries the injected `holiday_detector` inside `_update_session_info()` which is called from `update_context()`; that path is bypassed when caller supplies `context` (`/home/franco/projetos/EA_SCALPER_XAUUSD/nautilus_gold_scalper/src/strategies/strategy_selector.py:226-315`, `:329-343`).
- Reduced-liquidity days (adjacent holidays) are computed but not acted upon:
  - `HolidayDetector.check_holiday()` sets `reduced_liquidity=True` for “adjacent holiday” with `is_holiday=False` (`/home/franco/projetos/EA_SCALPER_XAUUSD/nautilus_gold_scalper/src/context/holiday_detector.py:372-392`).
  - `StrategySelector` gate 5 checks only `context.is_holiday` and ignores `context.reduced_liquidity` (`/home/franco/projetos/EA_SCALPER_XAUUSD/nautilus_gold_scalper/src/strategies/strategy_selector.py:466-475`).
- Holiday day-boundary may be wrong around UTC midnight:
  - `HolidayDetector` uses `check_time.date()` directly (UTC date if tz-aware) rather than evaluating US/UK local dates; this can misclassify holiday status around 00:00 UTC relative to New York/London (`/home/franco/projetos/EA_SCALPER_XAUUSD/nautilus_gold_scalper/src/context/holiday_detector.py:338-352`).
- Slippage ticks semantics drift / double-model risk:
  - `GoldScalperStrategy` converts `slippage_ticks` into `base_slippage_cents` and uses `ExecutionModel.apply_slippage(..., tick_size=...)`, but never sets `ExecutionRealism.slippage_ticks`, despite docs calling it “fixed adverse slippage in ticks” (`/home/franco/projetos/EA_SCALPER_XAUUSD/nautilus_gold_scalper/src/strategies/gold_scalper_strategy.py:786-823`, `/home/franco/projetos/EA_SCALPER_XAUUSD/nautilus_gold_scalper/src/execution/execution_model.py:24-27`, `:251-255`).
  - This can silently change the meaning of `slippage_ticks` (fixed ticks vs randomized cents) and make comparisons across configs hard.
- Commission schedule mis-inference can silently disable execution costs:
  - `GoldScalperStrategy` infers `product = "mgc" if raw_symbol == "mgc" else "xauusd"`; non-exact symbols (e.g., futures like `MGCZ5`) may route to `xauusd` and then `commission_per_side_usd(profile="apex", product="xauusd", ...)` raises, which is caught and disables the entire `ExecutionModel` (`/home/franco/projetos/EA_SCALPER_XAUUSD/nautilus_gold_scalper/src/strategies/gold_scalper_strategy.py:806-829`, `/home/franco/projetos/EA_SCALPER_XAUUSD/nautilus_gold_scalper/src/execution/commission_schedule.py:29-38`).
- Backtest determinism hole on missing timestamps:
  - On position close, DrawdownTracker update falls back to `datetime.now(timezone.utc)` if `event.ts_event` missing, which can skew day-boundary resets and metrics in backtests/replays (`/home/franco/projetos/EA_SCALPER_XAUUSD/nautilus_gold_scalper/src/strategies/base_strategy.py:719-727`).

## 3) Recommended fixes (minimal)
- Fix HolidayDetector wiring into selector usage:
  - In `GoldScalperStrategy`, stop passing a fully-formed `MarketContext` into `select_strategy(...)`.
  - Instead: call `self._strategy_selector.set_regime(hurst, entropy)` and `self._strategy_selector.update_context(..., bar_time=bar_time)` then call `self._strategy_selector.select_strategy()` without arguments. This ensures weekend/session/holiday (and future context fields) are consistently computed inside the selector.
- Make selector use reduced-liquidity signal:
  - In `StrategySelector._evaluate_strategies()`, treat `context.reduced_liquidity` similarly to `context.is_holiday` (or apply the `HolidayDetector.get_size_multiplier()` when available) so adjacent holidays meaningfully reduce size/score.
- Make holiday detection timezone-explicit:
  - Convert `check_time` into US/UK local dates for holiday lookup (ZoneInfo fallback to UTC). Keep this conservative (if conversion fails, assume reduced liquidity).
- Align slippage configuration semantics:
  - Choose one interpretation and make it consistent:
    - Either: wire `ExecutionRealism.slippage_ticks = config.slippage_ticks` and keep `base_slippage_cents` independent, or
    - Rename config to `base_slippage_cents` and stop calling it ticks.
- Avoid disabling execution costs entirely when commission schedule lookup fails:
  - If schedule lookup raises for an unsupported product, fall back to manual commission while keeping slippage modeling enabled; log a warning once.
- Close-time timestamp fallback:
  - Replace `datetime.now(timezone.utc)` fallbacks with the latest known market timestamp (`self._last_market_ts_ns`) or strategy clock time to preserve determinism.

## 4) Validation suggestions
- Run focused tests:
  - `pytest -q /home/franco/projetos/EA_SCALPER_XAUUSD/nautilus_gold_scalper/tests/test_risk/test_drawdown_tracker.py`
  - `pytest -q /home/franco/projetos/EA_SCALPER_XAUUSD/nautilus_gold_scalper/tests/test_holiday_detector.py`
  - `pytest -q /home/franco/projetos/EA_SCALPER_XAUUSD/nautilus_gold_scalper/tests/test_execution/test_execution_model.py`
- Add/extend tests (fast, deterministic):
  - StrategySelector: verify a wired `HolidayDetector` changes selection/size on a known holiday and adjacent day (assert `size_multiplier` changes).
  - GoldScalperStrategy: regression test that selector weekend/holiday gates are active (e.g., force `bar_time` to Saturday and assert no-trade).
  - Commission schedule inference: test that raw symbols like `MGCZ5` or `MGC` route correctly (or require explicit config override).
- Run type gate and unit tests:
  - `mypy --strict /home/franco/projetos/EA_SCALPER_XAUUSD/nautilus_gold_scalper/src`
  - `pytest -q`
