//+------------------------------------------------------------------
//|
//+------------------------------------------------------------------
#property copyright "mladen"
#property link      "www.forex-station.com"

#property indicator_separate_window
#property indicator_buffers 7
#property indicator_color1  clrDeepSkyBlue
#property indicator_color2  clrSandyBrown
#property indicator_color3  clrSilver
#property indicator_color4  clrDodgerBlue
#property indicator_color5  clrDodgerBlue
#property indicator_color6  clrSandyBrown
#property indicator_color7  clrSandyBrown
#property indicator_width3  2
#property indicator_width4  2
#property indicator_width5  2
#property indicator_width6  2
#property indicator_width7  2
#property indicator_style1  STYLE_DOT
#property indicator_style2  STYLE_DOT
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
   pr_haclose,    // Heiken ashi close
   pr_haopen ,    // Heiken ashi open
   pr_hahigh,     // Heiken ashi high
   pr_halow,      // Heiken ashi low
   pr_hamedian,   // Heiken ashi median
   pr_hatypical,  // Heiken ashi typical
   pr_haweighted, // Heiken ashi weighted
   pr_haaverage,  // Heiken ashi average
   pr_hamedianb,  // Heiken ashi median body
   pr_hatbiased   // Heiken ashi trend biased price
};

//
//
//
//
//

enum enRsiTypes
{
   rsi_rsi,  // Regular RSI
   rsi_wil,  // Slow RSI
   rsi_rap,  // Rapid RSI
   rsi_har,  // Harris RSI
   rsi_rsx,  // RSX
   rsi_cut   // Cuttlers RSI
};
enum enColorOn
{
   onSlopeChange, // Change color on slope change
   onFastCross,   // Change color on fast trend cross
   onSlowCross,   // Change color on slow trend cross
   onBothCross    // Change color on crossing of both values
};

extern ENUM_TIMEFRAMES TimeFrame          = PERIOD_CURRENT;  // Time frame to use
extern int             RsiPeriod          = 14;              // Rsi period
extern enPrices        RsiPrice           = pr_close;        // Rsi price to use
extern int             RsiPriceSmoothing  = 0;               // Rsi price smoothing
extern ENUM_MA_METHOD  RsiPriceSmoothingMethod = MODE_EMA;   // Rsi price smoothing method
extern int             RsiSmoothingFactor = 5;               // Rsi smoothing
extern enRsiTypes      RsiType            = rsi_rsx;         // Rsi type
extern double          WPFast             = 2.618;           // WP fast coeff
extern double          WPSlow             = 4.236;           // WP slow coeff
extern enColorOn       ChangeColorOn      = onBothCross;     // Change colors on :
extern bool            alertsOn           = false;           // Turn alerts on?
extern bool            alertsOnCurrent    = true;            // Alerts on current (still opened) bar?
extern bool            alertsMessage      = true;            // Alerts should show pop-up message?
extern bool            alertsPushNotif    = false;           // Alerts should send push notification?
extern bool            alertsSound        = false;           // Alerts should play a sound?
extern bool            alertsEmail        = false;           // Alerts should send email?
extern bool            arrowsVisible      = false;           // Arrows visible?
extern bool            arrowsOnNewest     = false;           // Arrows drawn on newst bar of higher time frame bar?
extern string          arrowsIdentifier   = "aqqe Arrows1";  // Unique ID for arrows
extern double          arrowsUpperGap     = 1.0;             // Upper arrow gap
extern double          arrowsLowerGap     = 1.0;             // Lower arrow gap
extern color           arrowsUpColor      = clrLimeGreen;    // Up arrow color
extern color           arrowsDnColor      = clrOrange;       // Down arrow color
extern int             arrowsUpCode       = 241;             // Up arrow code
extern int             arrowsDnCode       = 242;             // Down arrow code
extern bool            Interpolate        = true;

//
//
//
//
//

double RsiMa[];
double RsiMada[];
double RsiMadb[];
double RsiMaua[];
double RsiMaub[];
double TrendFast[];
double TrendSlow[];
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
   IndicatorBuffers(9);
   SetIndexBuffer(0,TrendSlow); SetIndexLabel(0, "QQE trend");
   SetIndexBuffer(1,TrendFast); SetIndexLabel(1, "QQE fast trend");
   SetIndexBuffer(2,RsiMa);     SetIndexLabel(2, "QQE");
   SetIndexBuffer(3,RsiMaua);   SetIndexLabel(3, "QQE");
   SetIndexBuffer(4,RsiMaub);   SetIndexLabel(4, "QQE");
   SetIndexBuffer(5,RsiMada);   SetIndexLabel(5, "QQE");
   SetIndexBuffer(6,RsiMadb);   SetIndexLabel(6, "QQE");
   SetIndexBuffer(7,trend);
   SetIndexBuffer(8,prices);

   //
   //
   //
   //
   //
   
      indicatorFileName = WindowExpertName();
      returnBars        = TimeFrame==-99;
      TimeFrame         = MathMax(TimeFrame,_Period);
      RsiPriceSmoothing = MathMax(RsiPriceSmoothing,1);
      
   //
   //
   //
   //
   //      

   IndicatorShortName(timeFrameToString(TimeFrame)+" QQE of "+getRsiName(RsiType)+" ("+(string)RsiPeriod+","+(string)RsiSmoothingFactor+")");
