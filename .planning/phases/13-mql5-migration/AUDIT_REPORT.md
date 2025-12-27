# MQL5 Codebase Audit Report

**Phase:** 13-mql5-migration
**Task:** 1.1 - Audit existing MQL5 structure
**Agent:** FORGE-1 (FORGE-NAUTILUS v1.2)
**Date:** 2025-12-27
**CLAUDE_MD_VERSION:** 3.10.24

---

## 1. File Inventory

### 1.1 Expert Advisors (Experts/)

| File | Lines | Description | Status |
|------|-------|-------------|--------|
| EA_SCALPER_XAUUSD.mq5 | 1,315 | **PRIMARY** - Singularity Edition v3.30 | Active |
| EA_AGGRESSIVE_SCALPER.mq5 | 2,886 | Self-learning aggressive mode v3.1 | **OBSOLETE** |
| EA_ULTRA_AGGRESSIVE.mq5 | 559 | Simple Fibo+MA v2.0 | **OBSOLETE** |
| SmartPropAI_Template.mq5 | 725 | Template/reference EA | Unused |

**Total EA lines:** 5,485

### 1.2 Indicators (Indicators/)

| File | Lines | Description | Status |
|------|-------|-------------|--------|
| SMC_Visual.mq5 | 510 | Visual SMC (OB/FVG/Sessions/Structure) | Active |
| EA_Dashboard.mq5 | 728 | Dashboard panel | Active |
| Footprint_Delta.mq5 | 164 | Delta indicator | Active |
| Footprint_CVD.mq5 | 171 | Cumulative Volume Delta | Active |
| Footprint_POC.mq5 | 239 | Point of Control | Active |

**Total Indicator lines:** 1,812

### 1.3 Scripts (Scripts/)

| File | Lines | Description | Status |
|------|-------|-------------|--------|
| ParityExporter.mq5 | 103 | Export data for Python parity checks | Utility |
| TestOrderFlowAnalyzer.mq5 | 222 | Test script for OrderFlow | Test |

**Total Script lines:** 325

### 1.4 Project Includes (Include/EA_SCALPER/)

**Total: 40 files, ~22,500 lines**

#### Analysis/ (16 files)
| File | Lines | Notes |
|------|-------|-------|
| CConfluenceScorer.mqh | 2,327 | Core signal scoring |
| CFootprintAnalyzer.mqh | 1,923 | Footprint/cluster analysis |
| CRegimeDetector.mqh | 1,239 | Hurst/entropy regime detection |
| CStructureAnalyzer.mqh | 1,230 | Market structure (HH/HL/LL/LH) |
| CMTFManager.mqh | 1,159 | Multi-timeframe analysis |
| CLiquiditySweepDetector.mqh | 914 | Sweep detection |
| CAMDCycleTracker.mqh | 795 | AMD cycle tracking |
| CNewsCalendarNative.mqh | 753 | Native MQL5 calendar |
| EliteFVG.mqh | 739 | Fair Value Gap detection |
| EliteOrderBlock.mqh | 650 | Order Block detection |
| CEntryOptimizer.mqh | 582 | Entry optimization |
| CSessionFilter.mqh | 578 | Session filtering |
| **OrderFlowAnalyzer_v2.mqh** | 1,003 | **DUPLICATE** (v2) |
| **OrderFlowAnalyzer.mqh** | 505 | **OBSOLETE** (v1) |
| CNewsFilter.mqh | 412 | Fallback news filter |
| InstitutionalLiquidity.mqh | 330 | Liquidity analysis |
| OrderFlowExample.mqh | 149 | Example/test code |

#### Bridge/ (5 files)
| File | Lines | Notes |
|------|-------|-------|
| **COnnxBrain.mqh** | 844 | **ACTIVE** - ONNX ML integration v2 |
| CMemoryBridge.mqh | 510 | Shared memory bridge |
| CFundamentalsBridge.mqh | 411 | Fundamentals data bridge |
| PythonBridge.mqh | 256 | Python IPC bridge |
| **OnnxBrain.mqh** | 166 | **OBSOLETE** (v1) |

#### Execution/ (2 files)
| File | Lines | Notes |
|------|-------|-------|
| CTradeManager.mqh | 1,646 | Position/partial TP management |
| TradeExecutor.mqh | 275 | Legacy execution |

#### Risk/ (2 files)
| File | Lines | Notes |
|------|-------|-------|
| FTMO_RiskManager.mqh | 945 | **CRITICAL** - Prop firm risk |
| CDynamicRiskManager.mqh | 510 | Dynamic risk sizing |

