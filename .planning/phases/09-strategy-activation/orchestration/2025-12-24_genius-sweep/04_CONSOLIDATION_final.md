# ONDA 4: Final Consolidation & Prioritized Action Plan

**Date:** 2025-12-24
**Purpose:** Distill 9 agent outputs into executable action plan with clear ownership

---

## Executive Summary

After 3 waves of parallel analysis across 5 elite agents (CRITIC, CRUCIBLE, SENTINEL, DAEMON, ORACLE), the verdict is unanimous:

**THE SYSTEM IS BROKEN BUT FIXABLE**

| Aspect | Current State | Target State | Gap |
|--------|---------------|--------------|-----|
| Trades/22yr | 7 | 200+ | **97% shortfall** |
| 1-Year Survival | ~65% | >95% | **30% gap** |
| Code Lines | 15K | 5K | **67% bloat** |
| Confluence Factors | 9 | 4 | **5 dead factors** |
| MC95DD | Unknown | <4% | **Unmeasured** |
| WFE | Unknown | ≥0.6 | **Unmeasured** |

---

## The Golden Path (Critical Path Only)

```
NOW ──────────────────────────────────────────────────────────────────────────►

[P0.1] Bottleneck Logging    [P0.2] Ghost Test Impl    [P0.3] Run Ghost Test
       (2-3 hours)                  (4-6 hours)              (1 hour)
          │                              │                        │
          ▼                              ▼                        ▼
     ┌────────────────────────────────────────────────────────────────┐
     │                     DECISION GATE                              │
     │  IF Ghost Sharpe_real - Sharpe_ghost > 0.2 → GO (Keep Signals) │
     │  IF Ghost Sharpe_real - Sharpe_ghost ≤ 0.2 → PIVOT (Filters)   │
     └────────────────────────────────────────────────────────────────┘
          │                                                      │
          ▼                                                      ▼
     [GO PATH]                                           [PIVOT PATH]
     Confluence Simplification (9→4)                     Filter-Only Strategy
     HWM-Proximity Scale-Out                             Simple trend-follow entry
     Fix HWM BID/ASK calculation                         Same survival hardening
          │                                                      │
          └──────────────────────┬───────────────────────────────┘
                                 │
                                 ▼
                    [Monte Carlo Validation]
                    [WFA + PSR/DSR/PBO]
                    [MC95DD < 4%? 95% survival?]
                                 │
                   ┌─────────────┴─────────────┐
                   │                           │
                   ▼                           ▼
               [PASS]                      [FAIL]
           Paper Trading                Loop back or
            (2 weeks)                    Redesign
```

---

## Master Action List (Prioritized)

### PRIORITY 0: BLOCKING (Do Before Anything Else)

| # | Task | Owner | Est. Effort | Deliverable | GO/NO-GO Gate |
|---|------|-------|-------------|-------------|---------------|
| P0.1 | **Add bottleneck logging** | FORGE | 2-3 hrs | Rejection funnel logs | Logs show where 99.97% of signals die |
| P0.2 | **Implement Ghost Test** | FORGE | 4-6 hrs | `ghost_test.py` | Unit tests pass |
| P0.3 | **Run Ghost Test** | ORACLE | 1 hr | Decision: GO/PIVOT | Sharpe delta calculated |

**CRITICAL:** All Week 1-4 work is BLOCKED until P0 complete. Do not proceed without Ghost Test result.

---

### PRIORITY 1: WEEK 1 (After Ghost Test Decision)

#### IF GO (Signals Have Edge):

| # | Task | Owner | Est. Effort | Deliverable |
|---|------|-------|-------------|-------------|
| P1.1 | **Simplify confluence (9→4)** | FORGE | 6-8 hrs | `simple_confluence.py` |
| P1.2 | **Implement HWM-Proximity Scale-Out** | FORGE | 4-6 hrs | Scale logic in position sizing |
| P1.3 | **Fix HWM calculation (BID/ASK)** | FORGE | 2-3 hrs | Conservative price enforcement |
| P1.4 | **Fix consistency tracker** | FORGE | 2-3 hrs | Correct trailing DD calculation |

#### IF PIVOT (Signals Have No Edge):

| # | Task | Owner | Est. Effort | Deliverable |
|---|------|-------|-------------|-------------|
| P1.1 | **Implement filter-only strategy** | FORGE | 8-12 hrs | Simple trend-follow + existing filters |
| P1.2 | **Same HWM-Proximity Scale-Out** | FORGE | 4-6 hrs | Scale logic in position sizing |
| P1.3 | **Same BID/ASK fix** | FORGE | 2-3 hrs | Conservative price enforcement |
| P1.4 | **Delete old confluence code** | FORGE | 1 hr | Archive to `.archive/` |

---

### PRIORITY 2: WEEK 2-3 (Validation)

| # | Task | Owner | Est. Effort | Deliverable |
|---|------|-------|-------------|-------------|
| P2.1 | **Implement Monte Carlo with HWM** | ORACLE | 6-8 hrs | MC95DD, MC99DD calculated |
| P2.2 | **Implement PSR/DSR/PBO** | ORACLE | 4-6 hrs | All metrics calculated |
| P2.3 | **Run full WFA (12 windows)** | ORACLE | 2-3 hrs | WFE ≥ 0.6 validated |
| P2.4 | **Validate survival probability** | SENTINEL | 2-3 hrs | 95% 1-year confirmed |

**GO/NO-GO Gate:**
- MC95DD < 4%
- 1-Year Survival ≥ 95%
- WFE ≥ 0.6
- 200+ trades

