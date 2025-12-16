# BRIEF: Deep Audit - Nautilus Strategies & Infrastructure

## Objective
Comprehensive critical analysis of ALL NautilusTrader strategies, indicators, risk modules, and scripts to identify bugs, design flaws, overfitting risks, Apex compliance gaps, and improvement opportunities.

## Scope

### In-Scope
- **Core Strategies**: `nautilus_gold_scalper/src/strategies/` (~1,400 lines)
- **Indicators SMC**: `nautilus_gold_scalper/src/indicators/` (~4,100 lines)
- **Risk Modules**: `nautilus_gold_scalper/src/risk/` (~2,989 lines)
- **Signal Generators**: `nautilus_gold_scalper/src/signals/` (~3,450 lines)
- **Execution Layer**: `nautilus_gold_scalper/src/execution/` (~908 lines)
- **Backtest Scripts**: `scripts/backtest/` (~50+ files)
- **Backtest Strategies**: `scripts/backtest/strategies/` (~5,322 lines)
- **Unit Tests**: `nautilus_gold_scalper/tests/` (all)

### Out-of-Scope
- MQL5 code (separate audit)
- Legacy scripts in `scripts/legacy/`
- Data conversion scripts (unless affecting backtests)

## Estimated Total Lines: ~18,000+

## Success Criteria
1. **Every component reviewed** with CRITIC protocol
2. **All bugs documented** with severity (CRITICAL/HIGH/MEDIUM/LOW)
3. **Apex compliance verified** for every trading-related module
4. **Temporal correctness confirmed** (no look-ahead bias)
5. **Performance budget checked** (<1ms on_bar, <100µs on_tick)
6. **Improvement recommendations** prioritized by impact/effort

## Deliverables
1. `AUDIT_REPORT.md` - Master findings document
2. `ISSUES_TRACKER.md` - Bug/issue tracker with status
3. `RECOMMENDATIONS.md` - Prioritized improvements
4. Per-phase detailed reports in phase subdirectories

## Constraints
- CRITIC self-review mandatory at each phase
- Use sequential-thinking (12-15 thoughts) for each module
- Document assumptions explicitly
- Parallel agent execution allowed (user confirmed resources)

## Owner
Franco

## Status
DRAFT - Pending approval
