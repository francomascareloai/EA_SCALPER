//------------------------------------------------------------------
#property copyright "mladen"
#property link      "www.forex-station.com"
//------------------------------------------------------------------
#property indicator_separate_window
#property indicator_buffers 3
#property indicator_color1  clrDodgerBlue
#property indicator_color2  clrSandyBrown
#property indicator_color3  clrSandyBrown
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
enum enRsiMaMethod
{
   rsm_original=-1, // Original RSI calculation
   rsm_sma,         // Calculate RSI using SMA
   rsm_ema,         // Calculate RSI using EMA
   rsm_smma,        // Calculate RSI using SMMA
   rsm_lwma         // Calculate RSI using LWMA
};

extern ENUM_TIMEFRAMES TimeFrame        = PERIOD_CURRENT;    // Time frame to use
extern int             pperiod          = 14;                // Calculating period
extern enPrices        pprice           = pr_close;          // Price
extern enRsiMaMethod   MaMethodToUse    = rsm_lwma;          // What ma method to use in rsi calculation
extern int             psmooth          = 32;                // Price smoothing
extern ENUM_MA_METHOD  psmoothMethod    = MODE_SMMA;         // Price smoothing method
extern int             linesWidth       =  3;                // Lines width
input bool             alertsOn         = true;              // Alerts on true/false?
input bool             alertsOnCurrent  = false;             // Alerts open bar true/false?
input bool             alertsMessage    = true;              // Alerts message true/false?
input bool             alertsSound      = true;              // Alerts sound true/false?
input bool             alertsNotify     = false;             // Alerts notification true/false?
input bool             alertsEmail      = false;             // Alerts email true/false?
input string           soundfile        = "alert2.wav";      // Sound file to use
input bool             arrowsVisible    = false;             // Arrows visible true/false?
input bool             arrowsOnNewest   = false;             // Arrows drawn on newest bar of higher time frame bar true/false?
input string           arrowsIdentifier = "rsi Arrows1";     // Unique ID for arrows
input double           arrowsUpperGap   = 0.5;               // Upper arrow gap
input double           arrowsLowerGap   = 0.5;               // Lower arrow gap
input color            arrowsUpColor    = clrBlue;           // Up arrow color
input color            arrowsDnColor    = clrCrimson;        // Down arrow color
input int              arrowsUpCode     = 116;               // Up arrow code
input int              arrowsDnCode     = 116;               // Down arrow code
input int              arrowsUpSize     = 2;                 // Up arrow size
input int              arrowsDnSize     = 2;                 // Down arrow size
extern bool            Interpolate      = true;              // Interpolate in multi time frame mode?


