# Nautilus Gold Scalper - Code Change Log

**Purpose:** Log COMPLETED work units (features, improvements, breaking changes, config)  
**Owner:** FORGE, NAUTILUS  
**Format:** Chronological (newest first)  
**When:** ONLY when work unit fully complete (all edits done, tests passing). NOT during individual edits.  
**Usage:** Understand what changed, why, and impact. Prevent getting lost in codebase evolution.

---

## Template (copy for new entries)

```markdown
## [Module] - YYYY-MM-DD HH:MM (AGENT)

### 🐛 BUGFIX | 🚀 IMPROVEMENT | ✨ FEATURE | ⚠️ BREAKING | ⚙️ CONFIG

**What:** Brief description (1 line)  
**Why:** Problem solved / motivation / context  
**Impact:** What changed (behavior, API, performance, dependencies)  
**Files:**
- path/to/file1.py
- path/to/file2.py

**Validation:** Tests passed, compilation status, quality gates
**Commit:** [hash if committed]
```

---

## Multi-Fidelity Suite: BOHB + ASHA + Warm-start + Adaptive Fidelity - 2025-12-28 (Claude)

### ✨ FEATURE: Complete multi-fidelity optimization suite

**What:**
- Added `BOHBSearch` - Bayesian Optimization + Hyperband (3-10x faster than standard BO)
- Added `ASHASearch` - Asynchronous Successive Halving (no sync barriers, better parallelism)
- Added `WarmStartProvider` - Reuse results from previous optimization runs
- Added `AdaptiveFidelitySelector` - Dynamic fidelity selection per configuration

**Why:**
- BOHB: Combines TPE intelligence with Hyperband's early stopping for efficient exploration
- ASHA: Enables async parallel evaluation without waiting for slowest trial
- Warm-start: Transfer knowledge between runs, skip already-evaluated configs
- Adaptive fidelity: Cost-aware evaluation decisions using bandit-like approach

**Impact:**
- New search modes: "bohb", "asha" (in addition to existing modes)
- SearchMode type updated with new options
- optimizer.py handles both BOHB and ASHA modes
- 14 new tests in test_bohb_asha.py (all passing)
- Phase 12 MASTER doc updated to v2.2

**Files:**
- src/optimization/search/bohb.py (NEW)
- src/optimization/search/asha.py (NEW)
- src/optimization/warmstart.py (NEW)
- src/optimization/adaptive_fidelity.py (NEW)
- src/optimization/search/__init__.py (MODIFIED)
- src/optimization/config.py (MODIFIED)
- src/optimization/optimizer.py (MODIFIED)
- tests/test_optimization/test_bohb_asha.py (NEW)

**Validation:** All 40 optimization tests pass, mypy clean on new files (except expected subclass errors)

---

## Sobol Sequences for Multi-Fidelity Optimization - 2025-12-28 (Claude)

### ✨ FEATURE: Add Sobol sampler (~3.5x better convergence than LHS)

**What:**
- Added `StreamingSobolGenerator` in `src/optimization/streaming/generator.py`
- Sobol sequences provide quasi-random sampling with lower discrepancy than LHS
- New sampler option "sobol" in `successive_halving.sampler` config

**Why:**
- Research shows Sobol converges ~3.5x faster than LHS for numerical integration
- Better space-filling properties = fewer wasted trials
- LHS needs ~440k samples for same precision as Sobol with ~50k

**Impact:**
- Samplers available: "lhs" (default), "sobol" (recommended), "levy"
- Sobol uses `scipy.stats.qmc.Sobol` with scrambling for reproducibility
- Supports float (continuous + log_scale), int (range), and categorical params
- Default config updated to use "sobol" sampler

**Files:**
- `nautilus_gold_scalper/src/optimization/streaming/generator.py` (StreamingSobolGenerator)
- `nautilus_gold_scalper/src/optimization/streaming/__init__.py` (exports)
- `nautilus_gold_scalper/src/optimization/search/successive_halving.py` (wiring)
- `nautilus_gold_scalper/src/optimization/config.py` (validation)
- `nautilus_gold_scalper/configs/grids/smc_optimization_fast.yaml` (default→sobol)
- `nautilus_gold_scalper/tests/test_optimization/test_successive_halving_search.py` (2 new tests)

**Validation:** pytest PASS (4 tests); mypy PASS (no new errors)
**Commit:** Pending

---

