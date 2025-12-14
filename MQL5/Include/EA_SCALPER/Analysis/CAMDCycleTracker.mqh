//+------------------------------------------------------------------+
//|                                             CAMDCycleTracker.mqh |
//|                           EA_SCALPER_XAUUSD - Singularity Edition |
//|                                                                  |
//|  AMD CYCLE: Accumulation → Manipulation → Distribution           |
//|                                                                  |
//|  This is the CORE institutional pattern. Understanding this      |
//|  separates profitable traders from the 90% who lose.             |
//|                                                                  |
//|  WHY IT WORKS:                                                   |
//|  - Institutions need LIQUIDITY to fill large orders              |
//|  - Retail traders place stops at obvious levels                  |
//|  - Institutions ENGINEER moves to trigger those stops            |
//|  - This creates PREDICTABLE patterns (if you know what to look)  |
//|                                                                  |
//|  THE CYCLE:                                                      |
//|  1. ACCUMULATION: Low volatility, range-bound, building position |
//|  2. MANIPULATION: Fake breakout to grab liquidity (stops)        |
//|  3. DISTRIBUTION: The REAL move in institutional direction       |
//|                                                                  |
//|  OUR EDGE: Enter in DISTRIBUTION, not Manipulation               |
//+------------------------------------------------------------------+
#property copyright "EA_SCALPER_XAUUSD - Singularity Edition"
#property strict

#include "../Core/Definitions.mqh"

//+------------------------------------------------------------------+
//| AMD Phase Enumeration                                             |
//+------------------------------------------------------------------+
enum ENUM_AMD_PHASE
{
   AMD_PHASE_UNKNOWN = 0,        // Cannot determine
   AMD_PHASE_ACCUMULATION,       // Range-bound, low volatility
   AMD_PHASE_MANIPULATION,       // Fake breakout, liquidity grab
   AMD_PHASE_DISTRIBUTION,       // Real move, institutional direction
   AMD_PHASE_EXHAUSTION          // Move completed, new cycle starting
};

//+------------------------------------------------------------------+
//| AMD Cycle Quality                                                 |
//+------------------------------------------------------------------+
enum ENUM_AMD_QUALITY
{
   AMD_QUALITY_INVALID = 0,
   AMD_QUALITY_LOW,              // Weak pattern
   AMD_QUALITY_MEDIUM,           // Acceptable
   AMD_QUALITY_HIGH,             // Strong pattern
   AMD_QUALITY_ELITE             // Textbook setup
};

//+------------------------------------------------------------------+
//| Accumulation Zone Structure                                       |
//+------------------------------------------------------------------+
struct SAccumulationZone
{
   double            high;                // Range high
   double            low;                 // Range low
   datetime          start_time;          // When accumulation started
   datetime          end_time;            // When it ended (manipulation started)
   int               bar_count;           // Duration in bars
   double            range_atr_ratio;     // Range size vs ATR
   bool              has_equal_highs;     // Liquidity pool above
   bool              has_equal_lows;      // Liquidity pool below
   int               touch_count_high;    // Times price touched high
   int               touch_count_low;     // Times price touched low
   bool              is_valid;
   
   void Reset()
   {
      high = 0;
      low = 0;
      start_time = 0;
      end_time = 0;
      bar_count = 0;
      range_atr_ratio = 0;
      has_equal_highs = false;
      has_equal_lows = false;
      touch_count_high = 0;
      touch_count_low = 0;
      is_valid = false;
   }
};

//+------------------------------------------------------------------+
//| Manipulation Event Structure                                      |
//+------------------------------------------------------------------+
struct SManipulationEvent
{
   ENUM_SIGNAL_TYPE  direction;           // Which way it faked (BUY=swept highs, SELL=swept lows)
   double            sweep_level;         // Level that was swept
   double            sweep_depth;         // How far beyond the level
   datetime          sweep_time;          // When sweep occurred
   int               sweep_bar;           // Bar index of sweep
   double            rejection_size;      // Size of rejection candle
   bool              has_rejection;       // Clear rejection candle
   bool              returned_to_range;   // Price came back inside
   bool              is_valid;
   
