# Research Tree + Takeaways (MT4/MT5 EAs)

## Research tree (what to scan)

### 1) Trend-following (XAUUSD)
- Trend engine
  - EMA/MA stack alignment (e.g., fast/mid/slow)
  - MTF bias (H1 trend + M5 entry)
  - Trend-strength gates (ADX/volatility bucket)
- Entry timing
  - Pullback + recross
  - Breakout continuation after structure shift
- Risk + management
  - ATR-based SL/TP, BE, trailing
  - Spread/slippage gates
  - Session gates (London/NY)
  - News pause (real calendar vs “hour-based block”)

### 2) Breakout (XAUUSD)
- Breakout definition
  - Swing high/low break
  - Range (Asian session) breakout
  - Volatility expansion breakout
- Placement
  - ATR buffers on entries/stops
  - Pending orders vs market
- Filters
  - Trend filter (avoid counter-trend)
  - Candle quality / momentum checks
  - Trading hours
  - News blocks

### 3) Mean reversion
- Plain MR (potentially Apex-compatible if strictly risk-capped)
  - BB/RSI/EMA deviation
  - Volatility regime filters (avoid trends)
  - Session constraints
- Grid / martingale variants (Apex-incompatible)
  - Averaging against adverse move
  - Lot multipliers

## Cross-cutting takeaways for Apex
- Grid/martingale is structurally incompatible with trailing DD from HWM: adverse excursion tends to breach 5% before reversion.
- Most “news filters” in products are not real calendars; many are manual hour blocks.
- Broker dependency and lack of verifiable live track record is the norm; treat claims as marketing unless a public signal exists.

## Where we already match these patterns in our codebase
We already have ATR-based exits, session gating, multi-timeframe alignment, news guard, and trade spacing/cooldown.

Pointers for deeper follow-up
- Build a checklist per EA: (1) regime model, (2) hard risk cap, (3) position stacking, (4) news mechanism, (5) session rules.
- For each category (trend/breakout/MR), pick 2-3 candidate descriptions and translate into testable hypotheses in our optimizer.
