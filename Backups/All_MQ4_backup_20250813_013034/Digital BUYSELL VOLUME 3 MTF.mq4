//+------------------------------------------------------------------+
//|                                                                  |
//|                                                                  |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright ""
#property link      ""
#property version   ""
#property strict


#property indicator_separate_window
#property indicator_buffers 4
#property indicator_color1  PaleVioletRed
#property indicator_color2  DeepSkyBlue
#property indicator_color3  DimGray
#property indicator_color4  DimGray
#property indicator_width1  2
#property indicator_width2  2
#property indicator_width3  2
#property indicator_width4  2


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
   pr_hatbiased2  // Heiken ashi trend biased (extreme) price
};

enum maTypes
{
   ma_sma,     // simple moving average - SMA
   ma_ema,     // exponential moving average - EMA
   ma_dsema,   // double smoothed exponential moving average - DSEMA
   ma_dema,    // double exponential moving average - DEMA
   ma_tema,    // tripple exponential moving average - TEMA
   ma_smma,    // smoothed moving average - SMMA
   ma_lwma,    // linear weighted moving average - LWMA
   ma_pwma,    // parabolic weighted moving average - PWMA
   ma_alxma,   // Alexander moving average - ALXMA
   ma_vwma,    // volume weighted moving average - VWMA
   ma_hull,    // Hull moving average
   ma_tma,     // triangular moving average
   ma_sine,    // sine weighted moving average
   ma_linr,    // linear regression value
   ma_ie2,     // IE/2
   ma_nlma,    // non lag moving average
   ma_zlma,    // zero lag moving average
   ma_lead,    // leader exponential moving average
   ma_ssm,     // super smoother
   ma_smoo     // smoother
};

//------------------------------------------------------------------

extern ENUM_TIMEFRAMES  TimeFrame         = PERIOD_CURRENT;    // Time frame
extern maTypes          MaMethod          = 19;
extern enPrices         Price             = pr_close;          // Price
extern int              SmoothPeriod      = 14;                // smoothing period
extern bool             alertsOn          = false;             // Turn alert on or off
extern bool             alertsOnCurrent   = true;              // Alerts on current (still opened) bar
extern bool             alertsMessage     = true;              // Alerts should show pop-up message
extern bool             alertsPushNotif   = false;             // Alerts should send push notification
extern bool             alertsSound       = false;             // Alerts should play a sound
extern bool             alertsEmail       = false;             // Alerts should send email
extern bool             Interpolate       = true;              // Interpolate in multi time frame mode


//------------------------------------------------------------------

double bb[];
double bs[];
double vols[];
double volb[];
double trend[];
string indicatorFileName;
bool   returnBars;
double open[];
double high[];
double low[];
double close[];

//------------------------------------------------------------------

int init()
{
   IndicatorBuffers(9);
   SetIndexBuffer(0, bs); SetIndexStyle(0, DRAW_HISTOGRAM);
   SetIndexBuffer(1, bb); SetIndexStyle(1, DRAW_HISTOGRAM);
   SetIndexBuffer(2, vols);
   SetIndexBuffer(3, volb);
   SetIndexBuffer(4, trend);
   SetIndexBuffer(5, open);
   SetIndexBuffer(6, high);  
   SetIndexBuffer(7, low);
   SetIndexBuffer(8, close);
     
   indicatorFileName = WindowExpertName();
   returnBars        = TimeFrame==-99;
   TimeFrame         = MathMax(TimeFrame,_Period);
   IndicatorShortName(timeFrameToString(TimeFrame)+"  Buy Sell Presure Volume "+getAverageName(MaMethod)+"["+(string)SmoothPeriod+"]");
     
   return(0);
}

//-------------------------------------------------------------------

int deinit() 
{  
   return(0); 
}

//--------------------------------------------------------------------

