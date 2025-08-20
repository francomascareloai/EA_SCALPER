#property indicator_separate_window
#property indicator_buffers    7
#property indicator_color1     clrGray
#property indicator_levelstyle STYLE_DOT
#property indicator_levelcolor clrMediumOrchid
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

extern ENUM_TIMEFRAMES    TimeFrame              = PERIOD_CURRENT;    // Time frame
extern int                Length                 = 7;                 // Rsx length
extern enPrices           Price                  = pr_typical;        // Rsx price to use    
extern double             OverSold               = 30;                // Oversold level
extern double             OverBought             = 70;                // Overbought level
extern color              OverSoldColor          = clrGreen;          // Oversold color
extern color              OverBoughtColor        = clrRed;            // Overbought color
extern color              ShadowColor            = clrGray;           // Shadow color
extern int                LineWidth              = 3;                 // Main line width
extern int                ShadowWidth            = 0;                 // Shadow width (<=0 main line width+3) 
extern bool               alertsOn               = false;             // Turn alerts on?
extern bool               alertsOnZoneEnter      = true;              // Alerts on entering OB/OS zones?
extern bool               alertsOnZoneExit       = true;              // Alerts on exiting OB/OS zones
extern bool               alertsOnCurrent        = false;             // Alerts on still opened bar?
extern bool               alertsMessage          = true;              // Alerts should display message?
extern bool               alertsSound            = false;             // Alerts should play a sound?
extern bool               alertsNotify           = false;             // Alerts should send a notification?
extern bool               alertsEmail            = false;             // Alerts should send an email?
extern string             soundFile              = "alert2.wav";      // Sound file
extern bool               arrowsVisible          = false;             // Show arrows?
extern string             arrowsIdentifier       = "rsx arrows1";     // Arrows ID
extern bool               arrowsOnNewest         = false;             // Arrows drawn on newest bar of higher time frame bar
extern double             arrowsDisplaceUp       = 0.5;               // Arrow gap up
extern double             arrowsDisplaceDn       = 0.5;               // Arrow gap down
extern bool               arrowsOnZoneEnter      = true;              // Arrows on entering OB/OS zone?
extern color              arrowsUpZoneEnterColor = clrDeepSkyBlue;    // Arrows on entering OB/OS zone up color
extern color              arrowsDnZoneEnterColor = clrRed;            // Arrows on entering OB/OS zone down
extern int                arrowsUpZoneEnterCode  = 233;               // Arrows on entering OB/OS zone up code
extern int                arrowsDnZoneEnterCode  = 234;               // Arrows on entering OB/OS zone down code
extern int                arrowsUpZoneEnterSize  = 2;                 // Arrows on entering OB/OS zone up size
extern int                arrowsDnZoneEnterSize  = 2;                 // Arrows on entering OB/OS zone down size
extern bool               arrowsOnZoneExit       = false;             // Arrows on exiting OB/OS zone?           
extern color              arrowsUpZoneExitColor  = clrLime;           // Arrows on exiting OB/OS zone up color
extern color              arrowsDnZoneExitColor  = clrOrange;         // Arrows on exiting OB/OS zone down color 
extern int                arrowsUpZoneExitCode   = 119;               // Arrows on exiting OB/OS zone up code
extern int                arrowsDnZoneExitCode   = 119;               // Arrows on exiting OB/OS zone down code
extern int                arrowsUpZoneExitSize   = 2;                 // Arrows on exiting OB/OS zone up size
extern int                arrowsDnZoneExitSize   = 2;                 // Arrows on exiting OB/OS zone down size
extern bool               Interpolate            = true;              // Interpolate in mtf mode?

