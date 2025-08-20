//+------------------------------------------------------------------+
//|                                                   Supertrend.mq4 |
//|                   Copyright © 2005, Jason Robinson (jnrtrading). |
//|                                      http://www.jnrtrading.co.uk |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2005, Jason Robinson (jnrtrading)."
#property link      "http://www.jnrtrading.co.uk"

#property indicator_chart_window
#property indicator_buffers 2
#property indicator_color1 Lime
#property indicator_color2 Red
#property indicator_width1 2
#property indicator_width2 2

extern int CCIperiod=50;
extern int ATRperiod=5;
int applied_price=5; 


double TrLine[];
double trend[];
double TrendUp[];
double TrendDown[];



//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators
   IndicatorBuffers(4);
   SetIndexStyle(0, DRAW_LINE);
   SetIndexBuffer(0, TrendUp);
   SetIndexLabel(0,"Trend Up");
   SetIndexStyle(1, DRAW_LINE);
   SetIndexBuffer(1, TrendDown);
   SetIndexLabel(1,"Trend Down");
   SetIndexBuffer(2, TrLine);
   SetIndexBuffer(3, trend);
   
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custor indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {
   
   int limit, i;
   double cciTrendNow;

   int counted_bars = IndicatorCounted();
//---- check for possible errors
   if(counted_bars < 0) return(-1);
//---- last counted bar will be recounted
   if(counted_bars > 0) counted_bars--;

   limit=Bars-counted_bars;
   
   for(i = limit; i >= 0; i--) 
     {cciTrendNow = iCCI(NULL, 0, CCIperiod, applied_price, i);
      
      if (cciTrendNow >= 0) 
        {TrLine[i] = NormalizeDouble(Low[i] - iATR(NULL, 0, ATRperiod, i),Digits);    
         if (TrLine[i] < TrLine[i+1]) 
            {TrLine[i] = TrLine[i+1];
            }
        }
      else if (cciTrendNow <= 0) {
         TrLine[i] = NormalizeDouble(High[i] + iATR(NULL, 0, ATRperiod, i),Digits);
         if (TrLine[i] > TrLine[i+1]) {
            TrLine[i] = TrLine[i+1];
         }
      }
   }
   
for (i=limit; i>=0; i--)
{

        trend[i] = trend[i+1];
        if (TrLine[i]> TrLine[i+1]) trend[i] =1;
        if (TrLine[i]< TrLine[i+1]) trend[i] =-1;
    
    if (trend[i]>0)
    { TrendUp[i] = TrLine[i]; 
      if (trend[i+1]<0) TrendUp[i+1]=TrLine[i+1];
      TrendDown[i] = EMPTY_VALUE;
    }
    else              
    if (trend[i]<0)
    { 
      TrendDown[i] = TrLine[i]; 
      if (trend[i+1]>0) TrendDown[i+1]=TrLine[i+1];
      TrendUp[i] = EMPTY_VALUE;
    }              
}
   return(0);
  }
//+------------------------------------------------------+