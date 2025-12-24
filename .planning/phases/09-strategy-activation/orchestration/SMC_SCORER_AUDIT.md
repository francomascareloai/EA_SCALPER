# SMC_SCORER_AUDIT

## Purpose

Audit the **ConfluenceScorer** (signal scoring layer) for:
- Temporal integrity (no look-ahead / no future-bar dependency)
- Correctness of score construction (weights, multipliers, thresholds)
- Caller contracts (completed bars vs forming bars; indicator inputs assumptions)
- Known gaps / deferred improvements

Scope: **scoring module only** (not strategy edge validation). Statistical validation is covered in `SMC_BACKTEST_RESULTS.md`.

## Scope (Phase 02 plan)

- File under audit: `nautilus_gold_scalper/src/signals/confluence_scorer.py`
- Related constants/types:
  - `nautilus_gold_scalper/src/core/definitions.py` (tiers, weights, bonuses)
  - `nautilus_gold_scalper/src/core/data_types.py` (`ConfluenceResult` fields)

## What the scorer does

`ConfluenceScorer.calculate_score(...)` computes a 0–100 **confluence score** and a discrete quality tier:
- S (90–100), A (80–89), B (70–79), C (60–69), Invalid (<60)
  - Evidence: tier comments in `nautilus_gold_scalper/src/signals/confluence_scorer.py:5-11`
  - Evidence: tier thresholds in `nautilus_gold_scalper/src/core/definitions.py:244-248`

It combines component scores, then applies:
- Session-specific weight profile (weights sum to 1.0 per session)
  - Evidence: `SessionWeightProfile` in `nautilus_gold_scalper/src/signals/confluence_scorer.py:112-200`
- Adjustments and confluence bonuses
  - Evidence: `_calculate_total` in `nautilus_gold_scalper/src/signals/confluence_scorer.py:932-1055`
- Multipliers (alignment, freshness, divergence)
  - Evidence: `_calculate_alignment_multiplier` at `nautilus_gold_scalper/src/signals/confluence_scorer.py:377-416`
  - Evidence: `_calculate_freshness_multiplier` at `nautilus_gold_scalper/src/signals/confluence_scorer.py:417-464`
  - Evidence: `_calculate_divergence_multiplier` at `nautilus_gold_scalper/src/signals/confluence_scorer.py:465-495`
- ICT 7-step sequence bonus/penalty
  - Evidence: `SequenceValidator.validate_sequence` at `nautilus_gold_scalper/src/signals/confluence_scorer.py:202-299`

Output object:
- `ConfluenceResult` (direction, total_score, per-component scores, counters, diagnosis)
  - Evidence: `nautilus_gold_scalper/src/core/data_types.py:260-309`

## Components (“factors”) actually used in code

The Phase 02 plan lists “9 factors”, but the current implementation uses the following *distinct contributors*:

1) **Structure** (bias + last break + premium/discount alignment)
- Evidence: `_score_structure` in `nautilus_gold_scalper/src/signals/confluence_scorer.py:617-657`

2) **Regime** (prime/noisy trending/reverting, random-walk penalty)
- Evidence: `_score_regime` in `nautilus_gold_scalper/src/signals/confluence_scorer.py:658-686`
- Evidence: `PENALTY_RANDOM_WALK` in `nautilus_gold_scalper/src/core/definitions.py:263-265`

3) **Session** (quality + allowed/block logic)
- Evidence: `_score_session` in `nautilus_gold_scalper/src/signals/confluence_scorer.py:687-719`

4) **Order Block proximity + alignment**
- Evidence: `_score_order_blocks` in `nautilus_gold_scalper/src/signals/confluence_scorer.py:720-765`

5) **FVG proximity + alignment**
- Evidence: `_score_fvgs` in `nautilus_gold_scalper/src/signals/confluence_scorer.py:765-809`

6) **Fibonacci confluence** (golden pocket + overlap bonus)
- Evidence: `_score_fibonacci` in `nautilus_gold_scalper/src/signals/confluence_scorer.py:884-931`

7) **Liquidity sweep** (confirmed sweep opposite to direction = reversal confluence)
- Evidence: `_score_sweeps` in `nautilus_gold_scalper/src/signals/confluence_scorer.py:810-846`

8) **AMD cycle** (distribution phase + confidence bonus)
- Evidence: `_score_amd` in `nautilus_gold_scalper/src/signals/confluence_scorer.py:847-883`

9) **MTF score + alignment bonus** (score is passed in already normalized)
- Evidence: `calculate_score` sets MTF component at `nautilus_gold_scalper/src/signals/confluence_scorer.py:558-566`

10) **Footprint score + alignment bonus** (score is passed in already normalized)
- Evidence: `calculate_score` footprint handling at `nautilus_gold_scalper/src/signals/confluence_scorer.py:567-576`

11) **Premium/Discount zone weight** (tracked as a separate weighted term named `zone`)
- Evidence: premium/discount score tracked in `nautilus_gold_scalper/src/signals/confluence_scorer.py:644-649`
- Evidence: applied as `zone` in `_calculate_total` at `nautilus_gold_scalper/src/signals/confluence_scorer.py:958-959`

Note: #11 is derived from structure state (not independent), but it is explicitly weighted as its own term.

## Weighting and thresholds

