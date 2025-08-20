//------------------------------------------------------------------
#property copyright "www.forex-tsd.com"
#property link      "www.forex-tsd.com"
//------------------------------------------------------------------

#property indicator_separate_window
#property indicator_buffers 4
#property indicator_color1  Aqua
#property indicator_color2  Magenta
#property indicator_color3	 LightSeaGreen
#property indicator_color4	 Red
#property indicator_level1	 80
#property indicator_level2	 20
#property indicator_maximum 100
#property indicator_minimum 0

//
//
//
//
//

extern string TimeFrame                 = "Current time frame";
extern int    StoKPeriod                = 14;
extern int    StoDPeriod                = 3;
extern int    StoSlowing                = 3;
extern int    StoPrice                  = 0;
extern int    SignalMode                = MODE_SMA;
extern int    arrowSize                 = 1; 
extern bool   drawDivergences           = true;
extern bool   ShowClassicalDivergence   = true;
extern bool   ShowHiddenDivergence      = true;
extern bool   drawIndicatorTrendLines   = true;
extern bool   drawPriceTrendLines       = true;
extern string drawLinesIdentificator    = "momdiverge1";
extern double arrowsDisplacement        = 1.0;
extern bool   divergenceAlert           = true;
extern bool   divergenceAlertsMessage   = true;
extern bool   divergenceAlertsSound     = true;
extern bool   divergenceAlertsEmail     = false;
extern bool   divergenceAlertsNotify    = false;
extern string divergenceAlertsSoundName = "alert1.wav";

extern bool   alertsOn                  = true;
extern bool   alertsOnCurrent           = true;
extern bool   alertsMessage             = true;
extern bool   alertsSound               = false;
extern bool   alertsNotify              = true;
extern bool   alertsEmail               = true;
extern string soundFile                 = "alert2.wav"; 


double bullishDivergence[];
double bearishDivergence[];
double top[];
double bot[];
double sto[];
double sig[];
double trend[];

string indicatorName;
string labelNames;

string indicatorFileName;
bool   calculateValue;
bool   returnBars;
int    timeFrame;


//+------------------------------------------------------------------
//|                                                                  
//+------------------------------------------------------------------

int init()
{
   IndicatorBuffers(5);
   SetIndexBuffer(0,bullishDivergence); SetIndexStyle(0,DRAW_ARROW,0,arrowSize); SetIndexArrow(0,233);
   SetIndexBuffer(1,bearishDivergence); SetIndexStyle(1,DRAW_ARROW,0,arrowSize); SetIndexArrow(1,234);  
   SetIndexBuffer(2,sto);
   SetIndexBuffer(3,sig);
   SetIndexBuffer(4,trend);

   ArraySetAsSeries(top, false);
   ArrayResize(top,Bars+StoKPeriod);
   ArraySetAsSeries(top, true);      

   ArraySetAsSeries(bot, false);
   ArrayResize(bot,Bars+StoKPeriod);
   ArraySetAsSeries(bot, true);      

      labelNames    = "Stochastic_DivergenceLine "+drawLinesIdentificator+":";
      indicatorName = "Stochastic ("+StoKPeriod+","+StoDPeriod+","+StoSlowing+")";
      IndicatorShortName(indicatorName);
//      indicatorFileName = WindowExpertName();
return(0);
}

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

//+------------------------------------------------------------------
//|                                                                  
//+------------------------------------------------------------------

int start()
{
   int i,limit,counted_bars=IndicatorCounted();

   if(counted_bars<0) return(-1);
   if(counted_bars>0) counted_bars--;
   limit = MathMin(Bars-counted_bars,Bars-1);
  
     for (i=limit; i>=0; i--)
     {
        sto[i] = iStochastic(NULL,0,StoKPeriod,StoDPeriod,StoSlowing,SignalMode,StoPrice,MODE_MAIN  ,i);
        sig[i] = iStochastic(NULL,0,StoKPeriod,StoDPeriod,StoSlowing,SignalMode,StoPrice,MODE_SIGNAL,i);
          trend[i] = trend[i+1];
          if (sto[i]>sig[i]) trend[i]= 1;
          if (sto[i]<sig[i]) trend[i]=-1;
          if (drawDivergences)
          {
            CatchBullishDivergence(i);
            CatchBearishDivergence(i);
          }        
      }
      manageAlerts();         
     return(0);
      
return(0);
}

