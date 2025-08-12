//------------------------------------------------------------------
#property copyright   "mladen"
#property link        "www.forex-station.com"
//------------------------------------------------------------------
#property indicator_separate_window
#property indicator_buffers 10
#property indicator_color1  clrSilver
#property indicator_color2  clrSilver
#property indicator_color3  clrSilver
#property indicator_color4  clrSilver
#property indicator_color5  clrDimGray
#property indicator_color6  clrDimGray
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
enum enMaTypes
{
   ma_sma,    // Simple moving average
   ma_ema,    // Exponential moving average
   ma_smma,   // Smoothed MA
   ma_lwma    // Linear weighted MA
};
enum enFilterWhat
{
   flt_prc,  // Filter the price
   flt_val,  // Filter the ADXm value
   flt_both  // Filter both
};
enum enColorOn
{
   cc_onSlope,   // Change color on slope change
   cc_onMiddle,  // Change color on middle line cross
   cc_onLevels   // Change color on outer levels cross
};
enum enLevelType
{
   lvl_floa,  // Floating levels
   lvl_quan   // Quantile levels
};

extern ENUM_TIMEFRAMES TimeFrame         = PERIOD_CURRENT; // Time frame
extern string          ForSymbol         = "";             // For symbol (leave empty for current chart symbol)
extern int             AdxmPeriod        = 14;             // Adxm period
extern enPrices        AdxmPriceC        = pr_close;       // Price for close
extern enPrices        AdxmPriceH        = pr_high;        // Price for high
extern enPrices        AdxmPriceL        = pr_low;         // Price for low
extern int             PriceSmoothing    = -1;             // Price smoothing (-1 same as adxm period, 0 no smoothing)
extern enMaTypes       PriceMaType       = ma_ema;         // Price smoothing method
extern double          Filter            = 0;              // Filter to use (<= 0 no filter)
extern enFilterWhat    FilterOn          = flt_prc;        // Apply filter to :
extern int             FilterPeriod      =  0;             // Filter period (<=0 use ADXm period)
extern enLevelType     LevelsType        = lvl_floa;       // Levels type
extern int             LevelsPeriod      = 25;             // Levels period
extern double          LevelsUp          = 80;             // Upper level %
extern double          LevelsDown        = 20;             // Lower level %
extern bool            AlertsOn          = false;          // Turn alerts on?
extern bool            AlertsOnCurrent   = true;           // Alerts on current (still opened) bar?
extern bool            AlertsMessage     = true;           // Alerts should show pop-up message?
extern bool            AlertsSound       = false;          // Alerts should play alert sound?
extern bool            AlertsPushNotif   = false;          // Alerts should send push notification?
extern bool            AlertsEmail       = false;          // Alerts should send email?
extern enColorOn       ColorOn           = cc_onLevels;    // Color change on :
extern bool            arrowsVisible     = false;          // Arrows visible?
extern bool            arrowsOnNewest    = false;          // Arrows drawn on newst bar of higher time frame bar?
extern string          arrowsIdentifier  = "adxm Arrows1"; // Unique ID for arrows
extern double          arrowsUpperGap    = 1.0;            // Upper arrow gap
extern double          arrowsLowerGap    = 1.0;            // Lower arrow gap
extern color           arrowsUpColor     = clrLimeGreen;   // Up arrow color
extern color           arrowsDnColor     = clrOrange;      // Down arrow color
extern int             arrowsUpCode      = 241;            // Up arrow code
extern int             arrowsDnCode      = 242;            // Down arrow code
extern int             arrowsSize        = 0;              // Arrows size
extern color           ColorUp           = clrDodgerBlue;  // Color for up
extern color           ColorDown         = clrSandyBrown;  // Color for down
extern int             LineWidth         = 3;              // Main line width
extern int             ShadowWidth       = 0;              // Shadow width (<=0 main line width+3)
extern bool            Interpolate       = true;           // Interpolate in multi time frame?

