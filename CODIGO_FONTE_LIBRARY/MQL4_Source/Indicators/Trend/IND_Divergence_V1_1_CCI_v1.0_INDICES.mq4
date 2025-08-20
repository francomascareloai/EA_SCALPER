
#property indicator_separate_window
#property indicator_buffers 4
#property indicator_color1 Lime
#property indicator_color2 Red
#property indicator_color3 Magenta
#property indicator_color4 Blue
#property indicator_level1  140
#property indicator_level2  0.0
#property indicator_level3 -140
#property indicator_width4     2
//----
#define arrowsDisplacement 0.0001
//---- input parameters
extern string separator1 = "*** CCI Settings ***";
extern int    period = 14;
extern string separator2 = "*** Indicator Settings ***";
extern bool   drawIndicatorTrendLines = true;
extern bool   drawPriceTrendLines = true;
extern bool   displayAlert = true;
//---- buffers
double bullishDivergence[];
double bearishDivergence[];
double CCI[];
double signal[];
//----
static datetime lastAlertTime;
static string   indicatorName;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators
   SetIndexStyle(0, DRAW_ARROW);
   SetIndexStyle(1, DRAW_ARROW);
   SetIndexStyle(2, DRAW_LINE);
   SetIndexStyle(3, DRAW_LINE,0,2);
//----   
   SetIndexBuffer(0, bullishDivergence);
   SetIndexBuffer(1, bearishDivergence);
   SetIndexBuffer(2, CCI);
   SetIndexBuffer(3, signal);   
//----   
   SetIndexArrow(0, 233);
   SetIndexArrow(1, 234);
