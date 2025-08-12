#property copyright "Leo"
#property link      ""
#property version   "1.00"
#property indicator_chart_window
#property indicator_buffers 12
#property indicator_plots   10

// Input parameters
input double   ProcessNoise1 = 0.01;       // Process Noise 1
input double   ProcessNoise2 = 0.01;       // Process Noise 2
input double   MeasurementNoise = 500.0;   // Measurement Noise
input int      OscSmoothness = 10;         // Osc Smoothness
input int      SigmaLookback = 500;        // Sigma Lookback
input int      TrendLookback = 10;         // Trend Lookback
input int      StrengthSmoothness = 10;    // Strength Smoothness
input int      Length = 20;                // Length
input double   Distance = 1.0;             // Distance
input int      Target = 0;                 // Set Targets
input int      BreakoutPeriod = 5;         // Breakout Period
input int      MaxBreakoutLength = 200;     // Max Breakout Length
input double   ThresholdRate = 0.03;       // Threshold Rate %
input int      MinTests = 2;               // Minimum Tests
input int      ZLPeriod = 15;              // Zero-Lag MA Period

// Buffers
double KalmanBuffer[];
double TrendStrengthBuffer[];
double MultiTrendScoreBuffer[];
double MultiTrendValueBuffer[];
double TrendLineBuffer[];
double PMaxBuffer[];
double ZeroLagBuffer[];
double EMABuffer[];
double UpperBandBuffer[];
double LowerBandBuffer[];
double Target1Buffer[];
double Target2Buffer[];