//
//
//
//
//

double val[],valUa[],valUb[],valDa[],valDb[],levup[],levmi[],levdn[],trend[],shadowa[],shadowb[];
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
   int shadowWidth = (ShadowWidth<=0) ? LineWidth+3 : ShadowWidth;
      IndicatorBuffers(11);
         SetIndexBuffer(0,levup);
         SetIndexBuffer(1,levmi);
         SetIndexBuffer(2,levdn);
         SetIndexBuffer(3,val);     SetIndexStyle(3,EMPTY,EMPTY,LineWidth);
         SetIndexBuffer(4,shadowa); SetIndexStyle(4,EMPTY,EMPTY,shadowWidth);
         SetIndexBuffer(5,shadowb); SetIndexStyle(5,EMPTY,EMPTY,shadowWidth);
         SetIndexBuffer(6,valUa);   SetIndexStyle(6,EMPTY,EMPTY,LineWidth,ColorUp);
         SetIndexBuffer(7,valUb);   SetIndexStyle(7,EMPTY,EMPTY,LineWidth,ColorUp);
         SetIndexBuffer(8,valDa);   SetIndexStyle(8,EMPTY,EMPTY,LineWidth,ColorDown);
         SetIndexBuffer(9,valDb);   SetIndexStyle(9,EMPTY,EMPTY,LineWidth,ColorDown);
         SetIndexBuffer(10,trend); 
  
       //
       //
       //
       //
       //
      
       indicatorFileName = WindowExpertName();
       returnBars        = (TimeFrame==-99);
       TimeFrame         = MathMax(TimeFrame,_Period);
              if (ForSymbol=="") ForSymbol = _Symbol;
   IndicatorShortName(ForSymbol+" "+timeFrameToString(TimeFrame)+" ADXm ("+(string)AdxmPeriod+","+(string)Filter+","+(string)PriceSmoothing+" filter : "+(string)Filter+")");
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

