//+------------------------------------------------------------------+
//|                                                 RSIFilter_v1.mq4 |
//|                                  Copyright © 2006, Forex-TSD.com |
//|                         Written by IgorAD,igorad2003@yahoo.co.uk |   
//|            http://finance.groups.yahoo.com/group/TrendLaboratory |                                      
//+------------------------------------------------------------------+
#property copyright "Copyright © 2006, Forex-TSD.com "
#property link      "http://www.forex-tsd.com/"

#property indicator_separate_window
#property indicator_minimum -2
#property indicator_maximum 2
#property indicator_buffers 2
#property indicator_color1 SkyBlue
#property indicator_color2 Orange

//---- input parameters
extern int PeriodRSI=14;
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
   SetIndexStyle(0,DRAW_HISTOGRAM,STYLE_SOLID,1);
   SetIndexStyle(1,DRAW_HISTOGRAM,STYLE_SOLID,1);
   SetIndexBuffer(0,UpBuffer);
   SetIndexBuffer(1,DnBuffer);
   IndicatorDigits(MarketInfo(Symbol(),MODE_DIGITS));
//---- name for DataWindow and indicator subwindow label
   short_name="RSI Filter("+PeriodRSI+")";
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
   RSI0=iRSI(NULL,0,PeriodRSI,PRICE_CLOSE,shift);
   	
	  if (RSI0>70)  trend=1; 
	  if (RSI0<30)  trend=-1;
	  
	  if (trend>0) 
	  {
	  if (RSI0 > 40) UpBuffer[shift]=1.0;
	  else UpBuffer[shift] = EMPTY_VALUE;
	  DnBuffer[shift]=0;
	  }
	  if (trend<0) 
	  {
	  if (RSI0 < 60) DnBuffer[shift]=-1.0;
	  else DnBuffer[shift] = EMPTY_VALUE;
	  UpBuffer[shift]=0;
	  }
	}
	return(0);	
 }

