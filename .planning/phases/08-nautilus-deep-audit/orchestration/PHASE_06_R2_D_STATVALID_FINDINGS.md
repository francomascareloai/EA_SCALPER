## Phase 06 Round 2 - Agent D (Statistical Validation) Findings

REVIEW SUMMARY
==============
AGENT: REVIEWER
VERSION: 2.2
CLAUDE_MD_VERSION: 3.10.18
STATUS: COMPLETE
DATE: 2025-12-19

Scope
- /home/franco/projetos/EA_SCALPER_XAUUSD/scripts/backtest/monte_carlo_degradation.py
- /home/franco/projetos/EA_SCALPER_XAUUSD/scripts/backtest/wfa_filter_study.py

Total lines reviewed: 851

Verdict: BLOCK

High-level findings
- The “Monte Carlo” script is not a Monte Carlo simulation in the statistical sense (no bootstrap/permutation ensemble, no confidence intervals/percentiles, and no serial-correlation treatment).
- Both validation scripts run on (or depend on) backtest paths with confirmed temporal leakage elsewhere in the repo:
  - `monte_carlo_degradation.py` runs `TickBacktester` with `use_ea_logic=True`, which is known to have HTF look-ahead leakage in the EA parity path (Phase 06 R1 findings).
  - `wfa_filter_study.py` relies on `ablation_study` SMC structure detection which uses forward bars (`i+1:i+4`) and is precomputed for the full window, creating a causality violation (look-ahead) unless explicitly delayed/confirmed.
- `wfa_filter_study.py` has a major window-sizing defect: with defaults (`n_windows=5`, `is_ratio=0.7`), it only evaluates the first ~44% of the bars and ignores the remainder of the dataset.
- Both scripts contain Windows-only hardcoded paths and (in `monte_carlo_degradation.py`) a `sys.path.insert(...)` injection pattern, harming reproducibility and increasing the risk of importing unintended code.


ISSUES BY SEVERITY
==================

BLOCKERS (must fix before trusting results)
------------------------------------------

| ID | Severity | Location | Description | Evidence | Recommended fix |
|----|----------|----------|-------------|----------|-----------------|
| P06-R2D-001 | CRITICAL | /home/franco/projetos/EA_SCALPER_XAUUSD/scripts/backtest/monte_carlo_degradation.py:109-127 | Confirmed leakage via dependency: script runs `TickBacktester` with `use_ea_logic=True`, which is currently affected by HTF look-ahead in the EA parity evaluation path (Phase 06 R1 A-001). Any “degradation” metrics are downstream of a leaky baseline. | `BacktestConfig(... use_ea_logic=True ...)` and `bt.run(...)` are hardcoded in the script. | Do not use this script for GO/NO-GO until the EA parity backtest path is made causal (slice HTF “as-of” timestamp, add guards/tests). |
| P06-R2D-007 | CRITICAL | /home/franco/projetos/EA_SCALPER_XAUUSD/scripts/backtest/wfa_filter_study.py:38-42 and :168-175 (dependency in ablation) | Confirmed look-ahead hazard via dependency: WFA calls `SMCAblationBacktester`, which precomputes OB/FVG structures using future bars (e.g., `i+1:i+4`) before simulation, then uses them earlier than would be knowable in real time unless delayed/confirmed. This violates temporal causality and can inflate both IS and OOS performance. | WFA imports `SMCAblationBacktester` (via `ablation_study`) and runs it on each window. In `ablation_study.detect_order_blocks`, displacement confirmation uses forward bars; the backtester uses precomputed structures during iteration. | Enforce “confirmation lag” semantics: structures that require N forward bars must only become available after those bars complete; add an “as-of” assertion/test that rejects using any structure not yet confirmed at the current bar. |

HIGH
----

| ID | Severity | Location | Description | Why this matters | Recommended fix |
|----|----------|----------|-------------|------------------|-----------------|
| P06-R2D-002 | HIGH | /home/franco/projetos/EA_SCALPER_XAUUSD/scripts/backtest/monte_carlo_degradation.py:2-15 and :145-160 | Misleading methodology: labeled “Monte Carlo” but performs a single seeded random conversion per degradation level, with no repeated simulations, no bootstrap/permutation, and no CI/percentiles for metrics (PF/DD). | Can materially understate tail risk and overstate robustness; the printed “FINAL VERDICT” reads like a statistical decision but is based on one draw. | Implement a true ensemble: >=1000 simulations per level; report percentiles for max DD, PF, net profit; and document whether resampling preserves serial correlation (block bootstrap) or breaks it (permutation). |
| P06-R2D-005 | HIGH | /home/franco/projetos/EA_SCALPER_XAUUSD/scripts/backtest/monte_carlo_degradation.py:18-20 and :105-106 | Reproducibility + safety issue: hardcoded Windows paths and `sys.path.insert(...)` import injection. | Results are not portable; path injection can cause accidental imports of unintended modules (path hijack), producing unverifiable outputs. | Use project-relative imports and accept data/output paths via CLI args; avoid modifying `sys.path` in scripts. |
| P06-R2D-008 | HIGH | /home/franco/projetos/EA_SCALPER_XAUUSD/scripts/backtest/wfa_filter_study.py:131-138 and :156-166 | WFA window sizing is incorrect: with defaults `n_windows=5`, `is_ratio=0.7`, the loop only reaches `oos_end ≈ 0.44 * n` (leaving ~56% of bars unused). This is not a full-dataset walk-forward. | Biased validation: conclusions depend disproportionately on the early portion of the dataset (regime/sample bias). It defeats the stated purpose (“gold standard overfitting detection”). | Redefine window construction so OOS windows tile across the full dataset (or explicitly define anchored WFA); log the exact coverage and ensure the last OOS end reaches the dataset end. |
| P06-R2D-012 | HIGH | /home/franco/projetos/EA_SCALPER_XAUUSD/scripts/backtest/wfa_filter_study.py:578-581 | Hardcoded Windows file paths for input data and report output (and diverges from the project’s single canonical dataset rule). | Script fails in Linux environments and results are not comparable to other validation artifacts; also risks selection bias if only 2024 ticks are used. | Parameterize paths; default to the canonical dataset; record exact date ranges used in outputs. |

