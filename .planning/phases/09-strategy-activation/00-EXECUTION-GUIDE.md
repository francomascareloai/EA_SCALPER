# EXECUTION GUIDE: Phase 09 - Strategy Activation

**Document:** 00-EXECUTION-GUIDE.md
**Version:** 1.0
**Created:** 2025-12-23
**Master Plan:** 01-ROADMAP-FINAL.md (v2.0 ARGUS-Integrated)

---

## Quick Reference

```
OUTPUT FOLDER: .planning/phases/09-strategy-activation/
ORCHESTRATION: .planning/phases/09-strategy-activation/orchestration/
```

---

## Phase 00-A: BASELINE VALIDATION (2-4 hours)

### Prompt para Copiar e Colar

```
Execute Phase 00-A: BASELINE VALIDATION from Phase 09.

Context:
- Master plan: .planning/phases/09-strategy-activation/01-ROADMAP-FINAL.md
- This is a GO/NO-GO gate from DAEMON's recommendation
- Purpose: Validate SMC thesis before spending weeks on fixes

Tasks:
1. Create simple EMA 20/50 crossover baseline strategy
2. Run backtest on same period as current SMC (2024-01-01 to 2024-06-30)
3. Use same dataset: data/raw/full_parquet/xauusd_2003_2025_stride20_full.parquet
4. Apply same session filters and risk management as SMC
5. Compare metrics: Trades, Win Rate, PnL, Sharpe, Profit Factor

GO/NO-GO Decision:
- IF SMC < EMA (Sharpe/PF): STOP IMMEDIATELY
- IF SMC > EMA by < 20%: CAUTION - proceed with scrutiny
- IF SMC > EMA by >= 20%: PROCEED with FIX FIRST

Output:
- Save results to: .planning/phases/09-strategy-activation/orchestration/PHASE_00A_BASELINE_RESULTS.md

Agent: ORACLE (opus)
```

---

## Phase 00-B: CRITICAL BUG FIXES (1 week)

### Prompt para Copiar e Colar

```
Execute Phase 00-B: CRITICAL BUG FIXES from Phase 09.

Context:
- Master plan: .planning/phases/09-strategy-activation/01-ROADMAP-FINAL.md
- Prerequisite: Phase 00-A passed (SMC > EMA)

Tasks:
1. Fix semantic collision: Rename _mtf_order_blocks to explicit _htf/_mtf/_ltf variables
   - Files: gold_scalper_strategy.py, signals/mtf_manager.py, signals/confluence_scorer.py

2. Fix file paths: Add deprecation warning to legacy indicators/mtf_manager.py
   - Create tests for production signals/mtf_manager.py

3. Investigate trade clustering: All 7 trades Jan 2-10, ZERO after
   - Check state reset, memory leaks, MTF bar accumulation

4. Add diagnostic logging to confluence_scorer.py
   - Log all 9 factor scores on every evaluation

Validation:
- All 9 factors can score > 0
- mypy --strict passes
- pytest -q passes

Output:
- Save findings to: .planning/phases/09-strategy-activation/orchestration/PHASE_00B_BUGFIX_REPORT.md

Agent: FORGE (opus)
```

---

## Phase 01: DIAGNOSTIC & BASELINE (3 days)

### Prompt para Copiar e Colar

```
Execute Phase 01: DIAGNOSTIC & BASELINE from Phase 09.

Context:
- Master plan: .planning/phases/09-strategy-activation/01-ROADMAP-FINAL.md
- Detailed plan: .planning/phases/09-strategy-activation/02-PHASE-01-PLAN.md
- Prerequisite: Phase 00-B bugs fixed

Tasks:
1. Run FIXED system with all 9 factors at threshold=35
2. Threshold sensitivity analysis: 35, 30, 25, 20
3. Capture factor activation report (which factors fire, avg/max scores)
4. Compare to EMA baseline from Phase 00-A

GO/NO-GO:
- 50+ trades, 4+ factors → PROCEED to Phase 02
- 50+ trades, < 4 factors → PROCEED but flag for ablation
- < 50 trades → TRIGGER Plan B (Simplification)

Output:
- Save to: .planning/phases/09-strategy-activation/orchestration/PHASE_01_DIAGNOSTIC_RESULTS.md

Agent: ORACLE (opus)
```

