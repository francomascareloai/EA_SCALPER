## PHASE 08-B: Indicator ↔ Strategy Integration Audit (NAUTILUS)

AGENT: NAUTILUS
VERSION: 3.1
CLAUDE_MD_VERSION: 3.10.9
STATUS: COMPLETE

### Scope
Trace integration:
- `BaseGoldStrategy.on_bar()` routing (HTF/MTF/LTF) → `GoldScalperStrategy._on_*_bar()`
- `GoldScalperStrategy._check_for_signal()` → `_calculate_confluence()` → indicator/analyzer calls

Focus:
- Update order (regime/session/structure/OB/FVG/liquidity/MTF/etc)
- Warmup periods respected (minimum bars, MTF completion)
- Bar/tick data flow correctness (no mixing timestamps/timeframes)
- Temporal correctness (no look-ahead via `[-1]` on full series)
- Strategy initialization sequence and indicator resets

### Files Reviewed
- `/home/franco/projetos/EA_SCALPER_XAUUSD/nautilus_gold_scalper/src/strategies/base_strategy.py`
- `/home/franco/projetos/EA_SCALPER_XAUUSD/nautilus_gold_scalper/src/strategies/gold_scalper_strategy.py`
- `/home/franco/projetos/EA_SCALPER_XAUUSD/nautilus_gold_scalper/src/indicators/regime_detector.py`
- `/home/franco/projetos/EA_SCALPER_XAUUSD/nautilus_gold_scalper/src/indicators/structure_analyzer.py`
- `/home/franco/projetos/EA_SCALPER_XAUUSD/nautilus_gold_scalper/src/indicators/order_block_detector.py`
- `/home/franco/projetos/EA_SCALPER_XAUUSD/nautilus_gold_scalper/src/indicators/fvg_detector.py`
- `/home/franco/projetos/EA_SCALPER_XAUUSD/nautilus_gold_scalper/src/indicators/liquidity_sweep.py`
- `/home/franco/projetos/EA_SCALPER_XAUUSD/nautilus_gold_scalper/src/indicators/amd_cycle_tracker.py`
- `/home/franco/projetos/EA_SCALPER_XAUUSD/nautilus_gold_scalper/src/indicators/footprint_analyzer.py`
- `/home/franco/projetos/EA_SCALPER_XAUUSD/nautilus_gold_scalper/src/indicators/session_filter.py`
- `/home/franco/projetos/EA_SCALPER_XAUUSD/nautilus_gold_scalper/src/signals/mtf_manager.py`
- `/home/franco/projetos/EA_SCALPER_XAUUSD/nautilus_gold_scalper/src/signals/confluence_scorer.py`
- `/home/franco/projetos/EA_SCALPER_XAUUSD/nautilus_gold_scalper/scripts/backtest/run_backtest.py` (config wiring check)

### Integration Map (Actual Call Graph)

**Lifecycle / init**
1. `BaseGoldStrategy.on_start()` loads instrument, subscribes to bars (`ltf_bar_type`, `mtf_bar_type`, `htf_bar_type`) and quote ticks.
2. Calls `GoldScalperStrategy._on_strategy_start()` to construct analyzers:
   - `SessionFilter`, `RegimeDetector`, `StructureAnalyzer`, `FootprintAnalyzer` (optional)
   - `OrderBlockDetector`, `FVGDetector`, `LiquiditySweepDetector`, `AMDCycleTracker`
   - `signals.MTFManager` (note: NOT `indicators/mtf_manager.py`), `ConfluenceScorer`

**Bar routing + analysis update**
- `BaseGoldStrategy.on_bar(bar)` routes by `bar.bar_type`:
  - HTF bar → `_htf_bars.append()` → `GoldScalperStrategy._on_htf_bar()`
  - MTF bar → `_mtf_bars.append()` → `GoldScalperStrategy._on_mtf_bar()`
  - LTF bar → `_ltf_bars.append()` → `GoldScalperStrategy._on_ltf_bar()` → if `_has_enough_data()` then `_check_for_signal(bar)`

**Signal path**
- `GoldScalperStrategy._check_for_signal(bar)` performs gates (flat/session/time/risk/spread/HTF bias) then calls:
  - `GoldScalperStrategy._calculate_confluence(bar)`
    - Builds arrays from `_ltf_bars[-200:]` for `StructureAnalyzer.analyze(highs,lows,closes)`
    - Footprint: `_footprint_analyzer.analyze_bar(...)` using current bar OHLCV and `bar.ts_event` timestamp
    - Sweeps: `_sweep_detector.detect(highs,lows,closes)` (timestamps not provided)
    - AMD: `_amd_tracker.analyze(highs,lows,closes,volumes)` (timestamps not provided)
    - MTF: `_analyze_mtf_component()` → `signals.MTFManager.analyze()` using arrays from `_htf_bars[-200:]`, `_mtf_bars[-200:]`, `_ltf_bars[-200:]` and `current_price=self._ltf_bars[-1].close`
    - Regime refresh: `RegimeDetector.analyze(closes)` every 20 LTF bars (requires >= max(multiscale_periods)=200 closes)
    - **Also re-runs OB/FVG detectors on LTF every 20 bars and overwrites `_mtf_order_blocks/_mtf_fvgs`**
    - Calls `ConfluenceScorer.calculate_score(...)` with:
      - `structure_state`, `regime_analysis`, `session_info`, `order_blocks=_mtf_order_blocks`, `fvgs=_mtf_fvgs`, `sweeps`, `amd_cycle`, `mtf_score`, `mtf_aligned`, `footprint_score`, `current_price`.

