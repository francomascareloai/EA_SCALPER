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