## TelemetrySink v2 Performance Optimization - 2025-12-28 (Claude)

### 🚀 IMPROVEMENT: Reuse file handle in TelemetrySink (3.42x faster)

**What:**
- Rewrote `TelemetrySink` to keep file handle open (line-buffered) instead of open/close per event.
- Added fork detection via PID check for multiprocess safety.
- Added explicit `close()` method called in `GoldScalperStrategy.on_stop()`.

**Why:**
- Telemetry overhead was ~30% of total backtest time when enabled.
- Heavy telemetry (100k events) would add 14+ seconds of pure file I/O overhead.
- Microbenchmark: 20k events took 4.078s (v1) vs 1.194s (v2) = 3.42x speedup.

**Impact:**
- For current 985 events/20d: ~142ms savings
- For heavy telemetry (100k events): 14.4s savings (20.4s → 6.0s)
- Trade determinism preserved (trade_signature SHA matches across runs)
- Line-buffered writes (buffering=1) ensure durability without syscall overhead

**Files:**
- `nautilus_gold_scalper/src/utils/telemetry.py` (major rewrite)
- `nautilus_gold_scalper/src/strategies/gold_scalper_strategy.py` (added close() call)
- `nautilus_gold_scalper/tests/test_utils/test_telemetry_sink.py` (new test file)

**Validation:** mypy --strict PASS; pytest PASS; trade_signature SHA matches
**Commit:** Pending

---

## Deprecate Parquet Tick Source - 2024-12-28 (GPT-5.2)

### ⚠️ BREAKING: Remove `--source parquet`, require catalog for tick backtests

**What:**
- Removed `parquet` as a valid `--source` option.
- Tick feed now requires catalog source (`--source catalog` with `--catalog-stride`).
- Fidelity check (`--fidelity-stride1`) now uses catalog stride20 vs catalog stride1 (both catalog-based).
- Dead code paths for parquet tick loading and tick-to-bar resampling removed.

**Why:**
- Catalog is faster, more memory-efficient, and produces more accurate results.
- Parquet loading was a legacy path that loaded entire DataFrame into memory.
- Comparison test: catalog stride1 = +$458.92, catalog stride20 = -$413.80 (1-day test).

**Impact:**
- `--source parquet` is no longer valid (CLI error).
- For bars feed, must use `--bars-file` or `--bars-agg renko`.
- No fallback to parquet when catalog not found.

**Files:**
- `nautilus_gold_scalper/scripts/backtest/run_backtest.py`
- `nautilus_gold_scalper/docs/configuration/CONFIGURATION_GUIDE.md`

**Validation:** mypy --strict PASS; catalog stride1/stride20 backtests PASS
**Commit:** Pending

---

## Phase B: RiskEngineConfig hardening (modify rate + max notional enforcement) - 2025-12-28 (GPT-5.2)

### ⚙️ CONFIG + ✅ SAFETY: Wire `max_order_modify_rate` + enforce `max_notional_per_order`

**What:**
- Added YAML support for `risk_engine.max_order_modify_rate` (paired with submit rate).
- Extended `_risk_engine_config_from_cfg(...)` to parse `max_order_modify_rate`.
- Added focused integration test proving `RiskEngineConfig.max_notional_per_order` actually denies oversized market orders.

**Why:**
- Rate limiting and notional caps are engine-level guardrails which reduce order spam and fat-finger exposure.
- We want an explicit test that the guardrail is real (not just config parsing).

**Impact:**
- Default behavior unchanged unless you set new YAML keys.
- Adds a safety rail which can prevent runaway exposure; keep values conservative and verify emergency close still works.

**Files:**
- `nautilus_gold_scalper/configs/strategy_config.yaml`
- `nautilus_gold_scalper/scripts/backtest/run_backtest.py`
- `nautilus_gold_scalper/tests/test_backtest/test_risk_engine_config_wiring.py`
- `nautilus_gold_scalper/tests/test_backtest/test_risk_engine_notional_enforcement.py`

**Validation:** mypy --strict PASS; pytest PASS
**Commit:** Pending

---

## Backtest Runner: sizing engine + tick sort stability - 2025-12-28 (GPT-5.2)

### 🐛 BUGFIX + ⚙️ CONFIG: Stable tick sorting + `--sizing-engine` override

