# ARGUS scan: Trend / XAUUSD (MT4/MT5 EAs)

Scope: commercial XAUUSD trend/scalper EAs; focus on portable patterns under Apex constraints (no overnight, trailing DD from HWM).

## Common marketplace patterns
- Trend engine: EMA stacks and/or MTF alignment (H1 bias + M5 execution).
- Risk management: ATR-based SL/TP, break-even, ATR trailing; spread and slippage filters.
- Operational gates: session filters, crude “news hour block” (often not a real calendar), daily loss/profit limits.

## Typical failure modes
- Curve-fitting to a specific volatility regime (works in a narrow slice of history).
- Fixed stops too tight for gold volatility; ATR stops without regime gating still get chopped.
- Multi-position stacking or hidden recovery modes increasing correlated drawdown.

## Apex portability
Portable:
- No-martingale, single-position discipline.
- Session gating aligned to your time constraints.
- ATR-based dynamic exits + strict worst-case loss per trade.
Not portable:
- Any averaging/grid/martingale semantics.
- Overnight holding.

## Representative EAs (URLs need verification if not on mql5.com)
Verified examples:
- MSX Plug And Play Scalper (MT5): https://www.mql5.com/en/market/product/157338

Unverified (captured from agent scan; verify before relying):
- PropHelper: https://www.mql5.com/en/market/product/126211
- GoldScalperEA: https://www.mql5.com/en/market/product/137310
- TW Sniper EA MT5: https://www.mql5.com/en/market/product/151533
- Aurum Vector Pro: https://www.mql5.com/en/market/product/149891
- XAUUSD Scalping EA: https://www.mql5.com/en/market/product/151815
- Scalp XAU: https://www.mql5.com/en/market/product/159455
- Gold Zenith MT5: https://www.mql5.com/en/market/product/151146
- FG Gold Scalper Pro: https://www.mql5.com/en/market/product/149371
- Vortex Gold EA: https://www.mql5.com/en/market/product/126409
- Forex GOLD Investor MT5: https://www.mql5.com/en/market/product/81137

## Notes on one verified example
MSX Plug And Play Scalper:
- Trend/pullback logic with EMA stack + recross.
- ATR-based SL/TP/BE/trailing.
- Session filter and manual hour-based news blocking.
- Explicitly claims no grid/martingale; depends on no DLL/external API.

Sources (verified):
- https://www.mql5.com/en/market/product/157338