---

### PRIORITY 3: WEEK 4+ (Enhancement - Only After P2 Passes)

| # | Task | Owner | Est. Effort | Priority |
|---|------|-------|-------------|----------|
| P3.1 | Session Transition Alpha | CRUCIBLE | 8-12 hrs | MEDIUM |
| P3.2 | Time-of-Day Risk Curve | SENTINEL | 4-6 hrs | LOW |
| P3.3 | Volatility Expansion Breakout | CRUCIBLE | 12-20 hrs | LOW |
| P3.4 | Cross-Asset Correlation | CRUCIBLE | 20-40 hrs | DEFERRED |

---

## Key Decisions Locked

| Decision | Choice | Rationale | Agent Source |
|----------|--------|-----------|--------------|
| Risk per trade | 0.5% max | 95% survival math | SENTINEL |
| Lot size cap | 0.25 lots on $50k | MC95DD < 4% | SENTINEL |
| Confluence factors | 4 (Regime, Direction, Session, Entry) | 7/9 score ZERO | CRUCIBLE |
| Entry trigger | Pullback/Breakout (M5) | Simple, verifiable edge | CRUCIBLE |
| Position scaling | HWM-Proximity | Prevent HWM trap | SENTINEL |
| Ghost Test threshold | Sharpe delta > 0.2 | Statistical significance | ORACLE |
| ML work | DEFERRED until validation passes | No proven edge yet | DAEMON |
| Timeframe | M5 entry, M15 state (default) | Simplest starting point | CRUCIBLE |

---

## Risk Register (Top 5)

| Risk | Probability | Impact | Mitigation | Owner |
|------|-------------|--------|------------|-------|
| Ghost Test shows signals are toxic | 40% | HIGH | Have PIVOT path ready | DAEMON |
| Simplification still produces <50 trades | 20% | HIGH | Progressive filter relaxation | FORGE |
| MC95DD > 4% even with 0.25 lots | 15% | CRITICAL | Reduce to 0.15 lots or redesign | SENTINEL |
| WFE < 0.6 after simplification | 25% | HIGH | Investigate overfit, adjust | ORACLE |
| Time gates don't work in live | 5% | CRITICAL | Paper trading mandatory | SENTINEL |

---

## Success Metrics Dashboard

| Metric | Current | Week 1 Target | Week 4 Target | Final Gate |
|--------|---------|---------------|---------------|------------|
| Trade Count | 7 | 50+ | 200+ | ≥200 |
| MC95DD | Unknown | Measured | <4% | <4% |
| 1-Year Survival | ~65% | Measured | >95% | ≥95% |
| WFE | Unknown | N/A | ≥0.6 | ≥0.6 |
| PSR | Unknown | N/A | ≥0.85 | ≥0.85 |
| DSR | Unknown | N/A | >0 | >0 |
| PBO | Unknown | N/A | <25% | <25% |
| Code Lines | 15K | 10K | 5K | ≤5K |
| Confluence Factors | 9 | 4 | 4 | 4 |
| Ghost Test Delta | N/A | Measured | >0.2 (if GO) | N/A |

---

## Agent Handoff Summary

### FORGE Receives:

1. **P0.1:** Add bottleneck logging to signal rejection funnel
2. **P0.2:** Implement Ghost Test harness per ORACLE spec
3. **P1.x:** Either simplify confluence OR implement filter-only (after Ghost Test)
4. **P1.2-4:** HWM-Proximity scaling, BID/ASK fix, consistency tracker fix

### ORACLE Receives:

1. **P0.3:** Run Ghost Test, deliver GO/PIVOT decision
2. **P2.1-3:** Monte Carlo, PSR/DSR/PBO, WFA validation
3. Final validation battery before paper trading

### SENTINEL Receives:

1. **P2.4:** Validate 95% 1-year survival with actual metrics
2. Apex compliance sign-off before paper trading
3. Emergency close mechanism verification

### CRUCIBLE Receives:

1. **P3.1:** Session Transition Alpha (after P2 passes)
2. **P3.3:** Volatility Expansion Breakout (deferred)

### DAEMON Receives:

1. Strategic oversight of transformation
2. Course correction if Ghost Test results are ambiguous
3. Paradigm enforcement ("Survive first, profit second")

---

## Timeline Overview

```
Week 0 (Now - End of Day)
├── P0.1: Bottleneck logging
├── P0.2: Ghost Test implementation
└── P0.3: Ghost Test execution → DECISION

Week 1 (After Decision)
├── [GO] P1.1-4: Simplification + survival hardening
└── [PIVOT] P1.1-4: Filter-only + survival hardening

Week 2-3
├── P2.1: Monte Carlo with HWM
├── P2.2: PSR/DSR/PBO implementation
├── P2.3: Full WFA validation
└── P2.4: Survival probability validation → GO/NO-GO

Week 4
├── P3.1-2: Enhancements (if time permits)
└── Paper Trading Prep → 2-week paper trading begins

Week 6+
└── Paper Trading Complete → GO-LIVE decision
```

---

## Final Verdict

**STATUS: READY TO EXECUTE**

The path forward is clear:

1. **TODAY:** P0.1-3 (Bottleneck logging + Ghost Test)
2. **DECISION GATE:** GO or PIVOT based on Ghost Test
3. **WEEK 1:** Simplification OR filter-only + survival hardening
4. **WEEK 2-3:** Full validation battery
5. **WEEK 4+:** Paper trading → GO-LIVE

**The 4-week transformation starts NOW.**

---

*ONDA 4 Consolidation Complete | 2025-12-24*