double buffer[];
double bufferda[];
double bufferdb[];
double trend[];
double prices[];
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
   IndicatorBuffers(5);
   SetIndexBuffer(0,buffer,  INDICATOR_DATA); SetIndexStyle(0,EMPTY,EMPTY,linesWidth);
   SetIndexBuffer(1,bufferda,INDICATOR_DATA); SetIndexStyle(1,EMPTY,EMPTY,linesWidth);
   SetIndexBuffer(2,bufferdb,INDICATOR_DATA); SetIndexStyle(2,EMPTY,EMPTY,linesWidth);
   SetIndexBuffer(3,trend   ,INDICATOR_CALCULATIONS);
   SetIndexBuffer(4,prices  ,INDICATOR_CALCULATIONS);
            indicatorFileName = WindowExpertName();
            returnBars        = TimeFrame==-99;
            TimeFrame         = MathMax(TimeFrame,_Period);
   IndicatorShortName(timeFrameToString(TimeFrame)+" rsi experiment ("+(string)pperiod+","+(string)psmooth+")");
   return(0);
}
void OnDeinit(const int reason)
{ 
    string lookFor       = arrowsIdentifier+":";
    int    lookForLength = StringLen(lookFor);
    for (int i=ObjectsTotal()-1; i>=0; i--)
    {
       string objectName = ObjectName(i);
       if (StringSubstr(objectName,0,lookForLength) == lookFor) ObjectDelete(objectName);
    }
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
                  buffer[i]   = iCustom(NULL,TimeFrame,indicatorFileName,PERIOD_CURRENT,pperiod,pprice,MaMethodToUse,psmooth,psmoothMethod,alertsOn,alertsOnCurrent,alertsMessage,alertsSound,alertsNotify,alertsEmail,soundfile,arrowsVisible,arrowsOnNewest,arrowsIdentifier,arrowsUpperGap,arrowsLowerGap,arrowsUpColor,arrowsDnColor,arrowsUpCode,arrowsDnCode,arrowsUpSize,arrowsDnSize,0,y);
                  trend[i]    = iCustom(NULL,TimeFrame,indicatorFileName,PERIOD_CURRENT,pperiod,pprice,MaMethodToUse,psmooth,psmoothMethod,alertsOn,alertsOnCurrent,alertsMessage,alertsSound,alertsNotify,alertsEmail,soundfile,arrowsVisible,arrowsOnNewest,arrowsIdentifier,arrowsUpperGap,arrowsLowerGap,arrowsUpColor,arrowsDnColor,arrowsUpCode,arrowsDnCode,arrowsUpSize,arrowsDnSize,3,y);
                  bufferda[i] = bufferdb[i] = EMPTY_VALUE;
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
   for(int i=limit; i>=0; i--) prices[i] = getPrice(pprice,Open,Close,High,Low,i,Bars);
   for(int i=limit; i>=0; i--)
   {
      buffer[i]   = iRsi(MaMethodToUse,iMAOnArray(prices,0,psmooth,0,psmoothMethod,i),pperiod,i);
      bufferda[i] = bufferdb[i] = EMPTY_VALUE;
      trend[i] = (i<Bars-1) ? (buffer[i]>buffer[i+1]) ? 1 : (buffer[i]<buffer[i+1]) ? -1 : trend[i+1]  : 0; 
         if (trend[i] == -1) PlotPoint(i,bufferda,bufferdb,buffer);
         
         //
         //
         //
      
         if (arrowsVisible)
         {
           string lookFor = arrowsIdentifier+":"+(string)Time[i]; ObjectDelete(lookFor);            
           if (i<(Bars-1) && trend[i] != trend[i+1])
           {
              if (trend[i] == 1) drawArrow(i,arrowsUpColor,arrowsUpCode,arrowsUpSize,false);
              if (trend[i] ==-1) drawArrow(i,arrowsDnColor,arrowsDnCode,arrowsDnSize, true);
           }
         }    
   } 
    manageAlerts();    
   return(0);
}

//------------------------------------------------------------------
//
//------------------------------------------------------------------

double workRsi[][3];
#define _price  0
#define _change 1
#define _changa 2

