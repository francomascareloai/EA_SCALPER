
#property copyright "Copyright © HELLTEAM^Pirat"
#property link      "http://www.fxmania.ru"

//+----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
//+
//| 03/07/2011 ver. 3.8.5 Добавлено ограничение на открытие только одного ордера внутри свечи (в данном случае раз в 15 минут), см. функцию OneOrderInBar и параметр OneOrderInBarMode.
//| Профиксен баг с постоянно выскакивающими сообщениями о превышении спреда, теперь сообщение будет появляться, только если при попытке открытия спред превышен.
//| Добавлена правило, при котором может происходить открытие противоположных ордеров (например на парах USDCAD и USDCHF может открываться). Раньше можно было открывать только 1
//| ордер, либо длинный, либо короткий. Теперь при желании можно открываться в обе стороны. См. параметр No_Hedge_Trades.
//| Добавлена дополнительная функция модификации (см. функцию ModifyOrder).
//|
//| 06/06/2011 ver. 3.8.4 Добавлено рыночное исполнение (см. параметр IsMarketExecution), то есть ордер открывается без sl и tp, а далее происходит модификация.
//| Необходимо для NDD счетов. Также изменена функция открытия и закрытия ордеров, теперь при реквотах советник повторяет попытки открытия. Число попыток можно задать в
//| параметре RequoteAttempts.
//+
//+----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
//| WallStreet Forex Robot ver. 3.8.5 FINAL (Pirate Edition)
//| 
//| Рабочие пары EURUSD, GBPUSD, USDCHF, USDJPY, USDCAD. Таймфрейм M15. Для каждой пары необходимы свои настройки.
//| По умолчанию эксперт настроен под торговлю на паре EURUSD M15. Для остальных пар подгружайте файлы настроек
//| .set из папки sets.
//|
//| Для оптимизации используйте файл for_optimisation_wsfr_3.8.5_final.set. Оптимизацию можно проводить по
//| контрольным точкам. Желательно оптимизировать на тиковых котировках (99% моделирование) по всем тикам.
//| Среднее время оптимизации по всем тикам занимает 10 дней. По контрольным точкам 1 сутки.
//| Рекомендуемый период оптимизации 1,5 года + 6 месяцев форвард. Оптимизацию необходимо проводить раз в квартал.
//| Также можно смело торговать на паре EURUSD m15 на стандартных "заводских" настройках.
//|
//| Данные для связи:
//| 
//| e-mail: fxmania.ru@gmail.com
//| icq: 8-345-89-91
//| skype: fxmania.ru
//+--------------------------------------------------------------------------------------------------------------+

//+--------------------------------------------------------------------------------------------------------------+
//| Основные входные параметры. Тейк-профит, стоп-лосс, вывод в безубыток и размер лота.
//+--------------------------------------------------------------------------------------------------------------+

extern string Name = "WallStreet Forex Robot ver. 3.8.5 FINAL (Pirate Edition)";
extern string Copy = "Copyright © HELLTEAM^Pirat";
extern string Op2 = "Оптимизация для пары";
extern string Symbol_Op = "EURUSD m15";
extern string Op = "Дата оптимизации";
extern datetime Date = D'12.05.2011'; //--- Сделал чисто для себя, чтобы видеть от какой даты оптимизация (дата забивается вручную)
extern string _TP = "Основные входные параметры";
//---
extern int TakeProfit = 15; //--- (10 2 60)
extern int StopLoss = 120; //--- (100 10 200)
extern bool UseStopLevels = TRUE; //--- Включение стоповых ордеров. Если выключена, то работают только виртуальные тейки и лоссы.
extern bool IsMarketExecution = true; //--- Включение рыночного исполнения открытия ордеров (сначало открывает, затем модифицирует)
//---
extern int SecureProfit = 1; //--- (0 1 5) Вывод в безубыток
extern int SecureProfitTriger =-7; //--- (10 2 30)
extern int MaxLossPoints = 0; //--- (-200 5 -20) Максимальная просадка для закрытия ордеров Buy и Sell при изменении сигнала (При просадке равной от - MaxLossPoints или меньше (например прибыль 0), ордер закроется)

extern string _MM = "Настройка MM";
//---
extern bool RecoveryMode = true; //--- Включение режима восстановления депозита (увеличение лота если случился стоп-лосс)
extern double FixedLot = 0.1; //--- Фиксированный объём лота
extern double AutoMM = 20.0; //--- ММ включается если AutoMM > 0. Процент риска. При RecoveryMode = FALSE, менять нужно только это значение.
//--- При AutoMM = 20 и депозите в 1000$, лот будет равен 0,2. Далее лот будет увеличиваться исходя из свободных средств, то есть уже при депозите в 2000$ лот будет равен 0,4.
extern double AutoMM_Max = 30.0; //--- Максимальный риск
extern int MaxAnalizCount = 50; //--- Число закрытых ранее ордеров для анализа(Используется при RecoveryMode = True)
extern double Risk = 45.0; //--- Риск от депозита (Используется при RecoveryMode = True)
extern double MultiLotPercent = 1.1; //--- Коэффициент умножение лота (Используется при RecoveryMode = True)

extern string _Vola = "Фильтр волатильности";
// Фильтр волатильности
extern int VolaFilter = 23; //--- (15 1 30)

//+--------------------------------------------------------------------------------------------------------------+
//| Периоды индикаторов. Кол-во баров для каждого индикатора.
//+--------------------------------------------------------------------------------------------------------------+

extern string _Periods = "Периоды индикаторов";

//--- Периоды индикаторов (Тоже можно будет заоптить, так как для каждой пары свои)
extern int iMA_Period = 75; //--- (60 5 100)
extern int iCCI_Period = 18; //--- (10 2 30)
extern int iATR_Period = 14; //--- (10 2 30) (!) Можно не оптить
extern int iWPR_Period = 11; //--- (10 1 20)

//+--------------------------------------------------------------------------------------------------------------+
//| Настройки из DLL
//+--------------------------------------------------------------------------------------------------------------+
//| EURUSD     | GBPUSD     | USDCHF     | USDJPY     | USDCAD     |
//+----------------------------------------------------------------
//| TP=26;     | TP=50;     | TP=17;     | TP=27;     | TP=14;     |
//| SL=120;    | SL=120;    | SL=120;    | SL=130;    | SL=150;    |
//| SP=1;      | SP=2;      | SP=0;      | SP=2;      | SP=2;      |
//| SPT=10;    | SPT=24;    | SPT=15;    | SPT=14;    | SPT=10;    |
//| MLP=-65;   | MLP=-200;  | MLP=-40;   | MLP=-80;   | MLP=-30;   |
//+----------------------------------------------------------------
//| MA=75;     | MA=75;     | MA=70;     | MA=85;     | MA=65;     |
//| CCI=18;    | CCI=12;    | CCI=14;    | CCI=12;    | CCI=12;    |
//| ATR=14;    | ATR=14;    | ATR=14;    | ATR=14;    | ATR=14;    |
//| WPR=11;    | WPR=12;    | WPR=12;    | WPR=12;    | WPR=16;    |
//+----------------------------------------------------------------
//| FATR=6;    | FATR=6;    | FATR=3;    | FATR=0;    | FATR=4;    |
//| FCCI=150;  | FCCI=290;  | FCCI=170;  | FCCI=2000; | FCCI=130;  |
//+----------------------------------------------------------------
//| MAFOA=15;  | MAFOA=12;  | MAFOA=8;   | MAFOA=5;   | MAFOA=5;   |
//| MAFOB=39;  | MAFOB=33;  | MAFOB=25;  | MAFOB=21;  | MAFOB=15;  |
//| WPRFOA=-99;| WPRFOA=-99;| WPRFOA=-95;| WPRFOA=-99;| WPRFOA=-99;|
//| WPRFOB=-95;| WPRFOB=-94;| WPRFOB=-92;| WPRFOB=-95;| WPRFOB=-89;|
//+----------------------------------------------------------------
//| MAFC=14;   | MAFC=18;   | MAFC=11;   | MAFC=14;   | MAFC=14;   |
//| WPRFC=-19; | WPRFC=-19; | WPRFC=-22; | WPRFC=-27; | WPRFC=-6;  |
//+--------------------------------------------------------------------------------------------------------------+