MEDIUM
------

| ID | Severity | Location | Description | Recommended fix |
|----|----------|----------|-------------|-----------------|
| P06-R2D-003 | MEDIUM | /home/franco/projetos/EA_SCALPER_XAUUSD/scripts/backtest/monte_carlo_degradation.py:39-40 and :150-155 | RNG is re-seeded inside `degrade_trades()` on every call (default `seed=42`), making degradation levels non-independent and nested. This is fine for a deterministic sensitivity curve, but not for estimating uncertainty. | If kept, label as “deterministic sensitivity”; otherwise seed per simulation and aggregate distributions. |
| P06-R2D-004 | MEDIUM | /home/franco/projetos/EA_SCALPER_XAUUSD/scripts/backtest/monte_carlo_degradation.py:49-55 | Degradation model is arbitrary: converts winners to losses via `-abs(win)/1.5` with no linkage to actual SL/TP distances, spread, or slippage. | Use trade-level risk information (R-multiples or SL distance) to convert to realistic loss outcomes; at minimum, document assumptions and stress multiple ratios. |
| P06-R2D-009 | MEDIUM | /home/franco/projetos/EA_SCALPER_XAUUSD/scripts/backtest/wfa_filter_study.py:156-166 | No embargo/purging between IS/OOS. For pure rule-based backtests this can be acceptable, but if any features/labels overlap across boundaries (especially if later extended to optimization/ML), it can leak information and inflate WFE. | If used for optimization/feature selection, add purge/embargo; otherwise clearly document “rolling re-fit without embargo” semantics. |
| P06-R2D-010 | MEDIUM | /home/franco/projetos/EA_SCALPER_XAUUSD/scripts/backtest/wfa_filter_study.py:177-178 and :240-245 | No minimum OOS trade count gate. A window with few trades can produce unstable returns and misleading WFE. | Enforce minimum OOS trades (e.g., >=50 recommended) or downweight/flag windows below threshold. |
| P06-R2D-011 | MEDIUM | /home/franco/projetos/EA_SCALPER_XAUUSD/scripts/backtest/wfa_filter_study.py:227-233 | WFE calculation uses `mean_oos/mean_is` and clips to [-2, 2]. For negative or near-zero IS returns this ratio becomes ill-defined and clipping can mask extreme overfit/fragility. | Use more robust aggregation (e.g., sum of returns, risk-adjusted metrics, or log-returns) and explicitly handle sign/near-zero denominators; avoid silent clipping or at least report unclipped values too. |

LOW
---

| ID | Severity | Location | Description | Recommended fix |
|----|----------|----------|-------------|-----------------|
| P06-R2D-006 | LOW | /home/franco/projetos/EA_SCALPER_XAUUSD/scripts/backtest/monte_carlo_degradation.py:72-76 | Drawdown computation hardcodes `100_000` starting equity. Works for the current baseline config but is fragile if `initial_balance` differs. | Pass `initial_balance` into `degrade_trades()` and compute drawdown from equity explicitly. |
| P06-R2D-013 | LOW | /home/franco/projetos/EA_SCALPER_XAUUSD/scripts/backtest/wfa_filter_study.py:27-32 | `warnings.filterwarnings('ignore')` suppresses warnings globally. | Avoid global suppression; scope to known-noisy warnings only. |


Look-ahead / leakage assessment (Phase 06 criteria)
===================================================
- Confirmed leakage present: YES.
  - Downstream leakage via EA parity backtest path invoked by `monte_carlo_degradation.py` (known HTF “as-of” violation in Phase 06 R1).
  - Causality violation via precomputed forward-confirmed SMC structures used by the ablation backtester invoked by `wfa_filter_study.py`.
- Leakage status: FAIL.


Validation steps (recommended)
==============================
1) Block-bootstrap Monte Carlo (serial correlation aware)
- Resample trades/returns using block bootstrap (or stationary bootstrap) to preserve clustering/serial dependence.
- Run >=1000 simulations; report percentiles (p5/p50/p95) for max DD, PF, net profit.

2) Fix WFA window construction
- Ensure OOS windows tile the full dataset end-to-end (or document anchored WFA) and log window coverage.

3) Add causality guards
- Add “as-of” checks for HTF inputs and any derived structures/indicators used for entry decisions.
- For SMC patterns requiring forward confirmation, enforce delayed availability.

4) Minimum sample gates
- Require minimum OOS trades per window and minimum total OOS trades before making “APPROVED/MARGINAL/REJECTED” decisions.

CRITIC SELF-REVIEW APPLIED
==========================
- Techniques used: INVERSION, PRE-MORTEM, EDGE CASES, ASSUMPTION AUDIT
- Hidden issues found: 2
  - WFA window sizing only covers ~44% of data under defaults.
  - “Monte Carlo” output is single-draw and can be misinterpreted as a CI-based robustness test.
- Confidence: HIGH
