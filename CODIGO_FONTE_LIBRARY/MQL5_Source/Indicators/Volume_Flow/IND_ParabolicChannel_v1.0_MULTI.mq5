//+------------------------------------------------------------------+
//|                                            Parabolic Channel.mq5 |
//|                              Copyright 2009-2024, MetaQuotes Ltd |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright   "2009-2024, MetaQuotes Ltd"
#property link        "http://www.mql5.com"
#property description "Parabolic Channel"

#property indicator_chart_window
#property indicator_buffers 3
#property indicator_plots   3
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrRoyalBlue
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
#property indicator_type2   DRAW_ARROW
#property indicator_width2  2
#property indicator_color2  clrDeepSkyBlue
#property indicator_type3   DRAW_LINE
#property indicator_color3  clrDarkOrange
#property indicator_style3  STYLE_SOLID
#property indicator_width3  1
//--- labels
#property indicator_label1  "Upper"
#property indicator_label2  "Parabolic"
#property indicator_label3  "Lower "

//--- input parameters
input double InpSARStep   =0.02; // Step
input double InpSARMaximum=0.2;  // Maximum
input bool   InpShowLabel =true; // Show price of level

//--- indicator buffers
double ExtUpperBuffer[];
double ExtParabolicBuffer[];
double ExtLowerBuffer[];

//--- indicator handle
int    ExtParabolicHandle;
//--- unique prefix to identify indicator objects
string ExtPrefixUniq;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- define buffers
   SetIndexBuffer(0, ExtUpperBuffer);
   SetIndexBuffer(1, ExtParabolicBuffer);
   SetIndexBuffer(2, ExtLowerBuffer);
   PlotIndexSetInteger(1,PLOT_ARROW,159);

//--- indicator name
   IndicatorSetString(INDICATOR_SHORTNAME, "Parabolic Channel");
//--- number of digits of indicator value
   IndicatorSetInteger(INDICATOR_DIGITS, _Digits);

//--- create indicators
   ExtParabolicHandle=iSAR(NULL,0,InpSARStep,InpSARMaximum);

//--- prepare prefix for objects
   string number=StringFormat("%I64d", GetTickCount64());
   ExtPrefixUniq=StringSubstr(number, StringLen(number)-4);
   ExtPrefixUniq=ExtPrefixUniq+"_PS";
   Print("Indicator \"Parabolic Channels\" started, prefix=", ExtPrefixUniq);

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
//--- write Parabolic SAR indicator values to the buffer
   if(CopyBuffer(ExtParabolicHandle, 0, 0, rates_total, ExtParabolicBuffer)<0)
      return(0);

//--- start calculations from the bar preceding the last one
   int start=prev_calculated-2;

//--- if this is the first calculation of the indicator
   if(prev_calculated==0)
     {
      start=1;
      ArrayFill(ExtUpperBuffer,0,rates_total,0);
      ArrayFill(ExtLowerBuffer,0,rates_total,0);
      ExtUpperBuffer[start-1]=close[start-1];
      ExtLowerBuffer[start-1]=open[start-1];
     }

   for(int i=start; i<rates_total; i++)
     {
      ExtUpperBuffer[i]=ExtUpperBuffer[i-1];
      ExtLowerBuffer[i]=ExtLowerBuffer[i-1];

      //--- check if the parabolic has jumped down
      if(close[i]>ExtParabolicBuffer[i] && close[i-1]<ExtParabolicBuffer[i-1])
         ExtLowerBuffer[i]=ExtParabolicBuffer[i];

      //--- check if the parabolic has jumped up
      if(close[i]<ExtParabolicBuffer[i] && close[i-1]>ExtParabolicBuffer[i-1])
         ExtUpperBuffer[i]=ExtParabolicBuffer[i];
     }

//--- draw labels on levels
   if(InpShowLabel)
     {
      ShowPriceLevels(time[rates_total-1], rates_total-1);
      ChartRedraw();
     }     

//--- succesfully calculated
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//--- delete all our graphical objects after use
   Print("Indicator \"Parabolic Channel\" stopped, delete all objects with prefix=", ExtPrefixUniq);
   ObjectsDeleteAll(0, ExtPrefixUniq, 0, OBJ_ARROW_RIGHT_PRICE);
   ChartRedraw(0);
  }  
//+------------------------------------------------------------------+
//|  Show prices' levels                                             |
//+------------------------------------------------------------------+
void ShowPriceLevels(datetime time, int last_index)
  {
   ShowRightPrice(ExtPrefixUniq+"_Upper", time, ExtUpperBuffer[last_index], clrRoyalBlue);
   ShowRightPrice(ExtPrefixUniq+"_Parabolic", time, ExtParabolicBuffer[last_index], clrDeepSkyBlue);
   ShowRightPrice(ExtPrefixUniq+"_Lower", time, ExtLowerBuffer[last_index], clrDarkOrange);
  }  
//+------------------------------------------------------------------+
//| Create or Update "Right Price Label" object                      |
//+------------------------------------------------------------------+
bool ShowRightPrice(const string name, datetime time, double price, color clr)
  {
   if(!ObjectCreate(0, name, OBJ_ARROW_RIGHT_PRICE, 0, time, price))
     {
      ObjectMove(0, name, 0, time, price);
      return(false);
     }

//--- make the label size adaptive
   long scale=2;
   if(!ChartGetInteger(0, CHART_SCALE, 0, scale))
     {
      //--- output an error message to the Experts journal
      Print(__FUNCTION__+", ChartGetInteger(CHART_SCALE) failed, error = ", GetLastError());
     }
   int width=scale>1 ? 2:1;  // if chart scale > 1, then label size = 2

   ObjectSetInteger(0, name, OBJPROP_COLOR, clr);
   ObjectSetInteger(0, name, OBJPROP_STYLE, STYLE_SOLID);
   ObjectSetInteger(0, name, OBJPROP_WIDTH, width);
   ObjectSetInteger(0, name, OBJPROP_BACK, false);
   ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);
   ObjectSetInteger(0, name, OBJPROP_SELECTED, false);
   ObjectSetInteger(0, name, OBJPROP_HIDDEN, true);
   ObjectSetInteger(0, name, OBJPROP_ZORDER, 0);

   return(true);
  }   
//+------------------------------------------------------------------+
