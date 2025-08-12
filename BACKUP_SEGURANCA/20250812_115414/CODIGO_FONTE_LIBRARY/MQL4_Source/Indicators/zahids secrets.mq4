//+------------------------------------------------------------------+
//|                     ZAHIDS SECRETS GOLDEN ALGO V0.01             |
//|                     Converted for MetaTrader 4                    |
//+------------------------------------------------------------------+
#property copyright "Converted from TradingView"
#property link      "https://www.tradingview.com"
#property version   "1.000"
#property strict
#property indicator_chart_window
#property indicator_buffers 3
#property indicator_plots   1

// Indicator properties for visualization
#property indicator_label1  "Trailing Stop"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrBlue
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1

// Inputs
input double KeyValue = 1.0;      // Key Value. This changes the sensitivity
input int ATRPeriod = 4;          // ATR Period
input bool UseHeikinAshi = false; // Signals from Heikin Ashi Candles

// Buffers
double TrailingStopBuffer[];
double BuySignalBuffer[];
double SellSignalBuffer[];

// Global variables
double xATRTrailingStop = 0.0;
int pos = 0;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                          |
//+------------------------------------------------------------------+
int OnInit()
{
   // Set indicator buffers
   SetIndexBuffer(0, TrailingStopBuffer);
   SetIndexBuffer(1, BuySignalBuffer, INDICATOR_DATA);
   SetIndexBuffer(2, SellSignalBuffer, INDICATOR_DATA);
   
   // Set empty values
   SetIndexEmptyValue(1, 0.0);
   SetIndexEmptyValue(2, 0.0);
   
   // Set labels
   IndicatorShortName("ZAHIDS SECRETS GOLDEN ALGO V0.01");
   SetIndexLabel(0, "Trailing Stop");
   
   // Initialize buffers
   ArraySetAsSeries(TrailingStopBuffer, true);
   ArraySetAsSeries(BuySignalBuffer, true);
   ArraySetAsSeries(SellSignalBuffer, true);
   
   return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| Custom indicator iteration function                               |
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
   // Ensure arrays are series
   ArraySetAsSeries(open, true);
   ArraySetAsSeries(high, true);
   ArraySetAsSeries(low, true);
   ArraySetAsSeries(close, true);
   
   // Calculate starting point
   int start = prev_calculated == 0 ? MathMax(ATRPeriod + 1, 1) : prev_calculated - 1;
   
   // Main loop
   for(int i = start; i < rates_total && !IsStopped(); i++)
   {
      // ATR calculation
      double xATR = iATR(NULL, 0, ATRPeriod, i);
      double nLoss = KeyValue * xATR;
      
      // Source price (Heikin Ashi or Close)
      double src = close[i];
      double src_prev = close[i + 1];
      
      // Heikin Ashi approximation (basic calculation as MT4 doesn't have built-in HA)
      if(UseHeikinAshi)
      {
         double ha_close = (open[i] + high[i] + low[i] + close[i]) / 4;
         src = ha_close;
         double ha_close_prev = (open[i + 1] + high[i + 1] + low[i + 1] + close[i + 1]) / 4;
         src_prev = ha_close_prev;
      }
      
      // Previous trailing stop (use buffer for historical values)
      double prev_trailing_stop = i > 0 ? TrailingStopBuffer[i + 1] : 0.0;
      
      // Trailing Stop Logic
      if(src > prev_trailing_stop && src_prev > prev_trailing_stop)
         xATRTrailingStop = MathMax(prev_trailing_stop, src - nLoss);
      else if(src < prev_trailing_stop && src_prev < prev_trailing_stop)
         xATRTrailingStop = MathMin(prev_trailing_stop, src + nLoss);
      else if(src > prev_trailing_stop)
         xATRTrailingStop = src - nLoss;
      else
         xATRTrailingStop = src + nLoss;
      
      TrailingStopBuffer[i] = xATRTrailingStop;
      
      // Position Logic
      int prev_pos = pos;
      if(src_prev < prev_trailing_stop && src > prev_trailing_stop)
         pos = 1;  // Long
      else if(src_prev > prev_trailing_stop && src < prev_trailing_stop)
         pos = -1; // Short
      else
         pos = prev_pos;
      
      // EMA (1-period EMA is essentially the source price)
      double ema = src;
      
      // Crossover detection
      bool above = (ema > xATRTrailingStop && (i + 1 < rates_total && close[i + 1] <= TrailingStopBuffer[i + 1]));
      bool below = (xATRTrailingStop > ema && (i + 1 < rates_total && TrailingStopBuffer[i + 1] <= close[i + 1]));
      
      // Buy/Sell Signals
      bool buy = src > xATRTrailingStop && above;
      bool sell = src < xATRTrailingStop && below;
      
      // Store signals (using arrows)
      BuySignalBuffer[i] = buy ? low[i] - 10 * Point : 0.0;
      SellSignalBuffer[i] = sell ? high[i] + 10 * Point : 0.0;
      
      // Bar coloring (approximated by comments as MT4 doesn't support direct bar coloring)
      if(src > xATRTrailingStop)
         Comment("Bar Color: Green (Buy)");
      else if(src < xATRTrailingStop)
         Comment("Bar Color: Red (Sell)");
   }
   
   // Plot signals as arrows
   if(BuySignalBuffer[rates_total - 1] > 0)
      ObjectCreate(0, "BuySignal" + TimeToString(time[rates_total - 1]), OBJ_ARROW_UP, 0, time[rates_total - 1], low[rates_total - 1] - 10 * Point);
   if(SellSignalBuffer[rates_total - 1] > 0)
      ObjectCreate(0, "SellSignal" + TimeToString(time[rates_total - 1]), OBJ_ARROW_DOWN, 0, time[rates_total - 1], high[rates_total - 1] + 10 * Point);
   
   return(rates_total);
}

//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                        |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   ObjectsDeleteAll(0, "BuySignal");
   ObjectsDeleteAll(0, "SellSignal");
   Comment("");
}