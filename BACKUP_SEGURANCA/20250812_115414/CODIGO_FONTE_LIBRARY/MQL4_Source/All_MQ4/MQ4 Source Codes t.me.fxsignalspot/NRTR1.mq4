//+------------------------------------------------------------------+
//|                                                         NRTR.mq4 |
//|                                                       Nick Bilak |
//+------------------------------------------------------------------+

#property indicator_chart_window
#property indicator_buffers 2
#property indicator_color1 Blue
#property indicator_color2 Red
//---- input parameters
extern int AveragePeriod=10;
extern int CountBars=300;
//---- buffers
double value1[];
double value2[];
int trend=1;
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
   int i,j,counted_bars=IndicatorCounted();
   double value;
   double dK,ap,AvgRange,price;
   ap=AveragePeriod;
//----
   if(Bars<=AveragePeriod) return(0);

   i=CountBars-1;
   while(i>=0) {
     value1[i]=0; value2[i]=0;
     AvgRange=0;
     for (j=i ; j<i+AveragePeriod; j++) 
         AvgRange += MathAbs((Ask-Bid)+High[j]-Low[j]);
     dK = AvgRange/ap;
     if (Close[i]>10) dK=dK/100.0;

     if (trend >= 0) {
       if (Close[i] > price) {
       	price = Close[i];
       	value = price - dK;
       	trend=1;
       }
       if (Close[i] < value)  {
          price = Close[i];
          value = price + dK;
          trend = -1;
       }
     }
     else if (trend <= 0) {
       if (Close[i] < price) {
       	price = Close[i];
       	value = price + dK;
       	trend=-1;
       }
       if (Close[i] > value) {
          price = Close[i];
          value = price - dK;
          trend = 1;
       }
    }
    if (trend == 1)  {value1[i]=value; value2[i]=0.0;}
    if (trend == -1)  {value2[i]=value; value1[i]=0.0;}

    i--;
  }
  return(0);
}

