//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "www,forex-tsd.com"
#property link      "www,forex-tsd.com"

#property indicator_separate_window
#property indicator_buffers    4
#property indicator_color1     MediumSeaGreen
#property indicator_color2     MediumSeaGreen
#property indicator_color3     DeepSkyBlue
#property indicator_color4     Red
#property indicator_style4     STYLE_DASH
#property indicator_width3     1
#property indicator_levelcolor MediumOrchid

//
//
//
//
//

#import "libSSA.dll"
   void fastSingular(double& sourceArray[],int arraySize, int lag, int numberOfComputationLoops, double& destinationArray[]);
#import

//
//
//
//
//

extern string TimeFrame                     = "Current time frame";
extern int    SSAPrice                      = PRICE_CLOSE;
extern int    SSALag                        = 10;
extern int    SSANumberOfComputations       = 2;
extern int    SSAPeriodNormalization        = 20;
extern int    SSANumberOfBars               = 500;
extern int    SSABarsToCalculate            = 250;
extern int    RsiPriceLinePeriod            = 2;
extern int    RsiPriceLineMAMode            = MODE_LWMA;
extern int    RsiSignalLinePeriod           = 7;
extern int    RsiSignalLineMAMode           = MODE_LWMA;
extern int    VolatilityBandPeriod          = 10;
extern int    VolatilityBandMAMode          = MODE_LWMA;
extern double ConfidenceLevel               = 98;
extern int    ConfidenceBandsShift          = 0;
extern double LevelDown                     = -0.40;
extern double LevelMiddle                   = 0.0;
extern double LevelUp                       = 0.40;
extern bool   Interpolate                   = true;

extern bool   alertsOn                      = false;
extern bool   alertsOnZeroCross             = true;
extern bool   alertsOnRsiSignalCross        = true;
extern bool   alertsOnCurrent               = false;
extern bool   alertsMessage                 = true;
extern bool   alertsSound                   = false;
extern bool   alertsEmail                   = false;

extern bool   arrowsVisible                 = true;
extern double arrowsDisplacement            = 1.0;
extern string arrowsIdentifier              = "tdi ssa arrows";

extern bool   arrowsOnZeroCross             = true;
extern color  arrowsOnZeroCrossUpColor      = Lime;
extern color  arrowsOnZeroCrossDnColor      = Red;
extern int    arrowsOnZeroCrossUpCode       = 233;
extern int    arrowsOnZeroCrossDnCode       = 234;
extern int    arrowsOnZeroCrossUpSize       = 1;
extern int    arrowsOnZeroCrossDnSize       = 1;

extern bool   arrowsOnRsiSignalCross        = false;
extern color  arrowsOnRsiSignalCrossUpColor = Yellow;
extern color  arrowsOnRsiSignalCrossDnColor = Magenta;
extern int    arrowsOnRsiSignalCrossUpCode  = 119;
extern int    arrowsOnRsiSignalCrossDnCode  = 222;
extern int    arrowsOnRsiSignalCrossUpSize  = 1;
extern int    arrowsOnRsiSignalCrossDnSize  = 1;

//
//
//
//
//

double bandUp[];
double bandDown[];
double rsiPriceLine[];
double rsiSignalLine[];
double in[];
double no[];
double avg[];
double trend[];
double ssaIn[];
double ssaOut[];

double trends[][2];
#define _tzl 0
#define _tcr 1

//
//
//
//
//

string indicatorFileName;
bool   calculateValue;
bool   returnBars;
int    timeFrame;
double ConfidenceZ;

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//
//
//
//
//

int init() 
{
   IndicatorBuffers(7);
   SetIndexBuffer(0,bandUp);
   SetIndexBuffer(1,bandDown);
   SetIndexBuffer(2,rsiPriceLine);
   SetIndexBuffer(3,rsiSignalLine);
   SetIndexBuffer(4,in);
   SetIndexBuffer(5,no);
   SetIndexBuffer(6,avg);
   
       ConfidenceLevel = MathMax(MathMin(ConfidenceLevel,99.9999999999),0.0000000001);
       ConfidenceZ = NormalCDFInverse((ConfidenceLevel+(100-ConfidenceLevel)/2.0)/100.0);
   

      //
      //
      //
      //
      //

      indicatorFileName = WindowExpertName();
      calculateValue    = (TimeFrame=="calculateValue"); if (calculateValue) return(0);
      returnBars        = (TimeFrame=="returnBars");     if (returnBars)     return(0);
      timeFrame         = stringToTimeFrame(TimeFrame);

      //
      //
      //
      //
      //
      
   SetLevelValue(0,LevelUp);
   SetLevelValue(1,LevelMiddle);
   SetLevelValue(2,LevelDown);
   IndicatorShortName(timeFrameToString(timeFrame)+"  Traders dynamic cb ssa norm index");
   return (0);
}

