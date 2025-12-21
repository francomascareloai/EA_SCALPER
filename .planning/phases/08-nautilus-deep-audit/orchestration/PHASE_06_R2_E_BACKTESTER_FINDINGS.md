## Phase 06 Round 2 - Agent E (Backtester Scripts) Findings

REVIEW SUMMARY
==============
AGENT: REVIEWER
VERSION: 2.2
CLAUDE_MD_VERSION: 3.10.18
STATUS: COMPLETE
DATE: 2025-12-19

Scope
- /home/franco/projetos/EA_SCALPER_XAUUSD/scripts/backtest/realistic_backtester.py
- /home/franco/projetos/EA_SCALPER_XAUUSD/scripts/backtest/stress_test_degradation.py
- /home/franco/projetos/EA_SCALPER_XAUUSD/scripts/backtest/multi_year_backtest.py

Baseline invariants (must hold for any “Apex/realistic” backtest output)
- Apex ET gates: block new trades after 4:30 PM ET, emergency close from 4:55 PM ET, hard flat by 4:59 PM ET.
- Trailing DD: 5% from High-Water Mark including unrealized PnL (mark-to-market, conservative BID/ASK).
- No look-ahead / temporal causality: decisions cannot use information from future bars/ticks.

Verdict: BLOCK

High-level findings
- These scripts are not safe for Apex-labeled evaluation/GO-NOGO.
- There is **confirmed look-ahead leakage** in the “compat” execution path of `realistic_backtester.py`.
- Risk controls do not match Apex: DD semantics are FTMO-like and realized-only; ET time gates are absent.
- Execution simulation still materially overstates realism: mid-based bars and bar-high/low SL/TP triggers without bid/ask microstructure or commissions.


ISSUES BY SEVERITY
==================

BLOCKERS (must fix before trusting results)
------------------------------------------

| ID | Severity | Location | Description | Evidence | Recommended fix |
|----|----------|----------|-------------|----------|-----------------|
| P06-R2E-001 | CRITICAL | /home/franco/projetos/EA_SCALPER_XAUUSD/scripts/backtest/realistic_backtester.py:288-325 and :1002-1004 | **Confirmed look-ahead leakage:** `MTFAnalyzer.calculate_alignment()` ignores `current_idx` and computes moving averages using the *end of the full timeframe series* (`.iloc[-1]`). In compat mode this means every bar “sees” the final MA state of the entire backtest. | `calculate_alignment(..., current_idx)` never slices `bars` by index/time. It does `close = bars['close'].values; ma_fast = ...rolling(10).mean().iloc[-1]` and `ma_slow = ...iloc[-1]`. Called from `_check_entry_compat()` as `self.mtf.calculate_alignment(bars_dict, idx)` with `bars_dict` containing full history. | Enforce an “as-of” contract: slice each timeframe to `<= current_idx` (or by timestamp) inside `calculate_alignment`, and add an assertion/test that rejects any use of data beyond the evaluated bar. |
| P06-R2E-002 | CRITICAL | /home/franco/projetos/EA_SCALPER_XAUUSD/scripts/backtest/realistic_backtester.py:96-106 and :401-474 and :818-823 | **Apex compliance mismatch:** risk model is FTMO-like (`max_daily_dd=5%`, `max_total_dd=10%`) and equity is treated as realized-only balance (no unrealized PnL, no HWM mark-to-market). **Apex ET time gates are not implemented.** | `RealisticBacktestConfig` hardcodes FTMO limits. `FTMORiskManager.update()` sets `equity = balance` (no unrealized). `equity_curve` records `balance` only. No ET gate constants/logic exist in this script. | Replace with the project’s Apex risk semantics (HWM including unrealized, conservative bid/ask) and implement explicit ET time gating (4:30/4:55/4:59). If this script is intentionally non-Apex, rename/label outputs and prevent its use in Apex evaluation. |

HIGH
----

