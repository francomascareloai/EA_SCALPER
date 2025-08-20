//+------------------------------------------------------------------+
//|                                       Polychromatic momentum.mq4 |
//|                                                                  |
//| Polychromatic momentum originaly developed                       |
//| by Dennis Meyers                                                 |
//|                                                                  |
//+------------------------------------------------------------------+
#property indicator_separate_window
#property indicator_buffers 4
#property indicator_color1  clrDimGray
#property indicator_color2  clrDarkOrange
#property indicator_color3  clrLimeGreen
#property indicator_color4  clrLimeGreen
#property indicator_style1  STYLE_DOT
#property indicator_style2  STYLE_DOT
#property indicator_style3  STYLE_DOT
#property indicator_width4  2
#property strict

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

extern ENUM_TIMEFRAMES TimeFrame        = PERIOD_CURRENT;        // Time frame to use
extern string UniqueID                  = "DZPCM";               // Unique ID for the indicator
extern int    MomentumLength            = 20;                    // Momentum length
extern enPrices Price                   = pr_close;              // Price to use
extern double SmoothLength              = 5;                     // Smoothing length
extern double SmoothPhase               = 0;                     // Smoothing phase
extern int    DzLookBackBars            = 35;                    // Dynamic zones look back bars
extern double DzStartBuyProbability     = 0.05;                  // Dynamic zones buy probability
extern double DzStartSellProbability    = 0.05;                  // Dynamic zones sell probability
extern color  ColorUp                   = clrLimeGreen;          // Color for up
extern color  ColorDown                 = clrOrangeRed;          // Color for down
extern int    ColorWidth                = 2;                     // Bars width
extern int    ColorBars                 = 1000;                  // Total bars to draw
extern bool   divergenceVisible         = false;                 // Divergence visible?
extern bool   divergenceOnValuesVisible = true;                  // Divergence on values should be visible?
extern bool   divergenceOnChartVisible  = true;                  // Divergence on chart should be visible?
extern color  divergenceBullishColor    = clrLimeGreen;          // Bullish divergence color
extern color  divergenceBearishColor    = clrOrangeRed;          // Bearish divergence color
extern bool   divergenceAlert           = true;                  // Divergence should alert?
extern bool   divergenceAlertsMessage   = true;                  // Divergence should show alert message?
extern bool   divergenceAlertsSound     = true;                  // Divergence alerts should play alert sound?
extern bool   divergenceAlertsEmail     = false;                 // Divergence alerts should send an email?
extern bool   divergenceAlertsNotify    = false;                 // Divergence alerts should send push notification?
extern string divergenceAlertsSoundName = "alert1.wav";          // Divergence alerts sound file
extern bool   ShowArrows                = false;                 // Arrows visible?
extern bool   arrowsCrossesVisible      = true;                  // Arrows on outer level cross visible?
extern bool   arrowsRevertsVisible      = true;                  // Arrows on reverts visible?
extern bool   arrowsMiddleVisible       = true;                  // Arrows on middle level cross visible?
extern double arrowsUpperGap            = 1.0;                   // Arrows upper gap
extern double arrowsLowerGap            = 1.0;                   // Arrows lower gap
extern color  arrowsUpColor             = clrLimeGreen;          // Arrows uuper color
extern color  arrowsDnColor             = clrOrangeRed;          // Arrows lower color
extern int    arrowsUpCode              = 241;                   // Arrows upper code
extern int    arrowsDnCode              = 242;                   // Arrows lower code
extern bool   alertsOn                  = false;                 // Turn alerts on?
extern bool   alertsOnobLineCross       = true;                  // Alert on ob line cross?
extern bool   alertsOnosLineCross       = true;                  // Alerts on os line cross?
extern bool   alertsOnmiLineCross       = true;                  // Alerts on middle line cross?
extern bool   alertsOnCurrent           = false;                 // Alerts on current (still opened) bar?
extern bool   alertsMessage             = true;                  // Alerts should display pop-up message?
extern bool   alertsSound               = true;                  // Alerts should play alert sound?
extern bool   alertsEmail               = false;                 // Alerts should send an email?
extern bool   alertsNotify              = true;                  // Alerts should send push notification?
extern bool   barsVisible               = true;                  // On chart bars visible?
extern int    widthWick                 = 0;                     // On chart bars wick width
extern int    widthBody                 = 2;                     // On chart bars body width
extern bool   drawInBackgound           = false;                 // On chart bars should be displayed in background?
extern bool   Interpolate               = true;                  // Interpolate in multi time frame mode?



