//+------------------------------------------------------------------+

#property link      "www.forex-station.com"  
#property copyright "www.forex-station.com"

#property indicator_separate_window
#property indicator_minimum    0
#property indicator_maximum    100
#property indicator_buffers    7
#property indicator_color1     Aqua
#property indicator_color2     Magenta
#property indicator_color3     SteelBlue
#property indicator_color4     LimeGreen
#property indicator_color5     LimeGreen
#property indicator_color6     Orange
#property indicator_color7     Orange
#property indicator_width3     2
#property indicator_width4     2
#property indicator_width5     2
#property indicator_width6     2
#property indicator_width7     2
#property indicator_levelcolor DarkSlateGray

//
//
//
//
//

extern string TimeFrame                 = "Current time frame";
extern int    RsiPeriod                 = 14;
extern int    Price                     = 0;
extern int    DivergearrowSize          = 0;
extern bool   drawDivergences           = true;
extern bool   ShowClassicalDivergence   = true;
extern bool   ShowHiddenDivergence      = true;
extern bool   drawIndicatorTrendLines   = true;
extern bool   drawPriceTrendLines       = true;
extern color  divergenceBullishColor    = Lime;
extern color  divergenceBearishColor    = Magenta;
extern string drawLinesIdentificator    = "rsidiverge1";
extern bool   divergenceAlert           = true;
extern bool   divergenceAlertsMessage   = true;
extern bool   divergenceAlertsSound     = true;
extern bool   divergenceAlertsEmail     = false;
extern bool   divergenceAlertsNotify    = false;
extern string divergenceAlertsSoundName = "alert1.wav";
extern bool   alertsOn                  = true;
extern bool   alertsOnCurrent           = false;
extern bool   alertsMessage             = true;
extern bool   alertsSound               = false;
extern bool   alertsNotify              = false;
extern bool   alertsEmail               = false;
extern string soundFile                 = "alert2.wav";
extern bool   Interpolate               = true;

extern double levelOb                   = 70;
extern double levelOs                   = 30;

double bullishDivergence[],bearishDivergence[],rsi[],valUa[],valUb[],valDa[],valDb[],valc[];
string indicatorName,labelNames,indicatorFileName;
bool   calculateValue,returnBars;
int    timeFrame;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
//
//

int init()
{
   IndicatorBuffers(8); 
   SetIndexBuffer(0, bullishDivergence); SetIndexStyle(0,DRAW_ARROW,0,DivergearrowSize); SetIndexArrow(0,233);
   SetIndexBuffer(1, bearishDivergence); SetIndexStyle(1,DRAW_ARROW,0,DivergearrowSize); SetIndexArrow(1,234);  
   SetIndexBuffer(2, rsi);   SetIndexStyle(2,DRAW_LINE); 
   SetIndexBuffer(3, valUa); SetIndexStyle(3,DRAW_LINE); 
   SetIndexBuffer(4, valUb); SetIndexStyle(4,DRAW_LINE); 
   SetIndexBuffer(5, valDa); SetIndexStyle(5,DRAW_LINE);  
   SetIndexBuffer(6, valDb); SetIndexStyle(6,DRAW_LINE); 
   SetIndexBuffer(7, valc); 
   
   SetLevelValue(0,levelOb);
   SetLevelValue(1,50);
   SetLevelValue(2,levelOs);
   
      //
      //
      //
      //
      //
      
      timeFrame     = stringToTimeFrame(TimeFrame);
      labelNames    = "RSI_DivergenceLine "+drawLinesIdentificator+":";
      indicatorName = timeFrameToString(timeFrame)+" RSI";
      IndicatorShortName(indicatorName);
      
      //
      //
      //
      //
      //
      
      indicatorFileName = WindowExpertName();
      calculateValue    = (TimeFrame=="calculateValue"); if (calculateValue) return(0);
      returnBars        = (TimeFrame=="returnBars");     if (returnBars)     return(0);
return (0);
}

//
//
//
//
//

int deinit()
{
   int length=StringLen(labelNames);
   for(int i=ObjectsTotal()-1; i>=0; i--)
   {
      string name = ObjectName(i);
      if(StringSubstr(name,0,length) == labelNames)  ObjectDelete(name);   
   }
   return(0);
}

