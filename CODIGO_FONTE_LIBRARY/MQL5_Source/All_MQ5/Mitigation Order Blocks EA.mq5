//+------------------------------------------------------------------+
//|                                   Mitigation Order Blocks EA.mq5 |
//|                                  Copyright 2025, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2025, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"

#include <Trade/Trade.mqh>
CTrade obj_Trade;

input double tradeLotSize = 0.01;
input bool enableTrading = true;
input bool enableTrailingStop = true;
input double trailingStopPoints = 30;
input double minProfitToTrail = 50;
input int uniqueMagicNumber = 1234567;
input int consolidationBars = 7;
input double maxconsolidationSpread = 50;
input int barstowaitafterbreakout = 3;
input double impulseMultiplier = 1.0;
input double stoplossDistance = 1500;
input double takeProfitdistance = 1500;
input color bullishOrderBlockColor = clrGreen;
input color bearishOrderBlockColor = clrRed;
input color mitigatedOrderBlockColor = clrGray;
input color labelTextColor = clrBlack;

struct PriceAndIndex{
   double price;
   int index;
};

PriceAndIndex rangeHighestHigh = {0,0};
PriceAndIndex rangeLowestLow = {0,0};
bool isBreakoutDetected = false;
double lastImpulseLow = 0.0;
double lastImpulseHigh = 0.0;
int breakoutBarNumber = -1;
datetime breakoutTimestamp = 0;
string orderBlockNames[];
string orderBlockLabels[];
datetime orderBlockEndTimes[];
bool orderblockMitigatedStatus[];
bool isBullishImpulse = false;
bool isBearishImpulse = false;

#define OB_Prefix "OB REC "


//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit(){
//---
   obj_Trade.SetExpertMagicNumber(uniqueMagicNumber);
