#property copyright "Distributed as freeware in Free Forex Robots"
#property link      "https://forex-station.com/viewtopic.php?p=1295442917#p1295442917"
#property version   "1.00"
#property strict
#property description "OSMA EA based on OSMA Indicator. Created by Matt Todorovski using Grok AI (www.x.ai)"

input double LotSize              = 0.01;
input ENUM_TIMEFRAMES Pair_1_High_Timeframe  = PERIOD_H4;
input ENUM_TIMEFRAMES Pair_1_Low_Timeframe   = PERIOD_M1;
input ENUM_TIMEFRAMES Pair_2_High_Timeframe  = PERIOD_H4;
input ENUM_TIMEFRAMES Pair_2_Low_Timeframe   = PERIOD_M2;
input ENUM_TIMEFRAMES Pair_3_High_Timeframe  = PERIOD_H4;
input ENUM_TIMEFRAMES Pair_3_Low_Timeframe   = PERIOD_M3;
input ENUM_TIMEFRAMES Pair_4_High_Timeframe  = PERIOD_H4;
input ENUM_TIMEFRAMES Pair_4_Low_Timeframe   = PERIOD_M5;
input ENUM_TIMEFRAMES Pair_5_High_Timeframe  = PERIOD_H4;
input ENUM_TIMEFRAMES Pair_5_Low_Timeframe   = PERIOD_M10;
input ENUM_TIMEFRAMES Pair_6_High_Timeframe  = PERIOD_H4;
input ENUM_TIMEFRAMES Pair_6_Low_Timeframe   = PERIOD_M15;
input ENUM_TIMEFRAMES Pair_7_High_Timeframe  = PERIOD_H4;
input ENUM_TIMEFRAMES Pair_7_Low_Timeframe   = PERIOD_M30;
input ENUM_TIMEFRAMES Pair_8_High_Timeframe  = PERIOD_H4;
input ENUM_TIMEFRAMES Pair_8_Low_Timeframe   = PERIOD_H1;
input ENUM_TIMEFRAMES Pair_9_High_Timeframe  = PERIOD_H4;
input ENUM_TIMEFRAMES Pair_9_Low_Timeframe   = PERIOD_H4;
input ENUM_TIMEFRAMES Pair_10_High_Timeframe = PERIOD_H4;
input ENUM_TIMEFRAMES Pair_10_Low_Timeframe  = PERIOD_H4;

double RSIBuffer[],marsioma[],MABuffer1[],RSIBuffer1[],marsioma1[];
int RSIOMA=10,RSIOMA_MODE=MODE_EMA,RSIOMA_PRICE=PRICE_CLOSE,Ma_RSIOMA=7,Ma_RSIOMA_MODE=MODE_EMA,BarsToCount=1750;

struct PositionInfo {int ticket,highTF,lowTF;};
PositionInfo positions[10];

int OnInit() {
   ArrayResize(RSIBuffer,BarsToCount);ArrayResize(marsioma,BarsToCount);
   ArrayResize(MABuffer1,BarsToCount);ArrayResize(RSIBuffer1,BarsToCount);ArrayResize(marsioma1,BarsToCount);
   ArraySetAsSeries(RSIBuffer,true);ArraySetAsSeries(marsioma,true);
   ArraySetAsSeries(MABuffer1,true);ArraySetAsSeries(RSIBuffer1,true);ArraySetAsSeries(marsioma1,true);
   for(int i=0;i<10;i++) {positions[i].ticket=0;positions[i].highTF=0;positions[i].lowTF=0;}
   return(INIT_SUCCEEDED);
}

void OnDeinit(const int reason) {}

void GetTimeframes(int &highTFs[], int &lowTFs[]) {
   highTFs[0]=Pair_1_High_Timeframe;highTFs[1]=Pair_2_High_Timeframe;highTFs[2]=Pair_3_High_Timeframe;highTFs[3]=Pair_4_High_Timeframe;highTFs[4]=Pair_5_High_Timeframe;
   highTFs[5]=Pair_6_High_Timeframe;highTFs[6]=Pair_7_High_Timeframe;highTFs[7]=Pair_8_High_Timeframe;highTFs[8]=Pair_9_High_Timeframe;highTFs[9]=Pair_10_High_Timeframe;
   lowTFs[0]=Pair_1_Low_Timeframe;lowTFs[1]=Pair_2_Low_Timeframe;lowTFs[2]=Pair_3_Low_Timeframe;lowTFs[3]=Pair_4_Low_Timeframe;lowTFs[4]=Pair_5_Low_Timeframe;
   lowTFs[5]=Pair_6_Low_Timeframe;lowTFs[6]=Pair_7_Low_Timeframe;lowTFs[7]=Pair_8_Low_Timeframe;lowTFs[8]=Pair_9_Low_Timeframe;lowTFs[9]=Pair_10_Low_Timeframe;
}

