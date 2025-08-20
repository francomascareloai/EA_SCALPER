//+------------------------------------------------------------------+
//|                                    Indicator: trendTMACGLWMA.mq4 |
//|                                       Created with EABuilder.com |
//|                                             http://eabuilder.com |
//+------------------------------------------------------------------+
#property copyright "Created with EABuilder.com"
#property link      "http://eabuilder.com"
#property version   "1.00"
#property description ""

#include <stdlib.mqh>
#include <stderror.mqh>

//--- indicator settings
#property indicator_separate_window
#property indicator_buffers 3

#property indicator_type1 DRAW_HISTOGRAM
#property indicator_style1 STYLE_SOLID
#property indicator_width1 2
#property indicator_color1 0x00FF32
#property indicator_label1 "Buy"

#property indicator_type2 DRAW_HISTOGRAM
#property indicator_style2 STYLE_SOLID
#property indicator_width2 2
#property indicator_color2 0x0000FF
#property indicator_label2 "Sell"

#property indicator_type3 DRAW_HISTOGRAM
#property indicator_style3 STYLE_SOLID
#property indicator_width3 0
#property indicator_color3 0xFFFFFF
#property indicator_label3 ""

//--- indicator buffers
double Buffer1[];
double Buffer2[];
double Buffer3[];

extern int Period1 = 120;
double myPoint; //initialized in OnInit

void myAlert(string type, string message)
  {
   if(type == "print")
      Print(message);
   else if(type == "error")
     {
      Print(type+" | trendTMACGLWMA @ "+Symbol()+","+Period()+" | "+message);
     }
   else if(type == "order")
     {
     }
   else if(type == "modify")
     {
     }
  }

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {   
   IndicatorBuffers(3);
   SetIndexBuffer(0, Buffer1);
   SetIndexEmptyValue(0, 0);
   SetIndexBuffer(1, Buffer2);
   SetIndexEmptyValue(1, 0);
   SetIndexBuffer(2, Buffer3);
   SetIndexEmptyValue(2, 0);
   //initialize myPoint
   myPoint = Point();
   if(Digits() == 5 || Digits() == 3)
     {
      myPoint *= 10;
     }
   return(INIT_SUCCEEDED);
  }

//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
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
   int limit = rates_total - prev_calculated;
   //--- counting from 0 to rates_total
   ArraySetAsSeries(Buffer1, true);
   ArraySetAsSeries(Buffer2, true);
   ArraySetAsSeries(Buffer3, true);
   //--- initial zero
   if(prev_calculated < 1)
     {
      ArrayInitialize(Buffer1, 0);
      ArrayInitialize(Buffer2, 0);
      ArrayInitialize(Buffer3, 0);
     }
   else
      limit++;
   
   //--- main loop
   for(int i = limit-1; i >= 0; i--)
     {
      if (i >= MathMin(5000-1, rates_total-1-50)) continue; //omit some old rates to prevent "Array out of range" or slow calculation   
      //Indicator Buffer 1
      if(iMA(NULL, PERIOD_CURRENT, Period1, 0, MODE_LWMA, PRICE_CLOSE, i) < iCustom(NULL, PERIOD_CURRENT, "TMA+CG mladen NRP", "current time frame", 56, PRICE_WEIGHTED, 1.618, true, false, false, false, 0, i) //Moving Average < TMA+CG mladen NRP
      )
        {
         Buffer1[i] = 1; //Set indicator value at fixed value
        }
      else
        {
         Buffer1[i] = 0;
        }
      //Indicator Buffer 2
      if(iMA(NULL, PERIOD_CURRENT, Period1, 0, MODE_LWMA, PRICE_CLOSE, i) > iCustom(NULL, PERIOD_CURRENT, "TMA+CG mladen NRP", "current time frame", 56, PRICE_WEIGHTED, 1.618, true, false, false, false, 0, i) //Moving Average > TMA+CG mladen NRP
      )
        {
         Buffer2[i] = -1; //Set indicator value at fixed value
        }
      else
        {
         Buffer2[i] = 0;
        }
      //Indicator Buffer 3
      if(iMA(NULL, PERIOD_CURRENT, Period1, 0, MODE_LWMA, PRICE_CLOSE, i) == iCustom(NULL, PERIOD_CURRENT, "TMA+CG mladen NRP", "current time frame", 56, PRICE_WEIGHTED, 1.618, true, false, false, false, 0, i) //ZeroLAG_MA is equal to TMA+CG mladen NRP
      )
        {
         Buffer3[i] = 0; //Set indicator value at fixed value
        }
      else
        {
         Buffer3[i] = 0;
        }
     }
   return(rates_total);
  }
//+------------------------------------------------------------------+