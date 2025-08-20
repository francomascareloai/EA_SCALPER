//+------------------------------------------------------------------+
//|                                                   STLM_hist.mq4  |
//|                                                                  |
//+------------------------------------------------------------------+
//STLM - Slow Trend Line Momentum
// not for sale, rent, auction, nor lease
//------------------------------------------------------------------
#property copyright "www.forex-station.com"
#property link      "www.forex-station.com"
//------------------------------------------------------------------

#property indicator_separate_window
#property indicator_buffers 7
#property indicator_color1  clrDarkGreen
#property indicator_color2  clrLime
#property indicator_color3  clrCrimson
#property indicator_color4  clrRed
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

//AHTF Timeframe template copy and paste start11
enum enTimeFrames
{
   tf_cu  = PERIOD_CURRENT, // Current time frame
   tf_m1  = PERIOD_M1,      // 1 minute
   tf_m5  = PERIOD_M5,      // 5 minutes
   tf_m15 = PERIOD_M15,     // 15 minutes
   tf_m30 = PERIOD_M30,     // 30 minutes
   tf_h1  = PERIOD_H1,      // 1 hour
   tf_h4  = PERIOD_H4,      // 4 hours
   tf_d1  = PERIOD_D1,      // Daily
   tf_w1  = PERIOD_W1,      // Weekly
   tf_mn1 = PERIOD_MN1,     // Monthly
   tf_n1  = -1,             // First higher time frame
   tf_n2  = -2,             // Second higher time frame
   tf_n3  = -3              // Third higher time frame
};
//AHTF Timeframe template copy and paste end11

//AHTF Timeframe template copy and paste start12
extern enTimeFrames      TimeFrame             = tf_cu;   // Time frame
//AHTF Timeframe template copy and paste end12

extern enPrices        Price            = pr_close;         // Price to use for stlm calculation
extern bool            ShowZones        = true;             // Display the background zones
extern color           ColorUp          = clrHoneydew;      // Uptrend Zone color
extern color           ColorDown        = clrLavenderBlush; // Downtrend Zone color
extern string          UniqueZoneID     = "STLMZones2";      // Unique ID for the zones
extern bool            arrowsVisible    = true;             // Arrows visible?
extern bool            arrowsOnFirst    = true;            // Arrows shift?
extern string          arrowsIdentifier = "STLM Arrows";   // Unique ID for arrows
extern double          arrowsUpperGap   = 1.0;              // Upper arrow gap
extern double          arrowsLowerGap   = 1.0;              // Lower arrow gap
extern color           arrowsUpColor    = clrDarkGreen;   // Up arrow color
extern color           arrowsDnColor    = clrCrimson; // Down arrow color
extern int             arrowsUpCode     = 233;              // Up arrow code
extern int             arrowsDnCode     = 234;              // Down arrow code
extern int             ArrowSize        = 1;
extern bool            alertsOn         = false;            // Turn alerts on?
extern bool            alertsOnCurrent  = false;            // Alerts on still opened bar?
extern bool            alertsMessage    = false;             // Alerts should display message?
extern bool            alertsSound      = false;            // Alerts should play a sound?
extern bool            alertsNotify     = false;            // Alerts should send a notification?
extern bool            alertsEmail      = false;            // Alerts should send an email?
extern string          soundFile        = "alert2.wav";     // Sound file
extern bool            Interpolate      = true;             // Interpolate in multi time frame mode?

//Forex-Station Zone template copy and paste start 1
double Dummy = -1;
//Forex-Station Zone template copy and paste end 1

double stlmhuu[],stlmhud[],stlmhdd[],stlmhdu[],stlm[],buffer2[],buffer3[],prices[],trend[],count[];
string indicatorFileName;
#define _mtfCall(_buff,_ind) iCustom(NULL,TimeFrame,indicatorFileName,PERIOD_CURRENT,Price,ShowZones,ColorUp,ColorDown,UniqueZoneID,arrowsVisible,arrowsOnFirst,arrowsIdentifier,arrowsUpperGap,arrowsLowerGap,arrowsUpColor,arrowsDnColor,arrowsUpCode,arrowsDnCode,ArrowSize,alertsOn,alertsOnCurrent,alertsMessage,alertsSound,alertsNotify,alertsEmail,soundFile,_buff,_ind)

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
//
//

