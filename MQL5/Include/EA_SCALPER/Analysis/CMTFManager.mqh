//+------------------------------------------------------------------+
//|                                                 CMTFManager.mqh |
//|                    Multi-Timeframe Analysis Manager              |
//|                    HTF=H1, MTF=M15, LTF=M5                       |
//+------------------------------------------------------------------+
#property copyright "EA_SCALPER_XAUUSD - Singularity Edition"
#property strict

#include "..\Core\Definitions.mqh"

//--- MTF Configuration
#define MTF_HTF     PERIOD_H1    // High Timeframe - Direction
#define MTF_MTF     PERIOD_M15   // Medium Timeframe - Structure  
#define MTF_LTF     PERIOD_M5    // Low Timeframe - Execution

//--- Trend Direction Enum
enum ENUM_MTF_TREND
{
   MTF_TREND_BULLISH = 1,      // Clear bullish trend
   MTF_TREND_BEARISH = -1,     // Clear bearish trend
   MTF_TREND_NEUTRAL = 0,      // No clear direction
   MTF_TREND_RANGING = 2       // Range-bound market
};

//--- MTF Alignment Quality
enum ENUM_MTF_ALIGNMENT
{
   MTF_ALIGN_PERFECT = 3,      // All TFs aligned
   MTF_ALIGN_GOOD = 2,         // 2 TFs aligned
   MTF_ALIGN_WEAK = 1,         // Only 1 TF confirms
   MTF_ALIGN_NONE = 0          // No alignment
};

//--- Structure for HTF Analysis
struct SHTFAnalysis
{
   ENUM_MTF_TREND    trend;               // H1 trend direction
   double            trend_strength;       // Trend strength (0-100)
   double            ma_20;               // H1 MA(20)
   double            ma_50;               // H1 MA(50)
   double            atr;                 // H1 ATR(14)
   double            rsi;                 // H1 RSI(14)
   bool              is_trending;         // True if H > 0.55 or < 0.45
   double            hurst;               // Hurst exponent estimate
   datetime          last_update;         // Last update time
   
   // Key levels from H1
   double            swing_high;          // Last H1 swing high
   double            swing_low;           // Last H1 swing low
   double            daily_high;          // Today's high
   double            daily_low;           // Today's low
   
   void Reset()
   {
      trend = MTF_TREND_NEUTRAL;
      trend_strength = 0;
      ma_20 = 0;
      ma_50 = 0;
      atr = 0;
      rsi = 50;
      is_trending = false;
      hurst = 0.5;
      last_update = 0;
      swing_high = 0;
      swing_low = 0;
      daily_high = 0;
      daily_low = 0;
   }
};

//--- Structure for MTF (M15) Analysis
struct SMTFAnalysis
{
   ENUM_MTF_TREND    trend;               // M15 trend direction
   double            trend_strength;       // Trend strength (0-100)
   
   // Structure levels
   bool              has_active_ob;        // Active Order Block present
   bool              has_active_fvg;       // Active FVG present
   bool              has_liquidity_pool;   // Liquidity pool nearby
   
   double            nearest_ob_high;      // Nearest OB high
   double            nearest_ob_low;       // Nearest OB low
   double            nearest_fvg_high;     // Nearest FVG high
   double            nearest_fvg_low;      // Nearest FVG low
   
   // Market structure
   double            last_swing_high;      // M15 swing high
   double            last_swing_low;       // M15 swing low
   bool              bos_bullish;          // Break of structure bullish
   bool              bos_bearish;          // Break of structure bearish
   bool              choch_detected;       // Change of character
   
   datetime          last_update;
   
   void Reset()
   {
      trend = MTF_TREND_NEUTRAL;
      trend_strength = 0;
      has_active_ob = false;
      has_active_fvg = false;
      has_liquidity_pool = false;
      nearest_ob_high = 0;
      nearest_ob_low = 0;
      nearest_fvg_high = 0;
      nearest_fvg_low = 0;
      last_swing_high = 0;
      last_swing_low = 0;
      bos_bullish = false;
      bos_bearish = false;
      choch_detected = false;
      last_update = 0;
   }
};

//--- Structure for LTF (M5) Analysis
struct SLTFAnalysis
{
   ENUM_MTF_TREND    trend;               // M5 trend direction
   double            trend_strength;       // Trend strength (0-100)
   
   // Entry signals
   bool              has_confirmation;     // Confirmation candle present
   bool              bullish_engulf;       // Bullish engulfing
   bool              bearish_engulf;       // Bearish engulfing
   bool              pin_bar_bullish;      // Bullish pin bar
   bool              pin_bar_bearish;      // Bearish pin bar
   
   // Momentum
   double            rsi;                  // M5 RSI
   double            momentum;             // Price momentum
   bool              momentum_aligned;     // Momentum with trend
   
   // Entry precision
   double            optimal_entry_long;   // Best entry for longs
   double            optimal_entry_short;  // Best entry for shorts
   double            tight_sl_long;        // Tight SL for longs
   double            tight_sl_short;       // Tight SL for shorts
   
   datetime          last_update;
   
   void Reset()
   {
      trend = MTF_TREND_NEUTRAL;
      trend_strength = 0;
      has_confirmation = false;
      bullish_engulf = false;
      bearish_engulf = false;
      pin_bar_bullish = false;
      pin_bar_bearish = false;
      rsi = 50;
      momentum = 0;
      momentum_aligned = false;
      optimal_entry_long = 0;
      optimal_entry_short = 0;
      tight_sl_long = 0;
      tight_sl_short = 0;
      last_update = 0;
   }
};

//--- MTF Session Type Enum (GENIUS v3.2) - Prefixed to avoid collision with CSessionFilter
enum ENUM_MTF_SESSION
{
   MTF_SESSION_OVERLAP = 4,     // London/NY Overlap (best)
   MTF_SESSION_LONDON = 3,      // London session
   MTF_SESSION_NEWYORK = 2,     // New York session
   MTF_SESSION_ASIAN = 1,       // Asian session (low liquidity)
   MTF_SESSION_DEAD = 0         // Dead zone (avoid)
};

//--- MTF Confluence Result
struct SMTFConfluence
{
   ENUM_MTF_ALIGNMENT alignment;          // Overall alignment
   ENUM_SIGNAL_TYPE   signal;             // Trade signal
   double             confidence;          // Confidence score (0-100)
   double             position_size_mult;  // Position size multiplier (0-1)
   
