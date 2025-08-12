//+------------------------------------------------------------------+
//|                                      Custom MA Envelopes Ind.mq5 |
//|                                  Copyright 2024, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, mutiiriallan.forex@gmail.com."
#property link      "mutiiriallan.forex@gmail.com"
#property description "Incase of anything with this Version of EA, Contact:\n"
                      "\nEMAIL: mutiiriallan.forex@gmail.com"
                      "\nWhatsApp: +254 782 526088"
                      "\nTelegram: https://t.me/Forex_Algo_Trader"
#property version   "1.00"
#property indicator_chart_window

#property indicator_buffers 3
#property indicator_plots 3

//--- plot1 details
#property indicator_type1 DRAW_LINE
#property indicator_color1 clrBlue
#property indicator_label1 "Upper Mod SMA" // shown on the data window

//--- plot2 details
#property indicator_type2 DRAW_LINE
#property indicator_color2 clrBlack
#property indicator_label2 "Middle Mod SMA" // shown on the data window
#property indicator_width2 1

//--- plot3 details
#property indicator_type3 DRAW_LINE
#property indicator_color3 clrRed
#property indicator_label3 "Lower Mod SMA" // shown on the data window

double upper_SMA[];
double middle_SMA[];
double lower_SMA[];

int handle_sma = INVALID_HANDLE; // -1

//--- ma period
int sma_period = 14;
double sma_deviation = 0.3;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit(){
//--- indicator buffers mapping
   SetIndexBuffer(0,upper_SMA,INDICATOR_DATA);
   SetIndexBuffer(1,middle_SMA,INDICATOR_DATA);
   SetIndexBuffer(2,lower_SMA,INDICATOR_DATA);
   
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,sma_period+1);
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,sma_period+1);
   PlotIndexSetInteger(2,PLOT_DRAW_BEGIN,sma_period+1);
   
   PlotIndexSetInteger(0,PLOT_SHIFT,1);
   PlotIndexSetInteger(1,PLOT_SHIFT,1);
   PlotIndexSetInteger(2,PLOT_SHIFT,1);
   
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,0.0);
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,0.0);
   PlotIndexSetDouble(2,PLOT_EMPTY_VALUE,0.0);
   
   string short_name = "SMA ("+IntegerToString(sma_period)+")";
   IndicatorSetString(INDICATOR_SHORTNAME,short_name);
   
   PlotIndexSetString(0,PLOT_LABEL,short_name+" Upper");
   PlotIndexSetString(1,PLOT_LABEL,short_name+" Middle");
   PlotIndexSetString(2,PLOT_LABEL,short_name+" Lower");
   
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits+1);
   
   handle_sma = iMA(_Symbol,_Period,sma_period,0,MODE_SMA,PRICE_CLOSE);
   
   if (handle_sma == INVALID_HANDLE){
      Print("UNABLE TO CREATE THE SMA IND HANDLE. REVERTING.");
      return (INIT_FAILED);
   }
   
