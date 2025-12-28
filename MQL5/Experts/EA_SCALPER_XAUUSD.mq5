//+------------------------------------------------------------------+
//|                                            EA_SCALPER_XAUUSD.mq5 |
//|                           EA_SCALPER_XAUUSD - Singularity Edition |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Franco - Singularity Edition"
#property link      "https://www.mql5.com"
#property version   "4.3"
#property strict

/*
   v4.3 - Recovery/Hedge Entry Logic (FORGE-3)
   ===========================================
   New feature: Allow recovery entries when existing position is losing,
   IF a better signal opportunity exists. Key constraints:
   - Recovery != Martingale (NO lot doubling)
   - Must have BETTER signal (score boost required)
   - Respects Apex DD limits at all times
   - Configurable via input parameters
   - Optional hedge entries for AGGRESSIVE profile

   v4.0 - Apex-Safe Risk Infrastructure (Phase 13 Migration)
   ==========================================================
   Complete migration from Python/NautilusTrader to MQL5 with:
   - 6-level DD taxonomy (WARN/CAUTION/CRITICAL/HALT/REDUCE/TERMINATED)
   - HWM tracking via AccountEquity() only (CRITIC fix)
   - DST-safe ET handling with TimeGMT() base
   - Idempotent wall-clock enforcement (catches missed OnTimer)
   - VirtualGate, UnifiedRiskPolicy, GapCooldown gates
   - Visual HUD for investor demo

   Previous versions:
   - v3.30: Order Flow + Multi-Timeframe Architecture
   - v3.20: MTF Manager integration
   - v3.10: SMC core (OB, FVG, Liquidity sweeps)
*/

//--- Core Includes
#include <EA_SCALPER/Core/Definitions.mqh>
#include <EA_SCALPER/Risk/FTMO_RiskManager.mqh>
#include <EA_SCALPER/Signal/SignalScoringModule.mqh>
#include <EA_SCALPER/Signal/CConfluenceScorer.mqh>
#include <EA_SCALPER/Execution/TradeExecutor.mqh>
#include <EA_SCALPER/Execution/CTradeManager.mqh>

//--- Multi-Timeframe Manager (NEW in v3.20)
#include <EA_SCALPER/Analysis/CMTFManager.mqh>

//--- Analysis Modules (Singularity)
#include <EA_SCALPER/Analysis/CRegimeDetector.mqh>
#include <EA_SCALPER/Analysis/CLiquiditySweepDetector.mqh>
#include <EA_SCALPER/Analysis/CAMDCycleTracker.mqh>
#include <EA_SCALPER/Analysis/CStructureAnalyzer.mqh>
#include <EA_SCALPER/Analysis/CSessionFilter.mqh>
#include <EA_SCALPER/Analysis/CNewsFilter.mqh>
#include <EA_SCALPER/Analysis/CNewsCalendarNative.mqh>  // NEW: Native MQL5 Calendar
#include <EA_SCALPER/Analysis/CEntryOptimizer.mqh>
#include <EA_SCALPER/Analysis/EliteFVG.mqh>

//--- Order Flow / Footprint Analysis (NEW v3.30)
#include <EA_SCALPER/Analysis/CFootprintAnalyzer.mqh>

//--- v4.2: New Strategy Modules (TrendFollow + AdaptiveRouter)
#include <EA_SCALPER/Strategy/CTrendFollowStrategy.mqh>
#include <EA_SCALPER/Strategy/CAdaptiveRouter.mqh>

//--- Signal Modules (CConfluenceScorer moved to Core Includes for dependency order)

//--- Bridge (Phase 2)
//#include <EA_SCALPER/Bridge/PythonBridge.mqh>
#include <EA_SCALPER/Bridge/COnnxBrain.mqh>

//--- v4.0: New Apex Risk Components (Task 4.1 Integration)
#include <EA_SCALPER/Core/Version.mqh>
#include <EA_SCALPER/Risk/CApexDDTracker.mqh>
#include <EA_SCALPER/Risk/CApexTimeHandler.mqh>
#include <EA_SCALPER/Risk/CWallClockEnforcer.mqh>
#include <EA_SCALPER/Risk/CUnifiedRiskPolicy.mqh>
#include <EA_SCALPER/Risk/CVirtualGate.mqh>
#include <EA_SCALPER/Risk/CGapCooldown.mqh>
#include <EA_SCALPER/Risk/CRecoveryManager.mqh>  // v4.3: Recovery/Hedge entry logic
#include <EA_SCALPER/Risk/CRiskProfileManager.mqh>  // v4.3: Configurable risk profiles
#include <EA_SCALPER/Safety/CSpreadMonitor.mqh>
#include <EA_SCALPER/UI/CRiskHUD.mqh>

//--- Mode presets (quick configuration profiles)
enum ENUM_ModePreset
{
   MODE_CUSTOM = 0,       // Use manual inputs below
   MODE_CONSERVATIVE,     // Lowest risk, strict filters
   MODE_BALANCED,         // Default profile (current v3.30 baseline)
   MODE_ELITE,            // Higher quality flow, moderate risk boost
   MODE_RISK_ON           // Max risk within FTMO guardrails
};

struct SModeConfig
{
   double risk_per_trade;
   double max_daily_loss;
   double soft_stop;
   double max_total_loss;
   int    max_trades_per_day;
   int    execution_threshold;
   double min_mtf_confluence;
   bool   require_htf_align;
   bool   require_mtf_zone;
   bool   require_ltf_confirm;
   bool   use_mtf;
   bool   aggressive_mode;
   bool   use_footprint_boost;
   bool   use_bandit_context;
   double min_rr;
   double target_rr;
   int    max_wait_bars;
   int    max_spread_points;
};

//--- Input Parameters: Risk Management
input group "=== Risk Management (FTMO) ==="
input ENUM_RISK_PROFILE InpRiskProfile = RISK_BALANCED; // Risk Profile (SAFE/BALANCED/AGGRESSIVE)
input double   InpRiskPerTrade      = 0.5;      // Risk Per Trade (%)
input double   InpMaxDailyLoss      = 4.5;      // Max Daily Loss (%) - Buffer before 5% Apex limit
input double   InpSoftStop          = 4.0;      // Soft Stop Level (%)
input double   InpMaxTotalLoss      = 9.0;      // Max Total Loss (%) - Buffer before 10% limit
input int      InpMaxTradesPerDay   = 20;       // Max Trades Per Day
input int      InpETOffset          = -5;       // ET offset vs GMT (EST=-5, EDT=-4)
input bool     InpEnforceApexCutoff = true;     // Enforce Apex hard close at 16:55 ET (ALWAYS ON for safety)
input int      InpApexCutoffMinute  = 50;       // Minute of 16:xx ET to start flattening


//--- Input Parameters: Scoring Engine
input group "=== Scoring Engine ==="
input int      InpExecutionThreshold = 60;      // Minimum score (60/100 = TIER_C quality - was 50, too low)
input int      InpVoteMargin         = 2;       // Direction vote margin (2 = more signals, 3 = stricter)
input double   InpWeightTech         = 0.6;     // Weight: Technical
input double   InpWeightFund         = 0.25;    // Weight: Fundamental
input double   InpWeightSent         = 0.15;    // Weight: Sentiment

//--- Input Parameters: Execution
input group "=== Execution Settings ==="
input int      InpSlippage          = 30;       // Max Slippage (points) - 30 typical for XAUUSD
input int      InpMagicNumber       = 123456;   // Magic Number
input string   InpTradeComment      = "SINGULARITY"; // Trade Comment

//--- Input Parameters: Recovery/Hedge Entry (NEW v4.3)
input group "=== Recovery Entry Settings ==="
input bool     InpAllowRecoveryEntry = true;    // Allow Recovery Entries
input double   InpRecoveryMinLoss    = -0.5;    // Min Loss % for Recovery (e.g., -0.5 = 0.5% loss)
input int      InpRecoveryScoreBoost = 10;      // Score Boost Required (new > old + boost)
input int      InpRecoveryCooldown   = 5;       // Cooldown Bars (between entries)
input int      InpMaxRecoveryPerDay  = 2;       // Max Recovery Entries Per Day
input double   InpRecoverySizeMult   = 0.5;     // Recovery Size Multiplier (<=1.0, NOT martingale)
input bool     InpAllowHedge         = false;   // Allow Hedge Entries (opposite direction)
input int      InpHedgeMinScore      = 80;      // Hedge Minimum Score (TIER_A = 80)

//--- Input Parameters: Session Filter
input group "=== Session & Time Filters ==="
input bool     InpDisableAllTimeGates = false; // Disable time gates (OFF for realistic testing)
input bool     InpDisableAMDGate      = false; // Disable AMD requirement (OFF for ICT sequence)
input bool     InpAllowAsian          = false; // Allow Asian Session (OFF = skip low-quality session)
input bool     InpAllowLateNY       = false;   // Allow Late NY (OFF = skip low-quality session)
input int      InpGMTOffset         = 2;        // Broker GMT Offset (FTMO = GMT+2)
input int      InpFridayCloseHour   = 14;       // Friday Close Hour (GMT)
input bool     InpDisableFridayClose = false;   // Disable Friday Close (FALSE for Apex - MUST close Friday)

//--- Input Parameters: News Filter
input group "=== News Filter ==="
input bool     InpNewsFilterEnabled = true;     // Enable News Filter (DEFAULT ON for live trading safety)
input bool     InpBlockHighImpact   = true;     // Block High-Impact News (TRUE for Apex safety)
input bool     InpBlockMediumImpact = false;    // Block Medium-Impact News

//--- Input Parameters: Machine Learning / Safeguards
input group "=== Machine Learning (ONNX) ==="
input bool     InpUseML             = false;    // Enable ONNX Direction Model
input double   InpMLThreshold       = 0.65;     // Min confidence to accept ML signal
input int      InpMLCacheSeconds    = 60;       // Cache horizon for ML predictions
input bool     InpLogML             = false;    // Log ML outputs for debugging
input int      InpMaxSpreadPoints   = 40;       // Gate 1: Max spread (points) - tight for quality entries

//--- Input Parameters: Entry Optimization
input group "=== Entry Optimization ==="
input double   InpMinRR             = 1.5;      // Minimum R:R Ratio (1.5 = quality risk/reward)
input double   InpTargetRR          = 2.5;      // Target R:R Ratio
input int      InpMaxWaitBars       = 10;       // Max Bars to Wait for Entry

