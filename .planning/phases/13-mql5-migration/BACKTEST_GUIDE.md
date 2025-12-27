# Integration Backtest Guide

**Version:** 1.0.0
**Created:** 2025-12-27
**Author:** FORGE-3 (Testing)
**Task:** 7.4 - MQL5 Migration MEGA-PLAN

---

## Overview

This guide provides step-by-step instructions for Franco to run integration backtests of the EA_SCALPER_XAUUSD in MetaTrader 5. Since we cannot run MT5 Strategy Tester from WSL, all compilation and testing must be performed in the Windows environment.

---

## Prerequisites

1. **MetaTrader 5** installed on Windows
2. **MetaEditor** accessible (F4 in MT5)
3. **XAUUSD symbol** available from your broker
4. **EA files** synced from the repository to your MT5 installation folder

### File Locations

The EA files should be placed in your MT5 data folder:
- Windows path: `C:\Users\[USERNAME]\AppData\Roaming\MetaQuotes\Terminal\[TERMINAL_ID]\MQL5\`
- Or use "Open Data Folder" from MT5 menu (File > Open Data Folder)

---

## Step 1: Compilation

Open MetaEditor (press F4 in MT5) and compile files **in the following order** to resolve dependencies correctly:

### 1.1 Core Definitions (Compile First)
```
MQL5/Include/EA_SCALPER/Core/Definitions.mqh
MQL5/Include/EA_SCALPER/Core/Version.mqh
```

### 1.2 Risk Components
```
MQL5/Include/EA_SCALPER/Risk/CApexDDTracker.mqh
MQL5/Include/EA_SCALPER/Risk/CApexTimeHandler.mqh
MQL5/Include/EA_SCALPER/Risk/CWallClockEnforcer.mqh
MQL5/Include/EA_SCALPER/Risk/CUnifiedRiskPolicy.mqh
MQL5/Include/EA_SCALPER/Risk/CVirtualGate.mqh
MQL5/Include/EA_SCALPER/Risk/CGapCooldown.mqh
MQL5/Include/EA_SCALPER/Risk/FTMO_RiskManager.mqh
```

### 1.3 Safety Components
```
MQL5/Include/EA_SCALPER/Safety/CSpreadMonitor.mqh
```

### 1.4 UI Components (if applicable)
```
MQL5/Include/EA_SCALPER/UI/*.mqh
```

### 1.5 Main EA and Indicators
```
MQL5/Experts/EA_SCALPER_XAUUSD.mq5
MQL5/Indicators/SMC_Visual.mq5
MQL5/Indicators/TradingDashboard.mq5
```

### 1.6 Test Scripts
```
MQL5/Scripts/Tests/Test_DDTracker.mq5
MQL5/Scripts/Tests/Test_TimeHandler.mq5
MQL5/Scripts/Tests/Test_WallClock.mq5
MQL5/Scripts/TestGapCooldown.mq5
```

### Compilation Success Criteria
- **ZERO errors** for all files
- Warnings are acceptable BUT review any:
  - Type conversion warnings (potential precision loss)
  - Array initialization warnings
  - Unused variable warnings (may indicate dead code)

---

## Step 2: Run Test Scripts FIRST

Before running any backtest, execute the disproof test scripts to validate core components. These tests run instantly and must ALL PASS.

### How to Run Test Scripts
1. Open MT5 Navigator (Ctrl+N)
2. Expand "Scripts" section
3. Find each test script
4. Drag and drop onto any chart (XAUUSD recommended)
5. Check "Experts" tab (Ctrl+E) for results

### 2.1 Test_DDTracker.mq5
**Purpose:** Validate Drawdown Tracker calculations
**Location:** Navigator > Scripts > Tests > Test_DDTracker

**Expected Output:**
```
*** ALL TESTS PASSED ***
CApexDDTracker implementation is VERIFIED
```

**What It Tests:**
- HWM double-count prevention (CRITICAL)
- Severity threshold boundaries (6 levels)
- Dynamic daily limit formula
- Daily DD thresholds
- Combined DD blocking logic
- Edge cases (zero equity, negative equity, precision)

### 2.2 Test_TimeHandler.mq5
**Purpose:** Validate DST algorithm and time gates
**Location:** Navigator > Scripts > Tests > Test_TimeHandler

**Expected Output:**
```
ALL TESTS PASSED!
CApexTimeHandler DST algorithm is VALIDATED.
Time state transitions are CORRECT.
```

**What It Tests:**
- DST boundary transitions (2024-2030)
- Time state thresholds (4:30/4:55/4:59 PM ET)
- nth Sunday algorithm for DST dates
- Integration with live time handler
- Edge cases (year boundary, leap year)

### 2.3 Test_WallClock.mq5
**Purpose:** Validate idempotent wall-clock enforcement
**Location:** Navigator > Scripts > Tests > Test_WallClock

**Expected Output:**
```
============ ALL TESTS PASSED ============
DISPROOF TESTS VALIDATED:
  [OK] Timer gaps - flatten executes despite delay
  [OK] Idempotency - flatten executes exactly once
  [OK] EA restart - immediate flatten on startup
  [OK] State progression - correct transitions
  [OK] Session reset - allows new flatten
  [OK] Minute boundaries - correct state at each threshold
```

**What It Tests:**
- Timer gap recovery (OnTimer delayed by minutes)
- Idempotent flatten (only once per session)
- EA restart after deadline handling
- State progression (NORMAL -> BLOCK_NEW -> EMERGENCY -> HALTED)
- Session reset behavior

### 2.4 TestGapCooldown.mq5
**Purpose:** Validate gap detection and cooldown
**Location:** Navigator > Scripts > TestGapCooldown

**Expected Output:**
```
ALL TESTS PASSED!
CGapCooldown is ready for use.
```

**What It Tests:**
- Gap detection threshold
- Cooldown duration enforcement
- Weekend gap simulation
- Force/clear cooldown methods
- Configuration setters

---

## Step 3: Strategy Tester Configuration

After all test scripts pass, configure the Strategy Tester for integration backtesting.

### Open Strategy Tester
- Menu: View > Strategy Tester (or Ctrl+R)

### 3.1 Basic Settings
| Setting | Value | Notes |
|---------|-------|-------|
| Expert Advisor | EA_SCALPER_XAUUSD | Select from dropdown |
| Symbol | XAUUSD | Must match broker's gold symbol |
| Period | M5 | Primary execution timeframe |
| Date Range | 2024.01.01 - 2024.12.31 | Full year for seasonality |
| Forward | No forward testing | |
| Execution | Normal | |
| Deposit | 50,000 USD | Apex-sized account |
| Leverage | 1:100 | Typical prop firm |

### 3.2 Model Selection
| Model | Speed | Accuracy | Recommended Use |
|-------|-------|----------|-----------------|
| Every tick | Slowest | Highest | Final validation |
| Every tick based on real ticks | Slow | Highest | Best for XAUUSD |
| 1 minute OHLC | Medium | Good | Initial testing |
| Open prices only | Fastest | Low | Quick sanity check |

**Recommendation:** Start with "1 minute OHLC" for faster iteration, then validate with "Every tick" before any production decision.

### 3.3 Spread Configuration
| Option | Value | Notes |
|--------|-------|-------|
| Current | Variable | Uses broker's current spread |
| Fixed | 30 points | Conservative for XAUUSD |
| Custom | 20-50 points | Adjust based on your broker |

**Warning:** Unrealistic low spreads will inflate results. Use 30+ points for conservative estimates.

### 3.4 EA Input Parameters (Recommended for Backtest)
```
Risk Per Trade = 0.5%
Max Daily Loss = 5.0%
Max Total Loss = 10.0%
Max Trades Per Day = 20
Execution Score Threshold = 50
ET Offset vs GMT = -5 (or -4 during EDT)
Enforce Apex Cutoff = true
News Filter Enabled = false  (faster backtest)
Use ML = false (test logic first)
```

---

## Step 4: Validation Criteria (MUST PASS)

### 4.1 Apex Compliance Checks (CRITICAL)

| Criterion | Requirement | How to Verify |
|-----------|-------------|---------------|
| No overnight positions | 100% flat by 4:59 PM ET | Check journal for "HALTED" messages |
| Max drawdown | < 5% from HWM | Check Report > Max Drawdown |
| Time gates | No new trades after 4:30 PM ET | Check trade history timestamps |
| Emergency close | Triggers at 4:55 PM ET if needed | Check journal for "EMERGENCY" |
| DD tracking | HWM calculation correct | Check journal for DD severity logs |

### 4.2 Journal Log Analysis

Open Experts tab (Ctrl+E) and look for these critical entries:

#### Expected Logs (Normal Operation)
```
[INFO] CApexTimeHandler initialized
[INFO] CApexDDTracker initialized
[INFO] Session started - Equity: 50000.00
[DEBUG] Time state: NORMAL
```

#### Time Gate Logs (End of Day)
```
[WARN] Time state: BLOCK_NEW - No new trades after 4:30 PM ET
[ALERT] Time state: EMERGENCY - Preparing to flatten
[CRITICAL] EMERGENCY FLATTEN triggered at 4:59 PM ET
[INFO] All positions closed - Session complete
```

#### DD Tracking Logs
```
[DEBUG] DD severity: NORMAL (0.5% trailing, 0.3% daily)
[WARN] DD severity: WARN (3.1% trailing)
[ALERT] DD severity: CRITICAL (4.2% trailing) - Trading halted
```

#### Gap Detection Logs
```
[WARN] GAP detected: 45 minutes since last bar
[INFO] Gap cooldown active for 15 minutes
```

### 4.3 Visual HUD Verification

If using the TradingDashboard indicator:
- DD gauges display correctly
- Time to close countdown accurate
- Risk status colors match severity

---

## Step 5: Expected Results

### Performance Metrics (Secondary Focus)
The backtest may show:
- Profitable or near-breakeven (not the primary focus)
- Win rate > 40% typical for scalping
- Profit factor > 1.0 indicates edge

### Compliance Metrics (PRIMARY Focus)
| Metric | Expected | Critical |
|--------|----------|----------|
| Overnight positions | 0 | YES |
| Max DD from HWM | < 5% | YES |
| Trades after 4:30 PM | 0 new trades | YES |
| Time gate violations | 0 | YES |
| Emergency flattens | Recorded in log | YES |

### Report Artifacts to Save
1. **HTML Report:** Strategy Tester > Results > Save Report
2. **Journal Log:** Copy from Experts tab
3. **Trade History:** Export to CSV
4. **Equity Curve Screenshot:** For visual DD analysis

---

## Step 6: Troubleshooting

### Common Issues

#### Compilation Errors
| Error | Solution |
|-------|----------|
| "Cannot open include file" | Check file paths and folder structure |
| "Undefined identifier" | Compile dependencies first |
| "Type mismatch" | Review function parameter types |

#### Runtime Errors
| Error | Solution |
|-------|----------|
| "Array out of range" | Check indicator buffer sizes |
| "Zero divide" | Add division-by-zero guards |
| "Trade context busy" | Reduce trade frequency |

#### Backtest Issues
| Issue | Solution |
|-------|----------|
| No trades generated | Lower execution threshold |
| Too many trades | Raise execution threshold |
| Unrealistic results | Increase spread, use real ticks |
| Overnight positions | Check time handler initialization |

---

## Step 7: Post-Backtest Actions

### If ALL Tests Pass
1. Document results in DOCS/04_REPORTS/DECISIONS/
2. Proceed to paper trading phase (see CLAUDE.md production_workflow)
3. Create optimization plan if parameters need tuning

### If ANY Test Fails
1. Document failure in DOCS/04_REPORTS/DECISIONS/
2. Create issue tracking in BUGFIX_LOG.md
3. Fix and re-run affected test scripts
4. Re-run backtest after fixes

---

## Appendix A: Quick Reference Commands

### MT5 Keyboard Shortcuts
| Action | Shortcut |
|--------|----------|
| MetaEditor | F4 |
| Strategy Tester | Ctrl+R |
| Navigator | Ctrl+N |
| Experts Tab | Ctrl+E |
| Compile | F7 |
| Compile All | Ctrl+Shift+F7 |

### MetaEditor Tips
- Drag and drop files to compile in order
- Use "Compile All" after initial setup
- Check "Errors" tab for any issues

---

## Appendix B: File Checklist

Before running backtests, verify these files exist and compile:

**Core Files:**
- [ ] `MQL5/Include/EA_SCALPER/Core/Definitions.mqh`
- [ ] `MQL5/Include/EA_SCALPER/Core/Version.mqh`

**Risk Components:**
- [ ] `MQL5/Include/EA_SCALPER/Risk/CApexDDTracker.mqh`
- [ ] `MQL5/Include/EA_SCALPER/Risk/CApexTimeHandler.mqh`
- [ ] `MQL5/Include/EA_SCALPER/Risk/CWallClockEnforcer.mqh`
- [ ] `MQL5/Include/EA_SCALPER/Risk/CUnifiedRiskPolicy.mqh`
- [ ] `MQL5/Include/EA_SCALPER/Risk/CVirtualGate.mqh`
- [ ] `MQL5/Include/EA_SCALPER/Risk/CGapCooldown.mqh`

**Main EA:**
- [ ] `MQL5/Experts/EA_SCALPER_XAUUSD.mq5`

**Test Scripts:**
- [ ] `MQL5/Scripts/Tests/Test_DDTracker.mq5`
- [ ] `MQL5/Scripts/Tests/Test_TimeHandler.mq5`
- [ ] `MQL5/Scripts/Tests/Test_WallClock.mq5`
- [ ] `MQL5/Scripts/TestGapCooldown.mq5`

---

*End of Backtest Guide*
