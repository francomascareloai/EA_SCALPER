# Agent A - Signal Generators Audit Findings

## Summary
- Modules reviewed:
  - `nautilus_gold_scalper/src/signals/confluence_scorer.py`
  - `nautilus_gold_scalper/src/signals/entry_optimizer.py`
  - `nautilus_gold_scalper/src/signals/mtf_manager.py`
- Lines analyzed: ~2,096 (per Phase 04 plan)
- Issues found: CRITICAL: 2 | HIGH: 4 | MEDIUM: 7 | LOW: 3

---

`★ Insight ─────────────────────────────────────`
- In this codebase, the *strategy* (`gold_scalper_strategy.py`) sets the effective execution threshold (70), not `ConfluenceScorer`’s internal default (60). Audits must validate both to avoid “safe-by-convention” assumptions.
- The biggest scoring-risk here is *sequence bonus inflation*: a single boolean like `at_poi` can add +20, then get scaled (`SCORE_SCALE_FACTOR=5`) into a +100 swing before clamping.
- There are **two different MTF managers** (`src/signals/mtf_manager.py` vs `src/indicators/mtf_manager.py`). Current tests cover the indicator version, while the main strategy uses the signals version — that’s a coverage gap and a common source of false confidence.
`─────────────────────────────────────────────────`

---

## Module: `confluence_scorer.py`

### Overview
Central scoring aggregator producing a `ConfluenceResult` with a 0–100 `total_score`, factor breakdown, optional GENIUS multipliers (alignment/freshness/divergence), and an ICT “7-step sequential confirmation” bonus.

### Findings

| ID | Severity | Issue | Location | Recommendation |
|----|----------|-------|----------|----------------|
| P04-A-001 | **CRITICAL** | **ICT Step 5 (`at_poi`) is incorrectly computed as “any valid OB/FVG exists”, not “price is at POI”. This will systematically over-count sequence steps and add +5/+10/+20 sequence bonus, which is then amplified by `SCORE_SCALE_FACTOR=5.0`.** | `nautilus_gold_scalper/src/signals/confluence_scorer.py:904` | Compute `at_poi` using `current_price` and *active* OB/FVG proximity checks (e.g., `ob.low_price <= current_price <= ob.high_price` / `fvg.lower_level <= current_price <= fvg.upper_level`). Add a regression unit test for sequence steps. |
| P04-A-002 | **HIGH** | Alignment multiplier uses a hard threshold `score > 7.0` but the underlying component scores are **not** normalized 0–100 (they appear to be weight-capped values such as 10–15). This makes “strong factors” counting inconsistent with the docstring (“>70% of max weight”) and can mis-trigger 1.35x/0.60x. | `nautilus_gold_scalper/src/signals/confluence_scorer.py:348` | Make the “strong factor” test relative to each component’s max possible (e.g., `score > 0.7 * weight_component` or similar) and add a regression unit test validating the multiplier thresholds. |
| P04-A-003 | **MEDIUM** | Freshness multiplier uses OB “age” approximation `touch_count * 2` (comment notes “would need bar_index”). This can mis-rank OB freshness and distort scoring in both backtest and live. | `nautilus_gold_scalper/src/signals/confluence_scorer.py:401` | Add real bar-age tracking to OB/FVG objects (bar index or timestamp) and compute age deterministically. If not available, remove OB-based freshness contribution or downgrade its impact. |
| P04-A-004 | **MEDIUM** | `ConfluenceScorer.config` is `None` by default and no in-repo call site sets it, but `_calculate_total` tries to enforce `config.confluence_min_score`. This is likely dead/latent behavior and can confuse operators (“why didn’t min score apply?”). | `nautilus_gold_scalper/src/signals/confluence_scorer.py:325` | Either (a) explicitly set `self._confluence_scorer.config = self.config` in the strategy, or (b) remove this path and rely on `min_score_to_trade` + strategy thresholding. |
| P04-A-005 | **LOW** | `strong_aligned` comment says “>70% of max weight”, but the implementation is absolute (7.0) and counts components from `self._components` which are already weight-scaled and not session-weighted. Docstring / implementation mismatch increases audit risk. | `nautilus_gold_scalper/src/signals/confluence_scorer.py:361` | Align comment + implementation: document the actual scale at this point in the pipeline and reference weights. |
| P04-A-006 | **LOW** | `at_poi` uses `not ob.state.value >= 2` which relies on operator precedence and is harder to read/review. | `nautilus_gold_scalper/src/signals/confluence_scorer.py:905` | Replace with `ob.state.value < 2` for clarity and to reduce audit mistakes. |

### Checklist Results
- Thresholds match authoritative source (TIER S/A/B/C): ✅ Verified in `nautilus_gold_scalper/src/core/definitions.py:240`
- Score capping at 100: ✅ `result.total_score = max(0, min(100, scaled_score))`
- Negative score handling: ⚠️ Allowed pre-clamp; clamped to 0
- NaN/Inf edge cases: ⚠️ No explicit guard; relies on upstream producing finite scores
- Component weight transparency: ✅ `ScoringComponents` breakdown exists
- Unit tests exist: ⚠️ Partial coverage exists (e.g. `nautilus_gold_scalper/tests/test_indicators/test_fibonacci_levels.py`), but there are no focused tests for ICT sequence (`at_poi`), multipliers, or score inflation edge cases

