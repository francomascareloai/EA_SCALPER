//+------------------------------------------------------------------+
//|                                                     TrendOSC.mq4 |
//|                      Copyright © 2005, MetaQuotes Software Corp. |
//|                                        http://www.metaquotes.net |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2005, DVYU."
#property link      "http://www.DVYU.ox"
#property indicator_buffers 1
#property indicator_color1 Yellow
#property indicator_separate_window
//#property indicator_minimum -1
//#property indicator_maximum 1
//параметры
int g_period;
//.extern int dBar=3;
//Объявление глобальных переменных
double z_buffer[];
//double SpeedTrend1;
double dBar;
int x;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
   
  SetIndexStyle(0, DRAW_HISTOGRAM, EMPTY, 2, Yellow);
  SetIndexBuffer(0,z_buffer);
  IndicatorDigits(4);
  
  int x=Period();
  //string P;
  //Для подбора смещения (shift) индикатора измените значение g_period для нужного периода графика
  switch (x)
  {
  case 1:g_period=110;
  Comment("Минутный график","   ","Смещение",g_period);
  break;
  case 5:g_period=90;
  Comment("Пятиминутный график","   ","Смещение",g_period);
   break;
  case 15:g_period=60;
  Comment("Пятнадцатиминутный график","   ","Смещение",g_period);
   break;
  case 30:g_period=42;
  Comment("Получасовой график","   ","Смещение",g_period);
   break;
  case 60:g_period=36;
  Comment("Часовой график","   ","Смещение",g_period);
   break;
  case 240:g_period=24;
  Comment("Четырехчасовой график","   ","Смещение",g_period);
   break;
  case 1440:g_period=18;
  Comment("Дневной график","   ","Смещение",g_period);
   break;
  case 10080:g_period=12;
  Comment("Недельный  график","   ","Смещение",g_period);
   break;
  case 43200:g_period=3;
  Comment("Месячный график","   ","Смещение",g_period);
   break;
  }
   return(0);
  }
//+------------------------------------------------------------------+
//| Custor indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
//---- 
   
//----
  return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {
  int limit = 0; 
  int z;
int counted_bars=IndicatorCounted();
      if(counted_bars<0) return(-1); 
          if(counted_bars>0) counted_bars--; 
              limit=Bars-counted_bars;  
  
   for  (int i=0; i<limit; i++)
{
 
 z_buffer[i]=MathSin((Close[i]-Close[i+g_period])/g_period);

 
 }

 
//---- 
   
//----
   return(0);
  }
//+------------------------------------------------------------------+