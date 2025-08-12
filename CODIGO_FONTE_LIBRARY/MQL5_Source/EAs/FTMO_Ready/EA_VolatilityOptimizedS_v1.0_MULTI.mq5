//+------------------------------------------------------------------+
//|                         VolatilityOptimizedSMA_EA_v2.mq5 |
//|                        Copyright 2025, Manus AI Agent        |
//|                 Enhanced with Dynamic SL/TP, Trail, BE       |
//+------------------------------------------------------------------+
#property copyright "Copyright 2025, Manus AI Agent"
#property link      ""
#property version   "2.00"
#property strict

#include <Trade\Trade.mqh> // Include the Trade library

//--- Input parameters: Original
input int    DefaultPeriod         = 14;    // Default SMA period if volatility is normal
input double HighVolatilityThreshold = 1.5;   // High volatility threshold (e.g., based on avg range)
input double LowVolatilityThreshold  = 0.5;   // Low volatility threshold (e.g., based on avg range)
input double LotSize               = 0.01;  // Trading lot size
input int    MagicNumber           = 12345; // Magic number for orders

//--- Input parameters: Risk Management Enhancements
input int    AtrPeriod             = 14;    // ATR Period for dynamic SL
input double AtrMultiplierSL       = 1.5;   // ATR Multiplier for Stop Loss (e.g., 1.5 * ATR)
input double RiskRewardRatioTP     = 2.0;   // Risk:Reward Ratio for Take Profit (e.g., 2.0 means TP = 2 * SL distance)
input int    TrailingStopPoints    = 15;    // Trailing Stop distance in points (0 = disabled)
input int    TrailingStartPoints   = 30;    // Profit in points to activate Trailing Stop
input int    BreakEvenPoints       = 20;    // Profit in points to move SL to Break-Even (0 = disabled)
input int    BreakEvenPipsLock     = 2;     // Pips to lock in profit when moving to BE

//--- Global variables
CTrade trade;                     // Trade object
int    smaHandle = INVALID_HANDLE; // Handle for the SMA indicator
int    atrHandle = INVALID_HANDLE; // Handle for the ATR indicator
int    optimizedPeriod = 0;        // Variable to store the optimized SMA period
double point;                      // Symbol point size

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- Initialize trade object
   trade.SetExpertMagicNumber(MagicNumber);
   trade.SetMarginMode();
   trade.SetTypeFillingBySymbol(Symbol());

//--- Initialize optimizedPeriod with the default value
   optimizedPeriod = DefaultPeriod;
   point = SymbolInfoDouble(Symbol(), SYMBOL_POINT);

//--- Print initialization message
   Print("Volatility Optimized SMA EA v2 Initialized.");
   Print("--- Strategy Params ---");
   Print("Default SMA Period: ", DefaultPeriod);
   Print("High Volatility Threshold: ", HighVolatilityThreshold);
   Print("Low Volatility Threshold: ", LowVolatilityThreshold);
   Print("Lot Size: ", LotSize);
   Print("Magic Number: ", MagicNumber);
   Print("--- Risk Management Params ---");
   Print("ATR Period: ", AtrPeriod);
   Print("ATR Multiplier SL: ", AtrMultiplierSL);
   Print("Risk Reward Ratio TP: ", RiskRewardRatioTP);
   Print("Trailing Stop (Points): ", TrailingStopPoints, TrailingStopPoints > 0 ? " (Enabled)" : " (Disabled)");
   Print("Trailing Start (Points): ", TrailingStartPoints);
   Print("Break Even Trigger (Points): ", BreakEvenPoints, BreakEvenPoints > 0 ? " (Enabled)" : " (Disabled)");
   Print("Break Even Lock (Pips): ", BreakEvenPipsLock);

//--- Get the initial SMA handle (will be updated in OnTick)
   smaHandle = iMA(Symbol(), Period(), optimizedPeriod, 0, MODE_SMA, PRICE_CLOSE);
   if(smaHandle == INVALID_HANDLE)
     {
      Print("Error creating SMA indicator handle - Code: ", GetLastError());
      return(INIT_FAILED);
     }

//--- Get the ATR handle
   atrHandle = iATR(Symbol(), Period(), AtrPeriod);
   if(atrHandle == INVALID_HANDLE)
     {
      Print("Error creating ATR indicator handle - Code: ", GetLastError());
      // Don't necessarily fail init, could potentially proceed without dynamic SL/TP
      // Or return INIT_FAILED if ATR is critical
      return(INIT_FAILED);
     }