void CatchBullishDivergence(int shift)
{
//   shift++;
   bullishDivergence[shift] = EMPTY_VALUE;
   ObjectDelete(labelNames+"l"+DoubleToStr(Time[shift],0));
   ObjectDelete(labelNames+"l"+"os" + DoubleToStr(Time[shift],0));  
   bot[shift]=0;          
   if(!IsIndicatorLow(shift)) return;  
   bot[shift]=1;      
   
   int currentLow = shift;
   int lastLow    = GetIndicatorLastLow(shift+1);
   if (sto[currentLow] > sto[lastLow] && Low[currentLow] < Low[lastLow])
   {
     if (ShowClassicalDivergence)
     {
        bullishDivergence[currentLow] = sto[currentLow] - arrowsDisplacement;
        if (drawPriceTrendLines)    DrawPriceTrendLine("l",Time[currentLow],Time[lastLow],Low[currentLow],Low[lastLow],Green,STYLE_SOLID);
        if (drawIndicatorTrendLines)DrawIndicatorTrendLine("l",Time[currentLow],Time[lastLow],sto[currentLow],sto[lastLow],Green,STYLE_SOLID);
        if (divergenceAlert)        DisplayAlert("Classical bullish divergence",currentLow);  
     }
                        
   }
       
   if (sto[currentLow] < sto[lastLow] && Low[currentLow] > Low[lastLow])
   {
     if (ShowHiddenDivergence)
     {
        bullishDivergence[currentLow] = sto[currentLow] - arrowsDisplacement;
        if (drawPriceTrendLines)     DrawPriceTrendLine("l",Time[currentLow],Time[lastLow],Low[currentLow],Low[lastLow],Green, STYLE_DOT);
        if (drawIndicatorTrendLines) DrawIndicatorTrendLine("l",Time[currentLow],Time[lastLow],sto[currentLow], sto[lastLow],Green, STYLE_DOT);
        if (divergenceAlert)         DisplayAlert("Reverse bullish divergence",currentLow); 
     }
   }
}


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

void CatchBearishDivergence(int shift)
{
//   shift++; 
   bearishDivergence[shift] = EMPTY_VALUE;
   ObjectDelete(labelNames+"h"+DoubleToStr(Time[shift],0));
   ObjectDelete(labelNames+"h"+"os" + DoubleToStr(Time[shift],0));   
   top[shift]=0;            
   if(IsIndicatorPeak(shift) == false) return;
   top[shift]=1;   
   int currentPeak = shift;
   int lastPeak = GetIndicatorLastPeak(shift+1);

   if (sto[currentPeak] < sto[lastPeak] && High[currentPeak]>High[lastPeak])
   {
     if (ShowClassicalDivergence)
     {
        bearishDivergence[currentPeak] = sto[currentPeak] + arrowsDisplacement;
        if (drawPriceTrendLines)     DrawPriceTrendLine("h",Time[currentPeak],Time[lastPeak],High[currentPeak],High[lastPeak],Red,STYLE_SOLID);
        if (drawIndicatorTrendLines) DrawIndicatorTrendLine("h",Time[currentPeak],Time[lastPeak],sto[currentPeak],sto[lastPeak],Red,STYLE_SOLID);
        if (divergenceAlert)         DisplayAlert("Classical bearish divergence",currentPeak);
     } 
                        
   }

   if (sto[currentPeak] > sto[lastPeak] && High[currentPeak] < High[lastPeak])
   {
     if (ShowHiddenDivergence)
     {
        bearishDivergence[currentPeak] = sto[currentPeak] + arrowsDisplacement;
        if (drawPriceTrendLines)     DrawPriceTrendLine("h",Time[currentPeak],Time[lastPeak],High[currentPeak],High[lastPeak], Red, STYLE_DOT);
        if (drawIndicatorTrendLines) DrawIndicatorTrendLine("h",Time[currentPeak],Time[lastPeak],sto[currentPeak],sto[lastPeak], Red, STYLE_DOT);
        if (divergenceAlert)         DisplayAlert("Reverse bearish divergence",currentPeak);
     }
                         
   }   
}


