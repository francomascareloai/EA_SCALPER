# Configuration Guide (Nautilus Gold Scalper)

This guide documents where configuration lives and how to run controlled experiments (backtest + optimizer) without hunting through code.

## What Controls What

### 1) Data selection (dataset paths)

- **Data config (single source of truth):** `nautilus_gold_scalper/data/config.yaml`
  - `active_dataset.path`: Parquet tick file (used by `--source parquet` and by default in `--source auto`).
  - `active_dataset.native_catalog_path`: Nautilus native catalog directory (used by `--source catalog`, or via `--catalog-path/--catalog-paths`).

Key implementation: `nautilus_gold_scalper/scripts/backtest/run_backtest.py:1463`.

### 2) Strategy behavior (trading knobs)

- **Strategy config (single source of truth):** `nautilus_gold_scalper/configs/strategy_config.yaml`
  - This file drives `GoldScalperConfig` (the dataclass that the strategy consumes).

Key implementation: `nautilus_gold_scalper/scripts/backtest/run_backtest.py:585` (`build_strategy_config`).

### 3) Runtime overrides (CLI and optimizer)

There are two override mechanisms:

- **CLI flags** on `run_backtest.py` (best for quick experiments).
- **Optimizer dotpaths** (best for systematic sweeps).

Both end up as a nested `config_overrides` dict which is merged into the YAML dict via `_deep_update`.

Key implementation:
- Merge: `nautilus_gold_scalper/scripts/backtest/run_backtest.py:1335`
- Dotpath expansion: `nautilus_gold_scalper/src/optimization/optimizer.py:44` (`_expand_dotpaths`).

## Precedence (What Wins)

Order of precedence for final config values:

1. CLI arguments (translated into `config_overrides`)
2. `config_overrides` passed programmatically (optimizer)
3. `nautilus_gold_scalper/configs/strategy_config.yaml`
4. Code defaults in `build_strategy_config` and `GoldScalperConfig`

Note: `run_backtest.py` also force-sets some runtime values so runs are reproducible (e.g., threshold, slippage, latency) after applying overrides.

## Backtest CLI (How to Run)

Canonical runner:
- `nautilus_gold_scalper/scripts/backtest/run_backtest.py`

Compatibility wrapper:
- `nautilus_gold_scalper/scripts/run_backtest.py` (imports the canonical runner)

### Common patterns

#### Recommended workflow (fast validation → final verification)

1) **Smoke/validation (fast):**
- Use default Parquet stride20 (`data/config.yaml active_dataset.path`).
- Run `--smoke-matrix` (ticks feed, source=parquet) over a short window to validate flag wiring and determinism.

2) **Final verification (slow, highest fidelity):**
- Use `--source catalog` (native ParquetDataCatalog stride1) on a smaller curated period (or session-sliced catalogs).
- Only do this after smoke passes to avoid wasting hours on broken wiring.


- **Single run (ticks feed, parquet source):**
  - Uses `data/config.yaml active_dataset.path` (default: Parquet stride20).
  - Most live-like (but slower).

- **Fast screening (bars feed):**
  - Uses bars instead of ticks.
  - If you use `--bars-file`, it currently supports M5 only.

### Data source selection

`--source` controls how ticks/bars are loaded:

- `--source auto` (default): uses Parquet (`active_dataset.path`).
- `--source parquet`: same as auto, explicit.
- `--source catalog`: uses Nautilus native catalog.

Important realism/memory note:
- Catalog mode can load huge amounts of ticks into RAM before sampling.
- For stride1 catalogs, this can require very large memory; prefer parquet (stride20) for normal iteration.

Implementation: `nautilus_gold_scalper/scripts/backtest/run_backtest.py:1514`.

### Timeframes (LTF/MTF/HTF)

- **Runner LTF (primary):** `--ltf-minutes`
- **Config LTF:** `execution.ltf_bar_minutes`

These must match. If they diverge, the runner fails fast:
- `nautilus_gold_scalper/scripts/backtest/run_backtest.py:772`

Reason: the engine aggregates bars at `--ltf-minutes`, and the strategy must not believe it is operating on a different bar size.

MTF/HTF can be explicitly set in YAML:
- `execution.mtf_bar_minutes`
- `execution.htf_bar_minutes`

## Strategy YAML Reference (`strategy_config.yaml`)

This is the practical map of the highest-impact sections.

### `confluence:` (scoring + weights)

- `confluence.min_score_to_trade`: main score gate.
- `confluence.weights.*`: per-factor weight caps used by the scorer.

### `execution:` (trade lifecycle + features)

Core execution knobs:
- `execution.execution_threshold`: mirrors confluence threshold for convenience.
- `execution.slippage_ticks`, `execution.latency_ms`: execution realism.
- `execution.fill_model`: engine-side fill model selection.

Feature toggles:
- `execution.use_session_filter`, `execution.use_regime_filter`, `execution.use_mtf`, `execution.use_footprint`.

Apex time/rules related:
- `execution.allow_overnight`: should stay `false`.
- `time.cutoff_et`, `time.urgent_et`, `time.emergency_et`: time gates.

