//+------------------------------------------------------------------+
//|                                               ChandelierExit.mq4 |
//|                                                       MQLService |
//|                                           scripts@mqlservice.com |
//+------------------------------------------------------------------+
#property copyright "MQLService"
#property link      "scripts@mqlservice.com"

#property indicator_chart_window
#property indicator_buffers 4
//#property indicator_color1 Blue
//#property indicator_color2 Red
#property indicator_color3 Orange
#property indicator_color4 Magenta
//---- input parameters
extern int       Range=15;
extern int       Shift=1;
extern int       ATRPeriod=14;
extern int       MultipleATR=4;
//---- buffers
double ExtMapBuffer1[];
double ExtMapBuffer2[];
double ExtMapBuffer3[];
double ExtMapBuffer4[];
int direction=1;
double ATRvalue;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators
   //SetIndexStyle(0,DRAW_LINE);
   SetIndexBuffer(0,ExtMapBuffer1);
   //SetIndexStyle(1,DRAW_LINE);
   SetIndexBuffer(1,ExtMapBuffer2);
   SetIndexStyle(2,DRAW_LINE);
   SetIndexBuffer(2,ExtMapBuffer3);
   SetIndexEmptyValue(2,0.0);
   SetIndexStyle(3,DRAW_LINE);
   SetIndexBuffer(3,ExtMapBuffer4);
   SetIndexEmptyValue(3,0.0);
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custor indicator deinitialization function                       |
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
   if(counted_bars<0) counted_bars=0;
   if(counted_bars>0) counted_bars--;
   limit=Bars-counted_bars;
   for(int i=limit; i>=0; i--)
      {
         ATRvalue=iATR(NULL,0,ATRPeriod,0)*MultipleATR;
         ExtMapBuffer1[i]=High[Highest(NULL,0,MODE_HIGH,Range,i+Shift)]-ATRvalue;
         ExtMapBuffer2[i]=Low[Lowest(NULL,0,MODE_LOW,Range,i+Shift)]+ATRvalue;
         if(direction==1)
           { 
            if(Close[i+1]<ExtMapBuffer1[i+1])
               {
                  direction=-1;
                  ExtMapBuffer3[i]=ExtMapBuffer2[i];
               }
            else
                  ExtMapBuffer3[i]=ExtMapBuffer1[i];   
           }
         if(direction==-1)
           { 
            if(Close[i+1]>ExtMapBuffer2[i+1])
               {
                  direction=1;
                  ExtMapBuffer4[i]=ExtMapBuffer1[i];
               }
            else
                  ExtMapBuffer4[i]=ExtMapBuffer2[i];   
           }
      }   
   return(0);
  }
//+------------------------------------------------------------------+