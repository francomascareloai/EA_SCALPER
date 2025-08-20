//+------------------------------------------------------------------+
//|                                   hilbert transform adaptive EMA |
//+------------------------------------------------------------------+
#property copyright "www.forex-tsd.com"
#property link      "www.forex-tsd.com"

#property indicator_separate_window
#property indicator_buffers 8
#property indicator_color1  clrSandyBrown
#property indicator_color2  clrSandyBrown
#property indicator_color3  clrDeepSkyBlue
#property indicator_color4  clrDeepSkyBlue
#property indicator_color5  clrDimGray
#property indicator_color6  clrDeepSkyBlue
#property indicator_color7  clrDimGray
#property indicator_color8  clrSandyBrown
#property indicator_width1  1
#property indicator_width2  2
#property indicator_width3  1
#property indicator_width4  2
#property indicator_width5  2
#property indicator_style6  STYLE_DOT
#property indicator_style7  STYLE_DOT
#property indicator_style8  STYLE_DOT
#property indicator_level1  0

//
//
//
//
//

enum enPrices
{
   pr_close,      // Close
   pr_open,       // Open
   pr_high,       // High
   pr_low,        // Low
   pr_median,     // Median
   pr_typical,    // Typical
   pr_weighted,   // Weighted
   pr_average,    // Average (high+low+open+close)/4
   pr_medianb,    // Average median body (open+close)/2
   pr_tbiased,    // Trend biased price
   pr_haclose,    // Heiken ashi close
   pr_haopen ,    // Heiken ashi open
   pr_hahigh,     // Heiken ashi high
   pr_halow,      // Heiken ashi low
   pr_hamedian,   // Heiken ashi median
   pr_hatypical,  // Heiken ashi typical
   pr_haweighted, // Heiken ashi weighted
   pr_haaverage,  // Heiken ashi average
   pr_hamedianb,  // Heiken ashi median body
   pr_hatbiased   // Heiken ashi trend biased price
};

extern ENUM_TIMEFRAMES    TimeFrame    = PERIOD_CURRENT;
extern string             ForSymbol    = "";
extern enPrices           price        = pr_median;
extern double             filter       = 1;
extern double             cyclesFast   = 0.5;
extern double             cyclesSlow   = 1.0;
extern bool               inverted     = false;
extern int                MinMaxPeriod =  50;
extern double             LevelUp      =  90;
extern double             LevelDown    =  10;
extern bool               Interpolate  = true;

//
//
//
//
//

double macd[];
double macdhUpa[];
double macdhUpb[];
double macdhDna[];
double macdhDnb[];
double levelUp[];
double levelMi[];
double levelDn[];
double emaFast[];
double emaSlow[];
double trend[];
string indicatorFileName;
bool   returnBars;


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//
//
//
//
//

int init() 
{
   IndicatorBuffers(11);
      SetIndexBuffer(0, macdhDna); SetIndexStyle(0,DRAW_HISTOGRAM);
      SetIndexBuffer(1, macdhDnb); SetIndexStyle(1,DRAW_HISTOGRAM);
      SetIndexBuffer(2, macdhUpa); SetIndexStyle(2,DRAW_HISTOGRAM);
      SetIndexBuffer(3, macdhUpb); SetIndexStyle(3,DRAW_HISTOGRAM);
      SetIndexBuffer(4, macd);
      SetIndexBuffer(5, levelUp);
      SetIndexBuffer(6, levelMi);
      SetIndexBuffer(7, levelDn);  
      SetIndexBuffer(8, emaFast); 
      SetIndexBuffer(9, emaSlow); 
      SetIndexBuffer(10,trend); 
         indicatorFileName = WindowExpertName();
         returnBars        = TimeFrame==-99;
         TimeFrame         = MathMax(TimeFrame,_Period);
            if (ForSymbol=="") ForSymbol = Symbol();

   IndicatorShortName(timeFrameToString(TimeFrame)+" "+ForSymbol+" Phase accumilation MACD ("+DoubleToStr(cyclesFast,2)+","+DoubleToStr(cyclesSlow,2)+","+DoubleToStr(filter,2)+")");
   return (0);
}
int deinit(){return (0);}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//
//
//
//
//