//--- Initialization successful
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//--- Release indicator handles if they were created
   if(smaHandle != INVALID_HANDLE)
      IndicatorRelease(smaHandle);
   if(atrHandle != INVALID_HANDLE)
      IndicatorRelease(atrHandle);

//--- Print deinitialization message
   Print("Volatility Optimized SMA EA v2 Deinitialized. Reason: ", reason);
  }

//+------------------------------------------------------------------+
//| Function to calculate simple market volatility                   |
//| (Adapted from the provided sample)                             |
//+------------------------------------------------------------------+
double MarketVolatility(const double &high[], const double &low[], int count)
  {
   int len = count;
   if(len < 2 || ArraySize(high) < len || ArraySize(low) < len)
     {
      PrintFormat("MarketVolatility: Not enough data or invalid array sizes. Len: %d, HighSize: %d, LowSize: %d", len, ArraySize(high), ArraySize(low));
      return 0.0;
     }

   double sumVolatility = 0.0;
   for(int i = 0; i < len; i++)
     {
      sumVolatility += MathAbs(high[i] - low[i]);
     }
   return sumVolatility / len; // Average range over the specified count
  }

//+------------------------------------------------------------------+
//| Function to manage open positions (Trailing Stop, Break Even)    |
//+------------------------------------------------------------------+
void ManageOpenPositions()
  {
   MqlTick currentTick;
   if(!SymbolInfoTick(Symbol(), currentTick))
     {
      Print("ManageOpenPositions: Error getting current tick - Code: ", GetLastError());
      return;
     }
   double askPrice = currentTick.ask;
   double bidPrice = currentTick.bid;

   // Iterate through all open positions for this EA
   for(int i = PositionsTotal() - 1; i >= 0; i--)
     {
      ulong positionTicket = PositionGetTicket(i);
      if(PositionSelectByTicket(positionTicket))
        {
         // Check if the position belongs to this EA instance
         if(PositionGetInteger(POSITION_MAGIC) == MagicNumber && PositionGetString(POSITION_SYMBOL) == Symbol())
           {
            double openPrice = PositionGetDouble(POSITION_PRICE_OPEN);
            double currentSL = PositionGetDouble(POSITION_SL);
            double currentTP = PositionGetDouble(POSITION_TP);
            long positionType = PositionGetInteger(POSITION_TYPE);
            double profitPoints = 0;
            double newSL = currentSL;
            bool modifyOrder = false;

            // Calculate profit in points
            if(positionType == POSITION_TYPE_BUY)
              {
               profitPoints = (bidPrice - openPrice) / point;
              }
            else // POSITION_TYPE_SELL
              {
               profitPoints = (openPrice - askPrice) / point;
              }

            // --- Break Even Logic ---
            if(BreakEvenPoints > 0 && profitPoints >= BreakEvenPoints)
              {
               double breakEvenLevel = 0;
               if(positionType == POSITION_TYPE_BUY)
                 {
                  breakEvenLevel = openPrice + BreakEvenPipsLock * point;
                  // Only modify if the new SL is better than the current SL
                  if(currentSL < breakEvenLevel)
                    {
                     newSL = breakEvenLevel;
                     modifyOrder = true;
                     PrintFormat("Position #%d: Moving SL to Break Even +%d pips. Old SL: %.5f, New SL: %.5f",
                                 positionTicket, BreakEvenPipsLock, currentSL, newSL);
                    }
                 }
               else // POSITION_TYPE_SELL
                 {
                  breakEvenLevel = openPrice - BreakEvenPipsLock * point;
                  // Only modify if the new SL is better than the current SL (higher price for sell SL)
                  if(currentSL == 0 || currentSL > breakEvenLevel) // Handle case where SL might be 0 initially
                    {
                     newSL = breakEvenLevel;
                     modifyOrder = true;
                     PrintFormat("Position #%d: Moving SL to Break Even +%d pips. Old SL: %.5f, New SL: %.5f",
                                 positionTicket, BreakEvenPipsLock, currentSL, newSL);
                    }
                 }
              }

            // --- Trailing Stop Logic ---
            // Note: Break-even logic takes precedence if both trigger on the same tick
            if(TrailingStopPoints > 0 && profitPoints >= TrailingStartPoints)
              {
               double trailingLevel = 0;
               if(positionType == POSITION_TYPE_BUY)
                 {
                  trailingLevel = bidPrice - TrailingStopPoints * point;
                  // Only trail if the new SL is better than the current SL (including potential BE level)
                  if(newSL < trailingLevel)
                    {
                     newSL = trailingLevel;
                     modifyOrder = true;
                     // PrintFormat("Position #%d: Trailing SL. New SL: %.5f", positionTicket, newSL); // Can be verbose
                    }
                 }
               else // POSITION_TYPE_SELL
                 {
                  trailingLevel = askPrice + TrailingStopPoints * point;
                  // Only trail if the new SL is better than the current SL (including potential BE level)
                  if(newSL == 0 || newSL > trailingLevel) // Handle SL=0 case
                    {
                     newSL = trailingLevel;
                     modifyOrder = true;
                     // PrintFormat("Position #%d: Trailing SL. New SL: %.5f", positionTicket, newSL); // Can be verbose
                    }
                 }
              }

            // --- Modify Position if SL changed ---
            if(modifyOrder)
              {
               if(!trade.PositionModify(positionTicket, newSL, currentTP))
                 {
                  PrintFormat("Position #%d: Failed to modify SL. Error %d: %s",
                              positionTicket, trade.ResultRetcode(), trade.ResultComment());
                 }
              }
           }
        }
      else
        {
         PrintFormat("ManageOpenPositions: Error selecting position #%d - Code: %d", positionTicket, GetLastError());
        }
     }
  }