   // Individual TF signals
   ENUM_MTF_TREND     htf_trend;
   ENUM_MTF_TREND     mtf_trend;
   ENUM_MTF_TREND     ltf_trend;
   
   // Entry details
   double             entry_price;
   double             stop_loss;
   double             take_profit;
   double             risk_reward;
   
   // Confluence factors
   bool               htf_aligned;         // H1 supports direction
   bool               mtf_structure;       // M15 has OB/FVG zone
   bool               ltf_confirmed;       // M5 confirmation
   bool               session_ok;          // Active session (quality >= 0.5)
   int                confluence_count;    // Number of factors aligned
   
   // v3.2 GENIUS: Session quality scoring (not binary)
   double             session_quality;     // 0.0-1.0 quality score
   ENUM_MTF_SESSION   session_type;        // Current session type
   bool               has_momentum_divergence; // M15 vs H1 momentum divergence
   
   string             reason;              // Trade reason
   
   void Reset()
   {
      alignment = MTF_ALIGN_NONE;
      signal = SIGNAL_NONE;
      confidence = 0;
      position_size_mult = 0;
      htf_trend = MTF_TREND_NEUTRAL;
      mtf_trend = MTF_TREND_NEUTRAL;
      ltf_trend = MTF_TREND_NEUTRAL;
      entry_price = 0;
      stop_loss = 0;
      take_profit = 0;
      risk_reward = 0;
      htf_aligned = false;
      mtf_structure = false;
      ltf_confirmed = false;
      session_ok = false;
      confluence_count = 0;
      // v3.2 GENIUS fields
      session_quality = 0.0;
      session_type = MTF_SESSION_DEAD;
      has_momentum_divergence = false;
      reason = "";
   }
};

//+------------------------------------------------------------------+
//| CMTFManager - Multi-Timeframe Analysis Manager                   |
//+------------------------------------------------------------------+
// NOTE: ADAPTIVE_TF moved to Phase 2 (requires WFA validation first)
// NOTE: BAYESIAN scoring already implemented in CConfluenceScorer v3.31
class CMTFManager
{
private:
   string            m_symbol;
   
   // Analysis results
   SHTFAnalysis      m_htf;                // H1 analysis
   SMTFAnalysis      m_mtf;                // M15 analysis  
   SLTFAnalysis      m_ltf;                // M5 analysis
   SMTFConfluence    m_confluence;         // Combined result
   
   // Indicator handles
   int               m_htf_ma20_handle;
   int               m_htf_ma50_handle;
   int               m_htf_atr_handle;
   int               m_htf_rsi_handle;
   int               m_mtf_atr_handle;
   int               m_mtf_rsi_handle;     // v3.2 GENIUS: M15 RSI for divergence detection
   int               m_ltf_rsi_handle;
   int               m_ltf_atr_handle;
   
   // Update intervals
   datetime          m_htf_last_bar;
   datetime          m_mtf_last_bar;
   datetime          m_ltf_last_bar;
   
   // Configuration
   double            m_min_trend_strength;  // Min trend strength to confirm
   double            m_min_confluence;      // Min confluence score
   int               m_lookback_bars;       // Bars to analyze
   int               m_gmt_offset;          // v3.2 GENIUS: Broker GMT offset (hours)
   
   // Private methods
   void              AnalyzeHTF();
   void              AnalyzeMTF();
   void              AnalyzeLTF();
   ENUM_MTF_TREND    DetermineTrend(double ma_fast, double ma_slow, double price, double atr);
   double            CalculateTrendStrength(ENUM_TIMEFRAMES tf);
   double            CalculateHurstExponent(ENUM_TIMEFRAMES tf, int periods = 50);
   void              FindSwingPoints(ENUM_TIMEFRAMES tf, double &swing_high, double &swing_low);
   bool              DetectConfirmationCandle(ENUM_SIGNAL_TYPE expected_direction);
   bool              CheckPriceNearSwingLevel(double price, double swing_level, double atr);
   
   // v3.2 GENIUS: Session quality and momentum divergence
   double            CalculateSessionQuality(ENUM_MTF_SESSION &session_type);
   bool              HasMomentumDivergence();
   
public:
                     CMTFManager();
                    ~CMTFManager();
   
   // Initialization
   bool              Init(string symbol);
   void              Deinit();
   
   // Update methods
   void              Update();              // Full update
   void              UpdateHTF();           // Update H1 only (on new H1 bar)
   void              UpdateMTF();           // Update M15 only (on new M15 bar)
   void              UpdateLTF();           // Update M5 on every tick
   
   // Analysis getters
   SHTFAnalysis      GetHTFAnalysis() const { return m_htf; }
   SMTFAnalysis      GetMTFAnalysis() const { return m_mtf; }
   SLTFAnalysis      GetLTFAnalysis() const { return m_ltf; }
   SMTFConfluence    GetConfluence();
   
   // Quick checks
   bool              IsHTFBullish() const { return m_htf.trend == MTF_TREND_BULLISH; }
   bool              IsHTFBearish() const { return m_htf.trend == MTF_TREND_BEARISH; }
   bool              IsTrending() const { return m_htf.is_trending; }
   bool              HasMTFStructure() const { return m_mtf.has_active_ob || m_mtf.has_active_fvg || m_mtf.has_liquidity_pool; }
   bool              HasLTFConfirmation(ENUM_SIGNAL_TYPE direction);
   
   // Trade permission
   bool              CanTradeLong();
   bool              CanTradeShort();
   ENUM_MTF_ALIGNMENT GetAlignment() const { return m_confluence.alignment; }
   double            GetPositionSizeMultiplier() const { return m_confluence.position_size_mult; }
   void              SetStructureFlags(bool has_ob, bool has_fvg, bool has_liquidity=false)
   {
      m_mtf.has_active_ob = has_ob;
      m_mtf.has_active_fvg = has_fvg;
      m_mtf.has_liquidity_pool = has_liquidity;
   }
   
   // Setters
   void              SetMinTrendStrength(double strength) { m_min_trend_strength = strength; }
   void              SetMinConfluence(double conf) { m_min_confluence = conf; }
   void              SetGMTOffset(int offset) { m_gmt_offset = offset; } // v3.2 GENIUS
   
   // v3.2 GENIUS: Session quality getters
   double            GetSessionQuality() const { return m_confluence.session_quality; }
   ENUM_MTF_SESSION  GetSessionType() const { return m_confluence.session_type; }
   bool              IsInActiveSession() const { return m_confluence.session_ok; }
   bool              HasMTFDivergence() const { return m_confluence.has_momentum_divergence; }
   
