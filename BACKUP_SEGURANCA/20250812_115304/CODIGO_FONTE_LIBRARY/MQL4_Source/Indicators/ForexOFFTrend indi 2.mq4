#property copyright "SilverTrend  rewritten by CrazyChart"
#property link      "http://viac.ru/ "

#property indicator_separate_window
#property indicator_buffers 2
#property indicator_color1 Blue
#property indicator_color2 Red

extern int SSP=10;
extern double Kmin=0.0;
extern double Kmax=50.0;
extern int CountBars=1000;

double ExtMapBuffer1[];
double ExtMapBuffer2[];

int init()
{
IndicatorBuffers(2);
SetIndexBuffer(0,ExtMapBuffer1);
SetIndexBuffer(1,ExtMapBuffer2);
SetIndexStyle(0,DRAW_LINE);
SetIndexStyle(1,DRAW_LINE);
return(0);
}

int start()
{
if (CountBars>=Bars) CountBars=Bars;
SetIndexDrawBegin(0,Bars-CountBars+SSP);
SetIndexDrawBegin(1,Bars-CountBars+SSP);
int i,counted_bars=IndicatorCounted();
double SsMax,SsMin,val1,val2,smin,smax; 

if(Bars<=SSP+1)return(0);

if(counted_bars<SSP+1)
{
for(i=1;i<=SSP;i++)ExtMapBuffer1[CountBars-i]=0.0;
for(i=1;i<=SSP;i++)ExtMapBuffer2[CountBars-i]=0.0;
}
for(i=CountBars-SSP;i>=0;i--)
{
SsMax=High[Highest(NULL,0,MODE_OPEN,SSP,i-SSP+1)];
SsMin=Low[Lowest(NULL,0,MODE_OPEN,SSP,i-SSP+1)];
smin=SsMin-(SsMax-SsMin)*Kmin/100;
smax=SsMax-(SsMax-SsMin)*Kmax/100;
ExtMapBuffer1[i-SSP+10]=smax;
ExtMapBuffer2[i-SSP]=smax;
val1=ExtMapBuffer1[0];
val2=ExtMapBuffer2[0];
if(val1>val2)Comment("Buy",val1);
if(val1<val2)Comment("Sell",val2);
}
return(0);
}