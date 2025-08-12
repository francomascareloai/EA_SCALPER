#include <Trade\Trade.mqh>

// Create an instance of the CTrade class
CTrade trade;

// Indicator buffers
double middleBand[];
double upperBand[];
double lowerBand[];
double maTrend[];
double adxBuffer[];
double mfiBuffer[];

input double LotSize = 0.2;
input double TrailingStop = 30;
input int HalfLength = 12;
input int MaPeriod = 50; // Period for Moving Average
input int ADXPeriod = 14; // Period for ADX
input int MFIPeriod = 14; // Period for MFI
input double ADXThreshold = 25; // Threshold for ADX
input double MFIThresholdHigh = 80; // Threshold for high MFI
input double MFIThresholdLow = 20; // Threshold for low MFI
input double UserStopLoss = 50; // User defined Stop Loss (points)
input double UserTakeProfit = 100; // User defined Take Profit (points)
input double TrailingDistance = 500;  // Distance to move SL
input double ProfitLockDistance = 500;  // Distance before starting to move SL
input double InitialStopLoss = 350;  // Initial stop loss distance (350 points)
input double MoveSLDistance = 350; // Distance from current price to move SL when locking in profit

int handleTMA;
int handleMA;
int handleADX;
datetime lastBuyTime = 0;  // Store the last buy signal time
datetime lastSellTime = 0;  // Store the last sell signal time
int minTimeBetweenTrades = 15;  // Minimum time between trades in minutes

//+------------------------------------------------------------------+
//| Custom function to calculate the Money Flow Index                |
//+------------------------------------------------------------------+
double CalculateMFI(int period)
{
   double positiveFlow = 0;
   double negativeFlow = 0;
   for (int i = 1; i <= period; i++)
   {
      double typicalPrice = (iHigh(Symbol(), Period(), i) + iLow(Symbol(), Period(), i) + iClose(Symbol(), Period(), i)) / 3;
      double prevTypicalPrice = (iHigh(Symbol(), Period(), i + 1) + iLow(Symbol(), Period(), i + 1) + iClose(Symbol(), Period(), i + 1)) / 3;
      double moneyFlow = typicalPrice * iVolume(Symbol(), Period(), i);

      if (typicalPrice > prevTypicalPrice)
         positiveFlow += moneyFlow;
      else if (typicalPrice < prevTypicalPrice)
         negativeFlow += moneyFlow;
   }

   double moneyRatio = (negativeFlow == 0) ? 0 : positiveFlow / negativeFlow;
   double mfi = 100 - (100 / (1 + moneyRatio));
   return mfi;
}

//+------------------------------------------------------------------+
//| Initialization function of the expert                            |
//+------------------------------------------------------------------+
int OnInit()
{
   //--- Initialize TMA indicator
   handleTMA = iCustom(Symbol(), Period(), "tma-centered-bands-indicator.ex5");

   //--- Initialize Moving Average
   handleMA = iMA(Symbol(), Period(), MaPeriod, 0, MODE_SMA, PRICE_CLOSE);

   //--- Initialize ADX
   handleADX = iADX(Symbol(), Period(), ADXPeriod);

   if(handleTMA == INVALID_HANDLE || handleMA == INVALID_HANDLE || handleADX == INVALID_HANDLE)
   {
      Print("Error initializing indicators");
      return(INIT_FAILED);
   }

   //--- Set buffers for the indicator
   ArraySetAsSeries(middleBand, true);
   ArraySetAsSeries(upperBand, true);
   ArraySetAsSeries(lowerBand, true);
   ArraySetAsSeries(maTrend, true);
   ArraySetAsSeries(adxBuffer, true);
   ArraySetAsSeries(mfiBuffer, true);
   
   //--- ok
   return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| Deinitialization function of the expert                          |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   //--- Release TMA indicator handle
   if(handleTMA != INVALID_HANDLE)
      IndicatorRelease(handleTMA);
   if(handleMA != INVALID_HANDLE)
      IndicatorRelease(handleMA);
   if(handleADX != INVALID_HANDLE)
      IndicatorRelease(handleADX);
}