//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//--- Check if a new bar has started
   static datetime lastBarTime = 0;
   datetime currentBarTime = (datetime)SeriesInfoInteger(Symbol(), Period(), SERIES_LASTBAR_DATE);
   bool isNewBar = false;
   if(lastBarTime < currentBarTime)
     {
      lastBarTime = currentBarTime;
      isNewBar = true;
     }

//--- Calculate volatility and update SMA period only on a new bar
   if(isNewBar)
     {
      int historyBars = 20; // Bars for volatility calculation
      MqlRates rates[];
      if(CopyRates(Symbol(), Period(), 0, historyBars + 1, rates) < historyBars) // Need +1 for correct indexing in MarketVolatility
        {
         Print("Error copying rates for volatility - Code: ", GetLastError());
         return;
        }

      double highArray[];
      double lowArray[];
      ArrayResize(highArray, historyBars);
      ArrayResize(lowArray, historyBars);
      // Use rates[1] to rates[historyBars] for calculation if MarketVolatility expects past bars
      // Or use rates[0] to rates[historyBars-1] if it uses current forming bar
      // Let's assume MarketVolatility uses the last 'historyBars' completed bars (index 1 to historyBars)
      bool copySuccessful = true;
      for(int i = 0; i < historyBars; i++)
        {
         if (i + 1 < ArraySize(rates))
           {
             highArray[i] = rates[i+1].high;
             lowArray[i] = rates[i+1].low;
           }
         else
           {
             PrintFormat("Error accessing rates array at index %d", i+1);
             copySuccessful = false;
             break;
           }
        }

      if (!copySuccessful) return;

      double volatility = MarketVolatility(highArray, lowArray, historyBars);

      int newOptimizedPeriod = DefaultPeriod;
      if(volatility > HighVolatilityThreshold && HighVolatilityThreshold > 0) // Avoid division by zero if threshold is 0
        {
         newOptimizedPeriod = MathMax(2, (int)MathRound(DefaultPeriod / 2.0)); // Ensure period >= 2
        }
      else if(volatility < LowVolatilityThreshold && LowVolatilityThreshold > 0)
        {
         newOptimizedPeriod = MathMax(2, (int)MathRound(DefaultPeriod * 2.0)); // Ensure period >= 2
        }

      if(newOptimizedPeriod != optimizedPeriod)
        {
         PrintFormat("Volatility: %.5f. Updating SMA period from %d to %d", volatility, optimizedPeriod, newOptimizedPeriod);
         optimizedPeriod = newOptimizedPeriod;

         if(smaHandle != INVALID_HANDLE) IndicatorRelease(smaHandle);
         smaHandle = iMA(Symbol(), Period(), optimizedPeriod, 0, MODE_SMA, PRICE_CLOSE);
         if(smaHandle == INVALID_HANDLE)
           {
            Print("Error updating SMA handle - Code: ", GetLastError());
            return;
           }
        }
     }

//--- Ensure handles are valid
   if(smaHandle == INVALID_HANDLE || atrHandle == INVALID_HANDLE)
     {
      Print("SMA or ATR Handle is invalid in OnTick. Cannot proceed.");
      return;
     }

//--- Get latest indicator values
   double smaValue[1];
   double atrValue[1];
   if(CopyBuffer(smaHandle, 0, 0, 1, smaValue) <= 0)
     {
      // Print("Error copying SMA buffer - Code: ", GetLastError()); // Can be noisy
      return; // Wait for next tick
     }
   if(CopyBuffer(atrHandle, 0, 0, 1, atrValue) <= 0)
     {
      // Print("Error copying ATR buffer - Code: ", GetLastError()); // Can be noisy
      return; // Wait for next tick
     }
   double currentSMA = smaValue[0];
   double currentATR = atrValue[0];