   void Reset()
   {
      direction = SIGNAL_NONE;
      sweep_level = 0;
      sweep_depth = 0;
      sweep_time = 0;
      sweep_bar = 0;
      rejection_size = 0;
      has_rejection = false;
      returned_to_range = false;
      is_valid = false;
   }
};

//+------------------------------------------------------------------+
//| Distribution Move Structure                                       |
//+------------------------------------------------------------------+
struct SDistributionMove
{
   ENUM_SIGNAL_TYPE  direction;           // Real direction (opposite of manipulation)
   double            displacement_size;   // Size of the move
   double            displacement_atr;    // Move in ATR units
   datetime          start_time;
   bool              has_choch;           // Change of Character confirmed
   bool              has_bos;             // Break of Structure confirmed
   bool              created_fvg;         // Fair Value Gap created
   bool              created_ob;          // Order Block created
   double            entry_zone_high;     // Optimal entry zone
   double            entry_zone_low;
   bool              is_valid;
   
   void Reset()
   {
      direction = SIGNAL_NONE;
      displacement_size = 0;
      displacement_atr = 0;
      start_time = 0;
      has_choch = false;
      has_bos = false;
      created_fvg = false;
      created_ob = false;
      entry_zone_high = 0;
      entry_zone_low = 0;
      is_valid = false;
   }
};

//+------------------------------------------------------------------+
//| Complete AMD Cycle Structure                                      |
//+------------------------------------------------------------------+
struct SAMDCycle
{
   SAccumulationZone accumulation;
   SManipulationEvent manipulation;
   SDistributionMove distribution;
   ENUM_AMD_PHASE    current_phase;
   ENUM_AMD_QUALITY  quality;
   int               quality_score;       // 0-100 score
   datetime          cycle_start;
   datetime          last_update;
   bool              is_active;
   
   void Reset()
   {
      accumulation.Reset();
      manipulation.Reset();
      distribution.Reset();
      current_phase = AMD_PHASE_UNKNOWN;
      quality = AMD_QUALITY_INVALID;
      quality_score = 0;
      cycle_start = 0;
      last_update = 0;
      is_active = false;
   }
};

//+------------------------------------------------------------------+
//| AMD Cycle Tracker Class                                           |
//+------------------------------------------------------------------+
class CAMDCycleTracker
{
private:
   // Configuration
   int               m_min_accumulation_bars;    // Minimum bars for valid accumulation
   int               m_max_accumulation_bars;    // Maximum before invalidation
   double            m_range_atr_max;            // Max range size in ATR for accumulation
   double            m_min_sweep_depth;          // Minimum sweep beyond level (points)
   double            m_min_displacement_atr;     // Minimum displacement in ATR
   double            m_equal_level_tolerance;    // Tolerance for equal highs/lows (points)
   
   // Current state
   SAMDCycle         m_current_cycle;
   SAMDCycle         m_history[];                // Recent cycles for analysis
   int               m_history_max;
   
   // Indicator handles
   int               m_atr_handle;
   
   // Internal methods
   bool              DetectAccumulation(MqlRates &rates[], double atr);
   bool              DetectManipulation(MqlRates &rates[], double atr);
   bool              DetectDistribution(MqlRates &rates[], double atr);
   bool              ValidateRejection(MqlRates &bar, double sweep_level, ENUM_SIGNAL_TYPE direction);
   int               CountEqualLevels(MqlRates &rates[], double level, bool is_high);
   int               CalculateQualityScore();
   ENUM_AMD_QUALITY  ScoreToQuality(int score);
   
public:
   CAMDCycleTracker();
   ~CAMDCycleTracker();
   
   // Initialization
   bool              Initialize(string symbol = NULL, ENUM_TIMEFRAMES tf = PERIOD_M15);
   
   // Main update method - call on each bar
   void              Update();
   
   // Phase detection
   ENUM_AMD_PHASE    GetCurrentPhase() { return m_current_cycle.current_phase; }
   bool              IsInAccumulation() { return m_current_cycle.current_phase == AMD_PHASE_ACCUMULATION; }
   bool              IsInManipulation() { return m_current_cycle.current_phase == AMD_PHASE_MANIPULATION; }
   bool              IsInDistribution() { return m_current_cycle.current_phase == AMD_PHASE_DISTRIBUTION; }
   
