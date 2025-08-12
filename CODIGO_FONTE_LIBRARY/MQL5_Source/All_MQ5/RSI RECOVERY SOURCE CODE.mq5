//+------------------------------------------------------------------+
//|                                                 RSI RECOVERY.mq5 |
//|                                  Copyright 2024, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+

#property copyright "Copyright 2024, Simple Forex Tools"
#property link      "https://t.me/simpleforextools"
#property description "RSI Recovery - Martingale Strategy"
#property version   "1.0"
#property strict

#include <Trade/trade.mqh>
CTrade obj_Trade;

string ZONE_L = "ZL";
string ZONE_H ="ZH";
string ZONE_T_H = "ZTH";
string ZONE_T_L ="ZTL";

input string SimpleForexTeam__ = "free tools for forex! Join our channel for more free eas";
input string The_our_telegram = "https://t.me/simpleforextools";
input string The_best_VPS = "https://t.me/simpleforextools/2290";
input double LotSize = 0.01;              //Lot Size
input double CloseWhenInProfit = 20;     // Close all trades when in profit of x $
input double sellzone=100;
input double buyzone=35;
input ENUM_TIMEFRAMES RsiTimeframe= PERIOD_M1;
input int RsiPeriod=14;
input ENUM_APPLIED_PRICE RsiAppliedPrice=PRICE_CLOSE;
input int InpMagicNumber =897654;    //Magic Number

int handleRsi;
double Rsi[];
int barsTotal=0;
double zoneLow=0;
double zoneHigh=0;
double zoneTargetLow=0;
double zoneTargetHigh=0;


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnInit()
  {
   obj_Trade.SetExpertMagicNumber(InpMagicNumber);
   handleRsi=iRSI(_Symbol,RsiTimeframe,RsiPeriod,RsiAppliedPrice);
//---
   return(INIT_SUCCEEDED);
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnTick()
  {
   double zoneRange=2000*_Point;
   double zoneTarget=4000*_Point;

   int bars=iBars(_Symbol,RsiTimeframe);
   if(barsTotal==bars)
      return;
   barsTotal=bars;
   if(!CopyBuffer(handleRsi,0,1,2,Rsi))
      return;

   if(Rsi[1]<buyzone &&Rsi[0]>buyzone)
     {
      //Print("buy signal");
      obj_Trade.Buy(LotSize);

      ulong PosTkt=obj_Trade.ResultOrder();
      if(PosTkt>0)
        {
         if(PositionSelectByTicket(PosTkt))
           {
            double OpenPrice= PositionGetDouble(POSITION_PRICE_OPEN);
            zoneHigh= NormalizeDouble(OpenPrice,_Digits);
            zoneLow= NormalizeDouble(zoneHigh-zoneRange,_Digits);
            zoneTargetHigh= NormalizeDouble(zoneHigh+zoneTarget,_Digits);
            zoneTargetLow=NormalizeDouble(zoneLow-zoneTarget,_Digits);
            
              drawZoneLevel(ZONE_H,zoneHigh,clrCyan,2);
              drawZoneLevel(ZONE_L,zoneLow,clrCyan,2);             
              drawZoneLevel(ZONE_T_H,zoneTargetHigh,clrBlue,2); 
              drawZoneLevel(ZONE_T_L,zoneTargetLow,clrBlue,2);
           }
        }
     }
   else
      if(Rsi[1]>sellzone &&Rsi[0]<sellzone)
        {
         //Print("sell signal");
         obj_Trade.Sell(LotSize);
         ulong PosTkt=obj_Trade.ResultOrder();
         if(PosTkt>0)
           {
            if(PositionSelectByTicket(PosTkt))
              {
               double OpenPrice= PositionGetDouble(POSITION_PRICE_OPEN);
               zoneLow= NormalizeDouble(OpenPrice,_Digits);
               zoneHigh= NormalizeDouble(zoneLow+zoneRange,_Digits);
               zoneTargetHigh= NormalizeDouble(zoneHigh+zoneTarget,_Digits);
               zoneTargetLow=NormalizeDouble(zoneLow-zoneTarget,_Digits);

              }
           }
        }
   //Print("Z_H=",zoneHigh,",Z_T_H=",zoneTargetHigh,",Z_L=",zoneLow,",Z_T_L=",zoneTargetLow);
   
   if(GetPositionProfit() >= CloseWhenInProfit)
      CloseAllBuySell();
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void drawZoneLevel(string LevelName,double Price,color clr,int Width)
  {
   ObjectCreate(0,LevelName,OBJ_HLINE,0,TimeCurrent(),Price);
   ObjectSetInteger(0,LevelName,OBJPROP_COLOR,clr);
   ObjectSetInteger(0,LevelName,OBJPROP_WIDTH,Width);
    }


void CloseAllBuySell(ENUM_POSITION_TYPE PosType = NULL)
{
    int total = PositionsTotal();

    // Start a loop to scan all the positions.
    // The loop starts from the last, otherwise it could skip positions.
    for (int i = total - 1; i >= 0; i--)
    {
        // If the position cannot be selected log an error.
        if (PositionGetSymbol(i) == "")
        {
            PrintFormat(__FUNCTION__, ": ERROR - Unable to select the position - %s - %d.", GetLastError());
            continue;
        }
        if (PositionGetString(POSITION_SYMBOL) != Symbol()) continue; // Only close current symbol trades.
        if (PositionGetInteger(POSITION_MAGIC) != InpMagicNumber) continue; // Only close own positions.
        if (PositionGetInteger(POSITION_TYPE) != PosType && PosType != NULL) continue; // Only close Buy positions.

        for (int try = 0; try < 10; try++)
        {
            bool result = obj_Trade.PositionClose(PositionGetInteger(POSITION_TICKET));
            if (!result)
            {
                PrintFormat(__FUNCTION__, ": ERROR - Unable to close position: %s - %d", obj_Trade.ResultRetcodeDescription(), obj_Trade.ResultRetcode());
            }
            else break;
        }
    }
}


// Get Positions Profit.
double GetPositionProfit()
{
   double posProfit  = 0;
   int posTotal   = PositionsTotal();
   for(int i = posTotal-1; i>=0; i--) {
      ulong posTicket   = PositionGetTicket(i);
      if(PositionSelectByTicket(posTicket)) {
         ulong posMagic    = PositionGetInteger(POSITION_MAGIC);
         string posSymbol  = PositionGetString(POSITION_SYMBOL);
         if(posSymbol == _Symbol && posMagic == InpMagicNumber) {
            posProfit  += PositionGetDouble(POSITION_PROFIT); 
         
         }
      
      }
   }
   return   posProfit;   

}