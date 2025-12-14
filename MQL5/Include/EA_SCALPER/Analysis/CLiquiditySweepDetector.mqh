//+------------------------------------------------------------------+
//|                                        CLiquiditySweepDetector.mqh |
//|                           EA_SCALPER_XAUUSD - Singularity Edition |
//|                                                                  |
//|  LIQUIDITY IS THE KEY TO UNDERSTANDING INSTITUTIONAL MOVES       |
//|                                                                  |
//|  WHAT IS LIQUIDITY?                                              |
//|  - Stop losses clustered at obvious levels                       |
//|  - Buy stops above highs, sell stops below lows                  |
//|  - Limit orders waiting to be filled                             |
//|                                                                  |
//|  WHY INSTITUTIONS NEED IT:                                       |
//|  - Large orders need counterparty liquidity                      |
//|  - Triggering stops provides that liquidity                      |
//|  - They ENGINEER moves to grab this liquidity                    |
//|                                                                  |
//|  EQUAL HIGHS/LOWS ARE MAGNETS:                                   |
//|  - Multiple touches = more stops accumulated                     |
//|  - Smart money WILL sweep these levels                           |
//|  - The sweep is often a FAKE move (manipulation)                 |
//|                                                                  |
//|  OUR EDGE:                                                       |
//|  - Identify where liquidity pools exist                          |
//|  - Wait for the sweep (don't get swept)                          |
//|  - Enter in the REAL direction after sweep                       |
//+------------------------------------------------------------------+
#property copyright "EA_SCALPER_XAUUSD - Singularity Edition"
#property strict

#include "../Core/Definitions.mqh"

//+------------------------------------------------------------------+
//| Liquidity Pool Structure                                          |
//| Note: ENUM_LIQUIDITY_TYPE is defined in Definitions.mqh           |
//+------------------------------------------------------------------+
struct SLiquidityPool
{
   double            level;              // Price level
   ENUM_LIQUIDITY_TYPE type;             // BSL or SSL
   int               touch_count;        // How many times tested
   datetime          first_touch;        // When first formed
   datetime          last_touch;         // Most recent touch
   double            strength;           // Estimated stop cluster size
   bool              is_equal_level;     // True if equal highs/lows
   bool              is_swept;           // Has been swept
   datetime          sweep_time;         // When it was swept
   bool              is_valid;
   
   void Reset()
   {
      level = 0;
      type = LIQUIDITY_NONE;
      touch_count = 0;
      first_touch = 0;
      last_touch = 0;
      strength = 0;
      is_equal_level = false;
      is_swept = false;
      sweep_time = 0;
      is_valid = false;
   }
};

//+------------------------------------------------------------------+
//| Sweep Event Structure                                             |
//+------------------------------------------------------------------+
struct SSweepEvent
{
   SLiquidityPool    pool;               // Which pool was swept
   double            sweep_price;        // Highest/lowest point of sweep
   double            sweep_depth;        // How far beyond the level
   datetime          sweep_time;         // When sweep occurred
   int               sweep_bar;          // Bar index
   bool              has_rejection;      // Clear rejection after sweep
   double            rejection_size;     // Size of rejection
   bool              returned_inside;    // Price came back
   int               bars_beyond;        // How many bars stayed beyond
   bool              is_valid_sweep;     // Meets all criteria for valid sweep
   
   void Reset()
   {
      pool.Reset();
      sweep_price = 0;
      sweep_depth = 0;
      sweep_time = 0;
      sweep_bar = 0;
      has_rejection = false;
      rejection_size = 0;
      returned_inside = false;
      bars_beyond = 0;
      is_valid_sweep = false;
   }
};

//+------------------------------------------------------------------+
//| Liquidity Sweep Detector Class                                    |
//+------------------------------------------------------------------+
class CLiquiditySweepDetector
{
private:
   // Configuration
   double            m_equal_tolerance;       // Points tolerance for equal levels
   int               m_min_touches;           // Minimum touches for valid pool
   int               m_lookback_bars;         // Bars to look back for pools
   double            m_min_sweep_depth;       // Minimum sweep beyond level
   int               m_max_bars_beyond;       // Max bars to stay beyond (fake vs real)
   
