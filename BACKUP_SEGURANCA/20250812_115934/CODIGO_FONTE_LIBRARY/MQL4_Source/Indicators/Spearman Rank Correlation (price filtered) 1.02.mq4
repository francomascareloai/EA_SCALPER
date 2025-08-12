//+------------------------------------------------------------------+
//|                                    Spearman Rank Correlation.mq4 |
//+------------------------------------------------------------------+
#property copyright "www.forex-station.com"
#property link      "www.forex-station.com"

#property indicator_separate_window
#property indicator_buffers  5
#property indicator_color1   clrGray
#property indicator_color2   clrDeepSkyBlue
#property indicator_color3   clrDeepSkyBlue
#property indicator_color4   clrSandyBrown
#property indicator_color5   clrSandyBrown
#property indicator_width2   3
#property indicator_width3   3
#property indicator_width4   3
#property indicator_width5   3
#property indicator_minimum -1
#property indicator_maximum  1
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
   ma_sma,  // Simple moving average
   ma_ema,  // Exponential moving average
   ma_smma, // Smoothed moving average
   ma_lwma, // Linear weighted moving average
   ma_tema, // Triple exponential moving average - TEMA
   ma_lsma  // Linear regression value (lsma)
};

extern ENUM_TIMEFRAMES TimeFrame       = PERIOD_CURRENT; // Time frame to use
extern int             Rank            = 32;             // Rank
extern enPrices        Price           = pr_close;       // Price to use
extern int             PriceSmoothing  = 0;              // Price smoothing period
extern enMaTypes       PriceSmoothinhM = ma_sma;         // Price smoothing method
extern double          LevelUp         =  0.75;          // Upper level
extern double          LevelDn         = -0.75;          // Lower level
extern bool            AlertsOn        = false;          // Turn alert on?
extern bool            AlertsOnCurrent = true;           // Alerts on current (stil opened) bar?
extern bool            AlertsMessage   = true;           // Alerts should display alert message?
extern bool            AlertsSound     = false;          // Alerts should play a sound?
extern bool            AlertsEmail     = false;          // Alerts should send email?
extern bool            AlertsNotify    = false;          // Alerts should send notification?
extern color           ColorNeutral    = clrDarkGray;    // Color for neutral
extern color           ColorUp         = clrDeepSkyBlue; // Color for up
extern color           ColorDn         = clrSandyBrown;  // Color for down
extern int             LinesWidth      = 2;              // Lines width
extern int             HistoWidth      = 2;              // Histogram width
extern bool            Interpolate     = true;           // Interpolate in mult time frame mode?

//
//
//
//
//

double rank[],rankUa[],rankUb[],rankDa[],rankDb[],trend[],prices[],histou[],histod[],histom[],count[];
string indicatorFileName;
#define _mtfCall(_buff,_ind) iCustom(NULL,TimeFrame,indicatorFileName,PERIOD_CURRENT,Rank,Price,PriceSmoothing,PriceSmoothinhM,LevelUp,LevelDn,AlertsOn,AlertsOnCurrent,AlertsMessage,AlertsSound,AlertsEmail,AlertsNotify,_buff,_ind)

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
   IndicatorBuffers(11);          
   SetIndexBuffer(0, histou); SetIndexStyle(0,DRAW_HISTOGRAM,EMPTY,HistoWidth,ColorUp);
   SetIndexBuffer(1, histod); SetIndexStyle(1,DRAW_HISTOGRAM,EMPTY,HistoWidth,ColorDn);
   SetIndexBuffer(2, histom); SetIndexStyle(2,DRAW_HISTOGRAM,EMPTY,HistoWidth);
   SetIndexBuffer(3, rank);   SetIndexStyle(3,EMPTY,EMPTY,LinesWidth,ColorNeutral);
   SetIndexBuffer(4, rankUa); SetIndexStyle(4,EMPTY,EMPTY,LinesWidth,ColorNeutral);
   SetIndexBuffer(5, rankUb); SetIndexStyle(5,EMPTY,EMPTY,LinesWidth,ColorNeutral);
   SetIndexBuffer(6, rankDa); SetIndexStyle(6,EMPTY,EMPTY,LinesWidth,ColorNeutral);
   SetIndexBuffer(7, rankDb); SetIndexStyle(7,EMPTY,EMPTY,LinesWidth,ColorNeutral);
   SetIndexBuffer(8, trend);
   SetIndexBuffer(9, prices);
   SetIndexBuffer(10,count);
   
      //
      //
      //
      //
      //
      
         Rank              = MathMax(Rank,1);
         indicatorFileName = WindowExpertName();
         TimeFrame         = MathMax(TimeFrame,_Period); 

         SetLevelValue(0,LevelUp);          
         SetLevelValue(1,LevelDn);          
         
   IndicatorShortName(timeFrameToString(TimeFrame)+" Spearman ("+(string)Rank+","+(string)PriceSmoothing+")");
   return(0);
}
int deinit() {  return(0); }

