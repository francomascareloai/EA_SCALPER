//=============================================================================================================|
//                                    ВСЕМ УДАЧИ !!!                                 |    ZzLiSzZ форум МТ5    |
//                        С благодарностью всем форумчанам МТ5                       | Ilan_TrendRacing_3.51ME |
//              которые так или иначе влияли на ход мыслей в процессе создания       |      Light Edition      |
//                этого советника или просто временами поднимали настроение          |                         |
//=============================================================================================================|

// -----------  ... ввиду долгой и продолжительной работы над этой серией пора наверно начинать описание советника 
// заново....  если что то забыл - извиняйте ))   

// В данной сове имеем :

//                   ============== Основные характеристики ===================
// Советник работает со всеми типами обслуживания ДЦ.
// Лотэкспонента - геометрическая,      с фиксацией значения после указанного колена ( режим безотката).
// Пипстеп экспонента - геометрическая, с фиксацией значения после указанного колена ( режим безотката).
// Наличие постоянного настраиваемого пипстепа с фиксацией значения после указанного колена ( режим безотката).
// Возможность временного отключения барконтроля ( после удачной постановки колена он восстановится автоматом ). 
// Перекрытие ордеров в указанном процентном соотношении от указанного ордера.
// Полное сопровождение  двух  разнонаправленных  серий,  имеющих разные мейджик номера одновременно, с разделением
// всех расчетных функций.
// Использование встроенных индикаторов MA, CCI, ADX, AC в практически любй комбинации, с выводом основных настроек
// во внешние переменные ( остальные настройки можно изменить в коде ).
// Использование пользовательского  индикатора MAonRCI с  выводом основных настроек во внешние переменные ( осталь -
// ные настройки в коде ).

//                   ===================  Удобства   ===========================
// Свободное вмешательство в работу одной из серий, при условии, если  ее мейджик выставлен равным нулю ( Автомати -
// ческий контроль ручного удаления и постановки ордеров ( по тикам, через ГП советника )).
// Автоматический контроль ручного удаления ордеров, если мейджик серии отличен от нуля ( по тикам, ГП советника ).
// Наличие отображения уровня безубытка по всем ордерам на инструменте.
// Автоматическое отключение барконтроля при ошибке выставления колена ввиду реквоты.
// Авторасчет лотэкспонеты, авторасчет и индикация спреда, авторасчет стопов ДЦ по инструменту с блокированием не  -
// верно выставленных ТП и СЛ ( СЛ не используется, сделано для совмещения функций ).
// Автопересчет на пятизнак, индикация цены следующего колена по бай и селл серии.
// Автоочистка графика при деинициализации советника ( из Иллана - стоповика от Босса).
// Остановка советника с уведомлением пользователя в виде диалогового окна в случаях недопустимых настроек и в слу -
// чае требования закрытия всех ордеров. 
// Прекращение выставления советником новых ордеров при ограниченном пользователем уровне просадки в % от депозита.

//                   ================= новое в версии ===========================
// Оптимизирована чать логики советника для ускорения работы с тестером стратегий.
// Переписана процедура закрытия ордеров по требованию пользователя ввиду возможных ошибок при реквотах.
// Переписана процедура перекрытия ордеров в виду возможных ошибок при реквотах.
// Добавлен вход по индикатору MAonRSI, с отключением всех остальных индикаторов кроме АС.
// Добавлен дроп просевшей серии по значению в текущей валюте ( по пожеланиям трейдеров ). ( Без остановки советника ).

//                  ================ Для заинтересованных ========================
// Во всех процедурах закрытия и перекрытия ордеров цикл for заменен на цикл while, немного сложнее, но много надежнее
// все это сделано в свете реквот и подобных неподобств  )))...

#property copyright "ZzLiSzZ, MT5 Forum"
#property link      "oookompas2010@rambler.ru"
#include <stderror.mqh>
#include <stdlib.mqh>
#include <WinUser32.mqh>
//==============================================================================================================
extern string  Set1           = "======  Общие настройки  =====";
extern double  Lots           = 0.01;                         // величина первого лота
extern double  LotExponent    = 1.4;                          // знаменатель геометрической прогрессии роста объема лота
extern double  TakeProfit     = 8.0;                          // профит в пунктах
double         StopLoss       = 0;                            // лось в пунктах
extern double  slip           = 5;                            // проскальзывание цены ( борьба с реквотой ) ))
extern int     MaxTrades      = 30;                           // количество максимально открываемых ордеров ( счет от "0" )
extern int     MagicNumberB   = 777;                          // идентификатор, позволяющий отличать "свои" ордера по серии БАЙ
extern int     MagicNumberS   = 555;                          // идентификатор, позволяющий отличать "свои" ордера по серии СЕЛЛ
extern string  Set2           = "===== Настройки  пипстепа =====";
extern string  Set3           = " на пятизнак перевод автоматом ";
extern double  FirstPipStep   = 6.0;                          // начальный пипстеп
extern double  LongPipStep    = 100;                          // пипстеп, используемый при длинных безоткатах, при включенном EconomProfil начиная от FirstEconomOrd
extern double  PipStepExponent= 1.8;                          // во сколько увеличивается шаг в зависимости от номера ордера
extern string  Set4           = "== Дополнительные настройки  ==";
extern bool    info           = True;                         // отображение информации
extern bool    Zero           = True;                         // отображение уровня безубытка всех ордеров по инструменту
extern bool    BarControl     = True;                         // отключение побарного контроля
extern bool    debug          = False;                        // отладка
extern bool    EconomProfil   = False;                        // режим для длительных безоткатов 
extern int     FirstEconomOrd = 4;                            // ордер, с которого включается экономичный режим. например, если 4, то 4, 5, 6 ... ордера имеют 1 и тот же лот.
extern bool    Overlapping    = True;                         // включение режима перекрытия последним ордером указанного ордера
extern int     LeadingOrder   = 4;                            // с какого колена работает перекрытие.
extern int     FLPersent      = 7;                            // процент перекрытия 

//            Tral
extern bool   UseTrailingStop = true;
extern double TrailTP = 5;          // ТР, который будет траллиться     
extern double TrailDist = 5;        // расстояние от цены, на котором тралится ТР
extern int    AutoTakeProfit = 50;  // ТР при TrailingStop

//**********************
extern string v1 = "Режим LastTP";
extern bool   SeparateLastTP = true;
extern int    LastTP  = 5;         //ТР последнего ордера. Если "0", то LastTP = TakeProfit
extern int    LastTPNo = 3;         //№ колена, с которого начинает работать LastTP
int ExcludeTicketB=0;
int ExcludeTicketS=0;

extern string  MASet          = "======== Параметры  МА ========";   
int            MATimeFrame    = 0;                            // 0 (ноль)- Период текущего графика; 1 - PERIOD_M1; 5 - PERIOD_M5; 15 - PERIOD_M15; 30 - PERIOD_M30;  
                                                              // 60 - PERIOD_H1; 240 - PERIOD_H4; 1440 - PERIOD_D1; 10080 - PERIOD_W1; 43200 - PERIOD_MN1 
