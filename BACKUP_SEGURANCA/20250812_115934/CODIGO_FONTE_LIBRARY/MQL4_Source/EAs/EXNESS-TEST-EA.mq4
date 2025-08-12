//+------------------------------------------------------------------+
//|                                               EXNESS-TEST-EA.mq4 |
//|                                  Copyright 2025, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2025, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
   Print("Symbol=",Symbol()); 
   Print("Low day price=",MarketInfo(Symbol(),MODE_LOW)); 
   Print("High day price=",MarketInfo(Symbol(),MODE_HIGH)); 
   Print("The last incoming tick time=",(MarketInfo(Symbol(),MODE_TIME))); 
   Print("Last incoming bid price=",MarketInfo(Symbol(),MODE_BID)); 
   Print("Last incoming ask price=",MarketInfo(Symbol(),MODE_ASK)); 
   Print("Point size in the quote currency=",MarketInfo(Symbol(),MODE_POINT)); 
   Print("Digits after decimal point=",MarketInfo(Symbol(),MODE_DIGITS)); 
   Print("Spread value in points=",MarketInfo(Symbol(),MODE_SPREAD)); 
   Print("Stop level in points=",MarketInfo(Symbol(),MODE_STOPLEVEL)); 
   Print("Lot size in the base currency=",MarketInfo(Symbol(),MODE_LOTSIZE)); 
   Print("Tick value in the deposit currency=",MarketInfo(Symbol(),MODE_TICKVALUE)); 
   Print("Tick size in points=",MarketInfo(Symbol(),MODE_TICKSIZE));  
   Print("Swap of the buy order=",MarketInfo(Symbol(),MODE_SWAPLONG)); 
   Print("Swap of the sell order=",MarketInfo(Symbol(),MODE_SWAPSHORT)); 
   Print("Market starting date (for futures)=",MarketInfo(Symbol(),MODE_STARTING)); 
   Print("Market expiration date (for futures)=",MarketInfo(Symbol(),MODE_EXPIRATION)); 
   Print("Trade is allowed for the symbol=",MarketInfo(Symbol(),MODE_TRADEALLOWED)); 
   Print("Minimum permitted amount of a lot=",MarketInfo(Symbol(),MODE_MINLOT)); 
   Print("Step for changing lots=",MarketInfo(Symbol(),MODE_LOTSTEP)); 
   Print("Maximum permitted amount of a lot=",MarketInfo(Symbol(),MODE_MAXLOT)); 
   Print("Swap calculation method=",MarketInfo(Symbol(),MODE_SWAPTYPE)); 
   Print("Profit calculation mode=",MarketInfo(Symbol(),MODE_PROFITCALCMODE)); 
   Print("Margin calculation mode=",MarketInfo(Symbol(),MODE_MARGINCALCMODE)); 
   Print("Initial margin requirements for 1 lot=",MarketInfo(Symbol(),MODE_MARGININIT)); 
   Print("Margin to maintain open orders calculated for 1 lot=",MarketInfo(Symbol(),MODE_MARGINMAINTENANCE)); 
   Print("Hedged margin calculated for 1 lot=",MarketInfo(Symbol(),MODE_MARGINHEDGED)); 
   Print("Free margin required to open 1 lot for buying=",MarketInfo(Symbol(),MODE_MARGINREQUIRED)); 
   Print("Order freeze level in points=",MarketInfo(Symbol(),MODE_FREEZELEVEL));  
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {   
  }