   // State
   SLiquidityPool    m_bsl_pools[];           // Buy-side liquidity pools
   SLiquidityPool    m_ssl_pools[];           // Sell-side liquidity pools
   SSweepEvent       m_recent_sweeps[];       // Recent sweep events
   int               m_max_pools;
   int               m_max_sweeps;
   
   // Indicator handles
   int               m_atr_handle;
   
   // Internal methods
   void              ScanForLiquidityPools(MqlRates &rates[]);
   void              FindEqualHighs(MqlRates &rates[]);
   void              FindEqualLows(MqlRates &rates[]);
   void              FindSwingHighs(MqlRates &rates[]);
   void              FindSwingLows(MqlRates &rates[]);
   bool              IsEqualLevel(double price1, double price2);
   void              AddBSLPool(double level, datetime time, bool is_equal);
   void              AddSSLPool(double level, datetime time, bool is_equal);
   void              CheckForSweeps(MqlRates &rates[], double atr);
   bool              ValidateSweep(MqlRates &rates[], SLiquidityPool &pool, int sweep_bar, double atr, int &bars_beyond_out, double &sweep_depth_out);
   void              CleanupOldPools();
   double            CalculatePoolStrength(SLiquidityPool &pool);
   
public:
   CLiquiditySweepDetector();
   ~CLiquiditySweepDetector();
   
   // Initialization
   bool              Initialize(string symbol = NULL, ENUM_TIMEFRAMES tf = PERIOD_M15);
   
   // Main update - call on each bar
   void              Update();
   
   // Pool queries
   int               GetBSLPoolCount() { return ArraySize(m_bsl_pools); }
   int               GetSSLPoolCount() { return ArraySize(m_ssl_pools); }
   SLiquidityPool    GetNearestBSL(double current_price);
   SLiquidityPool    GetNearestSSL(double current_price);
   bool              HasBSLAbove(double price, double max_distance);
   bool              HasSSLBelow(double price, double max_distance);
   
   // Sweep queries
   bool              HasRecentSweep(int within_bars = 10);
   SSweepEvent       GetMostRecentSweep();
   bool              WasBSLSwept(int within_bars = 10);
   bool              WasSSLSwept(int within_bars = 10);
   
   // Signal generation
   ENUM_SIGNAL_TYPE  GetSweepSignal();    // Direction to trade after sweep
   bool              HasValidSweepSetup();
   
   // Quality metrics
   int               GetSweepScore();      // 0-100 quality score
   double            GetSweepStrength();   // Estimated stop cluster size
   
   // Configuration
   void              SetEqualTolerance(double points) { m_equal_tolerance = points; }
   void              SetMinTouches(int touches) { m_min_touches = touches; }
   void              SetMinSweepDepth(double points) { m_min_sweep_depth = points; }
   
   // Cleanup
   void              Deinitialize();
};

//+------------------------------------------------------------------+
//| Constructor                                                       |
//+------------------------------------------------------------------+
CLiquiditySweepDetector::CLiquiditySweepDetector()
{
   m_equal_tolerance = 3.0;       // 3 points for XAUUSD
   m_min_touches = 2;             // At least 2 touches for equal level
   m_lookback_bars = 100;         // Look back 100 bars
   m_min_sweep_depth = 5.0;       // At least 5 points beyond
   m_max_bars_beyond = 3;         // Max 3 bars staying beyond (fake)
   
   m_max_pools = 20;
   m_max_sweeps = 10;
   
   ArrayResize(m_bsl_pools, 0);
   ArrayResize(m_ssl_pools, 0);
   ArrayResize(m_recent_sweeps, 0);
   
   m_atr_handle = INVALID_HANDLE;
}

//+------------------------------------------------------------------+
//| Destructor                                                        |
//+------------------------------------------------------------------+
CLiquiditySweepDetector::~CLiquiditySweepDetector()
{
   Deinitialize();
}