extern int     MA1_Period     = 7;                            // период быстрой МА
int            MA1_Shift      = 0;                            // метод  быстрой МА
extern int     MA2_Period     = 21;                           // период медленной МА
int            MA2_Shift      = 0;                            // метод  медленной МА
extern string  DeltaSet       = "== Зона неуверенного сигнала ==";
extern string  Comm1          = " разность МАшек в пипсах, 0 - 5";
extern double  DelFX          = 2;                            // сколько пунктов МА "не чувствует"
int            MA_sf          = 1;                            // номер "пред-бара" для учета направления тренда
extern string  Comm5          = "=== Наличие контроля по CCI ===";
extern bool    CCI_kontr      = True;                         // включение контроля CCI
extern double  CCI_Lim        = 170.0;                        // отсечка по уровням CCI
int            CCI_tf         = 0;                            // тайм фрейм CCI 0 - текущий
int            CCI_Per        = 14;                           // период CCI
int            CCI_sf         = 1;                            // номер "пред-бара" для учета тенденции CCI
extern string  Comm6          = "= Настройка подтверждения тренда =";
extern string  Comm7          = "===========   по ADX    ==========";
extern bool    ADX_kontr      = False;  
int            TF_ADX         = 0;                            // таймфрейм ADX, 0 - текущий
int            Per_ADX        = 7;                            // период ADX
extern double  ADX_Trend      = 25;                           // показатель основной линии ADX 
int            PriceADX       = 0;                            // 0 - цена закрытия, 1 - цена открытия
int            Sh_ADX         = 1;                            // номер "пред-бара" для учета тенденции ADX ( не может быть 0! )
extern string  Comm8          = "=== Включение входа по MAonRSI ===";
extern string  Comm9          = " (остальные индикаторы отключатся)";
extern bool    MAonRSI        = False;
int            MAonRSI_TimeFr = 0;                            // ТФ индикатора MAonRSI ( по умолчанию - текущий )
extern int     RSI_Period     = 8;                            // период индикатора RSI
int            RSI_Metod      = 6;                            // метод расчета цены RSI
extern int     MA_Period      = 21;                           // период МА индикатора MAonRSI
int            MA_Metod       = 1;                            // метод расчета цены МА
double         Delta_MAonRSI  = 2.0;                          // зона нечувствительности индикатора ( 0 - 5 )
extern int     RSI_max        = 70;                           // верхняя отсечка RSI
extern int     RSI_min        = 30;                           // нижняя  отсечка RSI
extern string  Comm10         = "= Настройка отсечки флета по АС=";
extern double  AClim          = 0.0001;                       // отступ АС от нуля во флете для разрешения сигналов на открытие первого ордера
extern string  Comm11         = "== Баланс, закрытие, просадка ==";
extern bool    CloseAll       = False;                        // функция экстренного закрытия всех "своих" ордеров
extern double  TradeStop      = 0.0;                          // запрет открытия новых сделок, если отношение средства/баланс меньше указанного (0.1 - 10% и так далее.. )
extern bool    LL             = False;                        // включение фиксации убытка  по значению 
extern int     LossLevel      = 10;                           // уровень убытка в текущей валюте

int MA1_Price   = 0;             //0 - Цена закрытия;  1 - Цена открытия; 2 - Максимальная цена; 3 - Минимальная цена;
                                 //4 - Средняя цена; 5 - Типичная цена; 6 Взвешенная цена закрытия.
                                          
int MA1_Method  = 0;             //0 - Простое скользящее среднее; 1 - Экспоненциальное скользящее среднее; 
                                 //2 - Сглаженное скользящее среднее; 3 - Линейно-взвешенное скользящее среднее.
int MA2_Price   = 0;
int MA2_Method  = 0;
//==============================================================================================================
double StopperB    = 0.0, StopperS = 0.0;
double CCI_Del, ADX_Del, STOP_L, Lprofit, Profit_B, Profit_S, Cprofit;
double LastBuyPrice, LastSellPrice, PipStepB, PipStepS, iLotsB, iLotsS, SL,TP, PrevEquity, CCI_min, CCI_max, ACmax, ACmin, Dig;
double CProfit = 0, CProfit2 = 0, LProfit = 0, PrcCL1 = 0, PrcCL = 0;

bool flagB, flagS;
bool LongTrade = False, ShortTrade = False, NewOrdersPlacedB = True, NewOrdersPlacedS = True;