   // Utility
   string            GetAnalysisSummary();
   string            SessionTypeToString(ENUM_MTF_SESSION session); // v3.2 GENIUS
};

//+------------------------------------------------------------------+
//| Constructor                                                       |
//+------------------------------------------------------------------+
CMTFManager::CMTFManager()
{
   m_symbol = "";
   m_htf.Reset();
   m_mtf.Reset();
   m_ltf.Reset();
   m_confluence.Reset();
   
   m_htf_ma20_handle = INVALID_HANDLE;
   m_htf_ma50_handle = INVALID_HANDLE;
   m_htf_atr_handle = INVALID_HANDLE;
   m_htf_rsi_handle = INVALID_HANDLE;
   m_mtf_atr_handle = INVALID_HANDLE;
   m_mtf_rsi_handle = INVALID_HANDLE;  // v3.2 GENIUS
   m_ltf_rsi_handle = INVALID_HANDLE;
   m_ltf_atr_handle = INVALID_HANDLE;
   
   m_htf_last_bar = 0;
   m_mtf_last_bar = 0;
   m_ltf_last_bar = 0;

   // v4.0: Relaxed defaults for backtest - lower thresholds for more trades
   m_min_trend_strength = 20.0;   // Was 30.0 - too strict
   m_min_confluence = 45.0;       // Was 60.0 - too strict
   m_lookback_bars = 100;
   m_gmt_offset = 0;  // v3.2 GENIUS: Default 0 (assume broker is GMT)
}

//+------------------------------------------------------------------+
//| Destructor                                                        |
//+------------------------------------------------------------------+
CMTFManager::~CMTFManager()
{
   Deinit();
}

//+------------------------------------------------------------------+
//| Initialize                                                        |
//+------------------------------------------------------------------+
bool CMTFManager::Init(string symbol)
{
   m_symbol = symbol;

   // Create H1 indicators
   m_htf_ma20_handle = iMA(m_symbol, MTF_HTF, 20, 0, MODE_EMA, PRICE_CLOSE);
   m_htf_ma50_handle = iMA(m_symbol, MTF_HTF, 50, 0, MODE_EMA, PRICE_CLOSE);
   m_htf_atr_handle = iATR(m_symbol, MTF_HTF, 14);
   m_htf_rsi_handle = iRSI(m_symbol, MTF_HTF, 14, PRICE_CLOSE);

   // Create M15 indicators
   m_mtf_atr_handle = iATR(m_symbol, MTF_MTF, 14);
   m_mtf_rsi_handle = iRSI(m_symbol, MTF_MTF, 14, PRICE_CLOSE);  // v3.2 GENIUS: M15 RSI for divergence

   // Create M5 indicators
   m_ltf_rsi_handle = iRSI(m_symbol, MTF_LTF, 14, PRICE_CLOSE);
   m_ltf_atr_handle = iATR(m_symbol, MTF_LTF, 14);

   // Validate handles
   if(m_htf_ma20_handle == INVALID_HANDLE ||
      m_htf_ma50_handle == INVALID_HANDLE ||
      m_htf_atr_handle == INVALID_HANDLE ||
      m_htf_rsi_handle == INVALID_HANDLE ||
      m_mtf_atr_handle == INVALID_HANDLE ||
      m_mtf_rsi_handle == INVALID_HANDLE ||  // v3.2 GENIUS
      m_ltf_rsi_handle == INVALID_HANDLE ||
      m_ltf_atr_handle == INVALID_HANDLE)
   {
      Print("[MTF] Failed to create indicator handles");
      return false;
   }

   // Wait for indicator data to be ready (critical for backtest)
   int max_wait = 10;  // Max iterations to wait
   for(int i = 0; i < max_wait; i++)
   {
      int htf_bars = BarsCalculated(m_htf_ma20_handle);
      int mtf_bars = BarsCalculated(m_mtf_atr_handle);
      int ltf_bars = BarsCalculated(m_ltf_rsi_handle);

      if(htf_bars >= 50 && mtf_bars >= 20 && ltf_bars >= 20)
      {
         Print("[MTF] Indicator data ready: HTF=", htf_bars, " MTF=", mtf_bars, " LTF=", ltf_bars);
         break;
      }

      if(i == max_wait - 1)
      {
         Print("[MTF] WARNING: Indicator data may not be fully ready. HTF=", htf_bars,
               " MTF=", mtf_bars, " LTF=", ltf_bars);
      }

      Sleep(100);  // Small delay to let indicators calculate
   }

   // Force initial analysis immediately (don't wait for bar change)
   m_htf_last_bar = 0;  // Reset to force first analysis
   m_mtf_last_bar = 0;
   m_ltf_last_bar = 0;

   // Run initial analysis
   AnalyzeHTF();
   AnalyzeMTF();
   AnalyzeLTF();

   // Log initial state
   string trend_str = (m_htf.trend == MTF_TREND_BULLISH) ? "BULLISH" :
                      (m_htf.trend == MTF_TREND_BEARISH) ? "BEARISH" :
                      (m_htf.trend == MTF_TREND_RANGING) ? "RANGING" : "NEUTRAL";
   Print("[MTF] Initial H1 trend: ", trend_str, " | Strength: ", DoubleToString(m_htf.trend_strength, 1),
         " | Trending: ", m_htf.is_trending ? "YES" : "NO");

   Print("[MTF] Manager v3.2 GENIUS initialized for ", m_symbol);
   Print("[MTF] HTF=H1, MTF=M15, LTF=M5 | Session Quality + Momentum Divergence enabled");
   return true;
}

//+------------------------------------------------------------------+
//| Deinitialize                                                      |
//+------------------------------------------------------------------+
void CMTFManager::Deinit()
{
   if(m_htf_ma20_handle != INVALID_HANDLE) IndicatorRelease(m_htf_ma20_handle);
   if(m_htf_ma50_handle != INVALID_HANDLE) IndicatorRelease(m_htf_ma50_handle);
   if(m_htf_atr_handle != INVALID_HANDLE) IndicatorRelease(m_htf_atr_handle);
   if(m_htf_rsi_handle != INVALID_HANDLE) IndicatorRelease(m_htf_rsi_handle);
   if(m_mtf_atr_handle != INVALID_HANDLE) IndicatorRelease(m_mtf_atr_handle);
   if(m_mtf_rsi_handle != INVALID_HANDLE) IndicatorRelease(m_mtf_rsi_handle);  // v3.2 GENIUS
   if(m_ltf_rsi_handle != INVALID_HANDLE) IndicatorRelease(m_ltf_rsi_handle);
   if(m_ltf_atr_handle != INVALID_HANDLE) IndicatorRelease(m_ltf_atr_handle);
}