//+------------------------------------------------------------------+
//| Initialize                                                        |
//+------------------------------------------------------------------+
bool CLiquiditySweepDetector::Initialize(string symbol = NULL, ENUM_TIMEFRAMES tf = PERIOD_M15)
{
   if(symbol == NULL) symbol = _Symbol;
   
   m_atr_handle = iATR(symbol, tf, 14);
   if(m_atr_handle == INVALID_HANDLE)
   {
      Print("CLiquiditySweepDetector: Failed to create ATR handle");
      return false;
   }
   
   // Initial scan
   Update();
   
   Print("CLiquiditySweepDetector: Initialized - BSL pools: ", ArraySize(m_bsl_pools),
         ", SSL pools: ", ArraySize(m_ssl_pools));
   
   return true;
}

//+------------------------------------------------------------------+
//| Update - Call on each new bar                                     |
//+------------------------------------------------------------------+
void CLiquiditySweepDetector::Update()
{
   MqlRates rates[];
   int copied = CopyRates(_Symbol, PERIOD_M15, 0, m_lookback_bars + 20, rates);
   if(copied < 50)
   {
      Print("CLiquiditySweepDetector: Insufficient data");
      return;
   }
   ArraySetAsSeries(rates, true);
   
   double atr_buf[];
   if(CopyBuffer(m_atr_handle, 0, 0, 1, atr_buf) <= 0)
      return;
   double atr = atr_buf[0];
   
   // Scan for liquidity pools
   ScanForLiquidityPools(rates);
   
   // Check for sweeps
   CheckForSweeps(rates, atr);
   
   // Cleanup old pools
   CleanupOldPools();
}

//+------------------------------------------------------------------+
//| Scan for liquidity pools                                          |
//+------------------------------------------------------------------+
void CLiquiditySweepDetector::ScanForLiquidityPools(MqlRates &rates[])
{
   // Clear existing pools
   ArrayResize(m_bsl_pools, 0);
   ArrayResize(m_ssl_pools, 0);
   
   // Find equal highs (BSL)
   FindEqualHighs(rates);
   
   // Find equal lows (SSL)
   FindEqualLows(rates);
   
   // Find swing highs (BSL)
   FindSwingHighs(rates);
   
   // Find swing lows (SSL)
   FindSwingLows(rates);
}

//+------------------------------------------------------------------+
//| Find Equal Highs (Strong BSL)                                     |
//+------------------------------------------------------------------+
void CLiquiditySweepDetector::FindEqualHighs(MqlRates &rates[])
{
   int size = ArraySize(rates);
   if(size < 20) return;
   
   // Scan for multiple highs at same level
   for(int i = 5; i < MathMin(size - 5, m_lookback_bars); i++)
   {
      double high_level = rates[i].high;
      int touches = 1;
      datetime first_time = rates[i].time;
      datetime last_time = rates[i].time;
      
      // Look for other highs at this level
      for(int j = i + 5; j < MathMin(size, m_lookback_bars); j++)
      {
         if(IsEqualLevel(rates[j].high, high_level))
         {
            touches++;
            if(rates[j].time < first_time) first_time = rates[j].time;
            if(rates[j].time > last_time) last_time = rates[j].time;
         }
      }
      
      // If we found multiple touches, it's a liquidity pool
      if(touches >= m_min_touches)
      {
         bool already_exists = false;
         for(int k = 0; k < ArraySize(m_bsl_pools); k++)
         {
            if(IsEqualLevel(m_bsl_pools[k].level, high_level))
            {
               already_exists = true;
               if(touches > m_bsl_pools[k].touch_count)
                  m_bsl_pools[k].touch_count = touches;
               break;
            }
         }
         
         if(!already_exists)
         {
            AddBSLPool(high_level, first_time, true);
            m_bsl_pools[ArraySize(m_bsl_pools)-1].touch_count = touches;
            m_bsl_pools[ArraySize(m_bsl_pools)-1].first_touch = first_time;
            m_bsl_pools[ArraySize(m_bsl_pools)-1].last_touch = last_time;
         }
      }
   }
}

