# Incident Response Playbooks

> **Purpose**: Playbooks for handling critical incidents during live trading

## NETWORK_DISCONNECT

**Trigger**: Data feed or broker connection lost for >10 seconds
**Severity**: CRITICAL

### Immediate Actions
1. HALT all new trade entries immediately
2. Attempt reconnection with exponential backoff (1s, 2s, 4s, 8s, 16s)
3. If reconnection fails after 30s: trigger EMERGENCY_CLOSE playbook
4. Log disconnect timestamp, duration, and any data gaps

### Post Recovery
- Reconcile local state with broker state
- Verify no phantom positions exist
- Check for missed fills during disconnect

---

## EMERGENCY_CLOSE

**Trigger**: Time gate (4:55 PM ET) OR network disconnect >30s OR trailing DD ≥4.0%
**Severity**: CRITICAL

### Immediate Actions
1. Submit market close orders for ALL open positions
2. Confirm each close order acknowledged (retry up to 3x with 2s delay)
3. If any order not acknowledged after 3 retries: continue to next position
4. Set trading halted flag (prevent any new orders)
5. Log all order statuses: CLOSED / PENDING / FAILED

### Fail-Closed Behavior (CRITICAL)

| Condition | Actions |
|-----------|---------|
| Approaching close (after 4:50 PM ET) AND broker unreachable | Trigger at 4:50 PM, retry every 5s until 4:59 PM, log DEGRADED_EMERGENCY_CLOSE |
| Broker unreachable AND positions open at 4:58 PM | CRITICAL ALERT (SMS+Email+Push to Franco), log FAILED_EMERGENCY_CLOSE with position details |
| DD breach but broker unreachable | Log DD_BREACH_UNRECOVERABLE, continue retry loop, execute close when restored |

### Human Escalation
- **Channels**: SMS + Telegram + Email (all simultaneously)
- **When**: After 3 failed retries OR positions still open at 4:58 PM OR trailing DD ≥4.5%
- **Template**: `EMERGENCY: [N] positions open, broker [status], DD [X]%, time [HH:MM ET]`

---

## DD_BREACH

**Trigger**: Drawdown exceeds threshold (reference `dd_limits.taxonomy`)

### Trailing DD Severity Matrix (from HWM - APEX KILLER)

| Level | Threshold | Action |
|-------|-----------|--------|
| WARN | 3.0% | Log + continue with reduced sizing |
| CAUTION | 3.5% | Log + reduce position size by 50% |
| CRITICAL | 4.0% | Close half of open positions + alert |
| HALT | 4.5% | Execute EMERGENCY_CLOSE immediately |

### Daily DD Severity Matrix (from session start)

| Level | Threshold | Action |
|-------|-----------|--------|
| WARN | 1.5% | Log |
| CAUTION | 2.0% | Reduce sizing |
| REDUCE | 2.5% | Reduce position size by 50% |
| HALT | 3.0% | No new trades, monitor existing |

**Rule**: Always use the MORE RESTRICTIVE action between trailing and daily DD
**Post-Incident**: Review all trades since last good state; identify root cause

---

## STALE_DATA

**Trigger**: No new ticks for threshold period during market hours
**Severity**: HIGH

### Regime-Aware Thresholds

| Session | Hours | Threshold |
|---------|-------|-----------|
| US_ACTIVE | 9:30-16:00 ET | 5 seconds |
| OVERNIGHT | 18:00-9:30 ET | 15 seconds |
| LOW_LIQUIDITY | weekends/holidays | 30 seconds |

*Note: MGC/Gold futures may have natural gaps - adjust based on observed feed cadence*

### Immediate Actions
1. HALT new trade entries
2. Mark current prices as STALE in UI/logs
3. Do NOT use stale prices for DD/HWM calculations - freeze at last known good
4. If persists >30s during US_ACTIVE: trigger NETWORK_DISCONNECT

### HWM Behavior When Stale
- Do NOT update HWM with stale prices
- Keep DD calculation frozen at last known good state
- When fresh data arrives: immediately recalculate with conservative pricing

---

## POSITION_MISMATCH

**Trigger**: Local position state differs from broker reported state
**Severity**: HIGH

### Immediate Actions
1. HALT all trading immediately
2. Log both local and broker states
3. Trust broker state as source of truth
4. Reconcile and correct local state
5. Investigate cause before resuming

---

## Escalation Contacts

| Role | Contact |
|------|---------|
| Primary | Franco (owner) - phone/telegram |
| Fallback | Automated SMS/email alert service |

*Note: Define actual contacts before go-live*
