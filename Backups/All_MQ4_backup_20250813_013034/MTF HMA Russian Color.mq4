//+------------------------------------------------------------------+
//|                                            MTF_MovingAverage.mq4 |
//|                                      Copyright © 2006, Keris2112 |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2006, Keris2112" //MTF version
#property link      "http://www.forex-tsd.com"
#property copyright "MT4 release WizardSerg ForexMagazine #104" //Original version
#property link      "wizardserg@mail.ru" 

#property indicator_chart_window
#property indicator_buffers 8
#property indicator_color1 Silver
#property indicator_color2 Silver
#property indicator_color3 Silver
#property indicator_color4 Silver
#property indicator_color5 Silver
#property indicator_color6 Silver
#property indicator_color7 Aqua
#property indicator_color8 Tomato


//---- input parameters
/*************************************************************************
PERIOD_M1   1
PERIOD_M5   5
PERIOD_M15  15
PERIOD_M30  30 
PERIOD_H1   60
PERIOD_H4   240
PERIOD_D1   1440
PERIOD_W1   10080
PERIOD_MN1  43200
You must use the numeric value of the timeframe that you want to use
when you set the TimeFrame' value with the indicator inputs.
---------------------------------------
PRICE_CLOSE    0 Close price. 
PRICE_OPEN     1 Open price. 
PRICE_HIGH     2 High price. 
PRICE_LOW      3 Low price. 
PRICE_MEDIAN   4 Median price, (high+low)/2. 
PRICE_TYPICAL  5 Typical price, (high+low+close)/3. 
PRICE_WEIGHTED 6 Weighted close price, (high+low+close+close)/4. 
You must use the numeric value of the Applied Price that you want to use
when you set the 'applied_price' value with the indicator inputs.
---------------------------------------
MODE_SMA    0 Simple moving average, 
MODE_EMA    1 Exponential moving average, 
MODE_SMMA   2 Smoothed moving average, 
MODE_LWMA   3 Linear weighted moving average. 
You must use the numeric value of the MA Method that you want to use
when you set the 'ma_method' value with the indicator inputs.

**************************************************************************/
extern int TimeFrame=0;
extern int MAPeriod=21;
extern int ma_method=MODE_SMA;
extern int applied_price=PRICE_CLOSE;
extern bool UseLevels=False;
extern int Level0=0;
extern int Level1=0;
extern int Level2=0;
extern int Level3=0;
extern int Level4=0;
extern int Level5=0;


double ExtMapBuffer1[];
double ExtMapBuffer2[];
double ExtMapBuffer3[];
double ExtMapBuffer4[];
double ExtMapBuffer5[];
double ExtMapBuffer6[];
double ExtMapBuffer7[];
double ExtMapBuffer8[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
   string short_name;
//---- indicator line
   SetIndexBuffer(0,ExtMapBuffer1);
   SetIndexStyle(0,DRAW_LINE,STYLE_DOT);
   SetIndexBuffer(1,ExtMapBuffer2);
   SetIndexStyle(1,DRAW_LINE,STYLE_DOT);
   SetIndexBuffer(2,ExtMapBuffer3);
   SetIndexStyle(2,DRAW_LINE,STYLE_DOT);
   SetIndexBuffer(3,ExtMapBuffer4);
   SetIndexStyle(3,DRAW_LINE,STYLE_DOT);
   SetIndexBuffer(4,ExtMapBuffer5);
   SetIndexStyle(4,DRAW_LINE,STYLE_DOT);
   SetIndexBuffer(5,ExtMapBuffer6);
   SetIndexStyle(5,DRAW_LINE,STYLE_DOT);
   SetIndexBuffer(6,ExtMapBuffer7);
   SetIndexStyle(6,DRAW_LINE);
   SetIndexBuffer(7,ExtMapBuffer8);
   SetIndexStyle(7,DRAW_LINE);
//---- name for DataWindow and indicator subwindow label   
   switch(ma_method)
     {
      case 1 : short_name="MTF_HMA_EMA("; break;
      case 2 : short_name="MTF_HMA_SMMA("; break;
      case 3 : short_name="MTF_HMA_LWMA("; break;
      default : short_name="MTF_HMA_SMA(";
     }
   switch(TimeFrame)
   {
      case 1 : string TimeFrameStr="Period_M1"; break;
      case 5 : TimeFrameStr="Period_M5"; break;
      case 15 : TimeFrameStr="Period_M15"; break;
      case 30 : TimeFrameStr="Period_M30"; break;
      case 60 : TimeFrameStr="Period_H1"; break;
      case 240 : TimeFrameStr="Period_H4"; break;
      case 1440 : TimeFrameStr="Period_D1"; break;
      case 10080 : TimeFrameStr="Period_W1"; break;
      case 43200 : TimeFrameStr="Period_MN1"; break;
      default : TimeFrameStr="Current Timeframe";
   } 
   IndicatorShortName(short_name+MAPeriod+") "+TimeFrameStr);  
  }
//----
   return(0);
 
//+------------------------------------------------------------------+
//| MTF Moving Average                                   |
//+------------------------------------------------------------------+
int start()
  {
   datetime TimeArray[];
   int    i,shift,limit,y=0,counted_bars=IndicatorCounted();
    
// Plot defined timeframe on to current timeframe   
   ArrayCopySeries(TimeArray,MODE_TIME,Symbol(),TimeFrame); 
   
   limit=Bars-counted_bars+TimeFrame/Period();
   for(i=0,y=0;i<limit;i++)
   {
   if (Time[i]<TimeArray[y]) y++; 
   
 /***********************************************************   
   Add your main indicator loop below.  You can reference an existing
      indicator with its iName  or iCustom.
   Rule 1:  Add extern inputs above for all neccesary values   
   Rule 2:  Use 'TimeFrame' for the indicator timeframe
   Rule 3:  Use 'y' for the indicator's shift value
 **********************************************************/  
    
   ExtMapBuffer7[i]=iCustom(NULL,TimeFrame,"HMA_Russian_Color",MAPeriod,ma_method,applied_price,0,y);
   ExtMapBuffer8[i]=iCustom(NULL,TimeFrame,"HMA_Russian_Color",MAPeriod,ma_method,applied_price,1,y);
   
   if(UseLevels)
   {
   ExtMapBuffer1[i]=(ExtMapBuffer7[i]+(Level0*Point));
   ExtMapBuffer2[i]=(ExtMapBuffer7[i]+(Level1*Point));
   ExtMapBuffer3[i]=(ExtMapBuffer7[i]+(Level2*Point));
   ExtMapBuffer4[i]=(ExtMapBuffer7[i]+(Level3*Point));
   ExtMapBuffer5[i]=(ExtMapBuffer7[i]+(Level4*Point));
   ExtMapBuffer6[i]=(ExtMapBuffer7[i]+(Level5*Point));
   }
   }  
     
//
   
  
  
   return(0);
  }
//+------------------------------------------------------------------+