int timeprev = 0, NumOfTradesB = 0, NumOfTradesS = 0, cnt = 0, DCCoef = 10000;
int ticket, expiration, totalB, totalS, total, CheckTotalS, CheckTotalB, lotdecimal, Error, Lpos, StopSet, Cpos;
string title="Советник остановлен", msg="";
string EAName = "Ilan_TrendRacing_3.51ME";
string txt1, txt2, txt3, txt4, txt5, txt6;
//==============================================================================================================
int init() {
   StopSet = 0;
   NewOrdersPlacedB = True;              // пересчитываем по включении ТП всех ордеров согласно текущей настройке
   NewOrdersPlacedS = True;
   ACmax = AClim;
   ACmin = (-AClim);
   CCI_max = CCI_Lim;
   CCI_min = (-CCI_Lim);
   Dig = MarketInfo(Symbol(), MODE_DIGITS);
   lotdecimal = MathLog(1/MarketInfo(Symbol(),MODE_LOTSTEP))/MathLog(10);
   if (debug) Print ("Точность ДЦ ", Dig);
   if (info) {
      ObjectCreate ("Lable1",OBJ_LABEL,0,0,1.0);
      ObjectSet    ("Lable1", OBJPROP_CORNER, 2);
      ObjectSet    ("Lable1", OBJPROP_XDISTANCE, 23);
      ObjectSet    ("Lable1", OBJPROP_YDISTANCE, 11);
      txt1="Trend Racing 3.51ME";
      ObjectSetText("Lable1",txt1,20,"Bauhaus 93",FireBrick);
   
      ObjectCreate ("Lable4",OBJ_LABEL,0,0,1.0);
      ObjectSet    ("Lable4", OBJPROP_CORNER, 2);
      ObjectSet    ("Lable4", OBJPROP_XDISTANCE, 250);
      ObjectSet    ("Lable4", OBJPROP_YDISTANCE, 8);
      txt4="    LiS";
      ObjectSetText("Lable4",txt4,20,"Vladimir Script",AliceBlue);
   }
    
    if ((DelFX < 1)||(DelFX > 5))   StopSet = 1;
    if ((MA_sf > 5)||(MA_sf <= 0))  StopSet = 2;
    if (MA1_Period >= MA2_Period)   StopSet = 3;
    
    int DcD = 1;
    if((Digits==5)||(Digits==3)) DcD = 10;   
       FirstPipStep  = FirstPipStep  * DcD;
       LongPipStep   = LongPipStep   * DcD;
       TakeProfit    = TakeProfit    * DcD;
       StopLoss      = StopLoss      * DcD;
       slip          = slip          * DcD;
      AutoTakeProfit *= DcD;
      TrailTP    *= DcD;              
      TrailDist  *= DcD;
      LastTP *= DcD;
//*****************Увеличение ТР при включении тралла
   if (UseTrailingStop) TakeProfit = AutoTakeProfit;
   //*****************выбор ТР для последнего колена
   if (SeparateLastTP && LastTP == 0) LastTP=TakeProfit;
      
    if(Digits==3)DCCoef = 500;
    if(Digits==2)DCCoef = 50;
    return (0);
}
int deinit() {
    ObjectDelete("Lable1");
    ObjectDelete("Lable2");
    ObjectDelete("Lable3");
    ObjectDelete("Lable4");
    ObjectDelete("Lable5");
    ObjectDelete("Zero");
    ObjectDelete("LableB");
    ObjectDelete("LableS");
   return (0);
}
//================================================================================================================
//============================================= S T A R T ========================================================
int start()
{  
   if (UseTrailingStop) 
   {
      Trailing (TrailDist, TrailTP, MagicNumberB);
      Trailing (TrailDist, TrailTP, MagicNumberS);
   }   

   STOP_L = NormalizeDouble(MarketInfo(Symbol(),MODE_STOPLEVEL),Dig);
   if (debug) Print ("Текущий уровень стопов ДЦ по данному инструменту ", STOP_L);
   if (TakeProfit < STOP_L)                    StopSet = 4; 
   if ((StopLoss !=0) && (StopLoss < STOP_L )) StopSet = 5; 

//============================================   баланс  ==========================================================   
   double Balans   = NormalizeDouble(AccountBalance(),Dig);
   double Sredstva = NormalizeDouble(AccountEquity() ,Dig); 
   double KontrSr  = NormalizeDouble(Sredstva/Balans,1);
   if (KontrSr <= TradeStop) StopSet = 6;

//========================================= если !!! ЗАКРЫТЬ ВСЕ  !!!  ===========================================   
   if (CloseAll) StopSet = CloseThisSymbolAll();
//================================= фиксация убытка по просадке в текущей валюте =================================
   if (LL) {                                  
      double LB = ProfitB(); 
      double LS = ProfitS();
      double L  = (- LossLevel);
      if (LB < L) CloseThisSymbolBUY ();
      if (LS < L) CloseThisSymbolSELL();
   }   
//====================================  пересчет основных позиций ================================================
   total  = CountTrades();
   totalB = CountTradesB();
   totalS = CountTradesS();
   if (CheckTotalB != totalB) NewOrdersPlacedB = True;
   if (CheckTotalS != totalS) NewOrdersPlacedS = True;
   if (NewOrdersPlacedB) RecalculationB();
   if (NewOrdersPlacedS) RecalculationS();
   PipStepB = NormalizeDouble(FirstPipStep * MathPow(PipStepExponent, totalB), 0);
   PipStepS = NormalizeDouble(FirstPipStep * MathPow(PipStepExponent, totalS), 0);
   if (debug) {
      Print("Текущий пипстеп бай ",  PipStepB);
      Print("Текущий пипстеп селл ", PipStepS);
   }   
   iLotsB = NormalizeDouble(Lots, lotdecimal); 
   iLotsS = NormalizeDouble(Lots, lotdecimal); 
   NumOfTradesB = totalB;
   NumOfTradesS = totalS;
// ============================== пересчет основных позиций для эконом режима ==================================
   if (EconomProfil) {
      if (totalB >= FirstEconomOrd) {
         PipStepB = LongPipStep;
         NumOfTradesB = FirstEconomOrd-1;
      }
      if (totalS >= FirstEconomOrd) {
         PipStepS = LongPipStep;
         NumOfTradesS = FirstEconomOrd-1;
      }   
   }   
//===================================  можно ли торговать дальше  ==============================================
   if (total > 0 && total <= MaxTrades) {
      LastBuyPrice  = FindLastBuyPrice();
      LastSellPrice = FindLastSellPrice();
   }
   if ((totalB + totalS) >= MaxTrades)  { 
      Print ("Достигнуто максимально разрешенное число сделок, "); 
      Print ("новые колена открываться не будут, сопровождение серий продолжается."); 
   }   
   if (totalB < 1) LongTrade = FALSE;
   if (totalS < 1) ShortTrade = FALSE;

//========================================== модуль остановки советника ========================================== 

   if ((StopSet==1)||(StopSet==2)||(StopSet==3)||(StopSet==4)||(StopSet==5)||(StopSet==6)||(StopSet==7)) {
      if (StopSet == 1) msg=" Выберите верное значение DelFX,DelFX   "+"\n"+" может быть задан от 1 до 5.   ";
      if (StopSet == 2) msg=" Неверно задана величина бара для       "+"\n"+" расчета скорости тренда по МА "+"\n"+
                            " задайте значение MA_sf от 0 до 5.";
      if (StopSet == 3) msg=" Неверно заданы параметры МА, МА_1Period"+"\n"+" не может быть больше либо равен MA2_Period.";
      if (StopSet == 4) msg=" Тейкпрофит не может быть выставлен     "+"\n"+" меньше стоп уровней ДЦ.";  
      if (StopSet == 5) msg=" Стоплосс не может быть выставлен       "+"\n"+" меньше стоп уровней ДЦ.";  
      if (StopSet == 6) msg=" Советник остановлен модулем контроля   "+"\n"+" средств. ";  
      if (StopSet == 7) msg=" Советник остановлен, все ордера закрыты"+"\n"+" по требованию пользователя. "; 
      int ret = MessageBox(msg,title,MB_OK|MB_ICONSTOP); 
      if (ret == IDOK) {
      Print ("Советник остановлен пользователем для перенастройки"); 
      return (0); 
      }   
   }

//========================================== определение текущих данных ==========================================    
   int TPControlS = OrderTake_ProfitS();
   int TPControlB = OrderTake_ProfitB();
   if (TPControlS == 1 ) NewOrdersPlacedS = True;
   if (TPControlB == 1 ) NewOrdersPlacedB = True;
   int SignalMA  = 0;
   int SignalCCI = 0;
   int SignalADX = 0; 
   int SignalRSI = 0;
   int SignalAC  = 0;
   int Signal = 0;
//============================================= модуль входа ======================================================  
   if (MAonRSI) { 
      CCI_kontr = False; ADX_kontr = False; 
      SignalRSI = MAonRSI();  SignalAC  = AC();                                   // отключено все, кроме MAonRSI и АС
      if ((SignalRSI == 1) && (SignalAC ==1)) Signal =  1;                        // разрешили БАЯ
      if ((SignalRSI ==-1) && (SignalAC ==1)) Signal = -1;                        // разрешили СЕЛА
   }   
   if ((!CCI_kontr) && (!ADX_kontr)&& (!MAonRSI)) {                               // CCI контроль отключен, ADX контроль отключен
      SignalMA  = MA(); SignalAC  = AC();
      if ((SignalMA == 1) && (SignalAC ==1)) Signal =  1;                         // разрешили БАЯ
      if ((SignalMA ==-1) && (SignalAC ==1)) Signal = -1;                         // разрешили СЕЛА
   } 
   if ((CCI_kontr) && (!ADX_kontr))  {                                            // CCI контроль включен ADX контроль отключен
      SignalMA  = MA(); SignalCCI = CCI(); SignalAC  = AC();
      if ((SignalMA == 1) && (SignalCCI == 1) && (SignalAC ==1)) Signal =  1;     // разрешили БАЯ
      if ((SignalMA ==-1) && (SignalCCI ==-1) && (SignalAC ==1)) Signal = -1;     // разрешили СЕЛА
   }
   if ((!CCI_kontr) && (ADX_kontr))  {                                            // CCI контроль отключен, ADX контроль включен
      SignalMA  = MA(); SignalAC  = AC(); SignalADX = ADX();
      if ((SignalMA == 1) && (SignalAC ==1) && (SignalADX ==1))  Signal =  1;     // разрешили БАЯ
      if ((SignalMA ==-1) && (SignalAC ==1) && (SignalADX ==1))  Signal = -1;     // разрешили СЕЛА
   }   
   if ((CCI_kontr) && (ADX_kontr))   {
      SignalMA  = MA(); SignalCCI = CCI(); SignalAC  = AC(); SignalADX = ADX();
      if ((SignalMA == 1) && (SignalCCI == 1) && (SignalAC ==1) && (SignalADX ==1)) Signal =  1;     // разрешили БАЯ
      if ((SignalMA ==-1) && (SignalCCI ==-1) && (SignalAC ==1) && (SignalADX ==1)) Signal = -1;     // разрешили СЕЛА
   }
   
//=============================================== ИНФО ============================================================
    if (info) {
    ObjectDelete("Lable2");
    ObjectCreate("Lable2",OBJ_LABEL,0,0,1.0);
    ObjectSet   ("Lable2", OBJPROP_CORNER, 3);
    ObjectSet   ("Lable2", OBJPROP_XDISTANCE, 33);
    ObjectSet   ("Lable2", OBJPROP_YDISTANCE, 11);
      if (Signal ==  1)txt2="Maneuver  BUY";
      if (Signal == -1)txt2="Maneuver SELL";
      if (Signal ==  0)txt2="Pit stop...";
    ObjectSetText("Lable2",txt2,14,"Fixedsys",FireBrick);
    ObjectDelete ("Lable3");
    ObjectCreate ("Lable3",OBJ_LABEL,0,0,1.0);
    ObjectSet    ("Lable3", OBJPROP_CORNER, 0);
    ObjectSet    ("Lable3", OBJPROP_XDISTANCE, 23);
    ObjectSet    ("Lable3", OBJPROP_YDISTANCE, 20);
    txt3= DoubleToStr (MarketInfo(Symbol(), MODE_SPREAD),0);
    ObjectSetText("Lable3","Текущий спред "+txt3+"",14,"Fixedsys",FireBrick);
    }
//=========================================== ИНФО ПИПСТЕП ======================================================
   if (info) {
      txt5 = DoubleToStr ((LastBuyPrice  - PipStepB * Point), Dig);
      txt6 = DoubleToStr ((LastSellPrice + PipStepS * Point), Dig);
      if (!LongTrade)  txt5 = "--"; 
      if (!ShortTrade) txt6 = "--"; 
      ObjectDelete ("LableB");
      ObjectCreate ("LableB",OBJ_LABEL,0,0,1.0);
      ObjectSet    ("LableB", OBJPROP_CORNER, 0);
      ObjectSet    ("LableB", OBJPROP_XDISTANCE, 23);
      ObjectSet    ("LableB", OBJPROP_YDISTANCE, 40);
      ObjectSetText("LableB","След. колено Buy  "+txt5+"",14,"Fixedsys",Blue);  
         
//                         --------------------------------------------

      ObjectDelete ("LableS");
      ObjectCreate ("LableS",OBJ_LABEL,0,0,1.0);
      ObjectSet    ("LableS", OBJPROP_CORNER, 0);
      ObjectSet    ("LableS", OBJPROP_XDISTANCE, 23);
      ObjectSet    ("LableS", OBJPROP_YDISTANCE, 60);
      ObjectSetText("LableS","След. колено Sell "+txt6+"",14,"Fixedsys",FireBrick);  
   }   
//========================================== ИНФО ЗЕРО =========================================================
   if (Zero) {
      double ZeroLevel = Zerro();
      ObjectDelete("Zero");
      ObjectCreate("Zero", OBJ_HLINE, 0, 0,ZeroLevel);
      ObjectSet   ("Zero", OBJPROP_COLOR, DodgerBlue);
      ObjectSet   ("Zero", OBJPROP_WIDTH, 1);
      ObjectSet   ("Zero", OBJPROP_RAY, False);
      }    
//====================================    перекрываем ордера    ================================================
  if ((totalB >= LeadingOrder) || (totalS >= LeadingOrder)) {
     if(Overlapping) {
       Lpos = 0; Cpos = 0; Lprofit = 0; Cprofit = 0;
       Lpos = LidingProfitOrder();
       Cpos = CloseProfitOrder();
       if (debug) {
          Print ("Наибольший профит ", Lprofit,"  ", Lpos);
          Print ("Наименьший профит ", Cprofit,"  ", Cpos);
       }    
       Cprofit  = MathAbs(Cprofit);
       PrcCL1 =  (Cprofit + Cprofit * FLPersent/100);
       if(Lprofit > PrcCL1) {
          CloseSelectOrder(); 
          
        }
     }  
  }  
//===================================  определяем направление серии  =============================================   
   if  (total == 0) {
       flagB = False;
       flagS = False;
   }    
   for (cnt = OrdersTotal() - 1; cnt >= 0; cnt--) {
       if (OrderSelect(cnt, SELECT_BY_POS, MODE_TRADES)) {
          if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumberB) {
          if (OrderType() == OP_BUY) {
             LongTrade = TRUE;
             break;
          }
       }
       if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumberS) {
          if (OrderType() == OP_SELL) {
             ShortTrade = TRUE;
             break;
          }
       }
     } 
   }

