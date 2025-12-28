---
description: EA optimization planning - parameters, walk-forward, Monte Carlo
argument-hint: <EA name and parameters to optimize>
---

# EA Optimization Protocol

## Optimizing: `$ARGUMENTS`

## Optimization Framework

### 1. Parameter Selection
Identify parameters to optimize:

| Parameter | Current | Min | Max | Step | Rationale |
|-----------|---------|-----|-----|------|-----------|
| [param1] | [val] | [min] | [max] | [step] | [why] |

**Rules:**
- Maximum 3-4 parameters at once
- Avoid over-optimization (curse of dimensionality)
- Each parameter needs 50+ trades to validate

### 2. Optimization Method

**Genetic Algorithm Settings:**
```
Population: 256
Generations: 500
Crossover: 0.9
Mutation: 0.1
```

**Optimization Criteria:**
- Primary: Custom criterion (Balance + Sharpe)
- Avoid: Pure profit maximization (overfitting risk)

### 3. Walk-Forward Analysis

```
Total Period: [X months]
├── Window 1: IS [dates] → OOS [dates]
├── Window 2: IS [dates] → OOS [dates]
├── Window 3: IS [dates] → OOS [dates]
└── Window N: IS [dates] → OOS [dates]

IS/OOS Ratio: 70/30
Minimum WFE Target: 0.6
```

### 4. Robustness Testing

After optimization:
1. **Parameter Sensitivity**: Test ±10% of optimal values
2. **Monte Carlo**: 5000 iterations with resampling
3. **Different Periods**: Test on unseen data
4. **Different Spreads**: Test with higher spread

### 5. Acceptance Criteria

| Metric | Minimum | Target |
|--------|---------|--------|
| WFE | >0.6 | >0.75 |
| OOS Profit Factor | >1.2 | >1.5 |
| OOS Max DD | <12% | <8% |
| Parameter Stability | Low variance | - |

## Output Required

1. **Optimization Plan** (parameters, ranges, method)
2. **Walk-Forward Schedule**
3. **Acceptance Criteria**
4. **Risk Assessment**
5. **Implementation Steps**
