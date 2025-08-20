
//+------------------------------------------------------------------+
//|                                                  MACD_Mirror.mq4 |
//|                           Copyright © 2010, Andy Tjatur Pramono. |
//|                                            andy.tjatur@gmail.com |
//+------------------------------------------------------------------+
#property  copyright "Copyright © 2010, Andy Tjatur Pramono."
#property  link      "andy.tjatur@gmail.com"
//---- indicator settings
#property  indicator_separate_window
#property indicator_level1 0
#property indicator_levelcolor Yellow
#property  indicator_buffers 3
#property  indicator_color1  Red
#property  indicator_color2  Blue
#property  indicator_color3  Yellow
#property  indicator_width1  2
#property  indicator_width2  2
#property  indicator_width3  2
//---- indicator parameters
extern int PeriodeEMA=20;
extern int SignalSMA=9;
//---- indicator buffers
double     MacdBuffer[];
double     Macd2Buffer[];
double     SignalBuffer[];

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- drawing settings
   SetIndexStyle(0,DRAW_LINE);
   SetIndexStyle(1,DRAW_LINE);
   SetIndexStyle(2,DRAW_LINE);
   SetIndexDrawBegin(2,SignalSMA);
   IndicatorDigits(Digits+1);
//---- indicator buffers mapping
   SetIndexBuffer(0,MacdBuffer);
   SetIndexBuffer(1,Macd2Buffer);
   SetIndexBuffer(2,SignalBuffer);
//---- name for DataWindow and indicator subwindow label
   IndicatorShortName("MACD_Mirror by Andy Tjatur("+PeriodeEMA+","+SignalSMA+")");
   SetIndexLabel(0,"MACD");
   SetIndexLabel(1,"MACD2");
   SetIndexLabel(2,"Signal");
//---- initialization done
   return(0);
  }
//+------------------------------------------------------------------+
//| MACD MIRROR                          |
//+------------------------------------------------------------------+
int start()
  {
   int limit;
   int counted_bars=IndicatorCounted();
//---- last counted bar will be recounted
   if(counted_bars>0) counted_bars--;
   limit=Bars-counted_bars;
//---- macd mirror counted in the 1-st buffer
   for(int i=0; i<limit; i++)
   
      MacdBuffer[i]=iMA(NULL,0,PeriodeEMA,0,MODE_EMA,PRICE_CLOSE,i)-iMA(NULL,0,PeriodeEMA,0,MODE_EMA,PRICE_OPEN,i);
      
//---- macd mirror counted in the 2-nd buffer
   for( i=0; i<limit; i++)
   
      Macd2Buffer[i]=iMA(NULL,0,PeriodeEMA,0,MODE_EMA,PRICE_OPEN,i)-iMA(NULL,0,PeriodeEMA,0,MODE_EMA,PRICE_CLOSE,i);      
 
//---- signal line mirror counted in the 3-rd buffer
   for( i=0; i<limit; i++)
      SignalBuffer[i]=iMAOnArray(MacdBuffer,Bars,SignalSMA,0,MODE_SMA,i);
//---- done
   return(0);
  }
//+------------------------------------------------------------------+