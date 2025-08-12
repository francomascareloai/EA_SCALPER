//+------------------------------------------------------------------+
//|                                                clusterbox_ad.mq4 |
//|                                        Copyright 2015, Scriptong |
//|                                          http://advancetools.net |
//+------------------------------------------------------------------+
#property copyright "Scriptong"
#property link      "http://advancetools.net"
#property description "English: Displays the ticks volume of candles in the form of clusters.\nRussian: Отображение тиковых объемов свечи в виде кластеров."
#property strict

#property indicator_chart_window
#property indicator_buffers 1

#define MAX_POINTS_IN_CANDLE 30000                                                                 // Приброска для свечей месячного графика пятизнака
#define MAX_TICKS_IN_CANDLE 1000000                                                                // Приброска для свечей месячного графика пятизнака
#define MAX_VOLUMES_SHOW      5                                                                    // Количество уровней максимального объема, которые следует отображать
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
struct LevelVolumeColor                                                                            // Структура соответствия уровней объема, достижение которых на ценовом уровне отображается.. 
  {                                                                                                 // ..соответствующим цветом
   color             levelColor;
   int               levelMinVolume;
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
struct TickStruct                                                                                  // Структура для записи данных об одном тике
  {
   datetime          time;
   double            bid;
   double            ask;
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
enum ENUM_YESNO
  {
   YES,                                                                                           // Yes / Да
   NO                                                                                             // No / Нет
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
enum ENUM_CHARTSCALE
  {
   SCALE_SMALLER,                                                                                  // Smallest / Наименьший
   SCALE_SMALL,                                                                                    // Small / Малый
   SCALE_MEDIUM,                                                                                   // Medium / Средний
   SCALE_BIG,                                                                                      // Big / Большой
   SCALE_BIGGEST,                                                                                  // Greater / Больший
   SCALE_LARGE                                                                                     // Biggest / Наибольший
  };

//--- Настроечные параметры индикатора
input int      i_pointsInBox           = 50;                                                       // Points in one cluster / Количество пунктов в одном кластере
input string   i_string1               = "Min volumes and colors / Мин. объемы и цвета";           // ==============================================
input int      i_minVolumeLevel1       = 1;                                                        // Minimal volume. Level 1 / Минимальный объем. Уровень 1
input color    i_colorLevel1           = clrSkyBlue;                                               // Color of level 1 / Цвет уровня 1
input int      i_minVolumeLevel2       = 250;                                                      // Minimal volume. Level 2 / Минимальный объем. Уровень 2
input color    i_colorLevel2           = clrTurquoise;                                             // Color of level 2 / Цвет уровня 2
input int      i_minVolumeLevel3       = 500;                                                      // Minimal volume. Level 3 / Минимальный объем. Уровень 3
input color    i_colorLevel3           = clrRoyalBlue;                                             // Color of level 3 / Цвет уровня 3
input int      i_minVolumeLevel4       = 1000;                                                     // Minimal volume. Level 4 / Минимальный объем. Уровень 4
input color    i_colorLevel4           = clrBlue;                                                  // Color of level 4 / Цвет уровня 4
input int      i_minVolumeLevel5       = 2000;                                                     // Minimal volume. Level 5 / Минимальный объем. Уровень 5
input color    i_colorLevel5           = clrMagenta;                                               // Color of level 5 / Цвет уровня 5
input string   i_string2               = "Параметры графика";                                      // ==============================================
input ENUM_YESNO i_useNeededScale      = YES;                                                      // Use the specific chart scale? / Задать масштаб графика?
input ENUM_CHARTSCALE i_chartScale     = SCALE_LARGE;                                              // Chart scale / Масштаб
input ENUM_YESNO i_showClusterGrid     = YES;                                                      // Display the cluster grid / Показывать сетку кластеров
input color    i_gridColor             = clrDarkGray;                                              // Color of clusters lines / Цвет линий кластеров

input int      i_indBarsCount=10000;                                                    // Number of bars to display / Кол-во баров отображения

//--- Прочие глобальные переменные индикатора
bool g_activate,                                                                              // Признак успешной инициализации индикатора
g_isShowInfo,                                                                                 // Признак необходимости отображения данных индикатора
g_chartForeground,                                                                            // Признак нахождения свечей на переднем плане
g_init;                                                                                       // Переменная для инициализации статических переменных внутри функций в момент проведения..
                                                                                              // ..повторной инициализации
int g_currentScale,// Масштаб графика действующий на момент присоединения индикатора
g_volumePriceArray[MAX_POINTS_IN_CANDLE];                                                      // Рабочий массив уровней, в который записывается количество тиков, которые попали на..
                                                                                               // ..соответствующую цену свечи. Количество заполненных элементов массива - высота свечи
double g_ticksPrice[MAX_TICKS_IN_CANDLE];                                                      // Массив для временного хранения набора тиков, приходящихся на одну свечу

double g_point,
g_tickSize;

TickStruct        g_ticks[];                                                                       // Массив для хранения тиков, поступивших после начала работы индикатора                    
LevelVolumeColor g_volumeLevelsColor[MAX_VOLUMES_SHOW];                                            // Массив объемов и, соответствующим им, цветов уровней

#define PREFIX                                  "CLSTRBX_"                                         // Префикс графических объектов, отображаемых индикатором 

#define SIGN_BUTTON                             "INFO_BUTTON_"                                     // Корень имени графического объекта "кнопка"
#define BUTTON_FONT_NAME                        "MS Sans Serif"                                    // Имя шрифта для отображения текста кнопки
#define BUTTON_TOOLTIP                          "Вкл/выкл отображение кластеров и сетки"           // Подсказка к назначению кнопки
#define BUTTON_XCOORD                           2                                                  // Х-координата левого верхнего угла кнопки
#define BUTTON_YCOORD                           14                                                 // Y-координата левого верхнего угла кнопки
#define BUTTON_WIDTH                            110                                                // Ширина кнопки
#define BUTTON_HEIGHT                           20                                                 // Высота кнопки
#define BUTTON_FONT_SIZE                        7                                                  // Размер шрифта для текста кнопки
#define BUTTON_TEXT_COLOR                       clrBlack                                           // Цвет шрифта текста в кнопке
#define BUTTON_BORDER_COLOR                     clrNONE                                            // Цвет границы кнопки
#define BUTTON_BACKGROUND_COLOR                 clrLightGray                                       // Цвет заливки кнопки

#define FONT_NAME                               "MS Sans Serif"
#define FONT_SIZE                               7
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
//| Custom indicator initialization function                                                                                                                                                          |
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
int OnInit()
  {
   g_activate=false;                                                                             // Индикатор не инициализирован
   g_init=true;

   if(!IsTuningParametersCorrect()) // Неверно указанные значения настроечных параметров - причина неудачной инициализации
      return INIT_FAILED;

   if(!IsLoadTempTicks()) // Загрузка данных о тиках, сохраненных за предыдущий период работы индикатора   
      return INIT_FAILED;

   CreateVolumeColorsArray();                                                                    // Копирование данных о цвете и величине уровней в массив
   SetChartView();                                                                               // Установка специфического вида графика

   g_activate=true;                                                                              // Индикатор успешно инициализирован

   return INIT_SUCCEEDED;
  }
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
//| Проверка корректности настроечных параметров                                                                                                                                                      |
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
bool IsTuningParametersCorrect()
  {
   string name=WindowExpertName();

   int period= Period();
   if(period == 0)
     {
      Alert(name,": фатальная ошибка терминала - период 0 минут. Индикатор отключен.");
      return (false);
     }

   g_point=Point;
   if(g_point==0)
     {
      Alert(name,": фатальная ошибка терминала - величина пункта равна нулю. Индикатор отключен.");
      return (false);
     }

   g_tickSize=MarketInfo(Symbol(),MODE_TICKSIZE);
   if(g_tickSize==0)
     {
      Alert(name,": фатальная ошибка терминала - величина шага одного тика равна нулю. Индикатор отключен.");
      return (false);
     }

   if(i_pointsInBox<1)
     {
      Alert(name,": количество пунктов в кластере должно быть положительным. Индикатор отключен.");
      return (false);
     }

   return (true);
  }
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
//| Чтение данных о тиках, накопленных в течение предыдущей рабочей сессии программы                                                                                                                  |
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
bool IsLoadTempTicks()
  {
//--- Открытие файла тиковой истории
   int hTicksFile=FileOpen(Symbol()+"temp.tks",FILE_BIN|FILE_READ|FILE_SHARE_READ|FILE_SHARE_WRITE);
   if(hTicksFile<1)
      return true;

//--- Распределение памяти для массива g_ticks
   int recSize=(int)(FileSize(hTicksFile)/sizeof(TickStruct));
   if(ArrayResize(g_ticks,recSize,1000)<0)
     {
      Alert(WindowExpertName(),": не удалось распределить память для подкачки данных из временного файла тиков. Индикатор отключен.");
      FileClose(hTicksFile);
      return false;
     }

//--- Чтение файла
   int i=0;
   while(i<recSize)
     {
      if(FileReadStruct(hTicksFile,g_ticks[i])==0)
        {
         Alert(WindowExpertName(),": ошибка чтения данных из временного файла. Индикатор отключен.");
         return false;
        }
      i++;
     }

   FileClose(hTicksFile);
   return true;
  }
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
//| Формирование массива значений объемов и соответствующих им цветам уровней                                                                                                                         |
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
void CreateVolumeColorsArray()
  {
   g_volumeLevelsColor[0].levelMinVolume = i_minVolumeLevel1;
   g_volumeLevelsColor[1].levelMinVolume = i_minVolumeLevel2;
   g_volumeLevelsColor[2].levelMinVolume = i_minVolumeLevel3;
   g_volumeLevelsColor[3].levelMinVolume = i_minVolumeLevel4;
   g_volumeLevelsColor[4].levelMinVolume = i_minVolumeLevel5;

   g_volumeLevelsColor[0].levelColor = i_colorLevel1;
   g_volumeLevelsColor[1].levelColor = i_colorLevel2;
   g_volumeLevelsColor[2].levelColor = i_colorLevel3;
   g_volumeLevelsColor[3].levelColor = i_colorLevel4;
   g_volumeLevelsColor[4].levelColor = i_colorLevel5;
  }
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
//| Установка нужного масштаба графика для работы индикатора                                                                                                                                          |
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
void SetChartView()
  {
//--- Положение свечного графика относительно прочей графики
   g_chartForeground=(bool)ChartGetInteger(0,CHART_FOREGROUND);
   ChartSetInteger(0,CHART_FOREGROUND,false);

   if(i_useNeededScale==NO)
      return;

//--- Масштаб графика
   g_currentScale=(int)ChartGetInteger(0,CHART_SCALE);
   ChartSetInteger(0,CHART_SCALE,(long)i_chartScale);
  }
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
//| Custom indicator deinitialization function                                                                                                                                                        |
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   if(!IsSavedFile())    // Если ни один из подключенных индикаторов не сохранил данные, то их сохранит текущий индикатор
      SaveTempTicks();   // Сохранение данных о тиках, накопленных за текущий период работы индикатора   
   DeleteAllObjects();
   RestoreChartView();
  }
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
//| Проверка наличия записанных данных другим индикатором                                                                                                                                             |
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
bool IsSavedFile()
  {
//--- Получение времени поступления последнего записанного тика
   int lastTickIndex=ArraySize(g_ticks)-1;
   if(lastTickIndex<0) // Ни один тик не был получен. Запись данных не требуется
      return true;

//--- Открытие файла тиковой истории
   int hTicksFile=FileOpen(Symbol()+"temp.tks",FILE_BIN|FILE_READ|FILE_SHARE_READ|FILE_SHARE_WRITE);
   if(hTicksFile<1)
      return false;

//--- Перемещение к последней записи в файле
   if(!FileSeek(hTicksFile,-sizeof(TickStruct),SEEK_END))
     {
      FileClose(hTicksFile);
      return false;
     }

//--- Чтение последней записи и закрытие файла
   TickStruct tick;
   uint readBytes=FileReadStruct(hTicksFile,tick);
   FileClose(hTicksFile);
   if(readBytes==0)
      return false;

//--- Сравнение даты тика, записанного в файле, и даты последнего поступившего тика
   return tick.time >= g_ticks[lastTickIndex].time;                                                // Дата/время последнего записанного в файле тика больше или равна дате/времени..
                                                                                                   // ..зарегистрированного тика. Значит, файл уже записан, и повторная запись не требуется
  }
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
//| Сохранение данных о тиках, накопленных за текущую рабочую сессию программы                                                                                                                        |
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
void SaveTempTicks()
  {
//--- Создание файла тиковой истории
   int hTicksFile=FileOpen(Symbol()+"temp.tks",FILE_BIN|FILE_READ|FILE_WRITE|FILE_SHARE_READ|FILE_SHARE_WRITE);
   if(hTicksFile<1)
      return;

//--- Запись файла
   int total=ArraySize(g_ticks),i=0;
   while(i<total)
     {
      if(FileWriteStruct(hTicksFile,g_ticks[i])==0)
        {
         Print("Ошибка сохранения данных во временный файл...");
         return;
        }
      i++;
     }

   FileClose(hTicksFile);
  }
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
//| Отображение кнопки вкл./выкл. визуализации показаний индикатора                                                                                                                                   |
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
void ShowInfoViewButton()
  {
   if(!g_init)
      return;

   g_isShowInfo=true;
   ShowButton(BUTTON_XCOORD,BUTTON_YCOORD,"Кластеры выкл.");
  }
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
//| Отображение графического объекта "Кнопка"                                                                                                                                                         |
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
void ShowButton(int x,int y,string text)
  {
   string name=PREFIX+SIGN_BUTTON+IntegerToString(x)+IntegerToString(y);

   if(ObjectFind(0,name)<0)
     {
      ObjectCreate(0,name,OBJ_BUTTON,0,0,0);

      ObjectSetInteger(0,name,OBJPROP_CORNER,0);
      ObjectSetInteger(0,name,OBJPROP_XDISTANCE,x);
      ObjectSetInteger(0,name,OBJPROP_YDISTANCE,y);

      ObjectSetInteger(0,name,OBJPROP_XSIZE,BUTTON_WIDTH);
      ObjectSetInteger(0,name,OBJPROP_YSIZE,BUTTON_HEIGHT);

      ObjectSetString(0,name,OBJPROP_TEXT,text);
      ObjectSetString(0,name,OBJPROP_FONT,BUTTON_FONT_NAME);
      ObjectSetString(0,name,OBJPROP_TOOLTIP,BUTTON_TOOLTIP);
      ObjectSetInteger(0,name,OBJPROP_FONTSIZE,BUTTON_FONT_SIZE);

      ObjectSetInteger(0,name,OBJPROP_COLOR,BUTTON_TEXT_COLOR);
      ObjectSetInteger(0,name,OBJPROP_BORDER_COLOR,BUTTON_BORDER_COLOR);
      ObjectSetInteger(0,name,OBJPROP_BGCOLOR,BUTTON_BACKGROUND_COLOR);

      ObjectSetInteger(0,name,OBJPROP_BACK,false);
      ObjectSetInteger(0,name,OBJPROP_HIDDEN,true);
      ObjectSetInteger(0,name,OBJPROP_SELECTABLE,false);
      return;
     }

   ObjectSetInteger(0,name,OBJPROP_XDISTANCE,x);
   ObjectSetInteger(0,name,OBJPROP_YDISTANCE,y);
   ObjectSetString(0,name,OBJPROP_TEXT,text);
  }
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
//| Удаление всех объектов, созданных программой                                                                                                                                                      |
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
void DeleteAllObjects()
  {
   for(int i=ObjectsTotal()-1; i>=0; i--)
      if(StringSubstr(ObjectName(i),0,StringLen(PREFIX))==PREFIX)
         ObjectDelete(ObjectName(i));

   g_init=true;
  }
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
//| Возвращение действующего масштаба графика                                                                                                                                                         |
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
void RestoreChartView()
  {
   ChartSetInteger(0,CHART_FOREGROUND,g_chartForeground);

   if(i_useNeededScale==NO)
      return;

   ChartSetInteger(0,CHART_SCALE,g_currentScale);
  }
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
//| Определение индекса бара, с которого необходимо производить перерасчет                                                                                                                            |
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
int GetRecalcIndex(int &total,const int ratesTotal,const int prevCalculated)
  {
//--- Определение первого бара истории, на котором будут доступны адекватные значения индикатора
   total=ratesTotal-1;

//--- А может значения индикатора не нужно отображать на всей истории?
   if(i_indBarsCount>0 && i_indBarsCount<total)
      total=MathMin(i_indBarsCount,total);

//--- Первое отображение индикатора или произошла подкачка данных, т. е. на предыдущем тике баров было не на один бар меньше, как при нормальном развитии истории, а на два или более баров меньше
   if(prevCalculated<ratesTotal-1)
     {
      DeleteAllObjects();
      return (total);
     }

//--- Нормальное развитие истории. Количество баров текущего тика отличается от количества баров предыдущего тика не больше, чем на один бар
   return (MathMin(ratesTotal - prevCalculated, total));
  }
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
//| Больше ли первое число, чем второе?                                                                                                                                                               |
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
bool IsFirstMoreThanSecond(double first,double second)
  {
   return (first - second > Point / 10);
  }
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
//| Равны ли числа?                                                                                                                                                                                   |
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
bool IsValuesEquals(double first,double second)
  {
   return (MathAbs(first - second) < Point / 10);
  }
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
//| Чтение одного тика из файла                                                                                                                                                                       |
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
bool IsReadTimeAndBidAskOfTick(int hTicksFile,TickStruct &tick)
  {
   if(FileIsEnding(hTicksFile))
     {
      FileClose(hTicksFile);
      return false;
     }

   uint bytesCnt=FileReadStruct(hTicksFile,tick);
   if(bytesCnt==sizeof(TickStruct))
      return true;

   FileClose(hTicksFile);
   return false;
  }
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
//| Приведение рыночной цены к цене кластера с учетом его высоты                                                                                                                                      |
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
double CastPriceToCluster(double price)
  {
   int priceInPoints=(int)MathRound(price/Point);
   int clusterPrice =(int)MathRound(priceInPoints/1.0/i_pointsInBox);
   return NormalizeDouble(clusterPrice * Point * i_pointsInBox, Digits);
  }
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
//| Считывание тиков, принадлежащих одной свече                                                                                                                                                       |
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
void ReadTicksFromFile(int hTicksFile,datetime limitTime,TickStruct &tick,int &ticksCount,bool &fileClose)
  {
   while(!fileClose)
     {
      fileClose=!IsReadTimeAndBidAskOfTick(hTicksFile,tick);
      if(tick.time>=limitTime || fileClose || tick.time==0)
         break;

      g_ticksPrice[ticksCount]=CastPriceToCluster(tick.bid);
      ticksCount++;
      if(ticksCount>MAX_TICKS_IN_CANDLE)
         break;
     }
  }
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
//| Распределение тиков по кластерам                                                                                                                                                                  |
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
void SortTicksByCluster(int ticksCount,int &arraySize)
  {
   arraySize=1;
   ArrayInitialize(g_volumePriceArray,0);
   g_volumePriceArray[0]=1;
   for(int i=1; i<ticksCount; i++)
     {
      if(!IsValuesEquals(g_ticksPrice[i-1],g_ticksPrice[i]))
        {
         arraySize+=(int)MathRound((g_ticksPrice[i]-g_ticksPrice[i-1])/g_tickSize);
         if(arraySize>MAX_POINTS_IN_CANDLE)
            break;
        }
      g_volumePriceArray[arraySize-1]++;
     }
  }
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
//| Чтение тиковых данных из буфера тиков                                                                                                                                                             |
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
void AddDataFromBuffer(datetime limitTime,TickStruct &tick,int &ticksCount)
  {
//--- Поиск в буфере тика, время которого больше последнего считанного тика
   int total=ArraySize(g_ticks),i=0;
   while(i<total && tick.time>=g_ticks[i].time)
      i++;

//--- Достигли конца буфера - уходим
   if(i>=total)
     {
      tick.time=0;                                                                               // Указание циклу while в функции ProcessOldCandles на то, что данные в буфере закончились
      return;
     }

//--- Перезапись данных из одного буфера в другой
   while(i<total && g_ticks[i].time<limitTime)
     {
      g_ticksPrice[ticksCount]=CastPriceToCluster(g_ticks[i].bid);
      ticksCount++;
      i++;
     }

//--- Сохранение данных о тике следующего бара
   if(i<total)
      tick=g_ticks[i];
   else
      tick.time=0;                                                                               // Указание циклу while в функции ProcessOldCandles на то, что данные в буфере закончились
  }
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
//| Подготовка данных для одного бара                                                                                                                                                                 |
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
void FormDataForOneBar(int hTicksFile,datetime limitTime,TickStruct &tick,double &lowPrice,int &arraySize,bool &fileClose)
  {
//--- Считывание тиков, принадлежащих одной свече
   int ticksCount=1;
   g_ticksPrice[0]=CastPriceToCluster(tick.bid);
   if(!fileClose)
      ReadTicksFromFile(hTicksFile,limitTime,tick,ticksCount,fileClose);

   if(fileClose) // Это не ошибка - else не нужен, т. к. после выполнения ReadTicksFromFile может измениться fileClose
      AddDataFromBuffer(limitTime,tick,ticksCount);

//--- Сортировка массива в порядке возрастания. После нее нулевой элемент содержит минимум свечи, а элемент [ticksCount - 1] - максимум
   ArraySort(g_ticksPrice,ticksCount);
   lowPrice=g_ticksPrice[0];

//--- Распределение тиков по кластерам
   SortTicksByCluster(ticksCount,arraySize);
  }
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
//| Отображение горизонтальной линии                                                                                                                                                                  |
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
void ShowHLine(double price,color clr)
  {
   string name=PREFIX+"HLINE_"+IntegerToString((int)(price/g_point));

   if(ObjectFind(0,name)<0)
     {
      ObjectCreate(0,name,OBJ_HLINE,0,0,price);
      ObjectSetInteger(0,name,OBJPROP_COLOR,clr);
      ObjectSetInteger(0,name,OBJPROP_STYLE,STYLE_DOT);
      ObjectSetInteger(0,name,OBJPROP_BACK,true);
      ObjectSetInteger(0,name,OBJPROP_HIDDEN,true);
      ObjectSetInteger(0,name,OBJPROP_SELECTABLE,false);
      return;
     }

   ObjectMove(0,name,0,1,price);
  }
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
//| Отображение объекта "Текст"                                                                                                                                                                       |
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
void ShowText(int index,datetime time,double price,string text,string toolTip,color clr)
  {
   string name=PREFIX+IntegerToString(time)+IntegerToString(index);
   if(ObjectFind(0,name)<0)
     {
      ObjectCreate(0,name,OBJ_TEXT,0,time,price);
      ObjectSetString(0,name,OBJPROP_FONT,FONT_NAME);
      ObjectSetInteger(0,name,OBJPROP_FONTSIZE,FONT_SIZE);
      ObjectSetString(0,name,OBJPROP_TEXT,text);
      ObjectSetString(0,name,OBJPROP_TOOLTIP,toolTip);
      ObjectSetInteger(0,name,OBJPROP_COLOR,clr);
      ObjectSetInteger(0,name,OBJPROP_BACK,false);
      ObjectSetInteger(0,name,OBJPROP_HIDDEN,true);
      ObjectSetInteger(0,name,OBJPROP_SELECTABLE,false);
      return;
     }

   ObjectMove(0,name,0,time,price);
   ObjectSetInteger(0,name,OBJPROP_COLOR,clr);
   ObjectSetString(0,name,OBJPROP_TEXT,text);
  }
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
//| Определение, какому из указанных объемов соответствует рассматриваемая величина объема                                                                                                            |
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
int GetVolumeLevel(int index)
  {
   for(int i=0; i<MAX_VOLUMES_SHOW; i++)
      if(g_volumeLevelsColor[i].levelMinVolume>g_volumePriceArray[index])
         return i - 1;

   return MAX_VOLUMES_SHOW - 1;
  }
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
//| Отображение гистограмм одного бара                                                                                                                                                                |
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
void ShowBarHistogramms(int barIndex,double lowPrice,int arraySize)
  {
   if(!g_isShowInfo)
      return;

   for(int i=0; i<arraySize; i+=i_pointsInBox)
     {
      //--- Является ли объем уровня достаточно большим?
      int volumeLevel=GetVolumeLevel(i);
      if(volumeLevel<0)
         continue;

      //--- Отображение объемов
      double price=lowPrice+i*g_tickSize;
      ShowText(i,Time[barIndex],price,IntegerToString(g_volumePriceArray[i]),DoubleToString(price,Digits),g_volumeLevelsColor[volumeLevel].levelColor);
     }
  }
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
//| Отображение данных по историческим барам, начиная с указанного                                                                                                                                    |
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
void ProcessOldCandles(int limit,double &lowPrice,int &arraySize)
  {
//--- Открытие файла тиковой истории
   bool fileClose = false;
   int hTicksFile = FileOpen(Symbol() + ".tks", FILE_BIN | FILE_READ | FILE_SHARE_READ | FILE_SHARE_WRITE);
   if(hTicksFile<1)
      fileClose=true;

//--- Поиск первого тика, принадлежащего бару limit или любому более позднему бару
   TickStruct tick;
   tick.time= Time[limit];
   tick.bid = Open[limit];
   while(!IsStopped() && !fileClose)
     {
      if(!IsReadTimeAndBidAskOfTick(hTicksFile,tick))
         return;

      if(tick.time>=Time[limit])
         break;
     }

//--- Отображение данных
   datetime extremeTime=Time[0]+PeriodSeconds();
   while(tick.time<extremeTime && tick.time!=0)
     {
      int barIndex=iBarShift(NULL,0,tick.time);
      FormDataForOneBar(hTicksFile,Time[barIndex]+PeriodSeconds(),tick,lowPrice,arraySize,fileClose);
      ShowBarHistogramms(barIndex,lowPrice,arraySize);
     }

   if(!fileClose)
      FileClose(hTicksFile);
  }
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
//| Образование нового бара                                                                                                                                                                           |
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
void ProcessNewBarForming(double bid,double &lowPrice,int &arraySize)
  {
   ArrayInitialize(g_volumePriceArray,0);
   arraySize= 1;
   lowPrice = bid;
   g_volumePriceArray[0]=1;
  }
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
//| Обновление минимума текущей свечи                                                                                                                                                                 |
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
void ProcessCandleMinimumUpdate(int priceIndex,double bid,double &lowPrice,int &arraySize)
  {
   priceIndex = MathAbs(priceIndex);
   arraySize += priceIndex;
   if(arraySize>MAX_POINTS_IN_CANDLE)
      return;

//--- Увеличение количества значимых элементов массива на priceIndex элементов
   for(int i=arraySize-1; i>priceIndex-1; i--)
      g_volumePriceArray[i]=g_volumePriceArray[i-priceIndex];

//--- Заполнение нулями элементов, соответствующих ценам между предыдущим минимумом и текущим
   for(int i=priceIndex-1; i>=0; i--)
      g_volumePriceArray[i]=0;
   g_volumePriceArray[0]=1;

//--- Новый минимум
   lowPrice=bid;
  }
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
//| Запись данных о тике в массив g_ticks                                                                                                                                                             |
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
bool IsUpdateTicksArray(TickStruct &tick)
  {
   int total=ArraySize(g_ticks);
   if(ArrayResize(g_ticks,total+1,100)<0)
     {
      Alert(WindowExpertName(),": индикатору не хватает памяти для сохранения данных об очередном тике.");
      return false;
     }

   g_ticks[total]=tick;
   return true;
  }
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
//| Добавление одного нового тика к имеющейся свече                                                                                                                                                   |
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
void ProcessOneTick(int limit,double &lowPrice,int &arraySize)
  {
   TickStruct tick;
   tick.time= TimeCurrent();
   tick.ask = Ask;
   tick.bid = Bid;

//--- Добавление одного тика в массив хранения тиков   
   if(!IsUpdateTicksArray(tick))
     {
      g_activate=false;
      return;
     }

   double bid=CastPriceToCluster(Bid);

//--- Образование нового бара или начало работы "с нуля"
   if(limit==1 || lowPrice==0 || arraySize==0)
     {
      ProcessNewBarForming(bid,lowPrice,arraySize);
      return;
     }

//--- Если экстремумы свечи не обновлены, то просто добавляется объем одному из существующих уровней
   int priceIndex=(int)MathRound((bid-lowPrice)/g_tickSize);                                 // Индекс элемента массива g_volumePriceArray, которому соответствует цена Bid
   if(priceIndex>=0 && priceIndex < arraySize)
     {
      g_volumePriceArray[priceIndex]++;
      return;
     }

//--- Обновлен минимум текущей свечи. Нужно сдвинуть все элементы массива g_volumePriceArray на priceIndex вверх
   if(IsFirstMoreThanSecond(lowPrice,bid))
     {
      ProcessCandleMinimumUpdate(priceIndex,bid,lowPrice,arraySize);
      return;
     }

//--- Обновлен максимум текущей свечи. 
   if(priceIndex+1>MAX_POINTS_IN_CANDLE)
      return;

   arraySize=priceIndex+1;
   g_volumePriceArray[priceIndex]=1;
  }
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
//| Отображение сетки кластеров                                                                                                                                                                       |
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
void ShowGrid()
  {
   if(!g_init)
      return;

   g_init=false;

   if(i_showClusterGrid==NO)
      return;

//--- Определение исторических экстремумов
   double highPrice= CastPriceToCluster(High[iHighest(NULL,0,MODE_HIGH)]);
   double lowPrice = CastPriceToCluster(Low[iLowest(NULL,0,MODE_LOW)]);

//--- Отображение линий кластеров
   for(double price=lowPrice; price<=highPrice; price=NormalizeDouble(price+i_pointsInBox*g_point,Digits))
      ShowHLine(price,i_gridColor);
  }
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
//| Отображение данных индикатора                                                                                                                                                                     |
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
void ShowIndicatorData(int limit,int total)
  {
   static double lowPrice = 0;                                                                     // Цена, соответствующая минимуму свечи и нулевому элементу массива g_volumePriceArray. Первому..
                                                                                                   // ..элементу будет соответствовать цена lowPrice + Point и т.д.;
   static int arraySize = 0;                                                                       // Количество элементов, записанных в массив g_volumePriceArray. В идеале это значение должно быть..
                                                                                                   // ..равно количеству пунктов, из которых состоит свеча. Но из-за раздельной записи тиков и..
                                                                                                   // ..реального формирования свечей возможны сдвиги
   if(limit>1)   // Вызов происходит только в момент отображения всей истории - начальная загрузка или обновление..
     {           // ..баров с индексом более 1
      ProcessOldCandles(limit,lowPrice,arraySize);
      return;
     }

//--- Нормальное обновление - приход нового тика или образование нового бара
   ProcessOneTick(limit,lowPrice,arraySize);
   ShowBarHistogramms(0,lowPrice,arraySize);
  }
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
//| Custom indicator iteration function                                                                                                                                                               |
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
   if(!g_activate) // Если индикатор не прошел инициализацию, то работать он не должен
      return rates_total;

   ProcessGlobalTick(rates_total,prev_calculated);

   return rates_total;
  }
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
//| Выполнение одной итерации отображения данных                                                                                                                                                      |
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
void ProcessGlobalTick(const int rates_total,const int prev_calculated)
  {
   int total;
   int limit=GetRecalcIndex(total,rates_total,prev_calculated);                                // С какого бара начинать обновление?

   ShowInfoViewButton();                                                                           // Отображение кнопки вкл./выкл. визуализации показаний индикатора
   ShowGrid();                                                                                     // Отображение линий кластеров
   ShowIndicatorData(limit, total);                                                                // Отображение данных индикатора
  }
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
//| Обработчик событий чарта                                                                                                                                                                          |
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
void OnChartEvent(const int id,const long &lparam,const double &dparam,const string &sparam)
  {
   if(id!=CHARTEVENT_OBJECT_CLICK)
      return;

   if(sparam!=PREFIX+SIGN_BUTTON+IntegerToString(BUTTON_XCOORD)+IntegerToString(BUTTON_YCOORD))
      return;

//--- Выключение кластеров   
   if(g_isShowInfo)
     {
      DeleteAllObjects();
      ShowButton(BUTTON_XCOORD,BUTTON_YCOORD,"Кластеры вкл.");
      g_isShowInfo=false;
      g_init=false;
      return;
     }

//--- Включение кластеров
   g_init=true;
   ProcessGlobalTick(Bars,0);
  }
//+------------------------------------------------------------------+