**What:**
- Fixed tick backtest sorting crash by switching to `engine.add_data(..., sort=True)` (ticks + bars).
- Added/validated `--sizing-engine {custom,nautilus_fixed}` CLI override so A/B tests don’t require editing YAML.
- Backtest outputs now include deterministic signatures (`trade_signature.json`, `trade_signature_v2.json`) under `--out-dir` for drift checks.

**Why:**
- Some Nautilus builds fail on `BacktestEngine.sort_data()` because `QuoteTick` is not orderable.
- Controlled experiments need an easy CLI-level toggle for sizing logic.

**Impact:**
- Backtests no longer depend on QuoteTick ordering semantics of the installed Nautilus build.
- Enables fast comparisons: `custom` vs `nautilus_fixed` sizing on the same window and feed.
- Artifacts stored under `nautilus_gold_scalper/_artifacts/backtests/` for audit/repro.

**Files:**
- `nautilus_gold_scalper/scripts/backtest/run_backtest.py`

**Artifacts (examples):**
- `nautilus_gold_scalper/_artifacts/backtests/sizing_compare/custom_20240102_20240105/trade_signature_v2.json`
- `nautilus_gold_scalper/_artifacts/backtests/sizing_compare/nautilus_fixed_20240102_20240105/trade_signature_v2.json`

**Validation:** mypy --strict PASS; pytest PASS
**Commit:** Pending

---

## Backtest Performance Optimization (deterministic) - 2025-12-27 (GPT-5.2)

### 🚀 IMPROVEMENT: Reduce tick backtest runtime without trade drift

**What:** Optimized hot paths in `GoldScalperStrategy` to reduce allocations and repeated conversions during `_check_for_signal()` and VirtualGate evaluation.

**Why:** Tick backtests were spending most time inside `engine_run` and strategy hot loops. The goal was to cut wall time while preserving exact trade decisions.

**Impact:**
- Determinism preserved using `trade_signature_v2.json` hashing across repeated runs.
- Primary speedups came from avoiding repeated Bar→Price allocations and reducing Python-level loops.
- Added lightweight caching for ET timezone and repeated timestamp conversions.

**Measured results (selected):**
- Day 2024-01-02 (ticks, reports none):
  - stride=1: `engine_run=16.240s`
  - stride=5: `engine_run=3.936s` (4.13x)
  - stride=10: `engine_run=2.317s` (7.01x)
  - stride=20: `engine_run=1.277s` (12.72x)
- Month 2025-06:
  - stride=1: `engine_run=468.877s`
  - stride=5: `engine_run=137.041s` (3.42x)
  - stride=10: `engine_run=75.126s` (6.24x)
  - stride=20: `engine_run=43.232s` (10.85x)
- Month 2025-06 (stride=1, reports full): `engine_run=635.629s`, PnL `-$994.33` (35 trades)

**Files:**
- `nautilus_gold_scalper/src/strategies/gold_scalper_strategy.py`
- `nautilus_gold_scalper/src/strategies/base_strategy.py`

**Artifacts (examples):**
- `nautilus_gold_scalper/_artifacts/_cmp_day_2024-01-02_stride20/profile.json`
- `nautilus_gold_scalper/_artifacts/_cmp_month_2025-06_stride20/profile.json`
- `nautilus_gold_scalper/_artifacts/_month_2025-06_stride1_reports_full/profile.json`

**Validation:** mypy --strict PASS; pytest PASS; repeated backtests MATCH via trade_signature_v2
**Commit:** Pending

---

## Execution Timeframes (Entry vs Management) - 2025-12-26 (FORGE)

### ⚙️ CONFIG + ✨ FEATURE: Configurable LTF/MTF/HTF minutes + management rate-limit

**What:** Added YAML-driven timeframe minutes for entry (LTF), multi-timeframe analysis (MTF/HTF), and a management timeframe that rate-limits trade management updates on quote ticks.

**Why:** Enable fast backtesting across TFs (M5/M15/M30/H1/H4) while keeping execution semantics deterministic and avoiding extra bar-series wiring / look-ahead risk for management logic.

**Impact:**
- New YAML keys under `execution:`: `ltf_bar_minutes`, `mtf_bar_minutes`, `htf_bar_minutes`, `management_bar_minutes` (defaults: 15/30/60/60)
- `run_backtest.py` enforces `execution.ltf_bar_minutes` == runner `--ltf-minutes` to prevent silent mismatches
- `MTFManager` now uses explicit timeframe enums derived from config minutes
- `GoldScalperStrategy` rate-limits `_process_trade_management(...)` by `management_bar_minutes` using `QuoteTick.ts_event`
- CLI defaults aligned to Entry=M15 to match YAML defaults (runner + optimizer)