//
//
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+

int start()
{
   int i,limit,counted_bars=IndicatorCounted();

   if(counted_bars<0) return(-1);
   if(counted_bars>0) counted_bars--;
         limit = MathMin(Bars-counted_bars,Bars-1);
         if (returnBars)  { bullishDivergence[0] = limit+1; return(0); }
   
   //
   //
   //
   //
   //
   
   if (calculateValue || timeFrame == Period())
   {  
     if (valc[limit]== 1) iCleanPoint(limit,Bars,valUa,valUb);
     if (valc[limit]==-1) iCleanPoint(limit,Bars,valDa,valDb);  
     for(i=limit; i >= 0; i--) 
     {
        rsi[i] = iRsi(iMA(NULL,0,1,0,MODE_SMA,Price,i),RsiPeriod,i);
        valUa[i]= valUb[i] = valDa[i] = valDb[i] = EMPTY_VALUE;
        valc[i] = (i<Bars-1) ? (rsi[i]>levelOb) ? 1 : (rsi[i]<levelOs) ? -1 : (rsi[i]<levelOb && rsi[i]>levelOs) ? 0 : valc[i+1] : 0; 
        if (valc[i] ==  1) iPlotPoint(i,Bars,valUa,valUb,rsi);
        if (valc[i] == -1) iPlotPoint(i,Bars,valDa,valDb,rsi);                  
        if (drawDivergences){CatchBullishDivergence(i);CatchBearishDivergence(i);}         
      }
   
   //
   //
   //
   //
   //
      
   if (alertsOn)
   {
      if (alertsOnCurrent)
           int whichBar = 0;
      else     whichBar = 1;
      if (valc[whichBar] != valc[whichBar+1])
      if (valc[whichBar] == 1)
            doAlert("entering oversold");
      else  doAlert("entering overbought");       
   }        
   return(0);           
   }
   
   //
   //
   //
   //
   //
   
   limit = MathMax(limit,MathMin(Bars-1,iCustom(NULL,timeFrame,indicatorFileName,"returnBars",0,0)*timeFrame/Period()));
   if (valc[limit]== 1) iCleanPoint(limit,Bars,valUa,valUb);
   if (valc[limit]==-1) iCleanPoint(limit,Bars,valDa,valDb);  
   for(i=limit; i >= 0; i--)  
   {
      int y = iBarShift(NULL,timeFrame,Time[i]);
         rsi[i]               = iCustom(NULL,timeFrame,indicatorFileName,"calculateValue",RsiPeriod,Price,DivergearrowSize,drawDivergences,ShowClassicalDivergence,ShowHiddenDivergence,drawIndicatorTrendLines,drawPriceTrendLines,divergenceBullishColor,divergenceBearishColor,drawLinesIdentificator,divergenceAlert,divergenceAlertsMessage,divergenceAlertsSound,divergenceAlertsEmail,divergenceAlertsNotify,divergenceAlertsSoundName,alertsOn,alertsOnCurrent,alertsMessage,alertsSound,alertsNotify,alertsEmail,soundFile,false,2,y);
         valc[i]              = iCustom(NULL,timeFrame,indicatorFileName,"calculateValue",RsiPeriod,Price,DivergearrowSize,drawDivergences,ShowClassicalDivergence,ShowHiddenDivergence,drawIndicatorTrendLines,drawPriceTrendLines,divergenceBullishColor,divergenceBearishColor,drawLinesIdentificator,divergenceAlert,divergenceAlertsMessage,divergenceAlertsSound,divergenceAlertsEmail,divergenceAlertsNotify,divergenceAlertsSoundName,alertsOn,alertsOnCurrent,alertsMessage,alertsSound,alertsNotify,alertsEmail,soundFile,false,7,y);
         bullishDivergence[i] = bearishDivergence[i] = EMPTY_VALUE;
         valUa[i]= valUb[i] = valDa[i] = valDb[i] = EMPTY_VALUE;
             
      int firstBar = iBarShift(NULL,0,iTime(NULL,timeFrame,y));
      if (i==firstBar)
      {
         bullishDivergence[i] = iCustom(NULL,timeFrame,indicatorFileName,"calculateValue",RsiPeriod,Price,DivergearrowSize,drawDivergences,ShowClassicalDivergence,ShowHiddenDivergence,drawIndicatorTrendLines,drawPriceTrendLines,divergenceBullishColor,divergenceBearishColor,drawLinesIdentificator,divergenceAlert,divergenceAlertsMessage,divergenceAlertsSound,divergenceAlertsEmail,divergenceAlertsNotify,divergenceAlertsSoundName,alertsOn,alertsOnCurrent,alertsMessage,alertsSound,alertsNotify,alertsEmail,soundFile,false,0,y);
         bearishDivergence[i] = iCustom(NULL,timeFrame,indicatorFileName,"calculateValue",RsiPeriod,Price,DivergearrowSize,drawDivergences,ShowClassicalDivergence,ShowHiddenDivergence,drawIndicatorTrendLines,drawPriceTrendLines,divergenceBullishColor,divergenceBearishColor,drawLinesIdentificator,divergenceAlert,divergenceAlertsMessage,divergenceAlertsSound,divergenceAlertsEmail,divergenceAlertsNotify,divergenceAlertsSoundName,alertsOn,alertsOnCurrent,alertsMessage,alertsSound,alertsNotify,alertsEmail,soundFile,false,1,y);
      } 
      
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
         for(int n = 1; i+n < Bars && Time[i+n] >= time; n++) continue;	
         for(int k = 1; k < n; k++) rsi[i+k] = rsi[i] + (rsi[i+n] - rsi[i])*k/n;
  }
  for (i=limit;i>=0;i--) 
  {
     if (valc[i] ==  1) iPlotPoint(i,Bars,valUa,valUb,rsi);
     if (valc[i] == -1) iPlotPoint(i,Bars,valDa,valDb,rsi);                  
   }
return(0);
}      

