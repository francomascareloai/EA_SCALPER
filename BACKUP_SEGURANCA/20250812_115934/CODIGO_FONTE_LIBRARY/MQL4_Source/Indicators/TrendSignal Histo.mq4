#property copyright "www,forex-station.com"
#property link      "www,forex-station.com"

#property indicator_separate_window
#property indicator_buffers 2
#property indicator_minimum 0
#property indicator_maximum 1
//#property strict

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

extern ENUM_TIMEFRAMES TimeFrame        = PERIOD_CURRENT;  // Time frame to use
extern double           x1              = 67;              // x1
extern double           x2              = 33;              // x2
extern enPrices         WprPrice        = pr_close;        // Price
extern int              Risk            = 3;               // Risk
extern bool             alertsOn        = false;           // Turn alerts on?
extern bool             alertsOnCurrent = false;           // Alerts on still opened bar?
extern bool             alertsMessage   = true;            // Alerts should display message?
extern bool             alertsSound     = false;           // Alerts should play a sound?
extern bool             alertsNotify    = false;           // Alerts should send a notification?
extern bool             alertsEmail     = false;           // Alerts should send an email?
extern int              HistoWidth      = 3;               // Histogram barswidth
extern color            UpHistoColor    = clrLimeGreen;    // Atr up histogram color
extern color            DnHistoColor    = clrRed;          // Atr down histogram color

double hUp[],hDn[],wpr[],price[],trend[],count[];
string indicatorFileName;
#define _mtfCall(_buff,_y) iCustom(NULL,TimeFrame,indicatorFileName,PERIOD_CURRENT,x1,x2,WprPrice,Risk,alertsOn,alertsOnCurrent,alertsMessage,alertsSound,alertsNotify,alertsEmail,HistoWidth,UpHistoColor,DnHistoColor,_buff,_y)

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
   IndicatorBuffers(6);
   SetIndexBuffer(0,hUp); SetIndexStyle(0, DRAW_HISTOGRAM,EMPTY,HistoWidth,UpHistoColor);
   SetIndexBuffer(1,hDn); SetIndexStyle(1, DRAW_HISTOGRAM,EMPTY,HistoWidth,DnHistoColor);   
   SetIndexBuffer(2,wpr);
   SetIndexBuffer(3,price);
   SetIndexBuffer(4,trend);
   SetIndexBuffer(5,count);
    
    indicatorFileName = WindowExpertName();
    TimeFrame         = MathMax(TimeFrame,_Period);  
    
    IndicatorShortName(timeFrameToString(TimeFrame)+" TrendSignal");
return(0);
}  
void OnDeinit(const int reason) { }

//
//
//
//
//

int start()
{
   int i,k,counted_bars=IndicatorCounted();
      if(counted_bars<0) return(-1);
      if(counted_bars>0) counted_bars--;
            int limit = fmin(Bars-counted_bars,Bars-1); count[0] = limit;
            if (TimeFrame != _Period)
            {
               limit = (int)fmax(limit,fmin(Bars-1,_mtfCall(5,0)*TimeFrame/Period()));
               for (i=limit; i>=0; i--)
               {
                  int y = iBarShift(NULL,TimeFrame,Time[i]);
                     hUp[i] = _mtfCall(0,y);
                     hDn[i] = _mtfCall(1,y);
               }
   return(0);
   }
   
   //
   //
   //
   //
   //

   for (i=limit; i>=0 ; i--)
   {
      int    period = 3 + Risk * 2;
      double range  = 0; for (k = 0; k < 10; k++) range += High[i+k] - Low[i+k]; range /= 10.0;
      bool   found1 = false; for (k = 0; k < 6 && !found1 && (i+k)<Bars; k++) found1 = (fabs(Open[i+k]    - Close[i+k+1])>= range * 2.0);
      bool   found2 = false; for (k = 0; k < 9 && !found2 && (i+k)<Bars; k++) found2 = (fabs(Close[i+k+3] - Close[i+k])  >= range * 4.6);
             if (found1) period = 3;
             if (found2) period = 4;
             price[i]  = getPrice(WprPrice,Open,Close,High,Low,i,Bars);
             double hi  = High[iHighest(NULL,0,MODE_HIGH,period,i)];
             double lo  =  Low[iLowest(NULL, 0,MODE_LOW, period,i)];
             wpr[i] = (hi!=lo) ? 100+(-100)*(hi-price[i])/(hi-lo) : 0.00;
      //
      //
      //
      //
      //
               
      hDn[i] = EMPTY_VALUE;
      hUp[i] = EMPTY_VALUE;
      if (i<Bars-1)
      {
         trend[i] = trend[i+1];
         if (wpr[i]<x2-Risk) { for (k=1; (i+k)<Bars && wpr[i+k]>=x2-Risk && wpr[i+k]<=x1+Risk;) k++; if (wpr[i+k]>x1+Risk) trend[i] =-1; }
         if (wpr[i]>x1+Risk) { for (k=1; (i+k)<Bars && wpr[i+k]>=x2-Risk && wpr[i+k]<=x1+Risk;) k++; if (wpr[i+k]<x2-Risk) trend[i] = 1; }
         if (trend[i] == 1) hUp[i] = 1;
         if (trend[i] ==-1) hDn[i] = 1;
      }
   }
manageAlerts();   
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
         if (trend[whichBar]== 1) doAlert(whichBar," up ");
         if (trend[whichBar]==-1) doAlert(whichBar," down ");
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

       message = timeFrameToString(_Period)+" "+Symbol()+" at "+TimeToStr(TimeLocal(),TIME_SECONDS)+" TrendSignal "+doWhat;
          if (alertsMessage)  Alert(message);
          if (alertsEmail)    SendMail(StringConcatenate(Symbol()," TrendSignal "),message);
          if (alertsNotify)   SendNotification(message);
          if (alertsSound)    PlaySound("alert2.wav");
   }
}

