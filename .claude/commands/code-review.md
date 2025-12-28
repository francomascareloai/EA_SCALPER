---
description: Code review for MQL5/Python trading code
argument-hint: <file path or component>
---

# Trading Code Review

## Reviewing: `$ARGUMENTS`

## Review Checklist

### 1. Correctness
- [ ] Logic is mathematically sound
- [ ] Edge cases handled
- [ ] No off-by-one errors
- [ ] Correct data types used

### 2. Risk Management
- [ ] Stop-loss always set
- [ ] Position sizing correct
- [ ] Drawdown limits enforced
- [ ] No unlimited risk exposure

### 3. Performance
- [ ] Efficient tick processing
- [ ] No unnecessary calculations
- [ ] Proper caching of indicators
- [ ] Memory management

### 4. MQL5 Specifics
- [ ] Proper use of CTrade
- [ ] Magic number handling
- [ ] Symbol validation
- [ ] Spread/slippage consideration

### 5. Error Handling
- [ ] Trade execution errors caught
- [ ] Network failures handled
- [ ] Invalid data protection
- [ ] Graceful degradation

### 6. FTMO Compliance
- [ ] Daily DD check before trade
- [ ] Total DD check before trade
- [ ] Proper lot sizing
- [ ] No prohibited patterns

## Output Format

```
CODE REVIEW: [file]
==================

SEVERITY: [CRITICAL/HIGH/MEDIUM/LOW]

ISSUES:
🔴 Critical: [issue]
🟠 High: [issue]
🟡 Medium: [issue]
🔵 Low: [issue]

POSITIVES:
✅ [good practice found]

RECOMMENDATIONS:
1. [specific fix]
2. [specific fix]

VERDICT: [APPROVE/NEEDS CHANGES/REJECT]
```