//+------------------------------------------------------------------
//|                                                                  
//+------------------------------------------------------------------
//
//
//
//
//
//

double workRsi[][3];
#define _price  0
#define _change 1
#define _changa 2

//
//
//
//

double iRsi(double price, double period, int shift, int forz=0)
{
   if (ArrayRange(workRsi,0)!=Bars) ArrayResize(workRsi,Bars);
      int    z     = forz*3; 
      int    i     = Bars-shift-1;
      double alpha = 1.0/period; 

   //
   //
   //
   //
   //
   
   workRsi[i][_price+z] = price;
   if (i<period)
      {
         int k; double sum = 0; for (k=0; k<period && (i-k-1)>=0; k++) sum += MathAbs(workRsi[i-k][_price+z]-workRsi[i-k-1][_price+z]);
            workRsi[i][_change+z] = (workRsi[i][_price+z]-workRsi[0][_price+z])/MathMax(k,1);
            workRsi[i][_changa+z] =                                         sum/MathMax(k,1);
      }
   else
      {
         double change = workRsi[i][_price+z]-workRsi[i-1][_price+z];
                         workRsi[i][_change+z] = workRsi[i-1][_change+z] + alpha*(        change  - workRsi[i-1][_change+z]);
                         workRsi[i][_changa+z] = workRsi[i-1][_changa+z] + alpha*(MathAbs(change) - workRsi[i-1][_changa+z]);
      }
   if (workRsi[i][_changa+z] != 0)
         return(50.0*(workRsi[i][_change+z]/workRsi[i][_changa+z]+1));
   else  return(0);
}

//
//
//

