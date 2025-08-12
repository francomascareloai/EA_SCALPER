//------------------------------------------------------------------
#property copyright "mladen"
#property link      "mladenfx@gmail.com"
#property link      "www.forex-station.com"
//------------------------------------------------------------------
#property indicator_separate_window
#property indicator_buffers 10
#property indicator_color1  clrSilver
#property indicator_color2  clrSilver
#property indicator_color3  C'255,238,210'
#property indicator_color10 clrDimGray
#property indicator_style1  STYLE_DOT
#property indicator_style2  STYLE_DOT
#property indicator_style10 STYLE_DASHDOTDOT
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

enum enColorOn
{
   col_onSign,   // Change color on signal cross
   col_onZone,   // Change color on zone 
   col_onLevels, // Change color on levels cross
   col_onSlope,  // Change color on slope change
   col_noChange  // No color channge
};

extern string    UniqueID             = "Laguerre rsi & filter 1"; // Indicator unique ID
extern double    RsiPeriod            = 41;                        // Laguerre RSI gamma
extern enPrices  RsiPrice             = 0;                         // Price
extern double    RsiSmoothGamma       = 0.001;                     // Laguerre RSI smooth gamma
extern int       RsiSmoothSpeed       = 2;                         // Laguerre RSI smooth speed (min 0, max 6)
extern double    FilterPeriod         = 16;                        // Laguerre filter gamma
extern int       FilterSpeed          = 2;                         // Laguerre filter speed (min 0, max 6)
extern double    LevelUp              = 0.85;                      // Level up
extern double    LevelDown            = 0.15;                      // Level down
extern bool      NoTradeZoneVisible   = true;                      // Display no trade zone?
extern double    NoTradeZoneUp        = 0.65;                      // No trade zone up
extern double    NoTradeZoneDown      = 0.35;                      // No trade zone down
extern color     NoTradeZoneColor     = C'255,238,210';            // No trade zone color
extern color     NoTradeZoneTextColor = clrBlack;                  // No trade zone text color
extern enColorOn ColorOn              = col_onZone;                // Color change on :
extern color     ColorUp              = clrLimeGreen;              // Color for up
extern color     ColorDown            = clrRed;                    // Color for down
extern color     ShadowColor          = C'255,238,210';            // Shadow color
extern int       LineWidth            = 3;                         // Main line width
extern int       ShadowWidth          = 0;                         // Shadow width (<=0 main line width+3)
input bool       alertsOn             = true;                 // Alerts on true/false?
input bool       alertsOnCurrent      = false;                // Alerts on still opened bar true/false?
input bool       alertsMessage        = true;                 // Alerts pop-up message true/false?
input bool       alertsSound          = false;                // Alerts sound true/false?
input bool       alertsPushNotif      = false;                // Alerts push notification true/false?
input bool       alertsEmail          = false;                // Alerts email true/false?
input string     soundFile            = "alert2.wav";         // Sound file
input bool       arrowsVisible        = false;                     // Arrows visible true/false?
input bool       arrowsOnNewest       = false;                     // Arrows drawn on newest bar of higher time frame bar true/false?
input string     arrowsIdentifier     = "lag Arrows1";             // Unique ID for arrows
input double     arrowsUpperGap       = 0.5;                       // Upper arrow gap
input double     arrowsLowerGap       = 0.5;                       // Lower arrow gap
input color      arrowsUpColor        = clrBlue;                   // Up arrow color
input color      arrowsDnColor        = clrCrimson;                // Down arrow color
input int        arrowsUpCode         = 221;                       // Up arrow code
input int        arrowsDnCode         = 222;                       // Down arrow code
input int        arrowsUpSize         = 2;                         // Up arrow size
input int        arrowsDnSize         = 2;                         // Down arrow size

//
//
//
//
//

