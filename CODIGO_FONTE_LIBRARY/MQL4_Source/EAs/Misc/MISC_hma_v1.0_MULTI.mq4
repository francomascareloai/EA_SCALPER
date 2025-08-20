//+------------------------------------------------------------------+
//|                                                         HMA2.mq4 |
//|                                                           jnr314 |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "jnr314"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

#include <MovingAverages.mqh>

//The Hull Moving Average (HMA), developed by Alan Hull, is an extreme-
//ly fast and smooth moving average that almost eliminates lag altoge-
//ther and manages to improve smoothing at the same time.To calculate
//it, firts, you have to calculate a difference between two LWMA of
//periods p/2 and p and then calculate another LWMA from this differen-
//ce but with a period of square root of p

//--- indicator settings
#property indicator_chart_window 
#property indicator_buffers 2 
#property indicator_color1 Black
#property indicator_style1 0
#property indicator_width1 1
#property indicator_color2 DeepSkyBlue
#property indicator_style2 0
#property indicator_width2 2

//---- input parameters 
input int                 HMAPeriod=13;           // Period 
input int                 HMAShift=0;             // Shift
input ENUM_MA_METHOD      InpMAMethod=MODE_LWMA;  // Method
//Actually, the HMA uses LWMA but you can change it if you want 
//writting MODE_SMA (simple moving average)or MODE_EMA (exponential
//moving average) or MODE_SMMA (smoothed moving average) instead of
//MODE_LWMA (linear-weighted moving average).
input ENUM_APPLIED_PRICE  InpMAPrice=5;           // Price
//Here you chose the price which the moving averages will be applied:
//0-close price, 1-open price, 2-high price, 3-low price, 4- median 
//price , 5-typical price, 6-weighted price.

//---- indicator buffers 
double    HMABuffer[];
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
   SetIndexStyle(0,DRAW_NONE);//If you want see the line (that is the 
//difference between the two LWMAs) on the chart, change in this line,
//DRAW_NONE to DRAW_LINE. This line is very similar to the final HMA 
//line for this reason I prefer that it stay invisible
   SetIndexShift(0,HMAShift);
   SetIndexStyle(1,DRAW_LINE);
   SetIndexShift(1,HMAShift);
   SetIndexDrawBegin(1,HMAPeriod);
//--- indicator buffers mapping  
   SetIndexBuffer(0,HMABuffer);
   SetIndexBuffer(1,ExtSignalBuffer);
//--- name for indicator label       
   IndicatorShortName("Hull Moving Average("+IntegerToString(HMAPeriod)
                      +","+IntegerToString(HMAShift)+")");
   SetIndexLabel(0,"Hull Moving Average");
//--- check for input parameters
   if(HMAPeriod<=1)
     {
      Print("Wrong input parameters");
      ExtParameters=false;
      return(INIT_FAILED);
     }
   else
      ExtParameters=true;
//--- initialization done
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+ 
//| Hull Moving Average                                              |
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
   int p = (int)floor(MathSqrt(HMAPeriod));
   int medp = (int)floor(HMAPeriod/2);
//---
   if(rates_total<=HMAPeriod || !ExtParameters)
      return(0);
//--- last counted bar will be recounted
   limit=rates_total-prev_calculated;
   if(prev_calculated>0)
      limit++;

//--- hull moving average 1st buffer
   for(i=0; i<limit; i++)     
      HMABuffer[i]=2*iMA(NULL,0,medp,0,InpMAMethod,InpMAPrice,i)
                    -iMA(NULL,0,HMAPeriod,0,InpMAMethod,InpMAPrice,i);
//--- hull moving average 2nd buffer     
   int weightsum;
   for(i=p;i>0;i--)
      weightsum+=i;
      LinearWeightedMAOnBuffer(rates_total,prev_calculated,0,p,HMABuffer,ExtSignalBuffer,weightsum);
//--- done
   return(rates_total);
  }
//+------------------------------------------------------------------+
