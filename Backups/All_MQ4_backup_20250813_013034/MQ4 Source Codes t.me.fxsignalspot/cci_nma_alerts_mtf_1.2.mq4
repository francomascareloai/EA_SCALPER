//------------------------------------------------------------------
#property copyright "mladen"
#property link      "www.forex-station.com"
//------------------------------------------------------------------
#property indicator_separate_window
#property indicator_buffers 3
#property indicator_color1  clrLimeGreen
#property indicator_color2  clrOrange
#property indicator_color3  clrOrange
#property indicator_width1  3
#property indicator_width2  3
#property indicator_width3  3
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
enum enDoWhat
{
   do_cci,  // Make cci using nma as price filter
   do_nma   // Make nma smoothed cci
};
enum enFilterWhat
{
   flt_prc,  // Filter the price
   flt_cci,  // Filter the CCI
   flt_both  // Filter both
};
extern ENUM_TIMEFRAMES    TimeFrame          = PERIOD_CURRENT;// Time frame to use
extern int                pperiod            = 14;            // Calculating period
extern enPrices           pprice             = pr_close;      // Price
extern int                filter             = 40;            // Nma period 
extern int                filterTema         = 10;            // Nma tema period
extern double             pFilter            = 0;             // Filter (<=0, no filter
extern int                pFilterPeriod      = 0;             // Filter period (<=0 for same as calculating period)
extern enFilterWhat       pFilterType        = flt_cci;       // Filter what?
extern enDoWhat           doWhat             = do_cci;        // Make what?
extern bool               alertsOn           = true;          // Turn alerts on
extern bool               alertsOnCurrent    = true;          // Alerts on current (still opened) bar
extern bool               alertsMessage      = true;          // Alerts should display alert message
extern bool               alertsNotification = false;         // Alerts should send alert notification
extern bool               alertsSound        = false;         // Alerts should play alert sound
extern bool               alertsEmail        = false;         // Alerts should send alert email?
extern bool               Interpolate        = true;          // Interpolate in multi time frame mode?
extern int                linesWidth         =  3;            // Lines width


double buffer[];
double bufferda[];
double bufferdb[];
double trend[];
double work[];
double pricef[];
string indicatorFileName;
bool   returnBars;

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
   IndicatorBuffers(6);
   SetIndexBuffer(0,buffer,  INDICATOR_DATA); SetIndexStyle(0,EMPTY,EMPTY,linesWidth);
   SetIndexBuffer(1,bufferda,INDICATOR_DATA); SetIndexStyle(1,EMPTY,EMPTY,linesWidth);
   SetIndexBuffer(2,bufferdb,INDICATOR_DATA); SetIndexStyle(2,EMPTY,EMPTY,linesWidth);
   SetIndexBuffer(3,trend   ,INDICATOR_CALCULATIONS);
   SetIndexBuffer(4,work    ,INDICATOR_CALCULATIONS);
   SetIndexBuffer(5,pricef  ,INDICATOR_CALCULATIONS);
   
   indicatorFileName = WindowExpertName();
   returnBars        = TimeFrame==-99;
   TimeFrame         = MathMax(TimeFrame,_Period);
   IndicatorShortName(timeFrameToString(TimeFrame)+" cci nma ("+(string)pperiod+","+(string)filter+","+(string)pFilter+")");
return(0);
}

//
//
//
//
//

