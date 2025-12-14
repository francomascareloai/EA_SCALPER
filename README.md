# EA_SCALPER_XAUUSD v3.30

[![Python](https://img.shields.io/badge/Python-3.10+-blue.svg)](https://python.org)
[![MQL5](https://img.shields.io/badge/MQL5-MetaTrader%205-orange.svg)](https://www.mql5.com)
[![NautilusTrader](https://img.shields.io/badge/NautilusTrader-Migration-green.svg)](https://nautilustrader.io)
[![License](https://img.shields.io/badge/License-Personal%20Project-lightgrey.svg)]()
[![Status](https://img.shields.io/badge/Status-In%20Development-red.svg)]()

**Automated Gold Trading System for Prop Firms (Apex Trader Funding & FTMO)**

**Dataset ativo para backtests:** `data/raw/full_parquet/xauusd_2003_2025_stride20_full.parquet` (32.7M ticks, 2003-05-05 → 2025-11-28, stride 20). Todas as execuções devem usar este arquivo.

> After many requests and messages, I've made this repository public again. This is a personal project that I've been developing to automate gold (XAUUSD) trading with a focus on prop firm challenges (Apex Trader Funding, FTMO, and others).

---

## 🚨 NOT READY FOR PRODUCTION

> **⚠️ WARNING: This project is NOT ready for live trading with real money!**
> 
> I am actively fixing bugs and improving the system. Use only for:
> - 📚 **Study and learning**
> - 🧪 **Demo account testing**
> - 🔬 **Backtesting and research**
>
> **DO NOT use on funded accounts or real money until further notice.**

### Known Issues & Bugs Being Fixed

| Issue | Status | Description |
|-------|--------|-------------|
| Filters too strict | 🔧 Fixing | May result in very few or no trades |
| ONNX model path | 🔧 Fixing | Model may not load on some setups |
| Compilation warnings | ✅ Fixed | Deprecated functions removed |
| Duplicate structs | ✅ Fixed | SConsolidation duplicate removed |

### Found a Bug? Have a Suggestion?

- 📬 **Telegram**: [@novtelfran](https://t.me/novtelfran) (fastest response)
- 🐛 **GitHub Issues**: Open an issue with details
- 💬 **Discussions**: Start a discussion for questions/ideas

**Please include**: MT5 version, broker, timeframe, logs/screenshots if possible.

---

## 📑 Table of Contents

- [The Origin Story](#the-origin-story)
- [Overview](#overview)
- [Two Versions Available](#two-versions-available)
- [Quick Start](#quick-start)
- [For Students & Researchers](#for-students--researchers)
- [System Architecture](#system-architecture)
- [Trading Strategies](#trading-strategies)
- [Analysis Modules (MQL5)](#analysis-modules-mql5)
- [Risk Management](#risk-management)
- [Machine Learning Integration](#machine-learning-integration)
- [NautilusTrader Migration (Python)](#nautilustrader-migration-python)
- [Project Structure](#project-structure)
- [Target Performance (Theoretical)](#target-performance-theoretical)
- [Roadmap](#roadmap)
- [Requirements](#requirements)
- [Disclaimer](#disclaimer)
- [Contact & Contributions](#contact--contributions)
- [Version History](#version-history)

---

## The Origin Story

This project started after I **downloaded and classified over 5,000 trading robots** from 90%+ of Telegram groups and channels about Trading and Expert Advisors. After extensive testing and analysis, I realized that **99.9% of trading bots are garbage** - either poorly coded, overfitted, or outright scams from vendors trying to steal your money.

**No scammers. No fake vendors. No bullshit.**

I decided to build my own robot from scratch, with proper backtesting, statistical validation, and real risk management. This is that journey.

---

## Overview

EA_SCALPER_XAUUSD is an advanced Expert Advisor (trading robot) designed specifically for **XAUUSD (Gold)** scalping on MetaTrader 5. It combines:

- **Smart Money Concepts (SMC)** - Institutional trading methodology
- **Machine Learning (ONNX)** - Direction models trained in Python
- **Multi-Timeframe Analysis (MTF)** - H1/M15/M5 for maximum precision
- **Order Flow Analysis** - Footprint/Cluster chart style confirmation
- **Prop Firm Compliance** - Strict rules for FTMO/Apex

---

## Two Versions Available

This project has **two separate implementations** for different use cases:

### Version 1: MQL5 Only (MetaTrader 5)

```
📁 MQL5/
├── Experts/EA_SCALPER_XAUUSD.mq5    # Main robot
└── Include/EA_SCALPER/              # All modules
```

| Aspect | Details |
|--------|---------|
| **Platform** | MetaTrader 5 |
| **Broker** | Any MT5 broker with XAUUSD |
| **Prop Firms** | FTMO, MyForexFunds, etc. |
| **Status** | 🔧 **In Development** (fixing bugs) |
| **Best For** | Study, demo testing, backtesting |

### Version 2: Python + NautilusTrader (Futures)

```
📁 nautilus_gold_scalper/
├── src/                             # Python modules
└── scripts/                         # Backtest runners
```

| Aspect | Details |
|--------|---------|
| **Platform** | NautilusTrader → NinjaTrader/Tradovate |
| **Broker** | Tradovate (via Apex Trader Funding) |
| **Prop Firms** | Apex Trader Funding (Futures) |
| **Status** | 🔄 **In Development** |
| **Best For** | Futures trading on Apex |

### Which Version Should I Use?

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                         WHICH VERSION TO USE?                               │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│   Want to trade FOREX/CFD on MT5?                                          │
│   └──▶ Use MQL5 Version (FTMO, MyForexFunds, etc.)                        │
│                                                                             │
│   Want to trade FUTURES on Apex Trader Funding?                            │
│   └──▶ Use Python/NautilusTrader Version (via NinjaTrader/Tradovate)      │
│                                                                             │
│   Want to study the code and learn?                                        │
│   └──▶ Both! MQL5 is complete, Python shows modern architecture           │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## Quick Start

### Option A: Run on MetaTrader 5 (MQL5 Version)

**Step 1: Install MetaTrader 5**
- Download from your broker or [MetaQuotes](https://www.metatrader5.com)
- Create demo account with XAUUSD access

**Step 2: Copy Files**
```
Copy entire MQL5/ folder to:
C:\Users\[YourUser]\AppData\Roaming\MetaQuotes\Terminal\[ID]\MQL5\
```

**Step 3: Compile**
- Open MetaEditor (F4 in MT5)
- Open `Experts/EA_SCALPER_XAUUSD.mq5`
- Press F7 to compile
- Fix any path issues if errors appear

**Step 4: Attach to Chart**
- Open XAUUSD M5 chart
- Drag EA from Navigator to chart
- Enable "Allow Algo Trading"
- Configure inputs (start with defaults)

**Step 5: Monitor**
- Check Experts tab for logs
- If no trades: check Journal for filter reasons
- Normal to wait hours for valid setup!

### Option B: Study & Learn (For Developers)

**Step 1: Clone Repository**
```bash
git clone https://github.com/francomascareloai/EA_SCALPER_XAUUSD.git
```

**Step 2: Explore Structure**
```
Start here:
├── MQL5/Include/EA_SCALPER/INDEX.md     # Architecture documentation
├── MQL5/Experts/EA_SCALPER_XAUUSD.mq5   # Main EA (read OnTick flow)
├── DOCS/                                 # Detailed documentation
└── nautilus_gold_scalper/               # Python implementation
```

**Step 3: Key Files to Study**

| File | What You'll Learn |
|------|-------------------|
| `Analysis/CRegimeDetector.mqh` | Hurst Exponent, Shannon Entropy |
| `Analysis/EliteOrderBlock.mqh` | SMC Order Block detection |
| `Analysis/CMTFManager.mqh` | Multi-timeframe architecture |
| `Risk/FTMO_RiskManager.mqh` | Prop firm risk management |
| `Bridge/COnnxBrain.mqh` | ML/ONNX integration in MQL5 |

---

## For Students & Researchers

### How to Compile MQL5 Files

**Using MetaEditor (GUI):**
1. Open MetaTrader 5 → Press F4 (opens MetaEditor)
2. File → Open → Navigate to `EA_SCALPER_XAUUSD.mq5`
3. Press F7 to compile
4. Check "Errors" tab at bottom

**Using Command Line (Advanced):**
```powershell
# Path to MetaEditor
$metaeditor = "C:\Program Files\MetaTrader 5\metaeditor64.exe"

# Compile with includes
& $metaeditor /compile:"MQL5\Experts\EA_SCALPER_XAUUSD.mq5" /inc:"MQL5" /log

# Check log for errors
Get-Content "MQL5\Experts\EA_SCALPER_XAUUSD.log"
```

### Common Compilation Errors

| Error | Cause | Fix |
|-------|-------|-----|
| `'file.mqh' - file not found` | Include path wrong | Check file exists in `Include/EA_SCALPER/` |
| `'CClassName' - undeclared identifier` | Missing #include | Add the required include at top of file |
| `'OnTick' - function already defined` | Duplicate EA | Only one EA per compilation |

### Understanding the Code Flow

```
OnInit()                    # EA starts
    │
    ├── Initialize modules
    ├── Load ONNX model
    └── Setup risk parameters
    
OnTick()                    # Every price change
    │
    ├── Gate 1: Check emergency mode
    ├── Gate 2: Check risk limits
    ├── Gate 3: Check session (London/NY)
    ├── Gate 4: Check news filter
    ├── Gate 5: Check regime (Hurst/Entropy)
    ├── Gate 6: Check H1 trend direction
    ├── Gate 7: Check structure (BOS/CHoCH)
    ├── Gate 8: Check MTF confirmation
    ├── Gate 9: Calculate confluence score
    ├── Gate 10: Optimize entry
    │
    └── If ALL gates pass → Execute Trade
    
OnTimer()                   # Every second
    │
    ├── Update regime metrics
    ├── Manage open positions
    └── Check partial TPs
```

---

## System Architecture

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                    EA_SCALPER_XAUUSD v3.30 ARCHITECTURE                     │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│   ┌─────────────┐    ┌─────────────┐    ┌─────────────┐    ┌─────────────┐ │
│   │   H1 (HTF)  │───▶│  M15 (MTF)  │───▶│  M5 (LTF)   │───▶│ ORDER FLOW  │ │
│   │   FILTER    │    │   ZONES     │    │  EXECUTION  │    │ CONFIRMATION│ │
│   └─────────────┘    └─────────────┘    └─────────────┘    └─────────────┘ │
│         │                  │                  │                  │         │
│         ▼                  ▼                  ▼                  ▼         │
│   ┌─────────────────────────────────────────────────────────────────────┐  │
│   │                    CONFLUENCE SCORER (0-100)                        │  │
│   │   Combines: Trend + Structure + OB + FVG + Sweep + Regime + Delta   │  │
│   └─────────────────────────────────────────────────────────────────────┘  │
│                                    │                                        │
│                                    ▼                                        │
│   ┌─────────────────────────────────────────────────────────────────────┐  │
│   │                    10-GATE VALIDATION SYSTEM                         │  │
│   │   Gate 1: Emergency  │  Gate 6: MTF Direction                       │  │
│   │   Gate 2: Risk       │  Gate 7: Structure/Signal                    │  │
│   │   Gate 3: Session    │  Gate 8: MTF Confirmation                    │  │
│   │   Gate 4: News       │  Gate 9: Confluence Score                    │  │
│   │   Gate 5: Regime     │  Gate 10: Entry Optimization                 │  │
│   └─────────────────────────────────────────────────────────────────────┘  │
│                                    │                                        │
│                                    ▼                                        │
│   ┌─────────────────────────────────────────────────────────────────────┐  │
│   │                    TRADE EXECUTION                                   │  │
│   │   Entry: Optimized │ SL: Structure-based │ TP: Partial (40/30/30)   │  │
│   └─────────────────────────────────────────────────────────────────────┘  │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## Trading Strategies

### Strategy 1: SMC Scalping (Primary)

```
                BULLISH ORDER BLOCK                    BEARISH ORDER BLOCK
                
                        │ Rally                              │ Drop
                        │   ↑                                │   ↓
                     ┌──┴───┴──┐                          ┌──┴───┴──┐
              ══════▶│  ENTRY  │◀══════            ══════▶│  ENTRY  │◀══════
                     │  ZONE   │                          │  ZONE   │
                     └─────────┘                          └─────────┘
                     Last Down                            Last Up
                     Candle                               Candle
```

| Feature | Description |
|---------|-------------|
| **Entry** | Retracement to Order Block (70% level) |
| **SL** | Below/Above OB with ATR buffer |
| **TP** | 1:2 to 1:3 Risk-Reward |
| **Filter** | Only trade fresh OBs (first touch) |

### Strategy 2: Fair Value Gap (FVG) Trading

```
              BULLISH FVG                         BEARISH FVG
              
           Candle 3 ──►  ┌───┐                    ┌───┐  ◄── Candle 1
                         │   │                    │   │
           GAP ────────► │░░░│ ◄── 50% Fill       │░░░│ ◄── GAP
                         │░░░│     Entry          │░░░│
                         └───┘                    └───┘
           Candle 1 ──►  ┌───┐                    ┌───┐  ◄── Candle 3
                         │   │                    │   │
                         └───┘                    └───┘
```

| Feature | Description |
|---------|-------------|
| **Entry** | 50% FVG fill (optimal R:R) |
| **Target** | Opposite side of FVG |
| **Best** | FVG + OB confluence |

### Strategy 3: Liquidity Sweep + Reversal

```
              LIQUIDITY SWEEP PATTERN
              
              BSL (Buy-Side Liquidity) ═══════════════════
                          │
                   ┌──────┼──────┐
                   │      │      │
                   │   SWEEP ────┼──── Price breaks above
                   │      │      │     grabs stops
                   │      │      │     and REVERSES
                   │      ▼      │
                   │   ══════    │
                   │             │
              SSL (Sell-Side Liquidity) ═══════════════════
```

| Feature | Description |
|---------|-------------|
| **Setup** | Equal highs/lows (liquidity pools) |
| **Trigger** | Price sweeps level and rejects |
| **Entry** | After confirmation candle |
| **Target** | Opposite liquidity pool |

### Strategy 4: AMD Cycle (Accumulation → Manipulation → Distribution)

```
         ACCUMULATION              MANIPULATION              DISTRIBUTION
         
         ┌─────────────┐          ┌─────────────┐          ┌─────────────┐
         │ ═══════════ │          │     ↑ Fake  │          │         ↗   │
         │ ═══════════ │    ──▶   │ ════╱ Break │    ──▶   │       ↗     │
         │  Range      │          │    ↓        │          │     ↗  REAL │
         │  (Wait)     │          │  (Prepare)  │          │   ↗  MOVE   │
         └─────────────┘          └─────────────┘          └─────────────┘
              ❌                        ⚠️                        ✅
           Don't Trade             Get Ready                   ENTER!
```

---

## Analysis Modules (MQL5)

### Core Analysis Modules

| Module | Purpose | Key Features |
|--------|---------|--------------|
| **CMTFManager** | Multi-Timeframe Coordination | H1 trend filter, M15 zones, M5 execution |
| **CStructureAnalyzer** | Market Structure | BOS, CHoCH, Swing Points detection |
| **EliteOrderBlock** | Order Block Detection | Quality scoring (0-100), freshness tracking |
| **EliteFVG** | Fair Value Gap Detection | Fill percentage, state management |
| **CLiquiditySweepDetector** | Liquidity Analysis | BSL/SSL pools, sweep detection |
| **CRegimeDetector** | Market Regime | Hurst Exponent + Shannon Entropy |
| **CAMDCycleTracker** | AMD Phase Detection | Accumulation/Manipulation/Distribution |
| **CFootprintAnalyzer** | Order Flow Analysis | Delta, Imbalance, Absorption |

### Regime Detection Matrix

```
┌─────────────────┬───────────────┬───────────────┐
│                 │ Entropy < 1.5 │ Entropy >= 1.5│
│                 │  (Low Noise)  │ (High Noise)  │
├─────────────────┼───────────────┼───────────────┤
│  Hurst > 0.55   │ ✅ TRENDING   │ ⚠️ NOISY      │
│  (Persistent)   │ Size: 100%    │ Size: 50%     │
├─────────────────┼───────────────┼───────────────┤
│  Hurst < 0.45   │ ✅ REVERTING  │ ⚠️ NOISY      │
│  (Mean-Revert)  │ Size: 100%    │ Size: 50%     │
├─────────────────┼───────────────┼───────────────┤
│  Hurst ≈ 0.50   │ ❌ RANDOM     │ ❌ RANDOM     │
│  (Random Walk)  │ NO TRADE      │ NO TRADE      │
└─────────────────┴───────────────┴───────────────┘
```

### Order Flow Analysis (Footprint)

```
   TRADITIONAL CANDLE              FOOTPRINT CHART
   
        ┌───┐                   Price │ Bid x Ask │ Delta
        │   │                   ──────┼───────────┼──────
        │   │                   2650.5│ 120 x 450 │ +330 [BUY IMB]
        │   │                   2650.0│ 280 x 310 │ +30  ◄─ POC
        │   │                   2649.5│ 350 x 180 │ -170 [SELL IMB]
        └───┘                   2649.0│ 190 x 220 │ +30
                                2648.5│  90 x 150 │ +60
```

| Pattern | Detection | Meaning |
|---------|-----------|---------|
| **Stacked Buy Imbalance** | 3+ consecutive buy imbalances | Strong support |
| **Stacked Sell Imbalance** | 3+ consecutive sell imbalances | Strong resistance |
| **Buy Absorption** | High volume + delta ~0 on drop | Buyers absorbing sells |
| **Sell Absorption** | High volume + delta ~0 on rise | Sellers absorbing buys |
| **Unfinished Auction** | Close=High/Low + delta confirms | Continuation expected |

---

## Risk Management

### Safety Layer Architecture

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                           SAFETY LAYER                                       │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│   ┌─────────────────────┐         ┌─────────────────────┐                  │
│   │   CIRCUIT BREAKER   │         │   SPREAD MONITOR    │                  │
│   ├─────────────────────┤         ├─────────────────────┤                  │
│   │ Daily DD: 4% → STOP │         │ Normal: 100% size   │                  │
│   │ Total DD: 8% → CLOSE│         │ Elevated: 50% size  │                  │
│   │ 5 Losses → COOLDOWN │         │ High: 25% size      │                  │
│   │ Emergency → HALT    │         │ Extreme: NO TRADE   │                  │
│   └─────────────────────┘         └─────────────────────┘                  │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### Prop Firm Compliance

| Rule | Apex | FTMO | Our Buffer | Implementation |
|------|------|------|------------|----------------|
| **Max Drawdown** | 10% trailing | 10% total | 8% | Real-time HWM tracking |
| **Daily Drawdown** | N/A | 5% | 4% | Daily loss circuit breaker |
| **Overnight** | ❌ Prohibited | ✅ Allowed | Auto-close | Time-based closure |
| **Consistency** | 30% max/day | N/A | Monitor | Daily profit cap |
| **Risk/Trade** | 0.5-1% | 0.5-1% | 0.5% | Dynamic position sizing |

### Position Sizing Formula

```
Lot Size = (Account Equity × Risk%) / (SL Points × Tick Value)
         × Regime Multiplier (0.5 or 1.0)
         × MTF Multiplier (0.5, 0.75, or 1.0)
         × Spread Multiplier (0.25 to 1.0)
```

---

## Machine Learning Integration

### ONNX Brain - Direction Prediction

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                        ONNX INFERENCE PIPELINE                               │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│   FEATURES (15)              MODEL                    OUTPUT                │
│   ┌─────────────┐      ┌─────────────┐         ┌─────────────┐             │
│   │ Returns     │      │             │         │             │             │
│   │ RSI (3 TFs) │      │    LSTM     │         │ P(Bearish)  │             │
│   │ ATR Norm    │ ───▶ │    MODEL    │ ───▶    │ P(Bullish)  │             │
│   │ Hurst       │      │   (ONNX)    │         │             │             │
│   │ Entropy     │      │             │         │ If > 0.65   │             │
│   │ Session     │      └─────────────┘         │ = CONFIRM   │             │
│   │ ...         │           < 5ms              └─────────────┘             │
│   └─────────────┘                                                          │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### 15 Model Features

| # | Feature | Calculation |
|---|---------|-------------|
| 1 | Returns | (close - prev) / prev |
| 2 | Log Returns | log(close / prev) |
| 3 | Range % | (high - low) / close |
| 4-6 | RSI (M5/M15/H1) | RSI(14) / 100 |
| 7 | ATR Normalized | ATR(14) / close |
| 8 | MA Distance | (close - MA20) / MA20 |
| 9 | BB Position | (close - mid) / width |
| 10 | Hurst | Rolling Hurst(100) |
| 11 | Entropy | Rolling Entropy(100) / 4 |
| 12 | Session | 0=Asia, 1=London, 2=NY |
| 13-14 | Hour Encoding | sin/cos(2π × hour / 24) |
| 15 | OB Distance | Distance to OB / ATR |

---

## NautilusTrader Migration (Python)

We are actively migrating to **[NautilusTrader](https://nautilustrader.io)** - a high-performance algorithmic trading platform.

### Why NautilusTrader?

| Feature | Benefit |
|---------|---------|
| **Event-Driven** | Realistic backtesting without look-ahead bias |
| **High Performance** | Cython core for institutional-grade speed |
| **Multi-Venue** | Trade futures on Tradovate (Apex) |
| **Unified Code** | Same code for backtest and live |
| **Python Ecosystem** | Full ML/AI libraries access |

### Migration Progress

```
nautilus_gold_scalper/
├── src/
│   ├── strategies/          # Trading strategies
│   ├── indicators/          # Custom indicators
│   ├── signals/             # Signal generators
│   ├── risk/                # Risk management
│   ├── ml/                  # Machine learning
│   ├── execution/           # Trade execution
│   └── core/                # Core definitions
├── scripts/                 # Backtest runners
├── tests/                   # Unit tests
└── data/                    # Historical data
```

### Modules Status

| Module | MQL5 | Python | Status |
|--------|------|--------|--------|
| Session Filter | ✅ | ✅ | **Migrated** |
| Regime Detector | ✅ | ✅ | **Migrated** |
| Order Block | ✅ | ✅ | **Migrated** |
| FVG Detector | ✅ | ✅ | **Migrated** |
| Liquidity Sweep | ✅ | ✅ | **Migrated** |
| Footprint Analyzer | ✅ | ✅ | **Migrated** |
| Confluence Scorer | ✅ | ✅ | **Migrated** |
| Risk Manager | ✅ | ✅ | **Migrated** |
| Trade Manager | ✅ | 🔄 | In Progress |
| SMC Strategy | ✅ | 🔄 | In Progress |

---

## Project Structure

```
EA_SCALPER_XAUUSD/
│
├── MQL5/                           # MetaTrader 5 Source
│   ├── Experts/                    # Main EA
│   │   └── EA_SCALPER_XAUUSD.mq5   # Entry point
│   ├── Include/EA_SCALPER/         # Modules
│   │   ├── Analysis/               # Technical analysis
│   │   ├── Signal/                 # Signal generation
│   │   ├── Risk/                   # Risk management
│   │   ├── Execution/              # Trade execution
│   │   ├── Bridge/                 # External integrations
│   │   ├── Safety/                 # Circuit breakers
│   │   └── Core/                   # Core definitions
│   └── Models/                     # ONNX models
│
├── nautilus_gold_scalper/          # NautilusTrader (Python)
│   ├── src/                        # Source code
│   ├── tests/                      # Unit tests
│   └── scripts/                    # Backtest scripts
│
├── scripts/                        # Analysis tools
│   ├── oracle/                     # WFA, Monte Carlo
│   └── forge/                      # Code analysis
│
├── models/                         # ML models
├── data/                           # Market data
└── DOCS/                           # Documentation
```

---

## Target Performance (Theoretical)

> **⚠️ IMPORTANT: These are THEORETICAL targets, not actual results!**
> 
> The system is still in development. These numbers represent design goals, 
> not guaranteed or backtested performance. Real results may vary significantly.

| Metric | Target | Notes |
|--------|--------|-------|
| **Win Rate** | 65-75% | If MTF + SMC + ML confluence works as designed |
| **Average R:R** | 2.0-2.5 | Depends on entry optimization |
| **Profit Factor** | 2.0+ | Theoretical based on above |
| **Max Drawdown** | < 8% | Prop firm buffer requirement |
| **Trades/Day** | 3-8 | Quality over quantity |

---

## Roadmap

### Current Phase: Bug Fixing & Stabilization

- [x] Fix duplicate struct definitions
- [x] Remove deprecated MQL5 functions
- [ ] Adjust filter strictness (too few trades)
- [ ] Improve ONNX model loading reliability
- [ ] Add more detailed logging for debugging
- [ ] Complete backtesting validation

### Next Phase: Optimization

- [ ] Walk-Forward Analysis (WFA)
- [ ] Monte Carlo simulation
- [ ] Parameter optimization
- [ ] Reduce false signals

### Future Phase: Production Ready

- [ ] 3+ months demo testing
- [ ] Statistical validation complete
- [ ] Documentation complete
- [ ] Production release

---

## Requirements

- **Platform**: MetaTrader 5 (build 3000+)
- **Broker**: Any with XAUUSD (low spread < 30 points preferred)
- **Account**: $50,000+ recommended for proper position sizing
- **VPS**: Recommended for 24/5 operation (low latency)
- **Python**: 3.10+ (for NautilusTrader version)
- **OS**: Windows 10/11 (for MQL5), Linux/Mac (for Python)

---

## Disclaimer

> **⚠️ IMPORTANT LEGAL DISCLAIMER**

This is a **personal project** shared for **educational purposes only**. 

**Trading involves substantial risk of loss and is not suitable for all investors.**

- Past performance does not guarantee future results
- Use at your own risk
- Always test on demo accounts first
- **I am not responsible for any financial losses**
- This is NOT financial advice
- Do NOT use real money until you fully understand the system

---

## Contact & Contributions

This repository is maintained by **Franco** as a personal trading automation project.

**Telegram**: [@novtelfran](https://t.me/novtelfran)

Questions? Want to contribute? Found a bug? Feel free to reach out!

If you find this useful, give it a ⭐ star!

---

## Version History

| Version | Date | Changes |
|---------|------|---------|
| **3.30** | 2025-12 | Order Flow Edition: Footprint, Imbalance, Absorption |
| **3.20** | 2025-11 | MTF Architecture (H1+M15+M5) |
| **3.10** | 2025-11 | Entry Optimizer SL limits |
| **3.00** | 2025-10 | Singularity Edition (ML/ONNX) |
| **2.00** | 2025-09 | SMC Core Modules |
| **1.00** | 2025-08 | Initial Release |

---

*"The market is never wrong. Opinions are."* - Jesse Livermore

---

### Keywords
`algorithmic-trading` `xauusd` `gold-trading` `mql5` `metatrader5` `expert-advisor` `prop-firm` `apex-trader-funding` `ftmo` `nautilustrader` `python-trading` `smart-money-concepts` `order-flow` `machine-learning` `onnx` `quantitative-trading` `automated-trading` `scalping` `forex` `futures` `trading-bot` `quant` `financial-analysis` `institutional-trading` `footprint-chart`
