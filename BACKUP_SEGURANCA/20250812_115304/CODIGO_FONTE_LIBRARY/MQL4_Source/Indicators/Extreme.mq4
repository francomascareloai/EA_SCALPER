//+------------------------------------------------------------------+
//|                                                       Extreme.mq4|
//|                        Non-repainting Extreme Condition Indicator|
//+------------------------------------------------------------------+
#property indicator_separate_window
#property indicator_buffers 1
#property indicator_color1 Magenta

// Indicator buffer
double ConditionBuffer1[];

// Input parameters
input int emaPeriod = 26; // EMA Period
input int atrPeriod = 50; // ATR Period
input double atr_threshold1 = 2.5; // ATR Threshold Low
input double atr_threshold2 = 3.5; // ATR Threshold Mid
input double atr_threshold3 = 4.0; // ATR Threshold High
input int Adx_Period = 14; // ADX period
input double Adx_Threshold = 25; // ADX threshold

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit() {
   SetIndexBuffer(0, ConditionBuffer1);
   SetIndexStyle(0, DRAW_LINE);
   IndicatorShortName("Extreme");
   return(INIT_SUCCEEDED);
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
                const int &spread[]) {
   if (rates_total < atrPeriod) return (0);
   int limit = rates_total - prev_calculated;
   for (int i = limit - 1; i > 0; i--) {
      double adx = iADX(Symbol(), Period(), Adx_Period, PRICE_CLOSE, MODE_MAIN, i);
      double slowMAValue = iMA(Symbol(), Period(), emaPeriod, 0, MODE_EMA, PRICE_WEIGHTED, i);
      double atr = iATR(Symbol(), Period(), atrPeriod, i);
      bool isExtremeH1 = (High[i] - slowMAValue) >= atr * atr_threshold1;
      bool isExtremeL1 = (slowMAValue - Low[i]) >= atr * atr_threshold1;
      bool isExtremeH2 = (High[i] - slowMAValue) >= atr * atr_threshold1;
      bool isExtremeL2 = (slowMAValue - Low[i]) >= atr * atr_threshold1;
      bool isExtremeH3 = (High[i] - slowMAValue) >= atr * atr_threshold3;
      bool isExtremeL3 = (slowMAValue - Low[i]) >= atr * atr_threshold3;
      if(adx >= Adx_Threshold) {
         if (isExtremeH1) {
            if (isExtremeH3) {
               ConditionBuffer1[i-1] = 1.0;
            } else {
               if (isExtremeH2) {
                  ConditionBuffer1[i-1] = 0.5;
               } else {
                  ConditionBuffer1[i-1] = 0.25;
               }
            }
         } else {
            if (isExtremeL1) {
               if (isExtremeL3) {
                  ConditionBuffer1[i-1] = -1.0;
               } else {
                  if (isExtremeL2) {
                     ConditionBuffer1[i-1] = -0.5;
                  } else {
                     ConditionBuffer1[i-1] = -0.25;
                  }
               }
            } else {
               ConditionBuffer1[i-1] = 0;
            }
         }
      } else {
         ConditionBuffer1[i-1] = 0;
      }
   }
   return (rates_total);
}