### Look-Ahead Verification
- `ConfluenceScorer` itself does not index arrays/time; it uses provided objects.
- **Primary risk is causal correctness of input objects** (OB/FVG/sweeps). The scorer currently does not verify that inputs are “as-of time T”.
- **Observed correctness violation (sequence logic)**: `at_poi` is not time-related, but it is logically incorrect and functionally equivalent to a permanent “true” when any OB/FVG exists.

### Apex Compliance
- No direct time-gate or DD checks inside `ConfluenceScorer`.
- Effective “trade/no-trade” enforcement must occur in the strategy (`execution_threshold`, time manager, DD managers). This module can be reused incorrectly without those guards.

---

## Module: `entry_optimizer.py`

### Overview
Computes an `OptimalEntry` (FVG 50% fill, OB 70% retest, golden pocket retrace, otherwise market) with SL/TP ladder and an expiry window.

### Findings

| ID | Severity | Issue | Location | Recommendation |
|----|----------|-------|----------|----------------|
| P04-A-007 | **HIGH** | Entry expiry uses wall-clock `datetime.now(timezone.utc)` instead of market/bar time. In backtests (or replay), this breaks temporal correctness: setups may not expire as bars advance, or may expire unpredictably depending on runtime speed. | `nautilus_gold_scalper/src/signals/entry_optimizer.py:396` | Make expiry depend on bar index or current bar timestamp passed in from the strategy. Avoid wall-clock in simulation paths. |
| P04-A-008 | **HIGH** | `has_expired()` also uses wall-clock `datetime.now(timezone.utc)`, compounding the same issue. | `nautilus_gold_scalper/src/signals/entry_optimizer.py:634` | Same as above; use deterministic simulation time. |
| P04-A-009 | **MEDIUM** | `min_rr_ratio` and `target_rr_ratio` are stored but not enforced anywhere in `calculate_optimal_entry`. Low R:R entries are still marked `is_valid=True` even if below `min_rr_ratio`. | `nautilus_gold_scalper/src/signals/entry_optimizer.py:153` | Enforce `entry.risk_reward >= min_rr_ratio` (or mark invalid / downgrade quality) before returning. Add a unit test to prevent regressions. |
| P04-A-010 | **MEDIUM** | Spread penalty divides `risk_reward` by `spread_ratio`, but TP/SL prices remain unchanged. This makes `risk_reward` field inconsistent with actual levels used for execution (metric drift). | `nautilus_gold_scalper/src/signals/entry_optimizer.py:260` | If spread affects execution, apply it consistently: adjust expected entry price/SL/TP or explicitly label `risk_reward` as “effective_rr_estimate” with the assumptions. |
| P04-A-011 | **MEDIUM** | Market-entry fallback uses `default_sl_price` directly without spread/slippage buffer. In realistic execution (XAUUSD), spreads spike; this can produce under-protected SL for market entries. | `nautilus_gold_scalper/src/signals/entry_optimizer.py:378` | Ensure strategy-level execution model (slippage/spread) adjusts risk before sizing/placing orders. At minimum, document reliance on upstream execution costs. |
| P04-A-012 | **LOW** | `valid_until` assumes “15 min bars” regardless of actual LTF bar timeframe (comment: “15 min bars * max_wait_bars”). Entry system is used as M5 entry in docs; mismatch indicates drift. | `nautilus_gold_scalper/src/signals/entry_optimizer.py:394` | Tie validity window to the timeframe actually used by the entry module or pass timeframe minutes in. |

### Checklist Results
- Fibonacci integration: ✅ Golden pocket + optional fib targets supported
- Zone validation logic: ✅ Basic `has_fvg`/`has_ob` validation
- R:R calculation accuracy: ✅ `reward/risk` computed as absolute distances
- Spread cost included in R:R: ⚠️ Partial (only via `risk_reward /= spread_ratio`, levels unchanged)
- Slippage buffer in entry price: ❌ Not present at entry-optimizer level
- No look-ahead: ✅ Purely uses provided levels + current_price (but relies on upstream not providing future-derived zones)
- Time gate (4:30 PM ET): ❌ Not enforced here

### Look-Ahead Verification
- EntryOptimizer is stateless aside from `_current_entry`; it uses only passed parameters.
- Primary “look-ahead” risk is **timestamp misuse**: wall-clock expiry is not aligned to bar progression in backtests.

### Apex Compliance
- No explicit time gates; relies on strategy-level `TimeConstraintManager`.

---

## Module: `mtf_manager.py` (signals)

### Overview
Computes HTF/MTF/LTF structure/regime analyses and sets an `MTFState` with alignment + a 0–100 `mtf_score`. Uses `StructureAnalyzer` per timeframe and a `RegimeDetector` for the MTF.

