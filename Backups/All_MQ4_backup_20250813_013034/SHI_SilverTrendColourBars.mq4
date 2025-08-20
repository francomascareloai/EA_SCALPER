//+------------------------------------------------------------------+
//|                                    SHI_SilverTrendColourBars.mq4 |
//|          Copyright © 2003, VIAC.RU, OlegVS, GOODMAN, 2005 Shurka |
//|                                                 shforex@narod.ru |
//|                                                                  |
//|                                                                  |
//| Пишу программы на заказ                                          |
//+------------------------------------------------------------------+
/*
   ВАЖНО!!! Для корректного отображения индикатора выключите в меню
   "Графики" ("Charts") пункт "График сверху" ("Foreground Chart")
   иначе бары будут отображаться поверх индикатора заслоняя их.
*/
#property copyright "Copyright © 2005, Shurka"
#property link      "http://shforex.narod.ru"

#property indicator_chart_window
#property indicator_buffers 2
#property indicator_color1 Blue
#property indicator_color2 Red
//---- Входные параметры
extern int     AllBars=0;//Для скольки баров считать. 0 - для всех.
extern int     Otstup=30;//Отступ.
extern double  Per=9;//Период.
int            SH,NB;
double         SHMax,SHMin;
double         BufD[];
double         BufU[];
//+------------------------------------------------------------------+
//| Функция инициализации                                            |
//+------------------------------------------------------------------+
int init()
{
   //В NB записываем количество баров для которых считаем индикатор
   if (Bars<AllBars+Per || AllBars==0) NB=Bars-Per; else NB=AllBars;
   IndicatorBuffers(2);
   IndicatorShortName("SHI_SilverTrendColourBars");
   SetIndexStyle(0,DRAW_HISTOGRAM,0,1);
   SetIndexStyle(1,DRAW_HISTOGRAM,0,1);
   SetIndexBuffer(0,BufU);
   SetIndexBuffer(1,BufD);
   SetIndexDrawBegin(0,Bars-NB);//Индикатор будетотображаться только для NB баров
   SetIndexDrawBegin(1,Bars-NB);
   ArrayInitialize(BufD,0.0);//Забьём оба буфера ноликами. Иначе будет мусор при смене таймфрейма.
   ArrayInitialize(BufU,0.0);
   return(0);
}
//+------------------------------------------------------------------+
//| Функция деинициализации                                          |
//+------------------------------------------------------------------+
int deinit()
{
   return(0);
}
//+------------------------------------------------------------------+
//| Собсна индикатор                                                 |
//+------------------------------------------------------------------+
int start()
{
   int CB=IndicatorCounted();
   /* Тут вот та самая оптимизационная фишка. В язык введена функция, которая возвращает количество
   посчитанных баров, причём очень хитро. При первом вызове индикатора это 0, всё понятно, ещё ничего
   не считалось, а затем выдаёт количество обсчитанных баров минус один. Т.е. если всего баров 100,
   то функция вернёт 99. Я ввёл такой код, выше у меня определялась NB - кол-во баров подлежащих
   обсчёту. В принципе этот параметр можно и выкинуть, однако для тех кто в танке (I80286) можно
   и оставить. Так вот, здесь, при первом вызове NB остаётся прежней, а при последующих уменьшается
   до последнего бара, т.е. 1 или 2, ну или сколько там осталось посчитать*/
   if(CB<0) return(-1); else if(NB>Bars-CB) NB=Bars-CB;
   for (SH=0;SH<NB;SH++)//Прочёсываем график от 0 до NB
   {
      SHMax = High[Highest(NULL,0,MODE_HIGH,Per,SH)];
      SHMin = Low[Lowest(NULL,0,MODE_LOW,Per,SH)];
      if (Close[SH]<SHMin+(SHMax-SHMin)*Otstup/100) {BufU[SH]=High[SH]; BufD[SH]=Low[SH];}
      if (Close[SH]>SHMax-(SHMax-SHMin)*Otstup/100) {BufD[SH]=High[SH]; BufU[SH]=Low[SH];}
   }
   return(0);
}