int start()
{  
   int counted_bars=IndicatorCounted();
   if(counted_bars < 0) return(-1);
   if(counted_bars > 0) counted_bars--;
   int limit=MathMin(Bars-counted_bars,Bars-1);
   if (returnBars) 
      { 
         bs[0] = MathMin(limit+1,Bars-1); return(0); 
      }
   if (TimeFrame!=_Period)
   
   {
         limit = (int)MathMax(limit,MathMin(Bars-1,iCustom(NULL,TimeFrame,indicatorFileName,PERIOD_CURRENT, "returnBars",0,0)*TimeFrame/Period()));
         for(int i=limit; i>=0; i--)
            {
               int y = iBarShift(NULL,TimeFrame,Time[i]);
            
               bs[i]   = iCustom(NULL,TimeFrame,indicatorFileName,PERIOD_CURRENT,"",MaMethod,Price,SmoothPeriod,alertsOn,alertsOnCurrent,alertsMessage,alertsPushNotif,alertsSound,alertsEmail,0,y);
               bb[i]   = iCustom(NULL,TimeFrame,indicatorFileName,PERIOD_CURRENT,"",MaMethod,Price,SmoothPeriod,alertsOn,alertsOnCurrent,alertsMessage,alertsPushNotif,alertsSound,alertsEmail,1,y);
               vols[i] = iCustom(NULL,TimeFrame,indicatorFileName,PERIOD_CURRENT,"",MaMethod,Price,SmoothPeriod,alertsOn,alertsOnCurrent,alertsMessage,alertsPushNotif,alertsSound,alertsEmail,2,y);
               volb[i] = iCustom(NULL,TimeFrame,indicatorFileName,PERIOD_CURRENT,"",MaMethod,Price,SmoothPeriod,alertsOn,alertsOnCurrent,alertsMessage,alertsPushNotif,alertsSound,alertsEmail,3,y);
            
               if (!Interpolate || (y!=0 && y==iBarShift(NULL,TimeFrame,Time[MathMax(i-1,0)]))) continue;
               
               int n,k;
               datetime time = iTime(NULL,TimeFrame,y);
               for(n = 1; i+n < Bars && Time[i+n] >= time; n++) continue;	
               for(k = 1; k < n && (i+n)<Bars && (i+k)<Bars; k++) 
                  {
                     vols[i+k] = vols[i] + (vols[i+n] - vols[i]) * k/n;
                     volb[i+k] = volb[i] + (volb[i+n] - volb[i]) * k/n;
                     if (bs[i]!=EMPTY_VALUE) bs[i+k] = vols[i+k];
                     if (bb[i]!=EMPTY_VALUE) bb[i+k] = volb[i+k];
                  }                           
            }
            
            return(0);
      }

     
   double alpha = 2.0 / (1.0 + SmoothPeriod);
   for(int i=limit; i>=0; i--)
      {  
         close[i] = Close[i]; open[i] = Open[i]; high[i] = High[i]; low[i] = Low[i];
         double price = getPrice(Price,i);
         
         if (i>=Bars-1) { volb[i] = 0;  vols[i] = 0;  continue;}
         double volume = 0; 
         double avg    = iCustomMa(MaMethod,price,SmoothPeriod,i);
         if (Close[i]>avg) volume = (double) Volume[i];
         if (Close[i]<avg) volume = (double)-Volume[i];
            
         bb[i]    = EMPTY_VALUE;
         bs[i]    = EMPTY_VALUE;
      
         trend[i] = trend[i+1];
         if (volume>0) 
            { 
               volb[i] = volb[i+1]+alpha*(volume-volb[i+1]); bb[i] = volb[i]; trend[i] =  1; 
            }
         else  
            { 
               volb[i] = volb[i+1]; 
            }
         if (volume<0)
            { 
               vols[i] = vols[i+1]+alpha*(volume-vols[i+1]); bs[i] = vols[i]; trend[i] = -1; 
            }
         else  
            { 
               vols[i] = vols[i+1]; 
            }
      }
   manageAlerts();
   return(0);
}