### Findings

| ID | Severity | Issue | Location | Recommendation |
|----|----------|-------|----------|----------------|
| P04-A-013 | **HIGH** | MTF analysis has no timestamp/bar-close semantics. It accepts arrays + a single `current_price` and feeds that same `current_price` into **all** timeframe analyzers, including HTF. If `current_price` is the LTF tick/price while HTF bar is not closed, HTF premium/discount and structure computations can become non-causal (look-ahead / cross-time leakage). | `nautilus_gold_scalper/src/signals/mtf_manager.py:254` | Pass per-timeframe “as-of” price (e.g., last close of each timeframe) or ensure caller passes `current_price` consistent with the evaluated timeframe (HTF uses HTF close). Add explicit bar-close assertions in strategy. |
| P04-A-014 | **MEDIUM** | Strength scoring mixes “bias” (40/20) + `structure_score * 0.3` + BOS/CHoCH bonuses. Without knowing `structure_score` scale, this can dominate or underweight BOS/CHoCH. | `nautilus_gold_scalper/src/signals/mtf_manager.py:279` | Normalize `structure_score` scale or clamp its contribution to known range. Add tests verifying score ranges in typical scenarios. |
| P04-A-015 | **MEDIUM** | Alignment strength weights can sum to <1.0 depending on transitional MTF weight (0.25). This effectively reduces alignment_strength even when aligned, but no explicit normalization. | `nautilus_gold_scalper/src/signals/mtf_manager.py:338` | Either normalize weights to sum=1.0 or document that transitional MTF intentionally reduces absolute strength. |
| P04-A-016 | **CRITICAL** | **Test coverage mismatch:** repository tests reference `src.indicators.mtf_manager.MTFManager`, but the trading strategy uses `src.signals.mtf_manager.MTFManager`. This leaves the signals MTF logic untested, including temporal alignment concerns. | `nautilus_gold_scalper/tests/test_indicators/test_mtf_manager.py:10` (test) and `nautilus_gold_scalper/src/strategies/gold_scalper_strategy.py:470` (strategy uses signals MTF) | Add dedicated tests for `nautilus_gold_scalper/src/signals/mtf_manager.py` or refactor to a single authoritative MTF manager. |

### Checklist Results
- Temporal alignment verified: ❌ No timestamps; relies on caller discipline
- HTF confirmed before use: ❌ No “bar closed” checks
- Conflict resolution documented: ✅ HTF vs MTF opposite blocks entries
- Performance acceptable: ⚠️ Likely OK (numpy ops + analyzer calls) but not measured
- Bar buffer sufficient for lookback: ✅ Configurable lookbacks, basic length checks

### Look-Ahead Verification
- **Cannot be proven inside this module** due to missing timestamps.
- Requires an explicit trace in the strategy ensuring: `htf_bar.close_time <= ltf_bar.time` and similarly for mtf/ltf.

### Apex Compliance
- Only supports `session_ok` boolean gate (`analyze(..., session_ok=True)`), but does not enforce Apex time gates itself.

---

## Cross-Module Dependencies

1. **Execution threshold source-of-truth**
   - `ConfluenceScorer` default `min_score_to_trade` is `TIER_INVALID` (60) via `core.definitions` (but note: some tests override this to `0`).
   - The main strategy overrides it to `execution_threshold` (default 70) when constructing `ConfluenceScorer`.
   - Risk: any alternate caller that uses default scorer threshold will trade Tier-C setups unintentionally.

2. **MTF manager duplication**
   - `nautilus_gold_scalper/src/signals/mtf_manager.py` (structure-based, H1/M15/M5) is used by the strategy.
   - `nautilus_gold_scalper/src/indicators/mtf_manager.py` (EMA-based, H1/M15/M5/M1) is what tests currently cover.
   - Risk: passing tests do not validate the live path.

3. **Time gating and DD gating are upstream**
   - None of these three modules enforce Apex time gates or DD penalties directly.
   - Strategy integrates `TimeConstraintManager`, drawdown tracking, circuit breaker, spread monitor.
   - Risk: reusing modules in isolation (or mis-wiring in strategy) bypasses constraints.

---

## Recommendations (Prioritized)

1. **Fix `at_poi` sequence logic** (P04-A-001, CRITICAL)
   - Without this, sequence bonus is inflated and can flip NO-TRADE → TRADE.

2. **Add real tests for `src/signals/mtf_manager.py`** (P04-A-016, CRITICAL)
   - Current tests validate a different class.

3. **Remove wall-clock time from EntryOptimizer** (P04-A-007/008, HIGH)
   - Use deterministic simulation time inputs.

4. **Audit/normalize alignment multiplier scaling** (P04-A-002, HIGH)
   - Ensure “strong factors” threshold matches actual score scale.

5. **Decide single MTF implementation** (P04-A-016 + duplication risk)
   - Consolidate or explicitly document which is authoritative.
