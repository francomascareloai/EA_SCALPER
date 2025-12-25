# XAUUSD Breakout EA Patterns Research

```
AGENT: ARGUS
VERSION: 2.4
CLAUDE_MD_VERSION: 3.10.23
STATUS: COMPLETE
DATE: 2025-12-25
```

## Claim
Identify common patterns and red flags in MT4/MT5 XAUUSD breakout/scalper EAs to inform EA_SCALPER_XAUUSD development.

## Verdict: MEDIUM CONFIDENCE

Evidence triangulated from MQL5 marketplace, strategy guides, and review sites. Limited academic validation for gold-specific breakout strategies. No Apex-specific EA examples found (expected).

---

## Common Patterns

### Breakout Methodologies
- **Daily/Session Range**: Mark high/low of Asian session, trade London breakout
- **ZigZag Breakout**: Swing structure detection with SuperTrend confirmation
- **Donchian Channel**: N-bar high/low with ATR buffer for entry
- **Volatility Expansion**: ATR threshold gate (e.g., ATR >= 200 points) before entry

### Session Filters
- **Asian-London**: Consolidation during Asia, breakout at London open
- **NY Session Focus**: Most XAUUSD volatility; M30 breakouts common
- **Time Windows**: Server time filters (e.g., 7:00-22:00 GMT)
- **GMT Offset Handling**: Critical for broker time synchronization

### ATR Usage
- **Entry Buffer**: 0.25 * ATR typical to filter false breakouts
- **Position Sizing**: Risk-based with ATR (1.5x ATR for SL, 2x ATR for TP)
- **Trailing Stops**: ATR-based dynamic trailing
- **Volatility Gate**: Minimum ATR threshold to confirm breakout strength

### Trade Management
- **One Trade/Day**: Reduces overtrading and DD exposure
- **Trailing Take Profit**: Lock profits as trade moves favorably
- **Fixed SL + Trailing TP**: Common risk management pattern
- **Time-Based Exits**: Close before session end (critical for Apex)

### News Filters
- **Smart News Filter**: Avoid high-impact events (FOMC, NFP, CPI)
- **Pre-Trigger Validation**: Confirm no news within N hours before entry

---

## Red Flags Taxonomy

| Red Flag | Indicators | Example |
|----------|------------|---------|
| **Grid/Martingale Disguised** | "Recovery mode", lot multipliers, "never loses", smooth equity curves hiding unrealized losses | Quantum Queen EA |
| **Overfit Claims** | Backtests only post-2018, <2 years data, >80% win rate, $100->$8k in 3 months | XAUUSD M5 Super Scalper claims |
| **Broker Dependency** | Specific spread requirements (60 pips), "works only with X broker", slippage sensitivity | Many free EAs |
| **Transparency Issues** | Hidden DD data, no refunds, no proper backtest reports, shy/anonymous developers | Golden Coup EA, XAUUSD ONLY EA |
| **Too Good Metrics** | Sharpe >3, monthly 30-200% returns, sub-5% DD with 25%+ monthly, "100% success" | General scam pattern |

### Verification Checklist
1. Demand live, dual-verified performance (Myfxbook, FxBlue)
2. Check if DD data is visible and realistic
3. Verify backtest period includes 2013/2016 gold spikes
4. Look for explicit "no martingale/grid" AND verify in reviews
5. Check developer responsiveness and refund policy

---

## Representative EAs

### Legitimate Patterns (Study for Architecture)

| EA Name | URL | Key Features |
|---------|-----|--------------|
| XAU Breakout Scalper MT5 | https://www.mql5.com/en/market/product/138496 | ZigZag + SuperTrend, session control, ADX/VWAP filters, $749 |
| XAU Breakout EA | https://www.mql5.com/en/market/product/149286 | Daily breakout, pending orders, trailing stop, $500 |
| Breakout Scalper 8 MT5 | https://www.mql5.com/en/market/product/149289 | High-Low placement, price action, XAUUSD + US100 |
| XAUUSD Precision Breakout | https://www.mql5.com/en/market/product/142453 | 7:00 GMT candle breakout, single trade/day, M5 |
| H4 Zone Retest EA | https://github.com/phatnomenal/blackXAU_AUTOMATED-BOT-TRADE | Zone retest + news filter, open source, MQL5 |
| EA_XAU_VolatilityBreakout | https://www.scribd.com/document/901109830/EA-XAU-VolatilityBreakout | ATR + Donchian, source code available |
| Gold Trend Breakout EA | https://www.mql5.com/en/blogs/post/766316 | Volatility-adaptive SL, time-based exit, 3 styles |

