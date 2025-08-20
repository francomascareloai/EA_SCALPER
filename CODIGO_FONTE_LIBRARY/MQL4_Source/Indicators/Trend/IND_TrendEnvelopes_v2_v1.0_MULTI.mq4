//+------------------------------------------------------------------+
//|                                            TrendEnvelopes_v2.mq4 |
//|                           Copyright ? 2007, TrendLaboratory Ltd. |
//|            http://finance.groups.yahoo.com/group/TrendLaboratory |
//|                                   E-mail: igorad2003@yahoo.co.uk |
//+------------------------------------------------------------------+
#property copyright "Copyright ? 2007, TrendLaboratory Ltd."
#property link      "http://finance.groups.yahoo.com/group/TrendLaboratory"
//---- indicator settings
#property indicator_chart_window
#property indicator_buffers 4
#property indicator_color1 LightBlue
#property indicator_color2 Orange
#property indicator_width1 2
#property indicator_width2 2
#property indicator_color3 LightBlue
#property indicator_color4 Orange
#property indicator_width3 1
#property indicator_width4 1
//---- indicator parameters
extern int     MA_Period      = 10;
extern int     MA_Method      =  0;
extern int     UseSignal      =  0; 
extern int     AlertMode      =  0;
extern int     WarningMode    =  0;

//---- indicator buffers
double UpBuffer[];
double DnBuffer[];
double UpSignal[];
double DnSignal[]; 
double smax[];
double smin[];
double trend[];

//----
int ExtCountedBars=0;
bool UpTrendAlert=false, DownTrendAlert=false;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
   int    draw_begin;
   string short_name;
//---- drawing settings
   IndicatorBuffers(7);
   SetIndexStyle(0,DRAW_LINE);
   SetIndexStyle(1,DRAW_LINE);
   SetIndexStyle(2,DRAW_ARROW);
   SetIndexArrow(2,108);
   SetIndexStyle(3,DRAW_ARROW);
   SetIndexArrow(3,108);
   
   IndicatorDigits(MarketInfo(Symbol(),MODE_DIGITS));
   if(MA_Period<2) MA_Period=10;
   draw_begin=MA_Period-1;
//---- indicator short name
   IndicatorShortName("TrendEnvelopes("+MA_Period+")");
   SetIndexLabel(0,"UpTrendEnv");
   SetIndexLabel(1,"DnTrendEnv");
   SetIndexLabel(2,"UpSignal");
   SetIndexLabel(3,"DnSignal");
   SetIndexDrawBegin(0,draw_begin);
   SetIndexDrawBegin(1,draw_begin);
   SetIndexDrawBegin(2,draw_begin);
   SetIndexDrawBegin(3,draw_begin);
   //---- indicator buffers mapping
   SetIndexBuffer(0,UpBuffer);
   SetIndexBuffer(1,DnBuffer);
   SetIndexBuffer(2,UpSignal);
   SetIndexBuffer(3,DnSignal);
   SetIndexBuffer(4,smax);
   SetIndexBuffer(5,smin);
   SetIndexBuffer(6,trend);
//---- initialization done
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {
   int limit;
   if(Bars<=MA_Period) return(0);
   ExtCountedBars=IndicatorCounted();
//---- check for possible errors
   if (ExtCountedBars<0) return(-1);
//---- last counted bar will be recounted
   if (ExtCountedBars>0) ExtCountedBars--;
   limit=Bars-ExtCountedBars;
//---- EnvelopesM counted in the buffers
   for(int i=limit; i>=0; i--)
     { 
      smax[i] = iMA(NULL,0,MA_Period,0,MA_Method,PRICE_HIGH,i);
      smin[i] = iMA(NULL,0,MA_Period,0,MA_Method,PRICE_LOW,i);
   
      trend[i]=trend[i+1]; 
	   
	   if (Close[i]>smax[i+1])  trend[i]=1; 
	   if (Close[i]<smin[i+1])  trend[i]=-1;

	   if(trend[i]>0)
	   {
	   if (smin[i]<smin[i+1]) smin[i]=smin[i+1];
	   UpBuffer[i]=smin[i];
	     if (UseSignal>0)
	     { 
	        if (trend[i+1]<0) 
	        {
	        UpSignal[i] = smin[i];
	        if (WarningMode>0 && i==0) PlaySound("alert2.wav");
	        }
	        else UpSignal[i] = EMPTY_VALUE;
	     }
	   DnBuffer[i]=EMPTY_VALUE;
	   DnSignal[i]=EMPTY_VALUE; 
	   }
	   else
	   {
	   if(smax[i]>smax[i+1]) smax[i]=smax[i+1];
	   DnBuffer[i]=smax[i];
	     if (UseSignal>0)
	     { 
	        if (trend[i+1]>0) 
	        {
	        DnSignal[i] = smax[i];
	        if (WarningMode>0 && i==0) PlaySound("alert2.wav");
	        }
	        else DnSignal[i] = EMPTY_VALUE;
	     }
	   UpBuffer[i]=EMPTY_VALUE;
	   UpSignal[i]=EMPTY_VALUE; 
	   }
   }
//----------   
   string Message;
   
   if ( trend[2]<0 && trend[1]>0 && Volume[0]>1 && !UpTrendAlert)
	  {
	  Message = " "+Symbol()+" M"+Period()+": Signal for BUY";
	  if ( AlertMode>0 ) Alert (Message); 
	  UpTrendAlert=true; DownTrendAlert=false;
	  } 
	 	  
	  if ( trend[2]>0 && trend[1]<0 && Volume[0]>1 && !DownTrendAlert)
	  {
	  Message = " "+Symbol()+" M"+Period()+": Signal for SELL";
	  if ( AlertMode>0 ) Alert (Message); 
	  DownTrendAlert=true; UpTrendAlert=false;
	  } 	         
//---- done
   return(0);
  }
//+------------------------------------------------------------------+