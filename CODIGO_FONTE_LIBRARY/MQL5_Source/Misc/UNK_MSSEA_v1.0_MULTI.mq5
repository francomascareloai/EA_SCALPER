//+------------------------------------------------------------------+
//|                                                       MSS EA.mq5 |
//|                                  Copyright 2024, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"

double swingHighs_Array[];
double swingLows_Array[];


//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   
//---
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
   
   static bool isNewBar = false;
   int currBars = iBars(_Symbol,_Period);
   static int prevBars = currBars;
   if (prevBars == currBars){isNewBar = false;}
   else if (prevBars != currBars){isNewBar = true; prevBars = currBars;}
   
   const int length = 10; // >2
   int right_index, left_index;
   int curr_bar = length;
   bool isSwingHigh = true, isSwingLow = true;
   static double swing_H = -1.0, swing_L = -1.0;
   
   if (isNewBar){
      for (int a=1; a<=length; a++){
         right_index = curr_bar - a;
         left_index = curr_bar + a;
         //Print(a," <> ",right_index," > ",left_index);
         if ( (high(curr_bar) <= high(right_index)) || (high(curr_bar) < high(left_index)) ){
            isSwingHigh = false;
         }
         if ( (low(curr_bar) >= low(right_index)) || (low(curr_bar) > low(left_index)) ){
            isSwingLow = false;
         }
      }
      
      //---
      
      if (isSwingHigh){
         swing_H = high(curr_bar);
         Print("WE DO HAVE A SWING HIGH @ BAR INDEX ",curr_bar," H: ",high(curr_bar));
         drawSwingPoint(TimeToString(time(curr_bar)),time(curr_bar),high(curr_bar),77,clrBlue,-1);
         
         //---
         if (ArraySize(swingHighs_Array) < 2){
            ArrayResize(swingHighs_Array,ArraySize(swingHighs_Array)+1);
            swingHighs_Array[ArraySize(swingHighs_Array)-1] = swing_H;
         }
         else if (ArraySize(swingHighs_Array) == 2){
            ArrayRemove(swingHighs_Array,0,1);
            ArrayResize(swingHighs_Array,ArraySize(swingHighs_Array)+1);
            swingHighs_Array[ArraySize(swingHighs_Array)-1] = swing_H;
            Print("POPULATED! New swing high prices data is as below:");
            ArrayPrint(swingHighs_Array,_Digits," , ");
         }
         
         
      }
      if (isSwingLow){
         swing_L = low(curr_bar);
         Print("WE DO HAVE A SWING LOW @ BAR INDEX ",curr_bar," L: ",low(curr_bar));
         drawSwingPoint(TimeToString(time(curr_bar)),time(curr_bar),low(curr_bar),77,clrRed,+1);
      
         //---
         if (ArraySize(swingLows_Array) < 2){
            ArrayResize(swingLows_Array,ArraySize(swingLows_Array)+1);
            swingLows_Array[ArraySize(swingLows_Array)-1] = swing_L;
         }
         else if (ArraySize(swingLows_Array) == 2){
            ArrayRemove(swingLows_Array,0,1);
            ArrayResize(swingLows_Array,ArraySize(swingLows_Array)+1);
            swingLows_Array[ArraySize(swingLows_Array)-1] = swing_L;
            Print("POPULATED! New swing low prices data is as below:");
            ArrayPrint(swingLows_Array,_Digits," , ");
         }
      
      }
   }
   
   double Ask = NormalizeDouble(SymbolInfoDouble(_Symbol,SYMBOL_ASK),_Digits);
   double Bid = NormalizeDouble(SymbolInfoDouble(_Symbol,SYMBOL_BID),_Digits);
   
   if (swing_H > 0 && Ask > swing_H){
      Print("$$$$$$$$$ BUY SIGNAL NOW. BREAK OF SWING HIGH");
      int swing_H_index = 0;
      for (int i=0; i<=length*2+1000; i++){
         double high_sel = high(i);
         if (high_sel == swing_H){
            swing_H_index = i;
            Print("BREAK HIGH FOUND @ BAR INDEX ",swing_H_index);
            break;
         }
      }
      
      //---
      bool isMSS_High = false;
      if (ArraySize(swingHighs_Array) >= 2 && ArraySize(swingLows_Array) >= 2){
         isMSS_High = swingHighs_Array[0] > swingHighs_Array[1]
                        && swingLows_Array[0] > swingLows_Array[1];
      }
      if (isMSS_High){
         Print("Alert! This is a Market Structure Shift (MSS) UPTREND");
         drawBreakLevel_MSS(TimeToString(time(0)),time(swing_H_index),high(swing_H_index),
         time(0),high(swing_H_index),clrDarkGreen,-1);
      }
      else if (!isMSS_High){
         drawBreakLevel(TimeToString(time(0)),time(swing_H_index),high(swing_H_index),
         time(0),high(swing_H_index),clrBlue,-1);
      }
      
      swing_H = -1.0;
      return;
   }
   if (swing_L > 0 && Bid < swing_L){
      Print("$$$$$$$$$ SELL SIGNAL NOW. BREAK OF SWING LOW");
      int swing_L_index = 0;
      for (int i=0; i<=length*2+1000; i++){
         double low_sel = low(i);
         if (low_sel == swing_L){
            swing_L_index = i;
            Print("BREAK LOW FOUND @ BAR INDEX ",swing_L_index);
            break;
         }
      }
      
      //---
      bool isMSS_Low = false;
      if (ArraySize(swingHighs_Array) >= 2 && ArraySize(swingLows_Array) >= 2){
         isMSS_Low = swingHighs_Array[0] < swingHighs_Array[1]
                        && swingLows_Array[0] < swingLows_Array[1];
      }
      if (isMSS_Low){
         Print("Alert! This is a Market Structure Shift (MSS) DOWNTREND");
         drawBreakLevel_MSS(TimeToString(time(0)),time(swing_L_index),low(swing_L_index),
         time(0),low(swing_L_index),clrBlack,+1);
      }
      else if (!isMSS_Low){
         drawBreakLevel(TimeToString(time(0)),time(swing_L_index),low(swing_L_index),
         time(0),low(swing_L_index),clrRed,+1);
      }
      
      

      swing_L = -1.0;
      return;
   }
   
}
//+------------------------------------------------------------------+

