
//+------------------------------------------------------------------+
//|                                                                  |
//|                     Traders Dynamic Index                        |
//|                                                                  |
//|  This hybrid indicator is developed to assist traders in their   |
//|  ability to decipher and monitor market conditions related to    |
//|  trend direction, market strength, and market volatility.        |
//|                                                                  | 
//|  Even though comprehensive, the T.D.I. is easy to read and use.  |
//|                                                                  |
//|  Green line = RSI Price line                                     |
//|  Red line = Trade Signal line                                    |
//|  Blue lines = Volatility Band                                    | 
//|  Yellow line = Market Base Line                                  |  
//|                                                                  |
//|  Trend Direction - Immediate and Overall                         |
//|   Immediate = Green over Red...price action is moving up.        |
//|               Red over Green...price action is moving down.      |
//|                                                                  |   
//|   Overall = Yellow line trends up and down generally between the |
//|             lines 32 & 68. Watch for Yellow line to bounces off  |
//|             these lines for market reversal. Trade long when     |
//|             price is above the Yellow line, and trade short when |
//|             price is below.                                      |        
//|                                                                  |
//|  Market Strength & Volatility - Immediate and Overall            |
//|   Immediate = Green Line - Strong = Steep slope up or down.      | 
//|                            Weak = Moderate to Flat slope.        |
//|                                                                  |               
//|   Overall = Blue Lines - When expanding, market is strong and    |
//|             trending. When constricting, market is weak and      |
//|             in a range. When the Blue lines are extremely tight  |                                                       
//|             in a narrow range, expect an economic announcement   | 
//|             or other market condition to spike the market.       |
//|                                                                  |               
//|                                                                  |
//|  Entry conditions                                                |
//|   Scalping  - Long = Green over Red, Short = Red over Green      |
//|   Active - Long = Green over Red & Yellow lines                  |
//|            Short = Red over Green & Yellow lines                 |    
//|   Moderate - Long = Green over Red, Yellow, & 50 lines           |
//|              Short= Red over Green, Green below Yellow & 50 line |
//|                                                                  |
//|  Exit conditions*                                                |   
//|   Long = Green crosses below Red                                 |
//|   Short = Green crosses above Red                                |
//|   * If Green crosses either Blue lines, consider exiting when    |
//|     when the Green line crosses back over the Blue line.         |
//|                                                                  |
//|                                                                  |
//|  IMPORTANT: The default settings are well tested and proven.     |
//|             But, you can change the settings to fit your         |
//|             trading style.                                       |
//|                                                                  |
//|                                                                  |
//|  Price & Line Type settings:                                     |                  
//|   RSI Price settings                                             |               
//|   0 = Close price     [DEFAULT]                                  |               
//|   1 = Open price.                                                |               
//|   2 = High price.                                                |               
//|   3 = Low price.                                                 |               
//|   4 = Median price, (high+low)/2.                                |               
//|   5 = Typical price, (high+low+close)/3.                         |               
//|   6 = Weighted close price, (high+low+close+close)/4.            |               
//|                                                                  |               
//|   RSI Price Line & Signal Line Type settings                     |               
//|   0 = Simple moving average       [DEFAULT]                      |               
//|   1 = Exponential moving average                                 |               
//|   2 = Smoothed moving average                                    |               
//|   3 = Linear weighted moving average                             |               
//|                                                                  |
//|   Good trading,                                                  |   
//|                                                                  |
//|   Dean                                                           |                              
//+------------------------------------------------------------------+

//unofficial modification, july 2020
// - request for uptrend/downtrend label on 
//    - green/red crossing
//    - green+red over/below 50
//    - green+red over/below yellow

#property copyright "www,forex-station.com"
#property link      "www,forex-station.com"