//+--------------------------------------------------------------------------------------------------------------+
//| Параметры оптимизации для правил открытия и закрытия позиции.
//+--------------------------------------------------------------------------------------------------------------+
extern string _Add_Op = "Расширенные параметры оптимизации";
//---
extern string _AddOpenFilters = "---";
//---
extern int FilterATR = 6; //--- (0 1 10) Проверка на вход по ATR для Buy и Sell (if (iATR_Signal <= FilterATR * pp) return (0);) (!) Можно не оптить
extern double iCCI_OpenFilter = 150; //--- (100 10 400) Фильтр по iCCI для Buy и Sell. При оптимизации под JPY рекомендуемо оптить по правилу (100 50 4000)
//---
extern string _OpenOrderFilters = "---";
//---
extern int iMA_Filter_Open_a = 15; //--- (4 2 20) Фильтр МА для открытия Buy и Sell (Пунты)
extern int iMA_Filter_Open_b = 39; //--- (14 2 50) Фильтр МА для открытия Buy и Sell (Пунты)
extern int iWPR_Filter_Open_a = -99; //--- (-100 1 0) Фильтр WPR для открытия Buy и Sell
extern int iWPR_Filter_Open_b = -95; //--- (-100 1 0) Фильтр WPR для открытия Buy и Sell
//---
extern string _CloseOrderFilters = "---";
//---
extern int Price_Filter_Close = 14; //--- (10 2 20) Фильтр цены открытия для закрытия Buy и Sell (Пунты)
extern int iWPR_Filter_Close = -19; //--- (0 1 -100) Фильтр WPR для закрытия Buy и Sell

//+--------------------------------------------------------------------------------------------------------------+
//| Расширенные настройки
//+--------------------------------------------------------------------------------------------------------------+

extern string _Add = "Расширенные настройки";
extern bool LongTrade = TRUE; //--- Выключатель длинных позиций
extern bool ShortTrade = TRUE; //--- Выключатель коротких позиций
extern bool No_Hedge_Trades = false; //--- Одновременное открытие одного Buy и одного Sell ордера. При True не хеджирует.
extern bool OneOrderInBarMode = TRUE; //--- При True советник будет открывать только 1 ордер в 1 свече. (В данном случае не более чем 1 раз в 15 минут). В тестере не работает, так как замедляет его в 10 раз.
extern int MagicNumber = 777;
extern double MaxSpread = 4;
extern double OpenSlippage = 3; //--- Проскальзывание для открытия ордера
extern double CloseSlippage = 5; //--- Проскальзывание для закрытия ордера
extern int RequoteAttempts = 5; //--- Максимальное число повторений при открытии/закрытии ордера при реквотах и других ошибках
extern bool WriteLog = TRUE; //--- //--- Включение всплывающих окон в терминале.
extern bool WriteDebugLog = TRUE; //--- Включение всплывающих окон об ошибках в терминале.
extern bool PrintLogOnChart = TRUE; //--- Включение комментариев на графике (при тестировании выключается автоматически)

//+--------------------------------------------------------------------------------------------------------------+
//| Блок дополнительных переменных
//+--------------------------------------------------------------------------------------------------------------+

double pp;
int pd;
double cf;
string EASymbol; //--- Текущий символ
int SP;
int CloseSP;
int MaximumTrades = 1;
double NDMaxSpread; //--- Максимальный спред ввиде пунктов
bool CheckSpreadRuleBuy; //--- Правило для проверки спреда перед открытием (Останавливает зацикливание сообщений о превышенном спреде)
bool CheckSpreadRuleSell;
string OpenOrderComment = "WSFR v3.8.5 FINAL";
int RandomOpenTimePercent = 0; //--- Используется при занятом потоке комманд терминала, своебразная рендомная пауза. Выражается в секундах.
//---

//--- Параметры для автолота
double MinLot = 0.01;
double MaxLot = 0.01;
double LotStep = 0.01;
int LotValue = 100000;
double FreeMargin = 1000.0;
double LotPrice = 1;
double LotSize;

//--- Параметры на открытие

int iWPR_Filter_OpenLong_a;
int iWPR_Filter_OpenLong_b;
int iWPR_Filter_OpenShort_a;
int iWPR_Filter_OpenShort_b;

//--- Параметры на закрытие

int iWPR_Filter_CloseLong;
int iWPR_Filter_CloseShort;

//---
color OpenBuyColor = Blue;
color OpenSellColor = Red;
color CloseBuyColor = DodgerBlue;
color CloseSellColor = DeepPink;


//+--------------------------------------------------------------------------------------------------------------+
//| INIT. Инициализация некоторых переменных, удаление объектов на графике.
//+--------------------------------------------------------------------------------------------------------------+
void init() {
//+--------------------------------------------------------------------------------------------------------------+

   //---
   if (IsTesting() && !IsVisualMode()) {PrintLogOnChart = FALSE; OneOrderInBarMode = FALSE;} //--- Если тестируем, то отключаются комментарии на графике и функция OneOrderInBarMode
   if (!PrintLogOnChart) Comment("");
   //---
   EASymbol = Symbol(); //--- Инициализация текущено символа
   //---
   if (Digits < 4) {
      pp = 0.01;
      pd = 2;
      cf = 0.01;
   } else {
      pp = 0.0001;
      pd = 4;
      cf = 0.0001;
   }
   //---
   SP = OpenSlippage * MathPow(10, Digits - pd); //--- Расчет проскальзывания цены для пятизнака
   CloseSP = CloseSlippage * MathPow(10, Digits - pd);
   NDMaxSpread = NormalizeDouble(MaxSpread * pp, pd + 1); //--- Преобразование значения MaxSpread в пункты
   //---
   if (ObjectFind("BKGR") >= 0) ObjectDelete("BKGR");
   if (ObjectFind("BKGR2") >= 0) ObjectDelete("BKGR2");
   if (ObjectFind("BKGR3") >= 0) ObjectDelete("BKGR3");
   if (ObjectFind("BKGR4") >= 0) ObjectDelete("BKGR4");
   if (ObjectFind("LV") >= 0) ObjectDelete("LV");
   //---
   
   //--- Инициализация параметров для MM
   
   MinLot = MarketInfo(Symbol(), MODE_MINLOT);
   MaxLot = MarketInfo(Symbol(), MODE_MAXLOT);
   LotValue = MarketInfo(Symbol(), MODE_LOTSIZE);
   LotStep = MarketInfo(Symbol(), MODE_LOTSTEP);
   FreeMargin = MarketInfo(Symbol(), MODE_MARGINREQUIRED);
   
   //--- Получение значения стоимости лота конкретного символа исходя из парамтеров вашего брокера.
   double SymbolBid = 0;
   if (StringSubstr(AccountCurrency(), 0, 3) == "JPY") {
      SymbolBid = MarketInfo("USDJPY" + StringSubstr(Symbol(), 6), MODE_BID);
      if (SymbolBid > 0.1) LotPrice = SymbolBid;
      else LotPrice = 84;
   }
   //---
   if (StringSubstr(AccountCurrency(), 0, 3) == "GBP") {
      SymbolBid = MarketInfo("GBPUSD" + StringSubstr(Symbol(), 6), MODE_BID);
      if (SymbolBid > 0.1) LotPrice = 1 / SymbolBid;
      else LotPrice = 0.6211180124;
   }
   //---
   if (StringSubstr(AccountCurrency(), 0, 3) == "EUR") {
      SymbolBid = MarketInfo("EURUSD" + StringSubstr(Symbol(), 6), MODE_BID);
      if (SymbolBid > 0.1) LotPrice = 1 / SymbolBid;
      else LotPrice = 0.7042253521;
   }
   
   //--- Параметры на открытие
   
   iWPR_Filter_OpenLong_a = iWPR_Filter_Open_a;
   iWPR_Filter_OpenLong_b = iWPR_Filter_Open_b;
   iWPR_Filter_OpenShort_a = -100 - iWPR_Filter_Open_a;
   iWPR_Filter_OpenShort_b = -100 - iWPR_Filter_Open_b;

   //--- Параметры на закрытие
   
   iWPR_Filter_CloseLong = iWPR_Filter_Close;
   iWPR_Filter_CloseShort = -100 - iWPR_Filter_Close;
   
   //---
   return (0);
   
}

//+--------------------------------------------------------------------------------------------------------------+
//| DEINIT. Удаление объектов на графике.
//+--------------------------------------------------------------------------------------------------------------+
int deinit() {
//+--------------------------------------------------------------------------------------------------------------+

   if (ObjectFind("BKGR") >= 0) ObjectDelete("BKGR");
   if (ObjectFind("BKGR2") >= 0) ObjectDelete("BKGR2");
   if (ObjectFind("BKGR3") >= 0) ObjectDelete("BKGR3");
   if (ObjectFind("BKGR4") >= 0) ObjectDelete("BKGR4");
   if (ObjectFind("LV") >= 0) ObjectDelete("LV");
   //---
   return (0);
   
}

