//+------------------------------------------------------------------+
//|                                            CBacktestRealism.mqh |
//|                                                           Franco |
//|                   EA_SCALPER_XAUUSD v4.0 - Backtest Realism      |
//+------------------------------------------------------------------+
#property copyright "Franco"
#property link      "EA_SCALPER_XAUUSD"
#property version   "1.00"
#property strict

//+------------------------------------------------------------------+
//| Design Philosophy:                                                |
//| Simulate conditions WORSE than live trading to ensure robustness  |
//|                                                                   |
//| "If it works in pessimistic backtest, it will work live"          |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| Simulation Modes                                                  |
//+------------------------------------------------------------------+
enum ENUM_SIMULATION_MODE
{
   SIM_OPTIMISTIC = 0,    // No extra costs (unrealistic!)
   SIM_NORMAL = 1,        // Normal trading conditions
   SIM_PESSIMISTIC = 2,   // Harsh conditions (recommended)
   SIM_EXTREME = 3        // Extreme stress test
};

//+------------------------------------------------------------------+
//| Market Condition Type                                             |
//+------------------------------------------------------------------+
enum ENUM_MARKET_CONDITION
{
   CONDITION_NORMAL = 0,        // Normal market
   CONDITION_NEWS = 1,          // During news
   CONDITION_LOW_LIQUIDITY = 2, // Asian session / holidays
   CONDITION_VOLATILE = 3,      // High volatility spike
   CONDITION_ILLIQUID = 4       // Flash crash / extreme
};

//+------------------------------------------------------------------+
//| Slippage Configuration                                            |
//+------------------------------------------------------------------+
struct SSlippageConfig
{
   double            base_slippage;      // Base slippage in points
   double            news_multiplier;    // Multiplier during news
   double            volatility_mult;    // Multiplier during high vol
   double            low_liq_mult;       // Multiplier during low liquidity
   double            random_factor;      // Random variance (0-1)
   bool              adverse_only;       // Only adverse slippage
   
   void SetDefaults(ENUM_SIMULATION_MODE mode)
   {
      switch(mode)
      {
         case SIM_OPTIMISTIC:
            base_slippage = 0;
            news_multiplier = 1.0;
            volatility_mult = 1.0;
            low_liq_mult = 1.0;
            random_factor = 0;
            adverse_only = false;
            break;
            
         case SIM_NORMAL:
            base_slippage = 2;
            news_multiplier = 5.0;
            volatility_mult = 2.0;
            low_liq_mult = 1.5;
            random_factor = 0.3;
            adverse_only = false;
            break;
            
         case SIM_PESSIMISTIC:
            base_slippage = 5;
            news_multiplier = 10.0;
            volatility_mult = 3.0;
            low_liq_mult = 2.0;
            random_factor = 0.5;
            adverse_only = true;
            break;
            
         case SIM_EXTREME:
            base_slippage = 10;
            news_multiplier = 20.0;
            volatility_mult = 5.0;
            low_liq_mult = 3.0;
            random_factor = 0.7;
            adverse_only = true;
            break;
      }
   }
};

//+------------------------------------------------------------------+
//| Spread Configuration                                              |
//+------------------------------------------------------------------+
struct SSpreadConfig
{
   double            base_spread;        // Base spread in points
   double            news_multiplier;    // Multiplier during news
   double            volatility_mult;    // Multiplier during high vol
   double            low_liq_mult;       // Multiplier during low liquidity
   double            asian_mult;         // Multiplier during Asian session
   double            random_factor;      // Random variance (0-1)
   
   void SetDefaults(ENUM_SIMULATION_MODE mode)
   {
      switch(mode)
      {
         case SIM_OPTIMISTIC:
            base_spread = 15;   // 1.5 pips
            news_multiplier = 1.0;
            volatility_mult = 1.0;
            low_liq_mult = 1.0;
            asian_mult = 1.0;
            random_factor = 0;
            break;
            
         case SIM_NORMAL:
            base_spread = 20;   // 2.0 pips
            news_multiplier = 3.0;
            volatility_mult = 1.5;
            low_liq_mult = 1.5;
            asian_mult = 2.0;
            random_factor = 0.2;
            break;
            
         case SIM_PESSIMISTIC:
            base_spread = 25;   // 2.5 pips
            news_multiplier = 5.0;
            volatility_mult = 2.0;
            low_liq_mult = 2.5;
            asian_mult = 3.0;
            random_factor = 0.4;
            break;
            
         case SIM_EXTREME:
            base_spread = 40;   // 4.0 pips
            news_multiplier = 10.0;
            volatility_mult = 4.0;
            low_liq_mult = 4.0;
            asian_mult = 5.0;
            random_factor = 0.6;
            break;
      }
   }
};