int start()
{
   int counted_bars=IndicatorCounted();
      if(counted_bars<0) return(-1);
      if(counted_bars>0) counted_bars--;
         int limit = MathMin(Bars-counted_bars,Bars-1);
            if (returnBars) { levup[0] = limit+1; return(0); }
            if (TimeFrame != _Period || ForSymbol!=_Symbol)
            {
               #define _mtfCall(_buff) iCustom(ForSymbol,TimeFrame,indicatorFileName,PERIOD_CURRENT,"",AdxmPeriod,AdxmPriceC,AdxmPriceH,AdxmPriceL,PriceSmoothing,PriceMaType,Filter,FilterOn,FilterPeriod,LevelsType,LevelsPeriod,LevelsUp,LevelsDown,AlertsOn,AlertsOnCurrent,AlertsMessage,AlertsSound,AlertsPushNotif,AlertsEmail,ColorOn,arrowsVisible,arrowsOnNewest,arrowsIdentifier,arrowsUpperGap,arrowsLowerGap,arrowsUpColor,arrowsDnColor,arrowsUpCode,arrowsDnCode,arrowsSize,_buff,y);
               limit = (int)MathMax(limit,MathMin(Bars-1,iCustom(ForSymbol,TimeFrame,indicatorFileName,-99,0,0)*TimeFrame/_Period)); 
               if (trend[limit]== 1) { CleanPoint(limit,valUa,valUb); CleanPoint(limit,shadowa,shadowb); }
               if (trend[limit]==-1) { CleanPoint(limit,valDa,valDb); CleanPoint(limit,shadowa,shadowb); }
               for(int i=limit; i>=0; i--)
               {
                  int y = iBarShift(ForSymbol,TimeFrame,Time[i]);
                     levup[i]   = _mtfCall( 0);
                     levmi[i]   = _mtfCall( 1);
                     levdn[i]   = _mtfCall( 2);
                     val[i]     = _mtfCall( 3);
                     trend[i]   = _mtfCall(10);
                     valDa[i]   = EMPTY_VALUE;
                     valDb[i]   = EMPTY_VALUE;
                     valUa[i]   = EMPTY_VALUE;
                     valUb[i]   = EMPTY_VALUE;
                     shadowa[i] = EMPTY_VALUE;
                     shadowb[i] = EMPTY_VALUE;
                     
                     //
                     //
                     //
                     //
                     //
                     
                     if (!Interpolate || (i>0 && y==iBarShift(NULL,TimeFrame,Time[i-1]))) continue;
                        #define _interpolate(buff) buff[i+k] = buff[i]+(buff[i+n]-buff[i])*k/n
                        int n,k; datetime time = iTime(NULL,TimeFrame,y);
                           for(n = 1; (i+n)<Bars && Time[i+n] >= time; n++) continue;	
                           for(k = 1; k<n && (i+n)<Bars && (i+k)<Bars; k++) 
                           {
                              _interpolate(levup);
                              _interpolate(levmi);
                              _interpolate(levdn);
                              _interpolate(val);
                        }                           
               }
               for(int i=limit; i>=0; i--)
               {
                  if (trend[i] ==  1) { PlotPoint(i,valUa,valUb,val); PlotPoint(i,shadowa,shadowb,val); }
                  if (trend[i] == -1) { PlotPoint(i,valDa,valDb,val); PlotPoint(i,shadowa,shadowb,val); }
               }
               return(0);
            }

   //
   //
   //
   //
   //

   int    speriod = (PriceSmoothing<0)  ? AdxmPeriod : PriceSmoothing;
   int    tperiod = (FilterPeriod<=0)   ? AdxmPeriod : FilterPeriod;
   double pfilter = (FilterOn==flt_prc) ? Filter : 0;
   double vfilter = (FilterOn==flt_val) ? Filter : 0;
   int    colorOn = (LevelsPeriod>0) ? ColorOn : cc_onSlope;
      if (trend[limit]== 1) { CleanPoint(limit,valUa,valUb); CleanPoint(limit,shadowa,shadowb); }
      if (trend[limit]==-1) { CleanPoint(limit,valDa,valDb); CleanPoint(limit,shadowa,shadowb); }
      for(int i=limit; i>=0; i--)
      {
         double prices[3],tdi=0,tadx=0;
            prices[0] = iCustomMa(PriceMaType,iFilter(getPrice(AdxmPriceC,Open,Close,High,Low,i,0),pfilter,tperiod,i,Bars,0),speriod,i,0);
            prices[1] = iCustomMa(PriceMaType,iFilter(getPrice(AdxmPriceH,Open,Close,High,Low,i,1),pfilter,tperiod,i,Bars,1),speriod,i,1);
            prices[2] = iCustomMa(PriceMaType,iFilter(getPrice(AdxmPriceL,Open,Close,High,Low,i,2),pfilter,tperiod,i,Bars,2),speriod,i,2);
               ArraySort(prices);
               iAdxm(prices[1],prices[2],prices[0],tperiod,tdi,tadx,i,Bars);
                  val[i]     = iFilter(tadx,vfilter,tperiod,i,Bars,3);
                  valDa[i]   = EMPTY_VALUE;
                  valDb[i]   = EMPTY_VALUE;
                  valUa[i]   = EMPTY_VALUE;
                  valUb[i]   = EMPTY_VALUE;
                  shadowa[i] = EMPTY_VALUE;
                  shadowb[i] = EMPTY_VALUE;
         
            //
            //
            //
            //
            //
            
            double hi = val[i]; double lo = val[i];
            if (LevelsType==lvl_floa)
               {
                  if (LevelsPeriod>0)
                  {
                     hi = val[ArrayMaximum(val,LevelsPeriod,i)];
                     lo = val[ArrayMinimum(val,LevelsPeriod,i)];
                     hi = lo+(hi-lo)*LevelsUp  /100.0;
                     lo = lo+(hi-lo)*LevelsDown/100.0;
                  }                     
                  levup[i] = hi;
                  levdn[i] = lo;
                  levmi[i] = (levup[i]+levdn[i])/2.0;
               }
            else
               {
                  levup[i] = iQuantile(val[i],LevelsPeriod, LevelsUp  ,i,Bars);
                  levdn[i] = iQuantile(val[i],LevelsPeriod, LevelsDown,i,Bars);
                  levmi[i] = iQuantile(val[i],LevelsPeriod,(LevelsDown+LevelsUp)/2,i,Bars);
               }                                 

         switch(colorOn)
         {
            case cc_onLevels:         trend[i] = (val[i]>levup[i]) ? 1 : (val[i]<levdn[i]) ? -1 : 0; break;
            case cc_onMiddle:         trend[i] = (val[i]>levmi[i]) ? 1 : (val[i]<levmi[i]) ? -1 : 0; break;
            default :  if (i<Bars-1)  trend[i] = (val[i]>val[i+1]) ? 1 : (val[i]<val[i+1]) ? -1 : trend[i+1];
         }                  
         if (trend[i] ==  1) { PlotPoint(i,valUa,valUb,val); PlotPoint(i,shadowa,shadowb,val); }
         if (trend[i] == -1) { PlotPoint(i,valDa,valDb,val); PlotPoint(i,shadowa,shadowb,val); }
         
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
               if (trend[i] == 1) drawArrow(i,arrowsUpColor,arrowsUpCode,false);
               if (trend[i] ==-1) drawArrow(i,arrowsDnColor,arrowsDnCode, true);
            }
         }
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

