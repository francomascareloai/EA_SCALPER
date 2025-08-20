//------------------------------------------------------------------
#property copyright "www.forex-station.com"
#property link      "www.forex-station.com"
//------------------------------------------------------------------

#property indicator_chart_window
#property indicator_buffers 5
#property indicator_color1  clrLimeGreen
#property indicator_color2  clrRed
#property indicator_color3  clrRed
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
   pr_hatbiased2  // Heiken ashi trend biased (extreme) price
};
enum enFilterWhat
{
   flt_prc,  // Filter the price
   flt_val,  // Filter the non lag ma value
   flt_both  // Filter both
};
enum enDisplay
{
   en_lin,  // Display line
   en_lid,  // Display lines with dots
   en_dot   // Display dots
};

extern ENUM_TIMEFRAMES TimeFrame         = PERIOD_CURRENT;    // Time frame to use
extern int             NlmPeriod         = 25;                // Non lag ma period
extern enPrices        NlmPrice          = pr_close;          // Price to use
extern double          Filter            =  0;                // Filter to use (<=0 no filter)
extern int             FilterPeriod      =  0;                // Filter period (<=0 use Non lag ma period)
extern enFilterWhat    FilterOn          = flt_prc;           // Apply filter to:
extern enDisplay       DisplayType       = en_lin;            // Display type
extern int             Shift             = 0;                 // Shift
extern int             LinesWidth        = 3;                 // Lines width (when lines are included in display)
extern bool            alertsOn          = true;              // Turn alerts on?
extern bool            alertsOnCurrent   = false;             // Alerts on current (still opened) bar?
extern bool            alertsMessage     = true;              // Alerts should display a message?
extern bool            alertsSound       = false;             // Alerts should play a sound?
extern bool            alertsEmail       = false;             // Alerts should send an email?
extern bool            alertsNotify      = false;             // Alerts should send notification?
extern bool            ArrowOnFirst      = true;              // Arrow on first bars
extern int             UpArrowSize       = 2;                 // Up Arrow size
extern int             DnArrowSize       = 2;                 // Down Arrow size
extern int             UpArrowCode       = 159;               // Up Arrow code
extern int             DnArrowCode       = 159;               // Down arrow code
extern double          UpArrowGap        = 0.5;               // Up Arrow gap        
extern double          DnArrowGap        = 0.5;               // Dn Arrow gap
extern color           UpArrowColor      = clrLimeGreen;      // Up Arrow Color
extern color           DnArrowColor      = clrOrange;         // Down Arrow Color
extern bool            Interpolate       = true;              // Interpolate in mtf mode

//
//
//
//
//

double nlmDa[];
double nlmDb[];
double trend[];
double nlm[];
double arrowu[];
double arrowd[];
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
   int lstyle = DRAW_LINE;     if (DisplayType==en_dot) lstyle = DRAW_NONE;
   int astyle = DRAW_ARROW;    if (DisplayType<en_lid)  astyle = DRAW_NONE;
   SetIndexBuffer(0, nlm);     SetIndexStyle(0,lstyle,EMPTY,LinesWidth);
   SetIndexBuffer(1, nlmDa);   SetIndexStyle(1,lstyle,EMPTY,LinesWidth);
   SetIndexBuffer(2, nlmDb);   SetIndexStyle(2,lstyle,EMPTY,LinesWidth);
   SetIndexBuffer(3, arrowu);  SetIndexStyle(3,astyle,0,UpArrowSize,UpArrowColor); SetIndexArrow(3,UpArrowCode);
   SetIndexBuffer(4, arrowd);  SetIndexStyle(4,astyle,0,DnArrowSize,DnArrowColor); SetIndexArrow(4,DnArrowCode);
   SetIndexBuffer(5, trend);

      //
      //
      //
      //
      //
         
          indicatorFileName = WindowExpertName();
          returnBars        = TimeFrame==-99;
          TimeFrame         = fmax(TimeFrame,_Period);
          for (int i=0; i<7; i++) SetIndexShift(i,Shift*TimeFrame/Period());
   
      //
      //
      //
      //
      //
      
