//compile//------------------------------------------------------------------+
//| Custom MACD+OsMA.mq4 |
//| Copyright © 2004, MetaQuotes Software Corp. |
//| http://www.metaquotes.net/ |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2004, MetaQuotes Software Corp."
#property link "http://www.metaquotes.net/"
//---- indicator settings
#property indicator_separate_window
#property indicator_buffers 3
#property indicator_color1 Silver
#property indicator_color2 Red
#property indicator_color3 Silver
//---- indicator parameters
extern int FastEMA=12;
extern int SlowEMA=26;
extern int SignalSMA=9;
//---- indicator buffers
double ind_buffer1[];
double ind_buffer2[];
double ind_buffer3[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function |
//+------------------------------------------------------------------+
int init()
{
//---- drawing settings
SetIndexStyle(0,DRAW_LINE,STYLE_SOLID,1);
SetIndexStyle(1,DRAW_LINE,STYLE_SOLID,1);
SetIndexStyle(2,DRAW_HISTOGRAM,STYLE_SOLID,1);
SetIndexDrawBegin(1,SignalSMA);
IndicatorDigits(MarketInfo(Symbol(),MODE_DIGITS)+1);
//---- indicator buffers mapping
if(!SetIndexBuffer(0,ind_buffer1) && !SetIndexBuffer(1,ind_buffer2) && !SetIndexBuffer(2,ind_buffer3))
Print("cannot set indicator buffers!");
//---- name for DataWindow and indicator subwindow label
IndicatorShortName("MACD("+FastEMA+","+SlowEMA+","+SignalSMA+")");
SetIndexLabel(0,"MACD");
SetIndexLabel(1,"Signal");
SetIndexLabel(2,"OsMA");
//---- initialization done
return(0);
}
//+------------------------------------------------------------------+
//| Moving Averages Convergence/Divergence |
//+------------------------------------------------------------------+
int start()
{
int limit;
int counted_bars=IndicatorCounted();
//---- check for possible errors
if(counted_bars<0) return(-1);
//---- last counted bar will be recounted
if(counted_bars>0) counted_bars--;
limit=Bars-counted_bars;
//---- macd counted in the 1-st buffer
for(int i=0; i<limit; i++)
ind_buffer1[i]=iMA(NULL,0,FastEMA,0,MODE_EMA,PRICE_CLOSE,i)-iMA(NULL,0,SlowEMA,0,MODE_EMA,PRICE_CLOSE,i);
//---- signal line counted in the 2-nd buffer
for(i=0; i<limit; i++)
ind_buffer2[i]=iMAOnArray(ind_buffer1,Bars,SignalSMA,0,MODE_SMA,i);
for(i=0; i<limit; i++)
ind_buffer3[i]=iOsMA(NULL,0,FastEMA,SlowEMA,SignalSMA,PRICE_CLOSE,i);
//---- done
return(0);
} 