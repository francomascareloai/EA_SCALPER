//+------------------------------------------------------------------+
//|                                                  TrendRSI_v3.mq4 |
//|                          Typical RSI revised By TrendLaboratory  |
//|            http://finance.groups.yahoo.com/group/TrendLaboratory |
//|                                       E-mail: igorad2004@list.ru |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2005, TrendLaboratory Ltd."
#property link      "http://finance.groups.yahoo.com/group/TrendLaboratory"

#property indicator_separate_window
#property indicator_buffers 3
#property indicator_color1 Silver
#property indicator_color2 LightBlue
#property indicator_color3 Tomato
//---- input parameters
extern int RSIPeriod=14;
extern int EMAPeriod= 5;
extern int ATRPeriod=14;
extern double K=2.618;

//---- buffers

double RSIindex[];
double UpTrend[];
double DnTrend[];
double RSIBuffer[];
double smin[];
double smax[];
double trend[];

int MAPeriod=1;
int Price=0;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
   string short_name;
//---- 2 additional buffers are used for counting.
   IndicatorBuffers(7);
//---- indicator line
   SetIndexStyle(0,DRAW_LINE);
   SetIndexBuffer(0,RSIindex);
   SetIndexStyle(1,DRAW_ARROW);
   SetIndexBuffer(1,UpTrend);
   SetIndexStyle(2,DRAW_ARROW);
   SetIndexBuffer(2,DnTrend);
   SetIndexArrow(1,159);
   SetIndexArrow(2,159);
   SetIndexBuffer(3,RSIBuffer);
   SetIndexBuffer(4,smin);
   SetIndexBuffer(5,smax);
   SetIndexBuffer(6,trend);
   
   
//---- name for DataWindow and indicator subwindow label
   short_name="TrendRSI("+RSIPeriod+","+EMAPeriod+","+ATRPeriod+","+DoubleToStr(K,3)+")";
   IndicatorShortName(short_name);
   SetIndexLabel(0,short_name);
   SetIndexLabel(1,"UpTrend");   
   SetIndexLabel(2,"DownTrend"); 
//----
   
   SetIndexDrawBegin(0,RSIPeriod+EMAPeriod+ATRPeriod);
   SetIndexDrawBegin(1,RSIPeriod+EMAPeriod+ATRPeriod);
   SetIndexDrawBegin(2,RSIPeriod+EMAPeriod+ATRPeriod);
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| TrendRSI_v3                                                       |
//+------------------------------------------------------------------+
int start()
{
   int    i,limit,counted_bars=IndicatorCounted();
   double rel;
//----

   if ( counted_bars < 0 ) return(-1);
   if ( counted_bars ==0 ) limit=Bars-1;
   if ( counted_bars < 1 ) 
   
   for( i=1;i<RSIPeriod+EMAPeriod+ATRPeriod;i++) 
   {
   RSIindex[Bars-i]=0.0;
   UpTrend[Bars-i]=0.0;
   DnTrend[Bars-i]=0.0;
   }
   
   if(counted_bars>0) limit=Bars-counted_bars;
   limit--;
   
   for( i=limit; i>=0; i--)
   {
   double sumn=0.0,sump=0.0;
      for (int k=RSIPeriod-1;k>=0;k--)
      { 
      rel=iMA(NULL,0,MAPeriod,0,MODE_SMA,Price,i+k)-iMA(NULL,0,MAPeriod,0,MODE_SMA,Price,i+k+1);
      if(rel>0) sump+=rel; else sumn-=rel;
      }
   double pos=sump/RSIPeriod;
   double neg=sumn/RSIPeriod;
                  
   if(neg==0.0) RSIBuffer[i]=100.0;
   else 
   RSIBuffer[i]=100.0-100.0/(1.0+pos/neg);
      
   RSIindex[i]=RSIindex[i+1]+2.0/(1.0+EMAPeriod)*(RSIBuffer[i]-RSIindex[i+1]);
      
            
   double AvgRange=0;
      for ( k=ATRPeriod-1;k>=0;k--)
      AvgRange+=MathAbs(RSIindex[i+k]-RSIindex[i+k+1]);
      
   double Range = AvgRange/ATRPeriod;
      
	smax[i]=RSIindex[i]+K*Range;
	smin[i]=RSIindex[i]-K*Range;
		
	trend[i]=trend[i+1]; 
	if (RSIindex[i]>smax[i+1])  trend[i]=1; 
	if (RSIindex[i]<smin[i+1])  trend[i]=-1;

      if(trend[i]>0)
	   {
	   if (smin[i]<smin[i+1]) smin[i]=smin[i+1];
	   UpTrend[i]=smin[i];
	   DnTrend[i]=EMPTY_VALUE;
	   }
	   else
	   {
	   if(smax[i]>smax[i+1]) smax[i]=smax[i+1];
	   UpTrend[i]=EMPTY_VALUE;
	   DnTrend[i]=smax[i];
	   } 
   }
//----
   return(0);
}
//+------------------------------------------------------------------+