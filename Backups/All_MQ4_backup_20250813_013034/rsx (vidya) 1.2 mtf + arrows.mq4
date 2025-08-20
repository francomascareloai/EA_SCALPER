//+------------------------------------------------------------------+
//|                                                              rsx |
//|                                                           mladen |
//+------------------------------------------------------------------+
#property copyright "mladen"
#property link      "mladenfx@gmail.com"

#property indicator_separate_window
#property indicator_buffers    3
#property indicator_color1     clrLimeGreen
#property indicator_color2     clrOrange
#property indicator_color3     clrOrange
#property indicator_width1     2
#property indicator_width2     2
#property indicator_width3     2
#property indicator_minimum    -2
#property indicator_maximum    102
#property indicator_level1     70
#property indicator_level2     30
#property indicator_levelcolor clrDarkGray
#property indicator_levelstyle STYLE_DOT
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

extern ENUM_TIMEFRAMES TimeFrame          = PERIOD_CURRENT;  // Time frame
extern int             RsxLength          = 14;              // RSX period
extern enPrices        Price              = pr_close;        // Price to use
extern int             VidyaPeriod        = 10;              // Vidya period
extern int             VidyaSmooth        = 5;               // Vidya period
extern bool            AlertsOn           = false;           // Turn alerts on?
extern bool            AlertsOnCurrent    = true;            // Alerts on still opened bar?
extern bool            AlertsMessage      = true;            // Alerts should show popup message?
extern bool            AlertsSound        = false;           // Alerts should play a sound?
extern bool            AlertsEmail        = false;           // Alerts should send email?
extern bool            AlertsPushNotif    = false;           // Alerts should send notification?
input bool             arrowsVisible      = false;           // Arrows visible on/off?
input bool             arrowsOnNewest     = true;            // Arrows drawn on newest bar of higher time frame bar on/off?
input string           arrowsIdentifier   = "rsx Arrows1";   // Unique ID for arrows
input double           arrowsUpperGap     = 0.5;             // Upper arrow gap
input double           arrowsLowerGap     = 0.5;             // Lower arrow gap
input color            arrowsUpColor      = clrLimeGreen;    // Up arrow color
input color            arrowsDnColor      = clrOrange;       // Down arrow color
input int              arrowsUpCode       = 221;             // Up arrow code
input int              arrowsDnCode       = 222;             // Down arrow code
input int              arrowsUpSize       = 2;               // Up arrow size
input int              arrowsDnSize       = 2;               // Down arrow size
extern bool            Interpolate        = true;            // Interpolate in mtf mode

double rsx[],rsxDa[],rsxDb[],slope[],wrkBuffer[][13],count[];
string indicatorFileName;
#define _mtfCall(_buff,_ind) iCustom(NULL,TimeFrame,indicatorFileName,PERIOD_CURRENT,RsxLength,Price,VidyaPeriod,VidyaSmooth,AlertsOn,AlertsOnCurrent,AlertsMessage,AlertsSound,AlertsEmail,AlertsPushNotif,arrowsVisible,arrowsOnNewest,arrowsIdentifier,arrowsUpperGap,arrowsLowerGap,arrowsUpColor,arrowsDnColor,arrowsUpCode,arrowsDnCode,arrowsUpSize,arrowsDnSize,_buff,_ind)

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//
//
//
//
//

