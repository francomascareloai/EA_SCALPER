## Phase 06 Round 1 - Agent B (Alternative Strategies) Findings

REVIEW SUMMARY
==============
AGENT: REVIEWER
VERSION: 2.2
CLAUDE_MD_VERSION: 3.10.16
STATUS: COMPLETE

Scope:
- /home/franco/projetos/EA_SCALPER_XAUUSD/scripts/backtest/strategies/ea_logic_python.py
- /home/franco/projetos/EA_SCALPER_XAUUSD/scripts/backtest/strategies/adaptive_kelly.py
- /home/franco/projetos/EA_SCALPER_XAUUSD/scripts/backtest/strategies/ea_logic_compat.py

Baseline for consistency checks:
- /home/franco/projetos/EA_SCALPER_XAUUSD/nautilus_gold_scalper/src/strategies/gold_scalper_strategy.py @ 2f2f5179b4f70c9af750647c5f266819e143119a

Verdict: CHANGES_REQUIRED

High-level finding:
These “alternative strategies” are not consistent with the baseline Nautilus strategy’s Apex constraints (5% trailing DD from HWM incl. unrealized, ET time gates, realistic execution costs), and two of them (ea_logic_python, ea_logic_compat) embed optimistic execution assumptions which can materially inflate backtest performance.

---

## Baseline reference (what “consistent” means here)
The baseline Nautilus strategy implements:

- Prop-firm mode with trailing DD budget and daily loss gating (Apex-oriented):
  - `GoldScalperConfig.total_loss_limit_pct = 5.0` (Apex trailing DD limit), `daily_loss_limit_pct = 5.0` (baseline config, but circuit breaker adds conservative tiers).
  - See: `gold_scalper_strategy.py:220-266` and `gold_scalper_strategy.py:523-542`.

- Apex time constraints (ET) + entry cutoff gate:
  - Hard flatten cutoff `flatten_time_et = "16:59"`, plus warning/urgent/emergency times.
  - Entry gate blocks new trades after ~4:30 PM ET via `TimeConstraintManager.can_open_new(...)`.
  - See: `gold_scalper_strategy.py:231-252` and `gold_scalper_strategy.py:980-987`.

- Tick-level guardrails and more realistic execution assumptions:
  - Spread monitor updated on quote ticks, optional commissions/slippage via execution model.
  - See: `gold_scalper_strategy.py:565-574` and `gold_scalper_strategy.py:1861-1899`.

This is the bar for “consistency” used below.

---

## Issues

### BLOCKERS (must fix before using these files for evaluation/GO-NOGO)

| ID | Severity | File:Line | Description | Recommended Fix |
|----|----------|-----------|-------------|-----------------|
| B-001 | CRITICAL | ea_logic_python.py:430-472 | `RiskManagerPython` uses FTMO-style limits (default `max_total_loss_pct=10.0`) and has an internal logic bug: `daily_dd >= max_total_loss_pct` is checked before total DD and daily DD checks (`can_open`: line 459). This is inconsistent with baseline’s Apex trailing DD (5% from HWM) and risks admitting trades under an invalid risk model. | Align risk model to baseline: trailing DD from HWM (5%) + daily DD tiers and remove the incorrect `daily_dd >= max_total_loss_pct` check. If this module is intentionally “FTMO”, rename/config-scope it and prevent use in Apex audits. |
| B-002 | CRITICAL | ea_logic_python.py:542-576 | Optimistic execution: `EntryOptimizerPython.build_entry()` can return an `entry` better than the current price (e.g., BUY uses `entry = min(price, (low+high)/2)` or `min(price, low)`), but there is no fill simulation (waiting for price to touch, rejection, slippage). When downstream backtest code opens a trade immediately at `setup.entry`, this becomes “free limit fill” and can inflate results. | Either (a) return only market-executable entries (at current bid/ask + slippage) or (b) return *orders* (limit/stop) and require the backtester to simulate fills (touch + latency + reject + partial fill). |
| B-003 | CRITICAL | ea_logic_compat.py:184-224 | Compat `RiskManager` hardcodes pip value as `sl_pips * 10.0` (line 199), which is not instrument-aware and is likely wrong for XAUUSD. This makes lot sizing non-comparable to the baseline (which is instrument-aware). | Replace hardcoded pip value with instrument-aware pip/tick valuation consistent with baseline (tick_size, lot_size, point value per unit). If this file is kept only as a toy shim, explicitly label “NOT FOR METRICS / NOT FOR VALIDATION” and prevent it from being used in benchmark runs. |
| B-004 | CRITICAL | ea_logic_python.py:599-689 | No Apex time gates exist (4:30 PM ET block, 4:55 PM emergency close, 4:59 PM hard flatten). SessionFilter is not a substitute for Apex gates; baseline enforces them via `TimeConstraintManager` (`gold_scalper_strategy.py:980-987`, `gold_scalper_strategy.py:1868-1870`). | Add Apex time gates to this path or prevent it from being used in any Apex-labeled “realistic” backtest. |

### HIGH

