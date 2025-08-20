//+------------------------------------------------------------------+
//|                                              FEMI TRAILING STOP.mq4 |
//|                        Copyright 2020, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
input int      InpTrailingStopPoints      =  30;     // Trailing stop points
double         StopLoss;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit() {
   StopLoss =  SymbolInfoDouble(Symbol(), SYMBOL_POINT)*InpTrailingStopPoints;
   return(INIT_SUCCEEDED);
}
//---
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
   
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
   ApplyTrailingStop(Symbol(), StopLoss); 
}
void  ApplyTrailingStop(string symbol, double stopLoss) {
 
   static int     digits   =  (int)SymbolInfoInteger(symbol, SYMBOL_DIGITS);
 
   // Trailing from the close prices
   double   buyStopLoss    =  NormalizeDouble(SymbolInfoDouble(symbol, SYMBOL_BID)-stopLoss, digits);
   double   sellStopLoss   =  NormalizeDouble(SymbolInfoDouble(symbol, SYMBOL_ASK)+stopLoss, digits);;
 
   int      count          =  OrdersTotal();
   for (int i=count-1; i>=0; i--) {
      if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES)) {
         if (OrderSymbol()==symbol) {
            if (OrderType()==ORDER_TYPE_BUY && buyStopLoss<OrderOpenPrice() && OrderProfit()>0 && (OrderStopLoss()==0 || buyStopLoss>OrderStopLoss())) {
               if (OrderModify(OrderTicket(), OrderOpenPrice(), buyStopLoss, OrderTakeProfit(), OrderExpiration())) {}
            } else
            if (OrderType()==ORDER_TYPE_SELL && sellStopLoss>OrderOpenPrice() && OrderProfit()>0 && (OrderStopLoss()==0 || sellStopLoss<OrderStopLoss())) {
               if (OrderModify(OrderTicket(), OrderOpenPrice(), sellStopLoss, OrderTakeProfit(), OrderExpiration())) {}
            }
         }
      }
   }
    
}  
//+------------------------------------------------------------------+
