//+------------------------------------------------------------------+
//|                                          Cascade Ordering EA.mq5 |
//|                                  Copyright 2023, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2023, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"

#include <Trade/Trade.mqh>
CTrade obj_Trade;

int handleMAFast;
int handleMASlow;

double maFast[],maSlow[];

input double LOT = 0.1;
input int tpPts = 300;
input int slPts = 300;
input int slPts_min = 100;

double takeProfit = 0;
double stopLoss = 0;

bool isBuySystemInitiated = false;
bool isSellSystemInitiated = false;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit(){
   
   handleMAFast = iMA(_Symbol,_Period,10,0,MODE_EMA,PRICE_CLOSE);
   if (handleMAFast == INVALID_HANDLE){
      Print("UNABLE TO LOAD FAST MA, REVERTING NOW");
      return (INIT_FAILED);
   }
   handleMASlow = iMA(_Symbol,_Period,20,0,MODE_EMA,PRICE_CLOSE);
   if (handleMASlow == INVALID_HANDLE){
      Print("UNABLE TO LOAD SLOW MA, REVERTING NOW");
      return (INIT_FAILED);
   }
   
   ArraySetAsSeries(maFast,true);
   ArraySetAsSeries(maSlow,true);

   return(INIT_SUCCEEDED);
}
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason){

   IndicatorRelease(handleMAFast);
   IndicatorRelease(handleMASlow);
}
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick(){
   
   double Ask = NormalizeDouble(SymbolInfoDouble(_Symbol,SYMBOL_ASK),_Digits);
   double Bid = NormalizeDouble(SymbolInfoDouble(_Symbol,SYMBOL_BID),_Digits);

   if (CopyBuffer(handleMAFast,0,1,3,maFast) < 3){
      Print("NO ENOUGH DATA FROM FAST MA FOR FURTHER ANALYSIS. REVERTING NOW");
      return;
   }
   if (CopyBuffer(handleMASlow,0,1,3,maSlow) < 3){
      Print("NO ENOUGH DATA FROM slow MA FOR FURTHER ANALYSIS. REVERTING NOW");
      return;
   }
   
   if (PositionsTotal()==0){
      isBuySystemInitiated = false; isSellSystemInitiated = false;
   }
   
   //ArrayPrint(maFast,6);
   if (PositionsTotal() == 0 && IsNewBar()){
      if (maFast[0] > maSlow[0] && maFast[1] < maSlow[1]){
         Print("BUY SIGNAL");
         takeProfit = Ask + tpPts*_Point;
         stopLoss = Ask - slPts*_Point;
         obj_Trade.Buy(LOT,_Symbol,Ask,stopLoss,0);
         isBuySystemInitiated = true;
      }
      
      else if (maFast[0] < maSlow[0] && maFast[1] > maSlow[1]){
         Print("SELL SIGNAL");
         takeProfit = Bid - tpPts*_Point;
         stopLoss = Bid + slPts*_Point;
         obj_Trade.Sell(LOT,_Symbol,Bid,stopLoss,0);
         isSellSystemInitiated = true;
      }
   }
   
   else {
      if (isBuySystemInitiated && Ask >= takeProfit){
         Print("(Buy) WE ARE ABOVE THE TP LEVEL OF ",takeProfit);
         takeProfit = takeProfit + tpPts*_Point;
         stopLoss = Ask - slPts_min*_Point;
         obj_Trade.Buy(LOT,_Symbol,Ask,0);
         // we need to modify the positions here afterwards to set the sl
         ModifyTrades(POSITION_TYPE_BUY,stopLoss);
      }
      else if (isSellSystemInitiated && Bid <= takeProfit){
         Print("(Sell) WE ARE BELOW THE TP LEVEL OF ",takeProfit);
         takeProfit = takeProfit - tpPts*_Point;
         stopLoss = Bid + slPts_min*_Point;
         obj_Trade.Sell(LOT,_Symbol,Bid,0);
         // we need to modify the positions here afterwards to set the sl
         ModifyTrades(POSITION_TYPE_SELL,stopLoss);
      }
   }
   
}
//+------------------------------------------------------------------+

bool IsNewBar(){
   static int prevBars = 0;
   int currBars = iBars(_Symbol,_Period);
   if (prevBars == currBars) return (false);
   prevBars = currBars;
   return (true);
}

void ModifyTrades(ENUM_POSITION_TYPE posType,double sl){
   for (int i=0; i<=PositionsTotal(); i++){
      ulong ticket = PositionGetTicket(i);
      if (ticket > 0){
         if (PositionSelectByTicket(ticket)){
            ENUM_POSITION_TYPE type = (ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE);
            if(type == posType){
               obj_Trade.PositionModify(ticket,sl,0);
            }
         }
      }
   }
}