//+--------------------------------------------------------------------------------------------------------------+
//| START. Проверка на ошибки, а также старт функции Scalper.
//+--------------------------------------------------------------------------------------------------------------+
int start() {
//+--------------------------------------------------------------------------------------------------------------+
   
   if (PrintLogOnChart) ShowComments (); //--- Включение комментариев на графике
   //---
   CloseOrders(); //--- Сопровождение ордеров
   ModifyOrders(); //--- Вывод в безубыток
   
   //--- Инициализация объёма сдеки
   if (AutoMM > 0.0 && (!RecoveryMode)) LotSize = MathMax(MinLot, MathMin(MaxLot, MathCeil(MathMin(AutoMM_Max, AutoMM) / LotPrice / 100.0 * AccountFreeMargin() / LotStep / (LotValue / 100)) * LotStep));
   if (AutoMM > 0.0 && RecoveryMode) LotSize = CalcLots(); //--- Если включен RecoveryMode используем CalcLots
   if (AutoMM == 0.0) LotSize = FixedLot;
   
   //--- Проверка наличия исторических данных для таймфрейма M15
   if(iBars(Symbol(), PERIOD_M15) < iMA_Period || iBars(Symbol(), PERIOD_M15) < iWPR_Period || iBars(Symbol(), PERIOD_M15) < iATR_Period || iBars(Symbol(), PERIOD_M15) < iCCI_Period)
   {
      Print("Недостаточно исторических данных для торговли");
      return;
   }
   //---
   if (DayOfWeek() == 1 && iVolume(NULL, PERIOD_D1, 0) < 5.0) return (0);
   if (StringLen(EASymbol) < 6) return (0);   
   //---
   if ((!IsTesting()) && IsStopped()) return (0);
   if ((!IsTesting()) && !IsTradeAllowed()) return (0);
   if ((!IsTesting()) && IsTradeContextBusy()) return (0);
   //---
   HideTestIndicators(TRUE);
   //---
   Scalper();
   //---
   return (0);
}

//+--------------------------------------------------------------------------------------------------------------+
//| Scalper. Основная функция. Сначало производится проверка спреда, далее проверка сигналов на вход.
//+--------------------------------------------------------------------------------------------------------------+
void Scalper() {
//+--------------------------------------------------------------------------------------------------------------+

   bool OpenBuyRule = TRUE;
   bool OpenSellRule = TRUE;
   
   //--- Правило для открытия противоположных ордеров.
   if (No_Hedge_Trades == TRUE && CheckOpenTrade(OP_SELL)) OpenBuyRule = FALSE;
   if (No_Hedge_Trades == TRUE && CheckOpenTrade(OP_BUY)) OpenSellRule = FALSE;
      
   //--- Проверка на открытие длинного ордера
   if (OpenLongSignal() && !CheckOpenTrade(OP_BUY) && OpenBuyRule && OneOrderInBar(OP_BUY) && LongTrade) {
         
      //--- Сообщение о превышенном спреде
      if (MaxSpreadFilter()) {
         if (!CheckSpreadRuleBuy && WriteDebugLog) {
         //---
         Print("Торговый сигнал на покупку пропущен из-за большого спреда.");
         Print("Текущий спред = ", DoubleToStr((Ask - Bid) / pp, 1), ",  MaxSpread = ", DoubleToStr(MaxSpread, 1));
         Print("Эксперт WSFR 3.8.5 будет пробовать позже, когда спред станет допустимым.");
         }
         //---
         CheckSpreadRuleBuy = TRUE;
      //---
      } else {
         //---
         CheckSpreadRuleBuy = FALSE;
         // запрет торговли при привышении волатильности
         if (CheckVolatility()) 
         {
            Print("Волатильность превышена, для безопасности пропускаем торговый сигнал");
         }else
         { 
           OpenPosition(OP_BUY);
         }
      }
   }//--- Закрытие if (OpenLongSignal()
      
   //--- Проверка на открытие короткого ордера   
   if (OpenShortSignal()&& !CheckOpenTrade(OP_SELL) && OpenSellRule && OneOrderInBar(OP_SELL) && ShortTrade) {
         
      //--- Сообщение о превышенном спреде
      if (MaxSpreadFilter()) {
         if (!CheckSpreadRuleSell && WriteDebugLog) {
         //---
         Print("Торговый сигнал на продажу пропущен из-за большого спреда.");
         Print("Текущий спред = ", DoubleToStr((Ask - Bid) / pp, 1), ",  MaxSpread = ", DoubleToStr(MaxSpread, 1));
         Print("Эксперт WSFR 3.8.5 будет пробовать позже, когда спред станет допустимым.");
         }
         //---
         CheckSpreadRuleSell = TRUE;
      //---
      } else {
         //---
         CheckSpreadRuleSell = FALSE;
         // запрет торговли при привышении волатильности
         if (CheckVolatility()) 
         {
            Print("Волатильность превышена, для безопасности пропускаем торговый сигнал");
         }else
         { 
           OpenPosition(OP_SELL);
         }
      }
   } //--- Закрытие  if (OpenShortSignal()
}

//+--------------------------------------------------------------------------------------------------------------+
//| фильтр волатильности
//+--------------------------------------------------------------------------------------------------------------+
bool CheckVolatility() {
   double HeightFilter_a = NormalizeDouble(VolaFilter * pp, pd);
   bool restrict = false;
   if (NormalizeDouble(iHigh(NULL, PERIOD_M15, 1) - iLow(NULL, PERIOD_M15, 1), pd) > HeightFilter_a) restrict = true;
   if (NormalizeDouble(iHigh(NULL, PERIOD_M15, 2) - iLow(NULL, PERIOD_M15, 2), pd) > HeightFilter_a) restrict = true;
   return (restrict);
}