#property indicator_separate_window
#property indicator_buffers    5
#property indicator_color1     clrMediumBlue
#property indicator_color2     clrYellow
#property indicator_color3     clrMediumBlue
#property indicator_color4     clrGreen
#property indicator_color5     clrRed
#property indicator_width2     2
#property indicator_width4     2
#property indicator_width5     2
#property indicator_levelcolor clrDimGray
#property indicator_levelstyle STYLE_DOT
#property strict

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
   pr_tbiased2,   // Trend biased (extreme) price
   pr_haclose,    // Heiken ashi close
   pr_haopen ,    // Heiken ashi open
   pr_hahigh,     // Heiken ashi high
   pr_halow,      // Heiken ashi low
   pr_hamedian,   // Heiken ashi median
   pr_hatypical,  // Heiken ashi typical
   pr_haweighted, // Heiken ashi weighted
   pr_haaverage,  // Heiken ashi average
   pr_hamedianb,  // Heiken ashi median body
   pr_hatbiased,  // Heiken ashi trend biased price
   pr_hatbiased2, // Heiken ashi trend biased (extreme) price
   pr_habclose,   // Heiken ashi (better formula) close
   pr_habopen ,   // Heiken ashi (better formula) open
   pr_habhigh,    // Heiken ashi (better formula) high
   pr_hablow,     // Heiken ashi (better formula) low
   pr_habmedian,  // Heiken ashi (better formula) median
   pr_habtypical, // Heiken ashi (better formula) typical
   pr_habweighted,// Heiken ashi (better formula) weighted
   pr_habaverage, // Heiken ashi (better formula) average
   pr_habmedianb, // Heiken ashi (better formula) median body
   pr_habtbiased, // Heiken ashi (better formula) trend biased price
   pr_habtbiased2 // Heiken ashi (better formula) trend biased (extreme) price
};
enum enMaTypes
{
   ma_sma,     // Simple moving average
   ma_ema,     // Exponential moving average
   ma_smma,    // Smoothed MA
   ma_lwma,    // Linear weighted MA
   ma_slwma,   // Smoothed LWMA
   ma_dsema,   // Double Smoothed Exponential average
   ma_tema,    // Triple exponential moving average - TEMA
   ma_lsma     // Linear regression value (lsma)
};
enum stdMethods
{
   std_custSam, // Custom - with sample correction
   std_custNos  // Custom - without sample correction
};
enum enRsiTypes
{
   rsi_rsi,  // Regular RSI
   rsi_wil,  // Slow RSI
   rsi_rap,  // Rapid RSI
   rsi_har,  // Harris RSI
   rsi_rsx,  // RSX
   rsi_cut   // Cuttlers RSI
};

extern ENUM_TIMEFRAMES    TimeFrame                    = PERIOD_CURRENT; // Time frame to use
extern int                RsiPeriod                    = 14;             // Rsi period
extern enRsiTypes         RsiMethod                    = rsi_rsx;        // Rsi type
extern enPrices           RsiPrice                     = pr_close;       // Rsi price to use
extern double             RsiPLPeriod                  = 1;              // Rsi price line period
extern enMaTypes          RsiPLMaMode                  = ma_sma;         // Signal line moving average method 
extern double             RsiSLPeriod                  = 14;             // Rsi signal line period
extern enMaTypes          RsiSLMaMode                  = ma_sma;         // Signal line moving average method 
extern stdMethods         DeviationType                = std_custSam;    // Deviation calculation type
extern int                VolBandPeriod                = 34;             // Volatility band period
extern enMaTypes          VolBandMaMode                = ma_sma;         // Volatility band moving average method 
extern double             VolBandMultiplier            = 1.6185;         // Volatility band multiplier
extern bool               alertsOn                     = false;          // Turn alerts on/off?
extern bool               alertsOnCurrent              = false;          // Alerts on open bar on/off?
extern bool               alertsMessage                = true;           // Alerts message on/off?
extern bool               alertsSound                  = false;          // Alerts sound on/off?
extern bool               alertsNotify                 = false;          // Alerts notification on/off?
extern bool               alertsEmail                  = false;          // Alerts email on/off?
extern string             soundFile                    = "alert2.wav";   // Sound file
extern bool               arrowsVisible                = false;          // Arrows visible on/off?
extern bool               arrowsOnNewest               = false;          // Arrows drawn on newest bar of higher time frame bar?
extern string             arrowsIdentifier             = "tdi Arrows1";  // Unique ID for arrows
extern double             arrowsUpperGap               = 1.0;            // Upper arrow gap
extern double             arrowsLowerGap               = 1.0;            // Lower arrow gap
extern color              arrowsUpColor                = clrLimeGreen;   // Up arrow color
extern color              arrowsDnColor                = clrOrange;      // Down arrow color
extern int                arrowsUpCode                 = 241;            // Up arrow code
extern int                arrowsDnCode                 = 242;            // Down arrow code
extern int                arrowsSize                   = 0;              // Arrows size
extern double             LevelDown                    = 32;             // Lower level
extern double             LevelMiddle                  = 50;             // Middle level
extern double             LevelUp                      = 68;             // Upper level
extern bool               Interpolate                  = true;           // Interpolate in multi time frame mode?

extern bool               label_show                   = false;          // Label show
extern int                label_type                   = 0;              // __ 0=g x r, 1=(gr) x 50, 2=(gr) x y
extern int                label_x_offset               = 10;             // __ x (from top right)
extern int                label_y_offset               = 50;             // __ y (from top right)
extern int                label_fsize                  = 10;             // __ font size
extern string             label_up_text                = "UP";           // __ up text
extern color              label_up_clr                 = clrLimeGreen;   // __ color
extern string             label_dn_text                = "DOWN";         // __ down text
extern color              label_dn_clr                 = clrRed;         // __ color
extern string             label_neu_text               = "Neutral";      // __ neutral text
extern color              label_neu_clr                = clrGray;        // __ color


