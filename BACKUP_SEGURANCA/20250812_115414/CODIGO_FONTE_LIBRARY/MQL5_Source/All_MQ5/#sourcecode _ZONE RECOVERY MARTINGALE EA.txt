//+------------------------------------------------------------------+
//|                                                MARTINGALE EA.mq5 |
//|                                  Copyright 2023, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2023, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"

#define ZONE_H "ZH"
#define ZONE_L "ZL"
#define ZONE_T_H "ZTH"
#define ZONE_T_L "ZTL"

#include <Trade/Trade.mqh>
CTrade obj_trade;

int rsi_handle;
double rsiData[];
int totalBars = 0;

double overBoughtLevel = 70.0, overSoldLevel = 30.0;
double zoneHigh = 0, zoneLow = 0, zoneTargetHigh = 0, zoneTargetLow = 0;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   rsi_handle = iRSI(_Symbol,PERIOD_CURRENT,14,PRICE_CLOSE);
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
   IndicatorRelease(rsi_handle);
   ArrayFree(rsiData);
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---
   double ask = SymbolInfoDouble(_Symbol,SYMBOL_ASK);
   double bid = SymbolInfoDouble(_Symbol,SYMBOL_BID);
   double zoneRange = 200*_Point;
   double zoneTarget = 400*_Point;
   
   //double highestLotSize = 0;
   
   static int lastDirection = 0; // -1=sell, 1=buy
   static double recovery_lot = 0;
   static bool isBuyDone=NULL, isSellDone=NULL;
         
      if (zoneTargetHigh > 0 && zoneTargetLow > 0){
         if (bid > zoneTargetHigh || bid < zoneTargetLow){
            deleteZoneLevels();
            for (int i=PositionsTotal()-1; i>=0; i--){
               ulong ticket = PositionGetTicket(i);
               if (ticket > 0){
                  if (PositionSelectByTicket(ticket)){
                     obj_trade.PositionClose(ticket);
                  }
               }
            }
            // after we close all the positions, reset all
            zoneHigh=0;zoneLow=0;zoneTargetHigh=0;zoneTargetLow=0;
            lastDirection = 0;
            recovery_lot = 0;
            isBuyDone=false; isSellDone=false;
         }
      }
   
   if (zoneHigh > 0 && zoneLow > 0){
      double lots_Rec = 0;
      lots_Rec = NormalizeDouble(recovery_lot,2);
      if (bid > zoneHigh){
         if (isBuyDone == false || lastDirection < 0){ // last direction was a sell, so we open buy rec
            obj_trade.Buy(lots_Rec);
            
            lastDirection = 1;
            recovery_lot = recovery_lot*2;
            isBuyDone=true; isSellDone=false;
         }
      }
      else if (bid < zoneLow){
         if (isSellDone==false || lastDirection > 0){
            obj_trade.Sell(lots_Rec);
            
            lastDirection = -1; //last direction is a sell pos
            recovery_lot = recovery_lot*2;
            isBuyDone=false; isSellDone=true;
         }
      }
   }
   
   int bars = iBars(_Symbol,PERIOD_CURRENT);
   if (totalBars == bars) return;
   totalBars = bars;
   
   if (PositionsTotal() > 0) return;
   
   if (!CopyBuffer(rsi_handle,0,1,2,rsiData)) return;
   
   if (rsiData[1] < overSoldLevel && rsiData[0] > overSoldLevel){
      obj_trade.Buy(0.01);
      ulong pos_ticket = obj_trade.ResultOrder();
      if (pos_ticket > 0){
         if (PositionSelectByTicket(pos_ticket)){
            double openPrice = PositionGetDouble(POSITION_PRICE_OPEN);
            zoneHigh = NormalizeDouble(openPrice,_Digits);
            zoneLow = NormalizeDouble(zoneHigh - zoneRange,_Digits);
            zoneTargetHigh = NormalizeDouble(zoneHigh + zoneTarget,_Digits);
            zoneTargetLow = NormalizeDouble(zoneLow - zoneTarget,_Digits);
            drawZoneLevel(ZONE_H,zoneHigh,clrLime,2);
            drawZoneLevel(ZONE_L,zoneLow,clrOrange,2);
            drawZoneLevel(ZONE_T_H,zoneTargetHigh,clrCyan,3);
            drawZoneLevel(ZONE_T_L,zoneTargetLow,clrCyan,3);
            
            lastDirection = 1; // last dir is a buy
            recovery_lot = 0.01*2;
            isBuyDone=true; isSellDone=false;

         }
      }
   }
   else if (rsiData[1] > overBoughtLevel && rsiData[0] < overBoughtLevel){
      obj_trade.Sell(0.01);
      ulong pos_ticket = obj_trade.ResultOrder();
      if (pos_ticket > 0){
         if (PositionSelectByTicket(pos_ticket)){
            double openPrice = PositionGetDouble(POSITION_PRICE_OPEN);
            zoneLow = NormalizeDouble(openPrice,_Digits);
            zoneHigh = NormalizeDouble(zoneLow + zoneRange,_Digits);
            zoneTargetHigh = NormalizeDouble(zoneHigh + zoneTarget,_Digits);
            zoneTargetLow = NormalizeDouble(zoneLow - zoneTarget,_Digits);
            drawZoneLevel(ZONE_H,zoneHigh,clrLime,2);
            drawZoneLevel(ZONE_L,zoneLow,clrOrange,2);
            drawZoneLevel(ZONE_T_H,zoneTargetHigh,clrCyan,3);
            drawZoneLevel(ZONE_T_L,zoneTargetLow,clrCyan,3);
            
            lastDirection = -1; // sell is the last dir
            recovery_lot = 0.01*2;
            isBuyDone=false; isSellDone=true;
         }
      }
   }
   //Print("Z-H = ",zoneHigh,", Z-L = ",zoneLow, ", Z T H = ", zoneTargetHigh,
   //    ", Z T L = ",zoneTargetLow);
  }
//+------------------------------------------------------------------+

void drawZoneLevel(string levelName, double price,color clr,int width){
   ObjectCreate(0,levelName,OBJ_HLINE,0,TimeCurrent(),price);
   ObjectSetInteger(0,levelName,OBJPROP_COLOR,clr);
   ObjectSetInteger(0,levelName,OBJPROP_WIDTH,width);
}

void deleteZoneLevels(){
   ObjectDelete(0,ZONE_H);
   ObjectDelete(0,ZONE_L);
   ObjectDelete(0,ZONE_T_H);
   ObjectDelete(0,ZONE_T_L);
}