bool IsIndicatorPeak(int shift)
{
   if(sto[shift+1] >= sto[shift+2] && sto[shift+1] > sto[shift+3] && sto[shift+1] > sto[shift])
       return(true);
   else 
       return(false);
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

bool IsIndicatorLow(int shift)
{
   if(sto[shift+1] <= sto[shift+2] && sto[shift+1] < sto[shift+3] && sto[shift+1] < sto[shift])
       return(true);
   else 
       return(false);
}


int GetIndicatorLastPeak(int shift)
{
    for(int i = shift+5; i < Bars; i++)
    {
       //if(sto[i] >= sto[i+1] && sto[i] > sto[i+2] && sto[i] >= sto[i-1] && sto[i] > sto[i-2])  return(i);
       if(top[i] != top[i+1]) return(i);
    }
return(-1);
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//

int GetIndicatorLastLow(int shift)
{
    for (int i = shift+5; i < Bars; i++)
    {
       //if (sto[i] <= sto[i+1] && sto[i] < sto[i+2] && sto[i] <= sto[i-1] && sto[i] < sto[i-2])
         if(bot[i] != bot[i+1]) return(i);
}
     
return(-1);
}

void DisplayAlert(string doWhat, int shift)
{
    string dmessage;
    static datetime lastAlertTime;
    if(shift <= 2 && Time[0] != lastAlertTime)
    {
      dmessage =  StringConcatenate(Symbol()," at ",TimeToStr(TimeLocal(),TIME_SECONDS)," Stochastic ",doWhat);
          if (divergenceAlertsMessage) Alert(dmessage);
          if (divergenceAlertsNotify)  SendNotification(StringConcatenate(Symbol(), Period() ," Stochastic " +" "+dmessage));
          if (divergenceAlertsEmail)   SendMail(StringConcatenate(Symbol()," Stochastic "),dmessage);
          if (divergenceAlertsSound)   PlaySound(divergenceAlertsSoundName); 
          lastAlertTime = Time[0];
    }
}

void DrawPriceTrendLine(string first,datetime t1, datetime t2, double p1, double p2, color lineColor, double style)
{
    string label = labelNames+first+"os"+DoubleToStr(t1,0);
      ObjectDelete(label);
      ObjectCreate(label, OBJ_TREND, 0, t1, p1, t2, p2, 0, 0);
         ObjectSet(label, OBJPROP_RAY, 0);
         ObjectSet(label, OBJPROP_COLOR, lineColor);
         ObjectSet(label, OBJPROP_STYLE, style);
}

void DrawIndicatorTrendLine(string first,datetime t1, datetime t2, double p1, double p2, color lineColor, double style)
{
    int indicatorWindow = WindowFind(indicatorName);
    if (indicatorWindow < 0) return;
    
    string label = labelNames+first+DoubleToStr(t1,0);
      ObjectDelete(label);
      ObjectCreate(label, OBJ_TREND, indicatorWindow, t1, p1, t2, p2, 0, 0);
         ObjectSet(label, OBJPROP_RAY, 0);
         ObjectSet(label, OBJPROP_COLOR, lineColor);
         ObjectSet(label, OBJPROP_STYLE, style);
}


void manageAlerts()
{
   if (alertsOn)
   {
      if (alertsOnCurrent)
           int whichBar = 0;
      else     whichBar = 1; whichBar = iBarShift(NULL,0,iTime(NULL,timeFrame,whichBar));
      if (trend[whichBar] != trend[whichBar+1])
      {
         if (trend[whichBar] == 1) doAlert(whichBar,"up");
         if (trend[whichBar] ==-1) doAlert(whichBar,"down");
      }         
   }
}   


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
             message =   "Stochastic DivergenceLine " + Symbol() + " " + Period();
             if (alertsMessage) Alert(message);
             if (alertsNotify)  SendNotification(StringConcatenate(Symbol(), Period() ," Stochastic " +" "+message));
             if (alertsEmail)   SendMail(StringConcatenate(Symbol(), Period(), " Stochastic "),message);
             if (alertsSound)   PlaySound(soundFile);
      }
}



