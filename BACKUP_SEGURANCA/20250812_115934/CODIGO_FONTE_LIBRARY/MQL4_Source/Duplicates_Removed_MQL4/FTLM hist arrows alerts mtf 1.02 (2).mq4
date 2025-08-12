//+------------------------------------------------------------------+
//|                             FTLM hist + alerts + arrows mtf.mq4  |
//|                                                       by mladen  |
//+------------------------------------------------------------------+
// FTLM - Fast Trend Line Momentum
// not for sale, rent, auction, nor lease
//--------------------------------------------------------------------
#property copyright "www.forex-station.com"
#property link      "www.forex-station.com"
//--------------------------------------------------------------------

#property indicator_separate_window
#property indicator_buffers 7
#property indicator_color1  clrDarkGreen
#property indicator_color2  clrRed
#property indicator_color3  clrCrimson
#property indicator_color4  clrLime
#property indicator_color5  clrGreen
#property indicator_color6  clrRed
#property indicator_color7  clrRed
#property indicator_width1  2
#property indicator_width3  2
#property indicator_width5  2
#property indicator_width6  2
#property indicator_width7  2

//33 enPrices
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
   pr_haopen,     // Heiken ashi open
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
   pr_habopen,    // Heiken ashi (better formula) open
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

extern ENUM_TIMEFRAMES TimeFrame        = PERIOD_CURRENT;   // Time frame
extern enPrices        Price            = pr_close;         // Price to use for FTLM calculation
extern bool            arrowsVisible    = true;             // Arrows visible?
extern bool            arrowsOnFirst    = true;            // Arrows shift?
extern string          arrowsIdentifier = "FTLM arrows";   // Unique ID for arrows
extern double          arrowsUpperGap   = 1.0;              // Upper arrow gap
extern double          arrowsLowerGap   = 1.0;              // Lower arrow gap
extern color           arrowsUpColor    = clrDarkGreen;   // Up arrow color
extern color           arrowsDnColor    = clrCrimson; // Down arrow color
extern int             arrowsUpCode     = 221;              // Up arrow code
extern int             arrowsDnCode     = 222;              // Down arrow code
extern int             ArrowSize        = 1;
extern bool            alertsOn         = false;            // Turn alerts on?
extern bool            alertsOnCurrent  = false;            // Alerts on still opened bar?
extern bool            alertsMessage    = false;             // Alerts should display message?
extern bool            alertsSound      = false;            // Alerts should play a sound?
extern bool            alertsNotify     = false;            // Alerts should send a notification?
extern bool            alertsEmail      = false;            // Alerts should send an email?
extern string          soundFile        = "alert2.wav";     // Sound file
extern bool            Interpolate      = true;             // Interpolate in multi time frame mode?


double FTLMhuu[],FTLMhud[],FTLMhdd[],FTLMhdu[],FTLM[],FTLMbuffer2[],FTLMbuffer3[],prices[],FTLMslope[],FTLMcount[];
string indicatorFileName;
#define _mtfCall(_buff,_ind) iCustom(NULL,TimeFrame,indicatorFileName,PERIOD_CURRENT,Price,arrowsVisible,arrowsOnFirst,arrowsIdentifier,arrowsUpperGap,arrowsLowerGap,arrowsUpColor,arrowsDnColor,arrowsUpCode,arrowsDnCode,ArrowSize,alertsOn,alertsOnCurrent,alertsMessage,alertsSound,alertsNotify,alertsEmail,soundFile,_buff,_ind)

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
{ 
   IndicatorBuffers(10);
   SetIndexBuffer(0,FTLMhuu); SetIndexStyle(0, DRAW_HISTOGRAM);
   SetIndexBuffer(1,FTLMhud); SetIndexStyle(1, DRAW_HISTOGRAM);
   SetIndexBuffer(2,FTLMhdd); SetIndexStyle(2, DRAW_HISTOGRAM);
   SetIndexBuffer(3,FTLMhdu); SetIndexStyle(3, DRAW_HISTOGRAM);
   SetIndexBuffer(4,FTLM);
   SetIndexBuffer(5,FTLMbuffer2);
   SetIndexBuffer(6,FTLMbuffer3);
   SetIndexBuffer(7,prices); 
   SetIndexBuffer(8,FTLMslope); 
   SetIndexBuffer(9,FTLMcount);
   
   indicatorFileName = WindowExpertName();
   TimeFrame         = fmax(TimeFrame,_Period);
    
    IndicatorShortName(timeFrameToString(TimeFrame)+" FTLM");
return (0);
}
int deinit()
{
   string lookFor       = arrowsIdentifier+":";
   int    lookForLength = StringLen(lookFor);
   for (int i=ObjectsTotal()-1; i>=0; i--)
   {
      string objectName = ObjectName(i);
         if (StringSubstr(objectName,0,lookForLength) == lookFor) ObjectDelete(objectName);
   }
   return(0);
}

