//+------------------------------------------------------------------+
//|                                      Percent Bollinger Bands.mq4 |
//|                                           Ким Игорь В. aka KimIV |
//|                                              http://www.kimiv.ru |
//+------------------------------------------------------------------+
#property copyright "Ким Игорь В. aka KimIV"
#property link      "http://www.kimiv.ru"

#property indicator_separate_window
//---- input parameters
extern int MA_Period=20;
extern int Deviation=2;
//---- indicator buffers
double ExtMapBuffer[];

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init() {
  SetIndexStyle(0, DRAW_LINE);
  IndicatorDigits(MarketInfo(Symbol(), MODE_DIGITS));
  SetIndexBuffer(0, ExtMapBuffer);
  return(0);
}

//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start() {
  int i, counted_bars = IndicatorCounted();
  double dn, up;
  if(Bars<=MA_Period) return(0);
//---- check for possible errors
  if (counted_bars<0) return(-1);
//---- last counted bar will be recounted
  if (counted_bars>0) counted_bars--;
//---- 
  i = Bars - MA_Period - 1;
  if(counted_bars>=MA_Period) i = Bars - counted_bars - 1;
  while(i>=0) {
    dn = iBands(NULL,0,MA_Period,Deviation,0,PRICE_LOW,MODE_LOWER,i);
    up = iBands(NULL,0,MA_Period,Deviation,0,PRICE_HIGH,MODE_UPPER,i);
    ExtMapBuffer[i] = (Close[i] - dn) / (up - dn);
    i--;
  }
//----
  return(0);
}
//+------------------------------------------------------------------+