double rsi[],rsiPL[],rsiSL[],bandUp[],bandMi[],bandDn[],trend[],count[];
string indicatorFileName;
#define _mtfCall(_buff,_ind) iCustom(NULL,TimeFrame,indicatorFileName,PERIOD_CURRENT,RsiPeriod,RsiMethod,RsiPrice,RsiPLPeriod,RsiPLMaMode,RsiSLPeriod,RsiSLMaMode,DeviationType,VolBandPeriod,VolBandMaMode,VolBandMultiplier,alertsOn,alertsOnCurrent,alertsMessage,alertsSound,alertsNotify,alertsEmail,soundFile,arrowsVisible,arrowsOnNewest,arrowsIdentifier,arrowsUpperGap,arrowsLowerGap,arrowsUpColor,arrowsDnColor,arrowsUpCode,arrowsDnCode,arrowsSize,LevelDown,LevelMiddle,LevelUp,_buff,_ind)

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//
//
//
//
//

int OnInit() 
{
   IndicatorBuffers(8);
   SetIndexBuffer(0,bandUp,INDICATOR_DATA); SetIndexStyle(0,DRAW_LINE);
   SetIndexBuffer(1,bandMi,INDICATOR_DATA); SetIndexStyle(1,DRAW_LINE);
   SetIndexBuffer(2,bandDn,INDICATOR_DATA); SetIndexStyle(2,DRAW_LINE);
   SetIndexBuffer(3,rsiPL, INDICATOR_DATA); SetIndexStyle(3,DRAW_LINE);
   SetIndexBuffer(4,rsiSL, INDICATOR_DATA); SetIndexStyle(4,DRAW_LINE);
   SetIndexBuffer(5,rsi,   INDICATOR_DATA); SetIndexStyle(5,DRAW_LINE);
   SetIndexBuffer(6,trend, INDICATOR_CALCULATIONS); 
   SetIndexBuffer(7,count, INDICATOR_CALCULATIONS); 
   
   indicatorFileName = WindowExpertName();
   TimeFrame         = fmax(TimeFrame,_Period);
    
   SetLevelValue(0,LevelUp);
   SetLevelValue(1,LevelMiddle);
   SetLevelValue(2,LevelDown);
   IndicatorShortName(timeFrameToString(TimeFrame)+" TDI of "+getRsiName((int)RsiMethod)+"  ("+(string)RsiPeriod+","+(string)RsiPLPeriod+", "+(string)RsiSLPeriod+")");
   if(label_show){
      int sub=ChartWindowFind(NULL,timeFrameToString(TimeFrame)+" TDI of "+getRsiName((int)RsiMethod)+"  ("+(string)RsiPeriod+","+(string)RsiPLPeriod+", "+(string)RsiSLPeriod+")");
      ObjectCreate(NULL,indicatorFileName+"label",OBJ_LABEL,sub,0,0);
      ObjectSet(indicatorFileName+"label", OBJPROP_CORNER, 1);
      ObjectSetInteger(NULL, indicatorFileName+"label", OBJPROP_ANCHOR, ANCHOR_RIGHT_UPPER);
      ObjectSet(indicatorFileName+"label", OBJPROP_XDISTANCE, label_x_offset);
      ObjectSet(indicatorFileName+"label", OBJPROP_YDISTANCE, label_y_offset);
      ObjectSetString(NULL, indicatorFileName+"label", OBJPROP_TEXT, "x");
      ObjectSetString(NULL, indicatorFileName+"label", OBJPROP_FONT, "Arial");
      ObjectSet(indicatorFileName+"label", OBJPROP_FONTSIZE, label_fsize);
      ObjectSet(indicatorFileName+"label", OBJPROP_COLOR, label_neu_clr);
      }
   //else{ObjectDelete(NULL,indicatorFileName+"label");}
return(INIT_SUCCEEDED);
}
int deinit()
{
    string lookFor       = arrowsIdentifier+":";
    int    lookForLength = StringLen(lookFor);
    for (int i=ObjectsTotal()-1; i>=0; i--)
    {
       string objectName = ObjectName(i);
          if (StringSubstr(objectName,0,lookForLength) == lookFor) ObjectDelete(objectName);
    }
    ObjectDelete(NULL,indicatorFileName+"label");
return(0);
}
//
//
//
//
//