//
//
//
//
//

int deinit() { if (!calculateValue && arrowsVisible) deleteArrows();  return(0);}
  
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
   int counted_bars=IndicatorCounted();
   int i,r,n,k,limit;

   if(counted_bars<0) return(-1);
   if(counted_bars>0) counted_bars--;
         limit = MathMin(Bars-counted_bars,Bars-1);
         if (returnBars) { bandUp[0] = limit+1; return(0); }

   //
   //
   //
   //
   //

   if (calculateValue || timeFrame == Period())
   {
      int ssaBars = MathMin(Bars-1,SSANumberOfBars);
      for(i=limit, r=Bars-i-1; i>=0; i--, r++)
      { 
      if (ArrayRange(trends,0)!=Bars) ArrayResize(trends,Bars); 
       
         double ma    = iMA(NULL,0,SSAPeriodNormalization,0,MODE_SMA,SSAPrice,i);
         double dev   = iStdDev(NULL,0,SSAPeriodNormalization,0,MODE_SMA,SSAPrice,i)*3.0;
         double price = iMA(NULL,0,1,0,MODE_SMA,SSAPrice,i);
                no[i] = (price-ma)/(MathMax(dev,0.000001));
                if (i<SSABarsToCalculate)
                {
                  if (ArraySize(ssaIn) != ssaBars)
                  {
                     ArrayResize(ssaIn ,ssaBars);
                     ArrayResize(ssaOut,ssaBars);
                  }
                  ArrayCopy(ssaIn,no,0,i,ssaBars);
                     fastSingular(ssaIn,ssaBars,SSALag,SSANumberOfComputations,ssaOut);
                  in[i] = ssaOut[0];
               }                  
         }                  
                     
         //
         //
         //
         //
         //
           
         for(i=ssaBars, r=Bars-i-1; i>=0; i--, r++)
         {
             rsiPriceLine[i]  = iMAOnArray(in,0, RsiPriceLinePeriod,  0, RsiPriceLineMAMode,  i);
             rsiSignalLine[i] = iMAOnArray(in,0, RsiSignalLinePeriod, 0, RsiSignalLineMAMode, i);
             avg[i]           = iMAOnArray(in,0, VolatilityBandPeriod,0, VolatilityBandMAMode,i);
             double deviation = iDeviation(in,VolatilityBandPeriod,avg[i+ConfidenceBandsShift],i+ConfidenceBandsShift);
             double me        = ConfidenceZ*deviation/MathSqrt(VolatilityBandPeriod);
             
                  bandUp[i]   = avg[i+ConfidenceBandsShift] + me;
                  bandDown[i] = avg[i+ConfidenceBandsShift] - me;
                  setTrends(i,r);
                  manageArrow(i,r);
         }
      manageAlerts();
      SetIndexDrawBegin(0,Bars-MathMin(ssaBars,SSABarsToCalculate)+SSAPeriodNormalization);
      SetIndexDrawBegin(1,Bars-MathMin(ssaBars,SSABarsToCalculate)+SSAPeriodNormalization);
      SetIndexDrawBegin(2,Bars-MathMin(ssaBars,SSABarsToCalculate)+SSAPeriodNormalization);
      SetIndexDrawBegin(3,Bars-MathMin(ssaBars,SSABarsToCalculate)+SSAPeriodNormalization);
      return (0);
   }      

   //
   //
   //
   //
   //

   limit = MathMin(Bars,SSANumberOfBars*timeFrame/Period());
   if (ArrayRange(trends,0)!=Bars) ArrayResize(trends,Bars);
             
    for(i=limit, r=Bars-i-1; i>=0; i--, r++)
    {
      int y = iBarShift(NULL,timeFrame,Time[i]);
         bandUp[i]        = iCustom(NULL,timeFrame,indicatorFileName,"calculateValue",SSAPrice,SSALag,SSANumberOfComputations,SSAPeriodNormalization,SSANumberOfBars,SSABarsToCalculate,RsiPriceLinePeriod,RsiPriceLineMAMode,RsiSignalLinePeriod,RsiSignalLineMAMode,VolatilityBandPeriod,VolatilityBandMAMode,ConfidenceLevel,ConfidenceBandsShift,0,y);
         bandDown[i]      = iCustom(NULL,timeFrame,indicatorFileName,"calculateValue",SSAPrice,SSALag,SSANumberOfComputations,SSAPeriodNormalization,SSANumberOfBars,SSABarsToCalculate,RsiPriceLinePeriod,RsiPriceLineMAMode,RsiSignalLinePeriod,RsiSignalLineMAMode,VolatilityBandPeriod,VolatilityBandMAMode,ConfidenceLevel,ConfidenceBandsShift,1,y);
         rsiPriceLine[i]  = iCustom(NULL,timeFrame,indicatorFileName,"calculateValue",SSAPrice,SSALag,SSANumberOfComputations,SSAPeriodNormalization,SSANumberOfBars,SSABarsToCalculate,RsiPriceLinePeriod,RsiPriceLineMAMode,RsiSignalLinePeriod,RsiSignalLineMAMode,VolatilityBandPeriod,VolatilityBandMAMode,ConfidenceLevel,ConfidenceBandsShift,2,y);
         rsiSignalLine[i] = iCustom(NULL,timeFrame,indicatorFileName,"calculateValue",SSAPrice,SSALag,SSANumberOfComputations,SSAPeriodNormalization,SSANumberOfBars,SSABarsToCalculate,RsiPriceLinePeriod,RsiPriceLineMAMode,RsiSignalLinePeriod,RsiSignalLineMAMode,VolatilityBandPeriod,VolatilityBandMAMode,ConfidenceLevel,ConfidenceBandsShift,3,y);
         trend[i]         = iCustom(NULL,timeFrame,indicatorFileName,"calculateValue",SSAPrice,SSALag,SSANumberOfComputations,SSAPeriodNormalization,SSANumberOfBars,SSABarsToCalculate,RsiPriceLinePeriod,RsiPriceLineMAMode,RsiSignalLinePeriod,RsiSignalLineMAMode,VolatilityBandPeriod,VolatilityBandMAMode,ConfidenceLevel,ConfidenceBandsShift,7,y);
         
         setTrends(i,r);
         manageArrow(i,r);
         
         //
         //
         //
         //
         //
      
         if (!Interpolate || y==iBarShift(NULL,timeFrame,Time[i-1])) continue;

         //
         //
         //
         //
         //
         
         datetime time = iTime(NULL,timeFrame,y);
            for(n = 1; i+n < Bars && Time[i+n] >= time; n++) continue;	
            for(k = 1; k < n; k++)
            {
               bandUp[i+k]        = bandUp[i]        + (bandUp[i+n]        - bandUp[i]       ) * k/n;
               bandDown[i+k]      = bandDown[i]      + (bandDown[i+n]      - bandDown[i]     ) * k/n;
               rsiPriceLine[i+k]  = rsiPriceLine[i]  + (rsiPriceLine[i+n]  - rsiPriceLine[i] ) * k/n;
               rsiSignalLine[i+k] = rsiSignalLine[i] + (rsiSignalLine[i+n] - rsiSignalLine[i]) * k/n;
            }               
   }

   //
   //
   //
   //
   //
   
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