### Update Order Assessment
Observed effective order on LTF signal evaluation:
1. Session filter updated in `_check_for_signal()` (uses `bar.ts_event` converted to UTC datetime).
2. HTF alignment gate uses `_htf_bias` (updated only on HTF bars in `_on_htf_bar`).
3. `_calculate_confluence()`:
   - LTF structure analysis (StructureAnalyzer)
   - footprint analysis (optional)
   - liquidity sweeps + AMD (both use LTF arrays)
   - MTF alignment (signals.MTFManager uses HTF+MTF+LTF arrays)
   - LTF regime refresh (RegimeDetector) periodically
   - LTF OB + LTF FVG refresh (every 20 bars) overwriting “MTF zones” storage
   - Confluence scoring

**Key finding:** Update order is internally consistent, but there is a *cross-timeframe semantic collision* where MTF zone storage is overwritten by LTF detectors.

### Warmup / Minimum Bars / MTF Completion
- Base warmup gate: `BaseGoldStrategy._has_enough_data()` requires:
  - LTF >= 50
  - If `mtf_bar_type` configured: MTF >= 20
  - If `htf_bar_type` configured: HTF >= 10
- Additional warmups:
  - `_on_mtf_bar` returns until MTF bars >= 30.
  - `_on_htf_bar` uses `StructureAnalyzer` and returns if HTF closes < 50.
  - `_analyze_mtf_component` requires all TF >= 50.
  - `RegimeDetector.analyze()` requires >= 200 closes (by default multiscale max).

**Key finding:** Warmup gating exists, but TF-specific gates are not harmonized:
- Strategy can begin `_check_for_signal()` at HTF>=10/MTF>=20/LTF>=50, while:
  - HTF bias is not updated until HTF closes >= 50.
  - MTF zones are not updated until MTF bars >= 30.
  - MTF alignment is not computed until all TF >= 50.

This can produce long “early run” windows where trades are blocked (HTF bias RANGING), or confluence runs with incomplete MTF components. Some of this is intended, but it should be documented as a known behavior.

### Data Flow Correctness (Bars/Ticks, timestamps, timeframes)
**Good / consistent**
- Bar routing by `bar.bar_type` prevents mixing timeframes in storage.
- Session filtering uses bar timestamp (`bar.ts_event`) converted to UTC datetime, not wall clock.
- Spread monitoring runs on quote ticks; drawdown intrabar uses tick-based mark-to-market.

**Issues**
1) **Timestamp handling inside indicators uses synthetic timelines when not provided.**
   - `LiquiditySweepDetector.detect()` creates synthetic `timestamps = np.arange(n, dtype=np.int64).astype("datetime64[ns]")` if none.
   - `AMDCycleTracker.analyze()` sets `timestamps = np.arange(n).astype("datetime64[ns]")` if none.
   - `FVGDetector.detect()` does similar; `OrderBlockDetector.detect()` uses `np.arange(n, dtype="datetime64[ns]")`.

   In `_calculate_confluence()` the strategy does NOT pass real timestamps into sweeps/AMD/OB/FVG detectors (they are fed only arrays). Therefore any “expiry_hours”/“time decay” logic becomes detached from actual market time and will not reflect real-time progression.

2) **Cross-timeframe zone semantics are mixed:**
   - `_on_mtf_bar()` sets `_mtf_order_blocks` and `_mtf_fvgs` from M15 bars.
   - `_calculate_confluence()` overwrites `_mtf_order_blocks/_mtf_fvgs` using LTF bars every 20 bars.

   This means ConfluenceScorer receives “MTF zones” which may actually be LTF zones depending on last refresh. This is an integration correctness risk (timeframe leakage in analysis state).

3) **Config wiring gap for HTF/MTF subscriptions in backtest runner.**
   - `run_backtest.py` constructs `GoldScalperConfig` with `ltf_bar_type=bar_type`, but does not set `mtf_bar_type` or `htf_bar_type` in the shown config assembly.
   - If omitted, BaseGoldStrategy won’t subscribe to HTF/MTF bars; `_htf_bars/_mtf_bars` remain empty; MTF alignment and HTF bias gates will behave as “no data” or block.

   This appears consistent with the large amount of LTF-only logic in `_calculate_confluence()`, but it contradicts the strategy’s stated architecture (H1/M15/M5). Needs confirmation from full config pipeline.