---

## Phase 02: SMC DEEP AUDIT (2 weeks)

### Prompt para Copiar e Colar

```
Execute Phase 02: SMC DEEP AUDIT from Phase 09.

Context:
- Master plan: .planning/phases/09-strategy-activation/01-ROADMAP-FINAL.md
- Detailed plan: .planning/phases/09-strategy-activation/03-PHASE-02-PLAN.md
- Prerequisite: Phase 01 passed (50+ trades)

Tasks (from original plan):
1. Audit each SMC indicator: OB, FVG, Sweep, Structure, Regime
2. Run extended backtest: 2003-2020 (dev), holdout 2021-2025
3. WFA: 12 windows, IS 2 years, OOS 6 months
4. Monte Carlo: 5000 runs, block bootstrap

NEW Tasks (from ARGUS):
5. Look-ahead pattern verification - 17 patterns with grep commands
   - Deliverable: orchestration/LOOKAHEAD_CHECKLIST.md

6. NautilusTrader bar config audit
   - Verify: bars_timestamp_on_close, ts_init_delta, bar_execution, bar_adaptive_high_low_ordering
   - Deliverable: orchestration/NAUTILUS_CONFIG_AUDIT.md

7. HWM protection logic design
   - Scale-out levels: 50% at +1R, 25% at +2R, 25% at full TP
   - Deliverable: orchestration/HWM_PROTECTION_DESIGN.md

GO/NO-GO (ALL must pass):
- WFE >= 0.6
- SQN >= 2.0
- PSR >= 0.85
- MC95DD < 4%
- 17 look-ahead patterns verified PASS
- NautilusTrader config verified
- Holdout WFE >= 0.5

Output:
- Save to: .planning/phases/09-strategy-activation/orchestration/PHASE_02_SMC_AUDIT.md

Agents: ORACLE (opus) + CRUCIBLE (opus)
```

---

## Phase 03: TREND_FOLLOW ACTIVATION (1 week)

### Prompt para Copiar e Colar

```
Execute Phase 03: TREND_FOLLOW ACTIVATION from Phase 09.

Context:
- Master plan: .planning/phases/09-strategy-activation/01-ROADMAP-FINAL.md
- Detailed plan: .planning/phases/09-strategy-activation/04-PHASE-03-PLAN.md
- Prerequisite: Phase 02 passed

Tasks:
1. Validate TrendFollowGenerator: pullback + breakout modes
2. Run separate backtest for TREND_FOLLOW only
3. Compare to SMC_SCALPER metrics
4. Analyze correlation between strategies

Decision:
- SMC >> TrendFollow → Focus on SMC
- SMC ~ TrendFollow → Keep both for diversification
- SMC << TrendFollow → Consider simplification

Output:
- Save to: .planning/phases/09-strategy-activation/orchestration/PHASE_03_TREND_FOLLOW.md

Agents: CRUCIBLE (opus) + ORACLE (opus)
```

---

## Phase 04: MEAN_REVERT DECISION (3 days)

### Prompt para Copiar e Colar

```
Execute Phase 04: MEAN_REVERT DECISION from Phase 09.

Context:
- Master plan: .planning/phases/09-strategy-activation/01-ROADMAP-FINAL.md
- Detailed plan: .planning/phases/09-strategy-activation/05-PHASE-04-PLAN.md
- Prerequisite: Phase 03 complete

Tasks:
1. Research: Does mean reversion make sense for XAUUSD scalping?
2. If implement: Design Bollinger + RSI approach
3. Present options to user: IMPLEMENT / REMOVE / DEFER
4. Execute user decision

Output:
- Save research to: .planning/phases/09-strategy-activation/orchestration/MEAN_REVERT_RESEARCH.md
- Save decision to: .planning/phases/09-strategy-activation/orchestration/PHASE_04_DECISION.md

Agent: CRUCIBLE (opus) - research only, then FORGE if implementing
```