//-------------------------------------------------------------------

void manageAlerts()
{
   if (alertsOn)
      {
         int whichBar = 1; if (alertsOnCurrent) whichBar = 0;
         if (trend[whichBar] != trend[whichBar+1])
            {
               if (trend[whichBar+1]==-1) doAlert(whichBar,"trend changed up");
               if (trend[whichBar+1]== 1) doAlert(whichBar,"trend changed down");
            }
      }
}

//-------------------------------------------------------------------

void doAlert(int forBar, string doWhat)
{
   static string   previousAlert="nothing";
   static datetime previousTime;
   string message;
   
   if (previousAlert != doWhat || previousTime != Time[forBar]) 
      {
         previousAlert  = doWhat;
         previousTime   = Time[forBar];

         message = timeFrameToString(Period())+" "+Symbol()+" at "+TimeToStr(TimeLocal(),TIME_SECONDS)+" Buy Sell volume "+doWhat;
         if (alertsMessage)   Alert(message);
         if (alertsEmail)     SendMail(StringConcatenate(Symbol()," Buy Sell volume "),message);
         if (alertsPushNotif) SendNotification(StringConcatenate(Symbol()," Buy Sell volume "+message));
         if (alertsSound)     PlaySound("alert2.wav");
      }
}

//-------------------------------------------------------------------

string sTfTable[] = {"M1","M5","M15","M30","H1","H4","D1","W1","MN"};
int    iTfTable[] = {1,5,15,30,60,240,1440,10080,43200};

int stringToTimeFrame(string tfs)
   {
      StringToUpper(tfs);
      for (int i=ArraySize(iTfTable)-1; i>=0; i--)
      if (tfs==sTfTable[i] || tfs==""+(string)iTfTable[i]) return(MathMax(iTfTable[i],Period()));

      return(Period());
   }

string timeFrameToString(int tf)
   {
      for (int i=ArraySize(iTfTable)-1; i>=0; i--) 
      if (tf==iTfTable[i]) return(sTfTable[i]);
      
      return("");
   }

//-------------------------------------------------------------------

#define priceInstances 1
double workHa[][priceInstances*4];
double getPrice(int tprice, int i, int instanceNo=0)

   {
      if (tprice>=pr_haclose)
         {
            if (ArrayRange(workHa,0)!= Bars) ArrayResize(workHa,Bars); instanceNo*=4;
            int r = Bars-i-1;
            
            double haOpen;
            if (r>0)
            haOpen  = (workHa[r-1][instanceNo+2] + workHa[r-1][instanceNo+3])/2.0;
            else   haOpen  = (open[i]+close[i])/2;
            double haClose = (open[i] + high[i] + low[i] + close[i]) / 4.0;
            double haHigh  = MathMax(high[i], MathMax(haOpen,haClose));
            double haLow   = MathMin(low[i] , MathMin(haOpen,haClose));

            if(haOpen  <haClose) 
               { 
                  workHa[r][instanceNo+0] = haLow;  workHa[r][instanceNo+1] = haHigh; 
               } 
            else                 
               { 
                  workHa[r][instanceNo+0] = haHigh; workHa[r][instanceNo+1] = haLow;  
               } 
            workHa[r][instanceNo+2] = haOpen;
            workHa[r][instanceNo+3] = haClose;
         
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
                  case pr_hatbiased2:
                  if (haClose>haOpen)  return(haHigh);
                  if (haClose<haOpen)  return(haLow);
                  return(haClose);        
               }
         }
   
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

string methodNames[] = {"SMA","EMA","Double smoothed EMA","Double EMA","Triple EMA","Smoothed MA","Linear weighted MA","Parabolic weighted MA","Alexander MA","Volume weghted MA","Hull MA","Triangular MA","Sine weighted MA","Linear regression","IE/2","NonLag MA","Zero lag EMA","Leader EMA","Super smoother","Smoother"};
string getAverageName(int method)
{
   int max = ArraySize(methodNames)-1;
      method=MathMax(MathMin(method,max),0); return(methodNames[method]);
}

