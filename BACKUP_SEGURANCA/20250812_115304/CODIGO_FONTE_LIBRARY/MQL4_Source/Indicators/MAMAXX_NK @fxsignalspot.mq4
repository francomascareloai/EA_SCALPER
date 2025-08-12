
/*
Version  November 28, 2007

Для  работы  индикатора  следует  положить файлы 
PriceSeries.mqh 
в папку (директорию): MetaTrader\experts\include\
MAMA_NK.mq4
Heiken Ashi#.mq4
в папку (директорию): MetaTrader\indicators\
*/
//+X================================================================X+
//|                                                    MAMAXX_NK.mq4 |
//|                    MAMA skript:                      John Ehlers |
//|                    MQL4 CODE: Copyright © 2007, Nikolay Kositsin | 
//|                              Khabarovsk,   farria@mail.redcom.ru | 
//+X================================================================X+
#property link  "farria@mail.redcom.ru/"
//---- отрисовка индикатора в главном окне
#property indicator_chart_window 
//---- количество индикаторных буферов
#property indicator_buffers 2 
//---- цвета индикатора
#property indicator_color1 Blue
#property indicator_color2 Red
//---- толщина индикаторных линий
#property indicator_width1 1
#property indicator_width2 1
//---- ВХОДНЫЕ ПАРАМЕТРЫ ИНДИКАТОРА 
extern double FastLimit = 0.2;
extern double SlowLimit = 0.05;
extern int IPC = 4;/* Выбор цен, по которым производится расчёт индикатора 
(0-CLOSE, 1-OPEN, 2-HIGH, 3-LOW, 4-MEDIAN, 5-TYPICAL, 6-WEIGHTED, 
7-Heiken Ashi Close, 8-SIMPL, 9-TRENDFOLLOW, 10-0.5*TRENDFOLLOW, 
11-Heiken Ashi Low, 12-Heiken Ashi High, 13-Heiken Ashi Open, 
14-Heiken Ashi Close, 15-Heiken Ashi Open0.) */
//---- индикаторные буфферы
double FAMA[];
double MAMA[];
//+X================================================================X+
//| Объявление функции PriceSeries                                   |
//| Объявление функции PriceSeriesAlert                              | 
//+X================================================================X+
#include <PriceSeries.mqh>
//+X================================================================X+
//| MAMAXX initialization function                                   |
//+X================================================================X+
int init()
//----+
  {
//---- Стиль исполнения графика
    SetIndexStyle(0, DRAW_LINE);
    SetIndexStyle(1, DRAW_LINE);
//---- 2 индикаторных буффера использованы для счёта
    SetIndexBuffer(0, FAMA);                                     
    SetIndexBuffer(1, MAMA);
//---- установка значений индикатора, которые не будут видимы на графике
    SetIndexEmptyValue(0,0.0);
    SetIndexEmptyValue(1,0.0);
//---- имя для окон данных и лэйба для субъокон
    IndicatorShortName("#MAMAXX");
    SetIndexLabel(0, "#FAMAXX");
    SetIndexLabel(1, "#MAMAXX");
//---- установка номера бара, 
                  //начиная с которого будет отрисовываться индикатор 
    SetIndexDrawBegin(0, 50);
    SetIndexDrawBegin(1, 50);
//---- установка алертов на недопустимые значения входных параметров
    PriceSeriesAlert(IPC);
//---- завершение инициализации
    return(0);
  }
//----+
//+X================================================================X+
//|    MAMAXX iteration function                                     |
//+X================================================================X+
int start()
//----+
  {
    int BARS=Bars;    
    //---- проверка количества баров на достаточность для расчёта
    if(BARS <= 7) 
            return(0);
    //----+ Введение целых переменных и получение уже посчитанных баров
    int MaxBar, limit, bar, counted_bars=IndicatorCounted();
    //---- проверка на возможные ошибки
    if (counted_bars<0)
                   return(-1);
    //---- последний посчитанный бар должен быть пересчитан
    if (counted_bars>0) 
                  counted_bars--;
    //----+ Введение переменных с плавающей точкой
    double  alpha; 
    //---- определение номера самого старого бара, 
             //начиная с которого будет произведён полный пересчёт всех баров 
    MaxBar=BARS-1-7;
    //---- определение номера самого старого бара, 
             //начиная с которого будет произедён пересчёт только новых баров 
    limit = BARS - 1 - counted_bars;
    //---- инициализация нуля
    if(limit>=MaxBar)
     {
       for(bar = BARS - 1; bar > MaxBar; bar--) 
         {
           MAMA[bar] = 0.0;
           FAMA[bar] = 0.0;
           limit = MaxBar;
         }
     }
    //----
    for (bar=limit;bar>=0;bar--)
      {
        alpha = FastLimit;
        if (alpha < SlowLimit)
                      alpha = SlowLimit;
        //---+
        MAMA[bar] = alpha*PriceSeries(IPC, bar) 
                          + (1.0 - alpha)*MAMA[bar+1];
        FAMA[bar] = 0.5*alpha*MAMA[bar] 
                        + (1.0 - 0.5*alpha)*FAMA[bar+1];    
      }
    return(0);
  }
//----+
//+X================================================================X+