#define _adxmInstances     1
#define _adxmInstancesSize 8
double  _adxmWork[][_adxmInstances*_adxmInstancesSize];
#define _adxmSdh   0
#define _adxmSdl   1
#define _adxmSdx   2
#define _adxmClose 3
#define _adxmHigh  4
#define _adxmLow   5
#define _adxmDi    6
#define _adxmAdx   7

void iAdxm(double pclose, double phigh, double plow, double cperiod, double& _di, double& _adx, int i, int bars, int instanceNo=0)
{
   if (ArrayRange(_adxmWork,0)!=bars) ArrayResize(_adxmWork,bars); instanceNo*=_adxmInstancesSize; i=bars-i-1;

      _adxmWork[i][instanceNo+_adxmClose]=pclose;
      _adxmWork[i][instanceNo+_adxmHigh] =phigh;
      _adxmWork[i][instanceNo+_adxmLow]  =plow;
         
         //
         //
         //
         //
         //
         
         double hc = _adxmWork[i][instanceNo+_adxmHigh];
         double lc = _adxmWork[i][instanceNo+_adxmLow ];
         double cp = (i>0) ? _adxmWork[i-1][instanceNo+_adxmClose] : _adxmWork[i][instanceNo+_adxmClose];
         double hp = (i>0) ? _adxmWork[i-1][instanceNo+_adxmHigh ] : _adxmWork[i][instanceNo+_adxmHigh ];
         double lp = (i>0) ? _adxmWork[i-1][instanceNo+_adxmLow  ] : _adxmWork[i][instanceNo+_adxmLow  ];
         double dh = MathMax(hc-hp,0);
         double dl = MathMax(lp-lc,0);

            if(dh==dl) {dh=0; dl=0;} else if(dh<dl) dh=0; else if(dl<dh) dl=0;
            
         double tr    = MathMax(hc,cp)-MathMin(lc,cp);
         double dhk   = (tr!=0) ? 100.0*dh/tr : 0;
         double dlk   = (tr!=0) ? 100.0*dl/tr : 0;
         double alpha = 2.0/(cperiod+1.0);

            _adxmWork[i][instanceNo+_adxmSdh] = (i>0) ? _adxmWork[i-1][instanceNo+_adxmSdh] + alpha*(dhk-_adxmWork[i-1][instanceNo+_adxmSdh]) : dhk;
            _adxmWork[i][instanceNo+_adxmSdl] = (i>0) ? _adxmWork[i-1][instanceNo+_adxmSdl] + alpha*(dlk-_adxmWork[i-1][instanceNo+_adxmSdl]) : dlk;
            _adxmWork[i][instanceNo+_adxmDi]  = _adxmWork[i][instanceNo+_adxmSdh] - _adxmWork[i][instanceNo+_adxmSdl];

         double div  = MathAbs(_adxmWork[i][instanceNo+_adxmSdh] + _adxmWork[i][instanceNo+_adxmSdl]);
         double temp = (div!=0.0) ? 100*_adxmWork[i][instanceNo+_adxmDi]/div : 0; 
 
           _adxmWork[i][instanceNo+_adxmAdx] = (i>0) ? _adxmWork[i-1][instanceNo+_adxmAdx]+alpha*(temp-_adxmWork[i-1][instanceNo+_adxmAdx]) : 0;
 
         //
         //
         //
         //
         //
         
      _di  = _adxmWork[i][instanceNo+_adxmDi];
      _adx = _adxmWork[i][instanceNo+_adxmAdx];
   return;
}

