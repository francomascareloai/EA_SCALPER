//+------------------------------------------------------------------+
//| СПЕЦИФИЧЕСКИЕ ПАРАМЕТРЫ
//+------------------------------------------------------------------+
#property copyright "";          //Авторство
#property indicator_chart_window //Вывод индикатора в окне графика
#property indicator_buffers 5    //Количество буферов для расчетов индикатора
//+------------------------------------------------------------------+
//| СПЕЦИФИЧЕСКИЕ ПАРАМЕТРЫ
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| КАСТОМНЫЕ ПЕРЕЧИСЛЕНИЯ
//+------------------------------------------------------------------+
//Перчисление констант для типа цен
enum PriceTypeInt
  {
   PRICE_CLOSE_1    = 0, //Цена закрытия
   PRICE_OPEN_1     = 1, //Цена открытия
   PRICE_HIGH_1     = 2, //Максимальная за период цена
   PRICE_LOW_1      = 3, //Минимальная за период цена
   PRICE_MEDIAN_1   = 4, //Медианная цена, (high+low)/2
   PRICE_TYPICAL_1  = 5, //Типичная цена, (high+low+close)/3
   PRICE_WEIGHTED_1 = 6  //Взвешенная цена закрытия, (high+low+close+close)/4
  };
///Перечисление констант вместо true/false
enum BoolInt
  {
   Yes = 0, //Да
   No  = 1  //Нет
  };
//Перечисление констант для стиля линий
enum StyleLineInt
  {
   STYLE_SOLID_1      = 0, //Сплошная линия
   STYLE_DASH_1       = 1, //Штриховая линия
   STYLE_DOT_1        = 2, //Пунктирная линия
   STYLE_DASHDOT_1    = 3, //Штрих-пунктирная линия
   STYLE_DASHDOTDOT_1 = 4  //Штрих-пунктирная линия с двойными точками
};
//Перечисления констант для символов
enum StyleArrowInt {
   STYLE_ARROW_1  = 217, //Символ - стрелка фрактала вверх
   STYLE_ARROW_2  = 218, //Символ - стрелка фрактала вниз
   STYLE_ARROW_3  = 221, //Символ - стрелка в круге вверх
   STYLE_ARROW_4  = 222, //Символ - стрелка в круге вниз
   STYLE_ARROW_5  = 221, //Символ - тонкая стрелка вверх
   STYLE_ARROW_6  = 222, //Символ - тонкая стрелка вниз
   STYLE_ARROW_7  = 233, //Символ - толстая стрелка вверх
   STYLE_ARROW_8  = 234, //Символ - толстая стрелка вниз
   STYLE_ARROW_9  = 83,  //Символ - капля
   STYLE_ARROW_10 = 84,  //Символ - снежинка
   STYLE_ARROW_11 = 251, //Символ - крестик
   STYLE_ARROW_12 = 252, //Символ - галочка
   STYLE_ARROW_13 = 89,  //Символ - пинтограмма
   STYLE_ARROW_14 = 91,  //Символ - иньянь
   STYLE_ARROW_15 = 161, //Символ - круг
   STYLE_ARROW_16 = 164, //Символ - круг с точкой
   STYLE_ARROW_17 = 108, //Символ - большая точка
   STYLE_ARROW_18 = 159, //Символ - маленькая точка
   STYLE_ARROW_19 = 110, //Символ - большой квадрат
   STYLE_ARROW_20 = 167, //Символ - маленький квадрат
   STYLE_ARROW_21 = 117, //Символ - большой ромб
   STYLE_ARROW_22 = 119, //Символ - маленький ромб
   STYLE_ARROW_23 = 171, //Символ - звезда
   STYLE_ARROW_24 = 181  //Символ - звезда в круге
  };
