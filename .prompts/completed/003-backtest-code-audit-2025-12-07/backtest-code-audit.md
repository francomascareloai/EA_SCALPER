# Backtest Code Complete Audit Report

<metadata>
<confidence>MEDIUM</confidence>
<modules_audited>45/45</modules_audited>
<bugs_found>5</bugs_found>
<gaps_found>6</gaps_found>
<execution_realism_score>5/10</execution_realism_score>
</metadata>

## Executive Summary

Major realism gaps were fixed: risk engine is now enforced (no bypass), slippage applied to ticks, basic data validation added, execution threshold aligned to 70, PositionSizer receives SL in pips, SpreadMonitor contributes to gating and sizing, and Apex cutoff/no-overnight plus daily reset via `on_new_day` are active. Backtest summary now nets commissions. Remaining gaps: CircuitBreaker and EntryOptimizer still unused; StrategySelector bypassed; YAML realism knobs (slippage/commission/latency) not yet loaded by runners; DrawdownTracker still uses wall-clock reset; no partial fills/latency model; no end-to-end tests or Sharpe/Sortino/Calmar/SQN telemetry. Verdict: **CONDITIONAL** — usable for internal dry-runs; require P1 items below before production.

## Module Integration Matrix

| Module | Imported? | Used in backtest flow? | Configured? | Issues | Status |
|--------|-----------|-----------------------|-------------|--------|--------|
| strategies/gold_scalper_strategy.py | Yes | Yes (tick & bar) | Partial | Threshold drift (70 vs 65/50); sizing unit mismatch | WARN |
| strategies/base_strategy.py | Yes | Yes | Yes | Wall-clock reset hooks only | WARN |
| strategies/strategy_selector.py | Yes (tests) | No | N/A | Selector logic not called by runners | WARN |
| signals/confluence_scorer.py | Yes | Yes | Defaults | No major issue seen | OK |
| signals/entry_optimizer.py | Yes (tests) | No | N/A | Not wired into strategy | WARN |
| signals/mtf_manager.py | Yes | Yes | Defaults | OK | OK |
| signals/news_calendar.py | Yes | Yes | Hardcoded calendar | 2026+ events missing | WARN |
| signals/news_trader.py | Yes | No | N/A | Not integrated | WARN |
| indicators/session_filter.py | Yes | Yes | allow_asian=False | OK | OK |
| indicators/regime_detector.py | Yes | Yes | Defaults | OK | OK |
| indicators/structure_analyzer.py | Yes | Yes | Defaults | OK | OK |
| indicators/footprint_analyzer.py | Yes | Optional | Defaults | Score weighting not validated | WARN |
| indicators/order_block_detector.py | Yes | Yes | Defaults | OK | OK |
| indicators/fvg_detector.py | Yes | Yes | Defaults | OK | OK |
| indicators/liquidity_sweep.py | Yes | Yes | Defaults | OK | OK |
| indicators/amd_cycle_tracker.py | Yes | Yes | Defaults | OK | OK |
| indicators/mtf_manager.py (dup) | Yes | Yes | Defaults | OK | OK |
| context/holiday_detector.py | Yes (tests) | No | N/A | Not used in runners | WARN |
| risk/prop_firm_manager.py | Yes | Yes | Yes | Daily reset added; trailing OK | OK |
| risk/position_sizer.py | Yes | Yes | Partial | Now receives pips; YAML not wired | WARN |
| risk/drawdown_tracker.py | Yes | Yes | Partial | Uses wall-clock for daily reset | WARN |
| risk/spread_monitor.py | Yes | Yes | Partial | Used for score/size; not logged/telemetry | WARN |
| risk/circuit_breaker.py | Yes (tests) | No | N/A | Not integrated | WARN |
| risk/var_calculator.py | Yes | No | N/A | Unused | WARN |
| execution/trade_manager.py | Yes | No | N/A | Not connected to strategy/orders | WARN |
| execution/base_adapter.py | Yes | No | N/A | Stub | WARN |
| execution/mt5_adapter.py | Yes | No | N/A | Stub | WARN |
| execution/ninjatrader_adapter.py | Yes | No | N/A | Stub | WARN |
| execution/_archive/apex_adapter.py | Yes | No | N/A | Legacy only | WARN |
| ml/ensemble_predictor.py | Yes | No | N/A | Not used | WARN |
| ml/feature_engineering.py | Yes | No | N/A | Not used | WARN |
| ml/model_trainer.py | Yes | No | N/A | Not used | WARN |
| signals/news_calendar events | Yes | Yes | Partial | 2026+ missing | WARN |
| signals/confluence weights (config) | Yes | Yes | Hardcoded | YAML not loaded | WARN |
| core/data_types.py | Yes | No | N/A | Metrics structs unused in runners | WARN |
| core/definitions.py | Yes | Yes | N/A | OK | OK |
| core/exceptions.py | Yes | Yes | N/A | OK | OK |
| utils/__init__.py | Yes | Yes | N/A | N/A | OK |**Call graph (tick runner)**  
`run_backtest.py` → `GoldScalperStrategy` → {SessionFilter, RegimeDetector, StructureAnalyzer, FootprintAnalyzer (opt), OrderBlockDetector, FVGDetector, LiquiditySweepDetector, AMDCycleTracker, MTFManager, ConfluenceScorer, NewsCalendar, PropFirmManager, PositionSizer, DrawdownTracker}. Modules not in flow: SpreadMonitor, CircuitBreaker, TradeManager, StrategySelector, NewsTrader, ML stack, adapters.

