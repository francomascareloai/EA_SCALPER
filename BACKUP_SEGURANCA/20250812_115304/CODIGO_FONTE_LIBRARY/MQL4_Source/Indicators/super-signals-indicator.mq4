//+------------------------------------------------------------------+
//|                                                super-signals.mq4 |
//|                Copyright © 2006, Nick Bilak, beluck[AT]gmail.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2006, Nick Bilak"
#property link      "http://www.forex-tsd.com/"

#property indicator_chart_window
#property indicator_buffers 2
#property indicator_color1 Red
#property indicator_width1 2
#property indicator_color2 Lime
#property indicator_width2 2

extern int SignalGap = 4;

int dist=24;
double b1[];
double b2[];

int init()  {
   SetIndexStyle(0,DRAW_ARROW,STYLE_SOLID,1);
   SetIndexStyle(1,DRAW_ARROW,STYLE_SOLID,1);
   SetIndexArrow(1,233);
   SetIndexArrow(0,234);
   SetIndexBuffer(0,b1);
   SetIndexBuffer(1,b2);
   return(0);
}
int start() {
   int counted_bars=IndicatorCounted();
   int k,i,j,limit,hhb,llb;
   
   if (counted_bars<0) return(-1);
   if (counted_bars>0) counted_bars--;
   limit=Bars-1;
   if(counted_bars>=1) limit=Bars-counted_bars-1;
   if (limit<0) limit=0;

   for (i=limit;i>=0;i--)   {
      b1[i]=EMPTY_VALUE;
      b2[i]=EMPTY_VALUE;
      hhb = iHighest(NULL,0,MODE_HIGH,dist,i-dist/2);
      llb = iLowest(NULL,0,MODE_LOW,dist,i-dist/2);

      if (i==hhb)
         b1[i]=High[hhb]+SignalGap*Point;
      if (i==llb)
         b2[i]=Low[llb]-SignalGap*Point;
   }
   return(0);
}