double rsx[],buffer1da[],buffer1db[],buffer1ua[],buffer1ub[],trend[],shadowa[],shadowb[],wrkBuffer[][13],count[];
string indicatorFileName;
#define _mtfCall(_buff,_ind) iCustom(NULL,TimeFrame,indicatorFileName,PERIOD_CURRENT,Length,Price,OverSold,OverBought,OverSoldColor,OverBoughtColor,ShadowColor,LineWidth,ShadowWidth,alertsOn,alertsOnZoneEnter,alertsOnZoneExit,alertsOnCurrent,alertsMessage,alertsSound,alertsNotify,alertsEmail,soundFile,arrowsVisible,arrowsIdentifier,arrowsOnNewest,arrowsDisplaceUp,arrowsDisplaceDn,arrowsOnZoneEnter,arrowsUpZoneEnterColor,arrowsDnZoneEnterColor,arrowsUpZoneEnterCode,arrowsDnZoneEnterCode,arrowsUpZoneEnterSize,arrowsDnZoneEnterSize,arrowsOnZoneExit,arrowsUpZoneExitColor,arrowsDnZoneExitColor,arrowsUpZoneExitCode,arrowsDnZoneExitCode,arrowsUpZoneExitSize,arrowsDnZoneExitSize,_buff,_ind)

//-------------------------------------------------------------------
//
//-------------------------------------------------------------------
//
//
//
//
//