//=========================================== контроль ордеров =================================================
   CheckTotalB = totalB;  
   CheckTotalS = totalS;
//===================================  побарный контроль  ======================================================
   if ((BarControl)&&(timeprev == Time[0])) return (0);
   timeprev = Time[0];
//=========================================== покупаем колено ==================================================
   if (total > 0 && total <= MaxTrades) {
      if (LongTrade) {
         if ((NormalizeDouble((LastBuyPrice - Ask)/Point, 0)) >= PipStepB) {
            iLotsB = NormalizeDouble(Lots * MathPow(LotExponent, NumOfTradesB), lotdecimal);
         
            ticket = OPENORDER ("Buy");
            if (ticket < 0) {
               BarControl  = False;
               return (0);
            }
            NewOrdersPlacedB = True;
            BarControl  = True;
         }
      }
   }   
//========================================== продаем колено ===================================================
      
   if (total > 0 && total <= MaxTrades) {   
      if (ShortTrade) {
         if ((NormalizeDouble((Bid - LastSellPrice) / Point, 0))>=PipStepS ) {
            iLotsS = NormalizeDouble(Lots * MathPow(LotExponent, NumOfTradesS), lotdecimal);
         
            ticket = OPENORDER ("Sell");
            if (ticket < 0) {
               BarControl  = False;
               return (0);
            }
            NewOrdersPlacedS = True;
            BarControl = True;
         }
      }
   }     
//================================================================================================================
     if ((Signal == 0 ) && (total ==0 )) {
        if (debug)      {
           Print ("Нет сигнала на открытие позиции ");
           return (0);                                    // ниче не покупаем... ждем..
        }
     }      
//============================================== покупаем 1 ордер ==============================================
     if ((Signal == 1) && (totalB == 0)) {  
                       
          ticket = OPENORDER ("Buy");
          if (ticket < 0) {
          BarControl  = False;
          return (0);
          }
          BarControl = True;
     }
//=============================================== продаем 1 ордер ================================================     
     if ((Signal == -1)&&(totalS == 0)) {                       
                                 
        ticket = OPENORDER ("Sell");
        if (ticket < 0) {
           BarControl  = False;
           return (0);
        }
        BarControl = True;
     }    

  return (0);
}
//===================================  пересчитываем ТП  БАЙ ордеров  =========================================

void RecalculationB() {
 double AveragePriceB = 0;
 double PriceTargetB  = 0;
 double CountB  = 0;
   for (cnt = OrdersTotal() - 1; cnt >= 0; cnt--) {
       if (OrderSelect(cnt, SELECT_BY_POS, MODE_TRADES))  {
          if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumberB) {
             if (OrderType() == OP_BUY ) {
                AveragePriceB += OrderOpenPrice() * OrderLots();
                CountB += OrderLots();
             }
          }
       }  
   }
   if (totalB > 0) AveragePriceB = NormalizeDouble(AveragePriceB / CountB, Dig);
   if (NewOrdersPlacedB) {
      for (cnt = OrdersTotal() - 1; cnt >= 0; cnt--) {
          if (OrderSelect(cnt, SELECT_BY_POS, MODE_TRADES)) {
             if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumberB) {
                if (OrderType() == OP_BUY) {
                   PriceTargetB = AveragePriceB + TakeProfit * Point;
                   StopperB = AveragePriceB - StopLoss * Point;
                   flagB = TRUE;
                }
             }
          }
      }
   }  
   if (NewOrdersPlacedB) {
      if (flagB == TRUE) {
         for (cnt = OrdersTotal() - 1; cnt >= 0; cnt--) {
             if (OrderSelect(cnt, SELECT_BY_POS, MODE_TRADES)) {        
                if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumberB) {
                   if (OrderType() == OP_BUY ) {
                      bool res;
                      if(SeparateLastTP && totalB >= LastTPNo && OrderTakeProfit() == 0.0)
                        res = OrderModify(OrderTicket(), OrderOpenPrice(), OrderStopLoss(), NormalizeDouble( OrderOpenPrice() + LastTP * Point, Dig), 0, Blue);
                      else
                        res = OrderModify(OrderTicket(), AveragePriceB, OrderStopLoss(), PriceTargetB, 0, Blue);
                      if(res)
                        NewOrdersPlacedB = FALSE;
                   }
                }
             }  
         }
      }
   }
 }

