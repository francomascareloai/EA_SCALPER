---
description: Validate EA/strategy for FTMO prop firm compliance
argument-hint: <EA name or backtest results>
---

# FTMO Compliance Validator

## Validating: `$ARGUMENTS`

## FTMO Challenge Requirements

### Phase 1: Challenge (30 days)
| Requirement | Value | Status |
|-------------|-------|--------|
| Profit Target | 10% | [ ] |
| Max Daily Loss | 5% | [ ] |
| Max Total Loss | 10% | [ ] |
| Min Trading Days | 4 | [ ] |

### Phase 2: Verification (60 days)
| Requirement | Value | Status |
|-------------|-------|--------|
| Profit Target | 5% | [ ] |
| Max Daily Loss | 5% | [ ] |
| Max Total Loss | 10% | [ ] |
| Min Trading Days | 4 | [ ] |

## Compliance Checklist

### Risk Management
- [ ] Hard stop-loss on every trade
- [ ] Daily drawdown protection logic
- [ ] Position sizing respects risk limits
- [ ] No martingale or grid without limits
- [ ] Weekend position handling

### Prohibited Strategies
- [ ] No high-frequency tick scalping
- [ ] No latency arbitrage
- [ ] No copy trading from other accounts
- [ ] No hedging across accounts

### Best Practices for FTMO
- [ ] Risk per trade: 0.5-1% recommended
- [ ] Target R:R ratio: minimum 1:1.5
- [ ] Avoid trading during major news (optional)
- [ ] Consistent lot sizing

## Analysis Required

1. **Backtest the strategy** with FTMO constraints:
   - Starting balance: $100,000 (or challenge size)
   - Apply 5% daily DD limit
   - Apply 10% total DD limit

2. **Calculate probability of passing**:
   - P(10% profit in 30 days)
   - P(never hitting 5% daily DD)
   - P(never hitting 10% total DD)

3. **Monte Carlo with FTMO constraints**:
   - Run 10,000 simulations
   - Count pass/fail scenarios
   - Calculate expected attempts to pass

## Output Required

```
FTMO COMPLIANCE REPORT
======================
Strategy: [name]
Account Size: $[X]

VERDICT: [COMPLIANT / NON-COMPLIANT / NEEDS ADJUSTMENT]

Pass Probability: [X]%
Expected Attempts: [X]
Risk Assessment: [LOW/MEDIUM/HIGH]

Issues Found:
- [issue 1]
- [issue 2]

Recommendations:
- [recommendation 1]
- [recommendation 2]
```