//+------------------------------------------------------------------+
//| Find Equal Lows (Strong SSL)                                      |
//+------------------------------------------------------------------+
void CLiquiditySweepDetector::FindEqualLows(MqlRates &rates[])
{
   int size = ArraySize(rates);
   if(size < 20) return;
   
   for(int i = 5; i < MathMin(size - 5, m_lookback_bars); i++)
   {
      double low_level = rates[i].low;
      int touches = 1;
      datetime first_time = rates[i].time;
      datetime last_time = rates[i].time;
      
      for(int j = i + 5; j < MathMin(size, m_lookback_bars); j++)
      {
         if(IsEqualLevel(rates[j].low, low_level))
         {
            touches++;
            if(rates[j].time < first_time) first_time = rates[j].time;
            if(rates[j].time > last_time) last_time = rates[j].time;
         }
      }
      
      if(touches >= m_min_touches)
      {
         bool already_exists = false;
         for(int k = 0; k < ArraySize(m_ssl_pools); k++)
         {
            if(IsEqualLevel(m_ssl_pools[k].level, low_level))
            {
               already_exists = true;
               if(touches > m_ssl_pools[k].touch_count)
                  m_ssl_pools[k].touch_count = touches;
               break;
            }
         }
         
         if(!already_exists)
         {
            AddSSLPool(low_level, first_time, true);
            m_ssl_pools[ArraySize(m_ssl_pools)-1].touch_count = touches;
            m_ssl_pools[ArraySize(m_ssl_pools)-1].first_touch = first_time;
            m_ssl_pools[ArraySize(m_ssl_pools)-1].last_touch = last_time;
         }
      }
   }
}

//+------------------------------------------------------------------+
//| Find Swing Highs (BSL)                                            |
//+------------------------------------------------------------------+
void CLiquiditySweepDetector::FindSwingHighs(MqlRates &rates[])
{
   int size = ArraySize(rates);
   if(size < 10) return;
   
   // A swing high is higher than bars on both sides
   for(int i = 3; i < MathMin(size - 3, m_lookback_bars); i++)
   {
      bool is_swing_high = true;
      
      // Check 3 bars on each side
      for(int j = 1; j <= 3; j++)
      {
         if(rates[i].high <= rates[i-j].high || rates[i].high <= rates[i+j].high)
         {
            is_swing_high = false;
            break;
         }
      }
      
      if(is_swing_high)
      {
         // Check if this level already exists
         bool exists = false;
         for(int k = 0; k < ArraySize(m_bsl_pools); k++)
         {
            if(IsEqualLevel(m_bsl_pools[k].level, rates[i].high))
            {
               exists = true;
               break;
            }
         }
         
         if(!exists)
         {
            AddBSLPool(rates[i].high, rates[i].time, false);
         }
      }
   }
}

//+------------------------------------------------------------------+
//| Find Swing Lows (SSL)                                             |
//+------------------------------------------------------------------+
void CLiquiditySweepDetector::FindSwingLows(MqlRates &rates[])
{
   int size = ArraySize(rates);
   if(size < 10) return;
   
   for(int i = 3; i < MathMin(size - 3, m_lookback_bars); i++)
   {
      bool is_swing_low = true;
      
      for(int j = 1; j <= 3; j++)
      {
         if(rates[i].low >= rates[i-j].low || rates[i].low >= rates[i+j].low)
         {
            is_swing_low = false;
            break;
         }
      }
      
      if(is_swing_low)
      {
         bool exists = false;
         for(int k = 0; k < ArraySize(m_ssl_pools); k++)
         {
            if(IsEqualLevel(m_ssl_pools[k].level, rates[i].low))
            {
               exists = true;
               break;
            }
         }
         
         if(!exists)
         {
            AddSSLPool(rates[i].low, rates[i].time, false);
         }
      }
   }
}

//+------------------------------------------------------------------+
//| Check if two levels are equal within tolerance                    |
//+------------------------------------------------------------------+
bool CLiquiditySweepDetector::IsEqualLevel(double price1, double price2)
{
   return MathAbs(price1 - price2) <= m_equal_tolerance;
}