//+--------------------------------------------------------------------------------------------------------------+
//| OpenPosition. Функция открытия позиции.
//+--------------------------------------------------------------------------------------------------------------+
int OpenPosition(int OpType) {
//+--------------------------------------------------------------------------------------------------------------+

   int RandomOpenTime; //--- Задержка по времени на открытие
   color OpenColor; //--- Цвет открытия позиции. Если Buy то голубая, если Sell то красная
   int OpenOrder = 0; //--- Открытие позиции
   int OpenOrderError; //--- Ошибка открытия
   string OpTypeString; //--- Преобразования вида позиции в текстовое значение
   double OpenPrice; //--- Цена открытия
   int    maxtry = RequoteAttempts;
   int    lasterror = 0;
   double price = 0;
   //---
   double TP, SL;
   double OrderTP = NormalizeDouble (TakeProfit * pp , pd); //--- Преобразуем тейк-профит в вид Points
   double OrderSL = NormalizeDouble (StopLoss * pp , pd); //--- Преобразуем стоп-лосс в вид Points
     
   //--- Задержка в секундах между открытиями
   if (RandomOpenTimePercent > 0) {
      MathSrand(TimeLocal());
      RandomOpenTime = MathRand() % RandomOpenTimePercent;
      
      if (WriteLog) {
      Print("DelayRandomiser: задержка ", RandomOpenTime, " секунд.");
      }
      
      Sleep(1000 * RandomOpenTime);
   } //--- Закрытие if (RandomOpenTimePerc
   
   double OpenLotSize = LotSize; //--- Расчет объёма позиции
   
   //--- Если не хватет средств, возвращаем ошибку
   if (AccountFreeMarginCheck(EASymbol, OpType, OpenLotSize) <= 0.0 || GetLastError() == 134/* NOT_ENOUGH_MONEY */) {
      //---
      if (WriteDebugLog) {
      //---
         Print("Для открытия ордера недостаточно свободной маржи.");
         Comment("Для открытия ордера недостаточно свободной маржи.");
      //---
      }
      return (-1);
   } //--- Закрытие if (AccountFreeMarginCheck  
   
   RefreshRates();
   
   //--- Если длинная позиция, то
   if (OpType == OP_BUY) {
      OpenPrice = NormalizeDouble(Ask, Digits);
      OpenColor = OpenBuyColor;
      
      //---
      if (UseStopLevels) { //--- Если включены стоп-уровни (стоп-лосс и тейк-профит)
      
      TP = NormalizeDouble(OpenPrice + OrderTP, Digits); //--- То расчитывает тейк-профит
      SL = NormalizeDouble(OpenPrice - OrderSL, Digits); //--- и стоп-лосс
      //---
      } else {TP = 0; SL = 0;}
   
   //--- Если короткая позиция, то   
   } else {
      OpenPrice = NormalizeDouble(Bid, Digits);
      OpenColor = OpenSellColor;
      
      //---
      if (UseStopLevels) {
       
      TP = NormalizeDouble(OpenPrice - OrderTP, Digits);
      SL = NormalizeDouble(OpenPrice + OrderSL, Digits);
      }
      //---
      else {TP = 0; SL = 0;}
   }
   
//--- Если тип исполнения Market Execution (рыночное исполнение), то сначало открываем ордер без sl и tp, а после модифицируем его

if (IsMarketExecution && UseStopLevels)
   {
   OpenOrder = OrderSend(EASymbol, OpType, OpenLotSize, OpenPrice, SP, 0, 0, OpenOrderComment, MagicNumber, 0, OpenColor);
   if (OpenOrder > 0)
      {
      OrderModify(OpenOrder,OrderOpenPrice(),SL,TP,0);
      return(OpenOrder);
      }
   }
   
      //--- Если же нет, то сразу открываем с sl и tp
      
      else
   {
   OpenOrder = OrderSend(EASymbol, OpType, OpenLotSize, OpenPrice, SP, SL, TP, OpenOrderComment, MagicNumber, 0, OpenColor);
   if (OpenOrder > 0) return(OpenOrder);
   }

//--- Если тип ордера не верен, то повторяем операцию.

if ((OpType != OP_BUY) && (OpType != OP_SELL)) return(OpenOrder);

//--- Если ордер открылся успешно, то отправляем сообщение на e-mail (если включена отправка)

if (OpenOrder < 0) { //--- Если ордер не открылся, то
   OpenOrderError = GetLastError(); //--- Возвращаем ошибку
         //---
   if (WriteDebugLog) {
      if (OpType == OP_BUY) OpTypeString = "OP_BUY";
         else OpTypeString = "OP_SELL";
            Print("Открытие: OrderSend(", OpTypeString, ") ошибка = ", ErrorDescription(OpenOrderError)); //--- Код ошибки на Русском
         } //--- Закрытие if (WriteDebugLog)
}

//--- При реквотах повторяем операцию.

lasterror = GetLastError();

if ((OpenOrder < 0) && ((lasterror == 135) || (lasterror == 138) || (lasterror == 146)))
   {
   Print("Requote. Error" + lasterror + ". Ticket: " + OpenOrder);
   }
      else
   {
   return(OpenOrder);
   }

//--- Цикл открытия ордера при возникновении ошибок (Максимальное число попыток открытия при возникновении ошибок равно значению RequoteAttempts) 

price = OpenPrice;

for (int attempt = 1; attempt <= maxtry; attempt++)
   {
   RefreshRates();
   if (OpType == OP_BUY)
      {
      if (Ask <= price)
         {
         if (IsMarketExecution && UseStopLevels)
            {
            OpenOrder = OrderSend(EASymbol, OpType, OpenLotSize, NormalizeDouble(Ask,Digits), SP, 0, 0, OpenOrderComment, MagicNumber, 0, OpenColor);
            if (OpenOrder > 0)
               {
               OrderModify(OpenOrder,OrderOpenPrice(),SL,TP,0);
               return(OpenOrder);
               }
            }
               else
            {
            OpenOrder = OrderSend(EASymbol, OpType, OpenLotSize, NormalizeDouble(Ask,Digits), SP, SL, TP, OpenOrderComment, MagicNumber, 0, OpenColor);
            if (OpenOrder > 0) return(OpenOrder);
            }
         if ((GetLastError() != 135) && (GetLastError() != 138) && (GetLastError() != 146)) return(OpenOrder);
         Print("Requote. " + "Attempt " + (attempt + 1));
         continue;
         }
      }
   if (OpType == OP_SELL)
      {
      if (Bid >= price)
         {
         if (IsMarketExecution && UseStopLevels)
            {
            OpenOrder = OrderSend(EASymbol, OpType, OpenLotSize, NormalizeDouble(Bid,Digits), SP, 0, 0, OpenOrderComment, MagicNumber, 0, OpenColor);
            if (OpenOrder > 0)
               {
               OrderModify(OpenOrder,OrderOpenPrice(),SL,TP,0);
               return(OpenOrder);
               }
            }
               else
            {
            OpenOrder = OrderSend(EASymbol, OpType, OpenLotSize, NormalizeDouble(Bid,Digits), SP, SL, TP, OpenOrderComment, MagicNumber, 0, OpenColor);
            if (OpenOrder > 0) return(OpenOrder);
            }
         if ((GetLastError() != 135) && (GetLastError() != 138) && (GetLastError() != 146)) return(OpenOrder);
         Print("Requote. " + "Attempt " + (OpenOrder + 1));
         }
      }
   }

//---
return(-1);

}

//+--------------------------------------------------------------------------------------------------------------+
//| ModifyOrders. Модификация ордеров в безубыток.
//+--------------------------------------------------------------------------------------------------------------+
void ModifyOrders() {
//+--------------------------------------------------------------------------------------------------------------+

   int total = OrdersTotal() - 1;
   int ModifyError = GetLastError();
   
   //---
   for (int i = total; i >= 0; i--) { //--- Счетчик открытых ордеров
      if (!OrderSelect(i, SELECT_BY_POS, MODE_TRADES)) {
         if (WriteDebugLog) Print("Произошла ошибка во время выборки ордера. Причина: ", ErrorDescription(ModifyError));
      
      } else {
      
      //--- Модификация ордера на покупку
      if (OrderType() == OP_BUY) {
         if (OrderMagicNumber() == MagicNumber && OrderSymbol() == EASymbol) {
            if (Bid - OrderOpenPrice() > SecureProfitTriger * pp && MathAbs(OrderOpenPrice() + SecureProfit * pp - OrderStopLoss()) >= Point && OrderOpenPrice()<OrderStopLoss()) {
               //--- Модифицируем ордер
               ModifyOrder(EASymbol, OrderOpenPrice(), NormalizeDouble(OrderOpenPrice() + SecureProfit * pp, Digits), OrderTakeProfit(), Blue);
               }
            }
         } //--- Закрытие if (OrderType() == OP_BUY)
      
      //--- Модификация ордера на продажу
      if (OrderType() == OP_SELL) {
         if (OrderMagicNumber() == MagicNumber && OrderSymbol() == EASymbol) {
            if (OrderOpenPrice() - Ask > SecureProfitTriger * pp && MathAbs(OrderOpenPrice() - SecureProfit * pp - OrderStopLoss()) >= Point && OrderOpenPrice()>OrderStopLoss()) {
               //--- Модифицируем ордер
               ModifyOrder(EASymbol, OrderOpenPrice(), NormalizeDouble(OrderOpenPrice() - SecureProfit * pp, Digits), OrderTakeProfit(), Red);
               }
            }
         } //--- Закрытие if (OrderType() == OP_SELL)
      }
   } //--- Закрытие for (int i = total - 1; i >= 0; i--)
}

//+--------------------------------------------------------------------------------------------------------------+
//| ModifyOrder. Модификация предварительно выбранного ордера.
//|  
//| Параметры:
//|   sy - наименование инструмента  ("" - текущий символ)
//|   pp - цена открытия позиции, установки ордера
//|   sl - ценовой уровень стопа
//|   tp - ценовой уровень тейка
//|   cl - цвет
//+--------------------------------------------------------------------------------------------------------------+
void ModifyOrder(string sy="", double pp=-1, double sl=0, double tp=0, color cl=CLR_NONE) {
//+--------------------------------------------------------------------------------------------------------------+

   int ModifyTicketID = OrderTicket();
   
   if (sy=="") sy=Symbol();
   bool   fm; //--- Модификация ордера
   double pAsk=MarketInfo(sy, MODE_ASK);
   double pBid=MarketInfo(sy, MODE_BID);
   int    dg, err, it;
   int    PauseAfterError = 5; //--- Пауза в секундах между попытками модификаций
   int    NumberOfTry = 10; //--- Кол-во попыток модификаций при возникновении ошибок
   
   //--- Проверка на ошибки переменных 
   if (pp<=0) pp=OrderOpenPrice();
   if (sl<0) sl=OrderStopLoss();
   if (tp<0) tp=OrderTakeProfit();
   
   //--- Инициализация параметров 
   dg=MarketInfo(sy, MODE_DIGITS);
   pp=NormalizeDouble(pp, dg);
   sl=NormalizeDouble(sl, dg);
   tp=NormalizeDouble(tp, dg);
   
   //--- Дополнительная проверка на ошибки переменных, после которой
   if (pp!=OrderOpenPrice() || sl!=OrderStopLoss() || tp!=OrderTakeProfit()) {
      
      //--- Начинаем цикл попыток модификаций
      for (it=1; it<=NumberOfTry; it++) {
         if (!IsTesting() && (!IsExpertEnabled() || IsStopped())) break;
         while (!IsTradeAllowed()) Sleep(5000);
         RefreshRates();
         
         //--- Модифицируем ордер
         fm=OrderModify(OrderTicket(), pp, sl, tp, 0, cl);
         
         //--- Если произошла ошибка, то
         if (!fm) {
         err=GetLastError();
         
         //--- Выдаём ошибку, если включено отображение ошибок
         if (WriteDebugLog) Print("Произошла ошибка во время модификации ордера (", GetNameOP(OrderType()), ",", ModifyTicketID, "). Причина: ", ErrorDescription(err),". Попытка №",it);
         
         //--- Ждём PauseAfterError секунд, после чего повторяем попытку модификаций
         Sleep(1000*PauseAfterError);
         
         } //--- Закрытие if (!fm) {
      }
   }
}

