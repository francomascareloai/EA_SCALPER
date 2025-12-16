# PLAN: Phase 03 - Risk Modules Audit

## Objective
Deep critical analysis of all risk management modules to ensure Apex compliance, correct DD tracking, and proper circuit breaker behavior.

## Files Under Review

| File | Lines | Apex Relevance |
|------|-------|----------------|
| `circuit_breaker.py` | 540 | Loss limits, cooldowns |
| `consistency_tracker.py` | 61 | 30% rule |
| `dd_protection.py` | 298 | DD limit enforcement |
| `drawdown_tracker.py` | 358 | DD calculation (CRITICAL) |
| `position_sizer.py` | 397 | Lot sizing |
| `prop_firm_manager.py` | 279 | Apex rules orchestration |
| `spread_monitor.py` | 525 | Spread tracking |
| `time_constraint_manager.py` | 108 | Time gates (CRITICAL) |
| `var_calculator.py` | 347 | Value at Risk |

**Total:** ~2,913 lines

## Execution Plan

### Parallel Agent Assignment

**Agent A (SENTINEL):** DD and Protection Stack
- `drawdown_tracker.py` - CRITICAL
- `dd_protection.py`
- `prop_firm_manager.py`
- ~935 lines

**Agent B (SENTINEL):** Circuit Breaker and Time Gates
- `circuit_breaker.py`
- `time_constraint_manager.py`
- `consistency_tracker.py`
- ~709 lines

**Agent C (SENTINEL):** Sizing and Monitoring
- `position_sizer.py`
- `spread_monitor.py`
- `var_calculator.py`
- ~1,269 lines

## APEX COMPLIANCE VERIFICATION (MANDATORY)

### Rule 1: Trailing Drawdown = 5% from HIGH-WATER MARK
**Critical Questions:**
- Is DD calculated from HIGH-WATER MARK (not initial balance)?
- Does HIGH-WATER MARK include unrealized P&L?
- Is trailing mechanism correctly implemented?
- Reset behavior on new high?

### Rule 2: No Overnight Positions
**Critical Questions:**
- Is 4:59 PM ET cutoff enforced?
- What happens if close fails?
- Market order vs limit for emergency close?
- Weekend/holiday handling?

### Rule 3: Time Gates
**Critical Questions:**
- 4:30 PM ET: Block new trades?
- 4:55 PM ET: Emergency close initiated?
- Timezone handling (ET with DST)?
- What if position entry at 4:29 PM, still open?

### Rule 4: Max 30% Profit in Single Day
**Critical Questions:**
- How is daily profit calculated?
- Is this hard block or warning?
- Reset timing (midnight ET)?
- What happens at 29.5%?

### Rule 5: DD Safety Buffers
**Critical Questions:**
- Trailing DD ≥4.0% → HALT?
- Total DD ≥4.5% → HALT?
- HALT = no new trades + close existing?
- Recovery mechanism?

## CRITIC Checklist per Module

### drawdown_tracker.py (CRITICAL)
| Check | Status |
|-------|--------|
| Uses HIGH-WATER MARK, not initial balance | ⬜ |
| Includes unrealized P&L in HWM | ⬜ |
| Trailing mechanism correct | ⬜ |
| Reset on new high correct | ⬜ |
| Edge: rapid gain then loss | ⬜ |
| Edge: gap open against position | ⬜ |
| Thread-safe if multi-threaded | ⬜ |

### time_constraint_manager.py (CRITICAL)
| Check | Status |
|-------|--------|
| Timezone = ET (America/New_York) | ⬜ |
| DST transitions handled | ⬜ |
| 4:30 PM warning implemented | ⬜ |
| 4:55 PM emergency close | ⬜ |
| 4:59 PM hard cutoff | ⬜ |
| Edge: position opened at 4:29:59 | ⬜ |

### circuit_breaker.py
| Check | Status |
|-------|--------|
| Level 1: 3 losses → 5min cooldown | ⬜ |
| Level 2: 5 losses → 15min + size reduction | ⬜ |
| Level 3: 3% DD → 30min cooldown | ⬜ |
| Level 4: 4% DD → day halt | ⬜ |
| Level 5: 4.5% DD → terminated | ⬜ |
| Escalation logic correct | ⬜ |
| Recovery/reset mechanism | ⬜ |

### position_sizer.py
| Check | Status |
|-------|--------|
| Risk per trade configurable | ⬜ |
| Uses current equity (not balance) | ⬜ |
| Respects CB size reduction | ⬜ |
| Min/max lot limits | ⬜ |
| Spread impact on sizing | ⬜ |

### prop_firm_manager.py
| Check | Status |
|-------|--------|
| Orchestrates all rules | ⬜ |
| Priority: DD > Time > Consistency | ⬜ |
| HALT state management | ⬜ |
| Rule violation logging | ⬜ |

### spread_monitor.py
| Check | Status |
|-------|--------|
| Spread calculation correct | ⬜ |
| Historical tracking working | ⬜ |
| Warning/block thresholds | ⬜ |
| Impact on trade decisions | ⬜ |

### var_calculator.py
| Check | Status |
|-------|--------|
| VaR calculation method | ⬜ |
| Confidence level (95%? 99%?) | ⬜ |
| Integration with sizing | ⬜ |
| Historical data requirements | ⬜ |

### consistency_tracker.py
| Check | Status |
|-------|--------|
| 30% daily profit cap | ⬜ |
| Calculation method | ⬜ |
| Action when exceeded | ⬜ |

### dd_protection.py
| Check | Status |
|-------|--------|
| Integration with tracker | ⬜ |
| Protection actions correct | ⬜ |
| Recovery handling | ⬜ |

## Success Criteria
- [ ] All 9 risk modules reviewed
- [ ] All 5 Apex rules verified
- [ ] DD calculation confirmed correct
- [ ] Time gate logic verified
- [ ] Circuit breaker escalation correct
- [ ] `PHASE_03_FINDINGS.md` completed

## Agents

**3 parallel SENTINEL agents (model: opus)**
- Each handles 2-3 modules
- Must apply CRITIC self-review internally
- Must verify Apex compliance explicitly

## Output
`PHASE_03_FINDINGS.md` in this directory