//--- Input Parameters: Debug Mode
input group "=== Debug Mode (Diagnostics) ==="
input bool     InpDebugMode         = true;     // Enable Debug Logging (DEFAULT: ON)
input int      InpDebugInterval     = 30;       // Debug Log Interval (seconds)

//--- Input Parameters: Multi-Timeframe (NEW v3.20)
input group "=== Multi-Timeframe Settings ==="
input ENUM_TIMEFRAMES InpEntryTimeframe  = PERIOD_M15;  // Entry Timeframe (signal generation)
input ENUM_TIMEFRAMES InpMgmtTimeframe   = PERIOD_H1;   // Management Timeframe (regime/trend analysis)
input ENUM_TIMEFRAMES InpLTFTimeframe    = PERIOD_M5;   // LTF Timeframe (confirmation/execution)
input bool     InpUseMTF            = false;   // Enable MTF Architecture (OFF = unreliable in backtest)
input double   InpMinMTFConfluence  = 0.5;      // Min MTF Confluence Score (0.5 = moderate filter)
input bool     InpRequireHTFAlign   = false;   // Require H1 Trend Alignment (OFF = optional)
input bool     InpRequireMTFZone    = true;    // Require M15 Structure Zone (ON = SMC validation)
input bool     InpRequireLTFConfirm = false;    // Require M5 Confirmation (OFF = not overly strict)

//--- Input Parameters: Mode/Boosts
input group "=== Mode Settings ==="
input ENUM_ModePreset InpModePreset = MODE_ELITE;  // Quick preset (ELITE = best quality trades)
input bool     InpUseFootprintBoost = true;     // Use footprint veto/boost (ON = institutional flow filter)
input bool     InpUseBanditContext  = true;     // Use contextual bandit-lite gating (ON = adaptive filtering)
input bool     InpAggressiveMode    = true;     // Enable aggressive boosts (ON for ELITE mode)

//--- Global Objects (Core)
CFTMO_RiskManager    g_RiskManager;
CSignalScoringModule g_ScoringEngine;
CTradeExecutor       g_Executor;
CTradeManager        g_TradeManager;

//--- Multi-Timeframe Manager (NEW v3.20)
CMTFManager          g_MTF;

//--- Singularity Analysis Objects
CRegimeDetector         g_Regime;
CStructureAnalyzer      g_Structure;
CLiquiditySweepDetector g_Sweep;
CAMDCycleTracker        g_AMD;
CSessionFilter          g_Session;
CNewsFilter             g_News;           // Fallback: hardcoded calendar
CNewsCalendarNative     g_NewsNative;     // PRIMARY: MQL5 native calendar
CEntryOptimizer         g_EntryOpt;
CEliteFVGDetector       g_FVG;
CConfluenceScorer       g_Confluence;

// v3.31: Footprint/Order Flow Analyzer (FORGE genius upgrade)
CFootprintAnalyzer      g_Footprint;

// v4.2: Strategy Modules (TrendFollow + AdaptiveRouter)
CTrendFollowStrategy    g_TrendFollow;
CAdaptiveRouter         g_Router;

//--- v4.0: Apex Risk Components (Task 4.1 Integration)
CApexDDTracker          g_DDTracker;
CApexTimeHandler        g_TimeHandler;
CWallClockEnforcer      g_WallClock;
CSpreadMonitor          g_SpreadMonitorV2;   // Renamed to avoid conflict with legacy spread check
CVirtualGate            g_VirtualGate;
CGapCooldown            g_GapCooldown;
CUnifiedRiskPolicy      g_RiskPolicy;
CRiskHUD                g_RiskHUD;           // Visual HUD for investor display
CRecoveryManager        g_RecoveryManager;   // v4.3: Recovery/Hedge entry logic
CRiskProfileManager     g_RiskProfile;       // v4.3: Configurable risk profiles

//--- ML Brain
COnnxBrain              g_OnnxBrain;
bool                    g_MLEnabled = false;

//--- Global State
bool g_IsEmergencyMode = false;

// v4.1: Current regime strategy (GENIUS)
SRegimeStrategy         g_CurrentStrategy;

// Active mode configuration (populated by ApplyModePreset)
SModeConfig             g_ModeCfg;

// Adaptive risk helpers
double                  g_spread_buff[20];
int                     g_spread_idx = 0;
int                     g_atr_fast_handle = INVALID_HANDLE;
int                     g_atr_slow_handle = INVALID_HANDLE;
int                     g_bucket_trades[96];

