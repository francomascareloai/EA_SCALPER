#property copyright "Your Name"
#property link      "https://yourwebsite.com"
#property version   "1.00"
#property strict
#property indicator_chart_window
#property indicator_buffers 5
#property indicator_plots   3
#property indicator_label1  "EliteSignal Main"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrYellow
#property indicator_style1  STYLE_SOLID
#property indicator_width1  3
#property indicator_label2  "EliteSignal Upper"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrYellow
#property indicator_style2  STYLE_SOLID
#property indicator_width2  3
#property indicator_label3  "EliteSignal Lower"
#property indicator_type3   DRAW_LINE
#property indicator_color3  clrYellow
#property indicator_style3  STYLE_SOLID
#property indicator_width3  3
#property indicator_label4  "Buy Signal"
#property indicator_type4   DRAW_ARROW
#property indicator_color4  clrYellow
#property indicator_style4  STYLE_SOLID
#property indicator_width4  2
#property indicator_label5  "Sell Signal"
#property indicator_type5   DRAW_ARROW
#property indicator_color5  clrRed
#property indicator_style5  STYLE_SOLID
#property indicator_width5  2

//--- Input parameters
input int ATRperiod = 5;            // ATR Period
input int BBperiod = 21;            // Bollinger Bands Period
input double BBdeviation = 1.0;     // Bollinger Bands Deviation
input bool UseATRfilter = true;     // ATR Filter On/Off
input bool showsignals = true;      // Show Signals

//--- Indicator buffers
double EliteSignalBuffer[];         // Main trend line
double EliteSignalUpperBuffer[];    // Upper trend line
double EliteSignalLowerBuffer[];    // Lower trend line
double BuySignalBuffer[];           // Buy signal arrows
double SellSignalBuffer[];          // Sell signal arrows

//--- Global variables
double atrValue[];
double BBUpper[];
double BBLower[];
int iTrend[];
double prevEliteSignal[];
double closeArray[];
double highArray[];
double lowArray[];

