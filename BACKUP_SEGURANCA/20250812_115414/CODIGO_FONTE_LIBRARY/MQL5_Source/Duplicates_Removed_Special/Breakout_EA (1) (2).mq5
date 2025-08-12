
//+------------------------------------------------------------------+
//|                                              Breakout_EA.mq5     |
//|                           Strategy: Buy after support breakout   |
//|                           Sell after resistance breakout         |
//|                           Timeframe: H1                          |
//+------------------------------------------------------------------+
#property strict

input int    LookbackCandles = 20;     // Number of candles to determine S/R
input double Lots            = 0.01;   // Fixed lot size
input int    TrailingStop    = 200;    // Trailing stop in points (20 pips)
input int    Slippage        = 5;      // Max slippage in points

datetime lastTradeTime = 0;

//+------------------------------------------------------------------+
int OnInit()
  {
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
void OnTick()
  {
   if (Period() != PERIOD_H1)
      return;

   static datetime lastChecked = 0;
   MqlRates rates[];
   if (CopyRates(_Symbol, PERIOD_H1, 0, LookbackCandles + 1, rates) <= 0)
      return;

   datetime currentTime = rates[0].time;
   if (currentTime == lastChecked)
      return;

   lastChecked = currentTime;

   double highestHigh = rates[1].high;
   double lowestLow = rates[1].low;

   for (int i = 2; i <= LookbackCandles; i++)
     {
      if (rates[i].high > highestHigh)
         highestHigh = rates[i].high;
      if (rates[i].low < lowestLow)
         lowestLow = rates[i].low;
     }

   double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
   double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
   double point = SymbolInfoDouble(_Symbol, SYMBOL_POINT);

   // Entry conditions
   if (TimeCurrent() - lastTradeTime > 3600) // Only trade once per hour
     {
      // Buy breakout
      if (rates[1].close > highestHigh)
        {
         if (OrderSend(Symbol(), OP_BUY, Lots, ask, Slippage, 0, 0, "Buy Breakout", MAGIC_NUMBER, 0, clrBlue) > 0)
            lastTradeTime = TimeCurrent();
        }

      // Sell breakout
      if (rates[1].close < lowestLow)
        {
         if (OrderSend(Symbol(), OP_SELL, Lots, bid, Slippage, 0, 0, "Sell Breakout", MAGIC_NUMBER, 0, clrRed) > 0)
            lastTradeTime = TimeCurrent();
        }
     }

   // Trailing stop logic
   for (int i = OrdersTotal() - 1; i >= 0; i--)
     {
      if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
        {
         if (OrderSymbol() != _Symbol) continue;

         if (OrderType() == OP_BUY)
           {
            double newStop = bid - TrailingStop * point;
            if (OrderStopLoss() < newStop)
               OrderModify(OrderTicket(), OrderOpenPrice(), newStop, 0, 0, clrGreen);
           }
         else if (OrderType() == OP_SELL)
           {
            double newStop = ask + TrailingStop * point;
            if (OrderStopLoss() > newStop || OrderStopLoss() == 0)
               OrderModify(OrderTicket(), OrderOpenPrice(), newStop, 0, 0, clrGreen);
           }
        }
     }
  }
//+------------------------------------------------------------------+