**Files:**
- `nautilus_gold_scalper/configs/strategy_config.yaml`
- `nautilus_gold_scalper/scripts/backtest/run_backtest.py`
- `nautilus_gold_scalper/src/strategies/gold_scalper_strategy.py`
- `nautilus_gold_scalper/src/signals/mtf_manager.py`
- `nautilus_gold_scalper/tests/test_backtest/test_temporal_leakage_guards.py`

**Validation:** mypy --strict PASS; pytest PASS
**Commit:** Pending

---

## [MULTI-AGENT AUDIT] - 2025-12-26 (FORGE + CRUCIBLE + CRITIC)

### 🐛 BUGFIX: Comprehensive codebase audit - 6 bugs fixed

**Follow-up hardening (determinism + time semantics):**
- Enforced `timestamps: np.datetime64[]` contract end-to-end for MTF structure analysis (MTFManager → StructureAnalyzer) to prevent silent epoch/bar-index misinterpretation.
- Made footprint tick simulation fail-closed on `seed=None` to prevent nondeterministic backtest drift (default remains deterministic).

**Validation:** mypy --strict PASS; pytest PASS

**What:** Multi-agent comprehensive audit of entire nautilus_gold_scalper codebase with 4 rodadas de análise + correções automáticas.

**Why:** Validação completa do código antes de go-live para Apex compliance e robustez.

**Impact:**
- **BUG-20 CRITICAL:** SL Cancel/Submit gap fixed - posições agora sempre protegidas durante trailing/breakeven
- **BUG-19 CRITICAL:** Session score agora passa pelos pesos de sessão - evita TIER-B sem SMC
- **BUG-18 HIGH:** AMD weights adicionados em London/NY/Overlap - ICT AMD cycle agora contribui
- **BUG-17 CRITICAL:** Emergency close retry mechanism - posições serão fechadas mesmo com rejeições
- **BUG-16 MEDIUM:** Shannon entropy calculation corrigido - regime detection mais preciso
- **BUG-16b HIGH:** StrategySelector agora usa bar_time - backtest temporal correctness

**Files:**
- `nautilus_gold_scalper/src/strategies/base_strategy.py` (SL failsafe)
- `nautilus_gold_scalper/src/strategies/gold_scalper_strategy.py` (SL failsafe)
- `nautilus_gold_scalper/src/signals/confluence_scorer.py` (session + AMD weights)
- `nautilus_gold_scalper/src/risk/time_constraint_manager.py` (emergency close retry)
- `nautilus_gold_scalper/src/indicators/regime_detector.py` (entropy fix)
- `nautilus_gold_scalper/src/strategies/strategy_selector.py` (bar_time)

**Validation:**
- mypy --strict: PASS
- pytest: 432 tests PASS
- All weight sums verified = 1.00

**Commit:** pending

---

## ML Entry Filter (telemetry → dataset → WFA) - 2025-12-25 (GPT-5.2)

### ✨ FEATURE + 🐛 BUGFIX: ML snapshot capture, dataset builder hardening, WFA JSON stability

**What:**
- Added CLI wiring to generate `ml_snapshot` telemetry during backtests, build a Parquet dataset from telemetry, and run a walk-forward sanity check (real vs ghost).

**Why:**
- Enable fast falsification-first checks for temporal leakage and ML overfit (ghost test baseline), using deterministic backtest telemetry as the single source of truth.

**Impact:**
- Backtest runner now supports forcing ML snapshot capture and telemetry path override:
  - `run_backtest.py --ml-capture --telemetry-path <path>`
- ML config (`ml:`) is now wired into `GoldScalperConfig` at construction time (immutable config).
- Dataset builder now reliably reads heterogeneous telemetry JSONL without dropping late-appearing `ml_snapshot` keys (schema inference across entire file).
- WFA script now works with `@dataclass(slots=True)` and outputs JSON-safe values (no `NaN`/`Inf`).

**Files:**
- `nautilus_gold_scalper/scripts/backtest/run_backtest.py`
  - Added CLI flags: `--ml-capture`, `--telemetry-path`
  - Wired `ml:` YAML keys into `GoldScalperConfig` inside `build_strategy_config()`
