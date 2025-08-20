//+------------------------------------------------------------------+
//| СПЕЦИФИЧЕСКИЕ ПАРАМЕТРЫ
//+------------------------------------------------------------------+
#property copyright "";          //Авторство
#property link "";               //Сылка на сайт разработчика
#property version "";            //Версия индикатора
#property description "";        //Описание индикатора
#property strict                 //Строгий режим компиляции
#property indicator_chart_window //Вывод индикатора в окне графика
#property indicator_buffers 2    //Количество буферов для расчетов индикатора
//+------------------------------------------------------------------+
//| СПЕЦИФИЧЕСКИЕ ПАРАМЕТРЫ
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| ВХОДНЫЕ НАСТРОЙКИ
//+------------------------------------------------------------------+
extern ENUM_TIMEFRAMES TimeFrame = PERIOD_CURRENT; //Таймфрейм для построения облаков
extern color           SellZone  = clrLightSalmon; //Цвет облака на продажу
extern color           BuyZone   = clrDeepSkyBlue; //Цвет облака на покупку
extern int             OverSize  = 1;              //Толщина линий в облаке
extern int             History   = 750;            //Ограничение истории в барах
//+------------------------------------------------------------------+
//| ВХОДНЫЕ НАСТРОЙКИ
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| ВНУТРЕННИЕ ГЛОБАЛЬНЫЕ ПЕРЕМЕННЫЕ
//+------------------------------------------------------------------+
double sellZone[];
double buyZone[];
double fastUpp[];
double fastMid[];
double fastLow[];
double slowUpp[];
double slowMid[];
double slowLow[];
//+------------------------------------------------------------------+
//| ВНУТРЕННИЕ ГЛОБАЛЬНЫЕ ПЕРЕМЕННЫЕ
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| ПЕРВОНАЧАЛЬНАЯ ИНИЦИАЛИЗАЦИЯ
//+------------------------------------------------------------------+
int OnInit()
  {
   //Страхуемся от показа расчетов с меньшего таймфрейма
   if(TimeFrame <= _Period) TimeFrame = (ENUM_TIMEFRAMES)_Period;
   //Инициализация и настройка индикаторных буферов
   IndicatorBuffers(8);
   SetIndexBuffer(0, sellZone);
   SetIndexBuffer(1, buyZone);
   SetIndexBuffer(2, fastUpp);
   SetIndexBuffer(3, fastMid);
   SetIndexBuffer(4, fastLow);
   SetIndexBuffer(5, slowUpp);
   SetIndexBuffer(6, slowMid);
   SetIndexBuffer(7, slowLow);
   SetIndexStyle(0, DRAW_HISTOGRAM, 0, OverSize, SellZone);
   SetIndexStyle(1, DRAW_HISTOGRAM, 0, OverSize, BuyZone);
   SetIndexLabel(0, "sellZone");
   SetIndexLabel(1, "buyZone");

   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| ПЕРВОНАЧАЛЬНАЯ ИНИЦИАЛИЗАЦИЯ
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| ТЕЛО ИНДИКАТОРА
//+------------------------------------------------------------------+
int OnCalculate(const int        rates_total,     //Количество баров на текущем тике
                const int        prev_calculated, //Количество закрытых баров 
                const datetime   &time[],         //Массив времени каждого бара в истории
                const double     &open[],         //Массив цен открытия каждого бара в истории
                const double     &high[],         //Массив максимумов каждого бара в истории
                const double     &low[],          //Массив минимумов каждого бара в истории
                const double     &close[],        //Массив цен закрытия каждого бара в истории
                const long       &tick_volume[],  //Массив объема в тиках каждого бара в истории
                const long       &volume[],       //Массив реального объема каждого бара в истории
                const int        &spread[])       //Массив спреда каждого бара в истории
  {
   //Объявление внутренних переменных
   int i, limit;
   //Определение стартового бара для расчета
   if(History == 0 || prev_calculated >= History) limit = MathMin(rates_total - 1, rates_total - prev_calculated);
   else limit = History;
   //Цикл расчета индикатора
   for(i = limit; i >= 0; i--)
     {
      fastMid[i] = iMA(NULL,TimeFrame,22,0,3,0,iBarShift(NULL,TimeFrame,Time[i],false));
      fastUpp[i] = (1.3 * iATR(NULL,TimeFrame,999,(iBarShift(NULL,TimeFrame,Time[i], false) + 1))) + fastMid[i];
      fastLow[i] = fastMid[i] - (1.3 * iATR(NULL,TimeFrame,999,(iBarShift(NULL,TimeFrame,Time[i], false) + 1)));
      slowMid[i] = iMA(NULL,TimeFrame,233,0,3,0,iBarShift(NULL,TimeFrame,Time[i],false));
      slowUpp[i] = (4 * iATR(NULL,TimeFrame,999,(iBarShift(NULL,TimeFrame,Time[i], false) + 1))) + slowMid[i];
      slowLow[i] = slowMid[i] - (4 * iATR(NULL,TimeFrame,999,(iBarShift(NULL,TimeFrame,Time[i], false) + 1)));
      if(SellZone != clrNONE && fastUpp[i] > slowUpp[i])
        {
         sellZone[i] = fastUpp[i];
         buyZone[i] = slowUpp[i];
        }
      if(BuyZone != clrNONE && fastLow[i] < slowLow[i])
        {
         buyZone[i] = slowLow[i];
         sellZone[i] = fastLow[i];
        }
     }
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| ТЕЛО ИНДИКАТОРА
//+------------------------------------------------------------------+