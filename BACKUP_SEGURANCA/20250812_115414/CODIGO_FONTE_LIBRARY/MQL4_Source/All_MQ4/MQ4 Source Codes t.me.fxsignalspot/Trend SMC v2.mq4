//+------------------------------------------------------------------+
//|                                                    SMC Trend.mq4 |
//|                                                  Copyright © 2004|
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2004"
#property link      "na"

#property indicator_separate_window
#property indicator_buffers 3
#property indicator_color1 DarkOliveGreen
#property indicator_color2 FireBrick
#property indicator_color3 Red


//---- input parameters
extern int TPeriodMA=24;
extern int TPeriodL= 8;
//---- buffers
double TBuffer[];
double HorizBuffer[];
double AvgBuffer[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
   string short_name;
//---- indicator line
   SetIndexStyle(0,DRAW_LINE);
   SetIndexBuffer(0,TBuffer);
   SetIndexStyle(1,DRAW_LINE,1);
   SetIndexBuffer(1,HorizBuffer);
   SetIndexStyle(2,DRAW_LINE,0,2,Red);
   SetIndexBuffer(2,AvgBuffer);
//---- name for DataWindow and indicator subwindow label
   short_name="SMC Trend("+TPeriodMA+")";
   IndicatorShortName(short_name);
   SetIndexLabel(0,short_name);
//----
   SetIndexDrawBegin(0,TPeriodMA);
   SetIndexDrawBegin(1,TPeriodMA);
   SetIndexDrawBegin(2,TPeriodMA);
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Trend                                                        |
//+------------------------------------------------------------------+
int start()
  {
   int i,x,cnt;
   int counted_bars=IndicatorCounted();
   double Total;
//----
   if(Bars<=TPeriodMA) return(0);
//---- initial zero
   if(counted_bars<1)
      for(i=1;i<=TPeriodMA;i++) TBuffer[Bars-i]=0.0;
//----

   i=Bars-TPeriodMA-1;
   if(counted_bars>=TPeriodMA) i=Bars-counted_bars-1;
   while(i>=0)
     {
      Total=0;
      x=0;
      while (x < TPeriodMA)
       {Total=Total + Close[i+x]; 
        x=x+1;
        }
        Total= Total / TPeriodMA; //Calculates Simple MA for TPeriod for Current Bar
      
      x=0;
      cnt=0;
      while(x < TPeriodL+1)
      {if(High[i+x] > Total && Low[i+x] < Total) cnt= cnt+1;
       x=x+1;
       } 

      TBuffer[i] = cnt;
      HorizBuffer[i] = TPeriodL/2;
      AvgBuffer[i] = (TBuffer[i] + TBuffer[i+1])/2;
      i--;
     }
 return(0);
  }
//+------------------------------------------------------------------+