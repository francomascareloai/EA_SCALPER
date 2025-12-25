# ARGUS Research Gaps Analysis - Mean Reversion XAUUSD

```
AGENT: ARGUS
VERSION: 2.4
CLAUDE_MD_VERSION: 3.10.23
STATUS: COMPLETE
```

## Executive Summary (5 Key Findings)

1. **TIMEFRAME MISMATCH**: Gold's mean reversion half-life is ~77 months (AR(3) model). M1 scalping is fighting fundamental market physics. Successful MR gold strategies in literature use 2H+ timeframes minimum.

2. **MISSING REGIME FILTER (CRITICAL GAP)**: No ADX filter present. ADX < 20-25 is the standard prerequisite for mean reversion. Current strategy trades in trending markets where MR is mathematically a losing proposition.

3. **INVERTED R:R ROOT CAUSE IDENTIFIED**: The 3.4x loss/win ratio stems from exits, not entries. Solution: TIGHT SL (1.0-1.5x ATR) + EARLY TP (0.75-1.0x ATR). Accept 0.75:1 R:R with 75-80% target win rate.

4. **ENTRY THRESHOLD TOO LOOSE**: Simple BB touch is insufficient. Need Z-score > 2.0 AND/OR RSI extreme (< 20 or > 80) AND "walk feature" (3-4 bars outside band before entry).

5. **SESSION FILTER MISSING**: Asian session (2300-0700 UTC) is range-bound and MR-friendly. London/NY sessions have trend potential - MR should be avoided or constrained.

---

## Literature Review

### Academic Sources

| Source | Finding | Applicability |
|--------|---------|---------------|
| Ornstein-Uhlenbeck Process | MR half-life H = ln(2)/theta. Gold's H ~77 months via AR(3) | Explains why M1 MR is structurally challenged |
| Z-score normalization | Entry at Z > 2.0 (2 std dev) is threshold, not BB touch | Direct - replace entry logic |
| ADX regime filter | ADX < 20-25 = ranging market, MR viable | Direct - add as prerequisite |

### Practitioner Insights

| Source | Finding | Confidence |
|--------|---------|------------|
| TradingView strategies | BB+RSI showed 35% win rate in one backtest | LOW (specific to test conditions) |
| Gold scalping guides | "Walk feature" - 3-4 bars outside band before entry | MEDIUM - needs calibration |
| ATR-based exits | SL = 1-1.5x ATR, TP = 0.75-1x ATR for high win rate MR | HIGH - universal principle |
| Session analysis | Asian session lower volatility, MR-friendly | MEDIUM-HIGH |

### Key Academic References

1. **Mean Reversion Half-Life**: AR(3) model analysis of gold prices shows mean reversion operates on 77-month horizons, not M1/M5 timeframes.

2. **Keltner vs Bollinger**: Keltner Channels (ATR-based) better filter volatility spikes than BB (std deviation). KC adapts to volatility regime changes.

3. **VWAP Deviation**: Volume-weighted price anchors more accurate than SMA for intraday mean reversion. Institutional traders use VWAP, not BB.

---

## Missing Indicators (Ranked by Potential Impact)

### Tier 1: High Impact (Implement First)

| Indicator | Purpose | Implementation |
|-----------|---------|----------------|
| **ADX(14)** | Regime filter | Entry only when ADX < 20 |
| **ATR-based exits** | Fix inverted R:R | SL = 1.0x ATR, TP = 0.75x ATR |
| **Z-score** | Replace BB touch | Entry only when abs(Z) > 2.0 |

### Tier 2: Medium Impact (Test After Tier 1)

| Indicator | Purpose | Implementation |
|-----------|---------|----------------|
| **RSI extremes** | Confluence filter | RSI < 20 or > 80 confirmation |
| **Walk feature** | Filter false signals | 3-4 consecutive bars outside band |
| **Session filter** | Avoid trends | Trade Asian session only (2300-0700 UTC) |

### Tier 3: Lower Priority (Structural Changes)

| Indicator | Purpose | Implementation |
|-----------|---------|----------------|
| **VWAP deviation** | Replace BB entirely | Requires significant code changes |
| **Keltner Channels** | ATR-based bands | Replace BB with KC(20, 1.5) |
| **DXY filter** | Macro regime | Avoid MR when DXY trending strongly |
| **VIX filter** | Risk regime | VIX > 25 = avoid MR (risk-off creates gold trends) |

---

## Gold-Specific Factors Being Ignored

### 1. Macro Correlations

| Factor | Correlation with Gold | Impact on MR |
|--------|----------------------|--------------|
| DXY (Dollar Index) | -0.6 to -0.8 inverse | Strong DXY trend = gold trend, avoid MR |
| VIX (Fear Index) | Positive in crisis | VIX > 25 = risk-off, gold trends UP, avoid MR |
| Treasury Yields | Inverse (real yields) | Rising yields = gold downtrend, avoid MR |

### 2. Session Characteristics

| Session | Gold Behavior | MR Viability |
|---------|--------------|--------------|
| Asian (2300-0700 UTC) | Range-bound, low volatility | HIGH |
| London (0700-1200 UTC) | Trend initiation, breakouts | LOW |
| NY (1200-2100 UTC) | High volume, trends/reversals | MEDIUM |
| NY PM (1700-2100 UTC) | Apex close requirement | BLOCKED |

### 3. Gold-Specific Volatility Patterns

- **NFP Fridays**: Extreme volatility, avoid MR entirely
- **FOMC days**: Trend days, avoid MR
- **Asian holidays**: Ultra-low volatility, MR optimal
- **Quarter-end rebalancing**: Institutional flows create trends

---

## Recommended Experiments

### Priority 1: Immediate Implementation (Fix Core Issues)