---

## Phase 05: FRAMEWORK INTEGRATION (1 week)

### Prompt para Copiar e Colar

```
Execute Phase 05: FRAMEWORK INTEGRATION from Phase 09.

Context:
- Master plan: .planning/phases/09-strategy-activation/01-ROADMAP-FINAL.md
- Detailed plan: .planning/phases/09-strategy-activation/06-PHASE-05-PLAN.md
- Prerequisite: Phase 04 complete

Tasks (from original plan):
1. Validate StrategySelector 6 gates
2. Validate AdaptiveEVRouter (DISABLED mode)
3. Integration test: tick → selector → candidates → router → signal → order

NEW Tasks (from ARGUS):
4. Implement 30% per-trade loss limit validation
   - Add to StrategySelector Gate 2

5. Implement 5:1 R:R enforcement
   - Add to position_sizer.py

6. Add execution_mode configuration
   - ExecutionMode.AUTO (full automation for eval/backtest)
   - ExecutionMode.SIGNAL_ONLY (alerts only for PA/Live)

GO/NO-GO:
- All 6 selector gates work correctly
- Static allocation functions properly
- Router code compiles (for future use)
- 30% per-trade limit validated
- 5:1 R:R enforcement working
- Both execution modes tested

Output:
- Save to: .planning/phases/09-strategy-activation/orchestration/PHASE_05_INTEGRATION.md

Agents: FORGE (opus) + SENTINEL (opus)
```

---

## Phase 06: MULTI-STRATEGY BACKTEST (1 week)

### Prompt para Copiar e Colar

```
Execute Phase 06: MULTI-STRATEGY BACKTEST from Phase 09.

Context:
- Master plan: .planning/phases/09-strategy-activation/01-ROADMAP-FINAL.md
- Detailed plan: .planning/phases/09-strategy-activation/07-PHASE-06-PLAN.md
- Prerequisite: Phase 05 complete

Tasks (from original plan):
1. Run individual baselines: SMC only, TrendFollow only
2. Run combined: Selector only, Selector + Router
3. Diversification benefit analysis
4. Compare all configurations

NEW Tasks (from ARGUS):
5. Implement PBO calculation (Probability of Backtest Overfitting)
   - Add to src/backtesting/validation_metrics.py
   - Target: PBO < 25%

6. Implement DSR calculation (Deflated Sharpe Ratio)
   - Add to src/backtesting/validation_metrics.py
   - Target: DSR > 0

7. Create failure mode matrix
   - Map 47 failure modes from ARGUS to prevention code
   - Deliverable: orchestration/FAILURE_MODE_MATRIX.md

GO/NO-GO (ALL must pass):
| Metric | Threshold |
|--------|-----------|
| WFE | >= 0.6 |
| SQN | >= 2.0 |
| PSR | >= 0.85 |
| DSR | > 0 |
| PBO | < 25% |
| MC95DD | < 4% |
| Min Trades | >= 200 |

Output:
- Save to: .planning/phases/09-strategy-activation/orchestration/PHASE_06_MULTI_STRATEGY.md
- Save comparison: .planning/phases/09-strategy-activation/MULTI_STRATEGY_COMPARISON.md

Agents: ORACLE (opus) + DAEMON (opus) for strategic review
```

---

## Phase 07: PAPER TRADING (2 weeks)

### Prompt para Copiar e Colar

