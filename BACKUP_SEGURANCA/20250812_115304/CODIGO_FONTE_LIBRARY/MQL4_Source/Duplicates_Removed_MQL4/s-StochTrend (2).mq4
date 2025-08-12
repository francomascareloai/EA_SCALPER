//+------------------------------------------------------------------+
//|                                                 s-StochTrend.mq4 |
//|                      Copyright © 2011, MetaQuotes Software Corp. |
//|                                        http://www.metaquotes.net |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2011, MetaQuotes Software Corp."
#property link      "http://www.metaquotes.net"

#property indicator_separate_window
#property indicator_minimum 0
#property indicator_maximum 100
#property indicator_buffers 4
#property indicator_color1 MediumBlue
#property indicator_color2 Green
#property indicator_color3 Green
#property indicator_color4 Crimson
#property indicator_level1 80
#property indicator_level2 60
#property indicator_level3 40
#property indicator_level4 20
#property indicator_levelcolor Maroon
#property indicator_levelwidth 1
#property indicator_levelstyle STYLE_DOT

//---- input parameters
extern int KPeriod=21;
extern int DPeriod=34;
extern int Slowing=3;
extern double ZoneHighPer = 65;
extern double ZoneLowPer = 35;
bool modeone=true;
extern bool PlaySoundBuy = true;
extern bool PlaySoundSell = true;
int CheckBarForSound = 0;
extern string FileSoundBuy = "gong1";
extern string FileSoundSell = "gong1";
extern color levelcolor = Brown;

//---- buffers
double MainBuffer[];
double SignalBuffer[];

double LineUpBuffer[];
double LineDnBuffer[];

//----
int draw_begin1=0;
int draw_begin2=0;

datetime BarSoundTime = 0;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
   string short_name;
//---- 2 additional buffers are used for counting.
   IndicatorBuffers(4);
//---- indicator lines
   SetIndexStyle(0,DRAW_LINE,EMPTY,2);
   SetIndexBuffer(0, MainBuffer);
   SetIndexStyle(1,DRAW_LINE,EMPTY,2);
   SetIndexBuffer(1, SignalBuffer);
   SetIndexStyle(2,DRAW_HISTOGRAM,EMPTY,2);
   SetIndexBuffer(2, LineUpBuffer);
   SetIndexStyle(3,DRAW_HISTOGRAM,EMPTY,2);
   SetIndexBuffer(3, LineDnBuffer);
//---- name for DataWindow and indicator subwindow label
   short_name="s-StochTrend";
   IndicatorShortName(short_name);
   SetIndexLabel(0,short_name);
   SetIndexLabel(1,"Signal");
//----
   draw_begin1=KPeriod+Slowing;
   draw_begin2=draw_begin1+DPeriod;
   SetIndexDrawBegin(0,draw_begin1);
   SetIndexDrawBegin(1,draw_begin2);
//----
   SetIndexEmptyValue(2,indicator_minimum);
   SetIndexEmptyValue(3,indicator_minimum);
   SetLevelStyle(STYLE_DOT,1,levelcolor);

   return(0);
  }
//+------------------------------------------------------------------+
//| Stochastic oscillator                                            |
//+------------------------------------------------------------------+
datetime LastUpTime=0,LastDnTime=0;
int direction=0;

int start()
  {
   int    i,k;
   int    counted_bars=IndicatorCounted();
   double price;
//----
   if(Bars<=draw_begin2) return(0);
//---- initial zero
   if(counted_bars<1)
     {
      for(i=1;i<=draw_begin1;i++) MainBuffer[Bars-i]=0;
      for(i=1;i<=draw_begin2;i++) SignalBuffer[Bars-i]=0;
     }

//---- last counted bar will be recounted
   if(counted_bars>0) counted_bars--;
   int limit=Bars-counted_bars;
//---- signal line is simple movimg average
   for(i=0; i<limit; i++)
   {
      MainBuffer[i]=iStochastic(NULL,0,KPeriod,DPeriod,Slowing,MODE_SMA,0,MODE_MAIN,i);
      SignalBuffer[i]=iStochastic(NULL,0,KPeriod,DPeriod,Slowing,MODE_SMA,0,MODE_SIGNAL,i);
   }
//---- vertical line draw
   for(i=limit-1; i>=0; i--)
   {
      double SS0 = SignalBuffer[i];
      double SS1 = SignalBuffer[i+1];
      double SF0 = MainBuffer[i];
      double SF1 = MainBuffer[i+1];

      if ((SF0>SS0) && (SF1<SS1) // пересечение Сигнальной линии Майном
      && (SF1<ZoneLowPer) && (SS1<ZoneLowPer)) {
            LineUpBuffer[i] = indicator_maximum;
            int idx = iBarShift(NULL,0,LastUpTime);
            if(modeone && idx != i && direction == 1)LineUpBuffer[idx] = indicator_minimum;
            LastUpTime=Time[i];
            direction = 1;
      }
      else LineUpBuffer[i] = indicator_minimum;

      if ((SF0<SS0) && (SF1>SS1) && // пересечение Сигнальной линии Майном
         (SF1>ZoneHighPer) && (SS1>ZoneHighPer)) {
            LineDnBuffer[i] = indicator_maximum;
            idx = iBarShift(NULL,0,LastDnTime);
            if(modeone && idx != i && direction == -1)LineDnBuffer[idx] = indicator_minimum;
            LastDnTime=Time[i];
            direction = -1;
      }
      else LineDnBuffer[i] = indicator_minimum;
   }
//----
  if (PlaySoundBuy && (LineUpBuffer[CheckBarForSound]>0))
  {
     if (BarSoundTime!=Time[CheckBarForSound])
        PlaySound(FileSoundBuy);
     BarSoundTime = Time[CheckBarForSound];
  }

  if (PlaySoundSell && (LineDnBuffer[CheckBarForSound]>0))
  {
     if (BarSoundTime!=Time[CheckBarForSound])
        PlaySound(FileSoundSell);
     BarSoundTime = Time[CheckBarForSound];
  }

   return(0);
  }
//+------------------------------------------------------------------+