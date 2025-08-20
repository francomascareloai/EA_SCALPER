/*
Для  работы  индикатора  следует  положить файлы 
JJMASeries.mqh
JurSeries.mqh 
PriceSeries.mqh 
в папку (директорию): MetaTrader\experts\include\
Heiken Ashi#.mq4
в папку (директорию): MetaTrader\indicators\
*/
//+------------------------------------------------------------------+ 
//|                                                        JCCIX.mq4 |
//|                              Copyright © 2006,  Nikolay Kositsin | 
//|                              Khabarovsk,   farria@mail.redcom.ru | 
//+------------------------------------------------------------------+  
#property copyright "Copyright © 2006, Nikolay Kositsin"
#property link "farria@mail.redcom.ru" 
//---- отрисовка индикатора в отдельном окне
#property indicator_separate_window
//---- количество индикаторных буферов
#property indicator_buffers  1
//---- цвета индикатора
#property indicator_color1  BlueViolet
//---- параметры горизонтальных уровней индикатора
#property indicator_level1  0.5
#property indicator_level2 -0.5
#property indicator_level3  0.0
#property indicator_levelcolor MediumBlue
#property indicator_levelstyle 4
//---- ВХОДНЫЕ ПАРАМЕТРЫ ИНДИКАТОРА --------------------------------------------------------------------------------------------------+
extern int  JJMA_Length = 8;  // глубина JJMA сглаживания входной цены
extern int  JurX_Length = 8;  // глубина JurX сглаживания полученного индикатора 
extern int  JJMA_Phase = 100; // параметр, изменяющийся в пределах -100 ... +100, влияет на качество переходныx процессов сглаживания
extern int Input_Price_Customs = 0;/* Выбор цен, по которым производится расчёт индикатора 
(0-CLOSE, 1-OPEN, 2-HIGH, 3-LOW, 4-MEDIAN, 5-TYPICAL, 6-WEIGHTED, 7-Heiken Ashi Close, 8-SIMPL, 9-TRENDFOLLOW, 10-0.5*TRENDFOLLOW,
11-Heiken Ashi Low, 12-Heiken Ashi High,  13-Heiken Ashi Open, 14-Heiken Ashi Close.) */
//---- -------------------------------------------------------------------------------------------------------------------------------+
//---- индикаторные буферы
double Ind_Buffer1[];
//---- целые константы 
int    w;
//+------------------------------------------------------------------+  
//----+ Введение функции JJMASeries 
//----+ Введение функции JJMASeriesResize 
//----+ Введение функции JJMASeriesAlert  
//----+ Введение функции JMA_ErrDescr  
#include <JJMASeries.mqh> 
//+------------------------------------------------------------------+ 
//----+ Введение функции JurXSeries
//----+ Введение функции JurXSeriesResize
//----+ Введение функции JurXSeriesAlert 
//----+ Введение функции JurX_ErrDescr  
#include <JurXSeries.mqh> 
//+------------------------------------------------------------------+  
//----+ Введение функции PriceSeries
//----+ Введение функции PriceSeriesAlert 
#include <PriceSeries.mqh>
//+------------------------------------------------------------------+ 
//| JCCIX initialization function                                    |
//+------------------------------------------------------------------+ 
int init()
 {
//---- стили изображения индикатора
   SetIndexStyle(0,DRAW_LINE);
//---- 1 индикаторный буфер использован для счёта. 
   SetIndexBuffer(0,Ind_Buffer1);
//---- установка значений индикатора, которые не будут видимы на графике
   SetIndexEmptyValue(0,0); 
//---- имена для окон данных и лэйбы для субъокон
   SetIndexLabel(0,"JCCIX");
   IndicatorShortName("JCCIX(JJMA_Length="+JJMA_Length+", JurX_Length"+JurX_Length+")");
//---- Установка формата точности (количество знаков после десятичной точки) для визуализации значений индикатора  
   IndicatorDigits(2);
//----+ Изменение размеров буферных переменных функции JurXSeries, nJurXnumber=2(Два обращения к функции JurXSeries)
   if (JurXSeriesResize(2)!=2)return(-1);
//----+ Изменение размеров буферных переменных функции JJMASeries, nJMAnumber=1(Одно обращение к функции JJMASeries)
   if (JJMASeriesResize(1)!=1)return(-1);
//---- установка алертов на недопустимые значения внешних переменных
   JurXSeriesAlert (0,"JurX_Length",JurX_Length);
   JJMASeriesAlert (0,"JJMA_Length",JJMA_Length);
   JJMASeriesAlert (1,"JJMA_Phase",JJMA_Phase);
   PriceSeriesAlert(Input_Price_Customs);
//---- установка номера бара, начиная с которого будет отрисовываться индикатор  
   SetIndexDrawBegin(0,JurX_Length+31);
//---- инициализация коэффициентов для расчёта индикатора 
   if (JurX_Length>5) w=JurX_Length-1; else w=5;
//---- завершение инициализации
   return(0);
  }