//+------------------------------------------------------------------+
//| Latency Configuration                                             |
//+------------------------------------------------------------------+
struct SLatencyConfig
{
   int               base_latency_ms;    // Base latency in ms
   int               news_latency_ms;    // Extra latency during news
   int               peak_latency_ms;    // Maximum latency spike
   double            spike_probability;  // Probability of latency spike
   double            reject_probability; // Probability of order rejection
   
   void SetDefaults(ENUM_SIMULATION_MODE mode)
   {
      switch(mode)
      {
         case SIM_OPTIMISTIC:
            base_latency_ms = 0;
            news_latency_ms = 0;
            peak_latency_ms = 0;
            spike_probability = 0;
            reject_probability = 0;
            break;
            
         case SIM_NORMAL:
            base_latency_ms = 50;
            news_latency_ms = 200;
            peak_latency_ms = 500;
            spike_probability = 0.05;
            reject_probability = 0.02;
            break;
            
         case SIM_PESSIMISTIC:
            base_latency_ms = 100;
            news_latency_ms = 500;
            peak_latency_ms = 1500;
            spike_probability = 0.15;
            reject_probability = 0.10;
            break;
            
         case SIM_EXTREME:
            base_latency_ms = 200;
            news_latency_ms = 1000;
            peak_latency_ms = 3000;
            spike_probability = 0.30;
            reject_probability = 0.25;
            break;
      }
   }
};

//+------------------------------------------------------------------+
//| Simulation Result                                                 |
//+------------------------------------------------------------------+
struct SSimulationResult
{
   double            adjusted_entry;     // Entry after slippage
   double            adjusted_spread;    // Spread at entry time
   int               latency_ms;         // Execution latency
   bool              order_rejected;     // Was order rejected?
   string            reject_reason;      // Rejection reason
   double            slippage_points;    // Slippage applied
   double            total_cost_points;  // Total extra cost
   
   void Reset()
   {
      adjusted_entry = 0;
      adjusted_spread = 0;
      latency_ms = 0;
      order_rejected = false;
      reject_reason = "";
      slippage_points = 0;
      total_cost_points = 0;
   }
};

//+------------------------------------------------------------------+
//| Class: CBacktestRealism                                           |
//| Purpose: Add realistic trading costs to backtest                  |
//+------------------------------------------------------------------+
class CBacktestRealism
{
private:
   //--- Configuration
   ENUM_SIMULATION_MODE m_mode;
   SSlippageConfig   m_slippage;
   SSpreadConfig     m_spread;
   SLatencyConfig    m_latency;
   
   //--- State
   bool              m_enabled;
   string            m_symbol;
   
   //--- Statistics
   int               m_total_trades;
   int               m_rejected_trades;
   double            m_total_slippage;
   double            m_total_spread_cost;
   double            m_avg_latency;
   
   //--- Random seed
   int               m_seed;
   
public:
                     CBacktestRealism();
                    ~CBacktestRealism();
   
   //--- Initialization
   bool              Init(string symbol = "", ENUM_SIMULATION_MODE mode = SIM_PESSIMISTIC);
   void              SetMode(ENUM_SIMULATION_MODE mode);
   void              Enable(bool enable) { m_enabled = enable; }
   bool              IsEnabled() { return m_enabled; }
   
   //--- Custom Configuration
   void              SetSlippageConfig(const SSlippageConfig &config) { m_slippage = config; }
   void              SetSpreadConfig(const SSpreadConfig &config) { m_spread = config; }
   void              SetLatencyConfig(const SLatencyConfig &config) { m_latency = config; }
   
   //--- Main Simulation
   SSimulationResult SimulateTrade(double requested_price, bool is_buy, 
                                   ENUM_MARKET_CONDITION condition = CONDITION_NORMAL);
   
   //--- Individual Components
   double            SimulateSlippage(bool is_buy, ENUM_MARKET_CONDITION condition);
   double            SimulateSpread(ENUM_MARKET_CONDITION condition);
   int               SimulateLatency(ENUM_MARKET_CONDITION condition);
   bool              SimulateRejection(ENUM_MARKET_CONDITION condition);
   
   //--- Market Condition Detection
   ENUM_MARKET_CONDITION DetectCondition(bool in_news_window, bool is_asian, 
                                          double volatility_percentile);
   
   //--- Statistics
   void              ResetStatistics();
   double            GetAverageSlippage() { return m_total_trades > 0 ? m_total_slippage / m_total_trades : 0; }
   double            GetRejectionRate() { return m_total_trades > 0 ? (double)m_rejected_trades / m_total_trades * 100 : 0; }
   double            GetTotalCost() { return m_total_slippage + m_total_spread_cost; }
   void              PrintStatistics();
   
private:
   double            GetRandomFactor();
   double            GetConditionMultiplier(ENUM_MARKET_CONDITION condition, 
                                            double news_mult, double vol_mult, double liq_mult);
};