//-------------------------------------------------------------------
//                                                                  
//-------------------------------------------------------------------
//
//
//
//
//

#define _filterInstances 4
#define _filterSize 3
double workFil[][_filterInstances*_filterSize];

#define _fchange 0
#define _fachang 1
#define _fprice  2

double iFilter(double tprice, double filter, int period, int i, int bars, int instanceNo=0)
{
   if (filter<=0 || period==0) return(tprice); i=bars-i-1;
   if (ArrayRange(workFil,0)!= bars) ArrayResize(workFil,bars); instanceNo*=_filterSize;
   
   //
   //
   //
   //
   //
   
   workFil[i][instanceNo+_fprice]  = tprice; if (i<1) return(tprice);
   workFil[i][instanceNo+_fchange] = MathAbs(workFil[i][instanceNo+_fprice]-workFil[i-1][instanceNo+_fprice]);
   workFil[i][instanceNo+_fachang] = workFil[i][instanceNo+_fchange];
      for (int k=1; k<period && (i-k)>=0; k++) workFil[i][instanceNo+_fachang] += workFil[i-k][instanceNo+_fchange];  workFil[i][instanceNo+_fachang] /= period;
      double _val = 0;  for (int k=0;  k<period && (i-k)>=0; k++) _val += MathPow(workFil[i-k][instanceNo+_fchange]-workFil[i-k][instanceNo+_fachang],2); _val  = filter*MathSqrt(_val/(double)period); 
            if( MathAbs(workFil[i][instanceNo+_fprice]-workFil[i-1][instanceNo+_fprice]) < _val ) workFil[i][instanceNo+_fprice]=workFil[i-1][instanceNo+_fprice];
   return(workFil[i][instanceNo+_fprice]);
}

//-------------------------------------------------------------------
//                                                                  
//-------------------------------------------------------------------
//
//
//
//
//

#define _quantileInstances 1
double _sortQuant[];
double _workQuant[][_quantileInstances];