double lag[],fil[],levu[],levd[],buffer1da[],buffer1db[],buffer1ua[],buffer1ub[],shadowa[],shadowb[],colors[]; 
string shortName;

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
   int shadowWidth = (ShadowWidth<=0) ? LineWidth+3 : ShadowWidth;
   IndicatorBuffers(11);
   SetIndexBuffer(0, levu);
   SetIndexBuffer(1, levd);
   SetIndexBuffer(2, lag);       SetIndexStyle(2,EMPTY,EMPTY,LineWidth);
   SetIndexBuffer(3, shadowa);   SetIndexStyle(3,EMPTY,EMPTY,shadowWidth,ShadowColor);
   SetIndexBuffer(4, shadowb);   SetIndexStyle(4,EMPTY,EMPTY,shadowWidth,ShadowColor);
   SetIndexBuffer(5, buffer1ua); SetIndexStyle(5,EMPTY,EMPTY,LineWidth,ColorUp);
   SetIndexBuffer(6, buffer1ub); SetIndexStyle(6,EMPTY,EMPTY,LineWidth,ColorUp);
   SetIndexBuffer(7, buffer1da); SetIndexStyle(7,EMPTY,EMPTY,LineWidth,ColorDown);
   SetIndexBuffer(8, buffer1db); SetIndexStyle(8,EMPTY,EMPTY,LineWidth,ColorDown);
   SetIndexBuffer(9, fil);       
   SetIndexBuffer(10,colors);
      SetLevelValue(0,LevelUp);
      SetLevelValue(1,LevelDown);
      shortName = UniqueID+": ("+DoubleToStr(RsiPeriod,2)+","+DoubleToStr(RsiSmoothGamma,2)+") filter ("+DoubleToStr(FilterPeriod,2)+")";
      IndicatorShortName(shortName);
   return(0);
}
void OnDeinit(const int reason)  {  ObjectsDeleteAll(0,arrowsIdentifier+":"); ObjectsDeleteAll(0,UniqueID+":");  }

//------------------------------------------------------------------
//                                                                  
//------------------------------------------------------------------

int start()
{
   int counted_bars=IndicatorCounted();
      if(counted_bars<0) return(-1);
      if(counted_bars>0) counted_bars--;
         int limit = fmin(Bars - counted_bars,Bars-1);

   //
   //
   //
   //
   //
   
      double gammar = 1 - 10/(RsiPeriod+9.0);
      double gammaf = 1 - 10/(FilterPeriod+9.0);
      if (colors[limit]==-1) { CleanPoint(limit,buffer1da,buffer1db); CleanPoint(limit,shadowa,shadowb); }
      if (colors[limit]== 1) { CleanPoint(limit,buffer1ua,buffer1ub); CleanPoint(limit,shadowa,shadowb); }
      for(int i = limit; i >= 0 ; i--)
      {
         lag[i]  = LaGuerreRsi(getPrice(RsiPrice,Open,Close,High,Low,i),gammar,RsiSmoothGamma,RsiSmoothSpeed,i);
         fil[i]  = LaGuerreFil(lag[i],gammaf,FilterSpeed,i);
         levu[i] = fmax(NoTradeZoneUp,NoTradeZoneDown);
         levd[i] = fmin(NoTradeZoneUp,NoTradeZoneDown);
         buffer1da[i] = EMPTY_VALUE;
         buffer1db[i] = EMPTY_VALUE;
         buffer1ua[i] = EMPTY_VALUE;
         buffer1ub[i] = EMPTY_VALUE;
         shadowa[i]   = EMPTY_VALUE;
         shadowb[i]   = EMPTY_VALUE;
                        
         switch (ColorOn)
         {
            case col_noChange: colors[i] = 0;                                                                                break;
            case col_onSign:   colors[i] = (lag[i]>fil[i])  ? 1 : (lag[i]<fil[i])  ? -1 : (i<Bars-1) ? colors[i+1] : 0;      break;
            case col_onZone:   colors[i] = (lag[i]>levu[i]) ? 1 : (lag[i]<levd[i]) ? -1 : 0;                                 break;
            case col_onLevels: colors[i] = (lag[i]>fmax(LevelUp,LevelDown)) ? 1 : (lag[i]<fmin(LevelUp,LevelDown)) ? -1 : 0; break;
            case col_onSlope:  colors[i] = (i<Bars-1) ? (lag[i]>lag[i+1])   ? 1 : (lag[i]<lag[i+1]) ? -1 : colors[i+1] : 0;  break;
         }
         if (colors[i] == -1) { PlotPoint(i,buffer1da,buffer1db,lag); PlotPoint(i,shadowa,shadowb,lag); }
         if (colors[i] ==  1) { PlotPoint(i,buffer1ua,buffer1ub,lag); PlotPoint(i,shadowa,shadowb,lag); }
         
         if (arrowsVisible)
         {
           string lookFor = arrowsIdentifier+":"+(string)Time[i]; if (ObjectFind(0,lookFor)==0) ObjectDelete(0,lookFor);           
           if (i<(Bars-1) && colors[i] != colors[i+1])
           {
              if (colors[i] == 1) drawArrow(i,arrowsUpColor,arrowsUpCode,arrowsUpSize,false);
              if (colors[i] ==-1) drawArrow(i,arrowsDnColor,arrowsDnCode,arrowsDnSize, true);
           }
         }    
      }
      
      //
      //
      //
      //
      //
      
      if (NoTradeZoneVisible)
      {
         string name   = UniqueID+":zone";
         int    window = WindowFind(shortName);
            if (ObjectFind(name) == -1)
                ObjectCreate(name,OBJ_RECTANGLE,window,0,0,0,0);
                   ObjectSet(name,OBJPROP_TIME1,Time[Bars-1]);
                   ObjectSet(name,OBJPROP_TIME2,Time[0]);
                   ObjectSet(name,OBJPROP_PRICE1,NoTradeZoneUp);
                   ObjectSet(name,OBJPROP_PRICE2,NoTradeZoneDown);
                   ObjectSet(name,OBJPROP_COLOR,NoTradeZoneColor);
                   ObjectSet(name,OBJPROP_BACK,true);
         name = UniqueID+":text";                   
            if (ObjectFind(name) == -1)
                ObjectCreate(name,OBJ_TEXT,window,0,0);
                   ObjectSet(name,OBJPROP_TIME1,Time[0]+30*Period()*60);
                   ObjectSet(name,OBJPROP_PRICE1,(NoTradeZoneUp+NoTradeZoneDown)/2.0);
                   ObjectSet(name,OBJPROP_COLOR,NoTradeZoneTextColor);
                   ObjectSetText(name,"no-trade zone "+DoubleToStr(NoTradeZoneDown,2)+":"+DoubleToStr(NoTradeZoneUp,2),10,"Courier new");
      }
      if (alertsOn)
      {
        int whichBar = (alertsOnCurrent) ? 0 : 1;
        if (colors[whichBar] != colors[whichBar+1])
        {
           if (colors[whichBar] == 1) doAlert(" up");
           if (colors[whichBar] ==-1) doAlert(" down");       
        }         
   }      
   return(0);
}

