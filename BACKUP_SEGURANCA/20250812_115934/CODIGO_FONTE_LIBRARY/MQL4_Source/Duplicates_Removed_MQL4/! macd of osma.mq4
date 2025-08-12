//+------------------------------------------------------------------+
//|                                               ! macd of osma.mq4 |
//+------------------------------------------------------------------+
#property copyright "www.forex-station.com"
#property link      "www.forex-station.com"
#property strict
#property indicator_separate_window
#property indicator_buffers 5
#property indicator_color1  clrGreen
#property indicator_color2  clrRed
#property indicator_color3  clrGray
#property indicator_color4  clrBlue
#property indicator_color5  clrGold
#property indicator_width3  2
#property indicator_width4  2
#property indicator_width5  2
#property strict

//
//
//

input double                  inpFastEma        = 12;                         // Fast ema period
input double                  inpSlowEma        = 26;                         // Slow ema period
input double                  inpSignalPeriod   = 9;                          // Signal period
input ENUM_APPLIED_PRICE      inpPrice          = PRICE_CLOSE;                // Price
sinput string                 Display           = "Display settings";         //=================================  
input bool                    AutoHisto         = true;                       // Automatically adjust histo width
input int                     HistWidth         = 3;                          // Histogram bars width
input color                   UpHistoColor      = clrGreen;                   // Bullish color
input color                   DnHistoColor      = clrRed;                     // Bearish color

double huu[],hdd[],osma[],omac[],omas[],state[];
struct sGlobalStruct
{
   int     width,scale,lim;
   double  prc,alpF,alpS,alSi;
};
sGlobalStruct glo;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+

int OnInit()
{
   if (AutoHisto)
   {
      glo.scale = int(ChartGetInteger(0,CHART_SCALE));
      switch(glo.scale) 
	   {
	      case 0: glo.width =  1; break;
	      case 1: glo.width =  1; break;
		   case 2: glo.width =  2; break;
		   case 3: glo.width =  3; break;
		   case 4: glo.width =  6; break;
		   case 5: glo.width = 14; break;
	   }
	}
	else { glo.width = HistWidth; }
   IndicatorBuffers(6);
   SetIndexBuffer(0,huu, INDICATOR_DATA);  SetIndexStyle(0,DRAW_HISTOGRAM,EMPTY,glo.width,UpHistoColor);
   SetIndexBuffer(1,hdd, INDICATOR_DATA);  SetIndexStyle(1,DRAW_HISTOGRAM,EMPTY,glo.width,DnHistoColor); 
   SetIndexBuffer(2,osma,INDICATOR_DATA);  SetIndexStyle(2,DRAW_LINE); // osma of osma
   SetIndexBuffer(3,omac,INDICATOR_DATA);  SetIndexStyle(3,DRAW_LINE); // macd osma
   SetIndexBuffer(4,omas,INDICATOR_DATA);  SetIndexStyle(4,DRAW_LINE); // sign
   SetIndexBuffer(5,state,INDICATOR_CALCULATIONS);  
   
   glo.alpF = 2.0/(1.0+fmax(inpFastEma,1.0));
   glo.alpS = 2.0/(1.0+fmax(inpSlowEma,1.0));
   glo.alSi = 2.0/(1.0+fmax(inpSignalPeriod,1.0));
   
   IndicatorSetString(INDICATOR_SHORTNAME,"Macd of Osma ("+(string)inpFastEma+","+(string)inpSlowEma+","+(string)inpSignalPeriod+")");
return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+

int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
{
   if(ChartGetInteger(0,CHART_SCALE) != glo.width) OnInit();
   glo.lim = fmin(rates_total-prev_calculated+1,rates_total-1);
   
   //
   //
   //
   
   struct sWorkStruct
   {
     double fEma;
     double sEma;
     double macd;
     double sign;
     double fOma;
     double sOma;
     double oma;
   };
   static sWorkStruct wrk[];
   static int         wrkSize = -1;
                  if (wrkSize<rates_total) wrkSize = ArrayResize(wrk,rates_total+500);
   
   
   //
   //
   //
   
   for(int i=glo.lim, r=rates_total-glo.lim-1; i>=0; i--,r++)
   {
      glo.prc     = iMA(NULL,0,1,0,MODE_SMA,inpPrice,i);
      wrk[r].fEma = (r>0) ? wrk[r-1].fEma + glo.alpF*(glo.prc-wrk[r-1].fEma) : glo.prc;  // fast per
      wrk[r].sEma = (r>0) ? wrk[r-1].sEma + glo.alpS*(glo.prc-wrk[r-1].sEma) : glo.prc;  // slow per
      wrk[r].macd = wrk[r].fEma-wrk[r].sEma;
      wrk[r].sign = (r>0) ? wrk[r-1].sign + glo.alSi*(wrk[r].macd-wrk[r-1].sign) : wrk[r].macd;  // signal
      wrk[r].oma  = wrk[r].macd-wrk[r].sign;
      wrk[r].fOma = (r>0) ? wrk[r-1].fOma + glo.alpF*(wrk[r].oma-wrk[r-1].fOma) : wrk[r].oma;  // fast per
      wrk[r].sOma = (r>0) ? wrk[r-1].sOma + glo.alpS*(wrk[r].oma-wrk[r-1].sOma) : wrk[r].oma;  // slow per
      omac[i]     = wrk[r].fOma-wrk[r].sOma; // osma macd
      omas[i]     = (r>0) ? omas[i+1] + glo.alSi*(omac[i]-omas[i+1]) : omac[i];  // osma signal
      osma[i]     = omac[i]-omas[i];
      state[i]    = (r>0) ? (osma[i]>0) ? 1 : (osma[i]<0) ? -1 : state[i+1] : 0; 
      huu[i]      = (state[i] == 1) ? osma[i] : EMPTY_VALUE;
      hdd[i]      = (state[i] ==-1) ? osma[i] : EMPTY_VALUE;
   }
return(rates_total);
}
