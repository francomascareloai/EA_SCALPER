# Nautilus Plan Audit - Summary

## One-Liner
Migration is **87.5% functionally complete** (35/40 modules with 16,542 lines), NOT 100% as documented; 4 critical bugs (#2, #4) from ORACLE remain unfixed in strategy code; NinjaTrader adapter is stub; MTF Manager has duplicate implementations.

## Version
v1 - Initial audit (2025-12-07)

## Key Findings
• **35/40 modules VERIFIED** as fully functional (200-990 lines each) with complete implementations
• **5/40 modules STUB/INCOMPLETE**: ninjatrader_adapter (42L), mt5_adapter (44L), MTF Manager duplicate, 2 minor gaps
• **4 ORACLE validation bugs documented** but ONLY 2 addressed: Bug #2 (threshold 65 vs 70) and Bug #4 (unused config) remain UNFIXED in gold_scalper_strategy.py and confluence_scorer.py
• **16,542 actual lines migrated** vs. 12,000+ documented (38% understatement - overdelivery but inaccurate docs)
• **Apex risk management** mentions trailing DD but needs validation testing with demo account
• **MTF Manager DUPLICATION**: implemented in BOTH indicators/ (670L) and signals/ (395L) - consolidation needed
• **GENIUS v4.2 features fully migrated** to confluence_scorer.py (991 lines)
• **Plan reorganization recommended**: 9,567 lines too verbose, needs executive summary structure

## Critical Issues Found

### P0 Blockers (Production-Critical)
1. **Bug #2 NOT FIXED**: gold_scalper_strategy.py line 67 has `execution_threshold=65` but should be 70 to match MQL5 (accepts TIER-C signals incorrectly)
2. **Bug #4 NOT FIXED**: confluence_scorer.py doesn't enforce `confluence_min_score` config variable (defined but never used)
3. **NinjaTrader adapter STUB**: 42 lines only, needs full implementation to connect to primary platform

### P1 Gaps (Core Functionality)
4. **Apex trailing DD validation**: prop_firm_manager.py (170L) mentions Apex but 10% HWM trailing logic needs testing
5. **MTF Manager duplication**: Two implementations (indicators/670L vs signals/395L) - which is correct?
6. **Regime detector VR bug**: ORACLE mentioned edge case in variance ratio calculation

### P2 Issues (Technical Debt)
7. **MT5 adapter stub**: 44 lines (optional backup broker)
8. **News calendar 2026+ events**: TODO to add future FOMC/NFP dates

## Decisions Needed
- **Should execution_threshold be 65 or 70?** (Evidence: MQL5 uses 70, ORACLE says 70, but Python has 65)
- **Which MTF Manager implementation to keep?** (indicators/670L vs signals/395L - need to audit both)
- **Keep or delete apex_adapter.py from _archive/?** (1,433 lines preserved - reference value?)
- **What is true completion percentage?** (100% if "files exist", 87.5% if "fully functional")

## Blockers
- **Apex demo account access** needed to validate trailing DD/consistency rules implementation
- **NinjaTrader 8 with API** needed to implement and test ninjatrader_adapter.py
- **Branch visibility** - audit assumes main branch is current; fixes may exist in other branches

## Next Step
**IMMEDIATE:** Fix ORACLE Bug #2 & #4 in Python strategy code (gold_scalper_strategy.py threshold 65→70, confluence_scorer.py enforce config), then re-run backtests to validate win rate improves (1-2 hours, FORGE owner, no blockers)