//----
   indicatorName = "CCI_Divergence_v1.1(" + period +" )";
   IndicatorDigits(Digits + 2);
   IndicatorShortName(indicatorName);
   SetIndexDrawBegin(3, period);
   return(0);
}
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
   for(int i = ObjectsTotal() - 1; i >= 0; i--)
     {
       string label = ObjectName(i);
       if(StringSubstr(label, 0, 18) != "CCI_DivergenceLine")
           continue;
       ObjectDelete(label);   
     }
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {
   int countedBars = IndicatorCounted();
   if(countedBars < 0)
       countedBars = 0;
   CalculateIndicator(countedBars);
//---- 
   return(0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CalculateIndicator(int countedBars)
  {
   for(int i = Bars - countedBars; i >= 0; i--)
     {
       CalculateCCI(i);
       CatchBullishDivergence(i + 2);
       CatchBearishDivergence(i + 2);
     }              
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CalculateCCI(int i)
  {
   CCI[i] = iCCI(Symbol(),0,period,PRICE_TYPICAL,i);
   
   signal[i] = iCCI(Symbol(),0,period,PRICE_TYPICAL,i);         
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CatchBullishDivergence(int shift)
  {
   if(IsIndicatorTrough(shift) == false)
       return;  
   int currentTrough = shift;
   int lastTrough = GetIndicatorLastTrough(shift);
//----   
   if(CCI[currentTrough] > CCI[lastTrough] && 
      Low[currentTrough] < Low[lastTrough])
     {
       bullishDivergence[currentTrough] = CCI[currentTrough] - 
                                          arrowsDisplacement;
       //----
       if(drawPriceTrendLines == true)
           DrawPriceTrendLine(Time[currentTrough], Time[lastTrough], 
                              Low[currentTrough], 
                             Low[lastTrough], Green, STYLE_SOLID);
       //----
       if(drawIndicatorTrendLines == true)
          DrawIndicatorTrendLine(Time[currentTrough], 
                                 Time[lastTrough], 
                                 CCI[currentTrough],
                                 CCI[lastTrough], 
                                 Green, STYLE_SOLID);
       //----
       if(displayAlert == true)
          DisplayAlert("Classical bullish divergence on: ", 
                        currentTrough);  
     }
//----   
   if(CCI[currentTrough] < CCI[lastTrough] && 
      Low[currentTrough] > Low[lastTrough])
     {
       bullishDivergence[currentTrough] = CCI[currentTrough] - 
                                          arrowsDisplacement;
       //----
       if(drawPriceTrendLines == true)
           DrawPriceTrendLine(Time[currentTrough], Time[lastTrough], 
                              Low[currentTrough], 
                              Low[lastTrough], Green, STYLE_DOT);
       //----
       if(drawIndicatorTrendLines == true)                            
           DrawIndicatorTrendLine(Time[currentTrough], 
                                  Time[lastTrough], 
                                  CCI[currentTrough],
                                  CCI[lastTrough], 
                                  Green, STYLE_DOT);
       //----
       if(displayAlert == true)
           DisplayAlert("Reverse bullish divergence on: ", 
                        currentTrough);   
     }      
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CatchBearishDivergence(int shift)
  {
   if(IsIndicatorPeak(shift) == false)
       return;
   int currentPeak = shift;
   int lastPeak = GetIndicatorLastPeak(shift);
//----   
   if(CCI[currentPeak] < CCI[lastPeak] && 
      High[currentPeak] > High[lastPeak])
     {
       bearishDivergence[currentPeak] = CCI[currentPeak] + 
                                        arrowsDisplacement;
      
       if(drawPriceTrendLines == true)
           DrawPriceTrendLine(Time[currentPeak], Time[lastPeak], 
                              High[currentPeak], 
                              High[lastPeak], Red, STYLE_SOLID);
                            
       if(drawIndicatorTrendLines == true)
           DrawIndicatorTrendLine(Time[currentPeak], Time[lastPeak], 
                                  CCI[currentPeak],
                                  CCI[lastPeak], Red, STYLE_SOLID);

       if(displayAlert == true)
           DisplayAlert("Classical bearish divergence on: ", 
                        currentPeak);  
     }
   if(CCI[currentPeak] > CCI[lastPeak] && 
      High[currentPeak] < High[lastPeak])
     {
       bearishDivergence[currentPeak] = CCI[currentPeak] + 
                                        arrowsDisplacement;
       //----
       if(drawPriceTrendLines == true)
           DrawPriceTrendLine(Time[currentPeak], Time[lastPeak], 
                              High[currentPeak], 
                              High[lastPeak], Red, STYLE_DOT);
       //----
       if(drawIndicatorTrendLines == true)
           DrawIndicatorTrendLine(Time[currentPeak], Time[lastPeak], 
                                  CCI[currentPeak],
                                  CCI[lastPeak], Red, STYLE_DOT);
       //----
       if(displayAlert == true)
           DisplayAlert("Reverse bearish divergence on: ", 
                        currentPeak);   
     }   
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool IsIndicatorPeak(int shift)
  {
   if(CCI[shift] >= CCI[shift+1] && CCI[shift] > CCI[shift+2] && 
      CCI[shift] > CCI[shift-1])
       return(true);
   else 
       return(false);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool IsIndicatorTrough(int shift)
  {
   if(CCI[shift] <= CCI[shift+1] && CCI[shift] < CCI[shift+2] && 
      CCI[shift] < CCI[shift-1])
       return(true);
   else 
       return(false);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int GetIndicatorLastPeak(int shift)
  {
   for(int i = shift + 5; i < Bars; i++)
     {
       if(signal[i] >= signal[i+1] && signal[i] >= signal[i+2] &&
          signal[i] >= signal[i-1] && signal[i] >= signal[i-2])
         {
           for(int j = i; j < Bars; j++)
             {
               if(CCI[j] >= CCI[j+1] && CCI[j] > CCI[j+2] &&
                  CCI[j] >= CCI[j-1] && CCI[j] > CCI[j-2])
                   return(j);
             }
         }
     }
   return(-1);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int GetIndicatorLastTrough(int shift)
  {
    for(int i = shift + 5; i < Bars; i++)
      {
        if(signal[i] <= signal[i+1] && signal[i] <= signal[i+2] &&
           signal[i] <= signal[i-1] && signal[i] <= signal[i-2])
          {
            for (int j = i; j < Bars; j++)
              {
                if(CCI[j] <= CCI[j+1] && CCI[j] < CCI[j+2] &&
                   CCI[j] <= CCI[j-1] && CCI[j] < CCI[j-2])
                    return(j);
              }
          }
      }
    return(-1);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void DisplayAlert(string message, int shift)
  {
   if(shift <= 2 && Time[shift] != lastAlertTime)
     {
       lastAlertTime = Time[shift];
       Alert(message, Symbol(), " , ", Period(), " minutes chart");
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void DrawPriceTrendLine(datetime x1, datetime x2, double y1, 
                        double y2, color lineColor, double style)
  {
   string label = "CCI_DivergenceLine_v1.0# " + DoubleToStr(x1, 0);
   ObjectDelete(label);
   ObjectCreate(label, OBJ_TREND, 0, x1, y1, x2, y2, 0, 0);
   ObjectSet(label, OBJPROP_RAY, 0);
   ObjectSet(label, OBJPROP_COLOR, lineColor);
   ObjectSet(label, OBJPROP_STYLE, style);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void DrawIndicatorTrendLine(datetime x1, datetime x2, double y1, 
                            double y2, color lineColor, double style)
  {
   int indicatorWindow = WindowFind(indicatorName);
   if(indicatorWindow < 0)
       return;
   string label = "CCI_DivergenceLine_v1.0$# " + DoubleToStr(x1, 0);
   ObjectDelete(label);
   ObjectCreate(label, OBJ_TREND, indicatorWindow, x1, y1, x2, y2, 
                0, 0);
   ObjectSet(label, OBJPROP_RAY, 0);
   ObjectSet(label, OBJPROP_COLOR, lineColor);
   ObjectSet(label, OBJPROP_STYLE, style);
  }
//+------------------------------------------------------------------+