int start()
{
   int i,counted_bars=IndicatorCounted();
      if(counted_bars<0) return(-1);
      if(counted_bars>0) counted_bars--;
         int limit=fmin(Bars-counted_bars,Bars-1); count[0] = limit;
         if (TimeFrame!=_Period)
         {
            limit = (int)fmax(limit,fmin(Bars-1,_mtfCall(7,0)*TimeFrame/Period()));
            for (i=limit;i>=0;i--)
            {
               int y = iBarShift(NULL,TimeFrame,Time[i]);
               bandUp[i] = _mtfCall(0,y); 
               bandMi[i] = _mtfCall(1,y); 
               bandDn[i] = _mtfCall(2,y); 
               rsiPL[i]  = _mtfCall(3,y); 
               rsiSL[i]  = _mtfCall(4,y); 
               
               //
               //
               //
               //
               //
      
               if (!Interpolate || (i>0 && y==iBarShift(NULL,TimeFrame,Time[i-1]))) continue;
               #define _interpolate(buff) buff[i+k] = buff[i]+(buff[i+n]-buff[i])*k/n
               int n,k; datetime time = iTime(NULL,TimeFrame,y);
                  for(n = 1; (i+n)<Bars && Time[i+n] >= time; n++) continue;	
                  for(k = 1; k<n && (i+n)<Bars && (i+k)<Bars; k++)
                  {
                    _interpolate(bandUp);
                    _interpolate(bandMi);
                    _interpolate(bandDn);
                    _interpolate(rsiPL);
                    _interpolate(rsiSL);
                  }                           
            }
            label_update();
      return(0);
      }
      
      //
      //
      //
      //
      //
      
      for(i=limit; i>=0; i--)
      {
         double prices    = getPrice(RsiPrice,Open,Close,High,Low,i,Bars); 
                rsi[i]    = iRsi(RsiMethod,prices,RsiPeriod,i,Bars);  
                rsiPL[i]  = iCustomMa(RsiPLMaMode, rsi[i], RsiPLPeriod,  i,Bars,0);
                rsiSL[i]  = iCustomMa(RsiSLMaMode,rsi[i],  RsiSLPeriod,  i,Bars,1);
                bandMi[i] = iCustomMa(VolBandMaMode,rsi[i],VolBandPeriod,i,Bars,2);
         double deviation = iDeviation(rsi[i],VolBandPeriod,DeviationType==std_custSam,i,Bars);
                bandUp[i] = bandMi[i]+VolBandMultiplier*deviation;
                bandDn[i] = bandMi[i]-VolBandMultiplier*deviation;
                trend[i]  = (i<Bars-1) ? (rsiPL[i]>rsiSL[i]) ? 1 : (rsiPL[i]<rsiSL[i]) ? -1 : trend[i+1] : 0;
                
                //
                //
                //
                //
                //
                
                if (arrowsVisible)
                {
                  string lookFor = arrowsIdentifier+":"+(string)Time[i]; ObjectDelete(lookFor);            
                  if (i<(Bars-1) && trend[i] != trend[i+1])
                  {
                     if (trend[i] == 1) drawArrow(i,arrowsUpColor,arrowsUpCode,false);
                     if (trend[i] ==-1) drawArrow(i,arrowsDnColor,arrowsDnCode, true);
                  }
                }
                label_update();
       }
       
       //
       //
       //
       //
       //
      
       if (alertsOn)
       {
         int whichBar = 1; if (alertsOnCurrent) whichBar = 0;
         if (trend[whichBar] != trend[whichBar+1])
         {
            if (trend[whichBar] == 1) doAlert(whichBar," crossed up");
            if (trend[whichBar] ==-1) doAlert(whichBar," crossed down");
         }         
       }

return (0);
}      

//------------------------------------------------------------------
//                                                                  
//------------------------------------------------------------------
//
//
//
//
//

#define _maInstances 3
#define _maWorkBufferx1 1*_maInstances
#define _maWorkBufferx2 2*_maInstances
#define _maWorkBufferx3 3*_maInstances

double iCustomMa(int mode, double price, double length, int r, int bars, int instanceNo=0)
{
   r = bars-r-1;
   switch (mode)
   {
      case ma_sma   : return(iSma(price,(int)length,r,bars,instanceNo));
      case ma_ema   : return(iEma(price,length,r,bars,instanceNo));
      case ma_smma  : return(iSmma(price,(int)length,r,bars,instanceNo));
      case ma_lwma  : return(iLwma(price,(int)length,r,bars,instanceNo));
      case ma_slwma : return(iSlwma(price,(int)length,r,bars,instanceNo));
      case ma_dsema : return(iDsema(price,length,r,bars,instanceNo));
      case ma_tema  : return(iTema(price,(int)length,r,bars,instanceNo));
      case ma_lsma  : return(iLinr(price,(int)length,r,bars,instanceNo));
      default       : return(price);
   }
}

//
//
//
//
//

double workSma[][_maWorkBufferx1];
double iSma(double price, int period, int r, int _bars, int instanceNo=0)
{
   if (ArrayRange(workSma,0)!= _bars) ArrayResize(workSma,_bars);

   workSma[r][instanceNo+0] = price;
   double avg = price; int k=1;  for(; k<period && (r-k)>=0; k++) avg += workSma[r-k][instanceNo+0];  
   return(avg/(double)k);
}

//
//
//
//
//

