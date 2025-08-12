//+------------------------------------------------------------------+
//|                                       FADE THE BREAK S AND R.mq5 |
//|                                  Copyright 2024, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"

#include <Trade/Trade.mqh>
CTrade obj_Trade;

double pricesHighest[], pricesLowest[];

double resistanceLevels[2], supportLevels[2];

#define resLine "RESISTANCE LEVEL"
#define colorRes clrRed
#define resLine_Prefix "R"

#define supLine "SUPPORT LEVEL"
#define colorSup clrBlue
#define supLine_Prefix "S"

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit(){
   
   ArraySetAsSeries(pricesHighest, true);
   ArraySetAsSeries(pricesLowest, true);
   // define the sizes of the arrays
   ArrayResize(pricesHighest, 50);
   ArrayResize(pricesLowest, 50);
   
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
   
   int currBars = iBars(_Symbol,_Period);
   static int prevBars = currBars;
   if (prevBars == currBars) return;
   prevBars = currBars;
   
   int visibleBars = (int)ChartGetInteger(0,CHART_VISIBLE_BARS);
   bool stop_processing = false; // flag to control the inner loop
   bool matchFound_high1 = false, matchFound_low1 = false;
   bool matchFound_high2 = false, matchFound_low2 = false;
   
   ArrayFree(pricesHighest);
   ArrayFree(pricesLowest);
   
   int copiedBarsHighs = CopyHigh(_Symbol,_Period,1,visibleBars,pricesHighest);
   int copiedBarsLows = CopyLow(_Symbol,_Period,1,visibleBars,pricesLowest);
   
   //ArrayPrint(pricesHighest);
   //ArrayPrint(pricesLowest);
   // sort the array from the ascending order
   ArraySort(pricesHighest);
   ArraySort(pricesLowest);
   //ArrayPrint(pricesHighest);
   //ArrayPrint(pricesLowest);
   ArrayRemove(pricesHighest,10,WHOLE_ARRAY);
   ArrayRemove(pricesLowest,0,visibleBars-10);
   //ArrayPrint(pricesHighest);
   //ArrayPrint(pricesLowest);
   
   for (int i=1; i<=visibleBars-1 && !stop_processing; i++){
      //Print(":: BAR NO: ",i);
      double open = iOpen(_Symbol,_Period,i);
      double high = iHigh(_Symbol,_Period,i);
      double low = iLow(_Symbol,_Period,i);
      double close = iClose(_Symbol,_Period,i);
      datetime time = iTime(_Symbol,_Period,i);
      
      //Print(":: BAR NO: ",i,", high = ",high);
      int diff_i_j = 10;
      for (int j=i+diff_i_j; j<=visibleBars-1; j++){
         double open_j = iOpen(_Symbol,_Period,j);
         double high_j = iHigh(_Symbol,_Period,j);
         double low_j = iLow(_Symbol,_Period,j);
         double close_j = iClose(_Symbol,_Period,j);
         datetime time_j = iTime(_Symbol,_Period,j);
         //Print("BAR CHECK NO: ",j,", HIGH = ",high_j);

         // CHECK FOR RESISTANCE
         double high_diff = NormalizeDouble(MathAbs(high-high_j)/_Point,0); // 10
         bool is_resistance = high_diff <= 10; // 0 - 10 
         
         // CHECK FOR SUPPORT
         double low_diff = NormalizeDouble(MathAbs(low-low_j)/_Point,0); // 10
         bool is_support = low_diff <= 10; // (0 - 10)
         
         if (is_resistance){
            //Print("RESISTANCE @ BAR ",i,"(",high,") & ",j," (",high_j,") Pts = ",high_diff);
            for (int k=0; k<ArraySize(pricesHighest); k++){
               if (pricesHighest[k]==high){
                  matchFound_high1 = true;
                  //Print("> RES H1(",high,") FOUND @ ",k," (",pricesHighest[k],")");
               }
               if (pricesHighest[k]==high_j){
                  matchFound_high2 = true;
                  //Print("> RES H2(",high_j,") FOUND @ ",k," (",pricesHighest[k],")");
               }
               if (matchFound_high1 && matchFound_high2){
                  if (resistanceLevels[0]==high || resistanceLevels[1]==high_j){
                     Print("CONFIRMED BUT this is the same resistance level, skip updating!");
                     stop_processing = true; // set the flag to stop processing
                     break; // stop the inner loop prematurily
                  }
                  else {
                     Print("++++++++= RESISTANCE LEVELS CONFIRMED @ BARS ",i,
                     "(",high,") & ",j,"(",high_j,")");
                     resistanceLevels[0] = high;
                     resistanceLevels[1] = high_j;
                     ArrayPrint(resistanceLevels);
                     
                     draw_S_R_level(resLine,high,colorRes,5);
                     draw_S_R_level_Point(resLine_Prefix,high,time,218,-1,colorRes,90);
                     draw_S_R_level_Point(resLine_Prefix,high,time_j,218,-1,colorRes,90);

                     stop_processing = true;
                     break;
                  }
               }
            }
         }
         if (is_support){
            //Print("RESISTANCE @ BAR ",i,"(",high,") & ",j," (",high_j,") Pts = ",high_diff);
            for (int k=0; k<ArraySize(pricesLowest); k++){
               if (pricesLowest[k]==low){
                  matchFound_low1 = true;
                  //Print("> RES H1(",high,") FOUND @ ",k," (",pricesHighest[k],")");
               }
               if (pricesLowest[k]==low_j){
                  matchFound_low2 = true;
                  //Print("> RES H2(",high_j,") FOUND @ ",k," (",pricesHighest[k],")");
               }
               if (matchFound_low1 && matchFound_low2){
                  if (supportLevels[0]==low || supportLevels[1]==low_j){
                     Print("CONFIRMED BUT this is the same support level, skip updating!");
                     stop_processing = true; // set the flag to stop processing
                     break; // stop the inner loop prematurily
                  }
                  else {
                     Print("++++++++= SUPPORT LEVELS CONFIRMED @ BARS ",i,
                     "(",low,") & ",j,"(",low_j,")");
                     supportLevels[0] = low;
                     supportLevels[1] = low_j;
                     ArrayPrint(supportLevels);
                     
                     draw_S_R_level(supLine,low,colorSup,5);
                     draw_S_R_level_Point(supLine_Prefix,low,time,217,1,colorSup,-90);
                     draw_S_R_level_Point(supLine_Prefix,low,time_j,217,1,colorSup,-90);

                     stop_processing = true;
                     break;
                  }
               }
            }
         }
         
         if (stop_processing){break;}
      }
      if (stop_processing){break;}
   }
   
   if (ObjectFind(0,resLine) >= 0){
      double objPrice = ObjectGetDouble(0,resLine,OBJPROP_PRICE);
      double visibleHighs[];
      ArraySetAsSeries(visibleHighs, true);
      CopyHigh(_Symbol,_Period,1,visibleBars,visibleHighs);
      bool matchHighFound = false;
      
      for (int i=0; i<ArraySize(visibleHighs); i++){
         if (visibleHighs[i]==objPrice){
            Print("> Match price for resistance found @ bar # ",i+1,"(",objPrice,")");
            matchHighFound = true;
            break;
         }
      }
      if (!matchHighFound){
         Print("(",objPrice,")> Match price for the resistance line not found. Delete!");
         deleteLevel(resLine);
      }
   }
   if (ObjectFind(0,supLine) >= 0){
      double objPrice = ObjectGetDouble(0,supLine,OBJPROP_PRICE);
      double visibleLows[];
      ArraySetAsSeries(visibleLows, true);
      CopyLow(_Symbol,_Period,1,visibleBars,visibleLows);
      bool matchLowFound = false;
      
      for (int i=0; i<ArraySize(visibleLows); i++){
         if (visibleLows[i]==objPrice){
            Print("> Match price for support found @ bar # ",i+1,"(",objPrice,")");
            matchLowFound = true;
            break;
         }
      }
      if (!matchLowFound){
         Print("(",objPrice,")> Match price for the support line not found. Delete!");
         deleteLevel(supLine);
      }
   }
   
   static double resistancePriceTrade = 0;
   if (ObjectFind(0,resLine) >= 0){
      double ResistancePriceLevel = ObjectGetDouble(0,resLine,OBJPROP_PRICE);
      if (resistancePriceTrade != ResistancePriceLevel){
      
         double Ask = NormalizeDouble(SymbolInfoDouble(_Symbol,SYMBOL_ASK),_Digits);
         double Bid = NormalizeDouble(SymbolInfoDouble(_Symbol,SYMBOL_BID),_Digits);
         
         double open1 = iOpen(_Symbol,_Period,1);
         double high1 = iHigh(_Symbol,_Period,1);
         double low1 = iLow(_Symbol,_Period,1);
         double close1 = iClose(_Symbol,_Period,1);
         
         if (open1 > close1 && open1 < ResistancePriceLevel
            && high1 > ResistancePriceLevel && Bid < ResistancePriceLevel){
            Print("$$$$$$$$$$$$$ SELL NOW SIGNAL!");
            obj_Trade.Sell(10,_Symbol,Bid,0,Bid-100*_Point);
            resistancePriceTrade = ResistancePriceLevel;
         }
      }
   }
   static double supportPriceTrade = 0;
   if (ObjectFind(0,supLine) >= 0){
      double SupportPriceLevel = ObjectGetDouble(0,supLine,OBJPROP_PRICE);
      if (supportPriceTrade != SupportPriceLevel){
      
         double Ask = NormalizeDouble(SymbolInfoDouble(_Symbol,SYMBOL_ASK),_Digits);
         double Bid = NormalizeDouble(SymbolInfoDouble(_Symbol,SYMBOL_BID),_Digits);
         
         double open1 = iOpen(_Symbol,_Period,1);
         double high1 = iHigh(_Symbol,_Period,1);
         double low1 = iLow(_Symbol,_Period,1);
         double close1 = iClose(_Symbol,_Period,1);
         
         if (open1 < close1 && open1 > SupportPriceLevel
            && low1 < SupportPriceLevel && Ask > SupportPriceLevel){
            Print("$$$$$$$$$$$$$ BUY NOW SIGNAL!");
            obj_Trade.Buy(10,_Symbol,Ask,0,Ask+100*_Point);
            supportPriceTrade = SupportPriceLevel;
         }
      }
   }
   
}
//+------------------------------------------------------------------+