#### Safety/ (3 files)
| File | Lines | Notes |
|------|-------|-------|
| CCircuitBreaker.mqh | 594 | Circuit breaker |
| CSpreadMonitor.mqh | 498 | Spread monitoring |
| SafetyIndex.mqh | 162 | Safety module index |

#### Context/ (3 files)
| File | Lines | Notes |
|------|-------|-------|
| CNewsWindowDetector.mqh | 817 | News window detection |
| CHolidayDetector.mqh | 531 | Holiday detection |
| ContextIndex.mqh | 24 | Context module index |

#### Strategy/ (3 files)
| File | Lines | Notes |
|------|-------|-------|
| CNewsTrader.mqh | 870 | News trading strategy |
| CStrategySelector.mqh | 713 | Strategy selection |
| StrategyIndex.mqh | 121 | Strategy module index |

#### Signal/ (3 files)
| File | Lines | Notes |
|------|-------|-------|
| CConfluenceScorer.mqh | (in Analysis) | |
| CFundamentalsIntegrator.mqh | 410 | Fundamentals integration |
| SignalScoringModule.mqh | 185 | Signal scoring |

#### Backtest/ (2 files)
| File | Lines | Notes |
|------|-------|-------|
| CBacktestRealism.mqh | 607 | Backtest realism enhancements |
| BacktestIndex.mqh | 94 | Backtest module index |

#### Core/ (1 file)
| File | Lines | Notes |
|------|-------|-------|
| Definitions.mqh | 344 | Enums, structs, constants |

---

## 2. Dependency Graph

```
EA_SCALPER_XAUUSD.mq5
|
+-- Core/Definitions.mqh
|
+-- Risk/FTMO_RiskManager.mqh
|
+-- Signal/SignalScoringModule.mqh
|   +-- Analysis/EliteOrderBlock.mqh
|   +-- Analysis/EliteFVG.mqh
|
+-- Signal/CConfluenceScorer.mqh (2,327 lines - heaviest module)
|   +-- Analysis/CRegimeDetector.mqh
|   +-- Analysis/CStructureAnalyzer.mqh
|   +-- Analysis/CLiquiditySweepDetector.mqh
|   +-- Analysis/CAMDCycleTracker.mqh
|   +-- Analysis/CFootprintAnalyzer.mqh
|   +-- Analysis/CMTFManager.mqh
|
+-- Execution/TradeExecutor.mqh
+-- Execution/CTradeManager.mqh
|   +-- Analysis/CStructureAnalyzer.mqh (attached)
|   +-- Analysis/CFootprintAnalyzer.mqh (attached)
|
+-- Analysis/CMTFManager.mqh
|   +-- Core/Definitions.mqh
|
+-- Analysis/CRegimeDetector.mqh
+-- Analysis/CLiquiditySweepDetector.mqh
+-- Analysis/CAMDCycleTracker.mqh
+-- Analysis/CStructureAnalyzer.mqh
+-- Analysis/CSessionFilter.mqh
+-- Analysis/CNewsFilter.mqh
+-- Analysis/CNewsCalendarNative.mqh
+-- Analysis/CEntryOptimizer.mqh
+-- Analysis/EliteFVG.mqh
+-- Analysis/CFootprintAnalyzer.mqh
|
+-- Bridge/COnnxBrain.mqh
    +-- Core/Definitions.mqh
```

**Key Observations:**
1. `CConfluenceScorer.mqh` is the CENTRAL hub - attaches to 8 other modules
2. `CTradeManager.mqh` manages position lifecycle with attachable analyzers
3. `FTMO_RiskManager.mqh` handles Apex/FTMO compliance
4. `CMTFManager.mqh` coordinates H1/M15/M5 timeframe analysis

---

## 3. Obsolete/Duplicated Files

### 3.1 CRITICAL Duplicates (Must Consolidate)

| Old Version | New Version | Action |
|-------------|-------------|--------|
| `OnnxBrain.mqh` (166 lines) | `COnnxBrain.mqh` (844 lines) | **DELETE** old, migrate to COnnxBrain |
| `OrderFlowAnalyzer.mqh` (505 lines) | `OrderFlowAnalyzer_v2.mqh` (1003 lines) | **DELETE** old, rename v2 to base |

### 3.2 Obsolete EAs

| File | Reason | Action |
|------|--------|--------|
| EA_AGGRESSIVE_SCALPER.mq5 | Superseded by EA_SCALPER_XAUUSD.mq5 | Archive or delete |
| EA_ULTRA_AGGRESSIVE.mq5 | Simple/superseded | Archive or delete |
| SmartPropAI_Template.mq5 | Template only | Keep as reference |

### 3.3 Obsolete Folders