//+------------------------------------------------------------------+
//| Full update                                                       |
//+------------------------------------------------------------------+
void CMTFManager::Update()
{
   datetime htf_bar = iTime(m_symbol, MTF_HTF, 0);
   datetime mtf_bar = iTime(m_symbol, MTF_MTF, 0);
   datetime ltf_bar = iTime(m_symbol, MTF_LTF, 0);
   
   // Update HTF on new H1 bar
   if(htf_bar != m_htf_last_bar)
   {
      AnalyzeHTF();
      m_htf_last_bar = htf_bar;
   }
   
   // Update MTF on new M15 bar
   if(mtf_bar != m_mtf_last_bar)
   {
      AnalyzeMTF();
      m_mtf_last_bar = mtf_bar;
   }
   
   // Update LTF on new M5 bar (or every tick for precision)
   if(ltf_bar != m_ltf_last_bar)
   {
      AnalyzeLTF();
      m_ltf_last_bar = ltf_bar;
   }
}

//+------------------------------------------------------------------+
//| Update HTF only (call on new H1 bar)                             |
//+------------------------------------------------------------------+
void CMTFManager::UpdateHTF()
{
   datetime htf_bar = iTime(m_symbol, MTF_HTF, 0);
   if(htf_bar != m_htf_last_bar)
   {
      AnalyzeHTF();
      m_htf_last_bar = htf_bar;
   }
}

//+------------------------------------------------------------------+
//| Update MTF only (call on new M15 bar)                            |
//+------------------------------------------------------------------+
void CMTFManager::UpdateMTF()
{
   datetime mtf_bar = iTime(m_symbol, MTF_MTF, 0);
   if(mtf_bar != m_mtf_last_bar)
   {
      AnalyzeMTF();
      m_mtf_last_bar = mtf_bar;
   }
}

//+------------------------------------------------------------------+
//| Update LTF only (call on new M5 bar or every tick)               |
//+------------------------------------------------------------------+
void CMTFManager::UpdateLTF()
{
   datetime ltf_bar = iTime(m_symbol, MTF_LTF, 0);
   if(ltf_bar != m_ltf_last_bar)
   {
      AnalyzeLTF();
      m_ltf_last_bar = ltf_bar;
   }
}

//+------------------------------------------------------------------+
//| Analyze H1 (HTF)                                                  |
//+------------------------------------------------------------------+
void CMTFManager::AnalyzeHTF()
{
   double ma20[], ma50[], atr[], rsi[];
   ArraySetAsSeries(ma20, true);
   ArraySetAsSeries(ma50, true);
   ArraySetAsSeries(atr, true);
   ArraySetAsSeries(rsi, true);

   // CopyBuffer with diagnostic logging for backtest debugging
   int copied_ma20 = CopyBuffer(m_htf_ma20_handle, 0, 0, 3, ma20);
   int copied_ma50 = CopyBuffer(m_htf_ma50_handle, 0, 0, 3, ma50);
   int copied_atr = CopyBuffer(m_htf_atr_handle, 0, 0, 3, atr);
   int copied_rsi = CopyBuffer(m_htf_rsi_handle, 0, 0, 3, rsi);

   if(copied_ma20 < 3 || copied_ma50 < 3 || copied_atr < 3 || copied_rsi < 3)
   {
      // Log diagnostics only once per session (avoid spam)
      static datetime last_warn = 0;
      datetime now = TimeCurrent();
      if(now - last_warn > 300)  // Every 5 minutes max
      {
         Print("[MTF] HTF CopyBuffer issue: MA20=", copied_ma20, " MA50=", copied_ma50,
               " ATR=", copied_atr, " RSI=", copied_rsi, " (need 3 each)");
         last_warn = now;
      }
      return;
   }
   
   double close = iClose(m_symbol, MTF_HTF, 0);
   double atr_val = atr[0];
   if(atr_val <= 0)
   {
      // Sem volatilidade util: considera neutro e nao-trending
      m_htf.ma_20 = ma20[0];
      m_htf.ma_50 = ma50[0];
      m_htf.atr = atr_val;
      m_htf.rsi = rsi[0];
      m_htf.trend = MTF_TREND_NEUTRAL;
      m_htf.trend_strength = 0;
      m_htf.is_trending = false;
      m_htf.last_update = TimeCurrent();
      return;
   }
   
   // Store values
   m_htf.ma_20 = ma20[0];
   m_htf.ma_50 = ma50[0];
   m_htf.atr = atr_val;
   m_htf.rsi = rsi[0];
   
   // Determine trend
   m_htf.trend = DetermineTrend(ma20[0], ma50[0], close, atr_val);
   m_htf.trend_strength = CalculateTrendStrength(MTF_HTF);
   
   // Calculate Hurst exponent for regime detection
   m_htf.hurst = CalculateHurstExponent(MTF_HTF, 50);
   
   // Is trending? (Hurst > 0.55 = persistent/trending, combined with MA separation)
   // v4.0: Relaxed for backtest - require less strict conditions
   double ma_separation = MathAbs(ma20[0] - ma50[0]) / atr_val;
   // Original was: (hurst > 0.55 && ma_sep > 0.5) || (ma_sep > 1.5)
   // Relaxed: (hurst > 0.52 && ma_sep > 0.3) || (ma_sep > 1.0) || (trend != NEUTRAL && strength > 25)
   m_htf.is_trending = (m_htf.hurst > 0.52 && ma_separation > 0.3) ||
                       (ma_separation > 1.0) ||
                       (m_htf.trend != MTF_TREND_NEUTRAL && m_htf.trend != MTF_TREND_RANGING && m_htf.trend_strength > 25.0);
   
   // Find swing points
   FindSwingPoints(MTF_HTF, m_htf.swing_high, m_htf.swing_low);
   
   // Daily levels
   m_htf.daily_high = iHigh(m_symbol, PERIOD_D1, 0);
   m_htf.daily_low = iLow(m_symbol, PERIOD_D1, 0);
   
   m_htf.last_update = TimeCurrent();
}