//---
   return(INIT_SUCCEEDED);
}
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
{
//---
   
   if (rates_total < sma_period){
      Print("LESS NUMBER OF BARS FOR THE SINGLE MA CALCULATION. REVERTING.");
      return (0);
   }
   
   if (BarsCalculated(handle_sma) < rates_total){
      Print("NOT ENOUGH DATA CALCULATED FOR THE SMA IND. REVERTING.");
      return (0);
   }
   
   //--- IF THIS IS THE FIRST CALL
   if (prev_calculated == 0){
      Print("THIS IS THE FIRST CALL OF THE INDICATOR. DO INITIAL COMPUTATIONS.");
      
      ArrayFill(upper_SMA,0,rates_total,0);
      ArrayFill(middle_SMA,0,rates_total,0);
      ArrayFill(lower_SMA,0,rates_total,0);
      
      double sma_data[];
      if (CopyBuffer(handle_sma,0,0,rates_total,sma_data) < rates_total){
         Print("NOT ENOUGH DATA FROM SMA IND FOR CALCULATIONS. REVERTING.");
         return (0);
      }
      //ArrayPrint(sma_data);
      
      int start = sma_period+1; // 14+1=15
      
      for (int i = start; i < rates_total && !IsStopped(); i++){
         middle_SMA[i] = sma_data[i];
         upper_SMA[i] = (1+sma_deviation/100.0)*middle_SMA[i];
         lower_SMA[i] = (1-sma_deviation/100.0)*middle_SMA[i];
      }
      
      #define obj_prefix "IND"
      datetime currTime = iTime(_Symbol,_Period,0)+1*PeriodSeconds();
      drawRightPrice(obj_prefix+ "MID",currTime,middle_SMA[rates_total-1],clrBlack);
      drawRightPrice(obj_prefix+ "UPPER",currTime,upper_SMA[rates_total-1],clrBlue);
      drawRightPrice(obj_prefix+ "LOWER",currTime,lower_SMA[rates_total-1],clrRed);
      //--- successfully calculated
      return(rates_total);
   }
   
   int start = prev_calculated -1;
   
   for (int i = start; i < rates_total && !IsStopped(); i++){
      
      int reverse_index = (rates_total - prev_calculated) + 0;
      
      double sma_data[];
      if (CopyBuffer(handle_sma,0,reverse_index,1,sma_data) < 1){
         Print("NOT ENOUGH DATA FROM SMA IND FOR CALCULATIONS. REVERTING.");
         return (prev_calculated);
      }
      
      middle_SMA[i] = sma_data[0];
      upper_SMA[i] = (1+sma_deviation/100.0)*middle_SMA[i];
      lower_SMA[i] = (1-sma_deviation/100.0)*middle_SMA[i];
      
      //#define obj_prefix "IND"
      datetime currTime = iTime(_Symbol,_Period,0)+1*PeriodSeconds();
      drawRightPrice(obj_prefix+ "MID",currTime,middle_SMA[i],clrBlack);
      drawRightPrice(obj_prefix+ "UPPER",currTime,upper_SMA[i],clrBlue);
      drawRightPrice(obj_prefix+ "LOWER",currTime,lower_SMA[i],clrRed);

   }
   
//--- return value of prev_calculated for next call
   return(rates_total);
}
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|         On Deinit function                                       |
//+------------------------------------------------------------------+
void OnDeinit(const int reason){
   ObjectsDeleteAll(0,obj_prefix,0,OBJ_ARROW_RIGHT_PRICE);
   ChartRedraw(0);
}

bool drawRightPrice(string objName,datetime time,double price,color clr){
   if (!ObjectCreate(0,objName,OBJ_ARROW_RIGHT_PRICE,0,time,price)){
      Print("UNABLE TO CREATE THE RIGHT PRICE ARROW OBJ. REVERTING NOW.");
      return (false);
   }
   
   int width = 1;
   
   long scale = 0;
   if (!ChartGetInteger(0,CHART_SCALE,0,scale)){
      Print("UNABLE TO GET THE CHART SCALE. DEFAULT OF ",scale," IS CONSIDERED");
   }
   
   //Print("CHART SCALE = ",scale);
   // 0 = minimized, 5 = maximized
   if (scale==0){width=1;}
   else if (scale==1){width=1;}
   else if (scale==2){width=2;}
   else if (scale==3){width=2;}
   else if (scale==4){width=3;}
   else if (scale==5){width=3;}

   ObjectSetInteger(0,objName,OBJPROP_COLOR,clr);
   ObjectSetInteger(0,objName,OBJPROP_WIDTH,width);
   ObjectSetInteger(0,objName,OBJPROP_STYLE,STYLE_SOLID);
   ObjectSetInteger(0,objName,OBJPROP_BACK,false);
   ObjectSetInteger(0,objName,OBJPROP_SELECTABLE,false);
   ObjectSetInteger(0,objName,OBJPROP_SELECTED,false);
   
   ChartRedraw(0);
   return (true);
}