//+--------------------------------------------------------------------------------------------------------------+
//| CloseTrades. Виртуальный тейк-профит и стоп-лосс.
//| Если включена функция UseStopLevels, то используется как функция резервного закрытия.
//+--------------------------------------------------------------------------------------------------------------+
void CloseOrders() {
//+--------------------------------------------------------------------------------------------------------------+

   int total = OrdersTotal() - 1;
   int SelectCloseError = GetLastError();
   
   //---
   for (int i = total; i >= 0; i--) { //--- Счетчик открытых ордеров
      if (!OrderSelect(i, SELECT_BY_POS, MODE_TRADES)) {
         if (WriteDebugLog) Print("Произошла ошибка во время выборки ордера. Причина: ", ErrorDescription(SelectCloseError));
      
      } else {
      
      //--- Закрытие по профиту или лоссу ордеров на покупку
      if (OrderType() == OP_BUY) {
         if (OrderMagicNumber() == MagicNumber && OrderSymbol() == EASymbol) {
            if (Bid >= OrderOpenPrice() + TakeProfit * pp || Bid <= OrderOpenPrice() - StopLoss * pp || CloseLongSignal(OrderOpenPrice(), ExistPosition())) {
               //---
               CloseOrder(OrderTicket(),Bid);
               //---
            }
         }
      } //--- Закрытие if (OrderType() == OP_BUY)
      
      //--- Закрытие по профиту или лоссу ордеров на продажу
      if (OrderType() == OP_SELL) {
         if (OrderMagicNumber() == MagicNumber && OrderSymbol() == EASymbol) {
            if (Ask <= OrderOpenPrice() - TakeProfit * pp || Ask >= OrderOpenPrice() + StopLoss * pp || CloseShortSignal(OrderOpenPrice(), ExistPosition())) {
               //---
               CloseOrder(OrderTicket(),Ask);
               //---
               }
            }
         } //--- Закрытие if (OrderType() == OP_SELL)
      } 
   } //--- Закрытие for (int i = total - 1; i >= 0; i--) {
}

//+--------------------------------------------------------------------------------------------------------------+
//| CloseOrder. Функция закрытия ордера.
//+--------------------------------------------------------------------------------------------------------------+
int CloseOrder(int ticket, double prce) {
//+--------------------------------------------------------------------------------------------------------------+

//--- Инициализация переменных необходимых для повтора открытия при реквотах или простых ошибках.

double price;
int    slippage;
double p = prce;
int    maxtry = RequoteAttempts;
color  CloseColor;

OrderSelect(ticket,SELECT_BY_TICKET,MODE_TRADES);

int ordtype = OrderType();
if (ordtype == OP_BUY) {price = NormalizeDouble(Bid,Digits); CloseColor = CloseBuyColor;}
if (ordtype == OP_SELL) {price = NormalizeDouble(Ask,Digits); CloseColor = CloseSellColor;}

if (MathAbs(OrderTakeProfit() - price) <= MarketInfo(Symbol(),MODE_FREEZELEVEL) * Point) return(0); //--- Проверка уровней заморозки тейк-профита
if (MathAbs(OrderStopLoss() - price) <= MarketInfo(Symbol(),MODE_FREEZELEVEL) * Point) return(0); //--- Проверка уровней заморозки стоп-лосса

if (OrderClose(ticket,OrderLots(),price,CloseSlippage,CloseColor)) return(1); //--- Если ордер открыт успешно, то возвращаем 1)
if ((GetLastError() != 135) && (GetLastError() != 138) && (GetLastError() != 146)) return(0); //--- Если нет то 0

Print("Requote");

//--- Цикл закрытия ордера при возникновении ошибок (Максимальное число попыток открытия при возникновении ошибок равно значению RequoteAttempts) 

for (int attempt = 1; attempt <= maxtry; attempt++)
   {
   RefreshRates();
   if (ordtype == OP_BUY)
      {
      slippage = MathRound((Bid - p) / pp);
      if (Bid >= p)
         {
         Print("Closing order. Attempt " + (attempt + 1));
         if (OrderClose(ticket,OrderLots(),NormalizeDouble(Bid,Digits),slippage,CloseColor)) return(1);
         if (!((GetLastError() != 135) && (GetLastError() != 138) && (GetLastError() != 146))) continue;
         return(0);
         }
      }
   if (ordtype == OP_SELL)
      {
      slippage = MathRound((p - Ask) / pp);
      if (p >= Ask)
         {
         Print("Closing order. Attempt " + (attempt + 1));
         if (OrderClose(ticket,OrderLots(),NormalizeDouble(Ask,Digits),slippage,CloseColor)) return(1);
         if ((GetLastError() != 135) && (GetLastError() != 138) && (GetLastError() != 146)) return(0);
         }
      }
   }
}

//+--------------------------------------------------------------------------------------------------------------+
//| OpenLongSignal. Сигнал на открытие длинной позиции.
//+--------------------------------------------------------------------------------------------------------------+
bool OpenLongSignal() {
//+--------------------------------------------------------------------------------------------------------------+

bool result = false;
bool result1 = false;
bool result2 = false;
bool result3 = false;

//--- Расчет основных сигналов на вход
double iClose_Signal = iClose(NULL, PERIOD_M15, 1);
double iMA_Signal = iMA(NULL, PERIOD_M15, iMA_Period, 0, MODE_SMMA, PRICE_CLOSE, 1);
double iWPR_Signal = iWPR(NULL, PERIOD_M15, iWPR_Period, 1);
double iATR_Signal = iATR(NULL, PERIOD_M15, iATR_Period, 1);
double iCCI_Signal = iCCI(NULL, PERIOD_M15, iCCI_Period, PRICE_TYPICAL, 1);
//---
double iMA_Filter_a = NormalizeDouble(iMA_Filter_Open_a*pp,pd);
double iMA_Filter_b = NormalizeDouble(iMA_Filter_Open_b*pp,pd);
double BidPrice = Bid; //--- (iClose_Signal >= BidPrice) Сравнение идёт именно с Bid (а не с Ask, как должно быть), так как цена закрытия свечи iClose_Signal формируется на основании значения Bid
//---

//--- Сверяем сигнал по АТР с его фильтром
if (iATR_Signal <= FilterATR * pp) return (0);
//---
if (iClose_Signal - iMA_Signal > iMA_Filter_a && iClose_Signal - BidPrice >= - cf && iWPR_Filter_OpenLong_a > iWPR_Signal) result1 = true;
else result1 = false;
//---
if (iClose_Signal - iMA_Signal > iMA_Filter_b && iClose_Signal - BidPrice >= - cf && - iCCI_OpenFilter > iCCI_Signal) result2 = true;
else result2 = false;
//---
if (iClose_Signal - iMA_Signal > iMA_Filter_b && iClose_Signal - BidPrice >= - cf && iWPR_Filter_OpenLong_b > iWPR_Signal) result3 = true;
else result3 = false;
//---
if (result1 == true || result2 == true || result3 == true) result = true;
else result = false;
//---
return (result);

}

//+--------------------------------------------------------------------------------------------------------------+
//| OpenShortSignal. Сигнал на открытие короткой позиции.
//+--------------------------------------------------------------------------------------------------------------+
bool OpenShortSignal() {
//+--------------------------------------------------------------------------------------------------------------+

bool result = false;
bool result1 = false;
bool result2 = false;
bool result3 = false;

//--- Расчет основных сигналов на вход
double iClose_Signal = iClose(NULL, PERIOD_M15, 1);
double iMA_Signal = iMA(NULL, PERIOD_M15, iMA_Period, 0, MODE_SMMA, PRICE_CLOSE, 1);
double iWPR_Signal = iWPR(NULL, PERIOD_M15, iWPR_Period, 1);
double iATR_Signal = iATR(NULL, PERIOD_M15, iATR_Period, 1);
double iCCI_Signal = iCCI(NULL, PERIOD_M15, iCCI_Period, PRICE_TYPICAL, 1);
//---
double iMA_Filter_a = NormalizeDouble(iMA_Filter_Open_a*pp,pd);
double iMA_Filter_b = NormalizeDouble(iMA_Filter_Open_b*pp,pd);
double BidPrice = Bid;
//---

//--- Сверяем сигнал по АТР с его фильтром
if (iATR_Signal <= FilterATR * pp) return (0);
//---
if (iMA_Signal - iClose_Signal > iMA_Filter_a && iClose_Signal - BidPrice <= cf && iWPR_Signal > iWPR_Filter_OpenShort_a) result1 = true;
else result1 = false;
//---
if (iMA_Signal - iClose_Signal > iMA_Filter_b && iClose_Signal - BidPrice <= cf && iCCI_Signal > iCCI_OpenFilter) result2 = true;
else result2 = false;
//---
if (iMA_Signal - iClose_Signal > iMA_Filter_b && iClose_Signal - BidPrice <= cf && iWPR_Signal > iWPR_Filter_OpenShort_b) result3 = true;
else result3 = false;
//---
if (result1 == true || result2 == true || result3 == true) result = true;
else result = false;
//---
return (result);

}

