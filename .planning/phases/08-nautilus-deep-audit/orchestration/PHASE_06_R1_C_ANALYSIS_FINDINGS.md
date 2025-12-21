REVIEW SUMMARY
==============
AGENT: REVIEWER
VERSION: 2.2
CLAUDE_MD_VERSION: 3.10.16
STATUS: COMPLETE
DATE: 2025-12-19

Scope
- /home/franco/projetos/EA_SCALPER_XAUUSD/scripts/backtest/strategies/fibonacci_analyzer.py
- /home/franco/projetos/EA_SCALPER_XAUUSD/scripts/backtest/strategies/spread_analyzer.py

Objective
- Audit Fibonacci/spread analysis correctness and temporal integrity.
- Identify any mechanisms that can accidentally introduce future-information leakage (e.g., full-series inputs, global aggregates).

Verdict
- CHANGES_REQUIRED

Key conclusions (high signal)
- FibonacciAnalyzer has multiple correctness defects (swing detection semantics + fallback indexing bug) that can invalidate analysis outputs.
- FibonacciAnalyzer is *conditionally causal*: it only remains temporally safe if the caller passes a rolling window ending at the current bar. The API provides no “as-of” index/time contract, making accidental full-series leakage easy.
- SpreadAnalyzer is generally temporally safe (sequential, history-based) but contains accuracy issues (avg includes current sample, session vs global averaging) and a time-to-session estimation bug for negative/large offsets.


TEMPORAL INTEGRITY / LOOK-AHEAD CHECK
====================================

FibonacciAnalyzer
- Swing detection uses a symmetric confirmation window:
  - `highs[i + j]` / `lows[i + j]` are accessed to confirm a swing at index `i`.
  - This is not “look-ahead” if (and only if) analysis is performed at time `t` on data limited to indices `<= t` and you accept a confirmation lag of `lookback` bars.
- Leakage risk (design): the analyzer accepts raw arrays only, no `asof_idx`/timestamp, so a backtest can accidentally pass the entire series (including bars beyond the current simulation time). In that case, cluster segmentation and swing confirmation will implicitly use future bars.

SpreadAnalyzer
- Uses only the current spread and previously-recorded spreads within internal deques.
- No direct mechanism for future data access was found in this module.
- Accuracy caveat: the current spread is recorded before computing the “average”, so the average often includes the same sample being classified.

Evidence-based callsite note (not speculative)
- /home/franco/projetos/EA_SCALPER_XAUUSD/scripts/backtest/run_p1_comparison.py calls:
  - `fib_result = self.fib_analyzer.analyze(highs, lows, entry_price, atr)`
  - In that script, `highs`/`lows` are length 5 synthetic arrays; FibonacciAnalyzer requires `len(highs) >= 20`, so the fib analysis is always invalid and cannot influence TP logic.


ISSUES BY SEVERITY
==================

BLOCKERS (must fix before trusting P1 fib/spread conclusions)
- P06-C-001 (HIGH, Correctness): FibonacciAnalyzer fallback returns a value from the wrong slice.
  - Code:
    - `idx = np.argmax(highs[-50:])`
    - returns index `len(highs) - 50 + idx` but value `highs[idx]` (wrong region).
  - Impact: when monotonic/low-swing data triggers fallback, swing_high/swing_low values can be inconsistent with the returned index and can be materially wrong.
  - Location: /home/franco/projetos/EA_SCALPER_XAUUSD/scripts/backtest/strategies/fibonacci_analyzer.py (find_swing_high / find_swing_low fallback)

- P06-C-002 (HIGH, Correctness): “Most recent swing” implementation scans forward and returns the first swing found.
  - Impact: picks an early swing in the window rather than the most recent confirmed swing; fib levels can be stale and unrelated to current context.
  - Location: /home/franco/projetos/EA_SCALPER_XAUUSD/scripts/backtest/strategies/fibonacci_analyzer.py (find_swing_high / find_swing_low loop direction)

HIGH
- P06-C-003 (HIGH, Temporal-leakage risk): FibonacciAnalyzer has no explicit “as-of” contract; passing full-series arrays in a backtest loop will leak future bars into swing/cluster detection.
  - Evidence: API shape (arrays only) + symmetric swing confirmation + cluster segmentation over absolute indices.
  - Note: No in-repo callsite was found (in Phase 06 R1C scope) that definitively passes full-series arrays at earlier timesteps.