### Red Flag Examples (Avoid/Study What NOT to Do)

| EA Name | URL | Issues |
|---------|-----|--------|
| Quantum Queen EA | https://bestforexrobo.com/quantum-queen-ea/ | Grid + Martingale disguised, backtests only post-2018, "unrealized-loss disguise" |
| XAUUSD ONLY EA | https://ie.trustpilot.com/review/indpendent.cloud | Martingale, scam, blown accounts, censored reviews |
| Golden Coup EA | https://fxeareview.com/golden-coup-ea-review/ | Claims no martingale but 78% DD observed, no transparency |

---

## Evidence Sources

1. **MQL5 Marketplace + Code** (Primary): XAU Breakout Scalper, Breakout Scalper 8, XAUUSD Precision Breakout, EA_XAU_VolatilityBreakout source code
2. **Strategy Guides**: Asian Session Breakout (Medium), ATR Breakout Guide (QuantStock), MQL5 Trailing Stop Book
3. **Review Sites/Forums**: bestforexrobo.com (Quantum Queen), TrustPilot (XAUUSD ONLY), soehoe.id forums, ACY 5 Red Flags article

---

## Applicability to EA_SCALPER_XAUUSD

### Transferable Patterns
- ATR-buffer entry filter: Reduces false breakouts
- Session filter: Align with London/NY overlap for liquidity
- News filter: Avoid FOMC/NFP/CPI windows
- One trade/day: Reduces DD exposure, aligns with Apex consistency
- Trailing stop: ATR-based, fits HWM tracking requirements

### Apex-Specific Considerations
- **Time Gates**: Must close by 4:59 PM ET; block new trades after 4:30 PM ET
- **DD Constraints**: No hidden grid/martingale; fixed SL mandatory
- **HWM Trap**: Trailing DD from peak equity means no "recovery mode" allowed
- **Consistency Rule**: 30% daily profit cap (live accounts)

### Evidence Gaps
- No Apex-compliant EA examples found (prop firm constraints are rare in retail EAs)
- Limited academic validation for gold-specific breakout timing
- Live-verified performance data is scarce; most claims are backtest-only

---

## Next Actions

| Priority | Action | Handoff |
|----------|--------|---------|
| 1 | Implement ATR-buffer entry filter using patterns from EA_XAU_VolatilityBreakout source (Donchian + ATR gate) | FORGE |
| 2 | Design session filter aligned with Apex time gates: NY overlap focus, block after 4:30 PM ET, force close 4:55 PM ET | CRUCIBLE |
| 3 | Audit current breakout logic for hidden grid/martingale characteristics; validate fixed SL always present | SENTINEL |

---

## HANDOFF: ARGUS -> FORGE/CRUCIBLE/SENTINEL

### Context
- Task: Research XAUUSD breakout EA patterns and red flags
- Files: This document

### Decisions Made
- ATR-buffer pattern selected over pure price action (more robust to noise)
- Session filter approach: NY session focus with Apex time gates
- One trade/day constraint recommended (reduces DD, improves consistency)

### Assumptions
- MQL5 marketplace patterns are representative of retail EA landscape
- Source code from Scribd/GitHub is authentic (verify before implementation)
- Apex constraints are more restrictive than typical retail EAs

### Risks Identified
- Survivorship bias: Only seeing marketed/available EAs
- Marketing claims may not match live performance
- Gold-specific volatility (FOMC/NFP) may break generic breakout logic

### Open Questions
- What is optimal ATR period for XAUUSD M5/M15? (Test 14 vs 20)
- Should session filter use absolute time (7:00 GMT) or relative (N hours after London open)?

### Next Agent Should
- FORGE: Implement ATR-buffer entry filter with configurable parameters
- CRUCIBLE: Design session filter architecture aligned with Apex
- SENTINEL: Audit for grid/martingale patterns in existing codebase