//---
   return(INIT_SUCCEEDED);
}
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason){
//---
   
}
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick(){
//---
   
   if (enableTrailingStop){
      applyTrailingStop(trailingStopPoints,obj_Trade,uniqueMagicNumber);
   }
   
   static bool isNewBar = false;
   int currentBarCount = iBars(_Symbol,_Period);
   static int previousBarCount = currentBarCount;
   if (previousBarCount == currentBarCount){
      isNewBar = false;
   }
   else if (previousBarCount != currentBarCount){
      isNewBar = true;
      previousBarCount = currentBarCount;
   }
   
   if (!isNewBar){
      return;
   }
   
   int startBarIndex = 1;
   
   int chartscale = (int)ChartGetInteger(0,CHART_SCALE);
   int dynamicFontSize = 8+(chartscale*2);
   
   if (!isBreakoutDetected){
      if (rangeHighestHigh.price == 0 && rangeLowestLow.price == 0){
         bool isConsolidated = true;
         for (int i=startBarIndex; i<startBarIndex+consolidationBars-1; i++){
            if (MathAbs(high(i) - high(i+1)) > maxconsolidationSpread * _Point){
               isConsolidated = false;
               break;
            }
            if (MathAbs(low(i) - low(i+1)) > maxconsolidationSpread * _Point){
               isConsolidated = false;
               break;
            }
         }
         if (isConsolidated){
            rangeHighestHigh.price = high(startBarIndex);
            rangeHighestHigh.index = startBarIndex;
            for (int i=startBarIndex+1; i<startBarIndex+consolidationBars; i++){
               if (high(i) > rangeHighestHigh.price){
                  rangeHighestHigh.price = high(i);
                  rangeHighestHigh.index = i;
               }
            }
            rangeLowestLow.price = low(startBarIndex);
            rangeLowestLow.index = startBarIndex;
            for (int i=startBarIndex+1; i<startBarIndex+consolidationBars; i++){
               if (low(i) < rangeLowestLow.price){
                  rangeLowestLow.price = low(i);
                  rangeLowestLow.index = i;
               }
            }
            Print("Consolidation Range Established./nHighest High: ",rangeHighestHigh.price,
            ", Lowest Low: ",rangeLowestLow.price);
         }
      }
      else {
         double currentHigh = high(1);
         double currentLow = low(1);
         if (currentHigh <= rangeHighestHigh.price && currentLow >= rangeLowestLow.price){
            Print("Range EXTENDED: High = ",currentHigh, ", Low = ",currentLow);
         }
         else {
            Print("No extension: Bar outside range.");
         }
      }
   }
   
   if (rangeHighestHigh.price > 0 && rangeLowestLow.price > 0){
      double currentClosePrice = close(1);
      if (currentClosePrice > rangeHighestHigh.price){
         Print("Upward Breakout at ",currentClosePrice, " > ",rangeHighestHigh.price);
         isBreakoutDetected = true;
      }
      else if (currentClosePrice < rangeLowestLow.price){
         Print("Downward Breakout at ",currentClosePrice, " < ",rangeLowestLow.price);
         isBreakoutDetected = true;
      }
   }
   
   if (isBreakoutDetected){
      Print("Breakout detected. Resetting for the next range.");
      breakoutBarNumber = 1;
      breakoutTimestamp = TimeCurrent();
      lastImpulseHigh = rangeHighestHigh.price;
      lastImpulseLow = rangeLowestLow.price;
      isBreakoutDetected = false;
      rangeHighestHigh.price = 0;
      rangeLowestLow.price = 0;
      rangeHighestHigh.index = 0;
      rangeLowestLow.index = 0;
   }
   
   if (breakoutBarNumber >= 0 && TimeCurrent() > breakoutTimestamp+barstowaitafterbreakout*PeriodSeconds()){
      double impulseRange = lastImpulseHigh - lastImpulseLow;
      double impulseThresholdPrice = impulseRange * impulseMultiplier;
      isBullishImpulse = false;
      isBearishImpulse = false;
      
      for (int i=1; i<=barstowaitafterbreakout; i++){
         double closePrice = close(i);
         if (closePrice >= lastImpulseHigh+impulseThresholdPrice){
            isBullishImpulse = true;
            Print("Impulsive upward move: ",closePrice," >= ",lastImpulseHigh+impulseThresholdPrice);
            break;
         }
         else if (closePrice <= lastImpulseLow-impulseThresholdPrice){
            isBearishImpulse = true;
            Print("Impulsive downward move: ",closePrice," <= ",lastImpulseLow-impulseThresholdPrice);
            break;
         }
      }
      
      if (!isBullishImpulse && !isBearishImpulse){
         Print("No impulsive movement detected.");
      }
      
      bool isOrderBlockValid = isBearishImpulse || isBullishImpulse;
      
      if (isOrderBlockValid){
         datetime blockStartTime = iTime(_Symbol,_Period,consolidationBars+barstowaitafterbreakout+1);
         double blockTopPrice = lastImpulseHigh;
         int visibleBarsOnchart = (int)ChartGetInteger(0,CHART_VISIBLE_BARS);
         datetime blockEndTime = blockStartTime+(visibleBarsOnchart/1)*PeriodSeconds();
         double blockBottomPrice = lastImpulseLow;
         string orderBlockName = OB_Prefix+"("+TimeToString(blockStartTime)+")";
         color orderBlockColor = isBullishImpulse ? bullishOrderBlockColor : bearishOrderBlockColor;
         string orderBlockLabel = isBullishImpulse ? "Bullish OB" : "Bearish OB";
         
         if (ObjectFind(0, orderBlockName) < 0){
            ObjectCreate(0,orderBlockName,OBJ_RECTANGLE,0,blockStartTime,blockTopPrice,blockEndTime,blockBottomPrice);
            ObjectSetInteger(0,orderBlockName,OBJPROP_TIME,0,blockStartTime);
            ObjectSetDouble(0,orderBlockName,OBJPROP_PRICE,0,blockTopPrice);
            ObjectSetInteger(0,orderBlockName,OBJPROP_TIME,1,blockEndTime);
            ObjectSetDouble(0,orderBlockName,OBJPROP_PRICE,1,blockBottomPrice);
            ObjectSetInteger(0,orderBlockName,OBJPROP_FILL,true);
            ObjectSetInteger(0,orderBlockName,OBJPROP_COLOR,orderBlockColor);
            ObjectSetInteger(0,orderBlockName,OBJPROP_BACK,false);
            
            datetime labelTime = blockStartTime + (blockEndTime-blockStartTime)/2;
            double labelPrice = (blockTopPrice+blockBottomPrice)/2;
            string labelObjectName = orderBlockName+orderBlockLabel;
            if (ObjectFind(0,labelObjectName) < 0){
               ObjectCreate(0,labelObjectName,OBJ_TEXT,0,labelTime,labelPrice);
               ObjectSetString(0,labelObjectName,OBJPROP_TEXT,orderBlockLabel);
               ObjectSetInteger(0,labelObjectName,OBJPROP_COLOR,labelTextColor);
               ObjectSetInteger(0,labelObjectName,OBJPROP_ANCHOR,ANCHOR_CENTER);
               ObjectSetInteger(0,labelObjectName,OBJPROP_FONTSIZE,dynamicFontSize);
            }
            ChartRedraw(0);
            
            ArrayResize(orderBlockNames,ArraySize(orderBlockNames)+1);
            orderBlockNames[ArraySize(orderBlockNames)-1] = orderBlockName;
            ArrayResize(orderBlockLabels,ArraySize(orderBlockLabels)+1);
            orderBlockLabels[ArraySize(orderBlockLabels)-1] = labelObjectName;
            ArrayResize(orderBlockEndTimes,ArraySize(orderBlockEndTimes)+1);
            orderBlockEndTimes[ArraySize(orderBlockEndTimes)-1] = blockEndTime;
            ArrayResize(orderblockMitigatedStatus,ArraySize(orderblockMitigatedStatus)+1);
            orderblockMitigatedStatus[ArraySize(orderblockMitigatedStatus)-1] = false;
                        
            Print("Order Block created: ",orderBlockName);
         }
      }
      breakoutBarNumber = -1;
      breakoutTimestamp = 0;
      lastImpulseHigh = 0;
      lastImpulseLow = 0;
      isBullishImpulse = false;
      isBearishImpulse = false;
   }
   
   for (int j=ArraySize(orderBlockNames)-1; j>=0; j--){
      string currentOrderBlockName = orderBlockNames[j];
      string currentOrderBlockLabel = orderBlockLabels[j];
      bool doesOrderBlockExist = false;
      
      double orderBlockHigh = ObjectGetDouble(0,currentOrderBlockName,OBJPROP_PRICE,0);
      double orderBlockLow = ObjectGetDouble(0,currentOrderBlockName,OBJPROP_PRICE,1);
      datetime orderBlockStartTime = (datetime)ObjectGetInteger(0,currentOrderBlockName,OBJPROP_TIME,0);
      datetime orderBlockEndTime = (datetime)ObjectGetInteger(0,currentOrderBlockName,OBJPROP_TIME,1);
      color orderBlockCurrentColor = (color)ObjectGetInteger(0,currentOrderBlockName,OBJPROP_COLOR);
      
      if (time(1) < orderBlockEndTime){
         doesOrderBlockExist = true;
      }
      
      double currentAskPrice = NormalizeDouble(SymbolInfoDouble(_Symbol,SYMBOL_ASK),_Digits);
      double currentBidPrice = NormalizeDouble(SymbolInfoDouble(_Symbol,SYMBOL_BID),_Digits);
      
      if (enableTrading && orderBlockCurrentColor == bullishOrderBlockColor && close(1) < orderBlockLow && !orderblockMitigatedStatus[j]){
         double entryPrice = currentBidPrice;
         double stoplossPrice = entryPrice+stoplossDistance*_Point;
         double takeprofitPrice = entryPrice-takeProfitdistance*_Point;
         obj_Trade.Sell(tradeLotSize,_Symbol,entryPrice,stoplossPrice,takeprofitPrice);
         orderblockMitigatedStatus[j] = true;
         ObjectSetInteger(0,currentOrderBlockName,OBJPROP_COLOR,mitigatedOrderBlockColor);
         string blockDescription = "Bullish Order Block";
         string textObjectName = currentOrderBlockName+blockDescription;
         ObjectSetString(0,currentOrderBlockLabel,OBJPROP_TEXT,"Mitigated "+blockDescription);
         
         Print("Sell trade entered upon mitigation of the bullish OB: ",currentOrderBlockName);
      }
      else if (enableTrading && orderBlockCurrentColor == bearishOrderBlockColor && close(1) > orderBlockHigh && !orderblockMitigatedStatus[j]){
         double entryPrice = currentAskPrice;
         double stoplossPrice = entryPrice-stoplossDistance*_Point;
         double takeprofitPrice = entryPrice+takeProfitdistance*_Point;
         obj_Trade.Buy(tradeLotSize,_Symbol,entryPrice,stoplossPrice,takeprofitPrice);
         orderblockMitigatedStatus[j] = true;
         ObjectSetInteger(0,currentOrderBlockName,OBJPROP_COLOR,mitigatedOrderBlockColor);
         string blockDescription = "Bearish Order Block";
         string textObjectName = currentOrderBlockName+blockDescription;
         ObjectSetString(0,currentOrderBlockLabel,OBJPROP_TEXT,"Mitigated "+blockDescription);
         
         Print("Buy trade entered upon mitigation of the bearish OB: ",currentOrderBlockName);
      }
      
      if (!doesOrderBlockExist){
         bool removedName = ArrayRemove(orderBlockNames,j,1);
         bool removedLabel = ArrayRemove(orderBlockLabels,j,1);
         bool removedTime = ArrayRemove(orderBlockEndTimes,j,1);
         bool removedStatus = ArrayRemove(orderblockMitigatedStatus,j,1);
         if (removedName && removedTime && removedStatus && removedLabel){
            Print("Success removing OB data from arrays at index ",j);
         }
      }
   }
}

