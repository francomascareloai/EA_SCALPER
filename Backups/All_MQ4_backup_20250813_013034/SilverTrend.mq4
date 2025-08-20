//+------------------------------------------------------------------+
//| SilverTrend.mq4 
//| Ramdass - Conversion only
//+------------------------------------------------------------------+
#property copyright "SilverTrend  rewritten by CrazyChart"
#property link      "http://viac.ru/"

#property indicator_chart_window
#property indicator_buffers 2
#property indicator_color1 Blue
#property indicator_color2 Red


//---- input parameters
extern int RISK=3;
extern int SSP=9;
extern int CountBars=350;

//---- buffers
double val1[];
double val2[];

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
   string short_name;
//---- indicator line
   IndicatorBuffers(2);
   SetIndexStyle(0,DRAW_HISTOGRAM,0,2);
   SetIndexStyle(1,DRAW_HISTOGRAM,0,2);
   SetIndexBuffer(0,val1);
   SetIndexBuffer(1,val2);
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| SilverTrend                                                      |
//+------------------------------------------------------------------+
int start()
  {   
   if (CountBars>=Bars) CountBars=Bars;
   SetIndexDrawBegin(0,Bars-CountBars+SSP);
   SetIndexDrawBegin(1,Bars-CountBars+SSP);
   int i,shift,counted_bars=IndicatorCounted();
   int i1,i2,x1=70,x2=30,K;
   double Range,AvgRange,smin,smax,SsMax,SsMin,price;
//----
   if(Bars<=SSP+1) return(0);
//---- initial zero
   if(counted_bars<SSP+1)
   {
      for(i=1;i<=SSP;i++) val1[CountBars-i]=0.0;
      for(i=1;i<=SSP;i++) val2[CountBars-i]=0.0;
   }
//----

K=33-RISK;
for (shift = CountBars-SSP; shift>=0; shift--) 
{ 

SsMax=High[shift]; SsMin=Low[shift]; 
   for (i2=shift;i2<=shift+SSP-1;i2++)
        {
         price=High[i2];
         if(SsMax<price) SsMax=price;
         price=Low[i2];
         if(SsMin>=price) SsMin=price;
        }

smin = SsMin+(SsMax-SsMin)*K/100; 
smax = SsMax-(SsMax-SsMin)*K/100; 
	val1[shift]=0;
	val2[shift]=0;
	if (Close[shift]<smin)
		{
		val1[shift]=Low[shift]; val2[shift]=High[shift];
		}
	if (Close[shift]>smax)
		{
		val1[shift]=High[shift]; val2[shift]=Low[shift];
		}

}
   return(0);
  }
//+------------------------------------------------------------------+