void iCleanPoint(int i,int bars,double& first[],double& second[])
{
   if (i>=bars-3) return;
   if ((second[i]  != EMPTY_VALUE) && (second[i+1] != EMPTY_VALUE))
        second[i+1] = EMPTY_VALUE;
   else
      if ((first[i] != EMPTY_VALUE) && (first[i+1] != EMPTY_VALUE) && (first[i+2] == EMPTY_VALUE))
          first[i+1] = EMPTY_VALUE;
}
void iPlotPoint(int i,int bars,double& first[],double& second[],double& from[])
{
   if (i>=bars-2) return;
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

void CatchBullishDivergence(int shift)
{
   shift++;
         bullishDivergence[shift] = EMPTY_VALUE;
            ObjectDelete(labelNames+"l"+DoubleToStr(Time[shift],0));
            ObjectDelete(labelNames+"l"+"os" + DoubleToStr(Time[shift],0));            
   if(!IsIndicatorLow(shift)) return;  

   //
   //
   //
   //
   //
      
   int currentLow = shift;
   int lastLow    = GetIndicatorLastLow(shift+1);
   if (rsi[currentLow] > rsi[lastLow] && Low[currentLow] < Low[lastLow])
   {
     if (ShowClassicalDivergence)
     {
        bullishDivergence[currentLow] = rsi[currentLow] - iStdDevOnArray(rsi,0,10,0,MODE_SMA,currentLow);
        if (drawPriceTrendLines)    DrawPriceTrendLine("l",Time[currentLow],Time[lastLow],Low[currentLow],Low[lastLow],    divergenceBullishColor,STYLE_SOLID);
        if (drawIndicatorTrendLines)DrawIndicatorTrendLine("l",Time[currentLow],Time[lastLow],rsi[currentLow],rsi[lastLow],divergenceBullishColor,STYLE_SOLID);
        if (divergenceAlert)        DisplayAlert("Classical bullish divergence",currentLow);  
     }
                        
   }
     
   //
   //
   //
   //
   //
        
   if (rsi[currentLow] < rsi[lastLow] && Low[currentLow] > Low[lastLow])
   {
     if (ShowHiddenDivergence)
     {
        bullishDivergence[currentLow] = rsi[currentLow] - iStdDevOnArray(rsi,0,10,0,MODE_SMA,currentLow);
        if (drawPriceTrendLines)     DrawPriceTrendLine("l",Time[currentLow],Time[lastLow],Low[currentLow],Low[lastLow],    divergenceBullishColor, STYLE_DOT);
        if (drawIndicatorTrendLines) DrawIndicatorTrendLine("l",Time[currentLow],Time[lastLow],rsi[currentLow],rsi[lastLow],divergenceBullishColor, STYLE_DOT);
        if (divergenceAlert)         DisplayAlert("Reverse bullish divergence",currentLow); 
     }
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

void CatchBearishDivergence(int shift)
{
   shift++; 
         bearishDivergence[shift] = EMPTY_VALUE;
            ObjectDelete(labelNames+"h"+DoubleToStr(Time[shift],0));
            ObjectDelete(labelNames+"h"+"os" + DoubleToStr(Time[shift],0));            
   if(IsIndicatorPeak(shift) == false) return;
   int currentPeak = shift;
   int lastPeak = GetIndicatorLastPeak(shift+1);

   //
   //
   //
   //
   //
      
   if (rsi[currentPeak] < rsi[lastPeak] && High[currentPeak]>High[lastPeak])
   {
     if (ShowClassicalDivergence)
     {
        bearishDivergence[currentPeak] = rsi[currentPeak] + iStdDevOnArray(rsi,0,10,0,MODE_SMA,currentPeak);
        if (drawPriceTrendLines)     DrawPriceTrendLine("h",Time[currentPeak],Time[lastPeak],High[currentPeak],High[lastPeak],  divergenceBearishColor,STYLE_SOLID);
        if (drawIndicatorTrendLines) DrawIndicatorTrendLine("h",Time[currentPeak],Time[lastPeak],rsi[currentPeak],rsi[lastPeak],divergenceBearishColor,STYLE_SOLID);
        if (divergenceAlert)         DisplayAlert("Classical bearish divergence",currentPeak);
     } 
                        
   }
   
   //
   //
   //
   //
   //

   if (rsi[currentPeak] > rsi[lastPeak] && High[currentPeak] < High[lastPeak])
   {
     if (ShowHiddenDivergence)
     {
        bearishDivergence[currentPeak] = rsi[currentPeak] + iStdDevOnArray(rsi,0,10,0,MODE_SMA,currentPeak);
        if (drawPriceTrendLines)     DrawPriceTrendLine("h",Time[currentPeak],Time[lastPeak],High[currentPeak],High[lastPeak],  divergenceBearishColor, STYLE_DOT);
        if (drawIndicatorTrendLines) DrawIndicatorTrendLine("h",Time[currentPeak],Time[lastPeak],rsi[currentPeak],rsi[lastPeak],divergenceBearishColor, STYLE_DOT);
        if (divergenceAlert)         DisplayAlert("Reverse bearish divergence",currentPeak);
     }
                         
   }   
}

//
//
//
//
//

bool IsIndicatorPeak(int shift)
{
   if(rsi[shift] >= rsi[shift+1] && rsi[shift] > rsi[shift+2] && rsi[shift] > rsi[shift-1])
       return(true);
   else 
       return(false);
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//
//

bool IsIndicatorLow(int shift)
{
   if(rsi[shift] <= rsi[shift+1] && rsi[shift] < rsi[shift+2] && rsi[shift] < rsi[shift-1])
       return(true);
   else 
       return(false);
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//
//

int GetIndicatorLastPeak(int shift)
{
    for(int i = shift+5; i < Bars; i++)
    {
       if(rsi[i] >= rsi[i+1] && rsi[i] > rsi[i+2] && rsi[i] >= rsi[i-1] && rsi[i] > rsi[i-2])
    return(i);
    }
return(-1);
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//
//

int GetIndicatorLastLow(int shift)
{
    for (int i = shift+5; i < Bars; i++)
    {
       if (rsi[i] <= rsi[i+1] && rsi[i] < rsi[i+2] && rsi[i] <= rsi[i-1] && rsi[i] < rsi[i-2])
    return(i);
    }
     
return(-1);
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
      dmessage =  StringConcatenate(Symbol()," at ",TimeToStr(TimeLocal(),TIME_SECONDS)," Rsi ",doWhat);
          if (divergenceAlertsMessage) Alert(dmessage);
          if (divergenceAlertsNotify)  SendNotification(dmessage);
          if (divergenceAlertsEmail)   SendMail(StringConcatenate(Symbol()," Rsi "),dmessage);
          if (divergenceAlertsSound)   PlaySound(divergenceAlertsSoundName); 
          lastAlertTime = Time[0];
    }
}

//
//
//
//
//

void DrawPriceTrendLine(string first,datetime t1, datetime t2, double p1, double p2, color lineColor, double style)
{
    string label = labelNames+first+"os"+DoubleToStr(t1,0);
      ObjectDelete(label);
      ObjectCreate(label, OBJ_TREND, 0, t1, p1, t2, p2, 0, 0);
         ObjectSet(label, OBJPROP_RAY, 0);
         ObjectSet(label, OBJPROP_COLOR, lineColor);
         ObjectSet(label, OBJPROP_STYLE, style);
}

//
//
//
//
//

void DrawIndicatorTrendLine(string first,datetime t1, datetime t2, double p1, double p2, color lineColor, double style)
{
    int indicatorWindow = WindowFind(indicatorName);
    if (indicatorWindow < 0) return;
    
    //
    //
    //
    //
    //
    
    string label = labelNames+first+DoubleToStr(t1,0);
      ObjectDelete(label);
      ObjectCreate(label, OBJ_TREND, indicatorWindow, t1, p1, t2, p2, 0, 0);
         ObjectSet(label, OBJPROP_RAY, 0);
         ObjectSet(label, OBJPROP_COLOR, lineColor);
         ObjectSet(label, OBJPROP_STYLE, style);
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
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
   tfs = StringUpperCase(tfs);
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

string StringUpperCase(string str)
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

          message =  StringConcatenate(Symbol()," ",timeFrameToString(timeFrame)," at ",TimeToStr(TimeLocal(),TIME_SECONDS)," rsi ",doWhat);
             if (alertsMessage) Alert(message);
             if (alertsNotify)  SendNotification(message);
             if (alertsEmail)   SendMail(StringConcatenate(Symbol()," rsi "),message);
             if (alertsSound)   PlaySound(soundFile);
      }
}