double iDeviation(double& array[], double period, double ma, int i, bool isSample=true)
{
   double sum = 0.00; for(int k=0; k<period; k++) sum += MathPow((array[i+k]-ma),2);
   if (isSample)      
         return(MathSqrt(sum/(period-1.0)));
   else  return(MathSqrt(sum/period));
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

//
//
//
//
//

int stringToTimeFrame(string tfs)
{
   tfs = stringUpperCase(tfs);
   for (int i=ArraySize(iTfTable)-1; i>=0; i--)
         if (tfs==sTfTable[i] || tfs==""+iTfTable[i]) return(MathMax(iTfTable[i],Period()));
                                                      return(Period());
}

//
//
//
//
//

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

string stringUpperCase(string str)
{
   string   s = str;

   for (int length=StringLen(str)-1; length>=0; length--)
   {
      int tchar = StringGetChar(s, length);
         if((tchar > 96 && tchar < 123) || (tchar > 223 && tchar < 256))
                     s = StringSetChar(s, length, tchar - 32);
         else if(tchar > -33 && tchar < 0)
                     s = StringSetChar(s, length, tchar + 224);
   }
   return(s);
}

//
//
//
//
//

//+-------------------------------------------------------------------
//|                                                                  
//+-------------------------------------------------------------------
//
//
//
//
//

void setTrends(int i, int r)
{
   trends[r][_tzl] = trends[r-1][_tzl];
   trends[r][_tcr] = trends[r-1][_tcr];
   
      if (rsiPriceLine[i] > 0)                trends[r][_tzl] =  1;
      if (rsiPriceLine[i] < 0)                trends[r][_tzl] = -1;
      if (rsiPriceLine[i] > rsiSignalLine[i]) trends[r][_tcr] =  1;
      if (rsiPriceLine[i] < rsiSignalLine[i]) trends[r][_tcr] = -1;
      
      
}

//+-------------------------------------------------------------------
//|                                                                  
//+-------------------------------------------------------------------
//
//
//
//
//

void manageAlerts()
{
   if (!calculateValue && alertsOn)
   {
      if (alertsOnCurrent)
           int whichBar = 0;
      else     whichBar = 1; whichBar = iBarShift(NULL,0,iTime(NULL,timeFrame,whichBar)); 
                             whichBar = Bars-whichBar-1;

      //
      //
      //
      //
      //
            
      static datetime time1 = 0;
      static string   mess1 = "";
      if (alertsOnZeroCross && trends[whichBar][_tzl] != trends[whichBar-1][_tzl])
      {
         if (trends[whichBar][_tzl] ==  1) doAlert(time1,mess1,whichBar,"crossed zero up");
         if (trends[whichBar][_tzl] == -1) doAlert(time1,mess1,whichBar,"crossed zero down");
      }
      static datetime time2 = 0;
      static string   mess2 = "";
      if (alertsOnRsiSignalCross && trends[whichBar][_tcr] != trends[whichBar-1][_tcr])
      {
         if (trends[whichBar][_tcr] ==  1) doAlert(time2,mess2,whichBar,"crossed signal line up");
         if (trends[whichBar][_tcr] == -1) doAlert(time2,mess2,whichBar,"crossed signal line down");
      }
      
   }
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

       message =  StringConcatenate(Symbol()," ",timeFrameToString(timeFrame)," at ",TimeToStr(TimeLocal(),TIME_SECONDS)," Tdi rsi ",doWhat);
          if (alertsMessage) Alert(message);
          if (alertsEmail)   SendMail(StringConcatenate(Symbol()," Tdi rsi "),message);
          if (alertsSound)   PlaySound("alert2.wav");
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

void manageArrow(int i, int r)
{
   if (!calculateValue && arrowsVisible)
   {
      deleteArrow(Time[i]);
      if (arrowsOnZeroCross && trends[r][_tzl]!=trends[r-1][_tzl])
      {
         if (trends[r][_tzl] == 1) drawArrow(i,arrowsOnZeroCrossUpColor,arrowsOnZeroCrossUpCode,arrowsOnZeroCrossUpSize,false);
         if (trends[r][_tzl] ==-1) drawArrow(i,arrowsOnZeroCrossDnColor,arrowsOnZeroCrossDnCode,arrowsOnZeroCrossDnSize, true);
      }
      if (arrowsOnRsiSignalCross && trends[r][_tcr]!=trends[r-1][_tcr])
      {
         if (trends[r][_tcr] == 1) drawArrow(i,arrowsOnRsiSignalCrossUpColor,arrowsOnRsiSignalCrossUpCode,arrowsOnRsiSignalCrossUpSize,false);
         if (trends[r][_tcr] ==-1) drawArrow(i,arrowsOnRsiSignalCrossDnColor,arrowsOnRsiSignalCrossDnCode,arrowsOnRsiSignalCrossDnSize,true);
      }
      
   }
}               

//
//
//
//
//

void drawArrow(int i,color theColor,int theCode,int theSize, bool up)
{
   string name = arrowsIdentifier+":"+Time[i];
   double gap  = iATR(NULL,0,20,i);   
   
      //
      //
      //
      //
      //
      
      ObjectCreate(name,OBJ_ARROW,0,Time[i],0);
         ObjectSet(name,OBJPROP_ARROWCODE,theCode);
         ObjectSet(name,OBJPROP_COLOR,   theColor);
         ObjectSet(name,OBJPROP_WIDTH,    theSize);      
         
         if (up)
               ObjectSet(name,OBJPROP_PRICE1,High[i] + arrowsDisplacement * gap);
         else  ObjectSet(name,OBJPROP_PRICE1, Low[i] - arrowsDisplacement * gap);
}

//
//
//
//
//

void deleteArrows()
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

void deleteArrow(datetime time)
{
   string lookFor = arrowsIdentifier+":"+time; ObjectDelete(lookFor);
}

//------------------------------------------------------------------
//                                                                  
//------------------------------------------------------------------
//
//
//
//
//

double RationalApproximation(double t)
{
    double c[] = {2.515517, 0.802853, 0.010328};
    double d[] = {1.432788, 0.189269, 0.001308};
    return (t - (( c[2]*t + c[1])*t + c[0]) / 
                (((d[2]*t + d[1])*t + d[0])*t + 1.0));
}

//
//
//
//
//

double NormalCDFInverse(double p)
{
    if (p <= 0.0 || p >= 1.0) return(0);
    if (p < 0.5)
           return (-RationalApproximation(MathSqrt(-2.0*MathLog(p))));
    else   return ( RationalApproximation(MathSqrt(-2.0*MathLog(1.0-p))));
}

