//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "PSmith"
#property link ""

#property indicator_chart_window
#property indicator_buffers 3
#property indicator_color1 Red
#property indicator_color2 Red
#property indicator_color3 Blue

extern int ExtremumOffset = 2;
extern int ChannelWidth = 10;
int ChWidth=0;
int beg_pos = 0;
// Буферы индикатора
double Hprice[];
double Lprice[];
double Aprice[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function |
//+------------------------------------------------------------------+
int init()
{
//---- indicators
switch (Period()) {
  case PERIOD_M1: ChWidth = ChannelWidth*60; beg_pos = ExtremumOffset*60; break;
  case PERIOD_M5: ChWidth = ChannelWidth*12; beg_pos = ExtremumOffset*12; break;
  case PERIOD_M15: ChWidth = ChannelWidth*4; beg_pos = ExtremumOffset*4; break;
  case PERIOD_M30: ChWidth = ChannelWidth*2; beg_pos = ExtremumOffset*2; break;
  case PERIOD_H1: ChWidth = ChannelWidth; beg_pos = ExtremumOffset; break;
  case PERIOD_H4: ChWidth = ChannelWidth/4; beg_pos = 1; break;
  default: ChWidth = 1; beg_pos = 1; break;
}
//----

IndicatorDigits(MarketInfo(Symbol(),MODE_DIGITS)); 
// HighLine
SetIndexStyle(0, DRAW_LINE);
SetIndexBuffer(0,Hprice);
SetIndexDrawBegin(0,ChWidth);
SetIndexShift(0,0);
// LowLine
SetIndexStyle(1, DRAW_LINE);
SetIndexBuffer(1,Lprice);
SetIndexDrawBegin(1,ChWidth);
SetIndexShift(1,0);
// AvgLine
SetIndexStyle(2, DRAW_LINE, STYLE_DASH);
SetIndexBuffer(2,Aprice);
SetIndexDrawBegin(2,ChWidth);
SetIndexShift(2,0);

return(0);
}
//+------------------------------------------------------------------+
//| Custor indicator deinitialization function |
//+------------------------------------------------------------------+
int deinit()
{
//---- TODO: add your code here

//----
return(0);
}
//+------------------------------------------------------------------+
//| Custom indicator iteration function |
//+------------------------------------------------------------------+
int start()
{
  int counted_bars=IndicatorCounted();
  int pos = 0;
  if (counted_bars<0) return(-1);
  if (Bars < (ChWidth+beg_pos)) return(-1);

  pos = Bars-counted_bars+1;

  while (pos>=0) {
    Hprice[pos] = HighCount(pos+beg_pos, ChWidth);
    Lprice[pos] = LowCount(pos+beg_pos, ChWidth);
    Aprice[pos] = MathRound((Hprice[pos]+Lprice[pos])/2/Point)*Point;
    pos--;
  }

  Comment("\n","Paramon\'s day: Coridor ", (Hprice[0]-Lprice[0])*MathPow(10, MarketInfo(Symbol(), MODE_DIGITS)), " points \n");

//----
  return(0);
}
//+------------------------------------------------------------------+
double LowCount(int pos, int ChWidth)
{
  int shift=0;
  double lowprice=0, rndprice=0;

  shift=Lowest(NULL, 0, MODE_LOW, ChWidth, pos);
  lowprice=Low[shift];
  rndprice = MathRound(lowprice/Point/10)*10 - 5;
  if ((lowprice/Point - rndprice) > 5) lowprice = (rndprice+5)*Point;
  else lowprice = rndprice*Point;
  
  return(lowprice);
}
//+------------------------------------------------------------------+
double HighCount(int pos, int ChWidth)
{
  int shift=0;
  double highprice=0, rndprice=0;

  shift=Highest(NULL, 0, MODE_HIGH, ChWidth, pos);
  highprice=High[shift]+MarketInfo(Symbol(),MODE_SPREAD)*Point;
  rndprice = MathRound(highprice/Point/10)*10 + 5;
  if ((rndprice - (highprice/Point)) > 5) highprice = (rndprice-5)*Point;
  else highprice = rndprice*Point;

  return(highprice);
}