//+------------------------------------------------------------------+

double high (int index) {return iHigh(_Symbol,_Period,index);}
double low (int index) {return iLow(_Symbol,_Period,index);}
double open (int index) {return iOpen(_Symbol,_Period,index);}
double close (int index) {return iClose(_Symbol,_Period,index);}
datetime time (int index) {return iTime(_Symbol,_Period,index);}

void applyTrailingStop(double trailingPoints, CTrade &trade_object, int magicNo = 0){
   double buyStopLoss = NormalizeDouble(SymbolInfoDouble(_Symbol,SYMBOL_BID)-trailingPoints*_Point,_Digits);
   double sellStopLoss = NormalizeDouble(SymbolInfoDouble(_Symbol,SYMBOL_ASK)+trailingPoints*_Point,_Digits);
   
   for (int i=PositionsTotal()-1; i>=0; i--){
      ulong ticket = PositionGetTicket(i);
      if (ticket > 0){
         if (PositionSelectByTicket(ticket)){
            if (PositionGetString(POSITION_SYMBOL)==_Symbol &&
               (magicNo == 0 || PositionGetInteger(POSITION_MAGIC)==magicNo)
            ){
               if (PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_BUY &&
                  buyStopLoss > PositionGetDouble(POSITION_PRICE_OPEN) &&
                  (buyStopLoss > PositionGetDouble(POSITION_SL) || PositionGetDouble(POSITION_SL) == 0)
               ){
                  trade_object.PositionModify(ticket,buyStopLoss,PositionGetDouble(POSITION_TP));
               }
               else if (PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_SELL &&
                  sellStopLoss < PositionGetDouble(POSITION_PRICE_OPEN) &&
                  (sellStopLoss < PositionGetDouble(POSITION_SL) || PositionGetDouble(POSITION_SL) == 0)
               ){
                  trade_object.PositionModify(ticket,sellStopLoss,PositionGetDouble(POSITION_TP));
               }
            }
         }
      }
   }
}
