# PLAN: Phase 08 - Production Readiness

## Metadata
- **Phase:** 08
- **Priority:** P0 - CRITICAL (Final Gate)
- **Status:** Not Started
- **Agents:** CRITIC (adversarial review) + SENTINEL (final approval)
- **Depends On:** Phase 07 (Paper Trading PASS)
- **Duration:** 1 week

---

## MANDATORY EXECUTION PROTOCOL

**ESTE PROTOCOLO DEVE SER SEGUIDO EM TODAS AS ACOES:**

### 1. Autonomous Loop (CRITIC ate GO)
```
Executar task → CRITIC review (opus) → GO?
                      ↓ NO
                Fix automatico → CRITIC review → loop (max 3x)
                      ↓ ainda NO-GO apos 3x
                Perguntar usuario
```

### 2. Quick Backtest Apos Cada Fix
```bash
# OBRIGATORIO apos qualquer mudanca de codigo
python -m nautilus_gold_scalper.run_backtest --start 2024-01-01 --end 2024-01-07

# Verificar:
# - Trades > 0 (senao algo quebrou)
# - Sem erros no log
# - Trade count nao caiu 50%+
```

### 3. Parallel Agents (sem limite)
- Pode spawnar multiplos agents em paralelo para fixes
- FORGE + ORACLE + SENTINEL simultaneo se necessario
- Nao economizar - usar quantos precisar

### 4. Anti-Hallucination
- SEMPRE mostrar output dos comandos
- NUNCA dizer "deve funcionar" sem testar
- NUNCA inventar metricas - usar output real

### 5. Verificacao Obrigatoria
```bash
# Antes de qualquer GO:
mypy --strict nautilus_gold_scalper/
pytest -q
# Quick backtest (1 semana)
```

**NOTA: Esta eh a fase FINAL - todas as verificacoes devem estar 100% antes do GO**

---

## Objective

Final validation and approval before deploying to Apex with real money. This is the last line of defense.

> "The cost of a missed bug in production is 100x the cost of finding it in review."

---

## Prerequisites

| Requirement | Source | Status |
|-------------|--------|--------|
| Paper trading PASS (2 weeks) | Phase 07 | Pending |
| All CRITICAL criteria pass | Phase 07 | Pending |
| No Apex compliance violations | Phase 07 | Pending |
| Failure modes verified | Phase 07 | Pending |

---

## Tasks

### Task 08-01: CRITIC Adversarial Review

**Status:** Not Started
**Priority:** P0
**Agent:** CRITIC (opus via CLIProxy)

**Review Scope:**
```markdown
CRITIC ADVERSARIAL REVIEW REQUEST

## Scope
Review ALL trading code, risk management, and Apex compliance.

## Files to Review
1. nautilus_gold_scalper/src/strategies/gold_scalper_strategy.py
2. nautilus_gold_scalper/src/risk/position_sizer.py
3. nautilus_gold_scalper/src/risk/drawdown_monitor.py
4. nautilus_gold_scalper/src/signals/confluence_scorer.py
5. nautilus_gold_scalper/src/core/time_gates.py

## Techniques Required
1. INVERSION: What would guarantee failure?
2. PRE-MORTEM: Assume we failed. Why?
3. STRESS: What if volatility 5x normal?
4. REGIME: What if market regime changes?
5. APEX_TRAP: What could breach Apex limits?
6. EDGE: What could erode the edge?
7. ASSUMPTION: What are we assuming that might be wrong?

## Deliverable
CRITIC_REVIEW.md with:
- Bugs found (CRITICAL/HIGH/MEDIUM/LOW)
- Logic errors
- Edge cases missed
- Apex compliance gaps
- Recommendations
- VERDICT: GO/NO-GO/CONDITIONAL
```

**Acceptance Criteria:**
- [ ] CRITIC review completed
- [ ] All CRITICAL issues resolved
- [ ] HIGH issues have mitigation plan

---

### Task 08-02: SENTINEL Final Approval

**Status:** Not Started
**Priority:** P0
**Agent:** SENTINEL (opus via CLIProxy)

**Approval Checklist:**
```markdown
SENTINEL APEX COMPLIANCE APPROVAL

## Mandatory Checks

### Trailing DD Protection
- [ ] HWM calculated tick-by-tick
- [ ] Uses conservative price (BID for longs, ASK for shorts)
- [ ] Never decreases during session
- [ ] HALT at 4.0% (safety buffer)
- [ ] TERMINATED at 5.0% (Apex limit)

### Daily DD Protection
- [ ] Calculated from session start
- [ ] REDUCE at 2.5%
- [ ] HALT at 3.0%

### Time Gates
- [ ] Block new trades at 4:30 PM ET
- [ ] Emergency close at 4:55 PM ET
- [ ] No overnight positions
- [ ] Handles DST correctly

### Position Sizing
- [ ] Risk per trade <= 1%
- [ ] 30% per-trade loss limit enforced
- [ ] 5:1 R:R enforcement

### Consistency Rule (Live Accounts)
- [ ] 30% daily profit limit (optional during eval)
- [ ] Tracking mechanism exists

### Automation Compliance
- [ ] SIGNAL_ONLY mode for PA/Live accounts
- [ ] AUTO mode only for Evaluation accounts
- [ ] Mode switch is clean

### Failsafes
- [ ] Network disconnect handling
- [ ] Stale data detection
- [ ] Emergency close works
- [ ] Position reconciliation

## Deliverable
SENTINEL_APPROVAL.md with:
- All checks verified
- Any exceptions noted
- VERDICT: APPROVED/REJECTED/CONDITIONAL
```

**Acceptance Criteria:**
- [ ] SENTINEL approval completed
- [ ] All mandatory checks pass
- [ ] APPROVED verdict received

