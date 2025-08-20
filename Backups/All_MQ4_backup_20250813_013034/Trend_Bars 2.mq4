


#property indicator_separate_window

#property indicator_buffers 2
#property indicator_color1 Lime
#property indicator_color2 Red

//---- input parameters
extern int PeriodRSI=14;
extern ENUM_APPLIED_PRICE RSIPrice = PRICE_CLOSE;
//---- indicator buffers
double UpBuffer[];
double DnBuffer[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
  int init()
  {
   string short_name;
//---- indicator line
   SetIndexStyle(0,DRAW_HISTOGRAM,STYLE_SOLID,3);
   SetIndexStyle(1,DRAW_HISTOGRAM,STYLE_SOLID,3);
   SetIndexBuffer(0,UpBuffer);
   SetIndexBuffer(1,DnBuffer);
   IndicatorDigits(MarketInfo(Symbol(),MODE_DIGITS));
//---- name for DataWindow and indicator subwindow label
   short_name="Trend Bars("+PeriodRSI+")";
   IndicatorShortName(short_name);
   SetIndexLabel(0,"UpTrend");
   SetIndexLabel(1,"DownTrend");
//----
   SetIndexDrawBegin(0,PeriodRSI);
   SetIndexDrawBegin(1,PeriodRSI);
//----
   return(0);
  }

//+------------------------------------------------------------------+
//| RSIFilter_v1                                                         |
//+------------------------------------------------------------------+
int start()
  {
   int shift,trend;
   double RSI0;

   
   for(shift=Bars-PeriodRSI-1;shift>=0;shift--)
   {	
   RSI0=iRSI(NULL,0,PeriodRSI,RSIPrice,shift);
	  if (RSI0>70)  trend=1; 
	  if (RSI0<30)  trend=-1;
	  
	  if (trend>0) 
	  {
	  if (RSI0 > 40  ) UpBuffer[shift]=1.0;
	  else UpBuffer[shift] = 1.0;
	  DnBuffer[shift]=0;
	  }
	  if (trend<0) 
	  {
	  if (RSI0 < 60  ) DnBuffer[shift]=1.0;
	  else DnBuffer[shift] = 1.0;
	  UpBuffer[shift]=0;
	  }
	}
	return(0);	
 }