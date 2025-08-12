//+------------------------------------------------------------------+
//|               MACD_4CZ                           Custom MACD.mq4 |
//|                      Copyright © 2004, MetaQuotes Software Corp. |
//|       mod. from ASilver MACD534     http://www.metaquotes.net/ik |
//| MACD_4CZ    4colors  up/dn over/under zero;    www.forexTSD.com  |
//+------------------------------------------------------------------+
#property  copyright "Copyright © 2004, MetaQuotes Software Corp."
#property  link      "http://www.metaquotes.net/" 

//---- indicator settings
#property  indicator_separate_window
#property  indicator_buffers 4
#property  indicator_color1  LimeGreen
#property  indicator_color2  DarkGreen
#property  indicator_color3  Red
#property  indicator_color4  Maroon
#property indicator_width1 2
#property indicator_width2 2
#property indicator_width3 2
#property indicator_width4 2
#property indicator_level1 0.004
#property indicator_level2 0.002
#property indicator_level3 0.0004
#property indicator_level4 0
#property indicator_level5 -0.0004
#property indicator_level6 -0.002
#property indicator_level7 -0.004
#property indicator_levelcolor SlateGray
#property indicator_levelstyle 2

//---- indicator parameters
extern int FastEMA=21;
extern int SlowEMA=34;
//---- indicator buffers
double green_buffer[];
double DarkGreen_buffer[];
double red_buffer[];
double Maroon_buffer[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- drawing settings
   SetIndexStyle(0,DRAW_HISTOGRAM,STYLE_SOLID);
   SetIndexBuffer(0,green_buffer);
//----
   SetIndexStyle(1,DRAW_HISTOGRAM,STYLE_SOLID);
   SetIndexBuffer(1,DarkGreen_buffer);
//----
   SetIndexStyle(2,DRAW_HISTOGRAM,STYLE_SOLID);
   SetIndexBuffer(2,red_buffer);
//----
   SetIndexStyle(3,DRAW_HISTOGRAM,STYLE_SOLID);
   SetIndexBuffer(3,Maroon_buffer);
//----

   IndicatorDigits(Digits+1);
//---- name for DataWindow and indicator subwindow label
    string short_name="MACD("+FastEMA+","+SlowEMA+")";
   IndicatorShortName(short_name);
   SetIndexLabel(0,short_name);
   SetIndexLabel(1,short_name);
   SetIndexLabel(2,short_name);
   SetIndexLabel(3,short_name);



//---- initialization done
   return(0);
  }
//+------------------------------------------------------------------+
//| Moving Averages Convergence/Divergence                           |
//+------------------------------------------------------------------+
int start()
  {
   double MACD;
   int counted_bars=IndicatorCounted();
   int i;
//---- check for possible errors
   if(counted_bars<0) return(-1);
//---- last counted bar will be recounted
   for (i = Bars - Max (counted_bars-1, 1); i>=0; i--) {
      MACD=iMA(NULL,0,FastEMA,0,MODE_EMA,PRICE_MEDIAN,i)-
           iMA(NULL,0,SlowEMA,0,MODE_EMA,PRICE_MEDIAN,i);
if(MACD>0) {
      if ( ( (green_buffer[i+1] != 0) && (MACD >= green_buffer[i+1]) ) ||
           ( (DarkGreen_buffer[i+1] != 0) && (MACD > DarkGreen_buffer[i+1]) ) ) {
        green_buffer[i] = MACD;
        DarkGreen_buffer[i] = 0;
      }
      else {
        green_buffer[i] = 0;
        DarkGreen_buffer[i] = MACD;}
     }
       else {
     if ( ( (red_buffer[i+1] != 0) && (MACD >= red_buffer[i+1]) ) ||
           ( (Maroon_buffer[i+1] != 0) && (MACD > Maroon_buffer[i+1]) ) ) {
        red_buffer[i] = MACD;
        Maroon_buffer[i] = 0;
      }
      else {
        red_buffer[i] = 0;
        Maroon_buffer[i] = MACD;
   } 
      }
   }
//---- done
   return(0);
  }

//+------------------------------------------------------------------+
int Max (int val1, int val2) {
  if (val1 > val2)  return(val1);
  return(val2);
}