| Folder | Action |
|--------|--------|
| `Include/_stdlib_backup/` | **DELETE** - Backup of standard library |

### 3.4 Standard Library Copies

The project contains full copies of MQL5 standard library in `Include/`:
- Arrays/, Canvas/, ChartObjects/, Charts/, Controls/, Expert/, Files/, Generic/, Graphics/, Indicators/, Math/, Strings/, Tools/, Trade/, WinAPI/

**Action:** These should be removed and rely on system stdlib. Currently ~150+ files duplicated unnecessarily.

---

## 4. Account Mode Handling

### 4.1 Current Status: **NOT IMPLEMENTED**

**Search results:** No references to `ACCOUNT_MARGIN_MODE`, `IsHedging`, `IsNetting`, or `hedg`/`nett` found in project code.

### 4.2 Risk Assessment: **CRITICAL**

Apex uses **NETTING** mode. If the EA was developed/tested on HEDGING accounts:
- Position aggregation differs
- Multiple positions per symbol behave differently
- `PositionSelect()` / `PositionsTotal()` semantics change

### 4.3 Required Changes

```mql5
// Add to OnInit() in EA_SCALPER_XAUUSD.mq5
ENUM_ACCOUNT_MARGIN_MODE marginMode = (ENUM_ACCOUNT_MARGIN_MODE)AccountInfoInteger(ACCOUNT_MARGIN_MODE);
if(marginMode == ACCOUNT_MARGIN_MODE_RETAIL_HEDGING)
{
    Print("WARNING: EA designed for NETTING mode. Running on HEDGING account.");
    // Optionally: return INIT_FAILED; for Apex safety
}
Print("Account Mode: ", EnumToString(marginMode));
```

**Also add to:**
- `CTradeManager.mqh` - Position lookup logic
- `FTMO_RiskManager.mqh` - Position counting
- `TradeExecutor.mqh` - Order handling

---

## 5. Dependency on External Resources

### 5.1 ONNX Models (Bridge/COnnxBrain.mqh)

Expected files in `MQL5/Files/Models/`:
- `direction_v2.onnx`
- `regime_v2.onnx`
- `scaler_params_v2.json`
- (Optional) `volatility_v1.onnx`, `fakeout_v1.onnx`

**Status:** Paths defined but models may not exist. EA handles gracefully (disables ML).

### 5.2 News Calendar

Uses MQL5 native calendar (`CalendarValueHistory()`) with fallback to hardcoded schedule.

---

## 6. Recommendations

### 6.1 Immediate Actions (Task 1.2-1.3)

1. **Add account mode check** - Critical for Apex netting mode
2. **Delete obsolete files:**
   - `Include/EA_SCALPER/Bridge/OnnxBrain.mqh`
   - `Include/EA_SCALPER/Analysis/OrderFlowAnalyzer.mqh`
   - `Include/_stdlib_backup/` (entire folder)
3. **Rename** `OrderFlowAnalyzer_v2.mqh` to `OrderFlowAnalyzer.mqh`
4. **Remove standard library copies** from project Include folder

### 6.2 Migration Priority

| Priority | Module | Reason |
|----------|--------|--------|
| P0 | Account mode check | Apex netting compliance |
| P0 | FTMO_RiskManager.mqh | DD/HWM critical for Apex |
| P1 | CTradeManager.mqh | Position management in netting |
| P1 | COnnxBrain.mqh | Ensure ONNX paths valid |
| P2 | CConfluenceScorer.mqh | Core logic review |
| P2 | Time gates | 4:30 PM / 4:55 PM ET enforcement |

### 6.3 Code Quality Notes

- **Good:** Modular architecture, clear separation of concerns
- **Good:** Index files (StrategyIndex.mqh, etc.) for clean includes
- **Issue:** Temporal correctness not explicitly verified (look-ahead risk)
- **Issue:** Some files mix Portuguese/English comments
- **Issue:** Version suffixes in filenames (_v2) should be avoided

---

## 7. Summary Metrics

| Metric | Value |
|--------|-------|
| Total project files | 51 (.mq5/.mqh) |
| Total project lines | ~30,000 |
| Obsolete files | 4 |
| Duplicate files | 2 pairs |
| Account mode handling | **MISSING** |
| Apex time gates | Present in FTMO_RiskManager |
| HWM tracking | Present in FTMO_RiskManager |

---

**Status:** COMPLETE
**Next Task:** 1.2 - Create module interface map
**Handoff:** Ready for REVIEWER validation

---

```
AGENT: FORGE-NAUTILUS
VERSION: 1.2
CLAUDE_MD_VERSION: 3.10.24
STATUS: COMPLETE
BUGS_FIXED: 0
```