//+------------------------------------------------------------------+
//| Analyze M15 (MTF)                                                 |
//+------------------------------------------------------------------+
void CMTFManager::AnalyzeMTF()
{
   double atr[];
   ArraySetAsSeries(atr, true);
   if(CopyBuffer(m_mtf_atr_handle, 0, 0, 3, atr) < 3) return;
   
   double close = iClose(m_symbol, MTF_MTF, 0);
   double high = iHigh(m_symbol, MTF_MTF, 0);
   double low = iLow(m_symbol, MTF_MTF, 0);
   
   // Trend from H1 perspective (inherit direction)
   if(m_htf.trend == MTF_TREND_BULLISH)
      m_mtf.trend = MTF_TREND_BULLISH;
   else if(m_htf.trend == MTF_TREND_BEARISH)
      m_mtf.trend = MTF_TREND_BEARISH;
   else
      m_mtf.trend = MTF_TREND_NEUTRAL;
   
   m_mtf.trend_strength = CalculateTrendStrength(MTF_MTF);
   
   // Find M15 swing points
   FindSwingPoints(MTF_MTF, m_mtf.last_swing_high, m_mtf.last_swing_low);
   
   // Check for break of structure
   double prev_high = iHigh(m_symbol, MTF_MTF, 1);
   double prev_low = iLow(m_symbol, MTF_MTF, 1);
   
   // Simple BOS detection
   if(close > m_mtf.last_swing_high && prev_high <= m_mtf.last_swing_high)
      m_mtf.bos_bullish = true;
   else
      m_mtf.bos_bullish = false;
      
   if(close < m_mtf.last_swing_low && prev_low >= m_mtf.last_swing_low)
      m_mtf.bos_bearish = true;
   else
      m_mtf.bos_bearish = false;
   
   // Structure presence: use dedicated detectors if available (OB/FVG flags)
   // FALLBACK: If no external flags set, check price proximity to swing levels
   if(!m_mtf.has_active_ob && !m_mtf.has_active_fvg)
   {
      double mtf_atr = atr[0];
      double current_bid = SymbolInfoDouble(m_symbol, SYMBOL_BID);
      
      // Fallback zone detection: price near M15 swing level = potential structure
      bool near_swing_high = CheckPriceNearSwingLevel(current_bid, m_mtf.last_swing_high, mtf_atr);
      bool near_swing_low = CheckPriceNearSwingLevel(current_bid, m_mtf.last_swing_low, mtf_atr);
      
      // Set internal structure flag if near key level AND aligned with HTF trend
      if(m_htf.trend == MTF_TREND_BULLISH && near_swing_low)
         m_mtf.has_liquidity_pool = true;  // Potential demand zone
      else if(m_htf.trend == MTF_TREND_BEARISH && near_swing_high)
         m_mtf.has_liquidity_pool = true;  // Potential supply zone
      
      // Store swing levels as pseudo-OB levels for entry optimization
      if(near_swing_low || near_swing_high)
      {
         m_mtf.nearest_ob_high = m_mtf.last_swing_high;
         m_mtf.nearest_ob_low = m_mtf.last_swing_low;
      }
   }
   
   m_mtf.last_update = TimeCurrent();
}

//+------------------------------------------------------------------+
//| Analyze M5 (LTF)                                                  |
//+------------------------------------------------------------------+
void CMTFManager::AnalyzeLTF()
{
   double rsi[];
   ArraySetAsSeries(rsi, true);
   if(CopyBuffer(m_ltf_rsi_handle, 0, 0, 3, rsi) < 3) return;
   
   m_ltf.rsi = rsi[0];
   
   // Get recent candles
   double open1 = iOpen(m_symbol, MTF_LTF, 1);
   double close1 = iClose(m_symbol, MTF_LTF, 1);
   double high1 = iHigh(m_symbol, MTF_LTF, 1);
   double low1 = iLow(m_symbol, MTF_LTF, 1);
   
   double open2 = iOpen(m_symbol, MTF_LTF, 2);
   double close2 = iClose(m_symbol, MTF_LTF, 2);
   
   double body1 = MathAbs(close1 - open1);
   double body2 = MathAbs(close2 - open2);
   double range1 = high1 - low1;
   
   // Detect engulfing
   m_ltf.bullish_engulf = (close2 < open2 && close1 > open1 && close1 > open2 && open1 < close2 && body1 > body2);
   m_ltf.bearish_engulf = (close2 > open2 && close1 < open1 && close1 < open2 && open1 > close2 && body1 > body2);
   
   // Detect pin bars
   double upper_wick1 = high1 - MathMax(open1, close1);
   double lower_wick1 = MathMin(open1, close1) - low1;
   
   m_ltf.pin_bar_bullish = (lower_wick1 > body1 * 2 && upper_wick1 < body1 * 0.5);
   m_ltf.pin_bar_bearish = (upper_wick1 > body1 * 2 && lower_wick1 < body1 * 0.5);
   
   // Check confirmation
   m_ltf.has_confirmation = m_ltf.bullish_engulf || m_ltf.bearish_engulf || 
                            m_ltf.pin_bar_bullish || m_ltf.pin_bar_bearish;
   
   // Calculate momentum
   double closes5[];
   ArraySetAsSeries(closes5, true);
   if(CopyClose(m_symbol, MTF_LTF, 0, 6, closes5) < 6)
      return;
   double close_5 = closes5[5];
   // v4.1: Use epsilon check to avoid division by zero/near-zero
   if(MathAbs(close_5) > 1e-10)
      m_ltf.momentum = (close1 - close_5) / close_5 * 100;
   else
      m_ltf.momentum = 0;
   
   // Is momentum aligned with HTF trend?
   if(m_htf.trend == MTF_TREND_BULLISH && m_ltf.momentum > 0)
      m_ltf.momentum_aligned = true;
   else if(m_htf.trend == MTF_TREND_BEARISH && m_ltf.momentum < 0)
      m_ltf.momentum_aligned = true;
   else
      m_ltf.momentum_aligned = false;
   
   // Calculate optimal entries
   double atr_m5_buf[];
   ArraySetAsSeries(atr_m5_buf, true);
   if(CopyBuffer(m_ltf_atr_handle, 0, 0, 1, atr_m5_buf) < 1) return;
   double atr_m5 = atr_m5_buf[0];
   double current_price = SymbolInfoDouble(m_symbol, SYMBOL_BID);
   
   m_ltf.optimal_entry_long = low1;  // Entry at previous low
   m_ltf.optimal_entry_short = high1; // Entry at previous high
   m_ltf.tight_sl_long = low1 - atr_m5 * 0.5;
   m_ltf.tight_sl_short = high1 + atr_m5 * 0.5;
   
   // Determine LTF trend
   if(rsi[0] > 55 && m_ltf.momentum > 0)
      m_ltf.trend = MTF_TREND_BULLISH;
   else if(rsi[0] < 45 && m_ltf.momentum < 0)
      m_ltf.trend = MTF_TREND_BEARISH;
   else
      m_ltf.trend = MTF_TREND_NEUTRAL;
   
   m_ltf.last_update = TimeCurrent();
}