//===================================  пересчитываем ТП  СЕЛЛ ордеров  ========================================
void RecalculationS() {
   double AveragePriceS = 0;
   double PriceTargetS  = 0;
   double CountS  = 0;
   for (cnt = OrdersTotal() - 1; cnt >= 0; cnt--) {
     if (OrderSelect(cnt, SELECT_BY_POS, MODE_TRADES))  {
       if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumberS) {
          if (OrderType() == OP_SELL ) {
             AveragePriceS += OrderOpenPrice() * OrderLots();
             CountS += OrderLots();
           }
        }
      }  
    }
   if (totalS > 0) AveragePriceS = NormalizeDouble(AveragePriceS / CountS, Dig);
   if (NewOrdersPlacedS) {
      for (cnt = OrdersTotal() - 1; cnt >= 0; cnt--) {
          if (OrderSelect(cnt, SELECT_BY_POS, MODE_TRADES)) {
             if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumberS) {
                if (OrderType() == OP_SELL) {
                   PriceTargetS = AveragePriceS - TakeProfit * Point;
                   StopperS = AveragePriceS + StopLoss * Point;
                   flagS = TRUE; 
                }
             }
          }
      }
   }  
   if (NewOrdersPlacedS) {
      if (flagS == TRUE) {
         for (cnt = OrdersTotal() - 1; cnt >= 0; cnt--) {
            if (OrderSelect(cnt, SELECT_BY_POS, MODE_TRADES)) {        
               if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumberS) {
                  if (OrderType() == OP_SELL) {
                     bool res;
                     if(SeparateLastTP && totalS >= LastTPNo && OrderTakeProfit() == 0.0)
                        res = OrderModify(OrderTicket(), OrderOpenPrice(), OrderStopLoss(),  NormalizeDouble( OrderOpenPrice() - LastTP * Point, Dig), 0, Red);
                     else
                        res = OrderModify(OrderTicket(), AveragePriceS, OrderStopLoss(), PriceTargetS, 0, Red);
                     if(res)
                        NewOrdersPlacedS = FALSE;
                 }
               }
            }  
         }
      }
   }
 }
//============================   подсчитываем ВСЕ ордера   ====================================================
int CountTrades() {
   int count = 0;
   for (int trade = OrdersTotal() - 1; trade >= 0; trade--) {
       if (OrderSelect(trade, SELECT_BY_POS, MODE_TRADES))  {
         if ((OrderSymbol() == Symbol()) && ((OrderMagicNumber() == MagicNumberB) || (OrderMagicNumber() == MagicNumberS))){
         if (OrderType() == OP_SELL || OrderType() == OP_BUY) { count++;} }
        }
     }
   return (count);
}

//============================   подсчитываем БАЙ ордера   ====================================================
int CountTradesB() {
   int count = 0;
   for (int trade = OrdersTotal() - 1; trade >= 0; trade--) {
       if (OrderSelect(trade, SELECT_BY_POS, MODE_TRADES))  {
         if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumberB){
         if (OrderType() == OP_BUY) { count++;} }
        }
     }
   return (count);
}   
//============================   подсчитываем СЕЛЛ ордера   ====================================================
int CountTradesS() {
   int count = 0;
   for (int trade = OrdersTotal() - 1; trade >= 0; trade--) {
       if (OrderSelect(trade, SELECT_BY_POS, MODE_TRADES))  {
         if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumberS){
         if (OrderType() == OP_SELL ) { count++;} }
        }
     }
   return (count);
}   


//========================================   закрытие всех  маркет ордеров  ====================================
int CloseThisSymbolAll() {
   
   int Result = 0;
   int error  = 0;
   int trade  = 0;
       while (OrdersTotal() > 0) {
             RefreshRates();
             trade = OrdersTotal()-1;
             OrderSelect(trade, SELECT_BY_POS, MODE_TRADES);   
             if (OrderSymbol() == Symbol()) {
                if (OrderType() == OP_SELL) { 
                   error = OrderClose(OrderTicket(), OrderLots(), NormalizeDouble(Ask, Dig), slip, Red );
                   if (error == -1) ShowERROR(error,0,0);
                }   
                Sleep(500);
                if (OrderType() == OP_BUY)  {
                   error =  OrderClose(OrderTicket(), OrderLots(), NormalizeDouble(Bid, Dig), slip, Blue);
                   if (error == -1) ShowERROR(error,0,0);
                }   
                Sleep(500);
             }   
       }
   if (OrdersTotal() == 0) Result = 7;
   if (debug) Print ("Ордера по инструменту успешно закрыты.");
   return (Result);
}
//========================================   закрытие бай серии   ============================================
int CloseThisSymbolBUY() {
   
   int Result = 0;
   int error  = 0;
   int trade  = OrdersTotal()-1;
   int i = CountTradesB();
       while (i > 0) {
             RefreshRates();
             OrderSelect(trade, SELECT_BY_POS, MODE_TRADES);   
             if ((OrderSymbol() == Symbol()) && (OrderMagicNumber() == MagicNumberB)) {
                if (OrderType() == OP_BUY)  {
                   error =  OrderClose(OrderTicket(), OrderLots(), NormalizeDouble(Bid, Dig), slip, Blue);
                   if (error == -1) ShowERROR(error,0,0);
                }   
                Sleep(500);
             }
             trade --;  
             i = CountTradesB(); 
       }
   if (i == 0) Result = 1;
   Print ("Серия БАЙ закрыта по требованию пользователя.");
   return (Result);
}

//========================================   закрытие СЕЛЛ серии   ============================================
int CloseThisSymbolSELL() {
   
   int Result = 0;
   int error  = 0;
   int trade  = OrdersTotal()-1;
   int i = CountTradesS();
       while (i > 0) {
             RefreshRates();
             OrderSelect(trade, SELECT_BY_POS, MODE_TRADES);   
             if ((OrderSymbol() == Symbol()) && (OrderMagicNumber() == MagicNumberS))  {
                if (OrderType() == OP_SELL)  {
                   error =  OrderClose(OrderTicket(), OrderLots(), NormalizeDouble(Ask, Dig), slip, Red);
                   if (error == -1) ShowERROR(error,0,0);
                }   
                Sleep(500);
             }
             trade --;
             i = CountTradesS();   
       }
   if (i == 0) Result = 1;
   Print ("Серия СЕЛЛ закрыта по требованию пользователя.");
   return (Result);
}

