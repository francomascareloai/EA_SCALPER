---
description: MQL5 Elite Ops - Daily Market Intelligence & Risk Adjustment
---

# MQL5 Elite Ops: Market Intelligence Scan

Daily scan to adjust EA risk parameters based on real-world conditions.

## Step 1: Deep Researcher Scan

**Analyzing:**
1. **News Scan** - High-impact events for today (USD, XAU)
2. **Sentiment Analysis** - Risk-On vs Risk-Off environment
3. **Volatility Check** - VIX levels, ATR readings

**Output:** Daily Market Briefing

## Step 2: Quantum Strategist Risk Adjustment

**Determining Risk Mode:**

| Mode | Condition | Action |
|------|-----------|--------|
| 🟢 **Normal** | Low news, normal volatility | Standard lots, standard SL |
| 🟡 **Caution** | Medium news, elevated volatility | 50% lots, tight SL |
| 🔴 **Survival** | High news, extreme volatility | Trading paused or close-only |

**Output:** Parameter overrides (e.g., `RiskPercent = 0.5`)

## Step 3: Deployment Confirmation

**Updating:**
1. Local cache parameters
2. `trading_params.json` configuration
3. EA input adjustments

---

## Execution

I will now:
1. Search for today's economic calendar (XAUUSD relevant)
2. Check current market sentiment
3. Analyze volatility levels
4. Recommend risk mode

**Proceed with market scan?**

Reference: `.agent/workflows/mql5-market-scan.md`