//+------------------------------------------------------------------+
//| Determine trend direction                                         |
//+------------------------------------------------------------------+
ENUM_MTF_TREND CMTFManager::DetermineTrend(double ma_fast, double ma_slow, double price, double atr)
{
   double threshold = atr * 0.3; // 30% of ATR as threshold
   
   if(price > ma_fast && ma_fast > ma_slow && (ma_fast - ma_slow) > threshold)
      return MTF_TREND_BULLISH;
   else if(price < ma_fast && ma_fast < ma_slow && (ma_slow - ma_fast) > threshold)
      return MTF_TREND_BEARISH;
   else if(MathAbs(ma_fast - ma_slow) < threshold)
      return MTF_TREND_RANGING;
   else
      return MTF_TREND_NEUTRAL;
}

//+------------------------------------------------------------------+
//| Calculate trend strength (improved: MA slope + directional move) |
//+------------------------------------------------------------------+
double CMTFManager::CalculateTrendStrength(ENUM_TIMEFRAMES tf)
{
   double closes[];
   ArraySetAsSeries(closes, true);
   if(CopyClose(m_symbol, tf, 0, 20, closes) < 20) return 0;
   
   // Component 1: Directional bar count (0-50 points)
   int up_count = 0;
   int down_count = 0;
   for(int i = 0; i < 19; i++)
   {
      if(closes[i] > closes[i+1]) up_count++;
      else if(closes[i] < closes[i+1]) down_count++;
   }
   double dir_score = MathAbs(up_count - down_count) / 19.0 * 50;
   
   // Component 2: Price movement relative to range (0-50 points)
   // v4.1: Validate array before calling ArrayMaximum/ArrayMinimum
   if(ArraySize(closes) == 0) return 0;
   int maxIdx = ArrayMaximum(closes);
   int minIdx = ArrayMinimum(closes);
   if(maxIdx < 0 || minIdx < 0) return 0;
   double highest = closes[maxIdx];
   double lowest = closes[minIdx];
   double range = highest - lowest;
   double net_move = MathAbs(closes[0] - closes[19]);
   double move_score = 0;
   if(range > 0)
      move_score = (net_move / range) * 50;
   
   double strength = dir_score + move_score;
   return MathMin(strength, 100.0);
}

//+------------------------------------------------------------------+
//| Calculate Hurst Exponent using R/S Analysis                       |
//| H > 0.5 = Trending (persistent), H < 0.5 = Mean-reverting        |
//+------------------------------------------------------------------+
double CMTFManager::CalculateHurstExponent(ENUM_TIMEFRAMES tf, int periods)
{
   double closes[];
   ArraySetAsSeries(closes, true);
   if(CopyClose(m_symbol, tf, 0, periods, closes) < periods) return 0.5;
   
   // Reverse to chronological order for R/S calculation
   double prices[];
   ArrayResize(prices, periods);
   for(int i = 0; i < periods; i++)
      prices[i] = closes[periods - 1 - i];
   
   // Calculate returns
   double returns[];
   ArrayResize(returns, periods - 1);
   for(int i = 0; i < periods - 1; i++)
   {
      if(prices[i] > 0)
         returns[i] = MathLog(prices[i + 1] / prices[i]);
      else
         returns[i] = 0;
   }
   
   int n = periods - 1;
   if(n < 10) return 0.5;
   
   // Calculate mean of returns
   double sum = 0;
   for(int i = 0; i < n; i++)
      sum += returns[i];
   double mean = sum / n;
   
   // Calculate cumulative deviations from mean
   double cumdev[];
   ArrayResize(cumdev, n);
   double running_sum = 0;
   for(int i = 0; i < n; i++)
   {
      running_sum += (returns[i] - mean);
      cumdev[i] = running_sum;
   }
   
   // Range R = max(cumdev) - min(cumdev)
   double R = cumdev[ArrayMaximum(cumdev)] - cumdev[ArrayMinimum(cumdev)];
   
   // Standard deviation S
   double sq_sum = 0;
   for(int i = 0; i < n; i++)
      sq_sum += MathPow(returns[i] - mean, 2);
   double S = MathSqrt(sq_sum / (n - 1));  // Bessel's correction for sample std dev
   
   // Hurst = log(R/S) / log(n)
   if(S <= 0 || R <= 0) return 0.5;
   double RS = R / S;
   double H = MathLog(RS) / MathLog((double)n);
   
   // Clamp to valid range [0, 1]
   return MathMax(0.0, MathMin(1.0, H));
}

//+------------------------------------------------------------------+
//| Check if price is near a swing level (within 0.5 ATR)            |
//+------------------------------------------------------------------+
bool CMTFManager::CheckPriceNearSwingLevel(double price, double swing_level, double atr)
{
   if(atr <= 0) return false;
   double distance = MathAbs(price - swing_level);
   return (distance <= atr * 0.5);
}

//+------------------------------------------------------------------+
//| Find swing points                                                 |
//+------------------------------------------------------------------+
void CMTFManager::FindSwingPoints(ENUM_TIMEFRAMES tf, double &swing_high, double &swing_low)
{
   double highs[], lows[];
   ArraySetAsSeries(highs, true);
   ArraySetAsSeries(lows, true);
   
   if(CopyHigh(m_symbol, tf, 0, m_lookback_bars, highs) < m_lookback_bars) return;
   if(CopyLow(m_symbol, tf, 0, m_lookback_bars, lows) < m_lookback_bars) return;
   
   swing_high = 0;
   swing_low = DBL_MAX;
   
   // Find swing high (local maximum)
   for(int i = 2; i < m_lookback_bars - 2; i++)
   {
      if(highs[i] > highs[i-1] && highs[i] > highs[i-2] &&
         highs[i] > highs[i+1] && highs[i] > highs[i+2])
      {
         if(highs[i] > swing_high) swing_high = highs[i];
         break;
      }
   }
   
   // Find swing low (local minimum)
   for(int i = 2; i < m_lookback_bars - 2; i++)
   {
      if(lows[i] < lows[i-1] && lows[i] < lows[i-2] &&
         lows[i] < lows[i+1] && lows[i] < lows[i+2])
      {
         if(lows[i] < swing_low) swing_low = lows[i];
         break;
      }
   }
   
   if(swing_low == DBL_MAX) swing_low = lows[ArrayMinimum(lows)];
   if(swing_high == 0) swing_high = highs[ArrayMaximum(highs)];
}

