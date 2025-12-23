# PLAN: Phase 06 - Multi-Strategy Backtest

## Metadata
- **Phase:** 06
- **Priority:** P0 - CRITICAL
- **Status:** Not Started
- **Agents:** 2 ORACLE (opus) + 1 DAEMON (opus)
- **Depends On:** Phase 05 Complete
- **Final Gate:** User approval for production

---

## Objective

Validar o sistema completo com múltiplas estratégias ativas. Comparar performance individual vs combinada. Verificar que o portfolio de estratégias é superior a qualquer estratégia isolada.

---

## Test Configurations

| Config | Selector | Router | Strategies |
|--------|----------|--------|------------|
| A | Off | Off | SMC only |
| B | Off | Off | TrendFollow only |
| C | Off | Off | MeanRevert only (if implemented) |
| D | On | Off | All via Selector |
| E | On | On | All via Selector + Router |

---

## Tasks

### Task 06-01: Individual Strategy Baselines

**Status:** Not Started

**Action:** Run separate backtests for each strategy in isolation.

**Config A: SMC Only**
```python
config = {
    "use_selector": False,
    "router_adaptive_ev": False,
    "force_strategy": "SMC_SCALPER",
    "enable_trend_follow": False,
}
```

**Config B: TrendFollow Only**
```python
config = {
    "use_selector": False,
    "router_adaptive_ev": False,
    "force_strategy": "TREND_FOLLOW",
    "enable_smc": False,
}
```

**Config C: MeanRevert Only (if implemented)**
```python
config = {
    "use_selector": False,
    "router_adaptive_ev": False,
    "force_strategy": "MEAN_REVERT",
    "enable_smc": False,
    "enable_trend_follow": False,
}
```

**Dataset:** `data/raw/full_parquet/xauusd_2003_2025_stride20_full.parquet`

**Output per Config:**
| Metric | SMC | TrendFollow | MeanRevert |
|--------|-----|-------------|------------|
| Total Trades | | | |
| Win Rate | | | |
| Profit Factor | | | |
| Total Profit | | | |
| Max Drawdown | | | |
| WFE | | | |
| SQN | | | |
| PSR | | | |
| MC95DD | | | |

**Acceptance Criteria:**
- [ ] Each strategy backtested individually
- [ ] Metrics recorded
- [ ] Baseline established for comparison

---

### Task 06-02: Combined Strategies - Selector Only

**Status:** Not Started

**Config D: Selector Active, Router Off**
```python
config = {
    "use_selector": True,
    "router_adaptive_ev": False,
    "enable_trend_follow": True,
    "enable_mean_revert": True,  # if implemented
}
```

**Verification Points:**
1. Selector switches between strategies based on regime
2. Each strategy gets trades when its regime is detected
3. No single strategy dominates unfairly

**Analysis:**
```python
# Trade distribution by strategy
strategy_distribution = {
    "SMC_SCALPER": count_trades_smc,
    "TREND_FOLLOW": count_trades_tf,
    "MEAN_REVERT": count_trades_mr,
}

# Profit distribution by strategy
profit_by_strategy = {
    "SMC_SCALPER": total_profit_smc,
    "TREND_FOLLOW": total_profit_tf,
    "MEAN_REVERT": total_profit_mr,
}
```

**Output:**
| Metric | Value |
|--------|-------|
| Total Trades | |
| Trade Distribution | SMC: X%, TF: Y%, MR: Z% |
| Win Rate | |
| Total Profit | |
| Profit by Strategy | SMC: $X, TF: $Y, MR: $Z |
| Max Drawdown | |
| WFE | |
| SQN | |

**Acceptance Criteria:**
- [ ] Selector switches correctly
- [ ] All strategies contribute trades
- [ ] Metrics recorded

---

### Task 06-03: Combined Strategies - Router Active

**Status:** Not Started

**Config E: Selector + Router Active**
```python
config = {
    "use_selector": True,
    "router_adaptive_ev": True,
    "enable_trend_follow": True,
    "enable_mean_revert": True,
}
```

**Verification Points:**
1. Router learns and improves selection over time
2. Thompson sampling converges to better arms
3. DD penalty affects selection during drawdowns

**Analysis:**
```python
# Arm selection evolution
# First 100 trades: should be exploratory
# Last 100 trades: should favor better arms

# Learning curve
arm_win_rates_over_time = {
    "SMC": [...],
    "TREND_PULLBACK": [...],
    "TREND_BREAKOUT": [...],
}
```

**Output:**
| Metric | Value |
|--------|-------|
| Total Trades | |
| Arm Distribution | SMC: X%, PB: Y%, BO: Z% |
| Win Rate | |
| Total Profit | |
| Max Drawdown | |
| WFE | |
| SQN | |
| Learning Improvement | First 100 vs Last 100 trades |

**Acceptance Criteria:**
- [ ] Router learns over time
- [ ] Better arms selected more often
- [ ] Metrics recorded

---

### Task 06-04: Comparison Analysis

**Status:** Not Started

**Master Comparison Table:**

