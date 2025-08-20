//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "www,forex-tsd.com"
#property link      "www,forex-tsd.com"

#property indicator_separate_window
#property indicator_buffers 4
#property indicator_color1  DimGray
#property indicator_color2  DarkOrange
#property indicator_color3  LimeGreen
#property indicator_color4  LimeGreen
#property indicator_style1  STYLE_DOT
#property indicator_style2  STYLE_DOT
#property indicator_style3  STYLE_DOT
#property indicator_width4  2

//
//
//
//
//

#import "dynamicZone.dll"
   double dzBuyP(double& sourceArray[],double probabiltyValue, int lookBack, int bars, int i, double precision);
   double dzSellP(double& sourceArray[],double probabiltyValue, int lookBack, int bars, int i, double precision);
#import

//
//
//
//
//

extern string TimeFrame                 = "Current time frame";
extern bool   UseRsi                    = false;   
extern double Length                    = 10;  
extern double Signal                    = 5;  
extern double Smooth                    = 5; 
extern int    Price                     = 0; 
extern int    MaMethod                  = 2; 
extern int    DzLookBackBars            = 35;
extern double DzStartBuyProbability     = 0.05;
extern double DzStartSellProbability    = 0.05;
extern color  ColorUp                   = LimeGreen;
extern color  ColorDown                 = Red;
extern string ColorUniqueID             = "DZ AbsoluteStrength Diff color";
extern int    ColorWidth                = 2;
extern int    ColorBars                 = 1000;
extern bool   divergenceVisible         = false;
extern bool   divergenceOnValuesVisible = true;
extern bool   divergenceOnChartVisible  = true;
extern color  divergenceBullishColor    = LimeGreen;
extern color  divergenceBearishColor    = PaleVioletRed;
extern string divergenceUniqueID        = "DZ AbsoluteStrength Diff ";
extern bool   divergenceAlert           = true;
extern bool   divergenceAlertsMessage   = true;
extern bool   divergenceAlertsSound     = true;
extern bool   divergenceAlertsEmail     = false;
extern bool   divergenceAlertsNotify    = false;
extern string divergenceAlertsSoundName = "alert1.wav";
extern bool   barsVisible               = true;
extern int    widthWick                 = 0;
extern int    widthBody                 = 2;
extern bool   drawInBackgound           = false;
bool          Interpolate               = true;

extern string _                         = "Alerts Settings";
extern bool   alertsOn                  = true;
extern bool   alertsOnobLineCross       = true;
extern bool   alertsOnosLineCross       = true;
extern bool   alertsOnzeroLineCross     = true;
extern bool   alertsOnCurrent           = false;
extern bool   alertsMessage             = true;
extern bool   alertsSound               = true;
extern bool   alertsEmail               = false;
extern bool   alertsNotify              = true;  

extern string MaMethods                 = "";
extern string __0                       = "SMA";
extern string __1                       = "EMA";
extern string __2                       = "Double smoothed EMA";
extern string __3                       = "Double EMA (DEMA)";
extern string __4                       = "Triple EMA (TEMA)";
extern string __5                       = "Smoothed MA";
extern string __6                       = "Linear weighted MA";
extern string __7                       = "Parabolic weighted MA";
extern string __8                       = "Alexander MA";
extern string __9                       = "Volume weghted MA";
extern string __10                      = "Hull MA";
extern string __11                      = "Triangular MA";
extern string __12                      = "Sine weighted MA";
extern string __13                      = "Linear regression";
extern string __14                      = "IE/2";
extern string __15                      = "NonLag MA";
extern string __16                      = "Zero lag EMA";
extern string __17                      = "Leader EMA";
extern string __18                      = "Super smoother";
extern string __19                      = "Smoother";   


//
//
//
//
//

double obLine[];
double osLine[];
double zeroLine[];
double SmthBulls[];
double SmthBears[];
double diff[];
double ratios[];

double trends[][3];
#define _tob 0
#define _tos 1
#define _tzl 2


string indicatorFileName;
bool   returnBars;
bool   calculateValue;
int    timeFrame;
string shortName;

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//
//
//
//
//

int window;
int init()
{
     IndicatorBuffers(7);
         SetIndexBuffer(0,zeroLine);  SetIndexLabel(0,NULL);
         SetIndexBuffer(1,obLine);    SetIndexLabel(1,NULL);
         SetIndexBuffer(2,osLine);    SetIndexLabel(2,NULL);
         SetIndexBuffer(3,diff);
         SetIndexBuffer(4,SmthBulls); 
         SetIndexBuffer(5,SmthBears);  
         SetIndexBuffer(6,ratios);
   
         //
         //
         //
         //
         //
      
            indicatorFileName = WindowExpertName();
            returnBars        = (TimeFrame=="returnBars");  if (returnBars) { return(0); }
            calculateValue    = (TimeFrame=="calculateValue");
            if (calculateValue)
            {
               int s = StringFind(divergenceUniqueID,":",0);
                     shortName          = divergenceUniqueID;
                     divergenceUniqueID = StringSubstr(divergenceUniqueID,0,s);
                     return(0);
            }            
            timeFrame         = stringToTimeFrame(TimeFrame);
      
         //
         //
         //
         //
         //

      shortName = timeFrameToString(timeFrame)+" "+divergenceUniqueID+" of "+getAverageName(MaMethod)+"";  
      IndicatorShortName(shortName);
   return(0);
}

//
//
//
//
//

