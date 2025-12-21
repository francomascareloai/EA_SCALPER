## Phase 06 Round 1 - Agent A (Core EA Logic) Findings

REVIEW SUMMARY
==============
AGENT: REVIEWER
VERSION: 2.2
CLAUDE_MD_VERSION: 3.10.16
STATUS: COMPLETE
DATE: 2025-12-19

Scope
- /home/franco/projetos/EA_SCALPER_XAUUSD/scripts/backtest/strategies/ea_logic_full.py

Callsites checked (to confirm harness-level leakage risk)
- /home/franco/projetos/EA_SCALPER_XAUUSD/scripts/backtest/tick_backtester.py (EA parity path)

Baseline for consistency checks
- /home/franco/projetos/EA_SCALPER_XAUUSD/nautilus_gold_scalper/src/strategies/gold_scalper_strategy.py @ 2f2f5179b4f70c9af750647c5f266819e143119a
  - Baseline file matches the current working tree (no diff against this hash).

Verdict: BLOCK

High-level finding
- `ea_logic_full.py` is positioned as a “full port / parity” EA logic layer, but it is not safe to use for realistic/Apex-labeled backtest metrics.
- There is **confirmed future-data leakage** when this EA layer is used via the current backtester integration: HTF (H1) bars are passed as a full-range series and are not sliced by the evaluation timestamp.
- Independently of leakage, this module lacks Apex ET time gates and uses non-Apex risk/DD semantics and optimistic execution assumptions (close-based entry, no bid/ask + slippage/latency/commission in the parity path).


Baseline reference (what “consistent” means here)
-----------------------------------------------
The baseline Nautilus strategy implements (key invariants):

1) Apex ET time constraints
- Config: hard flatten cutoff and emergency windows:
  - /home/franco/projetos/EA_SCALPER_XAUUSD/nautilus_gold_scalper/src/strategies/gold_scalper_strategy.py:231
  - /home/franco/projetos/EA_SCALPER_XAUUSD/nautilus_gold_scalper/src/strategies/gold_scalper_strategy.py:252
- Entry gate: block new trades after ~4:30 PM ET:
  - /home/franco/projetos/EA_SCALPER_XAUUSD/nautilus_gold_scalper/src/strategies/gold_scalper_strategy.py:980

2) Trailing DD from HWM including unrealized PnL (mark-to-market, conservative pricing)
- Prop-firm configuration:
  - /home/franco/projetos/EA_SCALPER_XAUUSD/nautilus_gold_scalper/src/strategies/gold_scalper_strategy.py:220
  - /home/franco/projetos/EA_SCALPER_XAUUSD/nautilus_gold_scalper/src/strategies/gold_scalper_strategy.py:224
- Tick-level equity updates (bid for longs, ask for shorts):
  - /home/franco/projetos/EA_SCALPER_XAUUSD/nautilus_gold_scalper/src/strategies/gold_scalper_strategy.py:1861
  - /home/franco/projetos/EA_SCALPER_XAUUSD/nautilus_gold_scalper/src/strategies/gold_scalper_strategy.py:1972

This baseline is the bar used for the consistency comparisons below.


ISSUES BY SEVERITY
==================

BLOCKERS (must fix before using this path for evaluation/GO-NOGO)
---------------------------------------------------------------

