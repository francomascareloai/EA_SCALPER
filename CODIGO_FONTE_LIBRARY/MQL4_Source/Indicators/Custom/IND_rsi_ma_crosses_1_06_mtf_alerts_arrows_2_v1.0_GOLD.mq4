//------------------------------------------------------------------
#property copyright "www.forex-station.com"
#property link      "www.forex-station.com"
//------------------------------------------------------------------
#property indicator_separate_window
#property indicator_buffers 6
#property indicator_style1  DRAW_LINE
#property indicator_color1  clrLimeGreen
#property indicator_width1  2
#property indicator_style2  DRAW_LINE
#property indicator_color2  clrSandyBrown
#property indicator_width2  2
#property indicator_style3  DRAW_LINE
#property indicator_color3  clrSandyBrown
#property indicator_width3  2
#property indicator_style4  STYLE_DOT
#property indicator_color4  clrPaleVioletRed
#property indicator_color5  clrLimeGreen
#property indicator_width5  2
#property indicator_color6  clrRed
#property indicator_width6  2
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

extern ENUM_TIMEFRAMES    TimeFrame              = PERIOD_CURRENT;   // Time frame
extern int                RsiPeriod              = 14;               // Rsi period
extern enPrices           RsiPrice               = pr_close;         // Rsi price
extern int                RsiPriceSmooth         = 0;                // Rsi price smoothing (<=1 for no smoothing)
extern enMaTypes          RsiPriceSmoothMet      = ma_sma;           // Rsi price smoothing method
extern int                SmoothingPeriod        = 3;                // Rsi smoothing (<=1 for no smoothing)
extern enMaTypes          SmoothingMethod        = ma_sma;           // Rsi smoothing period
extern int                MaPeriod               = 9;                // Signal period (<=1 for no signal)
extern enMaTypes          MaMethod               = ma_sma;           // Signal method 
extern bool               alertsOn               = false;            // Turn alerts on?
extern bool               alertsOnCurrent        = false;            // Alerts on still opened bar?
extern bool               alertsMessage          = true;             // Alerts should display message?
extern bool               alertsSound            = false;            // Alerts should play a sound?
extern bool               alertsNotify           = false;            // Alerts should send a notification?
extern bool               alertsEmail            = false;            // Alerts should send an email?
extern string             soundFile              = "alert2.wav";     // Sound file
extern bool               arrowsVisible          = false;            // Arrows visible?
extern bool               arrowsOnNewest         = false;            // Arrows drawn on newest bar of higher time frame bar?
extern string             arrowsIdentifier       = "rsimacross arrows1";  // Unique ID for arrows
extern double             arrowsUpperGap         = 1.0;              // Upper arrow gap
extern double             arrowsLowerGap         = 1.0;              // Lower arrow gap
extern color              arrowsUpColor          = clrLimeGreen;     // Up arrow color
extern color              arrowsDnColor          = clrOrange;        // Down arrow color
extern int                arrowsUpCode           = 241;              // Up arrow code
extern int                arrowsDnCode           = 242;              // Down arrow code
extern int                arrowsSize             = 0;                // Arrows size
extern bool               Interpolate            = true;             // Interpolate in mtf mode

double rsi[],rsida[],rsidb[],sig[],upDot[],dnDot[],trend[],prices[],count[];
string indicatorFileName;
#define _mtfCall(_buff,_ind) iCustom(NULL,TimeFrame,indicatorFileName,PERIOD_CURRENT,RsiPeriod,RsiPrice,RsiPriceSmooth,RsiPriceSmoothMet,SmoothingPeriod,SmoothingMethod,MaPeriod,MaMethod,alertsOn,alertsOnCurrent,alertsMessage,alertsSound,alertsNotify,alertsEmail,soundFile,arrowsVisible,arrowsOnNewest,arrowsIdentifier,arrowsUpperGap,arrowsLowerGap,arrowsUpColor,arrowsDnColor,arrowsUpCode,arrowsDnCode,arrowsSize,_buff,_ind)

//------------------------------------------------------------------
//
//------------------------------------------------------------------
//
//
//
//
//

