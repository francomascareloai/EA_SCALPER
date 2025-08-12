//+------------------------------------------------------------------+
//|                                       PROFITUNITY TRADING EA.mq5 |
//|                                  Copyright 2024, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"

#include <Trade/Trade.mqh>
CTrade obj_Trade;

int handle_Fractals = INVALID_HANDLE;
int handle_Alligator = INVALID_HANDLE;
int handle_AO = INVALID_HANDLE;
int handle_AC = INVALID_HANDLE;

double fractals_up[];
double fractals_down[];

double alligator_jaws[];
double alligator_teeth[];
double alligator_lips[];

double ao_values[];

double ac_color[];
#define AC_COLOR_UP 0
#define AC_COLOR_DOWN 1


double lastFractal_Value = 0.0;
enum fractal_direction {FRACTAL_UP,FRACTAL_DOWN,FRACTAL_NEUTRAL};
fractal_direction lastFractal_direction = FRACTAL_NEUTRAL;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit(){
//---
   
   handle_Fractals = iFractals(_Symbol,_Period);
   if (handle_Fractals == INVALID_HANDLE){
      Print("ERROR: UNABLE TO INITIALIZE THE FRACTALS INDICATOR. REVERTING NOW!");
      return (INIT_FAILED);
   }
   handle_Alligator = iAlligator(_Symbol,_Period,13,8,8,5,5,3,MODE_SMMA,PRICE_MEDIAN);
   if (handle_Alligator == INVALID_HANDLE){
      Print("ERROR: UNABLE TO INITIALIZE THE ALLIGATOR INDICATOR. REVERTING NOW!");
      return (INIT_FAILED);
   }
   handle_AO = iAO(_Symbol,_Period);
   if (handle_AO == INVALID_HANDLE){
      Print("ERROR: UNABLE TO INITIALIZE THE AO INDICATOR. REVERTING NOW!");
      return (INIT_FAILED);
   }
   handle_AC = iAC(_Symbol,_Period);
   if (handle_AC == INVALID_HANDLE){
      Print("ERROR: UNABLE TO INITIALIZE THE AC INDICATOR. REVERTING NOW!");
      return (INIT_FAILED);
   }
   
   if (!ChartIndicatorAdd(0,0,handle_Fractals)){
      Print("ERROR: UNABLE TO ADD THE FRACTALS INDICATOR TO CHART. REVERTING NOW!");
      return (INIT_FAILED);
   }
   if (!ChartIndicatorAdd(0,0,handle_Alligator)){
      Print("ERROR: UNABLE TO ADD THE ALLIGATOR INDICATOR TO CHART. REVERTING NOW!");
      return (INIT_FAILED);
   }
   if (!ChartIndicatorAdd(0,1,handle_AO)){
      Print("ERROR: UNABLE TO ADD THE AO INDICATOR TO CHART. REVERTING NOW!");
      return (INIT_FAILED);
   }
   if (!ChartIndicatorAdd(0,2,handle_AC)){
      Print("ERROR: UNABLE TO ADD THE AC INDICATOR TO CHART. REVERTING NOW!");
      return (INIT_FAILED);
   }
   
   Print("HANDLE ID FRACTALS = ",handle_Fractals);
   Print("HANDLE ID ALLIGATOR = ",handle_Alligator);
   Print("HANDLE ID AO = ",handle_AO);
   Print("HANDLE ID AC = ",handle_AC);
   
   ArraySetAsSeries(fractals_up,true);
   ArraySetAsSeries(fractals_down,true);
   
   ArraySetAsSeries(alligator_jaws,true);
   ArraySetAsSeries(alligator_teeth,true);
   ArraySetAsSeries(alligator_lips,true);
   
   ArraySetAsSeries(ao_values,true);
   
   ArraySetAsSeries(ac_color,true);

   
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
//---
   
   if (CopyBuffer(handle_Fractals,0,2,3,fractals_up) < 3){
      Print("ERROR: UNABLE TO COPY THE FRACTALS UP DATA. REVERTING!");
      return;
   }
   if (CopyBuffer(handle_Fractals,1,2,3,fractals_down) < 3){
      Print("ERROR: UNABLE TO COPY THE FRACTALS DOWN DATA. REVERTING!");
      return;
   }
   
   if (CopyBuffer(handle_Alligator,0,0,3,alligator_jaws) < 3){
      Print("ERROR: UNABLE TO COPY THE ALLIGATOR JAWS DATA. REVERTING!");
      return;
   }
   if (CopyBuffer(handle_Alligator,1,0,3,alligator_teeth) < 3){
      Print("ERROR: UNABLE TO COPY THE ALLIGATOR TEETH DATA. REVERTING!");
      return;
   }
   if (CopyBuffer(handle_Alligator,2,0,3,alligator_lips) < 3){
      Print("ERROR: UNABLE TO COPY THE ALLIGATOR LIPS DATA. REVERTING!");
      return;
   }
   
   if (CopyBuffer(handle_AO,0,0,3,ao_values) < 3){
      Print("ERROR: UNABLE TO COPY THE AO DATA. REVERTING!");
      return;
   }
   
   if (CopyBuffer(handle_AC,1,0,3,ac_color) < 3){
      Print("ERROR: UNABLE TO COPY THE AC DATA. REVERTING!");
      return;
   }
   
   if (isNewBar()){
      const int index_fractal = 0;
      //Print(fractals_up[index_fractal]);
      if (fractals_up[index_fractal] != EMPTY_VALUE){
         //Print(fractals_up[index_fractal]);
         lastFractal_Value = fractals_up[index_fractal];
         lastFractal_direction = FRACTAL_UP;
      }
      if (fractals_down[index_fractal] != EMPTY_VALUE){
         lastFractal_Value = fractals_down[index_fractal];
         lastFractal_direction = FRACTAL_DOWN;
      }
      
      if (lastFractal_Value != 0.0 && lastFractal_direction != FRACTAL_NEUTRAL){
         //Print("FRACTAL VALUE = ",lastFractal_Value);
         //Print("FRACTAL DIRECTION = ",getLastFractalDirection());
      }
      
//      Print("ALLIGATOR JAWS = ",NormalizeDouble(alligator_jaws[1],_Digits));
//      Print("ALLIGATOR TEETH = ",NormalizeDouble(alligator_teeth[1],_Digits));
//      Print("ALLIGATOR LIPS = ",NormalizeDouble(alligator_lips[1],_Digits));
//
//      Print("AO VALUES = ",NormalizeDouble(ao_values[1],_Digits+1));
      
      if (ac_color[1] == AC_COLOR_UP){
         //Print("AC COLOR UP GREEN = ",AC_COLOR_UP);
      }
      else if (ac_color[1] == AC_COLOR_DOWN){
         //Print("AC COLOR UP RED = ",AC_COLOR_DOWN);
      }
      
      bool isBreakdown_jaws_buy = alligator_jaws[1] < getClosePrice(1)
                                  && alligator_jaws[2] > getClosePrice(2);
      bool isBreakdown_jaws_sell = alligator_jaws[1] > getClosePrice(1)
                                  && alligator_jaws[2] < getClosePrice(2);

      if (lastFractal_direction == FRACTAL_DOWN
         && isBreakdown_jaws_buy
         && (ao_values[1] > 0 && ao_values[2] < 0)
         && ac_color[1] == AC_COLOR_UP){
         
         Print("BUY SIGNAL GENERATED");
         obj_Trade.Buy(10,_Symbol,getAsk());
      }
      if (lastFractal_direction == FRACTAL_UP
         && isBreakdown_jaws_sell
         && (ao_values[1] < 0 && ao_values[2] > 0)
         && ac_color[1] == AC_COLOR_DOWN){
         
         Print("SELL SIGNAL GENERATED");
         obj_Trade.Sell(10,_Symbol,getBid());
      }
      
      if (ao_values[1] < 0 && ao_values[2] > 0){
         if (PositionsTotal() > 0){
            Print("CLOSE ALL BUY POSITIONS");
            for (int i=0; i<PositionsTotal(); i++){
               ulong pos_ticket = PositionGetTicket(i);
               if (pos_ticket > 0 && PositionSelectByTicket(pos_ticket)){
                  ENUM_POSITION_TYPE pos_type = (ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE);
                  if (pos_type == POSITION_TYPE_BUY){
                     obj_Trade.PositionClose(pos_ticket);
                  }
               }
            }
         }
      }
      else if (ao_values[1] > 0 && ao_values[2] < 0){
         if (PositionsTotal() > 0){
            Print("CLOSE ALL SELL POSITIONS");
            for (int i=0; i<PositionsTotal(); i++){
               ulong pos_ticket = PositionGetTicket(i);
               if (pos_ticket > 0 && PositionSelectByTicket(pos_ticket)){
                  ENUM_POSITION_TYPE pos_type = (ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE);
                  if (pos_type == POSITION_TYPE_SELL){
                     obj_Trade.PositionClose(pos_ticket);
                  }
               }
            }
         }
      }
      
      
   }
   
   
}
//+------------------------------------------------------------------+

bool isNewBar(){
   
   static int prevBars = 0;
   int currBars = iBars(_Symbol,_Period);
   if (prevBars == currBars) return (false);
   prevBars = currBars;
   return (true);
   
}

string getLastFractalDirection(){
   string direction_fractal = "NEUTRAL";
   
   if (lastFractal_direction == FRACTAL_UP) return ("UP");
   else if (lastFractal_direction == FRACTAL_DOWN) return ("DOWN");
   
   return (direction_fractal);
}

double getClosePrice(int bar_index){
   return (iClose(_Symbol,_Period,bar_index));
}

double getAsk(){
   return (NormalizeDouble(SymbolInfoDouble(_Symbol,SYMBOL_ASK),_Digits));
}

double getBid(){
   return (NormalizeDouble(SymbolInfoDouble(_Symbol,SYMBOL_BID),_Digits));
}