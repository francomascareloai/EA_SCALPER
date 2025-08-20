//+------------------------------------------------------------------+
//|                                                         NRTR.mq4 |
//|            Copyright © 2005, VG many thanks to Konkop and dupidu |
//|                                                      4vg@mail.ru |
//+------------------------------------------------------------------+
#property copyright "VG many thanks to Konkop and dupidu"

#property indicator_chart_window
#property  indicator_buffers 4
#property  indicator_color1  Blue
#property  indicator_color2  Red
#property  indicator_color3  Magenta
#property  indicator_color4  Yellow


double     ind_buffer1[];
double     ind_buffer2[];
double     ind_buffer3[];
double     ind_buffer4[];

extern double AveragePeriod = 40;
extern bool OCnotAverage = true;
extern int MaxBarsToCount = 200;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- drawing settings
   SetIndexStyle(0,DRAW_ARROW,STYLE_SOLID,1);
   SetIndexDrawBegin(0,AveragePeriod);
   SetIndexStyle(1,DRAW_ARROW,STYLE_SOLID,1);
   SetIndexDrawBegin(1,AveragePeriod);
   SetIndexStyle(2,DRAW_ARROW,STYLE_SOLID,3);
   SetIndexDrawBegin(2,AveragePeriod);
   SetIndexStyle(3,DRAW_ARROW,STYLE_SOLID,3);
   SetIndexDrawBegin(3,AveragePeriod);
   
//---- indicator buffers mapping
   if(!SetIndexBuffer(0,ind_buffer1) && !SetIndexBuffer(1,ind_buffer2)
      && !SetIndexBuffer(2,ind_buffer3)&& !SetIndexBuffer(3,ind_buffer4))
      Print("cannot set indicator buffers!");
//---- name for DataWindow and indicator subwindow label
   IndicatorShortName("NRTR");
   SetIndexLabel(0,"Sell S/L");
   SetIndexLabel(1,"Buy S/L");
   SetIndexLabel(2,"Sell S/L");
   SetIndexLabel(3,"Buy S/L");

//---- initialization done
   return(0);
  }
//+------------------------------------------------------------------+
//| Custor indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
//---- TODO: add your code here
   
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {
   int bar, limit, PrevAlertTime;
   double value = 0;
   double price = 0;
   double trend, dK, AvgRange, HLTrend;
//---- TODO: add your code here
   if(Bars<=MaxBarsToCount) return(-1);

for (int shift=MaxBarsToCount; shift>=0; shift--)
    {
    ind_buffer1[shift]=0;
    ind_buffer2[shift]=0;
    ind_buffer3[shift]=0;
    ind_buffer4[shift]=0;
    }

AvgRange=0;
for (int i=1; i<=AveragePeriod; i++) AvgRange+= MathAbs(High[i]-Low[i]);
dK = AvgRange/AveragePeriod/Point/10000;  

if (OCnotAverage)
{
if (Close[MaxBarsToCount] > Open[MaxBarsToCount]) 
   {
   value = Close[MaxBarsToCount] * (1 - dK);
   trend = 1;
   ind_buffer2[MaxBarsToCount] = value;
   }
if (Close[MaxBarsToCount] < Open[MaxBarsToCount]) 
   {
   value = Close[MaxBarsToCount] * (1 + dK);
   trend = -1;
   ind_buffer1[MaxBarsToCount] = value;
   }
for (bar = MaxBarsToCount - 1; bar >= 0; bar--) 
    {
    if (trend >= 0) 
       {
       if (Low[bar] > price)  price = Close[bar];
       value = price * (1 - dK);
       if (Close[bar] < value) 
          {
          price = Close[bar];
          value = price * (1 + dK);
          trend = -1;
          }
       } 
    else 
    if (trend <= 0) 
       {
       if (High[bar] < price) price = Close[bar];
       value = price * (1 + dK);
       if (Close[bar] > value) 
          {
          price = Close[bar];
          value = price * (1 - dK);
          trend = 1;
          }
       }
    if (trend == -1) ind_buffer1[bar] = value;
    if (trend == 1) ind_buffer2[bar] = value;
    }
    if (CurTime() - PrevAlertTime > Period()*60)
    {
    if ((ind_buffer1[0] != ind_buffer1[1]) || (ind_buffer2[0] != ind_buffer2[1]))
       {
       Alert("Новый S/L на ",value);
       PrevAlertTime = CurTime();
       }
    } 
        
}
else
{    
if ((High[MaxBarsToCount] + Low[MaxBarsToCount])/2 > (High[MaxBarsToCount-1] + Low[MaxBarsToCount-1])/2) 
   {
   value = (High[MaxBarsToCount] + Low[MaxBarsToCount])/2 * (1 - dK);
   HLTrend = 1;
   ind_buffer4[MaxBarsToCount] = value;
   } 
   else
   {
   value = (High[MaxBarsToCount] + Low[MaxBarsToCount])/2 * (1 + dK);
   HLTrend = -1;
   ind_buffer3[MaxBarsToCount] = value;
   }
for (bar = MaxBarsToCount - 1; bar >= 0; bar--) 
    {
    if (HLTrend >= 0) 
       {
       if (Low[bar] > price) price = (High[bar] + Low[bar])/2;
       value = price * (1 - dK);
       if ((High[bar] + Low[bar])/2 < value) 
          {
          price = (High[bar] + Low[bar])/2;
          value = price * (1 + dK);
          HLTrend = -1;
          }
       } 
    else 
    if (HLTrend <= 0) 
       {
       if (High[bar] < price) price = (High[bar] + Low[bar])/2;
       value = price * (1 + dK);
       if ((High[bar] + Low[bar])/2 > value) 
          {
          price = (High[bar] + Low[bar])/2;
          value = price * (1 - dK);
          HLTrend = 1;
          }
       }
    if (HLTrend == -1) ind_buffer3[bar] = value;
    if (HLTrend == 1) ind_buffer4[bar] = value;
    } 
    if (CurTime() - PrevAlertTime > Period()*60)
    {
    if ((ind_buffer3[0] != ind_buffer3[1]) || (ind_buffer4[0] != ind_buffer4[1]))
       {
       Alert("Новый S/L на ",value);
       PrevAlertTime = CurTime();
       }
    } 
}
  
//----
   return(0);
  }
//+------------------------------------------------------------------+