//+--------------------------------------------------------------------------------------------------------------+
//| CloseLongSignal. Сигнал на закрытие длинной позиции.
//+--------------------------------------------------------------------------------------------------------------+
bool CloseLongSignal(double OrderPrice, int CheckOrders) {
//+--------------------------------------------------------------------------------------------------------------+

bool result = false;
bool result1 = false;
bool result2 = false;
//---
double iWPR_Signal = iWPR(NULL, PERIOD_M15, iWPR_Period, 1);
double iClose_Signal = iClose(NULL, PERIOD_M15, 1);
double iOpen_CloseSignal = iOpen(NULL, PERIOD_M1, 1);
double iClose_CloseSignal = iClose(NULL, PERIOD_M1, 1);
//---
double MaxLoss = NormalizeDouble(-MaxLossPoints * pp,pd);
//---
double Price_Filter = NormalizeDouble(Price_Filter_Close*pp,pd);
double BidPrice = Bid;
//---

//---
if (OrderPrice - BidPrice <= MaxLoss && iClose_Signal - BidPrice <= cf && iWPR_Signal > iWPR_Filter_CloseLong && CheckOrders == 1) result1 = true;
else result1 = false;
//---
if (iOpen_CloseSignal > iClose_CloseSignal && BidPrice - OrderPrice >= Price_Filter && CheckOrders == 1) result2 = true;
else result2 = false;
//---
if (result1 == true || result2 == true) result = true;
else result = false;
//---
return (result);

}

//+--------------------------------------------------------------------------------------------------------------+
//| CloseShortSignal. Сигнал на закрытие короткой позиции.
//+--------------------------------------------------------------------------------------------------------------+
bool CloseShortSignal(double OrderPrice, int CheckOrders) {
//+--------------------------------------------------------------------------------------------------------------+

bool result = false;
bool result1 = false;
bool result2 = false;
//---
double iWPR_Signal = iWPR(NULL, PERIOD_M15, iWPR_Period, 1);
double iClose_Signal = iClose(NULL, PERIOD_M15, 1);
double iOpen_CloseSignal = iOpen(NULL, PERIOD_M1, 1);
double iClose_CloseSignal = iClose(NULL, PERIOD_M1, 1);
//---
double MaxLoss = NormalizeDouble(-MaxLossPoints*pp,pd);
//---
double Price_Filter = NormalizeDouble(Price_Filter_Close*pp,pd);
double BidPrice = Bid;
double AskPrice = Ask;
//---

//---
if (AskPrice - OrderPrice <= MaxLoss && iClose_Signal - BidPrice >= - cf && iWPR_Signal < iWPR_Filter_CloseShort && CheckOrders == 1) result1 = true;
else result1 = false;
//---
if (iOpen_CloseSignal < iClose_CloseSignal && OrderPrice - AskPrice >= Price_Filter && CheckOrders == 1) result2 = true;
else result2 = false;
//---
if (result1 == true || result2 == true) result = true;
else result = false;
//---
return (result);

}

//+--------------------------------------------------------------------------------------------------------------+
//| CalcLots. Функция расчета обьема лота.
//| При AutoMM > 0.0 && RecoveryMode функция CalcLots расчитывает объём лота относительно свободных средств.
//| 
//| Также расчет лота производиться исходя из числа открытых в прошлом ордеров. То есть увеличение лота теперь
//| зависит не только от свободных средств, но и от числа открытых в прошлом советником ордеров.
//| 
//| Помимо простого ММ, функция рассчитывает лот исходя из произошедших ранее стоп-лоссов при включенном
//| параметре RecoveryMode, то есть, при желании можно включить режим восстановления депозита.
//+--------------------------------------------------------------------------------------------------------------+
double CalcLots() {
//+--------------------------------------------------------------------------------------------------------------+

   double SumProfit; //--- Суммарный профит
   int OldOrdersCount; //--- Текущее кол-во закрытых советником ордеров
   double loss; //--- Просадка
   int LossOrdersCount; //--- Число лосей в прошлом
   double pr; //--- Профит
   int ProfitOrdersCount; //--- Кол-во прибыльных ордеров ы прошлом
   double LastPr; //--- Предыдущее значение профит
   int LastCount; //--- Предыдущее значение счетчика ордеров
   double MultiLot = 1; //---  Обнуление значения умножения лота
   //---
   
   //--- Если ММ включен, то
   if (MultiLotPercent > 0.0 && AutoMM > 0.0) {
      
      //--- Обнуляем значения
      SumProfit = 0;
      OldOrdersCount = 0;
      loss = 0;
      LossOrdersCount = 0;
      pr = 0;
      ProfitOrdersCount = 0;
      //---
      
      //--- Выбираем закрытие ранее ордера
      for (int i = OrdersHistoryTotal() - 1; i >= 0; i--) {
         if (OrderSelect(i, SELECT_BY_POS, MODE_HISTORY)) {
            if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber) {
               OldOrdersCount++; //--- Считаем ордера
               SumProfit += OrderProfit(); //--- и суммарный профит
               
               //--- Если суммарный профит больше pr (для начала больше 0)
               if (SumProfit > pr) {
                  //--- Инициализируем профит и счетчик прибыльных ордеров
                  pr = SumProfit;
                  ProfitOrdersCount = OldOrdersCount;
               }
               //--- Если суммарный профит меньше loss (для начала больше 0)
               if (SumProfit < loss) {
                  //--- Инициализируем просадку и счетчик убыточных ордеров
                  loss = SumProfit;
                  LossOrdersCount = OldOrdersCount;
               }
               //--- Если текущее кол-во подсчитанных ордеров больше или равно MaxAnalizCount (50), то в будущем считаем только свеженькие ордера а старые вычитаем.
               if (OldOrdersCount >= MaxAnalizCount) break;
            }
         }
      } //--- Закрытие for (int i = OrdersHistoryTotal() - 1; i >= 0; i--) {
      
      
      //--- Если число прибыльных ордеров меньше или равно числу лосей, то расчитываем значение умножения лота MultiLot
      if (ProfitOrdersCount <= LossOrdersCount) MultiLot = MathPow(MultiLotPercent, LossOrdersCount);
      
      //--- Если нет, то
      else {
         
         //--- Инициализируем параметры по профиту
         SumProfit = pr;
         OldOrdersCount = ProfitOrdersCount;
         LastPr = pr;
         LastCount = ProfitOrdersCount;
         
         //--- Выбираем закрытие ранее ордера (минус число прибыльных ордеров)
         for (i = OrdersHistoryTotal() - ProfitOrdersCount - 1; i >= 0; i--) {
            if (OrderSelect(i, SELECT_BY_POS, MODE_HISTORY)) {
               if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber) {
                  //--- Если выбрано более 50 ордеров прекразщаем выбирать
                  if (OldOrdersCount >= MaxAnalizCount) break;
                  //---
                  OldOrdersCount++; //--- Считаем кол-во ордеров
                  SumProfit += OrderProfit(); //--- и профит
                  
                  //--- Если новый профит меньше предыдущего (LastPr), то
                  if (SumProfit < LastPr) {
                     //--- Переинициализируем значения профита и кол-во ордеров
                     LastPr = SumProfit;
                     LastCount = OldOrdersCount;
                  }
               }
            }
         } //--- Закрытие for (i = OrdersHistoryTotal() - ProfitOrdersCount - 1; i >= 0; i--) {
         
         //--- Если значение счетчика LastCount равно счетчику прибыльных ордеров или прошлый профит равен текщему, то
         if (LastCount == ProfitOrdersCount || LastPr == pr) MultiLot = MathPow(MultiLotPercent, LossOrdersCount); //--- расчитываем значение умножения лота MultiLot
         
         //--- Если нет, то
         else {
            //--- Делим положительный (loss - pr) на положительный (LastPr - pr) и сравниваем с риском, после расчитываем умножение лота MultiLot
            if (MathAbs(loss - pr) / MathAbs(LastPr - pr) >= (Risk + 100.0) / 100.0) MultiLot = MathPow(MultiLotPercent, LossOrdersCount);
            else MultiLot = MathPow(MultiLotPercent, LastCount);
         }
      }
   } //--- Закрытие if (MultiLotPercent > 0.0 && AutoMM > 0.0) {
   
   //--- Получаем финальный объём лота, исходя из выполненных выше действий
   for (double OpLot = MathMax(MinLot, MathMin(MaxLot, MathCeil(MathMin(AutoMM_Max, MultiLot * AutoMM) / 100.0 * AccountFreeMargin() / LotStep / (LotValue / 100)) * LotStep)); OpLot >= 2.0 * MinLot &&
      1.05 * (OpLot * FreeMargin) >= AccountFreeMargin(); OpLot -= MinLot) {
   }
   return (OpLot);
}

