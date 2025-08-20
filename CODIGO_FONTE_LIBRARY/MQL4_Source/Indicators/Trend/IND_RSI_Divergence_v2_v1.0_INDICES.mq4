//+------------------------------------------------------------------+
//|                                     FX5_RSI_Divergence_V1.0.mq4 |
//|                                                              FX5 |
//|                                                    hazem@uk2.net |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2007, FX5"
#property link      "hazem@uk2.net"
//----
#property indicator_separate_window
#property indicator_buffers 4
#property indicator_color1 DarkGreen
#property indicator_color2 Maroon
#property indicator_color3 White
#property indicator_color4 SteelBlue
//----
#define arrowsDisplacement 0.0001
//---- input parameters
extern string separator1 = "*** RSI Settings ***";
extern int    RSIPeriod = 6;
extern string separator2 = "*** Indicator Settings ***";
extern bool   drawIndicatorTrendLines = true;
extern bool   drawPriceTrendLines = true;
extern bool   displayAlert = true;
extern bool   displayHiddenDiv = true;
extern bool   alertsON = false; 
//---- buffers
double bullishDivergence[];
double bearishDivergence[];
double rsi[];
double signal[];
//----
static datetime lastAlertTimePk; // last alert on a Peak
static datetime lastAlertTimeTr; // last alert on a Trough
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
      
//---- indicators

   SetIndexStyle(2, DRAW_LINE);
   SetIndexStyle(3, DRAW_LINE);
   SetIndexStyle(0, DRAW_ARROW);
   SetIndexStyle(1, DRAW_ARROW);
//----   
   SetIndexBuffer(0, bullishDivergence);
   SetIndexBuffer(1, bearishDivergence);
   SetIndexBuffer(2, rsi);
//----   
   SetIndexArrow(0, 233);
   SetIndexArrow(1, 234);
//----
   SetIndexDrawBegin(3, RSIPeriod);
   IndicatorDigits(MarketInfo(Symbol(),MODE_DIGITS)+2);
   IndicatorShortName("RSI_Divergence(" + RSIPeriod + ")");