int init()
{ 
  
   if (TimeFrame == -1)
      switch(Period())
      {
         case 1:     TimeFrame = 5 ;     break;
         case 5:     TimeFrame = 15 ;    break;
         case 15:    TimeFrame = 30 ;    break;
         case 30:    TimeFrame = 60 ;    break;
         case 60:    TimeFrame = 240 ;   break;
         case 240:   TimeFrame = 1440 ;  break;
         case 1440:  TimeFrame = 10080 ; break;
         case 10080: TimeFrame = 43200 ; break;
         default :   TimeFrame = tf_cu;
      }
   
  
   IndicatorBuffers(10);
   SetIndexBuffer(0,stlmhuu); SetIndexStyle(0, DRAW_HISTOGRAM);
   SetIndexBuffer(1,stlmhud); SetIndexStyle(1, DRAW_HISTOGRAM);
   SetIndexBuffer(2,stlmhdd); SetIndexStyle(2, DRAW_HISTOGRAM);
   SetIndexBuffer(3,stlmhdu); SetIndexStyle(3, DRAW_HISTOGRAM);
   SetIndexBuffer(4,stlm);
   SetIndexBuffer(5,buffer2);
   SetIndexBuffer(6,buffer3);
   SetIndexBuffer(7,prices); 
   SetIndexBuffer(8,trend); 
   SetIndexBuffer(9,count);
   
   indicatorFileName = WindowExpertName();
//AHTF Timeframe Timeframe template copy and paste start13
   TimeFrame         = (enTimeFrames)timeFrameValue(TimeFrame);
//AHTF Timeframe Timeframe template copy and paste end13
    
    IndicatorShortName(timeFrameToString(TimeFrame)+" STLM");
return (0);
}
//+------------------------------------------------------------------------------------------------------------------+
//AHTF Timeframe template copy and paste start14
int timeFrameValue(int _tf)
{
   int add  = (_tf>=0) ? 0 : MathAbs(_tf);
   if (add != 0) _tf = _Period;
   int size = ArraySize(iTfTable); 
      int i =0; for (;i<size; i++) if (iTfTable[i]==_tf) break;
                                   if (i==size) return(_Period);
                                                return(iTfTable[(int)MathMin(i+add,size-1)]);
}
//AHTF Timeframe template copy and paste end14
//+------------------------------------------------------------------------------------------------------------------+
int deinit()
{
   string lookFor       = arrowsIdentifier+":";
   int    lookForLength = StringLen(lookFor);
   for (int i=ObjectsTotal()-1; i>=0; i--)
   {
      string objectName = ObjectName(i);
         if (StringSubstr(objectName,0,lookForLength) == lookFor) ObjectDelete(objectName);
   }

//Forex-Station Zone template copy and paste start 2

   lookFor       = UniqueZoneID+":";
   lookForLength = StringLen(lookFor);
   for (i=ObjectsTotal()-1; i>=0; i--)
   {
         objectName = ObjectName(i);
         if (StringSubstr(objectName,0,lookForLength) == lookFor) ObjectDelete(objectName);
   }
   GlobalVariableDel(ChartID()+":"+UniqueZoneID);
//Forex-Station Zone template copy and paste end 2

   return(0);
}

//+------------------------------------------------------------------+
//| STLM                                                             |
//+------------------------------------------------------------------+
//
//

