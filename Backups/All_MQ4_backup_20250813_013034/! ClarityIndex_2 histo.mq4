//+------------------------------------------------------------------+
//|                                                 ClarityIndex.mq4 |
//|                                       Copyright 2020, PuguForex. |
//|                          https://www.mql5.com/en/users/puguforex |
//+------------------------------------------------------------------+
#property copyright "Copyright 2020, PuguForex."
#property link      "https://www.mql5.com/en/users/puguforex"
#property strict
#property indicator_separate_window
#property indicator_buffers 2

input int                Lookback         = 14;                         // Lookback Period
input int                Smoothing        = 14;                         // Smoothing Period
input ENUM_MA_METHOD     Method           = MODE_EMA;                   // Smoothing Method
input bool               NewMethod        = true;                       // New Formula
input int                HistoWidth       = 3;                          // Histogram bars width
input color              UpHistoColor     = clrDarkGreen;               // Bullish color
input color              DnHistoColor     = clrCrimson;                 // Bearish color

double huu[],hdd[],bulls[],bears[],pos[],neg[],volUp[],volDn[],vi[],ci[],valc[];

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+

int OnInit()
{
   IndicatorBuffers(11);
   SetIndexBuffer(0,  huu,INDICATOR_DATA); SetIndexStyle(0,DRAW_HISTOGRAM,EMPTY,HistoWidth,UpHistoColor);
   SetIndexBuffer(1,  hdd,INDICATOR_DATA); SetIndexStyle(1,DRAW_HISTOGRAM,EMPTY,HistoWidth,DnHistoColor);  
   SetIndexBuffer(2,  bulls);
   SetIndexBuffer(3,  bears);
   SetIndexBuffer(4,  pos);
   SetIndexBuffer(5,  neg);
   SetIndexBuffer(6,  volUp);
   SetIndexBuffer(7,  volDn);
   SetIndexBuffer(8,  vi);
   SetIndexBuffer(9,  ci);
   SetIndexBuffer(10, valc); 
   
   IndicatorSetDouble(INDICATOR_MINIMUM,0);
   IndicatorSetDouble(INDICATOR_MAXIMUM,1);

   IndicatorSetString(INDICATOR_SHORTNAME,"Clarity Index("+(string)Lookback+","+(string)Smoothing+")");
   return(INIT_SUCCEEDED);
  }
int deinit() { return(0); } 
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int  OnCalculate(const int rates_total,const int prev_calculated,const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
{
   int limit=fmin(rates_total-prev_calculated+1,rates_total-1);
   
   //
   //
   //
   
   for(int i=limit; i>=0; i--)
   {
      bulls[i] = (i<Bars-1) ? Close[i]>Close[i+1] ? High[i]-Low[i] : 0 : 0;
      bears[i] = (i<Bars-1) ? Close[i]<Close[i+1] ? High[i]-Low[i] : 0 : 0;
      pos[i]   = bulls[i]==0 ? 0 : 1;
      neg[i]   = bears[i]==0 ? 0 : 1;
      volUp[i] = bulls[i]==0 ? 0 : (int)Volume[i];
      volDn[i] = bears[i]==0 ? 0 : (int)Volume[i];
      
      double bullsSum = 1;
      double bearsSum = 1;
      double posSum   = 1;
      double negSum   = 1;
      double volSum   = 1;
      double upSum    = 1;
      double dnSum    = 1;
      int k           = 1;
      
      for (k=1; k<Lookback && (i+k)<Bars; k++)
      {
       volSum   += (int)Volume[i+k];
       bullsSum += bulls[i+k];
       bearsSum += bears[i+k];
       posSum   += pos[i+k];
       negSum   += neg[i+k];
       upSum    += volUp[i+k];
       dnSum    += volDn[i+k];
      }
      
      double gain = (NewMethod) ? (upSum/Lookback)*(bullsSum/Lookback)*posSum : (volSum/Lookback)*(bullsSum/Lookback)*posSum; 
      double loss = (NewMethod) ? (dnSum/Lookback)*(bearsSum/Lookback)*negSum : (volSum/Lookback)*(bearsSum/Lookback)*negSum;
                  
      vi[i]   = gain-loss;
      ci[i]   = iMAOnArray(vi,0,Smoothing,0,Method,i);
      valc[i] = (i<Bars-1) ? (ci[i]>0) ? 1 : (ci[i]<0) ? -1 : valc[i+1] : 0;
      huu[i]  = (valc[i]== 1) ? 1 : EMPTY_VALUE;
      hdd[i]  = (valc[i]==-1) ? 1 : EMPTY_VALUE;  
   }   
return(rates_total);
}