//+------------------------------------------------------------------+
//| Apply trading mode preset                                        |
//+------------------------------------------------------------------+
void ApplyModePreset()
{
   // v4.2: ALWAYS use input values - no more hardcoded presets
   // The user controls everything via inputs. Presets are just for documentation.
   g_ModeCfg.risk_per_trade     = InpRiskPerTrade;
   g_ModeCfg.max_daily_loss     = InpMaxDailyLoss;
   g_ModeCfg.soft_stop          = InpSoftStop;
   g_ModeCfg.max_total_loss     = InpMaxTotalLoss;
   g_ModeCfg.max_trades_per_day = InpMaxTradesPerDay;
   g_ModeCfg.execution_threshold= InpExecutionThreshold;
   g_ModeCfg.min_mtf_confluence = InpMinMTFConfluence;
   g_ModeCfg.require_htf_align  = InpRequireHTFAlign;
   g_ModeCfg.require_mtf_zone   = InpRequireMTFZone;
   g_ModeCfg.require_ltf_confirm= InpRequireLTFConfirm;
   g_ModeCfg.use_mtf            = InpUseMTF;
   g_ModeCfg.aggressive_mode    = InpAggressiveMode;
   g_ModeCfg.use_footprint_boost= InpUseFootprintBoost;
   g_ModeCfg.use_bandit_context = InpUseBanditContext;
   g_ModeCfg.min_rr             = InpMinRR;
   g_ModeCfg.target_rr          = InpTargetRR;
   g_ModeCfg.max_wait_bars      = InpMaxWaitBars;
   g_ModeCfg.max_spread_points  = InpMaxSpreadPoints;

   // Log the actual config being used
   PrintFormat("[CONFIG] Mode=%s Risk=%.2f%% Threshold=%d MinRR=%.1f Spread=%d HTF=%s MTF=%s",
               EnumToString(InpModePreset),
               g_ModeCfg.risk_per_trade,
               g_ModeCfg.execution_threshold,
               g_ModeCfg.min_rr,
               g_ModeCfg.max_spread_points,
               g_ModeCfg.require_htf_align ? "ON" : "OFF",
               g_ModeCfg.use_mtf ? "ON" : "OFF");

   // Safety clamps aligned to FTMO guardrails
   g_ModeCfg.risk_per_trade     = MathMin(1.0, MathMax(0.1, g_ModeCfg.risk_per_trade)); // 0.1% - 1.0%
   g_ModeCfg.max_daily_loss     = MathMin(5.0, g_ModeCfg.max_daily_loss);
   g_ModeCfg.max_total_loss     = MathMin(10.0, g_ModeCfg.max_total_loss);
   g_ModeCfg.max_spread_points  = MathMax(20,  g_ModeCfg.max_spread_points);

   PrintFormat("[Mode] %s applied | Risk=%.2f%% | Exec>=%d | RR>=%.1f/%.1f | Spread<=%d | MTF=%s | Aggressive=%s",
               EnumToString(InpModePreset),
               g_ModeCfg.risk_per_trade,
               g_ModeCfg.execution_threshold,
               g_ModeCfg.min_rr,
               g_ModeCfg.target_rr,
               g_ModeCfg.max_spread_points,
               g_ModeCfg.use_mtf ? "ON" : "OFF",
               g_ModeCfg.aggressive_mode ? "ON" : "OFF");
}

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{
   Print("=== EA_SCALPER_XAUUSD v3.30 Singularity Order Flow Edition ===");
   Print("=== HTF=H1 | MTF=M15 | LTF=M5 (Execution) ===");

   // Apply selected trading mode before initializing modules
   ApplyModePreset();

   // v4.3: Initialize Risk Profile Manager (FIRST - controls risk parameters)
   if(!g_RiskProfile.Init(InpRiskProfile))
   {
      Print("Critical Error: Risk Profile Manager Initialization Failed!");
      return(INIT_FAILED);
   }

   // v4.2: InpDisableAllTimeGates ONLY affects time/session gates, NOT quality thresholds
   // The name says "TimeGates" - it should only disable time-related gates, not scoring!
   if(InpDisableAllTimeGates)
   {
      Print("[TIME BYPASS] InpDisableAllTimeGates=true - Time/session gates disabled, but quality thresholds preserved");
   }

   // 1. Initialize Risk Manager (FTMO Compliance) - with symbol/magic for safe flatten
   if(!g_RiskManager.Init(g_ModeCfg.risk_per_trade, g_ModeCfg.max_daily_loss, g_ModeCfg.max_total_loss, g_ModeCfg.max_trades_per_day, g_ModeCfg.soft_stop, 1.0, InpETOffset, _Symbol, InpMagicNumber))
   {
      Print("Critical Error: Risk Manager Initialization Failed!");
      return(INIT_FAILED);
   }
   // 2. Initialize Scoring Engine
   if(!g_ScoringEngine.Init(InpWeightTech, InpWeightFund, InpWeightSent))
   {
      Print("Critical Error: Scoring Engine Initialization Failed!");
      return(INIT_FAILED);
   }

   // 3. Initialize Executor (Legacy)
   g_Executor.Init(InpMagicNumber, InpSlippage, InpTradeComment);
   
   // 4. Initialize Trade Manager (New - with partial TPs)
   if(!g_TradeManager.Init(InpMagicNumber, InpSlippage))
   {
      Print("Warning: Trade Manager failed - using legacy executor");
   }
   g_TradeManager.SetManagementMode(MGMT_PARTIAL_TP);
   g_TradeManager.ConfigurePartials(1.5, 2.5, 0.40, 0.50);  // 40% at 1.5R, 30% at 2.5R

   // v4.3: Set max positions from RiskProfile and sync with broker
   int max_pos = g_RiskProfile.IsInitialized() ? g_RiskProfile.GetMaxPositions() : 1;
   g_TradeManager.SetMaxPositions(max_pos);
   g_TradeManager.SyncWithBrokerPositions();  // Recover state on EA restart
   Print("TradeManager: Max positions set to ", max_pos, " (from RiskProfile)");

   // v4.2 GENIUS: Attach analyzers for intelligent trade management
   // Structure-based trailing: Never trail through valid swing levels
   g_TradeManager.AttachStructureAnalyzer(&g_Structure);
   g_TradeManager.SetStructureTrailBuffer(0.2);  // 0.2 ATR buffer from swing level
   
   // Footprint exit: Detect absorption/exhaustion signals for early exits
   g_TradeManager.AttachFootprintAnalyzer(&g_Footprint);
   g_TradeManager.SetAbsorptionExitConfidence(60);  // Min 60% confidence for exit signal

   // 5. Initialize Multi-Timeframe Manager (NEW v3.20)
   if(g_ModeCfg.use_mtf)
   {
      if(!g_MTF.Init(_Symbol))
      {
         Print("Warning: MTF Manager initialization failed - using single TF mode");
      }
      else
      {
         g_MTF.SetMinConfluence(g_ModeCfg.min_mtf_confluence);
         Print("MTF Manager initialized: H1+M15+M5 architecture active");
      }
   }

   // 6. Initialize Singularity Analysis Modules
   // Regime detector
   g_Regime.SetHurstWindow(100);
   g_Regime.SetEntropyWindow(100);
   
   // Structure analyzer
   g_Structure.SetSwingStrength(3);
   g_Structure.SetLookback(100);
   
   // Sweep detector
   if(!g_Sweep.Initialize())
      Print("Warning: Sweep detector initialization issue");
   
   // AMD Cycle tracker
   if(!g_AMD.Initialize())
      Print("Warning: AMD tracker initialization issue");
   
   // Session filter
   if(!g_Session.Initialize(InpGMTOffset))
   {
      Print("Warning: Session filter initialization issue");
   }
   g_Session.AllowAsianTrading(InpAllowAsian);
   g_Session.AllowLateNYTrading(InpAllowLateNY);
   g_Session.SetFridayCloseHour(InpFridayCloseHour);
   g_Session.SetFridayCloseEarly(!InpDisableFridayClose);  // Disable for backtest
   
   // News filter (fallback - hardcoded calendar)
   if(!g_News.Initialize(InpGMTOffset))
   {
      Print("Warning: News filter initialization issue");
   }
   g_News.SetEnabled(InpNewsFilterEnabled);
   g_News.BlockHighImpact(InpBlockHighImpact);
   g_News.BlockMediumImpact(InpBlockMediumImpact);
   
   // Native MQL5 Calendar (PRIMARY - real-time from MetaQuotes)
   if(!g_NewsNative.Init(30, 15))  // 30 min before, 15 min after
   {
      Print("Warning: Native calendar initialization issue - using fallback");
   }
   else
   {
      Print("Native MQL5 Calendar: ACTIVE - ", g_NewsNative.GetCachedEventCount(), " events loaded");
      g_NewsNative.PrintStatus();  // Show upcoming events
   }
   
   // Entry optimizer
   if(!g_EntryOpt.Initialize())
   {
      Print("Warning: Entry optimizer initialization issue");
   }
   g_EntryOpt.SetMinRR(g_ModeCfg.min_rr);
   g_EntryOpt.SetTargetRR(g_ModeCfg.target_rr);
   g_EntryOpt.SetMaxWaitBars(g_ModeCfg.max_wait_bars);
   
   // v3.31: Initialize Footprint Analyzer (FORGE fix - was missing!)
   if(!g_Footprint.Init(_Symbol, InpLTFTimeframe, 0.50, 3.0))
   {
      Print("Warning: Footprint analyzer initialization issue");
   }
   else
   {
      // v3.3: Enable institutional-grade features
      g_Footprint.EnableDynamicCluster(true, 0.1, 0.25, 2.0);  // ATR-based cluster sizing
      g_Footprint.EnableSessionReset(true);                     // Reset delta at London/NY open
      Print("Footprint v3.4 initialized: M5 cluster=dynamic(ATR*0.1), session_reset=ON");
   }

   //=== v4.0: Initialize Apex Risk Components (Task 4.1 Integration) ===
   // 1. Initialize time handler first (needed by wall clock)
   // Pass broker GMT offset for backtest timezone correction (FTMO uses GMT+2)
   if(!g_TimeHandler.Init(InpGMTOffset == 0 ? 2 : InpGMTOffset))  // Default to 2 if not set
   {
      Print("Critical Error: Time Handler Initialization Failed!");
      return(INIT_FAILED);
   }

   // 2. Initialize DD tracker with starting equity
   if(!g_DDTracker.Init(AccountInfoDouble(ACCOUNT_EQUITY)))
   {
      Print("Critical Error: DD Tracker Initialization Failed!");
      return(INIT_FAILED);
   }

   // 3. Initialize wall clock with time handler
   if(!g_WallClock.Init(InpMagicNumber, _Symbol))
   {
      Print("Critical Error: Wall Clock Initialization Failed!");
      return(INIT_FAILED);
   }
   g_WallClock.AttachTimeHandler(&g_TimeHandler);

   // 4. Initialize spread monitor v2
   if(!g_SpreadMonitorV2.Init(_Symbol, 100))
   {
      Print("Warning: SpreadMonitor v2 initialization failed");
   }
   g_SpreadMonitorV2.SetMaxSpreadPoints(g_ModeCfg.max_spread_points);

   // 5. Initialize virtual gate (volatility filter)
   if(!g_VirtualGate.Init(20, 3.0, 2.5, 0.30, true))  // fail_open=true for initial data collection
   {
      Print("Warning: Virtual Gate initialization failed");
   }
   //--- Enable self-updating mode so median range is computed automatically
   g_VirtualGate.EnableSelfUpdate(Symbol(), Period());

   // 6. Initialize gap cooldown
   if(!g_GapCooldown.Init(30, 15))  // 30 min gap threshold, 15 min cooldown
   {
      Print("Warning: Gap Cooldown initialization failed");
   }

   // 7. Initialize unified risk policy with all components
   if(!g_RiskPolicy.Init(&g_DDTracker, &g_TimeHandler, &g_WallClock,
                         &g_SpreadMonitorV2, &g_VirtualGate, &g_GapCooldown))
   {
      Print("Critical Error: Unified Risk Policy Initialization Failed!");
      return(INIT_FAILED);
   }

   // v4.0: Apply time gate disable flag (for backtesting)
   if(InpDisableAllTimeGates)
   {
      g_RiskPolicy.SetDisableTimeGates(true);
      Print("*** TIME GATES DISABLED (backtest mode) ***");
   }

   // v4.1: Connect news filter to unified risk policy if enabled
   if(InpNewsFilterEnabled && g_NewsNative.IsInitialized())
   {
      g_RiskPolicy.SetNewsFilter(&g_NewsNative);
      Print("*** NEWS FILTER CONNECTED TO UNIFIED RISK POLICY ***");
   }

   Print("=== v4.0 Apex Risk Components Initialized ===");
   g_RiskPolicy.PrintStatus();

   // 8. Initialize Risk HUD for investor display
   if(!g_RiskHUD.Init(10, 50))  // Position at x=10, y=50
   {
      Print("Warning: Risk HUD initialization failed - visual display disabled");
   }
   else
   {
      Print("Risk HUD initialized: Visual display active");
   }

   // 8.1 v4.3: Initialize Recovery Manager
   if(!g_RecoveryManager.Init(InpAllowRecoveryEntry,
                               InpRecoveryMinLoss,
                               InpRecoveryScoreBoost,
                               InpRecoveryCooldown,
                               InpMaxRecoveryPerDay))
   {
      Print("Warning: Recovery Manager initialization failed - recovery entries disabled");
   }
   else
   {
      g_RecoveryManager.SetSymbolMagic(_Symbol, InpMagicNumber);
      g_RecoveryManager.SetRecoverySizeMultiplier(InpRecoverySizeMult);
      g_RecoveryManager.SetAllowHedge(InpAllowHedge);
      g_RecoveryManager.SetHedgeMinScore(InpHedgeMinScore);
      Print("Recovery Manager initialized: ", g_RecoveryManager.GetStatusString());
   }

   // 9. Connect Confluence Scorer to all detectors (v3.31: 9 factors)
   g_Confluence.AttachRegimeDetector(&g_Regime);
   g_Confluence.AttachStructureAnalyzer(&g_Structure);
   g_Confluence.AttachSweepDetector(&g_Sweep);
   g_Confluence.AttachAMDTracker(&g_AMD);
   g_Confluence.AttachOBDetector(g_ScoringEngine.GetOBDetector());
   g_Confluence.AttachFVGDetector(&g_FVG);
   
   // v3.31: Attach MTF and Footprint (FORGE genius upgrade) - only attach MTF when enabled
   if(g_ModeCfg.use_mtf)
      g_Confluence.AttachMTFManager(&g_MTF);
   else
      g_Confluence.AttachMTFManager(NULL);
   g_Confluence.AttachFootprint(&g_Footprint);

   g_Confluence.SetMinScore(InpExecutionThreshold);  // Match EA execution threshold
   g_Confluence.SetMinConfluences(2);                 // v4.0: Relaxed (was 3)
   g_Confluence.SetVoteMargin(InpVoteMargin);         // v4.2: Configurable vote margin (2 = more signals, 3 = stricter)
   
   // v4.2 GENIUS: Bayesian Learning - Connect CTradeManager to CConfluenceScorer
   // This enables self-improving priors based on actual trade outcomes
   g_TradeManager.AttachConfluenceScorer(&g_Confluence);
   
   // v4.2 GENIUS: Kelly Learning - Connect CTradeManager to RiskManager
   // This enables adaptive Kelly position sizing based on trade outcomes
   g_TradeManager.AttachRiskManager(&g_RiskManager);

   //=== v4.2: Initialize Strategy Modules (TrendFollow + AdaptiveRouter) ===
   // 1. Initialize AdaptiveRouter (rule-based strategy selection)
   if(!g_Router.Init())
   {
      Print("Warning: AdaptiveRouter initialization failed - using SMC only");
   }
   else
   {
      Print("[AdaptiveRouter] Active - routes by regime/session/volatility");
   }

   // 2. Initialize TrendFollow Strategy (EMA pullback + Donchian breakout)
   if(!g_TrendFollow.Init(_Symbol, InpEntryTimeframe))
   {
      Print("Warning: TrendFollow strategy initialization failed - SMC fallback only");
   }
   else
   {
      g_TrendFollow.SetTPRR(InpTargetRR);  // Use configured R:R
      Print("[TrendFollow] Active - EMA pullback + Donchian breakout, ER threshold=0.30");
   }

   // 8. Timer for slow-lane updates
   EventSetTimer(1);

   // 9. Initialize ML Brain (optional)
   g_MLEnabled = InpUseML;
   if(g_MLEnabled)
   {
      if(!g_OnnxBrain.Initialize())
      {
         Print("Warning: ONNX brain failed to initialize - ML disabled");
         g_MLEnabled = false;
      }
      else
      {
         g_OnnxBrain.SetCacheTime(InpMLCacheSeconds);
         Print("ONNX brain enabled with threshold=", DoubleToString(InpMLThreshold, 2));
      }
   }

   // 10. Init ATR handles for volatility rank (LTF)
   g_atr_fast_handle = iATR(_Symbol, InpLTFTimeframe, 14);
   g_atr_slow_handle = iATR(_Symbol, InpLTFTimeframe, 100);
   if(g_atr_fast_handle == INVALID_HANDLE || g_atr_slow_handle == INVALID_HANDLE)
      Print("Warning: ATR handles for vol rank failed to initialize");
   
   ArrayInitialize(g_bucket_trades, 0);

   // v4.2: Initialize regime strategy at startup (GENIUS refinement)
   // This ensures strategy is ready even before first H1 bar change
   SRegimeAnalysis init_regime = g_Regime.AnalyzeRegime(_Symbol, InpMgmtTimeframe);
   if(init_regime.is_valid)
   {
      g_CurrentStrategy = g_Regime.GetCurrentStrategy();
      g_RiskManager.SetRegimeMultiplier(init_regime.size_multiplier);
      Print("[Regime v4.2] Initial strategy: ", g_CurrentStrategy.philosophy);
      Print("  Entry mode: ", EnumToString(g_CurrentStrategy.entry_mode),
            " | Min confluence: ", g_CurrentStrategy.min_confluence,
            " | Risk: ", DoubleToString(g_CurrentStrategy.risk_percent * 100, 1), "%");
   }
   else
   {
      // Default to conservative if regime analysis fails at startup
      g_CurrentStrategy.Reset();
      Print("[Regime v4.2] Regime analysis failed at init - using conservative defaults");
   }

   Print("=== Singularity MTF Edition Initialized Successfully ===");
   Print("Execution TF: M5 | Structure TF: M15 | Direction TF: H1");
   Print("Session: ", g_Session.GetSessionName());
   Print("News Native: ", g_NewsNative.IsCalendarAvailable() ? "ACTIVE" : "UNAVAILABLE");
   Print("News Fallback: ", g_News.GetCurrentStatus());
   return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//| CRITIC FIX: Added mandatory flatten on EA removal/chart change   |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   Print("OnDeinit called, reason: ", reason);

   // Kill timer first
   EventKillTimer();

   //=== v4.0: ALWAYS flatten on EA removal/chart change ===
   // This is CRITICAL for Apex compliance - no orphan positions
   // Only flatten on specific deinit reasons (not chart period change)
   if(reason == REASON_REMOVE || reason == REASON_CLOSE ||
      reason == REASON_ACCOUNT || reason == REASON_PROGRAM)
   {
      FlattenAllPositions("OnDeinit - " + IntegerToString(reason));
   }
   else
   {
      Print("OnDeinit: Keeping positions open (reason=", reason, ")");
   }

   //=== Cancel all pending orders for this EA ===
   for(int i = OrdersTotal() - 1; i >= 0; i--)
   {
      ulong ticket = OrderGetTicket(i);
      if(OrderSelect(ticket))
      {
         if(OrderGetString(ORDER_SYMBOL) == _Symbol &&
            OrderGetInteger(ORDER_MAGIC) == InpMagicNumber)
         {
            CTrade trade;
            trade.OrderDelete(ticket);
            Print("OnDeinit: Cancelled pending order #", ticket);
         }
      }
   }

   // Cleanup modules
   g_MTF.Deinit();
   g_AMD.Deinitialize();
   g_Sweep.Deinitialize();
   g_OnnxBrain.Deinitialize();
   g_RiskHUD.Delete();  // v4.0: Cleanup HUD objects
   if(g_atr_fast_handle!=INVALID_HANDLE) IndicatorRelease(g_atr_fast_handle);
   if(g_atr_slow_handle!=INVALID_HANDLE) IndicatorRelease(g_atr_slow_handle);

   Print("EA_SCALPER_XAUUSD v4.0 Singularity Order Flow Deinitialized. Reason: ", reason);
}