return(0);
}
int deinit() {   return(0); }

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
   int i,limit,counted_bars=IndicatorCounted();
      if(counted_bars<0) return(-1);
      if(counted_bars>0) counted_bars--;
         limit = fmin(Bars-counted_bars,Bars-1);
         if (returnBars) { nlm[0] = limit+1; return(0); }

   //
   //
   //
   //
   //

   if (TimeFrame == Period())
   {
      if (trend[limit]==-1) CleanPoint(limit,nlmDa,nlmDb);
      for(i=limit; i>=0; i--)
      {  
         int    tperiod = FilterPeriod; if (tperiod<=0)  tperiod=(int)NlmPeriod;
         double pfilter = Filter; if (FilterOn==flt_val) pfilter=0;
         double vfilter = Filter; if (FilterOn==flt_prc) vfilter=0;
         double price = iFilter(getPrice(NlmPrice,Open,Close,High,Low,i),pfilter,tperiod,i,0);
         nlm[i]   = iFilter(iNoLagMa(price,NlmPeriod,i),vfilter,tperiod,i,1);
         nlmDa[i] = EMPTY_VALUE;
         nlmDb[i] = EMPTY_VALUE;
         trend[i] = (i<Bars-1) ? (nlm[i]>nlm[i+1]) ? 1 : (nlm[i]<nlm[i+1]) ? -1 : trend[i+1] : 0;
         if (trend[i] == -1) PlotPoint(i,nlmDa,nlmDb,nlm);
         if (i<Bars-1 && trend[i]!=trend[i+1])
         {
            if (trend[i] ==  1) arrowu[i] = fmin(nlm[i],Low[i] )-iATR(NULL,0,15,i)*UpArrowGap;
            if (trend[i] == -1) arrowd[i] = fmax(nlm[i],High[i])+iATR(NULL,0,15,i)*DnArrowGap;
         } 
     }
   manageAlerts();
   return(0);
   }
   
   //
   //
   //
   //
   //
   
   limit = (int)fmax(limit,fmin(Bars-1,iCustom(NULL,TimeFrame,indicatorFileName,-99,0,0)*TimeFrame/_Period));
   if (trend[limit]==-1) CleanPoint(limit,nlmDa,nlmDb);
   for(i=limit; i>=0; i--)
   {
      int y = iBarShift(NULL,TimeFrame,Time[i]);
      int x = y;
      if (ArrowOnFirst)
            {  if (i<Bars-1) x = iBarShift(NULL,TimeFrame,Time[i+1]);          }
      else  {  if (i>0) x = iBarShift(NULL,TimeFrame,Time[i-1]); else x = -1;  }
         nlm[i]   = iCustom(NULL,TimeFrame,indicatorFileName,PERIOD_CURRENT,NlmPeriod,NlmPrice,Filter,FilterPeriod,FilterOn,DisplayType,0,0,alertsOn,alertsOnCurrent,alertsMessage,alertsSound,alertsEmail,alertsNotify,ArrowOnFirst,UpArrowSize,DnArrowSize,UpArrowCode,DnArrowCode,UpArrowGap,DnArrowGap,UpArrowColor,DnArrowColor,0,y);
         trend[i] = iCustom(NULL,TimeFrame,indicatorFileName,PERIOD_CURRENT,NlmPeriod,NlmPrice,Filter,FilterPeriod,FilterOn,DisplayType,0,0,alertsOn,alertsOnCurrent,alertsMessage,alertsSound,alertsEmail,alertsNotify,ArrowOnFirst,UpArrowSize,DnArrowSize,UpArrowCode,DnArrowCode,UpArrowGap,DnArrowGap,UpArrowColor,DnArrowColor,5,y);
         nlmDa[i] = EMPTY_VALUE;
         nlmDb[i] = EMPTY_VALUE;
         arrowu[i] = EMPTY_VALUE;
         arrowd[i] = EMPTY_VALUE;
         if (x!=y)
         {
            arrowu[i] = iCustom(NULL,TimeFrame,indicatorFileName,PERIOD_CURRENT,NlmPeriod,NlmPrice,Filter,FilterPeriod,FilterOn,DisplayType,0,0,alertsOn,alertsOnCurrent,alertsMessage,alertsSound,alertsEmail,alertsNotify,ArrowOnFirst,UpArrowSize,DnArrowSize,UpArrowCode,DnArrowCode,UpArrowGap,DnArrowGap,UpArrowColor,DnArrowColor,3,y);
            arrowd[i] = iCustom(NULL,TimeFrame,indicatorFileName,PERIOD_CURRENT,NlmPeriod,NlmPrice,Filter,FilterPeriod,FilterOn,DisplayType,0,0,alertsOn,alertsOnCurrent,alertsMessage,alertsSound,alertsEmail,alertsNotify,ArrowOnFirst,UpArrowSize,DnArrowSize,UpArrowCode,DnArrowCode,UpArrowGap,DnArrowGap,UpArrowColor,DnArrowColor,4,y);
         }
         
         //
         //
         //
         //
         //
      
         if (!Interpolate || (i>0 && y==iBarShift(NULL,TimeFrame,Time[i-1]))) continue;
                  
         //
         //
         //
         //
         //
                  
         int n,j; datetime time = iTime(NULL,TimeFrame,y);
            for(n = 1; (i+n)<Bars && Time[i+n] >= time; n++) continue;	
            for(j = 1; j<n && (i+n)<Bars && (i+j)<Bars; j++) nlm[i+j] = nlm[i] + (nlm[i+n] - nlm[i])*j/n;        
   }
   for (i=limit;i>=0;i--) if (trend[i] == -1) PlotPoint(i,nlmDa,nlmDb,nlm);
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