int start()
{
   int i,counted_bars=IndicatorCounted();
      if(counted_bars<0) return(-1);
      if(counted_bars>0) counted_bars--;
         int limit = fmin(Bars-counted_bars,Bars-1); count[0]=limit;

//Forex-Station Zone template copy and paste start 3
         datetime tDummy = GlobalVariableGet(ChartID()+":"+UniqueZoneID); if (tDummy==0) tDummy = Time[0];
//Forex-Station Zone template copy and paste end 3

            if (TimeFrame!=_Period)
            {
//Forex-Station Zone template copy and paste start 5
            GlobalVariableSet(ChartID()+":"+UniqueZoneID,Time[0]+_Period*60-1);
            // don't forget to change to PERIOD_CURRENT in the next line
//            iCustom(NULL,TimeFrame,indicatorFileName,PERIOD_CURRENT,Price,arrowsVisible,arrowsOnFirst,arrowsIdentifier,arrowsUpperGap,arrowsLowerGap,arrowsUpColor,arrowsDnColor,arrowsUpCode,arrowsDnCode,ArrowSize,alertsOn,alertsOnCurrent,alertsMessage,alertsSound,alertsNotify,alertsEmail,soundFile,0,0);
//Forex-Station Zone template copy and paste end 5

               limit = (int)fmax(limit,fmin(Bars-1,_mtfCall(9,0)*TimeFrame/_Period));
               if (trend[limit]==-1) CleanPoint(limit,buffer2,buffer3);
               for (i=limit;i>=0 && !_StopFlag; i--)
               {
                  int y = iBarShift(NULL,TimeFrame,Time[i]);
                     stlm [i]   = _mtfCall(4,y);
                     stlmhuu[i] = EMPTY_VALUE;
                     stlmhud[i] = EMPTY_VALUE;
                     stlmhdd[i] = EMPTY_VALUE;
                     stlmhdu[i] = EMPTY_VALUE;
                     buffer2[i] = EMPTY_VALUE;
                     buffer3[i] = EMPTY_VALUE;
                     trend[i]   = _mtfCall(8,y);
                     
                     //
                     //
                     //
                     //
                     //
                     
                      if (!Interpolate || (i>0 && y==iBarShift(NULL,TimeFrame,Time[i-1]))) continue;
                      #define _interpolate(buff) buff[i+k] = buff[i]+(buff[i+n]-buff[i])*k/n
                      int n,k; datetime time = iTime(NULL,TimeFrame,y);
                         for(n = 1; (i+n)<Bars && Time[i+n] >= time; n++) continue;	
                         for(k = 1; k<n && (i+n)<Bars && (i+k)<Bars; k++) _interpolate(stlm);                                             
            }
            for(i=limit; i>=0; i--)
            {
               if (stlm[i]>0)
               if (trend[i]==1)
                     stlmhuu[i] = stlm[i];
               else  stlmhud[i] = stlm[i];
               if (stlm[i]<0)
               if (trend[i]==1)
                     stlmhdu[i] = stlm[i];
               else  stlmhdd[i] = stlm[i];
               if (trend[i]==-1) PlotPoint(i,buffer2,buffer3,stlm);  
            }
   return(0);
   }

   //
   //
   //
   //
   //
   
   if (trend[limit]==-1) CleanPoint(limit,buffer2,buffer3);
   for (i=limit; i >= 0; i--)
   {
     if (i<Bars-1)
     {
       prices[i] = getPrice(Price,Open,Close,High,Low,i, Bars);
       double value1 =
       0.0982862174*prices[i+0] 
       +0.0975682269*prices[i+1] 
       +0.0961401078*prices[i+2]
       +0.0940230544*prices[i+3]
       +0.0912437090*prices[i+4]
       +0.0878391006*prices[i+5]
       +0.0838544303*prices[i+6]
       +0.0793406350*prices[i+7]
       +0.0743569346*prices[i+8]
       +0.0689666682*prices[i+9]
       +0.0632381578*prices[i+10]
       +0.0572428925*prices[i+11]
       +0.0510534242*prices[i+12]
       +0.0447468229*prices[i+13]
       +0.0383959950*prices[i+14]
       +0.0320735368*prices[i+15]
       +0.0258537721*prices[i+16]
       +0.0198005183*prices[i+17]
       +0.0139807863*prices[i+18]
       +0.0084512448*prices[i+19]
       +0.0032639979*prices[i+20]
       -0.0015350359*prices[i+21]
       -0.0059060082*prices[i+22]
       -0.0098190256*prices[i+23]
       -0.0132507215*prices[i+24]
       -0.0161875265*prices[i+25]
       -0.0186164872*prices[i+26]
       -0.0205446727*prices[i+27]
       -0.0219739146*prices[i+28]
       -0.0229204861*prices[i+29]
       -0.0234080863*prices[i+30]
       -0.0234566315*prices[i+31]
       -0.0231017777*prices[i+32]
       -0.0223796900*prices[i+33]
       -0.0213300463*prices[i+34]
       -0.0199924534*prices[i+35]
       -0.0184126992*prices[i+36]
       -0.0166377699*prices[i+37]
       -0.0147139428*prices[i+38]
       -0.0126796776*prices[i+39]
       -0.0105938331*prices[i+40]
       -0.0084736770*prices[i+41]
       -0.0063841850*prices[i+42]
       -0.0043466731*prices[i+43]
       -0.0023956944*prices[i+44]
       -0.0005535180*prices[i+45]
       +0.0011421469*prices[i+46]
       +0.0026845693*prices[i+47]
       +0.0040471369*prices[i+48]
       +0.0052380201*prices[i+49]
       +0.0062194591*prices[i+50]
       +0.0070340085*prices[i+51]
       +0.0076266453*prices[i+52]
       +0.0080376628*prices[i+53]
       +0.0083037666*prices[i+54]
       +0.0083694798*prices[i+55]
       +0.0082901022*prices[i+56]
       +0.0080741359*prices[i+57]
       +0.0077543820*prices[i+58]
       +0.0073260526*prices[i+59]
       +0.0068163569*prices[i+60]
       +0.0062325477*prices[i+61]
       +0.0056078229*prices[i+62]
       +0.0049516078*prices[i+63]
       +0.0161380976*prices[i+64];
       
       double value2 =
       -0.0074151919*prices[i+0]
       -0.0060698985*prices[i+1]
       -0.0044979052*prices[i+2]
       -0.0027054278*prices[i+3]
       -0.0007031702*prices[i+4]
       +0.0014951741*prices[i+5]
       +0.0038713513*prices[i+6]
       +0.0064043271*prices[i+7]
       +0.0090702334*prices[i+8]
       +0.0118431116*prices[i+9]
       +0.0146922652*prices[i+10]
       +0.0175884606*prices[i+11]
       +0.0204976517*prices[i+12]
       +0.0233865835*prices[i+13]
       +0.0262218588*prices[i+14]
       +0.0289681736*prices[i+15]
       +0.0315922931*prices[i+16]
       +0.0340614696*prices[i+17]
       +0.0363444061*prices[i+18]
       +0.0384120882*prices[i+19]
       +0.0402373884*prices[i+20]
       +0.0417969735*prices[i+21]
       +0.0430701377*prices[i+22]
       +0.0440399188*prices[i+23]
       +0.0446941124*prices[i+24]
       +0.0450230100*prices[i+25]
       +0.0450230100*prices[i+26]
       +0.0446941124*prices[i+27]
       +0.0440399188*prices[i+28]
       +0.0430701377*prices[i+29]
       +0.0417969735*prices[i+30]
       +0.0402373884*prices[i+31]
       +0.0384120882*prices[i+32]
       +0.0363444061*prices[i+33]
       +0.0340614696*prices[i+34]
       +0.0315922931*prices[i+35]
       +0.0289681736*prices[i+36]
       +0.0262218588*prices[i+37]
       +0.0233865835*prices[i+38]
       +0.0204976517*prices[i+39]
       +0.0175884606*prices[i+40]
       +0.0146922652*prices[i+41]
       +0.0118431116*prices[i+42]
       +0.0090702334*prices[i+43]
       +0.0064043271*prices[i+44]
       +0.0038713513*prices[i+45]
       +0.0014951741*prices[i+46]
       -0.0007031702*prices[i+47]
       -0.0027054278*prices[i+48]
       -0.0044979052*prices[i+49]
       -0.0060698985*prices[i+50]
       -0.0074151919*prices[i+51]
       -0.0085278517*prices[i+52]
       -0.0094111161*prices[i+53]
       -0.0100658241*prices[i+54]
       -0.0104994302*prices[i+55]
       -0.0107227904*prices[i+56]
       -0.0107450280*prices[i+57]
       -0.0105824763*prices[i+58]
       -0.0102517019*prices[i+59]
       -0.0097708805*prices[i+60]
       -0.0091581551*prices[i+61]
       -0.0084345004*prices[i+62]
       -0.0076214397*prices[i+63]
       -0.0067401718*prices[i+64]
       -0.0058083144*prices[i+65]
       -0.0048528295*prices[i+66]
       -0.0038816271*prices[i+67]
       -0.0029244713*prices[i+68]
       -0.0019911267*prices[i+69]
       -0.0010974211*prices[i+70]
       -0.0002535559*prices[i+71]
       +0.0005231953*prices[i+72]
       +0.0012297491*prices[i+73]
       +0.0018539149*prices[i+74]
       +0.0023994354*prices[i+75]
       +0.0028490136*prices[i+76]
       +0.0032221429*prices[i+77]
       +0.0034936183*prices[i+78]
       +0.0036818974*prices[i+79]
       +0.0038037944*prices[i+80]
       +0.0038338964*prices[i+81]
       +0.0037975350*prices[i+82]
       +0.0036986051*prices[i+83]
       +0.0035521320*prices[i+84]
       +0.0033559226*prices[i+85]
       +0.0031224409*prices[i+86]
       +0.0028550092*prices[i+87]
       +0.0025688349*prices[i+88]
       +0.0022682355*prices[i+89]
       +0.0073925495*prices[i+90];
       
       stlm[i] = value1-value2;
       stlmhuu[i] = EMPTY_VALUE;
       stlmhud[i] = EMPTY_VALUE;
       stlmhdd[i] = EMPTY_VALUE;
       stlmhdu[i] = EMPTY_VALUE;
       buffer2[i] = EMPTY_VALUE;
       buffer3[i] = EMPTY_VALUE;
       trend[i] = (i<Bars-1) ? (stlm[i]>stlm[i+1]) ? 1 : (stlm[i]<stlm[i+1]) ? -1 : trend[i+1] : 0;            
       if (stlm[i]>0)
       if (trend[i]==1)
             stlmhuu[i] = stlm[i];
       else  stlmhud[i] = stlm[i];
       if (stlm[i]<0)
       if (trend[i]==1)
             stlmhdu[i] = stlm[i];
       else  stlmhdd[i] = stlm[i];
       if (trend[i]==-1) PlotPoint(i,buffer2,buffer3,stlm);
       
       if (arrowsVisible)
       {
          string lookFor = arrowsIdentifier+":"+(string)Time[i]; ObjectDelete(lookFor);            
             if (i<Bars-1 && trend[i] != trend[i+1])
             {
                if (trend[i] == 1) drawArrow(i,arrowsUpColor,arrowsUpCode,false);
                if (trend[i] ==-1) drawArrow(i,arrowsDnColor,arrowsDnCode, true);
             }
        }
//Forex-Station Zone template copy and paste start 4
        if (trend[i]==0 || !ShowZones) continue;

               for (int index=i; index<Bars; index++) if (trend[index]!= trend[index+1]) break;
               string name = UniqueZoneID+":"+Time[index+1]; ObjectDelete(name); ObjectDelete(UniqueZoneID+":"+Time[1]);
               
               datetime lastTime = Time[i-1]; if (i==0) { lastTime = tDummy; if (Time[index]==lastTime) lastTime = Time[0]+Period()*60;}
               ObjectCreate(name,OBJ_RECTANGLE,0,Time[index],0,lastTime,WindowPriceMax()*3.0);
                  ObjectSet(name,OBJPROP_BACK,true);
                  if (trend[i]==-1)
                        ObjectSet(name,OBJPROP_COLOR,ColorDown);
                  else  ObjectSet(name,OBJPROP_COLOR,ColorUp);
//Forex-Station Zone template copy and paste end 4

     }
   }
   if (alertsOn)
   {
      int whichBar = 1; if (alertsOnCurrent) whichBar = 0; 
      if (trend[whichBar] != trend[whichBar+1])
      {
         if (trend[whichBar] == 1) doAlert(" sloping up");
         if (trend[whichBar] ==-1) doAlert(" sloping down");       
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
//-------------------------------------------------------------------
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

          //
          //
          //
          //
          //

          message =  StringConcatenate(Symbol()," ",timeFrameToString(_Period)," at ",TimeToStr(TimeLocal(),TIME_SECONDS)," STLM ",doWhat);
             if (alertsMessage) Alert(message);
             if (alertsNotify)  SendNotification(message);
             if (alertsEmail)   SendMail(_Symbol+" STLM ",message);
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


  
