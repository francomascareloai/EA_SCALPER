//+------------------------------------------------------------------+
//|                                                PARABOLIC SAR.mq5 |
//|                                  Copyright 2023, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2023, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"

#include <Trade/Trade.mqh>
CTrade obj_Trade;

int handleSAR;
double SAR_Data[];

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit(){
   
   handleSAR = iSAR(_Symbol,_Period,0.02,0.2);
   if (handleSAR == INVALID_HANDLE){
      Print("UNABLE TO LOAD UP THE INDICATOR TO THE CHART. REVERTING NOW PAL");
      return (INIT_FAILED);
   }
   
   // sort the data in a timeseries format
   ArraySetAsSeries(SAR_Data,true);
   
   return(INIT_SUCCEEDED);
}
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason){

   IndicatorRelease(handleSAR);
   ArrayFree(SAR_Data);
}
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick(){
   
   if (CopyBuffer(handleSAR,0,0,3,SAR_Data) < 3){
      Print("NO ENOUGH DATA FROM THE SAR INDICATOR FOR FURTHER ANALYSIS. REVERTING");
      return;
   }
   
   //ArrayPrint(SAR_Data);
   double low0 = iLow(_Symbol,_Period,0);
   double low1 = iLow(_Symbol,_Period,1);
   
   double high0 = iHigh(_Symbol,_Period,0);
   double high1 = iHigh(_Symbol,_Period,1);
   
   double Ask = NormalizeDouble(SymbolInfoDouble(_Symbol,SYMBOL_ASK),_Digits);
   double Bid = NormalizeDouble(SymbolInfoDouble(_Symbol,SYMBOL_BID),_Digits);
   
   //Print("Low0 = ",low0,", High1 = ",high1);
   
   static datetime signalTime = 0;
   datetime currTime0 = iTime(_Symbol,_Period,0);
   //Print(prevTime);
   if (SAR_Data[0] < low0 && SAR_Data[1] > high1 && signalTime != currTime0){
      Print("BUY SIGNAL @ ",TimeCurrent());
      signalTime = currTime0;
      obj_Trade.Buy(0.01,_Symbol,Ask,SAR_Data[0],Ask+100*_Point);
   }
   else if (SAR_Data[0] > high0 && SAR_Data[1] < low1 && signalTime != currTime0){
      Print("SELL SIGNAL @ ",TimeCurrent());
      signalTime = currTime0;
      obj_Trade.Sell(0.01,_Symbol,Bid,SAR_Data[0],Bid-100*_Point);
   }
}
//+------------------------------------------------------------------+