---

### Task 08-03: Deployment Checklist

**Status:** Not Started
**Priority:** P0

**Pre-Deployment Checklist:**
```markdown
## Production Deployment Checklist

### Code
- [ ] All tests pass (mypy --strict, pytest -q)
- [ ] No TODO/FIXME in trading code
- [ ] Logging level set to INFO (not DEBUG)
- [ ] Secrets not hardcoded

### Configuration
- [ ] Correct broker credentials
- [ ] Correct account ID
- [ ] execution_mode = "AUTO" for Eval, "SIGNAL_ONLY" for PA/Live
- [ ] DD limits set correctly
- [ ] Time gates enabled

### Infrastructure
- [ ] VPS/server provisioned
- [ ] Network redundancy configured
- [ ] Time sync (NTP) verified
- [ ] Monitoring alerts configured

### Backup Plans
- [ ] Manual close procedure documented
- [ ] Emergency contact list ready
- [ ] Rollback plan defined

### Documentation
- [ ] All decisions documented
- [ ] Phase results archived
- [ ] Runbook created
```

**Acceptance Criteria:**
- [ ] All checklist items verified
- [ ] Runbook created
- [ ] Emergency procedures documented

---

### Task 08-04: Staged Deployment Plan

**Status:** Not Started
**Priority:** P1

**Deployment Stages:**
| Stage | Account | Capital | Duration | Success Criteria |
|-------|---------|---------|----------|------------------|
| 1 | Apex Evaluation $50k | Virtual | 2 weeks | Pass challenge |
| 2 | Apex PA $50k | Virtual | 1 month | Consistent profit |
| 3 | Apex Live $50k | Real ($2.5k risk) | 1 month | No DD breach |
| 4 | Scale to $100k | Real ($5k risk) | Ongoing | Maintain performance |

**Stage 1 → Stage 2 Criteria:**
- Complete Apex Evaluation challenge
- No DD breach
- Meet profit target

**Stage 2 → Stage 3 Criteria:**
- 1 month consistent performance
- Win rate >= 40%
- Sharpe >= 1.0
- No rule violations

**Acceptance Criteria:**
- [ ] Staged plan documented
- [ ] Success criteria defined
- [ ] Rollback triggers defined

---

### Task 08-05: Monitoring Setup

**Status:** Not Started
**Priority:** P1

**Monitoring Components:**
```yaml
monitoring:
  metrics:
    - equity_curve
    - hwm
    - trailing_dd_pct
    - daily_dd_pct
    - trades_today
    - win_rate_rolling

  alerts:
    - type: trailing_dd
      threshold: 3.0
      action: warn
    - type: trailing_dd
      threshold: 4.0
      action: halt
    - type: daily_dd
      threshold: 2.5
      action: reduce_size
    - type: daily_dd
      threshold: 3.0
      action: halt
    - type: stale_data
      threshold: 30s
      action: pause
    - type: network_disconnect
      threshold: 10s
      action: alert

  channels:
    - discord_webhook
    - telegram_bot
    - email (critical only)
```

**Dashboard:**
- Real-time equity curve
- Current DD status (trailing + daily)
- Today's trades
- Factor scores (9 factors)
- System health

**Acceptance Criteria:**
- [ ] Monitoring configured
- [ ] Alerts tested
- [ ] Dashboard operational

---

## Validation

**Final Validation Matrix:**
| Category | Check | Status |
|----------|-------|--------|
| Code | mypy --strict | Pending |
| Code | pytest | Pending |
| Code | CRITIC review | Pending |
| Compliance | SENTINEL approval | Pending |
| Ops | Deployment checklist | Pending |
| Ops | Monitoring setup | Pending |
| Docs | Runbook complete | Pending |

---

## GO/NO-GO Final Decision

**Decision Matrix:**
| Agent | Verdict | Weight |
|-------|---------|--------|
| CRITIC | ? | 30% |
| SENTINEL | ? | 50% |
| Paper Trading Results | ? | 20% |

**Rules:**
- SENTINEL NO-GO = Final NO-GO (veto power)
- CRITIC CRITICAL issues unresolved = NO-GO
- All agents CONDITIONAL = Review conditions, decide

**Final Verdicts:**
| Outcome | Action |
|---------|--------|
| ALL GO | Deploy to Apex Evaluation |
| CONDITIONAL | Address conditions, re-review |
| ANY NO-GO | Return to relevant phase |

---

## Deliverables

1. `orchestration/PHASE_08_CRITIC_REVIEW.md` - CRITIC analysis
2. `orchestration/PHASE_08_SENTINEL_APPROVAL.md` - SENTINEL sign-off
3. `orchestration/DEPLOYMENT_CHECKLIST.md` - Verified checklist
4. `orchestration/PRODUCTION_RUNBOOK.md` - Operational runbook

---

## Exit Criteria

Phase 08 is COMPLETE when:
1. CRITIC review completed with no unresolved CRITICAL
2. SENTINEL approval received
3. Deployment checklist verified
4. Monitoring configured
5. Runbook documented

**Next Step:** Deploy to Apex Evaluation ($50k)

---

## Post-Deployment

After successful deployment:
1. Monitor first 2 weeks closely
2. Daily review of trades
3. Weekly performance report
4. Monthly strategy review
5. Quarterly optimization cycle

**Feedback Loop:**
```
Live Results → Analysis → Adjustments → Backtest → Paper → Live
```

---

## Final Note

> "We've done everything possible to prepare. Now it's time to let the market decide."

The goal is not perfection - it's robust risk management and continuous improvement.

**Total Phase 09 Duration:** 10-12 weeks
**From:** Broken strategy (7 trades, 8 factors dead)
**To:** Production-ready trading system