//+------------------------------------------------------------------+
//| FTLM                                                             |
//+------------------------------------------------------------------+
//
//

int start()
{
   int i,FTLMcounted_bars=IndicatorCounted();
      if(FTLMcounted_bars<0) return(-1);
      if(FTLMcounted_bars>0) FTLMcounted_bars--;
         int limit = fmin(Bars-FTLMcounted_bars,Bars-1); FTLMcount[0]=limit;
            if (TimeFrame!=_Period)
            {
               limit = (int)fmax(limit,fmin(Bars-1,_mtfCall(9,0)*TimeFrame/_Period));
               if (FTLMslope[limit]==-1) CleanPoint(limit,FTLMbuffer2,FTLMbuffer3);
               for (i=limit;i>=0 && !_StopFlag; i--)
               {
                  int y = iBarShift(NULL,TimeFrame,Time[i]);
                     FTLM [i]   = _mtfCall(4,y);
                     FTLMhuu[i] = EMPTY_VALUE;
                     FTLMhud[i] = EMPTY_VALUE;
                     FTLMhdd[i] = EMPTY_VALUE;
                     FTLMhdu[i] = EMPTY_VALUE;
                     FTLMbuffer2[i] = EMPTY_VALUE;
                     FTLMbuffer3[i] = EMPTY_VALUE;
                     FTLMslope[i]   = _mtfCall(8,y);
                     
                     //
                     //
                     //
                     //
                     //
                     
                      if (!Interpolate || (i>0 && y==iBarShift(NULL,TimeFrame,Time[i-1]))) continue;
                      #define _interpolate(buff) buff[i+k] = buff[i]+(buff[i+n]-buff[i])*k/n
                      int n,k; datetime time = iTime(NULL,TimeFrame,y);
                         for(n = 1; (i+n)<Bars && Time[i+n] >= time; n++) continue;	
                         for(k = 1; k<n && (i+n)<Bars && (i+k)<Bars; k++) _interpolate(FTLM);                                             
            }
            for(i=limit; i>=0; i--)
            {
               if (FTLM[i]>0)
               if (FTLMslope[i]==1)
                     FTLMhuu[i] = FTLM[i];
               else  FTLMhud[i] = FTLM[i];
               if (FTLM[i]<0)
               if (FTLMslope[i]==1)
                     FTLMhdu[i] = FTLM[i];
               else  FTLMhdd[i] = FTLM[i];
               if (FTLMslope[i]==-1) PlotPoint(i,FTLMbuffer2,FTLMbuffer3,FTLM);  
            }
   return(0);
   }

   //
   //
   //
   //
   //
   
   if (FTLMslope[limit]==-1) CleanPoint(limit,FTLMbuffer2,FTLMbuffer3);
   for (i=limit; i >= 0; i--)
   {
     if (i<Bars-1)
     {
       prices[i] = getPrice(Price,Open,Close,High,Low,i,Bars);
       double value1 =
0.4360409450*prices[i+0]
+0.3658689069*prices[i+1]
+0.2460452079*prices[i+2]
+0.1104506886*prices[i+3]
-0.0054034585*prices[i+4]
-0.0760367731*prices[i+5]
-0.0933058722*prices[i+6]
-0.0670110374*prices[i+7]
-0.0190795053*prices[i+8]
+0.0259609206*prices[i+9]
+0.0502044896*prices[i+10]
+0.0477818607*prices[i+11]
+0.0249252327*prices[i+12]
-0.0047706151*prices[i+13]
-0.0272432537*prices[i+14]
-0.0338917071*prices[i+15]
-0.0244141482*prices[i+16]
-0.0055774838*prices[i+17]
+0.0128149838*prices[i+18]
+0.0226522218*prices[i+19]
+0.0208778257*prices[i+20]
+0.0100299086*prices[i+21]
-0.0036771622*prices[i+22]
-0.0136744850*prices[i+23]
-0.0160483392*prices[i+24]
-0.0108597376*prices[i+25]
-0.0016060704*prices[i+26]
+0.0069480557*prices[i+27]
+0.0110573605*prices[i+28]
+0.0095711419*prices[i+29]
+0.0040444064*prices[i+30]
-0.0023824623*prices[i+31]
-0.0067093714*prices[i+32]
-0.0072003400*prices[i+33]
-0.0047717710*prices[i+34]
+0.0005541115*prices[i+35]
+0.0007860160*prices[i+36]
+0.0130129076*prices[i+37]
+0.0040364019*prices[i+38];
       
       double value2 =
-0.0025097319*prices[i+0]
+0.0513007762*prices[i+1]
+0.1142800493*prices[i+2]
+0.1699342860*prices[i+3]
+0.2025269304*prices[i+4]
+0.2025269304*prices[i+5]
+0.1699342860*prices[i+6]
+0.1142800493*prices[i+7]
+0.0513007762*prices[i+8]
-0.0025097319*prices[i+9]
-0.0353166244*prices[i+10]
-0.0433375629*prices[i+11]
-0.0311244617*prices[i+12]
-0.0088618137*prices[i+13]
+0.0120580088*prices[i+14]
+0.0233183633*prices[i+15]
+0.0221931304*prices[i+16]
+0.0115769653*prices[i+17]
-0.0022157966*prices[i+18]
-0.0126536111*prices[i+19]
-0.0157416029*prices[i+20]
-0.0113395830*prices[i+21]
-0.0025905610*prices[i+22]
+0.0059521459*prices[i+23]
+0.0105212252*prices[i+24]
+0.0096970755*prices[i+25]
+0.0046585685*prices[i+26]
-0.0017079230*prices[i+27]
-0.0063513565*prices[i+28]
-0.0074539350*prices[i+29]
-0.0050439973*prices[i+30]
-0.0007459678*prices[i+31]
+0.0032271474*prices[i+32]
+0.0051357867*prices[i+33]
+0.0044454862*prices[i+34]
+0.0018784961*prices[i+35]
-0.0011065767*prices[i+36]
-0.0031162862*prices[i+37]
-0.0033443253*prices[i+38]
-0.0022163335*prices[i+39]
+0.0002573669*prices[i+40]
+0.0003650790*prices[i+41]
+0.0060440751*prices[i+42]
+0.0018747783*prices[i+43];
       
       FTLM[i] = value1-value2;
       FTLMhuu[i] = EMPTY_VALUE;
       FTLMhud[i] = EMPTY_VALUE;
       FTLMhdd[i] = EMPTY_VALUE;
       FTLMhdu[i] = EMPTY_VALUE;
       FTLMbuffer2[i] = EMPTY_VALUE;
       FTLMbuffer3[i] = EMPTY_VALUE;
       FTLMslope[i] = (i<Bars-1) ? (FTLM[i]>FTLM[i+1]) ? 1 : (FTLM[i]<FTLM[i+1]) ? -1 : FTLMslope[i+1] : 0;            
       if (FTLM[i]>0)
       if (FTLMslope[i]==1)
             FTLMhuu[i] = FTLM[i];
       else  FTLMhud[i] = FTLM[i];
       if (FTLM[i]<0)
       if (FTLMslope[i]==1)
             FTLMhdu[i] = FTLM[i];
       else  FTLMhdd[i] = FTLM[i];
       if (FTLMslope[i]==-1) PlotPoint(i,FTLMbuffer2,FTLMbuffer3,FTLM);
        
       //
       //
       //
       //
       //
       
       if (arrowsVisible)
       {
          string lookFor = arrowsIdentifier+":"+(string)Time[i]; ObjectDelete(lookFor);            
             if (i<Bars-1 && FTLMslope[i] != FTLMslope[i+1])
             {
                if (FTLMslope[i] == 1) drawArrow(i,arrowsUpColor,arrowsUpCode,false);
                if (FTLMslope[i] ==-1) drawArrow(i,arrowsDnColor,arrowsDnCode, true);
             }
        }
     }
   }
   if (alertsOn)
   {
      int whichBar = 1; if (alertsOnCurrent) whichBar = 0; 
      if (FTLMslope[whichBar] != FTLMslope[whichBar+1])
      {
         if (FTLMslope[whichBar] == 1) doAlert(" sloping up");
         if (FTLMslope[whichBar] ==-1) doAlert(" sloping down");       
      }         
   }   
return(0);
}
//------------------------------------------------------------------
#define _prHABF(_prtype) (_prtype>=pr_habclose && _prtype<=pr_habtbiased2)
#define _priceInstances     1
#define _priceInstancesSize 4
double workHa[][_priceInstances*_priceInstancesSize];
double getPrice(int tprice, const double& open[], const double& close[], const double& high[], const double& low[], int i, int bars, int instanceNo=0)
{
  if (tprice>=pr_haclose)
   {
      if (ArrayRange(workHa,0)!= Bars) ArrayResize(workHa,Bars); instanceNo*=_priceInstancesSize; int r = bars-i-1;
         
         double haOpen  = (r>0) ? (workHa[r-1][instanceNo+2] + workHa[r-1][instanceNo+3])/2.0 : (open[i]+close[i])/2;;
         double haClose = (open[i]+high[i]+low[i]+close[i]) / 4.0;
         if (_prHABF(tprice))
               if (high[i]!=low[i])
                     haClose = (open[i]+close[i])/2.0+(((close[i]-open[i])/(high[i]-low[i]))*MathAbs((close[i]-open[i])/2.0));
               else  haClose = (open[i]+close[i])/2.0; 
         double haHigh  = fmax(high[i], fmax(haOpen,haClose));
         double haLow   = fmin(low[i] , fmin(haOpen,haClose));
         
         if(haOpen<haClose) { workHa[r][instanceNo+0] = haLow;  workHa[r][instanceNo+1] = haHigh; } 
         else               { workHa[r][instanceNo+0] = haHigh; workHa[r][instanceNo+1] = haLow;  } 
                              workHa[r][instanceNo+2] = haOpen;
                              workHa[r][instanceNo+3] = haClose;
         
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
            { first[i]  = from[i]; first[i+1]  = from[i+1]; second[i] = EMPTY_VALUE; }
      else  { second[i] = from[i]; second[i+1] = from[i+1]; first[i]  = EMPTY_VALUE; }
   else     { first[i]  = from[i];                          second[i] = EMPTY_VALUE; }
}
//------------------------------------------------------------------
void doAlert(string doWhat)
{
   static string   previousAlert="nothing";
   static datetime previousTime;
   string message;
   
      if (previousAlert != doWhat || previousTime != Time[0]) {
          previousAlert  = doWhat;
          previousTime   = Time[0];

          message =  StringConcatenate(Symbol()," ",timeFrameToString(_Period)," at ",TimeToStr(TimeLocal(),TIME_SECONDS)," FTLM ",doWhat);
             if (alertsMessage) Alert(message);
             if (alertsNotify)  SendNotification(message);
             if (alertsEmail)   SendMail(_Symbol+" FTLM ",message);
             if (alertsSound)   PlaySound(soundFile);
      }
}
//-------------------------------------------------------------------
void drawArrow(int i,color theColor,int theCode,bool up)
{
   string name = arrowsIdentifier+":"+(string)Time[i];
   double gap  = iATR(NULL,0,20,i);   

      int add = 0; if (!arrowsOnFirst) add = _Period*60-1;
      ObjectCreate(name,OBJ_ARROW,0,Time[i]+add,0);
         ObjectSet(name,OBJPROP_ARROWCODE,theCode);
         ObjectSet(name,OBJPROP_COLOR,theColor);
         ObjectSet(name,OBJPROP_WIDTH,ArrowSize);
         if (up)
               ObjectSet(name,OBJPROP_PRICE1,High[i] + arrowsUpperGap * gap);
         else  ObjectSet(name,OBJPROP_PRICE1,Low[i]  - arrowsLowerGap * gap);
}
//-------------------------------------------------------------------
string sTfTable[] = {"M1","M5","M15","M30","H1","H4","D1","W1","MN"};
int    iTfTable[] = {1,5,15,30,60,240,1440,10080,43200};

string timeFrameToString(int tf)
{
   for (int i=ArraySize(iTfTable)-1; i>=0; i--) 
         if (tf==iTfTable[i]) return(sTfTable[i]);
                              return("");
}
//-------------------------------------------------------------------


  