//+------------------------------------------------------------------+
//| Constructor                                                       |
//+------------------------------------------------------------------+
CBacktestRealism::CBacktestRealism()
{
   m_mode = SIM_PESSIMISTIC;
   m_enabled = true;
   m_symbol = "";
   
   m_total_trades = 0;
   m_rejected_trades = 0;
   m_total_slippage = 0;
   m_total_spread_cost = 0;
   m_avg_latency = 0;
   
   m_seed = GetTickCount();
   MathSrand(m_seed);
   
   m_slippage.SetDefaults(m_mode);
   m_spread.SetDefaults(m_mode);
   m_latency.SetDefaults(m_mode);
}

//+------------------------------------------------------------------+
//| Destructor                                                        |
//+------------------------------------------------------------------+
CBacktestRealism::~CBacktestRealism()
{
}

//+------------------------------------------------------------------+
//| Initialize                                                        |
//+------------------------------------------------------------------+
bool CBacktestRealism::Init(string symbol = "", ENUM_SIMULATION_MODE mode = SIM_PESSIMISTIC)
{
   m_symbol = symbol == "" ? _Symbol : symbol;
   SetMode(mode);
   ResetStatistics();
   
   Print("CBacktestRealism: Initialized for ", m_symbol);
   Print("  Mode: ", EnumToString(m_mode));
   Print("  Base Slippage: ", m_slippage.base_slippage, " points");
   Print("  Base Spread: ", m_spread.base_spread, " points");
   Print("  Base Latency: ", m_latency.base_latency_ms, " ms");
   Print("  Reject Prob: ", m_latency.reject_probability * 100, "%");
   
   return true;
}

//+------------------------------------------------------------------+
//| Set simulation mode                                               |
//+------------------------------------------------------------------+
void CBacktestRealism::SetMode(ENUM_SIMULATION_MODE mode)
{
   m_mode = mode;
   m_slippage.SetDefaults(mode);
   m_spread.SetDefaults(mode);
   m_latency.SetDefaults(mode);
}

//+------------------------------------------------------------------+
//| Main simulation function                                          |
//+------------------------------------------------------------------+
SSimulationResult CBacktestRealism::SimulateTrade(double requested_price, bool is_buy,
                                                   ENUM_MARKET_CONDITION condition)
{
   SSimulationResult result;
   result.Reset();
   
   if(!m_enabled)
   {
      result.adjusted_entry = requested_price;
      result.adjusted_spread = SymbolInfoInteger(m_symbol, SYMBOL_SPREAD) * _Point;
      return result;
   }
   
   m_total_trades++;
   
   // 1. Check for rejection
   if(SimulateRejection(condition))
   {
      result.order_rejected = true;
      result.reject_reason = "Requote / Broker rejection";
      m_rejected_trades++;
      return result;
   }
   
   // 2. Simulate latency
   result.latency_ms = SimulateLatency(condition);
   
   // 3. Simulate spread
   result.adjusted_spread = SimulateSpread(condition);
   
   // 4. Simulate slippage
   result.slippage_points = SimulateSlippage(is_buy, condition);
   
   // 5. Calculate adjusted entry
   if(is_buy)
   {
      // Buy: price moves against us (up) + spread
      result.adjusted_entry = requested_price + result.slippage_points * _Point;
   }
   else
   {
      // Sell: price moves against us (down)
      result.adjusted_entry = requested_price - result.slippage_points * _Point;
   }
   
   // 6. Calculate total cost
   result.total_cost_points = MathAbs(result.slippage_points) + result.adjusted_spread / _Point;
   
   // 7. Update statistics
   m_total_slippage += MathAbs(result.slippage_points);
   m_total_spread_cost += result.adjusted_spread / _Point;
   
   return result;
}

//+------------------------------------------------------------------+
//| Simulate slippage                                                 |
//+------------------------------------------------------------------+
double CBacktestRealism::SimulateSlippage(bool is_buy, ENUM_MARKET_CONDITION condition)
{
   double multiplier = GetConditionMultiplier(condition, 
                                               m_slippage.news_multiplier,
                                               m_slippage.volatility_mult,
                                               m_slippage.low_liq_mult);
   
   double base = m_slippage.base_slippage * multiplier;
   
   // Add randomness
   double random_var = base * m_slippage.random_factor * GetRandomFactor();
   double slippage = base + random_var;
   
   // Adverse only mode: always slip against the trade
   if(m_slippage.adverse_only)
   {
      return slippage;  // Always positive = adverse
   }
   else
   {
      // Can be positive or negative
      if(GetRandomFactor() > 0.5)
         return slippage;
      else
         return -slippage * 0.3;  // Favorable slippage is rarer/smaller
   }
}