   // Signal generation
   bool              HasValidSetup();
   ENUM_SIGNAL_TYPE  GetDistributionDirection();
   double            GetEntryZoneHigh();
   double            GetEntryZoneLow();
   
   // Quality assessment
   ENUM_AMD_QUALITY  GetCycleQuality() { return m_current_cycle.quality; }
   int               GetQualityScore() { return m_current_cycle.quality_score; }
   
   // Current cycle access
   SAMDCycle         GetCurrentCycle() { return m_current_cycle; }
   SAccumulationZone GetAccumulation() { return m_current_cycle.accumulation; }
   SManipulationEvent GetManipulation() { return m_current_cycle.manipulation; }
   SDistributionMove GetDistribution() { return m_current_cycle.distribution; }
   
   // Quick access to manipulation levels for stop placement
   double            GetManipulationLow()  { return (m_current_cycle.manipulation.direction == SIGNAL_BUY) ? m_current_cycle.manipulation.sweep_level : m_current_cycle.accumulation.low; }
   double            GetManipulationHigh() { return (m_current_cycle.manipulation.direction == SIGNAL_SELL) ? m_current_cycle.manipulation.sweep_level : m_current_cycle.accumulation.high; }
   
   // Configuration
   void              SetMinAccumulationBars(int bars) { m_min_accumulation_bars = bars; }
   void              SetMaxAccumulationBars(int bars) { m_max_accumulation_bars = bars; }
   void              SetRangeATRMax(double ratio) { m_range_atr_max = ratio; }
   void              SetMinDisplacementATR(double ratio) { m_min_displacement_atr = ratio; }
   
   // Cleanup
   void              Deinitialize();
};

//+------------------------------------------------------------------+
//| Constructor                                                       |
//+------------------------------------------------------------------+
CAMDCycleTracker::CAMDCycleTracker()
{
   // Default configuration based on M15 XAUUSD
   m_min_accumulation_bars = 15;       // ~4 hours minimum
   m_max_accumulation_bars = 80;       // ~20 hours maximum
   m_range_atr_max = 1.5;              // Range must be < 1.5 ATR
   m_min_sweep_depth = 5.0;            // At least 5 points beyond level
   m_min_displacement_atr = 1.5;       // Displacement must be > 1.5 ATR
   m_equal_level_tolerance = 3.0;      // 3 points tolerance for equal levels
   
   m_atr_handle = INVALID_HANDLE;
   m_history_max = 10;
   ArrayResize(m_history, 0);
   
   m_current_cycle.Reset();
}

//+------------------------------------------------------------------+
//| Destructor                                                        |
//+------------------------------------------------------------------+
CAMDCycleTracker::~CAMDCycleTracker()
{
   Deinitialize();
}

//+------------------------------------------------------------------+
//| Initialize                                                        |
//+------------------------------------------------------------------+
bool CAMDCycleTracker::Initialize(string symbol = NULL, ENUM_TIMEFRAMES tf = PERIOD_M15)
{
   if(symbol == NULL) symbol = _Symbol;
   
   m_atr_handle = iATR(symbol, tf, 14);
   if(m_atr_handle == INVALID_HANDLE)
   {
      Print("CAMDCycleTracker: Failed to create ATR handle");
      return false;
   }
   
   m_current_cycle.Reset();
   
   Print("CAMDCycleTracker: Initialized successfully");
   return true;
}