double iQuantile(double value, int period, double qp, int i, int bars, int instanceNo=0)
{
   if (period<1) return(value);
   if (ArrayRange(_workQuant,0)!=bars) ArrayResize(_workQuant,bars); 
   if (ArraySize(_sortQuant)!=period)  ArrayResize(_sortQuant,period); 
            i=bars-i-1; _workQuant[i][instanceNo]=value;
            int k=0; for (; k<period && (i-k)>=0; k++) _sortQuant[k] = _workQuant[i-k][instanceNo];
                     for (; k<period            ; k++) _sortQuant[k] = 0;
                     ArraySort(_sortQuant);

   //
   //
   //
   //
   //
   
   double index = (period-1.0)*qp/100.00;
   int    ind   = (int)index;
   double delta = index - ind;
   if (ind == NormalizeDouble(index,5))
         return(            _sortQuant[ind]);
   else  return((1.0-delta)*_sortQuant[ind]+delta*_sortQuant[ind+1]);
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

#define _priceInstances 3
#define _priceSize 4
double workHa[][_priceInstances*_priceSize];
double getPrice(int tprice, const double& open[], const double& close[], const double& high[], const double& low[], int i, int instanceNo=0)
{
  if (tprice>=pr_haclose)
   {
      if (ArrayRange(workHa,0)!= Bars) ArrayResize(workHa,Bars); instanceNo*=_priceSize; int r = Bars-i-1;
         
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

void manageAlerts()
{
   if (AlertsOn)
   {
      int whichBar = 1; if (AlertsOnCurrent) whichBar = 0;
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

       message = timeFrameToString(_Period)+" "+_Symbol+" at "+TimeToStr(TimeLocal(),TIME_SECONDS)+" ADXm state changed to "+doWhat;
          if (AlertsMessage)   Alert(message);
          if (AlertsEmail)     SendMail(_Symbol+" ADXm",message);
          if (AlertsPushNotif) SendNotification(message);
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

#define _maInstances 3
#define _maWorkBufferx1 1*_maInstances
#define _maWorkBufferx2 2*_maInstances

string averageName(int mode)
{
   switch (mode)
   {
      case ma_sma   : return("SMA");
      case ma_ema   : return("EMA");
      case ma_smma  : return("SMMA");
      case ma_lwma  : return("LWMA");
   }
   return("");
}
double iCustomMa(int mode, double price, double length, int r, int instanceNo=0)
{
   r = Bars-r-1;
   switch (mode)
   {
      case ma_sma   : return(iSma(price,(int)length,r,instanceNo));
      case ma_ema   : return(iEma(price,length,r,instanceNo));
      case ma_smma  : return(iSmma(price,length,r,instanceNo));
      case ma_lwma  : return(iLwma(price,(int)length,r,instanceNo));
      default       : return(price);
   }
}

//
//
//
//
//

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
   if (ArrayRange(workEma,0)!= Bars) ArrayResize(workEma,Bars);

   //
   //
   //
   //
   //
      
   workEma[r][instanceNo] = price;
   if (r>0 && period>1)
          workEma[r][instanceNo] = workEma[r-1][instanceNo]+(2.0 / (1.0+period))*(price-workEma[r-1][instanceNo]);
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

   workSmma[r][instanceNo] = price;
   if (r>0 && period>1)
          workSmma[r][instanceNo] = workSmma[r-1][instanceNo]+(price-workSmma[r-1][instanceNo])/period;
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
   if (ArrayRange(workLwma,0)!= Bars) ArrayResize(workLwma,Bars);
   
   //
   //
   //
   //
   //
   
   period = MathMax(period,1);
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

string sTfTable[] = {"M1","M5","M15","M30","H1","H4","D1","W1","MN"};
int    iTfTable[] = {1,5,15,30,60,240,1440,10080,43200};

string timeFrameToString(int tf)
{
   for (int i=ArraySize(iTfTable)-1; i>=0; i--) 
         if (tf==iTfTable[i]) return(sTfTable[i]);
                              return("");
}

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
         ObjectSet(name,OBJPROP_WIDTH,arrowsSize);
         ObjectSet(name,OBJPROP_COLOR,theColor);
         if (up)
               ObjectSet(name,OBJPROP_PRICE1,High[i] + arrowsUpperGap * gap);
         else  ObjectSet(name,OBJPROP_PRICE1,Low[i]  - arrowsLowerGap * gap);
}
