//+------------------------------------------------------------------+
//|                                    Basic Harmonic Pattern EA.mq5 |
//|                                  Copyright 2024, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, mutiiriallan.forex@gmail.com."
#property link      "mutiiriallan.forex@gmail.com"
#property description "Incase of anything with this Version of EA, Contact:\n"
                      "\nEMAIL: mutiiriallan.forex@gmail.com"
                      "\nWhatsApp: +254 782 526088"
                      "\nTelegram: https://t.me/Forex_Algo_Trader"
#property version   "1.00"

#include <Trade/Trade.mqh>
CTrade obj_Trade;

int handle_BHP = INVALID_HANDLE; // -1

double signalBuy[], signalSell[];
double tp1[], tp2[], tp3[], sl0[];

double currBuy, currSell;
double currSl, currTP1, currTP2, currTP3;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit(){
   
   handle_BHP = iCustom(_Symbol,_Period,"Market//Basic Harmonic Pattern MT5");
   
   if (handle_BHP == INVALID_HANDLE){
      Print("UNABLE TO INITIALIZE THE IND CORRECTLY. REVERTING NOW.");
      return (INIT_FAILED);
   }
   
   ArraySetAsSeries(signalBuy,true);
   ArraySetAsSeries(signalSell,true);
   
   return(INIT_SUCCEEDED);
}
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
void OnTick(){
   
   if (CopyBuffer(handle_BHP,0,1,1,signalBuy) < 1){ // buy buffer = 6
      Print("UNABLE TO GET ENOUGH REQUESTED DATA FOR BUY SIG'. REVERTING.");
      return;
   }
   if (CopyBuffer(handle_BHP,1,1,1,signalSell) < 1){ // sell buffer = 7
      Print("UNABLE TO GET ENOUGH REQUESTED DATA FOR SELL SIG'. REVERTING.");
      return;
   }
   
   if (CopyBuffer(handle_BHP,2,1,1,sl0) < 1){
      Print("UNABLE TO GET ENOUGH REQUESTED DATA FOR SL. REVERTING.");
      return;
   }
   
   if (CopyBuffer(handle_BHP,3,1,1,tp1) < 1){
      Print("UNABLE TO GET ENOUGH REQUESTED DATA FOR TP1. REVERTING.");
      return;
   }
   if (CopyBuffer(handle_BHP,4,1,1,tp2) < 1){
      Print("UNABLE TO GET ENOUGH REQUESTED DATA FOR TP2. REVERTING.");
      return;
   }
   if (CopyBuffer(handle_BHP,5,1,1,tp3) < 1){
      Print("UNABLE TO GET ENOUGH REQUESTED DATA FOR TP3. REVERTING.");
      return;
   }
   
   int currBars = iBars(_Symbol,_Period);
   static int prevBars = currBars;
   if (prevBars == currBars) return;
   prevBars = currBars;
   
   
   //Print(signalBuy[0]," > ",signalSell[0]);
   //Print(DBL_MAX);
   //Print(EMPTY_VALUE);
   
   if (signalBuy[0] != EMPTY_VALUE && signalBuy[0] != currBuy){
      Print("BUY = ",signalBuy[0]);
      Print("SL = ",sl0[0],", TP1 = ",tp1[0],", TP2 = ",tp2[0],", TP3 = ",tp3[0]);
      
      currBuy = signalBuy[0];
      currSl = sl0[0]; currTP1 = tp1[0]; currTP2 = tp2[0]; currTP3 = tp3[0];
      
      obj_Trade.Buy(0.01,_Symbol,currBuy,currSl,currTP3);
   }
   
   else if (signalSell[0] != EMPTY_VALUE && signalSell[0] != currSell){
      Print("SELL = ",signalSell[0]);
      Print("SL = ",sl0[0],", TP1 = ",tp1[0],", TP2 = ",tp2[0],", TP3 = ",tp3[0]);
      
      currSell = signalSell[0];
      currSl = sl0[0]; currTP1 = tp1[0]; currTP2 = tp2[0]; currTP3 = tp3[0];
      
      obj_Trade.Sell(0.01,_Symbol,currSell,currSl,currTP3);
   }

}
//+------------------------------------------------------------------+