```
Execute Phase 07: PAPER TRADING from Phase 09.

Context:
- Master plan: .planning/phases/09-strategy-activation/01-ROADMAP-FINAL.md
- Prerequisite: Phase 06 passed all GO/NO-GO criteria

Tasks:
1. Run strategy on LIVE data stream (not backtest replay)
2. Track unrealized PnL and HWM exactly as Apex would
3. NO real money at risk

Verification Points:
- Time gate 4:30 PM ET: New trades blocked
- Time gate 4:55 PM ET: Emergency close initiates
- Time gate 4:59 PM ET: Position flat verified
- HWM tracking: Uses BID/ASK not MID
- Trailing DD: Correct calculation from HWM
- Latency: < 50ms on-tick

NEW from ARGUS:
4. Test BOTH execution modes:
   - Week 1: ExecutionMode.AUTO
   - Week 2: ExecutionMode.SIGNAL_ONLY
   - Deliverable: orchestration/EXECUTION_MODE_TEST.md

5. Verify 47 failure mode preventions in live conditions

GO/NO-GO:
- No critical issues in 2 weeks
- All time gates verified
- HWM calculation verified (BID/ASK)
- Latency within budget
- Both execution modes work
- 47 failure mode checks pass

Output:
- Save to: .planning/phases/09-strategy-activation/orchestration/PHASE_07_PAPER_TRADING.md

Agent: SENTINEL (opus)
```

---

## Phase 08: PRODUCTION READINESS (1 week)

### Prompt para Copiar e Colar

```
Execute Phase 08: PRODUCTION READINESS from Phase 09.

Context:
- Master plan: .planning/phases/09-strategy-activation/01-ROADMAP-FINAL.md
- Prerequisite: Phase 07 passed (2 weeks paper trading)

Tasks:
1. External CRITIC review (fresh context, no prior bias)
2. SENTINEL final approval

SENTINEL Apex Compliance Checklist:
- [ ] Trailing DD < 5% from HWM
- [ ] Daily DD < 3% halt
- [ ] Close all by 4:59 PM ET
- [ ] Block new trades after 4:30 PM ET
- [ ] Emergency close from 4:55 PM ET
- [ ] HWM uses BID/ASK (not MID)
- [ ] Broker-side SL as backup
- [ ] 30% per-trade limit enforced
- [ ] 5:1 R:R verified
- [ ] Automation prohibition understood (PA/Live)

Deployment Checklist:
- [ ] All tests pass
- [ ] Coverage >= 70% line, >= 50% branch
- [ ] No mypy errors
- [ ] Latency verified
- [ ] Runbook documented
- [ ] Alerting configured
- [ ] Rollback procedure documented

FINAL GATE (ALL must pass):
- CRITIC review: No critical issues
- SENTINEL approval: Obtained
- All validation metrics: GREEN
- Paper trading: PASSED
- Deployment checklist: COMPLETE

Output:
- Save CRITIC review: .planning/phases/09-strategy-activation/orchestration/PHASE_08_CRITIC_REVIEW.md
- Save SENTINEL approval: .planning/phases/09-strategy-activation/orchestration/PHASE_08_SENTINEL_APPROVAL.md
- Save final decision: .planning/phases/09-strategy-activation/PHASE_09_FINAL_DECISION.md

Agents: CRITIC (opus) + SENTINEL (opus)

Decision:
- All pass → GO - Deploy to smallest account ($50k)
- Any fail → NO-GO - Address issues, re-run relevant phases
```

---

## Output Files Summary

### Orchestration Folder

```
.planning/phases/09-strategy-activation/orchestration/
├── PHASE_00A_BASELINE_RESULTS.md      ← Phase 00-A
├── PHASE_00B_BUGFIX_REPORT.md         ← Phase 00-B
├── PHASE_01_DIAGNOSTIC_RESULTS.md     ← Phase 01
├── LOOKAHEAD_CHECKLIST.md             ← Phase 02 (NEW)
├── NAUTILUS_CONFIG_AUDIT.md           ← Phase 02 (NEW)
├── HWM_PROTECTION_DESIGN.md           ← Phase 02 (NEW)
├── PHASE_02_SMC_AUDIT.md              ← Phase 02
├── PHASE_03_TREND_FOLLOW.md           ← Phase 03
├── MEAN_REVERT_RESEARCH.md            ← Phase 04
├── PHASE_04_DECISION.md               ← Phase 04
├── PHASE_05_INTEGRATION.md            ← Phase 05
├── FAILURE_MODE_MATRIX.md             ← Phase 06 (NEW)
├── PHASE_06_MULTI_STRATEGY.md         ← Phase 06
├── EXECUTION_MODE_TEST.md             ← Phase 07 (NEW)
├── PHASE_07_PAPER_TRADING.md          ← Phase 07
├── PHASE_08_CRITIC_REVIEW.md          ← Phase 08
└── PHASE_08_SENTINEL_APPROVAL.md      ← Phase 08
```