| ID | Severity | File:Line | Description | Recommended Fix |
|----|----------|-----------|-------------|-----------------|
| B-005 | HIGH | adaptive_kelly.py:90-105 | `AdaptiveKelly` DD limits are FTMO-like (`MAX_TOTAL_DD=10%`, `MAX_DAILY_DD=5%`) and not aligned with Apex trailing DD 5% from HWM. Using this sizing in an Apex context can oversize during HWM-trap conditions. | Parameterize limits for Apex (5% trailing from HWM incl. unrealized, plus conservative halt buffers e.g. 4.0%/4.5% tiers). |
| B-006 | HIGH | adaptive_kelly.py:206-212 and 339-347 | DD tracking is based on `current_balance`/`peak_balance` (realized balance), not mark-to-market equity incl. unrealized PnL. Apex trailing DD requires unrealized-inclusive HWM; this module cannot satisfy that invariant without external equity feed. | Rename variables to `equity` (not balance) and require caller to pass mark-to-market equity; track HWM accordingly. |
| B-007 | HIGH | ea_logic_compat.py:226-314 | Compat `EALogic` is structurally inconsistent with baseline strategy: no spread/news gates, simplistic ATR (`(high-low)*2`), simplistic TP/SL construction, and direction logic depends mostly on ML probability/RSI. It should not be used as “EA parity” alternative. | Keep only for smoke tests, or remove from any “realistic” backtest path. If retained, add explicit “compat only” guardrails and ensure default backtest chooses `ea_logic_full` or the Nautilus strategy. |
| B-008 | HIGH | ea_logic_python.py:599-689 | Strategy uses the last bar close as `price` (`close.iloc[-1]`) and immediately constructs entries/SL/TP. If this is used for bar-based backtests without next-bar execution, it can embed implicit look-ahead (deciding on close and filling at same close without latency/slippage). Baseline uses tick-level spread and execution costs. | Ensure backtest engine executes entries on next bar/open or next tick with spread+slippage, or provide explicit “decision_time vs execution_time” separation. |

### MEDIUM

| ID | Severity | File:Line | Description | Recommended Fix |
|----|----------|-----------|-------------|-----------------|
| B-009 | MEDIUM | ea_logic_python.py:605-608 | Spread conversion is ambiguous: `raw_spread` is treated as “points if >5 else raw_spread / point_value”. If spread is stored in price units (e.g., 0.45) this becomes 45 points (assuming point_value=0.01). This relies on a heuristic and can silently mis-scale. | Make spread units explicit (price vs points) and enforce with validation/typing. |
| B-010 | MEDIUM | ea_logic_python.py:670-676 | MTF alignment fallback uses `htf_df['close'].iloc[-1]` and a rolling MA. If `htf_df` contains an incomplete HTF bar at the same timestamp, this can introduce cross-time leakage. Baseline emphasizes bar completion semantics for timeframes. | Require HTF series aligned to closed HTF bars only and document the expected indexing contract. |
| B-011 | MEDIUM | adaptive_kelly.py:418-461 | `get_risk_of_ruin()` uses an equity update model that does not scale risk by current equity (adds/subtracts `f*r` instead of `equity*f*r`). This makes RoR numbers unreliable (under/over-stated depending on conditions). | Rework RoR simulation to apply fraction-of-current-equity risk, or remove it from decision-making metrics. |

### LOW

| ID | Severity | File:Line | Description | Recommended Fix |
|----|----------|-----------|-------------|-----------------|
| B-012 | LOW | ea_logic_python.py:574-576 | Comment says using `cfg.min_rr` is “relaxed”; in some regimes this is actually stricter than `strat.min_rr`. This is confusing and increases audit risk. | Clarify intent: which RR is authoritative, and why. |

---

## Look-ahead / leakage assessment

- Confirmed direct “future index” (+1 beyond available history): NOT FOUND in these three files.
- Material optimistic execution assumptions: FOUND.
  - `ea_logic_python.py` builds entries that may be below/above current price and provides no fill simulation.
  - `ea_logic_compat.py` fills at `bar.close` with simplistic volatility proxy; not comparable to baseline.
- Cross-timeframe leakage risk: POSSIBLE.
  - `ea_logic_python.py` expects caller to pass HTF bars with correct “closed-bar” semantics; no guard is enforced.

Leakage status for Phase 06 criteria: FAIL (due to optimistic fills / execution unrealism), even if strict “bars[i+1]” violations are not present.

---

## Consistency notes vs baseline Nautilus strategy

1) Risk/DD
- Baseline: trailing DD limit configured at 5% with tick-level mark-to-market updates (`gold_scalper_strategy.py:224-225`, `gold_scalper_strategy.py:1904-1914`).
- `ea_logic_python.py`/`adaptive_kelly.py`: FTMO-like defaults (10% total DD) and balance-based tracking.
- `ea_logic_compat.py`: no DD logic at all; only Kelly-like scaling from realized trade results.

2) Time gates
- Baseline: `TimeConstraintManager` gates entries after ~4:30 PM ET and enforces cutoff flattening; checked in `on_quote_tick` and on-bar signal checks.
- Alternatives: no equivalent.

3) Execution realism
- Baseline: spread monitor and execution cost modeling hooks.
- Alternatives: spread check exists only as a threshold, no slippage/commission fill integration, and entries can be “better than market” without modeling.

---

## Validation steps (recommended)

- Confirm how these modules are used in Phase 06 backtests:
  - Identify runs using `ea_logic_python.py` or `ea_logic_compat.py` and treat metrics as non-authoritative until execution realism is fixed.
- Add/verify guardrails:
  - A backtest “realism mode” should fail-fast if a strategy returns an entry price that is not market-executable at decision time (unless it returns an explicit limit/stop order type).
  - Ensure HTF inputs are strictly closed bars.

---

## CRITIC self-review applied
- Techniques used: INVERSION, PRE-MORTEM, APEX TRAP, EDGE CASES
- Hidden issues found: 2
  - “Free limit fill” via `entry = min(price, zone_mid)` in ea_logic_python.
  - XAUUSD pip value hardcoding in ea_logic_compat.
- Assumptions challenged:
  - That `ltf_df`/`htf_df` inputs always contain only closed bars.
  - That spread values are consistently in “points”.
- Confidence: HIGH