int OnInit()
{
   int shadowWidth = (ShadowWidth<=0) ? LineWidth+3 : ShadowWidth;
   IndicatorBuffers(9);
   SetIndexBuffer(0, rsx);       SetIndexStyle(0,DRAW_LINE,EMPTY,LineWidth);
   SetIndexBuffer(1, shadowa);   SetIndexStyle(1,DRAW_LINE,EMPTY,shadowWidth,ShadowColor);
   SetIndexBuffer(2, shadowb);   SetIndexStyle(2,DRAW_LINE,EMPTY,shadowWidth,ShadowColor);
   SetIndexBuffer(3, buffer1ua); SetIndexStyle(3,DRAW_LINE,EMPTY,LineWidth,OverBoughtColor);
   SetIndexBuffer(4, buffer1ub); SetIndexStyle(4,DRAW_LINE,EMPTY,LineWidth,OverBoughtColor);
   SetIndexBuffer(5, buffer1da); SetIndexStyle(5,DRAW_LINE,EMPTY,LineWidth,OverSoldColor);
   SetIndexBuffer(6, buffer1db); SetIndexStyle(6,DRAW_LINE,EMPTY,LineWidth,OverSoldColor);
   SetIndexBuffer(7, trend);
   SetIndexBuffer(8, count);
   SetLevelValue(0,OverBought);
   SetLevelValue(1,OverSold);
   
   indicatorFileName = WindowExpertName();
   TimeFrame         = fmax(TimeFrame,_Period);  

   IndicatorShortName(timeFrameToString(TimeFrame)+" Rsx ("+(string)Length+")");
return(INIT_SUCCEEDED);
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

//-------------------------------------------------------------------
//
//-------------------------------------------------------------------
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
         int limit = fmin(Bars-counted_bars,Bars-1); count[0]=limit;
            if (TimeFrame!=_Period)
            {
               limit = (int)fmax(limit,fmin(Bars-1,_mtfCall(8,0)*TimeFrame/_Period));
               if (trend[limit]==-1) { CleanPoint(limit,buffer1da,buffer1db); CleanPoint(limit,shadowa,shadowb); }
               if (trend[limit]== 1) { CleanPoint(limit,buffer1ua,buffer1ub); CleanPoint(limit,shadowa,shadowb); }
               for (i=limit;i>=0 && !_StopFlag; i--)
               {
                  int y = iBarShift(NULL,TimeFrame,Time[i]);
                     rsx[i]       = _mtfCall(0,y);
                     shadowa[i]   = EMPTY_VALUE;
                     shadowb[i]   = EMPTY_VALUE;
                     buffer1da[i] = EMPTY_VALUE;
                     buffer1db[i] = EMPTY_VALUE;
                     buffer1ua[i] = EMPTY_VALUE;
                     buffer1ub[i] = EMPTY_VALUE;
                     trend[i]     = _mtfCall(7,y);
                 
                     //
                     //
                     //
                     //
                     //
                     
                     if (!Interpolate || (i>0 && y==iBarShift(NULL,TimeFrame,Time[i-1]))) continue;
                        #define _interpolate(buff) buff[i+k] = buff[i]+(buff[i+n]-buff[i])*k/n
                        int n,k; datetime time = iTime(NULL,TimeFrame,y);
                           for(n = 1; (i+n)<Bars && Time[i+n] >= time; n++) continue;	
                           for(k = 1; k<n && (i+n)<Bars && (i+k)<Bars; k++)  _interpolate(rsx);                                       
              }   
              for (i=limit; i >= 0; i--)
              {
                 if (trend[i] == -1) { PlotPoint(i,buffer1da,buffer1db,rsx); PlotPoint(i,shadowa,shadowb,rsx); }
                 if (trend[i] ==  1) { PlotPoint(i,buffer1ua,buffer1ub,rsx); PlotPoint(i,shadowa,shadowb,rsx); }  
	            }      
   return(0);
   }

   //
   //
   //
   //
   //
   
   if (ArrayRange(wrkBuffer,0) != Bars) ArrayResize(wrkBuffer,Bars);
   if (trend[limit]==-1) { CleanPoint(limit,buffer1da,buffer1db); CleanPoint(limit,shadowa,shadowb); }
   if (trend[limit]== 1) { CleanPoint(limit,buffer1ua,buffer1ub); CleanPoint(limit,shadowa,shadowb); }
   double Kg = (3.0)/(2.0+Length); 
   double Hg = 1.0-Kg;
   for(i=limit, r=Bars-i-1; i>=0; i--, r++)
   {
      wrkBuffer[r][12] = getPrice(Price,Open,Close,High,Low,i,Bars);
      if (i==(Bars-1)) { for (int c=0; c<12; c++) wrkBuffer[r][c] = 0; continue; }  

      //
      //
      //
      //
      //
      
      double mom = wrkBuffer[r][12]-wrkBuffer[r-1][12];
      double moa = fabs(mom);
      for (int k=0; k<3; k++)
      {
         int kk = k*2;
            wrkBuffer[r][kk+0] = Kg*mom                + Hg*wrkBuffer[r-1][kk+0];
            wrkBuffer[r][kk+1] = Kg*wrkBuffer[r][kk+0] + Hg*wrkBuffer[r-1][kk+1]; mom = 1.5*wrkBuffer[r][kk+0] - 0.5 * wrkBuffer[r][kk+1];
            wrkBuffer[r][kk+6] = Kg*moa                + Hg*wrkBuffer[r-1][kk+6];
            wrkBuffer[r][kk+7] = Kg*wrkBuffer[r][kk+6] + Hg*wrkBuffer[r-1][kk+7]; moa = 1.5*wrkBuffer[r][kk+6] - 0.5 * wrkBuffer[r][kk+7];
      }
      rsx[i] = (moa != 0) ? fmax(fmin((mom/moa+1.0)*50.0,100.00),0.00) : 50;
      buffer1da[i] = EMPTY_VALUE;
      buffer1db[i] = EMPTY_VALUE;
      buffer1ua[i] = EMPTY_VALUE;
      buffer1ub[i] = EMPTY_VALUE;
      shadowa[i]   = EMPTY_VALUE;
      shadowb[i]   = EMPTY_VALUE;
      trend[i] = (i<Bars-1) ? (rsx[i]>OverBought) ? 1 : (rsx[i]<OverSold) ? -1 : (rsx[i]<OverBought && rsx[i]>OverSold) ? 0 : trend[i+1] : 0;  
      if (trend[i] == -1) { PlotPoint(i,buffer1da,buffer1db,rsx); PlotPoint(i,shadowa,shadowb,rsx); }
      if (trend[i] ==  1) { PlotPoint(i,buffer1ua,buffer1ub,rsx); PlotPoint(i,shadowa,shadowb,rsx); }   
      
      //
      //
      //
      //
      //
                           
      if (arrowsVisible)
      {
          string lookFor = arrowsIdentifier+":"+(string)Time[i]; ObjectDelete(lookFor);            
          if (i<(Bars-1) && trend[i] != trend[i+1])
          {
              if (arrowsOnZoneEnter && trend[i]   ==-1)                 drawArrow(i,arrowsUpZoneEnterColor,arrowsUpZoneEnterCode,arrowsUpZoneEnterSize,false);
              if (arrowsOnZoneEnter && trend[i]   == 1)                 drawArrow(i,arrowsDnZoneEnterColor,arrowsDnZoneEnterCode,arrowsDnZoneEnterSize,true);
              if (arrowsOnZoneExit  && trend[i+1] == 1 && trend[i]!= 1) drawArrow(i,arrowsDnZoneExitColor,arrowsDnZoneExitCode,arrowsDnZoneExitSize,true); 
              if (arrowsOnZoneExit  && trend[i+1] ==-1 && trend[i]!=-1) drawArrow(i,arrowsUpZoneExitColor,arrowsUpZoneExitCode,arrowsUpZoneExitSize,false); 
            }                                            
      
        }
   }
   if (alertsOn)
   {
      int whichBar = 1; if (alertsOnCurrent) whichBar = 0;
      static datetime time1 = 0;
      static string   mess1 = "";
      if (alertsOnZoneEnter && trend[whichBar] != trend[whichBar+1])
      {
         if (trend[whichBar] ==  1)  doAlert(time1,mess1,whichBar,DoubleToStr(OverBought,2)+" crossed up");
         if (trend[whichBar] == -1)  doAlert(time1,mess1,whichBar,DoubleToStr(OverSold,2) +" crossed down");
      }  
      static datetime time2 = 0;
      static string   mess2 = "";  
      if (alertsOnZoneExit && trend[whichBar] != trend[whichBar+1])
      {
         if (trend[whichBar+1] == -1 && trend[whichBar]!=-1) doAlert(time2,mess2,whichBar,DoubleToStr(OverBought,2)+" crossed up");
         if (trend[whichBar+1] ==  1 && trend[whichBar]!= 1) doAlert(time2,mess2,whichBar,DoubleToStr(OverSold,2)+" crossed down");
      }
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

//
//
//
//
//

void doAlert(datetime& previousTime, string& previousAlert, int forBar, string doWhat)
{
   string message;
   
   if (previousAlert != doWhat || previousTime != Time[forBar]) {
       previousAlert  = doWhat;
       previousTime   = Time[forBar];

       //
       //
       //
       //
       //

       message =  StringConcatenate(Symbol()," ",timeFrameToString(Period())," at ",TimeToStr(TimeLocal(),TIME_SECONDS)," Rsx ",doWhat);
          if (alertsMessage) Alert(message);
          if (alertsNotify)  SendNotification(message);
          if (alertsEmail)   SendMail(_Symbol+" Rsx ",message);
          if (alertsSound)   PlaySound(soundFile);
   }
}

//-------------------------------------------------------------------
//                                                                  
//-------------------------------------------------------------------
//
//
//
//
//

void drawArrow(int i,color theColor,int theCode,int theSize,bool tup)
{
   string name = arrowsIdentifier+":"+(string)Time[i];
   double gap  = iATR(NULL,0,20,i);   
   
      //
      //
      //
      //
      //

      datetime time = Time[i]; if (arrowsOnNewest) time += _Period*60-1;      
      ObjectCreate(name,OBJ_ARROW,0,time,0);
         ObjectSet(name,OBJPROP_ARROWCODE,theCode);
         ObjectSet(name,OBJPROP_WIDTH,    theSize);
         ObjectSet(name,OBJPROP_COLOR,    theColor);
         if (tup)
               ObjectSet(name,OBJPROP_PRICE1,High[i] + arrowsDisplaceUp * gap);
         else  ObjectSet(name,OBJPROP_PRICE1,Low[i]  - arrowsDisplaceDn * gap);
}


