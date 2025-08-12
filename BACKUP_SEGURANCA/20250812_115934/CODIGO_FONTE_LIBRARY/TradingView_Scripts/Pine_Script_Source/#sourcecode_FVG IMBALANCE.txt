//+------------------------------------------------------------------+
//|                                                   FVG SMC EA.mq5 |
//|      Copyright 2024, ALLAN MUNENE MUTIIRIA. #@Forex Algo-Trader. |
//|                           https://youtube.com/@ForexAlgo-Trader? |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, ALLAN MUNENE MUTIIRIA. #@Forex Algo-Trader"
#property link      "https://youtube.com/@ForexAlgo-Trader?"
#property version   "1.00"

#include <Trade/Trade.mqh>
CTrade obj_Trade;

#define FVG_Prefix "FVG REC "
#define CLR_UP clrLime
#define CLR_DOWN clrRed

int minPts = 100;
int FVG_Rec_Ext_Bars = 10;

string totalFVGs[];
int barINDICES[];
datetime barTIMEs[];
bool signalFVGs[];

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit(){

   int visibleBars = (int)ChartGetInteger(0,CHART_VISIBLE_BARS);
   Print("Total visible bars on chart = ",visibleBars);
   
   if (ObjectsTotal(0,0,OBJ_RECTANGLE)==0){
      Print("No FVGs Found, Resizing storage arrays to 0 now!!!");
      ArrayResize(totalFVGs,0);
      ArrayResize(barINDICES,0);
      ArrayResize(signalFVGs,0);
   }
   
   ObjectsDeleteAll(0,FVG_Prefix);
   
   for (int i=0; i<=visibleBars; i++){
      //Print("Bar Index = ",i);
      double low0 = iLow(_Symbol,_Period,i);
      double high2 = iHigh(_Symbol,_Period,i+2);
      double gap_L0_H2 = NormalizeDouble((low0 - high2)/_Point,_Digits);
      
      double high0 = iHigh(_Symbol,_Period,i);
      double low2 = iLow(_Symbol,_Period,i+2);
      double gap_H0_L2 = NormalizeDouble((low2 - high0)/_Point,_Digits);
      
      bool FVG_UP = low0 > high2 && gap_L0_H2 > minPts;
      bool FVG_DOWN = low2 > high0 && gap_H0_L2 > minPts;
      
      if (FVG_UP || FVG_DOWN){
         Print("Bar Index with FVG = ",i+1);
         datetime time1 = iTime(_Symbol,_Period,i+1);
         double price1 = FVG_UP ? high2 : high0;
         datetime time2 = time1 + PeriodSeconds(_Period)*FVG_Rec_Ext_Bars;
         double price2 = FVG_UP ? low0 : low2;
         string fvgNAME = FVG_Prefix+"("+TimeToString(time1)+")";
         color fvgClr = FVG_UP ? CLR_UP : CLR_DOWN;
         CreateRec(fvgNAME,time1,price1,time2,price2,fvgClr);
         Print("Old ArraySize = ",ArraySize(totalFVGs));
         ArrayResize(totalFVGs,ArraySize(totalFVGs)+1);
         ArrayResize(barINDICES,ArraySize(barINDICES)+1);
         Print("New ArraySize = ",ArraySize(totalFVGs));
         totalFVGs[ArraySize(totalFVGs)-1] = fvgNAME;
         barINDICES[ArraySize(barINDICES)-1] = i+1;
         ArrayPrint(totalFVGs);
         ArrayPrint(barINDICES);
      }
   }
   
   for (int i=ArraySize(totalFVGs)-1; i>=0; i--){
      string objName = totalFVGs[i];
      string fvgNAME = ObjectGetString(0,objName,OBJPROP_NAME);
      int barIndex = barINDICES[i];
      datetime timeSTART = (datetime)ObjectGetInteger(0,fvgNAME,OBJPROP_TIME,0);
      datetime timeEND = (datetime)ObjectGetInteger(0,fvgNAME,OBJPROP_TIME,1);
      double fvgLOW = ObjectGetDouble(0,fvgNAME,OBJPROP_PRICE,0);
      double fvgHIGH = ObjectGetDouble(0,fvgNAME,OBJPROP_PRICE,1);
      color fvgColor = (color)ObjectGetInteger(0,fvgNAME,OBJPROP_COLOR);
      
      Print("FVG NAME = ",fvgNAME," >No: ",barIndex," TS: ",timeSTART," TE: ",
            timeEND," LOW: ",fvgLOW," HIGH: ",fvgHIGH," CLR = ",fvgColor);
      for (int k=barIndex-1; k>=(barIndex-FVG_Rec_Ext_Bars); k--){
         datetime barTime = iTime(_Symbol,_Period,k);
         double barLow = iLow(_Symbol,_Period,k);
         double barHigh = iHigh(_Symbol,_Period,k);
         //Print("Bar No: ",k," >Time: ",barTime," >H: ",barHigh," >L: ",barLow);
         
         if (k==0){
            Print("OverFlow Detected @ fvg ",fvgNAME);
            UpdateRec(fvgNAME,timeSTART,fvgLOW,barTime,fvgHIGH);
            break;
         }
         
         if ((fvgColor == CLR_DOWN && barHigh > fvgHIGH) ||
            (fvgColor == CLR_UP && barLow < fvgLOW)
         ){
            Print("Cut Off @ bar no: ",k," of Time: ",barTime);
            UpdateRec(fvgNAME,timeSTART,fvgLOW,barTime,fvgHIGH);
            break;
         }
      }
      
   }
   
   ArrayResize(totalFVGs,0);
   ArrayResize(barINDICES,0);

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
   
   for (int i=0; i<=FVG_Rec_Ext_Bars; i++){
      double low0 = iLow(_Symbol,_Period,i+1);
      double high2 = iHigh(_Symbol,_Period,i+2+1);
      double gap_L0_H2 = NormalizeDouble((low0 - high2)/_Point,_Digits);
      
      double high0 = iHigh(_Symbol,_Period,i+1);
      double low2 = iLow(_Symbol,_Period,i+2+1);
      double gap_H0_L2 = NormalizeDouble((low2 - high0)/_Point,_Digits);
      
      bool FVG_UP = low0 > high2 && gap_L0_H2 > minPts;
      bool FVG_DOWN = low2 > high0 && gap_H0_L2 > minPts;
      
      if (FVG_UP || FVG_DOWN){
         datetime time1 = iTime(_Symbol,_Period,i+1+1);
         double price1 = FVG_UP ? high2 : high0;
         datetime time2 = time1 + PeriodSeconds(_Period)*FVG_Rec_Ext_Bars;
         double price2 = FVG_UP ? low0 : low2;
         string fvgNAME = FVG_Prefix+"("+TimeToString(time1)+")";
         color fvgClr = FVG_UP ? CLR_UP : CLR_DOWN;
         
         if (ObjectFind(0,fvgNAME) < 0){
            CreateRec(fvgNAME,time1,price1,time2,price2,fvgClr);
            Print("Old ArraySize = ",ArraySize(totalFVGs));
            ArrayResize(totalFVGs,ArraySize(totalFVGs)+1);
            ArrayResize(barTIMEs,ArraySize(barTIMEs)+1);
            ArrayResize(signalFVGs,ArraySize(signalFVGs)+1);
            Print("New ArraySize = ",ArraySize(totalFVGs));
            totalFVGs[ArraySize(totalFVGs)-1] = fvgNAME;
            barTIMEs[ArraySize(barTIMEs)-1] = time1;
            signalFVGs[ArraySize(signalFVGs)-1] = false;
            ArrayPrint(totalFVGs);
            ArrayPrint(barTIMEs);
            ArrayPrint(signalFVGs);
         }
      }
   }
   
   for (int j=ArraySize(totalFVGs)-1; j>=0; j--){
      bool fvgExist = false;
      string objName = totalFVGs[j];
      string fvgNAME = ObjectGetString(0,objName,OBJPROP_NAME);
      double fvgLow = ObjectGetDouble(0,fvgNAME,OBJPROP_PRICE,0);
      double fvgHigh = ObjectGetDouble(0,fvgNAME,OBJPROP_PRICE,1);
      color fvgColor = (color)ObjectGetInteger(0,fvgNAME,OBJPROP_COLOR);
      
      for (int k=1; k<=FVG_Rec_Ext_Bars; k++){
         double barLow = iLow(_Symbol,_Period,k);
         double barHigh = iHigh(_Symbol,_Period,k);
         
         if (barHigh == fvgLow || barLow == fvgLow){
            //Print("Found: ",fvgNAME," @ bar ",k);
            fvgExist = true;
            break;
         }
      }
      
      //Print("Existence of ",fvgNAME," = ",fvgExist);
      
      double Ask = NormalizeDouble(SymbolInfoDouble(_Symbol,SYMBOL_ASK),_Digits);
      double Bid = NormalizeDouble(SymbolInfoDouble(_Symbol,SYMBOL_BID),_Digits);
      
      if (fvgColor == CLR_DOWN && Bid > fvgHigh && !signalFVGs[j]){
         Print("SELL SIGNAL For (",fvgNAME,") Now @ ",Bid);
         obj_Trade.Sell(0.01,_Symbol,Bid,0,fvgLow);
         signalFVGs[j] = true;
         ArrayPrint(totalFVGs,_Digits," [< >] ");
         ArrayPrint(signalFVGs,_Digits," [< >] ");
      }
      else if (fvgColor == CLR_UP && Ask < fvgLow && !signalFVGs[j]){
         Print("BUY SIGNAL For (",fvgNAME,") Now @ ",Ask);
         obj_Trade.Buy(0.01,_Symbol,Ask,0,fvgHigh);
         signalFVGs[j] = true;
         ArrayPrint(totalFVGs,_Digits," [< >] ");
         ArrayPrint(signalFVGs,_Digits," [< >] ");
      }
      
      if (fvgExist == false){
         bool removeName = ArrayRemove(totalFVGs,0,1);
         bool removeTime = ArrayRemove(barTIMEs,0,1);
         bool removeSignal = ArrayRemove(signalFVGs,0,1);
         if (removeName && removeTime && removeSignal){
            Print("Success removing the FVG DATA from the arrays. New Data as Below:");
            Print("FVGs: ",ArraySize(totalFVGs)," TIMEs: ",ArraySize(barTIMEs),
                     " SIGNALs: ",ArraySize(signalFVGs));
            ArrayPrint(totalFVGs);
            ArrayPrint(barTIMEs);
            ArrayPrint(signalFVGs);
         }
      }      
   }
   
}
//+------------------------------------------------------------------+

