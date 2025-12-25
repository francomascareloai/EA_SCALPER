# GENIUS SWEEP MANIFEST

**Date:** 2025-12-24
**Scope:** Complete multi-wave parallel analysis of EA_SCALPER_XAUUSD
**Waves:** 4 (ONDA 1-4)
**Agents:** CRITIC, CRUCIBLE, SENTINEL, DAEMON, ORACLE
**Total Outputs:** 11 documents

---

## Purpose

Massive parallel analysis seeking revolutionary improvements for:
- **Higher profitability** (increase trade frequency from 7 to 200+)
- **Lower risk** (increase 1-year survival from 65% to 95%+)
- **Revolutionary insights** (paradigm shifts, hidden patterns)

---

## Document Index

### ONDA 1: Parallel Analysis (5 Agents)

| File | Agent | Focus | Key Finding |
|------|-------|-------|-------------|
| `01_CRITIC_adversarial.md` | CRITIC | Adversarial review | 10 CRITICAL issues, NO-GO verdict |
| `01_CRUCIBLE_revolution.md` | CRUCIBLE | Revolutionary ideas | 10 innovations, #1 Confluence Simplification |
| `01_SENTINEL_risk_innovation.md` | SENTINEL | Risk innovations | 10 innovations, #1 HWM-Proximity Scale-Out |
| `01_DAEMON_paradigm.md` | DAEMON | Paradigm analysis | "Survive first, profit second" |
| `01_ORACLE_validation.md` | ORACLE | Validation gaps | 16 gaps (6 CRITICAL) |

### ONDA 2: Deep Dives (4 Agents)

| File | Agent | Focus | Key Finding |
|------|-------|-------|-------------|
| `02_SENTINEL_survival_math.md` | SENTINEL | Survival mathematics | 0.25 lots max, 0.5% risk/trade |
| `02_DAEMON_transformation.md` | DAEMON | 4-week roadmap | Week-by-week transformation plan |
| `02_ORACLE_ghost_test.md` | ORACLE | Ghost Test design | Implementation spec, pass/fail criteria |
| `02_CRUCIBLE_confluence_simple.md` | CRUCIBLE | Factor analysis | 7/9 factors score ZERO |

### ONDA 3: Synthesis

| File | Focus | Key Finding |
|------|-------|-------------|
| `03_SYNTHESIS_cross_cutting.md` | Cross-agent synthesis | 95% convergence, 5 synergies, 3 conflicts resolved |

### ONDA 4: Consolidation

| File | Focus | Key Finding |
|------|-------|-------------|
| `04_CONSOLIDATION_final.md` | Action plan | Prioritized P0-P3 task list with ownership |

---

## Top 10 Revolutionary Discoveries

### 1. THE 7-TRADE PROBLEM
**Source:** All agents
**Finding:** 7 trades in 22 years of data = statistically meaningless
**Root Cause:** 8/9 confluence factors score ZERO - the ICT 7-step sequence always fails at Step 3 (sweeps never fire)
**Solution:** Simplify to 4-factor system (Regime, Direction, Session, Entry)

### 2. HWM TRAP IS PRIMARY KILLER
**Source:** SENTINEL, CRITIC, DAEMON
**Finding:** Unrealized profit raises HWM permanently - this traps accounts into termination
**Math:** 80% of account terminations come from HWM trap, not actual losses
**Solution:** HWM-Proximity Scale-Out + Conservative BID/ASK pricing

### 3. STANDARD KELLY IS SUICIDAL
**Source:** SENTINEL
**Finding:** Kelly criterion assumes no ruin - Apex has 5% DD death threshold
**Formula:** `Max_Risk = 0.4 * (5% - Current_Trailing_DD)` - NOT standard Kelly
**Constraint:** 0.5% risk per trade = 0.25 lots max on $50k

### 4. SIGNALS MAY BE TOXIC
**Source:** ORACLE, DAEMON
**Finding:** Ghost Test may prove signals ADD NEGATIVE VALUE
**Implication:** Filters (time, regime, session) may be the ENTIRE edge
**Decision:** If Ghost Test fails (Sharpe_ghost ≥ Sharpe_real), pivot to filter-only strategy