//----
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
       if(StringSubstr(label, 0, 18) != "RSI_DivergenceLine")
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
   for (int i = Bars - countedBars; i >= 0; i--)
     {
       Calculatersi(i);
       CatchBullishDivergence(i + 1);
       CatchBearishDivergence(i + 1);
     }              
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Calculatersi(int i)
  {
   rsi[i] = iRSI(NULL, 0, RSIPeriod, PRICE_CLOSE,i);   
        
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
   if(rsi[currentTrough] > rsi[lastTrough] && 
      Low[currentTrough] < Low[lastTrough])
     {
       bullishDivergence[currentTrough] = rsi[currentTrough] - 
                                          arrowsDisplacement;
       if(drawPriceTrendLines == true)
           DrawPriceTrendLine(Time[currentTrough], Time[lastTrough], 
                              Low[currentTrough], 
                              Low[lastTrough], DarkGreen, STYLE_SOLID);
       if(drawIndicatorTrendLines == true)
           DrawIndicatorTrendLine(Time[currentTrough], 
                                  Time[lastTrough], rsi[currentTrough],
                                  rsi[lastTrough], DarkGreen, STYLE_SOLID);
       if(displayAlert == true)
           DisplayAlert("RSI Classical bullish divergence on: ", currentTrough, False);  // was not a Peak
     }
   if(rsi[currentTrough] < rsi[lastTrough] && 
      Low[currentTrough] > Low[lastTrough])
     {
       bullishDivergence[currentTrough] = rsi[currentTrough] - 
                                          arrowsDisplacement;
       if(drawPriceTrendLines == true && displayHiddenDiv == true)
           DrawPriceTrendLine(Time[currentTrough], Time[lastTrough], 
                              Low[currentTrough], 
                              Low[lastTrough], DarkGreen, STYLE_DOT);
       if(drawIndicatorTrendLines == true && displayHiddenDiv == true)                            
           DrawIndicatorTrendLine(Time[currentTrough], Time[lastTrough], 
                                  rsi[currentTrough],
                                  rsi[lastTrough], DarkGreen, STYLE_DOT);

       if(displayAlert == true && displayHiddenDiv == true)
           DisplayAlert("RSI Hidden bullish divergence on: ", currentTrough,False);   // was not a Peak
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
   
   if(rsi[currentPeak] < rsi[lastPeak] && 
      High[currentPeak] > High[lastPeak])
     {
       bearishDivergence[currentPeak] = rsi[currentPeak] + 
                                        arrowsDisplacement;
       if(drawPriceTrendLines == true)
           DrawPriceTrendLine(Time[currentPeak], Time[lastPeak], 
                              High[currentPeak], 
                              High[lastPeak], Maroon, STYLE_SOLID);                   
       if(drawIndicatorTrendLines == true)
           DrawIndicatorTrendLine(Time[currentPeak], Time[lastPeak], 
                                  rsi[currentPeak],
                                  rsi[lastPeak], Maroon, STYLE_SOLID);
       if(displayAlert == true)
           DisplayAlert("RSI Classical bearish divergence on: ", currentPeak, True);  // was a Peak
     }
   if(rsi[currentPeak] > rsi[lastPeak] && 
      High[currentPeak] < High[lastPeak])
     {
       bearishDivergence[currentPeak] = rsi[currentPeak] + 
                                        arrowsDisplacement;
       if (drawPriceTrendLines == true && displayHiddenDiv == true)
           DrawPriceTrendLine(Time[currentPeak], Time[lastPeak], 
                              High[currentPeak], 
                              High[lastPeak], Maroon, STYLE_DOT);
       if (drawIndicatorTrendLines == true && displayHiddenDiv == true)
           DrawIndicatorTrendLine(Time[currentPeak], Time[lastPeak], 
                                  rsi[currentPeak],
                                  rsi[lastPeak], Maroon, STYLE_DOT);
       if (displayAlert == true && displayHiddenDiv == true)
           DisplayAlert("RSI Hidden bearish divergence on: ", currentPeak, True);   // was a Peak
     }   
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool IsIndicatorPeak(int shift)
  {
   if(rsi[shift] >= rsi[shift+1] && rsi[shift] > rsi[shift+2] && 
      rsi[shift] > rsi[shift-1])
       return(true);
   else 
       return(false);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool IsIndicatorTrough(int shift)
  {
   if(rsi[shift] <= rsi[shift+1] && rsi[shift] < rsi[shift+2] && 
      rsi[shift] < rsi[shift-1])
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
               if(rsi[j] >= rsi[j+1] && rsi[j] > rsi[j+2] &&
                  rsi[j] >= rsi[j-1] && rsi[j] > rsi[j-2])
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
           for(int j = i; j < Bars; j++)
             {
               if(rsi[j] <= rsi[j+1] && rsi[j] < rsi[j+2] &&
                  rsi[j] <= rsi[j-1] && rsi[j] < rsi[j-2])
                   return(j);
             }
         }
     }
   return(-1);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void DisplayAlert(string message, int shift, bool peak)
  {
  if(alertsON){
  if (peak){
             if(shift <= 2 && Time[shift] != lastAlertTimePk)
              {
               lastAlertTimePk = Time[shift];
               Alert(message, Symbol(), " , ", Period(), " minutes chart");
              }
             } // was a Peak
    if (!peak){
               if(shift <= 2 && Time[shift] != lastAlertTimeTr)
                {
                 lastAlertTimeTr = Time[shift];
                 Alert(message, Symbol(), " , ", Period(), " minutes chart");
                } 
              } // not a Peak   
  }}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void DrawPriceTrendLine(datetime x1, datetime x2, double y1, 
                        double y2, color lineColor, double style)
  {
   string label = "RSI_DivergenceLine_v1.0# " + DoubleToStr(x1, 0);
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
   int indicatorWindow = WindowFind("RSI_Divergence(" + RSIPeriod + ")");
   if(indicatorWindow < 0)
       return;
   string label = "RSI_DivergenceLine_v1.0$# " + DoubleToStr(x1, 0);
   ObjectDelete(label);
   ObjectCreate(label, OBJ_TREND, indicatorWindow, x1, y1, x2, y2, 0, 0);
   ObjectSet(label, OBJPROP_RAY, 0);
   ObjectSet(label, OBJPROP_COLOR, lineColor);
   ObjectSet(label, OBJPROP_STYLE, style);
  }
//+------------------------------------------------------------------+



