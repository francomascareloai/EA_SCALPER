# Phase 02 Round 1: Indicators Audit Summary (Checkpoint)

**Date:** 2025-12-18
**Scope:** Phase 02 Round 1 indicator set (A/B/C)

## Outcome
- **Round 1 COMPLETE but BLOCKED** due to **CRITICAL look-ahead bias** reported in:
  - `nautilus_gold_scalper/src/indicators/order_block_detector.py`
  - `nautilus_gold_scalper/src/indicators/fvg_detector.py`

## What Was Reviewed
- **Agent A (COMPLETE):** `amd_cycle_tracker.py`, `regime_detector.py`, `session_filter.py`, `footprint_analyzer.py`
- **Agent B (BLOCKING):** `order_block_detector.py`, `fvg_detector.py`
- **Agent C (COMPLETE):** `liquidity_sweep.py`, `structure_analyzer.py`

Full findings:
- `.planning/phases/08-nautilus-deep-audit/orchestration/PHASE_02_R1_A_FINDINGS.md`
- `.planning/phases/08-nautilus-deep-audit/orchestration/PHASE_02_R1_B_FINDINGS.md`
- `.planning/phases/08-nautilus-deep-audit/orchestration/PHASE_02_R1_C_FINDINGS.md`

## Key Findings (Condensed)

### Blocking (CRITICAL)
- **C-001 (OB):** OrderBlockDetector uses **future bar indices** (`index+1..index+5`) to confirm displacement/validity. This is **look-ahead** unless semantics are explicitly “confirm later / delay signal”.
- **C-002 (FVG):** FVGDetector accesses `index+1` (future bar) for 3-candle FVG definition. This is **look-ahead** unless index semantics are “confirmation candle” (signal delayed by 1 bar).

### High Priority (HIGH)
- **H-001:** Widespread reliance on “caller provides completed bars only” (`[-1]` usage) with no hard enforcement.
- **H-002:** Missing unit tests (notably for Liquidity/Structure set; broader indicator suite also lacks dedicated temporal tests).
- **H-003:** Internal vs external liquidity/structure distinction not explicit in Liquidity/Structure indicators.
- **H-004:** Breaker blocks mentioned but not implemented in OB detector.
- **H-005:** IFVG not implemented in FVG detector.
- **H-006:** SessionFilter late-hours fallback may misclassify session.

### Medium/Low (Selected)
- **M-003/M-004 (from R0):** MTFManager does not verify HTF bar completion; EMA path may be borderline performance (profiling needed).
- Multiple “confirmation lag” patterns exist (e.g., swing strength requiring bars on both sides). These are acceptable only if strategy accounts for lag explicitly.

## Verification
- `pytest -q` passes in `.venv`.
- `mypy --strict` passes for the 8 Phase 02 R1 indicator files.

## Decision
- Treat **OB/FVG temporal integrity as BLOCKING** until we reconcile semantics:
  - Either refactor detectors to avoid future indexing, or
  - Formalize “confirmation lag” by shifting index semantics and ensuring the strategy consumes signals only after confirmation bars.

## Next Steps (Audit Flow)
- **Do not proceed to Phase 02 R2** until OB/FVG temporal design is resolved.
- Proceed with **Phase 01 Core Strategy Audit** in parallel if desired, with explicit focus on:
  - How bars are passed into indicators (completed vs forming)
  - Whether strategy already delays signals / uses `on_bar` close
  - Any existing protections against look-ahead.

---
*Phase: 08-nautilus-deep-audit*