//------------------------------------------------------------------
//
//------------------------------------------------------------------
//
//
//
//
//

double rankArray[][2];
int start()
{
   SetIndexStyle(2,EMPTY,EMPTY,HistoWidth,(color)ChartGetInteger(0,CHART_COLOR_BACKGROUND));
   int i,counted_bars=IndicatorCounted();
      if(counted_bars<0) return(-1);
      if(counted_bars>0) counted_bars--;
         int limit = fmin(Bars-counted_bars,Bars-1); count[0]=limit;
         if (TimeFrame!=_Period)
         {
            limit = (int)fmax(limit,fmin(Bars-1,_mtfCall(10,0)*TimeFrame/_Period));
            if (trend[limit]== 1) { CleanPoint(limit,rankUa,rankUb); histou[limit] = EMPTY_VALUE; histom[limit] = EMPTY_VALUE; }
            if (trend[limit]==-1) { CleanPoint(limit,rankDa,rankDb); histod[limit] = EMPTY_VALUE; histom[limit] = EMPTY_VALUE; }
            for (i=limit;i>=0 && !_StopFlag; i--)
            {
                  int y = iBarShift(NULL,TimeFrame,Time[i]);
                     rank[i]   = _mtfCall(3,y);
                     rankUa[i] = EMPTY_VALUE;
                     rankUb[i] = EMPTY_VALUE;
                     rankDa[i] = EMPTY_VALUE;
                     rankDb[i] = EMPTY_VALUE;
                     histou[i] = EMPTY_VALUE;
                     histod[i] = EMPTY_VALUE;
                     histom[i] = EMPTY_VALUE;
                     trend[i]  = _mtfCall(8,y);
                     
                     //
                     //
                     //
                     //
                     //
                     
                      if (!Interpolate || (i>0 && y==iBarShift(NULL,TimeFrame,Time[i-1]))) continue;
                      #define _interpolate(buff) buff[i+k] = buff[i]+(buff[i+n]-buff[i])*k/n
                      int n,k; datetime time = iTime(NULL,TimeFrame,y);
                         for(n = 1; (i+n)<Bars && Time[i+n] >= time; n++) continue;	
                         for(k = 1; k<n && (i+n)<Bars && (i+k)<Bars; k++) _interpolate(rank);                                             
            }
            for(i=limit; i>=0; i--) 
            {
                  if (trend[i] ==  1) { PlotPoint(i,rankUa,rankUb,rank); histou[i] = rank[i]; histom[i] = LevelUp; }
                  if (trend[i] == -1) { PlotPoint(i,rankDa,rankDb,rank); histod[i] = rank[i]; histom[i] = LevelDn; }
            }
            return(0);
      }

   //
   //
   //
   //
   //
   
   double coef = MathPow(Rank,3) - Rank;
   if (ArrayRange(rankArray,0)!=Rank) ArrayResize(rankArray,Rank);
   if (trend[limit]== 1) { CleanPoint(limit,rankUa,rankUb); histou[limit] = EMPTY_VALUE; histom[limit] = EMPTY_VALUE; }
   if (trend[limit]==-1) { CleanPoint(limit,rankDa,rankDb); histod[limit] = EMPTY_VALUE; histom[limit] = EMPTY_VALUE; }
   for(i = limit; i >= 0; i--)
   {
         prices[i] = iCustomMa(PriceSmoothinhM,getPrice(Price,Open,Close,High,Low,i,Bars),PriceSmoothing,i,Bars);
         for(int k=0; k<Rank && (i+k)<Bars; k++)
         {
            rankArray[k][0] = prices[i+k];
            rankArray[k][1] = k;
         }
         ArraySort(rankArray,EMPTY,0,MODE_DESCEND);
            double sum = 0.0; for(int k=0; k<Rank; k++) sum += (rankArray[k][1]-k)*(rankArray[k][1]-k);
            
            //
            //
            //
            //
            //
            
         rank[i]   = 1-6.00*sum/coef;
         rankUa[i] = EMPTY_VALUE;
         rankUb[i] = EMPTY_VALUE;
         rankDa[i] = EMPTY_VALUE;
         rankDb[i] = EMPTY_VALUE;
         histou[i] = EMPTY_VALUE;
         histod[i] = EMPTY_VALUE;
         histom[i] = EMPTY_VALUE;
         trend[i] = (i<Bars-1) ? (rank[i]>LevelUp) ? 1 : (rank[i]<LevelDn) ? -1 : (rank[i]<LevelUp && rank[i]>LevelDn) ? 0 :trend[i+1] : 0;    
          if (trend[i] ==  1) { PlotPoint(i,rankUa,rankUb,rank); histou[i] = rank[i]; histom[i] = LevelUp; }
          if (trend[i] == -1) { PlotPoint(i,rankDa,rankDb,rank); histod[i] = rank[i]; histom[i] = LevelDn; }
   }      
   manageAlerts();
return(0);
}      