int init()
{
   IndicatorBuffers(9);
      SetIndexBuffer(0,rsi);
      SetIndexBuffer(1,rsida);
      SetIndexBuffer(2,rsidb);
      SetIndexBuffer(3,sig);
      SetIndexBuffer(4,upDot); SetIndexStyle(4,DRAW_ARROW); SetIndexArrow(4,108); SetIndexLabel(4,"rsima>signal");
      SetIndexBuffer(5,dnDot); SetIndexStyle(5,DRAW_ARROW); SetIndexArrow(5,108); SetIndexLabel(5,"rsima<signal");
      SetIndexBuffer(6,trend);
      SetIndexBuffer(7,prices);
      SetIndexBuffer(8,count);
      
      indicatorFileName = WindowExpertName();
      TimeFrame         = fmax(TimeFrame,_Period);
      IndicatorShortName(timeFrameToString(TimeFrame)+" RSI + ma crosses ("+(string)RsiPeriod+","+(string)RsiPriceSmooth+","+(string)SmoothingPeriod+","+(string)MaPeriod+")");
return(0);  
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

int start()
{
   int i,counted_bars=IndicatorCounted();
      if(counted_bars<0) return(-1);
      if(counted_bars>0) counted_bars--;
         int limit=fmin(Bars-counted_bars,Bars-1); count[0] = limit;
         if (TimeFrame!=_Period)
         {
            limit = (int)fmax(limit,fmin(Bars-1,_mtfCall(8,0)*TimeFrame/Period()));
            if (trend[limit]==-1) CleanPoint(limit,rsida,rsidb);
            for (i=limit;i>=0;i--)
            {
               int y = iBarShift(NULL,TimeFrame,Time[i]);
               rsi[i]   = _mtfCall(0,y); 
               sig[i]   = _mtfCall(3,y); 
               trend[i] = _mtfCall(6,y); 
               rsida[i] = EMPTY_VALUE;
               rsidb[i] = EMPTY_VALUE;
               upDot[i] = EMPTY_VALUE;
               dnDot[i] = EMPTY_VALUE;
               if (trend[i]==-1) PlotPoint(i,rsida,rsidb,rsi);
               
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
                     _interpolate(rsi);
                     _interpolate(sig);
                   }                           
            }
            for (i=limit; i >= 0; i--) 
            {
               if (trend[i]==-1) PlotPoint(i,rsida,rsidb,rsi);
               if (i<Bars-1 && trend[i] != trend[i+1])
               {
                  if (trend[i] ==  1) upDot[i] = rsi[i];
                  if (trend[i] == -1) dnDot[i] = rsi[i];
               }
             }
   return(0);
   }
 
   //
   //
   //
   //
   //
   
   if (trend[limit]==-1) CleanPoint(limit,rsida,rsidb);
   for(i=limit; i>=0; i--) prices[i] = iCustomMa(RsiPriceSmoothMet,getPrice(RsiPrice,Open,Close,High,Low,i,Bars),RsiPriceSmooth,i,Bars,0);
   for(i=limit; i>=0; i--)
   {
      double rsit   = iRSIOnArray(prices,0,RsiPeriod,i);
             rsi[i] = iCustomMa(SmoothingMethod,rsit,SmoothingPeriod,i,Bars,1);
             sig[i] = iCustomMa(MaMethod,rsi[i],MaPeriod,i,Bars,2);
             rsida[i] = EMPTY_VALUE;
             rsidb[i] = EMPTY_VALUE;
             upDot[i] = EMPTY_VALUE;
             dnDot[i] = EMPTY_VALUE;
             trend[i] = (rsi[i] > sig[i]) ? 1 : (rsi[i] < sig[i])? -1 : (i<Bars-1) ? trend[i+1] : 0;
             if (trend[i]==-1) PlotPoint(i,rsida,rsidb,rsi);
             if (i<Bars-1 && trend[i] != trend[i+1])
             {
                if (trend[i] ==  1) upDot[i] = rsi[i];
                if (trend[i] == -1) dnDot[i] = rsi[i];
             }
             
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
   }
   if (alertsOn)
   {
         int whichBar = 1; if (alertsOnCurrent) whichBar = 0;
         if (trend[whichBar] != trend[whichBar+1])
         if (trend[whichBar] == 1)
               doAlert(" crossed signal up ");
         else  doAlert(" crossed signal down ");       
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

#define _maInstances 3
#define _maWorkBufferx1 1*_maInstances
#define _maWorkBufferx2 2*_maInstances
#define _maWorkBufferx3 3*_maInstances

double iCustomMa(int mode, double price, double length, int r, int bars, int instanceNo=0)
{
   r = bars-r-1;
   switch (mode)
   {
      case ma_sma   : return(iSma(price,(int)ceil(length),r,bars,instanceNo));
      case ma_ema   : return(iEma(price,length,r,bars,instanceNo));
      case ma_smma  : return(iSmma(price,(int)ceil(length),r,bars,instanceNo));
      case ma_lwma  : return(iLwma(price,(int)ceil(length),r,bars,instanceNo));
      case ma_slwma : return(iSlwma(price,(int)ceil(length),r,bars,instanceNo));
      case ma_dsema : return(iDsema(price,length,r,bars,instanceNo));
      case ma_tema  : return(iTema(price,(int)ceil(length),r,bars,instanceNo));
      case ma_lsma  : return(iLinr(price,(int)ceil(length),r,bars,instanceNo));
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

#define _prHABF(_prtype) (_prtype>=pr_habclose && _prtype<=pr_habtbiased2)
#define _priceInstances     1
#define _priceInstancesSize 4
double workHa[][_priceInstances*_priceInstancesSize];
double getPrice(int tprice, const double& open[], const double& close[], const double& high[], const double& low[], int i, int bars, int instanceNo=0)
{
     if (tprice>=pr_haclose)
     {
         if (ArrayRange(workHa,0)!= bars) ArrayResize(workHa,bars); instanceNo*=_priceInstancesSize; int r = bars-i-1;
         
         //
         //
         //
         //
         //
         
         double haOpen  = (r>0) ?  (open[i+1]+close[i+1])*0.5 : (open[i]+close[i])*0.5;
         double haClose = (open[i]+high[i]+low[i]+close[i])*0.25;
         if (_prHABF(tprice))
               if (high[i]!=low[i])
                     haClose = (open[i]+close[i])/2.0+(((close[i]-open[i])/(high[i]-low[i]))*fabs((close[i]-open[i])/2.0));
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
   
//-------------------------------------------------------------------
//                                                                  
//-------------------------------------------------------------------
//
//
//
//
//

void CleanPoint(int i,double& first[],double& second[])
{
   if (i>=Bars-3) return;
   if ((second[i]  != EMPTY_VALUE) && (second[i+1] != EMPTY_VALUE))
        second[i+1] = EMPTY_VALUE;
   else
      if ((first[i] != EMPTY_VALUE) && (first[i+1] != EMPTY_VALUE) && (first[i+2] == EMPTY_VALUE))
          first[i+1] = EMPTY_VALUE;
}

void PlotPoint(int i,double& first[],double& second[],double& from[])
{
   if (i>=Bars-2) return;
   if (first[i+1] == EMPTY_VALUE)
      if (first[i+2] == EMPTY_VALUE) 
            { first[i]  = from[i]; first[i+1]  = from[i+1]; second[i] = EMPTY_VALUE; }
      else  { second[i] = from[i]; second[i+1] = from[i+1]; first[i]  = EMPTY_VALUE; }
   else     { first[i]  = from[i];                          second[i] = EMPTY_VALUE; }
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

void doAlert(string doWhat)
{
   static string   previousAlert="nothing";
   static datetime previousTime;
   string message;
   
      if (previousAlert != doWhat || previousTime != Time[0]) {
          previousAlert  = doWhat;
          previousTime   = Time[0];

       //
       //
       //
       //
       //
      
       message = timeFrameToString(_Period)+" "+Symbol()+" at "+TimeToStr(TimeLocal(),TIME_SECONDS)+" rsi ma "+doWhat;
          if (alertsMessage) Alert(message);
          if (alertsNotify)  SendNotification(message);
          if (alertsEmail)   SendMail(_Symbol+" rsi ma ",message);
          if (alertsSound)   PlaySound(soundFile);
       
   }
}

