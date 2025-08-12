//+------------------------------------------------------------------+
//|                                                      ProjectName |
//|                                      Copyright 2012, CompanyName |
//|                                       http://www.companyname.net |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2012, Isotope"
#property link      "https://twitter.com/IsotopeFX"

#property indicator_chart_window
#property indicator_buffers 2
#property indicator_color1 Magenta
#property indicator_color2 Aqua
#property indicator_width1 4
#property indicator_width2 4

extern int TimeFrame1=1440,
TimeFrame2=0,
Period1=9,
Period2=76;
extern string Method="0=SMA,1=EMA,2=SMMA,3=LWMA";
extern int Method1=1,
Method2=3;
extern string Price="0=Close,1=Open,2=High,3=Low,4=Median,5=Typical,6=Weighted";
extern int Price1=0,
Price2=6;

double MA1[],MA2[],Cloud1[],Cloud2[];
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int init()
  {
   SetIndexBuffer(0,MA2);
   SetIndexBuffer(1,MA1);

   SetIndexStyle(0,DRAW_HISTOGRAM);
   SetIndexStyle(1,DRAW_HISTOGRAM);

   SetIndexLabel(0,NULL);
   SetIndexLabel(1,NULL);

   if(Period()==43200)
     {
      Alert("Cannot work correctly on this timeframe.");
      Alert("Please change the timeframe W1 or less :D");
     }
   if(Period()==10080)
     {TimeFrame1=43200;}
   if(Period()==1440)
     {TimeFrame1=10080;}
   if(Period()==240)
     {TimeFrame1=1440;}
   if(Period()==60)
     {TimeFrame1=240;}
   if(Period()==30)
     {TimeFrame1=60;}
   if(Period()==15)
     {TimeFrame1=30;}
   if(Period()==5)
     {TimeFrame1=15;}
   if(Period()==1)
     {TimeFrame1=5;}

   return(0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int start()
  {
   datetime TimeArray1[],TimeArray2[];
   int    i,limit1,limit2,y=0;

   int counted_bars=IndicatorCounted();
   if(counted_bars < 0)  return(-1);
   if(counted_bars>0) counted_bars--;

   limit1=Bars-counted_bars;
   limit2=Bars-counted_bars;
   if(counted_bars==0) limit1-=1+TimeFrame1/Period();
   if(counted_bars==0) limit2-=1+TimeFrame2/Period();

   ArrayCopySeries(TimeArray1,MODE_TIME,Symbol(),TimeFrame1);
   ArrayCopySeries(TimeArray2,MODE_TIME,Symbol(),TimeFrame2);

   for(i=0,y=0;i<limit1;i++)
     {
      MathRound(MA1[i]);
      if (y<ArraySize(TimeArray1)) {if(Time[i]<TimeArray1[y]) y++;}
      MA1[i]=iMA(NULL,TimeFrame1,Period1,0,Method1,Price1,y);
     }
   for(i=0,y=0;i<limit2;i++)
     {
      if(Time[i]<TimeArray2[y]) y++;
      if (y<ArraySize(TimeArray2)) {if(Time[i]<TimeArray2[y]) y++;}
      MA2[i]=iMA(NULL,TimeFrame2,Period2,0,Method2,Price2,y);
     }

   return(0);
  }
//+------------------------------------------------------------------+