void CreateRec(string objName,datetime time1,double price1,
               datetime time2, double price2,color clr){
   if (ObjectFind(0,objName) < 0){
      ObjectCreate(0,objName,OBJ_RECTANGLE,0,time1,price1,time2,price2);
      
      ObjectSetInteger(0,objName,OBJPROP_TIME,0,time1);
      ObjectSetDouble(0,objName,OBJPROP_PRICE,0,price1);
      ObjectSetInteger(0,objName,OBJPROP_TIME,1,time2);
      ObjectSetDouble(0,objName,OBJPROP_PRICE,1,price2);
      ObjectSetInteger(0,objName,OBJPROP_COLOR,clr);
      ObjectSetInteger(0,objName,OBJPROP_FILL,true);
      ObjectSetInteger(0,objName,OBJPROP_BACK,false);
      
      ChartRedraw(0);
   }
}

void UpdateRec(string objName,datetime time1,double price1,
               datetime time2, double price2){
   if (ObjectFind(0,objName) >= 0){
      ObjectSetInteger(0,objName,OBJPROP_TIME,0,time1);
      ObjectSetDouble(0,objName,OBJPROP_PRICE,0,price1);
      ObjectSetInteger(0,objName,OBJPROP_TIME,1,time2);
      ObjectSetDouble(0,objName,OBJPROP_PRICE,1,price2);
      
      ChartRedraw(0);
   }
}