//+------------------------------------------------------------------+
//| FlattenAllPositions - Close all positions for this EA            |
//| v4.0: Unified flatten function for OnDeinit and risk gates       |
//+------------------------------------------------------------------+
void FlattenAllPositions(string reason)
{
   Print("FlattenAllPositions called. Reason: ", reason);

   CTrade trade;
   trade.SetExpertMagicNumber(InpMagicNumber);
   trade.SetDeviationInPoints(InpSlippage);

   int positions_closed = 0;
   int positions_failed = 0;

   for(int i = PositionsTotal() - 1; i >= 0; i--)
   {
      ulong ticket = PositionGetTicket(i);
      if(!PositionSelectByTicket(ticket))
         continue;

      // Check magic and symbol
      if(PositionGetInteger(POSITION_MAGIC) != InpMagicNumber)
         continue;

      if(PositionGetString(POSITION_SYMBOL) != _Symbol)
         continue;

      // Found a position that needs closing
      double volume = PositionGetDouble(POSITION_VOLUME);
      double profit = PositionGetDouble(POSITION_PROFIT);

      Print("FlattenAllPositions: Closing position #", ticket,
            " Volume: ", DoubleToString(volume, 2),
            " Profit: ", DoubleToString(profit, 2));

      // Attempt to close with retry
      bool closed = false;
      for(int retry = 0; retry < 3 && !closed; retry++)
      {
         if(retry > 0)
         {
            Sleep(200);
            if(!PositionSelectByTicket(ticket))
            {
               closed = true;  // Position no longer exists
               break;
            }
         }

         if(trade.PositionClose(ticket))
         {
            closed = true;
            positions_closed++;
         }
         else
         {
            uint retcode = trade.ResultRetcode();
            Print("FlattenAllPositions: Close retry ", retry + 1,
                  " failed - ", trade.ResultRetcodeDescription());

            // Non-retriable errors
            if(retcode != TRADE_RETCODE_REQUOTE &&
               retcode != TRADE_RETCODE_PRICE_CHANGED &&
               retcode != TRADE_RETCODE_PRICE_OFF &&
               retcode != TRADE_RETCODE_CONNECTION &&
               retcode != TRADE_RETCODE_TIMEOUT)
            {
               break;
            }
         }
      }

      if(!closed)
      {
         positions_failed++;
         Print("FlattenAllPositions: FAILED to close position #", ticket);
      }
   }

   if(positions_closed > 0 || positions_failed > 0)
   {
      Print("FlattenAllPositions: Closed=", positions_closed,
            " Failed=", positions_failed, " Reason=", reason);
   }

   if(positions_failed > 0)
   {
      Alert("CRITICAL: Failed to close ", positions_failed, " positions on ", reason);
   }
}