//+------------------------------------------------------------------+
//| Update - Call on each new bar                                     |
//+------------------------------------------------------------------+
void CAMDCycleTracker::Update()
{
   // Get price data
   MqlRates rates[];
   int copied = CopyRates(_Symbol, PERIOD_M15, 0, m_max_accumulation_bars + 20, rates);
   if(copied < m_min_accumulation_bars + 10)
   {
      Print("CAMDCycleTracker: Insufficient price data");
      return;
   }
   ArraySetAsSeries(rates, true);
   
   // Get ATR
   double atr_buf[];
   if(CopyBuffer(m_atr_handle, 0, 0, 1, atr_buf) <= 0)
   {
      Print("CAMDCycleTracker: Failed to get ATR");
      return;
   }
   double atr = atr_buf[0];
   
   // State machine for AMD detection
   switch(m_current_cycle.current_phase)
   {
      case AMD_PHASE_UNKNOWN:
      case AMD_PHASE_EXHAUSTION:
         // Look for new accumulation
         if(DetectAccumulation(rates, atr))
         {
            m_current_cycle.current_phase = AMD_PHASE_ACCUMULATION;
            m_current_cycle.cycle_start = TimeCurrent();
            m_current_cycle.is_active = true;
         }
         break;
         
      case AMD_PHASE_ACCUMULATION:
         // Continue monitoring accumulation
         if(!DetectAccumulation(rates, atr))
         {
            // Accumulation ended - check if manipulation started
            if(DetectManipulation(rates, atr))
            {
               m_current_cycle.current_phase = AMD_PHASE_MANIPULATION;
               m_current_cycle.accumulation.end_time = TimeCurrent();
            }
            else
            {
               // No manipulation - cycle invalid, reset
               m_current_cycle.Reset();
            }
         }
         break;
         
      case AMD_PHASE_MANIPULATION:
         // Wait for distribution (the real move)
         if(DetectDistribution(rates, atr))
         {
            m_current_cycle.current_phase = AMD_PHASE_DISTRIBUTION;
            m_current_cycle.quality_score = CalculateQualityScore();
            m_current_cycle.quality = ScoreToQuality(m_current_cycle.quality_score);
         }
         else
         {
            // Check if manipulation failed (no rejection)
            if(!m_current_cycle.manipulation.has_rejection && 
               rates[0].time > m_current_cycle.manipulation.sweep_time + 5 * PeriodSeconds(PERIOD_M15))
            {
               // Manipulation didn't get rejection in 5 bars - might be real breakout
               m_current_cycle.Reset();
            }
         }
         break;
         
      case AMD_PHASE_DISTRIBUTION:
         {
            // Monitor distribution for exhaustion
            // Distribution is valid for entry until price moves significantly
            double dist_start = m_current_cycle.manipulation.sweep_level;
            double current = rates[0].close;
            double move_size = MathAbs(current - dist_start);
            
            // If move exceeds 3 ATR, consider exhaustion
            if(move_size > atr * 3)
            {
               // Save to history
               if(ArraySize(m_history) >= m_history_max)
                  ArrayRemove(m_history, 0, 1);
               int size = ArraySize(m_history);
               ArrayResize(m_history, size + 1);
               m_history[size] = m_current_cycle;
               
               m_current_cycle.current_phase = AMD_PHASE_EXHAUSTION;
            }
         }
         break;
   }
   
   m_current_cycle.last_update = TimeCurrent();
}

//+------------------------------------------------------------------+
//| Detect Accumulation Phase                                         |
//+------------------------------------------------------------------+
bool CAMDCycleTracker::DetectAccumulation(MqlRates &rates[], double atr)
{
   // Find potential accumulation range (last N bars)
   int lookback = m_max_accumulation_bars;
   if(ArraySize(rates) < lookback) return false;
   
   // Find range high/low over lookback period
   double range_high = rates[0].high;
   double range_low = rates[0].low;
   
   for(int i = 1; i < lookback; i++)
   {
      if(rates[i].high > range_high) range_high = rates[i].high;
      if(rates[i].low < range_low) range_low = rates[i].low;
   }
   
   double range_size = range_high - range_low;
   
   // Check if range is tight enough (consolidation)
   if(range_size > atr * m_range_atr_max)
      return false;
   
   // Count how many bars are within this range
   int bars_in_range = 0;
   for(int i = 0; i < lookback; i++)
   {
      if(rates[i].high <= range_high + m_equal_level_tolerance &&
         rates[i].low >= range_low - m_equal_level_tolerance)
      {
         bars_in_range++;
      }
   }
   
   // Need minimum bars in range for valid accumulation
   if(bars_in_range < m_min_accumulation_bars)
      return false;
   
   // Check for equal highs/lows (liquidity pools)
   int equal_highs = CountEqualLevels(rates, range_high, true);
   int equal_lows = CountEqualLevels(rates, range_low, false);
   
   // Update accumulation structure
   m_current_cycle.accumulation.high = range_high;
   m_current_cycle.accumulation.low = range_low;
   m_current_cycle.accumulation.bar_count = bars_in_range;
   m_current_cycle.accumulation.range_atr_ratio = range_size / atr;
   m_current_cycle.accumulation.has_equal_highs = (equal_highs >= 2);
   m_current_cycle.accumulation.has_equal_lows = (equal_lows >= 2);
   m_current_cycle.accumulation.touch_count_high = equal_highs;
   m_current_cycle.accumulation.touch_count_low = equal_lows;
   m_current_cycle.accumulation.is_valid = true;
   
   if(m_current_cycle.accumulation.start_time == 0)
      m_current_cycle.accumulation.start_time = rates[bars_in_range - 1].time;
   
   return true;
}

