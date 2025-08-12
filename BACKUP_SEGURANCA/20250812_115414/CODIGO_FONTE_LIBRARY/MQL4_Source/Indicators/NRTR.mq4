//+------------------------------------------------------------------+
//|                                                         NRTR.mq4 |
//|                                                                  |
//|                                        Ramdass - Conversion only |
//+------------------------------------------------------------------+

#property indicator_chart_window
#property indicator_buffers 2
#property indicator_color1 Aqua
#property indicator_color2 Violet
//---- input parameters
extern int AveragePeriod=10;
extern int CountBars=300;
//---- buffers
double value1[];
double value2[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {

//---- indicator line
   IndicatorBuffers(2);
   SetIndexStyle(0,DRAW_ARROW);
   SetIndexArrow(0,159);
   SetIndexStyle(1,DRAW_ARROW);
   SetIndexArrow(1,159);
   SetIndexBuffer(0,value1);
   SetIndexBuffer(1,value2);
//----
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| NRTR                                                             |
//+------------------------------------------------------------------+
int start()
  {
   if (CountBars>Bars) CountBars=Bars;
   SetIndexDrawBegin(0,Bars-CountBars+1);
   SetIndexDrawBegin(1,Bars-CountBars+1);
   int i,counted_bars=IndicatorCounted();
   double value;
   double trend=0,dK,AvgRange,price;
//----
   if(Bars<=AveragePeriod) return(0);
//---- initial zero
   if(counted_bars<1)
   {
      for(i=1;i<=AveragePeriod;i++) value1[Bars-i]=0.0;
      for(i=1;i<=AveragePeriod;i++) value2[Bars-i]=0.0;
   }


AvgRange=0;
for (i=1 ; i<=AveragePeriod ; i++) AvgRange+= MathAbs(High[i]-Low[i]);
if (Symbol() == "USDJPY" || Symbol() == "GBPJPY" || Symbol() == "EURJPY")
{dK = (AvgRange/AveragePeriod)/100;}
else {dK = AvgRange/AveragePeriod;}

if (Close[CountBars-1] > Open[CountBars-1])
   {
   value1[CountBars - 1] = Close[CountBars - 1] * (1 - dK);
   trend = 1; value2[CountBars - 1] = 0.0;
   }
if (Close[CountBars-1] < Open[CountBars-1])  {
   value2[CountBars - 1] = Close[CountBars - 1] * (1 + dK);
   trend = -1; value1[CountBars - 1] = 0.0;
   }
//----
   i=CountBars-1;
   while(i>=0)
     {
value1[i]=0; value2[i]=0;
if (trend >= 0)
       {
       if (Close[i] > price) price = Close[i];
       value = price * (1 - dK);
       if (Close[i] < value)
          {
          price = Close[i];
          value = price * (1 + dK);
          trend = -1;
          }
       } 
    else
       { 
    if (trend <= 0)
       {
       if (Close[i] < price) price = Close[i];
       value = price * (1 + dK);
       if (Close[i] > value) 
          {
          price = Close[i];
          value = price * (1 - dK);
          trend = 1;
          }
       }
       }
if (trend == 1)  {value1[i]=value; value2[i]=0.0;}
if (trend == -1)  {value2[i]=value; value1[i]=0.0;}

      i--;
     }
   return(0);
  }
//+------------------------------------------------------------------+