// Global variables
double prevFiltered, prevOscillator;
double trendStrength;
int trendDirection = 0;
double prevTrendLine = 0;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
{
   SetIndexBuffer(0, KalmanBuffer, INDICATOR_DATA);
   SetIndexStyle(0, DRAW_LINE, STYLE_SOLID, 2, clrLime);
   SetIndexLabel(0, "Kalman Filter");
   
   SetIndexBuffer(1, TrendStrengthBuffer, INDICATOR_DATA);
   SetIndexStyle(1, DRAW_HISTOGRAM, STYLE_SOLID, 3, clrBlue);
   SetIndexLabel(1, "Trend Strength");
   
   SetIndexBuffer(2, MultiTrendValueBuffer, INDICATOR_DATA);
   SetIndexStyle(2, DRAW_LINE, STYLE_SOLID, 1, clrYellow);
   SetIndexLabel(2, "Multi-Trend Value");
   
   SetIndexBuffer(3, TrendLineBuffer, INDICATOR_DATA);
   SetIndexStyle(3, DRAW_LINE, STYLE_DASH, 1, clrRed);
   SetIndexLabel(3, "Trend Line");
   
   SetIndexBuffer(4, PMaxBuffer, INDICATOR_DATA);
   SetIndexStyle(4, DRAW_LINE, STYLE_SOLID, 2, clrPurple);
   SetIndexLabel(4, "PMax");
   
   SetIndexBuffer(5, ZeroLagBuffer, INDICATOR_DATA);
   SetIndexStyle(5, DRAW_LINE, STYLE_SOLID, 1, clrBlue);
   SetIndexLabel(5, "Zero-Lag MA");
   
   SetIndexBuffer(6, EMABuffer, INDICATOR_DATA);
   SetIndexStyle(6, DRAW_LINE, STYLE_DOT, 1, clrRed);
   SetIndexLabel(6, "EMA");
   
   SetIndexBuffer(7, UpperBandBuffer, INDICATOR_DATA);
   SetIndexStyle(7, DRAW_LINE, STYLE_DOT, 1, clrGreen);
   SetIndexLabel(7, "Upper Band");
   
   SetIndexBuffer(8, LowerBandBuffer, INDICATOR_DATA);
   SetIndexStyle(8, DRAW_LINE, STYLE_DOT, 1, clrRed);
   SetIndexLabel(8, "Lower Band");
   
   SetIndexBuffer(9, Target1Buffer, INDICATOR_DATA);
   SetIndexStyle(9, DRAW_LINE, STYLE_DOT, 1, clrBlue);
   SetIndexLabel(9, "Target 1");
   
   SetIndexBuffer(10, Target2Buffer, INDICATOR_CALCULATIONS); // Hidden buffer
   SetIndexBuffer(11, MultiTrendScoreBuffer, INDICATOR_CALCULATIONS); // Hidden buffer
   
   return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| Kalman Filter                                                    |
//+------------------------------------------------------------------+
void KalmanFilter(int pos, double price)
{
   static double x0 = price, x1 = price;
   static double p00 = 1.0, p01 = 0.0, p10 = 0.0, p11 = 1.0;
   // State prediction
   double x0_pred = x0 + x1;
   double x1_pred = x1;
   
   // Covariance prediction
   double p00_pred = p00 + 2*p01 + p11 + ProcessNoise1;
   double p01_pred = p01 + p11 + ProcessNoise1*ProcessNoise2;
   double p10_pred = p01_pred;
   double p11_pred = p11 + ProcessNoise2;
   
   // Measurement update
   double y = price - x0_pred;
   double s = p00_pred + MeasurementNoise;
   double k0 = p00_pred / s;
   double k1 = p10_pred / s;
   
   // State update
   x0 = x0_pred + k0 * y;
   x1 = x1_pred + k1 * y;
   
   // Covariance update
   p00 = (1 - k0) * p00_pred;
   p01 = (1 - k0) * p01_pred;
   p10 = -k1 * p00_pred + p10_pred;
   p11 = -k1 * p01_pred + p11_pred;
   
   KalmanBuffer[pos] = x0;
   double oscillator = x1;
   
   // Update trend strength
   static double oscBuffer[];
   ArraySetAsSeries(oscBuffer, false);
   ArrayResize(oscBuffer, TrendLookback);
   
   if(pos > 0 && ArraySize(oscBuffer) > 0) {
      for(int i = ArraySize(oscBuffer)-1; i > 0; i--)
         oscBuffer[i] = oscBuffer[i-1];
   }
   oscBuffer[0] = oscillator;
   
   if(pos >= TrendLookback) {
      double maxOsc = MathAbs(oscBuffer[ArrayMaximum(oscBuffer)]);
      if(maxOsc != 0) 
         trendStrength = oscillator / maxOsc * 100;
   }
   TrendStrengthBuffer[pos] = trendStrength;
}

//+------------------------------------------------------------------+
//| Gaussian Filter                                                  |
//+------------------------------------------------------------------+
double GaussianFilter(const double &price[], int pos, int length, double sigma)
{
   double weights[];
   ArrayResize(weights, length);
   double total = 0.0;
   double pi = 3.14159265358979323846;
   
   // Calculate weights
   for(int i = 0; i < length; i++) {
      double weight = MathExp(-0.5 * MathPow((i - length/2.0) / sigma, 2)) / MathSqrt(sigma * 2.0 * pi);
      weights[i] = weight;
      total += weight;
   }
   
   // Normalize weights
   for(int i = 0; i < length; i++)
      weights[i] /= total;
   
   // Apply filter
   double sum = 0.0;
   for(int i = 0; i < length; i++) {
      if(pos - i >= 0)
         sum += price[pos - i] * weights[i];
   }
   
   return sum;
}

//+------------------------------------------------------------------+
//| Multi-Trend Indicator                                            |
//+------------------------------------------------------------------+
void MultiTrend(int pos, double close, double high, double low)
{
   double priceArray[];
   ArraySetAsSeries(priceArray, false);
   CopyClose(_Symbol, _Period, 0, Length+20, priceArray);
   
   double gValues[20];
   for(int step = 0; step < 20; step++) {
      gValues[step] = GaussianFilter(priceArray, pos, Length+step, 10);
   }
   
   // Calculate score
   double coeff = 0.05;
   double score = 0.0;
   for(int i = 0; i < 20; i++) {
      if(gValues[i] > gValues[0])
         score += coeff;
   }
   MultiTrendScoreBuffer[pos] = score;
   
   // Calculate value (average)
   double sum = 0.0;
   for(int i = 0; i < 20; i++)
      sum += gValues[i];
   double avg = sum / 20.0;
   MultiTrendValueBuffer[pos] = avg;
   
   // Calculate volatility
   double atr = iATR(_Symbol, _Period, 100, pos);
   double volatility = atr * Distance;
   
   // Update trend line
   static double prevUpperBand = 0, prevLowerBand = 0;
   static bool trend = false;
   
   double upperBand = avg + volatility;
   double lowerBand = avg - volatility;
   UpperBandBuffer[pos] = upperBand;
   LowerBandBuffer[pos] = lowerBand;
   
   if(close > upperBand)
      trend = true;
   else if(close < lowerBand)
      trend = false;
   
   TrendLineBuffer[pos] = trend ? lowerBand : upperBand;
   prevTrendLine = TrendLineBuffer[pos];
}

//+------------------------------------------------------------------+
//| Zero-Lag Moving Average                                          |
//+------------------------------------------------------------------+
void ZeroLagMA(int pos)
{
   double ema = iMA(_Symbol, _Period, ZLPeriod, 0, MODE_EMA, PRICE_CLOSE, pos);
   double prevEma = iMA(_Symbol, _Period, ZLPeriod, 0, MODE_EMA, PRICE_CLOSE, pos+1);
   double correction = Close[pos] + (Close[pos] - ema);
   double zlma = iMAOnArray(Close, 0, ZLPeriod, 0, MODE_EMA, pos);
   
   ZeroLagBuffer[pos] = zlma;
   EMABuffer[pos] = ema;
   
   // Detect signals
   static double prevZlma = 0, prevEma2 = 0;
   if(pos < Bars-1) {
      bool signalUp = (zlma > ema) && (prevZlma <= prevEma2);
      bool signalDn = (zlma < ema) && (prevZlma >= prevEma2);
      
      if(signalUp) {
         // Draw buy signal
         CreateArrow(pos, High[pos], 233, clrGreen, true);
      }
      else if(signalDn) {
         // Draw sell signal
         CreateArrow(pos, Low[pos], 234, clrRed, false);
      }
   }
   prevZlma = zlma;
   prevEma2 = ema;
}

//+------------------------------------------------------------------+
//| Create Arrow on Chart                                            |
//+------------------------------------------------------------------+
void CreateArrow(int bar, double price, int code, color clr, bool up)
{
   string name = "Arr_" + IntegerToString(bar) + "_" + IntegerToString(rand());
   if(ObjectCreate(0, name, OBJ_ARROW, 0, Time[bar], price)) {
      ObjectSetInteger(0, name, OBJPROP_ARROWCODE, code);
      ObjectSetInteger(0, name, OBJPROP_COLOR, clr);
      ObjectSetInteger(0, name, OBJPROP_WIDTH, 2);
      ObjectSetInteger(0, name, OBJPROP_ANCHOR, up ? ANCHOR_BOTTOM : ANCHOR_TOP);
   }
}

//+------------------------------------------------------------------+
//| Breakout Finder                                                  |
//+------------------------------------------------------------------+
void BreakoutFinder(int pos)
{
   static double phValues[], plValues[];
   static int phBars[], plBars[];
   static int phCount = 0, plCount = 0;
   
   // Detect pivot highs
   if(High[pos] > High[pos+1] && High[pos] > High[pos-1]) {
      phValues[phCount] = High[pos];
      phBars[phCount] = pos;
      phCount++;
   }
   
   // Detect pivot lows
   if(Low[pos] < Low[pos+1] && Low[pos] < Low[pos-1]) {
      plValues[plCount] = Low[pos];
      plBars[plCount] = pos;
      plCount++;
   }
   
   // Cleanup old values
   for(int i = phCount-1; i >= 0; i--) {
      if(pos - phBars[i] > MaxBreakoutLength) {
         phCount--;
         ArrayRemove(phValues, i, 1);
         ArrayRemove(phBars, i, 1);
      }
   }
   
   for(int i = plCount-1; i >= 0; i--) {
      if(pos - plBars[i] > MaxBreakoutLength) {
         plCount--;
         ArrayRemove(plValues, i, 1);
         ArrayRemove(plBars, i, 1);
      }
   }
   
   // Check for bullish breakout
   if(phCount >= MinTests && Close[pos] > Open[pos]) {
      double highestVal = phValues[ArrayMaximum(phValues)];
      if(Close[pos] > highestVal) {
         // Draw breakout box
         DrawBox(pos, highestVal, ThresholdRate, clrBlue);
         CreateArrow(pos, Low[pos], 233, clrBlue, true);
      }
   }
   
   // Check for bearish breakout
   if(plCount >= MinTests && Close[pos] < Open[pos]) {
      double lowestVal = plValues[ArrayMinimum(plValues)];
      if(Close[pos] < lowestVal) {
         // Draw breakout box
         DrawBox(pos, lowestVal, -ThresholdRate, clrRed);
         CreateArrow(pos, High[pos], 234, clrRed, false);
      }
   }
}

//+------------------------------------------------------------------+
//| Draw Box on Chart                                                |
//+------------------------------------------------------------------+
void DrawBox(int bar, double base, double width, color clr)
{
   string name = "Box_" + IntegerToString(bar) + "_" + IntegerToString(rand());
   double top = base + MathAbs(width);
   double bottom = base - MathAbs(width);
   
   if(ObjectCreate(0, name, OBJ_RECTANGLE, 0, Time[bar], top, Time[bar-20], bottom)) {
      ObjectSetInteger(0, name, OBJPROP_COLOR, clr);
      ObjectSetInteger(0, name, OBJPROP_STYLE, STYLE_DASH);
      ObjectSetInteger(0, name, OBJPROP_WIDTH, 1);
      ObjectSetInteger(0, name, OBJPROP_BACK, true);
      ObjectSetInteger(0, name, OBJPROP_FILL, true);
      ObjectSetInteger(0, name, OBJPROP_FILL_COLOR, clr);
   }
}

//+------------------------------------------------------------------+
//| Calculate Targets                                                |
//+------------------------------------------------------------------+
void CalculateTargets(int pos)
{
   double atr = iATR(_Symbol, _Period, 200, pos);
   double smaHigh = iMA(_Symbol, _Period, 10, 0, MODE_SMA, PRICE_HIGH, pos) + atr * 0.8;
   double smaLow = iMA(_Symbol, _Period, 10, 0, MODE_SMA, PRICE_LOW, pos) - atr * 0.8;
   
   // Update trend direction
   if(Close[pos] > smaHigh && Close[pos-1] <= smaHigh)
      trendDirection = 1;
   else if(Close[pos] < smaLow && Close[pos-1] >= smaLow)
      trendDirection = -1;
   
   // Set targets based on trend direction
   if(trendDirection == 1) {
      Target1Buffer[pos] = Close[pos] + atr * (5 + Target);
      Target2Buffer[pos] = Close[pos] + atr * (10 + Target*2);
   }
   else if(trendDirection == -1) {
      Target1Buffer[pos] = Close[pos] - atr * (5 + Target);
      Target2Buffer[pos] = Close[pos] - atr * (10 + Target*2);
   }
}

//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
{
   int start;
   if(prev_calculated == 0)
      start = MathMax(SigmaLookback, MathMax(TrendLookback, Length));
   else
      start = prev_calculated - 1;
   
   for(int i = start; i < rates_total && !IsStopped(); i++) {
      // Calculate main components
      KalmanFilter(i, close[i]);
      MultiTrend(i, close[i], high[i], low[i]);
      ZeroLagMA(i);
      BreakoutFinder(i);
      CalculateTargets(i);
      
      // Calculate PMax
      double ma = iMA(_Symbol, _Period, 7, 0, MODE_EMA, PRICE_CLOSE, i);
      double atr = iATR(_Symbol, _Period, 100, i);
      PMaxBuffer[i] = ma - 3.3 * atr;
   }
   
   return(rates_total);
}