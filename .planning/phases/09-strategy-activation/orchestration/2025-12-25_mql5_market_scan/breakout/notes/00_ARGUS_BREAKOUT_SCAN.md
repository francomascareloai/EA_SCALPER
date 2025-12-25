# ARGUS scan: Breakout / XAUUSD (MT4/MT5 EAs)

Scope: breakout EAs (swing breakout, volatility breakout, session breakout). Focus on portable design patterns and red flags.

## Common patterns
- Breakout definition
  - Swing high/low breaks with dynamic pivot depth.
  - Range/Asian-session breakout (consolidation -> London/NY expansion).
  - Volatility expansion breakouts.
- Placement + risk
  - ATR buffers (entry and/or SL), ATR trailing, BE rules.
  - Trade frequency throttles (1 trade/day, cooldown, spacing).
- Filters
  - Trend filter (avoid counter-trend), ADX strength gates.
  - Trading hours and news blocks.

## Red flags
- Disguised grid/martingale (“recovery mode”, lot multipliers, adding into losers).
- Overfit marketing (very high win rate + extreme Sharpe) with short track record.
- Broker dependency ("works only with broker X"; fragile to spread/slippage).

## One verified example
Ultimate Breakout Scalper:
- Swing breakout with ATR buffers; MTF filters; ADX; time filter; news filter.
- Claims no grid/martingale.
- Risks: new product, weak independent verification; set files outside listing.

Sources (verified):
- https://www.mql5.com/en/market/product/157349