#define _maWorkBufferx1 3
#define _maWorkBufferx2 6
#define _maWorkBufferx3 9
#define _maWorkBufferx5 15

double iCustomMa(int mode, double price, double length, int i, int instanceNo=0)
{
   int r = Bars-i-1;
   switch (mode)
   {
      case 0  : return(iSma(price,(int)length,r,instanceNo));
      case 1  : return(iEma(price,length,r,instanceNo));
      case 2  : return(iDsema(price,length,r,instanceNo));
      case 3  : return(iDema(price,length,r,instanceNo));
      case 4  : return(iTema(price,length,r,instanceNo));
      case 5  : return(iSmma(price,length,r,instanceNo));
      case 6  : return(iLwma(price,length,r,instanceNo));
      case 7  : return(iLwmp(price,length,r,instanceNo));
      case 8  : return(iAlex(price,length,r,instanceNo));
      case 9  : return(iWwma(price,length,r,instanceNo));
      case 10 : return(iHull(price,length,r,instanceNo));
      case 11 : return(iTma(price,length,r,instanceNo));
      case 12 : return(iSineWMA(price,(int)length,r,instanceNo));
      case 13 : return(iLinr(price,length,r,instanceNo));
      case 14 : return(iIe2(price,length,r,instanceNo));
      case 15 : return(iNonLagMa(price,length,r,instanceNo));
      case 16 : return(iZeroLag(price,length,r,instanceNo));
      case 17 : return(iLeader(price,length,r,instanceNo));
      case 18 : return(iSsm(price,length,r,instanceNo));
      case 19 : return(iSmooth(price,(int)length,r,instanceNo));
      default : return(0);
   }
}

//------------------------------------------------------------------

double workSma[][_maWorkBufferx2];
double iSma(double price, int period, int r, int instanceNo=0)
{
   int k;
   if (ArrayRange(workSma,0)!= Bars) ArrayResize(workSma,Bars); instanceNo *= 2;
   workSma[r][instanceNo] = price;
   if (r>=period){
   workSma[r][instanceNo+1] = workSma[r-1][instanceNo+1]+(workSma[r][instanceNo]-workSma[r-period][instanceNo])/period;
   }
   else { workSma[r][instanceNo+1] = 0; for(k=0; k<period && (r-k)>=0; k++) workSma[r][instanceNo+1] += workSma[r-k][instanceNo];  
          workSma[r][instanceNo+1] /= k; }
   return(workSma[r][instanceNo+1]);
}

//-----------

double workEma[][_maWorkBufferx1];
double iEma(double price, double period, int r, int instanceNo=0)
{
   if (ArrayRange(workEma,0)!= Bars) ArrayResize(workEma,Bars);
   double alpha = 2.0 / (1.0+period);
   workEma[r][instanceNo] = workEma[r-1][instanceNo]+alpha*(price-workEma[r-1][instanceNo]);
   return(workEma[r][instanceNo]);
}

//-----------

double workDsema[][_maWorkBufferx2];
#define _ema1 0
#define _ema2 1

double iDsema(double price, double period, int r, int instanceNo=0)
{
   if (ArrayRange(workDsema,0)!= Bars) ArrayResize(workDsema,Bars); instanceNo*=2;
   double alpha = 2.0 /(1.0+MathSqrt(period));
   workDsema[r][_ema1+instanceNo] = workDsema[r-1][_ema1+instanceNo]+alpha*(price                         -workDsema[r-1][_ema1+instanceNo]);
   workDsema[r][_ema2+instanceNo] = workDsema[r-1][_ema2+instanceNo]+alpha*(workDsema[r][_ema1+instanceNo]-workDsema[r-1][_ema2+instanceNo]);
   return(workDsema[r][_ema2+instanceNo]);
}

//-----------

