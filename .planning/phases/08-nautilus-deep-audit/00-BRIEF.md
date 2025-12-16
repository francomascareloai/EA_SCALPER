# BRIEF: Deep Audit - Nautilus Strategies & Infrastructure

## Objective
Comprehensive critical analysis of ALL NautilusTrader strategies, indicators, risk modules, and scripts to identify bugs, design flaws, overfitting risks, Apex compliance gaps, and improvement opportunities.

## Scope

### In-Scope

#### Foundation (CRITICAL - Phase 00)
- **Core Definitions**: `nautilus_gold_scalper/src/core/` (~300 lines)
  - `definitions.py` - Thresholds, constants, Apex rules
  - `data_types.py` - Data structures
  - `exceptions.py` - Custom exceptions

#### Main Modules (Phases 01-05)
- **Core Strategies**: `nautilus_gold_scalper/src/strategies/` (~1,400 lines)
- **Indicators SMC**: `nautilus_gold_scalper/src/indicators/` (~4,100 lines)
- **Risk Modules**: `nautilus_gold_scalper/src/risk/` (~2,989 lines)
- **Signal Generators**: `nautilus_gold_scalper/src/signals/` (~3,450 lines)
- **Execution Layer**: `nautilus_gold_scalper/src/execution/` (~908 lines)

#### ML Pipeline (Phase 04.5)
- **ML Modules**: `nautilus_gold_scalper/src/ml/` (~500 lines)
  - `feature_engineering.py` - Feature extraction (LOOK-AHEAD RISK)
  - `ensemble_predictor.py` - Model inference
  - `model_trainer.py` - Training pipeline

#### Context & Utils
- **Context**: `nautilus_gold_scalper/src/context/` (~100 lines)
  - `holiday_detector.py` - Holiday detection
- **Utils**: `nautilus_gold_scalper/src/utils/` (~200 lines)
  - `metrics.py` - Performance metrics
  - `telemetry.py` - Telemetry

#### Backtest & Tests (Phases 06-07)
- **Backtest Scripts**: `scripts/backtest/` (~50+ files)
- **Backtest Strategies**: `scripts/backtest/strategies/` (~5,322 lines)
- **Unit Tests**: `nautilus_gold_scalper/tests/` (all)

### Out-of-Scope
- MQL5 code (separate audit)
- Legacy scripts in `scripts/legacy/`
- Data conversion scripts (unless affecting backtests)
- `src/execution/_archive/` (dead code, verify in Phase 00)

## Estimated Total Lines: ~20,000+

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
