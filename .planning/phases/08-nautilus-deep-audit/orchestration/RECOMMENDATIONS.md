# Prioritized Recommendations (Phase 09)

## Immediate (Blocks Live/Paper Trading)
1) Make execution fail-safe under all broker outcomes (Phase 08-C, Phase 05).
   - Ensure protective SL/TP are confirmed; on reject/failure -> emergency close + halt.
   - Implement an order-event lifecycle (ack/fill/reject/cancel/expire) so the strategy cannot hold “naked” exposure.
2) Guarantee Apex flattening independent of market events (Phase 08-D, Phase 03 R2).
   - Add wall-clock/scheduler-driven enforcement for 16:55 emergency close and 16:59 hard flat even if feed stalls.
3) Enforce forced-flatten on DD safety-breach while in-position (Phase 08-A).
   - Unify DD thresholds/enforcement across PropFirm/DDProtection/DrawdownTracker/CircuitBreaker and couple breach -> flatten.
4) Remove confirmed look-ahead leakage from evaluation scripts (Phase 06).
   - Enforce “as-of” slicing for HTF/MTF inputs; add negative tests that fail with one future bar.
   - Label any non-Apex scripts explicitly and prevent them from producing Apex-labeled metrics.
5) Raise coverage to minimums with focus on strategy orchestration paths (Phase 07).
   - Add deterministic tests for time gates, DD breach flattening, bracket failure handling, and detector timestamp wiring.

## Near-Term (Required Before Trusting Backtest/Optimization Results)
1) Fix scoring correctness and determinism issues (Phase 04).
   - Correct ICT sequence `at_poi` and add regression tests.
   - Remove wall-clock time usage from EntryOptimizer expiry; use market/bar time.
2) Resolve indicator↔strategy integration realism gaps (Phase 08-B).
   - Stop overwriting MTF zone state with LTF detections; preserve timeframe semantics.
   - Pass real timestamps into time-aware detectors (OB/FVG/AMD/Sweep) to avoid synthetic timelines.

## Conditional (Only If ML Will Be Used)
1) Fix ML cross-validation leakage and enforce train/inference parity (Phase 04.5).
   - Replace KFold stacking with time-series-safe CV; persist scaler + feature order metadata.

## Conflicts / Follow-ups
- [CONFLICT] Time-gate enforcement: see `PHASE_03_B_APEX_FINDINGS.md` vs `PHASE_03_R2_FOLLOWUP_FINDINGS.md`. Treat R2 as latest for presence/wiring, but Phase 08/03R2 still require scheduler independence under feed stalls.
