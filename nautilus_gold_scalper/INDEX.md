# Nautilus Gold Scalper – Project Index

**Owner:** FORGE  
**Scope:** Python/NautilusTrader migration of EA_SCALPER_XAUUSD  
**Last update:** 2025-12-25
## Directory Map (high level)
- `configs/` – central strategy config (`strategy_config.yaml`)
- `configs/strategy_config_apex_mgc.yaml` – Apex/MGC profile (TrendFollow + router enabled; commented)
- `scripts/` – runners (`run_backtest.py`, future batch/optuna hooks)
- `src/core/` – enums, constants, datatypes, exceptions
- `src/indicators/` – regime, structure, footprint, OB/FVG, sweeps, AMD (includes deprecated shims)
- `src/signals/` – confluence (GENIUS v4.2), news calendar/gating, entry optimizer, MTF manager (canonical), TrendFollow candidates
- `src/risk/` – prop-firm manager, position sizer, spread monitor, circuit breaker, drawdown/VaR
- `src/strategies/` – base & gold strategy, selector, adaptive router
- `src/ml/` – entry filter runtime (ONNX), training/export, and feature contracts
- `src/execution/` – trade manager (needs test fix), adapters archive
- `tests/` – unit coverage per module family
- `reports/backtests/` - output/logs (telemetry CSV from runners)

## Active Modules (Phase 09 Simplification)

### Strategy Selection
- `src/strategies/strategy_selector.py` selects among `SMC_SCALPER`, `TREND_FOLLOW`, `MEAN_REVERT`, `SAFE_MODE`, or `NONE`.
- News events are handled via selector penalties/blocks + `NewsCalendar` gating in `GoldScalperStrategy` (no dedicated NEWS_TRADER strategy selection).

### Multi-Timeframe (MTF)
- Canonical MTF implementation: `src/signals/mtf_manager.py` (SMC-based structure alignment).
- Deprecated import path: `src/indicators/mtf_manager.py` (shim which re-exports from `src/signals/mtf_manager.py` and emits `DeprecationWarning`).

## Documentation (root level)
- `INDEX.md` – This file: structural overview + current state
- `docs/INDEX.md` – Operational documentation (canonical)
- `docs/configuration/CONFIGURATION_GUIDE.md` – Detailed configuration reference (YAML + backtest CLI + optimizer dotpaths)
- `CHANGELOG.md` – Detailed log of COMPLETED work units (features, bugfixes, improvements)
- `BUGFIX_LOG.md` – Quick reference for bugs discovered + fixes (debugging focus)
- `FUTURE_IMPROVEMENTS.md` – Brainstorming repository for optimization ideas (WHY/WHAT/IMPACT/EFFORT/PRIORITY). Includes **CRUCIBLE (2025-12-24) Portfolio Strategy Review** section.
- `README.md` – Project overview + quick start
- `*.md` (other) – Implementation notes, migration summaries
- Virtual Gate PRD: `DOCS/02_IMPLEMENTATION/PHASES/PHASE_4_INTEGRATION/20251225_VIRTUAL_GATE_PRD/PRD.md`
- Virtual Gate test checklist: `DOCS/02_IMPLEMENTATION/PHASES/PHASE_4_INTEGRATION/20251225_VIRTUAL_GATE_PRD/TEST_CHECKLIST.md`

## Heavy Audit (Strategy Falsification) – 2025-12-24

**Goal:** Kill/confirm edge with falsification-first testing (TrendFollow vs MeanRevert) under realistic costs and Apex constraints.

**Artifacts (source of truth):**
- Folder: `.planning/phases/09-strategy-activation/orchestration/2025-12-24_heavy-audit/`
- Final verdict: `.planning/phases/09-strategy-activation/orchestration/2025-12-24_heavy-audit/SYNTHESIS_FINAL_VERDICT.md`

**What was tested (high-level):**
- Factor isolation: TrendFollow variants vs MeanRevert (`ROUND2_FACTOR_ISOLATION.md`)
- Timeframe analysis: M5 vs M15 (H1 blocked by BarSpecification aggregation) (`ROUND3_TIMEFRAME_ANALYSIS.md`)
- Parameter sensitivity: ADX/RSI/BB/SLTP sweeps (`ROUND4_PARAMETER_SENSITIVITY.md`)
- Final validation: Walk-Forward Analysis windows across 2024 (`ROUND5_WFA_VALIDATION.md`)