| ID | Severity | Location | Description | Evidence | Recommended fix |
|----|----------|----------|-------------|----------|-----------------|
| A-001 | CRITICAL | /home/franco/projetos/EA_SCALPER_XAUUSD/scripts/backtest/tick_backtester.py:609 and :737 + /home/franco/projetos/EA_SCALPER_XAUUSD/scripts/backtest/strategies/ea_logic_full.py:2504-2514 | CONFIRMED HTF look-ahead leakage: `evaluate_from_df()` consumes the provided `htf_df` as-is (`h1_closes = htf['close'].values`) without enforcing an “as-of now” cutoff. The current backtester passes `self.htf_bars` (full H1 resample built once for the entire dataset) into `evaluate_from_df` at every step, which includes future H1 bars relative to `now`. | Backtester: `self.htf_bars = OHLCResampler.resample(ticks, '1h')` then `setup = self.ea.evaluate_from_df(ltf_window, self.htf_bars, timestamp, ...)` (EA parity path). EA layer: `htf = htf_df.copy(); h1_closes = htf['close'].values; h1_atr = htf['atr'].iloc[-1]`. No slicing by `now` occurs. | Enforce an explicit “as-of” contract. Preferred: slice at callsite (`htf_window = self.htf_bars.loc[:timestamp]`) and ensure the last HTF bar is closed. Defensive: add an assertion inside `evaluate_from_df` that `htf_df.index.max() <= now`. Add a unit test which fails if one future HTF bar is present. |
| A-002 | CRITICAL | /home/franco/projetos/EA_SCALPER_XAUUSD/scripts/backtest/strategies/ea_logic_full.py (string search: none found) | Missing Apex ET time gates (4:30 PM ET block new, 4:55 PM ET emergency close, 4:59 PM ET hard flatten). The only time gating is a GMT-offset session filter (and a Friday gate). | No references to `America/New_York`, ET cutoffs, `flatten_time`, `TimeConstraint`, or `4:30/4:55/4:59` exist in this file. Baseline uses `TimeConstraintManager` and config ET cutoffs (see baseline references above). | Either (a) implement the Apex time constraints in this strategy path, or (b) treat this module as “non-Apex” and prevent it from being used in any Apex-labeled realistic backtest. |
| A-003 | CRITICAL | /home/franco/projetos/EA_SCALPER_XAUUSD/scripts/backtest/strategies/ea_logic_full.py:126-191 | Risk/DD model is not Apex trailing DD from HWM including unrealized. `RiskManager` tracks `balance`/`peak_balance` updated only on `record_trade()` (realized-only) and defaults `max_total_loss_pct=10.0` (FTMO-like). | `RiskManager.can_open()` uses `total_dd = (peak_balance - balance)/peak_balance` and does not ingest unrealized PnL. `peak_balance` updates only in `record_trade()`. Default `max_total_loss_pct=10.0`. | Align to baseline: trailing DD from mark-to-market HWM including unrealized (bid/ask conservative) + daily DD tiers and safety buffers. At minimum, rename this manager to avoid implying Apex compliance. |
| A-004 | CRITICAL | /home/franco/projetos/EA_SCALPER_XAUUSD/scripts/backtest/strategies/ea_logic_full.py:2522-2608 + /home/franco/projetos/EA_SCALPER_XAUUSD/scripts/backtest/tick_backtester.py:747-762 | Execution realism gap: EA parity setups are filled at `current_price = close.iloc[-1]` with `entry = current_price` and no bid/ask, slippage, latency, commission, or rejection model. In the EA parity path, the backtester opens at `setup.entry` directly, bypassing its own `ExecutionModel.get_fill_price()` (used in non-EA MA-cross path). | EA layer: `current_price = float(ltf['close'].iloc[-1])` then `entry = current_price`. Backtester EA path: `entry = setup.entry` and opens immediately (no fill simulation). Baseline explicitly models spread, slippage, and tick-level mark-to-market equity. | Ensure EA parity execution is realistic: either return order intents (market/limit/stop) and simulate fills, or apply conservative bid/ask + slippage/latency in the parity execution path. |


HIGH
----

| ID | Severity | Location | Description | Why this matters | Recommended fix |
|----|----------|----------|-------------|------------------|-----------------|
| A-005 | HIGH | /home/franco/projetos/EA_SCALPER_XAUUSD/scripts/backtest/strategies/ea_logic_full.py:1279-1346 | MQL5 “series” parity mismatch likely: Liquidity sweep detection uses indices as if `0` is the most recent bar (`returned_inside = closes[0] ...`, loops `for j in range(min(10, len(highs))):`). In pandas/numpy `values`, index 0 is oldest. The EA wrapper passes `m15_closes = m5_closes[::3]` and `m15_highs = ltf['high'].values[::3]` (chronological), so sweep logic is likely inverted/non-parity. | This can create false positives/negatives while looking “reasonable”, which is a major audit trap because it changes the strategy behavior without obvious runtime errors. | Enforce a single array orientation convention at the interface boundary (chronological vs series-reversed). Add assertions/tests for sweep detection on a known synthetic sequence. |
| A-006 | HIGH | /home/franco/projetos/EA_SCALPER_XAUUSD/scripts/backtest/strategies/ea_logic_full.py:52-58 | Temporal hazard: order block detection uses forward bars relative to a candidate candle (`h[i+1:i+4]`, `l[i+1:i+4]`) to confirm displacement. This is only causally safe if treated as “confirmed after N bars” and never used as if known at candle i. | Without explicit lag semantics, this becomes de-facto look-ahead during signal generation. | Add explicit confirmation-time semantics (e.g., OB timestamp = i+3) and ensure the evaluator never uses unconfirmed structures. |
| A-007 | HIGH | /home/franco/projetos/EA_SCALPER_XAUUSD/scripts/backtest/strategies/ea_logic_full.py (SessionFilter/MTFManager) | Time/session logic is GMT-offset based, not ET via `America/New_York`. DST correctness is not guaranteed; Friday close gate is in GMT-hour space. | Apex compliance requires ET-aware cutoffs with automatic DST handling; fixed GMT offsets will drift seasonally and mis-time risk controls. | Use zone-aware ET time (zoneinfo) for operational gates, and define “degraded mode” earlier cutoffs when time is uncertain (per project rules). |
| A-008 | HIGH | /home/franco/projetos/EA_SCALPER_XAUUSD/scripts/backtest/strategies/ea_logic_full.py:2079 and :2267-2271 | Gate stats bug: `gate_blocks` initializes only `GATE_1..GATE_10`, but the code increments `GATE_11`. With ML enabled and direction mismatch, this can throw KeyError and/or corrupt gating analytics. | Breaks runs and masks true reject reasons (auditability regression). | Initialize `GATE_11` (and any other referenced keys) or use `defaultdict(int)`.


