//------------------------------------------------------------------
#property copyright "mladen"
#property link      "www.forex-tsd.com"
//------------------------------------------------------------------
#property indicator_separate_window
#property indicator_buffers 5
#property indicator_color1  clrSilver
#property indicator_color2  clrSilver
#property indicator_color3  clrPaleVioletRed
#property indicator_width2  2
#property indicator_width3  2
#property indicator_width4  2
#property indicator_width5  2
#property indicator_level1  0
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
enum enFilterWhat
{
   flt_prc,  // Filter the price
   flt_pfr,  // Filter the price and macd
   flt_pfs,  // Filter the price and signal
   flt_frm,  // Filter the macd
   flt_frs,  // Filter the macd and signal
   flt_sig,  // Filter the signal
   flt_all   // Filter all
};
enum enMaMethods
{
   ma_sma,   // Simple moving average
   ma_ema,   // Exponential moving average
   ma_smma,  // Smoothed moving average
   ma_lwma,  // Linear weighted moving average
   ma_rema   // RSI adaptive ema
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

extern ENUM_TIMEFRAMES TimeFrame       = PERIOD_CURRENT; // Time frame to use
extern double          FastPeriod      = 14;             // Fast macd period
extern double          SlowPeriod      = 34;             // Slow macd period
extern int             SignalPeriod    =  9;             // Signal period
extern enMaMethods     SignalMethod    = ma_ema;         // Signal ma method
extern int             RsiPeriod       = 14;             // Rsi period
extern enRsiTypes      RsiMethod       = rsi_rsi;        // Rsi method
extern enPrices        Price           = pr_close;       // Rsi price
extern double          Filter          = 0;              // Filter to use for filtering (<=0 for no filtering)
extern int             FilterPeriod    = 0;              // Filter period (0<= use indicator fast period)
extern enFilterWhat    FilterOn        = flt_all;        // Apply filter to :
extern bool            ColorSignalLine = true;           // Color chanle applied to signal line?
extern color           ColorUp         = clrLimeGreen;   // Color for up
extern color           ColorDown       = clrDarkOrange;  // Color for down
extern color           ColorMacd       = clrSilver;      // Macd histogram color
extern color           ColorSignal     = clrSilver;      // Signal histogram color
extern bool            alertsOn        = true;           // Alerting on?
extern bool            alertsOnCurrent = false;          // Alerts on current (still opened) bar?
extern bool            alertsMessage   = true;           // Alert with pop-up message?
extern bool            alertsSound     = false;          // Alert using sound?
extern bool            alertsNotify    = false;          // Alert using push notifications?
extern bool            alertsEmail     = false;          // Alert using emails?
extern bool            Interpolate     = true;           // Interpolate when in multi time frame mode?

//
//
//
//
//

double macd[];
double macdl[];
double signal[];
double colorDa[];
double colorDb[];
double slope[],prices[],rsi[];

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
   IndicatorBuffers(8);
   SetIndexBuffer(0,macd); SetIndexStyle(0,DRAW_HISTOGRAM);
   SetIndexBuffer(1,macdl);
   SetIndexBuffer(2,signal);
   SetIndexBuffer(3,colorDa); SetIndexStyle(3,DRAW_LINE,EMPTY,EMPTY,ColorDown);
   SetIndexBuffer(4,colorDb); SetIndexStyle(4,DRAW_LINE,EMPTY,EMPTY,ColorDown);
   SetIndexBuffer(5,slope);
   SetIndexBuffer(6,prices);
   SetIndexBuffer(7,rsi);
         if (ColorSignalLine)
               { SetIndexStyle(2,DRAW_LINE,EMPTY,EMPTY,ColorUp); SetIndexStyle(1,DRAW_LINE,EMPTY,EMPTY,ColorMacd);   }
         else  { SetIndexStyle(1,DRAW_LINE,EMPTY,EMPTY,ColorUp); SetIndexStyle(2,DRAW_LINE,EMPTY,EMPTY,ColorSignal); }
   
