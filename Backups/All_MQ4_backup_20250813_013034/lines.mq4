//+------------------------------------------------------------------+
//|                                                        lines.mq4 |
//|                                  Copyright 2024, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                                     KeyLevels.mq4|
//|                        Custom Indicator for MetaTrader 4          |
//+------------------------------------------------------------------+
#property strict
#property indicator_chart_window

extern int bar_displacement = 50; // Bar displacement
double high_first_candle = 0;
double low_first_candle = 0;
double average_first_candle = 0;
bool new_day = false;

// Key level arrays
double bl1, bh1, bl2, bh2, bl3, bh3, bl4, bh4, bl5, bh5;
double sh1, sl1, sh2, sl2, sh3, sl3, sh4, sl4, sh5, sl5;

// Initialize the indicator
int OnInit()
{
   // Sets the indicator buffers for plotting lines on the chart
   IndicatorBuffers(2);
   return(INIT_SUCCEEDED);
}

// Function to detect new day
bool IsNewDay()
{
   static datetime last_time = 0;
   if (TimeDay(Time[0]) != TimeDay(last_time)) {
      last_time = Time[0];
      return true;
   }
   return false;
}

int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime& time[],
                const double& open[],
                const double& high[],
                const double& low[],
                const double& close[],
                const long& tick_volume[],
                const long& volume[],
                const int& spread[])
{
   if (IsNewDay()) {
      // Reset the high and low of the first candle of the day
      high_first_candle = high[0];
      low_first_candle = low[0];
      average_first_candle = (high_first_candle + low_first_candle) / 2.0;
      
      // Calculate key levels based on the average
      double avg_plus_adjustment = average_first_candle + 0.864;
      double avg_minus_adjustment = average_first_candle - 0.864;
      
      bl1 = avg_plus_adjustment + 4.331;
      bh1 = bl1 + 1.737;
      
      bl2 = bh1 + 4.352;
      bh2 = bl2 + 1.745;
      
      bl3 = bh2 + 4.374;
      bh3 = bl3 + 1.754;
      
      bl4 = bh3 + 4.395;
      bh4 = bl4 + 1.762;
      
      bl5 = bh4 + 4.417;
      bh5 = bl5 + 1.771;
      
      sh1 = avg_minus_adjustment - 4.313;
      sl1 = sh1 - 1.721;
      
      sh2 = sl1 - 4.291;
      sl2 = sh2 - 1.713;
      
      sh3 = sl2 - 4.270;
      sl3 = sh3 - 1.704;
      
      sh4 = sl3 - 4.248;
      sl4 = sh4 - 1.696;
      
      sh5 = sl4 - 4.227;
      sl5 = sh5 - 1.687;
      
      // Draw the lines and labels
      DrawKeyLevels();
   }

   // Trade conditions based on close price and key levels
   if (Close[1] > bh1) {
      // Buy condition
      if (OrdersTotal() == 0) {
         OrderSend(Symbol(), OP_BUY, 0.1, Ask, 3, sl1, bh2, "Key Level Buy", 0, 0, Blue);
      }
   }
   
   if (Close[1] < bl1) {
      // Sell condition
      if (OrdersTotal() == 0) {
         OrderSend(Symbol(), OP_SELL, 0.1, Bid, 3, sh1, bl2, "Key Level Sell", 0, 0, Red);
      }
   }

   return rates_total;
}

// Function to draw key levels on the chart
void DrawKeyLevels()
{
   // Remove old objects
   ObjectsDeleteAll(0, OBJ_HLINE);
   
   // Draw buy and sell lines with appropriate colors
   DrawLine("BL1", bl1, Red);
   DrawLine("BH1", bh1, Green);
   
   DrawLine("BL2", bl2, Red);
   DrawLine("BH2", bh2, Green);
   
   DrawLine("BL3", bl3, Red);
   DrawLine("BH3", bh3, Green);
   
   DrawLine("BL4", bl4, Red);
   DrawLine("BH4", bh4, Green);
   
   DrawLine("BL5", bl5, Red);
   DrawLine("BH5", bh5, Green);
   
   DrawLine("SH1", sh1, Green);
   DrawLine("SL1", sl1, Red);
   
   DrawLine("SH2", sh2, Green);
   DrawLine("SL2", sl2, Red);
   
   DrawLine("SH3", sh3, Green);
   DrawLine("SL3", sl3, Red);
   
   DrawLine("SH4", sh4, Green);
   DrawLine("SL4", sl4, Red);
   
   DrawLine("SH5", sh5, Green);
   DrawLine("SL5", sl5, Red);
}

// Helper function to draw horizontal lines
void DrawLine(string name, double price, color clr)
{
   if (price > 0) {
      ObjectCreate(0, name, OBJ_HLINE, 0, Time[0], price);
      ObjectSetInteger(0, name, OBJPROP_COLOR, clr);
      ObjectSetInteger(0, name, OBJPROP_WIDTH, 2);
   }
}