//
//
//
//
//

double obLine[];
double osLine[];
double zeroLine[];
double buffer1[];
double buffer2[];
double ratios[];
double arrows[];
double arrowz[];

double trends[][3];
#define _tob 0
#define _tos 1
#define _tmi 2

string indicatorFileName;
bool   returnBars;
string shortName;

//------------------------------------------------------------------
//
//------------------------------------------------------------------
//
//
//
//
//

int window;
int init()
{
   MomentumLength = MathMax(MomentumLength,1);
     IndicatorBuffers(8);
         SetIndexBuffer(0,zeroLine);  
         SetIndexBuffer(1,obLine);    
         SetIndexBuffer(2,osLine);    
         SetIndexBuffer(3,buffer1);   SetIndexDrawBegin(3,MomentumLength);
         SetIndexBuffer(4,buffer2);
         SetIndexBuffer(5,ratios);
         SetIndexBuffer(6,arrows);
         SetIndexBuffer(7,arrowz);
   
         //
         //
         //
         //
         //
      
            indicatorFileName = WindowExpertName();
            returnBars        = (TimeFrame==-99);
            TimeFrame         = MathMax(TimeFrame,_Period);
      shortName =  UniqueID+" "+timeFrameToString(TimeFrame)+" ("+(string)MomentumLength+","+DoubleToStr(SmoothLength,2)+")";
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
   string lookFor       = UniqueID+":";
   int    lookForLength = StringLen(lookFor);
      for (int i=ObjectsTotal()-1; i>=0; i--) 
      {
         string name = ObjectName(i);  if (StringSubstr(name,0,lookForLength) == lookFor) ObjectDelete(name);
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

int start()
{
   window = WindowFind(shortName);
   int counted_bars = IndicatorCounted();
      if(counted_bars<0) return(-1);
      if(counted_bars>0) counted_bars--;
           int limit=MathMin(Bars-counted_bars,Bars-1);
           if (returnBars) { zeroLine[0] = MathMin(limit+1,Bars-1); return(0); }
           if (TimeFrame!=_Period)
           {
               limit = (int)MathMax(limit,MathMin(Bars-1,iCustom(NULL,TimeFrame,indicatorFileName,-99,0,0)*TimeFrame/_Period));
               for (int i=limit; i>=0; i--)
               {
                  int y = iBarShift(NULL,TimeFrame,Time[i]);
                     zeroLine[i] = iCustom(NULL,TimeFrame,indicatorFileName,PERIOD_CURRENT,UniqueID,MomentumLength,Price,SmoothLength,SmoothPhase,DzLookBackBars,DzStartBuyProbability,DzStartSellProbability,ColorUp,ColorDown,-1,ColorBars,divergenceVisible,divergenceOnValuesVisible,divergenceOnChartVisible,divergenceBullishColor,divergenceBearishColor,divergenceAlert,divergenceAlertsMessage,divergenceAlertsSound,divergenceAlertsEmail,divergenceAlertsNotify,divergenceAlertsSoundName,ShowArrows,arrowsCrossesVisible,arrowsRevertsVisible,arrowsMiddleVisible,arrowsUpperGap,arrowsLowerGap,arrowsUpColor,arrowsDnColor,arrowsUpCode,arrowsDnCode,alertsOn,alertsOnobLineCross,alertsOnosLineCross,alertsOnmiLineCross,alertsOnCurrent,alertsMessage,alertsSound,alertsEmail,alertsNotify,Interpolate,0,y);
                     obLine[i]   = iCustom(NULL,TimeFrame,indicatorFileName,PERIOD_CURRENT,UniqueID,MomentumLength,Price,SmoothLength,SmoothPhase,DzLookBackBars,DzStartBuyProbability,DzStartSellProbability,ColorUp,ColorDown,-1,ColorBars,divergenceVisible,divergenceOnValuesVisible,divergenceOnChartVisible,divergenceBullishColor,divergenceBearishColor,divergenceAlert,divergenceAlertsMessage,divergenceAlertsSound,divergenceAlertsEmail,divergenceAlertsNotify,divergenceAlertsSoundName,ShowArrows,arrowsCrossesVisible,arrowsRevertsVisible,arrowsMiddleVisible,arrowsUpperGap,arrowsLowerGap,arrowsUpColor,arrowsDnColor,arrowsUpCode,arrowsDnCode,alertsOn,alertsOnobLineCross,alertsOnosLineCross,alertsOnmiLineCross,alertsOnCurrent,alertsMessage,alertsSound,alertsEmail,alertsNotify,Interpolate,1,y);
                     osLine[i]   = iCustom(NULL,TimeFrame,indicatorFileName,PERIOD_CURRENT,UniqueID,MomentumLength,Price,SmoothLength,SmoothPhase,DzLookBackBars,DzStartBuyProbability,DzStartSellProbability,ColorUp,ColorDown,-1,ColorBars,divergenceVisible,divergenceOnValuesVisible,divergenceOnChartVisible,divergenceBullishColor,divergenceBearishColor,divergenceAlert,divergenceAlertsMessage,divergenceAlertsSound,divergenceAlertsEmail,divergenceAlertsNotify,divergenceAlertsSoundName,ShowArrows,arrowsCrossesVisible,arrowsRevertsVisible,arrowsMiddleVisible,arrowsUpperGap,arrowsLowerGap,arrowsUpColor,arrowsDnColor,arrowsUpCode,arrowsDnCode,alertsOn,alertsOnobLineCross,alertsOnosLineCross,alertsOnmiLineCross,alertsOnCurrent,alertsMessage,alertsSound,alertsEmail,alertsNotify,Interpolate,2,y);
                     buffer1[i]  = iCustom(NULL,TimeFrame,indicatorFileName,PERIOD_CURRENT,UniqueID,MomentumLength,Price,SmoothLength,SmoothPhase,DzLookBackBars,DzStartBuyProbability,DzStartSellProbability,ColorUp,ColorDown,-1,ColorBars,divergenceVisible,divergenceOnValuesVisible,divergenceOnChartVisible,divergenceBullishColor,divergenceBearishColor,divergenceAlert,divergenceAlertsMessage,divergenceAlertsSound,divergenceAlertsEmail,divergenceAlertsNotify,divergenceAlertsSoundName,ShowArrows,arrowsCrossesVisible,arrowsRevertsVisible,arrowsMiddleVisible,arrowsUpperGap,arrowsLowerGap,arrowsUpColor,arrowsDnColor,arrowsUpCode,arrowsDnCode,alertsOn,alertsOnobLineCross,alertsOnosLineCross,alertsOnmiLineCross,alertsOnCurrent,alertsMessage,alertsSound,alertsEmail,alertsNotify,Interpolate,3,y);
                     ratios[i]   = iCustom(NULL,TimeFrame,indicatorFileName,PERIOD_CURRENT,UniqueID,MomentumLength,Price,SmoothLength,SmoothPhase,DzLookBackBars,DzStartBuyProbability,DzStartSellProbability,ColorUp,ColorDown,-1,ColorBars,divergenceVisible,divergenceOnValuesVisible,divergenceOnChartVisible,divergenceBullishColor,divergenceBearishColor,divergenceAlert,divergenceAlertsMessage,divergenceAlertsSound,divergenceAlertsEmail,divergenceAlertsNotify,divergenceAlertsSoundName,ShowArrows,arrowsCrossesVisible,arrowsRevertsVisible,arrowsMiddleVisible,arrowsUpperGap,arrowsLowerGap,arrowsUpColor,arrowsDnColor,arrowsUpCode,arrowsDnCode,alertsOn,alertsOnobLineCross,alertsOnosLineCross,alertsOnmiLineCross,alertsOnCurrent,alertsMessage,alertsSound,alertsEmail,alertsNotify,Interpolate,5,y);

                     //
                     //
                     //
                     //
                     //
      
                     if (!Interpolate || (i>0 && y==iBarShift(NULL,TimeFrame,Time[i-1]))) continue;
                        interpolate(buffer1 ,TimeFrame,i);
                        interpolate(zeroLine,TimeFrame,i);
                        interpolate(obLine  ,TimeFrame,i);
                        interpolate(osLine  ,TimeFrame,i);
               }
               for (int i=limit; i>=0; i--)
               {
                  ObjectDelete(UniqueID+":c:"+(string)Time[i]);   
                  if (ratios[i] != -1 && i<Bars-1)
                  {
                     color theColor = gradientColor(100.0*ratios[i],101,ColorDown,ColorUp);
                        if (barsVisible) drawBar((int)Time[i],High[i],Low[i],Open[i],Close[i],theColor,theColor);
                                         plot(buffer1[i],buffer1[i+1],i,i+1,theColor,ColorWidth);
                  }
               }
               return(0);
           }

   //
   //
   //
   //
   //

   int cb = ColorBars; if (ColorBars==0) cb = Bars-1; cb = MathMin(Bars-1,cb);
   if (ArrayRange(trends,0)!=Bars) ArrayResize(trends,Bars); 
   for (int i=limit, r=Bars-i-1; i>=0; i--,r++)
   {
      buffer2[i] = getPrice(Price,Open,Close,High,Low,i);
      double sumMom = 0;
      double sumWgh = 0;
      for (int k=0; (i+k+1)<Bars && k<MomentumLength; k++)
      {
         double weight = MathSqrt(k+1);
               sumMom += (buffer2[i]-buffer2[i+k+1])/weight;
               sumWgh += weight;
      }
      if (sumWgh != 0)         
            buffer1[i] = iSmooth(sumMom/sumWgh,SmoothLength,SmoothPhase,i,0);
      else  buffer1[i] = iSmooth(0            ,SmoothLength,SmoothPhase,i,0);
      obLine[i]    = dzBuyP (buffer1, DzStartBuyProbability,  DzLookBackBars, Bars, i, 0.00001);
      osLine[i]    = dzSellP(buffer1, DzStartSellProbability, DzLookBackBars, Bars, i, 0.00001);
      zeroLine[i]  = dzSellP(buffer1, 0.5,                    DzLookBackBars, Bars, i, 0.00001);
      ratios[i]    = -1;
         
         //
         //
         //
         //
         //
            
         if (divergenceVisible)
         {
            CatchBullishDivergence(buffer1,i);
            CatchBearishDivergence(buffer1,i);
         }
         ObjectDelete(UniqueID+":c:"+(string)Time[i]);   
         if (cb>=i)
         {
            double ratio = MathMin(buffer1[i],osLine[i]);
                   ratio = MathMax(ratio     ,obLine[i]);
                   if ((osLine[i]-obLine[i]) != 0)
                        ratio = (ratio-obLine[i])/(osLine[i]-obLine[i]);
                  else  ratio = 0; 
                  if (ColorWidth>=0)
                  {
                        color theColor = gradientColor(100.0*ratio,101,ColorDown,ColorUp);
                           if (barsVisible) drawBar((int)Time[i],High[i],Low[i],Open[i],Close[i],theColor,theColor);
                                            plot(buffer1[i],buffer1[i+1],i,i+1,theColor,ColorWidth);
                  }                        
                  ratios[i] = ratio;
         }
         setTrends(i,r);
            
         //
         //
         //
         //
         //
            
         if (ShowArrows && i<(Bars-1))
         {
            arrows[i] = 0;
            arrowz[i] = arrowz[i+1];
               if (buffer1[i]>osLine[i])   arrows[i] =  1;
               if (buffer1[i]<obLine[i])   arrows[i] = -1;
               if (buffer1[i]>zeroLine[i]) arrowz[i] =  1;
               if (buffer1[i]<zeroLine[i]) arrowz[i] = -1;
                 deleteArrow(Time[i]);
                 deleteArrow(Time[i],"m");
               if (arrows[i] != arrows[i+1])
               {
                  if (arrowsCrossesVisible && arrows[i] == 1)                       drawArrow(i,arrowsUpColor,arrowsUpCode,false);
                  if (arrowsCrossesVisible && arrows[i] ==-1)                       drawArrow(i,arrowsDnColor,arrowsDnCode, true);
                  if (arrowsRevertsVisible && arrows[i] == 0 && arrows[i+1] ==  1)  drawArrow(i,arrowsDnColor,arrowsDnCode, true);
                  if (arrowsRevertsVisible && arrows[i] == 0 && arrows[i+1] == -1)  drawArrow(i,arrowsUpColor,arrowsUpCode,false);
               }
               if (arrowsMiddleVisible && arrowz[i] != arrowz[i+1])
               {
                  if (arrowz[i] == 1) drawArrow(i,arrowsUpColor,arrowsUpCode,false,"m");
                  if (arrowz[i] ==-1) drawArrow(i,arrowsDnColor,arrowsDnCode, true,"m");
               }
         }
   }
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

double wrk[][10];

#define bsmax  5
#define bsmin  6
#define volty  7
#define vsum   8
#define avolty 9

double iSmooth(double price, double length, double phase, int i, int s=0)
{
   if (length <=1) return(price);
   if (ArrayRange(wrk,0) != Bars) ArrayResize(wrk,Bars);
   
   int k,r = Bars-i-1; 
      if (r==0) { for(k=0; k<7; k++) wrk[r][k+s]=price; for(; k<10; k++) wrk[r][k+s]=0; return(price); }

   //
   //
   //
   //
   //
   
      double len1   = MathMax(MathLog(MathSqrt(0.5*(length-1)))/MathLog(2.0)+2.0,0);
      double pow1   = MathMax(len1-2.0,0.5);
      double del1   = price - wrk[r-1][bsmax+s];
      double del2   = price - wrk[r-1][bsmin+s];
      double div    = 1.0/(10.0+10.0*(MathMin(MathMax(length-10,0),100))/100);
      int    forBar = MathMin(r,10);
	
         wrk[r][volty+s] = 0;
               if(MathAbs(del1) > MathAbs(del2)) wrk[r][volty+s] = MathAbs(del1); 
               if(MathAbs(del1) < MathAbs(del2)) wrk[r][volty+s] = MathAbs(del2); 
         wrk[r][vsum+s] =	wrk[r-1][vsum+s] + (wrk[r][volty+s]-wrk[r-forBar][volty+s])*div;
         
         //
         //
         //
         //
         //
   
         wrk[r][avolty+s] = wrk[r-1][avolty+s]+(2.0/(MathMax(4.0*length,30)+1.0))*(wrk[r][vsum+s]-wrk[r-1][avolty+s]);
            double dVolty = 0;   
            if (wrk[r][avolty+s] > 0)
               dVolty = wrk[r][volty+s]/wrk[r][avolty+s]; else 
	               if (dVolty > MathPow(len1,1.0/pow1)) dVolty = MathPow(len1,1.0/pow1);
                  if (dVolty < 1)                      dVolty = 1.0;

      //
      //
      //
      //
      //
	        
   	double pow2 = MathPow(dVolty, pow1);
      double len2 = MathSqrt(0.5*(length-1))*len1;
      double Kv   = MathPow(len2/(len2+1), MathSqrt(pow2));

         if (del1 > 0) wrk[r][bsmax+s] = price; else wrk[r][bsmax+s] = price - Kv*del1;
         if (del2 < 0) wrk[r][bsmin+s] = price; else wrk[r][bsmin+s] = price - Kv*del2;
	
   //
   //
   //
   //
   //
      
      double R     = MathMax(MathMin(phase,100),-100)/100.0 + 1.5;
      double beta  = 0.45*(length-1)/(0.45*(length-1)+2);
      double alpha = MathPow(beta,pow2);

         wrk[r][0+s] = price + alpha*(wrk[r-1][0+s]-price);
         wrk[r][1+s] = (price - wrk[r][0+s])*(1-beta) + beta*wrk[r-1][1+s];
         wrk[r][2+s] = (wrk[r][0+s] + R*wrk[r][1+s]);
         wrk[r][3+s] = (wrk[r][2+s] - wrk[r-1][4+s])*MathPow((1-alpha),2) + MathPow(alpha,2)*wrk[r-1][3+s];
         wrk[r][4+s] = (wrk[r-1][4+s] + wrk[r][3+s]); 

   return(wrk[r][4+s]);
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
      double y1 = target[(int)MathMin(iBarShift(NULL,0,iTime(NULL,ttimeFrame,t+0))+1,Bars-1)];
      double y2 = target[(int)MathMin(iBarShift(NULL,0,iTime(NULL,ttimeFrame,t+1))+1,Bars-1)];

      //
      //
      //
      //
      //
      
      int n,k; datetime time = iTime(NULL,ttimeFrame,t);
         for(n = 1; i+n < Bars && Time[i+n] >= time; n++) continue;
         for(k = 1; i+n < Bars && i+k < Bars && k < n; k++)
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
   i++; if (i>=Bars-1) return;
            ObjectDelete(UniqueID+":bd:l"+DoubleToStr(Time[i],0));
            ObjectDelete(UniqueID+":bd:los" + DoubleToStr(Time[i],0));            
   if (!IsIndicatorLow(values,i)) return;  

   //
   //
   //
   //
   //

   int currentLow = i;
   int lastLow    = GetIndicatorLastLow(values,i+1);
      if (lastLow>=0 && values[currentLow] > values[lastLow] && Low[currentLow] < Low[lastLow])
      {
         if(divergenceOnChartVisible)  DrawPriceTrendLine("l",Time[currentLow],Time[lastLow],Low[currentLow],Low[lastLow],divergenceBullishColor,STYLE_SOLID);
         if(divergenceOnValuesVisible) DrawIndicatorTrendLine("l",Time[currentLow],Time[lastLow],values[currentLow],values[lastLow],divergenceBullishColor,STYLE_SOLID);
         if (divergenceAlert)          DisplayAlert("Classical bullish divergence",currentLow);  
      }
      if (lastLow>=0 && values[currentLow] < values[lastLow] && Low[currentLow] > Low[lastLow])
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
   i++; if (i>=Bars-1) return;
            ObjectDelete(UniqueID+":ed:h"+DoubleToStr(Time[i],0));
            ObjectDelete(UniqueID+":ed:hos" + DoubleToStr(Time[i],0));            
   if (IsIndicatorPeak(values,i) == false) return;

   //
   //
   //
   //
   //
      
   int currentPeak = i;
   int lastPeak = GetIndicatorLastPeak(values,i+1);
      if (lastPeak>=0 && values[currentPeak] < values[lastPeak] && High[currentPeak]>High[lastPeak])
      {
         if (divergenceOnChartVisible)  DrawPriceTrendLine("h",Time[currentPeak],Time[lastPeak],High[currentPeak],High[lastPeak],divergenceBearishColor,STYLE_SOLID);
         if (divergenceOnValuesVisible) DrawIndicatorTrendLine("h",Time[currentPeak],Time[lastPeak],values[currentPeak],values[lastPeak],divergenceBearishColor,STYLE_SOLID);
         if (divergenceAlert)           DisplayAlert("Classical bearish divergence",currentPeak);
      }
      if(lastPeak>=0 && values[currentPeak] > values[lastPeak] && High[currentPeak] < High[lastPeak])
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

bool IsIndicatorPeak(double& values[], int i) { return(values[i] >= values[(int)MathMin(i+1,Bars-1)] && values[i] > values[(int)MathMin(i+2,Bars-1)] && values[i] > values[(int)MathMax(i-1,0)]); }
bool IsIndicatorLow( double& values[], int i) { return(values[i] <= values[(int)MathMin(i+1,Bars-1)] && values[i] < values[(int)MathMin(i+2,Bars-1)] && values[i] < values[(int)MathMax(i-1,0)]); }

int GetIndicatorLastPeak(double& values[], int shift)
{
   for(int i = shift+5;  i<Bars-2 && i>1; i++)
         if (values[i] >= values[i+1] && values[i] > values[i+2] && values[i] >= values[i-1] && values[i] > values[i-2]) return(i);
   return(-1);
}
int GetIndicatorLastLow(double& values[], int shift)
{
   for(int i = shift+5; i<Bars-2 && i>1; i++)
         if (values[i] <= values[i+1] && values[i] < values[i+2] && values[i] <= values[i-1] && values[i] < values[i-2]) return(i);
   return(-1);
}


//------------------------------------------------------------------
//
//------------------------------------------------------------------
//
//
//
//
//

void DrawPriceTrendLine(string first,datetime t1, datetime t2, double p1, double p2, color lineColor, double style)
{
   string   label = UniqueID+":dl:"+first+"os"+DoubleToStr(t1,0);
    
   ObjectDelete(label);
      ObjectCreate(label, OBJ_TREND, 0, t1+Period()*60-1, p1, t2, p2, 0, 0);
         ObjectSet(label, OBJPROP_RAY, false);
         ObjectSet(label, OBJPROP_COLOR, lineColor);
         ObjectSet(label, OBJPROP_STYLE, style);
         ObjectSet(label, OBJPROP_HIDDEN, true);
         ObjectSet(label, OBJPROP_SELECTABLE, false);
}
void DrawIndicatorTrendLine(string first,datetime t1, datetime t2, double p1, double p2, color lineColor, double style)
{
   int indicatorWindow = WindowFind(shortName);
   if (indicatorWindow < 0) return;
   
   string label = UniqueID+":dl:"+first+DoubleToStr(t1,0);
   ObjectDelete(label);
      ObjectCreate(label, OBJ_TREND, indicatorWindow, t1+Period()*60-1, p1, t2, p2, 0, 0);
         ObjectSet(label, OBJPROP_RAY, false);
         ObjectSet(label, OBJPROP_COLOR, lineColor);
         ObjectSet(label, OBJPROP_STYLE, style);
         ObjectSet(label, OBJPROP_HIDDEN, true);
         ObjectSet(label, OBJPROP_SELECTABLE, false);
}

//
//
//
//
//

void plot(double valueA, double valueB, int shiftA, int shiftB, color theColor, int width=0,int style=STYLE_SOLID)
{
   string name = UniqueID+":c:"+(string)Time[shiftA];
   ObjectDelete(name);   
       ObjectCreate(name,OBJ_TREND,window,Time[shiftA],valueA,Time[(int)MathMin(shiftB,Bars-1)],valueB);
          ObjectSet(name,OBJPROP_RAY,false);
          ObjectSet(name,OBJPROP_BACK,false);
          ObjectSet(name,OBJPROP_STYLE,style);
          ObjectSet(name,OBJPROP_WIDTH,width);
          ObjectSet(name,OBJPROP_COLOR,theColor);
          ObjectSet(name,OBJPROP_PRICE1,valueA);
          ObjectSet(name,OBJPROP_PRICE2,valueB);
          ObjectSet(name, OBJPROP_HIDDEN, true);
          ObjectSet(name, OBJPROP_SELECTABLE, false);
}
void drawBar(int bTime, double prHigh, double prLow, double prOpen, double prClose, color barColor, color wickColor)
{
   string oName;
          oName = UniqueID+":c:w"+TimeToStr(bTime);
            if (ObjectFind(oName) < 0) ObjectCreate(oName,OBJ_TREND,0,bTime,0,bTime,0);
                 ObjectSet(oName, OBJPROP_PRICE1, prHigh);
                 ObjectSet(oName, OBJPROP_PRICE2, prLow);
                 ObjectSet(oName, OBJPROP_COLOR, wickColor);
                 ObjectSet(oName, OBJPROP_WIDTH, widthWick);
                 ObjectSet(oName, OBJPROP_RAY, false);
                 ObjectSet(oName, OBJPROP_BACK, drawInBackgound);
                 ObjectSet(oName, OBJPROP_HIDDEN, true);
                 ObjectSet(oName, OBJPROP_SELECTABLE, false);
           
         oName = UniqueID+":c:b"+TimeToStr(bTime);
            if (ObjectFind(oName) < 0)ObjectCreate(oName,OBJ_TREND,0,bTime,0,bTime,0);
                 ObjectSet(oName, OBJPROP_PRICE1, prOpen);
                 ObjectSet(oName, OBJPROP_PRICE2, prClose);
                 ObjectSet(oName, OBJPROP_COLOR, barColor);
                 ObjectSet(oName, OBJPROP_WIDTH, widthBody);
                 ObjectSet(oName, OBJPROP_RAY, false);
                 ObjectSet(oName, OBJPROP_BACK, drawInBackgound);
                 ObjectSet(oName, OBJPROP_HIDDEN, true);
                 ObjectSet(oName, OBJPROP_SELECTABLE, false);
}

//
//
//
//
//

void drawArrow(int i,color theColor,int theCode,bool up, string add="")
{
   string name = UniqueID+":a:"+add+(string)Time[i];
   double gap  = iATR(NULL,0,20,i);   
   
      //
      //
      //
      //
      //
      
      ObjectCreate(name,OBJ_ARROW,0,Time[i],0);
         ObjectSet(name,OBJPROP_ARROWCODE,theCode);
         ObjectSet(name,OBJPROP_COLOR,theColor);
         if (up)
               ObjectSet(name,OBJPROP_PRICE1,High[i] + arrowsUpperGap * gap);
         else  ObjectSet(name,OBJPROP_PRICE1,Low[i]  - arrowsLowerGap * gap);
         ObjectSet(name,OBJPROP_HIDDEN,true);
         ObjectSet(name,OBJPROP_SELECTABLE,false);
}
void deleteArrow(datetime time, string add = "") { string lookFor = UniqueID+":a:"+add+(string)time; ObjectDelete(lookFor); }


//------------------------------------------------------------------
//
//------------------------------------------------------------------
//
//
//
//
//

color gradientColor(double step, int totalSteps, color from, color to)
{
   step = (int)MathMax(MathMin(step,totalSteps-1),0);
      color newBlue  = getColor((int)step,totalSteps,(from & 0XFF0000)>>16,(to & 0XFF0000)>>16)<<16;
      color newGreen = getColor((int)step,totalSteps,(from & 0X00FF00)>> 8,(to & 0X00FF00)>> 8) <<8;
      color newRed   = getColor((int)step,totalSteps,(from & 0X0000FF)    ,(to & 0X0000FF)    )    ;
      return(newBlue+newGreen+newRed);
}
color getColor(int stepNo, int totalSteps, color from, color to)
{
   double step = (from-to)/(totalSteps-1.0);
   return((color)MathRound(from-step*stepNo));
}

//
//
//
//
//

void setTrends(int i, int r)
{
   if (r>0)
   {
   trends[r][_tob] = trends[r-1][_tob];
   trends[r][_tos] = trends[r-1][_tos];
   trends[r][_tmi] = trends[r-1][_tmi];
   
      if (buffer1[i] > obLine[i])   trends[r][_tob] =  1;
      if (buffer1[i] < obLine[i])   trends[r][_tob] = -1;
      if (buffer1[i] > osLine[i])   trends[r][_tos] =  1;
      if (buffer1[i] < osLine[i])   trends[r][_tos] = -1;     
      if (buffer1[i] > zeroLine[i]) trends[r][_tmi] =  1;
      if (buffer1[i] < zeroLine[i]) trends[r][_tmi] = -1;     
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
//

void manageAlerts()
{
   if (alertsOn)
   {
      int whichBar = 1; if (alertsOnCurrent) whichBar = 0; whichBar = Bars-whichBar-1;

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
      if (alertsOnmiLineCross && trends[whichBar][_tmi] != trends[whichBar-1][_tmi])
      {
         if (trends[whichBar][_tmi] ==  1) doAlert(time3,mess3,whichBar,"Crossing zero line up");
         if (trends[whichBar][_tmi] == -1) doAlert(time3,mess3,whichBar,"Crossing zero line down");
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

       message = Symbol()+" "+timeFrameToString(_Period)+" at "+TimeToStr(TimeLocal(),TIME_SECONDS)+" Dz Polychromatic momentum "+doWhat;
          if (alertsMessage) Alert(message);
          if (alertsNotify)  SendNotification(StringConcatenate(Symbol(), Period() ," Polychromatic momentum " +" "+message));
          if (alertsEmail)   SendMail(StringConcatenate(Symbol()," Dz Polychromatic momentum "),message);
          if (alertsSound)   PlaySound("alert2.wav");
   }
}

void DisplayAlert(string doWhat, int shift)
{
    string dmessage;
    static datetime lastAlertTime;
    if(shift <= 2 && Time[0] != lastAlertTime)
    {
      dmessage = Symbol()+" at "+TimeToStr(TimeLocal(),TIME_SECONDS)+" Polychromatic momentum "+doWhat;
          if (divergenceAlertsMessage) Alert(dmessage);
          if (divergenceAlertsNotify)  SendNotification(StringConcatenate(Symbol(), Period() ," Polychromatic momentum " +" "+dmessage));
          if (divergenceAlertsEmail)   SendMail(StringConcatenate(Symbol()," Polychromatic momentum "),dmessage);
          if (divergenceAlertsSound)   PlaySound(divergenceAlertsSoundName); 
          lastAlertTime = Time[0];
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
//

#define priceInstances 1
double workHa[][priceInstances*4];
double getPrice(int tprice, const double& open[], const double& close[], const double& high[], const double& low[], int i, int instanceNo=0)
{
  if (tprice>=pr_haclose)
   {
      if (ArrayRange(workHa,0)!= Bars) ArrayResize(workHa,Bars); instanceNo*=4;
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