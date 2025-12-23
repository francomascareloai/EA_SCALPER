# PLAN: Phase 07 - Paper Trading

## Metadata
- **Phase:** 07
- **Priority:** P0 - CRITICAL (Pre-Live Validation)
- **Status:** Not Started
- **Agents:** FORGE (implementation) + ORACLE (monitoring) + SENTINEL (compliance)
- **Depends On:** Phase 06 (Multi-Strategy Backtest PASS)
- **Duration:** 2 weeks minimum

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

**NOTA: Esta fase requer testes em tempo real com dados LIVE (paper trading)**

---

## Objective

Validate the strategy on LIVE data feed without risking real money. This is the final gate before production deployment.

> "Paper trading is the rehearsal before the performance. Skip it at your peril."

---

## Prerequisites

| Requirement | Source | Status |
|-------------|--------|--------|
| Multi-strategy backtest PASS | Phase 06 | Pending |
| WFE >= 0.6 on holdout | Phase 06 | Pending |
| MC95DD < 4% | Phase 06 | Pending |
| PBO < 25% | Phase 06 | Pending |
| DSR > 0 | Phase 06 | Pending |

---

## Tasks

### Task 07-01: Paper Trading Infrastructure

**Status:** Not Started
**Priority:** P0

**Implementation:**
```python
# Paper trading configuration
paper_config = BacktestEngineConfig(
    trader_id=TraderId("PAPER-001"),
    logging=LoggingConfig(log_level="INFO"),
    exec_engine=LiveExecEngineConfig(
        reconciliation=True,
        reconciliation_lookback_mins=1440,
    ),
)

# Use LIVE data feed, paper execution
data_config = LiveDataClientConfig(
    instrument_provider=InstrumentProviderConfig(load_all=True),
    # Real-time data from broker
)
```

**Requirements:**
- Connect to LIVE data feed (not historical replay)
- Paper execution (no real orders)
- Track unrealized PnL exactly as Apex would
- Log all trade signals, entries, exits

**Acceptance Criteria:**
- [ ] Paper trading environment configured
- [ ] Connected to live data feed
- [ ] Trades logged with full detail

---

### Task 07-02: Execution Mode Testing

**Status:** Not Started
**Priority:** P0

**Test Both Modes:**

| Mode | Use Case | Test Duration |
|------|----------|---------------|
| AUTO | Full automation (Evaluation accounts) | 1 week |
| SIGNAL_ONLY | Alert generation (PA/Live accounts) | 1 week |

**AUTO Mode Test:**
```python
execution_config = {
    "mode": "AUTO",
    "auto_execute": True,
    "send_alerts": True,
    "apex_compliance": True,
}
```

**SIGNAL_ONLY Mode Test:**
```python
execution_config = {
    "mode": "SIGNAL_ONLY",
    "auto_execute": False,
    "send_alerts": True,
    "alert_channels": ["discord", "telegram"],
}
```

**Acceptance Criteria:**
- [ ] AUTO mode executes trades correctly
- [ ] SIGNAL_ONLY mode sends alerts without executing
- [ ] Both modes respect time gates (4:30 PM block, 4:55 PM close)

---

### Task 07-03: Time Gate Verification

**Status:** Not Started
**Priority:** P0 (Apex Compliance)

**Critical Time Points:**
| Time (ET) | Action | Verification |
|-----------|--------|--------------|
| 4:30 PM | Block new trades | No new positions opened |
| 4:55 PM | Emergency force-close | All positions closed |
| 5:00 PM | Session end | Zero exposure |

**Test Scenarios:**
1. **Normal close:** Position in profit at 4:30 PM - verify graceful exit
2. **Emergency close:** Position open at 4:55 PM - verify force-close
3. **Edge case:** Order submitted at 4:29:59 PM - verify block

**Verification Script:**
```python
def verify_time_gates(trades_log: list[Trade]) -> bool:
    for trade in trades_log:
        entry_time = trade.entry_time.astimezone(ET)
        if entry_time.hour == 16 and entry_time.minute >= 30:
            return False  # FAIL: trade opened after 4:30 PM

        if trade.exit_time is None:
            exit_time = datetime.now(ET)
            if exit_time.hour >= 17:
                return False  # FAIL: position held overnight

    return True
```

**Acceptance Criteria:**
- [ ] No trades opened after 4:30 PM ET
- [ ] All positions closed by 4:59 PM ET
- [ ] Emergency close executes within latency budget (<500ms)

---

### Task 07-04: HWM Tracking Verification

**Status:** Not Started
**Priority:** P0 (Apex Compliance)