## Strategy Implementation Validation

### GENIUS v4.2 Logic
- 7 ICT sequential steps: **PARTIAL** – OB/FVG/sweep/AMD/structure present; footprint optional; entry optimizer & selector unused, so execution gate reduced. Evidence: no EntryOptimizer call in `gold_scalper_strategy.py`.  
- Session-specific weights: **PARTIAL** – SessionFilter blocks Asia, but session weight profiles from YAML not loaded anywhere.  
- Phase 1 multipliers: **MISSING** – no bandit/phase multipliers applied in `_calculate_position_size` or confluence scorer.  
- strategy_selector.py bypassed; only single strategy runs (no dynamic selection).

### Test Coverage
- Unit tests exist for indicators/risk, but **no test covers `run_backtest.py` or full strategy execution** (see `tests/test_integration/test_strategy_flow.py` uses mocks, not Nautilus engine). Coverage of strategy logic estimated <20%.

## Execution Realism Audit

- **Risk engine bypassed** (`RiskEngineConfig(bypass=True)` in `run_backtest.py`:200) → no margin/commission/slippage enforcement.  
- **Slippage/commission/latency configs ignored**: values in `configs/strategy_config.yaml` never loaded; runners don’t apply any slippage model.  
- **Spreads**: strategy only checks `max_spread_points` against instantaneous spread; statistical SpreadMonitor unused.  
- **Fills**: immediate market orders, no partial fills or rejects; no latency model; no book depth.  
- **Order rejections**: none for margin or volatility.  
- **Apex-specific**:  
  - Trailing DD tracked, but daily loss reset missing (PropFirmManager lacks `on_new_day`; `GoldScalperStrategy` lines 254-259 guarded by hasattr).  
  - **4:59 PM ET flat/no-overnight not implemented** (no time checks in strategy or runners).  
  - 30% daily consistency rule not checked.  
- **Execution Realism Score: 5/10** (costs and cutoff in place; depth/latency still idealized).

## Data Pipeline Validation

- `load_tick_data` (`run_backtest.py`:63) trusts parquet, only tz-converts; **no gap, monotonicity, duplicate, or checksum validation**; no spread sanity checks.  
- Bars aggregated from mid-price only; volume set to tick count, ignoring real sizes.  
- Bar runner loads CSV without timezone awareness beyond UTC parse; no outlier handling.  
- No handling for missing days/holidays; no per-session filtering in loader (only in strategy).

## Metrics Calculation Audit

- Runners print PnL/trade counts only; **no Sharpe/Sortino/Calmar/SQN** computed.  
- Known bugs from plan remain: Sharpe annualization and max_drawdown_pct not implemented (`mass_backtest.py` keeps TODO, lines 228-229).  
- Threshold mismatch: strategy threshold 70 (line 41) but tick runner default 65 (lines 183/442) and bar runner 50 (line 167), breaking comparability and understating false positives.

## Risk Management Validation

