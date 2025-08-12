//+------------------------------------------------------------------+
//|                                            AI RSI BB SCALPER.mq5 |
//|                                                           Alfr5d |
//|                                       https://www.49design.co.za |
//+------------------------------------------------------------------+

#property copyright   "Copyright 2023, Alfred Mandala. "
#property description "www.billionairebulls.co.za\n"
#property version     "1.5"
#property description "RSI GRID SCALPING EA, TIMEFRAME = M5 \nLOW RISK : RsiPeriods = 18; RsiSellTrigger = 70; RsiSellTrigger = 30; TpPoints = 212;"


#include <Trade/Trade.mqh>

/*    

      RSI GRID EA SETTINGS MODES
      
      LOW RISK SETINGS
      RsiPeriods     = 9;
      RsiSellTrigger = 80;
      RsiSellTrigger = 35;
      TpPoints       = 212;
      
      MEDIUM RISK SETINGS
      RsiPeriods     = 7;
      RsiSellTrigger = 80;
      RsiSellTrigger = 40;
      TpPoints       = 211;
      
      HIGH RISK SETINGS
      RsiPeriods     = 5;
      RsiSellTrigger = 85;
      RsiSellTrigger = 40;
      TpPoints       = 212;
*/

// ---- INPUTS ----
input group "--- Trading Inputs ---";
input double Lots                    = 0.01;           // Lot Size
input int TpPoints                   = 50;             // Take Profit in points [m5-50p, h1-200p]
input ENUM_TIMEFRAMES RsiTimeFrame   = PERIOD_CURRENT; // Timeframe


input group "--- RSI Inputs ---";
input int RsiPeriods                 = 18;            // RSI Period
input ENUM_APPLIED_PRICE RsiAppPrice = PRICE_CLOSE;   // RSI Applied Price
input double RsiSellTrigger          = 70;            // RSI Sell Zone
input double RsiBuyTrigger           = 30;            // RSI Buy Zone

input group "--- Bollinger Bands Inputs ---";
input int         BbPeriods          =  23;   // BB Periods
input double      BbDeviation        =  2.0;   // Deviation
input double      BbShift            =  0;   // Shift


// ---- GLOBAL VARIABLES ----

int handleRsi;
int handleBb;
double rsi[];

CTrade trade;

int barsTotal;

// ---- EXPERT INIT ----

int OnInit()
{

   handleRsi = iRSI(_Symbol,RsiTimeFrame,RsiPeriods,RsiAppPrice);
   handleBb  = iBands(_Symbol,PERIOD_CURRENT,BbPeriods,0,BbDeviation,PRICE_CLOSE);
   

   return(INIT_SUCCEEDED);
  }
  
// ---- EXPERT DEINIT ----

void OnDeinit(const int reason){

   IndicatorRelease(handleBb);
   IndicatorRelease(handleRsi);
}

// ---- ON TICK FUNCTION ----

void OnTick()
{
   int bars = iBars(_Symbol,RsiTimeFrame);
   if(barsTotal != bars){
   barsTotal = bars;
   
   double bid = SymbolInfoDouble(_Symbol,SYMBOL_BID);
   
   double bbUpper[];
   double bbLower[];
   CopyBuffer(handleBb,1,0,1,bbUpper);
   CopyBuffer(handleBb,2,0,1,bbLower);
   

   CopyBuffer(handleRsi,MAIN_LINE,1,2,rsi);
   
   if(rsi[1] > RsiSellTrigger && rsi[0] < RsiSellTrigger){
     if(bid >= bbUpper[0]){
      Print(__FUNCTION__," > SELL Signal...");
   //Sell signal
   trade.Sell(Lots);
      }
   }else  if(rsi[1] < RsiBuyTrigger && rsi[0] > RsiBuyTrigger){
      if(bid <= bbLower[0]){
      Print(__FUNCTION__," > BUY Signal...");
   //Buy signal
   trade.Buy(Lots);
      }
   }
   
   }
   
   //loop through open positions
   int pointsBuy = 0;
   int pointsSell = 0;
   for(int i = PositionsTotal()-1; i>=0; i--){
      ulong posTicket = PositionGetTicket(i);
      if(PositionSelectByTicket(posTicket)){
         ENUM_POSITION_TYPE posType = (ENUM_POSITION_TYPE) PositionGetInteger(POSITION_TYPE);
         double posOpenPrice = PositionGetDouble(POSITION_PRICE_OPEN);
         
         double bid = SymbolInfoDouble(_Symbol,SYMBOL_BID);
         double ask = SymbolInfoDouble(_Symbol,SYMBOL_ASK);
         if(posType == POSITION_TYPE_BUY){
         pointsBuy += (int)((bid - posOpenPrice) / _Point);
         
         }else if(posType == POSITION_TYPE_SELL){
         pointsSell += (int)((posOpenPrice - ask) / _Point);
         
         }
      
      }
   }
   
   for(int i = PositionsTotal()-1; i>=0; i--){
      ulong posTicket = PositionGetTicket(i);
      if(PositionSelectByTicket(posTicket)){
         ENUM_POSITION_TYPE posType = (ENUM_POSITION_TYPE) PositionGetInteger(POSITION_TYPE);
   
         if(pointsBuy > TpPoints){
         //close buy positions
            if(posType == POSITION_TYPE_BUY){
               trade.PositionClose(posTicket);
            }
         }
         if(pointsSell > TpPoints){
         //close sell positions
         if(posType == POSITION_TYPE_SELL){
               trade.PositionClose(posTicket);
            }
         }
      }
   }
   
   Comment("\nRSI[0]: ",DoubleToString(rsi[0],5),
           "\nRSI[1]: ",DoubleToString(rsi[1],5),
           "\nPoints Buy: ",pointsBuy,
           "\nPoints Sell: ",pointsSell);
}