### Temporal Correctness (Look-ahead, array usage)
**In-indicator loops are causal**
- OrderBlockDetector and FVGDetector explicitly scan with causal indexing (use i-1 vs i, and i-2..i patterns).

**But: full-series recomputation is used in strategy**
- Strategy passes arrays built from the full available window (e.g., last 200 bars) into detectors/analyzers at each call.
- These detectors/analyzers often reset internal state per call (e.g., StructureAnalyzer resets swings/breaks; OB/FVG reset storage each detect()).

This is not a “future peek” within the provided window (it uses historical bars only), but it is computationally heavier and can cause subtle behavioral differences vs incremental updates.

**Potential look-ahead via swing confirmation**
- `StructureAnalyzer._detect_swing_points` confirms swings by requiring `swing_strength` bars on both sides (`for i in range(strength, n-strength)` and compares highs[i+j]).
- When called on LTF windows, the last `strength` bars are not considered for swing points (good), but calling this on each new bar means swing points become “known” only after `strength` subsequent bars close — that is correct causally.

### Initialization + Resets
- `BaseGoldStrategy.on_reset()` explicitly does NOT clear bar history (to preserve indicator lookbacks). Good.
- `BaseGoldStrategy.on_stop()` cleans up: close positions, cancel orders, unsubscribe bars and quote ticks, then `_on_strategy_stop()`.

**Indicator state resets**
- Many detectors reset their internal storage each `detect()`/`analyze()` call (OB/FVG/Structure), so state persistence across bars is limited and controlled.

### Issue List (by Severity)

**CRITICAL (integration correctness)**
C1. Cross-timeframe semantic collision: `_mtf_order_blocks/_mtf_fvgs` populated from M15 in `_on_mtf_bar`, then overwritten by LTF detections in `_calculate_confluence()`.
- Effect: Signal generation consumes “MTF zones” that can be LTF-derived, violating intended architecture and risking incorrect confluence.
- Location: `/home/franco/projetos/EA_SCALPER_XAUUSD/nautilus_gold_scalper/src/strategies/gold_scalper_strategy.py` (`_on_mtf_bar`, `_calculate_confluence`).

**HIGH (temporal realism / expiry correctness)**
H1. Strategy does not pass real bar timestamps into OB/FVG/AMD/Sweep detectors; these detectors fall back to synthetic timestamps. Any time-based logic (e.g., FVG expiry/time decay, AMD phase start time) becomes decoupled from market time.
- Location: Strategy `_calculate_confluence`; detectors’ `timestamps is None` branches.

H2. Backtest config wiring likely omits `mtf_bar_type` and `htf_bar_type`, leading to LTF-only operation despite HTF/MTF gating and architecture claims.
- Location: `/home/franco/projetos/EA_SCALPER_XAUUSD/nautilus_gold_scalper/scripts/backtest/run_backtest.py`.

**MEDIUM (warmup alignment / gating coherence)**
M1. Warmup conditions are not harmonized across components, causing early-run windows where:
- `_check_for_signal()` executes with minimum thresholds, but HTF bias/MTF zones/MTF alignment not yet available.
- This can lead to prolonged “blocked by HTF ranging” or confluence missing higher-timeframe factors.

M2. Two MTF managers exist (`src/indicators/mtf_manager.py` and `src/signals/mtf_manager.py`). Strategy imports the signals version. Risk of developer confusion / wrong import in future integrations.

### Validation Checklist (for Orchestrator / Follow-up)
- Confirm whether live/backtest configs actually set `htf_bar_type` and `mtf_bar_type` for this strategy.
- Confirm whether confluence scoring expects OB/FVG inputs to be MTF-only, or mixed-timeframe by design.
- Confirm whether time-based detector behavior is relied upon in scoring (FVG expiry, AMD cycle timestamps). If yes, passing real timestamps is required for temporal realism.

### Minimal Data-Flow Diagram (text)
`Bar(HTF) → BaseGoldStrategy.on_bar → _htf_bars → GoldScalperStrategy._on_htf_bar → (StructureAnalyzer → _htf_bias) + (RegimeDetector → _current_regime)`

`Bar(MTF) → BaseGoldStrategy.on_bar → _mtf_bars → GoldScalperStrategy._on_mtf_bar → (OBDetector/FVGDetector) → _mtf_order_blocks/_mtf_fvgs`

`Bar(LTF) → BaseGoldStrategy.on_bar → _ltf_bars → GoldScalperStrategy._on_ltf_bar → _check_for_signal → _calculate_confluence → {StructureAnalyzer, FootprintAnalyzer, LiquiditySweepDetector, AMDCycleTracker, signals.MTFManager} → ConfluenceScorer → signal/score`

