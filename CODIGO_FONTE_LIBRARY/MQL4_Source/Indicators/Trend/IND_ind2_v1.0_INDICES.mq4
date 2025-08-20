
#property indicator_separate_window
#property indicator_buffers 2
#property indicator_color1 Yellow
#property indicator_color2 Red


extern int D1RSIPer=13;
extern int D2StochPer=8;
extern int D3tunnelPer=8;
extern double hot=0.4;
extern int sigsmooth=4;


double sig1n[];
double sig2n[];

int init()
  {
   SetIndexStyle(0,DRAW_LINE);
   SetIndexStyle(1,DRAW_LINE);
   SetIndexBuffer(0,sig1n);
   SetIndexBuffer(1,sig2n);
   SetIndexDrawBegin(0,D1RSIPer+D2StochPer+D3tunnelPer+hot+sigsmooth);
   SetIndexDrawBegin(1,D1RSIPer+D2StochPer+D3tunnelPer+hot+sigsmooth);
   
   return(0);
  }

int start()
  {
   int i,i2,counted_bars=IndicatorCounted();
   double rsi,maxrsi,minrsi,storsi,E3D,
   sig1,sig2,sk,ss,sk2;
   double cs;
   bool init=true;
   cs= D1RSIPer+D2StochPer+D3tunnelPer+hot+sigsmooth;
   if(Bars<=cs) return(0);


ss=sigsmooth;
if (ss<2) ss=2;
sk = 2 / (ss + 1);
sk2=2/(ss*0.8+1);
init=false;

   if(counted_bars<1)
   {
      for(i=1;i<=cs;i++) sig1n[Bars-i]=0.0;
      for(i=1;i<=cs;i++) sig2n[Bars-i]=0.0;
   }

   i=Bars-cs-1;
   
   
   
   if(counted_bars>=cs) i=Bars-counted_bars-1;
   while(i>=0)
     {
      
      rsi=iRSI(NULL,0,D1RSIPer,PRICE_CLOSE,i);
maxrsi=rsi;
minrsi=rsi;

for (i2=i+D2StochPer;i2>=i; i2--)
{
rsi=iRSI(NULL,0,D1RSIPer,PRICE_CLOSE,i2);
if (rsi>maxrsi) maxrsi=rsi;
if (rsi<minrsi) minrsi=rsi;
}

storsi=((rsi-minrsi)/(maxrsi-minrsi)*200-100);
E3D=hot*iCCI(NULL,0,D3tunnelPer,PRICE_TYPICAL,i)+(1-hot)*storsi;
sig1n[i]=sk*E3D+(1-sk)*sig1;
sig2n[i]=sk2*sig1+(1-sk2)*sig2;
sig1=sig1n[i];
sig2=sig2n[i];

      i--;
     }
   return(0);
  }
