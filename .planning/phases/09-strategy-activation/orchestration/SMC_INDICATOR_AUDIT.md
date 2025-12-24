# SMC_INDICATOR_AUDIT

## Purpose

Audit the core SMC indicator implementations for:
- Temporal integrity (no look-ahead / causal indexing)
- Caller contracts and data assumptions (completed bars vs forming bars)
- SMC correctness at a pragmatic level (definitions match intended concepts)
- Known gaps / deferred enhancements

This deliverable focuses on **indicator modules** only (not scoring/backtest validation).

## Scope (Phase 02 plan)

Indicators under audit:
- `nautilus_gold_scalper/src/indicators/order_block_detector.py`
- `nautilus_gold_scalper/src/indicators/fvg_detector.py`
- `nautilus_gold_scalper/src/indicators/liquidity_sweep.py`
- `nautilus_gold_scalper/src/indicators/structure_analyzer.py`
- `nautilus_gold_scalper/src/indicators/regime_detector.py`

## Method (what was checked)

Temporal integrity checks were validated via:
- Targeted scans for forward-looking patterns (`i+N`, negative shifts, full-sample stats)
- Manual inspection of index access patterns
- Unit/integration tests covering causal behavior where available

Key evidence sources (prior audit artifacts):
- `.planning/phases/08-nautilus-deep-audit/orchestration/PHASE_02_R1_B_FINDINGS.md` (OB/FVG look-ahead identification)
- `.planning/phases/08-nautilus-deep-audit/orchestration/PHASE_02_R1_C_FINDINGS.md` (liquidity/structure review)
- `.planning/phases/08-nautilus-deep-audit/orchestration/PHASE_02_R2_FOLLOWUP_FINDINGS.md` (closeout + fix verification)

## Findings by indicator

### 1) OrderBlockDetector (`order_block_detector.py`)

**Temporal integrity:** PASS (causal confirmation)
- Causal trailing average volume introduced (window excludes current candle), used for `volume_ratio`.
  - Evidence: `avg_volume` computed from a trailing window (not full-sample) at `nautilus_gold_scalper/src/indicators/order_block_detector.py:117-124`.
- Look-ahead displacement confirmation removed by using a **confirmation candle index** instead of scanning forward bars.
  - Evidence: `confirmation_index` is explicitly tracked and used to compute displacement at `nautilus_gold_scalper/src/indicators/order_block_detector.py:246-276` and `nautilus_gold_scalper/src/indicators/order_block_detector.py:369-387`.

**Caller contract:** still relevant
- The module can only be causal if the input arrays represent **completed bars**.
- `current_price` defaults are still a conceptual risk if a caller supplies a forming bar close (integration-layer responsibility).

**SMC completeness gaps (deferred):**
- “Breaker block” transformation is described in earlier audits as unimplemented (tracked as deferred; see `PHASE_02_R2_FOLLOWUP_FINDINGS.md`).

### 2) FVGDetector (`fvg_detector.py`)

**Temporal integrity:** PASS (3-candle causal definition)
- The detector uses a causal 3-candle FVG definition (no `index+1` forward boundary).
- Uses causal trailing average volume for volume-spike checks.
  - Evidence: trailing `avg_volume` window at `nautilus_gold_scalper/src/indicators/fvg_detector.py:109-116`.
  - Evidence: volume spike check uses `avg_volume` and current/previous candles only at `nautilus_gold_scalper/src/indicators/fvg_detector.py:349-366`.

**Caller contract:** still relevant
- Same constraint as all array-based indicators: the last bar in arrays must be complete.

**SMC completeness gaps (deferred):**
- IFVG (inverse FVG) not implemented (tracked as deferred; see `PHASE_02_R2_FOLLOWUP_FINDINGS.md`).

### 3) LiquiditySweepDetector (`liquidity_sweep.py`)

**Temporal integrity:** PASS (confirmation-lag pattern)
- Swing points are confirmed with a **delayed confirmation** pattern: candidate index `cand = i - strength`.
  - Evidence: documented and implemented at `nautilus_gold_scalper/src/indicators/liquidity_sweep.py:294-352`.
- This is not look-ahead; it intentionally creates lag and only emits swing points when enough bars exist.

**Caller contract:** still relevant
- Requires completed bars arrays.

**Known gaps (deferred):**
- Internal vs external liquidity distinction is not explicitly modeled (tracked as deferred; see `PHASE_02_R2_FOLLOWUP_FINDINGS.md`).

### 4) StructureAnalyzer (`structure_analyzer.py`)

**Temporal integrity:** PASS (confirmation-lag + close validation)
- Uses swing confirmation lag (same concept as liquidity sweeps).
- BOS/CHoCH break detection uses a break buffer and validates with bar closes.
  - Evidence: `break_buffer` logic at `nautilus_gold_scalper/src/indicators/structure_analyzer.py:379-429`.

**Caller contract risk:** medium
- If a caller mixes tick-level `current_price` with bar-level `closes[-1]`, temporal consistency becomes ambiguous.
- In strategy usage this should be aligned to completed-bar events (`on_bar`), but this is an integration requirement.

**Known gaps (deferred):**
- Internal vs external structure distinction not explicitly modeled (tracked as deferred).

### 5) RegimeDetector (`regime_detector.py`)

**Temporal integrity:** PASS (trailing windows only)
- Uses trailing slices for Hurst/Entropy/VR (no forward access).
- A `reset()` method exists to avoid cross-run leakage between segments/folds.
  - Evidence: `nautilus_gold_scalper/src/indicators/regime_detector.py:73-76`.

**Thresholds:**
- Trending boundary currently uses `HURST_TRENDING_MIN = 0.56` and mean-reverting uses `HURST_REVERTING_MAX = 0.45`.
  - Evidence: `nautilus_gold_scalper/src/indicators/regime_detector.py:44-45`.

## Test coverage evidence (indicator-focused)

- Unit tests for SMC detectors exist (including causal OB/FVG verification):
  - `nautilus_gold_scalper/tests/test_indicators/test_smc_detectors.py` (referenced in `.planning/phases/08-nautilus-deep-audit/orchestration/PHASE_02_R2_FOLLOWUP_FINDINGS.md`).

## Open risks / follow-ups

These are not Phase 02 temporal blockers, but must remain visible:
- **Integration contract (completed bars):** array-based indicators cannot prove the last bar is complete. This must be enforced/verified at integration boundary (owner: Phase 08).
- **SMC completeness:** internal vs external structure/liquidity, breaker blocks, IFVG (owner: Phase 04/08 depending on design).
- **Performance profiling:** any O(n²) scans with high lookback need profiling under realistic call frequency (owner: perf pass).

## Verdict (Indicator layer)

- **Temporal integrity objective:** PASS (no look-ahead in indicator implementations as currently written).
- **SMC edge objective:** NOT PROVEN here (requires backtest stats + enough trades).