### Main Folder

```
.planning/phases/09-strategy-activation/
├── 00-EXECUTION-GUIDE.md              ← THIS FILE
├── 01-ROADMAP-FINAL.md                ← Master Plan v2.0
├── 02-PHASE-01-PLAN.md                ← Detailed plan
├── 03-PHASE-02-PLAN.md                ← Detailed plan
├── 04-PHASE-03-PLAN.md                ← Detailed plan
├── 05-PHASE-04-PLAN.md                ← Detailed plan
├── 06-PHASE-05-PLAN.md                ← Detailed plan
├── 07-PHASE-06-PLAN.md                ← Detailed plan
├── 08-SIMPLIFICATION_PLAN.md          ← Plan B
├── MULTI_STRATEGY_COMPARISON.md       ← Phase 06 output
└── PHASE_09_FINAL_DECISION.md         ← Final GO/NO-GO
```

---

## Quick Start

**Copie e cole o prompt da Phase 00-A para começar:**

```
Execute Phase 00-A: BASELINE VALIDATION from Phase 09.

Context:
- Master plan: .planning/phases/09-strategy-activation/01-ROADMAP-FINAL.md
- This is a GO/NO-GO gate from DAEMON's recommendation
- Purpose: Validate SMC thesis before spending weeks on fixes

Tasks:
1. Create simple EMA 20/50 crossover baseline strategy
2. Run backtest on same period as current SMC (2024-01-01 to 2024-06-30)
3. Use same dataset: data/raw/full_parquet/xauusd_2003_2025_stride20_full.parquet
4. Apply same session filters and risk management as SMC
5. Compare metrics: Trades, Win Rate, PnL, Sharpe, Profit Factor

GO/NO-GO Decision:
- IF SMC < EMA (Sharpe/PF): STOP IMMEDIATELY
- IF SMC > EMA by < 20%: CAUTION - proceed with scrutiny
- IF SMC > EMA by >= 20%: PROCEED with FIX FIRST

Output:
- Save results to: .planning/phases/09-strategy-activation/orchestration/PHASE_00A_BASELINE_RESULTS.md

Agent: ORACLE (opus)
```

---

## Timeline Estimate

| Phase | Duration | Cumulative |
|-------|----------|------------|
| 00-A | 2-4 hours | Day 1 |
| 00-B | 1 week | Week 1 |
| 01 | 3 days | Week 2 |
| 02 | 2 weeks | Week 4 |
| 03 | 1 week | Week 5 |
| 04 | 3 days | Week 5-6 |
| 05 | 1 week | Week 6-7 |
| 06 | 1 week | Week 7-8 |
| 07 | 2 weeks | Week 10 |
| 08 | 1 week | Week 11 |

**Total: 10-11 weeks**

---

## Hard Exit Criteria

| Gate | Condition | Action |
|------|-----------|--------|
| Phase 00-A | EMA > SMC | STOP or PIVOT |
| Phase 00-B | Bugs not fixed after 2 weeks | STOP or PIVOT |
| Phase 01 | < 50 trades after fix | Trigger Plan B |
| Phase 02 | WFE < 0.3 on dev set | STOP |
| Holdout | Negative return 2021-2025 | STOP |
| Any | Engineering hours > 400 | HARD PAUSE |
| Any | Franco loses interest | STOP |

---

*End of Execution Guide*