//+--------------------------------------------------------------------------------------------------------------+
//| MaxSpreadFilter. Функция для расчета размера спреда и сравнения его со значением MaxSpread.
//| Если текущий спред превышен, то возвращаем TRUE.
//+--------------------------------------------------------------------------------------------------------------+
bool MaxSpreadFilter() {
//+--------------------------------------------------------------------------------------------------------------+

   RefreshRates();
   if (NormalizeDouble(Ask - Bid, Digits) > NDMaxSpread) return (TRUE);
   //---
   else return (FALSE);
}

//+--------------------------------------------------------------------------------------------------------------+
//| ExistPosition. Функция проверки открытых ордеров.
//| Если открыт ордер возвращает True, если нет, дает разрешение (False, 0) на открытие.
//+--------------------------------------------------------------------------------------------------------------+
int ExistPosition() {
//+--------------------------------------------------------------------------------------------------------------+

   int trade = OrdersTotal() - 1;
   for (int i = trade; i >= 0; i--) {
      if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES)) {
         if (OrderMagicNumber() == MagicNumber) {
            if (OrderSymbol() == EASymbol)
               if (OrderType() <= OP_SELL) return (1);
         }
      }
   }
   //---
   return (0);
}

//+--------------------------------------------------------------------------------------------------------------+
//| OneOrderInBar. Функция проверяет, открывался ли ордер внутри нулевой свечи.
//+--------------------------------------------------------------------------------------------------------------+
bool OneOrderInBar(int OpType = -1){
//+--------------------------------------------------------------------------------------------------------------+
   
   //--- Если отключена функция, то ничего не расчитываем.
   if (OneOrderInBarMode == FALSE) return(True);
   
   int Bar = Period(); //--- Свеча
   
   //--- Делаем выборку по закрытым ордерам
   for(int i = OrdersHistoryTotal(); i>=0; i--){
      //---
      if(OrderSelect(i,SELECT_BY_POS,MODE_HISTORY)){
         //---
         if(OrderSymbol() == EASymbol && OrderType() == OpType && OrderMagicNumber() == MagicNumber) {
            
            //--- Если время закрытия ордера больше времени открытия нулевого бара, то запрещаем открытие нового ордера.
            if(OrderCloseTime()>iTime(EASymbol,Bar,0)) return(False);
            }
         }
      }

   //---
   return(True);
}

//+--------------------------------------------------------------------------------------------------------------+
//| CheckOpenTrade. Функция для проверки открытого ордера. Проверяет был ли открыт ордер по OrderType.
//| Если был открыт, то возвращает TRUE, если нет, то FALSE.
//+--------------------------------------------------------------------------------------------------------------+
bool CheckOpenTrade(int OpType) {
//+--------------------------------------------------------------------------------------------------------------+
   
   int total = OrdersTotal();
   for (int i = total - 1; i >= 0; i--) {
      if (OrderSelect(i, SELECT_BY_POS) == TRUE)
         if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber && OrderType() == OpType) return (TRUE);
   }
   //---
   return (FALSE);
}

//+--------------------------------------------------------------------------------------------------------------+
//| ShowComments. Функция для отображения комментариев на графике.
//+--------------------------------------------------------------------------------------------------------------+
void ShowComments() {
//+--------------------------------------------------------------------------------------------------------------+

string ComSpacer = ""; //--- "/n"
datetime MyOpDate = TIME_DATE; //--- Вывод в комментарий даты оптимизации (формат)
//---
ComSpacer = ComSpacer
      + "\n  " 
      + "\n "
      + "\n  Version 3.8.5 (FINAL)"
      + "\n  Copyright © HELLTEAM^Pirat"
      + "\n  http://www.fxmania.ru"
      + "\n -----------------------------------------------"
      + "\n  Sets for: " + Symbol_Op
      + "\n  Optimization date: " + TimeToStr (Date, MyOpDate)
      + "\n -----------------------------------------------" 
      + "\n  SL = " + StopLoss + " pips / TP = " + TakeProfit + " pips" 
   + "\n  Spread = " + DoubleToStr((Ask - Bid) / pp, 1) + " pips";
   if (NormalizeDouble(Ask - Bid, Digits) > NDMaxSpread) ComSpacer = ComSpacer + " - TOO HIGH";
   else ComSpacer = ComSpacer + " - NORMAL";
   ComSpacer = ComSpacer 
   + "\n -----------------------------------------------";
   if (AutoMM > 0.0) {
      ComSpacer = ComSpacer 
         + "\n  AutoMM - ENABLED" 
      + "\n  Risk = " + DoubleToStr(AutoMM, 1) + "%";
   }
   ComSpacer = ComSpacer 
   + "\n  Trading Lots = " + DoubleToStr(LotSize, 2);
   ComSpacer = ComSpacer 
   + "\n -----------------------------------------------";
   if (UseStopLevels) {
      ComSpacer = ComSpacer 
      + "\n  Stop Levels - ENABLED";
   } else {
      ComSpacer = ComSpacer 
      + "\n  Stop Levels - DISABLED";
   }
      if (RecoveryMode) {
      ComSpacer = ComSpacer 
      + "\n  Recovery Mode - ENABLED";
   } else {
      ComSpacer = ComSpacer 
      + "\n  Recovery Mode - DISABLED";
   }
   ComSpacer = ComSpacer 
   + "\n -----------------------------------------------";
   Comment(ComSpacer);
   
   if (ObjectFind("LV") < 0) {
      ObjectCreate("LV", OBJ_LABEL, 0, 0, 0);
      ObjectSetText("LV", "WALL STREET ROBOT", 9, "Tahoma Bold", White);
      ObjectSet("LV", OBJPROP_CORNER, 0);
      ObjectSet("LV", OBJPROP_BACK, FALSE);
      ObjectSet("LV", OBJPROP_XDISTANCE, 13);
      ObjectSet("LV", OBJPROP_YDISTANCE, 23);
   }
   if (ObjectFind("BKGR") < 0) {
      ObjectCreate("BKGR", OBJ_LABEL, 0, 0, 0);
      ObjectSetText("BKGR", "g", 110, "Webdings", DarkViolet 	);
      ObjectSet("BKGR", OBJPROP_CORNER, 0);
      ObjectSet("BKGR", OBJPROP_BACK, TRUE);
      ObjectSet("BKGR", OBJPROP_XDISTANCE, 5);
      ObjectSet("BKGR", OBJPROP_YDISTANCE, 15);
   }
   if (ObjectFind("BKGR2") < 0) {
      ObjectCreate("BKGR2", OBJ_LABEL, 0, 0, 0);
      ObjectSetText("BKGR2", "g", 110, "Webdings", MidnightBlue);
      ObjectSet("BKGR2", OBJPROP_BACK, TRUE);
      ObjectSet("BKGR2", OBJPROP_XDISTANCE, 5);
      ObjectSet("BKGR2", OBJPROP_YDISTANCE, 60);
   }
   if (ObjectFind("BKGR3") < 0) {
      ObjectCreate("BKGR3", OBJ_LABEL, 0, 0, 0);
      ObjectSetText("BKGR3", "g", 110, "Webdings", MidnightBlue);
      ObjectSet("BKGR3", OBJPROP_CORNER, 0);
      ObjectSet("BKGR3", OBJPROP_BACK, TRUE);
      ObjectSet("BKGR3", OBJPROP_XDISTANCE, 5);
      ObjectSet("BKGR3", OBJPROP_YDISTANCE, 45);
   }
   if (ObjectFind("BKGR4") < 0) {
      ObjectCreate("BKGR4", OBJ_LABEL, 0, 0, 0);
      ObjectSetText("BKGR4", "g", 110, "Webdings", MidnightBlue);
      ObjectSet("BKGR4", OBJPROP_CORNER, 0);
      ObjectSet("BKGR4", OBJPROP_BACK, TRUE);
      ObjectSet("BKGR4", OBJPROP_XDISTANCE, 5);
      ObjectSet("BKGR4", OBJPROP_YDISTANCE, 84);
   }
}

