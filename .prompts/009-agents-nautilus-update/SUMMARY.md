# 🔧 AGENTS.md Nautilus Update Summary

**One-liner:** Updated AGENTS.md v3.4 → v3.4.1 to prioritize NautilusTrader (Python) over MQL5, marking MQL5 as LEGACY

**Status Update (2025-12-11):** AGENTS.md evolved significantly beyond initial scope → v3.7.0 (current)

## Version
v2.0 - SAFE (fixes 15 critical issues from v1.0)
AGENTS.md: v3.4.0 → v3.7.0 (atual)

### Evolution History
- v3.4.0 → v3.4.1: Nautilus prioritization (original prompt)
- v3.4.1 → v3.5.0: 68% token reduction + optimizations
- v3.5.0 → v3.6.0: 7 security gaps fixed
- v3.6.0 → v3.7.0: Multi-tier DD protection system (5% Apex trailing)

## Objective
Add dual-platform support to AGENTS.md: Nautilus (Python) as PRIMARY for current development, MQL5 as SECONDARY (still important for future). ADDITIVE approach - no deletions, no deprecation.

## V2.0 Improvements (vs V1.0)
✅ Pre-execution verification gates (migration status, dependencies, backup)
✅ Incremental XML validation (after each edit)
✅ MQL5 NOT marked as legacy (remains important)
✅ Granular git commits (7 commits for easy rollback)
✅ Post-execution smoke tests (verify both platforms work)
✅ Clear rollback procedure (backup + git revert)
✅ Realistic time estimate (1.5h vs V1.0's unrealistic 15-20min)
✅ Additive only (no breaking changes)

## Expected Changes (Additive)
• NEW: `<platform_support>` section (Nautilus PRIMARY, MQL5 SECONDARY)
• ADDED: Dual bugfix logs (nautilus_log + mql5_log, both active)
• EXPANDED: FORGE validation (Python: mypy + pytest, MQL5: metaeditor64)
• ADDED: 2 NEW error recovery protocols (Python/Nautilus) - MQL5 protocols KEPT
• UPDATED: FORGE metadata (supports both platforms)
• ADDED: Nautilus examples (MQL5 examples KEPT)

## Files Modified
- `AGENTS.md` (in-place edits)
- `AGENTS_v3.4_BACKUP_PRE_NAUTILUS_UPDATE.md` (backup created)

## Decisions Needed
None - changes align with project's NautilusTrader migration

## Blockers
None

## Next Step
Execute 010-droid-refactoring-master.md (FASE 2-4: refactor TOP 5 droids with inheritance)

## Estimated Time
1h 30min (realistic, with pre-execution gates, incremental validation, and smoke tests)

## Intelligence Required
- **Sequential-thinking** (7+ thoughts) to ensure MQL5 knowledge preserved as legacy (not deleted)
- **Proactive problem detection** to verify no breaking changes for existing droid invocations