//+------------------------------------------------------------------+
//| Add BSL Pool                                                      |
//+------------------------------------------------------------------+
void CLiquiditySweepDetector::AddBSLPool(double level, datetime time, bool is_equal)
{
   if(ArraySize(m_bsl_pools) >= m_max_pools)
      ArrayRemove(m_bsl_pools, 0, 1);
   
   int idx = ArraySize(m_bsl_pools);
   ArrayResize(m_bsl_pools, idx + 1);
   
   m_bsl_pools[idx].Reset();
   m_bsl_pools[idx].level = level;
   m_bsl_pools[idx].type = LIQUIDITY_BSL;
   m_bsl_pools[idx].touch_count = 1;
   m_bsl_pools[idx].first_touch = time;
   m_bsl_pools[idx].last_touch = time;
   m_bsl_pools[idx].is_equal_level = is_equal;
   m_bsl_pools[idx].is_valid = true;
}

//+------------------------------------------------------------------+
//| Add SSL Pool                                                      |
//+------------------------------------------------------------------+
void CLiquiditySweepDetector::AddSSLPool(double level, datetime time, bool is_equal)
{
   if(ArraySize(m_ssl_pools) >= m_max_pools)
      ArrayRemove(m_ssl_pools, 0, 1);
   
   int idx = ArraySize(m_ssl_pools);
   ArrayResize(m_ssl_pools, idx + 1);
   
   m_ssl_pools[idx].Reset();
   m_ssl_pools[idx].level = level;
   m_ssl_pools[idx].type = LIQUIDITY_SSL;
   m_ssl_pools[idx].touch_count = 1;
   m_ssl_pools[idx].first_touch = time;
   m_ssl_pools[idx].last_touch = time;
   m_ssl_pools[idx].is_equal_level = is_equal;
   m_ssl_pools[idx].is_valid = true;
}

//+------------------------------------------------------------------+
//| Check for sweeps                                                  |
//+------------------------------------------------------------------+
void CLiquiditySweepDetector::CheckForSweeps(MqlRates &rates[], double atr)
{
   // Check BSL sweeps
   for(int i = 0; i < ArraySize(m_bsl_pools); i++)
   {
      if(m_bsl_pools[i].is_swept) continue;
      
      // Check recent bars for sweep
      for(int j = 0; j < 10; j++)
      {
         if(rates[j].high > m_bsl_pools[i].level + m_min_sweep_depth)
         {
            int bars_beyond = 0; double depth = 0;
            if(ValidateSweep(rates, m_bsl_pools[i], j, atr, bars_beyond, depth))
            {
               m_bsl_pools[i].is_swept = true;
               m_bsl_pools[i].sweep_time = rates[j].time;
               
               // Record sweep event
               SSweepEvent sweep;
               sweep.Reset();
               sweep.pool = m_bsl_pools[i];
               sweep.sweep_price = rates[j].high;
               sweep.sweep_depth = rates[j].high - m_bsl_pools[i].level;
               sweep.sweep_time = rates[j].time;
               sweep.sweep_bar = j;
               sweep.is_valid_sweep = true;
               sweep.bars_beyond = bars_beyond;
               
               // Check rejection
               double upper_wick = rates[j].high - MathMax(rates[j].open, rates[j].close);
               double body = MathAbs(rates[j].close - rates[j].open);
               sweep.has_rejection = (upper_wick > body * 1.5);
               sweep.rejection_size = upper_wick;
               sweep.returned_inside = (rates[0].close < m_bsl_pools[i].level);
               
               if(ArraySize(m_recent_sweeps) >= m_max_sweeps)
                  ArrayRemove(m_recent_sweeps, 0, 1);
               int idx = ArraySize(m_recent_sweeps);
               ArrayResize(m_recent_sweeps, idx + 1);
               m_recent_sweeps[idx] = sweep;
            }
         }
      }
   }
   
   // Check SSL sweeps
   for(int i = 0; i < ArraySize(m_ssl_pools); i++)
   {
      if(m_ssl_pools[i].is_swept) continue;
      
      for(int j = 0; j < 10; j++)
      {
         if(rates[j].low < m_ssl_pools[i].level - m_min_sweep_depth)
         {
            int bars_beyond = 0; double depth = 0;
            if(ValidateSweep(rates, m_ssl_pools[i], j, atr, bars_beyond, depth))
            {
               m_ssl_pools[i].is_swept = true;
               m_ssl_pools[i].sweep_time = rates[j].time;
               
               SSweepEvent sweep;
               sweep.Reset();
               sweep.pool = m_ssl_pools[i];
               sweep.sweep_price = rates[j].low;
               sweep.sweep_depth = m_ssl_pools[i].level - rates[j].low;
               sweep.sweep_time = rates[j].time;
               sweep.sweep_bar = j;
               sweep.is_valid_sweep = true;
               sweep.bars_beyond = bars_beyond;
               
               double lower_wick = MathMin(rates[j].open, rates[j].close) - rates[j].low;
               double body = MathAbs(rates[j].close - rates[j].open);
               sweep.has_rejection = (lower_wick > body * 1.5);
               sweep.rejection_size = lower_wick;
               sweep.returned_inside = (rates[0].close > m_ssl_pools[i].level);
               
               if(ArraySize(m_recent_sweeps) >= m_max_sweeps)
                  ArrayRemove(m_recent_sweeps, 0, 1);
               int idx = ArraySize(m_recent_sweeps);
               ArrayResize(m_recent_sweeps, idx + 1);
               m_recent_sweeps[idx] = sweep;
            }
         }
      }
   }
}