//
//
//
//
//

#define _maInstances 1
#define _maWorkBufferx1 1*_maInstances
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
   double avg = price; int k=1; for(; k<period && (r-k)>=0; k++) avg += workSma[r-k][instanceNo+0];  
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
double iLwma(double price, double period, int r, int bars, int instanceNo=0)
{
   if (ArrayRange(workLwma,0)!= bars) ArrayResize(workLwma,bars);
   
   //
   //
   //
   //
   //
   
   workLwma[r][instanceNo] = price;
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

//-------------------------------------------------------------------
//
//-------------------------------------------------------------------
//
//
//
//
//

void manageAlerts()
{
   if (AlertsOn)
   {
      int whichBar = (AlertsOnCurrent) ? 0 : 1;
      if (trend[whichBar] != trend[whichBar+1])
      {
         if (trend[whichBar]   ==  1) doAlert(whichBar,DoubleToStr(LevelUp,2)+" broken up");
         if (trend[whichBar]   == -1) doAlert(whichBar,DoubleToStr(LevelDn,2)+" broken down");
         if (trend[whichBar+1] == -1) doAlert(whichBar,DoubleToStr(LevelDn,2)+" broken up");
         if (trend[whichBar+1] ==  1) doAlert(whichBar,DoubleToStr(LevelUp,2)+" broken down");
      }
   }
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

       message = _Symbol+" "+timeFrameToString(_Period)+" at "+TimeToStr(TimeLocal(),TIME_SECONDS)+"spearman level "+doWhat;
          if (AlertsMessage) Alert(message);
          if (AlertsEmail)   SendMail(_Symbol+"Spearman rank",message);
          if (AlertsNotify)  SendNotification(message);
          if (AlertsSound)   PlaySound("alert2.wav");
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

void CleanPoint(int i,double& first[],double& second[])
{
   if (i>Bars-2) return;
   if ((second[i]  != EMPTY_VALUE) && (second[i+1] != EMPTY_VALUE))
        second[i+1] = EMPTY_VALUE;
   else
      if ((first[i] != EMPTY_VALUE) && (first[i+1] != EMPTY_VALUE) && (first[i+2] == EMPTY_VALUE))
          first[i+1] = EMPTY_VALUE;
}

void PlotPoint(int i,double& first[],double& second[],double& from[])
{
   if (i>Bars-3) return;
   if (first[i+1] == EMPTY_VALUE)
         if (first[i+2] == EMPTY_VALUE) 
               { first[i]  = from[i]; first[i+1]  = from[i+1]; second[i] = EMPTY_VALUE; }
         else  { second[i] = from[i]; second[i+1] = from[i+1]; first[i]  = EMPTY_VALUE; }
   else        { first[i]  = from[i];                          second[i] = EMPTY_VALUE; }
}

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