MEDIUM
------

| ID | Severity | Location | Description | Why this matters | Recommended fix |
|----|----------|----------|-------------|------------------|-----------------|
| A-009 | MEDIUM | /home/franco/projetos/EA_SCALPER_XAUUSD/scripts/backtest/strategies/ea_logic_full.py:2524-2525 | Spread unit heuristic is ambiguous: `spread_points = int(raw_spread if raw_spread > 5 else raw_spread / point_value)` guesses whether spread is in points vs price units. | Silent mis-scaling can admit/deny trades incorrectly and undermines comparability across datasets. | Make spread units explicit in the interface and validate; avoid heuristics. |
| A-010 | MEDIUM | /home/franco/projetos/EA_SCALPER_XAUUSD/scripts/backtest/strategies/ea_logic_full.py:2516-2521 | M15 is approximated by downsampling M5 (`m5[::3]`) and scaling ATR (`m15_atr = m5_atr * 1.5`) rather than true resampling. | Not a look-ahead bug, but changes signal timing/structure detection in a way that breaks “parity” claims. | Use real resampling with closed-bar semantics, or explicitly label as approximation. |
| A-011 | MEDIUM | /home/franco/projetos/EA_SCALPER_XAUUSD/scripts/backtest/strategies/ea_logic_full.py:2321 and :2614 | Non-determinism risk when timestamps are missing: `get_position_size()` falls back to `datetime.utcnow()` if `timestamp` is None; legacy `evaluate()` falls back to `datetime.utcnow()` if bar.timestamp absent. | Backtests can become non-reproducible and can desync session scoring/time gates from the simulated timeline. | Fail-fast if timestamps are missing in backtests; remove wall-clock fallbacks from backtest paths. |
| A-012 | MEDIUM | /home/franco/projetos/EA_SCALPER_XAUUSD/scripts/backtest/strategies/ea_logic_full.py:24-25 | `warnings.filterwarnings('ignore')` suppresses warnings globally. | Hides data-quality problems (NaNs, resample gaps, dtype issues) that often correlate with leakage/overfitting bugs. | Remove global ignore or scope warnings filtering to narrow, justified cases. |


LOW
---

| ID | Severity | Location | Description | Recommended fix |
|----|----------|----------|-------------|-----------------|
| A-013 | LOW | /home/franco/projetos/EA_SCALPER_XAUUSD/scripts/backtest/strategies/ea_logic_full.py (module-level comments) | The file claims “full port / parity”, but multiple components are explicitly “simplified for backtest” and baseline invariants (Apex ET gates, unrealized-inclusive HWM, bid/ask execution) are absent. This increases audit risk. | Downgrade wording to “approximate parity” and document required caller contracts and known non-parity areas. |


Look-ahead / leakage assessment (Phase 06 criteria)
===================================================

1) Confirmed direct leakage
- YES: **HTF future-data leakage** exists in the current integration.
  - Root cause: `evaluate_from_df()` does not enforce an “as-of now” cutoff for `htf_df`, while the callsite passes the full-range H1 series.

2) Explicit “next bar” patterns
- No `shift(-1)` patterns found in `ea_logic_full.py`.
- However, there are forward-looking confirmations inside pattern detectors (order blocks, swing points) which must be treated as “confirmed after N bars”, or they become look-ahead.

3) Execution realism / implicit leakage
- EA parity path fills at bar close/mid without bid/ask + slippage/latency/commission; this is a material over-optimism even if strict indexing leaks were absent.

Leakage status for Phase 06: FAIL (confirmed leakage exists).


Validation steps (recommended)
==============================

1) Add an as-of guardrail in the EA parity harness
- Before calling `evaluate_from_df()`, assert:
  - `ltf_window.index.max() == timestamp`
  - `htf_window.index.max() <= timestamp`
- Add a negative test: append one future HTF bar and confirm the harness rejects it.

2) Fix EA parity execution realism
- Decide and document: “decision on bar close” vs “execution on next bar/open or next tick”.
- Ensure bid/ask + slippage/latency + commission are applied consistently in the EA parity path.

3) Add parity tests for series orientation
- Create synthetic OHLC sequences where sweep/OB outcomes are known and verify detectors behave identically under the intended array orientation.

4) Determinism check
- Ensure `datetime.utcnow()` is never used in backtest runs; require timestamps.


CRITIC SELF-REVIEW APPLIED
==========================
- Techniques used: INVERSION, PRE-MORTEM, APEX TRAP, EDGE CASES
- Hidden issues found: 2
  - Confirmed HTF future-data leakage due to missing `now` cutoff + callsite passing full HTF series.
  - EA parity path bypasses execution friction (fills at close without bid/ask/slippage), materially inflating results.
- Assumptions challenged:
  - That `htf_df` is always pre-windowed to the evaluation time.
  - That array orientation matches MQL5 series conventions.
- Confidence: HIGH