//+------------------------------------------------------------------+
//| Get MTF Confluence                                                |
//+------------------------------------------------------------------+
SMTFConfluence CMTFManager::GetConfluence()
{
   m_confluence.Reset();
   
   m_confluence.htf_trend = m_htf.trend;
   m_confluence.mtf_trend = m_mtf.trend;
   m_confluence.ltf_trend = m_ltf.trend;
   
   int confluence_count = 0;
   
   // Check HTF alignment
   if(m_htf.trend == MTF_TREND_BULLISH || m_htf.trend == MTF_TREND_BEARISH)
   {
      m_confluence.htf_aligned = true;
      confluence_count++;
   }
   
   // Check MTF structure (OB, FVG, or fallback liquidity pool near swing)
   if(m_mtf.has_active_ob || m_mtf.has_active_fvg || m_mtf.has_liquidity_pool)
   {
      m_confluence.mtf_structure = true;
      confluence_count++;
   }
   
   // Check LTF confirmation
   bool ltf_bull_conf = (m_ltf.bullish_engulf || m_ltf.pin_bar_bullish) &&
                        (m_ltf.momentum > 0) &&
                        (m_htf.trend == MTF_TREND_BULLISH);
   bool ltf_bear_conf = (m_ltf.bearish_engulf || m_ltf.pin_bar_bearish) &&
                        (m_ltf.momentum < 0) &&
                        (m_htf.trend == MTF_TREND_BEARISH);

   if(ltf_bull_conf || ltf_bear_conf)
   {
      m_confluence.ltf_confirmed = true;
      confluence_count++;
   }
   
   m_confluence.confluence_count = confluence_count;
   
   // Determine alignment quality
   if(confluence_count >= 3)
      m_confluence.alignment = MTF_ALIGN_PERFECT;
   else if(confluence_count == 2)
      m_confluence.alignment = MTF_ALIGN_GOOD;
   else if(confluence_count == 1)
      m_confluence.alignment = MTF_ALIGN_WEAK;
   else
      m_confluence.alignment = MTF_ALIGN_NONE;
   
   // Position size multiplier based on alignment
   switch(m_confluence.alignment)
   {
      case MTF_ALIGN_PERFECT: m_confluence.position_size_mult = 1.0; break;
      case MTF_ALIGN_GOOD:    m_confluence.position_size_mult = 0.75; break;
      case MTF_ALIGN_WEAK:    m_confluence.position_size_mult = 0.5; break;
      default:                m_confluence.position_size_mult = 0.0; break;
   }
   
   // Determine signal
   if(m_confluence.alignment >= MTF_ALIGN_GOOD)
   {
      if(m_htf.trend == MTF_TREND_BULLISH && 
         (m_ltf.bullish_engulf || m_ltf.pin_bar_bullish))
      {
         m_confluence.signal = SIGNAL_BUY;
         m_confluence.entry_price = m_ltf.optimal_entry_long;
         m_confluence.stop_loss = m_ltf.tight_sl_long;
         m_confluence.reason = "MTF Bullish: H1 trend + M15 structure + M5 confirmation";
      }
      else if(m_htf.trend == MTF_TREND_BEARISH && 
              (m_ltf.bearish_engulf || m_ltf.pin_bar_bearish))
      {
         m_confluence.signal = SIGNAL_SELL;
         m_confluence.entry_price = m_ltf.optimal_entry_short;
         m_confluence.stop_loss = m_ltf.tight_sl_short;
         m_confluence.reason = "MTF Bearish: H1 trend + M15 structure + M5 confirmation";
      }
   }
   
   // v3.2 GENIUS: Calculate session quality (not binary)
   ENUM_MTF_SESSION session_type;
   double session_quality = CalculateSessionQuality(session_type);
   m_confluence.session_quality = session_quality;
   m_confluence.session_type = session_type;
   m_confluence.session_ok = (session_quality >= 0.5);  // Tradeable if quality >= 50%
   
   // v3.2 GENIUS: Check for momentum divergence (M15 vs H1)
   m_confluence.has_momentum_divergence = HasMomentumDivergence();
   
   // Calculate confidence (0-100 scale)
   // Base: HTF aligned (30) + MTF structure (35) + LTF confirmed (35) = 100 max
   double conf = 0;
   if(m_confluence.htf_aligned) conf += 30.0;
   if(m_confluence.mtf_structure) conf += 35.0;
   if(m_confluence.ltf_confirmed) conf += 35.0;
   // Bonus for trend strength (up to +10, but cap at 100)
   conf += MathMin(m_htf.trend_strength * 0.1, 10.0);
   
   // v3.2 GENIUS: Session quality adjustment
   // Reduce confidence if outside core sessions (but don't zero it)
   if(session_quality < 1.0)
      conf *= (0.5 + session_quality * 0.5);  // Range: 50%-100% of base conf
   
   // v3.2 GENIUS: Momentum divergence penalty
   // If M15 is showing opposite momentum to H1, reduce confidence by 15%
   if(m_confluence.has_momentum_divergence)
      conf *= 0.85;
   
   m_confluence.confidence = MathMin(conf, 100.0);
   
   return m_confluence;
}

//+------------------------------------------------------------------+
//| Check if can trade long                                           |
//+------------------------------------------------------------------+
bool CMTFManager::CanTradeLong()
{
   if(m_htf.trend != MTF_TREND_BULLISH) return false;
   if(!m_htf.is_trending) return false;
   if(m_htf.trend_strength < m_min_trend_strength) return false;
   if(m_confluence.alignment < MTF_ALIGN_GOOD) return false;
   if(m_confluence.confidence < m_min_confluence) return false;
   if(!m_ltf.momentum_aligned) return false;
   
   return true;
}

//+------------------------------------------------------------------+
//| Check if can trade short                                          |
//+------------------------------------------------------------------+
bool CMTFManager::CanTradeShort()
{
   if(m_htf.trend != MTF_TREND_BEARISH) return false;
   if(!m_htf.is_trending) return false;
   if(m_htf.trend_strength < m_min_trend_strength) return false;
   if(m_confluence.alignment < MTF_ALIGN_GOOD) return false;
   if(m_confluence.confidence < m_min_confluence) return false;
   if(!m_ltf.momentum_aligned) return false;
   
   return true;
}