- P06-C-004 (HIGH, Validity of comparison): P1 comparison harness supplies insufficient history (`len(highs)=len(lows)=5`) so FibonacciAnalyzer always returns invalid.
  - Impact: any reported “P1 improvement” from that harness cannot be attributed to fib TP logic.
  - Location: /home/franco/projetos/EA_SCALPER_XAUUSD/scripts/backtest/run_p1_comparison.py

MEDIUM
- P06-C-005 (MEDIUM, Correctness/Design): find_clusters() uses hard-coded bullish levels (`is_bullish=True`) for all swing pairs.
  - Impact: clusters may be wrong/biased for bearish contexts.
  - Location: /home/franco/projetos/EA_SCALPER_XAUUSD/scripts/backtest/strategies/fibonacci_analyzer.py

- P06-C-006 (MEDIUM, Maintainability): FibonacciAnalyzer constructor parameters `golden_pocket_lower`/`golden_pocket_upper` are never used in `calculate_levels()`.
  - Impact: configuration changes silently do nothing; audit risk.

- P06-C-007 (MEDIUM, Accuracy): SpreadAnalyzer computes avg after recording current spread; average may include the current sample, dampening spike detection.
  - Impact: under-classifies spikes, especially early in session.
  - Location: /home/franco/projetos/EA_SCALPER_XAUUSD/scripts/backtest/strategies/spread_analyzer.py (analyze → record_spread before get_average_spread)

- P06-C-008 (MEDIUM, Accuracy): SpreadAnalyzer’s get_average_spread() switches to global recent average once >=20 samples, ignoring session-specific average.
  - Impact: session classification loses meaning when recent samples come from mixed sessions.

LOW
- P06-C-009 (LOW, Correctness): _estimate_time_to_session() normalizes negative hours but not `>= 24` hours when `gmt_offset` is negative.
  - Impact: seconds_until_optimal can be wrong for some offsets.
  - Location: /home/franco/projetos/EA_SCALPER_XAUUSD/scripts/backtest/strategies/spread_analyzer.py

- P06-C-010 (LOW, Maintainability): spike_threshold parameter is stored but not used consistently; hard-coded 1.5 appears in multiple places.


RECOMMENDATIONS (actionable fix plan)
====================================

FibonacciAnalyzer
1. Fix fallback indexing to return a value from the same slice region as the computed index.
2. Change swing search to return the most recent confirmed swing (scan backwards, keep confirmation lag explicit).
3. Make temporal contract explicit:
   - Require caller to provide a rolling window ending at the current bar, or add an `asof_idx`/`asof_timestamp` and internally bound computation to `<= asof`.
4. Align configuration with behavior:
   - Use `golden_pocket_lower/upper` when setting golden pocket bounds.
5. Cluster detection improvements:
   - Respect trend/bias (bullish vs bearish) per swing pair and anchor swing windows to the most recent data.

SpreadAnalyzer
1. Compute avg (or a “baseline avg”) before recording current spread, or compute avg excluding the current sample.
2. Prefer session-specific averages for session classification; treat global recent avg as a fallback only.
3. Normalize `current_hour` to [0, 23] in `_estimate_time_to_session` for negative/large offsets.
4. Use `spike_threshold` consistently (avoid hard-coded 1.5 scattered).


VALIDATION STEPS
================
- Add/extend unit tests for FibonacciAnalyzer:
  - Monotonic trend series where fallback triggers → verify swing value corresponds to the returned index and matches the last-50 window.
  - Window with multiple swings → verify “most recent” swing selection.
  - As-of slicing contract → verify no access beyond as-of end index.
- Add/extend unit tests for SpreadAnalyzer:
  - Verify spike classification when a single large spread occurs (avg excluding current).
  - Verify session-average behavior vs global-average behavior across mixed timestamps.
  - Verify `_estimate_time_to_session` with negative gmt_offset.

Pre-flight executed (per Phase 06 plan)
- git status -sb
- git diff --stat
- git diff
- rg TODO|FIXME|HACK
