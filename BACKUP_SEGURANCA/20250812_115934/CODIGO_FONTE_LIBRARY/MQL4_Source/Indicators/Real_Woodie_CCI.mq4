//+------------------------------------------------------------------+
//|                                              Real Woodie CCI.mq4 |
//|                Based on the code of Jason Robinson (jnrtrading). |
//|                                                                  |
//| After read the Woodie introductory document I started a search   |
//| for the right coloured CCI.                                      |
//| I can? find anyone in accomplish with the explanation of Woodie |
//| So, I take the code from another CCI, and I added                |
//| the center LSMA line according to the official explanation.      |
//| Everything you see is an exact copy like it? explained in the   |
//| document new_woodie_do1. Specially the colors.                   |
//| If you have some doubts can obtain a copy                        |
//| from http://woodiescciclub.com/                                  |
//|                                                                  |
//| Linuxser 2007                                                    |
//| for any doubts or suggestions contact me on Forex-TSD forum      |
//+------------------------------------------------------------------+
#property copyright "Under The GNU General Public License"
#property link      "www.gnu.org"

#property indicator_separate_window
#property indicator_buffers 8
#property indicator_color1 Blue   
#property indicator_color2 Red   //SaddleBrown
#property indicator_color3 Gray
#property indicator_color4 Gold
#property indicator_color5 Black 
#property indicator_color6 Crimson  
#property indicator_color7 Lime  //Gold  <<<<<<<<<<<<<<<<<<<<<<<<<<
#property indicator_color8 Red  //Gold  <<<<<<<<<<<<<<<<<<<<<<<<<<
#property indicator_level1 300
#property indicator_level2 200
#property indicator_level3 100
#property indicator_level4 -100
#property indicator_level5 -200
#property indicator_level6 -300
#property indicator_levelcolor Black
#property indicator_levelstyle STYLE_DOT
#property indicator_levelwidth 1

//---- input parameters
extern int TrendCCI_Period = 14;//14
extern int EntryCCI_Period = 6;//6
extern int LSMAPeriod = 25;     // LSMA period
extern int Trend_period = 5;
extern int  CountBars=1000; 
extern int   CCISize=2;
extern int   TCCISize=1;
extern int   TrendSize=1;
extern int   NoTrendSize=1;
extern bool  ShowLSMA=true;
extern int   LineSize3=1;

double TrendCCI[];
double EntryCCI[];
double CCITrendUp[];
double CCITrendDown[];
double CCINoTrend[];
double CCITimeBar[];
double ZeroLine[];
double LSMABuffer1[];
double LSMABuffer2[];
int EMAPeriod  = 34;     // ??period
int FromZero   = 0;      // Distance from zero level
double LineHighEMA[];
double LineLowEMA[];