Phase 11 safety layer:
- `execution.virtual_gate_enabled` and related `virtual_gate_*`
- `execution.vol_spacing_*`
- `execution.max_concurrent_positions`, `execution.max_concurrent_instruments`

### `risk:`

- `risk.max_risk_per_trade`: risk fraction per trade.
- `risk.dd_soft`, `risk.dd_hard`: drawdown buffers.

### `news:`

- `news.enabled`
- `news.events_path`: local calendar file.

## TrendFollow Configuration (YAML + CLI)

### YAML keys (under `execution:`)

- Enablement:
  - `enable_trend_follow` (master toggle)
  - `trend_follow_mode`: `PULLBACK_ONLY | BREAKOUT_ONLY | BOTH`
  - `enable_trend_pullback`, `enable_trend_breakout`

- MA type + periods:
  - `trend_ma_type`: `EMA | SMA | WMA | HMA`
  - `trend_ema_fast`, `trend_ema_slow`

- Pullback strictness:
  - `trend_pullback_require_recross`
  - `trend_pullback_recross_lookback`

- Breakout gate:
  - `trend_er_enabled`
  - `trend_er_min`

- Signal tuning:
  - `trend_sep_ticks_min`
  - `trend_touch_dist_mult`
  - `trend_min_score`

- Ablations (debugging):
  - `ghost_mode` + `ghost_seed`
  - `trend_direction_mode`: `NORMAL | INVERT`

### CLI flags → YAML mapping

All of the following flags set `config_overrides.execution.*` inside `run_backtest.py`:

- `--enable-trend-follow` → `execution.enable_trend_follow=true`
- `--trend-follow-mode {PULLBACK_ONLY,BREAKOUT_ONLY,BOTH}` → `execution.trend_follow_mode`
- `--trend-ma-type {EMA,SMA,WMA,HMA}` → `execution.trend_ma_type`
- `--trend-ema-fast N` → `execution.trend_ema_fast`
- `--trend-ema-slow N` → `execution.trend_ema_slow`
- `--trend-sep-ticks X` → `execution.trend_sep_ticks_min`
- `--trend-touch-dist-mult X` → `execution.trend_touch_dist_mult`
- `--trend-min-score X` → `execution.trend_min_score`
- `--trend-pullback-require-recross` → `execution.trend_pullback_require_recross=true`
- `--trend-pullback-recross-lookback N` → `execution.trend_pullback_recross_lookback`
- `--trend-er-enabled` → `execution.trend_er_enabled=true`
- `--trend-er-min X` → `execution.trend_er_min`
- `--ghost-mode` → `execution.ghost_mode=true`
- `--ghost-seed N` → `execution.ghost_seed`
- `--trend-direction-mode {NORMAL,INVERT}` → `execution.trend_direction_mode`

Implementation: `nautilus_gold_scalper/scripts/backtest/run_backtest.py:2396`.

## PSAR Configuration

YAML keys (under `execution:`):
- `psar_enabled`
- `psar_step`, `psar_max`
- `psar_use_prev_bar` (default)
- `psar_trend_use_prev_bar`, `psar_smc_use_prev_bar` (optional overrides)

CLI:
- `--psar-enabled` sets `execution.psar_enabled=true`.
- `--psar-use-prev-bar {trend,smc,both,none}` sets which arm(s) use `t-1` vs the latest bar.

## Safety Layer CLI (Quick toggles)

These flags avoid editing YAML for quick diagnostics:

- `--no-virtual-gate` → `execution.virtual_gate_enabled=false`
- `--no-vol-spacing` → disables vol spacing (`execution.vol_spacing_max_seconds=0.0`)
- `--no-exposure-caps` → `execution.max_concurrent_positions=99` and `execution.max_concurrent_instruments=99`

Implementation: `nautilus_gold_scalper/scripts/backtest/run_backtest.py:2357`.

## Optimizer (How the grid YAML works)

Entry point:
- `nautilus_gold_scalper/scripts/optimize.py`

A grid YAML (examples):
- `nautilus_gold_scalper/configs/grids/all_strategies_optimization_fast.yaml`
- `nautilus_gold_scalper/configs/grids/all_strategies_optimization_full.yaml`

### Grid structure

- `search`: mode, trials, parallelism, seeds, successive halving schedule.
- `parameters`: sweepable parameters, expressed as **dotpaths**.
- `fixed`: fixed dotpaths applied to all trials.

Dotpath example:
- `execution.trend_ma_type: {type: categorical, choices: ["EMA","SMA","WMA","HMA"]}`

### How dotpaths apply

- Optimizer generates a flat dict of dotpaths.
- Dotpaths expand into nested dicts via `_expand_dotpaths`.
- The resulting nested dict is fed into the backtest runner as `config_overrides`.

Implementation:
- `nautilus_gold_scalper/src/optimization/optimizer.py:44`
- `nautilus_gold_scalper/scripts/backtest/run_backtest.py:1335`

## Quick sanity checks

- Backtest CLI help:
  - `python nautilus_gold_scalper/scripts/backtest/run_backtest.py --help`
- Optimizer CLI help:
  - `python nautilus_gold_scalper/scripts/optimize.py --help`
