# Round 4 Synthesis: MR Viability Deep Analysis

**Date**: 2025-12-24
**Status**: COMPLETE
**Focus**: Determining if Mean Reversion is fundamentally viable for XAUUSD M1

---

## Agent Consensus: UNANIMOUS NO-GO

| Agent | Verdict | Key Reasoning |
|-------|---------|---------------|
| **ARGUS** | CONDITIONAL NO-GO | No academic evidence for gold MR at M1; structural R:R problem |
| **CRUCIBLE** | NOT VIABLE (as primary) | Negative expectancy; regime-fragile; under-sampled |
| **CRITIC** | FALSIFIED | Math doesn't work: needs 55.6% win rate, has 45.5% |

---

## Mathematical Proof of Failure

### Current State
- Win Rate: 45.5%
- R:R Ratio: 0.8:1 (TP 8x ATR / SL 10x ATR)

### Break-Even Calculation
```
E[R] = (WR × TP) - (LR × SL)
E[R] = (0.455 × 8) - (0.545 × 10)
E[R] = 3.64 - 5.45 = -1.81 per unit

Required win rate for break-even at R:R 0.8:
WR_req = SL / (SL + TP) = 10 / (10 + 8) = 55.6%

Current deficit: 55.6% - 45.5% = 10.1% shortfall
```

### Path to Profitability (Unrealistic)
| Fix | Requirement | Difficulty |
|-----|-------------|------------|
| Raise win rate | +10.1% → 55.6% | VERY HARD (already optimized) |
| Fix R:R to 1.2:1 | TP 12x, SL 10x | MODERATE (but changes strategy character) |
| Both partial | WR 50% + R:R 1.0 | Still requires major changes |

---

## Key Research Findings (ARGUS)

1. **Gold is NOT a mean-reverting asset at M1**
   - No academic studies support gold mean reversion at minute timeframes
   - Safari & Schmidhuber (2025): Reversion regime only for WEAK trends; strong deviations (BB extremes) persist

2. **BB + RSI Signal Timing Problem**
   - By the time BB+RSI fire, the move is "statistically significant"
   - Significant moves tend to persist, not revert

3. **M1 Microstructure Issues**
   - High noise-to-signal ratio
   - Transaction costs disproportionately impact short-term MR
   - Hansen & Lunde: High-frequency data has substantial microstructure noise

---

## Strategic Analysis (CRUCIBLE)

1. **Gold is regime-dependent**
   - Trends hard during macro repricing (real yields, DXY, risk-off)
   - Mean-reverts only in range/digestion phases around deep-liquidity windows

2. **M1 is execution timing, not alpha horizon**
   - Pure indicator MR is vulnerable to spread/slippage/latency/stop-runs

3. **Over-filtered but not overfit-proof**
   - Strict filters reduce opportunity (55 trades/2yr) but don't isolate profitable regime

---

## Falsification Verdict (CRITIC)

### Core Assumptions That Are FALSE

1. **"Gold mean-reverts reliably on M1 in a way BB+RSI can capture net of costs"**
   - FALSIFIED: Microstructure + trend/news dominance overwhelms small reversion edges

2. **"Parameter optimization can fix the strategy"**
   - FALSIFIED: The problem is structural (R:R vs win rate), not parametric

### What Would Change This Verdict
- 5+ years, 200+ trades, multiple regimes
- Win rate ≥58-62% at 0.8 R:R, OR 45-50% with R:R ≥1.2
- Stress test: 2-3x spread, 5x slippage doesn't flip expectancy negative
- MC95DD < 4%, no frequent HWM trap events

---

## Recommendations

### Immediate Actions

1. **STOP optimizing MR parameters** - The problem is structural, not parametric
2. **Focus on TrendFollow** - Should be primary strategy for XAUUSD M1

### If MR Must Be Preserved

1. **Structural Redesign Required**:
   - MR entry + TrendFollow exit (partial TP + runner for positive skew)
   - Session restriction: London-NY overlap only
   - Regime gate: Range-only, require Hurst < 0.40

2. **Fastest Falsification Tests**:
   - **Ghost Test**: Random entries with same filters → if similar results, filters are the edge, not signals
   - **Shifted Levels**: Random shift entry levels → if unchanged, entry precision is placebo

### Alternative Strategies (CRUCIBLE)

1. **HTF trend regime + M1 pullback continuation** (TF core)
2. **Liquidity sweep reversal at session extremes** (SMC-style)
3. **Volatility breakout + trailing management** during London/NY

---

## Final Verdict

### MR Strategy Status: **NO-GO (FALSIFIED)**

| Criterion | Status |
|-----------|--------|
| Mathematical expectancy | NEGATIVE |
| Academic support | NONE |
| Optimization potential | EXHAUSTED |
| Structural viability | FLAWED |

### Recommendation

**Suspend MR development. Focus resources on TrendFollow strategy optimization.**

If MR is to be reconsidered in future:
1. Require structural redesign (hybrid MR entry + TF exit)
2. Session/regime gating (London-NY overlap, range regimes only)
3. 5+ year backtest with realistic costs before any live consideration

---

*Round 4 completed by ORCHESTRATOR with ARGUS, CRUCIBLE, CRITIC consensus*