return(0);
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

//------------------------------------------------------------------
//
//------------------------------------------------------------------
//
//
//
//
//

double emas[][5];
#define iEma   0
#define iEmm   1
#define iEmf   2
#define iEms   3
#define _prict 4

//
//
//
//
//

int start()
{
   int counted_bars=IndicatorCounted();
   int i,r,limit;
   
   if(counted_bars < 0) return(-1);
   if(counted_bars > 0) counted_bars--;
           limit = MathMin(Bars-counted_bars,Bars-1);
           if (returnBars) { TrendSlow[0] = limit+1; return(0); }

   //
   //
   //
   //
   //

   if (TimeFrame == Period())
   {
      double alpha1 = 2.0/(RsiSmoothingFactor+1.0);
      if (ArrayRange(emas,0) != Bars) ArrayResize(emas,Bars); 
      if (trend[limit]==-1) CleanPoint(limit,RsiMada,RsiMadb);
      if (trend[limit]== 1) CleanPoint(limit,RsiMaua,RsiMaub);
      for (i=limit;             i>=0; i--    ) prices[i] = getPrice(RsiPrice,Open,Close,High,Low,i);
      for (i=limit, r=Bars-i-1; i>=0; i--,r++)
      {  
         emas[r][_prict] = iMAOnArray(prices,0,RsiPriceSmoothing,0,RsiPriceSmoothingMethod,i);
         double noise = 0, vhf = 0;
         double max   = emas[r][_prict];
         double min   = emas[r][_prict];
            for (int k=0; k<RsiPeriod && (r-k-1)>=0; k++)
            {
                  noise += MathAbs(emas[r-k][_prict]-emas[r-k-1][_prict]);
                  max    = MathMax(emas[r-k][_prict],max);   
                  min    = MathMin(emas[r-k][_prict],min);   
            }      
            if (noise>0) vhf = (max-min)/noise;
            double rsiPeriod = -MathLog(vhf)*RsiPeriod; 
               if (r==0) continue;
            double alpha2 = 1.0/(MathMax(rsiPeriod,1));
         
         RsiMa[i]      = RsiMa[i+1] + alpha1*(iRsi(emas[r][_prict],rsiPeriod,RsiType,i) - RsiMa[i+1]);
         emas[r][iEma] = emas[r-1][iEma] + alpha2*(MathAbs(RsiMa[i+1]-RsiMa[i]) - emas[r-1][iEma]);
         emas[r][iEmm] = emas[r-1][iEmm] + alpha2*(emas[r][iEma]                - emas[r-1][iEmm]);
         emas[r][iEmf] = emas[r][iEmm]*WPFast;
         emas[r][iEms] = emas[r][iEmm]*WPSlow;

         //
         //
         //
         //
         //

         double tr = TrendSlow[i+1];
         double dv = tr;
               if (RsiMa[i] < tr) { tr = RsiMa[i] + emas[r][iEms]; if ((RsiMa[i+1] < dv) && (tr > dv)) tr = dv; }
               if (RsiMa[i] > tr) { tr = RsiMa[i] - emas[r][iEms]; if ((RsiMa[i+1] > dv) && (tr < dv)) tr = dv; }
         TrendSlow[i] = tr;
         
         tr = TrendFast[i+1];
         dv = tr;
               if (RsiMa[i] < tr) { tr = RsiMa[i] + emas[r][iEmf]; if ((RsiMa[i+1] < dv) && (tr > dv)) tr = dv; }
               if (RsiMa[i] > tr) { tr = RsiMa[i] - emas[r][iEmf]; if ((RsiMa[i+1] > dv) && (tr < dv)) tr = dv; }
         TrendFast[i] = tr;
         
         switch (ChangeColorOn)
         {
            case onBothCross : 
               trend[i] = 0;
               if (RsiMa[i] > TrendSlow[i] && RsiMa[i] > TrendFast[i]) trend[i] =  1; 
               if (RsiMa[i] < TrendSlow[i] && RsiMa[i] < TrendFast[i]) trend[i] = -1;
               break;
            case onFastCross : 
               trend[i] = trend[i+1];
               if (RsiMa[i] > TrendFast[i]) trend[i] =  1; 
               if (RsiMa[i] < TrendFast[i]) trend[i] = -1;
               break;
            case onSlowCross : 
               trend[i] = trend[i+1];
               if (RsiMa[i] > TrendSlow[i]) trend[i] =  1; 
               if (RsiMa[i] < TrendSlow[i]) trend[i] = -1;
               break;
            default : 
               trend[i] = trend[i+1];
               if (RsiMa[i] > RsiMa[i+1]) trend[i] =  1; 
               if (RsiMa[i] < RsiMa[i+1]) trend[i] = -1;
               break;
         }
               RsiMada[i] = EMPTY_VALUE;
               RsiMadb[i] = EMPTY_VALUE;
               RsiMaua[i] = EMPTY_VALUE;
               RsiMaub[i] = EMPTY_VALUE;
               if (trend[i]==-1) PlotPoint(i,RsiMada,RsiMadb,RsiMa);
               if (trend[i]== 1) PlotPoint(i,RsiMaua,RsiMaub,RsiMa);
               
               //
               //
               //
               //
               //
               
               if (arrowsVisible)
               {
                  string lookFor = arrowsIdentifier+":"+(string)Time[i]; ObjectDelete(lookFor);            
                     if (trend[i] != trend[i+1])
                     {
                        if (trend[i] == 1) drawArrow(i,arrowsUpColor,arrowsUpCode,false);
                        if (trend[i] ==-1) drawArrow(i,arrowsDnColor,arrowsDnCode, true);
                     }
               }
      }
      
      //
      //
      //
      //
      //
      
      if (alertsOn) 
      {
        int whichBar = 1; if (alertsOnCurrent) whichBar = 0;
        if (trend[whichBar] != trend[whichBar+1]) 
        {
          if (trend[whichBar] ==  1) doAlert(whichBar,"up");
          if (trend[whichBar] == -1) doAlert(whichBar,"down");
        }
      }
      return(0);
   }
   
   //
   //
   //
   //
   //
   
   limit = (int)MathMax(limit,MathMin(Bars-1,iCustom(NULL,TimeFrame,indicatorFileName,-99,0,0)*TimeFrame/Period()));
   if (trend[limit]==-1) CleanPoint(limit,RsiMada,RsiMadb);
   if (trend[limit]== 1) CleanPoint(limit,RsiMaua,RsiMaub);
   for(i=limit; i>=0; i--)
   {

      int y = iBarShift(NULL,TimeFrame,Time[i]);
         RsiMa[i]     = iCustom(NULL,TimeFrame,indicatorFileName,PERIOD_CURRENT,RsiPeriod,RsiPrice,RsiPriceSmoothing,RsiPriceSmoothingMethod,RsiSmoothingFactor,RsiType,WPFast,WPSlow,ChangeColorOn,alertsOn,alertsOnCurrent,alertsMessage,alertsPushNotif,alertsSound,alertsEmail,arrowsVisible,arrowsOnNewest,arrowsIdentifier,arrowsUpperGap,arrowsLowerGap,arrowsUpColor,arrowsDnColor,arrowsUpCode,arrowsDnCode,2,y);
         TrendSlow[i] = iCustom(NULL,TimeFrame,indicatorFileName,PERIOD_CURRENT,RsiPeriod,RsiPrice,RsiPriceSmoothing,RsiPriceSmoothingMethod,RsiSmoothingFactor,RsiType,WPFast,WPSlow,ChangeColorOn,alertsOn,alertsOnCurrent,alertsMessage,alertsPushNotif,alertsSound,alertsEmail,arrowsVisible,arrowsOnNewest,arrowsIdentifier,arrowsUpperGap,arrowsLowerGap,arrowsUpColor,arrowsDnColor,arrowsUpCode,arrowsDnCode,0,y);
         TrendFast[i] = iCustom(NULL,TimeFrame,indicatorFileName,PERIOD_CURRENT,RsiPeriod,RsiPrice,RsiPriceSmoothing,RsiPriceSmoothingMethod,RsiSmoothingFactor,RsiType,WPFast,WPSlow,ChangeColorOn,alertsOn,alertsOnCurrent,alertsMessage,alertsPushNotif,alertsSound,alertsEmail,arrowsVisible,arrowsOnNewest,arrowsIdentifier,arrowsUpperGap,arrowsLowerGap,arrowsUpColor,arrowsDnColor,arrowsUpCode,arrowsDnCode,1,y);
         trend[i]     = iCustom(NULL,TimeFrame,indicatorFileName,PERIOD_CURRENT,RsiPeriod,RsiPrice,RsiPriceSmoothing,RsiPriceSmoothingMethod,RsiSmoothingFactor,RsiType,WPFast,WPSlow,ChangeColorOn,alertsOn,alertsOnCurrent,alertsMessage,alertsPushNotif,alertsSound,alertsEmail,arrowsVisible,arrowsOnNewest,arrowsIdentifier,arrowsUpperGap,arrowsLowerGap,arrowsUpColor,arrowsDnColor,arrowsUpCode,arrowsDnCode,7,y);
         
          //
          //
          //
          //
          //
            
          if (!Interpolate || (i>0 &&y==iBarShift(NULL,TimeFrame,Time[i-1]))) continue;

          //
          //
          //
          //
          //

          int n,s; datetime time = iTime(NULL,TimeFrame,y);
             for(n = 1; i+n<Bars && Time[i+n] >= time; n++) continue;
             for(s = 1; i+n<Bars && i+s<Bars && s<n; s++) 
             {
  	             RsiMa[i+s]     = RsiMa[i]     + (RsiMa[i+n]     - RsiMa[i])     * s/n;
  	             TrendSlow[i+s] = TrendSlow[i] + (TrendSlow[i+n] - TrendSlow[i]) * s/n;
  	             TrendFast[i+s] = TrendFast[i] + (TrendFast[i+n] - TrendFast[i]) * s/n;
             }
   }
   for(i=limit; i>=0; i--)
   {
      RsiMada[i] = EMPTY_VALUE;
      RsiMadb[i] = EMPTY_VALUE;
      RsiMaua[i] = EMPTY_VALUE;
      RsiMaub[i] = EMPTY_VALUE;
         if (trend[i]==-1) PlotPoint(i,RsiMada,RsiMadb,RsiMa);
         if (trend[i]== 1) PlotPoint(i,RsiMaua,RsiMaub,RsiMa);
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

string rsiMethodNames[] = {"RSI","Slow RSI","Rapid RSI","Harris RSI","RSX","Cuttler RSI"};
string getRsiName(int method)
{
   int max = ArraySize(rsiMethodNames)-1;
      method=MathMax(MathMin(method,max),0); return(rsiMethodNames[method]);
}

//
//
//
//
//

double workRsi[][13];
#define _price  0
#define _change 1
#define _changa 2
#define _rsival 1
#define _rsval  1

double iRsi(double price, double period, int rsiMode, int i, int instanceNo=0)
{
   if (ArrayRange(workRsi,0)!=Bars) ArrayResize(workRsi,Bars);
      int z = instanceNo*13; 
      int r = Bars-i-1;
   
   //
   //
   //
   //
   //
   
   workRsi[r][z+_price] = price;
   switch (rsiMode)
   {
      case 0:
         {
         double alpha = 1.0/MathMax(period,1); 
         if (r<period)
            {
               int k; double sum = 0; for (k=0; k<period && (r-k-1)>=0; k++) sum += MathAbs(workRsi[r-k][z+_price]-workRsi[r-k-1][z+_price]);
                  workRsi[r][z+_change] = (workRsi[r][z+_price]-workRsi[0][z+_price])/MathMax(k,1);
                  workRsi[r][z+_changa] =                                         sum/MathMax(k,1);
            }
         else
            {
               double change = workRsi[r][z+_price]-workRsi[r-1][z+_price];
                               workRsi[r][z+_change] = workRsi[r-1][z+_change] + alpha*(        change  - workRsi[r-1][z+_change]);
                               workRsi[r][z+_changa] = workRsi[r-1][z+_changa] + alpha*(MathAbs(change) - workRsi[r-1][z+_changa]);
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
      
      case 1 :
         {         
            double up = 0;
            double dn = 0;
            for(int k=0; k<(int)period && (r-k-1)>=0; k++)
            {
               double diff = workRsi[r-k][z+_price]- workRsi[r-k-1][z+_price];
               if(diff>0)
                     up += diff;
               else  dn -= diff;
            }
            if(up + dn == 0)
                  workRsi[r][z+_rsival] = workRsi[r-1][z+_rsival]+(1/MathMax(period,1))*(50            -workRsi[r-1][z+_rsival]);
            else  workRsi[r][z+_rsival] = workRsi[r-1][z+_rsival]+(1/MathMax(period,1))*(100*up/(up+dn)-workRsi[r-1][z+_rsival]);
            return(workRsi[r][z+_rsival]);      
         }
      
      //
      //
      //
      //
      //

      case 2 :
         {
            double up = 0;
            double dn = 0;
            for(int k=0; k<(int)period && (r-k-1)>=0; k++)
            {
               double diff = workRsi[r-k][z+_price]- workRsi[r-k-1][z+_price];
               if(diff>0)
                     up += diff;
               else  dn -= diff;
            }
            if(up + dn == 0)
                  return(50);
            else  return(100 * up / (up + dn));      
         }            

      //
      //
      //
      //
      //

      
      case 3 :
         {
            double avgUp=0,avgDn=0; double up=0; double dn=0;
            for(int k=0; k<(int)period && (r-k-1)>=0; k++)
            {
               double diff = workRsi[r-k][instanceNo+_price]- workRsi[r-k-1][instanceNo+_price];
               if(diff>0)
                     { avgUp += diff; up++; }
               else  { avgDn -= diff; dn++; }
            }
            if (up!=0) avgUp /= up;
            if (dn!=0) avgDn /= dn;
            double rs = 1;
               if (avgDn!=0) rs = avgUp/avgDn;
               return(100-100/(1.0+rs));
         }               

      //
      //
      //
      //
      //
      
      case 4 :  
         {   
            double Kg = (3.0)/(2.0+period), Hg = 1.0-Kg;
            if (r<period) { for (int k=1; k<13; k++) workRsi[r][k+z] = 0; return(50); }  

            //
            //
            //
            //
            //
      
            double mom = workRsi[r][_price+z]-workRsi[r-1][_price+z];
            double moa = MathAbs(mom);
            for (int k=0; k<3; k++)
            {
               int kk = k*2;
               workRsi[r][z+kk+1] = Kg*mom                + Hg*workRsi[r-1][z+kk+1];
               workRsi[r][z+kk+2] = Kg*workRsi[r][z+kk+1] + Hg*workRsi[r-1][z+kk+2]; mom = 1.5*workRsi[r][z+kk+1] - 0.5 * workRsi[r][z+kk+2];
               workRsi[r][z+kk+7] = Kg*moa                + Hg*workRsi[r-1][z+kk+7];
               workRsi[r][z+kk+8] = Kg*workRsi[r][z+kk+7] + Hg*workRsi[r-1][z+kk+8]; moa = 1.5*workRsi[r][z+kk+7] - 0.5 * workRsi[r][z+kk+8];
            }
            if (moa != 0)
                 return(MathMax(MathMin((mom/moa+1.0)*50.0,100.00),0.00)); 
            else return(50);
         }            
            
      //
      //
      //
      //
      //
      
      case 5 :
         {
            double sump = 0;
            double sumn = 0;
            for (int k=0; k<(int)period && r-k-1>=0; k++)
            {
               double diff = workRsi[r-k][z+_price]-workRsi[r-k-1][z+_price];
                  if (diff > 0) sump += diff;
                  if (diff < 0) sumn -= diff;
            }
            if (sumn > 0)
                  return(100.0-100.0/(1.0+sump/sumn));
            else  return(50);
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
//

double workHa[][4];
double getPrice(int price, const double& open[], const double& close[], const double& high[], const double& low[], int i, int instanceNo=0)
{
  if (price>=pr_haclose && price<=pr_hatbiased)
   {
      if (ArrayRange(workHa,0)!= Bars) ArrayResize(workHa,Bars);
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
         
         switch (price)
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
         }
   }
   
   //
   //
   //
   //
   //
   
   switch (price)
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

void doAlert(int forBar, string doWhat) 
{
   static string   previousAlert="nothing";
   static datetime previousTime;
   string message;
   
   if (previousAlert != doWhat || previousTime != Time[forBar]) {
       previousAlert  = doWhat;
       previousTime   = Time[forBar];

       message =  StringConcatenate(Symbol()," ",timeFrameToString(_Period)," at ",TimeToStr(TimeLocal(),TIME_SECONDS)," QQE trend changed to ",doWhat);
          if (alertsMessage)   Alert(message);
          if (alertsEmail)     SendMail(StringConcatenate(Symbol(),"QQE"),message);
          if (alertsPushNotif) SendNotification(message);
          if (alertsSound)     PlaySound("alert2.wav");
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

void drawArrow(int i,color theColor,int theCode,bool up)
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
         ObjectSet(name,OBJPROP_COLOR,theColor);
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
            { first[i]  = from[i];  first[i+1]  = from[i+1]; second[i] = EMPTY_VALUE; }
      else  { second[i] =  from[i]; second[i+1] = from[i+1]; first[i]  = EMPTY_VALUE; }
   else     { first[i]  = from[i];                           second[i] = EMPTY_VALUE; }
}