#define _length  0
#define _len     1
#define _weight  2

#define numOfSeparateCalculations 3
double  nlm_values[3][numOfSeparateCalculations];
double  nlm_prices[ ][numOfSeparateCalculations];
double  nlm_alphas[ ][numOfSeparateCalculations];

double iNoLagMa(double price, int length, int r, int instanceNo=0)
{
   r = Bars-r-1;
   if (ArrayRange(nlm_prices,0) != Bars(Symbol(),0)) ArrayResize(nlm_prices,Bars(Symbol(),0));
                               nlm_prices[r][instanceNo]=price;
   if (length<3 || r<3) return(nlm_prices[r][instanceNo]);
   
   //
   //
   //
   //
   //
   
   if (nlm_values[_length][instanceNo] != length)
   {
      double Cycle = 4.0;
      double Coeff = 3.0*M_PI;
      int    Phase = length-1;
      
         nlm_values[_length][instanceNo] = length;
         nlm_values[_len   ][instanceNo] = length*4 + Phase;  
         nlm_values[_weight][instanceNo] = 0;

         if (ArrayRange(nlm_alphas,0) < nlm_values[_len][instanceNo]) ArrayResize(nlm_alphas,(int)nlm_values[_len][instanceNo]);
         for (int k=0; k<nlm_values[_len][instanceNo]; k++)
         {
            double t;
            if (k<=Phase-1) 
                 t = 1.0 * k/(Phase-1);
            else t = 1.0 + (k-Phase+1)*(2.0*Cycle-1.0)/(Cycle*length-1.0); 
            double beta = MathCos(M_PI*t);
            double g = 1.0/(Coeff*t+1); if (t <= 0.5 ) g = 1;
      
            nlm_alphas[k][instanceNo]        = g * beta;
            nlm_values[_weight][instanceNo] += nlm_alphas[k][instanceNo];
         }
   }
   
   //
   //
   //
   //
   //
   
   if (nlm_values[_weight][instanceNo]>0)
   {
      double sum = 0;
           for (int k=0; k < nlm_values[_len][instanceNo] && (r-k)>=0; k++) sum += nlm_alphas[k][instanceNo]*nlm_prices[r-k][instanceNo];
           return( sum / nlm_values[_weight][instanceNo]);
   }
   else return(0);           
}

//------------------------------------------------------------------
//                                                                  
//------------------------------------------------------------------
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

double iFilter(double tprice, double filter, int period, int i, int instanceNo=0)
{
   if (filter<=0 || period<=0) return(tprice);
   if (ArrayRange(workFil,0)!= Bars) ArrayResize(workFil,Bars); i = Bars-i-1; instanceNo*=3;
   
   //
   //
   //
   //
   //
   
   workFil[i][instanceNo+_fprice]  = tprice; if (i<1) return(tprice);
   workFil[i][instanceNo+_fchange] = fabs(workFil[i][instanceNo+_fprice]-workFil[i-1][instanceNo+_fprice]);
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
         double haHigh  = fmax(high[i],fmax(haOpen,haClose));
         double haLow   = fmin(low[i] ,fmin(haOpen,haClose));

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
   if (alertsOn)
   {
      int whichBar = 1; if (alertsOnCurrent) whichBar = 0;
      if (trend[whichBar] != trend[whichBar+1])
      {
         if (trend[whichBar] ==  1) doAlert(whichBar,"up");
         if (trend[whichBar] == -1) doAlert(whichBar,"down");
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

       message =  StringConcatenate(Symbol()," ",timeFrameToString(_Period)," at ",TimeToStr(TimeLocal(),TIME_SECONDS)," NonLag MA slope changed to ",doWhat);
          if (alertsMessage) Alert(message);
          if (alertsSound)   PlaySound("alert2.wav");
          if (alertsEmail)   SendMail(StringConcatenate(Symbol(),"NonLag MA"),message);
          if (alertsNotify)  SendNotification(message);
   }
}