//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
{
   // Always refresh risk state (daily reset / drawdown monitoring) even if spread gate blocks
   g_RiskManager.OnTick();

   //=== v4.0: Update Apex Risk Components ===
   g_DDTracker.Update();               // Update DD tracking with current equity
   g_WallClock.CheckAndEnforce();      // Check time gates (idempotent)
   g_SpreadMonitorV2.Check();          // Update spread statistics

   // v4.0: Get unified risk decision FIRST (before any trading logic)
   RiskDecision decision = g_RiskPolicy.EvaluateEntry(0);  // No direction for now

   // v4.0: Update Risk HUD (every tick for live display)
   g_RiskHUD.Update(&g_DDTracker, &g_TimeHandler, decision);

   // CRITICAL: If must_flatten, close all positions immediately and exit
   if(decision.must_flatten)
   {
      string reason = decision.GetPrimaryReason();
      Print("v4.0 RiskPolicy: MUST FLATTEN - ", reason);
      FlattenAllPositions(reason);
      g_IsEmergencyMode = true;
      return;
   }

   // If can't open new trades, still manage existing positions but don't enter new
   // This is handled later in the trading logic

   // Legacy Apex cutoff: flatten and block new trades after 16:55 ET
   // v4.0: This is now handled by CWallClockEnforcer, but keep as fallback
   // SKIP if time gates are disabled (backtest mode)
   if(!InpDisableAllTimeGates && InpEnforceApexCutoff && g_RiskManager.IsAfterCutoffET(16, InpApexCutoffMinute))
   {
      if(g_TradeManager.HasActiveTrade())
         g_TradeManager.CloseTrade("Apex cutoff 16:55 ET");
      g_RiskManager.FlattenAllPositions();
      g_IsEmergencyMode = true;
      return;
   }

   //=== DEBUG: Periodic status dump ===
   static datetime last_debug_log = 0;
   bool debug_now = InpDebugMode && (TimeCurrent() - last_debug_log >= InpDebugInterval);
   
   if(debug_now)
   {
      last_debug_log = TimeCurrent();
      
      // Collect ALL gate statuses
      int spread_pts = (int)SymbolInfoInteger(_Symbol, SYMBOL_SPREAD);
      int spread_cap = g_ModeCfg.max_spread_points;
      bool in_tester = (bool)MQLInfoInteger(MQL_TESTER);
      // Backtest runs often encode wider synthetic spreads; loosen cap in tester/backtest.
      if(in_tester || InpDisableAllTimeGates)
         spread_cap = MathMax(spread_cap, 200);
      bool spread_ok = (spread_pts <= spread_cap);
      bool session_ok = g_Session.IsTradingAllowed();
      bool news_ok = g_News.IsTradingAllowed();
      SNewsWindowNative news_native = g_NewsNative.CheckNewsWindow();
      bool news_native_ok = (news_native.action != NEWS_ACTION_BLOCK);
      bool risk_ok = g_RiskManager.CanOpenNewTrade();
      bool has_trade = g_TradeManager.HasActiveTrade();
      
      // MTF status
      SMTFConfluence mtf_conf = g_MTF.GetConfluence();
      bool htf_ok = true;
      bool mtf_align_ok = true;
      if(g_ModeCfg.use_mtf)
      {
         htf_ok = mtf_conf.htf_aligned;
         mtf_align_ok = (mtf_conf.alignment >= MTF_ALIGN_GOOD);
      }
      
      // Regime status
      SRegimeStrategy regime = g_Regime.GetCurrentStrategy();
      bool regime_ok = (regime.entry_mode != ENTRY_MODE_DISABLED);
      
      // Confluence
      SConfluenceResult conf = g_Confluence.CalculateConfluence();
      int score = (int)conf.total_score;
      bool score_ok = (score >= g_ModeCfg.execution_threshold);
      
      // AMD Phase
      ENUM_AMD_PHASE amd = g_AMD.GetCurrentPhase();
      bool amd_ok = (amd == AMD_PHASE_DISTRIBUTION);
      
      Print("=== DEBUG STATUS @ ", TimeToString(TimeCurrent(), TIME_DATE|TIME_MINUTES), " ===");
      PrintFormat("  Spread: %d pts [%s]", spread_pts, spread_ok ? "OK" : "BLOCKED");
      PrintFormat("  Session: %s [%s]", g_Session.GetSessionName(), session_ok ? "OK" : "BLOCKED");
      PrintFormat("  News Native: %s [%s]", news_native.reason, news_native_ok ? "OK" : "BLOCKED");
      PrintFormat("  News Fallback: %s [%s]", g_News.GetCurrentStatus(), news_ok ? "OK" : "BLOCKED");
      PrintFormat("  Risk: [%s]", risk_ok ? "OK" : "BLOCKED");
      PrintFormat("  Has Trade: [%s]", has_trade ? "YES-SKIP" : "NO-OK");
      PrintFormat("  HTF Align: [%s]", htf_ok ? "OK" : "BLOCKED");
      PrintFormat("  MTF Align: %s [%s]", g_ModeCfg.use_mtf ? EnumToString(mtf_conf.alignment) : "MTF_DISABLED", mtf_align_ok ? "OK" : "BLOCKED");
      PrintFormat("  Regime: %s [%s]", regime.philosophy, regime_ok ? "OK" : "BLOCKED");
      PrintFormat("  Score: %d/%d [%s]", score, g_ModeCfg.execution_threshold, score_ok ? "OK" : "LOW");
      PrintFormat("  AMD Phase: %s [%s]", EnumToString(amd), amd_ok ? "OK" : "WAITING");
      PrintFormat("  Direction: %s | Valid: %s", EnumToString(conf.direction), conf.is_valid ? "YES" : "NO");
      Print("=== END DEBUG ===");
   }
   
   //=== GATE 1: Spread Guard ===
   int spread_points = (int)SymbolInfoInteger(_Symbol, SYMBOL_SPREAD);
   g_spread_buff[g_spread_idx % 20] = spread_points;
   g_spread_idx++;
   if(g_spread_idx >= 1000000) g_spread_idx = 20;  // Reset to prevent overflow

   int spread_cap = g_ModeCfg.max_spread_points;
   bool in_tester = (bool)MQLInfoInteger(MQL_TESTER);
   // Backtest runs often encode wider synthetic spreads; loosen cap in tester/backtest.
   if(in_tester || InpDisableAllTimeGates)
      spread_cap = MathMax(spread_cap, 200);

   if(spread_points > spread_cap)
   {
      static datetime last_spread_log = 0;
      if(TimeCurrent() - last_spread_log > 300)
      {
         if(InpDebugMode) Print("[BLOCKED] Spread too high: ", spread_points, " > ", spread_cap);
         last_spread_log = TimeCurrent();
      }
      return;
   }

   // If we were halted previously but risk manager is now clear (e.g., new day), exit emergency
   if(g_IsEmergencyMode && !g_RiskManager.IsTradingHalted())
   {
      g_IsEmergencyMode = false;
      Print("Emergency mode cleared - risk limits back within range.");
   }
   
   // Keep managing open positions even during halt/soft-stop conditions
   // v4.3: Use ManageAllPositions for multi-position support
   g_TradeManager.ManageAllPositions();  // State machine for partials/trailing (all positions)
   if(g_TradeManager.GetActiveCount() == 0)
      g_Executor.ManagePositions(); // Legacy manager only if TradeManager not handling any positions

   // Hard halt: no new trades while still allow management above
   if(g_RiskManager.IsTradingHalted())
   {
      if(!g_IsEmergencyMode)
      {
         Print("TRADING HALTED: Risk Limits Breached.");
         g_IsEmergencyMode = true;
      }
      return;
   }

   // v4.3: Update RecoveryManager daily reset check
   g_RecoveryManager.OnTick();

   // v4.3: Recovery entry tracking
   bool is_recovery_entry = false;
   double recovery_size_mult = 1.0;
   int existing_entry_score = 0;
   ENUM_POSITION_TYPE existing_position_type = POSITION_TYPE_BUY;  // Default
   double unrealized_pct = 0.0;
   int bars_since_entry = 0;

   // v4.3: Skip new trade logic if we have reached max positions (UNLESS recovery is allowed)
   // Use CanOpenNewTrade() which respects m_max_positions limit
   if(!g_TradeManager.CanOpenNewTrade())
   {
      // Get existing trade info for recovery decision (use first active position)
      STradeInfo active_trade = g_TradeManager.GetTradeInfo();
      existing_entry_score = (int)active_trade.entry_score;
      existing_position_type = active_trade.type;

      // Calculate unrealized P/L as percentage of equity (for all positions)
      double unrealized_pnl = g_TradeManager.GetTotalUnrealizedPnL();
      double equity = AccountInfoDouble(ACCOUNT_EQUITY);
      unrealized_pct = (equity > 0) ? (unrealized_pnl / equity) * 100.0 : 0.0;

      // Calculate bars since entry (first position)
      if(active_trade.entry_time > 0)
      {
         datetime current_bar = iTime(_Symbol, PERIOD_CURRENT, 0);
         bars_since_entry = Bars(_Symbol, PERIOD_CURRENT, active_trade.entry_time, current_bar);
         if(bars_since_entry < 0) bars_since_entry = 0;  // Error protection
      }

      // If position is profitable OR recovery not enabled, skip new entries
      if(unrealized_pct >= 0 || !g_RecoveryManager.IsEnabled())
      {
         return;  // Position profitable or recovery disabled - no new entries
      }

      // Position is losing - continue to signal generation, then check recovery
      // We'll validate recovery after we have a signal score to compare
      // Mark that we have an existing position for later check
      is_recovery_entry = true;  // Will be validated after signal generation
   }

   //=== GATE 2: ML Direction (ONNX) ===
   ENUM_SIGNAL_TYPE ml_signal = SIGNAL_NONE;
   double ml_conf = 0.0;
   if(g_MLEnabled)
   {
      ml_signal = g_OnnxBrain.GetMLSignal(InpMLThreshold);
      ml_conf = g_OnnxBrain.GetMLConfidence();
      if(ml_signal == SIGNAL_NONE)
      {
         static datetime last_ml_log = 0;
         if(InpLogML && TimeCurrent() - last_ml_log > 120)
         {
            Print("[ML] No confident signal | conf=", DoubleToString(ml_conf, 2));
            last_ml_log = TimeCurrent();
         }
         return; // Do not trade without ML confirmation
      }
      else if(InpLogML)
      {
         PrintFormat("[ML] Signal=%s conf=%.2f", EnumToString(ml_signal), ml_conf);
      }
   }

   //=== GATE 3: Session Filter ===
   // v4.1: Bypass session gate when InpDisableAllTimeGates is enabled (backtest mode)
   if(!InpDisableAllTimeGates && !g_Session.IsTradingAllowed())
   {
      // Static to avoid spamming logs
      static datetime last_session_log = 0;
      if(TimeCurrent() - last_session_log > 3600)
      {
         Print("Session blocked: ", g_Session.GetSessionName());
         last_session_log = TimeCurrent();
      }
      return;
   }
   
   //=== GATE 4: News Filter (Native MQL5 Calendar + Fallback) ===
   // PRIMARY: Use native MQL5 calendar (real-time data from MetaQuotes)
   SNewsWindowNative news_result = g_NewsNative.CheckNewsWindow();
   
   if(news_result.action == NEWS_ACTION_BLOCK)
   {
      static datetime last_news_log = 0;
      if(TimeCurrent() - last_news_log > 300)
      {
         Print("NEWS BLOCK [Native]: ", news_result.reason);
         if(news_result.event.is_valid)
            Print("  Event: ", news_result.event.event_name, " | Minutes: ", news_result.minutes_to_event);
         last_news_log = TimeCurrent();
      }
      return;
   }
   // Soft news caution: cut risk by 50% for next trade
   bool news_caution = false; // native calendar caution flag (set to true if enum provides)
   
   // FALLBACK: Also check hardcoded calendar for extra safety
   if(!g_News.IsTradingAllowed())
   {
      static datetime last_news_log2 = 0;
      if(TimeCurrent() - last_news_log2 > 300)
      {
         Print("NEWS BLOCK [Fallback]: ", g_News.GetCurrentStatus());
         last_news_log2 = TimeCurrent();
      }
      return;
   }
   
   // Apply news-based score adjustment and size multiplier
   int news_score_adj = news_result.score_adjustment;
   double news_size_mult = news_result.size_multiplier;
   
   //=== GATE 5: Risk Manager - Can open new trade? ===
   if(!g_RiskManager.CanOpenNewTrade()) return;

   //=== GATE 5.1: v4.0 Unified Risk Policy (Apex DD + Time + Spread + VirtualGate + Gap) ===
   // decision was already calculated at the start of OnTick
   if(!decision.can_open_new)
   {
      // Log periodically (not every tick)
      static datetime last_risk_gate_log = 0;
      if(TimeCurrent() - last_risk_gate_log >= 60)  // Every 60 seconds
      {
         string block_reason = decision.GetPrimaryReason();
         Print("[v4.0 RiskPolicy] New entries blocked: ", block_reason);
         last_risk_gate_log = TimeCurrent();
      }
      return;
   }

   // v4.0: Apply size factor from unified risk policy
   // This will reduce position size when DD is approaching limits or spread is elevated
   // Stored for use in lot size calculation later
   double risk_policy_size_mult = decision.size_factor;

   //=== GATE 6: Multi-Timeframe Analysis (NEW v3.20) ===
   // v4.1: Bypass HTF alignment when InpDisableAllTimeGates is enabled (backtest mode)
   if(g_ModeCfg.use_mtf && !InpDisableAllTimeGates)
   {
      // Check HTF (H1) direction - NEVER trade against H1 trend
      SMTFConfluence mtf_conf_htf = g_MTF.GetConfluence();
      if(g_ModeCfg.require_htf_align && !mtf_conf_htf.htf_aligned)
      {
         static datetime last_htf_log = 0;
         if(TimeCurrent() - last_htf_log > 1800)
         {
            Print("[MTF] H1 trend not aligned - waiting. ", g_MTF.GetAnalysisSummary());
            last_htf_log = TimeCurrent();
         }
         return;
      }
   }

   //=== v4.2: ADAPTIVE STRATEGY ROUTING ===
   // Use router to select best strategy for current conditions
   // Router decides between SMC (confluence) and TrendFollow based on regime/session/volatility
   SRegimeAnalysis current_regime = g_Regime.AnalyzeRegime(_Symbol, InpMgmtTimeframe);

   // Map session filter state to router session type
   ENUM_ROUTER_SESSION router_session = ROUTER_SESSION_OFF_HOURS;
   string session_name = g_Session.GetSessionName();
   if(StringFind(session_name, "Asian") >= 0)          router_session = ROUTER_SESSION_ASIAN;
   else if(StringFind(session_name, "London") >= 0)    router_session = ROUTER_SESSION_LONDON;
   else if(StringFind(session_name, "NY") >= 0)
   {
      if(StringFind(session_name, "Overlap") >= 0)     router_session = ROUTER_SESSION_NY_OVERLAP;
      else                                              router_session = ROUTER_SESSION_NY_AFTERNOON;
   }

   // Get volatility percentile for router
   double vol_percentile = GetVolRank() * 100.0;  // Convert 0-1 to 0-100

   // Get router decision
   SRouterDecision router_decision = g_Router.SelectStrategy(
      current_regime.regime,
      router_session,
      vol_percentile
   );

   // Log router decision periodically
   static datetime last_router_log = 0;
   if(InpDebugMode && TimeCurrent() - last_router_log >= 300)
   {
      PrintFormat("[Router] Strategy=%s Conf=%.0f%% Size=%.2f Reason=%s",
                  g_Router.StrategyToString(router_decision.primary_strategy),
                  router_decision.confidence,
                  router_decision.size_multiplier,
                  router_decision.reason);
      last_router_log = TimeCurrent();
   }

   //=== SIGNAL GENERATION (v4.2: Strategy-Aware) ===
   // Select strategy based on router decision
   ENUM_SIGNAL_TYPE signal = SIGNAL_NONE;
   int score = 0;
   bool using_trend_follow = false;
   double trend_follow_sl = 0, trend_follow_tp = 0, trend_follow_entry = 0;

   if(router_decision.primary_strategy == STRATEGY_TREND_FOLLOW && g_TrendFollow.IsTrending())
   {
      // Use TrendFollow strategy
      STrendFollowSignal tf_signal = g_TrendFollow.GetBestSignal();
      if(tf_signal.is_valid)
      {
         signal = tf_signal.direction;
         score = (int)tf_signal.confidence;
         trend_follow_sl = tf_signal.stop_loss;
         trend_follow_tp = tf_signal.take_profit;
         trend_follow_entry = tf_signal.entry_price;
         using_trend_follow = true;

         if(InpDebugMode)
         {
            PrintFormat("[TrendFollow] Signal=%s Mode=%s ER=%.2f Conf=%.0f",
                       EnumToString(signal),
                       EnumToString(tf_signal.mode),
                       tf_signal.efficiency_ratio,
                       tf_signal.confidence);
         }
      }
   }

   // Fallback to SMC confluence if TrendFollow didn't produce signal OR router chose SMC
   double fp_score = 0;  // Footprint score for booster/veto
   SConfluenceResult conf_result;  // Declare in outer scope for later use
   // MQL5 structs are zero-initialized by default

   if(signal == SIGNAL_NONE)
   {
      // v3.31: Calculate confluence using the REAL brain (FORGE genius upgrade)
      conf_result = g_Confluence.CalculateConfluence();
      score = (int)conf_result.total_score;
      signal = conf_result.direction;
      fp_score = conf_result.footprint_score;

      // v4.2: Validity check is ALWAYS enforced (never bypass)
      if(!conf_result.is_valid) return;
   }
   else
   {
      // TrendFollow was used - still get confluence for supplementary data
      conf_result = g_Confluence.CalculateConfluence();
      fp_score = conf_result.footprint_score;
   }

   // Check minimum score threshold - ALWAYS ENFORCED (never bypass)
   // v4.2: Keep EA threshold aligned with confluence engine input (adaptive threshold can be stricter internally)
   if(score < InpExecutionThreshold) return;

   //=== v4.3: RECOVERY ENTRY VALIDATION GATE ===
   // If we have an existing position (is_recovery_entry=true), validate if recovery is allowed
   if(is_recovery_entry)
   {
      // Use the full recovery decision method for detailed checking
      SRecoveryDecision recovery_decision = g_RecoveryManager.ShouldAllowRecoveryEntry(
         unrealized_pct,              // Current unrealized P/L %
         score,                       // New signal score
         existing_entry_score,        // Original entry score
         bars_since_entry,            // Bars elapsed since entry
         existing_position_type,      // Existing position type (BUY/SELL)
         signal                       // New signal type
      );

      if(!recovery_decision.allowed)
      {
         // Recovery not allowed - log periodically and exit
         static datetime last_recovery_reject_log = 0;
         if(TimeCurrent() - last_recovery_reject_log > 300)
         {
            Print("[Recovery v4.3] Entry rejected: ", recovery_decision.reason);
            last_recovery_reject_log = TimeCurrent();
         }
         return;
      }

      // Recovery allowed - apply size multiplier
      recovery_size_mult = recovery_decision.size_multiplier;
      Print("[Recovery v4.3] ", recovery_decision.reason);
      PrintFormat("  Size multiplier: %.2f (NOT martingale)", recovery_size_mult);
   }

   // Volatility & spread-relative filters
   // v4.1: Bypass vol_rank check when InpDisableAllTimeGates is enabled
   double vol_rank = GetVolRank();
   if(!InpDisableAllTimeGates && vol_rank < 0.15) return;              // block chop dead markets
   double median_spread = GetMedianSpread();
   if(!InpDisableAllTimeGates && g_spread_idx >= 5 && median_spread > 0 && spread_points > median_spread * 1.8) return;

   // Footprint booster/veto (fp_score already set above)
   if(g_ModeCfg.use_footprint_boost && g_ModeCfg.aggressive_mode)
   {
      if(fp_score <= 20) return;
   }
   
   // Contextual bandit-lite using bucket + vol + confluence
   double ctx_bandit = 1.0;
   int bucket = GetBucket15();
   if(bucket < 0 || bucket > 95) bucket = 0;
   if(g_ModeCfg.use_bandit_context && g_ModeCfg.aggressive_mode)
   {
      double norm_conf = score / 100.0;
      double spread_z = (g_spread_idx >=5 && median_spread>0) ? (double)spread_points/median_spread : 1.0;
      double ctx_mean = 0.5*norm_conf + 0.3*vol_rank + 0.2*(fp_score/100.0);
      double exploration = 0.30 / MathSqrt((double)g_bucket_trades[bucket] + 1.0);
      ctx_bandit = ctx_mean + exploration - MathMax(0.0, (spread_z-1.0)*0.15);
      if(ctx_bandit < 0.55) return; // too weak
   }

   //=== GATE 7: AMD Cycle Check ===
   // Only trade in DISTRIBUTION phase (after manipulation)
   // NOTE: This is also checked by CConfluenceScorer but kept for explicit control
   // SKIP if AMD gate is disabled (backtest mode)
   ENUM_AMD_PHASE amd_phase = g_AMD.GetCurrentPhase();
   if(!InpDisableAMDGate)
   {
      if(amd_phase == AMD_PHASE_ACCUMULATION || amd_phase == AMD_PHASE_MANIPULATION)
      {
         // Still in setup phase - wait
         return;
      }
   }

   // Signal was already determined above by router logic
   // Final signal check before proceeding to entry
   if(signal == SIGNAL_NONE) return;

   // Align with ML direction if enabled
   if(g_MLEnabled)
   {
      if(ml_signal == SIGNAL_NONE) return;
      // v3.31: Compare directly with SIGNAL_TYPE (not ORDER_TYPE)
      if(ml_signal != signal)
      {
         static datetime last_mismatch = 0;
         if(TimeCurrent() - last_mismatch > 300)
         {
            Print("[ML] Direction mismatch. ML=", EnumToString(ml_signal), " | ConfluenceDir=", EnumToString(signal));
            last_mismatch = TimeCurrent();
         }
         return;
      }
   }
   
   // Pull best order block zone from scoring module if available
   double ob_low = 0, ob_high = 0;
   SAdvancedOrderBlock best_ob;
   if(g_ScoringEngine.GetBestOrderBlock(best_ob))
   {
      ob_low = best_ob.low_price;
      ob_high = best_ob.high_price;
   }
   bool has_ob = (ob_low > 0 && ob_high > 0);
   
   // Pull nearest FVG in signal direction
   double fvg_low = 0, fvg_high = 0;
   SEliteFairValueGap best_fvg;
   if(signal == SIGNAL_BUY)
   {
      if(g_FVG.GetNearestFVG(FVG_BULLISH, best_fvg))
      {
         fvg_low = best_fvg.lower_level;
         fvg_high = best_fvg.upper_level;
      }
   }
   else if(signal == SIGNAL_SELL)
   {
      if(g_FVG.GetNearestFVG(FVG_BEARISH, best_fvg))
      {
         fvg_low = best_fvg.lower_level;
         fvg_high = best_fvg.upper_level;
      }
   }
   bool has_fvg = (fvg_low > 0 && fvg_high > 0);
   
   // Update MTF manager with real structure flags (OB/FVG)
   g_MTF.SetStructureFlags(has_ob, has_fvg, g_Sweep.HasRecentSweep());
   
   // Refresh MTF confluence with updated structure flags
   if(g_ModeCfg.use_mtf)
   {
      SMTFConfluence mtf_conf = g_MTF.GetConfluence();
      
      // Check minimum MTF alignment (at least GOOD = 2 TFs aligned)
      if(mtf_conf.alignment < MTF_ALIGN_GOOD)
         return;
      
      // Require structure zone if configured
      if(g_ModeCfg.require_mtf_zone && !mtf_conf.mtf_structure)
      {
         static datetime last_mtf_zone_log = 0;
         if(TimeCurrent() - last_mtf_zone_log > 900)
         {
            Print("[MTF] Structure zone missing - waiting for OB/FVG alignment. ", g_MTF.GetAnalysisSummary());
            last_mtf_zone_log = TimeCurrent();
         }
         return;
      }
   }
   
   //=== GATE 8: MTF Direction Confirmation (NEW v3.20) ===
   if(g_ModeCfg.use_mtf)
   {
      // Verify signal aligns with H1 trend
      if(signal == SIGNAL_BUY && !g_MTF.CanTradeLong())
      {
         return; // H1 is not bullish
      }
      if(signal == SIGNAL_SELL && !g_MTF.CanTradeShort())
      {
         return; // H1 is not bearish
      }
      
      // Check M5 confirmation
      if(g_ModeCfg.require_ltf_confirm && !g_MTF.HasLTFConfirmation(signal))
      {
         return; // No M5 confirmation candle
      }
   }
   
   // Get zone data for entry optimization
   double sweep_level = 0;
   double current_price = (signal == SIGNAL_BUY) 
      ? SymbolInfoDouble(_Symbol, SYMBOL_ASK) 
      : SymbolInfoDouble(_Symbol, SYMBOL_BID);
   
   // Get sweep level from AMD tracker
   if(signal == SIGNAL_BUY)
   {
      sweep_level = g_AMD.GetManipulationLow();
      SLiquidityPool ssl = g_Sweep.GetNearestSSL(current_price);
      if(ssl.is_valid) sweep_level = ssl.level;
   }
   else
   {
      sweep_level = g_AMD.GetManipulationHigh();
      SLiquidityPool bsl = g_Sweep.GetNearestBSL(current_price);
      if(bsl.is_valid) sweep_level = bsl.level;
   }
   
   // Require structure context; avoid defaulting to market-only entries
   bool has_structure_context = (fvg_low > 0 || fvg_high > 0 || ob_low > 0 || ob_high > 0 || sweep_level != 0);
   if(!has_structure_context)
   {
      static datetime last_structure_log = 0;
      if(TimeCurrent() - last_structure_log > 900)
      {
         Print("Entry skipped: missing structure context (OB/FVG/sweep).");
         last_structure_log = TimeCurrent();
      }
      return;
   }
   
   // Calculate optimal entry
   SOptimalEntry entry = g_EntryOpt.CalculateOptimalEntry(
      signal, fvg_low, fvg_high, ob_low, ob_high, sweep_level, current_price
   );
   
   // Validate entry quality
   if(!entry.is_valid || entry.risk_reward < g_ModeCfg.min_rr)
   {
      Print("Entry rejected: R:R = ", DoubleToString(entry.risk_reward, 2), " < ", g_ModeCfg.min_rr);
      return;
   }
   
   //=== v4.2: ENTRY MODE FILTERING (GENIUS) ===
   // Different regimes require different entry approaches
   switch(g_CurrentStrategy.entry_mode)
   {
      case ENTRY_MODE_BREAKOUT:
         // Standard breakout entry - current logic is fine
         break;
         
      case ENTRY_MODE_PULLBACK:
         // Require price to be pulling back INTO structure (FVG/OB)
         if(has_ob && signal == SIGNAL_BUY && current_price > (ob_high + ob_low) / 2)
         {
            static datetime last_pb_log = 0;
            if(TimeCurrent() - last_pb_log > 300)
            {
               Print("[Entry v4.2] PULLBACK mode: Waiting for pullback to OB zone");
               last_pb_log = TimeCurrent();
            }
            return;
         }
         if(has_ob && signal == SIGNAL_SELL && current_price < (ob_high + ob_low) / 2)
         {
            return; // Wait for pullback
         }
         break;
         
      case ENTRY_MODE_MEAN_REVERT:
         // Only enter at sweep levels (extremes)
         if(signal == SIGNAL_BUY && sweep_level <= 0)
         {
            static datetime last_mr_log = 0;
            if(TimeCurrent() - last_mr_log > 300)
            {
               Print("[Entry v4.2] MEAN_REVERT mode: Waiting for sweep of lows");
               last_mr_log = TimeCurrent();
            }
            return;
         }
         if(signal == SIGNAL_SELL && sweep_level <= 0)
         {
            return; // Wait for sweep
         }
         break;
         
      case ENTRY_MODE_CONFIRMATION:
         // Require extra confirmation bars
         if(g_CurrentStrategy.confirmation_bars > 1)
         {
            bool confirmed = true;
            for(int cb = 1; cb <= g_CurrentStrategy.confirmation_bars; cb++)
            {
               double bar_close = iClose(_Symbol, InpLTFTimeframe, cb);
               double bar_open = iOpen(_Symbol, InpLTFTimeframe, cb);
               if(signal == SIGNAL_BUY && bar_close < bar_open) confirmed = false;
               if(signal == SIGNAL_SELL && bar_close > bar_open) confirmed = false;
            }
            if(!confirmed)
            {
               static datetime last_conf_log = 0;
               if(TimeCurrent() - last_conf_log > 300)
               {
                  Print("[Entry v4.2] CONFIRMATION mode: Waiting for confirming bars");
                  last_conf_log = TimeCurrent();
               }
               return;
            }
         }
         break;
         
      case ENTRY_MODE_DISABLED:
         return; // Safety net
   }

   
   //=== EXECUTION ===
   // Check if we should enter now or wait
   if(!g_EntryOpt.ShouldEnterNow(current_price))
   {
      // Waiting for better entry - place limit order or wait
      return;
   }
   
   // Calculate position size
   double slPoints = MathAbs(current_price - entry.stop_loss) / _Point;

   // Dynamic risk based on edge/vol/spread/news
   double risk_custom = g_ModeCfg.risk_per_trade;
   double edge = (score - g_ModeCfg.execution_threshold) / MathMax(10.0, (double)g_ModeCfg.execution_threshold);
   risk_custom *= (1.0 + MathMax(-0.5, MathMin(0.6, edge * 0.6))); // boost/nerf 60% of edge
   double spread_rel = (g_spread_idx >= 5 && GetMedianSpread() > 0) ? spread_points / GetMedianSpread() : 1.0;
   if(spread_rel > 1.6) risk_custom *= 0.6;
   if(vol_rank < 0.35) risk_custom *= 0.6;
   if(vol_rank > 0.85) risk_custom *= 0.85; // tail caution
   if(news_caution)    risk_custom *= 0.5;
   // Footprint boost/nerf
   if(g_ModeCfg.use_footprint_boost && g_ModeCfg.aggressive_mode)
   {
      if(fp_score >= 60) risk_custom *= 1.15;
      else if(fp_score <= 35) risk_custom *= 0.8;
   }
   // Contextual bandit boost
   if(g_ModeCfg.use_bandit_context && g_ModeCfg.aggressive_mode)
      risk_custom *= (1.0 + MathMax(0.0, MathMin(0.3, ctx_bandit - 0.55)));
   risk_custom = MathMax(0.05, MathMin(g_ModeCfg.risk_per_trade * 2.5, risk_custom));
   
   //=== v4.2: OVERRIDE TPs WITH REGIME STRATEGY R-MULTIPLES (GENIUS) ===
   // Calculate TPs based on regime strategy instead of CEntryOptimizer defaults
   if(g_CurrentStrategy.tp1_r > 0)
   {
      double risk_price = MathAbs(current_price - entry.stop_loss);  // Risk in price units
      
      // Calculate new TPs based on R-multiples
      double tp1_offset = risk_price * g_CurrentStrategy.tp1_r;
      double tp2_offset = risk_price * g_CurrentStrategy.tp2_r;
      double tp3_offset = risk_price * g_CurrentStrategy.tp3_r;
      
      // Override entry TPs
      if(signal == SIGNAL_BUY)
      {
         entry.take_profit_1 = current_price + tp1_offset;
         entry.take_profit_2 = current_price + tp2_offset;
         entry.take_profit_3 = current_price + tp3_offset;
      }
      else
      {
         entry.take_profit_1 = current_price - tp1_offset;
         entry.take_profit_2 = current_price - tp2_offset;
         entry.take_profit_3 = current_price - tp3_offset;
      }
      
      // Recalculate R:R with new TP1
      entry.risk_reward = g_CurrentStrategy.tp1_r;
      
      // Log the override
      static datetime last_tp_log = 0;
      if(TimeCurrent() - last_tp_log > 600)
      {
         Print("[TP v4.2] Regime TPs applied: TP1=", DoubleToString(g_CurrentStrategy.tp1_r, 1), 
               "R TP2=", DoubleToString(g_CurrentStrategy.tp2_r, 1), 
               "R TP3=", DoubleToString(g_CurrentStrategy.tp3_r, 1), "R");
         last_tp_log = TimeCurrent();
      }
   }

   double lotSize = g_RiskManager.CalculateLotSizeWithRisk(slPoints, risk_custom);

   if(lotSize <= 0) return;
   
   // Additional safety: cap lot by equity and max 5 lots hard
   double maxLotEquity = AccountInfoDouble(ACCOUNT_EQUITY) / 20000.0; // 0.5 lot por 10k
   lotSize = MathMin(lotSize, maxLotEquity);
   lotSize = MathMin(lotSize, 5.0);
   
   // Margin pre-check: ensure using <80% of free margin
   double margin_required = 0;
   if(OrderCalcMargin((signal==SIGNAL_BUY)?ORDER_TYPE_BUY:ORDER_TYPE_SELL, _Symbol, lotSize, current_price, margin_required))
   {
      double free_margin = AccountInfoDouble(ACCOUNT_MARGIN_FREE);
      if(margin_required > free_margin * 0.8)
      {
         if(lotSize <= 0) return;  // Guard against division by zero
         double safe_lot = (free_margin * 0.8) / (margin_required / lotSize);
         lotSize = MathMin(lotSize, safe_lot);
         if(lotSize < SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN))
            return; // abort if too small after cap
      }
   }
   
   // v3.31: Apply position sizing from CConfluenceScorer (includes regime + MTF)
   double conf_size_mult = conf_result.position_size_mult;
   if(conf_size_mult < 1.0 && conf_size_mult > 0)
   {
      lotSize *= conf_size_mult;
      Print("[Confluence] Position size adjusted to ", DoubleToString(conf_size_mult*100, 0), "% (regime/MTF adjustment)");
   }
   
   // Also apply MTF multiplier if different (belt and suspenders)
   if(g_ModeCfg.use_mtf)
   {
      double mtf_mult = g_MTF.GetPositionSizeMultiplier();
      if(mtf_mult < conf_size_mult && mtf_mult > 0)
      {
         lotSize *= (mtf_mult / conf_size_mult);  // Only apply the difference
         Print("[MTF] Additional position size adjustment to ", DoubleToString(mtf_mult*100, 0), "%");
      }
   }
   
   // Ensure minimum lot size
   double minLot = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN);
   if(lotSize < minLot) lotSize = minLot;

   // v4.0: Apply unified risk policy size factor (DD approach / spread scaling)
   if(risk_policy_size_mult < 1.0 && risk_policy_size_mult > 0.0)
   {
      double adjusted_lot = lotSize * risk_policy_size_mult;
      if(adjusted_lot >= minLot)
      {
         Print("[v4.0 RiskPolicy] Position size reduced: ", DoubleToString(lotSize, 2),
               " -> ", DoubleToString(adjusted_lot, 2),
               " (factor: ", DoubleToString(risk_policy_size_mult, 2), ")");
         lotSize = adjusted_lot;
      }
      else
      {
         Print("[v4.0 RiskPolicy] Position size would be below minLot - keeping minLot");
      }
   }

   // v4.3: Apply recovery size multiplier (always <= 1.0, NOT martingale)
   if(is_recovery_entry && recovery_size_mult < 1.0 && recovery_size_mult > 0.0)
   {
      double recovery_adjusted_lot = lotSize * recovery_size_mult;
      if(recovery_adjusted_lot >= minLot)
      {
         Print("[Recovery v4.3] Position size reduced: ", DoubleToString(lotSize, 2),
               " -> ", DoubleToString(recovery_adjusted_lot, 2),
               " (recovery mult: ", DoubleToString(recovery_size_mult, 2), ")");
         lotSize = recovery_adjusted_lot;
      }
      else
      {
         Print("[Recovery v4.3] Position size would be below minLot - keeping minLot");
      }
   }

   // v3.31: Enhanced trade reason with confluence details
   string reason = StringFormat("Score:%d/%d Conf:%d/9 Q:%s AMD:%s RR:%.1f", 
                                score, g_ModeCfg.execution_threshold,
                                conf_result.total_confluences,
                                g_Confluence.QualityToString(conf_result.quality),
                                EnumToString(amd_phase), entry.risk_reward);
   
   // v4.1: Apply regime-adaptive strategy to trade manager (GENIUS)
   g_TradeManager.ApplyRegimeStrategy(g_CurrentStrategy);
   
   // v4.1: Apply regime-based risk percent (overrides input if regime dictates lower risk)
   if(g_CurrentStrategy.risk_percent > 0 && g_CurrentStrategy.risk_percent < g_ModeCfg.risk_per_trade / 100.0)
   {
      double regime_lots = g_RiskManager.CalculateLotSizeWithRisk(slPoints, g_CurrentStrategy.risk_percent * 100);
      if(regime_lots > 0 && regime_lots < lotSize)
      {
         Print("[Regime v4.1] Risk adjusted from ", DoubleToString(g_ModeCfg.risk_per_trade, 2), 
               "% to ", DoubleToString(g_CurrentStrategy.risk_percent * 100, 2), 
               "% | Lot: ", DoubleToString(lotSize, 2), " -> ", DoubleToString(regime_lots, 2));
         lotSize = regime_lots;
      }
   }
   
   if(g_TradeManager.OpenTradeWithTPs(signal, lotSize, entry.stop_loss,
                                       entry.take_profit_1, entry.take_profit_2, entry.take_profit_3,
                                       score, reason))
   {
      // increment bucket trade count for exploration decay
      if(g_ModeCfg.use_bandit_context && g_ModeCfg.aggressive_mode)
      {
         int exec_bucket = GetBucket15();
         if(exec_bucket >=0 && exec_bucket < 96) g_bucket_trades[exec_bucket]++;
      }
      Print("=== TRADE EXECUTED (v3.31 FORGE Genius Edition) ===");
      Print("Direction: ", (signal == SIGNAL_BUY ? "BUY" : "SELL"));
      Print("Entry: ", current_price, " | SL: ", entry.stop_loss);
      Print("TP1: ", entry.take_profit_1, " (40%)");
      Print("TP2: ", entry.take_profit_2, " (30%)");
      Print("TP3: ", entry.take_profit_3, " (trail 30%)");
      Print("R:R: ", DoubleToString(entry.risk_reward, 2));
      Print("Lot: ", lotSize);
      Print("Confluence Score: ", score, " | Quality: ", g_Confluence.QualityToString(conf_result.quality));
      Print("Factors: ", conf_result.total_confluences, "/9 | MTF:", DoubleToString(conf_result.mtf_score,1), " | FP:", DoubleToString(conf_result.footprint_score,1));
      if(g_ModeCfg.use_mtf) Print("MTF: ", g_MTF.GetAnalysisSummary());
      Print("============================================");

      // v4.3: Record recovery entry for daily counter tracking
      if(is_recovery_entry)
      {
         g_RecoveryManager.RecordRecoveryEntry();
         Print("[Recovery v4.3] Recovery entry recorded. Remaining today: ",
               g_RecoveryManager.GetRemainingRecoveries());
      }

      g_RiskManager.OnTradeExecuted();
   }
}

