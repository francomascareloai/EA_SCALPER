//+------------------------------------------------------------------+
//|                                                  Silver MACD.mq4 |
//|                                           Copyright © 2004, Viac |
//|                                              http://www.viac.ru/ |
//+------------------------------------------------------------------+
#property  copyright "Copyright © 2004, Viac.ru"
#property  link      "http://www.viac.ru/"

//---- indicator settings
#property  indicator_separate_window
#property  indicator_buffers 2
#property  indicator_color1  ForestGreen
#property  indicator_color2  Red
//---- indicator parameters
extern int FastEMA=9;
extern int SlowEMA=26;
extern int SignalSMA=9;
extern int Price=PRICE_CLOSE;
extern int Mode=MODE_EMA;


//---- indicator buffers
double green_buffer[];
double red_buffer[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- drawing settings
   SetIndexStyle(0,DRAW_HISTOGRAM,STYLE_SOLID,2);
   SetIndexBuffer(0,green_buffer);
//----
   SetIndexStyle(1,DRAW_HISTOGRAM,STYLE_SOLID,2);
   SetIndexBuffer(1,red_buffer);
//----
   IndicatorDigits(Digits+1);
//---- name for DataWindow and indicator subwindow label
   IndicatorShortName("MACD("+FastEMA+","+SlowEMA+","+SignalSMA+")");
   SetIndexLabel(0,"MACD");
//---- initialization done
   return(0);
  }
//+------------------------------------------------------------------+
//| Moving Averages Convergence/Divergence                           |
//+------------------------------------------------------------------+
int start()
  {
   double MACD[];
   double Signal[];
   int limit;   
   int counted_bars=IndicatorCounted();
   int i;
//---- check for possible errors
   if(counted_bars<0) return(-1);
//
   if(counted_bars>0) counted_bars--;
   limit=Bars-counted_bars;
//---- Вычисляем массив MACD
   for(i=0; i<limit; i++)
      MACD[i]=iMA(NULL,0,FastEMA,0,Mode,Price,i)-iMA(NULL,0,SlowEMA,0,Mode,Price,i);
//---- Вычисляем сигнальную линию для MACD
   for(i=0; i<limit; i++)
      Signal[i]=iMAOnArray(MACD,Bars,SignalSMA,0,MODE_SMA,i);
//---- Если MACD больше или равно сигнальной, то зеленый иначе красный 
   for (i=0; i<limit; i++) 
   {
      if (MACD[i] >= Signal[i]) 
      {
        green_buffer[i] = MACD[i];
        red_buffer[i] = 0;
      }
      else 
      {
        green_buffer[i] = 0;
        red_buffer[i] = MACD[i];
      }
   }
   return(0);
  }