//+------------------------------------------------------------------+
//| "Tick" event handler function                                    |
//+------------------------------------------------------------------+
void OnTick()
{
   //--- Copy TMA indicator data
   if(handleTMA == INVALID_HANDLE || handleMA == INVALID_HANDLE || handleADX == INVALID_HANDLE)
       return;

   int copiedMiddle = CopyBuffer(handleTMA, 0, 0, 1, middleBand); // Middle band buffer
   int copiedUpper = CopyBuffer(handleTMA, 1, 0, 1, upperBand); // Upper band buffer
   int copiedLower = CopyBuffer(handleTMA, 2, 0, 1, lowerBand); // Lower band buffer
   int copiedMA = CopyBuffer(handleMA, 0, 0, 1, maTrend); // MA buffer
   int copiedADX = CopyBuffer(handleADX, 0, 0, 1, adxBuffer); // ADX buffer

   if(copiedMiddle < 1 || copiedUpper < 1 || copiedLower < 1 || copiedMA < 1 || copiedADX < 1)
   {
       Print("Error copying indicator data");
       return;
   }

   double price = iClose(Symbol(), Period(), 0); // Current close price
   double Ask = SymbolInfoDouble(Symbol(), SYMBOL_ASK);
   double Bid = SymbolInfoDouble(Symbol(), SYMBOL_BID);
   double point = SymbolInfoDouble(Symbol(), SYMBOL_POINT);
   int stopsLevel = SymbolInfoInteger(Symbol(), SYMBOL_TRADE_STOPS_LEVEL);

   double stopLossBuy = Ask - UserStopLoss * point; // User defined stop loss
   double takeProfitBuy = Ask + UserTakeProfit * point; // User defined take profit
   double stopLossSell = Bid + UserStopLoss * point; // User defined stop loss
   double takeProfitSell = Bid - UserTakeProfit * point; // User defined take profit

   datetime currentTime = TimeCurrent();

   // Calculate MFI
   double mfi = CalculateMFI(MFIPeriod);

   // Check for Buy signal with trend, ADX, and MFI confirmation
   if(price < lowerBand[0] && price < maTrend[0] && adxBuffer[0] > ADXThreshold && mfi < MFIThresholdLow && (currentTime - lastBuyTime) > minTimeBetweenTrades * 60)
   {
      // Check if stops are valid
      if((Ask - stopLossBuy) >= (stopsLevel * point) && (takeProfitBuy - Ask) >= (stopsLevel * point))
      {
         // Buy Signal
         if(trade.Buy(LotSize, Symbol(), Ask, stopLossBuy, takeProfitBuy, "TMA Buy Signal"))
         {
             lastBuyTime = currentTime;  // Update last buy time
         }
      }
   }
   // Check for Sell signal with trend, ADX, and MFI confirmation
   else if(price > upperBand[0] && price > maTrend[0] && adxBuffer[0] > ADXThreshold && mfi > MFIThresholdHigh && (currentTime - lastSellTime) > minTimeBetweenTrades * 60)
   {
      // Check if stops are valid
      if((stopLossSell - Bid) >= (stopsLevel * point) && (Bid - takeProfitSell) >= (stopsLevel * point))
      {
         // Sell Signal
         if(trade.Sell(LotSize, Symbol(), Bid, stopLossSell, takeProfitSell, "TMA Sell Signal"))
         {
             lastSellTime = currentTime;  // Update last sell time
         }
      }
   }

   // Trailing stop logic
   for (int i = PositionsTotal() - 1; i >= 0; i--)
   {
      ulong ticket = PositionGetTicket(i);
      if (PositionSelectByTicket(ticket))
      {
         double openPrice = PositionGetDouble(POSITION_PRICE_OPEN);
         double currentPrice = (PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY) ? Bid : Ask;
         double stopLoss = PositionGetDouble(POSITION_SL);
         double takeProfit = PositionGetDouble(POSITION_TP); // Get the existing TP
         double newStopLoss;

         if (PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY)
         {
           // Move SL when price moves more than ProfitLockDistance in our favor
            if (currentPrice - openPrice > ProfitLockDistance * _Point)
            {
               newStopLoss = currentPrice - MoveSLDistance * _Point;
               if (stopLoss < newStopLoss)
               {
                  trade.PositionModify(ticket, newStopLoss, takeProfit); // Include TP in the modification
               }
            }
         }
         else if (PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_SELL)
         {
            // Move SL when price moves more than ProfitLockDistance in our favor
            if (openPrice - currentPrice > ProfitLockDistance * _Point)
            {
               newStopLoss = currentPrice + MoveSLDistance * _Point;
               if (stopLoss > newStopLoss)
               {
                  trade.PositionModify(ticket, newStopLoss, takeProfit); // Include TP in the modification
               }
            }
         }
      }
   }
}

//+------------------------------------------------------------------+
//| Timer function                                                   |
//+------------------------------------------------------------------+
void OnTimer()
{
   // Can be used for periodic checks if needed
}