int start()
{
   int i,limit,counted_bars=IndicatorCounted();

   if(counted_bars<0) return(-1);
   if(counted_bars>0) counted_bars--;
         limit = MathMin(Bars-counted_bars,Bars-1);
         if (returnBars) { macdhDna[0] = limit+1; return(0); }

   //
   //
   //
   //
   //
            
   if (ForSymbol == Symbol() && TimeFrame == Period())
   {
      for(i=limit; i>=0; i--)
      {
         double prc = getPrice(price,Open,Close,High,Low,i);
         if (i==Bars-1)
         {
            emaFast[i] = prc;
            emaSlow[i] = prc;
            continue;
         }

      //
      //
      //
      //
      //
      
      double alphaFast = 2.0/(1.0+iHilbertPhase(prc,filter,cyclesFast,i,0));
      double alphaSlow = 2.0/(1.0+iHilbertPhase(prc,filter,cyclesSlow,i,1));

         emaFast[i]  = emaFast[i+1]+alphaFast*(prc-emaFast[i+1]);
         emaSlow[i]  = emaSlow[i+1]+alphaSlow*(prc-emaSlow[i+1]);
         if (inverted)
               macd[i] = emaSlow[i]-emaFast[i];
         else  macd[i] = emaFast[i]-emaSlow[i];
         macdhDna[i] = EMPTY_VALUE;
         macdhDnb[i] = EMPTY_VALUE;
         macdhUpa[i] = EMPTY_VALUE;
         macdhUpb[i] = EMPTY_VALUE;
         
      //
      //
      //
      //
      //
               
            trend[i] = trend[i+1];
               if (macd[i]>macd[i+1]) trend[i] =  1;
               if (macd[i]<macd[i+1]) trend[i] = -1;
               if (macd[i]>0)
                  if (trend[i] == 1) 
                        macdhUpb[i] = macd[i];
                  else  macdhUpa[i] = macd[i];
               if (macd[i]<0)
                  if (trend[i] == -1) 
                        macdhDnb[i] = macd[i];
                  else  macdhDna[i] = macd[i];
                  
                  //
                  //
                  //
                  //
                  //
                  
                  double valMin = macd[ArrayMinimum(macd,MinMaxPeriod,i)];
                  double valMax = macd[ArrayMaximum(macd,MinMaxPeriod,i)];
                  double range  = valMax-valMin;
                     levelUp[i] = valMin+range*LevelUp/100.0;
                     levelMi[i] = valMin+range*0.5;
                     levelDn[i] = valMin+range*LevelDown/100.0;
      }
      return (0);
   }
   
   //
   //
   //
   //
   //
   
   limit = MathMax(limit,MathMin(Bars-1,iCustom(ForSymbol,TimeFrame,indicatorFileName,-99,0,0)*TimeFrame/Period()));
   for (i=limit; i>=0; i--)
   {
      int y = iBarShift(ForSymbol,TimeFrame,Time[i]);
         macdhDna[i] = iCustom(ForSymbol,TimeFrame,indicatorFileName,PERIOD_CURRENT,"",price,filter,cyclesFast,cyclesSlow,inverted,MinMaxPeriod,LevelUp,LevelDown,0,y);
         macdhDnb[i] = iCustom(ForSymbol,TimeFrame,indicatorFileName,PERIOD_CURRENT,"",price,filter,cyclesFast,cyclesSlow,inverted,MinMaxPeriod,LevelUp,LevelDown,1,y);
         macdhUpa[i] = iCustom(ForSymbol,TimeFrame,indicatorFileName,PERIOD_CURRENT,"",price,filter,cyclesFast,cyclesSlow,inverted,MinMaxPeriod,LevelUp,LevelDown,2,y);
         macdhUpb[i] = iCustom(ForSymbol,TimeFrame,indicatorFileName,PERIOD_CURRENT,"",price,filter,cyclesFast,cyclesSlow,inverted,MinMaxPeriod,LevelUp,LevelDown,3,y);
         macd[i]     = iCustom(ForSymbol,TimeFrame,indicatorFileName,PERIOD_CURRENT,"",price,filter,cyclesFast,cyclesSlow,inverted,MinMaxPeriod,LevelUp,LevelDown,4,y);
         levelUp[i]  = iCustom(ForSymbol,TimeFrame,indicatorFileName,PERIOD_CURRENT,"",price,filter,cyclesFast,cyclesSlow,inverted,MinMaxPeriod,LevelUp,LevelDown,5,y);
         levelMi[i]  = iCustom(ForSymbol,TimeFrame,indicatorFileName,PERIOD_CURRENT,"",price,filter,cyclesFast,cyclesSlow,inverted,MinMaxPeriod,LevelUp,LevelDown,6,y);
         levelDn[i]  = iCustom(ForSymbol,TimeFrame,indicatorFileName,PERIOD_CURRENT,"",price,filter,cyclesFast,cyclesSlow,inverted,MinMaxPeriod,LevelUp,LevelDown,7,y);

         //
         //
         //
         //
         //
      
         if (!Interpolate || y==iBarShift(NULL,TimeFrame,Time[i-1])) continue;

         //
         //
         //
         //
         //

         datetime time = iTime(NULL,TimeFrame,y);
            for(int n = 1; i+n < Bars && Time[i+n] >= time; n++) continue;	
            for(int k = 1; k < n; k++)
            {
               macd[i+k]    = macd[i]    + (macd[i+n]    - macd[i])   *k/n;
               levelUp[i+k] = levelUp[i] + (levelUp[i+n] - levelUp[i])*k/n;
               levelMi[i+k] = levelMi[i] + (levelMi[i+n] - levelMi[i])*k/n;
               levelDn[i+k] = levelDn[i] + (levelDn[i+n] - levelDn[i])*k/n;
               if (macdhDna[i+k]!=EMPTY_VALUE) macdhDna[i+k]=macd[i+k];
               if (macdhDnb[i+k]!=EMPTY_VALUE) macdhDnb[i+k]=macd[i+k];
               if (macdhUpa[i+k]!=EMPTY_VALUE) macdhUpa[i+k]=macd[i+k];
               if (macdhUpb[i+k]!=EMPTY_VALUE) macdhUpb[i+k]=macd[i+k];
            }               
   }
   return(0);
         
}


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//
//
//
//
//