//------------------------------------------------------------------
//
//------------------------------------------------------------------

#define priceInstances     1
#define priceInstancesSize 4
double workHa[][priceInstances*priceInstancesSize];
double getPrice(int tprice, const double& open[], const double& close[], const double& high[], const double& low[], int i, int instanceNo=0)
{
  if (tprice>=pr_haclose)
   {
      if (ArrayRange(workHa,0)!= Bars) ArrayResize(workHa,Bars); instanceNo*=priceInstancesSize; int r = Bars-i-1;
         
         //
         //
         //
         //
         //
         
         double haOpen  = (r>0) ? (workHa[r-1][instanceNo+2] + workHa[r-1][instanceNo+3])/2.0 : (open[i]+close[i])/2;;
         double haClose = (open[i]+high[i]+low[i]+close[i]) / 4.0;
         if (tprice>=pr_habclose)
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

//------------------------------------------------------------------
//                                                                  
//------------------------------------------------------------------

double workLagRsi[][15];
double LaGuerreRsi(double price, double gamma, double smooth, double smoothSpeed, int i, int instanceNo=0)
{
   if (ArrayRange(workLagRsi,0)!=Bars) ArrayResize(workLagRsi,Bars); int r = i; i=Bars-i-1; instanceNo*=5;

   //
   //
   //
   //
   //

   workLagRsi[i][instanceNo+0] = (i>0) ? (1.0 - gamma)*price                                                + gamma*workLagRsi[i-1][instanceNo+0] : price;
	workLagRsi[i][instanceNo+1] = (i>0) ? -gamma*workLagRsi[i][instanceNo+0] + workLagRsi[i-1][instanceNo+0] + gamma*workLagRsi[i-1][instanceNo+1] : price;
	workLagRsi[i][instanceNo+2] = (i>0) ? -gamma*workLagRsi[i][instanceNo+1] + workLagRsi[i-1][instanceNo+1] + gamma*workLagRsi[i-1][instanceNo+2] : price;
	workLagRsi[i][instanceNo+3] = (i>0) ? -gamma*workLagRsi[i][instanceNo+2] + workLagRsi[i-1][instanceNo+2] + gamma*workLagRsi[i-1][instanceNo+3] : price;

   //
   //
   //
   //
   //

      double CU = 0.00;
      double CD = 0.00;
      if (i>0)
      {   
            if (workLagRsi[i][instanceNo+0] >= workLagRsi[i][instanceNo+1])
            			CU =      workLagRsi[i][instanceNo+0] - workLagRsi[i][instanceNo+1];
            else	   CD =      workLagRsi[i][instanceNo+1] - workLagRsi[i][instanceNo+0];
            if (workLagRsi[i][instanceNo+1] >= workLagRsi[i][instanceNo+2])
            			CU = CU + workLagRsi[i][instanceNo+1] - workLagRsi[i][instanceNo+2];
            else	   CD = CD + workLagRsi[i][instanceNo+2] - workLagRsi[i][instanceNo+1];
            if (workLagRsi[i][instanceNo+2] >= workLagRsi[i][instanceNo+3])
   	       		   CU = CU + workLagRsi[i][instanceNo+2] - workLagRsi[i][instanceNo+3];
            else	   CD = CD + workLagRsi[i][instanceNo+3] - workLagRsi[i][instanceNo+2];
         }            
         if (CU + CD != 0) 
               workLagRsi[i][instanceNo+4] = CU / (CU + CD);
         else  workLagRsi[i][instanceNo+4] = 0;

   //
   //
   //
   //
   //

   return(LaGuerreFil(workLagRsi[i][instanceNo+4],smooth,(int)smoothSpeed,r,1));
}

//------------------------------------------------------------------
//                                                                  
//------------------------------------------------------------------
//
//
//
//
//

double workLagFil[][8];
double LaGuerreFil(double price, double gamma, int smoothSpeed, int i, int instanceNo=0)
{
   if (ArrayRange(workLagFil,0)!=Bars) ArrayResize(workLagFil,Bars); i=Bars-i-1; instanceNo*=4;
   if (gamma<=0) return(price);

   //
   //
   //
   //
   //
      
   workLagFil[i][instanceNo+0] = (i>0) ? (1.0 - gamma)*price                                                + gamma*workLagFil[i-1][instanceNo+0] : price;
	workLagFil[i][instanceNo+1] = (i>0) ? -gamma*workLagFil[i][instanceNo+0] + workLagFil[i-1][instanceNo+0] + gamma*workLagFil[i-1][instanceNo+1] : price;
	workLagFil[i][instanceNo+2] = (i>0) ? -gamma*workLagFil[i][instanceNo+1] + workLagFil[i-1][instanceNo+1] + gamma*workLagFil[i-1][instanceNo+2] : price;
	workLagFil[i][instanceNo+3] = (i>0) ? -gamma*workLagFil[i][instanceNo+2] + workLagFil[i-1][instanceNo+2] + gamma*workLagFil[i-1][instanceNo+3] : price;

   //
   //
   //
   //
   //
 
   double coeffs[]={0,0,0,0};
      smoothSpeed = MathMax(MathMin(smoothSpeed,6),0);   
      switch (smoothSpeed)
      {
         case 0: coeffs[0] = 1; coeffs[1] = 1; coeffs[2] = 1; coeffs[3] = 1; break;
         case 1: coeffs[0] = 1; coeffs[1] = 1; coeffs[2] = 2; coeffs[3] = 1; break;
         case 2: coeffs[0] = 1; coeffs[1] = 2; coeffs[2] = 2; coeffs[3] = 1; break;
         case 3: coeffs[0] = 2; coeffs[1] = 2; coeffs[2] = 2; coeffs[3] = 1; break;
         case 4: coeffs[0] = 2; coeffs[1] = 3; coeffs[2] = 2; coeffs[3] = 1; break;
         case 5: coeffs[0] = 3; coeffs[1] = 3; coeffs[2] = 2; coeffs[3] = 1; break;
         case 6: coeffs[0] = 4; coeffs[1] = 3; coeffs[2] = 2; coeffs[3] = 1; break;
      }
   double sumc = 0; for (int k=0; k<4; k++) sumc += coeffs[k];
   return((coeffs[0]*workLagFil[i][instanceNo+0]+coeffs[1]*workLagFil[i][instanceNo+1]+coeffs[2]*workLagFil[i][instanceNo+2]+coeffs[3]*workLagFil[i][instanceNo+3])/sumc);
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

      datetime atime = Time[i]; //if (arrowsOnNewest) atime += PeriodSeconds(_Period)-1;       
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

          message = timeFrameToString(_Period)+" "+_Symbol+" at "+TimeToStr(TimeLocal(),TIME_SECONDS)+" Laguerre RSI "+doWhat;
             if (alertsMessage)    Alert(message);
             if (alertsPushNotif)  SendNotification(message);
             if (alertsEmail)      SendMail(_Symbol+" Laguerre RSI ",message);
             if (alertsSound)      PlaySound(soundFile);
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

string sTfTable[] = {"M1","M5","M15","M30","H1","H4","D1","W1","MN"};
int    iTfTable[] = {1,5,15,30,60,240,1440,10080,43200};

string timeFrameToString(int tf)
{
   for (int i=ArraySize(iTfTable)-1; i>=0; i--) 
         if (tf==iTfTable[i]) return(sTfTable[i]);
                              return("");
}


