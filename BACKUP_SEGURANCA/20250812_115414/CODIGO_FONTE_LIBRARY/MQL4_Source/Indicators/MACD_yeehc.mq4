//+------------------------------------------------------------------+
//|                                                  Custom MACD.mq4 |
//|                   Copyright 2005-2014, MetaQuotes Software Corp. |
//|                                              http://www.mql4.com |
//+------------------------------------------------------------------+

//added
// - up/downtrend text
// - label xy

#property copyright   "2005-2014, MetaQuotes Software Corp."
#property link        "http://www.mql4.com"
#property description "Moving Averages Convergence/Divergence"
#property strict

#include <MovingAverages.mqh>

//--- indicator settings
#property  indicator_separate_window
#property  indicator_buffers 2
#property  indicator_color1  Silver
#property  indicator_color2  Red
#property  indicator_width1  2
//--- indicator parameters
input int InpFastEMA=12;               // Fast EMA Period
input int InpSlowEMA=26;               // Slow EMA Period
input int InpSignalSMA=9;              // Signal SMA Period
input bool label_show = 0;             // Trend text? (-+histo)
input int label_font_size = 10;        // Font size
input int label_x = 225;               // x offset
input int label_y = 0;                 // y offset
input string label_up = "UPTREND";     // Text if up
input string label_dn = "DOWNTREND";   // Text if down
input color label_clr_up = clrLime;    // Color if up
input color label_clr_dn = clrRed;     // Color if down

//--- indicator buffers
double    ExtMacdBuffer[];
double    ExtSignalBuffer[];
//--- right input parameters flag
bool      ExtParameters=false;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit(void)
  {
   IndicatorDigits(Digits+1);
//--- drawing settings
   SetIndexStyle(0,DRAW_HISTOGRAM);
   SetIndexStyle(1,DRAW_LINE);
   SetIndexDrawBegin(1,InpSignalSMA);
//--- indicator buffers mapping
   SetIndexBuffer(0,ExtMacdBuffer);
   SetIndexBuffer(1,ExtSignalBuffer);
//--- name for DataWindow and indicator subwindow label
   string short_name = "MACD("+IntegerToString(InpFastEMA)+","+IntegerToString(InpSlowEMA)+","+IntegerToString(InpSignalSMA)+") w/trend label";
   IndicatorShortName(short_name);
   SetIndexLabel(0,"MACD");
   SetIndexLabel(1,"Signal");
//--- check for input parameters
   if(InpFastEMA<=1 || InpSlowEMA<=1 || InpSignalSMA<=1 || InpFastEMA>=InpSlowEMA)
     {
      Print("Wrong input parameters");
      ExtParameters=false;
      return(INIT_FAILED);
     }
   else
      ExtParameters=true;
//--- initialization done

   for(int iObj=ObjectsTotal()-1; iObj >= 0; iObj--)
   {
      string objname = ObjectName(iObj);
      if (StringFind(objname, "MACD Label") != -1)
      {  
         ObjectDelete(0,objname);
      }
   }
   if(label_show==1)
   {
      LabelCreate(NULL,"MACD Label",ChartWindowFind(NULL,short_name),0,label_x,label_y,"somehting","Arial",label_font_size,clrWhite,0,false,true,false);
   }

   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Moving Averages Convergence/Divergence                           |
//+------------------------------------------------------------------+
int OnCalculate (const int rates_total,
                 const int prev_calculated,
                 const datetime& time[],
                 const double& open[],
                 const double& high[],
                 const double& low[],
                 const double& close[],
                 const long& tick_volume[],
                 const long& volume[],
                 const int& spread[])
  {
   int i,limit;
//---
   if(rates_total<=InpSignalSMA || !ExtParameters)
      return(0);
//--- last counted bar will be recounted
   limit=rates_total-prev_calculated;
   if(prev_calculated>0)
      limit++;
//--- macd counted in the 1-st buffer
   for(i=0; i<limit; i++)
      ExtMacdBuffer[i]=iMA(NULL,0,InpFastEMA,0,MODE_EMA,PRICE_CLOSE,i)-
                    iMA(NULL,0,InpSlowEMA,0,MODE_EMA,PRICE_CLOSE,i);
//--- signal line counted in the 2-nd buffer
   SimpleMAOnBuffer(rates_total,prev_calculated,0,InpSignalSMA,ExtMacdBuffer,ExtSignalBuffer);
//--- done

   if(label_show==1)
   {
      if(ExtMacdBuffer[0] >= 0){ObjectSetString(NULL,"MACD Label",OBJPROP_TEXT,label_up);ObjectSet("MACD Label",OBJPROP_COLOR,label_clr_up);}
      if(ExtMacdBuffer[0] <  0){ObjectSetString(NULL,"MACD Label",OBJPROP_TEXT,label_dn);ObjectSet("MACD Label",OBJPROP_COLOR,label_clr_dn);}
   
   }





   return(rates_total);
  }
//+------------------------------------------------------------------+

bool LabelCreate( long              chart_ID=0,               // chart's ID
                  string            name="Label",             // label name
                  int               sub_window=0,             // subwindow index
                  ENUM_BASE_CORNER  corner=CORNER_LEFT_UPPER, // chart corner for anchoring
                  //ENUM_ANCHOR_POINT anchor=ANCHOR_CENTER, // Anchor type
                  int               x=0,                      // X coordinate
                  int               y=0,                      // Y coordinate
                  string            text="text",             // text
                  string            font="Arial",             // font
                  int               font_size=10,             // font size
                  color             clr=clrRed,               // color
                  double            angle=0.0,                // text slope
                  bool              back=false,               // in the background
                  bool              selectable=true,           //object can be selected        
                  bool              selection=false,          // highlight to move
                  bool              hidden=false,              // hidden in the object list
                  long              z_order=0)                // priority for mouse click
  {
      ResetLastError();
      ObjectCreate(chart_ID, name, OBJ_LABEL,sub_window, 0, 0);
      ObjectSet(name, OBJPROP_CORNER, corner);
      ObjectSet(name, OBJPROP_XDISTANCE, x);
      ObjectSet(name, OBJPROP_YDISTANCE, y);
      ObjectSetString(0, name, OBJPROP_TEXT, text);
      ObjectSetString(0, name, OBJPROP_FONT, font);
      ObjectSet(name, OBJPROP_FONTSIZE, font_size);
      ObjectSet(name, OBJPROP_COLOR, clr);
      ObjectSet(name, OBJPROP_ANGLE, angle);
      //ObjectSet(name, OBJPROP_ANCHOR, anchor);
      ObjectSet(name, OBJPROP_BACK, back);
      ObjectSet(name, OBJPROP_SELECTABLE, selectable);
      ObjectSet(name, OBJPROP_SELECTED,selection);
      ObjectSet(name, OBJPROP_HIDDEN, hidden);
      ObjectSet(name, OBJPROP_ZORDER, z_order);
      return(true);    
  }

void OnDeinit(const int reason)
{
      for(int iObj=ObjectsTotal()-1; iObj >= 0; iObj--)
      {
         string objname = ObjectName(iObj);
         if (StringFind(objname, "MACD Label") != -1)
         {  
            ObjectDelete(0,objname);
         }
      }
}