int deinit()
{
   int lookForLength = StringLen(divergenceUniqueID);
      for (int i=ObjectsTotal()-1; i>=0; i--) 
      {
         string name = ObjectName(i);  if (StringSubstr(name,0,lookForLength) == divergenceUniqueID) ObjectDelete(name);
      }
   lookForLength = StringLen(ColorUniqueID);
      for (i=ObjectsTotal()-1; i>=0; i--) 
      {
         name = ObjectName(i);  if (StringSubstr(name,0,lookForLength) == ColorUniqueID) ObjectDelete(name);
      }
   return(0); 
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
   window = WindowFind(shortName);
   int counted_bars = IndicatorCounted();
      if(counted_bars<0) return(-1);
      if(counted_bars>0) counted_bars--;
           int limit=MathMin(Bars-counted_bars,Bars-1);
           if (returnBars) { zeroLine[0] = MathMin(limit+1,Bars-1); return(0); }

   //
   //
   //
   //
   //

   if (calculateValue || timeFrame == Period())
   {
      int i,r,k;
      int cb = ColorBars; if (ColorBars==0) cb = Bars-1; cb = MathMin(Bars-1,cb);
      if (ArrayRange(trends,0)!=Bars) ArrayResize(trends,Bars); 
      for (i=limit, r=Bars-i-1; i>=0; i--,r++)
      {
         double Price1 = getPrice(Price,i); 
         double Price2 = getPrice(Price,i+1);  
         double Bulls  = 0;
         double Bears  = 0; 
      
         if (UseRsi)
         {
            Bulls = 0.5*(MathAbs(Price1-Price2)+(Price1-Price2));
            Bears = 0.5*(MathAbs(Price1-Price2)-(Price1-Price2));
         }
         else
         {
            double smax = High[i]; for(k=1; k<Length && (i+k)>=0; k++) smax = MathMax(smax,High[i+k]);
            double smin =  Low[i]; for(k=1; k<Length && (i+k)>=0; k++) smin = MathMin(smin, Low[i+k]);
            Bulls = Price1 - smin;
            Bears = smax - Price1;
         }
   
         double AvgBulls = iCustomMa(MaMethod,Bulls,   Length,i,0);   
         double AvgBears = iCustomMa(MaMethod,Bears,   Length,i,1);
         SmthBulls[i]    = iCustomMa(MaMethod,AvgBulls,Smooth,i,2);  
         SmthBears[i]    = iCustomMa(MaMethod,AvgBears,Smooth,i,3);
         diff[i]         = SmthBulls[i]-SmthBears[i];
         obLine[i]       = dzBuyP (diff, DzStartBuyProbability,  DzLookBackBars, Bars, i, 0.00001);
         osLine[i]       = dzSellP(diff, DzStartSellProbability, DzLookBackBars, Bars, i, 0.00001);
         zeroLine[i]     = dzSellP(diff, 0.5,                    DzLookBackBars, Bars, i, 0.00001);
         ratios[i]       = -1;
         
         //
         //
         //
         //
         //
         
            if (divergenceVisible)
            {
               CatchBullishDivergence(diff,i);
               CatchBearishDivergence(diff,i);
            }
            ObjectDelete(ColorUniqueID+":"+Time[i]);   
            if (cb>=i)
            {
               double ratio = MathMin(diff[i],osLine[i]);
                      ratio = MathMax(ratio  ,obLine[i]);
                      if ((osLine[i]-obLine[i]) != 0)
                           ratio = (ratio-obLine[i])/(osLine[i]-obLine[i]);
                     else  ratio = 0; 
                     if (!calculateValue)
                     {
                           
                           color theColor = gradientColor(100.0*ratio,101,ColorDown,ColorUp);
                              plot("",diff[i],diff[i+1],i,i+1,theColor,ColorWidth);
                              if (barsVisible) drawBar(Time[i],High[i],Low[i],Open[i],Close[i],theColor,theColor);
                     }                        
                     ratios[i] = ratio;
            }
            setTrends(i,r);                     
      }
      manageAlerts(); 
      return(0);
   }
   
   //
   //
   //
   //
   //

   limit = MathMax(limit,MathMin(Bars-1,iCustom(NULL,timeFrame,indicatorFileName,"returnBars",0,0)*timeFrame/Period()));
   if (ArrayRange(trends,0) != Bars) ArrayResize(trends,Bars); 
   for (i=limit, r=Bars-i-1; i>=0; i--,r++)
   {
      int y = iBarShift(NULL,timeFrame,Time[i]);
         zeroLine[i]  = iCustom(NULL,timeFrame,indicatorFileName,"calculateValue",UseRsi,Length,Signal,Smooth,Price,MaMethod,DzLookBackBars,DzStartBuyProbability,DzStartSellProbability,ColorUp,ColorDown,ColorUniqueID,ColorWidth,ColorBars,divergenceVisible,divergenceOnValuesVisible,divergenceOnChartVisible,divergenceBullishColor,divergenceBearishColor,shortName,divergenceAlert,divergenceAlertsMessage,divergenceAlertsSound,divergenceAlertsEmail,divergenceAlertsNotify,divergenceAlertsSoundName,0,y);
         obLine[i]    = iCustom(NULL,timeFrame,indicatorFileName,"calculateValue",UseRsi,Length,Signal,Smooth,Price,MaMethod,DzLookBackBars,DzStartBuyProbability,DzStartSellProbability,ColorUp,ColorDown,ColorUniqueID,ColorWidth,ColorBars,divergenceVisible,divergenceOnValuesVisible,divergenceOnChartVisible,divergenceBullishColor,divergenceBearishColor,shortName,divergenceAlert,divergenceAlertsMessage,divergenceAlertsSound,divergenceAlertsEmail,divergenceAlertsNotify,divergenceAlertsSoundName,1,y);
         osLine[i]    = iCustom(NULL,timeFrame,indicatorFileName,"calculateValue",UseRsi,Length,Signal,Smooth,Price,MaMethod,DzLookBackBars,DzStartBuyProbability,DzStartSellProbability,ColorUp,ColorDown,ColorUniqueID,ColorWidth,ColorBars,divergenceVisible,divergenceOnValuesVisible,divergenceOnChartVisible,divergenceBullishColor,divergenceBearishColor,shortName,divergenceAlert,divergenceAlertsMessage,divergenceAlertsSound,divergenceAlertsEmail,divergenceAlertsNotify,divergenceAlertsSoundName,2,y);
         diff[i]      = iCustom(NULL,timeFrame,indicatorFileName,"calculateValue",UseRsi,Length,Signal,Smooth,Price,MaMethod,DzLookBackBars,DzStartBuyProbability,DzStartSellProbability,ColorUp,ColorDown,ColorUniqueID,ColorWidth,ColorBars,divergenceVisible,divergenceOnValuesVisible,divergenceOnChartVisible,divergenceBullishColor,divergenceBearishColor,shortName,divergenceAlert,divergenceAlertsMessage,divergenceAlertsSound,divergenceAlertsEmail,divergenceAlertsNotify,divergenceAlertsSoundName,3,y);
         ratios[i]    = iCustom(NULL,timeFrame,indicatorFileName,"calculateValue",UseRsi,Length,Signal,Smooth,Price,MaMethod,DzLookBackBars,DzStartBuyProbability,DzStartSellProbability,ColorUp,ColorDown,ColorUniqueID,ColorWidth,ColorBars,divergenceVisible,divergenceOnValuesVisible,divergenceOnChartVisible,divergenceBullishColor,divergenceBearishColor,shortName,divergenceAlert,divergenceAlertsMessage,divergenceAlertsSound,divergenceAlertsEmail,divergenceAlertsNotify,divergenceAlertsSoundName,6,y);
         setTrends(i,r);

         //
         //
         //
         //
         //
      
         if (!Interpolate || y==iBarShift(NULL,timeFrame,Time[i-1])) continue;
             interpolate(diff    ,timeFrame,i);
             interpolate(zeroLine,timeFrame,i);
             interpolate(obLine  ,timeFrame,i);
             interpolate(osLine  ,timeFrame,i);
   }
   for (i=limit; i>=0; i--)
   {
      ObjectDelete(ColorUniqueID+":"+Time[i]);   
      if (ratios[i] != -1)
      {
         theColor = gradientColor(100.0*ratios[i],101,ColorDown,ColorUp);
            plot("",diff[i],diff[i+1],i,i+1,theColor,ColorWidth);
            if (barsVisible) drawBar(Time[i],High[i],Low[i],Open[i],Close[i],theColor,theColor);
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

void interpolate(double& target[], int ttimeFrame, int i)
{
   int t = iBarShift(NULL,ttimeFrame,Time[i]); 
      double y0 = target[i];
      double y1 = target[iBarShift(NULL,0,iTime(NULL,ttimeFrame,t+0))+1];
      double y2 = target[iBarShift(NULL,0,iTime(NULL,ttimeFrame,t+1))+1];

      //
      //
      //
      //
      //
      
      datetime time = iTime(NULL,ttimeFrame,t);
         for(int n = 1; i+n < Bars && Time[i+n] >= time; n++) continue;
         for(int k = 1; k < n; k++)
            target[i+k] = target[i] + (target[i+n] - target[i])*k/n;
}


//------------------------------------------------------------------
//
//------------------------------------------------------------------
//
//
//
//
//

void CatchBullishDivergence(double& values[], int i)
{
   i++;
            ObjectDelete(divergenceUniqueID+"l"+DoubleToStr(Time[i],0));
            ObjectDelete(divergenceUniqueID+"l"+"os" + DoubleToStr(Time[i],0));            
   if (!IsIndicatorLow(values,i)) return;  

   //
   //
   //
   //
   //

   int currentLow = i;
   int lastLow    = GetIndicatorLastLow(values,i+1);
      if (values[currentLow] > values[lastLow] && Low[currentLow] < Low[lastLow])
      {
         if(divergenceOnChartVisible)  DrawPriceTrendLine("l",Time[currentLow],Time[lastLow],Low[currentLow],Low[lastLow],divergenceBullishColor,STYLE_SOLID);
         if(divergenceOnValuesVisible) DrawIndicatorTrendLine("l",Time[currentLow],Time[lastLow],values[currentLow],values[lastLow],divergenceBullishColor,STYLE_SOLID);
         if (divergenceAlert)          DisplayAlert("Classical bullish divergence",currentLow);  
      }
      if (values[currentLow] < values[lastLow] && Low[currentLow] > Low[lastLow])
      {
         if(divergenceOnChartVisible)  DrawPriceTrendLine("l",Time[currentLow],Time[lastLow],Low[currentLow],Low[lastLow], divergenceBullishColor, STYLE_DOT);
         if(divergenceOnValuesVisible) DrawIndicatorTrendLine("l",Time[currentLow],Time[lastLow],values[currentLow],values[lastLow], divergenceBullishColor, STYLE_DOT);
         if (divergenceAlert)          DisplayAlert("Reverse bullish divergence",currentLow); 
      }
}

//
//
//
//
//

void CatchBearishDivergence(double& values[], int i)
{
   i++; 
            ObjectDelete(divergenceUniqueID+"h"+DoubleToStr(Time[i],0));
            ObjectDelete(divergenceUniqueID+"h"+"os" + DoubleToStr(Time[i],0));            
   if (IsIndicatorPeak(values,i) == false) return;

   //
   //
   //
   //
   //
      
   int currentPeak = i;
   int lastPeak = GetIndicatorLastPeak(values,i+1);
      if (values[currentPeak] < values[lastPeak] && High[currentPeak]>High[lastPeak])
      {
         if (divergenceOnChartVisible)  DrawPriceTrendLine("h",Time[currentPeak],Time[lastPeak],High[currentPeak],High[lastPeak],divergenceBearishColor,STYLE_SOLID);
         if (divergenceOnValuesVisible) DrawIndicatorTrendLine("h",Time[currentPeak],Time[lastPeak],values[currentPeak],values[lastPeak],divergenceBearishColor,STYLE_SOLID);
         if (divergenceAlert)           DisplayAlert("Classical bearish divergence",currentPeak);
      }
      if(values[currentPeak] > values[lastPeak] && High[currentPeak] < High[lastPeak])
      {
         if (divergenceOnChartVisible)  DrawPriceTrendLine("h",Time[currentPeak],Time[lastPeak],High[currentPeak],High[lastPeak], divergenceBearishColor, STYLE_DOT);
         if (divergenceOnValuesVisible) DrawIndicatorTrendLine("h",Time[currentPeak],Time[lastPeak],values[currentPeak],values[lastPeak], divergenceBearishColor, STYLE_DOT);
         if (divergenceAlert)           DisplayAlert("Reverse bearish divergence",currentPeak);
      }
}

//
//
//
//
//

bool IsIndicatorPeak(double& values[], int i) { return(values[i] >= values[i+1] && values[i] > values[i+2] && values[i] > values[i-1]); }
bool IsIndicatorLow( double& values[], int i) { return(values[i] <= values[i+1] && values[i] < values[i+2] && values[i] < values[i-1]); }

int GetIndicatorLastPeak(double& values[], int shift)
{
   for(int i = shift+5; i<Bars; i++)
         if (values[i] >= values[i+1] && values[i] > values[i+2] && values[i] >= values[i-1] && values[i] > values[i-2]) return(i);
   return(-1);
}
int GetIndicatorLastLow(double& values[], int shift)
{
   for(int i = shift+5; i<Bars; i++)
         if (values[i] <= values[i+1] && values[i] < values[i+2] && values[i] <= values[i-1] && values[i] < values[i-2]) return(i);
   return(-1);
}

//+------------------------------------------------------------------
//|                                                                  
//+------------------------------------------------------------------
//
//
//
//
//

void DrawPriceTrendLine(string first,datetime t1, datetime t2, double p1, double p2, color lineColor, double style)
{
   string   label = divergenceUniqueID+first+"os"+DoubleToStr(t1,0);
    
   ObjectDelete(label);
      ObjectCreate(label, OBJ_TREND, 0, t1+Period()*60-1, p1, t2, p2, 0, 0);
         ObjectSet(label, OBJPROP_RAY, false);
         ObjectSet(label, OBJPROP_COLOR, lineColor);
         ObjectSet(label, OBJPROP_STYLE, style);
}
void DrawIndicatorTrendLine(string first,datetime t1, datetime t2, double p1, double p2, color lineColor, double style)
{
   int indicatorWindow = WindowFind(shortName);
   if (indicatorWindow < 0) return;
   
   string label = divergenceUniqueID+first+DoubleToStr(t1,0);
   ObjectDelete(label);
      ObjectCreate(label, OBJ_TREND, indicatorWindow, t1+Period()*60-1, p1, t2, p2, 0, 0);
         ObjectSet(label, OBJPROP_RAY, false);
         ObjectSet(label, OBJPROP_COLOR, lineColor);
         ObjectSet(label, OBJPROP_STYLE, style);
}

//
//
//
//
//

void DisplayAlert(string doWhat, int shift)
{
    string dmessage;
    static datetime lastAlertTime;
    if(shift <= 2 && Time[0] != lastAlertTime)
    {
      dmessage =  StringConcatenate(Symbol()," ",timeFrameToString(Period())," at ",TimeToStr(TimeLocal(),TIME_SECONDS)," Dz Absolute Strength of Averages ",doWhat);
          if (divergenceAlertsMessage) Alert(dmessage);
          if (divergenceAlertsNotify)  SendNotification(dmessage);
          if (divergenceAlertsEmail)   SendMail(StringConcatenate(Symbol()," Dz Absolute Strength of Averages "),dmessage);
          if (divergenceAlertsSound)   PlaySound(divergenceAlertsSoundName); 
          lastAlertTime = Time[0];
    }
}

//
//
//
//
//

double getPrice(int type, int i)
{
   switch (type)
   {
      case 7:     return((Open[i]+Close[i])/2.0);
      case 8:     return((Open[i]+High[i]+Low[i]+Close[i])/4.0);
      default :   return(iMA(NULL,0,1,0,MODE_SMA,type,i));
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

string methodNames[] = {"SMA","EMA","Double smoothed EMA","Double EMA","Triple EMA","Smoothed MA","Linear weighted MA","Parabolic weighted MA","Alexander MA","Volume weghted MA","Hull MA","Triangular MA","Sine weighted MA","Linear regression","IE/2","NonLag MA","Zero lag EMA","Leader EMA","Super smoother","Smoothed"};
string getAverageName(int& method)
{
   int max = ArraySize(methodNames)-1;
      method=MathMax(MathMin(method,max),0); return(methodNames[method]);
}

//
//
//
//
//

#define _maWorkBufferx1 4
#define _maWorkBufferx2 8
#define _maWorkBufferx3 12
#define _maWorkBufferx5 20

double iCustomMa(int mode, double price, double length, int i, int instanceNo=0)
{
   int r = Bars-i-1;
   switch (mode)
   {
      case 0  : return(iSma(price,length,r,instanceNo));
      case 1  : return(iEma(price,length,r,instanceNo));
      case 2  : return(iDsema(price,length,r,instanceNo));
      case 3  : return(iDema(price,length,r,instanceNo));
      case 4  : return(iTema(price,length,r,instanceNo));
      case 5  : return(iSmma(price,length,r,instanceNo));
      case 6  : return(iLwma(price,length,r,instanceNo));
      case 7  : return(iLwmp(price,length,r,instanceNo));
      case 8  : return(iAlex(price,length,r,instanceNo));
      case 9  : return(iWwma(price,length,r,instanceNo));
      case 10 : return(iHull(price,length,r,instanceNo));
      case 11 : return(iTma(price,length,r,instanceNo));
      case 12 : return(iSineWMA(price,length,r,instanceNo));
      case 13 : return(iLinr(price,length,r,instanceNo));
      case 14 : return(iIe2(price,length,r,instanceNo));
      case 15 : return(iNonLagMa(price,length,r,instanceNo));
      case 16 : return(iZeroLag(price,length,r,instanceNo));
      case 17 : return(iLeader(price,length,r,instanceNo));
      case 18 : return(iSsm(price,length,r,instanceNo));
      case 19 : return(iSmooth(price,length,r,instanceNo));
      default : return(0);
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

double workSma[][_maWorkBufferx2];
double iSma(double price, int period, int r, int instanceNo=0)
{
   if (ArrayRange(workSma,0)!= Bars) ArrayResize(workSma,Bars); instanceNo *= 2;

   //
   //
   //
   //
   //
      
   workSma[r][instanceNo] = price;
   if (r>=period)
          workSma[r][instanceNo+1] = workSma[r-1][instanceNo+1]+(workSma[r][instanceNo]-workSma[r-period][instanceNo])/period;
   else { workSma[r][instanceNo+1] = 0; for(int k=0; k<period && (r-k)>=0; k++) workSma[r][instanceNo+1] += workSma[r-k][instanceNo];  
          workSma[r][instanceNo+1] /= k; }
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
      
   double alpha = 2.0 / (1.0+period);
          workEma[r][instanceNo] = workEma[r-1][instanceNo]+alpha*(price-workEma[r-1][instanceNo]);
   return(workEma[r][instanceNo]);
}

//
//
//
//
//

double workDsema[][_maWorkBufferx2];
#define _ema1 0
#define _ema2 1

double iDsema(double price, double period, int r, int instanceNo=0)
{
   if (ArrayRange(workDsema,0)!= Bars) ArrayResize(workDsema,Bars); instanceNo*=2;

   //
   //
   //
   //
   //
      
   double alpha = 2.0 /(1.0+MathSqrt(period));
          workDsema[r][_ema1+instanceNo] = workDsema[r-1][_ema1+instanceNo]+alpha*(price                         -workDsema[r-1][_ema1+instanceNo]);
          workDsema[r][_ema2+instanceNo] = workDsema[r-1][_ema2+instanceNo]+alpha*(workDsema[r][_ema1+instanceNo]-workDsema[r-1][_ema2+instanceNo]);
   return(workDsema[r][_ema2+instanceNo]);
}

//
//
//
//
//

double workDema[][_maWorkBufferx2];
#define _dema1 0
#define _dema2 1

double iDema(double price, double period, int r, int instanceNo=0)
{
   if (ArrayRange(workDema,0)!= Bars) ArrayResize(workDema,Bars); instanceNo*=2;

   //
   //
   //
   //
   //
      
   double alpha = 2.0 / (1.0+period);
          workDema[r][_dema1+instanceNo] = workDema[r-1][_dema1+instanceNo]+alpha*(price                         -workDema[r-1][_dema1+instanceNo]);
          workDema[r][_dema2+instanceNo] = workDema[r-1][_dema2+instanceNo]+alpha*(workDema[r][_dema1+instanceNo]-workDema[r-1][_dema2+instanceNo]);
   return(workDema[r][_dema1+instanceNo]*2.0-workDema[r][_dema2+instanceNo]);
}

//
//
//
//
//

double workTema[][_maWorkBufferx3];
#define _tema1 0
#define _tema2 1
#define _tema3 2

double iTema(double price, double period, int r, int instanceNo=0)
{
   if (ArrayRange(workTema,0)!= Bars) ArrayResize(workTema,Bars); instanceNo*=3;

   //
   //
   //
   //
   //
      
   double alpha = 2.0 / (1.0+period);
          workTema[r][_tema1+instanceNo] = workTema[r-1][_tema1+instanceNo]+alpha*(price                         -workTema[r-1][_tema1+instanceNo]);
          workTema[r][_tema2+instanceNo] = workTema[r-1][_tema2+instanceNo]+alpha*(workTema[r][_tema1+instanceNo]-workTema[r-1][_tema2+instanceNo]);
          workTema[r][_tema3+instanceNo] = workTema[r-1][_tema3+instanceNo]+alpha*(workTema[r][_tema2+instanceNo]-workTema[r-1][_tema3+instanceNo]);
   return(workTema[r][_tema3+instanceNo]+3.0*(workTema[r][_tema1+instanceNo]-workTema[r][_tema2+instanceNo]));
}

//
//
//
//
//

double workSmma[][_maWorkBufferx1];
double iSmma(double price, double period, int r, int instanceNo=0)
{
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

//
//
//
//
//

double workLwmp[][_maWorkBufferx1];
double iLwmp(double price, double period, int r, int instanceNo=0)
{
   if (ArrayRange(workLwmp,0)!= Bars) ArrayResize(workLwmp,Bars);
   
   //
   //
   //
   //
   //
   
   workLwmp[r][instanceNo] = price;
      double sumw = period*period;
      double sum  = sumw*price;

      for(int k=1; k<period && (r-k)>=0; k++)
      {
         double weight = (period-k)*(period-k);
                sumw  += weight;
                sum   += weight*workLwmp[r-k][instanceNo];  
      }             
      return(sum/sumw);
}

//
//
//
//
//

double workAlex[][_maWorkBufferx1];
double iAlex(double price, double period, int r, int instanceNo=0)
{
   if (ArrayRange(workAlex,0)!= Bars) ArrayResize(workAlex,Bars);
   if (period<4) return(price);
   
   //
   //
   //
   //
   //

   workAlex[r][instanceNo] = price;
      double sumw = period-2;
      double sum  = sumw*price;

      for(int k=1; k<period && (r-k)>=0; k++)
      {
         double weight = period-k-2;
                sumw  += weight;
                sum   += weight*workAlex[r-k][instanceNo];  
      }             
      return(sum/sumw);
}

//
//
//
//
//

double workTma[][_maWorkBufferx1];
double iTma(double price, double period, int r, int instanceNo=0)
{
   if (ArrayRange(workTma,0)!= Bars) ArrayResize(workTma,Bars);
   
   //
   //
   //
   //
   //
   
   workTma[r][instanceNo] = price;

      double half = (period+1.0)/2.0;
      double sum  = price;
      double sumw = 1;

      for(int k=1; k<period && (r-k)>=0; k++)
      {
         double weight = k+1; if (weight > half) weight = period-k;
                sumw  += weight;
                sum   += weight*workTma[r-k][instanceNo];  
      }             
      return(sum/sumw);
}

//
//
//
//
//

double workSineWMA[][_maWorkBufferx1];
#define Pi 3.14159265358979323846264338327950288

double iSineWMA(double price, int period, int r, int instanceNo=0)
{
   if (period<1) return(price);
   if (ArrayRange(workSineWMA,0)!= Bars) ArrayResize(workSineWMA,Bars);
   
   //
   //
   //
   //
   //
   
   workSineWMA[r][instanceNo] = price;
      double sum  = 0;
      double sumw = 0;
  
      for(int k=0; k<period && (r-k)>=0; k++)
      { 
         double weight = MathSin(Pi*(k+1.0)/(period+1.0));
                sumw  += weight;
                sum   += weight*workSineWMA[r-k][instanceNo]; 
      }
      return(sum/sumw);
}

//
//
//
//
//

double workWwma[][_maWorkBufferx1];
double iWwma(double price, double period, int r, int instanceNo=0)
{
   if (ArrayRange(workWwma,0)!= Bars) ArrayResize(workWwma,Bars);
   
   //
   //
   //
   //
   //
   
   workWwma[r][instanceNo] = price;
      int    i    = Bars-r-1;
      double sumw = Volume[i];
      double sum  = sumw*price;

      for(int k=1; k<period && (r-k)>=0; k++)
      {
         double weight = Volume[i+k];
                sumw  += weight;
                sum   += weight*workWwma[r-k][instanceNo];  
      }             
      return(sum/sumw);
}

//
//
//
//
//

double workHull[][_maWorkBufferx2];
double iHull(double price, double period, int r, int instanceNo=0)
{
   if (ArrayRange(workHull,0)!= Bars) ArrayResize(workHull,Bars);

   //
   //
   //
   //
   //

      int HmaPeriod  = MathMax(period,2);
      int HalfPeriod = MathFloor(HmaPeriod/2);
      int HullPeriod = MathFloor(MathSqrt(HmaPeriod));
      double hma,hmw,weight; instanceNo *= 2;

         workHull[r][instanceNo] = price;

         //
         //
         //
         //
         //
               
         hmw = HalfPeriod; hma = hmw*price; 
            for(int k=1; k<HalfPeriod && (r-k)>=0; k++)
            {
               weight = HalfPeriod-k;
               hmw   += weight;
               hma   += weight*workHull[r-k][instanceNo];  
            }             
            workHull[r][instanceNo+1] = 2.0*hma/hmw;

         hmw = HmaPeriod; hma = hmw*price; 
            for(k=1; k<period && (r-k)>=0; k++)
            {
               weight = HmaPeriod-k;
               hmw   += weight;
               hma   += weight*workHull[r-k][instanceNo];
            }             
            workHull[r][instanceNo+1] -= hma/hmw;

         //
         //
         //
         //
         //
         
         hmw = HullPeriod; hma = hmw*workHull[r][instanceNo+1];
            for(k=1; k<HullPeriod && (r-k)>=0; k++)
            {
               weight = HullPeriod-k;
               hmw   += weight;
               hma   += weight*workHull[r-k][1+instanceNo];  
            }
   return(hma/hmw);
}

//
//
//
//
//

double workLinr[][_maWorkBufferx1];
double iLinr(double price, double period, int r, int instanceNo=0)
{
   if (ArrayRange(workLinr,0)!= Bars) ArrayResize(workLinr,Bars);

   //
   //
   //
   //
   //
   
      period = MathMax(period,1);
      workLinr[r][instanceNo] = price;
         double lwmw = period; double lwma = lwmw*price;
         double sma  = price;
         for(int k=1; k<period && (r-k)>=0; k++)
         {
            double weight = period-k;
                   lwmw  += weight;
                   lwma  += weight*workLinr[r-k][instanceNo];  
                   sma   +=        workLinr[r-k][instanceNo];
         }             
   
   return(3.0*lwma/lwmw-2.0*sma/period);
}

//
//
//
//
//

double workIe2[][_maWorkBufferx1];
double iIe2(double price, double period, int r, int instanceNo=0)
{
   if (ArrayRange(workIe2,0)!= Bars) ArrayResize(workIe2,Bars);

   //
   //
   //
   //
   //
   
      period = MathMax(period,1);
      workIe2[r][instanceNo] = price;
         double sumx=0, sumxx=0, sumxy=0, sumy=0;
         for (int k=0; k<period; k++)
         {
            price = workIe2[r-k][instanceNo];
                   sumx  += k;
                   sumxx += k*k;
                   sumxy += k*price;
                   sumy  +=   price;
         }
         double slope   = (period*sumxy - sumx*sumy)/(sumx*sumx-period*sumxx);
         double average = sumy/period;
   return(((average+slope)+(sumy+slope*sumx)/period)/2.0);
}

//
//
//
//
//

double workLeader[][_maWorkBufferx2];
double iLeader(double price, double period, int r, int instanceNo=0)
{
   if (ArrayRange(workLeader,0)!= Bars) ArrayResize(workLeader,Bars); instanceNo*=2;

   //
   //
   //
   //
   //
   
      period = MathMax(period,1);
      double alpha = 2.0/(period+1.0);
         workLeader[r][instanceNo  ] = workLeader[r-1][instanceNo  ]+alpha*(price                          -workLeader[r-1][instanceNo  ]);
         workLeader[r][instanceNo+1] = workLeader[r-1][instanceNo+1]+alpha*(price-workLeader[r][instanceNo]-workLeader[r-1][instanceNo+1]);

   return(workLeader[r][instanceNo]+workLeader[r][instanceNo+1]);
}

//
//
//
//
//

double workZl[][_maWorkBufferx2];
#define _price 0
#define _zlema 1

double iZeroLag(double price, double length, int r, int instanceNo=0)
{
   if (ArrayRange(workZl,0)!=Bars) ArrayResize(workZl,Bars); instanceNo *= 2;

   //
   //
   //
   //
   //

   double alpha = 2.0/(1.0+length); 
   int    per   = (length-1.0)/2.0; 

   workZl[r][_price+instanceNo] = price;
   if (r<per)
          workZl[r][_zlema+instanceNo] = price;
   else   workZl[r][_zlema+instanceNo] = workZl[r-1][_zlema+instanceNo]+alpha*(2.0*price-workZl[r-per][_price+instanceNo]-workZl[r-1][_zlema+instanceNo]);
   return(workZl[r][_zlema+instanceNo]);
}

//
//
//
//
//

double workSmooth[][_maWorkBufferx5];
double iSmooth(double price,int length,int r, int instanceNo=0)
{
   if (ArrayRange(workSmooth,0)!=Bars) ArrayResize(workSmooth,Bars); instanceNo *= 5;
 	if(r<=2) { workSmooth[r][instanceNo] = price; workSmooth[r][instanceNo+2] = price; workSmooth[r][instanceNo+4] = price; return(price); }
   
   //
   //
   //
   //
   //
   
	double alpha = 0.45*(length-1.0)/(0.45*(length-1.0)+2.0);
   	  workSmooth[r][instanceNo+0] =  price+alpha*(workSmooth[r-1][instanceNo]-price);
	     workSmooth[r][instanceNo+1] = (price - workSmooth[r][instanceNo])*(1-alpha)+alpha*workSmooth[r-1][instanceNo+1];
	     workSmooth[r][instanceNo+2] =  workSmooth[r][instanceNo+0] + workSmooth[r][instanceNo+1];
	     workSmooth[r][instanceNo+3] = (workSmooth[r][instanceNo+2] - workSmooth[r-1][instanceNo+4])*MathPow(1.0-alpha,2) + MathPow(alpha,2)*workSmooth[r-1][instanceNo+3];
	     workSmooth[r][instanceNo+4] =  workSmooth[r][instanceNo+3] + workSmooth[r-1][instanceNo+4]; 
   return(workSmooth[r][instanceNo+4]);
}

//
//
//
//
//

double workSsm[][_maWorkBufferx2];
#define _tprice  0
#define _ssm    1

double workSsmCoeffs[][4];
#define _period 0
#define _c1     1
#define _c2     2
#define _c3     3

//
//
//
//
//

double iSsm(double price, double period, int i, int instanceNo)
{
   if (ArrayRange(workSsm,0) !=Bars)                 ArrayResize(workSsm,Bars);
   if (ArrayRange(workSsmCoeffs,0) < (instanceNo+1)) ArrayResize(workSsmCoeffs,instanceNo+1);
   if (workSsmCoeffs[instanceNo][_period] != period)
   {
      workSsmCoeffs[instanceNo][_period] = period;
      double a1 = MathExp(-1.414*Pi/period);
      double b1 = 2.0*a1*MathCos(1.414*Pi/period);
         workSsmCoeffs[instanceNo][_c2] = b1;
         workSsmCoeffs[instanceNo][_c3] = -a1*a1;
         workSsmCoeffs[instanceNo][_c1] = 1.0 - workSsmCoeffs[instanceNo][_c2] - workSsmCoeffs[instanceNo][_c3];
   }

   //
   //
   //
   //
   //

      int s = instanceNo*2;   
          workSsm[i][s+_tprice] = price;
          workSsm[i][s+_ssm]    = workSsmCoeffs[instanceNo][_c1]*(workSsm[i][s+_tprice]+workSsm[i-1][s+_price])/2.0 + 
                                  workSsmCoeffs[instanceNo][_c2]*workSsm[i-1][s+_ssm]                               + 
                                  workSsmCoeffs[instanceNo][_c3]*workSsm[i-2][s+_ssm]; 
   return(workSsm[i][s+_ssm]);
}

//
//
//
//
//

#define _length  0
#define _len     1
#define _weight  2

double  nlmvalues[3][_maWorkBufferx1];
double  nlmprices[ ][_maWorkBufferx1];
double  nlmalphas[ ][_maWorkBufferx1];

//
//
//
//
//

double iNonLagMa(double price, double length, int r, int instanceNo=0)
{
   if (ArrayRange(nlmprices,0) != Bars)       ArrayResize(nlmprices,Bars);
   if (ArrayRange(nlmvalues,0) <  instanceNo) ArrayResize(nlmvalues,instanceNo);
                               nlmprices[r][instanceNo]=price;
   if (length<3 || r<3) return(nlmprices[r][instanceNo]);
   
   //
   //
   //
   //
   //
   
   if (nlmvalues[_length][instanceNo] != length  || ArraySize(nlmalphas)==0)
   {
      double Cycle = 4.0;
      double Coeff = 3.0*Pi;
      int    Phase = length-1;
      
         nlmvalues[_length][instanceNo] = length;
         nlmvalues[_len   ][instanceNo] = length*4 + Phase;  
         nlmvalues[_weight][instanceNo] = 0;

         if (ArrayRange(nlmalphas,0) < nlmvalues[_len][instanceNo]) ArrayResize(nlmalphas,nlmvalues[_len][instanceNo]);
         for (int k=0; k<nlmvalues[_len][instanceNo]; k++)
         {
            if (k<=Phase-1) 
                 double t = 1.0 * k/(Phase-1);
            else        t = 1.0 + (k-Phase+1)*(2.0*Cycle-1.0)/(Cycle*length-1.0); 
            double beta = MathCos(Pi*t);
            double g = 1.0/(Coeff*t+1); if (t <= 0.5 ) g = 1;
      
            nlmalphas[k][instanceNo]        = g * beta;
            nlmvalues[_weight][instanceNo] += nlmalphas[k][instanceNo];
         }
   }
   
   //
   //
   //
   //
   //
   
   if (nlmvalues[_weight][instanceNo]>0)
   {
      double sum = 0;
           for (k=0; k < nlmvalues[_len][instanceNo]; k++) sum += nlmalphas[k][instanceNo]*nlmprices[r-k][instanceNo];
           return( sum / nlmvalues[_weight][instanceNo]);
   }
   else return(0);           
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

//------------------------------------------------------------------
//
//------------------------------------------------------------------
//
//
//
//
//

void plot(string namex,double valueA, double valueB, int shiftA, int shiftB, color theColor, int width=0,int style=STYLE_SOLID)
{
   string   name = ColorUniqueID+":"+namex+Time[shiftA];
   
   //
   //
   //
   //
   //
   
   ObjectDelete(name);   
       ObjectCreate(name,OBJ_TREND,window,Time[shiftA],valueA,Time[shiftB],valueB);
          ObjectSet(name,OBJPROP_RAY,false);
          ObjectSet(name,OBJPROP_BACK,false);
          ObjectSet(name,OBJPROP_STYLE,style);
          ObjectSet(name,OBJPROP_WIDTH,width);
          ObjectSet(name,OBJPROP_COLOR,theColor);
          ObjectSet(name,OBJPROP_PRICE1,valueA);
          ObjectSet(name,OBJPROP_PRICE2,valueB);
}

//
//
//
//
//

void drawBar(int bTime, double prHigh, double prLow, double prOpen, double prClose, color barColor, color wickColor)
{
   string oName;
          oName = ColorUniqueID+":"+TimeToStr(bTime)+"w";
            if (ObjectFind(oName) < 0) ObjectCreate(oName,OBJ_TREND,0,bTime,0,bTime,0);
                 ObjectSet(oName, OBJPROP_PRICE1, prHigh);
                 ObjectSet(oName, OBJPROP_PRICE2, prLow);
                 ObjectSet(oName, OBJPROP_COLOR, wickColor);
                 ObjectSet(oName, OBJPROP_WIDTH, widthWick);
                 ObjectSet(oName, OBJPROP_RAY, false);
                 ObjectSet(oName, OBJPROP_BACK, drawInBackgound);
           
         oName = ColorUniqueID+":"+TimeToStr(bTime)+"b";
            if (ObjectFind(oName) < 0)ObjectCreate(oName,OBJ_TREND,0,bTime,0,bTime,0);
                 ObjectSet(oName, OBJPROP_PRICE1, prOpen);
                 ObjectSet(oName, OBJPROP_PRICE2, prClose);
                 ObjectSet(oName, OBJPROP_COLOR, barColor);
                 ObjectSet(oName, OBJPROP_WIDTH, widthBody);
                 ObjectSet(oName, OBJPROP_RAY, false);
                 ObjectSet(oName, OBJPROP_BACK, drawInBackgound);
}


//------------------------------------------------------------------
//
//------------------------------------------------------------------
//
//
//
//
//

color gradientColor(int step, int totalSteps, color from, color to)
{
   step = MathMax(MathMin(step,totalSteps-1),0);
      color newBlue  = getColor(step,totalSteps,(from & 0XFF0000)>>16,(to & 0XFF0000)>>16)<<16;
      color newGreen = getColor(step,totalSteps,(from & 0X00FF00)>> 8,(to & 0X00FF00)>> 8) <<8;
      color newRed   = getColor(step,totalSteps,(from & 0X0000FF)    ,(to & 0X0000FF)    )    ;
      return(newBlue+newGreen+newRed);
}
color getColor(int stepNo, int totalSteps, color from, color to)
{
   double step = (from-to)/(totalSteps-1.0);
   return(MathRound(from-step*stepNo));
}

//
//
//
//
//

void setTrends(int i, int r)
{
   trends[r][_tob] = trends[r-1][_tob];
   trends[r][_tos] = trends[r-1][_tos];
   trends[r][_tzl] = trends[r-1][_tzl];
   
      if (diff[i] > obLine[i])   trends[r][_tob] =  1;
      if (diff[i] < obLine[i])   trends[r][_tob] = -1;
      if (diff[i] > osLine[i])   trends[r][_tos] =  1;
      if (diff[i] < osLine[i])   trends[r][_tos] = -1;
      if (diff[i] > zeroLine[i]) trends[r][_tzl] =  1;
      if (diff[i] < zeroLine[i]) trends[r][_tzl] = -1;      
}

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
      if (alertsOnobLineCross && trends[whichBar][_tob] != trends[whichBar-1][_tob])
      {
         if (trends[whichBar][_tob] ==  1) doAlert(time1,mess1,whichBar,"Crossing oversold line up");
         if (trends[whichBar][_tob] == -1) doAlert(time1,mess1,whichBar,"Crossing oversold line down");
      }
      
      static datetime time2 = 0;
      static string   mess2 = "";
      if (alertsOnosLineCross && trends[whichBar][_tos] != trends[whichBar-1][_tos])
      {
         if (trends[whichBar][_tos] ==  1) doAlert(time2,mess2,whichBar,"Crossing overbought up");
         if (trends[whichBar][_tos] == -1) doAlert(time2,mess2,whichBar,"Crossing overbought down");
      } 
      
      static datetime time3 = 0;
      static string   mess3 = "";
      if (alertsOnzeroLineCross && trends[whichBar][_tzl] != trends[whichBar-1][_tzl])
      {
         if (trends[whichBar][_tzl] ==  1) doAlert(time3,mess3,whichBar,"Crossing zero line up");
         if (trends[whichBar][_tzl] == -1) doAlert(time3,mess3,whichBar,"Crossing zero line down");
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

       message =  StringConcatenate(Symbol()," ",timeFrameToString(timeFrame)," at ",TimeToStr(TimeLocal(),TIME_SECONDS)," Dz Absolute Strength of Averages ",doWhat);
          if (alertsMessage) Alert(message);
          if (alertsNotify)  SendNotification(message);
          if (alertsEmail)   SendMail(StringConcatenate(Symbol()," Dz Absolute Strength of Averages "),message);
          if (alertsSound)   PlaySound("alert2.wav");
   }
}