//====================================== выставление ордеров ===================================================
int OPENORDER(string ord)
{
   int error;
 
   if (ord=="Buy"   ) error=OrderSend(Symbol(),OP_BUY,  iLotsB, NormalizeDouble (Ask,Dig), slip, 0, 0, "Ilan_TrendRacing_3.51ME",MagicNumberB,5,Blue);
   if (ord=="Sell"  ) error=OrderSend(Symbol(),OP_SELL, iLotsS, NormalizeDouble (Bid,Dig), slip, 0, 0, "Ilan_TrendRacing_3.51ME",MagicNumberS,5,DeepPink);
   if (error==-1)   ShowERROR(error,0,0);
return (error);
}                  
//====================================== ошибки при открытии ордеров ===========================================
void ShowERROR(int Ticket,double SL,double TP)
{
   int err=GetLastError();
   switch ( err )
   {                  
      case 1:                                            return;
      case 2:    Print("Нет связи с торговым сервером ",                           Ticket," ",Symbol());return;
      case 3:    Print("Недопустимое ДЦ время ликвидации отложки ",                Ticket," ",Symbol());return;
      case 129:  Print("Неправильная цена ",                                       Ticket," ",Symbol());return;
      case 130:  Print("Близкие стопы Ticket ",                                    Ticket," ",Symbol());return;
      case 131:  Print("Неправильный объем ",                                      Ticket," ",Symbol());return;
      case 134:  Print("Недостаточно денег ",                                      Ticket," ",Symbol());return;
      case 136:  Print("Нет цен ... ",                                             Ticket," ",Symbol());return;
      case 138:  Print("Цена устарела ",                                           Ticket," ",Symbol());return;
      case 146:  Print("Подсистема торговли занята ",                              Ticket," ",Symbol());return;
      case 148:  Print("Превышен лимит количества ордеров",                        Ticket," ",Symbol());return;
      case 147:  Print("Использование даты истечения ордера запрещено брокером",   Ticket," ",Symbol());return;
      case 4107: Print("Неправильный параметр цены для торговой функции",          Ticket," ",Symbol());return;
      case 4109: Print("Советнику запрещено торговать",                            Ticket," ",Symbol());return;
      default:   Print("Ошибка  " ,err,"   Ticket ",        Ticket," ",Symbol());return;
   }
}

//==================================  расчет цены покупки ========================================================
double FindLastBuyPrice() {
   double oldorderopenprice;
   int oldticketnumber;
   double unused = 0;
   int ticketnumber = 0;
   for (int cnt = OrdersTotal() - 1; cnt >= 0; cnt--) {
      if (OrderSelect(cnt, SELECT_BY_POS, MODE_TRADES)) {
         if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumberB && OrderType() == OP_BUY) {
         oldticketnumber = OrderTicket();
         if (oldticketnumber > ticketnumber) {
            oldorderopenprice = OrderOpenPrice();
            unused = oldorderopenprice;
            ticketnumber = oldticketnumber;
         }
       }
     } 
   }
   return (oldorderopenprice);
}

//==================================  расчет цены продажи ======================================================
double FindLastSellPrice() {
   double oldorderopenprice;
   int oldticketnumber;
   double unused = 0;
   int ticketnumber = 0;
   for (int cnt = OrdersTotal() - 1; cnt >= 0; cnt--) {
     if ( OrderSelect(cnt, SELECT_BY_POS, MODE_TRADES)) {
       if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumberS && OrderType() == OP_SELL) {
          oldticketnumber = OrderTicket();
          if (oldticketnumber > ticketnumber) {
            oldorderopenprice = OrderOpenPrice();
            unused = oldorderopenprice;
            ticketnumber = oldticketnumber;
          }
        }
      } 
    }
   return (oldorderopenprice);
}

//======================================== ордер с наибольшим профитом  =======================================
int LidingProfitOrder() {
   double profit  = 0;
   int    Pos     = 0;
   for (int trade = OrdersTotal() - 1; trade >= 0; trade--) {
       if (OrderSelect(trade, SELECT_BY_POS, MODE_TRADES))  {
          if ((OrderSymbol() == Symbol()) && ((OrderMagicNumber() == MagicNumberB) || (OrderMagicNumber() == MagicNumberS))){
             if (OrderType() == OP_SELL || OrderType() == OP_BUY) { 
                profit = OrderProfit();
                Pos    = OrderTicket();
                if (profit > 0 && profit > Lprofit) {
                   Lprofit = profit;
                   Lpos    = Pos;
                }
             }
          }
       }   
   }    
   return (Lpos);
}
//======================================== ордер с наименьшим профитом  =======================================
int CloseProfitOrder() {
   double profit  = 0;
   int    Pos     = 0;
   for (int trade = OrdersTotal() - 1; trade >= 0; trade--) {
       if (OrderSelect(trade, SELECT_BY_POS, MODE_TRADES))  {
          if ((OrderSymbol() == Symbol()) && ((OrderMagicNumber() == MagicNumberB) || (OrderMagicNumber() == MagicNumberS))){
             if (OrderType() == OP_SELL || OrderType() == OP_BUY) { 
                profit = OrderProfit();
                Pos    = OrderTicket();
                if (profit < 0 && profit < Cprofit) {
                   Cprofit = profit;
                   Cpos    = Pos;
                }
             }
          }
       }   
   }    
   return (Cpos);
}
//========================================= проверка присутствия ТП ордеров SELL ===================================

int OrderTake_ProfitS() 
{
   int TPResult = 0;
   int count = 0;
   for (int trade = OrdersTotal() - 1; trade >= 0; trade--) {
       if (OrderSelect(trade, SELECT_BY_POS, MODE_TRADES))  {
          if ((OrderSymbol() == Symbol()) && ((OrderMagicNumber() == MagicNumberB) || (OrderMagicNumber() == MagicNumberS))){
             if (OrderType() == OP_SELL)  { 
                if (OrderTakeProfit() == 0) TPResult  = 1;
                count++;
             }
          }
       }
   }    
   return (TPResult);
}
//====================================== проверка присутствия ТП ордеров BUY =========================================
int OrderTake_ProfitB() 
{
   int TPResult = 0;
   int count = 0;
   for (int trade = OrdersTotal() - 1; trade >= 0; trade--) {
       if (OrderSelect(trade, SELECT_BY_POS, MODE_TRADES))  {
          if ((OrderSymbol() == Symbol()) && ((OrderMagicNumber() == MagicNumberB) || (OrderMagicNumber() == MagicNumberS))){
             if (OrderType() == OP_BUY)  { 
                if (OrderTakeProfit() == 0) TPResult  = 1;
                count++;
             }
          }
       }
   }    
   return (TPResult);
}