- `nautilus_gold_scalper/scripts/ml/build_dataset_from_telemetry.py`
  - Fixed argparse help-string formatting (`%` escaping)
  - Hardened `_read_jsonl()` to use `polars.read_ndjson(..., infer_schema_length=None)` so `ml_snapshot` fields are retained
- `nautilus_gold_scalper/scripts/ml/validate_filter_wfa.py`
  - Fixed fold serialization for `slots=True` dataclass
  - JSON-safe output for folds (avoid `NaN`/`Inf`)

**Artifacts (example outputs from quick run):**
- `logs/telemetry_ml.jsonl` (contains `event=ml_snapshot` rows)
- `logs/ml_dataset_2024-01-01_2024-01-03.parquet` (dataset built from telemetry)
- `logs/wfa_y_good_*_*.json` (WFA outputs)

**Validation:**
- `.venv/bin/pytest -q nautilus_gold_scalper/tests/test_ml/test_build_dataset_from_telemetry.py nautilus_gold_scalper/tests/test_backtest/test_temporal_leakage_guards.py::test_bars_resample_is_labeled_at_bar_close`

---

## Apex Optimizer - 2025-12-24 (GPT-5.2)

### ✨ FEATURE: Add Successive Halving multi-fidelity mode

**What:** Added `successive_halving` search mode to prune weak parameter sets early using rolling date windows + fewer InlineWFA windows.
**Why:** Reduce compute and RAM pressure during optimization by promoting only top configs to higher-fidelity evaluation.
**Impact:**
- New `search.mode: successive_halving` uses `search.trials` as initial pool size, then promotes `ceil(n/eta)` each rung.
- Fidelity is configured via `search.successive_halving.window_days` (rolling windows ending at `data.train_end`, `0` means full window) + `search.successive_halving.wfa_windows`.
**Files:**
- `nautilus_gold_scalper/src/optimization/search/successive_halving.py`
- `nautilus_gold_scalper/src/optimization/optimizer.py`
- `nautilus_gold_scalper/src/optimization/config.py`
- `nautilus_gold_scalper/src/optimization/__main__.py`
- `nautilus_gold_scalper/configs/grids/smc_optimization.yaml`
- `nautilus_gold_scalper/tests/test_optimization/test_successive_halving_search.py`
**Validation:** `.venv/bin/mypy --strict nautilus_gold_scalper/src/optimization/**/*.py`; `.venv/bin/pytest -q nautilus_gold_scalper/tests/test_optimization/test_grid_search.py nautilus_gold_scalper/tests/test_optimization/test_random_search.py nautilus_gold_scalper/tests/test_optimization/test_successive_halving_search.py`

---

## Phase 03 TrendFollow - 2025-12-24 (FORGE/CRITIC)

### 🐛 BUGFIX: Harden TrendFollow gates (fail-closed)

**What:** Hardened TrendFollow activation path with fail-closed config validation and regime stability gating; added Phase 03 TrendFollow report with real backtest metrics.
**Why:** Prevent misconfiguration from increasing aggressiveness and avoid trading without HTF regime context when stability gate is enabled.
**Impact:**
- Invalid `trend_follow_mode` disables TrendFollow (warn-once).
- `regime_stability_min_bars>0` blocks until HTF regime + detector available (warn-once).
**Files:**
- `nautilus_gold_scalper/src/strategies/gold_scalper_strategy.py`
- `.planning/phases/09-strategy-activation/orchestration/PHASE_03_TREND_FOLLOW.md`
**Validation:** `.venv/bin/pytest -q`; CRITIC (Sonnet) verdict GO

---

## nautilus_gold_scalper/scripts/backtest/run_backtest.py - 2025-12-20 18:32 (FORGE)

### ✨ FEATURE: Local NewsCalendar dataset support in backtests

**What:** Enabled deterministic loading of a local economic-events file (CSV/JSON) for `NewsCalendar` during backtests, with YAML + CLI wiring.
**Why:** Support offline, reproducible historical evaluation of news windows without relying on wall-clock time or live APIs.
**Impact:**
- `NewsCalendar` keeps both past+future events; backtests pass bar timestamps via `check_news_window(now=...)`.
- `run_backtest.py` accepts `--news-events-path` to override YAML `news.events_path`.
**Files:**
- `nautilus_gold_scalper/src/signals/news_calendar.py`
- `nautilus_gold_scalper/configs/strategy_config.yaml`
- `nautilus_gold_scalper/scripts/backtest/run_backtest.py`
- `nautilus_gold_scalper/tests/test_signals/test_news_calendar.py`
- `nautilus_gold_scalper/src/signals/NEWS_CALENDAR_USAGE.md`
**Validation:**
- `.venv/bin/pytest -q nautilus_gold_scalper/tests/test_signals/test_news_calendar.py`
- `.venv/bin/mypy --strict nautilus_gold_scalper/src/signals/news_calendar.py`
- `.venv/bin/mypy --strict nautilus_gold_scalper/src/strategies/gold_scalper_strategy.py`
**Commit:** pending