//+------------------------------------------------------------------+
//| Timer function - Slow lane updates + Wall Clock Enforcement      |
//| v4.0: Added wall clock enforcement for Apex time gates           |
//+------------------------------------------------------------------+
void OnTimer()
{
   //=== v4.0: Wall clock enforcement (CRITICAL for Apex 4:59 PM ET deadline) ===
   // This runs every 1 second to ensure time gates are enforced
   // even if there are no ticks (low liquidity / market gap)
   g_WallClock.CheckAndEnforce();

   // v4.0: Time-based flatten is ALREADY handled by g_WallClock.CheckAndEnforce()
   // which is idempotent (only flattens once per session)
   // REMOVED: Redundant FlattenAllPositions call that caused infinite loop

   // Slow-lane analytics
   static datetime last_h1_bar = 0;
   static datetime last_m15_bar = 0;

   datetime h1_bar = iTime(_Symbol, InpMgmtTimeframe, 0);
   datetime m15_bar = iTime(_Symbol, InpEntryTimeframe, 0);

   // Regime/HTF updates on new management bar
   if(h1_bar != last_h1_bar)
   {
      SRegimeAnalysis regime = g_Regime.AnalyzeRegime(_Symbol, InpMgmtTimeframe);
      if(regime.is_valid)
      {
         g_RiskManager.SetRegimeMultiplier(regime.size_multiplier);
         
         // v4.1: Update current regime strategy (GENIUS)
         g_CurrentStrategy = g_Regime.GetCurrentStrategy();
         
         // Log regime strategy change
         static ENUM_MARKET_REGIME last_regime = REGIME_UNKNOWN;
         if(regime.regime != last_regime)
         {
            Print("[Regime v4.1] Strategy changed to: ", g_CurrentStrategy.philosophy);
            Print("  Entry mode: ", EnumToString(g_CurrentStrategy.entry_mode),
                  " | Min confluence: ", g_CurrentStrategy.min_confluence,
                  " | Risk: ", DoubleToString(g_CurrentStrategy.risk_percent * 100, 1), "%");
            last_regime = regime.regime;
         }
      }
      last_h1_bar = h1_bar;
   }
   
   // Structure/Entry TF updates on new entry timeframe bar
   if(m15_bar != last_m15_bar)
   {
      g_Structure.AnalyzeStructure(_Symbol, InpEntryTimeframe);
      last_m15_bar = m15_bar;
      
      // Refresh FVGs on new M15 bar to avoid heavy per-tick detection
      g_FVG.DetectEliteFairValueGaps();
   }
   
   // Update sweep and AMD cycle (1s timer)
   g_Sweep.Update();
   g_AMD.Update();
   
   // v3.31: Update Footprint analyzer (FORGE fix - was missing!)
   g_Footprint.Update();
   
   // Update MTF manager once per timer tick (uses cached indicator buffers)
   if(g_ModeCfg.use_mtf)
      g_MTF.Update();
   
   // Check for new day (reset daily counters)
   static int last_day = 0;
   MqlDateTime dt;
   TimeCurrent(dt);
   if(dt.day != last_day)
   {
      last_day = dt.day;
      g_RiskManager.OnNewDay();
      g_News.RefreshSchedule();         // Refresh hardcoded calendar
      g_NewsNative.RefreshCache();      // Refresh native MQL5 calendar
      Print("=== NEW TRADING DAY ===");
      Print("Session: ", g_Session.GetSessionName());
      Print("News Fallback: ", g_News.GetCurrentStatus());
      g_NewsNative.PrintStatus();       // Show native calendar events
   }
   
   // Phase 2: Python Hub updates
   // g_PythonBridge.OnTimer();
}