| Config | Trades | Win% | Profit | MaxDD | WFE | SQN | PSR |
|--------|--------|------|--------|-------|-----|-----|-----|
| A: SMC only | | | | | | | |
| B: TrendFollow only | | | | | | | |
| C: MeanRevert only | | | | | | | |
| D: Combined (Selector) | | | | | | | |
| E: Combined (Router) | | | | | | | |

**Analysis Questions:**

1. **Diversification Benefit:**
   - Is Combined >= best individual?
   - If yes, by how much?
   - If no, why?

2. **Strategy Contribution:**
   - Do all strategies contribute?
   - Any strategy consistently negative?
   - Should any be removed?

3. **Drawdown Reduction:**
   - Is combined DD lower than individual?
   - Does diversification help?

4. **Router Value:**
   - Is E better than D?
   - Does learning add value?
   - Or is simpler Selector enough?

**Deliverable:** `MULTI_STRATEGY_COMPARISON.md`

**Acceptance Criteria:**
- [ ] All configs compared
- [ ] Analysis questions answered
- [ ] Clear recommendation

---

### Task 06-05: DAEMON Strategic Review

**Status:** Not Started

**DAEMON Questions:**

1. **Is multi-strategy the right approach?**
   - Or should we focus on one best strategy?
   - What does institutional practice suggest?

2. **Are we over-engineering?**
   - Selector + Router + multiple strategies
   - Is complexity justified by performance?

3. **Risk-adjusted view:**
   - Which config has best Sharpe?
   - Which has best risk-adjusted return?

4. **Operational considerations:**
   - More strategies = more complexity
   - More things that can break
   - Worth it?

**Deliverable:** `orchestration/DAEMON_STRATEGIC_REVIEW.md`

---

### Task 06-06: Final GO/NO-GO

**Status:** Not Started

**Decision Criteria:**

```
GO for Production if ALL are true:
1. Combined >= best individual (diversification benefit)
2. All active strategies contribute trades (no dead weight)
3. No single strategy dominates unfairly (>80% of trades)
4. Drawdown reduced vs single strategy
5. WFE >= 0.6, SQN >= 2.0, PSR >= 0.85
6. MC95DD < 4% (Apex compliant)
7. DAEMON recommends GO

CONDITIONAL GO if:
- Some metrics slightly below threshold
- Clear path to improvement identified
- User accepts risk

NO-GO if:
- Combined worse than best individual
- Critical metrics failed
- DAEMON recommends NO-GO
```

**Final Recommendation Format:**
```markdown
# Phase 06 Final Recommendation

## Verdict: [GO / CONDITIONAL GO / NO-GO]

## Summary
[1-2 paragraphs explaining the decision]

## Evidence
- Best config: [X] with [metrics]
- Diversification benefit: [X%]
- Risk reduction: [X%]
- Key strengths: [...]
- Key weaknesses: [...]

## Recommended Production Config
[If GO: exact config to deploy]

## Open Items
[If CONDITIONAL GO: what needs to be addressed]

## Next Steps
[What happens after this decision]
```

---

## Execution Order

```
06-01 (Baselines) ─────→ [ORACLE 1]
        ↓
06-02 (Selector) ─────→ [ORACLE 1]
        ↓
06-03 (Router) ────────→ [ORACLE 2]
        ↓
06-04 (Comparison) ───→ [ORACLE 2]
        ↓
06-05 (DAEMON) ────────→ [DAEMON]
        ↓
06-06 (GO/NO-GO) ─────→ [Human Decision]
```

**Note:** ORACLE 1 and ORACLE 2 can run in parallel for baselines.

---

## Phase Completion Checklist

- [ ] All individual baselines completed
- [ ] Selector-only config tested
- [ ] Router config tested
- [ ] Comparison analysis done
- [ ] DAEMON strategic review complete
- [ ] Final GO/NO-GO decision made
- [ ] User approval obtained

---

## Deliverables

1. `orchestration/BASELINE_RESULTS.md` - Individual strategy results
2. `orchestration/SELECTOR_RESULTS.md` - Config D results
3. `orchestration/ROUTER_RESULTS.md` - Config E results
4. `MULTI_STRATEGY_COMPARISON.md` - Master comparison
5. `orchestration/DAEMON_STRATEGIC_REVIEW.md` - Strategic analysis
6. `orchestration/PHASE_06_FINAL_DECISION.md` - GO/NO-GO

---

## Exit Criteria

Phase 06 is COMPLETE when:
1. All configurations backtested
2. Comparison analysis complete
3. DAEMON strategic review complete
4. User makes final GO/NO-GO decision
5. If GO: production config documented

---

## Post-Phase Actions

**If GO:**
1. Document production config
2. Create deployment checklist
3. Plan paper trading phase
4. Schedule live deployment

**If NO-GO:**
1. Document failure reasons
2. Create remediation plan
3. Return to relevant phase
4. Re-run validation

---

## Success Metrics (Final)

| Metric | Threshold | Required |
|--------|-----------|----------|
| WFE | >= 0.6 | Yes |
| SQN | >= 2.0 | Yes |
| PSR | >= 0.85 | Yes |
| MC95DD | < 4% | Yes |
| Min Trades | >= 200 | Yes |
| Multi-strategy benefit | >= 0% | Yes |
| Strategy contribution | All active | Yes |