//+------------------------------------------------------------------+
//| Validate a sweep                                                  |
//+------------------------------------------------------------------+
bool CLiquiditySweepDetector::ValidateSweep(MqlRates &rates[], SLiquidityPool &pool, int sweep_bar, double atr, int &bars_beyond_out, double &sweep_depth_out)
{
   // Count how many bars stayed beyond
   int bars_beyond = 0;
   double sweep_depth = 0;
   
   if(pool.type == LIQUIDITY_BSL)
   {
      for(int i = sweep_bar; i >= 0; i--)
      {
         if(rates[i].close > pool.level)
            bars_beyond++;
         else
            break;
      }
      sweep_depth = rates[sweep_bar].high - pool.level;
   }
   else // SSL
   {
      for(int i = sweep_bar; i >= 0; i--)
      {
         if(rates[i].close < pool.level)
            bars_beyond++;
         else
            break;
      }
      sweep_depth = pool.level - rates[sweep_bar].low;
   }
   
   // Require a meaningful probe beyond the level (depth vs ATR and configured minimum)
   if(sweep_depth < m_min_sweep_depth) return false;
   if(atr > 0 && sweep_depth < atr * 0.1) return false; // at least 0.1 ATR
   
   // For a valid fake sweep, price should not stay beyond too long
   if(bars_beyond > m_max_bars_beyond) return false;
   
   bars_beyond_out = bars_beyond;
   sweep_depth_out = sweep_depth;
   return true;
}

//+------------------------------------------------------------------+
//| Cleanup old pools                                                 |
//+------------------------------------------------------------------+
void CLiquiditySweepDetector::CleanupOldPools()
{
   datetime cutoff = TimeCurrent() - m_lookback_bars * PeriodSeconds(PERIOD_M15);
   
   // Remove old BSL pools
   for(int i = ArraySize(m_bsl_pools) - 1; i >= 0; i--)
   {
      if(m_bsl_pools[i].last_touch < cutoff && !m_bsl_pools[i].is_swept)
         ArrayRemove(m_bsl_pools, i, 1);
   }
   
   // Remove old SSL pools
   for(int i = ArraySize(m_ssl_pools) - 1; i >= 0; i--)
   {
      if(m_ssl_pools[i].last_touch < cutoff && !m_ssl_pools[i].is_swept)
         ArrayRemove(m_ssl_pools, i, 1);
   }
}

