# ARGUS scan: Mean Reversion (MT4/MT5 EAs)

Scope: MR EAs (plain MR vs grid vs martingale). Goal: identify what is Apex-compatible.

## Compatibility verdict
- Plain MR: CONDITIONAL (only if per-trade risk is hard-capped and regime filters prevent trend exposure).
- Grid: NO-GO under Apex trailing DD from HWM.
- Martingale: ABSOLUTE NO-GO.

## Filters commonly claimed
- Volatility regime (ATR/BB width thresholds)
- Session filters
- News blocks
- Trend alignment filter (e.g., MA200)
- Spread/liquidity gates

## Verified examples
- MultiWay EA (multi-pair MR grid; external volatility server dependency): https://www.mql5.com/en/market/product/142029
- Extreme Reversion Trader (MR + grid + lot multiplier): https://www.mql5.com/en/market/product/149373
- Aureus Mean Reversion (XAUUSD MR; claims no martingale/grid): https://www.mql5.com/en/market/product/156121

## Notes
- The “no martingale but grid” claim is often semantic: fixed-lot grid still accumulates adverse exposure.
- External server dependency is a major operational risk.

Sources (verified):
- https://www.mql5.com/en/market/product/142029
- https://www.mql5.com/en/market/product/149373
- https://www.mql5.com/en/market/product/156121