//+--------------------------------------------------------------------------------------------------------------+
//| GetNameOP. Функций возвращает наименование торговой операции
//| Параметры:
//|   op - идентификатор торговой операции
//+--------------------------------------------------------------------------------------------------------------+
string GetNameOP(int op) {
//+--------------------------------------------------------------------------------------------------------------+

	switch (op) {
		case OP_BUY      : return("Buy");
		case OP_SELL     : return("Sell");
		case OP_BUYLIMIT : return("Buy Limit");
		case OP_SELLLIMIT: return("Sell Limit");
		case OP_BUYSTOP  : return("Buy Stop");
		case OP_SELLSTOP : return("Sell Stop");
		default          : return("Unknown Operation");
	}
}

//+--------------------------------------------------------------------------------------------------------------+
//| ErrorDescription. Возвращает описание ошибки по её номеру.
//+--------------------------------------------------------------------------------------------------------------+
string ErrorDescription(int error) {
//+--------------------------------------------------------------------------------------------------------------+

   string ErrorNumber;
   //---
   switch (error) {
   case 0:
   case 1:     ErrorNumber = "Нет ошибки, но результат неизвестен";                        break;
   case 2:     ErrorNumber = "Общая ошибка";                                               break;
   case 3:     ErrorNumber = "Неправильные параметры";                                     break;
   case 4:     ErrorNumber = "Торговый сервер занят";                                      break;
   case 5:     ErrorNumber = "Старая версия клиентского терминала";                        break;
   case 6:     ErrorNumber = "Нет связи с торговым сервером";                              break;
   case 7:     ErrorNumber = "Недостаточно прав";                                          break;
   case 8:     ErrorNumber = "Слишком частые запросы";                                     break;
   case 9:     ErrorNumber = "Недопустимая операция нарушающая функционирование сервера";  break;
   case 64:    ErrorNumber = "Счет заблокирован";                                          break;
   case 65:    ErrorNumber = "Неправильный номер счета";                                   break;
   case 128:   ErrorNumber = "Истек срок ожидания совершения сделки";                      break;
   case 129:   ErrorNumber = "Неправильная цена";                                          break;
   case 130:   ErrorNumber = "Неправильные стопы";                                         break;
   case 131:   ErrorNumber = "Неправильный объем";                                         break;
   case 132:   ErrorNumber = "Рынок закрыт";                                               break;
   case 133:   ErrorNumber = "Торговля запрещена";                                         break;
   case 134:   ErrorNumber = "Недостаточно денег для совершения операции";                 break;
   case 135:   ErrorNumber = "Цена изменилась";                                            break;
   case 136:   ErrorNumber = "Нет цен";                                                    break;
   case 137:   ErrorNumber = "Брокер занят";                                               break;
   case 138:   ErrorNumber = "Новые цены - Реквот";                                        break;
   case 139:   ErrorNumber = "Ордер заблокирован и уже обрабатывается";                    break;
   case 140:   ErrorNumber = "Разрешена только покупка";                                   break;
   case 141:   ErrorNumber = "Слишком много запросов";                                     break;
   case 145:   ErrorNumber = "Модификация запрещена, так как ордер слишком близок к рынку";break;
   case 146:   ErrorNumber = "Подсистема торговли занята";                                 break;
   case 147:   ErrorNumber = "Использование даты истечения ордера запрещено брокером";     break;
   case 148:   ErrorNumber = "Количество открытых и отложенных ордеров достигло предела "; break;
   //---- 
   case 4000:  ErrorNumber = "Нет ошибки";                                                 break;
   case 4001:  ErrorNumber = "Неправильный указатель функции";                             break;
   case 4002:  ErrorNumber = "Индекс массива - вне диапазона";                             break;
   case 4003:  ErrorNumber = "Нет памяти для стека функций";                               break;
   case 4004:  ErrorNumber = "Переполнение стека после рекурсивного вызова";               break;
   case 4005:  ErrorNumber = "На стеке нет памяти для передачи параметров";                break;
   case 4006:  ErrorNumber = "Нет памяти для строкового параметра";                        break;
   case 4007:  ErrorNumber = "Нет памяти для временной строки";                            break;
   case 4008:  ErrorNumber = "Неинициализированная строка";                                break;
   case 4009:  ErrorNumber = "Неинициализированная строка в массиве";                      break;
   case 4010:  ErrorNumber = "Нет памяти для строкового массива";                          break;
   case 4011:  ErrorNumber = "Слишком длинная строка";                                     break;
   case 4012:  ErrorNumber = "Остаток от деления на ноль";                                 break;
   case 4013:  ErrorNumber = "Деление на ноль";                                            break;
   case 4014:  ErrorNumber = "Неизвестная команда";                                        break;
   case 4015:  ErrorNumber = "Неправильный переход";                                       break;
   case 4016:  ErrorNumber = "Неинициализированный массив";                                break;
   case 4017:  ErrorNumber = "Вызовы DLL не разрешены";                                    break;
   case 4018:  ErrorNumber = "Невозможно загрузить библиотеку";                            break;
   case 4019:  ErrorNumber = "Невозможно вызвать функцию";                                 break;
   case 4020:  ErrorNumber = "Вызовы внешних библиотечных функций не разрешены";           break;
   case 4021:  ErrorNumber = "Недостаточно памяти для строки, возвращаемой из функции";    break;
   case 4022:  ErrorNumber = "Система занята";                                             break;
   case 4050:  ErrorNumber = "Неправильное количество параметров функции";                 break;
   case 4051:  ErrorNumber = "Недопустимое значение параметра функции";                    break;
   case 4052:  ErrorNumber = "Внутренняя ошибка строковой функции";                        break;
   case 4053:  ErrorNumber = "Ошибка массива";                                             break;
   case 4054:  ErrorNumber = "Неправильное использование массива-таймсерии";               break;
   case 4055:  ErrorNumber = "Ошибка пользовательского индикатора";                        break;
   case 4056:  ErrorNumber = "Массивы несовместимы";                                       break;
   case 4057:  ErrorNumber = "Ошибка обработки глобальныех переменных";                    break;
   case 4058:  ErrorNumber = "Глобальная переменная не обнаружена";                        break;
   case 4059:  ErrorNumber = "Функция не разрешена в тестовом режиме";                     break;
   case 4060:  ErrorNumber = "Функция не подтверждена";                                    break;
   case 4061:  ErrorNumber = "Ошибка отправки почты";                                      break;
   case 4062:  ErrorNumber = "Ожидается параметр типа string";                             break;
   case 4063:  ErrorNumber = "Ожидается параметр типа integer";                            break;
   case 4064:  ErrorNumber = "Ожидается параметр типа double";                             break;
   case 4065:  ErrorNumber = "В качестве параметра ожидается массив";                      break;
   case 4066:  ErrorNumber = "Запрошенные исторические данные в состоянии обновления";     break;
   case 4067:  ErrorNumber = "Ошибка при выполнении торговой операции";                    break;
   case 4099:  ErrorNumber = "Конец файла";                                                break;
   case 4100:  ErrorNumber = "Ошибка при работе с файлом";                                 break;
   case 4101:  ErrorNumber = "Неправильное имя файла";                                     break;
   case 4102:  ErrorNumber = "Слишком много открытых файлов";                              break;
   case 4103:  ErrorNumber = "Невозможно открыть файл";                                    break;
   case 4104:  ErrorNumber = "Несовместимый режим доступа к файлу";                        break;
   case 4105:  ErrorNumber = "Ни один ордер не выбран";                                    break;
   case 4106:  ErrorNumber = "Неизвестный символ";                                         break;
   case 4107:  ErrorNumber = "Неправильный параметр цены для торговой функции";            break;
   case 4108:  ErrorNumber = "Неверный номер тикета";                                      break;
   case 4109:  ErrorNumber = "Торговля не разрешена";                                      break;
   case 4110:  ErrorNumber = "Длинные позиции не разрешены";                               break;
   case 4111:  ErrorNumber = "Короткие позиции не разрешены";                              break;
   case 4200:  ErrorNumber = "Объект уже существует";                                      break;
   case 4201:  ErrorNumber = "Запрошено неизвестное свойство объекта";                     break;
   case 4202:  ErrorNumber = "Объект не существует";                                       break;
   case 4203:  ErrorNumber = "Неизвестный тип объекта";                                    break;
   case 4204:  ErrorNumber = "Нет имени объекта";                                          break;
   case 4205:  ErrorNumber = "Ошибка координат объекта";                                   break;
   case 4206:  ErrorNumber = "Не найдено указанное подокно";                               break;
   case 4207:  ErrorNumber = "Ошибка при работе с объектом";                               break;
   default:    ErrorNumber = "Неизвестная ошибка";
   }
   //---
   return (ErrorNumber);
}