double workDema[][_maWorkBufferx2];
#define _dema1 0
#define _dema2 1

double iDema(double price, double period, int r, int instanceNo=0)
{
   if (ArrayRange(workDema,0)!= Bars) ArrayResize(workDema,Bars); instanceNo*=2;
   double alpha = 2.0 / (1.0+period);
   workDema[r][_dema1+instanceNo] = workDema[r-1][_dema1+instanceNo]+alpha*(price                         -workDema[r-1][_dema1+instanceNo]);
   workDema[r][_dema2+instanceNo] = workDema[r-1][_dema2+instanceNo]+alpha*(workDema[r][_dema1+instanceNo]-workDema[r-1][_dema2+instanceNo]);
   return(workDema[r][_dema1+instanceNo]*2.0-workDema[r][_dema2+instanceNo]);
}

//-----------

double workTema[][_maWorkBufferx3];
#define _tema1 0
#define _tema2 1
#define _tema3 2

double iTema(double price, double period, int r, int instanceNo=0)
{
   if (ArrayRange(workTema,0)!= Bars) ArrayResize(workTema,Bars); instanceNo*=3;
   double alpha = 2.0 / (1.0+period);
          workTema[r][_tema1+instanceNo] = workTema[r-1][_tema1+instanceNo]+alpha*(price                         -workTema[r-1][_tema1+instanceNo]);
          workTema[r][_tema2+instanceNo] = workTema[r-1][_tema2+instanceNo]+alpha*(workTema[r][_tema1+instanceNo]-workTema[r-1][_tema2+instanceNo]);
          workTema[r][_tema3+instanceNo] = workTema[r-1][_tema3+instanceNo]+alpha*(workTema[r][_tema2+instanceNo]-workTema[r-1][_tema3+instanceNo]);
   return(workTema[r][_tema3+instanceNo]+3.0*(workTema[r][_tema1+instanceNo]-workTema[r][_tema2+instanceNo]));
}

//-----------

double workSmma[][_maWorkBufferx1];
double iSmma(double price, double period, int r, int instanceNo=0)
{
   if (ArrayRange(workSmma,0)!= Bars) ArrayResize(workSmma,Bars);
   if (r<period)
         workSmma[r][instanceNo] = price;
   else  workSmma[r][instanceNo] = workSmma[r-1][instanceNo]+(price-workSmma[r-1][instanceNo])/period;
   return(workSmma[r][instanceNo]);
}

//-----------