//+------------------------------------------------------------------+
//| Detect Manipulation Phase (Fake Breakout)                         |
//+------------------------------------------------------------------+
bool CAMDCycleTracker::DetectManipulation(MqlRates &rates[], double atr)
{
   if(!m_current_cycle.accumulation.is_valid)
      return false;
   
   double range_high = m_current_cycle.accumulation.high;
   double range_low = m_current_cycle.accumulation.low;
   
   // Look at recent bars for a sweep
   for(int i = 0; i < 10; i++)
   {
      // Check for high sweep (manipulation to downside coming)
      if(rates[i].high > range_high + m_min_sweep_depth)
      {
         // Price swept above - check for rejection
         if(ValidateRejection(rates[i], range_high, SIGNAL_SELL))
         {
            m_current_cycle.manipulation.direction = SIGNAL_BUY; // Swept highs
            m_current_cycle.manipulation.sweep_level = range_high;
            m_current_cycle.manipulation.sweep_depth = rates[i].high - range_high;
            m_current_cycle.manipulation.sweep_time = rates[i].time;
            m_current_cycle.manipulation.sweep_bar = i;
            m_current_cycle.manipulation.has_rejection = true;
            m_current_cycle.manipulation.returned_to_range = (rates[0].close < range_high);
            m_current_cycle.manipulation.is_valid = true;
            return true;
         }
      }
      
      // Check for low sweep (manipulation to upside coming)
      if(rates[i].low < range_low - m_min_sweep_depth)
      {
         // Price swept below - check for rejection
         if(ValidateRejection(rates[i], range_low, SIGNAL_BUY))
         {
            m_current_cycle.manipulation.direction = SIGNAL_SELL; // Swept lows
            m_current_cycle.manipulation.sweep_level = range_low;
            m_current_cycle.manipulation.sweep_depth = range_low - rates[i].low;
            m_current_cycle.manipulation.sweep_time = rates[i].time;
            m_current_cycle.manipulation.sweep_bar = i;
            m_current_cycle.manipulation.has_rejection = true;
            m_current_cycle.manipulation.returned_to_range = (rates[0].close > range_low);
            m_current_cycle.manipulation.is_valid = true;
            return true;
         }
      }
   }
   
   return false;
}