//+------------------------------------------------------------------+
//| Custom indicator initialization function                           |
//+------------------------------------------------------------------+
int OnInit()
{
   // Assign indicator buffers
   SetIndexBuffer(0, EliteSignalBuffer);
   SetIndexBuffer(1, EliteSignalUpperBuffer);
   SetIndexBuffer(2, EliteSignalLowerBuffer);
   SetIndexBuffer(3, BuySignalBuffer);
   SetIndexBuffer(4, SellSignalBuffer);
   
   // Set buffer styles
   SetIndexStyle(0, DRAW_LINE, STYLE_SOLID, 3);
   SetIndexStyle(1, DRAW_LINE, STYLE_SOLID, 3);
   SetIndexStyle(2, DRAW_LINE, STYLE_SOLID, 3);
   SetIndexStyle(3, DRAW_ARROW, STYLE_SOLID, 2);
   SetIndexStyle(4, DRAW_ARROW, STYLE_SOLID, 2);
   SetIndexArrow(3, 233); // Up arrow for buy
   SetIndexArrow(4, 234); // Down arrow for sell
   
   // Set buffer labels
   SetIndexLabel(0, "EliteSignal Main");
   SetIndexLabel(1, "EliteSignal Upper");
   SetIndexLabel(2, "EliteSignal Lower");
   SetIndexLabel(3, "Buy Signal");
   SetIndexLabel(4, "Sell Signal");
   
   // Initialize arrays
   ArraySetAsSeries(EliteSignalBuffer, true);
   ArraySetAsSeries(EliteSignalUpperBuffer, true);
   ArraySetAsSeries(EliteSignalLowerBuffer, true);
   ArraySetAsSeries(BuySignalBuffer, true);
   ArraySetAsSeries(SellSignalBuffer, true);
   ArraySetAsSeries(atrValue, true);
   ArraySetAsSeries(BBUpper, true);
   ArraySetAsSeries(BBLower, true);
   ArraySetAsSeries(iTrend, true);
   ArraySetAsSeries(prevEliteSignal, true);
   ArraySetAsSeries(closeArray, true);
   ArraySetAsSeries(highArray, true);
   ArraySetAsSeries(lowArray, true);
   
   // Resize arrays
   ArrayResize(atrValue, Bars);
   ArrayResize(BBUpper, Bars);
   ArrayResize(BBLower, Bars);
   ArrayResize(iTrend, Bars);
   ArrayResize(prevEliteSignal, Bars);
   ArrayResize(closeArray, Bars);
   ArrayResize(highArray, Bars);
   ArrayResize(lowArray, Bars);
   
   return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| Custom indicator iteration function                                |
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
   // Ensure enough bars for calculations
   if(rates_total < MathMax(ATRperiod, BBperiod)) return(0);
   
   // Initialize arrays with price data
   ArrayCopy(closeArray, close);
   ArrayCopy(highArray, high);
   ArrayCopy(lowArray, low);
   
   // Calculate Bollinger Bands and ATR
   for(int i = 0; i < rates_total - prev_calculated; i++)
   {
      BBUpper[i] = iMA(NULL, 0, BBperiod, 0, MODE_SMA, PRICE_CLOSE, i) + 
                   iStdDev(NULL, 0, BBperiod, 0, MODE_SMA, PRICE_CLOSE, i) * BBdeviation;
      BBLower[i] = iMA(NULL, 0, BBperiod, 0, MODE_SMA, PRICE_CLOSE, i) - 
                   iStdDev(NULL, 0, BBperiod, 0, MODE_SMA, PRICE_CLOSE, i) * BBdeviation;
      atrValue[i] = iATR(NULL, 0, ATRperiod, i);
   }
   
   // Calculate signals
   for(int i = 0; i < rates_total - prev_calculated && i < rates_total - 1; i++)
   {
      int BBSignal = 0;
      
      // Determine BB signal
      if(closeArray[i] > BBUpper[i])
         BBSignal = 1;
      else if(closeArray[i] < BBLower[i])
         BBSignal = -1;
      
      // Buy signal logic
      if(BBSignal == 1)
      {
         EliteSignalBuffer[i] = UseATRfilter ? lowArray[i] - atrValue[i] : lowArray[i];
         if(i < rates_total - 1 && EliteSignalBuffer[i] < prevEliteSignal[i + 1])
            EliteSignalBuffer[i] = prevEliteSignal[i + 1];
      }
      // Sell signal logic
      else if(BBSignal == -1)
      {
         EliteSignalBuffer[i] = UseATRfilter ? highArray[i] + atrValue[i] : highArray[i];
         if(i < rates_total - 1 && EliteSignalBuffer[i] > prevEliteSignal[i + 1])
            EliteSignalBuffer[i] = prevEliteSignal[i + 1];
      }
      else
      {
         EliteSignalBuffer[i] = i < rates_total - 1 ? prevEliteSignal[i + 1] : EliteSignalBuffer[i];
      }
      
      // Store current EliteSignal for next iteration
      prevEliteSignal[i] = EliteSignalBuffer[i];
      
      // Trend direction
      if(i < rates_total - 1)
      {
         if(EliteSignalBuffer[i] > prevEliteSignal[i + 1])
            iTrend[i] = 1;
         else if(EliteSignalBuffer[i] < prevEliteSignal[i + 1])
            iTrend[i] = -1;
         else
            iTrend[i] = iTrend[i + 1];
      }
      
      // Calculate upper and lower lines
      double gapSize = atrValue[i] * 0.5;
      EliteSignalUpperBuffer[i] = EliteSignalBuffer[i] + gapSize;
      EliteSignalLowerBuffer[i] = EliteSignalBuffer[i] - gapSize;
      
      // Buy and sell signals
      if(i < rates_total - 1 && iTrend[i + 1] == -1 && iTrend[i] == 1)
      {
         BuySignalBuffer[i] = EliteSignalBuffer[i] - atrValue[i];
         if(showsignals)
            Alert("Gain Buy Sell Buy");
      }
      else
         BuySignalBuffer[i] = EMPTY_VALUE;
         
      if(i < rates_total - 1 && iTrend[i + 1] == 1 && iTrend[i] == -1)
      {
         SellSignalBuffer[i] = EliteSignalBuffer[i] + atrValue[i];
         if(showsignals)
            Alert("Gain Buy Sell Sell");
      }
      else
         SellSignalBuffer[i] = EMPTY_VALUE;
   }
   
   // Dynamically set colors based on trend (Note: MQL4 doesn't support dynamic color changes per bar easily)
   for(int i = 0; i < rates_total - prev_calculated; i++)
   {
      if(iTrend[i] > 0)
      {
         SetIndexStyle(0, DRAW_LINE, STYLE_SOLID, 3, clrYellow);
         SetIndexStyle(1, DRAW_LINE, STYLE_SOLID, 3, clrYellow);
         SetIndexStyle(2, DRAW_LINE, STYLE_SOLID, 3, clrYellow);
      }
      else
      {
         SetIndexStyle(0, DRAW_LINE, STYLE_SOLID, 3, clrRed);
         SetIndexStyle(1, DRAW_LINE, STYLE_SOLID, 3, clrRed);
         SetIndexStyle(2, DRAW_LINE, STYLE_SOLID, 3, clrRed);
      }
   }
   
   return(rates_total);
}