
//+------------------------------------------------------------------+
//|                  XAUUSD_Scalper_Pro_MT5_CORRECTED.mq5           |
//|           Fixed Supertrend + RSI + Trailing + News Filter        |
//+------------------------------------------------------------------+
#property strict

#include <Trade/Trade.mqh>
#include <Calendar.mqh>

input int EMA_Length = 50;
input int RSI_Length = 14;
input int MACD_Fast = 12;
input int MACD_Slow = 26;
input int MACD_Signal = 9;
input double Supertrend_ATR_Multiplier = 1.5;
input int Supertrend_ATR_Length = 10;
input double TakeProfit_Pips = 20.0;
input double StopLoss_Pips = 10.0;
input double TrailingStop_Pips = 8.0;
input double LotSize = 0.1;
input int MagicNumber = 123456;
input bool EnableAlerts = true;
input bool EnableNewsFilter = true;
input bool EnableSessionFilter = true;
input int StartHour = 8;
input int EndHour = 20;

CTrade tradeEngine;

// Handles
int emaHandle, rsiHandle, macdHandle, atrHandle;
double ema[], rsi[], macdMain[], macdSignal[], atr[];

datetime lastNewsCheck = 0;
bool lastNewsResult = false;

//+------------------------------------------------------------------+
int OnInit()
{
   emaHandle = iMA(_Symbol, _Period, EMA_Length, 0, MODE_EMA, PRICE_CLOSE);
   rsiHandle = iRSI(_Symbol, _Period, RSI_Length, PRICE_CLOSE);
   macdHandle = iMACD(_Symbol, _Period, MACD_Fast, MACD_Slow, MACD_Signal, PRICE_CLOSE);
   atrHandle = iATR(_Symbol, _Period, Supertrend_ATR_Length);

   tradeEngine.SetExpertMagicNumber(MagicNumber);

   return INIT_SUCCEEDED;
}
//+------------------------------------------------------------------+
void OnTick()
{
   if (EnableNewsFilter && IsHighImpactNews())
      return;

   if (EnableSessionFilter && !IsWithinSession())
      return;

   if (!GetIndicatorValues())
      return;

   MqlRates priceInfo[];
   ArraySetAsSeries(priceInfo, true);
   if (CopyRates(_Symbol, _Period, 0, 2, priceInfo) < 2)
      return;

   double point = SymbolInfoDouble(_Symbol, SYMBOL_POINT);
   double slPoints = StopLoss_Pips * point * 10;
   double tpPoints = TakeProfit_Pips * point * 10;
   double trailingPoints = TrailingStop_Pips * point * 10;

   bool macdCrossUp = (macdMain[1] < macdSignal[1]) && (macdMain[0] > macdSignal[0]);
   bool macdCrossDown = (macdMain[1] > macdSignal[1]) && (macdMain[0] < macdSignal[0]);

   bool priceAboveEMA = priceInfo[1].close > ema[1];
   bool priceBelowEMA = priceInfo[1].close < ema[1];

   double prevHigh = priceInfo[1].high;
   double prevLow = priceInfo[1].low;
   double prevMid = (prevHigh + prevLow) / 2.0;
   double supertrendUpper = prevMid + (Supertrend_ATR_Multiplier * atr[1]);
   double supertrendLower = prevMid - (Supertrend_ATR_Multiplier * atr[1]);
   bool supertrendBullish = priceInfo[1].close > supertrendUpper;
   bool supertrendBearish = priceInfo[1].close < supertrendLower;

   if (PositionsTotal() == 0)
   {
      if (priceAboveEMA && rsi[1] > 50 && macdCrossUp && supertrendBullish)
      {
         if (openTrade(ORDER_TYPE_BUY, tpPoints, slPoints) && EnableAlerts)
            Alert("BUY signal on XAUUSD");
      }
      else if (priceBelowEMA && rsi[1] < 50 && macdCrossDown && supertrendBearish)
      {
         if (openTrade(ORDER_TYPE_SELL, tpPoints, slPoints) && EnableAlerts)
            Alert("SELL signal on XAUUSD");
      }
   }
   else
   {
      trailStops(trailingPoints);
   }
}
//+------------------------------------------------------------------+
bool GetIndicatorValues()
{
   ArraySetAsSeries(ema, true);
   ArraySetAsSeries(rsi, true);
   ArraySetAsSeries(macdMain, true);
   ArraySetAsSeries(macdSignal, true);
   ArraySetAsSeries(atr, true);

   return (CopyBuffer(emaHandle, 0, 0, 3, ema) == 3 &&
           CopyBuffer(rsiHandle, 0, 0, 3, rsi) == 3 &&
           CopyBuffer(macdHandle, 0, 0, 3, macdMain) == 3 &&
           CopyBuffer(macdHandle, 1, 0, 3, macdSignal) == 3 &&
           CopyBuffer(atrHandle, 0, 0, 3, atr) == 3);
}
//+------------------------------------------------------------------+
bool openTrade(ENUM_ORDER_TYPE type, double tpPoints, double slPoints)
{
   double price = (type == ORDER_TYPE_BUY) ? SymbolInfoDouble(_Symbol, SYMBOL_ASK)
                                           : SymbolInfoDouble(_Symbol, SYMBOL_BID);
   double stopLoss = (type == ORDER_TYPE_BUY) ? price - slPoints : price + slPoints;
   double takeProfit = (type == ORDER_TYPE_BUY) ? price + tpPoints : price - tpPoints;

   bool result = false;
   if (type == ORDER_TYPE_BUY)
      result = tradeEngine.Buy(LotSize, _Symbol, price, stopLoss, takeProfit, "ScalperPro");
   else
      result = tradeEngine.Sell(LotSize, _Symbol, price, stopLoss, takeProfit, "ScalperPro");

   if (!result)
   {
      Print("Trade failed: ", tradeEngine.ResultRetcode(), " - ", tradeEngine.ResultRetcodeDescription());
      return false;
   }

   return true;
}
//+------------------------------------------------------------------+
void trailStops(double trailingPoints)
{
   double point = SymbolInfoDouble(_Symbol, SYMBOL_POINT);
   double minModifyDistance = 10 * point;

   for (int i = PositionsTotal() - 1; i >= 0; i--)
   {
      if (PositionGetTicket(i) > 0)
      {
         ulong ticket = PositionGetTicket(i);
         if (PositionSelectByTicket(ticket) &&
             PositionGetInteger(POSITION_MAGIC) == MagicNumber &&
             PositionGetString(POSITION_SYMBOL) == _Symbol)
         {
            double currentStop = PositionGetDouble(POSITION_SL);
            double currentTP = PositionGetDouble(POSITION_TP);
            double currentPrice = PositionGetDouble(POSITION_PRICE_CURRENT);
            ENUM_POSITION_TYPE posType = (ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE);
            double newStop = currentStop;

            if (posType == POSITION_TYPE_BUY)
            {
               newStop = currentPrice - trailingPoints;
               if (newStop > currentStop && (newStop - currentStop) > minModifyDistance)
               {
                  tradeEngine.PositionModify(ticket, newStop, currentTP);
               }
            }
            else if (posType == POSITION_TYPE_SELL)
            {
               newStop = currentPrice + trailingPoints;
               if (newStop < currentStop && (currentStop - newStop) > minModifyDistance)
               {
                  tradeEngine.PositionModify(ticket, newStop, currentTP);
               }
            }
         }
      }
   }
}
//+------------------------------------------------------------------+
bool IsHighImpactNews()
{
   if (TimeCurrent() - lastNewsCheck < 300)
      return lastNewsResult;

   MqlCalendarEvent events[];
   datetime now = TimeCurrent();
   datetime start = now - 3600;
   datetime end = now + 3600;

   lastNewsResult = false;

   if (CalendarEventHistory(events, start, end))
   {
      for (int i = 0; i < ArraySize(events); i++)
      {
         if ((events[i].impact == CALENDAR_IMPORTANCE_HIGH) &&
             (events[i].currency == "USD" || events[i].currency == "XAU"))
         {
            if (MathAbs(events[i].time - now) < 7200)
            {
               lastNewsCheck = TimeCurrent();
               lastNewsResult = true;
               return true;
            }
         }
      }
   }

   lastNewsCheck = TimeCurrent();
   return false;
}
//+------------------------------------------------------------------+
bool IsWithinSession()
{
   datetime now = TimeCurrent();
   MqlDateTime mqlTime;
   TimeToStruct(now, mqlTime);
   return (mqlTime.hour >= StartHour && mqlTime.hour < EndHour);
}
//+------------------------------------------------------------------+