//+------------------------------------------------------------------+
//| Detect Distribution Phase (Real Move)                             |
//+------------------------------------------------------------------+
bool CAMDCycleTracker::DetectDistribution(MqlRates &rates[], double atr)
{
   if(!m_current_cycle.manipulation.is_valid)
      return false;
   
   // Distribution direction is OPPOSITE of manipulation direction
   ENUM_SIGNAL_TYPE dist_dir = (m_current_cycle.manipulation.direction == SIGNAL_BUY) ? 
                                SIGNAL_SELL : SIGNAL_BUY;
   
   double range_high = m_current_cycle.accumulation.high;
   double range_low = m_current_cycle.accumulation.low;
   
   // Look for displacement in distribution direction
   double displacement = 0;
   int    window = 10; // examine last 10 bars after manipulation for displacement
   
   if(dist_dir == SIGNAL_BUY)
   {
      // Looking for bullish displacement after low sweep
      // Find lowest low after manipulation
      double lowest = rates[0].low;
      int lowest_bar = 0;
      for(int i = 0; i < window; i++)
      {
         if(rates[i].low < lowest)
         {
            lowest = rates[i].low;
            lowest_bar = i;
         }
      }
      
      // Check if price moved up significantly from that low
      displacement = rates[0].close - lowest;
      
      if(displacement > atr * m_min_displacement_atr)
      {
         // Valid bullish distribution
         m_current_cycle.distribution.direction = SIGNAL_BUY;
         m_current_cycle.distribution.displacement_size = displacement;
         m_current_cycle.distribution.displacement_atr = displacement / atr;
         m_current_cycle.distribution.start_time = rates[lowest_bar].time;
         
         // CHoCH: higher high relative to accumulation high AND higher low vs sweep level
         m_current_cycle.distribution.has_choch = (rates[0].high > range_high && rates[0].low > m_current_cycle.manipulation.sweep_level);
         
         // BOS (Break of Structure - close above range high)
         m_current_cycle.distribution.has_bos = (rates[0].close > range_high);
         
         // Entry zone is the OB/FVG created by displacement
         m_current_cycle.distribution.entry_zone_low = lowest;
         m_current_cycle.distribution.entry_zone_high = lowest + (rates[0].close - lowest) * 0.5;
         
         m_current_cycle.distribution.is_valid = true;
         return true;
      }
   }
   else // SIGNAL_SELL
   {
      // Looking for bearish displacement after high sweep
      double highest = rates[0].high;
      int highest_bar = 0;
      for(int i = 0; i < window; i++)
      {
         if(rates[i].high > highest)
         {
            highest = rates[i].high;
            highest_bar = i;
         }
      }
      
      displacement = highest - rates[0].close;
      
      if(displacement > atr * m_min_displacement_atr)
      {
         m_current_cycle.distribution.direction = SIGNAL_SELL;
         m_current_cycle.distribution.displacement_size = displacement;
         m_current_cycle.distribution.displacement_atr = displacement / atr;
         m_current_cycle.distribution.start_time = rates[highest_bar].time;
         
         m_current_cycle.distribution.has_choch = (rates[0].low < range_low && rates[0].high < m_current_cycle.manipulation.sweep_level);
         m_current_cycle.distribution.has_bos = (rates[0].close < range_low);
         
         m_current_cycle.distribution.entry_zone_high = highest;
         m_current_cycle.distribution.entry_zone_low = highest - (highest - rates[0].close) * 0.5;
         
         m_current_cycle.distribution.is_valid = true;
         return true;
      }
   }
   
   return false;
}

//+------------------------------------------------------------------+
//| Validate Rejection Candle                                         |
//+------------------------------------------------------------------+
bool CAMDCycleTracker::ValidateRejection(MqlRates &bar, double sweep_level, ENUM_SIGNAL_TYPE direction)
{
   double body = MathAbs(bar.close - bar.open);
   double upper_wick = bar.high - MathMax(bar.open, bar.close);
   double lower_wick = MathMin(bar.open, bar.close) - bar.low;
   double total_range = bar.high - bar.low;
   
   if(total_range < 1) return false;
   
   if(direction == SIGNAL_SELL) // Swept highs, expecting bearish rejection
   {
      // Upper wick should be significant (> body)
      // Close should be below sweep level
      return (upper_wick > body * 1.5) && (bar.close < sweep_level);
   }
   else // SIGNAL_BUY - Swept lows, expecting bullish rejection
   {
      return (lower_wick > body * 1.5) && (bar.close > sweep_level);
   }
}

//+------------------------------------------------------------------+
//| Count Equal Levels (for liquidity detection)                      |
//+------------------------------------------------------------------+
int CAMDCycleTracker::CountEqualLevels(MqlRates &rates[], double level, bool is_high)
{
   int count = 0;
   int size = ArraySize(rates);
   
   for(int i = 0; i < MathMin(size, m_max_accumulation_bars); i++)
   {
      double price = is_high ? rates[i].high : rates[i].low;
      if(MathAbs(price - level) <= m_equal_level_tolerance)
         count++;
   }
   
   return count;
}