### Per-component caps (0–100 scale)
Default caps come from `core.definitions`:
- `WEIGHT_STRUCTURE = 15`
- `WEIGHT_REGIME = 10`
- `WEIGHT_ORDER_BLOCK = 15`
- `WEIGHT_FVG = 10`
- `WEIGHT_LIQUIDITY_SWEEP = 12`
- `WEIGHT_AMD_CYCLE = 10`
- `WEIGHT_FIB = 10`
- `WEIGHT_MTF = 15`
- `WEIGHT_FOOTPRINT = 10`
  - Evidence: `nautilus_gold_scalper/src/core/definitions.py:250-260`

### Session-specific mixing
`SessionWeightProfile.get_weights(...)` selects a dict of weights by session:
- ASIAN / LONDON / NY_OVERLAP / NY / DEFAULT
- Each profile contains 10 keys (`structure`, `regime`, `sweep`, `ob`, `fvg`, `zone`, `amd`, `mtf`, `footprint`, `fib`).
- Verified: each profile sums to **1.0**.
  - Evidence: definitions at `nautilus_gold_scalper/src/signals/confluence_scorer.py:118-185`
  - Evidence: fixed NY_OVERLAP sum bug comment at `nautilus_gold_scalper/src/signals/confluence_scorer.py:147-157`

### Total score construction
In `_calculate_total`, weighted component terms are summed, session_score is added, then adjustments/bonuses/multipliers are applied:
- Evidence: base score + adjustments at `nautilus_gold_scalper/src/signals/confluence_scorer.py:949-984`
- Evidence: multipliers application at `nautilus_gold_scalper/src/signals/confluence_scorer.py:985-992`
- Evidence: score scale factor `SCORE_SCALE_FACTOR = 5.0` at `nautilus_gold_scalper/src/signals/confluence_scorer.py:1026-1027`

### Trade/no-trade gating
- Default `min_score_to_trade` is `TIER_INVALID` (60)
  - Evidence: constructor default at `nautilus_gold_scalper/src/signals/confluence_scorer.py:336-372`
  - Evidence: tier invalid constant at `nautilus_gold_scalper/src/core/definitions.py:244-248`
- Final validation forces INVALID when:
  - session filter blocks
  - regime is random walk
  - score < min_score_to_trade
  - Evidence: `_validate_result` at `nautilus_gold_scalper/src/signals/confluence_scorer.py:1071-1096`

## Temporal integrity (look-ahead / causality)

**Verdict:** PASS (scorer layer is causal if inputs are causal)

- No forward indexing or future-bar scanning exists in the scorer itself.
- All decisions are based on:
  - passed-in *current_price*,
  - current structure/regime/session objects,
  - lists of OB/FVG/Sweeps already detected,
  - already-normalized MTF/Footprint scores.

**Critical integration contract:**
- The scorer can be *made non-causal* if the caller passes **forming-bar values** (e.g., live tick mid-bar close) while OB/FVG/swing/structure detections are built on completed bars.
- To preserve causality: call from completed-bar events and ensure `current_price` is the completed bar close (or an explicitly chosen basis, consistently across all inputs).

## Notable fixes already present in code (as evidence of previous audit work)

These are important because they directly affect “always-true” logic and score scaling:

- **MTF and Footprint double-scaling removal**
  - MTF/Footprint scores are treated as already 0–100 normalized and are not scaled by weight/100 at ingestion.
  - Evidence: `nautilus_gold_scalper/src/signals/confluence_scorer.py:558-569`

- **Session weights multiplier inflation removed**
  - Removed `* 100` multiplier in weighted scores to prevent score inflation.
  - Evidence: `nautilus_gold_scalper/src/signals/confluence_scorer.py:949-964`

- **`at_poi` correctness fix (price proximity required)**
  - `at_poi` now checks whether price is actually inside an active OB or FVG zone.
  - Evidence: `nautilus_gold_scalper/src/signals/confluence_scorer.py:995-1005`

## Known gaps / risks

1) **“9 factors” naming mismatch (documentation drift)**
- The plan enumerates 9 factors, but the implementation has additional explicit contributors (fib, zone, mtf, footprint, and session_score added separately).
- This is not necessarily wrong, but it complicates analysis of factor correlation and calibration.

2) **Premium/Discount component not exposed in `ConfluenceResult`**
- `ConfluenceResult` has a `premium_discount: float` field (`nautilus_gold_scalper/src/core/data_types.py:277-282`), but the scorer writes into its internal `premium_discount_score` and never assigns `result.premium_discount`.
- Impact: diagnostics/transparency gap (score still includes `zone` term).
  - Evidence: premium/discount score set at `nautilus_gold_scalper/src/signals/confluence_scorer.py:644-649`
  - Evidence: no assignment found for `result.premium_discount` in this module.

3) **Cross-run state accumulation**
- `_factor_counters.bars_analyzed` increments per call and is never reset unless a new scorer instance is created.
- If the same scorer instance is reused across folds/runs, factor frequency statistics can leak across segments.
  - Evidence: increment at `nautilus_gold_scalper/src/signals/confluence_scorer.py:520-521`

4) **Caller contract: `current_price` must be valid**
- OB/FVG scoring requires `current_price > 0` and returns early otherwise.
  - Evidence: OB price validation at `nautilus_gold_scalper/src/signals/confluence_scorer.py:732-735`
  - Evidence: FVG price validation at `nautilus_gold_scalper/src/signals/confluence_scorer.py:777-780`

## Verdict (Scoring layer)

- **Temporal integrity objective:** PASS (no look-ahead in scorer code).
- **Correctness objective (scoring math):** PASS at implementation level (weights sum to 1, gating/penalties explicit).
- **Edge objective:** NOT PROVEN here (requires backtest stats + enough trades; see `SMC_BACKTEST_RESULTS.md`).
