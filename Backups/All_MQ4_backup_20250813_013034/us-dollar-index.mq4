//+------------------------------------------------------------------+
//|                                                 Dollar Index.mq4 |
//|                                  Copyright © 2009, Andy Thompson |
//|                                   mailto:andydoc1@googlemail.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2009, Andy Thompson"
#property link      "mailto:andydoc1@googlemail.com"

#property indicator_separate_window
#property indicator_buffers 3
#property indicator_color1 Red
#property indicator_width1 2
#property indicator_color2 Yellow
#property indicator_width2 1
#property indicator_style2 1
#property indicator_color3 Lime
#property indicator_width3 1
#property indicator_style3 2
//---- buffers
double ExtMapBuffer1[];
double ExtMapBuffer2[];
double ExtMapBuffer3[];

extern int short_term_SMA_period =20;
extern int long_term_SMA_period =40;

//int winind;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators
   SetIndexStyle(0,DRAW_LINE);
   SetIndexBuffer(0,ExtMapBuffer1);
   SetIndexLabel(0,"DXY");
   SetIndexStyle(1,DRAW_LINE);
   SetIndexBuffer(1,ExtMapBuffer2);
   SetIndexLabel(1,short_term_SMA_period+"SMA");
   SetIndexStyle(2,DRAW_LINE);
   SetIndexBuffer(2,ExtMapBuffer3);
   SetIndexLabel(2,long_term_SMA_period+"SMA");   
   IndicatorShortName("Dollar Index: DXY / "+short_term_SMA_period+"SMA / "+long_term_SMA_period+"SMA");
// winind = WindowFind("Dollar Index: DXY / "+short_term_SMA_period+"SMA / "+long_term_SMA_period+"SMA"); 
   
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
//----
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {
     int limit;
     int counted_bars=IndicatorCounted();
  //---- check for possible errors
     if(counted_bars<0) return(-1);
  //---- the last counted bar will be recounted
     if(counted_bars>0) counted_bars--;
     limit=Bars-counted_bars;
  //---- main loop
     for(int i=0; i<limit; i++)
       {
        ExtMapBuffer1[i]=50.14348112 * MathPow(iClose("EURUSD",0,i),-0.576) * MathPow(iClose("USDJPY",0,i),0.136) * MathPow(iClose("GBPUSD",0,i),-0.119) * MathPow(iClose("USDCAD",0,i),0.091) * MathPow(iClose("USDSEK",0,i),0.042) * MathPow(iClose("USDCHF",0,i),0.036);
       }
     for(i=0; i<limit; i++)
       {
        ExtMapBuffer2[i]=0;
        ExtMapBuffer3[i]=0;
        for(int z=0; z<long_term_SMA_period; z++)
          {       
           if(z<short_term_SMA_period) ExtMapBuffer2[i]=ExtMapBuffer2[i]+ExtMapBuffer1[i+z];
           ExtMapBuffer3[i]=ExtMapBuffer3[i]+ExtMapBuffer1[i+z];  
          }
        ExtMapBuffer2[i] = ExtMapBuffer2[i]/short_term_SMA_period;
        ExtMapBuffer3[i] = ExtMapBuffer3[i]/long_term_SMA_period;
       } 
  //---- done
     return(0);
  }
//+------------------------------------------------------------------+