//+------------------------------------------------------------------+
//| Get nearest BSL pool above current price                          |
//+------------------------------------------------------------------+
SLiquidityPool CLiquiditySweepDetector::GetNearestBSL(double current_price)
{
   SLiquidityPool nearest;
   nearest.Reset();
   
   double min_distance = DBL_MAX;
   
   for(int i = 0; i < ArraySize(m_bsl_pools); i++)
   {
      if(m_bsl_pools[i].is_swept) continue;
      if(m_bsl_pools[i].level <= current_price) continue;
      
      double dist = m_bsl_pools[i].level - current_price;
      if(dist < min_distance)
      {
         min_distance = dist;
         nearest = m_bsl_pools[i];
      }
   }
   
   return nearest;
}

//+------------------------------------------------------------------+
//| Get nearest SSL pool below current price                          |
//+------------------------------------------------------------------+
SLiquidityPool CLiquiditySweepDetector::GetNearestSSL(double current_price)
{
   SLiquidityPool nearest;
   nearest.Reset();
   
   double min_distance = DBL_MAX;
   
   for(int i = 0; i < ArraySize(m_ssl_pools); i++)
   {
      if(m_ssl_pools[i].is_swept) continue;
      if(m_ssl_pools[i].level >= current_price) continue;
      
      double dist = current_price - m_ssl_pools[i].level;
      if(dist < min_distance)
      {
         min_distance = dist;
         nearest = m_ssl_pools[i];
      }
   }
   
   return nearest;
}

//+------------------------------------------------------------------+
//| Check if BSL exists above price within distance                   |
//+------------------------------------------------------------------+
bool CLiquiditySweepDetector::HasBSLAbove(double price, double max_distance)
{
   for(int i = 0; i < ArraySize(m_bsl_pools); i++)
   {
      if(m_bsl_pools[i].is_swept) continue;
      if(m_bsl_pools[i].level > price && m_bsl_pools[i].level - price <= max_distance)
         return true;
   }
   return false;
}

//+------------------------------------------------------------------+
//| Check if SSL exists below price within distance                   |
//+------------------------------------------------------------------+
bool CLiquiditySweepDetector::HasSSLBelow(double price, double max_distance)
{
   for(int i = 0; i < ArraySize(m_ssl_pools); i++)
   {
      if(m_ssl_pools[i].is_swept) continue;
      if(m_ssl_pools[i].level < price && price - m_ssl_pools[i].level <= max_distance)
         return true;
   }
   return false;
}

//+------------------------------------------------------------------+
//| Check for recent sweep                                            |
//+------------------------------------------------------------------+
bool CLiquiditySweepDetector::HasRecentSweep(int within_bars)
{
   if(ArraySize(m_recent_sweeps) == 0) return false;
   
   datetime cutoff = TimeCurrent() - within_bars * PeriodSeconds(PERIOD_M15);
   
   for(int i = ArraySize(m_recent_sweeps) - 1; i >= 0; i--)
   {
      if(m_recent_sweeps[i].sweep_time >= cutoff)
         return true;
   }
   
   return false;
}

//+------------------------------------------------------------------+
//| Get most recent sweep                                             |
//+------------------------------------------------------------------+
SSweepEvent CLiquiditySweepDetector::GetMostRecentSweep()
{
   SSweepEvent empty;
   empty.Reset();
   
   if(ArraySize(m_recent_sweeps) == 0)
      return empty;
   
   return m_recent_sweeps[ArraySize(m_recent_sweeps) - 1];
}

//+------------------------------------------------------------------+
//| Check if BSL was swept recently                                   |
//+------------------------------------------------------------------+
bool CLiquiditySweepDetector::WasBSLSwept(int within_bars)
{
   datetime cutoff = TimeCurrent() - within_bars * PeriodSeconds(PERIOD_M15);
   
   for(int i = ArraySize(m_recent_sweeps) - 1; i >= 0; i--)
   {
      if(m_recent_sweeps[i].sweep_time >= cutoff &&
         m_recent_sweeps[i].pool.type == LIQUIDITY_BSL)
         return true;
   }
   
   return false;
}

