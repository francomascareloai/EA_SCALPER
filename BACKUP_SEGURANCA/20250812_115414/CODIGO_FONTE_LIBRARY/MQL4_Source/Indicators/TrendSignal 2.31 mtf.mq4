//------------------------------------------------------------------
//
//------------------------------------------------------------------
#property copyright "www.forex-station.com"
#property link      "www.forex-station.com"

#property indicator_chart_window
#property indicator_buffers 2
#property indicator_color1 DarkOrange
#property indicator_color2 LightBlue
#property indicator_width1 1
#property indicator_width2 1

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

extern ENUM_TIMEFRAMES TimeFrame = PERIOD_CURRENT;
extern double x1                 = 67;
extern double x2                 = 33;
extern enPrices WprPrice         = pr_close;      // Price
extern int    Risk               = 3;
extern double ArrowsGap          = 1.0;
extern bool   ArrowOnFirst       = true;         // Arrow on first bars

extern bool   alertsOn           = false;
extern bool   alertsOnCurrent    = true;
extern bool   alertsMessage      = true;
extern bool   alertsSound        = false;
extern bool   alertsEmail        = false;
extern bool   alertsNotify       = false;
//
//
//
//
//

double arrDn[];
double arrUp[];
double wpr[];
double price[];
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
   IndicatorBuffers(4);
   SetIndexBuffer(0,arrDn); SetIndexStyle(0,DRAW_ARROW); SetIndexArrow(0,234);
   SetIndexBuffer(1,arrUp); SetIndexStyle(1,DRAW_ARROW); SetIndexArrow(1,233);
   SetIndexBuffer(2,wpr);
   SetIndexBuffer(3,price);
      indicatorFileName = WindowExpertName();
      returnBars        = TimeFrame == -99;
      TimeFrame         = MathMax(TimeFrame,_Period);
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
      if (counted_bars<0) return(-1);
      if(counted_bars>0) counted_bars--;
         int limit = MathMin(Bars-counted_bars,Bars-1);
         if (returnBars) { arrDn[0] = limit+1; return(0); }
         if (TimeFrame!=Period())
         {
            limit = (int)MathMax(limit,MathMin(Bars-1,iCustom(NULL,TimeFrame,indicatorFileName,-99,0,0)*TimeFrame/Period()));
            for (i=limit; i>=0; i--)
            {
               int y = iBarShift(NULL,TimeFrame,Time[i]);
               int x = y;
               if (ArrowOnFirst)
                     {  if (i<Bars-1) x = iBarShift(NULL,TimeFrame,Time[i+1]);               }
               else  {  if (i>0)      x = iBarShift(NULL,TimeFrame,Time[i-1]); else x = -1;  }
               arrDn[i] = EMPTY_VALUE;
               arrUp[i] = EMPTY_VALUE;
               if (y!=x)
               {
                  arrDn[i] = iCustom(NULL,TimeFrame,indicatorFileName,PERIOD_CURRENT,x1,x2,WprPrice,Risk,ArrowsGap,alertsOn,alertsOnCurrent,alertsMessage,alertsSound,alertsEmail,alertsNotify,0,y);
                  arrUp[i] = iCustom(NULL,TimeFrame,indicatorFileName,PERIOD_CURRENT,x1,x2,WprPrice,Risk,ArrowsGap,alertsOn,alertsOnCurrent,alertsMessage,alertsSound,alertsEmail,alertsNotify,1,y);
               }    
            }
            return(0);                  
         }
         
         //
         //
         //
         //
         //

   //
   //
   //
   //
   //

   for (i=limit; i>=0 ; i--)
   {
      int    period = 3 + Risk * 2;
      double range  = 0; for (int k = 0; k < 10; k++) range += High[i+k] - Low[i+k]; range /= 10.0;
      bool   found1 = false; for (k = 0; k < 6 && !found1; k++) found1 = (MathAbs(Open[i+k]    - Close[i+k+1])>= range * 2.0);
      bool   found2 = false; for (k = 0; k < 9 && !found2; k++) found2 = (MathAbs(Close[i+k+3] - Close[i+k])  >= range * 4.6);
             if (found1) period = 3;
             if (found2) period = 4;
             price[i]  = getPrice(WprPrice,Open,Close,High,Low,i,Bars);
             double hi   = High[iHighest(NULL,0, MODE_HIGH,period,i)];
             double lo   =  Low[iLowest(NULL, 0, MODE_LOW, period,i)];
             if (hi!=lo)      
                  wpr[i] = 100+(-100)*(hi - price[i]) / (hi - lo);
             else wpr[i] = 0;   

      //
      //
      //
      //
      //
               
      arrDn[i] = EMPTY_VALUE;
      arrUp[i] = EMPTY_VALUE;
      if (wpr[i]<x2-Risk) { for (k=1; i+k<Bars && wpr[i+k]>=x2-Risk && wpr[i+k]<=x1+Risk;) k++; if (wpr[i+k]>x1+Risk) arrDn[i] = High[i]+range*ArrowsGap; }
      if (wpr[i]>x1+Risk) { for (k=1; i+k<Bars && wpr[i+k]>=x2-Risk && wpr[i+k]<=x1+Risk;) k++; if (wpr[i+k]<x2-Risk) arrUp[i] = Low[i] -range*ArrowsGap; }
   }
manageAlerts();   
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
   if (alertsOn)
   {
      //if (alertsOnCurrent)
      //     int whichBar = 0;
      //else     whichBar = 1;
      int whichBar = 1; if (alertsOnCurrent) whichBar = 0;
      if (arrDn[whichBar] != EMPTY_VALUE || arrUp[whichBar] != EMPTY_VALUE)
      {
         if (arrUp[whichBar] != EMPTY_VALUE) doAlert(whichBar,"up");
         if (arrDn[whichBar] != EMPTY_VALUE) doAlert(whichBar,"down");
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

       message =  StringConcatenate(Symbol()," at ",TimeToStr(TimeLocal(),TIME_SECONDS)," Trend signal trend changed to ",doWhat);
          if (alertsMessage) Alert(message);
          if (alertsNotify)  SendNotification(message);
          if (alertsEmail)   SendMail(StringConcatenate(Symbol()," Trend Signal"),message);
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
