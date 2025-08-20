//+------------------------------------------------------------------+
//|                                              Silver-channels.mq4 |
//|                                     Copyright © 2004, AlexSilver |
//|                                                  http://viac.ru/ |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2004, AlexSilver"
#property link      "http://viac.ru/"

#property indicator_chart_window
#property indicator_buffers 8
#property indicator_color1 Silver
#property indicator_color2 Silver
#property indicator_color3 SkyBlue
#property indicator_color4 SkyBlue
#property indicator_color5 YellowGreen
#property indicator_color6 YellowGreen
#property indicator_color7 Magenta
#property indicator_color8 Magenta
//---- input parameters
extern int TSP=9;
extern int SSP=26;
extern double SilvCh=38.2;
extern double SkyCh=23.6;
extern double ZenCh=0;
extern double FutCh=61.8;
//---- buffers
double SCH_BufferH[];
double SCH_BufferL[];
double Sky_BufferH[];
double Sky_BufferL[];
double Zen_BufferH[];
double Zen_BufferL[];
double Fut_BufferL[];
double Fut_BufferH[];
//----
int a_begin;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//----
   SetIndexStyle(0,DRAW_LINE);
   SetIndexBuffer(0,SCH_BufferH);
   SetIndexDrawBegin(0,SSP-1);
   SetIndexLabel(0,"Silver-channel High");
//----
   SetIndexStyle(1,DRAW_LINE);
   SetIndexBuffer(1,SCH_BufferL);
   SetIndexDrawBegin(1,SSP-1);
   SetIndexLabel(1,"Silver-channel Low");
//----
   SetIndexStyle(2,DRAW_LINE);
   SetIndexBuffer(2,Sky_BufferH);
   SetIndexDrawBegin(2,SSP-1);
   SetIndexLabel(2,"Sky-channel High");
//----
   SetIndexStyle(3,DRAW_LINE);
   SetIndexBuffer(3,Sky_BufferL);
   SetIndexDrawBegin(3,SSP-1);
   SetIndexLabel(3,"Sky-channel Low");
//----
   SetIndexStyle(4,DRAW_LINE);
   SetIndexBuffer(4,Zen_BufferH);
   SetIndexDrawBegin(4,SSP-1);
   SetIndexLabel(4,"Zen-channel High");
//----
   SetIndexStyle(5,DRAW_LINE);
   SetIndexBuffer(5,Zen_BufferL);
   SetIndexDrawBegin(5,SSP-1);
   SetIndexLabel(5,"Zen-channel Low");
//----
   SetIndexStyle(6,DRAW_LINE);
   SetIndexBuffer(6,Fut_BufferL);
   SetIndexDrawBegin(6,SSP+TSP-1);
   SetIndexShift(6,TSP);
   SetIndexLabel(6,"Future-channel Low");
//----
   SetIndexStyle(7,DRAW_LINE);
   SetIndexBuffer(7,Fut_BufferH);
   SetIndexDrawBegin(7,SSP+TSP-1);
   SetIndexShift(7,TSP);
   SetIndexLabel(7,"Future-channel High");
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Silver-channels                                                       |
//+------------------------------------------------------------------+
int start()
  {
   int    i,k;
   int    counted_bars=IndicatorCounted();
   double high,low,price;
//----
   if(Bars<=SSP) return(0);
//---- initial zero
   if(counted_bars<1)
     {
      for(i=1;i<=SSP;i++) SCH_BufferH[Bars-i]=0; SCH_BufferL[Bars-i]=0; Sky_BufferH[Bars-i]=0; Sky_BufferL[Bars-i]=0; Zen_BufferH[Bars-i]=0; Zen_BufferL[Bars-i]=0; Fut_BufferL[Bars-i]=0; Fut_BufferH[Bars-i]=0;
     }
//---- 
   i=Bars-SSP;
   if(counted_bars>SSP) i=Bars-counted_bars-1;
   while(i>=0)
     {
      high=High[i]; low=Low[i]; k=i-1+SSP;
      while(k>=i)
        {
         price=High[k];
         if(high<price) high=price;
         price=Low[k];
         if(low>price)  low=price;
         k--;
        }
      SCH_BufferL[i]=low+(high-low)*SilvCh/100;
      SCH_BufferH[i]=high-(high-low)*SilvCh/100;
      Sky_BufferL[i]=low+(high-low)*SkyCh/100;
      Sky_BufferH[i]=high-(high-low)*SkyCh/100;
      Zen_BufferL[i]=low;
      Zen_BufferH[i]=high;
      Fut_BufferL[i]=low-(high-low)*FutCh/100;
      Fut_BufferH[i]=high+(high-low)*FutCh/100;
      i--;
     }
   }
//+------------------------------------------------------------------+