//+------------------------------------------------------------------+
//| Calculate Quality Score (0-100)                                   |
//+------------------------------------------------------------------+
int CAMDCycleTracker::CalculateQualityScore()
{
   int score = 0;
   
   // Accumulation quality (max 30 points)
   if(m_current_cycle.accumulation.is_valid)
   {
      // Tight range = better (max 10)
      if(m_current_cycle.accumulation.range_atr_ratio < 1.0) score += 10;
      else if(m_current_cycle.accumulation.range_atr_ratio < 1.3) score += 7;
      else score += 4;
      
      // Duration (max 10) - not too short, not too long
      int bars = m_current_cycle.accumulation.bar_count;
      if(bars >= 20 && bars <= 50) score += 10;
      else if(bars >= 15 && bars <= 60) score += 7;
      else score += 4;
      
      // Liquidity pools (max 10)
      if(m_current_cycle.accumulation.has_equal_highs) score += 5;
      if(m_current_cycle.accumulation.has_equal_lows) score += 5;
   }
   
   // Manipulation quality (max 30 points)
   if(m_current_cycle.manipulation.is_valid)
   {
      // Sweep depth (max 10)
      if(m_current_cycle.manipulation.sweep_depth > 15) score += 10;
      else if(m_current_cycle.manipulation.sweep_depth > 10) score += 7;
      else score += 4;
      
      // Clear rejection (max 10)
      if(m_current_cycle.manipulation.has_rejection) score += 10;
      
      // Returned to range (max 10)
      if(m_current_cycle.manipulation.returned_to_range) score += 10;
   }
   
   // Distribution quality (max 40 points)
   if(m_current_cycle.distribution.is_valid)
   {
      // Displacement size (max 15)
      if(m_current_cycle.distribution.displacement_atr > 2.5) score += 15;
      else if(m_current_cycle.distribution.displacement_atr > 2.0) score += 12;
      else if(m_current_cycle.distribution.displacement_atr > 1.5) score += 8;
      else score += 5;
      
      // CHoCH confirmed (max 15)
      if(m_current_cycle.distribution.has_choch) score += 15;
      
      // BOS confirmed (max 10)
      if(m_current_cycle.distribution.has_bos) score += 10;
   }
   
   return MathMin(100, score);
}

//+------------------------------------------------------------------+
//| Convert Score to Quality Enum                                     |
//+------------------------------------------------------------------+
ENUM_AMD_QUALITY CAMDCycleTracker::ScoreToQuality(int score)
{
   if(score >= 85) return AMD_QUALITY_ELITE;
   if(score >= 70) return AMD_QUALITY_HIGH;
   if(score >= 55) return AMD_QUALITY_MEDIUM;
   if(score >= 40) return AMD_QUALITY_LOW;
   return AMD_QUALITY_INVALID;
}

//+------------------------------------------------------------------+
//| Check if we have a valid setup for entry                          |
//+------------------------------------------------------------------+
bool CAMDCycleTracker::HasValidSetup()
{
   // Must be in distribution phase
   if(m_current_cycle.current_phase != AMD_PHASE_DISTRIBUTION)
      return false;
   
   // Must have minimum quality
   if(m_current_cycle.quality < AMD_QUALITY_MEDIUM)
      return false;
   
   // Distribution must be valid
   if(!m_current_cycle.distribution.is_valid)
      return false;
   
   // CHoCH must be confirmed for high probability
   if(!m_current_cycle.distribution.has_choch)
      return false;
   
   return true;
}

//+------------------------------------------------------------------+
//| Get Distribution Direction for Entry                              |
//+------------------------------------------------------------------+
ENUM_SIGNAL_TYPE CAMDCycleTracker::GetDistributionDirection()
{
   if(!HasValidSetup())
      return SIGNAL_NONE;
   
   return m_current_cycle.distribution.direction;
}

//+------------------------------------------------------------------+
//| Get Entry Zone High                                               |
//+------------------------------------------------------------------+
double CAMDCycleTracker::GetEntryZoneHigh()
{
   return m_current_cycle.distribution.entry_zone_high;
}

//+------------------------------------------------------------------+
//| Get Entry Zone Low                                                |
//+------------------------------------------------------------------+
double CAMDCycleTracker::GetEntryZoneLow()
{
   return m_current_cycle.distribution.entry_zone_low;
}

//+------------------------------------------------------------------+
//| Cleanup                                                           |
//+------------------------------------------------------------------+
void CAMDCycleTracker::Deinitialize()
{
   if(m_atr_handle != INVALID_HANDLE)
   {
      IndicatorRelease(m_atr_handle);
      m_atr_handle = INVALID_HANDLE;
   }
   
   ArrayFree(m_history);
   m_current_cycle.Reset();
   
   Print("CAMDCycleTracker: Deinitialized");
}