double high(int index){return (iHigh(_Symbol,_Period,index));}
double low(int index){return (iLow(_Symbol,_Period,index));}
datetime time(int index){return (iTime(_Symbol,_Period,index));}

void drawSwingPoint(string objName,datetime time,double price,int arrCode,
   color clr,int direction){
   if (ObjectFind(0,objName) < 0){
      ObjectCreate(0,objName,OBJ_ARROW,0,time,price);
      ObjectSetInteger(0,objName,OBJPROP_ARROWCODE,arrCode);
      ObjectSetInteger(0,objName,OBJPROP_COLOR,clr);
      ObjectSetInteger(0,objName,OBJPROP_FONTSIZE,10);
      
      if (direction > 0) {ObjectSetInteger(0,objName,OBJPROP_ANCHOR,ANCHOR_TOP);}
      if (direction < 0) {ObjectSetInteger(0,objName,OBJPROP_ANCHOR,ANCHOR_BOTTOM);}
      
      string text = "BoS";
      string objName_Descr = objName + text;
      ObjectCreate(0,objName_Descr,OBJ_TEXT,0,time,price);
      ObjectSetInteger(0,objName_Descr,OBJPROP_COLOR,clr);
      ObjectSetInteger(0,objName_Descr,OBJPROP_FONTSIZE,10);
      
      if (direction > 0) {
         ObjectSetString(0,objName_Descr,OBJPROP_TEXT,"  "+text);
         ObjectSetInteger(0,objName_Descr,OBJPROP_ANCHOR,ANCHOR_LEFT_UPPER);
      }
      if (direction < 0) {
         ObjectSetString(0,objName_Descr,OBJPROP_TEXT,"  "+text);
         ObjectSetInteger(0,objName_Descr,OBJPROP_ANCHOR,ANCHOR_LEFT_LOWER);
      }

   }
   ChartRedraw(0);
}

