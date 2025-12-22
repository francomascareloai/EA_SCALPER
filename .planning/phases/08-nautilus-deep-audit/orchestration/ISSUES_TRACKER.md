# Issues Tracker (Nautilus Deep Audit)

## How to Use
- Working playbook + PR-sized checklist: `REMEDIATION_GUIDE.md`

## Status Values
- Open
- In Progress
- Fixed (commit hash)
- Accepted (risk accepted with justification)
- Deferred

## Notes
- Canonical IDs are deduplicated by issue ID; phase-scoped prefixes are added when the original ID was collision-prone (e.g., `B-001`).
- Status is taken from `MANIFEST.md` when an issue ID exists there; otherwise defaults to Open.

## Summary (Open)
- CRITICAL: 40
- HIGH: 54
- MEDIUM: 42
- LOW: 17

## CRITICAL (Open)
| ID | Category | Phase Hint | Summary | Sources |
|---|---|---|---|---|
| P04-A-001 | Risk / Drawdown | 04-A | ICT Step 5 (`at_poi`) is incorrectly computed as “any valid OB/FVG exists”, not “price is at POI”. This will systematically over-count sequence steps and add +5... | PHASE_04_A_SCORING_FINDINGS.md |
| P04-A-016 | Test Coverage | 04-A | Test coverage mismatch: repository tests reference `src.indicators.mtf_manager.MTFManager`, but the trading strategy uses `src.signals.mtf_manager.MTFManager`. ... | PHASE_04_A_SCORING_FINDINGS.md |
| P04-B-006 | Apex Compliance | 04-B | Timezone-aware vs naive datetime mismatch: the module uses `datetime.utcnow()` (naive) by default, but `NewsEvent.time_utc` is timezone-aware (UTC). Comparing o... | PHASE_04_B_NEWS_FINDINGS.md |
| P04.5-C-ML-001 | Temporal Integrity | 04.5 | StackingEnsemble uses KFold (non-temporal) -> look-ahead leakage if used | MANIFEST.md |
| P05-B-B-001 | Execution Safety | 05-B | No latency/partial/reject modeling in `ExecutionModel` | PHASE_05_B_ADAPTERS_FINDINGS.md |
| P05-B-B-002 | Other | 05-B | Slippage applied post-fill, not in fill price/time | PHASE_05_B_ADAPTERS_FINDINGS.md |
| P05-B-B-003 | Execution Safety | 05-B | MT5/Ninja adapters are stubs; `connect()` is fail-open | PHASE_05_B_ADAPTERS_FINDINGS.md |
| P06-R1-A-001 | Temporal Integrity | 06-R1 | Confirmed HTF look-ahead leakage (EA parity path lacks HTF "as-of" slicing) | MANIFEST.md |
| P06-R1-A-002 | Apex Compliance | 06-R1 | Missing Apex ET time gates (4:30/4:55/4:59) in backtest strategy scripts | MANIFEST.md |
| P06-R1-A-003 | Apex Compliance | 06-R1 | Risk model uses realized balance; not Apex trailing DD from HWM incl unrealized | MANIFEST.md |
| P06-R1-A-004 | Execution Safety | 06-R1 | Optimistic execution: decide+fill at same bar close; no bid/ask, slippage, commissions | MANIFEST.md |
| P06-R1-A-A-001 | Temporal Integrity | 06-R1-A | CONFIRMED HTF look-ahead leakage: `evaluate_from_df()` consumes the provided `htf_df` as-is (`h1_closes = htf['close'].values`) without enforcing an “as-of now”... | PHASE_06_R1_A_EALOGIC_FINDINGS.md |
| P06-R1-A-A-002 | Apex Compliance | 06-R1-A | Missing Apex ET time gates (4:30 PM ET block new, 4:55 PM ET emergency close, 4:59 PM ET hard flatten). The only time gating is a GMT-offset session filter (and... | PHASE_06_R1_A_EALOGIC_FINDINGS.md |
| P06-R1-A-A-003 | Apex Compliance | 06-R1-A | Risk/DD model is not Apex trailing DD from HWM including unrealized. `RiskManager` tracks `balance`/`peak_balance` updated only on `record_trade()` (realized-on... | PHASE_06_R1_A_EALOGIC_FINDINGS.md |
| P06-R1-A-A-004 | Apex Compliance | 06-R1-A | Execution realism gap: EA parity setups are filled at `current_price = close.iloc[-1]` with `entry = current_price` and no bid/ask, slippage, latency, commissio... | PHASE_06_R1_A_EALOGIC_FINDINGS.md |
| P06-R1-B-001 | Risk / Drawdown | 06-R1 | RiskManagerPython uses FTMO-like limits and has gating bug (`daily_dd >= max_total_loss_pct`) | MANIFEST.md |
| P06-R1-B-002 | Other | 06-R1 | “Free limit fill” entries possible without fill simulator (EntryOptimizerPython) | MANIFEST.md |
| P06-R1-B-003 | Risk / Drawdown | 06-R1 | XAUUSD pip value hardcoded in compat risk sizing (instrument-unaware) | MANIFEST.md |
| P06-R1-B-004 | Apex Compliance | 06-R1 | Missing Apex time gates in ea_logic_python | MANIFEST.md |
| P06-R1-B-B-001 | Apex Compliance | 06-R1-B | `RiskManagerPython` uses FTMO-style limits (default `max_total_loss_pct=10.0`) and has an internal logic bug: `daily_dd >= max_total_loss_pct` is checked before... | PHASE_06_R1_B_ALTSTRAT_FINDINGS.md |
| P06-R1-B-B-002 | Apex Compliance | 06-R1-B | Optimistic execution: `EntryOptimizerPython.build_entry()` can return an `entry` better than the current price (e.g., BUY uses `entry = min(price, (low+high)/2)... | PHASE_06_R1_B_ALTSTRAT_FINDINGS.md |
| P06-R1-B-B-003 | Risk / Drawdown | 06-R1-B | Compat `RiskManager` hardcodes pip value as `sl_pips * 10.0` (line 199), which is not instrument-aware and is likely wrong for XAUUSD. This makes lot sizing non... | PHASE_06_R1_B_ALTSTRAT_FINDINGS.md |
| P06-R1-B-B-004 | Apex Compliance | 06-R1-B | No Apex time gates exist (4:30 PM ET block, 4:55 PM emergency close, 4:59 PM hard flatten). SessionFilter is not a substitute for Apex gates; baseline enforces ... | PHASE_06_R1_B_ALTSTRAT_FINDINGS.md |
| P06-R2-D-P06-R2D-001 | Temporal Integrity | 06-R2-D | Confirmed leakage via dependency: script runs `TickBacktester` with `use_ea_logic=True`, which is currently affected by HTF look-ahead in the EA parity evaluati... | PHASE_06_R2_D_STATVALID_FINDINGS.md |
| P06-R2-D-P06-R2D-007 | Temporal Integrity | 06-R2-D | Confirmed look-ahead hazard via dependency: WFA calls `SMCAblationBacktester`, which precomputes OB/FVG structures using future bars (e.g., `i+1:i+4`) before si... | PHASE_06_R2_D_STATVALID_FINDINGS.md |
| P06-R2-E-P06-R2E-001 | Temporal Integrity | 06-R2-E | Confirmed look-ahead leakage: `MTFAnalyzer.calculate_alignment()` ignores `current_idx` and computes moving averages using the *end of the full timeframe series... | PHASE_06_R2_E_BACKTESTER_FINDINGS.md |
| P06-R2-E-P06-R2E-002 | Apex Compliance | 06-R2-E | Apex compliance mismatch: risk model is FTMO-like (`max_daily_dd=5%`, `max_total_dd=10%`) and equity is treated as realized-only balance (no unrealized PnL, no ... | PHASE_06_R2_E_BACKTESTER_FINDINGS.md |
| P06-R2-P06-R2D-001 | Temporal Integrity | 06-R2 | Validation leakage via dependency: "MC" script runs leaky EA parity path (`use_ea_logic=True`) | MANIFEST.md |
| P06-R2-P06-R2D-007 | Temporal Integrity | 06-R2 | WFA leakage via dependency: precomputed forward-confirmed SMC structures used without confirmation lag | MANIFEST.md |
| P06-R2-P06-R2E-001 | Temporal Integrity | 06-R2 | Confirmed look-ahead leakage: compat MTF alignment uses full-series `.iloc[-1]` | MANIFEST.md |
| P06-R2-P06-R2E-002 | Apex Compliance | 06-R2 | Apex mismatch: FTMO-like DD + realized-only equity + missing ET gates in realistic_backtester | MANIFEST.md |
| P07-001 | Test Coverage | 07 | Coverage below minimum thresholds (52.68% line / 28.66% branch) | MANIFEST.md, PHASE_07_COVERAGE_FINDINGS.md |
| P07-002 | Test Coverage | 07 | Core strategy orchestration largely untested (`gold_scalper_strategy.py` ~15% line) | MANIFEST.md, PHASE_07_COVERAGE_FINDINGS.md |
| P08-001 | Risk / Drawdown | 08 | DD breach does not force-flatten open positions (can block entries only) | MANIFEST.md | **Fixed (WP2)** |
| P08-002 | Risk / Drawdown | 08 | Multiple DD systems have inconsistent thresholds/enforcement (DDProtection/DrawdownTracker/CircuitBreaker) | MANIFEST.md | **Fixed (WP2)** |
| P08-003 | Apex Compliance | 08 | Cross-timeframe semantic collision: MTF zones overwritten by LTF detections (`_mtf_order_blocks/_mtf_fvgs`) | MANIFEST.md |
| P08-004 | Apex Compliance | 08 | Bracket SL/TP is not fail-safe; reject/failure can leave naked position | MANIFEST.md | **In Progress (WP0)** |
| P08-005 | Execution Safety | 08 | Missing order-event state machine; stale pending SL/TP can persist across rejects/cancels | MANIFEST.md | **In Progress (WP0)** |
| P08-006 | Apex Compliance | 08 | Live time gates are data-driven (ts_event); no wall-clock/scheduler fail-safe under feed stalls | MANIFEST.md | **Fixed (WP1)** |
| P08-007 | Apex Compliance | 08 | No guaranteed 'flat by 16:59 ET' enforcement independent of tick arrival (opportunistic closes) | MANIFEST.md | **Fixed (WP1)** |

## HIGH (Open)
| ID | Category | Phase Hint | Summary | Sources |
|---|---|---|---|---|
| P01-H-002 | Apex Compliance | 01 | Session detection uses UTC-now buckets (DST + nondeterministic backtests) | MANIFEST.md |
| P01-H-003 | Other | 01 | Time-gate enforcement depends on external manager (Phase 01 cannot verify 4:55/4:59 behavior) | MANIFEST.md |
| P02-R1-H-004 | Apex Compliance | 02-R1 | Caller contract not enforced for bar completion (array `[-1]` usage) | MANIFEST.md |
| P02-R1-H-005 | Test Coverage | 02-R1 | Missing unit tests for liquidity/structure indicators | MANIFEST.md |
| P02-R1-H-006 | Other | 02-R1 | Missing internal vs external liquidity/structure distinction | MANIFEST.md |
| P02-R1-H-007 | Other | 02-R1 | Breaker block mentioned but not implemented (OB) | MANIFEST.md |
| P02-R1-H-008 | Other | 02-R1 | IFVG not implemented (FVG) | MANIFEST.md |
| P02-R1-H-009 | Other | 02-R1 | SessionFilter late-hours fallback may misclassify session | MANIFEST.md |
| P03-R2-F-O-001 | Other | 03-R2-F | (heading) | PHASE_03_R2_FOLLOWUP_FINDINGS.md |
| P03-R2-F-O-002 | Other | 03-R2-F | (heading) | PHASE_03_R2_FOLLOWUP_FINDINGS.md |
| P04-A-002 | Signal Quality | 04-A | Alignment multiplier uses a hard threshold `score > 7.0` but the underlying component scores are not normalized 0–100 (they appear to be weight-capped values su... | PHASE_04_A_SCORING_FINDINGS.md |
| P04-A-007 | Apex Compliance | 04-A | Entry expiry uses wall-clock `datetime.now(timezone.utc)` instead of market/bar time. In backtests (or replay), this breaks temporal correctness: setups may not... | PHASE_04_A_SCORING_FINDINGS.md |
| P04-A-008 | Apex Compliance | 04-A | `has_expired()` also uses wall-clock `datetime.now(timezone.utc)`, compounding the same issue. | PHASE_04_A_SCORING_FINDINGS.md |
| P04-A-013 | Temporal Integrity | 04-A | MTF analysis has no timestamp/bar-close semantics. It accepts arrays + a single `current_price` and feeds that same `current_price` into all timeframe analyzers... | PHASE_04_A_SCORING_FINDINGS.md |
| P04-B-001 | Apex Compliance | 04-B | Naive timestamps are silently assumed to be UTC, which can shift event time by 4–5 hours if an upstream source provides ET timestamps without tzinfo (DST-depend... | PHASE_04_B_NEWS_FINDINGS.md |
| P04-B-002 | Temporal Integrity | 04-B | Hardcoded calendar coverage is extremely narrow (only a handful of Dec 2025 events). In 2026+ live trading the cache becomes empty, disabling news protection; i... | PHASE_04_B_NEWS_FINDINGS.md |
| P04.5-H-ML-001 | Temporal Integrity | 04.5 | Scaling/parity not enforced; scaler not persisted -> leakage + inference drift risk | MANIFEST.md |
| P04.5-H-ML-002 | Temporal Integrity | 04.5 | No index order validation -> rolling windows can leak if data sorted descending | MANIFEST.md |
| P05-B-B-004 | Other | 05-B | Tick streaming loads full file + iterrows, no monotonic checks | PHASE_05_B_ADAPTERS_FINDINGS.md |
| P05-B-B-005 | Execution Safety | 05-B | Adapter interface lacks ack/fill/reject lifecycle and error codes | PHASE_05_B_ADAPTERS_FINDINGS.md |
| P06-C-001 | Other | 06-R1 | FibonacciAnalyzer fallback indexing bug (wrong slice/value pairing) | MANIFEST.md |
| P06-C-002 | Apex Compliance | 06-R1 | FibonacciAnalyzer returns first swing found (not most recent) | MANIFEST.md |
| P06-C-003 | Temporal Integrity | 06-R1 | FibonacciAnalyzer lacks explicit as-of contract; easy to leak future bars via full-series inputs | MANIFEST.md |
| P06-C-004 | Other | 06-R1 | P1 harness invalid fib analysis (insufficient history) | MANIFEST.md |
| P06-R1-A-A-005 | Apex Compliance | 06-R1-A | MQL5 “series” parity mismatch likely: Liquidity sweep detection uses indices as if `0` is the most recent bar (`returned_inside = closes[0] ...`, loops `for j i... | PHASE_06_R1_A_EALOGIC_FINDINGS.md |
| P06-R1-A-A-006 | Apex Compliance | 06-R1-A | Temporal hazard: order block detection uses forward bars relative to a candidate candle (`h[i+1:i+4]`, `l[i+1:i+4]`) to confirm displacement. This is only causa... | PHASE_06_R1_A_EALOGIC_FINDINGS.md |
| P06-R1-A-A-007 | Apex Compliance | 06-R1-A | Time/session logic is GMT-offset based, not ET via `America/New_York`. DST correctness is not guaranteed; Friday close gate is in GMT-hour space. | PHASE_06_R1_A_EALOGIC_FINDINGS.md |
| P06-R1-A-A-008 | Other | 06-R1-A | Gate stats bug: `gate_blocks` initializes only `GATE_1..GATE_10`, but the code increments `GATE_11`. With ML enabled and direction mismatch, this can throw KeyE... | PHASE_06_R1_A_EALOGIC_FINDINGS.md |
| P06-R1-B-B-005 | Apex Compliance | 06-R1-B | `AdaptiveKelly` DD limits are FTMO-like (`MAX_TOTAL_DD=10%`, `MAX_DAILY_DD=5%`) and not aligned with Apex trailing DD 5% from HWM. Using this sizing in an Apex ... | PHASE_06_R1_B_ALTSTRAT_FINDINGS.md |
| P06-R1-B-B-006 | Apex Compliance | 06-R1-B | DD tracking is based on `current_balance`/`peak_balance` (realized balance), not mark-to-market equity incl. unrealized PnL. Apex trailing DD requires unrealize... | PHASE_06_R1_B_ALTSTRAT_FINDINGS.md |
| P06-R1-B-B-007 | News / Calendar | 06-R1-B | Compat `EALogic` is structurally inconsistent with baseline strategy: no spread/news gates, simplistic ATR (`(high-low)*2`), simplistic TP/SL construction, and ... | PHASE_06_R1_B_ALTSTRAT_FINDINGS.md |
| P06-R1-B-B-008 | Temporal Integrity | 06-R1-B | Strategy uses the last bar close as `price` (`close.iloc[-1]`) and immediately constructs entries/SL/TP. If this is used for bar-based backtests without next-ba... | PHASE_06_R1_B_ALTSTRAT_FINDINGS.md |
| P06-R2-D-P06-R2D-002 | Apex Compliance | 06-R2-D | Misleading methodology: labeled “Monte Carlo” but performs a single seeded random conversion per degradation level, with no repeated simulations, no bootstrap/p... | PHASE_06_R2_D_STATVALID_FINDINGS.md |
| P06-R2-D-P06-R2D-005 | Apex Compliance | 06-R2-D | Reproducibility + safety issue: hardcoded Windows paths and `sys.path.insert(...)` import injection. | PHASE_06_R2_D_STATVALID_FINDINGS.md |
| P06-R2-D-P06-R2D-008 | Apex Compliance | 06-R2-D | WFA window sizing is incorrect: with defaults `n_windows=5`, `is_ratio=0.7`, the loop only reaches `oos_end ≈ 0.44 * n` (leaving ~56% of bars unused). This is n... | PHASE_06_R2_D_STATVALID_FINDINGS.md |
| P06-R2-D-P06-R2D-012 | Apex Compliance | 06-R2-D | Hardcoded Windows file paths for input data and report output (and diverges from the project’s single canonical dataset rule). | PHASE_06_R2_D_STATVALID_FINDINGS.md |
| P06-R2-E-P06-R2E-003 | Risk / Drawdown | 06-R2-E | Temporal correctness risk: bars are generated via `resample(tf).ohlc()` with default bin labeling; the simulation then uses `timestamp` with `bar['close']` for ... | PHASE_06_R2_E_BACKTESTER_FINDINGS.md |
| P06-R2-E-P06-R2E-004 | Execution Safety | 06-R2-E | Execution realism gaps: mid-based OHLC + mean spread, no commission, no partial fills, no bid/ask bar extremes. SL/TP triggers use mid high/low, which can mater... | PHASE_06_R2_E_BACKTESTER_FINDINGS.md |
| P06-R2-E-P06-R2E-005 | Apex Compliance | 06-R2-E | Correctness bug in FULL mode: when `USE_FULL_LOGIC` is true, `self.ea_logic` is set to `None`, but `_close_position()` calls `self.ea_logic.risk_manager.update_... | PHASE_06_R2_E_BACKTESTER_FINDINGS.md |
| P06-R2-E-P06-R2E-006 | Other | 06-R2-E | Hardcoded Windows paths + `sys.path.insert(...)` import injection. These scripts are not portable and are vulnerable to path hijacking (importing unintended cod... | PHASE_06_R2_E_BACKTESTER_FINDINGS.md |
| P06-R2-E-P06-R2E-007 | Apex Compliance | 06-R2-E | Data contract mismatch: multi-year runner depends on per-year parquet files and only samples `max_ticks=15_000_000` (~3 months), which can introduce selection b... | PHASE_06_R2_E_BACKTESTER_FINDINGS.md |
| P07-003 | Test Coverage | 07 | News filtering path effectively untested (`news_trader.py` 0% line) | MANIFEST.md, PHASE_07_COVERAGE_FINDINGS.md |
| P07-004 | Test Coverage | 07 | Validation framework untested (`src/validation/*` 0% line) | MANIFEST.md, PHASE_07_COVERAGE_FINDINGS.md |
| P07-005 | Apex Compliance | 07 | Scoring/confluence coverage incomplete despite known Phase 04 risks | MANIFEST.md, PHASE_07_COVERAGE_FINDINGS.md |
| P08-008 | Risk / Drawdown | 08 | PositionSizer drawdown throttle not driven by live drawdown (`current_drawdown_pct` not passed) | MANIFEST.md |
| P08-009 | Risk / Drawdown | 08 | Tick-level equity/HWM sources differ across modules (potential drift) | MANIFEST.md |
| P08-010 | Apex Compliance | 08 | Strategy does not pass real timestamps into detectors; synthetic timestamps break time-based logic | MANIFEST.md |
| P08-011 | Test Coverage | 08 | Backtest config wiring likely omits HTF/MTF bar subscriptions (strategy may run LTF-only) | MANIFEST.md |
| P08-012 | Risk / Drawdown | 08 | Execution costs not included in pre-trade R:R or risk gating; validate_trade underestimates worst-case loss | MANIFEST.md |
| P08-013 | Other | 08 | TradeManager exists but is not integrated into strategy (trailing/partial TP logic inactive) | MANIFEST.md |
| P08-014 | Apex Compliance | 08 | Mixed daily boundary logic (ET vs UTC) across modules risks inconsistent daily limits | MANIFEST.md |
| P08-015 | Apex Compliance | 08 | Wall-clock usage in backtest-sensitive modules (SpreadMonitor/EntryOptimizer) breaks determinism | MANIFEST.md |
| P08-016 | Apex Compliance | 08 | ET ZoneInfo availability handling inconsistent (some fail-hard, some fail-safe) | MANIFEST.md |
| P08-017 | Risk / Drawdown | 08 | PositionSizer drawdown throttle bypassed in signal/execution path (`calculate_lot` default drawdown=0.0) | MANIFEST.md |

## MEDIUM (Open)
| ID | Category | Phase Hint | Summary | Sources |
|---|---|---|---|---|
| P02-R0-M-003 | Apex Compliance | 02-R0 | No HTF bar completion verification (caller contract) | MANIFEST.md |
| P02-R0-M-004 | Execution Safety | 02-R0 | EMA performance borderline (needs profiling) | MANIFEST.md |
| P03-R2-F-O-003 | Other | 03-R2-F | (heading) | PHASE_03_R2_FOLLOWUP_FINDINGS.md |
| P03-R2-F-O-004 | Other | 03-R2-F | (heading) | PHASE_03_R2_FOLLOWUP_FINDINGS.md |
| P04-A-003 | Test Coverage | 04-A | Freshness multiplier uses OB “age” approximation `touch_count * 2` (comment notes “would need bar_index”). This can mis-rank OB freshness and distort scoring in... | PHASE_04_A_SCORING_FINDINGS.md |
| P04-A-004 | Apex Compliance | 04-A | `ConfluenceScorer.config` is `None` by default and no in-repo call site sets it, but `_calculate_total` tries to enforce `config.confluence_min_score`. This is ... | PHASE_04_A_SCORING_FINDINGS.md |
| P04-A-009 | Apex Compliance | 04-A | `min_rr_ratio` and `target_rr_ratio` are stored but not enforced anywhere in `calculate_optimal_entry`. Low R:R entries are still marked `is_valid=True` even if... | PHASE_04_A_SCORING_FINDINGS.md |
| P04-A-010 | Apex Compliance | 04-A | Spread penalty divides `risk_reward` by `spread_ratio`, but TP/SL prices remain unchanged. This makes `risk_reward` field inconsistent with actual levels used f... | PHASE_04_A_SCORING_FINDINGS.md |
| P04-A-011 | Apex Compliance | 04-A | Market-entry fallback uses `default_sl_price` directly without spread/slippage buffer. In realistic execution (XAUUSD), spreads spike; this can produce under-pr... | PHASE_04_A_SCORING_FINDINGS.md |
| P04-A-014 | Risk / Drawdown | 04-A | Strength scoring mixes “bias” (40/20) + `structure_score * 0.3` (structure score is 0–100, so this term can add up to 30) + BOS/CHoCH bonuses. Verify the intend... | PHASE_04_A_SCORING_FINDINGS.md |
| P04-A-015 | Other | 04-A | Alignment strength weights can sum to <1.0 depending on transitional MTF weight (0.25). This effectively reduces alignment_strength even when aligned, but no ex... | PHASE_04_A_SCORING_FINDINGS.md |
| P04-B-003 | Apex Compliance | 04-B | “Today/This week” calculations are defined in UTC day boundaries, not `America/New_York`. This can mismatch trader expectations around midnight ET and around DS... | PHASE_04_B_NEWS_FINDINGS.md |
| P04-B-004 | Other | 04-B | `diff_minutes = int(diff_seconds / 60)` truncates toward zero, slightly expanding blackout/window edges by up to ~59 seconds, especially on the “after release” ... | PHASE_04_B_NEWS_FINDINGS.md |
| P04-B-007 | Other | 04-B | Calendar duplication/key collision: `events_by_time[event.time_utc] = event` will overwrite events with identical timestamps (e.g., NFP and Unemployment Rate re... | PHASE_04_B_NEWS_FINDINGS.md |
| P04-B-008 | Other | 04-B | `update_calendar()` only appends and never de-duplicates, so repeated updates can accumulate duplicates and distort window logic. | PHASE_04_B_NEWS_FINDINGS.md |
| P04.5-M-ML-001 | Apex Compliance | 04.5 | Feature order/metadata not enforced; silent inference mismatch risk | MANIFEST.md |
| P04.5-M-ML-002 | Temporal Integrity | 04.5 | Label alignment not validated; future-shift labels can leak | MANIFEST.md |
| P05-B-B-006 | Test Coverage | 05-B | Random slippage jitter makes backtests non-reproducible | PHASE_05_B_ADAPTERS_FINDINGS.md |
| P05-B-B-007 | Apex Compliance | 05-B | Holiday detector exists but is not wired into execution/risk | PHASE_05_B_ADAPTERS_FINDINGS.md |
| P06-R1-A-A-009 | Apex Compliance | 06-R1-A | Spread unit heuristic is ambiguous: `spread_points = int(raw_spread if raw_spread > 5 else raw_spread / point_value)` guesses whether spread is in points vs pri... | PHASE_06_R1_A_EALOGIC_FINDINGS.md |
| P06-R1-A-A-010 | Other | 06-R1-A | M15 is approximated by downsampling M5 (`m5[::3]`) and scaling ATR (`m15_atr = m5_atr * 1.5`) rather than true resampling. | PHASE_06_R1_A_EALOGIC_FINDINGS.md |
| P06-R1-A-A-011 | Apex Compliance | 06-R1-A | Non-determinism risk when timestamps are missing: `get_position_size()` falls back to `datetime.utcnow()` if `timestamp` is None; legacy `evaluate()` falls back... | PHASE_06_R1_A_EALOGIC_FINDINGS.md |
| P06-R1-A-A-012 | Other | 06-R1-A | `warnings.filterwarnings('ignore')` suppresses warnings globally. | PHASE_06_R1_A_EALOGIC_FINDINGS.md |
| P06-R1-B-B-009 | Signal Quality | 06-R1-B | Spread conversion is ambiguous: `raw_spread` is treated as “points if >5 else raw_spread / point_value”. If spread is stored in price units (e.g., 0.45) this be... | PHASE_06_R1_B_ALTSTRAT_FINDINGS.md |
| P06-R1-B-B-010 | Temporal Integrity | 06-R1-B | MTF alignment fallback uses `htf_df['close'].iloc[-1]` and a rolling MA. If `htf_df` contains an incomplete HTF bar at the same timestamp, this can introduce cr... | PHASE_06_R1_B_ALTSTRAT_FINDINGS.md |
| P06-R1-B-B-011 | Apex Compliance | 06-R1-B | `get_risk_of_ruin()` uses an equity update model that does not scale risk by current equity (adds/subtracts `f*r` instead of `equity*f*r`). This makes RoR numbe... | PHASE_06_R1_B_ALTSTRAT_FINDINGS.md |
| P06-R2-D-P06-R2D-003 | Apex Compliance | 06-R2-D | RNG is re-seeded inside `degrade_trades()` on every call (default `seed=42`), making degradation levels non-independent and nested. This is fine for a determini... | PHASE_06_R2_D_STATVALID_FINDINGS.md |
| P06-R2-D-P06-R2D-004 | Execution Safety | 06-R2-D | Degradation model is arbitrary: converts winners to losses via `-abs(win)/1.5` with no linkage to actual SL/TP distances, spread, or slippage. | PHASE_06_R2_D_STATVALID_FINDINGS.md |
| P06-R2-D-P06-R2D-009 | Temporal Integrity | 06-R2-D | No embargo/purging between IS/OOS. For pure rule-based backtests this can be acceptable, but if any features/labels overlap across boundaries (especially if lat... | PHASE_06_R2_D_STATVALID_FINDINGS.md |
| P06-R2-D-P06-R2D-010 | Apex Compliance | 06-R2-D | No minimum OOS trade count gate. A window with few trades can produce unstable returns and misleading WFE. | PHASE_06_R2_D_STATVALID_FINDINGS.md |
| P06-R2-D-P06-R2D-011 | Apex Compliance | 06-R2-D | WFE calculation uses `mean_oos/mean_is` and clips to [-2, 2]. For negative or near-zero IS returns this ratio becomes ill-defined and clipping can mask extreme ... | PHASE_06_R2_D_STATVALID_FINDINGS.md |
| P06-R2-E-P06-R2E-008 | Signal Quality | 06-R2-E | Script header claims multiple degradation factors (exit slippage, random loss conversion, spread multiplier) but the implementation only sweeps `base_slippage_p... | PHASE_06_R2_E_BACKTESTER_FINDINGS.md |
| P06-R2-E-P06-R2E-009 | Other | 06-R2-E | `warnings.filterwarnings('ignore')` suppresses warnings globally. | PHASE_06_R2_E_BACKTESTER_FINDINGS.md |
| P06-R2-E-P06-R2E-010 | Apex Compliance | 06-R2-E | Reproducibility: `realistic_backtester.py` uses randomness for latency/ONNX noise/slippage but has no seed control; multi-year runner does not set seeds. | PHASE_06_R2_E_BACKTESTER_FINDINGS.md |
| P07-006 | Apex Compliance | 07 | E2E tick backtest is not hermetic (skips without local data) | MANIFEST.md, PHASE_07_COVERAGE_FINDINGS.md |
| P07-007 | Test Coverage | 07 | Test imports inconsistent (`src.*` vs `nautilus_gold_scalper.src.*`) | MANIFEST.md, PHASE_07_COVERAGE_FINDINGS.md |
| P08-018 | Other | 08 | Redundant/duplicated gates can create confusing 'blocked' states | MANIFEST.md |
| P08-019 | Risk / Drawdown | 08 | Daily DD check uses `abs(_daily_pnl)` (could block on profits) | MANIFEST.md |
| P08-020 | Apex Compliance | 08 | Warmup gates not harmonized across components (incomplete HTF/MTF factors early-run) | MANIFEST.md |
| P08-021 | Other | 08 | Two MTF managers exist (`src/indicators/mtf_manager.py` vs `src/signals/mtf_manager.py`) | MANIFEST.md |
| P08-022 | Apex Compliance | 08 | ConfluenceScorer config threshold path is dead (`config` unset / None) | MANIFEST.md |
| P08-023 | Execution Safety | 08 | Emergency close closes positions but does not explicitly cancel open orders | MANIFEST.md |

## LOW (Open)
| ID | Category | Phase Hint | Summary | Sources |
|---|---|---|---|---|
| P02-R0-L-001 | Apex Compliance | 02-R0 | No gap detection in momentum | MANIFEST.md |
| P02-R0-L-002 | Other | 02-R0 | No warmup property exposed | MANIFEST.md |
| P02-R0-L-003 | Other | 02-R0 | No formal warmup validation beyond exception | MANIFEST.md |
| P04-A-005 | Risk / Drawdown | 04-A | `strong_aligned` comment says “>70% of max weight”, but the implementation is absolute (7.0) and counts components from `self._components` which are already wei... | PHASE_04_A_SCORING_FINDINGS.md |
| P04-A-006 | Signal Quality | 04-A | `at_poi` uses `not ob.state.value >= 2` which relies on operator precedence and is harder to read/review. | PHASE_04_A_SCORING_FINDINGS.md |
| P04-A-012 | Other | 04-A | `valid_until` assumes “15 min bars” regardless of actual LTF bar timeframe (comment: “15 min bars * max_wait_bars”). Entry system is used as M5 entry in docs; m... | PHASE_04_A_SCORING_FINDINGS.md |
| P04-B-005 | Apex Compliance | 04-B | `NewsEvent` contains `forecast/previous/actual` but the calendar currently never populates them; risk of confusion about whether the module supports result-base... | PHASE_04_B_NEWS_FINDINGS.md |
| P04-B-009 | News / Calendar | 04-B | Pre-release “bias” logic uses forecast as a proxy for “actual” (`_analyze_news_impact(forecast, forecast, previous)`), which is not economically meaningful and ... | PHASE_04_B_NEWS_FINDINGS.md |
| P04-B-010 | Other | 04-B | Null checks are inconsistent with types: `forecast`/`previous` are typed as floats but code checks against `None`. Suggests upstream may pass `None` and that co... | PHASE_04_B_NEWS_FINDINGS.md |
| P06-R1-A-A-013 | Apex Compliance | 06-R1-A | The file claims “full port / parity”, but multiple components are explicitly “simplified for backtest” and baseline invariants (Apex ET gates, unrealized-inclus... | PHASE_06_R1_A_EALOGIC_FINDINGS.md |
| P06-R1-B-B-012 | Risk / Drawdown | 06-R1-B | Comment says using `cfg.min_rr` is “relaxed”; in some regimes this is actually stricter than `strat.min_rr`. This is confusing and increases audit risk. | PHASE_06_R1_B_ALTSTRAT_FINDINGS.md |
| P06-R2-D-P06-R2D-006 | Risk / Drawdown | 06-R2-D | Drawdown computation hardcodes `100_000` starting equity. Works for the current baseline config but is fragile if `initial_balance` differs. | PHASE_06_R2_D_STATVALID_FINDINGS.md |
| P06-R2-D-P06-R2D-013 | Other | 06-R2-D | `warnings.filterwarnings('ignore')` suppresses warnings globally. | PHASE_06_R2_D_STATVALID_FINDINGS.md |
| P06-R2-E-P06-R2E-011 | Other | 06-R2-E | Type hygiene: `regime: any` should be `typing.Any` (and the rest of the dataclass fields are typed). | PHASE_06_R2_E_BACKTESTER_FINDINGS.md |
| P06-R2-E-P06-R2E-012 | Apex Compliance | 06-R2-E | The script markets itself as “institutional-grade / mirrors real EA behavior”, but key parity elements are absent (Apex gates, HWM unrealized, commission, bid/a... | PHASE_06_R2_E_BACKTESTER_FINDINGS.md |
| P08-024 | Other | 08 | Max contracts naming vs units ambiguity in `validate_trade` callsite | MANIFEST.md |
| P08-025 | Apex Compliance | 08 | ExecutionModel volatility parameter unused in strategy cost path | MANIFEST.md |

## Accepted (from MANIFEST)
- Count: 2

## Fixed/Resolved (from MANIFEST)
- Count: 4