### 5. SURVIVAL > RETURNS
**Source:** DAEMON (paradigm shift)
**Old Paradigm:** Optimize for returns
**New Paradigm:** Survive first, profit second
**Quantified:** 0.5 Sharpe with 95% survival beats 2.0 Sharpe with 50% survival

### 6. M15/M5 SEMANTIC COLLISION
**Source:** CRUCIBLE
**Finding:** Both timeframes do the SAME structure analysis - they cancel each other out
**Solution:** Separate roles - M15 = STATE (regime/direction), M5 = EVENT (entry)

### 7. COMPLEXITY IS THE ENEMY
**Source:** DAEMON, CRUCIBLE
**Finding:** 15K lines of code for 7 trades = negative ROI on complexity
**Target:** 5K lines, 200+ trades
**Philosophy:** Every line of code is a liability until proven profitable

### 8. MISSING STATISTICAL VALIDATION
**Source:** ORACLE
**Finding:** No Monte Carlo, no PSR/DSR/PBO, no proper WFA
**Impact:** All performance claims are statistically unsupported
**Solution:** Implement full validation battery (MC95DD, WFE, PSR, DSR, PBO)

### 9. CONSERVATIVE PRICING MISSING
**Source:** CRITIC, SENTINEL
**Finding:** HWM calculation uses MID price - overstates unrealized profit
**Fix:** LONG positions use BID, SHORT positions use ASK for conservative exit

### 10. 95% SURVIVAL REQUIRES 0.25 LOTS
**Source:** SENTINEL
**Math:** E[max_DD] = σ × √(2 × ln(n))
**Result:** At 0.5 lots, MC95DD = 3.17% (too close to 5% limit)
**Safe Zone:** 0.25 lots → MC95DD = 1.59% → 95% 1-year survival

---

## Unified Decision Matrix

| Decision | Choice | Rationale | Locked By |
|----------|--------|-----------|-----------|
| Max risk/trade | 0.5% | 95% survival math | SENTINEL |
| Max lots ($50k) | 0.25 | MC95DD < 4% | SENTINEL |
| Confluence factors | 4 | 7/9 score ZERO | CRUCIBLE |
| Ghost Test gate | Yes | Prove signals have edge | ORACLE |
| Position scaling | HWM-Proximity | Prevent trap | SENTINEL |
| ML work | DEFERRED | No proven edge yet | DAEMON |
| Timeframe split | M15 state, M5 event | Fix collision | CRUCIBLE |
| Price basis (HWM) | BID/ASK conservative | Prevent inflation | SENTINEL |

---

## The 4-Factor Simple Confluence System

**Replacing 9-factor system (1136 lines) with 4-factor system (~200 lines):**

| # | Factor | Layer | Type | Purpose |
|---|--------|-------|------|---------|
| 1 | **REGIME** | M15 | Gate | Block random-walk trading (Hurst) |
| 2 | **DIRECTION** | M15 | State | Determine trend bias (EMA50/200) |
| 3 | **SESSION** | M15 | Gate | Apex time compliance |
| 4 | **ENTRY** | M5 | Trigger | Pullback/breakout detection |

**Expected Impact:**
- Trades/month: 2 → 10-20 (5-10x improvement)
- Code lines: 1136 → ~200 (82% reduction)
- Edge: NEUTRAL (removing 0% factors removes no edge)

---

## HWM-Proximity Scale-Out Protocol

```python
def calculate_position_scale(hwm: float, equity: float) -> float:
    buffer_pct = ((equity - 0.95 * hwm) / equity) * 100

    if buffer_pct >= 3.0:   return 1.00  # Full size
    if buffer_pct >= 2.0:   return 0.50  # Half size
    if buffer_pct >= 1.5:   return 0.25  # Quarter size
    if buffer_pct >= 1.0:   return 0.00  # HALT
    else:
        emergency_close_all()
        return 0.00
```

**Impact:** 70% reduction in HWM trap terminations (from ~80% to ~20%)

---

## Ghost Test Specification

**Purpose:** Isolate signal edge from filter edge

**Implementation:**
1. Replace signal generator with random.choice([BUY, SELL, None])
2. Match real signal frequency distribution
3. Keep all filters intact (regime, session, time gates)
4. Run same backtest period

