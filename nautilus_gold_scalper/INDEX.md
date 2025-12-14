# Nautilus Gold Scalper – Project Index

**Owner:** FORGE  
**Scope:** Python/NautilusTrader migration of EA_SCALPER_XAUUSD  
**Last update:** 2025-12-03
**Last update:** 2025-12-11
## Directory Map (high level)
- `configs/` – central strategy config (`strategy_config.yaml`)
- `scripts/` – runners (`run_backtest.py`, future batch/optuna hooks)
- `src/core/` – enums, constants, datatypes, exceptions
- `src/indicators/` – regime, structure, footprint, OB/FVG, sweeps, AMD, MTF
- `src/signals/` – confluence (GENIUS v4.2), news, entry optimizer, MTF manager
- `src/risk/` – prop-firm manager, position sizer, spread monitor, circuit breaker, drawdown/VaR
- `src/strategies/` – base & gold strategy, selector
- `src/ml/` – feature engineering, trainer, ensemble predictor
- `src/execution/` – trade manager (needs test fix), adapters archive
- `tests/` – unit coverage per module family
- `reports/backtests/` - output/logs (telemetry CSV from runners)

## Documentation (root level)
- `INDEX.md` – This file: structural overview + current state
- `CHANGELOG.md` – Detailed log of COMPLETED work units (features, bugfixes, improvements)
- `BUGFIX_LOG.md` – Quick reference for bugs discovered + fixes (debugging focus)
- `FUTURE_IMPROVEMENTS.md` – Brainstorming repository for optimization ideas (WHY/WHAT/IMPACT/EFFORT/PRIORITY)
- `README.md` – Project overview + quick start
- `*.md` (other) – Implementation notes, migration summaries

## Current State (backtesting realism)
- Tick-first Nautilus runner (`scripts/run_backtest.py`): auto-detects tick files under `Python_Agent_Hub/ml_pipeline/data`, converts to `QuoteTick`, aggregates to M5 bars, defaults to all ticks (sample=1), execution threshold 70.
- Prop/FTMO risk tightened: intrabar mark-to-market + `DrawdownTracker` enforcing daily/total DD; auto-halt + flatten on breach; daily reset wired.
- News-aware: `GoldScalperStrategy` now gates signals with `NewsCalendar` (blocking CRITICAL/HIGH windows, score penalty, size multiplier).
- Footprint thresholds rebalanced (strong-signal threshold 60) to align with tests; still feeds confluence.
- MT5/Ninja adapters stubbed (`src/execution/mt5_adapter.py`, `ninjatrader_adapter.py`) plus base offline adapter.
- All Python tests green: `python -m pytest tests` (183 passed).
- Config single-source: `configs/strategy_config.yaml` now holds execution realism, spread monitor, cutoff times, circuit breaker, consistency cap, and telemetry JSONL path.
- Telemetry: JSONL sink (`logs/telemetry.jsonl`) captures spread/circuit/cutoff/partial-fill events for audits.

## Open Issues (next)

### 🚨 CRITICAL BUGS (2025-12-11 Analysis)
- ✅ FIXED: Look-ahead bias in ML feature_engineering.py (swing points with center=True)
- ✅ FIXED: Missing `_min_bars_for_signal` attribute in base_strategy.py
- ❌ PENDING: Pickle security in model_trainer.py / ensemble_predictor.py (should be ONNX-only)
- ❌ PENDING: 4:59 PM ET deadline NOT enforced in execution adapters (Apex violation risk)
- ❌ PENDING: Slippage model not integrated with base_adapter.py (unrealistic backtests)
- ❌ PENDING: News calendar hardcoded to Dec 2025 only

### P1 - High Priority
1) Batch runner still bar-based (`scripts/batch_backtest.py`); upgrade to tick pipeline + news gating for large sweeps.  
2) Telemetry JSONL added; still need Parquet schema (signal/open/close, news context, DD) for 1k+ backtests.  
3) Strategy still runs with HTF disabled when using tick-only bars; optional H1 reconstruction from ticks is pending.  
4) News events rely on hardcoded 2025 calendar; add loader for CSV/API and inject per-backtest window.  
5) Execution adapters: wire real MT5/Ninja connections (currently offline stubs) and decide venue routing.  
6) Prop firm circuit breaker: mapped to YAML thresholds; still need stress tests + cooldown tuning.

## Planned Improvements (backtest scale & quality)
### P2 - Medium Priority (from 2025-12-11 Analysis)
7) ONNX input shape validation missing in ensemble_predictor.py
8) Stacking ensemble not integrated in ensemble_predictor.py (advertised but unused)
9) DSR (Degradation Score Ratio) not calculated in WFA (model_trainer.py)
10) OOS Sharpe ratio not calculated in WFA (requires trade simulation)

- Tick batch sweeps + WFA using same QuoteTick pipeline; reuse new news/DD gating.
- Parquet telemetry writer + CLI (`--parquet`, `--logdir`); aggregate summary CSV.
- Optional H1/H15 bar rebuild from ticks to re-enable full MTF alignment while staying tick-realistic.
- News data source abstraction (CSV/API) with backtest-time clock injection; toggle via CLI `--no-news`.
- Execution realism knobs: latency drift model, variable slippage by spread regime.
- Position sizing hooks: apply footprint/news/drawdown multipliers to risk% (partially in place).

## Changelog (recent)
- 2025-12-11: **DEEP ANALYSIS** by FORGE - Found 7 bugs, fixed 2 critical (look-ahead bias in feature_engineering.py, missing `_min_bars_for_signal` in base_strategy.py)
- 2025-12-03: NewsCalendar injected into GoldScalperStrategy (block/size/score), intrabar drawdown guard, MTM equity, daily reset tied to tracker.  
- 2025-12-03: Tick runner defaults (sample=1, threshold=65), CLI `--no-news`, param sweep uses filters on.  
- 2025-12-03: Footprint strong-signal threshold lifted to 60 to align with stacked+absorption tests.  
- 2025-12-03: Fixed test blockers: TradeManager signature, DrawdownTracker (severity/streaks/analysis API), PropFirmManager (PropFirmLimits/RiskLevel compatibility).  
- 2025-12-03: YAML-driven backtest realism (slippage/latency/commission), prop-firm gate, PositionSizer, footprint score in confluence, spread-aware risk, telemetry CSV, equity/DD tracking (`scripts/run_backtest.py`).  
- 2025-12-03: Footprint Analyzer configurable (decay, score bounds); confluence logs footprint score/direction.  
- 2025-12-03: Added `configs/strategy_config.yaml` as single source of tunables.

## Test Status
- Passing: `python -m pytest tests` (183 passed, warnings only from onnx test returns).  

## Notes for Future Work
- Add Parquet logging before launching "thousands" of backtests to avoid CSV overhead.  
- Align PropFirmManager soft/hard limits with YAML (`dd_soft`, `dd_hard`, `max_total_loss_pct`).  
- Consider integrating Optuna objectives: maximize PF subject to MaxDD < 8%, hit-rate > 48%, avg RR > 1.8.