//+------------------------------------------------------------------+
//| КАСТОМНЫЕ ПЕРЕЧИСЛЕНИЯ
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| ВХОДНЫЕ НАСТРОЙКИ
//+------------------------------------------------------------------+
extern ENUM_TIMEFRAMES TimeFrame       = PERIOD_CURRENT;                     //Таймфрейм для построения канала
extern int             HalfLength      = 55;                                 //Период
extern PriceTypeInt    Price           = PRICE_WEIGHTED_1;                   //Тип цены
extern double          BandsDeviations = 2.2;                              //Расширение канала
extern BoolInt         Interpolate     = No;                                 //Сглаживание канала
extern int             History         = 750;                                //Ограничение истории в барах
extern BoolInt         alertsOn        = No;                                 //Разрешить оповещения
extern BoolInt         alertsOnCurrent = No;                                 //Оповещения "Да" - на текущем баре "Нет" - на предыдущем
extern BoolInt         alertsOnHighLow = No;                                 //Оповещения пробития канала "Да" - High/Low "Нет" - Close
extern BoolInt         alertsMessage   = No;                                 //Оповещение в терминале
extern BoolInt         alertsPush      = No;                                 //Оповещение Push
extern BoolInt         alertsEmail     = No;                                 //Оповещение на электронную почту
extern string          ChannelSetting  = "Настройки автопостроения канала";  //Настройки автопостроения канала
extern BoolInt         UseAutoChannel  = No;                                 //Использование автоматических настроек канала
extern ENUM_TIMEFRAMES TimeM1          = PERIOD_M5;                          //Таймфрейм для построения канала на графике M1
extern ENUM_TIMEFRAMES TimeM5          = PERIOD_M30;                         //Таймфрейм для построения канала на графике M5
extern ENUM_TIMEFRAMES TimeM15         = PERIOD_H1;                          //Таймфрейм для построения канала на графике M15
extern ENUM_TIMEFRAMES TimeM30         = PERIOD_H4;                          //Таймфрейм для построения канала на графике M30
extern ENUM_TIMEFRAMES TimeH1          = PERIOD_H4;                          //Таймфрейм для построения канала на графике H1
extern ENUM_TIMEFRAMES TimeH4          = PERIOD_D1;                          //Таймфрейм для построения канала на графике H4
extern ENUM_TIMEFRAMES TimeD1          = PERIOD_W1;                          //Таймфрейм для построения канала на графике D1
extern string          ChannelStyle    = "Настройки стиля канала и стрелок"; //Настройки стиля канала и стрелок
extern color           ColUpLine       = clrDimGray;                         //Цвет верхней линии канала
extern StyleLineInt    StyleUpLine     = STYLE_DOT_1;                        //Стиль верхней линии канала
extern int             WidthUpLine     = 1;                                  //Толщина верхней линии канала
extern color           ColMidLine      = clrMaroon;                          //Цвет средней линии канала
extern StyleLineInt    StyleMidLine    = STYLE_SOLID_1;                      //Стиль средней линии канала
extern int             WidthMidLine    = 1;                                  //Толщина средней линии канала
extern color           ColDnLine       = clrDarkBlue;                        //Цвет нижней линии канала
extern StyleLineInt    StyleDnLine     = STYLE_SOLID_1;                      //Стиль нижней линии канала
extern int             WidthDnLine     = 1;                                  //Толщина нижней линии канала
extern color           ColUpArrow      = clrBlue;                            //Цвет верхних символов
extern StyleArrowInt   StylUpArrow     = STYLE_ARROW_18;                     //Стиль верхних символов
extern int             WidthUpArrow    = 1;                                  //Толщина верхних символов
extern color           ColDnArrow      = clrRed;                             //Цвет нижних символов
extern StyleArrowInt   StylDnArrow     = STYLE_ARROW_18;                     //Стиль нижних символов
extern int             WidthDnArrow    = 1;                                  //Толщина нижних символов
//+------------------------------------------------------------------+
//| ВХОДНЫЕ НАСТРОЙКИ
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| ВНУТРЕННИЕ ГЛОБАЛЬНЫЕ ПЕРЕМЕННЫЕ
//+------------------------------------------------------------------+
double             Average[];
double             TopLine[];
double             LowerLine[];
double             MediumUp[];
double             MediumDn[];
double             UpArrow[];
double             DnArrow[];
double             time_alert[];
string             NameInd;
bool               Calc = false;
bool               NoCalc  = false;
ENUM_TIMEFRAMES    TF;
ENUM_APPLIED_PRICE price;
//+------------------------------------------------------------------+
//| ВНУТРЕННИЕ ГЛОБАЛЬНЫЕ ПЕРЕМЕННЫЕ
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| ПЕРВОНАЧАЛЬНАЯ ИНИЦИАЛИЗАЦИЯ
//+------------------------------------------------------------------+
int OnInit()
  {
   //Преобразование типа цен
   if(Price == PRICE_CLOSE_1)    price = 0;
   if(Price == PRICE_OPEN_1)     price = 1;
   if(Price == PRICE_HIGH_1)     price = 2;
   if(Price == PRICE_LOW_1)      price = 3;
   if(Price == PRICE_MEDIAN_1)   price = 4;
   if(Price == PRICE_TYPICAL_1)  price = 5;
   if(Price == PRICE_WEIGHTED_1) price = 6;
   //Определение расчетного таймфрема
   //если включен режим автонастройки канала
   if(UseAutoChannel == Yes)
     {
      if(_Period == PERIOD_M1)  TF = PERIOD_M5;
      if(_Period == PERIOD_M5)  TF = PERIOD_M30;
      if(_Period == PERIOD_M15) TF = PERIOD_H1;
      if(_Period == PERIOD_M30) TF = PERIOD_H4;
      if(_Period == PERIOD_H1)  TF = PERIOD_H4;
      if(_Period == PERIOD_H4)  TF = PERIOD_D1;
      if(_Period == PERIOD_D1)  TF = PERIOD_W1;
     }
   //иначе берем указаный таймфрем 
   else TF  = TimeFrame;
   //Страхуемся от нулевого значения периода
   HalfLength = MathMax(HalfLength,1);
   //Инициализация и настройка индикаторных буферов
   IndicatorBuffers(7);
   SetIndexBuffer(0,Average);
   SetIndexDrawBegin(0,HalfLength);
   SetIndexStyle(0,DRAW_LINE,StyleUpLine,WidthUpLine,ColUpLine);
   SetIndexBuffer(1,TopLine);
   SetIndexDrawBegin(1,HalfLength);
   SetIndexStyle(1,DRAW_LINE,StyleMidLine,WidthMidLine,ColMidLine);
   SetIndexBuffer(2,LowerLine);
   SetIndexDrawBegin(2,HalfLength);
   SetIndexStyle(2,DRAW_LINE,StyleDnLine,WidthDnLine,ColDnLine);
   SetIndexBuffer(3,DnArrow);
   SetIndexStyle(3,DRAW_ARROW,EMPTY,WidthUpArrow,ColDnArrow);
   SetIndexArrow(3,StylDnArrow);
   SetIndexBuffer(4,UpArrow);
   SetIndexStyle(4,DRAW_ARROW,EMPTY,WidthDnArrow,ColUpArrow);
   SetIndexArrow(4,StylUpArrow);
   SetIndexBuffer(5,MediumUp);
   SetIndexBuffer(6,MediumDn);
   //Включение флага для расчета главной функции
   if(ChannelSetting == "Calculate")
     {
      Calc = true;
      return(INIT_SUCCEEDED);
     }
   //Включение флага переопределения стартового бара для старшего таймфрейма
   if(ChannelSetting == "NoCalculate")
     {
      NoCalc = true;
      return(INIT_SUCCEEDED);
     }
   //Получаем имя индикатора
   NameInd = MQLInfoString(MQL_PROGRAM_NAME);
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
   int i, k, n, limit, forBar, Shift, timeBar;
   datetime TimeBar;
   double factor, ZeroBarUP, ZeroBarDN, PreviousBarUP, PreviousBarDN, ZeroH, PreviousH, ZeroL, PreviousL, Close0, Close1;
   //Определение стартового бара для расчета
   if(History != 0) limit = History;
   else limit = rates_total - 2;
   //Проверка флага переопределения стартового бара для старшего таймфрейма
   if(NoCalc)
     {
      Average[0] = limit;
      return(rates_total);
     }
   //Проверка флага для расчета главной функции
   if(Calc)
     {
      Calculate(limit);
      return(rates_total);
     }
   //Если расчетный таймфрем больше текущего периода, то переопределим стартовый бар
   if(TF > _Period) limit = MathMax(limit, MathMin(limit - 1, (int)iCustom(NULL,TF,NameInd,PERIOD_CURRENT,HalfLength,Price,BandsDeviations,Interpolate,
                                                                                       History,alertsOn,alertsOnCurrent,alertsOnHighLow,alertsMessage,
                                                                                       alertsPush,alertsEmail,"NoCalculate",UseAutoChannel,
                                                                                       TimeM1,TimeM5,TimeM15,TimeM30,TimeH1,TimeH4,TimeD1,0,0) * TF / _Period));
   //Цикл расчета индикатора
   for(i = limit; i >= 0; i--)
     {
      Shift = iBarShift(NULL,TF,Time[i]);
      TimeBar = iTime(NULL,TF,Shift);
      Average[i] = iCustom(NULL,TF,NameInd,PERIOD_CURRENT,HalfLength,Price,BandsDeviations,Interpolate,
                                                             History,alertsOn,alertsOnCurrent,alertsOnHighLow,alertsMessage,
                                                             alertsPush,alertsEmail,"Calculate",UseAutoChannel,
                                                             TimeM1,TimeM5,TimeM15,TimeM30,TimeH1,TimeH4,TimeD1,0,Shift);
      TopLine[i] = iCustom(NULL,TF,NameInd,PERIOD_CURRENT,HalfLength,Price,BandsDeviations,Interpolate,
                                                             History,alertsOn,alertsOnCurrent,alertsOnHighLow,alertsMessage,
                                                             alertsPush,alertsEmail,"Calculate",UseAutoChannel,
                                                             TimeM1,TimeM5,TimeM15,TimeM30,TimeH1,TimeH4,TimeD1,1,Shift);
      LowerLine[i] = iCustom(NULL,TF,NameInd,PERIOD_CURRENT,HalfLength,Price,BandsDeviations,Interpolate,
                                                             History,alertsOn,alertsOnCurrent,alertsOnHighLow,alertsMessage,
                                                             alertsPush,alertsEmail,"Calculate",UseAutoChannel,
                                                             TimeM1,TimeM5,TimeM15,TimeM30,TimeH1,TimeH4,TimeD1,2,Shift);
      UpArrow[i] = EMPTY_VALUE;
      DnArrow[i] = EMPTY_VALUE;
      //Расчитываем значение верхнего и нижнего символа по ATR
      if(High[i+1] > TopLine[i+1] && Close[i+1] > Open[i+1] && Close[i] < Open[i]) UpArrow[i] = High[i] + iATR(NULL,0,20,i);
      if(Low[i+1] < LowerLine[i+1] && Close[i+1] < Open[i+1] && Close[i] > Open[i]) DnArrow[i] = High[i] - iATR(NULL,0,20,i);
      //Если сглаживание канала разрешено
      if(Interpolate == Yes)
        {
         //Произведем расчет последнего бара с учетом весовых коэффициентов для сглаживания линий канала
         for(n = 1; i+n < limit && Time[i+n] >= TimeBar; n++) continue;
         factor = 1.0 / n;
         for(k = 1; k < n; k++)
           {
            Average[i+k] = k * factor * Average[i+n] + (1.0 - k * factor) * Average[i];
            TopLine[i+k] = k * factor * TopLine[i+n] + (1.0 - k * factor) * TopLine[i];
            LowerLine[i+k] = k * factor * LowerLine[i+n] + (1.0 - k * factor) * LowerLine[i];
           }
        }
     }
   //Определяем момент оповещений
   //Если оповещения разрешены
   if(alertsOn == Yes)
     {
      //Если оповещения на текущем баре разрешены, то берем текущий бар
      if(alertsOnCurrent == Yes) forBar = 0;
      //иначе предыдущий
      else forBar = 1;
      timeBar = iBarShift(NULL, 0, iTime(NULL, TF, forBar));
      ZeroBarUP = iCustom(NULL,TF,NameInd,PERIOD_CURRENT,HalfLength,Price,BandsDeviations,Interpolate,
                                                             History,alertsOn,alertsOnCurrent,alertsOnHighLow,alertsMessage,
                                                             alertsPush,alertsEmail,"Calculate",UseAutoChannel,
                                                             TimeM1,TimeM5,TimeM15,TimeM30,TimeH1,TimeH4,TimeD1,1,forBar);
      ZeroBarDN = iCustom(NULL,TF,NameInd,PERIOD_CURRENT,HalfLength,Price,BandsDeviations,Interpolate,
                                                             History,alertsOn,alertsOnCurrent,alertsOnHighLow,alertsMessage,
                                                             alertsPush,alertsEmail,"Calculate",UseAutoChannel,
                                                             TimeM1,TimeM5,TimeM15,TimeM30,TimeH1,TimeH4,TimeD1,2,forBar);
      PreviousBarUP = iCustom(NULL,TF,NameInd,PERIOD_CURRENT,HalfLength,Price,BandsDeviations,Interpolate,
                                                             History,alertsOn,alertsOnCurrent,alertsOnHighLow,alertsMessage,
                                                             alertsPush,alertsEmail,"Calculate",UseAutoChannel,
                                                             TimeM1,TimeM5,TimeM15,TimeM30,TimeH1,TimeH4,TimeD1,1,forBar+1);
      PreviousBarDN = iCustom(NULL,TF,NameInd,PERIOD_CURRENT,HalfLength,Price,BandsDeviations,Interpolate,
                                                             History,alertsOn,alertsOnCurrent,alertsOnHighLow,alertsMessage,
                                                             alertsPush,alertsEmail,"Calculate",UseAutoChannel,
                                                             TimeM1,TimeM5,TimeM15,TimeM30,TimeH1,TimeH4,TimeD1,2,forBar+1);
      //Если оповещения пробития границ канала разрешены
      if(alertsOnHighLow == Yes)
        {
         ZeroH = iHigh(NULL, TF, forBar);
         PreviousH = iHigh(NULL, TF, forBar+1);
         ZeroL = iLow(NULL, TF, forBar);
         PreviousL = iLow(NULL, TF, forBar+1);
         if(ZeroH > ZeroBarUP && PreviousH < PreviousBarUP) doAlert(timeBar, "Пробитие верхней границы канала");
         if(ZeroL < ZeroBarDN && PreviousL > PreviousBarDN) doAlert(timeBar, "Пробитие нижней границы канала");
        }
      //иначе
      else
        {
         Close0 = iClose(NULL, TF, forBar);
         Close1 = iClose(NULL, TF, forBar+1);
         if(Close0 > ZeroBarUP && Close1 < PreviousBarUP) doAlert(timeBar, "Закрытие свечи выше верхней границы канала");
         if(Close0 < ZeroBarDN && Close1 > PreviousBarDN) doAlert(timeBar, "Закрытие свечи ниже нижней границы канала");
        }
     }
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| ТЕЛО ИНДИКАТОРА
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| ГЛАВНАЯ ФУНКЦИЯ РАСЧЕТА
//+------------------------------------------------------------------+
void Calculate(int limit)
  {
   //Объявление внутренних переменных
   int i, j, k;
   double FullLength = 2 * HalfLength + 1;
   double sum, sumw, diff;
   //Цикл расчета
   for(i = limit; i >= 0; i--)
     {
      //Расчет средней линии канала
      sum  = (HalfLength + 1) * iMA(NULL,0,1,0,MODE_SMA,price,i);
      sumw = (HalfLength + 1);
      for(j = 1, k = HalfLength; j <= HalfLength; j++, k--)
        {
         sum  += k * iMA(NULL,0,1,0,MODE_SMA,price,i+j);
         sumw += k;
         if(j <= i)
           {
            sum  += k * iMA(NULL,0,1,0,MODE_SMA,price,i-j);
            sumw += k;
           }
        }
      Average[i] = sum / sumw;
      //Расчет верхней и нижней линий канала
      diff = iMA(NULL,0,1,0,MODE_SMA,price,i) - Average[i];
      if(i > (limit - HalfLength - 1)) continue;
      if(i == (limit - HalfLength - 1))
        {
         TopLine[i] = Average[i];
         LowerLine[i] = Average[i];
         if(diff >= 0)
           {
            MediumUp[i] = MathPow(diff, 2);
            MediumDn[i] = 0;
           }
         else
           {
            MediumDn[i] = MathPow(diff, 2);
            MediumUp[i] = 0;
           }
         continue;
        }
      if(diff >= 0)
        {
         MediumUp[i] = (MediumUp[i+1] * (FullLength - 1) + MathPow(diff, 2)) / FullLength;
         MediumDn[i] =  MediumDn[i+1] * (FullLength - 1) / FullLength;
        }
      else
        {
         MediumDn[i] = (MediumDn[i+1] * (FullLength - 1) + MathPow(diff, 2)) / FullLength;
         MediumUp[i] =  MediumUp[i+1] * (FullLength - 1) / FullLength;
        }
      TopLine[i] = Average[i] + BandsDeviations * MathSqrt(MediumUp[i]);
      LowerLine[i] = Average[i] - BandsDeviations * MathSqrt(MediumDn[i]);
     }
  }
//+------------------------------------------------------------------+
//| ГЛАВНАЯ ФУНКЦИЯ РАСЧЕТА
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| ФУНКЦИЯ ОПОВЕЩЕНИЯ
//+------------------------------------------------------------------+
void doAlert(int forBar, string doWhat)
  {
   static string   previousAlert = "";
   static datetime previousTime;
   string message;

   if(previousAlert != doWhat || previousTime != Time[forBar])
     {
      previousAlert = doWhat;
      previousTime  = Time[forBar];
      message = StringConcatenate(_Symbol," в ",TimeToStr(TimeLocal(),TIME_SECONDS)," ",NameInd," : ",doWhat);
      if(alertsMessage == Yes) Alert(message);
      if(alertsEmail == Yes) SendMail(StringConcatenate(_Symbol,NameInd," "),message);
      if(alertsPush == Yes) SendNotification(message);
     }
  }
//+------------------------------------------------------------------+
//| ФУНКЦИЯ ОПОВЕЩЕНИЯ
//+------------------------------------------------------------------+