void draw_S_R_level(string levelName,double price,color clr,int width){
   if (ObjectFind(0,levelName) < 0){
      ObjectCreate(0,levelName,OBJ_HLINE,0,TimeCurrent(),price);
      ObjectSetInteger(0,levelName,OBJPROP_COLOR,clr);
      ObjectSetInteger(0,levelName,OBJPROP_WIDTH,width);
   }
   else {
      ObjectSetDouble(0,levelName,OBJPROP_PRICE,price);
   }
   ChartRedraw(0);
}

void draw_S_R_level_Point(string objName,double price,datetime time,
   int arrowcode,int direction,color clr,double angle){
   string dynamic_name = objName;
   StringConcatenate(objName,objName," @ \nTime: ",time,"\nPrice: ",DoubleToString(price,_Digits));
   if (ObjectCreate(0,objName,OBJ_ARROW,0,time,price)){
      ObjectSetInteger(0,objName,OBJPROP_ARROWCODE,arrowcode);
      ObjectSetInteger(0,objName,OBJPROP_COLOR,clr);
      ObjectSetInteger(0,objName,OBJPROP_FONTSIZE,10);
      if (direction > 0) ObjectSetInteger(0,objName,OBJPROP_ANCHOR,ANCHOR_TOP);
      if (direction < 0) ObjectSetInteger(0,objName,OBJPROP_ANCHOR,ANCHOR_BOTTOM);
   }
   string prefix = (dynamic_name == supLine_Prefix) ? "S" : "R";
   string text = "\n"+prefix +"("+ DoubleToString(price,_Digits)+")";
   string objNameDescr = objName + text;
   if (ObjectCreate(0,objNameDescr,OBJ_TEXT,0,time,price)){
      ObjectSetInteger(0,objNameDescr,OBJPROP_COLOR,clr);
      ObjectSetInteger(0,objNameDescr,OBJPROP_FONTSIZE,10);
      ObjectSetDouble(0,objNameDescr,OBJPROP_ANGLE,angle);
      ObjectSetString(0,objNameDescr,OBJPROP_TEXT,"   "+text);
      if (direction > 0){
         ObjectSetInteger(0,objNameDescr,OBJPROP_ANCHOR,ANCHOR_LEFT);
      }
      if (direction < 0){
         ObjectSetInteger(0,objNameDescr,OBJPROP_ANCHOR,ANCHOR_BOTTOM);
      }
      
   }
   
   ChartRedraw(0);
}

void deleteLevel(string levelName){
   ObjectDelete(0,levelName);
   ChartRedraw(0);
}