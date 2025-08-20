//+------------------------------------------------------------------+
//|                                                      VIP_DSR.mq4 |
//|                                       Copyright © 2010, KingLion |
//|                                     http://www.metastock.org.ua/ |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2010, KingLion"
#property link      "http://www.metastock.org.ua/"

#property indicator_chart_window
#property indicator_buffers 3
#property indicator_color1 DarkGreen
#property indicator_color2 FireBrick
#property indicator_color3 DarkGoldenrod
//--- input parameters
extern string Custom_Indicator = "VIP Dynamic Support/Resistance";
extern string Copyright = "Copyright © 2010, KingLion";
extern string Web_Address = "www.metastock.org.ua";
//--- buffers
double Support[];
double Resistance[];
double SR_Mean[];
double HLC3[];
double MAOnArray[];
int counted_bars = 0;
int init()
  {
      IndicatorBuffers(5);
      SetIndexStyle(0, DRAW_LINE, STYLE_SOLID, 2);
      SetIndexStyle(1, DRAW_LINE, STYLE_SOLID, 2);
      SetIndexStyle(2, DRAW_LINE, STYLE_DOT, 1);
      SetIndexBuffer(0, Resistance);
      SetIndexBuffer(1, Support);
      SetIndexBuffer(2, SR_Mean);
      SetIndexBuffer(3, HLC3);
      SetIndexBuffer(4, MAOnArray);
      SetIndexLabel(0, "Resistance");
      SetIndexLabel(1, "Support");
      SetIndexLabel(2, "S/R_Mean");
      SetIndexDrawBegin(0, 25);
      SetIndexDrawBegin(1, 25);
      SetIndexDrawBegin(2, 25);
   return(0);
  }
int deinit()
  {
   return(0);
  }
int start()
  {
   counted_bars = IndicatorCounted();
   if (Bars <= 25) return (0);
   int i = Bars - counted_bars;
   if (counted_bars > 0) i++;
   else {
      Resistance[i] = High[i];
      Support[i] = Low[i];
   }
   for (int j = 0; j < i; j++) HLC3[j] = (High[iHighest(NULL, 0, MODE_HIGH, 3, j)] + Low[iLowest(NULL, 0, MODE_LOW, 3, j)] + Close[j]) / 3.0;
   for (j = 0; j < i; j++) MAOnArray[j] = iMAOnArray(HLC3, Bars, 25, 0, MODE_SMA, j);
   for (j = i - 1; j >= 0; j--) {
      if (HLC3[j + 1] > MAOnArray[j + 1] && HLC3[j] < MAOnArray[j]) Resistance[j] = High[iHighest(NULL, 0, MODE_HIGH, 28, j)];
      else Resistance[j] = Resistance[j + 1];
   }
   for (j = i - 1; j >= 0; j--) {
      if (HLC3[j + 1] < MAOnArray[j + 1] && HLC3[j] > MAOnArray[j]) Support[j] = Low[iLowest(NULL, 0, MODE_LOW, 28, j)];
      else Support[j] = Support[j + 1];
   }
   for (j = 0; j < i; j++) SR_Mean[j] = NormalizeDouble((Resistance[j] + Support[j]) / 2.0, Digits);
   return(0);
  }