**Conclusion (TL;DR):**
- TrendFollow: **TOXIC / ABORT** (catastrophic win rate and/or no signals on M15)
- MeanRevert: **NO-GO** (fails WFA, high variance/regime dependence; no stable OOS edge)
- Key takeaway: if any “edge” exists, it is dominated by the **ADX regime filter**, not BB/RSI signal logic

## Local NautilusTrader reference (offline)
- `external/nautilus_trader/` – symlink to a full NautilusTrader clone (docs + examples + source) for fast local lookup without MCP/web.

## Current State (backtesting realism)
- Tick-first Nautilus runner (`scripts/backtest/run_backtest.py`): reads YAML config (`configs/strategy_config.yaml` by default), loads ticks/bars, and runs the real NautilusTrader backtest engine.
- ML dataset pipeline (telemetry → dataset → WFA):
  - Telemetry: `ml_snapshot` events emitted from `src/strategies/gold_scalper_strategy.py` when `config.ml_capture_enabled=True`.
  - Backtest CLI wiring: `scripts/backtest/run_backtest.py --ml-capture --telemetry-path <path>`.
  - Dataset builder: `scripts/ml/build_dataset_from_telemetry.py` (Parquet output).
  - Walk-forward sanity: `scripts/ml/validate_filter_wfa.py` (real vs `--ghost`).
- Execution realism is engine-first:
  - Fill slippage via `fill_model` passed to `engine.add_venue(...)`.
  - Commissions via `PerContractFeeModel` passed to `engine.add_venue(...)` (converted from USD/lot → USD/unit using `instrument.lot_size`).
  - Latency via `LatencyModel` passed to `engine.add_venue(...)`.
- Strategy-side cost accounting avoids double counting:
  - `slippage_in_fills` is inferred from `execution.fill_model` in the runner and passed into `GoldScalperConfig`.
  - When `slippage_in_fills=True`, the strategy still tracks an execution cost estimate for telemetry but does not subtract slippage again from PnL.
- Commission source of truth is centralized:
  - Config knobs: `execution.commission_source` (`manual|schedule`), `execution.commission_profile` (`apex|ftmo`), `execution.commission_gateway` (`tradovate|rithmic`).
  - Schedule lookup lives in `src/execution/commission_schedule.py` (Apex+MGC is implemented; FTMO schedule intentionally raises until defined).
  - Both the runner (engine fee model) and strategy (ExecutionModel) can reference the same schedule so backtests and live logic don’t drift.
- Risk: intrabar mark-to-market + `DrawdownTracker` enforcing daily/total DD; auto-halt + flatten on breach; daily reset wired.
- News-aware: `GoldScalperStrategy` gates signals with `NewsCalendar` (blocking CRITICAL/HIGH windows, score penalty, size multiplier).
- Telemetry: JSONL sink (`logs/telemetry.jsonl`) captures spread/circuit/cutoff/partial-fill and (optionally) execution-cost estimates for audits.

## Open Issues (next)

### 🚨 CRITICAL BUGS (2025-12-11 Analysis)
- ✅ FIXED: Look-ahead bias in ML feature_engineering.py (swing points with center=True)
- ✅ FIXED: Missing `_min_bars_for_signal` attribute in base_strategy.py
- ✅ FIXED: Pickle disabled; ONNX export working (see `src/ml/model_trainer.py` and `src/ml/ensemble_predictor.py`).
- ❌ PENDING: 4:59 PM ET deadline NOT enforced in execution adapters (Apex violation risk)
- ✅ FIXED (backtests): Slippage model integrated in Nautilus engine runner via venue `fill_model` (see `scripts/backtest/run_backtest.py`).
- ❌ PENDING (adapters): Wire slippage/fees into live execution adapters (MT5/Ninja) where applicable.
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
- 2025-12-24: StrategySelector no longer selects NEWS_TRADER; `src/indicators/mtf_manager.py` is now a deprecation shim to `src/signals/mtf_manager.py`.
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