double workLwma[][_maWorkBufferx1];
double iLwma(double price, double period, int r, int instanceNo=0)
{
   if (ArrayRange(workLwma,0)!= Bars) ArrayResize(workLwma,Bars);
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

//-----------

double workLwmp[][_maWorkBufferx1];
double iLwmp(double price, double period, int r, int instanceNo=0)
{
   if (ArrayRange(workLwmp,0)!= Bars) ArrayResize(workLwmp,Bars);
 
   workLwmp[r][instanceNo] = price;
      double sumw = period*period;
      double sum  = sumw*price;

      for(int k=1; k<period && (r-k)>=0; k++)
      {
         double weight = (period-k)*(period-k);
                sumw  += weight;
                sum   += weight*workLwmp[r-k][instanceNo];  
      }             
      return(sum/sumw);
}

//-----------

double workAlex[][_maWorkBufferx1];
double iAlex(double price, double period, int r, int instanceNo=0)
{
   if (ArrayRange(workAlex,0)!= Bars) ArrayResize(workAlex,Bars);
   if (period<4) return(price);
   workAlex[r][instanceNo] = price;
      double sumw = period-2;
      double sum  = sumw*price;

      for(int k=1; k<period && (r-k)>=0; k++)
      {
         double weight = period-k-2;
                sumw  += weight;
                sum   += weight*workAlex[r-k][instanceNo];  
      }             
      return(sum/sumw);
}

//-----------

double workTma[][_maWorkBufferx1];
double iTma(double price, double period, int r, int instanceNo=0)
{
   if (ArrayRange(workTma,0)!= Bars) ArrayResize(workTma,Bars);
   
   workTma[r][instanceNo] = price;

      double half = (period+1.0)/2.0;
      double sum  = price;
      double sumw = 1;

      for(int k=1; k<period && (r-k)>=0; k++)
      {
         double weight = k+1; if (weight > half) weight = period-k;
                sumw  += weight;
                sum   += weight*workTma[r-k][instanceNo];  
      }             
      return(sum/sumw);
}

//-----------

double workSineWMA[][_maWorkBufferx1];
#define Pi 3.14159265358979323846264338327950288

double iSineWMA(double price, int period, int r, int instanceNo=0)
{
   if (period<1) return(price);
   if (ArrayRange(workSineWMA,0)!= Bars) ArrayResize(workSineWMA,Bars);
   
   workSineWMA[r][instanceNo] = price;
      double sum  = 0;
      double sumw = 0;
  
      for(int k=0; k<period && (r-k)>=0; k++)
      { 
         double weight = MathSin(Pi*(k+1.0)/(period+1.0));
                sumw  += weight;
                sum   += weight*workSineWMA[r-k][instanceNo]; 
      }
      return(sum/sumw);
}

//-----------

double workWwma[][_maWorkBufferx1];
double iWwma(double price, double period, int r, int instanceNo=0)
{
   if (ArrayRange(workWwma,0)!= Bars) ArrayResize(workWwma,Bars);
   
   workWwma[r][instanceNo] = price;
      int    i    = Bars-r-1;
      double sumw = (double)Volume[i];
      double sum  = sumw*price;

      for(int k=1; k<period && (r-k)>=0; k++)
      {
         double weight = (double)Volume[i+k];
                sumw  += weight;
                sum   += weight*workWwma[r-k][instanceNo];  
      }             
      return(sum/sumw);
}

//-----------

double workHull[][_maWorkBufferx2];
double iHull(double price, double period, int r, int instanceNo=0)
{
   int k;
   if (ArrayRange(workHull,0)!= Bars) ArrayResize(workHull,Bars);

   int HmaPeriod  = (int)MathMax(period,2);
   int HalfPeriod = (int)MathFloor(HmaPeriod/2);
   int HullPeriod = (int)MathFloor(MathSqrt(HmaPeriod));
   double hma,hmw,weight; instanceNo *= 2;

   workHull[r][instanceNo] = price;
               
   hmw = HalfPeriod; hma = hmw*price; 
   for(k=1; k<HalfPeriod && (r-k)>=0; k++)
      {
         weight = HalfPeriod-k;
         hmw   += weight;
         hma   += weight*workHull[r-k][instanceNo];  
      }             
   workHull[r][instanceNo+1] = 2.0*hma/hmw;

   hmw = HmaPeriod; hma = hmw*price; 
   for(k=1; k<period && (r-k)>=0; k++)
      {
         weight = HmaPeriod-k;
         hmw   += weight;
         hma   += weight*workHull[r-k][instanceNo];
      }             
   workHull[r][instanceNo+1] -= hma/hmw;

   hmw = HullPeriod; hma = hmw*workHull[r][instanceNo+1];
   for(k=1; k<HullPeriod && (r-k)>=0; k++)
      {
         weight = HullPeriod-k;
         hmw   += weight;
         hma   += weight*workHull[r-k][1+instanceNo];  
      }
   return(hma/hmw);
}

//-----------

double workLinr[][_maWorkBufferx1];
double iLinr(double price, double period, int r, int instanceNo=0)
{
   if (ArrayRange(workLinr,0)!= Bars) ArrayResize(workLinr,Bars);

   period = MathMax(period,1);
   workLinr[r][instanceNo] = price;
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

//-----------

double workIe2[][_maWorkBufferx1];
double iIe2(double price, double period, int r, int instanceNo=0)
{
   if (ArrayRange(workIe2,0)!= Bars) ArrayResize(workIe2,Bars);
   
      period = MathMax(period,1);
      workIe2[r][instanceNo] = price;
         double sumx=0, sumxx=0, sumxy=0, sumy=0;
         for (int k=0; k<period; k++)
         {
            price = workIe2[r-k][instanceNo];
                   sumx  += k;
                   sumxx += k*k;
                   sumxy += k*price;
                   sumy  +=   price;
         }
         double tslope  = (period*sumxy - sumx*sumy)/(sumx*sumx-period*sumxx);
         double average = sumy/period;
   return(((average+tslope)+(sumy+tslope*sumx)/period)/2.0);
}

//-----------

double workLeader[][_maWorkBufferx2];
double iLeader(double price, double period, int r, int instanceNo=0)
{
   if (ArrayRange(workLeader,0)!= Bars) ArrayResize(workLeader,Bars); instanceNo*=2;

      period = MathMax(period,1);
      double alpha = 2.0/(period+1.0);
         workLeader[r][instanceNo  ] = workLeader[r-1][instanceNo  ]+alpha*(price                          -workLeader[r-1][instanceNo  ]);
         workLeader[r][instanceNo+1] = workLeader[r-1][instanceNo+1]+alpha*(price-workLeader[r][instanceNo]-workLeader[r-1][instanceNo+1]);

   return(workLeader[r][instanceNo]+workLeader[r][instanceNo+1]);
}

//-----------

double workZl[][_maWorkBufferx2];
#define _price 0
#define _zlema 1

double iZeroLag(double price, double length, int r, int instanceNo=0)
{
   if (ArrayRange(workZl,0)!=Bars) ArrayResize(workZl,Bars); instanceNo *= 2; workZl[r][_price+instanceNo] = price;

   double median = 0;
   double alpha  = 2.0/(1.0+length); 
   int    per    = (int)((length-1.0)/2.0);
   if (r<per)
          workZl[r][_zlema+instanceNo] = price;
   else   
      {
         if ((int)length%2==0)
               median = (workZl[r-per][_price+instanceNo]+workZl[r-per-1][_price+instanceNo])/2.0;
         else  median =  workZl[r-per][_price+instanceNo];
         workZl[r][_zlema+instanceNo] = workZl[r-1][_zlema+instanceNo]+alpha*(2.0*price-median-workZl[r-1][_zlema+instanceNo]);
      }            
   return(workZl[r][_zlema+instanceNo]);
}

//-----------

double workSmooth[][_maWorkBufferx5];
double iSmooth(double price,int length,int r, int instanceNo=0)
{
   if (ArrayRange(workSmooth,0)!=Bars) ArrayResize(workSmooth,Bars); instanceNo *= 5;
 	if(r<=2) { workSmooth[r][instanceNo] = price; workSmooth[r][instanceNo+2] = price; workSmooth[r][instanceNo+4] = price; return(price); }
   
	double alpha = 0.45*(length-1.0)/(0.45*(length-1.0)+2.0);
   	  workSmooth[r][instanceNo+0] =  price+alpha*(workSmooth[r-1][instanceNo]-price);
	     workSmooth[r][instanceNo+1] = (price - workSmooth[r][instanceNo])*(1-alpha)+alpha*workSmooth[r-1][instanceNo+1];
	     workSmooth[r][instanceNo+2] =  workSmooth[r][instanceNo+0] + workSmooth[r][instanceNo+1];
	     workSmooth[r][instanceNo+3] = (workSmooth[r][instanceNo+2] - workSmooth[r-1][instanceNo+4])*MathPow(1.0-alpha,2) + MathPow(alpha,2)*workSmooth[r-1][instanceNo+3];
	     workSmooth[r][instanceNo+4] =  workSmooth[r][instanceNo+3] + workSmooth[r-1][instanceNo+4]; 
   return(workSmooth[r][instanceNo+4]);
}

//-----------

double workSsm[][_maWorkBufferx2];
#define _tprice  0
#define _ssm    1

double workSsmCoeffs[][4];
#define _period 0
#define _c1     1
#define _c2     2
#define _c3     3

double iSsm(double price, double period, int i, int instanceNo)
{
   if (ArrayRange(workSsm,0) !=Bars)                 ArrayResize(workSsm,Bars);
   if (ArrayRange(workSsmCoeffs,0) < (instanceNo+1)) ArrayResize(workSsmCoeffs,instanceNo+1);
   if (workSsmCoeffs[instanceNo][_period] != period)
   {
      workSsmCoeffs[instanceNo][_period] = period;
      double a1 = MathExp(-1.414*Pi/period);
      double b1 = 2.0*a1*MathCos(1.414*Pi/period);
         workSsmCoeffs[instanceNo][_c2] = b1;
         workSsmCoeffs[instanceNo][_c3] = -a1*a1;
         workSsmCoeffs[instanceNo][_c1] = 1.0 - workSsmCoeffs[instanceNo][_c2] - workSsmCoeffs[instanceNo][_c3];
   }

      int s = instanceNo*2;   
          workSsm[i][s+_tprice] = price;
          workSsm[i][s+_ssm]    = workSsmCoeffs[instanceNo][_c1]*(workSsm[i][s+_tprice]+workSsm[i-1][s+_price])/2.0 + 
                                  workSsmCoeffs[instanceNo][_c2]*workSsm[i-1][s+_ssm]                               + 
                                  workSsmCoeffs[instanceNo][_c3]*workSsm[i-2][s+_ssm]; 
   return(workSsm[i][s+_ssm]);
}

#define _length  0
#define _len     1
#define _weight  2

double  nlmvalues[3][_maWorkBufferx1];
double  nlmprices[ ][_maWorkBufferx1];
double  nlmalphas[ ][_maWorkBufferx1];

//-----------

double iNonLagMa(double price, double length, int r, int instanceNo=0)
{
   double t;
   if (ArrayRange(nlmprices,0) != Bars)       ArrayResize(nlmprices,Bars);
   if (ArrayRange(nlmvalues,0) <  instanceNo) ArrayResize(nlmvalues,instanceNo);
                               nlmprices[r][instanceNo]=price;
   if (length<3 || r<3) return(nlmprices[r][instanceNo]);
   
   if (nlmvalues[_length][instanceNo] != length  || ArraySize(nlmalphas)==0)
   {
      double Cycle = 4.0;
      double Coeff = 3.0*Pi;
      int    Phase = (int)length-1;
      
         nlmvalues[_length][instanceNo] = length;
         nlmvalues[_len   ][instanceNo] = length*4 + Phase;  
         nlmvalues[_weight][instanceNo] = 0;

         if (ArrayRange(nlmalphas,0) < nlmvalues[_len][instanceNo]) ArrayResize(nlmalphas,(int)nlmvalues[_len][instanceNo]);
         for (int k=0; k<nlmvalues[_len][instanceNo]; k++)
         {
            if (k<=Phase-1) 
                 t = 1.0 * k/(Phase-1);
            else t = 1.0 + (k-Phase+1)*(2.0*Cycle-1.0)/(Cycle*length-1.0); 
            double beta = MathCos(Pi*t);
            double g = 1.0/(Coeff*t+1); if (t <= 0.5 ) g = 1;
      
            nlmalphas[k][instanceNo]        = g * beta;
            nlmvalues[_weight][instanceNo] += nlmalphas[k][instanceNo];
         }
   }
   
   if (nlmvalues[_weight][instanceNo]>0)
   {
      double sum = 0;
           for (int k=0; k < nlmvalues[_len][instanceNo]; k++) sum += nlmalphas[k][instanceNo]*nlmprices[r-k][instanceNo];
           return( sum / nlmvalues[_weight][instanceNo]);
   }
   else return(0);           
}

//-----------------------------------------------------------