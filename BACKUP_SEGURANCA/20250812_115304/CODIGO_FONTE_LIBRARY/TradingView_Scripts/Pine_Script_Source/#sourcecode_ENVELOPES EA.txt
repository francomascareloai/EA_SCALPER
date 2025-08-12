//+------------------------------------------------------------------+
//|                                                 ENVELOPES EA.mq5 |
//|                                  Copyright 2023, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2023, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"

#include <Trade/Trade.mqh>
CTrade obj_Trade;

int handleEnv;
double UpperEnv[],LowerEnv[];

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit(){
   
   handleEnv = iEnvelopes(_Symbol,_Period,14,0,MODE_SMA,PRICE_CLOSE,0.5);
   if (handleEnv == INVALID_HANDLE){
      Print("UNABLE TO CREATE THE INDICATOR HANDLE. REVERTING NOW");
      return (INIT_FAILED);
   }
   // sort the data to timeseries format
   ArraySetAsSeries(UpperEnv,true);
   ArraySetAsSeries(LowerEnv,true);
   
   return(INIT_SUCCEEDED);
}
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason){

   IndicatorRelease(handleEnv);
   
   ArrayFree(UpperEnv);
   ArrayFree(LowerEnv);
   
}
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick(){
   
   // UPPER ENV DATA
   if (CopyBuffer(handleEnv,0,0,3,UpperEnv) < 3){
      Print("NO ENOUGH DATA FROM THE UPPER ENV. REVERTING NOW");
      return;
   }
   // LOWER ENV DATA
   if (CopyBuffer(handleEnv,1,0,3,LowerEnv) < 3){
      Print("NO ENOUGH DATA FROM THE LOWER ENV. REVERTING NOW");
      return;
   }
   
   double Ask = NormalizeDouble(SymbolInfoDouble(_Symbol,SYMBOL_ASK),_Digits);
   double Bid = NormalizeDouble(SymbolInfoDouble(_Symbol,SYMBOL_BID),_Digits);

   //Print("DATA IS AS:");
   //ArrayPrint(UpperEnv,6);
   //ArrayPrint(LowerEnv,6);
   
   static int prevBars = 0;
   int currBars = iBars(_Symbol,_Period);
   if (prevBars == currBars) return;
   prevBars = currBars;
   
   double close1 = iClose(_Symbol,_Period,1);
   double close2 = iClose(_Symbol,_Period,2);

   if (close1 < UpperEnv[0] && close2 > UpperEnv[1]){
      Print("SELL SIGNAL @ ",TimeCurrent());
      obj_Trade.Sell(1,_Symbol,Bid,Bid+300*_Point,Bid-300*_Point);
   }
   else if (close1 > LowerEnv[0] && close2 < LowerEnv[1]){
      Print("BUY SIGNAL @ ",TimeCurrent());
      obj_Trade.Buy(1,_Symbol,Ask,Ask-300*_Point,Ask+300*_Point);
   }
   
}
//+------------------------------------------------------------------+