//======================================== вычисляем общий профит БАЙ серии  ======================================
double ProfitB() {
   Profit_B  = 0;
   double p  = 0;
   for (int trade = OrdersTotal() - 1; trade >= 0; trade--) {
       if (OrderSelect(trade, SELECT_BY_POS, MODE_TRADES))  {
          if ((OrderSymbol() == Symbol()) && (OrderMagicNumber() == MagicNumberB)) {
             if (OrderType() == OP_BUY) { 
                p = OrderProfit();
                Profit_B = (Profit_B + p);
             }
          }
       }   
   }    
   if (debug) Print ("Текущий профит БАЙ серии = ", Profit_B);
   return (Profit_B);
}
//======================================== вычисляем общий профит СЕЛЛ серии  ======================================
double ProfitS() {
   Profit_S  = 0;
   double p  = 0;
   for (int trade = OrdersTotal() - 1; trade >= 0; trade--) {
       if (OrderSelect(trade, SELECT_BY_POS, MODE_TRADES))  {
          if ((OrderSymbol() == Symbol()) && (OrderMagicNumber() == MagicNumberS)) {
             if (OrderType() == OP_SELL) { 
                p = OrderProfit();
                Profit_S = (Profit_S + p);
             }
          }
       }   
   }    
   if (debug) Print ("Текущий профит СЕЛЛ серии = ", Profit_S);
   return (Profit_S);
}
//==================================== перекрытие ордеров ===================================================
int CloseSelectOrder()
{
//                       ----------- выбранный (обычно первый )------------
  int error =  0;
  int error1 = 0;
  int Result = 0;
      while (error == 0) {
            RefreshRates();
            int i = OrderSelect(Cpos, SELECT_BY_TICKET, MODE_TRADES);
            if  (i != 1 ) {
                Print ("Ошибка! Невозможно выбрать ордер с наименьшим профитом. Выполнение перекрытия отменено.");
                return (0);
            }    
            if ((OrderSymbol() == Symbol()) && ((OrderMagicNumber() == MagicNumberB) || (OrderMagicNumber() == MagicNumberS))) {
               if (OrderType() == OP_BUY) {
                  error = (OrderClose(OrderTicket(), OrderLots(), NormalizeDouble(Bid, Dig), slip, Blue)); 
                  if (error == 1 ) {
                     Print ("Перекрываемый ордер закрыт успешно."); 
                     Sleep (500);   
                  } else {
                     Print ("Ошибка закрытия перекрываемого ордера, повторяем операцию. ");
                     ShowERROR(error,0,0);
                  } 
               }        
//                             -------------------------------------                
               if (OrderType() == OP_SELL) {
                  error = (OrderClose(OrderTicket(), OrderLots(), NormalizeDouble(Ask, Dig), slip, Red));
                  if (error == 1) {
                     Print ("Перекрываемый ордер закрыт успешно."); 
                     Sleep (500);   
                  } else {
                     Print ("Ошибка закрытия перекрываемого ордера, повторяем операцию. ");
                     ShowERROR(error,0,0);
                  }
               }
            }
      }     
       
//                       ---------------   последний  ----------------                            
       
      while (error1 == 0) {
            RefreshRates();
            i = OrderSelect(Lpos, SELECT_BY_TICKET, MODE_TRADES);
            if  (i != 1 ) {
                Print ("Ошибка! Невозможно выбрать ордер с наибольшим профитом. Выполнение перекрытия отменено.");
                return (0);
            }  
            if ((OrderSymbol() == Symbol()) && ((OrderMagicNumber() == MagicNumberB) || (OrderMagicNumber() == MagicNumberS))) {
               if (OrderType() == OP_BUY) {
                  error1 =  (OrderClose(OrderTicket(), OrderLots(), NormalizeDouble(Bid, Dig), slip, Blue));
                  if (error1 == 1) {
                     Print ("Лидирующий ордер закрыт успешно."); 
                     Sleep (500);   
                  } else {
                     Print ("Ошибка закрытия лидирующего ордера, повторяем операцию. ");
                     ShowERROR(error1,0,0);
                  }      
               } 
//                      ---------------------------------------------               
               if (OrderType() == OP_SELL) {
                  error1 = (OrderClose(OrderTicket(), OrderLots(), NormalizeDouble(Ask, Dig), slip, Red));
                  if (error1 == 1) {
                     Print ("Лидирующий ордер закрыт успешно"); 
                     Sleep (500);   
                  } else {
                     Print ("Ошибка закрытия лидирующего ордера, повторяем операцию. ");
                     ShowERROR(error1,0,0);
                  }
               }
            } 
      }
  Result = 1;
  return (Result);    
}  
//=================================   расчет нулевого уровня    =========================================
double Zerro()
{
 double BuyLots    = 0;
 double SellLots   = 0;
 double BuyProfit  = 0;
 double SellProfit = 0;
 double BuyLevel   = 0;
 double SellLevel  = 0;
 double Price      = 0;
 double ZeroLevel  = 0;
 double TickValue  = MarketInfo(Symbol(),MODE_TICKVALUE);
 double spread = NormalizeDouble(MarketInfo(Symbol(), MODE_SPREAD),Dig)*Point;
  
  for (int trade = OrdersTotal() - 1; trade >= 0; trade--) {
      if (OrderSelect(trade, SELECT_BY_POS, MODE_TRADES))  {
         if (OrderSymbol() == Symbol()) {
            if (OrderType()==OP_BUY)    {
               BuyLots   = BuyLots   + OrderLots();
               BuyProfit = BuyProfit + OrderProfit() + OrderCommission() + OrderSwap();
            }
            if (OrderType()==OP_SELL) {
               SellLots   = SellLots   + OrderLots();
               SellProfit = SellProfit + OrderProfit() + OrderCommission() + OrderSwap();
            }
         }
      }
  }
 
 if (BuyLots>0)  BuyLevel  = NormalizeDouble(Bid - (BuyProfit/(TickValue*BuyLots)*Point),Digits); 
 if (SellLots>0) SellLevel = NormalizeDouble(Ask + (SellProfit/(TickValue*SellLots)*Point),Digits); 
 if ((BuyLots-SellLots)>0) Price = NormalizeDouble(Bid + spread - ((BuyProfit+SellProfit)/(TickValue*(BuyLots-SellLots))*Point),Digits);
 if ((SellLots-BuyLots)>0) Price = NormalizeDouble(Ask - spread + ((BuyProfit+SellProfit)/(TickValue*(SellLots-BuyLots))*Point),Digits);
 if (Price >  0) ZeroLevel = Price;
 if (Price <= 0) ZeroLevel = 0;
 if (debug) Print ("Уровень безубытка для всех ордеров советника на символе = ", ZeroLevel); 
 return (ZeroLevel);
}

//============================== Расчет МА сигнала для постановки 1 ордера  =================================
int MA()
{
  int ResultMA = 0;                                                           // 0 - запрещаем сделки
  
  double MA1       = iMA(Symbol(), MATimeFrame, MA1_Period, MA1_Shift, MA1_Method, MA1_Price, 0); 
  double MA1_Pred  = iMA(Symbol(), MATimeFrame, MA1_Period, MA1_Shift, MA1_Method, MA1_Price, MA_sf);  
  double MA2       = iMA(Symbol(), MATimeFrame, MA2_Period, MA2_Shift, MA2_Method, MA2_Price, 0);
  double MARes     = MathAbs(MA1-MA2);
  double Del       = DelFX/DCCoef;       
        
      if ((MA1_Pred < MA1) && (MA1 > MA2) && (MARes > Del)) ResultMA =  1;    //основной на БАЙ
      if ((MA1_Pred > MA1) && (MA1 < MA2) && (MARes > Del)) ResultMA = -1;    //основной СЕЛЛ
 
  return (ResultMA);
} 
//==============================   Ограничения ССИ для постановки 1 ордера   ================================
   
int CCI()
{  
  int ResultCCI = 0;                                                          // если 0 запрещаем сделки
  double LevelCCI_0 = iCCI(Symbol(),CCI_tf,CCI_Per,0,0);                      // значение ССИ на текущем баре
  double LevelCCI_1 = iCCI(Symbol(),CCI_tf,CCI_Per,4,CCI_sf);                 // значение ССИ на предидущем баре
  CCI_Del = (LevelCCI_0 - LevelCCI_1);   
  if (debug) Print ("Разность значений CCI ", CCI_Del);
      if ((LevelCCI_0 < CCI_min) || (LevelCCI_0 > CCI_max)) {
         ResultCCI = 0;
         return (ResultCCI);                                                  // отсечка по уровням
      }   
      if (CCI_Del > 0) ResultCCI =  1;                                        // разрешаем БАЙ 
      if (CCI_Del < 0) ResultCCI = -1;                                        // разрешаем СЕЛЛ     
                   
  return (ResultCCI);
}  
//=================================== Подтверждение тренда по ADX ===========================================
int ADX()
{
    int ResultADX  = 0;                                                        // запрещаем сделку
    double ADX0    = NormalizeDouble (iADX (Symbol(), TF_ADX, Per_ADX, PriceADX, 0,      0), 0);
    double ADX1    = NormalizeDouble (iADX (Symbol(), TF_ADX, Per_ADX, PriceADX, 0, Sh_ADX), 0);
    ADX_Del        = (ADX0 - ADX1);
    if (ADX_Del <= 0) {
       ResultADX = 0; 
       return (ResultADX);                                                     // тренд на развороте или падает, запретили сделки
    }
    
       if ((ADX_Del > 0) && (ADX0 > ADX_Trend)) {
       ResultADX = 1;                                                          // тренд есть, разрешаем сделки
       return (ResultADX);
    }  else { 
       ResultADX = 0;                                                          // хз, тренд - не тренд... запрещаем..
       return (ResultADX);
    }
}       

