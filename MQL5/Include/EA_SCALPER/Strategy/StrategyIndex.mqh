//+------------------------------------------------------------------+
//|                                              StrategyIndex.mqh |
//|                                                           Franco |
//|                   EA_SCALPER_XAUUSD v4.0 - Strategy Layer Index  |
//+------------------------------------------------------------------+
#property copyright "Franco"
#property link      "EA_SCALPER_XAUUSD"
#property version   "1.00"
#property strict

//+------------------------------------------------------------------+
//| Strategy Layer Components                                         |
//|                                                                   |
//| Purpose: Select and execute the right strategy for context        |
//|                                                                   |
//| Components:                                                       |
//| 1. CStrategySelector - Choose strategy based on market context    |
//| 2. CNewsTrader - Trade news events (3 modes)                      |
//|                                                                   |
//| Future additions:                                                 |
//| - CTrendFollower - Momentum/breakout strategy (Hurst > 0.55)      |
//| - CMeanReversion - Fade extremes strategy (Hurst < 0.45)          |
//| - CSMCScalper - Default OB/FVG/Sweep strategy                     |
//+------------------------------------------------------------------+

#include "CStrategySelector.mqh"
#include "CNewsTrader.mqh"

//+------------------------------------------------------------------+
//| Strategy Layer Usage Example                                      |
//+------------------------------------------------------------------+
/*
// Initialize components
CSafetyManager g_safety;
CNewsWindowDetector g_news_detector;
CHolidayDetector g_holiday_detector;
CStrategySelector g_selector;
CNewsTrader g_news_trader;

// OnInit
g_safety.Init(_Symbol, 4.0, 8.0, 5, 120, 100);
g_news_detector.Init(_Symbol);
g_holiday_detector.Init();
g_selector.Init(_Symbol);
g_news_trader.Init(_Symbol, 12345);

// Connect components
g_selector.SetSafetyManager(&g_safety);
g_selector.SetNewsDetector(&g_news_detector);
g_selector.SetHolidayDetector(&g_holiday_detector);

// OnTick - Strategy selection flow
void OnTick()
{
   // 1. Update regime (from Python or local calculation)
   g_selector.SetRegime(current_hurst, current_entropy);
   
   // 2. Select strategy
   SStrategySelection selection = g_selector.SelectStrategy();
   
   if(!selection.can_trade)
   {
      Print("Trading blocked: ", selection.reason);
      return;
   }
   
   // 3. Execute based on strategy
   switch(selection.strategy)
   {
      case STRATEGY_NEWS_TRADER:
         {
            SNewsWindowResult news = g_news_detector.Check();
            SNewsTradeSetup setup = g_news_trader.AnalyzeNewsSetup(news);
            
            if(setup.is_valid)
            {
               if(setup.mode == NEWS_MODE_PREPOSITION)
                  g_news_trader.ExecutePreposition(setup);
               else if(setup.mode == NEWS_MODE_STRADDLE)
                  g_news_trader.ExecuteStraddle(setup);
            }
         }
         break;
         
      case STRATEGY_TREND_FOLLOW:
         // Execute trend following logic
         // (CTrendFollower - to be implemented)
         break;
         
      case STRATEGY_MEAN_REVERT:
         // Execute mean reversion logic
         // (CMeanReversion - to be implemented)
         break;
         
      case STRATEGY_SMC_SCALPER:
         // Execute default SMC scalping
         // This is the existing logic
         break;
         
      case STRATEGY_SAFE_MODE:
         // Ultra conservative trading
         // Only tier A signals, minimal risk
         break;
   }
   
   // 4. Apply size multiplier
   double adjusted_lot = base_lot * selection.size_multiplier;
   
   // 5. Apply score adjustment
   int final_score = tech_score + selection.score_adjustment;
}

// OnTimer - Manage open trades
void OnTimer()
{
   g_news_trader.ManageOpenTrades();
   g_news_trader.ManageStraddle();
}
*/

//+------------------------------------------------------------------+