---

## 2025-12-18 19:27 (FORGE)

### ⚙️ CONFIG: Local NautilusTrader docs via symlink

**What:** Added `external/nautilus_trader` symlink workflow (git-ignored) as the preferred, offline NautilusTrader reference (docs + examples + source).
**Why:** Reduce dependence on heavy MCP doc pulls and avoid web/network coupling while keeping usage patterns accurate via official examples.
**Impact:** Agents should search local Nautilus repo first (`external/nautilus_trader/docs`, `external/nautilus_trader/examples`) before falling back to MCP/web; repo stays clean because `external/` is ignored.
**Files:**
- `.gitignore`
- `CLAUDE.md`
- `AGENTS.md`
- `nautilus_gold_scalper/INDEX.md`

**Validation:** `external/nautilus_trader/docs` accessible; symlink present; git ignores `external/`.
**Commit:** pending

---

## 2025-12-20 15:30 (FORGE)

### ⚙️ CONFIG: Enable clock-timer time gates by default (WP1)

**What:** Enabled `TimeConstraintManager` wall-clock enforcement via Nautilus `Clock` timers by default (1s interval).
**Why:** Ensures Apex time gates (4:30 block / 4:55 emergency flatten / 4:59 cutoff) still trigger if market data feed stalls.
**Impact:** Live/paper runs enforce close rules even without ticks/bars; behavior can be disabled/adjusted via `time_gate_use_clock_timer` and `time_gate_timer_interval_ns`.
**Files:**
- `nautilus_gold_scalper/src/strategies/base_strategy.py`
- `nautilus_gold_scalper/tests/test_risk/test_time_constraint_manager.py`

**Validation:** `.venv/bin/pytest -q`, `.venv/bin/mypy --config-file mypy.ini`
**Commit:** pending

---

## 2025-12-20 02:25 (FORGE)

### 🐛 BUGFIX: Execution fail-safe for bracket/IOC reject paths (WP0)

**What:** Added order lifecycle tracking and a hard fail-safe to prevent unprotected positions when bracket SL/TP reject/cancel occurs; clears stale pending SL/TP on IOC entry reject/cancel.
**Why:** Phase 08 identified execution safety as a NO-GO blocker (risk of naked exposure).
**Impact:** Strategy halts + cancels orders + flattens positions on bracket failure; improves correctness under rejects/cancels.
**Files:**
- `nautilus_gold_scalper/src/strategies/base_strategy.py`
- `nautilus_gold_scalper/tests/test_execution/test_execution_failsafe.py`

**Validation:**
- `pytest -q nautilus_gold_scalper/tests/test_execution/test_execution_failsafe.py`
- `pytest -q nautilus_gold_scalper/tests/test_integration/test_strategy_flow.py`

**Commit:** pending

---

## 2025-12-18 22:10 (FORGE)

### ✨ FEATURE (Apex-first): TrendFollow + Adaptive EV Router

**What:** Added optional TrendFollow candidate generation (pullback + breakout) and optional adaptive router (contextual bandit) selecting between SMC vs TrendFollow by EV (R-multiples) with DD penalties.  
**Why:** Enable multi-candidate selection optimized for Apex-style consistency (maximize EV with explicit DD penalty) without changing default behavior unless enabled in config.  
**Impact:** `GoldScalperStrategy` can (optionally) trade TrendFollow candidates and/or use the router to select the best mode per (session, regime, vol bucket); updates only on realized close (no look-ahead).  
**Files:**
- `src/signals/trend_follow.py`
- `src/strategies/adaptive_router.py`
- `src/strategies/gold_scalper_strategy.py`
- `scripts/backtest/run_backtest.py`
- `configs/strategy_config_apex_mgc.yaml`
- `tests/test_signals/test_trend_follow.py`
- `tests/test_strategies/test_adaptive_router.py`

