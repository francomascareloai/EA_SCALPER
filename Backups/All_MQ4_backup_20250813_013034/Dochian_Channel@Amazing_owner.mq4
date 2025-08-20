//+------------------------------------------------------------------+
//|                                              Dochian_Channel.mq4 |
//|                               Copyright © 2012, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2012, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_chart_window

#property indicator_buffers 5
#property indicator_color1 Red
#property indicator_color2 Green
#property indicator_color3 Yellow
#property indicator_color4 Cyan
#property indicator_color5 Magenta

extern int Length=20;
extern int Mode=1;    // 0 - Close
                      // 1 - High/Low

double Upper[], U75[], Middle[], L25[], Lower[];

int init()
  {
   IndicatorShortName("Dochian channel");
   SetIndexStyle(0,DRAW_LINE);
   SetIndexBuffer(0,Upper);
   SetIndexStyle(1,DRAW_LINE);
   SetIndexBuffer(1,U75);
   SetIndexStyle(2,DRAW_LINE);
   SetIndexBuffer(2,Middle);
   SetIndexStyle(3,DRAW_LINE);
   SetIndexBuffer(3,L25);
   SetIndexStyle(4,DRAW_LINE);
   SetIndexBuffer(4,Lower);

   return(0);
  }

int deinit()
  {

   return(0);
  }

int start()
{
 if(Bars<=Length) return(0);
 int ExtCountedBars=IndicatorCounted();
 if (ExtCountedBars<0) return(-1);
 int    limit=Bars-2;
 if(ExtCountedBars>2) limit=Bars-ExtCountedBars;
 int pos=limit;
 while(pos>=0)
 {
  if (Mode==0)
  {
   Upper[pos]=Close[iHighest(NULL, 0, MODE_CLOSE, Length, pos)];
   Lower[pos]=Close[iLowest(NULL, 0, MODE_CLOSE, Length, pos)];
  }
  else
  {
   Upper[pos]=High[iHighest(NULL, 0, MODE_HIGH, Length, pos)];
   Lower[pos]=Low[iLowest(NULL, 0, MODE_LOW, Length, pos)];
  }
  Middle[pos]=(Upper[pos]+Lower[pos])/2;
  U75[pos]=(Upper[pos]+Middle[pos])/2;
  L25[pos]=(Middle[pos]+Lower[pos])/2;
  pos--;
 } 

 return(0);
}