**HWM Trap Awareness:**
```python
# Correct HWM calculation
def update_hwm(self, current_equity: Decimal, unrealized_pnl: Decimal) -> None:
    """
    HWM = max(HWM, current_equity + unrealized_pnl)

    WARNING: Unrealized profit raises HWM PERMANENTLY.
    If trade reverses, trailing DD is calculated from peak.
    """
    total_equity = current_equity + unrealized_pnl
    self._hwm = max(self._hwm, total_equity)

    # Calculate trailing DD from HWM
    self._trailing_dd_pct = (self._hwm - total_equity) / self._hwm * 100

    if self._trailing_dd_pct >= 4.0:
        self._trigger_halt("Trailing DD >= 4%")
```

**Verification:**
1. Track HWM tick-by-tick during paper trading
2. Verify HWM never decreases
3. Confirm trailing DD calculated correctly
4. Test HWM protection (scale-out on winners)

**Acceptance Criteria:**
- [ ] HWM tracked correctly
- [ ] Trailing DD calculated from HWM
- [ ] Scale-out logic triggers at +1R, +2R

---

### Task 07-05: Failure Mode Verification

**Status:** Not Started
**Priority:** P1

**Verify Top 10 Failure Modes:**
| # | Failure Mode | Test | Expected Behavior |
|---|--------------|------|-------------------|
| 1 | Network disconnect | Kill connection mid-trade | Reconnect + verify position |
| 2 | Stale data | Pause data feed 30s | Alert + pause trading |
| 3 | DD breach (4%) | Simulate 4% loss | HALT all trading |
| 4 | Bracket SL canceled | Cancel SL order | Emergency close triggered |
| 5 | Position mismatch | Desync internal state | Reconciliation + alert |
| 6 | Time gate miss | Simulate clock drift | Earlier close triggered |
| 7 | Order rejection | Reject market order | Log + alert |
| 8 | Spread spike | 5x normal spread | Skip entry |
| 9 | HWM trap | 3% unrealized, then -2% | HALT before Apex limit |
| 10 | Emergency close fail | Close order timeout | Retry + market order |

**Acceptance Criteria:**
- [ ] All 10 failure modes tested
- [ ] Correct behavior in each case
- [ ] No Apex limit breaches

---

### Task 07-06: Daily Monitoring Protocol

**Status:** Not Started
**Priority:** P1

**Daily Checklist:**
```markdown
## Daily Paper Trading Review

### Pre-Session (Before 9:30 AM ET)
- [ ] System connected to data feed
- [ ] Time sync verified (NTP)
- [ ] Account state reconciled
- [ ] DD limits initialized

### During Session
- [ ] Monitor factor scores
- [ ] Track trade signals
- [ ] Verify time gates
- [ ] Check HWM updates

### Post-Session (After 5:00 PM ET)
- [ ] All positions closed
- [ ] Daily PnL recorded
- [ ] Trade log exported
- [ ] Anomalies documented
```

**Metrics to Track:**
| Metric | Target | Action if Missed |
|--------|--------|------------------|
| Trades/day | 1-5 | Investigate if 0 |
| Win rate | >= 40% | Review after 20 trades |
| Avg R:R | >= 2:1 | Adjust TP/SL |
| Max DD (day) | < 3% | Reduce size next day |
| Factor firing | All 9 score > 0 | Debug specific factor |

**Acceptance Criteria:**
- [ ] Monitoring protocol documented
- [ ] Daily review template created
- [ ] Metrics dashboard configured

---

## Validation

**Week 1 Checkpoints:**
- [ ] System runs 5 full sessions without crash
- [ ] Time gates verified working
- [ ] HWM tracking accurate
- [ ] All 9 factors fire at least once

**Week 2 Checkpoints:**
- [ ] >= 10 paper trades executed
- [ ] Win rate tracked
- [ ] PnL curve reasonable
- [ ] No Apex compliance violations

---

## GO/NO-GO Criteria

| Criterion | Threshold | Weight |
|-----------|-----------|--------|
| Sessions without crash | >= 10 | CRITICAL |
| Time gate violations | 0 | CRITICAL |
| HWM tracking correct | 100% | CRITICAL |
| Failure modes handled | >= 8/10 | HIGH |
| Factor coverage | >= 7/9 | MEDIUM |

**Decision:**
| Outcome | Action |
|---------|--------|
| All CRITICAL pass | Proceed to Phase 08 |
| 1 CRITICAL fail | Fix and extend paper trading |
| Multiple CRITICAL fail | Return to Phase 06 |

---

## Deliverables

1. `orchestration/PHASE_07_PAPER_TRADING.md` - Full report
2. `orchestration/PAPER_TRADING_LOG.csv` - All paper trades
3. `orchestration/FAILURE_MODE_TESTS.md` - Test results

---

## Exit Criteria

Phase 07 is COMPLETE when:
1. 2 weeks of paper trading completed
2. All CRITICAL criteria pass
3. No Apex compliance violations
4. Failure modes verified
5. ORACLE validates results

**Next Phase:** Phase 08 - Production Readiness