double workEma[][_maWorkBufferx1];
double iEma(double price, double period, int r, int _bars, int instanceNo=0)
{
   if (ArrayRange(workEma,0)!= _bars) ArrayResize(workEma,_bars);

   workEma[r][instanceNo] = price;
   if (r>0 && period>1)
          workEma[r][instanceNo] = workEma[r-1][instanceNo]+(2.0/(1.0+period))*(price-workEma[r-1][instanceNo]);
   return(workEma[r][instanceNo]);
}

//
//
//
//
//

double workSmma[][_maWorkBufferx1];
double iSmma(double price, double period, int r, int _bars, int instanceNo=0)
{
   if (ArrayRange(workSmma,0)!= _bars) ArrayResize(workSmma,_bars);

   workSmma[r][instanceNo] = price;
   if (r>1 && period>1)
          workSmma[r][instanceNo] = workSmma[r-1][instanceNo]+(price-workSmma[r-1][instanceNo])/period;
   return(workSmma[r][instanceNo]);
}

//
//
//
//
//

double workLwma[][_maWorkBufferx1];
double iLwma(double price, double period, int r, int _bars, int instanceNo=0)
{
   if (ArrayRange(workLwma,0)!= _bars) ArrayResize(workLwma,_bars);
   
   workLwma[r][instanceNo] = price; if (period<=1) return(price);
      double sumw = period;
      double sum  = period*price;

      for(int k=1; k<period && (r-k)>=0; k++)
      {
         double weight = period-k;
                sumw  += weight;
                sum   += weight*workLwma[r-k][instanceNo];  
      }             
      return(sum/sumw);
}

//
//
//
//
//


double workSlwma[][_maWorkBufferx2];
double iSlwma(double price, double period, int r, int _bars, int instanceNo=0)
{
   if (ArrayRange(workSlwma,0)!= _bars) ArrayResize(workSlwma,_bars); 

   //
   //
   //
   //
   //

      int SqrtPeriod = (int)MathFloor(MathSqrt(period)); instanceNo *= 2;
         workSlwma[r][instanceNo] = price;

         //
         //
         //
         //
         //
               
         double sumw = period;
         double sum  = period*price;
   
         for(int k=1; k<period && (r-k)>=0; k++)
         {
            double weight = period-k;
                   sumw  += weight;
                   sum   += weight*workSlwma[r-k][instanceNo];  
         }             
         workSlwma[r][instanceNo+1] = (sum/sumw);

         //
         //
         //
         //
         //
         
         sumw = SqrtPeriod;
         sum  = SqrtPeriod*workSlwma[r][instanceNo+1];
            for(int k=1; k<SqrtPeriod && (r-k)>=0; k++)
            {
               double weight = SqrtPeriod-k;
                      sumw += weight;
                      sum  += weight*workSlwma[r-k][instanceNo+1];  
            }
   return(sum/sumw);
}

//
//
//
//
//

double workDsema[][_maWorkBufferx2];
#define _ema1 0
#define _ema2 1

double iDsema(double price, double period, int r, int _bars, int instanceNo=0)
{
   if (ArrayRange(workDsema,0)!= _bars) ArrayResize(workDsema,_bars); instanceNo*=2;

   //
   //
   //
   //
   //
   
   workDsema[r][_ema1+instanceNo] = price;
   workDsema[r][_ema2+instanceNo] = price;
   if (r>0 && period>1)
   {
      double alpha = 2.0 /(1.0+MathSqrt(period));
          workDsema[r][_ema1+instanceNo] = workDsema[r-1][_ema1+instanceNo]+alpha*(price                         -workDsema[r-1][_ema1+instanceNo]);
          workDsema[r][_ema2+instanceNo] = workDsema[r-1][_ema2+instanceNo]+alpha*(workDsema[r][_ema1+instanceNo]-workDsema[r-1][_ema2+instanceNo]); }
   return(workDsema[r][_ema2+instanceNo]);
}

//
//
//
//
//

double workTema[][_maWorkBufferx3];
#define _tema1 0
#define _tema2 1
#define _tema3 2

double iTema(double price, double period, int r, int bars, int instanceNo=0)
{
   if (ArrayRange(workTema,0)!= bars) ArrayResize(workTema,bars); instanceNo*=3;

   //
   //
   //
   //
   //
      
   workTema[r][_tema1+instanceNo] = price;
   workTema[r][_tema2+instanceNo] = price;
   workTema[r][_tema3+instanceNo] = price;
   if (r>0 && period>1)
   {
      double alpha = 2.0 / (1.0+period);
          workTema[r][_tema1+instanceNo] = workTema[r-1][_tema1+instanceNo]+alpha*(price                         -workTema[r-1][_tema1+instanceNo]);
          workTema[r][_tema2+instanceNo] = workTema[r-1][_tema2+instanceNo]+alpha*(workTema[r][_tema1+instanceNo]-workTema[r-1][_tema2+instanceNo]);
          workTema[r][_tema3+instanceNo] = workTema[r-1][_tema3+instanceNo]+alpha*(workTema[r][_tema2+instanceNo]-workTema[r-1][_tema3+instanceNo]); }
   return(workTema[r][_tema3+instanceNo]+3.0*(workTema[r][_tema1+instanceNo]-workTema[r][_tema2+instanceNo]));
}