      //
      //
      //
      //
      //
      
         indicatorFileName = WindowExpertName();
         returnBars        = (TimeFrame==-99);
         TimeFrame         = MathMax(TimeFrame,_Period);
      IndicatorShortName(timeFrameToString(TimeFrame)+" MACD "+getRsiName(RsiMethod)+" adaptive ("+(string)FastPeriod+","+(string)SlowPeriod+","+(string)SignalPeriod+","+(string)RsiPeriod+","+(string)Filter+")");
   return(0);
}
int deinit() { return(0); }

//------------------------------------------------------------------
//
//------------------------------------------------------------------
//
//
//
//
//

int start()
{
   int counted_bars=IndicatorCounted();
      if(counted_bars < 0) return(-1);
      if(counted_bars>0) counted_bars--;
         int limit = MathMin(Bars-counted_bars,Bars-1);
         if (returnBars) { macd[0] = MathMin(limit+1,Bars-1); return(0); }
         
   //
   //
   //
   //
   //
    
   if (TimeFrame == Period())
   {
      int    tperiod = FilterPeriod; if (tperiod<=0) tperiod = (int)FastPeriod;
      double pfilter = Filter, vfilter = Filter, sfilter = Filter;
      switch(FilterOn)
      {
         case flt_prc: vfilter=sfilter=0; break;
         case flt_pfr: sfilter=0;         break;
         case flt_pfs: vfilter=0;         break;
         case flt_frm: pfilter=sfilter=0; break;
         case flt_frs: pfilter=0;         break;
         case flt_sig: pfilter=vfilter=0; break;
      }         
      if (slope[limit]==-1) CleanPoint(limit,colorDa,colorDb);
      for(int i = limit; i>=0; i--)
      {
         prices[i] = getPrice(Price,Open,Close,High,Low,i);
         double price = iFilter(prices[i],pfilter,tperiod,i,0);
         rsi[i]   = iRsi(RsiMethod,prices[i],RsiPeriod,i);
         macd[i]  = iFilter(iREma(price,(int)FastPeriod,RsiPeriod,rsi[i],i,0)-iREma(price,(int)SlowPeriod,RsiPeriod,rsi[i],i,1),vfilter,tperiod,i,1);
         macdl[i] = macd[i];
      }            
      for(int i = limit; i>=0; i--)
      {
         if (SignalMethod==ma_rema)
               signal[i] = iFilter(iREma(macd[i],SignalPeriod,RsiPeriod,rsi[i],i,2)     ,sfilter,tperiod,i,2);
         else  signal[i] = iFilter(iMAOnArray(macd,0,SignalPeriod,0,(int)SignalMethod,i),sfilter,tperiod,i,2);
         
         //
         //
         //
         //
         //
         
            colorDa[i] = EMPTY_VALUE;
            colorDb[i] = EMPTY_VALUE;
            if (i<Bars-1)
            {
               slope[i] = slope[i+1];
               if (ColorSignalLine)
               {
                  if (signal[i]>signal[i+1]) slope[i] =  1;
                  if (signal[i]<signal[i+1]) slope[i] = -1;
                     if (slope[i]==-1) PlotPoint(i,colorDa,colorDb,signal);
               }
               else
               {
                  if (macd[i]>macd[i+1]) slope[i] =  1;
                  if (macd[i]<macd[i+1]) slope[i] = -1;
                     if (slope[i]==-1) PlotPoint(i,colorDa,colorDb,macd);
               }
            }               
      }         
      if (alertsOn)
      {
         int whichBar = 1; if (alertsOnCurrent) whichBar = 0;
      
         //
         //
         //
         //
         //
         
         static datetime time1 = 0;
         static string   mess1 = "";
         if (slope[whichBar] != slope[whichBar+1])
         {
            string name = " macd "; if (ColorSignalLine) name = " signal line";
            if (slope[whichBar] ==  1) doAlert(time1,mess1,name+" sloping up");
            if (slope[whichBar] == -1) doAlert(time1,mess1,name+" sloping down");
         }            
      }
      return(0);
   }
   
   //
   //
   //
   //
   //
   
   limit = (int)MathMax(limit,MathMin(Bars-1,iCustom(NULL,TimeFrame,indicatorFileName,-99,0,0)*TimeFrame/Period()));
   if (slope[limit]==-1) CleanPoint(limit,colorDa,colorDb);
   for (int i=limit; i>=0; i--)
   {
      int y = iBarShift(NULL,TimeFrame,Time[i]);
         macd[i]    = iCustom(NULL,TimeFrame,indicatorFileName,PERIOD_CURRENT,FastPeriod,SlowPeriod,SignalPeriod,SignalMethod,RsiPeriod,RsiMethod,Price,Filter,FilterPeriod,FilterOn,ColorSignalLine,alertsOn,alertsOnCurrent,alertsMessage,alertsSound,alertsNotify,alertsEmail,0,y);
         signal[i]  = iCustom(NULL,TimeFrame,indicatorFileName,PERIOD_CURRENT,FastPeriod,SlowPeriod,SignalPeriod,SignalMethod,RsiPeriod,RsiMethod,Price,Filter,FilterPeriod,FilterOn,ColorSignalLine,alertsOn,alertsOnCurrent,alertsMessage,alertsSound,alertsNotify,alertsEmail,2,y);
         slope[i]   = iCustom(NULL,TimeFrame,indicatorFileName,PERIOD_CURRENT,FastPeriod,SlowPeriod,SignalPeriod,SignalMethod,RsiPeriod,RsiMethod,Price,Filter,FilterPeriod,FilterOn,ColorSignalLine,alertsOn,alertsOnCurrent,alertsMessage,alertsSound,alertsNotify,alertsEmail,5,y);
         macdl[i]   = macd[i];
         colorDa[i] = EMPTY_VALUE;
         colorDb[i] = EMPTY_VALUE;
         
         if (!Interpolate || (i>0 && y==iBarShift(NULL,TimeFrame,Time[i-1]))) continue;
                  
         //
         //
         //
         //
         //
                  
         int n,j; datetime time = iTime(NULL,TimeFrame,y);
            for(n = 1; (i+n)<Bars && Time[i+n] >= time; n++) continue;	
            for(j = 1; j<n && (i+n)<Bars && (i+j)<Bars; j++)
            {
               macdl[i+j]  = macdl[i]  + (macdl[i+n]  - macdl[i] )*j/n;
               signal[i+j] = signal[i] + (signal[i+n] - signal[i])*j/n;
            }
         
   }
   for (int i=limit; i>=0; i--)
   {   
            if (ColorSignalLine)
                  { if (slope[i]==-1) PlotPoint(i,colorDa,colorDb,signal); }
            else  { if (slope[i]==-1) PlotPoint(i,colorDa,colorDb,macd);   }
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

#define filterInstances 3
double workFil[][filterInstances*3];

#define _fchange 0
#define _fachang 1
#define _fprice  2

double iFilter(double tprice, double filter, int period, int i, int instanceNo=0)
{
   if (filter<=0) return(tprice);
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
   double filtev = filter * stddev;
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

double ema[][3];
double iREma(double price, int emaPeriod, int rsiPeriod, double trsi, int i, int instanceNo=0)
{
   if (ArrayRange(ema,0)!=Bars) ArrayResize(ema,Bars); int r=Bars-i-1;
   
   //
   //
   //
   //
   //
   
   double RSvoltl = MathAbs(trsi-50)+1.0;
   double multi   = (5.0+100.0/rsiPeriod)/(0.06+0.92*RSvoltl+0.02*MathPow(RSvoltl,2));
   double alpha   = 2.0 /(1.0+multi*emaPeriod);
   if (r<1)
           ema[r][instanceNo] = price;
   else    ema[r][instanceNo] = ema[r-1][instanceNo]+alpha*(price-ema[r-1][instanceNo]);
   return( ema[r][instanceNo]);           
}

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
      method=MathMax(MathMin(method,max),0); return(rsiMethodNames[method]);
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

double iRsi(int rsiMode, double price, double period, int i, int instanceNo=0)
{
   if (ArrayRange(workRsi,0)!=Bars) ArrayResize(workRsi,Bars);
      int z = instanceNo*13; 
      int r = Bars-i-1;
   
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
         double alpha = 1.0/MathMax(period,1); 
         if (r<period)
            {
               int k; double sum = 0; for (k=0; k<period && (r-k-1)>=0; k++) sum += MathAbs(workRsi[r-k][z+_price]-workRsi[r-k-1][z+_price]);
                  workRsi[r][z+_change] = (workRsi[r][z+_price]-workRsi[0][z+_price])/MathMax(k,1);
                  workRsi[r][z+_changa] =                                         sum/MathMax(k,1);
            }
         else
            {
               double change = workRsi[r][z+_price]-workRsi[r-1][z+_price];
                               workRsi[r][z+_change] = workRsi[r-1][z+_change] + alpha*(        change  - workRsi[r-1][z+_change]);
                               workRsi[r][z+_changa] = workRsi[r-1][z+_changa] + alpha*(MathAbs(change) - workRsi[r-1][z+_changa]);
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
                     workRsi[r][z+_rsival] = workRsi[r-1][z+_rsival]+(1/MathMax(period,1))*(50            -workRsi[r-1][z+_rsival]);
               else  workRsi[r][z+_rsival] = workRsi[r-1][z+_rsival]+(1/MathMax(period,1))*(100*up/(up+dn)-workRsi[r-1][z+_rsival]);
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
            double moa = MathAbs(mom);
            for (int k=0; k<3; k++)
            {
               int kk = k*2;
               workRsi[r][z+kk+1] = Kg*mom                + Hg*workRsi[r-1][z+kk+1];
               workRsi[r][z+kk+2] = Kg*workRsi[r][z+kk+1] + Hg*workRsi[r-1][z+kk+2]; mom = 1.5*workRsi[r][z+kk+1] - 0.5 * workRsi[r][z+kk+2];
               workRsi[r][z+kk+7] = Kg*moa                + Hg*workRsi[r-1][z+kk+7];
               workRsi[r][z+kk+8] = Kg*workRsi[r][z+kk+7] + Hg*workRsi[r-1][z+kk+8]; moa = 1.5*workRsi[r][z+kk+7] - 0.5 * workRsi[r][z+kk+8];
            }
            if (moa != 0)
                 return(MathMax(MathMin((mom/moa+1.0)*50.0,100.00),0.00)); 
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
            { first[i]  = from[i];  first[i+1]  = from[i+1]; second[i] = EMPTY_VALUE; }
      else  { second[i] =  from[i]; second[i+1] = from[i+1]; first[i]  = EMPTY_VALUE; }
   else     { first[i]  = from[i];                           second[i] = EMPTY_VALUE; }
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

//
//
//
//
//

void doAlert(datetime& previousTime, string& previousAlert, string doWhat)
{
   string message;
   
      if (previousAlert != doWhat || previousTime != Time[0]) {
          previousAlert  = doWhat;
          previousTime   = Time[0];

          //
          //
          //
          //
          //

          message =  StringConcatenate(Symbol()," at ",TimeToStr(TimeLocal(),TIME_SECONDS),doWhat);
             if (alertsMessage) Alert(message);
             if (alertsNotify)  SendNotification(message);
             if (alertsEmail)   SendMail(StringConcatenate(Symbol()," MACD -RSI adaptive "),message);
             if (alertsSound)   PlaySound("alert2.wav");
      }
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
double getPrice(int price, const double& open[], const double& close[], const double& high[], const double& low[], int i, int instanceNo=0)
{
  if (price>=pr_haclose)
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
         
         switch (price)
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
   
   switch (price)
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