//+------------------------------------------------------------------+ 
//|  JCommodity Channel IndexX                                       |
//+------------------------------------------------------------------+ 
int start()
  {
//---- Введение переменных с плавающей точкой    
double price,Jprice,JCCIX,UPCCI,DNCCI,JUPCCIX,JDNCCIX; 
//----+ Введение целых переменных и получение уже подсчитанных баров
int reset,MaxBar,MaxBarJ,limit,counted_bars=IndicatorCounted();
//---- проверка на возможные ошибки
if (counted_bars<0)return(-1);
//---- последний подсчитанный бар должен быть пересчитан 
//---- (без этого пересчёта для counted_bars функции JJMASeries и JurXSeries будут работать некорректно!!!)
if (counted_bars>0) counted_bars--;
//---- определение номера самого старого бара, начиная с которого будет произедён пересчёт новых баров
limit=Bars-counted_bars-1; MaxBar=Bars-1; MaxBarJ=MaxBar-30;
//---- корекция стартового расчётого бара в цикле
if(limit>=MaxBar)limit=MaxBar;

for(int bar=limit; bar>=0; bar--)
 { 
   //----+ Обращение к функции PriceSeries для получения входной цены Series
   price=PriceSeries(Input_Price_Customs, bar);
   //+----------------------------------------------------------------------------+ 
   //----+ Одно обращение к функции JJMASeries за номерам 0. 
   //----+ Параметры nJMA.Phase и nJMA.Length не меняются на каждом баре (nJMA.din=0)
   //+----------------------------------------------------------------------------+   
   Jprice=JJMASeries(0,0,MaxBar,limit,JJMA_Phase,JJMA_Length,price,bar,reset);
   //----+ проверка на отсутствие ошибки в предыдущей операции
   if(reset!=0)return(-1);
   //+----------------------------------------------------------------------------+    
   UPCCI=price-Jprice;         
   DNCCI=MathAbs(UPCCI);
   //----+ Два обращения к функции JurXSeries за номерами 0 и 1. Параметр nJJurXLength не меняtтся на каждом баре (nJurXdin=0)
   //----+ проверка на отсутствие ошибки в предыдущей операции
   JUPCCIX=JurXSeries(0,0,MaxBarJ,limit,JurX_Length,UPCCI,bar,reset); if(reset!=0)return(-1); 
   JDNCCIX=JurXSeries(1,0,MaxBarJ,limit,JurX_Length,DNCCI,bar,reset); if(reset!=0)return(-1); 
   //----+
   if (bar>MaxBarJ-w)JCCIX=0;
   else 
     if (JDNCCIX!=0)
       {
        JCCIX=JUPCCIX/JDNCCIX;
        if(JCCIX>1)JCCIX=1;
        if(JCCIX<-1)JCCIX=-1;
       }
     else JCCIX=0;
   Ind_Buffer1[bar]=JCCIX; 
   //----+
 }
//----
   return(0);
  }
//+---------------------------------------------------------------------------+


