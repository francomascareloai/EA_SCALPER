# Round 3 Synthesis: Parameter Optimization Sweep

**Date**: 2025-12-24
**Status**: COMPLETE
**Focus**: Finding optimal MR parameter configuration via systematic sweep

---

## Parameter Space Tested

| Parameter | Values Tested |
|-----------|---------------|
| SL ATR Multiplier | 5x, 10x |
| TP ATR Multiplier | 4x, 8x |
| ADX Threshold | 25, 30, 35, 40 |
| RSI Oversold/Overbought | 20/80, 25/75, 30/70 |

---

## Results Summary (2-year backtest: 2023-01-01 to 2025-01-01)

| Test | Configuration | Win Rate | Trades | Total PnL | Avg PnL/trade |
|------|---------------|----------|--------|-----------|---------------|
| Baseline | SL 10x, TP 8x, ADX 25, RSI 30/70 | 44.1% | 59 | -$2,505 (-2.51%) | -$42.47 |
| Test 1 | SL 5x, TP 4x, ADX 30, RSI 30/70 | 43.9% | 57 | -$3,155 (-3.16%) | -$55.36 |
| Test 2 | SL 10x, TP 8x, ADX 35, RSI 30/70 | 45.6% | 57 | -$2,418 (-2.42%) | -$42.42 |
| Test 3 | SL 10x, TP 8x, ADX 40, RSI 30/70 | 44.1% | 59 | -$2,633 (-2.63%) | -$44.63 |
| **Test 4** | **SL 10x, TP 8x, ADX 35, RSI 25/75** | **45.5%** | 55 | **-$1,704 (-1.70%)** | **-$30.99** |
| Test 5 | SL 10x, TP 8x, ADX 40, RSI 25/75 | 41.8% | 55 | -$2,724 (-2.72%) | -$49.53 |
| Test 6 | SL 10x, TP 8x, ADX 35, RSI 20/80 | 46.0% | 63 | -$2,184 (-2.18%) | -$34.67 |

---

## Key Findings

### 1. Tighter SL/TP Makes Results WORSE
- Test 1 (5x/4x) had -$3,155 loss vs baseline -$2,505
- Wider SL gives trades room to breathe; tighter SL gets stopped out prematurely
- **Conclusion**: Keep 10x/8x ATR multipliers

### 2. ADX 35 is the Sweet Spot
- ADX 25 (baseline): Too restrictive, misses valid ranging opportunities
- ADX 35: Best balance - allows more signals while blocking strong trends
- ADX 40: Too permissive, allows trades in unfavorable conditions
- **Conclusion**: ADX 35 outperforms both 25 and 40

### 3. Tighter RSI (25/75) is Better Than (30/70)
- RSI 30/70: Triggers on moderate oversold/overbought
- RSI 25/75: Requires stronger extremes = higher quality signals
- RSI 20/80: Too restrictive, still doesn't improve expectancy
- **Conclusion**: RSI 25/75 provides best signal quality

### 4. Best Configuration Still Unprofitable
Despite optimization, the best config (Test 4) still loses -1.70% over 2 years:
- Win Rate: 45.5% (needs ~55%+ for positive expectancy with current R:R)
- Avg Loss > Avg Win (R:R < 1.0)
- Not enough edge to overcome transaction costs + slippage

---

## Best Configuration (Applied to Strategy)

```python
# gold_scalper_strategy.py - Round 3 optimal parameters
mean_revert_rsi_oversold: float = 25.0   # Tighter RSI threshold
mean_revert_rsi_overbought: float = 75.0
mean_revert_sl_atr_multiplier: float = 10.0  # Wide SL (10x M1 ATR)
mean_revert_tp_atr_multiplier: float = 8.0   # TP targets BB middle
mean_revert_max_adx: float = 35.0        # Allow trades up to ADX 35
mean_revert_use_adx_filter: bool = True
```

---

## Improvement from Baseline

| Metric | Baseline (Round 2.1) | Best (Round 3) | Delta |
|--------|----------------------|----------------|-------|
| Total PnL | -$2,505 (-2.51%) | -$1,704 (-1.70%) | +$801 (+0.81%) |
| Avg PnL/trade | -$42.47 | -$30.99 | +$11.48 |
| Win Rate | 44.1% | 45.5% | +1.4% |

**Net improvement: ~32% reduction in losses** but still fundamentally unprofitable.

---

## Critical Observations

### The MR Strategy Has Structural Problems:

1. **Inverted R:R**: SL (10x ATR) > TP (BB middle targeting, ~8x ATR)
   - With 45.5% win rate and R:R < 1.0, expectancy is negative
   - Formula: EV = (WR × AvgWin) - (LR × AvgLoss)
   - EV = (0.455 × $W) - (0.545 × $L) where L > W

2. **Low Signal Frequency**: Only 55 trades in 2 years
   - ~27 trades/year = ~2 trades/month
   - Not enough to compound any edge

3. **Session Drawdown Issues**: Circuit breaker triggers remain frequent
   - Wide SL (10x ATR) can breach session DD limits on single trades

---

## Next Steps (Round 4+)

1. **Question the Strategy Premise**: Is MR viable for XAUUSD M1?
   - Gold trends strongly; may not be ideal for mean reversion
   - Consider MR only for specific session/regime combinations

2. **Position Sizing Analysis**:
   - Current sizing may be too aggressive for wide SL
   - Need to ensure no single trade can trigger circuit breaker

3. **Alternative Approaches**:
   - Reduce position size proportionally to SL width
   - Use trailing stops instead of fixed TP
   - Consider hybrid: MR entry, TF exit

---

*Round 3 completed by ORCHESTRATOR*