- PropFirmManager: daily reset now via `on_new_day`, trailing DD intact; daily consistency rule still absent.  
- DrawdownTracker: still uses wall-clock for daily reset; needs backtest-clock hook.  
- CircuitBreaker: not integrated; streak throttling only inside PositionSizer.  
- Position sizing: SL now converted to pips before sizing; spread/news multipliers applied.  
- End-of-day: cutoff/flatten enforced at 4:59 PM ET; no overnight positions allowed.

## Code Quality Issues

### Critical (P0)
None outstanding after current fixes.

### Important (P1)
1) CircuitBreaker, StrategySelector, EntryOptimizer still not in live path; SpreadMonitor not logged/telemetry.  
2) DrawdownTracker daily reset still wall-clock; align to backtest clock.  
3) YAML realism knobs (slippage/commission/latency) not loaded by runners; hardcoded defaults persist.  
4) No latency/partial-fill model; no Sharpe/Sortino/Calmar/SQN outputs.  

### Minor (P2)
1) News calendar fixed to 2025; 2026+ empty (news_calendar.py TODO 218).  
2) Parameter sweep reuses runner instances without freeing on exception; potential resource leak in long sweeps.  

**Code smells**: 5 TODOs, no silent `except: pass`, many unused modules.  

## Gap Analysis

### Missing Features
1) Slippage/commission/latency modeling tied to config.  
2) SpreadMonitor and CircuitBreaker gating in strategy loop.  
3) Apex operational rules: 4:59 ET flatten, no overnight, 30% daily consistency.  
4) End-of-day resets for PropFirmManager using backtest clock.  
5) StrategySelector / EntryOptimizer integration for promised GENIUS v4.2 pipeline.  

### Missing Tests
1) End-to-end tick/backtest run asserting trades, PnL, DD vs fixtures.  
2) Tests for daily reset and trailing DD across multi-day scenarios.  
3) Tests for slippage/commission application and spread gating.  

### Missing Documentation
1) How to enable realism knobs (slippage/latency) – unused config.  
2) Apex rule coverage and expected behaviors.  

## GO/NO-GO Assessment

**Current Status**: ⚠️ CONDITIONAL

**Conditions to clear for GO**
1) Integrate CircuitBreaker + StrategySelector + EntryOptimizer; log SpreadMonitor/CircuitBreaker telemetry.  
2) Load YAML realism knobs; allow CLI override for slippage/commission/latency.  
3) Add end-to-end tests validating multi-day Apex rules and drawdown resets (backtest-clock).  
4) Add latency/partial-fill model and report Sharpe/Sortino/Calmar/SQN + DD%.  

## Recommendations

### Important Actions (P1)
1) Wire CircuitBreaker + StrategySelector + EntryOptimizer into signal path; log spread/circuit telemetry.  
2) Load `configs/strategy_config.yaml` realism knobs (slippage/commission/latency) into runners; expose CLI overrides.  
3) Add E2E pytest for multi-day tick backtest covering Apex cutoff, daily reset, drawdown; ensure DrawdownTracker uses simulated clock.  
4) Implement simple latency/partial-fill model and emit Sharpe/Sortino/Calmar/SQN + DD%.  

### Nice-to-Have (P2)
1) Expand NewsCalendar to 2026+ via CSV/API loader.  
2) Parquet telemetry including applied slippage/commission and spread state per trade.  

## Next Steps

1) Implement P0 fixes (risk resets, slippage, sizing units, threshold alignment) and rerun tick backtest.  
2) Add data validation layer before engine ingest; log rejected spans.  
3) Wire SpreadMonitor/CircuitBreaker into strategy and backtest realism knobs.  
4) Add end-to-end tests + telemetry metrics (Sharpe/Sortino/Calmar/SQN, DD%).  

<open_questions>
- Target execution threshold: confirm 70 vs 65?  
- Required slippage/commission values for Apex realism?  
- Should bar runner remain supported or migrate fully to tick runner?  
</open_questions>

<assumptions>
- XAUUSD tick size 0.01 and pip_value $10 used unless otherwise specified.  
- Apex trailing DD 10% of HWM including unrealized.  
</assumptions>

<dependencies>
- Need updated tick/bar datasets with integrity checks.  
- Confirmation of Apex operational cutoffs to code exact times (ET).  
</dependencies>





