void drawBreakLevel(string objName,datetime time1,double price1,
   datetime time2,double price2,color clr,int direction){
   if (ObjectFind(0,objName) < 0){
      ObjectCreate(0,objName,OBJ_ARROWED_LINE,0,time1,price1,time2,price2);
      ObjectSetInteger(0,objName,OBJPROP_TIME,0,time1);
      ObjectSetDouble(0,objName,OBJPROP_PRICE,0,price1);
      ObjectSetInteger(0,objName,OBJPROP_TIME,1,time2);
      ObjectSetDouble(0,objName,OBJPROP_PRICE,1,price2);

      ObjectSetInteger(0,objName,OBJPROP_COLOR,clr);
      ObjectSetInteger(0,objName,OBJPROP_WIDTH,2);
      
      string text = "Break";
      string objName_Descr = objName + text;
      ObjectCreate(0,objName_Descr,OBJ_TEXT,0,time2,price2);
      ObjectSetInteger(0,objName_Descr,OBJPROP_COLOR,clr);
      ObjectSetInteger(0,objName_Descr,OBJPROP_FONTSIZE,10);
      
      if (direction > 0) {
         ObjectSetString(0,objName_Descr,OBJPROP_TEXT,text+"  ");
         ObjectSetInteger(0,objName_Descr,OBJPROP_ANCHOR,ANCHOR_RIGHT_UPPER);
      }
      if (direction < 0) {
         ObjectSetString(0,objName_Descr,OBJPROP_TEXT,text+"  ");
         ObjectSetInteger(0,objName_Descr,OBJPROP_ANCHOR,ANCHOR_RIGHT_LOWER);
      }
   }
   ChartRedraw(0);
}

void drawBreakLevel_MSS(string objName,datetime time1,double price1,
   datetime time2,double price2,color clr,int direction){
   if (ObjectFind(0,objName) < 0){
      ObjectCreate(0,objName,OBJ_ARROWED_LINE,0,time1,price1,time2,price2);
      ObjectSetInteger(0,objName,OBJPROP_TIME,0,time1);
      ObjectSetDouble(0,objName,OBJPROP_PRICE,0,price1);
      ObjectSetInteger(0,objName,OBJPROP_TIME,1,time2);
      ObjectSetDouble(0,objName,OBJPROP_PRICE,1,price2);

      ObjectSetInteger(0,objName,OBJPROP_COLOR,clr);
      ObjectSetInteger(0,objName,OBJPROP_WIDTH,4);
      
      string text = "Break (MSS)";
      string objName_Descr = objName + text;
      ObjectCreate(0,objName_Descr,OBJ_TEXT,0,time2,price2);
      ObjectSetInteger(0,objName_Descr,OBJPROP_COLOR,clr);
      ObjectSetInteger(0,objName_Descr,OBJPROP_FONTSIZE,13);
      
      if (direction > 0) {
         ObjectSetString(0,objName_Descr,OBJPROP_TEXT,text+"  ");
         ObjectSetInteger(0,objName_Descr,OBJPROP_ANCHOR,ANCHOR_RIGHT_UPPER);
      }
      if (direction < 0) {
         ObjectSetString(0,objName_Descr,OBJPROP_TEXT,text+"  ");
         ObjectSetInteger(0,objName_Descr,OBJPROP_ANCHOR,ANCHOR_RIGHT_LOWER);
      }
   }
   ChartRedraw(0);
}