| ID | Severity | Location | Description | Why this matters | Recommended fix |
|----|----------|----------|-------------|------------------|-----------------|
| P06-R2E-003 | HIGH | /home/franco/projetos/EA_SCALPER_XAUUSD/scripts/backtest/realistic_backtester.py:752-765 and :796-815 and :908-909 | **Temporal correctness risk:** bars are generated via `resample(tf).ohlc()` with default bin labeling; the simulation then uses `timestamp` with `bar['close']` for decisions and fills in the same step. If the bar index represents bar-open (pandas default), this becomes a systematic “close-at-open” causality violation. | This is a classic backtest inflation path: trade signals use information from within the bar while timestamp is earlier. It also breaks any hour/session gating because the “decision time” is ambiguous. | Make decision_time and execution_time explicit (e.g., decide on bar close, execute next tick/next bar open) and ensure all series are aligned to completed-bar timestamps. |
| P06-R2E-004 | HIGH | /home/franco/projetos/EA_SCALPER_XAUUSD/scripts/backtest/realistic_backtester.py:358-395 and :1064-1075 and :1088-1092 | Execution realism gaps: mid-based OHLC + mean spread, no commission, no partial fills, no bid/ask bar extremes. SL/TP triggers use mid high/low, which can materially mis-trigger exits vs bid/ask reality. | For XAUUSD scalping, spread/latency microstructure dominates edge; mid-bar SL/TP rules can overstate wins and understate losses/DD. | Model fills and exit triggers on conservative bid/ask (or simulate on ticks), include commissions, and add at least a coarse partial-fill model for market orders. |
| P06-R2E-005 | HIGH | /home/franco/projetos/EA_SCALPER_XAUUSD/scripts/backtest/realistic_backtester.py:543-552 and :1094-1095 | Correctness bug in FULL mode: when `USE_FULL_LOGIC` is true, `self.ea_logic` is set to `None`, but `_close_position()` calls `self.ea_logic.risk_manager.update_trade_result(pnl)` unconditionally. | This can crash runs and silently discourage use of the supposedly “realistic/full” path, pushing users into the leaky compat path. | Route risk-manager updates through the correct object for each mode, or guard the call when compat is not active. |
| P06-R2E-006 | HIGH | /home/franco/projetos/EA_SCALPER_XAUUSD/scripts/backtest/stress_test_degradation.py:16-17 and /home/franco/projetos/EA_SCALPER_XAUUSD/scripts/backtest/multi_year_backtest.py:10-13 | Hardcoded Windows paths + `sys.path.insert(...)` import injection. These scripts are not portable and are vulnerable to path hijacking (importing unintended code from the injected directory). | Reproducibility and safety: results differ across environments; path injection increases the chance of accidental execution of wrong modules. | Use project-relative imports/packaging and configure data paths via args/env; avoid sys.path injection. |
| P06-R2E-007 | HIGH | /home/franco/projetos/EA_SCALPER_XAUUSD/scripts/backtest/multi_year_backtest.py:23-27 and :67-69 | Data contract mismatch: multi-year runner depends on per-year parquet files and only samples `max_ticks=15_000_000` (~3 months), which can introduce selection bias. It also diverges from the project’s “single canonical dataset” rule. | “Multi-year” conclusions become fragile and non-comparable to other validation artifacts; selection bias can hide regime failures. | Use the canonical dataset with explicit date windows per year and record exact ranges; fix seeds if any randomness is used downstream. |

MEDIUM
------

| ID | Severity | Location | Description | Recommended fix |
|----|----------|----------|-------------|-----------------|
| P06-R2E-008 | MEDIUM | /home/franco/projetos/EA_SCALPER_XAUUSD/scripts/backtest/stress_test_degradation.py:7-12 and :40-75 | Script header claims multiple degradation factors (exit slippage, random loss conversion, spread multiplier) but the implementation only sweeps `base_slippage_points`. | Update the experiment or the description so readers don’t assume coverage that doesn’t exist. |
| P06-R2E-009 | MEDIUM | /home/franco/projetos/EA_SCALPER_XAUUSD/scripts/backtest/realistic_backtester.py:27-28 | `warnings.filterwarnings('ignore')` suppresses warnings globally. | Avoid global suppression; scope warning filters to known-noisy lines or remove. |
| P06-R2E-010 | MEDIUM | /home/franco/projetos/EA_SCALPER_XAUUSD/scripts/backtest/realistic_backtester.py:162-203 and :267-270 and /home/franco/projetos/EA_SCALPER_XAUUSD/scripts/backtest/multi_year_backtest.py (no seeding) | Reproducibility: `realistic_backtester.py` uses randomness for latency/ONNX noise/slippage but has no seed control; multi-year runner does not set seeds. | Add explicit seed plumbing (CLI arg/config) and log the seed used for each run. |

LOW
---

| ID | Severity | Location | Description | Recommended fix |
|----|----------|----------|-------------|-----------------|
| P06-R2E-011 | LOW | /home/franco/projetos/EA_SCALPER_XAUUSD/scripts/backtest/realistic_backtester.py:480-492 | Type hygiene: `regime: any` should be `typing.Any` (and the rest of the dataclass fields are typed). | Use `Any` consistently to avoid confusion. |
| P06-R2E-012 | LOW | /home/franco/projetos/EA_SCALPER_XAUUSD/scripts/backtest/realistic_backtester.py:3-13 | The script markets itself as “institutional-grade / mirrors real EA behavior”, but key parity elements are absent (Apex gates, HWM unrealized, commission, bid/ask bar extremes). | Downgrade claims or add a “known gaps” section to prevent misuse. |


Look-ahead / leakage assessment (Phase 06 criteria)
===================================================
- Confirmed leakage present: YES (P06-R2E-001).
- Leakage status: FAIL.


Validation steps (recommended)
==============================
1) Add a causal “as-of” guard
- For any timeframe-based feature (MTF alignment, HTF closes, spreads), enforce `data_end_time <= decision_time`.

2) Enforce explicit decision/execution timeline
- Document and enforce: decide on bar close; execute next tick/next bar open (with bid/ask).

3) Apex compliance gates for backtests
- Implement/verify: ET time gate + emergency close + hard flatten; trailing DD from HWM including unrealized at conservative bid/ask.

4) Reproducibility
- Seed all RNG sources; log seed and data range in every report.


CRITIC SELF-REVIEW APPLIED
==========================
- Techniques used: INVERSION, PRE-MORTEM, APEX TRAP, EDGE CASES
- Hidden issues found: 2
  - Confirmed MTF alignment look-ahead due to full-series `.iloc[-1]` usage.
  - Apex failure mode: realized-only DD + missing ET gates can pass backtest while blowing live trailing DD.
- Assumptions challenged:
  - That bar timestamps represent close times.
  - That “realistic” implies Apex compliance and bid/ask microstructure.
- Confidence: HIGH
