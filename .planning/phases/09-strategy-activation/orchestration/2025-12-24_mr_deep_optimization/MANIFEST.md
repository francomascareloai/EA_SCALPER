# MR Deep Optimization - 10 Rounds Analysis

**Date:** 2025-12-24
**Objective:** Transform Mean Revert from NO-GO to viable strategy
**Focus:** Genius-level optimization, unexplored factors, blind spots

---

## Problem Statement

ORACLE-1 extended backtest showed:
- 68 trades over 2 years
- Sharpe: -0.47, SQN: -0.25
- Negative expectancy: -$11.45/trade
- Inverted R:R: Avg loss 3.4x avg win

**Hypothesis:** Strategy failed due to lack of optimization, not fundamental flaw.

---

## Round Structure

| Round | Focus | Agents |
|-------|-------|--------|
| 1-2 | Fundamental Analysis | ARGUS, CRUCIBLE, CRITIC |
| 3-4 | Parameter Optimization | FORGE, CRUCIBLE, SENTINEL |
| 5-6 | Risk/Reward Architecture | SENTINEL, CRITIC, FORGE |
| 7-8 | Market Context | ARGUS, CRUCIBLE, SENTINEL |
| 9-10 | Synthesis & Design | ALL |

---

## Current MR Implementation

```python
# mean_revert.py - Current Implementation
- BB Period: 20
- BB StdDev: 2.0
- RSI Period: 14 (Wilder)
- RSI Oversold: 30
- RSI Overbought: 70
- Min Score Threshold: 65

# Scoring Components:
1. BB Position (0-40 pts)
2. RSI Divergence (0-30 pts)
3. Volume Profile (0-20 pts)
4. Session Weight (0-10 pts)
```

---

## Key Questions to Answer

1. **Parameters**: Are BB/RSI settings optimal for XAUUSD volatility?
2. **Indicators**: What are we missing? (ATR, VWAP, order flow, market depth)
3. **Entry Logic**: Is confluence scoring weighted correctly?
4. **Exit Logic**: Why are losers 3.4x winners? Exit too late?
5. **Filters**: What should block trades? (news, spread, volatility)
6. **Regime**: Does MR work in all regimes or only specific ones?
7. **Sessions**: Which sessions favor MR? Asian vs London vs NY?
8. **Risk**: Can scale-out/partial TP fix the R:R problem?
9. **Timing**: Entry timing - wait for confirmation or enter immediately?
10. **Synergy**: How should MR interact with TF signals?

---

## Round Outputs

- round_01/: [pending]
- round_02/: [pending]
- round_03/: [pending]
- round_04/: [pending]
- round_05/: [pending]
- round_06/: [pending]
- round_07/: [pending]
- round_08/: [pending]
- round_09/: [pending]
- round_10/: [pending]
- synthesis/: [pending]

---

*Created: 2025-12-24*