//--- Get current price information
   MqlTick currentTick;
   if(!SymbolInfoTick(Symbol(), currentTick))
     {
      Print("Error getting current tick - Code: ", GetLastError());
      return;
     }
   double askPrice = currentTick.ask;
   double bidPrice = currentTick.bid;

//--- Manage existing positions (Trailing Stop, Break Even)
   ManageOpenPositions();

//--- Check if allowed to trade (e.g., no open positions for this EA)
   int eaPositions = 0;
   for(int i = PositionsTotal() - 1; i >= 0; i--)
     {
      if(PositionSelectByTicket(PositionGetTicket(i)))
        {
         if(PositionGetString(POSITION_SYMBOL) == Symbol() && PositionGetInteger(POSITION_MAGIC) == MagicNumber)
           {
            eaPositions++;
           }
        }
     }

//--- Entry Logic ---
   if(eaPositions == 0) // Only enter if no position is open for this EA
     {
      // Calculate dynamic SL and TP
      double stopLossDistance = currentATR * AtrMultiplierSL;
      double takeProfitDistance = stopLossDistance * RiskRewardRatioTP;
      double sl = 0;
      double tp = 0;

      // Normalize SL/TP distances to be at least a few points
      double minDistancePoints = 5 * point; // Minimum 5 points SL/TP distance
      stopLossDistance = MathMax(stopLossDistance, minDistancePoints);
      takeProfitDistance = MathMax(takeProfitDistance, minDistancePoints);

      // --- Buy Signal --- (Price crosses above SMA)
      if(askPrice > currentSMA)
        {
         sl = askPrice - stopLossDistance;
         tp = askPrice + takeProfitDistance;
         // Normalize SL and TP prices according to symbol rules
         sl = NormalizeDouble(sl, (int)SymbolInfoInteger(Symbol(), SYMBOL_DIGITS));
         tp = NormalizeDouble(tp, (int)SymbolInfoInteger(Symbol(), SYMBOL_DIGITS));

         PrintFormat("BUY Signal: Ask=%.5f > SMA=%.5f. ATR=%.5f. SL Dist=%.5f (%.1f pts), TP Dist=%.5f (%.1f pts)",
                     askPrice, currentSMA, currentATR, stopLossDistance, stopLossDistance/point, takeProfitDistance, takeProfitDistance/point);
         PrintFormat("Attempting BUY: Lot=%.2f, Entry=%.5f, SL=%.5f, TP=%.5f",
                     LotSize, askPrice, sl, tp);

         if(!trade.Buy(LotSize, Symbol(), askPrice, sl, tp, "VolOpt SMA Buy"))
           {
            PrintFormat("Buy order failed: %d - %s", trade.ResultRetcode(), trade.ResultComment());
           }
         else
           {
            PrintFormat("Buy order placed successfully. Ticket: %d", trade.ResultOrder());
           }
        }
      // --- Sell Signal --- (Price crosses below SMA)
      else if(bidPrice < currentSMA)
        {
         sl = bidPrice + stopLossDistance;
         tp = bidPrice - takeProfitDistance;
         // Normalize SL and TP prices according to symbol rules
         sl = NormalizeDouble(sl, (int)SymbolInfoInteger(Symbol(), SYMBOL_DIGITS));
         tp = NormalizeDouble(tp, (int)SymbolInfoInteger(Symbol(), SYMBOL_DIGITS));

         PrintFormat("SELL Signal: Bid=%.5f < SMA=%.5f. ATR=%.5f. SL Dist=%.5f (%.1f pts), TP Dist=%.5f (%.1f pts)",
                     bidPrice, currentSMA, currentATR, stopLossDistance, stopLossDistance/point, takeProfitDistance, takeProfitDistance/point);
         PrintFormat("Attempting SELL: Lot=%.2f, Entry=%.5f, SL=%.5f, TP=%.5f",
                     LotSize, bidPrice, sl, tp);

         if(!trade.Sell(LotSize, Symbol(), bidPrice, sl, tp, "VolOpt SMA Sell"))
           {
            PrintFormat("Sell order failed: %d - %s", trade.ResultRetcode(), trade.ResultComment());
           }
         else
           {
            PrintFormat("Sell order placed successfully. Ticket: %d", trade.ResultOrder());
           }
        }
     } // End if(eaPositions == 0)
  }
//+------------------------------------------------------------------+