int start()
{
   int counted_bars=IndicatorCounted();
      if(counted_bars<0) return(-1);
      if(counted_bars>0) counted_bars--;
            int limit=MathMin(Bars-counted_bars,Bars-2);
            if (returnBars) { buffer[0] = MathMin(limit+1,Bars-1); return(0); }
            if (TimeFrame != Period())
            {
               if (trend[limit]==-1) CleanPoint(limit,bufferda,bufferdb);
               for(int i=limit; i>=0; i--)
               {
                  int y = iBarShift(NULL,TimeFrame,Time[i]);
                  buffer[i]   = iCustom(NULL,TimeFrame,indicatorFileName,PERIOD_CURRENT,pperiod,pprice,filter,filterTema,pFilter,pFilterPeriod,pFilterType,doWhat,alertsOn,alertsOnCurrent,alertsMessage,alertsNotification,alertsSound,alertsEmail,0,y);
                  trend[i]    = iCustom(NULL,TimeFrame,indicatorFileName,PERIOD_CURRENT,pperiod,pprice,filter,filterTema,doWhat,pFilterPeriod,pFilterType,alertsOn,alertsOnCurrent,alertsMessage,alertsNotification,alertsSound,alertsEmail,3,y);
                  bufferda[i] = EMPTY_VALUE;
                  bufferdb[i] = EMPTY_VALUE;
                  if (!Interpolate || (i>0 && y==iBarShift(NULL,TimeFrame,Time[i-1]))) continue;
                  
                  //
                  //
                  //
                  //
                  //
                  
                  int n,k; datetime time = iTime(NULL,TimeFrame,y);
                     for(n = 1; (i+n)<Bars && Time[i+n] >= time; n++) continue;	
                     for(k = 1; k<n && (i+n)<Bars && (i+k)<Bars; k++) 
                           buffer[i+k] = buffer[i] + (buffer[i+n] - buffer[i]) * k/n;
               }
               for(int i=limit; i>=0; i--) if (trend[i] == -1) PlotPoint(i,bufferda,bufferdb,buffer);
               return(0);
            }

   //
   //
   //
   //
   //

   if (trend[limit]==-1) CleanPoint(limit,bufferda,bufferdb);
   for(int i=limit; i>=0; i--)
   {
      int    tperiod = pFilterPeriod; if (tperiod<=1) tperiod = pperiod;
      double pfilter = pFilter; if (pFilterType==flt_cci) pfilter=0;
      double cfilter = pFilter; if (pFilterType==flt_prc) cfilter=0;
      if (doWhat==do_cci)
            pricef[i] = iNma(iFilter(getPrice(pprice,Open,Close,High,Low,i),pfilter,tperiod,i,0),filter,filterTema,i);
      else  pricef[i] =      iFilter(getPrice(pprice,Open,Close,High,Low,i),pfilter,tperiod,i,0);
      double avg = 0; for(int k=0; k<pperiod && (i+k)<Bars; k++) avg +=         pricef[i+k];      avg /= pperiod;
      double dev = 0; for(int k=0; k<pperiod && (i+k)<Bars; k++) dev += MathAbs(pricef[i+k]-avg); dev /= pperiod;
         if (dev!=0)
               work[i] = (pricef[i]-avg)/(0.015*dev);
         else  work[i] = 0;
         if (doWhat==do_cci)
                  buffer[i] = iFilter(work[i]                          ,cfilter,tperiod,i,1);
         else     buffer[i] = iFilter(iNma(work[i],filter,filterTema,i),cfilter,tperiod,i,1);
         bufferda[i] = EMPTY_VALUE;
         bufferdb[i] = EMPTY_VALUE;
         trend[i]    = trend[i+1];
      
         //
         //
         //
         //
         //
         
         if (buffer[i]>buffer[i+1]) trend[i] =  1;
         if (buffer[i]<buffer[i+1]) trend[i] = -1;
         if (trend[i] == -1) PlotPoint(i,bufferda,bufferdb,buffer);
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
         if (trend[whichBar] == 1)
               doAlert("sloping up");
         else  doAlert("sloping down");       
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

#define filterInstances 2
double workFil[][filterInstances*3];

#define _fchange 0
#define _fachang 1
#define _fprice  2

double iFilter(double tprice, double tfilter, int period, int i, int instanceNo=0)
{
   if (tfilter<=0) return(tprice);
   if (ArrayRange(workFil,0)!= Bars) ArrayResize(workFil,Bars); i = Bars-i-1; instanceNo*=3;
   
   //
   //
   //
   //
   //
   
   workFil[i][instanceNo+_fprice]  = tprice; if (i<1) return(tprice);
   workFil[i][instanceNo+_fchange] = MathAbs(workFil[i][instanceNo+_fprice]-workFil[i-1][instanceNo+_fprice]);
   workFil[i][instanceNo+_fachang] = workFil[i][instanceNo+_fchange];

   for (int k=1; k<period && (i-k)>=0; k++) workFil[i][instanceNo+_fachang] += workFil[i-k][instanceNo+_fchange];
                                            workFil[i][instanceNo+_fachang] /= period;
    
   double stddev = 0; for (int k=0;  k<period && (i-k)>=0; k++) stddev += MathPow(workFil[i-k][instanceNo+_fchange]-workFil[i-k][instanceNo+_fachang],2);
          stddev = MathSqrt(stddev/(double)period); 
   double filtev = tfilter * stddev;
   if( MathAbs(workFil[i][instanceNo+_fprice]-workFil[i-1][instanceNo+_fprice]) < filtev ) workFil[i][instanceNo+_fprice]=workFil[i-1][instanceNo+_fprice];
        return(workFil[i][instanceNo+_fprice]);
}

//------------------------------------------------------------------
//
//------------------------------------------------------------------
//
//
//
//
//

#define _nmaInstances 1
#define _nmaPrice     3
#define _nmaMom       4
#define _nmaValue     5
double workNma[][_nmaInstances*6];

double iNma(double price, int period, int temaperiod, int i, int instanceNo=0)
{
   if (period<=1) return(price);
   if (ArrayRange(workNma,0)!=Bars) ArrayResize(workNma,Bars); i = Bars-i-1; instanceNo*=6;

   //
   //
   //
   //
   //

   double alpha = 2.0 /(1.0 + temaperiod);
   if (i < 1)
   {
      workNma[i][instanceNo+_nmaPrice] = price;
      workNma[i][instanceNo+_nmaValue] = price;
      workNma[i][instanceNo+_nmaMom]   = 0;
      workNma[i][instanceNo+0]         = price;
      workNma[i][instanceNo+1]         = price;
      workNma[i][instanceNo+2]         = price;
   }
   else
   {
      workNma[i][instanceNo+0]         = workNma[i-1][instanceNo+0]+alpha*(price                   -workNma[i-1][instanceNo+0]);
      workNma[i][instanceNo+1]         = workNma[i-1][instanceNo+1]+alpha*(workNma[i][instanceNo+0]-workNma[i-1][instanceNo+1]);
      workNma[i][instanceNo+2]         = workNma[i-1][instanceNo+2]+alpha*(workNma[i][instanceNo+1]-workNma[i-1][instanceNo+2]);
      workNma[i][instanceNo+_nmaPrice] = 3*workNma[i][instanceNo+0] - 3*workNma[i][instanceNo+1] + workNma[i][instanceNo+2];
      workNma[i][instanceNo+_nmaMom]   = workNma[i][instanceNo+_nmaPrice]-workNma[i-1][instanceNo+_nmaPrice];
         
      //
      //
      //
      //
      //
   
      double momRatio = 0.00;
      double sumMomen = 0.00;
      double ratio    = 0.00;
      
      for (int k = 0; k<period && (i-k)>=0; k++)
      {
         sumMomen += MathAbs(workNma[i-k][instanceNo+_nmaMom]);
         momRatio +=         workNma[i-k][instanceNo+_nmaMom]*(MathSqrt(k+1)-MathSqrt(k));
      }
      if (sumMomen != 0) ratio = MathAbs(momRatio)/sumMomen;
      workNma[i][instanceNo+_nmaValue] =  workNma[i-1][instanceNo+_nmaValue]+ratio*(price-workNma[i-1][instanceNo+_nmaValue]);
   }         
   return(workNma[i][instanceNo+_nmaValue]);
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
   if ((second[i]  != EMPTY_VALUE) && (second[i+1] != EMPTY_VALUE))
        second[i+1] = EMPTY_VALUE;
   else
      if ((first[i] != EMPTY_VALUE) && (first[i+1] != EMPTY_VALUE) && (first[i+2] == EMPTY_VALUE))
          first[i+1] = EMPTY_VALUE;
}

//
//
//
//
//

void PlotPoint(int i,double& first[],double& second[],double& from[])
{
   if (i>=Bars-2) return;
   if (first[i+1] == EMPTY_VALUE)
         {
            if (first[i+2] == EMPTY_VALUE) 
                  { first[i]  = from[i]; first[i+1]  = from[i+1]; second[i] = EMPTY_VALUE; }
            else  { second[i] = from[i]; second[i+1] = from[i+1]; first[i]  = EMPTY_VALUE; }
         }
   else  { first[i] = from[i]; second[i] = EMPTY_VALUE; }
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

//-------------------------------------------------------------------
//
//-------------------------------------------------------------------
//
//
//
//
//

string sTfTable[] = {"M1","M5","M10","M15","M30","H1","H4","D1","W1","MN"};
int    iTfTable[] = {1,5,10,15,30,60,240,1440,10080,43200};

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

void doAlert(string doIt)
{
   static string   previousAlert="nothing";
   static datetime previousTime;
   string message;
   
      if (previousAlert != doIt || previousTime != Time[0]) {
          previousAlert  = doIt;
          previousTime   = Time[0];

          //
          //
          //
          //
          //

          message =  StringConcatenate(Symbol()," ",timeFrameToString(_Period)," at ",TimeToStr(TimeLocal(),TIME_SECONDS)," cci + nma ",doIt);
             if (alertsMessage)      Alert(message);
             if (alertsNotification) SendNotification(message);
             if (alertsEmail)        SendMail(StringConcatenate(Symbol()," cci + nma "),message);
             if (alertsSound)        PlaySound("alert2.wav");
      }
}