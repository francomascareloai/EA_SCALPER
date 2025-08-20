//------------------------------------------------------------------
#property copyright "copyleft malden"
#property link      "www.forex-station.com"
//------------------------------------------------------------------
#property indicator_chart_window
#property indicator_buffers 7
#property indicator_width3  3
#property indicator_width4  3
#property indicator_width5  3
#property strict

//
//
//
//
//

#define _disBar 1
#define _disLin 2
#define _disZer 4
enum enDisplayType
{
   dis_01=_disLin,                // Display bb stops line
   dis_02=_disBar,                // Display bb stops bars
   dis_03=_disZer,                // Display bb stops "zero" line
   dis_04=_disLin+_disBar,        // Display bb stops line and bars
   dis_05=_disLin+_disZer,        // Display bb stops line and "zero" line
   dis_06=_disBar+_disZer,        // Display bb stops bars and "zero" line
   dis_07=_disLin+_disBar+_disZer // Display all
};
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
enum enMaTypes
{
   ma_sma,    // Simple moving average
   ma_ema,    // Exponential moving average
   ma_smma,   // Smoothed MA
   ma_lwma,   // Linear weighted MA
   ma_tema    // Triple exponential moving average - TEMA
};

extern ENUM_TIMEFRAMES TimeFrame       = PERIOD_CURRENT;  // Time frame
extern int             BandsPeriod     = 21;              // Bands period
extern double          BandsDeviation  = 3;               // Bands deviation
extern bool            BandsDeviationSample = false;      // Bands deviation with sample correction?
extern double          BandsRisk       = 3;               // Bands risk
extern enMaTypes       BandsMaType     = ma_sma;          // Bands average type
extern enPrices        Price           = pr_close;        // Price
extern bool            alertsOn        = false;           // Turn alerts on?
extern bool            alertsOnCurrent = false;           // Alerts on still opened bar?
extern bool            alertsMessage   = true;            // Alerts should display message?
extern bool            alertsSound     = false;           // Alerts should play a sound?
extern bool            alertsNotify    = false;           // Alerts should send a notification?
extern bool            alertsEmail     = false;           // Alerts should send an email?
extern string          soundFile       = "alert2.wav";    // Sound file
extern enDisplayType   DisplayWhat     = _disLin+_disBar; // Display type
extern color           ColorUp         = clrLimeGreen;    // Color for up
extern color           ColorDn         = clrOrangeRed;    // Color for down
extern color           ColorNe         = clrDarkGray;     // Color for neutral and "zero" line
extern bool            Interpolate     = true;            // Interpolate in multi time frame mode?
//
//
//
//
//

double upb[],dnb[],upa[],dna[],histou[],histod[],zero[],amax[],amin[],bmin[],bmax[],trend[],count[];
string indicatorFileName;
#define _mtfCall(_buff,_y) iCustom(NULL,TimeFrame,indicatorFileName,PERIOD_CURRENT,BandsPeriod,BandsDeviation,BandsDeviationSample,BandsRisk,BandsMaType,Price,alertsOn,alertsOnCurrent,alertsMessage,alertsSound,alertsNotify,alertsEmail,soundFile,_buff,_y)

//------------------------------------------------------------------
//
//------------------------------------------------------------------
//
//
//
//
//

int OnInit()
{
   int czer = ((DisplayWhat&_disZer)==0) ? clrNONE : ColorNe;
   int chup = ((DisplayWhat&_disBar)==0) ? clrNONE : ColorUp;
   int chdn = ((DisplayWhat&_disBar)==0) ? clrNONE : ColorDn;
   int clup = ((DisplayWhat&_disLin)==0) ? clrNONE : ColorUp;
   int cldn = ((DisplayWhat&_disLin)==0) ? clrNONE : ColorDn;
   int arst = ((DisplayWhat&_disLin)==0) ? DRAW_LINE : DRAW_ARROW;
   IndicatorBuffers(13);
         SetIndexBuffer(0,histou);   SetIndexStyle(0,DRAW_HISTOGRAM,EMPTY,EMPTY,chup);
         SetIndexBuffer(1,histod);   SetIndexStyle(1,DRAW_HISTOGRAM,EMPTY,EMPTY,chdn);
         SetIndexBuffer(2,zero);     SetIndexStyle(2,EMPTY,STYLE_DOT,0,czer);
         SetIndexBuffer(3,upb);      SetIndexStyle(3,EMPTY,EMPTY,EMPTY,clup);
         SetIndexBuffer(4,dnb);      SetIndexStyle(4,EMPTY,EMPTY,EMPTY,cldn);
         SetIndexBuffer(5,upa);      SetIndexStyle(5,arst,EMPTY,EMPTY,clup); SetIndexArrow(5,159);
         SetIndexBuffer(6,dna);      SetIndexStyle(6,arst,EMPTY,EMPTY,cldn); SetIndexArrow(6,159);
         SetIndexBuffer(7,amax);
         SetIndexBuffer(8,amin);
         SetIndexBuffer(9,bmax);
         SetIndexBuffer(10,bmin);
         SetIndexBuffer(11,trend);
         SetIndexBuffer(12,count);
         
      
      //
      //
      //
      //
      //
     
        indicatorFileName = WindowExpertName();
        TimeFrame         = MathMax(TimeFrame,_Period);  
      IndicatorShortName(timeFrameToString(TimeFrame)+"  BB stops");
return(0);
}  
void OnDeinit(const int reason) { }