//
//
//
//
//

double workLinr[][_maWorkBufferx1];
double iLinr(double price, int period, int r, int bars, int instanceNo=0)
{
   if (ArrayRange(workLinr,0)!= bars) ArrayResize(workLinr,bars);

   //
   //
   //
   //
   //
   
      period = MathMax(period,1);
      workLinr[r][instanceNo] = price;
      if (r<period) return(price);
         double lwmw = period; double lwma = lwmw*price;
         double sma  = price;
         for(int k=1; k<period && (r-k)>=0; k++)
         {
            double weight = period-k;
                   lwmw  += weight;
                   lwma  += weight*workLinr[r-k][instanceNo];  
                   sma   +=        workLinr[r-k][instanceNo];
         }             
   
   return(3.0*lwma/lwmw-2.0*sma/period);
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

string rsiMethodNames[] = {"RSI","Slow RSI","Rapid RSI","Harris RSI","RSX","Cuttler RSI"};
string getRsiName(int method)
{
   int max = ArraySize(rsiMethodNames)-1;
      method=fmax(fmin(method,max),0); return(rsiMethodNames[method]);
}

//
//
//
//
//

#define rsiInstances 1
double workRsi[][rsiInstances*13];
#define _price  0
#define _change 1
#define _changa 2
#define _rsival 1
#define _rsval  1

double iRsi(int rsiMode, double price, double period, int i, int bars, int instanceNo=0)
{
   if (ArrayRange(workRsi,0)!=bars) ArrayResize(workRsi,bars);
      int z = instanceNo*13; 
      int r = bars-i-1;
   
   //
   //
   //
   //
   //
   
   workRsi[r][z+_price] = price;
   switch (rsiMode)
   {
      case rsi_rsi:
         {
         double alpha = 1.0/fmax(period,1); 
         if (r<period)
            {
               int k; double sum = 0; for (k=0; k<period && (r-k-1)>=0; k++) sum += fabs(workRsi[r-k][z+_price]-workRsi[r-k-1][z+_price]);
                  workRsi[r][z+_change] = (workRsi[r][z+_price]-workRsi[0][z+_price])/fmax(k,1);
                  workRsi[r][z+_changa] =                                         sum/fmax(k,1);
            }
         else
            {
               double change = workRsi[r][z+_price]-workRsi[r-1][z+_price];
                               workRsi[r][z+_change] = workRsi[r-1][z+_change] + alpha*(     change  - workRsi[r-1][z+_change]);
                               workRsi[r][z+_changa] = workRsi[r-1][z+_changa] + alpha*(fabs(change) - workRsi[r-1][z+_changa]);
            }
         if (workRsi[r][z+_changa] != 0)
               return(50.0*(workRsi[r][z+_change]/workRsi[r][z+_changa]+1));
         else  return(50.0);
         }
         
      //
      //
      //
      //
      //
      
      case rsi_wil :
         {         
            double up = 0;
            double dn = 0;
            for(int k=0; k<(int)period && (r-k-1)>=0; k++)
            {
               double diff = workRsi[r-k][z+_price]- workRsi[r-k-1][z+_price];
               if(diff>0)
                     up += diff;
               else  dn -= diff;
            }
            if (r<1)
                  workRsi[r][z+_rsival] = 50;
            else               
               if(up + dn == 0)
                     workRsi[r][z+_rsival] = workRsi[r-1][z+_rsival]+(1/fmax(period,1))*(50            -workRsi[r-1][z+_rsival]);
               else  workRsi[r][z+_rsival] = workRsi[r-1][z+_rsival]+(1/fmax(period,1))*(100*up/(up+dn)-workRsi[r-1][z+_rsival]);
            return(workRsi[r][z+_rsival]);      
         }
      
      //
      //
      //
      //
      //

      case rsi_rap :
         {
            double up = 0;
            double dn = 0;
            for(int k=0; k<(int)period && (r-k-1)>=0; k++)
            {
               double diff = workRsi[r-k][z+_price]- workRsi[r-k-1][z+_price];
               if(diff>0)
                     up += diff;
               else  dn -= diff;
            }
            if(up + dn == 0)
                  return(50);
            else  return(100 * up / (up + dn));      
         }            

      //
      //
      //
      //
      //

      
      case rsi_har :
         {
            double avgUp=0,avgDn=0; double up=0; double dn=0;
            for(int k=0; k<(int)period && (r-k-1)>=0; k++)
            {
               double diff = workRsi[r-k][instanceNo+_price]- workRsi[r-k-1][instanceNo+_price];
               if(diff>0)
                     { avgUp += diff; up++; }
               else  { avgDn -= diff; dn++; }
            }
            if (up!=0) avgUp /= up;
            if (dn!=0) avgDn /= dn;
            double rs = 1;
               if (avgDn!=0) rs = avgUp/avgDn;
               return(100-100/(1.0+rs));
         }               

      //
      //
      //
      //
      //
      
      case rsi_rsx :  
         {   
            double Kg = (3.0)/(2.0+period), Hg = 1.0-Kg;
            if (r<period) { for (int k=1; k<13; k++) workRsi[r][k+z] = 0; return(50); }  

            //
            //
            //
            //
            //
      
            double mom = workRsi[r][_price+z]-workRsi[r-1][_price+z];
            double moa = fabs(mom);
            for (int k=0; k<3; k++)
            {
               int kk = k*2;
               workRsi[r][z+kk+1] = Kg*mom                + Hg*workRsi[r-1][z+kk+1];
               workRsi[r][z+kk+2] = Kg*workRsi[r][z+kk+1] + Hg*workRsi[r-1][z+kk+2]; mom = 1.5*workRsi[r][z+kk+1] - 0.5 * workRsi[r][z+kk+2];
               workRsi[r][z+kk+7] = Kg*moa                + Hg*workRsi[r-1][z+kk+7];
               workRsi[r][z+kk+8] = Kg*workRsi[r][z+kk+7] + Hg*workRsi[r-1][z+kk+8]; moa = 1.5*workRsi[r][z+kk+7] - 0.5 * workRsi[r][z+kk+8];
            }
            if (moa != 0)
                 return(fmax(fmin((mom/moa+1.0)*50.0,100.00),0.00)); 
            else return(50);
         }            
            
      //
      //
      //
      //
      //
      
      case rsi_cut :
         {
            double sump = 0;
            double sumn = 0;
            for (int k=0; k<(int)period && r-k-1>=0; k++)
            {
               double diff = workRsi[r-k][z+_price]-workRsi[r-k-1][z+_price];
                  if (diff > 0) sump += diff;
                  if (diff < 0) sumn -= diff;
            }
            if (sumn > 0)
                  return(100.0-100.0/(1.0+sump/sumn));
            else  return(50);
         }            
   } 
   return(0);
}

//------------------------------------------------------------------
//                                                                  
//------------------------------------------------------------------
// 
//
//
//
//

double workDev[];
double iDeviation(double value, int length, bool isSample, int i, int bars)
{
   if (ArraySize(workDev)!= bars) ArrayResize(workDev,bars); i=bars-i-1; workDev[i] = value;
                 
   //
   //
   //
   //
   //
   
      double oldMean   = value;
      double newMean   = value;
      double squares   = 0; int k;
      for (k=1; k<length && (i-k)>=0; k++)
      {
         newMean  = (workDev[i-k]-oldMean)/(k+1)+oldMean;
         squares += (workDev[i-k]-oldMean)*(workDev[i-k]-newMean);
         oldMean  = newMean;
      }
      return(MathSqrt(squares/MathMax(k-isSample,1)));
}

//------------------------------------------------------------------
//
//------------------------------------------------------------------
//
//
//
//
//

#define _prHABF(_prtype) (_prtype>=pr_habclose && _prtype<=pr_habtbiased2)
#define _priceInstances     1
#define _priceInstancesSize 4
double workHa[][_priceInstances*_priceInstancesSize];
double getPrice(int tprice, const double& open[], const double& close[], const double& high[], const double& low[], int i, int bars, int instanceNo=0)
{
  if (tprice>=pr_haclose)
   {
      if (ArrayRange(workHa,0)!= Bars) ArrayResize(workHa,Bars); instanceNo*=_priceInstancesSize; int r = bars-i-1;
         
         //
         //
         //
         //
         //
         
         double haOpen  = (r>0) ? (workHa[r-1][instanceNo+2] + workHa[r-1][instanceNo+3])/2.0 : (open[i]+close[i])/2;;
         double haClose = (open[i]+high[i]+low[i]+close[i]) / 4.0;
         if (_prHABF(tprice))
               if (high[i]!=low[i])
                     haClose = (open[i]+close[i])/2.0+(((close[i]-open[i])/(high[i]-low[i]))*MathAbs((close[i]-open[i])/2.0));
               else  haClose = (open[i]+close[i])/2.0; 
         double haHigh  = fmax(high[i], fmax(haOpen,haClose));
         double haLow   = fmin(low[i] , fmin(haOpen,haClose));

         //
         //
         //
         //
         //
         
         if(haOpen<haClose) { workHa[r][instanceNo+0] = haLow;  workHa[r][instanceNo+1] = haHigh; } 
         else               { workHa[r][instanceNo+0] = haHigh; workHa[r][instanceNo+1] = haLow;  } 
                              workHa[r][instanceNo+2] = haOpen;
                              workHa[r][instanceNo+3] = haClose;
         //
         //
         //
         //
         //
         
         switch (tprice)
         {
            case pr_haclose:
            case pr_habclose:    return(haClose);
            case pr_haopen:   
            case pr_habopen:     return(haOpen);
            case pr_hahigh: 
            case pr_habhigh:     return(haHigh);
            case pr_halow:    
            case pr_hablow:      return(haLow);
            case pr_hamedian:
            case pr_habmedian:   return((haHigh+haLow)/2.0);
            case pr_hamedianb:
            case pr_habmedianb:  return((haOpen+haClose)/2.0);
            case pr_hatypical:
            case pr_habtypical:  return((haHigh+haLow+haClose)/3.0);
            case pr_haweighted:
            case pr_habweighted: return((haHigh+haLow+haClose+haClose)/4.0);
            case pr_haaverage:  
            case pr_habaverage:  return((haHigh+haLow+haClose+haOpen)/4.0);
            case pr_hatbiased:
            case pr_habtbiased:
               if (haClose>haOpen)
                     return((haHigh+haClose)/2.0);
               else  return((haLow+haClose)/2.0);        
            case pr_hatbiased2:
            case pr_habtbiased2:
               if (haClose>haOpen)  return(haHigh);
               if (haClose<haOpen)  return(haLow);
                                    return(haClose);        
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
      case pr_tbiased2:   
               if (close[i]>open[i]) return(high[i]);
               if (close[i]<open[i]) return(low[i]);
                                     return(close[i]);        
   }
   return(0);
}

//+-------------------------------------------------------------------
//|                                                                  
//+-------------------------------------------------------------------
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

//
//
//
//
//

void doAlert(int forBar, string doWhat)
{
   static string   previousAlert="nothing";
   static datetime previousTime;
   string message;
   
   if (previousAlert != doWhat || previousTime != Time[forBar]) {
       previousAlert  = doWhat;
       previousTime   = Time[forBar];

       //
       //
       //
       //
       //

       message = timeFrameToString(_Period)+" "+Symbol()+" at "+TimeToStr(TimeLocal(),TIME_SECONDS)+" TDI "+doWhat;
          if (alertsMessage) Alert(message);
          if (alertsNotify)  SendNotification(message);
          if (alertsEmail)   SendMail(Symbol()+" TDI ",message);
          if (alertsSound)   PlaySound(soundFile);
   }
}

//-------------------------------------------------------------------
//                                                                  
//-------------------------------------------------------------------
//
//
//
//
//

void drawArrow(int i,color theColor,int theCode,bool tup)
{
   string name = arrowsIdentifier+":"+(string)Time[i];
   double gap  = iATR(NULL,0,20,i);   
   
      //
      //
      //
      //
      //

      datetime time = Time[i]; if (arrowsOnNewest) time += _Period*60-1;      
      ObjectCreate(name,OBJ_ARROW,0,time,0);
         ObjectSet(name,OBJPROP_ARROWCODE,theCode);
         ObjectSet(name,OBJPROP_WIDTH,arrowsSize);
         ObjectSet(name,OBJPROP_COLOR,theColor);
         if (tup)
               ObjectSet(name,OBJPROP_PRICE1,High[i] + arrowsUpperGap * gap);
         else  ObjectSet(name,OBJPROP_PRICE1,Low[i]  - arrowsLowerGap * gap);
}

//
//
//
//
//

void label_update()
{
       if(label_show){
         string which = "";
         if(label_type==0){//g-r crossover
            if(rsiPL[0]>=rsiSL[0]){which="up";}
            else {which="dn";}
         }
         if(label_type==1){//gr above/below 50
            if(rsiPL[0]>=50 && rsiSL[0]>=50){which="up";}
            else if(rsiPL[0]<50 && rsiSL[0]<50){which="dn";}
            else {which="neu";}
         }
         if(label_type==2){//gr crossover y
            if(rsiPL[0]>=bandMi[0] && rsiSL[0]>=bandMi[0]){which="up";}
            else if(rsiPL[0]<bandMi[0] && rsiSL[0]<bandMi[0]){which="dn";}
            else {which="neu";}
         }
         
         if(which=="up"){
            ObjectSetString(NULL, indicatorFileName+"label",OBJPROP_TEXT,label_up_text);
            ObjectSet(indicatorFileName+"label",OBJPROP_COLOR,label_up_clr);         }
         else if(which=="dn"){
            ObjectSetString(NULL, indicatorFileName+"label",OBJPROP_TEXT,label_dn_text);
            ObjectSet(indicatorFileName+"label",OBJPROP_COLOR,label_dn_clr);         }
         else if(which=="neu"){
            ObjectSetString(NULL, indicatorFileName+"label",OBJPROP_TEXT,label_neu_text);
            ObjectSet(indicatorFileName+"label",OBJPROP_COLOR,label_neu_clr);         }
      }
}