int OnInit()
{
   IndicatorBuffers(5);
   SetIndexBuffer(0,rsx,  INDICATOR_DATA); SetIndexStyle(0,DRAW_LINE); SetIndexLabel(0,"RSX");
   SetIndexBuffer(1,rsxDa,INDICATOR_DATA); SetIndexStyle(1,DRAW_LINE); SetIndexLabel(1,"RSX");
   SetIndexBuffer(2,rsxDb,INDICATOR_DATA); SetIndexStyle(2,DRAW_LINE); SetIndexLabel(2,"RSX");
   SetIndexBuffer(3,slope);
   SetIndexBuffer(4,count);
   
   indicatorFileName = WindowExpertName();
   TimeFrame         = fmax(TimeFrame,_Period);
   IndicatorShortName(timeFrameToString(TimeFrame)+" Rsx ("+(string)RsxLength+","+(string)VidyaPeriod+","+(string)VidyaSmooth+")");
   return(INIT_SUCCEEDED);
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
   int i,r,counted_bars=IndicatorCounted();
      if(counted_bars<0) return(-1);
      if(counted_bars>0) counted_bars--;
         int limit=fmin(Bars-counted_bars,Bars-1); count[0] = limit;
         if (TimeFrame!=_Period)
         {
            limit = (int)fmax(limit,fmin(Bars-1,_mtfCall(4,0)*TimeFrame/Period()));
            if (slope[limit]==-1) CleanPoint(limit,rsxDa,rsxDb);
            for (i=limit;i>=0;i--)
            {
               int y = iBarShift(NULL,TimeFrame,Time[i]);
               rsx[i]   = _mtfCall(0,y); 
               rsxDa[i] = rsxDb[i] = EMPTY_VALUE;
               slope[i] = _mtfCall(3,y); 
               
               //
               //
               //
               //
               //
      
               if (!Interpolate || (i>0 && y==iBarShift(NULL,TimeFrame,Time[i-1]))) continue;
               #define _interpolate(buff) buff[i+k] = buff[i]+(buff[i+n]-buff[i])*k/n
               int n,k; datetime time = iTime(NULL,TimeFrame,y);
                  for(n = 1; (i+n)<Bars && Time[i+n] >= time; n++) continue;	
                  for(k = 1; k<n && (i+n)<Bars && (i+k)<Bars; k++) _interpolate(rsx);                                
            }
            for (i=limit; i >= 0; i--) if (slope[i]==-1) PlotPoint(i,rsxDa,rsxDb,rsx);
   return(0);
   }
         
   //
   //
   //
   //
   //
   
   double Kg = (3.0)/(2.0+RsxLength);
   double Hg = 1.0-Kg;
   if (ArrayRange(wrkBuffer,0) != Bars) ArrayResize(wrkBuffer,Bars);
   if (slope[limit]==-1) CleanPoint(limit,rsxDa,rsxDb);
   for(i=limit, r=Bars-i-1; i>=0; i--, r++)
   {
      double price = getPrice(Price,Open,Close,High,Low,i,Bars);
      wrkBuffer[r][12] = iVidya(price,price,VidyaPeriod,VidyaSmooth,i,Bars);

      if (i==(Bars-1)) for (int c=0; c<12; c++) wrkBuffer[r][c] = 0;

      //
      //
      //
      //
      //
      
      double roc = (r>0) ? wrkBuffer[r][12]-wrkBuffer[r-1][12] : 0;
      double roa = fabs(roc);
      for (int k=0; k<3 && r>0; k++)
      {
         int kk = k*2;
            wrkBuffer[r][kk+0] = Kg*roc                + Hg*wrkBuffer[r-1][kk+0];
            wrkBuffer[r][kk+1] = Kg*wrkBuffer[r][kk+0] + Hg*wrkBuffer[r-1][kk+1]; roc = 1.5*wrkBuffer[r][kk+0] - 0.5 * wrkBuffer[r][kk+1];
            wrkBuffer[r][kk+6] = Kg*roa                + Hg*wrkBuffer[r-1][kk+6];
            wrkBuffer[r][kk+7] = Kg*wrkBuffer[r][kk+6] + Hg*wrkBuffer[r-1][kk+7]; roa = 1.5*wrkBuffer[r][kk+6] - 0.5 * wrkBuffer[r][kk+7];
      }
      rsx[i] = (roa != 0) ? fmax(fmin((roc/roa+1.0)*50.0,100.00),0.00) : 50; 
      rsxDa[i] = rsxDb[i] = EMPTY_VALUE;
      slope[i] = (i<Bars-1) ? (rsx[i]>rsx[i+1]) ? 1 : (rsx[i]<rsx[i+1])? -1 : slope[i+1] : 0;
         if (slope[i]==-1) PlotPoint(i,rsxDa,rsxDb,rsx);
         
         //
         //
         //
         //
         //
         
         if (arrowsVisible)
         {
            string lookFor = arrowsIdentifier+":"+(string)Time[i]; ObjectDelete(lookFor);            
            if (i<(Bars-1) && slope[i] != slope[i+1])
            {
               if (slope[i] == 1) drawArrow(i,arrowsUpColor,arrowsUpCode,arrowsUpSize,false);
               if (slope[i] ==-1) drawArrow(i,arrowsDnColor,arrowsDnCode,arrowsDnSize, true);
            }
         }  
   }
   
   //
   //
   //
   //
   //
   
   if (AlertsOn)
   {
      int whichBar = (AlertsOnCurrent) ? 0 : 1;
      if (slope[whichBar] != slope[whichBar+1])
      if (slope[whichBar] == 1)
            doAlert("up");
      else  doAlert("down");       
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

void doAlert(string doWhat)
{
   static string   previousAlert="nothing";
   static datetime previousTime=0;
   string message;
   
      if (previousAlert != doWhat || previousTime != Time[0]) {
          previousAlert  = doWhat;
          previousTime   = Time[0];

          //
          //
          //
          //
          //

          message = timeFrameToString(_Period)+" "+Symbol()+" at "+TimeToStr(TimeLocal(),TIME_SECONDS)+" RSX Vidya slope changed to "+doWhat;
             if (AlertsMessage)   Alert(message);
             if (AlertsPushNotif) SendNotification(message);
             if (AlertsEmail)     SendMail(_Symbol+" RSX Vidya",message);
             if (AlertsSound)     PlaySound("alert2.wav");
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

#define _vidyaInstances     1
#define _vidyaInstancesSize 3
double  vidya_work[][_vidyaInstances*_vidyaInstancesSize];
#define vidya_price 0
#define vidya_pricc 1
#define vidya_value 2

double iVidya(double price, double priceForCmo, int cmoPeriod, int smoothPeriod, int r, int bars, int instanceNo=0)
{
   if (ArrayRange(vidya_work,0)!=bars) ArrayResize(vidya_work,bars); r = bars-r-1; int s = instanceNo*_vidyaInstancesSize;
   
   //
   //
   //
   //
   //
   
   vidya_work[r][s+vidya_price] = price;
   vidya_work[r][s+vidya_pricc] = priceForCmo;
          double sumUp = 0, sumDo = 0;
          for (int k=0; k<cmoPeriod && (r-k-1)>=0; k++)
          {
               double diff = vidya_work[r-k][s+vidya_pricc]-vidya_work[r-k-1][s+vidya_pricc];
                  if (diff > 0)
                        sumUp += diff;
                  else  sumDo -= diff;
          }      
          vidya_work[r][s+vidya_value] = (r>0 && (sumDo+sumUp)!=0) ? vidya_work[r-1][s+vidya_value]+((((sumUp+sumDo)!=0) ? MathAbs((sumUp-sumDo)/(sumUp+sumDo)):1)*2.00/(1.00+MathMax(smoothPeriod,1)))*(vidya_work[r][s+vidya_price]-vidya_work[r-1][s+vidya_value]) : price;
   return(vidya_work[r][s+vidya_value]);
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
double  _priceWorkHa[][_priceInstances*_priceInstancesSize];
double getPrice(int tprice, const double& open[], const double& close[], const double& high[], const double& low[], int i, int bars, int instanceNo=0)
{
  if (tprice>=pr_haclose)
   {
      if (ArrayRange(_priceWorkHa,0)!= Bars) ArrayResize(_priceWorkHa,Bars); instanceNo*=_priceInstancesSize; int r = #ifdef __MQL4__ bars-i-1 #else i #endif;
         
         //
         //
         //
         //
         //
         
         double haOpen  = (r>0) ? (_priceWorkHa[r-1][instanceNo+2] + _priceWorkHa[r-1][instanceNo+3])/2.0 : (open[i]+close[i])/2;;
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
         
         if(haOpen<haClose) { _priceWorkHa[r][instanceNo+0] = haLow;  _priceWorkHa[r][instanceNo+1] = haHigh; } 
         else               { _priceWorkHa[r][instanceNo+0] = haHigh; _priceWorkHa[r][instanceNo+1] = haLow;  } 
                              _priceWorkHa[r][instanceNo+2] = haOpen;
                              _priceWorkHa[r][instanceNo+3] = haClose;
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

void drawArrow(int i,color theColor,int theCode, int theSize, bool up)
{
   string name = arrowsIdentifier+":"+(string)Time[i];
   double gap  = iATR(NULL,0,20,i);   
   
      //
      //
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

