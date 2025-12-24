# Phase 00-C: Portfolio Strategy Review Summary

**Code analysis confirms single SMC_SCALPER (no redundancy), locked falsification test thresholds for Ghost/Shifted/MC95DD validation gates**

## Accomplishments
- Audited codebase: confirmed NO separate "SCALPER" exists - only SMC_SCALPER (consolidation already done)
- Mapped regime-to-strategy routing: Hurst>0.55→TREND_FOLLOW, Hurst<0.40→MEAN_REVERT, else→SMC_SCALPER
- Documented 9-factor confluence scoring system (structure, regime, session, OB, FVG, sweep, AMD, fib, MTF, footprint)
- Locked falsification test designs with concrete pass/fail thresholds

## Files Created/Modified
- `.planning/phases/09-strategy-activation/orchestration/PHASE_00C_PORTFOLIO_REVIEW.md` - Updated with code analysis findings, locked decisions, falsification test implementations
- `.planning/phases/09-strategy-activation/11-PHASE-00C-SUMMARY.md` - This summary file

## Decisions Made
| Decision | Status | Rationale |
|----------|--------|-----------|
| D1: SMC_SCALPER + SCALPER | ALREADY CONSOLIDATED | Code analysis shows only SMC_SCALPER exists - no separate SCALPER |
| D2: Volatility/VWAP additions | DEFER | Pending Ghost Test + survival metrics |
| D3: Mean Reversion | VALIDATE FIRST | Pending Phase 04 + Phase 06 metrics |
| D4: Apex/HWM hardening | NON-NEGOTIABLE | De-risk in profit + time-based exits mandatory |

## Deviations from Plan
None - plan executed exactly as written

## Issues Encountered
None - original consolidation question was moot since codebase already has single implementation

## Falsification Test Thresholds Locked

### T1: Ghost Test (Null Signal)
- **Pass:** ΔSharpe > 0.3, ΔWinRate > 10% (p < 0.05) → signals ADD edge
- **Fail:** ΔSharpe < 0.2, ΔWinRate < 5% → signals NOT edge → simplify

### T2: Shifted Levels (OB/FVG precision)
- **Pass:** Exact > Shifted by >10% (p < 0.05) → precision MATTERS
- **Fail:** Δ < 5% → precision ILLUSION → use zones

### T3: Apex HWM Survival (Monte Carlo)
- MC95DD < 4.0% (buffer before 5% Apex limit)
- MC99DD < 4.5%
- Survival Rate > 95% across 1000 paths
- Max Single Path DD < 5.0%

## Next Phase Readiness
- Phase 00-C analysis complete - no code changes needed
- Ready to proceed with Phase 04+ with locked decisions
- Falsification tests (T1/T2/T3) should be run before implementing new strategies

---
*Phase: 00-C (retrofit)*
*Completed: 2025-12-24*