double workHil[][18];
#define _price      0
#define _smooth     1
#define _detrender  2
#define _period     3
#define _instPeriod 4
#define _phase      5
#define _deltaPhase 6
#define _Q1         7
#define _I1         8

#define Pi 3.14159265358979323846264338327950288

//
//
//
//
//

double iHilbertPhase(double tprice, double tfilter, double cyclesToReach, int i, int s=0)
{
   if (ArrayRange(workHil,0)!=Bars) ArrayResize(workHil,Bars);
   int r = Bars-i-1; s = s*9;
      
   //
   //
   //
   //
   //
      
      workHil[r][s+_price]      = tprice;
      workHil[r][s+_smooth]     = (4.0*workHil[r][s+_price]+3.0*workHil[r-1][s+_price]+2.0*workHil[r-2][s+_price]+workHil[r-3][s+_price])/10.0;
      workHil[r][s+_detrender]  = calcComp(r,_smooth,s);
      workHil[r][s+_Q1]         = 0.15*calcComp(r,_detrender,s)  +0.85*workHil[r-1][s+_Q1];
      workHil[r][s+_I1]         = 0.15*workHil[r-3][s+_detrender]+0.85*workHil[r-1][s+_I1];
      workHil[r][s+_phase]      = workHil[r-1][s+_phase];
      workHil[r][s+_instPeriod] = workHil[r-1][s+_instPeriod];

      //
      //
      //
      //
      //
           
         if (MathAbs(workHil[r][s+_I1])>0)
                     workHil[r][s+_phase] = 180.0/Pi*MathArctan(MathAbs(workHil[r][s+_Q1]/workHil[r][s+_I1]));
           
         if (workHil[r][s+_I1]<0 && workHil[r][s+_Q1]>0) workHil[r][s+_phase] = 180-workHil[r][s+_phase];
         if (workHil[r][s+_I1]<0 && workHil[r][s+_Q1]<0) workHil[r][s+_phase] = 180+workHil[r][s+_phase];
         if (workHil[r][s+_I1]>0 && workHil[r][s+_Q1]<0) workHil[r][s+_phase] = 360-workHil[r][s+_phase];

      //
      //
      //
      //
      //
                        
      workHil[r][s+_deltaPhase] = workHil[r-1][s+_phase]-workHil[r][s+_phase];

         if (workHil[r-1][s+_phase]<90 && workHil[r][s+_phase]>270)
             workHil[r][s+_deltaPhase] = 360+workHil[r-1][s+_phase]-workHil[r][s+_phase];
             workHil[r][s+_deltaPhase] = MathMax(MathMin(workHil[r][s+_deltaPhase],60),7);
      
            //
            //
            //
            //
            //
                  
            double alpha    = 2.0/(1.0+MathMax(tfilter,1));
            double phaseSum = 0; for (int k=0; phaseSum<cyclesToReach*360 && (r-k)>0; k++) phaseSum += workHil[r-k][s+_deltaPhase];
         
               if (k>0) workHil[r][s+_instPeriod]= k;
                  workHil[r][s+_period] = workHil[r-1][s+_period]+alpha*(workHil[r][s+_instPeriod]-workHil[r-1][s+_period]);
   return (workHil[r][s+_period]);
}