**Validation:** `pytest -q` passing (warnings only).  
**Commit:** pending

---

## 2025-12-08 19:00 (FORGE)

### 🚨 CRITICAL SECURITY UPDATE

**What:** Fixed 7 CRITICAL GAPS in AGENTS.md for $50k account protection + added critical_bug_protocol  
**Why:** Franco identified system managing $50k needs maximum quality - gaps could cause account termination  
**Impact:** AGENTS.md v3.6.0 now has BLOCKING enforcement for all critical workflows:
- ✅ GAP #1: Emergency DD >4.5% (was >9% - inconsistent with Apex 5%)
- ✅ GAP #2: Pre-trade Apex checklist MANDATORY (6 checks BLOCK if fail)
- ✅ GAP #3: Trading logic 4-agent review ENFORCED (FORGE→REVIEWER→ORACLE→SENTINEL chain required)
- ✅ GAP #4: Sequential-thinking BLOCKING for CRITICAL tasks (15+ thoughts required, not optional)
- ✅ GAP #5: Production error protocol (immediate halt, 5 Whys, prevention updates)
- ✅ GAP #6: Pre-deploy profiling+coverage MANDATORY (OnTick <50ms, risk/ 90%+ coverage)
- ✅ GAP #7: Handoff gates BLOCKING (can't skip REVIEWER, ORACLE, SENTINEL validation)

**Prevention:** Added `<critical_bug_protocol>` with MANDATORY 5 Whys + Prevention steps for all CRITICAL bugs (Apex violations, $50k risks). Includes production_error_protocol with immediate halt procedures.

**Files:**
- AGENTS.md (v3.6.0 - 7 gaps fixed, critical_bug_protocol added)
- nautilus_gold_scalper/BUGFIX_LOG.md (restructured with CRITICAL template)
- MQL5/Experts/BUGFIX_LOG.md (restructured with CRITICAL template)
- nautilus_gold_scalper/FUTURE_IMPROVEMENTS.md (added SOURCE fields to P1 ideas)

**Validation:** All AGENTS.md sections updated with BLOCKING enforcement, examples added for CRITICAL bug prevention  
**Commit:** pending

---

## 2025-12-08 18:30 (FORGE)

### ✨ FEATURE

**What:** Created FUTURE_IMPROVEMENTS.md brainstorming repository (TEMPLATE FIX - matched to DOCS/ format)  
**Why:** Franco requested "base de ideias" for optimizations + asked to fix template format to match DOCS/02_IMPLEMENTATION/FUTURE_IMPROVEMENTS.md structure  
**Impact:** Clean, organized repository with STATUS GERAL tables (JÁ IMPLEMENTADO vs NÃO IMPLEMENTADO), PHASEs by priority (P1-P4), consistent format per idea (Motivacao/Arquivos alvo/Proposta/Esforco/Dependencies/Referencias). 12 ideas ready: Fibonacci (P1), Kelly (P1), Bayesian (P2), HMM (P2), Transformer (P2), WFO (P3), Meta-learning (P4), etc.  
**Files:**
- nautilus_gold_scalper/FUTURE_IMPROVEMENTS.md (recreated with correct template)
- AGENTS.md (updated future_improvements_tracking section)

**Validation:** Template now matches DOCS/ structure exactly - tables, phases, code examples, archive sections (IMPLEMENTED/REJECTED)  
**Commit:** pending

---

## 2025-12-08 18:00 (FORGE)

### ⚙️ CONFIG

**What:** Created CHANGELOG.md tracking system for COMPLETED work units + BUGFIX_LOG.md for discovered bugs  
**Why:** Franco requested systematic logging to prevent losing context, but ONLY when work complete (not individual edits)  
**Impact:** FORGE/NAUTILUS logs when work unit DONE (e.g., 10 edits = 1 log entry), bugs logged immediately when discovered  
**Files:**
- nautilus_gold_scalper/CHANGELOG.md (this file)
- nautilus_gold_scalper/BUGFIX_LOG.md (created)
- MQL5/Experts/CHANGELOG.md (created)
- MQL5/Experts/BUGFIX_LOG.md (created)
- AGENTS.md (updated code_change_tracking + git_workflow + forge_rule)

**Validation:** Documentation complete, enforcement rules added to AGENTS.md, philosophy: completion-based, NOT edit-based  
**Commit:** pending