//+------------------------------------------------------------------+
//| Helpers: volatility rank & spread median                         |
//+------------------------------------------------------------------+
double GetVolRank()
{
   if(g_atr_fast_handle==INVALID_HANDLE || g_atr_slow_handle==INVALID_HANDLE) return 0.5;
   double fast[1], slow[1];
   if(CopyBuffer(g_atr_fast_handle,0,0,1,fast) < 1) return 0.5;
   if(CopyBuffer(g_atr_slow_handle,0,0,1,slow) < 1) return 0.5;
   if(slow[0] <= 0) return 0.5;
   double rank = fast[0] / (slow[0]*2.0);
   return MathMin(1.0, MathMax(0.0, rank));
}

double GetMedianSpread()
{
   int count = MathMin(g_spread_idx, 20);
   if(count <= 0) return 0;
   double temp[];
   ArrayResize(temp, count);
   for(int i=0;i<count;i++) temp[i]=g_spread_buff[i];
   ArraySort(temp);
   int mid = count/2;
   if((count%2)==0) return (temp[mid-1]+temp[mid])/2.0;
   else return temp[mid];
}

int GetBucket15()
{
   MqlDateTime dt;
   TimeCurrent(dt);
   int adj_hour = (dt.hour - InpGMTOffset + 24) % 24;
   int minute_of_day = adj_hour*60 + dt.min;
   int bucket = minute_of_day / 15;
   if(bucket < 0) bucket = 0;
   if(bucket > 95) bucket = 95;
   return bucket;
}
//+------------------------------------------------------------------+