//
//
//
//
//

double calcComp(int r, int from, int s)
{
   return((0.0962*workHil[r  ][s+from] + 
           0.5769*workHil[r-2][s+from] - 
           0.5769*workHil[r-4][s+from] - 
           0.0962*workHil[r-6][s+from]) * (0.075*workHil[r-1][s+_period] + 0.54));
}

//-------------------------------------------------------------------
//
//-------------------------------------------------------------------
//
//
//
//
//

string sTfTable[] = {"M1","M5","M15","M30","H1","H4","D1","W1","MN"};
int    iTfTable[] = {1,5,15,30,60,240,1440,10080,43200};

string timeFrameToString(int tf)
{
   for (int i=ArraySize(iTfTable)-1; i>=0; i--) 
         if (tf==iTfTable[i]) return(sTfTable[i]);
                              return("");
}

//------------------------------------------------------------------
//
//------------------------------------------------------------------
//
//
//
//
//
//

double workHa[][4];
double getPrice(int tprice, const double& open[], const double& close[], const double& high[], const double& low[], int i, int instanceNo=0)
{
  if (tprice>=pr_haclose)
   {
      if (ArrayRange(workHa,0)!= Bars) ArrayResize(workHa,Bars);
         int r = Bars-i-1;
         
         //
         //
         //
         //
         //
         
         double haOpen;
         if (r>0)
                haOpen  = (workHa[r-1][instanceNo+2] + workHa[r-1][instanceNo+3])/2.0;
         else   haOpen  = (open[i]+close[i])/2;
         double haClose = (open[i] + high[i] + low[i] + close[i]) / 4.0;
         double haHigh  = MathMax(high[i], MathMax(haOpen,haClose));
         double haLow   = MathMin(low[i] , MathMin(haOpen,haClose));

         if(haOpen  <haClose) { workHa[r][instanceNo+0] = haLow;  workHa[r][instanceNo+1] = haHigh; } 
         else                 { workHa[r][instanceNo+0] = haHigh; workHa[r][instanceNo+1] = haLow;  } 
                                workHa[r][instanceNo+2] = haOpen;
                                workHa[r][instanceNo+3] = haClose;
         //
         //
         //
         //
         //
         
         switch (tprice)
         {
            case pr_haclose:     return(haClose);
            case pr_haopen:      return(haOpen);
            case pr_hahigh:      return(haHigh);
            case pr_halow:       return(haLow);
            case pr_hamedian:    return((haHigh+haLow)/2.0);
            case pr_hamedianb:   return((haOpen+haClose)/2.0);
            case pr_hatypical:   return((haHigh+haLow+haClose)/3.0);
            case pr_haweighted:  return((haHigh+haLow+haClose+haClose)/4.0);
            case pr_haaverage:   return((haHigh+haLow+haClose+haOpen)/4.0);
            case pr_hatbiased:
               if (haClose>haOpen)
                     return((haHigh+haClose)/2.0);
               else  return((haLow+haClose)/2.0);        
         }
   }
   
   //
   //
   //
   //
   //
   
   switch (tprice)
   {
      case pr_close:     return(close[i]);
      case pr_open:      return(open[i]);
      case pr_high:      return(high[i]);
      case pr_low:       return(low[i]);
      case pr_median:    return((high[i]+low[i])/2.0);
      case pr_medianb:   return((open[i]+close[i])/2.0);
      case pr_typical:   return((high[i]+low[i]+close[i])/3.0);
      case pr_weighted:  return((high[i]+low[i]+close[i]+close[i])/4.0);
      case pr_average:   return((high[i]+low[i]+close[i]+open[i])/4.0);
      case pr_tbiased:   
               if (close[i]>open[i])
                     return((high[i]+close[i])/2.0);
               else  return((low[i]+close[i])/2.0);        
   }
   return(0);
}