//+------------------------------------------------------------------+
//| Check LTF confirmation for direction                              |
//+------------------------------------------------------------------+
bool CMTFManager::HasLTFConfirmation(ENUM_SIGNAL_TYPE direction)
{
   if(direction == SIGNAL_BUY)
      return (m_ltf.bullish_engulf || m_ltf.pin_bar_bullish) && m_ltf.momentum > 0;
   else if(direction == SIGNAL_SELL)
      return (m_ltf.bearish_engulf || m_ltf.pin_bar_bearish) && m_ltf.momentum < 0;
   
   return false;
}

//+------------------------------------------------------------------+
//| v3.2 GENIUS: Calculate session quality based on time             |
//| Returns quality score 0.0-1.0 and sets session type              |
//| Sessions based on GMT with configurable offset                   |
//+------------------------------------------------------------------+
double CMTFManager::CalculateSessionQuality(ENUM_MTF_SESSION &session_type)
{
   MqlDateTime dt;
   TimeToStruct(TimeCurrent(), dt);
   
   // Apply GMT offset (broker time to GMT)
   int gmt_hour = (dt.hour - m_gmt_offset + 24) % 24;
   
   // Session definitions (GMT):
   // ASIAN:    00:00 - 07:00 (Tokyo 00-08, Hong Kong)
   // LONDON:   07:00 - 16:00 (Core 08-16)
   // OVERLAP:  13:00 - 16:00 (London + NY best liquidity)
   // NY:       13:00 - 21:00 (Core 13-21)
   // DEAD:     21:00 - 00:00 (Low liquidity)
   
   // Check for overlap first (highest priority)
   if(gmt_hour >= 13 && gmt_hour < 16)
   {
      session_type = MTF_SESSION_OVERLAP;
      return 1.0;  // Perfect liquidity
   }
   
   // London (non-overlap)
   if(gmt_hour >= 7 && gmt_hour < 13)
   {
      session_type = MTF_SESSION_LONDON;
      return 0.85;  // Excellent liquidity
   }
   
   // NY (non-overlap)
   if(gmt_hour >= 16 && gmt_hour < 21)
   {
      session_type = MTF_SESSION_NEWYORK;
      return 0.85;  // Excellent liquidity
   }
   
   // Asian
   if(gmt_hour >= 0 && gmt_hour < 7)
   {
      session_type = MTF_SESSION_ASIAN;
      return 0.40;  // Low liquidity, wide spreads
   }
   
   // Dead zone (21:00 - 00:00)
   session_type = MTF_SESSION_DEAD;
   return 0.25;  // Avoid trading
}

//+------------------------------------------------------------------+
//| v3.2 GENIUS: Detect momentum divergence between M15 and H1       |
//| Returns true if M15 RSI opposes H1 trend direction               |
//| This is a WARNING sign - trade with caution                      |
//+------------------------------------------------------------------+
bool CMTFManager::HasMomentumDivergence()
{
   // If no H1 trend, no divergence possible
   if(m_htf.trend == MTF_TREND_NEUTRAL || m_htf.trend == MTF_TREND_RANGING)
      return false;
   
   // Get M15 RSI
   double rsi_m15[];
   ArraySetAsSeries(rsi_m15, true);
   if(m_mtf_rsi_handle == INVALID_HANDLE) return false;
   if(CopyBuffer(m_mtf_rsi_handle, 0, 0, 1, rsi_m15) < 1) return false;
   
   double mtf_rsi = rsi_m15[0];
   
   // Divergence detection:
   // H1 BULLISH but M15 RSI < 45 = BEARISH divergence (momentum weakening)
   // H1 BEARISH but M15 RSI > 55 = BULLISH divergence (momentum weakening)
   
   if(m_htf.trend == MTF_TREND_BULLISH && mtf_rsi < 45.0)
      return true;  // H1 up, but M15 momentum is down
   
   if(m_htf.trend == MTF_TREND_BEARISH && mtf_rsi > 55.0)
      return true;  // H1 down, but M15 momentum is up
   
   return false;
}

//+------------------------------------------------------------------+
//| v3.2 GENIUS: Convert session type to string                      |
//+------------------------------------------------------------------+
string CMTFManager::SessionTypeToString(ENUM_MTF_SESSION session)
{
   switch(session)
   {
      case MTF_SESSION_OVERLAP:  return "OVERLAP";
      case MTF_SESSION_LONDON:   return "LONDON";
      case MTF_SESSION_NEWYORK:  return "NY";
      case MTF_SESSION_ASIAN:    return "ASIAN";
      case MTF_SESSION_DEAD:     return "DEAD";
      default:                   return "UNKNOWN";
   }
}

//+------------------------------------------------------------------+
//| Get analysis summary (v3.2 GENIUS: includes session info)        |
//+------------------------------------------------------------------+
string CMTFManager::GetAnalysisSummary()
{
   string htf_str = (m_htf.trend == MTF_TREND_BULLISH) ? "BULLISH" :
                    (m_htf.trend == MTF_TREND_BEARISH) ? "BEARISH" : "NEUTRAL";
   string mtf_str = (m_mtf.has_active_ob) ? "OB Active" : 
                    (m_mtf.has_active_fvg) ? "FVG Active" : 
                    (m_mtf.has_liquidity_pool) ? "Swing Zone" : "No Structure";
   string ltf_str = (m_ltf.has_confirmation) ? "CONFIRMED" : "No Confirmation";
   
   string align_str = (m_confluence.alignment == MTF_ALIGN_PERFECT) ? "PERFECT" :
                      (m_confluence.alignment == MTF_ALIGN_GOOD) ? "GOOD" :
                      (m_confluence.alignment == MTF_ALIGN_WEAK) ? "WEAK" : "NONE";
   
   // v3.2 GENIUS: Add session and divergence info
   string session_str = SessionTypeToString(m_confluence.session_type);
   string div_str = m_confluence.has_momentum_divergence ? " [DIV!]" : "";
   
   return StringFormat("[MTF v3.2] H1:%s | M15:%s | M5:%s | Align:%s (%.0f%%) | Session:%s(%.0f%%)%s",
                       htf_str, mtf_str, ltf_str, align_str, m_confluence.confidence,
                       session_str, m_confluence.session_quality * 100, div_str);
}
//+------------------------------------------------------------------+