//======================================= Расчет сигнала по MAonRSI =========================================

int MAonRSI() 
{
    int Result_MAonRSI = 0;
      
      double Ma0  = NormalizeDouble(iCustom(Symbol(), MAonRSI_TimeFr, "MAonRSI", RSI_Period, RSI_Metod, MA_Period, MA_Metod, 1, 0), 1);
      double Rsi0 = NormalizeDouble(iCustom(Symbol(), MAonRSI_TimeFr, "MAonRSI", RSI_Period, RSI_Metod, MA_Period, MA_Metod, 0, 0), 1);
      double Rsi1 = NormalizeDouble(iCustom(Symbol(), MAonRSI_TimeFr, "MAonRSI", RSI_Period, RSI_Metod, MA_Period, MA_Metod, 0, 1), 1);

       if ((Rsi0 > (Ma0 + Delta_MAonRSI)) && (Rsi0 > (Rsi1 + Delta_MAonRSI))) Result_MAonRSI =  1;       // основной на БАЙ
       if ((Rsi0 < (Ma0 - Delta_MAonRSI)) && (Rsi0 < (Rsi1 - Delta_MAonRSI))) Result_MAonRSI = -1;       // основной на СЕЛЛ
       if ((Rsi0 > RSI_max) || (Rsi0 < RSI_min))            Result_MAonRSI =  0;       // сигнал о перекупке/перепродаже
      
   return (Result_MAonRSI);
}         

//======================================= Отсечка флета по АС ===============================================
int AC()                                 // индикатор работает на текущем графике с текущим баром
{
    int ResultAC = 1;                                                         // разрешаем сделки
    double ACRes = NormalizeDouble (iAC (Symbol(), 0, 0),6);                  
    if ((ACRes >= ACmin) && (ACRes <= ACmax)) ResultAC = 0;                   // запрещаем сделки
    if (debug) Print ("АС сигнал = ", ResultAC); 
    return (ResultAC);
} 

//+----------------------------------------------------------------------------+
//|  Автор    : Night  http://www.instaforex-night.ru                          |
//|  Описание : Тралл                                                          |
//+----------------------------------------------------------------------------+
//|  Параметры:                                                                |
//|  Trail_TP -   ТР, который будет траллиться                                 |
//|  Trail_Dist - расстояние от цены, на котором тралится ТР                   |
//+----------------------------------------------------------------------------+

void Trailing (int Trail_Dist, int Trail_TP, int magic)
//--------------------------------------------------------------- 1 --
{
   string Symb=Symbol();                        // Финанс. инструмент
   double Aver = CalculateAveragePrice(magic);
//--------------------------------------------------------------- 2 --
   for(int i=1; i<=OrdersTotal(); i++)          // Цикл перебора ордер
     {
      if (OrderSelect(i-1,SELECT_BY_POS)==true) // Если есть следующий
        {                                       // Анализ ордеров:
         int Tip=OrderType();                   // Тип ордера
         if(OrderSymbol()!=Symb||Tip>1 || OrderMagicNumber()!= magic)continue;// Не наш ордер
         double SL=OrderStopLoss();             // SL выбранного орд.
         //------------------------------------------------------ 3 --
         while(true)                            // Цикл модификации
           {
            double TS = Trail_Dist;                // Исходное значение
            double TD = Trail_TP;
            int Min_Dist=MarketInfo(Symb,MODE_STOPLEVEL);//Миним. дист
            if (TS<Min_Dist)                    // Если меньше допуст.
               TS=Min_Dist;                     // Новое значение TS
            //--------------------------------------------------- 4 --
            bool Modify=false;                  // Не назначен к модифи
            switch(Tip)                         // По типу ордера
              {
               case 0 :                         // Ордер Buy
                if (Bid >= NormalizeDouble(Aver + (TD + TS)*Point, Digits))
                  {if (NormalizeDouble(SL,Digits)< NormalizeDouble(Bid-TS*Point,Digits)// Если ниже желаем.
                     || NormalizeDouble(SL,Digits)==0)
                    {
                     SL=Bid-TS*Point;           // то модифицируем его
                     string Text="Buy ";        // Текст для Buy 
                     Modify=true;               // Назначен к модифи.
                    }
                  }
                  break;                        // Выход из switch
               case 1 :                         // Ордер Sell
                if (Ask <= NormalizeDouble(Aver -(TD + TS)*Point,Digits))
                  {if (NormalizeDouble(SL,Digits)>NormalizeDouble(Ask+TS*Point,Digits) // Если выше желаем.                     
                     || NormalizeDouble(SL,Digits)==0)//или равно нулю
                    {
                     SL=Ask+TS*Point;           // то модифицируем его
                     Text="Sell ";              // Текст для Sell 
                     Modify=true;               // Назначен к модифи.
                    }
                  }
              }                                 // Конец switch
            if (Modify==false)                  // Если его не модифи
               break;                           // Выход из while
            //--------------------------------------------------- 5 --
            double TP    =OrderTakeProfit();    // TP выбранного орд.
            double Price =OrderOpenPrice();     // Цена выбранн. орд.
            int    Ticket=OrderTicket();        // Номер выбранн. орд.

            //Alert ("Модификация ",Text,Ticket,". Ждём ответ..");
            bool Ans=OrderModify(Ticket,Price,SL,TP,0);//Модифи его!
            //--------------------------------------------------- 6 --
            if (Ans==true)                      // Получилось :)
              {
               Alert ("Ордер ",Text,Ticket," модифицирован:)");
               break;                           // Из цикла модифи.
              }
            //--------------------------------------------------- 7 --
            int Error=GetLastError();           // Не получилось :(
            switch(Error)                       // Преодолимые ошибки
              {
               case 130:Alert("Неправильные стопы. Пробуем ещё раз.");
                  RefreshRates();               // Обновим данные
                  continue;                     // На след. итерацию
               case 136:Alert("Нет цен. Ждём новый тик..");
                  while(RefreshRates()==false)  // До нового тика
                     Sleep(1);                  // Задержка в цикле
                  continue;                     // На след. итерацию
               case 146:Alert("Подсистема торгов занята.Пробуем ещё");
                  Sleep(500);                   // Простое решение
                  RefreshRates();               // Обновим данные
                  continue;                     // На след. итерацию
                  // Критические ошибки
               case 2 : Alert("Общая ошибка.");
                  break;                        // Выход из switch
               case 5 : Alert("Старая версия клиентского терминала.");
                  break;                        // Выход из switch
               case 64: Alert("Счет заблокирован.");
                  break;                        // Выход из switch
               case 133:Alert("Торговля запрещена");
                  break;                        // Выход из switch
               default: Alert("Возникла ошибка ",Error);//Др. ошибки
              }
            break;                              // Из цикла модифи.
           }                                    // Конец цикла модифи.
         //------------------------------------------------------ 8 --
        }                                       // Конец анализа орд.
     }                                          // Конец перебора орд.
//--------------------------------------------------------------- 9 --
   return;                                      // Выход из start()
}

//==================================================================
//пересчёт новых ТР
//==================================================================
double CalculateAveragePrice(int magic)
{
  double AveragePrice = 0;
  double Count = 0;
  for (int i = 0; i < OrdersTotal(); i++)
    if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
      if (OrderSymbol() == Symbol() && OrderMagicNumber() == magic)
        if (OrderType() == OP_BUY || OrderType() == OP_SELL) 
        {
           AveragePrice += OrderOpenPrice() * OrderLots();
           Count += OrderLots();
        }
  if(AveragePrice > 0 && Count > 0)
    return( NormalizeDouble(AveragePrice / Count, Digits));
  else
    return(0);
}


