//+------------------------------------------------------------------+
//|                                                  TralingStop.mq4 |
//|                            Copyright © 2005, Cleon Adonis Santos |
//|                                                    www.fw380.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2005, Cleon Adonis Santos"
#property link      "www.fw380.com/forex"

extern int  BarsNum = 5;
extern int  PipDistance = 1;
double      LTS, STS, Spread;

int start() {

   int count = 0;

   // ----- Spread calculation -----
   Spread = MarketInfo(Symbol(), MODE_SPREAD) * Point;

   // ----- Stop Loss Calculation -----
   LTS = NormalizeDouble(Low[Lowest(NULL, 0, MODE_LOW, BarsNum, 1)] - (PipDistance * Point), Digits);
   STS = NormalizeDouble(High[Highest(NULL, 0, MODE_HIGH, BarsNum, 1)] + Spread + (PipDistance * Point), Digits);
   Comment("LTS: ", LTS, " - STS: ", STS);
   if (OrdersTotal() != 0) {
      while (count < OrdersTotal()) {
         OrderSelect(count, SELECT_BY_POS, MODE_TRADES);
         if (OrderSymbol() == Symbol()) {
            if (OrderType() == OP_BUY && (LTS > OrderStopLoss() || OrderStopLoss() == 0)) {
               OrderModify(OrderTicket(), 0, LTS, 0, 0, Blue);
               Alert("OP_BUY Error: ", GetLastError(), " - ", LTS, " - ", OrderTicket());
            }
            if (OrderType() == OP_SELL && (STS < OrderStopLoss() || OrderStopLoss() == 0)) {
               OrderModify(OrderTicket(), 0, STS, 0, 0, Red);
               Alert("OP_SELL Error: ", GetLastError(), " - ", STS, " - ", OrderTicket());
            }
            if (OrderType() == OP_BUYSTOP && (LTS > OrderStopLoss() || OrderStopLoss() == 0)) {
               OrderModify(OrderTicket(), OrderOpenPrice(), LTS, 0, 0, Blue);
               Alert("OP_BUYSTOP Error: ", GetLastError(), " - ", LTS, " - ", OrderTicket());
            }
            if (OrderType() == OP_SELLSTOP && (STS < OrderStopLoss() || OrderStopLoss() == 0)) {
               OrderModify(OrderTicket(), OrderOpenPrice(), STS, 0, 0, Red);
               Alert("OP_SELLSTOP Error: ", GetLastError(), " - ", STS, " - ", OrderTicket());
            }
         }
         count++;
      }
   }
   return(0);
}