int trendUp, trendDown;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()  {
//---- indicators
   SetIndexStyle(4, DRAW_LINE, STYLE_SOLID,CCISize);
   SetIndexBuffer(4, TrendCCI);
   SetIndexLabel(4, "TrendCCI");
   SetIndexStyle(0, DRAW_HISTOGRAM, 0,TrendSize);
   SetIndexBuffer(0, CCITrendUp);
   SetIndexLabel (0, NULL);
   SetIndexStyle(1, DRAW_HISTOGRAM, 0,TrendSize);
   SetIndexBuffer(1, CCITrendDown);
   SetIndexLabel (1, NULL);
   SetIndexStyle(2, DRAW_HISTOGRAM, 0,NoTrendSize);
   SetIndexBuffer(2, CCINoTrend);
   SetIndexLabel (2, NULL);
   SetIndexStyle(3, DRAW_HISTOGRAM, 0,NoTrendSize);
   SetIndexBuffer(3, CCITimeBar);
   SetIndexLabel (3, NULL);
   SetIndexStyle(5, DRAW_LINE, STYLE_SOLID,TCCISize);// 1 <<<<<<<<<<<<<<<<<<<<<<<<<<<
   SetIndexBuffer(5, EntryCCI);
   SetIndexLabel(5, "EntryCCI");
   SetIndexStyle(6, DRAW_ARROW, STYLE_SOLID,LineSize3);
   SetIndexBuffer(6, LSMABuffer2);
   SetIndexLabel (6, NULL);
   SetIndexArrow(6,167);
   SetIndexStyle(7, DRAW_ARROW, STYLE_SOLID,LineSize3);
   SetIndexBuffer(7, LSMABuffer1); 
   SetIndexArrow(7,167);
   SetIndexLabel (7, NULL);
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custor indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
//---- 
   
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start() {

   int limit, i, trendCCI, entryCCI;
   int counted_bars = IndicatorCounted();
   static datetime prevtime = 0;
//---- check for possible errors
   if(counted_bars < 0) return(-1);
//---- last counted bar will be recounted
   if(counted_bars > 0) counted_bars--;

   limit=Bars;//-counted_bars;
   
     SetIndexDrawBegin(0,Bars-CountBars);
     SetIndexDrawBegin(1,Bars-CountBars);
     SetIndexDrawBegin(2,Bars-CountBars);
     SetIndexDrawBegin(3,Bars-CountBars);
     SetIndexDrawBegin(4,Bars-CountBars);
     SetIndexDrawBegin(5,Bars-CountBars);
     SetIndexDrawBegin(6,Bars-CountBars);
     SetIndexDrawBegin(7,Bars-CountBars);
   

      trendCCI = TrendCCI_Period;
      entryCCI = EntryCCI_Period;
   
      IndicatorShortName("[CCI: " + trendCCI + "] [TCCI: " + entryCCI + "] [per LSMA: " + LSMAPeriod + "] [Trend: " + Trend_period + "] Values CCI|TCCI:");   
   
   for(i = limit; i >= 0; i--) {
      CCINoTrend[i] = 0;
      CCITrendDown[i] = 0;
      CCITimeBar[i] = 0;
      CCITrendUp[i] = 0;
      ZeroLine[i] = 0;
      TrendCCI[i] = iCCI(NULL, 0, trendCCI, PRICE_TYPICAL, i);
      EntryCCI[i] = iCCI(NULL, 0, entryCCI, PRICE_TYPICAL, i);
      
      if(TrendCCI[i] > 0 && TrendCCI[i+1] < 0) {
         if (trendDown >  Trend_period) trendUp = 0;
      }
      if (TrendCCI[i] > 0) {
         if (trendUp <  Trend_period){
            CCINoTrend[i] = TrendCCI[i];
            trendUp++;
         }
         if (trendUp ==  Trend_period) {
            CCITimeBar[i] = TrendCCI[i];
            trendUp++;
         }
         if (trendUp >  Trend_period) {
            CCITrendUp[i] = TrendCCI[i];
         }
      }
      if(TrendCCI[i] < 0 && TrendCCI[i+1] > 0) {
         if (trendUp >  Trend_period) trendDown = 0;
      }
      if (TrendCCI[i] < 0) {
         
         if (trendDown <  Trend_period){
            CCINoTrend[i] = TrendCCI[i];
            trendDown++;
         }
         if (trendDown ==  Trend_period) {
            CCITimeBar[i] = TrendCCI[i];
            trendDown++;
         }
         if (trendDown >  Trend_period) {
            CCITrendDown[i] = TrendCCI[i];
         }
      }
   }

//---- Color Middle Line LSMA
  if(ShowLSMA==true)
  {
  double sum, lengthvar, tmp, wt;
  int shift;
  int Draw4HowLong, loopbegin;

  if (counted_bars<0) return;
  if (counted_bars>0) counted_bars--;
  counted_bars = Bars - counted_bars;
  for (shift=0; shift<counted_bars; shift++) {
    LineLowEMA[shift] = -FromZero;
    LineHighEMA[shift] = -FromZero;

    double EmaValue = iMA(NULL, 0, EMAPeriod, 0, MODE_EMA, PRICE_TYPICAL, shift);
    if (Close[shift]>EmaValue) LineHighEMA[shift] = EMPTY_VALUE;
    if (Close[shift]<EmaValue) LineLowEMA[shift] = EMPTY_VALUE;
  }

  Draw4HowLong = Bars-LSMAPeriod - 5;
  loopbegin = Draw4HowLong - LSMAPeriod - 1;

  for(shift=loopbegin; shift>=0; shift--) {
    sum = 0;
    for (i=LSMAPeriod; i>=1; i--) {
      lengthvar = LSMAPeriod + 1;
      lengthvar /= 3;
      tmp = 0;
      tmp = (i - lengthvar) * Close[LSMAPeriod-i+shift];
      sum+=tmp;
    }
    wt = sum * 6 / (LSMAPeriod * (LSMAPeriod + 1));

    LSMABuffer1[shift] = 0;
    LSMABuffer2[shift] = 0;

    if (wt>Close[shift]) LSMABuffer2[shift] = EMPTY_VALUE;
    if (wt<Close[shift]) LSMABuffer1[shift] = EMPTY_VALUE;
  }
  }
  
//---- 
   return(0);
  }
//+------------------------------------------------------------------+