**Experiment 1.1: ADX Regime Filter**
```
Hypothesis: ADX(14) < 20 filter will eliminate 50%+ losing trades
Test: Backtest current strategy with ADX < 20 vs ADX >= 20
Expected: Win rate improvement, Sharpe goes from -0.47 to positive
Metric: Compare Sharpe, SQN, win rate in each regime
```

**Experiment 1.2: ATR-Based Exits (HIGHEST PRIORITY)**
```
Hypothesis: Tight SL + Early TP fixes inverted R:R
Current: Unknown exits causing 3.4x loss/win ratio
Proposed: SL = 1.0x ATR(14), TP = 0.75x ATR(14)
Expected: R:R inverts from 0.29:1 to 0.75:1 with 75%+ win rate
Metric: Avg win/avg loss ratio, expectancy per trade
```

**Experiment 1.3: Z-Score Threshold**
```
Hypothesis: Z > 2.0 entry threshold improves signal quality
Current: Entry at BB touch (Z ~= 2.0, but touch != exact 2.0)
Proposed: Calculate Z = (price - SMA20) / StdDev20, enter only if abs(Z) > 2.0
Expected: Fewer trades, higher quality, better expectancy
Metric: Win rate, expectancy, trade count
```

### Priority 2: Test After Priority 1 Success

**Experiment 2.1: Walk Feature**
```
Hypothesis: 3-4 bars outside band filters false signals
Proposed: Require 3+ consecutive bars with close outside BB
Expected: Fewer trades, higher win rate
Risk: May reduce trade count below statistical significance
```

**Experiment 2.2: Session Filter**
```
Hypothesis: Asian session MR outperforms other sessions
Proposed: Trade only 2300-0700 UTC
Expected: Higher win rate, lower volatility stops
Risk: Reduces trading hours significantly
```

**Experiment 2.3: RSI Extreme Confluence**
```
Hypothesis: RSI < 20 or > 80 improves BB signal quality
Proposed: Require RSI extreme in addition to BB touch
Current: RSI(14) > 70 or < 30 (not extreme enough)
Expected: Fewer but higher quality signals
```

### Priority 3: Structural Changes (If Above Fail)

**Experiment 3.1: Timeframe Shift**
```
Hypothesis: M1 is fundamentally incompatible with gold MR
Proposed: Test 15M, 1H, 4H timeframes
Expected: Positive expectancy at higher timeframes
Risk: Completely different strategy, not an "optimization"
```

**Experiment 3.2: Replace BB with VWAP Deviation**
```
Hypothesis: VWAP more accurate anchor than SMA
Proposed: VWAP deviation oscillator instead of BB
Expected: Better intraday mean reversion detection
Risk: Significant code changes, needs VWAP calculation
```

---

## Confidence Assessment

| Finding | Confidence | Evidence Sources |
|---------|-----------|-----------------|
| ADX regime filter needed | HIGH | 3+ academic/practitioner sources |
| ATR-based tight exits | HIGH | Universal MR principle, multiple sources |
| Z-score > 2.0 threshold | MEDIUM-HIGH | Academic + needs XAUUSD calibration |
| Walk feature (3-4 bars) | MEDIUM | Practitioner sources, needs tuning |
| Session filter (Asian) | MEDIUM | Market structure documented |
| Gold 77-month half-life | MEDIUM | Single AR(3) study, may differ for M1 |
| DXY/VIX correlation | HIGH | Well-documented macro relationships |

## Evidence Gaps

1. **No M1/M5 specific gold MR studies** - most literature uses 1H+ timeframes
2. **BB(20,2) + RSI(14) not validated** for gold specifically
3. **No walk-forward tested parameters** for XAUUSD
4. **No Monte Carlo survival studies** for proposed changes

---

## Handoff: ARGUS -> FORGE

**Context**: Mean Reversion strategy research gaps identified. Strategy has negative expectancy due to inverted R:R (3.4x loss/win) and missing regime filter.

**Decisions Made**:
1. ADX regime filter is critical missing component
2. ATR-based exits (SL=1.0x ATR, TP=0.75x ATR) should fix inverted R:R
3. Z-score threshold (>2.0) superior to simple BB touch

**Assumptions**:
1. ATR(14) period is appropriate for XAUUSD M1 (may need calibration)
2. ADX(14) period is standard (may need calibration)
3. 0.75x ATR TP is reachable on M1 timeframe (needs validation)

**Risks Identified**:
1. Multiple filters compound may reduce trade count below statistical significance
2. M1 may be fundamentally incompatible with gold MR (structural risk)
3. ATR calibration may need adjustment for XAUUSD spread/volatility

**Open Questions**:
1. What is current SL/TP configuration? (needed to quantify fix)
2. Is ATR already calculated? Can we reuse?
3. What is the spread cost per trade? (affects minimum TP viability)

**Next Agent Should**:
1. Implement Experiment 1.2 first (ATR-based exits) - highest impact
2. Run isolated backtest with new exits
3. If successful, add ADX filter (Experiment 1.1)
4. If still negative, escalate to ORACLE for deep validation

---

## Summary Table

| Issue | Gap | Fix | Priority | Confidence |
|-------|-----|-----|----------|------------|
| Inverted R:R (3.4x) | No ATR-based exits | SL=1.0xATR, TP=0.75xATR | P1 | HIGH |
| Trading trends | No regime filter | ADX(14) < 20 prerequisite | P1 | HIGH |
| Loose entry | BB touch too early | Z-score > 2.0 threshold | P1 | MEDIUM-HIGH |
| False signals | No exhaustion filter | Walk feature (3-4 bars) | P2 | MEDIUM |
| Session agnostic | Trading all sessions | Asian session only | P2 | MEDIUM |
| Wrong timeframe | M1 vs 77-month half-life | Shift to 1H+ | P3 | MEDIUM |