double iRsi(int maMethod, double price, double period, int i, int instanceNo=0)
{
   if (ArrayRange(workRsi,0)!=Bars) ArrayResize(workRsi,Bars);
      int z = instanceNo*3; 
      int r = Bars-i-1;
   
   //
   //
   //
   //
   //
   
   workRsi[r][z+_price] = price;
         if (r<period)
            {
               int k; double sum = 0; for (k=0; k<period && (r-k-1)>=0; k++) sum += MathAbs(workRsi[r-k][z+_price]-workRsi[r-k-1][z+_price]);
                  workRsi[r][z+_change] = (workRsi[r][z+_price]-workRsi[0][z+_price])/MathMax(k,1);
                  workRsi[r][z+_changa] =                                         sum/MathMax(k,1);
            }
         else
            {
               double alpha = 1.0/period; 
               double change = workRsi[r][z+_price]-workRsi[r-1][z+_price];
               switch (maMethod)
               {
                  case rsm_original :
                               workRsi[r][z+_change] = workRsi[r-1][z+_change] + alpha*(        change  - workRsi[r-1][z+_change]);
                               workRsi[r][z+_changa] = workRsi[r-1][z+_changa] + alpha*(MathAbs(change) - workRsi[r-1][z+_changa]);
                               break;
                  case rsm_sma :                    
                               workRsi[r][z+_change] = iSma(        change ,(int)period,r,0);
                               workRsi[r][z+_changa] = iSma(MathAbs(change),(int)period,r,1);
                               break;
                  case rsm_ema :                    
                               workRsi[r][z+_change] = iEma(        change ,period,r,0);
                               workRsi[r][z+_changa] = iEma(MathAbs(change),period,r,1);
                               break;
                  case rsm_smma :                    
                               workRsi[r][z+_change] = iSmma(        change ,period,r,0);
                               workRsi[r][z+_changa] = iSmma(MathAbs(change),period,r,1);
                               break;
                  case rsm_lwma :                    
                               workRsi[r][z+_change] = iLwma(        change ,period,r,0);
                               workRsi[r][z+_changa] = iLwma(MathAbs(change),period,r,1);
                               break;
               }                               
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

#define _maInstances 2
#define _maWorkBufferx1 1*_maInstances
#define _maWorkBufferx2 2*_maInstances
#define _maWorkBufferx3 3*_maInstances
#define _maWorkBufferx4 4*_maInstances
#define _maWorkBufferx5 5*_maInstances

double workSma[][_maWorkBufferx2];
double iSma(double price, int period, int r, int instanceNo=0)
{
   if (period<=1) return(price);
   if (ArrayRange(workSma,0)!= Bars) ArrayResize(workSma,Bars); instanceNo *= 2; int k;

   //
   //
   //
   //
   //
      
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
double iEma(double price, double period, int r, int instanceNo=0)
{
   if (period<=1) return(price);
   if (ArrayRange(workEma,0)!= Bars) ArrayResize(workEma,Bars);

   //
   //
   //
   //
   //
      
   workEma[r][instanceNo] = price;
   double alpha = 2.0 / (1.0+period);
   if (r>0)
          workEma[r][instanceNo] = workEma[r-1][instanceNo]+alpha*(price-workEma[r-1][instanceNo]);
   return(workEma[r][instanceNo]);
}

//
//
//
//
//

double workSmma[][_maWorkBufferx1];
double iSmma(double price, double period, int r, int instanceNo=0)
{
   if (period<=1) return(price);
   if (ArrayRange(workSmma,0)!= Bars) ArrayResize(workSmma,Bars);

   //
   //
   //
   //
   //

   if (r<period)
         workSmma[r][instanceNo] = price;
   else  workSmma[r][instanceNo] = workSmma[r-1][instanceNo]+(price-workSmma[r-1][instanceNo])/period;
   return(workSmma[r][instanceNo]);
}

//
//
//
//
//

double workLwma[][_maWorkBufferx1];
double iLwma(double price, double period, int r, int instanceNo=0)
{
   if (period<=1) return(price);
   if (ArrayRange(workLwma,0)!= Bars) ArrayResize(workLwma,Bars);
   
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

void manageAlerts()
{
   if (alertsOn)
   {
      int whichBar = 1; if (alertsOnCurrent) whichBar = 0; 
      if (trend[whichBar]!= trend[whichBar+1])
      {
         static datetime time1 = 0;
         static string   mess1 = "";
            if (trend[whichBar] == 1) doAlert(time1,mess1," up");
            if (trend[whichBar] ==-1) doAlert(time1,mess1," down");
      }
   }
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

       message = timeFrameToString(_Period)+" "+_Symbol+" at "+TimeToStr(TimeLocal(),TIME_SECONDS)+" rsi experiment "+doWhat;
          if (alertsMessage) Alert(message);
          if (alertsNotify)  SendNotification(message);
          if (alertsEmail)   SendMail(_Symbol+" rsi experiment ",message);
          if (alertsSound)   PlaySound(soundfile);
   }
}

//-------------------------------------------------------------------
//                                                                  
//-------------------------------------------------------------------

void drawArrow(int i,color theColor,int theCode, int theSize, bool up)
{
   string name = arrowsIdentifier+":"+(string)Time[i];
   double gap  = iATR(NULL,0,20,i);   
   
      //
      //
      //

      datetime atime = Time[i]; if (arrowsOnNewest) atime += _Period*60-1;      
      ObjectCreate(name,OBJ_ARROW,0,atime,0);
         ObjectSet(name,OBJPROP_ARROWCODE,theCode);
         ObjectSet(name,OBJPROP_COLOR,theColor);
         ObjectSet(name,OBJPROP_WIDTH,theSize);
         if (up)
               ObjectSet(name,OBJPROP_PRICE1,High[i] + arrowsUpperGap * gap);
         else  ObjectSet(name,OBJPROP_PRICE1,Low[i]  - arrowsLowerGap * gap);
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