//------------------------------------------------------------------
//
//------------------------------------------------------------------
//
//
//
//
//

int OnCalculate (const int       rates_total,
                 const int       prev_calculated,
                 const datetime& btime[],
                 const double&   open[],
                 const double&   high[],
                 const double&   low[],
                 const double&   close[],
                 const long&     tick_volume[],
                 const long&     volume[],
                 const int&      spread[] )
{

   int counted_bars = prev_calculated;
      if(counted_bars < 0) return(-1);
      if(counted_bars > 0) counted_bars--;
            int limit=MathMin(rates_total-counted_bars,rates_total-1); count[0] = limit;
            if (TimeFrame!=_Period)
            {
               limit = (int)MathMax(limit,MathMin(rates_total-1,_mtfCall(12,0)*TimeFrame/_Period));
               for (int i=limit;i>=0; i--)
               {
                  int y = iBarShift(NULL,TimeFrame,btime[i]);
                     zero[i]  = _mtfCall( 2,y);
                     bmax[i]  = _mtfCall( 9,y);
                     bmin[i]  = _mtfCall(10,y);
                     trend[i] = _mtfCall(11,y);
                     if (!Interpolate || (i>0 && y==iBarShift(NULL,TimeFrame,btime[i-1]))) continue;
                  
                     //
                     //
                     //
                     //
                     //
                  
                     #define _interpolate(buff) buff[i+k] = buff[i]+(buff[i+n]-buff[i])*k/n
                     int n,k; datetime time = iTime(NULL,TimeFrame,y);
                        for(n = 1; (i+n)<rates_total && btime[i+n] >= time; n++) continue;	
                        for(k = 1; k<n && (i+n)<rates_total && (i+k)<rates_total; k++) 
                        {
                           _interpolate(zero);
                           _interpolate(bmax);
                           _interpolate(bmin);
                        }                  
               }
               for (int i=limit;i>=0; i--)
               {
                  upb[i] = dnb[i] = EMPTY_VALUE;
                     if (trend[i] ==  1) { upb[i] = bmin[i]; histou[i] = high[i]; histod[i] = low[i]; }
                     if (trend[i] == -1) { dnb[i] = bmax[i]; histod[i] = high[i]; histou[i] = low[i]; }
                     upa[i] = (i<Bars-1) ? (trend[i]!=trend[i+1] && trend[i]== 1) ? upb[i] : EMPTY_VALUE :  EMPTY_VALUE;
                     dna[i] = (i<Bars-1) ? (trend[i]!=trend[i+1] && trend[i]==-1) ? dnb[i] : EMPTY_VALUE :  EMPTY_VALUE;
               }         
               return(rates_total);
            }               

   //
   //
   //
   //
   //

   for(int i=limit; i>=0; i--)
   {
      double price = getPrice(Price,open,close,high,low,i);
      double dev   = iDeviation(price,BandsPeriod,BandsDeviationSample,i);
               zero[i]  = iCustomMa(BandsMaType,price,BandsPeriod,i,0);
               amax[i]  = zero[i]+dev*BandsDeviation;
               amin[i]  = zero[i]-dev*BandsDeviation;
   	         bmax[i]  = amax[i]+0.5*(BandsRisk-1)*(amax[i]-amin[i]);
	  	         bmin[i]  = amin[i]-0.5*(BandsRisk-1)*(amax[i]-amin[i]);
               trend[i] = (i<Bars-1) ? (price>amax[i+1]) ? 1 : (price<amin[i+1]) ? -1 : trend[i+1] : 0;
                       if (i<Bars-1)
                       {
                           if (trend[i]==-1 && amax[i]>amax[i+1]) amax[i] = amax[i+1];
                           if (trend[i]== 1 && amin[i]<amin[i+1]) amin[i] = amin[i+1];
                           if (trend[i]==-1 && bmax[i]>bmax[i+1]) bmax[i] = bmax[i+1];
                           if (trend[i]== 1 && bmin[i]<bmin[i+1]) bmin[i] = bmin[i+1];
                       }                  
               upb[i] = EMPTY_VALUE; dnb[i] = EMPTY_VALUE;
               if (trend[i] ==  1) { upb[i] = bmin[i]; histou[i] = high[i]; histod[i] = low[i]; }
               if (trend[i] == -1) { dnb[i] = bmax[i]; histod[i] = high[i]; histou[i] = low[i]; }
               upa[i] = (i<Bars-1) ? (trend[i]!=trend[i+1] && trend[i]== 1) ? upb[i] : EMPTY_VALUE :  EMPTY_VALUE;
               dna[i] = (i<Bars-1) ? (trend[i]!=trend[i+1] && trend[i]==-1) ? dnb[i] : EMPTY_VALUE :  EMPTY_VALUE;
   }
   if (alertsOn)
   {
         int whichBar = 1; if (alertsOnCurrent) whichBar = 0; 
         if (trend[whichBar] != trend[whichBar+1])
         {
            if (trend[whichBar] == 1) doAlert(" up");
            if (trend[whichBar] ==-1) doAlert(" down");       
         }         
   }              
   return(rates_total);
}