//+------------------------------------------------------------------+
//| Check if SSL was swept recently                                   |
//+------------------------------------------------------------------+
bool CLiquiditySweepDetector::WasSSLSwept(int within_bars)
{
   datetime cutoff = TimeCurrent() - within_bars * PeriodSeconds(PERIOD_M15);
   
   for(int i = ArraySize(m_recent_sweeps) - 1; i >= 0; i--)
   {
      if(m_recent_sweeps[i].sweep_time >= cutoff &&
         m_recent_sweeps[i].pool.type == LIQUIDITY_SSL)
         return true;
   }
   
   return false;
}

//+------------------------------------------------------------------+
//| Get sweep signal direction                                        |
//+------------------------------------------------------------------+
ENUM_SIGNAL_TYPE CLiquiditySweepDetector::GetSweepSignal()
{
   if(!HasRecentSweep(10)) return SIGNAL_NONE;
   
   SSweepEvent sweep = GetMostRecentSweep();
   
   if(!sweep.is_valid_sweep) return SIGNAL_NONE;
   if(!sweep.has_rejection) return SIGNAL_NONE;
   if(!sweep.returned_inside) return SIGNAL_NONE;
   
   // BSL sweep = bearish signal coming (they grabbed longs' stops, now going down)
   // SSL sweep = bullish signal coming (they grabbed shorts' stops, now going up)
   
   if(sweep.pool.type == LIQUIDITY_BSL)
      return SIGNAL_SELL;  // After BSL sweep, expect bearish move
   else
      return SIGNAL_BUY;   // After SSL sweep, expect bullish move
}

//+------------------------------------------------------------------+
//| Check for valid sweep setup                                       |
//+------------------------------------------------------------------+
bool CLiquiditySweepDetector::HasValidSweepSetup()
{
   SSweepEvent sweep = GetMostRecentSweep();
   
   return (sweep.is_valid_sweep && 
           sweep.has_rejection && 
           sweep.returned_inside);
}

//+------------------------------------------------------------------+
//| Get sweep quality score                                           |
//+------------------------------------------------------------------+
int CLiquiditySweepDetector::GetSweepScore()
{
   if(!HasRecentSweep(10)) return 0;
   
   SSweepEvent sweep = GetMostRecentSweep();
   if(!(sweep.is_valid_sweep && sweep.has_rejection && sweep.returned_inside))
      return 0;
   
   int score = 20; // base for valid/rejected/returned
   
   // Equal level (stronger pool) (15 points)
   if(sweep.pool.is_equal_level) score += 15;
   
   // Multiple touches (10 points)
   if(sweep.pool.touch_count >= 3) score += 10;
   
   // Sweep depth (price units) relative to ATR approximated by _Point
   if(sweep.sweep_depth > m_min_sweep_depth * 2) score += 10;
   
   // Rejection size bonus
   if(sweep.rejection_size > sweep.sweep_depth * 0.5) score += 15;
   
   // Return inside bonus already counted; add slight bonus for fast return
   if(sweep.bars_beyond <= 1) score += 10;
   
   return MathMin(100, score);
}

//+------------------------------------------------------------------+
//| Get estimated sweep strength                                      |
//+------------------------------------------------------------------+
double CLiquiditySweepDetector::GetSweepStrength()
{
   if(!HasRecentSweep(10)) return 0;
   
   SSweepEvent sweep = GetMostRecentSweep();
   
   // Estimate based on touch count and equal level status
   double base = sweep.pool.touch_count * 10;
   if(sweep.pool.is_equal_level) base *= 1.5;
   
   return base;
}

//+------------------------------------------------------------------+
//| Cleanup                                                           |
//+------------------------------------------------------------------+
void CLiquiditySweepDetector::Deinitialize()
{
   if(m_atr_handle != INVALID_HANDLE)
   {
      IndicatorRelease(m_atr_handle);
      m_atr_handle = INVALID_HANDLE;
   }
   
   ArrayFree(m_bsl_pools);
   ArrayFree(m_ssl_pools);
   ArrayFree(m_recent_sweeps);
   
   Print("CLiquiditySweepDetector: Deinitialized");
}