//+------------------------------------------------------------------+
//| Simulate spread                                                   |
//+------------------------------------------------------------------+
double CBacktestRealism::SimulateSpread(ENUM_MARKET_CONDITION condition)
{
   double multiplier = 1.0;
   
   switch(condition)
   {
      case CONDITION_NEWS:
         multiplier = m_spread.news_multiplier;
         break;
      case CONDITION_VOLATILE:
         multiplier = m_spread.volatility_mult;
         break;
      case CONDITION_LOW_LIQUIDITY:
         multiplier = m_spread.low_liq_mult;
         break;
      case CONDITION_ILLIQUID:
         multiplier = m_spread.low_liq_mult * 2;
         break;
      default:
         multiplier = 1.0;
   }
   
   double base = m_spread.base_spread * multiplier;
   
   // Add randomness (spread can only increase)
   double random_var = base * m_spread.random_factor * GetRandomFactor();
   
   return (base + random_var) * _Point;
}

//+------------------------------------------------------------------+
//| Simulate latency                                                  |
//+------------------------------------------------------------------+
int CBacktestRealism::SimulateLatency(ENUM_MARKET_CONDITION condition)
{
   int base = m_latency.base_latency_ms;
   
   // Add news latency
   if(condition == CONDITION_NEWS)
      base += m_latency.news_latency_ms;
   
   // Random spike
   if(GetRandomFactor() < m_latency.spike_probability)
   {
      base = m_latency.peak_latency_ms;
   }
   
   // Add some randomness
   int variance = (int)(base * 0.3 * GetRandomFactor());
   
   return base + variance;
}

//+------------------------------------------------------------------+
//| Simulate order rejection                                          |
//+------------------------------------------------------------------+
bool CBacktestRealism::SimulateRejection(ENUM_MARKET_CONDITION condition)
{
   double prob = m_latency.reject_probability;
   
   // Higher rejection during news and illiquid conditions
   switch(condition)
   {
      case CONDITION_NEWS:
         prob *= 3.0;
         break;
      case CONDITION_ILLIQUID:
         prob *= 5.0;
         break;
      case CONDITION_VOLATILE:
         prob *= 2.0;
         break;
      default:
         break;
   }
   
   return GetRandomFactor() < prob;
}

//+------------------------------------------------------------------+
//| Detect market condition                                           |
//+------------------------------------------------------------------+
ENUM_MARKET_CONDITION CBacktestRealism::DetectCondition(bool in_news_window, 
                                                         bool is_asian,
                                                         double volatility_percentile)
{
   if(in_news_window)
      return CONDITION_NEWS;
   
   if(volatility_percentile > 95)
      return CONDITION_ILLIQUID;
   
   if(volatility_percentile > 80)
      return CONDITION_VOLATILE;
   
   if(is_asian)
      return CONDITION_LOW_LIQUIDITY;
   
   return CONDITION_NORMAL;
}

//+------------------------------------------------------------------+
//| Get random factor (0-1)                                           |
//+------------------------------------------------------------------+
double CBacktestRealism::GetRandomFactor()
{
   return MathRand() / 32767.0;
}

//+------------------------------------------------------------------+
//| Get condition multiplier                                          |
//+------------------------------------------------------------------+
double CBacktestRealism::GetConditionMultiplier(ENUM_MARKET_CONDITION condition,
                                                 double news_mult,
                                                 double vol_mult,
                                                 double liq_mult)
{
   switch(condition)
   {
      case CONDITION_NEWS:
         return news_mult;
      case CONDITION_VOLATILE:
         return vol_mult;
      case CONDITION_LOW_LIQUIDITY:
         return liq_mult;
      case CONDITION_ILLIQUID:
         return liq_mult * 2;
      default:
         return 1.0;
   }
}

//+------------------------------------------------------------------+
//| Reset statistics                                                  |
//+------------------------------------------------------------------+
void CBacktestRealism::ResetStatistics()
{
   m_total_trades = 0;
   m_rejected_trades = 0;
   m_total_slippage = 0;
   m_total_spread_cost = 0;
   m_avg_latency = 0;
}

//+------------------------------------------------------------------+
//| Print statistics                                                  |
//+------------------------------------------------------------------+
void CBacktestRealism::PrintStatistics()
{
   Print("=== Backtest Realism Statistics ===");
   Print("Mode: ", EnumToString(m_mode));
   Print("Total Trades: ", m_total_trades);
   Print("Rejected: ", m_rejected_trades, " (", GetRejectionRate(), "%)");
   Print("Avg Slippage: ", GetAverageSlippage(), " points");
   Print("Total Slippage Cost: ", m_total_slippage, " points");
   Print("Total Spread Cost: ", m_total_spread_cost, " points");
   Print("Total Extra Cost: ", GetTotalCost(), " points");
   Print("===================================");
}

//+------------------------------------------------------------------+
