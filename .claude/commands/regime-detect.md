---
name: regime-detect
description: Design and implement market regime detection (Hurst, Entropy, HMM)
---

# /regime-detect - Market Regime Detection

Design and implement market regime detection systems using statistical methods.

## Methods Available

### Hurst Exponent
- **Trending**: H > 0.55 → Momentum/breakout strategies
- **Mean-Reverting**: H < 0.45 → Contrarian/grid strategies
- **Random Walk**: H ≈ 0.5 → NO TRADE (no edge)

### Shannon Entropy
- **Low Entropy** (<1.5): Structured, predictable
- **High Entropy** (>2.5): Noisy, unpredictable

### Combined Filter (Singularity Filter)
| Hurst | Entropy | Action |
|-------|---------|--------|
| >0.55 | <1.5 | Full size trending |
| >0.55 | >1.5 | Half size trending |
| <0.45 | <1.5 | Full size reverting |
| ~0.5 | ANY | NO TRADE |

## Usage

```
/regime-detect design filter for XAUUSD scalping

/regime-detect implement Hurst exponent Python

/regime-detect create MQL5 regime indicator

/regime-detect combined Hurst entropy filter
```

## Output

- Python implementation code
- MQL5 indicator/module code
- Integration with existing EA
- Visualization/dashboard specs

## Integration Points

- **Python Agent Hub**: Add regime detection to Technical Agent
- **MQL5 EA**: Filter trades based on regime
- **ONNX Model**: Use as input feature for ML models