**Decision Matrix:**
| Result | Decision |
|--------|----------|
| Sharpe_real - Sharpe_ghost > 0.3 | **GO** - signals have edge |
| Sharpe_real - Sharpe_ghost in [0.2, 0.3] | **MARGINAL** - dig deeper |
| Sharpe_real - Sharpe_ghost < 0.2 | **PIVOT** - filters are the edge |
| Sharpe_ghost > Sharpe_real | **ABORT** - signals are TOXIC |

---

## Critical Path

```
P0.1 Bottleneck Logging ───┐
P0.2 Ghost Test Impl ──────┼──► P0.3 Run Ghost Test ──► DECISION
                           │
                           ▼
              ┌─── GO ─────┴───── PIVOT ───┐
              │                            │
              ▼                            ▼
    Confluence Simplify         Filter-Only Strategy
              │                            │
              └────────────┬───────────────┘
                           │
                           ▼
              [P1: Survival Hardening]
              [P2: Validation Battery]
              [P3: Paper Trading]
                           │
                           ▼
                    [GO-LIVE DECISION]
```

---

## Metrics Dashboard

| Metric | Current | Week 1 | Week 4 | Final |
|--------|---------|--------|--------|-------|
| Trade Count | 7 | 50+ | 200+ | ≥200 |
| MC95DD | ? | Measured | <4% | <4% |
| 1-Yr Survival | ~65% | Measured | >95% | ≥95% |
| WFE | ? | N/A | ≥0.6 | ≥0.6 |
| PSR | ? | N/A | ≥0.85 | ≥0.85 |
| DSR | ? | N/A | >0 | >0 |
| PBO | ? | N/A | <25% | <25% |
| Code Lines | 15K | 10K | 5K | ≤5K |
| Factors | 9 | 4 | 4 | 4 |

---

## Agent Verdicts Summary

| Agent | Verdict | Confidence | Key Statement |
|-------|---------|------------|---------------|
| **CRITIC** | NO-GO | HIGH | "65-80% probability of Year 1 termination" |
| **CRUCIBLE** | CONDITIONAL GO | HIGH | "Simplification removes complexity theater, not edge" |
| **SENTINEL** | CONDITIONAL GO | HIGH | "0.25 lots max achieves 95% survival" |
| **DAEMON** | CONDITIONAL GO | HIGH | "Survive first, profit second" |
| **ORACLE** | NO-GO | HIGH | "16 validation gaps (6 CRITICAL)" |

**UNIFIED VERDICT:**
> The system is architecturally fragile, operationally broken, and philosophically misaligned. However, the path forward is clear: Ghost Test → Simplify/Pivot → Survive. Executable in 4 weeks.

---

## Files Created in This Sweep

```
.planning/phases/09-strategy-activation/orchestration/2025-12-24_genius-sweep/
├── 01_CRITIC_adversarial.md      # ONDA 1
├── 01_CRUCIBLE_revolution.md     # ONDA 1
├── 01_SENTINEL_risk_innovation.md # ONDA 1
├── 01_DAEMON_paradigm.md         # ONDA 1
├── 01_ORACLE_validation.md       # ONDA 1
├── 02_SENTINEL_survival_math.md  # ONDA 2
├── 02_DAEMON_transformation.md   # ONDA 2
├── 02_ORACLE_ghost_test.md       # ONDA 2
├── 02_CRUCIBLE_confluence_simple.md # ONDA 2
├── 03_SYNTHESIS_cross_cutting.md # ONDA 3
├── 04_CONSOLIDATION_final.md     # ONDA 4
└── MANIFEST.md                   # This file
```

---

## Next Actions (Immediate)

| # | Action | Owner | Priority |
|---|--------|-------|----------|
| 1 | Add bottleneck logging | FORGE | **NOW** |
| 2 | Implement Ghost Test | FORGE | **NOW** |
| 3 | Run Ghost Test | ORACLE | **BLOCKING** |
| 4 | Make GO/PIVOT decision | ORCHESTRATOR | **BLOCKING** |
| 5 | Execute Week 1 plan | FORGE | After decision |

---

## Quote to Remember

> "The goal is not to be right. The goal is to not be dead."
> — DAEMON Strategic Advisor

---

*GENIUS SWEEP COMPLETE | 4 ONDAS | 11 DOCUMENTS | 2025-12-24*
