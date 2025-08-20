//+------------------------------------------------------------------+
//|                                            LinearRegSlope_v1.mq4 |
//|                                Copyright © 2006, TrendLaboratory |
//|            http://finance.groups.yahoo.com/group/TrendLaboratory |
//|                                   E-mail: igorad2003@yahoo.co.uk |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2006, TrendLaboratory"
#property link      "http://finance.groups.yahoo.com/group/TrendLaboratory"
//----
#property indicator_separate_window
#property indicator_buffers 1
#property indicator_color1 SkyBlue
#property indicator_width1 2
//---- input parameters
extern int     Price         =0;   //Apply to Price(0-Close;1-Open;2-High;3-Low;4-Median price;5-Typical price;6-Weighted Close) 
extern int     Length        =14;  //Period of NonLagMA
//---- indicator buffers
double RegSlope[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
  int init()
  {
   SetIndexStyle(0,DRAW_LINE);
   SetIndexBuffer(0,RegSlope);
   string short_name;
//---- indicator line
   IndicatorDigits(MarketInfo(Symbol(),MODE_DIGITS));
//---- name for DataWindow and indicator subwindow label
   short_name="LinearRegSlope("+Length+")";
   IndicatorShortName(short_name);
   SetIndexLabel(0,"LinearRegSlope");
   SetIndexDrawBegin(0,Length);
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| LinearRegSlope_v1                                                |
//+------------------------------------------------------------------+
int start()
  {
   int    i,shift, counted_bars=IndicatorCounted(),limit;
   double price;
   if(counted_bars > 0) limit=Bars-counted_bars;
   if(counted_bars < 0) return(0);
   if(counted_bars ==0) limit=Bars-Length-1;
   if(counted_bars < 1)
      for(i=1;i<Length;i++) RegSlope[Bars-i]=0;
   double SumBars=Length * (Length - 1) * 0.5;
   double SumSqrBars=(Length - 1.0) * Length * (2.0 * Length - 1.0)/6.0;
   for(shift=limit;shift>=0;shift--)
     {
      double Sum1=0;
      for(i=0;i<=Length-1;i++) Sum1+=i*iMA(NULL,0,1,0,1,Price,i+shift);
      double SumY=0;
      for(i=0;i<=Length-1;i++) SumY+=iMA(NULL,0,1,0,1,Price,i+shift);
      double Sum2=SumBars * SumY;
      double Num1=Length * Sum1 - Sum2;
      double Num2=SumBars * SumBars - Length * SumSqrBars;
      if(Num2!=0)
         RegSlope[shift]=100*Num1/Num2;
      else
         RegSlope[shift]=0;
     }
//----
   return(0);
  }
//+------------------------------------------------------------------+