void OnTick() {
   int highTFs[10],lowTFs[10];
   GetTimeframes(highTFs,lowTFs);
   for(int tf=0;tf<10;tf++) {
      if(highTFs[tf]!=PERIOD_CURRENT && lowTFs[tf]!=PERIOD_CURRENT) {
         CalculateIndicators(highTFs[tf]);
         CheckForClose(lowTFs[tf],tf);
         CheckForOpen(highTFs[tf],lowTFs[tf],tf);
      }
   }
}

void CalculateIndicators(int timeframe) {
   for(int i=BarsToCount-1;i>=0;i--) {
      MABuffer1[i]=iMA(Symbol(),timeframe,RSIOMA,0,RSIOMA_MODE,RSIOMA_PRICE,i);
      RSIBuffer1[i]=iRSIOnArray(MABuffer1,0,RSIOMA,i);
      marsioma1[i]=iMAOnArray(RSIBuffer1,0,Ma_RSIOMA,0,Ma_RSIOMA_MODE,i);
      RSIBuffer[i]=RSIBuffer1[i];
      marsioma[i]=marsioma1[i];
   }
}

void CheckForOpen(int highTF,int lowTF,int pairIndex) {
   CalculateIndicators(highTF);
   if(RSIBuffer[1]<marsioma[1] && RSIBuffer[0]>marsioma[0]) {
      if(positions[pairIndex].ticket>0 && OrderSelect(positions[pairIndex].ticket,SELECT_BY_TICKET)) {
         if(OrderType()==OP_SELL) bool res=OrderClose(positions[pairIndex].ticket,OrderLots(),Ask,3,clrWhite);
      }
      int ticket=OrderSend(Symbol(),OP_BUY,LotSize,Ask,3,0,0,"RSIOMA Buy TF"+IntegerToString(pairIndex),0,0,clrGreen);
      if(ticket>0) {positions[pairIndex].ticket=ticket;positions[pairIndex].highTF=highTF;positions[pairIndex].lowTF=lowTF;}
   }
   if(RSIBuffer[1]>marsioma[1] && RSIBuffer[0]<marsioma[0]) {
      if(positions[pairIndex].ticket>0 && OrderSelect(positions[pairIndex].ticket,SELECT_BY_TICKET)) {
         if(OrderType()==OP_BUY) bool res=OrderClose(positions[pairIndex].ticket,OrderLots(),Bid,3,clrWhite);
      }
      int ticket=OrderSend(Symbol(),OP_SELL,LotSize,Bid,3,0,0,"RSIOMA Sell TF"+IntegerToString(pairIndex),0,0,clrRed);
      if(ticket>0) {positions[pairIndex].ticket=ticket;positions[pairIndex].highTF=highTF;positions[pairIndex].lowTF=lowTF;}
   }
}

void CheckForClose(int lowTF,int pairIndex) {
   CalculateIndicators(lowTF);
   if(positions[pairIndex].ticket>0 && OrderSelect(positions[pairIndex].ticket,SELECT_BY_TICKET)) {
      if(OrderType()==OP_BUY && RSIBuffer[1]>marsioma[1] && RSIBuffer[0]<marsioma[0]) {
         if(OrderClose(positions[pairIndex].ticket,OrderLots(),Bid,3,clrWhite)) positions[pairIndex].ticket=0;
      }
      else if(OrderType()==OP_SELL && RSIBuffer[1]<marsioma[1] && RSIBuffer[0]>marsioma[0]) {
         if(OrderClose(positions[pairIndex].ticket,OrderLots(),Ask,3,clrWhite)) positions[pairIndex].ticket=0;
      }
   }
}