//------------------------------------------------------------------
//                                                                  
//------------------------------------------------------------------
//
//
//
//
//

#define _maInstances 1
#define _maWorkBufferx1 1*_maInstances
#define _maWorkBufferx2 2*_maInstances
#define _maWorkBufferx3 3*_maInstances

double iCustomMa(int mode, double price, double length, int r, int instanceNo=0)
{
   int bars = Bars; r = bars-r-1;
   switch (mode)
   {
      case ma_sma   : return(iSma(price,(int)length,r,bars,instanceNo));
      case ma_ema   : return(iEma(price,length,r,bars,instanceNo));
      case ma_smma  : return(iSmma(price,(int)length,r,bars,instanceNo));
      case ma_lwma  : return(iLwma(price,(int)length,r,bars,instanceNo));
      case ma_tema  : return(iTema(price,(int)length,r,bars,instanceNo));
      default       : return(price);
   }
}

//
//
//
//
//

double workSma[][_maWorkBufferx2];
double iSma(double price, int period, int r, int _bars, int instanceNo=0)
{
   if (ArrayRange(workSma,0)!= _bars) ArrayResize(workSma,_bars); instanceNo *= 2; int k;

   workSma[r][instanceNo+0] = price;
   workSma[r][instanceNo+1] = price; for(k=1; k<period && (r-k)>=0; k++) workSma[r][instanceNo+1] += workSma[r-k][instanceNo+0];  
   workSma[r][instanceNo+1] /= 1.0*k;
   return(workSma[r][instanceNo+1]);
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

double workTema[][_maWorkBufferx3];
#define _tema1 0
#define _tema2 1
#define _tema3 2

double iTema(double price, double period, int r, int bars, int instanceNo=0)
{
   if (period<=1) return(price);
   if (ArrayRange(workTema,0)!= bars) ArrayResize(workTema,bars); instanceNo*=3;

   //
   //
   //
   //
   //
      
   workTema[r][_tema1+instanceNo] = price;
   workTema[r][_tema2+instanceNo] = price;
   workTema[r][_tema3+instanceNo] = price;
   double alpha = 2.0 / (1.0+period);
   if (r>0)
   {
          workTema[r][_tema1+instanceNo] = workTema[r-1][_tema1+instanceNo]+alpha*(price                         -workTema[r-1][_tema1+instanceNo]);
          workTema[r][_tema2+instanceNo] = workTema[r-1][_tema2+instanceNo]+alpha*(workTema[r][_tema1+instanceNo]-workTema[r-1][_tema2+instanceNo]);
          workTema[r][_tema3+instanceNo] = workTema[r-1][_tema3+instanceNo]+alpha*(workTema[r][_tema2+instanceNo]-workTema[r-1][_tema3+instanceNo]); }
   return(workTema[r][_tema3+instanceNo]+3.0*(workTema[r][_tema1+instanceNo]-workTema[r][_tema2+instanceNo]));
}

//------------------------------------------------------------------
//                                                                  
//------------------------------------------------------------------
// 
//
//
//
//

#define _devInstances 1
double workDev[][_devInstances];
double iDeviation(double value, int length, bool isSample, int i, int instanceNo=0)
{
   if (ArrayRange(workDev,0)!=Bars) ArrayResize(workDev,Bars); i=Bars-i-1; workDev[i][instanceNo] = value;
                 
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
         newMean  = (workDev[i-k][instanceNo]-oldMean)/(k+1)+oldMean;
         squares += (workDev[i-k][instanceNo]-oldMean)*(workDev[i-k][instanceNo]-newMean);
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

          message = timeFrameToString(_Period)+" "+_Symbol+" at "+TimeToStr(TimeLocal(),TIME_SECONDS)+" BB stops state changed to "+doWhat;
             if (alertsMessage) Alert(message);
             if (alertsNotify)  SendNotification(message);
             if (alertsEmail)   SendMail(_Symbol+" BB stops ",message);
             if (alertsSound)   PlaySound(soundFile);
      }
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

//------------------------------------------------------------------
//
//------------------------------------------------------------------
//
//
//
//
//
//

#define priceInstances 1
double workHa[][priceInstances*4];
double getPrice(int tprice, const double& open[], const double& close[], const double& high[], const double& low[], int i, int instanceNo=0)
{
  if (tprice>=pr_haclose)
   {
      if (ArrayRange(workHa,0)!= Bars) ArrayResize(workHa,Bars); instanceNo*=4;
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
            case pr_hatbiased2:
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